# 🏍️ Causal Machine Learning for Road Safety Analysis

![Status](https://img.shields.io/badge/Status-Completed-success?style=flat-square)
![Language](https://img.shields.io/badge/Language-R-blue?style=flat-square)
![Methodology](https://img.shields.io/badge/Methodology-Causal_ML_%7C_PSM-orange?style=flat-square)
![Dataset](https://img.shields.io/badge/Dataset-pNEUMA_Drone_Trajectories-lightgrey?style=flat-square)

**Author:** Danial Abdollahi  
**Dataset:** pNEUMA (EPFL Drone Trajectory Data)  
**Methodology:** Caliper-enforced Propensity Score Matching (PSM) & Geospatial Interaction Tracking  

---

## 📖 Project Overview
This repository contains the complete analytical pipeline and manuscript for evaluating the isolated, causal impact of Power-Two-Wheelers (PTWs) on traffic conflict severity. Moving beyond traditional correlation-based models, this project employs a **Causal Machine Learning framework** using high-resolution drone trajectory data to extract frame-by-frame physical interactions.

## 🏗️ Repository Structure
```text
📦 RoadSafety_CausalML_pNEUMA
 ┣ 📂 data
 ┃ ┣ 📜 pNEUMA.csv                  # Raw trajectory data
 ┃ ┣ 📜 tidy_pNEUMA.rds             # Preprocessed longitudinal data
 ┃ ┗ 📜 conflict_events.rds         # Extracted critical interactions
 ┣ 📂 src
 ┃ ┣ 📜 01_data_preprocessing.R     # Wide-to-long transformation
 ┃ ┣ 📜 02_interaction_extraction.R # Haversine & TTC calculations
 ┃ ┣ 📜 03_causal_ml_psm.R          # Caliper-enforced PSM model
 ┃ ┗ 📜 04_visualization.R          # Publication-ready ggplot2 scripts
 ┣ 📂 output
 ┃ ┣ 📜 causal_inference_results.txt
 ┃ ┣ 🖼️ fig_covariate_balance.png   # Love Plot
 ┃ ┣ 🖼️ fig_ttc_boxplot.png
 ┃ ┗ 🖼️ fig_ttc_density.png
 ┣ 📂 docs
 ┃ ┣ 📄 Manuscript_Fa.docx          # Persian Manuscript (Word)
 ┃ ┣ 📄 Manuscript_En.pdf           # English Manuscript (PDF)
 ┃ ┗ 📄 Manuscript_En.html          # English Manuscript (HTML)
 ┗ 📜 README.md                     # Project documentation
🤖 AI Agent Workflow & DeliverablesThe automated pipeline has successfully processed the raw trajectory data, performed robust causal inference, and generated the final academic manuscripts.PhaseModule NameStatusArtifact LinkPhase 1Data Preprocessing (Wide to Long)✅ Completeddata/tidy_pNEUMA.rdsPhase 2Interaction Extraction (TTC & Haversine)✅ Completeddata/conflict_events.rdsPhase 3Robust Causal ML (Caliper PSM)✅ Completedoutput/causal_inference_results.txtPhase 4Data Visualization (Plots)✅ Completedoutput/Phase 5Final Manuscript (Fa/En)✅ Completeddocs/📄 Final Publications (Manuscripts):🇮🇷 Persian Manuscript (Word)🇬🇧 English Manuscript (PDF)🌐 English Manuscript (HTML)📊 Key Findings & Methodological Validation🎯 Covariate Balance Achieved: Successfully eliminated bias in relative speed and distance using a strict caliper ($0.15$ standard deviations). Validated via Love Plot.📉 Causal Impact: The presence of motorcycles significantly reduces the Time-to-Collision (TTC) from 1.35s to 1.23s, physically shifting the density of critical interactions towards more severe conflict zones.🔬 Statistical Significance: T-Test results maintained extreme statistical significance ($p < 0.001$) after rigorous matching, proving the inherent risk factor of PTWs in mixed traffic.