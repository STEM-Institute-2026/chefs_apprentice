import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../constants/app_transitions.dart';
import 'widgets/header_and_app_bar.dart';
import 'recipe_detail_screen.dart';

class StarterPathDetailScreen extends StatelessWidget {
  final EssentialsTabModel essentialsData;

  const StarterPathDetailScreen({
    super.key,
    required this.essentialsData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Starter Path'),
      backgroundColor: AppColors.creamBackground,
      body: ValueListenableBuilder<List<CookedHistoryModel>>(
        valueListenable: HistoryService.savedMealsNotifier,
        builder: (context, savedMeals, child) {
          final completedRecipeIds = savedMeals.map((m) => m.recipeId).toSet();
          final int completedCount =
              essentialsData.getCompletedStarterCount(completedRecipeIds);
          final int totalCount = essentialsData.totalStarterRecipes;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =============================================================
                // 1. HERO BANNER CARD
                // =============================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.oliveSecondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            essentialsData.coverImageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 160,
                              color: AppColors.oliveSecondary,
                              child: const Icon(
                                Icons.school,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.terracottaAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$completedCount / $totalCount Completed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              essentialsData.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 2. PATH STEPS SECTION
                // =============================================================
                const HeaderWidget(
                  headerText: "Learn the Basics",
                  icon: Icons.alt_route,
                  iconColor: AppColors.terracottaAccent,
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: essentialsData.starterPath.length,
                  itemBuilder: (context, index) {
                    final item = essentialsData.starterPath[index];
                    final isLast = index == essentialsData.starterPath.length - 1;
                    final isCompleted = item.isCompleted(completedRecipeIds);

                    return StarterPathStepItem(
                      item: item,
                      stepIndex: index + 1,
                      isCompleted: isCompleted,
                      isLast: isLast,
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGET: Starter Path Step Item (Card + Vertical Dotted Line)
// =============================================================================
class StarterPathStepItem extends StatelessWidget {
  final StarterPathItemModel item;
  final int stepIndex;
  final bool isCompleted;
  final bool isLast;

  const StarterPathStepItem({
    super.key,
    required this.item,
    required this.stepIndex,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = item.recipe;

    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 2,
          clipBehavior: Clip.antiAlias, // Clips the thumbnail flush to the card's rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isCompleted
                  ? AppColors.terracottaAccent.withValues(alpha: 0.5)
                  : AppColors.oliveSecondary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: recipe == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      StandardDetailRoute(
                        page: RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Makes thumbnail stretch full height flush to card boundaries
                children: [
                  // --- LEFT SIDE: FLUSH THUMBNAIL WITH STEP NUMBER ---
                  SizedBox(
                    width: 105,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        recipe?.imageUrl != null
                            ? Image.asset(
                                recipe!.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terracottaAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stepIndex < 10 ? '0$stepIndex' : '$stepIndex',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- RIGHT SIDE: PADDED & VERTICALLY CENTERED CONTENT ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0), // Padding applied only to right text container
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Skill tag & completion checkmark
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.terracottaAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.skillName.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.creamBackground,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? AppColors.terracottaAccent
                                    : AppColors.oliveSecondary
                                        .withValues(alpha: 0.35),
                                size: 24,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Recipe Title
                          Text(
                            recipe?.title ?? 'Recipe Unavailable',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.oliveSecondary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // "Why This Recipe" / Custom Description
                          Text(
                            recipe?.description ?? 'No details available.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.oliveSecondary,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- SUBTLE VERTICAL DOTTED CONNECTOR LINE ---
        if (!isLast)
          CustomPaint(
            size: const Size(2, 28),
            painter: DottedLinePainter(
              color: AppColors.oliveSecondary.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 36,
          color: AppColors.oliveSecondary,
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: Dotted Connector Line
// =============================================================================
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    const double dashHeight = 4;
    const double dashSpace = 4;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}