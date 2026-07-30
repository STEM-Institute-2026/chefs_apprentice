import 'cooking_step_model.dart';
import 'nutrition_model.dart';

class RecipeModel {
  final String recipeId;
  final String title;
  final String description;
  final String imageUrl;
  final int cookTimeMinutes;
  final int activePrepTimeMinutes;
  final int servings;
  final String difficultyTier;
  final String mealType;
  final List<String> tags;
  final List<String> equipment;
  final Map<String, String> ingredients;
  final double estimatedCost;
  final double costPerServing;
  final double estimatedRestaurantCost;
  final String startCookingButtonLabel;
  final NutritionModel nutritionStats;
  final List<CookingStepModel> steps;

  const RecipeModel({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookTimeMinutes,
    required this.activePrepTimeMinutes,
    required this.servings,
    required this.difficultyTier,
    required this.mealType,
    required this.tags,
    required this.equipment,
    required this.ingredients,
    required this.estimatedCost,
    required this.costPerServing,
    required this.estimatedRestaurantCost,
    required this.startCookingButtonLabel,
    required this.steps,
    required this.nutritionStats,
  });
}