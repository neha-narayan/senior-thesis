capture log close 
log using analysis.log, replace
clear all
set more off

program main 
// 	dynamic_twfe
// 	cohort_twfe
    stacking
//     rural_urban
end

program dynamic_twfe
	use ../../../shared_data/enrollment_dise, clear
	collapse (sum) enrollment enrollment_rate schtot govt_ind ///
	    (firstnm) primaryage_* reliable, by(statename distname ac_year)
	//drop states with uncertainty in treatment timing + bad parallel trends 
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU"
	drop if ac_year < 2009
	
	encode(statename), gen(i)
	encode(distname), gen(d)
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
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	        title("Dynamic TWFE") ///
            xtitle("Years From Treatment") 
	 graph export ../output/twfe_full, height(450) width(600) replace 	
end  

program cohort_twfe
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" 
	
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
	    keep if first_treat == 2019 | mi(first_treat)
			
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
		
		tempfile 2019cohort 
		drop i t 
		gen dataset = 2019
		save `2019cohort'
	
// 		wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
// 		coefplot, omitted keep(L* F*) vertical ///
// 	        order(F_7 F_8 F_6 F_5 F_4 F_3 F_2 F_1 L_0) ///
// 	        title("Event Study Plot, 2015 Cohort") ///
// 	        xtitle("Years From Treatment")
// 	    graph export ../output/twfe_2015cohort.png, height(450) width(600) replace 
	restore 
	
	clear 
	append using `2015cohort'
	append using `2016cohort'
	append using `2017cohort'
    append using `2019cohort'
	
	save ../output/cohortdata, replace
end 

program stacking 
	use ../output/cohortdata, clear
	collapse (sum) enrollment enrollment_rate schtot govt_ind ///
	    (firstnm) primaryage* reliable_index, by(statename distname ac_year dataset)
	bysort statename distname (reliable_index): replace reliable_index=reliable_index[1]
	drop if ac_year < 2011
	
	cap drop first_treat rel_time never_treat last_cohort gvar L* F* 

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
	
// 	drop if reliable_index > 1 
//	
// 	gen reliable_scale = ""
// 	centile reliable_index if ac_year == 2011, centile(50)
// 	replace reliable_scale = "Least Reliable" if reliable_index < `r(c_1)'
// 	replace reliable_scale = "Most Reliable"  if reliable_index >= `r(c_1)'
//	
// 	reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
// 	    reliable_scale == "Most Reliable", cluster(i) 
// 	matrix observe = e(b)
//
// 	cap program drop myboot
// 	program define myboot, rclass
//         preserve
// 		    bsample 1, strata(statename reliable_scale)
// 			reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
// 	            reliable_scale == "Most Reliable", cluster(i) 
// 			return matrix beta = e(b)
// 		restore 
// 	end 
//     simulate beta=r(beta), reps(100) seed(12345): myboot
//
// 	centile reliable_index if ac_year == 2011, centile(50)
// 	la var reliable_index "Reliability Index"
// 	hist reliable_index if ac_year == 2011, xline(`r(c_1)', lcolor(red))
// 	graph export ../output/reliabilitydist.png, width(600) height(450) replace
//	
// 	wildbootstrap reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
// 	    reliable_scale == "Most Reliable", cluster(i) rseed(1960)
// 	estimates store mostreliable
// 	wildbootstrap reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
// 	    reliable_scale == "Least Reliable", cluster(i) rseed(1960)
// 	estimates store leastreliable
//
//     coefplot mostreliable leastreliable, omitted keep(L* F*) vertical ///
// 	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
// 	        title("Stacked TWFE, Most vs. Least Reliable Districts") ///
//             xtitle("Years From Treatment") ///
// 			legend(order(1 "Most Reliable" 3 "Least Reliable"))
// 	graph export ../output/erroranalysis/twfe_stack_mostvsleast.png, height(450) width(600) replace

	 preserve
	    bysort ac_year: egen natlSTshare = mean(primaryage_ST/primaryage_all)
        bysort statename distname ac_year: gen distSTshare = primaryage_ST/primaryage_all
	    keep if distSTshare > natlSTshare 
	    reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i)
		 coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Dynamic TWFE, Higher-than-National-Average ST Population") ///
            xtitle("Years From Treatment")
         graph export "../output/final figures/twfe_stack_ST.png", height(450) width(600) replace 
	restore 
	
	preserve 
	    bysort ac_year: egen natlSCshare = mean(primaryage_SC/primaryage_all)
	    bysort statename distname ac_year: gen distSCshare = primaryage_SC/primaryage_all
	    keep if distSCshare > natlSCshare
		reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], ///
		    cluster(i) 
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Dynamic TWFE, Higher-than-National-Average SC Population") ///
            xtitle("Years From Treatment")
		graph export "../output/final figures/twfe_stack_SC.png", height(450) width(600) replace
	restore 
end

program rural_urban
    use ../output/cohortdata, clear
	cap drop first_treat rel_time never_treat last_cohort gvar L* F* 
	drop if ac_year < 2011

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
	
	bysort ac_year: egen natlruralshare = mean(primaryage_rural / primaryage_all)
	bysort ac_year: egen natlurbanshare = mean(primaryage_urban / primaryage_all) 
	
	bysort statename distname ac_year: gen distruralshare = primaryage_rural / primaryage_all
	bysort statename distname ac_year: gen disturbanshare = primaryage_urban / primaryage_all 
	
	preserve 
	    tempfile temp
        collapse (sum) enrollment_rate schtot, by(statename distname ac_year dataset)
        save `temp'
	restore
	
	preserve 
	    keep if distruralshare > natlruralshare
		drop enrollment_rate 
		merge m:1 statename distname ac_year dataset using `temp', assert(1 2 3) keep(3) 
		duplicates drop statename distname ac_year dataset, force
	    reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], ///
		    cluster(i) 
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Districts with Higher-Than-National-Average Rural Population") ///
	        xtitle("Years From Treatment")
		graph export "../output/final figures/twfe_stack_rural.png", height(450) width(600) replace
   restore 
   
   preserve 
        keep if disturbanshare > natlurbanshare
		drop enrollment_rate 
		merge m:1 statename distname ac_year dataset using `temp', assert(1 2 3) keep(3) 
		duplicates drop statename distname ac_year dataset, force
	    reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i)
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Districts with Higher-Than-National-Average Urban Population") ///
	        xtitle("Years From Treatment")
		graph export "../output/final figures/twfe_stack_urban.png", height(450) width(600) replace
   restore 
end 


*Execute
main