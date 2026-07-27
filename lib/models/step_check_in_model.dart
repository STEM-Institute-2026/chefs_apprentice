class StepCheckInModel {
  final String question;
  final List<String> options;
  final Map<String, String> tipResponses;

  StepCheckInModel({
    required this.question,
    required this.options,
    required this.tipResponses,
  });
}