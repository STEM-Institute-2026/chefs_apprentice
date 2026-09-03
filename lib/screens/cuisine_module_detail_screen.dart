import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import 'widgets/accordion_widget.dart';

class CuisineModuleDetailScreen extends StatelessWidget {
  final CuisineModuleModel module;

  const CuisineModuleDetailScreen({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    // Combine all module recipes to calculate overall progress
    final allModuleRecipes = [
      ...module.tier1Recipes,
      ...module.tier2Recipes,
      ...module.tier3Recipes,
    ];

    return Scaffold(
      appBar: CustomAppBar(title: module.title),
      backgroundColor: AppColors.creamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================================
            // 1. MODULE BANNER CARD
            // ===================================================================
            CuisineModuleBannerCard(
              module: module,
              allModuleRecipes: allModuleRecipes,
            ),

            const SizedBox(height: 14),

            // ===================================================================
            // 2. FLAVOR PROFILE OVERVIEW
            // ===================================================================
            if (module.flavorProfileOverview.isNotEmpty) ...[
              const HeaderWidget(
                headerText: "Flavor Profile",
                icon: Icons.local_fire_department,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 4),
              FlavorProfileCard(overviewText: module.flavorProfileOverview),
              const SizedBox(height: 14),
            ],

            // ===================================================================
            // 3. ESSENTIAL PANTRY
            // ===================================================================
            if (module.essentialPantry.isNotEmpty) ...[
              const HeaderWidget(
                headerText: "Essential Pantry",
                icon: Icons.kitchen,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: module.essentialPantry.length,
                itemBuilder: (context, index) {
                  return PantryItemCard(item: module.essentialPantry[index]);
                },
              ),
              const SizedBox(height: 14),
            ],

            // ===================================================================
            // 4. KEY TECHNIQUES
            // ===================================================================
            if (module.keyTechniques.isNotEmpty) ...[
              const HeaderWidget(
                headerText: "Key Techniques",
                icon: Icons.auto_awesome,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 4),
              KeyTechniquesCard(techniques: module.keyTechniques),
              const SizedBox(height: 14),
            ],

            // ===================================================================
            // 5. PRACTICE RECIPES SECTION (ACCORDION TIERS)
            // ===================================================================
            const HeaderWidget(
              headerText: "Cuisine Recipes",
              icon: Icons.restaurant_menu,
              iconColor: AppColors.terracottaAccent,
            ),
            const SizedBox(height: 6),

            if (module.tier1Recipes.isNotEmpty)
              AccordionWidget(
                title: "Tier 1 Recipes",
                recipes: module.tier1Recipes,
                initiallyExpanded: true,
              ),

            if (module.tier2Recipes.isNotEmpty)
              AccordionWidget(
                title: "Tier 2 Recipes",
                recipes: module.tier2Recipes,
              ),

            if (module.tier3Recipes.isNotEmpty)
              AccordionWidget(
                title: "Tier 3 Recipes",
                recipes: module.tier3Recipes,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET 1: Module Banner Card
// ===================================================================
class CuisineModuleBannerCard extends StatelessWidget {
  final CuisineModuleModel module;
  final List<RecipeModel> allModuleRecipes;

  const CuisineModuleBannerCard({
    super.key,
    required this.module,
    required this.allModuleRecipes,
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
                module.coverImageUrl,
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
                    final int completedCount =
                        HistoryService.getCompletedCount(allModuleRecipes);

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
                        '$completedCount / ${allModuleRecipes.length} Recipes Done',
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
              module.description,
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
// HELPER WIDGET 2: Flavor Profile Card
// ===================================================================
class FlavorProfileCard extends StatelessWidget {
  final String overviewText;

  const FlavorProfileCard({super.key, required this.overviewText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.oliveSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          overviewText,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.oliveSecondary,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET 3: Pantry Item Card
// ===================================================================
class PantryItemCard extends StatelessWidget {
  final PantryItemModel item;

  const PantryItemCard({super.key, required this.item});

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
          leading: CircleAvatar(
            backgroundColor:
                AppColors.oliveSecondary.withValues(alpha: 0.12),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.oliveSecondary,
              size: 20,
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.oliveSecondary,
            ),
          ),
          subtitle: Text(
            item.description,
            style: TextStyle(
              color: AppColors.oliveSecondary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET 4: Key Techniques Card
// ===================================================================
class KeyTechniquesCard extends StatelessWidget {
  final List<String> techniques;

  const KeyTechniquesCard({super.key, required this.techniques});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.oliveSecondary,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          children: techniques.map((technique) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.creamBackground,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      technique,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.creamBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}