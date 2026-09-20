import '../models/models.dart';
import './cooked_history_screen.dart';
import 'package:flutter/material.dart';
import '../constants/app_transitions.dart';
import './widgets/header_and_app_bar.dart';
import '../services/history_service.dart';
import 'badges_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Default list of titles without IDs
  static const List<ProfileTitleModel> _allTitles = [
    ProfileTitleModel(name: 'Novice Cook', requiredLevel: 1),
    ProfileTitleModel(name: 'Line Cook', requiredLevel: 3),
    ProfileTitleModel(name: 'Sous Chef', requiredLevel: 6),
    ProfileTitleModel(name: 'Head Chef', requiredLevel: 10),
    ProfileTitleModel(name: 'Master Connoisseur', requiredLevel: 15),
  ];


  void _showTitleSelectionSheet(BuildContext context, UserProfileModel profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handlebar indicator
              Center(
                child: Container(
                  width: 50,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Select Chef Title',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.oliveSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _allTitles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final title = _allTitles[index];
                    final isUnlocked = title.isUnlocked(profile.currentLevel);
                    final isSelected = (profile.equippedTitle) == title.name;

                    // Active item styled as a dark green pill container
                    if (isSelected) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.oliveSecondary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.creamBackground,
                            child: Icon(
                              Icons.stars,
                              color: AppColors.terracottaAccent,
                            ),
                          ),
                          title: Text(
                            title.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.creamBackground,
                            ),
                          ),
                          subtitle: const Text(
                            'Currently Active',
                            style: TextStyle(
                              color: AppColors.creamBackground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.check_circle,
                            color: AppColors.creamBackground,
                          ),
                        ),
                      );
                    }

                    // Default unselected titles list tile
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Icon(
                        isUnlocked ? Icons.military_tech : Icons.lock_outline_rounded,
                        color: isUnlocked ? AppColors.terracottaAccent : Colors.grey,
                      ),
                      title: Text(
                        title.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                      subtitle: isUnlocked
                          ? Text(
                              'Unlocked',
                              style: TextStyle(color: Colors.grey.shade600),
                            )
                          : Text(
                              'Locked: Reach Level ${title.requiredLevel}',
                              style: TextStyle(color: AppColors.terracottaAccent.withValues(alpha: 0.8)),
                            ),
                      onTap: () async {
                        if (isUnlocked) {
                          await HistoryService.updateEquippedTitle(title.name);
                          if (context.mounted) Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reach Level ${title.requiredLevel} to unlock "${title.name}"'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarSelectionSheet(BuildContext context) {
  final Map<String, IconData> availableAvatars = IconMapper.icons;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Avatar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.oliveSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: availableAvatars.entries.map((entry) {
                  final String key = entry.key;
                  final IconData iconData = entry.value;

                  return GestureDetector(
                    onTap: () async {
                      await HistoryService.updateAvatar(key);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.terracottaAccent.withValues(alpha: 0.1),
                      child: Icon(
                        iconData,
                        color: AppColors.terracottaAccent,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfileModel>(
      valueListenable: HistoryService.userProfileNotifier,
      builder: (context, currentProfile, child) {
        final activeProfile = currentProfile;
        final double progressFraction =
            (activeProfile.currentXp / activeProfile.maxXp).clamp(0.0, 1.0);

        // Resolve the avatar icon string key using IconMapper
        final IconData currentIcon = IconMapper.getIcon(activeProfile.avatarKey);

        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          appBar: CustomAppBar(
            title: 'Profile',
            leadingWidth: 110.0,
            leading: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BadgesScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaAccent.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.creamBackground.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: AppColors.creamBackground,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Badges',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.creamBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: const [],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.oliveSecondary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Interactive Avatar with Edit Overlay
                      GestureDetector(
                        onTap: () => _showAvatarSelectionSheet(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: activeProfile.avatarColorHex != null
                                  ? Color(activeProfile.avatarColorHex!)
                                  : AppColors.creamBackground,
                              child: Icon(
                                currentIcon,
                                size: 40,
                                color: AppColors.terracottaAccent,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.terracottaAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: AppColors.creamBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, Chef ${activeProfile.userName}!",
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.creamBackground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Title Selector Button
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showTitleSelectionSheet(context, activeProfile),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.creamBackground.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.creamBackground.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.military_tech_rounded,
                                      size: 16,
                                      color: AppColors.creamBackground,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Title: ${activeProfile.equippedTitle}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.creamBackground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      size: 18,
                                      color: AppColors.creamBackground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Level & XP Progress
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${activeProfile.currentLevel}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${activeProfile.currentXp} / ${activeProfile.maxXp} XP',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.oliveSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 12,
                          backgroundColor: Colors.amber.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.terracottaAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Dynamic Stats Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 28,
                              color: AppColors.terracottaAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${activeProfile.recipesTried}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Recipes Tried',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.oliveSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 48,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.restaurant_rounded,
                              size: 28,
                              color: AppColors.terracottaAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${activeProfile.totalTimesCooked}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Times Cooked',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.oliveSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Streak Card Widget
                StreakCard(profile: activeProfile),
                const SizedBox(height: 16),

                // 5. Cooked History Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oliveSecondary,
                    foregroundColor: AppColors.creamBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      StandardDetailRoute(
                        page: const CookedHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text(
                    'Cooked History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 6. Sign Out Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracottaAccent,
                    foregroundColor: AppColors.creamBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: AppColors.creamBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.terracottaAccent.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.terracottaAccent,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.oliveSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Are you sure you want to sign out of Chef\'s Apprentice?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.oliveSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.terracottaAccent,
                                        foregroundColor: AppColors.creamBackground,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (shouldLogout == true) {
                      await HistoryService.logout();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StreakCard extends StatelessWidget {
  final UserProfileModel profile;

  const StreakCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyStatus = _calculateWeeklyStatus(HistoryService.savedMeals);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.terracottaAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.currentStreak} Day Streak!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.oliveSecondary,
                    ),
                  ),
                ],
              ),
              const Text(
                'Weekly Goal',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.oliveSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final isCooked = weeklyStatus[index];

              return Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isCooked
                        ? AppColors.oliveSecondary
                        : AppColors.terracottaAccent.withValues(alpha: 0.5),
                    child: Icon(
                      isCooked
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: AppColors.creamBackground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    daysOfWeek[index],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.oliveSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<bool> _calculateWeeklyStatus(List<CookedHistoryModel>? meals) {
    if (meals == null || meals.isEmpty) {
      return List<bool>.filled(7, false);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final List<bool> weekStatus = List<bool>.filled(7, false);

    for (final meal in meals) {
      final mealDate = DateTime(
        meal.dateCooked.year,
        meal.dateCooked.month,
        meal.dateCooked.day,
      );

      final difference = mealDate.difference(startOfWeek).inDays;
      if (difference >= 0 && difference < 7) {
        weekStatus[difference] = true;
      }
    }

    return weekStatus;
  }
}