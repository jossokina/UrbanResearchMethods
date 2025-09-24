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
