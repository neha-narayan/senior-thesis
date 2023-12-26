capture log close 
log using build.log, replace
clear all
set more off

program main
   condense_panels
//    merge_pincode_panels
//     incorporate_enrollment_centers
end 

program condense_panels
	//alternative 
	use ../output/clean_dta/panel_pre2017, clear
	
    drop distname 
	rename (state district_name block_name village_name) (statename distname block village)
	
	gen govt_ind = . 
	replace govt_ind = 1 if sch_management == 1 | sch_management == 2 | sch_management == 3 | sch_management == 4 | sch_management == 6 
	replace govt_ind = 0 if sch_management == 5
	drop if mi(govt_ind) 
	
	rename rural_urban rural_ind
	replace rural_ind = 0 if rural_ind == 2 
	drop if rural_ind == 9 
	
	recode_dists
	
	bysort pincode rural_ind ac_year: gen schtot = _N
	
	keep c1_totg c1_totb c2_tot* c3_tot* c4_tot* c5_tot* c6_tot* c7_tot* c8_tot* ///
	    c1_c* c2_c* c3_c* c4_c* c5_c* c6_c* c7_c* c8_c* c1_t* c2_t* c3_t* c4_t* c5_t* ///
		c6_t* c7_t* c8_t* c1_o* c2_o* c3_o* c4_o* c5_o* c6_o* c7_o* c8_o* apprb7 apprg7 ///
		statename distname ac_year schtot govt_ind rural_ind pincode
	
	gen exam_appearers = apprb7 + apprg7 
	replace exam_appearers = . if ac_year != "2009-10" 
	replace exam_appearers = . if exam_appearers == 0 

	gen unreliable = c7_totb + c7_totg
	gen reliable_index = exam_appearers / unreliable
	bysort pincode ac_year: egen temp = mean(reliable_index)
    replace reliable_index = temp
	drop temp

	tostring rural_ind, replace
	tostring pincode, replace
	ds schtot rural_ind statename distname ac_year reliable_index pincode, not
	fcollapse (sum) `r(varlist)' (firstnm) statename schtot reliable_index, by(pincode rural_ind ac_year) 

	save ../output/clean_dta/pincode_enrollment_pre2017, replace

	use ../output/clean_dta/panel_post2017, clear
	
	gen govt_ind = . 
	replace govt_ind = 1 if managment == 1 | managment == 2 | managment == 3 | managment == 4 | managment == 6 
	replace govt_ind = 0 if managment == 5
	drop if mi(govt_ind)
	
	rename rural_urban rural_ind
	replace rural_ind = 0 if rural_ind == 2 
	drop if rural_ind == 9 

	rename (state district) (statename distname)
	
	recode_dists 
	
    bysort pincode rural_ind ac_year: gen schtot = _N
	
	keep c1_totg c1_totb c2_tot* c3_tot* c4_tot* c5_tot* c6_tot* c7_tot* c8_tot* ///
	    c1_c* c2_c* c3_c* c4_c* c5_c* c6_c* c7_c* c8_c* c1_t* c2_t* c3_t* c4_t* c5_t* ///
		c6_t* c7_t* c8_t* c1_o* c2_o* c3_o* c4_o* c5_o* c6_o* c7_o* c8_o* ///
		statename distname ac_year schtot govt_ind rural_ind pincode
	
	tostring rural_ind pincode, replace
	ds schtot rural_ind statename distname ac_year pincode, not
	collapse (sum) `r(varlist)' (firstnm) schtot statename, by(pincode rural_ind ac_year) fast
	
	save ../output/clean_dta/pincode_enrollment_post2017, replace 
end

program verify_pincodes
        import delimited ../../../raw/all_india_pin_code, varnames(1) clear
		keep pincode 
		duplicates drop 
		tostring pincode, replace
		save ../../../shared_data/all_pincodes, replace
end 

program merge_pincode_panels
    use ../output/clean_dta/pincode_enrollment_pre2017, clear
	append using ../output/clean_dta/pincode_enrollment_post2017
	
	merge m:1 pincode using ../output/all_pincodes, assert(1 2 3) keep(3)

	replace ac_year = substr(ac_year, 1, 4)
	destring ac_year, replace
	
	bysort pincode: egen N = nvals(ac_year) 
	drop if N != 13
	
	destring rural_ind, replace
	gen rural_schools = rural_ind*schtot
	ds pincode statename ac_year rural_ind reliable_index, not
	collapse (sum) `r(varlist)' (firstnm) reliable_index statename, by(pincode ac_year)
	
	egen enrollment = rowtotal(c1_totg c2_totg c3_totg c4_totg c5_totg c6_totg c7_totg c8_totg ///
	    c1_totb c2_totb c3_totb c4_totb c5_totb c6_totb c7_totb c8_totb)
	egen enrollment_g = rowtotal(c1_totg c2_totg c3_totg c4_totg c5_totg c6_totg c7_totg c8_totg)
	egen enrollment_b = rowtotal(c1_totb c2_totb c3_totb c4_totb c5_totb c6_totb c7_totb c8_totb)
	egen scenrollment = rowtotal(c1_cg c2_cg c3_cg c4_cg c5_cg c6_cg c7_cg c8_cg ///
	    c1_cb c2_cb c3_cb c4_cb c5_cb c6_cb c7_cb c8_cb)
	egen stenrollment = rowtotal(c1_tg c2_tg c3_tg c4_tg c5_tg c6_tg c7_tg c8_tg ///
	    c1_tb c2_tb c3_tb c4_tb c5_tb c6_tb c7_tb c8_tb)

	save ../../../shared_data/pincode_enrollment_dise, replace
end 

program incorporate_enrollment_centers
    import delimited ../../../raw/Aadhaar_Centers/UIDAI.csv, varnames(1) clear
	
	gen enrollment_center = 0
	replace enrollment_center = 1 if strpos(enrolment_type, "Enrolment")
	drop if enrollment_center == 0 
	
	bysort state: gen num_centers = _N
	bysort state: egen num_pincodes = nvals(pincode)
	
	duplicates drop pincode, force
	keep pincode num_centers state
	tostring pincode, replace
	
	merge 1:m pincode using ../../../shared_data/pincode_enrollment_dise, assert(1 2 3) keep(2 3) gen(merge_centers)
	replace num_centers = 0 if mi(num_centers)
	save ../../../shared_data/pincode_enrollment_dise, replace
end 

program population_scaling 
// 	use ../output/clean_dta/enrollment_dise, clear
// 	ds statename distname ac_year govt_ind rural_ind reliable_index, not
// 	collapse (sum) `r(varlist)' (mean) govt_ind reliable_index, by(statename distname ac_year rural_ind)
// 	drop N
// 	merge m:1 statename distname using ../../../shared_data/shares_from_2011_district, assert(1 2 3) keep(3)
// 	drop _merge
				
// 	gen enrollment_rate = enrollment/primaryage_all
// 	gen enrollment_rateg =  enrollment_g/primaryage_females
// 	gen enrollment_rateb = enrollment_b/primaryage_males
// 	gen enrollment_rateSC = scenrollment/primaryage_SC
// 	gen enrollment_rateST = stenrollment/primaryage_ST
// 	gen rural_enrollment_rate = enrollment / primaryage_rural
// 	gen urban_enrollment_rate = enrollment / primaryage_urban
//	
// 	save ../../../shared_data/enrollment_dise, replace
end 

program recode_dists
    replace statename = strtrim(statename)
	
	replace statename = strupper(statename)
	replace statename = "ANDAMAN & NICOBAR ISLANDS" if statename == "A & N ISLANDS" | statename == "A & N Islands" | statename == "ANDAMAN AND NICOBAR ISLANDS"
	replace statename = "ANDHRA PRADESH" if statename == "TELANGANA"
	replace statename = "CHHATTISGARH" if statename == "CHHATISGARH"
	replace statename = "DNH & DD" if statename == "D & N HAVELI" | statename == "DADRA & NAGAR HAVELI" |  statename == "DAMAN & DIU" | statename == "DADRA & NAGAR HAVELI AND DAMAN & DIU" | statename ==  "DADRA AND NAGAR HAVELI" | statename == "DAMAN & DIU AND DADRA & NAGAR HAVELI" | statename == "DAMAN AND DIU"
	replace statename = "JAMMU & KASHMIR" if statename == "JAMMU AND KASHMIR"
	replace statename = "KERALA" if statename == "KERLA"
	replace statename = "ODISHA" if statename == "ORISSA"
	replace statename = "TAMIL NADU" if statename == "TAMILNADU"
	replace statename = "UTTARAKHAND" if statename == "UTTARANCHAL"
	
	replace distname = strtrim(distname)
	replace distname = strupper(distname)
	
	//clean up district names 
	//andaman + nicobar
	replace distname = "ANDAMANS" if distname == "SOUTH ANDAMANS" | distname == "MIDDLE AND NORTH ANDAMANS"
	//arunachal pradesh
	replace distname = "PAPUM PARE" if distname == "CAPITAL COMPLEX ITANAGAR"
	replace distname = "LOWER SUBANSIRI" if distname == "KAMLE"
	replace distname = "KURUNG KUMEY" if distname == "KRA DADI" | distname == "KRA DAADI"
	replace distname = "UPPER SIANG" if distname == "LEPA RADA"
	replace distname = "TIRAP" if distname == "LONGDING"
	replace distname = "EAST SIANG" if distname == "LOWER SIANG"
	replace distname = "LOHIT" if distname == "NAMSAI"
	replace distname = "EAST KAMENG" if distname == "PAKKE KESSANG"
	replace distname = "WEST SIANG" if distname == "SHI YOMI"
	replace distname = "EAST SIANG" if distname == "SIANG"
	replace distname = "LOHIT" if distname == "ANJAW"

	//andhra pradesh
	replace distname = "ADILABAD" if distname == "KUMURAM BHEEM ASIFABAD" | distname == "MANCHERIAL" | distname == "NIRMAL" | distname == "KOMARAM BHEEM"
	replace distname = "KADAPA" if distname == "CUDDAPAH"
	replace distname = "BHADRADRI" if distname == "BHADRADRI KOTHAGUDEM"
	replace distname = "KHAMMAM" if distname == "BHADRADRI" | distname == "MULUGU"
	replace distname = "WARANGAL" if distname == "HANUMAKONDA" | distname == "WARANGAL URBAN" | distname == "WARANGAL RURAL" | distname == "JANGAON" | distname == "MAHABUBABAD"
	replace distname = "HYDERABAD" if distname == "HYDERBAD"
	replace distname = "KARIMNAGAR" if distname == "JAGTIAL" | distname == "PEDDAPALLI" | distname == "RAJANNA SIRICILLA" | distname == "RAJANNA" | distname == "JAYASHANKAR"
    replace distname = "JOGULAMBA" if distname == "JOGULAMBA GADWAL"
	replace distname = "MAHABUBNAGAR" if distname == "JOGULAMBA" | distname == "MAHBUBNAGAR" |distname == "NAGARKURNOOL" | distname == "NARAYANAPET" | distname == "WANAPARTHY"
	replace distname = "MEDCHAL" if distname == "MEDCHAL-MALKAJGIRI"
	replace distname = "RANGAREDDY" if distname == "RANGAREDDI" | distname == "RANGA REDDY" | distname == "VIKARABAD" | distname == "MEDCHAL"
	replace distname = "NIZAMABAD" if distname == "KAMAREDDY"
	replace distname = "MEDAK" if distname == "SANGAREDDY" | distname == "SIDDIPET"
	replace distname = "NALGONDA" if distname == "SURYAPET" | distname == "YADADRI" | distname == "YADADRI BHUVANAGIRI"
	//assam
	replace distname = "BAKSA" if distname == "TAMULPUR"
	replace distname = "BARPETA" if distname == "BAJALI" 
	replace distname = "SONITPUR" if distname == "BISWANATH"
	replace distname = "SIBSAGAR" if distname == "CHARAIDEO"
	replace distname = "SIVASAGAR" if distname == "SIBSAGAR"
	replace distname = "BONGAIGAON" if distname == "CHIRANG"
	replace distname = "NAGAON" if distname == "HOJAI"
	replace distname = "KAMRUP" if distname == "KAMRUP-METRO" | distname == "KAMRUP-RURAL" 
	replace distname = "JORHAT" if distname == "MAJULI"
	replace distname = "MORIGAON" if distname == "MARIGAON"
	replace distname = "DIMA HASAO" if distname == "NORTH CACHAR HILLS"
	replace distname = "DHUBRI" if distname == "SOUTH SALMARA-MANKACHAR"
	replace distname = "DARRANG" if distname == "UDALGURI"
	replace distname = "WEST KARBI ANGLONG" if distname == "KARBI ANGLONG"
	//bihar
	replace distname = "JEHANABAD" if distname == "ARWAL"
	replace distname = "AURANGABAD" if distname == "AURANGABAD (BIHAR)"
	replace distname = "KAIMUR" if distname == "KAIMUR (BHABUA)"
	//chandigarh
	replace distname = "CHANDIGARH" if distname == "CHANDIGARH (U.T.)"
	//chhattisgarh
	replace statename = "CHHATTISGARH" if distname == "DANTEWADA"
	replace distname = "SURGUJA" if distname == "BALRAMPUR" | distname == "SURAJPUR"
	replace distname = "DURG" if distname == "BEMETARA" | distname == "BALOD"
	replace distname = "DANTEWADA" if distname == "BIJAPUR" | distname == "SUKMA" | distname == "DAKSHIN BASTAR DANTEWADA"
	replace distname = "BILASPUR" if distname == "BILASPUR (CHHATTISGARH)" | distname == "GOURELA PENDRA MARVAHI" | distname == "MUNGELI"
	replace distname = "RAIPUR" if distname == "GARIABAND" | distname == "BALODABAZAR"
	replace distname = "BASTER" if distname == "KONDAGAON" | distname == "NARAYANPUR" 
	replace distname = "RAIGARH" if distname == "RAIGARH (CHHATTISGARH)"
	replace distname = "KANKER" if distname == "UTTAR BASTAR KANKER"
	replace distname = "KABEERDHAM" if distname == "KAWARDHA"
 	//delhi
	replace distname = "CENTRAL DELHI" if distname == "CENTRAL"
	replace distname = "EAST DELHI" if distname == "EAST"
	replace distname = "NORTH DELHI" if distname == "NORTH"
	replace distname = "NORTH EAST DELHI" if distname == "NORTH EAST"
	replace distname = "NORTH WEST DELHI" if distname == "NORTH WEST" | distname == "NORTH WEST A" | distname == "NORTH WEST B"
	replace distname = "SOUTH DELHI" if distname == "SOUTH"
	replace distname = "SOUTH EAST DELHI" if distname == "SOUTH EAST"
	replace distname = "SOUTH DELHI" if distname == "SOUTH EAST DELHI"
	replace distname = "SOUTH WEST DELHI" if distname == "SOUTH WEST" | distname == "SOUTH WEST A" | distname == "SOUTH WEST B"
	replace distname = "WEST DELHI" if distname == "WEST" | distname == "WEST A" | distname == "WEST B"
	//dnh & dd
	replace distname = "DADRA & NAGAR HAVELI" if distname == "DADRA AND NAGAR HAVELI(DIST)" | distname == "DADRA AND NAGAR HAVELI(UT)"
	replace distname = "DAMAN" if distname == "DAMAN (DIST)"
	replace distname = "DIU" if distname == "DIU (DIST)"
	//gujarat
	replace distname = "AHMEDABAD" if distname == "AHMADABAD" | distname == "BOTAD"
	replace distname = "SABARKANTHA" if distname == "ARAVALLI" | distname == "SABAR KANTHA"
	replace distname = "VADODARA" if distname == "CHHOTAUDEPUR"
	replace distname = "JAMNAGAR" if distname == "DEVBHOOMI DWARKA"
	replace distname = "JUNAGADH" if distname == "GIR SOMNATH"
	replace distname = "PANCH MAHALS" if distname == "MAHISAGAR"
	replace distname = "RAJKOT" if distname == "MORBI"
	//haryana
	replace distname = "BHIWANI" if distname == "CHARKHI DADRI"
	replace distname = "GURGAON" if distname == "GURUGRAM"
	replace distname = "NUH" if distname == "MEWAT"
	replace distname = "BILASPUR" if distname == "BILASPUR (H.P.)"
	replace distname = "HAMIRPUR" if distname == "HAMIRPUR (H.P.)"
	//jammu + kashmir / ladakh
	replace statename = "JAMMU & KASHMIR" if distname == "KARGIL" | distname == "LEH (LADAKH)"
	//karnataka
	replace distname = "BALLARI" if distname == "BELLARY" | distname == "VIJAYANAGARA"
	replace distname = "BENGALURU RURAL" if distname == "BANGALORE RURAL"
	replace distname = "BENGALURU URBAN" if distname == "BANGALORE NORTH" | distname == "BANGALORE SOUTH" | distname == "BANGALORE U NORTH" | distname == "BANGALORE U SOUTH" | distname == "BENGALURU U NORTH" | distname == "BENGALURU U SOUTH"
	replace distname = "BELGAVI CHIKKODI" if distname == "BELGAUM CHIKKODI" | distname == "CHIKKODI" | distname == "BELAGAVI CHIKKODI"
	replace distname = "BELGAVI" if distname == "BELGAUM" | distname == "BELAGAVI" | distname == "BELGAVI CHIKKODI"
	replace distname = "VIJAYAPURA" if distname == "BIJAPUR (KARNATAKA)" | distname == "BIJAPUR"
	replace distname = "CHAMARAJANAGARA" if distname == "CHAMARAJANAGAR"
	replace distname = "CHIKKAMANGALORE" if distname == "CHIKKAMAGALURU" | distname == "CHIKKAMANGALURU"
	replace distname = "KALABURGI" if distname == "GULBARGA" | distname == "KALBURGI"
	replace distname = "MYSURU" if distname == "MYSORE"
	replace distname = "SHIVAMOGGA" if distname == "SHIMOGA"
	replace distname = "TUMAKURU MADHUGIRI" if distname == "TUMKUR MADHUGIRI" | distname == "MADHUGIRI"
	replace distname = "TUMAKURU" if distname == "TUMKUR" | distname == "TUMAKURU MADHUGIRI" 
	replace distname = "UTTARA KANNADA" if distname == "UTTARAKANNADA" | distname == "UTTARA KANNADA SIRSI" | distname == "UTTARKANNADA"
	replace distname = "YADAGIRI" if distname == "YADGIRI"
	//madhya pradesh
	replace distname = "SHAJAPUR" if distname == "AGAR MALWA"
	replace distname = "TIKAMGARH" if distname == "NIWARI"
	replace distname = "JHABUA" if distname == "ALIRAJPUR"
	//maharashtra
	replace distname = "MUMBAI" if distname == "MUMBAI II"
	replace distname = "THANE" if distname == "PALGHAR"
	replace distname = "AURANGABAD" if distname == "AURANGABAD (MAHARASHTRA)"
	replace distname = "MUMBAI SUBURBAN" if distname == "MUMBAI (SUBURBAN)"
	replace distname = "RAIGARH" if distname == "RAIGARH (MAHARASHTRA)"
	//manipur
	replace distname = "IMPHAL EAST" if distname == "JIRIBAM"
	replace distname = "THOUBAL" if distname == "KAKCHING"
	replace distname = "UKHRUL" if distname == "KAMJONG" | distname == "KOMJONG"
	replace distname = "SENAPATI" if distname == "KANGPOKPI" | distname == "KONGPOKPI"
	replace distname = "TAMENGLONG" if distname == "NONEY"
	replace distname = "CHURACHANDPUR" if distname == "PHERZAWL"
	replace distname = "CHANDEL" if distname == "TENGNOUPAL"
	//meghalaya
	replace distname = "JAINTIA HILLS" if distname == "EAST JAINTIA HILLS" | distname == "WEST JAINTIA HILLS"
	replace distname = "EAST GARO HILLS" if distname == "NORTH GARO HILLS"
	replace distname = "WEST GARO HILLS" if distname == "SOUTH WEST GARO HILLS"
	replace distname = "WEST KHASI HILLS" if distname == "SOUTH WEST KHASI HILLS"
	//mizoram
	replace distname = "LUNGLEI" if distname == "HNAHTHIAL"
	replace distname = "CHAMPHAI" if distname == "KHAWZAWL"
	replace distname = "AIZAWL" if distname == "SAITUAL"
	//nagaland
	replace distname = "KIPHERE" if distname == "KIPHIRE"
	//odisha
	replace distname = "ANGUL" if distname == "ANUGUL"
	replace distname = "BALESHWAR" if distname == "BALASORE"
	replace distname = "BARAGARH" if distname == "BARGARH"
	replace distname = "BAUDH" if distname == "BOUDH"
	replace distname = "BALANGIR" if distname == "BOLANGIR"
	replace distname = "DEOGARH" if distname == "DEBAGARH"
	replace distname = "JAGATSINGHPUR" if distname == "JAGATSINGHAPUR"
	replace distname = "JAJAPUR" if distname == "JAJPUR"
	replace distname = "KEONJHAR" if distname == "KENDUJHAR"
	replace distname = "KHURDHA" if distname == "KHORDHA"
	replace distname = "NABARANGAPUR" if distname == "NABARANGPUR"
	replace distname = "SONAPUR" if distname == "SONEPUR"
	replace distname = "SUNDARGARH" if distname == "SUNDERGARH"
	//punjab
	replace distname = "SANGRUR" if distname == "MALERKOTA" | distname == "MALERKOTLA"
	replace distname = "FIROZPUR" if distname == "FAZILKA"
	replace distname = "GURDASPUR" if distname == "PATHANKOT"
	//rajasthan
	replace distname = "JHUNJHUNUN" if distname == "JHUNJHUNU"
	replace distname = "PRATAPGARH" if distname == "PRATAPGARH (RAJ.)" | distname == "PRATAPGARH(RAJASTHAN)"
	//sikkim
	replace distname = "WEST SIKKIM" if distname == "SORENG"
	replace distname = "EAST SIKKIM" if distname == "PAKYONG"
	replace distname = "SOUTH SIKKIM" if distname == "NAMCHI"
	replace distname = "NORTH SIKKIM" if distname == "MANGAN"
	replace distname = "WEST SIKKIM" if distname == "GYALSHING"
	replace distname = "EAST SIKKIM" if distname == "GANGTOK"
	//tamil nadu
	replace distname = "KANCHEEPURAM" if distname == "CHENGALPATTU"
	replace distname = "VILUPPURAM" if distname == "KALLAKURICHI"
	replace distname = "KRISHNAGIRI" if distname == "KRISHANAGIRI"
	replace distname = "VELLORE" if distname == "RANIPET" | distname == "TIRUPATHUR" | distname == "TIRUPATTUR"
	replace distname = "SIVAGANGA" if distname == "SIVAGANGAI"
	replace distname = "TIRUNELVELI" if distname == "TENKASI"
	replace distname = "THIRUVALLUR" if distname == "TIRUVALLUR"
	replace distname = "THIRUVARUR" if distname == "TIRUVARUR"
	replace distname = "VILUPPURAM" if distname == "VILLUPURAM"
	//tripura
	replace distname = "SOUTH TRIPURA" if distname == "GOMATI"
	replace distname = "WEST TRIPURA" if distname == "KHOWAI" | distname == "SEPAHIJALA"
	replace distname = "NORTH TRIPURA" if distname == "UNAKOTI"
	//uttar pradesh
	replace distname = "PRAYAGRAJ" if distname == "ALLAHABAD"
	replace distname = "BALRAMPUR" if distname == "BALRAMPUR (U.P)"
	replace distname = "HAMIRPUR" if distname == "HAMIRPUR (U.P.)"
	replace distname = "JYOTIBA PHULE NAGAR" if distname == "JYOTIBA PHULE NAGAR (AMROHA)"
	replace distname = "KASHIRAM NAGAR" if distname == "KANSHIRAM NAGAR"
	replace distname = "MUZAFFARNAGAR" if distname == "SHAMLI (PRABUDH NAGAR)"
	replace distname = "AMETHI" if distname == "AMETHI - CSM NAGAR" | distname == "CSMAHARAJ NAGAR"
	replace distname = "SULTANPUR" if distname == "AMETHI"
    replace distname = "GHAZIABAD" if distname == "HAPUR (PANCHSHEEL NAGAR)"
	replace distname = "MORADABAD" if distname == "SAMBHAL (BHIM NAGAR)"
	//west bengal
	replace distname = "JALPAIGURI" if distname == "ALIPURDUAR"
	replace distname = "BARDHAMAN" if distname == "BARDDHAMAN" | distname == "PASCHIM BARDHAMAN" | distname == "PURBA BARDHAMAN"
	replace distname = "KOCH BIHAR" if distname == "COOCHBEHAR" | distname == "COOCH BIHAR"
	replace distname = "DARJEELING" if distname == "DARJILING" | distname == "KALIMPONG" | distname == "SILIGURI"
	replace distname = "HOOGHLY" if distname == "HUGLI"
	replace distname = "PASCHIM MEDINIPUR" if distname == "JHARGRAM"
	replace distname = "NORTH 24 PARGANAS" if distname == "NORTH TWENTY FOUR PARGANA" | distname == "NORTH TWENTY FOUR PARGANAS"
	replace distname = "PURULIYA" if distname == "PURULIA"
	replace distname = "SOUTH 24 PARGANAS" if distname == "SOUTH  TWENTY FOUR PARGAN" | distname == "SOUTH  TWENTY FOUR PARGANA" | distname == "SOUTH  TWENTY FOUR PARGANAS" | distname == "SOUTH TWENTY FOUR PARGAN"
	replace distname = "HOWRAH" if distname == "HAORA"
end 

*Execute
main