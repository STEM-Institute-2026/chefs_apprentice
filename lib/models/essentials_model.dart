import 'recipe_model.dart';

/// Individual item representing a fundamental skill and its paired recipe.
class StarterPathItemModel {
  final String skillName;
  final RecipeModel? recipe;
  final String description;

  const StarterPathItemModel({
    required this.skillName,
    this.recipe,
    required this.description,
  });

  factory StarterPathItemModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeModel> allRecipes,
  ) {
    final String recipeId = map['recipeId'] ?? '';

    // Resolves the single recipeId against master list
    final matchingRecipes = allRecipes.where((r) => r.recipeId == recipeId);

    return StarterPathItemModel(
      skillName: map['skillName'] ?? '',
      recipe: matchingRecipes.isNotEmpty ? matchingRecipes.first : null,
      description: map['description'] ?? '',
    );
  }

  // ===========================================================================
  // PROGRESS HELPER METHOD
  // ===========================================================================

  /// Checks if the user completed the recipe attached to this skill.
  bool isCompleted(Set<String> userCompletedRecipeIds) {
    if (recipe == null) return false;
    return userCompletedRecipeIds.contains(recipe!.recipeId);
  }
}

/// Category section for meal-type fundamentals (Breakfast, Lunch, Dinner).
class MealFundamentalModel {
  final String categoryName;
  final String description;
  final String imageUrl;
  final List<FundamentalStrategyModel> strategies;
  final List<RecipeModel> recipes;

  const MealFundamentalModel({
    required this.categoryName,
    required this.description,
    required this.imageUrl,
    required this.strategies,
    required this.recipes,
  });

  factory MealFundamentalModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeModel> allRecipes,
  ) {
    final List<String> recipeIds = List<String>.from(map['recipeIds'] ?? []);

    final resolvedRecipes = allRecipes
        .where((recipe) => recipeIds.contains(recipe.recipeId))
        .toList();

    return MealFundamentalModel(
      categoryName: map['categoryName'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      recipes: resolvedRecipes,
      strategies: (map['strategies'] as List<dynamic>?)
              ?.map((item) => FundamentalStrategyModel.fromMap(item))
              .toList() ??
          [],
    );
  }

  // ===========================================================================
  // PROGRESS HELPER METHODS
  // ===========================================================================

  int getCompletedCount(Set<String> userCompletedRecipeIds) {
    return recipes.where((r) => userCompletedRecipeIds.contains(r.recipeId)).length;
  }

  double getCompletionPercentage(Set<String> userCompletedRecipeIds) {
    if (recipes.isEmpty) return 0.0;
    return getCompletedCount(userCompletedRecipeIds) / recipes.length;
  }
}

class FundamentalStrategyModel {
  final String title;
  final String tip;

  const FundamentalStrategyModel({
    required this.title,
    required this.tip,
  });

  factory FundamentalStrategyModel.fromMap(Map<String, dynamic> map) {
    return FundamentalStrategyModel(
      title: map['title'] ?? '',
      tip: map['tip'] ?? '',
    );
  }
}

/// Top-level container model for loading the entire Essentials tab data.
class EssentialsTabModel {
  final String title;
  final String description;
  final String coverImageUrl;
  final String essentialsMethodology;
  final List<StarterPathItemModel> starterPath;
  final List<MealFundamentalModel> mealFundamentals;

  const EssentialsTabModel({
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.essentialsMethodology,
    required this.starterPath,
    required this.mealFundamentals,
  });

  factory EssentialsTabModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeModel> allRecipes,
  ) {
    return EssentialsTabModel(
      title: map['title'] ?? 'Essentials',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      essentialsMethodology: map['essentialsMethodology'] ?? '',
      starterPath: (map['starterPath'] as List<dynamic>?)
              ?.map((item) => StarterPathItemModel.fromMap(item, allRecipes))
              .toList() ??
          [],
      mealFundamentals: (map['mealFundamentals'] as List<dynamic>?)
              ?.map((item) => MealFundamentalModel.fromMap(item, allRecipes))
              .toList() ??
          [],
    );
  }

  // ===========================================================================
  // PROGRESS HELPER METHODS
  // ===========================================================================

  /// Total recipes in the starter path
  int get totalStarterRecipes =>
      starterPath.where((item) => item.recipe != null).length;

  /// Total completed recipes in starter path
  int getCompletedStarterCount(Set<String> userCompletedRecipeIds) {
    return starterPath
        .where((item) => item.recipe != null && item.isCompleted(userCompletedRecipeIds))
        .length;
  }

  /// Completion percentage (0.0 to 1.0) for the starter path
  double getStarterCompletionPercentage(Set<String> userCompletedRecipeIds) {
    if (totalStarterRecipes == 0) return 0.0;
    return getCompletedStarterCount(userCompletedRecipeIds) / totalStarterRecipes;
  }
}