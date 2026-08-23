import 'skill_model.dart';
import 'recipe_model.dart';

class TierModel {
  final String id;
  final int tierNumber;
  final String title;
  final String description;
  final String coverImageUrl;
  final List<SkillModel> skills;
  final List<RecipeModel> recipes; // 👈 Keeps full RecipeModels for your UI

  const TierModel({
    required this.id,
    required this.tierNumber,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.skills,
    required this.recipes,
  });

  factory TierModel.fromMap(
    Map<String, dynamic> map, 
    List<RecipeModel> allRecipes, // 👈 Pass all loaded recipes into fromMap
  ) {
    // 1. Extract the string IDs from JSON
    final List<String> recipeIds = List<String>.from(map['recipeIds'] ?? []);

    // 2. Filter master list to get full RecipeModel objects for this tier
    final List<RecipeModel> matchingRecipes = allRecipes
        .where((recipe) => recipeIds.contains(recipe.recipeId))
        .toList();

    return TierModel(
      id: map['id'] ?? '',
      tierNumber: map['tierNumber'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      skills: (map['skills'] as List<dynamic>?)
              ?.map((s) => SkillModel.fromMap(s))
              .toList() ??
          [],
      recipes: matchingRecipes, // 👈 Assigned directly to your model
    );
  }
}