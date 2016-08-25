**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: merge MER indicators together
**   Date: August 24, 2016
**   Updated:

/* NOTES
	
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

*append all MER files together
	use "$output\temp_fbcts", clear
	append using "$output\temp_pmtct_wom_tst.dta" "$output\temp_htc.dta" ///
		"$output\temp_htc_pos.dta" "$output\temp_oth_ind.dta"
*save
	