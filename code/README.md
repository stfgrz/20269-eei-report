# Code Directory

This directory contains all STATA code for the Economics of European Integration final report.

## Main Analysis File

**`main_analysis.do`** - The primary submission file containing all analysis for Problems 1-7.

### Structure:
- **Part 1 (Problems 1-4)**: Production function estimation
  - Problem 1: Descriptive statistics (FR30 region, 2007 vs 2017)
  - Problem 2: TFP estimation (OLS, Wooldridge, Levinsohn-Petrin)
  - Problem 3: Theoretical discussion (revenues vs value added)
  - Problem 4: TFP distribution analysis

- **Part 2 (Problems 5-7)**: China shock and political economy
  - Problem 5: China import shock construction and mapping
  - Problem 6: TFP/wage regressions with IV
  - Problem 7: ESS survey analysis and voting behavior

### How to Run:
1. Open Stata (version 17+ recommended)
2. Set working directory to repository root
3. Run: `do code/main_analysis.do`

## Tutorial Files

The `/tutorial/` subfolder contains reference code from course materials.

## Required Packages
- `outreg2`
- `estout`
- `levpet`
- `prodest`
- `spmap`
- `shp2dta`
- `ivreg2`
