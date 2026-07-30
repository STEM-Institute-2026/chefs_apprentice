import '../models/models.dart';

class HistoryService {
  // --- 1. COOKED MEALS STORAGE ---
  static final List<CookedHistoryModel> savedMeals = [];

  static void addMeal(CookedHistoryModel meal) {
    savedMeals.add(meal);
  }

  static Set<String> get completedRecipeIds {
    return savedMeals.map((meal) => meal.recipeId).toSet();
  }

  static bool isRecipeCompleted(String recipeId) {
    return completedRecipeIds.contains(recipeId);
  }


  // --- 2. FAVORITES STORAGE ---
  static final Set<String> favoriteRecipeIds = {};

  // Toggle favorite on or off
  static void toggleFavorite(String recipeId) {
    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds.remove(recipeId);
    } else {
      favoriteRecipeIds.add(recipeId);
    }
  }

  // Quick check if a recipe is favorited
  static bool isRecipeFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}