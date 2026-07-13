import 'package:flutter_app/models/health_assessment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment maps every API field without renaming values', () {
    final assessment = HealthAssessmentModel(
      age: 50,
      gender: 1,
      cholesterol: 200,
      bloodPressure: 120,
      heartRate: 75,
      smoking: 0,
      alcoholIntake: 0,
      exerciseHours: 2,
      familyHistory: 1,
      diabetes: 0,
      obesity: 0,
      stressLevel: 5,
      bloodSugar: 100,
      exerciseInducedAngina: 0,
      chestPainType: 1,
    );

    expect(assessment.toJson(), {
      'Age': 50,
      'Gender': 1,
      'Cholesterol': 200,
      'Blood_Pressure': 120,
      'Heart_Rate': 75,
      'Smoking': 0,
      'Alcohol_Intake': 0,
      'Exercise_Hours': 2,
      'Family_History': 1,
      'Diabetes': 0,
      'Obesity': 0,
      'Stress_Level': 5,
      'Blood_Sugar': 100,
      'Exercise_Induced_Angina': 0,
      'Chest_Pain_Type': 1,
    });
  });
}
