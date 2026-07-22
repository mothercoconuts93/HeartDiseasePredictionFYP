"""Train a baseline Random Forest and report standard classification metrics."""

import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score
)

# Load dataset
df = pd.read_csv("dataset/heart_disease_dataset.csv")

# Handle missing values
df["Alcohol Intake"] = df["Alcohol Intake"].fillna("Unknown")

# Optional verification
print(df.isnull().sum())

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

# Random Forest
model = RandomForestClassifier(
    n_estimators=200,
    random_state=42
)

model.fit(X_train, y_train)

predictions = model.predict(X_test)

# Evaluation
print("\nAccuracy:")
print(accuracy_score(y_test, predictions))

print("\nPrecision:")
print(precision_score(y_test, predictions))

print("\nRecall:")
print(recall_score(y_test, predictions))

print("\nF1 Score:")
print(f1_score(y_test, predictions))
