import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/models.dart';
import '../constants/app_transitions.dart';

class CookedHistoryScreen extends StatelessWidget {
  const CookedHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Cooked History'),
            SizedBox(height: 2),
            Text(
              'Click on an entry to view details',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.creamBackground,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground,
      ),
      body: ValueListenableBuilder<List<CookedHistoryModel>>(
        valueListenable: HistoryService.savedMealsNotifier,
        builder: (context, savedMeals, child) {
          if (savedMeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.terracottaAccent,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No meals cooked yet!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.oliveSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete a recipe to add it to your history.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.60,
            ),
            itemCount: savedMeals.length,
            itemBuilder: (context, index) {
              final meal = savedMeals[index];
              return CookedMealCard(meal: meal);
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE MEAL CARD WIDGET
// -----------------------------------------------------------------------------
class CookedMealCard extends StatelessWidget {
  final CookedHistoryModel meal;

  const CookedMealCard({
    super.key,
    required this.meal,
  });

  // Safe image provider that works across Web, Network, and Native Storage
  Widget _buildMealImage(String imagePath) {
    if (imagePath.isEmpty) {
      return const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: AppColors.oliveSecondary,
        ),
      );
    }

    // Handles Web Base64 strings, Network URLs, or Blob URLs
    if (imagePath.startsWith('data:image') ||
        imagePath.startsWith('http') ||
        imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // Handles Native Mobile File Paths
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          StandardDetailRoute(
            page: MealDetailScreen(meal: meal),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PORTRAIT PHOTO AREA
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: _buildMealImage(meal.imagePath),
              ),
            ),

            // 2. BOTTOM DETAILS AREA
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // STAR RATING BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade800
                                  .withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              meal.rating != null
                                  ? '${meal.rating}'
                                  : 'Unrated',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // SAVINGS / COST BADGE
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildSavingsBadge(meal.costSaved),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final CookedHistoryModel meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text('Cooked on ${_formatDate(meal.dateCooked)}'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FULL PHOTO DISPLAY
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 600,
                color: Colors.grey.shade200,
                child: meal.imagePath.isNotEmpty
                    ? (kIsWeb
                        ? Image.network(meal.imagePath, fit: BoxFit.cover)
                        : Image.file(File(meal.imagePath), fit: BoxFit.cover))
                    : const Icon(Icons.restaurant,
                        size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // TITLE
            Text(
              meal.recipeTitle,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // RATING & MONEY SAVED ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // STAR RATING BADGE
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        meal.rating != null ? '${meal.rating}' : 'Unrated',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: meal.rating != null
                              ? Colors.amber.shade900
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // SAVINGS / COST BADGE
                _buildSavingsBadge(meal.costSaved),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSavingsBadge(double? savings) {
  if (savings == null) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'No Cost Entered',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  if (savings == 0) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Broke Even',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF2C3523),
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  final bool isSaved = savings > 0;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: isSaved
          ? AppColors.oliveSecondary.withValues(alpha: 0.25)
          : AppColors.terracottaAccent.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      isSaved
          ? 'Saved \$${savings.toStringAsFixed(2)}'
          : 'Spent \$${savings.abs().toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isSaved
            ? AppColors.oliveSecondary
            : AppColors.terracottaAccent,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}