class SkillStepModel {
  final String title;
  final String description;
  final String? imagePath; // 👈 Optional image path (can be null!)

  const SkillStepModel({
    required this.title,
    required this.description,
    this.imagePath,
  });

  /// Factory constructor to parse JSON Map into SkillStepModel
  factory SkillStepModel.fromMap(Map<String, dynamic> map) {
    return SkillStepModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }
}