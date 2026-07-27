class CookedHistoryModel {
  final String entryId;
  final String recipeId;
  final String recipeTitle;
  final String imagePath; // Can be a web URL (mock data) or local file path (camera)
  final DateTime completedAt;
  final double? costSaved;
  final int? rating; // Added rating here so stars can be saved!

  CookedHistoryModel({
    required this.entryId,
    required this.recipeId,
    required this.recipeTitle,
    required this.imagePath,
    required this.completedAt,
    this.costSaved,
    this.rating,
  });
}