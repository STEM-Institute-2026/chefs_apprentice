import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedMeals = HistoryService.savedMeals;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Column (
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Cooked History'),
            SizedBox(height: 2),
            Text('Click on a entry to view details', style: TextStyle(fontSize: 12, color: AppColors.creamBackground, fontWeight: FontWeight.w100)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground,
      ),
      body: savedMeals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No meals cooked yet!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete a recipe to add it to your history.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
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
                // Clean and simple widget call!
                return CookedMealCard(meal: meal);
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Push to your new detail widget when tapped!
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(meal: meal),
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
                child: meal.imagePath.isNotEmpty
                    ? (kIsWeb
                        ? Image.network(
                            meal.imagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(meal.imagePath),
                            fit: BoxFit.cover,
                          ))
                    : const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
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
                  // Inside CookedMealCard details area:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🌟 STAR RATING (Subtle Amber Pill)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12), // Subtle amber glow
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade800.withValues(alpha: 0.85), // Warm amber star
                            ),
                            const SizedBox(width: 3),
                            Text(
                              meal.rating != null ? '${meal.rating}' : 'Unrated',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withValues(alpha: 0.75), // Muted black for readability
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8), // Breathing room

                      // 💰 SAVINGS / COST BADGE (Your existing badge)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildSavingsBadge(meal.costSaved),
                        ),
                      ),
                    ],
                  )
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text('Cooked on ${_formatDate(meal.completedAt)}'),
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
                    : const Icon(Icons.restaurant, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // TITLE
            Text(
              meal.recipeTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // RATING & MONEY SAVED ROW
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. STAR RATING BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12), // Warm soft glow
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
                        color: meal.rating != null ? Colors.amber.shade900 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. SAVINGS / COST BADGE (Passes data cleanly)
              _buildSavingsBadge(meal.costSaved),
            ],
          )
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
      // 🟢 Olive tint for saved, 🟠 Terracotta tint for spent (No harsh bright red/green!)
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
        // Deep muted tones for text readability
        color: isSaved 
            ? AppColors.oliveSecondary 
            : AppColors.terracottaAccent,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}