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

if ("`user'" == "guita") {
    global filepath "C:\Users\guita\OneDrive - Università Commerciale Luigi Bocconi\Documenti\ESS 2° semester\EoEI\EEI Project\20269-eei-report"
	global output "C:\Users\guita\OneDrive - Università Commerciale Luigi Bocconi\Documenti\ESS 2° semester\EoEI\EEI Project\20269-eei-report\output"
	global data "C:\Users\guita\OneDrive - Università Commerciale Luigi Bocconi\Documenti\ESS 2° semester\EoEI\EEI Project\20269-eei-report\data"
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

*ADD ALL "EXPORTS" FOR GRAPHS, ADDITIONAL Tables etc.

preserve
	keep if nuts2 == "FR30" & year == 2007
	
	tabulate sector

	tabstat real_sales real_K real_M real_VA L W, by(sector) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W i.sizeclass, by(sector) /// 
		nformat(%7.2f mean sd) ///
		title(Table1. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2007) ///
		export(output/table1.html, replace) 
		
	graph box real_sales real_K real_M real_VA L W if sizeclass != 5, over(sizeclass) by(sector, cols(1))
	
* Further insights - 2007
	
	gen sector_size = sector*100 + sizeclass
	gen sector_size_13 = sector_size if sector == 13
	
	dtable real_sales real_K real_M real_VA L W ///
       , by(sector_size_13) ///
       nformat(%7.2f mean sd) ///
       title(Table3: Breakdown 13 by sector-sizeclass combinations - 2017) ///
       export(output/table5.html, replace)
		
	tabstat real_sales real_K real_M real_VA L W, by(sector_size_13) statistics(n mean sd min max) format(%9.2f) 
	
	gen sector_size_29 = sector_size if sector == 29
	
	dtable real_sales real_K real_M real_VA L W ///
       , by(sector_size_29) ///
       nformat(%7.2f mean sd) ///
       title(Table6: Breakdown 29 by sector-sizeclass combinations - 2017) ///
       export(output/table6.html, replace)
		
	tabstat real_sales real_K real_M real_VA L W, by(sector_size_29) statistics(n mean sd min max) format(%9.2f)
	
restore

	/* A: answer and comment */
	
/* At a first glance, we can notice that firms in sector 13 (textiles) and firms in sector 29 (motor vehicles, trailers and semi-trailers) in the FR30 region differ sizably in terms of competitive structure, capital and labor intensity, usage of materials, real revenues and real value added generated.
	
	In line with expectations, the motor vehicles' industry proves to be more concentrated than the textile industry; the former requires huge initial investments to start the production process and benefit from economies of scale as well as the ability to sustain larger variable costs over time to stay in business. These considerations may provide theoretical hints at why sector 29 firms are fewer in number compared to firms in sector 13 and why, on average, they are able to generate larger real revenues and value added in absolute terms. A graphical descriptive analysis (see "graph box") supports further our initial account on the differences among the two regional industries under scrutiny, basically by showing that bigger firms are more "productive" compared to smaller ones, the more so the more the structural characteristics of the industries favor firms endowed with greater resources. */
	
/* (b) Compare the descriptive statistics that you have analyzed in point (a) for 2007 to the same figures in 2017. What changes? Comment and give an interpretation.*/

preserve
	keep if nuts2 == "FR30" & year == 2017
	
	tabulate sector

	tabstat real_sales real_K real_M real_VA L W, by(sector) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W i.sizeclass, by(sector) ///
		nformat(%7.2f mean sd) ///
		title(Table2. Descriptive statistics for textiles and automotive in Pas de Calais, France, in 2017) ///
		export(output/table2.html, replace)
		
* Further insights - 2017
	
	gen sector_size = sector*100 + sizeclass
	gen sector_size_13 = sector_size if sector == 13
	
	tabstat real_sales real_K real_M real_VA L W, by(sector_size_13) statistics(n mean sd min max) format(%9.2f) 
	
	dtable real_sales real_K real_M real_VA L W ///
       , by(sector_size_13) ///
       nformat(%7.2f mean sd) ///
       title(Table3: Breakdown 13 by sector-sizeclass combinations - 2017) ///
       export(output/table5.html, replace)
	
	gen sector_size_29 = sector_size if sector == 29
	
	tabstat real_sales real_K real_M real_VA L W, by(sector_size_29) statistics(n mean sd min max) format(%9.2f)
	
	dtable real_sales real_K real_M real_VA L W ///
       , by(sector_size_29) ///
       nformat(%7.2f mean sd) ///
       title(Table6: Breakdown 29 by sector-sizeclass combinations - 2017) ///
       export(output/table6.html, replace)
		
restore

	/* A: answer and comment */

/* By performing a similar analysis for sector 13 (textiles) and sector 29 (motor vehicles) for the Nord - Pas de Calais (FR30) region in 2017 to the one previously run for the same region and industries in 2007, we observe stark differences: 

First and foremost, we easily notice that both industries underwent a substantial process of consolidation (simply put, fewer firms remained active in their respective markets in 2017). This fact is especially true for really small firms (proxied by the # of employees), particularly in the textiles industry, arguably an example of market "cleansing"; however, it is clear that the aforementioned consolidation process did not spare the largest firms, even in this case hitting more heavily the textile industry. 

Moreover, it is worth noticing that both industries underwent a process "cost rationalization" (lower variables costs - labor and materials), adjustments that might be motivated by firms' needs to react to heightened global competition, cost pressures, lower market shares and (maybe) shrinking demand. */
	
	
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
	
* QUESTION (Enri) - Why do not control for year trends here?
	
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

/* Levinsohn & Petrin (LP) */

	*sector 13 (Textiles)*

xi: levpet ln_real_VA if sector==13, free(ln_L) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_13, omega


	*sector 29 (Automotive)*

xi: levpet ln_real_VA if sector==29, free(ln_L) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)

predict TFP_LP_29, omega

*Check for extreme values
sum TFP_LP_13, d
sum TFP_LP_29, d

* COMMENT on extreme values (...)

*clearing outliers*

replace TFP_LP_13=. if !inrange(TFP_LP_13,r(p1),r(p99))
replace TFP_LP_29=. if !inrange(TFP_LP_29,r(p1),r(p99))

* check for extreme values after clearing
sum TFP_LP_13, d
sum TFP_LP_29, d

* plot kdensity of TFP distribution
tw kdensity TFP_LP_13 || kdensity TFP_LP_29

*log transformations of TFP
g ln_TFP_LP_13=ln(TFP_LP_13)
g ln_TFP_LP_29=ln(TFP_LP_29)

* plot kdensity log-transformed TFP distribution
tw kdensity ln_TFP_LP_13 || kdensity ln_TFP_LP_29

gen TFP_LP = .
replace TFP_LP=TFP_LP_13 if sector==13
replace TFP_LP=TFP_LP_29 if sector==29
gen ln_TFP_LP=ln(TFP_LP)


/* Wooldridge (WRDG) 

 QUESTION (Enri) - Can it be that here country and year dummies are missing and therefore graphs are wrong? */

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

*Check for extreme values
sum TFP_WRDG_13, d
sum TFP_WRDG_29, d

* COMMENT on extreme values (...)

*clearing outliers*

replace TFP_WRDG_13=. if !inrange(TFP_WRDG_13,r(p1),r(p99))
replace TFP_WRDG_29=. if !inrange(TFP_WRDG_29,r(p1),r(p99))

replace ln_TFP_WRDG_13=. if !inrange(ln_TFP_WRDG_13,r(p1),r(p99))
replace ln_TFP_WRDG_29=. if !inrange(ln_TFP_WRDG_29,r(p1),r(p99))

* check for extreme values after clearing
sum TFP_WRDG_13, d
sum TFP_WRDG_29, d

* plot kdensity of TFP distribution
tw kdensity TFP_WRDG_13 || kdensity TFP_WRDG_29

* plot kdensity log-transformed TFP distribution
tw kdensity ln_TFP_WRDG_13 || kdensity ln_TFP_WRDG_29

gen TFP_WRDG = .
replace TFP_WRDG=TFP_WRDG_13 if sector==13
replace TFP_WRDG=TFP_WRDG_29 if sector==29
gen ln_TFP_WRDG=ln(TFP_WRDG)


* Compare with WRDG

tw (kdensity ln_TFP_LP_13, lcolor(blue)) || (kdensity ln_TFP_LP_29, lcolor(red)) || (kdensity ln_TFP_WRDG_13, lcolor(blue) lp(dash)) || (kdensity ln_TFP_WRDG_29, lcolor(red) lp(dash)), title("TFP Density compared") legend(label(1 "13 LP") label(2 "29 LP") label(3 "13 WRDG") label(4 "29 WRDG"))


* COMMENT on what you notice and difference between LP and WRDG methods (...)


/* (b) Plot the TFP distribution for each country. Are there any differences if you rely on the LP or WRDG procedure? Compare and comment. */

** LP

drop TFP_LP_*
drop ln_TFP_LP_*

foreach c in "France" "Spain" "Italy" {
	xi: levpet ln_real_VA if country ==c, free(ln_L i.sector i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)
	predict TFP_LP_`c', omega
}  

foreach c in "France" "Spain" "Italy" {
	sum TFP_LP_`c' if country==c, d
	replace TFP_LP_`c'=. if !inrange(TFP_LP_`c', r(p1),r(p99)) & country==c
}

gen TFP_LP = .
replace TFP_LP=TFP_LP_France if country=="France"
replace TFP_LP=TFP_LP_Spain if country=="Spain"
replace TFP_LP=TFP_LP_Italy if country=="Italy"
gen ln_TFP_LP=ln(TFP_LP)

* LP comparison

tw (kdensity TFP_LP if country=="France", lcolor(green)) || (kdensity TFP_LP if country=="Spain", lcolor(sienna)) || (kdensity TFP_LP if country=="Italy", lcolor(black) lp(dash)), title("TFP (LP) Density: textile cross-country comparison") legend(label(1 "France") label(2 "Spain") label(3 "Italy")) 

** WRDG

drop ln_TFP_WRDG_*

foreach c in "France" "Spain" "Italy" {
	xi: prodest ln_real_VA if country==c, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
	predict ln_TFP_WRDG_`c', resid
}  

foreach c in "France" "Spain" "Italy" {
	sum ln_TFP_WRDG_`c' if country==c, d
	replace ln_TFP_WRDG_`c'=. if !inrange(ln_TFP_WRDG_`c', r(p1),r(p99)) & country==c
}

gen ln_TFP_WRDG = .
replace ln_TFP_WRDG=ln_TFP_WRDG_France if country=="France"
replace ln_TFP_WRDG=ln_TFP_WRDG_Spain if country=="Spain"
replace ln_TFP_WRDG=ln_TFP_WRDG_Italy if country=="Italy"


* WRDG comparison

twoway (kdensity ln_TFP_WRDG if country=="France", lcolor(green)) || (kdensity ln_TFP_WRDG if country=="Spain", lcolor(sienna)) || (kdensity ln_TFP_WRDG if country=="Italy", lcolor(black) lp(dash)), title("TFP (WRDG) Density: textile cross-country comparison") legend(label(1 "France") label(2 "Spain") label(3 "Italy")) 

* Final  comparison of LP and WRDG

tw (kdensity ln_TFP_LP if country=="France", lcolor(green)) || (kdensity ln_TFP_LP if country=="Spain", lcolor(sienna)) || (kdensity ln_TFP_LP if country=="Italy", lcolor(black)) || (kdensity ln_TFP_WRDG if country=="France", lcolor(green) lp(dash)) || (kdensity ln_TFP_WRDG if country=="Spain", lcolor(sienna) lp(dash)) || (kdensity ln_TFP_WRDG if country=="Italy", lcolor(black) lp(dash)), title("TFP (LP vs WRDG) Density: textile cross-country comparison") legend(label(1 "France LP") label(2 "Spain LP") label(3 "Italy LP") label(4 "France WRDG") label(5 "Spain WRDG") label(6 "Italy WRDG")) 

	/* A: answer and comment */
	
/* (c) Focus now on the TFP distributions of industry 13 in France and Spain. Do you find changes in these two TFP distributions in 2006 vs 2015? Did you expect these results? Compare the results obtained with WRDG and LP procedure and comment. */

* LP

preserve 

keep if sector == 13 & (year == 2006 | year == 2015) & (country == "France" | country == "Spain")

tw (kdensity ln_TFP_LP if country=="France" & year == 2006, lcolor(blue)) || (kdensity ln_TFP_LP if country=="Spain" & year==2006, lcolor(red)) || (kdensity ln_TFP_LP if country=="France" & year == 2015, lcolor(green)) || (kdensity ln_TFP_LP if country=="Spain" & year == 2015, lcolor(sienna)) || (kdensity ln_TFP_WRDG if country=="France" & year == 2006, lcolor(blue) lp(dash)) || (kdensity ln_TFP_WRDG if country=="Spain" & year==2006, lcolor(red) lp(dash)) || (kdensity ln_TFP_WRDG if country=="France" & year == 2015, lcolor(green) lp(dash)) || (kdensity ln_TFP_WRDG if country=="Spain" & year == 2015, lcolor(sienna) lp(dash)), title("TFP (LP vs WRDG) Density: textile comparisons") legend(label(1 "France LP '06") label(2 "Spain LP '06") label(3 "France LP '15") label(4 "Spain LP '15") label(5 "France WRDG '06") label(6 "Spain WRDG '06") label(7 "France WRDG '15") label(8 "Spain WRDG '15")) 

twoway (kdensity TFP_LP if country=="France" & year == 2006, lcolor(green)) || (kdensity TFP_LP if country=="Spain" & year == 2006, lcolor(sienna)) ||, (kdensity TFP_LP if country=="France" & year == 2015, lcolor(blue)) || (kdensity TFP_LP if country=="France" & year == 2015, lcolor(red)) || title("TFP Density compared") legend(label(1 "France") label(2 "Spain")) 

* Question - Do we simplify the graph like this for interpretation (perhaps doing both) ?

restore

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

ssc install spmap, replace
ssc install shp2dta, replace
ssc install mif2dta, replace

/* (a) Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to the equation above. Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting ∆IM P Chinackt with ∆IM P ChinaU SAkt, following the identification strategy by Colantone and Stanig (AJPS, 2018). */

	*—— i. Load pre-sample employment shares (first year only) ———————————————*
use "/Users/stefanograziosi/Documents/GitHub/20269-eei-report/data/Employment_Shares_Take_Home.dta", clear //SOSTITUISCI CON "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Employment_Shares_Take_Home.dta"

sort year country nace

gen ratio_left = empl / tot_empl_nuts2
save "$output/weights.dta", replace

	*—— ii. China imports delta ——————————————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_China_Take_Home.dta", clear

sort year country nace

merge 1:m year country nace using "$output/weights.dta"

egen panel_id = group(country nace nuts2)
xtset panel_id year

gen imp1  				= L.real_imports_china      							// imports at t−1
gen imp6  				= L6.real_imports_china     							// imports at t−6
gen delta_IMP_china 	= imp1 - imp6              								// 5-year growth
gen ratio_right 		= delta_IMP_china / tot_empl_country_nace
gen china_shock 		= ratio_left * ratio_right

drop if missing(china_shock)													// Need to understand why it removes so many obs | A: date issue

bysort country nuts2 year: egen sum_china_shock = total(china_shock)

save "$output/ChinaShock_by_region_year.dta", replace

	*—— iii. US imports delta (instrument) ————————————————————————————————————*
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b0e60e03a483219f9f6ab9ad83ef936eba49ec6a/data/Imports_US_China_Take_Home.dta", clear

gen country = "USA"
gen real_imports_china = .

sort year country nace
replace real_imports_china = real_USimports_china if country == "USA" & missing(real_imports_china)

merge 1:m year nace using "$output/weights.dta"

drop if year < 1989
drop if year >= 2007

egen panel_id_us = group (nace nuts2)
xtset panel_id_us year

gen imp1_us    			= L.real_USimports_china
gen imp6_us    			= L6.real_USimports_china
gen delta_IMP_china_us	= imp1_us - imp6_us
gen ratio_right_us		= delta_IMP_china_us / tot_empl_country_nace
gen china_shock_us		= ratio_left * ratio_right_us

drop if missing(china_shock_us)

bysort nuts2 year: egen sum_china_shock_us = total(china_shock_us)

save "$output/ChinaShock_by_region_year_us.dta", replace

/* (b) Collapse the dataset by region to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. */

	*—— Collapse observation dataset ——————————————————————————————*

use "$output/ChinaShock_by_region_year.dta", clear
collapse (mean) china_shock, by(country nuts2 year)
save "$output/ChinaShock_by_region_year_collapsed.dta", replace

use "$output/ChinaShock_by_region_year_collapsed.dta"
collapse (mean) china_shock, by (nuts2)
save "$output/ChinaShock_by_region_year_collapsed_MAPS.dta", replace
 
	*—— Collapse instrument dataset ——————————————————————————————*

use "$output/ChinaShock_by_region_year_us.dta", clear
collapse (mean) china_shock, by(country nuts2 year)
save "$output/ChinaShock_by_region_year_collapsed_us.dta", replace

use "$output/ChinaShock_by_region_year_collapsed_us.dta"
collapse (mean) china_shock, by (nuts2)
save "$output/ChinaShock_by_region_year_collapsed_us_MAPS.dta", replace

	*—— Merge the two dataset ——————————————————————————————*

use "$output/ChinaShock_by_region_year_collapsed.dta", clear

drop if year < 1989
drop if year >= 2007

merge 1:1 country nuts2 year using "$output/ChinaShock_by_region_year_collapsed_us.dta"
	
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

use "$filepath\EEI_TH_P6_2025.dta", clear

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

merge m:1 nuts2 using "\$output\region_shocks_avg"
drop _merge
*NB: 96 not merged (nuts: ES63, ES64, FRA1-FRA4)

/* (a) Regress (simple OLS) the post-crisis average of TFP against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues. */

* run OLS regression for average TFP
reg avg_tfp china_shock edu_lag3-pop_lag3

	/* A: answer and comment */

/* (b) To deal with endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA, and run again the regressions as in a). Do you see any changes in the coefficient? */

* run IV regression for average TFP
ivregress 2sls avg_tfp (china_shock = china_shock_us) edu_lag3-pop_lag3

	/* A: answer and comment */
	
/* (c) Now, regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock. Lastly, what happens if you regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed. Control for the average TFP during the post- crisis years, an interaction term between average of TFP and China shock and for the 3-year lags of population, education and GDP? Comment. */

* run OLS and IV regressions for wage
reg avg_wage china_shock edu_lag3-pop_lag3
ivregress 2sls avg_wage (china_shock = china_shock_us) edu_lag3-pop_lag3

* generate the interaction term
gen inter_term = avg_tfp*china_shock

* run OLS and IV regressions for wage with additional control and interaction
reg avg_wage china_shock avg_tfp inter_term edu_lag3-pop_lag3
ivregress 2sls avg_wage (china_shock = china_shock_us) avg_tfp inter_term edu_lag3-pop_lag3

*=============================================================================
**# 							Problem 7 									
*=============================================================================

https://github.com/stfgrz/20269-eei-report/blob/ddb4ad97f3974b2ba537498cbeea090d2b6ed3d1/data/ESS8e02_3.dta

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


