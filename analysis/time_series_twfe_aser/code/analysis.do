capture log close 
log using analysis.log, replace
clear all
set more off

program main
    gen_predictions
end 

program gen_predictions
    use ../../../shared_data/cross_section_mean, clear
	
	drop if state == "HIMACHAL PRADESH"
	
	gen treatment = .
	replace treatment = 1 if year == 2018 & (state == "BIHAR" | state == "CHHATTISGARH" | ///
	state == "GUJARAT" | state == "KARNATAKA" | state == "NAGALAND" | state == "ODISHA" | ///
    state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
    state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	
	replace treatment = 1 if year == 2016 & (state == "MANIPUR" | state == "JHARKHAND" | ///
	state == "ANDHRA PRADESH" | state == "HARYANA")
	
    replace treatment = 1 if year == 2013 & (state == "HIMACHAL PRADESH")
	
    replace treatment = 0 if state == "ASSAM" | state == "JAMMU AND KASHMIR" | state == "KERALA" | ///
	    state == "MAHARASHTRA" | state == "MEGHALAYA" | state == "TAMIL NADU" | state == "WEST BENGAL"
	replace treatment = 0 if mi(treatment)
	
	bysort district_name (year): replace treatment = treatment[_n-1] if treatment[_n-1] == 1	
	
	//storing synthetic estimates
	gen holder = .

	//generate lag variables 
	bysort district_name: gen enroll_lag1 = enrolled_ind[_n-1]
	bysort district_name: gen enroll_lag2 = enrolled_ind[_n-2]
	bysort district_name: gen enroll_lag3 = enrolled_ind[_n-3]

	regress enrolled_ind enroll_lag1 enroll_lag2, r
	predict synthetic_enrollment18 
	replace synthetic_enrollment18 = . if state != "BIHAR" & state != "CHHATTISGARH" & ///
	state != "GUJARAT" & state != "KARNATAKA" & state != "NAGALAND" & state != "ODISHA" & ///
    state != "PUNJAB" & state != "RAJASTHAN" & state != "SIKKIM" & state != "TRIPURA" & ///
    state != "UTTAR PRADESH" & state != "MADHYA PRADESH"
	
	replace holder = synthetic_enrollment18 if year == 2018 & (state == "BIHAR" | state == "CHHATTISGARH" | ///
	state == "GUJARAT" | state == "KARNATAKA" | state == "NAGALAND" | state == "ODISHA" | ///
    state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
    state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	drop synthetic_enrollment18
	
	regress enrolled_ind enroll_lag1 enroll_lag2, r
	predict synthetic_enrollment16 
	replace synthetic_enrollment16 = . if state == "ASSAM" | state == "JAMMU AND KASHMIR" | ///
	state == "KERALA" | state == "MAHARASHTRA" | state == "MEGHALAYA" | state == "TAMIL NADU" | ///
	state == "WEST BENGAL"
	
	replace holder = synthetic_enrollment16 if year == 2016 & (state == "MANIPUR" | ///
	state == "JHARKHAND" | state == "ANDHRA PRADESH" | state == "HARYANA" | state == "HIMACHAL PRADESH")
	
	regress enrolled_ind enroll_lag2 enroll_lag3, r
	predict synthetic_enrollment18 
	replace synthetic_enrollment18 = . if state == "ASSAM" | state == "JAMMU AND KASHMIR" | ///
	state == "KERALA" | state == "MAHARASHTRA" | state == "MEGHALAYA" | state == "TAMIL NADU" | ///
	state == "WEST BENGAL"
	
	replace holder = synthetic_enrollment18 if year == 2018 & (state == "MANIPUR" | ///
	state == "JHARKHAND" | state == "ANDHRA PRADESH" | state == "HARYANA" | state == "HIMACHAL PRADESH")
	
	gen synth_control = enrolled_ind 
	replace synth_control = holder if !mi(holder)
	
	gen diff = synth_control - enrolled_ind
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	reg diff treatment i.year i.num_dist, cluster(num_state)
end 

*Execute 
main













