import 'package:flutter_app/models/health_assessment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment maps every API field without renaming values', () {
    final assessment = HealthAssessmentModel(
      age: 50,
      gender: 'Male',
      cholesterol: 200,
      bloodPressure: 120,
      heartRate: 75,
      smoking: 'Never',
      alcoholIntake: 'Unknown',
      exerciseHours: 2,
      familyHistory: 'Yes',
      diabetes: 'No',
      obesity: 'No',
      stressLevel: 5,
      bloodSugar: 100,
      exerciseInducedAngina: 'No',
      chestPainType: 'Typical Angina',
    );

    expect(assessment.toJson(), {
      'Age': 50,
      'Gender': 'Male',
      'Cholesterol': 200,
      'Blood_Pressure': 120,
      'Heart_Rate': 75,
      'Smoking': 'Never',
      'Alcohol_Intake': 'Unknown',
      'Exercise_Hours': 2,
      'Family_History': 'Yes',
      'Diabetes': 'No',
      'Obesity': 'No',
      'Stress_Level': 5,
      'Blood_Sugar': 100,
      'Exercise_Induced_Angina': 'No',
      'Chest_Pain_Type': 'Typical Angina',
    });
  });

  test('v2 categorical options preserve the production string contract', () {
    expect(smokingOptions, ['Current', 'Former', 'Never']);
    expect(alcoholIntakeOptions, ['Heavy', 'Moderate', 'Unknown']);
    expect(chestPainTypeOptions, [
      'Typical Angina',
      'Atypical Angina',
      'Non-anginal Pain',
      'Asymptomatic',
    ]);
  });
}
