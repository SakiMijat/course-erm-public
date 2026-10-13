---
title: 'Lecture Takeaway: The PPDAC Investigative Cycle'
output:
  html_document:
    df_print: paged
---

> *"Statistical thinking focuses on the way people reason about raw data, how they operationalize constructs, and how they filter signal from noise. But above all, an empirical investigation is embedded in a context: it translates a real-world problem into a statistical model, and translates the statistical answers back into real-world meaning."*
>
> — **C. J. Wild & M. Pfannkuch**, *Statistical Thinking in Empirical Enquiry* (1999), *International Statistical Review*.

---

### Core Definition

**Empirical Inquiry** bridges messy, complex physical systems and formal mathematical models. It does not operate in a mathematical vacuum. Instead, every downstream claim is bound to the design, measurement, sampling, and data curation choices made upstream.

Our reference mental model for this pipeline is the **PPDAC cycle** (*Wild & Pfannkuch, 1999*; formalized further by *MacKay & Oldford, 2000*):

$$\text{Problem} \longrightarrow \text{Plan} \longrightarrow \text{Data} \longrightarrow \text{Analysis} \longrightarrow \text{Conclusion} \longrightarrow \text{(New) Problem}$$

---

### Stage 1: Problem (Formulating the Inquiry)

An empirical investigation begins in the context domain. Its goal is to take a practical problem or scientific curiosity and translate it into a formal, testable empirical question without distorting the underlying practical context.

**System Dynamics:** First, we must identify the physical, biological, or organizational mechanisms operating in the system, the concrete knowledge gap, stakeholder goals, and resource boundaries.

Next, we identify the **4 Coordinates:**

* **Units & Target Population (or Target Data Generating Process):**
   * **Target Unit:** The individual entity possessing characteristics of interest.
   * **Target Population:** The complete ensemble of units across space and time about which we wish to draw conclusions.
* **Variates:**
   * **Response Variate:** The primary unit characteristic(s) whose behavior, magnitude, or variability we want to explain.
   * **Explanatory Variates:** Characteristics that potentially explain, drive, or correlate with variation in the response.
* **Population Attributes:** Quantitative summaries across all units of the target population (e.g., population mean $\mu$, total species richness, regression coefficients $\beta$, structural model parameters).
* **Problem Aspect:**
   * **Descriptive:** Estimating, summarizing, or tracking population attributes (what is/was happening).
   * **Predictive:** Generating optimal forecasts for unobserved individual units based on their explanatory profiles (what will happen to unit $i$).
   * **Causative:** Quantifying how an attribute changes when an explanatory variate is *deliberately intervened upon* (what happens if we intervene).

**Primary Failure Modes:** Tier 1 (Theoretical Errors), for example, Babylonian astronomy and no-life-in-acid. Confusing a causative and predictive study. Selecting target populations that do not reflect the physical system.

---

### Stage 2: Plan (Designing the Empirical Protocol)

The Plan is the operational blueprint created before touching the system. We anticipate and defend against Tier 2 (Methodological), Tier 3 (Instrumental), and Tier 4 (Stochastic) issues.

**1. Sampling Frame:**

  * **Study Units:** The specific concrete entities that can practically be accessed and observed.
  * **Study Population (Sampling Frame):** The set of all accessible study units under logistical constraints.

The systematic error (bias) in the quantities of interest between the **Study Population** and the true **Target Population** results **study error**.
  
**Primary Failure Modes:** Tier 2 (Methodological) errors resulting in a large study error. TODO: Give example.

**2. Operationalization:** Translation of raw, qualitative physical realities into meaningful numerical metrics.

**Primary Failure Modes:** Tier 2 (Methodological) errors resulting in a large operationalization error: Treating the operational proxy as an inviolable, complete representation of the theoretical construct (Egas Moniz operationalizing "psychiatric cure" as docile, unagitated patient behavior following prefrontal lobotomy). Goodhart's Law (using number of papers published as a prox< for research quality). McNamara's Fallacy (body counts as a metric of military victory).

**3. Dealing with Explanatory Variates:** Real systems contain infinite variables. The researcher must make an explicit methodological commitment for every explanatory factor.

* **Hold Fixed (Restricted):** Held artificially constant. *Trade-off:* Minimizes stochastic noise, but severely shrinks the study population, inflating study error and masking interactions.
* **Manipulate:** Controlled by the investigator. *Trade-off:* The foundation of experimental and causal inquiry, but typically more difficult in terms of resources, feasibility, and ethical considerations.
* **Measure for Analysis:** Allowed to vary naturally, but recorded to adjust for them statistically. *Trade-off:* Observational adjustment cannot prevent unmeasured confounding or colinearity.
* **Ignore (Unmeasured):** Left unmeasured due to ignorance or perceived irrelevance. *Trade-off:* Variation goes into residual noise, omitted confounders may introduce bias.

**4. Measurement:** The physical tools, assays, and scoring protocols used to assign values to variates, potentially resulting in **measurement error**.

* **Measuring Bias:** Systematic calibration drift, sensor blindness, or tool-specific artifact.
* **Measuring Variability:** Random instrumental noise across repeated reads of the identical unit.

**Primary Failure Modes:**  Tier 3 (Instrumental) issues.

**5. Sampling Protocol:** Specifies the selection mechanism and sample size from the study population, potentially resulting in **sampling error**.
  * **Sampling Bias:** Systematic non-representativeness from non-random, selective sampling (survivorship bias, self-selection bias).
  * **Sampling Variability:** Random stochastic fluctuation resulting from a finite sample size ($n < \infty$).

**Primary Failure Modes:** Tier 2 sampling biases (survivorship bias, volunteer bias, etc.) and Tier 4 issues with high variability (sample size too small).

**6. Data Collection Protocol:** Standard Operating Procedures, data management schemes, and pilot testing.

**Primary Failure Modes:** Tier 2 logistical breakdowns from skipped pilot runs and absent data-entry validation rules

---

### Stage 3: Data (Executing the Protocol & Quality Assurance)

Stage Data is frequently ignored as a simple mechanical exercise, but it is where real-world friction disrupts the mathematical plan. It consists of four substages:

1. **Execution:** Executing the sampling and measurement routines while logging all departures from protocol
2. **Real-Time Monitoring:** Active screening during collection to detect sensor drift, assay degradation, operator fatigue, site destruction, or other issues.
3. **Data Examination:** Auditing the full dataset prior to formal modeling using Exploratory Data Analysis (EDA). Looking for digit preference, encoding blunders, impossible values, missingness patterns, etc.
4. **Data Storage:** Establishing tidy, validated schemas with machine-readable codebooks.

**Primary Failure Modes:** Unrecorded protocol departures, unrecorded metadata, skipped basic EDA.

---

### Stage 4: Analysis (Model Building, Assessment, and Inference)

Statistical modeling acts as an filter designed to isolate empirical signal from background noise, counteracting the human tendency to spot patterns in random noise. That is, a model aims at estimating the quantities of interest and quantifying Tier 4 stochastic variability in those estimates.

1. **Designing:** The model must reflect both the nature of the data and the physical sampling structure.
2. **Fitting:** Estimating unknown parameters from the collected data using chosen mathematical criteria and algorithms (maximum likelihood, least squares, Bayesian inference).
3. **Evaluating:** Measuring the quality of the model and auditing model assumptions.

**Primary Failure Modes:** Many different and subtle modeling choices can silently invalidate your conclusions (misspecified distributions, misspecified functional relationships, pseudoreplication). Because so much can go wrong here, several upcoming lectures are dedicated entirely to the Analysis stage.

---

### Stage 5: Conclusion (Synthesis, Limitations, and Reverse Translation)

The investigation ends with translating statistical output back into the real-world context domain:

1. **Reverse Translation:** Expressing findings in non-technical domain language that directly speaks to the practical question asked in Stage Problem.
2. **Comprehensive Error Auditing:** Explicitly synthesizing the accumulated errors across the entire pipeline.
3. **Inductive Boundary Demarcation:** Stating clearly where generalization stops across space, time, and environmental conditions.

**Primary Failure Modes:** Aspect drift (upgrading descriptive correlations into causal claims), hasty generalization, and mistaking measurement artifacts for true findings.

---

### The Weakest Link Principle

An empirical investigation is a **chain of commitments**. For example:

* A perfect statistical model cannot fix unrepresentative data.
* A massive sample size cannot fix a flawed operational variable.
* High-precision laboratory sensors cannot fix a severe study error.
* A rigorous experimental plan cannot compensate for unrecorded departures during execution.

**Empirical thinking is not merely the mathematical manipulation of numbers in Stage Analysis. It is the discipline of safeguarding the validity of the conclusions along every link of the chain.**

---

### Post-Lecture Reflections

* **Self-Test with your favorite AI tool:** Find an empirical paper, write down the key choices for each of the five stages (and their components), and identify top 3 sources of potential error (excluding stage Analysis). Once you've completed your assessment, ask your AI tool to do the same, independently of your assessment. Finally, analyze potential disagreements. You can control for difficulty by picking something relatively simple, for example, a simple comparison of several AI/ML models on a single benchmark. Once you are comfortable, challenge yourself with a more complex investigation that includes challenging measurement and sampling.
* **Readings:**
  * **Wild, C. J., & Pfannkuch, M. (1999).** *Statistical thinking in empirical enquiry.* International Statistical Review, 67(3), 223–248.
  * **MacKay, R. J., & Oldford, R. W. (2000).** *Scientific method, statistical method and the speed of light.* Statistical Science, 15(3), 254–278. *(Rigorous formalization of Study Error, Problem Aspects, and data-monitoring substages).*
