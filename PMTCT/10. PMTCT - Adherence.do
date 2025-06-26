*** APR 2021 - PMTCT cascade
*** Adherence
* 9 March 2021


foreach k in 1 2 3 {

use "$data/cohort_all_`k'yr.dta", replace
qui svyset id 



*------------------------------------------------------------------------------*
* Adherence – 5 point scale

* All

tabout mother_adh_5pt_allcat2 country ///
	using "$output/Adherence/`k' year cohort/Adh 5 pt scale 2021 ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* All excl WC sites
preserve 
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")
tabout mother_adh_5pt_allcat2 country ///
	using "$output/Adherence/`k' year cohort/Excl WC/Adh 5 pt scale 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
restore

/* WC sites only
preserve 
keep if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")
tabout mother_adh_5pt_allcat2 country ///
	using "$output/Adherence/`k' year cohort/WC only/Adh 5 pt scale 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
restore
*/

* AGYW
tabout mother_adh_5pt_allcat2 country if agecat_2==1 ///
	using "$output/Adherence/`k' year cohort/AGYW/Adh 5 pt scale 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* Adolescents (10-19)
tabout mother_adh_5pt_allcat2 country if agecat_5==1 ///
	using "$output/Adherence/`k' year cohort/Adol/Adh 5 pt scale 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* 15-19, 20-24 and 25+
tabout mother_adh_5pt_allcat2 country if ag_1519==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 5 pt scale 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
tabout mother_adh_5pt_allcat2 country if yw==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 5 pt scale 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
tabout mother_adh_5pt_allcat2 country if ow==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 5 pt scale 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

	
	
	
*------------------------------------------------------------------------------*
* Adherence - 7 day recall 

* All
tabout mother_adh_7day_mean_cat country ///
	using "$output/Adherence/`k' year cohort/Adh 7 day recall 2021 ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* All excl WC sites
preserve 
drop if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")
tabout mother_adh_7day_mean_cat country ///
	using "$output/Adherence/`k' year cohort/Excl WC/Adh 7 day recall 2021 excl WC `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
restore

/* WC sites only
preserve 
keep if inlist(facility, "khayelitsha site b mou", ///
	"michael mapongwana clinic", "town 2 clinic")
tabout mother_adh_7day_mean_cat country ///
	using "$output/Adherence/`k' year cohort/WC only/Adh 7 day recall 2021 WC only `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
restore
*/

* AGYW (10-24)
tabout mother_adh_7day_mean_cat country if agecat_2==1 ///
	using "$output/Adherence/`k' year cohort/AGYW/Adh 7 day recall 2021 AGYW `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* Adolescents (10-19)
tabout mother_adh_7day_mean_cat country if agecat_5==1 ///
	using "$output/Adherence/`k' year cohort/Adol/Adh 7 day recall 2021 adol `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

* 15-19, 20-24 and 25+
tabout mother_adh_7day_mean_cat country if ag_1519==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 7 day recall 15-19 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
tabout mother_adh_7day_mean_cat country if yw==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 7 day recall 20-24 yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 
tabout mother_adh_7day_mean_cat country if ow==1 ///
	using "$output/AGYW stats/Adherence/`k' year cohort/Adh 7 day recall 25+ yrs 2021 `k'yr cohort ($S_DATE).xls", ///
	c(col ci) f(1p 1) svy lay(row) npos(row) ///
	clab(_ _) per cisep(-) ///
	replace 

}
