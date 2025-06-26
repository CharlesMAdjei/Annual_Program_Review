*** APR 2020 - PMTCT cascade
*** PMTCT service uptake
* 19 March 2021

/*
- Disclosure - cannot calculate this year
- Couple attendance - cannot calculate this year
- Delivery in facility - cannot calculate this year
- Exclusive feeding
- Exclusive breastfeeding
- Modern family planning
- Dual family planning
- Condom use
- Infant ARV
- Infant bactrim
- Infant PCR test done
- Infant PCR test result
- Infant final test done
- Infant final test result
- Infant positivity rate (among women delivering)
- Infant positivity rate (among infants tested)
- Infant ART

This is presented first for all clients and sites, then for all excl WC sites
and WC sites only, and finally for AGYW across all sites.
*/





*------------------------------------------------------------------------------*
* Feeding - excl. feeding and excl. breastfeeding
/*
PN-any clients, 2+ PN visits. 
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
qui svyset id 

qui tabout excl_feeding facility ///
	using "$output/Exclusive feeding.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout ebf_6month facility ///
	using "$output/Exclusive BF.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Modern family planning - any, dual, condom
/*
PN-any with 2+ visits.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
qui svyset id 

qui tabout fp_any_ever country ///
	using "$output/FP any.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout fp_dual_ever country ///
	using "$output/FP dual.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout fp_condom_ever country ///
	using "$output/FP condom.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	


*------------------------------------------------------------------------------*
* Infant ARV (NVP) and bactrim (CTX)
/*
PN-any with 2+ PN visits.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
qui svyset id 

qui tabout nvp_done_ever country ///
	using "$output/Infant NVP.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout ctx_done_ever country ///
	using "$output/Infant CTX.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 



	

*------------------------------------------------------------------------------*
* Infant PCR test done and result received
/*
PN-any with 2+ PN visits.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
qui svyset id 

qui tabout test_68wk_done country ///
	using "$output/68wk test done.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout has_test68wk_result country ///
	using "$output/Has 68wk result.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
* Infant final test done (18-24 months) and test result received
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort (2 months 
before end of obs period) if they hadn't already done the final test (many 
infants do it younger than 2 years old). Note that the infant_tooyong variable 
has already been adjusted to set those who already have the final test to 0 so an 
additional condition does not need to be included for that.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
qui svyset id 

qui tabout test_1824m_done country ///
	using "$output/18-24m test done.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

qui tabout has_test1824m_result country ///
	using "$output/Has 1824m result.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
	
	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among women delivering)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
qui svyset id 

qui tabout infant_status facility ///
	using "$output/Pos rate (women delivering).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among infants tested)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
Restricted to those who were tested.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
drop if infant_status==2
qui svyset id 

qui tabout infant_status facility ///
	using "$output/Pos rate (infants tested).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	


*------------------------------------------------------------------------------*
* Infant ART
/*
PN-any with 2+ PN visits.
This is calculated on ALL positive infants, not just those who tested positive
after enrolling with m2m.
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
keep if infant_status==1 
qui svyset id 
replace infant_artstart=0 if infant_artstart==.

qui tabout infant_artstart country ///
	using "$output/Infant ART if pos.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* AGYW
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* Feeding - excl. feeding and excl. breastfeeding
/*
PN-any clients, 2+ PN visits. 
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if agyw==1
qui tabout excl_feeding country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Exclusive feeding 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout ebf_6month country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Exclusive BF 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	

	
*------------------------------------------------------------------------------*
* Modern family planning - any, dual, condom
/*
PN-any with 2+ visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if agyw==1
qui tabout fp_any_ever country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/FP any 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout fp_dual_ever country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/FP dual 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout fp_condom_ever country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/FP condom 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	


*------------------------------------------------------------------------------*
* Infant ARV (NVP) and bactrim (CTX)
/*
PN-any with 2+ PN visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if agyw==1
qui tabout nvp_done_ever country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Infant NVP 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout ctx_done_ever country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Infant CTX 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
* Infant PCR test done and result received
/*
PN-any with 2+ PN visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if agyw==1
qui tabout test_68wk_done country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/68wk test done 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout has_test68wk_result country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Has 68wk result 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	

*------------------------------------------------------------------------------*
* Infant final test done (18-24 months) and test result received
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort (2 months before end of 
obs period) if they hadn't already done the final test (many infants do it 
younger than 2 years old.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if infant_tooyoung==1
keep if agyw==1
qui tabout test_1824m_done country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/18-24m test done 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
qui tabout has_test1824m_result country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Has 1824m result 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among women delivering)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
qui svyset id 
keep if agyw==1
qui tabout infant_status country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Pos rate (women delivering) 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among infants tested)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
Restricted to those who were tested.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
drop if infant_status==2
qui svyset id 
keep if agyw==1
qui tabout infant_status country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Pos rate (infants tested) 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	


*------------------------------------------------------------------------------*
* Infant ART
/*
PN-any with 2+ PN visits.
This is calculated on ALL positive infants, not just those who tested positive
after enrolling with m2m.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
keep if infant_status==1 
qui svyset id 
keep if agyw==1
qui tabout infant_artstart country ///
	using "$output/PMTCT service uptake/`k' year cohort/AGYW/Infant ART if pos 2020 `k'yr cohort AGYW ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* 15-19, 20-24 and 25+ years old (conference abstracts)
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
* Feeding - excl. feeding and excl. breastfeeding
/*
PN-any clients, 2+ PN visits. 
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ag_1519==1
cap qui tabout excl_feeding country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive feeding 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ebf_6month country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive BF 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if yw==1
cap qui tabout excl_feeding country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive feeding 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ebf_6month country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive BF 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ow==1
cap qui tabout excl_feeding country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive feeding 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ebf_6month country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Exclusive BF 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
* Modern family planning - any, dual, condom
/*
PN-any with 2+ visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ag_1519==1
cap qui tabout fp_any_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP any 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_dual_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP dual 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_condom_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP condom 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if yw==1
cap qui tabout fp_any_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP any 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_dual_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP dual 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_condom_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP condom 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	

	
use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ow==1
cap qui tabout fp_any_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP any 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_dual_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP dual 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout fp_condom_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/FP condom 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 	


	
	
*------------------------------------------------------------------------------*
* Infant ARV (NVP) and bactrim (CTX)
/*
PN-any with 2+ PN visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ag_1519==1
cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant NVP 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant CTX 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if yw==1
cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant NVP 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant CTX 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ow==1
cap qui tabout nvp_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant NVP 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout ctx_done_ever country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant CTX 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	

*------------------------------------------------------------------------------*
* Infant PCR test done and result received
/*
PN-any with 2+ PN visits.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ag_1519==1
cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/68wk test done 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 68wk result 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if yw==1
cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/68wk test done 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 68wk result 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
keep if ow==1
cap qui tabout test_68wk_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/68wk test done 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test68wk_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 68wk result 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	

	
	
*------------------------------------------------------------------------------*
* Infant final test done (18-24 months) and test result received
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort (2 months before end of 
obs period) if they hadn't already done the final test (many infants do it 
younger than 2 years old.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if infant_tooyoung==1
keep if ag_1519==1
cap qui tabout test_1824m_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/18-24m test done 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test1824m_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 18-24m result 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if infant_tooyoung==1
keep if yw==1
cap qui tabout test_1824m_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/18-24m test done 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test1824m_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 18-24m result 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
qui svyset id 
drop if infant_tooyoung==1
keep if ow==1
cap qui tabout test_1824m_done country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/18-24m test done 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
cap qui tabout has_test1824m_result country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Has 18-24m result 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
	
	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among women delivering)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
qui svyset id 
keep if ag_1519==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (women delivering) 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
qui svyset id 
keep if yw==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (women delivering) 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
qui svyset id 
keep if ow==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (women delivering) 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Infant positivity rate (among infants tested)
/*
PN-any with 2+ PN visits.
Excludes infants less than 2 years old by 1 Nov 2020 `k'yr cohort if they had not yet done
the final test, as well as infants who tested positive at or before enrolment
with m2m. 
Restricted to those who were tested.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
drop if infant_status==2
qui svyset id 
keep if ag_1519==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (infants tested) 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
drop if infant_status==2
qui svyset id 
keep if yw==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (infants tested) 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
drop if infant_tooyoung==1
drop if when_testpos<=2
drop if infant_status==2
qui svyset id 
keep if ow==1
cap qui tabout infant_status country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Pos rate (infants tested) 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
* Infant ART
/*
PN-any with 2+ PN visits.
This is calculated on ALL positive infants, not just those who tested positive
after enrolling with m2m.
*/

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
keep if infant_status==1 
replace infant_artstart=0 if infant_artstart==.

qui svyset id 
keep if ag_1519==1
cap qui tabout infant_artstart country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant ART if pos 15-19 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	
use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
keep if infant_status==1 
qui svyset id 
keep if yw==1
cap qui tabout infant_artstart country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant ART if pos 20-24 yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

use "$data/cohort_pn_any_`k'yr_final.dta", replace
keep if visits_pn>=2
keep if infant_status==1 
qui svyset id 
keep if ow==1
cap qui tabout infant_artstart country ///
	using "$output/AGYW stats/PMTCT service uptake/`k' year cohort/Infant ART if pos 25+ yrs 2020 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
}
