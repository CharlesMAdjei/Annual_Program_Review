*** APR 2020 - Community analysis - 95 95 95
*** Gap between visits
* 26 May 2021



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Append the client-specific datasets

use	"$temp/index nonpos - gap betw visits - 1yr sample.dta", clear
append using ///
	"$temp/index pos - gap betw visits - 1yr sample.dta" ///
	"$temp/childadol - gap betw visits - 1yr sample.dta" ///
	"$temp/partner - gap betw visits - 1yr sample.dta"
drop if country=="Uganda"

gen x=caseid
replace x=hhmem_caseid if x=="" 
cap drop id
egen id=group(x)
drop x
label var id "Unique identifier across all clients"
svyset id
	
gen client=1 if db=="index_nonpos" & status_enrol==2
replace client=2 if db=="index_nonpos" & status_enrol==0
replace client=3 if db=="index_pos"
replace client=4 if db=="childadol" & age_enrol>=2 & age_enrol<=9
replace client=5 if db=="childadol" & age_enrol>=10 & age_enrol<=19
replace client=6 if db=="partner"
label def client_lab 1"Unknown status index" 2"HIV- index" 3"HIV+ index" ///
	4"Child" 5"Adolescent" 6"Male partner" 
label val client client_lab
label var client "Client type (numeric)"
label var db "App2 form"
tab client, m
drop if client==.

egen country2=group(country)
	
	
	
	
*------------------------------------------------------------------------------*
* Gap between visits for each country

putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 1 year sample ($S_DATE).xls", ///
	replace

local k=2
local j=1
forvalues i=1/4 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 1 year sample country `i' ($S_DATE).xls", ///
		replace

	putexcel B1="0 days"
	putexcel C1="1-30 days"
	putexcel D1="31-60 days"
	putexcel E1="61-90 days"
	putexcel F1=">90 days"
	putexcel G1="Mean"
	putexcel H1="Median"
	putexcel I1="p25"
	putexcel J1="p75"
	putexcel K1="Sample size"
	putexcel A`k'="Enrolment - visit 1"

	count if country2==`i' & gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 & country2==`i'
	putexcel B`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==1 & country2==`i'
	putexcel C`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==2 & country2==`i'
	putexcel D`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==3 & country2==`i'
	putexcel E`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==4 & country2==`i'
	putexcel F`k'=`r(N)'/`total', nformat(percent)

	sum gap_days`j' if country2==`i', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
}

local j=2
local k=`j'+1
local x=`j'-1
while `j' <=10 {
	forvalues i=1/4 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 1 year sample country `i' ($S_DATE).xls", ///
		modify
		
		putexcel A`k'="Visit `x' - visit `j'"
			
		count if country2==`i' & gap_days`j'_cat!=.
		local total=`r(N)'
		count if gap_days`j'_cat==0 & country2==`i'
		putexcel B`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==1 & country2==`i'
		putexcel C`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==2 & country2==`i'
		putexcel D`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==3 & country2==`i'
		putexcel E`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==4 & country2==`i'
		putexcel F`k'=`r(N)'/`total',  nformat(percent)

		sum gap_days`j' if country2==`i', d
		putexcel G`k'=`r(mean)', nformat(number_d2)
		putexcel H`k'=`r(p50)', nformat(number)
		putexcel I`k'=`r(p25)', nformat(number)
		putexcel J`k'=`r(p75)', nformat(number)
		putexcel K`k'=`r(N)'
	}
	local j=`j'+1
	local k=`j'+1
	local x=`j'-1
}

local k=12
local j="_lastv_end"
forvalues i=1/4 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 1 year sample country `i' ($S_DATE).xls", ///
		modify

	putexcel A`k'="Last visit - end period"

	count if country2==`i' & gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 & country2==`i'
	putexcel B`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==1 & country2==`i'
	putexcel C`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==2 & country2==`i'
	putexcel D`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==3 & country2==`i'
	putexcel E`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==4 & country2==`i'
	putexcel F`k'=`r(N)'/`total',  nformat(percent)

	sum gap_days`j' if country2==`i', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
}




*------------------------------------------------------------------------------*
* Gap between visits for m2m 

putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 1 year sample ($S_DATE).xls", ///
	replace

local k=2
local j=1

putexcel B1="0 days"
putexcel C1="1-30 days"
putexcel D1="31-60 days"
putexcel E1="61-90 days"
putexcel F1=">90 days"
putexcel G1="Mean"
putexcel H1="Median"
putexcel I1="p25"
putexcel J1="p75"
putexcel K1="Sample size"
putexcel A`k'="Enrolment - visit 1"

count if gap_days`j'_cat!=.
local total=`r(N)'
count if gap_days`j'_cat==0 
putexcel B`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==1 
putexcel C`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==2 
putexcel D`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==3 
putexcel E`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==4 
putexcel F`k'=`r(N)'/`total', nformat(percent)

sum gap_days`j', d
putexcel G`k'=`r(mean)', nformat(number_d2)
putexcel H`k'=`r(p50)', nformat(number)
putexcel I`k'=`r(p25)', nformat(number)
putexcel J`k'=`r(p75)', nformat(number)
putexcel K`k'=`r(N)'

local j=2
local k=`j'+1
local x=`j'-1
while `j' <=10 {
	putexcel set ///
		"$output/Gap between visits/Visit gaps - All - 1 year sample ($S_DATE).xls", ///
		modify
	
	putexcel A`k'="Visit `x' - visit `j'"
		
	count if gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 
	putexcel B`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==1 
	putexcel C`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==2 
	putexcel D`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==3 
	putexcel E`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==4 
	putexcel F`k'=`r(N)'/`total', nformat(percent)

	sum gap_days`j', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
	
	local j=`j'+1
	local k=`j'+1
	local x=`j'-1
}

local k=12
local j="_lastv_end"
putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 1 year sample ($S_DATE).xls", ///
	modify

putexcel A`k'="Last visit - end period"

count if gap_days`j'_cat!=.
local total=`r(N)'
count if gap_days`j'_cat==0 
putexcel B`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==1 
putexcel C`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==2 
putexcel D`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==3 
putexcel E`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==4 
putexcel F`k'=`r(N)'/`total', nformat(percent)

sum gap_days`j', d
putexcel G`k'=`r(mean)', nformat(number_d2)
putexcel H`k'=`r(p50)', nformat(number)
putexcel I`k'=`r(p25)', nformat(number)
putexcel J`k'=`r(p75)', nformat(number)
putexcel K`k'=`r(N)'




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Append the client-specific datasets

use	"$temp/index nonpos - gap betw visits - 2yr sample.dta", clear
append using ///
	"$temp/index pos - gap betw visits - 2yr sample.dta" ///
	"$temp/childadol - gap betw visits - 2yr sample.dta" ///
	"$temp/partner - gap betw visits - 2yr sample.dta"

gen x=caseid
replace x=hhmem_caseid if x=="" 
cap drop id
egen id=group(x)
drop x
label var id "Unique identifier across all clients"
svyset id
	
gen client=1 if db=="index_nonpos" & status_enrol==2
replace client=2 if db=="index_nonpos" & status_enrol==0
replace client=3 if db=="index_pos"
replace client=4 if db=="childadol" & age_enrol>=2 & age_enrol<=9
replace client=5 if db=="childadol" & age_enrol>=10 & age_enrol<=19
replace client=6 if db=="partner"
label def client_lab 1"Unknown status index" 2"HIV- index" 3"HIV+ index" ///
	4"Child" 5"Adolescent" 6"Male partner" 
label val client client_lab
label var client "Client type (numeric)"
label var db "App2 form"
tab client, m
drop if client==.

egen country2=group(country)
	
	
	
	
*------------------------------------------------------------------------------*
* Gap between visits for each country

putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 2 year sample ($S_DATE).xls", ///
	replace

local k=2
local j=1
forvalues i=1/3 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 2 year sample country `i' ($S_DATE).xls", ///
		replace

	putexcel B1="0 days"
	putexcel C1="1-30 days"
	putexcel D1="31-60 days"
	putexcel E1="61-90 days"
	putexcel F1=">90 days"
	putexcel G1="Mean"
	putexcel H1="Median"
	putexcel I1="p25"
	putexcel J1="p75"
	putexcel K1="Sample size"
	putexcel A`k'="Enrolment - visit 1"

	count if country2==`i' & gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 & country2==`i'
	putexcel B`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==1 & country2==`i'
	putexcel C`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==2 & country2==`i'
	putexcel D`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==3 & country2==`i'
	putexcel E`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==4 & country2==`i'
	putexcel F`k'=`r(N)'/`total', nformat(percent)

	sum gap_days`j' if country2==`i', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
}

local j=2
local k=`j'+1
local x=`j'-1
while `j' <=10 {
	forvalues i=1/3 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 2 year sample country `i' ($S_DATE).xls", ///
		modify
		
		putexcel A`k'="Visit `x' - visit `j'"
			
		count if country2==`i' & gap_days`j'_cat!=.
		local total=`r(N)'
		count if gap_days`j'_cat==0 & country2==`i'
		putexcel B`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==1 & country2==`i'
		putexcel C`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==2 & country2==`i'
		putexcel D`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==3 & country2==`i'
		putexcel E`k'=`r(N)'/`total',  nformat(percent)
		count if gap_days`j'_cat==4 & country2==`i'
		putexcel F`k'=`r(N)'/`total',  nformat(percent)

		sum gap_days`j' if country2==`i', d
		putexcel G`k'=`r(mean)', nformat(number_d2)
		putexcel H`k'=`r(p50)', nformat(number)
		putexcel I`k'=`r(p25)', nformat(number)
		putexcel J`k'=`r(p75)', nformat(number)
		putexcel K`k'=`r(N)'
	}
	local j=`j'+1
	local k=`j'+1
	local x=`j'-1
}

local k=12
local j="_lastv_end"
forvalues i=1/3 {
	putexcel set "$output/Gap between visits/Visit gaps - All - 2 year sample country `i' ($S_DATE).xls", ///
		modify

	putexcel A`k'="Last visit - end period"

	count if country2==`i' & gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 & country2==`i'
	putexcel B`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==1 & country2==`i'
	putexcel C`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==2 & country2==`i'
	putexcel D`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==3 & country2==`i'
	putexcel E`k'=`r(N)'/`total',  nformat(percent)
	count if gap_days`j'_cat==4 & country2==`i'
	putexcel F`k'=`r(N)'/`total',  nformat(percent)

	sum gap_days`j' if country2==`i', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
}




*------------------------------------------------------------------------------*
* Gap between visits for m2m 

putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 2 year sample ($S_DATE).xls", ///
	replace

local k=2
local j=1

putexcel B1="0 days"
putexcel C1="1-30 days"
putexcel D1="31-60 days"
putexcel E1="61-90 days"
putexcel F1=">90 days"
putexcel G1="Mean"
putexcel H1="Median"
putexcel I1="p25"
putexcel J1="p75"
putexcel K1="Sample size"
putexcel A`k'="Enrolment - visit 1"

count if gap_days`j'_cat!=.
local total=`r(N)'
count if gap_days`j'_cat==0 
putexcel B`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==1 
putexcel C`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==2 
putexcel D`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==3 
putexcel E`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==4 
putexcel F`k'=`r(N)'/`total', nformat(percent)

sum gap_days`j', d
putexcel G`k'=`r(mean)', nformat(number_d2)
putexcel H`k'=`r(p50)', nformat(number)
putexcel I`k'=`r(p25)', nformat(number)
putexcel J`k'=`r(p75)', nformat(number)
putexcel K`k'=`r(N)'

local j=2
local k=`j'+1
local x=`j'-1
while `j' <=10 {
	putexcel set ///
		"$output/Gap between visits/Visit gaps - All - 2 year sample ($S_DATE).xls", ///
		modify
	
	putexcel A`k'="Visit `x' - visit `j'"
		
	count if gap_days`j'_cat!=.
	local total=`r(N)'
	count if gap_days`j'_cat==0 
	putexcel B`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==1 
	putexcel C`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==2 
	putexcel D`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==3 
	putexcel E`k'=`r(N)'/`total', nformat(percent)
	count if gap_days`j'_cat==4 
	putexcel F`k'=`r(N)'/`total', nformat(percent)

	sum gap_days`j', d
	putexcel G`k'=`r(mean)', nformat(number_d2)
	putexcel H`k'=`r(p50)', nformat(number)
	putexcel I`k'=`r(p25)', nformat(number)
	putexcel J`k'=`r(p75)', nformat(number)
	putexcel K`k'=`r(N)'
	
	local j=`j'+1
	local k=`j'+1
	local x=`j'-1
}

local k=12
local j="_lastv_end"
putexcel set ///
	"$output/Gap between visits/Visit gaps - All - 2 year sample ($S_DATE).xls", ///
	modify

putexcel A`k'="Last visit - end period"

count if gap_days`j'_cat!=.
local total=`r(N)'
count if gap_days`j'_cat==0 
putexcel B`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==1 
putexcel C`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==2 
putexcel D`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==3 
putexcel E`k'=`r(N)'/`total', nformat(percent)
count if gap_days`j'_cat==4 
putexcel F`k'=`r(N)'/`total', nformat(percent)

sum gap_days`j', d
putexcel G`k'=`r(mean)', nformat(number_d2)
putexcel H`k'=`r(p50)', nformat(number)
putexcel I`k'=`r(p25)', nformat(number)
putexcel J`k'=`r(p75)', nformat(number)
putexcel K`k'=`r(N)'


