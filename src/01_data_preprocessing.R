# Script: 01_data_preprocessing.R
# Description: Reads raw wide-format pNEUMA trajectory data and converts it to a tidy long-format.
# Author: AI Agent (Simulated)

# 1. Load required libraries
if (!require("data.table")) install.packages("data.table")
library(data.table)

message("[AI Agent] Initializing Data Preprocessing Module...")

# 2. Define dynamic paths based on the project root (Robust Agent Logic)
project_root <- getwd()
input_file <- file.path(project_root, "data", "pNEUMA.csv")
output_file <- file.path(project_root, "data", "tidy_pNEUMA.rds")

message("[AI Agent] Working directory confirmed as: ", project_root)

# 3. Check if input file exists
if (!file.exists(input_file)) {
  stop("Error: Raw data file 'pNEUMA.csv' not found in the 'data' directory.")
}

# 4. Read raw data (using a sample of 50,000 rows for memory optimization)
message("[AI Agent] Reading raw pNEUMA dataset...")
raw_data <- fread(input_file, nrows = 50000, header = TRUE, fill = TRUE)

# 5. Tidy the data (Wide to Long transformation)
message("[AI Agent] Transforming data to long format...")
long_dt <- melt(raw_data, id.vars = 1:4, variable.factor = FALSE)
long_dt <- long_dt[!is.na(value) & value != ""]
long_dt[, value := as.numeric(value)]

# 6. Reassign variables based on repeating physical pattern
var_names <- c("lat", "lon", "speed", "lon_acc", "lat_acc", "time")
long_dt[, var_type := rep(var_names, length.out = .N), by = track_id]
long_dt[, frame_number := rep(1:ceiling(.N/6), each = 6)[1:.N], by = track_id]

# 7. Cast back to wide format but grouped by frame_number (Tidy Format)
message("[AI Agent] Finalizing Tidy format...")
tidy_data <- dcast(long_dt, 
                   track_id + type + traveled_d + avg_speed + frame_number ~ var_type, 
                   value.var = "value")

# 8. Clean NAs and sort by time
tidy_data <- tidy_data[!is.na(time) & !is.na(lat) & !is.na(lon)]
setorder(tidy_data, track_id, time)

# 9. Save processed data for the next script
saveRDS(tidy_data, output_file)
message("[AI Agent] Preprocessing complete. Tidy data saved to 'data/tidy_pNEUMA.rds'")