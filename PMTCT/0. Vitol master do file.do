
*------------------------------------------------------------------------------*
* Start-up commands

clear all
set more off
set excelxlsxlargefile on
macro drop _all
set maxvar 32700

global appdata "C:/Users/Charles.Adjei/Desktop/mothers2mothers/App data"
global input_appdata "$appdata/Commcare"
global do_appdata "$appdata/Do files"
global temp_appdata "$appdata/Temp"
global data_appdata "$appdata/Data"


global apr2021 "C:/Users/Charles.Adjei/Desktop/mothers2mothers/E&OR shared files/APR 2021"
global temp "$apr2021/PMTCT/Temp"
global data "$apr2021/PMTCT/Data"
global do "$apr2021/PMTCT/Do files"
global output "$apr2021/PMTCT/Output"
global responses "$output/Clients missing key outcomes/Responses from countries"


global beg_period=td(01jan2022)
global end_period=td(30jun2022)




*exit

*--> Import and append commcare exports across all years for each form
*do "$do_appdata/Clare & new version/App1/0. App1 Clare & new version - Master do file.do"
*------------------------------------------------------------------------------*

* Run do files

do "$do/0.1 PMTCT - Identify eligible facilities.do"
do "$do/1. PMTCT - Create data.do"
do "$do/2. PMTCT - Identify cohort.do"
do "$do/3. PMTCT - Create variables.do"
do "$do/4. PMTCT - Lists of clients missing outcomes.do"
*do "$do/5.1 PMTCT - Bringing in data on clients missing outcomes - 2yr.do"
*do "$do/5.2 PMTCT - Bringing in data on clients missing outcomes - 3yr.do"
do "$do/6. PMTCT - Demographics and descriptives.do"
*do "$do/7. PMTCT - PMTCT service uptake.do"
*do "$do/8. PMTCT - PMTCT cascade.do"
*do "$do/9. PMTCT - Infant testing, transmission & ART.do"
do "$do/10. PMTCT - Adherence.do"
do "$do/11. PMTCT - Viral load testing.do"



