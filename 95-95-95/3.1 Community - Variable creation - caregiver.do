*** APR 2020 - Community analysis - 95 95 95
*** Basic variable creation for index clients
* 27 May 2021



*------------------------------------------------------------------------------*
* Create index client dataset

* --> Open index client registration dataset and merge with caregiver
use "$temp/reg_index.dta", clear
duplicates drop 
drop if dreg_index_timeend_date<td(01jan2020) | ///
	dreg_index_timeend_date>td(30jun2021)


* --> Merge with caregiver dataset
merge 1:m id using "$temp/caregiver.dta"
gen index_reg_only=1 if _merge==1
label var index_reg_only "Client only found in index reg form"


* --> Keep clients at eligible sites 
foreach i in country facility {
	gen `i'=dreg_index_`i'
	replace `i'=dcaregiver_`i' if `i'=="" 
	count if `i'==""
}
cap drop _merge
merge m:1 facility using "$ninety_five/Input/community_sample.dta"
keep if _merge==3
drop _merge
drop if index_reg_only==1

* --> Identify earliest form submission in caregiver form
egen earliest_caregiver_form=min(dcaregiver_timeend_date), by(id)
format %d earliest_caregiver_form
drop if earliest_caregiver_form<td(01jan2020)
	// In previous years, I dropped any client not matched across reg index
	// and caregiver forms. However, we discovered that a lot of Zambian
	// clients were dropped because they had been registered on app1 and
	// claimed on app2, meaning they didn't appear in the reg index form.
	// This year I am going to keep all clients who either appear in the
	// reg index form in the relevant enrolment period or, if they don't
	// appear there, appear first in the caregiver form in the relevant 
	// period. May need to see if I need to adjust analysis or bring in
	// informaiton from the new client form in App1 for those clients not in
	// reg index.


* --> Make usable person identifier and count of form submissions
rename id caseid
egen id=group(caseid)
sort id dcaregiver_timeend_date
bysort id: gen obs=cond(_N==1,1,_n)


* --> Client and site tag
egen fac_tag=tag(facility)
tab country fac_tag
egen id_tag=tag(id)
tab id_tag
tab country if id_tag==1
	// Sample sizes:
		// Ghana: 716
		// Kenya: 790
		// Malawi: 12690
		// Zambia: 2599




*------------------------------------------------------------------------------*
* Date of enrolment with m2m
/*
Take the date of the reg index form as the date of enrolment if available. 
If the index client only appears in the caregiver form, presumably because they
were enrolled at the facility and claimed in the community, take their first
caregiver form date as enrolment date.
*/

* --> Create numeric enrolment date and year
cap drop enrolment_date
gen enrolment_date=dreg_index_timeend_date
replace enrolment_date=earliest_caregiver_form if ///
	enrolment_date==.
format %d enrolment_date
label var enrolment_date "Enrolment date with m2m"
cap drop enrolment_year
gen enrolment_year=yofd(enrolment_date)
tab enrolment_y if id_tag==1


* --> Drop those enrolled outside of the relevant period
/*
For the sites that have data for 2019 to 2021, the enrolment period is
1 Jan 2019 - 30 Jun 2021.
For the full pool of sites that have data for 2021, the enrolment period is
1 Jan - 30 Jun 2021.
*/

drop if enrolment_date<$beg_period1
	// Shouldn't drop any more people because of dropping forms above but just
	// to be safe. 
	
drop if enrolment_date<td(01jan2021) & keep_3y==0 & keep_1y==1
	// For those only in the 1 year sample and not in the 2 year sample, drop
	// if they enrolled before 1 Jan 2021
	
drop if enrolment_date>td(30jun2021)
tab country if id_tag==1
	// Those before 1 Jan 2021 are removed for the facilities that are only
	// in the 1 year analysis
	// Sample sizes:
		// Kenya: 790 --> 644
		// Malawi: 12690 --> 6907
		// Zambia: 2599 --> 1796
	
replace keep_1y=0 if enrolment_date<td(01jan2021)
	// Must exclude clients that enrolled before 1 Jan 2020 for the 1 year
	// analysis (ie. 2020 analysis) so the samples are equivalent - i.e. all 
	// must have enrolled between 1 Jan and 30 Jun 2020.
	
tab1 keep* if id_tag==1, m	
	// 1 year sample: 4792
	// 2 year sample: 5661
	
	
	
		
*------------------------------------------------------------------------------*
* Mother characteristics

* --> Mother versus caregiver
tab dreg_index_mother_caregiver if id_tag==1
drop if dreg_index_mother_caregiver=="caregiver"
tab country if id_tag==1
	// Only keep mothers. 
	// Sample sizes:
		// Kenya: 644 --> 599
		// Malawi: 6907 --> 6766
		// Zambia: 1796 --> 1750

	
* --> DOB 
foreach x in reg_index_dob caregiver_dob {
	cap drop `x'
	gen `x'x=date(d`x', "YMD") 
	replace `x'x=date(d`x', "DMY") if `x'==.
	egen `x'=max(`x'x), by(caseid)
	format %d `x'
}
/*
count if reg_index_dob!=caregiver_dob & caregiver_dob!=. & reg_index_dob!=.
br reg_index_dob caregiver_dob ///
	if reg_index_dob!=caregiver_dob & caregiver_dob!=. & reg_index_dob!=.
*/

cap drop dob
gen dob=reg_index_dob
replace dob=caregiver_dob if dob==.
	// Prioritise the DOB in the reg index form. Replace with dob in caregiver
	// form if missing.
	
format %d dob
label var dob "Date of birth"
count if dob==. & id_tag==1
tab dob if id_tag==1
	// A few DOBs that are clearly wrong, as always.
	

* --> Age at enrolment 
gen age_enrol=round((enrolment_date-dob)/365, 1)
label var age_enrol "Age in years at enrolment"
tab age_enrol if id_tag==1
count if age_enrol<10 & id_tag==1
count if age_enrol>60 & age_enrol<. & id_tag==1
replace age_enrol=. if age_enrol<10 | age_enrol>60 
replace dob=. if age_enrol<10 | age_enrol>60 
count if age==. & id_tag==1
gen age_missing=age==.
tab age_miss if id_tag==1
	// 2.8% of sample missing DOB and age

	
* --> Age categorical variable
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
tab age_enrol_cat if id_tag==1, m
tab age_enrol_cat country if id_tag==1, m



	
*------------------------------------------------------------------------------*
* HIV status at enrolment
	
* --> HIV status in reg index form	
tab dreg_index_hiv_status if id_tag==1, m
gen status_reg_index=0 if strpos(dreg_index_hiv_status, "negative")
replace status_reg_index=1 if strpos(dreg_index_hiv_status, "positive")
replace status_reg_index=2 if strpos(dreg_index_hiv_status, "unknown")
label def status 0"Negative" 1"Positive" 2"Unknown"
label val status_reg_index status
label var status_reg_index "Status in index registration form"
tab status_reg_index if id_tag==1, m

	
* --> HIV status in caregiver form
gen status_caregiver=1 if strpos(dcaregiver_hiv_status, "positive")
replace status_caregiver=0 if strpos(dcaregiver_hiv_status, "negative")
replace status_caregiver=2 if strpos(dcaregiver_hiv_status, "unknown")
label val status_caregiver status
label var status_caregiver "HIV status in caregiver form"

cap drop status_caregiver1
gen status_caregiver1=status_caregiver if ///
	dcaregiver_timeend_date==earliest_caregiver_form
cap drop status_caregiver_first
egen status_caregiver_first=max(status_caregiver1), by(id)
label var status_caregiver_first "HIV status in first caregiver form"
label val status_caregiver_first status
/*
sort id dcaregiver_timeend_date
br id dcaregiver_timeend_date dcaregiver_hiv_status earliest_caregiver_form ///
	status_caregiver_first
*/

* --> Compare HIV status in reg index and caregiver on first submission	
gen same_dayx=dreg_index_timeend_date==earliest_caregiver_form 
egen same_day=max(same_dayx), by(id)
drop same_dayx
label var same_day "1st caregiver form submitted on same day as reg index form"
tab same_day if id_tag==1
	// 74% of the sample
	
count if status_reg_index!=status_caregiver_first & same_day==1
/*
sort id obs
br id obs dreg_index_timeend_date earliest ///
	status_reg_index status_caregiver_first if ///
	status_reg_index!=status_caregiver_first & ///
	same_day==1
*/


* --> Create a single variable for status at enrolment
cap drop status_enrol
gen status_enrol=status_reg_index
replace status_enrol=status_caregiver_first if status_reg_index==.
replace status_enrol=status_caregiver_first if same_day==1 & ///
	status_caregiver_first!=2
	// Give priority to status in caregiver form if it is different to
	// status in reg index form and submitted on the same day as the reg index
	// form and is either positive or negative.

replace status_enrol=2 if status_enrol==.
label val status_enrol status
numlabel, add
tab status_enrol if id_tag==1, m
	

* --> Check sample sizes of non-positive clients
tab country if id_tag==1 & status_enrol!=1
	// Sample sizes of index clients who were unknown or negative at enrolment:
		// Kenya: 317 of 599
		// Malawi: 5181 of 6766
		// Zambia: 34 of 1750
		// Total: 5532
		// Zambia is no longer feasible for analysis on testing because of the
		// very small number of women who weren't positive at enrolment. 
		
		
* --> Check for changes over time that don't make sense
egen obs_max=max(obs), by(id)
gen status_caregiver_lastx=status_caregiver if obs==obs_max
egen status_caregiver_last=max(status_caregiver_lastx), by(caseid)
label var status_caregiver_last "HIV status in last caregiver form"
label val status_caregiver_last status
count if status_enrol==1 & status_caregiver_last!=1
tab status_caregiver_last if ///
	status_enrol==1 & status_caregiver_last!=1, m
	
/*
sort facility id obs
br id obs status_enrol status_caregiver if status_enrol!=status_caregiver_last
br id obs status_caregiver status_enrol status_caregiver_last ///
	if status_enrol==1 & ///
	status_caregiver_last!=1
*/
	// Only 1 client goes from positive to negative, and only in their last
	// 3 caregiver form submissions, so will assume it is a mistake. Otherwise
	// the rest are missing or unknown.

replace status_caregiver_last=1 if status_enrol==1 & status_caregiver_last!=1
count if status_enrol!=status_caregiver_last & status_enrol==0 & id_tag==1
tab status_caregiver_last if ///
	status_enrol!=status_caregiver_last & status_enrol==0 & id_tag==1, m
	// Of those who started out negative and have a different status in
	// their latest caregiver form, 47 are positive and 322 have no
	// status.

	

	
*------------------------------------------------------------------------------*
* Visit dates and m2m exposure
/*
Visit date is based on the completion time of the caregiver form. 
Most women should have a caregiver form submitted at the same time as the reg 
index form so the first visit is the same as enrolment for those clients. 
However, there are some who only have a reg index form and no caregiver forms 
so they are missing data for anything about visit dates and they count as 
having had zero visits.
*/

* --> Visit date (based on caregiver timeend date)
gen visit_date=dcaregiver_timeend_date
format %d visit_date
label var visit_date "Visit date (caregiver form sub date)"


* --> First and last visit dates
egen visit_date_first=min(visit_date), by(id)
format %d visit_date_first
label var visit_date_first "Date of first home visit (1st caregiver form)"
egen visit_date_last=max(visit_date), by(id)
	label var visit_date_last "Date of last home visit (last caregiver form)"
format %d visit_date_last
tab1 visit_date_*st if id_tag==1, m
	// Those without a first or last visit are those who never had a caregiver
	// form submitted.
	

* --> m2m exposure
gen m2m_exp=round((visit_date_last-enrolment_date)/30.5, 0.01)
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
tab m2m_exp_1yrplus if id_tag==1, m

	


*------------------------------------------------------------------------------*
* Number of visits 
/*
This is a count of form submissions in the caregiver form which actually records
services delivered. Those without any caregiver forms are assigned a value of 
0 for visits. 
*/

* --> Total number of visits per client
egen unique_visit_date=tag(id visit_date)
egen numvisits_total=total(unique_visit_date), by(id)
label var numvisits_total "Total visits to client"
	
recode numvisits_total ///
	(5/max=5 "5+"), ///
	gen(numvisits_total_cat)
label var numvisits_total_cat "Total visits to client"
label def visits_1_5_lab 0"0" 1"1" 2"2" 3"3" 4"4" 5"5+"
label val numvisits_total_cat visits_1_5_lab


* --> Number of visits (0-3 months after enrolment)
/*
I copy dates that occur between enrolment up until 3 months post enrolment. 
As above, if the first caregiver form is submitted at the same time as the
reg index form, i.e. at enrolment, then this is counted as the first visit.
*/
gen enrolment_plus3m=enrolment_date+91.5
format %d enrolment_plus3m

gen visit_date_3m=visit_date if visit_date>=enrolment_date & ///
	visit_date<=enrolment_plus3m
format %d visit_date_3m
label var visit_date_3m "Visit date (0-3m with m2m)"

egen unique_date_3m=tag(id visit_date_3m)
egen numvisits_3m=total(unique_date_3m), by(id)
label var numvisits_3m "# visits in first 3 months with m2m"
tab numvisits_3m if id_tag==1

recode numvisits_3m ///
	(5/max=5 "5+"), ///
	gen(numvisits_3m_cat)
label var numvisits_3m_cat "# visits in first 3 months with m2m"
tab numvisits_3m_cat if id_tag==1, m


* --> Number of visits (1st year with m2m)
gen enrolment_plusyr1=enrolment_date+365
gen visit_date_yr1=visit_date if visit_date>=enrolment_date & ///
	visit_date<=enrolment_plusyr1
format %d visit_date_yr1
label var visit_date_yr1 "Visit date in first year with m2m"

egen unique_date_yr1=tag(id visit_date_yr1)
egen numvisits_yr1=total(unique_date_yr1), by(id)
label var numvisits_yr1 "# visits in first year with m2m"
tab numvisits_yr1 if id_tag==1

recode numvisits_yr1 ///
	(5/max=5 "5+"), ///
	gen(numvisits_yr1_cat)
label var numvisits_yr1_cat "# visits in first year with m2m"
tab numvisits_yr1_cat if id_tag==1, m


* --> Number of visits (in 2021)
gen visit_date_2021=visit_date if visit_date>=td(01jan2021) & ///
	visit_date<=td(31dec2021)
format %d visit_date_2021
label var visit_date_2021 "Visit date (2021)"

egen unique_date_2021=tag(id visit_date_2021)
egen numvisits_2021=total(unique_date_2021), by(id)
label var numvisits_2021 "# visits in 2021"
tab numvisits_2021 if id_tag==1

recode numvisits_2021 ///
	(5/max=5 "5+"), ///
	gen(numvisits_2021_cat)
label var numvisits_2021_cat "# visits in 2021"
tab numvisits_2021_cat if id_tag==1, m


/*

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
	
tsset id obs
	

* --> Calculate gap in days between visits
bysort id (obs): generate gap_days=visit_date-L.visit_date
label var gap_days "Gap between visit dates (days)"


* --> Reshape to wide (because that's how the analysis code is written)
keeporder country caseid obs visit_date_last visit_date gap_days ///
	enrolment_date status_enrol keep*
reshape wide visit_date-gap_days, i(caseid) j(obs)
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
gen db="all"
replace db="nonpos" if status_enrol!=1
replace db="pos" if status_enrol==1
save "$temp/index all - gap betw visits - both samples.dta", replace
	// I save separate datasets by status and sample at the bottom.
restore

*/


*------------------------------------------------------------------------------*
* HIV test dates
/*
Annoyingly there are two HIV test variables - HIV test and HCT test. However, 
at least in this dataset, it seems that they're never both filled out in the
same visit, so I am going to slot the HCT date and result into the HIV test
date and result and then I don't have to adjust the code below which had been
written before I realised there was also an HCT variable.
*/

* --> Numeric test date
cap drop hivtest_date
gen hivtest_date=date(dcaregiver_hiv_retest_done_date, "YMD") 
replace hivtest_date=date(dcaregiver_hiv_retest_done_date, "DMY") if ///
	hivtest_date==.
format %d hivtest_date
label var hivtest_date "HIV test date"

cap drop hcttest_date
gen hcttest_date=date(dcaregiver_hct_done_date, "YMD") 
replace hcttest_date=date(dcaregiver_hct_done_date, "DMY") if ///
	hcttest_date==.
format %d hcttest_date
label var hcttest_date "HCT test date"

count if hcttest_date!=. & hivtest_date!=.
	// No form submission has both an HCT and HIV test date filled in
	
replace hivtest_date=hcttest_date if hivtest_date==.


* --> Compare HIV test dates to enrolment date to see when they happened
foreach x in hiv {
	gen `x'test_befenrol=`x'test_date<enrolment_date if `x'test_date!=.
	label var `x'test_befenrol "`x' test date before enrolment date"
}
tab1 *test_befenrol
	// This is in a loop because I initially had both hct and hiv test date 
	// variables here, but realised I can just slot hct into the hivtest 
	// variable. Leaving the loop because it's quicker.
	
	
* --> Result
gen hivtest_result=dcaregiver_hiv_result=="tested_positive" if ///
	dcaregiver_hiv_result!=""
label val hivtest_result status
label var hivtest_result "HIV test result"
gen hcttest_result=dcaregiver_hct_result=="tested_positive" if ///
	dcaregiver_hct_result!=""
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
Last year, for the stat on gap between enrolment and first test, I restricted it
to tests that have a result. I guess I should stick with that? I will do both
and see how different.
*/

* --> First and last test date after enrolment (regardless of result)
/*
egen min1=min(hivtest_date_postenrol), by(caseid)
egen min2=min(hcttest_date_postenrol), by(caseid)
egen hivtest_date_first=rowmin(min1 min2)
label var hivtest_date_first "First HIV test post-enrol (regardless of result)"
egen max1=max(hivtest_date_postenrol), by(caseid)
egen max2=max(hcttest_date_postenrol), by(caseid)
egen hivtest_date_last=rowmax(max1 max2)
label var hivtest_date_last "Last HIV test post-enrol (regardless of result)"
format %d hivtest_date_*
drop min? max?
*/
	// Code if HCT and HIV test dates are populated in the same row. NA in this
	// dataset but leaving the code in in case it's useful later or for another
	// dataset.
	
egen hivtest_date_first_post=min(hivtest_date_postenrol), by(caseid)
label var hivtest_date_first_post ///
	"First HIV test post-enrol (regardless of result)"
egen hivtest_date_last_post=max(hivtest_date_postenrol), by(caseid)
label var hivtest_date_last_post ///
	"Last HIV test post-enrol (regardless of result)"
format %d hivtest_date_*


* --> First and last test date after enrolment with a result
egen hivtest_date_first_post_result=min(hivtest_date_r2), by(caseid)
label var hivtest_date_first_post_result ///
	"First HIV test post-enrol with result"
egen hivtest_date_last_post_result=max(hivtest_date_r2), by(caseid)
label var hivtest_date_last_post_result ///
	"Last HIV test post-enrol with result"
format %d hivtest_date_*


* --> Result of first and last post-enrol HIV test 
*	  This is regardless of result so some of these values will be missing.
cap drop y
gen y=hivtest_result_postenrol if hivtest_date==hivtest_date_first_post
egen hivtest_result_first_post=max(y), by(caseid)	
cap drop y
gen y=hivtest_result_postenrol if hivtest_date==hivtest_date_last_post
egen hivtest_result_last_post=max(y), by(caseid)
label var hivtest_result_first_post "HIV test result from first post-enrol test"
label var hivtest_result_last_post "HIV test result from last post-enrol test"
label val hivtest_result* status
tab hivtest_result_first_post if hivtest_date_first_post!=. & id_tag==1, m
	// 656 of 2509 clients have an HIV test after enrolment but no result.

count if hivtest_result_last==0 & hivtest_result_first==1 & id_tag==1
	// No one goes from positive at first test to negative at last test.
/*
sort id obs
br id obs visit_date enrolment_date hivtest_date hivtest_result ///
	if hivtest_result_last==0 & hivtest_result_first==1
*/

	
* --> Result of first and last post-enrol HIV test that have results
gen hivtest_result_firstx=hivtest_result if ///
	hivtest_date==hivtest_date_first_post_result
egen hivtest_result_first_post_result=max(hivtest_result_firstx), by(caseid)
label var hivtest_result_first_post_result ///
	"HIV test result from first post-enrol test with result"

gen hivtest_result_lastx=hivtest_result if ///
	hivtest_date==hivtest_date_last_post_result
egen hivtest_result_last_post_result=max(hivtest_result_lastx), by(caseid)
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
egen id_test_tag=tag(id hivtest_date_postenrol)
egen total_tests=total(id_test_tag), by(id)
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
/*
Restricted to those who had 12+ months exposure to m2m.
*/

* --> HIV test date if in first year (and post-enrol)
gen hivtest_date_x=hivtest_date_postenrol if ///
	hivtest_date_postenrol<=enrolment_date+365


* --> Count of unique HIV test dates per client
egen id_test_tag=tag(id hivtest_date_x)
egen total_tests_yr1=total(id_test_tag), by(id)
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




*------------------------------------------------------------------------------*
* Number of test dates in 2021
/*
Restricted to those who enrolled before 2021, in line with last year's analysis.
*/

* --> HIV test date if in 2021 (and post-enrol)
gen hivtest_date_x=hivtest_date_postenrol if ///
	hivtest_date_postenrol>=td(01jan2021) & ///
	hivtest_date_postenrol<=td(31dec2021)


* --> Count of unique HIV test dates per client
egen id_test_tag=tag(id hivtest_date_x)
egen total_tests_2021=total(id_test_tag), by(id)
replace total_tests_2021=. if status_enrol==1
replace total_tests_2021=. if enrolment_date>td(31dec2020)
	// Only include those who were with m2m for (potentially) the whole of 2021
	
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
tab total_tests_2021_cat, m


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
	// Missing for those positive at enrolment
	



*------------------------------------------------------------------------------*
* Gap between enrolment and first test date 
/*
In 2019's evaluation, I used the first test date whether or not there was a result. 
In 2020's evaluation, I used the first test date that had a result as it 
	seemed more valid.
In 2020 and 2021's evaluations, I replicate 2018.
*/

gen gap_enrol_test1_days=hivtest_date_first_post_result-enrolment_date
label var gap_enrol_test1_days "Gap between enrol-1st HIV test date (days)"
tab gap_enrol_test1_days if id_tag==1, m

	
	
	
*------------------------------------------------------------------------------*
* Set final status to latest test result
/*
Those with no test results will be missing - matches how we did it in previous
years.
*/

cap drop status_final
gen status_final=1 if status_enrol==1
replace status_final=hivtest_result_last_post_r if status_final==.
replace status_final=2 if status_final==.
label val status_final status
label var status_final ///
	"Final HIV status at end of period (most recent post-enrol test)"
tab status_enrol status_final if id_tag==1, m

tab total_tests if status_final==. & id_tag==1, m 
tab total_tests status_final if id_tag==1, m 

/*
sort id obs
br id enrolment_date obs visit_date ///
	hivtest_date_postenrol hivtest_result_postenrol ///
	hivtest_result_first_post_r hivtest_result_last_post_r total_tests if ///
	status_final==. & total_tests>0 & total_tests<.
*/
	// Those who have 1 or more post-enrol test dates but no final status are
	// those who don't have a test result associated with their test date.

/*
sort id obs
br id enrolment_date obs visit_date status_enrol status_caregiver if ///
	status_final==.
*/
	// Many of these women who are missing a final status have a status in their
	// caregiver form. However, last year we explicitly only considered the
	// test result after enrolment to determine status, so I will apply the 
	// same here.
	
	
	

*------------------------------------------------------------------------------*
* ART initiation

* --> ART start date
foreach x in reg_index_init_date caregiver_init_date {
	cap drop `x'
	gen `x'x=date(d`x', "YMD") 
	replace `x'x=date(d`x', "DMY") if `x'==.
	egen `x'=max(`x'x), by(caseid)
	format %d `x'
}

gen artstart_date=reg_index_init_date
replace artstart_date=caregiver_init_date if artstart_date==.
format %d artstart_date
label var artstart_date "Date of ART initiation"
count if status_final!=1 & artstart_date!=.
	// No one who is non-pos at the end of the period has an ART start date.
	
count if status_final==1 & artstart_date==. & id_tag==1
	
	
* --> Client has started ART	
tab artstart_date
gen artstart=artstart_date!=.
replace artstart=. if status_final==0
label var artstart "Client has started ART"
label val artstart yes_no
tab artstart if status_final==1 & id_tag==1, m
tab country if status_final==1 & id_tag==1
tab country if status_final==1 & artstart!=1 & id_tag==1
	// A lot of positive women, particularly in Zambia, have no ART start date

/*
sort id obs
br id obs artstart_date ///
	dcaregiver_artrefill_done dcaregiver_artrefill_latest ///
	dcaregiver_artrefill_latest_date if status_final==1
*/


* --> ART refill dates
tab1 dcaregiver_artrefill_done dcaregiver_artrefill_latest ///
	dcaregiver_artrefill_latest_date if status_final==1
foreach x in caregiver_artrefill_latest_date {
	cap drop `x'
	gen `x'=date(d`x', "YMD") 
	replace `x'=date(d`x', "DMY") if `x'==.
	format %d `x'
}
egen latest_refill=max(caregiver_artrefill_latest_date), by(caseid)
replace artstart=1 if latest_refill!=. 
	// Replace ART start to yes if there are any ART refill done dates
	
tab artstart if status_final==1 & id_tag==1, m
tab country if status_final==1 & id_tag==1
tab country if status_final==1 & artstart!=1 & id_tag==1
	// Still quite a lot of Zambian women with no evidence of starting ART
	
tab caregiver_artrefill_latest_date
gen caregiver_has_artref=caregiver_artrefill_latest_date!=.
tab country caregiver_has_artref if id_tag==1 & status_final==1
	// 77 clients have one or mor ART refill dates out of 3600

	


*------------------------------------------------------------------------------*
* VL testing
/*
VL testing is tricky in App2 data because the date of the test isn't recorded.
We have the due date, a yes/no for whether it was done and the result. I don't
know if each result is a new result or the previous result being copied in 
again. I am going to go with the same analysis as in PMTCT - count of women
with 1 or more VL tests and were they suppressed at their most recent test.
*/

* --> Make new variables
gen vl_test_done=dcaregiver_vl_test_done=="yes" if dcaregiver_vl_test_done!=""
label var vl_test_done "VL test done"
label val vl_test_done yes_no
ren dcaregiver_vl_result vl_result
label var vl_result "VL result"
ren dcaregiver_vl_result_number vl_result_num
label var vl_result_num "VL result number"
destring vl_result_num, replace
foreach x in vl_test_due_date {
	gen `x'=date(dcaregiver_`x', "YMD") 
	replace `x'=date(dcaregiver_`x', "DMY") if `x'==.
	format %d `x'
}
drop dcaregiver_vl*
/*
sort id obs
br id obs visit_date vl_test_due_date vl_test_done vl_result if status_final==1
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
egen vl_test_ever=max(vl_done), by(id)
label var vl_test_ever "Ever received VL test"
label val vl_test_ever yes_no
tab vl_test_ever if status_final==1 & id_tag==1
	// 67% of those positive by the end of the period have 1 or more
	// VL test results recorded.
	
tab vl_test_ever if status_final!=1 & id_tag==1
/*
br id obs visit_date enrolment_date artstart vl_test_due vl_result* ///
	hivtest_date hivtest_result if status_final!=1 & vl_test_ever==1
*/
	// 11 clients who aren't marked as positive at the end of the period have
	// 1 or more VL test results recorded. If you look at the browse, it seems
	// that some are probably genuine positive cases. None of them seem to
	// have started ART though. They are either missing HIV test (and status)
	// information, or their test date was probably entered incorrectly because
	// they have a negative test date after the positive date. This is tricky
	// to fix because we need to know when they became positive - before or
	// during their time in our care - but I can't be sure when that happened.
	// I am going to leave them as is in terms of status - not positive - and
	// remove them from the VL stats. Either way I am re-jigging the data a 
	// bit but I can't have the samples changing between those identified as
	// positive by the end of the period and those who are in the VL testing
	// stats. This option seems more conservative.

replace vl_test_ever=. if status_final!=1


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
egen visit_date_vltest_max=max(visit_date_vltest), by(id)
gen vl_supp_lastx=vl_supp if visit_date==visit_date_vltest_max
egen vl_supp_last=max(vl_supp_last), by(id)
label var vl_supp_last "Most recent VL test result was suppressed"
label val vl_supp_last yes_no
tab vl_supp_last
/*
sort id obs
br id obs vl_result vl_result_num vl_supp*
*/

tab vl_test_ever if status_final==1 & id_tag==1, m
tab vl_supp_last if vl_test_ever==1 & id_tag==1, m




*------------------------------------------------------------------------------*
* Adherence
/*
App2 adherence questions/variables are quite different to App1. They are:
dcaregiver_adh_remember - difficult to remember to take meds
dcaregiver_adh_stop_better  - stop taking when feel better
dcaregiver_adh_7_forget - forget to take in last week
dcaregiver_adh_7_forget_num - number does forgot in last week
dcaregiver_adh_stop_worse - stop if feel worse
dcaregiver_adh_notadherent - marked by app as not adherent if any of the 
	questions about were answered "yes"

Unlike in App1, I can't run an analysis on 5 point scale, only on whether the
client is adherent or not, and 7 day recall.
*/

* --> Yes/no adherence variables
foreach x in adh_remember adh_stop_better adh_7_forget adh_stop_worse ///
	adh_notadherent {
		cap drop `x'
		gen `x'=(dcaregiver_`x'=="1" | dcaregiver_`x'=="yes") if ///
			dcaregiver_`x'!=""
		replace `x'=. if status_final!=1
}
label var adh_remember "Difficulty remembering to take medication"
label var adh_stop_better "Stop taking medication if feel better"
label var adh_7_forget "Forgot to take 1 or more doses in the last 7 days"
label var adh_stop_worse "Stop taking medication if feel worse"
label var adh_notadherent "Not adherent (yes to 1 or more of adh questions)"


* --> Number of doses forgotten in last 7 days
cap drop adh_7_forget_num
gen adh_7_forget_num=dcaregiver_adh_7_forget_num
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
egen adh_7dayrecall_average=mean(adh_7dayrecall), by(id)
replace adh_7dayrecall_average=round(adh_7dayrecall_average, 0.01)
label var adh_7dayrecall_average "Average 7 day recall over all visits"
cap drop adh_7dayrecall_average_cat
recode adh_7dayrecall_average ///
	(0/0.7999=1 "Avg 7 day recall <80% over all visits") ///
	(0.80/0.9499=2 "Avg 7 day recall 80-95% over all visits") ///
	(0.95/1=3 "Avg 7 day recall >95% over all visits"), ///
	gen(adh_7dayrecall_average_cat)
label var adh_7dayrecall_average_cat "Average 7 day recall over all visits"
tab adh_7dayrecall_average_cat if id_tag==1 & status_final==1, m
drop x


* --> Adherence over time
cap drop adherent
gen adherent=1-adh_notadherent
cap drop adh_average
egen adh_average=mean(adherent), by(id)
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

egen num_adh_measures=sum(has_adh_measure), by(caseid)
label var num_adh_measures "# adherence measures"
count if num_adh_m>numvisits_total
/*
sort country caseid visit_date
br country caseid visit_date num_adh_m numvisits_total if num_adh_m>numvisits_total
*/
	// There are cases of more adh measures than visit dates becuse the count
	// of visits is count of unique dates and many clients have more than 1
	// form submitted on the same day, whereas the num adh measures is simply
	// the number of measures recorded.

egen ever_has_adh_measure=max(has_adh_measure), by(caseid)
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
	// This accounts for cases where the person has a caregiver form sub
	// but the form sub date is missing. In those cases, they will have 0
	// for number of visits, because that is a count of unique visit dates,
	// but a positive number of adherence measurements. I assume they were
	// measured at 100% of their visits.
	
label var perc_visits_adh_measure "% visits at which adh measure was taken"

gen adh_all_visits=perc_visits_adh_measure==1
label var adh_all_visits "Adherence measure taken at all visits"

tab perc_visits_adh_measure if id_tag==1 & status_final==1, m
tab ever_has_adh_measure if perc_visits_adh_measure==0
tab perc_visits_adh_measure if id_tag==1 & status_final==1 & numvisits_total>=2, m
tab perc_visits_adh_measure if adh_average_cat==.
tab perc_visits_adh_measure if ever_has_adh_measure!=1


* --> % visits at which client was assessed for adherence in categories
cap drop perc_visits_adh_cat
recode perc_visits_adh_measure ///
	(0/0=0 "Never measured for adherence") ///
	(0.001/0.25=1 "Measured at 0-25% of visits") ///
	(0.2501/0.50=2 "Measured at 25-50% of visits") ///
	(0.5001/0.75=3 "Measured at 50-75% of visits") ///
	(0.7501/0.9999=4 "Measured at 75-99% of visits") ///
	(1/1=5 "Measured at 100% of visits"), ///
	gen(perc_visits_adh_cat)
label var perc_visits_adh_cat "% visits at which adherence was measured"
tab perc_visits_adh_cat if id_tag==1 & status_final==1, m



*------------------------------------------------------------------------------*
* Save final datasets

* --> Keep and label variables
label var country "Country"
label var facility "Facility"
label var caseid "Original client ID"
label var id "New usable client ID"
label var obs "Observation # in dataset"
label var keep_3 "Facilities to include in 3 year analysis"
label var keep_2 "Facilities to include in 2 year analysis"
label var keep_1 "Facilities to include in 1 year analysis"

keeporder country facility caseid obs visit_date* numvisits* ///
	enrolment_date enrolment_y m2m_exp* ///
	dob age_enrol status_enrol status_final ///
	hivtest_date hivtest_date_postenrol hivtest_date_r* ///
	hivtest_*_first_post* hivtest_*_last_post* ///
	total_tests* atleast1_test* gap_enrol_test1_days artstart* ///
	vl_test_ever vl_result vl_result_num vl_supp vl_supp_last keep* ///
	*adh*
drop visit_date_vltest visit_date_vltest_max
gen sex=0

cap drop *tag
egen id_tag=tag(caseid)
egen fac_tag=tag(facility)
tab1 *tag

*ren keep_2021 keep_1y
*ren keep_2020_2021 keep_2y


* --> Save 
tab country if id_tag==1, m
	// Kenya: 599
	// Malawi: 6766
	// Zambia: 1750
	
drop *tag
save "$temp/index all - full dataset - both samples.dta", replace
	
gen db="nonpos" if status_enrol!=1
replace db="pos" if status_enrol==1
forvalues i=1/2 {
	foreach db in nonpos pos {
		preserve
		keep if db=="`db'" 
		keep if keep_`i'y==1
		replace db="index_`db'"
		save "$temp/index `db' - full dataset - `i'yr sample.dta", replace
		restore
	}
}


/* --> Save separate 'gap betw visits' datasets by status and sample
forvalues i=1/3 {
	foreach db in nonpos pos {
		use "$temp/index all - gap betw visits - both samples.dta", clear
		*ren keep_2021 keep_1y
		*ren keep_2020_2021 keep_2y
		keep if db=="`db'" 
		keep if keep_`i'y==1
		replace db="index_`db'"
		save "$temp/index `db' - gap betw visits - `i'yr sample.dta", replace
	}
}
*/


*------------------------------------------------------------------------------*
* See if I can match Zambian women in this sample to App1 to get evidence
* of their ART start
/*
Many Zambian women had no evidence of starting ART in app2 dta because they
were registered in app1 and claimed on app2. I therefore bring in app1 data
to fill in the gaps. The only time so far that bringing in app1 data has
gotten me anywhere.
*/

use "$temp/index all - full dataset - both samples.dta", clear
duplicates drop caseid, force
keeporder country facility caseid status_enrol status_final artstart
save "$temp/index all - full dataset - both samples - to match with app1.dta", replace

use "$temp_appdata/Clare & new version/App1/new_an_pn.dta", clear
drop if caseid==""
egen art_init_date1=rowmax(mom_art_init_done_an mom_art_init_done_pn)
egen art_init_date=max(art_init_date1), by(caseid)

egen art_ref_latestx=rowmax(mom_art_ref_done_pn mom_art_ref_done_an)
egen art_ref_latest=max(art_ref_latestx), by(caseid)

gen art_start=art_ref_latest!=. | art_init_date!=.

keeporder country facility caseid art_start
duplicates drop caseid, force

merge 1:1 caseid using ///
	"$temp/index all - full dataset - both samples - to match with app1.dta"
drop if _merge==1
drop if country==""
drop _merge
replace artstart=1 if art_start==1
ren artstart artstart_index
sort country facility
tab country artstart if status_final==1, m row

keep country facility caseid artstart
save "$temp/index all - full dataset - both samples - to bring in for ART stats.dta", replace
