# 20269 Economics of European Integration - Final Report

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains the complete analysis for the Economics of European Integration (20269) final report at Bocconi University. The project examines production function estimation, the China import shock on European regions, and its political economy implications.

## Collaborators

- **Stefano Graziosi** ([stfgrz](https://github.com/stfgrz))
- **Enrico Ancona**
- **Simone Donoghue**

## Repository Structure

```
20269-eei-report/
├── code/               # All Stata analysis code
│   ├── main_analysis.do      # Primary submission file (Problems 1-7)
│   └── tutorial/             # Course reference materials
├── data/               # Input datasets (organized by type)
│   ├── firm_level/           # Firm balance sheet data
│   ├── regional/             # Regional employment, ESS survey
│   ├── trade/                # China import data
│   ├── political/            # Manifesto Project data
│   └── shapefiles/           # NUTS-2 geographic boundaries
├── output/             # Generated results
│   ├── figures/              # Maps, density plots, RD plots
│   ├── tables/               # LaTeX/HTML regression tables
│   └── intermediate/         # Temporary datasets
├── docs/               # Assignment and references
│   ├── Take_Home_EEI_2025.pdf
│   └── references/           # Academic papers
├── archive/            # Deprecated drafts (DO NOT USE)
└── README.md           # This file
```

## Data Flow

The chart below shows which input datasets feed each problem, what intermediate files are produced, and what final outputs (tables and figures) are generated.

```mermaid
flowchart TD
    %% ── Raw inputs ──────────────────────────────────────────────────────────
    subgraph RAW["Raw Input Data"]
        D1[("EEI_TH_2025.dta\nFirm-level balance sheets\n(France · Spain · Italy)")]
        D2[("Employment_Shares\n_Take_Home.dta\nNUTS-2 employment by sector")]
        D3[("Imports_China\n_Take_Home.dta\nEU imports from China")]
        D4[("Imports_US_China\n_Take_Home.dta\nUS imports from China (IV)")]
        D5[("EEI_TH_P6_2025.dta\nRegional TFP & wages")]
        D6[("ESS8e02_3.dta\nEuropean Social Survey Rd 8")]
        D7[("MPDataset_MPDS2024a\nManifesto Project 2024")]
        D8[("NUTS_RG_20M_2013\nNUTS-2 Shapefiles")]
    end

    %% ── Part 1 ───────────────────────────────────────────────────────────────
    subgraph PART1["Part 1 · Production Function Estimation"]
        P1["Q1 · Descriptive Statistics\nFR30 region — 2007 vs 2017\nsectors 13 & 29"]
        P2["Q2 · TFP Estimation\nOLS · WRDG · Levinsohn-Petrin"]
        P4["Q4 · TFP Distribution Analysis\nclean extremes · kdensity plots\nPareto fits · skewness"]
        IQ4[("intermediate/\ninput_Q4.dta")]
        ICS[("intermediate/\npart_I_cleaned_sample.dta")]
    end

    %% ── Part 2a: China Shock ─────────────────────────────────────────────────
    subgraph PART2A["Part 2a · China Shock Construction (Q5)"]
        WPR[("intermediate/\nweights_pre.dta\npre-sample emp. shares")]
        CS_EU[("intermediate/\nChinaShock_by_region_year.dta")]
        CS_US[("intermediate/\nChinaShock_by_region_year_us.dta")]
        MERGED[("intermediate/\nsum_china_shock_merged.dta\ncross-sectional shock + IV")]
        SHP[("intermediate/\nnuts2_db · nuts2_coords.dta\nconverted shapefiles")]
    end

    %% ── Part 2b: Regional Regressions ───────────────────────────────────────
    subgraph PART2B["Part 2b · Regional Outcome Regressions (Q6)"]
        IQ6[("intermediate/\nQ6.dta")]
    end

    %% ── Part 2c: Political Economy ───────────────────────────────────────────
    subgraph PART2C["Part 2c · Political Economy (Q7)"]
        ESS_IT[("intermediate/\nESS8_Italy_cleaned.dta")]
        IQ7AB[("intermediate/\nQ7ab.dta")]
        MP_CL[("intermediate/\nMP_cleaned.dta\nItaly 2013 parties")]
        IQ7EF[("intermediate/\nQ7ef.dta\nESS + party scores")]
    end

    %% ── Outputs ──────────────────────────────────────────────────────────────
    subgraph OUT["Outputs"]
        direction LR
        OT1["tables/\ntable1.tex · table2.tex\nDescriptive stats (Q1)"]
        OT2["figures/\nTFP density plots ×12\nQ4a–Q4c (WRDG & LP)"]
        OT3["tables/\nPareto_France.tex\nPareto_Spain.tex (Q4e)"]
        OT4["figures/\nmap_sum_china_shock.pdf\nmap_manuf_share.pdf (Q5)"]
        OT5["tables/\nTable1_DescStats.tex\nChina Shock summary (Q5)"]
        OT6["tables/\nEEI_Take_Home_VI_bb.tex\nEEI_Take_Home_VI_cc3.tex\nTFP & Wage regressions (Q6)"]
        OT7["tables/\nEEI_Take_Home_VIIc.tex\nEEI_Take_Home_VIIf.tex\nAttitude & Minority score (Q7)"]
    end

    %% ── Edges: Part 1 ────────────────────────────────────────────────────────
    D1 --> P1
    P1 --> OT1
    D1 --> P2
    P2 --> IQ4
    IQ4 --> P4
    P4 --> ICS
    ICS -.used within.-> P4
    P4 --> OT2
    P4 --> OT3

    %% ── Edges: Part 2a ───────────────────────────────────────────────────────
    D2 --> WPR
    WPR --> CS_EU
    D3 --> CS_EU
    WPR --> CS_US
    D4 --> CS_US
    CS_EU --> MERGED
    CS_US --> MERGED
    D8 --> SHP
    SHP --> OT4
    MERGED --> OT4
    D2 --> OT4
    MERGED --> OT5

    %% ── Edges: Part 2b ───────────────────────────────────────────────────────
    D5 --> IQ6
    MERGED --> IQ6
    IQ6 --> OT6

    %% ── Edges: Part 2c ───────────────────────────────────────────────────────
    D6 --> ESS_IT
    ESS_IT --> IQ7AB
    MERGED --> IQ7AB
    IQ7AB --> IQ7EF
    D7 --> MP_CL
    MP_CL --> IQ7EF
    IQ7EF --> OT7
```

## Project Contents

### Part 1: Production Function Estimation (Problems 1-4)

**Problem 1:** Descriptive statistics for French textile and automotive firms (FR30 region, 2007 vs 2017)

**Problem 2:** Total Factor Productivity (TFP) estimation using:
- OLS (Cobb-Douglas)
- Wooldridge (WRDG) method with `prodest`
- Levinsohn-Petrin (LP) method with `levpet`

**Problem 3:** Theoretical discussion on revenues vs value added in production functions

**Problem 4:** TFP distribution analysis across sectors (textiles, automotive) and countries (France, Spain)

### Part 2: China Shock and Political Economy (Problems 5-7)

**Problem 5:** China import shock construction:
- Regional import exposure by NUTS-2 (1988-2007)
- Instrumental variable using US-China trade
- Mapping regional variation

**Problem 6:** Impact on regional outcomes:
- TFP and wage regressions
- Instrumental variable strategy (Colantone & Stanig 2018)
- First stage and reduced form results

**Problem 7:** Political implications:
- European Social Survey (ESS) analysis for Italy
- Attitudes toward renewable energy subsidies
- Party voting behavior and minority rights positions

## How to Run

### Prerequisites

**Software:**
- Stata 17 or higher (some commands require version 17+)
- Git (for cloning the repository)

**Required Stata Packages:**
```stata
ssc install outreg2, replace
ssc install estout, replace
ssc install levpet, replace
ssc install prodest, replace
ssc install spmap, replace
ssc install shp2dta, replace
ssc install ivreg2, replace
```

### Execution

1. **Clone the repository:**
   ```bash
   git clone https://github.com/stfgrz/20269-eei-report.git
   cd 20269-eei-report
   ```

2. **Open Stata and run the main analysis file:**
   ```stata
   do code/main_analysis.do
   ```

3. **Output will be generated in:**
   - `output/figures/` - All graphs and maps
   - `output/tables/` - All regression tables
   - `output/intermediate/` - Intermediate datasets

### Configuration

The script automatically detects your username and sets paths. If you encounter path issues, edit lines 59-77 in `code/main_analysis.do` to add your username and preferred path.

## Data Sources

- **Firm-level data**: Course materials (EEI_TH_2025.dta)
- **Regional statistics**: Eurostat (employment shares, NUTS boundaries)
- **Trade data**: UN Comtrade (Chinese imports to EU and US)
- **Survey data**: European Social Survey Round 8 (2016)
- **Political data**: Manifesto Project (MARPOR 2024)

See `data/README.md` for detailed data documentation.

## Key Results

### Production Function Estimates
Comparison of TFP estimation methods shows:
- WRDG and LP methods produce more reasonable coefficients than OLS
- Significant sectoral differences between textiles and automotive
- Cross-country variation in productivity distributions

### China Shock Analysis
Regional exposure to Chinese import competition:
- Strong geographic heterogeneity (North-South divide)
- Negative impact on regional wages and TFP
- IV estimates larger than OLS (suggesting attenuation bias)

### Political Economy
- Regions with higher China shock exposure show more negative attitudes toward renewable energy subsidies
- Effect operates partly through voting for parties with less favorable positions on minority rights

## File Naming Convention

- **Code files:** lowercase with underscores (e.g., `main_analysis.do`)
- **Data files:** PascalCase with underscores (e.g., `Employment_Shares_Take_Home.dta`)
- **Output files:** descriptive names with type prefix (e.g., `Figure1_firm_size_density_2007.pdf`, `Table1_DescStats.tex`)

## Notes

- The `archive/` directory contains deprecated draft versions. **Do not use these files.**
- All paths in the code use global variables for portability
- Output files are overwritten when the script runs
- Some data files are loaded from GitHub URLs for reproducibility

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Course instructors and TAs for Economics of European Integration (20269)
- Colantone & Stanig (2018) for the empirical strategy
- Data providers: Eurostat, UN Comtrade, ESS, Manifesto Project

## Contact

For questions about this analysis, please contact the collaborators through GitHub:
- Stefano Graziosi: [@stfgrz](https://github.com/stfgrz)
