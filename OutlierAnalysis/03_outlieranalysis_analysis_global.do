**   EA Outlier Analysis
**   COP FY16
**   Aaron Chafetz
**   Purpose: identify UE outliers by program area, globally
**   Date: Sept 16, 2016
**   Updated: 


*SETUP
	
	*unzip file
		cd "$data"
		unzipfile "2015 SAS Output allcntry 8.26.16.zip", replace
		cd "$projectpath"

	*import data
		capture confirm file "$output\allctry_ea.dta"
			if !_rc{
				use "$output\allctry_ea.dta", clear
			}
			else{
				import delimited "$data\2015 SAS Output allcntry 8.26.16.csv", clear
				save "$output\allctry_ea.dta", replace
			}

	*clean up dataset to only rows/columns needed
		keep if rptgcycle==2015
		drop if data_type=="De-dup" | national_sub_unit=="National"
		keep ou mech_agency mech_hq_id yr_agency_promisid_snu rptgcycle national_sub_unit ///
			national_sub_sub_unit mech_partner mech_name mech_promis_id ///	
			cbcts_umb_ben cbcts_umb_ue cbcts_ecstrngth_ben cbcts_ecstrngth_ue ///
			cbcts_medcare_ben cbcts_medcare_ue cbcts_nutrtn_ben cbcts_nutrtn_ue ///
			cbcts_care_ben cbcts_care_ue mmt_ben mmt_ue vmmc_ben vmmc_ue ///
			ovc_umb_ben ovc_umb_ue ovc_ecstrngth_ben ovc_ecstrngth_ue ///
			ovc_edsprt_ben ovc_edsprt_ue sorpc_ben sorpc_ue sorpm_ben sorpm_ue ///
			sorpi_ben sorpi_ue sorpo_ben sorpo_ue adltart_py adltart_ue adltpreart_py ///
			adltpreart_ue art_py art_ue preart_py preart_ue chldart_py ///
			chldart_ue chldpreart_py chldpreart_ue htc_cbtc_tstpos ///
			htc_cbtc_tstpos_ue htc_cbtc_tst htc_cbtc_tst_ue htc_pitc_tstpos ///
			htc_pitc_tstpos_ue htc_pitc_tst htc_pitc_tst_ue htc_umb_tstpos ///
			htc_umb_tstpos_ue htc_umb_tst htc_umb_tst_ue htc_vct_tstpos ///
			htc_vct_tstpos_ue htc_vct_tst htc_vct_tst_ue inf_test inf_test_ue ///
			inf_testpos inf_testpos_ue inf_care inf_care_ue pw_test pw_test_ue ///
			pw_testpos pw_testpos_ue pw_care pw_care_ue

	*rename for uniformity (for reshaping) (all have _ben)
		foreach v in adltart_py adltpreart_py art_py preart_py ///
			chldart_py chldpreart_py{
			rename `v' `=subinstr("`v'", "py", "ben",.)'
			}

		foreach v in htc_cbtc_tstpos htc_cbtc_tst htc_pitc_tstpos ///
			htc_pitc_tst htc_umb_tstpos htc_umb_tst htc_vct_tstpos ///
			htc_vct_tst inf_test inf_testpos inf_care pw_test ///
			pw_testpos pw_care{
			rename `v' `v'_ben
			}
			*end
	
	*reshape
		reshape long @_ben @_ue, i(yr_agency_promisid_snu) j(type, string) 
		rename _ben ben
			lab var ben "Beneficiaries"
		rename _ue ue
			lab var ue "Unit Expenditure"
	*drop if rows have no data or ue=0
		egen rmax = rmax(ben ue)
		drop if inlist(rmax, ., 0)
		drop rmax
		drop if ue==0
		

*OUTLIERS		
	*idenfity outliers
		local ol 5 //set outlier level (default 5x Weight Avg UE)
		gen exp = ue*ben // mechanism expenditures for that prog area
			lab var exp "Expenditures"
		sort ou type
		egen id_ou_type = group (ou type) // use group to create weighted ue for each program area within an OpUnit
		bysort id_ou_type: egen tot_exp = total(ue*ben) //total expenditures in prog area
		bysort id_ou_type: egen tot_ben = total(ben) // total beneficiaries in prog area
		bysort id_ou_type: gen wa_ue = tot_exp/tot_ben // weighted average UE
			lab var wa_ue "Weighted Avg UE"
		bysort id_ou_type: gen wa_ue_ol = wa_ue * `ol' // UE outlier threshold (high)
		bysort id_ou_type: gen outlier = 0 //identify outliers
			replace outlier = 1 if ue>wa_ue_ol & ue!=.
			lab var outlier "Outlier (`ol'x Weighted Avg UE)"
			lab def yn 0 "No" 1 "Yes"
			lab val outlier yn
		drop tot* wa_ue_ol id_ou_type yr_agency_promisid_snu mech_promis_id //only needed to create outlier

*REPORT
	*clean up agency names
		split mech_agency, parse("(" ")")
		replace mech_agency2 = "PC" if mech_agency1 == "U.S. Peace Corps"
		drop mech_agency mech_agency1
		rename mech_agency2 agency
	*make program area names all upper case
		replace type = upper(type)
	*reorder
		order rptgcycle ou agency mech_hq_id mech_partner mech_name ///
			national_sub_unit national_sub_sub_unit
	*export data
		export excel using "$excel/global_ol_analysis_ea15.xlsx", ///
			firstrow(variables) sheet("Data") sheetreplace nolabel
	

		
		
		
		
		
		
		
		
		
		
		
		
