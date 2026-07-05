# Script: 02_interaction_extraction.R
# Description: Extracts near-miss events and calculates TTC using geospatial interactions.
# Author: AI Agent (Simulated)

# 1. Load required libraries
if (!require("data.table")) install.packages("data.table")
if (!require("geosphere")) install.packages("geosphere")
library(data.table)
library(geosphere)

message("[AI Agent] Initializing Interaction Extraction Module...")

# 2. Define dynamic paths
project_root <- getwd()
input_file <- file.path(project_root, "data", "tidy_pNEUMA.rds")
output_file <- file.path(project_root, "data", "conflict_events.rds")

if (!file.exists(input_file)) {
  stop("Error: Processed data 'tidy_pNEUMA.rds' not found. Please run Script 01 first.")
}

# 3. Load the tidy dataset
message("[AI Agent] Loading Tidy dataset...")
tidy_data <- readRDS(input_file)

# 4. Extract critical interactions frame by frame
message("[AI Agent] Computing pairwise interactions and TTC (This may take a minute)...")
unique_times <- unique(tidy_data$time)

critical_events_list <- lapply(unique_times, function(t) {
  v_frame <- tidy_data[time == t]
  if(nrow(v_frame) < 2) return(NULL)
  
  p <- CJ(id1 = v_frame$track_id, id2 = v_frame$track_id)
  p <- p[id1 < id2]
  
  p <- merge(p, v_frame[, .(id1 = track_id, lon1 = lon, lat1 = lat, speed1_kmh = speed, type1 = type)], by = "id1")
  p <- merge(p, v_frame[, .(id2 = track_id, lon2 = lon, lat2 = lat, speed2_kmh = speed, type2 = type)], by = "id2")
  
  p[, distance_m := distHaversine(matrix(c(lon1, lat1), ncol = 2), matrix(c(lon2, lat2), ncol = 2))]
  p[, speed1_ms := speed1_kmh / 3.6]
  p[, speed2_ms := speed2_kmh / 3.6]
  p[, relative_speed_ms := abs(speed1_ms - speed2_ms)]
  p[, ttc_seconds := ifelse(relative_speed_ms > 0, distance_m / relative_speed_ms, Inf)]
  
  # Physical constraints filter (1.5m to 30m, TTC < 3s)
  return(p[distance_m > 1.5 & distance_m < 30 & ttc_seconds < 3, 
           .(time = t, id1, type1, id2, type2, distance_m, relative_speed_ms, ttc_seconds)])
})

real_near_misses <- rbindlist(critical_events_list)

# 5. Aggregate frames into unique conflict events
message("[AI Agent] Aggregating frames into unique conflict events...")
unique_conflict_events <- real_near_misses[, .(
  min_ttc_sec = min(ttc_seconds),
  max_relative_speed = max(relative_speed_ms),
  avg_distance_m = mean(distance_m),
  duration_frames = .N,
  start_time = min(time),
  end_time = max(time)
), by = .(id1, type1, id2, type2)]

# 6. Filter noise (require at least 3 frames of interaction)
valid_conflicts <- unique_conflict_events[duration_frames >= 3]
setorder(valid_conflicts, min_ttc_sec)

# 7. Save output
saveRDS(valid_conflicts, output_file)
message("[AI Agent] Extraction complete. Valid conflicts saved to 'data/conflict_events.rds'")