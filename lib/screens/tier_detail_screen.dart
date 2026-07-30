import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../services/history_service.dart';
import './widgets/recipe_card.dart';

class TierDetailScreen extends StatefulWidget {
  final TierModel tier;

  const TierDetailScreen({
    super.key,
    required this.tier,
  });

  @override
  State<TierDetailScreen> createState() => _TierDetailScreenState();
}

class _TierDetailScreenState extends State<TierDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // 💡 Calculate completed recipes for this specific tier
    final int completedCount = widget.tier.recipes
        .where((recipe) => HistoryService.isRecipeCompleted(recipe.recipeId))
        .length;

    return Scaffold(
      
      appBar: AppBar(
        title:  Text(
          // ignore: unnecessary_string_interpolations
          '${widget.tier.title}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.oliveSecondary,
        foregroundColor: AppColors.creamBackground),

      backgroundColor: AppColors.creamBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================================
            // 1. TIER BANNER CARD
            // ===================================================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
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
                        widget.tier.coverImageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 160,
                          color: AppColors.oliveSecondary,
                          child: const Icon(Icons.restaurant, size: 40, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.terracottaAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$completedCount / ${widget.tier.recipes.length} Recipes Done',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Description
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.tier.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===================================================================
            // 2. TIER LESSONS SECTION
            // ===================================================================
            Text(
              'Tier Lessons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.oliveSecondary,
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.tier.skills.length,
              itemBuilder: (context, index) {
                return LessonCard(skill: widget.tier.skills[index]);
              },
            ),

            const SizedBox(height: 24),

            // ===================================================================
            // 3. PRACTICE RECIPES SECTION
            // ===================================================================
            Text(
              'Practice Recipes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.oliveSecondary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.tier.recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return RecipeCatalogCard(recipe: widget.tier.recipes[index]);
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            skill.shortDescription,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to LessonDetailScreen
          },
        ),
      ),
    );
  }
}