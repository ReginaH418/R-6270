# VTPEH 6270 – Diet and Depression Analysis
This repository contains code and materials for VTPEH 6270 coursework.
The project examines the relationship between dietary intake and depression scores using NHANES data and includes both data analysis and simulation studies.

## Author
Regina Hong
MPH 27', Cornell University
Food System and Health

## Contact
[yh2367@cornell.edu]

## Project Description
This repository contains data processing scripts and datasets for the VTPEH 6270 checkpoint assignment. 
The project processes NHANES dietary and mental health datasets mainly to examine the relationship between diet and depression.

## Research Question / Objectives
1. To assess the relationship between dietary intake (calories and macronutrients) and depression scores.  
2. To evaluate how sample size, effect size, and noise influence regression estimates and statistical power.  

## Data Source
Data were obtained from the National Health and Nutrition Examination Survey (NHANES) 2021-2023 cycle.
https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/default.aspx?Cycle=2021-2023

### Processed Data
The main analysis uses a cleaned dataset:

`data/Processed data/nhanes_L_diet_depression_with_gender.csv`

This dataset has been preprocessed and is used directly for exploration and simulation.

### Data Description
The cleaned dataset focuses on dietary intake and depressive symptoms. The variables included in this analysis are described below:

- **SEQN**: Unique participant identifier assigned by NHANES, used to link records across datasets.  
- **RIAGENDR**: Categorical variable indicating biological sex of the participant (1 = Male, 2 = Female), as defined in NHANES.  
- **RIDAGEYR**: Continuous variable representing age in years at the time of the survey interview.  
- **Depression_Score**: Continuous variable measuring depressive symptom severity based on questionnaire responses (e.g., PHQ scale), with higher scores indicating more severe symptoms.  
- **DR1TKCAL**: Continuous variable representing total daily energy intake (kilocalories) based on 24-hour dietary recall.  
- **DR1TPROT**: Continuous variable indicating total daily protein intake (grams) derived from dietary recall data.  
- **DR1TCARB**: Continuous variable measuring total daily carbohydrate intake (grams) based on 24-hour dietary recall.  
- **DR1TTFAT**: Continuous variable representing total daily fat intake (grams) derived from dietary recall.  
- **Gender**: Categorical variable representing recorded gender for analysis (e.g., Male and Female), derived from RIAGENDR for improved interpretability.  

All dietary variables (DR1TKCAL, DR1TPROT, DR1TCARB, DR1TTFAT) are based on NHANES Day 1 24-hour dietary recall data.

## Repository Structure
data/  
Raw data/  
Contains raw NHANES datasets (.xpt)   
Processed data/  
Contains the processed datasets (.csv)  

scripts/  
exploration.R  
Performs exploratory data analysis including summary statistics and visualizations.  
simulation.R  
Runs simulation experiments examining how sample size, effect size, and noise influence statistical power.
CP06_Statistic_Analysis_Fat_Depression.R
Runs statistic analysis between fat proportion and depression score to explore the probable relationship.

output/
The outputs of subsequent check points after CP05 are included as a new folder.
Figure/  
All figures are saved in the output/Figure folder.  
Reports/  
Contains the reports of the past Check Points as reference and subsequent check points content.

## AI Tool Disclosure
ChatGPT was used to assist with instruction clarification, repository organization and debugging R code for reproducibility.