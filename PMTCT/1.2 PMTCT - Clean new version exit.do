*** APR 2020 - PMTCT cascade
*** Firdale cleaning applied to new version exports
* 7 January 2021


local form "exit"
	
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
	replace `var'="exit" in `=`n'+1' if `var'[`old']=="form.close_client"
	replace `var'="exitwhy" in `=`n'+1' if `var'[`old']=="form.close_reason_no_ltfu"
	replace `var'="id" in `=`n'+1' if `var'[`old']=="form.case.@case_id"	
	replace `var'="country" in `=`n'+1' if `var'[`old']=="form.client_info.country"
	replace `var'="facility" in `=`n'+1' if `var'[`old']=="form.client_info.facility"
	replace `var'="province" in `=`n'+1' if `var'[`old']=="form.client_info.province"
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
	duplicates drop
	drop if exit=="no"
		// Drop form entries where the client is not actually exited. Presumably
		// a mistake.
		

	* --> Sort according to most recent form submission
	gsort id -timeend_time 
		// Sort with latest time first, by id


	* --> Identify and drop all but latest form submission for each client
	cap drop dup
	bysort id: gen dup=cond(_N==1,0,_n)
	keep if dup==1 | dup==0
	drop dup
		// Each client kept only once, with their latest exit date if they have
		// multiple.


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

