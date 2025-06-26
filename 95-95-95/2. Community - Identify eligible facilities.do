*** APR 2020 - Community analysis - 95 95 95
*** Identify sample
* 24 April 2021


*------------------------------------------------------------------------------*
* Reg index

use "$temp/reg_index.dta", clear
duplicates drop
isid id

count
count if dreg_index_facility==""
count if dreg_index_country==""
gen dreg_index_timeend_year=yofd(dreg_index_timeend_date)
tab dreg_index_timeend_year, m
tab dreg_index_timeend_year if dreg_index_facility==""
	// Majority of blank cases in reg index dataset are in 2017 (62%)

	
* --> Merge with caregiver to see if I can fill in some country and facility
merge 1:m id using "$temp/caregiver.dta"
*drop if _merge==2
	// Drop those only in the caregiver dataset, presumably registered 
	// before 2019.

	
* --> Fill in missing country and facility
foreach i in country facility {
	gen `i'=dreg_index_`i'
	replace `i'=dcaregiver_`i' if `i'=="" 
	count if _merge!=2 & `i'==""
}
/*
egen tag=tag(id)
tab country if tag==1, m
tab facility if tag==1, m
	// Still a lot of observations missing facility and country. Not sure
	// why.
*/


* --> Remove countries we know aren't eligible at all
drop if inlist(country, "Swaziland", "Test Country", "")
	

* --> Make numeric person identifier
egen idx=group(id)
sort idx dcaregiver_timeend_date
bysort idx: gen form_num=cond(_N==1,1,_n)




*------------------------------------------------------------------------------*
* Identify earliest and latest form submission date by facility
	
* --> Identify month of each caregiver form completion date
gen form=mofd(dcaregiver_timeend_date)
replace form=mofd(dreg_index_timeend_date) if form==.
	// In cases where the client doesn't appear in the caregiver form, the
	// form submission date of their reg index form is used.
	
format %tm form
tab form


* --> Earliest and latest completed date for each site
egen form_min=min(form), by(facility)
egen form_max=max(form), by(facility)
format %tm form_m??
label var form_min "Earliest form submission month"
label var form_max "Latest form submission month"


* --> Tag each site, and each unique site-form month date
egen site_tag=tag(facility)
egen site_m=tag(facility form)
tab form_min if site_tag==1
tab form_max if site_tag==1
/*
sort facility form
br facility form_min form if site_m==1
*/
	

* --> Number of months that have at least 1 form submission
egen num_months=sum(site_m), by(facility)
tab num_months if site_tag==1

/*
sort country facility form
br country facility num_months form_min form_max  ///
	if site_tag==1
br country facility num_months form ///
	if site_m==1 & country=="Lesotho" 
br form_m if site_m==1 & facility=="St Rose HC"
br form_m if site_m==1 & facility=="Berea Hospital"
*/


* --> Create new variable to identify each month a site has a form
*	  submission (takes a while).
forvalues i=1/12 {
	forvalues y=2019/2021 {
		gen m_`y'm`i'_x=1 if form==tm(`y'm`i')
		
		egen m_`y'm`i'=total(m_`y'm`i'_x), by(facility)
		replace m_`y'm`i'=. if m_`y'm`i'==0
		
		drop m_`y'm`i'_x
		label var  m_`y'm`i' "`y'm`i'"
	}
}
	// This creates a variable for each month that is equal to the count of
	// caregiver forms submitted per site. For sites that had 0 forms
	// submitted, the value is missing.
	
	


*------------------------------------------------------------------------------*
* Exports to check site eligibility

* --> Visualisation of which months each facility has data in
*br country facility form_m?? m_2019* m_2020* m_2021* if site_tag==1


* --> Ghana
preserve
keep if site_tag==1
keep if country=="Ghana"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Ghana) replace
restore


* --> Kenya
preserve
keep if site_tag==1
keep if country=="Kenya"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Kenya) sheetmodify
restore


* --> Lesotho
preserve
keep if site_tag==1
keep if country=="Lesotho"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Lesotho) sheetmodify
restore


* --> Malawi
preserve
keep if site_tag==1
keep if country=="Malawi"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Malawi) sheetmodify
restore


* --> SA
preserve
keep if site_tag==1
keep if country=="South Africa"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(SA) sheetmodify
restore


* --> Uganda
preserve
keep if site_tag==1
keep if country=="Uganda"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Uganda) sheetmodify
restore


* --> Zambia
preserve
keep if site_tag==1
keep if country=="Zambia"
keeporder country facility form_min form_max m_2019* m_2020* m_2021* 
sort m_2019m* m_2020m* m_2021*
export excel using ///
	"$ninety_five/Output/Checks/Form submissions by month ($S_DATE).xlsx", ///
	firstrow(variables) sheet(Zambia) sheetmodify
restore




*------------------------------------------------------------------------------*
* Final eligibility 

sort country facility
cap drop site_tag
egen site_tag=tag(facility)
tab site_tag


* --> Number of months per site that have form submissions by year
foreach i in 2019 2020 2021 {
	cap drop num_months_`i'
	egen num_months_`i'=rownonmiss(m_`i'm*)
	label var num_months_`i' "# months in `i' with 1 or more form submissions"
}


* --> Identify sites with 11 or 12 months of data in all of 2019, 2020, 2021  
cap drop keep_3y
gen keep_3y = ///
	(num_months_2019>=11 & num_months_2019<=12) & ///
	(num_months_2020>=11 & num_months_2020<=12) & ///
	(num_months_2021>=11 & num_months_2021<=12) 
tab country if keep_3y==1 & site_tag==1
	// No country has any sites with sufficient data to be included in a 3
	// year cohort.
	

* --> Identify sites with 11 or 12 months of data in  2020 and 2021 and use 
*     in 2 year analysis
cap drop keep_1y
gen keep_2y= ///
	(num_months_2020>=9 & num_months_2020<=12) & ///
	(num_months_2021>=9 & num_months_2021<=12)
tab country if keep_2y==1 & site_tag==1
	// 1 site in Kenya, 4 in Malawi and 9 in Zambia


/* --> Identify sites with 11 or 12 months of data in either 2019 or 2020
foreach year in 2020 2021 {
	gen keep_`year'=(num_months_`year'>=11 & num_months_`year'<=12)
}
*/
* --> Identify sites with 11 or 12 months of data in 0221 - use them in the 1
*     year analysis
gen keep_1y=(num_months_2021>=9 & num_months_2021<=12)
count if keep_1y==1 & site_tag==1
tab country if keep_1y==1 & site_tag==1
	// 1 in Kenya, 55 in Lesotho, 4 in Malawi and 17 in Zambia with data for
	// 2019. These are the sites included in the APR 2019.
	
tab country if keep_1y==1 & site_tag==1
	// 2 in Ghana, 1 in Kenya, 18 in Malawi and 16 in Zambia
	


	
* --> Count of clients per site
cap drop clients
egen tag=tag(id)
egen clients=sum(tag), by(facility)

	
* --> Create eligible site dataset
keep if site_tag==1
keep if keep_1y==1
	// All 2 year sites are also in the 1 year sample (obvs)

keeporder country facility clients keep* num_months_2019 num_months_2020 num_months_2021 
	
sort country facility
save "$ninety_five/Input/community_sample.dta", replace
