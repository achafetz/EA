**   EA Outlier Analysis
**   COP FY16
**   Aaron Chafetz
**   Purpose: identify UE outliers by program area
**   Date: Jan 31, 2016
**   Updated: March 22, 2016


* close out any open log files
	capture confirm log close
		if !_rc log close
			
*define set of countries to analyze (must match .dta file names)
	foreach ctry in Tanzania{
	
	// OUTLIER ANALYSIS //

	*start log (window will display UEs by program area, no other output)
		qui: log using "$excel/`ctry'_Summary$S_DATE.csv", text replace
		
	*store local values to use in analysis
		local ol 5 //set outlier level (default 5x Weight Avg UE)
		local i 0 //used to identify beneficiary type
		local tot_outliers 0 //stores cumulative outliers for output in log
		local tot_obs 0 //stores cumulative observations for output in log
		
	*loop over each program area
		foreach type in cbcts_umb cbcts_ecstrngth cbcts_medcare cbcts_nutrtn ///
			cbcts_care mmt vmmc ovc_umb ovc_ecstrngth ovc_edsprt sorpc ///
			sorpm sorpi sorpo adltart adltpreart art preart chldart chldpreart ///
			htc_cbtc_tstpos htc_cbtc_tst htc_pitc_tstpos htc_pitc_tst ///
			htc_umb_tstpos htc_umb_tst htc_vct_tstpos htc_vct_tst ///
			inf_test inf_testpos inf_care pw_test pw_testpos pw_care{
		
		*open dataset
			use "$output/`ctry'_datanav.dta", clear
		*rename type for different beneficiaries and ues for simiplicty in code
			local i = `i' + 1
			if `i' <15 rename `type'_ben ben //cbcts_umb-sorpo
			if `i' >=15 & `i' <21 rename `type'_py ben //adltart-chldpreart
			if `i' >=21 rename `type' ben //htc_cbtc_tstpost-pw_care
			rename `type'_ue ue 
		*csv headers (log output)
			if `i'==1 di "#, Prog Area, Avg UE, `ol'x Avg UE, Avg UE/`ol', Outliers, Tot Obs"
		*drop observations to meet criteria, no National, no De-Dup, no UE<=0 | UE==.
			qui: drop if national_sub_unit == "National" | data_type=="De-dup" | ue<=0 | ue==.
		*keep only necessary variables
			qui: keep yr_agency_promisid_snu rptgcycle national_sub_unit ///
				national_sub_sub_unit mech_partner mech_name mech_promis_id ue ben
		*make sure there are observations for reporting cycle 2015; else exit
			qui: sum rptgcycle if rptgcycle==2015
			local pa_obs `r(N)' //stores count of observations
			local tot_obs = `tot_obs' + `pa_obs' //running total
			if `r(N)' == 0 {
				di "`i',`=upper("`type'")',,,,,0"
				continue //skip remaining code in loop; move on to next prog area
				}
		*identify # of years in dataset	
			qui: levelsof rptgcycle, local(years) // loop over years 2013-2015; not all variables have same # of years
		*reshape so that UE and Beneficiaries for each year are seperate variables/columns
			qui: reshape wide ben ue, i(yr_agency_promisid_snu) j(rptgcycle) 
				drop yr_agency_promisid_snu //only needed for unique id
		*collapse to "merge" 2013 and 2014 observation onto 2015 programs
			qui: lookfor 20 //identify UE and beneficiary variables in 2013, 2014, and/or 2015
			qui: collapse (max) `r(varlist)', ///
				by(mech_partner mech_name mech_promis_id national_sub_unit national_sub_sub_unit)
				drop national_sub_unit //only needed for unique id
		*create lab val
			lab def yn 0 "No" 1 "Yes"
		*sum up all expenditures
			foreach y of local years{ 
				qui: egen tot_exp_`y' = total(ue`y'*ben`y') //total expenditures in prog area
				qui: egen tot_ben_`y' = total(ben`y') // total beneficiaries in prog area
				qui: gen wa_ue_`y' = tot_exp_`y'/tot_ben_`y' // weighted average UE
				qui: gen wa_ue_out_`y' = wa_ue_`y' * `ol' // UE outlier threshold (high)
				qui: gen wa_ue_out_`y'_low = wa_ue_`y' / `ol' // UE outlier threshold (low; not manditory)
				qui: gen outlier_`y' = 0 //identify outliers
					qui: replace outlier_`y' = 1 if ue`y'>wa_ue_out_`y' & ue`y'!=.
					qui: replace outlier_`y' = 1 if ue`y'<wa_ue_out_`y'_low //can remove; not manditory
					lab val outlier_`y' yn
				}
				*end
			
		*store values for UEs/outliers to display in output
			qui: sum wa_ue_2015, meanonly
				local wa `r(mean)'
			qui: sum wa_ue_out_2015, meanonly
				local wa_out `r(mean)'
			qui: sum wa_ue_out_2015_low, meanonly
				local wa_out_low `r(mean)'
			qui: sum outlier_2015 if outlier_2015==1
			di "`i',`=upper("`type'")', `wa' , `wa_out', `wa_out_low',`r(N)', `pa_obs'"
			local tot_outliers = `tot_outliers' + `r(N)'

		*exit rest of loop for prog area if no outliers in 2015
			qui: sum outlier_2015 if outlier_2015==1
			if `r(N)' == 0 {
				continue
				}
		*merge prog area variables w/ prog area names
			qui: gen pg_ue_name = "`type'_ue" // create key variable to merge off of
			qui: merge m:1 pg_ue_name using "$output/datanav_val.dta", ///
				keep(master matches) nogen noreport
		*gen outlier level and type (high v low)
			qui: gen outlierlvl = "`ol'x" //eg 5x
				lab var outlierlvl "Outlier Cutoff Value Used"
			qui: gen oltype = "High" if ue2015>wa_ue_out_2015 & ue2015!=.
				qui: replace oltype = "Low" if ue2015<wa_ue_out_2015 & ue2015!=.
				lab var oltype "Type of Outlier (High/Low)"
		*keep only those obs that had outliers in 2015
			qui: keep if outlier_2015==1
			qui: drop outlier_2015
		*add in missing outlier years if they do not exist
			foreach y in 2014 2013{
				capture confirm variable outlier_`y'
				if _rc {
					qui: gen outlier_`y' = .
					}
				}
			lab val outlier_* yn
		*reoder to match outlier analysis outlier analysis tab in Data Nav 
			order pa_area pg_name outlierlvl oltype mech_partner mech_name ///
				national_sub_sub_unit ue2015 ben2015 ///
				outlier_2014 outlier_2013
			qui: keep pa_area-outlier_2013 //keep only variables to match tab
		*relabel to match outlier analysis tab
			lab var pa_area "Program Area"
			lab var mech_partner "Partner Name"
			lab var mech_name "Mechanism Name"
			lab var national_sub_sub_unit "SNU"
			lab var ue2015 "Outlier UE Value"
			lab var ben2015 "Outlier UE Beneficiary Volume"
			lab var outlier_2014 "Was this IM or IM-SNU an outlier in EA 2014?"
			lab var outlier_2013 "Was this IM or IM-SNU an outlier in EA 2013?"
		*save prog area output file
			qui: save "$output/temp_`type'.dta", replace	
		*display overal total outliers and observations
			if `i' == 34 di ",Total,,,,`tot_outliers',`tot_obs'"
		}
		
		qui: log close
			
	// APPEND PROGRAM AREA OUTPUTS //

	*append prog area output files
		use "$output/temp_htc_umb_tst", clear
		foreach type in cbcts_umb cbcts_ecstrngth cbcts_medcare cbcts_nutrtn ///
			cbcts_care mmt vmmc ovc_umb ovc_ecstrngth ovc_edsprt sorpc ///
			sorpm sorpi sorpo adltart adltpreart art preart chldart chldpreart ///
			htc_cbtc_tstpos htc_cbtc_tst htc_pitc_tstpos htc_pitc_tst ///
			htc_umb_tstpos htc_vct_tstpos htc_vct_tst ///
			inf_test inf_testpos inf_care pw_test pw_testpos pw_care{
		*check to see if file exists
			capture confirm file "$output/temp_`type'.dta"
		*if file exists, append and save
			if !_rc{
				qui: append using "${output}/temp_`type'.dta"
				qui: save "$output/`ctry'_outliers.dta", replace
				erase "$output/temp_`type'.dta
				}
		}
		*drop 
			erase "$output/temp_htc_umb_tst.dta"
				
	// EXPORT APPENDED FILE TO EXCEL //
		qui: export excel "$excel/`ctry'_OutlierAnalysis $S_DATE.xlsx", firstrow(varlabels) replace
	
}
			
