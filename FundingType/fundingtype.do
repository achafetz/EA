**   Funding Types and UEs
**   COP FY16
**   Aaron Chafetz
**   Purpose: identify countries with similar distributios of TA/DSD only partners
**   Date: June 20, 2016
**   Updated: 

/* NOTES
	- Data source: ICPIFactView - SNU by IM Level_db-frozen_20160617 [Data Hub]
	- FY2015 APR
	- Report looks across HTC_TST, HTC_TST_POS, PMTCT_STAT, PMTCT_ARV, PMTCT_EID,
		TX_NEW, TX_CURR, OVC_SERV, VMMC_CIRC		
*/

*set directory
	cd "C:\Users\achafetz\Documents\GitHub\EA\FundingType"
*open dataset
	use "C:\Users\achafetz\Documents\GitHub\PartnerProgress\StataOutput\ICPIFactView_SNUbyIM.dta", clear

*eliminate unecessary data	
	drop fy2015q2 fy2015q4 fy2016* //only need one period
	drop if fy2015apr==. //no data
	drop if fundingagency=="Dedup" //looking at partner level
	replace psnuuid="na" if  psnuuid=="" //for unique id creation

*subset to just necessary variables
	keep if inlist(indicator, "HTC_TST", ///
		"PMTCT_STAT", "PMTCT_ARV", "PMTCT_EID", "TX_NEW", ///
		"TX_CURR", "OVC_SERV", "VMMC_CIRC") & disaggregate=="Total Numerator"

*aggregate up to IM and PSNU level		
	collapse (sum) fy2015apr, by(operatingunit countryname psnu psnuuid ///
		fundingagency mechanismuid primepartner mechanismid ///
		implementingmechanismname indicator indicatortype)
*reshape
	egen id = group(operatingunit countryname psnuuid mechanismuid indicator) //create unique id for reshaping (ie break out results into DSD and TA columns
	encode indicatortype, gen(type) // j must be numeric
	drop indicatortype //need to drop for reshaping since not unique
	reshape wide fy2015apr@, i(id) j(type)

*rename dsd and ta columns
	rename fy2015apr1 dsd
	rename fy2015apr2 ta

*identify indicator and type of funding
	foreach x in  "HTC_TST" "PMTCT_STAT" "PMTCT_ARV" "PMTCT_EID" "TX_NEW" "TX_CURR" "OVC_SERV" "VMMC_CIRC"{
		gen `x'_dsd = 1 if indicator=="`x'" & dsd!=. & ta==.
		gen `x'_both = 1 if indicator=="`x'" & dsd!=. & ta!=.
		gen `x'_ta = 1 if indicator=="`x'" & dsd==. & ta!=.
		}
		*end

*aggregate up to the OU level (reports PSNU & IM pairting)
	collapse (sum) HTC_TST_dsd-VMMC_CIRC_ta, by(operatingunit countryname)
	
*export for sharing & analysis
	export excel "ou_breakdown.xlsx", sheet("Sheet1") sheetmodify firstrow(var)
