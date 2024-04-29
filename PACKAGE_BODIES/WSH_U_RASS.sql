--------------------------------------------------------
--  DDL for Package Body WSH_U_RASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_U_RASS" AS
/* $Header: WSHURASB.pls 115.20 2003/09/25 22:16:44 csun ship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) 	:= 'WSH_U_RASS';
	p_message_type	CONSTANT VARCHAR2(1) 	:= 'E';



-- -------------------------------------------------------------------
-- Start of comments
-- API name			: FindServiceRate
--	Type				: public
--	Function			: compose the input string, call UPS APIs and parse
--					  the L_OUTPUT string, place them in the returning
--					  record
--	Version			: Initial version 1.0
-- Notes				: please use :set tabstop=3 to view this file in vi
--					  to get proper alignment
--
-- End of comments
-- ---------------------------------------------------------------------

FUNCTION FindServiceRate(
		p_api_version            IN     NUMBER,
		p_init_msg_list          IN     VARCHAR2,
		x_return_status         OUT NOCOPY      VARCHAR2,
		x_msg_count             OUT NOCOPY      NUMBER,
		x_msg_data              OUT NOCOPY      VARCHAR2,
		p_AppVersion				 IN	  VARCHAR2,
		p_AcceptLicenseAgreement IN     VARCHAR2,
		p_ResponseType				 IN	  VARCHAR2,
		p_request_in				 IN	  RateServiceInRec)
RETURN RateServTableTyp IS

-- standard version infermation
l_api_version	CONSTANT	NUMBER		:= 1.0;
l_api_name	CONSTANT	VARCHAR2(30)   := 'FindServiceRate';


-- standard variable for calling subroutines
l_return_status	VARCHAR2(1)			:= FND_API.G_RET_STS_SUCCESS;
l_msg_count		NUMBER					:= 0;
l_msg_data		VARCHAR2(2000) 		:= NULL;
l_msg_summary	VARCHAR2(2000) 		:= NULL;
l_msg_details	VARCHAR2(4000) 		:= NULL;

l_request_in RateServiceInRec;
L_UPS_URL VARCHAR2(1000)				:= NULL;
L_INTERNET_PROXY VARCHAR2(1000)		:= NULL;

L_INPUT_STR VARCHAR2(2000)				:= NULL;
L_OUTPUT_STR VARCHAR2(10000)			:= NULL;
L_OUTPUT RateServTableTyp;
l_output_data  utl_http.html_pieces;
L_Rate_Message	VARCHAR2(200)			:= NULL;


l_boundary_string_start		NUMBER  := 0;
l_boundary_string_end		NUMBER  := 0;
l_boundary_string			VARCHAR2(100)		 := NULL;
L_UPSONLINE				CONSTANT VARCHAR2(9) := 'UPSOnLine';

L_Locate_Boundry NUMBER 		:= 1;
L_Locate_Str_Len  NUMBER 	:= 1;
L_Locate_Str_Len_End  NUMBER 	:= 1;
L_Content_Str_Len NUMBER 	:= 1;
L_Locate_Begin   NUMBER 		:= 1;
L_Locate_Boundry_End NUMBER 	:= 1;
L_Token_Start NUMBER 		:= 1;
L_Token_End NUMBER 			:= 0;
L_Str_Len NUMBER			:= 0;
l_outrec_index BINARY_INTEGER := 0;
l_find_error NUMBER 		:= 0;
j NUMBER := 0;

WSH_U_CAR_URL			exception;
WSH_U_PROXY			exception;
WSH_U_APPVER			exception;
WSH_U_LICAGRE			exception;
WSH_U_RESTYP			exception;
WSH_U_ACTIONCODE		exception;
WSH_U_SRVLEVCODE		exception;
WSH_U_RATECHART		exception;
WSH_U_SPOSTALCODE		exception;
WSH_U_CPOSTALCODE		exception;
WSH_U_CCOUNTRY			exception;
WSH_U_PKGACTWT			exception;
WSH_U_RESDIND			exception;
WSH_U_PKGTYPE			exception;
WSH_U_NO_HOST			exception;
REQUEST_FAILED			exception;
INIT_FAILED			exception;
--Bug 2993856 : Added new exception
WSH_U_HOST_FAILED               exception;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FINDSERVICERATE';
--
BEGIN
     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'P_APPVERSION',P_APPVERSION);
         WSH_DEBUG_SV.log(l_module_name,'P_ACCEPTLICENSEAGREEMENT',P_ACCEPTLICENSEAGREEMENT);
         WSH_DEBUG_SV.log(l_module_name,'P_RESPONSETYPE',P_RESPONSETYPE);
     END IF;
     --
     L_OUTPUT.delete;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.compatible_api_call(	l_api_version,
 									p_api_version,
									l_api_name,
									G_PKG_NAME) THEN
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Not Compatible');
                END IF;
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list)	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	x_msg_count 	:= 0;
	x_msg_data 	:= NULL;


	-- program specific logic begins here


     l_request_in := p_request_in;

	L_UPS_URL := WSH_U_UTIL.Get_Carrier_API_URL(
	 					p_api_version		=> 1.0,
						p_init_msg_list	=> FND_API.G_TRUE,
						x_return_status	=> l_return_status,
						x_msg_count         => l_msg_count,
						x_msg_data          => l_msg_data,
						p_Carrier_Name		=> 'UPS',
						p_API_Name		=> 'RATING_AND_SERVICE_SELECTION');
	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise WSH_U_CAR_URL;
	 end if;

	 -- constructing the  request sent to UPS API
    	 L_INPUT_STR := L_UPS_URL || '?';

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'L_UPS_URL',SUBSTR(L_UPS_URL,1,250));
         END IF;
	 -- ---------------------------------------------------------------
	 -- UPS standard parameters: AppVersion
	 --                          AcceptLicenseAgreement
	 --	     			    ResponseType
	 -- ---------------------------------------------------------------

	 -- AppVersion ---------------------------------------------------------
      if( p_AppVersion IS NULL) then
			raise WSH_U_APPVER;
			-- l_request_in.AppVersion := '1.1';
      end if;
	 L_INPUT_STR := L_INPUT_STR || 'AppVersion' ||'='|| p_AppVersion;

	 -- AcceptLicenseAgreement ---------------------------------------------
      if( p_AcceptLicenseAgreement IS NULL) then
			raise WSH_U_LICAGRE;
			-- l_request_in.AcceptLicenseAgreement := 'YES';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' ||'AcceptUPSLicenseAgreement'||'=' || p_AcceptLicenseAgreement;


	 -- ResponseType --------------------------------------------------------
      if( p_ResponseType IS NULL) then
			raise WSH_U_RESTYP;
			-- l_request_in.ResponseType := 'application/x-ups-rss';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ResponseType' ||'='|| p_ResponseType;



	 -- ---------------------------------------------------------------
	 -- Program specific parameters start here
	 -- ---------------------------------------------------------------

	 -- ActionCode --------------------------------------------------------
      if(l_request_in.ActionCode IS NULL) then
			raise WSH_U_ACTIONCODE;
			-- l_request_in.ActionCode := '3';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ActionCode' ||'='|| l_request_in.ActionCode;


	 -- ServiceLevelCode ---------------------------------------------------
      if(l_request_in.ServiceLevelCode IS NULL) then
			raise WSH_U_SRVLEVCODE;
			-- l_request_in.ServiceLevelCode := '1DA';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ServiceLevelCode'||'=' || l_request_in.ServiceLevelCode;


	 -- RateChart ---------------------------------------------------
      if(l_request_in.RateChart IS NULL) then
			raise WSH_U_RATECHART;
			-- l_request_in.RateChart :=  'Regular+Daily+Pickup';
      end if;

      L_INPUT_STR := L_INPUT_STR || '&' || 'RateChart' ||'='|| l_request_in.RateChart;


	 -- ShipperPostalCode ---------------------------------------------------
      if(l_request_in.ShipperPostalCode IS NULL) then
			raise WSH_U_SPOSTALCODE;
			-- l_request_in.ShipperPostalCode := '94065';
      end if;

      L_INPUT_STR := L_INPUT_STR || '&' || 'ShipperPostalCode' ||'='|| l_request_in.ShipperPostalCode;


	 -- ConsigneePostalCode --------------------------------------------------
      if(l_request_in.ConsigneePostalCode IS NULL) then
			raise WSH_U_CPOSTALCODE;
			-- l_request_in.ConsigneePostalCode := '60089';
      end if;

      L_INPUT_STR := L_INPUT_STR || '&' || 'ConsigneePostalCode' ||'='|| l_request_in.ConsigneePostalCode;


	 -- ConsigneeCountry --------------------------------------------------
      if(l_request_in.ConsigneeCountry IS NULL) then

		   raise WSH_U_CCOUNTRY;
			-- l_request_in.ConsigneeCountry := 'US';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ConsigneeCountry' ||'='|| l_request_in.ConsigneeCountry;

	 -- PackageActualWeight --------------------------------------------------
      if(l_request_in.PackageActualWeight IS NULL) then
			raise WSH_U_PKGACTWT;
			-- l_request_in.PackageActualWeight := 25;
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'PackageActualWeight'||'=' ||
				 fnd_number.number_to_canonical(l_request_in.PackageActualWeight);


	 -- DeclaredValueInsurance --------------------------------------------------
      if(l_request_in.DeclaredValueInsurance IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'DeclaredValueInsurance'||'=' || fnd_number.number_to_canonical(l_request_in.DeclaredValueInsurance);
      end if;


	 -- PackageLength --------------------------------------------------
      if(l_request_in.PackageLength IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'Length' ||'='|| fnd_number.number_to_canonical(l_request_in.PackageLength);
      end if;


	 -- PackageWidth --------------------------------------------------
      if(l_request_in.PackageWidth IS NOT NULL) then
	     L_INPUT_STR := L_INPUT_STR || '&' || 'Width' ||'='|| fnd_number.number_to_canonical(l_request_in.PackageWidth);
      end if;



	 -- PackageHight --------------------------------------------------
      if(l_request_in.PackageHight IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'Hight' ||'='|| fnd_number.number_to_canonical(l_request_in.PackageHight);
      end if;


	 -- OverSizeIndicator --------------------------------------------------
      if(l_request_in.OverSizeIndicator IS NOT NULL) then
	     L_INPUT_STR := L_INPUT_STR || '&' || 'OversizeInd' ||'='|| l_request_in.OverSizeIndicator;
      end if;


	 -- CODIndicator --------------------------------------------------
      if(l_request_in.CODIndicator IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'CODInd' ||'='|| l_request_in.CODIndicator;
      end if;


	 -- HazMat --------------------------------------------------
      if(l_request_in.HazMat IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'HazMat' ||'='|| l_request_in.HazMat;
      end if;




	 -- AdditionalHandlingInd --------------------------------------------------
    	 if(l_request_in.AdditionalHandlingInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'AdditionalHandlingInd'||'=' || l_request_in.AdditionalHandlingInd;
      end if;



	 -- CallTagARSInd --------------------------------------------------
      if(l_request_in.CallTagARSInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'CallTagARSInd' ||'='|| l_request_in.CallTagARSInd;
      end if;


	 -- SatDeliveryInd --------------------------------------------------
      if(l_request_in.SatDeliveryInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'SatDeliveryInd' ||'='|| l_request_in.SatDeliveryInd;
      end if;


	 -- SatPickupInd --------------------------------------------------
      if(l_request_in.SatPickupInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'SatPickupInd' ||'='|| l_request_in.SatPickupInd;
      end if;


	 -- DCISInd --------------------------------------------------
      if(l_request_in.DCISInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'DCISInd' ||'='|| l_request_in.DCISInd;
      end if;


	 -- VerbalConfirmationInd ------------------------------------------------
      if(l_request_in.VerbalConfirmationInd IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'VerbalConfirmationInd' ||'='|| l_request_in.VerbalConfirmationInd;
      end if;



	 -- SNDestinationInd1 --------------------------------------------------
      if(l_request_in.SNDestinationInd1 IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'SNDestinationInd1' ||'='|| l_request_in.SNDestinationInd1;
      end if;


	 -- SNDestinationInd2 --------------------------------------------------
      if(l_request_in.SNDestinationInd2 IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'SNDestinationInd2' ||'='|| l_request_in.SNDestinationInd2;
      end if;


	 -- ResidentialInd --------------------------------------------------
      if(l_request_in.ResidentialInd IS NULL) then
			raise WSH_U_RESDIND;
			-- l_request_in.ResidentialInd := '0';
      end if;

      L_INPUT_STR := L_INPUT_STR || '&' || 'ResidentialInd' ||'='|| l_request_in.ResidentialInd;


	 -- PackagingType --------------------------------------------------
      if(l_request_in.PackagingType IS NULL) then
			raise WSH_U_PKGTYPE;
			-- l_request_in.PackagingType := '00';
      end if;

      L_INPUT_STR := L_INPUT_STR || '&' || 'PackagingType' ||'='|| l_request_in.PackagingType;
		L_INPUT_STR := REPLACE(L_INPUT_STR, ' ', '+');

  /*DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,0,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,51,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,101,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,151,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,201,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,251,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,301,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,351,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,401,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,451,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,501,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,551,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,601,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,651,50));
    DBMS_OUTPUT.PUT_LINE('INPUT:'||SUBSTR(L_INPUT_STR,701,50));
*/
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,0,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,51,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,101,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,151,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,201,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,251,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,301,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,351,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,401,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,451,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,501,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,551,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,601,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,651,50));
           WSH_DEBUG_SV.log(l_module_name,'Input',SUBSTR(L_INPUT_STR,701,50));
        END IF;
		-- clear variables before calling subroutine
	l_return_status	:= FND_API.G_RET_STS_SUCCESS;
	l_msg_count			:= 0;
	l_msg_data			:= NULL;

		-- get proxy server URL
		--
		L_INTERNET_PROXY := WSH_U_UTIL.Get_PROXY(
	 					p_api_version		=> 1.0,
						p_init_msg_list	=> FND_API.G_TRUE,
						x_return_status	=> l_return_status,
						x_msg_count         => l_msg_count,
						x_msg_data          => l_msg_data);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				raise WSH_U_PROXY;
		end if;

		-- send request to UPS site
		if L_INTERNET_PROXY is not NULL then
	   		l_output_data := utl_http.request_pieces(L_INPUT_STR,100,L_INTERNET_PROXY);
		else
	   		l_output_data := utl_http.request_pieces(L_INPUT_STR,100);
		end if;
		-- when no response is received from a request to a given URL
		-- then a formatted HTML error message may be returned, it contains the
		-- following error message
		l_find_error := INSTR(l_output_data(1), 'Can''t locate remote host');
		if l_find_error <> 0 then
		   raise WSH_U_NO_HOST;
		end if;

		-- It is only good for up to 10 iteration else it will fail.
		FOR i in 1 .. l_output_data.count LOOP
			L_OUTPUT_STR := L_OUTPUT_STR || l_output_data(i);
		END LOOP;


    		l_boundary_string_start	:= INSTR(L_OUTPUT_STR, 'boundary=', 1 , 1);
		if l_boundary_string_start <> 0 then
    			l_boundary_string_start	:= l_boundary_string_start + 9;
			-- l_boundary_string_end	:= INSTR(L_OUTPUT_STR, '--', l_boundary_string_start,1);
			l_boundary_string_end	:= INSTR(L_OUTPUT_STR, FND_GLOBAL.LOCAL_CHR(13), l_boundary_string_start,1);
			l_boundary_string		:= SUBSTR(L_OUTPUT_STR,
									l_boundary_string_start ,
	 								l_boundary_string_end - l_boundary_string_start);
		else

			l_boundary_string		:= 'UPSBOUNDARY';
		end if;
		l_boundary_string := '--' || l_boundary_string;
		-- DBMS_OUTPUT.PUT_LINE('Boundary String:'|| l_boundary_string);
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Boundary String',l_boundary_string);
                END IF;

    LOOP
 		L_Locate_Boundry := INSTR(L_OUTPUT_STR, l_boundary_string,
							 L_Locate_Boundry ,1);

		L_Locate_Str_Len  := INSTR(L_OUTPUT_STR, 'Content-length',L_Locate_Boundry,1);
		-- DBMS_OUTPUT.PUT_LINE('l_locate_str_len:' ||to_char( L_Locate_Str_Len));
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_locate_str_len',l_locate_str_len);
                END IF;
		L_Locate_Begin   := INSTR(L_OUTPUT_STR, L_UPSONLINE ,L_Locate_Boundry,1);
		L_Locate_Boundry_End := INSTR(L_OUTPUT_STR, l_boundary_string, L_Locate_Boundry,2);

		IF(L_Locate_Boundry_End > L_Locate_Begin) THEN

                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'J BEGIN',l_outrec_index);
                END IF;
			--DBMS_OUTPUT.PUT_LINE('J BEGIN:' || to_char(l_outrec_index));
     		l_outrec_index := l_outrec_index + 1;
			--DBMS_OUTPUT.PUT_LINE('l_outrec_index END:' || to_char(l_outrec_index));
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_outrec_index',l_outrec_index);
                END IF;

         L_Locate_Str_Len_End := INSTR(L_OUTPUT_STR, FND_GLOBAL.LOCAL_CHR(13), L_Locate_Str_Len, 1);
			-- DBMS_OUTPUT.PUT_LINE('l_locate_str_len_end:' ||to_char( L_Locate_Str_Len_end));
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_locate_str_len_end',l_locate_str_len_end);
                END IF;
			L_Content_Str_Len := TO_NUMBER(SUBSTR(L_OUTPUT_STR,(L_Locate_Str_Len+16),L_Locate_Str_Len_End - L_Locate_Str_Len - 16));

			-- DBMS_OUTPUT.PUT_LINE('string length:' || to_char(L_Content_Str_Len));
               IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'L_Content_Str_Len',L_Content_Str_Len);
                END IF;

			L_Rate_Message := SUBSTR(L_OUTPUT_STR, L_Locate_Begin, L_Content_Str_Len);
			L_Token_Start := 0;
			L_Token_End := 0;

			L_OUTPUT(l_outrec_index).UPSOnLine := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
			L_OUTPUT(l_outrec_index).AppVersion := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
			L_OUTPUT(l_outrec_index).ReturnCode := TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Rate_Message, L_Token_Start,L_Token_End));
			L_OUTPUT(l_outrec_index).MessageText := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
			L_OUTPUT(l_outrec_index).MessageNumber := TO_NUMBER(SUBSTR(L_OUTPUT(l_outrec_index).MessageText,1,4));
			L_OUTPUT(l_outrec_index).MessageText := SUBSTR(L_OUTPUT(l_outrec_index).MessageText,5,(LENGTH(L_OUTPUT(l_outrec_index).MessageText)-4));


			IF(L_OUTPUT(l_outrec_index).ReturnCode = 0) THEN
				L_OUTPUT(l_outrec_index).ActionCode := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	    		L_OUTPUT(l_outrec_index).ServiceLevelCode := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	    		L_OUTPUT(l_outrec_index).ShipperPostalCode := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	    		L_OUTPUT(l_outrec_index).ShipperCountry := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	    		L_OUTPUT(l_outrec_index).ConsigneePostalCode := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	    		L_OUTPUT(l_outrec_index).ConsigneeCountry := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
				L_OUTPUT(l_outrec_index).DeliverZone := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);
	     		L_OUTPUT(l_outrec_index).PackageActualWeight := FND_NUMBER.canonical_to_number(WSH_U_UTIL.Calculate_Token(L_Rate_Message, L_Token_Start,L_Token_End));
	     		L_OUTPUT(l_outrec_index).ProductCharge := FND_NUMBER.canonical_to_number(WSH_U_UTIL.Calculate_Token(L_Rate_Message, L_Token_Start,L_Token_End));
	     		L_OUTPUT(l_outrec_index).AccessorySurcharge := FND_NUMBER.canonical_to_number(WSH_U_UTIL.Calculate_Token(L_Rate_Message, L_Token_Start,L_Token_End));
	     		L_OUTPUT(l_outrec_index).TotalCharge := FND_NUMBER.canonical_to_number(WSH_U_UTIL.Calculate_Token(L_Rate_Message, L_Token_Start,L_Token_End));
	    		L_OUTPUT(l_outrec_index).CommitTime := WSH_U_UTIL.Calculate_Token(L_Rate_Message,L_Token_Start,L_Token_End);

	/*		   if	L_OUTPUT(l_outrec_index).MessageText is not NULL then
			     	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			     	FND_MESSAGE.SET_NAME('WSH',L_OUTPUT(l_outrec_index).MessageText);
				     WSH_UTIL_CORE.Add_Message('W',l_module_name);
			   end if;
      */
			ELSE
/*				FND_MESSAGE.SET_NAME('WSH',L_OUTPUT(l_outrec_index).MessageText);
				WSH_UTIL_CORE.Add_Message('E',l_module_name);
*/
-- Bug #2993856 : Adding the error message to the message stack
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_E');
                       FND_MESSAGE.SET_TOKEN('MSG_TEXT',L_OUTPUT(l_outrec_index).MessageText);
                       WSH_UTIL_CORE.Add_Message(p_message_type);
                       L_OUTPUT(l_outrec_index).ActionCode := NULL;
	    			L_OUTPUT(l_outrec_index).ServiceLevelCode := NULL;
	    			L_OUTPUT(l_outrec_index).ShipperPostalCode := NULL;
	    			L_OUTPUT(l_outrec_index).ShipperCountry := NULL;
	    			L_OUTPUT(l_outrec_index).ConsigneePostalCode := NULL;
	    			L_OUTPUT(l_outrec_index).ConsigneeCountry := NULL;
				L_OUTPUT(l_outrec_index).DeliverZone := NULL;
	     		L_OUTPUT(l_outrec_index).PackageActualWeight := NULL;
	     		L_OUTPUT(l_outrec_index).ProductCharge := NULL;
	     		L_OUTPUT(l_outrec_index).AccessorySurcharge := NULL;
	     		L_OUTPUT(l_outrec_index).TotalCharge := NULL;
	    		L_OUTPUT(l_outrec_index).CommitTime := NULL;
			END IF;
	  END IF;

	  L_Locate_Boundry := L_Locate_Boundry_End;
 	  EXIT WHEN L_Locate_Begin = 0;

    END LOOP;
-- Bug 2993856: Handling the error message returned by the HOST. This exception sends the error text returned from the HOST
    IF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
         raise WSH_U_HOST_FAILED;
    END IF;

    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN L_OUTPUT;


exception

		WHEN WSH_U_CAR_URL THEN
		   FND_MESSAGE.SET_NAME('WSH', 'WSH_U_CAR_URL');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CAR_URL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CAR_URL');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_PROXY THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_PROXY');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
	  	    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_PROXY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
	  	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_PROXY');
			END IF;
			--
			return L_OUTPUT;

	  	-- this exception is produced by UTL_HTTP.REQUEST_PIECES
	  	-- The http call fails(for example, bacause of failure of the HTTP
	  	-- daemon, or bacause the argument to REQUEST_PIECES cannot be interpreted
	  	-- as a URL because it is NULL or has non-HTTP syntax)
		WHEN REQUEST_FAILED THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_REQ_FAILED');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
		            WSH_DEBUG_SV.logmsg(l_module_name,'REQUEST_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REQUEST_FAILED');
			END IF;
			--
			return L_OUTPUT;

	  	-- this exception is produced by UTL_HTTP.REQUEST_PIECES
	  	-- Initialization of the HTTP callout subsystem failed
		-- for invironmental reasons such as lack of available memory
		WHEN INIT_FAILED THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_INIT_FAILED');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'INIT_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INIT_FAILED');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_NO_HOST THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_NO_HOST');
			WSH_UTIL_CORE.ADD_MESSAGE('E',l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_NO_HOST exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_NO_HOST');
			END IF;
			--
			return L_OUTPUT;
		WHEN  WSH_U_APPVER THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_APPVER');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_APPVER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_APPVER');
			END IF;
			--
			return L_OUTPUT;
		WHEN  WSH_U_LICAGRE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_LICAGRE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_LICAGRE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_LICAGRE');
			END IF;
			--
			return L_OUTPUT;
		WHEN  WSH_U_RESTYP THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_RESTYP');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_RESTYP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_RESTYP');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_ACTIONCODE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_ACTIONCODE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_ACTIONCODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_ACTIONCODE');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_SRVLEVCODE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_SRVLEVCODE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_SRVLEVCODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_SRVLEVCODE');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_RATECHART THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_RATECHART');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_RATECHART exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_RATECHART');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_SPOSTALCODE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_SPOSTALCODE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_SPOSTALCODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_SPOSTALCODE');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_CPOSTALCODE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_CPOSTALCODE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CPOSTALCODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CPOSTALCODE');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_CCOUNTRY THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_CCOUNTRY');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CCOUNTRY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CCOUNTRY');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_PKGACTWT THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_PKGACTWT');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_PKGACTWT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_PKGACTWT');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_RESDIND THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_RESDIND');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_RESDIND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_RESDIND');
			END IF;
			--
			return L_OUTPUT;
		WHEN WSH_U_PKGTYPE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_PKGTYPE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type,l_module_name);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;
			--
			IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_PKGTYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_PKGTYPE');
			END IF;
			--
			return L_OUTPUT;
-- Bug 2993856 :Handling the exception WSH_U_HOST_FAILED
                WHEN WSH_U_HOST_FAILED THEN
                        WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
                        if x_msg_count > 1 then
                                x_msg_data := l_msg_summary || l_msg_details;
                        else
                                x_msg_data := l_msg_summary;
                        end if;
                        -- To remove the prefix word "Error:" from the original error message
                        x_msg_data := SUBSTR(x_msg_data,INSTR(x_msg_data,':') + 2);

                         --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'x_msg_data',SUBSTR(x_msg_data,1,200));
                            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_HOST_FAILED  exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_HOST_FAILED');
                        END IF;
                        --
                        return L_OUTPUT;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
			--
			IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
			END IF;
			--
			return L_OUTPUT;
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
			--
			IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
			return L_OUTPUT;
END FindServiceRate;


-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Load_Headers
--	Type				: public
--	Function			: This procedure is used by the form to populate
--                   the UPS_SRV_HEADER block, the select statement
--                   is passed as a parameter, which is dynamically
--                   constructed as the transaction form passes the
--                   selected delivery_detail_id to the UPS Rate
--                   and Service Selection form
-- Output          : a table of ship_from_location_id and
--                   ship_to_location_id
-- Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------
procedure load_headers(
	p_select_statement  IN       varchar2,
	x_headers           IN OUT NOCOPY    wsh_u_rass.HeaderRecTableTyp)


is

l_CursorID integer;
l_SelectStmt VARCHAR2(3000) := NULL;
l_ship_from_location_id  number := 0;
l_ship_to_location_id number := 0;
l_dummy integer;
l_index integer := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOAD_HEADERS';
--
begin


/* construct a dynamic sql select statement and get the
   records */

/* the sql statement should look like
  select distinct ship_from_location_id, ship_to_location_id
  from (
	select * from wsh_delivery_detail_id where delivery_detail_id
	in (4941, 4942))
*/

--
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_SELECT_STATEMENT',P_SELECT_STATEMENT);
END IF;
--
l_CursorID := DBMS_SQL.OPEN_CURSOR;
l_SelectStmt := p_select_statement;
DBMS_SQL.PARSE(l_CursorID, l_SelectStmt, DBMS_SQL.V7);
DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, l_ship_from_location_id);
DBMS_SQL.DEFINE_COLUMN(l_CursorID, 2, l_ship_to_location_id);
l_dummy := DBMS_SQL.EXECUTE(l_CursorID);


loop
	if DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 then
		exit;
	end if;
	DBMS_SQL.COLUMN_VALUE(l_CursorID, 1, l_ship_from_location_id);
	DBMS_SQL.COLUMN_VALUE(l_CursorID, 2, l_ship_to_location_id);
	l_index := l_index + 1;
	x_headers(l_index).ship_from_location_id := l_ship_from_location_id;
	x_headers(l_index).ship_to_location_id := l_ship_to_location_id;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_ship_from_location_id',l_ship_from_location_id);
           WSH_DEBUG_SV.log(l_module_name,'l_ship_to_location_id',l_ship_to_location_id);
        END IF;
end loop;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
end  load_headers;



END WSH_U_RASS;


/
