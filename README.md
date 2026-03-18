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

`data/nhanes_L_diet_depression_with_gender.csv`

This dataset includes:
1. Depression score (PHQ-9 total, range 0–27)
2. Dietary intake variables (calories, protein, carbohydrate, fat)
3. Demographic variables (including gender)

This dataset has been preprocessed and is used directly for exploration and simulation.

## Repository Structure
data/  
Raw data/
Contains raw NHANES datasets (.xpt) 
Processed data/
Contains the processed datasets (.csv).

scripts/  
exploration.R  
Performs exploratory data analysis including summary statistics and visualizations.
simulation.R  
Runs simulation experiments examining how sample size, effect size, and noise influence statistical power.
nhanes_merge_diet_mentalhealth.R  
Shows the processes of NHANES datasets and creates the merged dataset used for analysis. The processed dataset was directly used in the exploration and simulation scripts.

output/
Figure/
All figures are saved in the output/Figure folder.
Reports/
Contains the reports of the past Check Points as reference.

## AI Tool Disclosure
ChatGPT was used to assist with instruction clarification, repository organization and debugging R code for reproducibility.