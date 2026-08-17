import 'package:flutter/material.dart';
import 'screens/main_shell_screen.dart';
import 'mock_data.dart'; // Import where your recipe mock data lives
import './models/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chef's Apprentice",
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.creamBackground,
      ),
      // 👈 Pointing home to MainShellScreen!
      home: MainShellScreen(recipes: mockRecipes, userProfile: mockUserProfile), 
    );
  }
}