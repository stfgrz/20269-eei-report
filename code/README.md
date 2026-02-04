# Code Directory

This directory contains all STATA `.do` files used for the analysis.

## Main Analysis File

### `main_analysis.do` ⭐

**This is the official submission file for the take-home exam.**

This file contains the complete analysis addressing all 7 problems specified in the assignment. It is well-documented with:
- Header comments explaining the project, authors, and requirements
- Section headers for each problem
- Inline comments explaining key steps
- All file paths using global macros for portability

**Structure:**
1. Setup and package installation instructions (lines 1-90)
2. Part I: Firm-Level Productivity Analysis (Problems 1-4)
3. Part II: China Shock Analysis (Problems 5-6)
4. Part III: Political Economy using ESS Data (Problem 7)

**To run:** 
```stata
do code/main_analysis.do
```

**Requirements:**
- STATA 14 or higher
- Required packages: outreg2, estout, levpet, prodest, grstyle, coefplot
- Working directory set to repository root
- Update the global paths in the Setup section to match your local directory

## Archive Directory

The `archive/` subdirectory contains previous versions of the analysis for reference:

- `version_draft.do` - Early draft version
- `version_enrico.do` - Version by Enrico Ancona

These files are kept for historical reference but are not part of the final submission.

## File Naming Convention

- Main analysis file: `main_analysis.do`
- Archive files: `version_*.do` format

## Notes

- All outputs (tables, figures) are saved to the `output/` directory
- Intermediate datasets are saved to `data/processed/`
- The code uses global macros for paths to ensure portability across different systems
