*** APR 2020 - Primary prevention
*** Analysis - HIV testing
* 7 July 2021



*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Create dataset for retest analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		
/*
This code is based on Jude's do file '1.number_of_retest' in the analysis folder.
*/



use "$temp/an_pn_cleaned.dta", replace
egen country2=group(country)
tab country*


* --> Restrict to variables relevant to HIV testing analysis and save
keep if sample==1
keeporder country2 facility id id_s client_type ///
	enrol_date visit_date tot_duration ///
	hiv_retest_prev_due_date hiv_retest_prev_done_date ///
	hiv_retest_due_date hiv_retest_done_date ///
	partner_status_enrol 
save "$temp/hiv_retest1.dta", replace


* --> Remove variables relating to current HIV test due and done date
keeporder country2 facility id id_s client_type ///
	enrol_date visit_date tot_duration ///
	hiv_retest_prev_due_date hiv_retest_prev_done_date ///
	partner_status_enrol
ren hiv_retest_prev_* hiv_retest_* 
save "$temp/prev_test.dta", replace
	// The previous due and done are renamed to match the current due and
	// done date variables for the append command below. This is so that we
	// put the previous and current dues and dones in a single set of variables.

	
* --> Append previous two datasets and drop perfect duplicates
use "$temp/hiv_retest1.dta", clear
keeporder country2 facility id id_s client_type ///
	enrol_date visit_date tot_duration ///
	hiv_retest_due_date hiv_retest_done_date ///
	partner_status_enrol
append using "$temp/prev_test.dta"
duplicates drop


* --> Identifying unique retest due and done dates
foreach x in due done {
	cap drop tag
	egen tag=tag(id hiv_retest_`x'_date)
	gen hiv_retest_`x'_date2=hiv_retest_`x'_date if tag==1
	format hiv_retest_`x'_date2 %td
}
drop tag


* --> Numbering the unique due and done dates
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


* --> Time between enrolment and 1st, 2nd, 3rd, 4th and 5th HIV retest 
forvalues x=1/5 {
	gen time_retest`x'_en=time_retest_enrol if done_retest_number==`x' 
	egen time_retest`x'_enrol=max(time_retest`x'_en), by(id)
	drop time_retest`x'_en
	label var time_retest`x'_enrol ///
		"# months between enrolment and HIV retest `x'"
}
/*
sort id visit_date
br id_s visit_date hiv_retest_done_date hiv_retest_done_date2 ///
	done_retest_number num_retest_done time_retest_enrol ///
	time_retest?_enrol
*/


* --> Fix labelling of partner's status
cap label drop partner_status
label def partner_status 0"Neg" 1"Pos" 2"Unknown"
lab val partner_status_enrol partner_status
tab partner_status_enrol


* --> Save dataset
numlabel, add
gen enrol_year=year(enrol_date)
keeporder country facility id enrol_date enrol_year client_type ///
	tot_duration partner_status_enrol num_retest_due num_retest_done ///
	ever_retest_d* time_retest?_enrol
duplicates drop
isid id
save "$data/HIV_tests_analysis.dta", replace






*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		
/*
This code is based on Jude's do file "2.number_of_retest_analysis_script"
*/

use "$data/HIV_tests_analysis.dta", clear
svyset id


*------------------------------------------------------------------------------*		
* % clients with at least 1 scheduled test by client type
/*
Jude's code
bys client_type: mdesc num_retest_due, no
	// # clients with no missing values for the num_retest_due
	
bys client_type: mdesc num_retest_due
	// Opposite of above 
*/	
	
tabout ever_retest_due client_type if enrol_year > 2019 ///
	using "$output/Testing/Scheduled tests ($S_DATE).xls", ///
	c(col /*ci*/) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per /*cisep(-)*/ h3(nil) ///
	replace 


	
	
*------------------------------------------------------------------------------*		
* Number of retests done and total duration in the programme - AN-only
/*
* Jude's code
foreach x in 2016 2017 2018 2019 2020 {
	tabstat num_retest_done tot_duration if enrol_year==`x' & client_type==1, ///
		stats(p50 p25 p75 N) by(country) col(stats)
}

Jude's code calculated median number of tests done for those with 1+ tests
because of how he calculated the number of retests done above (those with 
no tests were missing on that variable as opposed to 0). I replicate his code
and also run it including those with no retests at all.
*/

putexcel set ///
	"$output/Testing/Median tests and exposure - AN only (incl 0 tests) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"




forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if country2==`i' & client_type==1 & enrol_year > 2019
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*	
	sum num_retest_done, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if client_type==1 & enrol_year > 2019
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration, d
cap putexcel J`k' = `r(p50)'

/*
sum num_retest_done, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration, d
cap putexcel M`k' = `r(p50)'


sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore


putexcel set ///
	"$output/Testing/Median tests and exposure - AN only (excl 0 tests) ($S_DATE).xlsx", ///
	replace
	
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"



forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if enrol_year>2019
	keep if country2==`i' & client_type==1 & num_retest_done > 0
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2021, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*	
	sum num_retest_done, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if enrol_year>2019
keep if client_type==1 & num_retest_done > 0
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration , d
cap putexcel J`k' = `r(p50)'

/*
sum num_retest_done, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore




*------------------------------------------------------------------------------*		
* Number of retests done and total duration in the programme - PN-only

putexcel set ///
	"$output/Testing/Median tests and exposure - PN only (incl 0 tests) ($S_DATE).xlsx", ///
	replace
	
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"



forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if enrol_year > 2019
	keep if country2==`i' & client_type==2
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2021, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*
	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if enrol_year > 2019
keep if client_type==2
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration , d
cap putexcel J`k' = `r(p50)'


/*
sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore


putexcel set ///
	"$output/Testing/Median tests and exposure - PN only (excl 0 tests) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"



forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if enrol_year > 2019
	keep if country2==`i' & client_type==2 & num_retest_done > 0
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2021, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*	
	sum num_retest_done, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if enrol_year>2019
keep if client_type==2 & num_retest_done > 0
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration, d
cap putexcel J`k' = `r(p50)'

/*
sum num_retest_done, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration, d
cap putexcel M`k' = `r(p50)'


sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore




*------------------------------------------------------------------------------*		
* Number of retests done and total duration in the programme - AN+PN

putexcel set ///
	"$output/Testing/Median tests and exposure - AN+PN (incl 0 tests) ($S_DATE).xlsx", ///
	replace
	
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"





forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if enrol_year > 2019
	keep if country2==`i' & client_type==3
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2021, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*	
	sum num_retest_done, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if enrol_year > 2019
keep if client_type==3
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration, d
cap putexcel J`k' = `r(p50)'

/*
sum num_retest_done, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore


putexcel set ///
	"$output/Testing/Median tests and exposure - AN+PN (excl 0 tests) ($S_DATE).xlsx", ///
	replace
	
	
putexcel B1 = "N (2020)"
putexcel C1 = "Median # retests (2020)"
putexcel D1 = "Median duration in m2m (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Median # retests (2021)"
putexcel G1 = "Median duration in m2m (2021)"
putexcel H1 = "N"
putexcel I1 = "Median # retests"
putexcel J1 = "Median duration in m2m"




forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if enrol_year>2019
	keep if country2==`i' & client_type==3 & num_retest_done > 0
	cap putexcel A`k' = "Country `i'"
	
	sum num_retest_done if enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel D`k' = `r(p50)'
	
	sum num_retest_done if enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(p50)'
	sum tot_duration if enrol_year==2021, d
	cap putexcel G`k' = `r(p50)'
	
	sum num_retest_done, d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel J`k' = `r(p50)'
/*	
	sum num_retest_done, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(p50)'
	sum tot_duration if enrol_year==2019, d
	cap putexcel M`k' = `r(p50)'

	sum num_retest_done if enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(p50)'
	sum tot_duration if enrol_year==2020, d
	cap putexcel P`k' = `r(p50)'

	sum num_retest_done, d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(p50)'
	sum tot_duration, d
	cap putexcel S`k' = `r(p50)'
*/
	restore
}

local k=9
preserve
keep if enrol_year>2019
keep if client_type==3 & num_retest_done > 0
cap putexcel A`k' = "m2m"

sum num_retest_done if enrol_year==2020, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel D`k' = `r(p50)'

sum num_retest_done if enrol_year==2021, d
cap putexcel E`k' = `r(N)'
cap putexcel F`k' = `r(p50)'
sum tot_duration if enrol_year==2021, d
cap putexcel G`k' = `r(p50)'

sum num_retest_done, d
cap putexcel H`k' = `r(N)'
cap putexcel I`k' = `r(p50)'
sum tot_duration, d
cap putexcel J`k' = `r(p50)'
/*
sum num_retest_done, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration, d
cap putexcel M`k' = `r(p50)'


sum num_retest_done if enrol_year==2019, d
cap putexcel K`k' = `r(N)'
cap putexcel L`k' = `r(p50)'
sum tot_duration if enrol_year==2019, d
cap putexcel M`k' = `r(p50)'

sum num_retest_done if enrol_year==2020, d
cap putexcel N`k' = `r(N)'
cap putexcel O`k' = `r(p50)'
sum tot_duration if enrol_year==2020, d
cap putexcel P`k' = `r(p50)'

sum num_retest_done, d
cap putexcel Q`k' = `r(N)'
cap putexcel R`k' = `r(p50)'
sum tot_duration, d
cap putexcel S`k' = `r(p50)'
*/
restore


/*
* Build on this bit of code if need to create tables that include IQR. Haven't 
* done it yet because don't think the tables are legible.
	
putexcel set ///
	"$output/Testing/Number of retests with IQR ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "N"
putexcel C1 = "Median # retests"
putexcel D1 = "25th perc retests"
putexcel E1 = "75th perc retests "
putexcel F1 = "Median duration in m2m"
putexcel G1 = "25th perc duration in m2m"
putexcel H1 = "75th perc duration in m2m"

forvalues i=1/7 {
	local k=`i'+1
	preserve
	keep if country2==`i' & client_type==1
	cap putexcel A`k' = "Country `i'"
	sum num_retest_done, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(p50)'
	cap putexcel D`k' = `r(p25)'
	cap putexcel E`k' = `r(p75)'
	sum tot_duration, d
	cap putexcel F`k' = `r(p50)'
	cap putexcel G`k' = `r(p25)'
	cap putexcel H`k' = `r(p75)'
	
	restore
}
local k=9
preserve
keep if client_type==1
cap putexcel A`k' = "m2m"
sum num_retest_done, d
cap putexcel B`k' = `r(N)'
cap putexcel C`k' = `r(p50)'
cap putexcel D`k' = `r(p25)'
cap putexcel E`k' = `r(p75)'
sum tot_duration, d
cap putexcel F`k' = `r(p50)'
cap putexcel G`k' = `r(p25)'
cap putexcel H`k' = `r(p75)'
restore
	// This code isn't complete yet as it is done for all years together
	// and only for AN only clients.
	
*/
	

	
	
*------------------------------------------------------------------------------*		
* Median duration to each test (from enrolment)

/*
* Jude's code
forvalues i=1/7 {
	tabstat time_retest1_enrol-time_retest5_enrol if country2==`i', ///
		stats(p50) by(enrol_year) col(stats)
}
tabstat time_retest1_enrol-time_retest5_enrol, ///
	stats(p50) by(enrol_year) col(stats)
*/

forvalues j=1/5 {

	putexcel set ///
		"$output/Testing/Median duration to test `j' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "Ghana"
	putexcel C1 = "Kenya"
	putexcel D1 = "Lesotho"
	putexcel E1 = "Malawi"
	putexcel F1 = "SA"
	putexcel G1 = "Uganda"
	putexcel H1 = "Zambia"
	putexcel I1 = "m2m"

	forvalues i=2020/2021 {
		local k=`i'-2018
		cap putexcel A`k' = "`i'"
		
		sum time_retest`j'_enrol if enrol_year==`i' & country2==1, d
		cap putexcel B`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==2, d
		cap putexcel C`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==3, d
		cap putexcel D`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==4, d
		cap putexcel E`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==5, d
		cap putexcel F`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==6, d
		cap putexcel G`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i' & country2==7, d
		cap putexcel H`k' = `r(p50)'
		sum time_retest`j'_enrol if enrol_year==`i', d
		cap putexcel I`k' = `r(p50)'
	}
}

*/

	
*------------------------------------------------------------------------------*		
* Distribution of tests by year of enrolment

/*
* Jude's code
bys enrol_year: tab country num_retest_done, row
*/

* --> Including 0 tests
forvalues i=2020/2021 {
	tabout country num_retest_done if enrol_year==`i' ///
		using "$output/Testing/Distribution of tests (incl 0) - `i' ($S_DATE).xls", ///
		c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout country num_retest_done  if enrol_year > 2019 ///
	using "$output/Testing/Distribution of tests (incl 0) - all ($S_DATE).xls", ///
	c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
* --> Excluding 0 tests
forvalues i=2020/2021 {
	preserve
	replace num_retest_done=. if num_retest_done==0
	tabout country num_retest_done if enrol_year==`i' ///
		using "$output/Testing/Distribution of tests (excl 0) - `i' ($S_DATE).xls", ///
		c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
	restore
}
preserve
replace num_retest_done=. if num_retest_done==0
tabout country num_retest_done if enrol_year > 2019 ///
	using "$output/Testing/Distribution of tests (excl 0) - all ($S_DATE).xls", ///
	c(row) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
restore




*------------------------------------------------------------------------------*		
* Mean and SD of retests done by partner HIV status

/*
* Jude's code
tabstat num_retest_done, stats(N mean sd) by(partner) col(stats)
*/

putexcel set ///
	"$output/Testing/Tests by partner status ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "N (2020)"
putexcel C1 = "Mean (2020)"
putexcel D1 = "SD (2020)"
putexcel E1 = "N (2021)"
putexcel F1 = "Mean (2021)"
putexcel G1 = "SD (2021)"
putexcel H1 = "N"
putexcel I1 = "Mean"
putexcel J1 = "SD"
cap putexcel A2 = "Negative"
cap putexcel A3 = "Positive"
cap putexcel A4 = "Unknown"

forvalues i=0/2 {
	local k=`i'+2
	keep if enrol_year > 2019
	sum num_retest_done if partner_status_enrol==`i' & enrol_year==2020, d
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(mean)'
	cap putexcel D`k' = `r(sd)'

	sum num_retest_done if partner_status_enrol==`i' & enrol_year==2021, d
	cap putexcel E`k' = `r(N)'
	cap putexcel F`k' = `r(mean)'
	cap putexcel G`k' = `r(sd)'

	sum num_retest_done if partner_status_enrol==`i', d
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(mean)'
	cap putexcel J`k' = `r(sd)'
	/*
	sum num_retest_done if partner_status_enrol==`i', d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(mean)'
	cap putexcel M`k' = `r(sd)'
	
	sum num_retest_done if partner_status_enrol==`i' & enrol_year==2019, d
	cap putexcel K`k' = `r(N)'
	cap putexcel L`k' = `r(mean)'
	cap putexcel M`k' = `r(sd)'
	
	sum num_retest_done if partner_status_enrol==`i' & enrol_year==2020, d
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(mean)'
	cap putexcel P`k' = `r(sd)'
	
	sum num_retest_done if partner_status_enrol==`i', d
	cap putexcel Q`k' = `r(N)'
	cap putexcel R`k' = `r(mean)'
	cap putexcel S`k' = `r(sd)'	
	*/
}

