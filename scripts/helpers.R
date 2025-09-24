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