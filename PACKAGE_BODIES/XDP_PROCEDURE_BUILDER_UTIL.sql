--------------------------------------------------------
--  DDL for Package Body XDP_PROCEDURE_BUILDER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PROCEDURE_BUILDER_UTIL" AS
/* $Header: XDPPRBUB.pls 120.1 2005/06/24 17:29:13 appldev ship $ */

g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

type ParamLocation IS RECORD
  ( Location number,
    ParamName varchar2(80),
    Verified varchar2(1) );

type ParamLocations is table of ParamLocation
 INDEX BY BINARY_INTEGER;

 g_ParamLocations ParamLocations;

 g_FaParams varchar2(10) := '$FA.';
 g_FaParam varchar2(10) := 'FA';
 g_WIParams varchar2(10) := '$WI.';
 g_WIParam varchar2(10) := 'WI';
 g_OrderParams varchar2(10) := '$ORDER.';
 g_OrderParam varchar2(10) := 'ORDER';
 g_LineParams varchar2(10) := '$LINE.';
 g_LineParam varchar2(10) := 'LINE';

 g_FEAttr varchar2(10) := '$';

-- These are the translations for macros
 g_replace_get_param_str 	varchar2(200) := 'XDP_MACROS.GET_PARAM_VALUE';
 g_replace_send_str 		varchar2(200) := 'XDP_MACROS.SEND';
 g_replace_send_http_str 	varchar2(200) := 'XDP_MACROS.SEND_HTTP';
 g_replace_resp_str 		varchar2(200) := 'XDP_MACROS.RESPONSE_CONTAINS';
 g_replace_notify_str 		varchar2(200) := 'XDP_MACROS.NOTIFY_ERROR';
 g_replace_get_response_str 	varchar2(200) := 'XDP_MACROS.GET_RESPONSE';

 g_replace_connect_str 		varchar2(200) := 'XDP_MACROS.SEND_CONNECT';
 g_replace_get_attr_str 	varchar2(200) := 'XDP_MACROS.GET_ATTR_VALUE';

-- New for 11.5.6+
 g_replace_get_longresp_str 	varchar2(200) := 'XDP_MACROS.GET_LONG_RESPONSE';
 g_replace_audit_str 		varchar2(200) := 'XDP_MACROS.AUDIT';

cursor gc_getFAParams(FAID number, Param varchar2) is
	select 'Y' "FOUND"
	from XDP_FA_PARAMETERS XFA
        where FULFILLMENT_ACTION_ID = FAID
	  and upper(XFA.PARAMETER_NAME) = upper(Param) ;

cursor gc_getParamPool(Param varchar2) is
	select 'Y' "FOUND"
        from CSI_LOOKUPS
        where lookup_type = 'CSI_EXTEND_ATTRIB_POOL'
	  and upper(LOOKUP_CODE) = upper(Param);

cursor gc_getFeAttr(FeTypeID number, FEAttr varchar2) is
          select 'Y' "FOUND"
          from XDP_FE_ATTRIBUTE_DEF xad, XDP_FE_SW_GEN_LOOKUP xfl
          where xad.FE_SW_GEN_LOOKUP_ID = xfl.FE_SW_GEN_LOOKUP_ID
            and xfl.FETYPE_ID = FeTypeID
	    and upper(xad.FE_ATTRIBUTE_NAME) = upper(FEAttr);

Procedure CleanupParameterLocations;

-- Private Routines for Validation of Parameters

Procedure GetParametersLocations( p_Parameter in varchar2,
				  p_ProcText in varchar2);

Procedure ValidateFAParameters( p_FAID in number,
				p_ProcText in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2);

Procedure ValidateWIParameters( p_ProcText in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2);

Procedure ValidateFEAttr( p_ID in number,
			  p_ProcText in varchar2,
			  x_ErrorCode OUT NOCOPY number,
			  x_ErrorString OUT NOCOPY varchar2);

Procedure FetchParameters(p_ProcText in varchar2,
			  p_ParamType in varchar2);

Procedure VerifyFAParams(p_FAID in number,
			 x_ErrorCode OUT NOCOPY number,
			 x_ErrorString OUT NOCOPY varchar2);

Procedure VerifyPoolParams(x_ErrorCode OUT NOCOPY number,
			   x_ErrorString OUT NOCOPY varchar2);

Procedure VerifyFEAttr( p_FeTypeID in number,
			x_ErrorCode OUT NOCOPY number,
			x_ErrorString OUT NOCOPY varchar2);

Procedure GetValidParamLocation(p_CmdString in varchar2,
			        x_ParamLoc OUT NOCOPY number,
				x_ParamType OUT NOCOPY varchar2);

Procedure GetParamValue(p_ID in number,
			p_ParamType in varchar2,
			p_ParamName in varchar2,
			x_ParamValue OUT NOCOPY varchar2,
			x_ParamLogFlag OUT NOCOPY varchar2);

Function GetParamString(p_ProcText in varchar2,
			p_Location in number) return varchar2;

Function IsValidParamChar(p_Char in varchar2) return boolean;

Procedure OKtoLog(p_ParamType in varchar2,
		  p_ID in number,
		  p_ParamName in varchar2,
		  p_LogFlag OUT NOCOPY varchar2);

Procedure ReplaceFEAttr(p_FeName in varchar2,
			p_CmdString in varchar2,
			x_CmdStringReplaced OUT NOCOPY varchar2,
		      	x_ErrorCode OUT NOCOPY number,
		      	x_ErrorString OUT NOCOPY varchar2);

-- Public routines

-- This routine is used to check the validity of paramters used in
-- a Fulfillment Procedure
-- The validations to be done are only for WI and FA
-- The ID being passed is the FA ID
-- The WI Paramter validation is done from the pool
-- LINE and ORDER parameter validtion are NOT done!
Procedure ValidateFPParameters( p_ID in number,
				p_ProcBody in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2)
is

 l_WiParamFound number := 0;
 l_FaParamFound number := 0;
begin
    x_ErrorCode := 0;
    x_ErrorString := null;

    l_WiParamFound := INSTR(p_ProcBody, g_WIParams,1,1);
    l_FaParamFound := INSTR(p_ProcBody,g_FAParams,1,1);

    if l_FaParamFound > 0 then
    -- FA Parameter Found....
	-- Get the locations of the FA Paramaters
	GetParametersLocations( p_Parameter => g_FaParams,
				p_ProcText => p_ProcBody);

	-- Validate the FA Paramters found
	-- dbms_output.put_line('Validating  FA Parameters..');
	ValidateFAParameters(p_FAID => p_ID,
			     p_ProcText => p_ProcBody,
			     x_ErrorCode => x_ErrorCode,
			     x_ErrorString => x_ErrorString);

	if x_ErrorCode <> 0 then
		return;
	end if;

    end if;

    if l_WiParamFound > 0 then
    -- Work Item Parameter Found
	-- Get the locations of the WI Paramaters
	GetParametersLocations( p_Parameter => g_WIParams,
				p_ProcText => p_ProcBody);

	-- Validate the WI Paramters found
	-- dbms_output.put_line('Validating  WI Parameters..');
	ValidateWIParameters(p_ProcText => p_ProcBody,
                             x_ErrorCode => x_ErrorCode,

                             x_ErrorString => x_ErrorString);

	if x_ErrorCode <> 0 then
		return;
	end if;
    end if;

end ValidateFPParameters;



-- This is used at run-time to get the paramter values. The macros
-- SEND and GET_PARAM_VALUE use this routine to get the command string
-- The strings used for logging are also setup.
Procedure ReplaceOrderParameters(p_OrderID in number,
				 p_LineItemID in  number,
				 p_WIInstanceID in number,
				 p_FAInstanceID in number,
				 p_CmdString in varchar2,
				 x_CmdStringReplaced OUT NOCOPY varchar2,
				 x_CmdStringLog OUT NOCOPY varchar2,
			      	 x_ErrorCode OUT NOCOPY number,
			      	 x_ErrorString OUT NOCOPY varchar2)
is

  l_ActualParam		varchar2(50);
  l_ParamType		varchar2(50);
  l_save_str		varchar2(32767);
  l_ParamLoc		number;
  l_ParamEndLoc		number;
  l_param_value		varchar2(4000);
  l_param_log_value	varchar2(4000);
  l_param_log_flag	varchar2(20);

  l_CmdB4Param		varchar2(4000);
  l_CmdAfterParam	varchar2(4000);

  l_ID			number;

begin

-- dbms_output.put_line('REPLACE: Cmd: ' || substr(p_CmdString,1,200));
-- dbms_output.put_line(xdp_macros.pv_OrderID || ':' ||
--  xdp_macros.pv_LineItemID || ':' ||
--  xdp_macros.pv_WorkItemInstanceID  || ':' ||
--  xdp_macros.pv_FAInstanceID);
	x_ErrorCode := 0;
	x_ErrorString := null;

	if p_CmdString is null then
		return;
	end if;

	l_save_str := p_CmdString;
	while (true) loop
		-- Get a Valid parameter location
		GetValidParamLocation(l_save_str, l_ParamLoc, l_ParamType);
		if l_ParamLoc = 0 then
			-- Done!!
			if l_save_str = ' ' then
				exit;
			else
				x_CmdStringReplaced := x_CmdStringReplaced || l_save_str;
				x_CmdStringLog := x_CmdStringLog || l_save_str;
				exit;
			end if;
		end if;

		-- Found a Valid Parameter here..

		-- Construct Command String
		l_CmdB4Param := substr(l_save_str, 1, l_ParamLoc-1);
		l_CmdAfterParam := substr(l_save_str, l_ParamLoc+1 , length(l_save_str));

		x_CmdStringReplaced := x_CmdStringReplaced || l_CmdB4Param;
		x_CmdStringLog := x_CmdStringLog || l_CmdB4Param;

		-- Get the Actual parameter
		-- dbms_output.put_line('Param type:' || l_ParamType || ':');
		l_ActualParam := GetParamString(l_CmdAfterParam, length(l_ParamType) + 2 );

		-- dbms_output.put_line('Param:' || l_ActualParam || ':');
		l_ParamEndLoc := l_ParamLoc + length(l_ActualParam) + length(l_ParamType) + 2;

		-- Prepare the rest of strings
		l_CmdAfterParam := substr(l_save_str, l_ParamEndLoc , length(l_save_str));
		l_save_str := l_CmdAfterParam;

		-- Get the parameter values
		if l_ParamType = g_FAParam then
			l_ID := p_FAInstanceID;
		elsif l_ParamType = g_WIParam then
			l_ID := p_WIInstanceID;
		elsif l_ParamType = g_LineParam then
			l_ID := p_LineItemID;
		elsif l_ParamType = g_OrderParam then
			l_ID := p_OrderID;
		end if;

		-- Get the value of the paramter found
		GetParamValue(
			p_ID => l_ID,
			p_ParamType => l_ParamType,
			p_ParamName => l_ActualParam,
			x_ParamValue => l_Param_Value,
			x_ParamLogFlag => l_Param_Log_Flag);

--dbms_output.put_line('AFTER Get Value');
--dbms_output.put_line(xdp_macros.pv_OrderID || ':' ||
-- xdp_macros.pv_LineItemID || ':' ||
-- xdp_macros.pv_WorkItemInstanceID  || ':' ||
-- xdp_macros.pv_FAInstanceID);

		x_CmdStringReplaced := x_CmdStringReplaced || l_Param_Value;
		if l_Param_Log_Flag = 'Y' then
			x_CmdStringLog := x_CmdStringLog || l_Param_Value;
		else
			x_CmdStringLog := x_CmdStringLog||'$'||l_paramType||'.'||l_ActualParam;
		end if;


		-- dbms_output.put_line('Replaced String:' || x_CmdStringReplaced||':');
		-- dbms_output.put_line('Log String: ' || x_CmdStringLog);
		-- dbms_output.put_line('Saved String: ' || l_save_str || 'Len' || length(l_save_str));

		-- Check if the String Search is done...
		if l_save_str is null then
			exit;
		elsif length(l_save_str) = 0 then
			exit;
		end if;
	end loop;

	x_ErrorCode := 0;
	x_ErrorString := null;

	-- dbms_output.put_line('Cmd:' || x_CmdStringReplaced||':');
	-- dbms_output.put_line('Log:' || x_CmdStringLog||':');

end ReplaceOrderParameters;



-- Get the next valid paramter location. The $variables are scanned
-- and the first valid parameter location is returned. The parameter
-- type is also returned.
-- Valid parameters are $WI $FA $ORDER and $LINE
-- for e.g 'This is a test for $XDP.test and $WI.SP_NAME'
--                                           ^
-- the location of $WI is returned. $XDP is ignored
Procedure GetValidParamLocation(p_CmdString in varchar2,
			        x_ParamLoc OUT NOCOPY number,
				x_ParamType OUT NOCOPY varchar2)
is

 l_StartLoc number;
begin
 l_StartLoc := 1;

	while (true) loop
		-- Check for the first $ location
		x_ParamLoc := INSTR(p_CmdString, '$', l_StartLoc);
		if x_ParamLoc = 0 then
			-- No Params Found
			exit;
		end if;
		-- Check if the $ reference is for WI or FA
		-- If so Exit
		x_ParamType := SUBSTR(p_CmdString, x_ParamLoc + 1, 2);
		if x_ParamType in('FA', 'WI') then
			-- Valid params
			exit;
		end if;

		-- Check if the $ reference is for LINE
		-- If so Exit
		x_ParamType := SUBSTR(p_CmdString, x_ParamLoc + 1, 4);
		if x_ParamType in ('LINE') then
			-- Valid params
			exit;
		end if;

		-- Check if the $ reference is for ORDER
		-- If so Exit
		x_ParamType := SUBSTR(p_CmdString, x_ParamLoc + 1, 5);
		if x_ParamType in ('ORDER') then
			-- Valid params
			exit;
		end if;

		-- The $ is not a valid parameter reference
		-- Continue to find the next $ occurence
		l_StartLoc := x_ParamLoc + 1;

	end loop;

end GetValidParamLocation;


-- Validate the FE Attributes
-- This is used when the connect and disconnect procedures are being
-- generated
Procedure ValidateFEAttributes( p_FeTypeID in number,
				p_ProcBody in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2)
is

 l_FeAttrFound number := 0;
begin

    x_ErrorCode := 0;
    x_ErrorString := null;

    l_FeAttrFound := INSTR(p_ProcBody, g_FEAttr,1,1);

    if l_FeAttrFound > 0 then
    -- FE Attributes Found
	-- Get the locations of the FE Attributes
	GetParametersLocations( p_Parameter => g_FEAttr,
				p_ProcText => p_ProcBody);

	-- Validate the FE Attributes with the FE Type
	-- dbms_output.put_line('Validating  FE Attributes..');
	ValidateFEAttr(p_ID => p_FeTypeID,
		       p_ProcText => p_ProcBody,
		       x_ErrorCode => x_ErrorCode,
		       x_ErrorString => x_ErrorString);

	if x_ErrorCode <> 0 then
		return;
	end if;

    end if;

end ValidateFEAttributes;


-- This is used at run-time to get the paramter values. The macros
-- SEND and GET_PARAM_VALUE ONLY in Connection and Disconnection routines
--                          ------------------------------------
-- use this routine to get the command string
Procedure ReplaceFEAttributes(  p_FeName in varchar2,
				p_CmdString in varchar2,
				x_CmdStringReplaced OUT NOCOPY varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2)
is
 l_FeAttrFound number := 0;
begin

    x_ErrorCode := 0;
    x_ErrorString := null;

    l_FeAttrFound := INSTR(p_CmdString, g_FEAttr,1,1);

    if l_FeAttrFound > 0 then
    -- FE Attributes Found
	-- Get the locations of the FE Attributes
	GetParametersLocations( p_Parameter => g_FEAttr,
				p_ProcText => p_CmdString);

	-- dbms_output.put_line('Validating  FE Attributes..');
	-- Replace the FE Attributes with their values
	ReplaceFEAttr(p_FeName => p_FeName,
		      p_CmdString => p_CmdString,
		      x_CmdStringReplaced => x_CmdStringReplaced,
		      x_ErrorCode => x_ErrorCode,
		      x_ErrorString => x_ErrorString);

	if x_ErrorCode <> 0 then
		return;
	end if;

    else
	x_CmdStringReplaced :=  p_CmdString;

    end if;

end ReplaceFEAttributes;


Procedure ReplaceFEAttr(p_FeName in varchar2,
			p_CmdString in varchar2,
			x_CmdStringReplaced OUT NOCOPY varchar2,
		      	x_ErrorCode OUT NOCOPY number,
		      	x_ErrorString OUT NOCOPY varchar2)
is
 l_FeAttrValue varchar2(4000);
 l_TempCmdString varchar2(4000);
begin

  x_ErrorCode := 0;
  x_ErrorString := null;

  if g_ParamLocations.count > 0 then
	FetchParameters(p_ProcText => p_CmdString,
			p_ParamType => g_FEAttr);
  else
	x_CmdStringReplaced := p_CmdString;
	return;
  end if;

 l_TempCmdString := p_CmdString;
 x_CmdStringReplaced := p_CmdString;

 for i in 1..g_ParamLocations.count loop
		l_FeAttrValue := xdp_engine.get_fe_attributeval(
				p_FeName, upper(g_ParamLocations(i).ParamName));

 		x_CmdStringReplaced :=
			replace(l_TempCmdString,
				g_FEAttr || g_ParamLocations(i).ParamName,
				l_FeAttrValue);

	l_TempCmdString := x_CmdStringReplaced;

 end loop;

exception
when others then
	x_ErrorCode := sqlcode;
	x_ErrorString := substr(sqlerrm,1,2000);
end ReplaceFEAttr;

-- Cleanup
Procedure CleanupParameterLocations
is

begin
 g_ParamLocations.delete;

end CleanupParameterLocations;


-- Get all the locations of the parameter types in a string
--	Valid Parameter types are $WI. $FA. $ORDER. $LINE.
-- This will be used for checking the validy of the paramters

Procedure GetParametersLocations( p_Parameter in varchar2,
				  p_ProcText in varchar2)
is
 l_CurrLocation number := 0;
 l_NextLocation number := 0;
 l_ParamCount number := 0;

 l_Paramoffset number := length(p_Parameter) + 1;

 NoMoreOccurences boolean := true;
begin

	g_ParamLocations.delete;

 l_CurrLocation := INSTR(p_ProcText, p_Parameter, 1, 1);
 if l_CurrLocation = 0 then
	return;
 end if;

 -- We have found occurance of the parameter type
   l_CurrLocation := 1;

	while (NoMoreOccurences) loop

	-- Get the Next occurence of the parameter

		l_NextLocation := INSTR(p_ProcText, p_Parameter, l_CurrLocation, 1);

		if l_NextLocation = 0 then
			NoMoreOccurences := false;
		else
			l_ParamCount := l_ParamCount + 1;
			g_ParamLocations(l_ParamCount).location := l_NextLocation;
			g_ParamLocations(l_ParamCount).Verified := 'N';
			l_CurrLocation := l_NextLocation + l_Paramoffset;
		end if;

 	end loop;

end GetParametersLocations;

-- This routine checks the Validity of the FA Parameters in a
-- Procedure.
-- If there are any FA parameters these are checked against the
-- configuration for that FA
-- The FA ID needs to be passed
Procedure ValidateFAParameters( p_FAID in number,
				p_ProcText in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2)
is

begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	-- Check the validity only if there are any FA parameters
	-- The g_ParamLocations is populated by GetParametersLocations routine
	if g_ParamLocations.count > 0 then
		-- Get all the FA Parameters based on their location
		FetchParameters(p_ProcText => p_ProcText,
				p_ParamType => g_FAParams);

		-- Check against the Configuration
		VerifyFAParams( p_FAID => p_FAID,
			   	x_ErrorCode => x_ErrorCode,
				x_ErrorString => x_ErrorString);
	else
		return;
	end if;

end ValidateFAParameters;


-- This routine checks the Validity of the WI Parameters in a
-- Procedure.
-- If there are any WI parameters these are checked against the
-- configuration for that WI.
-- The WI Parameters are checked against the Parameter Pool
-- Hence no Workitem ID needs to be passed
Procedure ValidateWIParameters( p_ProcText in varchar2,
			      	x_ErrorCode OUT NOCOPY number,
			      	x_ErrorString OUT NOCOPY varchar2)
is

begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	-- Check the validity only if there are any WI parameters
	-- The g_ParamLocations is populated by GetParametersLocations routine
	if g_ParamLocations.count > 0 then
		-- Get all the WI Parameters based on their location
		FetchParameters(p_ProcText => p_ProcText,
				p_ParamType => g_WIParams);

		-- Check against the Configuration
		VerifyPoolParams(x_ErrorCode => x_ErrorCode,
				 x_ErrorString => x_ErrorString);
	else
		-- No Parameters found.

		return;
	end if;

end ValidateWIParameters;


-- This routine checks the Validity of the FE Attributes in a
-- Procedure.
-- If there are any FE Attributes, these are checked against the
-- configuration for that FE Type.
-- The FE Type ID needs to be passed
Procedure ValidateFEAttr( p_ID in number,
			  p_ProcText in varchar2,
			  x_ErrorCode OUT NOCOPY number,
			  x_ErrorString OUT NOCOPY varchar2)
is

begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	-- Check the validity only if there are any FE attriutes
	-- The g_ParamLocations is populated by GetParametersLocations routine

	if g_ParamLocations.count > 0 then
		-- Get all the FE Attributes based on their location
		FetchParameters(p_ProcText => p_ProcText,
				p_ParamType => g_FEAttr);

		-- Check against the configuration
		VerifyFEAttr(p_FeTypeID => p_ID,
			     x_ErrorCode => x_ErrorCode,
			     x_ErrorString => x_ErrorString);
	else
		return;
	end if;

end ValidateFEAttr;

-- This routine is used to identify all the Potential
-- Parameters/attributes based on the locations in the procedure
-- for e.g. if the procedure has 'This is a test for $WI.PARAM and $FA.FA_PARAM'
-- This routine will identify PARAM as a WorkItem parameter and
-- FA_PARAM as an FA parameter
-- The parameter starting locations are populated by the
-- GetParametersLocation routine
Procedure FetchParameters(p_ProcText in varchar2,
			  p_ParamType in varchar2)
is
 l_Param varchar2(80);
 l_ParamCount number := 1;
begin
	for i in 1..g_ParamLocations.count loop
		-- Get the parameter string starting from the location
		l_Param := GetParamString(p_ProcText => p_ProcText,
				  	  p_Location => g_ParamLocations(i).location
							+ length(p_ParamType) );

		g_ParamLocations(i).ParamName := l_Param;
	end loop;
end FetchParameters;

-- This routine checks the validity of ALL the FA parameters
-- identified against the FA Configuration
-- The FetchParameters routine identifies all the FA Parameters
Procedure VerifyFAParams(p_FAID in number,
			 x_ErrorCode OUT NOCOPY number,
			 x_ErrorString OUT NOCOPY varchar2)
is
 l_FoundFlag varchar(1) := 'N';
begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	for i in 1..g_ParamLocations.count loop
		for v_getFAParams in gc_getFAParams(
				p_FAID, g_ParamLocations(i).ParamName) loop
			l_FoundFlag := v_getFAParams.FOUND;
		end loop;

	if l_FoundFlag = 'Y' then
	-- Param is valid OK...
		l_FoundFlag := 'N';
	else
	-- Params in not valid
		x_ErrorCode := -1;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAMETER');
		FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', g_ParamLocations(i).ParamName);
		FND_MESSAGE.SET_TOKEN('PARAMETER_TYPE',
			xdp_procedure_builder.pv_ParamFADisp);
		x_ErrorString := FND_MESSAGE.GET;
		exit;
	end if;

 end loop;

end VerifyFAParams;


-- This routine checks the validity of ALL the WI parameters
-- identified against the Parameter Pool
-- The FetchParameters routine identifies all the WI Parameters
Procedure VerifyPoolParams( x_ErrorCode OUT NOCOPY number,
			    x_ErrorString OUT NOCOPY varchar2)
is
 l_FoundFlag varchar(1) := 'N';
begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	for i in 1..g_ParamLocations.count loop

		for v_getParamPool in gc_getParamPool(
				g_ParamLocations(i).ParamName) loop
			l_FoundFlag := v_getParamPool.FOUND;
		end loop;

	if l_FoundFlag = 'Y' then
	-- Param is valid OK...
		l_FoundFlag := 'N';
	else
	-- Params in not valid
		x_ErrorCode := -1;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAMETER');
		FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', g_ParamLocations(i).ParamName);
		FND_MESSAGE.SET_TOKEN('PARAMETER_TYPE',
				xdp_procedure_builder.pv_ParamWIDisp);
		x_ErrorString := FND_MESSAGE.GET;
		exit;
	end if;
 end loop;

end VerifyPoolParams;


-- This routine checks the validity of ALL the FE attributes
-- identified against the FE Configuration
-- The FetchParameters routine identifies all the FE Attributes
Procedure VerifyFEAttr( p_FeTypeID in number,
			x_ErrorCode OUT NOCOPY number,
			x_ErrorString OUT NOCOPY varchar2)
is
 l_FoundFlag varchar(1) := 'N';
begin
	x_ErrorCode := 0;
	x_ErrorString := null;

	for i in 1..g_ParamLocations.count loop
		for v_getFeAttr in gc_getFeAttr(
				p_FeTypeID, g_ParamLocations(i).ParamName) loop
			l_FoundFlag := v_getFeAttr.FOUND;
		end loop;

	if l_FoundFlag = 'Y' then
	-- Param is valid OK...
		l_FoundFlag := 'N';
	else
	-- Params in not valid
		x_ErrorCode := -1;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAMETER');
		FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', g_ParamLocations(i).ParamName);
		FND_MESSAGE.SET_TOKEN('PARAMETER_TYPE',
				xdp_procedure_builder.pv_ParamFEDisp);
		x_ErrorString := FND_MESSAGE.GET;
		exit;
	end if;

 end loop;

end VerifyFEAttr;


-- Based on the ID and type of the paramter. Obtain the paramter values
-- The log/nolog configuration for the paramter is also obtained.
Procedure GetParamValue(p_ID in number,
			p_ParamType in varchar2,
			p_ParamName in varchar2,
			x_ParamValue OUT NOCOPY varchar2,
			x_ParamLogFlag OUT NOCOPY varchar2)
is
begin

-- dbms_output.put_line('Getting the param value of:' || p_ParamType
-- 	 			 || ':' || p_ID || ':' || p_ParamName);

 x_ParamLogFlag := 'Y';
 if p_ParamType= g_OrderParam then
       	x_ParamValue := xdp_engine.get_order_param_value(
				p_ID,
				upper(p_ParamName));
 elsif p_ParamType = g_LineParam then
       	x_ParamValue := xdp_engine.get_line_param_value(
				p_ID,
				upper(p_ParamName));
 elsif p_ParamType = g_FAParam then
       	x_ParamValue := xdp_engine.get_fa_param_value(
				p_ID,
				upper(p_ParamName));
	 -- dbms_output.put_line('Checking to Log FA..');
	OKtoLog(p_ParamType => g_FAParam,
		p_ID => p_ID,
		p_ParamName => p_ParamName,
		p_LogFlag => x_ParamLogFlag);

 elsif p_ParamType = g_WIParam then
	x_ParamValue := xdp_engine.get_workitem_param_value(
				p_ID,
				upper(p_ParamName));

	 -- dbms_output.put_line('Checking to Log WI..');
	OKtoLog(p_ParamType => g_WIParam,
		p_ID => p_ID,
		p_ParamName => upper(p_ParamName),
		p_LogFlag => x_ParamLogFlag);
	 -- dbms_output.put_line('AFTer Checking to Log WI..');
 end if;

-- dbms_output.put_line('After Getting the param value of:' || p_ParamType
-- 	 			 || ':' || p_ID || ':' || p_ParamName);
-- dbms_output.put_line('Value: ' || x_ParamValue || ':log: ' || x_ParamLogFlag);

end GetParamValue;


-- This routine is used to check if the Paramter configuration
-- for audit trail logging.
-- This is mainly used in the SEND macro where the logging is performed.
-- The Configuration information is cached and the routines fetches the
-- value from the param cache
Procedure OKtoLog(p_ParamType in varchar2,
		  p_ID in number,
		  p_ParamName in varchar2,
		  p_LogFlag OUT NOCOPY varchar2)
is
 l_dummyChar varchar2(2000);

begin
  -- The Logging of the parameter is done in the FP
  -- Check if the Param Cache reqd flag is set.
  -- The v_ParamCacheReqd flag is set by in the InitFP routing within the FP

  -- dbms_output.put_line('Check Cache for: ' || p_ParamType || ' ' || p_ParamName);
  if p_ParamType = g_WIParam then
	if xdp_macros.pv_ParamCacheReqd = 'Y' then
		-- dbms_output.put_line('Getting WI from Cache..');
		xdp_param_cache.Get_wi_param_from_cache(
					  p_param_name => p_ParamName,
					  p_exists_in_cache => l_dummyChar,
					  p_param_value => l_dummyChar,
					  p_param_ref_value => l_dummyChar,
					  p_log_flag => p_LogFlag,
					  p_evaluation_mode => l_dummyChar,
					  p_evaluation_proc => l_dummyChar,
					  p_default_value => l_dummyChar);
	else
		-- dbms_output.put_line('Not Getting from Cache..');
		p_LogFlag := 'Y';
	end if;
	-- dbms_output.put_line('Param: ' || p_ParamName || ' flag: ' || p_LogFlag);
  elsif p_ParamType = g_FAParam then
	if xdp_macros.pv_ParamCacheReqd = 'Y' then
		-- dbms_output.put_line('Getting FA from Cache..');
		xdp_param_cache.Get_fa_param_from_cache(
					  p_param_name => p_ParamName,
					  p_exists_in_cache => l_dummyChar,
					  p_param_value => l_dummyChar,
					  p_log_flag => p_LogFlag,
					  p_evaluation_proc => l_dummyChar,
					  p_default_value => l_dummyChar);
	else
		p_LogFlag := 'Y';
	end if;
  else
-- Return Default Flag to be 'Y'
	p_LogFlag := 'Y';
  end if;

end OKtoLog;


-- This routines identifies the parameter name starting from a location
-- within a string.
-- e.g. 'This is a test for $WI.PARAM and $FA.FA_PARAM'
--                          ^(20)         ^(34)
-- The routine identifies PARAM as a WI Parameter from the 20th location
-- and FA_PARAM as another parameter from 34th location
Function GetParamString(p_ProcText in varchar2,
			p_Location in number) return varchar2
is
 l_ProcSubString varchar2(80);
 l_NextChar varchar2(1);
 NotDone boolean := true;
 l_CurLoc number := p_Location;
 l_CurLength number := 0;
begin
	while (NotDone) loop
		-- Get the Next character
		l_NextChar := substr(p_ProcText, l_CurLoc, 1);

 		-- Check if the character is a valid character from the
		-- ASCII set
		if IsValidParamChar(p_Char => l_NextChar) then
			-- Valid Char. So continue..
			l_CurLength :=  l_CurLength + 1;
		else
			l_ProcSubString :=
				substr(p_ProcText, p_Location, l_CurLength);
			NotDone := false;
		end if;
		l_CurLoc := l_CurLoc + 1;
		end loop;

-- dbms_output.put_line('Found Param: ' || l_ProcSubString);
  return (l_ProcSubString);

end GetParamString;

-- This routine is used when triyng to find a potential parameter
-- Only certain characters from the ASCII table are valid characters
Function IsValidParamChar(p_Char in varchar2) return boolean
is
 l_Valid boolean := false;
 l_AsciiVal number := ascii(p_Char);
begin
 if l_AsciiVal in (95, 45, 46) then
 	-- Value is "_" and "-" and "."
	l_Valid := true;
 elsif l_AsciiVal >= 65 and l_AsciiVal <= 90 then
	-- Value is between "A" and "Z"
	l_Valid := true;
 elsif l_AsciiVal >= 97 and l_AsciiVal <= 122 then
	-- Value is between "a" and "z"
	 l_Valid := true;
 elsif l_AsciiVal >= 48 and l_AsciiVal <= 57 then
	-- Value is between "0" and "9"
	 l_Valid := true;
 else
	l_Valid := false;
 end if;

 return (l_Valid);

end IsValidParamChar;

--
--
-- This routine is used for transtation of default macros
-- These are:
--	1. GET_PARAM_VALUE
Procedure TranslateDefMacros (ProcName   in  varchar2,
                                 ProcStr         in  varchar2,
                                 CompiledProc OUT NOCOPY varchar2)

 IS
l_temp_str                  varchar2(32767);

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
 l_temp_str := ProcStr;

  -- Find the DECLARE word location and delete the users declare string
  --  (can be case sensitive)

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 then
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;

-- Replace the Users GET_PARAM_VALUE references with the actual routine
 l_temp_str := REPLACE(l_temp_str, 'GET_PARAM_VALUE', g_replace_get_param_str);

  -- Construct the procedure
 CompiledProc := CompiledProc || l_temp_str;

end TranslateDefMacros;


--
-- This routine translates all the macros which can be used within
-- a Fulfillment Procedure
-- These are:
--	1. GET_PARAM_VALUE
--	2. SEND
--	3. SEND_HTTP
--	4. GET_RESPONSE
--	5. GET_LONG_RESPONSE
--	6. NOTIFY_ERROR
--	7. RESPONSE_CONTAINS
--	8. AUDIT

Procedure TranslateFPMacros (ProcName   in  varchar2,
                          ProcStr         in  varchar2,
                          CompiledProc OUT NOCOPY varchar2)

 IS
l_dummy                     number;

l_temp_str                  varchar2(32767);

l_final_str                 varchar2(32767);
l_clash_str1     varchar2(500);
l_replace_clash_str1     varchar2(500);

l_send_loc                   number;

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
 l_temp_str := ProcStr;

-- These are chashing strings which needs to be replaced fisrt
-- before the actual macro transtlation
 l_clash_str1 := '.SEND';
 l_replace_clash_str1 := '##XEND##';


-- These are to Replacing the Clashing strings with the macros...
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroSendHttp,'SFM_HTTP');
 l_temp_str := REPLACE(l_temp_str, l_clash_str1, l_replace_clash_str1);

-- Translate the Users macro calls into the actual calls
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroSend,
				   g_replace_send_str);
 l_temp_str := REPLACE(l_temp_str, 'SFM_HTTP', g_replace_send_http_str);
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroResponseContains,
			           g_replace_resp_str);
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroNotifError,
				   g_replace_notify_str);
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroGetResp,
				   g_replace_get_response_str);
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroGetParam,
				   g_replace_get_param_str);
-- New for 11.5.6++
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroGetLongResp,
				   g_replace_get_longresp_str);
 l_temp_str := REPLACE(l_temp_str, xdp_procedure_builder.g_MacroAudit,
				   g_replace_audit_str);

 l_temp_str := REPLACE(l_temp_str, l_replace_clash_str1, l_clash_str1);

  -- Need to find the DECLARE word location and delete the users
  -- declare string (can be case sensitive)

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 then
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;

 l_final_str := l_final_str || l_temp_str;

 CompiledProc := l_final_str;

end TranslateFPMacros;


--
-- This routine translates all the macros which can be used within
-- a Connection Procedure
-- These are:
--	1. GET_PARAM_VALUE
--	2. SEND
--	3. LOGIN
Procedure TranslateConnMacros (ProcName   in  varchar2,
                                  ProcBody in  varchar2,
                                  CompiledProc OUT NOCOPY varchar2)
 IS
-- PL/SQL Block
l_dummy                     number;

l_temp_str                  varchar2(32767);
l_temp_login_str            varchar2(32767);

l_final_str                 varchar2(32767);
l_replace_login_str 	    varchar2(500);
l_clash_str1 	    varchar2(500);
l_clash_str2 	    varchar2(500);
l_clash_str3 	    varchar2(500);
l_replace_clash_str1 	    varchar2(500);
l_replace_clash_str2 	    varchar2(500);
l_replace_clash_str3 	    varchar2(500);

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin

 l_temp_str := ProcBody;

-- These are chashing strings which needs to be replaced fisrt
-- before the actual macro transtlation
 l_clash_str1 := '$LOGIN';
 l_replace_clash_str1 := '##XOGIN##';
 l_clash_str2 := '_LOGIN';
 l_replace_clash_str2 := '##_XOGIN##';
 l_clash_str3 := 'LOGIN_';
 l_replace_clash_str3 := '##XOGIN_##';

 l_temp_str := REPLACE(l_temp_str, l_clash_str1, l_replace_clash_str1);
 l_temp_str := REPLACE(l_temp_str, l_clash_str2, l_replace_clash_str2);
 l_temp_str := REPLACE(l_temp_str, l_clash_str3, l_replace_clash_str3);

-- Translate the Users macro calls into the actual calls
 l_temp_str := REPLACE(l_temp_str, 'SEND', g_replace_connect_str);
 l_temp_str := REPLACE(l_temp_str, 'LOGIN', g_replace_connect_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_PARAM_VALUE', g_replace_get_attr_str);

 l_temp_str := REPLACE(l_temp_str, l_replace_clash_str3, l_clash_str3);
 l_temp_str := REPLACE(l_temp_str, l_replace_clash_str2, l_clash_str2);
 l_temp_str := REPLACE(l_temp_str, l_replace_clash_str1, l_clash_str1);

  -- Need to find the DECLARE word location and delete the users
  -- declare string (can be case sensitive)

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 THEN
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;


 l_final_str := l_final_str || l_temp_str;

  CompiledProc := l_final_str;

end TranslateConnMacros;



--
-- This routine translates all the macros which can be used within
-- a Disconnection Procedure
-- These are:
--	1. GET_PARAM_VALUE
--	2. SEND
Procedure TranslateDisconnMacros (ProcName   in  varchar2,
                                  ProcBody in  varchar2,
                                  CompiledProc OUT NOCOPY varchar2)

 IS
-- PL/SQL Block
l_dummy                     number;

l_temp_str                  varchar2(32767);

l_final_str                 varchar2(32767);
l_disconnect_str            varchar2(500);
l_end_str                   varchar2(500);

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin

 l_temp_str := ProcBody;

-- Translate the Users macro calls into the actual calls
 l_temp_str := REPLACE(l_temp_str, 'SEND', g_replace_connect_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_PARAM_VALUE', g_replace_get_attr_str);

  -- Need to find the DECLARE word location and delete the users
  -- declare string (can be case sensitive)

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 THEN
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;


 l_final_str := l_final_str || l_temp_str;

  CompiledProc := l_final_str;

end TranslateDisconnMacros;


begin
	g_ParamLocations.delete;

end XDP_PROCEDURE_BUILDER_UTIL;

/
