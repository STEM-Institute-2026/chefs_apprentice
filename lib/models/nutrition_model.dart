class NutritionModel {
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const NutritionModel({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  // Helper getters to quickly format badge text in your UI!
  String get caloriesText => '$calories kcal';
  String get proteinText => '${proteinGrams}g';
  String get carbsText => '${carbsGrams}g';
  String get fatText => '${fatGrams}g';
}