# ==============================================================================
# RStudio Discipline
# ==============================================================================
library(tidyverse)

# 1. Data Generation -----------------------------------------------------------
set.seed(0)
n <- 30


# Define groups
group <- factor(
  sample(
    c(
      "Control", 
      "Treatment_A", 
      "Treatment_B"
    ),
    n, 
    replace = TRUE
  ),
  levels = c("Control", "Treatment_A", "Treatment_B")
)

# Generate synthetic data for each group. 
# Control: N(450, 40); Treatment A: N(380, 35); Treatment B: N(320, 30).
mu    <- numeric(n)
sigma <- numeric(n)
for (i in 1:n) {
  if (group[i] == "Control") {
    mu[i]    <- 450
    sigma[i] <- 40
  } else if (group[i] == "Treatment_A") {
    mu[i]    <- 380
    sigma[i] <- 35
  } else if (group[i] == "Treatment_B") {
    mu[i]    <- 320
    sigma[i] <- 30
  }
}

reaction_time <- numeric(n)
for (i in seq_len(n)) {
  reaction_time[i] <- round(rnorm(1, mean = mu[i], sd = sigma[i]), 1)
}

df <- tibble(
  subject_id    = 1:n,
  group         = group,
  reaction_time = reaction_time
)

### Alternative data definition (no for loops)

group <- factor(sample(c("Control", "Treatment_A", "Treatment_B"),
                       n, replace = TRUE),
                levels = c("Control", "Treatment_A", "Treatment_B"))

# Lookup tables: one value per group
mu_by_group    <- c(Control = 450, Treatment_A = 380, Treatment_B = 320)
sigma_by_group <- c(Control = 40,  Treatment_A = 35,  Treatment_B = 30)

df <- tibble(
  subject_id = seq_len(n),
  group      = group
) %>%
  mutate(
    mu            = mu_by_group[as.character(group)],
    sigma         = sigma_by_group[as.character(group)],
    reaction_time = round(rnorm(n, mean = mu, sd = sigma), 1)
  ) %>%
  select(subject_id, group, reaction_time)

# 2. Attribute inspection ------------------------------------------------------

view(df)
glimpse(df)
attributes(df$group) # displays factor levels metadata

# 3. Generate and save plot ----------------------------------------------------

p <- ggplot(df, aes(x = group, y = reaction_time, fill = group)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(width = 0.15, size = 2, alpha = 0.8) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Reaction Time by Experimental Arm",
    x = "Condition",
    y = "Latency (ms)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

plot(p) # inspect plot

ggsave(here::here("output", "reaction_plot.png"), # use relative paths, avoid setwd()!
       plot = p, width = 6, height = 3.5, dpi = 300) 

plot(p)

