# ==============================================================================
# LESSON: Deconstructing the Grammar of Graphics in ggplot2
# Dataset: Basketball Shot Tracking (basketball.csv)
# Pipeline: Data -> Aesthetics -> Stats -> Scales -> Geoms -> Coords -> Facets
# ==============================================================================

library(tidyverse)

# ------------------------------------------------------------------------------
# STEP 0: DATA IMPORT & TYPE VERIFICATION
# ------------------------------------------------------------------------------
# Using read_delim specifies delim = ";" so decimal numbers are read as numeric
# doubles (<dbl>) rather than text (<chr>), preventing grid layout errors.

data_path <- here::here("data", "basketball.csv")
shots <- read_delim(data_path, delim = ";", show_col_types = FALSE)

# Inspect structure: ensure Distance and Angle are <dbl> and ShotType is <chr>
glimpse(shots)
head(shots)


# ------------------------------------------------------------------------------
# STEP 1: DATA
# ------------------------------------------------------------------------------
# Passing the data frame tells ggplot where to look, but outputs a blank grey box
# because no mappings, geometries, or stats have been declared yet.

ggplot(data = shots)

# ------------------------------------------------------------------------------
# STEP 2: AESTHETIC MAPPING
# ------------------------------------------------------------------------------
# aes() maps columns from the spreadsheet to visual channels on screen.
# - Continuous variables (Distance, Angle) map to spatial positions (x, y).
# - Categorical variable (ShotType) maps to visual channel (color).
# Note: Creates the grid and legend, but no physical data points are drawn yet!

ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType))


# ------------------------------------------------------------------------------
# STEP 3: STATISTICAL TRANSFORMATIONS
# ------------------------------------------------------------------------------

# Option 1: Untransformed Raw Data (stat = "identity")
# Plots raw, exact (x, y) coordinates directly with zero mathematical transformation.
ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  geom_point(alpha = 0.5)

# Option 2: Statistically Transformed Data (stat = "smooth")
# geom_smooth calls stat_smooth under the hood to fit linear regression models (lm)
# across each ShotType group on the fly.
ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = FALSE)

# ------------------------------------------------------------------------------
# STEP 4: SCALES
# ------------------------------------------------------------------------------
# Scales map raw numbers/categories to screen pixels and hex color codes.
# Naming rule: scale_[aesthetic]_[datatype]()

ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  # 1. Continuous Axis Scales: customize labels, tick breaks, and limits
  scale_x_continuous(name = "Shot Distance (Meters)", breaks = seq(0, 9, by = 1)) +
  scale_y_continuous(name = "Shot Angle (Degrees)", limits = c(0, 90)) +
  # 2. Discrete Color Scale: apply a high-contrast ColorBrewer palette
  scale_color_brewer(palette = "Set2", name = "Type of Shot")

# ------------------------------------------------------------------------------
# STEP 5: GEOMETRIC OBJECTS
# ------------------------------------------------------------------------------
# Geoms are the physical shapes drawn on canvas. Layers are stacked sequentially (+).

# Option A: Stacked Geoms (Scatterplot + Trendlines)
ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  geom_point(alpha = 0.4, size = 2) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(name = "Shot Distance (Meters)", breaks = seq(0, 9, by = 1)) +
  scale_y_continuous(name = "Shot Angle (Degrees)", limits = c(0, 90)) +
  scale_color_brewer(palette = "Set1", name = "Type of Shot")

# Option B: Swapping Geoms (Categorical Boxplot + Jittered Raw Points)
# Keeps data intact while changing geometric representation from points to boxes.
ggplot(data = shots,
       mapping = aes(x = ShotType, y = Distance, fill = ShotType)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.2) +
  scale_fill_brewer(palette = "Set1")


# ------------------------------------------------------------------------------
# STEP 6: COORDINATE SYSTEMS
# ------------------------------------------------------------------------------
# Stores the base plot setup into an object 'p' for modular coordinate testing
p <- ggplot(data = shots,
            mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(name = "Shot Distance (Meters)", breaks = seq(0, 9, by = 1)) +
  scale_y_continuous(name = "Shot Angle (Degrees)", limits = c(0, 90)) +
  scale_color_brewer(palette = "Set1", name = "Type of Shot")

# 1. Visual Zooming (coord_cartesian)
# Zooms camera viewport WITHOUT dropping data (preserves true stat_smooth fits!)
p + coord_cartesian(xlim = c(0, 3), ylim = c(20, 80))

# 2. Axis Rotation (coord_flip)
# Flips horizontal and vertical axes (ideal for long categorical text labels)
p + coord_flip()

# 3. Polar Projection (coord_polar)
# Projects Cartesian x/y space onto a circular polar grid
p + coord_polar()


# ------------------------------------------------------------------------------
# STEP 7: FACETS
# ------------------------------------------------------------------------------
# Complete 7-layer Grammar of Graphics pipeline!
# Partition plots into aligned sub-panels based on categorical levels (Competition).

ggplot(data = shots,
       mapping = aes(x = Distance, y = Angle, color = ShotType)) +
  # Layer 5: Geoms & Layer 3: Stats
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) +
  # Layer 4: Scales
  scale_x_continuous(name = "Shot Distance (Meters)", breaks = seq(0, 9, by = 1)) +
  scale_y_continuous(name = "Shot Angle (Degrees)", limits = c(0, 90)) +
  scale_color_brewer(palette = "Set1", name = "Type of Shot") +
  # Layer 6: Coordinates
  coord_cartesian(xlim = c(0, 8)) +
  # Layer 7: Faceting (~ Competition splits into sub-panels)
  facet_wrap( ~ Competition, ncol = 2) +
  # Non-Data Styling / Context
  theme_minimal()
