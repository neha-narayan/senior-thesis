capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    enroll_plots
	static_twfe
end

program enroll_plots 
	//figure out how to make cmissing work
	line enrolled_ind year if state_name == "CHHATTISGARH", ///
	    xlabel(2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020) ///
		xtitle("Year") ytitle("Average Enrollment Rate") title("Average Enrollment Rate in AP Over Time")
	
	scatter enrolled_ind year if state_name == "UTTAR PRADESH", ///
	    xlabel(2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020) ///
		xtitle("Year") ytitle("Average Enrollment Rate") title("Average Enrollment Rate in UP Over Time")
	
end 

program static_twfe
    use ../../../shared_data/cross_section, clear
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
	
	egen num_state = group(state_name)
	
	//no controls
	reg enrolled_ind interact i.year i.num_state, cluster(num_state)

	//some controls
	reg enrolled_ind interact i.year i.num_state child_age girl_ind tuition ///
	    govt_ind pvt_ind madarsa_ind other_ind, cluster(num_state)
end 

program dynamic_twfe 
    use ../../../shared_data/cross_section, clear
	forvalues val = 1/10 {
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
	
	egen num_state = group(state_name)
	
	la var lag_indicator_neg_10 "-10"
	la var lag_indicator_neg_9 "-9"
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
	
	reg enrolled_ind lag_indicator_* i.year i.num_state, cluster(num_state)
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_indicator_neg_10 lag_indicator_neg_9 lag_indicator_neg_8 ///
		lag_indicator_neg_7 lag_indicator_neg_6 lag_indicator_neg_5 lag_indicator_neg_4 ///
		lag_indicator_neg_3 lag_indicator_neg_2 lag_indicator_neg_1 lag_indicator_0 ///
		lag_indicator_1) 
end 




*Execute
main