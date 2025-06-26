*** APR 2020 - PMTCT cascade
*** Firdale cleaning applied to new version exports
* 7 January 2021


local form "new"
	
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
	replace `var'="details_surname" in `=`n'+1' if `var'[`old']=="form.info.surname"
	replace `var'="details_first_name" in `=`n'+1' if `var'[`old']=="form.info.first_name"
	replace `var'="details_m2m_id" in `=`n'+1' if `var'[`old']=="form.info.m2m_id"
	replace `var'="details_national_id" in `=`n'+1' if `var'[`old']=="form.info.national_id"
	replace `var'="details_number_anc" in `=`n'+1' if `var'[`old']=="form.info.number_anc"
	replace `var'="details_physical_address" in `=`n'+1' if `var'[`old']=="form.info.physical_address"
	replace `var'="details_phone_number" in `=`n'+1' if `var'[`old']=="form.info.phone_number_entered"
	replace `var'="gender" in `=`n'+1' if `var'[`old']=="form.gender"
	replace `var'="preg_lac" in `=`n'+1' if `var'[`old']=="form.is_this_women_pregnant_or_lactating"
	replace `var'="enrol_date" in `=`n'+1' if `var'[`old']=="form.info.m2m_enrollment_date"
	replace `var'="has_partner" in `=`n'+1' if `var'[`old']=="form.info.has_partner"
	replace `var'="partner_status" in `=`n'+1' if `var'[`old']=="form.info.partner_hiv_status"
	replace `var'="m2m_before" in `=`n'+1' if `var'[`old']=="form.info.m2m_before"
	replace `var'="m2m_before_num" in `=`n'+1' if `var'[`old']=="form.info.m2m_how_many_times"
	replace `var'="edd" in `=`n'+1' if `var'[`old']=="form.info.edd"
	replace `var'="gestage_units" in `=`n'+1' if `var'[`old']=="form.info.gestation_m2m.gestation_m2m_units"
	replace `var'="gestage_m2m" in `=`n'+1' if `var'[`old']=="form.info.gestation_m2m.gestation_first_m2m_entered"
	replace `var'="gestage_anc1" in `=`n'+1' if `var'[`old']=="form.info.gestation_m2m.gestation_first_anc_entered"
	replace `var'="dob_known" in `=`n'+1' if `var'[`old']=="form.info.dob_known"
	replace `var'="age" in `=`n'+1' if `var'[`old']=="form.info.client_age"
	replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.info.dob_entered"
	replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.info.hiv_status"
	replace `var'="already_on_art" in `=`n'+1' if `var'[`old']=="form.info.maternal_art_init_is_done_at_reg"
	replace `var'="art_number" in `=`n'+1' if `var'[`old']=="form.info.number_art"
	replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.info.maternal_art_init_due_done_date"
	replace `var'="country" in `=`n'+1' if `var'[`old']=="form.info.country"
	replace `var'="province" in `=`n'+1' if `var'[`old']=="form.info.province"
	replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.info.facility"
	replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
	replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
	replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
	replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
	replace `var'="username" in `=`n'+1' if	`var'[`old']=="username"	
	replace `var'="programme" in `=`n'+1' if	`var'[`old']=="form.program"	
	replace `var'="client_type" in `=`n'+1' if	`var'[`old']=="form.info.client_type"	
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


	* --> Rename facilities to match DHIS2 or to UIDs
	do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	*do "$do_appdata/Generic/0. Rename sites to UIDs.do"
		// Which to use depends on where the data is going to go after
		// analysis - DHIS2 or ad hoc reporting
		

	* --> Do generic cleaning
	do "$do_appdata/Generic/0. Generic cleaning.do"

	
	* --> Drop perfect duplicates and clients registered more than once
	duplicates drop
	egen double timerec_first=min(timerec_date), by(id)
	drop if timerec_date!=timerec_first
	drop timerec_first 


	* --> Determine best proxy for visit date
	// Generally we take timeend, also called completed in other analyses, as
	// the visit date. Timeend if the completed time of the form according to 
	// the device time settings, while timerec is the time the server received 
	// the data. There can be a delay between form entry and receipt by server 
	// so in general the completed time is taken to be the date of the visit. 
	// However, sometimes the device has a whack date in which case time 
	// received should be used. Going to use discretion here - use timeend as 
	// visit date unless it is at a later date than timerec, or more than 1 
	// month before timerec.
	
	gen diff=timeend_date-timerec_date>7 | timeend_date-timerec_date<-7
	tab diff
	/*
	sort timeend_date timerec_date
	br timeend_date timerec_date if diff==1
	*/
	gen after=timeend_date>timerec_date & timeend_date<.
	tab after
		// These are the observations where the form completion date is after
		// the form receipt date, which definitely means the date on the
		// device is wrong.
		
	replace timeend_date=timerec_date if after==1
	gen toofar=(timerec_date-timeend_date>30) & (timerec_date-timeend_date<.)
	tab toofar
	*br timeend timerec if toofar==1
	replace timeend_date=timerec_date if toofar==1
	drop toofar diff after
		// These are cases where the difference between the two is more than
		// 30 days. In these cases, we go with the time the form was received
		// by the server as opposed to the time completed according to the
		// device.


	* --> Rename variables to indicate form
	sort id
	qui ds id details*, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
}

