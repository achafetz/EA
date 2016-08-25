**   Funding Types and UEs
**   COP FY16
**   Aaron Chafetz
**   Purpose: incorporate EA data
**   Date: June 21, 2016
**   Updated: 

/* NOTES
	- Data source: ICPIFactView - SNU by IM Level_db-frozen_20160617 [Data Hub]
	- FY2015 APR
	- Report looks across HTC_TST, HTC_TST_POS, PMTCT_STAT, PMTCT_ARV, PMTCT_EID,
		TX_NEW, TX_CURR, OVC_SERV, VMMC_CIRC		
*/

*set directory
	cd "C:\Users\achafetz\Documents\GitHub\EA\FundingType"
*import data
	import excel "\RawData\SouthAfrica 2015 EA Data Nav Tool v02.02.16 updated.xlsx", ///
	sheet("Totals_MCCNav") firstrow case(lower) clear
	save "StataOutput\eadata_sa.dta", replace
	
use "StataOutput\eadata_sa.dta", clear

*subset
	drop if rptgcycle!=2015
	keep rptgcycle locationid mech_agency mech_partner mech_name mech_hq_id ///
		mech_legacy_id mech_promis_id national_sub_unit national_sub_sub_unit ///
		data_type htc_inv_tr htc_inv_const_ren htc_inv_vehi htc_inv_eqp_furn ///
		htc_inv_othexp htc_rec_pers htc_rec_arv htc_rec_nonarv htc_rec_hivtest ///
		htc_rec_condom htc_rec_othsupply htc_rec_food htc_rec_bldgrental ///
		htc_rec_trvl htc_rec_othexp pm_htc_tot si_htc_tot hss_htc_tot ///
		htc_umb_tst htc_umb_tstpos htc_umb_tst_ue htc_umb_tstpos_ue

*remove characters at beginning of PSNU name
gen psnu2 = substr(psnu,4,.) if psnu
drop psnu2
