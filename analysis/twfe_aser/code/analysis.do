capture log close 
log using analysis.log, replace
clear all
set more off

program main 
	//static_twfe
	//dynamic_twfe_sums
	//dynamic_twfe_means
	twfe_decomposed
end

program static_twfe
    use ../../../shared_data/cross_section_mean, clear
    gen interact = 0
	replace interact = 1 if year >= 2018 & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
    state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
    state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
    state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
    state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
    state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace interact = 1 if year >= 2016 & (state == "MANIPUR" | state == "JHARKHAND")
    replace interact = 1 if year >= 2016 & (state == "ANDHRA PRADESH" | state == "HARYANA")
    replace interact = 1 if year >= 2013 & (state == "HIMACHAL PRADESH")
	
    egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)	
	
	//no controls
	reg enrolled_ind interact i.year i.num_dist, cluster(state_name)
end 

program dynamic_twfe_sums
    *ALL STUDENTS*
    use ../../../shared_data/cross_section_sum, clear
	drop if year < 2009
	 forvalues val = 1/8 {
		gen  lag_neg_`val' = 0
		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/5 {
		gen  lag_`val' = 0
		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_neg_1 = 0 
		
	la var lag_neg_8 "-8"
	la var lag_neg_7 "-7"
	la var lag_neg_6 "-6"
	la var lag_neg_5 "-5"
	la var lag_neg_4 "-4"
	la var lag_neg_3 "-3"
	la var lag_neg_2 "-2"
	la var lag_neg_1 "-1"
	la var lag_0 "0"
	la var lag_1 "1"
	la var lag_2 "2"
	la var lag_3 "3"
	la var lag_4 "4"
	la var lag_5 "5"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)

	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for All Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_full_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for All Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_full_sum_sas.png, height(450) width(600) replace 
	
	*GIRLS*
	use ../../../shared_data/cross_section_girls_sum, clear
	drop if year < 2009
	 forvalues val = 1/8 {
		gen  lag_neg_`val' = 0
		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/5 {
		gen  lag_`val' = 0
		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_neg_1 = 0 
		
	la var lag_neg_8 "-8"
	la var lag_neg_7 "-7"
	la var lag_neg_6 "-6"
	la var lag_neg_5 "-5"
	la var lag_neg_4 "-4"
	la var lag_neg_3 "-3"
	la var lag_neg_2 "-2"
	la var lag_neg_1 "-1"
	la var lag_0 "0"
	la var lag_1 "1"
	la var lag_2 "2"
	la var lag_3 "3"
	la var lag_4 "4"
	la var lag_5 "5"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
	reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_10 lag_neg_9 lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for Girls") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_girls_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for Girls") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_girls_sum_sas.png, height(450) width(600) replace 
	
	*LOW SES*
	use ../../../shared_data/cross_section_lowSES_sum, clear
	drop if year < 2009
	 forvalues val = 1/8 {
		gen  lag_neg_`val' = 0
		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
	}
	forvalues val = 0/5 {
		gen  lag_`val' = 0
		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
            state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
            state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
            state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
            state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
            state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
	}
	replace lag_neg_1 = 0 
		
	la var lag_neg_8 "-8"
	la var lag_neg_7 "-7"
	la var lag_neg_6 "-6"
	la var lag_neg_5 "-5"
	la var lag_neg_4 "-4"
	la var lag_neg_3 "-3"
	la var lag_neg_2 "-2"
	la var lag_neg_1 "-1"
	la var lag_0 "0"
	la var lag_1 "1"
	la var lag_2 "2"
	la var lag_3 "3"
	la var lag_4 "4"
	la var lag_5 "5"
	
	egen num_dist = group(district_name state_name)
	egen num_state = group(state_name)
	
    reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
		
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for Low-SES Children") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_lowSES_sum.png, height(450) width(600) replace 
	
	reg enrolled_ind_sas lag_* i.year i.num_dist, cluster(num_state)
	
	coefplot, omitted keep(lag*) vertical ///
	    order(lag_neg_8 ///
		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
		lag_1) title("Event Study Plot, Sum(Enrollment) for Low-SES Students") ///
		xtitle("Years to Treatment") xline(9)
		
	graph export ../output/twfe_lowSES_sum_sas.png, height(450) width(600) replace 
end 

program dynamic_twfe_means
    *ALL STUDENTS*
    use ../../../shared_data/cross_section_mean, clear	
	//full twfe
	drop if year < 2009
    drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM"
	drop if enrolled_ind_most_restrict == 2

	encode(state_name), gen(i)
	encode(district_name), gen(d)
	gen t = year
		
	gen first_treat = . 
	replace first_treat = 2017 if (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
			state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
			state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
			state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
			state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
			state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace first_treat = 2016 if (state == "MANIPUR" | state == "JHARKHAND")
	replace first_treat = 2015 if (state == "ANDHRA PRADESH" | state == "HARYANA")
	replace first_treat = 2013 if (state == "HIMACHAL PRADESH")
	
	gen rel_time = t - first_treat // event time
	gen never_treat = first_treat==. // controls
	sum first_treat
	gen last_cohort = first_treat==r(max) // last treated
	
	gen gvar = first_treat
	recode gvar (. = 0)
		
	// leads
	cap drop F_*
	cap drop ref*
	cap drop stack
	
	summ rel_time
	local relmin = abs(r(min))
	local relmax = abs(r(max))
	dis "`relmax' `relmin'"
	
	forvalues x = 1/`relmin' {
		dis "`x'"
		gen F_`x' = rel_time == -`x'
		replace F_`x' = 0 if never_treat == 1 
	}
	replace F_1 = 0 
	
	cap drop L_*
	forval x = 0/`relmax' {
		gen L_`x' = rel_time == `x'
		replace L_`x' = 0 if never_treat==1 
	} 
	
	ds F*
	local idx = 1
	foreach pre in `r(varlist)' {
		la var `pre' "-`idx'"
		local idx `++idx'
	}
	
	ds L*
	local idx = 0
	foreach post in `r(varlist)' {
		la var `post' "`idx'"
		local idx `++idx'
	}

	reg enrolled_ind_open L_* F_* i.d i.t, cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	    title("Event Study Plot, Mean(Enrollment) Using Open Measure") ///
	    xtitle("Years to Treatment")
	graph export ../output/twfe_full_open.png, height(450) width(600) replace 
	reg enrolled_ind_restrict L_* F_* i.d i.t, cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	    title("Event Study Plot, Mean(Enrollment) Using Restricted Measure") ///
	    xtitle("Years to Treatment")
	graph export ../output/twfe_full_restrict.png, height(450) width(600) replace 
	reg enrolled_ind_most_restrict L_* F_* i.d i.t, cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	    title("Event Study Plot, Mean(Enrollment) Using Most Restricted Measure") ///
	    xtitle("Years to Treatment")
	graph export ../output/twfe_full_most_restrict.png, height(450) width(600) replace 
		
	
// 	*GIRLS*
// 	use ../../../shared_data/cross_section_girls_mean, clear
// 	drop if year < 2009
// 	 forvalues val = 1/8 {
// 		gen  lag_neg_`val' = 0
// 		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	forvalues val = 0/5 {
// 		gen  lag_`val' = 0
// 		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	replace lag_neg_1 = 0 
//
// 	la var lag_neg_8 "-8"
// 	la var lag_neg_7 "-7"
// 	la var lag_neg_6 "-6"
// 	la var lag_neg_5 "-5"
// 	la var lag_neg_4 "-4"
// 	la var lag_neg_3 "-3"
// 	la var lag_neg_2 "-2"
// 	la var lag_neg_1 "-1"
// 	la var lag_0 "0"
// 	la var lag_1 "1"
// 	la var lag_2 "2"
// 	la var lag_3 "3"
// 	la var lag_4 "4"
// 	la var lag_5 "5"
//	
// 	egen num_dist = group(district_name state_name)
// 	egen num_state = group(state_name)
//	
// 	//no controls
// 	reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
//	
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for Girls") ///
// 		xtitle("Years to Treatment")  xline(9)
		
// 	graph export ../output/twfe_girls_mean.png, height(450) width(600) replace 
//	
// 	reg enrolled_ind_sas lag_* i.year i.num_dist, cluster(num_state)
//	
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for Girls") ///
// 		xtitle("Years to Treatment") xline(9)
//		
// 	graph export ../output/twfe_girls_mean_sas.png, height(450) width(600) replace 
//	
//     *BOYS*
// 	use ../../../shared_data/cross_section_boys_mean, clear
// 	drop if year < 2009
// 	 forvalues val = 1/8 {
// 		gen  lag_neg_`val' = 0
// 		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	forvalues val = 0/5 {
// 		gen  lag_`val' = 0
// 		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	replace lag_neg_1 = 0 
//
// 	la var lag_neg_8 "-8"
// 	la var lag_neg_7 "-7"
// 	la var lag_neg_6 "-6"
// 	la var lag_neg_5 "-5"
// 	la var lag_neg_4 "-4"
// 	la var lag_neg_3 "-3"
// 	la var lag_neg_2 "-2"
// 	la var lag_neg_1 "-1"
// 	la var lag_0 "0"
// 	la var lag_1 "1"
// 	la var lag_2 "2"
// 	la var lag_3 "3"
// 	la var lag_4 "4"
// 	la var lag_5 "5"
//	
// 	egen num_dist = group(district_name state_name)
// 	egen num_state = group(state_name)
//	
// 	//no controls
// 	reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
//	
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for Boys") ///
// 		xtitle("Years to Treatment")  xline(9)
//		
// 	graph export ../output/twfe_boys_mean.png, height(450) width(600) replace 
//
// 	*LOW SES*
// 	use ../../../shared_data/cross_section_lowSES_mean, clear
// 	drop if year < 2009
// 	 forvalues val = 1/8 {
// 		gen  lag_neg_`val' = 0
// 		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	forvalues val = 0/5 {
// 		gen  lag_`val' = 0
// 		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	replace lag_neg_1 = 0 
//		
//     la var lag_neg_8 "-8"
// 	la var lag_neg_7 "-7"
// 	la var lag_neg_6 "-6"
// 	la var lag_neg_5 "-5"
// 	la var lag_neg_4 "-4"
// 	la var lag_neg_3 "-3"
// 	la var lag_neg_2 "-2"
// 	la var lag_neg_1 "-1"
// 	la var lag_0 "0"
// 	la var lag_1 "1"
// 	la var lag_2 "2"
// 	la var lag_3 "3"
// 	la var lag_4 "4"
// 	la var lag_5 "5"
//	
// 	egen num_dist = group(district_name state_name)
// 	egen num_state = group(state_name)
//	
// 	//no controls
//     reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
//		
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for Low-SES Children") ///
// 		xtitle("Years to Treatment")  xline(9)
//		
// 	graph export ../output/twfe_lowSES_mean.png, height(450) width(600) replace 
//	
// 	reg enrolled_ind_sas lag_* i.year i.num_dist, cluster(num_state)
//	
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for Low-SES Children") ///
// 		xtitle("Years to Treatment") xline(9)
//		
// 	graph export ../output/twfe_lowSES_mean_sas.png, height(450) width(600) replace 
//	
// 	*ALL BUT LOW SES*
// 	use ../../../shared_data/cross_section_remainderSES_mean, clear
// 	drop if year < 2009
//     forvalues val = 1/8 {
// 		gen  lag_neg_`val' = 0
// 		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	forvalues val = 0/5 {
// 		gen  lag_`val' = 0
// 		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	replace lag_neg_1 = 0 
//
//		
// 	la var lag_neg_8 "-8"
// 	la var lag_neg_7 "-7"
// 	la var lag_neg_6 "-6"
// 	la var lag_neg_5 "-5"
// 	la var lag_neg_4 "-4"
// 	la var lag_neg_3 "-3"
// 	la var lag_neg_2 "-2"
// 	la var lag_neg_1 "-1"
// 	la var lag_0 "0"
// 	la var lag_1 "1"
// 	la var lag_2 "2"
// 	la var lag_3 "3"
// 	la var lag_4 "4"
// 	la var lag_5 "5"
//	
// 	egen num_dist = group(district_name state_name)
// 	egen num_state = group(state_name)
//	
// 	//no controls
//     reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
//		
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1) title("Event Study Plot, Mean(Enrollment) for All but Low-SES Children") ///
// 		xtitle("Years to Treatment")  xline(9)
//		
// 	graph export ../output/twfe_remainderSES_mean.png, height(450) width(600) replace 
//	
// 	*SMALL STATES DROPPED*
// 	use ../../../shared_data/cross_section_noSmall_mean, clear
// 	drop if year < 2009
// 	forvalues val = 1/8 {
// 		gen  lag_neg_`val' = 0
// 		replace lag_neg_`val' = 1 if year == (2017 - `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_neg_`val' = 1 if year == 2016 - `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_neg_`val' = 1 if year == 2015 - `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_neg_`val' = 1 if year == 2013 - `val' & (state == "HIMACHAL PRADESH")
// 	}
// 	forvalues val = 0/5 {
// 		gen  lag_`val' = 0
// 		replace lag_`val' = 1 if year == (2017 + `val') & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
//             state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
//             state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
//             state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
//             state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
//             state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 		replace lag_`val' = 1 if year == 2016 + `val' & (state == "MANIPUR" | state == "JHARKHAND")
// 		replace lag_`val' = 1 if year == 2015 + `val' & (state == "ANDHRA PRADESH" | state == "HARYANA")
// 	    replace lag_`val' = 1 if year == 2013 + `val' & (state == "HIMACHAL PRADESH")
// 	}
//	
//	
// 	replace lag_neg_1 = 0 
//		
// 	la var lag_neg_8 "-8"
// 	la var lag_neg_7 "-7"
// 	la var lag_neg_6 "-6"
// 	la var lag_neg_5 "-5"
// 	la var lag_neg_4 "-4"
// 	la var lag_neg_3 "-3"
// 	la var lag_neg_2 "-2"
// 	la var lag_neg_1 "-1"
// 	la var lag_0 "0"
// 	la var lag_1 "1"
// 	la var lag_2 "2"
// 	la var lag_3 "3"
// 	la var lag_4 "4"
// 	la var lag_5 "5"
//	
// 	egen num_dist = group(district_name state_name)
// 	egen num_state = group(state_name)
//	
// 	//no controls
//     reg enrolled_ind lag_* i.year i.num_dist, cluster(num_state)
//		
// 	coefplot, omitted keep(lag*) vertical ///
// 	    order(lag_neg_8 ///
// 		lag_neg_7 lag_neg_6 lag_neg_5 lag_neg_4 ///
// 		lag_neg_3 lag_neg_2 lag_neg_1 lag_0 ///
// 		lag_1 lag_2 lag_3 lag_4 lag_5) ///
// 		title("Event Study Plot, Mean(Enrollment) without Sikkim, Nagaland, or Meghalaya") ///
// 		xtitle("Years to Treatment")  xline(9)
//		
// 	graph export ../output/twfe_noSmall_mean.png, height(450) width(600) replace 
end 

program twfe_decomposed
     use ../../../shared_data/cross_section_mean, clear	
	//2013 cohort 
	preserve 
	    //dynamic twfe
		drop if year < 2009
		drop if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "HIMACHAL PRADESH" //only compare to true controls
			
		encode(state_name), gen(i)
		encode(district_name), gen(d)
		gen t = year
			
		gen first_treat = . 
		replace first_treat = 2013 if state == "HIMACHAL PRADESH"
		
		gen rel_time = t - first_treat // event time
		gen never_treat = first_treat==. // controls
		sum first_treat
		gen last_cohort = first_treat==r(max) // last treated
		
		gen gvar = first_treat
		recode gvar (. = 0)
		
		// leads
		cap drop F_*
		cap drop ref*
		cap drop stack
		
		summ rel_time
		local relmin = abs(r(min))
		local relmax = abs(r(max))
		dis "`relmax' `relmin'"
		
		forvalues x = 1/`relmin' {
			dis "`x'"
			gen F_`x' = rel_time == -`x'
			replace F_`x' = 0 if never_treat == 1 
		}
		replace F_1 = 0 
		
		cap drop L_*
		forval x = 0/`relmax' {
			gen L_`x' = rel_time == `x'
			replace L_`x' = 0 if never_treat==1 
		} 
		
		ds F*
		local idx = 1
		foreach pre in `r(varlist)' {
			la var `pre' "-`idx'"
			local idx `++idx'
		}

		ds L*
		local idx = 0
		foreach post in `r(varlist)' {
			la var `post' "`idx'"
			local idx `++idx'
		}
	
		reg enrolled_ind_most_restrict L_* F_* i.d i.t, cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	        title("Event Study Plot, 2013 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2013cohort.png, height(450) width(600) replace 
	restore 
	
	//2015 cohort
	preserve 
		drop if year < 2009
		drop if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "ANDHRA PRADESH" & ///
			state != "HARYANA" //only compare to true controls
			
		encode(state_name), gen(i)
		encode(district_name), gen(d)
		gen t = year
			
		gen first_treat = . 
		replace first_treat = 2015 if state == "ANDHRA PRADESH" | state == "HARYANA"
		
		gen rel_time = t - first_treat // event time
		gen never_treat = first_treat==. // controls
		sum first_treat
		gen last_cohort = first_treat==r(max) // last treated
		
		gen gvar = first_treat
		recode gvar (. = 0)
		
		// leads
		cap drop F_*
		cap drop ref*
		cap drop stack
		
		summ rel_time
		local relmin = abs(r(min))
		local relmax = abs(r(max))
		dis "`relmax' `relmin'"
		
		forvalues x = 1/`relmin' {
			dis "`x'"
			gen F_`x' = rel_time == -`x'
			replace F_`x' = 0 if never_treat == 1 
		}
		replace F_1 = 0 
		
		cap drop L_*
		forval x = 0/`relmax' {
			gen L_`x' = rel_time == `x'
			replace L_`x' = 0 if never_treat==1 
		} 
		
		ds F*
		local idx = 1
		foreach pre in `r(varlist)' {
			la var `pre' "-`idx'"
			local idx `++idx'
		}

		ds L*
		local idx = 0
		foreach post in `r(varlist)' {
			la var `post' "`idx'"
			local idx `++idx'
		}
	
		reg enrolled_ind_most_restrict L_* i.d i.t, cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	        title("Event Study Plot, 2015 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2015cohort.png, height(450) width(600) replace 
	restore 
	
	//2016 cohort
	preserve 
		//cohort TWFE based on the sample code 
		drop if year < 2014 | year > 2016
		drop if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "MANIPUR" & ///
			state != "JHARKHAND" //only compare to true controls
			
		encode(state_name), gen(i)
		encode(district_name), gen(d)
		gen t = year
			
		gen first_treat = . 
		replace first_treat = 2016 if (state == "MANIPUR" | state == "JHARKHAND")
		
		gen rel_time = t - first_treat // event time
		gen never_treat = first_treat==. // controls
		sum first_treat
		gen last_cohort = first_treat==r(max) // last treated
		
		gen gvar = first_treat
		recode gvar (. = 0)
		
		// leads
		cap drop F_*
		cap drop ref*
		cap drop stack
		
		summ rel_time
		local relmin = abs(r(min))
		local relmax = abs(r(max))
		dis "`relmax' `relmin'"
		
		forvalues x = 1/`relmin' {
			dis "`x'"
			gen F_`x' = rel_time == -`x'
			replace F_`x' = 0 if never_treat == 1 
		}
		replace F_1 = 0 
		
		cap drop L_*
		forval x = 0/`relmax' {
			gen L_`x' = rel_time == `x'
			replace L_`x' = 0 if never_treat==1 
		} 
		
		ds F*
		local idx = 1
		foreach pre in `r(varlist)' {
			la var `pre' "-`idx'"
			local idx `++idx'
		}

		ds L*
		local idx = 0
		foreach post in `r(varlist)' {
			la var `post' "`idx'"
			local idx `++idx'
		}
		
		reg enrolled_ind_most_restrict F_2 L_0 i.d i.t, cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	        title("Event Study Plot, 2016 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2016cohort.png, height(450) width(600) replace 
		
		
		//difference in means: (.964021 -  .9832123) - (.9553404 - .9756249) = 0.0010932
		//which is what shows up from the standard DiD. 
		bysort L_0: egen postmean = mean(enrolled_ind_most_restrict) if year == 2016
		bysort F_2: egen premean = mean(enrolled_ind_most_restrict) if year == 2014
		//****
		
		//standard DiD
		use ../../../shared_data/cross_section_mean, clear
		drop if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "MANIPUR" & ///
			state != "JHARKHAND" //only compare to true controls
		egen num_dist = group(district_name)
		gen treat = 0
		replace treat = 1 if state == "MANIPUR" | state == "JHARKHAND" 
		gen post = 0
		replace post = 1 if year >= 2016
		gen interact = treat*post
		drop if year != 2014 & year != 2016
		
		reg enrolled_ind_most_restrict treat post interact i.year i.num_dist, cluster(state_name)
		//point estimate on beta_interact: .0010931
					
	    //static twfe - this matches the DiD exactly which makes sense.
		gen twfe_interact = 0
		replace twfe_interact = 1 if year >= 2018 & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
		state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
		state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
		state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
		state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
		state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
		replace twfe_interact = 1 if year >= 2016 & (state == "MANIPUR" | state == "JHARKHAND")
		replace twfe_interact = 1 if year >= 2016 & (state == "ANDHRA PRADESH" | state == "HARYANA")
		replace twfe_interact = 1 if year >= 2013 & (state == "HIMACHAL PRADESH")
		
		reg enrolled_ind_most_restrict twfe_interact i.year i.num_dist, cluster(state_name)
	restore 
	
	//2017 cohort 
	preserve 
		drop if year < 2009
		drop if state == "HIMACHAL PRADESH" | state == "ANDHRA PRADESH" | state == "HARYANA" | ///
		    state == "MANIPUR" | state == "JHARKHAND"
		encode(state_name), gen(i)
		encode(district_name), gen(d)
		gen t = year
			
		gen first_treat = . 
		replace first_treat = 2017 if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA"
		
		gen rel_time = t - first_treat // event time
		gen never_treat = first_treat==. // controls
		sum first_treat
		gen last_cohort = first_treat==r(max) // last treated
		
		gen gvar = first_treat
		recode gvar (. = 0)
		
		// leads
		cap drop F_*
		cap drop ref*
		cap drop stack
		
		summ rel_time
		local relmin = abs(r(min))
		local relmax = abs(r(max))
		dis "`relmax' `relmin'"
		
		forvalues x = 1/`relmin' {
			dis "`x'"
			gen F_`x' = rel_time == -`x'
			replace F_`x' = 0 if never_treat == 1 
		}
		replace F_1 = 0 
		
		cap drop L_*
		forval x = 0/`relmax' {
			gen L_`x' = rel_time == `x'
			replace L_`x' = 0 if never_treat==1 
		} 
		
		ds F*
		local idx = 1
		foreach pre in `r(varlist)' {
			la var `pre' "-`idx'"
			local idx `++idx'
		}

		ds L*
		local idx = 0
		foreach post in `r(varlist)' {
			la var `post' "`idx'"
			local idx `++idx'
		}
		
		reg enrolled_ind_most_restrict L_* F_* i.d i.t, cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	        title("Event Study Plot, 2017 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2017cohort.png, height(450) width(600) replace 
	restore
end 

*Execute
main