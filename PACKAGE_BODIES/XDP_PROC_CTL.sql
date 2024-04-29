--------------------------------------------------------
--  DDL for Package Body XDP_PROC_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PROC_CTL" AS
/* $Header: XDPPCTLB.pls 120.1 2005/06/16 02:20:17 appldev  $ */



g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

Procedure AppendConnectCommands(Command in varchar2,
				Response in varchar2);

Function HandlePipeErrors (ErrorCode in number, PipeOperation in varchar2,
                           Module in varchar2, HandShake varchar2,
                           Command varchar2 , InternalError in varchar2) return varchar2;

Function HandleMessageErrors (ErrorCode in number, InstanceID in number,Module in varchar2, HandShake varchar2,
                              PipeName in varchar2, Timeout in number, LogFlag in number,
                              Command varchar2 , LogCommand in varchar2, Response in varchar2,
                              LogResponse in varchar2, InternalError in varchar2) return varchar2;

Procedure LogAuditTrail(LogFlag in number, FAInstanceID in number, FEName in varchar2,
                        FeType in varchar2, SWGeneric in varchar2, LogCmd in varchar2,
                        ActualStr in varchar2, Response in varchar2, ResponseLong CLOB,
			LogResp in varchar2, ProcName in varchar2);
/*
Procedure LogAuditTrail(LogFlag in number, FAInstanceID in number, FEName in varchar2,
                        FeType in varchar2, SWGeneric in varchar2, LogCmd in varchar2,
                        ActualStr in varchar2, Response in varchar2, LogResp in varchar2,
                        ProcName in varchar2);

Procedure LogAuditTrail(LogFlag in number, FAInstanceID in number, FEName in varchar2,
                        FeType in varchar2, SWGeneric in varchar2, LogCmd in varchar2,
                        ActualStr in varchar2, Response in varchar2, LogResp in varchar2,
                        ProcName in varchar2, ErrCode OUT NOCOPY number, ErrStr OUT NOCOPY varchar2);
*/

Function HandlePipeErrors (ErrorCode in number, PipeOperation in varchar2,
                           Module in varchar2, HandShake varchar2,
                           Command varchar2, InternalError in varchar2) return varchar2 is

 ErrStr varchar2(2000);
begin

  if ErrorCode = -6558 then
     ErrStr := 'Error in ' || Module || ' Message Exceeded Pipe Limit (4096 bytes). Command being Sent: ' ||
               substr(Command,1,1500);
  elsif ErrorCode = -6556 then
     ErrStr := 'Error in ' || Module || ' No Item to UNPACK for Response: ' || HandShake || ' Last Command Sent: '
               || substr(Command, 1, 1500);
  elsif ErrorCode = -6559 then
     ErrStr := 'Error in ' || Module || ' Wrong Data Type to UNPACK for Response: ' || HandShake ||
               ' Last Command Sent: ' || substr(Command, 1, 1500);
  else
    if HandShake is null then
     ErrStr := 'Unhandled Exception in ' || Module || ' Error: ' || substr(InternalError, 1, 700) ||
               ' Pipe Operation: ' || PipeOperation || ' Command being Sent: ' || substr(Command, 1, 700);
    else
     ErrStr := 'Unhandled Exception in ' || Module || ' Error: ' || substr(InternalError, 1, 700) ||
               ' Pipe Operation: ' || PipeOperation || ' Response: ' || HandShake || ' Command being Sent: '
               || substr(Command, 1, 600);

    end if;

  end if;

  return ErrStr;

end HandlePipeErrors;

Function HandleMessageErrors (ErrorCode in number, InstanceID in number,Module in varchar2, HandShake varchar2,
                              PipeName in varchar2, Timeout in number, LogFlag in number,
                              Command varchar2 , LogCommand in varchar2, Response in varchar2,
                              LogResponse in varchar2, InternalError in varchar2) return varchar2
is
 ErrStr varchar2(2000);
 l_LogResp varchar2(300) := 'CANNOT Log NE Responses due to security reasons. Please use the Command Sent as the cross reference';
 l_LogCommand varchar2(32767);
 l_Response varchar2(32767);
begin

 if LogFlag > 0 then
    l_LogCommand := LogCommand;
 else
    l_LogCommand := Command;
 end if;

 if LogResponse = 'Y' then
    l_Response := l_LogResp;
 else
    l_Response := Response;
 end if;

    if ErrorCode = -2001 then
--        ParamValueException;
          null;

    elsif ErrorCode = -20021 then
          ErrStr := 'Error in ' || Module || ' Got exception when logging into the command audit trail for ' ||
                    ' Worklist id: ' || InstanceID || ' Message Received: ' || Handshake || ' Command Sent: ' ||
                    substr(l_LogCommand,1, 400) || ' Response: ' || substr(l_Response, 1, 400) || ' Error: ' ||
                    substr(InternalError, 1, 400);

    elsif ErrorCode =  -20101 then
       ErrStr := 'Error in ' || Module ||  ' Error when sending ACK for ' || HandShake ||
                 ' Error: ' || substr(ErrStr, 1, 600) || ' Last Command sent: ' || substr(l_LogCommand, 1, 400) ||
                 ' Response: ' || substr(l_Response,1,400);

    elsif ErrorCode = -20102  then
       ErrStr := 'Error in ' || Module ||  ' Message Timedout when waiting for an ACK for ' || HandShake ||
                 ' Timeout period: ' || to_char(Timeout)  || ' Last Command sent: ' || substr(l_LogCommand, 1, 600) ||
                 ' Error: ' || substr(InternalError, 1, 600);

    elsif ErrorCode = -20103 then
       ErrStr := 'Error in ' || Module ||  ' Wait for Message Timedout. Last Message: ' || HandShake ||
                 ' Timeout period: ' || to_char(Timeout)  || ' Last Command sent: ' || substr(l_LogCommand, 1, 600) ||
                 ' Error: ' || substr(InternalError, 1, 600);

    elsif ErrorCode = -20104 then
-- e_PipeSendMesgException
          null;

    elsif ErrorCode = -20105 then
-- e_PipePackMesgException
          null;

    elsif ErrorCode = -20106 then
--e_PipeUnpackMesgException
          null;

    elsif ErrorCode =  -20107 then
       ErrStr := 'Error in ' || Module ||  ' Pipes found in an inconsistent state. Got unexpected ' || HandShake ||
                 ' SYNC message sent ';

    elsif ErrorCode =  -20300 then
            ErrStr:= 'Error in ' || Module || ' Got NE_FAILURE Message. Last Command Sent: ' ||
                     substr(l_LogCommand, 1, 600) || ' Failure Message: ' || substr(InternalError, 1, 600);

    elsif ErrorCode = -20500  then
            ErrStr:= 'Warning in ' || Module || ' Got NE_WARNING Message. Last Command Sent: ' ||
                     substr(l_LogCommand, 1, 600) || ' Warning Message: ' || substr(InternalError, 1, 600);

    elsif ErrorCode = -20610 then
            ErrStr:= 'Error in ' || Module || ' Got SESSION_LOST Message. Last Command Sent: ' ||
                     substr(l_LogCommand, 1, 600) || ' Error Message: ' || substr(InternalError, 1, 600);

    elsif ErrorCode =  -20620 then
            ErrStr:= 'Warning in ' || Module || ' Got NE_TIMEDOUT Message. Last Command Sent: ' ||
                     substr(l_LogCommand, 1, 600) || ' Warning Message: ' || substr(InternalError, 1, 600);
    else
            ErrStr := 'Unhandled Exception in ' || Module || 'Pipe: ' || PipeName || ' SQLCODE: ' ||
                      ErrorCode || ' Error: ' || substr(InternalError,1,1500);
    end if;


 return ErrStr;

end HandleMessageErrors;

/*
Procedure LogAuditTrail(LogFlag in number, FAInstanceID in number, FEName in varchar2,
                        FeType in varchar2, SWGeneric in varchar2, LogCmd in varchar2,
                        ActualStr in varchar2, Response in varchar2, LogResp in varchar2,
                        ProcName in varchar2, ErrCode OUT NOCOPY number, ErrStr OUT NOCOPY varchar2)
is
begin

 LogAuditTrail(LogFlag, FAInstanceID, FEName, FeType, SWGeneric, LogCmd,
	       ActualStr, Response, LogResp,  ProcName);

exception
when others then
 ErrCode := SQLCODE;
 ErrStr := SQLERRM;
end LogAuditTrail;
*/

Procedure LogAuditTrail(LogFlag in number, FAInstanceID in number, FEName in varchar2,
                        FeType in varchar2, SWGeneric in varchar2, LogCmd in varchar2,
                        ActualStr in varchar2, Response in varchar2, ResponseLong in CLOB,
			LogResp in varchar2, ProcName in varchar2)
is
 l_LogResp varchar2(300) := 'CANNOT Log FE Responses due to security reasons. Please use the Command Sent as the cross reference';
 l_LogCommand varchar2(32767);
 l_Response varchar2(32767);
begin

   if LogFlag > 0 then
      l_LogCommand := substr(LogCmd,1,3999);
   else
      l_LogCommand := ActualStr;
   end if;

   if LogResp = 'Y' then
      l_Response := l_LogResp;
   else
      l_Response := substr(Response,1,32766);
   end if;

 XDP_AQ_UTILITIES.LogCommandAuditTrail( FAInstanceID, FEName, FeType, SWGeneric, l_LogCommand, sysdate, l_Response, ResponseLong, sysdate, ProcName);

end LogAuditTrail;


Procedure AppendConnectCommands(Command in varchar2,
				Response in varchar2)
is
 l_size number;
begin
 l_size := pv_ConnectCommands.count;

 pv_ConnectCommands(l_size + 1).command := Command;
 pv_ConnectCommands(l_size + 1).response := Response;

end AppendConnectCommands;


/***************************************************
** These Set of Procedures/Functions are for PROVIIONING PROCEDURE
** GENERATION, EXECUTION etc
***************************************************/



/********  Procedure CHECK_FOR_OLD_PARAM ***********/
/*
 * Author: V.Rajaram
 * Date Created: April 10 1999
 *
 * INPUT: parameter name
 * OUTPUT: parameter name with ".old" stripped off (if any),
 *       : flag indicating if the input parameter name had a ".old"
 *
 * This procedure checks if the input parameter has ".old" in it.
 * If so it strips it out and sets the old_flag to 1 and returns
 *
 * Usage: In sdp_find_parameters, sdp_find_replace_procedures procedure.
 */

Procedure CHECK_FOR_OLD_PARAM (Param  in   varchar2,
                               ParamMinusOld  OUT NOCOPY  varchar2,
                               OldFlag   OUT NOCOPY  number)
is

 l_dummy        number;
begin
   l_dummy := INSTR(UPPER(Param),'.OLD',1,1);

   IF l_dummy = 0 then
      ParamMinusOld := Param;
      OldFlag := 0;
   ELSE
      ParamMinusOld := SUBSTR(Param,1,l_dummy-1);
      OldFlag := 1;
   end IF;
end CHECK_FOR_OLD_PARAM;






/********  Procedure CHECK_PARAM_NAME ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: Service Name, Version, Param Name
 * OUTPUT: Error Code, Error String
 *
 * This procedure takes an SFM Parameter name as input and checks if they have been
 * defined for the service name, verision
 *
 * Usage: In the sdp_find_parameters procedure
 */

Procedure CHECK_PARAM_NAME (WorkitemID in number,
                            FAId in number,
                            ParamType in varchar2,
                            Param  in  varchar2,
                            ErrCode OUT NOCOPY number,
                            ErrStr OUT NOCOPY varchar2)
is
 l_ParamCount number := 0;

begin
  ErrCode := 0;
  ErrStr := null;

  if ParamType = 'WORKITEM' then
       begin
        select 1 into l_ParamCount from dual
        where exists ( select LOOKUP_CODE
                       from CSI_LOOKUPS
                       where LOOKUP_CODE = Param
                       and lookup_type = 'CSI_EXTEND_ATTRIB_POOL');


       exception
       when no_data_found then
         l_ParamCount := 0;
       when others then
         RAISE;
       end;

  elsif ParamType = 'FA' then
       begin
        select 1 into l_ParamCount from dual
        where exists (
                       select XFA.PARAMETER_NAME
                       from XDP_FA_PARAMETERS XFA
                       where FULFILLMENT_ACTION_ID = FAID
                       and XFA.PARAMETER_NAME = Param );

       exception
       when no_data_found then
         l_ParamCount := 0;
       when others then
         RAISE;
       end;
  elsif ParamType = 'ORDER' then
     l_ParamCount := 1;
   elsif ParamType = 'LINE' then
     l_ParamCount := 1;
  end if;


  if l_ParamCount = 0 then
     ErrCode := -1;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAMETER');
     FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', Param);
     FND_MESSAGE.SET_TOKEN('PARAMETER_TYPE', ParamType);
     ErrStr := FND_MESSAGE.GET;
  end if;

exception
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.CHECK_PARAM_NAME. Error: ' || SUBSTR(SQLERRM,1,200);
end CHECK_PARAM_NAME;




Procedure GET_PARAM_TYPE (Param in varchar2,
                          ParamType OUT NOCOPY varchar2,
                          ActualParam OUT NOCOPY varchar2,
                          ErrCode OUT NOCOPY number,
                          ErrStr OUT NOCOPY varchar2)
is
 l_Dummy number;
 l_ParamType varchar2(10);

begin
 ErrCode := 0;
 ErrStr := null;

 l_Dummy := INSTR(Param,'.');
 if l_Dummy > 0 then

     l_ParamType := SUBSTR(Param, 1, l_Dummy-1);
     if l_ParamType = 'WI' then
        ParamType := 'WORKITEM';
        ActualParam := SUBSTR(Param, (l_Dummy + 1), LENGTH(Param));
        return;
     end if;

     if l_ParamType = 'FA' then
        ParamType := 'FA';
        ActualParam := SUBSTR(Param, (l_Dummy + 1), LENGTH(Param));
        return;
     end if;

     if l_ParamType = 'ORDER' then
        ParamType := 'ORDER';
        ActualParam := SUBSTR(Param, (l_Dummy + 1), LENGTH(Param));
        return;
     end if;

     if l_ParamType = 'LINE' then
        ParamType := 'LINE';
        ActualParam := SUBSTR(Param, (l_Dummy + 1), LENGTH(Param));
        return;
     end if;

 end if;

       ErrCode := -1;
       FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_PARAMETER_TYPE');
       FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', l_ParamType);
       ErrStr := FND_MESSAGE.GET;

exception
when others then
  ErrCode := SQLCODE;
  ErrStr := SQLERRM;
end GET_PARAM_TYPE;




/********  Procedure GET_PARAMETER_VALUE ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 15 1998
 *
 * INPUT: workitem_instance_id, parameter name, old parameter flag, service,
 *        version, action code
 * OUTPUT: parameter value, Err_code, Error String
 *
 * This procedure gets the value of the input parameter. If the old parameter flag is
 * true then the old value of the parameter is returned.
 * Also if the value is to be determined by executing an external procedure, this
 * procedure identifies the procedure and executes the procedure dynamically.
 *
 * Usage: At Runtime in the sdp_find_replace_param procedure
 */

Procedure GET_PARAMETER_VALUE ( OrderID in number,
                           LineItemID in number,
                           WIInstanceID in  number,
                           FAInstanceID in number,
                           ParamName in  varchar2,
                           ParamType in varchar2,
                           ParamOldFlag in number,
                           ParamValue  OUT NOCOPY varchar2,
                           LogFlag OUT NOCOPY boolean,
                           ParamLogValue OUT NOCOPY varchar2,
                           ErrCode OUT NOCOPY number,
                           ErrStr OUT NOCOPY varchar2)
IS
  e_InvalidParamTypeException   exception;
  l_ParamRefValue varchar2(4000);
  x_progress varchar2(2000);
begin


  if ParamType = 'WORKITEM' then
     XDP_ENGINE.GET_WORKITEM_PARAM_VALUE(WIInstanceID,
                                         ParamName,
                                         ParamValue,
                                         l_ParamRefValue,
                                         LogFlag,
                                         ErrCode,
                                         ErrStr);

     if ParamOldFlag = 1 then
        ParamValue :=  l_ParamRefValue;
     end if;

     if LogFlag = FALSE then
        ParamLogValue := ParamName;
     else
        ParamLogValue := ParamValue;
     end if;

  elsif ParamType = 'FA' then

         XDP_ENGINE.GET_FA_PARAM(FAInstanceID,
                                 ParamName,
                                 ParamValue,
                                 l_ParamRefValue,
                                 LogFlag,
                                 ErrCode,
                                 ErrStr);

        if ErrCode <> 0 then
           RAISE e_ParamValueException;
        end if;

        if ParamOldFlag = 1 then
           ParamValue := l_ParamRefValue;
        end if;

        if LogFlag = FALSE then
           ParamLogValue := ParamName;
        else
           ParamLogValue := ParamValue;
        end if;

  elsif ParamType = 'ORDER' then
        ParamValue := XDP_ENGINE.GET_ORDER_PARAM_VALUE (OrderID,
                                                        ParamName);
  elsif ParamType = 'LINE' then
        ParamValue := XDP_ENGINE.GET_LINE_PARAM_VALUE(LineItemID,
                                                      ParamName);
  else
   RAISE e_InvalidParamTypeException;
  end if;

 ErrCode := 0;
 ErrStr := NULL;

exception
when e_InvalidParamTypeException then
  ErrCode := -1;
  ErrStr := x_progress;
when e_ParamValueException then
  ErrCode := -20001;
  ErrStr := x_progress;
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.GET_PARAMETER_VALUE. Error: ' || SUBSTR(SQLERRM,1,200);
end GET_PARAMETER_VALUE;






/********  Procedure FIND_PARAMETERS ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: Service Name, Version, Action Code, Input String
 * OUTPUT: Err_code, Error String
 *
 * This procedure takes a long string as input and checks for any SFM parameters.
 * The parameters are identified by $... The delimiters are " ", ":", ";", ",", "'"
 * When found it checks if such a parameter has been defined for the service, version,
 * action. This is done by Sdp_Check_Param_Name procedure.
 *
 * Usage: In forms. When the user tries to saves his provisioning program.
 */

 Procedure FIND_PARAMETERS (FAID in number,
                            WorkitemID number,
                            Str in varchar2,
                            ErrCode OUT NOCOPY varchar2,
                            ErrStr  OUT NOCOPY varchar2)
 is
TYPE DELIM_POS IS TABLE OF number INDEX BY BINARY_INTEGER;

  e_CheckParamException  exception;
  e_InvalidParamTypeException  exception;

  l_param_w_dollar        varchar2(50);
  l_param_wo_dollar       varchar2(50);
  l_param_wo_old          varchar2(50);
  l_old_flag              number;
  l_save_str              varchar2(32767);
  i                        number;
  j                        number;
  l_str_len               number;
  l_dollar_found          number;
  l_syntax_error          number;
  l_done                  number;
  l_delim                 DELIM_POS;
  l_mark                  number;
  l_counter               number;

  l_ParamType             varchar2(50);
  l_ActualParam           varchar2(50);
  l_dummy number;
  x_progress varchar2(2000);
begin

  ErrCode := 0;
  ErrStr := null;

    l_save_str := Str;
    l_done := 0;

    WHILE l_done <> 1 LOOP
    	 l_str_len := LENGTH(l_save_str);

    /* Check for "$" character. Indicates sn SFM variable */
  	 i := INSTR(l_save_str,'$',1,1);

  	  IF i = 0 then
	    /* No Variable found return the same string */
	      ErrCode := 0;
	      ErrStr := NULL;
	      l_done := 1;
	      RETURN;
	  ELSE
	    /* A variable found */
	      l_dollar_found := 1;
	  end IF;

	  /*
         * If the $ is the last letter then there is a syntax error
        */
	  IF i = l_str_len then
	       l_syntax_error := 1;
	       ErrCode := -1;
	       ErrStr := 'Syntax Error in ' || Str || ' No variable found';
	       RETURN;
	  end IF;

	  l_save_str := SUBSTR(l_save_str,i,l_str_len);

        /*
         * Find all the possible delimiters to get the variable name
        */
	  l_delim(1) := INSTR(l_save_str,',',1,1);
	  l_delim(2) := INSTR(l_save_str,':',1,1);
   	  l_delim(3) := INSTR(l_save_str,';',1,1);
	  l_delim(4) := INSTR(l_save_str,' ',1,1);
	  l_delim(5) := INSTR(l_save_str,'''',1,1);
	  l_delim(6) := INSTR(l_save_str,'"',1,1);

	  l_mark := -1;
	  j := -1;

        /*
         * Find the closest delimter from the $ sign
        */
	  FOR l_counter in 1..6 LOOP
        	IF l_delim(l_counter) > 0 AND j < 0 then
            	j := l_delim(l_counter);
                  l_mark := l_counter;
        	ELSIF l_delim(l_counter) > 0 AND l_delim(l_counter) < j then
            	j := l_delim(l_counter);
                  l_mark := l_counter;
       	end IF;
	  end LOOP;

        /*
         * Get the parameter
         */
        IF j > 0 then
        	l_param_w_dollar := SUBSTR(l_save_str,1,j-1);
            l_save_str := SUBSTR(l_save_str,j,l_str_len);
	  ELSIF j = -1 then
        	l_param_w_dollar := l_save_str;
		l_save_str := ' ';
	  end IF;

	  l_param_wo_dollar := SUBSTR(l_param_w_dollar,2,LENGTH(l_param_w_dollar));
        l_old_flag := 0;

        /*
         * Check if the parameter has a ".old" in it. If so the procedure strips it off
         */
        CHECK_FOR_OLD_PARAM(l_param_wo_dollar,l_param_wo_old,l_old_flag);

        GET_PARAM_TYPE(l_param_wo_old, l_ParamType, l_ActualParam, ErrCode, ErrStr);

        if ErrCode <> 0 then
           ErrStr :=  ErrStr || ' in ' || l_param_wo_old;
           Raise e_InvalidParamTypeException;
        end if;

        /*
         * Check if the parameter got is a valid parameter for the
         * service, version, action. If not found error out
         */
        CHECK_PARAM_NAME(WorkitemID, FAID, l_ParamType, l_ActualParam , ErrCode, ErrStr);
	IF ErrCode <> 0 then
          RAISE e_CheckParamException;
	end IF;
    end LOOP;
exception
  when e_CheckParamException then
    null;
  when e_InvalidParamTypeException then
    ErrCode := -1;
--    ErrStr := 'Invalid Parameter Type';
  when e_ProcExecException then
    ErrCode := -20021;
    ErrStr := x_progress;
  when others then
    ErrCode := SQLCODE;
    ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.FIND_PARAMETERS. Error: ' || SUBSTR(SQLERRM,1,200);
end FIND_PARAMETERS;






/********  Procedure FIND_REPLACE_PARAMS ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: WIInstanceID, Input String (command), service, version, action code
 * OUTPUT: Command str (with params replaced with values) Err_code, Error String
 *
 * This procedure is executed at run time by the Send function to get the values of
 * of the parameters. It takes a long string as input and checks for any SFM parameters.
 * The parameters are identified by $... The delimiters are " ", ":", ";", ",", "'"
 * When found it gets the value using Get_Param_Value procedure.
 *
 * Usage: At runtime in the Send procedure
 */

Procedure FIND_REPLACE_PARAMS ( OrderID in number,
                                LineItemID in number,
                                WorkiteminstanceID in number,
                                FAinstanceID in number,
                                Str in varchar2,
                                CmdStr OUT NOCOPY varchar2,
                                LogFlag OUT NOCOPY number,
                                LogStr  OUT NOCOPY varchar2,
                                ErrCode OUT NOCOPY varchar2,
                                ErrStr  OUT NOCOPY varchar2)

 IS

TYPE DELIM_POS IS TABLE OF number INDEX BY BINARY_INTEGER;

  e_ParamValueException    exception;
  e_InvalidParamTypeException    exception;

  l_param_w_dollar          varchar2(50);
  l_ActualParam          varchar2(50);
  l_ParamType          varchar2(50);
  l_param_wo_dollar         varchar2(50);
  l_param_wo_old            varchar2(50);
  l_old_flag                number;
  l_save_str                varchar2(32767);
  i                          number;
  j                          number;
  l_str_len                 number;
  l_dollar_found            number;
  l_syntax_error            number;
  l_done                    number;
  l_delim                   DELIM_POS;
  l_mark                    number;
  l_counter                 number;
  l_param_value             varchar2(4000);
  l_param_log_value         varchar2(4000);
  l_out_log_flag            BOOLEAN;

  x_progress varchar2(2000);
begin

  ErrCode := 0;
  ErrStr := null;

    l_save_str := Str;
    l_done := 0;

    l_out_log_flag := TRUE;
    LogFlag := 0;

    WHILE l_done <> 1 LOOP
    	 l_str_len := LENGTH(l_save_str);
       /*
        * Check for the character "$". It identifies an SFM parameter
        */

  	 i := INSTR(l_save_str,'$',1,1);
  	  IF i = 0 then
	    /* No Variable found return the same string */
	      ErrCode := 0;
	      ErrStr := NULL;
	      l_done := 1;
              if l_save_str = ' ' then
                exit;
              else
                CmdStr :=   CmdStr || l_save_str;
                LogStr :=   LogStr || l_save_str;
	        exit;
              end if;
	  ELSE
	    /* A variable found */
	      l_dollar_found := 1;
          /* Save the string to the left of the "$" sign in   CmdStr */
              CmdStr :=   CmdStr || SUBSTR(l_save_str,1,i-1);
              LogStr :=   LogStr || SUBSTR(l_save_str,1,i-1);
	  end IF;

	  /*
         * If the $ is the last letter syntax error
        */
	  IF i = l_str_len then
	       l_syntax_error := 1;
	       ErrCode := -1;
	       ErrStr := 'Syntax Error in ' || Str || ' No variable found';
	       RETURN;
	  end IF;

	  l_save_str := SUBSTR(l_save_str,i,l_str_len);
        /*
         * Find all the possible delimiters to get the variable name
        */
	  l_delim(1) := INSTR(l_save_str,',',1,1);
	  l_delim(2) := INSTR(l_save_str,':',1,1);
   	  l_delim(3) := INSTR(l_save_str,';',1,1);
	  l_delim(4) := INSTR(l_save_str,' ',1,1);
	  l_delim(5) := INSTR(l_save_str,'''',1,1);
	  l_delim(6) := INSTR(l_save_str,'"',1,1);

	  l_mark := -1;
	  j := -1;

        /*
         * Find the closest delimter from the $ sign
        */
	  FOR l_counter in 1..6 LOOP
        	IF l_delim(l_counter) > 0 AND j < 0 then
            	j := l_delim(l_counter);
                  l_mark := l_counter;
        	ELSIF l_delim(l_counter) > 0 AND l_delim(l_counter) < j then
            	j := l_delim(l_counter);
                  l_mark := l_counter;
       	end IF;
	  end LOOP;

        /*
         * Get the parameter
         */
        IF j > 0 then
        	l_param_w_dollar := SUBSTR(l_save_str,1,j-1);
            l_save_str := SUBSTR(l_save_str,j,l_str_len);
	  ELSIF j = -1 then
        	l_param_w_dollar := l_save_str;
		l_save_str := ' ';
	  end IF;

	  l_param_wo_dollar := SUBSTR(l_param_w_dollar,2,LENGTH(l_param_w_dollar));

        l_old_flag := 0;

	   /*
          * Check if the parameter had a ".old" in it.
         */
        CHECK_FOR_OLD_PARAM(l_param_wo_dollar,l_param_wo_old,l_old_flag);

        GET_PARAM_TYPE(l_param_wo_old, l_ParamType, l_ActualParam, ErrCode, ErrStr);
        if ErrCode <> 0 then
           raise e_InvalidParamTypeException;
        end if;

        /*
         * Get the parameter value at run time
         */
        GET_PARAMETER_VALUE(OrderID, LineItemID, WorkitemInstanceID, FAInstanceID, l_ActualParam, l_ParamType, l_old_flag, l_param_value, l_out_log_flag, l_param_log_value, ErrCode, ErrStr);
	  IF ErrCode <> 0 then
            x_progress := 'In XDP_PROC_CTL.FIND_REPLACE_PARAMS Got parameter value exception when evaluating the value of: ' || l_param_wo_dollar || ' Error: ' || SUBSTR(ErrStr, 1, 1500);
            CmdStr := Str;
            LogStr := Str;
            RAISE e_ParamValueException;
 	  end IF;

        /*
         * Replace parameter with its value
         */
        CmdStr := CmdStr || l_param_value;
        IF l_out_log_flag = FALSE then
           LogStr := LogStr || l_param_log_value;
           LogFlag := LogFlag + 1;
        ELSE
           LogStr := LogStr || l_param_value;
        end IF;

   end LOOP;



  ErrCode := 0;
  ErrStr := null;

exception
  when e_ParamValueException then
    ErrCode := -20001;
    ErrStr := x_progress;
  when e_ProcExecException then
    ErrCode := -20021;
    ErrStr := x_progress;
  when others then
    ErrCode := SQLCODE;
    ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.FIND_REPLACE_PARAMS. Error: ' || SUBSTR(SQLERRM,1,200);
end FIND_REPLACE_PARAMS;


 Procedure GENERATE_PROC (ProcName   in  varchar2,
                          ProcStr         in  varchar2,
                          CompiledProc OUT NOCOPY varchar2,
                          ErrCode    OUT NOCOPY number,
                          ErrStr     OUT NOCOPY varchar2)

 IS
l_dummy                     number;

l_out_str                   varchar2(32767);
l_temp_str                  varchar2(32767);

l_count                     number;
l_cnt                       number;
l_done                      number;
l_start                     number;

l_final_str                 varchar2(32767);
l_replace_send_str          varchar2(500);
l_replace_send_http_str          varchar2(500);
l_replace_resp_str          varchar2(500);
l_replace_notify_str        varchar2(500);
l_replace_get_response_str  varchar2(500);
l_sync_str                  varchar2(500);
l_replace_get_param_str     varchar2(500);

l_str_before_send            varchar2(32767);
l_str_after_send             varchar2(32767);
l_send_loc                   number;

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
  ErrCode := 0;
  ErrStr := null;

 l_temp_str := ProcStr;

 /*
  * Replace user written SEND, RESPONSE_CONTAINS etc... to comply with the actual spec of those
  * procedures
  * Remove the user written DECLARE as we will be generating the procedure on the fly
  *
  * Form the strings here...
  */

 l_replace_send_str := 'XDP_PROC_CTL.SEND(order_id, ' || g_new_line ||
					' line_item_id, ' || g_new_line ||
					' workitem_instance_id, ' || g_new_line ||
					' fa_instance_id, ' || g_new_line ||
					' db_channel_name, ' || g_new_line ||
					' FE_name,  ''' ||
					  ProcName ||''', ' || g_new_line ||
					' sdp_internal_response, ' || g_new_line ||
					' sdp_internal_err_code, ' || g_new_line ||
					' sdp_internal_err_str, ';

 l_replace_send_http_str := 'XDP_PROC_CTL.SEND_HTTP(order_id, ' || g_new_line ||
						  ' line_item_id, ' || g_new_line ||
						  ' workitem_instance_id, ' ||g_new_line ||
						  ' fa_instance_id, ' || g_new_line ||
						  ' db_channel_name, ' || g_new_line ||
						  ' FE_name,  ''' ||
						  ProcName ||''', ' || g_new_line ||
						  ' sdp_internal_response, '||g_new_line ||
						  ' sdp_internal_err_code, '||g_new_line ||
						  ' sdp_internal_err_str, ';

 l_replace_resp_str := 'XDP_PROC_CTL.RESPONSE_CONTAINS(sdp_internal_response, '||g_new_line;

 l_replace_notify_str := 'XDP_PROC_CTL.NOTIFY_ERROR(sdp_internal_response, '||g_new_line||
						  ' sdp_internal_err_code, ' ||g_new_line||
						  ' sdp_internal_err_str, ';

 l_replace_get_response_str := 'XDP_PROC_CTL.GET_RESPONSE(sdp_internal_response)';

 l_sync_str := 'XDP_PROC_CTL.SEND_SYNC(db_channel_name, ' || g_new_line ||
				     ' fe_name, ' || g_new_line ||
				     ' sdp_internal_err_code, ' || g_new_line ||
				     ' sdp_internal_err_str);';

 l_replace_get_param_str := 'XDP_PROC_CTL.GET_PARAM_VALUE(
					  order_id, ' || g_new_line ||
					' line_item_id, ' || g_new_line ||
					' workitem_instance_id, '|| g_new_line ||
					' fa_instance_id, ';


 /*
  * Replace the strings here...
  */
 l_temp_str := REPLACE(l_temp_str, 'SEND(', l_replace_send_str);
 l_temp_str := REPLACE(l_temp_str, 'SEND_HTTP(', l_replace_send_http_str);
 l_temp_str := REPLACE(l_temp_str, 'RESPONSE_CONTAINS(', l_replace_resp_str);
 l_temp_str := REPLACE(l_temp_str, 'NOTIFY_ERROR(', l_replace_notify_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_RESPONSE', l_replace_get_response_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_PARAM_VALUE(', l_replace_get_param_str);

 /*
  * Need to find the DECLARE word location and delete the users declare string (can be case sensitive)
  */

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 then
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;

 /*
  * Construct the procedure
  */
  if fnd_profile.defined('XDP_FP_SPEC') then
     fnd_profile.get('XDP_FP_SPEC', l_final_str);
     l_final_str := ' Procedure ' || ProcName  || ' ( '|| g_new_line || l_final_str || ' ) ' || g_new_line ||
                    'IS ' || g_new_line ||
                    ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';
  else

     l_final_str := ' Procedure ' || ProcName  || ' ( ' || g_new_line ||
     ' order_id in number, ' || g_new_line ||
     ' line_item_id in number, ' || g_new_line ||
     ' workitem_instance_id in number, ' || g_new_line ||
     ' fa_instance_id in number, ' || g_new_line ||
     ' db_channel_name in varchar2, ' || g_new_line ||
     ' FE_name in varchar2, ' || g_new_line ||
     ' FA_item_type in varchar2, ' || g_new_line ||
     ' FA_item_key  in varchar2, ' || g_new_line ||
     ' sdp_internal_err_code out number, ' || g_new_line ||
     ' sdp_internal_err_str out varchar2 ' || ' ) ' || g_new_line ||
     'IS ' || g_new_line ||
    ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';

  end if;

/*
 l_final_str := ' Procedure ' || ProcName || ' ( order_id in number, ' || g_new_line ||
' line_item_id in number, ' || g_new_line ||
' workitem_instance_id in number,  ' || g_new_line ||
' fa_instance_id in number, ' || g_new_line ||
' db_channel_name in varchar2, ' || g_new_line ||
' FE_name in varchar2, ' || g_new_line ||
' FA_item_type in varchar2, ' || g_new_line ||
' FA_item_key  in varchar2, ' || g_new_line ||
' sdp_internal_err_code out number, ' || g_new_line ||
' sdp_internal_err_str out varchar2 ) ' || g_new_line ||
'IS ' || g_new_line ||
' sdp_internal_response varchar2 (32767); ' || g_new_line ||
' ';
*/

 l_final_str := l_final_str || l_temp_str;

 /*
  * Find the first users's Send string and insert the SEND_SYNC procedure call before the
  * first call to send.
  */
 l_send_loc := INSTR(UPPER(l_final_str), 'XDP_PROC_CTL.SEND(', 1, 1);

 IF l_send_loc <> 0 then
    l_str_before_send := SUBSTR(l_final_str, 1, l_send_loc -1);
    l_str_after_send := SUBSTR(l_final_str, l_send_loc, LENGTH(l_final_str));

    l_final_str := l_str_before_send || l_sync_str || l_str_after_send;
 end IF;

/*
 * Parse the string for any errors. This is the dynamic generation of the procedure
 */

  CompiledProc := l_final_str;
  ErrCode := 0;
  ErrStr := 'Successfully generated the stored procedure ' || ProcName;

exception
  when others then
     ErrCode := SQLCODE;
     ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.GENERATE_PROC. Procedure to be generated: ' || ProcName || ' Error: ' || SUBSTR(SQLERRM,1,200);
end GENERATE_PROC;




/********  Procedure GENERATE_PROC ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: Procedure Name, Input String (user written procedure)
 * OUTPUT: Err_code, Error String
 *
 * This procedure takes the user written procedure string and the procedure name
 * as input and generates the actual procedure dynamically to be executed by Workflow.
 * It also generates any syntax errors in the actual PL/SQL block written by the user.
 *
 * Usage: In forms. After the sdp_find_parameters procedure went successfully.
 */

Procedure GENERATE_PROC (ProcName   in  varchar2,
                         ProcStr         in  varchar2,
                         ErrCode    OUT NOCOPY number,
                         ErrStr     OUT NOCOPY varchar2)
 IS
-- PL/SQL Block
l_cursorID                  number;
l_dummy                     number;

l_out_str                   varchar2(32767);
l_temp_str                  varchar2(32767);

l_count                     number;
l_cnt                       number;
l_done                      number;
l_start                     number;

l_final_str                 varchar2(32767);
l_replace_send_str          varchar2(500);
l_replace_send_http_str          varchar2(500);
l_replace_resp_str          varchar2(500);
l_replace_notify_str        varchar2(500);
l_replace_get_response_str  varchar2(500);
l_sync_str                  varchar2(500);
l_replace_get_param_str     varchar2(500);
--l_replace_connect_str varchar2(500);
--l_replace_disconnect_str varchar2(500);
--l_replace_tempconn_str varchar2(500);

l_str_before_send            varchar2(32767);
l_str_after_send             varchar2(32767);
l_send_loc                   number;

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
  ErrCode := 0;
  ErrStr := null;

 l_cursorID := DBMS_SQL.OPEN_CURSOR;


 l_temp_str := ProcStr;

 /*
  * Replace user written SEND, RESPONSE_CONTAINS etc... to comply with the actual spec of those
  * procedures
  * Remove the user written DECLARE as we will be generating the procedure on the fly
  *
  * Form the strings here...
  */
 l_replace_send_str := 'XDP_PROC_CTL.SEND(order_id,
					  line_item_id,
					  workitem_instance_id,
					  fa_instance_id,
					  db_channel_name,
					  FE_name,  ''' ||
					  ProcName ||''',
					  sdp_internal_response,
					  sdp_internal_err_code, sdp_internal_err_str, ';

 l_replace_send_http_str := 'XDP_PROC_CTL.SEND_HTTP(
					  order_id,
					  line_item_id,
					  workitem_instance_id,
					  fa_instance_id,
					  db_channel_name,
					  FE_name,  ''' || ProcName ||''',
					  sdp_internal_response,
					  sdp_internal_err_code,
					  sdp_internal_err_str, ';

 l_replace_resp_str := 'XDP_PROC_CTL.RESPONSE_CONTAINS(sdp_internal_response, ';

 l_replace_notify_str := 'XDP_PROC_CTL.NOTIFY_ERROR(sdp_internal_response,
					  	    sdp_internal_err_code,
						    sdp_internal_err_str, ';

 l_replace_get_response_str := 'XDP_PROC_CTL.GET_RESPONSE(sdp_internal_response)';

 l_sync_str := 'XDP_PROC_CTL.SEND_SYNC(db_channel_name,
				       fe_name,
				       sdp_internal_err_code,
				       sdp_internal_err_str);';

 l_replace_get_param_str := 'XDP_PROC_CTL.GET_PARAM_VALUE(order_id,
							  line_item_id,
							  workitem_instance_id,
							  fa_instance_id, ';


 /*
  * Replace the strings here...
  */
 l_temp_str := REPLACE(l_temp_str, 'SEND(', l_replace_send_str);
 l_temp_str := REPLACE(l_temp_str, 'SEND_HTTP(', l_replace_send_http_str);
 l_temp_str := REPLACE(l_temp_str, 'RESPONSE_CONTAINS(', l_replace_resp_str);
 l_temp_str := REPLACE(l_temp_str, 'NOTIFY_ERROR(', l_replace_notify_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_RESPONSE', l_replace_get_response_str);
 l_temp_str := REPLACE(l_temp_str, 'GET_PARAM_VALUE(', l_replace_get_param_str);

 /*
  * Need to find the DECLARE word location and delete the users declare string (can be case sensitive)
  */

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 then
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;


 /*
  * Construct the procedure
  */
 l_final_str := 'CREATE OR REPLACE Procedure ' || ProcName || ' (
  order_id in number,
  line_item_id in number,
  workitem_instance_id in number,
  fa_instance_id in number,
  db_channel_name in varchar2,
  FE_name in varchar2,
  FA_item_type in varchar2,
  FA_item_key  in varchar2,
  sdp_internal_err_code out number,
  sdp_internal_err_str out varchar2)
 IS
  sdp_internal_response varchar2 (32767);
  ';

 l_final_str := l_final_str || l_temp_str;

 /*
  * Find the first users's Send string and insert the SEND_SYNC procedure call before the
  * first call to send.
  */
 l_send_loc := INSTR(UPPER(l_final_str), 'XDP_PROC_CTL.SEND(', 1, 1);

 IF l_send_loc <> 0 then
    l_str_before_send := SUBSTR(l_final_str, 1, l_send_loc -1);
    l_str_after_send := SUBSTR(l_final_str, l_send_loc, LENGTH(l_final_str));

    l_final_str := l_str_before_send || l_sync_str || l_str_after_send;
 end IF;


/*
 * Parse the string for any errors. This is the dynamic generation of the procedure
 */
DBMS_SQL.PARSE(l_cursorID, l_final_str, DBMS_SQL.V7);

  DBMS_SQL.CLOSE_CURSOR(l_cursorID);
  COMMIT;
  ErrCode := 0;
  ErrStr := 'Successfully generated the stored procedure ' || ProcName;

exception
  when others then
     ErrCode := SQLCODE;
     ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.GENERATE_PROC. Procedure to be generated: ' || ProcName || ' Error: ' || SUBSTR(SQLERRM,1,200);
     DBMS_SQL.CLOSE_CURSOR(l_cursorID);
end GENERATE_PROC;





/********  Procedure SHOW_PROC_ERRORS ***********/
/*
 * Author: V.Rajaram
 * Date Created: Sept 4 1998
 *
 * INPUT: Procedure Name (Users procedure)
 * OUTPUT: Error text, Err_code, Error String
 *
 * This procedure takes the user written procedure name
 * as input and lists all the errors when generating the procedure
 *
 * Usage: In forms. When trying to generate the provisioning procedure
 */

Procedure SHOW_PROC_ERRORS (ProcName   in  varchar2,
                             ErrCode    OUT NOCOPY number,
                             Errors     OUT NOCOPY varchar2)
IS

 CURSOR c_GetAllErrors(p_ProcName varchar2) IS
 SELECT SUBSTR(text,1,80)
 FROM user_errors
 WHERE UPPER(name) = UPPER(p_ProcName)
 and sequence < 3
 order by line;

temp_err varchar2(100);

begin

  ErrCode := 0;
  ERRORS := null;

   OPEN c_GetAllErrors(ProcName);
   LOOP
      FETCH c_GetAllErrors into temp_err;
      EXIT when c_GetAllErrors%NOTFOUND;

      ERRORS := ERRORS || '
' || temp_err;
   end LOOP;

   IF ERRORS IS NULL then
      ERRORS := 'No Errors';
   end IF;

   IF c_GetAllErrors%ISOPEN then
     CLOSE c_GetAllErrors;
   end IF;


exception
when others then
 IF c_GetAllErrors%ISOPEN then
   CLOSE c_GetAllErrors;
 end IF;

 ErrCode := SQLCODE;
 ERRORS := 'Unhandeled Exception in XDP_PROC_CTL.SHOW_PROC_ERRORS. for Procedure ' || ProcName || ' Error: ' || SUBSTR(SQLERRM,1,200);
end SHOW_PROC_ERRORS;



/********  Procedure GET_ADAPTER_TOTAL_TIMEOUT ***********/
/*
 * Author: V.Rajaram
 * Date Created: August 11 1998
 *
 * INPUT: NE Name, NE Type, SW Generic
 * OUTPUT: Total Timeout , Err_code, Error String
 *
 * This is the procedure is used to find out the total timeout to which the Provisining
 * procedure waits for the message from the nem
 *
 * Usage: In Send function for to assign the WAIT Message timeout.
 */

Procedure GET_ADAPTER_TOTAL_TIMEOUT (NeID         in  number,
                                     Timeout       OUT NOCOPY number,
                                     ErrCode      OUT NOCOPY number,
                                     ErrStr       OUT NOCOPY varchar2)
is
 l_FeValue   varchar2(20);
 l_Retries number := 0;
 l_CmdTimeout number := 120;
 l_RetryWait number := 0;


begin
  ErrCode := 0;
  ErrStr := null;

  Timeout := 0;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(NeID, pv_attrFeCmdTimeout);
    if l_FeValue is null then
       l_CmdTimeout := 120;
    else
       l_CmdTimeout := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    l_CmdTimeout := 120;
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(NeID, pv_attrFeRetryCount);
    if l_FeValue is null then
       l_Retries := 0;
    else
       l_Retries := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    l_Retries := 0;
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(NeID, pv_attrFeCmdRetryWait);
    if l_FeValue is null then
       l_RetryWait := 0;
    else
       l_RetryWait := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    l_RetryWait := 0;
  when others then
    RAISE e_ParamValueException;
  end;

  IF to_number(l_Retries) <> 0 then
     Timeout := to_number(l_CmdTimeout) + ( to_number(l_CmdTimeout) + to_number(l_RetryWait) ) * to_number(l_Retries);
  ELSE
     Timeout := to_number(l_CmdTimeout);
  end IF;

  IF Timeout = 0 then
    Timeout := 120;
  end IF;

  Timeout := Timeout + 5;

exception
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.GET_NEM_TOTAL_TIMEOUT. Error: ' || SUBSTR(SQLERRM,1,200);
end GET_ADAPTER_TOTAL_TIMEOUT;




/********  Procedure GET_UNIQUE_CHANNEL_NAME ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 17 1998
 *
 * INPUT: ne_name
 * OUTPUT: Unique Pipe Name
 *
 * For each type of NEM this returns a unique pipe name for the communication
 *
 * Usage: General Utility
 */

FUNCTION GET_UNIQUE_CHANNEL_NAME (Name in varchar2)

RETURN varchar2
IS
 l_PipeName   varchar2(50);
 l_Temp        varchar2(80);
 l_Seq         number;
 l_SeqLen     number;
 l_TruncLen   number;
begin
  l_temp := RTRIM(Name,' ');
  l_temp := LTRIM(l_temp);


  l_temp := REPLACE(l_Temp, ' ', '_');

   SELECT XDP_CHANNEL_S.NEXTVAL into l_Seq
   FROM dual;

   l_PipeName := to_char(l_Seq);

   l_SeqLen := LENGTH(l_PipeName);

   l_TruncLen := 30 - (l_SeqLen + 9);

   l_PipeName := SUBSTR(l_Temp, 1, l_TruncLen) || '_' || l_PipeName;



 RETURN l_PipeName;

end GET_UNIQUE_CHANNEL_NAME;



/********  Procedure LOG_COMMAND_AUDIT_TRAIL ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 17 1998
 *
 * INPUT: WIInstanceID, NE name, NE type, SW Generic, command sent,
 *        date sent, response, response date, procedure name
 * OUTPUT:  error_code, error string
 *
 * This procedure logs the sudit trail for each command sent to the NE
 *
 * Usage: In Send procedure at run time.
 */

Procedure LOG_COMMAND_AUDIT_TRAIL (FAInstanceID  in  number,
                                   FeName in  varchar2,
                                   FeType in  varchar2,
                                   SW_Generic in  varchar2,
                                   CommandSent in  varchar2,
                                   SentDate in  DATE,
                                   Response in  varchar2,
                                   RespDate in  DATE,
                                   ProcName in  varchar2,
                                   ErrCode OUT NOCOPY number,
                                   ErrStr OUT NOCOPY varchar2)
IS
 l_response_id      number;
 l_FeName          varchar2(80);
 l_FeType          varchar2(80);
 l_SW_Generic       varchar2(80);
 l_CommandSent     varchar2(32767);
 l_Response         varchar2(32767);
begin
  ErrCode := 0;
  ErrStr := null;


 IF FeName IS NULL then
    l_FeName := 'GOT NULL FE NAME';
 ELSE
    l_FeName := FeName;
 end IF;

 IF FeType IS NULL then
    l_FeType := 'GOT NULL FE TYPE';
 ELSE
    l_FeType := FeType;
 end IF;

 IF SW_Generic IS NULL then
    l_SW_Generic := 'GOT NULL SW_GENERIC';
 ELSE
    l_SW_Generic := SW_Generic;
 end IF;

 IF CommandSent IS NULL then
    l_CommandSent := 'GOT NULL Command to be sent';
 ELSE
    l_CommandSent := CommandSent;
 end IF;

 IF Response IS NULL then
    l_Response := 'GOT NULL Response from the NE';
 ELSE
    l_Response := Response;
 end IF;

 /*
  * Insert into the audit trail table.
  */

 INSERT INTO XDP_FE_CMD_AUD_TRAILS (
   fa_instance_id,
   fe_command_seq,
   fulfillment_element_name,
   fulfillment_element_type,
   sw_generic,
   command_sent,
   command_sent_date,
   response,
   response_date,
   provisioning_procedure)
  VALUES (
   FAInstanceID,
   XDP_FE_CMD_AUD_TRAILS_S.NEXTVAL,
   l_FeName,
   l_FeType,
   l_Sw_Generic,
   l_CommandSent,
   SentDate,
   SUBSTR(l_Response,1,3999),
   RespDate,
   ProcName);


exception
when others then
 ErrCode := SQLCODE;
 ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.LOG_COMMAND_AUDIT_TRAIL. Error: ' || SUBSTR(SQLERRM,1,200);
end LOG_COMMAND_AUDIT_TRAIL;



/********  Procedure SEND_ACK ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 19 1998
 *
 * INPUT: pipe_name, timeout
 * OUTPUT: Err_code, Error String
 *
 * This procedure sends 'ACK_NEM" message over the input pipe to the NEM
 *
 * Usage: Gereral Utility
 */

Procedure SEND_ACK (ChannelName  in  varchar2,
                    Timeout    in  number,
                    ErrCode   OUT NOCOPY number,
                    ErrStr    OUT NOCOPY varchar2)
IS
 e_PipeException   exception;
 l_ReturnCode     number;
begin
  ErrCode := 0;
  ErrStr := null;

 begin
   DBMS_PIPE.PACK_MESSAGE('ACK_SDP');
    l_ReturnCode :=  DBMS_PIPE.SEND_MESSAGE(ChannelName,Timeout);
 END;

     IF l_ReturnCode <> 0 then
        RAISE e_PipeException;
     end IF;

exception
when e_PipeException then
    ErrCode := -20101;
    ErrStr :=   'SFM -20101 Could NOT send ACK message to the NEM';
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.SEND_ACK. Error: ' || SUBSTR(SQLERRM,1,200);
end SEND_ACK;





/********  Procedure WAIT_FOR_MESSAGE ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 19 1998
 *
 * INPUT: pipe_name, timeout
 * OUTPUT: message, Err_code, Error String
 *
 * This procedure waits for a message over the pipe and returns the message
 *
 * Usage: Gereral Utility
 */

Procedure WAIT_FOR_MESSAGE (ChannelName  in  varchar2,
                            Timeout    in  number,
                            Message    OUT NOCOPY varchar2,
                            ErrCode   OUT NOCOPY number,
                            ErrStr    OUT NOCOPY varchar2)
IS
 e_PipeException   exception;
 e_InternalPipeException   exception;
 l_ReturnCode     number;
begin
  ErrCode := 0;
  ErrStr := null;

 /*
  * Wait till you receive a message
  */
   l_ReturnCode := DBMS_PIPE.RECEIVE_MESSAGE(ChannelName,Timeout);

 /*
  * Got timeout on RECEIVE_MESSAGE
  */

   IF l_ReturnCode = 1 then
      RAISE e_PipeException;
   ELSIF l_ReturnCode <> 0 then
     /* Internal Error */
      RAISE e_InternalPipeException;
   ELSE
      DBMS_PIPE.UNPACK_MESSAGE(Message);
   end IF;


exception
when e_PipeException then
  ErrCode := -20103;
  ErrStr := 'SFM-20103 Could not get Response from NEM on Pipe: ' || ChannelName || ' Timeout: ' || TIMEOUT;
when e_InternalPipeException then
  ErrCode := -20103;
  ErrStr := 'SFM-20103 Unknown error when waiting for response from NEM on Pipe: ' || ChannelName || ' Timeout: ' || TIMEOUT;
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.WAIT_FOR_MESSAGE. Error: ' || SUBSTR(SQLERRM,1,200);
end WAIT_FOR_MESSAGE;



/********  Procedure Send ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: workitem_instance_id, pipe name, procedure name, command string
 * OUTPUT: response, Err_code, Error String
 *
 * This is the procedure to which the user written SEND's are mapped to.
 * The procedure sends the users commands to the NEM through the input pipe name.
 * Before doing this it calls the find_replace_procedure procedure to get the
 * parameter value at runtime. hence needs the workitem_instance_id. It manages
 * the connection to the NEM
 *
 * Usage: In forms. This is the procedure the suers SEND's are mapped to.
 */

Procedure SEND (OrderID in number,
                LineItemID in number,
                WIInstanceID in number,
                FAInstanceID in number,
                ChannelName in  varchar2,
                FEName in varchar2,
                ProcName in  varchar2,
                Response OUT NOCOPY varchar2,
                sdp_internal_err_code OUT NOCOPY number,
                sdp_internal_err_str OUT NOCOPY varchar2,
                CmdStr in  varchar2,
                EncryptFlag in  varchar2,
                Prompt in  varchar2,
                ErrCode OUT NOCOPY number,
                ErrStr OUT NOCOPY varchar2)

 IS

-- PL/SQL Block

  l_ReturnCode            number;
  l_ReturnChannelName       varchar2(50);
  l_ApplChannelName       varchar2(50);
  l_Handshake              varchar2(20);
  l_ActualStr		    varchar2(32767);

  l_TempResponse          varchar2(32767);
  l_RespCount             number;
  l_Counter                number;

/*
 * Dec 15 1999
 * The Prompt value was 50 now making it 4000
 * Should we make it 32767?
 */

  l_PromptValue           varchar2(4000);


  l_LogFlag               number;
  l_LogCmd                varchar2(32767);
  l_LogResp               varchar2(32767);

  l_FeWarning             varchar2(32767);
  l_NeSessionLost             varchar2(32767);
  l_NeTimedOut             varchar2(32767);
  l_AdapterType varchar2(80);

  l_RespXML 		varchar2(32767);
  l_MoreFlag 		varchar2(10);
  l_Status 		varchar2(40);

  l_Templob	CLOB;
  x_progress varchar2(2000);
begin

  sdp_internal_err_code := 0;
  sdp_internal_err_str := null;

  ErrCode := 0;
  ErrStr := null;

  RESPONSE := ' ';

  IF EncryptFlag = 'Y' then
     l_LogResp := 'CANNOT Log NE Responses due to security reasons. Please use the Command Sent as the cross reference';
  ELSE
     null;
  end IF;


  /*
   * find and replace any parameters with their value
   */
  FIND_REPLACE_PARAMS(OrderID, LineItemID, WIInstanceID, FAInstanceID, CmdStr, l_ActualStr, l_LogFlag, l_LogCmd, ErrCode, ErrStr);
  IF ErrCode <> 0 then
     x_progress := 'In XDP_PROC_CTL.SEND.FIND_REPLACE_PARAMS: Error when trying to get the value of parameters in: ' ||   CmdStr || ' Error: ' || SUBSTR(ErrStr, 1, 1500);
     RAISE e_ParamValueException;
  end IF;

  l_PromptValue := PROMPT;
  IF Prompt IS NULL then
     l_PromptValue := 'IGNORE';
  end IF;


	l_ApplChannelName := XDP_ADAPTER_CORE_PIPE.ConstructChannelName
				(p_ChannelType => 'APPL',
				 p_ChannelName => ChannelName);

        l_ReturnChannelName := XDP_ADAPTER_CORE_PIPE.GetReturnChannelName
                                (p_ChannelName => l_ApplChannelName);

  begin
	DBMS_LOB.createtemporary(l_TempLob, TRUE);
	xdp_adapter.pv_AdapterExitCode := null;

	-- dbms_output.put_line('Sending: ' || substr(l_ActualStr, 1, 200));
	-- dbms_output.put_line('Prompt: ' ||  substr(l_PromptValue, 1, 200));

	XDP_ADAPTER_CORE.SendApplicationMessage(p_ChannelName => l_ApplChannelName,
						p_Command => l_ActualStr,
						p_Response => l_PromptValue);

	-- dbms_output.put_line('Waiting for response...');
	-- dbms_output.put_line('Timeout: ' || to_char(pv_MesgTimeout));
	XDP_ADAPTER_CORE.WaitForMessage(p_ChannelName => l_ReturnChannelName,
					p_Timeout => pv_MesgTimeout + 5,
					p_ResponseMessage => l_RespXML);

	l_Status := XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'STATUS',
							p_XMLMessage => l_RespXML);

	-- dbms_output.put_line('Status: ' || l_Status);

	-- dbms_output.put_line('Sending ACK');
	XDP_ADAPTER_CORE.SendAck(p_ChannelName => l_ApplChannelName);

	-- dbms_output.put_line('After Sending ACK');
	xdp_adapter.pv_AdapterExitCode := XDP_ADAPTER_CORE_XML.DecodeMessage
							(p_WhattoDecode => 'EXIT_CODE',
							 p_XMLMessage => l_RespXML);

	-- dbms_output.put_line('Exit Code: ' || xdp_adapter.pv_AdapterExitCode);
	if (l_Status = 'SUCCESS') then

		l_MoreFlag := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'MORE_FLAG',
                                                	p_XMLMessage => l_RespXML);

		-- dbms_output.put_line('More Flag : ' || l_MoreFlag);
		Response := XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'DATA',
								p_XMLMessage => l_RespXML);

		if Response is not null then
		-- dbms_output.put_line('After Reponse' || length(Response));
			dbms_lob.writeappend(l_TempLob, length(Response), Response);
		end if;
		-- dbms_output.put_line('After Logging..');

		while (l_MoreFlag is not null and l_MoreFlag = 'Y' ) loop

			-- dbms_output.put_line('Waiting for message(LOOP)');
			-- dbms_output.put_line('Timeout: ' || to_char(pv_MesgTimeout));
			XDP_ADAPTER_CORE.WaitForMessage(
					p_ChannelName => l_ReturnChannelName,
                                        p_Timeout => pv_MesgTimeout + 5,
                                        p_ResponseMessage => l_RespXML);

			l_Status := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'STATUS',
							p_XMLMessage => l_RespXML);
			-- dbms_output.put_line('Status: (LOOP) ' || l_Status);

			-- dbms_output.put_line('Sending ACK (LOOP)');
			XDP_ADAPTER_CORE.SendAck(p_ChannelName => l_ApplChannelName);
			-- dbms_output.put_line('After Sending ACK (LOOP)');

			xdp_adapter.pv_AdapterExitCode := XDP_ADAPTER_CORE_XML.DecodeMessage
							(p_WhattoDecode => 'EXIT_CODE',
							 p_XMLMessage => l_RespXML);

			-- dbms_output.put_line('Exit Code:(LOOP) ' || xdp_adapter.pv_AdapterExitCode);
			if (l_Status = 'SUCCESS' ) then

				l_MoreFlag := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'MORE_FLAG',
                                                        p_XMLMessage => l_RespXML);

				-- dbms_output.put_line('More Flag: (LOOP) ' || l_MoreFlag);
				l_TempResponse := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'DATA',
                                                       	p_XMLMessage => l_RespXML);

				if l_TempResponse is not null then
				-- dbms_output.put_line('After Reponse (LOOP)' || length(l_TempResponse));
					dbms_lob.writeappend(
						l_TempLob, length(l_TempResponse), l_TempResponse);
				end if;
				-- dbms_output.put_line('After Logging(LOOP)..');

				if length(Response) + length(l_TempResponse) <= 32767 then
					Response := Response || l_TempResponse;
				elsif length(Response) < 32766 then
					Response := Response || substr(
					l_TempResponse, 1, 32766 - length(Response) );
				end if;

			else
				ErrStr := XDP_ADAPTER_CORE_XML.DecodeMessage(
                                                        p_WhattoDecode => 'DATA',
                                                        p_XMLMessage => l_RespXML);
				exit;
			end if;
		end loop;

	else
		ErrStr := XDP_ADAPTER_CORE_XML.DecodeMessage(
						p_WhattoDecode => 'DATA',
						p_XMLMessage => l_RespXML);
	end if;
  exception
  when others then
	-- dbms_output.put_line('EXCEPTION: ' || SQLCODE);
	-- Log into the Audit trail the command the response
	-- Log the command send irrespective of any errors.
	LogAuditTrail(LogFlag => l_LogFlag,
                      FAInstanceID => FAInstanceID,
                      FEName => FEName,
                      FeType => pv_FeType,
                      SWGeneric => pv_SWGeneric,
                      LogCmd => l_LogCmd,
                      ActualStr => l_ActualStr,
                      Response => Response,
		      ResponseLong => l_TempLob,
                      LogResp => l_LogResp,
                      ProcName => ProcName);

	raise;

 end;

	if (l_Status <> 'SESSION_LOST') then

		-- dbms_output.put_line('Sending Sync..');
		XDP_ADAPTER_CORE.SendSync(p_ChannelName => l_ApplChannelName,
					  p_CleanupPipe => 'N');
		-- dbms_output.put_line('After Sending Sync..');

	END IF;

	-- Log the Response
	LogAuditTrail(LogFlag => l_LogFlag,
                      FAInstanceID => FAInstanceID,
                      FEName => FEName,
                      FeType => pv_FeType,
                      SWGeneric => pv_SWGeneric,
                      LogCmd => l_LogCmd,
                      ActualStr => l_ActualStr,
                      Response => Response,
		      ResponseLong => l_TempLob,
                      LogResp => l_LogResp,
                      ProcName => ProcName);

	if l_Status = 'SUCCESS' then
		null;
	elsif (l_Status = 'FAILURE') then
		x_Progress := HandleMessageErrors
				(xdp_adapter.pv_AdapterFailure,NULL, 'XDP_PROC_CTL.SEND', 'RESP',
				l_ReturnChannelName, pv_MesgTimeout, l_LogFlag,
				l_ActualStr, l_LogCmd, Response, EncryptFlag, ErrStr);
		RAISE e_NeFailureException;

	elsif (l_Status = 'TIMEOUT') then
		x_Progress := HandleMessageErrors
				(xdp_adapter.pv_AdapterTimeout,NULL, 'XDP_PROC_CTL.SEND', 'RESP',
				l_ReturnChannelName, pv_MesgTimeout, l_LogFlag,
				l_ActualStr, l_LogCmd, Response, EncryptFlag, ErrStr);
		RAISE e_NeTimedOutException;

	elsif (l_Status = 'WARNING') then
		x_Progress := HandleMessageErrors(
				xdp_adapter.pv_AdapterWarning, NULL, 'XDP_PROC_CTL.SEND', 'RESP',
				l_ReturnChannelName, pv_MesgTimeout, l_LogFlag,
				l_ActualStr, l_LogCmd, Response, EncryptFlag, ErrStr);
		RAISE e_NeWarningException;

	elsif (l_Status = 'SESSION_LOST') then
		x_Progress := HandleMessageErrors(
			       xdp_adapter.pv_AdapterSessionLost,NULL,'XDP_PROC_CTL.SEND','RESP',
				l_ReturnChannelName, pv_AckTimeout, l_LogFlag,
				l_ActualStr, l_LogCmd, Response, EncryptFlag, ErrStr);
		RAISE e_NeSessionLostException;

	else
		RAISE e_UnhandledException;
	end if;

	DBMS_LOB.freetemporary(l_TempLob);

exception
when e_ParamValueException then
  ErrCode := -20001;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20001, x_progress);

 when e_ProcExecException then
  ErrCode := -20021;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20021, x_progress);

when e_PipeSendAckException then
  ErrCode := -20101;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20101, x_progress);

when e_PipeWaitForAckException then
  ErrCode := -20102;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);
  RAISE_APPLICATION_ERROR(-20102, x_progress);

when e_PipeWaitForMesgException then
  ErrCode := -20103;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20103, x_progress);

when e_PipeSendMesgException then
  ErrCode := -20104;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20104, x_progress);

when e_PipePackMesgException then
  ErrCode := -20105;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20105, x_progress);

when e_PipeUnpackMesgException then
  ErrCode := -20106;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20106, x_progress);

when e_PipeOutOfSyncException then
  ErrCode := -20107;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20107, x_progress);

when e_NeFailureException then
  ErrCode := xdp_adapter.pv_AdapterFailure;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20300, x_progress);

when e_NeWarningException then
  ErrCode := xdp_adapter.pv_AdapterWarning;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

--  RAISE_APPLICATION_ERROR(-20500, x_progress);

when e_NeSessionLostException then
  ErrCode := xdp_adapter.pv_AdapterSessionLost;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

--Changed sacsharm 2/19/02 Use update API that is autonomous
--update XDP_ADAPTER_REG
--set adapter_status = 'SESSION_LOST',
--      LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
--     LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
--where channel_name = ChannelName;
XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
	p_ChannelName => ChannelName,
	p_Status => XDP_ADAPTER.pv_statusSessionLost);


when e_NeTimedOutException then
  ErrCode := xdp_adapter.pv_AdapterTimeout;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

when others then
  x_progress := 'In XDP_PROC_CTL.Send Got Unhandeled Exception while sending ' || l_ActualStr || 'Error:' || SUBSTR(SQLERRM,1,400);
  ErrCode := -20400;
  ErrStr := 'Unhandeled Exception in XDP_PROC_CTL.SEND. Error: ' || SUBSTR(x_progress,1,200);
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  DBMS_LOB.freetemporary(l_TempLob);

  RAISE_APPLICATION_ERROR(-20400,x_progress);
end SEND;






/********  Procedure Send ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: workitem_instance_id, pipe name, procedure name, command string
 * OUTPUT: response, Err_code, Error String
 *
 * This procedure is an overloaded send without the prompt
 *
 * Usage: In forms. This is the procedure the suers SEND's are mapped to.
 */
Procedure SEND (OrderID in number,
                LineItemID in number,
                WIInstanceID in number,
                FAInstanceID in number,
                ChannelName in  varchar2,
                FEName in varchar2,
                ProcName in  varchar2,
                Response OUT NOCOPY varchar2,
                sdp_internal_err_code OUT NOCOPY number,
                sdp_internal_err_str OUT NOCOPY varchar2,
                CmdStr in  varchar2,
                EncryptFlag in  varchar2,
                ErrCode OUT NOCOPY number,
                ErrStr OUT NOCOPY varchar2)

IS
begin
  ErrCode := 0;
  ErrStr := null;

    SEND(OrderID, LineItemID, WIInstanceID, FAInstanceID, ChannelName, FEName, ProcName, Response, sdp_internal_err_code, sdp_internal_err_str, CmdStr, EncryptFlag, 'IGNORE', ErrCode, ErrStr);

exception
when others then
  RAISE;
end SEND;



Procedure SEND_HTTP (OrderID in number,
                      LineItemID in number,
                      WIInstanceID in number,
                      FAInstanceID in number,
                      ChannelName in  varchar2,
                      FEName in varchar2,
                      ProcName in  varchar2,
                      Response OUT NOCOPY varchar2,
                      sdp_internal_err_code OUT NOCOPY number,
                      sdp_internal_err_str OUT NOCOPY varchar2,
                      CmdStr in  varchar2,
                      EncryptFlag in  varchar2,
                      ErrCode OUT NOCOPY number,
                      ErrStr OUT NOCOPY varchar2)
is

 l_LogFlag               number;
 l_ReminderLen number;

 l_ActualStr varchar2(32767);
 l_LogCmd varchar2(32767);


 l_Resp UTL_HTTP.HTML_PIECES;

 x_progress varchar2(2000);
begin

  Response := null;

  /*
   * find and replace any parameters with their value
   */
  FIND_REPLACE_PARAMS(OrderID, LineItemID, WIInstanceID, FAInstanceID, CmdStr, l_ActualStr, l_LogFlag, l_LogCmd, ErrCode, ErrStr);
  IF ErrCode <> 0 then
     x_progress := 'In XDP_PROC_CTL.SEND_HTTP.FIND_REPLACE_PARAMS: Error when trying to get the value of parameters in: ' ||   SUBSTR(CmdStr, 1, 600) || ' Error: ' || SUBSTR(ErrStr, 1, 600);
     RAISE e_ParamValueException;
  end IF;

  l_Resp :=  UTL_HTTP.Request_pieces(l_ActualStr);

  Response := l_Resp(1);

  for i in 2..l_Resp.count LOOP
   if LENGTH(Response) < 32767 then
      if (LENGTH(Response) + LENGTH(l_Resp(i))) < 32767 then
         Response := Response || l_Resp(i);
      else
         l_ReminderLen := 32767 - LENGTH(l_Resp(i));
         Response := Response || SUBSTR(l_Resp(i), 1, l_ReminderLen);
      end if;
   end if;
  END LOOP;

exception
when UTL_HTTP.request_failed then
 ErrCode := -20050;
 ErrStr := 'Request Failed';
 sdp_internal_err_code :=  ErrCode;
 sdp_internal_err_str := ErrStr;

when UTL_HTTP.init_failed then
 ErrCode := -20051;
 ErrStr := 'Initialization Failed';
 sdp_internal_err_code :=  ErrCode;
 sdp_internal_err_str := ErrStr;

when others then
 ErrCode := SQLCODE;
 ErrStr := SQLERRM;
 sdp_internal_err_code :=  ErrCode;
 sdp_internal_err_str := ErrStr;
 RAISE;
end SEND_HTTP;





/********  Procedure NOTIFY_ERROR ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 17 1998
 *
 * INPUT: 2 strings
 * OUTPUT: err_string
 *
 * This procedure takes 2 strings and checks if one is contained in the other
 *
 * Usage: In forms. The users NOTIFY_ERROR is modified to match this procedure's
 *        specs.
 */

Procedure NOTIFY_ERROR (ResponseStr  in  varchar2,
                        ErrCode      OUT NOCOPY number,
                        ErrStr       OUT NOCOPY varchar2,
                        UserStr      in  varchar2,
                        LogFlag      in  varchar2)
IS
begin
   ErrCode := '-666';
   IF LogFlag = 'R' then
     ErrStr := 'User Defined error. NE Response will not be logged because of security reasons (as per user' || '''s request). ' || UserStr;
   ELSE
     ErrStr := 'User Defined error: ' || UserStr || '
               ' || ResponseStr;
   end IF;
end NOTIFY_ERROR;




/********  FUNCTION RESPONSE_CONTAINS ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 12 1998
 *
 * INPUT: 2 strings
 * OUTPUT: Boolean
 *
 * This procedure takes 2 strings and checks if one is contained in the other
 *
 * Usage: In forms. The users RESPONSE_CONTAINS is mmodified to match this procedures
 *        specs.
 */

FUNCTION RESPONSE_CONTAINS (String1 in varchar2,
                            String2 in varchar2
)
RETURN BOOLEAN
IS
 l_dummy    number;

begin

 IF String1 = NULL OR String2 = NULL then
   RETURN TRUE;
 end IF;
 l_dummy := INSTR(String1, String2, 1, 1);

 IF l_dummy = 0 then
   RETURN FALSE;
 ELSE
   RETURN TRUE;
 end IF;
end RESPONSE_CONTAINS;



/********  FUNCTION GET_RESPONSE ***********/
/*
 * Author: V.Rajaram
 * Date Created: June 19 1998
 *
 * INPUT: inp Str
 * OUTPUT: same_str;
 *
 * This function returns in the input str!!
 *
 * Usage: In forms. The users Get_Response string is modified to match this function's
 *        specs.
 */

FUNCTION GET_RESPONSE ( ResponseStr in varchar2) RETURN varchar2
IS

begin
    RETURN ResponseStr;
end GET_RESPONSE;




/********  Procedure GET_PARAM_VALUE ***********/
/*
 * Author: V.Rajaram
 * Date Created: Sept 4 1998
 *
 * INPUT: Fulfillment worklist id, pipe name , param string
 * OUTPUT: parameter value
 *
 * This is another constructs provided to the user to get the value of the parameter
 *
 * Usage: In forms. The users GET_PARAM_VALUE is modified to match this procedure's
 *        specs.
 */


 FUNCTION GET_PARAM_VALUE (OrderID in  number,
                           LineItemID in number,
                           WIInstanceID in number,
                           FAInstanceID in number,
                           ParamName               in  varchar2
  ) RETURN varchar2
IS
 l_LogStr           varchar2(32767);
 l_LogFlag          number;
 l_ErrCode          number;
 l_ErrStr           varchar2(4000);

 l_ParamValue       varchar2(600);

 x_progress varchar2(2000);
begin
 FIND_REPLACE_PARAMS (OrderID,
                      LineItemID,
                      WIInstanceID,
                      FAinstanceID,
                      ParamName,
                      l_ParamValue,
                      l_LogFlag,
                      l_LogStr,
                      l_ErrCode,
                      l_ErrStr);

  if l_ErrCode <> 0 then
    RAISE e_ParamValueException;
  end if;

  return l_ParamValue;

exception
 when e_ProcExecException then
  RAISE_APPLICATION_ERROR(-20021, x_progress);

 when others then
  x_progress := 'In XDP_PROC_CTL.GET_PARAM_VALUE Got Unhandeled Exception while Trying to get value of parameter: ' || ParamName || 'Error:' || SUBSTR(SQLERRM,1,1000);
  RAISE_APPLICATION_ERROR(-20400,x_progress);
end GET_PARAM_VALUE;






-- OLD ONE WILL BE DEPRECATED SOON...
Procedure SEND_SYNC ( ChannelName     in  varchar2,
                      ErrCode      OUT NOCOPY number,
                      ErrStr       OUT NOCOPY varchar2)
IS
 l_Handshake        varchar2(80);
 l_Counter          number;
 l_ReturnCode      number;
 l_ReturnChannelName varchar2(80);


 x_progress varchar2(2000);
begin
  ErrCode := 0;
  ErrStr := null;

  l_counter := 1;

 l_ReturnChannelName := ChannelName || '_R_PIPE';


/* Clean up the pipes */
 begin
      DBMS_PIPE.PURGE(ChannelName);
 exception
 when others then
    RAISE e_PipeOutOfSyncException;
 END;


 begin
      DBMS_PIPE.PURGE(l_ReturnChannelName);
 exception
 when others then
    RAISE e_PipeOutOfSyncException;
 END;


   begin
    DBMS_PIPE.PACK_MESSAGE('SYNC');
    DBMS_PIPE.PACK_MESSAGE(l_ReturnChannelName);
       l_ReturnCode := DBMS_PIPE.SEND_MESSAGE(ChannelName);
   exception
   when others then
     x_Progress := HandlePipeErrors(SQLCODE, 'PACK', 'XDP_PROC_CTL.SEND_SYNC',  NULL, 'SYNC', SQLERRM);
     RAISE e_PipePackMesgException;
   END;

   IF l_ReturnCode <> 0 then
      x_progress := 'Could not send message to pipe. Command to be sent: SYNC';
      RAISE e_PipeSendMesgException;
   end IF;

   l_Handshake := 'JUNK';

   WHILE (l_handshake <> 'ACK_SYNC') LOOP
       WAIT_FOR_MESSAGE(l_ReturnChannelName, pv_MesgTimeout, l_Handshake, ErrCode, ErrStr);
       IF ErrCode <> 0 then
	x_Progress := HandleMessageErrors(-20103, NULL, 'XDP_PROC_CTL.SEND_SYNC', 'SYNC',
                                          l_ReturnChannelName, pv_MesgTimeout, 0,
                                          'SYNC', 'SYNC', NULL, 'N', ErrStr);
          RAISE e_PipeWaitForMesgException;
       end IF;
   end LOOP;


 /* Raja: 09/01/1999
    Added to reset the Dirty Bit to be FALSE so that each new SEND will get the latest NE Command Timeout
 */
    pv_DirtyBit := FALSE;


exception
 when e_ProcExecException then
  ErrCode := -20021;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20021, x_progress);
when e_PipeSendAckException then
  ErrCode := -20101;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20101, x_progress);
when e_PipeWaitForMesgException then
  ErrCode := -20103;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20103, x_progress);
when e_PipeSendMesgException then
  ErrCode := -20104;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20104, x_progress);
when e_PipePackMesgException then
  ErrCode := -20105;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20105, x_progress);
when e_PipeUnpackMesgException then
  ErrCode := -20106;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20106, x_progress);
when e_PipeOutOfSyncException then
  ErrCode := -20107;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20107, x_progress);
when others then
  x_Progress := HandleMessageErrors(SQLCODE, NULL, 'XDP_PROC_CTL.SEND_SYNC', 'SYNC',
                                          ChannelName, pv_MesgTimeout, 0,
                                          'SYNC', 'SYNC', NULL, 'N', SQLERRM);
  ErrCode := SQLCODE;
  RAISE_APPLICATION_ERROR(-20021, x_progress);
end SEND_SYNC;


/********  Procedure SEND_SYNC ***********/
/*
 * Author: V.Rajaram
 * Date Created: August 11 1998
 *
 * INPUT: workitem_instance_id, Pipename (send), pipename (return)
 * OUTPUT: Err_code, Error String
 *
 * This is the procedure is executed if every time before the provisionnog procedure
 * is executed.
 *
 * Usage: Before the users writtes send function.
 */

Procedure SEND_SYNC ( ChannelName     in  varchar2,
		      FeName in varchar2,
                      ErrCode      OUT NOCOPY number,
                      ErrStr       OUT NOCOPY varchar2)
IS
 l_Handshake        varchar2(80);
 l_Counter          number;
 l_ReturnCode      number;
 l_ReturnChannelName varchar2(80);
 l_ApplChannelName varchar2(80);


 x_progress varchar2(2000);
begin
  ErrCode := 0;
  ErrStr := null;

	xdp_adapter.pv_AdapterExitCode := null;

	l_ApplChannelName := XDP_ADAPTER_CORE_PIPE.ConstructChannelName
				(p_ChannelType => 'APPL',
				 p_ChannelName => ChannelName);

        l_ReturnChannelName := XDP_ADAPTER_CORE_PIPE.GetReturnChannelName
                                (p_ChannelName => l_ApplChannelName);

	XDP_ADAPTER_CORE_PIPE.CleanupPipe(p_ChannelName => l_ApplChannelName,
					  p_CleanReturn => 'Y');

	XDP_ADAPTER_CORE.SendSync(p_ChannelName => l_ApplChannelName);

	XDP_ENGINE.GET_FE_CONFIGINFO (	FEName,
					pv_FeID,
                                   	pv_FeTypeID,
                                   	pv_FeType,
                                   	pv_SwGeneric,
                                   	pv_AdapterType);

     GET_ADAPTER_TOTAL_TIMEOUT (pv_FeID, pv_MesgTimeout, ErrCode, ErrStr);
     if ErrCode <> 0 then
        RAISE e_ParamValueException;
     end if;

/************************ OLD CODE - COMMENTEDOUT TILL THE END *********************/
/*
  l_counter := 1;

 l_ReturnChannelName := ChannelName || '_R_PIPE';


-- Clean up the pipes
 begin
      DBMS_PIPE.PURGE(ChannelName);
 exception
 when others then
    RAISE e_PipeOutOfSyncException;
 END;


 begin
      DBMS_PIPE.PURGE(l_ReturnChannelName);
 exception
 when others then
    RAISE e_PipeOutOfSyncException;
 END;


   begin
    DBMS_PIPE.PACK_MESSAGE('SYNC');
    DBMS_PIPE.PACK_MESSAGE(l_ReturnChannelName);
       l_ReturnCode := DBMS_PIPE.SEND_MESSAGE(ChannelName);
   exception
   when others then
     x_Progress := HandlePipeErrors(SQLCODE, 'PACK', 'XDP_PROC_CTL.SEND_SYNC',  NULL, 'SYNC', SQLERRM);
     RAISE e_PipePackMesgException;
   END;

   IF l_ReturnCode <> 0 then
      x_progress := 'Could not send message to pipe. Command to be sent: SYNC';
      RAISE e_PipeSendMesgException;
   end IF;

   l_Handshake := 'JUNK';

   WHILE (l_handshake <> 'ACK_SYNC') LOOP
       WAIT_FOR_MESSAGE(l_ReturnChannelName, pv_MesgTimeout, l_Handshake, ErrCode, ErrStr);
       IF ErrCode <> 0 then
	x_Progress := HandleMessageErrors(-20103, NULL, 'XDP_PROC_CTL.SEND_SYNC', 'SYNC',
                                          l_ReturnChannelName, pv_MesgTimeout, 0,
                                          'SYNC', 'SYNC', NULL, 'N', ErrStr);
          RAISE e_PipeWaitForMesgException;
       end IF;
   end LOOP;


--  Raja: 09/01/1999
--    Added to reset the Dirty Bit to be FALSE so that each new SEND will get the latest NE Command Timeout
    pv_DirtyBit := FALSE;
*/

/************************ END OF OLD CODE - COMMENTEDOUT *********************/
exception
 when e_ProcExecException then
  ErrCode := -20021;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20021, x_progress);
when e_PipeSendAckException then
  ErrCode := -20101;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20101, x_progress);
when e_PipeWaitForMesgException then
  ErrCode := -20103;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20103, x_progress);
when e_PipeSendMesgException then
  ErrCode := -20104;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20104, x_progress);
when e_PipePackMesgException then
  ErrCode := -20105;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20105, x_progress);
when e_PipeUnpackMesgException then
  ErrCode := -20106;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20106, x_progress);
when e_PipeOutOfSyncException then
  ErrCode := -20107;
  ErrStr := x_progress;
  RAISE_APPLICATION_ERROR(-20107, x_progress);
when others then
  x_Progress := HandleMessageErrors(SQLCODE, NULL, 'XDP_PROC_CTL.SEND_SYNC', 'SYNC',
                                          ChannelName, pv_MesgTimeout, 0,
                                          'SYNC', 'SYNC', NULL, 'N', SQLERRM);
  ErrCode := SQLCODE;
  RAISE_APPLICATION_ERROR(-20021, x_progress);
end SEND_SYNC;






/***************************************************
** These Set of Procedures/Functions are for CONNECT/DISCONNECT PROCEDURE
** GENERATION, EXECUTION etc
***************************************************/


/********  PROCEDURE CHECK_CONNECT_PARAM_NAME ***********/
/*
 * Author: V.Rajaram
 * Date Created: July 27 1998
 *
 * INPUT: NE type ID, Parameter Name
 * OUTPUT: Error Code, Error String
 *
 * This procedure takes an SFM CONNECT Parameter name as input and checks if they have been
 * defined for that NE Type ID
 *
 * Usage: In the FIND_REPLACE_CONNECT_PARAMS procedure
 */

PROCEDURE CHECK_CONNECT_PARAM_NAME (FeTypeID    in  number,
                                    Param        in  varchar2,
                                    ErrCode     OUT NOCOPY number,
                                    ErrStr      OUT NOCOPY varchar2)
 IS
  l_ParamCount       number;

begin

  ErrCode := 0;
  ErrStr := NULL;

  l_ParamCount := 0;

  /*
  * Check if the parameter is configured for the specified NE type ID in the
  * FE_ATTRIBUTE_DEF table
  * If not there return an error message
  */

  begin
    select 1 into l_ParamCount from dual
     where exists (
          select FE_ATTRIBUTE_ID
          from XDP_FE_ATTRIBUTE_DEF xad, XDP_FE_SW_GEN_LOOKUP xfl
          where xad.FE_ATTRIBUTE_NAME = Param
            and xad.FE_SW_GEN_LOOKUP_ID = xfl.FE_SW_GEN_LOOKUP_ID
            and xfl.FETYPE_ID = FeTypeID);

    l_ParamCount := 1;
  exception
  when no_data_found then
    l_ParamCount := 0;
  when others then
    RAISE;
  end;

  IF l_ParamCount = 0 THEN
    ErrCode := -1;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', Param);
    ErrStr := FND_MESSAGE.GET;
    RETURN;
 end IF;

exception
when others then
  ErrCode := SQLCODE;
  ErrStr := 'Unhandled Exception in XDP_PROC_CTL.CHECK_CONNECT_PARAM_NAME. Error: ' || SUBSTR(SQLERRM,1,200);
end CHECK_CONNECT_PARAM_NAME;








/********  PROCEDURE FIND_CONNECT_PARAMS ***********/
/*
 * Author: V.Rajaram
 * Date Created: July 27 1998
 *
 * INPUT: NE Type, Input String
 * OUTPUT: Err_code, Error String
 *
 * This procedure takes a long string as input and checks for any SFM parameters.
 * The parameters are identified by $... The delimiters are " ", ":", ";", ",", "'"
 * When found it checks if such a parameter has been defined for the service, version,
 * action. This is done by Sdp_Check_Connect_Param_Name procedure.
 *
 * Usage: In forms. When the user tries to saves his connection procedure.
 */

PROCEDURE FIND_CONNECT_PARAMETERS (FeTypeID in  number,
                                   ConnectStr in  varchar2,
                                   ErrCode OUT NOCOPY varchar2,
                                   ErrStr OUT NOCOPY varchar2)

 IS
TYPE DELIM_POS IS TABLE OF number INDEX BY BINARY_INTEGER;

  e_check_param_exception  exception;
  l_param_w_dollar        varchar2(50);
  l_param_wo_dollar       varchar2(50);
  l_param_wo_old          varchar2(50);
  l_save_str              varchar2(32700);
  i                        number;
  j                        number;
  l_str_len               number;
  l_dollar_found          number;
  l_syntax_error          number;
  l_done                  number;
  l_delim                 DELIM_POS;
  l_mark                  number;
  l_counter               number;

begin
  ErrCode := 0;
  ErrStr := NULL;

    l_save_str := ConnectStr;
    l_done := 0;

    WHILE l_done <> 1 LOOP
    	 l_str_len := LENGTH(l_save_str);
    /* Check for "$" character. Indicates an SFM variable */
  	 i := INSTR(l_save_str,'$',1,1);

  	  IF i = 0 THEN
	    /* No Variable found return the same string */
	      ErrCode := 0;
	      ErrStr := NULL;
	      l_done := 1;
	      RETURN;
	  ELSE
	    /* A variable found */
	      l_dollar_found := 1;
	  end IF;
	  /*
         * If the $ is the last letter then there is a syntax error
         */
	  IF i = l_str_len THEN
	       l_syntax_error := 1;
	       ErrCode := -1;
	       ErrStr := 'Syntax Error in ' || ConnectStr || '$ found but no variable specified';
	       RETURN;
	  end IF;
	  l_save_str := SUBSTR(l_save_str,i,l_str_len);
        /*
         * Find all the possible delimiters to get the variable name
         */
	  l_delim(1) := INSTR(l_save_str,',',1,1);
	  l_delim(2) := INSTR(l_save_str,':',1,1);
   	  l_delim(3) := INSTR(l_save_str,';',1,1);
	  l_delim(4) := INSTR(l_save_str,' ',1,1);
	  l_delim(5) := INSTR(l_save_str,'''',1,1);
	  l_delim(6) := INSTR(l_save_str,'"',1,1);

	  l_mark := -1;
	  j := -1;
        /*
         * Find the closest de-limiter from the $ sign
        */
	  FOR l_counter in 1..6 LOOP
        	IF l_delim(l_counter) > 0 and j < 0 THEN
            	j := l_delim(l_counter);
                  l_mark := l_counter;
        	ELSIF l_delim(l_counter) > 0 and l_delim(l_counter) < j THEN
            	j := l_delim(l_counter);
                  l_mark := l_counter;
       	end IF;
	  end LOOP;
        /*
         * Get the parameter
         */
        IF j > 0 THEN
            l_param_w_dollar := SUBSTR(l_save_str,1,j-1);
            l_save_str := SUBSTR(l_save_str,j,l_str_len);
        ELSIF j = -1 THEN
            l_param_w_dollar := l_save_str;
            l_save_str := ' ';
        end IF;
	  l_param_wo_dollar := SUBSTR(l_param_w_dollar,2,LENGTH(l_param_w_dollar));

         /*
          * Check if the parameter got is a valid parameter for the
          * NE Type
          */
          CHECK_CONNECT_PARAM_NAME(FeTypeID, l_param_wo_dollar, ErrCode, ErrStr);
	  IF ErrCode < 0 OR ErrCode = 100 THEN
              RAISE e_check_param_exception;
	  end IF;
    end LOOP;
exception
  WHEN e_check_param_exception THEN
     null;
  when others then
    ErrCode := SQLCODE;
    ErrStr := 'Unhandled Exception in XDP_PROC_CTL.FIND_CONNECT_PARAMETERS. Error: ' || SUBSTR(SQLERRM,1,200);
end FIND_CONNECT_PARAMETERS;


/********  PROCEDURE FIND_REPLACE_CONNECT_PARAMS ***********/
/*
 * Author: V.Rajaram
 * Date Created: July 27 1998
 *
 * INPUT: NE Type ID, NE ID, Input String (command), S/W Generic
 * OUTPUT: Command str (with parameters replaced with values) Err_code, Error String
 *
 * This procedure is executed at run time by the Send function to get the values of
 * of the parameters. It takes a long string as input and checks for any SFM parameters.
 * The parameters are identified by $... The delimiters are " ", ":", ";", ",", "'"
 * When found it gets the value using Get_Connect_Param_Value procedure.
 *
 * Usage: At runtime in the Send procedure for NE connection
 */

PROCEDURE FIND_REPLACE_CONNECT_PARAMS (FeName in varchar2,
                                       ConnectStr           in  varchar2,
                                       ActualStr           OUT NOCOPY varchar2,
                                       ErrCode      OUT NOCOPY varchar2,
                                       ErrStr       OUT NOCOPY varchar2)

 IS
-- Datastructure Definitions

TYPE DELIM_POS IS TABLE OF number INDEX BY BINARY_INTEGER;

-- PL/SQL Block
  e_ParamValueException    exception;
  l_param_w_dollar          varchar2(50);
  l_param_wo_dollar         varchar2(50);
  l_param_wo_old            varchar2(50);
  l_save_str                varchar2(900);
  i                          number;
  j                          number;
  l_str_len                 number;
  l_dollar_found            number;
  l_syntax_error            number;
  l_done                    number;
  l_delim                   DELIM_POS;
  l_mark                    number;
  l_counter                 number;
  l_param_value             varchar2(4000);

begin
  ErrCode := 0;
  ErrStr := NULL;

    l_save_str := ConnectStr;
    l_done := 0;
    WHILE l_done <> 1 LOOP
    	 l_str_len := LENGTH(l_save_str);
       /*
        * Check for the character "$". It identifies an SFM parameter
        */
  	 i := INSTR(l_save_str,'$',1,1);
  	  IF i = 0 THEN
	    /* No Variable found return the same string */
	      ErrCode := 0;
	      ErrStr := NULL;
	      l_done := 1;
              if l_save_str = ' ' then
                exit;
              else
                ActualStr :=   ActualStr || l_save_str;
                exit;
              end if;
	  ELSE
	    /* A variable found */
	      l_dollar_found := 1;
          /* Save the string to the left of the "$" sign in   ActualStr */
              ActualStr :=   ActualStr || SUBSTR(l_save_str,1,i-1);
	  end IF;
	  /*
         * If the $ is the last letter syntax error
         */
	  IF i = l_str_len THEN
	       l_syntax_error := 1;
	       ErrCode := -1;
	       ErrStr := 'Syntax Error in ' || ConnectStr || ' No variable found';
	       RETURN;
	  end IF;
	  l_save_str := SUBSTR(l_save_str,i,l_str_len);
        /*
         * Find all the possible delimiters to get the variable name
         */
	  l_delim(1) := INSTR(l_save_str,',',1,1);
	  l_delim(2) := INSTR(l_save_str,':',1,1);
   	  l_delim(3) := INSTR(l_save_str,';',1,1);
	  l_delim(4) := INSTR(l_save_str,' ',1,1);
	  l_delim(5) := INSTR(l_save_str,'''',1,1);
	  l_mark := -1;
	  j := -1;
        /*
         * Find the closest de-limiter from the $ sign
         */
	  FOR l_counter in 1..5 LOOP
            IF l_delim(l_counter) > 0 and j < 0 THEN
              j := l_delim(l_counter);
              l_mark := l_counter;
            ELSIF l_delim(l_counter) > 0 and l_delim(l_counter) < j THEN
              j := l_delim(l_counter);
              l_mark := l_counter;
            end IF;
          end LOOP;
        /*
         * Get the parameter
         */
         IF j > 0 THEN
            l_param_w_dollar := SUBSTR(l_save_str,1,j-1);
            l_save_str := SUBSTR(l_save_str,j,l_str_len);
         ELSIF j = -1 THEN
            l_param_w_dollar := l_save_str;
            l_save_str := ' ';
         end IF;

	  l_param_wo_dollar := SUBSTR(l_param_w_dollar,2,LENGTH(l_param_w_dollar));

        /*
         * Get the Connect parameter value at run time
         */
         l_param_value := XDP_ENGINE.Get_FE_ATTRIBUTEVAL(FeName, l_param_wo_dollar);
	  IF ErrCode < 0 OR ErrCode = 100 THEN
            RAISE e_ParamValueException;
              ActualStr := ConnectStr;
	  end IF;

        /*
         * Replace parameter with its value
         */
          ActualStr :=   ActualStr || l_param_value;
    end LOOP;

  ErrCode := 0;
  ErrStr := NULL;

exception
  WHEN e_ParamValueException THEN
    null;
  when others then
    ErrCode := SQLCODE;
    ErrStr := 'Unhandled Exception in XDP_PROC_CTL.FIND_REPLACE_CONNECT_PARAMS. Error: ' || SUBSTR(SQLERRM,1,200);
end FIND_REPLACE_CONNECT_PARAMS;


PROCEDURE GET_FE_PREFERENCES (FeName        in  varchar2,
                               CmdTimeout    OUT NOCOPY number,
                               CmdRetryCount  OUT NOCOPY number,
                               CmdWait       OUT NOCOPY number,
                               NoActTimeout OUT NOCOPY number,
                               DummyCmd      OUT NOCOPY varchar2,
                               ConnectRetryCount OUT NOCOPY number,
                               ConnectRetryWait OUT NOCOPY number,
                               ErrCode       OUT NOCOPY number,
                               ErrStr        OUT NOCOPY varchar2)
IS
 l_FeValue varchar2(40);
begin
  ErrCode := 0;
  ErrStr := NULL;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeCmdTimeout);
    if l_FeValue is null then
       CmdTimeout := 120;
    else
       CmdTimeout := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    CmdTimeout := 120;
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeRetryCount);
    if l_FeValue is null then
       CmdRetryCount := 0;
    else
       CmdRetryCount := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    CmdRetryCount := 0;
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeCmdRetryWait);
    if l_FeValue is null then
       CmdWait := 0;
    else
       CmdWait := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    CmdWait := 0;
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeNoActTimeout);
    if l_FeValue is null then
       NoActTimeout := 0;
    else
       NoActTimeout := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    NoActTimeout := 0;
  when others then
    RAISE e_ParamValueException;
  end;


  begin
    DummyCmd := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeCmdKeepAlive);
    if DummyCmd is null then
       DummyCmd := ' ';
    end if;
  exception
  when no_data_found then
    DummyCmd := ' ';
  when others then
    RAISE e_ParamValueException;
  end;

  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeConnRetryCount);
    if l_FeValue is null then
       ConnectRetryCount := 0;
    else
       ConnectRetryCount := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    ConnectRetryCount := 0;
  when others then
    RAISE e_ParamValueException;
  end;


  begin
    l_FeValue := XDP_ENGINE.Get_FE_AttributeVal(FeName, pv_attrFeConnRetryWait);
    if l_FeValue is null then
       ConnectRetryWait := 0;
    else
       ConnectRetryWait := to_number(l_FeValue);
    end if;
  exception
  when no_data_found then
    ConnectRetryWait := 0;
  when others then
    RAISE e_ParamValueException;
  end;
exception
WHEN e_ParamValueException THEN
 ErrCode := SQLCODE;
 ErrStr := 'Error when getting NE preferences. Error: ' || SUBSTR(SQLERRM,1,500);
when others then
 ErrCode := SQLCODE;
 ErrStr := 'Unhandled Exception in XDP_PROC_CTL.GET_NE_PREFERENCES. Error: ' || SUBSTR(SQLERRM,1,200);
end GET_FE_PREFERENCES;



PROCEDURE SEND_CONNECT (FeName      in  varchar2,
                ChannelName in  varchar2,
                ProcName    in  varchar2,
                Response     OUT NOCOPY varchar2,
                sdp_internal_err_code OUT NOCOPY number,
                sdp_internal_err_str OUT NOCOPY varchar2,
                CmdStr      in  varchar2,
                Prompt       in  varchar2 ,
                ErrCode OUT NOCOPY number,
                ErrStr OUT NOCOPY varchar2)

 IS

-- PL/SQL Block

  l_actual_str		    varchar2(32767);

  l_prompt                 varchar2(32767);
  l_prompt_value           varchar2(32767);

  x_progress varchar2(2000);
begin
  ErrCode := 0;
  ErrStr := NULL;

   Response := ' ';

  /*
   * find and replace any connect parameters with their value
   */
  FIND_REPLACE_CONNECT_PARAMS(FeName, CmdStr, l_actual_str, ErrCode, ErrStr);
  IF ErrCode < 0 OR ErrCode = 100 THEN
     x_progress := 'In XDP_PROC_CTL.SEND.FIND_REPLACE_CONNECT_PARAMS: Error when trying to get the value of parameters in: ' || SUBSTR(CmdStr, 1, 600) || ' Error: ' || SUBSTR(ErrStr,1,600);
     RAISE e_ParamValueException;
  end IF;

  /*
   * Same deal with the prompt
   */

  l_prompt := PROMPT;
  l_prompt_value := l_prompt;

  /*
   * The Prompt itself can be a parameter. Check for the value of the prompt
   */

  if l_prompt <> 'IGNORE' THEN
    FIND_REPLACE_CONNECT_PARAMS(FeName, l_prompt, l_prompt_value, ErrCode, ErrStr);
    IF ErrCode < 0 OR ErrCode = 100 THEN
      x_progress := 'In XDP_PROC_CTL.SEND.FIND_REPLACE_CONNECT_PARAMS: Error when trying to get the value of prompt: ' || SUBSTR(l_prompt, 1, 600) || ' Error: ' || SUBSTR(ErrStr,1,600);
      RAISE e_ParamValueException;
    end IF;
  end IF;


 /*
  * Trim the trailing spaces in the commands and the prompt to be sent
  */
  IF LENGTH(RTRIM(l_actual_str, ' ')) > 0 THEN
     l_actual_str := RTRIM(l_actual_str, ' ');
  end IF;

  IF LENGTH(RTRIM(l_prompt_value, ' ')) > 0 THEN
     l_prompt_value := RTRIM(l_prompt_value, ' ');
  end IF;


  AppendConnectCommands(l_actual_str, l_prompt_value);

exception
when others then
  x_progress := 'Unhandeled Exception in XDP_PROC_CTL.Send while sending ' || l_actual_str || 'Error:' || SUBSTR(SQLERRM,1,400);
  ErrCode := -20400;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  RAISE_APPLICATION_ERROR(-20400,x_progress);
end SEND_CONNECT;



PROCEDURE SEND_CONNECT (FeName      in  varchar2,
                 ChannelName in  varchar2,
                 ProcName    in  varchar2,
                 Response     OUT NOCOPY varchar2,
                 sdp_internal_err_code OUT NOCOPY number,
                 sdp_internal_err_str OUT NOCOPY varchar2,
                 CmdStr      in  varchar2,
                 ErrCode OUT NOCOPY number,
                 ErrStr OUT NOCOPY varchar2)

  IS
 x_progress varchar2(2000);
begin
    SEND_CONNECT(FeName, ChannelName, ProcName, Response, sdp_internal_err_code, sdp_internal_err_str, CmdStr, 'IGNORE', ErrCode, ErrStr);

  exception
  when others then
  x_progress := 'Unhandeled Exception in XDP_PROC_CTL.Send while sending ' || CmdStr || 'Error:' || SUBSTR(SQLERRM,1,400);
  ErrCode := -20400;
  ErrStr := x_progress;
  sdp_internal_err_code := ErrCode;
  sdp_internal_err_str := ErrStr;
  RAISE_APPLICATION_ERROR(-20400,x_progress);
end SEND_CONNECT;




/********  PROCEDURE GENERATE_CONNECT_PROC ***********/
/*
 * Author: V.Rajaram
 * Date Created: July 27 1998
 *
 * INPUT: Procedure Name, Input String (user written procedure)
 * OUTPUT: Err_code, Error String
 *
 * This procedure takes the user written connect procedure string and the procedure name
 * as input and generates the connect actual procedure.
 * It also generates any syntax errors in the actual PL/SQL block written by the user.
 *
 * Usage: In forms. After the sdp_find_connect_parameters procedure went successfully.
 */

 PROCEDURE GENERATE_CONNECT_PROC (ProcName   in  varchar2,
                                  ProcBody in  varchar2,
                                  CompiledProc OUT NOCOPY varchar2,
                                  ErrCode OUT NOCOPY number,
                                  ErrStr OUT NOCOPY varchar2)
 IS
-- PL/SQL Block
l_dummy                     number;

l_temp_str                  varchar2(32767);

l_count                     number;
l_cnt                       number;
l_done                      number;
l_start                     number;

l_final_str                 varchar2(32767);
l_replace_send_str          varchar2(500);
l_replace_connect_str       varchar2(500);
l_end_str                   varchar2(500);
l_sync_str                  varchar2(500);

l_str_before_end            varchar2(32767);
l_str_after_end             varchar2(4000);
l_end_loc                   number;

l_str_before_send            varchar2(32767);
l_str_after_send             varchar2(32767);
l_send_loc                   number;

l_str_before_lastsend            varchar2(32767);
l_str_after_lastsend             varchar2(32767);
l_lastsend_loc                   number;

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
  ErrCode := 0;
  ErrStr := NULL;

 l_temp_str := ProcBody;

 /*
  * Replace user written SEND, LOGIN to comply with the actual spec of those procedures
  * Remove the user written DECLARE as we will be generating the procedure on the fly
  */
 l_replace_connect_str := 'XDP_PROC_CTL.SEND_CONNECT(Fe_Name, ' || g_new_line ||
						   ' Channel_Name, ' || g_new_line ||
						   '''' || ProcName ||''', '|| g_new_line ||
						   ' sdp_internal_response, '||g_new_line ||
						   ' sdp_internal_err_code, '||g_new_line||
						   ' sdp_internal_err_str, ';

 l_replace_send_str := 'XDP_PROC_CTL.SEND_CONNECT(Fe_Name, ' || g_new_line ||
						' Channel_Name, ' || g_new_line ||
						'''' || ProcName ||''', ' ||g_new_line ||
						' sdp_internal_response, ' || g_new_line ||
						' sdp_internal_err_code, ' || g_new_line ||
						' sdp_internal_err_str, ';

 l_sync_str := 'XDP_PROC_CTL.RESET_BUFFER; ' || g_new_line;


 /*
  * Replace the strings here...
  */

 l_temp_str := REPLACE(l_temp_str, 'SEND(', l_replace_send_str);
 l_temp_str := REPLACE(l_temp_str, 'LOGIN(', l_replace_connect_str);

/*
  * Need to find the DECLARE word location and delete the users declare string (can be case sensitive)
  */

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 THEN
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;


 /*
  * Construct the procedure
  */
  if fnd_profile.defined('XDP_FP_SPEC') then
     fnd_profile.get('XDP_FP_SPEC', l_final_str);
     l_final_str := ' Procedure ' || ProcName  || ' ( '|| g_new_line || l_final_str || ' ) ' || g_new_line ||
                    'IS ' || g_new_line ||
                    ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';
  else

     l_final_str := ' Procedure ' || ProcName  || ' ( ' || g_new_line ||
      ' Fe_Name      in varchar2, ' || g_new_line ||
      ' Channel_Name in varchar2, ' || g_new_line ||
      ' sdp_internal_err_code out number, ' || g_new_line ||
      ' sdp_internal_err_str out varchar2 ' || ' ) ' || g_new_line ||
      'IS ' || g_new_line ||
     ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';

  end if;

 l_final_str := l_final_str || l_temp_str;

 /*
  * Find the first users's Send string and insert the RESET_BUFFER procedure call before the
  * first call to send.
  */
 l_send_loc := INSTR(UPPER(l_final_str), 'XDP_PROC_CTL.SEND_CONNECT(', 1, 1);

 IF l_send_loc <> 0 THEN
    l_str_before_send := SUBSTR(l_final_str, 1, l_send_loc -1);
    l_str_after_send := SUBSTR(l_final_str, l_send_loc, LENGTH(l_final_str));

    l_final_str := l_str_before_send || l_sync_str || l_str_after_send;
 end IF;


  CompiledProc := l_final_str;

  ErrCode := 0;
  ErrStr := 'Successfully generated the stored procedure ' || ProcName;
exception
  when others then
     ErrCode := SQLCODE;
     ErrStr := 'Unhandled Exception in XDP_PROC_CTL.GENERATE_CONNECT_PROC. Error: ' || SUBSTR(SQLERRM,1,200);
end GENERATE_CONNECT_PROC;




/********  PROCEDURE GENERATE_DISCONNECT_PROC ***********/
/*
 * Author: V.Rajaram
 * Date Created: July 27 1998
 *
 * INPUT: Procedure Name, Input String (user written procedure)
 * OUTPUT: Err_code, Error String
 *
 * This procedure takes the user written disconnect procedure string and the procedure name
 * as input and generates the disconnect actual procedure.
 * It also generates any syntax errors in the actual PL/SQL block written by the user.
 *
 * Usage: In forms. After the sdp_find_connect_parameters procedure went successfully.
 */

 PROCEDURE GENERATE_DISCONNECT_PROC (ProcName   in  varchar2,
                                     ProcBody         in  varchar2,
                                     CompiledProc OUT NOCOPY varchar2,
                                     ErrCode    OUT NOCOPY number,
                                     ErrStr     OUT NOCOPY varchar2)

 IS
-- PL/SQL Block
l_dummy                     number;

l_temp_str                  varchar2(32767);

l_count                     number;
l_cnt                       number;
l_done                      number;
l_start                     number;

l_final_str                 varchar2(32767);
l_replace_send_str          varchar2(500);
l_disconnect_str            varchar2(500);
l_end_str                   varchar2(500);

l_sync_str                  varchar2(500);

l_str_before_end            varchar2(32767);
l_str_after_end             varchar2(4000);
l_end_loc                   number;

l_str_before_send            varchar2(32767);
l_str_after_send             varchar2(4000);
l_send_loc                   number;
l_sync_loc                   number;

l_str_before_lastsend            varchar2(32767);
l_str_after_lastsend             varchar2(32767);
l_lastsend_loc                   number;

l_str_before_declare         varchar2(32767);
l_str_after_declare          varchar2(32767);
l_declare_loc                number;

begin
  ErrCode := 0;
  ErrStr := NULL;

 l_temp_str := ProcBody;

 /*
  * Replace user written Send to comply with the actual spec of those procedures
  * Remove the user written DECLARE as we will be generating the procedure on the fly
  */

 l_replace_send_str := 'XDP_PROC_CTL.SEND_CONNECT(Fe_Name, ' || g_new_line ||
						' Channel_Name, ' || g_new_line ||
						'''' || ProcName ||''', ' || g_new_line ||
						' sdp_internal_response, ' || g_new_line ||
						' sdp_internal_err_code, ' || g_new_line ||
						' sdp_internal_err_str, ';

 l_sync_str := 'XDP_PROC_CTL.RESET_BUFFER; ' || g_new_line;


 /*
  * Replace the strings here...
  */
 l_temp_str := REPLACE(l_temp_str, 'SEND(', l_replace_send_str);

 /*
  * Need to find the DECLARE word location and delete the users declare string (can be case sensitive)
  */

  l_declare_loc := INSTR(UPPER(l_temp_str), 'DECLARE', 1, 1);
  IF l_declare_loc <> 0 THEN
    l_str_before_declare := SUBSTR(l_temp_str, 1, l_declare_loc - 1);
    l_str_after_declare := SUBSTR(l_temp_str, l_declare_loc + 7, LENGTH(l_temp_str));

    l_temp_str := l_str_before_declare || ' ' || l_str_after_declare;
  end IF;


 /*
  * Construct the procedure
  */
  if fnd_profile.defined('XDP_FP_SPEC') then
     fnd_profile.get('XDP_FP_SPEC', l_final_str);
     l_final_str := ' Procedure ' || ProcName  || ' ( '|| g_new_line || l_final_str || ' ) ' || g_new_line ||
                    'IS ' || g_new_line ||
                    ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';
  else

     l_final_str := ' Procedure ' || ProcName  || ' ( ' || g_new_line ||
      ' Fe_Name      in varchar2, ' || g_new_line ||
      ' Channel_Name in varchar2, ' || g_new_line ||
      ' sdp_internal_err_code out number, ' || g_new_line ||
      ' sdp_internal_err_str out varchar2 ' || ' ) ' || g_new_line ||
      'IS ' || g_new_line ||
     ' sdp_internal_response varchar2(32767); ' || g_new_line || ' ';

  end if;

 l_final_str := l_final_str || l_temp_str;


    /*
     * Find the first users's DISCONNECT string and insert the RESET_BUFFER procedure call
     * before the first call to send.
     */
    l_sync_loc := INSTR(UPPER(l_final_str), 'XDP_PROC_CTL.SEND_CONNECT', 1, 1);

    IF l_sync_loc <> 0 THEN
       l_str_before_send := SUBSTR(l_final_str, 1, l_sync_loc -1);
       l_str_after_send := SUBSTR(l_final_str, l_sync_loc, LENGTH(l_final_str));

    l_final_str := l_str_before_send || l_sync_str || l_str_after_send;
    end IF;

  CompiledProc := l_final_str;

  ErrCode := 0;
  ErrStr := 'Successfully generated the stored procedure ' || ProcName;
exception
  when others then
     ErrCode := SQLCODE;
     ErrStr := 'Unhandled Exception in XDP_PROC_CTL.GENERATE_DISCONNECT_PROC. Error: ' || SUBSTR(SQLERRM,1,200);
end GENERATE_DISCONNECT_PROC;


Procedure RESET_BUFFER
is

begin

 pv_ConnectCommands.delete;

end RESET_BUFFER;

PROCEDURE FETCH_CONNECT_COMMANDS(CurrIndex in number,
				 TotalCount OUT NOCOPY number,
				 Command OUT NOCOPY varchar2,
				 Response OUT NOCOPY varchar2)
is

begin
	xdp_macros.FETCH_CONNECT_COMMANDS(CurrIndex,
					  TotalCount,
					  Command,
					  Response);
-- This is the new Procedure Builder Implementation
-- Comment out the old code.
/*
 TotalCount := pv_ConnectCommands.count;

 if TotalCount > 0 then
	Command := pv_ConnectCommands(CurrIndex).Command;
	Response := pv_ConnectCommands(CurrIndex).Response;
 else
	Command := null;
	Response := null;
 end if;
*/
end FETCH_CONNECT_COMMANDS;


begin

 pv_AckTimeout := 60;
 pv_MesgTimeout := 90;
 pv_ack_conn_timeout := 30;
 pv_cmd_conn_timeout := 45;
 pv_debug_mode := 'Y';
 pv_DirtyBit := FALSE;

 reset_buffer;

end XDP_PROC_CTL;

/
