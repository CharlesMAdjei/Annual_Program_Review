*** APR 2020 - PMTCT cascade
*** Create analysis dataset
* 19 Feb 2021


* --> Loop over both cohorts



clear all
set maxvar 32700
use "$data/vitol_cohort.dta", clear
cap drop *__00*
count
	// 2yr: 8048
	// 3yr: 5031

foreach x in an pn {
	ds `x'_hiv_status*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
	     replace `x'_hiv_status`i' = "1" if `x'_hiv_status`i' == "known_positive" | `x'_hiv_status`i' == "tested_positive" 
	     replace `x'_hiv_status`i' = "0" if `x'_hiv_status`i' == "negative"
	     replace `x'_hiv_status`i' = "-1" if `x'_hiv_status`i' == "unknown" 
	     destring `x'_hiv_status`i', replace
	}
}

egen hiv_status = rowlast(an_hiv_status* pn_hiv_status*)	
label define hiv_status -1 "unknown" 0 "negative" 1 "positive" 
label values hiv_status hiv_status
tab hiv_status facility, m
list new_client_type form_type hiv_status if hiv_status == -1
	// 63 clients in APC hiv_status was unknown. This was in the months of April and May when
	// we experience stock out of hiv test kits







*------------------------------------------------------------------------------*
* Label detail variables
/*
These are used to create the lists of clients missing key outcomes.
*/

label var first_timeend_date "First visit"
label var details_surname "Surname"
label var details_first_name "First name"
label var details_m2m_id "m2m ID"
label var details_national_id "National ID"
label var details_number_anc "ANC number"
label var details_physical_address "Home address"
label var details_phone_number "Phone number"




*------------------------------------------------------------------------------*
* Site type

gen site_type=.
replace site_type=1 if strpos(facility, "clinic")
replace site_type=2 if strpos(facility, "hc")
replace site_type=2 if strpos(facility, "health center")
replace site_type=2 if strpos(facility, "health centre")
replace site_type=2 if ///
	facility=="holy cross" | ///
	facility=="mofumahali oa rosari" | ///
	facility=="morifi" | ///
	facility=="sesote" | ///
	facility=="st monicas"
replace site_type=3 if strpos(facility, "hospital")
replace site_type=3 if facility=="khayelitsha site b mou" | ///
	facility=="michael mapongwana clinic" | facility=="soshanguve mou"
	// Advised by Kathrin to classify these as hospitals
	
replace site_type=1 if site_type==. & country=="zambia"
	// Advised by Owen that those that remained missing on this were all 
	// clinics.

replace site_type=2 if site_type==. & country=="malawi"
label def site_type 1"Clinic" 2"Health centre" 3"Hospital"
label val site_type site_type
tab country site_type, m
tab facility if site_type==.


	
	
*------------------------------------------------------------------------------*
* Identify clients according to AN/PN

* --> Identify AN versus PN etc
drop an pn
gen an=first_timeend_datean!=.
gen pn=first_timeend_datepn!=.
gen an_only=first_timeend_datean!=. & first_timeend_datepn==.
gen pn_only=first_timeend_datean==. & first_timeend_datepn!=.
gen an_pn=first_timeend_datean!=. & first_timeend_datepn!=.
gen an_any=an_only==1 | an_pn==1
gen pn_any=pn_only==1 | an_pn==1


* --> Variables for tables
gen retained=an_pn
label var retained "Client enrolled AN, retained PN"
tab retained, m

gen type=0 if an_only==1
replace type=1 if pn_only==1
replace type=2 if an_pn==1
label def type 0"AN only" 1"PN only" 2"AN+PN"
label val type type
label var type "AN / PN / AN+PN"
tab type, m

replace new_client_type = "an" if (type == 0 | type == 2) & new_client_type == ""
replace new_client_type = "pn" if type == 1 & new_client_type == ""




*------------------------------------------------------------------------------*
* Mother's age in various categories

* --> Various younger and older categories
gen ag=age>=10 & age<=19
la var ag "Adol. girl: 10-19"
gen ag_1519=age>=15 & age<=19
la var ag_1519 "Adol. girl: 15-19"
gen ag_1014=age>=10 & age<=14
la var ag_1014 "Adol. girl: 10-14"
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
label var agecat_agyw "Age categories def 1"
tab agecat_agyw, m

gen agecat_agyw2=1 if ag_1014==1
replace agecat_agyw2=2 if ag_1519==1
replace agecat_agyw2=3 if yw==1
replace agecat_agyw2=4 if ow==1
label def agecat_agyw2 1"Young adol (10-14)" 2"Older adol (15-19)" ///
	3" Young women (20-24)" 4"Older women (25+)"
label val agecat_agyw2 agecat_agyw2
label var agecat_agyw2 "Age categories def 2"
tab agecat_agyw2


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
tab new_gestage_units
tab new_gestage_anc1 if new_gestage_units=="months"
destring new_gestage_anc1, replace force
ren new_gestage_anc1 gestage_fac
tab gestage_fac
replace gestage_fac=round(gestage_fac*4.3, 1) if ///
	new_gestage_units=="months" & ///
	gestage_fac*4.3<40
		// Include the second condition because clearly some of those where they
		// said the unit was month was actually week because they end up 
		// having a gestage of 117 
		
replace gestage_fac=. if gestage<4
	// We always assume this is an error
	
tab gestage_fac if an_any==1, m
	// 560 AN-any clients are missing their gestage. 
	
	
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

ds pn_timeend_date*		
local nvars: word count `r(varlist)'
forvalues x=1/`nvars' {
	replace pn_fp_method`x'="" if pn_fp_method`x'=="---"
	gen condom`x'=pn_fp_condom`x'=="yes"
	gen imp`x'=pn_fp_method`x'=="implant"
	gen inj`x'=pn_fp_method`x'=="injection"
	gen iud`x'=pn_fp_method`x'=="iud"
	gen pill`x'=pn_fp_method`x'=="oral_contraceptives"
	gen tl`x'=pn_fp_method`x'=="sterilization"
	gen dual`x'=condom`x'==1 & pn_fp_method`x'!=""
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
	
gen has_partner=new_has_partner=="yes"
label var has_partner "Client has partner (from new client form)"
gen partner_status=0 if new_partner_status=="negative"
replace partner_status=1 if new_partner_status=="positive"
replace partner_status=2 if new_partner_status=="unknown"
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
*ren an_init_date* an_init_done_date*
ren pn_artprevrefill_done_date* pn_artrefill_prev_done_date*


* --> Make dates numeric
foreach x in an pn {
	ds `x'_timeend_date*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
		gen `x'_artstart_date`i'=date(`x'_init_done_date`i', "YMD") 
		replace `x'_artstart_date`i'=date(`x'_init_done_date`i', "DMY") if ///
			`x'_artstart_date`i'==.
		replace `x'_artstart_date`i'=. if `x'_artstart_date`i'>$end_period
		la var `x'_artstart_date`i' ///
			"ART start date, from `x' dataset, obs `i'" 
	
		gen `x'_artprevrefill_date`i'= ///
			date(`x'_artrefill_prev_done_date`i', "YMD")
		replace `x'_artprevrefill_date`i'= ///
			date(`x'_artrefill_prev_done_date`i', "DMY") if ///
			`x'_artprevrefill_date`i'==.
		replace `x'_artprevrefill_date`i'=. if ///
			`x'_artprevrefill_date`i'>$end_period
		la var `x'_artprevrefill_date`i' ///
			"ART previous refill done date, from `x' dataset, obs `i'"

		gen `x'_artrefill_date`i'=date(`x'_artrefill_done_date`i', "YMD")
		replace `x'_artrefill_date`i'= ///
			date(`x'_artrefill_done_date`i', "DMY") if ///
			`x'_artrefill_date`i'==.
		replace `x'_artrefill_date`i'=. if ///
			`x'_artrefill_date`i'>$end_period
		la var `x'_artrefill_date`i' ///
			"ART refill done date, from `x' dataset, obs `i'"
	}
}


* --> ART start date from new client form
tab new_init_date
gen double new_artstart_date=date(new_init_date, "YMD")
replace new_artstart_date=date(new_init_date, "DMY") if new_artstart_date==.
replace new_artstart_date=. if new_artstart_date>$end_period
format %d new_artstart_date
label var new_artstart_date "ART start date from new client form"

format %d new_artstart_date ?n_artstart_date* ?n_artrefill_date* ///
	?n_artprevrefill_date*


	
	
*------------------------------------------------------------------------------*
* ART start when 
	// Unlike in the MCC, "art start when" is not captured. I deduce it from the
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
	// A small number of women have different ART start dates in the data.
	

* --> Create single ART start date variable
gen artstart_date=new_artstart_date
ds an_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	forvalues j=1/`nvars'{
		replace artstart_date=an_artstart_date`i' if ///
			an_timeend_date`i'>=an_timeend_date`j' & ///
			an_timeend_date`i'<=$end_period & ///
			an_artstart_date`i'!=. 
	}
}
ds pn_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	forvalues j=1/`nvars'{
		replace artstart_date=pn_artstart_date`i' if ///
			pn_timeend_date`i'>=pn_timeend_date`j' & ///
			pn_timeend_date`i'<=$end_period & ///
			pn_artstart_date`i'!=.			
	}
}
	// This code takes the most recently entered date for ART initiation within
	// AN and PN form submissions separately. So if the ART start date changes
	// from one form submission to another in the AN or PN data, the code takes
	// the value entered into the most recent form.
	
format %d artstart_date
count if artstart_date!=new_artstart_date
	// 303 of ~4500 women have a difference between ART start date in
	// new client form and AN/PN form. Very small, not going to look further
	// into this.
	
count if artstart_date==.
	// 33 women missing an ART start date altogether.
/*
br artstart_date new_artstart_date artstart_date_m* if ///
	artstart_date!=new_artstart_date & new_artstart_date!=.
*/


* --> When started ART
gen edd=date(new_edd, "YMD") 
replace edd=date(new_edd, "DMY") if edd==.
format %d edd
label var edd "Expected date of delivery"
tab edd if an_only==1, m
	// Missing for 15% of AN-only clients
	
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
tab hiv_status artstart_when, m



*------------------------------------------------------------------------------*
* ART start (yes/no)

egen refill_done=rownonmiss(*artprevrefill_date* *artrefill_date*)
	// Identify clients with at least 1 ART refill date

gen artstart=(artstart_date!=. | refill_done>0)
label var artstart "Has started ART"
tab artstart, m
tab artstart hiv_status, m col
*--> Check for hiv positive clients not on ART (Check with MMs to verify this)
sort facility details_first_name details_surname
list facility details_surname details_first_name agecat_2  artstart ///
     hiv_status if artstart == 0 & hiv_status == 1





*------------------------------------------------------------------------------*
* Feeding
/*
On the MCC, they captured a separate element that was whether the baby was 
exclusively breastfed until 6 months or not. The app doesn't have this. It
collects feeding method at each visit. I have coded it so that only visits
where the infant is younger than 6 months are included in the calculation of
feeding method. However, what to do about the fact that we might only have 
feeding methods until 3 months old and then nothing recorded? If only BF
is recorded for those visits then my code will say they were excl. BF until 
6 months but we don't know what happened between 3 and 6 months old. I am 
just going to go with this method but mention the caveat in the presentation.
*/

ds pn_timeend_date*		
local nvars: word count `r(varlist)'
forvalues x=1/`nvars' {
	gen feed_method`x'=1 if pn_feed_current`x'=="excl_breastfeeding"
	replace feed_method`x'=2 if pn_feed_current`x'=="excl_formula"
	replace feed_method`x'=3 if pn_feed_current`x'=="mixed_feeding"
	replace feed_method`x'=. if pn_timeend_date`x'-infant_dob>6*30.5
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
tab1 ebf erf mf feed_6m if pn_any==1 & visits_pn>=2, m

gen excl_feeding=ebf==1 | erf==1
label var excl_feeding "EBF or ERF"
tab excl_feeding if pn_any==1, m
drop pn_feed* feed_method* pn_bf_ever* pn_bf_stop*




*------------------------------------------------------------------------------*
* NVP and CTX

* --> Make due and done dates numeric
ds pn_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	foreach x in nvp_due_date nvp_done_date ctx_due_date ctx_done_date {
		gen `x'`i'=date(pn_`x'`i', "YMD") 
		replace `x'`i'=date(pn_`x'`i', "DMY") if `x'`i'==. 
		replace `x'`i'=. if `x'`i'>$end_period
		format %d `x'`i'
		drop pn_`x'`i'
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

* --> Make test done dates numeric
	// Have to do test and result done dates separately because I didn't include
	// the result done dates for the non-first and last tests.
ds pn_timeend_date*
local nvars: word count `r(varlist)'
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
			gen `x'`i'=date(pn_`x'`i', "YMD") 
			replace `x'`i'=date(pn_`x'`i', "DMY") if `x'`i'==. 
			replace `x'`i'=. if `x'`i'>$end_period
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


* --> Make result done dates numeric
ds pn_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	foreach x in ///
		tbirth_result_done_date ///
		t68wk_result_done_date ///
		t10wk_result_done_date ///
		t1824m_result_done_date  {
			gen `x'`i'=date(pn_`x'`i', "YMD") 
			replace `x'`i'=date(pn_`x'`i', "DMY") if `x'`i'==. 
			replace `x'`i'=. if `x'`i'>$end_period
			format %d `x'`i'
	}
	la var tbirth_result_done_date`i' "Birth result done date, obs `i'"
	la var t68wk_result_done_date`i' "6-8 week result done date, obs `i'"
	la var t10wk_result_done_date`i' "10 week result done date, obs `i'"
	la var t1824m_result_done_date`i' "18-24 month result done date, obs `i'"
}


* --> Identify single done date per test (going to take the earliest one)
	// Doesn't really matter which date we take since we're not reporting
	// done on time, just done ever.
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	egen test_`x'_test_done_date_min= ///
		rowmin(t`x'_test_done_date? /*t`x'_test_done_date??*/ )
	label var test_`x'_test_done_date_min "Earliest `x' test done date"
	format %d test_`x'_*_done_date_min
}


* --> Test result
ds pn_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
		gen test_`x'_result`i'=1 if pn_t`x'_result`i'=="positive"
		replace test_`x'_result`i'=0 if pn_t`x'_result`i'=="negative"
	}
}


* --> Check for clients with multiple results for same test
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	egen test_`x'_result_min=rowmin(test_`x'_result*)
	egen test_`x'_result_max=rowmax(test_`x'_result*)
	count if test_`x'_result_min!=test_`x'_result_max
}
/*
sort id 
br id test_68wk_result* if test_68wk_result_min!=test_68wk_result_max
*/
	// There are a small number of cases of one infant having two diff
	// results for their test. I will include these infants in a list for
	// country teams to check MCCs/facility records. This will be part of
	// the process where they look for missing test results for other infants.
	// Last year I assumed all of these infants were actually positive but that
	// was decided before we thought about asking countries to check other
	// sources for missing information. I 
	
	
* --> Single test result variable for each test
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	gen test_`x'_result=.
	label var  test_`x'_result "Most recent `x' test result entered in app"
	ds pn_timeend_date*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
		forvalues j=1/`nvars'{
			replace test_`x'_result=test_`x'_result`i' if ///
				pn_timeend_date`i'>=pn_timeend_date`j' & ///
				pn_timeend_date`i'<=. & ///
				test_`x'_result`i'!=.			
		}
	}
}
	// This code takes the most recently entered test result and sticks it in
	// a new variable. This code will work if and when new data is brought in
	// via corections entered into the app.

/*
sort id 
br id test_68wk_result test_68wk_result? test_68wk_result?? ///
	if test_68wk_result_min!=test_68wk_result_max
*/
	

* --> Put birth and 10 week results into the 6-8 week variable so I have a 
*	  single variable for first test (SA does those two tests)
replace test_68wk_result=test_birth_result if ///
	test_68wk_result==. & test_birth_result!=.
replace test_68wk_result=test_10wk_result if ///
	test_68wk_result==. & test_10wk_result!=.
tab test_68wk_result if pn_any==1 & visits_pn>=2, m


* --> Test done
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	cap drop test_`x'_done
	gen test_`x'_done=(test_`x'_result!=. | test_`x'_test_done_date_min!=.)
	replace test_`x'_done=. if an_only==1
	label var test_`x'_done "`x' test done"
}
tab1 test_*_done if pn_any==1 & visits_pn>=2 & hiv_status == 1, m


* --> Has test result
foreach x in 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	gen has_test`x'_result=test_`x'_result!=.
	label var has_test`x'_result "Has `x' test result"
	tab1 test_`x'_done has_test`x'_result if pn_any==1 & visits_pn>=2, m
}


* --> Identify infants too young to be included in final test stats
/*
In line with previous years, exclude infants who were younger than 24 months old 
by 1 Nov 2021 if they had not yet done the test.
*/
gen nov2021=td(01nov2021)
gen age_nov2021=round((nov2021-infant_dob)/30.5, 0.01) 
cap drop infant_tooyoung
gen infant_tooyoung=age_nov2021<24
replace infant_tooyoung=0 if test_1824m_done==1
tab infant_tooyoung if pn_any==1 & visits_pn>=2, m
	// More than half of the 2 year cohort is too young for the final test.

	
* --> Identify infants too young to be included in first test stats
/*
No infants should be too young for this. At the youngest, they would be about
8-9 months old, assuming the mother enrolled on 30 June 2019 having just 
conceived. However, there are of course some weird DOBS, including infants
born after Nov 2020. Oy vey.
*/

list age_nov2021 test_68wk_done if age_nov2021<8
tab test_68wk_done if age_nov2021<8 & pn_any==1 & hiv_status == 1, m
	// 2 yr cohort: Very few infants are marked as younger than 8 months so 
	// going to leave it as is.
	// 3 yr cohort: None.
	
	
	

*------------------------------------------------------------------------------*
* Tested positive before enrolling with m2m
/*
When calculating the transmission rates, we exclude those who tested positive
at or before enrolment with m2m. This means looking at all test results, not 
just first and last.
*/

* --> Ever tested positive
cap drop ever_pos
egen ever_pos=rowmax(test_*_result)
label var ever_pos "Infant ever tested positive"
tab ever_pos
	// This variable uses the most recently entered test result within each
	// test, so this means that it will account for corrections to test
	// results made once we send lists to countries. However, it won't correct
	// for an infant having a positive result on a test at one age and negative 
	// on a later one. We go with the conservative approach and take any 
	// positive result entered - this was the approach in previous years.
	

* --> Test date of the test where a positive result was obtained 
foreach x in birth 68wk 10wk 14wk 9m 10m 12m 13m 1824m {
	cap drop test_`x'_test_done_date_minx
	gen test_`x'_test_done_date_minx= ///
		test_`x'_test_done_date_min if test_`x'_result==1
}  
	// We identify only dates that have a positive result associated with them.
	

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
	
label def when_testpos_lab ///
	1"1. Tested pos before enrol" ///
	2"2. Tested pos at enrol" ///
	3"3. Tested pos after enrol"
label val when_testpos when_testpos_lab
tab when_testpos if ever_pos==1, m




*------------------------------------------------------------------------------*
* Infant final status

cap drop infant_status
gen infant_status=test_1824m_result 
replace infant_status=1 if ever_pos==1
replace infant_status=2 if infant_status==. & pn_any==1
label def status 0"Neg" 1"Pos" 2"No final status"
label val infant_status status
label var infant_status "Final infant status"
tab infant_status if pn_any==1 & visits_pn>=2 & infant_tooyoung!=1, m
	// 2yr cohort: 18% of eligible infants are missing final test result
	// 3yr cohort: 47% of eligible infants are missing final test result
	

* --> Infant has a final status
gen has_infant_status=infant_status<=1 if pn_any==1
label def has_infant_status_lab 1"1. Has a final infant_status" ///
	0"0. Does not have a final infant_status"
label val has_infant_status has_infant_status_lab
	
		
* --> Final status excluding those testing positive before or at enrolment
cap drop infant_status_postenrol
gen infant_status_postenrol=infant_status
replace infant_status_postenrol=. if when_testpos<3
label var infant_status_postenrol "Infant status excl those pos before/at enrol"
label val infant_status_postenrol status
tab infant_status_postenrol if pn_any==1 & visits_pn>=2 & ///
	infant_tooyoung!=1 & when_testpos>=3, m

		
		

*------------------------------------------------------------------------------*
* Infant ART start

* --> Make infant ART done dates numeric
ds pn_timeend_date*
local nvars: word count `r(varlist)'
forvalues i=1/`nvars' {
	foreach j in due done {
		gen infant_artinit`j'`i'=date(pn_infant_init_`j'_date`i', "YMD")
		replace infant_artinit`j'`i'= ///
			date(pn_infant_init_`j'_date`i', "DMY") if ///
			infant_artinit`j'`i'==.
		replace infant_artinit`j'`i'=. if ///
			infant_artinit`j'`i'>$end_period
		la var infant_artinit`j'`i' "Infant ART initiation `j' date, obs `i'"

		gen infant_artprevrefill`j'`i'= ///
			date(pn_infant_art_prev_`j'_date`i',"YMD")
		replace infant_artprevrefill`j'`i'= ///
			date(pn_infant_art_prev_`j'_date`i',"DMY") if ///
			infant_artprevrefill`j'`i'==.
		replace infant_artprevrefill`j'`i'=. if ///
			infant_artprevrefill`j'`i'>$end_period
		la var infant_artprevrefill`j'`i' ///
			"Infant ART previous refill `j' date, obs `i'"

		gen infant_artrefill`j'`i'=date(pn_infant_art_`j'_date`i',"YMD")
		replace infant_artrefill`j'`i'= ///
			date(pn_infant_art_`j'_date`i',"DMY") if ///
			infant_artrefill`j'`i'==.
		replace infant_artrefill`j'`i'=. if ///
			infant_artrefill`j'`i'>$end_period
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
	// 3yr cohort: 17 infants missing ART start
	



*------------------------------------------------------------------------------*
* Has adherence information

* --> Make adherence measures numeric
label define adh_5pt 1"Low adherence" 2"Moderate adherence" 3"High adherence"
label define adh_7day 1"<80%" 2"80-94.9%" 3"95-100%"
foreach x in an pn { 
	ds `x'_timeend_date*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
		ren `x'_adh_5pt`i' adh_5pt`i'_`x'
		gen `x'_adh_5pt`i'=1 if adh_5pt`i'_`x'=="low_adherence"
		replace `x'_adh_5pt`i'=2 if adh_5pt`i'_`x'=="moderate_adherence"
		replace `x'_adh_5pt`i'=3 if adh_5pt`i'_`x'=="high_adherence"
		label val `x'_adh_5pt`i' adh_5pt

		ren `x'_adh_7day`i' adh_7day`i'_`x'
		gen `x'_adh_7day`i'=1 if adh_7day`i'_`x'=="less_than_80"
		replace `x'_adh_7day`i'=2 if adh_7day`i'_`x'=="80_949"
		replace `x'_adh_7day`i'=3 if adh_7day`i'_`x'=="95_100"
		label val `x'_adh_7day`i' adh_7day
	}
}
	
	
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
In 2016-2018, we had a continuous variable for 7 day recall (a number
out of 7 that is the number of doses taken in the last week). This year we
only have a categorical variable. We used to take the average of the continuous
variable and stick that into categories. Last year and again this year, I take
the average of the values (1, 2 and 3) and see where they stand. 
*/

* --> Average the values of the categories.
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
	// 642 of 4753 women have an inbetween value.
	
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
Still to work out an efficient way to do this given all the different 
permutations.
*/

* --> Variable to capture all 5 point scale measures
cap drop mother_adh_5pt_all
egen mother_adh_5pt_all=concat(?n_adh_5pt? /*?n_adh_5pt??*/ )
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
	// These are the 47 cases you see if you run the tab command just under the
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

	
* --> Check if all assigned to a category
cap drop adh_5pt_categories
egen adh_5pt_categories=rowtotal( ///
	mother_adh_5pt_allh mother_adh_5pt_allm mother_adh_5pt_alllow ///
	mother_adh_5pt_inconsist mother_adh_5pt_down mother_adh_5pt_up)
tab adh_5pt_categories, m
tab mother_adh_5pt_all if adh_5pt_categories==0, m 
	// These are inconsistent so assign to that group in section below.

	
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


* --> Checks
assert mother_adh_5pt_all=="" if mother_adh_5pt_allcat2==.
	// Those missing on the categorical variable are the clients with no
	// 5pt scale measures at all.
	
tab mother_adh_5pt_allcat2 if has_adh_info==1, m
sum mother_adh_7day_mean if mother_adh_5pt_allcat2==. & has_adh_info==1
	// 11 clients are marked as having adherence information but no value for
	// the 5pt scale categorical variable because they had information on 7 day 
	// recall but not 5 point scale.

*/


*------------------------------------------------------------------------------*
* Viral load testing

* --> Make all viral load dates numeric 
foreach x in an pn { 
	ds `x'_timeend_date*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
		foreach j in test_done test_prev_done result_done result_prev_done ///
			result_prev_due result_due {
				gen `x'_viral`j'`i'=date(`x'_vl_`j'_date`i', "YMD")
				replace `x'_viral`j'`i'=date(`x'_vl_`j'_date`i', "DMY") if ///
					`x'_viral`j'`i'==.
				replace `x'_viral`j'`i'=. if `x'_viral`j'`i'>$end_period
				la var `x'_viral`j'`i' "Viral load `j' date, from `x' dataset"
				drop `x'_vl_`j'_date`i'
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
	ds `x'_timeend_date*
	local nvars: word count `r(varlist)'
	forvalues i=1/`nvars' {
		* Destring numeric test result
		foreach j in result_num result_prev_num {
			replace `x'_vl_`j'`i'="" if `x'_vl_`j'`i'=="---"
			ren `x'_vl_`j'`i' vl_`j'`i'_`x'
			destring  vl_`j'`i'_`x', gen(`x'_vl_`j'`i')
			la var `x'_vl_`j'`i' "Viral load number in data `x', obs `i'"
			drop vl_`j'`i'_`x'
		}

	* Identify undetectable VL result
	cap drop `x'_vl_result_nd`i'
	gen `x'_vl_result_nd`i'=1 if ///
		`x'_vl_result`i'=="undetectable" | ///
		`x'_vl_result`i'=="suppressed"
	la var `x'_vl_result_nd`i' "`x' VL result `i' is non-detectable"
			
	cap drop `x'_vl_result_prev_nd`i'
	gen `x'_vl_result_prev_nd`i'=1 if ///
		`x'_vl_result_prev`i'=="undetectable" | ///
		`x'_vl_result_prev`i'=="suppressed" 
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
	ds 	`x'_timeend_date*
	local nvars: word count `r(varlist)'
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
tab mostrecent_vlresult_nomiss, m

gen mostrecent_vlresult_nomiss2=mostrecent_vlresult2
replace mostrecent_vlresult_nomiss2=4 if mostrecent_vlresult2==.
label val mostrecent_vlresult_nomiss2 mother_vlres_cat_lab2
label var mostrecent_vlresult_nomiss2 "Most recent VL test result (all women) v2"
	
	
	
/*
*------------------------------------------------------------------------------*
* Quarter in which infant due for 18-24 month test

gen t1824m_test_due_date=infant_dob+730
format %d t1824m_test_due_date 
label var t1824m_test_due_date "18-24m test due date (DOB+2 yrs)"

gen t1824m_test_due_month=mofd(t1824m_test_due_date)
format %tm t1824m_test_due_month

foreach x in 2019 2020 2021 {
	gen due_`x'q1=t1824m_test_due_month>=tm(`x'm1) & ///
		t1824m_test_due_month<=tm(`x'm3)
	gen due_`x'q2=t1824m_test_due_month>=tm(`x'm4) & ///
		t1824m_test_due_month<=tm(`x'm6)
	gen due_`x'q3=t1824m_test_due_month>=tm(`x'm7) & ///
		t1824m_test_due_month<=tm(`x'm9)
	gen due_`x'q4=t1824m_test_due_month>=tm(`x'm10) & ///
		t1824m_test_due_month<=tm(`x'm12)
}
replace due_2021q4=1 if t1824m_test_due_month>=tm(2022m1) & ///
		t1824m_test_due_month<=tm(2022m6)

tab1 due_2021q? if pn_any==1
tab1 due_2020q? if pn_any==1
tab1 due_2019q? if pn_any==1
	// All quarters before Q4 2018 have too small a sample size to be 
	// meaningful, so I am going to report 2017, 2018 and then each quarter
	// in 2019. That may not make sense per country though, except for
	// maybe Lesotho, because sample sizes will be too small.
	
gen due_2019=due_2019q1==1 | due_2019q2==1 | due_2019q3==1 | due_2019q4==1
gen due_2020=due_2020q1==1 | due_2020q2==1 | due_2020q3==1 | due_2020q4==1
gen due_2021=due_2021q1==1 | due_2021q2==1 | due_2021q3==1 | due_2021q4==1

tab due_2019 if pn_any==1
tab due_2020 if pn_any==1
tab due_2021 if pn_any==1
tab1 due_2021q? if pn_any==1

sort country
by country: tab due_2021 if pn_any==1
by country: tab due_2020 if pn_any==1
by country: tab due_2019 if pn_any==1
by country: tab1 due_2021q? if pn_any==1
	
gen due_year=2019 if due_2019==1
replace due_year=2020 if due_2020==1
replace due_year=2021 if due_2021==1 
tab due_year if pn_any==1, m	
count if infant_dob!=. & due_year==. & pn_any==1
tab infant_dob if infant_dob!=. & due_year==. & pn_any==1
	// While these infants have a DOB, it doesn't make sense in terms of the
	// cohort. Most are in 2015, meaning they turned 2 in 2017, before they
	// enrolled. One is in 2019, which is too late given how long after the
	// enrolment period of first half of 2018 that is. Must be mistakes.
	
*/
	

*------------------------------------------------------------------------------*
* Save datasets for generating output

foreach x in an_any pn_any an_pn {
	ren `x' x_`x'
}


drop pn_* an_* infant_artref*  infant_artprevref*  infant_artinit* ///
	tbirth* t68wk* t10wk* t14wk* t9m* t10m* t12m* t13m* t1824m* ///
	test_*_result? /*test_*_result??*/ ///
	nvp_due_date* nvp_done_date* ctx_due_date* ctx_done_date* ///
	adh_7day?_?n /*adh_7day??_?n*/ adh_5pt?_?n /*adh_5pt??_?n*/      ///
	pill? /*pill??*/ condom? /*condom??*/ dual? /*dual??*/ imp? /*imp??*/ inj?  ///
	/*tl? tl??*/ iud? 
	

foreach x in an_any pn_any an_pn {
	ren x_`x' `x'
}

save "$data/vitol_cohort_all.dta", replace


preserve
keep if an_any==1
save "$data/vitol_cohort_an_any.dta", replace
restore

preserve 
keep if pn_any==1
save "$data/vitol_cohort_pn_any.dta", replace
restore

preserve 
keep if an_pn==1
save "$data/vitol_cohort_an_pn.dta", replace
restore


