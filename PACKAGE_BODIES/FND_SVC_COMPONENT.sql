--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMPONENT" AS
/* $Header: AFSVCMPB.pls 120.4 2006/05/03 07:45:32 nravindr ship $ */

------------------------------------------------------------------------------
-- **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
-- pv_system_guid - the value of local system guid
-- pv_schema_name - the value of local WF schema
-- **** PRIVATE VARIABLE - NOT FOR CUSTOMER USE ******
pv_system_guid  raw(16);
pv_schema_name  varchar2(30);

pv_last_agent_name   varchar2(30);
pv_last_queue_name   varchar2(80);
pv_last_recipients   varchar2(30);

pv_install_mode varchar2(30);
------------------------------------------------------------------------------

-- Private declarations start

e_ContainerNotRunning 		EXCEPTION;

Procedure Get_Container_Info(p_Component_Id in number,
			   p_Container_Type out nocopy varchar2,
			   p_Container_Name out nocopy varchar2);

Procedure Raise_Control_Event (p_Component_Id in number default -1,
				p_Control_Operation in varchar2,
				p_Container_Type in varchar2,
				p_CPID in number,
				p_Params in varchar2 default null);

Function Get_ConcQ_Name (ApplId in number, ConcQID in number) return varchar2;

Procedure Get_ConcQ_ID (ConcQName in varchar2, ApplId out nocopy number, ConcQId out nocopy number);

PROCEDURE Refresh_Container
         ( p_container_type     IN VARCHAR2,
           p_container_name     IN VARCHAR2,
           p_params		IN VARCHAR2,
           p_retcode		OUT NOCOPY NUMBER,
           p_errbuf		OUT NOCOPY VARCHAR2);

-- Private declarations end

PROCEDURE Delete_Request
          ( p_component_request_id IN NUMBER)
AS
  l_job_id         fnd_svc_comp_requests.job_id%TYPE;

BEGIN

  --
  -- NOTE: This is in PL/SQL because it is called both by Execute_Request and
  --       by the Java code
  --

  SELECT job_id
  INTO l_job_id
  FROM fnd_svc_comp_requests
  WHERE component_request_id = p_component_request_id;

  --
  -- Delete DBMS_JOB
  --
  DBMS_Job.Remove(
    job => l_job_id);

  --
  -- Delete the request
  --
  FND_SVC_COMP_REQUESTS_PKG.DELETE_ROW(
    x_component_request_id => p_component_request_id);

END Delete_Request;


PROCEDURE Execute_Request
          ( p_component_request_id IN NUMBER)
AS

  l_component_id       fnd_svc_comp_requests.component_id%TYPE;
  l_event_name         fnd_svc_comp_requests.event_name%TYPE;
  l_job_id             fnd_svc_comp_requests.job_id%TYPE;
  l_event_params       fnd_svc_comp_requests.event_params%TYPE;
  l_event_frequency    fnd_svc_comp_requests.event_frequency%TYPE;
  l_requested_by_user  fnd_svc_comp_requests.requested_by_user%TYPE;

  l_component_name     fnd_svc_components.component_name%TYPE;
  l_component_type     fnd_svc_components.component_type%TYPE;
  l_component_status   fnd_svc_components.component_status%TYPE;
  l_container_type     fnd_svc_components.container_type%TYPE;
  l_container_name     fnd_svc_components.standalone_container_name%TYPE;

  l_request_history_id fnd_svc_comp_requests_h.request_history_id%TYPE;
  l_rowid              VARCHAR2(64);
  l_Status varchar2(30) := FND_SVC_COMPONENT.pv_adminStatusCompleted;

  l_ErrorMsg     		VARCHAR2 (4000);
  l_RetCode      		NUMBER := 0;

BEGIN

  --
  -- NOTE: This is in PL/SQL because it is called by DBMS_JOB
  --

  --
  -- Retrieve request details
  --
  begin

      SELECT a.component_id, event_name, event_params, event_frequency, requested_by_user, component_name,
             component_status, component_type, container_type, standalone_container_name
      INTO l_component_id, l_event_name, l_event_params, l_event_frequency, l_requested_by_user,
           l_component_name, l_component_status, l_component_type, l_container_type, l_container_name
      FROM fnd_svc_comp_requests a, fnd_svc_components b
      WHERE component_request_id = p_component_request_id and
            a.component_id = b.component_id;

      IF l_container_type = pv_Container_Type_GSM THEN
        SELECT concurrent_queue_name
        INTO l_container_name
        FROM fnd_svc_components_v
        WHERE component_id = l_component_id;
      END IF;

    EXCEPTION
    WHEN others then
    -- WHEN NO_DATA_FOUND then

    -- What can we do? - nothing
    -- This is really weird, request is getting executed and
    -- request is not there? Maybe, request got deleted and job is still
    -- getting executed. Donot do anything, return
    -- With the deletion of request, job for future will anyway be deleted
        if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.STRING(wf_log_pkg.LEVEL_ERROR,
                            'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.request_lookup_failed',
                            'Could not get request info, SQLCODE: '||SQLCODE);
        end if;
        return;
  END;

  if (wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.STRING (wf_log_pkg.LEVEL_EXCEPTION,
                        'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.executing',
                        'Request Type: '||l_event_name||
                        ', Job no.: '||l_job_id||
                        ', Component_id: '||l_Component_id);
  end if;

  if l_event_name = FND_SVC_COMPONENT.pv_Event_Suspend then

      FND_SVC_COMPONENT.Suspend_Component(l_Component_id, l_RetCode, l_ErrorMsg);

  elsif l_event_name = FND_SVC_COMPONENT.pv_Event_Resume then

      FND_SVC_COMPONENT.Resume_Component(l_Component_id, l_RetCode, l_ErrorMsg);

  elsif l_event_name = FND_SVC_COMPONENT.pv_Event_Stop then

      FND_SVC_COMPONENT.Stop_Component(l_Component_id, l_RetCode, l_ErrorMsg);

  elsif l_event_name = FND_SVC_COMPONENT.pv_Event_Start then

      FND_SVC_COMPONENT.Start_Component(l_Component_id, l_RetCode, l_ErrorMsg);

  elsif l_event_name = FND_SVC_COMPONENT.pv_Event_Refresh then

      FND_SVC_COMPONENT.Refresh_Component(l_Component_id, l_event_params, l_RetCode, l_ErrorMsg);

  else

      FND_SVC_COMPONENT.Generic_Operation (l_Component_id, l_event_name, l_event_params, l_RetCode, l_ErrorMsg);

  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.STRING (wf_log_pkg.LEVEL_STATEMENT,
                       'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.executed',
                       'After component control operation, Return code: '||l_RetCode);
  end if;

  if l_RetCode = FND_SVC_COMPONENT.pv_retInvalidComponentState then

      -- SKIPPED
      l_Status := FND_SVC_COMPONENT.pv_adminStatusSkipped;

  elsif l_RetCode <> 0 then -- Container not running or other SQL error

      -- ERRORED
      l_Status := FND_SVC_COMPONENT.pv_adminStatusErrored;

  end if;

  --
  -- Delete the request if it's not a recurring request
  --
  IF (l_event_frequency is NULL OR
      l_event_frequency = 0) THEN

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.STRING (wf_log_pkg.LEVEL_STATEMENT,
                         'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.frequency',
                         'Frequency is null, removing job');
    end if;

    Delete_Request(p_component_request_id => p_component_request_id);

  END IF;

  --
  -- Audit the request history
  --

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.STRING (wf_log_pkg.LEVEL_STATEMENT,
                       'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.request_audit',
                       'Request audited with status: '||l_Status);
  end if;

  SELECT fnd_svc_comp_requests_h_s.nextval INTO l_request_history_id FROM dual;

  FND_SVC_COMP_REQUESTS_H_PKG.Insert_Row
    ( x_rowid => l_rowid
    , x_request_history_id => l_request_history_id
    , x_component_id => l_component_id
    , x_event_name => l_event_name
    , x_request_status => l_Status
    , x_requested_by_user => l_requested_by_user
    , x_completion_date => SYSDATE
    , x_component_name => l_component_name
    , x_component_status => l_component_status
    , x_component_type => l_component_type
    , x_container_type => l_container_type
    , x_container_name => l_container_name
    , x_event_params => l_event_params
    , x_created_by => 0 -- TODO
    , x_last_updated_by => 0 -- TODO
    , x_last_update_login => 0 -- TODO
    );

  commit;

EXCEPTION
  WHEN OTHERS THEN
      -- Can come here only because of some SQL error in FND_SVC_COMP_REQUESTS_H_PKG.Insert_Row
      -- Still we need to commit;
      if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.STRING (wf_log_pkg.LEVEL_ERROR,
                           'wf.plsql.FND_SVC_COMPONENT.EXECUTE_REQUEST.error',
                           'Unhandled error, SQLCODE: '||SQLCODE);
      end if;
      commit;

END EXECUTE_REQUEST;


FUNCTION Get_OAM_Rolled_Status_By_Type
         ( p_component_type    IN VARCHAR2)
         RETURN NUMBER
AS

  l_found_running_flag BOOLEAN := FALSE;

  CURSOR c_Components
  IS
    SELECT c.component_status
    FROM fnd_svc_components c
    WHERE c.component_type = NVL(p_component_type, c.component_type);

BEGIN
  --
  -- Loop through all components
  --
  FOR r_Component IN c_Components LOOP

    --
    -- If it is in "error", return DOWN immediately
    --
    IF (r_Component.component_status IN (pv_Status_Stopped_Error, pv_Status_Deactivated_System)) THEN

      RETURN pv_OAM_Status_Down;

    --
    -- If it is "running", mark it so and exit from the loop
    --
    ELSIF (r_Component.component_status IN (pv_Status_Running, pv_Status_Suspended)) THEN

      l_found_running_flag := TRUE;
      --EXIT;
    END IF;
  END LOOP;

  --
  -- If any were "running", return UP
  --
  IF l_found_running_flag THEN

    RETURN pv_OAM_Status_Up;

  --
  -- Otherwise, return NA (Not Available/Unknown)
  --
  ELSE

    RETURN pv_OAM_Status_NA;

  END IF;

END Get_OAM_Rolled_Status_By_Type;

PROCEDURE Insert_Param_Vals
          ( p_component_type    IN VARCHAR2
          , p_component_id      IN NUMBER)
AS
  CURSOR c_params IS
    SELECT parameter_id
         , default_parameter_value
    FROM fnd_svc_comp_params_b
    WHERE component_type = p_component_type;

    l_rowid                  VARCHAR2(64);
    l_component_parameter_id fnd_svc_comp_param_vals.component_parameter_id%TYPE;

  l_customization_level fnd_svc_components.customization_level%TYPE;
  l_created_by          NUMBER;
  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;

BEGIN

  --
  -- Loop through all parameters for specified component type
  --

  FOR param IN c_params LOOP

    --
    -- Retrieve next sequence value
    --
    SELECT fnd_svc_comp_param_vals_s.nextval
    INTO l_component_parameter_id
    FROM dual;

    --
    -- Retrieve common data from component
    --
    SELECT customization_level, created_by, last_updated_by, last_update_login
    INTO l_customization_level, l_created_by, l_last_updated_by, l_last_update_login
    FROM fnd_svc_components
    WHERE component_id = p_component_id;

    --
    -- Insert parameter value
    --
    FND_SVC_COMP_PARAM_VALS_PKG.INSERT_ROW
      ( x_rowid => l_rowid
      , x_component_parameter_id => l_component_parameter_id
      , x_component_id => p_component_id
      , x_parameter_id => param.parameter_id
      , x_parameter_value => param.default_parameter_value
      , x_customization_level => l_customization_level
      , x_created_by => l_created_by
      , x_last_updated_by => l_last_updated_by
      , x_last_update_login => l_last_update_login
      );
  END LOOP;

EXCEPTION
 WHEN OTHERS THEN
   WF_CORE.CONTEXT(pv_Package_Name, 'Insert_Param_Vals', p_component_type, p_component_id);

   RAISE;

END Insert_Param_Vals;

PROCEDURE Get_Container_Status
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2
	 , p_container_status	OUT NOCOPY VARCHAR2
	 , p_process_id		OUT NOCOPY NUMBER)
AS

  l_module_name    	 gv$session.module%TYPE;
  l_module_name_temp     gv$session.module%TYPE;
  l_action_temp          gv$session.action%TYPE;
  l_found     		 boolean;
  l_schema_name          gv$session.SCHEMANAME%TYPE;

  CURSOR c_containers_running (c_module_name VARCHAR2, c_schema_name VARCHAR2) IS
    -- SELECT module
    SELECT module, action
    FROM gv$session se
    -- WHERE se.module like c_module_name and se.action is not null;
    -- Bug fix for 3461327, retrieve the record with largest CPID.
    WHERE se.module like c_module_name
    -- Use Schema name to distinguish different service containers running on different
    -- schema. Bug 3630749
    and   se.SCHEMANAME like c_schema_name
    order by se.module desc;
    -- Action will be set to ACTIVE in start and null when Container is stopping

BEGIN

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                       'wf.plsql.FND_SVC_COMPONENT.Get_Container_Status.begin',
                       'p_container_type: '||p_container_type||
                       ', p_container_name:'||p_container_name);
  end if;

  p_container_status := pv_Container_Status_Stopped;
  l_found := FALSE;

  --
  -- Set search module name = '<Prefix>:<Container Type>:<Container Name>:%'
  --
  l_module_name :=
    pv_Connection_Name_Prefix || ':' ||
    p_container_type || ':' ||
    p_container_name || ':%';

  -- YOHUANG: Bug Fix for 3630749
  -- If APPS MODE, append APPS in module name to distinguish with standalone sessions.
  -- If Apps Mode, Use the WF_SCHEMA to distinguish between different standalone sessions.
  if (pv_install_mode = 'EMBEDDED') then
    l_module_name := 'APPS' || ':' || l_module_name;
    l_schema_name := '%';
  else
    l_schema_name := pv_schema_name;
  end if;

  FOR rec_running_container IN c_containers_running (l_module_name, l_schema_name) LOOP
  	l_module_name_temp := rec_running_container.module;
  	l_action_temp := rec_running_container.action;
	l_found := TRUE;
	exit;
  END LOOP;

  if l_found then
	-- Extract and set the p_process_id using l_module_name_temp
	-- l_module_name_temp should look like 'SVC:GSM:WFMAILER:5677'
	p_process_id := to_number(substr(l_module_name_temp,instr(l_module_name_temp,':',-1,1)+1));

        -- Action will be set to ACTIVE in start and null when Container is stopping
        if l_action_temp is null then
  	    p_container_status := pv_Container_Status_Stopping;
        else
  	    p_container_status := pv_Container_Status_Running;
        end if;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Get_Container_Status', p_container_type, p_container_name);
  RAISE;

END Get_Container_Status;

PROCEDURE Name_Container_Session
          ( p_container_type IN VARCHAR2
          , p_container_name IN VARCHAR2
	  , p_process_id IN NUMBER
	  , p_action_name IN VARCHAR2)
AS

  l_module_name     gv$session.module%TYPE;

BEGIN

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                       'wf.plsql.FND_SVC_COMPONENT.Name_Container_Session.begin',
                       'p_container_type: '||p_container_type||
                       ', p_container_name:'||p_container_name);
  end if;

  --
  -- Set module name = '[APPS]:<Prefix>:<Container Type>:<Container Name>:<Process Id>'
  --
  l_module_name :=
    pv_Connection_Name_Prefix || ':' ||
    p_container_type || ':' ||
    p_container_name || ':' ||
    p_process_id;

  -- YOHUANG: Bug Fix for 3630749
  -- If APPS MODE, append APPS in module name to distinguish with standalone sessions.
  if (pv_install_mode = 'EMBEDDED') then
    l_module_name := 'APPS' || ':' || l_module_name;
  end if;

  DBMS_APPLICATION_INFO.SET_MODULE
  (
    module_name => l_module_name
  , action_name => p_action_name
  );

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Name_Container_Session', p_container_type,
				p_container_name, p_process_id);
  RAISE;

END Name_Container_Session;

FUNCTION Retrieve_Parameter_Value
         ( p_parameter_name    IN VARCHAR2
         , p_component_id      IN NUMBER)
         RETURN VARCHAR2
AS
  l_result fnd_svc_comp_param_vals.parameter_value%TYPE;

BEGIN

  SELECT parameter_value
  INTO l_result
  FROM fnd_svc_comp_param_vals_v
  WHERE parameter_name = p_parameter_name
    AND component_id = p_component_id;

  RETURN l_result;

END Retrieve_Parameter_Value;


Function Get_Current_Status(p_Component_Id in NUMBER) return varchar2
is
	l_CurrentStatus fnd_svc_components.component_status%TYPE;
begin
	select component_status into l_CurrentStatus
		from fnd_svc_components where component_id = p_Component_Id;

	return l_CurrentStatus;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Get_Current_Status', p_Component_Id);
  RAISE;
end Get_Current_Status;


PROCEDURE Validate_Operation
		(p_Component_Id        IN NUMBER,
		p_Control_Operation   IN VARCHAR2,
		p_retcode	OUT NOCOPY NUMBER,
		p_errbuf	OUT NOCOPY VARCHAR2)
is

l_isValid boolean := false;
l_CurrentStatus fnd_svc_components.component_status%TYPE;

begin

 p_retcode := 0;

 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
		              'wf.plsql.FND_SVC_COMPONENT.IS_OPERATION_VALID.begin',
                      'p_Component_Id: '||p_Component_Id||
                      ', p_Control_Operation:'||p_Control_Operation);
 end if;

 l_CurrentStatus := Get_Current_Status (p_Component_Id => p_Component_Id);

 if p_Control_Operation = FND_SVC_COMPONENT.pv_opStart then

	if l_CurrentStatus in (FND_SVC_COMPONENT.pv_Status_Stopped,
					FND_SVC_COMPONENT.pv_Status_Stopped_Error,
					FND_SVC_COMPONENT.pv_Status_Deactivated_User,
					FND_SVC_COMPONENT.pv_Status_Deactivated_System) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opStop then

	if l_CurrentStatus not in (FND_SVC_COMPONENT.pv_Status_Stopped,
					FND_SVC_COMPONENT.pv_Status_Stopped_Error,
				    	FND_SVC_COMPONENT.pv_Status_Not_Configured,
					FND_SVC_COMPONENT.pv_Status_Deactivated_User,
					FND_SVC_COMPONENT.pv_Status_Deactivated_System) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opSuspend then

	if l_CurrentStatus = FND_SVC_COMPONENT.pv_Status_Running then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opResume then

	if l_CurrentStatus = FND_SVC_COMPONENT.pv_Status_Suspended then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opUpdate then

	if l_CurrentStatus in (FND_SVC_COMPONENT.pv_Status_Stopped,
				FND_SVC_COMPONENT.pv_Status_Stopped_Error,
				FND_SVC_COMPONENT.pv_Status_Not_Configured,
				FND_SVC_COMPONENT.pv_Status_Deactivated_User,
				FND_SVC_COMPONENT.pv_Status_Deactivated_System) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opDelete then

	if l_CurrentStatus in (FND_SVC_COMPONENT.pv_Status_Stopped,
				FND_SVC_COMPONENT.pv_Status_Stopped_Error,
				FND_SVC_COMPONENT.pv_Status_Not_Configured,
				FND_SVC_COMPONENT.pv_Status_Deactivated_User,
				FND_SVC_COMPONENT.pv_Status_Deactivated_System) then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 elsif p_Control_Operation = FND_SVC_COMPONENT.pv_opGeneric or
	p_Control_Operation = FND_SVC_COMPONENT.pv_opRefresh then

	-- Generic operation

	if l_CurrentStatus = FND_SVC_COMPONENT.pv_Status_Running then
		l_isValid := true;
	else
		l_isValid := false;
	end if;

 else
	l_isValid := false;

 end if;

 if not l_isValid then
	p_retCode := pv_retInvalidComponentState;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_COMP_INVALID_EVENT');
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                         'wf.plsql.FND_SVC_COMPONENT.VALIDATE_OPERATION.invalid_event',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;
 END IF;

EXCEPTION

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.VALIDATE_OPERATION.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Validate_Operation;

Procedure Get_Container_Info(p_Component_Id in number,
			   p_Container_Type out nocopy varchar2,
			   p_Container_Name out nocopy varchar2)
is
l_Concurrent_Queue_Name fnd_concurrent_queues.concurrent_queue_name%TYPE;
l_Standalone_Container_Name fnd_svc_components.standalone_container_name%TYPE;
begin
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
	                      'wf.plsql.FND_SVC_COMPONENT.GET_CONTAINER_INFO.begin',
                          'p_Component_Id: '||p_Component_Id);
    end if;

	select container_type, concurrent_queue_name, standalone_container_name
	into p_Container_Type, l_Concurrent_Queue_Name, l_Standalone_Container_Name
	from fnd_svc_components_v where component_id = p_Component_Id;

	if (p_Container_Type = FND_SVC_COMPONENT.pv_Container_Type_GSM) then
		p_Container_Name := l_Concurrent_Queue_Name;
	else
		p_Container_Name := l_Standalone_Container_Name;
	END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Get_Container_Info', p_Component_Id);
  RAISE;
end Get_Container_Info;

--
-- Update_Status
--   Procedure to update the status of the given Service Component in
--   the FND_SVC_COMPONENTS table and to raise a System Alert if necessary.
--   If the component staus is either STOPPED_ERROR or DEACTIVATED_SYSTEM
--   then a System Alert is raised with the pre-defined message.
--   For more information, refer Bug 3786007.
--
-- IN
--   p_Component_Id       - Component ID
--   p_Status             - Status of the Component
--   p_Status_Info        - Status Information
--   p_Last_Updated_By    - ID of the user who is changing the status
--   p_Last_Updated_Login - Login ID of the user who is changing the status
--
PROCEDURE Update_Status (p_Component_Id      IN NUMBER,
			 p_Status            IN VARCHAR2,
			 p_Status_Info       IN VARCHAR2,
			 p_Last_Updated_By   IN NUMBER,
			 p_Last_Update_Login IN NUMBER)
is
   l_component_name fnd_svc_components.component_name%TYPE;

begin
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
			   'wf.plsql.FND_SVC_COMPONENT.UPDATE_STATUS.begin',
			   'p_Component_Id: '||p_Component_Id
			   ||' p_Status: '||p_Status);
    end if;

    UPDATE FND_SVC_COMPONENTS
    SET    component_status  = p_Status,
           component_status_info = decode(p_Status_Info, null, component_status_info,
					  'NULL', null, substrb(p_Status_Info,1,1996)),
           last_update_date  = sysdate,
	   last_updated_by   = p_Last_Updated_By,
           last_update_login = p_Last_Update_Login
    WHERE  component_id = p_Component_Id;

    -- Check whether the System Alert is to be raised
    if(upper(p_Status) in ('STOPPED_ERROR', 'DEACTIVATED_SYSTEM')) then

       -- The  message is logged with UNEXPECTED log level and so it is
       -- shown as a System Alert in the OAM (apps). In Standalone, the
       -- wf_log_pkg.set_name, set_token, message methods are empty implementations.

       -- Set the Message depending on the status
       if(upper(p_Status) = 'STOPPED_ERROR') then
	  WF_LOG_PKG.SET_NAME('FND', 'FND_SVC_ALERT_STOPPED_ERROR');
       else
	  WF_LOG_PKG.SET_NAME('FND', 'FND_SVC_ALERT_SYS_DEACTIVATED');
       end if;

       SELECT TRIM(component_name)
       INTO   l_component_name
       FROM   fnd_svc_components
       WHERE  component_id = p_Component_Id;

       WF_LOG_PKG.SET_TOKEN('COMPONENT_NAME', l_component_name);
       WF_LOG_PKG.SET_TOKEN('ERROR_CONTEXT', nvl(p_Status_Info,'Not provided.'));
       WF_LOG_PKG.MESSAGE(WF_LOG_PKG.LEVEL_UNEXPECTED, 'oracle.apps.fnd.cp.gsc', TRUE);

    end if;

 EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Update_Status', p_Component_Id, p_Status, p_Status_Info);
    RAISE;
end Update_Status;

--
-- Get_Component_Status
--   Function that returns the current status of the given Component
--   after verifying its Container status
-- IN
--   p_Component_Name     - Component Name
--
FUNCTION Get_Component_Status
         (p_Component_Name IN VARCHAR2)
         RETURN VARCHAR2
is
   l_Component_Id   fnd_svc_comp_requests.component_id%TYPE;
   l_Container_Type fnd_svc_components.container_type%TYPE;
   l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
   l_Current_Status fnd_svc_components.component_status%TYPE;

begin
   -- Get the Component Id
   SELECT component_id
   INTO   l_Component_Id
   FROM   fnd_svc_components
   WHERE  component_name = p_component_Name;

   -- Get Container Type and Name
   Get_Container_Info(p_Component_Id   => l_Component_Id,
                      p_Container_Type => l_Container_Type,
                      p_Container_Name => l_Container_Name);

   -- Verify the Container which will update the Component status if needed
   Verify_Container (p_container_type => l_container_Type,
                     p_container_name => l_Container_Name);

   -- Get Current Status of the Component and return
   l_Current_Status := Get_Current_Status(p_Component_Id => l_Component_Id);
   return l_Current_Status;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Get_Component_Status', p_Component_Name);
    RAISE;
end get_component_status;


Procedure Raise_Control_Event (p_Component_Id in number,
				p_Control_Operation in varchar2,
				p_Container_Type in varchar2,
				p_CPID in number,
				p_Params in varchar2)
is
l_event_paramlist wf_parameter_list_t;
begin

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
			             'wf.plsql.FND_SVC_COMPONENT.RAISE_CONTROL_EVENT.begin',
                         'p_Component_Id: '||p_Component_Id||
                         ', p_Control_Operation:'||p_Control_Operation);
    end if;

	--wf_event.SetDispatchMode ('ASYNC');
	l_event_paramlist := wf_parameter_list_t();
	if p_Component_Id <> -1 then
	    wf_event.addParameterToList('COMPONENT_ID', p_Component_Id, l_event_paramlist);
	END IF;
	wf_event.addParameterToList('CONTAINER_TYPE', p_Container_Type, l_event_paramlist);
	wf_event.addParameterToList('CONTAINER_PROCESS_ID', p_CPID, l_event_paramlist);
	if p_Params is not null then
		wf_event.addParameterToList('OPERATION_PARAMETERS', p_Params, l_event_paramlist);
	END IF;

	wf_event.raise(p_Control_Operation, pv_Connection_Name_Prefix||':'||sysdate, null, l_event_paramlist);
	--wf_event.SetDispatchMode ('SYNC');

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Raise_Control_Event', p_Component_Id, p_Control_Operation);
  RAISE;
end Raise_Control_Event ;

Procedure Start_Component(p_Component_Id in NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
	                      'wf.plsql.FND_SVC_COMPONENT.START_COMPONENT.begin',
                          'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opStart,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	-- Reset the Status Info
	Update_Status(p_Component_Id => p_Component_Id,
			p_Status => pv_Status_Starting,
			p_Status_Info => 'NULL');

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> pv_Event_Start,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID);
exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
	                     'wf.plsql.FND_SVC_COMPONENT.START_COMPONENT.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.START_COMPONENT.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

End Start_Component;

Procedure Stop_Component(p_Component_Id in NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
				         'wf.plsql.FND_SVC_COMPONENT.STOP_COMPONENT.begin',
				         'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opStop,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Update_Status(p_Component_Id => p_Component_Id, p_Status => pv_Status_Stopping);

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> pv_Event_Stop,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID);

/**********

	if (FND_SVC_COMPONENT.pv_callerContext = FND_SVC_COMPONENT.pv_CallerContextUser) then

		-- Deactivate the automatic adapter in case user stops it.

		if (XDP_ADAPTER_CORE_DB.Is_Adapter_Automatic(p_ChannelName)) then

			XDP_ADAPTER_CORE_DB.Update_Status(
				p_ChannelName => p_ChannelName,
				p_Status => pv_statusDeactivated);
		END IF;
	END IF;
********/

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
	                     'wf.plsql.FND_SVC_COMPONENT.STOP_COMPONENT.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.STOP_COMPONENT.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Stop_Component;

Procedure Suspend_Component(p_Component_Id in NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
				         'wf.plsql.FND_SVC_COMPONENT.SUSPEND_COMPONENT.begin',
                         'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opSuspend,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Update_Status(p_Component_Id => p_Component_Id, p_Status => pv_Status_Suspending);

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> pv_Event_Suspend,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID);

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                         'wf.plsql.FND_SVC_COMPONENT.SUSPEND_COMPONENT.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.SUSPEND_COMPONENT.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Suspend_Component;

Procedure Resume_Component(p_Component_Id in NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                         'wf.plsql.FND_SVC_COMPONENT.RESUME_COMPONENT.begin',
                         'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opResume,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Update_Status(p_Component_Id => p_Component_Id, p_Status => pv_Status_Resuming);

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> pv_Event_Resume,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID);

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
	                     'wf.plsql.FND_SVC_COMPONENT.RESUME_COMPONENT.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.RESUME_COMPONENT.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Resume_Component;

Procedure Refresh_Component(p_Component_Id in NUMBER,
			p_params	IN VARCHAR2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
				         'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT.begin',
                         'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opRefresh,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> pv_Event_Refresh,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID,
			p_Params 		=> p_params);

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

 	if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                         'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                      'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT.error',
                      'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Refresh_Component;

Procedure Generic_Operation(p_Component_Id in NUMBER,
			p_Control_Event	IN VARCHAR2,
			p_params	IN VARCHAR2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_Container_Type fnd_svc_components.container_type%TYPE;
 l_Container_Name fnd_svc_components.standalone_container_name%TYPE;
 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                         'wf.plsql.FND_SVC_COMPONENT.GENERIC_OPERATION.begin',
                         'p_Component_Id: '||p_Component_Id);
    end if;

	Validate_Operation
		(p_Component_Id        	=> p_Component_Id,
		p_Control_Operation   	=> FND_SVC_COMPONENT.pv_opGeneric,
		p_retcode		=> p_retcode,
		p_errbuf		=> p_errbuf);

	if p_retcode <> 0 then
		return;
	END IF;

	Get_Container_Info(p_Component_Id 	=> p_Component_Id,
			   p_Container_Type 	=> l_Container_Type,
			   p_Container_Name 	=> l_Container_Name);

	Get_Container_Status (p_container_type => l_Container_Type
		         , p_container_name => l_Container_Name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Raise_Control_Event (p_Component_Id 	=> p_Component_Id,
			p_Control_Operation 	=> p_Control_Event,
			p_Container_Type 	=> l_Container_Type,
			p_CPID 			=> l_CPID,
			p_Params 		=> p_params);

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                         'wf.plsql.FND_SVC_COMPONENT.GENERIC_OPERATION.container_not_running',
                         'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                     'wf.plsql.FND_SVC_COMPONENT.GENERIC_OPERATION.error',
                     'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Generic_Operation;

Function Get_ConcQ_Name (ApplId in number, ConcQID in number) return varchar2
is
l_ConcQName fnd_concurrent_queues.concurrent_queue_name%TYPE;
begin
    select concurrent_queue_name into l_ConcQname from fnd_concurrent_queues
        where concurrent_queue_id = ConcQID and application_id = ApplId;

    return l_ConcQName;
end Get_ConcQ_Name;

Procedure Get_ConcQ_ID (ConcQName in varchar2, ApplId out nocopy number, ConcQId out nocopy number)
is
begin

select a.concurrent_queue_id, a.application_id into ConcQId, ApplId
    from fnd_concurrent_queues a
    where a.concurrent_queue_name = ConcQName;

end Get_ConcQ_ID;

PROCEDURE Reset_Container_Components
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
cursor c_Get_Running_Components_Conc (ConcQId number, ApplId number) is
    select component_id
    from FND_SVC_COMPONENTS
    where component_status not in (FND_SVC_COMPONENT.pv_Status_Stopped,
                                 FND_SVC_COMPONENT.pv_Status_Stopped_Error,
                                 FND_SVC_COMPONENT.pv_Status_Not_Configured,
                                 FND_SVC_COMPONENT.pv_Status_Deactivated_User,
                                 FND_SVC_COMPONENT.pv_Status_Deactivated_System)
                            and container_type = pv_Container_Type_GSM
                            and concurrent_queue_id = ConcQId
                            and application_id = ApplId;

cursor c_Get_Running_Components_Std (StdContainerName varchar2) is
    select component_id
    from FND_SVC_COMPONENTS
    where component_status not in (FND_SVC_COMPONENT.pv_Status_Stopped,
                                 FND_SVC_COMPONENT.pv_Status_Stopped_Error,
                                 FND_SVC_COMPONENT.pv_Status_Not_Configured,
                                 FND_SVC_COMPONENT.pv_Status_Deactivated_User,
                                 FND_SVC_COMPONENT.pv_Status_Deactivated_System)
                            and container_type = pv_Container_Type_Servlet
                            and standalone_container_name = StdContainerName;

l_appl_id number;
l_concurrent_queue_id number;

begin

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                         'wf.plsql.FND_SVC_COMPONENT.RESET_CONTAINER_COMPONENTS.begin',
                         'Container Type: '||p_container_type||' Container Name: '||p_container_name);
    end if;

    if (p_Container_Type = FND_SVC_COMPONENT.pv_Container_Type_GSM) then

        Get_ConcQ_ID (ConcQName => p_container_name,
                      ApplId => l_appl_id, ConcQId => l_concurrent_queue_id);

        FOR r_conc IN c_Get_Running_Components_Conc (l_concurrent_queue_id, l_appl_id) LOOP

            Update_Status (p_Component_Id => r_conc.component_id,
                           p_Status => FND_SVC_COMPONENT.pv_Status_Stopped_Error,
                           p_Status_Info => 'Status has been reset because the Service Component did not stop gracefully.'); -- TODO MLS??

        END LOOP;

        update FND_SVC_COMPONENTS
            set component_status = FND_SVC_COMPONENT.pv_Status_Stopped_Error where
            component_status = FND_SVC_COMPONENT.pv_Status_Deactivated_System and
            concurrent_queue_id = l_concurrent_queue_id and
            application_id = l_appl_id and
            container_type = pv_Container_Type_GSM;

    else

        FOR r_std IN c_Get_Running_Components_Std (p_container_name) LOOP

            Update_Status (p_Component_Id => r_std.component_id,
                           p_Status => FND_SVC_COMPONENT.pv_Status_Stopped_Error,
                           p_Status_Info => 'Status has been reset because the Service Component did not stop gracefully.'); -- TODO MLS??
        END LOOP;

        update FND_SVC_COMPONENTS
            set component_status = FND_SVC_COMPONENT.pv_Status_Stopped_Error where
            component_status = FND_SVC_COMPONENT.pv_Status_Deactivated_System and
            standalone_container_name = p_container_name and
            container_type = pv_Container_Type_Servlet;

    end if;

    commit;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Reset_Container_Components', p_container_type, p_container_name);
  RAISE;

END Reset_Container_Components;

PROCEDURE Refresh_Container_Log_Level
         ( p_container_type     IN VARCHAR2,
           p_container_name     IN VARCHAR2,
           p_log_level		IN NUMBER,
           p_retcode		OUT NOCOPY NUMBER,
           p_errbuf		OUT NOCOPY VARCHAR2)
IS
BEGIN

  Refresh_Container
  (
    p_container_type => p_container_type,
    p_container_name => p_container_name,
    p_params         => pv_Key_Container_Log_Level || '=' || p_log_level,
    p_retcode        => p_retcode,
    p_errbuf         => p_errbuf
  );

END Refresh_Container_Log_Level;

PROCEDURE Refresh_Container
         ( p_container_type     IN VARCHAR2,
           p_container_name     IN VARCHAR2,
           p_params		IN VARCHAR2,
           p_retcode		OUT NOCOPY NUMBER,
           p_errbuf		OUT NOCOPY VARCHAR2)
is

 l_CPID number;
 l_Container_Status fnd_svc_components.component_status%TYPE;

begin
	p_retcode := 0;

    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_PROCEDURE,
                         'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT_CONTAINER.begin',
                         'p_container_name: '||p_container_name);
    end if;

	Get_Container_Status (p_container_type => p_container_type
		         , p_container_name => p_container_name
			 , p_container_status => l_Container_Status
			 , p_process_id	=> l_CPID);

	if l_Container_Status <> pv_Container_Status_Running then
		raise e_ContainerNotRunning;
	end if;

	Raise_Control_Event (p_Control_Operation => pv_Event_Refresh,
			p_Container_Type 	 => p_Container_Type,
			p_CPID 			 => l_CPID,
			p_Params 		 => p_params);

exception

when e_ContainerNotRunning then
	p_retCode := pv_retContainerNotRunning;
 	p_errbuf := WF_CORE.TRANSLATE ('SVC_CONTAINER_NOT_RUNNING');

    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
	   WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
	                     'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT_CONTAINER.container_not_running',
		                 'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
    end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retOtherComponentError;
 	p_errbuf := 'Other non-SQL error';
END IF;

if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.STRING (WF_LOG_PKG.LEVEL_ERROR,
                      'wf.plsql.FND_SVC_COMPONENT.REFRESH_COMPONENT_CONTAINER.error',
                      'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;

end Refresh_Container;

PROCEDURE Verify_Container
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2)
IS

l_CPID number;
l_Container_Status fnd_svc_components.component_status%TYPE;

begin

    Get_Container_Status (p_container_type => p_container_Type
                            , p_container_name => p_container_Name
                            , p_container_status => l_Container_Status
                            , p_process_id	=> l_CPID);

    -- Ignore Running and Stopping Container
    if l_Container_Status = pv_Container_Status_Stopped then

       Reset_Container_Components
        ( p_container_type     => p_container_type
        , p_container_name     => p_container_name);

    end if;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Verify_Container', p_container_type, p_container_name);
  RAISE;

end Verify_Container;

PROCEDURE Verify_All_Containers
IS

cursor c_Get_Distinct_Containers is

    select distinct standalone_container_name container_name, container_type
    from FND_SVC_COMPONENTS
    where container_type = pv_Container_Type_Servlet and standalone_container_name is not null

    union

    select distinct concurrent_queue_name container_name, container_type
    from FND_SVC_COMPONENTS_V
    where container_type = pv_Container_Type_GSM and concurrent_queue_name is not null;

begin

    FOR r_container IN c_Get_Distinct_Containers LOOP

        Verify_Container (p_container_type => r_container.container_type,
                        p_container_name => r_container.container_name);

    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(pv_Package_Name, 'Verify_All_Containers');
  RAISE;

end Verify_All_Containers;

---------------------------------------------------------------------------
-- Set pkg level private variables
begin
  fnd_svc_component.pv_system_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  fnd_svc_component.pv_schema_name := wf_core.translate('WF_SCHEMA');

  fnd_svc_component.pv_last_agent_name   := ' ';
  fnd_svc_component.pv_last_queue_name   := ' ';
  fnd_svc_component.pv_last_recipients   := ' ';
  pv_install_mode := wf_core.translate('WF_INSTALL');
---------------------------------------------------------------------------
END FND_SVC_COMPONENT;

/

  GRANT EXECUTE ON "APPS"."FND_SVC_COMPONENT" TO "EM_OAM_MONITOR_ROLE";
