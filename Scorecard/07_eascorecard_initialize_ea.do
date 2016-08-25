**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Import EA data & run outlier analysis
**   Date: August 24, 2016
**   Updated:

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
		import delimited "$data\2012-2015 Nigeria SAS Output 01FEB16.csv", clear
		save "$output\nigeria_ea.dta", replace
		use "$output\nigeria_ea.dta", clear

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
		rename art_py art_ben
		rename pw_test pw_test_ben
		rename pw_care pw_care_ben
		rename inf_test inf_test_ben
		rename inf_care inf_care_ben
		rename htc_umb_tst htc_umb_tst_ben
		rename htc_umb_tstpos htc_umb_tstpos_ben
	*reshape
		reshape long @_ben @_ue, i(yr_agency_promisid_snu) j(type, string) 
		rename _ben ben
		rename _ue ue
	*drop if rows have no data
		egen rmax = rmax(ben ue)
		drop if rmax==0
		drop rmax
		
	*sum up all expenditures
		local ol 5 //set outlier level (default 5x Weight Avg UE)
		sort type
		by type: egen tot_exp = total(ue*ben) //total expenditures in prog area
		by type: egen tot_ben = total(ben) // total beneficiaries in prog area
		by type: gen wa_ue = tot_exp/tot_ben // weighted average UE
		by type: gen wa_ue_ol = wa_ue * `ol' // UE outlier threshold (high)
		*by type: gen wa_ue_ol_low = wa_ue / `ol' // UE outlier threshold (low; not manditory)
		by type: gen outlier = 0 //identify outliers
			replace outlier = 1 if ue>wa_ue_out & ue!=.
			replace outlier = 1 if ue<wa_ue_out_low //can remove; not manditory
			lab def yn 0 "No" 1 "Yes"
			lab val outlier yn
	
	*rename each type to align w/ EA exp indicator
	*save
