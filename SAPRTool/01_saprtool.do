**   EA-SAPR Tool
**   COP FY16
**   Aaron Chafetz
**   Purpose: generate output for Excel tool for OUs to check
**				MER data reported by IM
**   Date: Aug 15, 2016
**   Updated: 

/* NOTES
	- Data source: ICPIFactView - OU_IM_20160801 [ICPI Data Store]
	- Report aggregates DSD and TA
	- Creates a SAPR result (Q1+Q2 or Q2 depending on indicator)
*/
********************************************************************************

*import OU IM data
	cd "C:\Users\achafetz\Documents\GitHub\EA\SAPRTool"
	import delimited "OU_IM_20160802.txt", clear 

*keep only top level numerators & KP disaggs
	keep if disaggregate=="Total Numerator" | ///
		(indicator=="KP_PREV" & categoryoptioncomboname!="default")

*create SAPR variable to sum up necessary variables
	egen fy2016sapr = rowtotal(fy2016q1 fy2016q2)
		replace fy2016sapr = fy2016q2 if inlist(indicator, "TX_CURR", ///
			"OVC_SERV", "PMTCT_ARV", "KP_PREV", "PP_PREV", "CARE_CURR", "TB_ART")
		replace fy2016sapr =. if fy2016sapr==0 //should be missing
	
*export
	export delimited using "ICPIFactView_OU_IM_ahc_20160815", nolabel replace dataf
