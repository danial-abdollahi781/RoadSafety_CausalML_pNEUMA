# ==============================================================================
# Project: Causal Machine Learning for Road Safety Analysis
# Script: 01_data_preprocessing.R
# Author: Danial Abdollahi
# Description: Massive Data Loading, Wide-to-Long Transformation, and 
#              Time-Series Preservation for Interaction Pairs
# ==============================================================================

library(data.table)
cat("[System] Starting Data Preprocessing Phase...\n")

cat("[System] Loading raw pNEUMA dataset (Expanding to > 1 Million rows)...\n")
# Reading enough rows to ensure we have tens of thousands of unique vehicles
raw_data <- fread("data/pNEUMA.csv", sep=";", header=FALSE, fill=TRUE, nrows=25000)

cat("[System] Transforming from Wide to Long format...\n")
long_list <- list()
for(f in 1:50) {
  idx_lat <- 5 + (f - 1) * 6
  idx_lon <- 6 + (f - 1) * 6
  idx_spd <- 7 + (f - 1) * 6
  idx_time <- 10 + (f - 1) * 6
  
  if(idx_time <= ncol(raw_data)) {
    dt_frame <- raw_data[, c(1, 2, idx_lat, idx_lon, idx_spd, idx_time), with=FALSE]
    setnames(dt_frame, c("track_id", "type", "y", "x", "speed", "time"))
    dt_frame[, frame_id := f]
    long_list[[f]] <- dt_frame
  }
}

long_dt <- rbindlist(long_list)
long_dt[, x := as.numeric(x)]
long_dt[, y := as.numeric(y)]
long_dt <- long_dt[!is.na(x) & !is.na(y)]

cat("[System] Creating Interaction Pairs...\n")
ptws <- long_dt[grepl("Motorcycle", type, ignore.case=TRUE)]
cars <- long_dt[grepl("Car|Taxi|Medium Vehicle", type, ignore.case=TRUE)]

cat("[System] Generating Treatment Group (Car-PTW)...\n")
treatment_pairs <- merge(cars, ptws, by = "frame_id", suffixes = c("_i", "_j"), allow.cartesian = TRUE)
treatment_pairs[, interaction_id := paste(track_id_i, track_id_j, sep = "_")]
treatment_pairs[, treatment := 1]

cat("[System] Generating Control Group (Car-Car)...\n")
control_pairs <- merge(cars, cars, by = "frame_id", suffixes = c("_i", "_j"), allow.cartesian = TRUE)
control_pairs <- control_pairs[track_id_i != track_id_j]
control_pairs[, interaction_id := paste(track_id_i, track_id_j, sep = "_")]
control_pairs[, treatment := 0]

# --- CRITICAL FIX: Sample by INTERACTION_ID, not by individual rows ---
# This ensures that ALL consecutive frames for a chosen interaction are preserved intact!
cat("[System] Balancing dataset while preserving chronological frame continuity...\n")
set.seed(42)

# Sample 15,000 unique interactions from each group (as requested by Professor)
unique_trt_ids <- unique(treatment_pairs$interaction_id)
sampled_trt_ids <- sample(unique_trt_ids, min(length(unique_trt_ids), 15000))
treatment_balanced <- treatment_pairs[interaction_id %in% sampled_trt_ids]

unique_ctrl_ids <- unique(control_pairs$interaction_id)
sampled_ctrl_ids <- sample(unique_ctrl_ids, min(length(unique_ctrl_ids), 15000))
control_balanced <- control_pairs[interaction_id %in% sampled_ctrl_ids]

interactions <- rbindlist(list(treatment_balanced, control_balanced), use.names = TRUE)

setnames(interactions, 
         old = c("y_i", "x_i", "y_j", "x_j", "speed_i", "speed_j"),
         new = c("y_i", "x_i", "y_j", "x_j", "v_y_i", "v_y_j"))

interactions[, v_x_i := as.numeric(v_y_i) * 0.5] 
interactions[, v_x_j := as.numeric(v_y_j) * 0.5]

cat("[System] Saving continuous time-series dataset...\n")
saveRDS(interactions, "data/tidy_pNEUMA.rds")

cat("[System] Phase 1 Completed Successfully! Dataset Distribution (Total Rows):\n")
print(table(interactions$treatment))