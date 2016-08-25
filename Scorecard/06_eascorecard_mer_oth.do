**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: export indicator associated other Program Areas
**   Date: August 24, 2016
**   Updated: 


/*
| EA Program Area | Expenditure indicators    | SI Indicators                   |
|-----------------|---------------------------|---------------------------------|
| PMTCT_EID       | PMTCT- Women on Treatment | PMTCT_ARV                       |
| PMTCT_EID       | PMTCT- Infants Tested     | PMTCT_EID Numerator             |
| PMTCT_EID       | PMTCT- Infants on Care    | CARE_CURR <1                    |
| VMMC            | VMMC                      | VMMC_CIRC                       |
| OVC             | OVC                       | OVC_SERV                        |
| Key Populations | KP-PWID                   | KP_PREV disaggregation of PWID  |
| Key Populations | KP-FSW                    | KP_PREV disaggregation of FSW   |
| Key Populations | KP-MSMTG                  | KP_PREV disaggregation of MSMTG |
*/

*retain other mer indicators

	*open datafile
		use "$output\temp_setup", clear
	*keep only necessary data
		keep if ///
			(inlist(indicator, "PMTCT_ARV", "PMTCT_EID", "VMMC_CIRC", "OVC_SERV") ///
			& disaggregate=="Total Numerator") | ///
			indicator=="KP_PREV" & disaggregate=="KeyPop" | /// KP indicators 
			indicator=="CARE_CURR" & disaggregate=="Age/Sex" & age=="<01" 
			
	*rename indicator for EA
		replace exp_ind="PMTCT_WOM_TX" if indicator=="PMTCT_ARV"
		replace exp_ind="PMTCT_INF_TST" if indicator=="PMTCT_EID"
		replace exp_ind="PMTCT_INF_TX" if indicator=="CARE_CURR"
		replace exp_ind="VMMC" if indicator=="VMMC_CIRC"
		replace exp_ind="OVC" if indicator=="OVC_SERV"
		replace exp_ind="KP_PWID" if regexm(otherdisaggregate, "PWID")
		replace exp_ind="KP_FSW" if otherdisaggregate=="FSW"
		replace exp_ind="KP_MSMTG" if otherdisaggregate=="MSM/TG"
	*clean
		drop if fy2016_targets==. & fy2016sapr==.
		
	*save 
		save "$output\temp_oth_ind.dta", replace	
