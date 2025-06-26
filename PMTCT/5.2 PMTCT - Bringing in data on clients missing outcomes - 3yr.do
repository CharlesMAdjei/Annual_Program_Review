*** APR 2021 - PMTCT cascade
*** Data of clients missing key outcomes - 3 year cohort
* 16 April 2021



*------------------------------------------------------------------------------*
* Lesotho

*------------*
* Mafeteng

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Mafeteng.xlsx", ///
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
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mafeteng.xlsx", ///
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
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta", replace


import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Mafeteng.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mafeteng.xlsx", ///
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
format %d test_1824m_test_done_date_min
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mafeteng.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mafeteng.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mafeteng.dta"



*------------*
* Maseru

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
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
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
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
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
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
gen updated_firstestconflict=1
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta", replace

	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
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
gen updated_excel=1 if ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
gen test_1824m_test_done_date_minx=date(test_1824m_test_done_date_min, "DMY")
replace test_1824m_test_done_date_minx= ///
	date(test_1824m_test_done_date_min,"MDY") if ///
	test_1824m_test_done_date_minx==. 
drop test_1824m_test_done_date_min
ren test_1824m_test_done_date_minx test_1824m_test_done_date_min
format %d test_1824m_test_done_date_min
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_result!=. | ///
	test_1824m_test_done_date_min!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho maseru.dta", replace	

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
	sheet("Conficting final test results") firstrow clear
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
gen updated_finaltestconflict=1
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test conflict - lesotho maseru.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - Maseru.xlsx", ///
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
replace updated_app=. if updated_excel==1
keep country facility caseid updated* ///
	vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho maseru.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho maseru.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test conflict - lesotho maseru.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho maseru.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho maseru.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test conflict - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho maseru.dta"



*------------*
* Mhoek

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mhoek.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mhoek.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mhoek.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
gen test_1824m_test_done_date_minx=date(test_1824m_test_done_date_min, "DMY")
replace test_1824m_test_done_date_minx= ///
	date(test_1824m_test_done_date_min,"MDY") if ///
	test_1824m_test_done_date_minx==. 
drop test_1824m_test_done_date_min
ren test_1824m_test_done_date_minx test_1824m_test_done_date_min
format %d test_1824m_test_done_date_min
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mhoek.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mhoek.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mhoek.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - mhoek.xlsx", ///
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
replace updated_app=. if updated_excel==1
keep country facility caseid updated* ///
	vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mhoek.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mhoek.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mhoek.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mhoek.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mhoek.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho mhoek.dta"



*------------*
* North

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - north.xlsx", ///
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
gen updated_excel=1 if ///
	test_68wk_test_done_date_min!=. | ///
	test_68wk_result!=.
replace updated_app=. if updated_excel==1
gen updated_firstestdate=1 if test_68wk_test_done_date_min!=.
gen updated_firstestresult=1 if test_68wk_result!=. 
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho north.dta", replace


import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - north.xlsx", ///
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
gen updated_firstestconflict=1
keep country facility caseid updated* ///
	test_68wk*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho north.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - north.xlsx", ///
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
gen updated_excel=1 if ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestdate=1 if test_1824m_test_done_date_min!=.
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho north.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - north.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
gen test_1824m_test_done_date_minx=date(test_1824m_test_done_date_min, "DMY")
replace test_1824m_test_done_date_minx= ///
	date(test_1824m_test_done_date_min,"MDY") if ///
	test_1824m_test_done_date_minx==. 
drop test_1824m_test_done_date_min
ren test_1824m_test_done_date_minx test_1824m_test_done_date_min
format %d test_1824m_test_done_date_min
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if ///
	test_1824m_result!=.
replace updated_app=. if updated_excel==1
gen updated_finaltestresult=1 if test_1824m_result!=.
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho north.dta", replace

* Skipping over infant ART because apparently all are actually negative so I 
* manually fix them at the bottom of this do file

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - Lesotho clients missing outcomes - 3yr - north.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
gen x=date(vl_test_date, "DMY")
replace x=date(vl_test_date, "MDY") if x==.
drop vl_test_date
ren x vl_test_date
format %d vl_test_date
keep if ///
	strpos(informationupdatedintheapp,"yes")  | ///
	vl_test_date!=. | vl_test_result!=""
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""
replace updated_app=. if updated_excel==1
keep country facility caseid updated* ///
	vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho north.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho north.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - lesotho north.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho north.dta", update
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho north.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - lesotho north.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - lesotho north.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - lesotho north.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - lesotho north.dta"



*------------------------------------*
* --> Merge all districts together

use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mafeteng.dta", clear
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho maseru.dta"
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mhoek.dta"
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho north.dta"
drop _merge
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mafeteng.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho maseru.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho mhoek.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho north.dta"




*------------------------------------------------------------------------------*
* SA

*------------*
* GP

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
gen updated_firstestconflict=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
gen updated_firstestresult=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* 
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
foreach var of varlist informationupdatedintheapp {
	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}
format %d test_1824m_test_done_date_min
keep if ///
	strpos(informationupdatedintheapp,"yes") | ///
	test_1824m_test_done_date_min!=. | ///
	test_1824m_result!=.

	gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_finaltestresult=1 if strpos(informationupdatedintheapp,"yes")
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - infant art - sa gp.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - gp.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - sa gp.dta", replace


* --> Merge
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - sa gp.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - sa gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - sa gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - sa gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - sa gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - infant art - sa gp.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - sa gp.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - sa gp.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - infant art - sa gp.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - sa gp.dta"




*-------------------------*
* WC - Michael M

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - Michael M.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - michael m.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - michael m.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - michael m.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - Michael M.xlsx", ///
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
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - michael m.dta", replace
	// Don't need to do missing final test result as this one has both

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - Michael M.xlsx", ///
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
	vl_test_date!=. 
drop vl_test_result
	// VL result wasnt recorded for anyone and there's no time to get them
	// to go back and find the results
	
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. 
keep country facility caseid updated* ///
	vl_test_date 
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - michael m.dta", replace


* --> Merge
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - michael m.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - michael m.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - michael m.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - michael m.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - michael m.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - michael m.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - michael m.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - michael m.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - michael m.dta"



*-------------------------*
* WC - Site B

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - site b.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - site b.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - site b.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - site b.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - site b.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - site b.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - site b.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - site b.dta", replace
	
	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - site b.xlsx", ///
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
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - site b.dta", replace


* --> Merge
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - site b.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - site b.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - site b.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - site b.dta", update
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - site b.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - site b.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - site b.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - site b.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - site b.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - site b.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - site b.dta"



*-------------------------*
* WC - Town 2

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - town 2.xlsx", ///
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
gen updated_finaltestdate=1
keep country facility caseid updated* ///
	test_1824m*
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - town 2.dta", replace
	
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - SA clients missing outcomes - 3yr - town 2.xlsx", ///
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
	vl_test_date!=. | ///
	vl_test_result!=""
format %d vl_test_date
gen updated_app=1 if strpos(informationupdatedintheapp,"yes")
gen updated_excel=1 if vl_test_date!=. | vl_test_result!=""
keep country facility caseid updated* ///
	vl_test_date vl_test_result
replace updated_app=. if updated_excel==1
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - town 2.dta", replace


* --> Merge
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - town 2.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - town 2.dta", update
drop _merge

isid caseid
ren caseid id
sort facility
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - town 2.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - town 2.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - town 2.dta"



*------------------------------------*
* Merge all districts together

use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - michael m.dta", clear
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - site b.dta", update
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - town 2.dta", update
drop _merge
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - sa.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - michael m.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - site b.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - town 2.dta"




*------------------------------------------------------------------------------*
* Uganda

* --> Import and save each tab
import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Missing first test date") firstrow clear
rename *, lower
drop if caseid==""
keep if test_68wk_test_done_date_min!=.
format %d test_68wk_test_done_date_min
keep country facility caseid test_68wk_test_done_date_min
gen updated_firstestdate=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Missing first test result") firstrow clear
rename *, lower
drop if caseid==""
keep if test_68wk_result!=.
keep country facility caseid test_68wk_result
gen updated_firstestresult=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Conficting first test results") firstrow clear
rename *, lower
drop if caseid==""
keep if test_68wk_result!=.
keep country facility caseid test_68wk_result
gen updated_firstestconflict=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Missing final test date") firstrow clear
rename *, lower
drop if caseid==""
keep if test_1824m_test_done_date_min!=.
format %d test_1824m_test_done_date_min
keep country facility caseid test_1824m_test_done_date_min
gen updated_finaltestdate=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Missing final test result") firstrow clear
rename *, lower
drop if caseid==""
keep if test_1824m_result!=.
keep country facility caseid test_1824m_result
gen updated_finaltestresult=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - uganda.dta", replace

import excel ///
	"$output/Clients missing key outcomes/3 year cohort/APR2021 - uganda clients missing outcomes - 3yr.xlsx", ///
	sheet("Missing VL tests") firstrow clear
rename *, lower
drop if caseid==""
keep if vl_test_date!=. | vl_test_result!=""
keep country facility caseid vl_test_date vl_test_result
gen updated_vltests=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - uganda.dta", replace


* --> Merge together
use "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - uganda.dta", clear
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - uganda.dta"
drop _merge
merge 1:1 caseid using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - uganda.dta"
drop _merge


* --> Save 
isid caseid
ren caseid id
sort facility
gen updated_excel=1
save "$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - uganda.dta", replace
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test date - uganda.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test result - uganda.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - first test conflict - uganda.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test date - uganda.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - final test result - uganda.dta"
erase "$temp/Missing client outcomes/3 year cohort/client missing outcomes - vl tests - uganda.dta"




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Bring this data into the main dataset
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$data/cohort_all_3yr.dta", clear

/*
* Checks to compare data to lower down when I bring in stuff above
bysort country: tab test_68wk_done, m
bysort country: tab test_1824m_done, m

tab1 has_test68wk_result has_test1824m_result if country=="uganda", m
tab ever_pos if country=="uganda", m
tab has_infant_status if country=="uganda", m
tab infant_status_postenrol if pn_any==1 & visits_pn>=2 & ///
	infant_tooyoung!=1 & when_testpos>=3 & country=="uganda", m
count if mostrecent_vltest_done!=. & country=="uganda"
*/	
	
	

*------------------------------------------------------------------------------*
* Merge in excel data

* --> Lesotho
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - lesotho.dta", update


* --> SA
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - sa.dta", update


* --> Uganda
drop _merge
merge 1:1 id using ///
	"$temp/Missing client outcomes/3 year cohort/client missing outcomes - all - uganda.dta", update
		
		
	

*------------------------------------------------------------------------------*
* Update analysis variables with info just brought in

* --> Test done date
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	label var test_`x'_test_done_date_min "Earliest `x' test done date"
	format %d test_`x'_*_done_date_min
}


* --> Test done
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	replace test_`x'_done=1 if ///
		(test_`x'_result!=. | test_`x'_test_done_date_min!=.)
}
bysort country: tab test_1824m_done, m
	// Just checking that number of infants marked as done has changed.
	

* --> Manual fix for infant that tested pos at 9m
foreach x in 9m 10m 12m 13m 1824m {
	replace test_`x'_result=1 if id=="0232a2c5-6aa9-4dde-b2e3-d788208bfc03"
}


* --> Manual fix for infant that tested pos at 14 weeks
foreach x in 14wk 1824m {
	replace test_`x'_result=1 if id=="4cde76f2-011d-47c3-bdf1-c1967ecf9dbc"
}


* --> Manual fix for infants that tested pos at an unknown age - setting it
*	  to 18-24m
foreach x in 1824m {
	replace test_`x'_result=1 if inlist(id, ///
		"ae821c21-5d9f-4b22-99f3-feb77923c53c", ///
		"4cde76f2-011d-47c3-bdf1-c1967ecf9dbc", ///
		"64c2b3d5-8c81-4790-b181-2ac50c535419", ///
		"4ceedad6-a7ee-4269-8f79-7403ce038c16")
}
	

* --> Manual fix for infants that are actually negative
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	replace test_`x'_result=0 if inlist(id, ///
		"95bd4053-0ad2-42c9-84a7-4db67f7238c1", ///
		"7eb8cb7b-cd5f-4989-bc58-d95458819e7c", ///
		"448bd8d5-54ee-4940-a5f8-a422132fa939", ///
		"fbe888ba-2ac5-4984-adc1-9129556d1ad3", ///
		"755e2266-42fb-4494-bdda-0b69437652ea")

	replace test_`x'_result=0 if inlist(id, ///
		"1f81e388-b0f7-403a-a3db-3f354021a98c", ///
		"8c9893a7-7b0a-4f58-b237-a2b0c7400ab2", ///
		"5894875b-fbee-40c9-8abf-05a64345bda0", ///
		"1594e6d7-ca94-4e77-9dbd-51176e43ff54")
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
tab ever_pos if country=="uganda"
	

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
replace infant_artstart=1 if inlist(id, ///
	"ae821c21-5d9f-4b22-99f3-feb77923c53c", ///
	"4cde76f2-011d-47c3-bdf1-c1967ecf9dbc", ///
	"64c2b3d5-8c81-4790-b181-2ac50c535419", ///
	"4ceedad6-a7ee-4269-8f79-7403ce038c16")
	// Manual fix for clients in Lesotho
	
	
* --> Make VL test result numeric
tab vl_test_result, m
replace vl_test_result="0" if ///
	vl_test_result=="LDL" | ///
	vl_test_result=="ND" | ///
	vl_test_result=="< 20" | ///
	vl_test_result=="<20"
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
	id=="acadb9a0-18cc-4792-951a-6ea0619147c1" | ///
	id=="2f4a18c0-a794-4167-9197-e89a042b3d94" | ///
	id=="85946f68-5f89-43fd-8ec1-204f8ee8c710"
	// Marked as negative in responses
	

* --> Uganda
drop if ///
	id=="50400687-284f-4158-afc5-c9806c805f63" | ///
	id=="afccec37-965e-48dc-80f6-67b75d3cc84c" 
	// These clients in Uganda were marked as negative in the Uganda responses
	
tab1 test_68wk_result ever_pos when_testpos infant_status ///
	infant_status_postenrol has_infant_status if ///
	id=="7627b7c4-1dea-4636-8869-6bf7decc9ea6"
	// Make sure that this infant is negative on final status and associated 
	// variables.
	


	
*------------------------------------------------------------------------------*
* Save final data for 3 year cohort

save "$data/cohort_all_3yr_final.dta", replace

preserve
keep if an_any==1
save "$data/cohort_an_any_3yr_final.dta", replace
restore

preserve 
keep if pn_any==1
save "$data/cohort_pn_any_3yr_final.dta", replace
restore

preserve 
keep if an_pn==1
save "$data/cohort_an_pn_3yr_final.dta", replace
restore


