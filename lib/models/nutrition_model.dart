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

  /// Factory constructor to parse JSON Map into NutritionModel
  factory NutritionModel.fromMap(Map<String, dynamic> map) {
    return NutritionModel(
      calories: map['calories'] ?? 0,
      proteinGrams: map['proteinGrams'] ?? 0,
      carbsGrams: map['carbsGrams'] ?? 0,
      fatGrams: map['fatGrams'] ?? 0,
    );
  }

  // Helper getters to quickly format badge text in your UI!
  String get caloriesText => '$calories kcal';
  String get proteinText => '${proteinGrams}g';
  String get carbsText => '${carbsGrams}g';
  String get fatText => '${fatGrams}g';
}