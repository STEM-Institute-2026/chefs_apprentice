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
  
  // Filtering fields
  final String mealType;            // e.g. "Breakfast", "Lunch", "Dinner"
  final String cuisine;             // e.g. "Italian", "Mexican", "American" (Default to "" if none)
  final List<String> dietary;       // e.g. ["Vegetarian", "Vegan", "Gluten-Free"]
  final List<String> tags;          // General keywords like ["Quick", "Budget", "Spicy"]

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
    this.cuisine = '',               // Optional with default empty string
    this.dietary = const [],          // Default to empty list if no dietary tags
    this.tags = const [],             // Default to empty list if no extra tags
    required this.ingredients,
    required this.estimatedCost,
    required this.costPerServing,
    required this.estimatedRestaurantCost,
    required this.startCookingButtonLabel,
    required this.steps,
    required this.nutritionStats,
  });
}