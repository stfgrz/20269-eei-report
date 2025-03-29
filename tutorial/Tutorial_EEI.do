clear all

*FIRST PART OF THE FILE */* IS DATA PREPARATION FROM ORIGINAL BALANCE SHEET DATA

/*

use Productivity_TH1_2017_master, clear

set more off, perm

keep if country=="ITA" | country=="GER" | country=="FRA"

rename d4 exp_intensity
rename operatingrevenueturnovertheu TO
rename totalassetstheur K
rename materialcoststheur M
rename employees L
rename costsofemployeestheur W
rename salestheur sales
rename Exporter exporter
rename sec sector



*** cleaning negative values

foreach var in K M L W sales TO {
        drop if  `var'<=0
        }

*** deflated variables

gen VA=sales-M
gen real_K=(K/gdp_defl)*100
gen real_M=(M/ppi)*100
gen real_sales=(sales/ppi)*100
gen real_VA=(VA/ppi)*100

keep year country sector mark K real_K M real_M L W sales real_sales real_VA VA exporter FDI  exp_intensity


*save STATA_Tutorial_EEI.dta, replace

*NOTE: THIS IS THE FILE SHARED ON BLACKBOARD

*/

log using tutorial_EEI

use STATA_Tutorial_EEI.dta, replace

*create logarithms 

*gen ln_real_sales=ln(real_sales)
*gen ln_real_M=ln(real_M)
*gen ln_real_K=ln(real_K)
*gen ln_L=ln(L)
*gen ln_real_VA=ln(real_VA)

*OR

foreach var in real_sales real_M real_K L real_VA {
        gen ln_`var'=ln(`var')
        }

	
***OLS REGRESSION - VALUE ADDED | ONE INDUSTRY - ONE COUNTRY

*sector 24 (Chemicals)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==24 & country=="ITA" 
predict ln_TFP_OLS_24, residuals 

gen TFP_OLS_24= exp(ln_TFP_OLS_24)

kdensity TFP_OLS_24

sum TFP_OLS_24, d
replace TFP_OLS_24=. if !inrange(TFP_OLS_24,r(p1),r(p99))

sum TFP_OLS_24, d
kdensity TFP_OLS_24

g ln_TFP_OLS_24_clean=ln(TFP_OLS_24)
kdensity ln_TFP_OLS_24


*** LEVINSOHN-PETRIN - VALUE ADDED | ONE INDUSTRY - ONE COUNTRY

***INSTALL PACKAGE FIRST! (search levpet => install package st0060)


xi: levpet ln_real_VA if sector==24 & country=="ITA", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_24, omega

sum TFP_LP_24, d
replace TFP_LP_24=. if !inrange(TFP_LP_24, r(p1),r(p99))

sum TFP_LP_24, d
kdensity TFP_LP_24

g ln_TFP_LP_24=ln(TFP_LP_24)
kdensity ln_TFP_LP_24

*** PRODEST - VALUE ADDED | ONE INDUSTRY - ONE COUNTRY

***INSTALL PACKAGE FIRST! (search prodest => install package prodest)


xi: prodest ln_real_VA if sector==24 & country=="ITA", met(lp) free(ln_L i.year) proxy(ln_real_M) state(ln_real_K) va acf

predict ln_TFP_LP_ACF_24, resid

xi: prodest ln_real_VA if sector==24 & country=="ITA", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va

predict ln_TFP_WRDG_24, resid

tw kdensity ln_TFP_LP_24 || kdensity ln_TFP_LP_ACF_24 || kdensity ln_TFP_WRDG_24


************CALCULATE & COMPARE PRODUCTIVITY ACROSS DIFFERENT INDUSTRIES & COUNTRIES

drop TFP_LP_*
drop ln_TFP_LP_*

*LP

foreach s in 17 28 24 {
xi: levpet ln_real_VA if sector==`s', free(ln_L i.country i.year) proxy(ln_real_M) capital(ln_real_K) reps(20) level(99)
predict TFP_LP_`s', omega
}   /* no need to use M because the estimate is in VA */


*OUTLIERS

foreach s in 17 28 24 {
sum TFP_LP_`s' if sector==`s', d
replace TFP_LP_`s'=. if !inrange(TFP_LP_`s', r(p1),r(p99)) & sector==`s'
}

*COMBINE IND-Specific Prod Estimates in One Variable

gen TFP_LP = .
replace TFP_LP=TFP_LP_17 if sector==17
replace TFP_LP=TFP_LP_24 if sector==24
replace TFP_LP=TFP_LP_28 if sector==28
gen ln_TFP_LP=ln(TFP_LP)

*plotting TFP distribution (LevPet), comparing industries kdensity

twoway (kdensity TFP_LP if sector==17, lcolor(green)) || (kdensity TFP_LP if sector==28, lcolor(sienna)) || (kdensity TFP_LP if sector==24, lcolor(black) lp(dash)), title("TFP Density compared") legend(label(1 "Textile") label(2 "Machinery") label(3 "Chemical")) 

*Plotting TFP distribution (LevPet), comparing industries boxplot

graph box TFP_LP, over(sector, gap(*0.1))  title("Box plot by sector") subtitle("After cleaning data", tstyle(smbody)) ///
ytitle("Total Factor Productivity (Lev-Pet)", tstyle(smbody))

graph box ln_TFP_LP, over(sector, gap(*0.1))  title("Box plot by sector") subtitle("After cleaning data", tstyle(smbody)) ///
ytitle("(Log)Total Factor Productivity (Lev-Pet)", tstyle(smbody))

*******EVALUATE EXPORT & FDI PREMIA

twoway (kdensity ln_TFP_LP if exporter==1 & FDI==1, lw(medthick) lcolor(green)) ///
|| (kdensity ln_TFP_LP if exporter==1 & FDI==0,lw(medthin) lcolor(sienna)) ///
|| (kdensity ln_TFP_LP if exporter==0 & FDI==0, lw(medthin) lcolor(blue) lp(dash)), ///
title("Productivity distributions by export status") legend(label(1 "exporters & FDI ") label(2 "exporters only ") label(3 "domestic only "))

g export_status=.
replace export_status=0 if exporter==0 & FDI==0
replace export_status=1 if exporter==1 & FDI==0
replace export_status=2 if exporter==1 & FDI==1  

xi: reg ln_TFP_LP exporter i.year i.sector

xi: reg ln_TFP_LP exporter i.year i.sector  if export_status==0 | export_status==1, robust

xi: reg ln_TFP_LP exporter i.year i.sector  if export_status==0 | export_status==2, robust



*Now I produce a nice table in Excel

***INSTALL PACKAGE FIRST! (search outreg2 => install package outreg2)

xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust
outreg2 using Exporter.xls, append title("Export premium") ctitle("export") addtext(year FE, YES, sector FE, YES) 

*Now I produce an even nicer table in Excel...
xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust
outreg2 using Exporter.xls, replace title("Export premium") ctitle("export") addtext(year FE, YES, sector FE, YES) drop (_Isector_* _Iyear*)



**********ESTIMATE PARETO SHAPE OF THE PRODUCTIVITY DISTRIBUTION

sort sector year
by sector year: cumul TFP_LP, generate(cum_TFP_LP)
gen rhs_LP=log(1- cum_TFP_LP)

*regress rhs on ln_TFP in order to retrieve the coefficient of ln(tfp), i.e. the "K" of the Pareto
*** first we pool all the years together and evaluate the general shape of the distribution
*then we compare the k-value for initial and final year to check the evolution of the distribution

foreach s in 17 28{
qui reg rhs_LP ln_TFP_LP if sector==`s'
outreg2 using Pareto.xls, append title("Pareto Distribution") ctitle("Sector `s'")
qui reg rhs_LP ln_TFP_LP if sector==`s' & year==2001
outreg2 using Pareto.xls, append title("Pareto Distribution") ctitle("Sector `s' - 2001")
qui reg rhs_LP ln_TFP_LP if sector==`s' & year==2008
outreg2 using Pareto.xls, append title("Pareto Distribution") ctitle("Sector `s' - 2008")
}





log close

*********MARKUP ESTIMATION

*****Non-Parametric Markup

gen PCM=(sales-W-M)/sales
sum PCM,de
replace PCM=. if !inrange(PCM,r(p1),r(p99))
kdensity PCM
