import 'package:cloud_firestore/cloud_firestore.dart';

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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
