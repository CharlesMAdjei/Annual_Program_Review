*** APR 2020 - Community analysis - 95 95 95
*** Community analysis - Test uptake among partners
* 27 May 2021

/*
Going to look at whether test rates differ by HIV status of the mother.
Have to use the matched sample for this, which is slightly smaller than the
full sample, especially for Zambia, where the matching is particularly poor.
*/


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
drop if hhmem_caseid==""
merge 1:1 hhmem_caseid using "$temp/partner matched to index - 1yr sample.dta"
keep if _merge==3

numlabel, add force
tab client1
keep if client1==4
drop if status_enrol_partner==1
tab country status_enrol_index, m 


* --> Number of tests for partners of non-pos index (including 0)
putexcel set ///
	"$output/HIV testing/partner/Test uptake incl 0 - partner with non-pos index - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/4 {
	local k=`i'+1
	preserve
	keep if country2==`i' & status_enrol_index!=1
	cap putexcel A`k' = "Country `i'"
	count if total_tests_cat!=.
	local total=`r(N)'
	count if total_tests_cat==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
}
local k=6
preserve
keep if status_enrol_index!=1
putexcel A`k' = "m2m"
count if total_tests_cat!=.
local total=`r(N)'
count if total_tests_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


* --> Number of tests for partners of pos mothers (including 0)
putexcel set ///
	"$output/HIV testing/partner/Test uptake incl 0 - partner with pos index - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/4 {
	local k=`i'+1
	preserve
	keep if country2==`i' & status_enrol_index==1
	putexcel A`k' = "Country `i'"
	count if total_tests_cat!=.
	local total=`r(N)'
	count if total_tests_cat==0
	putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==1
	putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==2
	putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==3
	putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	putexcel F`k' = `r(max)'
	putexcel G`k' = `r(mean)',  nformat(number_d2)
	putexcel H`k' = `r(p50)'
	putexcel I`k' = `total'
	restore
}
local k=6
preserve
keep if status_enrol_index==1
putexcel A`k' = "m2m"
count if total_tests_cat!=.
local total=`r(N)'
count if total_tests_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
drop if hhmem_caseid==""
merge 1:1 hhmem_caseid using "$temp/partner matched to index - 2yr sample.dta"
keep if _merge==3

numlabel, add force
tab client1
keep if client1==4
drop if status_enrol_partner==1
tab country status_enrol_index, m 


* --> Number of tests for partners of non-pos index (including 0)
putexcel set ///
	"$output/HIV testing/partner/Test uptake incl 0 - partner with non-pos index - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/3 {
	local k=`i'+1
	preserve
	keep if country2==`i' & status_enrol_index!=1
	putexcel A`k' = "Country `i'"
	count if total_tests_cat!=.
	local total=`r(N)'
	count if total_tests_cat==0
	putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==1
	putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==2
	putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==3
	putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	putexcel F`k' = `r(max)'
	putexcel G`k' = `r(mean)',  nformat(number_d2)
	putexcel H`k' = `r(p50)'
	putexcel I`k' = `total'
	restore
}
local k=5
preserve
keep if status_enrol_index!=1
putexcel A`k' = "m2m"
count if total_tests_cat!=.
local total=`r(N)'
count if total_tests_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


* --> Number of tests for children of pos mothers (including 0)
putexcel set ///
	"$output/HIV testing/partner/Test uptake incl 0 - partner with pos index - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/3 {
	local k=`i'+1
	preserve
	keep if country2==`i' & status_enrol_index==1
	putexcel A`k' = "Country `i'"
	count if total_tests_cat!=.
	local total=`r(N)'
	count if total_tests_cat==0
	putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==1
	putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==2
	putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat==3
	putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	putexcel F`k' = `r(max)'
	putexcel G`k' = `r(mean)',  nformat(number_d2)
	putexcel H`k' = `r(p50)'
	putexcel I`k' = `total'
	restore
}
local k=5
preserve
keep if status_enrol_index==1
putexcel A`k' = "m2m"
count if total_tests_cat!=.
local total=`r(N)'
count if total_tests_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore
