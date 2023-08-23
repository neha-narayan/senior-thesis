capture log close 
log using build.log, replace
clear all
set more off

global raw_house "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\ASER_Household_Village_Data"
global raw_school "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\ASER_Household_Village_Data"

program main
    clean_house
end 

program clean_house 
    import delimited "${raw_house}/ASER 2007 Household Data", varnames(1) stringcols(_all)
	gen year = . 
	replace year = 2005 if aser05village == "1"
	replace year = 2006 if aser06village == "1"
	replace year = 2007 if aser07village == "1"
	drop if mi(year)
	
	import delimited "${raw_house}/ASER 2008 Household Data", varnames(1) stringcols(_all)
	gen year = . 
	replace year = 2006 if aser06village == "1"
	replace year = 2007 if aser07village == "1"
	replace year = 2008 if aser08village == "1"
	drop if mi(year)

end 

*Execute 
main