**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: genereate SAPR Unit Expednitures
**   Date: August 29, 2016
**   Updated:


*open
	use "$output\temp_merge.dta", clear
*remove National since no national data was collected
	drop if snu1=="National"
	
*generate UEs
	gen ue = fy2016sapr_ea_exp/fy2016sapr

*idenfity outliers
	local ol 5 //set outlier level (default 5x Weight Avg UE)
	bysort exp_ind: egen tot_exp = total(fy2016sapr_ea_exp) //total expenditures in prog area
	bysort exp_ind: egen tot_ben = total(fy2016sapr) // total beneficiaries in prog area
	bysort exp_ind: gen wa_ue = tot_exp/tot_ben if fy2016sapr!=. & fy2016sapr_ea_exp!=. // weighted average UE
		lab var wa_ue "Weighted Avg UE"
	bysort exp_ind: gen wa_ue_ol = wa_ue * `ol' // UE outlier threshold (high)
	*by exp_ind: gen wa_ue_ol_low = wa_ue / `ol' // UE outlier threshold (low; not manditory)
	by exp_ind: gen outlier = 0 //identify outliers
		replace outlier = 1 if ue>wa_ue_ol & ue!=.
		lab var outlier "Outlier (`ol'x Weighted Avg UE)"
		*replace outlier = 1 if ue<wa_ue_ol_low //can remove; not manditory
		lab val outlier yn
	drop tot* wa_ue_ol //only needed to create outlier

*rename ea variables
		foreach v of varlist ue-outlier{
			rename `v' fy2016sapr_ea_`v'
		}
		*end
*reorder 
	order fy2015apr_ea_exp fy2015apr_ea_ue fy2015apr_ea_wa_ue ///
		fy2015apr_ea_outlier fy2016_targets fy2016sapr fy2016sapr_ea_exp ///
		fy2016sapr_ea_ue fy2016sapr_ea_wa_ue fy2016sapr_ea_outlier, last
*save 
	save "$output\NigeriaSAPRdataEA.dta", replace

*export
	export delimited using "$excel\NigeriaSAPRdataEA", replace 

*remove temporary files
	fs "$output\temp*.dta"
	foreach f in `r(files)'{
		erase `f'
		}
		*end
