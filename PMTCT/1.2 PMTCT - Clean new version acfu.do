*** APR 2020 - PMTCT cascade
*** Firdale cleaning applied to new version exports
* 7 January 2021


local form "acfu"
	
foreach c in 2020 2021 {

	* --> Open data
	use "$temp_appdata/New version/App1/`form'/`form'_`c'.dta", clear

	* --> Identify row with variable name and create new row
	local old=1 
	count
	local n=r(N)
	set obs `=`n'+1' 

	* --> Variable names
	foreach var of varlist * {
	replace `var'="agreefu" in `=`n'+1' if `var'[`old']=="form.contact_methods.agree_to_acfu"	
	replace `var'="contact" in `=`n'+1' if `var'[`old']=="form.contact_methods.contact_method"	
	replace `var'="status" in `=`n'+1' if `var'[`old']=="form.client_status.client_status"	
	forvalues j=1/3 {
		replace `var'="call`j'" in `=`n'+1' if `var'[`old']=="form.acfu_calls.call_`j'.call_`j'_done_date"	
		replace `var'="call`j'res" in `=`n'+1' if `var'[`old']=="form.acfu_calls.call_`j'.call_`j'_outcome"	
	}
	forvalues s=1/3 {
		replace `var'="sms`s'" in `=`n'+1' if `var'[`old']=="form.acfu_sms.sms_`s'.sms_`s'_done_date"	
		replace `var'="sms`s'res" in `=`n'+1' if `var'[`old']=="form.acfu_sms.sms_`s'.sms_`s'_outcome"	
	}
	forvalues h=1/2 {
		replace `var'="homewho`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_done_by"	
		replace `var'="homecmm`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_assign_cmm.home_visit`h'_assign_current_cmm"	
		replace `var'="homecmmwho`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_assign_cmm.home_visit`h'_cmm_assigned_id_selected"	
		replace `var'="homeref`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_no_cmm.home_visit`h'_referral_date"	
		replace `var'="homeresknow`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_no_cmm.home_visit`h'_outcome_known"	
		replace `var'="homeres`h'" in `=`n'+1' if `var'[`old']=="form.acfu_home_visit.home_visit`h'.home_visit`h'_no_cmm.home_visit`h'_outcome"	
	}
	replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.location.user_facility_name"	
	replace `var'="province" in `=`n'+1' if `var'[`old']=="form.location.user_province_name"	
	replace `var'="country" in `=`n'+1' if `var'[`old']=="form.location.user_country_name"	
	replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
	replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
	replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
	replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"	
	replace `var'="username" in `=`n'+1' if	`var'[`old']=="username"	
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


	* --> Rename facilities to match DHIS2 or to UIDs
	do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	*do "$do_appdata/Generic/0. Rename sites to UIDs.do"
		// Which to use depends on where the data is going to go after
		// analysis - DHIS2 or ad hoc reporting?
		

	* --> Do generic cleaning
	do "$do_appdata/Generic/0. Generic cleaning.do"

	
	* --> Determine best proxy for visit date
	gen diff=timeend_date-timerec_date>7 | timeend_date-timerec_date<-7
	tab diff
	gen after=timeend_date>timerec_date & timeend_date<.
	tab after
	replace timeend_date=timerec_date if after==1
	gen toofar=(timerec_date-timeend_date>30) & (timerec_date-timeend_date<.)
	tab toofar
	*br timeend timerec if toofar==1
	replace timeend_date=timerec_date if toofar==1
	drop toofar diff after

	
	* --> Rename variables to indicate form
	sort id
	qui ds id, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
	
	
	* --> Drop perfect deuplicates and observations with missing id
	duplicates drop
	drop if id==""
}
