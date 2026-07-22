// Presentation state for API inference and Firestore prediction persistence.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/health_assessment_model.dart';
import '../models/prediction_model.dart';
import '../services/firestore_service.dart';
import '../services/prediction_service.dart';

/// Coordinates the assessment-to-API-to-Firestore prediction workflow.
class PredictionProvider extends ChangeNotifier {
  final PredictionService _predictionService = PredictionService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  String? errorMessage;

  PredictionModel? latestPrediction;

  /// Exposes a real-time history stream for the authenticated Patient.
  Stream<List<PredictionModel>> getPredictionHistory(String userId) {
    return _firestoreService.getPredictionsByUser(userId);
  }

  /// Runs inference, creates a persistent result, and reports overall success.
  ///
  /// A successful return means both the API call and Firestore save completed.
  Future<bool> runPrediction({
    required String userId,
    required HealthAssessmentModel assessment,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await _predictionService.predictHeartDisease(assessment);

      final prediction = PredictionModel(
        predictionId: const Uuid().v4(),
        userId: userId,
        prediction: result['prediction'] ?? 0,
        riskLevel: result['risk_level'] ?? 'Unknown Risk',
        probability: (result['probability'] ?? 0).toDouble(),
        recommendation:
            result['recommendation'] ??
            'Please consult a healthcare professional for further advice.',
        createdAt: DateTime.now(),
      );

      await _firestoreService.savePrediction(prediction);

      latestPrediction = prediction;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }
}
