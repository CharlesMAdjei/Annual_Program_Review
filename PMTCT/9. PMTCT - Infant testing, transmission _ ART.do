*** APR 2020 - PMTCT cascade
*** Infant testing, transmission and ART
* 16 April 2021


/*
Note:
- All stats are calculated using the PN-any sample with 2+ PN visits.
- For stats relating to final test result, the sample is further restricted to
  those old enough by 1 Nov 2019 to have done the final test and received the
  result unless they have already done the test.
- The positivity rate calculation includes missings, which means they are
  effectively treated as negatives. In other words, the positivity rate is the
  % of infants positive out of all age eligible infants with 2+ PN visits, 
  irrespective of whether they were tested or not.
*/


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* All sites
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 3 2 {


use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 



*------------------------------------------------------------------------------*
* % infants who did first test

qui tabout test_68wk_done country ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Infant first test done 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
	
	
*------------------------------------------------------------------------------*
* % infants with first test result

qui tabout country has_test68wk_result ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Has first test result 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
* % infants eligible for final test with final test result
/*
Excludes infants too young (<2 years by 1 Nov 2020) if they had not already
done the test.
*/

qui tabout country has_test1824m_result if infant_tooyoung==0 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
/*
Checking out why rates are dropping for some countries despite no changes being
made yet

* --> Use data before changes made when bring missing outcomes in
local k = 2
use "$data/cohort_pn_any_`k'yr.dta", replace
keep if visits_pn>=2
qui svyset id 

qui tabout country has_test1824m_result if infant_tooyoung==0 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result 2020 `k'yr cohort x ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
*/
	
	
	
	
*------------------------------------------------------------------------------*
* First test MTCT rate (i.e. positivity rate using first test)
/*
Infants who tested positive at or before enrolment are excluded.
*/

* Code missings as unknown
replace test_68wk_result=2 if test_68wk_result==.
label def test_result_lab2 1"Positive" 0"Negative" 2"Missing"
label val test_68wk_result test_result_lab2


* Including all infants
qui tabout country test_68wk_result ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT rate first test 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
	
* Excluding infants who tested positive at or before enrolment
qui tabout country test_68wk_result if when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT rate first test excl pre pos 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
* Excluding infants who tested positive at or before enrolment
* 15-19, 20-24 and 25+ years old (conference abstracts)
preserve
keep if ag_1519==1
qui tabout country test_68wk_result if when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/`k' year cohort/MTCT rate first test excl pre pos 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore

preserve
keep if yw==1
qui tabout country test_68wk_result if when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate first test excl pre pos 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore

preserve
keep if ow==1
qui tabout country test_68wk_result if when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate first test excl pre pos 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
	

	
	
*------------------------------------------------------------------------------*
* Final MTCT rate (positivity rate using final status)
/*
This excludes infants who were too young as well as those who tested positive
before enrolling with m2m. 
*/

* All eligible infants, i.e. including those without a final status
* a.k.a Among women delivering
tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT rate final status all 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


* Restricted to infants with a final status
* a.k.a Among infants tested
preserve
replace infant_status=. if infant_status==2
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT rate final status among known status 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
	
	
* Among women delivering, 15-19, 20-24 and 25+ years old
preserve
keep if ag_1519==1
tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among women delivering 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
preserve
keep if yw==1
tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among women delivering 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
preserve
keep if ow==1
tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among women delivering 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore


* Among infants tested, 15-19, 20-24 and 25+ years old
preserve
replace infant_status=. if infant_status==2
keep if ag_1519==1
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among infants tested 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
preserve
replace infant_status=. if infant_status==2
keep if yw==1
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among infants tested 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
preserve
replace infant_status=. if infant_status==2
keep if ow==1
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/AGYW stats/MTCT rates/`k' year cohort/MTCT rate final among infants tested 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
	
	
	
	
*------------------------------------------------------------------------------*
* MTCT graph (positive, negative and unknown)
/*
This excludes infants who were too young as well as those who tested positive
before enrolling with m2m.
*/

* --> Positivity rate amongst all women delivering (with 2+ visits)
qui tabout infant_status country if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT graph all 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 	
	// Used for bars in graph

	
* --> Positivity rate amongst those tested (with 2+ visits)
preserve
replace infant_status=. if infant_status==2
qui tabout infant_status country if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/MTCT graph status known 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 	
restore	


	

*------------------------------------------------------------------------------*
* Linking HIV positive infants to ART

* All
replace infant_artstart=0 if infant_artstart==.
tab country infant_artstart if infant_status==1
qui tabout country infant_artstart if infant_status==1 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Infant ART enrolment 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
* AGYW
qui tabout country infant_artstart if infant_status==1 & agecat_2==1 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Infant ART enrolment AGYW 2020 `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
	}
	
	

/*
Have not updated this from last year as I am hoping it isn't asked for.
Will need to change the years at least, if I include this. Also, will have to
be different for the 2 and 3 year cohorts.

*------------------------------------------------------------------------------*
* Final testing rate disaggregated by quarter in which infant was due
/*
Trying to see if there are differences in final testing rate by quarter.
Excludes infants too young (<2 years by 1 Nov 2019) if they had not already
done the test.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 

* 2017 and 2018
forvalues i=2017/2018 {
	qui tabout country has_test1824m_result if infant_tooyoung==0 & ///
		when_testpos>2 & due_`i'==1 ///
		using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result due `i' ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}

* 2019 (by quarter)
forvalues i=1/4 {
	qui tabout country has_test1824m_result if infant_tooyoung==0 & ///
		when_testpos>2 & due_2019q`i'==1 ///
		using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result due 2019 Q`i' ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}

foreach var of varlist due_2017 due_2018 due_2019q* {
	tab country has_test1824m_result if infant_tooyoung==0 & ///
	when_testpos>2 & `var'==1, r 
}	
tab country has_test1824m_result if infant_tooyoung==0 & ///
	when_testpos>2, r 

*/


	
	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Excluding WC sites
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 2 3 {

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")


*------------------------------------------------------------------------------*
* % infants who did first test

qui tabout test_68wk_done country ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/Infant first test done 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	

	
*------------------------------------------------------------------------------*
* % infants with first test result

qui tabout country has_test68wk_result ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/Has first test result 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

		
	
	
*------------------------------------------------------------------------------*
* % infants eligible for final test with final test result
/*
Excludes infants too young (<2 years by 1 Nov 2019) if they had not already
done the test.
*/

qui tabout country has_test1824m_result if infant_tooyoung==0 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/Has final test result 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
* First test MTCT rate (i.e. positivity rate using first test)
/*
Infants who tested positive at or before enrolment are excluded.
*/

* Code missings as unknown
replace test_68wk_result=2 if test_68wk_result==.
label def test_result_lab2 1"Positive" 0"Negative" 2"Missing"
label val test_68wk_result test_result_lab2


* Including all infants
qui tabout country test_68wk_result ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT rate first test 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* Excluding infants who tested positive at or before enrolment
qui tabout country test_68wk_result if when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT rate first test excl pre pos 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
	
	
	
*------------------------------------------------------------------------------*
* Final MTCT rate (positivity rate using final status)
/*
This excludes infants who were too young as well as those who tested positive
before enrolling with m2m. 
*/

* All eligible infants, i.e. including those without a final status
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT rate final status all 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
* Restricted to infants with a final status
preserve
replace infant_status=. if infant_status==2
qui tabout country infant_status if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT rate final status among known status 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore
	
	
	
	
*------------------------------------------------------------------------------*
* MTCT graph (positive, negative and unknown)
/*
This excludes infants who were too young as well as those who tested positive
before enrolling with m2m.
*/

* --> Positivity rate amongst all women delivering (with 2+ visits)
qui tabout infant_status country if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT graph all 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 	
	// Used for bars in graph

	
* --> Positivity rate amongst those tested (with 2+ visits)
preserve
replace infant_status=. if infant_status==2
qui tabout infant_status country if infant_tooyoung==0 & when_testpos>2 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/MTCT graph status known 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 	
restore	


	

*------------------------------------------------------------------------------*
* Linking HIV positive infants to ART

* All
replace infant_artstart=0 if infant_artstart==.
qui tabout country infant_artstart if infant_status==1 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/Excl WC/Infant ART enrolment 2020 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
tab country infant_artstart if infant_status==1

}	




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* WC sites only
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 3 {

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

	
	
*------------------------------------------------------------------------------*
* % infants eligible for final test with final test result
/*
Excludes infants too young (<2 years by 1 Nov 2019) if they had not already
done the test.
*/

qui tabout country has_test1824m_result if infant_tooyoung==0 ///
	using "$output/Infant testing, transmission & ART/`k' year cohort/WC only/Has final test result 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
}
	
/*
Commented out until this is asked for, then will have to update for this year.
	
*------------------------------------------------------------------------------*
* Final testing rate disaggregated by quarter in which infant was due

use "$data/Datasets used for analysis/cohort_pn_any_updated.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

* 2017 and 2018
forvalues i=2017/2018 {
	qui tabout country has_test1824m_result if infant_tooyoung==0 & ///
		when_testpos>2 & due_`i'==1 ///
		using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result due `i' excl WC ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}

* 2019 excl WC (by quarter)
forvalues i=1/4 {
	qui tabout country has_test1824m_result if infant_tooyoung==0 & ///
		when_testpos>2 & due_2019q`i'==1 ///
		using "$output/Infant testing, transmission & ART/`k' year cohort/Has final test result due 2019 Q`i' excl WC ($S_DATE).xls", ///
		c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per cisep(-) h3(nil) ///
		replace 
}

foreach var of varlist due_2017 due_2018 due_2019q* {
	tab country has_test1824m_result if infant_tooyoung==0 & ///
	when_testpos>2 & `var'==1, r 
}	
tab country has_test1824m_result if infant_tooyoung==0 & ///
	when_testpos>2, r 

*/
