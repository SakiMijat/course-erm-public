# ==============================================================================
# Core Data Wrangling with dplyr & tidyr
# ==============================================================================
library(tidyverse)

# Load Data & Initial Setup -------------------------------------------------
shots <- read_delim(here::here("data", "basketball.csv"), 
                    delim = ";", 
                    show_col_types = FALSE)

# Row Filtering with Compound Logical Operators (filter) -----------------------
# & (AND), | (OR), ! (NOT), %in% (Set membership)

filtered_shots <- shots |>
  filter(
    ShotType %in% c("above head", "layup"),
    Distance >= 0.5 & Distance <= 5.0,
    Angle > 30.0,
    !(Transition == 1 & TwoLegged == 1)
  )

# Column Selection, Renaming & Tidy-Selectors (select) -------------------------
# Tidy-selectors: starts_with(), ends_with(), where(), everything()

cleaned_columns <- filtered_shots |>
  select(
    shot_type   = ShotType,
    player_type = PlayerType,
    movement    = Movement,
    distance    = Distance,
    angle       = Angle,
    # Tidy-selector: keep remaining metadata flags
    starts_with("Two"),
    Transition
  ) |>
  # Standardize remaining column names to snake_case
  rename_with(tolower)

# Feature Engineering & Conditional Branching (mutate, case_when) --------------

engineered_shots <- cleaned_columns |>
  mutate(
    angle_rad = angle * (pi / 180),
    shot_zone = case_when(
      distance < 1.0                ~ "Under Basket (<1m)",
      distance >= 1.0 & distance <= 4.0 ~ "Short Range (1-4m)",
      distance > 4.0                ~ "Perimeter (>4m)",
      TRUE                          ~ "Unclassified"
    ),
    is_dynamic_movement = if_else(movement == "dribble or cut", 1, 0)
  )

# Grouped Statistical Aggregations & Cell Counts (group_by, summarize) ---------

shot_summary <- engineered_shots |>
  group_by(shot_type, shot_zone) |>
  summarize(
    total_shots = n(),
    mean_angle  = mean(angle, na.rm = TRUE),
    sd_angle    = sd(angle, na.rm = TRUE),
    se_angle    = sd_angle / sqrt(total_shots),
    mean_dist   = mean(distance, na.rm = TRUE),
    .groups     = "drop" # Always drop grouping metadata after summarize
  )

print(shot_summary)

# Data Reshaping with tidyr (Wide vs. Long) ------------------------------------
# Demonstrating on a simple repeated-measures experiment (Scores across 3 Trials)

# --- (A) Starting Point: Wide Dataset ---
wide_experiment <- tibble(
  player_id = 1:4,
  group     = c("Ctrl", "Ctrl", "Treat", "Treat"),
  trial_1   = c(10.2, 12.1, 14.5, 13.8),
  trial_2   = c(11.0, 12.8, 16.2, 15.1),
  trial_3   = c(11.5, 13.4, 18.0, 16.9)
)

print(wide_experiment)

# Collapses multiple trial columns into two columns: "trial" and "score"
long_data <- wide_experiment |>
  pivot_longer(
    cols      = starts_with("trial_"),
    names_to  = "trial",
    values_to = "score"
  )

print(long_data)

# Restores columns and calculates difference score directly across trials
wide_restored <- long_data |>
  pivot_wider(
    names_from  = trial,
    values_from = score
  ) |>
  mutate(gain_trial3_vs_trial1 = trial_3 - trial_1)

print(wide_restored)