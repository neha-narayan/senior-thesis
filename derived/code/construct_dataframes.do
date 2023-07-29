capture log close 
log using construct_dataframes.log, replace
clear all
set more off

global raw "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw"
global csv "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\derived\output\csv"
global messy_dta "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\derived\output\messy_dta"
global clean_dta "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\derived\output\clean_dta"

program main
    *prep_post2017
	*append_files
	*transform_enrollment_post2017
	*append_files_post2017
	recode_appended
end 

program prep_post2017
foreach year in 2018-19 2019-20 2020-21 2021-22 {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "nationalEnrol*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile enroll_`idx'
		save "`enroll_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`enroll_`i''"
	}
	save "${messy_dta}\enrollment_`year'", replace
}

//profile 
foreach year in 2018-19 2019-20  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "100_prof*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile prof_`idx'
		save "`prof_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`prof_`i''"
	}
	save "${messy_dta}\profile_`year'", replace
}

foreach year in 2020-21 2021-22  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "nationalProfile*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile prof_`idx'
		save "`prof_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`prof_`i''"
	}
	save "${messy_dta}\profile_`year'", replace
}

//facility
foreach year in 2018-19 2019-20  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "100_fac*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile facility_`idx'
		save "`facility_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`facility_`i''"
	}
	save "${messy_dta}\facility_`year'", replace
}

    foreach year in 2020-21 2021-22  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "nationalfacility*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile facility_`idx'
		save "`facility_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`facility_`i''"
	}
	save "${messy_dta}\facility_`year'", replace
}

//teachers
foreach year in 2018-19 2019-20  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "100_tch*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile teachers_`idx'
		save "`teachers_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`teachers_`i''"
	}
	save "${messy_dta}\teachers_`year'", replace
}

    foreach year in 2020-21 2021-22  {
	clear
	local idx = 0
    local filenames : dir "${raw}\\`year'" files "nationalTeacher*.csv"
	cap dis "`filenames'"
	foreach file in `filenames' {
		local idx "`++idx'"
		import delimited "${raw}\\`year'\\`file'", varnames(1) stringcols(_all)
		tempfile teachers_`idx'
		save "`teachers_`idx''"
		clear
	}
	clear
	forvalues i = 1/`idx' {
		append using "`teachers_`i''"
	}
	save "${messy_dta}\teachers_`year'", replace
}
end 

program append_files
    forvalues year = 2005/2017 {
	    import delimited "${csv}\basic_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile basic_`year'
		save "`basic_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`basic_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\basic_append", replace
	
	forvalues year = 2005/2017 {
	    import delimited "${csv}\general_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile general_`year'
		save "`general_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`general_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\general_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\facility_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile facility_`year'
		save "`facility_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`facility_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\facility_append", replace
	
	clear
	forvalues year = 2009/2017 {
	    import delimited "${csv}\teachers_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile teachers_`year'
		save "`teachers_`year''"
		clear
	}
	forvalues year = 2009/2017 {
		append using "`teachers_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\teachers_append", replace
	
	clear
	forvalues year = 2010/2017 {
	    import delimited "${csv}\rte_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile rte_`year'
		save "`rte_`year''"
		clear
	}
	forvalues year = 2010/2017 {
		append using "`rte_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\rte_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\repeaters_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile repeaters_`year'
		save "`repeaters_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`repeaters_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\repeaters_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\enrollment_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile enrollment_`year'
		save "`enrollment_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`enrollment_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\enrollment_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\scenrollment_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile scenrollment_`year'
		save "`scenrollment_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`scenrollment_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\scenrollment_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\stenrollment_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile stenrollment_`year'
		save "`stenrollment_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`stenrollment_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\stenrollment_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\obcenrollment_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile obcenrollment_`year'
		save "`obcenrollment_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`obcenrollment_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\obcenrollment_append", replace
	
	clear
	forvalues year = 2005/2017 {
	    import delimited "${csv}\disabledenrollment_`year'", varnames(1) stringcols(_all) ///
		bindquote(strict) maxquotedrows(100)
		tempfile disabledenrollment_`year'
		save "`disabledenrollment_`year''"
		clear
	}
	forvalues year = 2005/2017 {
		append using "`disabledenrollment_`year''"
	}
	qui duplicates drop 
	save "${messy_dta}\disabledenrollment_append", replace
	
	
end 

program append_files_post2017
    //profile seems = to general 
    /*clear
    foreach year in 2018-19 2019-20 2020-21 2021-22 {
		append using "${csv}\profile_`year'"
	}
	qui duplicates drop 
	save "${messy_dta}\profile_append"
	
	clear 
	foreach year in 2018-19 2019-20 2020-21 2021-22 {
		append using "${csv}\facility_`year'"
	}
	qui duplicates drop 
	save "${messy_dta}\facility_append_post2017", replace

    clear 
	foreach year in 2018-19 2019-20 2020-21 2021-22 {
		append using "${csv}\teachers_`year'"
	}
	qui duplicates drop 
	save "${messy_dta}\teachers_append_post2017", replace*/
	
	//this enrollment file is huge. transform first
	clear 
	foreach year in 2018-19 2019-20 2020-21 2021-22 {
		append using "${csv}\enrollment_`year'"
	}
	qui duplicates drop 
	save "${messy_dta}\enrollment_append_post2017", replace
end 

program recode_appended
    //basic 
	use "${messy_dta}/basic_append", clear
	replace district_name = distname if mi(district_name)
	rename (district_name school_code ac_year school_name block_name cluster_name village_name) ///
	    (district schoolcode academicyear schoolname blockname clustername villagename)
	drop distname 
	save "${messy_dta}/basic_append", replace
	
	//general 
	use "${messy_dta}/general_append", clear
	replace school_code = schcd if mi(school_code) 
	drop schcd
	replace rural_urban = rururb if mi(rural_urban)
	drop rururb
	forvalues i =  1/4 {
	    replace medium`i' = medinstr`i' if mi(medium`i')
		drop medinstr`i'
	}
	replace estdyear = yeur_estd if mi(estdyear)
	drop yeur_estd	
	replace pre_pry_yn = ppsec_yn if mi(pre_pry_yn)
	drop ppsec_yn
	replace residential_sch_yn = schres_yn if mi(residential_sch_yn)
	drop schres_yn
	replace sch_management = schmgt if mi(sch_management)
	drop schmgt
	replace lowest_class = lowclass if mi(lowest_class)
	drop lowclass
	replace highest_class = highclass if mi(highest_class)
	drop highclass
	rename schcat schoolcategory_post2013
	rename sch_category schoolcategory_pre2013
	replace pre_pry_students = ppstudent if mi(pre_pry_students)
	drop ppstudent
	replace school_type = schtype if mi(school_type)
	drop schtype
	replace shift_school_yn = schshi_yn if mi(shift_school_yn)
	drop schshi_yn
	destring workdays_* no_of_working_days, replace
	replace no_of_working_days = workdays_pr + workdays_upr + workdays_sec + workdays_hsec ///
	    if mi(no_of_working_days)
	drop workdays_*
	replace no_of_acad_inspection = noinspect if mi(no_of_acad_inspection)
	drop noinspect
	replace residential_sch_type = resitype if mi(residential_sch_type)
	drop resitype
	replace pre_pry_teachers = ppteacher if mi(pre_pry_teachers)
	drop ppteacher
	replace visits_by_brc = visitsbrc if mi(visits_by_brc)
	drop visitsbrc
	replace visits_by_crc = visitscrc if mi(visits_by_crc)
	drop visitscrc
	replace school_dev_grant_recd = schmntcgrant_r if mi(school_dev_grant_recd)
	drop schmntcgrant_r
	replace school_dev_grant_expnd = schmntcgrant_e if mi(school_dev_grant_expnd)
	drop schmntcgrant_e
	replace tlm_grant_recd = conti_r if mi(tlm_grant_recd)
	drop conti_r
	replace tlm_grant_expnd = conti_e if mi(tlm_grant_expnd)
	drop conti_e
	replace funds_from_students_recd = funds_r if mi(funds_from_students_recd)
	drop funds_r
	replace funds_from_students_expnd = funds_e if mi(funds_from_students_expnd)
	drop funds_e
	
	rename (school_code ac_year rural_urban distance_brc distance_crc pre_pry_yn residential_sch_yn) ///
	    (schoolcode academicyear ruralurban distancetobrc distancetocrc preprimary_ind resschool_ind)
	rename (lowest_class highest_class pre_pry_students school_type shift_school_yn no_of_working_days) ///
	    (lowestclass highestclass preprimary_students schooltype shiftschool_ind num_workingdays)
	rename (estdyear) (year_est)
	drop boardsec boardhsec schmgts schmgths
	save "${messy_dta}/general_append", replace
	
	//facility
	use "${messy_dta}/facility_append", clear
	replace school_code = schcd if mi(school_code) 
	drop schcd
	replace building_status = bldstatus if mi(building_status) //unavailable 2012-13
	drop bldstatus
	replace tot_clrooms = clrooms if mi(tot_clrooms)
    drop clrooms
	replace classrooms_in_good_condition = clgood if mi(classrooms_in_good_condition)
	drop clgood
	replace classrooms_require_major_repair = clmajor if mi(classrooms_require_major_repair)
	drop clmajor 
	replace classrooms_require_minor_repair = clminor if mi(classrooms_require_minor_repair)
	drop clminor
	replace other_rooms_in_good_cond = othgood if mi(other_rooms_in_good_cond)
	drop othgood
	replace other_rooms_need_major_rep = othmajor if mi(other_rooms_need_major_rep)
	drop othmajor
	replace other_rooms_need_minor_rep = othminor if mi(other_rooms_need_minor_rep)
	drop othminor
	foreach var in toilet_common_yn toilet_c toiletd {
	    	replace toilet_common = `var' if mi(toilet_common)
			drop `var'
	}
	foreach var in toilet_girls_yn toilet_g toiletg_func {
	    replace toilet_girls = `var' if mi(toilet_girls)
		drop `var'
	}
	foreach var in toilet_boys_yn toiletb toiletb_func {
	    replace toilet_boys = `var' if mi(toilet_boys) 
		drop `var'
	}
	replace electricity = electric_yn if mi(electricity)
	drop electric_yn
	replace boundary_wall = bndrywall if mi(boundary_wall)
	drop bndrywall
	replace playground = pground_yn if mi(playground)
	drop pground_yn
    replace books_in_library = 	bookinlib if mi(books_in_library)
	drop bookinlib
	replace drinking_water = water if mi(drinking_water)
	drop water
	replace medical_checkup = medchk_yn if mi(medical_checkup)
	drop medchk_yn
	replace ramps = ramps_yn if mi(ramps)
	drop ramps_yn 
	replace no_of_computers = computer if mi(no_of_computers)
	drop computer
	replace male_tch = tch_male if mi(male_tch)
	drop tch_male
	replace female_tch = tch_female if mi(female_tch)
	drop tch_female
	replace noresp_tch = tch_nr if mi(noresp_tch)
	drop tch_nr
	replace head_teacher = headtch if mi(head_teacher)
	drop headtch
	replace graduate_teachers = gradabove if mi(graduate_teachers)
	drop gradabove
	replace tch_with_professional = tchwithprof if mi(tch_with_professional) 
	drop tchwithprof
	replace days_involved_in_non_tch = daysinvld if mi(days_involved_in_non_tch) 
	drop daysinvld
	replace teachers_involved_in_non_tch = tchinvld if mi(teachers_involved_in_non_tch)
	drop tchinvld
	replace status_of_mdm = mealsinsch if mi(status_of_mdm)
	drop mealsinsch
	replace kitchen_devices_grant = kitdevgrant_yn if mi(kitchen_devices_grant)
	drop kitdevgrant_yn
	replace computer_aided = cal_yn if mi(computer_aided)
	drop cal_yn
	drop book_bank blackboard column1
	save "${messy_dta}/facility_append", replace
	
	//teachers
	use "${messy_dta}/teachers_append", clear
	rename (tch_male tch_female tch_nr gradabove tchwithprof daysinvld tchinvld) ///
	    (male_tch female_tch noresp_tch graduate_teachers tch_with_professional days_involved_in_non_tch teachers_involved_in_non_tch)
	save "${messy_dta}/teachers_append", replace
	
	//rte
	use "${messy_dta}/rte_append", clear
	replace ac_year = acyear if mi(ac_year)
	drop acyear
	replace working_days_primary = workdays_pr if mi(working_days_primary)
	drop workdays_pr
	replace working_days_uprimary = workdays_upr if mi(working_days_uprimary)
	drop workdays_upr 
	replace school_hours_children_upri = schhrschild_upr if mi(school_hours_children_upri)
	drop schhrschild_upr
	replace school_hours_tch_p = schhrstch_pr if mi(school_hours_tch_p)
	drop schhrstch_pr
	replace school_hours_tch_upr = schhrstch_upr if mi(school_hours_tch_upr)
	drop schhrstch_upr
	replace approachable_by_all_weather_road  = approachbyroad ///
	    if mi(approachable_by_all_weather_road)
	drop approachbyroad
	replace cce_implemented = cce_yn if mi(cce_implemented)
	drop cce_yn 
	replace pcr_maintained = people_cumil if mi(pcr_maintained)
	drop people_cumil
	replace pcr_shared_with_parents = pcr_shared if mi(pcr_shared_with_parents)
	drop pcr_shared
	replace wsec25p_applied = children_from_weaker_section_app if mi(wsec25p_applied)
	drop children_from_weaker_section_app
	replace wsec25p_enrolled = children_from_weaker_section_enr if mi(wsec25p_enrolled)
	drop children_from_weaker_section_enr
	replace smc_constit
	
	
	
	
	
	qui ds 
	foreach var in `r(varlist)' {
	    dis "`var'"
	    count if mi(`var')
	}
	
	
		

    
end 



*Execute
main
