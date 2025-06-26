*** APR 2020 - Community analysis - 95 95 95
*** ART initiation among clients with 2+ visits
* 26 May 2021


*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear
merge m:1 caseid using ///
	"$temp/index all - full dataset - both samples - to bring in for ART stats.dta"
replace artstart=artstart_index if artstart!=1 & artstart_index==1 & client1==1

keep if status_final==1
drop if numvisits_total<2
numlabel, add force
qui svyset id 

forvalues i=1/7 {	
	tabout client1 artstart if country2==`i' ///
		using "$output/ART initiation/ART initiation - All - 1 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout client1 artstart ///
	using "$output/ART initiation/ART initiation - All - 1 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 




*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear
merge m:1 caseid using ///
	"$temp/index all - full dataset - both samples - to bring in for ART stats.dta"
replace artstart=artstart_index if artstart!=1 & artstart_index==1 & client1==1

drop if numvisits_total<2
keep if status_final==1
numlabel, add force
qui svyset id 

forvalues i=1/5 {	
	tabout client1 artstart if country2==`i' ///
		using "$output/ART initiation/ART initiation - All - 2 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout client1 artstart ///
	using "$output/ART initiation/ART initiation - All - 2 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
	
/*
/*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear
merge m:1 caseid using ///
	"$temp/index all - full dataset - both samples - to bring in for ART stats.dta"
replace artstart=artstart_index if artstart!=1 & artstart_index==1 & client1==1

drop if numvisits_total<2
keep if status_final==1
numlabel, add force
qui svyset id 

forvalues i=1/3 {	
	tabout client1 artstart if country2==`i' ///
		using "$output/ART initiation/ART initiation - All - 3 year sample (2+ visits) country `i' ($S_DATE).xls", ///
		c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout client1 artstart ///
	using "$output/ART initiation/ART initiation - All - 3 year sample (2+ visits) ($S_DATE).xls", ///
	c(row) f(1p 0c) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 
