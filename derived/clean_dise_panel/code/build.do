capture log close 
log using build.log, replace
clear all
set more off

program main 
    //sample 
    consolidate_vars
	//gen_plots
    //drop_suspicious_obs
end

program sample 
    use school_code using ../../../shared_data/panel, clear
    duplicates drop
    sample 1
    save ../output/1pctsample_codes, replace
    use ../output/1pctsample_codes, clear
    merge 1:m school_code using ../../construct_dataframes_dise/output/clean_dta/panel_pre2017, assert(1 2 3) keep(3) nogen
    save ../output/pre2017panel_1pct, replace

    use ../output/1pctsample_codes, clear 
    merge 1:m school_code using ../../construct_dataframes_dise/output/clean_dta/panel_post2017, assert(1 2 3) keep(3) nogen
    save ../output/post2017panel_1pct, replace

    use ../output/1pctsample_codes, clear 
    merge 1:m school_code using ../../construct_dataframes_dise/output/clean_dta/RECODED_panel_2001-12, assert(1 2 3) keep(3) nogen
    save ../output/pre2005panel_1pct, replace

    qui append using ../output/pre2017panel_1pct
    qui append using ../output/post2017panel_1pct
    save ../output/panel_1pct, replace
end 

program consolidate_vars
    dis "recode vars"
    //use  ../../../shared_data/panel, clear
	use  ../../../shared_data/panel_1pct, clear

	*create analysis sample 
	drop if ac_year == "2018-19" | ac_year == "2019-20" | ac_year == "2020-21" | ac_year == "2021-22"
	cap drop N
	bysort school_code: gen N = _N
	drop if N != 13

    /*
	preserve 
	    duplicates drop school_code, force
	    la var N "Years present in dataset"
	    tabout N using ../output/yearsindataset.tex, replace oneway style(tex) c(freq col cum) ///
	        clab(N_Schools Column_% Cumulative_%) f(0c 2 2) mi 
	restore
	*/ 

	//state 
	replace state = "Andaman and Nicobar Islands" if state == "Andaman & Nicobar Islands"
	foreach name in "Dadra & Nagar Haveli" "Dadra & Nagar Haveli and Daman & Diu" "Dadra and Nagar Haveli" "Daman & Diu" "Daman & Diu and Dadra & Nagar Haveli" "Daman and Diu" {
		replace state = "DNH and DD" if state == "`name'"
	}
    replace state = "Jammu and Kashmir" if state == "Jammu & Kashmir" | state == "01"
	replace state = "Kerala" if state == "Kerla"
	replace state = "Odisha" if state == "Orissa"
	replace state = "Tamil Nadu" if state == "Tamilnadu"
	replace state = "Uttarakhand" if state == "Uttaranchal" 
	replace state = "Himachal Pradesh" if state == "02"
	replace state = "Punjab" if state == "03"
	replace state = "Chandigarh" if state == "04"
	replace state = "Uttarakhand" if state == "05"
	replace state = "Haryana" if state == "06"
	replace state = "Delhi" if state == "07"
	replace state = "Rajasthan" if state == "08"
	replace state = "Uttar Pradesh" if state == "09"
	replace state = "Bihar" if state == "10"
	replace state = "Sikkim" if state == "11"
	replace state = "Arunachal Pradesh" if state == "12"
	replace state = "Nagaland" if state == "13"
	replace state = "Mizoram" if state == "15"
	replace state = "Tripura" if state == "16"
	replace state = "Meghalaya" if state == "17"
	replace state = "Assam" if state == "18"
	replace state = "West Bengal" if state == "19" 
	replace state = "Jharkhand" if state == "20"
	replace state = "Odisha" if state == "21"
	replace state = "Chhattisgarh" if state == "22"
	replace state = "Madhya Pradesh" if state == "23"
	replace state = "Gujarat" if state == "24"
	replace state = "Maharashtra" if state == "27"
	replace state = "Andhra Pradesh" if state == "28"
	replace state = "Karnataka" if state == "29"
	replace state = "Kerala" if state == "32"
	replace state = "Tamil Nadu" if state == "33"
	replace state = "Puducherry" if state == "34"
	replace state = "Andhra Pradesh" if state == "Telangana"
	drop if state == "Ladakh" //we only have data from 2018-19 onwards from Ladakh
	gsort school_code -state
	by school_code: replace state = state[_n-1] if mi(state) 

    //district
    replace district = district_name if mi(district)
    drop district_name
    gsort school_code -district
    by school_code: replace district = district[_n-1] if mi(district) 
    //the remaining rows with missing district do not have a value for "district", so just put distid in there
    //replace district = distid if mi(district)
    //drop distid
    dis "counting how many schools are missing district"
    count if mi(district)
	
    //electricity
    replace electricity = . if electricity == 0 | electricity == 9 
    replace electricity = electricity_availability if mi(electricity)
    dis "counting how many schools are missing elec"
    count if mi(electricity)

    //boundary wall
	replace boundary_wall = . if boundary_wall == 9 | boundary_wall == 10 | boundary_wall == 22 | boundary_wall == 99 | boundary_wall == 0
	
	//medical checkups
	replace medical_checkup = . if medical_checkup == 0 | medical_checkup == 9 | medical_checkup == 5
	
	//ramps
	replace ramps = . if ramps != 1 & ramps != 2
	
	/*
	//water available 
    replace drinking_water = . if drinking_water < 1 | drinking_water > 5
	replace water_any = 1 if drinking_water < 5 
	replace water_any = 0 if drinking_water == 5 
	replace water_any = 1 if drinking_water_available == 1
	replace water_any = 0 if drinking_water_available == 2
	drop drinking_water drinking_water_available
	
	//toilets
	drop toilett toilett_func toiletd toiletd_func 
	replace toilet_g = toilet_girls if mi(toilet_g)
	replace toilet_g = total_girls_toilet if mi(toilet_g)
	drop toilet_girls total_girls_toilet
	replace toiletb = toilet_boys if mi(toiletb)
	replace toiletb = total_boys_toilet if mi(toiletb)
	drop toilet_boys total_boys_toilet
	replace toilet_c = toilet_common if mi(toilet_c)
	drop toilet_common
	replace toiletb_func = total_boys_func_toilet if mi(toiletb_func)
	replace toiletg_func = total_girls_func_toilet if mi(toiletg_func)
	drop total_girls_func_toilet total_boys_func_toilet
	rename toiletb toilet_b
	
	//classrooms 
	replace clrooms = tot_clrooms if mi(clrooms)
	replace clrooms = total_class_rooms if mi(clrooms)
	drop tot_clrooms total_class_rooms
	replace clgood = classrooms_in_good_condition if mi(clgood)
	drop classrooms_in_good_condition 
	replace clminor = classrooms_needs_minor_repair if mi(clminor)
	replace clmajor = classrooms_needs_major_repair if mi(clmajor)
	drop classrooms_needs*
	
	//other rooms
	replace othrooms = othgood + othminor + othmajor 
	replace othrooms = other_rooms if mi(othrooms)
	drop other_rooms
	
    //rural 
	replace rural_urban = . if rural_urban == 9
	gsort school_code -rural_urban
    by school_code: replace rural_urban = rural_urban[_n-1] if mi(rural_urban)
	drop rural
	
	//computer aided learning lab 
	replace computer_aided_learnin_lab = . if ///
	    computer_aided_learnin_lab == 0 | computer_aided_learnin_lab == 9
	replace computer_aided_learnin_lab = 0 if ///
	    computer_aided_learnin_lab == 2 | computer_aided_learnin_lab == 3
	replace ict_lab = . if ict_lab == 0 
	replace ict_lab = 0 if ict_lab == 2 
	replace cal_yn = computer_aided_learnin_lab if mi(cal_yn)
	replace cal_yn = ict_lab if mi(cal_yn)
	drop computer_aided_learnin_lab ict_lab
	
	//number of computers
	replace num_computer = desktop + laptop if mi(num_computer)
	replace num_computer = no_of_computers if mi(num_computer)
	drop no_of_computer
	
	//playground 
	replace playground = . if playground == 0 | playground == 9
	replace playground = 0 if playground == 2 
	replace playground_available = 0 if playground_available == 2
	replace play = playground if mi(play)
	replace play = playground_available if mi(play)
	drop playground*
	
	//homeroom 
	replace hmroom_yn = . if hmroom_yn == 0 | hmroom_yn == 9
	replace hmroom_yn = separate_room_for_hm if mi(hmroom_yn)
	replace hmroom_yn = 0 if hmroom_yn == 2
	drop separate_room_for_hm
	
	//medium of instruction
	rename medium_instr1 medium_of_instr1 
	forvalues i = 1/4 {
		replace medium`i' = medinstr`i' if mi(medium`i')
		replace medium`i' = medium_of_instr`i' if mi(medium`i')
		drop medinstr`i' medium_of_instr`i' 
		replace medium`i' = 0 if medium`i' == 98
	}
	
	//school management 
	//schmgt_...,  sch_management, management
	*/

	*aggregate exam appearance variables as alternative
	//gen tot_appr5 = apprb5 + apprg5
	
	*aggregate enrollment variables 

	//total and split by gender
	egen pup_b = rowtotal(c1_totb c2_totb c3_totb c4_totb c5_totb c6_totb c7_totb c8_totb)
	egen pup_g = rowtotal(c1_totg c2_totg c3_totg c4_totg c5_totg c6_totg c7_totg c8_totg)
	gen tot_pup = pup_b + pup_g

	/*
	egen pri_b = rowtotal(c1_totb c2_totb c3_totb c4_totb)
	egen pri_g = rowtotal(c1_totg c2_totg c3_totg c4_totg)
	gen tot_pri = pri_g + pri_b


	//sc - the sum here has been checked and it works 
	egen pup_cb = rowtotal(c1_cb c2_cb c3_cb c4_cb c5_cb c6_cb c7_cb c8_cb)
	egen pup_cg = rowtotal(c1_cg c2_cg c3_cg c4_cg c5_cg c6_cg c7_cg c8_cg)   
	gen pup_c = pup_cb + pup_cg

	//st
	egen pup_tb = ///
	    rowtotal(cpp_tb c1_tb c2_tb c3_tb c4_tb c5_tb c6_tb c7_tb c8_tb c9_tb c10_tb c11_tb c12_tb)
	egen pup_tg = ///
	    rowtotal(cpp_cb c1_tg c2_tg c3_tg c4_tg c5_tg c6_tg c7_tg c8_tg c9_tg c10_tg c11_tg c12_tg)   
	gen pup_t = pup_tb + pup_tg
	
	//obc
	egen pup_ob = rowtotal(c1_ob c2_ob c3_ob c4_ob c5_ob c6_ob c7_ob c8_ob)
	egen pup_og = rowtotal(c1_og c2_og c3_og c4_og c5_og c6_og c7_og c8_og)   
	gen pup_o = pup_ob + pup_og
*/
    save ../../../shared_data/balanced_panel, replace
end 

program gen_plots
    preserve 
        collapse (sum) tot_pup, by(state ac_year)
        egen year = group(ac_year)
        twoway line tot_pup year if state == "Uttar Pradesh", xline(17) ytitle("Average Total P and UP Enrollment") xtitle("Year") title("Total Enrollment, Uttar Pradesh") 
	restore 
	
	preserve 
	    keep if state == "Uttar Pradesh"
		levelsof(ac_year), local(years)
		gen num_schools = .
		foreach year in `years' {
			count if ac_year == "`year'"
			replace num_schools = `r(N)' if ac_year == "`year'"
		}
		duplicates drop num_schools, force
		egen year = group(ac_year)
		twoway line num_schools year 
	restore 
		
	    
	
	
	
	
	
	graph export ../output/UP_enrollment.png, replace

	twoway line tot_pri year if state == "Andhra Pradesh", xline(15) ytitle("Average Total P and UP Enrollment") xtitle("Year") title("Total Enrollment, Andhra Pradesh")
	graph export ../output/AP_enrollment.png, replace

	twoway line tot_pri year if state == "Maharashtra", ytitle("Average Total P and UP Enrollment") xtitle("Year") title("Total Enrollment, Maharashtra")
	graph export ../output/Maha_enrollment.png, replace

	twoway line tot_pri year if state == "Assam", ytitle("Average Total P and UP Enrollment") xtitle("Year") title("Total Enrollment, Assam")
	graph export ../output/Assam_enrollment.png, replace
end

program drop_suspicious_obs
    use ../output/clean_dta/panel_pre2017, clear
	foreach var in apprb5 apprg5 apprb8 apprg8 {
		replace `var' = "." if `var' == "NA"
		destring `var', replace
	}
	tab ac_year if mi(apprb5)
	drop if ac_year == "2005-06" | ac_year == "2006-07" | ac_year == "2007-08" | ac_year == "2008-09" | ac_year == "2013-14"
	foreach var in apprb5 apprg5 apprb8 apprg8 {
		bys school_code (ac_year): gen pctChange_`var' = (`var'[_n] - `var'[_n-1])/`var'[_n-1]
		replace pctChange_`var' = 0 if `var'[_n] == 0 & `var'[_n-1] == 0
	    replace pctChange_`var' = `var'[_n] if `var'[_n] != 0 & `var'[_n-1] == 0
	}
	foreach var in c5_totb c5_totg c8_totb c8_totg {
        bys school_code (ac_year): gen pctChange_`var' = (`var'[_n] - `var'[_n-1])/`var'[_n-1]
		replace pctChange_`var' = 0 if `var'[_n] == 0 & `var'[_n-1] == 0
		replace pctChange_`var' = `var'[_n] if `var'[_n] != 0 & `var'[_n-1] == 0
	}
	gen ratiob5 = pctChange_apprb5/pctChange_c5_totb
	gen ratiog5 = pctChange_apprg5/pctChange_c5_totg
	gen ratiob8 = pctChange_apprb8/pctChange_c8_totb
	gen ratiog8 = pctChange_apprg8/pctChange_c8_totg
	
	foreach var in ratiob5 ratiog5 ratiob8 ratiog8 {
		bysort school_code: egen mean_`var' = mean(`var')
	}
 	bysort school_code: gen meaned_ratio = mean_ratiob5 + mean_ratiog5 + mean_ratiob8 + mean_ratiog8 / 4
	
	centile meaned_ratio, centile(5)
	local lower = `r(c_1)'
	dis `lower'
	centile meaned_ratio, centile(95)
	local upper = `r(c_1)'
	drop if meaned_ratio < lower | meaned_ratio > upper
	
	hist meaned_ratio
	graph export ../output/ratio_hist.pdf, replace
end 



*Execute
main