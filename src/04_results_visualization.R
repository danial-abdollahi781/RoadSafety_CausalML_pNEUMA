# ==============================================================================
# Script: 04_results_visualization.R
# AI Agent: Claude 3.5 Sonnet (Anthropic)
# Task: Publication-Quality Figures and Tables for the Final Paper
# ==============================================================================

library(data.table)
library(ggplot2)

cat("[AI Agent] Initializing Phase 4: Publication Visualization...\n")

agg_df <- readRDS("data/conflict_events_2d.rds")
setDT(agg_df)

agg_df[, interaction_type := factor(treatment, 
                                    levels = c(0, 1), 
                                    labels = c("Car-Car (Baseline)", "Motorcycle-Car (Treatment)"))]

if(!dir.exists("output")) dir.create("output")

cat("[AI Agent] Generating Table 1: Descriptive Statistics...\n")
summary_stats <- agg_df[, .(
  Total_Interactions = .N,
  Mean_TTC_Seconds = round(mean(min_ttc_2d, na.rm=TRUE), 2),
  SD_TTC = round(sd(min_ttc_2d, na.rm=TRUE), 2),
  Mean_Relative_Speed = round(mean(mean_rel_speed, na.rm=TRUE), 2),
  SD_Relative_Speed = round(sd(mean_rel_speed, na.rm=TRUE), 2),
  Mean_Distance_Meters = round(mean(initial_distance, na.rm=TRUE), 2)
), by = interaction_type]

write.csv(summary_stats, "output/Table1_Descriptive_Statistics.csv", row.names = FALSE)
print(summary_stats)

cat("[AI Agent] Generating Figure 1: TTC Boxplot...\n")
p1 <- ggplot(agg_df, aes(x = interaction_type, y = min_ttc_2d, fill = interaction_type)) +
  geom_boxplot(alpha = 0.8, outlier.shape = 21, outlier.fill = "white", outlier.alpha = 0.5) +
  scale_fill_manual(values = c("#34495e", "#e74c3c")) + 
  theme_minimal(base_size = 14) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold")) +
  labs(title = "Time-to-Collision (TTC) by Interaction Type",
       subtitle = "Comparing safety margins: Motorcycles vs. Standard Traffic",
       x = "Interaction Category",
       y = "Minimum TTC (Seconds)")

suppressWarnings(ggsave("output/Fig1_TTC_Boxplot.png", plot = p1, width = 8, height = 6, dpi = 300))

cat("[AI Agent] Generating Figure 2: Speed vs. Safety Margin Scatter/Trend...\n")
p2 <- ggplot(agg_df, aes(x = mean_rel_speed, y = min_ttc_2d, color = interaction_type)) +
  geom_point(alpha = 0.2, size = 1.5) +
  geom_smooth(method = "loess", se = TRUE, linewidth = 1.2) +
  scale_color_manual(values = c("#34495e", "#e74c3c")) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom", 
        legend.title = element_blank(),
        plot.title = element_text(face = "bold")) +
  labs(title = "Impact of Relative Speed on Time-to-Collision",
       subtitle = "Diverging safety behaviors at higher relative velocities",
       x = "Mean Relative Speed (m/s)",
       y = "Minimum TTC (Seconds)")

suppressWarnings(ggsave("output/Fig2_Speed_vs_TTC.png", plot = p2, width = 9, height = 6, dpi = 300))

cat("[AI Agent] Phase 4 Completed! All publication assets saved in the 'output' folder.\n")