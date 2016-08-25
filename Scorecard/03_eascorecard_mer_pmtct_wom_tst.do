**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: calcuate indicator associated with PMTCT Women Tested Program Area
**   Date: August 25, 2016
**   Updated: 


/*
| EA Program Area | Expenditure indicators | SI Indicators                     |
|-----------------|------------------------|-----------------------------------|
| PMTCT           | PMTCT- Women Tested    | PMTCT_STAT - PMTCT_STAT Known Pos |
*/
	*open datafile
		use "$output\temp_setup", clear
	*remove extra variables
		keep if ///
			indicator=="PMTCT_STAT" & ///
			inlist(disaggregate, "Total Numerator", "Known/New")
			
	*aggregate known/new disaggs together
		collapse (sum) fy2016_targets (sum) fy2016sapr, by(operatingunit-disaggregate)
	
	*reshape long
		gen id = _n //need a unique id for reshape
		rename fy2016sapr fy2016_sapr //uniformity between naming conventions for stub
		reshape long fy2016_, i(id) j(type, string)
		rename fy2016_ value
		drop id
	
	*reshape wide
		egen id = group(type psnuuid mechanismid primepartner)
		replace disaggregate="KnownNew" if disaggregate=="Known/New"
		replace disaggregate="Total" if disaggregate=="Total Numerator"
		reshape wide value, i(id) j(disaggregate, string)		
	
	*create PMTCT - Women Tested
		ds value*
		recode `r(varlist)' (.=0)
		gen valuePMTCT_WOM_TST_EA = valueTotal - valueKnownNew 
		*what to do w/ neg values?
		replace valuePMTCT_WOM_TST_EA = . if valuePMTCT_WOM_TST_EA<0	
	
	*reshape back 
		reshape long
		drop id
		
	*reshape 
		egen id = group(disaggregate psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(type, string) 
	
	*add expenditure indicator
		replace exp_ind="PMTCT_WOM_TST" if disaggregate=="PMTCT_WOM_TST_EA"
		
	*clean up
		drop id
		rename valuesapr fy2016sapr
		rename valuetargets fy2016_targets
		order fy2016_targets fy2016sapr, last
		order indicator, before(indicatortype)
		drop if fy2016_targets==. & fy2016sapr==.
		replace disaggregate="Known/New" if disaggregate=="KnownNew"
		replace disaggregate="Total Numerator" if disaggregate=="Total"
		keep if exp_ind!="."
		
	*save 
		save "$output\temp_pmtct_wom_tst.dta", replace
