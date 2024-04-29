--------------------------------------------------------
--  DDL for Package XDP_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER" AUTHID CURRENT_USER AS
/* $Header: XDPADBOS.pls 120.1 2005/06/08 23:40:12 appldev  $ */

 pv_SMParamDelimiter varchar2(1) 	:= ':';
 pv_SMParamSpace varchar2(1) 		:= ' ';
 pv_logFileExtension varchar2(4)        := '.log';

 -- TODO Statuses to be changed - sacsharm
 -- pv_statusRunning varchar2(30) 	:= 'RUNNING';
 -- pv_statusInUse varchar2(30) 	:= 'IN-USE';
 -- pv_statusStopped varchar2(30) 	:= 'STOPPED';
 -- pv_statusStarting varchar2(30) 	:= 'STARTING';
 -- pv_statusSuspending varchar2(30) 	:= 'SUSPENDING';
 -- pv_statusDisconnecting varchar2(30) := 'DISCONNECTING';
 -- pv_statusStopping varchar2(30) 	:= 'STOPPING';

 pv_statusRunning varchar2(30) 		:= 'IDLE';
 pv_statusInUse varchar2(30) 		:= 'BUSY';
 pv_statusStopped varchar2(30) 		:= 'SHUTDOWN';
 pv_statusStarting varchar2(30) 	:= 'STARTING UP';
 pv_statusSuspending varchar2(30) 	:= 'MARKED FOR SUSPEND';
 pv_statusDisconnecting varchar2(30) 	:= 'MARKED FOR DISCONNECT';
 pv_statusStopping varchar2(30) 	:= 'MARKED FOR SHUTDOWN';

 -- Statuses - no changes
 pv_statusSuspended varchar2(30) 	:= 'SUSPENDED';
 pv_statusDisconnected varchar2(30) 	:= 'DISCONNECTED';
 pv_statusError varchar2(30) 		:= 'ERROR';
 pv_statusSessionLost varchar2(30) 	:= 'SESSION_LOST';
 pv_statusReconnecting varchar2(30) 	:= 'RECONNECTING';

 -- New statuses 11.5.6
 pv_statusConnecting varchar2(30) 	:= 'CONNECTING';
 pv_statusTerminating varchar2(30) 	:= 'TERMINATING';
 pv_statusResuming varchar2(30) 	:= 'RESUMING';
 pv_statusNotAvailable varchar2(30) 	:= 'NOT_AVAILABLE';

-- New statuses 11.5.6.1
pv_statusStoppedError varchar2(30) 	:= 'SHUTDOWN_ERROR';
pv_statusTerminated varchar2(30)	:= 'TERMINATED';

-- New statuses 11.5.7G
 pv_statusDeactivated varchar2(30) 	:= 'DEACTIVATED';
 pv_statusDeactivatedSystem varchar2(30):= 'DEACTIVATED_SYSTEM';

 pv_startAutomatic varchar2(30) 	:= 'AUTOMATIC';
 pv_startManual varchar2(30) 		:= 'MANUAL';
 pv_startDisabled varchar2(30) 		:= 'DISABLED';

-- New Startup modes 11.5.7G
 pv_startGroup varchar2(30) 		:= 'GROUP';
 pv_startOnDemand varchar2(30) 		:= 'START_ON_DEMAND';

 pv_opStartup varchar2(30) 		:= 'STARTUP';
 pv_opStop varchar2(30) 		:= 'SHUTDOWN';
 pv_opConnect varchar2(30) 		:= 'OPEN';
 pv_opDisconnect varchar2(30) 		:= 'CLOSE';
 pv_opSuspend varchar2(30) 		:= 'SUSPEND';
 pv_opResume varchar2(30) 		:= 'RESUME';
 pv_opFtpFile varchar2(30) 		:= 'FTP_FILE';
 pv_opVerify varchar2(30) 		:= 'VERIFY';
 pv_opTerminate varchar2(30) 		:= 'TERMINATE';

 pv_opDelete varchar2(30) 		:= 'DELETE';
 pv_opUpdate varchar2(30) 		:= 'UPDATE';
 pv_opGeneric varchar2(30) 		:= 'GENERIC';

 -- Added - sacsharm
 pv_AppID number 			:= 535;

 --pv_retAdapterAsyncParamWrong number	:= 197020;
 pv_retAdapterImplParamWrong number	:= 197021;
 pv_retAdapterConnParamWrong number	:= 197022;
 pv_retAdapterInboundParamWrong number	:= 197024;
 pv_retAdapterCannotLock number 	:= 191392;
 pv_retAdapterCannotLockReqSub number	:= 191405;
 pv_retAdapterInvalidState number 	:= 191395;
 pv_retAdapterOpFailed number 		:= 191394;
 pv_retAdapterCommFailed number		:= 191407;
 pv_retAdapterCtrlNotRunning number 	:= 191396;
 pv_retAdapterOtherError number 	:= 20001;
 pv_retAdapterMaxNumReached number 	:= 191194;
 pv_retAdapterInvalidReqDate number	:= 191236;
 pv_retFEAdapterRunning number		:= 191171;
 pv_retAdapterNoGenExists number	:= 197012;
 pv_retAdapterConfigNA number           := 197013;
 pv_retAdapterAbnormalExit number       := 191107;
 pv_retAdapterPipeError number		:= 197029;

 pv_AdapterTimeOut number 		:= -20620;
 pv_AdapterSessionLost number		:= -20610;
 pv_AdapterFailure number 		:= -20300;
 pv_AdapterWarning number 		:= -20500;

 --pv_adminStatusPending varchar2(30) 	:= 'PENDING';
 pv_adminStatusCompleted varchar2(30) 	:= 'COMPLETED';
 pv_adminStatusSkipped varchar2(30) 	:= 'SKIPPED';
 -- TODO Change to ERRORED
 pv_adminStatusErrored varchar2(30) 	:= 'ERROR';

 pv_adminReqBySystem varchar2(30) 	:= 'SYSTEM';

 pv_errorObjectTypeAdapter varchar2(30)	:= 'ADAPTER';

 pv_AdapterExitCode			varchar2(40);

 pv_callerContextUser varchar2(30)	:= 'USER';
 pv_callerContextAdmin varchar2(30)	:= 'ADMIN';
 pv_callerContext varchar2(30)		:= pv_CallerContextUser;

 pv_applModeQueue varchar2(30) 		:= 'QUEUE';
 pv_applModePipe varchar2(30) 		:= 'PIPE';
 pv_applModeNone varchar2(30) 		:= 'NONE';

 -- Added end - sacsharm

  --Added - mviswana
 pv_rolledStatusError  varchar2(30)      := 'ROLLED_STATUS_ERROR';
 pv_rolledStatusRunning varchar2(30)     := 'ROLLED_STATUS_RUNNING';
 pv_rolledStatusUnavailable varchar2(30) := 'ROLLED_STATUS_UNAVAILABLE';
  --Added end -mviswana

 e_OperationFailure  	EXCEPTION;
 e_OperationError  	EXCEPTION;
 e_InvalidAdapterState  EXCEPTION;
 e_UnabletoLockAdapter  EXCEPTION;
 e_ControllerNotRunning EXCEPTION;

-- Start of comments
--	API name	: Create_Adapter
--	Type		: Private
--	Purpose		: Creates a new adapter in the registration table
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_FeName		VARCHAR2 	Required
--				The name of the fulfillment element for	which
--				this adapter is being created
--			  p_AdapterType		VARCHAR2	Required
--				The type of communication between SFM and the
--				fulfillment element.
--			  p_AdapterName 	VARCHAR2	Required
--				The adapter's consumer name, which only
--				applies with a usage mode of messaging.
--			  p_AdapterDispName	VARCHAR2	Required
--				The adapter's display name
--			  p_ConcQID		NUMBER		Required
--				The ID of the concurrent queue, the controller
-- 				that spawns the adapter instance
--			  p_startupMode	VARCHAR2	Optional
--				The startup mode which defines the adapter's
-- 				behavior when the SFM app
--			  p_UsageCode 		VARCHAR2	Optional
--				The usage mode which identifies a specific
-- 				use for the adapter
--			  p_LogLevel		VARCHAR2	Optional
--				The log level indicates the amount of
-- 				information to write to the adapter log file
--			  p_CODFlag		VARCHAR2	Optional
--				The connect on demand flag.  When this flag is
-- 				enabled, the connection between SFM and the
-- 				fulfillment element is established only when
-- 				there are orders to be processed
--			  p_MaxIdleTime		NUMBER		Optional
--				If the COD flag is enabled, this is the number
-- 				of minutes the adapter instance remains
-- 				connected to the remote system after there are
--				no more orders
--				to be processed
--			  p_LogFileName		VARCHAR2	Optional
--				The name of the file where log messages for
--				the adapter instances are written
--			  p_SeqINFE		NUMBER		Optional
--				The order in which the adapter instance	is
-- 				accessed when multiple adapter instances are
--				running for the same
--				fulfillment element
--			  p_CmdLineOpts		VARCHAR2	Optional
--				User defined command line options for the
-- 				adapter program
--			  p_CmdLineArgs		VARCHAR2	Optional
--			 	User defined command line arguments for	the
-- 				adapter program.  Only static values can be
--				passed as initialization args
--
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
 Procedure Create_Adapter(p_FeName in varchar2,
			    p_AdapterType in varchar2,
			    p_AdapterName in varchar2 default NULL,
			    p_AdapterDispName in varchar2,
			    p_ConcQID in number,
			    p_StartupMode in varchar2 default 'MANUAL',
			    p_UsageCode in varchar2 default 'NORMAL',
			    p_LogLevel in varchar2 default 'ERROR',
			    p_CODFlag in varchar2 default 'N',
			    p_MaxIdleTime in number default 0,
			    p_LogFileName in varchar2 default NULL,
			    p_SeqInFE in number default null,
			    p_CmdLineOpts in varchar2 default NULL,
                            p_CmdLineArgs in varchar2 default NULL,
			    p_retcode	OUT NOCOPY NUMBER,
			    p_errbuf	OUT NOCOPY VARCHAR2
			);

-- ************* Added - sacsharm - START *****************************

-- Start of comments
--	API name	: Update_Adapter
--	Type		: Private
--	Purpose		: Updates an adapter
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName		VARCHAR2 	Required
--				Internally generated and unique name used by
--				the adapter instance to communicate with SFM
--			  p_AdapterName	VARCHAR2	Required
--			  p_AdapterDispName	VARCHAR2	Required
--			  p_ConcQID		NUMBER		Required
--				The ID of the concurrent queue, the controller
-- 				that spawns the adapter instance
--			  p_startupMode		VARCHAR2	Optional
--				The startup mode which defines the adapter's
-- 				behavior when the SFM app
--			  p_UsageCode 		VARCHAR2	Optional
--				The usage mode which identifies a specific
-- 				use for the adapter
--			  p_LogLevel		VARCHAR2	Optional
--				The log level indicates the amount of
-- 				information to write to the adapter log file
--			  p_CODFlag		VARCHAR2	Optional
--				The connect on demand flag.  When this flag is
-- 				enabled, the connection between SFM and the
-- 				fulfillment element is established only when
-- 				there are orders to be processed
--			  p_MaxIdleTime		NUMBER		Optional
--				If the COD flag is enabled, this is the number
-- 				of minutes the adapter instance remains
-- 				connected to the remote system after there are
--				no more orders
--				to be processed
--			  p_LogFileName		VARCHAR2	Optional
--				The name of the file where log messages for
--				the adapter instances are written
--			  p_SeqINFE		NUMBER		Optional
--				The order in which the adapter instance	is
-- 				accessed when multiple adapter instances are
--				running for the same
--				fulfillment element
--			  p_CmdLineOpts		VARCHAR2	Optional
--				User defined command line options for the
-- 				adapter program
--			  p_CmdLineArgs		VARCHAR2	Optional
--			 	User defined command line arguments for	the
-- 				adapter program.  Only static values can be
--				passed as initialization args
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version 	: Current version	11.5
--	Notes		: None
--
--
-- End of comments
Procedure Update_Adapter(p_ChannelName in varchar2,
			    p_AdapterName in varchar2,
			    p_AdapterDispName in varchar2,
			    p_ConcQID in number,
			    p_StartupMode in varchar2 default 'MANUAL',
			    p_UsageCode in varchar2 default 'NORMAL',
			    p_LogLevel in varchar2 default 'ERROR',
			    p_CODFlag in varchar2 default 'N',
			    p_MaxIdleTime in number default 0,
			    p_LogFileName in varchar2 default NULL,
			    p_SeqInFE in number default null,
			    p_CmdLineOpts in varchar2 default NULL,
                            p_CmdLineArgs in varchar2 default NULL,
			    p_retcode	OUT NOCOPY NUMBER,
			    p_errbuf	OUT NOCOPY VARCHAR2
			);

-- Start of comments
--	API name	: Delete_Adapter
--	Type		: Private
--	Purpose		: Deletes an adapter
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName		VARCHAR2 	Required
--				Internally generated and unique name for the
--				adapter to be deleted
--
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
PROCEDURE Delete_Adapter (p_ChannelName IN VARCHAR2,
			  p_retcode	OUT NOCOPY NUMBER,
			  p_errbuf	OUT NOCOPY VARCHAR2
			  );

-- Start of comments
--	API name	: Delete_All_For_FE
--	Type		: Private
--	Purpose		: Deletes all adapters for an fulfillment element
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_FeName		VARCHAR2 	Required
--				The name of the fulfillment element for whom
--				all adapters will be deleted
--
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf:  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
PROCEDURE Delete_All_For_FE (p_FeName IN VARCHAR2,
			  	  p_retcode	OUT NOCOPY NUMBER,
				  p_errbuf	OUT NOCOPY VARCHAR2
				);


-- Start of comments
--	API name	: Generic_Operation
--	Type		: Group
--	Purpose		: Runs the specified operation
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName	VARCHAR2 	Required
--				Internally generated and unique name for the
--				adapter
--			  p_OperationName	VARCHAR2	Required
--			  p_OperationParam 	VARCHAR2	Optional
--
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
PROCEDURE Generic_Operation (p_ChannelName in varchar2,
				p_OperationName in varchar2,
				p_OperationParam in varchar2 default null,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);
-- Start of comments
--	API name	: Verify_Adapter
--	Type		: Private
--	Purpose		: Checks the status of an adapter
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName		VARCHAR2 	Required
--				Internally generated and unique name for the
--				adapter
--			  p_OperationName	VARCHAR2	Required
--			  p_OperationParam 	VARCHAR2	Optional
--
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
Procedure Verify_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- ************* Added - sacsharm - END *****************************

-- Start of comments
--	API name	: Create_Admin_Request
--	Type		: Private
--	Purpose		: Submits an adapter admin request
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName		VARCHAR2 	Required
--				Internally generated and unique name for the
--				adapter
--			  p_RequestType 	VARCHAR2	Required
--			  p_RequestDate		DATE		Optional
--			  p_RequestedBy		VARCHAR2	Optional
--			  p_Freq		NUMBER		Optional
--
--	OUT		:
--			  p_RequestID		NUMBER
--				The request ID for the created admin request
--			  p_JobID		NUMBER
--				The job ID for the created admin request
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
Procedure Create_Admin_Request (p_ChannelName in varchar2,
				 p_RequestType in varchar2,
				 p_RequestDate in date default sysdate,
				 p_RequestedBy in varchar2 default null,
				 p_Freq in number default null,
				 p_RequestID OUT NOCOPY number,
				 p_JobID OUT NOCOPY number,
				 p_retcode	OUT NOCOPY NUMBER,
				 p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Update_Admin_Request
--	Type		: Private
--	Purpose		: Updates an adapter admin request
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_RequestID		NUMBER		Required
--			  p_RequestDate		DATE		Optional
--			  p_RequestedBy		VARCHAR2	Optional
--			  p_Freq		NUMBER		Optional
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
Procedure Update_Admin_Request (p_RequestID in number,
				p_RequestDate in date default sysdate,
				p_RequestedBy in varchar2 default null,
				p_Freq in number default null,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Delete_Admin_Request
--	Type		: Private
--	Purpose		: Removes an adapter admin request
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_RequestID		NUMBER		Required
--	OUT		:
--			  p_retcode  		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf  		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Delete_Admin_Request (p_RequestID in number,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- End of Adapter Admin Request Procedures

--
-- The following procedures are used to perform Control operations on adapters

-- Start of comments
--	API name	: Start_Adapter
--	Type		: Group
--	Purpose		: Performs startup control operation on an adapter
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName		VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Start_Adapter	(p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Stop_Adapter
--	Type		: Group
--	Purpose		: Performs stop control operation on an adapter
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments
Procedure Stop_Adapter	(p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);


-- Start of comments
--	API name	: Suspend_Adapter
--	Type		: Group
--	Purpose		: Performs suspend control operation on an adapter.
--			  Stops the adapter instance from processing any
--			  inbound or outbound messages.  The adapter instance
--			  maintains its connection to the remote system
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Suspend_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);
-- Start of comments
--	API name	: Resume_Adapter
--	Type		: Group
--	Purpose		: Performs resume control operation on an adapter.
--			  Allows the adapter instance to process inbound and
--			  outbound messages
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Resume_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);
-- Start of comments
--	API name	: Connect_Adapter
--	Type		: Group
--	Purpose		: Performs connect control operation on an adapter.
--			  Establishes a connection between the adapter instance
--			  and the remote system
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Connect_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);
-- Start of comments
--	API name	: Disconnect_Adapter
--	Type		: Group
--	Purpose		: Performs disconnect control operation on an adapter.
--			  Releases the cnonection between the adapter instance
--			  and the remote system
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Disconnect_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);
-- Start of comments
--	API name	: Terminate_Adapter
--	Type		: Group
--	Purpose		: Performs terminate control operation on an adapter.
--			  Kills the adapter process, a forceful shutdown
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Terminate_Adapter (p_ChannelName in varchar2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Get_Adapter_Exit_Code
--	Type		: Private
--	Purpose		: Performs terminate control operation on an adapter.
--			  Kills the adapter process, a forceful shutdown
--	Pre-reqs	: None.
--	Parameters	:
--
--		IN	:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--	Returns 	: VARCHAR2
--				The adapter's exit code
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments

Function get_adapter_exit_code return varchar2;
FUNCTION  Is_Adapter_Configured(p_fe_id in number) return BOOLEAN;

PROCEDURE Verify_Running_Adapters (p_controller_instance_id IN NUMBER,
				x_adapter_info OUT NOCOPY VARCHAR2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Get_Adapter_Log_File_URL
--	Type		: Private
--	Purpose		: Returns the URL from which the user can view the
--			  adapter log file.  This URL can only be accessed
--			  once.
--	Pre-reqs	: None.
--	Parameters	:
--
--		IN	:
--			  p_ChannelName 	VARCHAR2 	Required
--				Internally generated and unique name for an
--				adapter
--			  p_gwyuid		VARCHAR2	Required
--				The guest user id for the database instance
--			  p_two_task		VARCHAR2	Required
--				TWO_TASK of the database instance
--	Returns 	: VARCHAR2
--				The URL to access the adapter log file
--	Version		: Current version	11.5
--	Notes		: This API will only work if the log file ends
--			  in '.log'.
--
-- End of comments
FUNCTION Get_Adapter_Log_File_URL(p_channel_name in VARCHAR2,
                             p_gwyuid in VARCHAR2,
                             p_two_task in VARCHAR2) return VARCHAR2;

-- Start of comments
--	API name	: Get_Adapter_Log_File_URL
--	Type		: Private
--	Purpose		: Appends '.log' to the specified string if it
--			  is not already appended.
--	Pre-reqs	: None.
--	Parameters	:
--
--		IN	:
--			  p_file_name 	VARCHAR2 	Required
--				The string to append to
--	Returns 	: VARCHAR2
--				The adapter log file name with '.log'
--				appended if it was not present already.
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
FUNCTION Add_Log_File_Extension(p_file_name in VARCHAR2) return VARCHAR2;

Procedure Verify_All_Adapters ( p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

Procedure Verify_Adapters (p_FilterType IN varchar2,
				p_FilterKey 	IN VARCHAR2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

Procedure Reset_SysDeactivated_Adapter (p_ChannelName in varchar2,
			p_ResetStatusFlag in boolean default true);

PROCEDURE Reset_SysDeactivated_Adapters (p_controller_instance_id IN NUMBER);

END XDP_ADAPTER;

 

/
