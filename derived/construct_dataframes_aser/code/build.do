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
	trim_strings
	convert_to_int
	save ../output/messy_dta/household_2007, replace
	
	import delimited "${raw_house}/ASER 2008 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	save ../output/messy_dta/household_2008, replace
	
	import delimited "${raw_house}/ASER 2009 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	save ../output/messy_dta/household_2009, replace
	
	import delimited "${raw_house}/ASER 2010 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	save ../output/messy_dta/household_2010, replace
	
	import delimited "${raw_house}/ASER 2011 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	save ../output/messy_dta/household_2008, replace
end 

program trim_strings
    ds, has(type string)
    local string_vars = r(varlist)
    foreach var in `string_vars' {
        replace `var' = strtrim(`var')
    }
    compress
end

program convert_to_int
    ds, not(varlabel *ID)
    local string_vars = r(varlist)
    foreach var in `string_vars' {
        if "`:type `var''" != "string" {
            continue
        }
        local length = strlen(`var')
        di "`var'"
        if `length' < 16 {
            gen `var'_r = real(`var')
            sum `var'_r, d
            count if !mi(`var'_r)
            local nonmiss = `r(N)'
            count
            local N = `r(N)'
            local nonmissing_pct = `nonmiss'/`N'
            if `nonmissing_pct' >= 0.05 {
                destring `var', replace
            }
            drop `var'_r
        }
    } 
    compress
end 

*Execute 
main