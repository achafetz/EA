**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: import Applied UEs from PBAC
**   Date: August 30, 2016
**   Updated: 

/* NOTES
	- Data source: Nigeria 2015 PBAC v03182016_base_Final Uploaded_04282016.xlsx [PEPFAR.net - Nigeria > FY16 COP Submission]
	- Manually created a new tab for extracting to Stata in PBAC workbook
	
	| PBAC Program Area | PBAC Target Population                           | EA Expenditure Indicator |
	|-------------------|--------------------------------------------------|--------------------------|
	| CBCTS             | CBCTS Beneficiaries                              |                          |
	| FBCTS             | Adults ART                                       |                          |
	| FBCTS             | Adults Pre-ART                                   |                          |
	| FBCTS             | Pediatrics ART                                   |                          |
	| FBCTS             | Pediatrics Pre-ART                               |                          |
	| FBCTS             | Use UE with ARVs                                 |                          |
	|                   |                                                  | FBCTS                    |
	| HTC               | CBTC Clients                                     |                          |
	| HTC               | Other HTC Clients                                |                          |
	| HTC               | PITC Clients                                     |                          |
	| HTC               | VCT Clients                                      |                          |
	|                   |                                                  | HTC_TST                  |
	|                   |                                                  | HTC_TST_POS              |
	| KP-FSW            | Female sex workers reached                       | KP_FSW                   |
	| KP-MSMTG          | MSM and transgender reached                      | KP_MSMTG                 |
	| KP-PWID           | PWID reached                                     | KP_PWID                  |
	| MAT               | Persons receiving medication assisted therapy    |                          |
	| OVC               | Orphans reached                                  | OVC                      |
	| PMTCT             | Infants receiving care                           | PMTCT_INF_TX             |
	| PMTCT             | Infants tested                                   | PMTCT_INF_TST            |
	| PMTCT             | Pregnant women tested and receiving results      | PMTCT_WOM_TST            |
	| PMTCT             | Women receiving ART as Option B+      (optional) |                          |
	| PMTCT             | Women receiving ARV prophylaxis                  |                          |
	|                   |                                                  | PMTCT_WOM_TX             |
	| PP-PREV           | Priority populations reached                     |                          |
	| VMMC              | Males Circumcised                                | VMMC                     |
	
*/
********************************************************************************

*import data
		capture confirm file "$output\nigeria_ea_pbac.dta"
			if !_rc{
				use "$output\nigeria_ea_pbac.dta", clear
			}
			else{
				import excel "$data\Nigeria 2015 PBAC v03182016_base_Final Uploaded_04282016.xlsx", ///
					sheet("Stata Extract") firstrow case(lower) clear
				save "$output\nigeria_ea_pbac.dta", replace
			}
			*end


*keep only ues of interest

	*rename each type to align w/ EA exp indicator
		preserve // preserve current file while creating a crosswalk table on the side
		clear
		input str14 programarea str14 exp_ind //crosswalk table
			"HTC" "HTC_TST"
			"KP-FSW" "KP_FSW"
			"KP-MSMTG" "KP_MSMTG"
			"KP-PWID" "KP_PWID"
			"OVC" "OVC"
			"VMMC" "VMMC"
			end
		tempfile temp_cw //create a temporary file for saving the crosswalk table
		save "`temp_cw'"
		restore // restore the EA data
		merge m:1 programarea using "`temp_cw'", nogen //merge in crosswalk table
	*replace PMTCT
		replace exp_ind = "PMTCT_WOM_TST" if targetpopulation=="Pregnant women tested and receiving results"
		replace exp_ind = "PMTCT_INF_TX" if targetpopulation=="Infants receiving care"
		replace exp_ind = "PMTCT_INF_TST" if targetpopulation=="Infants tested"

	
