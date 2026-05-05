# VTPEH 6270 – Diet and Depression Analysis

This repository contains code and materials for VTPEH 6270 coursework. The project examines the relationship between dietary intake and depression scores using NHANES data and includes both data analysis and simulation studies.

---

## Author

Regina Hong MPH '27, Cornell University Food System and Health

## Contact

[yh2367@cornell.edu](mailto:yh2367@cornell.edu)

---

## Project Description

This repository contains data processing scripts and datasets for the VTPEH 6270 checkpoint assignment. The project processes NHANES dietary and mental health datasets mainly to examine the relationship between diet and depression.

---

## Research Question / Objectives

1. To assess the relationship between dietary intake (calories and macronutrients) and depression scores.
2. To evaluate how sample size, effect size, and noise influence regression estimates and statistical power.

---

## Final Report

The final report examines associations between macronutrient intakes (fat, carbohydrate, protein) and total energy intake with PHQ-9 depressive symptom scores using NHANES 2021–2023 data.

📄 **Report script file:** [`Final Report/Final_Report_Depression_Macronutrients.Rmd`](Final%20Report/Final_Report_Depression_Macronutrients.Rmd)

### To reproduce the report

1. Clone this repository
2. Open `R-6270.Rproj` in RStudio
3. Install required packages (automatically handled on first run):
   `tidyverse`, `ggplot2`, `knitr`, `kableExtra`, `corrplot`, `broom`, `car`, `lmtest`, `patchwork`, `rprojroot`
4. Place the following files in the `Final Report/` folder:
   - `nhanes_L_diet_depression_with_gender.csv`
   - `references.bib`
   - `american-medical-association.csl`
5. Open `Final_Report_Depression_Macronutrients.Rmd` and click **Knit**

> The working directory is set automatically using `rprojroot` — no manual path changes needed.

---

## Shiny App (CP07)

An interactive Shiny app has been developed to visualize and explore the analysis results.

🔗 **Live App:** [https://akaregina.shinyapps.io/Diet_Depression/](https://akaregina.shinyapps.io/Diet_Depression/)

### App Features

The app includes five interactive tabs:

- **Overview** – Key summary statistics and depression score distribution across the sample.
- **Data Explorer** – Interactive visualizations of dietary variables vs. depression scores, filterable by gender and age group.
- **Statistical Analysis** – Linear regression of dietary fat proportion on depression score, with model diagnostics and coefficient plots. Users can select predictors and subsets.
- **Power Simulation** – Explore how sample size, effect size, and noise level affect statistical power, with a live power curve and table.
- **Data Table** – Browse and download the filtered dataset.

### Running the App Locally

1. Clone this repository
2. Make sure the following R packages are installed:
   `shiny`, `shinydashboard`, `ggplot2`, `dplyr`, `DT`, `scales`, `bslib`, `shinyWidgets`, `plotly`
3. Open RStudio and run:

```r
shiny::runApp("shiny")
```

### Shiny App Files

```
Shiny app/
├── app.R
└── nhanes_L_diet_depression_with_gender.csv
```

---

## Data Source

Data were obtained from the National Health and Nutrition Examination Survey (NHANES) 2021–2023 cycle.
[https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/default.aspx?Cycle=2021-2023](https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes/default.aspx?Cycle=2021-2023)

---

## Processed Data

The main analysis uses a cleaned dataset:
`data/Processed data/nhanes_L_diet_depression_with_gender.csv`

This dataset has been preprocessed and is used directly for exploration, simulation, and the Shiny app.

---

## Data Description

The cleaned dataset focuses on dietary intake and depressive symptoms. The variables included in this analysis are described below:

| Variable | Type | Description |
|---|---|---|
| `SEQN` | ID | Unique participant identifier assigned by NHANES |
| `RIAGENDR` | Categorical | Biological sex (1 = Male, 2 = Female) |
| `RIDAGEYR` | Continuous | Age in years at time of survey |
| `Depression_Score` | Continuous | Depressive symptom severity (PHQ-9, 0–27) |
| `DR1TKCAL` | Continuous | Total daily energy intake (kcal) |
| `DR1TPROT` | Continuous | Total daily protein intake (g) |
| `DR1TCARB` | Continuous | Total daily carbohydrate intake (g) |
| `DR1TTFAT` | Continuous | Total daily fat intake (g) |
| `Gender` | Categorical | Gender label derived from RIAGENDR (Male / Female) |

All dietary variables are based on NHANES Day 1 24-hour dietary recall data.

---

## Repository Structure

```
R-6270/
├── data/
│   ├── Raw data/                    # Raw NHANES datasets (.xpt)
│   └── Processed data/              # Processed datasets (.csv)
│
├── scripts/
│   ├── exploration.R                # Exploratory data analysis
│   ├── simulation.R                 # Power simulation study
│   └── CP06_Statistic_Analysis_Fat_Depression.R
│
├── shiny/                           # CP07 Shiny App
│   ├── app.R                        # Main Shiny application
│   └── nhanes_L_diet_depression_with_gender.csv
│
├── Final Report/                    # Final Report (R Markdown + PDF)
│   ├── Final_Report_Depression_Macronutrients.Rmd
│   ├── Final_Report_Depression_Macronutrients.pdf
│   ├── references.bib
│   └── american-medical-association.csl
│
└── output/
    ├── Figure/                      # Exploration and simulation figures
    ├── Report/                      # Checkpoint reports
    └── CP06_Statistic_Analysis_Fat_Depression/
        ├── Figure/                  # CP06 regression and diagnostic plots
        └── ...                      # Model outputs and statistical results
```

---

## AI Tool Disclosure

ChatGPT and Claude were used to assist with instruction clarification, repository organization, instruction on Shiny app development, and debugging R code for reproducibility.
