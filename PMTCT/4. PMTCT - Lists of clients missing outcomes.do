*** APR 2020 - PMTCT cascade
*** Lists of clients missing key outcomes
* 3 March 2021

/*
This do file produces lists of clients missing key outcomes. I have restricted
it to clients with 2+ PN visits for the infant-related outcomes, and used
all clients for VL testing. The restriction to 2+ visits is because that is
the sample of clients who we report on.  
*/



foreach k in 1 2 3 {

clear all
set maxvar 32700
use "$data/cohort_all_`k'yr.dta", replace
count
replace country="sa" if country=="south africa"
	// For loops below to work


	
	
*------------------------------------------------------------------------------*
* Change some labels for the output

label var id "Case ID"
label var test_68wk_test_done_date_min "First test done date"
label var test_68wk_result "First test result"
label var test_1824m_test_done_date_min "Final test done date"
label var test_1824m_result "Final test result"
gen vl_test_date=""
label var vl_test_date "Most recent VL test date"
gen vl_test_result=""
label var vl_test_result "Most recent VL test result"
	

	

*------------------------------------------------------------------------------*
* First test done and result

tab test_68wk_done if pn_any==1 & visits_pn>=2
tab has_test68wk_result if pn_any==1 & visits_pn>=2

* --> Missing first test date
preserve
keep if pn_any==1
keep if visits_pn>=2
keep if test_68wk_done!=1
keeporder country facility details_first_name details_surname ///
	first_timeend_date infant_dob id ///
	details_phone_number details_physical_address
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Missing first test date") replace
}
restore


* --> Missing first test result
preserve
keep if pn_any==1
keep if visits_pn>=2
keep if has_test68wk_result!=1
keeporder country facility *first_name *surname first_timeend_date ///
	infant_dob test_68wk_test_done_date_min id ///
	details_phone_number details_physical_address 
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Missing first test result") sheetmodify
}
restore


* --> Has conflicting first test results
preserve
keep if pn_any==1
keep if visits_pn>=2
keep if test_68wk_result_min!=test_68wk_result_max
keeporder country facility *first_name *surname first_timeend_date ///
	infant_dob test_68wk_test_done_date_min id ///
	details_phone_number details_physical_address 
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Conficting first test results") sheetmodify
}
restore





*------------------------------------------------------------------------------*
* Final test done and result
/*
Final test done is those without a status who also don't have a final test
done date. Final test result is simply those without a status. In other words,
the difference is the small number of infants who got the test done but the
result was never captured.
*/

preserve
keep if pn_any==1
keep if visits_pn>=2
drop if infant_tooyoung==1
count if has_infant_status==1 & test_1824m_test_done_date_min==.
	// 54 infants have a status because a previous test was positive
	
count if has_infant_status!=1 & test_1824m_test_done_date_min==. 
	// 1437 infants weren't positive before final test and don't have a 
	// final test done date

tab country has_infant_status, row

restore

	
* --> Final test done
preserve
keep if pn_any==1
keep if visits_pn>=2
drop if infant_tooyoung==1
keep if has_infant_status!=1 & test_1824m_test_done_date_min==.
keeporder country facility *first_name *surname first_timeend_date ///
	infant_dob id details_phone_number details_physical_address 
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Missing final test date") sheetmodify
}
restore


* --> Final test result
preserve
keep if pn_any==1
keep if visits_pn>=2
drop if infant_tooyoung==1
keep if has_infant_status!=1
keeporder country facility *first_name *surname  first_timeend_date ///
	infant_dob test_1824m_test_done_date_min ///
	id details_phone_number details_physical_address  
sort country facility *first_name *surname  
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Missing final test result") sheetmodify
}
restore


* --> Has conflicting final test results
preserve
keep if pn_any==1
keep if visits_pn>=2
keep if test_1824m_result_min!=test_1824m_result_max
keeporder country facility *first_name *surname first_timeend_date ///
	infant_dob test_1824m_test_done_date_min id ///
	details_phone_number details_physical_address 
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) ///
		sheet("Conficting final test results") sheetmodify
}
restore




*------------------------------------------------------------------------------*
* Infant on ART

preserve
keep if infant_status==1
keep if infant_artstart==0
replace infant_artstart=.
keeporder country facility *first_name *surname first_timeend_date ///
	infant_dob infant_status id ///
	details_phone_number details_physical_address  
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) sheet("Missing ART")  ///
		sheetmodify
}
restore




*------------------------------------------------------------------------------*
* No VL tests at all

preserve
keep if mostrecent_vlresult_nomiss==4
keeporder country facility *first_name *surname first_timeend_date ///
	id ///
	details_phone_number details_physical_address  
sort country facility *first_name *surname 
foreach x in kenya lesotho malawi sa uganda zambia {
	cap export excel using ///
		"$output/Clients missing key outcomes/`k' year cohort/`x' clients missing key outcomes - `k'yr cohort ($S_DATE).xlsx" ///
		if country=="`x'", firstrow(varlabels) sheet("Missing VL tests")  ///
		sheetmodify
}
restore


}
