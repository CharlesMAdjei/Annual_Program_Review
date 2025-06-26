*** APR 2020 - Community analysis - 95 95 95
*** Community analysis - At least 1 test amongst all client types with 2+ visits
* 26 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
numlabel, add force
drop if status_enrol==1
drop if numvisits_total<2
tab client2
tab client1

* --> Original version (unknown + neg combined for each)	
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients - 1yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "South Africa"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "Index"
putexcel A3 = "Child"
putexcel A4 = "Adolescent"
putexcel A5 = "Partner"
putexcel A6 = "All clients"

local k="B"
preserve
keep if country=="Ghana"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="C"
preserve
keep if country=="Kenya"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="D"
preserve
keep if country=="Lesotho"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="E"
preserve
keep if country=="Malawi"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="F"
preserve
keep if country=="South Africa"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client1==2
*putexcel `k'3 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client1==3
*putexcel `k'4 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client1==4
*putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="G"
preserve
keep if country=="Uganda"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="H"
preserve
keep if country=="Zambia"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="I"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)


* --> New version (unknown + neg separated for each)
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients (sep by status) - 1yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Lesotho"
putexcel E1 = "Malawi"
putexcel F1 = "South Africa"
putexcel G1 = "Uganda"
putexcel H1 = "Zambia"
putexcel I1 = "m2m"
putexcel A2 = "Index (HIV-neg)"
putexcel A3 = "Index (unknown status)"
putexcel A4 = "Child (HIV-neg)"
putexcel A5 = "Child (unknown status)"
putexcel A6 = "Adolescent (HIV-neg)"
putexcel A7 = "Adolescent (unknown status)"
putexcel A8 = "Partner (HIV-neg)"
putexcel A9 = "Partner (unknown status)"
putexcel A10 = "All"

local k="B"
preserve
keep if country=="Ghana"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
cap putexcel `k'5 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==8
*putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="C"
preserve
keep if country=="Kenya"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="D"
preserve
keep if country=="Lesotho"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==5
*putexcel `k'4 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==6
*putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==12
*putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="E"
preserve
keep if country=="Malawi"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore


local k="F"
preserve
keep if country=="South Africa"
*sum atleast1_test if client2==2
*putexcel `k'2 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==3
*putexcel `k'3 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==5
*putexcel `k'4 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==6
*putexcel `k'5 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==8
*putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
*sum atleast1_test if client2==11
*putexcel `k'8 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==12
*putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="G"
preserve
keep if country=="Uganda"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="H"
preserve
keep if country=="Zambia"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==3
*putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==6
*putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="I"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)





*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
numlabel, add force
drop if status_enrol==1
drop if numvisits_total<2
tab client2
tab client1

* --> Original version (unknown + neg combined for each)	
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients - 2yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Malawi"
putexcel E1 = "Uganda"
putexcel F1 = "Zambia"
putexcel G1 = "m2m"
putexcel A2 = "Index"
putexcel A3 = "Child"
putexcel A4 = "Adolescent"
putexcel A5 = "Partner"
putexcel A6 = "All clients"

local k="B"
preserve
keep if country=="Ghana"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=3
local k="C"
preserve
keep if country=="Kenya"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=4
local k="D"
preserve
keep if country=="Malawi"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=5
local k="E"
preserve
keep if country=="Uganda"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=6
local k="F"
preserve
keep if country=="Zambia"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="G"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)


* --> New version (unknown + neg separated for each)
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients (sep by status) - 2yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Ghana"
putexcel C1 = "Kenya"
putexcel D1 = "Malawi"
putexcel E1 = "Uganda"
putexcel F1 = "Zambia"
putexcel G1 = "m2m"
putexcel A2 = "Index (HIV-neg)"
putexcel A3 = "Index (unknown status)"
putexcel A4 = "Child (HIV-neg)"
putexcel A5 = "Child (unknown status)"
putexcel A6 = "Adolescent (HIV-neg)"
putexcel A7 = "Adolescent (unknown status)"
putexcel A8 = "Partner (HIV-neg)"
putexcel A9 = "Partner (unknown status)"
putexcel A10 = "All"

local k="B"
preserve
keep if country=="Ghana"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==8
*putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=3
local k="C"
preserve
keep if country=="Kenya"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=4
local k="D"
preserve
keep if country=="Malawi"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=5
local k="E"
preserve
keep if country=="Uganda"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
*sum atleast1_test if client2==6
*putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=6
local k="F"
preserve
keep if country=="Zambia"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="G"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)



/*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
numlabel, add force
drop if status_enrol==1
drop if numvisits_total<2
tab client2
tab client1

* --> Original version (unknown + neg combined for each)	
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients - 2yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Kenya"
putexcel C1 = "Malawi"
putexcel D1 = "Zambia"
putexcel E1 = "m2m"
putexcel A2 = "Index"
putexcel A3 = "Child"
putexcel A4 = "Adolescent"
putexcel A5 = "Partner"
putexcel A6 = "All clients"

local k="B"
preserve
keep if country=="Kenya"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=3
local k="C"
preserve
keep if country=="Malawi"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local i=4
local k="D"
preserve
keep if country=="Zambia"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)
restore

local k="E"
sum atleast1_test if client1==1
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==2
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==3
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client1==4
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'6 = `r(mean)', nformat(number_d2)


* --> New version (unknown + neg separated for each)
putexcel set ///
	"$output/HIV testing/All clients/At least 1 test - all clients (sep by status) - 2yr sample (2+ visits) ($S_DATE).xlsx", ///
	replace
	
putexcel B1 = "Kenya"
putexcel C1 = "Malawi"
putexcel D1 = "Zambia"
putexcel E1 = "m2m"
putexcel A2 = "Index (HIV-neg)"
putexcel A3 = "Index (unknown status)"
putexcel A4 = "Child (HIV-neg)"
putexcel A5 = "Child (unknown status)"
putexcel A6 = "Adolescent (HIV-neg)"
putexcel A7 = "Adolescent (unknown status)"
putexcel A8 = "Partner (HIV-neg)"
putexcel A9 = "Partner (unknown status)"
putexcel A10 = "All"

local k="B"
preserve
keep if country=="Kenya"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=3
local k="C"
preserve
keep if country=="Malawi"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local i=4
local k="D"
preserve
keep if country=="Zambia"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = 0, nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
restore

local k="E"
sum atleast1_test if client2==2
putexcel `k'2 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==3
putexcel `k'3 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==5
putexcel `k'4 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==6
putexcel `k'5 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==8
putexcel `k'6 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==9
putexcel `k'7 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==11
putexcel `k'8 = `r(mean)', nformat(number_d2) 
sum atleast1_test if client2==12
putexcel `k'9 = `r(mean)', nformat(number_d2) 
sum atleast1_test
putexcel `k'10 = `r(mean)', nformat(number_d2)
