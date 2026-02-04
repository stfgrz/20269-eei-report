# Economics of European Integration - Take-Home Exam 2025

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Course Information

- **Course Code:** 20269
- **Course Title:** Economics of European Integration
- **Institution:** Bocconi University
- **Academic Year:** 2024-2025
- **Exam Type:** Take-Home Final Exam

## Authors

- **Stefano Graziosi** - [stfgrz](https://github.com/stfgrz)
- **Enrico Ancona**
- **Simone Donoghue**

*All authors contributed equally to this project.*

## Project Description

This repository contains the complete analysis for the Economics of European Integration take-home exam. The exam consists of 7 problems covering three main areas:

### Part I: Firm-Level Productivity Analysis (Problems 1-4)
- Descriptive statistics of French firms in textiles and automotive sectors
- Production function estimation using OLS, Wooldridge (WRDG), and Levinsohn & Petrin (LP) methods
- Productivity comparisons across industries and countries
- Total Factor Productivity (TFP) analysis and Pareto distributions

### Part II: Trade Shock Analysis - China Shock (Problems 5-6)
- Construction of regional China shock measures following Colantone and Stanig (2018)
- Spatial analysis and mapping of trade exposure across European NUTS-2 regions
- Comparison with US China shock identification strategy

### Part III: Political Economy Analysis (Problem 7)
- Analysis of the relationship between trade exposure and political attitudes
- Instrumental variable (IV) estimation using ESS8 individual-level data
- Study of attitudes towards green subsidies and minority rights
- Manifesto Project data integration for party-level analysis

## Repository Structure

```
.
├── README.md                   # This file
├── LICENSE                     # MIT License
├── .gitignore                  # Git ignore patterns
│
├── code/                       # STATA analysis scripts
│   ├── README.md              # Code documentation
│   ├── main_analysis.do       # MAIN SUBMISSION FILE ⭐
│   └── archive/               # Previous versions for reference
│       ├── README.md
│       ├── version_draft.do
│       └── version_enrico.do
│
├── data/                       # Data files
│   ├── README.md              # Data documentation
│   ├── raw/                   # Original datasets (not modified)
│   │   ├── shapefiles/        # NUTS-2 2013 shapefiles
│   │   ├── EEI_TH_2025.dta   # Firm-level balance sheet data
│   │   ├── EEI_TH_P6_2025.dta # Firm-level data for Problem 6
│   │   ├── ESS8*.dta          # European Social Survey Round 8
│   │   ├── *_Take_Home.dta    # Employment and trade data
│   │   └── *.pdf              # Data documentation and codebooks
│   └── processed/             # Generated intermediate datasets
│       └── README.md
│
├── output/                     # Analysis outputs
│   ├── README.md              # Output documentation
│   ├── tables/                # LaTeX and HTML tables
│   ├── figures/               # Graphs, plots, and maps
│   └── logs/                  # STATA log files
│
├── docs/                       # Documentation and references
│   ├── README.md
│   ├── Take_Home_EEI_2025.pdf # Assignment instructions
│   └── references/            # Academic papers
│       ├── L8_Slides_Productivity_markup.pdf
│       └── L18 Colantone Stanig 2018a.pdf
│
└── tutorial/                   # STATA tutorial files
    ├── README.md
    ├── Tutorial_EEI.do
    └── STATA_Tutorial_EEI.dta
```

## Prerequisites

### Software Requirements
- **STATA** (version 14 or higher recommended)
- **Operating System:** Windows, macOS, or Linux

### Required STATA Packages
The following packages must be installed before running the analysis:

```stata
ssc install outreg2, replace     // For regression output tables
ssc install estout, replace      // For formatted estimation tables
ssc install grstyle, replace     // For graph styling
ssc install coefplot, replace    // For coefficient plots
search levpet                    // For Levinsohn-Petrin estimation
search prodest                   // For production function estimation
```

*Installation commands are also included in the main analysis file.*

## Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/stfgrz/20269-eei-report.git
   cd 20269-eei-report
   ```

2. **Install required STATA packages:**
   - Open STATA
   - Run the installation commands listed in Prerequisites
   - Or uncomment the installation block in `code/main_analysis.do`

3. **Set your working directory:**
   - Open `code/main_analysis.do` in STATA
   - Update the file path in the Setup section (lines 60-80) to match your local directory
   - Example:
     ```stata
     global filepath "/your/path/to/20269-eei-report"
     ```

## How to Run the Analysis

### Quick Start

1. Open STATA
2. Set the working directory to the repository root
3. Run the main analysis file:
   ```stata
   do code/main_analysis.do
   ```

### Step-by-Step Execution

The analysis can also be run problem-by-problem by executing specific sections:

1. **Part I - Productivity Analysis:** Lines ~50-450
2. **Part II - China Shock Analysis:** Lines ~450-650  
3. **Part III - Political Economy:** Lines ~650-end

All outputs are automatically saved to the appropriate directories.

## Output Description

### Tables (`output/tables/`)
- Descriptive statistics tables (Problems 1-2)
- Production function estimation results (Problem 4)
- Pareto distribution parameters (Problem 4d)
- IV estimation results (Problems 7c, 7f)

### Figures (`output/figures/`)
- Firm size density plots
- TFP distributions (WRDG and LP methods)
- Comparison plots across sectors and countries
- NUTS-2 regional maps:
  - Average China shock by region
  - Pre-sample manufacturing employment share
- RD plots for regression discontinuity analysis

### Processed Data (`data/processed/`)
- Regional China shock measures
- Merged datasets for spatial analysis
- Cleaned individual-level survey data
- NUTS-2 shapefile databases

## Technical Notes

### Data Sources
- **Amadeus dataset:** Firm-level balance sheet data for France, Italy, and Spain
- **UN Comtrade:** Import data from China and US
- **European Social Survey (ESS8):** Individual-level survey data
- **Manifesto Project:** Party manifestos and political positions
- **Eurostat:** NUTS-2 shapefiles (2013 definition)

### Methodology Highlights
- **Production Function Estimation:** Wooldridge (2009) and Levinsohn & Petrin (2003) methods
- **Trade Shock Construction:** Following Autor et al. (2013) and Colantone & Stanig (2018)
- **Identification Strategy:** Instrumental variables using US import exposure from China

## Reproducibility

This analysis is fully reproducible. All data files are included in the repository (or loaded from the GitHub repository in the code), and the complete analysis pipeline is documented in `code/main_analysis.do`.

To replicate the results:
1. Follow the Installation & Setup instructions
2. Run the main analysis file
3. Compare outputs with those in the `output/` directory

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Course Instructor:** Economics of European Integration Teaching Team
- Special thanks to the authors of the methodological papers that guided this analysis

## References

- Autor, D. H., Dorn, D., & Hanson, G. H. (2013). *The China syndrome: Local labor market effects of import competition in the United States.* American Economic Review, 103(6), 2121-68.
- Colantone, I., & Stanig, P. (2018). *Global competition and Brexit.* American Political Science Review, 112(2), 201-218.
- Levinsohn, J., & Petrin, A. (2003). *Estimating production functions using inputs to control for unobservables.* The Review of Economic Studies, 70(2), 317-341.
- Wooldridge, J. M. (2009). *On estimating firm-level production functions using proxy variables to control for unobservables.* Economics Letters, 104(3), 112-114.

## Contact

For questions or comments about this analysis:
- Open an issue on GitHub
- Contact the authors via their GitHub profiles

---

*Last updated: January 2025*
