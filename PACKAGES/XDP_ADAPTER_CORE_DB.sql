--------------------------------------------------------
--  DDL for Package XDP_ADAPTER_CORE_DB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER_CORE_DB" AUTHID CURRENT_USER AS
/* $Header: XDPACODS.pls 120.1 2005/06/08 23:33:33 appldev  $ */

e_SendPipedMsgException exception;
e_ReceivePipedMsgException exception;
e_LockException exception;
e_LockReleaseException exception;

pv_JreCommand varchar2(10) 		:= 'jre';

pv_InboundChannelName varchar2(40) 	:= 'XNP_IN_MSG_Q';
pv_OutboundChannelName varchar2(40) 	:= 'XNP_OUT_MSG_Q';

pv_AckTimeout number			:= 60;
-- Very small timeout, please donot change
pv_LockTimeout number 			:= 1;
pv_InstanceName varchar2(40);

cursor G_Get_Running_Adapters (SvcInstID number) is
	select CHANNEL_NAME, PROCESS_ID, ADAPTER_STATUS,
		decode(ADAPTER_CLASS, 'NONE', 'N', 'Y') IS_IMPLEMENTED,
		STATUS_ACTIVE_TIME
	from XDP_ADAPTER_REG a, XDP_ADAPTER_TYPES_B b
	where ADAPTER_STATUS not in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem)
	and a.adapter_type = b.adapter_type
	and service_instance_id = SvcInstId;

cursor G_Get_Controller_Instances is
	select distinct a.service_instance_id, b.CONCURRENT_QUEUE_NAME,
		decode(b.USER_CONCURRENT_QUEUE_NAME,
		null, b.CONCURRENT_QUEUE_NAME,
		b.USER_CONCURRENT_QUEUE_NAME) USER_CONCURRENT_QUEUE_NAME
	from XDP_ADAPTER_REG a, FND_CONCURRENT_QUEUES_VL b
	where a.service_instance_id = b.CONCURRENT_QUEUE_ID and
		b.APPLICATION_ID = XDP_ADAPTER.pv_AppID;

-- DWI - Disconnect/Stop when idle
cursor G_Get_DWI_Adapters (SvcInstID number) is
	select CHANNEL_NAME, STARTUP_MODE, CONNECT_ON_DEMAND_FLAG
	from XDP_ADAPTER_REG
	where ADAPTER_STATUS = XDP_ADAPTER.pv_statusRunning and
		((STARTUP_MODE = XDP_ADAPTER.pv_startOnDemand) OR
			((CONNECT_ON_DEMAND_FLAG is not null) and (CONNECT_ON_DEMAND_FLAG = 'Y'))) and
		((MAX_IDLE_TIME_MINUTES is not null) and
			((STATUS_ACTIVE_TIME + (MAX_IDLE_TIME_MINUTES/(60*24))) < SYSDATE)) and
		service_instance_id = SvcInstId;

cursor G_Get_All_Adapters is
	select a.CHANNEL_NAME, a.PROCESS_ID, a.ADAPTER_STATUS, a.FE_ID,
		a.ADAPTER_TYPE, f.ROLE_NAME, a.ADAPTER_DISPLAY_NAME
	from XDP_ADAPTER_REG a, XDP_FES f
	where a.fe_id = f.fe_id;

-- Gets all automatic (AUTO and SOD) adapters for a Controller instance that are/may
-- be required to be started. AUTO adapters are started whereas SOD adapters are checked if
-- they are required to be started.
-- Intentionally ignores DEACTIVATED adapters

cursor G_Get_Automatic_Adapters (SvcInstID number) is
	select CHANNEL_NAME, STARTUP_MODE, XAR.FE_ID, XFE.FULFILLMENT_ELEMENT_NAME,
		decode(ADAPTER_CLASS, 'NONE', 'N', 'Y') IS_IMPLEMENTED, APPLICATION_MODE
	from XDP_ADAPTER_REG xar, XDP_ADAPTER_TYPES_B xat, XDP_FES xfe
	where ADAPTER_STATUS in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated)
	and STARTUP_MODE in (XDP_ADAPTER.pv_startAutomatic, XDP_ADAPTER.pv_startOnDemand)
	and xat.adapter_type = xar.adapter_type
	and xar.fe_id = xfe.fe_id
	and service_instance_id = SvcInstId;

-- Gets all automatic (AUTO and SOD) adapters having status DEACTIVATED_SYSTEM that are
-- required to be resetted when the Controller instance starts

cursor G_Get_SysDeactivated_Adapters (SvcInstID number) is
	select CHANNEL_NAME, adapter_status
	from XDP_ADAPTER_REG
	where STARTUP_MODE in (XDP_ADAPTER.pv_startAutomatic, XDP_ADAPTER.pv_startOnDemand)
	and service_instance_id = SvcInstId;

-- This creates an entry in the Adapter Registration table.
-- Once the adapter is created it can be started
Procedure LoadNewAdapter(   p_ChannelName in varchar2,
			    p_FeID in number,
			    p_AdapterType in varchar2,
			    p_AdapterName in varchar2,
			    p_AdapterDispName in varchar2,
			    p_AdapterStatus in varchar2,
			    p_ConcQID in number,
			    p_StartupMode in varchar2 default 'MANUAL',
			    p_UsageCode in varchar2 default 'NORMAL',
			    p_LogLevel in varchar2 default 'ERROR',
			    p_CODFlag in varchar2 default 'N',
			    p_MaxIdleTime in number default 0,
			    p_LogFileName in varchar2 default NULL,
			    p_SeqInFE in number default null,
			    p_CmdLineOpts in varchar2 default NULL,
                            p_CmdLineArgs in varchar2 default NULL);

-- Allocate a new Control Channel for the Adapter.
-- Returns a new Channel Name
Procedure CreateNewAdapterChannel(p_FeName in varchar2, p_ChannelName OUT NOCOPY varchar2);

-- Fetch Adapter Information for a Particular Channel
-- This is used for Verifying and Terminating an adapter process
-- Returns the Process ID and the Controller Serivice Intance
-- which is currently servicing the adapter
Procedure FetchAdapterInfo(p_ChannelName in varchar2,
			   p_FEID OUT NOCOPY number,
			   p_ProcessID OUT NOCOPY number,
			   p_ConcQID OUT NOCOPY number);

-- Fetch all the informaion required to be passed to the Contoller
-- when starting the adapter
-- The informaion is obtained from the Adapter Registration and also
-- The Adapter Types table.
Procedure  FetchAdapterStartupInfo(p_ChannelName in varchar2,
			 	   p_CmdOptions OUT NOCOPY varchar2,
			 	   p_CmdArgs OUT NOCOPY varchar2,
			 	   p_ControlChannelName OUT NOCOPY varchar2,
			 	   p_ApplChannelName OUT NOCOPY varchar2,
			 	   p_ApplMode OUT NOCOPY varchar2,
			 	   p_FeName OUT NOCOPY varchar2,
				   p_AdapterClass OUT NOCOPY varchar2,
			 	   p_AdapterName OUT NOCOPY varchar2,
			 	   p_ConcQID OUT NOCOPY number,
			 	   p_InboundChannelName OUT NOCOPY varchar2,
			 	   p_LogFileName OUT NOCOPY varchar2);

-- API to update the Adapter Information from the Adapter registration
Procedure UpdateAdapter(  p_ChannelName in varchar2,
				p_Status in varchar2 default null,
				p_ProcessId in number default null,
				p_UsageCode in varchar2 default null,
				p_StartupMode in varchar2 default null,
				p_AdapterName in varchar2 default null,
				p_AdapterDispName in varchar2 default null,
				p_SvcInstId in number default null,
				p_WFItemType in varchar2 default null,
				p_WFItemKey in varchar2 default null,
				p_WFActivityName in varchar2 default null,
				p_CODFlag in varchar2 default null,
				p_MaxIdleTime in number default -1,
				p_LastVerified in date default null,
				p_CmdLineOpts in varchar2 default 'CmdLineOpts',
				p_CmdLineArgs in varchar2 default 'CmdLineArgs',
			    	p_LogLevel in varchar2 default null,
			    	p_LogFileName in varchar2 default 'LogFileName',
			    	p_SeqInFE in number default -1);

-- API to update the Adapter Active Time
Procedure Update_Adapter_Active_Time(p_ChannelName IN VARCHAR2);

-- Submits an Admin Request for an Adapter. A DBMS_JOB is also submitted.
Procedure SubmitAdapterAdminReq (p_ChannelName in varchar2,
				 p_RequestType in varchar2,
				 p_RequestDate in date default sysdate,
				 p_RequestedBy in varchar2,
				 p_Freq in number default null,
				 p_RequestID OUT NOCOPY number,
				 p_JobID OUT NOCOPY number);

-- Update an Admin Request
Procedure UpdateAdapterAdminReq(p_RequestID in number,
				p_RequestDate in date default sysdate,
				p_RequestedBy in varchar2,
				p_Freq in number default null);

-- Remove Adapter Admin Requests
Procedure RemoveAdapterAdminReq (p_RequestID in number);

-- Fetch More Information regarding a particular Request
Procedure FetchAdapterAdminReqInfo (p_RequestID in number,
				    p_RequestType OUT NOCOPY varchar2,
				    p_RequestDate OUT NOCOPY date,
				    p_RequestedBy OUT NOCOPY varchar2,
				    p_Freq OUT NOCOPY number,
				    p_DBJobID OUT NOCOPY number,
				    p_ChannelName OUT NOCOPY varchar2);

-- Check if a System Generated Admin Request has already been submitted
Function DoesSystemReqAlreadyExist(p_ChannelName in varchar2,
				   p_RequestType in varchar2,
				   p_RequestDate in date) return number;

-- Get the Current Adapter Status
Function GetCurrentAdapterStatus(p_ChannelName in varchar2) return varchar2;

-- Try to obtain a lock on a particular Adapter Channel
-- The timeout specifies the duration for which you need to wait for the lock
-- 'Y' if successful else 'N'

--Used by Adapters
Function ObtainAdapterLock(p_ChannelName in varchar2,
			   p_Timeout in number default pv_LockTimeout) return varchar2;

--Used by FA processing logic
Function ObtainAdapterLock_FA(p_ChannelName in varchar2,
			   p_Timeout in number default pv_LockTimeout) return varchar2;

--Used by adapter verification logic
Function ObtainAdapterLock_Verify(p_ChannelName in varchar2,
			   p_Timeout in number default pv_LockTimeout) return varchar2;

-- Releases the lock on an Adapter Channel
-- 'Y' if successful else 'N'
Function ReleaseAdapterLock(p_ChannelName in varchar2) return varchar2;

-- Checks if the Channel on which the adapter is operating is Connect-On-Demand
-- enabled
Function IsChannelCOD(p_ChannelName in varchar2) return varchar2;

-- Check if there are any FA's waiting for a Channel to a Fulfillment Element
Function PeekIntoFeWaitQueue(p_ChannelName in varchar2) return varchar2;

-- ************* Added - sacsharm - START *****************************

-- Autonomous API to update the Adapter Status in the Adapter registration
Procedure Update_Adapter_Status (p_ChannelName in varchar2,
				p_Status in varchar2,
				p_ErrorMsg in varchar2 default null,
				p_ErrorMsgParams in varchar2 default null,
				p_WFItemType in varchar2 default null,
				p_WFItemKey in varchar2 default null);

Function GetAckTimeOut return number;

Function GetLockTimeOut return number;

-- Check if any more adapters can be started for a FE
Function Is_Max_Connection_Reached (p_fe_id in number) return boolean;

-- Procedure to delete an Adapter
PROCEDURE Delete_Adapter (p_channel_name IN VARCHAR2);

-- Procedure to delete all Adapters for a FE
PROCEDURE Delete_Adapters_For_Fe (p_fe_id IN NUMBER);

Function Get_Fe_Id_For_name (p_FeName in varchar2) return number;

Function Get_Job_Id_For_Request (p_RequestId in number) return number;

PROCEDURE Audit_Adapter_Admin_Request (p_RequestID in number,
			p_RequestType in varchar2,
			p_RequestDate in date,
			p_RequestedBy in varchar2,
			p_Freq in number,
			p_RequestStatus in varchar2,
			p_RequestMessage in varchar2,
			p_ChannelName in varchar2);

--Function Is_Adapter_Available (p_fe_id in NUMBER, p_AdapterType in VARCHAR2) return boolean;
Procedure Are_Adapter_Generics_Available (p_fe_id in NUMBER, p_AdapterType in VARCHAR2,
			p_GenCountActive OUT NOCOPY NUMBER, p_GenCountFuture OUT NOCOPY NUMBER);

Function Is_Message_Adapter_Available(p_fe_name in varchar2) return VARCHAR2;

Function Is_Message_Adapter_Available(p_fe_id in number) return VARCHAR2;

Function Is_FE_Adapter_Running(p_fe_id in number) return BOOLEAN;

Function Is_FEType_Adapter_Running(p_fetype_id in number) return BOOLEAN;

-- Checks if the channel's adapter type is an implemented class
Function Is_Adapter_Implemented (p_ChannelName in varchar2) return boolean;

-- This autonomous function is called from FA WF and does not obtain or release
-- lock on the channel as the caller would have already obtained a
-- lock on the channel

Function Verify_Adapter (p_ChannelName IN varchar2) return boolean;

Function Is_Adapter_Automatic (p_ChannelName in varchar2) return boolean;

Function GetAdapterRestartCount return number;

-- ************* Added - sacsharm - END *****************************

-- ************* Added - mviswana - START ***************************

FUNCTION GetOAMFERolledStatus(p_fe_id        IN NUMBER,
                              p_mode IN VARCHAR2) RETURN VARCHAR2;




FUNCTION GetOAMAdapterRunningCount(p_fe_id         IN NUMBER,
                                   p_mode IN VARCHAR2) return NUMBER;



FUNCTION GetNumOfJobsCount(p_fe_id        IN NUMBER,
                           p_fe_name      IN VARCHAR2,
                           p_mode IN VARCHAR2) return NUMBER;


-- ************* Added - mviswana - END *****************************


/********* Commented out - START - sacsharm ************************

-- Create a New Adaptr Type
-- This loads the adapter type information into the XDP_ADAPTER_TYPES_B table

Procedure LoadNewAdapterType (  p_AdapterType in varchar2,
		 		p_AdapterClass in varchar2,
				p_ApplicationMode in varchar2,
				p_InboundReqFlag in varchar2 default 'N',
				p_MaxBufSize in number default 2000,
				p_CmdLineOpts in varchar2 default NULL,
				p_CmdLineArgs in varchar2 default NULL);

-- Remove Adapter Admin DB Jobs alone
-- Used in application stop
Procedure RemoveAdapterAdminDBJobs(p_ChannelName in varchar2);

-- Re-submit adapter admin jobs. Used in application start
Procedure ResubmitAdapterAdminDBJob(p_Channelname in varchar2);


********** Commented out - END - sacsharm ***********************/

--This function verifies whether the channel need to be locked or not..
--Approach to get the lock only if the adapter_type is PIPE..
Function checkLockRequired( p_Channelname in varchar2) return boolean;
-----------------------------------------------------------------------------
--
--
-- Start of comments
--      API name        : Copy_FET_Attribute
--      Type            : Group
--      Function        : Copy attributes from an adapter type to FE Type/SW
--      Pre-reqs        : None.
--      Version :       : Current version       11.5.7
--      Notes   :
--   This procedure will copy adapter type attribute to an FE type/SW combination
-- End of comments
--
--

Procedure Copy_FET_Attribute(
        p_fe_sw_gen_lookup_id in NUMBER,
        p_adapter_type IN VARCHAR2,
        p_caller_id NUMBER,
        x_retcode OUT NOCOPY NUMBER,
        x_errbuf OUT NOCOPY VARCHAR2);

------------------------------------------------------------------------
--
--
-- Start of comments
--      API name        : Copy_FE
--      Type            : Group
--      Function        : Copy an exsiting fe to a new FE
--      Pre-reqs        : None.
--      Version :       : Current version       11.5.7
--      Notes   :
--   This procedure will copy an existing fe, identified by p_feid
--   to a newly created FE identified by p_NewFeId with input internal
--   name. It copies all the fields of exsiting fe, including all
--   software generic config and attributes.
-- End of comments
--
--

 Procedure Copy_FE(
                p_FeName in varchar2,
                p_FeDisplayName in varchar2,
                p_FeID in varchar2,
                p_NewFeID in NUMBER,
                p_CallerID in NUMBER,
                x_retcode OUT NOCOPY NUMBER,
                x_errbuf OUT NOCOPY VARCHAR2);



END XDP_ADAPTER_CORE_DB;

 

/
