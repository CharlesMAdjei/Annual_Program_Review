*** APR 2020 - Primary prevention
*** Analysis - Condom usage
* 9 July 2021



*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Create dataset for analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		



use "$temp/an_pn_cleaned.dta", replace
egen country2=group(country)


* --> Restrict dataset to PN-any clients and PN form submissions
drop dataset_max
egen dataset_max=max(dataset), by(id)

tab id_tag
	// 119373 (full dataset)
	
keep if sample==1
tab id_tag
	// 68301 (clients negative at enrolment)
	
drop if client_type==1
tab id_tag
	// 37852 (PN-any clients negative at enrolment)
	
keep if dataset==2
drop id_tag
egen id_tag=tag(id)
tab id_tag
	// This keeps only the PN form submissions (dataset=2 is for the PN dataset).
	// An additional 332 clients were dropped because they had been coded as PN
	// any but didn't have any PN form submissions. Not sure why, it's probably
	// a small misstep in the cleaning in do file 3.


* --> Recreate visit number now that AN forms have been dropped
cap drop visit_num
sort id visit_date
quietly bys id: gen visit_num=cond(_N==1,1,_n)
egen num_visits=max(visit_num), by(id)
label var num_visits "# PN contacts with m2m"


* --> Identify condom usage at each visit
gen visit_condom=fp_condom=="yes"
egen num_visits_condom=sum(visit_condom), by(id)
label var num_visits_condom "Number of PN visits at which condom recorded"


* --> Consistency of condom usage
gen no_condom=num_visits_condom==0
label var no_condom "No condom usage"
gen consistent_condom=num_visits==num_visits_condom
label var consistent_condom "Consistent condom usage"
gen inconsistent_condom=no_condom!=1 & consistent_condom!=1
label var inconsistent_condom "Inconsistent condom usage"
assert no_condom+consistent_condom+inconsistent_condom==1
tab consistent_condom if id_tag==1

gen condom_usage=1 if consistent_condom==1
replace condom_usage=2 if inconsistent_condom==1
replace condom_usage=3 if no_condom==1
label def condom_usage 1"Consistent use" 2"Inconsistent use" 3"No use"
label val condom_usage condom_usage
tab condom_usage if id_tag==1, m


* --> Check partner status variable
tab partner_status_enrol, m
replace partner_status_enrol=3 if partner_status_enrol==.
label def partner_status_enrol 0"Neg" 1"Pos" 2"Unknown" 3"Client is single"
label val partner_status_enrol partner_status_enrol
tab partner_status_enrol, m


* --> Reduce dataset and save
keeporder country* facility id enrol_date num_visits* ///
	tot_duration partner_status_enrol serocon* ///
	no_condom consistent_condom inconsistent_condom condom_usage
gen enrol_year=year(enrol_date)
duplicates drop
numlabel, add
isid id
save "$data/condom_analysis.dta", replace





*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

use "$data/condom_analysis.dta", clear
count
	// 37520 PN-any clients who were HIV-negative at enrolment 
	

* --> Consistency of condom use among clients who used a condom >1 times
tabout condom_usage if no_condom==0 ///
	using "$output/Condom usage/Consistency of usage among those who ever used ($S_DATE).xls", ///
	cells(freq row) replace

	
* --> Consistency of use among clients who seroconverted
tabout condom_usage if serocon==1 ///
	using "$output/Condom usage/Consistency of usage among seroconverted ($S_DATE).xls", ///
	cells(freq row) replace


* --> Consistency of use among clients who seroconverted by status of partner
tabout partner_status_enrol condom_usage if serocon==1 ///
	using "$output/Condom usage/Consistency of usage among seroconverted by partner status ($S_DATE).xls", ///
	cells(freq) replace


* --> Consistency of use among all clients by status of partner
tabout partner_status_enrol condom_usage ///
	using "$output/Condom usage/Consistency of usage among all clients by partner status ($S_DATE).xls", ///
	cells(freq) replace



