# ==============================================================================
# File I/O with readr, RDS, and Parquet
# ==============================================================================
library(tidyverse)
library(arrow) # for Parquet

# Delimited Text I/O (read_csv / read_delim vs. write_csv) ---------------------

shots <- read_delim(here::here("data", "basketball.csv"), 
                    delim = ";", 
                    show_col_types = FALSE)

shots$ShotType <- factor(shots$ShotType, levels = c("layup", "above head", "other"))

write_csv(shots, here::here("data", "basketball_exported.csv")) # factor levels are lost!

# Binary Serialization (write_rds vs. read_rds) --------------------------------
# Keeping the R objects (table metadata, factor levels, etc.) intact.

write_rds(shots, here::here("data", "basketball.rds"))
reloaded_rds <- read_rds(here::here("data", "basketball.rds"))
class(reloaded_rds$ShotType)     

# Columnar Big Data Format (write_parquet vs. read_parquet) --------------------
# Parquet is a compressed, type-safe columnar format widely used in Data Science.
parquet_out <- here::here("data", "shots.parquet")
write_parquet(shots, parquet_out)

# In-Memory loading: Converts columnar Parquet into a standard R tibble
reloaded_parquet <- read_parquet(parquet_out)
glimpse(reloaded_parquet)

# For datasets larger than RAM (e.g. 50 GB):
# 1. Open pointer without loading into RAM:
ds <- open_dataset(here::here("data", "shots.parquet"))

# 2. Lazy dplyr query processed in C++ on disk:
# 3. collect() pulls ONLY the final filtered result into R's memory:
result <- ds |>
  filter(Distance > 2.0) |>
  collect()