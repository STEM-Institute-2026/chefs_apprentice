import 'package:charles_flutter_app_main/models/skill_step_model.dart';
import 'package:flutter/material.dart';

class SkillModel {
  final String id;
  final String name;
  final String shortDescription;
  final IconData icon; 
  final String? videoUrl; // Short demonstration video/GIF
  final List<SkillStepModel> coreSteps; // Step-by-step instructions or key techniques
  final List<String> keyTypesOrCuts; // e.g. types of cuts, types of heat, or variations
  final List<String> safetyOrProTips; // Safety rules or expert advice
  final String whereItsUsed; // Practical context (e.g. "Onions, garlic, stews")

  const SkillModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.icon,
    this.videoUrl,
    required this.coreSteps,
    required this.keyTypesOrCuts,
    required this.safetyOrProTips,
    required this.whereItsUsed,
  });
}