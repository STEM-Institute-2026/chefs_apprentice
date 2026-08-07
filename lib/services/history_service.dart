import '../models/models.dart';
import '../mock_tier_data.dart'; // Adjust path as needed

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

  // Helper method: Counts completed recipes in a list
  static int getCompletedCount(List<RecipeModel> recipes) {
    return recipes
        .where((recipe) => completedRecipeIds.contains(recipe.recipeId))
        .length;
  }

  // --- 2. TIER UNLOCK LOGIC (From your TierSelectionScreen) ---
  static bool isTierUnlocked(int tierNumber) {
    if (tierNumber <= 1) return true;

    List<RecipeModel> previousTierRecipes = switch (tierNumber) {
      2 => tier1Recipes,
      3 => tier2Recipes,
      4 => tier3Recipes,
      _ => [],
    };

    return getCompletedCount(previousTierRecipes) >= 2;
  }

  /// Helper: Gets the highest tier the user is currently working on!
  static TierModel getActiveTier(List<TierModel> allTiers) {
    // Loop backwards from highest tier to tier 1
    for (int i = allTiers.length - 1; i >= 0; i--) {
      final tier = allTiers[i];
      if (isTierUnlocked(tier.tierNumber)) {
        return tier; // Returns highest unlocked tier!
      }
    }
    return allTiers.first; // Fallback to Tier 1
  }

  // --- 3. FAVORITES STORAGE ---
  static final Set<String> favoriteRecipeIds = {};

  static void toggleFavorite(String recipeId) {
    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds.remove(recipeId);
    } else {
      favoriteRecipeIds.add(recipeId);
    }
  }

  static bool isRecipeFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}