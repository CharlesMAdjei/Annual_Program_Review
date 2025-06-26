*** APR 2020 - PMTCT cascade
*** Identify final cohorts
* 17 February 2021

/*
Clients that are removed from the sample in this do file include:
	- Only in new client form (i.e. have no AN or PN forms)
	- First AN or PN form submission was before new client form submission
	- Missing DOB and age (need to know age at enrolment)
	- Age is implausible (<10 or >60 at enrolment)
	- Infant has more than 1 DOB and the gap between earliest and latest is
	  more than 2 months.
*/



* --> Loop over both cohorts



*------------------------------------------------------------------------------*
* Open dataset and rename form prefixes to variables

use "$data/vitol_data.dta", clear
cap drop *__00*

foreach x in new an pn exit { 
	ren d`x'* `x'*
}
	
	


*------------------------------------------------------------------------------*
* Facility and country
	// Create single variable for all clients taken from new client form
	
drop exit_country
ren new_country country
assert country!=""
assert facility!=""
count
	// 2yr: 8559
	// 3yr: 5190
	



	
*------------------------------------------------------------------------------*
* Month of form submission and receipt dates
/*
Not sure if these variables are needed this year but kept this in in case.
*/

drop ?n_timeend_datex*
foreach x in an pn { 
	 ds `x'_timeend_date*		
	 local nvars: word count `r(varlist)'
	 forvalues z=1/`nvars' {
		gen double `x'_timeend_month`z'=mofd(`x'_timeend_date`z')
		label var `x'_timeend_month`z' ///
			"Month when `x' form was submitted, for obs `z'"
	}
}

foreach x in new exit {
	gen double `x'_timeend_month=mofd(`x'_timeend_date)
	label var `x'_timeend_month "Month when `x' form was submitted"
}	

format %tm *_timeend_month*
	

	
	
*------------------------------------------------------------------------------*
* First and last form submission within each form and across forms

* --> First and most recent form submission (as proxy for visit) within
*	  each form
foreach x in an pn {
	egen double first_timeend_date`x'=rowmin(`x'_timeend_date*)
	label var first_timeend_date`x' "First `x' form submission date"
	
	egen double mostrecent_timeend_date`x'=rowmax(`x'_timeend_date*)
	label var mostrecent_timeend_date`x' "Most recent `x' form submission date"
	format %d first_timeend_date`x' mostrecent_timeend_date`x'
}
	
foreach x in new exit {
	gen double first_timeend_date`x'=`x'_timeend_date
	label var first_timeend_date`x' "First `x' form submission date"
	gen double mostrecent_timeend_date`x'=`x'_timeend_date
	label var mostrecent_timeend_date`x' "Most recent `x' form submission date"
	format %d first_timeend_date`x' mostrecent_timeend_date`x'
}
	// There is only 1 form submission per client in each of these forms so
	// this is redundant but I do it so that we have the same variables across
	// all forms.
	

* --> First and most recent form submission across all forms
	// Don't include exit form because that isn't representative of a visit
egen double first_timeend_date=rowmin(first_timeend_datenew ///
	first_timeend_datean first_timeend_datepn)
egen double mostrecent_timeend_date=rowmax(mostrecent_timeend_datenew ///
	mostrecent_timeend_datean mostrecent_timeend_datepn)
format %td first_timeend* mostrecent_timeend*


* --> Identify clients with an AN or PN form submission before new form sub.
/*
assert first_timeend_date==first_timeend_datenew
br id country facility first_timeend_date* if ///
	first_timeend_date!=first_timeend_datenew
*/
	// First form submission date must be in new client form

drop if first_timeend_date!=first_timeend_datenew
	// 18 weird cases of an AN or PN form coming before the new client form.
	

* --> Identify clients who only appear in new client form
count if first_timeend_datean==.
count if first_timeend_datepn==.
count if first_timeend_datean==. & first_timeend_datepn==.
/*
sort country facility
br country facility an* pn* if ///
	first_timeend_datean==. & first_timeend_datepn==.
*/
	// 347 women never have either AN or PN form submitted. Drop them as
	// have no information on even their first visit. First count number per
	// facility so can report on them.
	
gen new_onlyx=first_timeend_datean==. & first_timeend_datepn==.
egen new_only=total(new_onlyx), by(facility)
label var new_only "Count of clients per facility found only in new client form"
tab new_only
gen x=1
egen total=total(x), by(facility)
label var total "Count of all clients per facility"

/*
* Comment out to save time
preserve
egen fac_tag=tag(facility)
keep if fac_tag==1 
sort country facility
keeporder country facility total new_only
export excel using ///
	"$output/Checks/Clients found only in registration form ($S_DATE).xlsx", ///
	firstrow(varlabels) replace
restore
*/

drop if new_onlyx==1
drop new_only* total 
count
	// 8194
	// 5091


	
	
*------------------------------------------------------------------------------*
* Maternal DOB and age
	// Take this from new client form
	
* --> DOB from new client form
foreach x in new {
	gen dob=date(`x'_dob, "YMD") 
	replace dob=date(`x'_dob, "DMY") if dob==.
	format %d dob
}
count if dob==.


* --> Age from new client form - use to fill in DOB
ren new_age age
destring age, replace force
replace age=. if age>60
count if dob==. & age!=.
gen dob_miss=dob==.
label var dob_miss "DOB missing in original data"
	
replace dob=first_timeend_date-(365.25*age) if dob==. & age!=.
format %d dob 
label var dob "Maternal DOB (incl. calc DOB based on age)"
tab dob if dob_miss==1
count if dob==.
drop if dob==.
	// Only 1 woman missing DOB now when deduce DOB from age captured in new
	// client form. Remove from sample as we do analysis by age of the mother.


* --> Populate age for all women (age at beginning of period)
replace age=(first_timeend_date-dob)/365.25  if age==.
replace age=round(age, 1)
label var age "Maternal age at first visit"
tab age if age<10 | age>60
tab dob if age<10 | age>60
tab an_dob1 if age<10 | age>60
tab pn_dob1 if age<10 | age>60
drop if age<10 | age>60
	// Drop another 9 clients where the age is totally whack & can't fix it.

*drop ?n_dob? ?n_dob?? new_dob* dob_miss


	

*------------------------------------------------------------------------------*



* Infant DOB

* --> Identify infant's DOB from most recent entry in the PN form
gen infant_dob=.
ds pn_timeend_date*
local nvars: word count `r(varlist)'
local nvars=`nvars'
di `nvars'
forvalues i=1/`nvars' {
	gen infant_dob`i'=date(pn_infant_dob`i', "YMD") 
	replace infant_dob`i'=date(pn_infant_dob`i', "DMY") if infant_dob`i'==.
	la var infant_dob`i' "Infant date of birth in obs `i'"
	forvalues j=1/`nvars'{
		replace infant_dob=infant_dob`i' if ///
			pn_timeend_date`i'>=pn_timeend_date`j' & ///
			pn_timeend_date`i'<. & ///
			infant_dob`i'!=.			
	}
}
format %d infant_dob
label var infant_dob "Infant's DOB from most recent PN form submitted in App1"



* --> Check for cases where client has more than 1 infant DOB in PN form
egen infant_dob_min=rowmin(infant_dob? )
egen infant_dob_max=rowmax(infant_dob? )
format %d infant_dob*
gen infant_dob_diff=infant_dob_max-infant_dob_min
label var infant_dob_diff "Diff between infant DOBs recorded in PN form in app1"
tab infant_dob_diff
count if infant_dob_min!=infant_dob_max
count if infant_dob_diff>62 & infant_dob_diff<.
	// 317 infants have more than 1 DOB; 139 of these infants have more than 2
	// months between the DOBs.

/*
gsort -infant_dob_diff
br infant_dob infant_dob_m* infant_dob_diff ///
	infant_dob? infant_dob?? ///
	if infant_dob_min!=infant_dob_max
*/

drop if infant_dob_diff>62 & infant_dob_diff<.
count if infant_dob!=.
count if infant_dob_diff>0 & infant_dob_diff<.
	// Drop clients where there is more than a 2 month gap between infant
	// DOBs recorded in PN form. For the rest, take the DOB recorded in their
	// most recent PN form submission. There are only 87 infants with more
	// than 1 DOB out of 3444 in total.

count if infant_dob==. & first_timeend_datepn!=.
	// 164 PN clients are missing an infant DOB.
	
drop pn_infant_dob* infant_dob_* infant_dob? //infant_dob??
label var infant_dob "Infant DOB"

*has a child
ds pn_infant_first_name* 	
local nvars: word count `r(varlist)'
forvalues x=1/`nvars' {
	gen has_child_`x'=1 if !missing(pn_infant_first_name`x') 
}
egen has_child = anymatch(has_child_*	), values(1)
replace has_child = 1 if has_child == 0 & infant_dob != .

drop has_child_* pn_infant_first_name*

	
*------------------------------------------------------------------------------*
* Replace timeend dates with missing if there are 2+ obs with the same 
* timeend dates as this should only count as a single visit. 
/*
This deals with the issue of multiple forms being submitted on 1 day. 
*/

/*
*--------------*
This code was in APR 2019 do file 4. I don't think it's needed anymore. For the
number of visits, just count the unique form sub dates, not the number of
forms submitted. That still doesn't get over the issue of forms being submitted
when a visit isn't actually taking place, but at least means multiple submissions
on the same day won't be skewing numbers.

As for replacing variable values with the most recent form submitted on that
day, I don't think we need that for this analysis since we are just taking any
done date as indication of the service being done.

The code below doesn't work on this data currently (early Jan 2021) so if I
decide that I do need it for some reason, I will have to make it work.	
*--------------*


ren pn_t10wk* pn_tenwk*
ren pn_t10m* pn_ttenm*
	// Need to rename these because of code in the loop.

* --> A looong loop with many steps...
/*
I still don't understand why we need the suffix step but it works and it's
necessary so...
*/

save "$data/cohort.dta", replace


foreach x in an pn { 			
	use "$data/cohort.dta", clear	
	
	preserve 
	cap drop dup
	keep id `x'_* 
		// Keep only the variables in the form being dealt with
		
	* Reshape all variables that have the suffixes of 1, 2, etc
	unab varlist: *10
			// Unab creates a list of variables for all vars that end in 10, 
			// saved in "`varlist'". unab is needed because it allows the 
			// use of wildcards (and the command ", not") when creating locals 
			// consisting of a list of variables in a dataset.
			
	local varlist: subinstr local varlist "10" "", all		
			// Create a new list where 10s are replaced with blank so that the 
			// reshape works.

	reshape long `varlist', i(id) j(dup)					
	ds id dup `x'_*, not									
		// We want a local that contains all variables except id, dup and the 
		// created date variables.
		
	unab varlist: `r(varlist)'							
		// Local from above line of code

	gsort id `x'_timeend_date -`x'_timeend_time		
		// Sort the data by id, then by date, and then by time so that the 
		// latest time appears first within that group. 
		
	foreach y in `varlist' {
		by id `x'_timeend_date: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")	
			// If an entry is "" or "---", replace that entry with the line 
			// just below if it is of the same ID and date. The latest time 
			// will be first row as per line above. In other words, the latest
			// entry is taken unless it is missing, in which case the earlier
			// entries are progressively taken if it is still missing.
	}

	* If client is seen more than once on the same day, only keep the date entry 
	* with the latest time entry. The rest are replaced as missing.
	by id `x'_timeend_date: gen tag=cond(_N==1,1,_n) 
		// Identify clients with visits on the same day; For example: if 
		// observation 1 and observation 2 have the same id and the same 
		// timeenddate, then tag will be 1 for observation 1 and 2 for 
		// observation 2. Conversely, if we have observation 1 and 2 with the
		// same id but different dates, then both observations will have tag  
		// 1. Missing dates will get tagged, but it's OK as they get replaced 
		// with missing later.
														 
	replace `x'_timeend_date=. if tag>1		
		// Keep only one of the dates per duplicate dates within ID, with the 
		// date with the latest time kept as is. 
		
	drop tag
	
	* Merge back into the master dataset
	ds id dup, not
	unab varlist: `r(varlist)'
	reshape wide `varlist', i(id) j(dup)
	tempfile `x'_dupfree
	save ``x'_dupfree'
	restore
	drop d`x'_* `x'_*						
		// To replace all old variables with the new 
		
	cap drop _merge
	merge 1:1 id using ``x'_dupfree'		
		// Merge in the cleaned data
		
	format `x'_timeend_date* %td
	drop _merge 
	
	* Replace other timeend variables with missing if timeenddate is missing
	ds d`x'_timeend*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		replace `x'_timeend`i'=. if `x'_timeend_date`i'==.	
		replace `x'_timeend_month`i'=. if `x'_timeend_date`i'==.	
	}
	
	save "$data/cohort.dta", replace
	sleep 200
}
cap drop __000*
*/



*------------------------------------------------------------------------------*
* PMTCT cohort dataset
/*
Women in the sample must have been positive at enrolment (known or tested pos
in the new client form), as well as have a valid age. They must also have
at least one AN or PN form submission in addition to the new client form.
*/

save "$data/vitol_cohort.dta", replace
count
	// 8048
	

