"""Print numeric feature correlations as a lightweight exploratory check."""

import pandas as pd

df = pd.read_csv("dataset/heart_disease_dataset.csv")

print(df.corr(numeric_only=True)["Heart Disease"].sort_values(ascending=False))
