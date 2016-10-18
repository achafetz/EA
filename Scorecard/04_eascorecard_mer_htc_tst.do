**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: calcuate indicator associated with HTC_TST Program Area
**   Date: August 25, 2016
**   Updated: 10/17/16


/*
| EA Program Area            | Expenditure indicators | SI Indicators                                                                                             |
|----------------------------|------------------------|-----------------------------------------------------------------------------------------------------------|
| HIV Testing and Counseling | HTC Tested             | [HTC_TST - (PMTCT_STAT(total numerator)+ VMMC_CIRC tested (total numerator)+PMTCT EID (total numerator))] |

MER 2.0
| EA Program Area            | Expenditure indicators | SI Indicators                                |
|----------------------------|------------------------|----------------------------------------------|
| HIV Testing and Counseling | HTC Tested             | [HTC_TST - (PMTCT_STAT  + VMMC_CIRC tested)] |
*/

	*open datafile
		use "$output\temp_setup", clear
		
	*remove extra variables
		keep if ///
			(inlist(indicator, "HTC_TST", "PMTCT_STAT", "PMTCT_EID") & ///
			disaggregate=="Total Numerator") | ///
			(indicator=="VMMC_CIRC" & disaggregate=="HIVStatus" & resultstatus!="Unknown")
			
	*aggregate VMMC results together --> no VMMC in Nigeria
		collapse (sum) fy2016_targets fy2016sapr, by(operatingunit-exp_ind)
	
	*reshape long
		gen id = _n //need a unique id for reshape
		rename fy2016sapr fy2016_sapr //uniformity between naming conventions for stub
		reshape long fy2016_, i(id) j(type, string)
		rename fy2016_ value
		drop id
	
	*reshape wide
		egen id = group(type psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(indicator, string)
		
	*create HTC_TST numerator
		ds value*
		recode `r(varlist)' (.=0)	
		capture confirm variable valueVMMC_CIRC //if VMMC doesn't exist, remove it from equation
			if !_rc{
				gen valueHTC_TST_EA = valueHTC_TST - (valuePMTCT_STAT + valueVMMC_CIRC + valuePMTCT_STAT)
				}
			else{
				gen valueHTC_TST_EA = valueHTC_TST - (valuePMTCT_STAT + valuePMTCT_STAT) //no VMMC in equation
				}
		*what to do w/ neg values?
		replace valueHTC_TST_EA = . if valueHTC_TST_EA<0
		
	*reshape back 
		reshape long
		drop id
		
	*reshape 
		egen id = group(indicator psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(type, string) 
	
	*add expenditure indicator
		replace exp_ind="HTC_TST" if indicator=="HTC_TST_EA"
		
	*clean up
		drop id
		rename valuesapr fy2016sapr
		rename valuetargets fy2016_targets
		order fy2016_targets fy2016sapr, last
		order indicator, after(exp_ind)
		drop if fy2016_targets==. & fy2016sapr==.
		keep if exp_ind!="."
		
	*save 
		save "$output\temp_htc.dta", replace	
