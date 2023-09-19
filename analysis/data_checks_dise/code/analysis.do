capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    tests
end

program tests
    //use ../../../shared_data/balanced_panel, clear
	use ../../../shared_data/panel_1pct, clear
	drop if state == "Puducherry" | state == "Uttarakhand" //really no info / big contradictions on linkage
	gen interact = .
	replace interact = 1 if ac_year == "2019-20" & state == "Tamil Nadu"
	replace interact = 1 if ac_year == "2017-18" & (state == "Andaman and Nicobar Islands" | ///
	state == "Arunachal Pradesh" | state == "Bihar" | state == "Chandigarh" | state == "Chhattisgarh" | ///
	state == "DNH and DD" | state == "Goa" | state == "Gujarat" | state == "Karnataka" | ///
    state == "Lakshadweep" | state == "Mizoram" | state == "Nagaland" | state == "Odisha" | ///
	| state == "Punjab" | state == "Rajasthan" | state == "Sikkim" | state == "Tripura" | ///
	state == "Uttar Pradesh" | state == "Madhya Pradesh")
	replace interact = 1 if ac_year == "2016-17" & ///
	    (state == "Delhi" | state == "Manipur" | state == "Jharkhand")
	replace interact = 1 if ac_year == "2015-16" & (state == "Andhra Pradesh" | state == "Haryana")
	replace interact = 1 if ac_year == "2013-14" & ///
	    (state == "Himachal Pradesh")
    replace interact = 0 if state == "Assam" | state == "Jammu and Kashmir" | state == "Kerala" ///
	    | state == "Maharashtra" | state == "Meghalaya" | state == "West Bengal")
	replace interact = 0 if mi(interact)
	bysort school_code (ac_year): replace interact = interact[_n-1] if interact[_n-1] == 1	
	
	collapse (firstnm) interact (sum) tot_pup pup_b pup_g, by(ac_year state)
	egen year = group(ac_year)
	egen num_state = group(state)
	gen log_enr = log(tot_pup)
	
    egen c = group(ac_year num_state)
	reg log_enr i.year i.num_state interact, cluster(c)
	predict double resid, residuals
	
	rvfplot, title("Residual Plot from DiD Regression (DISE)") 
	//graph export ../output/residual.pdf, replace
	
	sktest resid

	frontier log_enr i.year i.num_state interact, uhet(year) vce(cluster c)
end 



*Execute
main