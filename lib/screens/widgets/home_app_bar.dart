import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/constants/app_colors.dart';
import '../../models/user_profile_model.dart';
import '../../services/history_service.dart';

class MainHomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainHomeScreenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.oliveSecondary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16, // Flush left padding

      // 1. LEFT SIDE: Larger App Logo + Title
      title: Row(
        children: [
          // Expanded Logo Image Container
          Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.creamBackground,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/app_logo_cropped.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.restaurant,
                  color: AppColors.oliveSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Prominent App Title
          const Text(
            "Chef's Apprentice",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.creamBackground,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),

      // 2. RIGHT SIDE: Proportional Level Badge + Profile Icon
      actions: [
        ValueListenableBuilder<UserProfileModel>(
          valueListenable: HistoryService.userProfileNotifier,
          builder: (context, userProfile, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic Level & XP Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.terracottaAccent.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.creamBackground.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'Lvl ${userProfile.currentLevel} • ${userProfile.currentXp} XP',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.creamBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between badge and edge
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}