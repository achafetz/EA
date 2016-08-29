**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Import EA data & run outlier analysis
**   Date: August 24, 2016
**   Updated: 8/29

/* NOTES
	- Data source: 2012-2015 Nigeria SAS Output 01FEB16 [PEPFAR.net]
	- Report uses only 2015 EA data
	- Below are the program areas/indicators of focus
	
	EA Beneficiary Types & UE headings [EA Data Nav]
	| Beneficiary Type       | UE                | Beneficiaries  |
	|------------------------|-------------------|----------------|
	| All Age ART            | ART_UE            | ART_PY         |
	| Pregnant Women Tested  | PW_TEST_UE        | PW_TEST        |
	| Pregnant Women on Care | PW_CARE_UE        | PW_CARE        |
	| Infants Tested         | INF_TEST_UE       | INF_TEST       |
	| Infants on Care        | INF_CARE_UE       | INF_CARE       |
	| Males Circumcised      | VMMC_UE           | VMMC_BEN       |
	| HTC Tested             | HTC_UMB_TST_UE    | HTC_UMB_TST    |
	| HTC Positive           | HTC_UMB_TSTPOS_UE | HTC_UMB_TSTPOS |
	| OVC All Care           | OVC_UMB_UE        | OVC_UMB_BEN    |
	| Prevention- PWID       | SORPI_UE          | SORPI_BEN      |
	| Prevention- FSW        | SORPC_UE          | SORPC_BEN      |
	| Prevention- MSMTG      | SORPM_UE          | SORPM_BEN      |
*/
********************************************************************************

*SETUP

	*import data
		capture confirm file "$output\nigeria_ea.dta"
			if !_rc{
				use "$output\nigeria_ea.dta", clear
			}
			else{
				import delimited "$data\2012-2015 Nigeria SAS Output 01FEB16.csv", clear
				save "$output\nigeria_ea.dta", replace
			}

	*clean up dataset
		keep if rptgcycle==2015
		drop if data_type=="De-dup"
		keep mech_hq_id yr_agency_promisid_snu rptgcycle national_sub_unit ///
			national_sub_sub_unit mech_partner mech_name mech_promis_id ///
			art_ue art_py pw_test_ue pw_test pw_care_ue pw_care inf_test_ue ///
			inf_test inf_care_ue inf_care vmmc_ue vmmc_ben htc_umb_tst_ue ///
			htc_umb_tst htc_umb_tstpos_ue htc_umb_tstpos ovc_umb_ue ///
			ovc_umb_ben sorpi_ue sorpi_ben sorpc_ue sorpc_ben sorpm_ue sorpm_ben
	*rename for uniformity (for reshaping)
		foreach v in art_py pw_test pw_care inf_test inf_care ///
			htc_umb_tst htc_umb_tstpos {
			rename `v' `v'_ben
			}
			*end
		rename art_py_ben art_ben //match w/ ue
	*reshape
		reshape long @_ben @_ue, i(yr_agency_promisid_snu) j(type, string) 
		rename _ben ben
			lab var ben "Beneficiaries"
		rename _ue ue
			lab var ue "Unit Expenditure"
	*drop if rows have no data
		egen rmax = rmax(ben ue)
		drop if inlist(rmax, ., 0)
		drop rmax

*OUTLIERS		
	*idenfity outliers
		local ol 5 //set outlier level (default 5x Weight Avg UE)
		gen exp = ue*ben // mechanism expenditures for that prog area
			lab var exp "Expenditures"
		bysort type: egen tot_exp = total(ue*ben) //total expenditures in prog area
		bysort type: egen tot_ben = total(ben) // total beneficiaries in prog area
		bysort type: gen wa_ue = tot_exp/tot_ben // weighted average UE
			lab var wa_ue "Weighted Avg UE"
		bysort type: gen wa_ue_ol = wa_ue * `ol' // UE outlier threshold (high)
		*by type: gen wa_ue_ol_low = wa_ue / `ol' // UE outlier threshold (low; not manditory)
		by type: gen outlier = 0 //identify outliers
			replace outlier = 1 if ue>wa_ue_ol & ue!=.
			lab var outlier "Outlier (`ol'x Weighted Avg UE)"
			*replace outlier = 1 if ue<wa_ue_ol_low //can remove; not manditory
			lab def yn 0 "No" 1 "Yes"
			lab val outlier yn
		drop tot* wa_ue_ol //only needed to create outlier
		
*CLEAN UP	
	*rename each type to align w/ EA exp indicator
		preserve // preserve current file while creating a crosswalk table on the side
		clear
		input str14 (type exp_ind) //crosswalk table
			"art" "FBCTS"
			"htc_umb_tst" "HTC_TST"
			"htc_umb_tstpos" "HTC_POS"
			"inf_care" "PMTCT_INF_TX"
			"inf_test" "PMTCT_INF_TST"
			"ovc_umb" "OVC"
			"pw_care" "PMTCT_WOM_TX"
			"pw_test" "PMTCT_WOM_TST"
			"sorpc" "KP_FSW"
			"sorpi" "KP_PWID"
			"sorpm" "KP_MSMTG"
			end
		tempfile temp_cw //create a temporary file for saving the crosswalk table
		save "`temp_cw'"
		restore // restore the EA data
		merge m:1 type using "`temp_cw'", nogen //merge in crosswalk table
	*cleanup for merging
		drop yr_agency_promisid_snu-mech_name national_sub_sub_unit mech_promis_id ben
		order exp_ind, before(ue)
		rename national_sub_unit snu1
		rename mech_hq_id mechanismid
		replace snu1="FCT" if snu1=="Abuja Federal Capital Territory"
	*rename ea variables
		foreach v of varlist ue-outlier{
			rename `v' fy2015apr_ea_`v'
		}
		*end
	*save
		save "$output\temp_eadata.dta", replace	
