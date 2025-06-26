
* This do file uses a date that's prepared by Clare in wide format. All the App1
* data files are cleaned, merged/appended. 

* This code estimate the RIC using App1 data

clear mata
discard
set maxvar 32700
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\cohort_3yr_reduced.dta", clear
 
* Reshape to long format
*-----------------------
 
reshape long an_init_date pn_init_done_date an_artrefill_prev_done_date /// 
an_artrefill_due_date pn_artrefill_done_date pn_artprevrefill_done_date  /// 
pn_infant_art_prev_done_date pn_infant_init_done_date pn_infant_art_done_date  /// 
an_anvisit2_done_date an_anvisit3_done_date an_artrefill_done_date /// 
an_anvisit4_done_date , i(id) j(visit) 


save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\RIC-longformartdata_v1.dta", replace

* Date variabes cleaning
*-----------------------
clear mata
set maxvar 32700
use  "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\RIC-longformartdata_v1.dta", clear

*dropping clients with single contact
* drop if visits_total ==1
*drop if visits_an ==1 
*drop if visits_pn ==1 
* Generate site calssification
*gen site_classification = 1 if country == 1
*replace site_classification = 1 if facility == "khayelitsha site b mou" ///
*| facility == "michael mapongwana clinic" | facility == "town 2 clinic"
*replace site_classification = 1 if facility == "dark city clinic" | ///
*facility == "soshanguve mou"
*replace site_classification = 2 if facility == "letlhabile clinic"
*-------------------------------------------------------------------------------
* Destring Exit variable
replace exit_exitwhy = "1" if exit_exitwhy == "baby_deceased"
replace exit_exitwhy = "2" if exit_exitwhy == "client_deceased"
replace exit_exitwhy = "2" if exit_exitwhy == "deceased"
replace exit_exitwhy = "3" if exit_exitwhy == "graduated"
replace exit_exitwhy = "4" if exit_exitwhy == "lost_to_follow-up"
replace exit_exitwhy = "4" if exit_exitwhy == "ltfu"
replace exit_exitwhy = "5" if exit_exitwhy == "miscarried"
replace exit_exitwhy = "6" if exit_exitwhy == "moved"
replace exit_exitwhy = "7" if exit_exitwhy == "transferred"
destring exit_exitwhy , replace 
label define exit_exitwhy 1 "Baby_deceased" 2 "Client_deceased" 3 ///
"Graduated" 4 "LTFU" 5 "Miscarried" 6 "Moved" 7 "Transferred"
label values exit_exitwhy exit_exitwhy
*-------------------------------------------------------------------------------

*replace an_anvisit2_done = "." if an_anvisit2_done == "---"
*replace an_anvisit3_done = "." if an_anvisit3_done == "---"
*replace an_anvisit4_done = "." if an_anvisit4_done == "---"
*destring an_anvisit2_done an_anvisit3_done an_anvisit4_done, replace


gen an_anvisit2 = date(an_anvisit2_done_date , "YMD")
gen an_anvisit3 = date(an_anvisit3_done_date , "YMD")
gen an_anvisit4 = date(an_anvisit4_done_date , "YMD")
*-------------------------------------------------------------------------------
* Clean enrol and init visit
gen enrol_date = date(new_enrol_date , "YMD")
gen init_date = date(new_init_date , "YMD")
gen init_date_an = date(an_init_date, "YMD")
gen init_done_date_pn = date(pn_init_done_date, "YMD")
gen artrefill_prev_done_date_an = date(an_artrefill_prev_done_date, "YMD")
gen artrefill_due_date_an = date(an_artrefill_due_date, "YMD")
gen artrefill_done_date_pn = date(pn_artrefill_done_date, "YMD")
gen artprevrefill_done_date_pn = date(pn_artprevrefill_done_date, "YMD")
gen infant_art_prev_done_date_pn = date(pn_infant_art_prev_done_date, "YMD")
gen infant_init_done_date_pn = date(pn_infant_init_done_date,"YMD")
gen infant_art_done_date_pn = date(pn_infant_art_done_date, "YMD")
gen artrefill_done_date_an = date(an_artrefill_done_date, "YMD")
gen exit_time = exit_timestart_date
*-------------------------------------------------------------------------------
* Format dates variables
format %td enrol_date init_date init_date_an init_done_date_pn artrefill_prev_done_date_an ///
artrefill_due_date_an artrefill_done_date_pn artprevrefill_done_date_pn ///
infant_art_prev_done_date_pn infant_init_done_date_pn infant_art_done_date_pn ///
artrefill_done_date_an exit_time an_anvisit2 an_anvisit3 an_anvisit4


/*init_date_an init_done_date_pn artrefill_prev_done_date_an /// 
artrefill_due_date_an artrefill_done_date_an artprevrefill_done_date_an  /// 
infant_art_prev_done_date_pn infant_init_done_date_pn infant_art_done_date_pn  /// 
an_anvisit2_done_date an_anvisit3_done_date /// 
an_anvisit4_done_date */
*-------------------------------------------------------------------------------
* Treatment history (Naive and Non Naive clients)
gen treat_hist = 0 if init_date >= date("01jan2018", "DMY") & init_date!=.
replace treat_hist = 1 if init_date < date("01jan2018", "DMY") & init_date!=.
label define treat_hist 0 "Naive" 1 "Non Naive"
label values treat_hist treat_hist
*-------------------------------------------------------------------------------
* rename first and last visit variables
rename first_timeend_datenew first_visit_date
rename mostrecent_timeend_date last_visit_date 
*replace last_visit_date = mostrecent_timeenddatepn ///
*if mostrecent_timeenddatepn>last_visit_date  & mostrecent_timeenddatepn!=.

gen visit_date = first_visit_date if visit == 1
format %td visit_date 

replace  enrol_date = visit_date if enrol_date==.
replace  init_date = enrol_date if init_date==.
*-------------------------------------------------------------------------------
* Destring variables
*-------------------
replace  new_gestage_m2m = "." if  new_gestage_m2m == "---"
destring  new_gestage_m2m, replace 

*HIV status
rename new_hiv_status hiv_status
replace hiv_status = "1" if hiv_status == "known_positive"
replace hiv_status = "2" if hiv_status == "tested_positive"
destring hiv_status, replace 
label define hiv_status 1 "known_positive" 2 "tested_positive"
label values hiv_status hiv_status
* Countries
replace country = "1" if country == "lesotho"
replace country = "2" if country == "south africa"
replace country = "3" if country == "uganda"
destring country , replace 
label define country 1 "Lesotho" 2 "South Africa" 3 "Uganda"
label values country country
*-------------------------------------------------------------------------------
* Age group (AGYW)
gen agecat_agyw = 0 if age>=15 & age <= 24
replace agecat_agyw = 1 if agecat_agyw==.
label define agecat_agyw 0 "15-24" 1 ">24"
label values agecat_agyw agecat_agyw

gen beg_month =td(01jan2018)
gen infant_age = (beg_month - infant_dob)/365 
replace infant_age=. if infant_age<0
*-------------------------------------------------------------------------------
* Consider AN any (AN+PN)
* Generating expected date of exit in the m2m program (EDD + 18 months) 
* minus 89 days
gen edd = date(new_edd, "YMD")
format edd %td
gen expect_m2m_exit_date= edd + (18*30)-89
format expect_m2m_exit_date %td

replace expect_m2m_exit_date=(infant_dob+(18*30))-89 ///
if expect_m2m_exit_date==. & infant_dob!=.

bys id: egen expect_m2m_exit_date1= max(expect_m2m_exit_date)
drop expect_m2m_exit_date
rename expect_m2m_exit_date1 expect_m2m_exit_date
format expect_m2m_exit_date %td

* Generating first and last pick-up date
egen pick_up_dates = rowmax(init_date artrefill_prev_done_date_an artrefill_done_date_pn ///
artrefill_done_date_an artrefill_done_date_pn)
format %td pick_up_dates
bys id (pick_up_dates ): egen pickup_date_last=lastnm(pick_up_dates)
format %td pickup_date_last

bys id (pick_up_dates): egen pickup_date_first=first(pick_up_dates)
format pickup_date_first %td


*Generating RIC variable
*gen ric=1 if pickup_date_last>expect_m2m_exit_date & pickup_date_last!=.
*replace ric=0 if ric==.


gen ric1=1 if last_visit_date>=(expect_m2m_exit_date) & last_visit_date!=.
replace ric1=0 if ric1==.
*-------------------------------------------------------------------------------
* Distribution of eligible records by country and treatment history 
*------------------------------------------------------------------

tab country treat_hist if visit == 1, col 

*-------------------------------------------------------------------------------
* How long do the clients take to initiate ART treatment since enrolled
*-------------------------------------------------------------------

gen how_long_initiated = (init_date - enrol_date)/30 if enrol_date != . 
replace how_long_initiated  = -(how_long_initiated ) ///
if (how_long_initiated  > -3 & how_long_initiated  < 0)
format %7.3g how_long_initiated

* count unique number of clients started ART at specific time point
egen initiated_num_unique=tag(id how_long_initiated)
gen initiated_ric_3m = 1 if how_long_initiated <= 3.5 & initiated_num_unique ==1 & how_long_initiated >=0 
replace initiated_ric_3m  = 0 if (initiated_ric_3m ==. & how_long_initiated != .)
* Initiated treatment within 3 months since joined M2M
*Numerator
tab country initiated_ric_3m if treat_hist == 0  ///
& initiated_num_unique == 1 & init_date  >= date("01jan2018", "DMY")
*Denominator (same as if we included AN Any)
tab country if treat_hist == 0  & visit == 1 & init_date  >= date("01jan2018", "DMY")

* Retained at three months on ART after ainitaited ART within 3m
gen retained_3m = 1 if initiated_ric_3m == 1 & how_long_initiated <= 3.5 & how_long_initiated >= 0
*& ric_3mths==1

* count unique number of clients started ART at specific time point
egen retained_num_unique=tag(id retained_3m)
*Numerator
tab country retained_3m if treat_hist == 0  & retained_num_unique == 1 
*Denominator
tab country if treat_hist == 0  & visit == 1 

* Retained at three months on ART after ainitaited ART within 3m (Another way)

gen ric_within3m=1 if ((init_date- enrol_date)>=((3*30.4)-89) ///
| ((init_date- enrol_date) > 0 | (init_date- enrol_date) <= 3)) & init_date!=.
replace ric_within3m=0 if ric_within3m==.
* count unique number of clients started ART at specific time point
egen retained_num_unique_within3m=tag(id  ric_within3m)


tab country ric_within3m if retained_num_unique == 1 & treat_hist == 0 

tab country if visit == 1 & treat_hist == 0 

*-------------------------------------------------------------------------------
* How long do the infant take to initiate ART treatment since birth
*-------------------------------------------------------------------
gen how_long_initiated_infant = (infant_init_done_date_pn - infant_dob)/30 if infant_init_done_date_pn  != . 
replace how_long_initiated_infant  = -(how_long_initiated_infant ) ///
if (how_long_initiated_infant  > -3 & how_long_initiated_infant  < 0)
format %7.3g how_long_initiated_infant

* count unique number of clients started ART at specific time point
egen initiated_num_unique_infant=tag(id how_long_initiated_infant)
gen initiated_ric_3m_infant = 1 if how_long_initiated_infant <= 3.5 & initiated_num_unique_infant ==1 & how_long_initiated_infant >=0 
replace initiated_ric_3m_infant  = 0 if (initiated_ric_3m_infant ==. & how_long_initiated_infant != .)
* Initiated treatment within 3 months since joined M2M
*Numerator
tab country initiated_ric_3m_infant if treat_hist == 0  ///
& initiated_num_unique_infant == 1 & infant_init_done_date_pn  >= date("01jan2018", "DMY")
*Denominator (same as if we included AN Any)
tab country if treat_hist == 0  & visit == 1 & infant_init_done_date_pn  >= date("01jan2018", "DMY") & infant_age <= 6
*-------------------------------------------------------------------------------
* Consider AN any (AN+PN) (consider also last visit date)
* RIC for AN in months
*---------------------
gen an_ric = (artrefill_done_date_an - init_date_an)/30
replace an_ric = (artrefill_prev_done_date_an  - init_date_an)/30 /// 
if artrefill_done_date_an == .
replace an_ric = 1000 if an_ric == .
gen yr_an = year(artrefill_done_date_an) 
replace yr_an = year(artrefill_prev_done_date_an) if artrefill_done_date_an == .

/*
* RIC for PN in months
*---------------------
gen pn_ric = (pn_artrefill_date - pn_artstart_date)/30
replace pn_ric = (pn_artprevrefill_date  - pn_artstart_date)/30 /// 
if pn_artrefill_date == .
replace pn_ric = 1000 if pn_ric == .
gen yr_pn = year(pn_artrefill_date ) 
replace yr_pn = year(pn_artprevrefill_date) if pn_artrefill_date == .
*/
*-------------------------------------------------------------------------------
*Retention at delivery 
*---------------------
* This will be estimated using the infant DOB
gen delivery_art = (infant_dob - init_date_an)/30 if init_date_an!=.
gen delivery_ric = 1 if delivery_art > 0  & visit == 1 & delivery_art !=.
* check if the client has a refill date at delivery
gen delivery_art_refill = (infant_dob - artrefill_done_date_an )/30 if artrefill_done_date_an!=.
gen delivery_ric_refill = 1 if delivery_art_refill > 0 & visit == 1
replace delivery_ric = delivery_ric_refill if (delivery_ric_refill == 1 & ///
delivery_ric == .)

* Consider AN any (AN+PN)
* Retained in care at delivery 
*-----------------------------
*Naive clients
*--------------
*Numerator
tab country delivery_ric if treat_hist == 0 & visit == 1 
*Denominator
tab country if treat_hist == 0  & visit == 1 


* Consider AN any (AN+PN)
* All m2m HIV+ve clients
*-----------------------
*Numerator
tab country delivery_ric if visit == 1 , col 
*Denominator
tab country if visit == 1 
* there are two clients who didn't retained (1 in Lesotho and 1 on SA)
*-------------------------------------------------------------------------------
*Generating RIC variable
*-------------------------------------------------------------------------------
* 3m RIC
gen ric_3mths=1 if ((pickup_date_last - init_date )>=((3*30.4)-89) ///
| (pickup_date_last - init_date ) ==0) & pickup_date_last !=. & enrol_date!=.
replace ric_3mths=0 if ric_3mths==.
*percentage of RIC 3 mnths
tab country ric_3mths if visit ==1 ,row 

* 6m RIC
gen ric_6mths=1 if ((pickup_date_last - init_date )>=((6*27.5)-89)  ///
| (pickup_date_last - init_date ) ==0) & pickup_date_last !=. & enrol_date!=.
replace ric_6mths=0 if ric_6mths==.
*percentage of RIC 6 mnths
tab country ric_6mths if visit ==1 ,row 

* 9m RIC
gen ric_9mths=1 if ((pickup_date_last - init_date )>=((9*27.5)-89)  ///
| (pickup_date_last - init_date ) ==0) & pickup_date_last !=.
replace ric_9mths=0 if ric_9mths==.
*percentage of RIC 6 mnths
tab country ric_9mths if visit ==1 ,row 

* 12m RIC
gen ric_12mths=1 if ((pickup_date_last - init_date)>=((12*27.4)-89)  ///
| (pickup_date_last - init_date ) ==0) & pickup_date_last !=.
replace ric_12mths=0 if ric_12mths==.
tab country ric_12mths if visit ==1 ,row 

* 18m RIC
gen ric_18mths=1 if ((pickup_date_last - init_date )>=((18*27.4)-89)  ///
| (pickup_date_last - init_date ) ==0) & pickup_date_last !=.
replace ric_18mths=0 if ric_18mths==.
tab country ric_18mths if visit ==1 ,row 

* 24m RIC
gen ric_24mths=1 if ((pickup_date_last - init_date)>=((24*27.4)-89)  ///
| (pickup_date_last - init_date) ==0) & pickup_date_last !=.
replace ric_24mths=0 if ric_24mths==.
tab country ric_24mths if visit ==1 ,row 

* Consider AN any (AN+PN)
*-------------------------------------------------------------------------------
*Retention on ART at different time points  by treatment history

 tab delivery_ric treat_hist if visit ==1 ,col

 tab ric_3mths treat_hist if visit ==1 ,col
 
 tab ric_6mths treat_hist if visit ==1  ,col

 tab ric_9mths treat_hist if visit ==1  ,col

 tab ric_12mths treat_hist if visit ==1 ,col
 
 tab ric_18mths treat_hist if visit ==1 ,col
 
 tab ric_24mths treat_hist if visit ==1  ,col 

*-------------------------------------------------------------------------------
*Retention at different time points by age group

 tab delivery_ric agecat_agyw if visit ==1,col
 
 tab ric_3mths agecat_agyw if visit ==1 ,col
 
 tab ric_6mths agecat_agyw if visit ==1 ,col

 tab ric_9mths agecat_agyw if visit ==1 ,col

 tab ric_12mths agecat_agyw if visit ==1 ,col

 tab ric_18mths agecat_agyw if visit ==1 ,col
 
 tab ric_24mths agecat_agyw if visit ==1 ,col
 
*-------------------------------------------------------------------------------
*Retention at different time points by site type

 
 tab ric_3mths site_type if visit ==1 & type == 2,col
 
 tab ric_6mths site_type if visit ==1 & type == 2,col

 tab ric_9mths site_type if visit ==1 & type == 2,col

 tab ric_12mths site_type if visit ==1 & type == 2,col

 tab ric_18mths site_type if visit ==1 & type == 2,col
 
 tab ric_24mths site_type if visit ==1 & type == 2,col
 
 
*-------------------------------------------------------------------------------
*Retention on ART at different time points  by treatment history

 tab country ric_3mths if visit ==1 & (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row
 
 tab country ric_6mths if visit ==1 & (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row

 tab country ric_9mths if visit ==1 & (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row

 tab country ric_12mths if visit ==1 &  (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row
 
 tab country ric_18mths if visit ==1 &  (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row
 
 tab country ric_24mths if visit ==1 &  (exit_exitwhy != 2 ///
 | exit_exitwhy != 4), row
 

 
*Retention at different time points by age group (Naive client only)

 tab delivery_ric agecat_agyw if visit ==1 &  treat_hist ==0 ,col
 
 tab ric_3mths agecat_agyw if visit ==1 & treat_hist ==0,col
 
 tab ric_6mths agecat_agyw if visit ==1 &  treat_hist ==0,col

 tab ric_9mths agecat_agyw if visit ==1 & treat_hist ==0,col

 tab ric_12mths agecat_agyw if visit ==1 &  treat_hist ==0,col

 tab ric_18mths agecat_agyw if visit ==1 &  treat_hist ==0,col
 
 tab ric_24mths agecat_agyw if visit ==1 &  treat_hist ==0,col
 
 

*-------------------------------------------------------------------------------
* Duration on ART
*----------------
 
gen art_duration= (last_visit_date - init_date )/365 

gen art_duration_cat = 1 if art_duration <=3 
replace art_duration_cat =2 if art_duration >3 & art_duration <=6
replace art_duration_cat =3 if art_duration >6 & art_duration <=9
replace art_duration_cat =4 if art_duration >9 & art_duration <=12
replace art_duration_cat =5 if art_duration >12 & art_duration <=18
replace art_duration_cat =6 if art_duration >18 & art_duration <=24
replace art_duration_cat =7 if art_duration >24 & art_duration!=.
 
tab agecat_agyw art_duration_cat if visit ==1 & treat_hist==1 & (exit_exitwhy ==3 ///
| exit_exitwhy == 5 | exit_exitwhy == 6 | exit_exitwhy == 7)

tab agecat_agyw art_duration_cat if visit ==1 & treat_hist==1 & exit_exitwhy !=.

*-------------------------------------------------------------------------------
* alive and on ART at 12 
*-----------------------
 tab ric_3mths exit_exitwhy if visit ==1 & exit_exitwhy==3,col
 
 tab ric_6mths exit_exitwhy if visit ==1 &  exit_exitwhy==3,col

 tab ric_9mths exit_exitwhy if visit ==1 & exit_exitwhy==3,col

 tab ric_12mths exit_exitwhy if visit ==1 &  exit_exitwhy==3,col

 tab ric_18mths exit_exitwhy if visit ==1 &  exit_exitwhy==3,col
 
 tab ric_24mths exit_exitwhy if visit ==1 &  exit_exitwhy==3,col
 
save  "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\RIC_analysis_output.dta", replace

*-------------------------------------------------------------------------------
*Survival Analysis
set maxvar 32700
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\RIC_analysis_output.dta", clear


collapse (firstnm) country treat_hist enrol_date init_date ///
last_visit_date expect_m2m_exit_date exit_exitwhy agecat_agyw ///
 ric* visit, by (id)
 
gen mm_contacts = 1 if visit >= 2 & visit <=5
replace mm_contacts = 2 if visit >=6 & visit <=9
replace mm_contacts = 3 if visit >=10 & visit <=12
replace mm_contacts = 4 if visit >=13 & visit <=15
replace mm_contacts = 5 if visit >=16
tab mm_contacts

gen m2m_duration = (last_visit_date - enrol_date)/30.4

label values exit_exitwhy exit_exitwhy
*label values visits_total_cat visits_total_cat

gen ric = 1 if ((expect_m2m_exit_date - init_date)/28.5 <= 24)
replace ric = 0 if ric == .

stset m2m_duration if m2m_duration<=24 & treat_hist==0 & m2m_duration != . , failure(ric=0) scale(1)
sts graph, by(country) yline(0.95, lwidth(thick) lpattern(solid) lcolor(red)) ///
xtitle(Months on ART) ylabel(0.0(.2)1.0) xlabel(0(2)24) legend(order(1 "Lesotho"  2 "South Africa" 3 "Uganda" ))

* Probability of 24 months retention on ART by # MM contacts

stset m2m_duration if m2m_duration<=24 & treat_hist==0 & m2m_duration != . , failure(ric=0) scale(1)
sts graph, by(mm_contacts) yline(0.95, lwidth(thick) lpattern(solid) lcolor(red)) ///
xtitle(Months on ART) ylabel(0.0(.2)1.0) xlabel(0(2)24)



gen m2m_duration_type = (last_visit_date - enrol_date)/30.4

gen ric_type = 1 if (expect_m2m_exit_date - init_dat)/30.4 <= 24
replace ric_type = 0 if ric_type == .

stset m2m_duration_type if m2m_duration_type <=24 & treat_hist==0 & m2m_duration_type !=., failure(ric_type==0) scale(1)
sts graph, by(type)  xtitle(Months on ART) ylabel(0.4(0.1)1) xlabel(0(2)24) yline(0.95, lwidth(thick) lpattern(solid) lcolor(red))




save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\RIC_survival_analysis.dta", replace
