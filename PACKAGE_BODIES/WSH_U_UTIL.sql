--------------------------------------------------------
--  DDL for Package Body WSH_U_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_U_UTIL" AS
/* $Header: WSHUUTLB.pls 115.9 2002/11/12 02:04:26 nparikh ship $ */
	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_U_UTL';
	p_message_type	CONSTANT VARCHAR2(1) := 'E';



-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Calculate_Token
--	Type				: private
--	Function			: use '%' as delimiter, strip off the first token.
--						  if '%' is not found, just return the substring
--						  starting from x_Start_Token till the end.
--
--	Version			: Initial version 1.0
-- Notes
--
--
-- End of comments
-- ---------------------------------------------------------------------

FUNCTION Calculate_Token(x_In_Message IN OUT NOCOPY  VARCHAR2,
                         x_Start_Token IN OUT NOCOPY  NUMBER,
                         x_End_Token IN OUT NOCOPY  NUMBER) RETURN VARCHAR2
IS
	L_Return_String VARCHAR2(4000);
	L_Str_Len NUMBER;
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALCULATE_TOKEN';
	--
BEGIN
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
	    WSH_DEBUG_SV.log(l_module_name,'X_IN_MESSAGE',X_IN_MESSAGE);
	    WSH_DEBUG_SV.log(l_module_name,'X_START_TOKEN',X_START_TOKEN);
	    WSH_DEBUG_SV.log(l_module_name,'X_END_TOKEN',X_END_TOKEN);
	END IF;
	--
	x_Start_Token := x_End_Token +1;
	x_End_Token := INSTR(x_In_Message, '%',x_Start_Token,1);
	if x_End_Token = 0 then
		L_Return_String := SUBSTR(x_In_Message, x_Start_Token, length(x_In_Message) - x_Start_Token + 2);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return L_Return_String;
	end if;
	L_Str_Len := x_End_Token - x_Start_Token;
	L_Return_String := SUBSTR(x_In_Message,x_Start_Token,L_Str_Len);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return L_Return_String;

END Calculate_Token;

-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Get_Carrier_API_URL
--	Type				: public
--	Function			: get the URL to for calling Carrier API
--	Version			: Initial version 1.0
-- Notes				: please use :set tabstop=3 to view this file in vi to get
--						  proper alignment
--
-- End of comments
-- ---------------------------------------------------------------------


FUNCTION Get_Carrier_API_URL(
			   p_api_version            IN		NUMBER,
			   p_init_msg_list          IN		VARCHAR2  DEFAULT FND_API.G_FALSE,
			   x_return_status         OUT NOCOPY 		VARCHAR2,
			   x_msg_count             OUT NOCOPY 		NUMBER,
		      x_msg_data					OUT NOCOPY 		VARCHAR2,
			   p_Carrier_Name 	    	IN			VARCHAR2,
            p_API_Name					IN 		VARCHAR2) RETURN VARCHAR2 IS

			-- standard version infermation
			l_api_version		CONSTANT	NUMBER		:= 1.0;
			l_api_name		CONSTANT	VARCHAR2(30)	:= 'Get_Carrier_API_URL';
			l_carrier_api_url	VARCHAR2(1000) 		:= NULL;
			--
l_debug_on BOOLEAN;
			--
			l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CARRIER_API_URL';
			--
begin

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
	    WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_NAME',P_CARRIER_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_API_NAME',P_API_NAME);
	END IF;
	--
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
								l_api_name, G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list)	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	x_msg_count := 0;
	x_msg_data := NULL;

	if UPPER(p_Carrier_Name) = 'UPS' and
		UPPER(p_API_Name) = 'RATING_AND_SERVICE_SELECTION' then
		l_carrier_api_url := 'http://www.ups.com/using/services/rave/qcost_dss.cgi';

	elsif UPPER(p_Carrier_Name) = 'UPS' and
		UPPER(p_API_Name) = 'ENHANCED_TRACKING' then
		l_carrier_api_url := 'http://wwwapps.ups.com/etracking/tracking.cgi';

	elsif UPPER(p_Carrier_Name) = 'UPS' and
		UPPER(p_API_Name) = 'CSP_VALIDATE' then
		l_carrier_api_url := 'http://www.ups.com/using/services/cszval/cszval_dss.cgi';

	elsif UPPER(p_Carrier_Name) = 'UPS' and
		UPPER(p_API_Name) = 'TIME_IN_TRANSIT' then
		l_carrier_api_url := 'http://wwwapps.ups.com/transit/timetran.cgi';

	else
		x_msg_count := 1;
		x_msg_data := 'Invalid Carrier/API combination';
	end if;
	FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_carrier_api_url;



end Get_Carrier_API_URL;

-- -------------------------------------------------------------------
-- Start of comments
-- API name			: Get_PROXY
--	Type				: public
--	Function			: get oracle proxy server
--	Version			: Initial version 1.0
-- Notes				: please use :set tabstop=3 to view this file in vi to get
--						  proper alignment
--
-- End of comments
-- ---------------------------------------------------------------------

FUNCTION Get_PROXY (
			   p_api_version            IN     NUMBER,
			   p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
			   x_return_status         OUT NOCOPY      VARCHAR2,
			   x_msg_count             OUT NOCOPY      NUMBER,
			   x_msg_data              OUT NOCOPY      VARCHAR2) return VARCHAR2 IS

	-- standard version infermation
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_api_name		CONSTANT	VARCHAR2(30):= 'Get_PROXY';
	l_proxy	VARCHAR2(1000) := NULL;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PROXY';
--
begin

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

	x_msg_count := 0;
	x_msg_data := NULL;

	-- l_proxy := 'www-proxy.us.oracle.com';
	FND_PROFILE.GET('WSH_INTERNET_PROXY', l_proxy );
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return l_proxy;


end Get_PROXY;

END WSH_U_UTIL;


/
