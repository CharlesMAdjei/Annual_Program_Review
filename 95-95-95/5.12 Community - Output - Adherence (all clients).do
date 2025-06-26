*** APR 2020 - Community analysis - 95 95 95
*** Adherence
* 27 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
keep if status_final==1
qui svyset id 


*------------------------------------------------------------------------------*
* Adherence rates

tab country adh_average_cat, m
forvalues i=1/4 {
	tabout client1 adh_average_cat if country2==`i' ///
		using "$output/Adherence/Adherence average - All - 1 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 adh_average_cat  ///
	using "$output/Adherence/Adherence average - All - 1 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Frequency of adherence measures

/*
* --> Option 1: % clients who had an adherence measure taken at every visit
tabout client1 adh_all_visits  ///
	using "$output/Adherence/Perc clients with adh measure at all visits - All - 1 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/4 {
	tabout client1 adh_all_visits if country2==`i' ///
		using "$output/Adherence/Perc clients with adh measure at all visits - All - 1 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
*/

* --> Option 2: % of visits at which client had adherence done in categories
tabout client1 perc_visits_adh_cat  ///
	using "$output/Adherence/Perc visits with adh measure - All - 1 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/4 {
	tabout client1 perc_visits_adh_cat if country2==`i' ///
		using "$output/Adherence/Perc visits with adh measure - All - 1 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	


	
	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
keep if status_final==1
qui svyset id 


*------------------------------------------------------------------------------*
* Adherence rates

tab country adh_average_cat, m
forvalues i=1/3 {
	tabout client1 adh_average_cat if country2==`i' ///
		using "$output/Adherence/Adherence average - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 adh_average_cat  ///
	using "$output/Adherence/Adherence average - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	
	
/*
Not using it currently but left in in case it's asked for.
* --> Average 7 day recall over all visits
tabout client1 adh_7dayrecall_average_cat ///
	using "$output/Adherence/Adherence 7 day recall - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
*/	




*------------------------------------------------------------------------------*
* Frequency of adherence measures

tab client1 adh_average_cat, m  
tab client1 ever_has_adh, m
tab client1 adh_all_visits, m
tab client1 perc_visits_adh_cat, m

/*
* --> Option 1: % clients who had an adherence measure taken at every visit
tabout client1 adh_all_visits  ///
	using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 adh_all_visits if country2==`i' ///
		using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
*/


* --> Option 2: % of visits at which client had adherence done in categories
tabout client1 perc_visits_adh_cat  ///
	using "$output/Adherence/Perc visits with adh measure - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 perc_visits_adh_cat if country2==`i' ///
		using "$output/Adherence/Perc visits with adh measure - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	




/*	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear
keep if status_final==1
qui svyset id 


*------------------------------------------------------------------------------*
* Adherence rates

tab country adh_average_cat, m
forvalues i=1/3 {
	tabout client1 adh_average_cat if country2==`i' ///
		using "$output/Adherence/Adherence average - All - 3 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 adh_average_cat  ///
	using "$output/Adherence/Adherence average - All - 3 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	
	
/*
Not using it currently but left in in case it's asked for.
* --> Average 7 day recall over all visits
tabout client1 adh_7dayrecall_average_cat ///
	using "$output/Adherence/Adherence 7 day recall - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
*/	




*------------------------------------------------------------------------------*
* Frequency of adherence measures

tab client1 adh_average_cat, m  
tab client1 ever_has_adh, m
tab client1 adh_all_visits, m
tab client1 perc_visits_adh_cat, m

/*
* --> Option 1: % clients who had an adherence measure taken at every visit
tabout client1 adh_all_visits  ///
	using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 adh_all_visits if country2==`i' ///
		using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
*/


* --> Option 2: % of visits at which client had adherence done in categories
tabout client1 perc_visits_adh_cat  ///
	using "$output/Adherence/Perc visits with adh measure - All - 3 year sample ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 perc_visits_adh_cat if country2==`i' ///
		using "$output/Adherence/Perc visits with adh measure - All - 3 year sample country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
