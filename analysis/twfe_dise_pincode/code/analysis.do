capture log close 
log using analysis.log, replace
clear all
set more off
set scheme s2color

program main 
    stack_dataset
	stack_regression
end

program uidai
end 

program stack_dataset
	use ../../../shared_data/pincode_enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 

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
	
	eststo all: reghdfe enrollment L_* F_* [aw=schtot], absorb(p##dataset t##dataset) vce(cluster i)
	eststo girls: reghdfe enrollment_g L_* F_* [aw=schtot], absorb(p##dataset t##dataset) vce(cluster i)
	 coefplot all girls, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Dynamic TWFE at Pincode Level") ///
            xtitle("Years From Treatment") 
end



*Execute
main