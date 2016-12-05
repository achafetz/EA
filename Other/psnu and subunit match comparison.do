
use "$output\allctry_ea.dta"
rename ou operatingunit

*which ou's use sub sub unit?
	gen mm = 1 if national_sub_unit!= national_sub_sub_unit
	tab operatingunit mm
	* Cameroon, Haiti, Mozambique, Namibia, South Africa, Tanzania, Vietnam, Zambia
	drop mm
	
clonevar psnu =  national_sub_sub_unit
save "C:\Users\achafetz\Documents\ICPI\Data\ea_snu_global.dta", replace


gen id = 1

collapse id, by(operatingunit snu1 snu1uid psnu psnuuid)

drop if psnu==""

save "C:\Users\achafetz\Documents\ICPI\Data\mer_snu_global.dta", replace

egen id = group(operatingunit psnu)
sort id
gen error = 1 if id==id[_n-1] | id==id[_n+1]
gen remove = 1 if id==id[_n-1] //this also removes Haiti
drop if remove==1
drop error remove id


merge 1:1 operatingunit psnu using "C:\Users\achafetz\Documents\ICPI\Data\ea_snu_global.dta"
