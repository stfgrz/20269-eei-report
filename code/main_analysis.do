*============================================================================
*
*                   Economics of European Integration
*                          Final Report 2024/2025
*
*   Course:        20269 Economics of European Integration
*   Institution:   Bocconi University
*   Authors:       Enrico Ancona, Simone Donoghue, Stefano Graziosi
*   Date:          February 2025
*
*   Description:   This is the main analysis file for the Economics of
*                  European Integration final report. It contains analysis
*                  covering 7 problems across 2 parts:
*                  - Part 1: Production function estimation (OLS, WRDG, LP)
*                  - Part 2: China shock analysis, IV regressions, ESS survey
*
*   File:          main_analysis.do (previously 20269_takehome.do)
*   Repository:    https://github.com/stfgrz/20269-eei-report
*
*   Note:          This file has been refactored as part of repository
*                  reorganization. All paths now use relative paths from
*                  the repository root to ensure portability.
*
*============================================================================

*=============================================================================
/* 								Setup 										*/
*=============================================================================

/* For commands */
/*
ssc install outreg2, replace
ssc install estout, replace
search levpet
search prodest
*/

/* For graphs & stuff */
/*
ssc install grstyle, replace
ssc install coefplot, replace
graph set window fontface "Lato"
grstyle init
grstyle set plain, horizontal
*/

*=============================================================================
/* 						Path Configuration 								*/
*=============================================================================
* Note: This file is now located in /code directory. Paths are set relative
* to the repository root for portability across different systems.

clear all
set more off
set maxvar 10000

* Detect username and set paths
local user = c(username)

if ("`user'" == "stefanograziosi") {
    global root "/Users/stefanograziosi/Documents/GitHub/20269-eei-report"
}
else if ("`user'" == "enricoancona") {
    global root "C:/Users/enricoancona/Documents/GitHub/20269-eei-report"
}
else if ("`user'" == "simon") {
    global root "C:/Users/simon/Documents/GitHub/20269-eei-report"
}
else {
    * Fallback: assume current directory is repository root
    global root "."
}

* Set subdirectory globals
global code     "$root/code"
global data     "$root/data"
global output   "$root/output"
global figures  "$output/figures"
global tables   "$output/tables"
global intermediate "$output/intermediate"

* Data subdirectories
global firm_data    "$data/firm_level"
global regional     "$data/regional"
global trade        "$data/trade"
global political    "$data/political"
global shapefiles   "$data/shapefiles"

* Set working directory
cd "$root"

* Create output directories if they don't exist
capture mkdir "$output"
capture mkdir "$figures"
capture mkdir "$tables"
capture mkdir "$intermediate"

*=============================================================================
/*)))))))))))))))))))) 			PART 1 			((((((((((((((((((((((((((((*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b7808de62ba85f86396e28f7cbf865ac9771cafe/data/EEI_TH_2025.dta", clear

tab country, generate(dcountry_)
tab year, generate(dyear_)

foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var' = ln(`var')
}

*=============================================================================
**# 							Problem 1 									*/
*=============================================================================

/* (a) Focus only on French firms. Starting from balance-sheet data, provide some descriptive statistics (e.g. n. of firms, average capital, revenues, number of employees, value added) in 2007 comparing firms in sector 13 (textiles) and firms in sector 29 (motor vehicles, trailers and semi-trailers) for the region Nord - Pas de Calais -> FR30. Please use the NUTS level 2 - 2013 definition. Comment briefly. */

preserve
	keep if nuts2 == "FR30" & year == 2007
	
	tabulate sector

	tabstat real_sales real_K real_M real_VA L W, by(sector) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W, by(sector) /// 
		continuous(                                         ///
        real_sales real_K real_M real_VA L W,         		///
        statistics(mean median p25 p75)               		///
		)													///  
		nformat(%7.2f mean) 								///
		title(Table 1. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2007) ///
		export($tables/table1.tex, replace) 
		
	*graph box real_sales real_K real_M real_VA L W if sizeclass != 5, over(sizeclass) by(sector, cols(1))
restore

	/* A: answer and comment */
	
/* (b) Compare the descriptive statistics that you have analyzed in point (a) for 2007 to the same figures in 2017. What changes? Comment and give an interpretation.*/

preserve
	keep if nuts2 == "FR30" & year == 2017
	
	tabulate sector

	tabstat real_sales real_K real_M real_VA L W, by(sector) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W, by(sector) /// 
		continuous(                                         ///
        real_sales real_K real_M real_VA L W,         		///
        statistics(mean median p25 p75)               		///
		)													///  
		nformat(%7.2f mean) 								///
		title(Table 1. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2017) ///
		export($tables/table2.tex, replace) 
restore

	/* A: answer and comment */


*=============================================================================
**#								Problem 2 									
*=============================================================================

/* (a) Consider now all the three countries. Estimate for the two industries available in NACE Rev. 2 2-digit format the production function coefficients, by using standard OLS, the Wooldridge (WRDG) and the Levinsohn & Petrin (LP) procedure. How do you treat the fact that data come from different countries in different years in the productivity estimation? */

	/*(i) OLS: Straight linear regression of log(value added) on log(labor) and log(capital); potentially biased if firms choose inputs based on unobserved productivity shocks. */

** sector 13 (Textiles)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13
predict ln_TFP_OLS_13, residuals 

gen TFP_OLS_13= exp(ln_TFP_OLS_13)

** sector 29 (Automotive)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
predict ln_TFP_OLS_29, residuals 

gen TFP_OLS_29= exp(ln_TFP_OLS_29)

	/* (ii) Wooldridge (WRDG): Further refinements of proxy variable methods; attempt to handle collinearity issues (ACF) and to combine multiple steps into a single estimation (Wooldridge) to improve efficiency. */

** sector 13 (Textiles)

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) control(i.country) va
predict ln_TFP_WRDG_13, resid

gen TFP_WRDG_13=exp(ln_TFP_WRDG_13)

* NB: Woolridge non serve usare year fixed effects (già inclusi) né panel_id (id_n). TAs: non serve neanche controllare per country dummies.

** sector 29 (Automotive)

xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) control(i.country) va
predict ln_TFP_WRDG_29, resid

gen TFP_WRDG_29=exp(ln_TFP_WRDG_29)

	/* (iii) Levinsohn & Petrin (LP): Uses intermediate inputs (e.g., materials) as a proxy for unobserved productivity; partially addresses the endogeneity problem that arises if high-productivity firms systematically choose more inputs. */
	
** sector 13 (Textiles)

xi: levpet ln_real_VA if sector==13, free(ln_L i.country i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99) va
predict TFP_LP_13, omega

** sector 29 (Automotive)

xi: levpet ln_real_VA if sector==29, free(ln_L i.country i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99) va
predict TFP_LP_29, omega

	/* A: answer and comment */

/* (b) Present a Table (SEE THE ONE IN THE PDF), where you compare the coefficients obtained in the estimation outputs, indicating their significance levels (*, ** or *** for 10, 5 and 1 per cent). Is there any bias of the labour coefficients? What is the reason for that? */

	/* A: answer and comment */

save "$intermediate/input_Q4.dta", replace

/* Results:

- NACE-13 (labour and capital): OLS 0.806 and 0.163; WRDG 0.663 and 0.058; LP 0.639 and 0.072 --
- NACE-19 (labour and capital): OLS 0.910 and 0.125; WRDG 0.683 and 0.079; LP 0.647 and 0.078 --

*/


*=============================================================================
**#								Problem 3 									
*=============================================================================

/* (a) Would there be any difference in estimating the production function using revenues rather than added values in LP, WRDG or OLS? Why is it so? Discuss the issue theoretically, considering the assumptions behind the Cobb-Douglas production function. */

	/* A: See overleaf */


*=============================================================================
**#  							Problem 4 							
*=============================================================================

/* (a) Comment on the presence of "extreme" values in both industries. Clear the TFP estimates from these extreme values (1st and 99th percentiles) and save a "cleaned sample". From now on, focus on this sample. Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry. What do you notice? Are there any differences if you rely on the LP or WRDG procedure? Comment. */

clear all 
use "$intermediate/input_Q4.dta", replace

*** Clearing of extreme values

** WRDG estimates

foreach s in 13 29 {
sum TFP_WRDG_`s' if sector==`s', d
replace TFP_WRDG_`s'=. if !inrange(TFP_WRDG_`s', r(p1),r(p99)) & sector==`s'
sum TFP_WRDG_`s' if sector==`s', d
}

gen TFP_WRDG = .
replace TFP_WRDG=TFP_WRDG_13 if sector==13
replace TFP_WRDG=TFP_WRDG_29 if sector==29
gen ln_TFP_WRDG=ln(TFP_WRDG)

** LP estimates

foreach s in 13 29 {
sum TFP_LP_`s' if sector==`s', d
replace TFP_LP_`s'=. if !inrange(TFP_LP_`s', r(p1),r(p99)) & sector==`s'
sum TFP_LP_`s' if sector==`s', d
}

gen TFP_LP = .
replace TFP_LP=TFP_LP_13 if sector==13
replace TFP_LP=TFP_LP_29 if sector==29
gen ln_TFP_LP=ln(TFP_LP)

save "$intermediate/part_I_cleaned_sample.dta", replace


** Plotting of the densities

use "$intermediate/part_I_cleaned_sample.dta", clear

** WRDG estimates

tw (kdensity TFP_WRDG if sector==13, lcolor(sienna)) || (kdensity TFP_WRDG if sector==29, lcolor(black)), title("TFP Densities with WRDG") legend(label(1 "Textile") label(2 "Automotive"))

graph save "$figures/Q4a_WRDG.gph", replace
graph export "$figures/Q4a_WRDG.png", replace

tw (kdensity ln_TFP_WRDG if sector==13, lcolor(sienna)) || (kdensity ln_TFP_WRDG if sector==29, lcolor(black)), title("Log-TFP Densities with WRDG") legend(label(1 "Textile") label(2 "Automotive"))

graph save "$figures/Q4a_lnWRDG.gph", replace
graph export "$figures/Q4a_lnWRDG.png", replace

** LP estimates

tw (kdensity TFP_LP if sector==13, lcolor(sienna)) || (kdensity TFP_LP if sector==29, lcolor(black)), title("TFP Densities with LP") legend(label(1 "Textile") label(2 "Automotive"))

graph save "$figures/Q4a_LP.gph", replace
graph export "$figures/Q4a_LP.png", replace

tw (kdensity ln_TFP_LP if sector==13, lcolor(sienna)) || (kdensity ln_TFP_LP if sector==29, lcolor(black)), title("Log-TFP Densities with LP") legend(label(1 "Textile") label(2 "Automotive"))

graph save "$figures/Q4a_lnLP.gph", replace
graph export "$figures/Q4a_lnLP.png", replace

* comparison  WRDG vs LP

graph combine "$figures/Q4a_WRDG.gph" "$figures/Q4a_LP.gph"

graph export "$figures/Q4a_comparison_LP_vs_WRDG.png", replace

graph combine "$figures/Q4a_lnWRDG.gph" "$figures/Q4a_lnLP.gph"

graph export "$figures/Q4a_comparison_lnLP_vs_lnWRDG.png", replace


/* (b) Plot the TFP distribution for each country. Are there any differences if you rely on the LP or WRDG procedure? Compare and comment. */

clear all 
use "$intermediate/part_I_cleaned_sample.dta", replace

*** NB: from now on we only use non-log TFP distributions for comparing (more immediate)

* WRDG estimates for Textile

preserve
keep if sector == 13

tw (kdensity TFP_WRDG if country == "France", lcolor(blue)) || (kdensity TFP_WRDG if country == "Spain", lcolor(orange)) (kdensity TFP_WRDG if country == "Italy", lcolor(red)), title("TFP Densities in Textile (NACE-13) — WRDG") legend(label(1 "France") label(2 "Spain") label(3 "Italy"))

graph save "$figures/Q4b_WRDG_13.gph", replace
graph export "$figures/Q4b_WRDG_13.png", replace

* LP estimates for Textile

tw (kdensity TFP_LP if country == "France", lcolor(blue)) || (kdensity TFP_LP if country == "Spain", lcolor(orange)) (kdensity TFP_LP if country == "Italy", lcolor(red)), title("TFP Densities in Textile (NACE-13) — LP") legend(label(1 "France") label(2 "Spain") label(3 "Italy"))

graph save "$figures/Q4b_LP_13.gph", replace
graph export "$figures/Q4b_LP_13.png", replace

* comparison WRDG vs LP for Textile

graph combine "$figures/Q4b_WRDG_13.gph" "$figures/Q4b_LP_13.gph"
graph export "$figures/Q4b_comparison_LP_vs_WRDG_13.png", replace

restore

* WRDG estimates for Automotive

preserve
keep if sector == 29

tw (kdensity TFP_WRDG if country == "France", lcolor(blue)) || (kdensity TFP_WRDG if country == "Spain", lcolor(orange)) (kdensity TFP_WRDG if country == "Italy", lcolor(red)), title("TFP Densities in Automotive (NACE-29) — WRDG") legend(label(1 "France") label(2 "Spain") label(3 "Italy"))

graph save "$figures/Q4b_WRDG_29.gph", replace
graph export "$figures/Q4b_WRDG_29.png", replace

* LP estimates for Automotive

tw (kdensity TFP_LP if country == "France", lcolor(blue)) || (kdensity TFP_LP if country == "Spain", lcolor(orange)) (kdensity TFP_LP if country == "Italy", lcolor(red)), title("TFP Densities in Automotive (NACE-29) — LP") legend(label(1 "France") label(2 "Spain") label(3 "Italy"))

graph save "$figures/Q4b_LP_29.gph", replace
graph export "$figures/Q4b_LP_29.png", replace

* comparison WRDG vs LP

graph combine "$figures/Q4b_WRDG_29.gph" "$figures/Q4b_LP_29.gph"
graph export "$figures/Q4b_comparison_LP_vs_WRDG_29.png", replace

restore
	
/* (c) Focus now on the TFP distributions of industry 13 in France and Spain. Do you find changes in these two TFP distributions in 2006 vs 2015? Did you expect these results? Compare the results obtained with WRDG and LP procedure and comment. */

clear all 
use "$intermediate/part_I_cleaned_sample.dta", replace

* WRDG estimates

preserve 

keep if sector == 13

tw (kdensity TFP_WRDG if country == "France" & year == 2006, lcolor(blue)) || (kdensity TFP_WRDG if country == "France" & year == 2015, lcolor(orange)), title("TFP in France with WRDG") legend(label(1 "2006") label(2 "2015"))

graph save "$figures/Q4c_WRDG_France.gph", replace
graph export "$figures/Q4c_WRDG_France.png", replace

tw (kdensity TFP_WRDG if country == "Spain" & year == 2006, lcolor(blue)) || (kdensity TFP_WRDG if country == "Spain" & year == 2015, lcolor(orange)), title("TFP in Spain with WRDG") legend(label(1 "2006") label(2 "2015"))

graph save "$figures/Q4c_WRDG_Spain.gph", replace
graph export "$figures/Q4c_WRDG_Spain.png", replace

graph combine "$figures/Q4c_WRDG_France.gph" "$figures/Q4c_WRDG_Spain.gph"
graph export "$figures/Q4c_comparison_FR_vs_SP_WRDG.png", replace

restore

* LP estimation

preserve 

keep if sector == 13

tw (kdensity TFP_LP if country == "France" & year == 2006, lcolor(blue)) || (kdensity TFP_LP if country == "France" & year == 2015, lcolor(orange)), title("TFP in France with LP") legend(label(1 "2006") label(2 "2015"))

graph save "$figures/Q4c_LP_France.gph", replace
graph export "$figures/Q4c_LP_France.png", replace

tw (kdensity TFP_LP if country == "Spain" & year == 2006, lcolor(blue)) || (kdensity TFP_LP if country == "Spain" & year == 2015, lcolor(orange)), title("TFP in Spain with LP") legend(label(1 "2006") label(2 "2015"))

graph save "$figures/Q4c_LP_Spain.gph", replace
graph export "$figures/Q4c_LP_Spain.png", replace

graph combine "$figures/Q4c_LP_France.gph" "$figures/Q4c_LP_Spain.gph"
graph export "$figures/Q4c_comparison_FR_vs_SP_LP.png", replace

restore
	
/* (d) Look at changes in skewness in the same time window (again, focus on industry 13 only in these two countries). What happens? Relate this result to what you have found at point c. */

preserve

keep if sector == 13

* Using WRDG

sum TFP_WRDG if country == "France" & year == 2006, detail
sum TFP_WRDG if country == "France" & year == 2015, detail

sum TFP_WRDG if country == "Spain" & year == 2006, detail
sum TFP_WRDG if country == "Spain" & year == 2015, detail

* Using LP

sum TFP_LP if country == "France" & year == 2006, detail
sum TFP_LP if country == "France" & year == 2015, detail

sum TFP_LP if country == "Spain" & year == 2006, detail
sum TFP_LP if country == "Spain" & year == 2015, detail

restore
	
/* (e) Do you find the shifts to be homogenous throughout the distribution? Once you have defined a specific parametrical distribution for the TFP, is there a way through which you can statistically measure the changes in the TFP distribution in each industry over time (2006 vs 2015)? */

*** visually we can see bumps

clear all 
use "$intermediate/part_I_cleaned_sample.dta", replace

sort country sector year
by country sector year: cumul TFP_LP, generate(cum_TFP_LP)
gen rhs_LP=log(1- cum_TFP_LP)

keep if year <= 2015 & year >= 2006

preserve

keep if country == "France"

qui reg rhs_LP ln_TFP_LP if sector== 13
outreg2 using "$tables/Pareto_France.tex", replace title("Pareto Distribution (France)") ctitle("Average")
qui reg rhs_LP ln_TFP_LP if sector== 13 & year==2006
outreg2 using "$tables/Pareto_France.tex", append title("Pareto Distribution (France)") ctitle("2006")
qui reg rhs_LP ln_TFP_LP if sector==13 & year==2015
outreg2 using "$tables/Pareto_France.tex", append title("Pareto Distribution (France)") ctitle("2015")

restore

preserve

keep if country == "Spain"

qui reg rhs_LP ln_TFP_LP if sector==13
outreg2 using "$tables/Pareto_Spain.tex", replace title("Pareto Distribution (Spain)") ctitle("Average")
qui reg rhs_LP ln_TFP_LP if sector==13 & year==2006
outreg2 using "$tables/Pareto_Spain.tex", append title("Pareto Distribution (Spain)") ctitle("2006")
qui reg rhs_LP ln_TFP_LP if sector==13 & year==2015
outreg2 using "$tables/Pareto_Spain.tex", append title("Pareto Distribution (Spain)") ctitle("2015")

restore

*** the coefficient decreases (from more negative to less negative), so the Pareto distribution's tail is becoming fatter --> higher concentration of TFP in the upper tail in both industries

	
*=============================================================================
/*)))))))))))))))))))) 			PART 2 			((((((((((((((((((((((((((((*/
*=============================================================================

*=============================================================================
**# 							Problem 5
*=============================================================================

ssc install spmap, replace
ssc install shp2dta, replace
ssc install mif2dta, replace
ssc install palettes, replace
ssc install colrspace, replace
set scheme s2color

/* (a) Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to the equation above. Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting ∆IM P Chinackt with ∆IM P ChinaU SAkt, following the identification strategy by Colantone and Stanig (AJPS, 2018). */

	*—— i. Load pre-sample employment shares (first year only) ———————————————*
use "$regional/Employment_Shares_Take_Home.dta", clear

sort country nuts2 nace year

gen ratio_left = empl / tot_empl_nuts2

save "$intermediate/weights_pre.dta", replace

	*—— ii. China imports delta ——————————————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_China_Take_Home.dta", clear

sort year country nace

<<<<<<< Updated upstream
merge 1:m year country nace using "$intermediate/weights_pre.dta"
=======
merge 1:m year country nace using "$processed/weights_pre.dta"
>>>>>>> Stashed changes

egen panel_id = group(country nace nuts2)
xtset panel_id year

gen imp1  				= L.real_imports_china      							// imports at t−1
gen imp6  				= L6.real_imports_china     							// imports at t−6
gen delta_IMP_china 	= imp1 - imp6              								// 5-year growth
gen ratio_right 		= delta_IMP_china / tot_empl_country_nace				// Normalised \Delta IMP china
gen china_shock 		= ratio_left * ratio_right								// Individual element of the china shock

bysort country nuts2 year: egen sum_china_shock = total(china_shock)			// Summation of the individual china shocks

save "$intermediate/ChinaShock_by_region_year.dta", replace

	*—— iii. US imports delta (instrument) ————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_US_China_Take_Home.dta", clear

gen country = "USA"

sort year country nace

<<<<<<< Updated upstream
merge 1:m year nace using "$intermediate/weights_pre.dta"
=======
merge 1:m year nace using "$processed/weights_pre.dta"
>>>>>>> Stashed changes

egen panel_id_us = group (nace nuts2)
xtset panel_id_us year

gen imp1_us    			= L.real_USimports_china
gen imp6_us    			= L6.real_USimports_china
gen delta_IMP_china_us	= imp1_us - imp6_us
gen ratio_right_us		= delta_IMP_china_us / tot_empl_country_nace
gen china_shock_us		= ratio_left * ratio_right_us

drop if missing(china_shock_us)

bysort nuts2 year: egen sum_china_shock_us = total(china_shock_us)

save "$intermediate/ChinaShock_by_region_year_us.dta", replace

/* (b) Collapse the dataset by region to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. */

	*—— Collapse observation dataset ——————————————————————————————*

use "$intermediate/ChinaShock_by_region_year.dta", clear
collapse (mean) sum_china_shock, by(nuts2 nuts2_name)
rename nuts2        	NUTS_ID
rename nuts2_name   	NAME_LATN
save "$intermediate/collapsedimpshock.dta", replace
 
	*—— Collapse instrument dataset ——————————————————————————————*

use "$intermediate/ChinaShock_by_region_year_us.dta", clear
collapse (mean) sum_china_shock_us, by(nuts2 nuts2_name)
rename nuts2        	NUTS_ID
rename nuts2_name   	NAME_LATN
save "$intermediate/collapsedimpshock_us.dta", replace

/*NOTA BENE: il secondo dataset americano contiene osservazioni per 1989 - 2006, quello europeo invece 1988 - 2007. Vogliamo fare trimming del primo e ultimo anno prima di fare merge o lasciamo così ed elaboriamo in seguito? Dato che la cartina va fatta con il dataset europeo penso sia melgio avere più dati */

	*—— Merge the two dataset ——————————————————————————————*

use "$intermediate/collapsedimpshock.dta", clear

<<<<<<< Updated upstream
merge 1:1 NUTS_ID using "$intermediate/collapsedimpshock_us.dta"
=======
merge 1:1 NUTS_ID using "$processed/collapsedimpshock_us.dta"
>>>>>>> Stashed changes
drop _merge

save "$intermediate/sum_china_shock_merged.dta", replace
	
/* (c) Produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment Shares Take Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. Do you notice any similarities between the two maps? What were your expectations? Comment. LINK TO TUTORIAL ON THE PDF */


	*—— Convert & merge NUTS-2 shapefile ————————————————————————————————————*
shp2dta using "$shapefiles/NUTS_RG_20M_2013_3035.shp", database("$intermediate/nuts2_db.dta") coordinates("$intermediate/nuts2_coords.dta") genid(uid) replace

	*—— Load & merge region-cross-section shocks ——————————————————————————————*
use "$intermediate/nuts2_db.dta", clear
describe

merge 1:1 NUTS_ID using "$intermediate/sum_china_shock_merged.dta"
drop if _merge==1
drop _merge

	*—— Map average China shock ——————————————————————————————————————*
spmap sum_china_shock using "$intermediate/nuts2_coords.dta", id(uid) 						///
    fcolor(Blues) clmethod(kmeans) clnumber(8) ocolor(none) 					///
    title("Avg. 5-Year China Shock by NUTS-2 Region") 							///
    note("Source: own elaboration based on Colantone and Stanig (AJPS, 2018)", size(2.5)) ///
	subtitle("1988 to 2007 sample; quantile shading", size(4))					///
	saving("$figures/map_sum_china_shock.gph", replace)

graph export "$figures/map_sum_china_shock.pdf", as(pdf) replace
	
kdensity sum_china_shock

	*—— Compute & map pre-sample manufacturing share ——————————————————————*
use "$regional/Employment_Shares_Take_Home.dta", clear

keep if year==1988

collapse (sum) empl tot_empl_nuts2, by(country nuts2)

gen manuf_share = empl / tot_empl_nuts2

rename nuts2 NUTS_ID

save "$intermediate/manuf_share.dta", replace

use "$intermediate/nuts2_db.dta", clear
describe

merge 1:1 NUTS_ID using "$intermediate/manuf_share.dta"
keep if _merge==3
drop _merge


spmap manuf_share using "$intermediate/nuts2_coords.dta", ///
    id(uid) ///
    fcolor(Greens)  ///
    clmethod(kmeans) ///
    clnumber(8) ///
    ocolor(none) ///
    title("Pre-sample Manufacturing Share by NUTS-2 Region") ///
    subtitle("Year 1988; k-means classes") ///
    note("Source: own elaboration", size(2.5)) ///
	saving("$figures/map_manuf_share.gph", replace)

graph export "$figures/map_manuf_share.pdf", as(pdf) replace

	*—— Recap table ——————————————————————*

use "$intermediate/sum_china_shock_merged.dta", clear

cap which estout
if _rc ssc install estout, replace

// 2. Collect detailed summary stats
estpost summarize sum_china_shock, detail

// 3. Export with custom stat–labels
estout using "$tables/Table1_DescStats.tex", ///
    cells("count(fmt0) mean(fmt3) sd(fmt3) p25(fmt3) p50(fmt3) p75(fmt3) min(fmt3) max(fmt3)") ///
    varlabels(sum_china_shock "Average 5-Year China Shock") ///
    statslabels("N" "Mean" "Std. Dev." "25th pct." "Median" "75th pct." "Min" "Max") ///
    booktabs nonumber nomtitle ///
    title("Table 1: Descriptive Statistics of China Shock") ///
    replace
	
*=============================================================================
**# 							Problem 6 									
*=============================================================================

use "$intermediate/sum_china_shock_merged.dta", clear
rename NUTS_ID nuts2
save "$intermediate/sum_china_shock_merged.dta", replace


/* Use the dataset "EEI TH P6 2025.dta" to construct an average of TFP and wages during the post-crisis years (2014-2017). Create a lag of 3 years in the control variables (education, GDP and population). Now merge the data you have obtained with data on the China shock (region-specific average). */

use "$regional/EEI_TH_P6_2025.dta", clear

* generate 2014-2017 averages for TFPs and wages
gen tfp_temp = tfp if inrange(year, 2014, 2017)
egen avg_tfp = mean(tfp_temp), by(nuts_code nace2_2_group)
gen wage_temp = mean_uwage if inrange(year, 2014, 2017)
egen avg_wage = mean(wage_temp), by(nuts_code nace2_2_group)

* generate 3-yr lags for education, GDP and population
egen panel_id = group(nuts_code nace2_2_group)
xtset panel_id year

gen edu_lag3 = L3.share_tert_educ
*NB: Missing values to handle
gen gdp_lag3 = L3.control_gdp
gen pop_lag3 = L3.lnpop

keep if year >= 2014 & year <= 2017

decode cou, gen(country_str)
replace country_str = "Spain" if country_str == "ES"
replace country_str = "France" if country_str == "FR"
replace country_str = "Italy" if country_str == "IT"
rename country_str country

rename nuts_code nuts2
keep nuts2 nace2_2_group year tfp avg_tfp avg_wage edu_lag3-pop_lag3 country

<<<<<<< Updated upstream
merge m:1 nuts2 using "$intermediate/sum_china_shock_merged.dta"
=======
merge m:1 nuts2 using "$processed/sum_china_shock_merged.dta"
>>>>>>> Stashed changes
format nuts2 %-10s
drop if _merge==1
drop _merge

label variable avg_tfp "Average post-crisis TFP"
label variable avg_wage "Average post-crisis wage"
label variable sum_china_shock "Import Shock"
label variable sum_china_shock_us "U.S. imports from China"
label variable edu_lag3 "Education (lagged)"
label variable gdp_lag3 "GDP (lagged)"
label variable pop_lag3 "Population (lagged)"

save "$intermediate/Q6.dta", replace

*NB: 96 not merged and deleted (nuts: ES63, ES64, FRA1-FRA4)

/* (a) Regress (simple OLS) the post-crisis average of TFP against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues. */

* run OLS regression for average TFP

<<<<<<< Updated upstream
use "$intermediate/Q6.dta", clear
=======
use "$processed/Q6.dta", clear

* Collapse to a true cross-section: one observation per nuts2 × nace
* The dependent variables (avg_tfp, avg_wage) are already time-invariant averages,
* so keeping the panel structure would be pseudo-replication.
collapse (mean) avg_tfp avg_wage sum_china_shock sum_china_shock_us ///
    edu_lag3 gdp_lag3 pop_lag3, by(nuts2 country nace2_2_group)

label variable avg_tfp "Average post-crisis TFP"
label variable avg_wage "Average post-crisis wage"
label variable sum_china_shock "Import Shock"
label variable sum_china_shock_us "U.S. imports from China"
label variable edu_lag3 "Education (lagged)"
label variable gdp_lag3 "GDP (lagged)"
label variable pop_lag3 "Population (lagged)"

>>>>>>> Stashed changes
gen dummy = 1
gen y = runiform()
reg y if dummy == 1 // blank model for table formatting
eststo m1
generate x = runiform()
reg x if dummy == 1  // another blank model for table formatting
eststo m3

* OLS (cross-sectional: no year FE needed)
xi: regress avg_tfp sum_china_shock edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo OLS_tfp: 
scalar R2 = e(r2)
scalar R2_a = e(r2_a)
scalar F_ols = e(F)
estadd scalar R2 
estadd scalar R2_a
estadd scalar F_ols

* computing the effect of the China shock in terms of standard deviations - OLS
scalar beta_OLS= e(b)[1,1]
sum sum_china_shock
scalar sum_china_shock_sd=r(sd)
scalar effect_OLS=beta_OLS*sum_china_shock_sd
scalar list effect_OLS

* compare it to the average TFP 
sum avg_tfp
scalar mean_avg_tfp=r(mean)
scalar ratio_OLS=abs(effect_OLS/mean_avg_tfp)
scalar list ratio_OLS


/* (b) To deal with endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA, and run again the regressions as in a). Do you see any changes in the coefficient? */

* 2SLS
xi: reg sum_china_shock sum_china_shock_us edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo First_Stage_tfp

xi: ivreg2 avg_tfp (sum_china_shock = sum_china_shock_us) edu_lag3-pop_lag3 i.country i.nace2_2_group, first robust
scalar F_1st = e(widstat)
estadd scalar F_1st

xi: ivregress 2sls avg_tfp (sum_china_shock = sum_china_shock_us) edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo IV_tfp

scalar R2 = e(r2)
scalar R2_a = e(r2_a)
estadd scalar R2 
estadd scalar R2_a

* computing the effect of the China shock in terms of standard deviations - IV
scalar beta_IV= e(b)[1,1]
sum sum_china_shock
scalar sum_china_shock_sd=r(sd)
scalar effect_IV=beta_IV*sum_china_shock_sd
scalar list effect_IV

* compare it to the average TFP
sum avg_tfp
scalar mean_avg_tfp=r(mean)
scalar ratio_IV=abs(effect_IV/mean_avg_tfp)
scalar list ratio_IV

* panel A
	estout OLS_tfp IV_tfp ///
 using "$tables/EEI_Take_Home_VI_bb.tex", replace style(tex) ///
	keep(sum_china_shock) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(N R2 R2_a F_ols, fmt(a3 3) labels("Observations" "R^2" "Adjusted-R^2" "F-statistic")) ///
	prehead("\begin{table}[H]" "\centering" "\begin{tabular}{lcc}" ///
			"\hline \hline \noalign{\smallskip}" ///
			"\cmidrule(lr){2-3} " ///
			" & (1) & (2) \\" "& OLS & 2SLS \\" ) ///
			posthead("\hline \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel A: TFP on China Shock}} \\" "\noalign{\smallskip} \noalign{\smallskip}" ) ///	
	prefoot("\noalign{\smallskip}" "Controls & \checkmark & \checkmark " ///
	"Country-Year FE & \checkmark & \checkmark & \\ " /// 
	"Industry FE & \checkmark & \checkmark & \\ " )	
	
	 
* panel B
	estout m1 First_Stage_tfp ///
 using "$tables/EEI_Take_Home_VI_bb.tex", append style(tex) ///
	posthead("\noalign{\smallskip} \hline \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel B: First Stage China Shock on China Shock US}} \\" "\noalign{\smallskip} \noalign{\smallskip}" ) ///
	keep(sum_china_shock_us) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(F_1st, fmt(a3 3) labels("Kleibergen-Paap F")) ///
	postfoot("\noalign{\smallskip} \hline \hline \noalign{\smallskip}" ///
	"\multicolumn{3}{l}{\footnotesize{Standard errors in parentheses *** p$<$0.01, ** p$<$0.05, * p$<$0.1}} \\" ///
	"\end{tabular}" "\caption{Effect of China shock on TFP}" "\end{table}")
	
/* (c) Now, regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock. Lastly, what happens if you regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed. Control for the average TFP during the post-crisis years, an interaction term between average of TFP and China shock and for the 3-year lags of population, education and GDP? Comment. */


* run OLS and IV regressions for wage

xi: reg avg_wage sum_china_shock edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo OLS_wage
scalar R2 = e(r2)
scalar R2_a = e(r2_a)
scalar F_ols = e(F)
estadd scalar R2 
estadd scalar R2_a
estadd scalar F_ols

	* computing the effect of the China shock in terms of standard deviations - OLS
	scalar beta_OLS_wage= e(b)[1,1]
	sum sum_china_shock
	scalar sum_china_shock_sd=r(sd)
	scalar effect_OLS_wage=beta_OLS_wage*sum_china_shock_sd
	scalar list effect_OLS_wage

	* compare it to the average wage
	sum avg_wage
	scalar mean_avg_wage=r(mean)
	scalar ratio_OLS_wage=abs(effect_OLS_wage/mean_avg_wage)
	scalar list ratio_OLS_wage

* 2SLS 

xi: reg sum_china_shock sum_china_shock_us edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo First_Stage_wage

xi: ivreg2 avg_wage (sum_china_shock = sum_china_shock_us) edu_lag3-pop_lag3 i.country i.nace2_2_group, first robust
scalar F_1st = e(widstat)
estadd scalar F_1st

xi: ivregress 2sls avg_wage (sum_china_shock = sum_china_shock_us) edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo IV_wage

scalar R2 = e(r2)
scalar R2_a = e(r2_a)
estadd scalar R2 
estadd scalar R2_a

	* computing the effect of the China shock in terms of standard deviations - IV
	scalar beta_IV_wage= e(b)[1,1]
	sum sum_china_shock
	scalar sum_china_shock_sd=r(sd)
	scalar effect_IV_wage=beta_IV_wage*sum_china_shock_sd
	scalar list effect_IV_wage

	* compare it to the average wage
	sum avg_wage
	scalar mean_avg_wage=r(mean)
	scalar ratio_IV_wage=abs(effect_IV_wage/mean_avg_wage)
	scalar list ratio_IV_wage


* generate the interaction term
capture gen inter_term = avg_tfp*sum_china_shock
label variable inter_term "Interaction term"

* run OLS and IV regressions for wage with additional control and interaction

xi: reg avg_wage sum_china_shock avg_tfp inter_term edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo OLS_wage_int
scalar R2 = e(r2)
scalar R2_a = e(r2_a)
scalar F_ols = e(F)
estadd scalar R2 
estadd scalar R2_a
estadd scalar F_ols

* computing the effect of the China shock in terms of standard deviations - OLS (with interaction)
	scalar beta_OLS_wage_int= e(b)[1,1]
	sum sum_china_shock
	scalar sum_china_shock_sd=r(sd)
	scalar effect_OLS_wage_int=beta_OLS_wage_int*sum_china_shock_sd
	scalar list effect_OLS_wage_int

	* compare it to the average wage
	sum avg_wage
	scalar mean_avg_wage=r(mean)
	scalar ratio_OLS_wage_int=abs(effect_OLS_wage_int/mean_avg_wage)
	scalar list ratio_OLS_wage_int

xi: reg sum_china_shock sum_china_shock_us edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo First_Stage_wage_int

* NOTE: inter_term = avg_tfp * sum_china_shock contains the endogenous variable,
* so it must also be instrumented. We use avg_tfp * sum_china_shock_us as the
* additional excluded instrument.
gen inter_iv = avg_tfp * sum_china_shock_us
label variable inter_iv "TFP $\times$ China Shock IV"

xi: ivreg2 avg_wage (sum_china_shock inter_term = sum_china_shock_us inter_iv) avg_tfp edu_lag3-pop_lag3 i.country i.nace2_2_group, first robust
scalar F_1st= e(widstat)
estadd scalar F_1st

xi: ivregress 2sls avg_wage (sum_china_shock inter_term = sum_china_shock_us inter_iv) avg_tfp edu_lag3-pop_lag3 i.country i.nace2_2_group, robust
eststo IV_wage_int

scalar R2 = e(r2)
scalar R2_a = e(r2_a)
estadd scalar R2 
estadd scalar R2_a

* computing the effect of the China shock in terms of standard deviations - IV (with interaction)
	scalar beta_IV_wage_int= e(b)[1,1]
	sum sum_china_shock
	scalar sum_china_shock_sd=r(sd)
	scalar effect_IV_wage_int=beta_IV_wage_int*sum_china_shock_sd
	scalar list effect_IV_wage_int

	* compare it to the average wage
	sum avg_wage
	scalar mean_avg_wage=r(mean)
	scalar ratio_IV_wage_int=abs(effect_IV_wage_int/mean_avg_wage)
	scalar list ratio_IV_wage_int

* exporting the results to Latex

label var sum_china_shock "China Shock"
	label var sum_china_shock_us "China Shock Instrument (China-USA)"
	label var inter_term "TFP $\times$ China Shock"
	label var avg_tfp "Average post-crisis TFP"
	
* panel A
	estout OLS_wage IV_wage OLS_wage_int IV_wage_int ///
 using "$tables/EEI_Take_Home_VI_cc3.tex", replace style(tex) ///
	keep(sum_china_shock avg_tfp inter_term) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(N R2 R2_a F_ols, fmt(a3 3) labels("Observations" "R^2" "Adjusted-R^2" "F-statistic")) ///
	prehead("\begin{table}[H]" "\centering" "\begin{tabular}{lcccc}" ///
			"\hline \hline \noalign{\smallskip}" ///
			"& \multicolumn{2}{c} {Wages} & \multicolumn{2}{c} {Interaction}\\" ///
			"\cmidrule(lr){2-3}  \cmidrule(lr){4-5} " ///
			" & (1) & (2) & (3) & (4) \\" "& OLS & 2SLS & OLS & 2SLS \\" ) ///
			posthead("\hline \noalign{\smallskip}" "\multicolumn{5}{l}{\emph{Panel A: Wage and Interaction on China Shock}} \\" "\noalign{\smallskip} \noalign{\smallskip}" ) ///	
	prefoot("\noalign{\smallskip}" ///
	"Controls & \checkmark & \checkmark & \checkmark & \checkmark \\ " ///
	"Country-Year FE & \checkmark & \checkmark & \checkmark & \checkmark \\ " ///
	"Industry FE & \checkmark & \checkmark & \checkmark & \checkmark \\ " )	
	


* panel B
estout m1 First_Stage_wage m3 First_Stage_wage_int ///
 using "$tables/EEI_Take_Home_VI_cc3.tex", append style(tex) ///
	posthead("\noalign{\smallskip} \hline \noalign{\smallskip}" ///
	"\multicolumn{5}{l}{\emph{Panel B: First Stage China Shock on China Shock US}} \\" ///
	"\noalign{\smallskip} \noalign{\smallskip}" ) ///
	keep(sum_china_shock_us) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(F_1st, fmt(a3 3) labels("Kleibergen-Paap F")) ///
	postfoot( ///
	"\noalign{\smallskip} \hline \hline \noalign{\smallskip}" ///
	"\multicolumn{5}{l}{\footnotesize{Standard errors in parentheses *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1}} \\" ///
	"\end{tabular}" "\caption{Effect of China shock on Wages}" "\label{tab:wages}" "\end{table}")
	

*/

*=============================================================================
**# 							Problem 7 									
*=============================================================================

/* (a) Merge the ESS dataset with data on the China shock (region-specific average), based on the region of residence of each respondent. */

use "$regional/ESS8e02_3", clear

	keep if cntry == "IT"
	
	keep gndr agea region edlvdit prtvtbit sbsrnen pspwght
	
	rename region nuts2
	
	save "$intermediate/ESS8_Italy_cleaned.dta", replace

<<<<<<< Updated upstream
merge m:1 nuts2 using "$intermediate/sum_china_shock_merged.dta", keep(match)

	drop _merge

save "$intermediate/Q7ab.dta", replace
=======
merge m:1 nuts2 using "$processed/sum_china_shock_merged.dta", keep(match)

	drop _merge

save "$processed/Q7ab.dta", replace
>>>>>>> Stashed changes
	
sort nuts2
	
/* (b) Regress (simple OLS) the attitude score towards the allocation of public money to subsidize renewable energies on the region-level China shock previously constructed, controlling for gender, age, dummies for levels of education, and dummies for Nuts regions at the 1 digit level. Cluster the standard errors by Nuts region level 2. Be sure to use survey weights in the regression. Comment and discuss possible endogeneity issues. */

gen nuts1 = substr(nuts2, 1, 3)

xi: reg sbsrnen sum_china_shock gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo OLS_attitude
scalar R2 = e(r2)
scalar R2_a = e(r2_a)
scalar F_ols = e(F)
estadd scalar R2 
estadd scalar R2_a
estadd scalar F_ols

	/* A: answer and comment */
	
	
/* (c) To correct for endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA. Discuss the rationale for using this instrumental variable. What happens when you instrument the China shock in the previous regression? Comment both on first-stage and on second-stage results. */

<<<<<<< Updated upstream
merge m:1 nuts2 using "$intermediate/sum_china_shock_merged.dta", keep(match)

drop _merge
=======
* NOTE: sum_china_shock_us already available from the merge at line 980, no second merge needed
>>>>>>> Stashed changes
	
xi: regress sum_china_shock sum_china_shock_us gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo First_Stage_IV_attitude

xi: ivreg2 sbsrnen (sum_china_shock = sum_china_shock_us) ///
    gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2) first
	scalar F_1st= e(widstat)
estadd scalar F_1st

xi: ivregress 2sls sbsrnen (sum_china_shock = sum_china_shock_us) ///
    gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo IV_attitude
	
scalar beta_IV = e(b)[1,1]
sum sum_china_shock
scalar sum_china_shock_sd=r(sd)
scalar effect_IV_sd_attitude = beta_IV * sum_china_shock_sd
display "1-sd IV effect on attitude: " effect_IV_sd_attitude

* Compare it to the average underprivileged minority groups score 
sum sbsrnen
scalar sbsrnen_mean = r(mean)
scalar std_IV_Effect_attitude = abs(effect_IV_sd_attitude/sbsrnen_mean)
display "Standardized IV effect on attitude score: " std_IV_Effect_attitude

estadd scalar effect_IV_sd_attitude, replace
estadd scalar std_IV_Effect_attitude, replace

label var sum_china_shock "China Shock"
label var sum_china_shock_us "China Shock Instrument (China-USA)"
	
* Exporting results to LaTeX:

* panel A 
estout using "$tables/EEI_Take_Home_VIIc.tex", replace style(tex) ///
keep(sum_china_shock) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
 mlabels(, none) collabels(, none) eqlabels(, none) stats(N effect_IV_sd_attitude std_IV_Effect_attitude R2, fmt(a3 3) labels("Observations" "1-sd IV effect on attitude score" "Standardized IV effect on attitude score" "R^2")) ///
prehead("\begin{table}[H]" "\centering" "\begin{tabular}{lcc}" "\noalign{\smallskip} \hline \hline \noalign{\smallskip}" "& \multicolumn{1}{c} {(1)} & \multicolumn{1}{c} {(2)} \\" "& \multicolumn{1}{c} {(OLS)} & \multicolumn{1}{c} {(2SLS)} \\" "\noalign{\smallskip} \hline  \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel A: Impact China Shock on Attitude Score towards Public Green Subsidies}} \\")  ///
posthead("\noalign{\smallskip} \noalign{\smallskip}" ) ///
prefoot("\noalign{\smallskip}" "Controls & \checkmark & \checkmark  \\" ///
"NUTS-1 FE & \checkmark & \checkmark \\ " ///
	"Education FE & \checkmark & \checkmark \\ " )	 

* panel B
estout using "$tables/EEI_Take_Home_VIIc.tex", append style(tex) ///
posthead("\noalign{\smallskip} \hline \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel B: First stage China Shock on China Shock US}} \\" "\noalign{\smallskip} \noalign{\smallskip}") ///
keep(sum_china_shock_us) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) mlabels(, none) collabels(, none) eqlabels(, none) stats(F_1st, fmt(a3 3) labels("Kleibergen-Paap F-statistic")) ///
postfoot("\hline \noalign{\smallskip}" "\multicolumn{3}{l}{\footnotesize{Standard errors in parentheses *** p$<$0.01, ** p$<$0.05, * p$<$0.1}} \\" "\end{tabular}" "\caption{Effect of China Shock on Public Support for Renewable Energy Subsidies}" "\label{tab:results}" "\end{table}")


save "$intermediate/Q7cd.dta", replace

	/* A: answer and comment */
	
	
/* (d) Comment on the sign of the coefficient on the China shock obtained at point c. Provide intuitive theoretical arguments to rationalize this finding. */

	/* A: answer and comment */
	
	
/* (e) Starting from the augmented ESS dataset used in the previous regressions, attach to the variable "party voted in last national election" the score for the "very general favorable references to underprivileged minority groups" available in the Manifesto Project for the election of 2013. You can search in the codebook the code for this score in the dataset. Please note that party names do not necessarily match exactly, and that ESS may have more parties than coded by the Manifesto Project. In the end, you should be able to match 9 parties. */

use "$political/MPDataset_MPDS2024a_stata14.dta", clear

keep if countryname == "Italy" & coderyear == 2013

keep party partyname per705
rename party party_cmp
rename partyname partyname_cmp

save "$intermediate/MP_cleaned.dta", replace

// Step 1: Get the name of the value label attached to party_cmp
local lblname : value label party_cmp

// Step 2: Get unique party codes present in your dataset
levelsof party_cmp, local(partycodes)

// Step 3: Loop through each party code and show its label
display "Matching party_cmp numeric codes and their labels:"
foreach code of local partycodes {
    local code_int = floor(`code')  // safely convert to integer
    local partyname : label `lblname' `code_int'
    display "`code_int' = `partyname'"
}

use "$intermediate/Q7cd.dta", clear

gen party_cmp = .
replace party_cmp = 32440 if prtvtbit == 1  // PD
replace party_cmp = 32061 if prtvtbit == 8  // PDL
replace party_cmp = 32956 if prtvtbit == 4  // M5S
replace party_cmp = 32720 if prtvtbit == 9  // Lega Nord
replace party_cmp = 32230 if prtvtbit == 2  // SEL
replace party_cmp = 32450 if prtvtbit == 6  // UDC
replace party_cmp = 32460 if prtvtbit == 5  // Scelta Civica
replace party_cmp = 32630 if prtvtbit == 10  // Fratelli d'Italia
replace party_cmp = 32021 if prtvtbit == 3  // Rivoluzione Civile (Ingroia)

<<<<<<< Updated upstream
merge m:1 party_cmp using "$intermediate/MP_cleaned.dta", keep(match)
=======
merge m:1 party_cmp using "$processed/MP_cleaned.dta", keep(match)
>>>>>>> Stashed changes

drop _merge

save "$intermediate/Q7ef.dta", replace

	/* A: answer and comment */
	
	
	
/* (f) Regress (both OLS and IV, as above) the underprivileged minority groups score of the party voted against the region-level China shock, controlling for gender, age, dummies for levels of education, and dummies for Nuts regions at the 1 digit level. For this purpose, transform the score as follows:

	minority scorepc = log(.5 + zpc)

	with z being the variable for the "very general favorable references to underprivileged minority groups". Cluster the standard errors by Nuts region level 2. Be sure to use survey weights in the regressions. Comment. */
	
<<<<<<< Updated upstream
use "$intermediate/Q7ef.dta", replace
=======
use "$processed/Q7ef.dta", clear
>>>>>>> Stashed changes

gen z_pc = per705
	
	// first round everything to 2 decimal places
replace z_pc = round(z_pc, 0.01)

drop per705
	
gen minority_score_pc = log(0.5 + z_pc)
	
xi: reg minority_score_pc sum_china_shock gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo OLS_minority
scalar R2 = e(r2)
scalar R2_a = e(r2_a)
scalar F_ols = e(F)
estadd scalar R2 
estadd scalar R2_a
estadd scalar F_ols

xi: ivreg2 minority_score_pc (sum_china_shock = sum_china_shock_us) ///
    gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2) first
scalar F_1st= e(widstat)
estadd scalar F_1st

xi: regress sum_china_shock sum_china_shock_us gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo First_Stage_IV_minority

xi: ivregress 2sls minority_score_pc (sum_china_shock = sum_china_shock_us) ///
    gndr agea i.edlvdit i.nuts1 [pweight=pspwght], cluster(nuts2)
eststo IV_minority

scalar beta_IV = e(b)[1,1]
sum sum_china_shock
scalar sum_china_shock_sd=r(sd)
scalar effect_IV_sd_minority = beta_IV * sum_china_shock_sd
display "1-sd IV effect on minority score: " effect_IV_sd_minority

* Compare it to the average underprivileged minority groups score 
sum minority_score_pc
scalar minority_score_pc_mean = r(mean)
scalar std_IV_effect_minority = abs(effect_IV_sd_minority/minority_score_pc_mean)
display "Standardized IV effect on minority score: " std_IV_effect_minority

estadd scalar effect_IV_sd_minority, replace
estadd scalar std_IV_effect_minority, replace

label var sum_china_shock "China Shock"
label var sum_china_shock_us "China Shock Instrument (China-USA)"
	
* Exporting results to LaTeX:
	
* panel A 
estout using "$tables/EEI_Take_Home_VIIf.tex", replace style(tex) ///
keep(sum_china_shock) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
 mlabels(, none) collabels(, none) eqlabels(, none) stats(N effect_IV_sd_minority std_IV_effect_minority R2, fmt(a3 3) labels("Observations" "1-sd IV effect on attitude score" "Standardized IV effect on attitude score" "R$^2$")) ///
prehead("\begin{table}[H]" "\centering" "\begin{tabular}{lcc}" "\noalign{\smallskip} \hline \hline \noalign{\smallskip}" "& \multicolumn{1}{c} {(1)} & \multicolumn{1}{c} {(2)} \\" "& \multicolumn{1}{c} {(OLS)} & \multicolumn{1}{c} {(2SLS)} \\" "\noalign{\smallskip} \hline  \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel A: Impact of China Score on Underprivileged Minority Groups Score}} \\")  ///
posthead("\noalign{\smallskip} \noalign{\smallskip}" ) ///
prefoot("\noalign{\smallskip}" "Controls & \checkmark & \checkmark  \\" ///
"NUTS-1 FE & \checkmark & \checkmark \\ " ///
	"Education FE & \checkmark & \checkmark \\ " )		 

* panel B
estout using "$tables/EEI_Take_Home_VIIf.tex", append style(tex) ///
posthead("\noalign{\smallskip} \hline \noalign{\smallskip}" "\multicolumn{3}{l}{\emph{Panel B: First stage China Shock on China Shock US}} \\" "\noalign{\smallskip} \noalign{\smallskip}") ///
keep(sum_china_shock_us) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) mlabels(, none) collabels(, none) eqlabels(, none) stats(F_1st, fmt(a3 3) labels("Kleibergen-Paap F-statistic")) ///
prefoot("\noalign{\smallskip}" "Controls &  & \checkmark  \\ ")	 ///
postfoot("\hline \noalign{\smallskip}" "\multicolumn{3}{l}{\footnotesize{Standard errors in parentheses *** p$<$0.01, ** p$<$0.05, * p$<$0.1}} \\" "\end{tabular}" "\caption{Effect of China Shock on Electoral Support for Advocates of Minority Groups}" "\label{tab:results}" "\end{table}")
	

	/* A: answer and comment */
	
	
	
/* (g) What can we learn from the results at point f on the relation between economic and cultural determinants of the globalization backlash? */

	/* A: answer and comment */


