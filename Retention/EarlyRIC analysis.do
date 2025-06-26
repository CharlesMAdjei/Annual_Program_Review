* This do file uses a date that's prepared by Clare in wide format. All the App1
* data files are cleaned, merged/appended. 

* This code estimate the RIC using App1 data

clear mata
set maxvar 32700
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/earlyric_final.dta", clear
 
* Reshape to long format
*-----------------------
 
reshape long an_artstart_date pn_artstart_date an_artprevrefill_date /// 
an_artrefill_date pn_artprevrefill_date pn_artrefill_date /// 
infant_artprevrefilldue infant_artrefilldue infant_artprevrefilldone /// 
infant_artrefilldone dan_anvisit2_done_date dan_anvisit3_done_date /// 
dan_anvisit4_done_date dan_facility dan_init_done_date ///
dpn_infant_art_done_date, i(id) j(visit) 


save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/EarlyRIC-longformartdata.dta", replace

* Date variabes cleaning
*-----------------------
clear mata
set maxvar 32700
use  "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/EarlyRIC-longformartdata.dta", clear

*dropping clients with single contact
drop if visits_total ==1

* Generate site calssification
*gen site_classification = 1 if country == 1
*replace site_classification = 1 if facility == "khayelitsha site b mou" ///
*| facility == "michael mapongwana clinic" | facility == "town 2 clinic"
*replace site_classification = 1 if facility == "dark city clinic" | ///
*facility == "soshanguve mou"
*replace site_classification = 2 if facility == "letlhabile clinic"
*-------------------------------------------------------------------------------
* Destring Exit variable
replace dexit_exitwhy = "1" if dexit_exitwhy == "baby_deceased"
replace dexit_exitwhy = "2" if dexit_exitwhy == "client_deceased"
replace dexit_exitwhy = "2" if dexit_exitwhy == "deceased"
replace dexit_exitwhy = "3" if dexit_exitwhy == "graduated"
replace dexit_exitwhy = "4" if dexit_exitwhy == "lost_to_follow-up"
replace dexit_exitwhy = "4" if dexit_exitwhy == "ltfu"
replace dexit_exitwhy = "5" if dexit_exitwhy == "miscarried"
replace dexit_exitwhy = "6" if dexit_exitwhy == "moved"
replace dexit_exitwhy = "7" if dexit_exitwhy == "transferred"
destring dexit_exitwhy , replace 
label define dexit_exitwhy 1 "Baby_deceased" 2 "Client_deceased" 3 ///
"Graduated" 4 "LTFU" 5 "Miscarried" 6 "Moved" 7 "Transferred"
label values dexit_exitwhy dexit_exitwhy
*-------------------------------------------------------------------------------

*replace dan_anvisit2_done = "." if dan_anvisit2_done == "---"
*replace dan_anvisit3_done = "." if dan_anvisit3_done == "---"
*replace dan_anvisit4_done = "." if dan_anvisit4_done == "---"
*destring dan_anvisit2_done dan_anvisit3_done dan_anvisit4_done, replace


*gen an_anvisit2 = date(dan_anvisit2_done , "YMD")
*gen an_anvisit3 = date(dan_anvisit3_done , "YMD")
*gen an_anvisit4 = date(dan_anvisit4_done , "YMD")
*-------------------------------------------------------------------------------
* Clean enrol and init visit
rename first_timeenddate enrol_date
*gen enrol_date = date(first_timeenddate , "YMD")
*gen init_date = date(dnew_init_date , "YMD")

*-------------------------------------------------------------------------------
* Format dates variables
format %td artstart_date enrol_date an_artstart_date pn_artstart_date /// 
an_artrefill_date an_artprevrefill_date pn_artrefill_date ///
pn_artprevrefill_date infant_artrefilldone infant_artprevrefilldone 

*-------------------------------------------------------------------------------
* Treatment history (Naive and Non Naive clients)
gen treat_hist = 0 if artstart_date >= date("01jan2019", "DMY")
replace treat_hist = 1 if treat_hist == .
label define treat_hist 0 "Naive" 1 "Non Naive"
label values treat_hist treat_hist
*-------------------------------------------------------------------------------
*rename first and last visit variables
*rename first_timeenddatean first_visit_date
rename mostrecent_timeenddate last_visit_date 
replace last_visit_date = mostrecent_timeenddatepn ///
if mostrecent_timeenddatepn>last_visit_date  & mostrecent_timeenddatepn!=.

*gen visit_date = first_visit_date if visit == 1
*format %td visit_date 

*replace  enrol_date = visit_date if enrol_date==.
*replace  init_date = enrol_date if init_date==.
*-------------------------------------------------------------------------------
* Destring variables
*-------------------
replace  dnew_gestage_m2m = "." if  dnew_gestage_m2m == "---"
destring  dnew_gestage_m2m, replace 

*HIV status
*rename dnew_hiv_status hiv_status
*replace hiv_status = "1" if hiv_status == "known_positive"
*replace hiv_status = "2" if hiv_status == "tested_positive"
*destring hiv_status, replace 
*label define hiv_status 1 "known_positive" 2 "tested_positive"
*label values hiv_status hiv_status
* Countries
replace country = "1" if country == "Ghana"
replace country = "2" if country == "Kenya"
replace country = "3" if country == "Lesotho"
replace country = "4" if country == "Malawi"
replace country = "5" if country == "South Africa"
replace country = "6" if country == "Uganda"
replace country = "7" if country == "Zambia"
destring country , replace 
label define country 1 "Ghana" 2 "Kenya" 3 "Lesotho" 4 "Malawi" 5 "South Africa" ///
6 "Uganda" 7 "Zambia"
label values country country
*-------------------------------------------------------------------------------
* Treatment history (Naive and Non Naive clients)
gen treat_hist = 0 if artstart_date >= date("01jan2020", "DMY") & artstart_date!=.
replace treat_hist = 1 if artstart_date < date("01jan2020", "DMY") & artstart_date!=.
label define treat_hist 0 "Naive" 1 "Non Naive"
label values treat_hist treat_hist
*-------------------------------------------------------------------------------
* Consider AN any (AN+PN)
* Generating expected date of exit in the m2m program (EDD + 18 months) 
* minus 89 days
gen expect_m2m_exit_date= edd + (18*30)-89
format expect_m2m_exit_date %td

replace expect_m2m_exit_date=(infant_dob+(18*30))-89 ///
if expect_m2m_exit_date==. & infant_dob!=.

bys id: egen expect_m2m_exit_date1= max(expect_m2m_exit_date)
drop expect_m2m_exit_date
rename expect_m2m_exit_date1 expect_m2m_exit_date
format expect_m2m_exit_date %td

* Generating first and last pick-up date
egen pick_up_dates = rowmax(an_artstart_date an_artrefill_date an_artprevrefill_date)
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

tab country treat_hist if visit == 1 & type == 2, col 

*-------------------------------------------------------------------------------
* How long do the clients take to initiate ART treatment since enrolled
*-------------------------------------------------------------------

gen how_long_initiated = (artstart_date - enrol_date)/30 if enrol_date != . 
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
& initiated_num_unique == 1 & type == 2 & artstart_date  >= date("01jan2020", "DMY")
*Denominator (same as if we included AN Any)
tab country if treat_hist == 0  & visit == 1 & type == 2 & artstart_date  >= date("01jan2020", "DMY")

* Retained at three months on ART after ainitaited ART within 3m
gen retained_3m = 1 if initiated_ric_3m == 1 & how_long_initiated <= 6  & how_long_initiated >= 0
*& ric_3mths==1

* count unique number of clients started ART at specific time point
egen retained_num_unique=tag(id retained_3m)
*Numerator
tab country retained_3m if treat_hist == 0  & retained_num_unique == 1 & type ==2 & artstart_date  >= date("01jan2020", "DMY")
*Denominator
tab country if treat_hist == 0  & visit == 1 & type == 2 & artstart_date  >= date("01jan2020", "DMY")

* Retained at three months on ART after ainitaited ART within 3m (Another way)

gen ric_within3m=1 if ((artstart_date- enrol_date)>=((3*30.4)-89) ///
| ((artstart_date- enrol_date) > 0 | (artstart_date- enrol_date) <= 3)) & artstart_date!=.
replace ric_within3m=0 if ric_within3m==.
* count unique number of clients started ART at specific time point
egen retained_num_unique_within3m=tag(id  ric_within3m)


tab country ric_within3m if retained_num_unique == 1 & treat_hist == 0 & type == 2

tab country if visit == 1 & treat_hist == 0 & type ==2
*-------------------------------------------------------------------------------
* Consider AN any (AN+PN) (consider also last visit date)
* RIC for AN in months
*---------------------
gen an_ric = (an_artrefill_date - an_artstart_date)/30
replace an_ric = (an_artprevrefill_date  - an_artstart_date)/30 /// 
if an_artrefill_date == .
replace an_ric = 1000 if an_ric == .
gen yr_an = year(an_artrefill_date ) 
replace yr_an = year(an_artprevrefill_date) if an_artrefill_date == .

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
gen delivery_art = (infant_dob - artstart_date)/30 if an_artstart_date!=.
gen delivery_ric = 1 if delivery_art > 0  & visit == 1 & delivery_art !=.
* check if the client has a refill date at delivery
gen delivery_art_pick = (infant_dob - last_visit_date)/30 if last_visit_date!=.
gen delivery_ric_final = 1 if delivery_art_pick > 0 & visit == 1
replace delivery_ric = delivery_ric_final if (delivery_ric_final == 1 & ///
delivery_ric == .)

* Consider AN any (AN+PN)
* Retained in care at delivery 
*-----------------------------
*Naive clients
*--------------
*Numerator
tab country delivery_ric if treat_hist == 0 & visit == 1 & type == 2
*Denominator
tab country if treat_hist == 0  & visit == 1 & type == 2
* there are two clients who didn't retained (1 in Lesotho and 1 on SA)

* Consider AN any (AN+PN)
* All m2m HIV+ve clients
*-----------------------
*Numerator
tab country delivery_ric if visit == 1 & type != 1, col 
*Denominator
tab country if visit == 1 & type != 1
* there are two clients who didn't retained (1 in Lesotho and 1 on SA)
*-------------------------------------------------------------------------------
*Generating RIC variable
*-------------------------------------------------------------------------------
* 3m RIC
gen ric_3mths=1 if ((last_visit_date - artstart_date)>=((3*30.4)-89) ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=. & enrol_date!=. 
replace ric_3mths=0 if ric_3mths==.
*percentage of RIC 3 mnths
tab country ric_3mths if visit ==1 & type == 2 & treat_hist == 0,row 

* 6m RIC
gen ric_6mths=1 if ((last_visit_date - artstart_date)>=((6*30.4)-89)  ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=. & enrol_date!=.
replace ric_6mths=0 if ric_6mths==.
*percentage of RIC 6 mnths
tab country ric_6mths if visit ==1 & type == 2 & treat_hist == 0,row 

* 9m RIC
gen ric_9mths=1 if ((last_visit_date - artstart_date)>=((9*27.5)-89)  ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=.
replace ric_9mths=0 if ric_9mths==.
*percentage of RIC 6 mnths
tab country ric_9mths if visit ==1 & type == 2,row 

* 12m RIC
gen ric_12mths=1 if ((last_visit_date - artstart_date)>=((12*27.4)-89)  ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=.
replace ric_12mths=0 if ric_12mths==.
tab country ric_12mths if visit ==1 & type ==2,row 

* 18m RIC
gen ric_18mths=1 if ((last_visit_date - artstart_date)>=((18*27.4)-89)  ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=.
replace ric_18mths=0 if ric_18mths==.
tab country ric_18mths if visit ==1 & type ==2,row 

* 24m RIC
gen ric_24mths=1 if ((last_visit_date -artstart_date)>=((24*27.4)-89)  ///
| (last_visit_date - artstart_date) ==0) & last_visit_date !=.
replace ric_24mths=0 if ric_24mths==.
tab country ric_24mths if visit ==1 & type ==2,row 

* Consider AN any (AN+PN)
*-------------------------------------------------------------------------------
*Retention on ART at different time points  by treatment history

 tab delivery_ric treat_hist if visit ==1 & type == 2,col

 tab ric_3mths treat_hist if visit ==1 & type == 2 ,col
 
 tab ric_6mths treat_hist if visit ==1 & type == 2 ,col

 tab ric_9mths treat_hist if visit ==1 & type == 2 ,col

 tab ric_12mths treat_hist if visit ==1 & type == 2 ,col
 
 tab ric_18mths treat_hist if visit ==1 & type == 2 ,col
 
 tab ric_24mths treat_hist if visit ==1 & type == 2 ,col 

*-------------------------------------------------------------------------------
*Retention at different time points by age group

 tab delivery_ric agecat_agyw if visit ==1 & type == 2,col
 
 tab ric_3mths agecat_agyw if visit ==1 & type == 2,col
 
 tab ric_6mths agecat_agyw if visit ==1 & type == 2,col

 tab ric_9mths agecat_agyw if visit ==1 & type == 2,col

 tab ric_12mths agecat_agyw if visit ==1 & type == 2,col

 tab ric_18mths agecat_agyw if visit ==1 & type == 2,col
 
 tab ric_24mths agecat_agyw if visit ==1 & type == 2,col

*-------------------------------------------------------------------------------
*Retention at different time points by site type

 
 /*tab ric_3mths site_type if visit ==1 & type == 2,col
 
 tab ric_6mths site_type if visit ==1 & type == 2,col

 tab ric_9mths site_type if visit ==1 & type == 2,col

 tab ric_12mths site_type if visit ==1 & type == 2,col

 tab ric_18mths site_type if visit ==1 & type == 2,col
 
 tab ric_24mths site_type if visit ==1 & type == 2,col
 
 */
*-------------------------------------------------------------------------------
*Retention on ART at different time points  by treatment history

 tab country ric_3mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row
 
 tab country ric_6mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row

 tab country ric_9mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row

 tab country ric_12mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row
 
 tab country ric_18mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row
 
 tab country ric_24mths if visit ==1 & type == 2 & (dexit_exitwhy != 2 ///
 | dexit_exitwhy != 4), row
 
 
save  "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/EarlyRICanalysis_output.dta", replace

*-------------------------------------------------------------------------------
*Survival Analysis
set maxvar 32700
use "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/EarlyRICanalysis_output.dta", clear


collapse (firstnm) type country treat_hist artstart_date enrol_date ///
last_visit_date expect_m2m_exit_date dexit_exitwhy ///
ric*, by (id)

gen m2m_duration = (last_visit_date - enrol_date)/30.4

label values dexit_exitwhy dexit_exitwhy
*label values visits_total_cat visits_total_cat

gen ric = 1 if (expect_m2m_exit_date - artstart_date)/30.4 <= 24
replace ric = 0 if ric == .

stset m2m_duration if m2m_duration<=6 & treat_hist==0 & type == 2 & m2m_duration != .  , failure(ric==0) scale(1)
sts graph, by(country)  ///
xtitle(Months on ART) ylabel(0.60(0.1)1) xlabel(0(1)6) legend(order(1 "Ghana" 2 "Kenya" 3 "Lesotho" 4 "Malawi"  5 "South Africa" 6 "Uganda" 7 "Zambia"))




stset m2m_duration if m2m_duration <=6 & m2m_duration != ., failure(ric==0) scale(1)
sts graph, by(type) xlabel(0(1)6)

save "C:\Users\Mohammed.Fadul\Desktop\RIC 2021\Data\Early RIC/EarlyRIC_survival_analysis.dta", replace
