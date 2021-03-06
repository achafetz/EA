**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: calculate indicator associated with HTC_TST_POS Program Area
**   Date: August 25, 2016
**   Updated: 10/17/16

/*
| EA Program Area            | Expenditure indicators | SI Indicators                                                                                                                                                       |
|----------------------------|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| HIV Testing and Counseling | HTC Positive           | [HTC_TSTPOS (results, positive) - ((PMTCT_ARV (total denominator) + VMMC_CIRC positive + PMTCT EID POS_2MO(total numerator) + PMTCT EID POS_12MO(total numerator))] |
MER 2.0
| EA Program Area            | Expenditure indicators | SI Indicators                                               |
|----------------------------|------------------------|-------------------------------------------------------------|
| HIV Testing and Counseling | HTC Positive           | [HTC_TSTPOS - (PMTCT_ARV denominator + VMMC_CIRC positive)] |
*/

	*open datafile
		use "$output\temp_setup", clear
	*remove extra variables
		keep if ///
			(indicator=="HTC_TST" & disaggregate=="Results" & resultstatus=="Positive") | ///
			(indicator=="PMTCT_ARV" & disaggregate=="Total Denominator") | ///
			(indicator=="VMMC_CIRC" & disaggregate=="HIVStatus" & resultstatus=="Positive") | ///
			inlist(indicator, "PMTCT_EID_POS_12MO", "PMTCT_EID_POS_2MO")
			
	*reshape long
		gen id = _n //need a unique id for reshape
		rename fy2016sapr fy2016_sapr //uniformity between naming conventions for stub
		reshape long fy2016_, i(id) j(type, string)
		rename fy2016_ value
		drop id
	
	*reshape wide
		drop disaggregate resultstatus
		egen id = group(type psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(indicator, string)
		
	*create HTC_TST numerator
		ds value*
		recode `r(varlist)' (.=0)
		capture confirm variable valueVMMC_CIRC //if VMMC doesn't exist, remove it from equation
			if !_rc{
				gen valueHTC_TST_POS_EA = valueHTC_TST - (valuePMTCT_ARV + valueVMMC_CIRC + valuePMTCT_EID_POS_12MO + valuePMTCT_EID_POS_2MO)
				}
			else{
				gen valueHTC_TST_POS_EA = valueHTC_TST - (valuePMTCT_ARV + valuePMTCT_EID_POS_12MO + valuePMTCT_EID_POS_2MO) //no VMMC in equation
				}
		*what to do w/ neg values?
		replace valueHTC_TST_POS_EA = . if valueHTC_TST_POS_EA<0
		
	*reshape back 
		reshape long
		drop id
		
	*reshape 
		egen id = group(indicator psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(type, string) 
		
	*add expenditure indicator
		replace exp_ind="HTC_POS" if indicator=="HTC_TST_POS_EA"
		
	*clean up
		drop id
		rename valuesapr fy2016sapr
		rename valuetargets fy2016_targets
		order fy2016_targets fy2016sapr, last
		order indicator, after(exp_ind)
		drop if fy2016_targets==. & fy2016sapr==.
		keep if exp_ind!="."
		
	*save 
		save "$output\temp_htc_pos.dta", replace	
