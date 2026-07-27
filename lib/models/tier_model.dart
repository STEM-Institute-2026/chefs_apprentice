class TierModel {
  final int tierNumber;
  final String tierTitle;
  final String tierSubtitle;
  final double progress;
  final bool isLocked;
  final int totalLessons;
  final int completedLessons;
  final int totalRecipes;
  final int completedRecipes;

  TierModel({
    required this.tierNumber,
    required this.tierTitle,
    required this.tierSubtitle,
    required this.progress,
    required this.isLocked,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalRecipes,
    required this.completedRecipes,
  });
}