capture log close 
log using build.log, replace
clear all
set more off

global raw_house "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\ASER_Household_Village_Data"

program main
    //convert_to_dta
    //recode 
	//append_files
	clean_appended
	clear_temp
	collapse_datasets
end 


program convert_to_dta
    import delimited "${raw_house}/ASER 2007 Household Data", varnames(1) stringcols(_all) 
	trim_strings
	rename (anganvadistatusage3to5schgoing anganvadistatusage3to5schnotgoin) ///
	    (anganvadigoing anganvadinotgoing)
    rename (schoolstatusage5to16govt schoolstatusage5to16madarsa schoolstatusage5to16pvt schoolstatusage5to16oth) ///
	    (govt_ind madarsa_ind pvt_ind other_ind)
	rename (doeschildgotothesurveyedschoolye doeschildgotothesurveyedschoolno) ///
	    (surveyedschool_yes surveyedschool_no)
	rename (basiclearninglevelsreadstory basiclearninglevelsreadletter basiclearninglevelsreadpara) ///
	    (readstory readletter readpara)
	rename (basiclearninglevelsreadnothing basiclearninglevelsreadword) (readnothing readword)
	rename languageinwhichchildtested test_language
	rename (englishreadingnothing englishmeaningswordscansay englishreadinglettersmall englishmeaningswordscantsay) ///
	    (eng_readnothing eng_wordscan eng_lettersmall eng_wordscant)
	rename (englishreadinglettercapital englishmeaningssentencecansay englishreadingword englishmeaningssentencecantsay) ///
	    (eng_lettercap eng_sentencecan eng_readword english_sentencecant)
    rename englishreadingsentence eng_readsentence
	convert_to_int
	gen year = 2007 
	save ../output/messy_dta/household_2007, replace
	
	clear
	import delimited "${raw_house}/ASER 2008 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2008
	save ../output/messy_dta/household_2008, replace
	
	clear
	import delimited "${raw_house}/ASER 2009 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2009
	save ../output/messy_dta/household_2009, replace
	
	clear
	import delimited "${raw_house}/ASER 2010 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2010
	save ../output/messy_dta/household_2010, replace
	
	clear
	import delimited "${raw_house}/ASER 2011 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2011
	save ../output/messy_dta/household_2011, replace
	
	clear
	import delimited "${raw_house}/ASER 2012 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2012
	save ../output/messy_dta/household_2012, replace
	
	clear
	import delimited "${raw_house}/ASER 2013 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2013
	save ../output/messy_dta/household_2013, replace
	
	clear
	import delimited "${raw_house}/ASER 2014 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2014
	save ../output/messy_dta/household_2014, replace
	
	clear
	import delimited "${raw_house}/ASER 2016 Household Data", varnames(1) stringcols(_all) 
	trim_strings
	convert_to_int
	gen year = 2016
	save ../output/messy_dta/household_2016, replace
	
	clear
	import delimited "${raw_house}/ASER 2018 Household Data", varnames(1) stringcols(_all)
	trim_strings
	convert_to_int
	gen year = 2018
	save ../output/messy_dta/household_2018, replace
	
end 

program recode 
    //2007
	use ../output/messy_dta/household_2007, clear 
    gen sample_year = .
	replace sample_year = 2005 if aser05village == 1 
	replace sample_year = 2006 if aser06village == 1 
	replace sample_year = 2007 if aser07village == 1 
	
	rename(village_id totalmember household_id child_slno child_sex motherstudieduptoclass) ///
	    (village_code total_member hh_id child_no child_gender mother_class)
		
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mothergonetoschoolyes == 1
	replace mother_gone_to_school = 2 if mothergonetoschoolno == 1
	
	gen preschool_ind = .
	replace preschool_ind = 1 if anganvadigoing == 1 
	replace preschool_ind = 0 if anganvadinotgoing == "1"
	
	destring madarsa_ind other_ind, replace
	
	rename (child5to16schoolingclassstd age5to16neverbeentoschool age5to16dropout ge5to16dropoutstd) ///
	    (school_class oos_never_enr oos_dropout oos_dropout_class) 
	destring school_class oos_*, replace
		
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1
	drop if mi(child_age)
	
	gen tuition = . 
	replace tuition = 1 if tutionyes == 1 
	replace tuition = 2 if tutionno == 1 
	
	gen surveyed_school = .
	replace surveyed_school = 1 if surveyedschool_yes == 1 
	replace surveyed_school = 2 if surveyedschool_no == 1 
	
	tostring mother_class, replace
	replace mother_class = "Above HS" if mother_class == "13"
	replace mother_class = "0" if mother_class == "14"
	
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "ODISHA" if state_name == "ORISSA"
	replace state_name = "PUDUCHERRY" if state_name == "Pondicherry"
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	//per Bryce's recommendation in Drought of Opportunity
	foreach var in mathlevelnumrec1to9 mathlevelnumrec10to99 mathlevelsubtraction mathleveldivision {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = mathlevelnumrec1to9 + 2*mathlevelnumrec10to99 + 3*mathlevelsubtraction + 4*mathleveldivision
	
	foreach var in readletter readword readpara readstory {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = readletter + 2*readword + 3*readpara + 4*readstory
	replace read_code = 0 if mi(read_code)
	
    foreach var in mathwordq1can mathwordq2can {
	    replace `var' = 0 if mi(`var')
	}
	
	gen mathwordprob_scaled = (mathwordq1can + mathwordq2can)/2
	
	foreach var in comprehensionq1can comprehensionq2can comprehensionq3can comprehensionq4can {
	    replace `var' = 0 if mi(`var')
	}
	gen readwordprob_scaled = (comprehensionq1can + comprehensionq2can + comprehensionq3can + comprehensionq4can)/4
	
	foreach var in eng_lettersmall eng_lettercap eng_readword eng_readsentence eng_wordscan ///
	    eng_sentencecan {
	    replace `var' = 0 if mi(`var')
	}
	gen english_code = eng_lettersmall + 2*eng_lettercap + 3*eng_readword + 4*eng_readsentence 
	
	rename (mult motherage eng_wordscan eng_sentencecan) ///
	    (hh_multiplier mother_age english_comp_word english_comp_sentence)
		
	drop aser0* mothergone* angan* tution* surveyedschool_* ///
	    read* comprehension* mathlevel* mathwordq* eng_* english_sentencecant
		
    save ../output/clean_dta/household_2007, replace
	
	//2008
	use ../output/messy_dta/household_2008, clear
	gen sample_year = .
	replace sample_year = 2006 if aser06 == 1 
	replace sample_year = 2007 if aser07 == 1 
	replace sample_year = 2008 if aser08 == 1
	
	destring school_class oos_*, replace
	
	egen missing_tracker = rowtotal(hhtype_pucca hhtype_semi_katcha hhtype_katcha)
	foreach var in hhtype_pucca hhtype_semi_katcha hhtype_katcha {
	    replace `var' = 0 if mi(`var') & missing_tracker != 0 
	}
	
	gen hh_electricity_conn = .
	replace hh_electricity_conn = 1 if hh_electricity_conn_yes == 1
	replace hh_electricity_conn = 2 if hh_electricity_conn_no == 1
	gen hh_electricity_today = .
	replace hh_electricity_today = 1 if hh_electricity_obs_yes == 1
	replace hh_electricity_today = 2 if hh_electricity_obs_no == 1
	gen hh_tv = .
	replace hh_tv = 1 if hh_tv_yes == 1 
	replace hh_tv = 2 if hh_tv_no == 1 
	gen hh_phone = .
	replace hh_phone = 1 if hh_phone_yes == 1 
	replace hh_phone = 2 if hh_phone_no == 1 
	
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mother_gone_to_school_yes == 1
	replace mother_gone_to_school = 2 if mother_gone_to_school_no == 1
	
	tostring mother_class, replace
	replace mother_class = "Bachelors" if mother_class == "13"
	replace mother_class = "Masters" if mother_class == "14"
	replace mother_class = "0" if mother_class == "99"
	
	gen preschool_ind = .
	replace preschool_ind = 1 if preschool_yes == 1 
	replace preschool_ind = 0 if preschool_no == "1"
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1
	drop if mi(child_age)
	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
    destring govt_ind pvt_ind madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}

	//recode states for consistency with 2018 dataset 
	replace state_name = "ANDHRA PRADESH" if state_name == "ANDHHRA PRADESH"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADAR & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GUJARAT" if state_name == "GUJRAT"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "ODISHA" if state_name == "ORRISA"
	replace state_name = "PUDUCHERRY" if state_name == "PONDICHERRY"
	replace state_name = "TAMIL NADU" if state_name == "TAMILNADU"
	replace state_name = "UTTARAKHAND" if state_name == "UTTRANCHAL"
	replace state_name = "KERALA" if state_name == "kerala"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	//per Bryce's rec
	foreach var in math_num_1_9 math_num_10_99 math_subtraction math_division {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = 1*math_num_1_9 + 2*math_num_10_99 + 3*math_subtraction + 4*math_division

	foreach var in read_letter read_word read_level_1 read_level_2 {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = 1*read_letter + 2*read_word + 3*read_level_1 + 4*read_level_2

	foreach var in timeclock1_yes timeclock2_yes funpart1_yes funpart2_yes {
	    replace `var' = 0 if mi(`var')
	}	
	gen mathwordprob_scaled = (timeclock1_yes + timeclock2_yes + funpart1_yes + funpart2_yes)/4
	
	rename vlg_electricity_conn vlg_electricity

	drop math_num_1_9 math_num_10_99 math_subtraction math_division read_letter read_word ///
	    read_level_1 read_level_2 timeclock1_yes timeclock2_yes funpart1_yes funpart2_yes ///
		read_nothing math_nothing aser* hh_electricity_conn_yes ///
		hh_electricity_conn_no hh_electricity_obs_yes hh_electricity_obs_no hh_tv_no hh_tv_yes ///
		hh_phone_yes hh_phone_no preschool_yes preschool_no timeclock1_no timeclock2_no ///
		funpart1_no funpart2_no mother_gone_to_school_* ///
	
	destring vlg_*, replace
		
	save ../output/clean_dta/household_2008, replace
	
	//2009
	use ../output/messy_dta/household_2009, clear 
	gen sample_year = .
	replace sample_year = 2007 if aser07 == 1 
	replace sample_year = 2008 if aser08 == 1 
	replace sample_year = 2009 if aser09 == 1
	
	destring school_class oos_*, replace
	
	egen missing_tracker = rowtotal(hhtype_pucca hhtype_semi_katcha hhtype_katcha)
	foreach var in hhtype_pucca hhtype_semi_katcha hhtype_katcha {
	    replace `var' = 0 if mi(`var') & missing_tracker != 0 
	}

	gen hh_electricity_conn = .
	replace hh_electricity_conn = 1 if hh_electricity_conn_yes == 1
	replace hh_electricity_conn = 2 if hh_electricity_conn_no == 1
	gen hh_tv = .
	replace hh_tv = 1 if hh_tv_yes == 1 
	replace hh_tv = 2 if hh_tv_no == 1 
	gen hh_phone = .
	replace hh_phone = 1 if hh_mobile_yes == 1 
	replace hh_phone = 2 if hh_mobile_no == 1 
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "0" if `var' == "99"
		replace `var' = "Bachelors" if `var' == "15"
		replace `var' = "Masters" if `var' == "17"
	}
	
	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)
	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	//recode states for consistency with 2018 dataset 
	replace state_name = "ANDHRA PRADESH" if state_name == "ANDHHRA PRADESH"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADAR & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GUJARAT" if state_name == "GUJRAT"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "ODISHA" if state_name == "ORRISA"
	replace state_name = "PUDUCHERRY" if state_name == "PONDICHERRY"
	replace state_name = "TAMIL NADU" if state_name == "TAMILNADU"
	replace state_name = "UTTARAKHAND" if state_name == "UTTRANCHAL"
	replace state_name = "KERALA" if state_name == "kerala"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	foreach var in math_num_1_9 math_num_10_99 math_subtraction math_division {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = 1*math_num_1_9 + 2*math_num_10_99 + 3*math_subtraction + 4*math_division

	foreach var in read_letter read_word read_level_1 read_level_2 {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = 1*read_letter + 2*read_word + 3*read_level_1 + 4*read_level_2
	
	foreach var in english_lowercase_letter english_uppercase_letter english_word english_sentence ///
	    english_comp_word english_comp_sentence {
	    replace `var' = 0 if mi(`var')
	}
	gen english_code = english_lowercase_letter + 2*english_uppercase_letter + 3*english_word + 4*english_sentence
	
	destring vlg_*, replace
	
	drop math_num_1_9 math_num_10_99 math_subtraction math_division read_letter read_word ///
	    read_level_1 read_level_2 read_nothing math_nothing aser*  ///
		hh_electricity_conn_yes hh_electricity_conn_no  hh_tv_no hh_tv_yes ///
		hh_mobile_yes hh_mobile_no preschool_no kindergarton_yes english_nothing ///
		english_uppercase_letter english_lowercase_letter english_word english_sentence ///
		
	save ../output/clean_dta/household_2009, replace
	
	//2010
	use ../output/messy_dta/household_2010, clear 
	gen sample_year = .
	replace sample_year = 2008 if aser08 == 1 
	replace sample_year = 2009 if aser09 == 1 
	replace sample_year = 2010 if aser10 == 1
	
	destring school_class oos_*, replace
	
	egen missing_tracker = rowtotal(hhtype_pucca hhtype_semi_katcha hhtype_katcha)
	foreach var in hhtype_pucca hhtype_semi_katcha hhtype_katcha {
	    replace `var' = 0 if mi(`var') & missing_tracker != 0 
	}
	
	gen hh_electricity_conn = .
	replace hh_electricity_conn = 1 if hh_electricity_conn_yes == 1
	replace hh_electricity_conn = 2 if hh_electricity_conn_no == 1
	gen hh_electricity_today = .
	replace hh_electricity_today = 1 if hh_electricity_today_yes == 1
	replace hh_electricity_today = 2 if hh_electricity_today_no == 1
	gen hh_toilet = . 
	replace hh_toilet = 1 if hh_toilet_yes == 1 
	replace hh_toilet = 2 if hh_toilet_no == 1 
	gen hh_tv = .
	replace hh_tv = 1 if hh_tv_yes == 1 
	replace hh_tv = 2 if hh_tv_no == 1 
	gen hh_cable_tv = .
	replace hh_cable_tv = 1 if hh_cable_tv__yes == 1 
	replace hh_cable_tv = 2 if hh_cable_tv__no == 1
	replace hh_tv = . if hh_tv == 2 & hh_cable_tv == 1 //remove erroneous obs
	replace hh_cable_tv = . if hh_tv == 2 & hh_cable_tv == 1 //remove erroneous obs
	gen hh_phone = .
	replace hh_phone = 1 if hh_mobile_yes == 1 
	replace hh_phone = 2 if hh_mobile_no == 1 
	gen hh_computer_use = .
	replace hh_computer_use = 1 if hh_computer_use_yes == 1
	replace hh_computer_use = 2 if hh_computer_use_no == 1
	gen hh_dvd = .
	replace hh_dvd = 1 if hh_dvd_yes == 1 
	replace hh_dvd = 2 if hh_dvd_no == 1 
	gen hh_newspaper = . 
	replace hh_newspaper = 1 if hh_newspaper_yes == 1 
	replace hh_newspaper = 2 if hh_newspaper_no == 1 
	gen hh_reading_material = . 
	replace hh_reading_material = 1 if hh_reading_material_yes == 1 
	replace hh_reading_material = 2 if hh_reading_material_no == 1 
	
	gen tuition = . 
	replace tuition = 1 if tuition_yes == 1 
	replace tuition = 2 if tuition_no == 1 
	
	gen tuition_govt_school = .
	replace tuition_govt_school = 1 if tuition_school_teacher_yes  == "1" 
	replace tuition = 2 if  tuition_school_teacher_no  == 1 
	
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mother_gone_to_school_yes == 1
	replace mother_gone_to_school = 2 if mother_gone_to_school_no == 1
	
	gen father_gone_to_school = .
	replace father_gone_to_school = 1 if father_gone_to_school_yes == 1
	replace father_gone_to_school = 2 if father_gone_to_school_no == 1
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}

	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)

    rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	gen surveyed_school = .
	replace surveyed_school = 1 if surveyed_school_yes == 1 
	replace surveyed_school = 2 if surveyed_school_no == 1 
	
	//recode states for consistency with 2018 dataset 
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "ODISHA" if state_name == "ORISSA"
	replace state_name = "PUDUCHERRY" if state_name == "Puducherry"
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	foreach var in math_num_1_9 math_num_10_99 math_subtraction math_division {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = 1*math_num_1_9 + 2*math_num_10_99 + 3*math_subtraction + 4*math_division

	foreach var in read_letter read_word read_level_1 read_level_2 {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = 1*read_letter + 2*read_word + 3*read_level_1 + 4*read_level_2
	
	destring vlg_*, replace
	
	drop math_num_1_9 math_num_10_99 math_subtraction math_division read_letter read_word ///
	    read_level_1 read_level_2 read_nothing math_nothing aser* ///
		hh_electricity_conn_yes hh_electricity_conn_no  hh_tv_no hh_tv_yes ///
		hh_mobile_yes hh_mobile_no preschool_no kindergarton_yes bonus_* mother_gone_to_school_* ///
		father_gone_to_school_* hh_electricity_today_* hh_electricity_conn_* hh_toilet_* ///
		hh_cable_tv_* hh_tv_* hh_mobile* hh_computer_use_* surveyed_school_* ///
		tuition_school* tuition_yes tuition_no hh_dvd_* hh_newspaper_* hh_reading_material_* ///
		
	save ../output/clean_dta/household_2010, replace

	//2011
	use ../output/messy_dta/household_2011, clear 
	gen sample_year = .
	replace sample_year = 2009 if aser09 == 1 
	replace sample_year = 2010 if aser10 == 1 
	replace sample_year = 2011 if aser11 == 1
	
	destring school_class oos_*, replace
	
	rename hh_mobile hh_phone
	rename tuition_school_teacher tuition_govt_school
	
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mother_gone_to_school_yes == 1
	replace mother_gone_to_school = 2 if mother_gone_to_school_no == 1
	
	gen father_gone_to_school = .
	replace father_gone_to_school = 1 if father_gone_to_school_yes == 1
	replace father_gone_to_school = 2 if father_gone_to_school_no == 1
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}
	
	destring preschool_yes, gen(preschool_ind)
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)
	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind) 
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	//recode states for consistency with 2018 dataset 
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "Daman & Diu"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "ODISHA" if state_name == "ORISSA"
	replace state_name = "PUDUCHERRY" if state_name == "Pondicherry"
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	foreach var in math_num_1_9 math_num_10_99 math_subtraction math_division {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = 1*math_num_1_9 + 2*math_num_10_99 + 3*math_subtraction + 4*math_division

	foreach var in read_letter read_word read_level_1 read_level_2 {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = 1*read_letter + 2*read_word + 3*read_level_1 + 4*read_level_2
	
	drop math_num_1_9 math_num_10_99 math_subtraction math_division read_letter read_word ///
	    read_level_1 read_level_2 read_nothing math_nothing aser* hh_type ///
		preschool_yes kindergarton_yes mother_gone_to_school_* father_gone_to_school_* ///
	
	
	destring vlg_*, replace

	save ../output/clean_dta/household_2011, replace
	
	//2012 
	use ../output/messy_dta/household_2012, clear
	gen sample_year = .
	replace sample_year = 2010 if aser10 == 1 
	replace sample_year = 2011 if aser11 == 1 
	replace sample_year = 2012 if aser12 == 1
	
	destring school_class oos_*, replace
	
	rename hh_mobile hh_phone
	
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mother_gone_to_school_yes == 1
	replace mother_gone_to_school = 2 if mother_gone_to_school_no == 1
	
	gen father_gone_to_school = .
	replace father_gone_to_school = 1 if father_gone_to_school_yes == 1
	replace father_gone_to_school = 2 if father_gone_to_school_no == 1
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}

	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)
	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	//recode states for consistency with 2018 dataset 
    replace state_name = subinstr(state_name, `"""',  "", .)
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "ARUNACHAL PRADESH" if state_name == "Arunachal pardesh"
	replace state_name = "BIHAR" if state_name == "Bihar"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "JAMMU & KASHMIR" if state_name == "Jammu & Kashmir"
	replace state_name = "JHARKHAND" if state_name == "Jharkhand"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "MEGHALAYA" if state_name == "Meghalaya"
	replace state_name = "MIZORAM" if state_name == "Mizoram"
	replace state_name = "ODISHA" if state_name == "ORISSA"
	replace state_name = "PUDUCHERRY" if state_name == "Pondicherry"
	replace state_name = "SIKKIM" if state_name == "Sikkim"
	replace state_name = "TRIPURA" if state_name == "Tripura" 
	replace state_name = "UTTAR PRADESH" if state_name == "UP"
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, `"""',  "", .)
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	foreach var in math_num_1_9 math_num_10_99 math_subtraction math_division {
	    replace `var' = 0 if mi(`var')
	}
    gen math_code = 1*math_num_1_9 + 2*math_num_10_99 + 3*math_subtraction + 4*math_division

	foreach var in read_letter read_word read_level_1 read_level_2 {
	    replace `var' = 0 if mi(`var')
	}
	gen read_code = 1*read_letter + 2*read_word + 3*read_level_1 + 4*read_level_2
	
	foreach var in english_lowercase_letter english_uppercase_letter english_word english_sentence ///
	    english_comp_word english_comp_sentence {
	    replace `var' = 0 if mi(`var')
	}
	gen english_code = english_lowercase_letter + 2*english_uppercase_letter + ///
	    3*english_word + 4*english_sentence
	
	drop math_num_1_9 math_num_10_99 math_subtraction math_division read_letter read_word ///
	    read_level_1 read_level_2 read_nothing math_nothing aser* ///
		kindergarton_yes mother_gone_to_school_* father_gone_to_school_* english_nothing ///
		english_uppercase_letter english_lowercase_letter english_word english_sentence ///
	
	save ../output/clean_dta/household_2012, replace
	
	//2013
	use ../output/messy_dta/household_2013, clear
	gen sample_year = .
	replace sample_year = 2011 if aser11 == 1 
	replace sample_year = 2012 if aser12 == 1 
	replace sample_year = 2013 if aser13 == 1
	
	destring school_class oos_*, replace
	
	rename hh_mobile hh_phone
	
	gen mother_gone_to_school = .
	replace mother_gone_to_school = 1 if mother_gone_to_school_yes == 1
	replace mother_gone_to_school = 2 if mother_gone_to_school_no == 1
	
	gen father_gone_to_school = .
	replace father_gone_to_school = 1 if father_gone_to_school_yes == 1
	replace father_gone_to_school = 2 if father_gone_to_school_no == 1
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}

	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)
	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	//recode states for consistency with 2018 dataset 
    replace state_name = subinstr(state_name, `"""',  "", .)
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "ARUNACHAL PRADESH" if state_name == "Arunachal pardesh"
	replace state_name = "BIHAR" if state_name == "Bihar"
	replace state_name = "CHHATTISGARH" if state_name == "Chhattisgarh"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "JAMMU & KASHMIR" if state_name == "Jammu & Kashmir"
	replace state_name = "JHARKHAND" if state_name == "Jharkhand"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MAHARASHTRA" if state_name == "Maharashtra"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "MEGHALAYA" if state_name == "Meghalaya"
	replace state_name = "MIZORAM" if state_name == "Mizoram"
	replace state_name = "ODISHA" if state_name == "ORISSA"
	replace state_name = "PUDUCHERRY" if state_name == "Pondicherry"
	replace state_name = "PUNJAB" if state_name == "Punjab"
	replace state_name = "SIKKIM" if state_name == "Sikkim"
	replace state_name = "TAMIL NADU" if state_name == "TAMILNADU"
	replace state_name = "TRIPURA" if state_name == "Tripura" 
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, `"""',  "", .)
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	drop aser* kindergarton_yes mother_gone_to_school_* father_gone_to_school_* id
	
	destring vlg_*, replace
	
	save ../output/clean_dta/household_2013, replace
	
	//2014
	use ../output/messy_dta/household_2014, clear
	gen sample_year = .
	replace sample_year = 2012 if aser12 == 1 
	replace sample_year = 2013 if aser13 == 1 
	replace sample_year = 2014 if aser14 == 1
	
	destring school_class oos_*, replace
	
	rename hh_mobile hh_phone
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}

	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)

	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind)
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	qui ds vlg_*
	foreach var in `r(varlist)' {
		replace `var' = "1" if `var' == "Yes"
		replace `var' = "2" if `var' == "No"
		destring `var', replace
	}

	//recode states for consistency with 2018 dataset 
	replace state_name = "ANDHRA PRADESH" if state_name == "Andhra Pradesh"
	replace state_name = "ARUNACHAL PRADESH" if state_name == "Arunachal pardesh"
	replace state_name = "BIHAR" if state_name == "Bihar"
	replace state_name = "CHHATTISGARH" if state_name == "Chhattisgarh"
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	replace state_name = "GOA" if state_name == "Goa"
	replace state_name = "JAMMU & KASHMIR" if state_name == "Jammu & Kashmir"
	replace state_name = "JHARKHAND" if state_name == "Jharkhand"
	replace state_name = "KERALA" if state_name == "Kerala"
	replace state_name = "MAHARASHTRA" if state_name == "Maharashtra"
	replace state_name = "MANIPUR" if state_name == "Manipur"
	replace state_name = "MEGHALAYA" if state_name == "Meghalaya"
	replace state_name = "MIZORAM" if state_name == "Mizoram"
	replace state_name = "ODISHA" if state_name == "Orissa"
	replace state_name = "PUDUCHERRY" if state_name == "Pondicherry"
	replace state_name = "PUNJAB" if state_name == "Punjab"
	replace state_name = "SIKKIM" if state_name == "Sikkim"
	replace state_name = "TAMIL NADU" if state_name == "TAMILNADU"
	replace state_name = "TRIPURA" if state_name == "Tripura" 
	replace state_name = "UTTARAKHAND" if state_name == "UTTARANCHAL"
	
	replace district_name = subinstr(district_name, "   *",  "", .)
	replace district_name = subinstr(district_name, "  *",  "", .)
	replace district_name = subinstr(district_name, " *",  "", .)
	replace district_name = subinstr(district_name, "*",  "", .)
	
	replace district_name = strproper(district_name)
	
	drop aser* kindergarton_yes 
	
	save ../output/clean_dta/household_2014, replace
	
	//2016
	use ../output/messy_dta/household_2016, clear
	
	destring school_class oos_*, replace
	
	rename hh_mobile hh_phone

	rename preschool_yes preschool_ind
	replace preschool_ind = 0 if mi(preschool_ind)
	destring kindergarton_yes, gen(kinder_ind)
	replace kinder_ind = 0 if mi(kinder_ind)
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
	}
	
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)

	
	rename (school_govt school_private school_madarsa school_other) ///
	     (govt_ind pvt_ind madarsa_ind other_ind) 
	destring madarsa_ind other_ind, replace
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var')
	}
	
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	qui ds vlg_*
	foreach var in `r(varlist)' {
		replace `var' = "1" if `var' == "Yes"
		replace `var' = "2" if `var' == "No"
		destring `var', replace
	}
	
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
	
	drop kindergarton_yes 
	
	save ../output/clean_dta/household_2016, replace
	
	//2018
	use ../output/messy_dta/household_2018, clear
    gen sample_year = .
	replace sample_year = 2018 if aser18 == 2018
	replace sample_year = 2016 if aser18 == 2016
	rename hh_mobile hh_phone
	
	destring school_class oos_*, replace
	
	foreach var in father_class mother_class {
		tostring `var', replace
		replace `var' = "Bachelors Year 1" if `var' == "13"
		replace `var' = "Bachelors Year 2" if `var' == "14"
		replace `var' = "Bachelors Year 3" if `var' == "15"
		replace `var' = "Postgrad Year 1" if `var' == "16"
		replace `var' = "Postgrad Year 2" if `var' == "17"
		replace `var' = "Diploma" if `var' == "18"
		replace `var' = "ITI" if `var' == "19"
		replace `var' = "Polytechnic" if `var' == "20"
	}

	gen preschool_ind = . 
	replace preschool_ind = 0 if mi(preschool_type) | preschool_type == 2
	replace preschool_ind = 1 if preschool_type == 1
	gen kinder_ind = . 
	replace kinder_ind = 0 if mi(preschool_type) | preschool_type == 1
	replace kinder_ind = 1 if preschool_type == 2
	
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
	    gen `var' = .
	}
	replace govt_ind = 1 if school_type == 1 
	replace pvt_ind = 1 if school_type == 2
	replace madarsa_ind = 1 if school_type == 3
	replace other_ind = 1 if school_type == 4 
	foreach var in govt_ind pvt_ind madarsa_ind other_ind {
		replace `var' = 0 if mi(`var') & !mi(school_type)
	}

	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		gen `var' = . 
	}
	replace hhtype_katcha = 1 if hh_type == 1 
	replace hhtype_semi_katcha = 1 if hh_type == 2
	replace hhtype_pucca = 1 if hh_type == 3
	foreach var in hhtype_katcha hhtype_semi_katcha hhtype_pucca {
		replace `var' = 0 if mi(`var') & !mi(hh_type)
	}
	
	qui ds vlg_*
	foreach var in `r(varlist)' {
		replace `var' = "1" if `var' == "Yes"
		replace `var' = "2" if `var' == "No"
		destring `var', replace
	}
	
	replace state_name = "DNH & DD" if ///
	    state_name == "DADRA & NAGAR HAVELI" | state_name == "DAMAN & DIU"
		
	drop if school_class > 8 & !mi(school_class)
	drop if child_age == 3 | child_age == 4 | child_age == 5 
	drop if child_age > 14 & mi(school_class)
	drop if preschool_ind == 1 | kinder_ind == 1 
	drop if mi(child_age)
		
	drop aser18 
	
	save ../output/clean_dta/household_2018, replace
end 

program append_files
    clear
	foreach year in 2007 2008 2009 2010 2011 2012 2013 2014 2016 2018 {
		dis "`year'"
		qui append using ../output/clean_dta/household_`year', force
	}
	
	save ../output/messy_dta/cross_section, replace
end 

program clean_appended
    use ../output/messy_dta/cross_section, clear
	
    replace state_name = "ANDHRA PRADESH" if state_name == "TELANGANA"
	replace district_name = "Tarn Taran" if district_name == "Tarn-Taran" | district_name == "Tarn_Taran"
	replace district_name = "Janjgir Champa" if ///
	    district_name == "Janjgir _ Champa" | district_name == "Janjgir_Champa" | ///
		district_name == "Janjgir - Champa"
	foreach name in North South East West {
		replace district_name = "`name' District" if district_name == "`name'"
	}
	replace district_name = "North District" if district_name == "North  District"
	
    drop if state_name == "PUDUCHERRY" | state_name == "UTTARAKHAND" //treatment time unknown
	
	drop state_code district_code village_code hh_id child_no hh_no id preschool_no id hh_type
	
    replace schtype_gender = . if schtype_gender == 0 
	foreach var in schtype_coed schtype_boys schtype_girls {
	     gen `var' = 0
	}
	replace schtype_coed = 1 if schtype_gender == 1
	replace schtype_boys = 1 if schtype_gender == 2
	replace schtype_girls = 1 if schtype_gender == 3
	drop schtype_gender
	 
	rename child_gender girl_ind
	replace girl_ind = 0 if girl_ind == 1 
	replace girl_ind = 1 if girl_ind == 2
	 
	destring oos_dropout_class, replace
	replace oos_dropout_class = . if oos_dropout_class == 99 | oos_dropout_class == 13 ///
	    | oos_dropout_class == 14 | oos_dropout_class == 0
	 
	foreach var in english_comp_word english_comp_sentence {
	    replace `var' = . if `var' == 0 
	}
	replace english_comp_word = 0 if english_comp_word == 2
	replace english_comp_sentence = 0 if english_comp_sentence == 2
	
	rename hh_no_animal no_livestock_ind 
	replace no_livestock_ind = 0 if mi(no_livestock_ind)

	replace hh_no_vehic = 0 if mi(hh_no_vehic) & year == 2009
	replace hh_no_vehic = hh_no_vehic + 1 if !mi(hh_no_vehic)
	replace hh_motor_vehicle = hh_no_vehic if mi(hh_motor_vehicle)
	drop hh_no_vehicle
	
	destring hh_three_wheeler hh_four_wheeler hh_tractor, replace
	
	qui ds mother_gone_to_school father_gone_to_school tuition vlg_* hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle mother_read_level_1 
		
	foreach var in `r(varlist)' {
		dis "`var'"
	    replace `var' = 0 if `var' == 2 
	}
	
	replace hh_multiplier = trunc(hh_multiplier) //round multiplier in order to weight in collapse()
	
	save ../output/clean_dta/cross_section, replace

	bysort district_name (year): egen impute_hhtype = mean(hhtype_pucca)
	bysort district_name (year): egen impute_elec_conn = mean(hh_electricity_conn)
	bysort district_name (year): egen impute_elec_today = mean(hh_electricity_today)
	bysort district_name (year): egen impute_tv = mean(hh_tv)
	bysort district_name (year): egen impute_phone = mean(hh_phone)
	ds impute_*
	foreach var in `r(varlist)' {
		replace `var' = . if year != 2008
	}
	keep impute* district_name year
	duplicates drop
	drop if year != 2008
	replace year = 2007
	merge 1:m district_name year using ../output/clean_dta/cross_section, assert(1 2 3) keep(2 3) nogen
		
	replace hhtype_pucca = impute_hhtype if year == 2007
	replace hh_electricity_conn = impute_elec_conn if year == 2007
	replace hh_electricity_today = impute_elec_today if year == 2007
	replace hh_tv = impute_tv if year == 2007
	replace hh_phone = impute_phone if year == 2007
	
	save ../output/clean_dta/cross_section, replace
	
	bysort district_name (year): egen impute_toilet = mean(hh_toilet)
	replace impute_toilet = . if year != 2009
	keep impute_toilet district_name year
	duplicates drop
	drop if year != 2009
	expand 2, gen(tag)
	replace year = 2008 if tag == 0
	replace year = 2007 if tag == 1
	drop tag
	save ../temp/impute, replace
	merge 1:m district_name year using ../output/clean_dta/cross_section, assert(1 2 3) keep(2 3) nogen
	
	replace hh_toilet = impute_toilet if year == 2007 | year == 2008
	
	save ../output/clean_dta/cross_section, replace
	
	bysort district_name (year): egen impute_comp = mean(hh_computer_use)
	bysort district_name (year): egen impute_news = mean(hh_newspaper)
	bysort district_name (year): egen impute_read = mean(hh_reading_material)
	foreach var in impute_comp impute_news impute_read {
		replace `var' = . if year != 2010
	}
    keep impute_comp impute_news impute_read district_name year
	duplicates drop
	drop if year != 2010
	expand 2, gen(tag)
	replace year = 2007 if tag == 0 
	replace year = 2008 if tag == 1 
	drop tag 
	expand 2 if year==2008, gen(tag)
	replace year = 2009 if tag == 1 
	drop tag
	save ../temp/impute, replace
	merge 1:m district_name year using ../output/clean_dta/cross_section, assert(1 2 3) keep(2 3) nogen
	
	replace hh_computer_use = impute_comp if year == 2007 | year == 2008 | year == 2009
	replace hh_newspaper = impute_news if year == 2007 | year == 2008 | year == 2009
	replace hh_reading_material = impute_read if year == 2007 | year == 2008 | year == 2009
	
	save ../output/clean_dta/cross_section, replace
	
	egen temp = rowtotal(hh_motor_veh_*)
	replace hh_motor_vehicle = 1 if temp == 1 | temp == 2
	replace hh_motor_vehicle = 0 if temp == 3 | temp == 4
	bysort district_name (year): egen impute_mv = mean(hh_motor_vehicle)
	replace impute_mv = . if year != 2012 & year != 2009 & year != 2014
	keep impute_mv district_name year
	duplicates drop
	drop if year != 2014 & year != 2012 & year != 2009
	expand 2, gen(tag)
	replace year = 2007 if tag == 0 & year == 2009
	replace year = 2008 if tag == 1 & year == 2009
	replace year = 2010 if tag == 0 & year == 2012
	replace year = 2011 if tag == 1 & year == 2012
	replace year = 2016 if tag == 0 & year == 2014
	replace year = 2018 if tag == 1 & year == 2014
	drop tag 
	save ../temp/impute, replace
	merge 1:m district_name year using ../output/clean_dta/cross_section, assert(1 2 3) keep(2 3) nogen
	
	replace hh_motor_vehicle = impute_mv if ///
	    year == 2007 | year == 2008 | year == 2010 | year == 2011 | year == 2016 | year == 2018
	
	 gen hh_SES = hhtype_pucca + hh_electricity_conn + hh_tv + hh_phone + hh_toilet ///
	      + hh_computer + hh_newspaper + hh_reading_material + hh_motor_vehicle
	
	bysort state_name district_name: egen timeframe = nvals(year) //how many years is each district in the data?
	
	qui ds hhtype_pucca hh_electricity_conn hh_tv hh_phone hh_toilet hh_computer hh_newspaper ///
	    hh_reading_material hh_motor_vehicle 
	eststo hh_SES_full: qui estpost sum `r(varlist)'
	eststo hh_SES_trim: qui estpost sum `r(varlist)' if timeframe == 10
	esttab hh_SES_full hh_SES_trim using ../output/hhSES_stats.tex, replace cells("mean sd") nonumbers 

	drop if timeframe != 10 //create balanced district-level panel
	
    egen schtype_missing = rowtotal(govt_ind pvt_ind madarsa_ind other_ind)
	
	//open enrollment definition - either schtype_missing == 0 or mi(school_class)
	gen enrolled_ind_open = 1
	replace enrolled_ind_open = 0 if mi(school_class) | schtype_missing == 0 
	
	//restricted enrollment definition - must be missing both, and all other students are considered enrolled
	gen enrolled_ind_restrict = 1 
	replace enrolled_ind_restrict = 0 if mi(school_class) & schtype_missing == 0 
	
	//most restricted enrollment def - must be missing both, and enrolled students must have both nonmissing
	gen enrolled_ind_most_restrict = .
	replace enrolled_ind_most_restrict = 0 if mi(school_class) & schtype_missing == 0 
	replace enrolled_ind_most_restrict = 1 if !mi(school_class) & schtype_missing == 1 
	
	//FINISH by making a government enrollment and private enrollment variable 
	
	
	//ASER enrollment measure 
// 	rename schtype_missing enrolled_ind
//
// 	gen enrolled_ind_neha = . 
// 	replace enrolled_ind_neha = 0 if mi(school_class) | oos_dropout == 1 | oos_never_enr == 1 
// 	replace enrolled_ind_neha = 1 if enrolled_ind_neha == . 
//	
// 	//sas = Shah and Steinberg measure of enrollment
// 	gen enrolled_ind_sas = .
// 	replace enrolled_ind_sas = 0 if oos_never_enr == 1 | oos_dropout == 1
// 	replace enrolled_ind_sas = 1 if mi(oos_never_enr) & mi(oos_dropout)
	
	preserve
	    use ../../../shared_data/NSS_enrollment, clear
        eststo NSS: estpost tabstat enrolled_ind, by(State) stat(mean) nototal
 		eststo NSSgirls: estpost tabstat enrolled_ind if girl_ind == 1, by(State) stat(mean) nototal
 		eststo NSSboys: estpost tabstat enrolled_ind if girl_ind == 0, by(State) stat(mean) nototal
		eststo NSSallstates: estpost tabstat enrolled_ind, stat(mean) 
		eststo NSSallstates_girls: estpost tabstat enrolled_ind if girl_ind == 1, stat(mean) 
		eststo NSSallstates_boys: estpost tabstat enrolled_ind if girl_ind == 0, stat(mean) 
	restore 
	
	eststo ASER: estpost tabstat enrolled_ind enrolled_ind_sas if year == 2011, ///
	    by(state_name) stat(mean) nototal
 	eststo ASERgirls: ///
	    estpost tabstat enrolled_ind enrolled_ind_sas if girl_ind == 1 & year == 2011, ///
		by(state_name) stat(mean) nototal
 	eststo ASERboys: ///
	    estpost tabstat enrolled_ind enrolled_ind_sas if girl_ind == 0 & year == 2011, ///
		by(state_name) stat(mean) nototal
	eststo ASERallstates: ///
	    estpost tabstat enrolled_ind enrolled_ind_sas if year == 2011, stat(mean)
	eststo ASERallstates_girls: ///
	    estpost tabstat enrolled_ind enrolled_ind_sas if girl_ind == 1 & year == 2011, stat(mean)
	eststo ASERallstates_boys: ///
	    estpost tabstat enrolled_ind enrolled_ind_sas if girl_ind == 0 & year == 2011, stat(mean)
	
	esttab NSS ASER using ../output/enrollment_measures.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 	
	esttab NSSgirls ASERgirls using ../output/enrollment_measures_girls.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 
	esttab NSSboys ASERboys using ../output/enrollment_measures_boys.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 
	esttab NSSallstates ASERallstates using ../output/total_enroll.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 
	esttab NSSallstates_girls ASERallstates_girls using ../output/total_enroll_girls.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 
	esttab NSSallstates_boys ASERallstates_boys using ../output/total_enroll_boys.tex, ///
	    replace cells("Mean enrolled_ind enrolled_ind_sas") nonumbers 
	
	preserve 
	    centile hh_SES, centile(25) 
        local bound = r(c_1)
        drop if hh_SES <= `bound'
		qui ds hhtype_pucca hh_electricity_conn hh_tv hh_phone hh_toilet hh_computer hh_newspaper ///
	    hh_reading_material hh_motor_vehicle 
		eststo hh_SES_75: qui estpost sum `r(varlist)'
	restore 
	preserve 
	    centile hh_SES, centile(25) 
        local bound = r(c_1)
        keep if hh_SES <= `bound'
		qui ds hhtype_pucca hh_electricity_conn hh_tv hh_phone hh_toilet hh_computer hh_newspaper ///
	    hh_reading_material hh_motor_vehicle 
		eststo hh_SES_25: qui estpost sum `r(varlist)'
	restore 
	esttab hh_SES_75 hh_SES_25 using ../output/hhSES_pct_stats.tex, replace cells("mean sd") nonumbers 	
end 

program collapse_datasets
	preserve 
	    drop if girl_ind == 0 
		collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
		save ../output/clean_dta/cross_section_girls_mean, replace
	restore 
	
	preserve 
	    drop if girl_ind == 1 
		collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
		save ../output/clean_dta/cross_section_boys_mean, replace
	restore 
	
	preserve 
	    centile hh_SES, centile(25) 
        local bound = r(c_1)
        drop if hh_SES > `bound' //keep bottom 25% 
		collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
		save ../output/clean_dta/cross_section_lowSES_mean, replace
	restore 
	
	preserve 
	    centile hh_SES, centile(25) 
        local bound = r(c_1)
        drop if hh_SES < `bound' //keep top 75% as complement for lowSES 
		collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
		save ../output/clean_dta/cross_section_remainderSES_mean, replace
	restore 
	
	preserve
	drop if state_name == "SIKKIM" | state_name == "MEGHALAYA" | state_name == "NAGALAND"
	collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
	save ../output/clean_dta/cross_section_noSmall_mean, replace
	restore 
	
	preserve
	collapse (firstnm) state_name (mean) enrolled_ind* total_member child_age mother_age father_age ///
	    school_class oos_dropout_class english_comp* mother_gone_to_school father_gone_to_school tuition ///
		no_livestock_ind hh_goat_lamb hh_cows_buffalo hh_other_animals vlg_*  hh_electricity_* ///
	    hh_tv hh_phone hh_toilet hh_cable_tv hh_computer_use hh_dvd hh_newspaper ///
		hh_reading_material hh_motor_vehicle hh_three_wheeler hh_four_wheeler hh_tractor ///
		mother_read_level_1 govt_ind pvt_ind madarsa_ind other_ind hhtype_* hh_SES ///
		[fweight = hh_multiplier], by(district_name year) 
	save ../output/clean_dta/cross_section_mean, replace
	restore 
end 


program trim_strings
    ds, has(type string)
    local string_vars = r(varlist)
    foreach var in `string_vars' {
        replace `var' = strtrim(`var')
    }
    compress
end

program convert_to_int
    ds
    local string_vars = r(varlist)
    foreach var in `string_vars' {
        //if "`:type `var''" != "string" {
            //continue
        //}
        local length = strlen(`var')
        di "`var'"
        if `length' < 16 {
            gen `var'_r = real(`var')
            sum `var'_r, d
            count if !mi(`var'_r)
            local nonmiss = `r(N)'
            count
            local N = `r(N)'
            local nonmissing_pct = `nonmiss'/`N'
            if `nonmissing_pct' >= 0.05 {
                destring `var', replace
            }
            drop `var'_r
        }
    } 
    compress
end 

program clear_temp
    local wd ../temp
    cd `wd'
    local datafiles: dir "`wd'" files "*.dta"
    foreach datafile of local datafiles {
	    rm `datafile'
    }
end 


*Execute 
main