*** App2 - New version versions
*** Import and append
* 31 March 2021


* --> Import data 
foreach folder in reg_index reg_hhmem caregiver infant partner ///
	exit_index childadol {
		foreach n in 2020 2021{
		clear
		local files: dir "$commcare_appdata/New version/App2/`folder'/`n'/" files "*.xlsx"
		cd "$commcare_appdata/New version/App2/`folder'/`n'/"
		foreach file in `files' {
			import excel using "`file'", clear allstring
			save "$temp_appdata/New version/App2/`folder'/`n'/`file'.dta", replace
			sleep 50
		}
		sleep 50
	}
}


* --> Append each form's datasets together 
foreach folder in reg_index reg_hhmem caregiver infant partner ///
	exit_index childadol {
		foreach n in 2020 2021 {
			clear
			cd "$temp_appdata/New version/App2/`folder'/`n'"
			local filelist: dir . files "*.dta"  	
			local total: word count `filelist'
			local first: word 1 of `filelist'      
			use "`first'", clear
			forvalues x = 2/`total' {
				local y: word `x' of `filelist'
				append using "`y'"
			}
			duplicates drop
			save "$temp_appdata/New version/App2/`folder'/`folder'_`n'.dta", replace
		}
}


* --> Delete the individual temp datasets created
foreach folder in reg_index reg_hhmem caregiver infant partner ///
	exit_index childadol {
		foreach n in 2020 2021{
			local files: dir "$temp_appdata/New version/App2/`folder'/`n'" files "*.dta"
			cd "$temp_appdata/New version/App2/`folder'/`n'"
			foreach file in `files' {
				erase "`file'"
				sleep 50
			}
			sleep 50
		}
}

