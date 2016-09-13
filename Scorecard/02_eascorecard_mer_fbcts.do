**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: calcuate indicator associated with FBCTS Program Area
**   Date: August 25, 2016
**   Updated: 9/13/16


/*
Notes:
	- FBCTS Patient Years:  Our standard calculations is (using FY16 
		EA analysis as an example) is:  (APR15+(2xSAPR16)+APR16)/4.  
		My suggestion would be to simply take the average of the first 2 data 
		points:  (APR15+SAPR15)/2  -- this would account for some variation in 
		the number of patients w/o giving too much weight to SAPR. (R.Godbole, 9/12/16)

| EA Program Area                          | Expenditure indicators | SI Indicators         |
|------------------------------------------|------------------------|-----------------------|
| Facility-based Care & Treatment Services | FBCTS                  | [TX_CURR - PMTCT_ARV] |
*/
	*open datafile
		use "$output\temp_setup", clear
		
	*remove extra variables
		keep if ///
			(indicator=="TX_CURR" & disaggregate=="Age/Sex" & age!="<01") | ///
			(indicator=="PMTCT_ARV" & disaggregate=="Total Numerator")
		
	*aggregate all age groups together
		collapse (sum) fy2016_targets fy2015apr fy2016sapr, by(operatingunit-disaggregate)
	
	*replace fy2016sapr with patient year value
		gen fy2016sapr_py = (fy2015apr+fy2016sapr)/2
		drop fy2015apr fy2016sapr
		rename fy2016sapr_py fy2016sapr
		
	*reshape long
		gen id = _n //need a unique id for reshape
		rename fy2016sapr fy2016_sapr //uniformity between naming conventions for stub
		reshape long fy2016_, i(id) j(type, string)
		rename fy2016_ value
		drop id
	
	*reshape wide
		drop disaggregate
		egen id = group(type psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(indicator, string)
		
	*create FBCT numerator
		ds value*
		recode `r(varlist)' (.=0)
		gen valueFBCTS_EA = valueTX_CURR-valuePMTCT_ARV 
		*what to do w/ neg values?
		replace valueFBCTS_EA = . if valueFBCTS_EA<0
		
	*reshape back 
		reshape long
		drop id
		
	*reshape 
		egen id = group(indicator psnuuid mechanismid primepartner)
		reshape wide value, i(id) j(type, string)
		
	*add expenditure indicator
		replace exp_ind="FBCTS" if indicator=="FBCTS_EA"
		
	*clean up
		drop id
		rename valuesapr fy2016sapr
		rename valuetargets fy2016_targets
		order fy2016_targets fy2016sapr, last
		order indicator, before(indicatortype)
		drop if fy2016_targets==. & fy2016sapr==.
		keep if exp_ind!="."
		
	*save 
		save "$output\temp_fbcts.dta", replace

		
** Remove fy2015apr from further datasets **
	use "$output\temp_setup", clear
	drop fy2015apr
	save "$output\temp_setup", replace
