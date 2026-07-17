# ==============================================================================
# Project: Causal Machine Learning for Road Safety Analysis
# Script: 02_interaction_extraction.R
# Author: Danial Abdollahi
# Description: 2D Euclidean Kinematics, Pure TTC Extraction, and 
#              Strict 25-Frame Continuous Rolling Filter (RLE)
# ==============================================================================
library(data.table)
cat("[System] Starting Strict Interaction Extraction Phase...\n")

interactions <- readRDS("data/tidy_pNEUMA.rds")
setDT(interactions) 

suppressWarnings({
  numeric_cols <- c("x_i", "y_i", "x_j", "y_j", "v_y_i", "v_y_j", "v_x_i", "v_x_j")
  for (col in numeric_cols) {
    if(col %in% names(interactions)) interactions[, (col) := as.numeric(get(col))]
  }
})

interactions[, x_i_m := x_i * 87700]
interactions[, y_i_m := y_i * 111320]
interactions[, x_j_m := x_j * 87700]
interactions[, y_j_m := y_j * 111320]

# Euclidean Distance
interactions[, distance := sqrt((x_i_m - x_j_m)^2 + (y_i_m - y_j_m)^2)]

cat("[System] Deriving true physical velocity vectors...\n")
setorder(interactions, interaction_id, frame_id)

interactions[, v_x_i := (x_i_m - shift(x_i_m, n=1L, type="lag")) / 0.04, by=interaction_id]
interactions[, v_y_i := (y_i_m - shift(y_i_m, n=1L, type="lag")) / 0.04, by=interaction_id]
interactions[, v_x_j := (x_j_m - shift(x_j_m, n=1L, type="lag")) / 0.04, by=interaction_id]
interactions[, v_y_j := (y_j_m - shift(y_j_m, n=1L, type="lag")) / 0.04, by=interaction_id]

cols_to_fill <- c("v_x_i", "v_y_i", "v_x_j", "v_y_j")
for(col in cols_to_fill) {
  interactions[is.na(get(col)) | is.infinite(get(col)), (col) := 0]
}

interactions[, r_x := x_j_m - x_i_m]
interactions[, r_y := y_j_m - y_i_m]
interactions[, v_x := v_x_i - v_x_j]
interactions[, v_y := v_y_i - v_y_j]

interactions[, dot_product := (r_x * v_x) + (r_y * v_y)]
interactions[, v_norm_sq := (v_x^2) + (v_y^2)]
interactions[, speed_val := sqrt(v_norm_sq)]

# 2D TTC Calculation
interactions[, ttc_2d := NA_real_] 
valid_idx <- which(interactions$dot_product > 0 & interactions$v_norm_sq > 0)
if(length(valid_idx) > 0) {
  interactions[valid_idx, ttc_2d := abs(dot_product / v_norm_sq)]
}

cat("[System] Applying Professor's 25-Frame Continuous Filter (Run-Length Encoding)...\n")

# Identify critical frames
interactions[, is_critical := (!is.na(ttc_2d) & ttc_2d <= 3 & distance <= 30)]

# Calculate consecutive streaks of critical frames
interactions[, run_id := rleid(is_critical), by = interaction_id]
interactions[, streak_length := .N, by = .(interaction_id, run_id)]
interactions[, valid_streak := ifelse(is_critical == TRUE & streak_length >= 25, TRUE, FALSE)]

# Extract interaction IDs that have at least one valid streak
valid_interaction_ids <- unique(interactions[valid_streak == TRUE, interaction_id])

# Filter the dataset to ONLY include these valid interactions (apples-to-apples for both groups)
filtered_interactions <- interactions[interaction_id %in% valid_interaction_ids]

trt_ids <- unique(filtered_interactions[treatment == 1, interaction_id])
ctrl_ids <- unique(filtered_interactions[treatment == 0, interaction_id])

# Ensure balanced dataset for Causal ML
n_samples <- min(length(trt_ids), length(ctrl_ids), 2500)
balanced_ids <- c(head(trt_ids, n_samples), head(ctrl_ids, n_samples))
final_df <- filtered_interactions[interaction_id %in% balanced_ids]

cat("[System] Aggregating final variables...\n")
if(nrow(final_df) > 0) {
  agg_df <- final_df[, .(
    initial_distance = distance[1],
    mean_rel_speed = mean(speed_val, na.rm = TRUE),
    duration_frames = .N,
    accel_rate = (speed_val[.N] - speed_val[1]) / .N,
    min_ttc_2d = min(ttc_2d, na.rm = TRUE),
    treatment = treatment[1] 
  ), by = interaction_id]
  
  agg_df <- agg_df[!is.infinite(min_ttc_2d) & !is.na(min_ttc_2d) & !is.infinite(mean_rel_speed) & !is.na(mean_rel_speed)]
  agg_df <- agg_df[mean_rel_speed < 40] 
  
  cat("[System] Final TRUE Physical Group Distribution:\n")
  print(table(agg_df$treatment))
  
  saveRDS(agg_df, "data/conflict_events_2d.rds")
  cat("[System] Phase 2 Revision Complete! Ready for Phase 3.\n")
} else {
  cat("[System] Fatal Error: No 25-frame continuous interactions found. Try increasing nrows in Phase 1.\n")
}