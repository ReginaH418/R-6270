# VTPEH 6270
# NHANES L cycle merge pipeline
# Files used:
# BIOPRO_L, DBQ_L, DEMO_L, DPQ_L, DR1TOT_L, FNQ_L, HSQ_L, SLQ_L
#
# Outputs:
# data/nhanes_L_merged_diet.csv
# data/nhanes_L_diet_depression.csv

# Load packages
library(tidyverse)
library(haven)

# 1 Load raw NHANES .xpt files

# Folder containing raw NHANES files
path = "data/"

# File names
files = c(
  "BIOPRO_L.xpt",
  "DBQ_L.xpt",
  "DEMO_L.xpt",
  "DPQ_L.xpt",
  "DR1TOT_L.xpt",
  "FNQ_L.xpt",
  "HSQ_L.xpt",
  "SLQ_L.xpt"
)

# Create full file paths
full_paths = file.path(path, files)

# Read all .xpt files into a named list
nhanes_list = full_paths %>%
  set_names(~ tools::file_path_sans_ext(basename(.))) %>%
  map(read_xpt)

# 2 Define DEMO as the reference table

stopifnot("DEMO_L" %in% names(nhanes_list))
demo = nhanes_list$DEMO_L

# 3 Check whether each table has one row per person

check = imap_dfr(nhanes_list, ~ tibble(
  table = .y,
  rows = nrow(.x),
  people = n_distinct(.x$SEQN),
  ratio = nrow(.x) / n_distinct(.x$SEQN)
)) %>%
  arrange(desc(ratio))

print(check)

# 4 Remove duplicate variables from non DEMO tables

remove_duplicate_vars = function(df, reference_df) {
  dup = intersect(names(df), names(reference_df))
  dup = setdiff(dup, "SEQN")
  df %>% select(-all_of(dup))
}

nhanes_clean = nhanes_list %>%
  imap(~ (
    if (.y == "DEMO_L") {
      .x
    } else {
      remove_duplicate_vars(.x, demo)
    }
  ))

# 5 Force DEMO_L to be first before merging

nhanes_clean2 = nhanes_clean[c("DEMO_L", setdiff(names(nhanes_clean), "DEMO_L"))]

# 6 Merge all tables by SEQN

nhanes_full = reduce(nhanes_clean2, left_join, by = "SEQN")

# 7 Post merge checks

stopifnot(nrow(nhanes_full) == nrow(demo))
stopifnot(n_distinct(nhanes_full$SEQN) == nrow(nhanes_full))

# 8 Restrict to participants with Day 1 dietary data

stopifnot("DR1TKCAL" %in% names(nhanes_full))

nhanes_diet = nhanes_full %>%
  filter(!is.na(DR1TKCAL))

stopifnot(n_distinct(nhanes_diet$SEQN) == nrow(nhanes_diet))

# 9 Export merged diet dataset

write_csv(nhanes_diet, "data/nhanes_L_merged_diet.csv")

# 10 Read merged dataset

data_nh = read_csv("data/nhanes_L_merged_diet.csv")

# 11 Construct depression score

dpq_items = c(
  "DPQ010", "DPQ020", "DPQ030", "DPQ040", "DPQ050",
  "DPQ060", "DPQ070", "DPQ080", "DPQ090"
)

data_nh = data_nh %>%
  mutate(across(all_of(dpq_items), ~ ifelse(.x %in% 0:3, .x, NA))) %>%
  mutate(
    Depression_Score = rowSums(across(all_of(dpq_items)), na.rm = FALSE)
  )

# 12 Select variables for analysis

data_nhdm = data_nh %>%
  select(
    SEQN,
    RIAGENDR,
    RIDAGEYR,
    Depression_Score,
    DR1TKCAL,
    DR1TPROT,
    DR1TCARB,
    DR1TTFAT
  )

# 13 Keep complete cases

data_nhdm = data_nhdm %>%
  filter(
    !is.na(DR1TKCAL),
    !is.na(DR1TPROT),
    !is.na(DR1TCARB),
    !is.na(DR1TTFAT),
    !is.na(Depression_Score)
  )

# 14 Export final analysis dataset

write_csv(data_nhdm, "data/nhanes_L_diet_depression.csv")

# 15 Optional quick checks

glimpse(data_nhdm)
summary(data_nhdm)

# create gender variable
data_nhdm$Gender = NA
data_nhdm$Gender[data_nhdm$RIAGENDR == 1] = "Male"
data_nhdm$Gender[data_nhdm$RIAGENDR == 2] = "Female"

# Export the new csv file with gender
write_csv(data_nhdm, "data/nhanes_L_diet_depression_with_gender.csv")