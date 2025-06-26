*** APR 2020 - Community 95 95 95
*** Master do file 
* 28 April 2021



*------------------------------------------------------------------------------*
* Start-up commands

clear all
set more off
set excelxlsxlargefile on
macro drop _all
set maxvar 32700


global main_appdata_onedrive "C:/Users/Charles.Adjei/Desktop/mothers2mothers/App data"
global commcare_appdata "$main_appdata_onedrive/Commcare"
global do_appdata "$main_appdata_onedrive/Do files"
global temp_appdata "$main_appdata_onedrive/Temp"
global data_appdata "$main_appdata_onedrive/Data"


global ninety_five "C:/Users/Charles.Adjei/Desktop/mothers2mothers/E&OR shared files/APR 2021/95 95 95"
global input "$ninety_five/Input"
global temp "$ninety_five/Temp"
global data "$ninety_five/Data"
global do "$ninety_five/Do files"
global output "$ninety_five/Output"

global beg_period1=td(01jan2020)
global beg_period2=td(01jan2021)
global end_period=td(31dec2021)



exit

*------------------------------------------------------------------------------*
* Run do files

do "$do/1. Community - Import, append and clean data.do"
do "$do/2. Community - Identify eligible facilities.do"
do "$do/3.1 Community - Variable creation - caregiver.do"
do "$do/3.2 Community - Variable creation - childadol.do"
do "$do/3.3 Community - Variable creation - partner.do"
do "$do/4. Community - Append index, childadol and partner datasets.do"
do "$do/5.1 Community - Output - Sample stats (all clients).do"
do "$do/5.2 Community - Output - m2m exposure (all clients).do"
do "$do/5.3 Community - Output - Number of visits (all clients).do"
do "$do/5.4 Community - Output - Gap between visits (all clients).do"
do "$do/5.5 Community - Output - At least 1 test (all clients).do"
do "$do/5.5.1 Community - Output - At least 1 test (all clients).do"
do "$do/5.6 Community - Output - HIV test uptake (index).do"
do "$do/5.6 Community - Output - HIV test uptake (index).do"
do "$do/5.7.1 Community - Output - HIV test uptake (child).do"
do "$do/5.7 Community - Output - HIV test uptake (child).do"
do "$do/5.8 Community - Output - HIV test uptake (partner).do"
do "$do/5.8.1 Community - Output - HIV test uptake (partner).do"
do "$do/5.9 Community - Output - Status at enrolment vs final (all clients).do"
do "$do/5.9.1 Community - Output - Status at enrolment vs final (all clients).do"
do "$do/5.10 Community - Output - ART initiation (all clients).do"
do "$do/5.10.1 Community - Output - ART initiation (all clients).do"
do "$do/5.11 Community - Output - VL testing (all clients).do"
do "$do/5.11.1 Community - Output - VL testing (all clients).do"
do "$do/5.12 Community - Output - Adherence (all clients).do"
do "$do/5.12.1 Community - Output - Adherence (all clients).do"


exit


*------------------------------------------------------------------------------*
* Delete temporary datasets

* --> Erase intermediate datasets
local files: dir "$temp/" files "*.dta"
cd "$temp/"
foreach file in `files' {
	erase "`file'"
}
