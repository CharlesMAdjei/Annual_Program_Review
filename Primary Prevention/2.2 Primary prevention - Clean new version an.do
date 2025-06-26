*** APR 2020 - Primary prevention
*** Firdale cleaning applied to new version exports
* 18 June 2021


local form "an"
	
foreach c in 2020 {

	* --> Open data
	use "$temp_appdata/New version/App1/`form'/`form'_`c'.dta", clear

	* --> Identify row with variable name and create new row
	local old=1 
	count
	local n=r(N)
	set obs `=`n'+1' 

	* --> Variable names
	foreach var of varlist * {
	replace `var'="client_is_pn" in `=`n'+1' if `var'[`old']=="form.client_is_pn"
	replace `var'="return" in `=`n'+1' if `var'[`old']=="form.acfu.patient_returned"
	replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.hiv_status"
	replace `var'="hiv_retest_prev_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest_prev.mother_hiv_retest_prev_due_date_entered" 
	replace `var'="hiv_retest_prev_done_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest_prev.mother_hiv_retest_prev_done_date_entered" 
	replace `var'="hiv_retest_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_due_date_entered" 
	replace `var'="hiv_retest_done_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_done_date_entered"
	replace `var'="hiv_retest_next_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_next_due_date_entered" 
	replace `var'="adherence_update" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_update"
	replace `var'="adh_5pt" in `=`n'+1' if `var'[`old']=="form.adherence.five_point"
	replace `var'="adh_7day" in `=`n'+1' if `var'[`old']=="form.adherence.seven_day_recall"
	replace `var'="pill_count" in `=`n'+1' if `var'[`old']=="form.adherence.pill_count"
	replace `var'="init_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_due_date_entered"	
	replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_done_date_entered"	
	replace `var'="artrefill_prev_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill_prev.maternal_art_refill_prev_due_date_entered"	
	replace `var'="artrefill_prev_done_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill_prev.maternal_art_refill_prev_done_date_entered"		
	replace `var'="artrefill_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_due_date_entered"	
	replace `var'="artrefill_done_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_done_date_entered"	
	replace `var'="artrefill_next_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_next_due_date_entered"	
	replace `var'="vl_test_prev_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load_prev.viral_load_prev_due_date_entered"	
	replace `var'="vl_test_prev_done_date" in `=`n'+1' if `var'[`old']=="form.viral_load_prev.viral_load_prev_done_date_entered"	
	replace `var'="vl_result_prev_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load_prev_result.viral_load_prev_result_due_date_entered"	
	replace `var'="vl_result_prev_done_date" in `=`n'+1' if `var'[`old']=="form.viral_load_prev_result.viral_load_prev_result_done_date_entered"
	replace `var'="vl_result_prev" in `=`n'+1' if `var'[`old']=="form.viral_load_prev_result.viral_load_prev_result_entered"	
	replace `var'="vl_result_prev_num" in `=`n'+1' if `var'[`old']=="form.viral_load_prev_result.viral_load_prev_level_entered"	
	replace `var'="vl_test_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_due_date_entered"	
	replace `var'="vl_test_done_date" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_done_date_entered"	
	replace `var'="vl_result_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load_result.viral_load_result_due_date_entered"	
	replace `var'="vl_result_done_date" in `=`n'+1' if `var'[`old']=="form.viral_load_result.viral_load_result_done_date_entered"
	replace `var'="vl_result" in `=`n'+1' if `var'[`old']=="form.viral_load_result.viral_load_result_entered"	
	replace `var'="vl_result_num" in `=`n'+1' if `var'[`old']=="form.viral_load_result.viral_load_level_entered"	
	replace `var'="vl_test_next_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load_next.viral_load_next_due_date_entered"
	forvalues i=2(1)4 {
		replace `var'="anvisit`i'_due_date" in `=`n'+1' if `var'[`old']=="form.an`i'.an`i'_due_date_entered"
		replace `var'="anvisit`i'_done_date" in `=`n'+1' if `var'[`old']=="form.an`i'.an`i'_done_date_entered"
		}	
	replace `var'="client_type" in `=`n'+1' if `var'[`old']=="form.status.client_type"
	replace `var'="in_acfu" in `=`n'+1' if `var'[`old']=="form.status.in_acfu"
	replace `var'="next_acfu_date" in `=`n'+1' if `var'[`old']=="form.status.next_acfu_date"
	replace `var'="acfu_status" in `=`n'+1' if `var'[`old']=="form.acfu_fields.acfu_status"
	replace `var'="acfu_returned_date" in `=`n'+1' if `var'[`old']=="form.acfu_fields.acfu_returned_date"
	replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_info.country"
	replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_info.province"
	replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_info.facility"
	replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
	replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
	replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
	replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
	replace `var'="malepartner" in `=`n'+1' if `var'[`old']=="form.case.update.Male_partner"
	replace `var'="name" in `=`n'+1' if `var'[`old']=="form.client_info.name"
	replace `var'="risk" in `=`n'+1' if `var'[`old']=="form.case.update.client_risk_assessment"
	replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_info.dob"	
	replace `var'="m2mid" in `=`n'+1' if `var'[`old']=="form.client_info.m2m_id"	
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
		

	* --> Do generic cleaning
	do "$do_appdata/Generic/0. Generic cleaning.do"

	
	* --> Determine best proxy for visit date
	// See the do file that cleans the new client dataset for an explanation
	// of these steps.
	
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

