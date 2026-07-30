import 'package:charles_flutter_app_main/screens/tier_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../mock_tier_data.dart';
import '../services/history_service.dart';

class TierSelectionScreen extends StatefulWidget {
  const TierSelectionScreen({super.key});

  @override
  State<TierSelectionScreen> createState() => _TierSelectionScreenState();
}

class _TierSelectionScreenState extends State<TierSelectionScreen> {
  // 1. APP STATE: Track completed recipe IDs
  Set<String> get completedRecipeIds => HistoryService.completedRecipeIds;

  // 2. HELPER: Determines if a given tier is unlocked
  bool isTierUnlocked(int tierNumber) {
    if (tierNumber == 1) return true;

    List<RecipeModel> previousTierRecipes = switch (tierNumber) {
      2 => tier1Recipes,
      3 => tier2Recipes,
      4 => tier3Recipes,
      _ => [],
    };

    int completedCount = previousTierRecipes
        .where((recipe) => completedRecipeIds.contains(recipe.recipeId))
        .length;

    return completedCount >= 2;
  }

  // 3. HELPER: Counts completed recipes for a recipe list
  int getCompletedCount(List<RecipeModel> recipes) {
    return recipes
        .where((recipe) => completedRecipeIds.contains(recipe.recipeId))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground,
        elevation: 0,
        title: Text(
          'Cooking Tiers',
          style: TextStyle(
            color: AppColors.creamBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true

      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        itemCount: mockTiers.length,
        itemBuilder: (context, index) {
          final tier = mockTiers[index];
          final unlocked = isTierUnlocked(tier.tierNumber);
          final completed = getCompletedCount(tier.recipes);

          int prevCompleted = 0;
            if (index > 0) {
              final previousTier = mockTiers[index - 1];
              prevCompleted = getCompletedCount(previousTier.recipes);
            }
          
          return TierCard(
            tier: tier,
            isUnlocked: unlocked,
            completedCount: completed,
            previousTierCompleted: prevCompleted,
            onTap: () {
                Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TierDetailScreen(
                  tier: tier
                ),
              ),
            );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// REUSABLE TIER CARD WIDGET
// =============================================================================

class TierCard extends StatelessWidget {
  final TierModel tier;
  final bool isUnlocked;
  final int completedCount;
  final int totalRequired;
  final VoidCallback? onTap;
  final int previousTierCompleted;

  const TierCard({
    super.key,
    required this.tier,
    required this.isUnlocked,
    required this.completedCount,
    this.previousTierCompleted = 0,
    this.totalRequired = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isUnlocked ? 3 : 1,
        color: AppColors.creamBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.oliveSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          child: Stack(
            children: [
              // --- 1. BACKGROUND IMAGE WITH SAFE FALLBACK ---
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.35,
                child: Image.network(
                  tier.coverImageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                ),
              ),

              // --- 2. GRADIENT OVERLAY FOR TEXT READABILITY ---
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: isUnlocked ? 0.75 : 0.90),
                    ],
                  ),
                ),
              ),

              // --- 3. CARD CONTENT ---
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Lock Icon Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? AppColors.terracottaAccent
                                : AppColors.oliveSecondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'TIER ${tier.tierNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(
                          isUnlocked ? Icons.lock_open : Icons.lock,
                          color: isUnlocked
                              ? AppColors.terracottaAccent
                              : Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      tier.title,
                      style: TextStyle(
                        color: isUnlocked ? AppColors.creamBackground : Colors.grey.shade400,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Text
                    Text(
                      isUnlocked
                          ? '$completedCount / ${tier.recipes.length} Completed'
                          : 'Complete $totalRequired recipes in Tier ${tier.tierNumber - 1} to unlock',
                      style: TextStyle(
                        color: AppColors.creamBackground.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: isUnlocked
                            ? (completedCount / tier.recipes.length)
                            : (previousTierCompleted / totalRequired).clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked
                              ? AppColors.terracottaAccent
                              : AppColors.oliveSecondary,
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

  // Helper method to keep image placeholder dry and consistent
  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.oliveSecondary.withValues(alpha: 0.15),
      child: Icon(
        Icons.restaurant,
        size: 48,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}