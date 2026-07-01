from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import pandas as pd

# Load Trained Model
model = joblib.load("machine_learning/heart_model.pkl")

# FastAPI Configuration
app = FastAPI(
    title="Heart Disease Prediction API",
    description="Random Forest Heart Disease Prediction System",
    version="1.0.0",
    contact={
        "name": "Guled Ibrahim"
    }
)

# Input Model
class PatientData(BaseModel):
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

# Response Model
class PredictionResponse(BaseModel):
    prediction: int
    risk_level: str
    probability: float
    recommendation: str
    model: str
    status: str

# Home Endpoint
@app.get("/")
def home():
    return {
        "message": "Heart Disease Prediction API Running Successfully"
    }

# Prediction Endpoint
@app.post("/predict", response_model=PredictionResponse)
def predict(data: PatientData):
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

        # Risk Classification
        if probability >= 75:
            risk_level = "High Risk"
            recommendation = (
                "Consult a cardiologist as soon as possible. "
                "Further clinical evaluation is strongly recommended."
            )
        elif probability >= 50:
            risk_level = "Moderate Risk"
            recommendation = (
                "Schedule a medical check-up and improve lifestyle habits "
                "such as diet and regular exercise."
            )
        elif probability >= 25:
            risk_level = "Low Risk"
            recommendation = (
                "Maintain a healthy lifestyle and continue regular health screening."
            )
        else:
            risk_level = "Very Low Risk"
            recommendation = (
                "Continue healthy habits and attend routine medical check-ups."
            )
        return PredictionResponse(
            prediction=int(prediction),
            risk_level=risk_level,
            probability=probability,
            recommendation=recommendation,
            model="Random Forest",
            status="Prediction Completed Successfully"

        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Prediction Error: {str(e)}"
        )