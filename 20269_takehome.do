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
ssc install randomizr, replace
ssc install ritest, replace
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

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/abc3c6d67f27161b9899cedb19c8ff1016402746/ps1/jtrain2.dta", clear
use "https://raw.githubusercontent.com/stfgrz/20269-eei-report/b7808de62ba85f86396e28f7cbf865ac9771cafe/data/EEI_TH_2025.dta", clear

*=============================================================================
/* 								Problem 1 									*/
*=============================================================================

/* (a) Focus only on French firms. Starting from balance-sheet data, provide some descriptive statistics (e.g. n. of firms, average capital, revenues, number of employees, value added) in 2007 comparing firms in sector 13 (textiles) and firms in sector 29 (motor vehicles, trailers and semi-trailers) for the region Nord - Pas de Calais. Please use the NUTS level 2 - 2013 definition. Comment briefly. */



	/* A: answer and comment */
	
/* (b) Compare the descriptive statistics that you have analyzed in point a. for 2007 to the same figures in 2017. What changes? Comment and give an interpretation.*/

*=============================================================================
/* 								Problem 2 									*/
*=============================================================================

/* (a) Consider now all the three countries. Estimate for the two industries available in NACE Rev. 2 2-digit format the production function coefficients, by using standard OLS, the Wooldridge (WRDG) and the Levinsohn & Petrin (LP) procedure. How do you treat the fact that data come from different countries in different years in the productivity estimation? */

	/* A: answer and comment */

/* (b) Present a Table (SEE THE ONE IN THE PDF), where you compare the coefficients obtained in the estimation outputs, indicating their significance levels (*, ** or *** for 10, 5 and 1 per cent). Is there any bias of the labour coefficients? What is the reason for that? */

	/* A: answer and comment */

*=============================================================================
/* 								Problem 3 									*/
*=============================================================================

/* (a) Would there be any difference in estimating the production function using revenues rather than added values in LP, WRDG or OLS? Why is it so? Discuss the issue theoretically, considering the assumptions behind the Cobb-Douglas production function. */

	/* A: answer and comment */

*=============================================================================
/* 								Problem 4 									*/
*=============================================================================

/* (a) Comment on the presence of "extreme" values in both industries. Clear the TFP estimates from these extreme values (1st and 99th percentiles) and save a "cleaned sample". From now on, focus on this sample. Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry. What do you notice? Are there any differences if you rely on the LP or WRDG procedure? Comment. */

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
/* 								Problem 5 									*/
*=============================================================================

/* (a) Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to the equation above. Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting ∆IM P Chinackt with ∆IM P ChinaU SAkt, following the identification strategy by Colantone and Stanig (AJPS, 2018). */

	/* A: answer and comment */

/* (b) Collapse the dataset by region to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. */

	/* A: answer and comment */

/* (c) Produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment Shares Take Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. Do you notice any similarities between the two maps? What were your expectations? Comment. LINK TO TUTORIAL ON THE PDF */

	/* A: answer and comment */

*=============================================================================
/* 								Problem 6 									*/
*=============================================================================

/* Use the dataset "EEI TH P6 2025.dta" to construct an average of TFP and wages during the post-crisis years (2014-2017). Create a lag of 3 years in the control variables (education, GDP and population). Now merge the data you have obtained with data on the China shock (region-specific average). */

/* (a) Regress (simple OLS) the post-crisis average of TFP against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues. */

	/* A: answer and comment */

/* (b) To deal with endogeneity issues, use the instrumental variable you have built before, based on changes in Chinese imports to the USA, and run again the regressions as in a). Do you see any changes in the coefficient? */

	/* A: answer and comment */
	
/* (c) Now, regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed, controlling for the 3-year lags of population, education and GDP. Comment on the estimated coefficient on the China shock. Lastly, what happens if you regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed. Control for the average TFP during the post- crisis years, an interaction term between average of TFP and China shock and for the 3-year lags of population, education and GDP? Comment. */

	/* A: answer and comment */

*=============================================================================
/* 								Problem 7 									*/
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


