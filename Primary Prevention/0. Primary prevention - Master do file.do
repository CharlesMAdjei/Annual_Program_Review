*** APR 2020 - Primary prevention
*** Master do file 
* 9 July 2021



*------------------------------------------------------------------------------*
* Start-up commands

clear all
set more off
set excelxlsxlargefile on
set maxvar 32700
macro drop _all

global appdata "C:/Users/Charles.Adjei/Desktop/mothers2mothers/App data"
global input_appdata "$appdata/Commcare"
global do_appdata "$appdata/Do files"
global temp_appdata "$appdata/Temp"
global data_appdata "$appdata/Data"



global apr2021 "C:/Users/Charles.Adjei/Desktop/mothers2mothers/E&OR shared files/APR 2021"
global temp "$apr2021/Primary prevention/Temp"
global data "$apr2021/Primary prevention/Data"
global do "$apr2021/Primary prevention/Do files"
global output "$apr2021/Primary prevention/Output"

global beg_enrol=td(01jan2019)
global end_enrol=td(01jun2020)
global end_period=td(31dec2021)


exit

*------------------------------------------------------------------------------*
* Run do files

do "$do/1. Primary prevention - Identify eligible facilities.do"
do "$do/2. Primary prevention - Create data.do"
/*
do "$do/2.1 Primary prevention - Import new version data.do"
do "$do/2.2 Primary prevention - Clean new version an.do"
do "$do/2.2 Primary prevention - Clean new version new.do"
do "$do/2.2 Primary prevention - Clean new version pn.do"
*/
do "$do/3. Primary prevention - Cleaning.do"
do "$do/4.1 Primary prevention - Analysis - Sample description.do"
do "$do/4.2 Primary prevention - Analysis - HIV tests.do"
do "$do/4.3 Primary prevention - Analysis - Seroconversion.do"
do "$do/4.4 Primary prevention - Analysis - Client characteristics.do"
*do "$do/4.5 Primary prevention - Analysis - Condom usage.do"
*do "$do/4.6 Primary prevention - Analysis - FP usage.do"
