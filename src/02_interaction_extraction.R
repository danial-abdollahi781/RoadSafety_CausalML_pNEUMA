# ==============================================================================
# Script: 02_interaction_extraction.R
# AI Agent: Claude 3.5 Sonnet (Anthropic) - STRICT SCIENTIFIC REVISION
# Task: Natural Kinematics, Pure TTC Extraction, and Valid Baseline Structuring
# ==============================================================================

library(data.table)
cat("[AI Agent] Starting Strict Interaction Extraction Phase...\n")

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

interactions[, distance := sqrt((x_i_m - x_j_m)^2 + (y_i_m - y_j_m)^2)]

cat("[AI Agent] Deriving true physical velocity vectors (Dynamic dt)...\n")
setorder(interactions, interaction_id, frame_id)

# FIXED: Dynamic time delta to prevent supersonic speeds from missing frames
interactions[, delta_f := frame_id - shift(frame_id, n=1L, type="lag"), by=interaction_id]
interactions[is.na(delta_f) | delta_f <= 0, delta_f := 1]

interactions[, v_x_i := (x_i_m - shift(x_i_m, n=1L, type="lag")) / (delta_f * 0.04), by=interaction_id]
interactions[, v_y_i := (y_i_m - shift(y_i_m, n=1L, type="lag")) / (delta_f * 0.04), by=interaction_id]
interactions[, v_x_j := (x_j_m - shift(x_j_m, n=1L, type="lag")) / (delta_f * 0.04), by=interaction_id]
interactions[, v_y_j := (y_j_m - shift(y_j_m, n=1L, type="lag")) / (delta_f * 0.04), by=interaction_id]

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

# FIXED: Only calculate TTC for vehicles actively converging, no fake imputations
interactions[, ttc_2d := NA_real_] 
valid_idx <- which(interactions$dot_product > 0 & interactions$v_norm_sq > 0)
if(length(valid_idx) > 0) {
  interactions[valid_idx, ttc_2d := abs(dot_product / v_norm_sq)]
}

cat("[AI Agent] Extracting Scientifically Valid Control and Treatment Groups...\n")

# Treatment: Motorcycles in critical conditions (TTC <= 3s)
trt_base <- interactions[treatment == 1 & !is.na(ttc_2d) & ttc_2d <= 3 & distance <= 30]
trt_ids <- unique(trt_base$interaction_id)

# FIXED: Control group must represent NORMAL traffic, not extreme tracking errors
# We require TTC > 0.1 to drop ghost car errors, and take a pure RANDOM sample
ctrl_base <- interactions[treatment == 0 & !is.na(ttc_2d) & distance <= 40 & ttc_2d > 0.1 & ttc_2d < 15]
set.seed(42)
valid_ctrl_ids <- unique(ctrl_base$interaction_id)
ctrl_ids <- sample(valid_ctrl_ids, min(length(valid_ctrl_ids), 2500))

balanced_ids <- c(head(trt_ids, 2500), ctrl_ids)
filtered_df <- interactions[interaction_id %in% balanced_ids]

cat("[AI Agent] Aggregating final variables...\n")
if(nrow(filtered_df) > 0) {
  agg_df <- filtered_df[, .(
    initial_distance = distance[1],
    mean_rel_speed = mean(speed_val, na.rm = TRUE),
    duration_frames = .N,
    accel_rate = (speed_val[.N] - speed_val[1]) / .N,
    min_ttc_2d = min(ttc_2d, na.rm = TRUE),
    treatment = treatment[1] 
  ), by = interaction_id]
  
  # Remove impossible velocities (e.g. tracking jitters > 40 m/s relative speed)
  agg_df <- agg_df[!is.infinite(min_ttc_2d) & !is.na(min_ttc_2d) & !is.infinite(mean_rel_speed) & !is.na(mean_rel_speed)]
  agg_df <- agg_df[mean_rel_speed < 40] 
  
  cat("[AI Agent] Final TRUE Physical Group Distribution:\n")
  print(table(agg_df$treatment))
  
  saveRDS(agg_df, "data/conflict_events_2d.rds")
  cat("[AI Agent] Phase 2 Revision Complete! Ready for Phase 3.\n")
} else {
  cat("[AI Agent] Fatal Error: No converging interactions found.\n")
}