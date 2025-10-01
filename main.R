# =====================================================
# Detector Speed Forecasting - Linear Models
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
train <- read.csv("data/trainDataset.csv")
test  <- read.csv("data/testDataset.csv")

# target variable
target_col <- "speed_main"

# Print first few rows to check the datasets
head(train)
head(test)
