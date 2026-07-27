import 'package:flutter/material.dart';
// 1. Import your mock data file
import 'mock_data.dart'; 
// 2. Import your screen file
import 'custom_widgets/recipe_catalog_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cooking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // 3. Set home to your detail screen and pass in mockRecipe!
      home: RecipeCatalogScreen(recipes: mockRecipes),
    );
  }
}