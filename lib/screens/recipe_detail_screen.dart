import 'package:flutter/material.dart';
import '../models/models.dart';
import 'interactive_cooking_screen.dart';
import 'recipe_complete_screen.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import '../constants/app_transitions.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(
        title: recipe.title,
        actions: [
          // Reactive favorite heart button
          ValueListenableBuilder<Set<String>>(
            valueListenable: HistoryService.favoriteRecipeIdsNotifier,
            builder: (context, favoriteIds, child) {
              final isFavorite = favoriteIds.contains(recipe.recipeId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.creamBackground,
                ),
                onPressed: () {
                  HistoryService.toggleFavorite(recipe.recipeId);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                recipe.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(
                        "${recipe.difficultyTier} Difficulty",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.terracottaAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      recipe.description,
                      style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatItemWidget(
                      icon: Icons.timer_outlined,
                      label: '${recipe.cookTimeMinutes} mins',
                    ),
                    StatItemWidget(
                      icon: Icons.people_outline,
                      label: '${recipe.servings} Servings',
                    ),
                    StatItemWidget(
                      icon: Icons.attach_money,
                      label: '\$${recipe.estimatedCost.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              NutritionCard(nutrition: recipe.nutritionStats),
              HeaderWidget(
                headerText: "Ingredients",
                icon: Icons.shopping_basket_outlined,
                iconColor: AppColors.terracottaAccent,
              ),
              IngredientListSection(ingredients: recipe.ingredients),
              const SizedBox(height: 5.0),
              HeaderWidget(
                headerText: "Instructions",
                icon: Icons.format_list_numbered,
                iconColor: AppColors.terracottaAccent,
              ),
              InstructionListSection(instructions: recipe.steps),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RecipeBottomActionBar(
        onStartGuidedCooking: () {
          Navigator.push(
            context,
            ModalSlideUpRoute(
              page: InteractiveCookingScreen(recipe: recipe),
            ),
          );
        },
        onFinishedCooking: () {
          Navigator.push(
            context,
            ScalePopRoute(
              page: RecipeCompleteScreen(recipe: recipe),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRACTED WIDGET CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class StatItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const StatItemWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.terracottaAccent, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppColors.oliveSecondary,
          ),
        ),
      ],
    );
  }
}

class IngredientListSection extends StatelessWidget {
  final Map<String, String> ingredients;

  const IngredientListSection({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          for (var entry in ingredients.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                      ),
                      Text(
                        entry.value,
                        style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Divider(
                    height: 1,
                    thickness: 2,
                    color: AppColors.oliveSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class InstructionListSection extends StatelessWidget {
  final List<CookingStepModel> instructions;

  const InstructionListSection({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          for (var entry in instructions.asMap().entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${entry.value.stepNumber}.",
                    style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value.instructionText,
                      style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class RecipeBottomActionBar extends StatelessWidget {
  final VoidCallback onStartGuidedCooking;
  final VoidCallback onFinishedCooking;

  const RecipeBottomActionBar({
    super.key,
    required this.onStartGuidedCooking,
    required this.onFinishedCooking,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracottaAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onStartGuidedCooking,
                  child: const Text(
                    'Start Guided',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oliveSecondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onFinishedCooking,
                  child: const Text(
                    'I finished cooking!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  final NutritionModel nutrition;

  const NutritionCard({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          color: AppColors.oliveSecondary,
          thickness: 1,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NutrientItem(
                  icon: '🔥',
                  value: nutrition.caloriesText,
                  label: 'Calories',
                ),
                const VerticalDivider(
                  color: AppColors.oliveSecondary,
                  thickness: 1,
                  width: 1,
                ),
                NutrientItem(
                  icon: '🥩',
                  value: nutrition.proteinText,
                  label: 'Protein',
                ),
                const VerticalDivider(
                  color: AppColors.oliveSecondary,
                  thickness: 1,
                  width: 1,
                ),
                NutrientItem(
                  icon: '🍞',
                  value: nutrition.carbsText,
                  label: 'Carbs',
                ),
                const VerticalDivider(
                  color: AppColors.oliveSecondary,
                  thickness: 1,
                  width: 1,
                ),
                NutrientItem(
                  icon: '🧀',
                  value: nutrition.fatText,
                  label: 'Fat',
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: AppColors.oliveSecondary,
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}

class NutrientItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const NutrientItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.oliveSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.terracottaAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}