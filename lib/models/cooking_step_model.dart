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

  /// Factory constructor to parse JSON Map into CookingStepModel
  factory CookingStepModel.fromMap(Map<String, dynamic> map) {
    return CookingStepModel(
      stepNumber: map['stepNumber'] ?? 1,
      instructionText: map['instructionText'] ?? '',
      timerSeconds: map['timerSeconds'] ?? 0,
      title: map['title'] ?? '',
      importantTip: map['importantTip'] as String?,
    );
  }
}