--------------------------------------------------------
--  DDL for Package Body XDP_MACROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_MACROS" AS
/* $Header: XDPMACRB.pls 120.1 2005/06/09 00:07:05 appldev  $ */


g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

g_Unhandled	number := -20001;
g_MsgNoLogString varchar2(2000);
g_MsgNullResponse varchar2(2000);
g_MsgAuditStr varchar2(2000);

g_StatusSuccess varchar2(30) := 'SUCCESS';
g_StatusTimeout varchar2(30) := 'TIMEOUT';
g_StatusFailure varchar2(30) := 'FAILURE';
g_StatusWarning varchar2(30) := 'WARNING';
g_StatusSessionLost varchar2(30) := 'SESSION_LOST';

-- Private Routines
Procedure SetFeCmdTimeout;

Procedure SetupUserMessages;
Function GetNoLogString return varchar2;
Function getNullResp return varchar2;

Procedure ResetResponseBuffer;
Procedure StripOffendingChars;

-- do an HTTP Get
Procedure doGet(p_Url in varchar2,
		p_LogCommand in varchar2,
		p_EncryptFlag in varchar2);

-- Procedure AppendConnectCommands(p_Command in varchar2,
-- 				p_Response in varchar2);

Procedure LoadAuditTrail(CommandSent in varchar2,
			 Response in varchar2,
			 NoLob in boolean default false);

Procedure LogAuditTrail(LogCmd in varchar2,
			EncryptFlag in varchar2,
			ErrorMessage in varchar2 default null);

Procedure LogAuditTrail(AuditCmd in varchar2);


-- Public Routines...
-- Sends a SYNC message which in turn also cleans up the TO and RETURN Channels
Procedure SEND_SYNC
is
begin

 	XDP_ADAPTER_CORE.SendSync(p_ChannelName => pv_ApplChannelName);

end SEND_SYNC;

--
-- This is the internal translation of the users SEND macro.
Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       p_Prompt in varchar2 default 'IGNORE')
is

-- PL/SQL Block
  l_ActualStr		    varchar2(32767);

  l_TempResponse          varchar2(32767);

  l_LogCmd                varchar2(32767);
  l_Dummy                varchar2(32767);

  l_PromptValue           varchar2(4000);

  l_RespXML 		varchar2(32767);
  l_MoreFlag 		varchar2(10);
  l_Status 		varchar2(40);

begin

  SFM_SQLCODE := 0;
  SFM_SQLERRM := null;

-- Cleanup buffers b4 every send
  ResetResponseBuffer;

-- dbms_output.put_line('SEND: Cmd: ' || substr(p_Command,1,200));
-- dbms_output.put_line(pv_OrderID || ':' ||
 -- pv_LineItemID || ':' ||
 -- pv_WorkItemInstanceID  || ':' ||
 -- pv_FAInstanceID);
-- Get the Command String to be sent out
  xdp_procedure_builder_util.ReplaceOrderParameters(
				p_OrderID => pv_OrderID,
				p_LineItemID => pv_LineItemID,
				p_WIInstanceID => pv_WorkItemInstanceID,
				p_FAInstanceID => pv_FaInstanceId,
				p_CmdString => p_Command,
				x_CmdStringReplaced => l_ActualStr,
				x_CmdStringLog => l_LogCmd,
			      	x_ErrorCode => SFM_SQLCODE,
			      	x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		xdpcore.context('XDP_MACROS',
				'SEND.ReplaceOrderParameters',
				p_Command, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise(SFM_SQLCODE, SFM_SQLERRM);
	end if;

-- Get the Prompt String to be sent out...
 if p_Prompt is not null and p_Prompt <> 'IGNORE' then
	xdp_procedure_builder_util.ReplaceOrderParameters(
                                p_OrderID => pv_OrderID,
                                p_LineItemID => pv_LineItemID,
                                p_WIInstanceID => pv_WorkItemInstanceID,
                                p_FAInstanceID => pv_FaInstanceId,
                                p_CmdString => p_Prompt,
                                x_CmdStringReplaced => l_PromptValue,
                                x_CmdStringLog => l_Dummy,
                                x_ErrorCode => SFM_SQLCODE,
                                x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		xdpcore.context('XDP_MACROS',
				'SEND.ReplaceOrderParameters',
				p_Prompt, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise(SFM_SQLCODE, SFM_SQLERRM);
	end if;
 else
	l_PromptValue := p_Prompt;
 end if;

  begin
	-- reset the Log Locator for every SEND
	pv_ResponseLob := null;
	DBMS_LOB.createtemporary(pv_ResponseLob, TRUE);

	xdp_adapter.pv_AdapterExitCode := null;

	 -- dbms_output.put_line('Sending: ' || substr(l_ActualStr, 1, 200));
	 -- dbms_output.put_line('Prompt: ' ||  substr(l_PromptValue, 1, 200));

	XDP_ADAPTER_CORE.SendApplicationMessage(p_ChannelName => pv_ApplChannelName,
						p_Command => l_ActualStr,
						p_Response => l_PromptValue);

	 -- dbms_output.put_line('Waiting for response...');
	 -- dbms_output.put_line('Timeout: ' || to_char(pv_MesgTimeout));
	XDP_ADAPTER_CORE.WaitForMessage(p_ChannelName => pv_ReturnChannelName,
					p_Timeout => pv_MesgTimeout + 5,
					p_ResponseMessage => l_RespXML);

	l_Status := XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'STATUS',
							p_XMLMessage => l_RespXML);

	 -- dbms_output.put_line('Status: ' || l_Status);

	 -- dbms_output.put_line('Sending ACK');
	XDP_ADAPTER_CORE.SendAck(p_ChannelName => pv_ApplChannelName);

	 -- dbms_output.put_line('After Sending ACK');

	xdp_adapter.pv_AdapterExitCode := XDP_ADAPTER_CORE_XML.DecodeMessage
							(p_WhattoDecode => 'EXIT_CODE',
							 p_XMLMessage => l_RespXML);

	 -- dbms_output.put_line('Exit Code: ' || xdp_adapter.pv_AdapterExitCode);
	if (l_Status = g_StatusSuccess) then

		l_MoreFlag := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'MORE_FLAG',
                                                	p_XMLMessage => l_RespXML);

		 -- dbms_output.put_line('More Flag : ' || l_MoreFlag);
		SFM_int_response_buffer :=
			XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'DATA',
							   p_XMLMessage => l_RespXML);

		if SFM_int_response_buffer is not null then
		 -- dbms_output.put_line('After Reponse' || SFM_int_response_buffer);
			dbms_lob.writeappend(pv_ResponseLob, length(SFM_int_response_buffer), SFM_int_response_buffer);
		end if;
		 -- dbms_output.put_line('After Logging..');
		 -- dbms_output.put_line('After Reponse' || SFM_int_response_buffer);

		while (l_MoreFlag is not null and l_MoreFlag = 'Y' ) loop

			 -- dbms_output.put_line('Waiting for message(LOOP)');
			 -- dbms_output.put_line('Timeout: ' || to_char(pv_MesgTimeout));
			XDP_ADAPTER_CORE.WaitForMessage(
					p_ChannelName => pv_ReturnChannelName,
                                        p_Timeout => pv_MesgTimeout + 5,
                                        p_ResponseMessage => l_RespXML);

			l_Status := XDP_ADAPTER_CORE_XML.DecodeMessage(
							p_WhattoDecode => 'STATUS',
							p_XMLMessage => l_RespXML);
			 -- dbms_output.put_line('Status: (LOOP) ' || l_Status);

			 -- dbms_output.put_line('Sending ACK (LOOP)');
			XDP_ADAPTER_CORE.SendAck(p_ChannelName => pv_ApplChannelName);
			 -- dbms_output.put_line('After Sending ACK (LOOP)');

			xdp_adapter.pv_AdapterExitCode := XDP_ADAPTER_CORE_XML.DecodeMessage
							(p_WhattoDecode => 'EXIT_CODE',
							 p_XMLMessage => l_RespXML);

			 -- dbms_output.put_line('Exit Code:(LOOP) ' || xdp_adapter.pv_AdapterExitCode);
			if (l_Status = g_StatusSuccess ) then

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
						pv_ResponseLob, length(l_TempResponse), l_TempResponse);
				end if;
				 -- dbms_output.put_line('After Logging(LOOP)..');

				if length(SFM_int_response_buffer) + length(l_TempResponse) <= 32767 then
					SFM_int_response_buffer := SFM_int_response_buffer || l_TempResponse;
				elsif length(SFM_int_response_buffer) < 32766 then
					SFM_int_response_buffer :=
					SFM_int_response_buffer ||
					substr(l_TempResponse, 1,
					32766 - length(SFM_int_response_buffer) );
				end if;

			else
				SFM_SQLERRM := XDP_ADAPTER_CORE_XML.DecodeMessage(
                                                        p_WhattoDecode => 'DATA',
                                                        p_XMLMessage => l_RespXML);
				exit;
			end if;
		end loop;

	else
		SFM_SQLERRM := XDP_ADAPTER_CORE_XML.DecodeMessage(
						p_WhattoDecode => 'DATA',
						p_XMLMessage => l_RespXML);
	end if;
  exception
  when others then
	-- dbms_output.put_line('EXCEPTION: ' || SQLCODE);
	-- Log into the Audit trail the command the response
	-- Log the command send irrespective of any errors.

-- Strip any PL/SQL offending characters
-- Mainly chr(0)'s
	StripOffendingChars;

	LogAuditTrail(  LogCmd => l_LogCmd,
			EncryptFlag => p_EncryptFlag,
			ErrorMessage => sqlerrm);

	xdpcore.context('XDP_MACROS',
			'SEND',
			l_ActualStr, SQLCODE, SQLERRM);
	xdpcore.raise(g_Unhandled);

 end;

-- Strip any PL/SQL offending characters
-- Mainly chr(0)'s
	StripOffendingChars;

	-- dbms_output.put_line('Sending Sync..');
--	 XDP_ADAPTER_CORE.SendSync(p_ChannelName => pv_ApplChannelName,
--	 			  p_CleanupPipe => 'N');
	 -- dbms_output.put_line('After Sending Sync..');

	-- Log the Response
	LogAuditTrail(  LogCmd => l_LogCmd,
			EncryptFlag => p_EncryptFlag,
			ErrorMessage => SFM_SQLERRM);

	if l_Status = g_StatusSuccess then
		null;
	else
		-- Set the Context
		xdpcore.context('XDP_MACROS',
				'Send',
				l_Status,
				pv_ReturnChannelName,
				l_ActualStr,
				l_PromptValue,
				pv_MesgTimeout,
				SFM_int_response_buffer);

		if (l_Status = g_StatusFailure) then
			SFM_SQLCODE := xdp_adapter.pv_AdapterFailure;
			xdpcore.raise(xdp_adapter.pv_AdapterFailure, SFM_SQLERRM);

		elsif (l_Status = g_StatusTimeout) then
			SFM_SQLCODE := xdp_adapter.pv_AdapterTimeOut;
			xdpcore.raise(xdp_adapter.pv_AdapterTimeOut, SFM_SQLERRM);

		elsif (l_Status = g_StatusWarning) then
			SFM_SQLCODE := xdp_adapter.pv_AdapterWarning;
			xdpcore.raise(xdp_adapter.pv_AdapterWarning, SFM_SQLERRM);

		elsif (l_Status = g_StatusSessionLost) then
			SFM_SQLCODE := xdp_adapter.pv_AdapterSessionLost;
			xdpcore.raise(xdp_adapter.pv_AdapterSessionLost, SFM_SQLERRM);
		else
			xdpcore.raise(g_Unhandled, SFM_SQLERRM);
		end if;
	end if;

--	DBMS_LOB.freetemporary(pv_ResponseLob);

end SEND;

--
-- For Backward Compatibility...
Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       p_Prompt in varchar2 default 'IGNORE',
	       x_ErrorCode OUT NOCOPY number,
	       x_ErrorString OUT NOCOPY varchar2)
is

begin
	Send(p_Command => p_Command,
	     p_EncryptFlag => p_EncryptFlag,
	     p_Prompt => p_Prompt);

	x_ErrorCode := SFM_SQLCODE;
	x_ErrorString := SFM_SQLERRM;

exception
when others then
	if SFM_SQLCODE <> 0 then
		x_ErrorCode := SFM_SQLCODE;
		x_ErrorString := SFM_SQLERRM;
		-- For Backward Compatibility. Do not raise exception
		-- in cases of timeout Only. SessionLost, Failure etc will still
		-- Raise the exception
		if SFM_SQLCODE = xdp_adapter.pv_AdapterTimeOut then
			-- NO OP
			null;
		else
			raise;
		end if;
	else
		-- Unhandled Exception. Raise it
		x_ErrorCode := SQLCODE;
		x_ErrorString := SQLERRM;
		raise;
	end if;
end SEND;

--
-- For Backward Compatibility...
Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       x_ErrorCode OUT NOCOPY number,
	       x_ErrorString OUT NOCOPY varchar2)
is

begin
	Send(p_Command => p_Command,
	     p_EncryptFlag => p_EncryptFlag);

	x_ErrorCode := SFM_SQLCODE;
	x_ErrorString := SFM_SQLERRM;

exception
when others then
	if SFM_SQLCODE <> 0 then
		x_ErrorCode := SFM_SQLCODE;
		x_ErrorString := SFM_SQLERRM;
		-- For Backward Compatibility. Do not raise exception
		-- in cases of timeout Only. SessionLost, Failure etc will still
		-- Raise the exception
		if SFM_SQLCODE = xdp_adapter.pv_AdapterTimeOut then
			-- NO OP
			null;
		else
			raise;
		end if;
	else
		-- Unhandled Exception. Raise it
		x_ErrorCode := SQLCODE;
		x_ErrorString := SQLERRM;
		raise;
	end if;
end SEND;


--
-- This is the internal translation of the users SEND_HTTP macro.
Procedure SEND_HTTP(p_Url in varchar2,
		    p_EncryptFlag in varchar2 default 'N',
		    p_Proxy in varchar2 default null)
is
 l_ActualStr varchar2(32767);
 l_LogCmd varchar2(32767);


begin

-- cleanup buffers b4 each SEND_HTTP
  ResetResponseBuffer;

-- Get the Command String to be sent out
  xdp_procedure_builder_util.ReplaceOrderParameters(
				p_OrderID => pv_OrderID,
				p_LineItemID => pv_LineItemID,
				p_WIInstanceID => pv_WorkItemInstanceID,
				p_FAInstanceID => pv_FaInstanceId,
				p_CmdString => p_Url,
				x_CmdStringReplaced => l_ActualStr,
				x_CmdStringLog => l_LogCmd,
			      	x_ErrorCode => SFM_SQLCODE,
			      	x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		xdpcore.context('XDP_MACROS',
				'SEND_HTTP.ReplaceOrderParameters',
				p_Url, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise;
	end if;

-- Do a Get Depending on the input
-- GET is the ONLY option supported as of now
	doGet(	p_Url => l_ActualStr,
		p_LogCommand => l_LogCmd,
		p_EncryptFlag => p_EncryptFlag);

end SEND_HTTP;


--
-- For Backward Compatibility...
Procedure SEND_HTTP(p_Url in varchar2,
	       	    p_EncryptFlag in varchar2 default 'N',
		    x_ErrorCode OUT NOCOPY number,
		    x_ErrorString OUT NOCOPY varchar2)
is

begin
	SEND_HTTP(p_Url => p_Url,
		  p_EncryptFlag => p_EncryptFlag);

	x_ErrorCode := SFM_SQLCODE;
	x_ErrorString := SFM_SQLERRM;

exception
when others then
-- Unhandled Exception. Raise it
-- SEND_HTTP does not support any user specific interactions with errors etc
-- for e.g Command Timeout etc are not supported in SEND_HTTP and user cannot
-- trap this error code and code accordingly
	x_ErrorCode := SQLCODE;
	x_ErrorString := SQLERRM;
	raise;
end SEND_HTTP;

--
-- This method is done for an "HTTP GET Request"
Procedure doGet(p_Url in varchar2,
		p_LogCommand in varchar2,
		p_EncryptFlag in varchar2)
is
 l_ReminderLen number;

 l_Resp UTL_HTTP.HTML_PIECES;

begin

-- Use the UTL_HTTP package to do the GET request
  begin
 	l_Resp :=  UTL_HTTP.Request_pieces(p_Url);

	SFM_int_response_buffer := l_Resp(1);

	for i in 2..l_Resp.count loop
		if LENGTH(SFM_int_response_buffer) < 32767 then
			if (LENGTH(SFM_int_response_buffer) +
				LENGTH(l_Resp(i))) < 32767 then
			SFM_int_response_buffer := SFM_int_response_buffer ||
				l_Resp(i);
			else
				l_ReminderLen := 32767 - LENGTH(l_Resp(i));
				SFM_int_response_buffer := SFM_int_response_buffer
				|| SUBSTR(l_Resp(i), 1, l_ReminderLen);
			end if;
		end if;
	end loop;
 exception
 when others then
	-- Log in the audit trail anyway
	LogAuditTrail(  LogCmd => p_LogCommand,
			EncryptFlag => p_EncryptFlag,
			ErrorMessage => sqlerrm);

	SFM_SQLCODE := sqlcode;
	SFM_SQLCODE := sqlerrm;

	xdpcore.context('XDP_MACROS',
			'SEND_HTTP.doGet.UTL_HTTP.Request_pieces',
			p_Url, SQLCODE, SQLERRM);
	xdpcore.raise(g_Unhandled);
 end;

-- Log the response
	LogAuditTrail(  LogCmd => p_LogCommand,
			EncryptFlag => p_EncryptFlag);
end doGet;

--
-- This is the internal translation of the users GET_RESPONSE macro.
Function GET_RESPONSE return varchar2
is
begin
	return (SFM_int_response_buffer);

end GET_RESPONSE;

--
-- This is the internal translation of the users GET_PARAM_VALUE macro.
Function GET_PARAM_VALUE(p_ParamName in varchar2) return varchar2
is
 l_ActualStr varchar2(4000);
 l_dummy varchar2(4000);
begin

-- Get the Command String
  xdp_procedure_builder_util.ReplaceOrderParameters(
				p_OrderID => pv_OrderID,
				p_LineItemID => pv_LineItemID,
				p_WIInstanceID => pv_WorkItemInstanceID,
				p_FAInstanceID => pv_FaInstanceId,
				p_CmdString => p_ParamName,
				x_CmdStringReplaced => l_ActualStr,
				x_CmdStringLog => l_dummy,
			      	x_ErrorCode => SFM_SQLCODE,
			      	x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		xdpcore.context('XDP_MACROS',
				'GET_PARAM_VALUE.ReplaceOrderParameters',
				p_ParamName, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise;
	end if;

	-- dbms_output.put_line('SFMCODE: ' || SFM_SQLCODE);
	return (l_ActualStr);

end GET_PARAM_VALUE;

--
-- For Future use only!!
Function GET_ATTR_VALUE(p_AttrName in varchar2) return varchar2
is
 l_ActualCmd varchar2(2000);
begin
	xdp_procedure_builder_util.ReplaceFEAttributes(
			p_FeName => pv_FeName,
			p_CmdString => p_AttrName,
			x_CmdStringReplaced => l_ActualCmd,
			x_ErrorCode => SFM_SQLCODE,
			x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		-- dbms_output.put_line('Error: ' || SFM_SQLERRM);
		xdpcore.context('XDP_MACROS',
				'GET_ATTR_VALUE.RepalceFEAttributes',
				p_AttrName, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise;
	end if;

	return (l_ActualCmd);

end GET_ATTR_VALUE;

--
-- This is the internal translation of the users RESPONSE_CONTAINS macro.
Function RESPONSE_CONTAINS(p_UserString in varchar2) return boolean
is

begin

	if p_UserString is NULL or SFM_int_response_buffer is NULL then
		return true;
	end if;

	if instrb(SFM_int_response_buffer, p_UserString, 1, 1) > 0 then
		return true;
	else
		return false;
	end if;

end RESPONSE_CONTAINS;

--
-- This is the internal translation of the users NOTIFY_ERROR macro.
Procedure NOTIFY_ERROR(p_UserMessage in varchar2,
		       p_AutomaticRetry in number default 0)
is
begin
	SFM_SQLCODE := g_NotifyError;
	SFM_SQLERRM := p_UserMessage;
	pv_AutoRetry := p_AutomaticRetry;
	raise e_NotifyError;

end NOTIFY_ERROR;

--
-- For Backward compatibility
Procedure NOTIFY_ERROR(p_UserMessage in varchar2,
		       p_Overwrite in varchar2)
is
begin
	SFM_SQLCODE := g_NotifyError;
	SFM_SQLERRM := p_UserMessage;

	if p_Overwrite = 'A' then
		SFM_SQLERRM := substr(p_UserMessage ||
					' ' ||
				substr(SFM_int_response_buffer,1,1500), 1, 2000);
	end if;
	raise e_NotifyError;

end NOTIFY_ERROR;

-- New for 11.5.6++
--
-- This is the internal translation of the users GET_LONG_RESPONSE macro.
Function GET_LONG_RESPONSE return CLOB
is
begin
	return (pv_ResponseLob);

end GET_LONG_RESPONSE;

--
-- This is the internal translation of the users AUDIT macro.
Procedure AUDIT(p_AuditString in varchar2)
is
begin
	LogAuditTrail(AuditCmd => p_AuditString);
end AUDIT;

--
-- This function returns if the FP error needs to be automatically
-- retried
Function AUTO_RETRY_ENABLED return varchar2
is
begin
	if pv_AutoRetry = 0 then
		return 'N';
	else
		return 'Y';
	end if;

end AUTO_RETRY_ENABLED;

--
-- This is the internal translation of the Users SEND and LOGIN macros
-- in the Connect/Disconnect procedures
Procedure SEND_CONNECT( p_Command in varchar2,
	       		p_Prompt in varchar2 default 'IGNORE')
is
 l_ActualCmd varchar2(4000);
 l_ActualPrompt varchar2(4000);
begin

	-- Replace the FE Attributes in the command to be sent by their values
	xdp_procedure_builder_util.ReplaceFEAttributes(
			p_FeName => pv_FeName,
			p_CmdString => p_Command,
			x_CmdStringReplaced => l_ActualCmd,
			x_ErrorCode => SFM_SQLCODE,
			x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		-- dbms_output.put_line('Error: ' || SFM_SQLERRM);
		xdpcore.context('XDP_MACROS',
				'SEND_CONNET.RepalceFEAttributes',
				p_Command, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise;
	end if;

	-- Replace the FE Attributes in the Prompt by their values
	xdp_procedure_builder_util.ReplaceFEAttributes(
			p_FeName => pv_FeName,
			p_CmdString => p_Prompt,
			x_CmdStringReplaced => l_ActualPrompt,
			x_ErrorCode => SFM_SQLCODE,
			x_ErrorString => SFM_SQLERRM);

  	if SFM_SQLCODE <> 0 then
		-- dbms_output.put_line('Error: ' || SFM_SQLERRM);
		xdpcore.context('XDP_MACROS',
				'SEND_CONNET.RepalceFEAttributes',
				p_Command, SFM_SQLCODE, SFM_SQLERRM);
		xdpcore.raise;
	end if;

	-- dbms_output.put_line('Command: ' || l_ActualCmd);
	-- dbms_output.put_line('Response: ' || l_ActualPrompt);

	-- Append the commands to the internal buffer
	-- The commands are not actually "Sent" to the adapter
	-- The adapter executes the Connect Procedure which in turn populated
	-- the buffer. Once this is done the adapter executes the
	-- "FetchConnectCommands reoutine to get the commands
	AppendConnectCommands(p_Command => l_ActualCmd,
			      p_Response => l_ActualPrompt);

end SEND_CONNECT;

--
-- For backward compatibility
Procedure SEND_CONNECT( p_Command in varchar2,
	       		p_Prompt in varchar2 default 'IGNORE',
			x_ErrorCode OUT NOCOPY number,
			x_ErrorString OUT NOCOPY varchar2)
is

begin

	Send_Connect(p_Command => p_Command,
			p_Prompt => p_Prompt);

	x_ErrorCode := SFM_SQLCODE;
	x_ErrorString := SFM_SQLERRM;

exception
when others then
	x_ErrorCode := SQLCODE;
	x_ErrorString := SFM_SQLERRM;
end SEND_CONNECT;


--
-- This routine fetches the commands and their respective responses from
-- the buffer. The buffer is populated by each SEND macro
PROCEDURE FETCH_CONNECT_COMMANDS(p_CurrIndex in number,
				 x_TotalCount OUT NOCOPY number,
				 x_Command OUT NOCOPY varchar2,
				 x_Response OUT NOCOPY varchar2)
is

begin
 x_TotalCount := xdp_macros.g_ConnectCommands.count;

 if x_TotalCount > 0 then
	x_Command := xdp_macros.g_ConnectCommands(p_CurrIndex).Command;
	x_Response := xdp_macros.g_ConnectCommands(p_CurrIndex).Response;
 else
	x_Command := null;
	x_Response := null;
 end if;

end FETCH_CONNECT_COMMANDS;


-- The commands are not actually "Sent" to the adapter
-- The adapter executes the Connect Procedure which in turn populated
-- the buffer. Once this is done the adapter executes the
-- "FetchConnectCommands reoutine to get the commands
Procedure AppendConnectCommands(p_Command in varchar2,
				p_Response in varchar2)
is
 l_size number;
begin
 l_size := xdp_macros.g_ConnectCommands.count;

 xdp_macros.g_ConnectCommands(l_size + 1).command := p_Command;
 xdp_macros.g_ConnectCommands(l_size + 1).response := p_Response;

end AppendConnectCommands;


--
-- Log the Command sent to the audit trail
-- The internal response buffer is also logged
Procedure LogAuditTrail(LogCmd in varchar2,
			EncryptFlag in varchar2,
			ErrorMessage in varchar2 default null)
is
 l_Response varchar2(32767) := '' ;
begin

   if ErrorMessage is not null then
	l_Response := ErrorMessage || g_new_line;
   end if;

   if EncryptFlag = 'Y' then
      l_Response :=  l_Response || GetNoLogString;
   else
	l_Response := l_Response || substr(SFM_int_response_buffer,1,32766);
   end if;

-- dbms_output.put_line('LOG: Cmd: ' || substr(LogCmd,1,200));
-- dbms_output.put_line(pv_OrderID || ':' ||
--  pv_LineItemID || ':' ||
--  pv_WorkItemInstanceID  || ':' ||
--  pv_FAInstanceID);

	LoadAuditTrail(CommandSent => LogCmd,
		       Response => NVL(l_Response, getNullResp));

end LogAuditTrail;

--
-- Log the AUDIT string to the audit trail
-- This is used when the user requests a specific audit request
-- with the AUDIT macro
Procedure LogAuditTrail(AuditCmd in varchar2)
is
begin

	LoadAuditTrail( CommandSent => substr(AuditCmd, 1, 1996),
		        Response => g_MsgAuditStr,
			NoLob => true);

end LogAuditTrail;


--
-- Get the translated String for the user to let him know that he
-- has asked NOT to log the responses from the FE
Function GetNoLogString return varchar2 is
begin

 return (g_MsgNoLogString);

end GetNoLogString;

--
-- Get the translated String for the user to indicate a NULL response from the FE
Function getNullResp return varchar2 is
begin

 return (g_MsgNullResponse);

end getNullResp;

--
-- Load the Audit Trail Table
Procedure LoadAuditTrail(CommandSent in varchar2,
			 Response in varchar2,
			 NoLob boolean default false)
is
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_Response varchar2(4000);
begin

-- Bug 3064571
-- Max Size for RESPONSE Column is 4000
-- Rest of the Response can be obtained from the RESPONSE_LONG CLOB column

 l_Response := substr(Response, 1, 3999);

 if NoLob then
	INSERT INTO XDP_FE_CMD_AUD_TRAILS (
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               fa_instance_id,
               fe_command_seq,
               fulfillment_element_name,
               fulfillment_element_type,
               sw_generic,
               command_sent,
               command_sent_date,
               response,
	       response_long,
               response_date,
               provisioning_procedure)
	VALUES (
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.LOGIN_ID,
               pv_FAInstanceID,
               XDP_FE_CMD_AUD_TRAILS_S.NEXTVAL,
               pv_FEName,
               pv_FeType,
               pv_SWGeneric,
               CommandSent,
               sysdate,
	       l_Response,
               Response,
               sysdate,
               pv_ProcName);
 else
	INSERT INTO XDP_FE_CMD_AUD_TRAILS (
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               fa_instance_id,
               fe_command_seq,
               fulfillment_element_name,
               fulfillment_element_type,
               sw_generic,
               command_sent,
               command_sent_date,
               response,
	       response_long,
               response_date,
               provisioning_procedure)
	VALUES (
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.LOGIN_ID,
               pv_FAInstanceID,
               XDP_FE_CMD_AUD_TRAILS_S.NEXTVAL,
               pv_FEName,
               pv_FeType,
               pv_SWGeneric,
               CommandSent,
               sysdate,
	       l_Response,
	       pv_ResponseLob,
               sysdate,
               pv_ProcName);
 end if;

 commit;

end LoadAuditTrail;


--
-- Get the total timout for the command execution
Procedure SetFeCmdTimeout
is
 l_FeAttrVal varchar2(4000);
 l_Retries number := 0;
 l_CmdTimeout number := 120;
 l_RetryWait number := 0;
begin

 	pv_MesgTimeout := 0;

	begin
		l_FeAttrVal := xdp_engine.get_fe_attributeval(
				pv_FeID, pv_attrFeCmdTimeout);
		if l_FeAttrVal is null then
			l_CmdTimeout := pv_defFeCmdTimeout;
		else
			l_CmdTimeout := to_number(l_FeAttrVal);
		end if;
	exception
	when no_data_found then
		l_CmdTimeout := pv_defFeCmdTimeout;
	when others then
		raise;
	end;

	begin
		l_FeAttrVal := xdp_engine.get_fe_attributeval(
				pv_FeID, pv_attrFeRetryCount);
		if l_FeAttrVal is null then
			l_Retries := pv_defFeRetryCount;
		else
			l_Retries := to_number(l_FeAttrVal);
		end if;
	exception
	when no_data_found then
		l_Retries := pv_defFeRetryCount;
	when others then
		raise;
	end;

	begin
		l_FeAttrVal := xdp_engine.get_fe_attributeval(
				pv_FeID, pv_attrFeCmdRetryWait);
		if l_FeAttrVal is null then
			l_RetryWait := pv_defFeCmdRetryWait;
		else
			l_RetryWait := to_number(l_FeAttrVal);
		end if;
	exception
	when no_data_found then
		l_RetryWait := pv_defFeCmdRetryWait;
	when others then
		raise;
	end;

	if to_number(l_Retries) <> 0 then
		pv_MesgTimeout := to_number(l_CmdTimeout) +
			( to_number(l_CmdTimeout) + to_number(l_RetryWait) ) *
			to_number(l_Retries);
	else
		pv_MesgTimeout := to_number(l_CmdTimeout);
	end if;

	if pv_MesgTimeout = 0 then
		pv_MesgTimeout := pv_defMesgTimeout;
	end if;


end SetFeCmdTimeout;

Procedure ResetResponseBuffer
is

begin
   SFM_int_response_buffer := '';

end ResetResponseBuffer;

--
-- PL/SQL does not like chr(0)!!
Procedure StripOffendingChars
is

begin
	SFM_int_response_buffer := replace(SFM_int_response_buffer, chr(0), '');

end StripOffendingChars;

--
-- Clean up the buffers
Procedure ResetCommandBuffer
is
begin

  xdp_macros.g_ConnectCommands.delete;

end ResetCommandBuffer;

--
-- Default Initialization for all Procedure Types which DO NOT
-- require any any special treatment. The FP, Connect and Disconnect
-- Procedure types have special initialization routines
Procedure Initdefault(  OrderID in number,
			LineItemID in number,
			WIInstanceID in number,
			FAInstanceID in number)
is

begin

 SFM_SQLCODE := 0;
 SFM_SQLERRM := null;

--
-- In case the Procedure being executed is invoked from an FP
-- for example GET_PARAM_VALUE of a Work Item which has an evaluation
-- Procedure associated with it, the global variables to be initialized are
-- NOT to be reset with nulls. If the Globals are already Initialized
-- then leave them as is
 pv_OrderID := nvl(OrderID, pv_OrderID);
 pv_LineItemID := nvl(LineItemID, pv_LineItemID);
 pv_WorkItemInstanceID := nvl(WIInstanceID, pv_WorkItemInstanceID);
 pv_FAInstanceID := nvl(FAInstanceID, pv_FAInstanceID);

 if pv_ParamCacheReqd = 'Y' then
	-- Cache is already set
	-- By FP
	null;
 else
	pv_ParamCacheReqd := 'N';
 end if;

end Initdefault;


--
-- Initialization specific for Fulfillment Procdure
-- 1. The Parameter Config Cache needs to be initialized
-- 2. The Communication channels(pipes) needs to be set
-- 3. SYNC message needs to be sent
-- 4. The Command time out value needs to be set
Procedure InitFP(OrderID in number,
                 LineItemID in number,
                 WIInstanceID in number,
                 FAInstanceID in number,
                 ChannelName in  varchar2,
                 FEName in varchar2,
                 ProcName in  varchar2)
is

begin

-- Initialize Order Related Package Variables

 pv_OrderID := OrderID;
 pv_LineItemID := LineItemID;
 pv_WorkItemInstanceID := WIInstanceID;
 pv_FAInstanceID := FAInstanceID;
 pv_ChannelName := ChannelName;
 pv_FeName := FEName;
 pv_ProcName := ProcName;
 SFM_SQLCODE := 0;
 SFM_SQLERRM := null;

 pv_ResponseLob := null;

 pv_AutoRetry := 0;

 pv_AdapterImplemented  := false;

-- Buffers
 ResetResponseBuffer;

-- The Parameter Config Cache is required for an FP
-- Intialize the Cache
 pv_ParamCacheReqd := 'Y';
 xdp_param_cache.clear_cache;
 xdp_param_cache.init_cache(p_wi_instance_id => WIInstanceID,
			    p_fa_instance_id => FAInstanceID);

-- Setup the Channel Names for Communications and Send a SYNC message
-- The SEND requires 2 channels: 1 Channel for sending commands
-- and another channel for the responses from the adapter

-- Bug 2486815
-- Send Sync for only Implemented Adapters
if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (pv_ChannelName)) then
 pv_ApplChannelName := XDP_ADAPTER_CORE_PIPE.ConstructChannelName
			(p_ChannelType => 'APPL',
			 p_ChannelName => pv_ChannelName);

 pv_ReturnChannelName := XDP_ADAPTER_CORE_PIPE.GetReturnChannelName
			(p_ChannelName => pv_ApplChannelName);

 Send_Sync;
end if;

-- Setup the timeout for response from the adapter for each
-- command

	XDP_ENGINE.GET_FE_CONFIGINFO (	pv_FeName,
					pv_FeID,
                                   	pv_FeTypeID,
                                   	pv_FeType,
                                   	pv_SwGeneric,
                                   	pv_AdapterType);

	SetFeCmdTimeout;

-- Finally set up from User Messages
   SetupUserMessages;
end InitFP;


--
-- Procedure Finilization routine to be for all procedures.
Procedure EndProc(p_return_code in OUT NOCOPY number,
		p_error_description in OUT NOCOPY varchar2)
is

begin
	if SFM_SQLCODE <> 0 then
		-- Internal Error had occured
		-- Return with an error
		p_return_code := SFM_SQLCODE;
		p_error_description := SFM_SQLERRM;
	else
		-- User could set the return core
		-- Let it be as is
		null;
	end if;

	-- dbms_output.put_line('SFMCODE: ' || SFM_SQLCODE);
	-- dbms_output.put_line('retcode: ' || p_return_code);
end EndProc;

--
-- Initialization routine specific to the Connetion procedure
Procedure InitConnection(ChannelName in  varchar2,
                         FEName in varchar2)
is

begin
 pv_FeName := FEName;
 pv_ChannelName := ChannelName;
 SFM_SQLCODE := 0;
 SFM_SQLERRM := null;

 ResetResponseBuffer;

 ResetCommandBuffer;

end InitConnection;


--
-- Initialization routine specific to the Connetion procedure
Procedure InitDisConnection(ChannelName in  varchar2,
                         FEName in varchar2)
is

begin
 null;

end InitDisconnection;


--
-- This routine traps all the errors in any type of procedure and returns
-- appropriate error codes
Procedure HandleProcErrors(p_return_code OUT NOCOPY number,
                           p_error_description OUT NOCOPY varchar2)
is
begin
-- Cleanup the Cache..
 xdp_param_cache.clear_cache;

 if SFM_SQLCODE <> 0 then
	p_return_code := SFM_SQLCODE;
	p_error_description := SFM_SQLERRM;
 	return;
 end if;
	p_return_code := sqlcode;
	p_error_description := sqlerrm;

-- For future Use if you want to do anything special for each error

 if sqlcode = g_CommandTimeout then
	-- handle Command Timeout
	null;
 elsif sqlcode = g_SessionLost then
	-- Handle Session Lost
	null;
 elsif sqlcode = g_FeFailure then
	-- Handle FE Failure
	null;
 else
	-- Unhandled Exception
	null;
 end if;

	p_return_code := sqlcode;
	p_error_description := substr(sqlerrm,1,1996);

end HandleProcErrors;

--
-- Setup the Translated User Messages ONCE
Procedure SetupUserMessages
is
begin

	FND_MESSAGE.SET_NAME('XDP','XDP_FP_NO_LOG_STR');
	g_MsgNoLogString := FND_MESSAGE.GET;

	FND_MESSAGE.SET_NAME('XDP','XDP_FP_NULL_RESPONSE');
	g_MsgNullResponse := FND_MESSAGE.GET;

	FND_MESSAGE.SET_NAME('XDP','XDP_FP_AUDIT_STR');
	g_MsgAuditStr := FND_MESSAGE.GET;

end SetupUserMessages;

begin
 ResetCommandBuffer;
 pv_AckTimeout := 60;
 pv_MesgTimeout := 90;

end XDP_MACROS;

/
