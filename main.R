# ==========================================================
# Data Challenge 1 - Data analysis and variable selection
# ==========================================================
library(dplyr)
library(tidyr)
library(caret)
library(stargazer)
library(Metrics)
library(olsrr)

# Create directories for saving tables
dir.create(file.path("tables"), recursive = TRUE)
dir.create(file.path("figures"), recursive = TRUE)

# -----------------------------
# Load datasets
# -----------------------------
train_dataset <- read.csv("data/dc1_trainDataset.csv")


# target variable
target_col <- "speed_main"

# Print first few rows to check the datasets
head(train_dataset)

# -----------------------------
# Question 1
# -----------------------------

# -----------------------------
# Question 2
# -----------------------------

# -----------------------------
# Question 3
# -----------------------------

# -----------------------------
# Question 4
# -----------------------------

# -----------------------------
# Question 5
# -----------------------------
