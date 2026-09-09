import 'recipe_model.dart';

class PantryItemModel {
  final String name;
  final String description;

  const PantryItemModel({
    required this.name,
    required this.description,
  });

  factory PantryItemModel.fromMap(Map<String, dynamic> map) {
    return PantryItemModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class CuisineModuleModel {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String flavorProfileOverview;
  final List<PantryItemModel> essentialPantry;
  final List<String> keyTechniques;

  // Tiered recipe lists (resolved automatically at load time)
  final List<RecipeModel> tier1Recipes;
  final List<RecipeModel> tier2Recipes;
  final List<RecipeModel> tier3Recipes;

  const CuisineModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.flavorProfileOverview,
    required this.essentialPantry,
    required this.keyTechniques,
    required this.tier1Recipes,
    required this.tier2Recipes,
    required this.tier3Recipes,
  });

  factory CuisineModuleModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeModel> allRecipes,
  ) {
    // 1. Safe extraction of string ID lists (defaults to [] if missing)
    final List<String> t1Ids = List<String>.from(map['tier1RecipeIds'] ?? []);
    final List<String> t2Ids = List<String>.from(map['tier2RecipeIds'] ?? []);
    final List<String> t3Ids = List<String>.from(map['tier3RecipeIds'] ?? []);

    // 2. Helper function to match IDs against master recipe list
    List<RecipeModel> resolveRecipes(List<String> ids) {
      return allRecipes
          .where((recipe) => ids.contains(recipe.recipeId))
          .toList();
    }

    return CuisineModuleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      flavorProfileOverview: map['flavorProfileOverview'] ?? '',
      essentialPantry: (map['essentialPantry'] as List<dynamic>?)
              ?.map((item) => PantryItemModel.fromMap(item))
              .toList() ??
          [],
      keyTechniques: List<String>.from(map['keyTechniques'] ?? []),
      tier1Recipes: resolveRecipes(t1Ids),
      tier2Recipes: resolveRecipes(t2Ids),
      tier3Recipes: resolveRecipes(t3Ids),
    );
  }

  // ===========================================================================
  // BADGE & PROGRESS HELPER METHODS
  // ===========================================================================

  /// Returns a combined list of all recipes belonging to this module across all tiers.
  List<RecipeModel> get allRecipes => [
        ...tier1Recipes,
        ...tier2Recipes,
        ...tier3Recipes,
      ];

  /// Returns a combined list of all unique recipe IDs belonging to this cuisine.
  List<String> get allRecipeIds =>
      allRecipes.map((recipe) => recipe.recipeId).toList();

  /// Calculates how many recipes in this cuisine module the user has completed.
  int getCompletedCount(Set<String> userCompletedRecipeIds) {
    return allRecipeIds.where((id) => userCompletedRecipeIds.contains(id)).length;
  }

  /// Calculates the completion percentage (0.0 to 1.0) for this cuisine.
  double getCompletionPercentage(Set<String> userCompletedRecipeIds) {
    if (allRecipes.isEmpty) return 0.0;
    return getCompletedCount(userCompletedRecipeIds) / allRecipes.length;
  }

  /// Checks if the user has cooked every single recipe in this cuisine module.
  bool isFullyCompleted(Set<String> userCompletedRecipeIds) {
    if (allRecipes.isEmpty) return false;
    return getCompletedCount(userCompletedRecipeIds) == allRecipes.length;
  }

  /// Checks if a specific recipe belongs to this cuisine module.
  bool containsRecipe(String recipeId) {
    return allRecipeIds.contains(recipeId);
  }
}