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
            Text('Click on a entry to view details', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      Text(
                        meal.rating != null ? '⭐ ${meal.rating}' : '⭐ Unrated',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      
                      const SizedBox(width: 8), // 👈 Gives a little breathing room between rating and savings

                      // 🟢 Wrap with Expanded so Flutter forces it to fit inside the Row!
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight, // 👈 Keeps it pushed to the right side
                          child: _buildSavingsText(meal.costSaved),
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
              children: [
                Chip(
                  avatar: const Text('⭐'),
                  label: Text(
                    meal.rating != null ? '${meal.rating}' : 'Unrated',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  )
                ),
                const SizedBox(width: 10),
                Chip(
                  avatar: Icon(
                    meal.costSaved == null
                        ? Icons.restaurant
                        : (meal.costSaved! >= 0 ? Icons.savings : Icons.trending_down),
                    color: meal.costSaved == null
                        ? Colors.grey
                        : (meal.costSaved! >= 0 ? Colors.green : Colors.red),
                    size: 18,
                  ),
                  
                  // 🔁 Reused here as the label!
                  label: _buildSavingsText(meal.costSaved),
                  
                  backgroundColor: meal.costSaved == null
                      ? Colors.grey.shade100
                      : (meal.costSaved! >= 0 ? Colors.green.shade50 : Colors.red.shade50),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSavingsText(double? savings) {
  if (savings == null) {
    return const Text(
      'No Cost Inputted',
      style: TextStyle(fontSize: 12, color: Colors.grey),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  if (savings == 0) {
    return const Text(
      'Broke Even',
      style: TextStyle(
        fontSize: 12, 
        color: Colors.orange, 
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  final bool isSaved = savings > 0;

  return Text(
    isSaved
        ? 'Saved \$${savings.toStringAsFixed(2)}'
        : 'Spent \$${savings.abs().toStringAsFixed(2)} extra',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: isSaved ? Colors.green : Colors.red,
    ),
    overflow: TextOverflow.ellipsis, // 👈 Truncates with ... if too long
    maxLines: 1,                     // 👈 Prevents wrapping onto line 2
  );
}