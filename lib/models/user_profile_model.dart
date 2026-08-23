class UserProfileModel {
  final String userId;
  final String userName;
  final int totalXp; // Added totalXp as source of truth
  final int currentLevel;
  final int currentXp;
  final int maxXp;
  final int recipesTried;
  final int totalTimesCooked;
  final String? avatarUrl;
  final int? avatarColorHex;
  
  // Streak fields
  final int currentStreak;
  final DateTime? lastCookedDate;

  UserProfileModel({
    required this.userId,
    required this.userName,
    this.totalXp = 0, // Default to 0 XP for new profiles
    required this.currentLevel,
    required this.currentXp,
    required this.maxXp,
    required this.recipesTried,
    required this.totalTimesCooked,
    this.avatarUrl,
    this.avatarColorHex,
    this.currentStreak = 0,
    this.lastCookedDate,
  });

  /// Factory constructor to parse JSON Map into UserProfileModel
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      totalXp: map['totalXp'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      currentXp: map['currentXp'] ?? 0,
      maxXp: map['maxXp'] ?? 100,
      recipesTried: map['recipesTried'] ?? 0,
      totalTimesCooked: map['totalTimesCooked'] ?? 0,
      avatarUrl: map['avatarUrl'] as String?,
      avatarColorHex: map['avatarColorHex'] as int?,
      currentStreak: map['currentStreak'] ?? 0,
      lastCookedDate: map['lastCookedDate'] != null
          ? DateTime.parse(map['lastCookedDate'] as String)
          : null,
    );
  }

  /// Converts UserProfileModel into a Map for local storage or Firestore
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
      'avatarUrl': avatarUrl,
      'avatarColorHex': avatarColorHex,
      'currentStreak': currentStreak,
      'lastCookedDate': lastCookedDate?.toIso8601String(),
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
    String? avatarUrl,
    int? avatarColorHex,
    int? currentStreak,
    DateTime? lastCookedDate,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCookedDate: lastCookedDate ?? this.lastCookedDate,
    );
  }
}