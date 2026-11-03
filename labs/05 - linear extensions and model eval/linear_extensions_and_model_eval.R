library(ggplot2)
library(dplyr)
library(tidyr)

# FUNCTION 1: LOOCV via Physical Loop
loocv_loop <- function(model) {
  
  # extract details from model
  data <- model.frame(model)
  y    <- model.response(data)
  form <- formula(model)
  n    <- length(y)
  
  # storage
  pointwise_log_scores <- numeric(n)
  
  # physical Leave-One-Out loop over all n observations
  for (i in 1:n) {
    fit_i   <- lm(form, data = data[-i, , drop = FALSE])
    pred_i  <- predict(fit_i, newdata = data[i, , drop = FALSE])
    sigma_i <- summary(fit_i)$sigma
    
    # Pointwise Gaussian log-predictive density (log score)
    pointwise_log_scores[i] <- dnorm(y[i], mean = pred_i, sd = sigma_i, log = TRUE)
  }
  
  # Total ELPD (sum of log scores) and its Standard Error (SE) across observations
  elpd    <- sum(pointwise_log_scores)
  se_elpd <- sqrt(n) * sd(pointwise_log_scores) # 
  
  # NOTE: SE for mean is approximately SD(X) / sqrt(n). But SE for sum is this below.
  # It follows from: SE(SUM) = SE(n * X) = n * SE(X_average) = n * (SD(X) / sqrt(n)) = sqrt(n) * SD(X)
  se_elpd <- sqrt(n) * sd(pointwise_log_scores)
  
  list(
    elpd                 = elpd,
    se_elpd              = se_elpd,
    pointwise_log_scores = pointwise_log_scores
  )
}

# FUNCTION 2: LOOCV via Leverage Shortcut (Closed-Form Approximation)
# Interesting note: LOOCV can be computed for a linear model without retraining!
loocv_shortcut <- function(model) {
  
  # extract details from model
  data <- model.frame(model)
  y    <- model.response(data)
  n    <- length(y)
  k    <- length(coef(model)) # Number of beta coefficients
  
  e <- residuals(model)
  h <- hatvalues(model)
  sse <- sum(e^2)
  
  # Closed-form out-of-sample predictions & residual variances
  loo_pred   <- y - (e / (1 - h))
  sigma2_loo <- (sse - (e^2 / (1 - h))) / (n - 1 - k)
  
  # Pointwise log scores without loops
  pointwise_log_scores <- dnorm(y, mean = loo_pred, sd = sqrt(sigma2_loo), log = TRUE)
  
  # Total ELPD and Standard Error
  elpd    <- sum(pointwise_log_scores)
  se_elpd <- sqrt(n) * sd(pointwise_log_scores)
  
  list(
    elpd                 = elpd,
    se_elpd              = se_elpd,
    pointwise_log_scores = pointwise_log_scores
  )
}

# FUNCTION 3: AIC Approximation (Analytical ELPD)

aic_eval <- function(model) {
  # Stone (1977): ELPD_AIC = -AIC / 2 = logLik - k_total
  list(
    elpd = -AIC(model) / 2
  )
}

# ==============================================================================
# DEMONSTRATION & EQUIVALENCE ON PALMER PENGUINS
# ==============================================================================
# Load data and filter missing cases for the model
penguins_clean <- penguins |>
  filter(!is.na(body_mass_g), !is.na(flipper_length_mm), 
         !is.na(species), !is.na(sex), !is.na(bill_length_mm))

# Fit standard linear regression model
fit_penguins <- lm(body_mass_g ~ flipper_length_mm, data = penguins_clean)

# Execute all three functions
res_loop     <- loocv_loop(fit_penguins)
res_shortcut <- loocv_shortcut(fit_penguins)
res_aic      <- aic_eval(fit_penguins)

summary_table <- data.frame(
  Method = c(
    "LOOCV (Physical Loop)",
    "LOOCV (Leverage Shortcut)",
    "AIC Approximation (-AIC / 2)"
  ),
  ELPD = c(
    round(res_loop$elpd, 2),
    round(res_shortcut$elpd, 2),
    round(res_aic$elpd, 2)
  ),
  SE_ELPD = c(
    round(res_loop$se_elpd, 2),
    round(res_shortcut$se_elpd, 2),
    "—"
  )
)

knitr::kable(
  summary_table,
  col.names = c("Evaluation Method", "Estimated ELPD", "SE(ELPD)"),
  align = "lcc",
  caption = "Comparison of Estimated ELPD across LOOCV implementations and AIC on Palmer Penguins."
)


# MODEL COMPARISON -------------------------------------------------------------

mod_simple  <- lm(body_mass_g ~ flipper_length_mm, data = penguins_clean)

mod_complex <- lm(body_mass_g ~ flipper_length_mm * species + sex + bill_length_mm + island + year + bill_depth_mm, 
                  data = penguins_clean)

# Targeted Pointwise Model Comparison
res_simple  <- loocv_shortcut(mod_simple)
res_complex <- loocv_shortcut(mod_complex)

# Pointwise paired difference: d_i = log_score(complex) - log_score(simple)
d_ptwise <- res_complex$pointwise_log_scores - res_simple$pointwise_log_scores
n        <- length(d_ptwise)

# Delta ELPD, Standard Error, and 95% Confidence Interval
delta_elpd    <- sum(d_ptwise)
se_delta_elpd <- sqrt(n) * sd(d_ptwise)
ci_lower      <- delta_elpd - 1.96 * se_delta_elpd
ci_upper      <- delta_elpd + 1.96 * se_delta_elpd

# AIC equivalent: Delta ELPD_AIC = -(AIC_complex - AIC_simple) / 2
delta_aic      <- AIC(mod_complex) - AIC(mod_simple)
delta_elpd_aic <- -delta_aic / 2

# ==============================================================================
# 4. Summary & Comparison Tables
# ==============================================================================
# Table 1: Individual Model Standings
tbl_models <- data.frame(
  Model = c("M1: Simple", "M2: Complex"),
  Parameters_k = c(length(coef(mod_simple)) + 1, length(coef(mod_complex)) + 1),
  In_Sample_R2 = c(summary(mod_simple)$r.squared, summary(mod_complex)$r.squared),
  LOOCV_ELPD   = c(res_simple$elpd, res_complex$elpd),
  SE_ELPD      = c(res_simple$se_elpd, res_complex$se_elpd),
  AIC_ELPD     = c(aic_eval(mod_simple)$elpd, aic_eval(mod_complex)$elpd)
)

cat("--- INDIVIDUAL MODEL PERFORMANCE ---\n")
print(knitr::kable(tbl_models, digits = 2, align = "lccccc"))

# Table 2: Direct Targeted Comparison (M2 vs. M1)
tbl_comparison <- data.frame(
  Comparison = "M2 (Complex) vs. M1 (Simple)",
  Delta_LOOCV_ELPD = round(delta_elpd, 2),
  SE_Delta = round(se_delta_elpd, 2),
  CI_95 = paste0("[+", round(ci_lower, 2), ", +", round(ci_upper, 2), "]"),
  Delta_AIC_ELPD = round(delta_elpd_aic, 2)
)

cat("\n--- TARGETED DIRECT MODEL COMPARISON ---\n")
print(knitr::kable(tbl_comparison, align = "lcccc"))


# Model diagnostics. Are all inputs relevant?
plot(mod_complex)
summary(mod_complex)
