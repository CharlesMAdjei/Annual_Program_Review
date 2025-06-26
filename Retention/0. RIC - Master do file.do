*------------------------------------------------------------------------------*
* Start-up commands

clear all
set more off
set excelxlsxlargefile on
macro drop _all

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

global ric_2021 "C:/Users/Charles.Adjei/Desktop/mothers2mothers/E&OR shared files/APR 2021"
global ric_temp "$ric_2021/RIC/Temp"
global ric_data "$ric_2021/RIC/Data"
global ric_do "$ric_2021/RIC/Do files"
global ric_output "$ric_2021/RIC/Output"
global ric_responses "$output/Clients missing key outcomes/Responses from countries"

global beg_period=td(01jan2019)
global beg_period_2yr=td(01jan2020)
global end_period=td(31dec2021)
