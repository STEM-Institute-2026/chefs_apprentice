import 'package:flutter/material.dart';
import '../../models/models.dart'; // Adjust path to match your AppColors location

class BadgeDetailsDialog extends StatelessWidget {
  final BadgeModel badge;
  final int currentValue;

  const BadgeDetailsDialog({
    super.key,
    required this.badge,
    required this.currentValue,
  });

  /// Helper to show this dialog directly
  static Future<void> show({
    required BuildContext context,
    required BadgeModel badge,
    required int currentValue,
    VoidCallback? onNavigateToModule,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => BadgeDetailsDialog(
        badge: badge,
        currentValue: currentValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = badge.isUnlocked(currentValue);
    final bool isMaxed = badge.isMaxed(currentValue);
    final double progressPercent = badge.getProgressPercentage(currentValue);
    final int nextTarget = badge.getNextTargetValue(currentValue);

    // Tier calculation math for relative progress display
    final int currentStars = badge.getStarLevel(currentValue);
    final int previousTarget =
        currentStars == 0 ? 0 : badge.targetValues[currentStars - 1];
    final int currentTierProgress = currentValue - previousTarget;
    final int currentTierRequirement =
        isMaxed ? 0 : (nextTarget - previousTarget);

    const Color warmBeigeContainer = Color(0xFFEFE6D5);

    return Dialog(
      backgroundColor: AppColors.creamBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon Showcase
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? AppColors.terracottaAccent
                      : Colors.grey.shade400,
                  width: 3,
                ),
              ),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
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
                      errorBuilder: (_, _, _) => Icon(
                        Icons.workspace_premium,
                        size: 36,
                        color: isUnlocked
                            ? AppColors.terracottaAccent
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Title & Description
            Text(
              "Badge: ${badge.title}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.oliveSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 16),

            // Progress Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: warmBeigeContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.oliveSecondary.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Row: Tier Status & Fraction Count
                  // Goal Requirement / Status Line
                  if (isMaxed)
                    const Text(
                      'Badge Completed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.oliveSecondary,
                      ),
                    )
                  else if (badge.targetDescription.isNotEmpty)
                    Text(
                      '${currentTierRequirement - currentTierProgress}/$currentTierRequirement more ${badge.targetDescription} for next star',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.oliveSecondary,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Tier Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.terracottaAccent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Star Targets Breakdown Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        List.generate(badge.targetValues.length, (index) {
                      final targetVal = badge.targetValues[index];
                      final bool tierAchieved = currentValue >= targetVal;

                      return Row(
                        children: [
                          Icon(
                            tierAchieved ? Icons.star : Icons.star_border,
                            size: 18,
                            color: tierAchieved
                                ? AppColors.terracottaAccent
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$targetVal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: tierAchieved
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: tierAchieved
                                  ? AppColors.oliveSecondary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions Row
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.oliveSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.creamBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}