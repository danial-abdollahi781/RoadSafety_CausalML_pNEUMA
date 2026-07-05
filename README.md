# Causal Machine Learning for Road Safety Analysis
**Author:** Danial Abdollahi  
**Dataset:** pNEUMA (EPFL Drone Trajectory Data)  
**Methodology:** Caliper-enforced Propensity Score Matching (PSM) & Geospatial Interaction Tracking  

## 🤖 AI Agent Workflow & Completion Report

The automated pipeline has successfully processed the raw trajectory data and performed robust causal inference. Below is the summary of the generated artifacts:

| Phase | Module Name | Status | Artifact Link |
| :--- | :--- | :---: | :--- |
| **Phase 1** | Data Preprocessing (Wide to Long) | ✅ Completed | [tidy_pNEUMA.rds](data/tidy_pNEUMA.rds) |
| **Phase 2** | Interaction Extraction (TTC & Haversine) | ✅ Completed | [conflict_events.rds](data/conflict_events.rds) |
| **Phase 3** | Robust Causal ML (Caliper PSM) | ✅ Completed | [causal_inference_results.txt](output/causal_inference_results.txt) |
| **Phase 4** | Data Visualization (Love Plot, Density, Boxplot) | ✅ Completed | [output folder](output/) |

### 📊 Key Findings & Methodological Validation:
- **Covariate Balance Achieved:** Successfully eliminated bias in relative speed and distance using a strict caliper ($0.15$ standard deviations). Validated via Love Plot.
- **T-Test Results:** Statistical significance maintained ($p < 0.001$) after rigorous matching.
- **Causal Impact:** The presence of motorcycles significantly reduces the Time-to-Collision (TTC), physically shifting the density of critical interactions towards more severe conflict zones.