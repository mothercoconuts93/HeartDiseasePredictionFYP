const genderOptions = ['Female', 'Male'];
const smokingOptions = ['Current', 'Former', 'Never'];
const alcoholIntakeOptions = ['Heavy', 'Moderate', 'Unknown'];
const yesNoOptions = ['No', 'Yes'];
const chestPainTypeOptions = [
  'Typical Angina',
  'Atypical Angina',
  'Non-anginal Pain',
  'Asymptomatic',
];

class HealthAssessmentModel {
  final int age;
  final String gender;
  final int cholesterol;
  final int bloodPressure;
  final int heartRate;
  final String smoking;
  final String alcoholIntake;
  final int exerciseHours;
  final String familyHistory;
  final String diabetes;
  final String obesity;
  final int stressLevel;
  final int bloodSugar;
  final String exerciseInducedAngina;
  final String chestPainType;

  HealthAssessmentModel({
    required this.age,
    required this.gender,
    required this.cholesterol,
    required this.bloodPressure,
    required this.heartRate,
    required this.smoking,
    required this.alcoholIntake,
    required this.exerciseHours,
    required this.familyHistory,
    required this.diabetes,
    required this.obesity,
    required this.stressLevel,
    required this.bloodSugar,
    required this.exerciseInducedAngina,
    required this.chestPainType,
  });

  Map<String, dynamic> toJson() {
    return {
      "Age": age,
      "Gender": gender,
      "Cholesterol": cholesterol,
      "Blood_Pressure": bloodPressure,
      "Heart_Rate": heartRate,
      "Smoking": smoking,
      "Alcohol_Intake": alcoholIntake,
      "Exercise_Hours": exerciseHours,
      "Family_History": familyHistory,
      "Diabetes": diabetes,
      "Obesity": obesity,
      "Stress_Level": stressLevel,
      "Blood_Sugar": bloodSugar,
      "Exercise_Induced_Angina": exerciseInducedAngina,
      "Chest_Pain_Type": chestPainType,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}
