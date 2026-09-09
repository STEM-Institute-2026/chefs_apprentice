class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String category; // e.g., 'cuisine', 'skill', 'milestone', 'streak'
  final String iconPath;
  final List<int> targetValues; // e.g., [1, 3, 5] for 1, 2, and 3 star tiers
  final String targetDescription;
  final String? targetModuleId; // Optional: links to a CuisineModule or SkillModule ID

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconPath,
    required this.targetValues,
    required this.targetDescription,
    this.targetModuleId,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      iconPath: map['iconPath']?.toString() ?? '',
      targetValues: (map['targetValues'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1],
      targetDescription: map['targetDescription']?.toString() ?? 'completed',
      targetModuleId: map['targetModuleId']?.toString(),
    );
  }

  // ===========================================================================
  // DYNAMIC COMPUTATION HELPERS
  // ===========================================================================

  /// Calculates the star level (0 to targetValues.length) based on a raw value.
  int getStarLevel(int currentValue) {
    int stars = 0;
    for (int i = 0; i < targetValues.length; i++) {
      if (currentValue >= targetValues[i]) {
        stars = i + 1;
      } else {
        break;
      }
    }
    return stars;
  }

  /// Returns true if the user has reached at least 1 star.
  bool isUnlocked(int currentValue) {
    return getStarLevel(currentValue) > 0;
  }

  /// Returns true if the user has reached the maximum available star level.
  bool isMaxed(int currentValue) {
    return getStarLevel(currentValue) == targetValues.length;
  }

  /// Calculates progress toward the next star tier as a percentage (0.0 to 1.0).
  double getProgressPercentage(int currentValue) {
    if (targetValues.isEmpty) return 0.0;

    if (isMaxed(currentValue)) return 1.0;

    final currentStars = getStarLevel(currentValue);
    final nextTarget = targetValues[currentStars];
    final previousTarget =
        currentStars == 0 ? 0 : targetValues[currentStars - 1];

    final progressInTier = currentValue - previousTarget;
    final totalTierRequirement = nextTarget - previousTarget;

    if (totalTierRequirement <= 0) return 1.0;

    return (progressInTier / totalTierRequirement).clamp(0.0, 1.0);
  }

  /// Gets the next target count the user is currently working toward.
  int getNextTargetValue(int currentValue) {
    final currentStars = getStarLevel(currentValue);
    if (currentStars >= targetValues.length) {
      return targetValues.last;
    }
    return targetValues[currentStars];
  }
}