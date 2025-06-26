*** Firdale versions - App2
*** Clean reg_hhmem dataset
* 31 March 2021


local form "reg_hhmem"
	
foreach c in 2019 2020 {

	* --> Open data
	use "$temp_appdata/Firdale/App2/`form'/`form'_`c'.dta", clear


	* --> Identify row with variable name and create new row
	local old=1 
	count
	local n=r(N)
	set obs `=`n'+1' 


	* --> Variable names
	foreach var of varlist * {
		replace `var'="form_type" in `=`n'+1' if `var'[`old']=="form_type"
		replace `var'="hhmem_type" in `=`n'+1' if `var'[`old']=="form.member_type"
		replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_status.dob"
		replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
		replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
		replace `var'="username" in `=`n'+1' if `var'[`old']=="username"
		replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
		replace `var'="case_name" in `=`n'+1' if `var'[`old']=="case_name"
		replace `var'="hhmem_type" in `=`n'+1' if `var'[`old']=="form.member_type"
		replace `var'="first_name" in `=`n'+1' if `var'[`old']=="form.name_info.first_name"
		replace `var'="surname" in `=`n'+1' if `var'[`old']=="form.name_info.surname"
		replace `var'="gender" in `=`n'+1' if `var'[`old']=="form.name_info.gender"
		replace `var'="infant_hiv_exposed" in `=`n'+1' if `var'[`old']=="form.health_info.hiv_exposure_status"
		replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.health_info.hiv_status"
		replace `var'="init_done" in `=`n'+1' if `var'[`old']=="form.health_info.hh_art_init_is_done"
		replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.health_info.hh_art_init_done_date"
		replace `var'="enrol_date" in `=`n'+1' if `var'[`old']=="form.client_status.registration_date"
		replace `var'="communityclient" in `=`n'+1' if `var'[`old']=="form.client_status.community_client"
		replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_status.country"
		replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_status.province"
		replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_status.facility"
		replace `var'="community" in `=`n'+1' if `var'[`old']=="form.client_status.community"
		replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
		replace `var'="hhmem_id" in `=`n'+1' if `var'[`old']=="form.subcase_0.case.@case_id"
	}
		
		
	* --> Drop all variables that don't have a new name 
	count
	local n=r(N)
	foreach var of varlist * {
		if missing(`var'[`n']) {
			drop `var'
		}
	}


	* --> Rename all variables 
	count
	foreach var of varlist * {
		ren `var' `=`var'[`n']'
	}
	drop in `n'
	drop in 1
	cap drop savecase* 


	* --> Do generic cleaning
	do "$do_appdata/Generic/0. Generic cleaning.do"

	
	* --> Rename variables to indicate form
	sort id
	qui ds id hhmem_id, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
	
	
	* --> Save
	duplicates drop
	isid hhmem_id
	gen `form'=1
	save "$temp/Firdale/`form'_clean_`c'.dta", replace
	*erase "$temp_appdata/Firdale/App2/`form'/`form'_`c'.dta"
}
