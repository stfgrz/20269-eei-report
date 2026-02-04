# Data Directory

This directory contains all input datasets for the analysis.

## Subdirectories

### `/firm_level/`
| File | Description | Source | Key Variables |
|------|-------------|--------|---------------|
| `EEI_TH_2025.dta` | Firm-level balance sheet data | Course materials | `id_n`, `year`, `country`, `sector`, `real_sales`, `real_K`, `real_M`, `L`, `real_VA`, `W`, `nuts2` |

### `/regional/`
| File | Description | Source | Key Variables |
|------|-------------|--------|---------------|
| `Employment_Shares_Take_Home.dta` | Regional employment by industry | Eurostat | `country`, `nuts2`, `nace`, `year`, `empl`, `tot_empl_nuts2` |
| `EEI_TH_P6_2025.dta` | Regional TFP and wage data | Course materials | `nuts_code`, `year`, `tfp`, `mean_uwage`, `share_tert_educ` |
| `ESS8e02_3.dta` | European Social Survey Round 8 | ESS | `cntry`, `region`, `gndr`, `agea`, `edlvdit`, `prtvtbit`, `sbsrnen` |

### `/trade/`
| File | Description | Source | Key Variables |
|------|-------------|--------|---------------|
| `Imports_China_Take_Home.dta` | Chinese imports to EU | UN Comtrade | `year`, `country`, `nace`, `real_imports_china` |
| `Imports_US_China_Take_Home.dta` | Chinese imports to US (instrument) | UN Comtrade | `year`, `nace`, `real_USimports_china` |

### `/political/`
| File | Description | Source | Key Variables |
|------|-------------|--------|---------------|
| `MPDataset_MPDS2024a_stata14.dta` | Manifesto Project party positions | MARPOR | `party`, `partyname`, `countryname`, `per705` |

### `/shapefiles/`
NUTS-2 regional boundary shapefiles (2013 version, EPSG:3035 projection) from Eurostat GISCO.

## Data Sources
- **Eurostat**: Regional statistics and NUTS boundaries
- **UN Comtrade**: International trade data
- **European Social Survey**: Public opinion data
- **Manifesto Project**: Party policy positions
