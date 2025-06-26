*** APR 2020 - Primary prevention
*** Analysis - Client characteristics
* 9 July 2021



*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Create dataset for analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		



use "$temp/an_pn_cleaned.dta", replace
egen country2=group(country)
keep if sample==1


* --> Calculate number of visits in total and by AN/PN
egen num_contacts=max(visit_num), by(id)
label var num_contacts "# contacts with m2m"
gen visit_an=dataset==1
gen visit_pn=dataset==2
egen num_contacts_an=sum(visit_an), by(id)
egen num_contacts_pn=sum(visit_pn), by(id)
label var num_contacts_an "# AN contacts with m2m"
label var num_contacts_pn "# PN contacts with m2m"


* --> Gestational age
replace gestation_firstm2m=gestation_firstanc if ///
	gestation_firstm2m>42


* --> Restrict to relevant variables and save
keeporder country* facility id client_type *_any age ///
	enrol_date visit_date visit_num tot_duration num_contacts* ///
	hiv_retest_prev_due_date hiv_retest_prev_done_date ///
	hiv_retest_due_date hiv_retest_done_date gestation_* ///
	serocon time_serocon_days time_serocon serocon_year
save "$temp/characs1.dta", replace


* --> Remove variables relating to current HIV test due and done date
drop hiv_retest_due_date hiv_retest_done_date 
ren hiv_retest_prev_* hiv_retest_* 
save "$temp/characs2.dta", replace
	// The previous due and done are renamed to match the current due and
	// done date variables for the append command below. This is so that we
	// put the previous and current dues and dones in a single set of variables.

	
* --> Append previous two datasets and drop perfect duplicates
use "$temp/characs1.dta", clear
drop hiv_retest_prev_due_date hiv_retest_prev_done_date 
append using "$temp/characs2.dta"
duplicates drop


* --> Identify unique retest due and done dates
foreach x in due done {
	cap drop tag
	egen tag=tag(id hiv_retest_`x'_date)
	gen hiv_retest_`x'_date2=hiv_retest_`x'_date if tag==1
	format hiv_retest_`x'_date2 %td
}
drop tag


* --> Number the unique due and done dates
foreach x in due done {
	bys id (hiv_retest_`x'_date2): gen `x'_retest_number=_n if ///
		hiv_retest_`x'_date2!=.
}


* --> Total number of unique dues and dones
foreach x in due done {
	egen num_retest_`x'=max(`x'_retest_number), by(id) 
	replace num_retest_`x'=5 if num_retest_`x'>=5 & num_retest_`x'!=.
	replace num_retest_`x'=0 if num_retest_`x'==.
	lab var num_retest_`x' "Total # unique retest `x' dates"
}
tab1 num_retest_due num_retest_done


* --> Have one or more dues/dones
foreach x in due done {
	cap drop ever_retest_`x'
	gen ever_retest_`x'=num_retest_`x'>0 & num_retest_`x'<.
	label var ever_retest_`x' "Has 1 or more HIV test `x' dates"
	tab num_retest_`x' ever_retest_`x', m
}


* --> Duration between enrolment and each test done date
gen time_retest_enrol=round((hiv_retest_done_date2-enrol_date)/30.5) if ///
	hiv_retest_done_date2!=.
replace time_retest_enrol=0 if time_retest_enrol<1
label var time_retest_enrol "# months between enrolment and test done date"


* --> Time between enrolment and first and last tests
egen time_retest_first_enrol=min(time_retest_enrol), by(id)
egen time_retest_last_enrol=max(time_retest_enrol), by(id)


* --> Keep 1 obs per client and relevant variables
keeporder country* facility id enrol_date client_type an_any pn_any age ///
	tot_duration gestation* num_contacts* ///
	time_retest_first_enrol time_retest_last_enrol num_retest* serocon*
gen enrol_year=year(enrol_date)
	
duplicates drop
numlabel, add
isid id
save "$data/client_characs_analysis.dta", replace




*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

use "$data/client_characs_analysis.dta", clear

putexcel set ///
	"$output/Seroconversion/Client characteristics ($S_DATE).xlsx", ///
	replace

putexcel B1 = "Neg 2020"
putexcel C1 = "Serocon 2020"
putexcel D1 = "Neg 2021"
putexcel E1 = "Serocon 2021"
putexcel A2 = "Sample size"
putexcel A3 = "Age (mean)"
putexcel A4 = "Age (SD)"
putexcel A5 = "Gestage 1st ANC (mean)"
putexcel A6 = "Gestage 1st ANC (SD)"
putexcel A7 = "Gestage 1st m2m (mean)"
putexcel A8 = "Gestage 1st m2m (SD)"
putexcel A9= "Number of AN contacts (median)"
putexcel A10 = "Number of AN contacts (IQR)"
putexcel A11 = "Number of PN contacts (median)"
putexcel A12 = "Number of PN contacts (IQR)"
putexcel A13 = "Time to first recorded test (median)"
putexcel A14 = "Time to first recorded test (IQR)"
putexcel A15 = "Time to last recorded test (median)"
putexcel A16 = "Time to last recorded test (IQR)"
putexcel A17 = "Number of retests (mean)"
putexcel A18 = "Number of retests (SD)"

gen punc=", "
gen b1="("
gen b2=")"


* --> 2020
preserve

keep if enrol_year==2020

sum serocon 
putexcel B2 = `r(N)'-`r(sum)'
putexcel C2 = `r(sum)'

sum age if serocon==0 
putexcel B3 = `r(mean)'
putexcel B4 = `r(sd)'
sum age if serocon==1 
putexcel C3 = `r(mean)'
putexcel C4 = `r(sd)'

sum gestation_firstanc if serocon==0 
putexcel B5 = `r(mean)'
putexcel B6 = `r(sd)'
sum gestation_firstanc if serocon==1 
putexcel C5 = `r(mean)'
putexcel C6 = `r(sd)'

sum gestation_firstm2m if serocon==0 
putexcel B7 = `r(mean)'
putexcel B8 = `r(sd)'
sum gestation_firstm2m if serocon==1 
putexcel C7 = `r(mean)'
putexcel C8 = `r(sd)'

sum num_contacts_an if an_any==1 & serocon==0, d 
putexcel B9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel B10 = c
drop a b c
sum num_contacts_an if an_any==1 & serocon==1, d 
putexcel C9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel C10 = c
drop a b c

sum num_contacts_pn if pn_any==1 & serocon==0, d 
putexcel B11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel B12 = c
drop a b c
sum num_contacts_pn if pn_any==1 & serocon==1, d 
putexcel C11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel C12 = c
drop a b c

sum time_retest_first_enrol if serocon==0, d 
putexcel B13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel B14 = c
drop a b c
sum time_retest_first_enrol if serocon==1, d 
putexcel C13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel C14 = c
drop a b c

sum time_retest_last_enrol if serocon==0, d 
putexcel B15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel B16 = c
drop a b c
sum time_retest_last_enrol if serocon==1, d 
putexcel C15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel C16 = c
drop a b c

sum num_retest_done if serocon==0 
putexcel B17 = `r(mean)'
putexcel B18 = `r(sd)'
sum num_retest_done if serocon==1 
putexcel C17 = `r(mean)'
putexcel C18 = `r(sd)'

restore


* --> 2021
preserve

keep if enrol_year==2021

sum serocon 
putexcel D2 = `r(N)'-`r(sum)'
putexcel E2 = `r(sum)'

sum age if serocon==0 
putexcel D3 = `r(mean)'
putexcel D4 = `r(sd)'
sum age if serocon==1 
putexcel E3 = `r(mean)'
putexcel E4 = `r(sd)'

sum gestation_firstanc if serocon==0 
putexcel D5 = `r(mean)'
putexcel D6 = `r(sd)'
sum gestation_firstanc if serocon==1 
putexcel E5 = `r(mean)'
putexcel E6 = `r(sd)'

sum gestation_firstm2m if serocon==0 
putexcel D7 = `r(mean)'
putexcel D8 = `r(sd)'
sum gestation_firstm2m if serocon==1 
putexcel E7 = `r(mean)'
putexcel E8 = `r(sd)'

sum num_contacts_an if an_any==1 & serocon==0, d 
putexcel D9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel D10 = c
drop a b c
sum num_contacts_an if an_any==1 & serocon==1, d 
putexcel E9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel E10 = c
drop a b c

sum num_contacts_pn if pn_any==1 & serocon==0, d 
putexcel D11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel D12 = c
drop a b c
sum num_contacts_pn if pn_any==1 & serocon==1, d 
putexcel E11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel E12 = c
drop a b c

sum time_retest_first_enrol if serocon==0, d 
putexcel D13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel D14 = c
drop a b c
sum time_retest_first_enrol if serocon==1, d 
putexcel E13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel E14 = c
drop a b c

sum time_retest_last_enrol if serocon==0, d 
putexcel D15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel D16 = c
drop a b c
sum time_retest_last_enrol if serocon==1, d 
putexcel E15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel E16 = c
drop a b c

sum num_retest_done if serocon==0 
putexcel D17 = `r(mean)'
putexcel D18 = `r(sd)'
sum num_retest_done if serocon==1 
putexcel E17 = `r(mean)'
putexcel E18 = `r(sd)'

restore

/*
* --> 2019
preserve

keep if enrol_year==2019

sum serocon 
putexcel F2 = `r(N)'-`r(sum)'
putexcel G2 = `r(sum)'

sum age if serocon==0 
putexcel F3 = `r(mean)'
putexcel F4 = `r(sd)'
sum age if serocon==1 
putexcel G3 = `r(mean)'
putexcel G4 = `r(sd)'

sum gestation_firstanc if serocon==0 
putexcel F5 = `r(mean)'
putexcel F6 = `r(sd)'
sum gestation_firstanc if serocon==1 
putexcel G5 = `r(mean)'
putexcel G6 = `r(sd)'

sum gestation_firstm2m if serocon==0 
putexcel F7 = `r(mean)'
putexcel F8 = `r(sd)'
sum gestation_firstm2m if serocon==1 
putexcel G7 = `r(mean)'
putexcel G8 = `r(sd)'

sum num_contacts_an if an_any==1 & serocon==0, d 
putexcel F9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel F10 = c
drop a b c
sum num_contacts_an if an_any==1 & serocon==1, d 
putexcel G9 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel G10 = c
drop a b c

sum num_contacts_pn if pn_any==1 & serocon==0, d 
putexcel F11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel F12 = c
drop a b c
sum num_contacts_pn if pn_any==1 & serocon==1, d 
putexcel G11 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel G12 = c
drop a b c

sum time_retest_first_enrol if serocon==0, d 
putexcel F13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel F14 = c
drop a b c
sum time_retest_first_enrol if serocon==1, d 
putexcel G13 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel G14 = c
drop a b c

sum time_retest_last_enrol if serocon==0, d 
putexcel F15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel F16 = c
drop a b c
sum time_retest_last_enrol if serocon==1, d 
putexcel G15 = `r(p50)'
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(b1 a punc b b2)
cap putexcel G16 = c
drop a b c

sum num_retest_done if serocon==0 
putexcel F17 = `r(mean)'
putexcel F18 = `r(sd)'
sum num_retest_done if serocon==1 
putexcel G17 = `r(mean)'
putexcel G18 = `r(sd)'

restore
*/

