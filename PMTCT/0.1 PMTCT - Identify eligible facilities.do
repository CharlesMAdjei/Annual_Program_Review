*** APR 2020 - PMTCT cascade
*** Identify sample
* 12 Feb 2021



*------------------------------------------------------------------------------*
* Create multi-country dataset

use "$data_appdata/Clare & new version/App1/app1 final.dta", clear
drop if completed2<td(01sept2021)
*do "$do_appdata/Generic/0. Undo renaming to UID.do"
*do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
drop if country=="" | facility==""
drop if strpos(facility, "UAT")
	// UAT = user acceptability training
	
cap drop site_tag 
egen site_tag=tag(facility)
	


	
*------------------------------------------------------------------------------*
* Identify earliest and latest form submission date by facility
	
* --> Identify month of each new/AN/PN form completion date
gen completed2_m=mofd(completed2) if form_type=="an" | form_type=="pn" | ///
	form_type=="new"
format %tm completed2_m
label var completed2_m "Month of AN/PN/new client form completion date"
replace completed2_m=. if completed2_m<tm(2019m1)
	// Only want to count forms submitted after 1 Jan 2019.
	

* --> Earliest and latest completed date for each site
cap drop completed2_m_m*
egen completed2_m_min=min(completed2_m), by(facility)
egen completed2_m_max=max(completed2_m), by(facility)
format %tm completed2_m_m??
label var completed2_m_min "Earliest form sub. month"
label var completed2_m_max "Latest form sub. month"


* --> Eligible for 3 year cohort in terms of span of form submission dates 
/*
First form sub. in <=Jan 2019, final form sub. in >=Dec 2021.
*/
cap drop eligible_dates_3yr
gen eligible_dates_3yr=completed2_m_min<=mofd($beg_period) & ///
	completed2_m_max>=mofd($end_period)
label var eligible_dates_3yr ///
	"Eligible for 3 year cohort based on earliest and latest form sub dates"
tab eligible_dates_3yr if site_tag==1
tab country if eligible_dates_3yr==1 & site_tag==1
/*
sort eligible country facility
br country facility eligible completed2_m_min completed2_m_max if ///
	site_tag==1
*/


* --> Eligible for 2 year cohort in terms of span of form submission dates
cap drop eligible_dates_2yr
gen eligible_dates_2yr=completed2_m_min<=mofd($beg_period_2yr) & ///
	completed2_m_max>=mofd($end_period)
label var eligible_dates_2yr ///
	"Eligible for 2 year cohort based on earliest and latest form sub dates"
tab eligible_dates_2yr if site_tag==1
tab country if eligible_dates_2yr==1 & site_tag==1


* --> Eligible for 1 year cohort in terms of span of form submission dates
cap drop eligible_dates_1yr
gen eligible_dates_1yr=completed2_m_min<=mofd($beg_period3) & ///
	completed2_m_max>=mofd($end_period)
label var eligible_dates_1yr ///
	"Eligible for 1 year cohort based on earliest and latest form sub dates"
tab eligible_dates_1yr if site_tag==1
tab country if eligible_dates_1yr==1 & site_tag==1


* --> Tag each site, and each unique site-form month date
cap drop site_m
egen site_m_3yr=tag(facility completed2_m) if ///
	completed2_m>tm(2018m12) & ///
	completed2_m<tm(2022m1)
egen site_m_2yr=tag(facility completed2_m) if ///
	completed2_m>tm(2019m12) & ///
	completed2_m<tm(2022m1)
egen site_m_1yr=tag(facility completed2_m) if ///
	completed2_m>tm(2020m12) & ///
	completed2_m<tm(2022m1)
/*
sort facility completed2_m
br facility completed2_m if site_m_3yr==1
br facility completed2_m site_m_3yr if ///
	completed2_m>tm(2017m12) |
	completed2_m<tm(2021m1)
*/
	

* --> Number of months that have at least 1 form submission between 2019-2021
*	  and 2020-2021
egen num_months_3yr=sum(site_m_3yr), by(facility)
tab num_months_3yr if country=="Lesotho" & site_tag==1

egen num_months_2yr=sum(site_m_2yr), by(facility)

egen num_months_1yr=sum(site_m_1yr), by(facility)

/*
sort country facility completed2_m
br country facility num_months* completed2_m_min completed2_m_max  ///
	if eligible==1 & site_tag==1
br country facility num_months* completed2_m ///
	if site_m==1 & eligible==1 & country=="Lesotho" 
br completed2_m if site_m==1 & facility=="St Rose HC"
br completed2_m if site_m==1 & facility=="Berea Hospital"
*/


* --> Create new variable to count new/AN/PN form submissions per facility per  
*	  site each month (takes a while).
forvalues i=1/12 {
	forvalues y=2019/2021 {
		gen m_`y'm`i'_x=1 if completed2_m==tm(`y'm`i')
		egen m_`y'm`i'=total(m_`y'm`i'_x), by(facility)
		replace m_`y'm`i'=. if m_`y'm`i'==0
		drop m_`y'm`i'_x
		label var  m_`y'm`i' "`y' m`i'"
	}
}
	// This creates a variable for each month that is equal to the count of
	// new, AN and PN forms submitted per site. For sites that had 0 forms
	// submitted, the value is missing.


* --> Facilities in 3 year cohort
/*
This is a dataset of facility names for sites that have continuous app usage 
for the period Jan 2019 - Dec 2021. Use this to merge with app data to restrict 
it to relevant facilities. 
*/

/*
br facility completed2_m_min completed2_m_max num_m m_2019* m_2020* m_2021* ///
	if site_tag==1 & eligible_dates_3yr==1 & num_months_3yr<36
*/

cap drop pmtct_sample_3yr
gen pmtct_sample_3yr=eligible_dates_3yr==1 & num_months_3yr>=35
tab pmtct_sample_3yr
tab country if pmtct_sample_3yr==1
tab facility if pmtct_sample_3yr==1

preserve 
keep if pmtct_sample_3yr==1
keeporder country facility
sort country facility
duplicates drop
save "$temp/pmtct sample facilities - 3 year cohort.dta", replace
export excel using "$output/Checks/Facilities in PMTCT sample - 3 year cohort ($S_DATE).xlsx", ///
	firstrow(variables) replace
restore


* --> Facilities in 2 year cohort
/*
This is a dataset of facility names for sites that have continuous app usage 
for the period Jan 2020 - Dec 2021.
*/

/*
br facility completed2_m_min completed2_m_max m_2020* m_2021* ///
	if site_tag==1 & eligible_dates_2yr==1 & num_months_2yr<24
*/

cap drop pmtct_sample_2yr
gen pmtct_sample_2yr=eligible_dates_2yr==1 & num_months_2yr>=23
tab pmtct_sample_2yr
tab country if pmtct_sample_2yr==1 & site_tag==1
tab facility if pmtct_sample_2yr==1 & site_tag==1
sort pmtct_sample_2yr facility
list facility num_months_2yr pmtct_sample_2yr if country=="Malawi" & site_tag==1

preserve 
keep if pmtct_sample_2yr==1
keeporder country facility
sort country facility
duplicates drop
save "$temp/pmtct sample facilities - 2 year cohort.dta", replace
export excel using "$output/Checks/Facilities in PMTCT sample - 2 year cohort ($S_DATE).xlsx", ///
	firstrow(variables) replace
restore
	


* --> Facilities in 2 year cohort
/*
This is a dataset of facility names for sites that have continuous app usage 
for the period Jan 2020 - Dec 2021.
*/

/*
br facility completed2_m_min completed2_m_max m_2020* m_2021* ///
	if site_tag==1 & eligible_dates_2yr==1 & num_months_2yr<24
*/

cap drop pmtct_sample_1yr
gen pmtct_sample_1yr=eligible_dates_1yr==1 & num_months_1yr>=9
tab pmtct_sample_1yr
tab country if pmtct_sample_1yr==1 & site_tag==1
tab facility if pmtct_sample_1yr==1 & site_tag==1
sort pmtct_sample_1yr facility
list facility num_months_1yr pmtct_sample_1yr if country=="Malawi" & site_tag==1

preserve 
keep if pmtct_sample_1yr==1
keeporder country facility
sort country facility
duplicates drop
save "$temp/pmtct sample facilities - 1 year cohort.dta", replace
export excel using "$output/Checks/Facilities in PMTCT sample - 1 year cohort ($S_DATE).xlsx", ///
	firstrow(variables) replace
restore
	
*------------------------------------------------------------------------------*
* Exports to check site eligibility for PMTCT 3 year cohort

/*
sort country facility
br country facility completed2_m_m?? m_2019* m_2020* m_2021* if site_tag==1
*/

label var country "Country"
label var facility "Facility"
tostring eligible_dates_3yr, replace
replace eligible_dates_3yr="Yes" if eligible_dates_3yr=="1"
replace eligible_dates_3yr="No" if eligible_dates_3yr=="0"
replace country="SA" if country=="South Africa"
drop if completed2_m_min==.
	// Some sites appear in the data but were closed before the period so I
	// remove them here.
	

foreach x in Ghana {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_3yr ///
		completed2_m_min completed2_m_max ///
		m_2019* m_2020* m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 3 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") replace
	restore
}
	// Got to do the first country by itself so I can use the replace in the
	// export command, and then sheetmodify for the remaining countries.
	
foreach x in Kenya Lesotho Malawi SA Uganda Zambia {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_3yr ///
	completed2_m_min completed2_m_max ///
		m_2019* m_2020* m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 3 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") sheetmodify
	restore
}




*------------------------------------------------------------------------------*
* Exports to check site eligibility for PMTCT 2 year cohort

label var country "Country"
label var facility "Facility"
tostring eligible_dates_2yr, replace
replace eligible_dates_2yr="Yes" if eligible_dates_2yr=="1"
replace eligible_dates_2yr="No" if eligible_dates_2yr=="0"
replace country="SA" if country=="South Africa"
drop if completed2_m_min==.
	// Some sites appear in the data but were closed before the period so I
	// remove them here.
	

foreach x in Ghana {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_2yr ///
		completed2_m_min completed2_m_max ///
		m_2020* m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 2 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") replace
	restore
}
foreach x in Kenya Lesotho Malawi SA Uganda Zambia {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_2yr ///
		completed2_m_min completed2_m_max ///
		m_2020* m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 2 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") sheetmodify
	restore
}



*------------------------------------------------------------------------------*
* Exports to check site eligibility for PMTCT 1 year cohort

label var country "Country"
label var facility "Facility"
tostring eligible_dates_1yr, replace
replace eligible_dates_1yr="Yes" if eligible_dates_1yr=="1"
replace eligible_dates_1yr="No" if eligible_dates_1yr=="0"
replace country="SA" if country=="South Africa"
drop if completed2_m_min==.
	// Some sites appear in the data but were closed before the period so I
	// remove them here.
	

foreach x in Ghana {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_1yr ///
		completed2_m_min completed2_m_max ///
		m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 2 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") replace
	restore
}
foreach x in Kenya Lesotho Malawi SA Uganda Zambia {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder country facility eligible_dates_2yr ///
		completed2_m_min completed2_m_max ///
	    m_2021*
	sort facility
	export excel using ///
		"$output/Checks/APR 2021 - PMTCT - Eligible sites 1 year cohort ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") sheetmodify
	restore
}



*Old code from 2019
/*

*------------------------------------------------------------------------------*
* Final eligibility for PMTCT & original RIC analysis

preserve

cap drop keep
gen keep=.

* --> Lesotho
replace keep=1 if country=="Lesotho" & eligible==1
replace keep=. if inlist(facility, "Berea Hospital", "Little Flower HC", ///
	"Tsepo HC", "St Rose HC")
	// I remove those sites that are missing some months during the enrolment
	// period 1 Jan-30 Jun 2017. A few others are missing a single month later
	// on but they remain in.
	// 32 in total.
	
	
* --> SA
replace keep=1 if inlist(facility, "Dark City Clinic", ///
	"Khayelitsha Site B MOU", "Letlhabile Clinic", ///
	"Michael Mapongwana Clinic", "Soshanguve MOU", "Town 2 Clinic")
	// I list these countries manually instead of using the method above with
	// Lesotho because the eligible variable identified quite a few site that
	// clearly aren't to be included. This was easier.
	// 6 in total.
	
	
* --> Uganda
replace keep=1 if country=="Uganda" & eligible==1
replace keep=. if inlist(facility, "Busesa Health Center IV")
	// Busesa is missing 7 months of data. All others have data for every month.
	// Sarah emailed with reasons so I can refer to those, but either way,
	// doesn't matter because that is too much data to be missing.
	
keep if keep==1
drop eligible
egen fac_tag=tag(facility)
keep if fac_tag==1
sort country facility
keep country facility
save "$pmtct/Input/pmtct_sample.dta", replace

restore




*------------------------------------------------------------------------------*
* Exports to check eligibility for early RIC analysis
/*
I produce a different version of exports to identify the sample for the early
RIC analysis.
*/

* --> Count of months in each year with more than 10 form submissions
/*
A few sites have just a few forms submitted during the month. Given that I
am counting all new/A/PN form submissions, there really should be more than 10
to take the site's data seriously. Ikhwezi is a good exampe of a site that 
should be excluded because it burnt down but you still see one form submission
in some months.
*/
forvalues y=2017/2019 {
	forvalues i=1/12 {
		cap drop m_`y'm`i'x
		gen m_`y'm`i'x=m_`y'm`i'
		replace m_`y'm`i'x=. if m_`y'm`i'<10
	}
	cap drop months_`y'
	egen months_`y'=rownonmiss(m_`y'm?x m_`y'm??x)
}
/*
sort country facility
br country facility months_2019 months_2018 months_2017 if site_tag==1
*/


* --> Kenya
preserve
keep if site_tag==1
keep if facility=="Mathare Health Centre"
keep if months_2019>=11 & months_2019<=12
	// Not interested in any sites without data in 2019.
	
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
keeporder country facility months*
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Kenya) replace
restore

* --> Lesotho
preserve
keep if site_tag==1
keep if country=="Lesotho"
keep if months_2019>=11 & months_2019<=12
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
keeporder country facility months*
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Lesotho) sheetmodify
restore

* --> Malawi
preserve
keep if site_tag==1
keep if country=="Malawi"
keep if months_2019>=11 & months_2019<=12
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
keeporder country facility months*
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Malawi) sheetmodify
restore

* --> SA
preserve
keep if site_tag==1
keep if country=="South Africa"
keep if months_2019>=11 & months_2019<=12
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(SA) sheetmodify
restore

* --> Uganda
preserve
keep if site_tag==1
keep if country=="Uganda"
keep if months_2019>=11 & months_2019<=12
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Uganda) sheetmodify
restore

* --> Zambia
preserve
keep if site_tag==1
keep if country=="Zambia"
keep if months_2019>=11 & months_2019<=12
gsort -months_2019 -months_2018
keeporder country facility months_2019 months_2018 months_2017
sort facility
export excel using ///
	"$pmtct/Output/Checks/Early RIC eligible sites ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Zambia) sheetmodify
restore




*------------------------------------------------------------------------------*
* Final eligibility for early RIC analysis

preserve
keep if months_2019==11 | months_2019==12
egen fac_tag=tag(facility)
keep if fac_tag==1
sort country facility 
keep country facility months_2019 months_2018
save "$pmtct/Input/earlyric_sample.dta", replace
restore
