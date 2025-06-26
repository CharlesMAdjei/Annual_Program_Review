*** APR 2020 - Community analysis - 95 95 95
*** Basic variable creation for children and adolescents
* 26 May 2021



*------------------------------------------------------------------------------*
* Create childadol dataset

* --> Open index client registration dataset and merge with childadol
use "$temp/reg_hhmem.dta", clear
drop if dreg_hhmem_timeend_date<td(01jan2020) | ///
	dreg_hhmem_timeend_date>td(30jun2021)
merge 1:m hhmem_id using "$temp/childadol.dta"
drop if dchildadol_timeend_date<$beg_period1 | ///
	(dchildadol_timeend_date>$end_period & dchildadol_timeend_date<.)
drop if _merge==2
	// Drop those only in the child-adol dataset.

tab dreg_hhmem_hhmem_type
keep if inlist(dreg_hhmem_hhmem_type, "child_adolescent")
count
	// Keep children and adolescents
	
	
* --> Fill in missing country and facility in reg form with childadol form
foreach i in country facility {
	gen `i'=dreg_hhmem_`i'
	replace `i'=dchildadol_`i' if `i'=="" 
	count if `i'==""
}

	
* --> Keep eligible sites 
cap drop _merge
merge m:1 facility using "$ninety_five/Input/community_sample.dta"
	// Seems like there are no observations for Makoanyane Military Hosp.??
	
keep if _merge==3
drop _merge


* --> Make usable person identifier and count of form submissions
ren id caseid
label var caseid "Index client caseid from HH mem reg form"
rename hhmem_id hhmem_caseid
egen hhmem_id=group(hhmem_caseid)
sort hhmem_id dchildadol_timeend_date
bysort hhmem_id: gen obs=cond(_N==1,1,_n)


* --> Client and site tag
egen fac_tag=tag(facility)
tab fac_tag
egen id_tag=tag(hhmem_id)
tab id_tag
tab country if id_tag==1
	// Sample sizes:
		// Kenya: 753
		// Malawi: 8120
		// Zambia: 1943

		


*------------------------------------------------------------------------------*
* Date of enrolment with m2m
/*
Take the date of the reg index form as the date of enrolment. More reliable
than the manually entered variable and it is what we do in other analyses.
*/

* --> Create numeric enrolment date
gen enrolment_date=dreg_hhmem_timeend_date
format %d enrolment_date
label var enrolment_date "Enrolment date with m2m"


* --> Year of enrolment
gen enrolment_year=yofd(enrolment_date)
tab enrolment_y if id_tag==1


* --> Drop those enrolled outside of the relevant period
*ren keep_2020 keep_1y
*ren keep_2019_2020 keep_2y
drop if enrolment_date<td(01jan2020)
tab country if id_tag==1
drop if enrolment_date<td(01jan2021) & keep_3y==0 & keep_1y==1
drop if enrolment_date>td(30jun2021)
tab country if id_tag==1
	// Those before 1 Jan 2020 are removed for the facilities that are only
	// in the 1 year analysis
	// Sample sizes:
		// Kenya: 753 --> 753
		// Malawi: 8120 --> 4179
		// Zambia: 1943 --> 1864

replace keep_1y=0 if enrolment_date<td(01jan2021)
	// Must exclude clients that enrolled before 1 Jan 2020 for the 1
	// year analysis so the samples are equivalent - i.e. all enrolled between
	// 1 Jan and 30 Jun 2020.
	
tab1 keep* if id_tag==1, m	
	// 3463 in the 2 year sample, 4029 in the 1 year sample
	
	
	
		
*------------------------------------------------------------------------------*
* DOB, age and sex

* --> DOB 
foreach x in reg_hhmem_dob childadol_dob {
	cap drop `x'
	gen `x'x=date(d`x', "YMD") 
	replace `x'x=date(d`x', "DMY") if `x'==.
	egen `x'=max(`x'x), by(hhmem_id)
	format %d `x'
}
/*
count if reg_hhmem_dob!=childadol_dob & childadol_dob!=. & reg_hhmem_dob!=.
br reg_hhmem_dob childadol_dob ///
	if reg_hhmem_dob!=childadol_dob & childadol_dob!=. & reg_hhmem_dob!=.
*/

gen dob=reg_hhmem_dob
replace dob=childadol_dob if dob==.
format %d dob
count if dob!=childadol_dob & childadol_dob!=. & id_tag==1
	// 13 children/adolescents have a difference between the DOB in the hhmem
	// reg form and their child adol form. Not enough to worry about.

label var dob "Date of birth"
count if dob==. & id_tag==1
tab dob if id_tag==1


* --> Age at enrolment 
gen age_enrol=round((enrolment_date-dob)/365, 0.1)
label var age_enrol "Age in years at enrolment"
tab age_enrol if id_tag==1
count if age_enrol<2 & id_tag==1
	// Not sure why these have been entered into the child form and not the
	// infant form. Maybe just an error or otherwise because they aren't the
	// child of the index client?
	
count if age_enrol>=20 & age_enrol<. & id_tag==1
replace age_enrol=. if age_enrol>=20
replace dob=. if age_enrol>=20
count if age==. & id_tag==1
gen age_missing=age==.
tab age_miss if id_tag==1
	// 1% missing age at enrolment

	
* --> Age categorical variable
replace age_enrol=round(age_enrol, 1)
replace age_enrol=19 if age_enrol==20
	// These poeple were rounded up to 20 in the command above.
	
recode age_enrol ///
	(0/1=1 "0-1 years old") ///
	(2/9=2 "2-9 years old") ///
	(10/19=3 "10-19 years old") ///
	(20/24=4 "20-24 years old") ///
	(25/34=5 "25-34 years old") ///
	(35/max=6 "35+ years old") ///
	(.=7 "Missing"), ///
	gen(age_enrol_cat)
label var age_enrol_cat "Age at enrolment (categories)"
tab age_enrol_cat, m
tab age_enrol_cat country, m


* --> Sex
tab dchildadol_gender, m
gen sex=dchildadol_gender=="male"
tab sex, m



	
*------------------------------------------------------------------------------*
* HIV status at enrolment
	
* --> HIV status in reg index form	
tab dreg_hhmem_hiv_status if id_tag==1, m
gen status_enrol=0 if strpos(dreg_hhmem_hiv_status, "negative")
replace status_enrol=1 if strpos(dreg_hhmem_hiv_status, "positive")
replace status_enrol=2 if strpos(dreg_hhmem_hiv_status, "unknown")
label def status 0"Negative" 1"Positive" 2"Unknown"
label val status_e status
label var status_enrol "Status at enrolment"
tab status_e if id_tag==1, m
	// This is thus far based on the HIV status captured in the reg hhmem form.
	// However, there are of course cases where the client has a different
	// status in the childadol form submitted on the same day.

	
* --> HIV status in childadol form
gen status_childadol=1 if strpos(dchildadol_hiv_status, "positive")
replace status_childadol=0 if strpos(dchildadol_hiv_status, "negative")
replace status_childadol=2 if strpos(dchildadol_hiv_status, "unknown")
label val status_childadol status
label var status_childadol "HIV status in childadol form"
tab status_childadol

gen status_childadol1x=status_childadol if obs==1
egen status_childadol_first=max(status_childadol1x), by(hhmem_id)
drop status_childadol1x
label var status_childadol_first "HIV status in first childadol form"
label val status_childadol_first status
tab status_childadol_first if id_tag==1, m


* --> Compare HIV status in reg index and childadol on first submission	
gen same_dayx=enrolment_date==dchildadol_timeend_date 
egen same_day=max(same_dayx), by(hhmem_id)
drop same_dayx
label var same_day "1st childadol form submitted on same day as reg index form"
count if status_enrol!=status_childadol_first & same_day==1 & ///
	status_enrol<2 & status_childadol_first<2
/*
sort hhmem_id obs
br hhmem_id obs status_enrol status_childadol_first if ///
	status_enrol!=status_childadol_first & same_day==1 & ///
	status_enrol<2 & status_childadol_first<2
*/

replace status_enrol=status_childadol_first if same_day==1 & ///
	status_childadol_first!=2
	// Give priority to status in childadol form if it is different to
	// status in reg index form and submitted on the same day as the reg index
	// form.

replace status_enrol=status_childadol_first if status_enrol>=2 & ///
	status_childadol_first<2
	// For those who are unknown in the reg hh mem form and have a known
	// status in their first child adol form, take the child adol form.
	
tab status_enrol if id_tag==1, m
tab status_childadol_first if status_enrol==2 & id_tag==1, m

tab country if id_tag==1 & status_enrol!=1
	// Sample sizes of non-positive children and adolescents:
		// Kenya: 731
		// Malawi: 3770
		// Zambia: 1820
		// All countries still viable for an analysis of testing amongst
		// those not positive at enrolment.
		
		
* --> Check for changes over time that don't make sense
egen obs_max=max(obs), by(hhmem_id)
gen status_childadol_lastx=status_childadol if obs==obs_max
egen status_childadol_last=max(status_childadol_lastx), by(hhmem_id)
label var status_childadol_last "HIV status in last childadol form"
count if status_enrol==1 & status_childadol_last!=1
/*
sort facility hhmem_id obs
br hhmem_id obs status_enrol status_childadol if ///
	status_enrol!=status_childadol_last
*/
	// Seems OK
	
count if status_enrol!=status_childadol_last & status_enrol==0
tab status_childadol_last if ///
	status_enrol!=status_childadol_last & status_enrol==0 & id_tag==1, m
	// Of those who started out negative and have a different status in
	// their latest childadol form, 15 are positive and 641 have no
	// status. 
	
	

	
*------------------------------------------------------------------------------*
* Visit dates and m2m exposure
/*
Visit date is based on the completion time of the childadol form. 
Most children/adols should have a childadol form submitted at the same time 
as the reg form so the first visit is the same as enrolment for those clients. 
However, there are some who only have a reg hhmem form and no childadol forms 
so they are missing data for anything about visit dates.
*/

* --> Visit date (based on childadol timeend date)
gen visit_date=dchildadol_timeend_date
format %d visit_date
label var visit_date "Visit date (childadol form sub date)"


* --> First and last visit dates
egen visit_date_first=min(visit_date), by(hhmem_id)
format %d visit_date_first
label var visit_date_first "Date of first home visit (1st childadol form)"
egen visit_date_last=max(visit_date), by(hhmem_id)
	label var visit_date_last "Date of last home visit (last childadol form)"
format %d visit_date_last
tab1 visit_date_*st, m
	// Those without a first or last visit are those who never had a childadol
	// form submitted.
	

* --> m2m exposure
gen m2m_exp=round((visit_date_last-enrolment_date)/30.5, 1)
label var m2m_exp "Client m2m exposure (months)"
replace m2m_exp=0 if m2m_exp<0 | m2m_exp==.

recode m2m_exp ///
	(0/0=0 "0 months (single visit)") ///
	(0.01/5.49=1 "1. 0-5 months") ///
	(5.50/11.49=2 "2. 6-11 months") ///
	(11.50/17.49=3 "3. 12-17 months") ///
	(17.50/24=4 "4. 18-24 months"), ///
	gen(m2m_exp_cat)
label var m2m_exp_cat "Client m2m exposure"
tab m2m_exp_cat if id_tag==1, m
	
recode m2m_exp ///
	(0=0 "0 months (seen at single visit)") ///
	(0.01/1.49=1 "1 month") ///
	(1.50/2.49=2 "2 months") ///
	(2.50/3.49=3 "3 months") ///
	(3.50/4.49=4 "4 months") ///
	(4.50/5.49=5 "5 months") ///
	(5.50/6.49=6 "6 months") ///
	(6.50/12.49=7 "7-12 months") ///
	(12.50/17.49=8 "12-18 months") ///
	(17.50/24=9 "18-24 months"), ///
	gen(m2m_exp_cat2)
label var m2m_exp_cat2 "Client m2m exposure version 2"
tab m2m_exp_cat2 if id_tag==1, m

gen m2m_exp_1yrplus=m2m_exp>=12 & m2m_exp<.
label var m2m_exp_1yrplus "Client m2m exposure > 1 year"
label val m2m_exp_1yrplus yes_no
tab m2m_exp_1yrplus if id_tag==1 & keep_2y==1, m
	// Vast majority of the 2 year sample has less than 12 months of m2m exp.
	
	


*------------------------------------------------------------------------------*
* Number of visits 
/*
This is a count of form submissions in the childadol form which actually records
services delivered. Those without any childadol forms are assigned a value of 
0 for visits. 
*/

* --> Total number of visits per client
egen unique_visit_date=tag(hhmem_id visit_date)
egen numvisits_total=total(unique_visit_date), by(hhmem_id)
label var numvisits_total "Total visits to client"
tab numvisits_total if id_tag==1
	
recode numvisits_total ///
	(5/max=5 "5+"), ///
	gen(numvisits_total_cat)
label var numvisits_total_cat "Total visits to client"
label def visits_1_5_lab 0"0" 1"1" 2"2" 3"3" 4"4" 5"5+"
label val numvisits_total_cat visits_1_5_lab
tab numvisits_total_cat if id_tag==1


* --> Number of visits (0-3 months after enrolment)
/*
I copy dates that occur between enrolment up until 3 months post enrolment. 
As above, if the first childadol form is submitted at the same time as the
reg index form, i.e. at enrolment, then this is counted as the first visit.
*/

gen enrolment_plus3m=enrolment_date+91.5
format %d enrolment_plus3m

gen visit_date_3m=visit_date if visit_date>=enrolment_date & ///
	visit_date<=enrolment_plus3m
format %d visit_date_3m
label var visit_date_3m "Visit date (0-3m with m2m)"

egen unique_date_3m=tag(hhmem_id visit_date_3m)
egen numvisits_3m=total(unique_date_3m), by(hhmem_id)
label var numvisits_3m "# visits in first 3 months with m2m"
tab numvisits_3m if id_tag==1

recode numvisits_3m ///
	(5/max=5 "5+"), ///
	gen(numvisits_3m_cat)
label var numvisits_3m_cat "# visits in first 3 months with m2m"
tab numvisits_3m_cat if id_tag==1, m


* --> Household visits (1st year with m2m)
gen enrolment_plusyr1=enrolment_date+365
gen visit_date_yr1=visit_date if visit_date>=enrolment_date & ///
	visit_date<=enrolment_plusyr1
format %d visit_date_yr1
label var visit_date_yr1 "Visit date in first year with m2m"

egen unique_date_yr1=tag(hhmem_id visit_date_yr1)
egen numvisits_yr1=total(unique_date_yr1), by(hhmem_id)
label var numvisits_yr1 "# visits in first year with m2m"
tab numvisits_yr1 if id_tag==1

recode numvisits_yr1 ///
	(5/max=5 "5+"), ///
	gen(numvisits_yr1_cat)
label var numvisits_yr1_cat "# visits in first year with m2m"
tab numvisits_yr1_cat if id_tag==1, m


* --> Household visits (in 2021)
gen visit_date_2021=visit_date if visit_date>=td(01jan2021) & ///
	visit_date<=td(31dec2021)
format %d visit_date_2021
label var visit_date_2021 "Visit date (2021)"

egen unique_date_2021=tag(hhmem_id visit_date_2021)
egen numvisits_2021=total(unique_date_2021), by(hhmem_id)
label var numvisits_2021 "# visits in 2021"
tab numvisits_2021 if id_tag==1

recode numvisits_2021 ///
	(5/max=5 "5+"), ///
	gen(numvisits_2021_cat)
label var numvisits_2021_cat "# visits in 2021"
tab numvisits_2021_cat if id_tag==1, m




*------------------------------------------------------------------------------*
* Gap in days between visits
/*
This creates a separate dataset that is in wide format that is used for the
output on gap between visits.
*/

preserve

* --> Identify max number of visits and declare data to be time series
egen maxobs=max(obs)
local max_visits=maxobs
di `max_visits'
	// Need this for loop below.
	
tsset hhmem_id obs
	

* --> Calculate gap in days between visits
bysort hhmem_id (obs): generate gap_days=visit_date-L.visit_date
label var gap_days "Gap between visit dates (days)"


* --> Reshape to wide (because that's how the analysis code is written)
keeporder country hhmem_caseid age_enrol obs visit_date_last visit_date ///
	gap_days enrolment_date status_enrol keep*
reshape wide visit_date-gap_days, i(hhmem_caseid) j(obs)
replace gap_days1=visit_date1-enrolment_date
drop if gap_days1<0
	
	
* --> Categorical variable for gap in days
forvalues i=1/`max_visits' {
	recode gap_days`i' ///
		(0=0 "0. 0 days") ///
		(1/30=1 "1. 1-30 days") ///
		(31/60=2 "2. 31-60 days") ///
		(61/90=3 "3. 61-90 days") ///
		(91/max=4 "4. >90 days"), ///
		gen(gap_days`i'_cat)
	label var gap_days`i'_cat ///
		"Gap between visit `i' & the previous visit in days" 
}
label var gap_days1_cat "Gap between enrolment and visit 1 in days"


* --> Calculate gap in days between last visit and end of obs period
gen end_period=$end_period 
format %d end_period

gen gap_days_lastv_end=end_period-visit_date_last 
recode gap_days_lastv_end ///
	(0=0 "0. 0 days") ///
	(1/30=1 "1. 1-30 days") ///
	(31/60=2 "2. 31-60 days") ///
	(61/90=3 "3. 61-90 days") ///
	(91/max=4 "4. >90 days"), ///
	gen(gap_days_lastv_end_cat)
label var gap_days_lastv_end_cat ///
	"Gap between lst visit and 31 Dec 2021 in days" 

	
* --> Save data for output
gen db="childadol"
save "$temp/childadol - gap betw visits - both samples.dta", replace

restore




*------------------------------------------------------------------------------*
* HIV test dates

* --> Numeric test date
cap drop hivtest_date
gen hivtest_date=date(dchildadol_hiv_retest_done_date, "YMD") 
replace hivtest_date=date(dchildadol_hiv_retest_done_date, "DMY") if ///
	hivtest_date==.
format %d hivtest_date
label var hivtest_date "HIV test date"

cap drop hcttest_date
gen hcttest_date=date(dchildadol_hct_done_date, "YMD") 
replace hcttest_date=date(dchildadol_hct_done_date, "DMY") if ///
	hcttest_date==.
format %d hcttest_date
label var hcttest_date "HCT test date"

count if hcttest_date!=. & hivtest_date!=.
replace hivtest_date=hcttest_date if hivtest_date==.


* --> Compare HIV test dates to enrolment date to see when they happened
gen hivtest_befenrol=hivtest_date<enrolment_date if hivtest_date!=.
label var hivtest_befenrol "HIV test date before enrolment date"
tab hivtest_befenrol
	// 40% of recorded HIV test dates are before enrolment

	
* --> Result
gen hivtest_result=dchildadol_hiv_result=="tested_positive" if ///
	dchildadol_hiv_result!=""
label val hivtest_result status
label var hivtest_result "HIV test result"

gen hcttest_result=dchildadol_hct_result=="tested_positive" if ///
	dchildadol_hct_result!=""
label val hcttest_result status
label var hcttest_result "HCT test result"
count if hcttest_result!=. & hivtest_result!=.
replace hivtest_result=hcttest_result if hivtest_result==.


* --> HIV test date that is only populated if it is after enrolment
foreach x in hiv {
	cap drop `x'test_date_postenrol
	gen `x'test_date_postenrol=`x'test_date if `x'test_date>enrolment_date
	label var `x'test_date_postenrol "`x' test date if post-enrol"
	format %d `x'test_date_postenrol 
}

* --> HIV test date that is only populated for tests that have a result
foreach x in hiv {
	cap drop `x'test_date_r
	gen `x'test_date_r=`x'test_date if `x'test_result<=1
	label var `x'test_date_r "`x' test date if there is a result"
	format %d `x'test_date_r 
}

* --> HIV test date that is only populated for tests that have a result AND are
*	  after enrolment
foreach x in hiv {
	cap drop `x'test_date_r2
	gen `x'test_date_r2=`x'test_date_postenrol if `x'test_result<=1
	label var `x'test_date_r2 "`x' test date if post-enrol & has a result"
	format %d `x'test_date_r2 
}

* --> HIV test result that is only populated if it is after enrolment
foreach x in hiv {
	cap drop `x'test_result_postenrol
	gen `x'test_result_postenrol=`x'test_result if ///
		`x'test_date_postenrol!=.
	label var `x'test_result_postenrol "`x' test result if post-enrol"
	format %d `x'test_result_postenrol 
}




*------------------------------------------------------------------------------*
* First and last HIV test dates and results
/*
Last year for the stat on gap between enrolment and first test, I restricted it
to tests that have a result. I guess I should stick with that? I will do both
and see how different.
*/

* --> First and last test date after enrolment (regardless of result)
egen hivtest_date_first_post=min(hivtest_date_postenrol), by(hhmem_id)
label var hivtest_date_first_post ///
	"First HIV test post-enrol (regardless of result)"
egen hivtest_date_last_post=max(hivtest_date_postenrol), by(hhmem_id)
label var hivtest_date_last_post ///
	"Last HIV test post-enrol (regardless of result)"
format %d hivtest_date_*


* --> First and last test date after enrolment with a result
egen hivtest_date_first_post_result=min(hivtest_date_r2), by(hhmem_id)
label var hivtest_date_first_post_result ///
	"First HIV test post-enrol with result"
egen hivtest_date_last_post_result=max(hivtest_date_r2), by(hhmem_id)
label var hivtest_date_last_post_result ///
	"Last HIV test post-enrol with result"
format %d hivtest_date_*


* --> Result of first and last post-enrol HIV test 
*	  This is regardless of result so some of these values will be missing.
cap drop y
gen y=hivtest_result_postenrol if hivtest_date==hivtest_date_first_post
egen hivtest_result_first_post=max(y), by(hhmem_id)	
cap drop y
gen y=hivtest_result_postenrol if hivtest_date==hivtest_date_last_post
egen hivtest_result_last_post=max(y), by(hhmem_id)
label var hivtest_result_first_post "HIV test result from first post-enrol test"
label var hivtest_result_last_post "HIV test result from last post-enrol test"
label val hivtest_result* status
count if hivtest_date_first_post!=. & id_tag==1 & hivtest_result_first_post==.
tab hivtest_result_first_post if hivtest_date_first_post!=. & id_tag==1, m

count if hivtest_result_last==0 & hivtest_result_first==1 & id_tag==1
	// No one goes from positive to negative
	
	
* --> Result of first and last post-enrol HIV test that have results
gen hivtest_result_firstx=hivtest_result if ///
	hivtest_date==hivtest_date_first_post_result
egen hivtest_result_first_post_result=max(hivtest_result_firstx), by(hhmem_id)
label var hivtest_result_first_post_result ///
	"HIV test result from first post-enrol test with result"

gen hivtest_result_lastx=hivtest_result if ///
	hivtest_date==hivtest_date_last_post_result
egen hivtest_result_last_post_result=max(hivtest_result_lastx), by(hhmem_id)
label var hivtest_result_last_post_result ///
	"HIV test result from last post-enrol test with result"
drop hivtest_result_firstx hivtest_result_lastx	
label val hivtest_result* status
tab hivtest_result_first_post_result if ///
	hivtest_date_first_post_result!=. & id_tag==1, m
tab hivtest_result_last_post_result if ///
	hivtest_date_last_post_result!=. & id_tag==1, m

	

	
*------------------------------------------------------------------------------*
* Number of HIV tests after enrolment

* --> Count of unique HIV test dates per client
egen id_test_tag=tag(hhmem_id hivtest_date_postenrol)
egen total_tests=total(id_test_tag), by(hhmem_id)
replace total_tests=. if status_enrol==1
label var total_tests "Total HIV tests (post-enrol)"
tab total_tests if id_tag==1 & status_enrol!=1, m
drop id_test_tag 


* --> Categorical count of tests incl 0 tests
recode total_tests ///
	(0=0 "0") ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_cat)
label var total_tests_cat "Total HIV tests (post-enrol)"
tab total_tests_cat country if id_tag==1 & status_enrol!=1, m
tab total_tests_cat country if id_tag==1 & status_enrol!=1, col nof m


* --> Categorical count of tests excl. 0 tests
cap drop total_tests_cat_sans0
recode total_tests ///
	(0=.) ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_cat_sans0)
label var total_tests_cat_sans0 ///
	"Total HIV tests (post-enrol) amongst those with 1+ tests"
tab total_tests_cat_sans0 if id_tag==1 & status_enrol!=1


* --> At least 1 test
gen atleast1_test=total_tests>0 if total_tests!=.
label var atleast1_test "At least 1 test after enrolment"
label def yes_no 1"Yes" 0"No"
label val atleast1_test yes_no
tab atleast1_test country if id_tag==1 & status_enrol!=1, m
tab atleast1_test country if id_tag==1 & status_enrol!=1, col nof m




*------------------------------------------------------------------------------*
* Number of tests in 1st year with m2m

* --> HIV test date if in first year (and post-enrol)
gen hivtest_date_x=hivtest_date_postenrol if ///
	hivtest_date_postenrol<=enrolment_date+365


* --> Count of unique HIV test dates per client
egen id_test_tag=tag(hhmem_id hivtest_date_x)
egen total_tests_yr1=total(id_test_tag), by(hhmem_id)
replace total_tests_yr1=. if status_enrol==1
replace total_tests_yr1=. if m2m_exp<12
label var total_tests_yr1 "Total HIV tests (in first yr with m2m)"
drop id_test_tag hivtest_date_x


* --> Categorical count of tests incl. 0 tests
recode total_tests_yr1 ///
	(0=0 "0") ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_yr1_cat)
label var total_tests_yr1_cat "Total HIV tests (in first yr with m2m)"
tab total_tests_yr1_cat


* --> Categorical count of tests excl. 0 tests
cap drop total_tests_yr1_cat_sans0
recode total_tests_yr1 ///
	(0=.) ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_yr1_cat_sans0)
label var total_tests_yr1_cat_sans0 ///
	"Total HIV tests amongst those with 1+ tests (in first yr with m2m)"


* --> At least 1 test
gen atleast1_test_yr1=total_tests_yr1>0 if total_tests_yr1!=.
label var atleast1_test_yr1 ///
	"At least 1 test after enrolment in first yr with m2m"
label val atleast1_test_yr1 yes_no
tab atleast1_test_yr1




*------------------------------------------------------------------------------*
* Number of test dates in 2020

* --> HIV test date if in 2020 (and post-enrol)
gen hivtest_date_x=hivtest_date_postenrol if ///
	hivtest_date_postenrol>=td(01jan2021) & ///
	hivtest_date_postenrol<=td(31dec2021)


* --> Count of unique HIV test dates per client
egen id_test_tag=tag(hhmem_id hivtest_date_x)
egen total_tests_2021=total(id_test_tag), by(hhmem_id)
replace total_tests_2021=. if status_enrol==1
replace total_tests_2021=. if enrolment_date>td(31dec2019)
label var total_tests_2021 "Total HIV tests (in 2021)"
drop id_test_tag hivtest_date_x


* --> Categorical count of tests incl. 0 tests
recode total_tests_2021 ///
	(0=0 "0") ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_2021_cat)
label var total_tests_2021_cat "Total HIV tests (in 2021)"


* --> Categorical count of tests excl. 0 tests
cap drop total_tests_2021_cat_sans0
recode total_tests_2021 ///
	(0=.) ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3/max=3 "3+"), ///
	gen(total_tests_2021_cat_sans0)
label var total_tests_2021_cat_sans0 ///
	"Total HIV tests amongst those with 1+ tests (in 2021)"


* --> At least 1 test
gen atleast1_test_2021=total_tests_2021>0 if total_tests_2021!=.
label var atleast1_test_2021 "At least 1 test after enrolment in 2021"
label val atleast1_test_2021 yes_no
tab atleast1_test_2021 country if id_tag==1, m




*------------------------------------------------------------------------------*
* Gap between enrolment and first test date 
/*
In 2017, I used the first test date whether or not there was a result. 
In 2018, I used the first test date that had a result as it seemed more valid.
In 2019, I replicate 2018.
*/

gen gap_enrol_test1_days=hivtest_date_first_post_result-enrolment_date
label var gap_enrol_test1_days "Gap between enrol-1st HIV test date (days)"
tab gap_enrol_test1_days if id_tag==1, m

	
	
	
*------------------------------------------------------------------------------*
* Set final status to latest test result
/*
Those with no test results will be missing - matches how we did it last year.
*/

gen status_final=1 if status_enrol==1
replace status_final=hivtest_result_last_post_r if status_final==.
replace status_final=2 if status_final==.
label val status_final status
label var status_final ///
	"Final HIV status at end of period (most recent post-enrol test)"
tab status_final if id_tag==1, m
tab total_tests if status_final==. & id_tag==1 
/*
sort id obs
br id enrolment_date obs visit_date ///
	hivtest_date_postenrol hivtest_result_postenrol ///
	hivtest_result_first_post_r hivtest_result_last_post_r total_tests if ///
	status_final==. & total_tests>0 & total_tests<.
*/
	// Those who have 1 or more post-enrol test dates but no final status are
	// those who don't have a test result associated with their test date.


	

*------------------------------------------------------------------------------*
* ART initiation

* --> ART start date
foreach x in reg_hhmem_init_date childadol_init_date {
	cap drop `x'
	gen `x'x=date(d`x', "YMD") 
	replace `x'x=date(d`x', "DMY") if `x'==.
	egen `x'=max(`x'x), by(hhmem_id)
	format %d `x'
}

gen artstart_date=reg_hhmem_init_date
replace artstart_date=childadol_init_date if artstart_date==.
format %d artstart_date
label var artstart_date "Date of ART initiation"
count if status_final!=1 & artstart_date!=.
	// No one who is non-pos at the end of the period has an ART start date.
	
count if status_final==1 & artstart_date==. & id_tag==1
	// 16 positive children/adolescents have no ART start date
	
	
* --> Client has started ART	
tab artstart_date
gen artstart=artstart_date!=.
replace artstart=. if status_final==0
label var artstart "Client has started ART"
label val artstart yes_no
tab artstart if status_final==1 & id_tag==1, m

/*
sort hhmem_id obs
br hhmem_id obs artstart_date ///
	dchildadol_artrefill_done dchildadol_artrefill_latest ///
	dchildadol_artrefill_latest_date if status_final==1
*/


* --> ART refill dates
tab1 dchildadol_artrefill_done dchildadol_artrefill_latest ///
	dchildadol_artrefill_latest_date if status_final==1
foreach x in childadol_artrefill_latest_date {
	cap drop `x'
	gen `x'=date(d`x', "YMD") 
	replace `x'=date(d`x', "DMY") if `x'==.
	format %d `x'
}
egen latest_refill=max(childadol_artrefill_latest_date), by(hhmem_id)
replace artstart=1 if latest_refill!=. 

tab childadol_artrefill_latest_date
gen childadol_has_artref=childadol_artrefill_latest_date!=.
tab country childadol_has_artref if id_tag==1 & status_final==1
	



*------------------------------------------------------------------------------*
* VL testing
/*
VL testing is tricky in App2 data because the date of the test isn't recorded.
We have the due date, a yes/no for whether it was done and the result. I don't
know if each result is a new result or the previous result being copied in 
again. I am going to go with the same analysis as in PMTCT - count of women
with 1 or more VL tests and were they suppressed at their most recent test, 
most recent is taken as their result at their most recent visit.
*/

* --> Make new variables
gen vl_test_done=dchildadol_vl_test_done=="yes" if dchildadol_vl_test_done!=""
label var vl_test_done "VL test done"
label val vl_test_done yes_no
ren dchildadol_vl_result vl_result
label var vl_result "VL result"
ren dchildadol_vl_result_number vl_result_num
label var vl_result_num "VL result number"
destring vl_result_num, replace
foreach x in vl_test_due_date {
	gen `x'=date(dchildadol_`x', "YMD") 
	replace `x'=date(dchildadol_`x', "DMY") if `x'==.
	format %d `x'
}
drop dchildadol_vl*
/*
sort hhmem_id obs
br hhmem_id obs visit_date vl_test_due_date vl_test_done ///
	vl_result if status_final==1
*/


* --> Ever tested
/*
Ever tested is simply the presence of a result since there is no date to 
check whether they were tested while in our care or not. The "done" variable
doesn't seem very useful since it is filled out far less often than the 
result variable.
*/
drop vl_test_done
gen vl_done=vl_result!=""
egen vl_test_ever=max(vl_done), by(hhmem_id)
label var vl_test_ever "Ever received VL test"
label val vl_test_ever yes_no
tab vl_test_ever if status_final==1 & id_tag==1
	// Less than 50% of those positive by the end of the period have 1 or more
	// VL test results recorded.
	
tab vl_test_ever if status_final!=1 & id_tag==1
	// No one who is not marked as positive as their final status has any
	// VL test information - good!
	
replace vl_test_ever=. if status_final!=1
	// Change from 0 to missing since VL testing is NA for them.


* --> VL test result 
/*
Use the definition that suppression is anything below 200 copies/ml
*/
gen vl_supp=vl_result!="need_to_record_a_number" if vl_result!=""
replace vl_supp=1 if vl_result_num<200
replace vl_supp=. if vl_test_ever!=1
	// Carrying on the fix from above.
	
label val vl_supp yes_no
label var vl_supp "VL suppressed (<200 copies/ml)"


* --> Suppressed at most recent VL test
/*
Since the date isn't recorded, I use the visit date as a proxy, and take the
result recorded at the most recent visit.
*/
gen visit_date_vltest=visit_date if vl_supp!=.
egen visit_date_vltest_max=max(visit_date_vltest), by(hhmem_id)
gen vl_supp_lastx=vl_supp if visit_date==visit_date_vltest_max
egen vl_supp_last=max(vl_supp_last), by(hhmem_id)
label var vl_supp_last "Most recent VL test result was suppressed"
label val vl_supp_last yes_no
tab vl_supp_last if vl_test_ever==1 & id_tag==1, m
tab vl_test_ever if status_final==1 & id_tag==1, m
/*
sort hhmem_id obs
br hhmem_id obs vl_result vl_result_num vl_supp*
*/




*------------------------------------------------------------------------------*
* Adherence

* --> Yes/no adherence variables
foreach x in adh_remember adh_stop_better adh_7_forget adh_stop_worse ///
	adh_notadherent {
		cap drop `x'
		gen `x'=(dchildadol_`x'=="1" | dchildadol_`x'=="yes") if ///
			dchildadol_`x'!=""
		replace `x'=. if status_final!=1
}
label var adh_remember "Difficulty remembering to take medication"
label var adh_stop_better "Stop taking medication if feel better"
label var adh_7_forget "Forgot to take 1 or more doses in the last 7 days"
label var adh_stop_worse "Stop taking medication if feel worse"
label var adh_notadherent "Not adherent (yes to 1 or more of adh questions"


* --> Number of doses forgotten in last 7 days
cap drop adh_7_forget_num
gen adh_7_forget_num=dchildadol_adh_7_forget_num
destring adh_7_forget_num, replace
label var adh_7_forget_num "Number of doses forgotten in last 7 days"


* --> 7 day recall (% of doses in last week that were taken)
cap drop x
gen x=7-adh_7_forget_num
cap drop adh_7dayrecall
gen adh_7dayrecall=round(x/7, 0.01)
replace adh_7dayrecall=1 if adh_7_forget==0
label var adh_7dayrecall "7 day recall score"
tab adh_7_forget_num if adh_7_forget==1
tab adh_7dayrecall if id_tag==1 & status_final==1, m
cap drop adh_7dayrecall_average
egen adh_7dayrecall_average=mean(adh_7dayrecall), by(hhmem_id)
replace adh_7dayrecall_average=round(adh_7dayrecall_average, 0.01)
label var adh_7dayrecall_average "Average 7 day recall over all visits"
cap drop adh_7dayrecall_average_cat
recode adh_7dayrecall_average ///
	(0/0.7999=1 "Avg 7 day recall <80% over all visits") ///
	(0.80/0.9499=2 "Avg 7 day recall 80-95% over all visits") ///
	(0.95/1=3 "Avg 7 day recall >95% over all visits"), ///
	gen(adh_7dayrecall_average_cat)
label var adh_7dayrecall_average_cat "Average 7 day recall over all visits"
tab adh_7dayrecall_average_cat if id_tag==1 & status_final==1, 
drop x


* --> Adherence over time
cap drop adherent
gen adherent=1-adh_notadherent
cap drop adh_average
egen adh_average=mean(adherent), by(hhmem_id)
replace adh_average=round(adh_average, 0.01)
label var adh_average "Average adherence over all visits"
cap drop adh_average_cat
recode adh_average ///
	(0/0.7999=1 "Adherent at <80% of visits") ///
	(0.80/0.9499=2 "Adherent at 80-95% of visits") ///
	(0.95/1=3 "Adherent at >95% of visits"), ///
	gen(adh_average_cat)
label var adh_average_cat "Average adherence over all visits"
tab adh_average_cat if id_tag==1 & status_final==1, m


* --> Identify if adherence taken at each visit and ever per client 
gen has_adh_measure=adh_remember!=. | adh_stop_better!=. | ///
	adh_7_forget!=. | adh_stop_worse!=. | adh_notadherent!=.
label var has_adh_measure "Client was assessed for adherence"

cap drop num_adh_measures
egen num_adh_measures=sum(has_adh_measure), by(hhmem_id)
label var num_adh_measures "# adherence measures"
tab num_adh_measures, m

egen ever_has_adh_measure=max(has_adh_measure), by(hhmem_id)
label var ever_has_adh_measure "Client has ever been assessed for adherence"
tab ever_has_adh_measure if id_tag==1, m
tab adh_average_cat if id_tag==1 & status_final==1 & ever_has_adh_measure==1, m
tab adh_average_cat if id_tag==1 & status_final==1, m


* --> % of visits at which client was assessed for adherence
/*
sort id visit_date
br id visit_date has_adh_measure num_adh_measures numvisits_total
*/
cap drop perc_visits_adh_measure
gen perc_visits_adh_measure=round((num_adh_measures/numvisits_total), 0.0001)
replace perc_visits_adh_measure=0 if num_adh_measures==0
replace perc_visits_adh_measure=1 if perc_visits_adh_measure>1 ///
	& perc_visits_adh_measure<.
	// Some people score >100% becuse of the issue above of the number of
	// adh measures being more than the calculated number of visits due to
	// multiple forms being submitted on the same day.

replace perc_visits_adh_measure=1 if num_adh_measures>=1 & ///
	num_adh_measures<. & numvisits_total==0
	// Some clients have 0 for number of visits yet have adherence information
	// because their child/partner form submission date is blank. No idea why that
	// happens sometimes in app2 but it does. So for these clients, I assume
	// that they're measured at 100% of their visits.
	
label var perc_visits_adh_measure "% visits at which adh measure was taken"

gen adh_all_visits=perc_visits_adh_measure==1
label var adh_all_visits "Adherence measure taken at all visits"

tab perc_visits_adh_measure if id_tag==1 & status_final==1, m
tab ever_has_adh_measure if perc_visits_adh_measure==0
tab perc_visits_adh_measure if id_tag==1 & status_final==1 & numvisits_total>=2, m
tab perc_visits_adh_measure if adh_average_cat==.
tab perc_visits_adh_measure if ever_has_adh_measure!=1


* --> % visits at hich client was assessed for adherence in categories
cap drop perc_visits_adh_cat
recode perc_visits_adh_measure ///
	(0/0=0 "Never measured for adherence") ///
	(0.001/0.25=1 "Measured at 1-25% of visits") ///
	(0.2501/0.50=2 "Measured at 25-50% of visits") ///
	(0.5001/0.75=3 "Measured at 50-75% of visits") ///
	(0.7501/0.9999=4 "Measured at 75-99% of visits") ///
	(1/1=5 "Measured at 100% of visits"), ///
	gen(perc_visits_adh_cat)
label var perc_visits_adh_cat "% visits at which adherence was measured"
tab perc_visits_adh_cat if id_tag==1 & status_final==1, m
tab perc_visits_adh_cat if id_tag==1 & adh_average_cat!=., m




*------------------------------------------------------------------------------*
* Save final datasets

label var country "Country"
label var facility "Facility"
label var obs "Observation # in dataset"
label var keep_3y "Facilities to include in 3 year analysis"
label var keep_2y "Facilities to include in 2 year analysis"
label var keep_1y "Facilities to include in 1 year analysis"

keeporder country facility hhmem_caseid caseid obs visit_date* numvisits* ///
	enrolment_date enrolment_y m2m_exp* ///
	dob age_enrol sex status_enrol status_final ///
	hivtest_date hivtest_date_postenrol hivtest_date_r* ///
	hivtest_*_first_post* hivtest_*_last_post* ///
	total_tests* atleast1_test* gap_enrol_test1_days artstart* ///
	vl_test_ever vl_result vl_result_num vl_supp vl_supp_last *adh* keep*
drop visit_date_vltest visit_date_vltest_max

cap drop *tag
egen id_tag=tag(hhmem_caseid)
egen fac_tag=tag(facility)
tab1 *tag

cap drop *tag
gen db="childadol" 


* --> Save 
save "$temp/childadol - full dataset - both samples.dta", replace
forvalues i=1/2 {
	preserve
	keep if keep_`i'y==1
	save "$temp/childadol - full dataset - `i'yr sample.dta", replace
	restore
}

forvalues i=1/2 {
	use "$temp/childadol - gap betw visits - both samples.dta", clear
	keep if keep_`i'y==1
	save "$temp/childadol - gap betw visits - `i'yr sample.dta", replace
}
