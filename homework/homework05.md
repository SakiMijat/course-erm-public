# Homework 05

As shown below, load the `mpg` dataset from `ggplot2` (included in `tidyverse`) and center the continuous displacement predictor:

```text
data(mpg, package = "ggplot2")

mpg_clean <- mpg |>
  filter(!is.na(hwy), !is.na(displ), !is.na(drv)) |>
  mutate(displ_c = displ - mean(displ))
```

Fit two competing linear regression models predicting highway fuel economy (`hwy`):
1. **Model A (Additive / Parallel Slopes):** Main effects of centered displacement and categorical drivetrain (`hwy ~ displ_c + drv`).
2. **Model B (Interaction / Varying Slopes):** Drivetrain-specific slopes via an interaction term (`hwy ~ displ_c * drv`).

Interpret the estimated coefficients of Model B: explain the physical meaning of the intercept, the drivetrain main effects, and the interaction slopes. Explain why centering engine displacement was necessary for the drivetrain main effects to have a sensible real-world interpretation.

Compare Model A and Model B across both in-sample and out-of-sample dimensions:

* Visualize the linear fits side-by-side.
* Report in-sample $R^2$ and Adjusted $R^2$.
* Compute $\text{AIC}$.
* Compute out-of-sample predictive performance using Leave-One-Out Cross-Validation. Perform a targeted model comparison by evaluating the mean pointwise out-of-sample squared error difference along with its standard error. Is one model better than the other with 95% confidence?

Does the added complexity of drivetrain-specific slopes earn its keep?

Required Project Structure:

```text
hw-05-[student_id]/
├── hw-05.Rproj              # Mandatory project root anchor
└── hw-05-report.qmd         # Main reproducible Quarto report
```

Allowed additional packages:

```text
tidyverse
here::here() for paths
patchwork
```

To receive a **PASS** in initial screening:

* The project opens cleanly via `hw-05.Rproj` with no absolute path calls.
* `.qmd` renders to completion in reasonable time and with zero errors.
* The generated output is a clean, 1-page PDF document containing whatever you feel is essential for communicating your work and results.