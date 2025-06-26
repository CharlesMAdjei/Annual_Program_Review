*** APR 2020 - Primary prevention
*** Master do file 
* 17 June 2021



*------------------------------------------------------------------------------*
* Create multi-country dataset

use "$appdata/Data/Clare & new version/App1/app1 final.dta", clear
drop if completed2<td(01jan2019)
drop if form_type=="acfu" | form_type=="exit"
drop if country=="" | facility==""
drop if strpos(facility, "UAT")
	// UAT = user acceptability training

*do "$do_appdata/Generic/0. Undo renaming to UID.do"
*do "$do_appdata/Generic/0. Rename sites to match DHIS2.do"
	// This is done to make sure weird things like the same site having two
	// different names in the app are fixed.

cap drop site_tag 
egen site_tag=tag(facility)
	


	
*------------------------------------------------------------------------------*
* Identify earliest and latest form submission date by facility
	
* --> Identify month of each new/AN/PN form completion date
gen completed2_m=mofd(completed2) if form_type=="an" | form_type=="pn" | ///
	form_type=="new"
format %tm completed2_m
label var completed2_m "Month of AN/PN/new client form completion date"
replace completed2_m=. if completed2_m<tm(2019m1)
	

* --> Earliest and latest completed date for each site
cap drop completed2_m_m*
egen completed2_m_min=min(completed2_m), by(facility)
egen completed2_m_max=max(completed2_m), by(facility)
format %tm completed2_m_m??
label var completed2_m_min "Earliest form sub. month"
label var completed2_m_max "Latest form sub. month"


* --> Tag each unique site-form month date
cap drop site_m
egen site_month=tag(facility completed2_m) if ///
	completed2_m>=tm(2019m2) & ///
	completed2_m<=tm(2021m12)

	
* --> Count new/AN/PN form submissions each month per facility (takes a while).
forvalues y=2019/2021 {
	forvalues i=1/12 {
		gen m_`y'm`i'_x=1 if completed2_m==tm(`y'm`i')
		egen m_`y'm`i'=total(m_`y'm`i'_x), by(facility)
		replace m_`y'm`i'=. if m_`y'm`i'==0
		drop m_`y'm`i'_x
		label var  m_`y'm`i' "`y' m`i'"
	}
}
	// This creates a variable for each month that is equal to the count of
	// new, AN and PN forms submitted per site. For sites that had 0 forms
	// submitted, the value is missing.

	
* --> Open and using App1 continuously between June-Dec 2021
cap drop eligible
gen eligible=m_2021m9!=. & m_2021m10!=. & m_2021m11!=. & m_2021m12!=.
label var eligible ///
	"Site is eligible for inclusion (continuous app usage Jun-Dec 2021)"
sort country eligible facility
list country facility eligible if site_tag==1


	
	
*------------------------------------------------------------------------------*
* Exports to check site eligibility 

label var country "Country"
label var facility "Facility"
tostring eligible, replace
replace eligible="Yes" if eligible=="1"
replace eligible="No" if eligible=="0"
replace country="SA" if country=="South Africa"

foreach x in Ghana {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder eligible facility ///
		completed2_m_min completed2_m_max ///
		m_2019* m_2020* m_2021* 
	gsort -eligible +facility 
	export excel using ///
		"$output/Site eligibility/APR 2021 - Primary prevention - Usage by month ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") replace
	restore
}
	// Got to do the first country by itself so I can use the replace in the
	// export command, and then sheetmodify for the remaining countries.
	
foreach x in Kenya Lesotho Malawi SA Uganda Zambia {
	preserve
	keep if site_tag==1
	keep if country=="`x'"
	keeporder eligible facility ///
		completed2_m_min completed2_m_max ///
		m_2019* m_2020* m_2021* 
	gsort -eligible +facility 
	export excel using ///
		"$output/Site eligibility/APR 2021 - Primary prevention - Usage by month ($S_DATE).xlsx", ///
		firstrow(varlabels) sheet("`x'") sheetmodify
	restore
}




*------------------------------------------------------------------------------*
* Identify starting month for each eligible site
/*
Of those that are eligible, for each site, only include the months from
which there is consistent usage thereafter. So, if a site has some data for a 
few months in 2018, then none for some months, and then starts again in 2019 
and has continuous usage until end 2020, they are included from their start 
month in 2019. 
Test how many sites are included if we allow them to miss at most 1 per year

I want to find a way to automate this but I can't think of how right now and
I need to make progress, so I am doing it manually using the excel exports
created above.
*/

foreach country in Ghana Kenya Lesotho Malawi SA Uganda Zambia {
	import excel ///
		"$output/Site eligibility/APR 2021 - Primary prevention - Usage by month ($S_DATE).xlsx", ///
		sheet("`country'") firstrow clear
	keep if Siteiseligibleforinclusion=="Yes"
	*ren Startmonth start_month
	ren Earliestformsubmonth start_month
	ren Facility facility
	gen country="`country'"
	keeporder country facility start_month 
	save "$temp/`country' facilities.dta", replace
}

use "$temp/Ghana facilities.dta", clear
append using ///
	"$temp/Kenya facilities.dta" ///
	"$temp/Lesotho facilities.dta" ///
	"$temp/Malawi facilities.dta" ///
	"$temp/SA facilities.dta" ///
	"$temp/Uganda facilities.dta" ///
	"$temp/Zambia facilities.dta" 
sort country facility
save "$temp/primary prevention facilities.dta", replace
erase "$temp/Ghana facilities.dta"
erase"$temp/Kenya facilities.dta" 
erase"$temp/Lesotho facilities.dta" 
erase"$temp/Malawi facilities.dta" 
erase"$temp/SA facilities.dta" 
erase"$temp/Uganda facilities.dta" 
erase"$temp/Zambia facilities.dta" 
