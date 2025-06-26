*** APR 2019 - ECD
*** Identify eligible facilities
* 12 June 2020

/*
Working out which facilities were eligible was done in the similarly named
do file for the community 95-95-95 analysis. This do file just creates the
list of the facilities agreed on with Fiona on 12 June 2020.
*/



*------------------------------------------------------------------------------*
* Merge reg index and caregiver

use "$temp_appdata/Firdale/reg_index.dta", clear
count if dreg_index_facility==""
count if dreg_index_country==""
gen dreg_index_timeend_year=yofd(dreg_index_timeend_date)
tab dreg_index_timeend_year if dreg_index_facility==""
	// Most of those missing facility or country are in 2017, followed by 2018.
	
tab dreg_index_timeend_year, m


* --> Merge with caregiver to see if I can fill in some country and facility
merge 1:m id using "$temp_appdata/Firdale/caregiver.dta"
drop if _merge==2
	// Drop those only in the caregiver dataset

	
* --> Fill in missing country and facility
foreach i in country province facility {
	gen `i'=dreg_index_`i'
	replace `i'=dcaregiver_`i' if `i'=="" 
	count if _merge!=2 & `i'==""
}


* --> Keep relevant facilities
keep if province=="Nairobi" | province=="Mulanje"
egen site_tag=tag(facility)
keep if site_tag==1


* --> Save facility dataset
sort country facility
keeporder country facility 
save "$ecd/Input/ecd_sample.dta", replace
