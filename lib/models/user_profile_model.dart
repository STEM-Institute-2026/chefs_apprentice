class UserProfileModel {
  final String userId;
  final String userName;
  final int currentLevel;
  final int currentXp;
  final int maxXp;
  final int recipesTried;
  final int totalTimesCooked;
  final String? avatarUrl;
  final int? avatarColorHex;
  final List<String> favoriteRecipeIds;
  
  // Add these two new streak fields:
  final int currentStreak;
  final DateTime? lastCookedDate;

  UserProfileModel({
    required this.userId,
    required this.userName,
    required this.currentLevel,
    required this.currentXp,
    required this.maxXp,
    required this.recipesTried,
    required this.totalTimesCooked,
    this.avatarUrl,
    this.avatarColorHex,
    this.currentStreak = 0,
    this.lastCookedDate,
    required this.favoriteRecipeIds,
  });

  // Include copyWith so you can easily update the streak state
  UserProfileModel copyWith({
    String? userId,
    String? userName,
    int? currentLevel,
    int? currentXp,
    int? maxXp,
    int? recipesTried,
    int? totalTimesCooked,
    String? avatarUrl,
    int? avatarColorHex,
    int? currentStreak,
    DateTime? lastCookedDate,
    List<String>? favoriteRecipeIds,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      maxXp: maxXp ?? this.maxXp,
      recipesTried: recipesTried ?? this.recipesTried,
      totalTimesCooked: totalTimesCooked ?? this.totalTimesCooked,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCookedDate: lastCookedDate ?? this.lastCookedDate,
      favoriteRecipeIds: favoriteRecipeIds ?? this.favoriteRecipeIds,
    );
  }
}