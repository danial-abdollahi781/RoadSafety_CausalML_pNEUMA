# Causal Machine Learning for Road Safety Analysis
**Dataset:** pNEUMA (EPFL Drone Trajectory Data)  
**Methodology:** Propensity Score Matching (PSM) & Geospatial Interaction Tracking  

## 🤖 AI Agent Workflow & Completion Report

The automated pipeline has successfully processed the raw trajectory data and performed causal inference. Below is the summary of the generated artifacts:

| Phase | Module Name | Status | Artifact Link |
| :--- | :--- | :---: | :--- |
| **Phase 1** | Data Preprocessing (Wide to Long) | ✅ Completed | [tidy_pNEUMA.rds](data/tidy_pNEUMA.rds) |
| **Phase 2** | Interaction Extraction (TTC & Haversine) | ✅ Completed | [conflict_events.rds](data/conflict_events.rds) |
| **Phase 3** | Causal ML (Propensity Score Matching) | ✅ Completed | [causal_inference_results.txt](output/causal_inference_results.txt) |

### Key Findings:
- Successfully matched **4,858** conflict events using Nearest Neighbor PSM.
- **T-Test Results:** Statistical significance achieved ($p < 0.001$).
- **Causal Impact:** The presence of motorcycles significantly reduces the Time-to-Collision (TTC) from 1.35s to 1.23s, increasing conflict severity.