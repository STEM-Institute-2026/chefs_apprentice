
class CookingPreferencesModel {
  /// User's self-reported cooking skill level (1–3).
  final int cookingSkillTier;

  /// Cuisines the user enjoys, e.g. ['Japanese', 'Italian'].
  final List<String> favoriteCuisines;

  /// Allergies reported by the user, e.g. ['Peanuts', 'Shellfish'].
  final List<String> allergies;

  /// Ingredients the user would like to cook with.
  final List<String> preferredIngredients;

  /// Maximum preferred total recipe cooking time, in minutes.
  /// Null means the user has no specific time preference.
  final int? maxCookTimeMinutes;

  const CookingPreferencesModel({
    this.cookingSkillTier = 1,
    this.favoriteCuisines = const [],
    this.allergies = const [],
    this.preferredIngredients = const [],
    this.maxCookTimeMinutes,
  });

  /// Creates a model from data stored in Firestore.
  factory CookingPreferencesModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CookingPreferencesModel(
      cookingSkillTier: _parseSkillTier(map['cookingSkillTier']),
      favoriteCuisines: _parseStringList(map['favoriteCuisines']),
      allergies: _parseStringList(map['allergies']),
      preferredIngredients: _parseStringList(
        map['preferredIngredients'],
      ),
      maxCookTimeMinutes: _parseOptionalPositiveInt(
        map['maxCookTimeMinutes'],
      ),
    );
  }

  /// Converts the model into data suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'cookingSkillTier': cookingSkillTier,
      'favoriteCuisines': favoriteCuisines,
      'allergies': allergies,
      'preferredIngredients': preferredIngredients,
      'maxCookTimeMinutes': maxCookTimeMinutes,
    };
  }

  /// Creates a copy with selected fields changed.
  CookingPreferencesModel copyWith({
    int? cookingSkillTier,
    List<String>? favoriteCuisines,
    List<String>? allergies,
    List<String>? preferredIngredients,
    int? maxCookTimeMinutes,
    bool clearMaxCookTime = false,
  }) {
    return CookingPreferencesModel(
      cookingSkillTier: _parseSkillTier(
        cookingSkillTier ?? this.cookingSkillTier,
      ),
      favoriteCuisines: List<String>.from(
        favoriteCuisines ?? this.favoriteCuisines,
      ),
      allergies: List<String>.from(
        allergies ?? this.allergies,
      ),
      preferredIngredients: List<String>.from(
        preferredIngredients ?? this.preferredIngredients,
      ),
      maxCookTimeMinutes: clearMaxCookTime
          ? null
          : _parseOptionalPositiveInt(
              maxCookTimeMinutes ?? this.maxCookTimeMinutes,
            ),
    );
  }

  static int _parseSkillTier(dynamic value) {
    final tier = value is num ? value.toInt() : 1;
    return tier.clamp(1, 3);
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  static int? _parseOptionalPositiveInt(dynamic value) {
    if (value == null) return null;

    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value.toString());

    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
