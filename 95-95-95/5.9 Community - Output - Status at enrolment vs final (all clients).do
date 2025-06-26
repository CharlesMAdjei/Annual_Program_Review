*** APR 2020 - Community analysis - 95 95 95
*** Status at enrolment versus most recent post-enrolment test result
* 26 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
numlabel, add force
qui svyset id 

replace status_enrol=. if status_enrol==1
forvalues i=1/7 {
	qui tabout status_enrol status_final if country2==`i' using ///
		"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 1yr sample country `i' ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}
qui tabout status_enrol status_final using ///
	"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 1yr sample ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
numlabel, add force
qui svyset id 

replace status_enrol=. if status_enrol==1
forvalues i=1/5 {
	qui tabout status_enrol status_final if country2==`i' using ///
		"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 2yr sample country `i' ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}
qui tabout status_enrol status_final using ///
	"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 2yr sample ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
/*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear
numlabel, add force
qui svyset id 

replace status_enrol=. if status_enrol==1
forvalues i=1/3 {
	qui tabout status_enrol status_final if country2==`i' using ///
		"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 3yr sample country `i' ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}
qui tabout status_enrol status_final using ///
	"$output/HIV testing/Status enrol vs final/Status enrol vs last test - all - 3yr sample ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
