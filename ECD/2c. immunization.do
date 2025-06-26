
* --> Infant Immunizations
use "$data_appdata/Old & new version/App2/infant_reduced.dta", clear
keep if country == "Ghana"

*------------------------------------------------------------------------------*

ds immun* deworm* vita*
local yesno `r(varlist)'
foreach var of varlist `yesno' {
	qui replace `var'="0" if `var'=="no"
	qui replace `var'="1" if `var'=="yes"
	replace `var'="" if `var'=="na" | `var'=="---"
	qui destring `var', replace
	label val `var' yesno
}

* Take maximum of multiple measurements for same age
/*
There are a few cases where a given age's milestone is measured multiple
times. I take the maximum of the measures in those cases, which will be within
if that was ever recorded. 
*/

* --> Immunization
foreach i in birth 6wk 10wk 14wk 6m 9m 12m 18m {
	egen max_`i'=max(immun_`i'), by(hhid)
	replace immun_`i'=max_`i'
	drop max_`i'
}


* --> Deworming
foreach i in 6m 12m 18m 24m {
	egen max_`i'=max(deworm_`i'), by(hhid)
	replace deworm_`i'=max_`i'
	drop max_`i'
}

* --> Vitamin
foreach i in 6m 12m 18m 24m {
	egen max_`i'=max(vita_`i'), by(hhid)
	replace vita_`i'=max_`i'
	drop max_`i'
}


*------------------------------------------------------------------------------*
* Assessment rate for last due assessment

* -- Immunization
*gen due_birth = 1 if immun_birth != .
foreach i in /*birth*/ 6wk 10wk 14wk 6m 9m 12m 18m {
	gen due_assessed_`i'x=due_`i'==1 & immun_`i'!=.
	egen immun_due_assessed_`i'=max(due_assessed_`i'), by(hhid)
	label var immun_due_assessed_`i' ///
		"Infant was both due and assessed for `i' imunization by last visit"
	label val immun_due_assessed_`i' yesno
	drop due_assessed_*
}

* --> Deworming
foreach i in 6m 12m 18m 24m{
	gen due_assessed_`i'x=due_`i'==1 & deworm_`i'!=.
	egen deworm_due_assessed_`i'=max(due_assessed_`i'), by(hhid)
	label var deworm_due_assessed_`i' ///
		"Infant was both due and assessed for `i' Deworm by last visit"
	label val deworm_due_assessed_`i' yesno
	drop due_assessed_*
}

* --> Vitamins
foreach i in 6m 12m 18m 24m{
	gen due_assessed_`i'x=due_`i'==1 & vita_`i'!=.
	egen vita_due_assessed_`i'=max(due_assessed_`i'), by(hhid)
	label var vita_due_assessed_`i' ///
		"Infant was both due and assessed for `i' Vitamins by last visit"
	label val vita_due_assessed_`i' yesno
	drop due_assessed_*
}

*------------------------------------------------------------------------------*
* Achievement rate for last due assessment

* --> Achieved dummy (where achieve=done)

* --> Immunization
foreach i in /*birth*/ 6wk 10wk 14wk 6m 9m 12m 18m {
	gen immun_due_achieved_`i'x=due_`i'==1 & immun_`i'==1
	egen immun_due_achieved_`i'=max(immun_due_achieved_`i'), by(hhid)
	label var immun_due_achieved_`i' ///
		"Infant was both due for and received `i' immunization by last visit"
	label val immun_due_achieved_`i' yesno
}

* --> Deworming
foreach i in 6m 12m 18m 24m {
	gen deworm_due_achieved_`i'x=due_`i'==1 & deworm_`i'==1
	egen deworm_due_achieved_`i'=max(deworm_due_achieved_`i'), by(hhid)
	label var deworm_due_achieved_`i' ///
		"Infant was both due for and received `i' Deworming by last visit"
	label val deworm_due_achieved_`i' yesno
}

* --> Deworming
foreach i in 6m 12m 18m 24m {
	gen vita_due_achieved_`i'x=due_`i'==1 & vita_`i'==1
	egen vita_due_achieved_`i'=max(vita_due_achieved_`i'), by(hhid)
	label var vita_due_achieved_`i' ///
		"Infant was both due for and received `i' Vitamins by last visit"
	label val vita_due_achieved_`i' yesno
}




* --> Rates for each measurement category 

* --> Immunization
foreach i in 6wk 10wk 14wk 6m 9m 12m 18m {
	gen immun_done_`i'x=due_`i'==1 & immun_`i'==1
	egen immun_done_`i'=max(immun_done_`i'), by(hhid)
	label var immun_done_`i' ///
		"Infant was due and received `i' immunization by last visit"
	label val immun_done_`i' yesno
	drop immun_done_*x
}

* --> Deworming
foreach i in 6m 12m 18m 24m{
	gen deworm_done_`i'x=due_`i'==1 & deworm_`i'==1
	egen deworm_done_`i'=max(deworm_done_`i'), by(hhid)
	label var deworm_done_`i' ///
		"Infant was due and received `i' Deworming by last visit"
	label val deworm_done_`i' yesno
	drop deworm_done_*x
}


* --> Vitamins
foreach i in 6m 12m 18m 24m{
	gen vita_done_`i'x=due_`i'==1 & vita_`i'==1
	egen vita_done_`i'=max(vita_done_`i'), by(hhid)
	label var vita_done_`i' ///
		"Infant was due and received `i' vitamin by last visit"
	label val vita_done_`i' yesno
	drop vita_done_*x
}

*------------------------------------------------------------------------------*
* Export Immunization rates by facility

* --> Recreate tag to make sure it is still correct
cap drop hhid_tag
egen hhid_tag=tag(hhid)
tab hhid_tag


* --> Create facility counts and percentages
foreach i in 6wk 10wk 14wk 6m 9m 12m 18m {
    gen due_`i'_tag=hhid_tag*due_`i'
	egen due_`i'_fac=sum(due_`i'_tag), by(facility)
	label var due_`i'_fac ///
		"Total infants due for `i' immun/deworm/vita by last visit"
	
	gen immun_assessed_`i'_tag=hhid_tag*immun_due_assessed_`i'
	egen immun_assessed_`i'_fac=sum(immun_assessed_`i'_tag), by(facility)
	label var immun_assessed_`i'_fac "# infants due and assessed at `i'"

	gen immun_perc_assessed_`i'_fac=immun_assessed_`i'_fac/due_`i'_fac 
	label var immun_perc_assessed_`i'_fac "% infants assessed at `i' immunization"

	gen immun_done_`i'_tag=hhid_tag*immun_done_`i'
	egen immun_done_`i'_fac=sum(immun_done_`i'_tag), by(facility)
	label var immun_done_`i'_fac "# infants who recieved immunization at `i'"

	gen immun_perc_done_`i'_fac=immun_done_`i'_fac/due_`i'_fac 
	label var immun_perc_done_`i'_fac "% infants who recieved immunization at `i'"
}


foreach i in 6m 12m 18m 24m{
    gen due_`i'_tag1=hhid_tag*due_`i'
	egen due_`i'_fac1=sum(due_`i'_tag1), by(facility)
	label var due_`i'_fac1 ///
		"Total infants due for `i' deworming by last visit"
	
	gen deworm_assessed_`i'_tag=hhid_tag*deworm_due_assessed_`i'
	egen deworm_assessed_`i'_fac=sum(deworm_assessed_`i'_tag), by(facility)
	label var deworm_assessed_`i'_fac "# infants due and assessed at `i' deworming"

	gen deworm_perc_assessed_`i'_fac=deworm_assessed_`i'_fac/due_`i'_fac1 
	label var deworm_perc_assessed_`i'_fac "% infants assessed at `i' deworming"

	gen deworm_done_`i'_tag=hhid_tag*deworm_done_`i'
	egen deworm_done_`i'_fac=sum(deworm_done_`i'_tag), by(facility)
	label var deworm_done_`i'_fac "# infants who recieved deworming at `i'"

	gen deworm_perc_done_`i'_fac=deworm_done_`i'_fac/due_`i'_fac1 
	label var deworm_perc_done_`i'_fac "% infants who recieved deworming at `i'"
}


foreach i in 6m 12m 18m 24m{
    gen due_`i'_tag2=hhid_tag*due_`i'
	egen due_`i'_fac2=sum(due_`i'_tag2), by(facility)
	label var due_`i'_fac2 ///
		"Total infants due for `i' Vitamin by last visit"
	
	gen vita_assessed_`i'_tag=hhid_tag*vita_due_assessed_`i'
	egen vita_assessed_`i'_fac=sum(vita_assessed_`i'_tag), by(facility)
	label var vita_assessed_`i'_fac "# infants due and assessed at `i' Vitamin"

	gen vita_perc_assessed_`i'_fac=vita_assessed_`i'_fac/due_`i'_fac2 
	label var vita_perc_assessed_`i'_fac "% infants assessed at `i' Vitamin"

	gen vita_done_`i'_tag=hhid_tag*vita_done_`i'
	egen vita_done_`i'_fac=sum(vita_done_`i'_tag), by(facility)
	label var vita_done_`i'_fac "# infants who recieved Vitamin at `i'"

	gen vita_perc_done_`i'_fac=vita_done_`i'_fac/due_`i'_fac2 
	label var vita_perc_done_`i'_fac "% infants who recieved Vitamin at `i'"
}

* Save dataset to use in analysis output do file

egen fac_tag=tag(fac)
keep if fac_tag==1
keeporder facility *_fac *_fac1 *_fac2
save immun_deworm_vita, replace

*Immunization
use immun_deworm_vita, clear
keeporder facility - immun_perc_done_18m_fac
save "$data_appdata/Old & new version/App2/immunization.dta", replace

*Deworming
use immun_deworm_vita, clear
keeporder facility due_6m_fac1 deworm_assessed_6m_fac - deworm_perc_done_6m_fac ///
          due_12m_fac1 deworm_assessed_12m_fac - deworm_perc_done_12m_fac ///
		  due_18m_fac1 deworm_assessed_18m_fac - deworm_perc_done_18m_fac ///
		  due_24m_fac1 deworm_assessed_24m_fac - deworm_perc_done_24m_fac
save "$data_appdata/Old & new version/App2/deworming.dta", replace

*Vitamin
use immun_deworm_vita, clear
keeporder facility due_6m_fac2 vita_assessed_6m_fac - vita_perc_done_6m_fac ///
          due_12m_fac2 vita_assessed_12m_fac - vita_perc_done_12m_fac ///
		  due_18m_fac2 vita_assessed_18m_fac - vita_perc_done_18m_fac ///
		  due_24m_fac2 vita_assessed_24m_fac - vita_perc_done_24m_fac
save "$data_appdata/Old & new version/App2/vitamin.dta", replace
