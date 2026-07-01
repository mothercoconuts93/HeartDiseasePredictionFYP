import pandas as pd

from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV

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

# Grid search parameters
param_grid = {
    "n_estimators": [100, 200, 300],
    "max_depth": [5, 10, 15, None],
    "min_samples_split": [2, 5, 10]
}

# Random Forest
rf = RandomForestClassifier(random_state=42)

# Grid search + 5-Fold CV
grid_search = GridSearchCV(
    estimator=rf,
    param_grid=param_grid,
    cv=5,
    scoring="recall",
    n_jobs=-1
)

grid_search.fit(X_train, y_train)

print("\nBest Parameters:")
print(grid_search.best_params_)

print("\nBest Recall Score:")
print(grid_search.best_score_)