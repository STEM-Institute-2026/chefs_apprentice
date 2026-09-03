import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';


class AppData {
  final List<RecipeModel> recipes;
  final List<SkillModuleModel> skillModules;
  final List<CuisineModuleModel> cuisineModules;

  AppData({
    required this.recipes,
    required this.skillModules,
    required this.cuisineModules,
  });
}

class DataLoaderService {
  static Future<AppData> loadInitialData() async {
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

    return AppData(
      recipes: recipes,
      skillModules: skillModules,
      cuisineModules: cuisineModules,
    );
  }
}