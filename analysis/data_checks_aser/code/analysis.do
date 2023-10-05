capture log close 
log using analysis.log, replace
clear all
set more off

program main 
    //enroll_plots
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






*Execute
main