import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../../services/history_service.dart';
import './widgets/header_and_app_bar.dart';
import './widgets/recipe_card.dart';
import './widgets/home_app_bar.dart';
import './tier_detail_screen.dart';
import '../constants/app_transitions.dart';
import '../services/data_loader_service.dart';

class HomeScreen extends StatefulWidget {
  final List<RecipeModel> recipes;

  const HomeScreen({
    super.key,
    required this.recipes,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AppData> _appDataFuture;

  @override
  void initState() {
    super.initState();
    _appDataFuture = DataLoaderService.loadInitialData();
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
              child: Text("Error loading app data."),
            );
          }

          final appData = snapshot.data!;
          final allTiers = appData.tiers;
          final currentTier = HistoryService.getActiveTier(allTiers);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // NEXT TIER HERO BANNER
                ContinueTierProgressCard(
                  tier: currentTier,
                  onTierUpdated: () {
                    setState(() {}); // Forces HomeScreen to rebuild with the updated tier!
                  },
                ),

                const SizedBox(height: 12),

                // SECTION 1: QUICK RECIPES
                const HeaderWidget(
                  headerText: 'Quick Recipes',
                  icon: Icons.bolt_rounded,
                ),
                _buildHorizontalRecipeList(widget.recipes),

                const SizedBox(height: 12),

                // SECTION 2: MY FAVORITES
                const HeaderWidget(
                  headerText: 'My Favorites',
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.redAccent,
                ),

                // Dynamically listen to favorite changes using ValueListenableBuilder
                ValueListenableBuilder<Set<String>>(
                  valueListenable: HistoryService.favoriteRecipeIdsNotifier,
                  builder: (context, favoriteIds, child) {
                    final favoriteRecipes = widget.recipes
                        .where((r) => favoriteIds.contains(r.recipeId))
                        .toList();

                    if (favoriteRecipes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'No favorites added yet! Tap the heart on any recipe.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      );
                    }

                    return _buildHorizontalRecipeList(favoriteRecipes);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

  Widget _buildHorizontalRecipeList(List<RecipeModel> recipeList) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: recipeList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 165,
              child: RecipeCatalogCard(recipe: recipeList[index]),
            ),
          );
        },
      ),
    );
  }


class ContinueTierProgressCard extends StatelessWidget {
  final TierModel tier;
  final VoidCallback? onTierUpdated;

  const ContinueTierProgressCard({
    super.key,
    required this.tier,
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
                tier.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
                      AppColors.oliveSecondary.withValues(alpha: 0.6),
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
                            'NEXT LESSON • TIER ${tier.tierNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tier.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.creamBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.creamBackground.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        StandardDetailRoute(
                          page: TierDetailScreen(tier: tier),
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
                        Icon(Icons.arrow_forward_rounded, size: 14),
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