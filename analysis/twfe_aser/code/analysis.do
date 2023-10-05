capture log close 
log using analysis.log, replace
clear all
set more off

program main 
	//static_twfe
	dynamic_twfe_sums
	dynamic_twfe_means
end

program static_twfe
    use ../../../shared_data/cross_section_mean, clear
    gen interact = .
	replace interact = 1 if year == 2018 & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
    state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
    state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
    state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
    state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
    state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace interact = 1 if year == 2016 & (state == "MANIPUR" | state == "JHARKHAND")
    replace interact = 1 if year == 2016 & (state == "ANDHRA PRADESH" | state == "HARYANA")
    replace interact = 1 if year == 2013 & (state == "HIMACHAL PRADESH")
    replace interact = 0 if state == "ASSAM" | state == "JAMMU AND KASHMIR" | state == "KERALA" | ///
	    state == "MAHARASHTRA" | state ==    "MEGHALAYA" | ///
		state == "TAMIL NADU" | state == "WEST BENGAL"
	replace interact = 0 if mi(interact)
	bysort district_name (year): replace interact = interact[_n-1] if interact[_n-1] == 1	
	
    egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)	
	
	//no controls
	reg enrolled_ind interact i.year i.num_dist, cluster(num_state)
end 

program dynamic_twfe_sums
    *ALL STUDENTS*
    use ../../../shared_data/cross_section_sum, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)

	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for All Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_full_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for All Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_full_sum_sas.png, height(450) width(600) replace 
	
	*GIRLS*
	use ../../../shared_data/cross_section_girls_sum, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_10 lag_indicator_neg_9 lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for Girls") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_girls_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for Girls") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_girls_sum_sas.png, height(450) width(600) replace 
	
	*LOW SES*
	use ../../../shared_data/cross_section_lowSES_sum, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
    reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
		
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for Low-SES Children") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_lowSES_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Sum(Enrollment) for Low-SES Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_lowSES_sum_sas.png, height(450) width(600) replace 
end 

program dynamic_twfe_means
    *ALL STUDENTS*
    use ../../../shared_data/cross_section_mean, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	//no controls
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for All Students") ///
		xtitle("Years to Treatment")  xline(9)
	graph export ../output/twfe_full_mean.png, height(450) width(600) replace 
		
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_dist)
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for All Students") ///
		xtitle("Years to Treatment")  xline(9)
	graph export ../output/twfe_full_mean_dist.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for All Students") ///
		xtitle("Years to Treatment") xline(9)

	graph export ../output/twfe_full_mean_sas.png, height(450) width(600) replace 
	
	*GIRLS*
	use ../../../shared_data/cross_section_girls_mean, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 

	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	//no controls
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for Girls") ///
		xtitle("Years to Treatment")  xline(9)
		
	graph export ../output/twfe_girls_mean.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for Girls") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_girls_mean_sas.png, height(450) width(600) replace 
	
    *BOYS*
	use ../../../shared_data/cross_section_boys_mean, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 

	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	//no controls
	reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for Boys") ///
		xtitle("Years to Treatment")  xline(9)
		
	graph export ../output/twfe_boys_mean.png, height(450) width(600) replace 

	*LOW SES*
	use ../../../shared_data/cross_section_lowSES_mean, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	//no controls
    reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
		
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for Low-SES Children") ///
		xtitle("Years to Treatment")  xline(9)
		
	graph export ../output/twfe_lowSES_mean.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_indicator_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for Low-SES Children") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_lowSES_mean_sas.png, height(450) width(600) replace 
	
	*ALL BUT LOW SES*
	use ../../../shared_data/cross_section_remainderSES_mean, clear
	drop if year < 2009
	forvalues val = 1/8 {
		gen  lag_indicator_neg_`val' = 0
		replace lag_indicator_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/1 {
		gen  lag_indicator_`val' = 0
		replace lag_indicator_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_indicator_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_indicator_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_indicator_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_indicator_neg_1 = 0 
		
	la var lag_indicator_neg_8 "-8"
	la var lag_indicator_neg_7 "-7"
	la var lag_indicator_neg_6 "-6"
	la var lag_indicator_neg_5 "-5"
	la var lag_indicator_neg_4 "-4"
	la var lag_indicator_neg_3 "-3"
	la var lag_indicator_neg_2 "-2"
	la var lag_indicator_neg_1 "-1"
	la var lag_indicator_0 "0"
	la var lag_indicator_1 "1"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	//no controls
    reg enrolled_ind lag_indicator_* i.year i.num_dist, cluster(num_state)
		
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) title("Event Study Plot, Mean(Enrollment) for All but Low-SES Children") ///
		xtitle("Years to Treatment")  xline(9)
		
	graph export ../output/twfe_remainderSES_mean.png, height(450) width(600) replace 
	
end 

*Execute
main