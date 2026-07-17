# 🏍️ Causal Machine Learning for Road Safety Analysis

![Status](https://img.shields.io/badge/Status-Completed-success?style=flat-square)
![Language](https://img.shields.io/badge/Language-R-blue?style=flat-square)
![Methodology](https://img.shields.io/badge/Methodology-Causal_Forest_%7C_Mahalanobis_PSM-orange?style=flat-square)
![Dataset](https://img.shields.io/badge/Dataset-pNEUMA_Drone_Trajectories-lightgrey?style=flat-square)

**Author:** Danial Abdollahi  
**Dataset:** pNEUMA (EPFL Drone Trajectory Data - 1.2M+ Rows)  
**Methodology:** Generalized Random Forests (Causal Forest), Mahalanobis Distance Matching, and Rosenbaum Bounds Sensitivity Analysis  

---

## 📖 Project Overview
This repository contains a highly advanced analytical pipeline for evaluating the isolated, causal impact of Power-Two-Wheelers (PTWs) on traffic conflict severity. Moving beyond traditional models, this project employs a **Causal Machine Learning framework** (Stanford's `grf` package) using high-resolution drone trajectory data. 

A major technical achievement in this project was successfully overcoming **Perfect Separation** (0/1 Propensity Score boundaries) by implementing targeted overlap sampling and Mahalanobis distance matching, ensuring mathematically rigorous control-treatment balancing.

## 🏗️ Repository Structure

```text
📦 RoadSafety_CausalML_pNEUMA
 ┣ 📂 data
 ┃ ┣ 📜 pNEUMA.csv                  # Raw trajectory data
 ┃ ┣ 📜 tidy_pNEUMA.rds             # 1.2M perfectly balanced longitudinal records
 ┃ ┗ 📜 conflict_events_2d.rds      # Extracted critical interactions with physical TTC
 ┣ 📂 src
 ┃ ┣ 📜 01_data_preprocessing.R     # Massive Data Loading & Cartesian Merge
 ┃ ┣ 📜 02_interaction_extraction.R # 2D Kinematics & Natural Control Group Extraction
 ┃ ┣ 📜 03_causal_ml_psm.R          # Causal Forest & Rosenbaum Bounds Analysis
 ┃ ┗ 📜 04_results_visualization.R  # Publication-ready ggplot2 scientific charts
 ┣ 📂 output
 ┃ ┣ 📊 Table1_Descriptive_Statistics.csv
 ┃ ┣ 🖼️ Fig1_TTC_Boxplot.png        # Behavioral Boxplot
 ┃ ┣ 🖼️ Fig2_Speed_vs_TTC.png       # Scatter & LOESS Trend
 ┃ ┗ 🖼️ fig_cate_distribution.png   # CATE Distribution Density
 ┣ 📂 docs
 ┃ ┣ 📄 Manuscript_Fa.docx          
 ┃ ┣ 📄 Manuscript_En.pdf           
 ┃ ┗ 📄 Manuscript_En.html          
 ┗ 📜 README.md                     # Project documentation
```

## 📊 Key Findings & Methodological Breakthroughs

* 📉 **Causal Impact (ATE):** The presence of motorcycles significantly reduces the Time-to-Collision (TTC) by an average of **-2.11 seconds** compared to baseline traffic. PTWs actively consume safety margins in mixed traffic.
* 🎯 **Overcoming Perfect Separation:** Bypassed logistic regression failures caused by extreme group behavioral differences using **Mahalanobis Distance Matching**, enabling robust pairwise comparisons.
* 🤖 **Feature Importance (Causal Forest):** The Causal ML algorithm identified **Relative Speed (45.6%)** and **Acceleration Rate (25.4%)** as the primary drivers of collision risk, overtaking initial distance.
* 🛡️ **Unconfounded Robustness (Rosenbaum Bounds):** The causal findings exhibited extreme resilience against hidden variables. Sensitivity testing proved the results remain statistically valid up to **Gamma = 2.8**, meaning an unobserved confounder would need to alter the odds of risk by 2.8 times to invalidate this study's conclusions.

## 🛠️ Pipeline Automation Status

| Phase | Module Name | Status |
| :--- | :--- | :---: |
| **Phase 1** | Strict 50/50 Baseline Balancing | ✅ Completed |
| **Phase 2** | Dynamic dt Kinematics & TTC | ✅ Completed |
| **Phase 3** | Causal Forest & Mahalanobis PSM | ✅ Completed |
| **Phase 4** | Publication Visualizations | ✅ Completed |