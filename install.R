# install.R
# Install all required packages for the assignment
install.packages("readr") # for binder

packages <- c(
  "dplyr",
  "tidyr",
  "caret",
  "rpart",
  "randomForest",
  "xgboost",
  "stargazer",
  "tibble",
  "Metrics",
  "olsrr"
)

# Install any packages that are not already installed
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed])
}
