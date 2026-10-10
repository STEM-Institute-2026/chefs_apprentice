import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../constants/app_transitions.dart';
import 'skill_module_detail_screen.dart';
import 'cuisine_module_detail_screen.dart';
import 'widgets/header_and_app_bar.dart';
import 'starter_path_detail_screen.dart';
import 'meal_fundamental_detail_screen.dart';

class LearnScreen extends StatelessWidget {
  final EssentialsTabModel essentialsData;
  final List<SkillModuleModel> skillModules;
  final List<CuisineModuleModel> cuisineModules;

  const LearnScreen({
    super.key,
    required this.essentialsData,
    required this.skillModules,
    required this.cuisineModules,
  });

  int _getDifficultyRank(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'fundamentals':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
      case 'mastery':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedSkillModules = List<SkillModuleModel>.from(skillModules)
      ..sort((a, b) => _getDifficultyRank(a.difficultyLevel)
          .compareTo(_getDifficultyRank(b.difficultyLevel)));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        appBar: CustomAppBar(
          title: 'Learn',
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              decoration: BoxDecoration(
                color: AppColors.creamBackground.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: AppColors.terracottaAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    AppColors.creamBackground.withValues(alpha: 0.8),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 16),
                        SizedBox(width: 4),
                        Text('Essentials'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 16),
                        SizedBox(width: 4),
                        Text('Skills'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 16),
                        SizedBox(width: 4),
                        Text('Cuisines'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder<List<CookedHistoryModel>>(
          valueListenable: HistoryService.savedMealsNotifier,
          builder: (context, savedMeals, child) {
            // Extract all completed recipe IDs into a Set for fast lookup
            final userCompletedRecipeIds =
                savedMeals.map((m) => m.recipeId).toSet();

            return TabBarView(
              children: [
                // =============================================================
                // TAB 1: ESSENTIALS
                // =============================================================
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: InfoBannerBox(
                        icon: Icons.star_outline,
                        title: "Essential Recipes",
                        description:
                            "Learn essential recipes that are healthy, nutritious, and time-effective. For cooking novices, look through the Starter Path to get exposure to various fundamental cooking-skills.",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- STARTER PATH SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StarterPathCard(
                        essentialsData: essentialsData,
                        userCompletedRecipeIds: userCompletedRecipeIds,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: AppColors.oliveSecondary,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              "MEAL FUNDAMENTALS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.oliveSecondary.withValues(alpha: 0.7),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: AppColors.oliveSecondary,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- MEAL FUNDAMENTALS CARDS (Breakfast, Lunch, Dinner) ---
                    ...essentialsData.mealFundamentals.map((mealModel) {
                      return MealFundamentalCard(
                        mealModel: mealModel,
                        userCompletedRecipeIds: userCompletedRecipeIds,
                      );
                    }),
                  ],
                ),

                // =============================================================
                // TAB 2: SKILLS
                // =============================================================
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: InfoBannerBox(
                        icon: Icons.lightbulb_outline,
                        title: "Culinary Techniques",
                        description:
                            "Focus on foundational kitchen mechanics step-by-step, from essential knife safety to temperature control.",
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sortedSkillModules.map((module) {
                      final allModuleRecipes = [
                        ...module.tier1Recipes,
                        ...module.tier2Recipes,
                        ...module.tier3Recipes,
                      ];
                      final completedCount =
                          HistoryService.getCompletedCount(allModuleRecipes);

                      return SkillModuleCard(
                        module: module,
                        completedCount: completedCount,
                        totalRecipesCount: allModuleRecipes.length,
                      );
                    }),
                  ],
                ),

                // =============================================================
                // TAB 3: CUISINES
                // =============================================================
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: InfoBannerBox(
                        icon: Icons.public,
                        title: "Explore Global Flavors",
                        description:
                            "Discover region-specific pantries, flavor bases, and specialized cooking traditions from around the world.",
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...cuisineModules.map((module) {
                      return CuisineModuleCard(module: module);
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// STARTER PATH CARD
// =============================================================================
class StarterPathCard extends StatelessWidget {
  final EssentialsTabModel essentialsData;
  final Set<String> userCompletedRecipeIds;

  const StarterPathCard({
    super.key,
    required this.essentialsData,
    required this.userCompletedRecipeIds,
  });

  @override
  Widget build(BuildContext context) {
    final int completedCount =
        essentialsData.getCompletedStarterCount(userCompletedRecipeIds);
    final int totalCount = essentialsData.totalStarterRecipes;
    final double progress =
        essentialsData.getStarterCompletionPercentage(userCompletedRecipeIds);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      color: AppColors.creamBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.oliveSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              StandardDetailRoute(
                page: StarterPathDetailScreen(essentialsData: essentialsData),
              ),
            );
        },
        child: Stack(
          children: [
            Image.asset(
              essentialsData.coverImageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholder(),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.terracottaAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'LEARN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.terracottaAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ultimate Starter Path",
                    style: const TextStyle(
                      color: AppColors.creamBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedCount / $totalCount Completed',
                    style: TextStyle(
                      color: AppColors.creamBackground.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.terracottaAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.school,
        size: 40,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}

// =============================================================================
// MEAL FUNDAMENTAL CARD (Breakfast, Lunch, Dinner)
// =============================================================================
class MealFundamentalCard extends StatelessWidget {
  final MealFundamentalModel mealModel;
  final Set<String> userCompletedRecipeIds;

  const MealFundamentalCard({
    super.key,
    required this.mealModel,
    required this.userCompletedRecipeIds,
  });

  @override
  Widget build(BuildContext context) {
    final int completedCount = mealModel.getCompletedCount(userCompletedRecipeIds);
    final int totalCount = mealModel.recipes.length;
    final double progress = mealModel.getCompletionPercentage(userCompletedRecipeIds);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        color: AppColors.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.oliveSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
             Navigator.push(
              context,
              StandardDetailRoute(
                page: MealFundamentalDetailScreen(fundamental: mealModel),
              ),
            );
          },
          child: Stack(
            children: [
              Image.asset(
                mealModel.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mealModel.categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.terracottaAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mealModel.description,
                      style: const TextStyle(
                        color: AppColors.creamBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount / $totalCount Completed',
                      style: TextStyle(
                        color: AppColors.creamBackground.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.terracottaAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}

// =============================================================================
// SKILL MODULE CARD
// =============================================================================
class SkillModuleCard extends StatelessWidget {
  final SkillModuleModel module;
  final int completedCount;
  final int totalRecipesCount;

  const SkillModuleCard({
    super.key,
    required this.module,
    required this.completedCount,
    required this.totalRecipesCount,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalRecipesCount > 0
        ? (completedCount / totalRecipesCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        color: AppColors.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.oliveSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              StandardDetailRoute(
                page: SkillModuleDetailScreen(module: module),
              ),
            );
          },
          child: Stack(
            children: [
              Image.asset(
                module.coverImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            module.difficultyLevel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.menu_book,
                          color: AppColors.terracottaAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.title,
                      style: const TextStyle(
                        color: AppColors.creamBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount / $totalRecipesCount Completed',
                      style: TextStyle(
                        color:
                            AppColors.creamBackground.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.terracottaAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}

// =============================================================================
// CUISINE MODULE CARD
// =============================================================================
class CuisineModuleCard extends StatelessWidget {
  final CuisineModuleModel module;

  const CuisineModuleCard({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    final allModuleRecipes = [
      ...module.tier1Recipes,
      ...module.tier2Recipes,
      ...module.tier3Recipes,
    ];

    final int totalRecipesCount = allModuleRecipes.length;
    final int completedCount =
        HistoryService.getCompletedCount(allModuleRecipes);
    final double progress = totalRecipesCount > 0
        ? (completedCount / totalRecipesCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        color: AppColors.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.oliveSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              StandardDetailRoute(
                page: CuisineModuleDetailScreen(module: module),
              ),
            );
          },
          child: Stack(
            children: [
              Image.asset(
                module.coverImageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              color: AppColors.creamBackground,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.public,
                          color: AppColors.terracottaAccent,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedCount / $totalRecipesCount Completed',
                      style: TextStyle(
                        color:
                            AppColors.creamBackground.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.terracottaAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}

// =============================================================================
// INFO BANNER BOX
// =============================================================================
class InfoBannerBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoBannerBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.oliveSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.terracottaAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.oliveSecondary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.oliveSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}