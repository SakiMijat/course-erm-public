# ==============================================================================
# Tidyverse, R coding style, and functional paradigm
# ==============================================================================
library(tidyverse)

# Load the Dataset via Project-Relative Path -----------------------------------
data_path <- here::here("data", "basketball.csv")
shots <- read_delim(data_path, delim = ";", show_col_types = FALSE)

# Coding Style -----------------------------------------------------------------
# Principle: Empirical code is read, audited, and peer-reviewed more than written.
# Tidyverse Standard: Use snake_case, spaces around operators, and 2-space indentation.

# BAD / HARD-TO-READ STYLE (Nested, inside-out function calls):
result_nested <- round(log(123.456), digits = 2)

# GOOD STYLE (Linear, left-to-right reading using the native pipe |>):
result_piped <- 123.456 |>
  log() |>
  round(digits = 2)

# Auto-format your active file in RStudio using the styler package:
# styler::style_active_file()   (or keyboard shortcut: Ctrl + Shift + A)

# Linear Workflow Construction with the Native Pipe (|>) -----------------------
# Passes the output of the left side as the 1st argument of the right side:
# x |> f(y) is equivalent to f(x, y)

clean_shots <- shots |>
  # Standardize all column names to snake_case
  rename(
    shot_type   = ShotType,
    competition = Competition,
    player_type = PlayerType,
    transition  = Transition,
    two_legged  = TwoLegged,
    movement    = Movement,
    angle       = Angle,
    distance    = Distance
  ) |>
  # Chain row filtering
  filter(shot_type %in% c("above head", "layup")) |>
  # Chain feature creation (Vectorized math)
  mutate(angle_radians = angle * (pi / 180))

print(clean_shots)

# Vectorized Column Operations vs. Procedural For-Loops ------------------------
# In R, for-loops are slower and verbose.

# The Procedural Loop (Inefficient / Anti-Pattern in R)
distance_zone_loop <- character(nrow(clean_shots))

for (i in seq_along(clean_shots$distance)) {
  if (clean_shots$distance[i] < 1.0) {
    distance_zone_loop[i] <- "Paint (<1m)"
  } else if (clean_shots$distance[i] <= 4.0) {
    distance_zone_loop[i] <- "Mid-Range (1-4m)"
  } else {
    distance_zone_loop[i] <- "Perimeter (>4m)"
  }
}

# Vectorized Operation with case_when() (Idiomatic & Fast) ---
clean_shots <- clean_shots |>
  mutate(
    distance_zone = case_when(
      distance < 1.0  ~ "Paint (<1m)",
      distance <= 4.0 ~ "Mid-Range (1-4m)",
      TRUE            ~ "Perimeter (>4m)"
    )
  )

# Verify both approaches give the exact same output:
identical(distance_zone_loop, clean_shots$distance_zone) # TRUE