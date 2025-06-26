*** APR 2021 - PMTCT cascade
*** Data of clients missing key outcomes - 2 year cohort
* 16 april 2021



*------------------------------------------------------------------------------*
* Kenya

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Kenya clients missing outcomes - 2yr.xlsx", ///
	sheet("To import") firstrow clear
rename *, lower
drop if id==""
gen updated_excel=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - kenya.dta", replace




*------------------------------------------------------------------------------*
* Lesotho

*------------*
* Mafeteng

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - Mafeteng.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1
keep country facility caseid updated* ///
	test_68wk_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mafeteng.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1
keep country facility caseid updated* ///
	test_68wk_result
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta", replace


* No infants have their conflicting result updated


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - Mafeteng.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mafeteng.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=. /* |  ///
	test_1824m_test_done_date_min!=. */
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if /* test_1824m_test_done_date_min!=. | */ ///
	test_1824m_result!=.
*gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta", replace


* No infants missing ART in this district


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mafeteng.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. /* | vl_test_result!="" */
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. /* | vl_test_result!="" */ 
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
tostring vl_test_result, replace
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mafeteng.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta"



*------------*
* Maseru

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=.
gen updated_firstestdate=1
keep country facility caseid updated* ///
	test_68wk_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
gen updated_firstestresult=1
keep country facility caseid updated* ///
	test_68wk_result
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestconflict=1
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=. | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m_test_done_date_min test_1824m_result
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho maseru.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing ART") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") 
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_infantart=1
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - maseru.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | vl_test_result!=""
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""
keep country facility caseid updated* ///
	vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho maseru.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho maseru.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho maseru.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
tostring vl_test_result, replace
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho maseru.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho maseru.dta"




*------------*
* Mhoek

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1
keep country facility caseid updated* ///
	test_68wk_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1
keep country facility caseid updated* ///
	test_68wk_result
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestconflict=1
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=. 
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_1824m_test_done_date_min!=. 
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - mhoek.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | vl_test_result!="" 
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. /* | vl_test_result!="" */ 
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mhoek.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mhoek.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho mhoek.dta", update
drop _merge
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mhoek.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mhoek.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
tostring vl_test_result, replace
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mhoek.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta"
		

	
*------------*
* North

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - north.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.	
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.	
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=.
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho north.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - north.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.	
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.	
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=.
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho north.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - north.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho north.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - north.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=.  |  ///
	test_1824m_test_done_date_min!=. 
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho north.dta", replace

* No infants missing ART in this district

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Lesotho clients missing outcomes - 2yr - north.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | vl_test_result!=""
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""  
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho north.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho north.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho north.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
tostring vl_test_result, replace
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho north.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - lesotho north.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - lesotho north.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - lesotho north.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - lesotho north.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - lesotho north.dta"



*-------------------------------*
* Merge all districts together

use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mafeteng.dta", clear
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho maseru.dta"
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mhoek.dta"
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho north.dta"
drop _merge
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho maseru.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho north.dta"




*------------------------------------------------------------------------------*
* Malawi

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Malawi clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. 
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - malawi.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Malawi clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - malawi.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Malawi clients missing outcomes - 2yr.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - malawi.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Malawi clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - malawi.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Malawi clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - malawi.dta", replace


* --> Merge
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - malawi.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - malawi.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - malawi.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - malawi.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - malawi.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - malawi.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - malawi.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - malawi.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - malawi.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - malawi.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - malawi.dta"


	

*------------------------------------------------------------------------------*
* SA

*-----------*
* GP

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestdate=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - gp.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestresultt=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - gp.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_finaltestdate=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - gp.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_finaltestresult=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - gp.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing ART") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_infantart=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - gp.dta", replace


import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - gp.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_vltests=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - gp.dta", replace


* --> Merge
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - gp.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - gp.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - gp.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - gp.dta"




*-------------------------*
* WC - Site B

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - site b.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=. 
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. 
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - site b.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - site b.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
destring test_68wk_result, replace
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - site b.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - site b.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=. 
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - site b.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - site b.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
gen vl_test_datex=date(vl_test_date, "DMY")
drop vl_test_date
ren vl_test_datex vl_test_date
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | ///
	vl_test_result!=""
format %d vl_test_date
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - site b.dta", replace


* --> Merge
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - site b.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - site b.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - site b.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - site b.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - site b.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - site b.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - site b.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - site b.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - site b.dta"




*-------------------------*
* Michael M and Town 2

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - SA clients missing outcomes - 2yr - michael m and town 2.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=. 
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - michael m and town 2.dta", replace
	// The only thing updated is the final test date.
	
	
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - michael m and town 2.dta", replace
	// Just doing this to have consistent naming


* --> Merge districts together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - gp.dta"
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - site b.dta", update
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - michael m and town 2.dta", update
drop _merge

save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - sa.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - gp.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - site b.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - michael m and town 2.dta"




*------------------------------------------------------------------------------*
* Uganda

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
keep if test_68wk_test_done_date_min!=.
format %d test_68wk_test_done_date_min
keep country facility caseid test_68wk_test_done_date_min
gen updated_firstestdate=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
keep if test_68wk_result!=.
keep country facility caseid test_68wk_result
gen updated_firstestresult=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
gen country="uganda"
keep if test_68wk_result!=.
keep country facility caseid test_68wk_result
gen updated_firstestconflict=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
keep if test_1824m_test_done_date_min!=.
format %d test_1824m_test_done_date_min
keep country facility caseid test_1824m_test_done_date_min
gen updated_finaltestdate=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
keep if test_1824m_result!=.
keep country facility caseid test_1824m_result
gen updated_finaltestresult=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing ART") firstrow clear
rename *, lower
drop if caseid==""
keep if infant_art_earliestdone!=.
keep country facility caseid infant_art_earliestdone
gen updated_infantart=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - uganda clients missing outcomes - 2yr.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
keep if vl_test_date!=. | vl_test_result!=""
keep country facility caseid vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - uganda.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - uganda.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - uganda.dta"
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
gen updated_excel=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - uganda.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - uganda.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - uganda.dta"




*------------------------------------------------------------------------------*
* Zambia

*-------------------------------*
* Central region

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestdate=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestresult=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_firstestconflict=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_finaltestdate=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_finaltestresult=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing ART") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_infantart=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - zambia central.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Central.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_vltests=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia central.dta", replace


* --> merge
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia central.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia central.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia central.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia central.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia central.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - zambia central.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia central.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia central.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - infant art - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia central.dta"




*-------------------------------*
* Copperbelt region 

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_test_done_date_min!=.
format %d test_68wk_test_done_date_min
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* *68wk*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia copperbelt.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1
keep country facility caseid updated* *68*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia copperbelt.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_68wk_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestresult=1
keep country facility caseid updated* *68*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia copperbelt.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if test_1824m_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m_test_done_date_min
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia copperbelt.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=. /* |  ///
	test_1824m_test_done_date_min!=. */
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if /* test_1824m_test_done_date_min!=. | */ ///
	test_1824m_result!=.
*gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia copperbelt.dta", replace

import excel ///
	"$output/Clients missing key outcomes/2 year cohort/APR2021 - Zambia clients missing outcomes - 2yr - Copperbelt.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | vl_test_result!="" 
replace vl_test_result="LDL" if vl_test_result=="TND"
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""  
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia copperbelt.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia copperbelt.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia copperbelt.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia copperbelt.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia copperbelt.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia copperbelt.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia copperbelt.dta"
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia copperbelt.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test date - zambia copperbelt.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test result - zambia copperbelt.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - first test conflict - zambia copperbelt.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test date - zambia copperbelt.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - final test result - zambia copperbelt.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - vl tests - zambia copperbelt.dta"

use "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia central.dta", clear
merge 1:1 id using "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia copperbelt.dta"
drop _merge
save "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia.dta", replace
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia central.dta"
erase "$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia copperbelt.dta"




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Bring this data into the main dataset
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$data/cohort_all_2yr.dta", clear

/*
* Checks to see if numbers change
tab1 test_1824m_done if country=="malawi" & pn_any==1 & visits_pn>=2 ///
	& infant_tooyoung==0, m
tab1 has_test68wk_result has_test1824m_result if country=="uganda", m
tab ever_pos if country=="uganda", m
tab has_infant_status if country=="uganda", m
tab infant_status_postenrol if pn_any==1 & visits_pn>=2 & ///
	infant_tooyoung!=1 & when_testpos>=3 & country=="uganda", m
count if mostrecent_vltest_done!=. & country=="uganda"
*/	
	
	

*------------------------------------------------------------------------------*
* Merge in excel data

* --> Kenya
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - kenya.dta", update


* --> Lesotho
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - lesotho.dta", update


* --> Malawi
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - malawi.dta", update


* --> SA
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - sa.dta", update

	
* --> Uganda
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - uganda.dta", update
		
		
* --> Zambia
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/2 year cohort/client missing outcomes - all - zambia.dta", update
	

	
*------------------------------------------------------------------------------*
* Update analysis variables with info just brought in

* --> Test done date
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	label var test_`x'_test_done_date_min "Earliest `x' test done date"
	format %d test_`x'_*_done_date_min
}
replace test_12m_test_done_date_min=infant_dob+365 if ///
	id=="c6016f32-4513-4f29-801c-cbb563545dd4"


* --> Test done
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	replace test_`x'_done=1 if ///
		(test_`x'_result!=. | test_`x'_test_done_date_min!=.)
}
tab1 test_68wk_done test_1824m_done if country=="uganda", m
	// Just checking that number of infants marked as done has changed.


* --> Manual fix for a client in Lesotho who tested pos at 1 year
replace test_12m_result=1 if ///
	id=="c6016f32-4513-4f29-801c-cbb563545dd4"
replace test_12m_done=1 if ///
	id=="c6016f32-4513-4f29-801c-cbb563545dd4"

	
* --> Manual fix for infant that is actually negative
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	replace test_`x'_result=0 if ///
		id=="69b1752f-f573-42b3-b751-b4b2e52ddf8b" | ///
		id=="6b40a6e2-e1f7-42d0-b7b5-9cc4ecbbfafb"
}


* --> Has test result
foreach x in 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	replace has_test`x'_result=1 if test_`x'_result!=.
	label var has_test`x'_result "Has `x' test result"
}
tab1 has_test68wk_result has_test1824m_result if country=="uganda", m


* --> Ever tested positive
cap drop ever_pos
egen ever_pos=rowmax(test_*_result)
label var ever_pos "Infant ever tested positive"
tab ever_pos
	

* --> Test date of the test where a positive result was obtained 
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	cap drop test_`x'_test_done_date_minx
	gen test_`x'_test_done_date_minx= ///
		test_`x'_test_done_date_min if test_`x'_result==1
}  
	

* --> Earliest positive test date
cap drop earliest_pos_test
egen earliest_pos_test=rowmin(test_*_test_done_date_minx)
format %d earliest_pos_test
label var earliest_pos_test "Earliest test date which was positive"


* --> Identify when they tested positive in relation to enrolment
cap drop when_testpos
gen when_testpos=1 if earliest_pos_test<first_timeend_date
replace when_testpos=2 if earliest_pos_test==first_timeend_date 
replace when_testpos=3 if earliest_pos_test>first_timeend_date & ///
	earliest_pos_test<.	
label val when_testpos when_testpos_lab


* --> Infant final status
cap drop infant_status
gen infant_status=test_1824m_result 
replace infant_status=1 if ever_pos==1
replace infant_status=2 if infant_status==. & pn_any==1
label val infant_status status
label var infant_status "Final infant status"
	

* --> Infant has a final status
replace has_infant_status=1 if infant_status<=1 
tab has_infant_status if country=="uganda", m
	
	
* --> Final status excluding those testing positive before or at enrolment
cap drop infant_status_postenrol
gen infant_status_postenrol=infant_status
replace infant_status_postenrol=. if when_testpos<3
label var infant_status_postenrol "Infant status excl those pos before/at enrol"
label val infant_status_postenrol status
tab infant_status_postenrol if pn_any==1 & visits_pn>=2 & ///
	infant_tooyoung!=1 & when_testpos>=3, m
tab infant_status_postenrol if pn_any==1 & visits_pn>=2 & ///
	infant_tooyoung!=1 & when_testpos>=3 & country=="uganda", m


* --> Infant ART
replace infant_artstart=1 if infant_art_earliestdone!=. & infant_status==1


* --> Make VL test result numeric
tab vl_test_result, m
replace vl_test_result="0" if ///
	vl_test_result=="LDL" | ///
	vl_test_result=="ND" | ///
	vl_test_result=="<20" | ///
	vl_test_result=="< 20" 
destring vl_test_result, replace
tab vl_test_result, m


* --> Fill in various VL result variables
tab1 mostrecent_vlresult mostrecent_vlresult_nomiss mostrecent_vlresult2, m
replace mostrecent_vlresult=1 if vl_test_result==0
replace mostrecent_vlresult=2 if vl_test_result>0 & vl_test_result<1000
replace mostrecent_vlresult=3 if vl_test_result>=1000 & vl_test_result<.

replace mostrecent_vlresult_nomiss=mostrecent_vlresult if ///
	mostrecent_vlresult!=.

replace mostrecent_vlresult2=1 if mostrecent_vlresult==1
replace mostrecent_vlresult2=2 if vl_test_result>0 & ///
	vl_test_result<200
replace mostrecent_vlresult2=3 if vl_test_result>=200 & ///
	vl_test_result<.

	
	
	
*------------------------------------------------------------------------------*
* Clients to fix/drop manually

* --> Lesotho
drop if ///
	id=="e5fa24c8-c65b-400f-bcfb-3f7f6e782dc7" | ///
	id=="3684d2f8-6909-4959-823c-b3a22831a6bc" | ///
	id=="a92995ab-baf8-407a-bec9-4cb3dfd769f6"
	// Marked as negative 
	

* --> Uganda
drop if id=="8db5950b-939c-4db5-b9ff-03af06ee0915"
	// Marked as negative 
	
	
	

	
*------------------------------------------------------------------------------*
* Save final data for 2 year cohort

save "$data/cohort_all_2yr_final.dta", replace

preserve
keep if an_any==1
save "$data/cohort_an_any_2yr_final.dta", replace
restore

preserve 
keep if pn_any==1
save "$data/cohort_pn_any_2yr_final.dta", replace
restore

preserve 
keep if an_pn==1
save "$data/cohort_an_pn_2yr_final.dta", replace
restore


