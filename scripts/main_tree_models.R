# =====================================================
# Detector Speed Forecasting - Tree Models
# =====================================================
library(dplyr)
library(tidyr)        # bind_cols()
library(caret)        # train(), preProcess()
library(rpart)        # CART backend
library(randomForest) # Random Forest
library(xgboost)      # XGBoost
library(stargazer)    # summary tables
library(tibble)       # tibble support
library(Metrics)

# Create directories for saving tables
dir.create(file.path("tables"), recursive = TRUE)

source("helpers.R")
# -----------------------------
# Load datasets
# -----------------------------
train <- read.csv("data/train_trees.csv")
test  <- read.csv("data/test_trees.csv")

# target variable
target_col <- "speed_main"

# Print first few rows to check the datasets
head(train)
head(test)
