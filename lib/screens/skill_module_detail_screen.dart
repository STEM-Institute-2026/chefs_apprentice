import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import 'widgets/accordion_widget.dart';
import 'skill_detail_screen.dart';
import '../constants/app_transitions.dart';

class SkillModuleDetailScreen extends StatelessWidget {
  final SkillModuleModel module;

  const SkillModuleDetailScreen({
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===================================================================
            // 1. MODULE BANNER CARD
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
                          child: const Icon(Icons.restaurant,
                              size: 40, color: Colors.white),
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
                                  horizontal: 10, vertical: 6),
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
            ),

            const SizedBox(height: 16),

            // ===================================================================
            // 2. LESSONS SECTION
            // ===================================================================
            const HeaderWidget(
              headerText: "Module Lessons",
              icon: Icons.school,
              iconColor: AppColors.terracottaAccent,
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: module.skills.length,
              itemBuilder: (context, index) {
                return LessonCard(skill: module.skills[index]);
              },
            ),

            const SizedBox(height: 16),

            // ===================================================================
            // 3. PRACTICE RECIPES SECTION
            // ===================================================================
            const HeaderWidget(
              headerText: "Practice Recipes",
              icon: Icons.restaurant_menu,
              iconColor: AppColors.terracottaAccent,
            ),
            const SizedBox(height: 8),

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
              fontWeight: FontWeight.bold,
              color: AppColors.oliveSecondary,
            ),
          ),
          subtitle: Text(
            skill.shortDescription,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.terracottaAccent,
              fontWeight: FontWeight.w900,
            ),
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