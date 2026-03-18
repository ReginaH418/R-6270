# VTPEH 6270 – Data Exploration Script
# Author: Regina Hong
# Description: Exploratory analysis of NHANES diet and depression data

# Load packages
library(tidyverse)
library(ggplot2)

# 1 Load data
data_nhdm = read.csv("data/nhanes_L_diet_depression_with_gender.csv")

glimpse(data_nhdm)
summary(data_nhdm)

# 2 Distribute depression score using histogram
mean_score = mean(data_nhdm$Depression_Score, na.rm = TRUE)
median_score = median(data_nhdm$Depression_Score, na.rm = TRUE)

ggplot(data_nhdm, aes(x = Depression_Score)) +
  geom_histogram(
    binwidth = 1,
    boundary = -0.5,
    fill = "steelblue",              
    color = "white",               
    alpha = 0.8                    
  ) +
  geom_vline(
    aes(xintercept = mean_score),
    color = "red",           
    linetype = "dashed",
    linewidth = 1
  ) +
  geom_vline(
    aes(xintercept = median_score),
    color = "darkblue",            
    linetype = "solid",
    linewidth = 1
  ) +
  annotate("text", x = mean_score, y = Inf, 
           label = paste("Mean =", round(mean_score, 2)),
           vjust = 5, 
           hjust = -0.1,
           color = "red", fontface = "bold") +
  annotate("text", x = median_score, y = Inf,
           label = paste("Median =", round(median_score, 2)),
           vjust = 1,
           hjust = -0.1,
           color = "darkblue", fontface = "bold") +
  labs(
    title = "Distribution of Depression Scores",
    x = "Depression Score (0-27)",
    y = "Frequency"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  ) +
  scale_x_continuous(breaks = seq(0, 27, 3))

ggsave(
  "output/histogram_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)

# 3 Depression score by gender
ggplot(data_nhdm,
       aes(x = Gender,
           y = Depression_Score,
           fill = Gender)) +
  geom_violin(
    width = 0.8,
    alpha = 0.7,
    color = NA,
    trim = FALSE
  ) +
  geom_boxplot(
    width = 0.15,
    outlier.shape = NA,
    fill = "white",
    color = "black"
  ) +
  labs(
    title = "Distribution of Depression Scores by Gender",
    x = "Gender",
    y = "Depression Score"
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    legend.position = "none"
  )

ggsave(
  "output/violin_gender_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)

# 4 Scatterplots of diet variables vs depression score

# Protein intake
ggplot(data_nhdm, 
       aes(x = DR1TPROT, 
           y = Depression_Score, 
           color = Gender)) +
  geom_point(
    alpha = 0.8,                   
    size = 2.5,                    
    shape = 16                     
  ) +
  geom_smooth(
    method = "lm",                 
    se = TRUE,              
    color = "darkgreen",             
    fill = "grey",              
    linetype = "dashed",
    linewidth = 1.2,
    alpha = 0.2
  ) +
  labs(
    title = "Protein Intake and Depression Scores",
    x = "Daily Protein Intake (g)",
    y = "Depression Score (0-27)",
    color = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  ) 

ggsave(
  "output/scatter_protein_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)

# Carbohydrate intake
ggplot(data_nhdm, 
       aes(x = DR1TCARB, 
           y = Depression_Score, 
           color = Gender)) +
  geom_point(
    alpha = 0.8,                   
    size = 2.5,                    
    shape = 16                     
  ) +
  geom_smooth(
    method = "lm",                 
    se = TRUE,              
    color = "darkgreen",             
    fill = "grey",              
    linetype = "dashed",
    linewidth = 1.2,
    alpha = 0.2
  ) +
  labs(
    title = "Carbohydrate Intake and Depression Scores",
    x = "Daily Carbohydrate Intake (g)",
    y = "Depression Score (0-27)",
    color = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  ) 

ggsave(
  "output/scatter_carb_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)

# Fat intake
ggplot(data_nhdm, 
       aes(x = DR1TTFAT, 
           y = Depression_Score, 
           color = Gender)) +
  geom_point(
    alpha = 0.8,                   
    size = 2.5,                    
    shape = 16                     
  ) +
  geom_smooth(
    method = "lm",                 
    se = TRUE,              
    color = "darkgreen",             
    fill = "grey",              
    linetype = "dashed",
    linewidth = 1.2,
    alpha = 0.2
  ) +
  labs(
    title = "Fat Intake and Depression Scores",
    x = "Daily Fat Intake (g)",
    y = "Depression Score (0-27)",
    color = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  ) 

ggsave(
  "output/scatter_fat_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)

# Total energy intake
ggplot(data_nhdm, 
       aes(x = DR1TKCAL, 
           y = Depression_Score, 
           color = Gender)) +
  geom_point(
    alpha = 0.8,                   
    size = 2.5,                    
    shape = 16                     
  ) +
  geom_smooth(
    method = "lm",                 
    se = TRUE,              
    color = "darkgreen",             
    fill = "grey",              
    linetype = "dashed",
    linewidth = 1.2,
    alpha = 0.2
  ) +
  labs(
    title = "Energy Intake and Depression Scores",
    x = "Daily Energy Intake (kcal)",
    y = "Depression Score (0-27)",
    color = "Gender"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  ) 

ggsave(
  "output/scatter_energy_depression.png",
  width = 7,
  height = 5,
  dpi = 300
)
