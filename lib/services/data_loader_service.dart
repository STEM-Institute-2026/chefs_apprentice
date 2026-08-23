import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class AppData {
  final List<RecipeModel> recipes;
  final List<TierModel> tiers;

  AppData({
    required this.recipes,
    required this.tiers,
  });
}

class DataLoaderService {
  static Future<AppData> loadInitialData() async {
    // 1. Load raw recipes JSON
    final String recipesString = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> recipesJson = jsonDecode(recipesString);
    
    // Parse into RecipeModel objects
    final List<RecipeModel> recipes = recipesJson
        .map((map) => RecipeModel.fromMap(map as Map<String, dynamic>))
        .toList();

    // 2. Load raw tiers JSON
    final String tiersString = await rootBundle.loadString('assets/data/tiers.json');
    final List<dynamic> tiersJson = jsonDecode(tiersString);

    // Parse into TierModel objects, resolving recipes matching recipeIds
    final List<TierModel> tiers = tiersJson.map((map) {
      return TierModel.fromMap(
        map as Map<String, dynamic>,
        recipes, // Pass loaded recipes here to resolve relationships
      );
    }).toList();

    return AppData(
      recipes: recipes,
      tiers: tiers,
    );
  }
}