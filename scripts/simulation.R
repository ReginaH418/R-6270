# VTPEH 6270 – Simulation Study
# Goal: Examine statistical power across different
# sample sizes, effect sizes, and noise levels.

# Create output folder if not exists
if(!dir.exists("output")){
  dir.create("output")
}

if(!dir.exists("output/Figure")){
  dir.create("output/Figure")
}

# Install packages if not exists
packages <- c("tidyverse", "ggplot2")

for(p in packages){
  if(!require(p, character.only = TRUE)){
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

library(tidyverse)
library(ggplot2)
set.seed(123)

# Parameter settings
sample_sizes = c(50, 100, 150, 200, 300, 400, 500, 700, 900, 1200)
effect_sizes = seq(0, 0.008, 0.002)
noise_levels = c(1, 2, 3)
n_rep = 500

# Simulation function
simulate_dataset = function(n, beta, noise_sd) {
  # Simulate dietary intake
  x = rnorm(n, mean = 250, sd = 60)
  # Generate depression score
  # Baseline depression level set around 8 to mimic realistic PHQ-9 scores
  y = 8 + beta * x + rnorm(n, 0, noise_sd)
  # Restrict depression score to PHQ-9 range
  y[y < 0] = 0
  y[y > 27] = 27
  model = lm(y ~ x)
  # Extract p value for slope
  p_value = summary(model)$coefficients[2, 4]  
  
  return(p_value)
}

# Run simulation
results = expand.grid(
  sample_size = sample_sizes,
  effect_size = effect_sizes,
  noise_sd = noise_levels,
  rep = 1:n_rep
)

results$p_value = NA
results$significant = NA

for(i in 1:nrow(results)){
  results$p_value[i] = simulate_dataset(
    results$sample_size[i],
    results$effect_size[i],
    results$noise_sd[i]
  )  
  results$significant[i] = results$p_value[i] < 0.05
}

# Summarize power
df_power = results %>%
  group_by(effect_size, sample_size, noise_sd) %>%
  summarise(
    power = mean(significant),
    .groups = "drop"
  )

# Prepare for plotting
df_power$sample_size = factor(
  df_power$sample_size,
  levels = c(50,100,150,200,300,400,500,700,900,1200)
)

# Heatmap
ggplot(df_power,
       aes(x = sample_size,
           y = effect_size,
           fill = power)) +
  geom_tile(color = "white") +
  facet_wrap(~noise_sd, nrow = 1,
             labeller = labeller(noise_sd = 
                                   function(x) paste("Noise SD =", x))) +
  scale_fill_viridis_c(limits = c(0, 1)) +
  scale_y_continuous(
    breaks = seq(0,0.008,0.002)
  ) +
  labs(
    title = "Statistical Power Across Simulation Settings",
    subtitle = "Each cell shows the proportion of significant slopes across 
    500 simulations",
    x = "Sample Size",
    y = "True Effect Size",
    fill = "Power"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )

ggsave(
  "output/Figure/power_heatmap.png",
  width = 10,
  height = 5,
  dpi = 300
)