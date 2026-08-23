class LessonModel {
  final String lessonId;
  final String title;
  final int estimatedMinutes;
  final bool isCompleted;
  final bool isLocked;

  LessonModel({
    required this.lessonId,
    required this.title,
    required this.estimatedMinutes,
    required this.isCompleted,
    required this.isLocked,
  });

  /// Factory constructor to parse JSON Map into LessonModel
  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      lessonId: map['lessonId'] ?? '',
      title: map['title'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isLocked: map['isLocked'] ?? true,
    );
  }
}