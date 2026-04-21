# ============================================================
# VTPEH 6270 – Check Point 07: Shiny App
# Topic: Dietary Fat and Depression: An NHANES Analysis
# Author: Regina Hong
# ============================================================

# --- 0. Load packages ---
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)
library(scales)
library(bslib)
library(shinyWidgets)

# --- 1. Load & prepare data ---
# Adjust path as needed
nhdf_raw <- read.csv("nhanes_L_diet_depression_with_gender.csv")

nhdf <- nhdf_raw %>%
  filter(!is.na(DR1TTFAT), DR1TKCAL > 0) %>%
  mutate(
    Fat_Kcal       = DR1TTFAT * 9,
    Fat_Proportion = Fat_Kcal / DR1TKCAL,
    Age_Group      = cut(RIDAGEYR,
                         breaks = c(17, 30, 45, 60, 80),
                         labels = c("18-30", "31-45", "46-60", "61-80")),
    Depression_Cat = case_when(
      Depression_Score <= 4  ~ "Minimal (0-4)",
      Depression_Score <= 9  ~ "Mild (5-9)",
      Depression_Score <= 14 ~ "Moderate (10-14)",
      TRUE                   ~ "Severe (15+)"
    ),
    Depression_Cat = factor(Depression_Cat,
                            levels = c("Minimal (0-4)", "Mild (5-9)",
                                       "Moderate (10-14)", "Severe (15+)"))
  ) %>%
  filter(Fat_Proportion >= 0, Fat_Proportion <= 1)

# --- 2. Colour palette ---
col_gender <- c("Female" = "#E07B9A", "Male" = "#5B9BD5")
col_dep    <- c("Minimal (0-4)"    = "#2a9d8f",
                "Mild (5-9)"       = "#e9c46a",
                "Moderate (10-14)" = "#f4a261",
                "Severe (15+)"     = "#e63946")

theme_app <- theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 15, hjust = 0.5),
    plot.subtitle    = element_text(hjust = 0.5, color = "grey40", size = 11),
    axis.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )

# ---- 3. Helper: power simulation function ----
run_power_sim <- function(sample_sizes, effect_size, noise_sd, n_rep = 500) {
  set.seed(42)
  results <- expand.grid(n = sample_sizes, rep = seq_len(n_rep))
  results$significant <- mapply(function(n, ...) {
    x <- rnorm(n, mean = 0.35, sd = 0.12)   # fat proportion
    y <- 8 + effect_size * n * x + rnorm(n, 0, noise_sd)
    y <- pmax(0, pmin(27, y))
    p <- summary(lm(y ~ x))$coefficients[2, 4]
    p < 0.05
  }, results$n)

  results %>%
    group_by(n) %>%
    summarise(power = mean(significant), .groups = "drop")
}

# ============================================================
# UI
# ============================================================
ui <- fluidPage(
  title = "Diet & Depression Explorer",

  # ---- Custom CSS ----
  tags$head(tags$style(HTML("
    body { background-color: #f8f9fb; font-family: 'Segoe UI', sans-serif; }

    .navbar-custom {
      background: linear-gradient(135deg, #2c3e50, #3498db);
      padding: 14px 28px;
      display: flex; align-items: center; gap: 16px;
    }
    .navbar-custom h1 {
      color: white; margin: 0; font-size: 22px; font-weight: 700;
    }
    .navbar-custom p { color: #cce4ff; margin: 0; font-size: 13px; }

    .tab-content { padding-top: 20px; }

    /* Nav tabs */
    .nav-tabs > li > a {
      color: #2c3e50 !important; font-weight: 600;
      border-radius: 8px 8px 0 0 !important;
    }
    .nav-tabs > li.active > a {
      background-color: #3498db !important;
      color: white !important;
      border-color: #3498db !important;
    }

    /* Sidebar panels */
    .well { background: #ffffff; border: 1px solid #dde3ec;
            border-radius: 10px; box-shadow: 0 1px 4px rgba(0,0,0,.06); }

    /* KPI cards */
    .kpi-box {
      background: white; border-radius: 10px;
      border-left: 5px solid #3498db;
      padding: 14px 18px; margin-bottom: 12px;
      box-shadow: 0 1px 4px rgba(0,0,0,.08);
    }
    .kpi-box .kpi-val { font-size: 26px; font-weight: 700; color: #2c3e50; }
    .kpi-box .kpi-lbl { font-size: 12px; color: #888; text-transform: uppercase;
                        letter-spacing: .5px; }
    .kpi-box.k2 { border-left-color: #e07b9a; }
    .kpi-box.k3 { border-left-color: #2a9d8f; }
    .kpi-box.k4 { border-left-color: #f4a261; }

    /* Section headers */
    .section-header {
      background: linear-gradient(90deg, #3498db15, transparent);
      border-left: 4px solid #3498db;
      padding: 8px 14px; border-radius: 4px;
      font-weight: 700; font-size: 15px; color: #2c3e50;
      margin-bottom: 14px;
    }

    /* Footer */
    .app-footer { text-align: center; color: #aaa; font-size: 12px;
                  padding: 20px 0; margin-top: 30px; }

    .plot-card { background: white; border-radius: 10px; padding: 16px;
                 box-shadow: 0 1px 5px rgba(0,0,0,.07); }
  "))),

  # ---- Header ----
  div(class = "navbar-custom",
      icon("heartbeat", lib = "font-awesome",
           style = "color:white; font-size:28px;"),
      div(
        tags$h1("Dietary Macronutrients & Depression Explorer"),
        tags$p("NHANES Cycle L (2021–2023)  ·  n = 4,528")
      ),
      # Put the icon at the upper right corner
      tags$a(
        href   = "https://github.com/ReginaH418/R-6270",
        target = "_blank",
        style  = "margin-left:auto; color:white; font-size:24px;",
        icon("github", lib = "font-awesome")
      )
  ),
  
  # ---- Main tabs ----
  tabsetPanel(id = "main_tabs", type = "tabs",

    # ======================================================
    # TAB 1 – OVERVIEW
    # ======================================================
    tabPanel("📊 Overview",
      br(),
      fluidRow(
        column(3, div(class = "kpi-box",
          div(class = "kpi-val", format(nrow(nhdf), big.mark=",")),
          div(class = "kpi-lbl", "Total Participants")
        )),
        column(3, div(class = "kpi-box k2",
          div(class = "kpi-val",
              paste0(round(mean(nhdf$Gender == "Female") * 100), "%")),
          div(class = "kpi-lbl", "Female")
        )),
        column(3, div(class = "kpi-box k3",
          div(class = "kpi-val",
              round(mean(nhdf$Depression_Score), 1)),
          div(class = "kpi-lbl", "Mean Depression Score (PHQ-9)")
        )),
        column(3, div(class = "kpi-box k4",
          div(class = "kpi-val",
              paste0(round(mean(nhdf$Fat_Proportion) * 100, 1), "%")),
          div(class = "kpi-lbl", "Mean Fat-Energy Proportion")
        ))
      ),

      fluidRow(
        column(6,
          div(class = "section-header", "Depression Score Distribution"),
          div(class = "plot-card", plotOutput("hist_dep", height = 300))
        ),
        column(6,
          div(class = "section-header", "Depression Severity Breakdown"),
          div(class = "plot-card", plotOutput("pie_dep", height = 300))
        )
      ),

      br(),
      fluidRow(
        column(12,
          div(class = "section-header", "About This App"),
          wellPanel(
            tags$p(
              tags$b("Research Question:"),
              " Is dietary fat intake (as a proportion of total energy) associated with
               depression symptoms in US adults, as measured by the PHQ-9?"
            ),
            tags$p(
              "This app allows you to explore NHANES data from 2021–2023.
               Navigate the tabs above to:"
            ),
            tags$ul(
              tags$li(tags$b("Data Explorer –"), " visualise relationships between diet and depression by gender, age group, or macronutrient."),
              tags$li(tags$b("Statistical Analysis –"), " run and display a linear regression of fat proportion on depression scores."),
              tags$li(tags$b("Power Simulation –"), " investigate how sample size and effect size influence statistical power.")
            ),
            tags$p(
              tags$b("Data source: "),
              "National Health and Nutrition Examination Survey (NHANES), CDC, Cycle L."
            )
          )
        )
      )
    ), # end Tab 1

    # ======================================================
    # TAB 2 – DATA EXPLORER
    # ======================================================
    tabPanel("🔍 Data Explorer",
      br(),
      sidebarLayout(
        sidebarPanel(width = 3,
          div(class = "section-header", "Plot Controls"),

          selectInput("explorer_x", "X-axis Variable:",
            choices = c(
              "Fat-Energy Proportion"      = "Fat_Proportion",
              "Total Fat Intake (g)"       = "DR1TTFAT",
              "Protein Intake (g)"         = "DR1TPROT",
              "Carbohydrate Intake (g)"    = "DR1TCARB",
              "Total Energy Intake (kcal)" = "DR1TKCAL",
              "Age (years)"               = "RIDAGEYR"
            )
          ),

          selectInput("explorer_plot", "Plot Type:",
            choices = c(
              "Scatter + Regression"  = "scatter",
              "Violin / Box by Gender" = "violin",
              "Violin / Box by Age"    = "violin_age"
            )
          ),

          checkboxGroupInput("gender_filter", "Filter by Gender:",
            choices = c("Female", "Male"),
            selected = c("Female", "Male")
          ),

          sliderInput("age_range", "Age Range:",
            min = 18, max = 80, value = c(18, 80), step = 1
          ),

          hr(),
          checkboxInput("show_smooth", "Show regression line", value = TRUE),
          checkboxInput("split_gender", "Color by gender (scatter)", value = TRUE),

          br(),
          actionButton("update_plot", "Update Plot",
            icon = icon("sync"),
            class = "btn btn-primary btn-block",
            style = "width:100%; background:#3498db; border:none; border-radius:6px;")
        ),

        mainPanel(width = 9,
          div(class = "plot-card",
            plotOutput("explorer_plot", height = 480)
          ),
          br(),
          fluidRow(
            column(6,
              div(class = "section-header", "Summary Statistics"),
              tableOutput("summary_table")
            ),
            column(6,
              div(class = "section-header", "Depression by Category"),
              div(class = "plot-card",
                plotOutput("bar_dep_cat", height = 220)
              )
            )
          )
        )
      )
    ), # end Tab 2

    # ======================================================
    # TAB 3 – STATISTICAL ANALYSIS
    # ======================================================
    tabPanel("📈 Statistical Analysis",
      br(),
      sidebarLayout(
        sidebarPanel(width = 3,
          div(class = "section-header", "Model Settings"),

          selectInput("predictor", "Predictor Variable:",
            choices = c(
              "Fat-Energy Proportion"      = "Fat_Proportion",
              "Total Fat Intake (g)"       = "DR1TTFAT",
              "Protein Intake (g)"         = "DR1TPROT",
              "Carbohydrate Intake (g)"    = "DR1TCARB",
              "Total Energy Intake (kcal)" = "DR1TKCAL"
            )
          ),

          selectInput("model_gender", "Subset:",
            choices = c("All Participants" = "all",
                        "Female only"       = "Female",
                        "Male only"         = "Male")
          ),

          checkboxInput("adjust_age", "Adjust for age", value = FALSE),

          hr(),
          actionButton("run_model", "Run Regression",
            icon  = icon("calculator"),
            class = "btn btn-success btn-block",
            style = "width:100%; background:#2a9d8f; border:none; border-radius:6px;"
          )
        ),

        mainPanel(width = 9,
          fluidRow(
            column(7,
              div(class = "section-header", "Scatter Plot & Fitted Line"),
              div(class = "plot-card",
                plotOutput("reg_scatter", height = 380)
              )
            ),
            column(5,
              div(class = "section-header", "Model Coefficients"),
              div(class = "plot-card",
                plotOutput("coef_plot", height = 380)
              )
            )
          ),
          br(),
          div(class = "section-header", "Regression Summary"),
          div(class = "plot-card",
            verbatimTextOutput("model_summary")
          ),
          br(),
          div(class = "section-header", "Model Diagnostics"),
          div(class = "plot-card",
            plotOutput("diagnostics", height = 360)
          )
        )
      )
    ), # end Tab 3

    # ======================================================
    # TAB 4 – POWER SIMULATION
    # ======================================================
    tabPanel("⚡ Power Simulation",
      br(),
      sidebarLayout(
        sidebarPanel(width = 3,
          div(class = "section-header", "Simulation Parameters"),

          tags$p(style = "font-size:12px; color:#666;",
            "Simulate statistical power for detecting a linear association
             between fat proportion and depression score."),

          sliderInput("effect_size", "True Effect Size (β per unit fat):",
            min = 0, max = 20, value = 5, step = 1
          ),

          sliderInput("noise_sd", "Residual Noise (SD of depression scores):",
            min = 1, max = 8, value = 4, step = 0.5
          ),

          checkboxGroupInput("sim_n", "Sample Sizes to Simulate:",
            choices  = c("50" = 50, "100" = 100, "200" = 200,
                         "300" = 300, "500" = 500, "700" = 700,
                         "1000" = 1000),
            selected = c(50, 100, 200, 300, 500, 700, 1000)
          ),

          hr(),
          actionButton("run_sim", "Run Simulation (500 reps)",
            icon  = icon("play"),
            class = "btn btn-warning btn-block",
            style = "width:100%; background:#f4a261; border:none;
                     border-radius:6px; color:white;"
          ),
          br(),
          tags$small(style = "color:#999;",
            "Note: 500 repetitions may take ~10 seconds.")
        ),

        mainPanel(width = 9,
          fluidRow(
            column(8,
              div(class = "section-header", "Power Curve"),
              div(class = "plot-card",
                plotOutput("power_curve", height = 400)
              )
            ),
            column(4,
              div(class = "section-header", "Power Table"),
              div(class = "plot-card",
                br(),
                DTOutput("power_table")
              )
            )
          ),
          br(),
          div(class = "section-header", "Interpretation"),
          wellPanel(
            tags$p(
              "Statistical ", tags$b("power"), " is the probability of correctly
               detecting a true effect (rejecting H₀ when it is false). ",
              "A power of ", tags$b("≥ 0.80"), " is conventionally considered acceptable."
            ),
            tags$p(
              "Adjust the ", tags$b("effect size"), " (how strongly fat proportion
               predicts depression score) and the ", tags$b("noise level"),
              " (individual variability) to see how sample size requirements change."
            )
          )
        )
      )
    ), # end Tab 4

    # ======================================================
    # TAB 5 – DATA TABLE
    # ======================================================
    tabPanel("🗂 Data Table",
      br(),
      fluidRow(
        column(3,
          selectInput("dt_gender", "Filter Gender:",
            choices = c("All", "Female", "Male")
          )
        ),
        column(3,
          selectInput("dt_dep_cat", "Filter Depression Category:",
            choices = c("All", levels(nhdf$Depression_Cat))
          )
        ),
        column(3,
          sliderInput("dt_age", "Age Range:",
            min = 18, max = 80, value = c(18, 80)
          )
        ),
        column(3, br(),
          downloadButton("download_data", "Download Filtered CSV",
            style = "background:#3498db; color:white; border:none;
                     border-radius:6px; margin-top:4px;"
          )
        )
      ),
      DTOutput("data_table")
    )

  ), # end tabsetPanel

  # ---- Footer ----
  div(class = "app-footer",
    "VTPEH 6270 · Check Point 07 · NHANES Diet & Depression App")

) # end fluidPage


# ============================================================
# SERVER
# ============================================================
server <- function(input, output, session) {

  # ---- Reactive: filtered data for explorer ----
  explorer_data <- eventReactive(input$update_plot, {
    nhdf %>%
      filter(Gender %in% input$gender_filter,
             RIDAGEYR >= input$age_range[1],
             RIDAGEYR <= input$age_range[2])
  }, ignoreNULL = FALSE)

  # ---- TAB 1: Overview plots ----
  output$hist_dep <- renderPlot({
    m  <- mean(nhdf$Depression_Score)
    md <- median(nhdf$Depression_Score)
    ggplot(nhdf, aes(x = Depression_Score)) +
      geom_histogram(binwidth = 1, boundary = -0.5,
                     fill = "#5B9BD5", color = "white", alpha = 0.85) +
      geom_vline(xintercept = m,  color = "red",      linetype = "dashed", linewidth = 1) +
      geom_vline(xintercept = md, color = "#2c3e50",  linetype = "solid",  linewidth = 1) +
      annotate("text", x = m  + 0.3, y = Inf, label = paste("Mean =",   round(m,  1)),
               vjust = 3,  hjust = 0, color = "red",     fontface = "bold", size = 3.5) +
      annotate("text", x = md + 0.3, y = Inf, label = paste("Median =", round(md, 1)),
               vjust = 5,  hjust = 0, color = "#2c3e50", fontface = "bold", size = 3.5) +
      scale_x_continuous(breaks = seq(0, 27, 3)) +
      labs(title = "Distribution of PHQ-9 Depression Scores",
           x = "Depression Score (0-27)", y = "Count") +
      theme_app
  })

  output$pie_dep <- renderPlot({
    counts <- nhdf %>%
      count(Depression_Cat) %>%
      mutate(pct = n / sum(n),
             label = paste0(Depression_Cat, "\n", round(pct * 100, 1), "%"))
    ggplot(counts, aes(x = "", y = pct, fill = Depression_Cat)) +
      geom_col(color = "white", linewidth = 0.5) +
      coord_polar("y") +
      geom_text(aes(label = label),
                position = position_stack(vjust = 0.5), size = 3.5) +
      scale_fill_manual(values = col_dep) +
      labs(title = "Depression Severity Categories (PHQ-9)", fill = NULL) +
      theme_void() +
      theme(plot.title   = element_text(face = "bold", size = 14, hjust = 0.5),
            legend.position = "none")
  })

  # ---- TAB 2: Explorer plot ----
  output$explorer_plot <- renderPlot({
    dat  <- explorer_data()
    xvar <- input$explorer_x
    xlabels <- c(
      Fat_Proportion = "Fat-Energy Proportion",
      DR1TTFAT       = "Total Fat Intake (g)",
      DR1TPROT       = "Protein Intake (g)",
      DR1TCARB       = "Carbohydrate Intake (g)",
      DR1TKCAL       = "Total Energy Intake (kcal)",
      RIDAGEYR        = "Age (years)"
    )
    xl <- xlabels[xvar]

    if (input$explorer_plot == "scatter") {
      p <- ggplot(dat, aes_string(x = xvar, y = "Depression_Score",
                                  color = if (input$split_gender) "Gender" else NULL)) +
        geom_point(alpha = 0.45, size = 1.6, shape = 16)
      if (input$show_smooth)
        p <- p + geom_smooth(method = "lm", se = TRUE,
                             color   = if (input$split_gender) NULL else "#2c3e50",
                             fill    = "grey80", linewidth = 1.1, alpha = 0.25)
      p <- p +
        scale_color_manual(values = col_gender) +
        labs(title    = paste(xl, "vs. Depression Score"),
             subtitle = paste("n =", nrow(dat)),
             x = xl, y = "Depression Score (PHQ-9)", color = "Gender") +
        theme_app

    } else if (input$explorer_plot == "violin") {
      p <- ggplot(dat, aes(x = Gender, y = Depression_Score, fill = Gender)) +
        geom_violin(alpha = 0.65, trim = FALSE, color = NA) +
        geom_boxplot(width = 0.12, outlier.shape = NA, fill = "white", color = "#333") +
        scale_fill_manual(values = col_gender) +
        labs(title    = "Depression Score Distribution by Gender",
             subtitle = paste("n =", nrow(dat)),
             x = NULL, y = "Depression Score (PHQ-9)") +
        theme_app + theme(legend.position = "none")

    } else {
      p <- ggplot(dat %>% filter(!is.na(Age_Group)),
                  aes(x = Age_Group, y = Depression_Score, fill = Age_Group)) +
        geom_violin(alpha = 0.65, trim = FALSE, color = NA) +
        geom_boxplot(width = 0.12, outlier.shape = NA, fill = "white", color = "#333") +
        scale_fill_brewer(palette = "Set2") +
        labs(title    = "Depression Score Distribution by Age Group",
             subtitle = paste("n =", nrow(dat %>% filter(!is.na(Age_Group)))),
             x = "Age Group", y = "Depression Score (PHQ-9)") +
        theme_app + theme(legend.position = "none")
    }
    p
  })

  output$summary_table <- renderTable({
    dat <- explorer_data()
    dat %>%
      group_by(Gender) %>%
      summarise(
        N              = n(),
        `Mean Dep.`    = round(mean(Depression_Score), 2),
        `SD Dep.`      = round(sd(Depression_Score),   2),
        `Mean Fat %`   = round(mean(Fat_Proportion * 100), 1),
        `Mean Kcal`    = round(mean(DR1TKCAL), 0),
        .groups = "drop"
      )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$bar_dep_cat <- renderPlot({
    dat <- explorer_data()
    dat %>%
      count(Gender, Depression_Cat) %>%
      group_by(Gender) %>%
      mutate(pct = n / sum(n)) %>%
      ggplot(aes(x = Gender, y = pct, fill = Depression_Cat)) +
      geom_col(position = "fill", color = "white", linewidth = 0.4) +
      scale_fill_manual(values = col_dep) +
      scale_y_continuous(labels = percent_format()) +
      labs(title = "Depression Categories by Gender",
           x = NULL, y = "Proportion", fill = NULL) +
      theme_app +
      theme(legend.position = "right", legend.text = element_text(size = 9))
  })

  # ---- TAB 3: Regression ----
  model_dat <- eventReactive(input$run_model, {
    d <- nhdf
    if (input$model_gender != "all") d <- d %>% filter(Gender == input$model_gender)
    d
  }, ignoreNULL = FALSE)

  fitted_model <- eventReactive(input$run_model, {
    d   <- model_dat()
    fml <- if (input$adjust_age) {
      as.formula(paste("Depression_Score ~", input$predictor, "+ RIDAGEYR"))
    } else {
      as.formula(paste("Depression_Score ~", input$predictor))
    }
    lm(fml, data = d)
  }, ignoreNULL = FALSE)

  output$reg_scatter <- renderPlot({
    d    <- model_dat()
    xvar <- input$predictor
    xlabels <- c(
      Fat_Proportion = "Fat-Energy Proportion",
      DR1TTFAT       = "Total Fat Intake (g)",
      DR1TPROT       = "Protein Intake (g)",
      DR1TCARB       = "Carbohydrate Intake (g)",
      DR1TKCAL       = "Total Energy Intake (kcal)"
    )
    xl <- xlabels[xvar]
    col_subset <- if (input$model_gender == "all") col_gender else
                  col_gender[input$model_gender]
    gcol <- if (input$model_gender == "all") "Gender" else NULL

    p <- ggplot(d, aes_string(x = xvar, y = "Depression_Score",
                              color = gcol)) +
      geom_point(alpha = 0.4, size = 1.5, shape = 16) +
      geom_smooth(method = "lm", se = TRUE,
                  color = "#e63946", fill = "pink", linewidth = 1.3) +
      scale_color_manual(values = col_gender) +
      labs(title    = paste("Linear Regression:", xl, "→ Depression"),
           subtitle = paste("Subset:", if (input$model_gender == "all")
                              "All participants" else input$model_gender,
                            "| n =", nrow(d)),
           x = xl, y = "Depression Score (PHQ-9)", color = "Gender") +
      theme_app
    p
  })

  output$coef_plot <- renderPlot({
    mod <- fitted_model()
    ci  <- as.data.frame(confint(mod))
    names(ci) <- c("lower", "upper")
    coef_df <- data.frame(
      term  = rownames(ci),
      est   = coef(mod),
      lower = ci$lower,
      upper = ci$upper
    ) %>% filter(term != "(Intercept)")

    ggplot(coef_df, aes(x = est, y = reorder(term, est))) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
      geom_errorbarh(aes(xmin = lower, xmax = upper),
                     height = 0.25, color = "#3498db", linewidth = 0.9) +
      geom_point(size = 3.5, color = "#e63946") +
      labs(title    = "Coefficient Plot (95% CI)",
           x = "Estimate",
           y = NULL) +
      theme_app
  })

  output$model_summary <- renderPrint({
    summary(fitted_model())
  })

  output$diagnostics <- renderPlot({
    mod <- fitted_model()
    par(mfrow = c(2, 2), mar = c(4, 4, 3, 1.5), bg = "white")
    plot(mod, which = 1:4, col = adjustcolor("#3498db", 0.5), pch = 16, cex = 0.7)
  })

  # ---- TAB 4: Power Simulation ----
  power_results <- eventReactive(input$run_sim, {
    ns <- as.numeric(input$sim_n)
    run_power_sim(
      sample_sizes = ns,
      effect_size  = input$effect_size / 100,
      noise_sd     = input$noise_sd,
      n_rep        = 500
    )
  })

  output$power_curve <- renderPlot({
    df <- power_results()
    ggplot(df, aes(x = n, y = power)) +
      geom_hline(yintercept = 0.80, linetype = "dashed",
                 color = "#e63946", linewidth = 1) +
      geom_line(color = "#3498db", linewidth = 1.5) +
      geom_point(aes(color = power >= 0.80), size = 4) +
      scale_color_manual(values = c("FALSE" = "#f4a261", "TRUE" = "#2a9d8f"),
                         labels = c("< 80%", "≥ 80%"),
                         name   = "Adequate power?") +
      annotate("text", x = min(df$n), y = 0.82,
               label = "80% power threshold", hjust = 0,
               color = "#e63946", fontface = "bold", size = 3.8) +
      scale_x_continuous(breaks = df$n) +
      scale_y_continuous(labels = percent_format(), limits = c(0, 1)) +
      labs(title    = "Statistical Power vs. Sample Size",
           subtitle = paste("Effect size =", input$effect_size / 100,
                            " | Noise SD =", input$noise_sd,
                            " | 500 repetitions"),
           x = "Sample Size (n)", y = "Power") +
      theme_app +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  output$power_table <- renderDT({
    df <- power_results() %>%
      mutate(Power       = round(power, 3),
             `≥ 80%?`   = ifelse(power >= 0.80, "✅ Yes", "❌ No")) %>%
      select(`Sample Size` = n, Power, `≥ 80%?`)
    datatable(df, options = list(pageLength = 10, dom = "t"),
              rownames = FALSE)
  })

  # ---- TAB 5: Data Table ----
  dt_filtered <- reactive({
    d <- nhdf
    if (input$dt_gender != "All") d <- d %>% filter(Gender == input$dt_gender)
    if (input$dt_dep_cat != "All") d <- d %>% filter(Depression_Cat == input$dt_dep_cat)
    d <- d %>% filter(RIDAGEYR >= input$dt_age[1], RIDAGEYR <= input$dt_age[2])
    d %>% select(SEQN, Gender, Age = RIDAGEYR, Age_Group,
                 Depression_Score, Depression_Cat,
                 Fat_Proportion = Fat_Proportion,
                 `Fat (g)` = DR1TTFAT,
                 `Protein (g)` = DR1TPROT,
                 `Carbs (g)` = DR1TCARB,
                 `Energy (kcal)` = DR1TKCAL) %>%
      mutate(Fat_Proportion = round(Fat_Proportion, 3))
  })

  output$data_table <- renderDT({
    datatable(dt_filtered(),
              options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE,
              filter = "top")
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("nhanes_filtered_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(dt_filtered(), file, row.names = FALSE)
  )

} # end server

# ============================================================
# RUN
# ============================================================
shinyApp(ui = ui, server = server)
