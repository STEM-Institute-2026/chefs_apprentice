import 'profile_title_model.dart';
import 'package:flutter/material.dart';
import 'cooking_preferences_model.dart';

class UserProfileModel {
  final String userId;
  final String userName;
  final int totalXp;
  final int currentLevel;
  final int currentXp;
  final int maxXp;
  final int recipesTried;
  final int totalTimesCooked;
  final String avatarKey;
  final int? avatarColorHex;
  final String equippedTitle;

  final CookingPreferencesModel cookingPreferences;
  // Onboarding
  final bool onboardingCompleted;

  // Streak fields
  final int currentStreak;
  final DateTime? lastCookedDate;

  UserProfileModel({
    required this.userId,
    required this.userName,
    this.totalXp = 0,
    required this.currentLevel,
    required this.currentXp,
    required this.maxXp,
    required this.recipesTried,
    required this.totalTimesCooked,
    this.avatarKey = 'person',
    this.avatarColorHex,
    this.currentStreak = 0,
    this.lastCookedDate,
    this.equippedTitle = 'Novice Cook',
    this.onboardingCompleted = false,
    this.cookingPreferences = const CookingPreferencesModel(),
  });

  /// Dynamically compute unlocked title strings based on level.
  List<String> get unlockedTitles {
    return getUnlockedTitles(currentLevel).map((t) => t.name).toList();
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Chef',
      totalXp: map['totalXp'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      currentXp: map['currentXp'] ?? 0,
      maxXp: map['maxXp'] ?? 100,
      recipesTried: map['recipesTried'] ?? 0,
      totalTimesCooked: map['totalTimesCooked'] ?? 0,
      avatarKey: (map['avatarKey'] as String?) ?? 'person',
      avatarColorHex: map['avatarColorHex'] as int?,
      currentStreak: map['currentStreak'] ?? 0,
      lastCookedDate: map['lastCookedDate'] != null
          ? DateTime.parse(map['lastCookedDate'] as String)
          : null,
      equippedTitle: map['equippedTitle'] as String? ?? 'Novice Cook',
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      cookingPreferences: map['cookingPreferences'] is Map
        ? CookingPreferencesModel.fromMap(
            Map<String, dynamic>.from(
              map['cookingPreferences'] as Map,
            ),
          )
        : const CookingPreferencesModel(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'currentXp': currentXp,
      'maxXp': maxXp,
      'recipesTried': recipesTried,
      'totalTimesCooked': totalTimesCooked,
      'avatarKey': avatarKey,
      'avatarColorHex': avatarColorHex,
      'currentStreak': currentStreak,
      'lastCookedDate': lastCookedDate?.toIso8601String(),
      'equippedTitle': equippedTitle,
      'onboardingCompleted': onboardingCompleted,
      'cookingPreferences': cookingPreferences.toMap(),
    };
  }

  UserProfileModel copyWith({
    String? userId,
    String? userName,
    int? totalXp,
    int? currentLevel,
    int? currentXp,
    int? maxXp,
    int? recipesTried,
    int? totalTimesCooked,
    String? avatarKey,
    int? avatarColorHex,
    int? currentStreak,
    DateTime? lastCookedDate,
    String? equippedTitle,
    bool? onboardingCompleted,
    CookingPreferencesModel? cookingPreferences,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      maxXp: maxXp ?? this.maxXp,
      recipesTried: recipesTried ?? this.recipesTried,
      totalTimesCooked: totalTimesCooked ?? this.totalTimesCooked,
      avatarKey: avatarKey ?? this.avatarKey,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCookedDate: lastCookedDate ?? this.lastCookedDate,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      onboardingCompleted:
          onboardingCompleted ?? this.onboardingCompleted,
      cookingPreferences: cookingPreferences ?? this.cookingPreferences,
    );
  }
}

class IconMapper {
  static const Map<String, IconData> icons = {
    'person': Icons.person,
    'restaurant': Icons.restaurant,
    'soup_kitchen': Icons.soup_kitchen,
    'local_pizza': Icons.local_pizza,
    'cake': Icons.cake,
    'fire': Icons.local_fire_department,
    'emoji_events': Icons.emoji_events,
    'set_meal': Icons.set_meal,
    'bakery_dining': Icons.bakery_dining,
  };

  static IconData getIcon(String? key) {
    if (key == null) return Icons.person;
    return icons[key] ?? Icons.person;
  }
}
