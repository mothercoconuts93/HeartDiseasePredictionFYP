import hashlib
import sys
from pathlib import Path

import joblib
import matplotlib
import numpy as np
import pandas as pd
import sklearn
from sklearn.base import clone
from sklearn.dummy import DummyClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
    roc_curve,
)
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.tree import DecisionTreeClassifier

from train_pipeline_v2 import (
    DATASET_PATH,
    FEATURE_COLUMNS,
    PIPELINE_PATH,
    TARGET_COLUMN,
    build_pipeline,
    validate_dataset_contract,
)

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

RESULTS_DIR = Path(__file__).resolve().parent / "results"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as artifact:
        for chunk in iter(lambda: artifact.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def classifier_definitions() -> dict[str, object]:
    return {
        "DummyClassifier": DummyClassifier(strategy="prior", random_state=42),
        "LogisticRegression": LogisticRegression(
            max_iter=5000,
            random_state=42,
        ),
        "DecisionTreeClassifier": DecisionTreeClassifier(random_state=42),
        "RandomForestClassifier": build_pipeline().named_steps["classifier"],
    }


def save_class_distribution(y: pd.Series) -> None:
    counts = y.value_counts().sort_index()
    labels = ["No Heart Disease (0)", "Heart Disease (1)"]

    fig, ax = plt.subplots(figsize=(7, 5))
    bars = ax.bar(labels, counts.values, color=["#3B82F6", "#EF4444"])
    ax.set_title("Heart Disease Class Distribution")
    ax.set_ylabel("Number of records")
    ax.bar_label(bars, padding=3)
    ax.set_ylim(0, max(counts.values) * 1.15)
    fig.tight_layout()
    fig.savefig(RESULTS_DIR / "class_distribution.png", dpi=200)
    plt.close(fig)


def save_confusion_matrix(matrix: np.ndarray) -> None:
    fig, ax = plt.subplots(figsize=(6, 5))
    image = ax.imshow(matrix, cmap="Blues")
    ax.set_title("Random Forest Confusion Matrix")
    ax.set_xlabel("Predicted label")
    ax.set_ylabel("True label")
    ax.set_xticks([0, 1], labels=["No disease", "Disease"])
    ax.set_yticks([0, 1], labels=["No disease", "Disease"])

    threshold = matrix.max() / 2
    for row in range(2):
        for column in range(2):
            ax.text(
                column,
                row,
                str(matrix[row, column]),
                ha="center",
                va="center",
                color="white" if matrix[row, column] > threshold else "black",
            )

    fig.colorbar(image, ax=ax)
    fig.tight_layout()
    fig.savefig(RESULTS_DIR / "confusion_matrix_random_forest.png", dpi=200)
    plt.close(fig)


def save_roc_curves(
    y_test: pd.Series,
    probabilities_by_model: dict[str, np.ndarray],
    auc_by_model: dict[str, float],
) -> None:
    fig, ax = plt.subplots(figsize=(8, 6))
    for model_name, probabilities in probabilities_by_model.items():
        false_positive_rate, true_positive_rate, _ = roc_curve(
            y_test, probabilities
        )
        ax.plot(
            false_positive_rate,
            true_positive_rate,
            linewidth=2,
            label=f"{model_name} (AUC={auc_by_model[model_name]:.3f})",
        )

    ax.plot([0, 1], [0, 1], "k--", label="Chance")
    ax.set_title("ROC Curve Comparison")
    ax.set_xlabel("False-positive rate")
    ax.set_ylabel("True-positive rate")
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.02)
    ax.legend(loc="lower right")
    ax.grid(alpha=0.25)
    fig.tight_layout()
    fig.savefig(RESULTS_DIR / "roc_curve_comparison.png", dpi=200)
    plt.close(fig)


def save_feature_importance(random_forest_pipeline: Pipeline) -> None:
    preprocessor = random_forest_pipeline.named_steps["preprocessor"]
    classifier = random_forest_pipeline.named_steps["classifier"]
    feature_names = preprocessor.get_feature_names_out()
    cleaned_names = [
        name.replace("numeric__", "").replace("categorical__", "")
        for name in feature_names
    ]
    importances = pd.Series(
        classifier.feature_importances_,
        index=cleaned_names,
    ).sort_values(ascending=True)

    fig_height = max(7, len(importances) * 0.32)
    fig, ax = plt.subplots(figsize=(10, fig_height))
    ax.barh(importances.index, importances.values, color="#2563EB")
    ax.set_title("Random Forest Feature Importance After Preprocessing")
    ax.set_xlabel("Importance")
    fig.tight_layout()
    fig.savefig(RESULTS_DIR / "feature_importance.png", dpi=200)
    plt.close(fig)


def save_model_comparison(results: pd.DataFrame) -> None:
    metric_columns = ["accuracy", "precision", "recall", "f1_score", "roc_auc"]
    chart_data = results.set_index("model")[metric_columns]

    fig, ax = plt.subplots(figsize=(12, 7))
    chart_data.plot(kind="bar", ax=ax, width=0.8)
    ax.set_title("Test-set Model Performance Comparison")
    ax.set_ylabel("Score")
    ax.set_xlabel("")
    ax.set_ylim(0, 1.05)
    ax.tick_params(axis="x", rotation=15)
    ax.legend(loc="lower right", ncol=2)
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(RESULTS_DIR / "model_comparison.png", dpi=200)
    plt.close(fig)


def write_dataset_summary(
    dataframe: pd.DataFrame,
    X_train: pd.DataFrame,
    X_test: pd.DataFrame,
    y_train: pd.Series,
    y_test: pd.Series,
    artifact_hash: str,
) -> None:
    missing_values = dataframe.isna().sum()
    missing_values = missing_values[missing_values > 0].to_dict()
    summary = [
        "CardioGuard Pipeline v2 Dataset Summary",
        "======================================",
        f"Dataset path: {DATASET_PATH}",
        f"Dataset shape: {dataframe.shape}",
        f"Feature count: {len(FEATURE_COLUMNS)}",
        f"Feature order: {FEATURE_COLUMNS}",
        f"Target: {TARGET_COLUMN}",
        f"Missing values: {missing_values}",
        f"Complete duplicate rows: {int(dataframe.duplicated().sum())}",
        f"Full class distribution: {dataframe[TARGET_COLUMN].value_counts().sort_index().to_dict()}",
        f"Training rows: {len(X_train)}",
        f"Test rows: {len(X_test)}",
        f"Training class distribution: {y_train.value_counts().sort_index().to_dict()}",
        f"Test class distribution: {y_test.value_counts().sort_index().to_dict()}",
        "Split: test_size=0.20, stratify=y, random_state=42",
        "Cross-validation: 5-fold StratifiedKFold on training partition, shuffle=True, random_state=42",
        f"Production v2 artifact: {PIPELINE_PATH}",
        f"Production v2 SHA-256: {artifact_hash}",
        "",
        "Package versions",
        "----------------",
        f"Python: {sys.version.split()[0]}",
        f"pandas: {pd.__version__}",
        f"NumPy: {np.__version__}",
        f"matplotlib: {matplotlib.__version__}",
        f"joblib: {joblib.__version__}",
        f"scikit-learn: {sklearn.__version__}",
        "",
        "Interpretation limitation",
        "-------------------------",
        "These results are an internal technical evaluation on one dataset.",
        "They do not establish clinical validity, safety, calibration, or generalization",
        "to external patient populations.",
    ]
    (RESULTS_DIR / "dataset_summary.txt").write_text(
        "\n".join(summary) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

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

    production_pipeline = joblib.load(PIPELINE_PATH)
    base_preprocessor = build_pipeline().named_steps["preprocessor"]
    cross_validator = StratifiedKFold(
        n_splits=5,
        shuffle=True,
        random_state=42,
    )

    rows = []
    fitted_pipelines: dict[str, Pipeline] = {}
    probabilities_by_model: dict[str, np.ndarray] = {}
    auc_by_model: dict[str, float] = {}

    for model_name, classifier in classifier_definitions().items():
        evaluation_pipeline = Pipeline(
            steps=[
                ("preprocessor", clone(base_preprocessor)),
                ("classifier", clone(classifier)),
            ]
        )
        evaluation_pipeline.fit(X_train, y_train)

        predictions = evaluation_pipeline.predict(X_test)
        positive_class_index = list(
            evaluation_pipeline.named_steps["classifier"].classes_
        ).index(1)
        probabilities = evaluation_pipeline.predict_proba(X_test)[
            :, positive_class_index
        ]
        matrix = confusion_matrix(y_test, predictions)
        true_negatives, false_positives, false_negatives, true_positives = (
            matrix.ravel()
        )

        cv_scores = cross_val_score(
            evaluation_pipeline,
            X_train,
            y_train,
            cv=cross_validator,
            scoring="accuracy",
            n_jobs=1,
        )

        roc_auc = roc_auc_score(y_test, probabilities)
        rows.append(
            {
                "model": model_name,
                "accuracy": accuracy_score(y_test, predictions),
                "precision": precision_score(
                    y_test, predictions, zero_division=0
                ),
                "recall": recall_score(y_test, predictions, zero_division=0),
                "f1_score": f1_score(y_test, predictions, zero_division=0),
                "roc_auc": roc_auc,
                "cv_accuracy_mean": cv_scores.mean(),
                "cv_accuracy_std": cv_scores.std(),
                "true_negatives": int(true_negatives),
                "false_positives": int(false_positives),
                "false_negatives": int(false_negatives),
                "true_positives": int(true_positives),
            }
        )
        fitted_pipelines[model_name] = evaluation_pipeline
        probabilities_by_model[model_name] = probabilities
        auc_by_model[model_name] = roc_auc

    random_forest_pipeline = fitted_pipelines["RandomForestClassifier"]
    evaluated_predictions = random_forest_pipeline.predict(X_test)
    production_predictions = production_pipeline.predict(X_test)
    evaluated_probabilities = random_forest_pipeline.predict_proba(X_test)[:, 1]
    production_probabilities = production_pipeline.predict_proba(X_test)[:, 1]
    if not np.array_equal(evaluated_predictions, production_predictions):
        raise RuntimeError(
            "Evaluated Random Forest predictions do not match the production v2 artifact"
        )
    if not np.allclose(evaluated_probabilities, production_probabilities):
        raise RuntimeError(
            "Evaluated Random Forest probabilities do not match the production v2 artifact"
        )

    results = pd.DataFrame(rows)
    results.to_csv(RESULTS_DIR / "model_results.csv", index=False, float_format="%.6f")

    save_class_distribution(y)
    random_forest_matrix = confusion_matrix(
        y_test,
        random_forest_pipeline.predict(X_test),
    )
    save_confusion_matrix(random_forest_matrix)
    save_roc_curves(y_test, probabilities_by_model, auc_by_model)
    save_feature_importance(random_forest_pipeline)
    save_model_comparison(results)

    artifact_hash = sha256_file(PIPELINE_PATH)
    write_dataset_summary(
        dataframe,
        X_train,
        X_test,
        y_train,
        y_test,
        artifact_hash,
    )

    print(results.to_string(index=False, float_format=lambda value: f"{value:.6f}"))
    print(f"Results directory: {RESULTS_DIR}")
    print(f"Production artifact SHA-256: {artifact_hash}")
    print("Random Forest evaluation matches the saved production v2 artifact.")


if __name__ == "__main__":
    main()
