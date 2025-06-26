*** APR 2020 - PMTCT cascade
*** PMTCT cascade
* 25 March 2021


/*
- ART for life
- Delivery at health facility - cannot calculate this year
- Infant ARV uptake for PMTCT
- Infant CTX
- Infant PCR test
- Infant PCR test result
- Infant final test
- Infant final test result
- Infant status known
- Infant positivity rate (women delivering)
- Infant positivity rate (infants tested)
- Infant ART uptake

Presented for all, then excl WC sites and only WC sites, then for AGYW.
*/


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* All sites
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 2 3 {

use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 


*--------------------------------*
* ART for life

qui tabout artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/ART uptake 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant ARV (NVP) 

qui tabout nvp_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/Infant NVP 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant bactrim (CTX) 

qui tabout ctx_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/Infant CTX 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test done

qui tabout test_68wk_done country ///
	using "$output/PMTCT cascade/`k' year cohort/Infant PCR test 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test result 

qui tabout has_test68wk_result country ///
	using "$output/PMTCT cascade/`k' year cohort/Infant PCR test result 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test done
/*
This is restricted to infants who were old enough to have done the final test
before the end of the observation period if they hadn't already had it done.
*/

qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Infant final test done 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test result 
/*
Ditto above restriction.
*/

qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Infant final test result 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant status known
/*
Ditto above restriction.
*/

qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Infant status known 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant positivity rate 
/*
Ditto above restriction.
*/

qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Infant pos rate (all women delivering) 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/PMTCT cascade/`k' year cohort/Infant pos rate (infants tested) 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
	
*--------------------------------*
* Infant ART uptake 
/*
This is amongst all infants, regardless of whether they're positive or not.
*/

replace infant_artstart=0 if infant_artstart>1
tab infant_artstart country if infant_status==1
qui tabout infant_artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/Infant ART uptake 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


}



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Excl WC sites
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 3 2 {

use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

	
*--------------------------------*
* ART for life

qui tabout artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/ART uptake 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant ARV (NVP) 

qui tabout nvp_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant NVP 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant bactrim (CTX) 

qui tabout ctx_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant CTX 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test done

qui tabout test_68wk_done country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant PCR test 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test result 

qui tabout has_test68wk_result country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant PCR test result 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test done
/*
This is restricted to infants who were old enough to have done the final test
before the end of the observation period if they hadn't already had it done.
*/

qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant final test done 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test result 
/*
Ditto above restriction.
*/

qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant final test result 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant status known
/*
Ditto above restriction.
*/

qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant status known 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant positivity rate 
/*
Ditto above restriction.
*/

qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant pos rate (all women delivering) 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant pos rate (infants tested) 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
	
*--------------------------------*
* Infant ART uptake 
/*
This is amongst all infants, regardless of whether they're positive or not.
*/

replace infant_artstart=0 if infant_artstart>1
qui tabout infant_artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/Excl WC/Infant ART uptake 2020 Excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

}



	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Only WC sites
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 2 3 {

use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
keep if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")

	
*--------------------------------*
* ART for life

cap qui tabout artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/ART uptake 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant ARV (NVP) 

cap qui tabout nvp_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant NVP 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant bactrim (CTX) 

cap qui tabout ctx_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant CTX 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test done

cap qui tabout test_68wk_done country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant PCR test 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test result 

cap qui tabout has_test68wk_result country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant PCR test result 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test done
/*
This is restricted to infants who were old enough to have done the final test
before the end of the observation period if they hadn't already had it done.
*/

cap qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant final test done 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test result 
/*
Ditto above restriction.
*/

cap qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant final test result 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant status known
/*
Ditto above restriction.
*/

cap qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant status known 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant positivity rate 
/*
Ditto above restriction.
*/

cap qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant pos rate (all women delivering) 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant pos rate (infants tested) 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
	
*--------------------------------*
* Infant ART uptake 
/*
This is amongst all infants, regardless of whether they're positive or not.
*/


replace infant_artstart=0 if infant_artstart>1
tab infant_artstart country
cap qui tabout infant_artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/WC only/Infant ART uptake 2020 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
	
}

	
	

*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* AGYW
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 3 2 {

use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
keep if agyw==1



*--------------------------------*
* ART for life

cap qui tabout artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/ART uptake 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant ARV (NVP) 

qui tabout nvp_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant NVP 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
*--------------------------------*
* Infant bactrim (CTX) 

qui tabout ctx_done_ever country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant CTX 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test done

qui tabout test_68wk_done country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant PCR test 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant first test result 

qui tabout has_test68wk_result country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant PCR test result 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant final test done
/*
This is restricted to infants who were old enough to have done the final test
before the end of the observation period if they hadn't already had it done.
*/

qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant final test done 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	




*--------------------------------*
* Infant final test result 
/*
Ditto above restriction.
*/

qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant final test result 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant status known
/*
Ditto above restriction.
*/

qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant status known 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	



*--------------------------------*
* Infant positivity rate 
/*
Ditto above restriction.
*/

qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant pos rate (all women delivering) 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant pos rate (infants tested) 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

		
	
*--------------------------------*
* Infant ART uptake 
/*
This is amongst all infants, regardless of whether they're positive or not.
*/

local k=2
replace infant_artstart=0 if infant_artstart>1
tab infant_artstart country
qui tabout infant_artstart country ///
	using "$output/PMTCT cascade/`k' year cohort/AGYW/Infant ART uptake 2020 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 		
}

	
	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* 15-19, 20-24 and 25+ years old (conference abstracts)
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

foreach k in 2 3 {

* --> 15-19
use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
keep if ag_1519==1

cap qui tabout artstart country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/ART uptake 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant NVP 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant CTX 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test result 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test done 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout  has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test result 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant status known 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (all women delivering) 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
	
cap qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (infants tested) 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

/*
cap qui tabout infant_artstart country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant ART uptake 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
*/
	// No observations
	

* --> 20-24
use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
keep if yw==1

cap qui tabout artstart country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/ART uptake 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant NVP 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant CTX 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test result 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test done 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test result 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant status known 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (all women delivering) 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
	
cap qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (infants tested) 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
* --> 25+
use "$data/cohort_an_pn_`k'yr_final.dta", replace
qui svyset id 
keep if ow==1

cap qui tabout artstart country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/ART uptake 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant NVP 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant CTX 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant PCR test result 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout test_1824m_done country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test done 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_test1824m_result country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant final test result 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout has_infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant status known 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

cap qui tabout infant_status country if infant_tooyoung==0 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (all women delivering) 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
	
cap qui tabout infant_status country if infant_tooy==0 & has_infant_status==1 ///
	using "$output/AGYW stats/PMTCT cascade/`k' year cohort/Infant pos rate (infants tested) 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci)f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	
	
}
