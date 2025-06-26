*** APR 2019 - ECD
*** Cleaning and variable creation
* 13 June 2020


/*
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Restrict each dataset to relevant time period and facilities
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

/*
These datasets have been imported, appended and cleaned using the do files
'2a. App2 Clare - Import and append' and '2b. App2 Clare - Cleaning'.
This section keeps Kenya and Malawi, April-Dec 2019.
*/

foreach folder in caregiver infant eid devmile childadol reg_index reg_hhmem {
	use "$temp_appdata/Clare/`folder'.dta", clear
	keep if country=="Kenya" | country=="Malawi"
	do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	
	foreach var of varlist completed received {
		gen `var'_time=clock(`var', "YMDhms")
		format %tc `var'_time
		label var `var'_time "Form `var' date and time"

		gen `var'1=date(`var',"YMDhms")
		drop `var'
		ren `var'1 `var'
		format %d `var' 
		label var `var' "Form `var' date"
	}

	keep if completed>=$beg_period & completed<=$end_period
	merge m:1 facility using "$ecd/Input/ecd_sample.dta"
	keep if _merge==3
	drop _merge
	save "$temp/`folder'.dta", replace
}

*/



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* HH member registration 
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*
/*
Need this dataset for the enrolment date as well as the index client's case id, 
in order to match infant to mother. 
*/

use "$temp/reg_hhmem.dta", clear
set sortseed 1

label def status_lab 0"Negative" 1"Positive" 2"Unknown"
label def sex_lab 0"Female" 1"Male"
label def yesnounk 0"No" 1"Yes" 2"Unknown"

ren housemem_caseid hhmem_id
label var hhmem_id "HH member ID"
isid hhmem_id

ren caseid index_id
label var index_id "Index client ID"

keep if reg_housemem1=="infant" 
gen infant=1
	// Keep infants only

	


*------------------------------------------------------------------------------*
* Dates
/*
There are lots of DOB variables. I go with housemem4 which seems to always
be populated while the others aren't (but when they are populated, they seem
to always be the same).
*/

ren reg_housemem4 infant_dob
label var infant_dob "Infant's DOB"
ren completed enrolment_date
label var enrolment_date "Enrolment date"
ren reg_housemem21 artstart_date_hhmemreg
label var artstart_date_hhmemreg "ART start date (reg hh member form)"

foreach var of varlist infant_dob artstart_date_hhmemreg {
	gen `var'1=date(`var',"YMD")
	replace `var'1=date(`var',"DMY") if `var'1==.
	_crcslbl `var'1 `var'
	drop `var'
	ren `var'1 `var'
	format %d `var' 
}




*------------------------------------------------------------------------------*
* Sex

cap drop sex*
gen hhmem_sex=.
replace hhmem_sex=reg_housemem10=="male" if reg_housemem10!=""
label val hhmem_sex sex_lab
label var hhmem_sex "Sex"
tab hhmem_sex, m




*------------------------------------------------------------------------------*
* HIV-exposure and HIV status

* --> Exposure
gen infant_hiv_exposed=reg_housemem18=="exposed" if reg_housemem18!=""
replace infant_hiv_exposed=2 if reg_housemem18=="unknown_exposure"
label val infant_hiv_exposed yesnounk
label var infant_hiv_exposed "Infant is exposed to HIV"
tab infant_hiv_exposed, m


* --> Status
tab reg_housemem19, m
gen hiv_status_hhmemreg=reg_housemem19=="positive" if reg_housemem19!=""
replace hiv_status_hhmemreg=2 if reg_housemem19=="unknown"
label val hiv_status_hhmemreg status_lab
label var hiv_status_hhmemreg "HIV status (reg hh member form)"
numlabel, add
tab hiv_status_hhmemreg, m




*------------------------------------------------------------------------------*
* ART initiation

gen artstart_hhmemreg=reg_housemem20=="yes"
label val artstart_hhmemreg yesnounk
label var artstart_hhmemreg "Initiated on ART (HH member reg)"
tab artstart_hhmemreg, m
tab artstart_date_hhmemreg, m




*------------------------------------------------------------------------------*
* Unique IDs and identifying duplicates
/*
caseid is the index client's ID and hhmem_id is the hh member's (infant's)
ID. We can see an index ID show up multiple times - sometimes can be for a
valid reason like having multiple infants. 
However, there also seem to be cases of HH member's being registered twice.
I drop those which are perfectly duplicated and some of those not perfectly 
duplicated but where it is obvious they are the same individual. Some will
remain which look like they must be duplicated registrations but there isn't
enough perfectly duplicated to drop without doing it manually.
*/

* --> Drop perfectly duplicated entries
ren reg_housemem8 hhmem_fname
ren reg_housemem9 hhmem_sname
ren case_name index_name 
replace hhmem_fname=upper(hhmem_fname)
replace hhmem_sname=upper(hhmem_sname)

duplicates drop index_id hhmem_fname hhmem_sname hhmem_sex infant_dob, force
duplicates drop index_id hhmem_sex infant_dob, force
duplicates drop index_id hhmem_fname hhmem_sname, force


* --> Recreate index tag
egen index_id_tag=tag(index_id)
tab index_id_tag

	
* --> Identify non-perfectly duplicated entries
egen tag_min=min(index_id_t), by(index_id)
egen tag_max=max(index_id_t), by(index_id)
gen ever_duplicated=tag_min!=tag_max
tab ever_duplicated
egen num_infants=sum(infant), by(index_id)
label var num_infants "# infants associated with index caseid"
/*
sort caseid hhmem_fname 
br caseid hhmem_*name hhmem_sex infant_dob num_infants if ever_dup==1
*/
	// Some of these are errors, others might be a woman with 2 children.




*------------------------------------------------------------------------------*
* Save dataset

keeporder country facility index_id hhmem_id ///
	hhmem_fname hhmem_sname enrolment_date ///
	hhmem_sex infant_dob infant_hiv_e hiv_status artstart* 
sort index_id hhmem_id
numlabel, add
isid hhmem_id

gen form="reg_hhmem"
notes drop _all
notes: HH member registration form, infants only. Saved on TS
save "$data/reg_hhmem_cleaned.dta", replace
	



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Index client registration 
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/reg_index.dta", clear
set sortseed 1
ren caseid index_id
isid index_id
label def yesno 1"Yes" 0"No"
label def status_lab 0"Negative" 1"Positive" 2"Unknown"



*------------------------------------------------------------------------------*
* Dates

ren client_reg18 index_dob
ren completed enrolment_date
ren client_reg26 artstart_date_indexreg

foreach var of varlist index_dob artstart_date_indexreg {
	gen `var'1=date(`var',"YMD")
	replace `var'1=date(`var',"DMY") if `var'1==.
	_crcslbl `var'1 `var'
	format %d `var'1
	drop `var'
	ren `var'1 `var'
}
label var index_dob "Index client DOB"
label var enrolment_date "Enrolment date"
label var artstart_date_indexreg "ART start date (reg index form)"




*------------------------------------------------------------------------------*
* HIV status

tab client_reg23
gen hiv_status_indexreg=(client_reg23=="known_positive" | ///
	client_reg23=="tested_positive") if client_reg23!=""
replace hiv_status_indexreg=2 if client_reg23=="unknown"
label val hiv_status_indexreg status_lab
label var hiv_status_indexreg "HIV status at enrolment (reg index form)"
numlabel, add
tab hiv_status_indexreg, m




*------------------------------------------------------------------------------*
* ART start

gen artstart_indexreg=client_reg24=="yes" if client_reg24!=""
label val artstart_indexreg yesno
label var artstart_indexreg "Initiated on ART (reg index form)"
tab artstart_indexreg hiv_status_indexreg, m




*------------------------------------------------------------------------------*
* Age at enrolment

gen index_age_enrol=round(((enrolment_date-index_dob)/365), 1)
label var index_age_enrol "Index client's age at enrolment (years)"
tab index_age, m
replace index_age=. if index_age<10 | index_age>60




*------------------------------------------------------------------------------*
* Save data

label var index_id "Original unique ID for index client (caseid)"
isid index_id

keeporder facility index_* enrolment_date hiv_status artstart* 
gen form="reg_index"

notes: Index client reg data. Saved on TS, replace
save "$data/reg_index_cleaned.dta", replace




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Caregiver form 
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/caregiver.dta", clear
ren caseid index_id
set sortseed 1
label def yesno 1"Yes" 0"No"
label def status_lab 0"Negative" 1"Positive" 2"Unknown"




*------------------------------------------------------------------------------*
* Deal with multiple form submissions on the same date. Consolidate info
* into one obs and replace all other completed date values to missing so
* we only count 1 visit per day.

gsort index_id completed -completed_time		
	// Sort the data by id, then by date, and then by time so that the 
	// latest time appears first within that group. 
	
ds index_id completed* received*, not							
unab varlist: `r(varlist)'			
	// We want a local that contains all variables except id and the 
	// created date variables.
	
foreach y in `varlist' {
	by index_id completed: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")
}
	// If an entry is "" or "---", replace that entry with the line 
	// just below if it is of the same ID and date. The latest time 
	// will be first row as per line above. In other words, the latest
	// entry is taken unless it is missing, in which case the earlier
	// entries are progressively taken if it is still missing.

by index_id completed: gen tag=cond(_N==1,0,_n) 
drop if tag>1
	// If client is seen more than once on the same day, only keep the latest
	// form entry which has now been updated with earlier ones as much as 
	// possible. Still a chance we have kept some incorrect data (because a
	// mistake was made in the later form entry, not the earlier one), but no
	// way to control for that fully.


	

*------------------------------------------------------------------------------*
* Merge in reg index form

merge m:1 index_id using "$data/reg_index_cleaned.dta"
keep if _merge==3




*------------------------------------------------------------------------------*
* Visits
/*
The form completion time is taken as the visit date.
*/

* --> Visit/form submission number
sort index_id completed	
bysort index_id (completed): gen caregiver_visit_num=_n
label var caregiver_visit_num "Caregiver's visit number (calc)"


* --> Total unique visit dates per index client
egen unique_visit=tag(index_id completed)
egen caregiver_total_visits=total(unique_visit), by(index_id)
label var caregiver_total_visits "Total visits in caregiver form"
tab caregiver_total_visits




*------------------------------------------------------------------------------*
* HIV status

tab mom_care24 
gen hiv_status_caregiver=(mom_care24=="known_positive" | ///
	mom_care24=="tested_positive") if mom_care24!=""
replace hiv_status_caregiver=2 if mom_care24=="unknown"
label val hiv_status_caregiver status_lab
label var hiv_status_caregiver "HIV status in caregiver form"
tab hiv_status_caregiver, m




*------------------------------------------------------------------------------*
* ART initiation

gen artstart_caregiver=mom_care26=="yes"
replace artstart_caregiver=. if mom_care26==""
label var artstart_caregiver "Index client has started ART (caregiver form)"
label val artstart_caregiver yesno
tab artstart_caregiver, m

ren mom_care10 artstart_date_caregiver
label var artstart_date_caregiver "ART start date (caregiver form)"
foreach var of varlist artstart_date_caregiver {
	gen `var'1=date(`var',"YMD")
	replace `var'1=date(`var',"DMY") if `var'1==.
	drop `var'
	ren `var'1 `var'
	format %d `var' 
}
tab artstart_date_caregiver if artstart_caregiver==1, m




*------------------------------------------------------------------------------*
* Wellbeing variables

* --> Rename variables
ren mom_care44 wellbeing_depressed
label var wellbeing_depressed ///
	"In past month, have you felt depressed or hopeless?"
ren mom_care45 wellbeing_nointerest
label var wellbeing_nointerest ///
	"In past month, have you had little interest/pleasure in doing things?"
ren mom_care46 wellbeing_wanthelp
label var wellbeing_wanthelp ///
	"Do you feel you need or want help?"
ren mom_care47 wellbeing_notcope
label var wellbeing_notcope ///
	"How often felt you could not cope with being preg/mother?"
ren mom_care48 wellbeing_nervous
label var wellbeing_nervous ///
	"How often felt nervous and 'stressed' by being preg/mother?"
ren mom_care49 wellbeing_confident
label var wellbeing_confident ///
	"How often felt confident about your ability to handle being preg/mother?"
ren mom_care50 wellbeing_difficulties
label var wellbeing_difficulties ///
	"How often felt difficulties piling up so you could not overcome them?"

	
* --> Make variables numeric
label def often 1"Always" 2"Sometimes" 3"Never"
ds wellbeing*
local variables=r(varlist)
di `variables'
foreach var of varlist `variables' {
	replace `var'="1" if `var'=="yes" | `var'=="always"
	replace `var'="0" if `var'=="no"
	replace `var'="2" if `var'=="sometimes"
	replace `var'="3" if `var'=="never"
	destring `var', replace
}
label val wellbeing_dep wellbeing_noi wellbeing_want yesno
label val wellbeing_notcope wellbeing_nervous wellbeing_conf ///
	wellbeing_diff often
numlabel, add
tab1 wellbeing*
	// Tricky thing is that all frequency questions have "never" coded 3 as
	// being the best response except for confident where we ideally want 
	// always as the answer. I therefore change its coding and label so that
	// when I take the maximum below, it prioritises the same category across
	// all variables.
	
gen wellbeing_confidentx=1 if wellbeing_confident==3
replace wellbeing_confidentx=3 if wellbeing_confident==1
replace wellbeing_confidentx=2 if wellbeing_confident==2
label def often_reverse 1"Never" 2"Sometimes" 3"Always"
label val wellbeing_confidentx often_reverse
numlabel, add
drop wellbeing_confident
ren wellbeing_confidentx wellbeing_confident
label var wellbeing_confident ///
	"How often felt confident about ability to handle being preg/mother?"
tab1 wellbeing*
	// I think the MMs don't realise that the confident one is positive while
	// all the others are negative. The "bad" category for the others is 
	// "always" because a bad thing is always happening. With confident, the
	// "bad" category is "never" because a good thing never happens. However,
	// the rate of never feeling confident is quite high and matches the rates
	// for never feeling bad for the other variables. If none of this
	// makes sense, the point is that I think MMs mix up never and always for
	// the confidence question. Tell Fiona.

	
	

*------------------------------------------------------------------------------*
* Save data

keeporder country facility index_* enrolment_date hiv_status* artstart* ///
	caregiver_visit_num completed caregiver_total_visits ///
	artstart* well*
sort index_id caregiver_visit_num
isid index_id completed
save "$data/caregiver_cleaned.dta", replace

 


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Infant form
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*


use "$temp/infant.dta", clear
set sortseed 1
label def yesno_lab 1"Yes" 0"No"
label def yesnona_lab 1"Yes" 0"No" 2"NA"
label def status_lab 0"Negative" 1"Positive" 2"Unknown"

ren caseid hhmem_id
label var hhmem_id "HH member caseid"
ren case_name hhmem_name
	



*------------------------------------------------------------------------------*
* Deal with multiple form submissions on the same date. Consolidate info
* into one obs and replace all other completed date values to missing so
* we only count 1 visit per day.

gsort hhmem_id completed -completed_time			
ds hhmem_id completed* received*, not							
unab varlist: `r(varlist)'			

foreach y in `varlist' {
	by hhmem_id completed: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")
}
by hhmem_id completed: gen tag=cond(_N==1,0,_n) 
drop if tag>1




*------------------------------------------------------------------------------*
* Merge in reg hhmem form

merge m:1 hhmem_id using "$data/reg_hhmem_cleaned.dta"
keep if _merge==3
drop _merge




*------------------------------------------------------------------------------*
* Visits

* --> Visit number
sort hhmem_id completed	
bysort hhmem_id (completed): gen infant_visit_num=_n
label var infant_visit_num "infant's visit number"


* --> Rename and count unique visit dates  
egen infant_total_visits=count(completed), by(hhmem_id)
label var infant_total_visits "Total visits in infant form"


* --> Last visit date during period  
egen infant_visit_date_last=max(completed), by(hhmem_id)
format %d infant_visit_date_last
label var infant_visit_date_last "Infant's last visit during period"
	
	


*------------------------------------------------------------------------------*
* Infant's age at each visit 

drop dob
gen infant_age_visit=round(((completed-infant_dob)/30.5),0.01)
label var infant_age_visit "Infant age at visit (months)"
sort hhmem_id completed

recode infant_age_visit ///
	(0/3=1 "0-3m old") ///
	(3.001/6=2 "3-6m old") ///
	(6.001/9=3 "6-9m old") ///
	(9.001/12=4 "9-12m old") ///
	(12.001/15=5 "12-15m old") ///
	(15.001/18=6 "15-18m old") ///
	(18.001/24=7 "18-24m old") ///
	(24.001/max=8 "24+ m old"), ///
	gen(infant_age_visit_cat)
label var infant_age_visit_cat "Infant age at visit in months"
tab infant_age_visit_cat, m
/*
sort hhmem_id infant_visit_num
br hhmem_id infant_visit_num completed infant_visit_date infant_dob infant_age* 
*/




*------------------------------------------------------------------------------*
* Is infant's mother HIV positive

ren infant249 mother_pos
destring mother_pos, replace
label var mother_pos "Infant's mother is HIV positive"
label val mother_pos yesno_lab
tab mother_pos




*------------------------------------------------------------------------------*
* HIV status

encode infant45, gen(hiv_status_infant)
numlabel, add
tab hiv_status_infant
replace hiv_status_infant=0 if hiv_status_infant==1
replace hiv_status_infant=1 if hiv_status_infant==2 | hiv_status_infant==3
replace hiv_status_infant=2 if hiv_status_infant==4
label val hiv_status_infant status_lab
label var hiv_status_infant "HIV status (infant form)"
tab hiv_status_infant, m




*------------------------------------------------------------------------------*
* Infant ART start if positive

foreach var of varlist infant245 {
	gen `var'1=date(`var',"YMD")
	replace `var'1=date(`var',"DMY") if `var'1==.
	drop `var'
	ren `var'1 `var'
	format %d `var' 
}

egen artstart_date_infant=max(infant245), by(hhmem_id)
format %d artstart_date_infant
label var artstart_date_infant "Infant's ART initiation date (infant form)"
tab artstart_date_infant
tab artstart_date_infant hiv_status_infant, m
assert artstart_date_infant==. if hiv_status_infant==0
	// Check that no negative infants have an ART start date.
	// Will take presence of a date as indication that they've started.
	
gen artstart_infant=artstart_date_infant!=. if hiv_status_infant==1
label val artstart_infant yesno_lab
label var artstart_infant "Initiated on ART (infant form)"
tab artstart_infant hiv_status_infant, m




*------------------------------------------------------------------------------*
* Early stimulation and play opportunities
/*
# of children reached with early stimulation and play opportunities 
*/

gen playgroup_attend=infant92=="yes"
replace playgroup_attend=2 if infant92=="na"
label val playgroup_attend yesnona_lab
label var playgroup_attend "Attended a play group"
tab playgroup_attend, m




*------------------------------------------------------------------------------*
* Birth registration

foreach var of varlist infant3 {
	gen birthreg_date=date(`var',"YMD")
	replace birthreg_date=date(`var',"DMY") if birthreg_date==.
	format %d birthreg_date
}
replace birthreg_date=. if birthreg_date<infant_dob
replace birthreg_date=. if birthreg_date>$end_period
tab birthreg_date, m

tab infant1, m
gen birthreg_done=infant1=="yes" if infant1!=""
replace birthreg_done=1 if birthreg_date!=.
label var birthreg_done "Birth registered"
label val birthreg_done yesno_lab
tab birthreg_done, m




*------------------------------------------------------------------------------*
* Growth curve

ren infant146 grow_6wk_done
ren infant148 grow_6wk_curve
ren infant149 grow_10wk_done	
ren infant151 grow_10wk_curve 
ren infant152 grow_14wk_done
ren infant154 grow_14wk_curve	
ren infant155 grow_6m_done	
ren infant157 grow_6m_curve
ren infant158 grow_9m_done	
ren infant160 grow_9m_curve	
ren infant161 grow_12m_done
ren infant163 grow_12m_curve
ren infant164 grow_18m_done
ren infant166 grow_18m_curve
ren infant167 grow_24m_done
ren infant169 grow_24m_curve

foreach i in 6wk 10wk 14wk 6m 9m 12m 18m 24m {
	label var grow_`i'_done "`i' growth assessment done"
	label var grow_`i'_curve "`i' growth assessment score"
}

label def yesno 1"Yes" 0"No"
ds grow*done
local yesno `r(varlist)'
foreach var of varlist `yesno' {
	qui replace `var'="0" if `var'=="no"
	qui replace `var'="1" if `var'=="yes"
	replace `var'="" if `var'=="na"
	qui destring `var', replace
	label val `var' yesno
}

label def curve 1"Above" 2"Below" 3"Within"
qui ds grow*curve
local curve `r(varlist)'
foreach var of varlist `curve' {
	qui replace `var'="1" if `var'=="above"
	qui replace `var'="2" if `var'=="below"
	qui replace `var'="3" if `var'=="within"
	qui destring `var', replace
	label val `var' curve
}
numlabel, add




*------------------------------------------------------------------------------*
* Save dataset

keeporder country facility index_id hhmem_id enrolment_date ///
	hhmem_sex infant_dob infant_hiv_e hiv_status* artstart* ///
	birth* infant_dob mother_pos infant_visit_num completed infant_age* ///
	grow*
sort hhmem_id completed
isid hhmem_id completed
gen form="infant"
notes: Data from infant form merged with hh mem reg form, replace
save "$data/infant_cleaned.dta", replace




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* EID form
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/eid.dta", clear
set sortseed 1
label def yesnonamiss 1"Yes" 0"No" 2"NA" 3"Blank/missing"
label def yes_notyes 0"No/NA/Blank" 1"Yes"
label def result 1"Positive" 0"Negative" 2"Unknown/missing"

ren caseid hhmem_id
label var hhmem_id "Infant's unique ID"
ren case_name hhmem_name




*------------------------------------------------------------------------------*
* Visit dates

* --> Deal with multiple form submissions on the same date
gsort hhmem_id completed -completed_time		
ds hhmem_id completed* received*, not									
unab varlist: `r(varlist)'							
foreach y in `varlist' {
	by hhmem_id completed: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")
}
by hhmem_id completed: gen tag=cond(_N==1,0,_n) 
drop if tag>1


* --> Visit number
sort hhmem_id completed	
bysort hhmem_id (completed): gen eid_visit_num=_n
label var eid_visit_num "EID form visit number (calc)"


* --> Rename and count unique visit dates  
egen eid_total_visits=count(completed), by(hhmem_id)
label var eid_total_visits "Total visits per infant in EID form"
tab eid_total_visits 




*------------------------------------------------------------------------------*
* Merge in reg hhmem form

merge m:1 hhmem_id using "$data/reg_hhmem_cleaned.dta"
keep if _merge==3
drop _merge




*------------------------------------------------------------------------------*
* Age at each visit

foreach var of varlist dob {
	gen `var'1=date(`var',"YMD")
	replace `var'1=date(`var',"DMY") if `var'1==.
	drop `var'
	ren `var'1 `var'
	format %d `var' 
}

gen infant_age_visit=round(((completed-dob)/30.5),0.001)
label var infant_age_visit "Infant age at visit (months)"
sort hhmem_id completed

recode infant_age_visit ///
	(0/3=1 "0-3m old") ///
	(3.001/6=2 "3-6m old") ///
	(6.001/9=3 "6-9m old") ///
	(9.001/12=4 "9-12m old") ///
	(12.001/15=5 "12-15m old") ///
	(15.001/18=6 "15-18m old") ///
	(18.001/24=7 "18-24m old") ///
	(24.001/max=8 "24+ m old"), ///
	gen(infant_age_visit_cat)
label var infant_age_visit_cat "Infant age at visit in months"
tab infant_age_visit_cat, m
tab infant_age_visit if infant_age_visit_cat==8
count if infant_age_visit>24 & infant_age_visit<. 
	
	


*------------------------------------------------------------------------------*
* 6-8 week test 

* --> Rename variables
tab1 early_infant_diag2 early_infant_diag3 
/*
sort pid visit_date
br pid visit_date early_infant_diag2 early_infant_diag3 early_infant_diag42
*/


* --> Due
tab early_infant_diag2, m
gen test_68wk_due=early_infant_diag2=="yes"
label var test_68wk_due "6-8 wk PCR due"
label val test_68wk_due yes_notyes
tab test_68wk_due, m


* --> Done
tab early_infant_diag3, m
gen test_68wk_done=early_infant_diag3=="yes"
label var test_68wk_done "6-8 wk PCR done"
label val test_68wk_done yes_notyes
tab test_68wk_done, m
tab test_68wk_d*, m


* --> Test result
tab early_infant_diag42
gen test_68wk_res=1 if early_infant_diag42=="Positive"
replace test_68wk_res=0 if early_infant_diag42=="negative"
replace test_68wk_res=2 if early_infant_diag42=="" 
label var test_68wk_res "6-8 wk test result"
label val test_68wk_res result
tab test_68wk_res, m




*------------------------------------------------------------------------------*
* 12 month rapid test due and done

* --> Rename variables
ren early_infant_diag57 test_12m_due
ren early_infant_diag58 test_12m_done
	

* --> Due
encode test_12m_due, gen(test_12m_due1)
replace test_12m_due1=test_12m_due1==3
label var test_12m_due1 "12 month rapid test due"
label val test_12m_due1 yes_notyes
drop test_12m_due
ren test_12m_due1 test_12m_due
tab test_12m_due, m


* --> Done
encode test_12m_done, gen(test_12m_done1)
replace test_12m_done1=test_12m_done1==2
label var test_12m_done1 "12 month rapid test done"
label val test_12m_done1 yes_notyes
drop test_12m_done
ren test_12m_done1 test_12m_done
tab test_12m_done, m


* --> Test result
tab early_infant_diag60
gen test_12m_res=1 if early_infant_diag60=="Positive"
replace test_12m_res=0 if early_infant_diag60=="negative"
replace test_12m_res=2 if early_infant_diag60=="" 
label var test_12m_res "12m test result"
label val test_12m_res result
tab test_12m_res, m




*------------------------------------------------------------------------------*
* 1824 month rapid test due and done

* --> Rename variables
ren early_infant_diag8 test_1824m_due
ren early_infant_diag9 test_1824m_done
tab1 test_1824m_d*, m


* --> Due
encode test_1824m_due, gen(test_1824m_due1)
replace test_1824m_due1=test_1824m_due1==3
label var test_1824m_due1 "18-24 month test due"
label val test_1824m_due1 yes_notyes
drop test_1824m_due
ren test_1824m_due1 test_1824m_due
tab test_1824m_due, m


* --> Done
tab test_1824m_done
encode test_1824m_done, gen(test_1824m_done1)
replace test_1824m_done1=test_1824m_done1==3
label var test_1824m_done1 "18-24 month test done"
label val test_1824m_done1 yes_notyes
drop test_1824m_done
ren test_1824m_done1 test_1824m_done
tab test_1824m_done, m


* --> Test result
tab early_infant_diag66
gen test_1824m_res=1 if early_infant_diag66=="Positive"
replace test_1824m_res=0 if early_infant_diag66=="negative"
replace test_1824m_res=2 if early_infant_diag66=="" 
label var test_1824m_res "18-24m test result"
label val test_1824m_res result
tab test_1824m_res, m




*------------------------------------------------------------------------------*
* Save dataset

keeporder country facility index_id hhmem_id ///
	enrolment_date hhmem_sex infant_dob infant_hiv_e hiv_status* artstart* ///
	completed infant_age* test_68wk* test_12m* test_1824m* eid_visit_num ///
	eid_total_visits
sort hhmem_id completed
numlabel, add
isid hhmem_id completed
gen form="eid"
notes: Data from EID form for infants who appear in hh mem reg form, replace
save "$data/eid_cleaned.dta", replace



   	
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Development milestones form
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*


use "$temp/devmile.dta", clear
set sortseed 1
label def yesno 1"Yes" 0"No"

ren caseid hhmem_id
label var hhmem_id "HH member's unique ID"




*------------------------------------------------------------------------------*
* Visit dates

* --> Deal with multiple form submissions on the same date
gsort hhmem_id completed -completed_time		
ds hhmem_id completed* received*, not									
unab varlist: `r(varlist)'							
foreach y in `varlist' {
	by hhmem_id completed: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")
}
by hhmem_id completed: gen tag=cond(_N==1,0,_n) 
drop if tag>1


* --> Visit number
sort hhmem_id completed	
bysort hhmem_id (completed): gen dev_visit_num=_n
label var dev_visit_num "Dev milestones form visit number"


* --> Rename and count unique visit dates  
egen dev_total_visits=count(completed), by(hhmem_id)
label var dev_total_visits "Total visits in dev milestones form"
tab dev_total_visits 




*------------------------------------------------------------------------------*
* Merge in reg hhmem form

merge m:1 hhmem_id using "$data/reg_hhmem_cleaned.dta"
keep if _merge==3
drop _merge




*------------------------------------------------------------------------------*
* Infant age

* --> Infant age at each visit
ren child_dev114 infant_age_visit
destring infant_age_visit, replace
replace infant_age_visit=round(infant_age_visit, 0.001)
label var infant_age_visit "Infant age at visit (months)"

/*
gen infant_age_calc=round(((completed-infant_dob)/30.5),1)
sort hhmem_id completed
br hhmem_id infant_dob completed infant_age* 
	// Seems the 2 ages are the same so I will just use the app generated 
	// age - hence why this is commented out.
*/

recode infant_age_visit ///
	(0/3=1 "0-3m old") ///
	(3.001/6=2 "3-6m old") ///
	(6.001/9=3 "6-9m old") ///
	(9.001/12=4 "9-12m old") ///
	(12.001/15=5 "12-15m old") ///
	(15.001/18=6 "15-18m old") ///
	(18.001/24=7 "18-24m old") ///
	(24.001/max=8 "24+ m"),  ///
	gen(infant_age_visit_cat)
label var infant_age_visit_cat "Infant age at visit in months"
numlabel, add
tab infant_age_visit_cat, m
	

	

*------------------------------------------------------------------------------*
* Three month milestones

* --> Rename variables
ren child_dev1 dev3m_sound
ren child_dev2 dev3m_watch
ren child_dev3 dev3m_smile
ren child_dev4 dev3m_hands
ren child_dev5 dev3m_head
ren child_dev6 dev3m_flex
ren child_dev7 dev3m_eyecontact
ren child_dev8 dev3m_grab
ren child_dev95	dev3m_all_complete
ren child_dev102 dev3m_e_percent
ren child_dev106 dev3m_p_percent
ren child_dev120 dev3m_l_percent
ren child_dev136 dev3m_last_ask
ren child_dev152 dev3m_ref
ren child_dev83	dev3m_ref_complete

destring dev3m_*, replace
tab1 dev3m_*_percent

/*
sort hhmem_id dev_visit_num
order hhmem_id dev_visit_num completed ///
	dev3m_sound dev3m_watch dev3m_smile dev3m_hands dev3m_head ///
	dev3m_flex dev3m_eyecontact dev3m_grab dev3m_all_complete ///
	dev3m_e_percent dev3m_p_percent dev3m_l_percent dev3m_last_ask ///
	dev3m_ref dev3m_ref_c
br hhmem_id dev_visit_num completed ///
	dev3m_sound dev3m_watch dev3m_smile dev3m_hands dev3m_head ///
	dev3m_flex dev3m_eyecontact dev3m_grab dev3m_all_complete ///
	dev3m_e_percent dev3m_p_percent dev3m_l_percent dev3m_last_ask ///
	dev3m_ref dev3m_ref_c
br hhmem_id dev3m_sound dev3m_watch dev3m_smile dev3m_hands dev3m_head ///
	dev3m_flex dev3m_eyecontact dev3m_grab ///
	dev3m_e_percent dev3m_p_percent dev3m_l_percent 
*/
	
	
* --> Assessed on 1 or more 3m measures at a given visit
egen num_assessed_3m=rownonmiss(dev3m_sound dev3m_watch dev3m_smile ///
	dev3m_hands dev3m_head dev3m_flex dev3m_eye dev3m_grab)
label var num_assessed_3m "# of 3m milestones assessed at visit"
gen assessed_any_3m=num_assessed_3m>0
label var assessed_any_3m "Any 3m milestones assessed at visit?"
label val assessed_any_3m yesno
tab assessed_any_3m, m


* --> Infant ever assessed during the period for 3m milestones
egen assessed_ever_3m=max(assessed_any), by(hhmem_id)
label var assessed_ever_3m "Ever assessed for 3m milestones during period"
label val assessed_ever_3m yesno
tab assessed_ever_3m, m
	// This is a generous measure of assessment. An infant will be marked
	// as having been assessed if even just one of the 8 measures had either
	// a 0 or 1 filled in. It seems like in most cases that if one of the
	// measures was done, others were too, so this isn't likely to be much
	// of an overestimate if it is one at all.
	
tab infant_age_visit_cat if assessed_any_3m==1
	


	
*------------------------------------------------------------------------------*
* 6 month milestones

* --> Rename variables
ren child_dev9 dev6m_watch_movement
ren child_dev10	dev6m_smile
ren child_dev11	dev6m_head
ren child_dev12	dev6m_make_sounds
ren child_dev13	dev6m_affection
ren child_dev14	dev6m_object_to_mouth
ren child_dev15	dev6m_legs_push_down
ren child_dev16	dev6m_vowel_sounds
ren child_dev17	dev6m_eye_movement
ren child_dev18	dev6m_respond_sound
ren child_dev19	dev6m_flex
ren child_dev20	dev6m_roll_over
ren child_dev21	dev6m_copy
ren child_dev22	dev6m_caregiver_presence
ren child_dev23	dev6m_sit_unsupport
ren child_dev97	dev6m_e_percent
ren child_dev109 dev6m_c_percent
ren child_dev129 dev6m_p_percent
ren child_dev133 dev6m_l_percent
destring dev6m_*, replace
tab1 dev6m_*_percent


* --> Assessed on 1 or more 6m measures at a given visit
egen num_assessed_6m=rownonmiss(dev6m_watch dev6m_smile ///
	dev6m_head dev6m_make_s dev6m_aff dev6m_obj dev6m_legs ///
	dev6m_vowel dev6m_eye dev6m_respond dev6m_flex dev6m_roll dev6m_copy ///
	dev6m_care dev6m_sit)
label var num_assessed_6m "# of 6m milestones assessed at visit"
gen assessed_any_6m=num_assessed_6m>0
label var assessed_any_6m "Any 6m milestones assessed at visit?"
label val assessed_any_6m yesno
tab assessed_any_6m, m


* --> Infant ever assessed during the period for 6m milestones
egen assessed_ever_6m=max(assessed_any_6m), by(hhmem_id)
label var assessed_ever_6m "Ever assessed for 6m milestones during period"
label val assessed_ever_6m yesno
tab assessed_ever_6m, m
/*
sort hhmem_id completed
br infant_caseid completed infant_age_visit ///
	assessed_any_3m assessed_any_6m
*/




*------------------------------------------------------------------------------*
* 9 month milestones

* --> Rename variables
ren child_dev25 dev9m_babble
ren child_dev24 dev9m_bear_weight
ren child_dev32 dev9m_crawling
ren child_dev33 dev9m_favorite_toy
ren child_dev29 dev9m_follow_point
ren child_dev26 dev9m_game
ren child_dev30 dev9m_hand_to_hand
ren child_dev27 dev9m_knows_name
ren child_dev31 dev9m_recog_objects
ren child_dev28 dev9m_recog_people
ren child_dev150 dev9m_c_percent
ren child_dev143 dev9m_e_percent
ren child_dev123 dev9m_l_percent
ren child_dev104 dev9m_p_percent
destring dev9m_*, replace


* --> Assessed on 1 or more 9m measures at a given visit
egen num_assessed_9m=rownonmiss(dev9m_bear_weight dev9m_babble dev9m_game ///
	dev9m_knows_name dev9m_recog_people dev9m_follow_point ///
	dev9m_hand_to_hand dev9m_recog_objects dev9m_crawling dev9m_favorite_toy)
label var num_assessed_9m "# of 9m milestones assessed at visit"
gen assessed_any_9m=num_assessed_9m>0
label var assessed_any_9m "Any 9m milestones assessed at visit?"
label val assessed_any_9m yesno
tab assessed_any_9m, m


* --> Infant ever assessed during the period for 9m milestones
egen assessed_ever_9m=max(assessed_any_9m), by(hhmem_id)
label var assessed_ever_9m "Ever assessed for 9m milestones during period"
label val assessed_ever_9m yesno
tab assessed_ever_9m, m




*------------------------------------------------------------------------------*
* 12 month milestones

* --> Rename variables
ren child_dev35 dev12m_find_hidden
ren child_dev37 dev12m_gestures
ren child_dev39 dev12m_interactive_games
ren child_dev38 dev12m_point_speak
ren child_dev36 dev12m_single_words
ren child_dev34 dev12m_stand
ren child_dev100 dev12m_c_percent
ren child_dev144 dev12m_e_percent
ren child_dev155 dev12m_l_percent
ren child_dev130 dev12m_p_percent
destring dev12m_*, replace


* --> Assessed on 1 or more 12m measures at a given visit
egen num_assessed_12m=rownonmiss(dev12m_stand dev12m_find_hidden ///
	dev12m_single_words dev12m_gestures dev12m_point_speak ///
	dev12m_interactive_games)
label var num_assessed_12m "# of 12m milestones assessed at visit"
gen assessed_any_12m=num_assessed_12m>0
label var assessed_any_12m "Any 12m milestones assessed at visit?"
label val assessed_any_12m yesno
tab assessed_any_12m, m


* --> Infant ever assessed during the period for 12m milestones
egen assessed_ever_12m=max(assessed_any_12m), by(hhmem_id)
label var assessed_ever_12m "Ever assessed for 12m milestones during period"
label val assessed_ever_12m yesno
tab assessed_ever_12m, m




*------------------------------------------------------------------------------*
* 18 month milestones

* --> Rename variables
ren child_dev45 dev18m_6_words
ren child_dev43 dev18m_copy_others
ren child_dev50 dev18m_explore_alone
ren child_dev96 dev18m_last_ask
ren child_dev48 dev18m_follow_directions
ren child_dev46 dev18m_help_dress
ren child_dev44 dev18m_new_words
ren child_dev49 dev18m_point_interesting
ren child_dev40 dev18m_show_others
ren child_dev42 dev18m_things_use
ren child_dev47 dev18m_use_common_items
ren child_dev41 dev18m_walk
ren child_dev115 dev18m_c_percent
ren child_dev137 dev18m_e_percent
ren child_dev92 dev18m_l_percent
ren child_dev142 dev18m_p_percent
destring dev18m_*, replace


* --> Assessed on 1 or more 18m measures at a given visit
egen num_assessed_18m=rownonmiss(dev18m_show_others dev18m_walk ///
	dev18m_things_use dev18m_copy_others dev18m_new_words dev18m_6_words ///
	dev18m_help_dress dev18m_use_common_items dev18m_follow_directions ///
	dev18m_point_interesting dev18m_explore_alone)
label var num_assessed_18m "# of 18m milestones assessed at visit"
gen assessed_any_18m=num_assessed_18m>0
label var assessed_any_18m "Any 18m milestones assessed at visit?"
label val assessed_any_18m yesno
tab assessed_any_18m, m


* --> Infant ever assessed during the period for 18m milestones
egen assessed_ever_18m=max(assessed_any_18m), by(hhmem_id)
label var assessed_ever_18m "Ever assessed for 18m milestones during period"
label val assessed_ever_18m yesno
tab assessed_ever_18m, m




*------------------------------------------------------------------------------*
* Age eligible for a given milestone
/*
Two ways to define age eligibility which give different samples:

1) Age eligible based on age at beginning of period
	Eligible for 3m measurement if aged between 0.5 and 5.5 months old on 1 Apr.
	This means they will be between 3.5 and 8.5 months old by 30 June, and
	therefore have been with m2m during the 3 months when at least one 3m
	measurement should be done (the 3m measurement is done at 3, 4 and 5
	months old). 
	
2) Age eligible based on age at each visit
	Eligible for the 3m measurement if the infant was aged between 3 and 6 
	months at any of their visits with us. 
	
Number 2 gives a smaller sample than number 1 because we have infants who,
although age eligible based on age at beginning of period, may have only
had visits at ages that were not eligible (e.g. 2 months old or 6.5 months
old). I think number 2 is better so going with that. I keep the code in a 
comment below in case we want to use it instead.
*/

* --> Age eligible for each milestone based on age at each visit during period
foreach x in 3 6 9 12 18 24 {
	gen dev`x'm_eligible_visit=infant_age_visit>=`x' & infant_age_visit<`x'+3
	label var dev`x'm_eligible_visit "Age eligible for `x'm assess. at visit"
	egen dev`x'm_eligible=max(dev`x'm_eligible_visit), by(hhmem_id)
	label var dev`x'm_eligible "Age eligible for `x'm assess. during period"
	label val dev`x'm_eligible yesno
}

/*
* --> Age eligible defined using DOB and beginning of period
gen dev3m_eligible_v2=age_1april>0.5*30.5 & age_1april<5.5*30.5
label val dev3m_eligible_v2 yesno
label var dev3m_eligible_v2 "Eligible for 3m assessment between 1 Apr-30 Jun"
tab dev3m_eligible_v2
tab infant_age_visit if dev3m_eligible_v2==1
*/




*------------------------------------------------------------------------------*
* Milestone achievement at 3m

* --> Number of milestones achieved at a visit
egen num_achieved_3m=rowtotal(dev3m_sound dev3m_watch dev3m_smile ///
	dev3m_hands dev3m_head dev3m_flex dev3m_eye dev3m_grab)
replace num_achieved_3m=. if assessed_any_3m==0
label var num_achieved_3m "# 3m milestones achieved at visit"
tab num_achieved_3m if assessed_any_3m==1, m


* --> Percent of milestones achieved at visit
/*
This is the percent of all milestones achieved taken together, which is diff
to the percentages which the app calculates that are separated into type
of milestone (language, cognitive, emotional and physical).
*/
gen perc_achieved_3m=round((num_achieved/8), 0.0001)
label var perc_achieved_3m "% of 3m milestones achieved at visit"
tab perc_achieved_3m if assessed_any_3m==1, m

recode perc_achieved_3m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(perc_achieved_3m_cat)
label var perc_achieved_3m_cat "% of 3m milestones achieved at visit"
tab perc_achieved_3m_cat


* --> Maximum achievement for those measured more than once
egen max_num_achieved_3m=max(num_achieved_3m), by(hhmem_id)
label var max_num_achieved_3m "Max # 3m milestones achieved during period"
gen max_perc_achieved_3m=round((max_num_achieved_3m/8), 0.0001)
label var max_perc_achieved_3m "Max % of 3m milestones achieved during period"
recode max_perc_achieved_3m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(max_perc_achieved_3m_cat)
label var max_perc_achieved_3m_cat "Max % 3m milestones achieved during period"




*------------------------------------------------------------------------------*
* Milestone achievement at 6m

* --> Number of milestones achieved at a visit
ds dev6m_watch dev6m_smile ///
	dev6m_head dev6m_make_s dev6m_aff dev6m_obj dev6m_legs ///
	dev6m_vowel dev6m_eye dev6m_respond dev6m_flex dev6m_roll dev6m_copy ///
	dev6m_care dev6m_sit
local varlist `r(varlist)'
local total: word count `varlist'
cap drop num_achieved_6m
egen num_achieved_6m=rowtotal(`varlist')
replace num_achieved_6m=. if assessed_any_6m==0
label var num_achieved_6m "# 6m milestones achieved at visit"


* --> Percentage of milestones acbieved at a visit
cap drop perc_achieved_6m
gen perc_achieved_6m=round((num_achieved_6m/`total'), 0.0001)
label var perc_achieved_6m "% of 6m milestones achieved at visit"
recode perc_achieved_6m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(perc_achieved_6m_cat)
label var perc_achieved_6m_cat "% of 6m milestones achieved at visit"
tab perc_achieved_6m_cat


* --> Maximum achievement for those measured more than once
egen max_num_achieved_6m=max(num_achieved_6m), by(hhmem_id)
label var max_num_achieved_6m "Max # 6m milestones achieved during period"
gen max_perc_achieved_6m=round((max_num_achieved_6m/`total'), 0.0001)
label var max_perc_achieved_6m "Max % of 6m milestones achieved during period"
recode max_perc_achieved_6m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(max_perc_achieved_6m_cat)
label var max_perc_achieved_6m_cat "Max % 6m milestones achieved during period"




*------------------------------------------------------------------------------*
* Milestone achievement at 9m

* --> Number of milestones achieved at a visit
ds dev9m_bear_weight dev9m_babble dev9m_game ///
	dev9m_knows_name dev9m_recog_people dev9m_follow_point ///
	dev9m_hand_to_hand dev9m_recog_objects dev9m_crawling dev9m_favorite_toy
local varlist `r(varlist)'
local total: word count `varlist'
cap drop num_achieved_9m
egen num_achieved_9m=rowtotal(`varlist')
replace num_achieved_9m=. if assessed_any_9m==0
label var num_achieved_9m "# 9m milestones achieved at visit"


* --> Percentage of milestones achieved at a visit
cap drop perc_achieved_9m
gen perc_achieved_9m=round((num_achieved_9m/`total'), 0.0001)
label var perc_achieved_9m "% of 9m milestones achieved at visit"
recode perc_achieved_9m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(perc_achieved_9m_cat)
label var perc_achieved_9m_cat "% of 9m milestones achieved at visit"
tab perc_achieved_9m_cat


* --> Maximum achievement for those measured more than once
egen max_num_achieved_9m=max(num_achieved_9m), by(hhmem_id)
label var max_num_achieved_9m "Max # 9m milestones achieved during period"
gen max_perc_achieved_9m=round((max_num_achieved_9m/`total'), 0.0001)
label var max_perc_achieved_9m "Max % of 9m milestones achieved during period"
recode max_perc_achieved_9m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.9999=4 "75-99%") ///
	(1=5 "100%"), ///
	gen(max_perc_achieved_9m_cat)
label var max_perc_achieved_9m_cat "Max % 9m milestones achieved during period"




*------------------------------------------------------------------------------*
* Milestone achievement at 12m

* --> Number of milestones achieved at a visit
ds dev12m_stand dev12m_find_hidden ///
	dev12m_single_words dev12m_gestures dev12m_point_speak ///
	dev12m_interactive_games
local varlist `r(varlist)'
local total: word count `varlist'
cap drop num_achieved_12m
egen num_achieved_12m=rowtotal(`varlist')
replace num_achieved_12m=. if assessed_any_12m==0
label var num_achieved_12m "# 12m milestones achieved at visit"


* --> Percentage of milestones achieved at a visit
cap drop perc_achieved_12m
gen perc_achieved_12m=round((num_achieved_12m/`total'), 0.0001)
label var perc_achieved_12m "% of 12m milestones achieved at visit"
recode perc_achieved_12m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.12121212=4 "75-1212%") ///
	(1=5 "100%"), ///
	gen(perc_achieved_12m_cat)
label var perc_achieved_12m_cat "% of 12m milestones achieved at visit"
tab perc_achieved_12m_cat


* --> Maximum achievement for those measured more than once
egen max_num_achieved_12m=max(num_achieved_12m), by(hhmem_id)
label var max_num_achieved_12m "Max # 12m milestones achieved during period"
gen max_perc_achieved_12m=round((max_num_achieved_12m/`total'), 0.0001)
label var max_perc_achieved_12m "Max % of 12m milestones achieved during period"
recode max_perc_achieved_12m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.12121212=4 "75-1212%") ///
	(1=5 "100%"), ///
	gen(max_perc_achieved_12m_cat)
label var max_perc_achieved_12m_cat ///
	"Max % 12m milestones achieved during period"




*------------------------------------------------------------------------------*
* Milestone achievement at 18m

* --> Number of milestones achieved at a visit
ds dev18m_show_others dev18m_walk ///
	dev18m_things_use dev18m_copy_others dev18m_new_words dev18m_6_words ///
	dev18m_help_dress dev18m_use_common_items dev18m_follow_directions ///
	dev18m_point_interesting dev18m_explore_alone
local varlist `r(varlist)'
local total: word count `varlist'
cap drop num_achieved_18m
egen num_achieved_18m=rowtotal(`varlist')
replace num_achieved_18m=. if assessed_any_18m==0
label var num_achieved_18m "# 18m milestones achieved at visit"


* --> Percentage of milestones achieved at a visit
cap drop perc_achieved_18m
gen perc_achieved_18m=round((num_achieved_18m/`total'), 0.0001)
label var perc_achieved_18m "% of 18m milestones achieved at visit"
recode perc_achieved_18m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.18181818=4 "75-1818%") ///
	(1=5 "100%"), ///
	gen(perc_achieved_18m_cat)
label var perc_achieved_18m_cat "% of 18m milestones achieved at visit"
tab perc_achieved_18m_cat


* --> Maximum achievement for those measured more than once
egen max_num_achieved_18m=max(num_achieved_18m), by(hhmem_id)
label var max_num_achieved_18m "Max # 18m milestones achieved during period"
gen max_perc_achieved_18m=round((max_num_achieved_18m/`total'), 0.0001)
label var max_perc_achieved_18m "Max % of 18m milestones achieved during period"
recode max_perc_achieved_18m ///
	(0/0.25=1 "0-25%") ///
	(0.2501/0.5=2 "25-50%") ///
	(0.5001/0.75=3 "50-75%") ///
	(0.7501/0.18181818=4 "75-1818%") ///
	(1=5 "100%"), ///
	gen(max_perc_achieved_18m_cat)
label var max_perc_achieved_18m_cat ///
	"Max % 18m milestones achieved during period"




*------------------------------------------------------------------------------*
* Save dataset

keeporder country facility index_id hhmem_id ///
	enrolment_date hhmem_sex infant_dob infant_hiv_e hiv_status* artstart* ///
	completed infant_age* dev_visit_num completed infant_dob ///
	infant_age* dev_total dev*m* dev*m* dev*m* dev*m* dev*m* ///
	num_assessed_*m assessed_any_*m assessed_ever_*m ///
	num_achieved_*m perc_achieved_*m perc_achieved_*m_cat ///
	max_num_achieved_*m max_perc_achieved_*m max_perc_achieved_*m_cat
sort hhmem_id completed
numlabel, add
isid hhmem_id completed
gen form="devmile"
notes: Data from dev milestones form for infants who appear in hh mem ///
	reg form, replace
save "$data/devmile_cleaned.dta", replace


