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
  final String cuisine;             // e.g. "Italian", "Mexican", "American"
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
    this.cuisine = '',               
    this.dietary = const [],          
    this.tags = const [],             
    required this.ingredients,
    required this.estimatedCost,
    required this.costPerServing,
    required this.estimatedRestaurantCost,
    required this.startCookingButtonLabel,
    required this.steps,
    required this.nutritionStats,
  });

  /// Factory constructor to parse JSON Map into RecipeModel
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      recipeId: map['recipeId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      cookTimeMinutes: map['cookTimeMinutes'] ?? 0,
      activePrepTimeMinutes: map['activePrepTimeMinutes'] ?? 0,
      servings: map['servings'] ?? 1,
      difficultyTier: map['difficultyTier'] ?? 'Tier 1',
      mealType: map['mealType'] ?? 'Dinner',
      cuisine: map['cuisine'] ?? '',
      
      // Safely casting arrays
      dietary: List<String>.from(map['dietary'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      
      // Safely casting key-value maps
      ingredients: Map<String, String>.from(map['ingredients'] ?? {}),
      
      // Safe double conversion from num
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      costPerServing: (map['costPerServing'] as num?)?.toDouble() ?? 0.0,
      estimatedRestaurantCost: (map['estimatedRestaurantCost'] as num?)?.toDouble() ?? 0.0,
      
      startCookingButtonLabel: map['startCookingButtonLabel'] ?? 'Start Cooking',
      
      // Parsing nested model
      nutritionStats: NutritionModel.fromMap(map['nutritionStats'] ?? {}),
      
      // Mapping list of step maps to CookingStepModels
      steps: (map['steps'] as List<dynamic>?)
              ?.map((step) => CookingStepModel.fromMap(step))
              .toList() ??
          [],
    );
  }
}