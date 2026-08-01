import 'package:flutter/material.dart';
// Replace with your actual import paths:
import '../models/models.dart';
import 'package:charles_flutter_app_main/mock_data.dart';
import './widgets/recipe_card.dart';
import 'tier_selection_screen.dart';
import 'widgets/header_and_app_bar.dart';

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
      appBar: CustomAppBar(title: "Recipe Catalog",

        // Replace TextButton with an IconButton!
        leading: IconButton(
          icon: Icon(Icons.alt_route_rounded, color: const Color.fromARGB(255, 99, 130, 197)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TierSelectionScreen(),
              ),
            );
          },
        ),
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
            return RecipeCatalogCard(recipe: recipe);
          },
        ),
      ),
    );
  }
}

