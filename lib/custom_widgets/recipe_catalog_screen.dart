import 'package:flutter/material.dart';
// Replace with your actual import paths:
import '../models/models.dart';
import 'package:charles_flutter_app_main/mock_data.dart';
import 'recipe_detail_screen.dart'; // Your existing detail screen

class RecipeCatalogScreen extends StatelessWidget {
  final List<RecipeModel> recipes;

  RecipeCatalogScreen({
    super.key,
    List<RecipeModel>? recipes,
  }) : recipes = recipes ?? mockRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground, // Use your defined cream background color
      appBar: AppBar(
        title: const Text(
          'Menu Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 👈 2 recipes per row
            crossAxisSpacing: 12, // Horizontal spacing between cards
            mainAxisSpacing: 12, // Vertical spacing between rows
            childAspectRatio: 0.85, // Height-to-width ratio for optimal card layout
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _RecipeCatalogCard(recipe: recipe);
          },
        ),
      ),
    );
  }
}

class _RecipeCatalogCard extends StatelessWidget {
  final RecipeModel recipe;

  const _RecipeCatalogCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the recipe detail screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // Clips image to match card's rounded corners
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recipe Image
            Expanded(
              child: Image.network(
                recipe.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.grey,
                      size: 36,
                    ),
                  );
                },
              ),
            ),

            // 2. Recipe Title
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Truncates if text is too long
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}