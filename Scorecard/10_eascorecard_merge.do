**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: merge MER & EA indicators together
**   Date: August 25, 2016
**   Updated: 8/31/16

/* NOTES
	
	EA Needed to create Variable to Create
	| EA Program Area                          | Expenditure indicators    | SI Indicators                                                                |
	|------------------------------------------|---------------------------|------------------------------------------------------------------------------|
	| Facility-based Care & Treatment Services | FBCTS                     | TX_CURR (numerator) - PMTCT_ART (numerator)                                  |
	| PMTCT                                    | PMTCT- Women Tested       | PMTCT_STAT (numerator) - PMTCT_STAT_POS (denominator, PMTCT ART)             |
	| PMTCT                                    | PMTCT- Women on Treatment | PMTCT_ARV (numerator)                                                        |
	| PMTCT                                    | PMTCT- Infants Tested     | PMTCT_EID Numerator                                                          |
	| PMTCT                                    | PMTCT- Infants on Care    | CARE_CURR <1                                                                 |
	| VMMC                                     | VMMC                      | VMMC_CIRC                                                                    |
	| HIV Testing and Counseling               | HTC Tested                | [HTC_TST - (PMTCT_STAT+ VMMC_CIRC tested + PMTCT_EID)]                       |
	| HIV Testing and Counseling               | HTC Positive              | [HTC_TSTPOS - (PMTCT_ARV denominator + VMMC_CIRC positive +PMTCT_EID_POS)]   |
	| OVC                                      | OVC                       | OVC_SERV                                                                     |
	| Key Populations                          | KP-PWID                   | KP_PREV disaggregation of PWID                                               |
	| Key Populations                          | KP-FSW                    | KP_PREV disaggregation of FSW                                                |
	| Key Populations                          | KP-MSMTG                  | KP_PREV disaggregation of MSMTG                                              |


*/
********************************************************************************

*append all MER files together
	use "$output\temp_fbcts", clear
	append using "$output\temp_pmtct_wom_tst.dta" "$output\temp_htc.dta" ///
		"$output\temp_htc_pos.dta" "$output\temp_oth_ind.dta"
*clean up - remove unnecessary variables
	drop countryname disaggregate age otherdisaggregate ///
		resultstatus indicator
*aggregate DSD/TA & PSNU
	*EA does not differentiate between DSD and TA
	*expenditure data not down to PSNU level --> no prioritizations
	*also removes extra variables - countryname psnu psnuuid disaggregate age otherdisaggregate resultstatus indicator
	collapse (sum) fy2016_targets fy2016sapr, by(operatingunit snu1 ///
		psnu psnuuid primepartner fundingagency mechanismid ///
		implementingmechanismname exp_ind)

*merge with EA 2015 data
	*in Kenya, have to resolve TBD partner for merging
	egen id = group(mechanismid psnu exp_ind)
	sort id
	gen match = 1 if id[_n-1]==id
	by id: egen matchb = max(match)
	replace primepartner = "Population Services International" if matchb==1
	drop id match*
	collapse (sum) fy2016_targets fy2016sapr, by(operatingunit snu1 ///
		psnu psnuuid primepartner fundingagency mechanismid ///
		implementingmechanismname exp_ind)
	merge 1:1 mechanismid psnu exp_ind using "$output\temp_eadata.dta"
	*check 
	tab _merge if  _merge!=3
	*tab _merge if !inlist(snu1, "Kebbi", "Kwara",	"Niger",	"Zamfara",	"National") & _merge!=3 & primepartner!="Dedup" & fy2016_targets!=0 & fy2016sapr!=0 //non matching SNUs in Nigeria
	drop if primepartner=="Dedup"
	drop _merge
*merge with EA Pilot SAPR data
	merge 1:1 mechanismid psnu exp_ind using "$output\temp_eadata_sapr.dta"
	drop _merge
*save
	save "$output\temp_merge.dta", replace
	
