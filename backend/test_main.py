"""Regression tests for API validation, risk bands, and model artifacts."""

import unittest

import joblib
from fastapi.testclient import TestClient
from pydantic import ValidationError
from sklearn.pipeline import Pipeline

from backend.main import (
    FEATURE_COLUMNS,
    PIPELINE_V2_PATH,
    PatientData,
    app,
    classify_risk,
    health,
)

client = TestClient(app)


def valid_v1_payload(**overrides):
    """Build a valid legacy request and selectively replace test fields."""

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
    return values


def valid_v2_payload(**overrides):
    """Build a valid categorical request and selectively replace test fields."""

    values = {
        "Age": 50,
        "Gender": "Male",
        "Cholesterol": 200,
        "Blood_Pressure": 120,
        "Heart_Rate": 75,
        "Smoking": "Never",
        "Alcohol_Intake": "Unknown",
        "Exercise_Hours": 2,
        "Family_History": "No",
        "Diabetes": "No",
        "Obesity": "No",
        "Stress_Level": 5,
        "Blood_Sugar": 100,
        "Exercise_Induced_Angina": "No",
        "Chest_Pain_Type": "Typical Angina",
    }
    values.update(overrides)
    return values


class RiskClassificationTests(unittest.TestCase):
    """Verify public health reporting and probability-to-risk thresholds."""

    def test_risk_thresholds(self):
        self.assertEqual(classify_risk(0)[0], "Very Low Risk")
        self.assertEqual(classify_risk(24.99)[0], "Very Low Risk")
        self.assertEqual(classify_risk(25)[0], "Low Risk")
        self.assertEqual(classify_risk(50)[0], "Moderate Risk")
        self.assertEqual(classify_risk(75)[0], "High Risk")
        self.assertEqual(classify_risk(100)[0], "High Risk")

    def test_health_reports_both_artifacts(self):
        response = health()
        self.assertEqual(response["status"], "healthy")
        self.assertEqual(response["model"], "Random Forest")
        self.assertTrue(response["artifacts"]["v1"])
        self.assertTrue(response["artifacts"]["v2"])


class V1CompatibilityTests(unittest.TestCase):
    """Protect the original endpoint contract from unintended regressions."""

    def test_existing_patient_validation_still_accepts_v1_contract(self):
        patient = PatientData(**valid_v1_payload(Age=18, Stress_Level=10))
        self.assertEqual(patient.Age, 18)
        self.assertEqual(patient.Stress_Level, 10)

    def test_existing_predict_endpoint_still_works(self):
        response = client.post("/predict", json=valid_v1_payload())
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["model"], "Random Forest")

    def test_v1_rejects_out_of_range_age(self):
        with self.assertRaises(ValidationError):
            PatientData(**valid_v1_payload(Age=17))

    def test_v1_rejects_invalid_binary_value(self):
        with self.assertRaises(ValidationError):
            PatientData(**valid_v1_payload(Smoking=2))


class PipelineV2ArtifactTests(unittest.TestCase):
    """Verify that the deployed pipeline exists and preserves its input schema."""

    def test_v2_pipeline_artifact_exists_and_loads(self):
        self.assertTrue(PIPELINE_V2_PATH.is_file())
        loaded_pipeline = joblib.load(PIPELINE_V2_PATH)
        self.assertIsInstance(loaded_pipeline, Pipeline)

    def test_v2_pipeline_preserves_raw_feature_contract(self):
        loaded_pipeline = joblib.load(PIPELINE_V2_PATH)
        self.assertEqual(list(loaded_pipeline.feature_names_in_), FEATURE_COLUMNS)


class PredictionV2Tests(unittest.TestCase):
    """Exercise accepted categories and rejected V2 request variations."""

    def assert_valid_prediction(self, payload):
        response = client.post("/predict/v2", json=payload)
        self.assertEqual(response.status_code, 200, response.text)
        body = response.json()
        self.assertTrue(
            {"prediction", "risk_level", "probability", "recommendation"}
            <= body.keys()
        )
        self.assertGreaterEqual(body["probability"], 0)
        self.assertLessEqual(body["probability"], 100)
        self.assertEqual(body["model"], "Random Forest Pipeline v2")

    def test_valid_v2_request(self):
        self.assert_valid_prediction(valid_v2_payload())

    def test_every_smoking_value(self):
        for value in ("Current", "Former", "Never"):
            with self.subTest(value=value):
                self.assert_valid_prediction(valid_v2_payload(Smoking=value))

    def test_every_alcohol_value(self):
        for value in ("Heavy", "Moderate", "Unknown"):
            with self.subTest(value=value):
                self.assert_valid_prediction(
                    valid_v2_payload(Alcohol_Intake=value)
                )

    def test_every_chest_pain_value(self):
        for value in (
            "Asymptomatic",
            "Atypical Angina",
            "Non-anginal Pain",
            "Typical Angina",
        ):
            with self.subTest(value=value):
                self.assert_valid_prediction(
                    valid_v2_payload(Chest_Pain_Type=value)
                )

    def test_old_integer_categories_are_rejected(self):
        response = client.post(
            "/predict/v2",
            json=valid_v2_payload(
                Gender=1,
                Smoking=0,
                Alcohol_Intake=0,
                Family_History=0,
                Diabetes=0,
                Obesity=0,
                Exercise_Induced_Angina=0,
                Chest_Pain_Type=0,
            ),
        )
        self.assertEqual(response.status_code, 422)

    def test_unsupported_category_is_rejected(self):
        response = client.post(
            "/predict/v2",
            json=valid_v2_payload(Smoking="Occasional"),
        )
        self.assertEqual(response.status_code, 422)

    def test_incorrect_capitalization_is_rejected(self):
        response = client.post(
            "/predict/v2",
            json=valid_v2_payload(Smoking="never"),
        )
        self.assertEqual(response.status_code, 422)

    def test_missing_field_is_rejected(self):
        payload = valid_v2_payload()
        del payload["Smoking"]
        response = client.post("/predict/v2", json=payload)
        self.assertEqual(response.status_code, 422)


if __name__ == "__main__":
    unittest.main()
