*============================================================================

*					Economics of European Integration
*							Final Report

/* Group composition: Enrico Ancona, Simone Donoghue, Stefano Graziosi */
*============================================================================

*=============================================================================
/* 								Setup 										*/
*=============================================================================

set more off

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

local user = c(username)

if ("`user'" == "stefanograziosi") {
	cd "/Users/stefanograziosi/Documents/GitHub/20269-eei-report"
    global filepath "/Users/stefanograziosi/Documents/GitHub/20269-eei-report"
	global output "/Users/stefanograziosi/Documents/GitHub/20269-eei-report/output"
	global data "/Users/stefanograziosi/Documents/GitHub/20269-eei-report/data"
}

if ("`user'" == "enricoancona") {
    global filepath "CAMBIA"
}

if ("`user'" == "simon") {
    global filepath "CHANGE"
}

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
	
	dtable real_sales real_K real_M real_VA L W i.sizeclass, by(sector) /// 
		nformat(%7.2f mean sd) ///
		title(Table 1. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2007) ///
		export(output/table1.html, replace) 
		
	graph box real_sales real_K real_M real_VA L W if sizeclass != 5, over(sizeclass) by(sector, cols(1))
restore

	/* A: answer and comment */
	
/* (b) Compare the descriptive statistics that you have analyzed in point (a) for 2007 to the same figures in 2017. What changes? Comment and give an interpretation.*/

preserve
	keep if nuts2 == "FR30" & year == 2017
	
	tabulate sector

	tabstat real_sales real_K real_M real_VA L W, by(sector) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W i.sizeclass, by(sector) ///
		nformat(%7.2f mean sd) ///
		title(Table 2. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2017) ///
		export(output/table2.html, replace)
restore

	/* A: answer and comment */


*=============================================================================
**#								Problem 2 									
*=============================================================================

/* (a) Consider now all the three countries. Estimate for the two industries available in NACE Rev. 2 2-digit format the production function coefficients, by using standard OLS, the Wooldridge (WRDG) and the Levinsohn & Petrin (LP) procedure. How do you treat the fact that data come from different countries in different years in the productivity estimation? */

	/*(i) OLS: Straight linear regression of log(value added) on log(labor) and log(capital); potentially biased if firms choose inputs based on unobserved productivity shocks. */

*sector 13 (Textiles) controlling for country and year*
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13
predict ln_TFP_OLS_13, residuals 

gen TFP_OLS_13= exp(ln_TFP_OLS_13)

kdensity TFP_OLS_13, title("OLS TFP (Sector 13 - Textiles)")

*sector 29 (Automotive) controlling for country and year*
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
predict ln_TFP_OLS_29, residuals 

gen TFP_OLS_29= exp(ln_TFP_OLS_29)

kdensity TFP_OLS_29, title("OLS TFP (Sector 29 - Automotive)")
	
	/* (ii) Wooldridge (WRDG): Further refinements of proxy variable methods; attempt to handle collinearity issues (ACF) and to combine multiple steps into a single estimation (Wooldridge) to improve efficiency. */

*sector 13 (Textiles) controlling for country*

xi: prodest ln_real_VA if sector==13, ///
	met(wrdg) ///
	free(ln_L) proxy(ln_real_M) state(ln_real_K) ///
	control(dcountry_1 dcountry_2 dcountry_3) ///
	va 
	
predict ln_TFP_WRDG_13, resid

gen TFP_WRDG_13=exp(ln_TFP_WRDG_13)

kdensity TFP_WRDG_13, title("WRDG TFP (Sector 13 - Textiles)")

*sector 29 (Automotive) controlling for country*

xi: prodest ln_real_VA if sector==29, ///
	met(wrdg) ///
	free(ln_L) proxy(ln_real_M) state(ln_real_K) ///
	control(dcountry_1 dcountry_2 dcountry_3) ///
	va
	
predict ln_TFP_WRDG_29, resid

gen TFP_WRDG_29=exp(ln_TFP_WRDG_29)

kdensity TFP_WRDG_29, title("WRDG TFP (Sector 29 - Automotive)")

	/* (iii) Levinsohn & Petrin (LP): Uses intermediate inputs (e.g., materials) as a proxy for unobserved productivity; partially addresses the endogeneity problem that arises if high-productivity firms systematically choose more inputs. */
	
*sector 13 (Textiles) controlling for country and year*

xi: levpet ln_real_VA if sector==13, free(ln_L i.country i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_13, omega

*sector 29 (Automotive) controlling for country and year*

xi: levpet ln_real_VA if sector==29, free(ln_L i.country i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_29, omega

	/* A: answer and comment */

/* (b) Present a Table (SEE THE ONE IN THE PDF), where you compare the coefficients obtained in the estimation outputs, indicating their significance levels (*, ** or *** for 10, 5 and 1 per cent). Is there any bias of the labour coefficients? What is the reason for that? */

	/* A: answer and comment */


*=============================================================================
**#								Problem 3 									
*=============================================================================

/* (a) Would there be any difference in estimating the production function using revenues rather than added values in LP, WRDG or OLS? Why is it so? Discuss the issue theoretically, considering the assumptions behind the Cobb-Douglas production function. */

	/* A: See overleaf */


*=============================================================================
**#  							Problem 4 							
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b7808de62ba85f86396e28f7cbf865ac9771cafe/data/EEI_TH_2025.dta", clear

tab country, generate(dcountry_)
tab year, generate(dyear_)

foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var' = ln(`var')
}

/* (a) Comment on the presence of "extreme" values in both industries. Clear the TFP estimates from these extreme values (1st and 99th percentiles) and save a "cleaned sample". From now on, focus on this sample. Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry. What do you notice? Are there any differences if you rely on the LP or WRDG procedure? Comment. */

/* OLS */

	*sector 13 (Textiles)*
	
xi: reg ln_real_VA ln_L ln_real_K if sector==13
predict ln_TFP_OLS_13, residuals 

gen TFP_OLS_13= exp(ln_TFP_OLS_13)

	*sector 29 (Automotive)*
	
xi: reg ln_real_VA ln_L ln_real_K if sector==29
predict ln_TFP_OLS_29, residuals 

gen TFP_OLS_29= exp(ln_TFP_OLS_29)

	*clearing outliers*

replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p1),r(p99))
replace TFP_OLS_29=. if !inrange(TFP_OLS_29,r(p1),r(p99))

replace ln_TFP_OLS_13=. if !inrange(ln_TFP_OLS_13,r(p1),r(p99))
replace ln_TFP_OLS_29=. if !inrange(ln_TFP_OLS_29,r(p1),r(p99))

gen TFP_OLS = .
replace TFP_OLS=TFP_OLS_13 if sector==13
replace TFP_OLS=TFP_OLS_29 if sector==29
gen ln_TFP_OLS=ln(TFP_OLS)


/* Wooldridge (WRDG) */

	*sector 13 (Textiles)*

xi: prodest ln_real_VA if sector==13, ///
	met(wrdg) ///
	free(ln_L) proxy(ln_real_M) state(ln_real_K) ///
	va 
	
predict ln_TFP_WRDG_13, resid

gen TFP_WRDG_13=exp(ln_TFP_WRDG_13)

	*sector 29 (Automotive)*

xi: prodest ln_real_VA if sector==29, ///
	met(wrdg) ///
	free(ln_L) proxy(ln_real_M) state(ln_real_K) ///
	va
	
predict ln_TFP_WRDG_29, resid

gen TFP_WRDG_29=exp(ln_TFP_WRDG_29)

	*clearing outliers*

replace TFP_WRDG_13=. if !inrange(TFP_WRDG_13,r(p1),r(p99))
replace TFP_WRDG_29=. if !inrange(TFP_WRDG_29,r(p1),r(p99))

replace ln_TFP_WRDG_13=. if !inrange(ln_TFP_WRDG_13,r(p1),r(p99))
replace ln_TFP_WRDG_29=. if !inrange(ln_TFP_WRDG_29,r(p1),r(p99))

gen TFP_WRDG = .
replace TFP_WRDG=TFP_WRDG_13 if sector==13
replace TFP_WRDG=TFP_WRDG_29 if sector==29
gen ln_TFP_WRDG=ln(TFP_WRDG)

/* Levinsohn & Petrin (LP) */

	*sector 13 (Textiles)*

xi: levpet ln_real_VA if sector==13, free(ln_L) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_13, omega

gen ln_TFP_LP_13 =ln(TFP_LP_13)

	*sector 29 (Automotive)*

xi: levpet ln_real_VA if sector==29, free(ln_L) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_29, omega

gen ln_TFP_LP_29 =ln(TFP_LP_29)

	*clearing outliers*

replace TFP_LP_13=. if !inrange(TFP_LP_13,r(p1),r(p99))
replace TFP_LP_29=. if !inrange(TFP_LP_29,r(p1),r(p99))

gen TFP_LP = .
replace TFP_LP=TFP_LP_13 if sector==13
replace TFP_LP=TFP_LP_29 if sector==29
gen ln_TFP_LP=ln(TFP_LP)

twoway (kdensity TFP_OLS if sector==13, lcolor(green)) || (kdensity TFP_OLS if sector==29, lcolor(green) lp(dash)) || (kdensity TFP_WRDG if sector==13, lcolor(sienna)) || (kdensity TFP_WRDG if sector==29, lcolor(sienna) lp(dash)) || (kdensity TFP_LP if sector==13, lcolor(blue)) || (kdensity TFP_LP if sector==29, lcolor(sienna) lp(dash)), title("TFP Density compared") legend(label(1 "Textile") label(2 "Machinery") label(3 "Chemical")) 

twoway (kdensity TFP_LP if sector==13, lcolor(green)) || (kdensity TFP_LP if sector==28, lcolor(sienna)) || (kdensity TFP_LP if sector==24, lcolor(black) lp(dash)), title("TFP Density compared") legend(label(1 "Textile") label(2 "Machinery") label(3 "Chemical")) 

	/* A: answer and comment */

/* (b) Plot the TFP distribution for each country. Are there any differences if you rely on the LP or WRDG procedure? Compare and comment. */

	/* A: answer and comment */
	
/* (c) Focus now on the TFP distributions of industry 13 in France and Spain. Do you find changes in these two TFP distributions in 2006 vs 2015? Did you expect these results? Compare the results obtained with WRDG and LP procedure and comment. */

	/* A: answer and comment */
	
/* (d) Look at changes in skewness in the same time window (again, focus on industry 13 only in these two countries). What happens? Relate this result to what you have found at point c. */

	/* A: answer and comment */
	
/* (e) Do you find the shifts to be homogenous throughout the distribution? Once you have defined a specific parametrical distribution for the TFP, is there a way through which you can statistically measure the changes in the TFP distribution in each industry over time (2006 vs 2015)? */

	/* A: answer and comment */

	
*=============================================================================
/*)))))))))))))))))))) 			PART 2 			((((((((((((((((((((((((((((*/
*=============================================================================

*=============================================================================
**# 							Problem 5
*=============================================================================

ssc install shp2dta, replace
ssc install spmap, replace

/* (a) Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to the equation above. Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting ∆IM P Chinackt with ∆IM P ChinaU SAkt, following the identification strategy by Colantone and Stanig (AJPS, 2018). */

	*—— i. Load pre-sample employment shares (first year only) ———————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Employment_Shares_Take_Home.dta", clear

bysort country nace (year): keep if _n==1         // keep only pre-sample
keep country nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace
save "$output/weights_pre.dta", replace

	*—— ii. China imports delta ——————————————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_China_Take_Home.dta", clear

merge m:1 country nace using "$output/weights_pre.dta"
assert _merge==3
drop _merge

egen panel_id = group(country nace)
xtset panel_id year

gen imp1  = L.real_imports_china      // imports at t−1
gen imp6  = L6.real_imports_china     // imports at t−6
gen deltaC = imp1 - imp6              // 5-year growth
gen scaledC = deltaC / tot_empl_country_nace
gen w_rk    = empl / tot_empl_nuts2
gen w_dC    = w_rk * scaledC

bysort country nuts2 year: egen ChinaShock = total(w_dC)
keep country nuts2 year ChinaShock
save "$output/ChinaShock_by_region_year.dta", replace

	*—— iii. US imports delta (instrument) ————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_US_China_Take_Home.dta", clear

egen nace_id = group(nace)
xtset nace_id year

gen us1    = L.real_USimports_china
gen us6    = L6.real_USimports_china
gen deltaUS = us1 - us6
merge m:1 nace_id using "$output/weights_pre.dta"
assert _merge==3
drop _merge

gen scaledUS = deltaUS / tot_empl_country_nace
gen w_dUS    = w_rk * scaledUS

bysort country nuts2 year: egen USShock = total(w_dUS)
keep country nuts2 year USShock
save "$output/USShock_by_region_year.dta", replace

/* (b) Collapse the dataset by region to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. */

use "ChinaShock_by_region_year.dta", clear
merge 1:1 country nuts2 year using "$output/USShock_by_region_year.dta"
assert _merge==3
drop _merge

* Compute each region's average 5-year shock over all years available
collapse (mean) ChinaShock USShock, by(country nuts2)

save "$output/region_shocks_avg.dta", replace

/* (c) Produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment Shares Take Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. Do you notice any similarities between the two maps? What were your expectations? Comment. LINK TO TUTORIAL ON THE PDF */

*—— Load & merge region-cross-section shocks ——————————————————————————————*
use "region_shocks_avg.dta", clear

*—— Convert & merge NUTS-2 shapefile ————————————————————————————————————*
shp2dta using "NUTS_RG_01M_2013_4326.shp", ///
    database(nuts2db) coordinates(nuts2coord) genid(id)

use nuts2db.dta, clear
rename id nuts2
merge 1:1 nuts2 using "region_shocks_avg.dta"
assert _merge==3
drop _merge

*—— Map average China shock ——————————————————————————————————————*
spmap ChinaShock using nuts2coord.dta, id(nuts2) ///
    fcolor(Blues) ocolor(none) ///
    title("Avg. 5-Year China Shock by NUTS-2 Region")

*—— Compute & map pre-sample manufacturing share ——————————————————————*
use "weights_pre.dta", clear
collapse (sum) mfg_emp=empl, by(country nuts2)
merge m:1 country nuts2 using "weights_pre.dta", ///
    keepusing(tot_empl_nuts2)
gen mfg_share = mfg_emp / tot_empl_nuts2

use nuts2db.dta, clear
rename id nuts2
merge 1:1 nuts2 using ///
    mfg_emp mfg_share using("weights_pre.dta")
assert _merge==3
drop _merge

spmap mfg_share using nuts2coord.dta, id(nuts2) ///
    fcolor(Reds) ocolor(none) ///
    title("Pre-Sample Manufacturing Share by NUTS-2 Region")

*=============================================================================
**# 							Problem 6 									
*=============================================================================

/* Use the dataset "EEI TH P6 2025.dta" to construct an average of TFP and wages during the post-crisis years (2014-2017). Create a lag of 3 years in the control variables (education, GDP and population). Now merge the data you have obtained with data on the China shock (region-specific average). */

/* (a) Regress (simple OLS) the post-crisis average of TFP against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues. */

	/* A: answer and comment */

/* (b) To deal with endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA, and run again the regressions as in a). Do you see any changes in the coefficient? */

	/* A: answer and comment */
	
/* (c) Now, regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock. Lastly, what happens if you regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed. Control for the average TFP during the post- crisis years, an interaction term between average of TFP and China shock and for the 3-year lags of population, education and GDP? Comment. */

	/* A: answer and comment */

*=============================================================================
**# 							Problem 7 									
*=============================================================================

/* (a) Merge the ESS dataset with data on the China shock (region-specific average), based on the region of residence of each respondent. */

	/* A: answer and comment */

/* (b) Regress (simple OLS) the attitude score towards the allocation of public money to subsidize renewable energies on the region-level China shock previously constructed, controlling for gender, age, dummies for levels of education, and dummies for Nuts regions at the 1 digit level. Cluster the standard errors by Nuts region level 2. Be sure to use survey weights in the regression. Comment and discuss possible endogeneity issues.To correct for endogeneity issues, use the instrumental variable you have built before, based on changes in
Chinese imports to the USA. Discuss the rationale for using this instrumental variable. What happens when
you instrument the China shock in the previous regression? Comment both on first-stage and on second-stage
results. */

	/* A: answer and comment */
	
/* (c) To correct for endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA. Discuss the rationale for using this instrumental variable. What happens when you instrument the China shock in the previous regression? Comment both on first-stage and on second-stage results. */

	/* A: answer and comment */
	
/* (d) Comment on the sign of the coefficient on the China shock obtained at point c. Provide intuitive theoretical arguments to rationalize this finding. */

	/* A: answer and comment */
	
/* (e) Starting from the augmented ESS dataset used in the previous regressions, attach to the variable "party voted in last national election" the score for the "very general favorable references to underprivileged minority groups" available in the Manifesto Project for the election of 2013. You can search in the codebook the code for this score in the dataset. Please note that party names do not necessarily match exactly, and that ESS may have more parties than coded by the Manifesto Project. In the end, you should be able to match 9 parties. */

	/* A: answer and comment */
	
/* (f) Regress (both OLS and IV, as above) the underprivileged minority groups score of the party voted against the region-level China shock, controlling for gender, age, dummies for levels of education, and dummies for Nuts regions at the 1 digit level. For this purpose, transform the score as follows:

	minority scorepc = log(.5 + zpc)

	with z being the variable for the "very general favorable references to underprivileged minority groups". Cluster the standard errors by Nuts region level 2. Be sure to use survey weights in the regressions. Comment. */

	/* A: answer and comment */
	
/* (g) What can we learn from the results at point f on the relation between economic and cultural determinants of the globalization backlash? */

	/* A: answer and comment */


