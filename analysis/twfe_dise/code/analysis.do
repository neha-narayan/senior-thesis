capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    *enrollment_plots
	dynamic_twfe
	//cohort_twfe
	//DiD
	//timeseries
    * tests
end

program enrollment_plots
    use ../../../shared_data/enrollment_dise, clear
	qui ds c*
	egen enrollment = rowtotal(`r(varlist)')
    bysort statename ac_year govt_ind: egen state_enroll = total(enrollment)
    duplicates drop statename ac_year govt_ind, force
    twoway line enrollment_rate ac_year if statename == "ASSAM", xline(9)
end 

program dynamic_twfe
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM"
	drop if ac_year < 2011 
	
	encode(statename), gen(i)
	//encode(distname), gen(d)
	gen t = ac_year
			
	//subject to change based on what the RTI guys say. 
	gen first_treat = . 
	replace first_treat = 2019 if state == "TAMIL NADU"
	replace first_treat = 2017 if (state == "ANDAMAN & NICOBAR ISLANDS" | ///
		state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
		state == "DNH & DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
		state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
		state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
		state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace first_treat = 2016 if (state == "MANIPUR" | state == "JHARKHAND" | state == "DELHI")
	replace first_treat = 2015 if (state == "ANDHRA PRADESH" | state == "HARYANA")
	
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
	
	reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i)
	reg enrollment_rate_b L_* F_* i.i i.t [weight=schtot], cluster(i)
	reg enrollment_rate_g L_* F_* i.i i.t [weight=schtot], cluster(i)
	boottest L_0, boottype(wild)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_10 F_9 F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	    title("Event Study Plot, Full TWFE") ///
	     xtitle("Years From Treatment")
	graph export ../output/twfe_full_dise_rate.png, height(450) width(600) replace
end 

program cohort_twfe
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" 
	drop if ac_year < 2011 
	
	//2015 cohort
	preserve 
		drop if state != "ASSAM" & state != "WEST BENGAL" & state != "MAHARASHTRA" & ///
		    state != "MEGHALAYA" & state != "JAMMU & KASHMIR" & ///
		    state != "HARYANA" & state != "ANDHRA PRADESH" //only compare to true controls
			
		encode(statename), gen(i)
		//encode(distname), gen(d)
		gen t = ac_year
			
		gen first_treat = . 
		replace first_treat = 2015 if state == "HARYANA" | state == "ANDHRA PRADESH"
		
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
	
		reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i)
		reg enrollment_rate_b L_* F_* i.i i.t [weight=schtot], cluster(i)	
		reg enrollment_rate_g L_* F_* i.i i.t [weight=schtot], cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	        title("Event Study Plot, 2015 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2015cohort_dise_rate.png, height(450) width(600) replace 
	restore 
	
	//2016 cohort
	preserve 
		drop if state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "JAMMU & KASHMIR" & ///
			state != "MANIPUR" &  state != "JHARKHAND" & state != "DELHI" //only compare to true controls
			
		encode(statename), gen(i)
		//encode(distname), gen(d)
		gen t = ac_year
			
		gen first_treat = . 
		replace first_treat = 2016 if (state == "MANIPUR" | state == "JHARKHAND" | state == "DELHI") 
		
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
	
		reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5) ///
	        title("Event Study Plot, 2016 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2016cohort_dise_rate.png, height(450) width(600) replace 
	restore

	//2017 
	preserve 
		drop if state == "ANDHRA PRADESH" | state == "HARYANA" | ///
		    state == "MANIPUR" | state == "JHARKHAND" | state == "DELHI" | state == "TAMIL NADU"
		encode(statename), gen(i)
		//encode(distname), gen(d)
		gen t = ac_year
			
		gen first_treat = . 
		replace first_treat = 2017 if state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "JAMMU & KASHMIR" //the true controls
			 
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
	
		reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Event Study Plot, 2017 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2017cohort_dise_rate.png, height(450) width(600) replace 
	restore
	
	//2019
	preserve 
		drop if state != "WEST BENGAL" & state != "ASSAM" & ///
		    state != "MAHARASHTRA" & state != "MEGHALAYA" & state != "TAMIL NADU"
			
		encode(statename), gen(i)
		gen t = ac_year
			
		gen first_treat = . 
		replace first_treat = 2019 if state == "TAMIL NADU"
		
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
	
		reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i)	
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_10 F_9 F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2) ///
	        title("Event Study Plot, 2019 Cohort") ///
	        xtitle("Years From Treatment")
	    graph export ../output/twfe_2019cohort_dise_rate.png, height(450) width(600) replace 
	restore
end 

program DiD
    use ../../../shared_data/enrollment_dise, clear
	
	encode(statename), gen(i)
	
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM"
	
	keep if state == "TAMIL NADU" | state == "WEST BENGAL" | state == "ASSAM" | ///
		state == "MAHARASHTRA" | state == "MEGHALAYA" | state == "ANDAMAN & NICOBAR ISLANDS" | ///
		state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
		state == "DNH & DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
		state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
		state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
		state == "UTTAR PRADESH" | state == "MADHYA PRADESH"
	gen treat = 0
	replace treat = 1 if state != "TAMIL NADU" & state != "WEST BENGAL" & state != "ASSAM" & ///
	    state != "MAHARASHTRA" & state != "MEGHALAYA"
	gen post = 0
	replace post = 1 if ac_year >= 2017
	gen interact = treat*post
		
	reg enrollment_rate treat post interact i.ac_year i.i [weight=schtot], cluster(i)
end

program timeseries 
    use ../../../shared_data/enrollment_dise, clear
	drop if statename != "TAMIL NADU"
	
	encode(statename), gen(i)
	tsset ac_year
	corrgram enrollment_rate
	gen d_enroll = enrollment_rate[_n] - enrollment_rate[_n-1]
	reg d_enroll L.d_enroll, r 
	
// 	gen treatment = 0 
// 	replace treatment = 1 if ac_year >= 2017 & (state == "ANDAMAN & NICOBAR ISLANDS" | ///
// 		state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
// 		state == "DNH & DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
// 		state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
// 		state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
// 		state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
// 	replace treatment = 1 if ac_year >= 2016 & (state == "MANIPUR" | state == "JHARKHAND" | state == "DELHI")
// 	replace treatment = 1 if ac_year >= 2015 & (state == "ANDHRA PRADESH" | state == "HARYANA")

// 	//storing synthetic estimates
// 	gen holder = .
//
// 	//generate lag variables 
// 	bysort statename: gen enroll_lag1 = enrollment_rate[_n-1]
// 	bysort statename: gen enroll_lag2 = enrollment_rate[_n-2]
// 	bysort statename: gen enroll_lag3 = enrollment_rate[_n-3]
//
// 	regress enrollment_rate enroll_lag1, r
// 	predict synthetic_enrollment17 
// 	replace holder = synthetic_enrollment17 if year == 2017 &
//	
// 	encode(statename), gen(i) 
// 	reg diff treatment i.ac_year i.i, cluster(i)
end 


program tests
	use ../../../shared_data/enrollment_dise_disaggregated, clear
	qui ds c*
	egen enrollment = rowtotal(`r(varlist)')
	
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM"
	drop if ac_year < 2009
	drop if govt_ind == 0 
	
	encode(statename), gen(i)
	encode(distname), gen(d)
	gen t = ac_year
	
	gen interact = 0
	replace interact = 1 if ac_year >= 2018 & (state == "ANDAMAN AND NICOBAR ISLANDS" | ///
    state == "ARUNACHAL PRADESH" | state == "BIHAR" | state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
    state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
    state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
    state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
    state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace interact = 1 if ac_year >= 2016 & (state == "MANIPUR" | state == "JHARKHAND")
    replace interact = 1 if ac_year >= 2016 & (state == "ANDHRA PRADESH" | state == "HARYANA")
    replace interact = 1 if ac_year >= 2013 & (state == "HIMACHAL PRADESH")
	
	reg enrollment i.ac_year i.d interact, cluster(i)
	predict double resid, residuals
	twoway scatter resid ac_year //how do residuals vary over time?
	
	rvfplot, title("Residual Plot from DiD Regression (DISE)") 
	//graph export ../output/residual.pdf, replace
	
	sktest resid

	frontier enrollment i.t i.i interact, vce(cluster i)
end 



*Execute
main