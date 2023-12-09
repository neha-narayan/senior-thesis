capture log close 
log using analysis.log, replace
clear all
set more off

program main
    summary_stats
end 

program summary_stats
	use ../output/clean_dta/panel_pre2017, clear
	
    drop distname 
	rename (state district_name) (statename distname)
	
	gen govt_ind = . 
	replace govt_ind = 1 if sch_management == 1 | sch_management == 2 | sch_management == 3 | ///
	    sch_management == 4 | sch_management == 6 
	replace govt_ind = 0 if sch_management == 5
	drop if mi(govt_ind) 
	
	rename rural_urban rural_ind
	replace rural_ind = 0 if rural_ind == 2 
	drop if rural_ind == 9 
	
	keep distname statename ac_year govt_ind rural_ind c1_totg c2_totg c3_totg ///
	    c4_totg c5_totg c6_totg c7_totg c8_totg c1_totb c2_totb c3_totb c4_totb c5_totb ///
		c6_totb c7_totb c8_totb toilet_girls toilet_common electricity drinking_water ///
		tch_male tch_female tch_nr playground approachbyroad medium1 medium2 medium3 ///
		medium4 
	
	//summary variables 
	egen enrollment = rowtotal(c1_totg c2_totg c3_totg c4_totg c5_totg c6_totg c7_totg c8_totg ///
	    c1_totb c2_totb c3_totb c4_totb c5_totb c6_totb c7_totb c8_totb)
	
	replace toilet_girls = . if toilet_girls < 0 
	replace toilet_girls = 1 if toilet_girls > 0
	
	replace toilet_common = 1 if toilet_common > 0 
	
	replace electricity = . if electricity == 0 | electricity == 5 | electricity == 9 
	replace electricity = 0 if electricity == 2 | electricity == 3 
	
	replace drinking_water = . if drinking_water == 9 
	replace drinking_water = 1 if drinking_water != 5
	replace drinking_water = 0 if drinking_water == 5 
	
	gen teachers = tch_male + tch_female + tch_nr 
	
	replace playground = 0 if playground == 2 
	replace playground = . if playground == 3 | playground == 9

	replace approachbyroad = . if approachbyroad == 0 | approachbyroad == 4 | approachbyroad == 9
	replace approachbyroad = 0 if approachbyroad == 2 
	
	forvalues idx = 1/4 {
		replace medium`idx' = 0 if medium`idx' == 4 | medium`idx' == 19
		replace medium`idx' = 1 if medium`idx' > 0 
		replace medium`idx' = . if medium`idx' < 0 
	}
	egen vernacular = rowtotal(medium1 medium2 medium3 medium4)
	replace vernacular = 1 if vernacular > 0 
	
	recode_dists
	
	replace ac_year = substr(ac_year, 1, 4)
	destring ac_year, replace
	drop if mi(ac_year) | ac_year < 2009
	
	bysort statename distname rural_ind: egen N = nvals(ac_year)
	drop if N != 9
	
	bysort statename distname ac_year: gen schtot = _N

	keep if ac_year == 2014
	drop ac_year 
	
	gen group = "Treatment"
	replace group = "Control" if statename == "ASSAM" | statename == "JAMMU & KASHMIR" | ///
	    statename == "KERALA" | statename == "MAHARASHTRA" | statename == "MEGHALAYA" | ///
		statename == "WEST BENGAL"
	
	fcollapse (firstnm) schtot group (mean) govt_ind rural_ind enrollment toilet_girls ///
	    toilet_common electricity drinking_water teachers playground approachbyroad vernacular, ///
		by(statename distname) 
	
    save ../output/summary_stats, replace
	
	use ../output/summary_stats, clear 
	
	la var govt_ind "Dummy for Government/Government-Aided School"
	la var rural_ind "Dummy for Rural"
	la var enrollment "Grade 1-8 Enrollment"
	la var toilet_girls "Dummy for Girls' Toilet"
	la var toilet_common "Dummy for Common Toilet"
	la var electricity "Dummy for Working Electricity"
	la var drinking_water "Dummy for Drinking Water"
	la var teachers "Number of Teachers"
	la var playground "Dummy for Playground"
	la var schtot "Number of Schools" 
	la var vernacular "Dummy for Instruction in Vernacular"
	la var approachbyroad "Dummy for Approachable by Road"
	
	eststo PreCTrim: estpost sum enrollment toilet_girls toilet_common ///
	    electricity drinking_water teachers playground approachbyroad vernacular schtot govt_ind rural_ind if group == "Control"
	
	eststo PreTTrim: estpost sum govt_ind rural_ind enrollment toilet_girls toilet_common ///
	    electricity drinking_water teachers playground approachbyroad vernacular schtot if group == "Treatment"
	
	esttab PreCTrim PreTTrim using ../output/summary_stats1.tex, ///
            replace cells(mean(fmt(%5.2f)) sd(fmt(%5.2f))) nonumbers label
	
	drop if statename == "PUDUCHERRY" | statename == "UTTARAKHAND"  |statename == "CHHATTISGARH" | ///
	statename == "HIMACHAL PRADESH" | statename == "MIZORAM" | statename == "TAMIL NADU"
	
	eststo PostCTrim: estpost sum govt_ind rural_ind enrollment toilet_girls toilet_common ///
	    electricity drinking_water teachers playground approachbyroad vernacular schtot if group == "Control"
	
	eststo PostTTrim: estpost sum govt_ind rural_ind enrollment toilet_girls toilet_common ///
	    electricity drinking_water teachers playground approachbyroad vernacular schtot if group == "Treatment"
	
	esttab PostCTrim PostTTrim using ../output/summary_stats2.tex, ///
            replace cells(mean(fmt(%5.2f)) sd(fmt(%5.2f))) nonumbers label
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

