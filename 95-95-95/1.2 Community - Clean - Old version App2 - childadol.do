*** Firdale versions - App2
*** Clean child-adolescent dataset
* 28 April 2021


local form "childadol"
	
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
		replace `var'="adh_7_forget" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_7_forget"
		replace `var'="adh_7_forget_num" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_7_forget_number"
		replace `var'="adh_remember" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_remember"
		replace `var'="adh_stop_better" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_stop_better"
		replace `var'="adh_stop_worse" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.adherence_stop_worse"
		replace `var'="adh_notadherent" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_questions.not_adherent"
		replace `var'="artrefill_done" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_complete"
		replace `var'="artrefill_due_date" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_due_date"
		replace `var'="artrefill_latest" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_most_recent"
		replace `var'="artrefill_latest_date" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_prev_done_date"
		replace `var'="community" in `=`n'+1' if `var'[`old']=="form.client_info.community"
		replace `var'="communityclient" in `=`n'+1' if `var'[`old']=="form.client_status.community_client"
		replace `var'="condom" in `=`n'+1' if `var'[`old']=="form.family_planning.condom_use"
		replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_info.country"
		replace `var'="deworm_30m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_thirty_month.deworm_thirty_month_done"
		replace `var'="deworm_36m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_thirtysix_month.deworm_thirtysix_month_done"
		replace `var'="deworm_42m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_fortytwo_month.deworm_fortytwo_month_done"
		replace `var'="deworm_48m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_forty_eight_month.deworm_forty_eight_month_done"
		replace `var'="deworm_54m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_fifty_four_month.deworm_fifty_four_month_done"
		replace `var'="deworm_60m_done" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_sixty_month.deworm_sixty_month_done"
		replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_info.dob"
		replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_info.facility"
		replace `var'="fp_method" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_which_method"
		replace `var'="fp_notuse" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_not_using"
		replace `var'="fp_user" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_user"
		replace `var'="gender" in `=`n'+1' if `var'[`old']=="form.client_info.gender"
		replace `var'="hct_done_date" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hct_questions.hct_date"
		replace `var'="hct_result" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hct_questions.hct_result"
		replace `var'="hhmem_id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
		replace `var'="hhmem_type" in `=`n'+1' if `var'[`old']=="form.change_member_type"
		replace `var'="hhmem_type2" in `=`n'+1' if `var'[`old']=="form.client_status.member_type"
		replace `var'="hiv_result" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_result"
		replace `var'="hiv_retest_done_date" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_date"
		replace `var'="hiv_retest_due" in `=`n'+1' if `var'[`old']=="form.hiv_testing.hiv_retest_questions.hiv_retest_due"
		replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.client_status.hiv_status"
		replace `var'="immun_12yr_done" in `=`n'+1' if `var'[`old']=="form.immunization.immun_twelve_year.immun_twelve_year_done"
		replace `var'="immun_60m_done" in `=`n'+1' if `var'[`old']=="form.immunization.immun_sixty_month.immun_sixty_month_done"
		replace `var'="immun_6yr_done" in `=`n'+1' if `var'[`old']=="form.immunization.immun_six_year.immun_six_year_done"
		replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.hh_art_init.hh_art_init_done_date"
		replace `var'="init_done" in `=`n'+1' if `var'[`old']=="form.hh_art_init.hh_art_init_is_done"
		replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_info.province"
		replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
		replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
		replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
		replace `var'="username" in `=`n'+1' if `var'[`old']=="username"
		replace `var'="vita_30m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_thirty_month.vit_a_thirty_month_done"
		replace `var'="vita_36m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_thirtysix_month.vit_a_thirtysix_month_done"
		replace `var'="vita_42m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_fortytwo_month.vit_a_fortytwo_month_done"
		replace `var'="vita_48m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_forty_eight_month.vit_a_forty_eight_month_done"
		replace `var'="vita_54m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_fifty_four_month.vit_a_fifty_four_month_done"
		replace `var'="vita_60m_done" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_sixty_month.vit_a_sixty_month_done"
		replace `var'="vl_result" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_prev_results"
		replace `var'="vl_result_number" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_number"
		replace `var'="vl_test_done" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_referral_complete"
		replace `var'="vl_test_due_date" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_next_date_date_entered"
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
	sort hhmem_id
	qui ds hhmem_id, not
	foreach var of varlist `r(varlist)' {
		ren `var' d`form'_`var'
	}
	
	
	* --> Drop perfect deuplicates and observations with missing id
	duplicates drop
	drop if hhmem_id==""
	
	
	* --> Save cleaned dataset	
	gen `form'=1
	save "$temp/Firdale/`form'_clean_`c'.dta", replace
	*erase "$temp_appdata/Firdale/App2/`form'/`form'_`c'.dta"
}

