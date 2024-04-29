--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_CORE_DB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_CORE_DB" AS
/* $Header: XDPACODB.pls 120.1 2005/06/08 23:24:55 appldev  $ */

-- Private variables

 pv_ChannelTruncLength number 	:= 4;
 pv_ChannelLength number 	:= 30;

 -- '%' breaks Controller C code
 -- pr_AfLogStr varchar2(500) 	:= '-DAFLOG_ENABLED=TRUE -DAFLOG_MODULE=% -DAFLOG_LEVEL=';
 pr_AfLogStr varchar2(500) 	:= '-DAFLOG_ENABLED=TRUE -DAFLOG_LEVEL=';

-- Private Procedures start

Function ObtainHandle(p_ChannelName in varchar2) return varchar2;

Function GetAdapterAttributes( FeID in number) return XDP_TYPES.ORDER_PARAMETER_LIST
is
 FeName varchar2(80);
 FeAttributes XDP_TYPES.ORDER_PARAMETER_LIST;
begin

	begin
		FeAttributes := XDP_ENGINE.Get_FE_AttributeVal_List(p_fe_id => FeID);
	exception
	when no_data_found then
		 null;
	end;

	return (FeAttributes);

end GetAdapterAttributes;

-- Private Procedures End

-- Public Procedures Start
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
                            p_CmdLineArgs in varchar2 default NULL)
is
begin


  insert into xdp_adapter_reg (
			channel_name,
			fe_id,
			adapter_status,
			process_id,
			adapter_type,
			adapter_name,
			adapter_display_name,
			usage_code,
                      	startup_mode,
			service_instance_id,
                      	log_level,
			connect_on_demand_flag,
			max_idle_time_minutes,
			cmd_line_options,
			cmd_line_args,
			log_file_name,
			seq_in_fe,
			application_id,
                      	created_by,
                      	creation_date,
                      	last_updated_by,
                      	last_update_date,
                      	last_update_login)
  		values
               	      (	p_ChannelName,
                      	p_FeID,
                      	p_AdapterStatus,
                      	-1,
                      	p_AdapterType,
                      	p_AdapterName,
			p_AdapterDispName,
                      	p_UsageCode,
                      	p_StartupMode,
			p_ConcQID,
                      	p_LogLevel,
			p_CODFlag,
			p_MaxIdleTime,
			p_CmdLineOpts,
			p_CmdLineArgs,
			p_LogFileName,
			p_SeqInFE,
  			XDP_ADAPTER.pv_AppID,
                      	FND_GLOBAL.USER_ID,
                      	sysdate,
                      	FND_GLOBAL.USER_ID,
                      	sysdate,
                      	FND_GLOBAL.LOGIN_ID);

end LoadNewAdapter;


Procedure SubmitAdapterAdminReq (p_ChannelName in varchar2,
				 p_RequestType in varchar2,
				 p_RequestDate in date default sysdate,
				 p_RequestedBy in varchar2,
				 p_Freq in number default null,
				 p_RequestID OUT NOCOPY number,
				 p_JobID OUT NOCOPY number)
is

begin
	select XDP_ADAPTER_ADMIN_REQS_S.NEXTVAL into p_RequestID from dual;

  	XDP_CRON_UTIL.SubmitAdapterAdminJob(p_request => p_RequestID,
                                  p_RunDate => SubmitAdapterAdminReq.p_RequestDate,
				  p_RunFreq => SubmitAdapterAdminReq.p_Freq,
                                  p_JobNumber => p_JobID);

	insert into xdp_adapter_admin_reqs
		(request_id,
		 channel_name,
		 request_type,
		 request_date,
		 requested_by_user,
		 request_frequency,
		 job_id,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login)
  	values
		(p_RequestID,
		 SubmitAdapterAdminReq.p_ChannelName,
		 SubmitAdapterAdminReq.p_RequestType,
		 SubmitAdapterAdminReq.p_RequestDate,
		 SubmitAdapterAdminReq.p_RequestedBy,
		 SubmitAdapterAdminReq.p_Freq,
		 p_JobID,
                 FND_GLOBAL.USER_ID,
                 sysdate,
                 FND_GLOBAL.USER_ID,
                 sysdate,
                 FND_GLOBAL.LOGIN_ID);

end SubmitAdapterAdminReq;

Procedure UpdateAdapterAdminReq(p_RequestID in number,
				p_RequestDate in date default sysdate,
				p_RequestedBy in varchar2,
				p_Freq in number default null)
is
l_jobID number := -1;
begin
	l_jobID := Get_Job_Id_For_Request (p_RequestID);

	XDP_CRON_UTIL.UpdateDBJob(p_jobID => l_jobID,
				  p_request => p_RequestID,
				  p_ReqDate => p_RequestDate,
				  p_Freq => p_Freq);

	update xdp_adapter_admin_reqs set
	    request_date = p_RequestDate,
	    requested_by_user = p_RequestedBy,
	    request_frequency = p_Freq,
	    last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.login_id
	where request_id = p_RequestID;

end UpdateAdapterAdminReq;


Procedure RemoveAdapterAdminReq (p_RequestID in number)
is
l_jobID number := -1;
begin
	l_jobID := Get_Job_Id_For_Request (p_RequestID);

 	dbms_job.remove(l_jobID);

	delete from xdp_adapter_admin_reqs where request_id = p_RequestID;

end RemoveAdapterAdminReq;


Procedure FetchAdapterAdminReqInfo (p_RequestID in number,
				    p_RequestType OUT NOCOPY varchar2,
				    p_RequestDate OUT NOCOPY date,
				    p_RequestedBy OUT NOCOPY varchar2,
				    p_Freq OUT NOCOPY number,
				    p_DBJobID OUT NOCOPY number,
				    p_ChannelName OUT NOCOPY varchar2)
is

 cursor c_GetAdapterAdmin is
 select xar.request_type,  xar.request_date, xar.requested_by_user, xar.request_frequency,
	xar.channel_name, xar.job_id
 from xdp_adapter_admin_reqs xar
 where request_id = p_RequestID;

 l_Found varchar2(1) := 'N';
begin

 for v_GetAdapterAdmin in c_GetAdapterAdmin loop
	p_RequestType := v_GetAdapterAdmin.request_type;
	p_RequestDate := v_GetAdapterAdmin.request_date;
	p_RequestedBy := v_GetAdapterAdmin.requested_by_user;
	p_Freq := v_GetAdapterAdmin.request_frequency;
	p_DBJobID := v_GetAdapterAdmin.job_id;
	p_ChannelName := v_GetAdapterAdmin.channel_name;

	l_Found := 'Y';
	exit;
 end loop;

 if l_Found = 'N' then
	raise no_data_found;
 end if;
end FetchAdapterAdminReqInfo;

Function DoesSystemReqAlreadyExist(p_ChannelName in varchar2,
				   p_RequestType in varchar2,
				   p_RequestDate in date) return number
is
 cursor c_CheckReq is
  select request_id, job_id
   from xdp_adapter_admin_reqs
  where channel_name = DoesSystemReqAlreadyExist.p_ChannelName
    and request_type = DoesSystemReqAlreadyExist.p_RequestType
    and requested_by_user = XDP_ADAPTER.pv_adminReqBySystem
    and request_date <= nvl(p_RequestDate,sysdate);

-- l_RequestFound boolean := false;
   l_JobId number := 0;
begin

 for v_CheckReq in c_CheckReq loop
--	l_RequestFound := true;
	l_JobId := v_CheckReq.job_id;
 end loop;

 return (l_JobId);

end DoesSystemReqAlreadyExist;


Procedure CreateNewAdapterChannel(p_FeName in varchar2, p_ChannelName OUT NOCOPY varchar2)
is

begin

 p_ChannelName := XDP_ADAPTER_CORE_PIPE.GetUniqueChannelName(p_FeName);
 p_ChannelName := XDP_ADAPTER_CORE_PIPE.ConstructChannelName( 'CONTROL', p_ChannelName);

end CreateNewAdapterChannel;


Procedure FetchAdapterInfo(p_ChannelName in varchar2,
			   p_FEID OUT NOCOPY number,
			   p_ProcessID OUT NOCOPY number,
			   p_ConcQID OUT NOCOPY number)
is

 cursor c_GetAdapter is
  select fe_id, process_id, service_instance_id
   from xdp_adapter_reg
  where channel_name = p_ChannelName;

 l_Found varchar2(1) := 'N';
begin

 for v_GetAdapter in c_GetAdapter loop
	p_ProcessID := v_GetAdapter.process_id;
	p_ConcQID := v_GetAdapter.service_instance_id;
	p_FeID := v_GetAdapter.fe_id;

	l_Found := 'Y';
	exit;
 end loop;

 if l_Found = 'N' then
	raise no_data_found;
 end if;

end FetchAdapterInfo;

-- Fetch all the Adapter Starup Information
-- The possbile values for Application Mode are <PIPE> <QUEUE> <NONE>
-- If the Mode is <PIPE> the <Application Channel Name> will be a Pipe Name
-- If the Mode is <QUEUE> the <Application Channel Name> will be the Outbound Queue Name
-- If NONE then the <Application Channel Name> will be the string NONE
-- If the Inbound Flag for the adapter is set to N then the <Inbound Channel Name>
-- is NONE. Of the Inbound Flag is set to 'Y' then the value of the Inbound Queue is returned
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
			 	   p_LogFileName OUT NOCOPY varchar2)
is

 cursor c_GetFEInfo is
   select xfe.fulfillment_element_name,
          xat.application_mode,
	  xat.cmd_line_options base_cmd_options,
	  xat.cmd_line_args base_cmd_args,
	  xat.adapter_class,
	  xat.inbound_required_flag,
	  xag.adapter_name,
	  xag.cmd_line_options sub_cmd_options,
	  xag.cmd_line_args sub_cmd_args,
	  xag.log_level,
	  xag.log_file_name,
	  xag.service_instance_id
    from xdp_fes xfe,
	 xdp_adapter_types_b xat,
	 xdp_adapter_reg xag
   where xag.channel_name = p_ChannelName
     and xag.fe_id = xfe.fe_id
     and xag.adapter_type = xat.adapter_type;

 l_BaseCmdOptions varchar2(240);
 l_SubCmdOptions varchar2(240);
 l_BaseCmdArgs varchar2(240);
 l_SubCmdArgs varchar2(240);
 l_InboundFlag varchar2(1);

 l_LogLevel varchar2(240);
 l_Found varchar2(1) := 'N';

begin
  for v_GetFEInfo in c_GetFEInfo loop
	p_FeName := v_GetFEInfo.fulfillment_element_name;
	p_ApplMode := v_GetFEInfo.application_mode;
	l_BaseCmdOptions := v_GetFEInfo.base_cmd_options;
	l_BaseCmdArgs := v_GetFEInfo.base_cmd_args;
	p_AdapterClass := v_GetFEInfo.adapter_class;
	p_AdapterName := v_GetFEInfo.adapter_name;
	l_SubCmdOptions := v_GetFEInfo.sub_cmd_options;
	l_SubCmdArgs := v_GetFEInfo.sub_cmd_args;
	p_ConcQID := v_GetFEInfo.service_instance_id;
	l_InboundFlag := v_GetFEInfo.inbound_required_flag;
	l_LogLevel := v_GetFEInfo.log_level;
	p_LogFileName := v_GetFEInfo.log_file_name;

	l_Found := 'Y';
	exit;
  end loop;

 if l_Found = 'N' then
	raise no_data_found;
 end if;

 p_ControlChannelName := p_ChannelName;

 if p_FeName is null or p_ConcQID is null then
	raise no_data_found;
 end if;

 -- Lets not HC 'jre' here, as from JDK 1.2 this could be different
 -- Refer to bug 2370475
 -- p_CmdOptions := pv_JreCommand;
 p_CmdOptions := null;

 if l_BaseCmdOptions is not null then
	p_CmdOptions := l_BaseCmdOptions || ' ';
 end if;

 if l_SubCmdOptions is not null then
	p_CmdOptions := p_CmdOptions || l_SubCmdOptions || ' ';
 end if;

 if (l_LogLevel is not null) then
	p_CmdOptions := p_CmdOptions || pr_AfLogStr || l_LogLevel;
 end if;

 if (p_CmdOptions is null) then
	p_CmdOptions := 'NONE';
 end if;

 if (p_LogFileName is null) then
	p_LogFileName := 'NONE';
 end if;

 p_CmdArgs := null;
 if l_BaseCmdArgs is not null then
	p_CmdArgs := l_BaseCmdArgs || ' ';
 end if;

 if l_SubCmdArgs is not null then
	p_CmdArgs := p_CmdArgs || l_SubCmdArgs;
 end if;

 if p_ApplMode = 'PIPE' then
	p_ApplChannelName := XDP_ADAPTER_CORE_PIPE.ConstructChannelName
				('APPL', p_ChannelName);
 elsif p_ApplMode = 'QUEUE' then
	p_ApplChannelName := pv_OutboundChannelName;
 else
	p_ApplMode := 'NONE';
	p_ApplChannelName := 'NONE';
 end if;

 if l_InboundFlag = 'Y' then
	p_InboundChannelName := pv_InboundChannelName;
 else
 	l_InboundFlag := 'N';
	p_InboundChannelName := 'NONE';
 end if;

end FetchAdapterStartupInfo;


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
			    	p_SeqInFE in number default -1)
is

l_errorCount	NUMBER := 0;
l_Status	VARCHAR2 (40) := null;
l_AdapterDisplayName	VARCHAR2 (80) := null;

begin

	l_Status := p_Status;

	if ((l_Status is not null) and (l_Status = XDP_ADAPTER.pv_statusStoppedError) and
		(Is_Adapter_Automatic(p_ChannelName))) then

		l_errorCount := XDP_ERRORS_PKG.GET_ERROR_COUNT (
			p_object_type => XDP_ADAPTER.pv_errorObjectTypeAdapter,
			p_object_key => p_ChannelName);

		l_errorCount := l_errorCount + 1;

		XDP_ERRORS_PKG.UPDATE_ERROR_COUNT (
			p_object_type => XDP_ADAPTER.pv_errorObjectTypeAdapter,
			p_object_key => p_ChannelName,
			p_error_count => l_errorCount);

		if (l_errorCount >= GetAdapterRestartCount()) then

			l_Status := XDP_ADAPTER.pv_statusDeactivatedSystem;

			if (p_AdapterDispName is null) then
				select adapter_display_name into l_AdapterDisplayName
					from xdp_adapter_reg where channel_name = p_ChannelName;
			else
				l_AdapterDisplayName := p_AdapterDispName;
			end if;

			XDP_ADAPTER_CORE.NotifyAdapterSysDeactivation (l_AdapterDisplayName);
		END IF;

	END IF;

	-- status_active_time is updated anytime status is updated

	update xdp_adapter_reg
	set	adapter_status = nvl(l_Status, adapter_status),
		status_active_time = decode(l_Status,
					null, status_active_time,
					sysdate),
		process_id = nvl(p_ProcessId,
			decode(l_Status,
				XDP_ADAPTER.pv_statusStopped, -1,
				XDP_ADAPTER.pv_statusStoppedError, -1,
				XDP_ADAPTER.pv_statusTerminated, -1,
				XDP_ADAPTER.pv_statusStarting, -1,
				XDP_ADAPTER.pv_statusDeactivated, -1,
				XDP_ADAPTER.pv_statusDeactivatedSystem, -1,
				process_id)),
		node = decode(l_Status,
				XDP_ADAPTER.pv_statusStopped, null,
				XDP_ADAPTER.pv_statusStoppedError, null,
				XDP_ADAPTER.pv_statusTerminated, null,
				XDP_ADAPTER.pv_statusDeactivated, null,
				XDP_ADAPTER.pv_statusDeactivatedSystem, null,
				node),
		usage_code = nvl(p_UsageCode, usage_code),
		startup_mode = nvl(p_StartupMode, startup_mode),
		adapter_name = nvl(p_AdapterName, adapter_name),
		adapter_display_name = nvl(p_AdapterDispName,
						adapter_display_name),
		service_instance_id = nvl(p_SvcInstId, service_instance_id),
		wf_item_type = nvl(p_WFItemType, wf_item_type),
		wf_item_key = nvl(p_WFItemKey, wf_item_key),
		wf_activity_name = nvl(p_WFActivityName,wf_activity_name),
		connect_on_demand_flag = nvl(p_CODFlag,connect_on_demand_flag),
		max_idle_time_minutes = decode(p_MaxIdleTime,
				-1, max_idle_time_minutes,
				p_MaxIdleTime),
		cmd_line_options = decode(p_CmdLineOpts,
				'CmdLineOpts', cmd_line_options,
				p_CmdLineOpts),
		cmd_line_args = decode(p_CmdLineArgs,
				'CmdLineArgs', cmd_line_args,
				p_CmdLineArgs),
		last_verified_time = nvl(p_LastVerified,
				decode(l_Status,
			XDP_ADAPTER.pv_statusStarting, last_verified_time,
			XDP_ADAPTER.pv_statusStopping, last_verified_time,
 			XDP_ADAPTER.pv_statusSuspending, last_verified_time,
			XDP_ADAPTER.pv_statusResuming, last_verified_time,
			XDP_ADAPTER.pv_statusConnecting, last_verified_time,
			XDP_ADAPTER.pv_statusDisconnecting, last_verified_time,
			XDP_ADAPTER.pv_statusTerminating, last_verified_time,
				sysdate)),
		log_level = nvl(p_LogLevel, log_level),
		log_file_name = decode(p_LogFileName,
				'LogFileName', log_file_name,
				p_LogFileName),
		seq_in_fe = decode(p_SeqInFE,
				-1, seq_in_fe,
				p_SeqInFE),
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		last_update_login = fnd_global.login_id
	where
	channel_name = p_ChannelName;

end UpdateAdapter;


Procedure Update_Adapter_Active_Time(p_ChannelName IN VARCHAR2)
IS

BEGIN
	UPDATE 	xdp_adapter_reg
	SET 	status_active_time = sysdate,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		last_update_login = fnd_global.login_id
	WHERE 	channel_name = p_ChannelName;

END Update_Adapter_Active_time;

--********** For Getting Rolled Up status of FE **************

FUNCTION GetOAMFERolledStatus (p_fe_id IN NUMBER,
                               p_mode IN VARCHAR2) RETURN VARCHAR2 AS


  CURSOR c_GetASyncAdapterStatus IS
         SELECT a.adapter_status
         FROM xdp_adapter_reg a,
         xdp_adapter_types_b b
         WHERE a.adapter_type = b.adapter_type AND
         a.fe_id = p_fe_id AND
         (b.application_mode = 'QUEUE' OR
         (b.application_mode = 'NONE' AND b.inbound_required_flag = 'Y'));

  CURSOR c_GetSyncAdapterStatus IS
         SELECT a.adapter_status
         FROM xdp_adapter_reg a,
         xdp_adapter_types_b b
         WHERE a.adapter_type = b.adapter_type AND
         a.fe_id = p_fe_id AND
         NOT(b.application_mode = 'QUEUE' OR
            (b.application_mode = 'NONE' AND b.inbound_required_flag = 'Y'));

  l_fe_status        VARCHAR2(30);
  l_match_found      BOOLEAN := FALSE;

BEGIN

 IF p_mode = 'ASYNC' THEN

   FOR v_GetAdapterStatus IN c_GetAsyncAdapterStatus LOOP

     IF v_GetAdapterStatus.adapter_status IN (XDP_ADAPTER.pv_statusError, XDP_ADAPTER.pv_statusSessionLost, XDP_ADAPTER.pv_statusStoppedError, XDP_ADAPTER.pv_statusTerminated)
     THEN
           l_fe_status := XDP_ADAPTER.pv_rolledStatusError;
           RETURN l_fe_status;
     ELSIF v_GetAdapterStatus.adapter_status IN (XDP_ADAPTER.pv_statusInUse, XDP_ADAPTER.pv_statusRunning, XDP_ADAPTER.pv_statusDisconnected, XDP_ADAPTER.pv_statusSuspended)
     THEN
           l_match_found := TRUE;
           exit;
        END IF;
   END LOOP;

 ELSE

   FOR v_GetAdapterStatus IN c_GetSyncAdapterStatus LOOP

     IF v_GetAdapterStatus.adapter_status IN (XDP_ADAPTER.pv_statusError, XDP_ADAPTER.pv_statusSessionLost, XDP_ADAPTER.pv_statusStoppedError, XDP_ADAPTER.pv_statusTerminated)
     THEN
           l_fe_status := XDP_ADAPTER.pv_rolledStatusError;
           RETURN l_fe_status;
     ELSIF v_GetAdapterStatus.adapter_status IN (XDP_ADAPTER.pv_statusInUse, XDP_ADAPTER.pv_statusRunning, XDP_ADAPTER.pv_statusDisconnected, XDP_ADAPTER.pv_statusSuspended)
     THEN
           l_match_found := TRUE;
           exit;
        END IF;
   END LOOP;

  END IF;

  IF l_match_found THEN
      l_fe_status := XDP_ADAPTER.pv_rolledStatusRunning;
      RETURN l_fe_status;
  ELSE
      l_fe_status := XDP_ADAPTER.pv_rolledStatusUnavailable;
      RETURN l_fe_status;
   END IF;
END GetOAMFERolledStatus;



--********** For Running Adapters**********

 FUNCTION GetOAMAdapterRunningCount(p_fe_id IN NUMBER,
                                    p_mode IN VARCHAR2) RETURN NUMBER AS

    l_adapter_status_cnt        NUMBER;

BEGIN

 IF p_mode = 'ASYNC' THEN

   SELECT count(*)
   INTO l_adapter_status_cnt
   FROM xdp_adapter_reg a, xdp_adapter_types_b b
   WHERE a.adapter_type = b.adapter_type
     AND a.fe_id = p_fe_id
     AND (b.application_mode = 'QUEUE' OR
         (b.application_mode = 'NONE' AND b.inbound_required_flag = 'Y'))
     AND a.adapter_status IN (XDP_ADAPTER.pv_statusInUse, XDP_ADAPTER.pv_statusRunning);

 ELSE

   SELECT count(*)
   INTO l_adapter_status_cnt
   FROM xdp_adapter_reg a, xdp_adapter_types_b b
   WHERE a.adapter_type = b.adapter_type
     AND a.fe_id = p_fe_id
     AND NOT(b.application_mode = 'QUEUE' OR
            (b.application_mode = 'NONE' AND b.inbound_required_flag = 'Y'))
     AND a.adapter_status IN (XDP_ADAPTER.pv_statusInUse, XDP_ADAPTER.pv_statusRunning);

 END IF;

 RETURN l_adapter_status_cnt;

END GetOAMAdapterRunningCount;


--********** For  counting no. of job an adapter ***********

 FUNCTION GetNumOfJobsCount(p_fe_id IN NUMBER,
                           p_fe_name IN VARCHAR2,
                           p_mode IN VARCHAR2) return NUMBER AS
l_num_of_job_cnt NUMBER;

BEGIN

 if p_mode = 'ASYNC' THEN

    SELECT COUNT(xomq.msg_id) num_of_jobs
      INTO l_num_of_job_cnt
      FROM AQ$xnp_out_msg_qtab xomq
     WHERE xomq.consumer_name = p_fe_name;

 else

    SELECT COUNT(DISTINCT xaj.job_id) num_of_jobs
      INTO l_num_of_job_cnt
      FROM xdp_adapter_job_queue xaj, xdp_adapter_reg xar, xdp_adapter_types_b xat
     WHERE xaj.fe_id = xar.fe_id
       AND xar.adapter_type = xat.adapter_type
       AND xaj.fe_id = p_fe_id
       AND xat.application_mode <> 'QUEUE';


 end if;

 RETURN l_num_of_job_cnt;

END GetNumOfJobsCount;


Function GetCurrentAdapterStatus(p_ChannelName in varchar2) return varchar2
is
 cursor c_GetAdapterStatus is
   select xag.adapter_status
    from xdp_adapter_reg xag
   where channel_name = p_ChannelName;

 l_CurrentAdapterStatus varchar2(40);
 l_exists varchar2(1) := 'N';
begin

 for v_AdapterStatus in c_GetAdapterStatus loop
	l_CurrentAdapterStatus := v_AdapterStatus.adapter_status;
	l_exists := 'Y';
 end loop;

 if l_exists = 'N' then
	raise no_data_found;
 end if;

 return (l_CurrentAdapterStatus);

end GetCurrentAdapterStatus;

--Used by adapter verification logic
Function ObtainAdapterLock_Verify(p_ChannelName in varchar2,
                           p_Timeout in number default pv_LockTimeout) return varchar2
is
 l_Status number;
 l_LockHandle varchar2(240);

begin
        l_LockHandle := ObtainHandle(p_ChannelName => p_ChannelName);

        l_Status := DBMS_LOCK.REQUEST(lockhandle=> l_LockHandle,
                                      timeout => p_Timeout,
                                      lockmode => 6);

        if l_Status in(0, 4) then
                return 'Y';
        elsif l_Status = 1 then
                return 'N';
        else
                raise e_LockException;
        end if;

end ObtainAdapterLock_Verify;

--Used by FA processing
Function ObtainAdapterLock_FA(p_ChannelName in varchar2,
			   p_Timeout in number default pv_LockTimeout) return varchar2
is
 l_LockFlag varchar2(1) := 'N';
 l_InstanceName varchar2(40);
 l_ChannelName varchar2(40);
begin
	l_LockFlag := ObtainAdapterLock_Verify (p_ChannelName => p_ChannelName,
                                                p_Timeout => p_Timeout);

	if l_LockFlag = 'Y' then

            IF (INSTR(p_ChannelName, 'SESSION_', 1) > 0) THEN
          	l_ChannelName := substr(p_ChannelName, 9);
            ELSE
          	l_ChannelName := p_ChannelName;
            END IF;

            select node into l_InstanceName from xdp_adapter_reg where channel_name = l_ChannelName;
            --Adapter is running on different instance than this session
            if l_InstanceName is not null and l_InstanceName <> pv_InstanceName then
                l_LockFlag := ReleaseAdapterLock(p_ChannelName => p_ChannelName);
                l_LockFlag := 'N';
            end if;
	end if;

        return l_LockFlag;
end ObtainAdapterLock_FA;

--Used by adapter to hold session lock
Function ObtainAdapterLock(p_ChannelName in varchar2,
			   p_Timeout in number default pv_LockTimeout) return varchar2
is
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_LockFlag varchar2(1);
 l_ChannelName varchar2(40);
begin
	l_LockFlag := ObtainAdapterLock_Verify (p_ChannelName => p_ChannelName,
                                                p_Timeout => p_Timeout);

	if l_LockFlag = 'Y' then

            IF (INSTR(p_ChannelName, 'SESSION_', 1) > 0) THEN
          	l_ChannelName := substr(p_ChannelName, 9);
            ELSE
          	l_ChannelName := p_ChannelName;
            END IF;

            update xdp_adapter_reg set node = pv_InstanceName where channel_name = l_ChannelName;
            commit;
	end if;

        return l_LockFlag;
end ObtainAdapterLock;


Function ReleaseAdapterLock(p_ChannelName in varchar2) return varchar2
is
 l_Status number;
 l_LockHandle varchar2(240);

begin
	l_LockHandle := ObtainHandle(ReleaseAdapterLock.p_ChannelName);

	l_Status := DBMS_LOCK.RELEASE(lockhandle => l_LockHandle);

	if l_Status in (0, 4) then
		return 'Y';
	else
		raise e_LockReleaseException;
	end if;

end ReleaseAdapterLock;


Function IsChannelCOD(p_ChannelName in varchar2) return varchar2
is
 l_CODFlag varchar2(1) := 'N';
begin

  select NVL(CONNECT_ON_DEMAND_FLAG, 'N') into l_CODFlag
  from xdp_adapter_reg
  where CHANNEL_NAME = p_ChannelName;

  return (l_CODFlag);

end IsChannelCOD;


Function PeekIntoFeWaitQueue(p_ChannelName in varchar2) return varchar2
is
 l_check varchar2(1) := 'N';
begin

 begin
	select 'Y' into l_check
	from dual
	where exists
	( select JOB_ID from xdp_adapter_job_queue a, xdp_adapter_reg b
	  where b.channel_name = p_ChannelName
	  and b.fe_id = a.fe_id);
 exception
 when no_data_found then
  l_check := 'N';
 end;

 return (l_check);
end PeekIntoFeWaitQueue;


Function ObtainHandle(p_ChannelName in varchar2) return varchar2
is
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_LockHandle varchar2(240);
begin

	DBMS_LOCK.ALLOCATE_UNIQUE(lockname => ObtainHandle.p_ChannelName,
			          lockhandle => l_LockHandle);

	commit;

	return (l_LockHandle);

end ObtainHandle;


Function GetAckTimeOut return number
is
 l_ProfileValue varchar2(40);
begin
	if fnd_profile.defined('XDP_ACK_TIMEOUT') then
		fnd_profile.get('XDP_ACK_TIMEOUT', l_ProfileValue);
			if to_number(l_ProfileValue) <= 0 then
				l_ProfileValue := '60';
			end if;
	else
		l_ProfileValue := '60';
	end if;

	return to_number(l_ProfileValue);

end GetAckTimeOut;

-- ************** Added - sacsharm - START *********************

Function GetLockTimeOut return number
is
 l_ProfileValue varchar2(40);
begin
	-- 1 hr = 60 * 60 = 3600 secs
	if fnd_profile.defined('XDP_ADAPTER_LOCK_TIMEOUT') then
		fnd_profile.get('XDP_ADAPTER_LOCK_TIMEOUT', l_ProfileValue);
			if to_number(l_ProfileValue) <= 0 then
				l_ProfileValue := '3600';
			end if;
	else
		l_ProfileValue := '3600';
	end if;

	return to_number(l_ProfileValue);

end GetLockTimeOut;

Procedure Update_Adapter_Status (p_ChannelName in varchar2,
				p_Status in varchar2,
				p_ErrorMsg in varchar2 default null,
				p_ErrorMsgParams in varchar2 default null,
				p_WFItemType in varchar2 default null,
				p_WFItemKey in varchar2 default null)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
	UpdateAdapter (
			p_ChannelName 	=> p_ChannelName,
			p_Status 	=> p_Status,
			p_WFItemType 	=> p_WFItemType,
			p_WFItemKey 	=> p_WFItemKey
			);
	if p_ErrorMsg is not null then
		XDP_ERRORS_PKG.Set_Message (
			p_object_type 		=> XDP_ADAPTER.pv_errorObjectTypeAdapter,
			p_object_key 		=> p_ChannelName,
			p_message_name 		=> p_ErrorMsg,
			p_message_parameters	=> p_ErrorMsgParams);
	end if;
	commit;
end Update_Adapter_Status;

Function Get_Job_Id_For_Request (p_RequestId in number) return number
is
 cursor c_GetJobID is
   select job_id
    from xdp_adapter_admin_reqs
   where request_id = p_RequestId;

l_JobId number := -1;

begin

for v_GetJobId in c_GetJobID loop
	l_JobId := v_GetJobId.job_id;

	exit;
end loop;

if l_JobId = -1 then
	raise no_data_found;
end if;

return l_JobId;

end Get_Job_Id_For_Request;

Function Get_Fe_Id_For_name (p_FeName in varchar2) return number
is
 cursor c_GetFEiD is
   select fe_id
    from xdp_fes
   where UPPER(fulfillment_element_name) = UPPER(p_FeName);

l_FEId number := -1;

begin

for v_GetFeId in c_GetFEid loop
	l_FeID := v_GetFeId.fe_id;

	exit;
end loop;

if l_FeID = -1 then
	raise no_data_found;
end if;

return l_FEID;

end Get_Fe_Id_For_Name;

Function Is_Max_Connection_Reached (p_fe_id in NUMBER) return boolean
is

l_CurrentCount number := 0;
l_MaxCount number := 0;
begin
	select count(*)
	into l_CurrentCount
	from XDP_ADAPTER_REG
	where FE_ID = p_fe_id and
	ADAPTER_STATUS not in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
-- (ankung)			XDP_ADAPTER.pv_statusStopping,
--				XDP_ADAPTER.pv_statusTerminating,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem);

	select MAX_CONNECTION
	into l_MaxCount
	from XDP_FES
	where FE_ID = p_fe_id;

	if l_CurrentCount < l_maxCount then
		return TRUE;
	else
		return FALSE;
	end if;
end Is_Max_Connection_Reached;

--
-- Procedure to delete an Adapter
--
PROCEDURE Delete_Adapter (p_channel_name IN VARCHAR2)
IS

 cursor c_GetAdapterAdminReqs is
 select xar.request_id
 from xdp_adapter_admin_reqs xar
 where channel_name = p_channel_name;

BEGIN
	-- Cleanup XDP_ERROR_LOG
	BEGIN
		DELETE FROM xdp_error_log WHERE
			object_type = XDP_ADAPTER.pv_errorObjectTypeAdapter and
			object_key = p_channel_name;
	EXCEPTION
	-- Not an error if no errors exists for the adapter
	--
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	-- Cleanup request audit table
	BEGIN
		DELETE FROM xdp_adapter_audit WHERE channel_name = p_channel_name;
	EXCEPTION
	-- Not an error if no rows exist in audit table
	--
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	-- Delete all occurences of the requests and dbms_jobs for the adapter from the
	-- XDP_ADAPTER_ADMIN_REQS table if present
	--
	for v_AdapterReq in c_GetAdapterAdminReqs loop
		RemoveAdapterAdminReq (p_RequestID => v_AdapterReq.request_id);
	END LOOP;

	-- Delete the Adapter from the XDP_ADAPTER_REG table
	--
	DELETE FROM xdp_adapter_reg WHERE  channel_name = p_channel_name;

END Delete_Adapter;

--
-- Procedure to delete all Adapter for a FE
--
PROCEDURE Delete_Adapters_For_Fe (p_fe_id IN NUMBER)
IS

 cursor c_GetAdapters is
 select channel_name
 from xdp_adapter_reg
 where fe_id = p_fe_id;

BEGIN
	-- Delete all adapters belonging to the FE, if present

	for v_Adapters in c_GetAdapters loop
		Delete_Adapter (p_channel_name => v_Adapters.channel_name);
	END LOOP;

END Delete_Adapters_For_Fe;

PROCEDURE Audit_Adapter_Admin_Request (p_RequestID in number,
			p_RequestType in varchar2,
			p_RequestDate in date,
			p_RequestedBy in varchar2,
			p_Freq in number,
			p_RequestStatus in varchar2,
			p_RequestMessage in varchar2,
			p_ChannelName in varchar2)
IS

 cursor c_GetAdapterInfo is
   select xag.adapter_name,
	  xag.adapter_status,
	  xag.adapter_type,
	  xag.service_instance_id,
	  xag.connect_on_demand_flag,
	  xag.max_idle_time_minutes,
	  xag.cmd_line_options,
	  xag.cmd_line_args,
	  xag.log_level,
	  xag.log_file_name
    from
	 xdp_adapter_reg xag
   where xag.channel_name = p_ChannelName;

l_AdapterName 		varchar2(40);
l_AdapterStatus		varchar2(40);
l_AdapterType		varchar2(40);
l_ConcQID 		number;
l_COD 			varchar2(1);
l_MaxIdleTime 		number;
l_CmdOptions 		varchar2(240);
l_CmdArgs 		varchar2(240);
l_LogLevel 		varchar2(40);
l_LogFileName 		varchar2(240);

BEGIN
	for v_GetAdapterInfo in c_GetAdapterInfo loop

		l_AdapterName := v_GetAdapterInfo.adapter_name;
		l_AdapterStatus := v_GetAdapterInfo.adapter_status;
		l_AdapterType := v_GetAdapterInfo.adapter_type;
		l_ConcQID := v_GetAdapterInfo.service_instance_id;
		l_COD := v_GetAdapterInfo.connect_on_demand_flag;
		l_MaxIdleTime := v_GetAdapterInfo.max_idle_time_minutes;
		l_CmdOptions := v_GetAdapterInfo.cmd_line_options;
		l_CmdArgs := v_GetAdapterInfo.cmd_line_args;
		l_LogLevel := v_GetAdapterInfo.log_level;
		l_LogFileName := v_GetAdapterInfo.log_file_name;

		exit;
	end loop;

  	insert into xdp_adapter_audit (
			adapter_audit_id,
			channel_name,
		 	request_type,
		 	request_status,
		 	completion_date,
		 	requested_by_user,
			adapter_name,
			adapter_status,
			adapter_type,
			service_instance_id,
			connect_on_demand_flag,
			max_idle_time_minutes,
			cmd_line_options,
			cmd_line_args,
			log_file_name,
			application_id,
                      	created_by,
                      	creation_date,
                      	last_updated_by,
                      	last_update_date,
                      	last_update_login)
  		values
               	      ( XDP_ADAPTER_AUDIT_S.NEXTVAL,
			p_ChannelName,
		 	p_RequestType,
		 	p_RequestStatus,
			sysdate,
		 	p_RequestedBy,
                      	l_AdapterName,
			l_AdapterStatus,
			l_AdapterType,
			l_ConcQID,
			l_COD,
			l_MaxIdleTime,
			l_CmdOptions,
			l_CmdArgs,
			l_LogFileName,
  			XDP_ADAPTER.pv_AppID,
                      	FND_GLOBAL.USER_ID,
                      	sysdate,
                      	FND_GLOBAL.USER_ID,
                      	sysdate,
                      	FND_GLOBAL.LOGIN_ID);

END Audit_Adapter_Admin_Request;

--Function Is_Adapter_Available (p_fe_id in NUMBER, p_AdapterType in VARCHAR2) return boolean;
Procedure Are_Adapter_Generics_Available (p_fe_id in NUMBER, p_AdapterType in VARCHAR2,
				p_GenCountActive OUT NOCOPY NUMBER, p_GenCountFuture OUT NOCOPY NUMBER)
is
	cursor c_get_valid_generics (c_fe_id NUMBER, c_AdapterType VARCHAR2) is
	select XGC.START_DATE
	from XDP_FE_SW_GEN_LOOKUP XSW, XDP_FE_GENERIC_CONFIG XGC
	where XGC.FE_ID = c_fe_id and
	XSW.ADAPTER_TYPE = c_AdapterType and
	XSW.FE_SW_GEN_LOOKUP_ID = XGC.FE_SW_GEN_LOOKUP_ID and
	((XGC.END_DATE is null) or ((XGC.END_DATE is not null) and (XGC.END_DATE > SYSDATE)));
begin
	p_GenCountActive := 0;
	p_GenCountFuture := 0;

	for v_GetValidGens in c_get_valid_generics (p_fe_id, p_AdapterType) loop
		if (v_GetValidGens.START_DATE <= SYSDATE) then
			p_GenCountActive := p_GenCountActive + 1;
		else
			p_GenCountFuture := p_GenCountFuture + 1;
		END IF;
	END LOOP;

end Are_Adapter_Generics_Available;

Function Is_Message_Adapter_Available(p_fe_name in varchar2) return VARCHAR2

is
l_adapter_name varchar2(80) := NULL;

	--
	-- NOTE: This method should always be exactly the same as
	-- XNP_UTILS.Get_Adapter_Using_FE(p_fe_name).
	-- We were not able to call this method directly from that
	-- function because of the PRAGMA restrictions
	--

 cursor c_getadapter IS
	SELECT xad.adapter_name
	FROM xdp_adapter_reg xad, xdp_adapter_types_b t,xdp_fes XFE
	WHERE XAD.fe_id = XFE.fe_id
          AND XFE.fulfillment_element_name = p_fe_name
	  AND xad.adapter_type = t.adapter_type
	  AND application_mode='QUEUE'
	  AND xad.adapter_status not in (XDP_ADAPTER.pv_statusNotAvailable)
 	ORDER BY
	  DECODE(adapter_status, xdp_adapter.pv_statusRunning, 1,
                 xdp_adapter.pv_statusSuspended, 2,
                 xdp_adapter.pv_statusDisconnected, 3,
                 xdp_adapter.pv_statusStopped, 4, 5)
          ASC ;

BEGIN
   if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;

   open c_getadapter;

   fetch c_getadapter into l_adapter_name;

   if c_getadapter%NOTFOUND then
	l_adapter_name := NULL;
   end if;

   return l_adapter_name;
exception
when others then
    if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;
   raise;

END Is_Message_Adapter_Available;


Function Is_Message_Adapter_Available(p_fe_id in number) return VARCHAR2

is
 l_adapter_name varchar2(80) := NULL;

 cursor c_getadapter(FEID number) is
	SELECT xad.adapter_name
	FROM xdp_adapter_reg xad, xdp_adapter_types_b t
	WHERE xad.adapter_type = t.adapter_type
	AND FE_ID = FEID
	AND application_mode='QUEUE'
	AND xad.adapter_status not in (XDP_ADAPTER.pv_statusNotAvailable)
 order by
 DECODE(adapter_status, xdp_adapter.pv_statusRunning, 1,
         xdp_adapter.pv_statusSuspended, 2,
         xdp_adapter.pv_statusDisconnected, 3,
         xdp_adapter.pv_statusStopped, 4, 5)
  ASC ;

BEGIN

   if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;

   open c_getadapter(p_fe_id);

   fetch c_getadapter into l_adapter_name;

   if c_getadapter%NOTFOUND then
	l_adapter_name := NULL;
   end if;

   return l_adapter_name;

exception
when others then
    if c_getadapter%ISOPEN then
      close c_getadapter;
   end if;
   raise;
end Is_Message_Adapter_Available;


 /*
    Check if any Adapter is running for
    a given Fulfillment Element
 */
 Function Is_FE_Adapter_Running(p_fe_id in number)
   return BOOLEAN
 IS
  lv_exists varchar2(1) := 'N';

   CURSOR c_IsAdapterRunning is
     select 'Y' yahoo
     from dual
     where exists(
	  select 1
        from XDP_ADAPTER_REG
        where fe_id = p_fe_id
         and adapter_status not in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem)
	);
 BEGIN
   for v_IsAdapterRunning in c_IsAdapterRunning loop
	lv_exists := v_IsAdapterRunning.yahoo;
	exit;
   end loop;

   if lv_exists = 'Y' then
     return TRUE;
   else
     return FALSE;
   end if;

 END Is_FE_Adapter_Running;

 /*
    Check if any Adapter is running for
    a given Fulfillment Element Type
 */
 Function Is_FEType_Adapter_Running(p_fetype_id in number)
   return BOOLEAN
IS
  lv_exists varchar2(1) := 'N';

   CURSOR c_IsAdapterRunning is
     select 'Y' yahoo
     from dual
     where exists(
	  select 1
        from XDP_ADAPTER_REG arn, XDP_FES fet
        where arn.fe_id = fet.fe_id
         and fet.fetype_id = p_fetype_id
         and arn.adapter_status not in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem)
	);
 BEGIN

   for v_IsAdapterRunning in c_IsAdapterRunning loop
	lv_exists := v_IsAdapterRunning.yahoo;
	exit;
   end loop;

   if lv_exists = 'Y' then
     return TRUE;
   else
     return FALSE;
   end if;

END Is_FEType_Adapter_Running;


Function Is_Adapter_Implemented (p_ChannelName in varchar2) return boolean
is
	l_ClassName varchar2(240);
begin
	select b.adapter_class into l_ClassName
	from xdp_adapter_reg a, xdp_adapter_types_b b
	where a.CHANNEL_NAME = p_ChannelName and
	a.adapter_type = b.adapter_type;

	if (upper(l_ClassName) = 'NONE') then
		return FALSE;
	else
		return TRUE;
	END IF;

end Is_Adapter_Implemented;

Function Verify_Adapter (p_ChannelName in varchar2) return boolean
is
 PRAGMA AUTONOMOUS_TRANSACTION;

 l_FeID number;
 l_ProcessID number;
 l_ConcQID number;

 l_AdapterLocked1 varchar2(1) := 'N';

begin
        if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER_CORE_DB.VERIFY_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

              --skilaru 05/17/2002
              --If the channel is of type PIPE then we dont need to lock..
              IF ( checkLockRequired( p_ChannelName ) ) THEN
		l_AdapterLocked1 := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify('SESSION_'||p_ChannelName);
              END IF;

		if l_AdapterLocked1 = 'Y' then

			-- Adapter NOT running, release the SESSION lock

			--dbms_output.put_line('Got SESSION lock for: ' || p_ChannelName);
			--dbms_output.put_line('Adapter NOT RUNNING');

			if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock('SESSION_'||p_ChannelName) = 'N' then
                             if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER_CORE_DB.VERIFY_ADAPTER',
					'Could not release SESSION lock, Channel name: '||p_ChannelName);
                             end if;
			end if;

			XDP_ADAPTER_CORE_DB.FetchAdapterInfo(
				p_ChannelName => p_ChannelName,
				p_FEID => l_FeID,
	  			p_ProcessID => l_ProcessID,
	  			p_ConcQID => l_ConcQID);

			-- Cannot use XDP_ADAPTER_CORE_DB.Update_Adapter_Status, an autonomous
			-- procedure

			XDP_ADAPTER_CORE_DB.UpdateAdapter (
					p_ChannelName 	=> p_ChannelName,
					p_Status 	=> XDP_ADAPTER.pv_statusStoppedError
					);

			XDP_ERRORS_PKG.Set_Message (
					p_object_type 		=> XDP_ADAPTER.pv_errorObjectTypeAdapter,
					p_object_key 		=> p_ChannelName,
					p_message_name 		=> 'XDP_ADAPTER_ABNORMAL_EXIT',
					p_message_parameters	=> 'PROCESS_ID='||l_ProcessID||'#XDP#');

			commit;

			return false;
		else
			--dbms_output.put_line('Did not get SESSION lock for: ' || p_ChannelName);
			--dbms_output.put_line('Adapter RUNNING');

			-- Could not get lock, Adapter running, update last_verified_date
			XDP_ADAPTER_CORE_DB.UpdateAdapter (
					p_ChannelName => p_ChannelName,
					p_LastVerified => sysdate);
		end if;
	else
		-- Adapter not implemented, so Adapter is 'running', update last_verified_date
		XDP_ADAPTER_CORE_DB.UpdateAdapter (
				p_ChannelName => p_ChannelName,
				p_LastVerified => sysdate);
	end if;

	commit;

	return true;

end Verify_Adapter;

Function Is_Adapter_Automatic (p_ChannelName in varchar2) return boolean
is
	l_StartupMode varchar2(30);
begin
	select a.startup_mode into l_StartupMode
	from xdp_adapter_reg a
	where a.CHANNEL_NAME = p_ChannelName;

	if (upper(l_StartupMode) IN (XDP_ADAPTER.pv_startAutomatic, XDP_ADAPTER.pv_startOnDemand)) then
		return TRUE;
	else
		return FALSE;
	END IF;

end Is_Adapter_Automatic;

Function GetAdapterRestartCount return number
is
 l_ProfileValue varchar2(40);
begin
	if fnd_profile.defined('XDP_ADAPTER_RESTART_COUNT') then
		fnd_profile.get('XDP_ADAPTER_RESTART_COUNT', l_ProfileValue);
			if to_number(l_ProfileValue) <= 0 then
				l_ProfileValue := '5';
			end if;
	else
		l_ProfileValue := '5';
	end if;

	return to_number(l_ProfileValue);

end GetAdapterRestartCount;

-- ************** Added - sacsharm - END *********************

Function checkLockRequired( p_Channelname in varchar2) return boolean IS

  cursor getApplMode IS
  SELECT atb.application_mode
    FROM xdp_adapter_reg ar, xdp_adapter_types_b atb
   WHERE ar.channel_name = p_Channelname
     AND ar.adapter_type = atb.adapter_type;

 lv_appl_mode VARCHAR2(40);
 lv_is_lock_required BOOLEAN := TRUE;

Begin

  FOR lv_rec in getApplMode LOOP
    lv_appl_mode := lv_rec.application_mode;
    IF( lv_appl_mode <> 'PIPE' ) THEN
      lv_is_lock_required := FALSE;
    END IF;
  END LOOP;

  RETURN lv_is_lock_required;

EXCEPTION
  WHEN others THEN
    RAISE;
END checkLockRequired;


-----------------------------------------------------------
Procedure Copy_FET_Attribute(
	p_fe_sw_gen_lookup_id in NUMBER,
        p_adapter_type IN VARCHAR2,
	p_caller_id NUMBER,
	x_retcode OUT NOCOPY NUMBER,
	x_errbuf OUT NOCOPY VARCHAR2)
AS
	cursor c_adapter_type_attribute is
		select ATTRIBUTE_NAME,DEFAULT_VALUE,DISPLAY_NAME,DESCRIPTION
		from XDP_ADAPTER_TYPE_ATTRS_VL
		where ADAPTER_TYPE = p_adapter_type
		and attribute_name not in (
			select FE_ATTRIBUTE_NAME from xdp_fe_attribute_def_vl
			where fe_sw_gen_lookup_id = p_fe_sw_gen_lookup_id);

	cursor c_adapter_types is
     		SELECT BASE_ADAPTER_TYPE FROM XDP_ADAPTER_TYPES_B
		WHERE ADAPTER_TYPE = p_adapter_type;

	l_rowid ROWID;
	l_base_type XDP_ADAPTER_TYPES_B.ADAPTER_TYPE%TYPE;
	l_fe_attribute_id number;
BEGIN
	x_retcode := 0;
    	SavePoint CopyFETATTR;

	FOR l_at_attr in c_adapter_type_attribute LOOP

    		select XDP.XDP_FE_ATTRIBUTE_DEF_S.nextval into l_fe_attribute_id from dual;

		XDP_FE_ATTRIBUTE_DEF_PKG.INSERT_ROW(
			l_rowid,
			l_fe_attribute_id,
			p_fe_sw_gen_lookup_id,
			l_at_attr.ATTRIBUTE_NAME,
			'N',
			l_at_attr.DEFAULT_VALUE,
			null,
			l_at_attr.DISPLAY_NAME,
			l_at_attr.DESCRIPTION,
			sysdate,
			p_caller_id,
			sysdate,
			p_caller_id,p_caller_id);


	END LOOP;
--
-- Should be only one entry for this cursor. Recursively copy parent adapter attributes
--
	FOR l_base_type in c_adapter_types LOOP
		IF l_base_type.BASE_ADAPTER_TYPE is not NULL THEN
		   Copy_FET_Attribute(
        		p_fe_sw_gen_lookup_id,
        		l_base_type.BASE_ADAPTER_TYPE,
       		 	p_caller_id,
        		x_retcode,
        		x_errbuf);
		END IF;
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN
	        rollback to CopyFETATTR;
      	  	x_retcode := SQLCODE;
        	x_errbuf := sqlerrm;
END Copy_FET_Attribute;

-----------------------------------------------------------
Procedure Copy_FE(
        p_FeName in varchar2,
	p_FeDisplayName in varchar2,
        p_FeID in varchar2,
        p_NewFeID in NUMBER,
        p_CallerID in NUMBER,
	x_retcode OUT NOCOPY NUMBER,
	x_errbuf OUT NOCOPY VARCHAR2)
AS
    l_rowid ROWID;
    l_new_feId Number;
    l_new_generic_config_Id Number;
    CURSOR aFe is
        SELECT fetype_id,
               max_connection,
               min_connection,
               session_controller_id,
               valid_date,
               invalid_date,
               geo_area_id,
               role_name,
               network_unit_id,
               description
        from xdp_fes_vl
        where fe_id = p_FeID;
    CURSOR c_fe_generic_config(l_fe_id number) IS
        SELECT
            fe_generic_config_id,
            fe_sw_gen_lookup_id,
            start_date,
            end_date,
            sw_start_proc,
            sw_exit_proc
        FROM XDP_FE_GENERIC_CONFIG
        WHERE fe_id = l_fe_id;
    CURSOR c_fe_attribute_val(l_fe_config_id number) IS
        SELECT
            fe_generic_config_id,
            fe_attribute_id,
            fe_attribute_value,
            display_name,
            description
        FROM XDP_FE_ATTRIBUTE_VAL_VL
        WHERE fe_generic_config_id = l_fe_config_id;
BEGIN
    x_retcode := 0;
    SavePoint CopyFE;
    select XDP.xdp_fes_s.nextval into l_new_feId from dual;

    for l_FeRecord in aFe loop
        XDP_FES_PKG.INSERT_ROW(
            l_rowid,
            l_new_feId,
            l_FeRecord.fetype_id,
            p_FeName,
            l_FeRecord.MAX_CONNECTION,
            l_FeRecord.MIN_CONNECTION,
            l_FeRecord.SESSION_CONTROLLER_ID,
            l_FeRecord.VALID_DATE,
            l_FeRecord.INVALID_DATE,
            l_FeRecord.GEO_AREA_ID,
            l_FeRecord.ROLE_NAME,
            l_FeRecord.NETWORK_UNIT_ID,
            p_FeDisplayName,
            l_FeRecord.DESCRIPTION,
            SYSDATE,
            p_CallerID,
            SYSDATE,
            p_CallerID,
            p_CallerID
         );
    END LOOP;

    FOR l_fe_gen_config in c_fe_generic_config(p_FeID) LOOP
        select xdp_fe_generic_config_s.nextval into l_new_generic_config_Id from dual;

        insert into xdp_fe_generic_config (
            fe_generic_config_id,
            fe_id,
            fe_sw_gen_lookup_id,
            start_date,
            end_date,
            sw_start_proc,
            sw_exit_proc,
            creation_date,
            last_update_date,
            last_updated_by,
            created_by,
            last_update_login,
            security_group_id)
        Values (
            l_new_generic_config_Id,
            l_new_feId,
            l_fe_gen_config.fe_sw_gen_lookup_id,
            l_fe_gen_config.start_date,
            l_fe_gen_config.end_date,
            l_fe_gen_config.sw_start_proc,
            l_fe_gen_config.sw_exit_proc,
            sysdate,
            sysdate,
            p_CallerID,
            p_CallerID,
            p_CallerID,
            null
        );
        FOR l_fe_val in c_fe_attribute_val(l_fe_gen_config.fe_generic_config_id) LOOP
            XDP_FE_ATTRIBUTE_VAL_PKG.INSERT_ROW (
                l_rowid,
                l_fe_val.fe_attribute_id,
                l_new_generic_config_Id,
                l_fe_val.fe_attribute_value,
                l_fe_val.display_name,
                l_fe_val.description,
                SYSDATE,
                p_CallerID,
                SYSDATE,
                p_CallerID,
                p_callerID
             );
        END LOOP;

     END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        rollback to CopyFE;
        x_retcode := SQLCODE;
        x_errbuf := sqlerrm;
END Copy_FE;

begin

 pv_AckTimeout := GetAckTimeOut;
 select instance_name into pv_InstanceName from v$instance;

end XDP_ADAPTER_CORE_DB;

/
