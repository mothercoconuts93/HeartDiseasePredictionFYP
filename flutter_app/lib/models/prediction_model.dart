// Persistent representation of a prediction returned by FastAPI.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the prediction result saved in the `predictions` collection.
class PredictionModel {
  final String predictionId;
  final String userId;

  final int prediction;

  final String riskLevel;

  final double probability;

  final String recommendation;

  final DateTime createdAt;

  PredictionModel({
    required this.predictionId,
    required this.userId,
    required this.prediction,
    required this.riskLevel,
    required this.probability,
    required this.recommendation,
    required this.createdAt,
  });

  /// Serializes the prediction using the deployed Firestore field names.
  Map<String, dynamic> toMap() {
    return {
      'predictionId': predictionId,
      'userId': userId,
      'prediction': prediction,
      'riskLevel': riskLevel,
      'probability': probability,
      'recommendation': recommendation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Reconstructs a prediction from a Firestore document map.
  factory PredictionModel.fromMap(Map<String, dynamic> map) {
    return PredictionModel(
      predictionId: map['predictionId'] ?? '',
      userId: map['userId'] ?? '',
      prediction: _toInt(map['prediction']),
      riskLevel: map['riskLevel'] ?? '',
      probability: _toDouble(map['probability']),
      recommendation: map['recommendation'] ?? '',
      createdAt: _toDateTime(map['createdAt']),
    );
  }

  /// Accepts integer-like Firestore values without making reads type-fragile.
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Accepts numeric or string probability values from existing documents.
  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Supports Firestore timestamps and the ISO strings written by this app.
  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
