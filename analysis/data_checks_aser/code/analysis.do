capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    enroll_plots
	identify_error
	NSS_comparison
end

program enroll_plots 
	use ../../../shared_data/enrollment_dise, clear
	collapse (sum) enrollment_rate, by(distname statename ac_year)
	//drop states which have unknown treatment timings or aren't in the scope of the data
	drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM" | ///
	    state == "TAMIL NADU"
	//drop states not in the ASER data to ensure balanced groups
	drop if state != "ANDHRA PRADESH" & state != "ASSAM" & state != "BIHAR" & state != "GUJARAT" & ///
	    state != "HARYANA" & state != "JHARKHAND" & state != "KARNATAKA" & state != "KERALA" & ///
		state != "MADHYA PRADESH" & state != "MAHARASHTRA" & state != "MANIPUR" & state != "MEGHALAYA" & ///
		state != "NAGALAND" & state != "ODISHA" & state != "PUNJAB" & state != "RAJASTHAN" & ///
		state != "SIKKIM" & state != "TRIPURA" & state != "UTTAR PRADESH" & state != "WEST BENGAL"
		
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
	replace first_treat = 0 if mi(first_treat)
	collapse enrollment_rate, by(first_treat ac_year)
	rename enrollment_rate dise_enrollment_rate
	save ../temp/dise, replace
	
	use ../../../shared_data/cross_section_mean, clear
	drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM" | ///
	    state == "TAMIL NADU" 
	//drop states not in the ASER data to ensure balanced groups
	drop if state != "ANDHRA PRADESH" & state != "ASSAM" & state != "BIHAR" & state != "GUJARAT" & ///
	    state != "HARYANA" & state != "JHARKHAND" & state != "KARNATAKA" & state != "KERALA" & ///
		state != "MADHYA PRADESH" & state != "MAHARASHTRA" & state != "MANIPUR" & state != "MEGHALAYA" & ///
		state != "NAGALAND" & state != "ODISHA" & state != "PUNJAB" & state != "RAJASTHAN" & ///
		state != "SIKKIM" & state != "TRIPURA" & state != "UTTAR PRADESH" & state != "WEST BENGAL"
		
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
	replace first_treat = 0 if mi(first_treat)
	collapse enrolled_ind, by(first_treat year)
	rename (enrolled_ind year) (aser_enrollment_rate ac_year)
	merge 1:1 ac_year first_treat using ../temp/dise, assert(1 2 3) keep(1 2 3) 
		
	preserve
		gen group = 1
		replace group = 0 if first_treat == 0 
		collapse aser_enrollment_rate dise_enrollment_rate, by(group ac_year)

		bysort group ac_year: gen delta = dise_enrollment_rate - aser_enrollment_rate
		sort group ac_year 
		twoway (scatter delta ac_year if group == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
		(scatter delta ac_year if group == 1, connect(direct) cmissing(n)) ///
		, legend(order(1 "Delta(Control)" 2 "Delta(Treatment)")) ///
		ytitle("Enrollment Rate") ///
		title("Enrollment Rate Over Time, By Treatment Group")
		graph export ../output/treat_vs_control.png, width(600) height(450) replace 
	restore 
	
	bysort first_treat ac_year: gen delta = aser_enrollment_rate - dise_enrollment_rate
	sort first_treat ac_year 
	twoway (scatter delta ac_year if first_treat == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
    (scatter delta ac_year if first_treat == 2015, connect(direct) cmissing(n) xline(2015, lcolor(maroon))) ///
	(scatter delta ac_year if first_treat == 2016, connect(direct) cmissing(n) xline(2016, lcolor(green))) ///
	(scatter delta ac_year if first_treat == 2017, connect(direct) cmissing(n) xline(2017, lcolor(orange))) ///
    , legend(order(1 "Delta(Control)" 2 "Delta(2015 Cohort)" 3 "Delta(2016 Cohort)" 4 "Delta(2017 Cohort)")) ///
    ytitle("Enrollment Rate") ///
    title("Enrollment Rate Over Time, By Treatment Group")
	graph export ../output/cohorts_vs_control.png, width(600) height(450) replace 
	
	
	bysort first_treat ac_year: gen delta = dise_enrollment_rate - aser_enrollment_rate
	sort first_treat ac_year 
	sort first_treat ac_year
    twoway (scatter aser_enrollment_rate1 ac_year if first_treat == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
    (scatter aser_enrollment_rate1 ac_year if first_treat == 2016, connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 0,  connect(l) xlabel(2005(1)2020)) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 2016, connect(l) xline(2016, lcolor(gray))), ///
    legend(order(1 "ASER (open) Control" 2 "ASER (open) 2016 Cohort" 3 "DISE Control" 4 "DISE 2016 Cohort")) ///
    ytitle("Enrollment Rate") ///
    title("Enrollment Rate Over Time, By Treatment Group")
	
	sort first_treat ac_year
    twoway (scatter aser_enrollment_rate1 ac_year if first_treat == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
    (scatter aser_enrollment_rate1 ac_year if first_treat == 2017, connect(direct) cmissing(n) xline(2017, lcolor(gray))) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 0,  connect(l) xlabel(2005(1)2020)) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 2017, connect(l) xline(2017, lcolor(gray))), ///
    legend(order(1 "ASER (open) Control" 2 "ASER (open) 2017 Cohort" 3 "DISE Control" 4 "DISE 2017 Cohort")) ///
    ytitle("Enrollment Rate") ///
    title("Enrollment Rate Over Time, By Treatment Group")
	
    twoway (scatter aser_enrollment_rate2 ac_year if first_treat == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
    (scatter aser_enrollment_rate2 ac_year if first_treat == 2017, connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 0,  connect(l) xlabel(2005(1)2020)) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 2017, connect(l) xline(2016, lcolor(gray))), ///
    legend(order(1 "ASER (restrict) Control" 2 "ASER (restrict) 2017 Cohort" 3 "DISE Control" 4 "DISE 2017 Cohort")) ///
    ytitle("Enrollment Rate") ///
    title("Enrollment Rate Over Time, By Treatment Group")
	
	twoway (scatter aser_enrollment_rate3 ac_year if first_treat == 0, connect(direct) cmissing(n) xlabel(2007(1)2020)) ///
    (scatter aser_enrollment_rate3 ac_year if first_treat == 2017, connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 0,  connect(l) xlabel(2005(1)2020)) ///
    (scatter dise_enrollment_rate ac_year if first_treat == 2017, connect(l) xline(2016, lcolor(gray))), ///
    legend(order(1 "ASER (most restrict) Control" 2 "ASER (most restrict) 2016 Cohort" 3 "DISE Control" 4 "DISE 2016 Cohort")) ///
    ytitle("Enrollment Rate") ///
    title("Enrollment Rate Over Time, By Treatment Group")

	
	graph export using ../output/enrollmentplot.png, height(450) width(600) replace
	
	use ../../../shared_data/cross_section_boys_mean, clear
	
	gen treatment_time = .
	replace treatment_time = 2013 if state == "HIMACHAL PRADESH" 
	replace treatment_time = 2015 if state == "ANDHRA PRADESH" | state == "HARYANA"
	replace treatment_time = 2016 if  state == "MANIPUR" | state == "JHARKHAND" 
    replace treatment_time = 2017 if (state == "ARUNACHAL PRADESH" | state == "BIHAR" | ///
	    state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
        state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
        state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
        state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
        state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace treatment_time = 0 if mi(treatment_time)
	collapse enrolled_ind, by(treatment_time year)
	
	input
	2017 0 . 
	2015 0 . 
	2017 2013 . 
	2015 2013 .
	2017 2015 . 
	2015 2015 .
	2017 2016 . 
	2015 2016 .
	2017 2017 . 
	2015 2017 .
	end
	
	twoway 
	
	twoway (scatter enrolled_ind year if treatment_time == 0, connect(direct) cmissing(n) xlabel(2005(1)2020)) ///
	    (scatter enrolled_ind year if treatment_time == 2013, ///
		connect(direct) cmissing(n) xline(2013, lcolor(gray)) ytitle("Enrollment Rate")) ///
		(scatter enrolled_ind year if treatment_time == 2015, ///
		connect(direct) cmissing(n) xline(2015, lcolor(gray)) ///
		title("Boys' Enrollment Rate Over Time, By Treatment Group")) ///
	    (scatter enrolled_ind year if treatment_time == 2016, ///
		connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
		(scatter enrolled_ind year if treatment_time == 2017, ///
		connect(direct) cmissing(n) xline(2017, lcolor(gray))), ///
 	    legend(order(1 "Control" 2 "Treatment Time = 2013"  3 "Treatment Time = 2015" ///
		    4 "Treatment Time = 2016" 5 "Treatment Time = 2016"))
			
	graph export using ../output/enrollmentplot_boys.png, height(450) width(600) replace

	use ../../../shared_data/cross_section_girls_mean, clear
		
	gen treatment_time = .
	replace treatment_time = 2013 if state == "HIMACHAL PRADESH" 
	replace treatment_time = 2015 if state == "ANDHRA PRADESH" | state == "HARYANA"
	replace treatment_time = 2016 if  state == "MANIPUR" | state == "JHARKHAND" 
    replace treatment_time = 2017 if (state == "ARUNACHAL PRADESH" | state == "BIHAR" | ///
	    state == "CHANDIGARH" | state == "CHHATTISGARH" | ///
        state == "DNH AND DD" | state == "GOA" | state == "GUJARAT" | state == "KARNATAKA" | ///
        state == "LAKSHADWEEP" | state == "MIZORAM" | state == "NAGALAND" | state == "ODISHA" | ///
        state == "PUNJAB" | state == "RAJASTHAN" | state == "SIKKIM" | state == "TRIPURA" | ///
        state == "UTTAR PRADESH" | state == "MADHYA PRADESH")
	replace treatment_time = 0 if mi(treatment_time)
	collapse enrolled_ind, by(treatment_time year)
	
	
	input
	2017 0 . 
	2015 0 . 
	2017 2013 . 
	2015 2013 .
	2017 2015 . 
	2015 2015 .
	2017 2016 . 
	2015 2016 .
	2017 2017 . 
	2015 2017 .
	end
	
	twoway (scatter enrolled_ind year if treatment_time == 0, connect(direct) cmissing(n) xlabel(2005(1)2020)) ///
	    (scatter enrolled_ind year if treatment_time == 2013, ///
		connect(direct) cmissing(n) xline(2013, lcolor(gray)) ytitle("Enrollment Rate")) ///
		(scatter enrolled_ind year if treatment_time == 2015, ///
		connect(direct) cmissing(n) xline(2015, lcolor(gray)) ///
		title("Girls' Enrollment Rate Over Time, By Treatment Group")) ///
	    (scatter enrolled_ind year if treatment_time == 2016, ///
		connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
		(scatter enrolled_ind year if treatment_time == 2017, ///
		connect(direct) cmissing(n) xline(2017, lcolor(gray))), ///
 	    legend(order(1 "Control" 2 "Treatment Time = 2013"  3 "Treatment Time = 2015" ///
		    4 "Treatment Time = 2016" 5 "Treatment Time = 2016"))
	
	graph export using ../output/enrollmentplot_girls.png, height(450) width(600) replace
end 

program identify_error
    use ../../../shared_data/enrollment_dise, clear
	collapse (sum) enrollment_rate, by(statename distname ac_year)
	//drop states which have unknown treatment timings or aren't in the scope of the data
	drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM" | ///
	    state == "TAMIL NADU"
	//drop states not in the ASER data to ensure balanced groups
	drop if state != "ANDHRA PRADESH" & state != "ASSAM" & state != "BIHAR" & state != "GUJARAT" & ///
	    state != "HARYANA" & state != "JHARKHAND" & state != "KARNATAKA" & state != "KERALA" & ///
		state != "MADHYA PRADESH" & state != "MAHARASHTRA" & state != "MANIPUR" & state != "MEGHALAYA" & ///
		state != "NAGALAND" & state != "ODISHA" & state != "PUNJAB" & state != "RAJASTHAN" & ///
		state != "SIKKIM" & state != "TRIPURA" & state != "UTTAR PRADESH" & state != "WEST BENGAL"
	rename enrollment_rate dise_enrollment_rate
	drop if ac_year == 2015 | ac_year == 2017 | ac_year > 2018
	save ../temp/dise, replace
	
	use ../../../shared_data/cross_section_mean, clear
	drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM" | ///
	    state == "TAMIL NADU" 
	//drop states not in the ASER data to ensure balanced groups
	drop if state != "ANDHRA PRADESH" & state != "ASSAM" & state != "BIHAR" & state != "GUJARAT" & ///
	    state != "HARYANA" & state != "JHARKHAND" & state != "KARNATAKA" & state != "KERALA" & ///
		state != "MADHYA PRADESH" & state != "MAHARASHTRA" & state != "MANIPUR" & state != "MEGHALAYA" & ///
		state != "NAGALAND" & state != "ODISHA" & state != "PUNJAB" & state != "RAJASTHAN" & ///
		state != "SIKKIM" & state != "TRIPURA" & state != "UTTAR PRADESH" & state != "WEST BENGAL"

	rename (enrolled_ind year state district_name) (aser_enrollment_rate ac_year statename distname)
	drop if ac_year < 2009
	merge 1:1 ac_year distname statename using ../temp/dise, assert(1 2 3) keep(3) nogen
	drop if ac_year < 2011 | ac_year > 2018
	
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

	bysort distname ac_year: gen delta = aser_enrollment_rate - dise_enrollment_rate

	//2015 cohort
	preserve 		
		tempfile 2015cohort 
		keep if first_treat == 2015 | mi(first_treat)
		gen dataset = 2015
		save `2015cohort'
	restore 
	
	preserve 		
		tempfile 2016cohort 
		keep if first_treat == 2016 | mi(first_treat)
		gen dataset = 2016
		save `2016cohort'
	restore 
	
	preserve 		
		tempfile 2017cohort 
		keep if first_treat == 2017 | mi(first_treat)
		gen dataset = 2017
		save `2017cohort'
	restore 
	
	clear 
	append using `2015cohort'
	append using `2016cohort'
	append using `2017cohort'

	save ../output/cohortdata, replace
	
	drop first_treat

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
	
    gen district_x_data = d*dataset
	gen year_x_data = t*dataset
	
	reg delta L_* F_* i.district_x_data i.year_x_data, cluster(i) 
end 

program test 
    use ../../../shared_data/cross_section_mean, clear
	drop if state == "CHHATTISGARH" | state == "HIMACHAL PRADESH" | state == "MIZORAM" | ///
	    state == "TAMIL NADU" 
	//drop states not in the ASER data to ensure balanced groups
	drop if state != "ANDHRA PRADESH" & state != "ASSAM" & state != "BIHAR" & state != "GUJARAT" & ///
	    state != "HARYANA" & state != "JHARKHAND" & state != "KARNATAKA" & state != "KERALA" & ///
		state != "MADHYA PRADESH" & state != "MAHARASHTRA" & state != "MANIPUR" & state != "MEGHALAYA" & ///
		state != "NAGALAND" & state != "ODISHA" & state != "PUNJAB" & state != "RAJASTHAN" & ///
		state != "SIKKIM" & state != "TRIPURA" & state != "UTTAR PRADESH" & state != "WEST BENGAL"
	
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
	
	drop if first_treat == 2015 | first_treat == 2016
	drop if year != 2016 & year != 2018
	
	gen treat = 0 
	replace treat = 1 if first_treat == 2017
	gen post = 0 
	replace post = 1 if year == 2018
	gen interact = treat*post
	
	encode district_name, gen(d)
	encode state_name, gen(i)
	
	reg enrolled_ind treat post interact i.d i.year, cluster(i)
	
end 




program_
*Execute
main