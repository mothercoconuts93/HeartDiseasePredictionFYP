"""Inspect duplicate removal and categorical encoding on the source dataset."""

import pandas as pd
from sklearn.preprocessing import LabelEncoder

df = pd.read_csv("dataset/heart_disease_dataset.csv")

print("Original Shape:", df.shape)

# Remove duplicates
df = df.drop_duplicates()

# Encode categorical columns
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

encoder = LabelEncoder()

for column in categorical_columns:
    df[column] = encoder.fit_transform(df[column])

print("\nProcessed Shape:")
print(df.shape)

print("\nData Types:")
print(df.dtypes)
