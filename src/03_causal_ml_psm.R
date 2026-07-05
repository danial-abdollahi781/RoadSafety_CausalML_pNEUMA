# Script: 03_causal_ml_psm.R
# Description: Performs Propensity Score Matching (PSM) to evaluate the causal effect of motorcycles on TTC.
# Author: AI Agent (Simulated)

if (!require("MatchIt")) install.packages("MatchIt")
if (!require("data.table")) install.packages("data.table")
library(MatchIt)
library(data.table)

message("[AI Agent] Initializing Causal ML (PSM) Module...")

# 1. Define dynamic paths
project_root <- getwd()
input_file <- file.path(project_root, "data", "conflict_events.rds")
output_txt <- file.path(project_root, "output", "causal_inference_results.txt")

if (!file.exists(input_file)) {
  stop("Error: 'conflict_events.rds' not found. Run Script 02 first.")
}

# 2. Load conflict events data
message("[AI Agent] Loading conflict events data...")
valid_conflicts <- readRDS(input_file)

# 3. Define treatment variable (Motorcycle involvement)
message("[AI Agent] Defining treatment variable (Motorcycle involvement)...")
valid_conflicts[, is_motorcycle := ifelse(type1 == "Motorcycle" | type2 == "Motorcycle", 1, 0)]

# 4. Run Propensity Score Matching (Nearest Neighbor)
message("[AI Agent] Running Propensity Score Matching (Nearest Neighbor)...")
set.seed(2026) # Setting seed for reproducibility
match_model <- matchit(is_motorcycle ~ max_relative_speed + avg_distance_m + duration_frames, 
                       data = valid_conflicts, 
                       method = "nearest", 
                       ratio = 1, 
                       replace = FALSE)

matched_data <- match.data(match_model)

# 5. Perform Causal Inference (T-Test)
message("[AI Agent] Performing Causal Inference (T-Test)...")
causal_test <- t.test(min_ttc_sec ~ is_motorcycle, data = matched_data)

# 6. Save results to the output folder
message("[AI Agent] Saving results to output folder...")
sink(output_txt)
cat("--- Causal ML Module: Propensity Score Matching Results ---\n\n")
cat("1. Matching Summary:\n")
print(summary(match_model)$nn)
cat("\n2. Causal Effect on TTC (T-Test):\n")
print(causal_test)
sink()

message("[AI Agent] Causal ML complete. Results saved to 'output/causal_inference_results.txt'")