import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class AppData {
  final List<RecipeModel> recipes;
  final List<SkillModuleModel> skillModules;
  final List<CuisineModuleModel> cuisineModules;
  final List<BadgeModel> badges;

  AppData({
    required this.recipes,
    required this.skillModules,
    required this.cuisineModules,
    required this.badges,
  });
}

class DataLoaderService {
  // 1. Private variable to store the loaded data in memory
  static AppData? _cachedData;

  static Future<AppData> loadInitialData() async {
    // 2. Return cached data immediately if it's already loaded
    if (_cachedData != null) {
      return _cachedData!;
    }

    // 1. Load raw recipes JSON
    final String recipesString =
        await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> recipesJson = jsonDecode(recipesString);

    // Parse into RecipeModel objects
    final List<RecipeModel> recipes = recipesJson
        .map((map) => RecipeModel.fromMap(map as Map<String, dynamic>))
        .toList();

    // 2. Load skills JSON
    final String skillsString =
        await rootBundle.loadString('assets/data/skills.json');
    final List<dynamic> skillsJson = jsonDecode(skillsString);

    // Parse into SkillModuleModel objects
    final List<SkillModuleModel> skillModules = skillsJson.map((map) {
      return SkillModuleModel.fromMap(
        map as Map<String, dynamic>,
        recipes,
      );
    }).toList();

    // 3. Load cuisines JSON
    final String cuisinesString =
        await rootBundle.loadString('assets/data/cuisines.json');
    final List<dynamic> cuisinesJson = jsonDecode(cuisinesString);

    // Parse into CuisineModuleModel objects
    final List<CuisineModuleModel> cuisineModules = cuisinesJson.map((map) {
      return CuisineModuleModel.fromMap(
        map as Map<String, dynamic>,
        recipes,
      );
    }).toList();

    // 4. Load badges JSON
    final String badgesString =
        await rootBundle.loadString('assets/data/badges.json');
    final List<dynamic> badgesJson = jsonDecode(badgesString);

    // Parse into BadgeModel objects
    final List<BadgeModel> badges = badgesJson
        .map((map) => BadgeModel.fromMap(map as Map<String, dynamic>))
        .toList();

    // 3. Store the parsed result in the cache before returning
    _cachedData = AppData(
      recipes: recipes,
      skillModules: skillModules,
      cuisineModules: cuisineModules,
      badges: badges,
    );

    return _cachedData!;
  }

  // Optional: Call this if you ever need to clear memory or force a re-fetch
  static void clearCache() {
    _cachedData = null;
  }
}