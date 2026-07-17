# ==============================================================================
# Script: 03_causal_ml_psm.R
# AI Agent: Claude 3.5 Sonnet (Anthropic) - REVIEWER FIX (One-Sided Test Swap)
# Task: Causal Forest, CATE Analysis, and Rosenbaum Bounds Sensitivity Analysis
# ==============================================================================

library(data.table)
library(grf)
library(Matching)
library(rbounds)
library(ggplot2)

cat("[AI Agent] Initializing Advanced Causal Machine Learning Module...\n")

agg_df <- readRDS("data/conflict_events_2d.rds")
setDT(agg_df)

cat("[AI Agent] Preparing variables for Generalized Random Forest (grf)...\n")
W <- agg_df$treatment
Y <- agg_df$min_ttc_2d
X <- as.matrix(agg_df[, .(initial_distance, mean_rel_speed, duration_frames, accel_rate)])

cat("[AI Agent] Training Causal Forest (2000 trees) - This may take a moment...\n")
set.seed(42)
c_forest <- causal_forest(X, Y, W, num.trees = 2000)

cat("[AI Agent] Estimating Average Treatment Effect (ATE)...\n")
ate <- average_treatment_effect(c_forest, target.sample = "all")
cat("--------------------------------------------------\n")
cat("[AI Agent] ATE Estimate (Impact of Motorcycles on TTC):", round(ate["estimate"], 4), "seconds\n")
cat("[AI Agent] ATE Standard Error:", round(ate["std.err"], 4), "\n")
cat("--------------------------------------------------\n")

cat("[AI Agent] Calculating Conditional Average Treatment Effects (CATE)...\n")
cate_pred <- predict(c_forest)$predictions
agg_df[, CATE := cate_pred]

var_imp <- variable_importance(c_forest)
rownames(var_imp) <- c("initial_distance", "mean_rel_speed", "duration_frames", "accel_rate")
cat("[AI Agent] Variable Importance Structure:\n")
print(var_imp)

cat("[AI Agent] Generating CATE Distribution Plot...\n")
ate_val <- ifelse(is.na(ate["estimate"]), 0, ate["estimate"])
cate_plot <- ggplot(agg_df, aes(x = CATE)) +
  geom_density(fill = "#e74c3c", alpha = 0.7, color = "black") +
  geom_vline(xintercept = ate_val, linetype = "dashed", linewidth = 1, color = "blue") +
  theme_minimal(base_size = 14) +
  labs(title = "Distribution of Conditional Average Treatment Effects (CATE)",
       subtitle = "Individual Causal Impact of PTWs on Minimum TTC",
       x = "CATE (Seconds)", y = "Density")

if(!dir.exists("output")) dir.create("output")
suppressWarnings(ggsave("output/fig_cate_distribution.png", plot = cate_plot, width = 8, height = 5, dpi = 300))

cat("[AI Agent] Executing Phase 6: Rosenbaum Bounds Sensitivity Analysis...\n")
if(length(unique(agg_df$treatment)) > 1) {
  cat("[AI Agent] Executing Mahalanobis Distance Matching...\n")
  
  X_mat <- agg_df[, .(initial_distance, mean_rel_speed, duration_frames, accel_rate)]
  m_out <- Match(Y = agg_df$min_ttc_2d, Tr = agg_df$treatment, X = X_mat, Weight = 2, ties = FALSE)

  if(!is.null(m_out)) {
    cat("[AI Agent] Calculating Sensitivity Bounds (Gamma)...\n")
    
    trt_outcomes <- agg_df$min_ttc_2d[m_out$index.treated]
    ctrl_outcomes <- agg_df$min_ttc_2d[m_out$index.control]
    
    # CRITICAL FIX: Swapping x and y because our treatment effect is NEGATIVE (reduces TTC).
    # psens defaults to a one-sided test for positive effects. 
    sens_results <- psens(x = ctrl_outcomes, y = trt_outcomes, Gamma = 3, GammaInc = 0.2)
    print(sens_results)
    
    cat("\n[AI Agent] Phase 3 Completed Successfully! All causal algorithms executed.\n")
  } else {
    cat("[AI Agent] Warning: Matching failed.\n")
  }
} else {
  cat("[AI Agent] Error: Control group insufficient for matching analysis.\n")
}