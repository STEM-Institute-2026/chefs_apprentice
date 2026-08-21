class CookingStepModel {
  final int stepNumber;
  final String instructionText;
  final int timerSeconds;
  final String title;
  final String? importantTip; // 👈 Mark as nullable with ?

  CookingStepModel({
    required this.stepNumber,
    required this.instructionText,
    required this.timerSeconds,
    required this.title,
    this.importantTip, // 👈 Defaults to null if omitted
  });
}