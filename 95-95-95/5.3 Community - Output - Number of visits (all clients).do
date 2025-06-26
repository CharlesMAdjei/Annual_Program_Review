*** APR 2020 - Community analysis - 95 95 95
*** Number of visits
* 26 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear


*------------------------------------------------------------------------------*
* Average # visits during the observation period 

putexcel set "$output/Number of visits/Visits mean - All - 1 year sample ($S_DATE).xlsx", ///
	replace

putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Ghana"
putexcel A3 = "Kenya"
putexcel A4 = "Lesotho"
putexcel A5 = "Malawi"
putexcel A6 = "South Africa"
putexcel A7 = "Uganda"
putexcel A8 = "Zambia"
putexcel A9 = "m2m"

/*
Locals:
j - client type
c - country value
col - column in Excel
row - row in excel
*/

forval c=1/7 {
	local j=0
	foreach col in `c(ALPHA)' {
		if "`col'">="B" & "`col'"<="E" {
			local col="`col'"
			local j=`j'+1
			local row=`c'+1
			sum numvisits_total if client1==`j' & country2==`c'
			putexcel `col'`row' = `r(mean)', nformat(number_d2) 
		}
	}
	local col="F"
	sum numvisits_total if country2==`c'
	putexcel `col'`row' = `r(mean)', nformat(number_d2)
}
	// Each country's row
	
local j=0
foreach col in `c(ALPHA)' {
	if "`col'">="B" & "`col'"<="E" {
		local col="`col'"
		local j=`j'+1
		local row=9
		sum numvisits_total if client1==`j' 
		putexcel `col'`row' = `r(mean)', nformat(number_d2) 
	}
}
local col="F"
local j=9
sum numvisits_total
putexcel `col'`row' = `r(mean)', nformat(number_d2)
	// m2m's row




*------------------------------------------------------------------------------*
* Number of visits by category and median number of visits

forvalues i=1/4 {
	putexcel set "$output/Number of visits/Visits median + categories - All - 1 year sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3"
	putexcel F1 = "4"
	putexcel G1 = "5+"
	putexcel H1 = "Mean"
	putexcel I1 = "Median"
	putexcel J1 = "Max"
	putexcel K1 = "Sample size"


	* --> Visits since enrolment
	local k=2
	putexcel A`k' = "Visits since enrolment"
	count if numvisits_total!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_total==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_total if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'


	* --> Visits in first 3 months
	local k=3
	putexcel A`k' = "Visits (0-3m with m2m)"
	count if numvisits_3m_cat!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_3m_cat==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_3m if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'
}


putexcel set "$output/Number of visits/Visits median + categories - All - 1 year sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3"
putexcel F1 = "4"
putexcel G1 = "5+"
putexcel H1 = "Mean"
putexcel I1 = "Median"
putexcel J1 = "Max"
putexcel K1 = "Sample size"


* --> Visits since enrolment
local k=2
putexcel A`k' = "Visits since enrolment"
count if numvisits_total!=. 
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_total==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_total, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'


* --> Visits in first 3 months
local k=3
putexcel A`k' = "Visits (0-3m with m2m)"
count if numvisits_3m_cat!=.
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_3m_cat==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_3m, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'





*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear


*------------------------------------------------------------------------------*
* Average # visits during the observation period 

putexcel set "$output/Number of visits/Visits mean - All - 2 year sample ($S_DATE).xlsx", ///
	replace

putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Ghana"
putexcel A3 = "Kenya"
putexcel A4 = "Malawi"
putexcel A5 = "Uganda"
putexcel A6 = "Zambia"
putexcel A7 = "m2m"

/*
Locals:
j - client type
c - country value
col - column in Excel
row - row in excel
*/

forval c=1/5 {
	local j=0
	foreach col in `c(ALPHA)' {
		if "`col'">="B" & "`col'"<="E" {
			local col="`col'"
			local j=`j'+1
			local row=`c'+1
			sum numvisits_total if client1==`j' & country2==`c'
			putexcel `col'`row' = `r(mean)', nformat(number_d2) 
		}
	}
	local col="F"
	sum numvisits_total if country2==`c'
	putexcel `col'`row' = `r(mean)', nformat(number_d2)
}
	// Each country's row
	
local j=0
foreach col in `c(ALPHA)' {
	if "`col'">="B" & "`col'"<="E" {
		local col="`col'"
		local j=`j'+1
		local row=7
		sum numvisits_total if client1==`j' 
		putexcel `col'`row' = `r(mean)', nformat(number_d2) 
	}
}
local col="F"
local j=7
sum numvisits_total
putexcel `col'`row' = `r(mean)', nformat(number_d2)
	// m2m's row




*------------------------------------------------------------------------------*
* Number of visits by category and median number of visits

forvalues i=1/4 {
	putexcel set "$output/Number of visits/Visits median + categories - All - 2 year sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3"
	putexcel F1 = "4"
	putexcel G1 = "5+"
	putexcel H1 = "Mean"
	putexcel I1 = "Median"
	putexcel J1 = "Max"
	putexcel K1 = "Sample size"


	* --> Visits since enrolment
	local k=2
	putexcel A`k' = "Visits since enrolment"
	count if numvisits_total!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_total==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_total if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'


	* --> Visits in first 3 months
	local k=3
	putexcel A`k' = "Visits (0-3m with m2m)"
	count if numvisits_3m_cat!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_3m_cat==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_3m if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'
}


putexcel set "$output/Number of visits/Visits median + categories - All - 2 year sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3"
putexcel F1 = "4"
putexcel G1 = "5+"
putexcel H1 = "Mean"
putexcel I1 = "Median"
putexcel J1 = "Max"
putexcel K1 = "Sample size"


* --> Visits since enrolment
local k=2
putexcel A`k' = "Visits since enrolment"
count if numvisits_total!=. 
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_total==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_total, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'


* --> Visits in first 3 months
local k=3
putexcel A`k' = "Visits (0-3m with m2m)"
count if numvisits_3m_cat!=.
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_3m_cat==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_3m, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'



/*
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear


*------------------------------------------------------------------------------*
* Average # visits during the observation period 

putexcel set ///
	"$output/Number of visits/Visits mean - All - 3 year sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Kenya"
putexcel A3 = "Malawi"
putexcel A4 = "Zambia"
putexcel A5 = "m2m"

/*
Locals:
j - client type
c - country value
col - column in Excel
row - row in excel
*/

forval c=1/3 {
	local j=0
	foreach col in `c(ALPHA)' {
		if "`col'">="B" & "`col'"<="E" {
			local col="`col'"
			local j=`j'+1
			local row=`c'+1
			sum numvisits_total if client1==`j' & country2==`c'
			putexcel `col'`row' = `r(mean)', nformat(number_d2) 
		}
	}
	local col="F"
	sum numvisits_total if country2==`c'
	putexcel `col'`row' = `r(mean)', nformat(number_d2)
}
	// Each country's row
	
local j=0
foreach col in `c(ALPHA)' {
	if "`col'">="B" & "`col'"<="E" {
		local col="`col'"
		local j=`j'+1
		local row=5
		sum numvisits_total if client1==`j' 
		putexcel `col'`row' = `r(mean)', nformat(number_d2) 
	}
}
local col="F"
local j=5
sum numvisits_total
putexcel `col'`row' = `r(mean)', nformat(number_d2)
	// m2m's row

	


*------------------------------------------------------------------------------*
* Number of visits by category and median number of visits

forvalues i=1/3 {
	putexcel set "$output/Number of visits/Visits median + categories - All - 3 year sample country `i' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "0"
	putexcel C1 = "1"
	putexcel D1 = "2"
	putexcel E1 = "3"
	putexcel F1 = "4"
	putexcel G1 = "5+"
	putexcel H1 = "Mean"
	putexcel I1 = "Median"
	putexcel J1 = "Max"
	putexcel K1 = "Sample size"


	* --> Visits since enrolment
	local k=2
	putexcel A`k' = "Visits since enrolment"
	count if numvisits_total!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_total==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_total if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'


	* --> Visits in first 3 months
	local k=3
	putexcel A`k' = "Visits (0-3m with m2m)"
	count if numvisits_3m_cat!=. & country2==`i'
	local total=`r(N)'
	local j=0
	foreach a in `c(ALPHA)' {
		if "`a'">="B" & "`a'"<="G" {
			count if numvisits_3m_cat==`j' & country2==`i' 
			putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
			local j=`j'+1
		}
	}
	sum numvisits_3m if country2==`i', d
	putexcel H`k' = `r(mean)',  nformat(number_d2)
	putexcel I`k' = `r(p50)'
	putexcel J`k' = `r(max)'
	putexcel K`k' = `total'
}


putexcel set "$output/Number of visits/Visits median + categories - All - 3 year sample ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "0"
putexcel C1 = "1"
putexcel D1 = "2"
putexcel E1 = "3"
putexcel F1 = "4"
putexcel G1 = "5+"
putexcel H1 = "Mean"
putexcel I1 = "Median"
putexcel J1 = "Max"
putexcel K1 = "Sample size"


* --> Visits since enrolment
local k=2
putexcel A`k' = "Visits since enrolment"
count if numvisits_total!=. 
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_total==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_total, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'


* --> Visits in first 3 months
local k=3
putexcel A`k' = "Visits (0-3m with m2m)"
count if numvisits_3m_cat!=.
local total=`r(N)'
local j=0
foreach a in `c(ALPHA)' {
	if "`a'">="B" & "`a'"<="G" {
		count if numvisits_3m_cat==`j' 
		putexcel `a'`k' = `r(N)'/`total', nformat(number_d2)
		local j=`j'+1
	}
}
sum numvisits_3m, d
putexcel H`k' = `r(mean)',  nformat(number_d2)
putexcel I`k' = `r(p50)'
putexcel J`k' = `r(max)'
putexcel K`k' = `total'


