import 'package:flutter/material.dart';
import "../models/models.dart";
import 'recipe_complete_screen.dart';
import 'widgets/header_and_app_bar.dart';
import '../constants/app_transitions.dart';

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
          // ---------------- TOP HALF (CREAM - 50%) ----------------
          Expanded(
            flex: 6,
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      
                      // 1. Step Label
                      Text(
                        'STEP ${currentStep.stepNumber}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracottaAccent,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),

                      // 2. Step Title
                      Text(
                        currentStep.title,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.oliveSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),

                      // 3. Instruction Text
                      Text(
                        currentStep.instructionText,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.4,
                          color: AppColors.oliveSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 4. Important Tip Button
                      if (currentStep.importantTip != null && currentStep.importantTip!.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.creamBackground,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.lightbulb_outline_rounded,
                                            color: AppColors.terracottaAccent,
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Pro Tip",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.oliveSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        currentStep.importantTip!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                          color: AppColors.oliveSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.oliveSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.oliveSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.lightbulb_rounded,
                                  color: AppColors.terracottaAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "View Helpful Tip",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.oliveSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ---------------- BOTTOM HALF (OLIVE - 50%) ----------------
          Expanded(
            flex: 4,
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
                      color: AppColors.creamBackground,
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