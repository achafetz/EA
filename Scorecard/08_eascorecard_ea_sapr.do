**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Import pilot EA SAPR data
**   Date: August 29, 2016
**   Updated: 10/18/16

/* NOTES
	- Data source: USAID EA SPR Scorecard Draft Aug 18 2016 [EATAP, Nigeria]
	- Data collected for EA pilot using SAPR data
	- Crosswalk between EA SAPR Pilot Program areas and EA Exenditure Indicators below
	
	| EA SAPR Pilot Prog Areas | EA Exp Indicators |
	|--------------------------|-------------------|
	| fbcts                    | FBCTS             |
	| cbcts                    | n/a               |
	| pmtctwomentested         | PMTCT_WOM_TST     |
	| pmtctwomenontreatment    | PMTCT_WOM_TX      |
	| pmtctinfantstested       | PMTCT_INF_TST     |
	| pmtctinfantsoncare       | PMTCT_INF_TX      |
	| vmmc                     | VMMC              |
	| htctotal                 | HTC_TST           |
	| lab                      | n/a               |
	| ovc                      | OVC               |
	| kppwid                   | KP_PWID           |
	| kpfsw                    | KP_FSW            |
	| kpmsmtg                  | KP_MSMTG          |
*/
********************************************************************************

*SETUP

	*import/use data
		capture confirm file "$output\kenya_ea_sapr.dta"
			if !_rc{
				use "$output\kenya_ea_sapr.dta", clear
			}
			else{
				import delimited "$data\EAKenyaPilotData.csv", clear
				save "$output\kenya_ea_sapr.dta", replace
			}
	*give variables common stub for reshaping
		foreach x of varlist fbcts - kpmsmtg {
			rename `x' ind_`x'
		}
		*end
		
	*drop totals (last line)
		*Nigeria
		*rename snustate snu1
		*drop if snu1=="" & mechanismid==.
		*Kenya
		drop ip //will get mechanism name when merging
		rename snu psnu
		replace psnu = "Elgeyo Marakwet" if psnu == "Elgeyo-Marakwet"
		replace psnu = "Trans Nzoia" if psnu== "Trans-Nzoia"
		
		
	*reshape long
		*reshape long ind_, i(snu1 psnulga mechanismid) j(sapr_pa, string) //Nigeria
		reshape long ind_, i(psnu mechanismid) j(sapr_pa, string)
	
	*destring if ind_ contains string values & drop missing values
		capture confirm string variable ind_  
			if !_rc{
				destring ind_, gen(fy2016sapr_ea_exp)
			}
			else{
				gen fy2016sapr_ea_exp = ind_
			}
		
		drop ind_
		drop if inlist(fy2016sapr_ea_exp, ., 0)
		
	*rename each type to align w/ EA exp indicator
		preserve // preserve current file while creating a crosswalk table on the side
		clear
		input str21 sapr_pa str14 exp_ind //crosswalk table
			"fbcts" "FBCTS"
			"cbcts" "n/a"
			"pmtctwomentested" "PMTCT_WOM_TST"
			"pmtctwomenontreatment" "PMTCT_WOM_TX"
			"pmtctinfantstested" "PMTCT_INF_TST"
			"pmtctinfantsoncare" "PMTCT_INF_TX"
			"vmmc" "VMMC"
			"htctotal" "HTC_TST"
			"lab" "n/a"
			"ovc" "OVC"
			"kppwid" "KP_PWID"
			"kpfsw" "KP_FSW"
			"kpmsmtg" "KP_MSMTG"
			end
		tempfile temp_cw //create a temporary file for saving the crosswalk table
		save "`temp_cw'"
		restore // restore the EA data
		merge m:1 sapr_pa using "`temp_cw'", nogen keep(match master) //merge in crosswalk table
	*clean up
		drop if inlist(fy2016sapr_ea_exp, ., 0)
		drop sapr_pa
		drop if exp_ind=="n/a"
		*Nigeria
		*collapse (sum) fy2016sapr_ea_exp, by(snu1 mechanismid exp_ind)
		*replace snu1 = trim(snu1) //extra spaces in some snu names
		*Kenya
		collapse (sum) fy2016sapr_ea_exp, by(psnu mechanismid exp_ind)
		replace psnu = trim(psnu) //extra spaces in some snu names
	*save
		save "$output\temp_eadata_sapr.dta", replace	
