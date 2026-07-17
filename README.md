# 🏍️ Causal Machine Learning for Road Safety Analysis

![Status](https://img.shields.io/badge/Status-Completed-success?style=flat-square)
![Language](https://img.shields.io/badge/Language-R-blue?style=flat-square)
![Methodology](https://img.shields.io/badge/Methodology-Causal_Forest_%7C_Mahalanobis_PSM-orange?style=flat-square)
![Dataset](https://img.shields.io/badge/Dataset-pNEUMA_Drone_Trajectories-lightgrey?style=flat-square)

**Author:** Danial Abdollahi  
**Dataset:** pNEUMA (EPFL Drone Trajectory Data - Expanded to 1.5M+ Rows)  
**Methodology:** Generalized Random Forests (Causal Forest), Mahalanobis Distance Matching, and Rosenbaum Bounds Sensitivity Analysis  

---

## 📖 Project Overview
This repository contains a highly advanced analytical pipeline for evaluating the isolated, causal impact of Power-Two-Wheelers (PTWs) on traffic conflict severity. Moving beyond traditional models, this project employs a **Causal Machine Learning framework** (Stanford's `grf` package) using high-resolution drone trajectory data. 

A major technical achievement in this project was implementing a strict **25-frame continuous rolling filter (Run-Length Encoding)** to isolate 91 pristine, noise-free near-miss interactions from over 1.5 million trajectory records. Furthermore, we successfully overcame **Perfect Separation** by implementing targeted overlap sampling and Mahalanobis distance matching.

## 🏗️ Repository Structure

```text
📦 RoadSafety_CausalML_pNEUMA
 ┣ 📂 data
 ┃ ┣ 📜 pNEUMA.csv                  # Raw trajectory data
 ┃ ┣ 📜 tidy_pNEUMA.rds             # 1.5M perfectly balanced longitudinal records
 ┃ ┗ 📜 conflict_events_2d.rds      # Extracted 91 critical interactions (25-frame continuous)
 ┣ 📂 src
 ┃ ┣ 📜 01_data_preprocessing.R     # Massive Data Loading & Time-Series Preservation
 ┃ ┣ 📜 02_interaction_extraction.R # 2D Kinematics, Euclidean Dist & RLE Filtering
 ┃ ┣ 📜 03_causal_ml_psm.R          # Causal Forest & Rosenbaum Bounds Analysis
 ┃ ┗ 📜 04_results_visualization.R  # Publication-ready ggplot2 scientific charts
 ┣ 📂 output
 ┃ ┣ 📊 Table1_Descriptive_Statistics.csv
 ┃ ┣ 🖼️ Fig1_TTC_Boxplot.png        # Behavioral Boxplot
 ┃ ┣ 🖼️ Fig2_Speed_vs_TTC.png       # Scatter & LOESS Trend
 ┃ ┗ 🖼️ fig_cate_distribution.png   # CATE Distribution Density
 ┣ 📂 docs
 ┃ ┣ 📄 Manuscript_Fa.docx          # Persian Manuscript (Word)
 ┃ ┣ 📄 Manuscript_En.pdf           # English Manuscript (PDF)
 ┃ ┗ 📄 Manuscript_En.html          # English Manuscript (HTML)
 ┗ 📜 README.md                     # Project documentation
```

## 📊 Key Findings & Methodological Breakthroughs

* 📉 **Causal Impact (ATE):** The presence of motorcycles significantly reduces the Time-to-Collision (TTC) by an average of **-0.1026 seconds** compared to baseline traffic. PTWs actively consume safety margins in mixed traffic.
* 🎯 **Strict Interaction Filtering:** Translated raw trajectories into physical Euclidean spaces and applied a strict 1-second (25-frame) continuous threshold, isolating only true physical near-misses and eliminating sensor ghosting.
* 🤖 **Feature Importance (Causal Forest):** The Causal ML algorithm identified **Initial Distance (37.0%)** and **Relative Speed (33.0%)** as the primary drivers of collision risk.
* 🛡️ **Unconfounded Robustness (Rosenbaum Bounds):** The causal findings exhibited extreme resilience against hidden variables. Sensitivity testing (One-sided Wilcoxon) proved the results remain statistically significant ($p = 0.0059$) up to **Gamma = 3.0**.

## 🛠️ Pipeline Automation Status

| Phase | Module Name | Status |
| :--- | :--- | :---: |
| **Phase 1** | Strict 50/50 Baseline Balancing (1.5M Rows) | ✅ Completed |
| **Phase 2** | Euclidean Kinematics & 25-Frame RLE | ✅ Completed |
| **Phase 3** | Causal Forest & Mahalanobis PSM | ✅ Completed |
| **Phase 4** | Publication Visualizations | ✅ Completed |