"""FastAPI service that validates clinical inputs and serves model inference."""

import logging
import os
from pathlib import Path
from typing import Literal

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger("cardioguard.api")

# Load Trained Model
PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = Path(
    os.getenv("CARDIOGUARD_MODEL_PATH", PROJECT_ROOT / "machine_learning" / "heart_model.pkl")
)
model = joblib.load(MODEL_PATH)

PIPELINE_V2_PATH = Path(
    os.getenv(
        "CARDIOGUARD_PIPELINE_V2_PATH",
        PROJECT_ROOT / "machine_learning" / "heart_pipeline_v2.pkl",
    )
)
try:
    pipeline_v2 = joblib.load(PIPELINE_V2_PATH)
except Exception as error:
    logger.exception("Unable to load Random Forest Pipeline v2: %s", error)
    pipeline_v2 = None

FEATURE_COLUMNS = [
    "Age",
    "Gender",
    "Cholesterol",
    "Blood Pressure",
    "Heart Rate",
    "Smoking",
    "Alcohol Intake",
    "Exercise Hours",
    "Family History",
    "Diabetes",
    "Obesity",
    "Stress Level",
    "Blood Sugar",
    "Exercise Induced Angina",
    "Chest Pain Type",
]

# FastAPI Configuration
app = FastAPI(
    title="CardioGuard Prediction API",
    description="Random Forest Heart Disease Prediction System",
    version="1.0.0",
    contact={
        "name": "Guled Ibrahim"
    }
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "CARDIOGUARD_CORS_ORIGINS",
        "http://localhost,http://localhost:3000,http://localhost:5000",
    ).split(",")
    if origin.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)

# Input Model
class PatientData(BaseModel):
    """Legacy numerical request contract retained for `/predict` compatibility."""

    Age: int = Field(..., ge=18, le=120)
    Gender: int = Field(..., ge=0, le=1)

    Cholesterol: int = Field(..., ge=50, le=500)
    Blood_Pressure: int = Field(..., ge=60, le=250)
    Heart_Rate: int = Field(..., ge=30, le=220)

    Smoking: int = Field(..., ge=0, le=1)
    Alcohol_Intake: int = Field(..., ge=0, le=1)
    Exercise_Hours: int = Field(..., ge=0, le=24)

    Family_History: int = Field(..., ge=0, le=1)
    Diabetes: int = Field(..., ge=0, le=1)
    Obesity: int = Field(..., ge=0, le=1)

    Stress_Level: int = Field(..., ge=1, le=10)

    Blood_Sugar: int = Field(..., ge=50, le=500)

    Exercise_Induced_Angina: int = Field(..., ge=0, le=1)

    Chest_Pain_Type: int = Field(..., ge=0, le=3)


class PatientDataV2(BaseModel):
    """Validated request contract matching the raw categorical pipeline inputs."""

    Age: int = Field(..., ge=18, le=120)
    Gender: Literal["Female", "Male"]

    Cholesterol: int = Field(..., ge=50, le=500)
    Blood_Pressure: int = Field(..., ge=60, le=250)
    Heart_Rate: int = Field(..., ge=30, le=220)

    Smoking: Literal["Current", "Former", "Never"]
    Alcohol_Intake: Literal["Heavy", "Moderate", "Unknown"]
    Exercise_Hours: int = Field(..., ge=0, le=24)

    Family_History: Literal["No", "Yes"]
    Diabetes: Literal["No", "Yes"]
    Obesity: Literal["No", "Yes"]

    Stress_Level: int = Field(..., ge=1, le=10)
    Blood_Sugar: int = Field(..., ge=50, le=500)

    Exercise_Induced_Angina: Literal["No", "Yes"]
    Chest_Pain_Type: Literal[
        "Asymptomatic",
        "Atypical Angina",
        "Non-anginal Pain",
        "Typical Angina",
    ]

# Response Model
class PredictionResponse(BaseModel):
    """Stable response returned to Flutter after successful model inference."""

    prediction: int
    risk_level: str
    probability: float
    recommendation: str
    model: str
    status: str


def classify_risk(probability: float) -> tuple[str, str]:
    """Map a percentage probability to a readable risk band and guidance."""

    if probability >= 75:
        return (
            "High Risk",
            "Consult a cardiologist as soon as possible. "
            "Further clinical evaluation is strongly recommended.",
        )
    if probability >= 50:
        return (
            "Moderate Risk",
            "Schedule a medical check-up and improve lifestyle habits "
            "such as diet and regular exercise.",
        )
    if probability >= 25:
        return (
            "Low Risk",
            "Maintain a healthy lifestyle and continue regular health screening.",
        )
    return (
        "Very Low Risk",
        "Continue healthy habits and attend routine medical check-ups.",
    )

# Home Endpoint
@app.get("/")
def home():
    """Return a lightweight confirmation that the API process is running."""

    return {
        "service": "CardioGuard Prediction API",
        "status": "running",
    }


@app.get("/health")
def health():
    """Report service version and availability of both serialized artifacts."""

    return {
        "status": "healthy",
        "service": "CardioGuard Prediction API",
        "version": app.version,
        "model": "Random Forest",
        "artifacts": {
            "v1": model is not None,
            "v2": pipeline_v2 is not None,
        },
    }

# Prediction Endpoint
@app.post("/predict", response_model=PredictionResponse)
def predict(data: PatientData):
    """Run the legacy model using the original integer-encoded API contract."""

    try:

        patient_data = pd.DataFrame([{
            "Age": data.Age,
            "Gender": data.Gender,
            "Cholesterol": data.Cholesterol,
            "Blood Pressure": data.Blood_Pressure,
            "Heart Rate": data.Heart_Rate,
            "Smoking": data.Smoking,
            "Alcohol Intake": data.Alcohol_Intake,
            "Exercise Hours": data.Exercise_Hours,
            "Family History": data.Family_History,
            "Diabetes": data.Diabetes,
            "Obesity": data.Obesity,
            "Stress Level": data.Stress_Level,
            "Blood Sugar": data.Blood_Sugar,
            "Exercise Induced Angina": data.Exercise_Induced_Angina,
            "Chest Pain Type": data.Chest_Pain_Type

        }])

        prediction = model.predict(patient_data)[0]

        probability = model.predict_proba(patient_data)[0][1]

        probability = round(float(probability) * 100, 2)

        risk_level, recommendation = classify_risk(probability)
        return PredictionResponse(
            prediction=int(prediction),
            risk_level=risk_level,
            probability=probability,
            recommendation=recommendation,
            model="Random Forest",
            status="Prediction Completed Successfully"

        )
    except Exception as error:
        logger.exception("Prediction failed: %s", error)
        raise HTTPException(
            status_code=500,
            detail="Prediction could not be completed.",
        ) from error


@app.post("/predict/v2", response_model=PredictionResponse)
def predict_v2(data: PatientDataV2):
    """Run the production preprocessing and Random Forest pipeline.

    The DataFrame column order is fixed to the training contract so the
    serialized preprocessing stages receive the same schema used in training.
    """

    if pipeline_v2 is None:
        raise HTTPException(
            status_code=503,
            detail="Prediction pipeline v2 is unavailable.",
        )

    try:
        patient_data = pd.DataFrame(
            [
                {
                    "Age": data.Age,
                    "Gender": data.Gender,
                    "Cholesterol": data.Cholesterol,
                    "Blood Pressure": data.Blood_Pressure,
                    "Heart Rate": data.Heart_Rate,
                    "Smoking": data.Smoking,
                    "Alcohol Intake": data.Alcohol_Intake,
                    "Exercise Hours": data.Exercise_Hours,
                    "Family History": data.Family_History,
                    "Diabetes": data.Diabetes,
                    "Obesity": data.Obesity,
                    "Stress Level": data.Stress_Level,
                    "Blood Sugar": data.Blood_Sugar,
                    "Exercise Induced Angina": data.Exercise_Induced_Angina,
                    "Chest Pain Type": data.Chest_Pain_Type,
                }
            ],
            columns=FEATURE_COLUMNS,
        )

        prediction = pipeline_v2.predict(patient_data)[0]
        probability = pipeline_v2.predict_proba(patient_data)[0][1]
        probability = round(float(probability) * 100, 2)

        risk_level, recommendation = classify_risk(probability)
        return PredictionResponse(
            prediction=int(prediction),
            risk_level=risk_level,
            probability=probability,
            recommendation=recommendation,
            model="Random Forest Pipeline v2",
            status="Prediction Completed Successfully",
        )
    except Exception as error:
        logger.exception("Pipeline v2 prediction failed: %s", error)
        raise HTTPException(
            status_code=500,
            detail="Prediction could not be completed.",
        ) from error
