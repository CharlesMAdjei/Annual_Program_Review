

*** App2 Old & new version 
*** Master do file for appending Clare & new version datasets and cleaning
* Aug 2021



*------------------------------------------------------------------------------*
* Start up commands

clear all
set more off
set excelxlsxlargefile on


global appdata "C:/Users/farou/OneDrive/Desktop/m2m/Ghana Program Data/App data"
global commcare_appdata "$appdata/Commcare"
global do_appdata "$appdata/Do files"
global temp_appdata "$appdata/Temp"
global data_appdata "$appdata/Data"
global output_appdata "$appdata/Output"


global beg_period=td(01Jan2023)
global end_period=td(29Feb2024)


*------------------------------------------------------------------------------
*                             Data Management
*------------------------------------------------------------------------------*
* Run importing and cleaning do files

* --> Import and append
*--> Old version
do "$do_appdata/App2/1. App2 Old version - Import and append.do"

*--> New version
do "$do_appdata/App2/1. App2 New version - Import and append.do"




* --> Append all years for each form
foreach x in reg_index reg_hhmem caregiver infant eid devmile ///
	childadol partner exit_index  {
		use "$temp_appdata/Old & new version/App2/`x'_2020.dta", clear
		append using "$temp_appdata/Old & new version/App2/`x'_2021.dta", force
		drop if facility == "Ghana test facility"
		duplicates drop
		save "$data_appdata/Old & new version/App2/`x'.dta", replace
		erase "$temp_appdata/Old & new version/App2/`x'_2020.dta"
		erase "$temp_appdata/Old & new version/App2/`x'_2021.dta"
}



*--> data cleaning, creation of new variables and labeling

foreach form in reg_index reg_hhmem index infant immunization ///
                growth_monitoring eid devmile childadol  {
	do "$do_appdata/App2/`form'.do"
}







*------------------------------------------------------------------------------
*                             Output from analysis
*-----------------------------------------------------------------------------
* --> Birth certification
clear
use "$data_appdata/Old & new version/App2/growth_monitoring.dta"
sort facility 
egen fac_tag=tag(fac)
keep if fac_tag==1
keeporder facility eligible_fac perc_birthreg_fac
export excel using ///
	"$output_appdata/Birth registration ($S_DATE).xlsx", ///
	firstrow(varlabels) sheetmodify
	
/*
% of children aged 0-3 years achieving age-appropriate development milestones
*/
clear
use "$data_appdata/Old & new version/App2/devmile_reduced.dta"	
foreach i in 3 6 9 12 18 24 36 {
	preserve
	sort facility
	keeporder facility eligible_`i'm_fac *assessed_`i'm_fac *achieved_`i'm_fac 
	export excel using "$output_appdata/Development milestones ($S_DATE).xlsx", ///
		sheet("`i'm") firstrow(varlabels) sheetmodify
	restore
}

*--> Immunizations
clear
use "$data_appdata/Old & new version/App2/immunization.dta"	
foreach i in 6wk 10wk 14wk 6m 9m 12m 18m {
	preserve
	sort facility
	keeporder facility due_`i'_fac immun_assessed_`i'_fac immun_done_`i'_fac ///
	immun_perc_done_`i'_fac  
	export excel using "$output_appdata/immunization ($S_DATE).xlsx", ///
		sheet("`i'") firstrow(varlabels) sheetmodify
	restore
}

*--> Deworming
clear
use "$data_appdata/Old & new version/App2/deworming.dta"	
foreach i in 6m 12m 18m 24m{
	preserve
	sort facility
	keeporder facility due_`i'_fac1 deworm_assessed_`i'_fac deworm_done_`i'_fac ///
	deworm_perc_done_`i'_fac  
	export excel using "$output_appdata/deworming ($S_DATE).xlsx", ///
		sheet("`i'") firstrow(varlabels) sheetmodify
	restore
}

*--> Vitamin
clear
use "$data_appdata/Old & new version/App2/vitamin.dta"	
foreach i in 6m 12m 18m 24m{
	preserve
	sort facility
	keeporder facility due_`i'_fac2 vita_assessed_`i'_fac vita_done_`i'_fac ///
	vita_perc_done_`i'_fac  
	export excel using "$output_appdata/vitamin ($S_DATE).xlsx", ///
		sheet("`i'") firstrow(varlabels) sheetmodify
	restore
}


* --> Growth curve assessments
use "$data_appdata/Old & new version/App2/growth_monitoring.dta"
foreach i in 6wk 10wk 14wk 6m 9m 12m 18m 24m {
	preserve
	sort facility 
	egen fac_tag=tag(fac)
	keep if fac_tag==1
	keeporder facility *_`i'_fac 
	sort facilityoutput_appdata/Growth curve ($S_DATE).xlsx", ///
		sheet("`i'") firs
	export excel using "$trow(varlabels) sheetmodify
	restore
}


/*
% of parents/caregivers displaying coping skills including coping behavior
*/
use "$data_appdata/Old & new version/App2/index_reduced2.dta", clear

sort facility
export excel using "$output_appdata\Coping ($S_DATE).xlsx", ///
	firstrow(varlabels) sheetmodify


*-- > Number of infants aged 0-3 years enrolled into the m2m programme
clear
use "$data_appdata/Old & new version/App2/infant_reduced.dta", clear
egen unique_infant=tag(hhmem_id)
tab facility if unique_infant == 1


*--> Number of pregnant adolescents and older women and parents/caregivers of 
*    young children aged 0-3 reached with RMNCH/PMTCT/ECD education to promote
*    optimal development of their children
use "$data_appdata/Old & new version/App2/index_reduced_full.dta", clear 
tab facility if id_tag == 1

*-- > Male partners
use "$data_appdata/Old & new version/App2/partner.dta", clear
keep if country == "Ghana"
egen unique_partner=tag(hhmem_id)
tab facility if unique_partner == 1
