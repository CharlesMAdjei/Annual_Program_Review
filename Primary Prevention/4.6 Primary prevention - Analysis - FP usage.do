*** APR 2020 - Primary prevention
*** Analysis - FP education and usage
* 15 July 2021



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


* --> Check partner status variable
tab partner_status_enrol, m
replace partner_status_enrol=3 if partner_status_enrol==.
label def partner_status_enrol 0"Neg" 1"Pos" 2"Unknown" 3"Client is single"
label val partner_status_enrol partner_status_enrol
tab partner_status_enrol, m


* --> FP education
gen visit_fp_educ=fp_educ=="yes"
egen num_visits_fp_educ=sum(visit_fp_educ), by(id)
label var num_visits_fp_educ "Number of PN visits at which FP educ recorded"
gen fp_educ_ever=num_visits_fp_educ>0 & num_visits_fp_educ<.
label var fp_educ_ever "Ever received FP education"
tab fp_educ_ever if id_tag==1


* --> FP method
tab fp_method
gen fp_long=fp_method=="injection" | fp_method=="implant" | ///
	fp_method=="iud" | fp_method=="sterilization" | ///
	fp_method=="oral_contraceptives"
label var fp_long "Long-acting and permanent methods"
gen fp_long_string="Long-acting/permanent" if fp_long==1
	// It isn't clear whether Jude included the pill in his long-acting/
	// permanent definition. His wording suggests not but then in one of the
	// tables, it doesn't make sense for it to have been excluded. Plus the
	// pill is included as a long acting method in the PMTCT analysis so I have
	// included it here.
	
gen fp_pill=fp_method=="oral_contraceptives"
label var fp_pill "Oral contraceptives"
gen fp_pill_string="Pill" if fp_pill==1
	// Created this just because.
	
gen fp_condomx=fp_condom=="yes"
drop fp_condom
ren fp_condomx fp_condom
gen fp_condom_string="Condom" if fp_condom==1


* --> Dual FP (condom + one other method)
egen fp_sum=rowtotal(fp_condom fp_long)
gen fp_dual=fp_sum==2
label var fp_dual "Dual FP"
/*
sort id visit_date
br id visit_date fp_method fp_condom* fp_long* fp_pill* fp_sum fp_dual
*/


* --> Method ever used
foreach x in condom pill dual long {
	egen fp_`x'_ever=max(fp_`x'), by(id)
	label var fp_`x'_ever "Ever used `x'"
	tab fp_`x'_ever if id_tag==1, m
}
egen fp_ever=rowmax(fp_condom_ever fp_dual_ever fp_long_ever)
label var fp_ever "Ever used any form of FP"
tab fp_ever if id_tag==1, m


* --> First FP method
gen visit_date_fp=visit_date if fp_sum>0
format %d visit_date_fp
	// Visit date if an FP method and/or condom is entered at that visit
	
egen visit_date_fp_min=min(visit_date_fp), by(id)
format %d visit_date_fp_min
	// First visit date at which either condom or FP was reported

cap drop fp_method_first
gen fp_method_firstx=fp_method if visit_date_fp_min==visit_date_fp
	// First FP method recorded
	
replace fp_method_firstx="Condoms only" if ///
	fp_method_firstx=="" & fp_condom_string!="" & ///
	visit_date_fp_min==visit_date_fp
	// Replace first method with condom if it is blank and condom was marked at
	// that first visit
	
egen fp_method_first=mode(fp_method_firstx), by(id)	
drop fp_method_firstx
tab fp_method_first if id_tag==1, m


* --> First method after delivery - dual or single
gen fp_method_firstx=fp_method if visit_date_fp_min==visit_date_fp
	// Modern FP method recorded at first visit at which either modern FP
	// or condom was recorded
	
gen fp_condom_first=1 if fp_condom==1 & visit_date_fp_min==visit_date_fp
	// Condom recorded at first visit where FP was recorded

gen fp_method_first_dualx=.
replace fp_method_first_dualx=0 if fp_method_firstx!="" & ///
	fp_condom_first!=1
replace fp_method_first_dualx=0 if fp_method_firstx=="" & ///
	fp_condom_first==1
replace fp_method_first_dualx=1 if fp_method_firstx!="" & ///
	fp_condom_first==1
	
egen fp_method_first_dual=max(fp_method_first_dualx), by(id)
drop fp_method_first_dualx

label def dual 0"Single FP method" 1"Dual method"
label val fp_method_first_dual dual
label var fp_method_first_dual "Single or dual FP offered at first visit"
tab fp_method_first_dual if id_tag==1
/*
sort id visit_date
br id visit_date fp_method visit_date_fp visit_date_fp_min ///
	fp_condom fp_long fp_pill ///
	fp_method_first fp_method_firstx fp_condom_first fp_method_first_dual
*/


* --> Consistency of single/dual usage
gen fp_single=fp_sum==1
label var fp_single "Single FP method recorded at this visit"

gen fp_none=fp_sum==0
label var fp_none "No FP method or condom recorded at this visit"

gen fp_any=fp_sum!=0
label var fp_any "FP method and/or condom recorded at this visit"

foreach x in none single dual any {
	cap drop num_visits_`x'
	egen num_visits_`x'=sum(fp_`x'), by(id)
	label var num_visits_`x' ///
		"Number of visits at which `x' FP method/condom recorded"
		
	gen consistent_`x'=num_visits==num_visits_`x'
	label var consistent_`x' "Consistently used `x' FP method"
}

gen consistency=1 if consistent_dual==1
replace consistency=2 if num_visits_dual>0 & num_visits_dual<num_visits
	// Dual at one or more visits but not all visits
	
replace consistency=3 if num_visits_single==num_visits
	// Single at all visits
	
replace consistency=4 if num_visits_single>0 & num_visits_single<num_visits & ///
	consistency!=2
	// Single at one or more visits but not all visits and never used dual

label def consistency 1"Consistently on dual" 2"Inconsistently on dual" ///
	3"Consistently on single" 4"Inconsistently on single"
label val consistency consistency
label var consistency "Consistency of single and dual FP usage"
tab consistency if id_tag==1, m
tab consistent_any if consistency==. & id_tag==1
tab fp_method fp_condom if consistency==. & id_tag==1
	// No results in the last table indicates this is correct - those who are
	// missing on the consistency variable are people who we have no record
	// of ever using FP/condoms.
	
/*
sort id visit_date
br id visit_num num_visits fp_method fp_condom_string fp_none fp_single fp_dual ///
	num_visits_none num_visits_single num_visits_dual consistent* consistency

br id visit_num num_visits fp_method fp_condom_string fp_none fp_single fp_dual ///
	num_visits_none num_visits_single num_visits_dual consistent* consistency if ///
	consistency==. 
*/

	
* --> Summary of methods ever used in one variable
gen fp_method_summary=1 if fp_dual_ever==1
replace fp_method_summary=2 if ///
	fp_method_summary==. & fp_dual_ever==0 & fp_long_ever==1 
replace fp_method_summary=3 if ///
	fp_method_summary==. & fp_dual_ever==0 & fp_long_ever==0 & ///
	fp_condom_ever==1
replace fp_method_summary=4 if fp_method_summary==.
label def fp_label 1"Dual" 2"Long-acting/permanent" 3"Condoms only" ///
	4"No method recorded"
label val fp_method_summary fp_label
tab fp_method_summary if id_tag==1, m
assert fp_method_summary==4 if fp_dual_ever==0 & fp_condom_ever==0 & ///
	fp_long_ever==0

	
* --> Timing of first FP method after delivery
count if infant_dob_clean==. & id_tag==1
	// 1535 clients don't have an infant DOB so they will be omitted from this
	// analysis.
	
gen fp_method_first_days=visit_date_fp_min-infant_dob_clean
tab fp_method_first_days
tab country if fp_method_first_days>365*2 & fp_method_first_days<. 
	// These are clients who have a gap of more than 2 years between giving
	// birth and the first visit at which they're offered FP. Really seems a bit
	// odd...

replace fp_method_first_days=0 if fp_method_first_days<0
	// Of course we find some people having a PN visit date before the baby
	// was born...oy vey.

recode fp_method_first_days ///
	(0/41=1 "<6 weeks") ///
	(42/56=2 "6-8 weeks") ///
	(57/120=3 "2-4 months") ///
	(121/180=4 "4-6 months") ///
	(181/max=5 ">6 months"), ///
	gen(fp_method_first_days_cat)
label var fp_method_first_days_cat "Time between delivery and first FP method"
tab fp_method_first_days_cat if id_tag==1, m


* --> Checking the calculation of time to first FP method because there seem to
*	  be quite a lot of clients in the 2016 enrolment year who had a very long 
*	  gap between enrolment and first FP method.
gen enrol_year=year(enrol_date)
count if fp_method_first_days>365 & fp_method_first_days<. & id_tag==1
	// 2012 clients have more than a year between delivery and first FP method
	// recorded.

count if fp_method_first_days>365 & fp_method_first_days<. & id_tag==1 & ///
	enrol_year==2016
	// 684 of those clients were enrolled in 2016

tab country if fp_method_first_days>365 & fp_method_first_days<. & id_tag==1 & ///
	enrol_year==2016
tab country if enrol_year==2016
	// Problem in all 3 countries in this enrolment year cohort

gen enrol_infant_dob_days=infant_dob_clean-enrol_date
gen infant_born_befm2m=infant_dob_clean<enrol_date if infant_dob_clean!=.
label var infant_born_befm2m "Infant born before enrolling with m2m"
tab infant_born_befm2m if fp_method_first_days>365 & fp_method_first_days<. & ///
	id_tag==1 & enrol_year==2016
	// Just under half of those with a really big gap between infant DOB and 
	// first FP method had their baby before they enrolled with m2m.

sum enrol_infant_dob_days if infant_born_befm2m==1 & ///
	fp_method_first_days>365 & fp_method_first_days<. & ///
	id_tag==1 & enrol_year==2016, d
	// Of those who have a big gap between dob and first FP method and whose
	// baby was born before enrolling with m2m, the median time between dob
	// and enrolment is about 5 months. Not sure what exactly this is telling
	// us...so even for those who enrolled after their baby was born, half
	// of them had given birth less than 6 months before enrolling.
	// Should this stat not be measuring the time either between infant DOB and
	// first FP method if they enrolled before giving birth, or time between
	// enrolment and first FP method if they enrolled after giving birth?
	
/*
sort country id visit_date
br country id_s infant_dob_clean visit_date_fp_min if ///
	fp_method_first_days>365 & fp_method_first_days<. & id_tag==1
br country id_s infant_dob_clean visit_date_fp_min if ///
	fp_method_first_days>365 & fp_method_first_days<. & id_tag==1 & ///
	enrol_year==2016	
br country id_s infant_dob_clean visit_date_fp_min if ///
	fp_method_first_days>365 & fp_method_first_days<. & id_tag==1 & ///
	enrol_year==2016	
br country id_s enrol_date infant_dob_clean enrol_infant_dob_days if ///
	fp_method_first_days>365 & fp_method_first_days<. & id_tag==1 & ///
	enrol_year==2016	
*/


* --> Alternative calculation of timing of first FP method after delivery
/*
This is my alternative suggestion for how to calculate this. It is the time
between dob and first FP method if the client enrolled with m2m before giving
birth, or the time between delivery and first FP method if they enrolled after
giving birth.
*/
cap drop fp_method_first_days_v2
gen fp_method_first_days_v2=visit_date_fp_min-infant_dob_clean if ///
	infant_dob_clean>=enrol_date & infant_dob_clean<.
	// Number of days between infant DOB and first FP method for clients who
	// gave birth after enrolling with m2m
	
replace fp_method_first_days_v2=visit_date_fp_min-enrol_date if ///
	infant_dob_clean<enrol_date
	// Number of days between enrolment and first FP method for clients who
	// gave birth before enrolling with m2m
	
replace fp_method_first_days_v2=visit_date_fp_min-enrol_date if ///
	infant_dob_clean==. & client_type==2
	// Number of days between enrolment and first FP method for clients
	// who don't have an infant DOB and enrolled after giving birth (PN-only)

/*
br id enrol_date infant_dob_clean visit_date_fp_min ///
	fp_method_first_days fp_method_first_days_v2 if ///
	fp_method_first_days!=fp_method_first_days_v2 & id_tag==1
br id enrol_date infant_dob_clean visit_date_fp_min ///
	fp_method_first_days fp_method_first_days_v2 if ///
	fp_method_first_days_v2<0 & id_tag==1
	// This second browse shows people who have a PN form submitted with FP
	// information before the infant was apparently born so the number of days
	// is negative. Will replace to 0.
*/

replace fp_method_first_days_v2=0 if fp_method_first_days_v2<0
label var fp_method_first_days_v2 ///
	"Days between enrol or infant DOB and first FP method"
sum fp_method_first_days fp_method_first_days_v2 if id_tag==1
	// The second method has a few more observations because it includes clients
	// who are missing an infant DOB but enrolled PN.

recode fp_method_first_days_v2 ///
	(0/41=1 "<6 weeks") ///
	(42/56=2 "6-8 weeks") ///
	(57/120=3 "2-4 months") ///
	(121/180=4 "4-6 months") ///
	(181/max=5 ">6 months"), ///
	gen(fp_method_first_days_cat_v2)
label var fp_method_first_days_cat_v2 ///
	"Time between enrol or delivery and first FP method"
tab fp_method_first_days_cat_v2 if id_tag==1, m
tab fp_method_first_days_cat* if id_tag==1, m


* --> Reduce dataset and save
keeporder country* facility id enrol_date enrol_year num_visits* ///
	tot_duration partner_status_enrol serocon* consistency ///
	fp_educ_ever fp_method_first fp_method_summary fp_method_first_dual ///
	fp_method_first_days*
duplicates drop
numlabel, add
isid id
save "$data/fp_analysis.dta", replace




*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

use "$data/fp_analysis.dta", replace


* --> FP education
tabout fp_educ_ever serocon ///
	using "$output/FP usage/FP education in full sample ($S_DATE).xls", ///
	cells(freq) replace

forvalues i=1/7 {
	tabout fp_educ_ever enrol_year if country2==`i' ///
		using "$output/FP usage/FP education by year - Country `i' ($S_DATE).xls", ///
		cells(freq) replace
}


* --> Uptake of FP method among all HIV negative PN clients after delivery
tabout fp_method_summary enrol_year ///
	using "$output/FP usage/Summary of FP methods used by year ($S_DATE).xls", ///
	cells(freq) replace


* --> First FP method
tabout fp_method_first ///
	using "$output/FP usage/First FP method in full sample ($S_DATE).xls", ///
	cells(freq) replace

tabout fp_method_first enrol_year ///
	using "$output/FP usage/First FP method by year ($S_DATE).xls", ///
	cells(freq) replace
	
	
* --> First FP was dual or not
tabout fp_method_first_dual enrol_year ///
	using "$output/FP usage/First FP method dual by year ($S_DATE).xls", ///
	cells(freq) replace


* --> Consistently on dual or not
tabout consistency enrol_year ///
	using "$output/FP usage/Consistency of single and dual usage by year ($S_DATE).xls", ///
	cells(freq) replace


* --> Timing of first FP method after delivery - categorical variable
tabout fp_method_first_days_cat enrol_year ///
	using "$output/FP usage/Timing of first FP method in categories by year ($S_DATE).xls", ///
	cells(freq) replace


* --> Timing of first FP method after enrol or delivery - categorical variable
tabout fp_method_first_days_cat_v2 enrol_year ///
	using "$output/FP usage/Timing of first FP method in categories v2 by year ($S_DATE).xls", ///
	cells(freq) replace

	
* --> Timing of first FP method after delivery - median and IQR in days
putexcel set ///
	"$output/FP usage/Timing of first FP median and IQR ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "2016"
putexcel A4 = "2017"
putexcel A6 = "2018"
putexcel A8 = "2019"
putexcel A10 = "2020"

gen comma=", "
gen space=" "
gen n="N="
gen b1="("
gen b2=")"

sum fp_method_first_days if country=="Ghana" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel B10 = e
cap putexcel B11 = f
drop a b c d e f

sum fp_method_first_days if country=="Kenya" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel C6 = e
cap putexcel C7 = f
drop a b c d e f

sum fp_method_first_days if country=="Kenya" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel C10 = e
cap putexcel C11 = f
drop a b c d e f

sum fp_method_first_days if country=="Lesotho" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D2 = e
cap putexcel D3 = f
drop a b c d e f

sum fp_method_first_days if country=="Lesotho" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D4 = e
cap putexcel D5 = f
drop a b c d e f

sum fp_method_first_days if country=="Lesotho" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D6 = e
cap putexcel D7 = f
drop a b c d e f

sum fp_method_first_days if country=="Lesotho" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D8 = e
cap putexcel D9 = f
drop a b c d e f

sum fp_method_first_days if country=="Lesotho" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D10 = e
cap putexcel D11 = f
drop a b c d e f

sum fp_method_first_days if country=="Malawi" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel E6 = e
cap putexcel E7 = f
drop a b c d e f

sum fp_method_first_days if country=="SA" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F2 = e
cap putexcel F3 = f
drop a b c d e f

sum fp_method_first_days if country=="SA" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F4 = e
cap putexcel F5 = f
drop a b c d e f

sum fp_method_first_days if country=="SA" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F6 = e
cap putexcel F7 = f
drop a b c d e f

sum fp_method_first_days if country=="SA" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F8 = e
cap putexcel F9 = f
drop a b c d e f

sum fp_method_first_days if country=="SA" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F10 = e
cap putexcel F11 = f
drop a b c d e f

sum fp_method_first_days if country=="Uganda" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G2 = e
cap putexcel G3 = f
drop a b c d e f

sum fp_method_first_days if country=="Uganda" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G4 = e
cap putexcel G5 = f
drop a b c d e f

sum fp_method_first_days if country=="Uganda" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G6 = e
cap putexcel G7 = f
drop a b c d e f

sum fp_method_first_days if country=="Uganda" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G8 = e
cap putexcel G9 = f
drop a b c d e f

sum fp_method_first_days if country=="Uganda" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G10 = e
cap putexcel G11 = f
drop a b c d e f

sum fp_method_first_days if country=="Zambia" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H6 = e
cap putexcel H7 = f
drop a b c d e f

sum fp_method_first_days if country=="Zambia" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H8 = e
cap putexcel H9 = f
drop a b c d e f

sum fp_method_first_days if country=="Zambia" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H10 = e
cap putexcel H11 = f
drop a b c d e f

sum fp_method_first_days, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel I2 = e
cap putexcel I3 = f
drop a b c d e f



* --> Timing of first FP method after enrol or delivery - median and IQR in days
putexcel set ///
	"$output/FP usage/Timing of first FP median and IQR v2 ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "2016"
putexcel A4 = "2017"
putexcel A6 = "2018"
putexcel A8 = "2019"
putexcel A10 = "2020"

sum fp_method_first_days_v2 if country=="Ghana" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel B10 = e
cap putexcel B11 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Kenya" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel C6 = e
cap putexcel C7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Kenya" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel C10 = e
cap putexcel C11 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Lesotho" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D2 = e
cap putexcel D3 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Lesotho" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D4 = e
cap putexcel D5 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Lesotho" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D6 = e
cap putexcel D7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Lesotho" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D8 = e
cap putexcel D9 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Lesotho" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel D10 = e
cap putexcel D11 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Malawi" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel E6 = e
cap putexcel E7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="SA" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F2 = e
cap putexcel F3 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="SA" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F4 = e
cap putexcel F5 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="SA" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F6 = e
cap putexcel F7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="SA" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F8 = e
cap putexcel F9 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="SA" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel F10 = e
cap putexcel F11 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Uganda" & enrol_year==2016, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G2 = e
cap putexcel G3 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Uganda" & enrol_year==2017, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G4 = e
cap putexcel G5 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Uganda" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G6 = e
cap putexcel G7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Uganda" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G8 = e
cap putexcel G9 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Uganda" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel G10 = e
cap putexcel G11 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Zambia" & enrol_year==2018, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H6 = e
cap putexcel H7 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Zambia" & enrol_year==2019, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H8 = e
cap putexcel H9 = f
drop a b c d e f

sum fp_method_first_days_v2 if country=="Zambia" & enrol_year==2020, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel H10 = e
cap putexcel H11 = f
drop a b c d e f

sum fp_method_first_days_v2, d
gen a=`r(N)'
gen b=`r(p50)'
gen c=`r(p25)'
gen d=`r(p75)'
tostring a b c d, replace
egen e=concat(b1 n a b2)
egen f=concat(b space b1 c comma d b2)
cap putexcel I2 = e
cap putexcel I3 = f
drop a b c d e f

