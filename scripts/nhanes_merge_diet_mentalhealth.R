# NHANES L cycle merge pipeline
# Files used: BIOPRO_L, DBQ_L, DEMO_L, DPQ_L, DR1TOT_L, FNQ_L, HSQ_L, SLQ_L
# Output: nhanes_L_merged_diet.csv (only participants with Day 1 dietary data)

library(tidyverse)
library(haven)

# 1) Set the folder that contains your .xpt files
path <- "/Users/shiyi11/Desktop/R/6270/Diet and Mental Health"   # <-- change to your real folder path

# 2) File list (exactly what you showed)
files <- c(
  "BIOPRO_L.xpt",
  "DBQ_L.xpt",
  "DEMO_L.xpt",
  "DPQ_L.xpt",
  "DR1TOT_L.xpt",
  "FNQ_L.xpt",
  "HSQ_L.xpt",
  "SLQ_L.xpt"
)

full_paths <- file.path(path, files)

# 3) Read all XPTs into a named list
nhanes_list <- full_paths %>%
  set_names(~ tools::file_path_sans_ext(basename(.))) %>%
  map(read_xpt)

# 4) Define DEMO as the reference (main) table
stopifnot("DEMO_L" %in% names(nhanes_list))
demo <- nhanes_list$DEMO_L

# 5) Check each table is one row per person (SEQN)
check <- imap_dfr(nhanes_list, ~ tibble(
  table  = .y,
  rows   = nrow(.x),
  people = n_distinct(.x$SEQN),
  ratio  = nrow(.x) / n_distinct(.x$SEQN)
)) %>% arrange(desc(ratio))

print(check)

# If any ratio > 1, that table is one-to-many and must be summarized before joining.
# For your current case you said all ratios are 1.

# 6) Function to remove duplicate variables (keep SEQN for joining)
remove_duplicate_vars <- function(df, reference_df) {
  dup <- intersect(names(df), names(reference_df))
  dup <- setdiff(dup, "SEQN")
  df %>% select(-all_of(dup))
}

# 7) Remove duplicate vars from all non-DEMO tables
nhanes_clean <- nhanes_list %>%
  imap(~ if (.y == "DEMO_L") .x else remove_duplicate_vars(.x, demo))

# 8) IMPORTANT: force DEMO_L to be first so reduce() starts from the full sample
nhanes_clean2 <- nhanes_clean[c("DEMO_L", setdiff(names(nhanes_clean), "DEMO_L"))]

# 9) Merge all tables by SEQN (left joins, keep all DEMO participants)
nhanes_full <- reduce(nhanes_clean2, left_join, by = "SEQN")

# 10) Post-merge checks: still one row per person, same n as DEMO
stopifnot(nrow(nhanes_full) == nrow(demo))
stopifnot(n_distinct(nhanes_full$SEQN) == nrow(nhanes_full))

# 11) Restrict to participants with Day 1 dietary data (DR1TOT)
# Most common indicator is total kcal on Day 1: DR1TKCAL
stopifnot("DR1TKCAL" %in% names(nhanes_full))

nhanes_diet <- nhanes_full %>%
  filter(!is.na(DR1TKCAL))

# 12) Final check: still one row per person
stopifnot(n_distinct(nhanes_diet$SEQN) == nrow(nhanes_diet))

# 13) Optional: make variable names lower-case for tidy style
# nhanes_diet <- nhanes_diet %>% rename_with(tolower)

# 14) Export CSV
write_csv(nhanes_diet, "nhanes_L_merged_diet.csv")

# 15) Show where the file was saved
getwd()
