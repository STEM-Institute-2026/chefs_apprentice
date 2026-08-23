import 'package:charles_flutter_app_main/models/skill_step_model.dart';
import 'package:flutter/material.dart';

class SkillModel {
  final String id;
  final String name;
  final String shortDescription;
  final IconData icon; 
  final String? videoUrl;
  final List<SkillStepModel> coreSteps;
  final List<String> keyTypesOrCuts;
  final List<String> safetyOrProTips;
  final String whereItsUsed;

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

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      icon: _getIconFromName(map['icon'] as String?),
      videoUrl: map['videoUrl'] as String?,
      coreSteps: (map['coreSteps'] as List<dynamic>?)
              ?.map((step) => SkillStepModel.fromMap(step))
              .toList() ??
          [],
      keyTypesOrCuts: List<String>.from(map['keyTypesOrCuts'] ?? []),
      safetyOrProTips: List<String>.from(map['safetyOrProTips'] ?? []),
      whereItsUsed: map['whereItsUsed'] ?? '',
    );
  }

  /// Maps JSON string keys to Material Icons safely
  static IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'flatware':
        return Icons.flatware;
      case 'soup_kitchen':
        return Icons.soup_kitchen;
      case 'local_fire_department':
        return Icons.local_fire_department;
      default:
        return Icons.restaurant;
    }
  }
}