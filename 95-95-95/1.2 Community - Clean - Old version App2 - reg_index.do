*** Firdale versions - App2
*** Clean index client registration dataset
* 31 March 2021


local form "reg_index"
	
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
	replace `var'="gender" in `=`n'+1' if `var'[`old']=="form.gender"
	replace `var'="firstname" in `=`n'+1' if `var'[`old']=="form.name_info.first_name"
	replace `var'="surname" in `=`n'+1' if `var'[`old']=="form.name_info.surname"
	replace `var'="mother_caregiver" in `=`n'+1' if `var'[`old']=="form.mother_or_caregiver"
	replace `var'="community" in `=`n'+1' if `var'[`old']=="form.household_info.community_name"
	replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.age_info.dob_entered"
	replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.hiv_info.hiv_status"
	replace `var'="init_done" in `=`n'+1' if `var'[`old']=="form.hiv_info.maternal_art_init_is_done"
	replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.hiv_info.maternal_art_init_due_done_date"
	replace `var'="an_pn" in `=`n'+1' if `var'[`old']=="form.health_info.client_type"
	replace `var'="enrol_date" in `=`n'+1' if `var'[`old']=="form.client_status.registration_date"
	replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_status.country"
	replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_status.province"
	replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_status.facility"
	replace `var'="communityclient" in `=`n'+1' if `var'[`old']=="form.client_status.community_client"
	replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
	replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
	replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
	replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
	replace `var'="hhid" in `=`n'+1' if `var'[`old']=="form.client_info.cc_household_id"	
	replace `var'="username" in `=`n'+1' if `var'[`old']=="username"	
	replace `var'="m2mid" in `=`n'+1' if `var'[`old']=="form.household_info.m2m_id"	
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


	* --> Do generic cleaning
	do "$do_appdata/Generic/0. Generic cleaning.do"

	
	* --> Drop perfect duplicates and clients registered more than once
	/*
	This code used to work fine but something funky is happening with Dec 2019
	which is either clients registered twice or somehow my imports overlap
	and the duplicates aren't being dropped because the format of some of the
	dates is different in the 2 observations. So I have added another duplicates
	drop line specifying key variables as 'duplicates drop' by itself and keeping
	the earliest obs doesn't work in cases when not all variables are perfectly
	duplicated and the earliest time is the same.
	*/
	duplicates drop
	egen double timerec_first=min(timerec_time), by(id)
	drop if timerec_time!=timerec_first
	drop timerec_first 
	duplicates drop id facility gender firstname surname, force
	
	
	* --> Rename variables to indicate form
	sort id
	qui ds id, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
	
	
	* --> Save cleaned dataset	
	gen `form'=1
	save "$temp/Firdale/`form'_clean_`c'.dta", replace
	*erase "$temp_appdata/Firdale/App2/`form'/`form'_`c'.dta"
}


