--------------------------------------------------------
--  DDL for Package Body WSH_U_CSPV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_U_CSPV" AS
/* $Header: WSHUCSPB.pls 115.12 2002/11/12 01:59:37 nparikh ship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) 		:= 'WSH_U_CSPV';
	p_message_type	CONSTANT VARCHAR2(1) 	:= 'E';







-- -------------------------------------------------------------------
-- Start of comments
-- API name			: CSP_Validate
--	Type				: public
--	Function			: compose the input string, call UPS APIs and parse
--						  the L_OUTPUT string, place them in the returning
--
--	Version			: Initial version 1.0
-- Notes
--
-- End of comments
-- ---------------------------------------------------------------------
PROCEDURE CSP_Validate (
								  p_api_version            IN		NUMBER,
								  p_init_msg_list          IN		VARCHAR2,
								  x_return_status         OUT NOCOPY 		VARCHAR2,
								  x_msg_count             OUT NOCOPY 		NUMBER,
								  x_msg_data              OUT NOCOPY 		VARCHAR2,
								  p_AppVersion					IN		VARCHAR2,
								  p_AcceptLicenseAgreement IN		VARCHAR2,
	 							  p_ResponseType				IN		VARCHAR2,
								  p_request_in					IN		CSPValidateInRec,
								  x_CSPValidate_out		  OUT NOCOPY 		CSPValidateOutTblTyp
) IS

		-- standard version infermation
		l_api_version	CONSTANT	NUMBER		:= 1.0;
		l_api_name	CONSTANT	VARCHAR2(30)   := 'CSP_VALIDATE';

		-- standard variables
		l_return_status	VARCHAR2(1)			:= FND_API.G_RET_STS_SUCCESS;
		l_msg_count		NUMBER					:= 0;
		l_msg_data		VARCHAR2(2000) 		:= NULL;
		l_msg_summary	VARCHAR2(2000);
		l_msg_details	VARCHAR2(4000);


		-- L_UPS_URL VARCHAR2(200) := 'http://wwwapps.ups.com/using/sevices/cszval/cszval_dss.cgi';
		L_UPS_URL VARCHAR2(1000) := NULL;
		L_INTERNET_PROXY VARCHAR2(1000) := NULL;

		l_boundary_string_start		NUMBER  := 0;
		l_boundary_string_end			NUMBER  := 0;
		l_boundary_string				VARCHAR2(100)		 := NULL;
		L_Content_Str_Len NUMBER					:= 0;

		l_request_in CSPValidateInRec;

		L_INPUT_STR VARCHAR2(2000);
		L_OUTPUT_STR VARCHAR2(10000);
		l_output_data  utl_http.html_pieces;

		L_CSPV_Message VARCHAR2(500);

		L_Content_Type VARCHAR2(200);

		L_Locate_boundary NUMBER := 1;
		L_Locate_Str_Len  NUMBER := 1;
		L_Locate_Str_Len_End NUMBER := 0;
		L_Locate_Content  NUMBER :=1;
		L_Locate_boundary_End NUMBER := 1;
		L_Locate_Begin   NUMBER := 1;
		L_Token_Start NUMBER := 1;
		L_Token_End NUMBER := 0;
		l_find_error NUMBER := 0;

		-- this is used to print the debug message only
		l_outrec_index BINARY_INTEGER := 0;

		WSH_U_INPUT_PARAMETER 		exception;
		WSH_U_CAR_URL				exception;
		WSH_U_PROXY				exception;
		WSH_U_APPVER				exception;
		WSH_U_LICAGRE				exception;
		WSH_U_RESTYP				exception;
		WSH_U_CSP					exception;
		WSH_U_CITYORZIP			exception;
		WSH_U_NO_HOST            	exception;
		REQUEST_FAILED           	exception;
		INIT_FAILED              	exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CSP_VALIDATE';
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

		-- initialize global variables




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
							p_API_Name		   => 'CSP_VALIDATE');
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
			-- p_AppVersion := '1.0';
      end if;
		L_INPUT_STR := L_INPUT_STR || 'AppVersion' ||'='|| p_AppVersion;

		-- AcceptLicenseAgreement ---------------------------------------------
      if( p_AcceptLicenseAgreement IS NULL) then
			raise WSH_U_LICAGRE;
			-- p_AcceptLicenseAgreement := 'YES';
      end if;
		L_INPUT_STR := L_INPUT_STR || '&' ||'AcceptUPSLicenseAgreement'||'=' || p_AcceptLicenseAgreement;

		-- ResponseType --------------------------------------------------------
      if( p_ResponseType IS NULL) then
			raise WSH_U_RESTYP;
			-- p_ResponseType := 'application/x-ups-cszval';
      end if;
      L_INPUT_STR := L_INPUT_STR || '&' || 'ResponseType' ||'='|| p_ResponseType;

		-- ---------------------------------------------------------------
		-- Program specific parameters start here
		-- ---------------------------------------------------------------
		if (l_request_in.City IS NULL and l_request_in.StateProv IS NULL
			and l_request_in.PostalCode IS NULL) then
			raise WSH_U_CSP;
		end if;

		-- --------------------------------------------------------------------
		-- City is required if StateProv is NOT NULL and PostalCode is NULL
		-- --------------------------------------------------------------------
		if (l_request_in.City IS NULL) then
			if (l_request_in.StateProv is NOT NULL and l_request_in.PostalCode
				is NULL ) then

				raise WSH_U_CITYORZIP;
			end if;
	   else
			L_INPUT_STR := L_INPUT_STR || '&' || 'City' ||'='|| l_request_in.City;
		end if;

		-- ----------------------------------------------------------------
		-- StateProv cannot be specified without either City or PostalCode
		-- ----------------------------------------------------------------
		if(l_request_in.StateProv IS not NULL) then
			if (l_request_in.City IS NULL and l_request_in.PostalCode is NULL) then
				raise WSH_U_CITYORZIP;
			end if;
			L_INPUT_STR := L_INPUT_STR || '&' || 'StateProv'||'=' || l_request_in.StateProv;
		end if;

		-- -------------------------------------------------------------------
		-- PostalCode is required when StateProv is populated and City is not
		-- provided
		-- -------------------------------------------------------------------
		if(l_request_in.PostalCode IS NULL) then
			if (l_request_in.StateProv is NOT NULL and l_request_in.City is NULL) then
					raise WSH_U_CITYORZIP;
			end if;
		else
    		L_INPUT_STR := L_INPUT_STR || '&' || 'PostalCode' ||'='|| l_request_in.PostalCode;
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

			l_boundary_string		:= 'UPSBOUNDARY';
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

				L_CSPV_Message := SUBSTR(L_OUTPUT_STR, L_Locate_Begin, L_Content_Str_Len);
				-- DBMS_OUTPUT.put_line('Message Is:'||L_CSPV_Message);
				-- DBMS_OUTPUT.PUT_LINE('CONTENT_TYPE IS ************'||L_Content_Type||'*********');

				if(SUBSTR(L_Content_Type,1,LENGTH('x-ups-cszval')) = 'x-ups-cszval' or
				 		SUBSTR(L_Content_Type,1,LENGTH('x-ups-error')) = 'x-ups-error')
				then
					-- DBMS_OUTPUT.PUT_LINE('===<begin> ======');
					L_Token_Start := 0;
					L_Token_End := 0;


					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_CSPValidate_out(l_outrec_index).UPSOnLine :=
							WSH_U_UTIL.Calculate_Token(L_CSPV_Message,L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_CSPValidate_out(l_outrec_index).AppVersion :=
							WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_CSPValidate_out(l_outrec_index).ReturnCode :=
							TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End));
					-- DBMS_OUTPUT.PUT_LINE('Return Code: ' || TO_CHAR(x_CSPValidate_out(l_outrec_index).ReturnCode));

					--
					-- Debug Statements
					--
					IF l_debug_on THEN
					    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					--
					x_CSPValidate_out(l_outrec_index).MessageText :=
							WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

					x_CSPValidate_out(l_outrec_index).MessageNumber :=
							TO_NUMBER(SUBSTR(x_CSPValidate_out(l_outrec_index).MessageText,1,4));
					-- DBMS_OUTPUT.PUT_LINE('MessageNumber: ' || TO_CHAR(x_CSPValidate_out(l_outrec_index).MessageNumber));
					x_CSPValidate_out(l_outrec_index).MessageText :=
							SUBSTR(x_CSPValidate_out(l_outrec_index).MessageText,5,(LENGTH(x_CSPValidate_out(l_outrec_index).MessageText)-4));
					-- DBMS_OUTPUT.PUT_LINE('MessageText: ' || x_CSPValidate_out(l_outrec_index).MessageText);

					if (x_CSPValidate_out(l_outrec_index).ReturnCode = 0) then

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).Rank :=
								TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End));

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).Quality :=
								TO_NUMBER(WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End));

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).City :=
								WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).StateProv :=
								WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).PostalCodeLow :=
								WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

						--
						-- Debug Statements
						--
						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_U_UTIL.CALCULATE_TOKEN',WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						--
						x_CSPValidate_out(l_outrec_index).PostalCodeHigh :=
								WSH_U_UTIL.Calculate_Token(L_CSPV_Message, L_Token_Start,L_Token_End);

					else
						x_CSPValidate_out(l_outrec_index).Rank := NULL;

						x_CSPValidate_out(l_outrec_index).Quality := NULL;

						x_CSPValidate_out(l_outrec_index).City := NULL;

						x_CSPValidate_out(l_outrec_index).StateProv := NULL;

						x_CSPValidate_out(l_outrec_index).PostalCodeLow := NULL;

						x_CSPValidate_out(l_outrec_index).PostalCodeHigh := NULL;

					end if;
					-- DBMS_OUTPUT.PUT_LINE('===<end> === application/x-ups-cszval ===');
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
		WHEN WSH_U_NO_HOST THEN
		   FND_MESSAGE.SET_NAME('WSH', 'WSH_U_NO_HOST');
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
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_NO_HOST exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_NO_HOST');
			END IF;
			--
		WHEN REQUEST_FAILED THEN
		   FND_MESSAGE.SET_NAME('WSH', 'WSH_U_REQUEST_FAILED');
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

			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_PROXY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_PROXY');
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
		WHEN WSH_U_CSP THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_CSP');
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
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CSP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CSP');
			END IF;
			--
		WHEN WSH_U_CITYORZIP	 THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_U_INQNO	');
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
			    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_U_CITYORZIP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_U_CITYORZIP');
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
END CSP_Validate;


END WSH_U_CSPV;

/