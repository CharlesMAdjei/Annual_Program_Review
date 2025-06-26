*** APR 2020 - Primary prevention
*** Create dataset for analysis
* 9 July 2021




*------------------------------------------------------------------------------*
* Import, clean and append Firdale and New version datasets for 2016-2020

* --> Firdale versions 
/*
For Firdale, I don't import and append the raw exports, or run the basic 
cleaning, here because the datasets already exist in the App data folder for
other analyses and it would waste a lot of time. Any changes like including
additional variables would have to be added to the cleaning do files in the
folder '\App data\Do files\Firdale\App1'
*/

foreach form in new an pn {
	use "$temp_appdata/Firdale/App1/`form'.dta", clear
	ren d`form'_facility facility
	*do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	cap drop form
	gen form="`form'"
	cap drop export
	gen export="Firdale"
	drop if d`form'_timeend_date<$beg_enrol
	merge m:1 facility using "$temp/primary prevention facilities.dta"
	keep if _merge==3
	drop _merge
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

foreach form in new an pn {
	use "$temp_appdata/New version/App1/`form'.dta", clear
	ren d`form'_facility facility
	*do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	cap drop form
	gen form="`form'"
	cap drop export
	gen export="Firdale"
	drop if d`form'_timeend_date<$beg_enrol
	merge m:1 facility using "$temp/primary prevention facilities.dta"
	keep if _merge==3
	drop _merge
	save "$temp/New version - `form'.dta", replace
}

* --> Append Firdale and new version for each form
foreach form in new an pn {
	use "$temp/Firdale - `form'.dta", clear
	append using "$temp/New version - `form'.dta"
	save "$temp/`form'.dta", replace
	erase "$temp/Firdale - `form'.dta" 
}




*------------------------------------------------------------------------------*
* Drop forms submitted before start month per site

foreach form in new an pn {
	use "$temp/`form'.dta", clear
	drop if d`form'_timeend_date<start_month
	save "$temp/`form'.dta", replace
	sleep 20
}




*------------------------------------------------------------------------------*
* Drop clients registered more than once
/*
This will drop clients with more than 1 child, which is what Jude did in his
analysis, as well as dropping those registered more than once by mistake, which
I think is also what Jude did, and is the correct thing to so since we don't
know which entry is correct and don't want to include the same client multiple
times. It also isn't too many clients.
*/

use "$temp/new.dta", clear

* --> Client's DOB
/*
I calculate DOB so I can use it as one of the variables to use to identify
duplicate registrations
*/
gen dob=date(dnew_dob, "YMD")
replace dob=date(dnew_dob, "DMY") if dob==.
format %d dob

destring dnew_age, gen(age)
	// Only going to check for valid DOBs and age in the cleaning do file
	
gen dob_calc=dnew_timeend_date-(age*365)
format %d dob_calc
count if dob==. & dob_calc!=.

replace dob=dob_calc if dob==.
count if dob==.

duplicates tag facility details_first details_surname dob, gen(d)
tab d
/*
sort facility details_first details_surname d
br facility d dnew_timeend_date details* dob if d>=1
*/
drop if d>=1
drop d

save "$temp/new.dta", replace
count
	// 151266 clients 
	



*------------------------------------------------------------------------------*
* Drop clients enrolled after 30 June 2021

use "$temp/new.dta", clear
drop if dnew_timeend_date>td(30jun2021)
codebook dnew_timeend_date
save "$temp/new.dta", replace
count
	// 118539 clients
	
	


*------------------------------------------------------------------------------*
* Merge new client form with AN and PN forms and drop clients not HIV-neg at 
* enrolment in each dataset
/*
This restricts the datasets to clients marked as HIV negative in the new client
form. I was using this originally but need to generate a few tables that also
include positives for the first few slides in the powerpoint so it's actually
the dataset below that I use for the analysis.
*/

* --> New
use "$temp/new.dta", clear
drop form
tab dnew_hiv_status, m
keep if dnew_hiv_status=="negative"
*gen dataset=0
*label var dataset "0=New client, 1=AN, 2=PN"
save "$temp/new_hivneg.dta", replace
isid id
count
	// 70437 clients


* --> AN
use "$temp/new_hivneg.dta", clear
merge 1:m id using "$temp/an.dta"
keep if _merge==3
	// Keep clients found in both new and AN datasets
	
gen dataset=1
label var dataset "0=New client, 1=AN, 2=PN"
drop _merge
save "$temp/an_hivneg.dta", replace
	

* --> PN
use "$temp/new_hivneg.dta", clear
merge 1:m id using "$temp/pn.dta"
keep if _merge==3
gen dataset=2
label var dataset "0=New client, 1=AN, 2=PN"
drop _merge
save "$temp/pn_hivneg.dta", replace




*------------------------------------------------------------------------------*
* Merge new client form with AN and PN forms incl. ALL clients

* --> Merge new and AN
use "$temp/new.dta", clear
merge 1:m id using "$temp/an.dta"
keep if _merge==3
	// Keep clients found in both new and AN datasets. Note that I drop
	// those found only in the new client dataset because this is in line
	// with the other APR analyses and because this analysis is only conducted
	// on clients with at least 2 visits.
	
gen dataset=1
label var dataset "0=New client, 1=AN, 2=PN"
drop _merge
save "$temp/new_an.dta", replace
	

* --> PN
use "$temp/new.dta", clear
merge 1:m id using "$temp/pn.dta"
keep if _merge==3
gen dataset=2
label var dataset "0=New client, 1=AN, 2=PN"
drop _merge
save "$temp/new_pn.dta", replace




*------------------------------------------------------------------------------*
* Create fully appended dataset - HIV negative clients only

* --> Append AN and PN
use "$temp/an_hivneg.dta", clear
append using "$temp/pn_hivneg.dta"
	// Since I am creating the dataset with these two datasets, I am only
	// including clients found in at least 1 of the AN or PN forms in addition 
	// to the new client form.
	

* --> Simpler unique id and tag each id
egen id_simple=group(id)
egen id_tag=tag(id)
tab id_tag
	// 69417 clients
		
	
* --> Save dataset
save "$temp/an_pn_neg.dta", replace




*------------------------------------------------------------------------------*
* Create fully appended dataset - all clients

* --> Append AN and PN
use "$temp/new_an.dta", clear
append using "$temp/new_pn.dta"
	

* --> Simpler unique id and tag each id
egen id_simple=group(id)
egen id_tag=tag(id)
tab id_tag
	// 156,631 clients
		
	
* --> Save dataset
save "$temp/an_pn_all.dta", replace


