import 'package:cloud_firestore/cloud_firestore.dart';

class CookedHistoryModel {
  final String entryId;
  final String recipeId;
  final String recipeTitle;
  final String imagePath; // Can be a web URL (mock data) or local file path (camera)
  final DateTime dateCooked;
  final double? costSaved;
  final int? rating; // Added rating here so stars can be saved!

  CookedHistoryModel({
    required this.entryId,
    required this.recipeId,
    required this.recipeTitle,
    required this.imagePath,
    required this.dateCooked,
    this.costSaved,
    this.rating,
  });

  /// Convert Map (from Firestore/JSON) into CookedHistoryModel
  factory CookedHistoryModel.fromMap(Map<String, dynamic> map) {
  return CookedHistoryModel(
    entryId: map['entryId'] ?? '',
    recipeId: map['recipeId'] ?? '',
    recipeTitle: map['recipeTitle'] ?? '',
    imagePath: map['imagePath'] ?? '',
    dateCooked: map['dateCooked'] is Timestamp
        ? (map['dateCooked'] as Timestamp).toDate()
        : map['dateCooked'] != null
            ? DateTime.tryParse(map['dateCooked'].toString()) ?? DateTime.now()
            : DateTime.now(),
    costSaved: (map['costSaved'] as num?)?.toDouble(),
    rating: map['rating'] as int?,
  );
}

  /// Convert CookedHistoryModel into Map for Firestore upload
  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'imagePath': imagePath,
      'dateCooked': dateCooked.toIso8601String(),
      'costSaved': costSaved,
      'rating': rating,
    };
  }
}