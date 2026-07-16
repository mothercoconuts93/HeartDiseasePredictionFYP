import csv
import hashlib
from pathlib import Path

import joblib
import pandas as pd
import sklearn
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    accuracy_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATASET_PATH = PROJECT_ROOT / "dataset" / "heart_disease_dataset.csv"
PIPELINE_PATH = PROJECT_ROOT / "machine_learning" / "heart_pipeline_v2.pkl"

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
TARGET_COLUMN = "Heart Disease"

NUMERIC_COLUMNS = [
    "Age",
    "Cholesterol",
    "Blood Pressure",
    "Heart Rate",
    "Exercise Hours",
    "Stress Level",
    "Blood Sugar",
]

CATEGORICAL_COLUMNS = [
    "Gender",
    "Smoking",
    "Alcohol Intake",
    "Family History",
    "Diabetes",
    "Obesity",
    "Exercise Induced Angina",
    "Chest Pain Type",
]


def validate_dataset_contract(dataframe: pd.DataFrame) -> None:
    with DATASET_PATH.open("r", encoding="utf-8-sig", newline="") as dataset_file:
        header = next(csv.reader(dataset_file))

    duplicated_headers = sorted(
        {column for column in header if header.count(column) > 1}
    )
    if duplicated_headers:
        raise ValueError(
            f"Dataset contains duplicated columns: {duplicated_headers}"
        )

    expected_columns = FEATURE_COLUMNS + [TARGET_COLUMN]
    actual_columns = list(dataframe.columns)
    missing_columns = [
        column for column in expected_columns if column not in actual_columns
    ]
    unexpected_columns = [
        column for column in actual_columns if column not in expected_columns
    ]

    if missing_columns:
        raise ValueError(f"Dataset is missing expected columns: {missing_columns}")
    if unexpected_columns:
        raise ValueError(f"Dataset has unexpected columns: {unexpected_columns}")
    if actual_columns != expected_columns:
        raise ValueError(
            "Dataset columns are not in the required order. "
            f"Expected {expected_columns}, received {actual_columns}."
        )


def build_pipeline() -> Pipeline:
    numeric_pipeline = Pipeline(
        steps=[("imputer", SimpleImputer(strategy="median"))]
    )
    categorical_pipeline = Pipeline(
        steps=[
            (
                "imputer",
                SimpleImputer(strategy="constant", fill_value="Unknown"),
            ),
            ("encoder", OneHotEncoder(handle_unknown="ignore")),
        ]
    )

    preprocessor = ColumnTransformer(
        transformers=[
            ("numeric", numeric_pipeline, NUMERIC_COLUMNS),
            ("categorical", categorical_pipeline, CATEGORICAL_COLUMNS),
        ],
        remainder="drop",
    )

    classifier = RandomForestClassifier(
        n_estimators=100,
        max_depth=5,
        min_samples_split=2,
        random_state=42,
    )

    return Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("classifier", classifier),
        ]
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as artifact:
        for chunk in iter(lambda: artifact.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    dataframe = pd.read_csv(DATASET_PATH)
    validate_dataset_contract(dataframe)

    X = dataframe.loc[:, FEATURE_COLUMNS].copy()
    y = dataframe[TARGET_COLUMN].copy()

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.20,
        stratify=y,
        random_state=42,
    )

    pipeline = build_pipeline()
    pipeline.fit(X_train, y_train)

    predictions = pipeline.predict(X_test)
    probabilities = pipeline.predict_proba(X_test)[:, 1]

    joblib.dump(pipeline, PIPELINE_PATH)

    reloaded_pipeline = joblib.load(PIPELINE_PATH)
    if not isinstance(reloaded_pipeline, Pipeline):
        raise TypeError("Saved v2 artifact is not a scikit-learn Pipeline")
    if list(reloaded_pipeline.feature_names_in_) != FEATURE_COLUMNS:
        raise ValueError("Saved pipeline feature contract does not match v2")

    smoke_input = X_test.iloc[[0]].loc[:, FEATURE_COLUMNS]
    smoke_prediction = int(reloaded_pipeline.predict(smoke_input)[0])
    smoke_probability = float(reloaded_pipeline.predict_proba(smoke_input)[0][1])

    print(f"Dataset shape: {dataframe.shape}")
    print(f"Training rows: {len(X_train)}")
    print(f"Test rows: {len(X_test)}")
    print(f"Class distribution: {y.value_counts().sort_index().to_dict()}")
    print(f"Accuracy: {accuracy_score(y_test, predictions):.6f}")
    print(f"Precision: {precision_score(y_test, predictions):.6f}")
    print(f"Recall: {recall_score(y_test, predictions):.6f}")
    print(f"F1: {f1_score(y_test, predictions):.6f}")
    print(f"ROC-AUC: {roc_auc_score(y_test, probabilities):.6f}")
    print(f"Confusion matrix: {confusion_matrix(y_test, predictions).tolist()}")
    print(
        "Smoke-test prediction: "
        f"class={smoke_prediction}, probability={smoke_probability:.6f}"
    )
    print(f"scikit-learn version: {sklearn.__version__}")
    print(f"Artifact path: {PIPELINE_PATH}")
    print(f"Artifact SHA-256: {sha256_file(PIPELINE_PATH)}")


if __name__ == "__main__":
    main()
