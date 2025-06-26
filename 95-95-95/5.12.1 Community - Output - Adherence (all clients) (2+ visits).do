*** APR 2020 - Community analysis - 95 95 95
*** Adherence among those with 2+ visits
* 28 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
keep if status_final==1
drop if numvisits_total<2
qui svyset id 


*------------------------------------------------------------------------------*
* Adherence rates

tab country adh_average_cat, m
forvalues i=1/4 {
	tabout client1 adh_average_cat if country2==`i' ///
		using "$output/Adherence/Adherence average - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 adh_average_cat  ///
	using "$output/Adherence/Adherence average - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Frequency of adherence measures

/*
* --> Option 1: % clients who had an adherence measure taken at every visit
tabout client1 adh_all_visits  ///
	using "$output/Adherence/Perc clients with adh measure at all visits - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/4 {
	tabout client1 adh_all_visits if country2==`i' ///
		using "$output/Adherence/Perc clients with adh measure at all visits - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
*/

* --> Option 2: % of visits at which client had adherence done in categories
tabout client1 perc_visits_adh_cat  ///
	using "$output/Adherence/Perc visits with adh measure - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/4 {
	tabout client1 perc_visits_adh_cat if country2==`i' ///
		using "$output/Adherence/Perc visits with adh measure - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
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
drop if numvisits_total<2
qui svyset id 


*------------------------------------------------------------------------------*
* Adherence rates

tab country adh_average_cat, m
forvalues i=1/3 {
	tabout client1 adh_average_cat if country2==`i' ///
		using "$output/Adherence/Adherence average - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 adh_average_cat  ///
	using "$output/Adherence/Adherence average - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	

	
	
*------------------------------------------------------------------------------*
* Frequency of adherence measures

/*
* --> Option 1: % clients who had an adherence measure taken at every visit
tabout client1 adh_all_visits  ///
	using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 adh_all_visits if country2==`i' ///
		using "$output/Adherence/Perc clients with adh measure at all visits - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
*/

* --> Option 2: % of visits at which client had adherence done in categories
tabout client1 perc_visits_adh_cat  ///
	using "$output/Adherence/Perc visits with adh measure - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
forvalues i=1/3 {
	tabout client1 perc_visits_adh_cat if country2==`i' ///
		using "$output/Adherence/Perc visits with adh measure - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	

