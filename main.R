# =====================================================
# Data Challenges 2 - Linear Models 
# =====================================================
library(dplyr)
library(tidyr)
library(caret)
library(stargazer)
library(Metrics)
library(olsrr)

#  =================== WARNING ======================== 
# The session will time out after inactivity of 10 minutes. If you are taking a break, ALWAYS export
# your script. See canvas for how to do this.
#  =====================================================

# Create directories for saving tables
dir.create(file.path("tables"), recursive = TRUE)

# -----------------------------
# Load datasets
# -----------------------------
train_dataset <- read.csv("data/dc2_trainDataset.csv")
test_dataset  <- read.csv("data/dc2_testDataset.csv")

# Print first few rows to check the datasets
head(train_dataset)
head(test_dataset)

# -----------------------------
# Question 1
# -----------------------------

# -----------------------------
# Model (a): Only flow
# -----------------------------
lm_flow_only <- 

# -------------------------------------------
# Model (b): All variables except speed_ngh
# -------------------------------------------
lm_all_but_speed <- 

# -------------------------------------------
# Model (c): All variables
# -------------------------------------------
lm_all_var <- 

# -------------------------------------------
# Model (d): Step forward function
# -------------------------------------------
step_forward_model <- 

# -------------------------------------------
# Summary Table
# -------------------------------------------


# -----------------------------
# Question 2
# -----------------------------


# -----------------------------
# Question 3
# -----------------------------
