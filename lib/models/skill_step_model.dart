class SkillStepModel {
  final String title;
  final String description;
  final String? imagePath; // 👈 Optional image path (can be null!)

  const SkillStepModel({
    required this.title,
    required this.description,
    this.imagePath,
  });
}