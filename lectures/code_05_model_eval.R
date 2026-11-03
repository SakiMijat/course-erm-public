library(ggplot2)
library(dplyr)

# A function that plots our penguins models by species and sex.
plot_flipper_model <- function(model, data = penguins, n = 200) {
  # Prediction grid
  pred_grid <- expand.grid(
    flipper_length_mm = seq(
      min(data$flipper_length_mm, na.rm = TRUE),
      max(data$flipper_length_mm, na.rm = TRUE),
      length.out = n
    ),
    sex = levels(data$sex),
    species = levels(data$species)
  )
  
  # Ensure factors have the same levels as in the model data
  pred_grid$sex <- factor(
    pred_grid$sex,
    levels = levels(data$sex)
  )
  
  pred_grid$species <- factor(
    pred_grid$species,
    levels = levels(data$species)
  )
  
  # Predictions and confidence intervals
  pred <- predict(
    model,
    newdata = pred_grid,
    interval = "confidence"
  )
  
  pred_grid <- cbind(
    pred_grid,
    as.data.frame(pred)
  )
  
  # Plot
  p <- ggplot(
    data,
    aes(
      x = flipper_length_mm,
      y = body_mass_g,
      color = sex
    )
  ) +
    geom_point(alpha = 0.4) +
    geom_ribbon(
      data = pred_grid,
      aes(
        x = flipper_length_mm,
        ymin = lwr,
        ymax = upr,
        fill = sex,
        group = interaction(sex, species)
      ),
      alpha = 0.15,
      inherit.aes = FALSE
    ) +
    geom_line(
      data = pred_grid,
      aes(
        x = flipper_length_mm,
        y = fit,
        color = sex,
        group = interaction(sex, species)
      ),
      linewidth = 1,
      inherit.aes = FALSE
    ) +
    facet_wrap(~species) +
    labs(
      title = "Predicted body mass by flipper length",
      subtitle = "Separate predictions by sex and species",
      x = "Flipper length (mm)",
      y = "Body mass (g)",
      color = "Sex",
      fill = "Sex"
    ) +
    theme_minimal()
  
  return(p)
}

# A function that estimates the ELPD/R2 of a model using LOOCV. It also outputs
# in-sample estimates, including AIC and -1/2 * AIC
loo_lm <- function(model) {
  
  # Extract original response and design matrix
  mf <- model.frame(model)
  y <- model.response(mf)
  X <- model.matrix(model)
  
  n <- length(y)
  
  # In-sample metrics
  elpd_in <- as.numeric(logLik(model))
  r2_in <- summary(model)$r.squared
  
  # Storage
  log_pred <- numeric(n)
  err2 <- numeric(n)
  err20 <- numeric(n)
  
  # Leave-one-out cross-validation
  for (i in seq_len(n)) {
    
    train_X <- X[-i, , drop = FALSE]
    test_X  <- X[i, , drop = FALSE]
    train_y <- y[-i]
    # Fit using the original design matrix
    fit <- lm.fit(x = train_X, y = train_y)
    # Predictions
    pred <- as.numeric(test_X %*% fit$coefficients)
    
    # Training-fold residual standard deviation
    sigma_hat <- sqrt(
      sum(fit$residuals^2) / fit$df.residual
    )
    
    # Predictive log score
    log_pred[i] <- dnorm(
      y[i],
      mean = pred,
      sd = sigma_hat,
      log = TRUE
    )
    
    # Null model prediction
    pred0 <- mean(train_y)
    
    # Squared errors
    err2[i] <- (y[i] - pred)^2
    err20[i] <- (y[i] - pred0)^2
  }
  
  # LOO ELPD
  elpd_loo <- sum(log_pred)
  se_elpd_loo <- sqrt(n * var(log_pred))
  
  # LOO predictive R2
  r2_loo <- 1 - sum(err2) / sum(err20)
  
  # Delta-method SE for R2
  q <- mean(err2) / mean(err20)
  influence <- (err2 - q * err20) / mean(err20)
  se_r2_loo <- sd(influence) / sqrt(n)
  
  list(
    n = n,
    ELPD_in = elpd_in,
    R2_in = r2_in,
    ELPD_LOO = elpd_loo,
    SE_ELPD_LOO = se_elpd_loo,
    R2_LOO = r2_loo,
    SE_R2_LOO = se_r2_loo,
    AIC = AIC(model),
    minus_half_AIC = - 0.5 * AIC(model),
    pointwise_ELPD = log_pred
  )
}

# A direct comparison of 2 models.
compare_loo <- function(models) {
  model_names <- names(models)
  
  # Apply loo_lm() to each model
  loo_results <- lapply(models, loo_lm)
  
  # Extract requested quantities
  results <- data.frame(
    Model = model_names,
    ELPD_in = sapply(loo_results, `[[`, "ELPD_in"),
    R2_in = sapply(loo_results, `[[`, "R2_in"),
    ELPD_LOO = sapply(loo_results, `[[`, "ELPD_LOO"),
    SE_ELPD_LOO = sapply(loo_results, `[[`, "SE_ELPD_LOO"),
    R2_LOO = sapply(loo_results, `[[`, "R2_LOO"),
    SE_R2_LOO = sapply(loo_results, `[[`, "SE_R2_LOO"),
    AIC = sapply(loo_results, `[[`, "AIC"),
    minus_half_AIC = sapply(loo_results, `[[`, "minus_half_AIC"),
    row.names = NULL
  )
  results
}

# 0) LOAD AND CLEAN DATA SET ---------------------------------------------------
penguins_raw <- read.csv("https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv")

penguins <- penguins_raw |>
  filter(!is.na(body_mass_g), !is.na(flipper_length_mm), !is.na(sex), !is.na(species)) |>
  mutate(
    species = as.factor(species),
    sex     = as.factor(sex)
  )

# 1) FL-ONLY MODEL AND DIAGNOSTICS ---------------------------------------------

m1 <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
print(summary(m1))
plot(penguins$flipper_length_mm, penguins$body_mass_g)
abline(m1, col = "blue")

plot(m1, which = 1)
plot(m1, which = 2)
plot(m1, which = 5)
acf(residuals(m1), main = "Autocorrelation of Penguin Residuals")

# 2) ADD BINARY INPUT VARIABLE -------------------------------------------------
m2 <- lm(body_mass_g ~ flipper_length_mm + sex, data = penguins)
print(summary(m2))

# 3) ADD ANOTHER CATEGORICAL INPUT VARIABLE ------------------------------------
# Adding sex and species removes most of the autocorrelation in residuals we saw
# when data were in the original order.
m3 <- lm(body_mass_g ~ flipper_length_mm + sex + species, data = penguins)
print(summary(m3))

plot(m3, which = 1)
plot(m3, which = 2)
plot(m3, which = 5)
acf(residuals(m3), main = "Autocorrelation of Penguin Residuals")

# 4) COMPUTE IN-SAMPLE (TRAINING SET, OPTIMISTIC) LOG-LIKELIHOOD ---------------
m0 <- lm(body_mass_g ~ 1, data = penguins) # intercept-only model

ll0 <- as.numeric(logLik(m0))
ll1 <- as.numeric(logLik(m1))
ll2 <- as.numeric(logLik(m2))
ll3 <- as.numeric(logLik(m3))

c(ll0, ll1, ll2, ll3)

# Relationship between in-sample likelihood and R2 for linear model:
n <- nobs(m0)

R2 <- function(ll, ll0, n) {
  1 - exp(-2 * (ll - ll0) / n)
}

c(
  m1 = R2(ll1, ll0, n),
  m2 = R2(ll2, ll0, n),
  m3 = R2(ll3, ll0, n)
)

# 5) USE LOOCV TO ESTIMATE ELPD ------------------------------------------------
# - Observe how in sample ELPD and R2 are typically better than the CV estimates.
# - Observe how AIC approximation to LOOCV is very good for these models.
compare_loo(list(baseline = m0, fl = m1, fl_sex = m2, fl_sex_species = m3))

# 7) POLYNOMIAL REGRESSION -----------------------------------------------------
m4 <- lm(body_mass_g ~ poly(flipper_length_mm, 3, raw = T) + sex + species, data = penguins)
summary(m4)
compare_loo(list(baseline = m0, fl = m1, fl_sex = m2, fl_sex_species = m3, fl3_sex_species = m4))
plot(m4)
plot_flipper_model(m4)

# 7) POLYNOMIAL REGRESSION (HIGHER DEGREE) -------------------------------------
# - Observe how the model overfits (worse out-of-sample performace).
# - Observe how AIC is a slightly worse approximation for this model.
m5 <- lm(body_mass_g ~ poly(flipper_length_mm, 12) + sex + species, data = penguins)
summary(m5)
compare_loo(list(baseline = m0, fl = m1, fl_sex = m2, fl_sex_species = m3, fl3_sex_species = m4, fl15_sex_species = m5))
plot(m5)
plot_flipper_model(m5)

# 8) TARGETED COMPARISON -------------------------------------------------------
# - When we want to compare two models on the same data, it is easiest to estimate
#   the difference, because it is only a univariate distribution and we take potential
#   dependencies between the two models into account.
compare_elpd <- function(mA, mB) {
  xA   <- loo_lm(mA)$pointwise_ELPD
  xB   <- loo_lm(mB)$pointwise_ELPD
  diff <- xA - xB
  n    <- length(xA)
  list(mean_diff = mean(diff),
       se_mean = sd(diff) / sqrt(n),
       sum_diff = sum(diff),
       se_sum = sqrt(n * var(diff)))
}
compare_elpd(m0, m1) # just flipper length is better than no input at all, with high confidence
compare_elpd(m3, m4) # 3rd def. polynomial is not better than linear, at least not with high confidence

# NOTE: We can use an intercept-only model to estimate the difference.
xA   <- loo_lm(m3)$pointwise_ELPD
xB   <- loo_lm(m4)$pointwise_ELPD
summary(lm(xA - xB ~ 1))

# 9) INTERACTIONS 1 ------------------------------------------------------------
# Adding a separate effect for male for each species.
m7 <- lm(body_mass_g ~ flipper_length_mm + sex + species + sex * species, data = penguins)
summary(m7)
compare_loo(list(baseline = m0, fl = m1, fl_sex = m2, fl_sex_species = m3,
                 fl3_sex_species = m4,
                 fl15_sex_species = m5,
                 m3_with_interaction = m7))
plot_flipper_model(m7)
compare_elpd(m3, m7)

# NOTE: The interaction model is better, with 96% confidence.
1 - pnorm(-8.403425, 0, 4.773144)

# 10) INTERACTIONS 2 -----------------------------------------------------------
# Giving each species its own slope does not improve the model.
m8 <- lm(body_mass_g ~ sex + species + species * flipper_length_mm, data = penguins)
summary(m8)
compare_loo(list(baseline = m0, fl = m1, fl_sex = m2, fl_sex_species = m3,
                 fl3_sex_species = m4,
                 fl15_sex_species = m5,
                 m3_with_interaction = m7,
                 m3_with_species_slope = m8))
plot_flipper_model(m8)
compare_elpd(m3, m7)
