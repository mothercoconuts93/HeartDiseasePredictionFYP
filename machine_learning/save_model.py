"""Train and serialize the legacy Random Forest model used by API V1."""

import pandas as pd
import joblib

from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Load dataset
df = pd.read_csv("dataset/heart_disease_dataset.csv")

# Handle missing values
df["Alcohol Intake"] = df["Alcohol Intake"].fillna("Unknown")

# Label encoding
categorical_columns = [
    "Gender",
    "Smoking",
    "Alcohol Intake",
    "Family History",
    "Diabetes",
    "Obesity",
    "Exercise Induced Angina",
    "Chest Pain Type"
]

for column in categorical_columns:
    encoder = LabelEncoder()
    df[column] = encoder.fit_transform(df[column])

# Features & Target
X = df.drop("Heart Disease", axis=1)
y = df["Heart Disease"]

# Train test split
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    stratify=y,
    random_state=42
)

# Train best model
model = RandomForestClassifier(
    n_estimators=100,
    max_depth=5,
    min_samples_split=2,
    random_state=42
)

model.fit(X_train, y_train)

# Save model
joblib.dump(model, "machine_learning/heart_model.pkl")

print("Model saved successfully!")
