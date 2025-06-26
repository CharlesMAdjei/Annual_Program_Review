*** APR 2020 - Community analysis - 95 95 95
*** Append all datasets together
* 29 April 2021

/*
This do file creates a few different datasets:
- 1 & 2 year sample datasets that contain all clients appended together. No
  attempt made to match household members to their index clients.
- 1 & 2 year matched samples for index+child/adol and index+partner.
*/



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year sample
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Append clients, no attempt to match hhmems to index

* --> Append the client-specific datasets
use	"$temp/index nonpos - full dataset - 1yr sample.dta", clear
append using ///
	"$temp/index pos - full dataset - 1yr sample.dta" ///
	"$temp/childadol - full dataset - 1yr sample.dta" ///
	"$temp/partner - full dataset - 1yr sample.dta"
	
egen fac_tag=tag(facility)
tab fac_tag

	
* --> Unique identifier across all clients
gen x=caseid 
replace x=hhmem_caseid if hhmem_caseid!="" & (db=="childadol" | db=="partner") 
cap drop id
egen id=group(x)
*drop x
label var id "Unique identifier across all clients"


* --> Keep each client only once to make dataset wide
egen id_tag=tag(id)
tab id_tag
keep if id_tag==1
tab country
*drop if country=="Uganda"
	// Dropping Uganda because the sample is too small to be useful.
	
isid id
label var db "App2 form"
tab db, m 
	// Note that index clients will still appear multiple times if they are
	// associated with a child/adol and/or partner.


* --> Client type
gen client1=1 if db=="index_pos" | db=="index_nonpos"
replace client=2 if db=="childadol" & age_enrol>=2 & age_enrol<=9
replace client=3 if db=="childadol" & age_enrol>=10 & age_enrol<=19
replace client=4 if db=="partner"
label def client1 1"Index" 2"Child" 3"Adolescent" 4"Partner" 
label val client1 client1
label var client1 "Client type v1"
tab client, m
tab db if client==.
drop if client==.
	// 101 individuals are missing their type because they are from the child/
	// adol form and don't have an age so I haven't been able to class them as
	// child or adol. In order to keep sample sizes consistent and simple, I
	// remove them from the sample since they will be dropped from most stats
	// anyway.

gen client2=1 if db=="index_pos"
replace client2=2 if db=="index_nonpos" & status_enrol==0
replace client2=3 if db=="index_nonpos" & status_enrol==2
replace client2=4 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==1
replace client2=5 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==0
replace client2=6 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==2
replace client2=7 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==1
replace client2=8 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==0
replace client2=9 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==2
replace client2=10 if db=="partner" & status_enrol==1
replace client2=11 if db=="partner" & status_enrol==0
replace client2=12 if db=="partner" & status_enrol==2
label def client2 ///
	1"Index (HIV-pos)" 2"Index (HIV-neg)" 3"Index (unknown)" ///
	4"Child (HIV-pos)" 5"Child (HIV-neg)" 6"Child (unknown)" ///
	7"Adolescent (HIV-pos)" 8"Adolescent (HIV-neg)" 9"Adolescent (unknown)" ///
	10"Partner (HIV-pos)" 11"Partner (HIV-neg)" 12"Partner (unknown)" 
label val client2 client2
label var client2 "Client type (sep. by status at enrol)"
tab client2

	
* --> Sex
label def sex_lab 0"Female" 1"Male" 2"Missing"
label val sex sex_lab
tab sex, m


* --> Age categorical variable
label var age_enrol "Age at enrolment"
replace age_enrol=. if age_enrol==0
recode age_enrol ///
	(2/9=1 "1. 2-9 years old") ///
	(10/19=2 "2. 10-19 years old") ///
	(20/24=3 "3. 20-24 years old") ///
	(25/34=4 "4. 25-34 years old") ///
	(35/max=5 "5. 35+ years old") ///
	(.=6 "Missing"), ///
	gen(age_enrol_cat)
label var age_enrol_cat "Age at enrolment (categories)"
tab age_enrol_cat, m
tab age_enrol_cat country, m


* --> Numeric country variable for loops
egen country2=group(country)


* --> Save
tab country
save "$temp/all clients - full dataset - 1yr sample.dta", replace




*------------------------------------------------------------------------------*
* Matching hh members to their index clients

* --> Index clients
use	"$temp/index nonpos - full dataset - 1yr sample.dta", clear
append using ///
	"$temp/index pos - full dataset - 1yr sample.dta" 
cap drop id_tag
egen id_tag=tag(caseid)
keep if id_tag==1
drop if country=="Uganda"
ren status_enrol status_enrol_index
keep country db caseid status_enrol	
save "$temp/index ids - 1yr sample.dta", replace


* --> Children/adolescents	
use	"$temp/childadol - full dataset - 1yr sample.dta", clear
cap drop id_tag
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
drop if country=="Uganda"
ren status_enrol status_enrol_childadol
keep country caseid hhmem_caseid status_enrol	
save "$temp/childadol ids - 1yr sample.dta", replace


* --> Partners	
use	"$temp/partner - full dataset - 1yr sample.dta", clear
cap drop id_tag
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
drop if country=="Uganda"
ren status_enrol status_enrol_partner
keep country caseid hhmem_caseid status_enrol
save "$temp/partner ids - 1yr sample.dta", replace
	

* --> Merge index and child/adol
use  "$temp/index ids - 1yr sample.dta", clear
merge 1:m caseid using "$temp/childadol ids - 1yr sample.dta"
tab country _merge
	// Almost all children/adols are matched to an index client. 
	
keep if _merge==3
drop _merge
gen matched_child_index=1
save "$temp/childadol matched to index - 1yr sample.dta", replace


* --> Merge index and partner
use  "$temp/index ids - 1yr sample.dta", clear
merge 1:m caseid using "$temp/partner ids - 1yr sample.dta"
tab country _merge
	
keep if _merge==3
drop _merge
gen matched_partner_index=1
save "$temp/partner matched to index - 1yr sample.dta", replace




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year sample
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Append clients (no attempt to match hh members to index)

* --> Append the client-specific datasets
use	"$temp/index nonpos - full dataset - 2yr sample.dta", clear
append using ///
	"$temp/index pos - full dataset - 2yr sample.dta" ///
	"$temp/childadol - full dataset - 2yr sample.dta" ///
	"$temp/partner - full dataset - 2yr sample.dta"
	
egen fac_tag=tag(facility)
tab fac_tag
	
	
* --> Unique identifier across all clients
replace caseid="" if db=="childadol" | db=="partner"
gen x=caseid 
replace x=hhmem_caseid if x=="" 
cap drop id
egen id=group(x)
drop x
label var id "Unique identifier across all clients"
egen id_tag=tag(id)
keep if id_tag==1
tab db 


* --> Client type
gen client1=1 if db=="index_pos" | db=="index_nonpos"
replace client=2 if db=="childadol" & age_enrol>=2 & age_enrol<=9
replace client=3 if db=="childadol" & age_enrol>=10 & age_enrol<=19
replace client=4 if db=="partner"
label def client1 1"Index" 2"Child" 3"Adolescent" 4"Partner" 
label val client1 client1
label var client1 "Client type v1"
tab db client, m
drop if client==.

gen client2=1 if db=="index_pos"
replace client2=2 if db=="index_nonpos" & status_enrol==0
replace client2=3 if db=="index_nonpos" & status_enrol==2
replace client2=4 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==1
replace client2=5 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==0
replace client2=6 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==2
replace client2=7 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==1
replace client2=8 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==0
replace client2=9 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==2
replace client2=10 if db=="partner" & status_enrol==1
replace client2=11 if db=="partner" & status_enrol==0
replace client2=12 if db=="partner" & status_enrol==2
label def client2 ///
	1"Index (HIV-pos)" 2"Index (HIV-neg)" 3"Index (unknown)" ///
	4"Child (HIV-pos)" 5"Child (HIV-neg)" 6"Child (unknown)" ///
	7"Adolescent (HIV-pos)" 8"Adolescent (HIV-neg)" 9"Adolescent (unknown)" ///
	10"Partner (HIV-pos)" 11"Partner (HIV-neg)" 12"Partner (unknown)" 
label val client2 client2
label var client2 "Client type (sep. by status at enrol)"
tab client2

	
* --> Sex
label def sex_lab 0"Female" 1"Male" 2"Missing"
label val sex sex_lab
tab sex, m


* --> Age categorical variable
label var age_enrol "Age at enrolment"
replace age_enrol=. if age_enrol==0
recode age_enrol ///
	(2/9=1 "1. 2-9 years old") ///
	(10/19=2 "2. 10-19 years old") ///
	(20/24=3 "3. 20-24 years old") ///
	(25/34=4 "4. 25-34 years old") ///
	(35/max=5 "5. 35+ years old") ///
	(.=6 "Missing"), ///
	gen(age_enrol_cat)
label var age_enrol_cat "Age at enrolment (categories)"
tab age_enrol_cat, m
tab age_enrol_cat country, m


* --> Numeric country variable for loops
egen country2=group(country)


* --> Save
save "$temp/all clients - full dataset - 2yr sample.dta", replace




*------------------------------------------------------------------------------*
* Matching hh members to their index clients

* --> Index clients
use	"$temp/index nonpos - full dataset - 2yr sample.dta", clear
append using "$temp/index pos - full dataset - 2yr sample.dta"
egen id_tag=tag(caseid)
keep if id_tag==1
ren status_enrol status_enrol_index
keep db caseid status_enrol_index
save "$temp/index ids - 2yr sample.dta", replace


* --> Children/adolescents	
use "$temp/childadol - full dataset - 2yr sample.dta", replace
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
ren status_enrol status_enrol_childadol
keep caseid hhmem_caseid status_enrol_childadol	
save "$temp/childadol ids - 2yr sample.dta", replace


* --> Partners	
use "$temp/partner - full dataset - 2yr sample.dta", replace
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
ren status_enrol status_enrol_partner
keep caseid hhmem_caseid status_enrol_partner
save "$temp/partner ids - 2yr sample.dta", replace
	

* --> Merge index and child/adol
use  "$temp/index ids - 2yr sample.dta", clear
merge 1:m caseid using "$temp/childadol ids - 2yr sample.dta"
keep if _merge==3
drop _merge
gen matched_child_index=1
save "$temp/childadol matched to index - 2yr sample.dta", replace


* --> Merge index and partner
use  "$temp/index ids - 2yr sample.dta", clear
merge 1:m caseid using "$temp/partner ids - 2yr sample.dta"
keep if _merge==3
drop _merge
gen matched_partner_index=1
save "$temp/partner matched to index - 2yr sample.dta", replace







/*
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year sample
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
* Append clients (no attempt to match hh members to index)

* --> Append the client-specific datasets
use	"$temp/index nonpos - full dataset - 3yr sample.dta", clear
append using ///
	"$temp/index pos - full dataset - 3yr sample.dta" ///
	"$temp/childadol - full dataset - 3yr sample.dta" ///
	"$temp/partner - full dataset - 3yr sample.dta"
	
egen fac_tag=tag(facility)
tab fac_tag
	
	
* --> Unique identifier across all clients
replace caseid="" if db=="childadol" | db=="partner"
gen x=caseid 
replace x=hhmem_caseid if x=="" 
cap drop id
egen id=group(x)
drop x
label var id "Unique identifier across all clients"
egen id_tag=tag(id)
keep if id_tag==1
tab db 


* --> Client type
gen client1=1 if db=="index_pos" | db=="index_nonpos"
replace client=2 if db=="childadol" & age_enrol>=2 & age_enrol<=9
replace client=3 if db=="childadol" & age_enrol>=10 & age_enrol<=19
replace client=4 if db=="partner"
label def client1 1"Index" 2"Child" 3"Adolescent" 4"Partner" 
label val client1 client1
label var client1 "Client type v1"
tab db client, m
drop if client==.

gen client2=1 if db=="index_pos"
replace client2=2 if db=="index_nonpos" & status_enrol==0
replace client2=3 if db=="index_nonpos" & status_enrol==2
replace client2=4 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==1
replace client2=5 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==0
replace client2=6 if db=="childadol" & age_enrol>=2 & age_enrol<=9 & ///
		status_enrol==2
replace client2=7 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==1
replace client2=8 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==0
replace client2=9 if db=="childadol" & age_enrol>=10 & age_enrol<=19 & ///
		status_enrol==2
replace client2=10 if db=="partner" & status_enrol==1
replace client2=11 if db=="partner" & status_enrol==0
replace client2=12 if db=="partner" & status_enrol==2
label def client2 ///
	1"Index (HIV-pos)" 2"Index (HIV-neg)" 3"Index (unknown)" ///
	4"Child (HIV-pos)" 5"Child (HIV-neg)" 6"Child (unknown)" ///
	7"Adolescent (HIV-pos)" 8"Adolescent (HIV-neg)" 9"Adolescent (unknown)" ///
	10"Partner (HIV-pos)" 11"Partner (HIV-neg)" 12"Partner (unknown)" 
label val client2 client2
label var client2 "Client type (sep. by status at enrol)"
tab client2

	
* --> Sex
label def sex_lab 0"Female" 1"Male" 2"Missing"
label val sex sex_lab
tab sex, m


* --> Age categorical variable
label var age_enrol "Age at enrolment"
replace age_enrol=. if age_enrol==0
recode age_enrol ///
	(2/9=1 "1. 2-9 years old") ///
	(10/19=2 "2. 10-19 years old") ///
	(20/24=3 "3. 20-24 years old") ///
	(25/34=4 "4. 25-34 years old") ///
	(35/max=5 "5. 35+ years old") ///
	(.=6 "Missing"), ///
	gen(age_enrol_cat)
label var age_enrol_cat "Age at enrolment (categories)"
tab age_enrol_cat, m
tab age_enrol_cat country, m


* --> Numeric country variable for loops
egen country2=group(country)


* --> Save
save "$temp/all clients - full dataset - 3yr sample.dta", replace




*------------------------------------------------------------------------------*
* Matching hh members to their index clients

* --> Index clients
use	"$temp/index nonpos - full dataset - 3yr sample.dta", clear
append using "$temp/index pos - full dataset - 3yr sample.dta"
egen id_tag=tag(caseid)
keep if id_tag==1
ren status_enrol status_enrol_index
keep db caseid status_enrol_index
save "$temp/index ids - 3yr sample.dta", replace


* --> Children/adolescents	
use "$temp/childadol - full dataset - 3yr sample.dta", replace
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
ren status_enrol status_enrol_childadol
keep caseid hhmem_caseid status_enrol_childadol	
save "$temp/childadol ids - 3yr sample.dta", replace


* --> Partners	
use "$temp/partner - full dataset - 3yr sample.dta", replace
egen id_tag=tag(hhmem_caseid)
keep if id_tag==1
ren status_enrol status_enrol_partner
keep caseid hhmem_caseid status_enrol_partner
save "$temp/partner ids - 3yr sample.dta", replace
	

* --> Merge index and child/adol
use  "$temp/index ids - 3yr sample.dta", clear
merge 1:m caseid using "$temp/childadol ids - 3yr sample.dta"
keep if _merge==3
drop _merge
gen matched_child_index=1
save "$temp/childadol matched to index - 3yr sample.dta", replace


* --> Merge index and partner
use  "$temp/index ids - 3yr sample.dta", clear
merge 1:m caseid using "$temp/partner ids - 3yr sample.dta"
keep if _merge==3
drop _merge
gen matched_partner_index=1
save "$temp/partner matched to index - 3yr sample.dta", replace
