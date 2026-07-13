import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/health_assessment_model.dart';

class PredictionServiceException implements Exception {
  final String message;

  const PredictionServiceException(this.message);

  @override
  String toString() => message;
}

class PredictionService {
  String get baseUrl {
    const configuredUrl = String.fromEnvironment('CARDIOGUARD_API_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  Future<Map<String, dynamic>> predictHeartDisease(
    HealthAssessmentModel assessment,
  ) async {
    final Uri url = Uri.parse('$baseUrl/predict');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(assessment.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic> ||
            !decoded.containsKey('risk_level') ||
            !decoded.containsKey('probability')) {
          throw const PredictionServiceException(
            'The prediction server returned an unexpected response.',
          );
        }
        return decoded;
      }

      if (response.statusCode == 422) {
        throw const PredictionServiceException(
          'One or more assessment values were rejected. Review the form and try again.',
        );
      }

      throw PredictionServiceException(
        'The prediction service is unavailable (error ${response.statusCode}). Please try again.',
      );
    } on TimeoutException {
      throw const PredictionServiceException(
        'The prediction request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const PredictionServiceException(
        'Unable to connect to the prediction service. Check that the backend is running.',
      );
    } on FormatException {
      throw const PredictionServiceException(
        'The prediction server returned an unreadable response.',
      );
    } on PredictionServiceException {
      rethrow;
    } catch (_) {
      throw const PredictionServiceException(
        'Prediction could not be completed. Please try again.',
      );
    }
  }
}
