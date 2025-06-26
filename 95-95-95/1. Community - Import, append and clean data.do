*** APR 2020 - Community analysis - 95 95 95
*** Import, append and clean data
* 24 April 2021


* --> Import and append
do "$do/1.1 Community - Import and append - Firdale App2.do"
do "$do/1.1 Community - Import and append - New version App2.do"

	
* --> Clean the data
foreach form in reg_index reg_hhmem caregiver infant partner childadol {
	do "$do/1.2 Community - Clean - Firdale App2 - `form'.do"
	do "$do/1.2 Community - Clean - New version App2 - `form'.do"
}


* --> Append all years for each form
foreach form in reg_index reg_hhmem caregiver infant partner childadol {
	use "$temp/Firdale/`form'_clean_2019.dta", clear
	append using "$temp/Firdale/`form'_clean_2020.dta"      ///
		"$temp/New version/`form'_clean_2020.dta"  ///
		"$temp/New version/`form'_clean_2021.dta"  
	save "$temp/`form'.dta", replace
	
	erase "$temp/Firdale/`form'_clean_2019.dta"
	erase "$temp/Firdale/`form'_clean_2020.dta"
	erase "$temp/New version/`form'_clean_2020.dta"
	erase "$temp/New version/`form'_clean_2021.dta"
	
}

