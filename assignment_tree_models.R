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
source("scripts/helpers.R") # contains the function summarize_feature_importance_trees()

# -----------------------------
# Constants
# -----------------------------
CART_CP <- 0.001

MTRY_RF <- 24
NTREE_RF <- 200

NROUNDS_XG <- 100
MAX_DEPTH_XG <- 7
ETA_XG <- 0.1
COLSAMPLE_XG <- 1
MIN_CHILD_WEIGHT_XG <- 1
SUBSAMPLE_XG <- 0.7

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
