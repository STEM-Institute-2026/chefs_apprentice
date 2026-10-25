
import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../../services/history_service.dart';
import './widgets/header_and_app_bar.dart';
import './widgets/recipe_card.dart';
import './widgets/home_app_bar.dart';
import 'skill_module_detail_screen.dart';
import '../constants/app_transitions.dart';
import '../services/data_loader_service.dart';
import '../services/recipe_recommendation_service.dart';

class HomeScreen extends StatefulWidget {
  final List<RecipeModel> recipes;
  final VoidCallback onOpenCatalog;

  const HomeScreen({
    super.key,
    required this.recipes,
    required this.onOpenCatalog,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AppData> _appDataFuture;

  // Keep recommendations stable during ordinary rebuilds/tab switches.
  // Regenerate them whenever the saved preferences change.
  List<RecipeModel>? _cachedRecommendedRecipes;
  String? _cachedPreferencesKey;

  @override
  void initState() {
    super.initState();
    _appDataFuture = DataLoaderService.loadInitialData();
  }

  List<RecipeModel> _getRecommendedRecipes(
    CookingPreferencesModel preferences,
  ) {
    // Sort sets/lists before creating the key so selection order does not
    // count as a preference change.
    final preferencesKey = [
      preferences.cookingSkillTier,
      ([...preferences.favoriteCuisines]..sort()),
      ([...preferences.allergies]..sort()),
      ([...preferences.preferredIngredients]..sort()),
      preferences.maxCookTimeMinutes,
    ].toString();

    if (_cachedRecommendedRecipes == null ||
        _cachedPreferencesKey != preferencesKey) {
      // Use the current savedMeals at the moment preferences are saved.
      // This includes any cooking history added since the previous preferences.
      _cachedRecommendedRecipes =
          RecipeRecommendationService.generateRecommendedRecipes(
        allRecipes: widget.recipes,
        preferences: preferences,
        cookingHistory: HistoryService.savedMeals,
      );
      _cachedPreferencesKey = preferencesKey;
    }

    return _cachedRecommendedRecipes!;
  }

  /// Finds the first incomplete skill module.
  SkillModuleModel _getActiveSkillModule(
    List<SkillModuleModel> skillModules,
  ) {
    for (final module in skillModules) {
      final allModuleRecipes = [
        ...module.tier1Recipes,
        ...module.tier2Recipes,
        ...module.tier3Recipes,
      ];

      final completedCount =
          HistoryService.getCompletedCount(allModuleRecipes);

      if (allModuleRecipes.isNotEmpty &&
          completedCount < allModuleRecipes.length) {
        return module;
      }
    }

    return skillModules.isNotEmpty
        ? skillModules.last
        : skillModules.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: const MainHomeScreenAppBar(),
      body: FutureBuilder<AppData>(
        future: _appDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.terracottaAccent,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Error loading app data.'),
            );
          }

          final appData = snapshot.data!;
          final skillModules = appData.skillModules;

          // Avoid accessing .first if no skill modules exist.
          final activeModule = skillModules.isNotEmpty
              ? _getActiveSkillModule(skillModules)
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SHARPEN YOUR SKILLS HERO BANNER
                if (activeModule != null)
                  ContinueTierProgressCard(
                    module: activeModule,
                    onTierUpdated: () {
                      setState(() {});
                    },
                  ),

                const SizedBox(height: 12),

                // SECTION 1: RECOMMENDED RECIPES
                const HeaderWidget(
                  headerText: 'Recommended Recipes!',
                  icon: Icons.bolt_rounded,
                ),

                ValueListenableBuilder<CookingPreferencesModel?>(
                  valueListenable:
                      HistoryService.cookingPreferencesNotifier,
                  builder: (context, preferences, _) {
                    if (preferences == null) {
                      return const SizedBox.shrink();
                    }

                    final recommendedRecipes =
                        _getRecommendedRecipes(preferences);

                    return _buildHorizontalRecipeList(
                      recommendedRecipes,
                      showCatalogShortcut: true,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // SECTION 2: MY FAVORITES
                const HeaderWidget(
                  headerText: 'My Favorites',
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.redAccent,
                ),

                ValueListenableBuilder<Set<String>>(
                  valueListenable:
                      HistoryService.favoriteRecipeIdsNotifier,
                  builder: (context, favoriteIds, child) {
                    final favoriteRecipes = widget.recipes
                        .where(
                          (recipe) =>
                              favoriteIds.contains(recipe.recipeId),
                        )
                        .toList();

                    if (favoriteRecipes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'No favorites added yet! '
                          'Tap the heart on any recipe.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }

                    // Favorites do not get the catalog shortcut.
                    return _buildHorizontalRecipeList(
                      favoriteRecipes,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalRecipeList(
    List<RecipeModel> recipeList, {
    bool showCatalogShortcut = false,
  }) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // Add one extra item for the catalog shortcut when requested.
        itemCount: recipeList.length +
            (showCatalogShortcut ? 1 : 0),

        itemBuilder: (context, index) {
          // The final item is the catalog shortcut.
          if (showCatalogShortcut &&
              index == recipeList.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: SizedBox(
                width: 165,
                child: CatalogShortcutCard(
                  onTap: widget.onOpenCatalog,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 165,
              child: RecipeCatalogCard(
                recipe: recipeList[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===================================================================
// CATALOG SHORTCUT CARD
// Styled to match the InfoBannerBox aesthetic.
// ===================================================================

class CatalogShortcutCard extends StatelessWidget {
  final VoidCallback onTap;

  const CatalogShortcutCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.oliveSecondary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.oliveSecondary.withValues(
                alpha: 0.3,
              ),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.terracottaAccent,
                  size: 40,
                ),

                const SizedBox(height: 5),

                const Text(
                  'Looking for something else?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.oliveSecondary,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Explore the full recipe catalog!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.oliveSecondary,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.terracottaAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Browse',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// HERO PROGRESS CARD FOR SKILL MODULES
// ===================================================================

class ContinueTierProgressCard extends StatelessWidget {
  final SkillModuleModel module;
  final VoidCallback? onTierUpdated;

  const ContinueTierProgressCard({
    super.key,
    required this.module,
    this.onTierUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                module.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                  color: AppColors.oliveSecondary,
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      AppColors.oliveSecondary.withValues(
                        alpha: 0.6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            color: AppColors.terracottaAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SHARPEN YOUR SKILLS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(
                                alpha: 0.85,
                              ),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.creamBackground,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        module.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.creamBackground.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        StandardDetailRoute(
                          page: SkillModuleDetailScreen(
                            module: module,
                          ),
                        ),
                      );

                      onTierUpdated?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracottaAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue Learning!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                        ),
                      ],
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
}
