import '../models/models.dart';
import './cooked_history_screen.dart';
import 'package:flutter/material.dart';
import '../constants/app_transitions.dart';
import './widgets/header_and_app_bar.dart';
import '../services/history_service.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final double progressFraction =
        (profile.currentXp / profile.maxXp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(title: "Profile"),
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
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: profile.avatarColorHex != null 
                        ? Color(profile.avatarColorHex!) 
                        : AppColors.creamBackground,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.terracottaAccent,
                          )
                        : null,
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Text(
                      "Hello, Chef ${profile.userName}!",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.creamBackground,
                      ),
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
                        'Level ${profile.currentLevel}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${profile.currentXp} / ${profile.maxXp} XP',
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

            // 3. Dynamic Stats Bar connected to HistoryService
            ValueListenableBuilder<UserProfileModel>(
              valueListenable: HistoryService.userProfileNotifier,
              builder: (context, _, child) {
                final meals = HistoryService.savedMeals;
                final recipesTried = meals.map((m) => m.recipeId).toSet().length;
                final totalTimesCooked = meals.length;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 12.0),
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
                      // Unique Recipes Tried
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
                              '$recipesTried',
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

                      // Divider Line
                      Container(
                        height: 48,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),

                      // Total Times Cooked
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
                              '$totalTimesCooked',
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
                );
              },
            ),
            const SizedBox(height: 16),

            // Streak Card
            const StreakCard(),
            const SizedBox(height: 16),

            // 4. Cooked History Screen Button
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
          ],
        ),
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    // SINGLE LISTENER: Listens to profile updates, which also trigger on meal updates
    return ValueListenableBuilder<UserProfileModel>(
      valueListenable: HistoryService.userProfileNotifier,
      builder: (context, profile, child) {
        // Grab the latest meals list directly from HistoryService
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
              // HEADER ROW: STREAK COUNT & GOAL
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

              // 7-DAY CALENDAR ROW
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
                          color: AppColors.creamBackground
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
      },
    );
  }

  // HELPER METHOD TO CALCULATE WEEKLY STATUS
  // HELPER METHOD TO CALCULATE WEEKLY STATUS
  List<bool> _calculateWeeklyStatus(List<CookedHistoryModel>? meals) {
    // 1. Guard against null or empty meals list
    if (meals == null || meals.isEmpty) {
      return List<bool>.filled(7, false);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final List<bool> weekStatus = List<bool>.filled(7, false);

    for (final meal in meals) {
      // 2. Normalize the meal date to midnight (dateCooked is guaranteed non-nullable)
      final mealDate = DateTime(
        meal.dateCooked.year,
        meal.dateCooked.month,
        meal.dateCooked.day,
      );

      // 3. Calculate day difference relative to Monday
      final difference = mealDate.difference(startOfWeek).inDays;
      if (difference >= 0 && difference < 7) {
        weekStatus[difference] = true;
      }
    }

    return weekStatus;
  }
}

