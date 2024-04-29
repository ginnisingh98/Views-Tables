--------------------------------------------------------
--  DDL for Package XDP_ADAPTER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER_CORE" AUTHID CURRENT_USER AS
/* $Header: XDPACORS.pls 120.1 2005/06/15 21:50:52 appldev  $ */

e_ReceiveTimedOut exception;
e_ReceiveOtherError exception;

e_AdapterWarningException exception;
e_AdapterErrorException exception;

pv_DefTimeout number := 120;

pv_DBMSPipeTimeoutError number := 1;
g_AdapterTimeout number := -20620;
g_AdapterSessionLost number := -20610;

pv_AdapterResponseSuccess VARCHAR2(30) 	:= 'SUCCESS';
pv_AdapterResponseFailure VARCHAR2(30) 	:= 'FAILURE';

pv_ProcessCommandTimedout VARCHAR2(30) 	:= 'TIMEOUT';
pv_ProcessCommandError VARCHAR2(30) 	:= 'ERROR';

pv_AdapterTermFailure varchar2(40) 		:= 'ADAPTER_TERM_FAILURE';
pv_AdapterSysDeactivated varchar2(40) 		:= 'ADAPTER_SYS_DEACTIVATED';

-- Send a SYNC Control Message to the Adapter
-- The Procedure waits for an ACK
Procedure SendSync( p_ChannelName in varchar2,
		    p_CleanupPipe in varchar2 default 'Y');

-- Send a Response to the Adapter
-- The Response sent is an XML message of the type RESPONSE
-- The Procedure does NOT wait for an ACK
Procedure SendResponse(p_ChannelName in varchar2,
		       p_Status in varchar2,
		       p_Message in varchar2);
-- Send the ACK Response
Procedure SendAck(p_ChannelName in varchar2);

-- Send any Control Command to the adapter
-- The Control Command XML is constructed and sent
-- The Procedure waits for an ACK
Procedure SendControlCommand(	p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData   in varchar2 default null);

-- Send any Control Command to the adapter
-- The Control Command XML is constructed and sent
-- The Procedure waits for an ACK This procedure is same as the previous
-- Procedure except that the procedure returns a timeout value to wait for
-- for any response from the Adapter.

Procedure SendControlCommand(	p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData in varchar2 default null,
				p_Timeout OUT NOCOPY number);

-- Process any Control Command to the adapter
-- The Control Command XML is constructed and sent
-- The Procedure waits for an ACK
-- Once the ACK is received the routine waits for the control command
-- to be processed by the adapter;
Procedure ProcessControlCommand(p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_OpData in varchar2 default null,
				p_Status OUT NOCOPY varchar2,
				p_ErrorMessage OUT NOCOPY varchar2);

-- Perform the two way communication with the adapter.
-- Send a control command and wait for an ACK.
Procedure TalkToAdapter(p_ChannelName in varchar2,
		     	p_Command in varchar2);

-- Send an Application Message.
-- Data in the users SEND Constuct in the FP will be the sent in an XML
-- Format
-- The Procedure Waits for an ACK
Procedure SendApplicationMessage(p_ChannelName in varchar2,
				 p_Command in varchar2,
				 p_Response in varchar2);

-- Wait for an ACK from the other party
Procedure ReceiveAck(p_ChannelName in varchar2,
		     p_Status OUT NOCOPY varchar2,
		     p_ErrorMessage OUT NOCOPY varchar2);

Procedure SendMessage(	p_ChannelName in varchar2,
			p_Command in varchar2);

Procedure WaitForMessage(p_ChannelName  in varchar2,
			 p_Timeout in number,
			 p_ResponseMessage OUT NOCOPY varchar2);

Function VerifyAdapterOperation(p_ChannelName in varchar2,
				p_Operation in varchar2,
				p_CurrentStatus OUT NOCOPY varchar2)  return boolean;

Function ShouldAdapterConnect(p_ChannelName in varchar2) return varchar2;

-- Send Notification to inform that the Adapter could not be terminated
Procedure NotifyAdapterTerminateFailure (p_AdapterName in VARCHAR2,
			p_NotifRecipient IN VARCHAR2 DEFAULT NULL);

-- Send Notification to inform that the Adapter has been deactivated by System
Procedure NotifyAdapterSysDeactivation (p_AdapterName in VARCHAR2,
			p_NotifRecipient IN VARCHAR2 DEFAULT NULL);

END XDP_ADAPTER_CORE;

 

/
