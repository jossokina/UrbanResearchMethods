library(ggplot2)
library(knitr)

# -----------------------------
# Extract feature importance
# -----------------------------
get_feature_importance <- function(model, model_name, min_rel_importance = 0.005) {
  
  if (inherits(model, "xgb.Booster")) {
    xgb.importance(model = model) %>%
      dplyr::select(Feature, !!model_name := Gain) %>%
      dplyr::filter(!!rlang::sym(model_name) >= min_rel_importance)
    
    
  } else if (inherits(model, "rpart")) {
    imp <- as.data.frame(model$variable.importance)
    imp$Feature <- rownames(imp)
    rownames(imp) <- NULL
    colnames(imp)[1] <- model_name
    # Convert to relative importance
    imp[[model_name]] <- imp[[model_name]] / sum(imp[[model_name]])
    imp <- imp %>% dplyr::filter(!!rlang::sym(model_name) >= min_rel_importance)
    imp
    
  } else if (inherits(model, "randomForest")) {
    imp <- as.data.frame(importance(model))
    imp$Feature <- rownames(imp)
    rownames(imp) <- NULL
    colnames(imp)[1] <- model_name
    # Convert to relative importance
    imp[[model_name]] <- imp[[model_name]] / sum(imp[[model_name]])
    imp <- imp %>% dplyr::filter(!!rlang::sym(model_name) >= min_rel_importance)
    imp
    
  } else stop("Feature importance not implemented for this model type.")
}

# -----------------------------
# Combine feature importance in wide format
# -----------------------------
summarize_feature_importance_trees <- function(models, model_names,
                                            output_prefix = "feature_importance") {
  
  # Extract and merge feature importance
  wide_imp <- purrr::map2(models, model_names, get_feature_importance) %>%
    purrr::reduce(full_join, by = "Feature") %>%
    arrange(desc(!!rlang::sym(model_names[1])))   # sort by first model's importance
  
  # Reorder columns: Feature first, then the models
  wide_imp <- wide_imp[, c("Feature", model_names)]
  
  stargazer::stargazer(wide_imp, summary = FALSE, type = "text",  out = paste0(output_prefix, ".txt"))
  stargazer::stargazer(wide_imp, summary = FALSE, type = "latex", out = paste0(output_prefix, ".tex"))
  stargazer::stargazer(wide_imp, summary = FALSE, type = "html", out = paste0(output_prefix, ".html"))
  
  wide_imp
}

#-----------------------------------------
# Confusion Matrix and simple metrics
#-----------------------------------------
make_confusion <- function(y_true, y_pred) {
  y_true <- as.integer(y_true)
  y_pred <- as.integer(y_pred)
  
  cm <- table(
    factor(y_true, levels = 0:1),
    factor(y_pred, levels = 0:1)
  )
  dimnames(cm) <- list(True = c("0","1"), Pred = c("0","1"))
  
  TN <- cm[1,1]; FP <- cm[1,2]; FN <- cm[2,1]; TP <- cm[2,2]
  safe_div <- function(a, b) if (b == 0) NA else a / b
  
  accuracy  <- (TP + TN) / sum(cm)
  precision <- safe_div(TP, TP + FP)
  recall    <- safe_div(TP, TP + FN)
  f1        <- if (is.na(precision) || is.na(recall) || (precision + recall) == 0) NA
  else 2 * precision * recall / (precision + recall)
  
  list(
    cm = cm,
    metrics = c(Accuracy = accuracy, Precision = precision, Recall = recall, F1 = f1)
  )
}

save_cm <- function(cm, model_name, output_prefix) {
  # ---- LaTeX (.tex) ----
  label <- paste0("tab:cm_", gsub("[^a-z0-9]+", "_", tolower(model_name)))
  tex_lines <- c(
    "\\begin{table}[!htbp]",
    "\\centering",
    sprintf("\\caption{Confusion matrix on test set - %s}", model_name),
    sprintf("\\label{%s}", label),
    "\\begin{tabular}{lrr}",
    "\\toprule",
    " & Pred 0 & Pred 1 \\\\",
    "\\midrule",
    sprintf("True 0 & %d & %d \\\\", cm["0","0"], cm["0","1"]),
    sprintf("True 1 & %d & %d \\\\", cm["1","0"], cm["1","1"]),
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tex_lines, paste0(output_prefix, ".tex"))
  
  # ---- HTML (.html) ----
  html_lines <- c(
    "<!doctype html>",
    "<html><head><meta charset='utf-8'>",
    sprintf("<title>Confusion Matrix - %s</title>", model_name),
    "</head><body>",
    sprintf("<h3>Confusion matrix on test set - %s</h3>", model_name),
    "<table border='1' cellpadding='6' cellspacing='0'>",
    "<tr><th></th><th>Pred 0</th><th>Pred 1</th></tr>",
    sprintf("<tr><th>True 0</th><td>%d</td><td>%d</td></tr>", cm["0","0"], cm["0","1"]),
    sprintf("<tr><th>True 1</th><td>%d</td><td>%d</td></tr>", cm["1","0"], cm["1","1"]),
    "</table>",
    "</body></html>"
  )
  writeLines(html_lines, paste0(output_prefix, ".html"))
  
}

# ---- Metrics helper: builds table AND saves .tex + .html ----
make_metrics_table <- function(model_names, results_list,
                               output_prefix = "tables/test_metrics_summary",
                               caption = "Test-set performance summary",
                               label = "tab:test_metrics") {
  metrics_mat <- do.call(rbind, lapply(results_list, function(x) x$metrics))
  
  metrics_table <- data.frame(
    Model = model_names,
    metrics_mat,
    row.names = NULL
  )
  metrics_table[, -1] <- round(metrics_table[, -1], 3)
  
  # Keep trailing zeros for export formatting
  mt_print <- metrics_table
  mt_print[, -1] <- lapply(mt_print[, -1], function(x) formatC(x, format = "f", digits = 3))
  
  # ---- LaTeX ----
  colspec <- paste0("l", paste(rep("r", ncol(mt_print) - 1), collapse = ""))
  tex_lines <- c(
    "\\begin{table}[!htbp]",
    "\\centering",
    sprintf("\\caption{%s}", caption),
    sprintf("\\label{%s}", label),
    sprintf("\\begin{tabular}{%s}", colspec),
    "\\toprule",
    paste0(paste(names(mt_print), collapse = " & "), " \\\\"),
    "\\midrule",
    paste0(apply(mt_print, 1, function(r) paste(r, collapse = " & ")), " \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tex_lines, paste0(output_prefix, ".tex"))
  
  # ---- HTML ----
  html_rows <- apply(mt_print, 1, function(r) {
    paste0("<tr>", paste0("<td>", r, "</td>", collapse = ""), "</tr>")
  })
  html_lines <- c(
    "<!doctype html>",
    "<html><head><meta charset='utf-8'></head><body>",
    sprintf("<h3>%s</h3>", caption),
    "<table border='1' cellpadding='6' cellspacing='0'>",
    paste0("<tr>", paste0("<th>", names(mt_print), "</th>", collapse = ""), "</tr>"),
    html_rows,
    "</table>",
    "</body></html>"
  )
  writeLines(html_lines, paste0(output_prefix, ".html"))
  
  metrics_table
}


library(ggplot2)
library(knitr)

# Define consistent colors for all plots
MODEL_COLORS <- c(
  "Ground Truth" = "#6A1B9A",
  "CART" = "#E41A1C",
  "Random Forest" = "#377EB8",
  "XGBoost" = "#4DAF4A"
)

# Analyze congestion rates by group
# Analyze congestion rates by group
analyze_by_group <- function(data, group_col, pred_cols, output_prefix) {
  # Calculate mean congestion rate for each group
  result <- aggregate(
    x = data[, pred_cols],
    by = list(group = data[[group_col]]),
    FUN = mean
  )
  names(result)[1] <- group_col
  
  # Sort by group
  result <- result[order(result[[group_col]]), ]
  
  # Convert to percentages and round
  result[, pred_cols] <- lapply(result[, pred_cols], function(x) round(x * 100, 1))
  
  # Create LaTeX table
  latex_table <- kable(
    result,
    format = "latex",
    booktabs = TRUE,
    caption = paste("Congestion rate by", group_col, "(percentage)"),
    label = paste0("tab:cong_by_", group_col)
  )
  writeLines(latex_table, paste0(output_prefix, ".tex"))
  
  # Create HTML table
  html_table <- kable(
    result,
    format = "html",
    caption = paste("Congestion rate by", group_col, "(percentage)")
  )
  writeLines(html_table, paste0(output_prefix, ".html"))
  
  return(result)
}

# Plot congestion by hour (bar chart)
plot_congestion_by_hour <- function(hour_data, output_file) {
  # Rename columns for better labels
  plot_data <- hour_data
  names(plot_data) <- c("hour", "Ground Truth", "CART", "Random Forest", "XGBoost")
  
  # Convert to long format
  plot_long <- tidyr::pivot_longer(
    plot_data,
    cols = -hour,
    names_to = "Model",
    values_to = "Rate"
  )
  
  # Set factor levels for proper ordering
  plot_long$Model <- factor(plot_long$Model, 
                            levels = c("Ground Truth", "CART", "Random Forest", "XGBoost"))
  
  # Create plot with consistent colors
  p <- ggplot(plot_long, aes(x = as.factor(hour), y = Rate, fill = Model)) +
    geom_col(position = position_dodge(width = 0.9), width = 0.8) +
    scale_fill_manual(values = MODEL_COLORS) +
    labs(
      x = "Hour of Day",
      y = "Congestion Rate (%)",
      fill = ""
    ) +
    theme_minimal(base_size = 12, base_family = "serif") +
    theme(legend.position = "bottom")
  
  ggsave(output_file, p, width = 8, height = 5)
}

# Plot congestion by week - Prediction Error
plot_congestion_by_week <- function(week_data, output_file) {
  names(week_data) <- c("week", "Ground Truth", "CART", "Random Forest", "XGBoost")
  
  # Calculate prediction errors (Model - Ground Truth)
  week_data$CART_error <- week_data$CART - week_data$`Ground Truth`
  week_data$RF_error <- week_data$`Random Forest` - week_data$`Ground Truth`
  week_data$XGB_error <- week_data$XGBoost - week_data$`Ground Truth`
  
  # Prepare error data
  error_long <- tidyr::pivot_longer(
    week_data,
    cols = ends_with("_error"),
    names_to = "Model",
    values_to = "Error"
  )
  
  # Clean up model names and set order
  error_long$Model <- gsub("_error", "", error_long$Model)
  error_long$Model <- ifelse(error_long$Model == "RF", "Random Forest",
                             ifelse(error_long$Model == "XGB", "XGBoost", error_long$Model))
  error_long$Model <- factor(error_long$Model, levels = c("CART", "Random Forest", "XGBoost"))
  
  # Create plot - only errors
  p <- ggplot(error_long, aes(x = week, y = Error, color = Model, linetype = Model)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", linewidth = 0.5) +
    scale_color_manual(values = MODEL_COLORS[c("CART", "Random Forest", "XGBoost")]) +
    labs(
      x = "Week",
      y = "Prediction Error (%)",
      color = "",
      linetype = ""
    ) +
    scale_x_continuous(breaks = seq(1, max(week_data$week), by = 4)) +
    theme_minimal(base_size = 12, base_family = "serif") +
    theme(legend.position = "bottom")
  
  ggsave(output_file, p, width = 10, height = 5.5)
}