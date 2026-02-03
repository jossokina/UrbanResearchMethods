# =====================================================
# Data CHallenge 3 - Tree Models
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

#  =================== WARNING ======================== 
# The session will time out after inactivity of 10 minutes. If you are taking a break, ALWAYS export
# your script. See canvas for how to do this.
#  =====================================================

dir.create(file.path("tables"), recursive = TRUE)
dir.create(file.path("figures"), recursive = TRUE)

source("scripts/helpers.R") # contains the function summarize_feature_importance_trees()

# -----------------------------
# Constants
# -----------------------------
CART_CP <- 0.001

MTRY_RF <- 24
NTREE_RF <- 200

NROUNDS_XG <- 50
MAX_DEPTH_XG <- 4
ETA_XG <- 0.1
COLSAMPLE_XG <- 1
MIN_CHILD_WEIGHT_XG <- 1
SUBSAMPLE_XG <- 0.7

# -----------------------------------------------------------
# Seed: # NOTE: Do not change the seed
# grading compares your results to the reference output,
# and a different seed will produce different model results.
# -----------------------------------------------------------
set.seed(42)

# -----------------------------
# Load datasets
# -----------------------------
train_dataset <- read.csv("data/dc3_trainDataset.csv")
test_dataset  <- read.csv("data/dc3_testDataset.csv")

# Print first few rows to check the datasets
head(train_dataset)
head(test_dataset)

# -----------------------------
# Question 1
# -----------------------------

#Choose which columns to use as predictors. Remove target(congestion)
#and speed_ngh_432
model_formula <- congestion ~ . - speed_main - speed_ngh_432

#Create CART model
cart_model <- rpart(model_formula, data = train_dataset, method = "class",
                    control = rpart.control(cp = CART_CP))

#Create Random Forrest Model
predictor_cols <- setdiff(names(train_dataset), 
                          c("congestion", "speed_main", "speed_ngh_432"))

rf_model <- randomForest(
  x = train_dataset[, predictor_cols],
  y = as.factor(train_dataset$congestion),
  mtry = MTRY_RF,
  ntree = NTREE_RF,
  importance = TRUE
)

#Create XGBoose Model
# (4) XGBoost: build matrix from the same formula
X_train <- model.matrix(model_formula, train_dataset)[, -1, drop = FALSE]
y_train <- train_dataset$congestion

dtrain <- xgb.DMatrix(data = X_train, label = y_train)

params <- list(
  objective = "binary:logistic",
  eval_metric = "logloss",
  max_depth = MAX_DEPTH_XG,
  eta = ETA_XG,
  colsample_bytree = COLSAMPLE_XG,
  min_child_weight = MIN_CHILD_WEIGHT_XG,
  subsample = SUBSAMPLE_XG
)

xgb_model <- xgb.train(params = params, data = dtrain, nrounds = NROUNDS_XG, verbose = 0)

#Create variable importance table
summarize_feature_importance_trees(
  models = list(cart_model, rf_model, xgb_model),
  model_names = c("CART", "Random Forest", "XGBoost"),
  output_prefix = "tables/feature_importance_table"
)

# -----------------------------
# Question 2
# -----------------------------

# XGBoost test matrix using SAME formula
X_test <- model.matrix(model_formula, test_dataset)[, -1, drop = FALSE]

# CART
pred_cart <- as.integer(as.character(predict(cart_model, newdata = test_dataset, type = "class")))

# Random Forest (trained with formula, so predict() can take full test_dataset)
pred_rf <- as.integer(as.character(predict(rf_model, newdata = test_dataset, type = "class")))

# XGBoost
p_xgb <- predict(xgb_model, newdata = X_test)
pred_xgb <- ifelse(p_xgb >= 0.5, 1, 0)

# -----------------------------
# Confusion matrices + save
# -----------------------------
res_cart <- make_confusion(test_dataset$congestion, pred_cart)
save_cm(res_cart$cm, "CART", "tables/cm_cart")

res_rf <- make_confusion(test_dataset$congestion, pred_rf)
save_cm(res_rf$cm, "Random Forest", "tables/cm_random_forest")

res_xgb <- make_confusion(test_dataset$congestion, pred_xgb)
save_cm(res_xgb$cm, "XGBoost", "tables/cm_xgboost")

# -----------------------------
# Metrics table + save (.tex and .html) via function
# -----------------------------
metrics_table <- make_metrics_table(
  model_names  = c("CART", "Random Forest", "XGBoost"),
  results_list = list(res_cart, res_rf, res_xgb),
  output_prefix = "tables/test_metrics_summary"
)

# -----------------------------
# Question 3
# -----------------------------

# Add predictions to test dataset
test_dataset$pred_cart <- pred_cart
test_dataset$pred_rf <- pred_rf
test_dataset$pred_xgb <- pred_xgb

# Create hour variable from hour dummies
test_dataset$hour <- ifelse(test_dataset$hour6 == 1, 6,
                            ifelse(test_dataset$hour7 == 1, 7,
                                   ifelse(test_dataset$hour8 == 1, 8,
                                          ifelse(test_dataset$hour9 == 1, 9, NA))))

# Analyze congestion by hour
hour_analysis <- analyze_by_group(
  data = test_dataset,
  group_col = "hour",
  pred_cols = c("congestion", "pred_cart", "pred_rf", "pred_xgb"),
  output_prefix = "tables/congestion_by_hour"
)

# Create visualizations
plot_congestion_by_hour(hour_analysis, "figures/congestion_by_hour.pdf")
