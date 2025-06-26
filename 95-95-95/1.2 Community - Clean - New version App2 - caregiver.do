*** New version versions - App2
*** Clean caregiver dataset
* 31 March 2021


local form "caregiver"
	
foreach c in 2020 2021 {

	* --> Open data
	use "$temp_appdata/New version/App2/`form'/`form'_`c'.dta", clear

	
	* --> Identify row with variable name and create new row
	local old=1 
	count
	local n=r(N)
	set obs `=`n'+1' 

	
	* --> Variable names
	foreach var of varlist * {
		replace `var'="adh_7_forget" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_7_forget"
		replace `var'="adh_7_forget_num" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_7_forget_number"
		replace `var'="adh_remember" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_remember"
		replace `var'="adh_stop_better" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_stop_better"
		replace `var'="adh_stop_worse" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_stop_worse"
		replace `var'="adh_notadherent" in `=`n'+1' if `var'[`old']=="form.adherence.not_adherent"
		replace `var'="age" in `=`n'+1' if `var'[`old']=="form.mother_sched.age"
		replace `var'="anc_visits_num" in `=`n'+1' if `var'[`old']=="form.anc.anc1_questions.anc_how_many"
		replace `var'="anc1_visit_done" in `=`n'+1' if `var'[`old']=="form.anc.anc1_questions.anc1_visit_done"
		replace `var'="artrefill_done" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_complete"
		replace `var'="artrefill_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_due_date"
		replace `var'="artrefill_latest" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_most_recent"
		replace `var'="artrefill_latest_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_prev_done_date"
		replace `var'="community" in `=`n'+1' if `var'[`old']=="form.client_info.community"
		replace `var'="communityclient" in `=`n'+1' if `var'[`old']=="form.client_status.community_client"
		replace `var'="condom" in `=`n'+1' if `var'[`old']=="form.family_planning.condom_use"
		replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_info.country"
		replace `var'="delivery" in `=`n'+1' if `var'[`old']=="form.facility_delivery.facility_delivery"
		replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_info.dob"
		replace `var'="edd" in `=`n'+1' if `var'[`old']=="form.anc.gestation_edd.edd"
		replace `var'="enrol_date" in `=`n'+1' if `var'[`old']=="form.client_info.registration_date"
		replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_info.facility"
		replace `var'="fp_method" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_which_method"
		replace `var'="fp_notuse" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_not_using"
		replace `var'="fp_user" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_user"
		replace `var'="hct_done_date" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hct_questions.hct_date"
		replace `var'="hct_result" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hct_questions.hct_result"
		replace `var'="hiv_result" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_result"
		replace `var'="hiv_retest_done_date" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_date"
		replace `var'="hiv_retest_due" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_due"
		replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.client_status.hiv_status"
		replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
		replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_done_date"
		replace `var'="init_done" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_is_done"
		replace `var'="pnc_visits_num" in `=`n'+1' if `var'[`old']=="form.pnc.pnc_other_visits.pnc_how_many"
		replace `var'="pnc1_visit_done" in `=`n'+1' if `var'[`old']=="form.pnc.pnc1_questions.pnc1_visit_done"
		replace `var'="pregnant" in `=`n'+1' if `var'[`old']=="form.mother_sched.is_pregnant"
		replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_info.province"
		replace `var'="risk" in `=`n'+1' if `var'[`old']=="form.risk_assesment.client_risk_assessment"
		replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
		replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
		replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
		replace `var'="type" in `=`n'+1' if `var'[`old']=="form.client_status.client_type"
		replace `var'="username" in `=`n'+1' if `var'[`old']=="username"
		replace `var'="vl_result" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_prev_results"
		replace `var'="vl_result_number" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_number"
		replace `var'="vl_test_done" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_referral_complete"
		replace `var'="vl_test_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_next_due_date_entered"
		replace `var'="wellbeing_confident" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_confident"
		replace `var'="wellbeing_depressed" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_depressed"
		replace `var'="wellbeing_diffs" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_diffculties"
		replace `var'="wellbeing_help" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_want_help"
		replace `var'="wellbeing_nervous" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_nervous"
		replace `var'="wellbeing_nointerest" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_no_interest"
		replace `var'="wellbeing_notcope" in `=`n'+1' if `var'[`old']=="form.mother_well_being.mother_well_not_cope"
		replace `var'="risk_status" in `=`n'+1' if `var'[`old']=="form.risk_assesment.client_risk_assessment"
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
	qui ds id, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
	
	
	* --> Drop perfect deuplicates and observations with missing id
	duplicates drop
	drop if id==""
	
	
	* --> Save cleaned dataset	
	gen `form'=1
	save "$temp/New version/`form'_clean_`c'.dta", replace
	*erase "$temp_appdata/New version/App2/`form'/`form'_`c'.dta"
}

