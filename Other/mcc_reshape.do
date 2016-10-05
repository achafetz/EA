**   EA Data Nav Dataset Reshape
**   COP FY16
**   Aaron Chafetz
**   Purpose: reshape the EA Data Nav Tool's dataset structure for ease of use
**   Date: October 5, 2016
**   Updated: 

/* NOTES
	- Data source: 2012-2015 Malawi SAS Output 01FEB16 [PEPFAR.net]
*/

** IMPORT DATA
	
	cd "C:\Users\achafetz\Documents\GitHub\EA\OutlierAnalysis\StataOutput\"
	*use
		use "Malawi_datanav.dta", clear 
		cd "C:\Users\achafetz\Documents\GitHub\EA\Other\"
		
** CREATE UNIFORMITY FOR RESHAPING **
	*adjust variable for uniformity and add _kp at end to identify as keeping
	
	*beneficiaries (all _ben)
		*change _py to _ben
		foreach v in adltpreart_py chldpreart_py adltart_py chldart_py preart_py ///
			art_py {
			rename `v' `=regexr("`v'","py","ben_kp")'
			}
			*end
		*add _ben
		foreach v in pw_test pw_testpos pw_care inf_test inf_testpos inf_care ///
			htc_umb_tst htc_umb_tstpos htc_pitc_tst htc_pitc_tstpos htc_vct_tst ///
			htc_vct_tstpos htc_cbtc_tst htc_cbtc_tstpos{
			rename `v' `v'_ben_kp
			}
			*end
		*identify others as keeping (_kp)
		foreach v in cbcts_umb_ben cbcts_medcare_ben cbcts_ecstrngth_ben ///
			cbcts_care_ben cbcts_nutrtn_ben ovc_umb_ben ovc_edsprt_ben ///
			ovc_ecstrngth_ben sorpg_ben sorpo_ben sorpi_ben sorpc_ben ///
			sorpm_ben mmt_ben vmmc_ben{
			rename `v' `v'_kp
			}
			*end
	
	*unit expenditures
		*UEs (all _ue)
		foreach v in adltart_uenoarv chldart_uenoarv art_uenoarv{
			rename `v' `=regexr("`v'","uenoarv","noarv_ue_kp")'
			}
			*end
		*identify others as keeping (_kp)
		foreach v in adltpreart_ue chldpreart_ue adltart_ue chldart_ue ///
			preart_ue art_ue cbcts_umb_ue cbcts_medcare_ue cbcts_ecstrngth_ue ///
			cbcts_care_ue cbcts_nutrtn_ue pw_test_ue pw_testpos_ue pw_care_ue ///
			inf_test_ue inf_testpos_ue inf_care_ue vmmc_ue htc_umb_tst_ue ///
			htc_umb_tstpos_ue htc_pitc_tst_ue htc_pitc_tstpos_ue ///
			htc_vct_tst_ue htc_vct_tstpos_ue htc_cbtc_tst_ue htc_cbtc_tstpos_ue ///
			ovc_umb_ue ovc_edsprtnew_ue ovc_ecstrngthnew_ue sorpg_ue ///
			sorpo_ue sorpi_ue sorpc_ue sorpm_ue mmt_ue{
			rename `v' `v'_kp
			}
			*end
	*cost categories
		*identify ccs to keep
		foreach pa in fbcts cbcts pmtct vmmc htc pep bs ic lab ovc sorpg sorpo ///
			sorpi sorpc sorpm mmt{
			foreach cc in _inv_tr _inv_const_ren _inv_vehi _inv_eqp_furn ///
				_inv_othexp _rec_pers _rec_arv _rec_nonarv _rec_hivtest ///
				_rec_condom _rec_othsupply _rec_food _rec_bldgrental /// 
				_rec_trvl _rec_othexp{
				rename `pa'`cc' `pa'`cc'_kp
			}
			}
			*end
	
	*above site major ccs
		*adjust inline with program area
		foreach pa in fbcts cbcts pmtct vmmc htc pep bs ic lab ovc sorpg sorpo ///
			sorpi sorpc sorpm mmt {
			foreach cat in pm si hss{
				rename `cat'_`pa'_tot `pa'_`cat'_tot_kp
			}
			}
			*end
		*rename two lab ccs
		rename lab_fbcts_total fbcts_lab_tot_kp
		rename lab_exp_pmtct pmctct_lab_tot_kp
 
** REMOVE EXCESS VARIABLES/COLUMNS **
	keep locationid rptgcycle ou mech_agency mech_partner mech_name ///
		mech_hq_id mech_promis_id national_sub_unit national_sub_sub_unit ///
		data_type *_kp 
	*remove _kp from all vars
		ds *_kp
		foreach v in `r(varlist)'{
			rename `v' `=regexr("`v'","_kp","")'
		}
		*end
		
** RESHAPE **
	replace mech_partner = "na" if mech_partner==""
	replace mech_name = "na" if mech_name==""
	egen id = group(locationid rptgcycle ou mech_agency mech_partner ///
		mech_name mech_hq_id mech_promis_id national_sub_unit ///
		national_sub_sub_unit data_type)
	reshape long fbcts_ cbcts_ pmtct_ vmmc_ htc_ pep_ bs_ ic_ lab_ ovc_ ///
		sorpg_ sorpo_ sorpi_ sorpc_ sorpm_ mmt_, i(id) j(progarea, string) 


