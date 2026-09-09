import 'skill_model.dart';
import 'recipe_model.dart';

class SkillModuleModel {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String difficultyLevel;
  final List<SkillModel> skills; // Lesson cards or technique guides
  
  // Directly parsed RecipeModels divided by difficulty tier
  final List<RecipeModel> tier1Recipes;
  final List<RecipeModel> tier2Recipes;
  final List<RecipeModel> tier3Recipes;

  const SkillModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.difficultyLevel,
    required this.skills,
    required this.tier1Recipes,
    required this.tier2Recipes,
    required this.tier3Recipes,
  });

  factory SkillModuleModel.fromMap(
    Map<String, dynamic> map,
    List<RecipeModel> allRecipes,
  ) {
    // 1. Extract string ID lists from JSON for each difficulty tier
    final List<String> t1Ids = List<String>.from(map['tier1RecipeIds'] ?? []);
    final List<String> t2Ids = List<String>.from(map['tier2RecipeIds'] ?? []);
    final List<String> t3Ids = List<String>.from(map['tier3RecipeIds'] ?? []);

    // 2. Helper function to match IDs against the loaded recipes master list
    List<RecipeModel> resolveRecipes(List<String> ids) {
      return allRecipes.where((recipe) => ids.contains(recipe.recipeId)).toList();
    }

    return SkillModuleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      difficultyLevel: map['difficultyLevel'] ?? '',
      skills: (map['skills'] as List<dynamic>?)
              ?.map((s) => SkillModel.fromMap(s))
              .toList() ??
          [],
      tier1Recipes: resolveRecipes(t1Ids),
      tier2Recipes: resolveRecipes(t2Ids),
      tier3Recipes: resolveRecipes(t3Ids),
    );
  }

  // ===========================================================================
  // BADGE & PROGRESS HELPER METHODS
  // ===========================================================================

  /// Returns a combined list of all practice recipes in this skill module.
  List<RecipeModel> get allRecipes => [
        ...tier1Recipes,
        ...tier2Recipes,
        ...tier3Recipes,
      ];

  /// Returns a combined list of all unique recipe IDs in this skill module.
  List<String> get allRecipeIds =>
      allRecipes.map((recipe) => recipe.recipeId).toList();

  /// Calculates how many recipes in this skill module the user has completed.
  int getCompletedCount(Set<String> userCompletedRecipeIds) {
    return allRecipeIds.where((id) => userCompletedRecipeIds.contains(id)).length;
  }

  /// Calculates the completion percentage (0.0 to 1.0) for this skill module.
  double getCompletionPercentage(Set<String> userCompletedRecipeIds) {
    if (allRecipes.isEmpty) return 0.0;
    return getCompletedCount(userCompletedRecipeIds) / allRecipes.length;
  }

  /// Checks if the user has cooked every practice recipe in this skill module.
  bool isFullyCompleted(Set<String> userCompletedRecipeIds) {
    if (allRecipes.isEmpty) return false;
    return getCompletedCount(userCompletedRecipeIds) == allRecipes.length;
  }

  /// Checks if a specific recipe belongs to this skill module.
  bool containsRecipe(String recipeId) {
    return allRecipeIds.contains(recipeId);
  }
}