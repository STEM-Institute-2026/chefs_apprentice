import 'package:flutter/material.dart';
import '../models/models.dart';
import 'interactive_cooking_screen.dart';
import 'recipe_complete_screen.dart';
import '../services/history_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground, // Use your defined cream background color
      
      appBar: AppBar(
        // 1. FAR LEFT
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        // 2. CENTER
        centerTitle: true,
        title: Text(
          widget.recipe.title, 
          style: kHeaderTextStyle.copyWith(color: AppColors.creamBackground),
        ),

        // 3. FAR RIGHT
        actions: [
          IconButton(
            icon: Icon(
              HistoryService.isRecipeFavorite(widget.recipe.recipeId)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: HistoryService.isRecipeFavorite(widget.recipe.recipeId)
                  ? Colors.red
                  : Colors.white,
            ),
            onPressed: () {
              setState(() {
                HistoryService.toggleFavorite(widget.recipe.recipeId);
              });
            },
          )
        ],
      
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground,
      ),
      
     body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.network( // image of recipe at the top of the screen 
              widget.recipe.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Just the Badge (aligned to the left)
                  Chip(
                    label: Text(
                      "${widget.recipe.difficultyTier} Difficulty",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.terracottaAccent,
                  ),
                  const SizedBox(height: 12),

                  // 2. Recipe Description
                  Text(
                    widget.recipe.description,
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
                  // 1. Cook Time
                  StatItemWidget(
                    icon: Icons.timer_outlined,
                    label: '${widget.recipe.cookTimeMinutes} mins',
                  ),

                  // 2. Servings / Yield
                  StatItemWidget(
                    icon: Icons.people_outline,
                    label: '${widget.recipe.servings} Servings',
                  ),

                  // 3. Cost
                  StatItemWidget(
                    icon: Icons.attach_money,
                    label: '\$${widget.recipe.estimatedCost.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 5.0),

            NutritionCard(nutrition: widget.recipe.nutritionStats),
            
            HeaderWidget(headerText: "Ingredients"),

            // 2. The 2-Column Ingredients List Widget
            IngredientListSection(ingredients: widget.recipe.ingredients),
          
            const SizedBox(height: 5.0),
            // 3. The Instruction List Widget
            HeaderWidget(headerText: "Instructions"),
            
            InstructionListSection(instructions: widget.recipe.steps),
            
            const SizedBox(height: 20),
          ],
        ),      
      ),
    ),
    
    bottomNavigationBar: RecipeBottomActionBar(
        onStartGuidedCooking: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InteractiveCookingScreen(
                recipe: widget.recipe
              ),
            ),
          );
        },
        onFinishedCooking: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeCompleteScreen(recipe: widget.recipe),
            ),
          );
        },
    ) 
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRACTED WIDGET CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class HeaderWidget extends StatelessWidget {
  // 1. Declare any parameters passed into this widget
  final String headerText;

  // 2. Constructor with super key
  const HeaderWidget({
    super.key,
    required this.headerText,
  });

  // 3. The build method that returns your UI
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        headerText,
        style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
      ),
    );
  }
}

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
                      // 👈 Calls the Ingredient Name (e.g., "Flour")
                      Text(
                        entry.key, 
                        style: kBodyTextStyle.copyWith(color: AppColors.oliveSecondary),
                      ),
                  
                      // 👈 Calls the Amount (e.g., "2 cups")
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
                  // Instruction Number
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
              // 1. Start Guided Cooking Button
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

              // 2. Finished Cooking Button
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