*** APR 2020 - Primary prevention
*** Analysis - Seroconversion
* 7 July 2021



*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Create dataset for seroconversion analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

use "$temp/an_pn_cleaned.dta", replace
egen country2=group(country)
tab country*
keep if sample==1

keeporder country2 facility id enrol_date client_type ///
	tot_duration partner_status_enrol ///
	serocon time_serocon_days time_serocon serocon_year
duplicates drop
numlabel, add
isid id

gen enrol_year=year(enrol_date)
keep if enrol_year >= 2019
gen has_partner=partner_status!=.
label var has_partner "Client has a partner"
cap label drop partner_status
label def partner_status 0"Neg" 1"Pos" 2"Unknown"
lab val partner_status_enrol partner_status
tab has_partner partner_status_enrol, m





*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

*------------------------------------------------------------------------------*		
* Seroconversion rate by country and year

putexcel set ///
	"$output/Seroconversion/Seroconversion rate by country and year ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Neg Ghana"
putexcel C1 = "Serocon Ghana"
putexcel D1 = "Neg Kenya"
putexcel E1 = "Serocon Kenya"
putexcel F1 = "Neg Lesotho"
putexcel G1 = "Serocon Lesotho"
putexcel H1 = "Neg Malawi"
putexcel I1 = "Serocon Malawi"
putexcel J1 = "Neg SA"
putexcel K1 = "Serocon SA"
putexcel L1 = "Neg Uganda"
putexcel M1 = "Serocon Uganda"
putexcel N1 = "Neg Zambia"
putexcel O1 = "Serocon Zambia"
putexcel P1 = "Neg m2m"
putexcel Q1 = "Serocon m2m"

forvalues i=2019/2021 {
	local k=`i'-2017
	cap putexcel A`k' = "`i'"
	
	sum serocon if enrol_year==`i' & country2==1
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(sum)'
	
	sum serocon if enrol_year==`i' & country2==2
	cap putexcel D`k' = `r(N)'
	cap putexcel E`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==3
	cap putexcel F`k' = `r(N)'
	cap putexcel G`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==4
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==5
	cap putexcel J`k' = `r(N)'
	cap putexcel K`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==6
	cap putexcel L`k' = `r(N)'
	cap putexcel M`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==7
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(sum)'

	sum serocon if enrol_year==`i'
	cap putexcel P`k' = `r(N)'
	cap putexcel Q`k' = `r(sum)'
}




*------------------------------------------------------------------------------*		
* Time from m2m enrolment to seroconversion

putexcel set ///
	"$output/Seroconversion/Time to seroconversion ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Median"
putexcel C1 = "25th perc"
putexcel D1 = "75th perc"

forvalues i=1/7 {
	local k=`i'+1
	putexcel A`k' = "Country `i'"
	sum time_serocon if country2==`i', d
	cap putexcel B`k' = `r(p50)'
	cap putexcel C`k' = `r(p25)'
	cap putexcel D`k' = `r(p75)'
}
local k=9
putexcel A`k' = "m2m"
sum time_serocon, d
cap putexcel B`k' = `r(p50)'
cap putexcel C`k' = `r(p25)'
cap putexcel D`k' = `r(p75)'




*------------------------------------------------------------------------------*		
* Seroconversion rate by relationship status
/*
This doesn't produce the full table that is needed in the excel sheet and the
slides, just the absolute numbers. The table in excel then calculates the %.
*/

putexcel set ///
	"$output/Seroconversion/Seroconversion by relationship status ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Neg #"
putexcel C1 = "Serocon #"

local k=2
cap putexcel A`k' = "No partner"
sum serocon if has_partner==0
cap putexcel B`k' = `r(N)'-`r(sum)'
cap putexcel C`k' = `r(sum)'

local k=3
cap putexcel A`k' = "Partner"
sum serocon if has_partner==1
cap putexcel B`k' = `r(N)'-`r(sum)'
cap putexcel C`k'=`r(sum)'




*------------------------------------------------------------------------------*		
* Seroconversion rate by partner's status
/*
This doesn't produce the full table that is needed in the excel sheet and the
slides, just the absolute numbers. The table in excel then calculates the %.
*/


putexcel set ///
	"$output/Seroconversion/Seroconversion by partner's status 2019 ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Neg"
putexcel C1 = "Serocon"
putexcel A1 = "Partner's status"
putexcel A2 = "Neg"
putexcel A3 = "Pos"
putexcel A4 = "Unknown"


local k=2
sum serocon if partner_status_enrol==0 & enrol_year== 2019
cap putexcel B`k' = `r(N)'-`r(sum)'
cap putexcel C`k' = `r(sum)'

local k=3
sum serocon if partner_status_enrol==1 & enrol_year== 2019
cap putexcel B`k' = `r(N)'-`r(sum)'
cap putexcel C`k'=`r(sum)'

local k=4
sum serocon if partner_status_enrol==2 & enrol_year== 2019
cap putexcel B`k' = `r(N)'-`r(sum)'
cap putexcel C`k'=`r(sum)'







putexcel set ///
	"$output/Seroconversion/Seroconversion rate by country and year has a partner ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Neg Ghana"
putexcel C1 = "Serocon Ghana"
putexcel D1 = "Neg Kenya"
putexcel E1 = "Serocon Kenya"
putexcel F1 = "Neg Lesotho"
putexcel G1 = "Serocon Lesotho"
putexcel H1 = "Neg Malawi"
putexcel I1 = "Serocon Malawi"
putexcel J1 = "Neg SA"
putexcel K1 = "Serocon SA"
putexcel L1 = "Neg Uganda"
putexcel M1 = "Serocon Uganda"
putexcel N1 = "Neg Zambia"
putexcel O1 = "Serocon Zambia"
putexcel P1 = "Neg m2m"
putexcel Q1 = "Serocon m2m"

forvalues i=2019/2021 {
	local k=`i'-2017
	cap putexcel A`k' = "`i'"
	
	sum serocon if enrol_year==`i' & country2==1 & has_partner==0
	cap putexcel B`k' = `r(N)'
	cap putexcel C`k' = `r(sum)'
	
	sum serocon if enrol_year==`i' & country2==2 & has_partner==0
	cap putexcel D`k' = `r(N)'
	cap putexcel E`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==3 & has_partner==0
	cap putexcel F`k' = `r(N)'
	cap putexcel G`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==4 & has_partner==0
	cap putexcel H`k' = `r(N)'
	cap putexcel I`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==5 & has_partner==0
	cap putexcel J`k' = `r(N)'
	cap putexcel K`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==6 & has_partner==0
	cap putexcel L`k' = `r(N)'
	cap putexcel M`k' = `r(sum)'

	sum serocon if enrol_year==`i' & country2==7 & has_partner==0
	cap putexcel N`k' = `r(N)'
	cap putexcel O`k' = `r(sum)'

	sum serocon if enrol_year==`i' & has_partner==0
	cap putexcel P`k' = `r(N)'
	cap putexcel Q`k' = `r(sum)'
}

