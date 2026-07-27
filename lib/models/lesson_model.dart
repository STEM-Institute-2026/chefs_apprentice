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
}