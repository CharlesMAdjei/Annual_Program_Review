*** APR 2019 - Early RIC
*** Identify cohort for early RIC
* 19 June 2020



*------------------------------------------------------------------------------*
* Merge cleaned forms together

* --> Merge new and AN, and reshape
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Do files\Temp\Firdale\new/new_clean_2020.dta", clear
merge 1:m id using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Do files\Temp\Firdale\an/an_clean_2020.dta"
drop if _merge==2
	// Drop women found only in the AN form and not the new client form

assert id!=""
sort id dan_timeend_time
bysort id: gen dup=cond(_N==1,1,_n)
keep id dup dnew* dan_timeend* dan_timerec* dan_hiv* dan_vl* dan_an* ///
	dan_init* dan_art* dan_client_is_pn dan_dob dan_adh_5pt dan_adh_7day
	// Keep relevant variables
	
ren dnew_facility facility
ren dnew_country country
merge m:1 facility using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Eligible facilities.dta" 
keep if _merge==3
drop _merge
	// Keep relevant facilities
	
keep if dnew_timeend_date>=td(01jan2020) & dnew_timeend_date<=td(30jun2020)
	// Keep those enrolled in first half of 2020
	
keep if dan_timeend_date>=td(01jan2020) & dan_timeend_date<=td(31dec2020)
	// Keep AN form submissions from 2019. You'd think none should be dropped
	// since I used the 2019 An dataset but it's because some of the forms had
	// a timeend date of Dec 2018 but they must have only been received by
	// the server in 2019, and the exports are based on time received by 
	// server, not time the form was submitted.

ds id dup dnew* country facility, not
local stubs `r(varlist)'
reshape wide `stubs', i(id) j(dup)
gen an="1"
label var an "In AN form"
gen form_type="an"
save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/an_ric.dta", replace


* --> Merge new and PN, and reshape
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Do files\Temp\Firdale/new/new_clean_2020.dta", clear
merge 1:m id using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Do files\Temp\Firdale/pn/pn_clean_2020.dta"
drop if _merge==2
drop _merge
assert id!=""
sort id dpn_timeend_time
bysort id: gen dup=cond(_N==1,1,_n)
keep id dup dnew* dpn_timeend* dpn_timerec* dpn_hiv_status ///
	dpn_dob dpn_infant_dob dpn_feed dpn_bf* dpn_fp* ///
	dpn_tbirth* dpn_t68wk* dpn_t10wk* dpn_t14* dpn_t9m* dpn_t10m* ///
	dpn_t12m* dpn_t13m* dpn_t1824m* dpn_infant_init* ///
	dpn_infant_art* dpn_vl* dpn_art* dpn_init* dpn_client_is_an ///
	dpn_ctx* dpn_nvp* dpn_adh_5pt dpn_adh_7day

ren dnew_facility facility
ren dnew_country country
merge m:1 facility using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Eligible facilities.dta" 
keep if _merge==3
drop _merge
keep if dnew_timeend_date>=td(01jan2020) & dnew_timeend_date<=td(30sep2020)
keep if dpn_timeend_date>=td(01jan2020) & dpn_timeend_date<=td(31dec2020)
ds id dup dnew* country facility, not
local stubs `r(varlist)'
reshape wide `stubs', i(id) j(dup)
gen pn="1"
label var pn "In PN form"
gen form_type="pn"
save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/pn_ric.dta", replace


* --> Reduce exit dataset to relevant period
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Do files\Temp\Firdale/exit/exit_clean_2020.dta", clear
assert id!=""
isid id
keep id dexit* 
ren dexit_facility facility
ren dexit_country country
merge m:1 facility using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Eligible facilities.dta" 
keep if _merge==3
drop _merge
keep if dexit_timeend_date>=td(01jan2020) & dexit_timeend_date<=td(31dec2020)
gen exit="1"
label var exit "In exit form"
gen form_type="exit"
save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/exit_ric.dta", replace


* --> Merge all forms
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/an_ric.dta", clear
merge 1:1 id using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/pn_ric.dta"
drop _merge
merge 1:1 id using "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/exit_ric.dta"
drop if _merge==2
drop _merge
count


* --> Make all variables lowercase and remove superfluous punctuation
*	  This takes ~5 min.
/*
ds, has(type string)
local stubs `r(varlist)'
foreach var of varlist `stubs' {
	replace `var'=lower(`var')
	replace `var'=subinstr(`var', "'", "", .)
	replace `var'=subinstr(`var', ".", "", .)
}
*/
	// Commented out because I don't think it adds much and it takes a long
	// time.
	

* --> Save 
save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric1.dta", replace




use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric1.dta", clear



*------------------------------------------------------------------------------*
* Identify women who were HIV positive at enrolment

tab dnew_hiv_status
gen pos=1 if strpos(dnew_hiv_status, "positive")
replace pos=0 if strpos(dnew_hiv_status, "neg")
tab pos, m
/*
preserve
egen cohort=total(pos), by(facility)
egen fac_tag=tag(facility)
keep if fac_tag==1 
sort country facility
keeporder country facility cohort
export excel using ///
	"$output/Checks/Cohort (HIV-pos at enrol) ($S_DATE).xlsx", ///
	firstrow(varlabels) replace
restore
*/

tab country pos, m
keep if pos==1
drop pos
count
	// 10803
	
	
	
	
*------------------------------------------------------------------------------*
* First and last form submission within each form and across forms

* --> First and most recent form submission (as proxy for visit) within
*	  each dataset
ren d*timeend_date* *timeenddate*
ren d*timeend_time* *timeendtime*
ren d*timerec_date* *timerecdate*
ren d*timerec_time* *timerectime*

foreach x in an pn {
	egen double first_timeenddate`x'=rowmin(`x'_timeenddate*)
	label var first_timeenddate`x' "First `x' form submission date"
	
	egen double mostrecent_timeenddate`x'=rowmax(`x'_timeenddate*)
	label var mostrecent_timeenddate`x' "Most recent `x' form submission date"
	format %d first_timeenddate`x' mostrecent_timeenddate`x'
}
	
foreach x in new exit {
	gen double first_timeenddate`x'=`x'_timeenddate
	label var first_timeenddate`x' "First `x' form submission date"
	gen double mostrecent_timeenddate`x'=`x'_timeenddate
	label var mostrecent_timeenddate`x' "Most recent `x' form submission date"
	format %d first_timeenddate`x' mostrecent_timeenddate`x'
}
	// There is only 1 form submission per client in each of these forms so
	// this is redundant but I do it so that we have the same variables across
	// all forms.
	

* --> First and most recent form submission across all datasets
	// Don't include exit form because that isn't representative of a visit
egen double first_timeenddate=rowmin(first_timeenddatenew ///
	first_timeenddatean first_timeenddatepn)
egen double mostrecent_timeenddate=rowmax(first_timeenddatenew ///
	first_timeenddatean first_timeenddatepn)
format %td first_timeend* mostrecent_timeend*


* --> Identify clients with an AN or PN form submission before new form sub.
drop if first_timeenddate!=first_timeenddatenew
assert first_timeenddate==first_timeenddatenew
	// First form submission date must be in new client form


* --> Identify clients who only appear in new client form
	// Tried to use the an and pn dummy variables but something in the cleaning
	// or reshaping meant all replaced to 1 so drop them and use presence of 
	// a form submission date as the indicator on whether a client ever had
	// an AN or PN form submission.
drop an pn exit
count if first_timeenddatean==.
count if first_timeenddatepn==.
count if first_timeenddatean==. & first_timeenddatepn==.
/*
sort dnew_country dnew_facility
br dnew_country dnew_facility dan* dpn* if ///
	first_timeenddatean==. & first_timeenddatepn==.
*/
	// 1912 women never have either AN or PN form submitted. Drop them as
	// have no information on even their first visit. First count number per
	// facility so can report on them.
	
gen new_onlyx=first_timeenddatean==. & first_timeenddatepn==.
egen new_only=total(new_onlyx), by(facility)
label var new_only "Count of clients per facility found only in new client form"
tab new_only
gen x=1
egen total=total(x), by(facility)
label var total "Count of all clients per facility"

drop if new_onlyx==1
drop new_only total 
count
	// 10800



	
*------------------------------------------------------------------------------*
* Maternal DOB and age
	// Take this from new client form
	
* --> DOB from new client form
foreach x in new {
	gen dob=date(d`x'_dob, "YMD") 
	replace dob=date(d`x'_dob, "DMY") if dob==.
	format %d dob
}
count if dob==.


* --> Age from new client form - use to fill in DOB
ren dnew_age age
destring age, replace force
replace age=. if age>60
count if dob==. & age!=.
gen dob_miss=dob==.
replace dob=first_timeenddate-(365.25*age) if dob==. & age!=.
format %d dob 
label var dob "Maternal DOB"
tab dob if dob_miss==1
count if dob==.
drop if dob==.


* --> Populate age for all women (age at beginning of period)
replace age=(first_timeenddate-dob)/365.25  if age==.
replace age=round(age, 1)
la var age "Age at first visit"
tab age if age<10 | age>60
tab dob if age<10 | age>60
tab dan_dob1 if age<10 | age>60
tab dpn_dob1 if age<10 | age>60
drop if age<10 | age>60
	// Drop those cases where the age is totally whack and no way to fix it.

drop d?n_dob? d?n_dob?? dnew_dob* dob_miss


	

*------------------------------------------------------------------------------*
* Infant DOB

* --> Identify infant's DOB from most recent entry in the PN form
gen infant_dob=.
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'

forvalues i=1/`nvars' {
	gen infant_dob`i'=date(dpn_infant_dob`i' , "YMD") 
	replace infant_dob`i'=date(dpn_infant_dob`i', "DMY") if infant_dob`i'==.
	la var infant_dob`i' "Infant date of birth in obs `i'"
	forvalues j=1/`nvars'{
		replace infant_dob=infant_dob`i' if ///
			pn_timeenddate`i'>=pn_timeenddate`j' & ///
			pn_timeenddate`i'<. & ///
			infant_dob`i'!=.			
	}
}
format %d infant_dob
label var infant_dob "Infant's DOB from most recent PN form submitted in App1"


* --> Check for cases where client has more than 1 infant DOB in PN form
egen infant_dob_min=rowmin(infant_dob? infant_dob??)
egen infant_dob_max=rowmax(infant_dob? infant_dob??)
format %d infant_dob*
gen infant_dob_diff=infant_dob_max-infant_dob_min
label var infant_dob_diff "Diff between infant DOBs recorded in PN form in app1"
/*
count if infant_dob_min!=infant_dob_max
count if infant_dob_diff>60 & infant_dob_diff<.
gsort -infant_dob_diff
br infant_dob infant_dob_m* infant_dob_diff ///
	infant_dob? infant_dob?? ///
	if infant_dob_min!=infant_dob_max
*/

drop if infant_dob_diff>62 & infant_dob_diff<.
count if infant_dob!=.
count if infant_dob_diff>0 & infant_dob_diff<.
	// Drop clients where there is more than a 2 month gap between infant
	// DOBs recorded in PN form. For the rest, take the DOB recorded in their
	// most recent PN form submission. 

count if infant_dob==. & first_timeenddatepn!=.
	
drop dpn_infant_dob* infant_dob_* infant_dob? infant_dob??
label var infant_dob "Infant DOB"



	
*------------------------------------------------------------------------------*
* Replace timeend dates with missing if there are two obs with the same 
* timeend dates as this should only count as a single visit. 
/* 
Although this has nothing to do with identifying the cohort, I include it here
because it takes time and makes running the variable creation do file a pain
in the ass.
*/

ren dpn_t10wk* dpn_tenwk*
ren dpn_t10m* dpn_ttenm*
	// Need to rename these because of code in the loop. Still don't fully
	// understand but it works.

* --> A looong loop with many steps...
/*
I still don't understand why we need the suffix step but it works and it's
necessary so...
*/

save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric2.dta", replace


foreach x in an pn { 			
	use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric2.dta", clear	
	
	preserve 
	cap drop dup
	keep id d`x'_* `x'_*	
		// Keep only the variables in the form being dealt with
		
	* Reshape all variables that have the suffixes of 1, 2, etc
	unab varlist: *10
			// Unab creates a list of variables for all vars that end in 10, 
			// saved in "`varlist'". unab is needed because it allows the 
			// use of wildcards (and the command ", not") when creating locals 
			// consisting of a list of variables in a dataset.
			
	local varlist: subinstr local varlist "10" "", all		
			// Create a new list where 10s are replaced with blank so that the 
			// reshape works.

	reshape long `varlist', i(id) j(dup)					
	ds id dup `x'_*, not									
		// We want a local that contains all variables except id, dup and the 
		// created date variables.
		
	unab varlist: `r(varlist)'							
		// Local from above line of code

	gsort id `x'_timeenddate -`x'_timeendtime		
		// Sort the data by id, then by date, and then by time so that the 
		// latest time appears first within that group. 
		
	foreach y in `varlist' {
		by id `x'_timeenddate: replace `y'=`y'[_n+1] if (`y'=="" | `y'=="---")	
			// If an entry is "" or "---", replace that entry with the line 
			// just below if it is of the same ID and date. The latest time 
			// will be first row as per line above. In other words, the latest
			// entry is taken unless it is missing, in which case the earlier
			// entries are progressively taken if it is still missing.
	}

	* If client is seen more than once on the same day, only keep the date entry 
	* with the latest time entry. The rest are replaced as missing.
	by id `x'_timeenddate: gen tag=cond(_N==1,1,_n) 
		// Identify clients with visits on the same day; For example: if 
		// observation 1 and observation 2 have the same id and the same 
		// timeenddate, then tag will be 1 for observation 1 and 2 for 
		// observation 2. Conversely, if we have observation 1 and 2 with the
		// same id but different dates, then both observations will have tag  
		// 0. Missing dates will get tagged, but it's OK as they get replaced 
		// with missing later.
														 
	replace `x'_timeenddate=. if tag>1		
		// Keep only one of the dates per duplicate dates within ID, with the 
		// date with the latest time kept as is. 
		
	drop tag

	
	* Merge back into the master dataset
	ds id dup, not
	unab varlist: `r(varlist)'
	reshape wide `varlist', i(id) j(dup)
	tempfile `x'_dupfree
	save ``x'_dupfree'
	restore
	drop d`x'_* `x'_*						
		// To replace all old variables with the new 
		
	cap drop _merge
	merge 1:1 id using ``x'_dupfree'		
		// Merge in the cleaned data
		
	format `x'_timeenddate* %td
	drop _merge 
		
	save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric2.dta", replace
	sleep 200
}
cap drop __000*




*------------------------------------------------------------------------------*
* Early RIC cohort dataset
/*
Women in the sample must have been positive at enrolment (known or tested pos
in the new client form), as well as have a valid age. They must also have
at least one AN or PN form submission in addition to the new client form. They
enrolled between 1 Jan and 30 June 2019, and we have their data from 1 Jan - 
31 Dec 2019.
*/

save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric3.dta", replace
count
	// 8250


	
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric3.dta", clear
	

*------------------------------------------------------------------------------*
* Site type

/*
Would have to be updated for this sample - facility is no longer in all lower
case. I haven't fixed it here since we aren't, as yet, reporting RIC by site
type.

gen site_type=.
replace site_type=1 if strpos(facility, "clinic")
replace site_type=2 if strpos(facility, "hc")
replace site_type=2 if strpos(facility, "health center")
replace site_type=2 if facility=="holy cross" | ///
	facility=="mofumahali oa rosari" | facility=="morifi"
replace site_type=3 if strpos(facility, "hospital")
replace site_type=3 if facility=="khayelitsha site b mou" | ///
	facility=="michael mapongwana clinic" | facility=="soshanguve mou"
	// Advised by Kathrin to classify these as hospitals
	
label def site_type 1"Clinic" 2"Health centre" 3"Hospital"
label val site_type site_type
tab site_type, m

*/

	
	

*------------------------------------------------------------------------------*
* Identify clients according to AN/PN

* --> Identify AN versus PN etc
gen an=first_timeenddatean!=.
gen pn=first_timeenddatepn!=.
gen an_only=first_timeenddatean!=. & first_timeenddatepn==.
gen pn_only=first_timeenddatean==. & first_timeenddatepn!=.
gen an_pn=first_timeenddatean!=. & first_timeenddatepn!=.
gen an_any=an_only==1 | an_pn==1
gen pn_any=pn_only==1 | an_pn==1


* --> Variables for tables
gen retained=an_pn
label var retained "Client enrolled AN, retained PN"
tab an_pn
tab retained

gen type=0 if an_only==1
replace type=1 if pn_only==1
replace type=2 if an_pn==1
label def type 0"AN only" 1"PN only" 2"AN+PN"
label val type type
label var type "AN / PN / AN+PN"
tab type, m




*------------------------------------------------------------------------------*
* Mother's age in various categories

* --> AG versus YW versus older
gen ag=age>=10 & age<=19
la var ag "Adol. girl: 10-19"
gen yw=age>=20 & age<=24 
la var yw "Young woman: 20-24"
gen agyw=ag==1 | yw==1
la var agyw "AGYW: 10-24"
gen ow=age>=25
la var ow "Older woman: 25+"
gen agecat_agyw=1 if ag==1
replace agecat_agyw=2 if yw==1
replace agecat_agyw=3 if ow==1
label def agecat_agyw 1"Adolescent (10-19)" 2"Young woman (20-24)" ///
	3"Older women (25+)"
label val agecat_agyw agecat_agyw
tab agecat_agyw, m


* --> Age categories (2)
gen agecat_2=1 if age>=10 & age<=24 
replace agecat_2=2 if age>24 & age<.
label def agecat_2_lab 1"1. 10-24 yrs" 2"2. 25+ yrs"
label val agecat_2 agecat_2_lab
label var agecat_2 "Age categories (10-24 vs 25+)"
tab agecat_2, m


* --> Age categories (5)
recode age ///
	(min/19=1 "<20") ///
	(20/24=2 "20-24") ///
	(25/29=3 "25-29") ///
	(30/34=4 "30-24") ///
	(35/max=5 "35+") ///
	, gen(agecat_5)
numlabel, add
tab agecat_5, m




*------------------------------------------------------------------------------*
* AN and PN visits

* --> Count unique AN and PN form submission dates per client
	// All timeend dates should be different because of long loop at the top
	// of this do file.
foreach x in an pn {
	egen visits_`x'=rownonmiss(`x'_timeenddate? `x'_timeenddate??)
	replace visits_`x'=. if `x'_any!=1
	label var visits_`x' "Total `x' visits (proxied by `x' form sub date)"
}
tab1 visits_?n


* --> Total AN + PN visits
egen visits_total=rowtotal(visits_an visits_pn)
label var visits_total "Total visits (AN + PN)"
tab visits_tot


* --> AN visits in 4 categories
recode visits_an ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3=3 "3") ///
	(4/max=4 "4+") ///
	, gen(visits_an_cat)
label var visits_an_cat "AN visits"


* --> PN visits in 5 categories
recode visits_pn ///
	(1=1 "1") ///
	(2=2 "2") ///
	(3=3 "3") ///
	(4=4 "4") ///
	(5/max=5 "5+") ///
	, gen(visits_pn_cat)
label var visits_pn_cat "PN visits"




*------------------------------------------------------------------------------*
* Gestational age at first facility visit

* --> Put gestage in weeks for everyone
tab dnew_gestage_units
tab dnew_gestage_anc1 if dnew_gestage_units=="months"
destring dnew_gestage_anc1, replace force
ren dnew_gestage_anc1 gestage_fac
tab gestage_fac
replace gestage_fac=round(gestage_fac*4.3, 1) if ///
	dnew_gestage_units=="months" & ///
	gestage_fac*4.3<40
		// Include the second condition because clearly some of those where they
		// said the unit was month was actually week because they end up 
		// having a gestage of 117 
		
replace gestage_fac=. if gestage<4
	// We always assume this is an error
	
tab gestage_fac if an_any==1, m
	// 470 AN-any clients are missing their gestage. 
	
	
* --> Trimester at first facility visit
recode gestage_fac ///
	(4/13=1 "1. Trimester 1") ///
	(14/26=2 "2. Trimester 2") ///
	(27/max=3 "3. Trimester 3"), ///
	gen(trimester)
label var trimester "Trimester at first visit"
tab trimester if an_any==1, m


* --> Gestational age at first facility visit <17 weeks
recode gestage_fac ///
	(min/17=1 "1. Yes") ///
	(18/max=0 "0. No"), ///
	gen(gestage_before17wks)
label var gestage_before17wks "Gestage less than 17 weeks"
tab gestage_before17wks if an_any==1, m




*------------------------------------------------------------------------------*
* Family planning

ds pn_timeenddate*		
local nvars: word count `r(varlist)'
di `nvars'
forvalues x=1/`nvars' {
	replace dpn_fp_method`x'="" if dpn_fp_method`x'=="---"
	gen condom`x'=dpn_fp_condom`x'=="yes"
	gen imp`x'=dpn_fp_method`x'=="implant"
	gen inj`x'=dpn_fp_method`x'=="injection"
	gen iud`x'=dpn_fp_method`x'=="iud"
	gen pill`x'=dpn_fp_method`x'=="oral_contraceptives"
	gen tl`x'=dpn_fp_method`x'=="sterilization"
	gen dual`x'=condom`x'==1 & dpn_fp_method`x'!=""
}

foreach x in condom imp inj iud pill tl dual {
	egen fp_`x'_ever=rowmax(`x'*)
	replace fp_`x'_ever=. if pn_any!=1
	label var fp_`x'_ever "Ever used FP method `x'"
}

egen fp_any=rowtotal(fp*ever)
gen fp_any_ever=fp_any>0 & fp_any<.
replace fp_any_ever=. if pn_any!=1
label var fp_any_ever "Ever used any FP method"

egen fp_long=rowtotal(fp_pill_ever fp_iud_ever fp_imp_ever fp_inj_ever ///
	fp_tl_ever)
gen fp_long_ever=fp_long>0 & fp_long<.
replace fp_long_ever=. if pn_any!=1
label var fp_long_ever "Ever used a longer acting FP method"

tab1 fp*ever if pn_any==1, m




*------------------------------------------------------------------------------*
* Partner status
	// Taken from new client form
	
gen has_partner=dnew_has_partner=="yes"
label var has_partner "Client has partner (from new client form"
gen partner_status=0 if dnew_partner_status=="negative"
replace partner_status=1 if dnew_partner_status=="positive"
replace partner_status=2 if dnew_partner_status=="unknown"
replace partner_status=3 if has_partner==0
label def partner_status 0"Neg" 1"Pos" 2"Unknown" 3"No partner"
label val partner_status partner_status
label var partner_status "Partner's HIV status"
tab has_partner, m
tab partner_status, m




*------------------------------------------------------------------------------*
* ART initiation and refill dates
/* 
ART refills are indicated by: 
	1) ART initiation
	2) ART previous refill
	3) ART refill
ART may be filled in AN or PN.
*/

* --> Rename variables for loop to work
/*
This is dumb. I either need to change the names back in the AN cleaning do file 
or change them in this loop. This is the quickest but dumbest way to address the
issue I created by changing variable names in the cleaning do file at the 
moment.
*/
ren dan_init_date* dan_init_done_date*
ren dpn_artprevrefill_done_date* dpn_artrefill_prev_done_date*


* --> Make dates numeric
foreach x in an pn {
	ds `x'_timeenddate*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		gen `x'_artstart_date`i'=date(d`x'_init_done_date`i', "YMD") 
		replace `x'_artstart_date`i'=date(d`x'_init_done_date`i', "DMY") if ///
			`x'_artstart_date`i'==.
		la var `x'_artstart_date`i' ///
			"ART start date, from `x' dataset, obs `i'" 
	
		gen `x'_artprevrefill_date`i'= ///
			date(d`x'_artrefill_prev_done_date`i', "YMD")
		replace `x'_artprevrefill_date`i'= ///
			date(d`x'_artrefill_prev_done_date`i', "DMY") if ///
				`x'_artprevrefill_date`i'==.
		la var `x'_artprevrefill_date`i' ///
			"ART previous refill done date, from `x' dataset, obs `i'"

		gen `x'_artrefill_date`i'=date(d`x'_artrefill_done_date`i', "YMD")
		replace `x'_artrefill_date`i'= ///
			date(d`x'_artrefill_done_date`i', "DMY") if ///
			`x'_artrefill_date`i'==.
		la var `x'_artrefill_date`i' ///
			"ART refill done date, from `x' dataset, obs `i'"
	}
}
drop dan_art* dpn_art*


* --> ART start date from new client form
tab dnew_init_date
gen double new_artstart_date=date(dnew_init_date, "YMD")
replace new_artstart_date=date(dnew_init_date, "DMY") if new_artstart_date==.
format %d new_artstart_date
label var new_artstart_date "ART start date from new client form"

format %d new_artstart_date ?n_artstart_date* ?n_artrefill_date* ///
	?n_artprevrefill_date*


	
	
*------------------------------------------------------------------------------*
* ART start when 
	// Unlike in the MCC, art start when is not captured. I deduce it from the
	// infant dob and EDD. Where either the start date or infant DOB/edd are 
	// unavailable, we cannot calculate this.
	
* --> Check for inconsistencies
egen artstart_date_min=rowmin(new_artstart_date ?n_artstart*)
egen artstart_date_max=rowmax(new_artstart_date ?n_artstart*)
format %d artstart_date_m*
count if artstart_date_max>artstart_date_min+30
count if new_artstart_date==. & artstart_date_min!=.
/*
br artstart_date_m* new_artstart_date ?n_artstart* if ///
	artstart_date_max>artstart_date_min+30
*/


* --> Create single ART start date variable
gen artstart_date=new_artstart_date
ds an_timeenddate*
local nvars: word count `r(varlist)'

forvalues i=1/`nvars' {
	forvalues j=1/`nvars'{
		local nvars=`nvars'-1
		replace artstart_date=an_artstart_date`i' if ///
			an_timeenddate`i'>=an_timeenddate`j' & ///
			an_timeenddate`i'<. & ///
			an_artstart_date`i'!=.			
	}
}
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	forvalues j=1/`nvars'{
		replace artstart_date=pn_artstart_date`i' if ///
			pn_artstart_date`i'>=pn_artstart_date`j' & ///
			pn_artstart_date`i'<. & ///
			pn_artstart_date`i'!=.			
	}
}
format %d artstart_date
count if artstart_date!=new_artstart_date
	// 212 of ~3500 women with a difference between ART start date in
	// new client form and AN/PN form. Very small, not going to look further
	// into this.
	
count if artstart_date==.
	// 52 women missing an ART start date altogether.
/*
br artstart_date new_artstart_date artstart_date_m* if ///
	artstart_date!=new_artstart_date & new_artstart_date!=.
*/


* --> When started ART
	// App1 doesn't capture "ART start when" in the same way as the MCC so I
	// deduce it based on dates. Probably introduce error and not possible to
	// calculate if infant DOB or EDD not available.
gen edd=date(dnew_edd, "YMD") 
replace edd=date(dnew_edd, "DMY") if edd==.
format %d edd
label var edd "Expected date of delivery"
tab edd if an_only==1, m
	// Missing for 20% of AN-only clients
	
cap drop artstart_when
gen artstart_when=1 if artstart_date<infant_dob-(9*30.5) & infant_dob!=.
replace artstart_when=1 if artstart_date<edd-(9*30.5) & edd!=. & ///
	artstart_when==.

replace artstart_when=2 if artstart_date>infant_dob-(9*30.5) & ///
	artstart_date<infant_dob & infant_dob!=.
replace artstart_when=2 if artstart_date>edd-(9*30.5) & ///
	artstart_date<edd & edd!=. & artstart_when==.

replace artstart_when=3 if artstart_date==infant_dob & artstart_when==.
replace artstart_when=3 if artstart_date==edd & artstart_when==.

replace artstart_when=4 if artstart_date>infant_dob & artstart_date<. & ///
	artstart_when==.
replace artstart_when=4 if artstart_date>edd & artstart_date<. & ///
	artstart_when==.

replace artstart_when=5 if artstart_date==.

replace artstart_when=6 if edd==. & infant_dob==. & artstart_date!=.

label var artstart_when "When started ART"
label def artstart_when 1"Before preg" 2"During preg" 3"During labour" ///
	4"After delivery" 5"No ART start date" ///
	6"Unable to calc (missing EDD & DOB)"
label val artstart_when artstart_when
numlabel, add
tab artstart_when, m




*------------------------------------------------------------------------------*
* ART start (yes/no)

egen refill_done=rownonmiss(*artprevrefill_date* *artrefill_date*)
	// Identify clients with at least 1 ART refill date

gen artstart=artstart_date!=. 
replace artstart=1 if refill_done>0 & artstart==0
label var artstart "Has started ART"
tab artstart, m




*------------------------------------------------------------------------------*
* Feeding
/*
On the MCC, they captured a separate element that was whether the baby was 
exclusively breastfed until 6 months or not. The app doesn't have this. It
collects feeding method at each visit. I have coded it so that only visits
where the infant is younger than 6 months are included in the calculation of
feeding method. However, what to do about the fact that we might only have 
feeding methods until 3 months old and then nothing recorded. If only BF
is recorded for those visits then my code will say they were excl. BF until 
6 months but we don't know what happened between 3 and 6 months old. I am 
just going to go with this method but mention the caveat in the presentation.
*/
ds pn_timeenddate*		
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues x=1/`nvars' {
	gen feed_method`x'=1 if dpn_feed_current`x'=="excl_breastfeeding"
	replace feed_method`x'=2 if dpn_feed_current`x'=="excl_formula"
	replace feed_method`x'=3 if dpn_feed_current`x'=="mixed_feeding"
	replace feed_method`x'=. if pn_timeenddate`x'-infant_dob>6*30.5
		// Remove the feeding method if it comes from a visit where the infant
		// was older than 6 months.
}
label def feed 1"EBF" 2"ERF" 3"MF"
label val feed_method* feed

egen feed_min=rowmin(feed_method*)
egen feed_max=rowmax(feed_method*)
gen mf_6month=feed_min!=feed_max
replace mf_6month=1 if feed_min==3 & feed_max==3
label var mf_6month "Mixed feeding up to 6m"
gen ebf_6month=feed_min==1 & feed_max==1
label var ebf_6month "Excl. breast feeding up to 6m"
gen erf_6month=feed_min==2 & feed_max==2
label var erf_6month "Excl. replacement feeding up to 6m"
gen feed_6month=1 if ebf==1
replace feed_6month=2 if erf==1
replace feed_6month=3 if mf==1
label val feed_6month feed
label var feed_6month "Feeding method up to 6m"
tab1 ebf erf mf feed_6m if pn_any==1, m

gen excl_feeding=ebf==1 | erf==1
label var excl_feeding "EBF or ERF"
tab excl_feeding if pn_any==1, m
drop dpn_feed* feed_method* dpn_bf_ever* dpn_bf_stop*




*------------------------------------------------------------------------------*
* NVP and CTX

* --> Make due and done dates numeric
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach x in nvp_due_date nvp_done_date ctx_due_date ctx_done_date {
		gen `x'`i'=date(dpn_`x'`i', "YMD") 
		replace `x'`i'=date(dpn_`x'`i', "DMY") if `x'`i'==. 
		format %d `x'`i'
		drop dpn_`x'`i'
	}
}


* --> Ever due and ever done
foreach x in nvp_due nvp_done ctx_due ctx_done {
	egen `x'_date_num=rownonmiss(`x'_date*)
	gen `x'_ever=`x'_date_num>0
	replace `x'_ever=. if pn_any!=1
}




*------------------------------------------------------------------------------*
* Infant tests

ren *ttenm* *t10m*
ren *tenwk* *t10wk*


* --> Test done dates
	// Have to do test and result done dates separately because I didn't include
	// the result done dates for the non-first and last tests.
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach x in ///
		tbirth_test_done_date ///
		t68wk_test_done_date ///
		t10wk_test_done_date ///
		t14wk_test_done_date ///
		t9m_test_done_date ///
		t10m_test_done_date ///
		t12m_test_done_date ///
		t13m_test_done_date ///
		t1824m_test_done_date {
			gen `x'`i'=date(dpn_`x'`i', "YMD") 
			replace `x'`i'=date(dpn_`x'`i', "DMY") if `x'`i'==. 
			format %d `x'`i'
	}
	la var tbirth_test_done_date`i' "Birth test done date, obs `i'"
	la var t68wk_test_done_date`i' "6-8 week test done date, obs `i'"
	la var t10wk_test_done_date`i' "10 week test done date, obs `i'"
	la var t14wk_test_done_date`i' "14 week test done date, obs `i'"
	la var t9m_test_done_date`i' "9 month test done date, obs `i'"
	la var t10m_test_done_date`i' "10 month test done date, obs `i'"
	la var t12m_test_done_date`i' "12 month test done date, obs `i'"
	la var t13m_test_done_date`i' "13 month test done date, obs `i'"
	la var t1824m_test_done_date`i' "18-24 month test done date, obs `i'"
}


* --> Result done dates
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach x in ///
		tbirth_result_done_date ///
		t68wk_result_done_date ///
		t10wk_result_done_date ///
		t1824m_result_done_date  {
			gen `x'`i'=date(dpn_`x'`i', "YMD") 
			replace `x'`i'=date(dpn_`x'`i', "DMY") if `x'`i'==. 
			format %d `x'`i'
	}
	la var tbirth_result_done_date`i' "Birth result done date, obs `i'"
	la var t68wk_result_done_date`i' "6-8 week result done date, obs `i'"
	la var t10wk_result_done_date`i' "10 week result done date, obs `i'"
	la var t1824m_result_done_date`i' "18-24 month result done date, obs `i'"
}


* --> Identify single done date (going to take the latest one)
	// Doesn't really matter which date we take since we're not reporting
	// done on time, just done ever.
foreach x in ///
	tbirth_test_done_date tbirth_result_done_date ///
	t68wk_test_done_date t68wk_result_done_date ///
	t10wk_test_done_date t10wk_result_done_date ///
	t14wk_test_done_date t9m_test_done_date ///
	t10m_test_done_date t12m_test_done_date t13m_test_done_date ///
	t1824m_test_done_date t1824m_result_done_date  {
		egen `x'=rowmax(`x'? `x'??)
		format %d `x'
}
	
foreach x in birth 68wk 10wk 1824m {
	label var t`x'_test_done_date "`x' test done date"
	label var t`x'_result_done_date "`x' result done date"
}


* --> Test result
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
		gen test_`x'_result`i'=1 if dpn_t`x'_result`i'=="positive"
		replace test_`x'_result`i'=0 if dpn_t`x'_result`i'=="negative"
	}
}


* --> Check for clients with different test results
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	egen test_`x'_result_min=rowmin(test_`x'_result*)
	egen test_`x'_result_max=rowmax(test_`x'_result*)
	count if test_`x'_result_min!=test_`x'_result_max
}
/*
sort id 
br id test_68wk_result* if test_68wk_result_min!=test_68wk_result_max
*/
	// There are a very small number of cases of one infant having two diff
	// results for their test. I am going to be conservative and code them as
	// positive if they ever have a positive result recorded. 

	
* --> Single test result variable for each test
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	ren test_`x'_result_max test_`x'_result
	label var test_`x'_result "`x' test result"
	drop test_`x'_result_min
}


* --> Put birth and 10 week results into the 6-8 week variable so I have a 
*	  single variable for first test (SA does those two tests)
replace test_68wk_result=test_birth_result if ///
	test_68wk_result==. & test_birth_result!=.
replace test_68wk_result=test_10wk_result if ///
	test_10wk_result!=.
tab test_68wk_result if pn_any==1, m


* --> Test done
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	gen test_`x'_done=(test_`x'_result!=. | t`x'_test_done_date!=.)
	replace test_`x'_done=. if an_only==1
	label var test_`x'_done "`x' test done"
	tab test_`x'_done if pn_any==1, m
}


* --> Has test result
foreach x in 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	gen has_test`x'_result=test_`x'_result!=.
	label var has_test`x'_result "Has `x' test result"
	tab1 test_`x'_done has_test`x'_result if pn_any==1, m
}


* --> Identify infants too young to be included in final test stats
/*
In line with last year, exclude infants who were younger than 24 months old at
1 Nov 2019 if they had not yet done the test.
*/

gen nov2020=td(01nov2020)
gen age_nov2020=round((nov2020-infant_dob)/30.5, 0.01) 
gen infant_tooyoung=age_nov2020<24
replace infant_tooyoung=0 if test_1824m_done==1
tab infant_tooyoung if pn_any==1, m




*------------------------------------------------------------------------------*
* Tested positive before enrolling with m2m
/*
When calculating the transmission rates, we exclude those who tested positive
at or before enrolment with m2m. This means looking at all test results, not 
just first and last.
*/

* --> Ever tested positive
egen ever_pos=rowmax(test_*_result*)
tab ever_pos


* --> Test date of the test where a positive result was obtained
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
		cap drop t`x'_test_done_date`i'x
		gen t`x'_test_done_date`i'x=t`x'_test_done_date`i' if ///
			test_`x'_result`i'==1
		format %d t`x'_test_done_date`i'x
		label var t`x'_test_done_date`i'x "Test done date if result positive"
	}
}


* --> Identify earliest positive test result within each test and then across
*	  tests
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	egen t`x'_test_done_datex=rowmin(t`x'_test_done_date*x)
	format %d t`x'_test_done_datex
}
egen earliest_pos_test=rowmin(t*_test_done_datex)
format %d earliest_pos_test


* --> Identify when they tested positive in relation to enrolment
cap drop when_testpos
gen when_testpos=1 if earliest_pos_test<first_timeenddate
replace when_testpos=2 if earliest_pos_test==first_timeenddate 
replace when_testpos=3 if earliest_pos_test>first_timeenddate & ///
	earliest_pos_test<.
	
label def when_testpos_lab ///
	1"1. Tested pos before enrol" ///
	2"2. Tested pos at enrol" ///
	3"3. Tested pos after enrol"
label val when_testpos when_testpos_lab
tab when_testpos




*------------------------------------------------------------------------------*
* Infant final status

gen infant_status=test_1824m_result 
replace infant_status=1 if ///
	test_birth_result==1 | ///
	test_68wk_result==1 | ///
	test_10wk_result==1 | ///
	test_14wk_result==1 | ///
	test_9m_result==1 | ///
	test_10m_result==1 | ///
	test_12m_result==1 | ///
	test_13m_result==1 
replace infant_status=2 if infant_status==. & pn_any==1
label def status 0"Neg" 1"Pos" 2"No final status"
label val infant_status status
label var infant_status "Final infant status"
tab infant_status if pn_any==1, m


* --> Infant has a final status
gen has_infant_status=infant_status<=1 if pn_any==1
label def has_infant_status_lab 1"1. Has a final infant_status" ///
	0"0. Does not have a final infant_status"
label val has_infant_status has_infant_status_lab
tab has_infant_status if pn_any==1, m
		
		
* --> Final status excluding those testing positive before or at enrolment
cap drop infant_status_postenrol
gen infant_status_postenrol=infant_status
replace infant_status_postenrol=. if when_testpos<3
label var infant_status_postenrol "Infant status excl those pos before/at enrol"
label val infant_status_postenrol status
tab infant_status_postenrol if pn_any==1 & when_testpos>=3, m

		
		

*------------------------------------------------------------------------------*
* Infant ART start

* --> Make infant ART done dates
ds pn_timeenddate*
local nvars: word count `r(varlist)'
local nvars=`nvars'-1
forvalues i=1/`nvars' {
	foreach j in due done {
		gen infant_artinit`j'`i'=date(dpn_infant_init_`j'_date`i', "YMD")
		replace infant_artinit`j'`i'= ///
			date(dpn_infant_init_`j'_date`i', "DMY") if ///
			infant_artinit`j'`i'==.
		la var infant_artinit`j'`i' "Infant ART initiation `j' date, obs `i'"

		gen infant_artprevrefill`j'`i'= ///
			date(dpn_infant_art_prev_`j'_date`i',"YMD")
		replace infant_artprevrefill`j'`i'= ///
			date(dpn_infant_art_prev_`j'_date`i',"DMY") if ///
			infant_artprevrefill`j'`i'==.
		la var infant_artprevrefill`j'`i' ///
			"Infant ART previous refill `j' date, obs `i'"

		gen infant_artrefill`j'`i'=date(dpn_infant_art_`j'_date`i',"YMD")
		replace infant_artrefill`j'`i'= ///
			date(dpn_infant_art_`j'_date`i',"DMY") if ///
			infant_artrefill`j'`i'==.
		la var infant_artrefill`j'`i' "Infant ART refill `j' date, obs `i'"
	}
}


* --> Find earliest infant ART due and done date
foreach x in due done {
	egen infant_art_earliest`x'=rowmin(infant_artinit`x'* ///
		infant_artprevrefill`x'* infant_artrefill`x'*)
	format %d infant_art_earliest`x'
	la var infant_art_earliest`x' "Earliest infant ART `x' date"
}
tab1 infant_art_earliestdue infant_art_earliestdone if infant_status==1, m


* --> Identify those who've started ART
gen infant_artstart=infant_art_earliestdone!=. if infant_status==1
label var infant_artstart "Infant has started ART"
tab infant_artstart if infant_status==1, m
tab infant_artstart if infant_status_postenrol==1, m




*------------------------------------------------------------------------------*
* Has adherence information

* --> Make adherence measures numeric
label define adh_5pt 1"Low adherence" 2"Moderate adherence" 3"High adherence"
label define adh_7day 1"<80%" 2"80-94.9%" 3"95-100%"
foreach x in an pn { 
	ds `x'_timeenddate*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		gen `x'_adh_5pt`i'=1 if d`x'_adh_5pt`i'=="low_adherence"
		replace `x'_adh_5pt`i'=2 if d`x'_adh_5pt`i'=="moderate_adherence"
		replace `x'_adh_5pt`i'=3 if d`x'_adh_5pt`i'=="high_adherence"
		label val `x'_adh_5pt`i' adh_5pt

		gen `x'_adh_7day`i'=1 if d`x'_adh_7day`i'=="less_than_80"
		replace `x'_adh_7day`i'=2 if d`x'_adh_7day`i'=="80_949"
		replace `x'_adh_7day`i'=3 if d`x'_adh_7day`i'=="95_100"
		label val `x'_adh_7day`i' adh_7day
	}
}
drop d?n_adh*
	
	
* --> Number of measures per client	
foreach x in 5pt 7day {
	egen mother_adh_`x'_total=rownonmiss(?n_adh_`x'*)
	label var mother_adh_`x'_total "Total `x' measures per client"
}
tab1 mother_adh*


* --> Number of adherence visits is the max of the above 2 counts
cap drop mother_adh_visits_total
egen mother_adh_visits_total=rowmax(mother_adh_5pt_total mother_adh_7day_total)
label var mother_adh_visits_total "# visits with any adherence information"
tab mother_adh_visits_total


* --> Has any adherence information
cap drop has_adh_info
gen has_adh_info=mother_adh_visits_total>=1 & mother_adh_visits_total<.
label var has_adh_info "Has some adherence information"
tab has_adh_info 




*------------------------------------------------------------------------------*
* 7 day recall (adherence rate)
/*
In previous years we have had a continuous variable for 7 day recall (a number
out of 7 that is the number of doses taken in the last week). This year we
only have a categorical variable. We used to take the average of the continuous
variable and stick that into categories. So now I have to work out some sort
of sensible way of averaging across categories. I could either average the 
values 1, 2 and 3 and see where they stand. Or I could say that you have 
95-100% adherence if 75% or more of your measures are that, and do that for
the other two levels. 
*/

* --> Method 1: Average the values of the categories.
cap drop mother_adh_7day_mean
egen mother_adh_7day_mean=rowmean(?n_adh_7day*)
replace mother_adh_7day_mean=round(mother_adh_7day_mean, 0.01)
label var mother_adh_7day_mean "Mean 7 day recall categories over all visits"
tab mother_adh_7day_mean


* --> Categorical variable for mean 7 day recall over all visits (3 cats)
cap drop mother_adh_7day_mean_cat
gen mother_adh_7day_mean_cat=mother_adh_7day_mean if inlist( ///
	mother_adh_7day_mean, 1, 2, 3)
	// If a woman's average is exactly 1, 2 or 3 it means they only have those
	// measures recorded. So it is only those who fall somewhere between those
	// values that a judegment has to be made about where to put them.
	
count if mother_adh_7day_mean!=. & mother_adh_7day_mean_cat==.
	// 321 of 3115 women have an inbetween value.
	
replace mother_adh_7day_mean_cat=1 if mother_adh_7day_mean<1.5
replace mother_adh_7day_mean_cat=2 if mother_adh_7day_mean>=1.5 & ///
	mother_adh_7day_mean<2.5
replace mother_adh_7day_mean_cat=3 if mother_adh_7day_mean>=2.5 & ///
	mother_adh_7day_mean<.
	// Going for the simplistic rule that you get rounded up or down to nearest
	// whole number.
	
label var mother_adh_7day_mean_cat "Mean 7 day recall (3 categories)"
label val mother_adh_7day_mean_cat adh_7day
tab mother_adh_7day_mean_cat


* --> Categorical variable for mean 7 day recall over all visits (2 cats)
cap drop mother_adh_7day_mean_cat2
recode mother_adh_7day_mean_cat ///
	(1=1 "1. <80% adherence") ///
	(2/3=2 "2. >=80% adherence"), ///
	gen(mother_adh_7day_mean_cat2) 
label var mother_adh_7day_mean_cat2 "Mean 7 day recall (2 categories)"
tab mother_adh_7day_mean_cat2




*------------------------------------------------------------------------------*
* 5 point scale (self-efficacy)
/*
Another section that I am not sure how to do because the number of permutations
is going to be higher here than last year and I can't do it this super
inefficient way. 
*/

* --> Variable to capture all 5 point scale measures
cap drop mother_adh_5pt_all
egen mother_adh_5pt_all=concat(?n_adh_5pt? ?n_adh_5pt??)
replace mother_adh_5pt_all=subinstr(mother_adh_5pt_all, ".", "", .)
tab mother_adh_5pt_all, m


* --> Dummy to capture those with only "high" measurements
cap drop mother_adh_5pt_allhigh
gen mother_adh_5pt_allhigh=.
replace mother_adh_5pt_allhigh=1 if ///
	strpos(mother_adh_5pt_all, "3")
replace mother_adh_5pt_allhigh=0 if ///
	strpos(mother_adh_5pt_all, "1")
replace mother_adh_5pt_allhigh=0 if ///
	strpos(mother_adh_5pt_all, "2")
label define mother_adh_5pt_allhigh_lab 1"1. Consistently high" ///
	0"0. Not consistently high"
label val mother_adh_5pt_allhigh mother_adh_5pt_allhigh_lab
label var mother_adh_5pt_allhigh "All 5 point scale measures are high"
tab mother_adh_5pt_allhigh 


* --> Dummy to capture those with only "medium" measurements
cap drop mother_adh_5pt_allmed
gen mother_adh_5pt_allmed=.
replace mother_adh_5pt_allmed=1 if ///
	strpos(mother_adh_5pt_all, "2")
replace mother_adh_5pt_allmed=0 if ///
	strpos(mother_adh_5pt_all, "1")
replace mother_adh_5pt_allmed=0 if ///
	strpos(mother_adh_5pt_all, "3")
label define mother_adh_5pt_allmed_lab 1"1. Consistently medium" ///
	0"0. Not consistently medium"
label val mother_adh_5pt_allmed mother_adh_5pt_allmed_lab
label var mother_adh_5pt_allmed "All 5 point scale measures are medium"
tab mother_adh_5pt_allmed


* --> Dummy to capture those with only "low" measurements
cap drop mother_adh_5pt_alllow
gen mother_adh_5pt_alllow=.
replace mother_adh_5pt_alllow=1 if ///
	strpos(mother_adh_5pt_all, "1")
replace mother_adh_5pt_alllow=0 if ///
	strpos(mother_adh_5pt_all, "2")
replace mother_adh_5pt_alllow=0 if ///
	strpos(mother_adh_5pt_all, "3")
label define mother_adh_5pt_alllow_lab 1"1. Consistently low" ///
	0"0. Not consistently low"
label val mother_adh_5pt_alllow mother_adh_5pt_alllow_lab
label var mother_adh_5pt_alllow "All 5 point scale measures are low"
tab mother_adh_5pt_alllow


* --> Dummy to capture those who move around (i.e. none of the above 3)
cap drop mother_adh_5pt_allvaries
gen mother_adh_5pt_allvaries= ///
	mother_adh_5pt_alllow==0 & mother_adh_5pt_allmed==0 ///
	& mother_adh_5pt_allhigh==0
replace mother_adh_5pt_allvaries=. if mother_adh_visits_total==0
label define mother_5ptscale_pn_allvar_lab 1"1. Varies" ///
	0"0. Does not vary"
label val mother_adh_5pt_allvaries mother_5ptscale_pn_allvar_lab
label var mother_adh_5pt_allvaries "5 point scale measures vary"
tab mother_adh_5pt_allvaries


* --> High, med, low and varied in one categorical variable
cap drop mother_adh_5pt_allcat
gen mother_adh_5pt_allcat=.
replace mother_adh_5pt_allcat=1 if mother_adh_5pt_alllow==1
replace mother_adh_5pt_allcat=2 if mother_adh_5pt_allmed==1
replace mother_adh_5pt_allcat=3 if mother_adh_5pt_allhigh==1
replace mother_adh_5pt_allcat=4 if mother_adh_5pt_allvaries==1
label def mother_adh_5pt_allcat_lab 1"1. All low" 2"2. All medium" ///
	3"3. All high" 4"4. Varies"
label val mother_adh_5pt_allcat mother_adh_5pt_allcat_lab
tab mother_adh_5pt_allcat if has_adh==1, m


* --> Dummy to capture those who start and end on low, medium and high
tab1 mother_adh_5pt_all if mother_adh_5pt_allcat==4, m
cap drop *digit
gen first_digit=substr(mother_adh_5pt_all,1,1) if mother_adh_5pt_allcat==4
gen last_digit=substr(mother_adh_5pt_all,-1,.) if mother_adh_5pt_allcat==4
destring *_digit, replace
foreach x in first last {
	forvalues i=1/3 {
		cap drop `x'`i'
		gen `x'`i'=`x'_digit==`i'
	}
}


* --> Identify those who are inconsistent
cap drop mother_adh_5pt_inconsist
gen mother_adh_5pt_inconsist=first_digit==1 & last_digit==1 if ///
	mother_adh_5pt_allcat==4
replace mother_adh_5pt_inconsist=first_digit==2 & last_digit==2 if ///
	mother_adh_5pt_allcat==4
replace mother_adh_5pt_inconsist=first_digit==3 & last_digit==3 if ///
	mother_adh_5pt_allcat==4
label var mother_adh_5pt_inconsist "5 point scale measures inconsistent"
tab mother_adh_5pt_inconsist
	// These people start and end on the same number but move about so I
	// can say they aren't consistently moving in one direction or not. This
	// really isn't great analysis because someone could have 10 measures of 
	// one value and one of another and we'll say they are inconsistent or
	// move down/up when really they are pretty much the same almost all of the
	// time. However, this is what we've done in previous years, so going to
	// stick with it.

	
* --> Identify those who move up and stay there
cap drop mother_adh_5pt_up
gen mother_adh_5pt_up=.
tab1 mother_adh_5pt_all if mother_adh_5pt_inconsist==0 & ///
	(first_digit==1 | first_digit==2) & (last_digit==2 | last_digit==3) & ///
	mother_adh_5pt_up!=1
replace mother_adh_5pt_up=inlist(mother_adh_5pt_all, ///
	"1133333", "1233333333", "13", "113", "133", "13333", "133333", "1333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"133333333333333", "1333333333333333", "133333333333333333", ///
	"133333333333333333", "22233333333333", "22333", "23", "233")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"123", "1233", "123333", "13", "133", "1333", "13333", "1333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"2333", "23333", "233333", "23333333", "23333333333333333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"2333333", "233333333", "233333333333", "233333333333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"1133", "113333333333", "12222", "1233333333333", "1233333333333333", ///
	"13333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"133333333", "1333333333", "13333333333", "133333333333", "133333333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"1333333333333", "133333333333333333333", ///
	"1333333333333333333333333333", "22223333", "223", "2233")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"223333", "22333333", "223333333", "22333333333", "2333333333", ///
	"23333333333333", "23333333333333333", "2333333333333333333")
replace mother_adh_5pt_up=1 if inlist(mother_adh_5pt_all, ///
	"2333333333333333333333", "23333333333333333333333")
tab mother_adh_5pt_up, m
tab1 mother_adh_5pt_all if mother_adh_5pt_up==1, m


replace mother_adh_5pt_inconsist=1 if mother_adh_5pt_inconsist==0 & ///
	(first_digit==1 | first_digit==2) & (last_digit==2 | last_digit==3) & ///
	mother_adh_5pt_up!=1
	// These are the 18 cases you see if you run the tab command just under the
	// previous heading.
	
	
* --> Identify those who move down and stay there
cap drop mother_adh_5pt_down
gen mother_adh_5pt_down=.
tab1 mother_adh_5pt_all if mother_adh_5pt_inconsist==0 & ///
	(first_digit==2 | first_digit==3) & (last_digit==1 | last_digit==2) & ///
	mother_adh_5pt_down!=1 & mother_adh_5pt_up!=1 & mother_adh_5pt_inconsist!=1
replace mother_adh_5pt_down=1 if inlist(mother_adh_5pt_all, ///
	"21", "31", "32", "322", "331", "331", "3311")
replace mother_adh_5pt_down=1 if inlist(mother_adh_5pt_all, ///
	"332", "3322", "3331", "3332", "33322", "33332", "33332")
replace mother_adh_5pt_down=1 if inlist(mother_adh_5pt_all, ///
	"33333311", "3333332", "33333332", "333333332", "3333333333332", ///
	"333333333333332", "3333333333333332", "333322")
replace mother_adh_5pt_down=1 if inlist(mother_adh_5pt_all, ///
	"3333333333333333332", "33333333333333333333333333332")
replace mother_adh_5pt_down=1 if inlist(mother_adh_5pt_all, ///
	"3222", "33331", "3333322", "3333333332", "333333333311", ///
	"33333333333333332", "3333333333333333333333333333332")

replace mother_adh_5pt_inconsist=1 if mother_adh_5pt_inconsist==0 & ///
	(first_digit==2 | first_digit==3) & (last_digit==1 | last_digit==2) & ///
	mother_adh_5pt_down!=1 & mother_adh_5pt_up!=1 & mother_adh_5pt_inconsist!=1
	// These are the 15 cases you see if you run the tab command just under the
	// previous heading.

	
* --> Assign last few to inconsistent group
tab1 mother_adh_5pt_all if mother_adh_5pt_inconsist==0 & ///
	(first_digit==2 | first_digit==3) & (last_digit==1 | last_digit==2) & ///
	mother_adh_5pt_down!=1 & mother_adh_5pt_up!=1 & mother_adh_5pt_inconsist!=1
replace mother_adh_5pt_inconsist=1 if ///
	mother_adh_5pt_alllow!=1 & ///
	mother_adh_5pt_allmed!=1 & ///
	mother_adh_5pt_allhigh!=1 & ///
	mother_adh_5pt_up!=1 & ///
	mother_adh_5pt_down!=1 & ///
	mother_adh_5pt_allcat==4
	
	
* --> Consistently high, med, low, up, down & varied in one categorical variable
cap drop mother_adh_5pt_allcat2
gen mother_adh_5pt_allcat2=.
replace mother_adh_5pt_allcat2=1 if mother_adh_5pt_alllow==1
replace mother_adh_5pt_allcat2=2 if mother_adh_5pt_allmed==1
replace mother_adh_5pt_allcat2=3 if mother_adh_5pt_allhigh==1
replace mother_adh_5pt_allcat2=4 if mother_adh_5pt_up==1
replace mother_adh_5pt_allcat2=5 if mother_adh_5pt_down==1
replace mother_adh_5pt_allcat2=6 if mother_adh_5pt_inconsist==1
label def mother_adh_5pt_allcat2_lab 1"All low" 2"All med" 3"All high" ///
	4"Move up" 5"Move down" 6"Inconsistent"
label val mother_adh_5pt_allcat2 mother_adh_5pt_allcat2_lab
numlabel, add force
label var mother_adh_5pt_allcat2 "Movement in 5 point scale over all visits"
tab mother_adh_5pt_allcat2 if has_adh_info==1, m
	// Those 9 are people who had information on 7 day recall but not 5 point
	// scale.
	



*------------------------------------------------------------------------------*
* Viral load testing

* --> Make all viral load dates numeric 
foreach x in an pn { 
	ds `x'_timeenddate*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		foreach j in test_done test_prev_done result_done result_prev_done ///
			result_prev_due result_due {
				gen `x'_viral`j'`i'=date(d`x'_vl_`j'_date`i', "YMD")
				replace `x'_viral`j'`i'=date(d`x'_vl_`j'_date`i', "DMY") if ///
					`x'_viral`j'`i'==.
				la var `x'_viral`j'`i' "Viral load `j' date, from `x' dataset"
				drop d`x'_vl_`j'_date`i'
		}
	}
}


* --> VL results
label def mother_vlres_cat_lab ///
	1"1. Not detectable" ///
	2"2. <1000" ///
	3"3. >=1000" ///
	4"4. Never tested"
label def mother_vlres_cat_lab2 ///
	1"1. Not detectable" ///
	2"2. <200" ///
	3"3. >=200" ///
	4"4. Never tested"

foreach x in an pn { 
	ds `x'_timeenddate*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		* Destring numeric test result
		foreach j in result_num result_prev_num {
			replace  d`x'_vl_`j'`i'="" if d`x'_vl_`j'`i'=="---"
			destring  d`x'_vl_`j'`i', gen(`x'_vl_`j'`i')
			la var `x'_vl_`j'`i' "Viral load number in data `x', obs `i'"
			drop d`x'_vl_`j'`i'
		}

	* Identify undetectable VL result
	cap drop `x'_vl_result_nd`i'
	gen `x'_vl_result_nd`i'=1 if ///
		d`x'_vl_result`i'=="undetectable" | ///
		d`x'_vl_result`i'=="suppressed"
	la var `x'_vl_result_nd`i' "`x' VL result `i' is non-detectable"
			
	cap drop `x'_vl_result_prev_nd`i'
	gen `x'_vl_result_prev_nd`i'=1 if ///
		d`x'_vl_result_prev`i'=="undetectable" | ///
		d`x'_vl_result_prev`i'=="suppressed" 
	la var `x'_vl_result_prev_nd`i' "`x' VL prev result `i' is non-detectable"
	
	* Categorical VL result v1 (suppression<1000)
	cap drop `x'_vltest`i'_result_cat
	gen `x'_vltest`i'_result_cat=.
	replace `x'_vltest`i'_result_cat=1 if `x'_vl_result_nd`i'==1
	replace `x'_vltest`i'_result_cat=2 if ///
		`x'_vl_result_num`i'>=0 & `x'_vl_result_num`i'<1000
	replace `x'_vltest`i'_result_cat=3 if ///
		`x'_vl_result_num`i'>1000 & `x'_vl_result_num`i'<.
	label var `x'_vltest`i'_result_cat "Mother VL test result `i' (categories)"
	label val `x'_vltest`i'_result_cat mother_vlres_cat_lab
	
	cap drop `x'_vltest`i'_prevresult_cat
	gen `x'_vltest`i'_prevresult_cat=.
	replace `x'_vltest`i'_prevresult_cat=1 if `x'_vl_result_prev_nd`i'==1
	replace `x'_vltest`i'_prevresult_cat=2 if ///
		`x'_vl_result_prev_num`i'>=0 & `x'_vl_result_prev_num`i'<1000
	replace `x'_vltest`i'_prevresult_cat=3 if ///
		`x'_vl_result_prev_num`i'>1000 & `x'_vl_result_prev_num`i'<.
	label var `x'_vltest`i'_prevresult_cat ///
		"Mother previous VL test result `i' (categories)"
	label val `x'_vltest`i'_prevresult_cat mother_vlres_cat_lab

	
	* Categorical VL result v1 (suppression<200)
	cap drop `x'_vltest`i'_result_cat22
	gen `x'_vltest`i'_result_cat22=.
	replace `x'_vltest`i'_result_cat2=1 if `x'_vl_result_nd`i'==1
	replace `x'_vltest`i'_result_cat2=2 if ///
		`x'_vl_result_num`i'>=0 & `x'_vl_result_num`i'<200
	replace `x'_vltest`i'_result_cat2=3 if ///
		`x'_vl_result_num`i'>200 & `x'_vl_result_num`i'<.
	label var `x'_vltest`i'_result_cat2 "Mother VL test result `i' (categories)"
	label val `x'_vltest`i'_result_cat2 mother_vlres_cat_lab2
	
	cap drop `x'_vltest`i'_prevresult_cat2
	gen `x'_vltest`i'_prevresult_cat2=.
	replace `x'_vltest`i'_prevresult_cat2=1 if `x'_vl_result_prev_nd`i'==1
	replace `x'_vltest`i'_prevresult_cat2=2 if ///
		`x'_vl_result_prev_num`i'>=0 & `x'_vl_result_prev_num`i'<200
	replace `x'_vltest`i'_prevresult_cat2=3 if ///
		`x'_vl_result_prev_num`i'>200 & `x'_vl_result_prev_num`i'<.
	label var `x'_vltest`i'_prevresult_cat2 ///
		"Mother previous VL test result `i' (categories)"
	label val `x'_vltest`i'_prevresult_cat2 mother_vlres_cat_lab2
	}
}


* --> Most recent test done date
cap drop mostrecent_vltest_done
egen mostrecent_vltest_done=rowmax(?n_viraltest_done* ?n_viraltest_prev_done*)
format %d mostrecent_vltest_done
label var mostrecent_vltest_done "Most recent VL test done date"
	
	
* --> Most recent result done date
cap drop mostrecent_vlresult_done
egen mostrecent_vlresult_done= ///
	rowmax(?n_viralresult_done* ?n_viralresult_prev_done*)
label var mostrecent_vlresult_done "Most recent VL result done date"
format %d mostrecent_vlresult_done
		

* --> Most recent VL result
gen mostrecent_vlresult=.
gen mostrecent_vlresult2=.
foreach x in an pn {
	ds `x'_timeenddate*
	local nvars: word count `r(varlist)'
	local nvars=`nvars'-1
	forvalues i=1/`nvars' {
		replace mostrecent_vlresult=`x'_vltest`i'_prevresult_cat if ///
			`x'_viralresult_prev_done`i'==mostrecent_vlresult_done 
		replace mostrecent_vlresult=`x'_vltest`i'_result_cat if ///
			`x'_viralresult_done`i'==mostrecent_vlresult_done 

		replace mostrecent_vlresult2=`x'_vltest`i'_prevresult_cat2 if ///
			`x'_viralresult_prev_done`i'==mostrecent_vlresult_done 
		replace mostrecent_vlresult2=`x'_vltest`i'_result_cat2 if ///
			`x'_viralresult_done`i'==mostrecent_vlresult_done 
	}
}
label val mostrecent_vlresult mother_vlres_cat_lab
label var mostrecent_vlresult "Most recent VL test result was suppressed"
label val mostrecent_vlresult2 mother_vlres_cat_lab2
label var mostrecent_vlresult2 "Most recent VL test result was suppressed v2"
tab1 mostrecent_vlresult*, m

gen mostrecent_vlresult_nomiss=mostrecent_vlresult
replace mostrecent_vlresult_nomiss=4 if mostrecent_vlresult==.
label val mostrecent_vlresult_nomiss mother_vlres_cat_lab
label var mostrecent_vlresult_nomiss "Most recent VL test result (all women)"

gen mostrecent_vlresult_nomiss2=mostrecent_vlresult2
replace mostrecent_vlresult_nomiss2=4 if mostrecent_vlresult2==.
label val mostrecent_vlresult_nomiss2 mother_vlres_cat_lab2
label var mostrecent_vlresult_nomiss2 "Most recent VL test result (all women) v2"
	
	

*------------------------------------------------------------------------------*
* Quarter in which infant due for 18-24 month test

gen t1824m_test_due_date=infant_dob+730
format %d t1824m_test_due_date 
label var t1824m_test_due_date "18-24m test due date (DOB+2 yrs)"

gen t1824m_test_due_month=mofd(t1824m_test_due_date)
format %tm t1824m_test_due_month

foreach x in 2018 2019 2020 {
	gen due_`x'q1=t1824m_test_due_month>=tm(`x'm1) & ///
		t1824m_test_due_month<=tm(`x'm3)
	gen due_`x'q2=t1824m_test_due_month>=tm(`x'm4) & ///
		t1824m_test_due_month<=tm(`x'm6)
	gen due_`x'q3=t1824m_test_due_month>=tm(`x'm7) & ///
		t1824m_test_due_month<=tm(`x'm9)
	gen due_`x'q4=t1824m_test_due_month>=tm(`x'm10) & ///
		t1824m_test_due_month<=tm(`x'm12)
}
replace due_2020q4=1 if t1824m_test_due_month>=tm(2021m1) & ///
		t1824m_test_due_month<=tm(2020m6)

tab1 due_2020q? if pn_any==1
tab1 due_2019q? if pn_any==1
tab1 due_2018q? if pn_any==1
	// All quarters before Q4 2018 have too small a sample size to be 
	// meaningful, so I am going to report 2017, 2018 and then each quarter
	// in 2019. That may not make sense per country though, except for
	// maybe Lesotho, because sample sizes will be too small.
	
gen due_2018=due_2018q1==1 | due_2018q2==1 | due_2018q3==1 | due_2018q4==1
gen due_2019=due_2019q1==1 | due_2019q2==1 | due_2019q3==1 | due_2019q4==1
gen due_2020=due_2020q1==1 | due_2020q2==1 | due_2020q3==1 | due_2020q4==1

tab due_2018 if pn_any==1
tab due_2019 if pn_any==1
tab1 due_2020q? if pn_any==1

tab due_2018 if pn_any==1
tab due_2019 if pn_any==1
tab due_2020 if pn_any==1
tab1 due_2020q? if pn_any==1

sort country
by country: tab due_2018 if pn_any==1
by country: tab due_2019 if pn_any==1
by country: tab due_2020 if pn_any==1
by country: tab1 due_2020q? if pn_any==1
	// Sample size large enough in Lesotho and SA for 2019 quarterly breakdown. 
	// Year breakdown for 2017 doesn't make sense for anyone.
	// Year breakdown for 2018 only makes sense for Lesotho.
	
gen due_year=2018 if due_2018==1
replace due_year=2019 if due_2019==1
replace due_year=2020 if due_2020==1 
tab due_year if pn_any==1, m	


	

*------------------------------------------------------------------------------*
* Save datasets for generating output

ren dexit_exitwhy exit_exitwhy
ren dnew_gestage_m2m new_gestage_m2m
drop dpn* dnew* dan* dexit* 
ren exit_exitwhy dexit_exitwhy
ren new_gestage_m2m dnew_gestage_m2m
save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric_final.dta", replace

	
* --> Erase intermediate datasets
foreach x in an pn exit {
	erase "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/`x'_ric.dta"
}
erase "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric1.dta"
erase "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric2.dta"
erase "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data/Early RIC/earlyric3.dta"

	
