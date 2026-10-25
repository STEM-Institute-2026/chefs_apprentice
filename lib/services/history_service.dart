
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/badge_evaluator_service.dart';

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
      avatarKey: 'person',
      equippedTitle: 'Novice Cook',
    ),
  );

  static UserProfileModel get currentProfile => userProfileNotifier.value;

  // --- 2. COOKING PREFERENCES STORAGE (REACTIVE) ---
  // Only notifies listeners when cooking preferences are loaded or saved.
  // Other profile changes will not notify this separate notifier.
  static final ValueNotifier<CookingPreferencesModel?>
      cookingPreferencesNotifier =
      ValueNotifier<CookingPreferencesModel?>(null);

  // --- 3. COOKED MEALS STORAGE & STREAKS ---
  static final ValueNotifier<List<CookedHistoryModel>> savedMealsNotifier =
      ValueNotifier<List<CookedHistoryModel>>([]);

  static List<CookedHistoryModel> get savedMeals => savedMealsNotifier.value;

  // --- 4. FAVORITES STORAGE (REACTIVE) ---
  static final ValueNotifier<Set<String>> favoriteRecipeIdsNotifier =
      ValueNotifier<Set<String>>({});

  static Set<String> get favoriteRecipeIds => favoriteRecipeIdsNotifier.value;

  // --- 5. FIRESTORE INITIAL SYNC ---

  /// Load user profile, saved meals, and favorites from Firestore on sign-in.
  static Future<void> loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDocRef = _db.collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;

        // Restore profile model.
        final loadedProfile = UserProfileModel.fromMap(data);
        userProfileNotifier.value = loadedProfile;

        // Restore cooking preferences separately.
        cookingPreferencesNotifier.value =
            loadedProfile.cookingPreferences;

        _verifyAndUpdateStreak();

        // Restore favorited recipe IDs.
        if (data['favoriteRecipeIds'] != null) {
          final List<dynamic> favs = data['favoriteRecipeIds'];
          favoriteRecipeIdsNotifier.value = favs.cast<String>().toSet();
        }

        // Restore cooked meals history list.
        if (data['savedMeals'] != null) {
          final List<dynamic> mealsRaw = data['savedMeals'];
          savedMealsNotifier.value = mealsRaw
              .map(
                (m) => CookedHistoryModel.fromMap(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList();
        }
      } else {
        // New user profile creation.
        final newProfile = UserProfileModel(
          userId: user.uid,
          userName:
              user.displayName ?? user.email?.split('@').first ?? 'Chef',
          totalXp: 0,
          currentLevel: 1,
          currentXp: 0,
          maxXp: getXpForLevel(1),
          recipesTried: 0,
          totalTimesCooked: 0,
          currentStreak: 0,
          avatarKey: 'person',
          equippedTitle: 'Novice Cook',
        );

        // Write initial user document to Firestore.
        await userDocRef.set({
          ...newProfile.toMap(),
          'favoriteRecipeIds': <String>[],
          'savedMeals': <Map<String, dynamic>>[],
        });

        userProfileNotifier.value = newProfile;
        cookingPreferencesNotifier.value =
            newProfile.cookingPreferences;
      }
    } catch (e) {
      debugPrint('Error loading user profile from Firestore: $e');
    }
  }

  /// Helper to safely update profile fields in Firestore.
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

  /// Update individual user profile fields.
  static Future<void> updateUserProfile({
    String? userName,
    String? avatarKey,
    int? avatarColorHex,
  }) async {
    final profile = currentProfile;

    userProfileNotifier.value = profile.copyWith(
      userName: userName ?? profile.userName,
      avatarKey: avatarKey ?? profile.avatarKey,
      avatarColorHex: avatarColorHex ?? profile.avatarColorHex,
    );

    await _saveProfileToFirestore();
  }

  /// Save onboarding preferences and the user's chosen username.
  /// Other profile fields are preserved through copyWith().
  static Future<void> saveCookingPreferences(
    CookingPreferencesModel preferences, {
    required String userName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to save your profile.');
    }

    final trimmedUserName = userName.trim();
    if (trimmedUserName.length < 5 || trimmedUserName.length > 12) {
      throw ArgumentError('Username must be between 5 and 12 characters.');
    }

    final updatedProfile = currentProfile.copyWith(
      userId: user.uid,
      userName: trimmedUserName,
      cookingPreferences: preferences,
      onboardingCompleted: true,
    );

    await _db.collection('users').doc(user.uid).set(
      updatedProfile.toMap(),
      SetOptions(merge: true),
    );

    // Update reactive app state only after Firestore save succeeds.
    userProfileNotifier.value = updatedProfile;

    // Notify only listeners that depend on cooking preferences.
    cookingPreferencesNotifier.value = preferences;
  }

  /// Convenience helper to update the selected avatar icon key.
  static Future<void> updateAvatar(String avatarKey) async {
    await updateUserProfile(avatarKey: avatarKey);
  }

  static Future<void> logout() async {
    try {
      // 1. Sign out from Firebase Auth.
      await FirebaseAuth.instance.signOut();

      // 2. Reset profile state to defaults.
      userProfileNotifier.value = UserProfileModel(
        userId: '',
        userName: 'Chef',
        currentLevel: 1,
        currentXp: 0,
        maxXp: 1000,
        recipesTried: 0,
        totalTimesCooked: 0,
        currentStreak: 0,
        avatarKey: 'person',
        equippedTitle: 'Novice Cook',
      );

      // 3. Clear the separate cooking preferences notifier.
      cookingPreferencesNotifier.value = null;

      // 4. Clear user-specific lists.
      savedMealsNotifier.value = [];
      favoriteRecipeIdsNotifier.value = {};
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // --- 6. TITLES MANAGEMENT ---

  /// Equips a title for the user profile and syncs with Firestore.
  static Future<void> updateEquippedTitle(String newTitle) async {
    final profile = currentProfile;

    userProfileNotifier.value = profile.copyWith(
      equippedTitle: newTitle,
    );

    await _saveProfileToFirestore();
  }

  // --- 7. XP ENGINE & LEVEL CALCULATIONS ---

  static int getXpForLevel(int level) {
    return 1000 + ((level - 1) * 750);
  }

  static XpRewardSnapshot addXp(int amountEarned) {
    final profile = currentProfile;
    final int startXp = profile.currentXp;
    final int startLevel = profile.currentLevel;
    final int newTotalXp = profile.totalXp + amountEarned;

    final stats = _calculateLevelStats(newTotalXp);

    // 1. Update local reactive state.
    userProfileNotifier.value = profile.copyWith(
      totalXp: newTotalXp,
      currentLevel: stats.level,
      currentXp: stats.xpInLevel,
      maxXp: stats.maxXpForLevel,
    );

    // 2. Auto-save profile update to Firestore.
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

  static ({
    int level,
    int xpInLevel,
    int maxXpForLevel,
  }) _calculateLevelStats(int totalXp) {
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

  // --- 8. MEAL SAVING & STREAKS ---

  static Future<List<BadgeUnlockResult>> addMeal({
    required CookedHistoryModel meal,
    required List<BadgeModel> badges,
    required List<CuisineModuleModel> cuisineModules,
    required List<SkillModuleModel> skillModules,
  }) async {
    // 1. Snapshot BEFORE state.
    final UserProfileModel oldProfile = currentProfile;
    final Set<String> oldCompletedRecipeIds =
        Set<String>.from(completedRecipeIds);

    final bool isNewRecipe =
        !oldCompletedRecipeIds.contains(meal.recipeId);

    // 2. Update local state.
    savedMealsNotifier.value = [...savedMealsNotifier.value, meal];
    _updateStreakAndMealStats(meal.recipeId, isNewRecipe: isNewRecipe);

    // 3. Snapshot AFTER state.
    final UserProfileModel newProfile = currentProfile;
    final Set<String> newCompletedRecipeIds = completedRecipeIds;

    // 4. Run evaluation engine.
    final List<BadgeUnlockResult> newlyUnlockedBadges =
        BadgeEvaluatorService.evaluateUnlocks(
      badges: badges,
      oldProfile: oldProfile,
      newProfile: newProfile,
      oldCompletedRecipeIds: oldCompletedRecipeIds,
      newCompletedRecipeIds: newCompletedRecipeIds,
      cuisineModules: cuisineModules,
      skillModules: skillModules,
    );

    // 5. Sync state to Firestore in the background.
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

    // 6. Return evaluation results.
    return newlyUnlockedBadges;
  }

  static void _updateStreakAndMealStats(
    String recipeId, {
    required bool isNewRecipe,
  }) {
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

    // If more than 1 day has passed, the streak is broken.
    if (differenceInDays > 1) {
      userProfileNotifier.value = profile.copyWith(currentStreak: 0);
      _saveProfileToFirestore();
    }
  }

  // --- 9. RECIPE STATUS HELPERS ---

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

  // --- 10. FAVORITES LOGIC ---

  static Future<void> toggleFavorite(String recipeId) async {
    final updatedFavorites = Set<String>.from(favoriteRecipeIdsNotifier.value);

    if (updatedFavorites.contains(recipeId)) {
      updatedFavorites.remove(recipeId);
    } else {
      updatedFavorites.add(recipeId);
    }

    // 1. Update local reactive state immediately for a responsive UI.
    favoriteRecipeIdsNotifier.value = updatedFavorites;

    // 2. Auto-save to Firestore.
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
