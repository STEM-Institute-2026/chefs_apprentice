import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/badge_evaluator_service.dart';
import '../services/data_loader_service.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import 'widgets/badge_detail_dialog.dart'; // Make sure this path matches your dialog file

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  bool _isLoading = true;
  AppData? _appData;

  static const Color _warmBeigeContainer = Color(0xFFEFE6D5);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final appData = await DataLoaderService.loadInitialData();
    if (!mounted) return;
    setState(() {
      _appData = appData;
      _isLoading = false;
    });
  }

  Map<String, int> _calculateBadgeLevels(
    UserProfileModel currentProfile,
    Set<String> completedRecipeIds,
  ) {
    if (_appData == null) return {};

    final Map<String, int> levels = {};
    for (final badge in _appData!.badges) {
      final rawValue = BadgeEvaluatorService.getCurrentValueForBadge(
        badge: badge,
        profile: currentProfile,
        completedRecipeIds: completedRecipeIds,
        cuisineModules: _appData!.cuisineModules,
        skillModules: _appData!.skillModules,
      );

      levels[badge.id] = badge.getStarLevel(rawValue);
    }
    return levels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(
        title: 'Badge Collection',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading || _appData == null
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: Listenable.merge([
                HistoryService.userProfileNotifier,
                HistoryService.savedMealsNotifier,
              ]),
              builder: (context, _) {
                final currentProfile = HistoryService.currentProfile;
                final completedRecipeIds = HistoryService.completedRecipeIds;

                final badgeStarLevels = _calculateBadgeLevels(
                  currentProfile,
                  completedRecipeIds,
                );

                final generalBadges = _appData!.badges
                    .where((b) =>
                        b.category == 'milestone' || b.category == 'streak' || b.category == 'level')
                    .toList();
                final skillBadges = _appData!.badges
                    .where((b) => b.category == 'skill')
                    .toList();
                final cuisineBadges = _appData!.badges
                    .where((b) => b.category == 'cuisine')
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.oliveSecondary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.terracottaAccent,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.creamBackground,
                                ),
                                child: const Icon(
                                  Icons.military_tech,
                                  color: AppColors.terracottaAccent,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Earn progress and flex your skills through badges!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.creamBackground,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 1. General Badges
                      if (generalBadges.isNotEmpty) ...[
                        const HeaderWidget(
                          headerText: 'General Achievements',
                          icon: Icons.stars,
                        ),
                        const SizedBox(height: 7),
                        _buildSectionContainer(
                          badges: generalBadges,
                          badgeStarLevels: badgeStarLevels,
                          currentProfile: currentProfile,
                          completedRecipeIds: completedRecipeIds,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 2. Skill Badges
                      if (skillBadges.isNotEmpty) ...[
                        const HeaderWidget(
                          headerText: 'Skill Mastery',
                          icon: Icons.restaurant_menu,
                        ),
                        const SizedBox(height: 7),
                        _buildSectionContainer(
                          badges: skillBadges,
                          badgeStarLevels: badgeStarLevels,
                          currentProfile: currentProfile,
                          completedRecipeIds: completedRecipeIds,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 3. Cuisine Badges
                      if (cuisineBadges.isNotEmpty) ...[
                        const HeaderWidget(
                          headerText: 'Cuisine Mastery',
                          icon: Icons.public,
                        ),
                        const SizedBox(height: 7),
                        _buildSectionContainer(
                          badges: cuisineBadges,
                          badgeStarLevels: badgeStarLevels,
                          currentProfile: currentProfile,
                          completedRecipeIds: completedRecipeIds,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionContainer({
    required List<BadgeModel> badges,
    required Map<String, int> badgeStarLevels,
    required UserProfileModel currentProfile,
    required Set<String> completedRecipeIds,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _warmBeigeContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.oliveSecondary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: _buildBadgeGrid(
        badges,
        badgeStarLevels,
        currentProfile,
        completedRecipeIds,
      ),
    );
  }

  Widget _buildBadgeGrid(
    List<BadgeModel> badges,
    Map<String, int> badgeStarLevels,
    UserProfileModel currentProfile,
    Set<String> completedRecipeIds,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.72,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final currentStarLevel = badgeStarLevels[badge.id] ?? 0;

        // Calculate the raw current value (e.g. 2 recipes completed out of 5)
        final rawValue = BadgeEvaluatorService.getCurrentValueForBadge(
          badge: badge,
          profile: currentProfile,
          completedRecipeIds: completedRecipeIds,
          cuisineModules: _appData?.cuisineModules ?? [],
          skillModules: _appData?.skillModules ?? [],
        );

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            BadgeDetailsDialog.show(
              context: context,
              badge: badge,
              currentValue: rawValue,
            );
          },
          child: _BadgeCardTile(
            badge: badge,
            currentStarLevel: currentStarLevel,
          ),
        );
      },
    );
  }
}

class _BadgeCardTile extends StatelessWidget {
  final BadgeModel badge;
  final int currentStarLevel;

  const _BadgeCardTile({
    required this.badge,
    required this.currentStarLevel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = currentStarLevel > 0;
    final int maxStars = badge.targetValues.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.terracottaAccent
                  : AppColors.terracottaAccent.withValues(alpha: 0.35),
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.creamBackground,
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: isUnlocked
                      ? const ColorFilter.mode(
                          Colors.transparent, BlendMode.dst)
                      : const ColorFilter.mode(
                          Colors.grey, BlendMode.saturation),
                  child: Image.asset(
                    badge.iconPath,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.workspace_premium,
                      size: 26,
                      color: isUnlocked
                          ? AppColors.terracottaAccent
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(maxStars, (starIndex) {
              final bool starEarned = starIndex < currentStarLevel;
              return Icon(
                starEarned ? Icons.star : Icons.star_border,
                size: 16,
                color: starEarned
                    ? AppColors.terracottaAccent
                    : Colors.grey.shade400,
              );
            }),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isUnlocked ? FontWeight.bold : FontWeight.w500,
                  color: isUnlocked
                      ? AppColors.oliveSecondary
                      : Colors.grey.shade600,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}