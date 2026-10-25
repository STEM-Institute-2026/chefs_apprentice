import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import 'widgets/accordion_widget.dart';

class MealFundamentalDetailScreen extends StatelessWidget {
  final MealFundamentalModel fundamental;

  const MealFundamentalDetailScreen({
    super.key,
    required this.fundamental,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: fundamental.categoryName),
      backgroundColor: AppColors.creamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================================
            // 1. BANNER CARD
            // ===================================================================
            MealFundamentalBannerCard(fundamental: fundamental),

            const SizedBox(height: 16),

            // ===================================================================
            // 2. FUNDAMENTAL STRATEGIES SECTION
            // ===================================================================
            if (fundamental.strategies.isNotEmpty) ...[
              const HeaderWidget(
                headerText: "Fundamental Strategies",
                icon: Icons.lightbulb_outline,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fundamental.strategies.length,
                itemBuilder: (context, index) {
                  return StrategyTipItemCard(
                    strategy: fundamental.strategies[index],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ===================================================================
            // 3. RECIPES SECTION (ACCORDION WIDGET)
            // ===================================================================
            if (fundamental.recipes.isNotEmpty) ...[
              const HeaderWidget(
                headerText: "Fundamental Recipes",
                icon: Icons.restaurant_menu,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 8),
              AccordionWidget(
                title: "${fundamental.categoryName} Recipes",
                recipes: fundamental.recipes,
                initiallyExpanded: true,
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET 1: Meal Fundamental Banner Card
// ===================================================================
class MealFundamentalBannerCard extends StatelessWidget {
  final MealFundamentalModel fundamental;

  const MealFundamentalBannerCard({
    super.key,
    required this.fundamental,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                fundamental.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160,
                  color: AppColors.oliveSecondary,
                  child: const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ValueListenableBuilder<List<CookedHistoryModel>>(
                  valueListenable: HistoryService.savedMealsNotifier,
                  builder: (context, savedMeals, child) {
                    final userCompletedRecipeIds =
                        savedMeals.map((m) => m.recipeId).toSet();
                    final int completedCount =
                        fundamental.getCompletedCount(userCompletedRecipeIds);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.terracottaAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedCount / ${fundamental.recipes.length} Recipes Done',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              fundamental.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET 2: Strategy Tip Item Card
// ===================================================================
class StrategyTipItemCard extends StatelessWidget {
  final FundamentalStrategyModel strategy;

  const StrategyTipItemCard({
    super.key,
    required this.strategy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor:
                AppColors.terracottaAccent.withValues(alpha: 0.12),
            child: const Icon(
              Icons.auto_awesome, // Changed from lightbulb to sparkles
              color: AppColors.terracottaAccent,
              size: 20,
            ),
          ),
          title: Text(
            strategy.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.oliveSecondary,
              fontSize: 20,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              strategy.tip,
              style: TextStyle(
                color: AppColors.oliveSecondary.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}