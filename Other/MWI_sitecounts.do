**   Exependiture Analysis
**   Malawi COP FY17 Site Counts
**   Aaron Chafetz
**   Purpose: Create site counts for each EA UE program area for IM TBB Tool
**   Date: Feb 6, 2017
**   Updated: 

*import data
	global fvdata "C:\Users\achafetz\Documents\ICPI\Data\All Site Dataset 20161230_Q4v2_1\"
	import delimited "$fvdata/ICPI_FactView_Site_By_IM_Malawi_20161230_Q4v2_1.txt", clear

*clean
	rename ïorgunituid orgunituid
	drop if inlist(mechanismid, 0, 1) // remove dedups
	drop if indicatortype=="NONE"
* 1 if reported indicator at site
	gen circ_fy16_cnt = 1 if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & !inlist(fy2016apr,.,0)
	gen circ_fy17_cnt = 1 if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & !inlist(fy2017_targets,.,0)
	gen adltart_fy16_cnt = 1 if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & !inlist(fy2016apr,.,0)
	gen adltart_fy17_cnt = 1 if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & age=="<15" & !inlist(fy2017_targets,.,0)
	gen chldart_fy16_cnt = 1 if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & !inlist(fy2016apr,.,0)
	gen chldart_fy17_cnt = 1 if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & age=="15+" & !inlist(fy2017_targets,.,0)
	gen ovc_fy16_cnt = 1 if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & !inlist(fy2016apr,.,0)
	gen ovc_fy17_cnt = 1 if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & !inlist(fy2017_targets,.,0)
	gen htc_fy16_cnt = 1 if indicator=="HTC_TST" & disaggregate=="Total Numerator" & !inlist(fy2016apr,.,0)
	gen htc_fy17_cnt = 1 if indicator=="HTC_TST" & disaggregate=="Total Numerator" & !inlist(fy2017_targets,.,0)
	gen pwtest_fy16_cnt = 1 if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & !inlist(fy2016apr,.,0)
	gen pwtest_fy17_cnt = 1 if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & !inlist(fy2017_targets,.,0)
	gen inftest_fy16_cnt = 1 if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & !inlist(fy2016apr,.,0)
	gen inftest_fy17_cnt = 1 if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & !inlist(fy2017_targets,.,0)

*aggreaget up to site/IM/type level
	collapse (max) *_cnt, by(orgunituid mechanismid indicatortype) fast

*aggregate to sum of sites by IM/type
	collapse (sum) *_cnt, by(mechanismid indicatortype) fast

*drop rows with no values
	egen rowtot = rowtotal(*cnt)
	drop if rowtot==0
	drop rowtot
*reshape
	ds *_cnt
	reshape wide `r(varlist)', i(mechanismid) j(indicatortype, string)
	
*
	foreach x in circ adltart chldart ovc htc pwtest inftest{
		egen `x'_fy16sitecount = rowtotal(`x'_fy16_cntDSD `x'_fy16_cntTA)
		foreach t in DSD TA{
			clonevar `x'_`t'_fy17sitecount = `x'_fy17_cnt`t'
			}
		}
		*end

*clean up
	drop *cnt*
	recode *fy* (0=.)

*merge with official names
	merge m:1 mechanismid using "C:/Users/achafetz/Documents/GitHub/ICPI/DataPack/StataOutput/officialnames.dta", ///
		update replace nogen keep(1 3 4 5) //keep all but non match from using
	order mechanismid implementingmechanismname primepartner


	
	
