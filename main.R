# =====================================================
# Detector Speed Forecasting - Linear Models (part 2)
# =====================================================
library(dplyr)
library(tidyr)
library(caret)
library(stargazer)
library(Metrics)
library(olsrr)

# Create directories for saving tables
dir.create(file.path("tables"), recursive = TRUE)

# -----------------------------
# Load datasets
# -----------------------------
train <- read.csv("data/train_clean.csv")
test  <- read.csv("data/test_clean.csv")

# target variable
target_col <- "speed_main"

# Print first few rows to check the datasets
head(train)
head(test)

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
