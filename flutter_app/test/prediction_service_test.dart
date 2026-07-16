import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/models/health_assessment_model.dart';
import 'package:flutter_app/services/prediction_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  HealthAssessmentModel assessment() {
    return HealthAssessmentModel(
      age: 50,
      gender: 'Female',
      cholesterol: 200,
      bloodPressure: 120,
      heartRate: 75,
      smoking: 'Former',
      alcoholIntake: 'Moderate',
      exerciseHours: 2,
      familyHistory: 'Yes',
      diabetes: 'No',
      obesity: 'No',
      stressLevel: 5,
      bloodSugar: 100,
      exerciseInducedAngina: 'No',
      chestPainType: 'Asymptomatic',
    );
  }

  test('prediction service posts string categories to predict v2', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'prediction': 0,
          'risk_level': 'Very Low Risk',
          'probability': 10.0,
          'recommendation': 'Continue healthy habits.',
          'model': 'Random Forest Pipeline v2',
          'status': 'Prediction Completed Successfully',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = PredictionService(client: client);
    await service.predictHeartDisease(assessment());

    expect(capturedRequest.url.path, '/predict/v2');
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(body['Gender'], 'Female');
    expect(body['Smoking'], 'Former');
    expect(body['Alcohol_Intake'], 'Moderate');
    expect(body['Family_History'], 'Yes');
    expect(body['Exercise_Induced_Angina'], 'No');
    expect(body['Chest_Pain_Type'], 'Asymptomatic');
    expect(body['Age'], isA<int>());
    expect(body['Cholesterol'], isA<int>());
    expect(body['Stress_Level'], isA<int>());
  });

  test('prediction screen no longer contains manual category encoders', () {
    final source = File(
      'lib/screens/patient/prediction_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('yesNoToInt')));
    expect(source, isNot(contains('genderToInt')));
    expect(source, isNot(contains('chestPainToInt')));
  });
}
