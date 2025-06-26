*** APR 2020 - Primary prevention
*** Analysis - Sample description
* 8 July 2021



*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Create dataset for analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		


use "$temp/an_pn_cleaned.dta", replace
egen country2=group(country)


* --> Calculate number of visits in total and by AN/PN
isid id visit_date
	// Checking that the dataset is unique on ID and visit date, i.e. that
	// no client has more than 1 row or obs with the same visit date in it.
	// I fixed this in the cleaning do file, but just wanted to check.
	
egen num_contacts=max(visit_num), by(id)
label var num_contacts "# contacts with m2m"
tab num_contacts if id_tag==1, m

gen visit_an=dataset==1
gen visit_pn=dataset==2
egen num_contacts_an=sum(visit_an), by(id)
egen num_contacts_pn=sum(visit_pn), by(id)
assert num_contacts_an+num_contacts_pn==num_contacts
label var num_contacts_an "# AN contacts with m2m"
label var num_contacts_pn "# PN contacts with m2m"
/*
sort id visit_date
br id_s visit_num visit_date dataset visit_?n num_contacts*
*/


* --> Gestational age
tab gestation_firstanc if id_tag==1, m
tab gestation_firstm2m if id_tag==1, m
replace gestation_firstm2m=gestation_firstanc if ///
	gestation_firstm2m>42

	
* --> Keep 1 obs per client and relevant variables
keeporder country* facility id enrol_date client_type an_any pn_any ///
	tot_duration partner_status_enrol ///
	gestation* num_contacts* sample
gen enrol_year=year(enrol_date)
	
duplicates drop
numlabel, add
isid id
save "$data/Sample_analysis.dta", replace




*------------------------------------------------------------------------------*		
////////////////////////////////////////////////////////////////////////////////
* Analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*		

use "$data/Sample_analysis.dta", clear
svyset id


*------------------------------------------------------------------------------*		
* Number and distribution of clients by country, client type and year of
* enrolment
/*
These tables are a bit of a mess but they do a good enough job
*/

tab country client_type
tabout country client_type if enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by client type v1 ($S_DATE).xls", ///
	cells(freq row) replace

tabout country client_type if enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by client type v2 ($S_DATE).xls", ///
	cells(freq col) f(1 1p) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

tabout country enrol_year if enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by country ($S_DATE).xls", ///
	c(col) f(1p 1) svy lay(row) npos(col) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

tabout enrol_year country if enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by year - All v1 ($S_DATE).xls", ///
	cells(freq /*col*/) replace

tabout country enrol_year if enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by year - All v2 ($S_DATE).xls", ///
	cells(freq /*col*/) replace

tabout country enrol_year if sample==1 & enrol_year > 2019 ///
	using "$output//Sample description/Total enrolment by year - HIV neg ($S_DATE).xls", ///
	cells(freq /*col*/) replace




*------------------------------------------------------------------------------*		
* Gestational age at first m2m and ANC visit among AN-any clients
/*
Since I don't have Jude's code for this part of the analysis, and he doesn't
explicitly say who his sample is in the slides, I am going to assume it is
just HIV negative clients.
*/

putexcel set ///
	"$output/Sample description/Gestage mean by country ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "First m2m"
putexcel C1 = "First ANC"

forvalues i=1/7 {
	local k=`i'+1
	cap putexcel A`k' = "Country `i'"
	
	preserve
	keep if sample==1 & an_any==1 & country2==`i' & enrol_year > 2019
	
	sum gestation_firstm2m
	cap putexcel B`k' = `r(mean)'
	sum gestation_firstanc
	cap putexcel C`k' = `r(mean)'
	
	restore
}
local k=9
cap putexcel A`k' = "m2m"
preserve
keep if sample==1 & an_any==1 & enrol_year > 2019
sum gestation_firstm2m
cap putexcel B`k' = `r(mean)'
sum gestation_firstanc
cap putexcel C`k' = `r(mean)'
restore


putexcel set ///
	"$output/Sample description/Gestage SD by country ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "Gestational age at first m2m"
putexcel A3 = "Gestational age at first ANC"

preserve
keep if sample==1 & an_any==1 & enrol_year > 2019
	
sum gestation_firstm2m if country=="Ghana"
cap putexcel B2 = `r(sd)'
sum gestation_firstanc if country=="Ghana"
cap putexcel B3 = `r(sd)'

sum gestation_firstm2m if country=="Kenya"
cap putexcel C2 = `r(sd)'
sum gestation_firstanc if country=="Kenya"
cap putexcel C3 = `r(sd)'

sum gestation_firstm2m if country=="Lesotho"
cap putexcel D2 = `r(sd)'
sum gestation_firstanc if country=="Lesotho"
cap putexcel D3 = `r(sd)'

sum gestation_firstm2m if country=="Malawi"
cap putexcel E2 = `r(sd)'
sum gestation_firstanc if country=="Malawi"
cap putexcel E3 = `r(sd)'

sum gestation_firstm2m if country=="SA"
cap putexcel F2 = `r(sd)'
sum gestation_firstanc if country=="SA"
cap putexcel F3 = `r(sd)'

sum gestation_firstm2m if country=="Uganda"
cap putexcel G2 = `r(sd)'
sum gestation_firstanc if country=="Uganda"
cap putexcel G3 = `r(sd)'

sum gestation_firstm2m if country=="Zambia"
cap putexcel H2 = `r(sd)'
sum gestation_firstanc if country=="Zambia"
cap putexcel H3 = `r(sd)'

sum gestation_firstm2m
cap putexcel I2 = `r(sd)'
sum gestation_firstanc
cap putexcel I3 = `r(sd)'

restore


forvalues j=2020/2021 {
	putexcel set ///
		"$output/Sample description/Gestage mean by country - `j' ($S_DATE).xlsx", ///
		replace
		
	putexcel B1 = "First m2m"
	putexcel C1 = "First ANC"

	forvalues i=1/7 {
		local k=`i'+1
		cap putexcel A`k' = "Country `i'"
		
		preserve
		keep if sample==1 & an_any==1 & country2==`i' & enrol_year==`j'
		
		sum gestation_firstm2m
		cap putexcel B`k' = `r(mean)'
		sum gestation_firstanc
		cap putexcel C`k' = `r(mean)'
		
		restore
	}
	local k=9
	cap putexcel A`k' = "m2m"
	preserve
	keep if sample==1 & an_any==1 & enrol_year==`j'
	sum gestation_firstm2m
	cap putexcel B`k' = `r(mean)'
	sum gestation_firstanc
	cap putexcel C`k' = `r(mean)'
	restore
}




*------------------------------------------------------------------------------*		
* Number of m2m contacts - over all years

* --> Median # visits
putexcel set ///
	"$output/Sample description/m2m contacts median - all years ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "AN"
putexcel A3 = "PN"

preserve
keep if sample==1 & enrol_year > 2019
	
sum num_contacts_an if country=="Ghana" & an_any==1, d
cap putexcel B2 = `r(p50)'
sum num_contacts_pn if country=="Ghana" & pn_any==1, d
cap putexcel B3 = `r(p50)'

sum num_contacts_an if country=="Kenya" & an_any==1, d
cap putexcel C2 = `r(p50)'
sum num_contacts_pn if country=="Kenya" & pn_any==1, d
cap putexcel C3 = `r(p50)'

sum num_contacts_an if country=="Lesotho" & an_any==1, d
cap putexcel D2 = `r(p50)'
sum num_contacts_pn if country=="Lesotho" & pn_any==1, d
cap putexcel D3 = `r(p50)'

sum num_contacts_an if country=="Malawi" & an_any==1, d
cap putexcel E2 = `r(p50)'
sum num_contacts_pn if country=="Malawi" & pn_any==1, d
cap putexcel E3 = `r(p50)'

sum num_contacts_an if country=="SA" & an_any==1, d
cap putexcel F2 = `r(p50)'
sum num_contacts_pn if country=="SA" & pn_any==1, d
cap putexcel F3 = `r(p50)'

sum num_contacts_an if country=="Uganda" & an_any==1, d
cap putexcel G2 = `r(p50)'
sum num_contacts_pn if country=="Uganda" & pn_any==1, d
cap putexcel G3 = `r(p50)'

sum num_contacts_an if country=="Zambia" & an_any==1, d
cap putexcel H2 = `r(p50)'
sum num_contacts_pn if country=="Zambia" & pn_any==1, d
cap putexcel H3 = `r(p50)'

sum num_contacts_an if an_any==1, d
cap putexcel I2 = `r(p50)'
sum num_contacts_pn if pn_any==1, d
cap putexcel I3 = `r(p50)'

restore


* --> IQR of visits
putexcel set ///
	"$output/Sample description/m2m contacts IQR - all years ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "AN"
putexcel A3 = "PN"

preserve
keep if sample==1 & enrol_year > 2019
cap drop punc
gen punc=", "
	
sum num_contacts_an if country=="Ghana" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel B2 = c
drop a b c
sum num_contacts_pn if country=="Ghana" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel B3 = c
drop a b c

sum num_contacts_an if country=="Kenya" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel C2 = c
drop a b c
sum num_contacts_pn if country=="Kenya" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel C3 = c
drop a b c

sum num_contacts_an if country=="Lesotho" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel D2 = c
drop a b c
sum num_contacts_pn if country=="Lesotho" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel D3 = c
drop a b c

sum num_contacts_an if country=="Malawi" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel E2 = c
drop a b c
sum num_contacts_pn if country=="Malawi" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel E3 = c
drop a b c

sum num_contacts_an if country=="SA" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel F2 = c
drop a b c
sum num_contacts_pn if country=="SA" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel F3 = c
drop a b c

sum num_contacts_an if country=="Uganda" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel G2 = c
drop a b c
sum num_contacts_pn if country=="Uganda" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel G3 = c
drop a b c

sum num_contacts_an if country=="Zambia" & an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel H2 = c
drop a b c
sum num_contacts_pn if country=="Zambia" & pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel H3 = c
drop a b c

sum num_contacts_an if an_any==1, d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel I2 = c
drop a b c
sum num_contacts_pn if pn_any==1,d
gen a=`r(p25)'
gen b=`r(p75)'
tostring a b, replace
egen c=concat(a punc b)
cap putexcel I3 = c
drop a b c

restore




*------------------------------------------------------------------------------*		
* Number of m2m contacts - disaggregated by year

* --> AN contacts
putexcel set ///
	"$output/Sample description/m2m AN contacts median by year ($S_DATE).xlsx", ///
	replace
			
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "2020"
putexcel A3 = "2021"



preserve
keep if sample==1 & an_any==1
forvalues j=2020/2021 {
	local k=`j'-2018
	sum num_contacts_an if country=="Ghana" & enrol_year==`j', d
	cap putexcel B`k' = `r(p50)'
	sum num_contacts_an if country=="Kenya" & enrol_year==`j', d
	cap putexcel C`k' = `r(p50)'
	sum num_contacts_an if country=="Lesotho" & enrol_year==`j', d
	cap putexcel D`k' = `r(p50)'
	sum num_contacts_an if country=="Malawi" & enrol_year==`j', d
	cap putexcel E`k' = `r(p50)'
	sum num_contacts_an if country=="SA" & enrol_year==`j', d
	cap putexcel F`k' = `r(p50)'
	sum num_contacts_an if country=="Uganda" & enrol_year==`j', d
	cap putexcel G`k' = `r(p50)'
	sum num_contacts_an if country=="Zambia" & enrol_year==`j', d
	cap putexcel H`k' = `r(p50)'
	sum num_contacts_an if enrol_year==`j', d
	cap putexcel I`k' = `r(p50)'
}
restore


* --> PN contacts
putexcel set ///
	"$output/Sample description/m2m PN contacts median by year ($S_DATE).xlsx", ///
	replace
			
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "SA"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "2020"
putexcel A3 = "2021"



preserve
keep if sample==1 & pn_any==1

forvalues j=2020/2021 {
	local k=`j'-2018
	sum num_contacts_pn if country=="Ghana" & enrol_year==`j', d
	cap putexcel B`k' = `r(p50)'
	sum num_contacts_pn if country=="Kenya" & enrol_year==`j', d
	cap putexcel C`k' = `r(p50)'
	sum num_contacts_pn if country=="Lesotho" & enrol_year==`j', d
	cap putexcel D`k' = `r(p50)'
	sum num_contacts_pn if country=="Malawi" & enrol_year==`j', d
	cap putexcel E`k' = `r(p50)'
	sum num_contacts_pn if country=="SA" & enrol_year==`j', d
	cap putexcel F`k' = `r(p50)'
	sum num_contacts_pn if country=="Uganda" & enrol_year==`j', d
	cap putexcel G`k' = `r(p50)'
	sum num_contacts_pn if country=="Zambia" & enrol_year==`j', d
	cap putexcel H`k' = `r(p50)'
	sum num_contacts_pn if enrol_year==`j', d
	cap putexcel I`k' = `r(p50)'
}
restore
