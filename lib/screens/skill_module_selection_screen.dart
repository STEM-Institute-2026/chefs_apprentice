import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_loader_service.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';
import '../constants/app_transitions.dart';
import 'skill_module_detail_screen.dart'; // Update to your detail screen import

class SkillModuleSelectionScreen extends StatefulWidget {
  const SkillModuleSelectionScreen({super.key});

  @override
  State<SkillModuleSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends State<SkillModuleSelectionScreen> {
  late Future<AppData> _appDataFuture;

  @override
  void initState() {
    super.initState();
    _appDataFuture = DataLoaderService.loadInitialData();
  }

  // Define explicit order for difficulty levels
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
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: const CustomAppBar(title: "Skill Modules"),
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
              child: Text("Error loading skills data."),
            );
          }

          // 1. Sort modules so Beginner modules appear first
          final modules = List<SkillModuleModel>.from(snapshot.data!.skillModules)
            ..sort((a, b) => _getDifficultyRank(a.difficultyLevel)
                .compareTo(_getDifficultyRank(b.difficultyLevel)));

          return ValueListenableBuilder<List<CookedHistoryModel>>(
            valueListenable: HistoryService.savedMealsNotifier,
            builder: (context, savedMeals, child) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];

                  // 2. Gather all recipes across all tiers in this module
                  final allModuleRecipes = [
                    ...module.tier1Recipes,
                    ...module.tier2Recipes,
                    ...module.tier3Recipes,
                  ];

                  // 3. Count total completed recipes for this specific module
                  final completedCount =
                      HistoryService.getCompletedCount(allModuleRecipes);

                  return SkillModuleCard(
                    module: module,
                    completedCount: completedCount,
                    totalRecipesCount: allModuleRecipes.length,
                    onTap: () {
                      Navigator.push(
                        context,
                        StandardDetailRoute(
                          page: SkillModuleDetailScreen(module: module),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// REUSABLE SKILL MODULE CARD WIDGET
// =============================================================================

class SkillModuleCard extends StatelessWidget {
  final SkillModuleModel module;
  final int completedCount;
  final int totalRecipesCount;
  final VoidCallback? onTap;

  const SkillModuleCard({
    super.key,
    required this.module,
    required this.completedCount,
    required this.totalRecipesCount,
    this.onTap,
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
          onTap: onTap,
          child: Stack(
            children: [
              // --- 1. BACKGROUND IMAGE WITH SAFE FALLBACK ---
              Image.asset(
                module.coverImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
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
                      Colors.black.withValues(alpha: 0.75),
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
                    // Badge Row (Displays Difficulty Level e.g. "BEGINNER")
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
                        // Small icon indicating it's open/ready
                        const Icon(
                          Icons.menu_book, // Valid Flutter Material Icon
                          color: AppColors.terracottaAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      module.title,
                      style: const TextStyle(
                        color: AppColors.creamBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Text (Total completion across all tiers)
                    Text(
                      '$completedCount / $totalRecipesCount Completed',
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
        size: 48,
        color: AppColors.oliveSecondary,
      ),
    );
  }
}