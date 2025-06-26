*** APR 2020 - PMTCT cascade
*** Import and append new version exports
* 12 Feb 2021


* --> Import data
foreach folder in exit an new pn {
	foreach n in 2020 2021 {
		clear
		local files: dir "$input_appdata/New version/App1/`folder'/`n'/" files "*.xlsx"
		cd "$input_appdata/New version/App1/`folder'/`n'/"
		foreach file in `files' {
			import excel using "`file'", clear allstring
			save "$temp_appdata/New version/App1/`folder'/`n'/`file'.dta", replace
			sleep 50
		}
		sleep 50
	}
}


* --> Append each form's datasets together
foreach folder in exit an new pn {
	foreach n in 2020 2021 {
		clear
		cd "$temp_appdata/New version/App1/`folder'/`n'"
		local filelist: dir . files "*.dta"  	
		local total: word count `filelist'
		local first: word 1 of `filelist'      
		use "`first'", clear
		forvalues x = 2/`total' {
			local y: word `x' of `filelist'
			append using "`y'"
		}
		duplicates drop
		save "$temp_appdata/New version/App1/`folder'/`folder'_`n'.dta", replace
	}
}


* --> Delete the individual temp datasets created
foreach folder in exit an new pn {
	foreach n in 2020 2021 {
		local files: dir "$temp_appdata/New version/App1/`folder'/`n'" files "*.dta"
		cd "$temp_appdata/New version/App1/`folder'/`n'"
		foreach file in `files' {
			erase "`file'"
			sleep 50
		}
		sleep 50
	}
}
