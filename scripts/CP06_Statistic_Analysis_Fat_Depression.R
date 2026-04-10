# Load packages
library(tidyverse)
library(ggplot2)

# Load data
nhdf = read.csv("data/Processed data/nhanes_L_diet_depression_with_gender.csv")

glimpse(nhdf)
summary(nhdf)

# Remove the possible missing fat intake
nhdf_clean = nhdf %>%
  filter(!is.na(DR1TTFAT))

# Calculate the fat energy proportion
nhdf_clean = nhdf_clean %>%
  mutate(
    Fat_Kcal = DR1TTFAT * 9,
    Fat_Proportion = Fat_Kcal / DR1TKCAL
  )

# Clean the inappropriate proportion number
nhdf_clean = nhdf_clean %>%
  filter(Fat_Proportion >= 0, Fat_Proportion <= 1)

write_csv(nhdf_clean, "nhanes_fat_depression_statistic_analyses.csv")

# Descriptive statistics
summary_stats = nhdf_clean %>%
  summarise(
    Variable = c("Depression_Score", "Fat_Proportion"),
    Mean = c(
      mean(Depression_Score, na.rm = TRUE),
      mean(Fat_Proportion, na.rm = TRUE)
    ),
    SD = c(
      sd(Depression_Score, na.rm = TRUE),
      sd(Fat_Proportion, na.rm = TRUE)
    ),
    Median = c(
      median(Depression_Score, na.rm = TRUE),
      median(Fat_Proportion, na.rm = TRUE)
    ),
    IQR = c(
      IQR(Depression_Score, na.rm = TRUE),
      IQR(Fat_Proportion, na.rm = TRUE)
    )
  )

print(summary_stats)

write_csv(summary_stats, 
"output/CP06_Statistic_Analysis_Fat_Depression/summary_stats_cp06.csv")

# Scatterplot with regression line
f1 = ggplot(nhdf_clean, 
       aes(x = Fat_Proportion, 
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
    color = "black",             
    fill = "darkgreen",              
    linetype = "dashed",
    linewidth = 1.2,
    alpha = 0.2
  ) +
  labs(
    title = "Fat Proportion and Depression Scores",
    x = "Fat-Energy Proportion",
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

print(f1)

ggsave(
  filename = 
"output/CP06_Statistic_Analysis_Fat_Depression/Figure/Figure1_FatProportion_DepressionScore.png",
  plot = f1,
  width = 7,
  height = 5,
  dpi = 300
)

# Distribute depression score using histogram
mean_score = mean(nhdf_clean$Depression_Score, na.rm = TRUE)
median_score = median(nhdf_clean$Depression_Score, na.rm = TRUE)

f2 = ggplot(nhdf_clean, aes(x = Depression_Score)) +
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

print(f2)

ggsave(
"output/CP06_Statistic_Analysis_Fat_Depression/Figure/Figure2_DepressionScore_Histogram.png",
  width = 7,
  height = 5,
  dpi = 300
)

# Linear regression model
model1 = lm(Depression_Score ~ Fat_Proportion, data = nhdf_clean)

model_summary = summary(model1)
print(model_summary)

# Save coefficients table
model_coef = as.data.frame(model_summary$coefficients)
model_coef$Term = rownames(model_coef)
rownames(model_coef) = NULL

write_csv(model_coef, 
"output/CP06_Statistic_Analysis_Fat_Depression/linear_model_coefficients_cp06.csv")

# Save confidence intervals
model_ci = as.data.frame(confint(model1))
model_ci$Term = rownames(model_ci)
rownames(model_ci) = NULL
names(model_ci)[1:2] = c("CI_Lower", "CI_Upper")

write_csv(model_ci, 
"output/CP06_Statistic_Analysis_Fat_Depression/linear_model_confint_cp06.csv")

# Model diagnostics plots
png(
"output/CP06_Statistic_Analysis_Fat_Depression/Figure/Figure3_Model_Diagnostics.png", 
  width = 1200, 
  height = 1200, 
  res = 150)
par(mfrow = c(2, 2))
plot(model1)
dev.off()

# Additional assumption checks
shapiro_result = shapiro.test(residuals(model1))
print(shapiro_result)

capture.output(shapiro_result, file = 
        "output/CP06_Statistic_Analysis_Fat_Depression/shapiro_test_cp06.txt")

# Correlation as supplemental result
cor_test_result = cor.test(nhdf_clean$Fat_Proportion, 
                           nhdf_clean$Depression_Score)

print(cor_test_result)

capture.output(cor_test_result, file = 
    "output/CP06_Statistic_Analysis_Fat_Depression/correlation_test_cp06.txt")
