*** New version versions - App2
*** Clean infant dataset
* 31 March 2021


local form "infant"
	
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
		replace `var'="artrefill_done" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_complete"
		replace `var'="artrefill_due_date" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_due_date"
		replace `var'="artrefill_latest" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_most_recent"
		replace `var'="artrefill_latest_date" in `=`n'+1' if `var'[`old']=="form.hh_art_refill.hh_art_refill_prev_done_date"
		replace `var'="birthcert_date" in `=`n'+1' if `var'[`old']=="form.birth_reg.birth_registration_date"
		replace `var'="birthcert" in `=`n'+1' if `var'[`old']=="form.birth_reg.birth_registration_done"
		replace `var'="community" in `=`n'+1' if `var'[`old']=="form.client_info.community"
		replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_info.country"
		replace `var'="ctx_done" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_init_is_done"
		replace `var'="ctx_done_date" in `=`n'+1' if `var'[`old']=="form.infant_ctx.infant_ctx_init_date"
		replace `var'="deworm_12m" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_twelve_month.deworm_twelve_month_done"
		replace `var'="deworm_18m" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_eighteen_month.deworm_eighteen_month_done"
		replace `var'="deworm_24m" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_twentyfour_month.deworm_twentyfour_month_done"
		replace `var'="deworm_6m" in `=`n'+1' if `var'[`old']=="form.deworming.deworm_six_month.deworm_six_month_done"
		replace `var'="dob" in `=`n'+1' if `var'[`old']=="form.client_info.dob"
		replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_info.facility"
		replace `var'="feeding_practice" in `=`n'+1' if `var'[`old']=="form.infant_feeding.infant_feeding_practice"
		replace `var'="gender" in `=`n'+1' if `var'[`old']=="form.client_info.gender"
		replace `var'="growth_10wk" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_ten_weeks.growth_monitoring_ten_weeks_curve"
		replace `var'="growth_12m" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_twelve_months.growth_monitoring_twelve_months_curve"
		replace `var'="growth_14wk" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_fourteen_weeks.growth_monitoring_fourteen_weeks_curve"
		replace `var'="growth_18m" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_eighteen_months.growth_monitoring_eighteen_months_curve"
		replace `var'="growth_6m" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_six_months.growth_monitoring_six_months_curve"
		replace `var'="growth_6wk" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_six_weeks.growth_monitoring_six_weeks_curve"
		replace `var'="growth_9m" in `=`n'+1' if `var'[`old']=="form.growth_monitoring.growth_monitoring_nine_months.growth_monitoring_nine_months_curve"
		replace `var'="hhmem_id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"
		replace `var'="hiv_status" in `=`n'+1' if `var'[`old']=="form.member_sched.member_profile"
		replace `var'="immun_10wk" in `=`n'+1' if `var'[`old']=="form.immunization.immun_ten_week.immun_ten_week_done"
		replace `var'="immun_12m" in `=`n'+1' if `var'[`old']=="form.immunization.immun_twelve_month.immun_twelve_month_done"
		replace `var'="immun_14wk" in `=`n'+1' if `var'[`old']=="form.immunization.immun_fourteen_week.immun_fourteen_week_done"
		replace `var'="immun_18m" in `=`n'+1' if `var'[`old']=="form.immunization.immun_eighteen_month.immun_eighteen_month_done"
		replace `var'="immun_6m" in `=`n'+1' if `var'[`old']=="form.immunization.immun_six_month.immun_six_month_done"
		replace `var'="immun_6wk" in `=`n'+1' if `var'[`old']=="form.immunization.immun_six_week.immun_six_week_done"
		replace `var'="immun_9m" in `=`n'+1' if `var'[`old']=="form.immunization.immun_nine_month.immun_nine_month_done"
		replace `var'="immun_birth" in `=`n'+1' if `var'[`old']=="form.immunization.immun_birth.immun_birth_done"
		replace `var'="init_date" in `=`n'+1' if `var'[`old']=="form.hh_art_init.hh_art_init_done_date"
		replace `var'="init_done" in `=`n'+1' if `var'[`old']=="form.hh_art_init.hh_art_init_is_done"
		replace `var'="muac_done" in `=`n'+1' if `var'[`old']=="form.muac.muac_is_done"
		replace `var'="muac_result" in `=`n'+1' if `var'[`old']=="form.muac.muac_result"
		replace `var'="muac_treat" in `=`n'+1' if `var'[`old']=="form.muac.muac_rx"
		replace `var'="nvp_done" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_init_is_done"
		replace `var'="nvp_done_date" in `=`n'+1' if `var'[`old']=="form.infant_nvp.infant_nvp_date_initiation"
		replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_info.province"
		replace `var'="timeend" in `=`n'+1' if `var'[`old']=="completed_time"
		replace `var'="timerec" in `=`n'+1' if `var'[`old']=="received_on"
		replace `var'="timestart" in `=`n'+1' if `var'[`old']=="started_time"
		replace `var'="username" in `=`n'+1' if `var'[`old']=="username"
		replace `var'="vita_12m" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_twelve_month.vit_a_twelve_month_done"
		replace `var'="vita_18m" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_eighteen_month.vit_a_eighteen_month_done"
		replace `var'="vita_24m" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_twentyfour_month.vit_a_twentyfour_month_done"
		replace `var'="vita_6m" in `=`n'+1' if `var'[`old']=="form.vitamin_a.vit_a_six_month.vit_a_six_month_done"
		replace `var'="vl_ref_date" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_referral_date"
		replace `var'="vl_result" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_prev_results"
		replace `var'="vl_number" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_number"
		replace `var'="vl_test_done" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_referral_complete"
		replace `var'="vl_test_next_due" in `=`n'+1' if `var'[`old']=="form.viral_load.viral_load_next_date_date_entered"
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
	
	
	* --> Drop observations with missing hhmem_id
	drop if hhmem_id==""
	
	
	* --> Save cleaned dataset	
	gen `form'=1
	save "$temp/New version/`form'_clean_`c'.dta", replace
	*erase "$temp_appdata/New version/App2/`form'/`form'_`c'.dta"
}

