*** APR 2020 - Community analysis - 95 95 95
*** Sample stats
* 26 May 2021

/*
This do file produces the following stats:
- Sample sizes
- Age and sex breakdown
- Year of enrolment
- Status at enrolment
*/


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear

* --> Sample size by client type
tabout country client1  ///
	using "$output/Sample stats/Sample size - All - 1 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
tabout country client2  ///
	using "$output/Sample stats/Sample size - All (sep by status) - 1 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	

* --> Age breakdown by country
tabout age_enrol_cat country ///
	using "$output/Sample stats/Age breakdown by country - 1 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
/*
tabout age_enrol_cat country if client1==4 ///
	using "$output/Sample stats/Age breakdown by country - 1 year sample partners ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
*/


* --> Age breakdown by sex 
tabout age_enrol_cat sex ///
	using "$output/Sample stats/Age breakdown by sex - 1 year sample ($S_DATE).xls", ///
	c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Age breakdown by sex by country
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout age_enrol_cat sex if country2==`i' ///
	using "$output/Sample stats/Age breakdown by sex - 1 year sample - Country `i' ($S_DATE).xls", ///
		c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}


* --> Status at enrolment
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout status_enrol client1 if country2==`i' ///
	using "$output/Sample stats/Status at enrolment - 1 year sample - Country `i' ($S_DATE).xls", ///
		c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout status_enrol client1 ///
using "$output/Sample stats/Status at enrolment - 1 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Sample size for children, adolescents and partners when we restrict to
*	  those who could be matched to their index client
use "$temp/all clients - full dataset - 1yr sample.dta", clear
drop if hhmem_caseid==""
	// Keep only children, adolescents and partners
	
merge 1:1 hhmem_caseid using "$temp/childadol matched to index - 1yr sample.dta"
drop if _merge==2
	// There are some in the using data - child/adol matched to index - that
	// don't appear in the master data - the full dataset - because in the full
	// dataset we dropped individuals in the child/adol dataset who didn't have
	// an age as that meant we couldn't assign them to child or adol.

drop _merge
merge 1:1 hhmem_caseid using "$temp/partner matched to index - 1yr sample.dta"
drop if _merge==2	
drop _merge

keep if matched_child_index==1 | matched_partner_index==1
	// Only keep those who were matched to their index client

tabout country client1  ///
	using "$output/Sample stats/Sample size - HH mems matched to index - 1 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear

* --> Sample size by client type
tabout country client1  ///
	using "$output/Sample stats/Sample size - All - 2 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
tabout country client2  ///
	using "$output/Sample stats/Sample size - All (sep by status) - 2 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	

* --> Age breakdown by country
tabout age_enrol_cat country ///
	using "$output/Sample stats/Age breakdown by country - 2 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
/*
tabout age_enrol_cat country if client1==4 ///
	using "$output/Sample stats/Age breakdown by country - 2 year sample partners ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
*/


* --> Age breakdown by sex 
tabout age_enrol_cat sex ///
	using "$output/Sample stats/Age breakdown by sex - 2 year sample ($S_DATE).xls", ///
	c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Age breakdown by sex by country
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout age_enrol_cat sex if country2==`i' ///
	using "$output/Sample stats/Age breakdown by sex - 2 year sample - Country `i' ($S_DATE).xls", ///
		c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}


* --> Status at enrolment
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout status_enrol client1 if country2==`i' ///
	using "$output/Sample stats/Status at enrolment - 2 year sample - Country `i' ($S_DATE).xls", ///
		c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout status_enrol client1 ///
using "$output/Sample stats/Status at enrolment - 2 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Sample size for children, adolescents and partners when we restrict to
*	  those who could be matched to their index client
use "$temp/all clients - full dataset - 2yr sample.dta", clear
drop if hhmem_caseid==""
	// Keep only children, adolescents and partners
	
merge 1:1 hhmem_caseid using "$temp/childadol matched to index - 2yr sample.dta"
drop if _merge==2
	// There are some in the using data - child/adol matched to index - that
	// don't appear in the master data - the full dataset - because in the full
	// dataset we dropped individuals in the child/adol dataset who didn't have
	// an age as that meant we couldn't assign them to child or adol.

drop _merge
merge 1:1 hhmem_caseid using "$temp/partner matched to index - 2yr sample.dta"
drop if _merge==2	
drop _merge

keep if matched_child_index==1 | matched_partner_index==1
	// Only keep those who were matched to their index client

tabout country client1  ///
	using "$output/Sample stats/Sample size - HH mems matched to index - 2 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
	

	
/*
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear

* --> Sample size by client type
tabout country client1  ///
	using "$output/Sample stats/Sample size - All - 3 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
tabout country client2  ///
	using "$output/Sample stats/Sample size - All (sep by status) - 3 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
	

* --> Age breakdown by country
tabout age_enrol_cat country ///
	using "$output/Sample stats/Age breakdown by country - 3 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
/*
tabout age_enrol_cat country if client1==4 ///
	using "$output/Sample stats/Age breakdown by country - 3 year sample partners ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
*/


* --> Age breakdown by sex 
tabout age_enrol_cat sex ///
	using "$output/Sample stats/Age breakdown by sex - 3 year sample ($S_DATE).xls", ///
	c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Age breakdown by sex by country
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout age_enrol_cat sex if country2==`i' ///
	using "$output/Sample stats/Age breakdown by sex - 3 year sample - Country `i' ($S_DATE).xls", ///
		c(col) f(1p) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}


* --> Status at enrolment
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout status_enrol client1 if country2==`i' ///
	using "$output/Sample stats/Status at enrolment - 3 year sample - Country `i' ($S_DATE).xls", ///
		c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout status_enrol client1 ///
using "$output/Sample stats/Status at enrolment - 3 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


* --> Sample size for children, adolescents and partners when we restrict to
*	  those who could be matched to their index client
use "$temp/all clients - full dataset - 3yr sample.dta", clear
drop if hhmem_caseid==""
	// Keep only children, adolescents and partners
	
merge 1:1 hhmem_caseid using "$temp/childadol matched to index - 3yr sample.dta"
drop if _merge==2
	// There are some in the using data - child/adol matched to index - that
	// don't appear in the master data - the full dataset - because in the full
	// dataset we dropped individuals in the child/adol dataset who didn't have
	// an age as that meant we couldn't assign them to child or adol.

drop _merge
merge 1:1 hhmem_caseid using "$temp/partner matched to index - 3yr sample.dta"
drop if _merge==2	
drop _merge

keep if matched_child_index==1 | matched_partner_index==1
	// Only keep those who were matched to their index client

tabout country client1  ///
	using "$output/Sample stats/Sample size - HH mems matched to index - 3 year sample ($S_DATE).xls", ///
	c(col freq) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
