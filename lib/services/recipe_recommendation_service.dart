
import 'dart:math';

import '../models/models.dart';

/// Generates personalized recipe recommendations.
///
/// This service does not fetch data or modify the original recipe list.
/// Pass in the recipe catalog, user preferences, and cooking history.
/// It returns up to five unique RecipeModel objects in randomized order.
class RecipeRecommendationService {
  RecipeRecommendationService._();

  static const int _personalizedCount = 4;
  static const int _discoveryCount = 1;
  static const int _candidatePoolSize = 8;

  static const double _maxCuisineScore = 30;
  static const double _maxIngredientScore = 25;
  static const double _maxTimeScore = 20;

  /// Main entry point.
  ///
  /// [allRecipes] contains the full recipe catalog.
  /// [preferences] contains the user's saved cooking preferences.
  /// [cookingHistory] contains individual cooking-session records.
  ///
  /// [random] is optional and can be supplied for deterministic testing.
  static List<RecipeModel> generateRecommendedRecipes({
    required List<RecipeModel> allRecipes,
    required CookingPreferencesModel preferences,
    required List<CookedHistoryModel> cookingHistory,
    Random? random,
  }) {
    final rng = random ?? Random();

    if (allRecipes.isEmpty) return [];

    // Remove duplicate recipe IDs without modifying the original list.
    final uniqueRecipes = <String, RecipeModel>{};

    for (final recipe in allRecipes) {
      if (recipe.recipeId.trim().isEmpty) continue;

      uniqueRecipes.putIfAbsent(recipe.recipeId, () => recipe);
    }

    if (uniqueRecipes.isEmpty) return [];

    // Allergy filtering always happens before scoring or selection.
    final eligibleRecipes = uniqueRecipes.values
        .where((recipe) => _isAllergyEligible(recipe, preferences))
        .toList();

    if (eligibleRecipes.isEmpty) return [];

    // Count actual cooking sessions for each recipe.
    final timesCookedByRecipe = <String, int>{};

    for (final meal in cookingHistory) {
      if (meal.recipeId.trim().isEmpty) continue;

      timesCookedByRecipe.update(
        meal.recipeId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    // Fewer than five eligible recipes: return all available recipes.
    if (eligibleRecipes.length < 5) {
      _shuffle(eligibleRecipes, rng);
      return eligibleRecipes;
    }

    // Shuffle first so tied scores do not consistently favor catalog order.
    _shuffle(eligibleRecipes, rng);

    // Calculate preference + history scores.
    final adjustedScores = <String, double>{};

    for (final recipe in eligibleRecipes) {
      final baseScore = _calculateBaseScore(recipe, preferences);
      final timesCooked = timesCookedByRecipe[recipe.recipeId] ?? 0;
      final historyAdjustment = _historyAdjustment(timesCooked);

      adjustedScores[recipe.recipeId] =
          baseScore + historyAdjustment;
    }

    // Rank recipes by adjusted score.
    eligibleRecipes.sort((a, b) {
      final scoreA = adjustedScores[a.recipeId]!;
      final scoreB = adjustedScores[b.recipeId]!;
      return scoreB.compareTo(scoreA);
    });

    // Only the top eight candidates are considered for personalized slots.
    final candidateCount = min(
      _candidatePoolSize,
      eligibleRecipes.length,
    );

    final candidates = eligibleRecipes
        .take(candidateCount)
        .toList();

    final selected = <RecipeModel>[];

    // Select four personalized recipes using weighted random selection
    // without replacement.
    for (int i = 0;
        i < _personalizedCount && candidates.isNotEmpty;
        i++) {
      final weights = _calculateWeights(
        candidates,
        adjustedScores,
      );

      final chosenIndex = _weightedRandomIndex(weights, rng);
      selected.add(candidates.removeAt(chosenIndex));
    }

    // Select a discovery recipe uniformly from every remaining eligible
    // recipe, including those outside the top-eight candidate pool.
    final selectedIds = selected.map((r) => r.recipeId).toSet();

    final remainingRecipes = eligibleRecipes
        .where((recipe) => !selectedIds.contains(recipe.recipeId))
        .toList();

    if (remainingRecipes.isNotEmpty && _discoveryCount > 0) {
      final discoveryIndex = rng.nextInt(remainingRecipes.length);
      selected.add(remainingRecipes[discoveryIndex]);
    }

    // Randomize display order so discovery is not always last.
    _shuffle(selected, rng);

    return selected;
  }

  /// Excludes recipes that conflict with declared allergies.
  ///
  /// SAFETY NOTE:
  /// The current RecipeModel cannot distinguish missing allergen metadata
  /// from a verified empty allergen list. Until metadata is complete and
  /// verified, recipes with empty allergen lists are excluded for users
  /// who have declared allergies.
  static bool _isAllergyEligible(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    final userAllergies = preferences.allergies
        .map(_normalize)
        .where((value) => value.isNotEmpty)
        .toSet();

    if (userAllergies.isEmpty) return true;

    // Conservative behavior while allergen metadata is incomplete.
    if (recipe.allergens.isEmpty) return false;

    final recipeAllergens = recipe.allergens
        .map(_normalize)
        .where((value) => value.isNotEmpty)
        .toSet();

    // If a declared allergy is present in the recipe's allergen list,
    // the recipe is not eligible.
    return !recipeAllergens.any(userAllergies.contains);
  }

  /// Calculates the preference score before applying cooking history.
  static double _calculateBaseScore(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    final cuisineScore = _calculateCuisineScore(
      recipe,
      preferences,
    );

    final skillScore = _calculateSkillScore(
      recipe,
      preferences,
    );

    final ingredientScore = _calculateIngredientScore(
      recipe,
      preferences,
    );

    final timeScore = _calculateTimeScore(
      recipe,
      preferences,
    );

    return cuisineScore +
        skillScore +
        ingredientScore +
        timeScore;
  }

  static double _calculateCuisineScore(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    if (preferences.favoriteCuisines.isEmpty) {
      return 20;
    }

    final recipeCuisine = _normalize(recipe.cuisine);

    final matches = preferences.favoriteCuisines
        .map(_normalize)
        .any((cuisine) =>
            cuisine.isNotEmpty && cuisine == recipeCuisine);

    return matches ? _maxCuisineScore : 15;
  }

  static double _calculateSkillScore(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    final userTier = preferences.cookingSkillTier.clamp(1, 3);
    final recipeTier = _parseRecipeSkillTier(recipe.difficultyTier);

    // Conservative fallback for an invalid or missing recipe tier.
    if (recipeTier == null) return 0;

    const scores = <int, Map<int, double>>{
      1: {1: 10, 2: 5, 3: 0},
      2: {1: 5, 2: 10, 3: 5},
      3: {1: 3, 2: 5, 3: 10},
    };

    return scores[userTier]![recipeTier] ?? 0;
  }

  /// Parses values such as "Tier 1", "Tier 2", and "Tier 3".
  static int? _parseRecipeSkillTier(String difficultyTier) {
    final match = RegExp(
      r'\b(?:tier\s*)?([1-3])\b',
      caseSensitive: false,
    ).firstMatch(difficultyTier.trim());

    if (match == null) return null;

    return int.tryParse(match.group(1)!);
  }

  /// Scores recipes according to the user's preferred ingredients.
  ///
  /// Uses substring matching so preferences can match ingredient keys
  /// containing additional descriptors, such as "Diced Mushrooms".
  /// Each selected preference can contribute at most one match per recipe.
  static double _calculateIngredientScore(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    final selectedIngredients = preferences.preferredIngredients
        .map(_normalize)
        .where((ingredient) => ingredient.isNotEmpty)
        .toSet();

    if (selectedIngredients.isEmpty) {
      return _maxIngredientScore / 2;
    }

    // Ingredient names are keys; quantities are values.
    final recipeIngredients = recipe.ingredients.keys
        .map(_normalize)
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    // A preference matches if it appears anywhere in an ingredient key.
    final matchedCount = selectedIngredients.where((selected) {
      return recipeIngredients.any(
        (ingredient) => ingredient.contains(selected),
      );
    }).length;

    return _maxIngredientScore *
        matchedCount /
        selectedIngredients.length;
  }

  static double _calculateTimeScore(
    RecipeModel recipe,
    CookingPreferencesModel preferences,
  ) {
    final timeLimit = preferences.maxCookTimeMinutes;

    if (timeLimit == null || timeLimit <= 0) {
      return _maxTimeScore;
    }

    final recipeTime = recipe.cookTimeMinutes;

    if (recipeTime <= timeLimit * 0.75) return 10;
    if (recipeTime <= timeLimit) return 8;
    if (recipeTime <= timeLimit * 1.25) return 5;

    return 0;
  }

  /// Applies the agreed cooking-history adjustment.
  static double _historyAdjustment(int timesCooked) {
    if (timesCooked == 0) return 10;
    if (timesCooked == 1) return 5;
    if (timesCooked <= 3) return 0;
    if (timesCooked <= 5) return -10;

    return -15;
  }

  /// Converts adjusted scores into weights between 1 and 2.
  ///
  /// Equal scores give every candidate weight 1.
  /// Otherwise:
  /// weight = 1 + (score - minimum score) / score range
  static List<double> _calculateWeights(
    List<RecipeModel> candidates,
    Map<String, double> adjustedScores,
  ) {
    if (candidates.isEmpty) return [];

    final scores = candidates
        .map((recipe) => adjustedScores[recipe.recipeId]!)
        .toList();

    final minScore = scores.reduce(min);
    final maxScore = scores.reduce(max);
    final scoreRange = maxScore - minScore;

    if (scoreRange == 0) {
      return List<double>.filled(candidates.length, 1);
    }

    return candidates.map((recipe) {
      final score = adjustedScores[recipe.recipeId]!;

      return 1 + (score - minScore) / scoreRange;
    }).toList();
  }

  /// Picks one index proportionally to its weight.
  static int _weightedRandomIndex(
    List<double> weights,
    Random rng,
  ) {
    final totalWeight = weights.fold<double>(
      0,
      (total, weight) => total + weight,
    );

    var roll = rng.nextDouble() * totalWeight;

    for (int i = 0; i < weights.length; i++) {
      roll -= weights[i];

      if (roll < 0) return i;
    }

    // Floating-point safety fallback.
    return weights.length - 1;
  }

  /// Fisher-Yates shuffle.
  static void _shuffle<T>(List<T> items, Random rng) {
    for (int i = items.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
  }

  /// Normalizes case and repeated/leading/trailing whitespace.
  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }
}

