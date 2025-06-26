*** APR 2020 - Community analysis - 95 95 95
*** VL testing among those with 2+ visits
* 26 May 2021


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
* VL test ever done
/*
Ever tested is simply the presence of a result since there is no date to 
check whether they were tested while in our care or not. There is a  "done" 
variable but it doesn't seem very useful since it is filled out far less often 
than the result variable.
*/

forvalues i=1/7 {
	tabout client1 vl_test_ever if country2==`i' ///
			using "$output/VL testing/VL test ever done - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 vl_test_ever ///
	using "$output/VL testing/VL test ever done - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	
	
	
	
*------------------------------------------------------------------------------*
* Virally suppressed at most recent test

forvalues i=1/7 {
	tabout client1 vl_supp_last if country2==`i' ///
		using "$output/VL testing/VL most recent supp - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
}
tabout client1 vl_supp_last ///
	using "$output/VL testing/VL most recent supp - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
	
	
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
* VL test ever done
/*
Ever tested is simply the presence of a result since there is no date to 
check whether they were tested while in our care or not. There is a  "done" 
variable but it doesn't seem very useful since it is filled out far less often 
than the result variable.
*/

forvalues i=1/5 {
	tabout client1 vl_test_ever if country2==`i' ///
			using "$output/VL testing/VL test ever done - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}	
tabout client1 vl_test_ever ///
	using "$output/VL testing/VL test ever done - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

/*
* Old code
tabout client1 vl_test_ever ///
	using "$output/VL testing/VL test ever done - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	// With frequencies
	
tabout client1 vl_test_ever ///
	using "$output/VL testing/VL test ever done - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	// Without frequencies
*/	
	
	
	
	
*------------------------------------------------------------------------------*
* Virally suppressed at most recent test

forvalues i=1/5 {
	tabout client1 vl_supp_last if country2==`i' ///
		using "$output/VL testing/VL most recent supp - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
}
tabout client1 vl_supp_last ///
	using "$output/VL testing/VL most recent supp - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

