**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Initialize data structure
**   Date: August 24, 2016
**   Updated: 9/13/16

/* NOTES
	- Data source: ICPIFactView - SNU by IM Level_db-frozen_20160822 [Data Hub]
	- Report aggregates DSD and TA
	
	EA Needed to create Variable to Create (8/31, A.Chen)
	| EA Program Area                          | Expenditure indicators    | SI Indicators                                                                                                                                                       |
	|------------------------------------------|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
	| Facility-based Care & Treatment Services | FBCTS                     | TX_CURR (total numerator) - PMTCT_ART (total numerator)                                                                                                             |
	| PMTCT                                    | PMTCT- Women Tested       | PMTCT_STAT (total numerator) - PMTCT_STAT_POS (total denominator for PMTCT ART)                                                                                     |
	| PMTCT                                    | PMTCT- Women on Treatment | PMTCT_ARV (numerator)                                                                                                                                               |
	| PMTCT                                    | PMTCT- Infants Tested     | PMTCT_EID Numerator                                                                                                                                                 |
	| PMTCT                                    | PMTCT- Infants on Care    | CARE_CURR <1                                                                                                                                                        |
	| VMMC                                     | VMMC                      | VMMC_CIRC                                                                                                                                                           |
	| HIV Testing and Counseling               | HTC Tested                | [HTC_TST - (PMTCT_STAT(total numerator)+ VMMC_CIRC tested (total numerator)[1]+PMTCT EID (total numerator))]                                                        |
	| HIV Testing and Counseling               | HTC Positive              | [HTC_TSTPOS (results, positive) - ((PMTCT_ARV (total denominator) + VMMC_CIRC positive + PMTCT EID POS_2MO(total numerator) + PMTCT EID POS_12MO(total numerator))] |
	| OVC                                      | OVC                       | OVC_SERV                                                                                                                                                            |
	| Key Populations                          | KP-PWID                   | KP_PREV disaggregation of PWID                                                                                                                                      |
	| Key Populations                          | KP-FSW                    | KP_PREV disaggregation of FSW                                                                                                                                       |
	| Key Populations                          | KP-MSMTG                  | KP_PREV disaggregation of MSMTG                                                                                                                                     |
	
	HTC Calculation Changes for MER 2.0
	| EA Program Area                          | Expenditure indicators    | SI Indicators                                                    |
	|------------------------------------------|---------------------------|------------------------------------------------------------------|
	| HIV Testing and Counseling               | HTC Tested                | [HTC_TST - (PMTCT_STAT+ VMMC_CIRC tested)]                       |
	| HIV Testing and Counseling               | HTC Positive              | [HTC_TSTPOS - (PMTCT_ARV denominator + VMMC_CIRC positive)]      |
*/
********************************************************************************

*SETUP

	*import/use data
		capture confirm file "$output\ICPIFactView_SNUbyIM.dta"
			if !_rc{
				use "$output\ICPIFactView_SNUbyIM.dta", clear
			}
			else{
				import delimited "$data\PSNU_IM_20160822.txt", clear
				save "$output\ICPIFactView_SNUbyIM.dta", replace
			}

	*create dataset for just Niergia
		keep if operatingunit=="Nigeria"
		
	*replace missing SNU prioritizatoins
		replace snuprioritization="[not classified]" if snuprioritization==""
	
	*create SAPR variable to sum up necessary variables
		egen fy2016sapr = rowtotal(fy2016q1 fy2016q2)
			replace fy2016sapr = fy2016q2 if inlist(indicator, "TX_CURR", ///
				"OVC_SERV", "PMTCT_ARV", "KP_PREV", "PP_PREV", "CARE_CURR")
			replace fy2016sapr =. if fy2016sapr==0 //should be missing

	*drop unnecessary columns
		drop ïregion regionuid operatingunituid mechanismuid typemilitary ///
			numeratordenom categoryoptioncomboname sex ///
			coarsedisaggregate fy*q*
	*create a variable for EA expenditure indicator names
		gen str9 exp_ind = "."
			lab var exp_ind "EA Expenditure Indicators"
		order exp_ind, after(indicator)
		
	*save file
		save "$output\temp_setup", replace
		
