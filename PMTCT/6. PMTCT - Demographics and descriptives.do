*** APR 2021 - PMTCT cascade
*** Demographics and descriptives
* 25 March 2021


/*
Stats included here:
	- Site type (over sites and clients)
	- Client type
	- Retained
	- AN and PN breakdown
	- Mother's age (cohort and median)
	- AGYW distribution
	- AN and PN visits
	- Trimester and gestage
	- Family planning
	- ART for life
	- Has partner and partner status
	
I also calculate the stats excluding WC sites, as well as for WC sites only, 
finally followed by AGYW across all sites.
*/



*Total number of clients
use "$data/vitol_cohort_all.dta", clear
tab facility, m

*Total number of clients by age category
tab agecat_2 facility, m r col

*Total number of clients by client type
tab new_client_type facility, m col


*Total number of children
tab has_child facility, m r

*EID done
tab test_68wk_done if hiv_status == 1 & ( (td(30jun2022) - infant_dob) > = 42)
tab test_1824m_done if hiv_status == 1 & ( (td(30jun2022) - infant_dob) > = 547)



*------------------------------------------------------------------------------*
* Site type (by site)
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", clear
	
cap drop site_tag
egen site_tag=tag(facility)
egen unique_client=tag(id)
qui svyset id

tab site_type if site_tag==1, m
qui tabout site_type country if site_tag==1 ///
	using "$output/Demog & descrip/enrolment by site type.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	
	
	
*------------------------------------------------------------------------------*
* Site type (by clients)
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", replace
qui svyset id

tab site_type facility, m 
qui tabout site_type facility ///
	using "$output/Demog & descrip/total client by site.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*
* Client type 
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", clear
qui svyset id

tab type facility, m col
tabout type facility ///
	using "$output/Demog & descrip/enrolment by client type.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	

*------------------------------------------------------------------------------*
* Retained
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", clear
qui svyset id

tab retained facility, m col
qui tabout retained facility ///
	using "$output/Demog & descrip/retained by facility.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
	

*------------------------------------------------------------------------------*
* AN and PN breakdowns
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", replace
qui svyset id

* AN-any versus PN only by country
tab facility an_any, m r
qui tabout facility an_any ///
	using "$output/Demog & descrip/AN-any versus PN only by facility).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
	

* AN-any breakdown (AN only vs AN+PN) by country
tab facility type if an_any==1, m r
qui tabout facility type if an_any==1 ///
	using "$output/Demog & descrip/AN-any breakdown (AN only vs AN+PN) by country.xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


* PN-any versus AN only by country
tab facility pn_any, m r
qui tabout facility pn_any ///
	using "$output/Demog & descrip/PN-any versus AN only by country.xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

	
* PN-any breakdown (PN only versus AN+PN) (by country)
tab facility type if pn_any==1 
qui tabout facility type if pn_any==1 ///
	using "$output/Demog & descrip/PN-any breakdown (PN only versus AN+PN) (by facility).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
* Mother's age at 1st visit
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", clear
qui svyset id


* Mother's median age and range at 1st m2m visit (by country)
tabstat age, by(country) stat(median min max)


* Mother's age cohort at 1st m2m visit (by country)
qui tabout agecat_5 country ///
	using "$output/Demog & descrip/Mother's age.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 


	

*------------------------------------------------------------------------------*
* AGYW distribution
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", replace
keep if agyw==1
qui svyset id

qui tabout country agecat_agyw ///
	using "$output/Demog & descrip/AGYW distribution.xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

/*
Commented out because they didn't ask for it

qui tabout agecat_agyw2 country ///
	using "$output/AGYW stats/Family planning/`k' year cohort/Mother's age 2021 AGYW v2`k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
*/
tab agecat_agyw country

	
	
	
*------------------------------------------------------------------------------*
* AN and PN visits
/*
All clients, no restriction on visits
*/

use "$data/vitol_cohort_all.dta", replace
qui svyset id 

tabstat visits_an if an_any==1, stats(n mean median)
qui tabout visits_an_cat facility if an_any==1 ///
	using "$output/Demog & descrip/AN visits.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
bysort country: tabstat visits_an if an_any==1 , stats(n mean median)


tabstat visits_pn if pn_any==1, stats(n mean median)
qui tabout visits_pn_cat facility if pn_any==1 ///
	using "$output/Demog & descrip/PN visits.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
bysort country: tabstat visits_pn if pn_any==1, stats(n mean median)
tabstat visits_pn if pn_any==1, stats(n mean median)


	

*------------------------------------------------------------------------------*
* Gestational age/trimester
/*
AN-any with no restriction on visits.
This is gestational age at first visit to the facility, which isn't necessarily
the same as the first time they saw m2m.
~17% missing gestage. Stat reported in slide excludes missings.
*/

use "$data/vitol_cohort_an_any.dta", replace
qui svyset id 

* --> Trimester by country
qui tabout trimester facility ///
	using "$output/Demog & descrip/Trimester.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
tabstat gestage_fac if gestage_fac>3, stat(median p25 p75)
bysort country: tabstat gestage_fac if gestage_fac>3, stat(median p25 p75)


* --> Trimester by country - AGYW only
qui tabout trimester facility if agyw==1 ///
	using "$output/Demog & descrip/Trimester AGYW.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
tabstat gestage_fac if gestage_fac>3 & agyw==1, stat(median p25 p75)
bysort country: tabstat gestage_fac if gestage_fac>3 & agyw==1, ///
	stat(median p25 p75)


* --> Proportion with gestage < 17 weeks (RMNCH fact sheet)
replace gestage_before17wks=0 if gestage_before17wk==.
qui tabout gestage_before17wks facility if gestage_fac>3 ///
	using "$output/Demog & descrip/Gestage before 17 wks.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
bysort country: tabstat gestage_before17wks if gestage_fac>3, ///
	stat(median p25 p75)
	

	

*------------------------------------------------------------------------------*
* Use of modern family planning
/*
PN-any clients, 2+ PN visits. 
*/

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
qui svyset id 


* --> All sites
foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/Demog & descrip/FP `x'.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}

foreach x in pill inj imp iud tl {
	qui tabout fp_`x'_ever facility if fp_long_ever==1 ///
	using "$output/Demog & descrip/FP long `x'.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}



	
	
	
	
*------------------------------------------------------------------------------*
* Use of modern family planning - AGYW and adolescent
/*
PN-any AGYW/adol, 2+ PN visits. 
*/

* --> AGYW
use "$data/vitol_cohort_pn_any.dta", clear
keep if visits_pn>=2
keep if agyw==1
qui svyset id 

foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/Demog & descrip/FP `x' AGYW.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}


* --> Adolescents 10-19
use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
keep if agecat_5==1
qui svyset id 

foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/Demog & descrip/FP `x' adol.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}


* --> Adolescents 15-19, young women 20-24 and older women 25+
use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
keep if ag_1519==1
qui svyset id 
foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/FP `x' 15-19 yrs.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
keep if yw==1
qui svyset id 
foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/FP `x' 20-24 yrs.xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}

use "$data/vitol_cohort_pn_any.dta", replace
keep if visits_pn>=2
keep if ow==1
qui svyset id 
foreach x in long dual condom any {
	qui tabout fp_`x'_ever facility ///
	using "$output/FP `x' 25+ yrs .xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
}




*------------------------------------------------------------------------------*
* Partner HIV status
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", replace
qui svyset id

qui tabout country partner_status ///
	using "$output/Demog & descrip/Partner status.xls", ///
	c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 



*------------------------------------------------------------------------------*
* Partner ART status
/*
All clients, no restriction on visits.
*/

/*
I don't think we capture this in app1 - double check with Garrit

use "$data/cohort_all_`k'yr.dta", replace
qui svyset id

tab partner_artstart if partner_status==1, missing 
replace partner_artstart=2 if partner_artstart==.
svy: tab partner_artstart if partner_status==1, ci missing 
qui tabout country partner_artstart if partner_status==1 ///
	using "$output_excel\Do file 4 - Demographics and descriptives\Partner ART start 2018`k'yr cohort ($S_DATE).xls", ///
	c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
*/




*------------------------------------------------------------------------------*
* ART for life
/*
All clients, no restriction on visits.
*/

use "$data/vitol_cohort_all.dta", clear
qui svyset id


* --> All sites
* Started ART
qui tabout facility artstart if hiv_status == 1 ///
	using "$output/Demog & descrip/ART start.xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

* When started ART 
qui tabout facility artstart_when ///
	using "$output/Demog & descrip/ART start when.xls", ///
	c(row) f(1p) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

		
		
		
*------------------------------------------------------------------------------*
* AGYW and adolescent ART for life
/*
AGYW/adolescent clients, no restriction on visits.
*/

* --> AGYW
use "$data/vitol_cohort_all.dta", clear
keep if agecat_2==1
qui svyset id


qui tabout facility artstart ///
	using "$output/Demog & descrip/ART start AGYW.xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 

