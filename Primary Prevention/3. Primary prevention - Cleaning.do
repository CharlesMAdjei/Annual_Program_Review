*** APR 2020 - Primary prevention
*** Clean data
* 2 July 2021

/*
Clients excluded during cleaning process:
- Multiple infants
- Single visit
- Date of enrolment after first AN or PN form submission


Restricting to those HIV negative at enrolment:
- HIV status recorded at enrolment was either positive or unknown 
- Have an ART initiation date at or before enrolment
- Have a positive status recorded within 2 weeks of enrolling


Observations dropped during cleaning:
- Forms submitted after 31 Dec 2020
- Multiple forms submitted on same day - I take latest form, populate blank
  variables with non-blank values from forms submitted earlier on that day
  and then drop all but the latest form
  
Dues and dones replaced to missing:
- Any due or done after end of obs period (31 Dec 2020)
- Dues and dones before facility start date
- Dues and dones after last visit date
- Removing dues before enrolment date
- Removing dones after form submission date
*/


use "$temp/an_pn_all.dta", clear
tab id_tag
	// 156,631 clients (all)




*------------------------------------------------------------------------------*
* Identify client type

egen dataset_min=min(dataset), by(id)
egen dataset_max=max(dataset), by(id)

cap drop client_type
gen client_type=1 if dataset_min==1 & dataset_max==1
replace client_type=2 if dataset_min==2 & dataset_max==2
replace client_type=3 if dataset_min==1 & dataset_max==2
label var client_type "Client type"
label def client_type 1"AN" 2"PN" 3"AN+PN"
label val client_type client_type
numlabel, add
tab client_type if id_tag==1, m

gen an_any=client_type==1 | client_type==3
gen pn_any=client_type==2 | client_type==3




*------------------------------------------------------------------------------*
* Partner's HIV status

gen partner_status_enrol=0 if dnew_partner_status=="negative"
replace partner_status_enrol=1 if dnew_partner_status=="positive"
replace partner_status_enrol=2 if dnew_partner_status=="unknown" | dnew_partner_status==""
label def partner_status 0"Neg" 1"Pos" 2"Unknown"
lab val partner_status_enrol partner_status
lab var partner_status_enrol "Partner's HIV status at enrolment"
tab partner_status_enrol, m




*------------------------------------------------------------------------------*
* Gestational age at first m2m/ANC visit

destring dnew_gestage_m2m, gen(gestation_firstm2m)
destring dnew_gestage_anc1, gen(gestation_firstanc)
foreach var of varlist gestation_firstm2m gestation_firstanc {  
	replace `var'=`var'*4.3 if dnew_gestage_units=="months"
}

replace gestation_firstanc=. if gestation_firstanc<2
replace gestation_firstanc=round(gestation_firstanc)

replace gestation_firstm2m=abs(gestation_firstm2m)
replace gestation_firstm2m=. if gestation_firstm2m<2
replace gestation_firstm2m=round(gestation_firstm2m)

replace gestation_firstm2m=gestation_firstanc if gestation_firstm2m==.




*------------------------------------------------------------------------------*
* Destring dates

cap drop dnew_init_date
*ren dan_init_date dan_init_done_date
ren dan_hiv_test_due dan_hiv_retest_due_date
ren dan_hiv_test_done dan_hiv_retest_done_date
foreach var of varlist ///
	dnew_edd ///
	dan_hiv_retest_prev_due_date dan_hiv_retest_prev_done_date ///
	dan_hiv_retest_due_date dan_hiv_retest_done_date ///
	dan_hiv_retest_next_due_date ///
	dpn_hiv_retest_prev_due_date dpn_hiv_retest_prev_done_date  ///
	dpn_hiv_retest_due_date dpn_hiv_retest_done_date ///
	dpn_hiv_retest_next_due_date ///
	dpn_fp_due_date dpn_fp_done_date ///
	dan_init_due_date dan_init_done_date ///
	dpn_init_due_date dpn_init_done_date ///
	dan_artrefill_prev_due_date dan_artrefill_prev_done_date ///
	dan_artrefill_due_date dan_artrefill_done_date ///
	dan_artrefill_next_due_date ///
	dpn_artprevrefill_due_date dpn_artprevrefill_done_date ///
	dpn_artrefill_due_date dpn_artrefill_done_date ///
	dpn_artnextrefill_due_date ///
	dpn_nvp_due_date dpn_nvp_done_date ///
	dpn_infant_init_due_date dpn_infant_init_done_date {
		gen `var'_x=date(`var', "YMD")
		replace `var'_x=date(`var', "DMY") if `var'_x==.
		drop `var'
		ren `var'_x `var'
		format %d `var'
}
ren dnew_edd edd
ren dpn_fp* fp*
ren dpn_nvp* nvp*

	
	
	
*------------------------------------------------------------------------------*
* Enrolment date and visit dates
/*
This creates a bunch of variables and then drops those who were only seen once.
*/

* --> Enrolment date
gen enrol_date=dnew_timeend_date
assert enrol_date!=.
label var enrol_date "Date of enrolment with m2m"
format %d enrol_date 


* --> Single visit date variable across AN and PN forms
cap drop visit_date
gen visit_date=dan_timeend_date
replace visit_date=dpn_timeend_date if visit_date==.
assert visit_date!=.
label var visit_date "Visit date (proxied by form sub date)"
format %d visit_date 


* --> Drop forms submitted after end of 2020
drop if visit_date>$end_period


* --> First and last visit
foreach x in min max {
	egen visit_date_`x'=`x'(visit_date), by(id)
	format %d visit_date_`x'
}
label var visit_date_min "Earliest visit date"
label var visit_date_max "Latest visit date"


* --> Comparing date of enrolment to first and last visit date
count if enrol_date!=visit_date_min & id_tag==1
gen same_day=enrol_date==visit_date_min
label var same_day "Enrolment date and first AN/PN form sub date are the same"
tab same_day if id_tag==1
	// Some clients' first form submission date is different to their enrolment
	// date. This just means the AN or PN form wasn't submitted on the same day
	// as the new client form.

count if enrol_date>visit_date_min & id_tag==1
	// Somehow a few hundred clients have a visit date in the AN or PN form that 
	// is before their new client form.  Not sure what is going on and it's a 
	// small number of clients so I am going to drop them because we need to
	// know their status at enrolment.
	
drop if visit_date_min<enrol_date	

	
* --> Form submission time and number
cap drop form_sub_time
gen form_sub_time=dan_timeend_time
replace form_sub_time=dpn_timeend_time if form_sub_time==.
assert form_sub_time!=.
label var form_sub_time "Form sub. date and time"
format %tc form_sub_time

cap drop form_sub_number
bys id (form_sub_time): gen form_sub_number=_n
label var form_sub_number "Form sub. number in ascending order"
	// This isn't the same as visit number because of cases where multiple forms
	// were submitted on the same day. Will have to create visit number when
	// I decide how to deal with multiple forms on one day.
	
	
* --> Drop clients with only 1 visit
/*
Some clients may have more than one form submission but if they're all on the
same date, it is treated as a single visit and they are dropped. This is in
line with Jude's method.
*/
drop if visit_date_min==visit_date_max
duplicates tag id, gen(d)
tab d
drop d
	// Just checking that everyone that remains appears at least twice in the 
	// dataset (indicated by d>=1. d would be 0 if the client only appears once).

	
* --> Length of time in m2m programme (i.e. exposure to m2m)
gen tot_duration=round((visit_date_max-enrol_date)/30.5, 1)
replace tot_duration=round((visit_date_max-enrol_date)/30.5, 0.01) if ///
	visit_date_max-enrol_date<30.5
	// Include decimal points for those in the programme for less than 1 month.
	
label var tot_duration "Duration in m2m programme"
tab tot_duration if id_tag==1
	
	
* --> Client count
tab id_tag
		// 98727 

		


*------------------------------------------------------------------------------*		
* Make a single variable for variables that are in both AN and PN forms	

* --> HIV test dues and dones
foreach x in due done prev_due prev_done next_due {
	cap drop hiv_retest_`x'_date
	gen hiv_retest_`x'_date=dan_hiv_retest_`x'_date
	replace hiv_retest_`x'_date=dpn_hiv_retest_`x'_date if ///
		hiv_retest_`x'_date==.
	format %d hiv_retest_`x'_date
}
drop d?n_hiv_retest_*_date


* --> ART initiation dues and dones
foreach x in due done {
	cap drop art_init_`x'_date
	gen art_init_`x'_date=dan_init_`x'_date
	replace art_init_`x'_date=dpn_init_`x'_date if ///
		art_init_`x'_date==.
	format %d art_init_`x'_date
	label var art_init_`x'_date "Client's ART initiation `x' date"
}
drop d?n_init_d*_date


* --> ART refill dues and dones
ren dpn_artprevrefill_due_date dpn_artrefill_prev_due_date
ren dpn_artprevrefill_done_date dpn_artrefill_prev_done_date
ren dpn_artnextrefill_due_date dpn_artrefill_next_due_date
	// Named inconsistently across AN and PN forms
	
foreach x in due done prev_due prev_done next_due {
	cap drop art_refill_`x'_date
	gen art_refill_`x'_date=dan_artrefill_`x'_date
	replace art_refill_`x'_date=dpn_artrefill_`x'_date if ///
		art_refill_`x'_date==.
	format %d art_refill_`x'_date
	label var art_refill_`x'_date "Client's ART refill `x' date"
}
drop d?n_artrefill_*_date


* --> Rename infant ART initiation dues and dones
ren dpn_infant_init_d*e_date infant_init_d*e_date
label var infant_init_due_date "Infant's ART initiation due date"
label var infant_init_done_date "Infant's ART initiation done date"
	// Just renaming to be consistent with other variables.

	
* --> HIV status
label def hiv_status_lab 0"Neg" 1"Known pos" 2"Tested pos" 3"Unknown"

foreach x in an pn {
	cap drop hiv_status_`x'
	gen hiv_status_`x'=0 if d`x'_hiv_status=="negative"
	replace hiv_status_`x'=1 if d`x'_hiv_status=="known_positive"
	replace hiv_status_`x'=2 if d`x'_hiv_status=="tested_positive"
	replace hiv_status_`x'=3 if d`x'_hiv_status=="unknown"
	lab val hiv_status_`x' hiv_status_lab
	label var hiv_status_`x' "Client's HIV status in `x' form"
	tab hiv_status_`x' if id_tag==1, m
}
gen hiv_status=hiv_status_an
replace hiv_status=hiv_status_pn if hiv_status==.
label val hiv_status* hiv_status_lab
tab hiv_status, m

cap drop hiv_status_simple
gen hiv_status_simple=hiv_status
replace hiv_status_s=1 if hiv_status==2
replace hiv_status_s=2 if hiv_status==3

label def hiv_status_simple 0"Neg" 1"Pos" 2"Unknown"
label val hiv_status_simple hiv_status_simple
tab hiv_status hiv_status_s, m




*------------------------------------------------------------------------------*		
* Sorting out multiple form submissions on the same day

* --> Identify clients who ever had more than one form submitted on same day
cap drop visit_date_dup ever_visit_date_dup
egen visit_date_dup=tag(id visit_date)
egen ever_visit_date_dup=min(visit_date_dup), by(id)
replace ever_visit_date_dup=1-ever_visit_date_dup
label var ever_visit_date_dup "Ever have >1 form sub on same day"
tab ever_visit_date_dup if id_tag==1


* --> Number the forms submitted on the same day
cap drop form_count
sort id visit_date form_sub_time
quietly bys id visit_date: gen form_count=cond(_N==1,1,_n)
egen form_count_max=max(form_count), by(id visit_date)
tab form_count_max	
/*
sort id form_sub_time form_count
br id_s visit_date form_sub_time form_sub_num form_count if ///
	ever_visit_date_dup==1
*/

	
* --> Fill in empty variables in the most recent form submission with non-blank 
*	  values from forms submitted earlier in the day
/*
The logic here is that the most recent form submission takes precedence but if
there are values for variables in a form submitted earlier on that day that are
missing in the last one submitted, they are filled in.
*/
sum form_count_max
return list
forvalues i = 1/`r(max)' {
	foreach var of varlist ///
		hiv_retest_prev_due_date hiv_retest_prev_done_date ///
		hiv_retest_due_date hiv_retest_done_date ///
		hiv_retest_next_due_date hiv_status ///
		fp_due_date fp_done_date ///
		fp_condom fp_method {
	sort id form_sub_time
	bysort id visit_date: ///
		replace `var'=`var'[_n-1] if missing(`var')
	}
}
	// Have to use the forvalues loop to get it to reiterate as many times as
	// needed to populate all missing rows.
/*
sort id form_sub_num form_count
br id_s form_sub_num visit_date form_count form_count_max ///
	dan_hiv_retest_done_date dpn_hiv_retest_done_date hiv_retest_done_date ///
	if ever_visit_date_dup==1
*/


* --> Drop all but the last form submitted on a given day
drop if form_count!=form_count_max
drop form_count*


* --> Visit time and visit number
ren form_sub_time visit_time
cap drop visit_num
sort id visit_date
quietly bys id: gen visit_num=cond(_N==1,1,_n)
/*
br id_s visit_num visit_date
*/


* --> Recreate ID tag
tab id_tag
drop id_tag
egen id_tag=tag(id)
tab id_tag
	// 98727 
	
	

	
*------------------------------------------------------------------------------*		
* Remove dates outside of correct range
/*
This is largely code from Jude, adapted to my variables etc. It removes dues
and dones for repeat appointments that are incorrect within a given form.
*/

* --> Remove dues and dones outside of correct range
ds fp_d*e_date hiv_retest_d*e_date ///
	hiv_retest_prev_d*e_date hiv_retest_next_d*e_date ///
	art_refill_d*e_date art_refill_prev_d*e_date ///
	art_refill_next_d*e_date
foreach var of varlist `r(varlist)' {
	replace `var'=. if `var'>$end_period
		// Dues and done after 31 Dec 2021.

	replace `var'=. if `var'<start_month
		// Dues and dones before facility start date

	replace `var'=. if `var'>visit_date_max
		// Dues and dones after last visit date
}
	

* --> Removing dues before enrolment date
ds fp_due_date hiv_retest_due_date ///
	hiv_retest_prev_due_date hiv_retest_next_due_date ///
	art_refill_due_date art_refill_prev_due_date ///
	art_refill_next_due_date 
foreach var of varlist `r(varlist)' {
	replace `var'=. if `var'<enrol_date
}


* --> Removing dones after form submission date
ds fp_done_date nvp_done_date ///
	hiv_retest_done_date hiv_retest_prev_done_date ///
	art_refill_done_date art_refill_prev_done_date  
foreach var of varlist `r(varlist)' {
	replace `var'=. if `var'>visit_date
}
	// This is removing done dates within a form that are after the actual
	// date that the form was submitted. Should be impossible obvs.



	
*------------------------------------------------------------------------------*		
* Drop clients with multiple infants
/*
I have just used Jude's code here without adjusting it.
*/

* --> Set any infant dob before Jan 2014 or after Dec 2021 to missing
gen infant_dob=date(dpn_infant_dob, "YMD")
replace infant_dob=date(dpn_infant_dob, "DMY") if infant_dob==.
format %d infant_dob
replace infant_dob=. if infant_dob<=td(01jan2014) | infant_dob>td(31dec2021)


* --> Identifying more than one infant DOB per client
egen infant_dob_min=min(infant_dob), by(id)
egen infant_dob_max=max(infant_dob), by(id)
format %d infant_dob*

gen diff_dob=infant_dob_max-infant_dob_min
tab diff_dob
count if infant_dob_min!=. & diff_dob>0 & id_tag==1

	
* --> Identify unique infant first name per client
egen tag=tag(id dpn_infant_first_name)
egen num_babies=total(tag), by(id)
tab num_babies


* --> Count clients with more than 1 infant 
count if diff_dob>30.5*9 & diff_dob!=. & num_babies>1 & id_tag==1
	// 105 clients have more than 1 baby's name and the difference in DOB
	// is greater than 9 months. 
	

* --> Drop clients identified above
drop if diff_dob>30.5*9 & diff_dob!=. & num_babies>1


* --> Drop clients where there is more than a year between DOBs
drop if diff_dob>30.5*12 & diff_dob!=.
	// This was another cleaning step used by Jude so I have included it.


* --> Client count
tab id_tag
	// 98527 

	
	

*------------------------------------------------------------------------------*		
* Clean infant DOB
/*
As above, just following Jude's steps with some minor adjustments.
*/

* --> Calculate difference between first visit and infant DOB
cap drop diff_first_visit_infant_dob
gen diff_first_visit_infant_dob=floor((infant_dob - visit_date_min)/30.5)


* --> Set infant DOB to missing for various groups
replace infant_dob=. if diff_first_visit_infant_dob>8 & an_any==1
	// Missing if gap between first visit and infant DOB is more than 8 months
	// for clients who enrolled AN. Jude's team used 6 months but I think it
	// is possible for the client to enrol earlier in their pregnancy than
	// that.
	
replace infant_dob=. if infant_dob<visit_date_min  & an_any==1
	// Missing if infant DOB before first visit for clients enrolled AN

replace infant_dob=. if infant_dob > visit_date_min & client_type==2
	// Missing if infant DOB after first visit for clients enrolled PN
	
	
* --> Generate new DOB based on mode
cap drop mode_infant_dob_pn
bys id: egen mode_infant_dob_pn=mode(infant_dob) if client_type==2, minmode
cap drop mode_infant_dob_an
bys id: egen mode_infant_dob_an=mode(infant_dob) if an_any==1, maxmode
replace mode_infant_dob_an=mode_infant_dob_pn if mode_infant_dob_an==.
rename mode_infant_dob_an infant_dob2
drop mode_infant_dob_pn
label var infant_dob2 "Infant DOB (cleaned)"
format %d infant_dob*
/*
sort id visit_date
br id_s visit_date form infant_dob infant_dob2
*/

count if infant_dob2==. & id_tag==1 & pn_any==1
	// 4431 missing infant DOB

	
* --> Cleaning missing infant dob with NVP due and done date
foreach x in due done {
	replace nvp_`x'_date=. if nvp_`x'_date<td(01jan2014)
	cap drop nvp_`x'_date_min
	egen nvp_`x'_date_min=min(nvp_`x'_date), by(id)
}

replace infant_dob2=nvp_done_date_min if infant_dob2==.
replace infant_dob2=nvp_due_date_min if infant_dob2==.
count if infant_dob2==. & id_tag==1 & pn_any==1
	// 3036 missing infant DOB

ren infant_dob2 infant_dob_clean	
label var infant_dob_clean "Infant DOB (cleaned)"




*------------------------------------------------------------------------------*		
* Clean mother's age and DOB
/*
Going to recreate mother's DOB and age here to remove any issues related
to impossible DOBs and age. 
*/

cap drop dob
gen dob=date(dnew_dob, "YMD")
replace dob=date(dnew_dob, "DMY") if dob==.
format %d dob

cap drop age
destring dnew_age, gen(age)
replace age=. if age<=10 | age>=60
count if age==.
	
cap drop dob_calc
gen dob_calc=dnew_timeend_date-(age*365)
format %d dob_calc

count if dob==.
count if dob==. & dob_calc!=.
replace dob=dob_calc if dob==.

gen age_calc=round(((dnew_timeend_date-dob)/365), 1)
tab age_calc
replace age=age_calc if (age_calc>10 & age_calc<60) & (age<=10 | age>=60)
tab age, m

replace dob=. if age==.
count if age==. & id_tag==1
count if dob==. & id_tag==1

drop dnew_dob_known dnew_dob dnew_dob dnew_age dan_dob dpn_dob dob_calc age_calc




*------------------------------------------------------------------------------*		
********************************************************************************
* Save data here to save time
********************************************************************************
*------------------------------------------------------------------------------*		

save "$temp/an_pn_cleaned1.dta", replace

*/
	

use "$temp/an_pn_cleaned1.dta", clear



*------------------------------------------------------------------------------*
* Client's HIV status
/*
The status variable seems to actually capture the HIV test result since there
is no test result variable in the data.
*/

* --> Identify status in new client form at enrolment
tab dnew_hiv_status
foreach x in new {
	cap drop hiv_status_`x'
	gen hiv_status_`x'=0 if d`x'_hiv_status=="negative"
	replace hiv_status_`x'=1 if d`x'_hiv_status=="known_positive"
	replace hiv_status_`x'=2 if d`x'_hiv_status=="tested_positive"
	replace hiv_status_`x'=3 if d`x'_hiv_status=="unknown"
	lab val hiv_status_`x' hiv_status_lab
	label var hiv_status_`x' "Client's HIV status in `x' form"
	tab hiv_status_`x' if id_tag==1, m
}
tab hiv_status_new, m
gen neg_enrol=hiv_status_new==0
label var neg_enrol "Client was HIV- at enrolment"
tab neg_enrol, m


* --> Check HIV status at enrolment across AN and PN forms
/*
Need to check if there are any who have an AN or PN form submission on the same
day as the new client form and are marked as positive in it.
*/
gen hiv_status_an_x=hiv_status_an if visit_date==enrol_date
gen hiv_status_pn_x=hiv_status_pn if visit_date==enrol_date
egen hiv_status_an_enrol=max(hiv_status_an_x), by(id)
egen hiv_status_pn_enrol=max(hiv_status_pn_x), by(id)
label val hiv_status_* hiv_status_lab
	// Assigning the HIV status captured in the AN or PN form that was submitted
	// on the same day as enrolment to all of the client's rows.
	
tab hiv_status_an_enrol if an_any==1 & neg_enrol==1, m
tab hiv_status_pn_enrol if pn_any==1 & neg_enrol==1, m	
	// There are some cases of the status entered into an AN or PN form that
	// is on the same day as enrolment being positive even though their status
	// in the new client form was negative. Going to be cautious and code them
	// as positive at enrolment (i.e. will be excluded from the analysis).

replace neg_enrol=0 if ///
	hiv_status_an_enrol==1 | ///
	hiv_status_an_enrol==2 | ///
	hiv_status_pn_enrol==1 | ///
	hiv_status_pn_enrol==2
	
drop hiv_status_an_x hiv_status_pn_x hiv_status_?n_enrol


* --> Status in last form that had a value for status in
gen visit_date_x=visit_date if hiv_status!=.
egen visit_date_xx=max(visit_date_x), by(id)
gen status_last_x=hiv_status if visit_date==visit_date_xx
egen status_lastrecorded=max(status_last_x), by(id)
label val status_lastrecorded hiv_status_lab
label var status_lastrecorded "Most recently recorded HIV status"
drop visit_date_x visit_date_xx status_last_x
tab status_lastrecorded if id_tag==1, m
/*
sort id visit_date 
br id_s visit_date hiv_status status_last
*/


* --> Client count by status at enrolment
tab neg_enrol if id_tag==1
	// 119373 clients in total
	// 68700 neg clients

	
* --> Identify clients with more than one status across all form submissions
gen pos=hiv_status_simple==1 
gen neg=hiv_status_simple==0

cap drop ever_pos
egen ever_pos=max(pos), by(id)
replace ever_pos=1 if hiv_status_new==1 | hiv_status_new==2
cap drop ever_neg
egen ever_neg=max(neg), by(id)
replace ever_neg=1 if neg_enrol==1

egen neg_pos_x=rowtotal(ever_neg ever_pos)
gen neg_pos=neg_pos==2
label var neg_pos ///
	"Client has both negative and positive status across forms"
drop neg_pos_x
tab neg_pos if id_tag==1, m
	// 1114 of 119373 clients have both neg and pos statuses recorded
	
/*
sort id_s visit_date
br id_s enrol_date hiv_status_new visit_date hiv_status if neg_pos==1
*/
	// Hopefully most of these are valid cases of a women seroconverting at
	// some point and going from neg to pos. There are almost definitely going
	// to be some cases where women move back to being negative. Have to find
	// them
	
tab neg_pos if id_tag==1, m
tab ever_pos if id_tag==1 & neg_pos==1
/*
sort id visit_date
br id enrol_date hiv_status_new visit_date hiv_status pos neg neg_pos if  ///
	ever_pos==1 & neg_pos!=1
br id enrol_date hiv_status_new visit_date hiv_status pos neg neg_pos if  ///
	ever_pos==1 & neg_pos==1
*/

	
* --> Check timing of status going to positive.
/*
Need to identify cases where the positive status comes very shortly
after enrolment to see if they really should be included in this dataset. I
am guessing in some cases that the client may actually have been unknown at
the first visit but was entered as negative and then tested positive very
shortly afterwards.
*/
gen visit_date_pos_x=visit_date if pos==1
egen visit_date_pos_first=min(visit_date_pos_x), by(id)
drop visit_date_pos_x
label var visit_date_pos_first "Visit date at which first pos status appears"
format %d visit_date_pos_first

gen time_to_pos=visit_date_pos_first-enrol_date
label var time_to_pos ///
	"Days between enrolment and first visit at which pos status recorded"
count if neg_pos==1 & time_to_pos<30 & id_tag==1
	// 289 of 1114 clients who were ever marked as positive were marked as pos
	// in a form submitted less than a month after their enrolment date.

/*
sort id visit_date
br id enrol_date visit_date hiv_status if  ///
	neg_pos==1 & time_to_pos<30
*/
	// Some of these people were marked as known positive as opposed to tested
	// positive. Seems to suggest they should be dropped. But really not sure 
	// how well the MMs differentiate between known and tested positive because
	// of the next browse below where we see lots of clients with a bigger
	// gap between enrolment and when they were marked as pos and were also 
	// entered as known positive. Fokking data.
	

* --> Check if known versus tested positive is useful/reliable
gen ever_known_pos_x=1 if hiv_status==1
egen ever_known_pos=max(ever_known_pos_x), by(id)
count if neg_pos==1 & time_to_pos>60 & ever_known_pos==1 & id_tag==1
/*
sort id visit_date
br id enrol_date visit_date hiv_status if  ///
	ever_pos==1 & time_to_pos>60 & ever_known_pos==1
*/
	// 254 clients marked as known positive even though that took place at least 
	// 2 months after enrolment. Although Jude seemed to put some sort of stock
	// in whether known or tested was entered, I am not going to because I
	// don't think it is used correctly.


* --> Identify those who tested positive 1-30 days after enrolling with m2m.
*	  Probably going to drop them, but will run Jude's convoluted code first
*	  to see what he did.
cap drop poss_drop
gen poss_drop=neg_pos==1 & time_to_pos<=30
tab poss_drop if neg_pos==1 & id_tag==1
	// 209 of 1114 people who were marked as negative at enrolment were then
	// marked as positive within 1 month of enrolling. 


* --> Only positive and only negative
cap drop only_pos
gen only_pos=ever_neg==0 & ever_pos==1
label var only_pos "Client only ever has a positive status recorded"

cap drop only_neg
gen only_neg=ever_neg==1 & ever_pos==0
label var only_neg "Client only ever has a negative status recorded"

cap drop only_unknown
gen only_unknown=ever_pos==0 & ever_neg==0
label var only_unknown "Client never has a status recorded"

cap drop statuses
gen statuses=0 if only_neg==1
replace statuses=1 if only_pos==1
replace statuses=2 if only_neg==0 & only_pos==0
replace statuses=3 if only_unknown==1
label def statuses 0"Only neg" 1"Only pos" 2"Both pos and neg" ///
	3"Never has status"
label val statuses statuses
tab statuses if id_tag==1, m
/*
sort id visit_date
br id_s enrol_date hiv_status_new visit_date hiv_status ///
	ever_neg ever_pos only_neg only_pos neg_enrol if  ///
	statuses==2
br id_s enrol_date hiv_status_new visit_date hiv_status ///
	ever_neg ever_pos only_neg only_pos neg_pos if statuses==3 
*/


	
	
	
*------------------------------------------------------------------------------*
* Jude's code to identify HIV status and seroconversion
/*
I have taken his code from the cleaning do file #5 to and only adapted it to
work with my variable names. There are a lot of decisions that don't seem
entirely clear to me but I run it here, in a comment, to see what he does and
to see the final number of clients his code would classify as having sero-
converted so I can use his general decisions to guide my cleaning and hopefully
end up with something similar because the analysis is supposed to be comparable
over the years.

Key seems to be that he takes the ART initiation date as correct and if it
falls before enrolment, that classifies a client as positive at enrolment
even though their recorded status isn't positive at enrolment. He also tries
to a bunch of fixes related to clients' status changing from positive to neg
or known pos to tested pos etc etc. 
*/

/*
* --> Difference between enrolment and art initiation date
capture drop init_enrol_time
gen init_enrol_time=art_init_done_date - enrol_date

gen hiv=hiv_status
label val hiv hiv_status

replace hiv=1 if init_enrol_time <= -91.25 
	// Known pos if ART init was more than 3 months before enrolment
	
replace hiv=2 if init_enrol_time > - 91.25 & init_enrol_time!=. & hiv!=1
	// Tested pos if ART init was anytime between 3 months before enrolment
	// to after enrolment. Not sure why he includes that 3 month period before
	// enrolment...
	
bys id (visit_date): replace hiv=2 if init_enrol_time[_n+1] <= - 91.25 & hiv==0
/*
br id visit_date hiv_status hiv enrol_date art_init_done_date init_enrol_time 
*/

capture drop next_hiv
bys id (visit_date): gen next_hiv=hiv[_n+1]
tab hiv next_hiv, m


* --> Tested positive at baseline but becomes negative later
bys id: gen max_visit=_N
bys id (visit_date): egen first_prevart_refil_due=first(art_refill_prev_due_date)
bys id (visit_date): egen first_prevart_refil_done=first(art_refill_prev_done_date)
bys id (visit_date): egen first_art_refil_done=first(art_refill_done_date)
bys id (visit_date): egen first_art_refil_due=first(art_refill_due_date)

foreach var of varlist ///
	first_prevart_refil_due first_prevart_refil_done ///
	first_art_refil_done first_art_refil_due {
		capture drop `var'1
		bys id (visit_date): mipolate `var' visit_date, gen(`var'1) groupwise
		format `var'1 %td
		capture drop `var'
		rename `var'1 `var'
}

replace hiv=0 if hiv==2 & next_hiv==0 & ///
	first_prevart_refil_due==. & first_prevart_refil_done==. & ///
	first_art_refil_done==. & first_art_refil_due==. & ///
	init_enrol_time==. & art_init_due_date==. & art_init_done_date==.
	// Say client is negative if they have neg recorded at a subsequent visit
	// and don't have any ART refill or initiation due or done dates


* --> Clean HIV using maternal art init due date: due<3 months is tested pos
replace hiv=2 if ///
	abs(art_init_due_date - enrol_date)<= 91.25 & ///
	hiv==0 & ///
	art_init_done_date==. 

	
* --> Due date more than 3 months is known positive
replace hiv=1 if ///
	(art_init_due_date - enrol_date)<=-91.25 & ///
	art_init_done_date==. & ///
	art_init_due_date!=. & ///
	hiv!=2
	
bys id (visit_date): replace hiv=0 if hiv==1 & hiv[_n-1]==0 & hiv[_n+1]==0 & ///
	first_prevart_refil_due==. & first_prevart_refil_done==. & ///
	first_art_refil_done==. & first_art_refil_due==. & ///
	init_enrol_time==. & art_init_due_date==. & art_init_done_date==.

bys id (visit_date): replace hiv=0 if hiv==1 & hiv[_n-1]==0 & hiv[_n+1]==3 & ///
	first_prevart_refil_due==. & first_prevart_refil_done==. & ///
	first_art_refil_done==. & first_art_refil_due==. & ///
	init_enrol_time==. & art_init_due_date==. & art_init_done_date==.


* --> Replace status to known pos if marked as known pos in last form and have a 
*	  refill due or done date		
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & first_prevart_refil_due!=.
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & first_prevart_refil_done!=.
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & first_art_refil_done!=.
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & first_art_refil_due!=.
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & art_init_due_date!=.
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_N]==1 & art_init_done_date!=.


* --> Known positive to negative - Known positive
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_n-1]==1
bys id (visit_date): replace hiv=1 if hiv==0 & hiv[_n+1]==1


* --> Known positives to unknown
bys id (visit_date): replace hiv=1 if hiv[_n-1]==1 & hiv==3


* --> Negative that became known positive
bys id (visit_date): replace hiv=2 if hiv[_n-1]==0 & hiv==1


* --> Known positive to tested positive
bys id (visit_date): replace hiv=1 if hiv==2 & hiv[_n-1]==1


* --> Tested positive to negative 
bys id (visit_date): replace hiv=2 if hiv[_n-1]==2 & hiv==0


* --> Tested positive-positive
bys id (visit_date): replace hiv=2 if hiv[_n-1]==2 & hiv==1


* --> Tested positive-unknown
bys id (visit_date): replace hiv=2 if hiv[_n-1]==2 & hiv==3


* --> Known positives to unknown
bys id (visit_date): replace hiv=1 if hiv[_n-1]==1 & hiv==3


* --> Unknown positives to known positive
bys id (visit_date): replace hiv=1 if hiv[_N]==1 & hiv==3

cap drop next_hiv
bys id (visit_date): gen next_hiv=hiv[_n+1]
tab hiv next_hiv, m


* --> Clean HIV status
cap drop hiv_status_clean
gen hiv_status_clean=.
bys id (visit_date): replace hiv_status_clean=2 if hiv[1]==2 
	// Filling the tested positives 

bys id (visit_date): replace hiv_status_clean=1 if hiv[1]==1
	// Filling the known positives 
	
replace hiv_status_clean=hiv if hiv_status_clean==.
	// Filling the remaining

capture drop next_hiv_status_clean
bys id (visit_date): gen next_hiv_status_clean=hiv_status_clean[_n+1]
tab hiv_status_clean next_hiv_status_clean, m
label val hiv_status_clean hiv_status


* --> Generating first captured HIV status
bys id (visit_date): egen first_hiv_status=first(hiv_status_clean)
bys id: mipolate first_hiv_status visit_date, gen(first_hiv_status1) groupwise
drop first_hiv_status
rename first_hiv_status1 first_hiv_status
label val first_hiv_status hiv_status


* --> Generate HIV status at registration 
bys id (visit_date): gen hiv_status_reg=hiv_status[1]  
label val hiv_status_reg hiv_status


* --> Generating hiv status (clean) at registration based on cleaned HIV status
bys id (visit_date): gen hiv_status_reg_clean= hiv_status_clean[1]
label var hiv_status_reg_clean ///
	"HIV status (cleaned HIV status) at m2m registration" 
label val hiv_status_reg_clean hiv_status


* --> Seronversion
capture drop serocon
gen serocon=.
bys id (visit_date): replace serocon=1 if hiv_status_clean[_n]==2 ///
	& hiv_status_clean[_n-1]==0

	
* --> Time to seroconversion
gen time_serocon= ///
	round(((visit_date - enrol_date)/30.4),1) if serocon==1
bys id (visit_date): mipolate time_serocon visit_date, ///
	gen(time_serocon1) groupwise
drop time_serocon
rename time_serocon1 time_serocon
lab var time_serocon "Time from m2m enrolment to seroconversion in months"

gen serocon_year = year(visit_date) if serocon==1
bys id (visit_date): mipolate serocon_year visit_date, ///
	gen(serocon_year1) groupwise
drop serocon_year
rename serocon_year1 serocon_year
lab var serocon_year "Seroconversion year"

bys id (visit_date): mipolate serocon visit_date, gen(serocon1) groupwise
drop serocon
rename serocon1 serocon
replace serocon=0 if serocon==.
label var serocon "Seroconverted in the program"

tab serocon if id_tag==1
tab neg_pos if id_tag==1
	// 512 clients marked as sero-converted during m2m care by Jude's code
	// compared to mine which is a bit more than double.
*/	
	


	
*------------------------------------------------------------------------------*		
* Maternal ART initiation
/*
Jude's analysis goes through a lot of convoluted steps to come up with an
ART initiation due date. The code is in the do file '5. Serocon cleaning...'
I don't replicate it perfectly here because it seems to include a lot of
unnecessary steps and goes around in circles a bit. Basically it takes
the value for ART initiation due date if entered, and then replaces it with the
earliest refill due date if it is missing. This is the same as what is done
in other analyses like Malawi's Expert Client reporting.
*/

* --> Earliest and latest ART initiation due and done date per client
/*
Using this to check cases where a client has more than one due or done date
for their ART initiation
*/
foreach x in min max {
	egen art_init_due_date_`x'=`x'(art_init_due_date), by(id)
	egen art_init_done_date_`x'=`x'(art_init_done_date), by(id)
	format %d art_init_d*e_date_`x'
}
count if art_init_due_date_min!=art_init_due_date_max & id_tag==1
count if art_init_done_date_min!=art_init_done_date_max & id_tag==1
	// 2824 clients have different init due dates and 2313 clients have diff
	// done dates.
/*
sort id visit_date
br id_s enrol_date visit_date hiv_status_an hiv_status_pn hiv_status ///
	art_init_due_date_m* art_init_done_date_m* if neg_pos==1
	
br id_s enrol_date visit_date hiv_status ///
	art_init_due_date_m* art_init_done_date_m* if ///
	(art_init_due_date_min!=art_init_due_date_max | ///
	art_init_done_date_min!=art_init_done_date_max) & ///
	neg_pos==1

br id_s enrol_date visit_date hiv_status ///
	art_init_due_date_m* art_init_done_date_m* if ///
	(art_init_due_date_min<enrol_date-30  | ///
	art_init_done_date_min<enrol_date-30) & ///
	neg_pos==1
*/
	// As expected, some weird things going on, like due or done dates for
	// same client differing, sometimes by a lot, or the date coming before
	// enrolment. SOmetimes it is clearly a typo on month or year, other times
	// there is no way to know why the dates are what they are. Jude's analysis
	// presented in his slides doesn't go into ART initiation but he uses
	// it to identify clients as HIV positive at enrolment or not and seems
	// to have taken the date as correct rather than the recorded status
	// and therefore made clients positive at enrolment who had an ART init
	// date before enrolment. I will do the same.


* --> Remove dates that fall before DOB or after the end of the period.
foreach var of varlist ///
	art_init_due_date art_init_done_date ///
	art_refill_prev_due_date art_refill_prev_done_date ///
	art_refill_due_date art_refill_done_date ///
	art_refill_next_due_date {
		replace `var'=. if `var'<dob
		replace `var'=. if `var'>$end_period
}


* --> Recreate min and max after cleaning step above
foreach x in min max {
	cap drop art_init_due_date_`x'
	egen art_init_due_date_`x'=`x'(art_init_due_date), by(id)
	cap drop art_init_done_date_`x'
	egen art_init_done_date_`x'=`x'(art_init_done_date), by(id)
	format %d art_init_d*e_date_`x'
}


* --> Earliest of refill due and done dates within a form and across all forms
foreach x in due {
	foreach y in min max {
		cap drop art_refill_`x'_`y'_x
		egen art_refill_`x'_`y'_x= ///
			row`y'(art_refill_prev_`x'_date art_refill_`x'_date art_refill_next_`x'_date)
		egen art_refill_`x'_`y'=`y'(art_refill_`x'_`y'_x), by(id)
		label var art_refill_`x'_`y' "`y' of all ART refill `x' dates"
		format %d art_refill_`x'_`y'
		drop art_refill_`x'_`y'_x
	}
}

foreach x in done {
	foreach y in min max {
		cap drop art_refill_`x'_`y'_x
		egen art_refill_`x'_`y'_x= ///
			row`y'(art_refill_prev_`x'_date art_refill_`x'_date)
		egen art_refill_`x'_`y'=`y'(art_refill_`x'_`y'_x), by(id)
		label var art_refill_`x'_`y' "`y' of all ART refill `x' dates"
		format %d art_refill_`x'_`y'
		drop art_refill_`x'_`y'_x
	}
}
	// Have to do dues and dones separately because there is no 'next done'
	// date.	

	
* --> ART initiation due date including earliest refill due date
foreach x in due done {
	replace art_init_`x'_date=art_refill_`x'_min if ///
		art_init_`x'_date==. & art_refill_`x'_min!=.
	drop art_init_`x'_date_min art_init_`x'_date_max
	egen art_init_`x'_date_min=min(art_init_`x'_date), by(id)
	drop art_init_`x'_date
	ren art_init_`x'_date_min art_init_`x'_date
	label var art_init_`x'_date "Client's ART initiation `x' date"
	format %d art_init_`x'_date
}

tab art_init_due_date if neg_pos==1 & id_tag==1, m
tab art_init_done_date if neg_pos==1 & id_tag==1, m
	// Of 1114 clients who seroconvert under our care, 157 are missing a due 
	// date for ART initiation and 178 are missing a done date for initiation
	// after I filled in blanks with earliest refill date.




*------------------------------------------------------------------------------*
* Identify sample of clients for testing, seroconversion etc
/*
This section identifies the final sample to use for HIV testing, seroconversion,
family planning etc. It is defined as:
- HIV status in new client form is negative as long as HIV status in AN or PN
  form submitted on the same day (i.e. enrolment) wasn't positive
- Does not have a positive status in AN or PN form recorded at a visit that took
  place within 1-14 days of enrolling
- Does not have an ART initiation done date before enrolment
- Does not go back to a negative status after having a positive status recorded
  at some point.
*/

tab neg_enrol if id_tag==1, m
	// 68700 clients marked as negative at enrolment according to the status
	// variables in new client, AN and PN forms (primarily defined based on
	// status recorded in new client form but those entered as positive in the
	// AN or PN form that was submitted on the same day as the new client form
	// are excluded from this variable).
	
cap drop sample_testing
gen sample_testing=neg_enrol==1
tab sample_testing if id_tag==1

count if time_to_pos<=14 & sample_testing==1 & id_tag==1
replace sample_testing=0 if time_to_pos<=14
	// 73 clients in the sample tested positive within 14 days of enrolment - 
	// exclude.
	
count if art_init_done_date<=enrol_date & sample_testing==1 & id_tag==1
replace sample_testing=0 if art_init_done_date<=enrol_date
	// 290 clients in the sample have an ART start date before their enrolment
	// date even though they are supposed to have been negative at enrolment.
	// Exclude.
	
count if status_lastrec==0 & neg_pos==1 & id_tag==1
replace sample_testing=0 if status_lastrec==0 & neg_pos==1
	// 201 clients in the sample were recorded as going from negative to pos
	// but are negative in their last form. Exclude.
	
tab neg_enrol sample_testing if id_tag==1
	// Of the 68700 clients marked as negative at enrolment, 68301 are in the  
	// sample after the exclusions above.

tab neg_pos if sample==1 & id_tag==1	
	// Of the sample, 495 seroconvert.

	
/*
sort neg_pos id visit_date
br id_s enrol_date art_init_done_date hiv_status_new  ///
	visit_date hiv_status ///
	neg_pos if sample==1 
*/


* --> Create seroconversion variable
gen serocon=sample==1 & ever_pos==1
label var serocon "Seroconverted in the program"
tab serocon if sample==1 & id_tag==1, m
		// 495 versus 512 using Jude's method above.
		
	
	

*------------------------------------------------------------------------------*		
* Time to seroconversion

cap drop time_serocon_days
gen time_serocon_days=time_to_pos
label var time_serocon_days "# days between enrolment and sero-conversion"
replace time_serocon_days=. if sample!=1
	// Only have a value for those in the sample just to be sure we are only
	// looking at time to conversion of those in the sample.
	
gen time_serocon=round(time_serocon_days/30.5, 1)
label var time_serocon "# months between enrolment and sero-conversion"
tab time_serocon if ever_pos==1 & sample==1 & id_tag==1
gen serocon_year=year(visit_date_pos)
label var serocon_year "Year in which client sero-converted"
tab serocon_year if id_tag==1
/*
sort id visit_date
br id_s enrol_date visit_num visit_date hiv_status visit_date_pos ///
	time_serocon serocon if ever_pos==1
*/




*------------------------------------------------------------------------------*		
* Save dataset

save "$temp/an_pn_cleaned.dta", replace
tab sample if id_tag==1
	// 119373 clients in total, 68301 in sample for testing etc.

