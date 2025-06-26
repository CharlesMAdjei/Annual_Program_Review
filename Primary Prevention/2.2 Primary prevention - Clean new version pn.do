*** APR 2020 - Primary prevention
*** Firdale cleaning applied to new version exports
* 9 July 2021


local form "pn"
	
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
		replace `var'="client_is_an" in `=`n'+1' if `var'[`old']=="form.client_is_an"
		replace `var'="return" in `=`n'+1' if `var'[`old']=="form.acfu.patient_returned"
		replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.hiv_status"
		replace `var'="province" in `=`n'+1' if `var'[`old']=="form.location.location_province_name"
		replace `var'="country" in `=`n'+1' if `var'[`old']=="form.location.location_country_name"
		replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.location.user_facility_name"
		replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
		replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
		replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
		replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
		replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_info.dob"	
		replace `var'="hiv_retest_prev_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest_prev.mother_hiv_retest_prev_due_date_entered" 
		replace `var'="hiv_retest_prev_done_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest_prev.mother_hiv_retest_prev_done_date_entered" 
		replace `var'="hiv_retest_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_due_date_entered" 
		replace `var'="hiv_retest_done_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_done_date_entered"
		replace `var'="hiv_retest_next_due_date" in `=`n'+1' if `var'[`old']=="form.mother_hiv_retest.mother_hiv_retest_next_due_date_entered" 
		replace `var'="adherence_update" in `=`n'+1' if `var'[`old']=="form.adherence.adherence_update"
		replace `var'="adh_5pt" in `=`n'+1' if `var'[`old']=="form.adherence.five_point"
		replace `var'="adh_7day" in `=`n'+1' if `var'[`old']=="form.adherence.seven_day_recall"
		replace `var'="pill_count" in `=`n'+1' if `var'[`old']=="form.adherence.pill_count"
		replace `var'="fp_educ" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_educated"
		replace `var'="fp_due" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_is_due_entered"
		replace `var'="fp_due_date" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_due_date_entered"
		replace `var'="fp_done" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_is_done_entered"
		replace `var'="fp_done_date" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_done_date_entered"
		replace `var'="fp_condom" in `=`n'+1' if `var'[`old']=="form.family_planning.condom_usage"
		replace `var'="fp_method" in `=`n'+1' if `var'[`old']=="form.family_planning.family_planning_method_entered"
		replace `var'="infant_sex" in `=`n'+1' if `var'[`old']=="form.infant_info.infant_gender"
		replace `var'="infant_dob" in `=`n'+1' if `var'[`old']=="form.infant_info.infant_dob"
		replace `var'="feed_current" in `=`n'+1' if `var'[`old']=="form.breastfeeding.current_infant_feeding_method"
		replace `var'="bf_ever" in `=`n'+1' if `var'[`old']=="form.breastfeeding.ever_breastfed"
		replace `var'="bf_stop" in `=`n'+1' if `var'[`old']=="form.breastfeeding.breastfeeding_stopped"
		replace `var'="nvp_due" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_is_due_entered"
		replace `var'="nvp_due_date" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_due_date_entered"
		replace `var'="nvp_done" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_is_done_entered"
		replace `var'="nvp_done_date" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_done_date_entered"
		replace `var'="ctx_due" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_is_due_entered"
		replace `var'="ctx_due_date" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_due_date_entered"
		replace `var'="ctx_done" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_is_done_entered"
		replace `var'="ctx_done_date" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_done_date_entered"
		replace `var'="tbirth_test_done_date" in `=`n'+1' if `var'[`old']=="form.birth_pcr.birth_pcr_done_date_entered"
		replace `var'="tbirth_result_done_date" in `=`n'+1' if `var'[`old']=="form.birth_pcr_result.birth_pcr_result_done_date_entered"
		replace `var'="tbirth_result" in `=`n'+1' if `var'[`old']=="form.birth_pcr_result.birth_pcr_result_entered"
		replace `var'="t68wk_test_due_date" in `=`n'+1' if `var'[`old']=="form.six_eight_week_pcr.six_eight_week_pcr_due_date_entered"
		replace `var'="t68wk_test_done_date" in `=`n'+1' if `var'[`old']=="form.six_eight_week_pcr.six_eight_week_pcr_done_date_entered"
		replace `var'="t68wk_result_due_date" in `=`n'+1' if `var'[`old']=="form.six_eight_week_pcr_result.six_eight_week_pcr_result_due_date_entered"
		replace `var'="t68wk_result_done_date" in `=`n'+1' if `var'[`old']=="form.six_eight_week_pcr_result.six_eight_week_pcr_result_done_date_entered"
		replace `var'="t68wk_result" in `=`n'+1' if `var'[`old']=="form.six_eight_week_pcr_result.six_eight_week_pcr_result_entered"
		replace `var'="t10wk_test_done_date" in `=`n'+1' if `var'[`old']=="form.ten_week_pcr.ten_week_pcr_done_date_entered"
		replace `var'="t10wk_result_done_date" in `=`n'+1' if `var'[`old']=="form.ten_week_pcr_result.ten_week_pcr_result_done_date_entered"
		replace `var'="t10wk_result" in `=`n'+1' if `var'[`old']=="form.ten_week_pcr_result.ten_week_pcr_result_entered"
		replace `var'="t14wk_test_done_date" in `=`n'+1' if `var'[`old']=="form.forteen_week_pcr.forteen_week_pcr_done_date_entered"
		replace `var'="t14wk_pcr_status" in `=`n'+1' if `var'[`old']=="form.forteen_week_pcr.save_to_case.forteen_week_pcr_status"
		replace `var'="t14wk_pcr_result_status" in `=`n'+1' if `var'[`old']=="form.copy-1-of-ten_week_pcr_result.save_to_case.forteen_week_pcr_result_status"		
		replace `var'="t14wk_result" in `=`n'+1' if `var'[`old']=="form.copy-1-of-ten_week_pcr_result.forteen_week"
		replace `var'="t9m_test_done_date" in `=`n'+1' if `var'[`old']=="form.nine_month_infant_test.nine_month_infant_test_done_date_entered"
		replace `var'="t9m_result" in `=`n'+1' if `var'[`old']=="form.nine_month_infant_test_result.nine_month_infant_test_result_entered"
		replace `var'="t10m_test_done_date" in `=`n'+1' if `var'[`old']=="form.ten_month_infant_test.ten_month_infant_test_done_date_entered"
		replace `var'="t10m_result" in `=`n'+1' if `var'[`old']=="form.ten_month_infant_test_result.ten_month_infant_test_result_entered"
		replace `var'="t12m_test_done_date" in `=`n'+1' if `var'[`old']=="form.twelve_month_infant_test.twelve_month_infant_test_done_date_entered"
		replace `var'="t12m_result_due_date" in `=`n'+1' if `var'[`old']=="form.twelve_month_infant_test_result.twelve_month_infant_test_result_due_date_entered"
		replace `var'="t12m_result_done_date" in `=`n'+1' if `var'[`old']=="form.twelve_month_infant_test_result.twelve_month_infant_test_result_done_date_entered"
		replace `var'="t12m_result" in `=`n'+1' if `var'[`old']=="form.twelve_month_infant_test_result.twelve_month_infant_test_result_entered"
		replace `var'="t13m_test_done_date" in `=`n'+1' if `var'[`old']=="form.thirteen_month_infant_test.thirteen_month_infant_test_done_date_entered"
		replace `var'="t13m_result" in `=`n'+1' if `var'[`old']=="form.thirteen_month_infant_test_result.thirteen_month_infant_test_result_entered"
		replace `var'="t1824m_test_due_date" in `=`n'+1' if `var'[`old']=="form.eighteen_twentyfour_month_infant_test.eighteen_twentyfour_month_infant_test_due_date_entered"
		replace `var'="t1824m_test_done_date" in `=`n'+1' if `var'[`old']=="form.eighteen_twentyfour_month_infant_test.eighteen_twentyfour_month_infant_test_done_date_entered"
		replace `var'="t1824m_result_due_date" in `=`n'+1' if `var'[`old']=="form.eighteen_twentyfour_month_infant_test_result.eighteen_twentyfour_month_infant_test_result_due_date_entered"
		replace `var'="t1824m_result_done_date" in `=`n'+1' if `var'[`old']=="form.eighteen_twentyfour_month_infant_test_result.eighteen_twentyfour_month_infant_test_result_done_date_entered"
		replace `var'="t1824m_result" in `=`n'+1' if `var'[`old']=="form.eighteen_twentyfour_month_infant_test_result.eighteen_twentyfour_month_infant_test_result_entered"
		replace `var'="infant_init_due_date" in `=`n'+1' if `var'[`old']=="form.infant_art_init.infant_art_init_due_date_entered"
		replace `var'="infant_init_done_date" in `=`n'+1' if `var'[`old']=="form.infant_art_init.infant_art_init_done_date_entered"
		replace `var'="infant_art_prev_due_date" in `=`n'+1' if `var'[`old']=="form.infant_art_refill_prev.infant_art_refill_prev_due_date_entered"
		replace `var'="infant_art_prev_done_date" in `=`n'+1' if `var'[`old']=="form.infant_art_refill_prev.infant_art_refill_prev_done_date_entered"
		replace `var'="infant_art_due_date" in `=`n'+1' if `var'[`old']=="form.infant_art_refill.infant_art_refill_due_date_entered"	
		replace `var'="infant_art_done_date" in `=`n'+1' if `var'[`old']=="form.infant_art_refill.infant_art_refill_done_date_entered"
		replace `var'="infant_art_next_due_date" in `=`n'+1' if `var'[`old']=="form.infant_art_refill.infant_art_refill_next_due_date_entered"		
		replace `var'="init_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_due_date_entered"	
		replace `var'="init_done_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_init.maternal_art_init_done_date_entered"	
		replace `var'="artprevrefill_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill_prev.maternal_art_refill_prev_due_date_entered"	
		replace `var'="artprevrefill_done_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill_prev.maternal_art_refill_prev_done_date_entered"		
		replace `var'="artrefill_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_due_date_entered"	
		replace `var'="artrefill_done_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_done_date_entered"	
		replace `var'="artnextrefill_due_date" in `=`n'+1' if `var'[`old']=="form.maternal_art_refill.maternal_art_refill_next_due_date_entered"	
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
		replace `var'="risk" in `=`n'+1' if	`var'[`old']=="form.client_risk_assessment"	
		replace `var'="name" in `=`n'+1' if `var'[`old']=="form.client_info.name"	
		replace `var'="username" in `=`n'+1' if	`var'[`old']=="username"	
		replace `var'="hhid" in `=`n'+1' if `var'[`old']=="form.client_info.cc_household_id"	
		replace `var'="infant_m2mid" in `=`n'+1' if `var'[`old']=="form.infant_info.infant_m2m_id"	
		replace `var'="m2mid" in `=`n'+1' if `var'[`old']=="form.client_info.m2m_id"
		replace `var'="infant_first_name" in `=`n'+1' if `var'[`old']=="form.infant_info.infant_first_name"
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
