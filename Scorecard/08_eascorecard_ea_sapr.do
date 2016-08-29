**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: Import pilot EA SAPR data
**   Date: August 29, 2016
**   Updated:

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
		capture confirm file "$output\nigeria_ea_sapr.dta"
			if !_rc{
				use "$output\nigeria_ea_sapr.dta", clear
			}
			else{

				import delimited "$data\EANigeriaPilotData.csv", clear
				save "$output\nigeria_ea_sapr.dta", replace
			}
	*give variables common stub for reshaping
		foreach x of varlist fbcts - kpmsmtg {
			rename `x' ind_`x'
		}
		*end
		
	*drop totals (last line)
		drop if snustate=="" & mechanismid==.
		rename snustate snu1
		
	*reshape long
		reshape long ind_, i(snu1 psnulga mechanismid) j(sapr_pa, string)
	
	*destring values	
		destring ind_, gen(fy2016sapr_ea_exp)
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
		merge m:1 sapr_pa using "`temp_cw'", nogen //merge in crosswalk table
	*clean up
		drop if inlist(fy2016sapr_ea_exp, ., 0)
		drop sapr_pa
		drop if exp_ind=="n/a"
		collapse (sum) fy2016sapr_ea_exp, by(snu1 mechanismid exp_ind)
		replace snu1 = trim(snu1) //extra spaces in some snu names
	*save
		save "$output\temp_eadata_sapr.dta", replace	
