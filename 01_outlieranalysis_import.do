**   EA Outlier Analysis
**   COP FY16
**   Aaron Chafetz
**   Purpose: import EA raw data files and program area names
**   Date: Jan 31, 2016
**   Updated: Feb 5, 2016


** EA DATA **

	*import and save EA Data
		*note: all raw data file should be saved as ctry.xlsx
		local files : dir "$data/" files "*.xlsx"
		foreach file in `files' {
			capture confirm file "$output/`=regexr("`file'",".xlsx","")'_datanav.dta"
			if _rc {
				import excel using "$data/`file'", firstrow case(lower) clear
				save "$output/`=regexr("`file'",".xlsx","")'_datanav.dta", replace
				}
			}
			
** PROGRAM AREA INFORMATION **

	*import data validation info
		/*note: only need to import once for one country you are using; adjust 
			country after the backslash if using a diff country */
		import excel "$data/Malawi", ///
			sheet("Validations") cellrange(N1:S37) clear
		rename (N O P Q) (pg_name ben_type pg_ue_name pg_ben_name)
			lab var pg_name "Program Area Name"
			lab var ben_type "Type of Beneficiary"
			lab var pg_ue_name "Program Area UE Variable Name"
			lab var pg_ben_name "Program Area Beneficiary Variable Name"
		drop R S
		replace pg_ue_name = lower(pg_ue_name)
		replace pg_ben_name = lower(pg_ben_name)
		merge 1:1 pg_name using areas.dta
		drop if _merge!=3
		drop _merge
		drop if pa_area==""
		lab var pa_area "Program Area"
		lab var pg_name "Unit Expenditure Label/Indicator
		save "$output/datanav_val.dta", replace
