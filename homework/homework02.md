# Homework 02

Take an open empirical dataset of your choice (smaller than 10MB) and build a self-contained, publication-grade composite figure with the following constraints:

* 3 subgraphs (2 in one row, the third in its own row; or, alternatively, two in one column, the third in its own column),
* at least one subgraph must use faceting (small-multiples),
* use at least three distinct geometric types,
* the titles, caption, axes, etc. must make the figure self-contained.

```text
hw-02-[student_id]/
├── hw-02.Rproj              # Mandatory project root anchor
├── data/
│   └── your-dataset.???     # Raw dataset
└── hw-02-report.qmd         # Main reproducible Quarto report
```

Allowed additional packages:

```text
tidyverse
here::here() for paths
patchwork
```
To receive a **PASS** in initial screening:

* The project opens cleanly via `hw-02.Rproj` with no absolute path calls.
* `.qmd` renders to completion in reasonable time and with zero errors.
* The generated output is a clean, 1-page PDF document containing the captioned figure.