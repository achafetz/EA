### PEPFAR EA - Outlier Analysis

#### Overview
This set of Stata do files provides both a program area summary and detailed mechanism information necessary for Unit Expenditure outliers using PEPFAR Expenditure Analysis data.

Notes
   - This repository contains code only; raw data (in xlsx format) should be loaded onto the local machines in the `RawData` folder
(created in the in [`00_outlieranalysis_initialize.do`] (https://github.com/achafetz/EA/blob/master/00_outlieranalysis_initialize.do)) where this analysis is being run. 
   - Running this analysis requires Stata software


#### Step 1
In order to conduct the outlier analysis, it's important to first setup a consistent folder structure. Running the first do file ([`00_outlieranalysis_initialize.do`] (https://github.com/achafetz/EA/blob/master/00_outlieranalysis_initialize.do)) will do just that. In order to run this, you will need to adjust one line of code (17), changing the file path to where you want the EA project folder to go on your local machine (`global projectpath "/Users/Aaron/Desktop/"`) 

Any time you open a new instance of Stata to run this analysis, you will need to re-run this do file, as it establishes the file paths as global macros used in the rest of the analysis.

#### Step 2
Download the EA Data Nav Tools for the Operating Units (OU) you wish to conduct the outlier analysis on. For each OU, make a copy of their (hidden) `Totals_MCCNav` tab in a new workbook and save this as the `[OU].xlsx` (eg `Kenya.xlsx`). [Note: Remove any spaces in OU names, eg `"South Africa"` -> `"SouthAfrica"`.] Save these files to the `RawData` folder of your EA project folder.

#### Step 3
With the EA data saved to the `RawData` folder, you can start converting the data to Stata formated data (.dta). Before running the second do file, you will need to adjust one line of code (27), changing the country in `import excel "$data/Malawi"'` to one that you are analyzing. Note that this will need to be the actual Data Nav Tool rather that just the EA data as it is importing program area information stored in the `Validations` tab. 

Once you have made this change, you can run [`01_outlieranalysis_import.do`] (https://github.com/achafetz/EA/blob/master/01_outlieranalysis_import.do). This do file only needs to be run again if you add different OUs to your analysis.

#### Step 4
Now that the project folder structure has been created and all the necessary data has been saved, its time to run the outlier analysis ( [`02_outlieranalysis_analysis.do`] (https://github.com/achafetz/EA/blob/master/02_outlieranalysis_analysis.do)). Before running you will need to adjust one line of code (14) to identify all the OUs you are running the analysis on (adding a space between each OU), eg `foreach ctry in Kenya Zambia Tanzania {`. The current outlier analysis is set to identify any Unit Expenditures (UE) that are +/- 5x the weighted average UE for that program area. This can be adjusted by changing one line of code (22) from 5 to a different frequency (`local ol 5`).

Running the do file will produce two outputs to your `ExcelOutputs` folder. First, .csv file (from the log) that identifies a the overall number of outliers by program area. The second output is a .xlsx file that provides each mechanism that is an outlier with the information needed in the `Outlier Analysis Documentation` tab of the Data Nav tool.
