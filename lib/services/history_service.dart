import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class HistoryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. USER PROFILE STORAGE ---
  static final ValueNotifier<UserProfileModel> userProfileNotifier =
      ValueNotifier<UserProfileModel>(
    UserProfileModel(
      userId: '',
      userName: 'Chef',
      currentLevel: 1,
      currentXp: 0,
      maxXp: 1000,
      recipesTried: 0,
      totalTimesCooked: 0,
    ),
  );

  static UserProfileModel get currentProfile => userProfileNotifier.value;

  // --- 2. COOKED MEALS STORAGE & STREAKS ---
  static final ValueNotifier<List<CookedHistoryModel>> savedMealsNotifier =
      ValueNotifier<List<CookedHistoryModel>>([]);

  static List<CookedHistoryModel> get savedMeals => savedMealsNotifier.value;

  // --- 3. FAVORITES STORAGE (REACTIVE) ---
  static final ValueNotifier<Set<String>> favoriteRecipeIdsNotifier =
      ValueNotifier<Set<String>>({});

  static Set<String> get favoriteRecipeIds => favoriteRecipeIdsNotifier.value;

  // --- 4. FIRESTORE INITIAL SYNC ---

  /// Load user profile, saved meals, and favorites from Firestore on sign-in
  static Future<void> loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDocRef = _db.collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;

        // Restore Profile Model
        userProfileNotifier.value = UserProfileModel.fromMap(data);


        _verifyAndUpdateStreak();

        // Restore Favorited Recipe IDs
        if (data['favoriteRecipeIds'] != null) {
          final List<dynamic> favs = data['favoriteRecipeIds'];
          favoriteRecipeIdsNotifier.value = favs.cast<String>().toSet();
        }

        // Restore Cooked Meals History List
        if (data['savedMeals'] != null) {
          final List<dynamic> mealsRaw = data['savedMeals'];
          savedMealsNotifier.value = mealsRaw
              .map((m) => CookedHistoryModel.fromMap(Map<String, dynamic>.from(m)))
              .toList();
        }
      } else {
        // New user profile creation
        final newProfile = UserProfileModel(
          userId: user.uid,
          userName: user.displayName ?? user.email?.split('@').first ?? 'Chef',
          totalXp: 0,
          currentLevel: 1,
          currentXp: 0,
          maxXp: getXpForLevel(1),
          recipesTried: 0,
          totalTimesCooked: 0,
          currentStreak: 0,
        );

        // Write initial user document to Firestore
        await userDocRef.set({
          ...newProfile.toMap(),
          'favoriteRecipeIds': <String>[],
          'savedMeals': <Map<String, dynamic>>[],
        });

        userProfileNotifier.value = newProfile;
      }
    } catch (e) {
      debugPrint('Error loading user profile from Firestore: $e');
    }
  }

  /// Helper to safely update profile fields in Firestore
  static Future<void> _saveProfileToFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await _db.collection('users').doc(uid).set(
        currentProfile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving profile to Firestore: $e');
    }
  }

 static Future<void> logout() async {
    try {
      // 1. Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 2. Reset profile state to defaults
      userProfileNotifier.value = UserProfileModel(
        userId: '',
        userName: 'Chef',
        currentLevel: 1,
        currentXp: 0,
        maxXp: 1000,
        recipesTried: 0,
        totalTimesCooked: 0,
        currentStreak: 0,
      );

      // 3. Clear user-specific lists
      savedMealsNotifier.value = [];
      favoriteRecipeIdsNotifier.value = {};
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
  // --- 5. XP ENGINE & LEVEL CALCULATIONS ---

  static int getXpForLevel(int level) {
    return 1000 + ((level - 1) * 750);
  }

  static XpRewardSnapshot addXp(int amountEarned) {
    final profile = currentProfile;
    final int startXp = profile.currentXp;
    final int startLevel = profile.currentLevel;
    final int newTotalXp = profile.totalXp + amountEarned;

    final stats = _calculateLevelStats(newTotalXp);

    // 1. Update local reactive state
    userProfileNotifier.value = profile.copyWith(
      totalXp: newTotalXp,
      currentLevel: stats.level,
      currentXp: stats.xpInLevel,
      maxXp: stats.maxXpForLevel,
    );

    // 2. Auto-save profile update to Firestore
    _saveProfileToFirestore();

    return XpRewardSnapshot(
      startXp: startXp,
      startLevel: startLevel,
      xpEarned: amountEarned,
      finalXp: stats.xpInLevel,
      finalLevel: stats.level,
      didLevelUp: stats.level > startLevel,
    );
  }

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

  // --- 6. MEAL SAVING & STREAKS ---

  static Future<void> addMeal(CookedHistoryModel meal) async {
    final bool isNewRecipe = !completedRecipeIds.contains(meal.recipeId);

    // 1. Update local meals list
    savedMealsNotifier.value = [...savedMealsNotifier.value, meal];

    // 2. Update streak and meal stats locally
    _updateStreakAndMealStats(meal.recipeId, isNewRecipe: isNewRecipe);

    // 3. Save meals list and profile stats to Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set({
          ...currentProfile.toMap(),
          'savedMeals': savedMeals.map((m) => m.toMap()).toList(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error saving cooked meal to Firestore: $e');
    }
  }

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

    final uniqueRecipesCount = completedRecipeIds.length;

    userProfileNotifier.value = profile.copyWith(
      currentStreak: newStreak,
      lastCookedDate: today,
      totalTimesCooked: profile.totalTimesCooked + 1,
      recipesTried: uniqueRecipesCount,
    );
  }

  static void _verifyAndUpdateStreak() {
    final profile = currentProfile;
    if (profile.lastCookedDate == null || profile.currentStreak == 0) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCooked = DateTime(
      profile.lastCookedDate!.year,
      profile.lastCookedDate!.month,
      profile.lastCookedDate!.day,
    );

    final differenceInDays = today.difference(lastCooked).inDays;

    // If more than 1 day has passed, the streak is broken
    if (differenceInDays > 1) {
      userProfileNotifier.value = profile.copyWith(currentStreak: 0);
      _saveProfileToFirestore();
    }
  }

  
  // --- 7. RECIPE STATUS HELPERS ---

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

  // --- 8. TIER UNLOCK LOGIC ---

  static bool isTierUnlocked(TierModel tier, List<TierModel> allTiers) {
    if (tier.tierNumber <= 1) return true;

    final previousTier = allTiers.firstWhere(
      (t) => t.tierNumber == tier.tierNumber - 1,
      orElse: () => allTiers.first,
    );

    final completedInPrevious = getCompletedCount(previousTier.recipes);
    return completedInPrevious >= 2;
  }

  static TierModel getActiveTier(List<TierModel> allTiers) {
    for (int i = allTiers.length - 1; i >= 0; i--) {
      final tier = allTiers[i];
      if (isTierUnlocked(tier, allTiers)) {
        return tier;
      }
    }
    return allTiers.isNotEmpty ? allTiers.first : throw Exception("No tiers loaded");
  }

  // --- 9. FAVORITES LOGIC ---

  static Future<void> toggleFavorite(String recipeId) async {
    final updatedFavorites = Set<String>.from(favoriteRecipeIdsNotifier.value);

    if (updatedFavorites.contains(recipeId)) {
      updatedFavorites.remove(recipeId);
    } else {
      updatedFavorites.add(recipeId);
    }

    // 1. Update local reactive state immediately for snappy UI
    favoriteRecipeIdsNotifier.value = updatedFavorites;

    // 2. Auto-save to Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set({
          'favoriteRecipeIds': updatedFavorites.toList(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating favorites in Firestore: $e');
    }
  }

  static bool isRecipeFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}