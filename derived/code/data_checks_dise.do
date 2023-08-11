capture log close 
log using data_checks.log, replace
clear all
set more off

program main
    drop_sus_schools
end

program drop_sus_schools
    use ../output/clean_dta/panel_pre2017, clear
	foreach var in apprb5 apprg5 apprb8 apprg8 {
		replace `var' = "." if `var' == "NA"
		destring `var', replace
	}
	tab ac_year if mi(apprb5)
	drop if ac_year == "2005-06" | ac_year == "2006-07" | ac_year == "2007-08" | ac_year == "2008-09" | ac_year == "2013-14"
	foreach var in apprb5 apprg5 apprb8 apprg8 {
		bys school_code (ac_year): gen pctChange_`var' = (`var'[_n] - `var'[_n-1])/`var'[_n-1]
		replace pctChange_`var' = 0 if `var'[_n] == 0 & `var'[_n-1] == 0
	    replace pctChange_`var' = `var'[_n] if `var'[_n] != 0 & `var'[_n-1] == 0
	}
	foreach var in c5_totb c5_totg c8_totb c8_totg {
        bys school_code (ac_year): gen pctChange_`var' = (`var'[_n] - `var'[_n-1])/`var'[_n-1]
		replace pctChange_`var' = 0 if `var'[_n] == 0 & `var'[_n-1] == 0
		replace pctChange_`var' = `var'[_n] if `var'[_n] != 0 & `var'[_n-1] == 0
	}
	gen ratiob5 = pctChange_apprb5/pctChange_c5_totb
	gen ratiog5 = pctChange_apprg5/pctChange_c5_totg
	gen ratiob8 = pctChange_apprb8/pctChange_c8_totb
	gen ratiog8 = pctChange_apprg8/pctChange_c8_totg
	
	foreach var in ratiob5 ratiog5 ratiob8 ratiog8 {
		bysort school_code: egen mean_`var' = mean(`var')
	}
 	bysort school_code: gen meaned_ratio = mean_ratiob5 + mean_ratiog5 + mean_ratiob8 + mean_ratiog8 / 4
	
	eststo ratio_hist: qui estpost sum meaned_ratio, de
	graph export ../output/ratio_hist.png, height(600) width(450) replace
end 



*Execute
main