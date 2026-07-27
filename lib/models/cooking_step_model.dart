import 'step_check_in_model.dart';

class CookingStepModel {
  final int stepNumber;
  final String instructionText;
  final int timerSeconds;
  final StepCheckInModel? checkIn;
  final String title;

  CookingStepModel({
    required this.stepNumber,
    required this.instructionText,
    required this.timerSeconds,
    required this.title,
    this.checkIn,
  });
}