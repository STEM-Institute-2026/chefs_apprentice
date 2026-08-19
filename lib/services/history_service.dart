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

  /// Helper to calculate Max XP for any level dynamically.
  /// Formula: Level 1 = 1000 XP. Every level after adds 750 XP.
  static int getXpForLevel(int level) {
    return 1000 + ((level - 1) * 750);
  }

  /// 1. SEPARATE MEAL SAVING (No XP added here)
  /// Call this when the user taps "Save to Cook History".
  static void addMeal(CookedHistoryModel meal) {
    final bool isNewRecipe = !completedRecipeIds.contains(meal.recipeId);

    // Save meal to history list
    savedMealsNotifier.value = [...savedMealsNotifier.value, meal];

    // Update streak and cooking stats (without modifying XP)
    _updateStreakAndMealStats(meal.recipeId, isNewRecipe: isNewRecipe);
  }

  /// Private helper for updating streaks and cook counts
  static void _updateStreakAndMealStats(String recipeId, {required bool isNewRecipe}) {
    final profile = currentProfile;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = profile.currentStreak;

    if (profile.lastCookedDate == null) {
      newStreak = 1;
    } else {
      final lastCooked = DateTime(
        profile.lastCookedDate!.year,
        profile.lastCookedDate!.month,
        profile.lastCookedDate!.day,
      );
      final differenceInDays = today.difference(lastCooked).inDays;

      if (differenceInDays == 1) {
        newStreak += 1;
      } else if (differenceInDays > 1) {
        newStreak = 1;
      }
    }

    // Derive unique recipes tried directly from all saved meals
    final uniqueRecipesCount = completedRecipeIds.length;

    userProfileNotifier.value = profile.copyWith(
      currentStreak: newStreak,
      lastCookedDate: today,
      totalTimesCooked: profile.totalTimesCooked + 1,
      recipesTried: uniqueRecipesCount,
    );
  }

  // --- 3. STANDALONE XP ENGINE ---

  /// Direct method to award XP immediately (e.g., when the reward dialog opens)
  static XpRewardSnapshot addXp(int amountEarned) {
    final profile = currentProfile;
    final int startXp = profile.currentXp;
    final int startLevel = profile.currentLevel;
    final int newTotalXp = profile.totalXp + amountEarned;

    final stats = _calculateLevelStats(newTotalXp);

    userProfileNotifier.value = profile.copyWith(
      totalXp: newTotalXp,
      currentLevel: stats.level,
      currentXp: stats.xpInLevel,
      maxXp: stats.maxXpForLevel,
    );

    return XpRewardSnapshot(
      startXp: startXp,
      startLevel: startLevel,
      xpEarned: amountEarned,
      finalXp: stats.xpInLevel,
      finalLevel: stats.level,
      didLevelUp: stats.level > startLevel,
    );
  }

  /// Math Engine: Calculates level and progress using total XP as source of truth
  static ({int level, int xpInLevel, int maxXpForLevel}) _calculateLevelStats(int totalXp) {
    int level = 1;
    int remainingXp = totalXp;
    int currentMax = getXpForLevel(level);

    while (remainingXp >= currentMax) {
      remainingXp -= currentMax;
      level++;
      currentMax = getXpForLevel(level);
    }

    return (
      level: level,
      xpInLevel: remainingXp,
      maxXpForLevel: currentMax,
    );
  }

  // --- 4. RECIPE STATUS HELPERS ---
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

  // --- 5. TIER UNLOCK LOGIC ---
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

  // --- 6. FAVORITES STORAGE (REACTIVE) ---
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

    favoriteRecipeIdsNotifier.value = updatedFavorites;
  }

  static bool isRecipeFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}