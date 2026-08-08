class UserProfileModel {
  final String userId;
  final String userName;
  final String avatarUrl;
  final int currentTier;
  final double tierProgress;
  final int currentStreak;
  final List<String> favoriteRecipeIds;

  UserProfileModel({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.currentTier,
    required this.tierProgress,
    required this.currentStreak,
    required this.favoriteRecipeIds,
  });
}

