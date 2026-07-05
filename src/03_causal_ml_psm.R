# Script: 03_causal_ml_psm.R
# Description: Performs Caliper-enforced Propensity Score Matching (PSM).
# Author: AI Agent (Simulated)

if (!require("MatchIt")) install.packages("MatchIt")
if (!require("data.table")) install.packages("data.table")
library(MatchIt)
library(data.table)

message("[AI Agent] Initializing Robust Causal ML (PSM) Module...")

project_root <- getwd()
input_file <- file.path(project_root, "data", "conflict_events.rds")
output_txt <- file.path(project_root, "output", "causal_inference_results.txt")

if (!file.exists(input_file)) {
  stop("Error: 'conflict_events.rds' not found. Run Script 02 first.")
}

valid_conflicts <- readRDS(input_file)
valid_conflicts[, is_motorcycle := ifelse(type1 == "Motorcycle" | type2 == "Motorcycle", 1, 0)]

# Enforcing a strict caliper of 0.15 standard deviations to eliminate bad matches
message("[AI Agent] Running Caliper-enforced Propensity Score Matching...")
set.seed(2026)
match_model <- matchit(is_motorcycle ~ max_relative_speed + avg_distance_m + duration_frames, 
                       data = valid_conflicts, 
                       method = "nearest", 
                       caliper = 0.15, 
                       ratio = 1, 
                       replace = FALSE)

matched_data <- match.data(match_model)

message("[AI Agent] Performing Causal Inference on Caliper-matched sample...")
causal_test <- t.test(min_ttc_sec ~ is_motorcycle, data = matched_data)

message("[AI Agent] Saving optimized results to output folder...")
sink(output_txt)
cat("--- Optimized Causal ML Module: Caliper-enforced PSM Results ---\n\n")
cat("1. Matching Summary (Notice dropped unmatched units for strict balance):\n")
print(summary(match_model)$nn)
cat("\n2. Causal Effect on TTC after Strict Matching (T-Test):\n")
print(causal_test)
sink()

message("[AI Agent] Causal ML complete. Optimized results saved.")