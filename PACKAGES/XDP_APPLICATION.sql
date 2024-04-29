--------------------------------------------------------
--  DDL for Package XDP_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_APPLICATION" AUTHID CURRENT_USER AS
/* $Header: XDPAADMS.pls 120.1 2005/06/15 21:48:06 appldev  $ */

/***************** Commented out - START - sacsharm - 11.5.6 *****

 e_TableException          EXCEPTION;
 e_ProcException           EXCEPTION;
 e_ProcExecException       EXCEPTION;
 e_LockUnavailException    EXCEPTION;
 e_InvalidRequestException EXCEPTION;
 e_ConnectExecException    EXCEPTION;
 e_DisconnExecException    EXCEPTION;
 e_GetFeConfigException    EXCEPTION;

 pv_AckTimeout number;

 x_ErrorID number;
 x_ErrCode number;
 x_ErrStr varchar2(800);
 x_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;

 Procedure CLEANUP_ADAPTER_PIPE (ChannelName  in  varchar2,
                           ErrCode   OUT NOCOPY number,
                           ErrStr    OUT NOCOPY varchar2);

 Procedure STOP_ADAPTER (ChannelName  in  varchar2,
                    Whomtostop in varchar2,
                    ErrCode   OUT NOCOPY number,
                    ErrStr    OUT NOCOPY varchar2);

 Procedure SUSPEND_ADAPTER (RequestID      in  number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure SUSPEND_ADAPTER  (ChannelName in varchar2,
                             FeName in varchar2,
                             FeID in number,
                             User in varchar2,
                             Freq in varchar2,
                             Reqdate in DATE,
                             RequestID in number,
                             Caller          in  varchar2,
                             ErrCode        OUT NOCOPY number,
                             ErrStr         OUT NOCOPY varchar2);

 Procedure RESUME_ADAPTER (RequestID      in  number,
                           Caller          in  varchar2,
                           ErrCode        OUT NOCOPY number,
                           ErrStr         OUT NOCOPY varchar2);

 Procedure RESUME_ADAPTER  (ChannelName in varchar2,
                        FeName in varchar2,
                        FeID in number,
                       User in varchar2,
                       Freq in varchar2,
                       Reqdate in DATE,
                       RequestID in number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure CONNECT_ADAPTER (RequestID      in  number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure CONNECT_ADAPTER (ChannelName in varchar2,
                        FeName in varchar2,
                        FeID in number,
                       User in varchar2,
                       Freq in varchar2,
                       Reqdate in DATE,
                       RequestID in number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure DISCONNECT_ADAPTER (RequestID      in  number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);


 Procedure DISCONNECT_ADAPTER (ChannelName in varchar2,
                        FeName in varchar2,
                        FeID in number,
                       User in varchar2,
                       Freq in varchar2,
                       Reqdate in DATE,
                       RequestID in number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure SHUTDOWN_ADAPTER (RequestID      in  number,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure SHUTDOWN_ADAPTER (ChannelName in varchar2,
                        FeName in varchar2,
                        FeID in number,
                       User in varchar2,
                       Freq in varchar2,
                       Reqdate in DATE,
                       RequestID in number,
                       ShutdownMode in varchar2 default 'N',
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure ADMINISTER_ADAPTER (RequestType in varchar2,
                               RequestID in number,
                               ErrCode OUT NOCOPY number,
                               ErrStr OUT NOCOPY varchar2);

Procedure STARTUP_ADAPTER (ChannelName in varchar2,
                           FeName in varchar2,
                           FeID in number,
                           AdapterName in varchar2,
                           AdapterUsageCode in varchar2,
                           AdapterStartupMode in varchar2,
                           AdapterDebugMode in varchar2,
                           User in varchar2,
                           Freq in varchar2,
                           Reqdate in DATE,
                           RequestID in number,
                           Caller          in  varchar2,
                           ErrCode        OUT NOCOPY number,
                           ErrStr         OUT NOCOPY varchar2);


 Procedure STARTUP_ADAPTER (RequestID      in  number,
                            Caller          in  varchar2,
                            ErrCode        OUT NOCOPY number,
                            ErrStr         OUT NOCOPY varchar2);

 Procedure STARTUP_NEW_ADAPTER (ChannelName in varchar2,
                        FeName in varchar2,
                        FeID in number,
                       AdapterName in varchar2,
                       AdapterUsageCode in varchar2,
                       AdapterStartupMode in varchar2,
                       AdapterDebugMode in varchar2,
                       Caller          in  varchar2,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);


 Procedure FTP_ADAPTER_FILE (RequestID      in  number,
                             Caller          in  varchar2,
                             ErrCode        OUT NOCOPY number,
                             ErrStr         OUT NOCOPY varchar2);

 Procedure FTP_ADAPTER_FILE  (ChannelName in varchar2,
                              FeName in varchar2,
                              FeID in number,
                              User in varchar2,
                              Freq in varchar2,
                              Reqdate in DATE,
                              RequestID in number,
                              Caller          in  varchar2,
                              ErrCode        OUT NOCOPY number,
                              ErrStr         OUT NOCOPY varchar2);

 Procedure GET_ADAPTER_INFO (RequestID     in  number,
                       ChannelName  OUT NOCOPY varchar2,
                       FeID        OUT NOCOPY number,
                       User           OUT NOCOPY varchar2,
                       Freq           OUT NOCOPY  number,
                       Reqdate       OUT NOCOPY  DATE,
                       ErrCode        OUT NOCOPY number,
                       ErrStr         OUT NOCOPY varchar2);

 Procedure LOCK_ADAPTER_REG_STATUS (ChannelName     in  varchar2,
                             ErrCode          OUT NOCOPY number,
                             ErrStr           OUT NOCOPY varchar2);

 Procedure UPDATE_ADAPTER_REG_STATUS (ChannelName     in  varchar2,
                               AdapterStatus    in  varchar2,
                               ErrCode          OUT NOCOPY number,
                               ErrStr           OUT NOCOPY varchar2);

 Procedure UPDATE_ADAPTER_REG_STATUS (ChannelName     in  varchar2,
                               AdapterStatus    in  varchar2,
			       AdapterErrCode in number,
			       AdapterErrDesc in varchar2,
                               ErrCode          OUT NOCOPY number,
                               ErrStr           OUT NOCOPY varchar2);

 Procedure UPDATE_ADAPTER_ADMIN_STATUS (RequestID        in  number,
                                 ChannelName     in  varchar2,
                                 FeID           in  number,
                                 Reqcode          in  varchar2,
                                 Reqstatus        in  varchar2,
                                 Reqdate          in  DATE,
                                 Reqby            in  varchar2,
                                 Freq              in  varchar2,
                                 ErrCode          OUT NOCOPY number,
                                 ErrStr           OUT NOCOPY varchar2);

 Procedure CHECK_FREQUENCY (ChannelName     in  varchar2,
                           FeID           in  number,
                           Request           in  varchar2,
                           Status            in  varchar2,
                           Freq              in  number,
                           User              in  varchar2,
                           ErrCode          OUT NOCOPY number,
                           ErrStr           OUT NOCOPY varchar2);

 Procedure GET_ADAPTER_STATUS (ChannelName   in  varchar2,
                               Status        OUT NOCOPY varchar2,
                               UsageCode     OUT NOCOPY varchar2,
                               ErrCode       OUT NOCOPY varchar2,
                               ErrStr        OUT NOCOPY varchar2);

 FUNCTION LOCK_ADAPTER_CTRL RETURN BOOLEAN;


Procedure SubmitControllerReq(errbuf OUT NOCOPY varchar2,
			      retcode OUT NOCOPY number,
                              DebugMode in varchar2,
			      ReqID OUT NOCOPY number);

Procedure SubmitControllerReq(errbuf OUT NOCOPY varchar2,
			      retcode OUT NOCOPY number);

Procedure VerifyController (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY number,
                            MaxTries in number,
                            Caller in varchar2 DEFAULT 'CONC_JOB');

Procedure RemoveDBJobs(retcode OUT NOCOPY number,
                       errbuf OUT NOCOPY varchar2,
                       What in varchar default 'ALL');

Procedure StartController(DebugMode in varchar2,
                          ControllerAlreadyRunningFlag OUT NOCOPY boolean,
                          errbuf OUT NOCOPY varchar2,
                          retcode OUT NOCOPY number);

Procedure CONTROLLER_RESUBMIT(errbuf OUT NOCOPY varchar2,
		             retcode OUT NOCOPY number);

 Procedure LockVerifyController
	(
	errbuf 			OUT NOCOPY VARCHAR2,
	retcode 		OUT NOCOPY NUMBER,
	IsControllerLocked 	OUT NOCOPY BOOLEAN,
	IsControllerDown 	OUT NOCOPY BOOLEAN,
	MaxTries 		IN  NUMBER DEFAULT 1,
	MaxTriesLock 		IN  NUMBER DEFAULT 1,
	Caller 			IN  VARCHAR2 DEFAULT 'NON_CONC_JOB'
	);

****************** Commented out - END - sacsharm - 11.5.6 ****/

Function Fetch_CPID(ConcQID in number, Caller in varchar2 default 'SERV') return number;

Procedure Fetch_ConcQ_Details (CPID in number,
				ConcQID OUT NOCOPY number,
				ConcQName OUT NOCOPY varchar2);

Function Submit_Svc_Ctl_Request (CPID in number, CtlCmd in varchar2) return number;

FUNCTION GET_COMPONENT_THREADS (p_service_params_str IN VARCHAR2,
                                p_tag IN VARCHAR2)
RETURN NUMBER;

 PROCEDURE XDP_STOP
	(
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	FeOptions	IN VARCHAR2,
	FeName		IN VARCHAR2,
	StopOptions	IN VARCHAR2
  	);


 PROCEDURE XDP_START
	(
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	FeOptions	IN VARCHAR2,
	FeName		IN VARCHAR2,
	DebugMode	IN VARCHAR2
  	);

Procedure XDP_CM_SHUTDOWN ;

  PROCEDURE FETCH_THREAD_CNT
         (
         svc_handle     IN VARCHAR2,
         num_of_threads OUT NOCOPY NUMBER
         );

--  *** Procedure to get counts for OAM console ****


PROCEDURE XDP_CONSOLE_COUNTS_FENGINE(
         p_order_threads              OUT NOCOPY    NUMBER
        ,p_order_current              OUT NOCOPY    NUMBER
        ,p_order_future               OUT NOCOPY    NUMBER
        ,p_order_exception            OUT NOCOPY    NUMBER
        ,p_order_inprogress           OUT NOCOPY    NUMBER
        ,p_order_inerror              OUT NOCOPY    NUMBER
        ,p_order_completed            OUT NOCOPY    NUMBER
        ,p_wi_threads                 OUT NOCOPY    NUMBER
        ,p_wi_current                 OUT NOCOPY    NUMBER
        ,p_wi_future                  OUT NOCOPY    NUMBER
        ,p_wi_exception               OUT NOCOPY    NUMBER
        ,p_wi_inprogress              OUT NOCOPY    NUMBER
        ,p_wi_inerror                 OUT NOCOPY    NUMBER
        ,p_wi_completed               OUT NOCOPY    NUMBER
        ,p_fa_threads                 OUT NOCOPY    NUMBER
        ,p_fa_current                 OUT NOCOPY    NUMBER
        ,p_fa_future                  OUT NOCOPY    NUMBER
        ,p_fa_exception               OUT NOCOPY    NUMBER
        ,p_fa_inprogress              OUT NOCOPY    NUMBER
        ,p_fa_inerror                 OUT NOCOPY    NUMBER
        ,p_fa_completed               OUT NOCOPY    NUMBER
        ,p_fa_ready_current           OUT NOCOPY    NUMBER
        ,p_fa_ready_future            OUT NOCOPY    NUMBER
        ,p_fa_ready_exception         OUT NOCOPY    NUMBER
        ,p_timer_threads              OUT NOCOPY    NUMBER
        ,p_timer_current              OUT NOCOPY    NUMBER
        ,p_timer_future               OUT NOCOPY    NUMBER
        ,p_timer_exception            OUT NOCOPY    NUMBER
        ,p_timer_inprogress           OUT NOCOPY    NUMBER
        ,p_timer_completed            OUT NOCOPY    NUMBER
        ,p_event_threads              OUT NOCOPY    NUMBER
        ,p_event_current              OUT NOCOPY    NUMBER
        ,p_event_future               OUT NOCOPY    NUMBER
        ,p_event_exception            OUT NOCOPY    NUMBER
        ,p_event_inprogress           OUT NOCOPY    NUMBER
        ,p_event_inerror              OUT NOCOPY    NUMBER
        ,p_event_completed            OUT NOCOPY    NUMBER
        ,p_in_threads                 OUT NOCOPY    NUMBER
        ,p_in_current                 OUT NOCOPY    NUMBER
        ,p_in_future                  OUT NOCOPY    NUMBER
        ,p_in_exception               OUT NOCOPY    NUMBER
        ,p_in_inprogress              OUT NOCOPY    NUMBER
        ,p_in_inerror                 OUT NOCOPY    NUMBER
        ,p_in_completed               OUT NOCOPY    NUMBER
        ,p_out_current                OUT NOCOPY    NUMBER
        ,p_out_exception              OUT NOCOPY    NUMBER
        ,p_out_inprogress             OUT NOCOPY    NUMBER
        ,p_out_inerror                OUT NOCOPY    NUMBER
        ,p_out_completed              OUT NOCOPY    NUMBER
        );


END XDP_APPLICATION;

 

/
