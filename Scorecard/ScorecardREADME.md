### PEPFAR EA - Scorecard

#### OVERVIEW
This set of Stata do files creates a triangulated dataset, bringing together EA and MER data for FY2016 SAPR. The intent of the scorecard is to allow country teams to evaluate partners' EA progress mid year.

Notes
   - This repository contains code only; raw data (in xlsx format) should be loaded onto the local machines in the `RawData` folder
(created in the in [`00_eascorecard_initialize.do`] (https://github.com/achafetz/EA/blob/master/Scorecard/00_eascorecard_initialize.do)) where this analysis is being run. 
   - Pilot EA data from Nigeria was used in addition to data from the ICPI Q3 Factview dataset (8/22/16), Nigeria FY15 DataNav Tool, and Nigeria FY15 PBAC
   - Running this analysis requires Stata software
   - All do files can be run through [`_eascorecard_runall.do`] (https://github.com/achafetz/EA/blob/master/Scorecard/_eascorecard_runall.do)


#### SETUP
   In order to run these files, you will need to adjust one line of code (17), changing the file path to where you want the EA project folder to go on your local machine (`"C:\Users\achafetz\Documents\GitHub\EA\"`) as well as store the dataset in the `RawData` folder.
   
   - 00 Initialize folder structure ([`00_eascorecard_initialize`] (https://github.com/achafetz/EA/blob/master/Scorecard/00_eascorecard_initialize.do))

#### MER
   - 01 initialize MER data structure ([`01_eascorecard_mer_setup`] (https://github.com/achafetz/EA/blob/master/Scorecard/01_eascorecard_mer_setup.do))
   - 02 calcuate indicator associated with FBCTS Program Area ([`02_eascorecard_mer_fbcts`] (https://github.com/achafetz/EA/blob/master/Scorecard/02_eascorecard_mer_fbcts.do))
   - 03 calcuate indicator associated with PMTCT Women Tested Program Area ([`03_eascorecard_mer_pmtct_wom_tst`] (https://github.com/achafetz/EA/blob/master/Scorecard/03_eascorecard_mer_pmtct_wom_tst.do))
   - 04 calcuate indicator associated with HTC_TST Program Area ([`04_eascorecard_mer_htc_tst`] (https://github.com/achafetz/EA/blob/master/Scorecard/04_eascorecard_mer_htc_tst.do))
   - 05 calculate indicator associated with HTC_TST_POS Program Area ([`05_eascorecard_mer_htc_tst_pos`] (https://github.com/achafetz/EA/blob/master/Scorecard/05_eascorecard_mer_htc_tst_pos.do))
   - 06 export indicator associated other Program Areas ([`06_eascorecard_mer_oth`] (https://github.com/achafetz/EA/blob/master/Scorecard/06_eascorecard_mer_oth.do))
		
#### EA
   - 07 import EA data & run outlier analysis ([`07_eascorecard_initialize_ea`] (https://github.com/achafetz/EA/blob/master/Scorecard/07_eascorecard_initialize_ea.do))
   - 08 import pilot EA FY16 SAPR data ([`08_eascorecard_ea_sapr`] (https://github.com/achafetz/EA/blob/master/Scorecard/08_eascorecard_ea_sapr.do))
   - 09 import Applied UEs from PBAC ([`09_eascorecard_ea_pbac`] (https://github.com/achafetz/EA/blob/master/Scorecard/09_eascorecard_ea_pbac.do)) //still a work in progress

#### MERGED
   - 10 merge MER & EA indicators together ([`10_eascorecard_merge`] (https://github.com/achafetz/EA/blob/master/Scorecard/10_eascorecard_merge.do))
   - 11 genereate SAPR Unit Expenditures ([`11_eascorecard_merge_sapr_ues`] (https://github.com/achafetz/EA/blob/master/Scorecard/11_eascorecard_merge_sapr_ues.do))
