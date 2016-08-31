**   EA Scorecard
**   COP FY16
**   Aaron Chafetz
**   Purpose: run through all do files
**   Date: August 31, 2016
**   Updated:

*** RUN ALL DO FILES FOR EA SCORECARD ***

** SETUP **
	*00 Initialize folder structure
		cd C:\Users\achafetz\Documents\GitHub\EA\Scorecard
		run 00_eascorecard_initialize 
	
** MER **
	*01 initialize MER data structure
		*output - temp_setup.dta > use for MER calculations 01-06
		run 01_eascorecard_mer_setup 
	*02 calcuate indicator associated with FBCTS Program Area
		run 02_eascorecard_mer_fbcts    
	*03 calcuate indicator associated with PMTCT Women Tested Program Area
		run 03_eascorecard_mer_pmtct_wom_tst
	*04 calcuate indicator associated with HTC_TST Program Area
		run 04_eascorecard_mer_htc_tst 
	*05 calculate indicator associated with HTC_TST_POS Program Area
		run 05_eascorecard_mer_htc_tst_pos
	*06 export indicator associated other Program Areas	
		run 06_eascorecard_mer_oth
		
** EA **
	*07 import EA data & run outlier analysis
		run 07_eascorecard_initialize_ea
	*08 import pilot EA FY16 SAPR data
		run 08_eascorecard_ea_sapr
	*09 import Applied UEs from PBAC
		*run 09_eascorecard_ea_pbac //still a work in progress
** MERGED **
	*10 merge MER & EA indicators together
		run 10_eascorecard_merge
	*11 genereate SAPR Unit Expenditures
		run 11_eascorecard_merge_sapr_ues
