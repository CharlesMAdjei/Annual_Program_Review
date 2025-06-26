*** APR 2020 - Community analysis - 95 95 95
*** Test uptake amongst negative and unknown index
* 26 May 2021



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*-----------------------------------------------------------------------------*
* Index clients - unknown status at enrolment

use "$temp/all clients - full dataset - 1yr sample.dta", clear
numlabel, add force
tab client2
keep if client2==3


* --> Number of tests including 0
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake incl 0 - index unknown - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

* Ghana Kenya Malawi South Africa
forvalues i=1/6 {
	local k=`i'+1
	preserve
	keep if country2==`i'
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


local k=8
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


* --> Number of tests excl 0
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake excl 0 - index unknown - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/6 {
	local k=`i'+1
	preserve
	keep if country2==`i'
	putexcel A`k' = "Country `i'"
	count if total_tests_cat_sans0!=.
	local total=`r(N)'
	count if total_tests_cat_sans0==0
	putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==1
	putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==2
	putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==3
	putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	putexcel F`k' = `r(max)'
	putexcel G`k' = `r(mean)', nformat(number_d2)
	putexcel H`k' = `r(p50)'
	putexcel I`k' = `total'
	restore
}
local k=8
putexcel A`k' = "m2m"
count if total_tests_cat_sans0!=.
local total=`r(N)'
count if total_tests_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'




*-----------------------------------------------------------------------------*
* Index clients - HIV-negative at enrolment

use "$temp/all clients - full dataset - 1yr sample.dta", clear
numlabel, add force
tab client2
keep if client2==2


* --> Number of tests including 0
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake incl 0 - index neg - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/6 {
	local k=`i'+1
	preserve
	keep if country2==`i'
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
local k=8
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


* --> Number of tests excl 0
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake excl 0 - index neg - 1yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

forvalues i=1/6 {
	local k=`i'+1
	preserve
	keep if country2==`i'
	putexcel A`k' = "Country `i'"
	count if total_tests_cat_sans0!=.
	local total=`r(N)'
	count if total_tests_cat_sans0==0
	putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==1
	putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==2
	putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==3
	putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	putexcel F`k' = `r(max)'
	putexcel G`k' = `r(mean)', nformat(number_d2)
	putexcel H`k' = `r(p50)'
	putexcel I`k' = `total'
	restore
}
local k=8
putexcel A`k' = "m2m"
count if total_tests_cat_sans0!=.
local total=`r(N)'
count if total_tests_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*-----------------------------------------------------------------------------*
* Index clients - unknown status at enrolment

use "$temp/all clients - full dataset - 2yr sample.dta", clear
numlabel, add force
tab client2
keep if client2==3
	

/*
* --> Includes CIs, excludes mean, median and max.
qui tabout country total_tests_cat  ///
	using "$output/HIV testing/Test uptake - index nonpos - 2yr sample v1 ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
*/


* --> Since enrolment, in 1st year and in 2021, incl 0 tests
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake incl 0 - index unknown - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

local k=2
putexcel A`k' = "Since enrolment"
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

local k=4
putexcel A`k' = "In first year"
preserve
count if total_tests_yr1_cat!=.
local total=`r(N)'
count if total_tests_yr1_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_yr1 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore

local k=4
putexcel A`k' = "In 2021"
preserve
count if total_tests_2021_cat!=.
local total=`r(N)'
count if total_tests_2021_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_2021 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


* --> Since enrolment, in 1st year and in 2021, incl 0 tests, for each country
forvalues i=1/3 {
	putexcel set ///
		"$output/HIV testing/caregiver/Test uptake incl 0 - index unknown - 2yr sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3+"
	putexcel F1 = "Max"
	putexcel G1 = "Mean"
	putexcel H1 = "Median"
	putexcel I1 = "Sample"

	local k=2
	cap putexcel A`k' = "Since enrolment"
	preserve
	keep if country2==`i'
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
	
	local k=3
	cap putexcel A`k' = "In first year"
	preserve
	keep if country2==`i'
	count if total_tests_yr1_cat!=.
	local total=`r(N)'
	count if total_tests_yr1_cat==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_yr1 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
	
	local k=4
	cap putexcel A`k' = "In 2021"
	preserve
	keep if country2==`i'
	count if total_tests_2021_cat!=.
	local total=`r(N)'
	count if total_tests_2021_cat==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_2021 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
}


* --> Since enrolment, in 1st year and in 2021, excl 0 tests
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake excl 0 - index unknown - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

local k=2
putexcel A`k' = "Since enrolment"
count if total_tests_cat_sans0!=.
local total=`r(N)'
count if total_tests_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'

local k=3
putexcel A`k' = "In first year"
preserve
count if total_tests_yr1_cat_sans0!=.
local total=`r(N)'
count if total_tests_yr1_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_yr1 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore

local k=4
putexcel A`k' = "In 2021"
preserve
count if total_tests_2021_cat_sans0!=.
local total=`r(N)'
count if total_tests_2021_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_2021 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


* --> Since enrolment, in 1st year and in 2021, excl 0 tests, for each country
	forvalues i=1/3 {
		putexcel set ///
			"$output/HIV testing/caregiver/Test uptake excl 0 - index unknown - 2yr sample country `i' ($S_DATE).xlsx", ///
			replace
			
		putexcel B1 = "0"
		putexcel C1 = "1"
		putexcel D1 = "2"
		putexcel E1 = "3+"
		putexcel F1 = "Max"
		putexcel G1 = "Mean"
		putexcel H1 = "Median"
		putexcel I1 = "Sample"

		local k=2
		cap putexcel A`k' = "Since enrolment"
		preserve
		keep if country2==`i'
		count if total_tests_cat_sans0!=.
		local total=`r(N)'
		count if total_tests_cat_sans0==0
		cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_cat_sans0==1
		cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_cat_sans0==2
		cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_cat_sans0==3
		cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
		sum total_tests if id_tag==1, d
		cap putexcel F`k' = `r(max)'
		cap putexcel G`k' = `r(mean)',  nformat(number_d2)
		cap putexcel H`k' = `r(p50)'
		cap putexcel I`k' = `total'
		restore
		
		local k=3
		cap putexcel A`k' = "In first year"
		preserve
		keep if country2==`i'
		count if total_tests_yr1_cat_sans0!=.
		local total=`r(N)'
		count if total_tests_yr1_cat_sans0==0
		cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_yr1_cat_sans0==1
		cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_yr1_cat_sans0==2
		cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_yr1_cat_sans0==3
		cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
		sum total_tests_yr1 if id_tag==1, d
		cap putexcel F`k' = `r(max)'
		cap putexcel G`k' = `r(mean)',  nformat(number_d2)
		cap putexcel H`k' = `r(p50)'
		cap putexcel I`k' = `total'
		restore

		local k=4
		cap putexcel A`k' = "In 2021"
		preserve
		keep if country2==`i'
		count if total_tests_2021_cat_sans0!=.
		local total=`r(N)'
		count if total_tests_2021_cat_sans0==0
		cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_2021_cat_sans0==1
		cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_2021_cat_sans0==2
		cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
		count if total_tests_2021_cat_sans0==3
		cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
		sum total_tests_2021 if id_tag==1, d
		cap putexcel F`k' = `r(max)'
		cap putexcel G`k' = `r(mean)',  nformat(number_d2)
		cap putexcel H`k' = `r(p50)'
		cap putexcel I`k' = `total'
		restore
}




*-----------------------------------------------------------------------------*
* Index clients - HIV negative at enrolment

use "$temp/all clients - full dataset - 2yr sample.dta", clear
numlabel, add force
tab client2
keep if client2==2
	

/*
* --> Includes CIs, excludes mean, median and max.
qui tabout country total_tests_cat  ///
	using "$output/HIV testing/Test uptake - index nonpos - 2yr sample v1 ($S_DATE).xls", ///
	c(row ci) f(1p 1) svy lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per cisep(-) h3(nil) ///
	replace 
*/


* --> Since enrolment, in 1st year and in 2021, incl 0 tests, for all sites
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake incl 0 - index neg - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

local k=2
putexcel A`k' = "Since enrolment"
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

local k=3
putexcel A`k' = "In first year"
preserve
count if total_tests_yr1_cat!=.
local total=`r(N)'
count if total_tests_yr1_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_yr1 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore

local k=4
putexcel A`k' = "In 2021"
preserve
count if total_tests_2021_cat!=.
local total=`r(N)'
count if total_tests_2021_cat==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_2021 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


* --> Since enrolment, in 1st year and in 2021, incl 0 tests, for each country
forvalues i=1/3 {
	putexcel set ///
		"$output/HIV testing/caregiver/Test uptake incl 0 - index neg - 2yr sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3+"
	putexcel F1 = "Max"
	putexcel G1 = "Mean"
	putexcel H1 = "Median"
	putexcel I1 = "Sample"

	local k=2
	cap putexcel A`k' = "Since enrolment"
	preserve
	keep if country2==`i'
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
	
	local k=3
	cap putexcel A`k' = "In first year"
	preserve
	keep if country2==`i'
	count if total_tests_yr1_cat!=.
	local total=`r(N)'
	count if total_tests_yr1_cat==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_yr1 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore

	local k=4
	cap putexcel A`k' = "In 2021"
	preserve
	keep if country2==`i'
	count if total_tests_2021_cat!=.
	local total=`r(N)'
	count if total_tests_2021_cat==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_2021 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
}


* --> Since enrolment, in 1st year and in 2021, excl 0 tests
putexcel set ///
	"$output/HIV testing/caregiver/Test uptake excl 0 - index neg - 2yr sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3+"
putexcel F1 = "Max"
putexcel G1 = "Mean"
putexcel H1 = "Median"
putexcel I1 = "Sample"

local k=2
putexcel A`k' = "Since enrolment"
count if total_tests_cat_sans0!=.
local total=`r(N)'
count if total_tests_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'

local k=3
putexcel A`k' = "In first year"
preserve
count if total_tests_yr1_cat_sans0!=.
local total=`r(N)'
count if total_tests_yr1_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_yr1_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_yr1 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore

local k=4
putexcel A`k' = "In 2021"
preserve
count if total_tests_2021_cat_sans0!=.
local total=`r(N)'
count if total_tests_2021_cat_sans0==0
putexcel B`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==1
putexcel C`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==2
putexcel D`k' = `r(N)'/`total', nformat(number_d2)
count if total_tests_2021_cat_sans0==3
putexcel E`k' = `r(N)'/`total', nformat(number_d2)
sum total_tests_2021 if id_tag==1, d
putexcel F`k' = `r(max)'
putexcel G`k' = `r(mean)',  nformat(number_d2)
putexcel H`k' = `r(p50)'
putexcel I`k' = `total'
restore


forvalues i=1/3 {
	putexcel set ///
		"$output/HIV testing/caregiver/Test uptake excl 0 - index neg - 2yr sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3+"
	putexcel F1 = "Max"
	putexcel G1 = "Mean"
	putexcel H1 = "Median"
	putexcel I1 = "Sample"

	local k=2
	cap putexcel A`k' = "Since enrolment"
	preserve
	keep if country2==`i'
	count if total_tests_cat_sans0!=.
	local total=`r(N)'
	count if total_tests_cat_sans0==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_cat_sans0==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
	
	local k=3
	cap putexcel A`k' = "In first year"
	preserve
	keep if country2==`i'
	count if total_tests_yr1_cat_sans0!=.
	local total=`r(N)'
	count if total_tests_yr1_cat_sans0==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat_sans0==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat_sans0==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_yr1_cat_sans0==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_yr1 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore

	local k=4
	cap putexcel A`k' = "In 2021"
	preserve
	keep if country2==`i'
	count if total_tests_2021_cat_sans0!=.
	local total=`r(N)'
	count if total_tests_2021_cat_sans0==0
	cap putexcel B`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat_sans0==1
	cap putexcel C`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat_sans0==2
	cap putexcel D`k' = `r(N)'/`total', nformat(number_d2)
	count if total_tests_2021_cat_sans0==3
	cap putexcel E`k' = `r(N)'/`total', nformat(number_d2)
	sum total_tests_2021 if id_tag==1, d
	cap putexcel F`k' = `r(max)'
	cap putexcel G`k' = `r(mean)',  nformat(number_d2)
	cap putexcel H`k' = `r(p50)'
	cap putexcel I`k' = `total'
	restore
}

