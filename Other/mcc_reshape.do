**   EA Data Nav Dataset Reshape
**   COP FY16
**   Aaron Chafetz
**   Purpose: reshape the EA Data Nav Tool's dataset structure for ease of use
**   Date: October 5, 2016
**   Updated: 11/7/16

/* NOTES
	- Data source: 2012-2015 Malawi SAS Output 01FEB16 [PEPFAR.net]
*/

** IMPORT EA Break Out Table **
preserve
cd "C:\Users\achafetz\Documents\GitHub\EA\Other\"
import excel using "EATable.xlsx", clear firstrow
save "eatable", replace
restore

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
				rename `pa'`cc' `pa'`cc'_exp_kp
			}
			rename hss_`pa'_tot hss_`pa'_tot_kp
			}
			*end
	
	*above site major ccs
		*adjust inline with program area
		foreach pa in fbcts cbcts pmtct vmmc htc pep bs ic lab ovc sorpg sorpo ///
			sorpi sorpc sorpm mmt {
			foreach cat in pm si hss{
				rename `cat'_`pa'_tot `pa'_`cat'_tot_exp_kp
			}
			}
			*end
		*rename lab, hss, and surv ccs
		rename lab_fbcts_total fbcts_lab_tot_exp_kp
		rename lab_exp_pmtct pmctct_lab_tot_exp_kp
		rename hss hss_tot_exp_kp
		rename surveillance surveillance_exp_kp
		rename grand_tot grand_tot_exp_kp
		
		*rename loaded and other total expenses
		ds *loaded_tot
		foreach v in `r(varlist)'{
			rename `v' `v'_exp_kp
		}
		foreach v in si_pm_oth hss_si_tot hss_surv_tot hss_pm_oth hss_si_oth{
			rename `v' `v'_exp_kp
		}
		*end
** REMOVE EXCESS VARIABLES/COLUMNS **
	keep locationid rptgcycle ou mech_agency mech_partner mech_name ///
		mech_hq_id mech_promis_id national_sub_unit national_sub_sub_unit ///
		data_type *_kp 

** RESHAPE **
	replace mech_partner = "PEPFAR" if mech_partner==""
	replace mech_name = "PEPFAR" if mech_name==""
	
	reshape long @_kp, i(rptgcycle mech_agency mech_hq_id national_sub_unit data_type) j(progarea, string)
	rename _kp fy
	
	merge m:1 progarea using eatable.dta, nogen
	drop if rptgcycle==.
	reshape wide fy, i(mech_agency mech_hq_id national_sub_unit data_type progarea) j(rptgcycle)
	
	egen rowtot = rowtotal(fy*)
	drop if rowtot==0
	drop rowtot progarea

	order mech_agency ou locationid national_sub_unit national_sub_sub_unit ///
		mech_hq_id mech_promis_id mech_partner mech_name data_type prog_area ///
		type exp_cc_maj exp_cc fy2013 fy2014 fy2015
		
	format fy* %10.2fc
	
	
	replace data_type="Direct" if data_type=="DIRECT"
	replace data_type="De-dup" if data_type=="De-Dup"
	
	
	sort data_type locationid mech_hq_id prog_area type exp_cc_maj exp_cc
	*collapse (sum) fy*, by(mech_agency-exp_cc)
	
	save newoutput.dta, replace
