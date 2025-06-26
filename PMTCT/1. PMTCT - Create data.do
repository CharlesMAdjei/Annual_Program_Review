*** APR 2020 - PMTCT cascade
*** Create analysis dataset
* 17 Feb 2021

/*
I use the Firdale and new version exports for this analysis. 
Must make sure due date fixes are run (again?) on appended dataset.
*/

/*
foreach form in new an pn acfu exit
*/


*------------------------------------------------------------------------------*
* Import, clean and append Firdale and New version datasets for 2018-2021

* --> Firdale versions 
foreach form in new an acfu exit pn {
	use "$temp_appdata/Firdale/App1/`form'.dta" if d`form'_country == "Ghana", clear
	cap drop form
	gen form="`form'"
	cap drop export
	gen export="Firdale"
	drop if d`form'_timeend_date<$beg_period
	ren d`form'_facility facility
	save "$temp/Firdale - `form'.dta", replace
}


* --> Import new version data and run Firdale cleaning on it so I can append
*	  to data above 
/*
The existing version of the cleaned new version datasets are named to work
with the App1 routine reporting do files. The names used there don't all match
the names used in the Firdale do files so I run the Firdale cleaning do files
on the new version imports.
*/
/*
do "$do/1.1 PMTCT - Import new version data.do"
foreach form in exit new an pn {
	do "$do/1.2 PMTCT - Clean new version `form'.do"
	gen form="`form'"
	gen export="New version"
	ren d`form'_facility facility
	merge m:1 facility using "$temp/pmtct sample facilities - 2 year cohort.dta"
	keep if _merge==3
	drop _merge
	save "$temp/New version - `form'.dta", replace
}
*/

foreach form in new an acfu exit pn {
	use "$temp_appdata/New version/App1/`form'.dta" if d`form'_country == "Ghana", clear
	cap drop form
	gen form="`form'"
	cap drop export
	gen export="New version"
	drop if d`form'_timeend_date<$beg_period
	ren d`form'_facility facility
	save "$temp/New version - `form'.dta", replace
}

* --> Append Firdale and new version for each form
foreach form in exit new an pn {
	use "$temp/Firdale - `form'.dta", clear
	append using "$temp/New version - `form'.dta"
	save "$temp/`form'.dta", replace
	erase "$temp/Firdale - `form'.dta" 
}




*------------------------------------------------------------------------------*
* Drop all but latest form submission for each client in exit form 

*No client exited within the period

use "$temp/exit.dta", clear
gsort id -export 
cap drop dup
bysort id: gen dup=cond(_N==1,1,_n)
keep if dup==1
drop dup
save "$temp/exit_clean.dta", replace




*------------------------------------------------------------------------------*
* Restrict new client data to pos clients who enrolled between 1 Jan-30 Jun 
* 2018 (for 3 yr cohort) and 1 Jan - 30 Jun 2019 (for 2 yr cohort) 

* --> 3 year enrolment cohort
use "$temp/new.dta", clear
ge enrolment_date = date(dnew_enrol_date, "YMD")
format %td enrolment_date
keep if dnew_timeend_date >= $beg_period & dnew_timeend_date <= $end_period
keep if enrolment_date >= $beg_period
tab dnew_hiv_status, m
gen pos=1 if strpos(dnew_hiv_status, "positive")
tab pos
*keep if pos==1
drop pos
	
isid id
save "$temp/new restricted to vitol enrolment.dta", replace
count
	// 6575

*------------------------------------------------------------------------------*
* Merge AN and PN with new client form and reshape
/*
Have to do this separately for the 2 cohorts.
*/

* --> AN data

use "$temp/new restricted to vitol enrolment.dta", clear
merge 1:m id using "$temp/an.dta"
drop if _merge==2
drop _merge
		// Drop women found only in the AN form and not the new client form

assert id!=""
sort id dan_timeend_time
bysort id: gen dup=cond(_N==1,1,_n)

gen dan_timeend_datex=dan_timeend_date if dan_timeend_date<=$end_period
egen timeend_date_tag=tag(id dan_timeend_datex)
egen visits_an=total(timeend_date_tag), by(id)
label var visits_an "Total unique AN form sub dates"

keep id dup dnew* details* dan_timeend* dan_timerec* dan_risk facility ///
		dan_vl* dan_an* dan_init* dan_art* dan_client_is_pn dan_dob  ///
		dan_adh_5pt dan_adh_7day dan_tb_* dan_hiv_status export visits_an
		
ds id dup dnew* details* facility export visits_an, not
local stubs `r(varlist)'
reshape wide `stubs', i(id) j(dup)
gen an="1"
label var an "In AN form"
gen form_type="an"
save "$temp/an_x.dta", replace

	

* --> PN data

use "$temp/new restricted to vitol enrolment.dta", clear
merge 1:m id using "$temp/pn.dta"
drop if _merge==2
drop _merge
		
assert id!=""
sort id dpn_timeend_time
bysort id: gen dup=cond(_N==1,1,_n)

gen dpn_timeend_datex=dpn_timeend_date if dpn_timeend_date<=$end_period
egen timeend_date_tag=tag(id dpn_timeend_datex)
egen visits_pn=total(timeend_date_tag), by(id)
label var visits_pn "Total unique PN form sub dates"

keep id dup dnew* details* dpn_timeend* dpn_timerec* ///
		facility dpn_dob dpn_infant_dob dpn_feed dpn_bf* dpn_fp* ///
		dpn_tbirth* dpn_t68wk* dpn_t10wk* dpn_t14* dpn_t9m* dpn_t10m* ///
		dpn_t12m* dpn_t13m* dpn_t1824m* dpn_infant_init* ///
		dpn_infant_art* dpn_vl* dpn_art* dpn_init* dpn_client_is_an ///
		dpn_ctx* dpn_nvp* dpn_adh_5pt dpn_adh_7day export visits_pn ///
		dpn_tb_* dpn_hiv_status dpn_infant_first_name 
		
ds id dup dnew* details* facility export visits_pn, not
local stubs `r(varlist)'
reshape wide `stubs', i(id) j(dup)
gen pn="1" 
label var pn "In PN form"
gen form_type="pn"
save "$temp/pn_x.dta", replace




*------------------------------------------------------------------------------*
* Merge all forms

use "$temp/an_x.dta", clear
merge 1:1 id using "$temp/pn_x.dta"
drop _merge
merge 1:1 id using "$temp/exit_clean.dta"
drop if _merge==2
drop _merge

ds, has(type string)
local stubs `r(varlist)'
foreach var of varlist `stubs' {
		replace `var'=lower(`var')
		replace `var'=subinstr(`var', "'", "", .)
		replace `var'=subinstr(`var', ".", "", .)
	}

save "$data/vitol_data.dta", replace
	// This isn't the final analysis dataset. The next do file excludes a
	// few more clients based on missing or inconsistent information. The 
	// final dataset is called cohort.



* --> Erase intermediate datasets
foreach form in new an pn exit {
	erase "$temp/`form'.dta"
}
erase "$temp/an_x.dta"
erase "$temp/an_x.dta"
erase "$temp/new restricted to vitol enrolment.dta"



