--------------------------------------------------------
--  DDL for Package XDP_PROC_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PROC_CTL" AUTHID CURRENT_USER AS
/* $Header: XDPPCTLS.pls 120.1 2005/06/22 06:48:22 appldev ship $ */


 e_ParamValueException           EXCEPTION;
 e_ProcExecException             EXCEPTION;

 e_UnhandledException 		EXCEPTION;
 e_PipeSendAckException         EXCEPTION;
 e_PipeWaitForAckException     EXCEPTION;
 e_PipeWaitForMesgException    EXCEPTION;
 e_PipeSendMesgException        EXCEPTION;
 e_PipePackMesgException        EXCEPTION;
 e_PipeUnpackMesgException      EXCEPTION;
 e_NeWarningException            EXCEPTION;
 e_NeFailureException            EXCEPTION;
 e_NeSessionLostException            EXCEPTION;
 e_NeTimedOutException            EXCEPTION;
 e_PipeOutOfSyncException      EXCEPTION;

--  x_progress       varchar2(32767);

 pv_FeName  varchar2(80);
 pv_FeID            number;
 pv_FeType           varchar2(80);
 pv_FeTypeID        number;
 pv_SWGeneric       varchar2(80);
 pv_AdapterType       varchar2(80);

 pv_AckTimeout   number;
 pv_MesgTimeout  number;

 pv_ack_conn_timeout                   number;
 pv_cmd_conn_timeout                   number;

 pv_DirtyBit BOOLEAN;

 pv_debug_mode varchar2(10);

-- Connect Command/Response
  TYPE CONNECT_CMD IS RECORD
  (
    COMMAND VARCHAR2(32767),
    RESPONSE VARCHAR2(32767));

-- list of the order parameter
  TYPE CONNECT_CMD_LIST IS TABLE OF CONNECT_CMD
	 INDEX BY BINARY_INTEGER;

  pv_ConnectCommands CONNECT_CMD_LIST;

  pv_CommandTimeout number;


  pv_attrFeCmdTimeout	varchar2(80) := 'NE_CMD_TIMEOUT';
  pv_attrFeRetryCount	varchar2(80) := 'NE_CMD_RETRY_COUNT';
  pv_attrFeCmdRetryWait	varchar2(80) := 'NE_CMD_WAIT';
  pv_attrFeNoActTimeout	varchar2(80) := 'NE_NO_ACTIVITY_TIMEOUT';
  pv_attrFeCmdKeepAlive	varchar2(80) := 'NE_DUMMY_CMD';

  pv_attrFeConnRetryCount varchar2(80) := 'NE_CONNECT_RETRY_COUNT';
  pv_attrFeConnRetryWait varchar2(80) := 'NE_CONNECT_WAIT';

/* DEBUG: */
 x_dbg_progress    varchar2(32767);


/* These set of procedures/Functions is for the PROVISIONING PROCEDURE,
   Generation, execution
*/

 Procedure CHECK_FOR_OLD_PARAM (Param  in   varchar2,
                                ParamMinusOld  OUT NOCOPY  varchar2,
                                OldFlag   OUT NOCOPY  number);

Procedure CHECK_PARAM_NAME (WorkitemID in number,
                            FAId in number,
                            ParamType in varchar2,
                            Param  in  varchar2,
                            ErrCode OUT NOCOPY number,
                            ErrStr OUT NOCOPY varchar2);

 Procedure FIND_PARAMETERS (FAID in number,
                            WorkitemID number,
                            Str in varchar2,
                            ErrCode OUT NOCOPY varchar2,
                            ErrStr  OUT NOCOPY varchar2);

 Procedure GET_PARAMETER_VALUE (OrderID in number,
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
                                ErrStr OUT NOCOPY varchar2);

 Procedure FIND_REPLACE_PARAMS (OrderID in number,
                                LineItemID in number,
                                WorkiteminstanceID in number,
                                FAinstanceID in number,
                                Str in varchar2,
                                CmdStr OUT NOCOPY varchar2,
                                LogFlag OUT NOCOPY number,
                                LogStr  OUT NOCOPY varchar2,
                                ErrCode OUT NOCOPY varchar2,
                                ErrStr  OUT NOCOPY varchar2);


 Procedure GENERATE_PROC (ProcName   in  varchar2,
                          ProcStr         in  varchar2,
                          CompiledProc OUT NOCOPY varchar2,
                          ErrCode    OUT NOCOPY number,
                          ErrStr     OUT NOCOPY varchar2);

 Procedure SHOW_PROC_ERRORS (ProcName   in  varchar2,
                             ErrCode    OUT NOCOPY number,
                             Errors     OUT NOCOPY varchar2);

 Function GET_UNIQUE_CHANNEL_NAME (Name in varchar2) return varchar2;

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
                                    ErrStr OUT NOCOPY varchar2);

 Procedure SEND_ACK (ChannelName  in  varchar2,
                     Timeout    in  number,
                     ErrCode   OUT NOCOPY number,
                     ErrStr    OUT NOCOPY varchar2);

  Procedure WAIT_FOR_MESSAGE (ChannelName  in  varchar2,
                              Timeout    in  number,
                              Message    OUT NOCOPY varchar2,
                              ErrCode   OUT NOCOPY number,
                              ErrStr    OUT NOCOPY varchar2);


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
                ErrStr OUT NOCOPY varchar2);

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
                ErrStr OUT NOCOPY varchar2);

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
                      ErrStr OUT NOCOPY varchar2);

 Procedure NOTIFY_ERROR (ResponseStr  in  varchar2,
                         ErrCode      OUT NOCOPY number,
                         ErrStr       OUT NOCOPY varchar2,
                         UserStr      in  varchar2,
                         LogFlag      in  varchar2);

 Function RESPONSE_CONTAINS (string1 in varchar2,
                             string2 in varchar2) return BOOLEAN;

 Function GET_RESPONSE (ResponseStr in varchar2) return varchar2;

 Function GET_PARAM_VALUE (OrderID in number,
                           LineItemID in number,
                           WIInstanceID in  number,
                           FAInstanceID in number,
                           ParamName  in  varchar2) return varchar2;


-- OLD ONE WILL BE DEPRECATED SOON...
Procedure SEND_SYNC ( ChannelName     in  varchar2,
                      ErrCode      OUT NOCOPY number,
                      ErrStr       OUT NOCOPY varchar2);

 Procedure SEND_SYNC (ChannelName  in  varchar2,
		      Fename 	   in varchar2,
                      ErrCode      OUT NOCOPY number,
                      ErrStr       OUT NOCOPY varchar2);

/*

  End of PROVISIONING Procedure Related stuff
*/



/* These set of procedures/Functions is for the CONNECT/DISCONNECT PROCEDURE,
   Generation, execution
*/

 PROCEDURE CHECK_CONNECT_PARAM_NAME (FeTypeID    in  number,
                                     Param        in  varchar2,
                                     ErrCode     OUT NOCOPY number,
                                     ErrStr      OUT NOCOPY varchar2);


 PROCEDURE FIND_CONNECT_PARAMETERS (FeTypeID in  number,
                                    ConnectStr in  varchar2,
                                    ErrCode OUT NOCOPY varchar2,
                                    ErrStr OUT NOCOPY varchar2);



 PROCEDURE FIND_REPLACE_CONNECT_PARAMS (FeName in varchar2,
                                       ConnectStr           in  varchar2,
                                       ActualStr           OUT NOCOPY varchar2,
                                       ErrCode      OUT NOCOPY varchar2,
                                       ErrStr       OUT NOCOPY varchar2);

 PROCEDURE GENERATE_CONNECT_PROC (ProcName   in  varchar2,
                                  ProcBody in  varchar2,
                                  CompiledProc OUT NOCOPY varchar2,
                                  ErrCode OUT NOCOPY number,
                                  ErrStr OUT NOCOPY varchar2);

 PROCEDURE GENERATE_DISCONNECT_PROC (ProcName   in  varchar2,
                                     ProcBody         in  varchar2,
                                     CompiledProc OUT NOCOPY varchar2,
                                     ErrCode    OUT NOCOPY number,
                                     ErrStr     OUT NOCOPY varchar2);

 PROCEDURE GET_FE_PREFERENCES (FeName        in  varchar2,
                               CmdTimeout    OUT NOCOPY number,
                               CmdRetryCount  OUT NOCOPY number,
                               CmdWait       OUT NOCOPY number,
                               NOActTimeout OUT NOCOPY number,
                               DummyCmd      OUT NOCOPY varchar2,
                               ConnectRetryCount OUT NOCOPY number,
                               ConnectRetryWait OUT NOCOPY number,
                               ErrCode       OUT NOCOPY number,
                               ErrStr        OUT NOCOPY varchar2);

 PROCEDURE SEND_CONNECT (FeName      in  varchar2,
                 ChannelName in  varchar2,
                 ProcName    in  varchar2,
                 Response     OUT NOCOPY varchar2,
                 sdp_internal_err_code OUT NOCOPY number,
                 sdp_internal_err_str OUT NOCOPY varchar2,
                 CmdStr      in  varchar2,
                 Prompt       in  varchar2 ,
                 ErrCode OUT NOCOPY number,
                 ErrStr OUT NOCOPY varchar2);

 PROCEDURE SEND_CONNECT (FeName      in  varchar2,
                 ChannelName in  varchar2,
                 ProcName    in  varchar2,
                 Response     OUT NOCOPY varchar2,
                 sdp_internal_err_code OUT NOCOPY number,
                 sdp_internal_err_str OUT NOCOPY varchar2,
                 CmdStr      in  varchar2,
                 ErrCode OUT NOCOPY number,
                 ErrStr OUT NOCOPY varchar2);


 PROCEDURE RESET_BUFFER;

 PROCEDURE FETCH_CONNECT_COMMANDS(CurrIndex in number,
				  TotalCount OUT NOCOPY number,
				  Command OUT NOCOPY varchar2,
				  Response OUT NOCOPY varchar2);

END XDP_PROC_CTL;

 

/
