capture log close 
log using build.log, replace
clear all
set more off

global raw_house "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\ASER_Household_Village_Data"
global raw_school "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\ASER_Household_Village_Data"

program main
    convert_to_dta
end 

program convert_to_dta
    import delimited "${raw_house}/ASER 2007 Household Data", varnames(1) stringcols(_all) 
	trim_strings
	convert_to_int
	gen year = 2007 
	gen sample_year = .
	replace sample_year = 2005 if aser05village == 1 
	replace sample_year = 2006 if aser06village == 1 
	replace sample_year = 2007 if aser07village == 1 
	rename(village_id totalmember household_id child_slno child_sex motherstudieduptoclass) ///
	    (village_code total_member hh_id child_no child_gender mother_class)
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mothergonetoschoolyes == 1
	replace mother_gone_to_school = 2 if mothergonetoschoolno == 1
	
	
	
	
	save ../output/messy_dta/household_2007, replace
	
	clear
	import delimited "${raw_house}/ASER 2008 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2008
	save ../output/messy_dta/household_2008, replace
	
	clear
	import delimited "${raw_house}/ASER 2009 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2009
	save ../output/messy_dta/household_2009, replace
	
	clear
	import delimited "${raw_house}/ASER 2010 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2010
	save ../output/messy_dta/household_2010, replace
	
	clear
	import delimited "${raw_house}/ASER 2011 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2011
	save ../output/messy_dta/household_2011, replace
	
	clear
	import delimited "${raw_house}/ASER 2012 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2012
	save ../output/messy_dta/household_2012, replace
	
	clear
	import delimited "${raw_house}/ASER 2013 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2013
	save ../output/messy_dta/household_2013, replace
	
	clear
	import delimited "${raw_house}/ASER 2014 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2014
	save ../output/messy_dta/household_2014, replace
	
	clear
	import delimited "${raw_house}/ASER 2016 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2016
	save ../output/messy_dta/household_2016, replace
	
	clear
	import delimited "${raw_house}/ASER 2018 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2018
	save ../output/messy_dta/household_2018, replace
	
	clear
	foreach year in 2007 2008 2009 2010 2011 2012 2013 2014 2016 2018 {
		qui append using ../output/messy_dta/household_`year'
	}
	qui duplicates drop 
	save ../output/clean_dta/cross_section, replace
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
        //if "`:type `var''" != "string" {
            //continue
        //}
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