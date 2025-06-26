*** App2 (Clare versions) 
*** Generic cleaning
* 14 June 2020

*!!* This is the only cleaning that applies to all individual datasets.
*!!* The rest of the cleaning is done in form-specific do files.


foreach folder in caregiver childadol devmile eid infant ///
	partner reg_hhmem reg_index {
	clear
	use "$temp_appdata/Clare/`folder'.dta", clear
	
	* Change missings to blank
	ds, has(type string) 
	local strvars="`r(varlist)'" 
	foreach v of varlist `strvars' {
		replace `v'="" if `v'=="---"
	}	
	
	* Numeric completed time for section below this
	foreach var of varlist completed {
		gen `var'1=date(`var',"YMDhms")
		replace `var'1=date(`var',"DMYhms") if `var'1==.
		format %d `var'1
	}

	* Drop observations before each country's programme started
	drop if country=="Lesotho" & completed1<td(01aug2016)
	drop if country=="Kenya" & completed1<td(01aug2016)
	drop if country=="Malawi" & completed1<td(01aug2016)
	drop if country=="Mozambique" & completed1<td(01jan2016)
	drop if country=="South Africa" & completed1<td(01feb2016)
	drop if country=="Swaziland" & completed1<td(01aug2016)
	drop if country=="Uganda" & completed1<td(01aug2016)
	drop if country=="Zambia" & completed1<td(01aug2016)

	* Drop invalid usernames
	replace username=lower(username)
	drop if username=="alekhutle3"
	drop if username=="alekhutle4"
	drop if username=="bmkolada"
	drop if username=="cnaidoo"
	drop if username=="deleteme"
	drop if username=="demo"
	drop if username=="dicksoncloudcare"
	drop if username=="dmatsiko"
	drop if username=="dummy"
	drop if username=="dumy"
	drop if username=="facility"
	drop if username=="garrit"
	drop if username=="ggerke"
	drop if username=="hnatukunda"
	drop if username=="imokhali2"
	drop if username=="jabmagagula2"
	drop if username=="jabsibandze2"
	drop if username=="jaloo"
	drop if username=="jmalete"
	drop if username=="jsesing4"
	drop if username=="jsnow"
	drop if username=="keneuoe"
	drop if username=="kgumedze2"
	drop if username=="klekhotla2"
	drop if username=="kmabaleka2"
	drop if username=="kmahao3"
	drop if username=="kmahao4"
	drop if username=="kmoeketse3"
	drop if username=="kmoeketse4"
	drop if username=="kmolosiuoa2"
	drop if username=="kmorienyane"
	drop if username=="kmoroeng4"
	drop if username=="limpho"
	drop if username=="lizcindzi2"
	drop if username=="lkhothle"
	drop if username=="lmatetete1"
	drop if username=="lmosoeu2"
	drop if username=="lmusa3"
	drop if username=="lmusa4"
	drop if username=="lnteko2"
	drop if username=="lnteko3"
	drop if username=="lomduma2"
	drop if username=="londwandwe2"
	drop if username=="lramoleko2"
	drop if username=="lramoleko4"
	drop if username=="lraupa3"
	drop if username=="lraupa4"
	drop if username=="lserobanyane3"
	drop if username=="lserobanyane4"
	drop if username=="lsibiya2"
	drop if username=="lungmamba2"
	drop if username=="lushongweee2"
	drop if username=="mahowe"
	drop if username=="mavesi"
	drop if username=="mchitema"
	drop if username=="mchitema2"
	drop if username=="mfuma3"
	drop if username=="mfuma4"
	drop if username=="mkoao4"
	drop if username=="mlesia3"
	drop if username=="mlesia4"
	drop if username=="mliefo3"
	drop if username=="mliefo4"
	drop if username=="mmahobe2"
	drop if username=="mmakara"
	drop if username=="mmakolotsa1"
	drop if username=="mmaoeksa"
	drop if username=="mmaputle2"
	drop if username=="mmaroba3"
	drop if username=="mmaroba4"
	drop if username=="mmhao4"
	drop if username=="mmochesane2"
	drop if username=="mmohloai"
	drop if username=="mmoleko"
	drop if username=="mmpana2"
	drop if username=="mmpana4"
	drop if username=="mmsibi2"
	drop if username=="mnchobe2"
	drop if username=="mngoae2"
	drop if username=="mnxumalo2"
	drop if username=="mnyapisi3"
	drop if username=="molly"
	drop if username=="mphosholi2"
	drop if username=="mposholi2"
	drop if username=="mrakharebe2"
	drop if username=="mseakhi4"
	drop if username=="msekhesa2"
	drop if username=="msekotolane2"
	drop if username=="mselemela2"
	drop if username=="msenohe3"
	drop if username=="msenohe4"
	drop if username=="mtokho3"
	drop if username=="mtota2"
	drop if username=="nango"
	drop if username=="ncarbone2"
	drop if username=="ncele"
	drop if username=="ndoliwe"
	drop if username=="ndube"
	drop if username=="nfakudze2"
	drop if username=="ngari"
	drop if username=="nick"
	drop if username=="nkhenisa"
	drop if username=="nkhmakhathu2"
	drop if username=="nkhutlisi2"
	drop if username=="nlekhooana2"
	drop if username=="nmangope4"
	drop if username=="nmaseko2"
	drop if username=="nmoeti3"
	drop if username=="nmoeti4"
	drop if username=="nmpopo"
	drop if username=="nndayi"
	drop if username=="nnestle"
	drop if username=="nonkdlamini2"
	drop if username=="nqatana"
	drop if username=="nsekotolane4"
	drop if username=="nseyama2"
	drop if username=="pilot"
	drop if username=="pmaluwaya2"
	drop if username=="pnekesa2"
	drop if username=="ratieno2"
	drop if username=="rdawa2"
	drop if username=="refresher"
	drop if username=="rleoatha2"
	drop if username=="rleoatha4"
	drop if username=="rlitaole1"
	drop if username=="rmakhate2"
	drop if username=="rmassa2"
	drop if username=="rmkhate4"
	drop if username=="rthole"
	drop if username=="rtowett"
	drop if username=="rtowett2"
	drop if username=="sgama2"
	drop if username=="sjdlamini2"
	drop if username=="sletsie2"
	drop if username=="smagagula2"
	drop if username=="smahao2"
	drop if username=="snkhetse3"
	drop if username=="snkhetse4"
	drop if username=="ssebanda"
	drop if username=="stephano"
	drop if username=="szondi"
	drop if username=="tchigaru2"
	drop if username=="test"
	drop if username=="themdube"
	drop if username=="tkhumalo2"
	drop if username=="tkunene2"
	drop if username=="tmbonambi"
	drop if username=="tmkhabela2"
	drop if username=="towett"
	drop if username=="train"
	drop if username=="tranin"
	drop if username=="trainer33"
	drop if username=="user"
	drop if username=="user3"
	drop if username=="user4"
	drop if username=="user5"
	drop if username=="user6"
	drop if username=="user7"
	drop if username=="user8"
	drop if username=="userg"
	drop if username=="vkumwenda2"
	drop if username=="winindwandwe2"
	drop if username=="wsimelane2"
	drop if username=="wthindwa2"
	drop if username=="ymfunda"
	drop if username=="zadlamini2"
	drop if username=="zanddlamini2"
	drop if username=="zjoaki"
	drop if username=="zjoaki2"
	drop if username=="zmkhatshwa2"


	* Cleaning facility
	drop if strpos(facility, "share it")!=0 | ///
		strpos(facility, "shine")!=0 | ///
		strpos(facility, "train")!=0 | ///
		strpos(facility, "Train")!=0 | ///
        strpos(facility, "tranin")!=0 | ///
       	strpos(facility, "dumy")!=0 | ///
		strpos(facility, "dummy")!=0 | ///
		strpos(facility, "facility")!=0 | ///
		strpos(facility, "test")!=0 | ///
		strpos(facility, "Train")!=0 | ///
       	strpos(facility, "Tranin")!=0 | ///
        strpos(facility, "Dumy")!=0 | ///
		strpos(facility, "Dummy")!=0 | ///
		strpos(facility, "Facility")!=0 | ///
		strpos(facility, "Test")!=0 | ///
		strpos(facility, "ToT")!=0 | ///
		strpos(facility, "demo")!=0 | ///
		strpos(facility, "Demo")!=0 | ///
		strpos(facility, "Rtowett")!=0 | ///
		strpos(facility, "Mmoleko")!=0 | ///
		strpos(facility, "Dicksoncloudcare")!=0 | ///
		strpos(facility, "Dmatsiko")!=0 | ///
		strpos(facility, "Ymfunda")!=0 | ///
		strpos(facility, "Tmbonambi")!=0 | ///
		strpos(facility, "Zjoaki")!=0 | ///
		strpos(facility, "Mchitema")!=0 | ///
		strpos(facility, "Szondi")!=0 | ///
		strpos(facility, "Ggerke")!=0 | ///
		strpos(facility, "Userg")!=0 | ///
		strpos(facility, "Ndoliwe")!=0 | ///
		strpos(facility, "Nango")!=0 | ///
		strpos(facility, "Jaloo")!=0 | ///
		strpos(facility, "Ngari")!=0 | ///
		strpos(facility, "Bmkolada")!=0 | ///
		strpos(facility, "Mahowe")!=0 | ///
		strpos(facility, "Hnatukunda")!=0 | ///
		strpos(facility, "Ndube")!=0 | ///
		strpos(facility, "Molly")!=0 | ///
		strpos(facility, "Nick")!=0 | ///
		strpos(facility, "Nnestle")!=0 | ///
		strpos(facility, "Jsnow")!=0 | ///
		strpos(facility, "Nmpopo")!=0 | ///
		strpos(facility, "Mavesi")!=0 | ///
		strpos(facility, "rtowett")!=0 | ///
		strpos(facility, "mmoleko")!=0 | ///
		strpos(facility, "dicksoncloudcare")!=0 | ///
		strpos(facility, "dmatsiko")!=0 | ///
		strpos(facility, "ymfunda")!=0 | ///
		strpos(facility, "tmbonambi")!=0 | ///
		strpos(facility, "zjoaki")!=0 | ///
		strpos(facility, "mchitema")!=0 | ///
		strpos(facility, "szondi")!=0 | ///
		strpos(facility, "ggerke")!=0 | ///
		strpos(facility, "userg")!=0 | ///
		strpos(facility, "ndoliwe")!=0 | ///
		strpos(facility, "nango")!=0 | ///
		strpos(facility, "jaloo")!=0 | ///
		strpos(facility, "ngari")!=0 | ///
		strpos(facility, "bmkolada")!=0 | ///
		strpos(facility, "mahowe")!=0 | ///
		strpos(facility, "hnatukunda")!=0 | ///
		strpos(facility, "ndube")!=0 | ///
		strpos(facility, "molly")!=0 | ///
		strpos(facility, "nick")!=0 | ///
		strpos(facility, "nnestle")!=0 | ///
		strpos(facility, "jsnow")!=0 | ///
		strpos(facility, "nmpopo")!=0 | ///
		strpos(facility, "mavesi")!=0 | ///
		strpos(facility, "3")!=0 | ///
		strpos(facility, "5")!=0 | ///
		strpos(facility, "7")!=0 | ///
		strpos(facility, "9")!=0 | ///
		strpos(facility, "10")!=0 | ///
		strpos(facility, "refresher")!=0 | ///
		strpos(facility, "Refresher")!=0 | ///
		strpos(facility, "WC Training")!=0 | ///
		strpos(facility, "Lesotho ToT Facility")!=0 | ///
		strpos(facility, "Aloes guest house clinic")!=0 

	* Save
	drop completed1
	save "$temp_appdata/Clare/`folder'.dta", replace
}
