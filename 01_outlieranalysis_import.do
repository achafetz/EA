**   EA Outlier Analysis
**   COP FY16
**   Aaron Chafetz
**   Date: Jan 31, 2016
**   Updated: Feb 5, 2016


*** EA DATA ***

	*import and save EA Data
		local files : dir "$data/" files "*.xlsx"
		foreach file in `files' {
			capture confirm file "$output/`=regexr("`file'",".xlsx","")'_datanav.dta"
			if _rc {
				import excel using "$data/`file'", firstrow case(lower) clear
				save "$output/`=regexr("`file'",".xlsx","")'_datanav.dta", replace
				}
			}
			
*** PROGRAM AREA INFORMATION ***

	*import program categories and areas for outlier analysis tab
		import excel "areas.xlsx", firstrow clear
		save areas.dta, replace

	*import data validation info
		import excel "$data/Malawi", sheet("Validations") cellrange(N1:S37) clear
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
		save datanav_val.dta, replace
