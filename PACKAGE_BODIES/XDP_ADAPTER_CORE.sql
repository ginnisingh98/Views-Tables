--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_CORE" AS
/* $Header: XDPACORB.pls 120.1 2005/06/08 23:34:53 appldev  $ */


Function IsOperationValid(p_Operation in varchar2,
			  p_CurrentAdapterStatus in varchar2) return boolean;

Procedure TalkToAdapter(p_ChannelName in varchar2,
			p_Command in varchar2,
			p_Timeout OUT NOCOPY number);

Procedure ReceiveAck(p_ChannelName in varchar2,
		     p_Status OUT NOCOPY varchar2,
		     p_ErrorMessage OUT NOCOPY varchar2,
		     p_Timeout OUT NOCOPY number);

Procedure SendSync( p_ChannelName in varchar2,
		    p_CleanupPipe in varchar2 default 'Y')
is

begin
	if p_CleanupPipe = 'Y' then
		XDP_ADAPTER_CORE_PIPE.CleanupPipe(p_ChannelName => SendSync.p_ChannelName,
						p_Cleanreturn => 'Y');
	end if;

	SendControlCommand(p_ChannelName => SendSync.p_ChannelName,
			   p_Operation => 'SYNC');

end SendSync;

Procedure SendResponse(p_ChannelName in varchar2,
		       p_Status in varchar2,
		       p_Message in varchar2)

is
 RespXML varchar2(4000);
begin

 RespXML := XDP_ADAPTER_CORE_XML.ConstructRespXML(p_Status => SendResponse.p_Status,
						 p_RespData => SendResponse.p_Message);

 SendMessage(p_ChannelName => SendResponse.p_ChannelName, p_Command => RespXML);

end SendResponse;


Procedure SendAck(p_ChannelName in varchar2)

is
 AckXML varchar2(4000);
begin
 AckXML := XDP_ADAPTER_CORE_XML.ConstructRespXML(p_Status => 'ACK',
						 p_RespData => NULL);

 SendMessage(p_ChannelName => SendAck.p_ChannelName, p_Command => AckXML);

end SendAck;



Procedure SendControlCommand(	p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData in varchar2 default null)
is
 ControlCommandXML varchar2(4000);
begin

	ControlCommandXML :=
		XDP_ADAPTER_CORE_XML.ConstructControlXML
			(p_Operation => SendControlCommand.p_Operation,
			 p_OpData => SendControlCommand.p_OpData);

	TalkToAdapter (	p_ChannelName => SendControlCommand.p_ChannelName,
			p_Command => ControlCommandXML);

end SendControlCommand;


Procedure SendControlCommand(	p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData in varchar2 default null,
				p_Timeout OUT NOCOPY number)
is
 ControlCommandXML varchar2(4000);

begin

	ControlCommandXML :=
		XDP_ADAPTER_CORE_XML.ConstructControlXML
			(p_Operation => SendControlCommand.p_Operation,
			 p_OpData => SendControlCommand.p_OpData);

	TalkToAdapter(	p_ChannelName => SendControlCommand.p_ChannelName,
			p_Command => ControlCommandXML,
			p_Timeout => SendControlCommand.p_Timeout);

end SendControlCommand;

Procedure ProcessControlCommand(p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData in varchar2 default null,
				p_Status OUT NOCOPY varchar2,
				p_ErrorMessage OUT NOCOPY varchar2)
is
 l_Timeout number;
 l_ReturnChannel varchar2(40);
 l_RespXML varchar2(4000);
begin

	XDP_ADAPTER_CORE_PIPE.CleanupPipe(p_ChannelName => p_ChannelName);

	-- dbms_output.put_line('In ProcessControlCommand');
	-- dbms_output.put_line('Before SendControlCommand, p_ChannelName:' || p_ChannelName);

	SendControlCommand(p_ChannelName => ProcessControlCommand.p_ChannelName,
			   p_Operation => ProcessControlCommand.p_Operation,
			   p_OpData => ProcessControlCommand.p_OpData,
			   p_Timeout => l_Timeout);

	l_ReturnChannel := XDP_ADAPTER_CORE_PIPE.GetReturnChannelName
				(p_ChannelName => ProcessControlCommand.p_ChannelName);

	-- dbms_output.put_line('After SendControlCommand, l_ReturnChannel:' || l_ReturnChannel);
	-- dbms_output.put_line('After SendControlCommand, Message timeout: ' || l_Timeout);
	-- dbms_output.put_line('Before WaitForMessage');

	WaitForMessage(p_ChannelName => l_ReturnChannel,
		       p_Timeout => l_Timeout,
		       p_ResponseMessage => l_RespXML);

	-- dbms_output.put_line('After WaitForMessage, p_ResponseMessage:'||l_RespXML);
	-- dbms_output.put_line('Before SendAck');

	SendAck(p_ChannelName => ProcessControlCommand.p_ChannelName);

	p_Status := XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'STATUS',
							p_XMLMessage => l_RespXML);

	p_ErrorMessage := XDP_ADAPTER_CORE_XML.DecodeMessage(p_WhattoDecode => 'DATA',
							p_XMLMessage => l_RespXML);

	if (p_Operation <> XDP_ADAPTER.pv_opStop)  and
	   (p_Status <> pv_AdapterResponseFailure) then
			SendSync(p_ChannelName => ProcessControlCommand.p_ChannelName,
			 	 p_CleanupPipe => 'N');
	end if;
exception
when e_ReceiveTimedOut then
p_Status := pv_ProcessCommandTimedout;
p_ErrorMessage := 'Waiting for response, timed out';

when others then
p_Status := pv_ProcessCommandError;
p_ErrorMessage := 'Waiting for response, errored out';

end ProcessControlCommand;

Procedure TalkToAdapter(p_ChannelName in varchar2,
			p_Command in varchar2)
is
 l_dummynum number;
begin
 TalkToAdapter(p_ChannelName => TalkToAdapter.p_ChannelName,
		p_Command => TalkToAdapter.p_Command,
		p_Timeout => l_dummynum);

end TalkToAdapter;


Procedure TalkToAdapter(p_ChannelName in varchar2,
			p_Command in varchar2,
			p_Timeout OUT NOCOPY number)
is

 ReturnChannelName varchar2(40);
 Status varchar2(40);
 ErrorMessage varchar2(2000);

begin
	SendMessage(p_ChannelName => TalkToAdapter.p_ChannelName,
		    p_Command => TalkToAdapter.p_Command);

	ReturnChannelName := XDP_ADAPTER_CORE_PIPE.GetReturnChannelName
				(p_ChannelName => TalkToAdapter.p_ChannelName);

	ReceiveAck(p_ChannelName => ReturnChannelName,
		   p_Status => Status,
		   p_ErrorMessage => ErrorMessage,
		   p_Timeout=> p_Timeout);

	-- if Status = 'WARNING' then
	-- 	raise e_AdapterWarningException;
	-- elsif Status = 'ERROR' then
	-- 	raise e_AdapterErrorException;
	-- end if;

end TalkToAdapter;


Procedure SendApplicationMessage(p_ChannelName in varchar2,
				 p_Command in varchar2,
				 p_Response in varchar2)
is
 ApplXML varchar2(4000);
begin
	ApplXML := XDP_ADAPTER_CORE_XML.ConstructSendXML(
				p_Command => SendApplicationMessage.p_Command,
				p_Response => SendApplicationMessage.p_Response);

	TalkToAdapter(p_ChannelName => SendApplicationMessage.p_ChannelName,
		      p_Command => ApplXML);

end SendApplicationMessage;


Procedure SendMessage(	p_ChannelName in varchar2,
			p_Command in varchar2)
is
begin

	XDP_ADAPTER_CORE_PIPE.SendPipedMessage(p_ChannelName => SendMessage.p_ChannelName,
			  		     p_Message => SendMessage.p_Command);

end SendMessage;


Procedure ReceiveAck(p_ChannelName in varchar2,
		     p_Status OUT NOCOPY varchar2,
		     p_ErrorMessage OUT NOCOPY varchar2)
is
 l_dummynum number;
begin
	ReceiveAck(p_ChannelName => ReceiveAck.p_ChannelName,
		   p_Status => ReceiveAck.p_Status,
		   p_ErrorMessage => ReceiveAck.p_ErrorMessage,
		    p_Timeout=> l_dummynum);

end ReceiveAck;

Procedure ReceiveAck(p_ChannelName in varchar2,
		     p_Status OUT NOCOPY varchar2,
		     p_ErrorMessage OUT NOCOPY varchar2,
		     p_Timeout OUT NOCOPY number)
is
 ReturnCode number := 0;

 PipedMessage varchar2(4000);
 l_Timeout varchar2(20);
begin

	XDP_ADAPTER_CORE_PIPE.ReceivePipedMessage(p_ChannelName => ReceiveAck.p_ChannelName,
						p_Timeout => NULL,
					    	p_ErrorCode => ReturnCode,
					    	p_Message => PipedMessage);

	if ReturnCode = 0  then
		if PipedMessage is not null then

			p_Status := XDP_ADAPTER_CORE_XML.DecodeMessage
						(p_WhattoDecode => 'STATUS',
						 p_XMLMessage => PipedMessage);

			p_ErrorMessage  := XDP_ADAPTER_CORE_XML.DecodeMessage
						(p_WhattoDecode => 'DATA',
						 p_XMLMessage => PipedMessage);

			l_Timeout  := XDP_ADAPTER_CORE_XML.DecodeMessage
						(p_WhattoDecode => 'TIMEOUT',
						 p_XMLMessage => PipedMessage);

			if l_Timeout is not null then
				p_Timeout := to_number(l_Timeout);
			else
				p_Timeout := pv_DefTimeout;
			end if;

		else
			raise e_ReceiveOtherError;
			-- p_Status := 'WARNING';
			-- p_ErrorMessage := 'Nuthin to Unpack';
		end if;
	elsif ReturnCode = pv_DBMSPipeTimeoutError then
		raise e_ReceiveTimedOut;
	else
		raise e_ReceiveOtherError;
	end if;

end ReceiveAck;


Procedure WaitForMessage(p_ChannelName  in varchar2,
			 p_Timeout in number,
			 p_ResponseMessage OUT NOCOPY varchar2)
is
 ReturnCode number := 0;
begin

	XDP_ADAPTER_CORE_PIPE.ReceivePipedMessage
			(p_ChannelName => WaitForMessage.p_ChannelName,
			 p_Timeout => WaitForMessage.p_Timeout,
			 p_ErrorCode => ReturnCode,
			 p_Message => p_ResponseMessage);

	if ReturnCode <> 0 then
		if ReturnCode = pv_DBMSPipeTimeoutError then
			raise e_ReceiveTimedOut;
		else
			raise e_ReceiveOtherError;
		end if;
	end if;
end WaitForMessage;


Function VerifyAdapterOperation(p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_CurrentStatus OUT NOCOPY varchar2)  return boolean
is
 l_isValid boolean := false;
begin
 p_CurrentStatus := XDP_ADAPTER_CORE_DB.GetCurrentAdapterStatus
				(VerifyAdapterOperation.p_ChannelName);

 if (IsOperationValid(VerifyAdapterOperation.p_Operation, p_CurrentStatus) ) then
	l_isValid := true;
 end if;

 return (l_isValid);

end VerifyAdapterOperation;


Function IsOperationValid(p_Operation in varchar2,
			  p_CurrentAdapterStatus in varchar2) return boolean
is
 l_isValid boolean := false;
begin
 if p_Operation = XDP_ADAPTER.pv_opStartup then
--	if p_CurrentAdapterStatus = XDP_ADAPTER.pv_statusStopped then

	if p_CurrentAdapterStatus in (XDP_ADAPTER.pv_statusStopped,
					XDP_ADAPTER.pv_statusStoppedError,
					XDP_ADAPTER.pv_statusTerminated,
					XDP_ADAPTER.pv_statusDeactivated,
					XDP_ADAPTER.pv_statusDeactivatedSystem) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opStop then
	if p_CurrentAdapterStatus not in (XDP_ADAPTER.pv_statusStopped,
					XDP_ADAPTER.pv_StatusStoppedError,
					XDP_ADAPTER.pv_StatusTerminated,
				    	XDP_ADAPTER.pv_statusNotAvailable,
					XDP_ADAPTER.pv_statusDeactivated,
					XDP_ADAPTER.pv_statusDeactivatedSystem) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opConnect then
	if p_CurrentAdapterStatus in (XDP_ADAPTER.pv_statusDisconnected,
					XDP_ADAPTER.pv_statusSessionLost) then
		l_isValid := true;
	else
		l_isValid := false;
        end if;

 elsif p_Operation = XDP_ADAPTER.pv_opDisconnect then
	if p_CurrentAdapterStatus in (XDP_ADAPTER.pv_statusRunning,
					XDP_ADAPTER.pv_statusSuspended) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opSuspend then
	if p_CurrentAdapterStatus = XDP_ADAPTER.pv_statusRunning then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opResume then
	if p_CurrentAdapterStatus = XDP_ADAPTER.pv_statusSuspended then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opVerify then
	if p_CurrentAdapterStatus not in (XDP_ADAPTER.pv_statusStopped,
					XDP_ADAPTER.pv_StatusStoppedError,
					XDP_ADAPTER.pv_StatusTerminated,
				    	XDP_ADAPTER.pv_statusNotAvailable,
					XDP_ADAPTER.pv_statusDeactivated,
					XDP_ADAPTER.pv_statusDeactivatedSystem) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opUpdate then
	if p_CurrentAdapterStatus in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_StatusStoppedError,
				XDP_ADAPTER.pv_StatusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opDelete then
	if p_CurrentAdapterStatus in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_StatusStoppedError,
				XDP_ADAPTER.pv_StatusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Operation = XDP_ADAPTER.pv_opGeneric then
	-- Generic operation
	if p_CurrentAdapterStatus = XDP_ADAPTER.pv_statusRunning then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 else
	l_isValid := false;

 end if;

 return (l_isValid);

end IsOperationValid;


Function ShouldAdapterConnect(p_ChannelName in varchar2) return varchar2
is

begin

 if ( XDP_ADAPTER_CORE_DB.IsChannelCOD(p_ChannelName) = 'N') then
      return('Y');
 elsif (XDP_ADAPTER_CORE_DB.PeekIntoFeWaitQueue(p_ChannelName) = 'Y') then
      return('Y');
 else
      return( 'N');
 end if;

end ShouldAdapterConnect;


Procedure NotifyAdapterTerminateFailure (p_AdapterName in VARCHAR2,
			p_NotifRecipient IN VARCHAR2 DEFAULT NULL)
is
 l_NotifID number;
 l_NotifRecipient varchar2(80);
begin

 if ( p_notifRecipient is NULL ) then
 	l_NotifRecipient := xdp_utilities.GetSystemErrNotifRecipient;
 else
	l_NotifRecipient := p_NotifRecipient;
 end if;

 l_NotifID := wf_notification.Send(role => l_NotifRecipient,
			msg_type => xdp_utilities.pv_ErrorNotifItemType,
                        msg_name => XDP_ADAPTER_CORE.pv_AdapterTermFailure,
                        due_date =>sysdate);

 wf_notification.SetAttrText( nid    => l_NotifID,
                              aname  => 'ADAPTER_NAME',
                              avalue => p_AdapterName );

end NotifyAdapterTerminateFailure;

Procedure NotifyAdapterSysDeactivation (p_AdapterName in VARCHAR2,
			p_NotifRecipient IN VARCHAR2 DEFAULT NULL)
is
 l_NotifID number;
 l_NotifRecipient varchar2(80);
begin

 if ( p_notifRecipient is NULL ) then
 	l_NotifRecipient := xdp_utilities.GetSystemErrNotifRecipient;
 else
	l_NotifRecipient := p_NotifRecipient;
 end if;

 l_NotifID := wf_notification.Send(role => l_NotifRecipient,
			msg_type => xdp_utilities.pv_ErrorNotifItemType,
                        msg_name => XDP_ADAPTER_CORE.pv_AdapterSysDeactivated,
                        due_date =>sysdate);

 wf_notification.SetAttrText( nid    => l_NotifID,
                              aname  => 'ADAPTER_NAME',
                              avalue => p_AdapterName );

end NotifyAdapterSysDeactivation;

end XDP_ADAPTER_CORE;

/
