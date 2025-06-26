*** APR 2020 - Community analysis - 95 95 95
*** Exposure to m2m
* 26 May 2021



*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* One year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 1yr sample.dta", clear

* --> Categories
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ - All - 1 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat client1 ///
	using "$output/m2m exposure/m2m exp categ - All - 1 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat2 client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ v2 - All - 1 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat2 client1 ///
	using "$output/m2m exposure/m2m exp categ v2 - All - 1 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
* --> Mean and median
sum country2, meanonly
foreach i of num 1/`r(max)' {
	putexcel set "$output/m2m exposure/m2m exp mean med - All - 1 year sample country `i' ($S_DATE).xlsx", ///
		sheet(m2m) replace

		putexcel B1 = "Index"
		putexcel C1 = "Child"
		putexcel D1 = "Adolescent"
		putexcel E1 = "Male partner"
		putexcel F1 = "All"
		putexcel A2 = "Mean exposure"
		putexcel A3 = "Median exposure"
		putexcel A4 = "Sample size"

		preserve
		keep if country2==`i'
		
		local k="B"
		sum m2m_exp if client1==1, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="C"
		sum m2m_exp if client1==2, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="D"
		sum m2m_exp if client1==3, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="E"
		sum m2m_exp if client1==4, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="F"
		sum m2m_exp, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		restore
}

putexcel set "$output/m2m exposure/m2m exp mean med - All - 1 year sample ($S_DATE).xlsx", ///
	sheet(m2m) modify
	
putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Mean exposure"
putexcel A3 = "Median exposure"
putexcel A4 = "Sample size"

local k="B"
sum m2m_exp if client1==1, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="C"
sum m2m_exp if client1==2, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="D"
sum m2m_exp if client1==3, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="E"
sum m2m_exp if client1==4, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="F"
sum m2m_exp, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'





*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Two year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 2yr sample.dta", clear

* --> Categories
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat client1 ///
	using "$output/m2m exposure/m2m exp categ - All - 2 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat2 client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ v2 - All - 2 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat2 client1 ///
	using "$output/m2m exposure/m2m exp categ v2 - All - 2 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
* --> Mean and median
sum country2, meanonly
foreach i of num 1/`r(max)' {
	putexcel set "$output/m2m exposure/m2m exp mean med - All - 2 year sample country `i' ($S_DATE).xlsx", ///
		sheet(m2m) replace

		putexcel B1 = "Index"
		putexcel C1 = "Child"
		putexcel D1 = "Adolescent"
		putexcel E1 = "Male partner"
		putexcel F1 = "All"
		putexcel A2 = "Mean exposure"
		putexcel A3 = "Median exposure"
		putexcel A4 = "Sample size"

		preserve
		keep if country2==`i'
		
		local k="B"
		sum m2m_exp if client1==1, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="C"
		sum m2m_exp if client1==2, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="D"
		sum m2m_exp if client1==3, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="E"
		sum m2m_exp if client1==4, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="F"
		sum m2m_exp, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		restore
}

putexcel set "$output/m2m exposure/m2m exp mean med - All - 2 year sample ($S_DATE).xlsx", ///
	sheet(m2m) modify
	
putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Mean exposure"
putexcel A3 = "Median exposure"
putexcel A4 = "Sample size"

local k="B"
sum m2m_exp if client1==1, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="C"
sum m2m_exp if client1==2, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="D"
sum m2m_exp if client1==3, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="E"
sum m2m_exp if client1==4, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="F"
sum m2m_exp, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'




/*
*------------------------------------------------------------------------------*
////////////////////////////////////////////////////////////////////////////////
* Three year analysis
////////////////////////////////////////////////////////////////////////////////
*------------------------------------------------------------------------------*

use "$temp/all clients - full dataset - 3yr sample.dta", clear

* --> Categories
sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ - All - 3 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat client1 ///
	using "$output/m2m exposure/m2m exp categ - All - 3 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 


sum country2, meanonly
foreach i of num 1/`r(max)' {
	tabout m2m_exp_cat2 client1 if country2==`i' ///
		using "$output/m2m exposure/m2m exp categ v2 - All - 3 year sample country `i' ($S_DATE).xls", ///
		c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
		clab(_ _) per h3(nil) ///
		replace 
}
tabout m2m_exp_cat2 client1 ///
	using "$output/m2m exposure/m2m exp categ v2 - All - 3 year sample ($S_DATE).xls", ///
	c(col) f(1p 1) lay(row) npos(row) nlab(Sample size) ///
	clab(_ _) per h3(nil) ///
	replace 

	
* --> Mean and median
sum country2, meanonly
foreach i of num 1/`r(max)' {
	putexcel set "$output/m2m exposure/m2m exp mean med - All - 3 year sample country `i' ($S_DATE).xlsx", ///
		sheet(m2m) replace

		putexcel B1 = "Index"
		putexcel C1 = "Child"
		putexcel D1 = "Adolescent"
		putexcel E1 = "Male partner"
		putexcel F1 = "All"
		putexcel A2 = "Mean exposure"
		putexcel A3 = "Median exposure"
		putexcel A4 = "Sample size"

		preserve
		keep if country2==`i'
		
		local k="B"
		sum m2m_exp if client1==1, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="C"
		sum m2m_exp if client1==2, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="D"
		sum m2m_exp if client1==3, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="E"
		sum m2m_exp if client1==4, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		local k="F"
		sum m2m_exp, d
		putexcel `k'2 = `r(mean)', nformat(number_d2)
		putexcel `k'3 = `r(p50)'
		putexcel `k'4 = `r(N)'

		restore
}

putexcel set "$output/m2m exposure/m2m exp mean med - All - 3 year sample ($S_DATE).xlsx", ///
	sheet(m2m) modify
	
putexcel B1 = "Index"
putexcel C1 = "Child"
putexcel D1 = "Adolescent"
putexcel E1 = "Male partner"
putexcel F1 = "All"
putexcel A2 = "Mean exposure"
putexcel A3 = "Median exposure"
putexcel A4 = "Sample size"

local k="B"
sum m2m_exp if client1==1, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="C"
sum m2m_exp if client1==2, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="D"
sum m2m_exp if client1==3, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="E"
sum m2m_exp if client1==4, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'

local k="F"
sum m2m_exp, d
putexcel `k'2 = `r(mean)', nformat(number_d2)
putexcel `k'3 = `r(p50)'
putexcel `k'4 = `r(N)'
