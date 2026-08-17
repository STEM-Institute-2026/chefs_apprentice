import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../mock_tier_data.dart'; // Adjust path if needed
import '../mock_data.dart'; // Adjust path if needed

class HistoryService {
  // --- 1. USER PROFILE STORAGE ---
  static final ValueNotifier<UserProfileModel> userProfileNotifier =
      ValueNotifier<UserProfileModel>(
    mockUserProfile.copyWith(
      currentStreak: mockUserProfile.currentStreak,
      lastCookedDate: mockUserProfile.lastCookedDate,
    ),
  );

  static UserProfileModel get currentProfile => userProfileNotifier.value;

  // --- 2. COOKED MEALS STORAGE & STREAKS ---
  static final ValueNotifier<List<CookedHistoryModel>> savedMealsNotifier =
      ValueNotifier<List<CookedHistoryModel>>([]);

  static List<CookedHistoryModel> get savedMeals => savedMealsNotifier.value;

  static void addMeal(CookedHistoryModel meal) {
    // Check if new recipe BEFORE adding it to saved list
    final bool isNewRecipe = !completedRecipeIds.contains(meal.recipeId);

    // Add meal to history list
    savedMealsNotifier.value = [...savedMealsNotifier.value, meal];

    // Automatically update streak & profile stats
    _updateStreakAndStats(meal.recipeId, isNewRecipe: isNewRecipe);
  }

  static void _updateStreakAndStats(String recipeId, {required bool isNewRecipe}) {
    final profile = currentProfile;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = profile.currentStreak;

    if (profile.lastCookedDate == null) {
      // First meal ever logged
      newStreak = 1;
    } else {
      final lastCooked = DateTime(
        profile.lastCookedDate!.year,
        profile.lastCookedDate!.month,
        profile.lastCookedDate!.day,
      );
      final differenceInDays = today.difference(lastCooked).inDays;

      if (differenceInDays == 1) {
        // Cooked yesterday: increment streak by 1
        newStreak += 1;
      } else if (differenceInDays > 1) {
        // Missed one or more days: reset streak to 1
        newStreak = 1;
      }
      // If differenceInDays == 0 (already cooked today), streak remains unchanged
    }

    // Update profile and notify all listening screens automatically
    userProfileNotifier.value = profile.copyWith(
      currentStreak: newStreak,
      lastCookedDate: today,
      totalTimesCooked: profile.totalTimesCooked + 1,
      recipesTried: isNewRecipe ? profile.recipesTried + 1 : profile.recipesTried,
    );
  }

  static Set<String> get completedRecipeIds {
    return savedMeals.map((meal) => meal.recipeId).toSet();
  }

  static bool isRecipeCompleted(String recipeId) {
    return completedRecipeIds.contains(recipeId);
  }

  static int getCompletedCount(List<RecipeModel> recipes) {
    return recipes
        .where((recipe) => completedRecipeIds.contains(recipe.recipeId))
        .length;
  }

  // --- 3. TIER UNLOCK LOGIC ---
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

  static TierModel getActiveTier(List<TierModel> allTiers) {
    for (int i = allTiers.length - 1; i >= 0; i--) {
      final tier = allTiers[i];
      if (isTierUnlocked(tier.tierNumber)) {
        return tier;
      }
    }
    return allTiers.first;
  }

  // --- 4. FAVORITES STORAGE (REACTIVE) ---
  static final ValueNotifier<Set<String>> favoriteRecipeIdsNotifier =
      ValueNotifier<Set<String>>({});

  static Set<String> get favoriteRecipeIds => favoriteRecipeIdsNotifier.value;

  static void toggleFavorite(String recipeId) {
    final updatedFavorites = Set<String>.from(favoriteRecipeIdsNotifier.value);

    if (updatedFavorites.contains(recipeId)) {
      updatedFavorites.remove(recipeId);
    } else {
      updatedFavorites.add(recipeId);
    }

    // Reassigning triggers ValueListenableBuilder rebuilds
    favoriteRecipeIdsNotifier.value = updatedFavorites;
  }

  static bool isRecipeFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}