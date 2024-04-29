--------------------------------------------------------
--  DDL for Package Body WSH_U_TRACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_U_TRACK" AS
/* $Header: WSHUTRKB.pls 115.14 2002/11/12 02:03:07 nparikh ship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) 		:= 'WSH_U_TRACK';
	p_message_type	CONSTANT VARCHAR2(1) 	:= 'E';






-- -------------------------------------------------------------------
-- Start of comments
-- API name			: EnhancedTracking
--	Type				: public
--	Function			: compose the input string, call UPS APIs and parse
--						  the L_OUTPUT string, place them in the returning
--
--	Version			: Initial version 1.0
-- Notes
--
-- End of comments

-- ---------------------------------------------------------------------
PROCEDURE EnhancedTracking(
								  p_api_version            IN		NUMBER,
								  p_init_msg_list          IN		VARCHAR2,
								  x_return_status         OUT NOCOPY 		VARCHAR2,
								  x_msg_count             OUT NOCOPY 		NUMBER,
								  x_msg_data              OUT NOCOPY 		VARCHAR2,
								  p_AppVersion					IN		VARCHAR2,
								  p_AcceptLicenseAgreement IN		VARCHAR2,
	 							  p_ResponseType				IN		VARCHAR2,
								  p_request_in					IN		EnhancedTrackInRec,
                          x_track_header			  OUT NOCOPY 		TrackHeaderRec,
                          x_track_error			  OUT NOCOPY 		TrackErrorRec,
                          x_track_address			  OUT NOCOPY 		TrackAddressTblTyp,
                          x_multi_sum_header		  OUT NOCOPY 		MultiSumHdrTblTyp,
                          x_multi_sum_detail		  OUT NOCOPY 		MultiSumDtlTblTyp,
                          x_pkg_detail_segment	  OUT NOCOPY 		PkgDtlSegTblTyp,
                          x_pkg_progress			  OUT NOCOPY 		PkgProgressHdrRec,
                          x_activity_detail		  OUT NOCOPY 		ActivityDetailTblTyp) IS

		-- standard version infermation
		l_api_version	CONSTANT	NUMBER		:= 1.0;
		l_api_name	CONSTANT	VARCHAR2(30)   := 'EnhancedTracking';

		-- standard variables
		l_return_status	VARCHAR2(1)			:= FND_API.G_RET_STS_SUCCESS;
		l_msg_count		NUMBER					:= 0;
		l_msg_data		VARCHAR2(2000) 		:= NULL;
		l_msg_summary	VARCHAR2(2000) 		:= NULL;
		l_msg_details	VARCHAR2(4000) 		:= NULL;


		-- L_UPS_URL VARCHAR2(200) := 'http://wwwapps.ups.com/etracking/tracking.cgi';
		L_UPS_URL VARCHAR2(1000) := NULL;
		L_INTERNET_PROXY VARCHAR2(1000) := NULL;

		l_boundary_string_start		NUMBER  := 0;
		l_boundary_string_end			NUMBER  := 0;
		l_boundary_string				VARCHAR2(100)		 := NULL;

		L_Content_Str_Len NUMBER					:= 0;
		l_sub_str_len NUMBER := 0;
		l_loop_counter_limit  NUMBER := 0;
		l_remainder NUMBER := 0;
		j NUMBER := 0;

		l_request_in EnhancedTrackInRec;

		L_INPUT_STR VARCHAR2(2000);
		L_OUTPUT_STR VARCHAR2(10000);
		l_output_data  utl_http.html_pieces;

		L_Track_Message VARCHAR2(500);

		L_Content_Type VARCHAR2(200);
		L_Previous_Content_Type VARCHAR2(200);

		l_date_string VARCHAR2(8) := NULL;
		l_time_string VARCHAR2(6) := NULL;

		L_Locate_boundary NUMBER := 1;
		L_Locate_Str_Len  NUMBER := 1;
		L_Locate_Str_Len_End NUMBER := 0;
		L_Locate_Content  NUMBER :=1;
		L_Locate_boundary_End NUMBER := 1;
		L_Locate_Begin   NUMBER := 1;
		L_Token_Start NUMBER := 1;
		L_Token_End NUMBER := 0;


		l_track_address_i BINARY_INTEGER	:= 0;
		l_multi_sum_header_i BINARY_INTEGER		:= 0;
		l_multi_sum_detail_i BINARY_INTEGER		:= 0;
		l_pkg_detail_segment_i BINARY_INTEGER	:= 0;
		l_activity_detail_i BINARY_INTEGER		:= 0;



		-- this is used to print the debug message only
		l_outrec_index BINARY_INTEGER := 0;
		l_char_index NUMBER;
		l_find_error NUMBER := 0;
		WSH_U_INPUT_PARAMETER 	exception;
		WSH_U_CAR_URL				exception;
		WSH_U_PROXY					exception;
		WSH_U_APPVER				exception;
		WSH_U_LICAGRE				exception;
		WSH_U_RESTYP				exception;
		WSH_U_INQNO					exception;
		WSH_U_TYP_INQNO			exception;
		WSH_U_NO_HOST			exception;
		REQUEST_FAILED			exception;
		INIT_FAILED			exception;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ENHANCEDTRACKING';
--
BEGIN

		-- Standard call to check for call compatibility.
		--
		-- Debug Statements
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
		IF NOT FND_API.compatible_api_call(	l_api_version,
 										p_api_version,
										l_api_name,
										G_PKG_NAME) THEN
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


		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.GET_CARRIER_API_URL',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		L_UPS_URL := WSH_U_UTIL.Get_Carrier_API_URL(
	 						p_api_version		=> 1.0,
							p_init_msg_list	=> FND_API.G_TRUE,
							x_return_status	=> l_return_status,
							x_msg_count       => l_msg_count,
							x_msg_data        => l_msg_data,
							p_Carrier_Name		=> 'UPS',
							p_API_Name		   => 'ENHANCED_TRACKING');
		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				raise WSH_U_CAR_URL;
		end if;

		L_INPUT_STR := L_UPS_URL || '?';

		-- ---------------------------------------------------------------
		-- UPS standard parameters: AppVersion
		--                          AcceptLicenseAgreement
		--	     							 ResponseType
		-- ---------------------------------------------------------------

		-- AppVersion ---------------------------------------------------------
      if( p_AppVersion IS NULL) then
			raise WSH_U_APPVER;
			-- l_request_in.AppVersion := '1.0';
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
			-- l_request_in.ResponseType := 'application/x-ups-tracking-full-response';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ResponseType' ||'='|| p_ResponseType;

		-- ---------------------------------------------------------------
		-- Program specific parameters start here
		-- ---------------------------------------------------------------
		-- Inquiry Number ------------------------------------------------
		if(l_request_in.InquiryNumber IS NULL) then
			-- l_request_in.InquiryNumber := '3';
			raise WSH_U_INQNO;
		end if;


		L_INPUT_STR := L_INPUT_STR || '&' || 'InquiryNumber' ||'='|| l_request_in.InquiryNumber;

		-- Type of Inquiry Number --------------------------------------------
		if(l_request_in.TypeOfInquiryNumber IS NULL) then
			-- l_request_in.TypeOfInquiryNumber := 'T';
			raise WSH_U_TYP_INQNO;
		end if;
		L_INPUT_STR := L_INPUT_STR || '&' || 'TypeOfInquiryNumber'||'=' || l_request_in.TypeOfInquiryNumber;

		-- if l_request_in is in (M, D, P), it is a follow up request, internalKey is required.
		if((l_request_in.TypeOfInquiryNumber = 'M' OR
			l_request_in.TypeOfInquiryNumber = 'D' OR
			l_request_in.TypeOfInquiryNumber = 'P')AND
			l_request_in.InternalKey is NULL) THEN
			raise WSH_U_INPUT_PARAMETER;
		end if;

		-- -------------------------------------------------------------------
		-- INternal Key is required for subsuccessive request, ignored in the
		-- initial request
		-- -------------------------------------------------------------------
		if(l_request_in.InternalKey IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'InternalKey' ||'='|| l_request_in.InternalKey;
		end if;


		-- Sender Shipper Number ------------------------------------------------
		if(l_request_in.SenderShipperNumber IS NOT NULL) then
			L_INPUT_STR := L_INPUT_STR || '&' || 'SenderShipperNumber' ||'='|| l_request_in.SenderShipperNumber;
		end if;


		-- From Pickup Date -----------------------------------------------------
		if(l_request_in.FromPickupDate IS NOT NULL) then
    		L_INPUT_STR := L_INPUT_STR || '&' || 'FromPickupDate' ||'='|| TO_CHAR(l_request_in.FromPickupDate, 'YYYYMMDD');
		end if;


		-- To Pickup Date -------------------------------------------------------
		if(l_request_in.ToPickupDate IS NOT NULL) then
    		L_INPUT_STR := L_INPUT_STR || '&' || 'ToPickupDate' ||'='|| TO_CHAR(l_request_in.ToPickupDate, 'YYYYMMDD');
		end if;


		-- Destination Postal Code ----------------------------------------------
		if(l_request_in.DestinationPostalCode IS NOT NULL) then
    		L_INPUT_STR := L_INPUT_STR || '&' || 'DestinationPostalCode'||'=' || l_request_in.DestinationPostalCode;
		end if;


		-- Destination Country --------------------------------------------------
		if(l_request_in.DestinationCountry IS NOT NULL) then
    		L_INPUT_STR := L_INPUT_STR || '&' || 'DestinationCountry'||'=' || l_request_in.DestinationCountry;
		end if;

		L_INPUT_STR := REPLACE(L_INPUT_STR, ' ', '+');

		-- DBMS_OUTPUT.PUT_LINE('========== request begin =========');
	   -- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,0,50));
		-- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,51,50));
		-- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,101,50));
		-- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,151,50));
		-- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,201,50));
		-- DBMS_OUTPUT.PUT_LINE(SUBSTR(L_INPUT_STR,251,50));
		-- DBMS_OUTPUT.PUT_LINE('========== request end =========');

		-- clear variables before calling subroutine
		l_return_status	:= FND_API.G_RET_STS_SUCCESS;
		l_msg_count			:= 0;
		l_msg_data			:= NULL;


	 	-- get proxy server URL
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.GET_PROXY',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		L_INTERNET_PROXY := WSH_U_UTIL.Get_PROXY(
	 					p_api_version			=> 1.0,
						p_init_msg_list		=> FND_API.G_TRUE,
						x_return_status		=> l_return_status,
						x_msg_count				=> l_msg_count,
						x_msg_data				=> l_msg_data);

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


		-- It is only good for up to 100 iteration else it will fail.
		-- DBMS_OUTPUT.PUT_LINE('======= result begin =============');
		FOR i in 1 .. l_output_data.count LOOP
				L_OUTPUT_STR := L_OUTPUT_STR || l_output_data(i);
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 1, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 251, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 501, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 751, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 1001, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 1251, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 1501, 250));
				-- DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), 1751, 250));

/*				l_sub_str_len := length(l_output_data(i));
				l_loop_counter_limit := l_sub_str_len / 250;
				l_remainder :=     MOD(l_sub_str_len,250);
				j := 0;
				DBMS_OUTPUT.PUT_LINE('******* Inner loop ********');
				loop
					if j < l_loop_counter_limit then
					   if l_remainder <> l_sub_str_len then
						 	DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), j*250+1, l_remainder));
							exit;
						else
							exit;
						end if;
					else
						DBMS_OUTPUT.PUT_LINE(SUBSTR(l_output_data(i), j*250+1, 250));
						j := j+1;
					end if;

				end loop;
				DBMS_OUTPUT.PUT_LINE('******* Inner loop ********');
*/
				-- EXIT WHEN i = 100;
		END LOOP;
		-- DBMS_OUTPUT.PUT_LINE('========== result end ===========');
    	l_boundary_string_start		:= INSTR(L_OUTPUT_STR, 'boundary=', 1 , 1);
		if l_boundary_string_start <> 0 then
    		l_boundary_string_start		:= l_boundary_string_start + 9;
			-- l_boundary_string_end	:= INSTR(L_OUTPUT_STR, '--', l_boundary_string_start,1);
			l_boundary_string_end		:= INSTR(L_OUTPUT_STR, FND_GLOBAL.LOCAL_CHR(13), l_boundary_string_start,1);
			l_boundary_string				:= SUBSTR(L_OUTPUT_STR,
													l_boundary_string_start ,
	 												l_boundary_string_end - l_boundary_string_start);
		else

			l_boundary_string		:= 'UPSBOUNDARYUPS';
		end if;
		l_boundary_string := '--' || l_boundary_string;
		-- DBMS_OUTPUT.PUT_LINE('Boundary String:'|| l_boundary_string);



		LOOP

 				L_Locate_boundary :=INSTR(L_OUTPUT_STR, l_boundary_string ,L_Locate_boundary,1);
				L_Locate_Content := INSTR(L_OUTPUT_STR,'Content-type',L_Locate_boundary,1);
				-- DBMS_OUTPUT.PUT_LINE('LOCATE CONTENT IS************'||to_char(L_Locate_Content));
				L_Locate_Str_Len  := INSTR(L_OUTPUT_STR, 'Content-length',L_Locate_boundary,1);
				-- DBMS_OUTPUT.PUT_LINE('LOCATE STR IS************'||to_char(L_Locate_Str_Len));
    			L_Locate_Begin   := INSTR(L_OUTPUT_STR,'UPSOnLine',L_Locate_boundary,1);
				-- DBMS_OUTPUT.PUT_LINE('LOCATE BEGIN IS************'||to_char(L_Locate_Begin));
				L_Locate_boundary_End := INSTR(L_OUTPUT_STR, l_boundary_string ,L_Locate_boundary,2);
				-- DBMS_OUTPUT.PUT_LINE('LOCATE boundary END************'||to_char(L_Locate_boundary_End));
				IF(L_Locate_boundary_End > L_Locate_Begin) THEN

				-- DBMS_OUTPUT.PUT_LINE('l_outrec_index BEGIN:' || to_char(l_outrec_index));
     			l_outrec_index := l_outrec_index + 1;
				-- DBMS_OUTPUT.PUT_LINE('l_outrec_index END:' || to_char(l_outrec_index));


				-- Get Content-length

				L_Locate_Str_Len_End := INSTR(L_OUTPUT_STR, FND_GLOBAL.LOCAL_CHR(13), L_Locate_Str_Len, 1);
				L_Content_Str_Len := TO_NUMBER(SUBSTR(L_OUTPUT_STR,(L_Locate_Str_Len+16),L_Locate_Str_Len_End - L_Locate_Str_Len - 16));

				-- DBMS_OUTPUT.PUT_LINE('CONTENT STR LENGTH IS ***********'||to_char(L_Content_Str_Len));
				L_Content_Type := SUBSTR(L_OUTPUT_STR,(L_Locate_Content + LENGTH('Content-type: application/')),(L_Locate_Str_Len -  (L_Locate_Content + LENGTH('Content-type: application/'))));

				L_Track_Message := SUBSTR(L_OUTPUT_STR, L_Locate_Begin, L_Content_Str_Len);
				-- DBMS_OUTPUT.put_line('Message Is:'||L_Track_Message);
				-- DBMS_OUTPUT.PUT_LINE('CONTENT_TYPE IS ************'||L_Content_Type||'*********');

				if(SUBSTR(L_Content_Type,1,LENGTH('x-ups-tracking-full-response')) = 'x-ups-tracking-full-response') then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-full-response ===');
					L_Token_Start := 0;
					L_Token_End := 0;

					L_Previous_Content_Type := 'x-ups-tracking-full-response';

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.TypeofResponse :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.InquiryNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.TypeOfInquiryNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.SenderShiperNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.InternalKey :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.FromPickupDate :=
							TO_DATE(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End), 'YYYYMMDD');
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.ToPickupDate :=
							TO_DATE(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End), 'YYYYMMDD');
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.DestinationPostalCode :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					-- DBMS_OUTPUT.put_line('PostalCode:'||x_track_header.DestinationPostalCode);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_header.DestinationCountry :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					-- DBMS_OUTPUT.put_line('Country:'||x_track_header.DestinationCountry);

					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-full-response ===');

				elsif(SUBSTR(L_Content_Type,1,LENGTH('x-ups-error')) = 'x-ups-error') then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-error ===');
					L_Token_Start := 0;
					L_Token_End := 0;

					L_Previous_Content_Type := 'x-ups-error';

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_error.UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_error.AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_error.ReturnCode :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_track_error.MessageText :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					x_track_error.MessageNumber := SUBSTR(x_track_error.MessageText, 1,4 );
					x_track_error.MessageText := SUBSTR(x_track_error.MessageText,
																	5,
																	LENGTH(x_track_error.MessageText) - 4);

					x_msg_count := 1;
					x_msg_data := 'Message ' || x_track_error.MessageNumber
							|| ': ' || x_track_error.MessageText;
					x_return_status := FND_API.G_RET_STS_ERROR;

					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-error ===');
				elsif(SUBSTR(L_Content_Type,1,LENGTH('x-ups-address')) = 'x-ups-address') then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-address ===');

					L_Token_Start := 0;
					L_Token_End := 0;


					l_track_address_i := l_track_address_i + 1;

					if(L_Previous_Content_Type = 'x-ups-tracking-multipiece-summary-hdr') then
						x_multi_sum_header(l_multi_sum_header_i).ConsigneeAddressIndex := l_track_address_i;
					elsif(L_Previous_Content_Type = 'x-ups-tracking-package-detail-hdr') then
						x_pkg_detail_segment(l_pkg_detail_segment_i).ConsigneeAddressIndex := l_track_address_i;
					elsif(L_Previous_Content_Type = 'x-ups-tracking-activity-detail') then
						x_activity_detail(l_activity_detail_i).ActivityAddressIndex := l_track_address_i;
					end if;

					--L_Previous_Content_Type :=  'x-ups-address';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).TypeOfAddress :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).Name :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).Address1 :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).Address2 :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).Address3 :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).City :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).StateProv :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).PostalCode :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_track_address(l_track_address_i).Country :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-address ===');
 				elsif(SUBSTR(L_Content_Type,1,LENGTH( 'x-ups-tracking-multipiece-summary-hdr')) = 'x-ups-tracking-multipiece-summary-hdr') then

					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-multipiece-summary-hdr ===');
					L_Token_Start := 0;
					L_Token_End := 0;

					l_multi_sum_header_i := l_multi_sum_header_i + 1;
					L_Previous_Content_Type :=  'x-ups-tracking-multipiece-summary-hdr';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));
					-- DBMS_OUTPUT.PUT_LINE('after AppVersion');

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).InternalShipmentKey :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					-- DBMS_OUTPUT.PUT_LINE('after InternalShipmentKey');

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).ServiceLevelDescription :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					-- DBMS_OUTPUT.PUT_LINE('after ServiceLevelDescription');

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).PickupDate :=
							TO_DATE(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End), 'YYYYMMDD');
	    			-- DBMS_OUTPUT.PUT_LINE('after PickupDate');

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_multi_sum_header(l_multi_sum_header_i).ScheduledDeliveryDate :=
							TO_DATE(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End), 'YYYYMMDD');
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).TotalShipmentWeight :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End));
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).WeightUOM :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).NumberOfPackagesInShipment :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End));
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).NumberOfPackagesDelivered :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End));

					-- ------------------------------------------------------------
					-- to find all th details corresponding to the summary header
					-- use the MPieceSummaryDtlIndex to find the first detail and
					-- use the NumberOfPackagesActive to find the successive ones
					-- ------------------------------------------------------------

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_header(l_multi_sum_header_i).NumberOfPackagesActive :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End));

					x_multi_sum_header(l_multi_sum_header_i).ConsigneeAddressIndex := 9999;
					x_multi_sum_header(l_multi_sum_header_i).MPieceSummaryDtlIndex := 9999;
					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-multipiece-summary-hdr ===');

 				elsif(SUBSTR(L_Content_Type,1,LENGTH( 'x-ups-tracking-multipiece-summary-det')) = 'x-ups-tracking-multipiece-summary-det') then

					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-multipiece-summary-det ===');
					L_Token_Start := 0;
					L_Token_End := 0;

					l_multi_sum_detail_i:= l_multi_sum_detail_i+ 1;
					-- DBMS_OUTPUT.PUT_LINE('Previous Content Type: ' || L_Previous_Content_Type);

					if(L_Previous_Content_Type = 'x-ups-tracking-multipiece-summary-hdr') then
						-- DBMS_OUTPUT.PUT_LINE(' added myself to the Summary Header index: ' || l_multi_sum_detail_i);
						x_multi_sum_header(l_multi_sum_header_i).MPieceSummaryDtlIndex := l_multi_sum_detail_i;
					end if;

					L_Previous_Content_Type :=  'x-ups-tracking-multipiece-summary-det';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_detail(l_multi_sum_detail_i).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_detail(l_multi_sum_detail_i).AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_detail(l_multi_sum_detail_i).TrackingNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_multi_sum_detail(l_multi_sum_detail_i).InternalPackageKey :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

		  			x_multi_sum_detail(l_multi_sum_detail_i).ActivityDetailIndex := 9999;
					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-multipiece-summary-det ===');

 				elsif(SUBSTR(L_Content_Type,1,LENGTH( 'x-ups-tracking-package-detail-hdr')) = 'x-ups-tracking-package-detail-hdr') then

					L_Token_Start := 0;
					L_Token_End := 0;

					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-package-detail-hdr ===');
					-- DBMS_OUTPUT.put_line('Message Is:'||L_Track_Message);
					-- DBMS_OUTPUT.PUT_LINE('PKG TBL INDEX:'||l_pkg_detail_segment_i);
					l_pkg_detail_segment_i := l_pkg_detail_segment_i + 1;
					-- DBMS_OUTPUT.PUT_LINE('PKG TBL INDEX:'||l_pkg_detail_segment_i);
					L_Previous_Content_Type := 'x-ups-tracking-package-detail-hdr';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).TrackingNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).InternalPackageKey :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).ShipmentNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_pkg_detail_segment(l_pkg_detail_segment_i).InternalShipmentKey :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_pkg_detail_segment(l_pkg_detail_segment_i).PickupDate :=
							TO_DATE(WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End), 'YYYYMMDD');

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_pkg_detail_segment(l_pkg_detail_segment_i).NumberOfPackagesInShipment :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).ServiceLevelDescription :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_pkg_detail_segment(l_pkg_detail_segment_i).PackageWeight :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).WeightUOM :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).SignedForByName :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).Location :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_detail_segment(l_pkg_detail_segment_i).CusotmerReferenceNumber :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);



					x_pkg_detail_segment(l_pkg_detail_segment_i).ConsigneeAddressIndex := 9999;

					x_pkg_detail_segment(l_pkg_detail_segment_i).ActivityDetailIndex := 9999;
					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-package-detail-hdr ===');

 				elsif(SUBSTR(L_Content_Type,1,LENGTH('x-ups-tracking-package-progress-hdr'))=
					'x-ups-tracking-package-progress-hdr') then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-package-progress-hdr ===');
					L_Token_Start := 0;
					L_Token_End := 0;

					L_Previous_Content_Type := 'x-ups-tracking-package-progress-hdr';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_progress.UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_progress.AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

					-- ------------------------------------------------------------
					-- to find all th details corresponding to the summary header
					-- use the ActivityDetailIndex to find the first detail and
					-- use the NumberOfActivityDetailLines to find the successive ones
					-- ------------------------------------------------------------

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_pkg_progress.NumberOfActivityDetailLines :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					x_pkg_progress.ActivityDetailIndex := 9999;
					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-package-progress-hdr ===');

 				elsif(SUBSTR(L_Content_Type,1,LENGTH( 'x-ups-tracking-activity-detail')) = 'x-ups-tracking-activity-detail') then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> === x-ups-tracking-activity-detail ===');
					L_Token_Start := 0;
					L_Token_End := 0;


					l_activity_detail_i := l_activity_detail_i + 1;

					if(L_Previous_Content_Type = 'x-ups-tracking-multipiece-summary-det') then
							x_multi_sum_detail(l_multi_sum_detail_i).ActivityDetailIndex := l_activity_detail_i;
					elsif(L_Previous_Content_Type = 'x-ups-tracking-package-detail-hdr') then
							x_pkg_detail_segment(l_pkg_detail_segment_i).ActivityDetailIndex := l_activity_detail_i;
					elsif(L_Previous_Content_Type = 'x-ups-tracking-package-progress-hdr') then
							x_pkg_progress.ActivityDetailIndex := l_activity_detail_i;
					end if;

					L_Previous_Content_Type :=  'x-ups-tracking-activity-detail';

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_activity_detail(l_activity_detail_i).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_activity_detail(l_activity_detail_i).AppVersion :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_Track_Message, L_Token_Start,L_Token_End));

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_activity_detail(l_activity_detail_i).StatusType :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			--
	    			-- Debug Statements
	    			--
	    			IF l_debug_on THEN
	    			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;
	    			--
	    			x_activity_detail(l_activity_detail_i).StatusLongDescription :=
							WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					l_date_string := WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);
					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					l_time_string := WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

	    			x_activity_detail(l_activity_detail_i).ActivityDate :=
							TO_DATE(l_date_string || l_time_string, 'YYYYMMDDHH24MISS');

	    			-- x_activity_detail(l_activity_detail_i).ActivityTime :=
					-- 		WSH_U_UTIL.Calculate_Token(L_Track_Message,L_Token_Start,L_Token_End);

					-- DBMS_OUTPUT.PUT_LINE('===<end> === x-ups-tracking-activity-detail ===');
			end if;

		END IF;

		-- advance to next UPSBOUNDARYUPS section
		L_Locate_boundary := L_Locate_boundary_End;

 		EXIT WHEN L_Locate_Begin = 0;

    END LOOP;




--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

		WHEN WSH_U_CAR_URL THEN
		   FND_MESSAGE.SET_NAME('WSH', 'WSH_U_CAR_URL');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CAR_URL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CAR_URL');
			END IF;
			--
		WHEN WSH_U_PROXY THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_PROXY');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

	  	-- this exception is produced by UTL_HTTP.REQUEST_PIECES
	  	-- The http call fails(for example, bacause of failure of the HTTP
	  	-- daemon, or bacause the argument to REQUEST_PIECES cannot be interpreted
	  	-- as a URL because it is NULL or has non-HTTP syntax)
	  	--
	  	-- Debug Statements
	  	--
	  	IF l_debug_on THEN
	  	    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_PROXY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	  	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_PROXY');
	  	END IF;
	  	--
		WHEN REQUEST_FAILED THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_REQ_FAILED');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   	end if;

	  	-- this exception is produced by UTL_HTTP.REQUEST_PIECES
	  	-- Initialization of the HTTP callout subsystem failed
		-- for invironmental reasons such as lack of available memory
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'REQUEST_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:REQUEST_FAILED');
		END IF;
		--
		WHEN INIT_FAILED THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_INIT_FAILED');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'INIT_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INIT_FAILED');
		END IF;
		--
		WHEN WSH_U_NO_HOST THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_NO_HOST');
			WSH_UTIL_CORE.ADD_MESSAGE('E');
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_NO_HOST exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_NO_HOST');
			END IF;
			--
		WHEN  WSH_U_APPVER THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_APPVER');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_APPVER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_APPVER');
END IF;
--
		WHEN  WSH_U_LICAGRE THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_LICAGRE');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_LICAGRE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_LICAGRE');
END IF;
--
		WHEN  WSH_U_RESTYP THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_RESTYP');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_RESTYP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_RESTYP');
END IF;
--
		WHEN WSH_U_INPUT_PARAMETER THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_INPUT_PARAMETER');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_INPUT_PARAMETER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_INPUT_PARAMETER');
END IF;
--
		WHEN WSH_U_INQNO	 THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_INQNO');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_INQNO exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_INQNO');
END IF;
--
		WHEN WSH_U_TYP_INQNO THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_TYP_INQNO');
			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages( 'Y', l_msg_summary, l_msg_details, x_msg_count);
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;


		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_TYP_INQNO exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_TYP_INQNO');
		END IF;
		--
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);


			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
			END IF;
			--
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);





--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END EnhancedTracking;


END WSH_U_TRACK;

/
