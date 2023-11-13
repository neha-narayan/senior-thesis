capture log close 
log using analysis.log, replace
clear all
set more off

program main 
//     enrollment_plots
// 	dynamic_twfe
	cohort_twfe
//     stacking
// 	covar_matching
// 	DiD
// 	timeseries
//     tests
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
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU"
	drop if ac_year < 2011
	
	encode(statename), gen(i)
	encode(distname), gen(d)
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
	
	gen STshare =  primaryage_ST / primaryage_all
	gen SCshare = primaryage_SC / primaryage_all 
	
	bysort statename: egen stateST = mean(STshare)
	bysort statename: egen stateSC = mean(SCshare)
	
	sum STshare, de
	sum SCshare, de 
	sum stateST, de
	sum stateSC, de 
	
	preserve 
	    keep if SCshare >= stateSC
		//wildbootstrap reg enrollment_rate L_* F_* i.d i.t [weight=schtot], cluster(i) rseed(1960)
		reg enrollment_rate L_* F_* i.d i.t [weight=schtot], cluster(i)
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	    title("Event Study Plot, SC Students") ///
	     xtitle("Years From Treatment")
	restore 
	
	preserve 
	    keep if STshare >= stateST 
	    ///wildbootstrap reg enrollment_rate L_* F_* i.d i.t [weight=schtot], cluster(i) rseed(1960)
		reg enrollment_rate L_* F_* i.d i.t [weight=schtot], cluster(i)
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	    title("Event Study Plot, ST Students") ///
	     xtitle("Years From Treatment")
	restore 
		
	reg enrollment_rate L_* F_* i.d i.t [weight=schtot], cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	    title("Event Study Plot, Full TWFE") ///
	     xtitle("Years From Treatment")
	graph export ../output/twfe_full_notyet_trim.png, height(450) width(600) replace
end 

program cohort_twfe
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU"
	drop if ac_year < 2011
	
	//2015 cohort
	preserve 		
		encode(statename), gen(i)
	    gen t = ac_year
			
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
	    keep if first_treat == 2015 | mi(first_treat)
			
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
		
		tempfile 2015cohort 
		drop i t 
		gen dataset = 2015
		save `2015cohort'
	
// 		wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
// 		coefplot, omitted keep(L* F*) vertical ///
// 	        order(F_7 F_8 F_6 F_5 F_4 F_3 F_2 F_1 L_0) ///
// 	        title("Event Study Plot, 2015 Cohort") ///
// 	        xtitle("Years From Treatment")
// 	    graph export ../output/twfe_2015cohort.png, height(450) width(600) replace 
	restore 
	
	//2016 cohort
	preserve 
		encode(statename), gen(i)
	    gen t = ac_year
			
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
	    keep if first_treat == 2016 | mi(first_treat)
		
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
	
	    tempfile 2016cohort 
		drop i t 
		gen dataset = 2016
		save `2016cohort'
		
// 		wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
// 		coefplot, omitted keep(L* F*) vertical ///
// 	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0) ///
// 	        title("Event Study Plot, 2016 Cohort") ///
// 	        xtitle("Years From Treatment")
// 	    graph export ../output/twfe_2016cohort_notyet_trim.png, height(450) width(600) replace 
	restore

	//2017 
	preserve 
		encode(statename), gen(i)
	    gen t = ac_year
			
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
	    keep if first_treat == 2017 | mi(first_treat)
		
			 
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
		
		tempfile 2017cohort 
		drop i t 
		gen dataset = 2017 
		save `2017cohort'
	
// 		wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
// 		coefplot, omitted keep(L* F*) vertical ///
// 	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0) ///
// 	        title("Event Study Plot, 2017 Cohort") ///
// 	        xtitle("Years From Treatment")
// 	    graph export ../output/twfe_2017cohort_dise_2011rate.png, height(450) width(600) replace 
	restore
	
	clear 
	append using `2015cohort'
	append using `2016cohort'
	append using `2017cohort'

	save ../output/cohortdata, replace
end 

program stacking 
	use ../output/cohortdata, clear
	
	drop first_treat rel_time never_treat last_cohort gvar F* L* 

	encode(statename), gen(i)
	encode(distname), gen(d)
	gen t = ac_year
		
	gen first_treat = . 
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
	
	drop L_5 L_6 F_5 F_6
    gen district_x_data = d*dataset
	gen year_x_data = t*dataset
	
	gen STshare =  primaryage_ST / primaryage_all
	gen SCshare = primaryage_SC / primaryage_all 

	
	bysort statename: egen stateST = mean(STshare)
	bysort statename: egen stateSC = mean(SCshare)
	bysort statename: egen state_rural = mean(rural_ind)
	
	sum STshare, de
	sum SCshare, de 
	sum stateST, de
	sum stateSC, de  

	preserve 
	    keep if rural_ind < state_rural
		reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i)
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Event Study Plot, Stacked Regression") ///
	    xtitle("Years From Treatment")
	restore
	
	preserve 
	    keep if SCshare >= stateSC
		reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i)
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Event Study Plot, Stacked Regression") ///
	    xtitle("Years From Treatment")
	restore 
	
	preserve 
	    keep if STshare >= stateST 
		wildbootstrap reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], ///
		    cluster(i) rseed(1960)
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Event Study Plot, Stacked Regression") ///
	    xtitle("Years From Treatment")
	restore 
		
	
// 	wildbootstrap reg enrollment_rateb L_* F_* i.state_x_data i.year_x_data [weight=schtot], cluster(i) rseed(1960)
	
	
	graph export ../output/twfe_stack.png, height(450) width(600) replace
end 

program covar_matching 
    use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM"
	drop if ac_year < 2011
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
	
	//let's define some control groups based on population size. our 5 controls are Assam, Maharashtra,
	//West Bengal, Meghalaya, and Jammu + Kashmir 
	
	//assam = 5,381,152 
	//maharashtra = 1.97e+07 (order of 10.9 mil)
	//west bengal = 1.61e+07 (10.6 mil)
	//meghalaya = = 547,757
	//j+k = 2,157,691
	
	//primaryage_all quintiles: min =  10359.14, 20th =  222471.5, 40th: 2157691 
	//60th =  5409471, 80th = 1.27e+07, max = 3.61e+07
	
	//first 20% - meghalaya, 20-40%: j+k, 40-60: assam, 60-80: west bengal, 80-100: maharashtra
	
// 	gen group = ""
// 	replace group = "0to20" if state == "ANDAMAN & NICOBAR ISLANDS" | state == "CHANDIGARH" | ///
// 	    state == "DNH & DD" | state == "GOA" | state == "LAKSHADWEEP" | state == "SIKKIM" | ///
// 		state == "MEGHALAYA"
// 	replace group = "20to40" if state == "ARUNACHAL PRADESH" | state == "GOA" | state == "JAMMU & KASHMIR" | ///
// 	    state == "MANIPUR" | state == "NAGALAND" | state == "TRIPURA"
// 	replace group = "40to60" if state == "ASSAM" | state == "DELHI" | state == "HARYANA" | ///
// 	    state == "JHARKHAND" | state == "KERALA" | state == "PUNJAB"
// 	replace group = "60to80" if state == "GUJARAT" | state == "KARNATAKA" | state == "ODISHA" | ///
// 	    state == "RAJASTHAN" | state == "TAMIL NADU" | state == "WEST BENGAL"
// 	replace group = "80to100" if state == "ANDHRA PRADESH" | state == "BIHAR" | state == "MADHYA PRADESH" | ///
// 	    state == "MAHARASHTRA" | state == "UTTAR PRADESH" 
//		
//    // regions from here: https://en.wikipedia.org/wiki/Administrative_divisions_of_India
//    gen region = ""
//    replace region = "NORTH" if state == "CHANDIGARH" | state == "DELHI" | state == "HARYANA" | ///
//        state == "JAMMU & KASHMIR" | state == "PUNJAB" | state == "RAJASTHAN"
//    replace region = "NORTHEAST" if state == "ASSAM" | state == "ARUNCHAL PRADESH" | state == "MANIPUR" | ///
//        state == "MEGHALAYA" | state == "NAGALAND" | state == "TRIPURA" | state == "SIKKIM"
//    replace region = "CENTRAL-EAST" if state == "CHHATTISGARH" | state == "MADHYA PRADESH" | state == "UTTAR PRADESH" | ///
//        state == "BIHAR" | state == "JHARKHAND" | state == "ODISHA" | state == "WEST BENGAL"
//    replace region = "WEST" if state == "DNH & DD" | state == "GOA" | state == "GUJARAT" | state == "MAHARASHTRA"
//   
   gen STshare = primaryage_ST/primaryage_all 
   gen group = ""
   replace group = "HighIndigenous" if STshare >= .1117244
   
	preserve 
		keep if group == "HighIndigenous"
		encode(statename), gen(i)
		gen t = ac_year
				 
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

		wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
		coefplot, omitted keep(L* F*) vertical ///
			order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
			title("Event Study Plot, Upper 50% of Indigenous Share Distribution") ///
			xtitle("Years From Treatment")
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
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM"
	drop if ac_year < 2013 
	
	encode(statename), gen(i)
	gen t = ac_year
			
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
	drop if gvar == 0 

	reg enrollment_rate rel_time if ac_year < gvar
	predict synthetic_ctrls
    
	replace synthetic_ctrls = enrollment_rate if ac_year < gvar 
	
	preserve 
		tempfile temp
		levelsof statename, local(states)
		foreach state in `states' {
			replace statename = "SYNTH `state'" if statename == "`state'"
		}
		keep statename ac_year schtot synthetic_ctrls first_treat
		rename synthetic_ctrls enrollment_rate
		save `temp'
	restore 
	drop synthetic_ctrls
	append using `temp'
	
	keep statename ac_year schtot enrollment_rate first_treat
    
	encode(statename), gen(i)
	gen t = ac_year
	levelsof statename if strpos(statename, "SYNTH"), local(synth)
	foreach state in `synth' {
		replace first_treat = . if statename == "`state'"
	}
	
	gen rel_time = t - first_treat // event time
	gen never_treat = first_treat==. // controls
	sum first_treat
	gen last_cohort = first_treat==r(max) // last treated
	
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
	
	reg enrollment_rate L* F* i.t i.i [weight=schtot], cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("2017 Cohort, Synthetic Control Approach") ///
	        xtitle("Years From Treatment")
	
	replace rel_time = t - 2017 if strpos(statename, "SYNTH")
    scatter enrollment_rate rel_time if strpos(statename, "SYNTH") || lfit enrollment_rate rel_time if strpos(statename, "SYNTH") || ///
	scatter enrollment_rate rel_time if !strpos(statename, "SYNTH") || lfit enrollment_rate rel_time if !strpos(statename, "SYNTH")
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