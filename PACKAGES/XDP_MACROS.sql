--------------------------------------------------------
--  DDL for Package XDP_MACROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_MACROS" AUTHID CURRENT_USER AS
/* $Header: XDPMACRS.pls 120.1 2005/06/16 01:41:52 appldev  $ */


e_AdapterNotUpException exception;
e_CommandTimedoutException exception;
e_SessionLostException exception;
e_FEFailureException exception;
e_NotifyError exception;

g_NotifyError number := -666;
g_CommandTimeout number := -20620;
g_SessionLost number := -20610;
g_FeFailure number := -20300;


-- New for 11.5.6+
 pv_OrderID number;
 pv_LineItemID number;
 pv_WorkItemInstanceID number;
 pv_FAInstanceID number;
 pv_ChannelName varchar2(40);
 pv_ApplChannelName varchar2(40);
 pv_ReturnChannelName varchar2(40);
 pv_ProcName varchar2(80);
 SFM_SQLCODE number;
 SFM_SQLERRM varchar2(4000);
 SFM_int_response_buffer varchar2(32767);
 pv_ResponseLob	CLOB;
 pv_ResponseLongLob	CLOB;
 pv_AutoRetry	number := 0;

 pv_ParamCacheReqd varchar2(1) := 'N';

 pv_WIParamUsed boolean := false;
 pv_OrderParamUsed boolean := false;
 pv_LineParamUsed boolean := false;
 pv_FAParamUsed boolean := false;

 pv_FeName  varchar2(80);
 pv_FeID            number;
 pv_FeType           varchar2(80);
 pv_FeTypeID        number;
 pv_SWGeneric       varchar2(80);
 pv_AdapterType       varchar2(80);
 pv_AdapterImplemented   boolean := false;

 pv_AckTimeout number;
 pv_MesgTimeout number;
 pv_defMesgTimeout number := 120;

-- Connect Command/Response
  TYPE G_CONNECT_CMD IS RECORD
  (
    COMMAND VARCHAR2(32767),
    RESPONSE VARCHAR2(32767));

-- list of the order parameter
  TYPE G_CONNECT_CMD_LIST IS TABLE OF G_CONNECT_CMD
	 INDEX BY BINARY_INTEGER;

  g_ConnectCommands G_CONNECT_CMD_LIST;


  pv_attrFeCmdTimeout	varchar2(80) := 'NE_CMD_TIMEOUT';
  pv_attrFeRetryCount	varchar2(80) := 'NE_CMD_RETRY_COUNT';
  pv_attrFeCmdRetryWait	varchar2(80) := 'NE_CMD_WAIT';
  pv_attrFeNoActTimeout	varchar2(80) := 'NE_NO_ACTIVITY_TIMEOUT';
  pv_attrFeCmdKeepAlive	varchar2(80) := 'NE_DUMMY_CMD';

  pv_attrFeConnRetryCount varchar2(80) := 'NE_CONNECT_RETRY_COUNT';
  pv_attrFeConnRetryWait varchar2(80) := 'NE_CONNECT_WAIT';

  pv_defFeCmdTimeout	number := 120;
  pv_defFeRetryCount	number := 0;
  pv_defFeCmdRetryWait  number := 0;
  pv_defFeNoActTimeout	number := 120;
  pv_defFeCmdKeepAlive	varchar2(80) := ' ';

  pv_defFeConnRetryCount number := 0;
  pv_defFeConnRetryWait number := 0;

Procedure SEND_SYNC;

Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       p_Prompt in varchar2 default 'IGNORE');

--
-- For Backward Compatibility...

Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       p_Prompt in varchar2 default 'IGNORE',
	       x_ErrorCode OUT NOCOPY number,
	       x_ErrorString OUT NOCOPY varchar2);

Procedure SEND(p_Command in varchar2,
	       p_EncryptFlag in varchar2 default 'N',
	       x_ErrorCode OUT NOCOPY number,
	       x_ErrorString OUT NOCOPY varchar2);

Procedure SEND_HTTP(p_URL in varchar2,
	       	    p_EncryptFlag in varchar2 default 'N',
		    p_Proxy in varchar2 default null);

Procedure SEND_HTTP(p_URL in varchar2,
	       	    p_EncryptFlag in varchar2 default 'N',
		    x_ErrorCode OUT NOCOPY number,
		    x_ErrorString OUT NOCOPY varchar2);

Function GET_RESPONSE return varchar2;

Function GET_PARAM_VALUE(p_ParamName in varchar2) return varchar2;

Function GET_ATTR_VALUE(p_AttrName in varchar2) return varchar2;

Procedure NOTIFY_ERROR(p_UserMessage in varchar2,
		       p_Overwrite in varchar2);

Procedure NOTIFY_ERROR(p_UserMessage in varchar2,
		       p_AutomaticRetry in number default 0);

Function RESPONSE_CONTAINS(p_UserString in varchar2) return boolean;

-- New for 11.5.6+
Function GET_LONG_RESPONSE return CLOB;

Procedure AUDIT(p_AuditString in varchar2);

Function AUTO_RETRY_ENABLED return varchar2;

Procedure SEND_CONNECT( p_Command in varchar2,
	       		p_Prompt in varchar2 default 'IGNORE');

-- For backward compatibility
Procedure SEND_CONNECT( p_Command in varchar2,
	       		p_Prompt in varchar2 default 'IGNORE',
			x_ErrorCode OUT NOCOPY number,
			x_ErrorString OUT NOCOPY varchar2);

Procedure AppendConnectCommands(p_Command in varchar2,
				p_Response in varchar2);

PROCEDURE FETCH_CONNECT_COMMANDS(p_CurrIndex in number,
				 x_TotalCount OUT NOCOPY number,
				 x_Command OUT NOCOPY varchar2,
				 x_Response OUT NOCOPY varchar2);

Procedure ResetCommandBuffer;


-- Routines for Initialization etc..

Procedure Initdefault(  OrderID in number,
			LineItemID in number,
			WIInstanceID in number,
			FAInstanceID in number);

Procedure InitFP(OrderID in number,
                 LineItemID in number,
                 WIInstanceID in number,
                 FAInstanceID in number,
                 ChannelName in  varchar2,
                 FEName in varchar2,
                 ProcName in  varchar2);

Procedure InitConnection(ChannelName in  varchar2,
                         FEName in varchar2);

Procedure InitDisconnection(ChannelName in  varchar2,
			    FEName in varchar2);

Procedure EndProc(p_return_code in OUT NOCOPY number,
		  p_error_description in OUT NOCOPY varchar2);

Procedure HandleProcErrors(p_return_code OUT NOCOPY number,
                           p_error_description OUT NOCOPY varchar2);

end XDP_MACROS;

 

/
