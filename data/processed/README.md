# Processed Data Directory

This directory contains intermediate datasets generated during the analysis.

## Important Notes

⚠️ **This directory is for generated files only**

- Files here are created by running `code/main_analysis.do`
- These files are NOT tracked in version control (excluded via `.gitignore`)
- To regenerate: delete files and rerun the analysis

## Typical Contents

When you run the analysis, this directory will contain files such as:

### China Shock Analysis
- `ChinaShock_by_region_year.dta` - China shock by region and year
- `ChinaShock_by_region_year_us.dta` - US China shock (instrumental variable)
- `sum_china_shock_merged.dta` - Collapsed regional China shocks
- `collapsedimpshock.dta` - Collapsed import shock measures
- `weights_pre.dta` - Employment weights for shock calculation

### Spatial Data
- `nuts2_db.dta` - NUTS-2 shapefile database
- `nuts2_coords.dta` - NUTS-2 coordinates for mapping
- `manuf_share.dta` - Manufacturing employment shares by region

### Productivity Analysis
- `part_I_cleaned_sample.dta` - Cleaned firm-level data
- `input_Q4.dta` - Input data for Problem 4

### Political Economy
- `Q7ab.dta` - Merged data for Problem 7a-b
- `Q7cd.dta` - Data for Problem 7c-d
- `Q7ef.dta` - Data for Problem 7e-f
- `ESS8_Italy_cleaned.dta` - Cleaned Italian ESS data
- `MP_cleaned.dta` - Cleaned Manifesto Project data

## Regeneration

To regenerate all processed data files:

```bash
# Delete processed files
rm data/processed/*.dta

# Run analysis in STATA
do code/main_analysis.do
```

## File Naming Convention

- Dataset names are descriptive of their content
- Problem-specific files use `Q[number]` prefix
- Intermediate merge/collapse files include descriptive suffixes

## Note

If you encounter missing file errors when running the analysis:
1. Ensure all raw data files are in `data/raw/`
2. Check that working directory paths are set correctly in the code
3. Verify required STATA packages are installed
