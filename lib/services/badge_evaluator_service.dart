import '../models/models.dart';

/// Data payload passed to the UI when a badge levels up.
class BadgeUnlockResult {
  final BadgeModel badge;
  final int oldStarLevel;
  final int newStarLevel;

  const BadgeUnlockResult({
    required this.badge,
    required this.oldStarLevel,
    required this.newStarLevel,
  });
}

/// Stateless engine that converts user stats into badge progress numbers
/// and detects star level increases.
class BadgeEvaluatorService {
  /// Resolves the current raw numerical progress for a given badge.
  static int getCurrentValueForBadge({
    required BadgeModel badge,
    required UserProfileModel profile,
    required Set<String> completedRecipeIds,
    required List<CuisineModuleModel> cuisineModules,
    required List<SkillModuleModel> skillModules,
  }) {
    switch (badge.category) {
      case 'cuisine':
        if (badge.targetModuleId == null) return 0;
        final module = cuisineModules.firstWhere(
          (m) => m.id == badge.targetModuleId,
          orElse: () => CuisineModuleModel(
            id: '',
            title: '',
            description: '',
            coverImageUrl: '',
            flavorProfileOverview: '',
            essentialPantry: [],
            keyTechniques: [],
            tier1Recipes: [],
            tier2Recipes: [],
            tier3Recipes: [],
          ),
        );
        return module.id.isNotEmpty
            ? module.getCompletedCount(completedRecipeIds)
            : 0;

      case 'skill':
        if (badge.targetModuleId == null) return 0;
        final module = skillModules.firstWhere(
          (m) => m.id == badge.targetModuleId,
          orElse: () => SkillModuleModel(
            id: '',
            title: '',
            description: '',
            coverImageUrl: '',
            difficultyLevel: '',
            skills: [],
            tier1Recipes: [],
            tier2Recipes: [],
            tier3Recipes: [],
          ),
        );
        return module.id.isNotEmpty
            ? module.getCompletedCount(completedRecipeIds)
            : 0;

      case 'streak':
        return profile.currentStreak;

      case 'milestone':
      default:
        return profile.totalTimesCooked;
    }
  }

  /// Compares old and new profile states to return any badges that increased star levels.
  static List<BadgeUnlockResult> evaluateUnlocks({
    required List<BadgeModel> badges,
    required UserProfileModel oldProfile,
    required UserProfileModel newProfile,
    required Set<String> oldCompletedRecipeIds,
    required Set<String> newCompletedRecipeIds,
    required List<CuisineModuleModel> cuisineModules,
    required List<SkillModuleModel> skillModules,
  }) {
    final List<BadgeUnlockResult> newlyUnlocked = [];

    for (final badge in badges) {
      // Get raw scores before and after the action
      final oldValue = getCurrentValueForBadge(
        badge: badge,
        profile: oldProfile,
        completedRecipeIds: oldCompletedRecipeIds,
        cuisineModules: cuisineModules,
        skillModules: skillModules,
      );

      final newValue = getCurrentValueForBadge(
        badge: badge,
        profile: newProfile,
        completedRecipeIds: newCompletedRecipeIds,
        cuisineModules: cuisineModules,
        skillModules: skillModules,
      );

      // Convert scores to star tiers
      final oldStarLevel = badge.getStarLevel(oldValue);
      final newStarLevel = badge.getStarLevel(newValue);

      // Only add to the result list if star level strictly increased
      if (newStarLevel > oldStarLevel) {
        newlyUnlocked.add(
          BadgeUnlockResult(
            badge: badge,
            oldStarLevel: oldStarLevel,
            newStarLevel: newStarLevel,
          ),
        );
      }
    }

    return newlyUnlocked;
  }
}