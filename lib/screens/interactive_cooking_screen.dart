import 'package:flutter/material.dart';
import "../models/models.dart";
import 'recipe_complete_screen.dart';
import 'widgets/header_and_app_bar.dart';
import '../constants/app_transitions.dart'; // Import your custom transitions

class InteractiveCookingScreen extends StatefulWidget {
  final RecipeModel recipe;

  const InteractiveCookingScreen({super.key, required this.recipe});

  @override
  State<InteractiveCookingScreen> createState() => _InteractiveCookingScreenState();
}

class _InteractiveCookingScreenState extends State<InteractiveCookingScreen> {
  int currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.recipe.steps[currentStepIndex];

    return Scaffold(
      appBar: CustomAppBar(title: widget.recipe.title),
      body: Column(
        children: [
          // ---------------- TOP HALF (CREAM) ----------------
          Expanded(
            child: Container(
              color: AppColors.creamBackground,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey<int>(currentStepIndex),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      
                      // 1. Terracotta Pop for Step Label
                      Text(
                        'STEP ${currentStep.stepNumber}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracottaAccent, // 👈 Terracotta Accent
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),

                      // 2. Bold Olive for Step Title
                      Text(
                        currentStep.title,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.oliveSecondary, // 👈 Olive Header
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),

                      // 3. Readable Olive for Instruction Text
                      Text(
                        currentStep.instructionText,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.4,
                          color: AppColors.oliveSecondary, // 👈 Olive Body Text
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ---------------- BOTTOM HALF (OLIVE) ----------------
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (currentStepIndex < widget.recipe.steps.length - 1) {
                    currentStepIndex++;
                  } else {
                    Navigator.pushReplacement(
                      context,
                      ScalePopRoute(
                        page: RecipeCompleteScreen(recipe: widget.recipe),
                      ),
                    );
                  }
                });
              },
              child: Container(
                width: double.infinity,
                color: AppColors.oliveSecondary,
                child: Center(
                  child: Text(
                    currentStepIndex < widget.recipe.steps.length - 1
                        ? 'Completed this Step!'
                        : 'Finish! 🎉',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.creamBackground, // 👈 Cream Text on Olive
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}