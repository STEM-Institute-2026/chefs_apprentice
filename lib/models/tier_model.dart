import 'skill_model.dart';
import 'recipe_model.dart';

class TierModel {
  final String id;
  final int tierNumber;
  final String title;
  final String description;
  final String coverImageUrl;
  final List<SkillModel> skills;
  final List<RecipeModel> recipes;

  const TierModel({
    required this.id,
    required this.tierNumber,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.skills,
    required this.recipes,
  });
}