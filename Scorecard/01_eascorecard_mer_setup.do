**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Initialize data structure
**   Date: August 24, 2016
**   Updated:

/* NOTES
	- Data source: ICPIFactView - SNU by IM Level_db-frozen_20160802 [Data Hub]
	- Report uses FY2016APR results since it sums up necessary values
	- Report aggregates DSD and TA
	
	EA Needed to create Variable to Create
	| EA Program Area                          | Expenditure indicators    | SI Indicators                                                                         |
	|------------------------------------------|---------------------------|---------------------------------------------------------------------------------------|
	| Facility-based Care & Treatment Services | FBCTS                     | [TX_CURR - PMTCT_ARV]                                                                 |
	| PMTCT                                    | PMTCT- Women Tested       | PMTCT_STAT - PMTCT_STAT Known Pos                                                     |
	| PMTCT                                    | PMTCT- Women on Treatment | PMTCT_ARV                                                                             |
	| PMTCT                                    | PMTCT- Infants Tested     | PMTCT_EID Numerator                                                                   |
	| PMTCT                                    | PMTCT- Infants on Care    | CARE_CURR <1                                                                          |
	| VMMC                                     | VMMC                      | VMMC_CIRC                                                                             |
	| HIV Testing and Counseling               | HTC Tested                | [HTC_TST - (PMTCT_STAT + PMTCT_EID numerator + VMMC_CIRC tested)]                     |
	| HIV Testing and Counseling               | HTC Positive              | [HTC_TSTPOS - (PMTCT_ARV denominator +  PMTCT_EID disaggregate + VMMC_CIRC positive)] |
	| OVC                                      | OVC                       | OVC_SERV                                                                              |
	| Key Populations                          | KP-PWID                   | KP_PREV disaggregation of PWID                                                        |
	| Key Populations                          | KP-FSW                    | KP_PREV disaggregation of FSW                                                         |
	| Key Populations                          | KP-MSMTG                  | KP_PREV disaggregation of MSMTG                                                       |

*/
********************************************************************************

*SETUP

	*import data
		import delimited "$data\PSNU_IM_20160802.txt", clear
		save "$output\ICPIFactView_SNUbyIM.dta", replace
		use "$output\ICPIFactView_SNUbyIM.dta", clear

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
			coarsedisaggregate fy2015q2 fy2015q3 fy2015q4 fy2015apr fy2016q1 ///
			fy2016q2
	*create a variable for EA expenditure indicator names
		gen str9 exp_ind = "."
			lab var exp_ind "EA Expenditure Indicators"
		order exp_ind, after(indicator)
		
	*save file
		save "$output\temp_setup", replace
		