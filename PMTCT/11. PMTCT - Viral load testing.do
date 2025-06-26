*** APR 2021 - PMTCT cascade
*** VL testing
* 18 April 2021


foreach k in 1 2 3 {

use "$data/cohort_all_`k'yr.dta", replace
qui svyset id 



*------------------------------------------------------------------------------*
* Viral load suppression
/*
Full sample, no restriction on visits.
*/

* Only including those tested, suppression<1000
qui tabout mostrecent_vlresult country ///
	using "$output/Viral Load testing/`k' year cohort/VL supp 1000 (amongst those tested) 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<1000
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/Viral Load testing/`k' year cohort/VL supp 1000 (all women) 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

* Only including those tested, suppression<200
qui tabout mostrecent_vlresult2 country ///
	using "$output/Viral Load testing/`k' year cohort/VL supp 200 (amongst those tested) 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<200
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/Viral Load testing/`k' year cohort/VL supp 200 (all women) 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	

	
	
*------------------------------------------------------------------------------*
* Viral load suppression excl WC sites
/*
Full sample, no restriction on visits.
*/

preserve
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

* Only including those tested, suppression<1000
qui tabout mostrecent_vlresult country ///
	using "$output/Viral Load testing/`k' year cohort/Excl WC/VL supp 1000 (amongst those tested) 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<1000
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/Viral Load testing/`k' year cohort/Excl WC/VL supp 1000 (all women) 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

* Only including those tested, suppression<200
qui tabout mostrecent_vlresult2 country ///
	using "$output/Viral Load testing/`k' year cohort/Excl WC/VL supp 200 (amongst those tested) 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<200
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/Viral Load testing/`k' year cohort/Excl WC/VL supp 200 (all women) 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore

	
	
	
*------------------------------------------------------------------------------*
* Viral load suppression WC sites only
/*
Full sample, no restriction on visits.
*/
/*
preserve
keep if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

qui tabout mostrecent_vlresult country ///
	using "$output/Viral Load testing/`k' year cohort/WC only/VL supp 1000 (amongst those tested) 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<1000
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/Viral Load testing/`k' year cohort/WC only/VL supp 1000 (all women) 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

* Only including those tested, suppression<200
qui tabout mostrecent_vlresult2 country ///
	using "$output/Viral Load testing/`k' year cohort/WC only/VL supp 200 (amongst those tested) 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
* All women, including those not tested, suppression<200
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/Viral Load testing/`k' year cohort/WC only/VL supp 200 (all women) 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

restore

*/


*------------------------------------------------------------------------------*
* AGYW and adolescent viral load suppression

* --> AGYW
preserve
keep if agecat_2==1
qui tabout mostrecent_vlresult country ///
	using "$output/Viral Load testing/`k' year cohort/AGYW/VL supp 1000 (amongst those tested) 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/Viral Load testing/`k' year cohort/AGYW/VL supp 1000 (all women) 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult2 country ///
	using "$output/Viral Load testing/`k' year cohort/AGYW/VL supp 200 (amongst those tested) 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/Viral Load testing/`k' year cohort/AGYW/VL supp 200 (all women) 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore


* --> Adolescents
preserve
keep if agecat_5==1
qui tabout mostrecent_vlresult country ///
	using "$output/Viral Load testing/`k' year cohort/Adol/VL supp 1000 (amongst those tested) 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/Viral Load testing/`k' year cohort/Adol/VL supp 1000 (all women) 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult2 country ///
	using "$output/Viral Load testing/`k' year cohort/Adol/VL supp 200 (amongst those tested) 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/Viral Load testing/`k' year cohort/Adol/VL supp 200 (all women) 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore




*------------------------------------------------------------------------------*
* 15-19, 20-24 and 25+ yrs viral load suppression

* --> 15-19
preserve
keep if ag_1519==1
qui tabout mostrecent_vlresult country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (amongst those tested) 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (all women) 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (amongst those tested) 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (all women) 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore


* --> 20-24
preserve
keep if yw==1
qui tabout mostrecent_vlresult country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (amongst those tested) 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (all women) 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (amongst those tested) 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (all women) 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore


* --> 25+
preserve
keep if ow==1
qui tabout mostrecent_vlresult country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (amongst those tested) 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 1000 (all women) 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (amongst those tested) 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout mostrecent_vlresult_nomiss2 country ///
	using "$output/AGYW stats/VL testing/`k' year cohort/VL supp 200 (all women) 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
restore

}
