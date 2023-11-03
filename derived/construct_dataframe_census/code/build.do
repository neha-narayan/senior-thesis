capture log close 
log using build.log, replace
clear all
set more off

//raw points to the census files
global raw "C:\Users\Neha Narayan\Desktop\GitHub\senior-thesis\raw\Census"

program main
//     import_sheets
// 	combine_sheets
// 	calculate_population
	calculate_population_2011only
end 

program import_sheets
    import excel "${raw}\DDW-0000C-14.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt
	save ../output/total2011, replace
	
	import excel "${raw}\DDW-0000C-14SC.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt
	rename (TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales) ///
	    (TotalSCPersons TotalSCMales TotalSCFemales RuralSCPersons RuralSCMales RuralSCFemales) 
	rename (UrbanPersons UrbanMales UrbanFemales) (UrbanSCPersons UrbanSCMales UrbanSCFemales)
	save ../output/SC2011, replace
	
	import excel "${raw}\DDW-0000C-14ST.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt
	rename (TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales) ///
	    (TotalSTPersons TotalSTMales TotalSTFemales RuralSTPersons RuralSTMales RuralSTFemales) 
	rename (UrbanPersons UrbanMales UrbanFemales) (UrbanSTPersons UrbanSTMales UrbanSTFemales)
	save ../output/ST2011, replace
	
	import excel "${raw}\PC01_C14_00.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt Tehsil P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM
	save ../output/total2001, replace
	
	import excel "${raw}\PC01_C14_SC_00.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt Tehsil P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM
	rename (TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales) ///
	    (TotalSCPersons TotalSCMales TotalSCFemales RuralSCPersons RuralSCMales RuralSCFemales) 
	rename (UrbanPersons UrbanMales UrbanFemales) (UrbanSCPersons UrbanSCMales UrbanSCFemales)
	save ../output/SC2001, replace
	
	import excel "${raw}\PC01_C14_ST_00.xls", sheet("Sheet1") firstrow allstring clear
	keep if ///
	    Agegroup == "All ages" | Agegroup == "0-4" | Agegroup == "5-9" | ///
		Agegroup == "10-14" | Agegroup =="15-19" | Agegroup =="20-24"
	drop Table State Distt Tehsil P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM
	rename (TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales) ///
	    (TotalSTPersons TotalSTMales TotalSTFemales RuralSTPersons RuralSTMales RuralSTFemales) 
	rename (UrbanPersons UrbanMales UrbanFemales) (UrbanSTPersons UrbanSTMales UrbanSTFemales)
	save ../output/ST2001, replace
end 

program combine_sheets
    use ../output/total2011, clear
	merge 1:1 AreaName Agegroup using ../output/SC2011, assert(1 2 3) gen(merge_sc) keep(1 3) 
	merge 1:1 AreaName Agegroup using ../output/ST2011, assert(1 2 3) gen(merge_st) keep(1 3)
	drop merge_sc merge_st
	egen agegroup = group(Agegroup)
	drop Agegroup
	qui ds AreaName agegroup, not
	reshape wide `r(varlist)', i(AreaName) j(agegroup)
	foreach var in TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales ///
	    UrbanPersons UrbanMales UrbanFemales TotalSCPersons TotalSCMales TotalSCFemales ///
		RuralSCPersons RuralSCMales RuralSCFemales UrbanSCPersons UrbanSCMales UrbanSCFemales ///
		TotalSTPersons TotalSTMales TotalSTFemales RuralSTPersons RuralSTMales RuralSTFemales ///
		UrbanSTPersons UrbanSTMales UrbanSTFemales  {
			rename `var'1 `var'_allages_11
			rename `var'2 `var'_0to4_11
			rename `var'3 `var'_5to9_11
			rename `var'4 `var'_10to14_11
			rename `var'5 `var'_15to19_11
			rename `var'6 `var'_20to24_11
	}
	replace AreaName = "Andaman & Nicobar Islands" if ///
	    AreaName == "State - ANDAMAN & NICOBAR ISLANDS (35)"
	replace AreaName = "Andhra Pradesh" if AreaName == "State - ANDHRA PRADESH (28)"
	replace AreaName = "Arunachal Pradesh" if AreaName == "State - ARUNACHAL PRADESH (12)"
	replace AreaName = "Assam" if AreaName == "State - ASSAM (18)"
	replace AreaName = "Bihar" if AreaName == "State - BIHAR (10)"
	replace AreaName = "Chandigarh" if AreaName == "State - CHANDIGARH (04)"
	replace AreaName = "Chhattisgarh" if AreaName == "State - CHHATTISGARH (22)"
	replace AreaName =  "DNH & DD" if ///
	    AreaName == "State - DADRA & NAGAR HAVELI (26)" | AreaName == "State - DAMAN & DIU (25)"
	replace AreaName = "Goa" if AreaName == "State - GOA (30)"
	replace AreaName = "Gujarat" if AreaName == "State - GUJARAT (24)"
	replace AreaName = "Haryana" if AreaName == "State - HARYANA (06)"
	replace AreaName = "Himachal Pradesh" if AreaName == "State - HIMACHAL PRADESH (02)"
	replace AreaName = "Jammu & Kashmir" if AreaName == "State - JAMMU & KASHMIR (01)"
	replace AreaName = "Jharkhand" if AreaName == "State - JHARKHAND (20)"
	replace AreaName = "Karnataka" if AreaName == "State - KARNATAKA (29)"
	replace AreaName = "Kerala" if AreaName == "State - KERALA (32)"
	replace AreaName = "Lakshadweep" if AreaName == "State - LAKSHADWEEP (31)"
	replace AreaName = "Madhya Pradesh" if AreaName == "State - MADHYA PRADESH (23)"
	replace AreaName = "Maharashtra" if AreaName == "State - MAHARASHTRA (27)"
	replace AreaName = "Manipur" if AreaName == "State - MANIPUR (14)"
	replace AreaName = "Meghalaya" if AreaName == "State - MEGHALAYA (17)"
	replace AreaName = "Mizoram" if AreaName == "State - MIZORAM (15)" 
	replace AreaName = "Nagaland" if AreaName == "State - NAGALAND (13)"
	replace AreaName = "Delhi" if AreaName == "State - NCT OF DELHI (07)"
	replace AreaName = "Odisha" if AreaName == "State - ODISHA (21)"
	replace AreaName = "Puducherry" if AreaName == "State - PUDUCHERRY (34)"
	replace AreaName = "Punjab" if AreaName == "State - PUNJAB (03)"
	replace AreaName = "Rajasthan" if AreaName == "State - RAJASTHAN (08)"
	replace AreaName = "Sikkim" if AreaName == "State - SIKKIM (11)"
	replace AreaName = "Tamil Nadu" if AreaName == "State - TAMIL NADU (33)"
	replace AreaName = "Tripura" if AreaName == "State - TRIPURA (16)"
	replace AreaName = "Uttar Pradesh" if AreaName == "State - UTTAR PRADESH (09)"
	replace AreaName = "Uttarakhand" if AreaName == "State - UTTARAKHAND (05)"
	replace AreaName = "West Bengal" if AreaName == "State - WEST BENGAL (19)"
	qui ds AreaName, not
	destring `r(varlist)', replace
	qui ds AreaName, not
	collapse (sum) `r(varlist)', by(AreaName)
	save ../output/allpops2011, replace

	use ../output/total2001, clear
	merge 1:1 AreaName Agegroup using ../output/SC2001, assert(1 2 3) gen(merge_sc) keep(1 3)
	merge 1:1 AreaName Agegroup using ../output/ST2001, assert(1 2 3) gen(merge_st) keep(1 3)
	drop merge_sc merge_st
	egen agegroup = group(Agegroup)
	drop Agegroup
	qui ds AreaName agegroup, not
	reshape wide `r(varlist)', i(AreaName) j(agegroup)
	foreach var in TotalPersons TotalMales TotalFemales RuralPersons RuralMales RuralFemales ///
	    UrbanPersons UrbanMales UrbanFemales TotalSCPersons TotalSCMales TotalSCFemales ///
		RuralSCPersons RuralSCMales RuralSCFemales UrbanSCPersons UrbanSCMales UrbanSCFemales ///
		TotalSTPersons TotalSTMales TotalSTFemales RuralSTPersons RuralSTMales RuralSTFemales ///
		UrbanSTPersons UrbanSTMales UrbanSTFemales  {
			rename `var'1 `var'_allages_01
			rename `var'2 `var'_0to4_01
			rename `var'3 `var'_5to9_01
			rename `var'4 `var'_10to14_01
			rename `var'5 `var'_15to19_01
			rename `var'6 `var'_20to24_01
	}
	replace AreaName = strproper(AreaName)
	replace AreaName = "Odisha" if AreaName == "Orissa"
	replace AreaName = "Puducherry" if AreaName == "Pondicherry"
	replace AreaName = "Uttarakhand" if AreaName == "Uttaranchal"
	replace AreaName = "DNH & DD" if AreaName == "Dadra & Nagar Haveli" | AreaName == "Daman & Diu"
	qui ds AreaName, not
	destring `r(varlist)', replace
	qui ds AreaName, not
	collapse (sum) `r(varlist)', by(AreaName)
	save ../output/allpops2001, replace
	
	use ../output/allpops2011, clear
	merge 1:1 AreaName using ../output/allpops2001, assert(1 2 3) keep()
	drop _merge 
	save ../output/fullcensus, replace
	
end 	
	
program calculate_population
    use ../output/fullcensus, clear
	gen total_1 = 0.201705289*TotalPersons_10to14_01 + 0.199074661*TotalPersons_5to9_01 + ///
	    0.199059085*TotalPersons_5to9_01 + 0.200144779*TotalPersons_5to9_01 + 0.200887226*TotalPersons_5to9_01
	gen women_01 = 0.201705289*TotalFemales_10to14_01 + 0.199074661*TotalFemales_5to9_01 + ///
	    0.199059085*TotalFemales_5to9_01 + 0.200144779*TotalFemales_5to9_01 + 0.200887226*TotalFemales_5to9_01
	gen men_01  = 0.201705289*TotalMales_10to14_01 + 0.199074661*TotalMales_5to9_01 + ///
	    0.199059085*TotalMales_5to9_01 + 0.200144779*TotalMales_5to9_01 + 0.200887226*TotalMales_5to9_01
	gen rural_01 = 0.201705289*RuralPersons_10to14_01 + 0.199074661*RuralPersons_5to9_01 + ///
	    0.199059085*RuralPersons_5to9_01 + 0.200144779*RuralPersons_5to9_01 + 0.200887226*RuralPersons_5to9_01
	gen ST_01 =  0.201705289*TotalSTPersons_10to14_01 + 0.199074661*TotalSTPersons_5to9_01 + ///
	    0.199059085*TotalSTPersons_5to9_01 + 0.200144779*TotalSTPersons_5to9_01 + 0.200887226*TotalSTPersons_5to9_01
	gen SC_01 = 0.201705289*TotalSCPersons_10to14_01 + 0.199074661*TotalSCPersons_5to9_01 + ///
	    0.199059085*TotalSCPersons_5to9_01 + 0.200144779*TotalSCPersons_5to9_01 + 0.200887226*TotalSCPersons_5to9_01
	
	gen total_2 = TotalPersons_5to9_01
	gen women_02 = TotalFemales_5to9_01
	gen men_02 = TotalMales_5to9_01
	gen rural_02 = RuralPersons_5to9_01
	gen ST_02 = TotalSTPersons_5to9_01
	gen SC_02 = TotalSCPersons_5to9_01
	
	gen total_3 = 0.199059085*TotalPersons_5to9_01 + 0.200144779*TotalPersons_5to9_01 + ///
	    0.200887226*TotalPersons_5to9_01 + 0.200834249*TotalPersons_5to9_01 + 0.198830636*TotalPersons_0to4_01
	gen women_03 = 0.199059085*TotalFemales_5to9_01 + 0.200144779*TotalFemales_5to9_01 + ///
	    0.200887226*TotalFemales_5to9_01 + 0.200834249*TotalFemales_5to9_01 + 0.198830636*TotalFemales_0to4_01
	gen men_03 = 0.199059085*TotalMales_5to9_01 + 0.200144779*TotalMales_5to9_01 + ///
	    0.200887226*TotalMales_5to9_01 + 0.200834249*TotalMales_5to9_01 + 0.198830636*TotalMales_0to4_01
	gen rural_03 = 0.199059085*RuralPersons_5to9_01 + 0.200144779*RuralPersons_5to9_01 + ///
	    0.200887226*RuralPersons_5to9_01 + 0.200834249*RuralPersons_5to9_01 + 0.198830636*RuralPersons_0to4_01
	gen ST_03 = 0.199059085*TotalSTPersons_5to9_01 + 0.200144779*TotalSTPersons_5to9_01 + ///
	    0.200887226*TotalSTPersons_5to9_01 + 0.200834249*TotalSTPersons_5to9_01 + ///
		0.198830636*TotalSTPersons_0to4_01
	gen SC_03 = 0.199059085*TotalSCPersons_5to9_01 + 0.200144779*TotalSCPersons_5to9_01 + ///
	    0.200887226*TotalSCPersons_5to9_01 + 0.200834249*TotalSCPersons_5to9_01 + ///
		0.198830636*TotalSCPersons_0to4_01
	
	gen total_4 = 0.200144779*TotalPersons_5to9_01 + 0.200887226*TotalPersons_5to9_01 + ///
	    0.200834249*TotalPersons_5to9_01 + 0.198830636*TotalPersons_0to4_01 + 0.199107848*TotalPersons_0to4_01
	gen women_04 = 0.200144779*TotalFemales_5to9_01 + 0.200887226*TotalFemales_5to9_01 + ///
	    0.200834249*TotalFemales_5to9_01 + 0.198830636*TotalFemales_0to4_01 + 0.199107848*TotalFemales_0to4_01
	gen men_04 = 0.200144779*TotalMales_5to9_01 + 0.200887226*TotalMales_5to9_01 + ///
	    0.200834249*TotalMales_5to9_01 + 0.198830636*TotalMales_0to4_01 + 0.199107848*TotalMales_0to4_01
	gen rural_04 = 0.200144779*RuralPersons_5to9_01 + 0.200887226*RuralPersons_5to9_01 + ///
	    0.200834249*RuralPersons_5to9_01 + 0.198830636*RuralPersons_0to4_01 + 0.199107848*RuralPersons_0to4_01
	gen ST_04 = 0.200144779*TotalSTPersons_5to9_01 + 0.200887226*TotalSTPersons_5to9_01 + ///
	    0.200834249*TotalSTPersons_5to9_01 + 0.198830636*TotalSTPersons_0to4_01 + ///
		0.199107848*TotalSTPersons_0to4_01
	gen SC_04 = 0.200144779*TotalSCPersons_5to9_01 + 0.200887226*TotalSCPersons_5to9_01 + ///
	    0.200834249*TotalSCPersons_5to9_01 + 0.198830636*TotalSCPersons_0to4_01 + ///
		0.199107848*TotalSCPersons_0to4_01
	
	gen total_5 = 0.200887226*TotalPersons_5to9_01 + 0.200834249*TotalPersons_5to9_01 + ///
	    0.198830636*TotalPersons_0to4_01 + 0.199107848*TotalPersons_0to4_01 + 0.198999054*TotalPersons_0to4_01
	gen women_05 = 0.200887226*TotalFemales_5to9_01 + 0.200834249*TotalFemales_5to9_01 + ///
	    0.198830636*TotalFemales_0to4_01 + 0.199107848*TotalFemales_0to4_01 + 0.198999054*TotalFemales_0to4_01
	gen men_05 = 0.200887226*TotalMales_5to9_01 + 0.200834249*TotalMales_5to9_01 + ///
	    0.198830636*TotalMales_0to4_01 + 0.199107848*TotalMales_0to4_01 + 0.198999054*TotalMales_0to4_01
	gen rural_05 = 0.200887226*RuralPersons_5to9_01 + 0.200834249*RuralPersons_5to9_01 + ///
	    0.198830636*RuralPersons_0to4_01 + 0.199107848*RuralPersons_0to4_01 + 0.198999054*RuralPersons_0to4_01
	gen ST_05 = 0.200887226*TotalSTPersons_5to9_01 + 0.200834249*TotalSTPersons_5to9_01 + ///
	    0.198830636*TotalSTPersons_0to4_01 + 0.199107848*TotalSTPersons_0to4_01 + ///
		0.198999054*TotalSTPersons_0to4_01
	gen SC_05 = 0.200887226*TotalSCPersons_5to9_01 + 0.200834249*TotalSCPersons_5to9_01 + ///
	    0.198830636*TotalSCPersons_0to4_01 + 0.199107848*TotalSCPersons_0to4_01 + ///
		0.198999054*TotalSCPersons_0to4_01
	
    gen total_6 = 0.200834249*TotalPersons_5to9_01 + 0.198830636*TotalPersons_0to4_01 + ///
	    0.199107848*TotalPersons_0to4_01 + 0.198999054*TotalPersons_0to4_01 + 0.200732943*TotalPersons_0to4_01
	gen women_06 = 0.200834249*TotalFemales_5to9_01 + 0.198830636*TotalFemales_0to4_01 + ///
	    0.199107848*TotalFemales_0to4_01 + 0.198999054*TotalFemales_0to4_01 + 0.200732943*TotalFemales_0to4_01
	gen men_06 = 0.200834249*TotalMales_5to9_01 + 0.198830636*TotalMales_0to4_01 + ///
	    0.199107848*TotalMales_0to4_01 + 0.198999054*TotalMales_0to4_01 + 0.200732943*TotalMales_0to4_01
	gen rural_06 = 0.200834249*RuralPersons_5to9_01 + 0.198830636*RuralPersons_0to4_01 + ///
	    0.199107848*RuralPersons_0to4_01 + 0.198999054*RuralPersons_0to4_01 + 0.200732943*RuralPersons_0to4_01
	gen ST_06 = 0.200834249*TotalSTPersons_5to9_01 + 0.198830636*TotalSTPersons_0to4_01 + ///
	    0.199107848*TotalSTPersons_0to4_01 + 0.198999054*TotalSTPersons_0to4_01 + ///
		0.200732943*TotalSTPersons_0to4_01
	gen SC_06 = 0.200834249*TotalSCPersons_5to9_01 + 0.198830636*TotalSCPersons_0to4_01 + ///
	    0.199107848*TotalSCPersons_0to4_01 + 0.198999054*TotalSCPersons_0to4_01 + ///
		0.200732943*TotalSCPersons_0to4_01

	gen total_7 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*TotalPersons_5to9_01 + ///
	    TotalPersons_0to4_01
	gen women_07 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*TotalFemales_5to9_01 + ///
	    TotalFemales_0to4_01
	gen men_07 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*TotalMales_5to9_01 + ///
	    TotalMales_0to4_01
	gen rural_07 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*RuralPersons_5to9_01 + ///
	    RuralPersons_0to4_01
	gen ST_07 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*TotalSTPersons_5to9_01 + ///
	    TotalSTPersons_0to4_01
	gen SC_07 = (0.199059085 + 0.200144779 + 0.200887226 + 0.200834249)*TotalSCPersons_5to9_01 + ///
	    TotalSCPersons_0to4_01
	
	gen total_8 = (0.200144779 + 0.200887226 + 0.200834249)*TotalPersons_5to9_01 + ///
	    TotalPersons_0to4_01 + 0.204670205*TotalPersons_5to9_11
	gen women_08 = (0.200144779 + 0.200887226 + 0.200834249)*TotalFemales_5to9_01 + ///
	    TotalFemales_0to4_01 + 0.204670205*TotalFemales_5to9_11
	gen men_08 = (0.200144779 + 0.200887226 + 0.200834249)*TotalMales_5to9_01 + ///
	    TotalMales_0to4_01 + 0.204670205*TotalMales_5to9_11
	gen rural_08 = (0.200144779 + 0.200887226 + 0.200834249)*RuralPersons_5to9_01 + ///
	    RuralPersons_0to4_01 + 0.204670205*RuralPersons_5to9_11
	gen ST_08 = (0.200144779 + 0.200887226 + 0.200834249)*TotalSTPersons_5to9_01 + ///
	    TotalSTPersons_0to4_01 + 0.204670205*TotalSTPersons_5to9_11
	gen SC_08 = (0.200144779 + 0.200887226 + 0.200834249)*TotalSCPersons_5to9_01 + ///
	    TotalSCPersons_0to4_01 + 0.204670205*TotalSCPersons_5to9_11
	
	gen total_9 = (0.200887226 + 0.200834249)*TotalPersons_5to9_01 + TotalPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422)*TotalPersons_5to9_11
	gen women_09 = (0.200887226 + 0.200834249)*TotalFemales_5to9_01 + TotalFemales_0to4_01 + ///
	    (0.204670205 + 0.202585422)*TotalFemales_5to9_11
	gen men_09 = (0.200887226 + 0.200834249)*TotalMales_5to9_01 + TotalMales_0to4_01 + ///
	    (0.204670205 + 0.202585422)*TotalMales_5to9_11
	gen rural_09 = (0.200887226 + 0.200834249)*RuralPersons_5to9_01 + RuralPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422)*RuralPersons_5to9_11
	gen ST_09 = (0.200887226 + 0.200834249)*TotalSTPersons_5to9_01 + TotalSTPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422)*TotalSTPersons_5to9_11
	gen SC_09 = (0.200887226 + 0.200834249)*TotalSCPersons_5to9_01 + TotalSCPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422)*TotalSCPersons_5to9_11
	
	gen total_10 = 0.200834249*TotalPersons_5to9_01 + TotalPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*TotalPersons_5to9_11
	gen women_10 = 0.200834249*TotalFemales_5to9_01 + TotalFemales_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*TotalFemales_5to9_11
	gen men_10 = 0.200834249*TotalMales_5to9_01 + TotalMales_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*TotalMales_5to9_11
	gen rural_10 = 0.200834249*RuralPersons_5to9_01 + RuralPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*RuralPersons_5to9_11
	gen ST_10 = 0.200834249*TotalSTPersons_5to9_01 + TotalSTPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*TotalSTPersons_5to9_11
	gen SC_10 = 0.200834249*TotalSCPersons_5to9_01 + TotalSCPersons_0to4_01 + ///
	    (0.204670205 + 0.202585422 + 0.200750232)*TotalSCPersons_5to9_11
	
	gen total_11 = TotalPersons_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*TotalPersons_5to9_11
	gen women_11 = TotalFemales_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*TotalFemales_5to9_11
	gen men_11 = TotalMales_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*TotalMales_5to9_11
    gen rural_11 = RuralPersons_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*RuralPersons_5to9_11
	gen ST_11 = TotalSTPersons_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*TotalSTPersons_5to9_11
    gen SC_11 = TotalSCPersons_10to14_11 + ///
	   (0.204670205 + 0.202585422 + 0.200750232 + 0.197495796)*TotalSCPersons_5to9_11
	
	gen total_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*TotalPersons_10to14_11 + ///
	    TotalPersons_5to9_11
	gen women_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*TotalFemales_10to14_11 + ///
	    TotalFemales_5to9_11
	gen men_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*TotalMales_10to14_11  + ///
	    TotalMales_5to9_11
	gen rural_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*RuralPersons_10to14_11 + ///
	    RuralPersons_5to9_11
	gen ST_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*TotalSTPersons_10to14_11 + ///
	    TotalSTPersons_5to9_11
	gen SC_12 = (0.199107848 + 0.198999054 + 0.200732943 + 0.202329519)*TotalSCPersons_10to14_11 + ///
	    TotalSCPersons_5to9_11
	
	gen total_13 = (0.198999054 + 0.200732943 + 0.202329519)*TotalPersons_10to14_11 + ///
	    TotalPersons_5to9_11 + 0.202136731*TotalPersons_0to4_11 
	gen women_13 = (0.198999054 + 0.200732943 + 0.202329519)*TotalFemales_10to14_11 + ///
	    TotalFemales_5to9_11 + 0.202136731*TotalFemales_0to4_11 
	gen men_13 = (0.198999054 + 0.200732943 + 0.202329519)*TotalMales_10to14_11 + ///
	    TotalMales_5to9_11 + 0.202136731*TotalMales_0to4_11 
	gen rural_13 = (0.198999054 + 0.200732943 + 0.202329519)*RuralPersons_10to14_11 + ///
	    RuralPersons_5to9_11 + 0.202136731*RuralPersons_0to4_11 
	gen ST_13 = (0.198999054 + 0.200732943 + 0.202329519)*TotalSTPersons_10to14_11 + ///
	    TotalSTPersons_5to9_11 + 0.202136731*TotalSTPersons_0to4_11 
	gen SC_13 = (0.198999054 + 0.200732943 + 0.202329519)*TotalSCPersons_10to14_11 + ///
	    TotalSCPersons_5to9_11 + 0.202136731*TotalSCPersons_0to4_11 
	
	gen total_14 = (0.200732943 + 0.202329519)*TotalPersons_10to14_11 + TotalPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*TotalPersons_0to4_11 
	gen women_14 = (0.200732943 + 0.202329519)*TotalFemales_10to14_11 + TotalFemales_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*TotalFemales_0to4_11 
	gen men_14 = (0.200732943 + 0.202329519)*TotalMales_10to14_11 + TotalMales_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*TotalMales_0to4_11 
	gen rural_14 =  (0.200732943 + 0.202329519)*RuralPersons_10to14_11 + RuralPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*RuralPersons_0to4_11 
	gen ST_14 = (0.200732943 + 0.202329519)*TotalSTPersons_10to14_11 + TotalSTPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*TotalSTPersons_0to4_11 
	gen SC_14 = (0.200732943 + 0.202329519)*TotalSCPersons_10to14_11 + TotalSCPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761)*TotalSCPersons_0to4_11 
	
	gen total_15 = 0.202329519*TotalPersons_10to14_11 + TotalPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*TotalPersons_0to4_11 
	gen women_15 = 0.202329519*TotalFemales_10to14_11 + TotalFemales_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*TotalFemales_0to4_11 
	gen men_15 = 0.202329519*TotalMales_10to14_11 + TotalMales_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*TotalMales_0to4_11 
	gen rural_15 = 0.202329519*RuralPersons_10to14_11 + RuralPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*RuralPersons_0to4_11 
	gen ST_15 = 0.202329519*TotalSTPersons_10to14_11 + TotalSTPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*TotalSTPersons_0to4_11 
	gen SC_15 = 0.202329519*TotalSCPersons_10to14_11 + TotalSCPersons_5to9_11 + ///    
	    (0.202136731 + 0.20108761 + 0.200774164)*TotalSCPersons_0to4_11 
	
	gen total_16 = TotalPersons_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*TotalPersons_0to4_11
	gen women_16 = TotalFemales_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*TotalFemales_0to4_11
	gen men_16 = TotalMales_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*TotalMales_0to4_11
	gen rural_16 = RuralPersons_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*RuralPersons_0to4_11
	gen ST_16 = TotalSTPersons_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*TotalSTPersons_0to4_11
	gen SC_16 = TotalSCPersons_5to9_11 + ///
	    (0.202136731 + 0.20108761 + 0.200774164 + 0.198956016)*TotalSCPersons_0to4_11
	
	gen total_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*TotalPersons_5to9_11 + ///
	    TotalPersons_0to4_11
	gen women_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*TotalFemales_5to9_11 + ///
	    TotalFemales_0to4_11
	gen men_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*TotalMales_5to9_11 + ///
	    TotalMales_0to4_11
	gen rural_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*RuralPersons_5to9_11 + ///
	    RuralPersons_0to4_11
	gen ST_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*TotalSTPersons_5to9_11 + ///
	    TotalSTPersons_0to4_11
	gen SC_17 = (0.202585422 + 0.200750232 + 0.197495796 + 0.194498345)*TotalSCPersons_5to9_11 + ///
	    TotalSCPersons_0to4_11
		
	gen women_multiplier = women_17/total_17 
	gen men_multiplier = men_17/total_17
	gen rural_multiplier = rural_17/total_17
	gen ST_multiplier = ST_17/total_17
	gen SC_multiplier = SC_17/total_17
	
	//26026303.42 = total babies born in 2012, and we multiply by the share of total population in 2011
	//that a given state makes up -- seems to be underestimating population, though. 
	gen total_18 = (0.200750232 + 0.197495796 + 0.194498345)*TotalPersons_5to9_11 + ///
	    TotalPersons_0to4_11 + 26026303.42*(TotalPersons_allages_11/112806778) 
	gen women_18 = women_multiplier*total_18
	gen men_18 = men_multiplier*total_18
	gen rural_18 = rural_multiplier*total_18
	gen ST_18 = ST_multiplier*total_18
	gen SC_18 = SC_multiplier*total_18
	
	gen total_19 = (0.197495796 + 0.194498345)*TotalPersons_5to9_11 + TotalPersons_0to4_11 + ///
	    (26026303.42 + 25738717.68)*(TotalPersons_allages_11/112806778) 
	gen women_19 = women_multiplier*total_19
	gen men_19 = men_multiplier*total_19
	gen rural_19 = rural_multiplier*total_19
	gen ST_19 = ST_multiplier*total_19
	gen SC_19 = SC_multiplier*total_19

	gen total_20 = (0.194498345)*TotalPersons_5to9_11 + TotalPersons_0to4_11 + ///
	    (26026303.42 + 25738717.68 + 24901738.75)*(TotalPersons_allages_11/112806778) 
	gen women_20 = women_multiplier*total_20
	gen men_20 = men_multiplier*total_20
	gen rural_20 = rural_multiplier*total_20
	gen ST_20 = ST_multiplier*total_20
	gen SC_20 = SC_multiplier*total_20
	
	gen total_21 = TotalPersons_0to4_11 + ///
	    (26026303.42 + 25738717.68 + 24901738.75 + 24823589.97)*(TotalPersons_allages_11/112806778) 
	gen women_21 = women_multiplier*total_21
	gen men_21 = men_multiplier*total_21
	gen rural_21 = rural_multiplier*total_21
	gen ST_21 = ST_multiplier*total_21
	gen SC_21 = SC_multiplier*total_21
	
	ds AreaName total_* women_* men_* rural_* ST_* SC_*, not
	drop `r(varlist)'
	drop women_multiplier men_multiplier rural_multiplier ST_multiplier SC_multiplier
	rename AreaName state
	drop if state == "India"
	
	replace state = strupper(state)
	rename state statename
	keep total_* statename
	reshape long total_, i(statename) j(year)
	keep statename year total_
	replace year = 2000 + year
	save ../output/state_populations, replace
end 

program calculate_population_2011only
   use ../output/allpops2011, clear
   keep AreaName TotalPersons* TotalMales* TotalFemales*
   rename AreaName statename
   gen primaryage_all = (0.197495796 + 0.200750232 + 0.202585422 + 0.204670205)*TotalPersons_5to9_11 + ///
       TotalPersons_10to14_11
   gen primaryage_males = (0.197495796 + 0.200750232 + 0.202585422 + 0.204670205)*TotalMales_5to9_11 + ///
       TotalMales_10to14_11
   gen primaryage_females = (0.197495796 + 0.200750232 + 0.202585422 + 0.204670205)*TotalFemales_5to9_11 + ///
       TotalFemales_10to14_11
   keep statename primaryage*
   replace statename = strupper(statename)
   
   save ../output/shares_from_2011, replace   
end 
	
*Execute
main