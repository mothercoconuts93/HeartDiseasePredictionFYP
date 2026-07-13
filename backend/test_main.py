import unittest

from pydantic import ValidationError

from backend.main import PatientData, classify_risk, health


class RiskClassificationTests(unittest.TestCase):
    def test_risk_thresholds(self):
        self.assertEqual(classify_risk(0)[0], "Very Low Risk")
        self.assertEqual(classify_risk(24.99)[0], "Very Low Risk")
        self.assertEqual(classify_risk(25)[0], "Low Risk")
        self.assertEqual(classify_risk(50)[0], "Moderate Risk")
        self.assertEqual(classify_risk(75)[0], "High Risk")
        self.assertEqual(classify_risk(100)[0], "High Risk")

    def test_health_response(self):
        response = health()
        self.assertEqual(response["status"], "healthy")
        self.assertEqual(response["model"], "Random Forest")


class PatientValidationTests(unittest.TestCase):
    def valid_patient(self, **overrides):
        values = {
            "Age": 50,
            "Gender": 1,
            "Cholesterol": 200,
            "Blood_Pressure": 120,
            "Heart_Rate": 75,
            "Smoking": 0,
            "Alcohol_Intake": 0,
            "Exercise_Hours": 2,
            "Family_History": 0,
            "Diabetes": 0,
            "Obesity": 0,
            "Stress_Level": 5,
            "Blood_Sugar": 100,
            "Exercise_Induced_Angina": 0,
            "Chest_Pain_Type": 0,
        }
        values.update(overrides)
        return PatientData(**values)

    def test_valid_boundary_values(self):
        patient = self.valid_patient(Age=18, Stress_Level=10)
        self.assertEqual(patient.Age, 18)
        self.assertEqual(patient.Stress_Level, 10)

    def test_rejects_out_of_range_age(self):
        with self.assertRaises(ValidationError):
            self.valid_patient(Age=17)

    def test_rejects_invalid_binary_value(self):
        with self.assertRaises(ValidationError):
            self.valid_patient(Smoking=2)


if __name__ == "__main__":
    unittest.main()
