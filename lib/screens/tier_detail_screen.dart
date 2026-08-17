import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../services/history_service.dart';
import './widgets/recipe_card.dart';
import 'widgets/header_and_app_bar.dart';
import 'skill_detail_screen.dart';
import '../constants/app_transitions.dart';

class TierDetailScreen extends StatelessWidget {
  final TierModel tier;

  const TierDetailScreen({
    super.key,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: tier.title),
      backgroundColor: AppColors.creamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===================================================================
            // 1. TIER BANNER CARD
            // ===================================================================
            Container(
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
                  // Image with Progress Badge
                  Stack(
                    children: [
                      Image.network(
                        tier.coverImageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 160,
                          color: AppColors.oliveSecondary,
                          child: const Icon(Icons.restaurant,
                              size: 40, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        // Reactive count badge updating directly from savedMealsNotifier
                        child: ValueListenableBuilder<List<CookedHistoryModel>>(
                          valueListenable: HistoryService.savedMealsNotifier,
                          builder: (context, savedMeals, child) {
                            final int completedCount =
                                HistoryService.getCompletedCount(tier.recipes);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.terracottaAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$completedCount / ${tier.recipes.length} Recipes Done',
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
                  // Description
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tier.description,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.3,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===================================================================
            // 2. TIER LESSONS SECTION
            // ===================================================================
            const HeaderWidget(headerText: "Tier Lessons"),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tier.skills.length,
              itemBuilder: (context, index) {
                return LessonCard(skill: tier.skills[index]);
              },
            ),

            const SizedBox(height: 8),

            // ===================================================================
            // 3. PRACTICE RECIPES SECTION
            // ===================================================================
            const HeaderWidget(headerText: "Practice Recipes"),

            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tier.recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return RecipeCatalogCard(recipe: tier.recipes[index]);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// HELPER WIDGET: Lesson Card
// ===================================================================
class LessonCard extends StatelessWidget {
  final SkillModel skill;

  const LessonCard({super.key, required this.skill});

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
            backgroundColor: AppColors.oliveSecondary.withValues(alpha: 0.15),
            child: Icon(skill.icon, color: AppColors.oliveSecondary),
          ),
          title: Text(
            skill.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.oliveSecondary),
          ),
          subtitle: Text(
            skill.shortDescription,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.terracottaAccent, fontWeight: FontWeight.w900),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              StandardDetailRoute(
                page: SkillDetailScreen(skill: skill),
              ),
            );
          },
        ),
      ),
    );
  }
}