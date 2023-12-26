capture log close 
log using analysis.log, replace
clear all
set more off
set scheme s2color

set maxvar 32767

program main 
    plots
// 	dynamic_twfe
// 	cohort_twfe
//     stacking
	triplediff
//     rural_urban
end

program plots
    use ../../../shared_data/enrollment_dise, clear
	collapse (sum) enrollment enrollment_rate schtot govt_ind ///
	    (firstnm) primaryage_* reliable, by(statename distname ac_year)
	//drop states with uncertainty in treatment timing
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	drop if ac_year < 2009
		
	centile reliable_index, centile(50)
	
	hist reliable_index, xline(`r(c_1)') percent xtitle("Appearance/Enrollment Ratio")
	graph export "../output/final figures/reliability_distribution.png", height(450) width(600) replace 
end 

program dynamic_twfe
	use ../../../shared_data/enrollment_dise, clear
	collapse (sum) enrollment enrollment_rate schtot govt_ind ///
	    (firstnm) primaryage_* reliable, by(statename distname ac_year)
	//drop states with uncertainty in treatment timing + bad parallel trends 
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
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
	
	gen enrollment_rate = enrollment/primaryage_all
	reg enrollment_rate primaryage_rural L_* F_* i.i##t i.t##border i.i##border [aw=schtot], cluster(i)
	
// 	wildbootstrap reg enrollment_rate L_* F_* i.i i.t [weight=schtot], cluster(i) rseed(1960)
	
    coefplot, omitted keep(L* F*) vertical ///
	        order(F_8 F_7 F_6 F_5 F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4 L_5 L_6) ///
	        title("Dynamic TWFE") ///
            xtitle("Years From Treatment") 
	 graph export ../output/twfe_full, height(450) width(600) replace 	
end  


program cohort_twfe
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	collapse (sum) enrollment enrollment_rate schtot govt_ind ///
	    (firstnm) primaryage_* reliable, by(statename distname ac_year)

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
    use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	collapse (sum) enrollment_rateg enrollment_rateb enrollment_rate enrollment_rateSC ///
	    enrollment_rateST schtot govt_ind (firstnm) primaryage* reliable_index, ///
		by(statename distname ac_year)
		
	bysort ac_year: egen natlSTshare = mean(primaryage_ST / primaryage_all)
	sum natlSTshare, de
	bysort ac_year: egen natlSCshare = mean(primaryage_SC / primaryage_all)
	sum natlSCshare, de
	
    use ../output/cohortdata, clear
	bysort statename distname (reliable_index): replace reliable_index = reliable_index[1]
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
	
	gen interact = 0 
	replace interact = 1 if ac_year >= 2017 & first_treat == 2017 
	replace interact = 1 if ac_year >= 2016 & first_treat == 2016
	replace interact = 1 if ac_year >= 2015 & first_treat == 2015
		
	reghdfe enrollment_rate interact [aw=schtot], ///
		    absorb(d#dataset t#dataset) vce(cluster i)
	
	preserve 
	    use ../../../shared_data/enrollment_dise, clear
	    collapse reliable_index, by(statename distname ac_year)
	    drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
		    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
		centile reliable_index, centile(50)
	restore 
	
	reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i) 
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Dynamic TWFE, All Students") ///
        xtitle("Years From Treatment") ///
		ytitle("Change in Enrollment Rate")
    graph export "../output/final figures/twfe_stack.png", height(450) width(600) replace 
	
	reg enrollment_rateg L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i) 
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Dynamic TWFE, Girls") ///
        xtitle("Years From Treatment") ///
		ytitle("Change in Enrollment Rate")
    graph export "../output/final figures/twfe_stack_girls.png", height(450) width(600) replace 
	
	reg enrollment_rateb L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i) 
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Dynamic TWFE, Boys") ///
        xtitle("Years From Treatment") ///
		ytitle("Change in Enrollment Rate")
    graph export "../output/final figures/twfe_stack_boys.png", height(450) width(600) replace 


// 	centile reliable_index if ac_year == 2011, centile(50)
// 	la var reliable_index "Reliability Index"
// 	hist reliable_index if ac_year == 2011, xline(`r(c_1)', lcolor(red))
// 	graph export ../output/reliabilitydist.png, width(600) height(450) replace
//	
	reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
	    reliable_scale == "Most Reliable", cluster(i)
	estimates store mostreliable
	reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot] if ///
	    reliable_scale == "Least Reliable", cluster(i)
	estimates store leastreliable
    coefplot mostreliable leastreliable, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Stacked TWFE, Most vs. Least Reliable Districts") ///
            xtitle("Years From Treatment") ///
			legend(order(1 "Most Reliable" 3 "Least Reliable"))
	graph export ../output/erroranalysis/twfe_stack_mostvsleast.png, height(450) width(600) replace

	 preserve
        bysort statename distname ac_year dataset: gen distSTshare = primaryage_ST/primaryage_all
	    keep if distSTshare > .1434088  
	    reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], cluster(i)
		 coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Dynamic TWFE, Higher-than-National-Average ST Population") ///
            xtitle("Years From Treatment")
         graph export "../output/final figures/twfe_stack_ST.png", height(450) width(600) replace 
	restore 
	
	preserve 
	    bysort statename distname ac_year dataset: gen distSCshare = primaryage_SC/primaryage_all
	    keep if distSCshare > .1562831
		reg enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], ///
		    cluster(i) 
		coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Dynamic TWFE, Higher-than-National-Average SC Population") ///
            xtitle("Years From Treatment")
		graph export "../output/final figures/twfe_stack_SC.png", height(450) width(600) replace
	restore 
end



program cohort_tdr
	use ../../../shared_data/enrollment_dise, clear
	drop if statename == "CHHATTISGARH" | statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | ///
	    statename == "TAMIL NADU" | statename == "PUDUCHERRY" | statename == "UTTARAKHAND" 
	collapse (sum) enrollment schtot (firstnm) primaryage*, ///
		by(statename distname ac_year)
	drop if ac_year < 2011

	//2015 cohort
	preserve 	
	    gen border = 0
	replace border = 1 if distname == "TINSUKIA" | distname == "DIBRUGARH" | distname == "SIVASAGAR" | ///
	    distname == "JORHAT" | distname == "GOLAGHAT" | distname == "WEST KARBI ANGLONG" | ///
		distname == "DIMA HASAO" | distname == "CACHAR" | distname == "HAILAKANDI" | ///
		distname == "KARIMGANJ" | distname == "DHEMAJI" | distname == "LAKHIMPUR" | ///
		distname == "SONITPUR" | distname == "DARRANG" | distname == "WEST KAMENG" | ///
		distname == "EAST KAMENG" | distname == "PAPUM PARE" | distname == "LOWER SUBANSIRI" | ///
		distname == "EAST SIANG" | distname == "LOWER DIBANG VALLEY" | distname == "LOHIT" | ///
		distname == "CHANGLANG" | distname == "TIRAP" | distname == "PEREN" | distname == "DIMAPUR" | ///
		distname == "WOKHA" | distname == "MOKOCHUNG" | distname == "LONGLENG" | distname == "MON" | ///
		distname == "CHURACHANDPUR" | distname == "TAMENGLONG" | distname == "IMPHAL EAST" | ///
		distname == "NORTH TRIPURA" | distname == "KATHUA" | distname == "DODA" | distname == "KARGIL" | ///
		distname == "LEH (LADAKH)" | distname == "GURDASPUR" | distname == "KASARAGOD" | ///
		distname == "KANNUR" | distname == "WAYANAD" | distname == "PALAKKAD" | distname == "THRISSUR" | ///
		distname == "IDUKKI" | distname == "PATHANAMTHITTA" | distname == "KOLLAM" | ///
		distname == "THIRUVANANTHAPURAM" | distname == "MYSURU" | distname == "KODAGU" | ///
		distname == "DAKSHINA KANNADA" | distname == "CHAMARAJNAGARA" | distname == "THANE" | ///
		distname == "NASHIK" | distname == "DHULE" | distname == "NANDURBAR" | distname == "JALGAON" | ///
		distname == "BULDANA" | distname == "AMRAVATI" | distname == "NAGPUR" | distname == "BHANDARA" | ///
		distname == "GADCHIROLI" | distname == "GONDIYA" | distname == "CHANDRAPUR" | distname == "YAVATMAL" | ///
		distname == "NADED" | distname == "OSMANABAD" | distname == "SOLAPUR" | distname == "SANGLI" | ///
		distname == "KOLHAPUR" | distname == "SINDHUDURG" | distname == "NORTH GOA" | ///
		distname == "BIDAR" | distname == "KALABURGI" | distname == "BELGAVI" | distname == "NIZAMABAD" | ///
		distname == "ADILABAD" | distname == "JHABUA" | distname == "BARWANI" | distname == "KHARGONE" | ///
		distname == "BURHANPUR" | distname == "KHANDWA" | distname == "BETUL" | distname == "CHHINDWARA" | ///
		distname == "SEONI" | distname == "BALAGHAT" | distname == "DADRA & NAGAR HAVELI" | ///
		distname == "VALSAD" | distname == "NAVSARI" | distname == "THE DANGS" | distname == "SURAT" | ///
		distname == "NARMADA" | distname == "VADODARA" | distname == "KOCH BIHAR" | distname == "JALPAIGURI" | ///
		distname == "KALIMPONG" | distname == "DARJEELING" | distname == "SILIGURI" | distname == "UTTAR DINAJPUR" | ///
		distname == "MALDAH" | distname == "MURSHIDABAD" | distname == "BIRBHUM" | distname == "BARDHAMAN" | ///
		distname == "PURULIYA" | distname == "PASCHIM MEDINIPUR" | distname == "PURBA MEDINIPUR" | ///
		distname == "MAYURBHANJ" | distname == "BALESHWAR" | distname == "SAHIBGANJ" | distname == "PAKAUR" | ///
		distname == "JAMTARA" | distname == "DHANBAD" | distname == "BOKARA" | distname == "RAMGARH" | ///
		distname == "RANCHI" | distname == "SARAIKELA-KHARSAWAN" | distname == "PURBI SINGHBHUM" | ///
		distname == "KISHANGANJ" | distname == "PURNIA" | distname == "KATIHAR" | ///
		distname == "EAST SIKKIM" | distname == "WEST SIKKIM" | distname == "SOUTH SIKKIM"
		
	collapse (sum) enrollment primaryage_all primaryage_rural schtot, by(statename border ac_year)

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
	
	gen border = 0
	replace border = 1 if distname == "TINSUKIA" | distname == "DIBRUGARH" | distname == "SIVASAGAR" | ///
	    distname == "JORHAT" | distname == "GOLAGHAT" | distname == "WEST KARBI ANGLONG" | ///
		distname == "DIMA HASAO" | distname == "CACHAR" | distname == "HAILAKANDI" | ///
		distname == "KARIMGANJ" | distname == "DHEMAJI" | distname == "LAKHIMPUR" | ///
		distname == "SONITPUR" | distname == "DARRANG" | distname == "WEST KAMENG" | ///
		distname == "EAST KAMENG" | distname == "PAPUM PARE" | distname == "LOWER SUBANSIRI" | ///
		distname == "EAST SIANG" | distname == "LOWER DIBANG VALLEY" | distname == "LOHIT" | ///
		distname == "CHANGLANG" | distname == "TIRAP" | distname == "PEREN" | distname == "DIMAPUR" | ///
		distname == "WOKHA" | distname == "MOKOCHUNG" | distname == "LONGLENG" | distname == "MON" | ///
		distname == "CHURACHANDPUR" | distname == "TAMENGLONG" | distname == "IMPHAL EAST" | ///
		distname == "NORTH TRIPURA" | distname == "KATHUA" | distname == "DODA" | distname == "KARGIL" | ///
		distname == "LEH (LADAKH)" | distname == "GURDASPUR" | distname == "KASARAGOD" | ///
		distname == "KANNUR" | distname == "WAYANAD" | distname == "PALAKKAD" | distname == "THRISSUR" | ///
		distname == "IDUKKI" | distname == "PATHANAMTHITTA" | distname == "KOLLAM" | ///
		distname == "THIRUVANANTHAPURAM" | distname == "MYSURU" | distname == "KODAGU" | ///
		distname == "DAKSHINA KANNADA" | distname == "CHAMARAJNAGARA" | distname == "THANE" | ///
		distname == "NASHIK" | distname == "DHULE" | distname == "NANDURBAR" | distname == "JALGAON" | ///
		distname == "BULDANA" | distname == "AMRAVATI" | distname == "NAGPUR" | distname == "BHANDARA" | ///
		distname == "GADCHIROLI" | distname == "GONDIYA" | distname == "CHANDRAPUR" | distname == "YAVATMAL" | ///
		distname == "NADED" | distname == "OSMANABAD" | distname == "SOLAPUR" | distname == "SANGLI" | ///
		distname == "KOLHAPUR" | distname == "SINDHUDURG" | distname == "NORTH GOA" | ///
		distname == "BIDAR" | distname == "KALABURGI" | distname == "BELGAVI" | distname == "NIZAMABAD" | ///
		distname == "ADILABAD" | distname == "JHABUA" | distname == "BARWANI" | distname == "KHARGONE" | ///
		distname == "BURHANPUR" | distname == "KHANDWA" | distname == "BETUL" | distname == "CHHINDWARA" | ///
		distname == "SEONI" | distname == "BALAGHAT" | distname == "DADRA & NAGAR HAVELI" | ///
		distname == "VALSAD" | distname == "NAVSARI" | distname == "THE DANGS" | distname == "SURAT" | ///
		distname == "NARMADA" | distname == "VADODARA" | distname == "KOCH BIHAR" | distname == "JALPAIGURI" | ///
		distname == "KALIMPONG" | distname == "DARJEELING" | distname == "SILIGURI" | distname == "UTTAR DINAJPUR" | ///
		distname == "MALDAH" | distname == "MURSHIDABAD" | distname == "BIRBHUM" | distname == "BARDHAMAN" | ///
		distname == "PURULIYA" | distname == "PASCHIM MEDINIPUR" | distname == "PURBA MEDINIPUR" | ///
		distname == "MAYURBHANJ" | distname == "BALESHWAR" | distname == "SAHIBGANJ" | distname == "PAKAUR" | ///
		distname == "JAMTARA" | distname == "DHANBAD" | distname == "BOKARA" | distname == "RAMGARH" | ///
		distname == "RANCHI" | distname == "SARAIKELA-KHARSAWAN" | distname == "PURBI SINGHBHUM" | ///
		distname == "KISHANGANJ" | distname == "PURNIA" | distname == "KATIHAR" | ///
		distname == "EAST SIKKIM" | distname == "WEST SIKKIM" | distname == "SOUTH SIKKIM"
		
	collapse (sum) enrollment primaryage_all primaryage_rural schtot, by(statename border ac_year)
	
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
	
	gen border = 0
	replace border = 1 if distname == "TINSUKIA" | distname == "DIBRUGARH" | distname == "SIVASAGAR" | ///
	    distname == "JORHAT" | distname == "GOLAGHAT" | distname == "WEST KARBI ANGLONG" | ///
		distname == "DIMA HASAO" | distname == "CACHAR" | distname == "HAILAKANDI" | ///
		distname == "KARIMGANJ" | distname == "DHEMAJI" | distname == "LAKHIMPUR" | ///
		distname == "SONITPUR" | distname == "DARRANG" | distname == "WEST KAMENG" | ///
		distname == "EAST KAMENG" | distname == "PAPUM PARE" | distname == "LOWER SUBANSIRI" | ///
		distname == "EAST SIANG" | distname == "LOWER DIBANG VALLEY" | distname == "LOHIT" | ///
		distname == "CHANGLANG" | distname == "TIRAP" | distname == "PEREN" | distname == "DIMAPUR" | ///
		distname == "WOKHA" | distname == "MOKOCHUNG" | distname == "LONGLENG" | distname == "MON" | ///
		distname == "CHURACHANDPUR" | distname == "TAMENGLONG" | distname == "IMPHAL EAST" | ///
		distname == "NORTH TRIPURA" | distname == "KATHUA" | distname == "DODA" | distname == "KARGIL" | ///
		distname == "LEH (LADAKH)" | distname == "GURDASPUR" | distname == "KASARAGOD" | ///
		distname == "KANNUR" | distname == "WAYANAD" | distname == "PALAKKAD" | distname == "THRISSUR" | ///
		distname == "IDUKKI" | distname == "PATHANAMTHITTA" | distname == "KOLLAM" | ///
		distname == "THIRUVANANTHAPURAM" | distname == "MYSURU" | distname == "KODAGU" | ///
		distname == "DAKSHINA KANNADA" | distname == "CHAMARAJNAGARA" | distname == "THANE" | ///
		distname == "NASHIK" | distname == "DHULE" | distname == "NANDURBAR" | distname == "JALGAON" | ///
		distname == "BULDANA" | distname == "AMRAVATI" | distname == "NAGPUR" | distname == "BHANDARA" | ///
		distname == "GADCHIROLI" | distname == "GONDIYA" | distname == "CHANDRAPUR" | distname == "YAVATMAL" | ///
		distname == "NADED" | distname == "OSMANABAD" | distname == "SOLAPUR" | distname == "SANGLI" | ///
		distname == "KOLHAPUR" | distname == "SINDHUDURG" | distname == "NORTH GOA" | ///
		distname == "BIDAR" | distname == "KALABURGI" | distname == "BELGAVI" | distname == "NIZAMABAD" | ///
		distname == "ADILABAD" | distname == "JHABUA" | distname == "BARWANI" | distname == "KHARGONE" | ///
		distname == "BURHANPUR" | distname == "KHANDWA" | distname == "BETUL" | distname == "CHHINDWARA" | ///
		distname == "SEONI" | distname == "BALAGHAT" | distname == "DADRA & NAGAR HAVELI" | ///
		distname == "VALSAD" | distname == "NAVSARI" | distname == "THE DANGS" | distname == "SURAT" | ///
		distname == "NARMADA" | distname == "VADODARA" | distname == "KOCH BIHAR" | distname == "JALPAIGURI" | ///
		distname == "KALIMPONG" | distname == "DARJEELING" | distname == "SILIGURI" | distname == "UTTAR DINAJPUR" | ///
		distname == "MALDAH" | distname == "MURSHIDABAD" | distname == "BIRBHUM" | distname == "BARDHAMAN" | ///
		distname == "PURULIYA" | distname == "PASCHIM MEDINIPUR" | distname == "PURBA MEDINIPUR" | ///
		distname == "MAYURBHANJ" | distname == "BALESHWAR" | distname == "SAHIBGANJ" | distname == "PAKAUR" | ///
		distname == "JAMTARA" | distname == "DHANBAD" | distname == "BOKARA" | distname == "RAMGARH" | ///
		distname == "RANCHI" | distname == "SARAIKELA-KHARSAWAN" | distname == "PURBI SINGHBHUM" | ///
		distname == "KISHANGANJ" | distname == "PURNIA" | distname == "KATIHAR" | ///
		distname == "EAST SIKKIM" | distname == "WEST SIKKIM" | distname == "SOUTH SIKKIM"
		
	collapse (sum) enrollment primaryage_all primaryage_rural schtot, by(statename border ac_year)
	
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
	
	save ../output/cohortdata_TDR, replace
end 


program triplediff
    use ../output/cohortdata_TDR, clear
	gen enrollment_rate = enrollment / primaryage_all

	cap drop first_treat rel_time never_treat last_cohort gvar L* F* 

	encode(statename), gen(i)
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
		
	reg enrollment_rate L_* F_* primaryage_rural i.i##t##dataset i.t##border##dataset i.i##border##dataset [aw=schtot], ///
	    cluster(i)
	coefplot, omitted keep(L* F*) vertical ///
	    order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	    title("Triple Difference") ///
        xtitle("Years From Treatment") ///
		ytitle("Change in Enrollment Rate")
	
	

	
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
	
	
		
	preserve 
	    bysort distname statename ac_year: egen test = nvals(rural_ind)
		keep if test == 1 
		keep if rural_ind == 1 
	    reg rural_enrollment_rate L_* F_* i.district_x_data i.year_x_data [weight=schtot], ///
		    cluster(i) 
		coefplot, omitted keep(L* F*) vertical ///
	        order(F_4 F_3 F_2 F_1 L_0 L_1 L_2 L_3 L_4) ///
	        title("Districts with Higher-Than-National-Average Rural Population") ///
	        xtitle("Years From Treatment")
		graph export "../output/final figures/twfe_stack_rural.png", height(450) width(600) replace
   restore 
   
   preserve 
        bysort distname statename ac_year: egen test = nvals(rural_ind)
		keep if test == 1 
        keep if rural_ind == 0 
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