capture log close 
log using build.log, replace
clear all
set more off

program main
    append_datasets
end 

program append_datasets
    use ../../../raw/NSS12_Demographics, clear
    merge 1:1 HHID Person_Serial_No using ../../../raw/NSS12_PrincipalActivity, ///
	    assert(1 2 3) keep(3) nogen
	drop if Age < 6 | Age > 16
	gen enrolled_ind = .
	replace enrolled_ind = 1 if Usual_Principal_Activity_Status == "91"
	replace enrolled_ind = 0 if enrolled_ind > 1
	gen girl_ind = .
	replace girl_ind = 1 if Sex == "2"
	replace girl_ind = 0 if Sex == "1"	
	keep if State == "28" | State == "18" | State == "10" | State == "22" | State == "24" | ///
	    State == "06" | State == "02" | State == "20" | State == "29" | State == "32" | ///
		State == "23" | State == "27" | State == "14" | State == "17" | State == "13" | ///
		State == "21" | State == "03" | State == "08" | State == "18" | State == "11" | ///
		State == "33" | State == "36" |  State == "16" | State == "09" | ///
		State == "19" //keep only states from ASER
	replace State = "ANDHRA PRADESH" if State == "28"
	replace State = "ASSAM" if State == "18"
	replace State = "BIHAR" if State == "10"
	replace State = "CHHATTISGARH" if State == "22"
	replace State = "GUJARAT" if State == "24"
	replace State = "HARYANA" if State == "06"
	replace State = "HIMACHAL PRADESH" if State == "02"
	replace State = "JHARKHAND" if State == "20"
	replace State = "KARNATAKA" if State == "29"
	replace State = "KERALA" if State == "32"
	replace State = "MADHYA PRADESH" if State == "23"
	replace State = "MAHARASHTRA" if State == "27"
	replace State = "MANIPUR" if State == "14"
	replace State = "MEGHALAYA" if State == "17" 
	replace State = "NAGALAND" if State == "13"
	replace State = "ODISHA" if State == "21"
	replace State = "PUNJAB" if State == "03"
	replace State = "RAJASTHAN" if State == "08"
	replace State = "SIKKIM" if State == "11"
	replace State = "TAMIL NADU" if State == "33"
	replace State = "ANDHRA PRADESH" if State == "36"
	replace State = "TRIPURA" if State == "16"
	replace State = "UTTAR PRADESH" if State == "09"
	replace State = "WEST BENGAL" if State == "19"
	save ../output/NSS_enrollment, replace
end 

*Execute 
main