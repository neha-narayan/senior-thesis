capture log close 
log using analysis.log, replace
clear all
set more off
set scheme s2color
set maxvar 25000

program main 
    plots
    stack_dataset
	stack_regression
	pooled_regression
end

program plots 
    use ../../../shared_data/pincode_enrollment_dise, clear
	collapse (sum) enrollment schtot (firstnm) statename reliable num_centers, by(pincode ac_year)
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	     statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	bysort pincode (reliable_index): replace reliable_index = reliable_index[1]
		
	centile reliable_index, centile(50)
	local median = `r(c_1)'
	centile reliable_index, centile(99)
	local upper = `r(c_1)'
	unique pincode if reliable_index > `upper'

	hist reliable_index, xline(`median') percent xtitle("Appearance/Enrollment Ratio")
	graph export "../output/reliability_distribution.png", height(450) width(600) replace 
end

program import_weights 
    import delimited using ../../../shared_data/ipw_weights_reliability.csv, varnames(1) clear
	drop v1
	rename ipw ipw_r 
	tostring pincode, replace
	save ../../../shared_data/ipw_weights_reliability, replace 
	
	import delimited using ../../../shared_data/ipw_weights_centers.csv, varnames(1) clear
	drop v1
	rename ipw ipw_c
	tostring pincode, replace
	save ../../../shared_data/ipw_weights_centers, replace 
end 

program stack_dataset
	use ../../../shared_data/pincode_enrollment_dise, clear
	bysort pincode: egen temp=mode(statename)
	replace statename = temp
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	bysort pincode (reliable_index): replace reliable_index = reliable_index[1]
	expand schtot
	export delimited using ../../../shared_data/pincode_ipw.csv, replace
	
	merge m:1 pincode using ../../../shared_data/ipw_weights_reliability, assert(1 2 3) keep(1 3) gen(merge_wr)
	merge m:1 pincode using ../../../shared_data/ipw_weights_centers, assert(1 2 3) keep(3) gen(merge_wc)
	
	merge m:1 statename using ../../../shared_data/shares_from_2011, assert(1 2 3) keep(3) gen(merge_pop)
	drop state
	
	bysort state ac_year: egen schtot_state = total(schtot)
	gen pop_per_school = primaryage_all / schtot_state
	gen pop_per_school_b = primaryage_males / schtot_state
	gen pop_per_school_g = primaryage_females / schtot_state
	gen pop_per_school_sc = primaryage_SC / schtot_state
	gen pop_per_school_st = primaryage_ST / schtot_state
	gen pincode_pop = pop_per_school * schtot
	gen pincode_pop_b = pop_per_school_b * schtot
	gen pincode_pop_g = pop_per_school_g * schtot
	gen pincode_pop_sc = pop_per_school_sc * schtot
	gen pincode_pop_st = pop_per_school_st * schtot
	gen enrollment_rate = enrollment/pincode_pop
	gen enrollment_rate_b = enrollment_b/pincode_pop_b
	gen enrollment_rate_g = enrollment_g/pincode_pop_g
	gen enrollment_rate_sc = scenrollment/pincode_pop_sc
	gen enrollment_rate_st = stenrollment/pincode_pop_st
	
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
	restore
	
	clear 
	append using `2015cohort'
	append using `2016cohort'
	append using `2017cohort'
	
	save ../output/cohortdata_pincode, replace
end 

program stack_regression
    use ../output/cohortdata_pincode, clear	
	drop if ac_year < 2011
	
	cap drop first_treat rel_time never_treat last_cohort gvar L* F* 

	encode(statename), gen(i)
	encode(pincode), gen(p)
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
	
	gen interact = 0 
	replace interact = 1 if ac_year >= 2017 & first_treat == 2017
	replace interact = 1 if ac_year >= 2016 & first_treat == 2016
	replace interact = 1 if ac_year >= 2015 & first_treat == 2015
	
	eststo all: reghdfe enrollment_rate L_* F_* [aw=schtot], absorb(p#dataset t#dataset) vce(cluster i)
	eststo girls: reghdfe enrollment_rate_g L_* F_* [aw=schtot], absorb(p#dataset t#dataset) vce(cluster i)
	eststo boys: reghdfe enrollment_rate_b L_* F_* [aw=schtot], absorb(p#dataset t#dataset) vce(cluster i)
	eststo sc: reghdfe enrollment_rate_sc c.t#i.i L_* F_* [aw=schtot], absorb(p#dataset t#dataset) vce(cluster i)
	eststo st: reghdfe enrollment_rate_st L_* F_* [aw=schtot], absorb(p#dataset t#dataset) vce(cluster i)

	coefplot all, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Stacked-Regression Estimates of ATT") ///
        xtitle("Years From Treatment") 
	graph export ../output/twfe_stack_pincode.png, height(450) width(600) replace
	coefplot girls, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Stacked-Regression Estimates of ATT, Girls") ///
        xtitle("Years From Treatment") 
	graph export ../output/twfe_stack_girls_pincode.png, height(450) width(600) replace
	coefplot boys, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Stacked-Regression Estimates of ATT, Boys") ///
        xtitle("Years From Treatment") 
	graph export ../output/twfe_stack_boys_pincode.png, height(450) width(600) replace
	coefplot sc, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Stacked-Regression Estimates of ATT, Caste-Marginalized") ///
        xtitle("Years From Treatment") 
	graph export ../output/twfe_stack_SC_pincode.png, height(450) width(600) replace
	coefplot st, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Stacked-Regression Estimates of ATT, Indigenous") ///
        xtitle("Years From Treatment") 
	graph export ../output/twfe_stack_ST_pincode.png, height(450) width(600) replace
	
	 coefplot highreliability lowreliability, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Stacked TWFE, More vs. Less Reliable Pincodes") ///
            xtitle("Years From Treatment") ///
			legend(order(1 "More Reliable" 3 "Less Reliable"))
	graph export ../output/erroranalysis.png, height(450) width(600) replace 
	
	gen private_ind = schtot - govt_ind
	gen urban_schools = schtot - rural_schools
		
	preserve 
	    keep if reliable_index <= 1 
        reghdfe enrollment_rate L_*##c.reliable_index F_*##c.reliable_index [aw=schtot], ///
            absorb(p#dataset t#dataset) vce(cluster i)
	restore
	
	reghdfe enrollment_rate L_*##c.num_centers F_*##c.num_centers [aw=schtot], ///
		    absorb(p#dataset t#dataset) vce(cluster i)
	
	reghdfe enrollment_rate L_*##c.govt_ind F_*##c.govt_ind [aw=schtot], ///
		    absorb(p#dataset t#dataset) vce(cluster i)
	reghdfe enrollment_rate L_*##c.private_ind F_*##c.private_ind [aw=schtot], ///
		    absorb(p#dataset t#dataset) vce(cluster i)
			
	reghdfe enrollment_rate L_*##c.rural_schools F_*##c.rural_schools [aw=schtot], ///
		absorb(p#dataset t#dataset) vce(cluster i)
	reghdfe enrollment_rate L_*##c.urban_schools F_*##c.urban_schools [aw=schtot], ///
        absorb(p#dataset t#dataset) vce(cluster i)
	
  
end

program pooled_regression
    use ../output/cohortdata_pincode, clear	
	drop if ac_year < 2011
	
	cap drop first_treat rel_time never_treat last_cohort gvar L* F* 
	encode(statename), gen(i)
	tostring pincode, replace
	encode(pincode), gen(p)
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
	

	
	
    reghdfe enrollment_rate interact##c.num_centers, absorb(p#dataset t#dataset) vce(cluster i)
end 

*Execute
main










