// lib/utils/app_transitions.dart
import 'package:flutter/material.dart';

/// 1. STANDARD DETAIL ROUTE (Slide 5% Up + Fade)
/// Use for: Recipe Card -> Detail, Tier Card -> Detail, History Item -> Detail
class StandardDetailRoute extends PageRouteBuilder {
  final Widget page;

  StandardDetailRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05), // Gentle upward nudge
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(
                opacity: curve,
                child: child,
              ),
            );
          },
        );
}

/// 2. MODAL SLIDE-UP ROUTE (Slides full height from bottom)
/// Use for: Recipe Detail -> Interactive Guided Cooking Screen
class ModalSlideUpRoute extends PageRouteBuilder {
  final Widget page;

  ModalSlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0), // Starts at screen bottom
                end: Offset.zero,
              ).animate(curve),
              child: child,
            );
          },
        );
}

/// 3. SCALE POP ROUTE (Slight scale up + energetic fade)
/// Use for: Recipe Detail -> Recipe Complete Screen
class ScalePopRoute extends PageRouteBuilder {
  final Widget page;

  ScalePopRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack, // Playful pop effect
            );

            return ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}