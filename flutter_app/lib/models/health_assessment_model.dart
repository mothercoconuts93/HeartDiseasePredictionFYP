class HealthAssessmentModel {
  final int age;
  final int gender;
  final int cholesterol;
  final int bloodPressure;
  final int heartRate;
  final int smoking;
  final int alcoholIntake;
  final int exerciseHours;
  final int familyHistory;
  final int diabetes;
  final int obesity;
  final int stressLevel;
  final int bloodSugar;
  final int exerciseInducedAngina;
  final int chestPainType;

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
