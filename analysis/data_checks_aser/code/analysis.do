capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    enroll_plots
end

program enroll_plots 
    use ../../../shared_data/cross_section_mean, clear
	
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
		connect(direct) cmissing(n) xline(2015, lcolor(gray)) title("Enrollment Rate Over Time, By Treatment Group")) ///
	    (scatter enrolled_ind year if treatment_time == 2016, ///
		connect(direct) cmissing(n) xline(2016, lcolor(gray))) ///
		(scatter enrolled_ind year if treatment_time == 2017, ///
		connect(direct) cmissing(n) xline(2017, lcolor(gray))), ///
 	    legend(order(1 "Control" 2 "Treatment Time = 2013"  3 "Treatment Time = 2015" ///
		    4 "Treatment Time = 2016" 5 "Treatment Time = 2016"))

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


*Execute
main