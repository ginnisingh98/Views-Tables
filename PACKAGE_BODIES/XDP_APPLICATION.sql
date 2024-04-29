--------------------------------------------------------
--  DDL for Package Body XDP_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_APPLICATION" AS
/* $Header: XDPAADMB.pls 120.1 2005/06/15 22:07:04 appldev  $ */

TYPE Service_Instance_reqs_rec IS RECORD
		(Instance_Name   varchar2(30),
		Req_ID           number);

TYPE Service_Instance_reqs_tab IS TABLE of Service_Instance_reqs_rec
       index by binary_integer;

CURSOR c_getQServiceTypes IS
	select SERVICE_ID, SERVICE_HANDLE, SERVICE_NAME
	from fnd_cp_services_VL
	where
		((service_handle like 'XDPA%') or (service_handle like 'XDPQ%')) and
		ENABLED = 'Y' and
		service_handle <> 'XDPCTRLS'
	order by service_handle;

Function Is_ICM_Running (Caller in varchar2 default 'CONC') return boolean;

Procedure Get_Max_Tries(Interval OUT NOCOPY number, MaxTries OUT NOCOPY number) ;

Function Check_Request_Status (ReqID in number, ServiceInstanceId in number) return boolean;

Function Verify_Controller_Instances (p_ServiceInstanceList in SERVICE_INSTANCE_REQS_TAB)
		return boolean;

Function Start_Service_Instances (p_ServiceHandle in varchar2) return SERVICE_INSTANCE_REQS_TAB;

Function Stop_Adapters (StopOptions IN VARCHAR2, FeOptions IN VARCHAR2, FeName IN VARCHAR2)
	return boolean;

Procedure Stop_Service_Instances (p_ServiceHandle in varchar2, StopOptions in varchar2);

Function Fetch_ConcQ_Name (ConcQID in number) return varchar2;

Function Fetch_ConcQ_ID (ConcQName in varchar2) return number;


-- ************************** IS_ICM_RUNNING *****************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Is_ICM_Running (Caller IN VARCHAR2 default 'CONC') return boolean
is

l_targetp number;
l_activep number;
l_pmon_method varchar2(80);
l_callstat number;

begin

	if Caller = 'CONC' then
		FND_FILE.put_line(FND_FILE.log, 'Checking if ICM is running');
	END IF;

	FND_CONCURRENT.GET_MANAGER_STATUS (
  		applid => 0,
       		managerid => 1,
       		targetp	   => l_targetp,
       		activep     => l_activep,
       		pmon_method => l_pmon_method,
       		callstat    => l_callstat);

	if l_callstat <> 0 then
		if Caller = 'CONC' then
        		FND_FILE.put_line(FND_FILE.log,
			'FND_CONCURRENT.GET_MANAGER_STATUS failed while checking for ICM, callstat: '||l_callstat);
		END IF;
		return false;
	else
		if Caller = 'CONC' then
			FND_FILE.put_line(FND_FILE.log,'ICM target processes: '||l_targetp||', active processes: '||l_activep);
		END IF;
		if l_activep > 0 then
			if Caller = 'CONC' then
				FND_FILE.put_line(FND_FILE.log,'ICM is running');
			END IF;
			return true;
		else
			if Caller = 'CONC' then
				FND_FILE.put_line(FND_FILE.log,'ICM is not running, services cannot be managed');
			END IF;
			return false;
		end if;
	end if;

end Is_ICM_Running;

-- ************************** Stop_Adapters *****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: FALSE if not entirely successful else TRUE
-- *
-- * This procedure stops specified adapters
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
-- ***********************************************************************************

Function Stop_Adapters
	(
	StopOptions	IN VARCHAR2,
	FeOptions	IN VARCHAR2,
	FeName		IN VARCHAR2
  	)
return boolean

IS

 CURSOR c_getAdapterInfoAll IS
 SELECT xar.channel_name, fe.fulfillment_element_name, xar.adapter_display_name,
	xar.fe_id, xar.adapter_status, xar.process_id
 FROM xdp_adapter_reg xar, xdp_fes fe
 WHERE xar.adapter_status not in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
				XDP_ADAPTER.pv_statusNotAvailable,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem)
   -- and xar.startup_mode = XDP_ADAPTER.pv_startAutomatic
       and xar.fe_id = fe.fe_id
 order by fe.fulfillment_element_name;

 l_temp_fe_name		VARCHAR2(2000);
 l_temp_fe_name2	VARCHAR2(2000);
 l_offset		NUMBER;
 l_AdapterOfInterest	BOOLEAN := FALSE;
 l_SomeError		BOOLEAN := FALSE;
 l_retcode 		NUMBER := 0;
 l_errbuf 		VARCHAR2(2000);

BEGIN

	l_SomeError := FALSE;

	-- ************************************************************
	--  Stop adapters as per user request
	-- ************************************************************

	l_temp_fe_name := 'NONE';

	if (((FeOptions = 'INCLUDE') or (FeOptions = 'EXCLUDE'))
				and (FeName IS NOT NULL)) then

		--  Remove leading, trailing blanks and upper case the FE names
		l_temp_fe_name := UPPER (LTRIM (RTRIM (FeName)));

		if FeOptions = 'INCLUDE' then
			FND_FILE.put_line(FND_FILE.log,'Stopping adapters for :'||
				l_temp_fe_name||': only');
		else
			FND_FILE.put_line(FND_FILE.log,'Stopping adapters for FE(s) other than :'||
				l_temp_fe_name||':');
		end if;

		-- Replace embedded commas by blanks and finally append a blank to the FE name
		-- list so that all words in the list have atleast a trailing blank for
		-- correct matching

		l_temp_fe_name := REPLACE (l_temp_fe_name, ',', ' ');
		l_temp_fe_name := RPAD (l_temp_fe_name, LENGTH(l_temp_fe_name)+1);
	else

		-- if all adapters are required to be stoppped i.e. complete application stop
		-- Controller stop will take care of its adapters

		FND_FILE.put_line(FND_FILE.log,'None of the adapters stoppped');
		return true;

	END IF; -- End of if which checks the user request type


       	for v_AdapterData in c_getAdapterInfoAll loop

 		l_AdapterOfInterest := FALSE;

		l_temp_fe_name2 := UPPER (LTRIM (RTRIM
			(v_AdapterData.fulfillment_element_name)));
		l_temp_fe_name2 := RPAD (l_temp_fe_name2, LENGTH(l_temp_fe_name2)+1);
 		l_offset := INSTR (l_temp_fe_name, l_temp_fe_name2);

		if (((FeOptions = 'INCLUDE') and (l_offset <> 0)) or -- found
			((FeOptions = 'EXCLUDE') and (l_offset = 0))) then -- not found
			l_AdapterOfInterest := TRUE;
		end if;

		--  If adapter is of interest
		if (l_AdapterOfInterest = TRUE) then

			IF StopOptions = 'NORMAL' then

				-- Stop adapter instance
				-- Following package with also update the adapter instance entry
				-- in XDP_ADAPTER_REG table accordingly
				-- and will submit a admin request if required i.e. if the
				-- Adapter cannot be locked

				FND_FILE.put_line(FND_FILE.log,'Attempting to stop adapter '||
						v_AdapterData.adapter_display_name);

				XDP_ADAPTER.Stop_Adapter (
					v_AdapterData.channel_name,
					l_retcode, l_errbuf);

				IF ((l_retcode <> 0) and
				(l_retcode <> XDP_ADAPTER.pv_retAdapterInvalidState) and
				(l_retcode <> XDP_ADAPTER.pv_retAdapterCannotLockReqSub)) THEN
					l_SomeError := TRUE;
					FND_FILE.put_line(FND_FILE.log,
						'Error in stopping adapter '||
						v_AdapterData.adapter_display_name);
					FND_FILE.put_line(FND_FILE.log,l_errbuf);
				elsif (l_retcode = XDP_ADAPTER.pv_retAdapterCannotLockReqSub) then
					FND_FILE.put_line(FND_FILE.log,
						'Stop request for adapter '||v_AdapterData.adapter_display_name||
						' successfully submitted');
					FND_FILE.put_line(FND_FILE.log,l_errbuf);
				else
					-- Success and InvalidState case
					-- InvalidState means already stopped

					FND_FILE.put_line(FND_FILE.log,
						'Adapter '||v_AdapterData.adapter_display_name||
						' stopped successfully');
				END IF;

			-- elsif StopOptions = 'ABORT' then
			else
				-- Stop adapter instance in abbort mode
				-- and also update the adapter instance entry
				-- in XDP_ADAPTER_REG table accordingly

				FND_FILE.put_line(FND_FILE.log,'Attempting to stop adapter '||
						v_AdapterData.adapter_display_name||
						' in abort mode');

				XDP_ADAPTER.Terminate_Adapter (
					v_AdapterData.channel_name,
					l_retcode, l_errbuf);

				IF l_retcode <> 0 THEN
					l_SomeError := TRUE;
					FND_FILE.put_line(FND_FILE.log,
						'Error in terminating adapter '||
						v_AdapterData.adapter_display_name);
					FND_FILE.put_line(FND_FILE.log,l_errbuf);
				else
					FND_FILE.put_line(FND_FILE.log,
						'Adapter '||
						v_AdapterData.adapter_display_name||
						' Aborted successfully');

				END IF;

			END IF;

			commit;

		END IF; -- End of if adapter is of interest

	END LOOP;

	if l_SomeError = TRUE then
		return false;
	else
		return true;
	END IF;

EXCEPTION

WHEN OTHERS THEN
IF c_getAdapterInfoAll%ISOPEN THEN
	CLOSE c_getAdapterInfoAll;
END IF;
FND_FILE.put_line(FND_FILE.log,'SQL code: '||SQLCODE);
FND_FILE.put_line(FND_FILE.log,'SQL message string: '||SQLERRM);
return false;
END Stop_Adapters;

-- ************************** STOP_SERVICE_INSTANCES *******************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Procedure Stop_Service_Instances (p_ServiceHandle in varchar2, StopOptions in varchar2)
is
l_ReqID 		number;
l_ServiceInstanceList 	FND_CONCURRENT.SERVICE_INSTANCE_TAB_TYPE;

l_targetp number;
l_activep number;
l_pmon_method varchar2(80);
l_callstat number;
l_ServiceInstanceId number := 0;
l_ServiceToBeStopped boolean := FALSE;

begin
	l_ServiceInstanceList.delete;

	FND_FILE.put_line(FND_FILE.log, 'Retrieving services instances for '||p_ServiceHandle);
	l_ServiceInstanceList := FND_CONCURRENT.GET_SERVICE_INSTANCES
					(svc_handle => p_ServiceHandle);

	if (l_ServiceInstanceList.COUNT > 0) then

		FND_FILE.put_line(FND_FILE.log, 'Service instances found: '||
					l_ServiceInstanceList.COUNT);

		for i in 1..l_ServiceInstanceList.COUNT loop
			if (l_ServiceInstanceList.EXISTS(i)) then

				-- TODO
				-- Donot stop if DISABLED, INACTIVE
				-- Stop if ACTIVE, SUSPENDED
				-- But whatif TRANSIT
				-- Possible TRANSIT statues are:
				-- DEACTIVATING, MIGRATING, CONNECTING, TERMINATING, INITIALIZING
				-- Apart from DEACTIVATING, TERMINATING in other cases
				-- service should also be stopped

				l_ServiceToBeStopped := FALSE;

				--if UPPER(l_ServiceInstanceList(i).STATE)
				--	not in ('INACTIVE','DISABLED','DEACTIVATING','TERMINATING') then
				if UPPER(l_ServiceInstanceList(i).STATE)
							in ('ACTIVE','SUSPENDED') then

					l_ServiceToBeStopped := TRUE;

				elsif UPPER(l_ServiceInstanceList(i).STATE) = 'TRANSIT' then

					l_ServiceInstanceId := Fetch_ConcQ_ID
							(ConcQName => l_ServiceInstanceList(i).INSTANCE_NAME);
					if (l_ServiceInstanceId > 0) then

						FND_CONCURRENT.GET_MANAGER_STATUS (
  							applid => 535,
					       		managerid => l_ServiceInstanceId,
					       		targetp	   => l_targetp,
					       		activep     => l_activep,
					       		pmon_method => l_pmon_method,
					       		callstat    => l_callstat);

						if l_callstat <> 0 then
	        					FND_FILE.put_line(FND_FILE.log,
							'FND_CONCURRENT.GET_MANAGER_STATUS failed, callstat: '||l_callstat);
						else
							FND_FILE.put_line(FND_FILE.log,'Target processes: '||l_targetp||', active processes: '||l_activep);
							-- if l_targetp > 0 then
							if l_activep > 0 then
								l_ServiceToBeStopped := TRUE;
							END IF;
						END IF;
					END IF;
				END IF;

				if l_ServiceToBeStopped = TRUE then

					l_ReqID := 0;

					if StopOptions = 'NORMAL' then
						FND_FILE.put_line(FND_FILE.log,
						'Submitting DEACTIVATE request for service instance: '||
						l_ServiceInstanceList(i).INSTANCE_NAME);
						l_ReqID := FND_REQUEST.SUBMIT_SVC_CTL_REQUEST (
							command => 'DEACTIVATE',
							service => l_ServiceInstanceList(i).INSTANCE_NAME,
							service_app => 'XDP');
					else
						FND_FILE.put_line(FND_FILE.log,
						'Submitting TERMINATE request for service instance: '||
						l_ServiceInstanceList(i).INSTANCE_NAME);
						l_ReqID := FND_REQUEST.SUBMIT_SVC_CTL_REQUEST (
							command => 'ABORT',
							service => l_ServiceInstanceList(i).INSTANCE_NAME,
							service_app => 'XDP');
					END IF;

					if l_ReqID > 0 then
						FND_FILE.put_line(FND_FILE.log,
							'Request : '||
							l_ReqID||
							' successfully submitted');
					else
						FND_FILE.put_line(FND_FILE.log,
							'Error, request could not be successfully submitted');
					END IF;
				else
					FND_FILE.put_line(FND_FILE.log,
						'Service instance: '||
						l_ServiceInstanceList(i).INSTANCE_NAME||
						' ignored, has state: '||
						l_ServiceInstanceList(i).STATE);
				END IF;
			END IF;
		END LOOP;
	else
		FND_FILE.put_line(FND_FILE.log, 'No service instances found');
	END IF;

end Stop_Service_Instances;

-- *************************** XDP_STOP *********************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: FALSE if adapters and controller cannot be stoppped at this moment i.e. either
-- * atleast one adapter instance is BUSY or some process has acquired lock on the
-- * XDP_ADAPTER_REGISTRATION table else TRUE
-- *
-- * This function gracefully shuts down the adapter instances and the controller.
-- *
-- * Called by: Administration scripts used to shutdown application gracefully.
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * ---------------------------------------------------------------------------------
-- ***********************************************************************************

PROCEDURE XDP_STOP
	(
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	FeOptions	IN VARCHAR2,
	FeName		IN VARCHAR2,
	StopOptions	IN VARCHAR2
  	)

IS

l_SomeError		BOOLEAN := FALSE;

BEGIN
	-- Verify / reset adapters silently
	XDP_ADAPTER.Verify_All_Adapters ( p_retcode => retCode,
				p_errbuf => errbuf);

 	l_SomeError := FALSE;
	retcode := 0;
	errbuf := '';

	if FeName is NULL and FeOptions = 'ALL' then

		FND_FILE.put_line(FND_FILE.log,'Application shutdown initiated');

		-- ************************************************************
		--  Check if ICM is running
		-- ************************************************************

		if (not Is_ICM_Running('CONC')) then
       		 	retCode := -1;
			errbuf := 'Cannot stop application as ICM is not running';
			FND_FILE.put_line(FND_FILE.log, errbuf);
			COMMIT;
			return;
		end if;

		-- ************************************************************
		--  Stop all non DISABLED, non INACTIVE Controller services instances
		--  Controller stop also stops all its Adapters
		-- ************************************************************

		FND_FILE.put_line(FND_FILE.log,'Stopping Controller services');
		begin
			Stop_Service_Instances (p_ServiceHandle => 'XDPCTRLS',
						StopOptions	=> StopOptions);
			FND_FILE.put_line(FND_FILE.log,'Requests to stop Controller services submitted successfully');
		EXCEPTION
		WHEN OTHERS THEN

			l_SomeError := TRUE;
			FND_FILE.put_line(FND_FILE.log,
				'Encountered error while stopping Controller services');
			FND_FILE.put_line(FND_FILE.log, 'Error: ' || SUBSTR(errbuf,1,200));
			FND_FILE.put_line (FND_FILE.log, 'SQLCODE: '||SQLCODE);
			FND_FILE.put_line (FND_FILE.log, 'SQLERRM: '||SQLERRM);
			commit;
			-- Continue, do as much as possible
		end;

		-- ************************************************************
		--  Stop all non DISABLED, non INACTIVE application queue service instances
		-- ************************************************************

		FND_FILE.put_line(FND_FILE.log,'Stopping Queue services');

       		for v_ServiceTypeData in c_getQServiceTypes loop
			FND_FILE.put_line(FND_FILE.log,'Stopping '||v_ServiceTypeData.SERVICE_NAME);

			begin
				Stop_Service_Instances (p_ServiceHandle =>
								v_ServiceTypeData.SERVICE_HANDLE,
							StopOptions	=> StopOptions);
				FND_FILE.put_line(FND_FILE.log,
					'Requests to stop '||v_ServiceTypeData.SERVICE_NAME||
						' submitted successfully');
			EXCEPTION
			WHEN OTHERS THEN
 				l_SomeError := TRUE;
				FND_FILE.put_line(FND_FILE.log,
					'Encountered error when stopping services');
				FND_FILE.put_line (FND_FILE.log, 'SQLCODE: '||SQLCODE);
				FND_FILE.put_line (FND_FILE.log, 'SQLERRM: '||SQLERRM);
				commit;
				-- Continue, do as much as possible
			end;

		END LOOP;

		-- TODO Verify the adapters HERE
		-- In normal shutdown, Controller will ensure that adapters are stopped
		-- In abort shutdown, termination of Controller Service will terminate child adapter
		-- processes, all we are trying to do is verify their statuses in case service
		-- instances have been terminated. If ICM has not picked up the termination request
		-- verify will still find adapters to be running, but there is nothing much we can do

		if (l_SomeError = FALSE) then
			FND_FILE.put_line(FND_FILE.log,
				'Application stop request completed successfully');
		else
			retcode := -1;
			errbuf := 'Application stop request completed with warnings or errors';
			FND_FILE.put_line(FND_FILE.log, errbuf);
		END IF;
	else
		l_SomeError := Stop_Adapters (
			StopOptions	=> StopOptions,
			FeOptions 	=> FeOptions,
			FeName 		=> FeName);

		if (l_SomeError = FALSE) then
			retcode := -1;
			errbuf := 'Adapters stopped with warnings or errors';
			FND_FILE.put_line(FND_FILE.log, errbuf);
		else
			FND_FILE.put_line(FND_FILE.log,
				'Adapters stopped successfully');
		END IF;
	end if;

	COMMIT;

EXCEPTION

WHEN OTHERS THEN
IF c_getQServiceTypes%ISOPEN THEN
	CLOSE c_getQServiceTypes;
end if;
FND_FILE.put_line(FND_FILE.log,'SQL code: '||SQLCODE);
FND_FILE.put_line(FND_FILE.log,'SQL message string: '||SQLERRM);
retcode := SQLCODE;
errbuf := SUBSTR(SQLERRM,1,200);
COMMIT;

END XDP_STOP;

-- ************************** GET_MAX_TRIES ****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Procedure Get_Max_Tries(Interval OUT NOCOPY number, MaxTries OUT NOCOPY number)
is
l_interval varchar2(20);
l_loop varchar2(20);
begin
	if fnd_profile.defined('XDP_CTRL_WAIT_LOOP_SLEEP_TIME') then
		fnd_profile.get('XDP_CTRL_WAIT_LOOP_SLEEP_TIME', l_interval);
		if to_number(l_interval) <= 0 then
			l_interval := '10';
		end if;
	else
		l_interval := '10';
	end if;
	Interval := to_number(l_interval);

	if fnd_profile.defined('XDP_CTRL_WAIT_LOOP_COUNT') then
		fnd_profile.get('XDP_CTRL_WAIT_LOOP_COUNT', l_loop);
		if to_number(l_loop) <= 0 then
			l_loop := '10';
		end if;
	else
		l_loop := '10';
	end if;
	MaxTries := to_number(l_loop);

end Get_Max_Tries;

-- ************************** CHECK_REQUEST_STATUS ****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Check_Request_Status (ReqID in number, ServiceInstanceId in number)
		return boolean
is

l_RunningFlag BOOLEAN := FALSE;
l_CallStatus BOOLEAN := FALSE;
l_Interval number;
l_MaxTries number;
l_Tries number := 0;
phase varchar2(80);
status varchar2(80);
dev_phase varchar2(80);
dev_status varchar2(80);
message varchar2(1996);
l_ReqID number := ReqID;

l_CPID number := 0;

begin
	FND_FILE.put_line(FND_FILE.log,
		'Checking the status of request: ' || to_char(ReqID));

	Get_Max_Tries(l_Interval, l_MaxTries);

	FND_FILE.put_line(FND_FILE.log,
		'Tries: '||l_MaxTries||', wait between retries: '||l_Interval);

	l_Tries := 1;

	while (l_Tries <= l_MaxTries) loop

		if (l_Tries > 1) then
			FND_FILE.put_line(FND_FILE.log, 'Try #: ' || to_char(l_Tries));
			DBMS_LOCK.SLEEP(l_Interval);
		end if;

		-- Initialize out variables with NULL string
		dev_phase := 'NULL';
		dev_status := 'NULL';
		l_CallStatus := FND_CONCURRENT.GET_REQUEST_STATUS
					(l_ReqID, null, null, phase,
					status, dev_phase, dev_status,
					message);

		if (not l_CallStatus) then
	        	FND_FILE.put_line(FND_FILE.log,
				'FND_CONCURRENT.GET_REQUEST_STATUS failed, message: '||message);
			return false;
		end if;

	        FND_FILE.put_line(FND_FILE.log,
			'Request Dev. Phase: ' || dev_phase || 'Status: ' || dev_status);
		FND_FILE.put_line(FND_FILE.log,
			'Request User Phase: ' || phase || 'Status: ' || status);

		if upper(dev_phase) in ('COMPLETE') then

           		if upper(dev_status) = 'NORMAL' then

				FND_FILE.put_line(FND_FILE.log,'Request has completed');

				exit;
			else
	        		FND_FILE.put_line(FND_FILE.log,
					'Request didnot complete successfully');
				return false;
			end if;

		elsif upper(dev_phase) in ('INACTIVE') then

			-- Irrespective of dev_status request
			-- should NOT enter this phase

			FND_FILE.put_line(FND_FILE.log,
	'Request not started. Check the Internal Concurrent Manager process and try again');
			return false;

		else
			FND_FILE.put_line(FND_FILE.log,'Request not yet completed');
			l_Tries := l_Tries + 1;
		end if;
	end loop;

	while (l_Tries <= l_MaxTries) loop

		l_CPID := Fetch_CPID(ConcQID => ServiceInstanceId, Caller => 'CONC');
		if l_CPID > 0 then
			FND_FILE.put_line(FND_FILE.log,'Service has started. CPID: '||l_CPID);
			return true;
		else
			FND_FILE.put_line(FND_FILE.log,'No active process for Service found');
		end if;

		l_Tries := l_Tries + 1;

		if (l_Tries < l_MaxTries) then
			FND_FILE.put_line(FND_FILE.log, 'Try #: ' || to_char(l_Tries));
			DBMS_LOCK.SLEEP(l_Interval);
		end if;

	end loop;

	FND_FILE.put_line(FND_FILE.log,
	'Request has not completed yet. Check the Internal Concurrent Manager process and try again');
	return false;

end Check_Request_Status ;

-- ************************** VERIFY_CONTROLLER_INSTANCES *****************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Verify_Controller_Instances (p_ServiceInstanceList in SERVICE_INSTANCE_REQS_TAB)
	return boolean
is
l_Flag 				boolean := false;
l_ControllerReqSubmitted 	boolean := false;
begin

if (p_ServiceInstanceList.COUNT > 0) then

	-- We are only interested in Controller instances that are used
	for v_GetSvcID in XDP_ADAPTER_CORE_DB.G_Get_Controller_Instances loop

		l_ControllerReqSubmitted := false;

		for i in 1..p_ServiceInstanceList.COUNT loop
			if (p_ServiceInstanceList.EXISTS(i)) then

				if UPPER(v_GetSvcID.concurrent_queue_name) =
					UPPER(p_ServiceInstanceList(i).INSTANCE_NAME) then

					l_ControllerReqSubmitted := true;

					FND_FILE.put_line(FND_FILE.log,
						'Verifying Controller instance '||
						p_ServiceInstanceList(i).INSTANCE_NAME||
						', conc. req.: '||p_ServiceInstanceList(i).Req_ID);

					l_Flag := Check_Request_Status (
						p_ServiceInstanceList(i).Req_ID,
						v_GetSvcID.service_instance_id);

					if l_Flag = false then
						-- Request did not COMPLETE after
						-- retrys

						FND_FILE.put_line(FND_FILE.log,
							'Could not verify Controller instance '||
							p_ServiceInstanceList(i).INSTANCE_NAME);
						return false;
					else
						FND_FILE.put_line(FND_FILE.log,
							'Successfully verified Controller instance '||
							p_ServiceInstanceList(i).INSTANCE_NAME);
					end if;
				end if;
			end if;
		end loop;

		if l_ControllerReqSubmitted = false then
			FND_FILE.put_line(FND_FILE.log, 'Did not verify Controller instance '||
				v_GetSvcID.concurrent_queue_name||' as request to start not submitted');
		end if;

	end loop;
else
	FND_FILE.put_line(FND_FILE.log, 'No Controller instances to verify');
end if;

return true;

end Verify_Controller_Instances;

-- ************************** START_SERVICE_INSTANCES *********************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Start_Service_Instances (p_ServiceHandle in varchar2) return SERVICE_INSTANCE_REQS_TAB
is
l_ReqID 		number;
l_ServiceInstanceList 	FND_CONCURRENT.SERVICE_INSTANCE_TAB_TYPE;
l_ServiceInstanceStarted SERVICE_INSTANCE_REQS_TAB;
l_Count 		number := 0;

l_targetp number;
l_activep number;
l_pmon_method varchar2(80);
l_callstat number;
l_ServiceInstanceId number := 0;
l_ServiceToBeStarted boolean := FALSE;

begin
	l_ServiceInstanceStarted.delete;
	l_ServiceInstanceList.delete;

	FND_FILE.put_line(FND_FILE.log, 'Retrieving services instances for '||p_ServiceHandle);
	l_ServiceInstanceList := FND_CONCURRENT.GET_SERVICE_INSTANCES
					(svc_handle => p_ServiceHandle);

	if (l_ServiceInstanceList.COUNT > 0) then

		FND_FILE.put_line(FND_FILE.log, 'Service instances found: '||
					l_ServiceInstanceList.COUNT);

		for i in 1..l_ServiceInstanceList.COUNT loop

			if (l_ServiceInstanceList.EXISTS(i)) then

				-- TODO
				-- Donot start if DISABLED, SUSPENDED, ACTIVE
				-- Start if INACTIVE
				-- But whatif TRANSIT
				-- Possible TRANSIT statues are:
				-- DEACTIVATING, MIGRATING, CONNECTING, TERMINATING, INITIALIZING
				-- DEACTIVATING, TERMINATING are the problem cases where
				-- service should also be started

				l_ServiceToBeStarted := FALSE;

				-- if UPPER(l_ServiceInstanceList(i).STATE) in
				--		('INACTIVE', 'DEACTIVATING', 'TERMINATING') then
				if UPPER(l_ServiceInstanceList(i).STATE) = 'INACTIVE' then

					l_ServiceToBeStarted := TRUE;

				elsif UPPER(l_ServiceInstanceList(i).STATE) = 'TRANSIT' then

					l_ServiceInstanceId := Fetch_ConcQ_ID
							(ConcQName => l_ServiceInstanceList(i).INSTANCE_NAME);
					if (l_ServiceInstanceId > 0) then

						FND_CONCURRENT.GET_MANAGER_STATUS (
  							applid => 535,
					       		managerid => l_ServiceInstanceId,
					       		targetp	   => l_targetp,
					       		activep     => l_activep,
					       		pmon_method => l_pmon_method,
					       		callstat    => l_callstat);

						if l_callstat <> 0 then
	        					FND_FILE.put_line(FND_FILE.log,
							'FND_CONCURRENT.GET_MANAGER_STATUS failed, callstat: '||l_callstat);
						else
							FND_FILE.put_line(FND_FILE.log,'Target processes: '||l_targetp||', active processes: '||l_activep);
							-- if l_targetp = 0 then
							if l_activep = 0 then
								l_ServiceToBeStarted := TRUE;
							END IF;
						END IF;
					END IF;
				END IF;

				if l_ServiceToBeStarted = TRUE then

					FND_FILE.put_line(FND_FILE.log,
						'Submitting ACTIVATE request for service instance: '||
						l_ServiceInstanceList(i).INSTANCE_NAME);
					l_ReqID := 0;
					l_ReqID := FND_REQUEST.SUBMIT_SVC_CTL_REQUEST (
						command     => 'ACTIVATE',
						service     => l_ServiceInstanceList(i).INSTANCE_NAME,
						service_app => 'XDP');

					if l_ReqID > 0 then
						l_Count := l_Count + 1;
						l_ServiceInstanceStarted(l_Count).INSTANCE_NAME :=
							l_ServiceInstanceList(i).INSTANCE_NAME;
						l_ServiceInstanceStarted(l_Count).Req_ID := l_ReqID;
						FND_FILE.put_line(FND_FILE.log,
							'Request : '||
							l_ReqID||
							' successfully submitted');
					else
						FND_FILE.put_line(FND_FILE.log,
							'Error, request could not be successfully submitted');
					END IF;
				else
					FND_FILE.put_line(FND_FILE.log,
						'Service instance: '||
						l_ServiceInstanceList(i).INSTANCE_NAME||
						' ignored, has state: '||
						l_ServiceInstanceList(i).STATE);
				END IF;
			END IF;
		END LOOP;
	else
		FND_FILE.put_line(FND_FILE.log, 'No service instances found');
	END IF;

	return l_ServiceInstanceStarted;

end Start_Service_Instances;

-- ************************** XDP_START ********************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: FALSE if not entirely successful else TRUE
-- *
-- * This function starts adapter and DQ instances as per configuration.
-- *
-- * Called by: Administration scripts used to start application.
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
-- ***********************************************************************************

Procedure XDP_START
(
	errbuf		OUT NOCOPY VARCHAR2,
	retcode		OUT NOCOPY NUMBER,
	FeOptions	IN VARCHAR2,
	FeName		IN VARCHAR2,
	DebugMode	IN VARCHAR2
)

IS

 CURSOR c_getAdapterInfoAll IS
 SELECT xar.channel_name, xfe.fulfillment_element_name,
	xar.adapter_display_name, xar.startup_mode, xar.fe_id, xar.adapter_status
 FROM xdp_adapter_reg xar, xdp_fes xfe
 WHERE xar.adapter_status in (XDP_ADAPTER.pv_statusStopped,
				XDP_ADAPTER.pv_statusStoppedError,
				XDP_ADAPTER.pv_statusTerminated,
				XDP_ADAPTER.pv_statusDeactivated,
				XDP_ADAPTER.pv_statusDeactivatedSystem)
   and xar.startup_mode in (XDP_ADAPTER.pv_startAutomatic,
				XDP_ADAPTER.pv_startGroup,
				XDP_ADAPTER.pv_startOnDemand)
   and xfe.fe_id = xar.fe_id
 order by xfe.fulfillment_element_name;

l_temp_fe_name			VARCHAR2(2000);
l_temp_fe_name2			VARCHAR2(2000);
l_offset			NUMBER;
l_retCode			Boolean;
l_AdaptersRequiredTobeStarted	Boolean := FALSE;
l_StartThisAdapter		Boolean := FALSE;
l_ServiceInstanceStartedC SERVICE_INSTANCE_REQS_TAB;
l_ServiceInstanceStartedQ SERVICE_INSTANCE_REQS_TAB;

BEGIN
	-- Verify / reset running adapters silently
	XDP_ADAPTER.Verify_All_Adapters ( p_retcode => retCode,
				p_errbuf => errbuf);

        l_retCode := TRUE;
        retcode := 0;
	errbuf := '';

	FND_FILE.put_line(FND_FILE.log,'Application Start Initiated.');

	-- ************************************************************
	--  Check if ICM is running
	-- ************************************************************

	if (not Is_ICM_Running('CONC')) then
        	retCode := -1;
        	errbuf := 'Cannot start application as ICM is not running';
		FND_FILE.put_line(FND_FILE.log, errbuf);
		COMMIT;
		return;
	end if;

	-- ************************************************************
	--  Start INACTIVE Controller services instances
	-- ************************************************************

	FND_FILE.put_line(FND_FILE.log,'Starting Controller services');
	begin
		l_ServiceInstanceStartedC := Start_Service_Instances (p_ServiceHandle => 'XDPCTRLS');

	EXCEPTION
	WHEN OTHERS THEN
        	retCode := SQLCODE;
        	errbuf := SQLERRM;
		FND_FILE.put_line(FND_FILE.log,
			'Encountered error when starting Controller services. Aborting Start Request');
		FND_FILE.put_line(FND_FILE.log, 'Error: ' || SUBSTR(errbuf,1,200));
		COMMIT;
		return;
	end;
	FND_FILE.put_line(FND_FILE.log,'Requests to start Controller services submitted successfully');

	-- ************************************************************
	--  Start INACTIVE application queue service instances
	-- ************************************************************

       	for v_ServiceTypeData in c_getQServiceTypes loop
		FND_FILE.put_line(FND_FILE.log,'Starting '||v_ServiceTypeData.SERVICE_NAME);
		-- Ignore the returned list
		begin
			l_ServiceInstanceStartedQ := Start_Service_Instances
						(p_ServiceHandle => v_ServiceTypeData.SERVICE_HANDLE);
		EXCEPTION
		WHEN OTHERS THEN
       		 	retCode := SQLCODE;
       		 	errbuf := SQLERRM;
			FND_FILE.put_line(FND_FILE.log,
			'Encountered error when starting services. Aborting Start Request');
			FND_FILE.put_line(FND_FILE.log, 'Error: ' || SUBSTR(errbuf,1,200));
			COMMIT;
			return;
		end;
	END LOOP;
	FND_FILE.put_line(FND_FILE.log,'Requests to start Queue services submitted successfully');

	-- Check if Controller instances are really started
	FND_FILE.put_line(FND_FILE.log,'Verifying Controller processes');
        l_retCode := Verify_Controller_Instances (l_ServiceInstanceStartedC);

	if l_retCode = false then
	 	retCode := -1;
       	 	errbuf := 'Could not verify Controller processes';
		FND_FILE.put_line(FND_FILE.log, 'Error: ' || SUBSTR(errbuf,1,200));
		return;
	end if;

	-- ************************************************************
	--  Start adapters as per user request
	-- ************************************************************

	l_temp_fe_name := 'NONE';

	if FeOptions = 'ALL' and FeName is NULL then

		--  Start all adapters
		FND_FILE.put_line(FND_FILE.log,'Starting all adapters');
 		l_AdaptersRequiredTobeStarted := TRUE;

	elsif (((FeOptions = 'INCLUDE') or (FeOptions = 'EXCLUDE'))
				and (FeName IS NOT NULL)) then

 		l_AdaptersRequiredTobeStarted := TRUE;

		--  Remove leading, trailing blanks and upper case the FE names
		l_temp_fe_name := UPPER (LTRIM (RTRIM (FeName)));

		if FeOptions = 'INCLUDE' then
			FND_FILE.put_line(FND_FILE.log,
			'Starting adapters associated with FE(s) :'||l_temp_fe_name||': only');
		else
			FND_FILE.put_line(FND_FILE.log,
			'Starting adapters for FE(s) other than :'||l_temp_fe_name||':');
		end if;

		-- Replace embedded commas by blanks and finally append a blank to the FE name
		-- list so that all words in the list have atleast a trailing blank for
		-- correct matching

		l_temp_fe_name := REPLACE (l_temp_fe_name, ',', ' ');
		l_temp_fe_name := RPAD (l_temp_fe_name, LENGTH(l_temp_fe_name)+1);

	else
 		l_AdaptersRequiredTobeStarted := FALSE;
		--  Handles 'other' cases i.e. no adapters to be started
		FND_FILE.put_line(FND_FILE.log,'No adapters started');
	END IF;

	if l_AdaptersRequiredTobeStarted = TRUE then

        	for v_AdapterData in c_getAdapterInfoAll loop

 			l_StartThisAdapter := TRUE;

			if l_temp_fe_name <> 'NONE' then
				-- Remove leading, trailing blanks and upper case the string and
				-- finally append a trailing blank to the NE name so as to match
				-- correctly

 				l_temp_fe_name2 := UPPER (LTRIM (RTRIM
						(v_AdapterData.fulfillment_element_name)));
				l_temp_fe_name2 := RPAD (l_temp_fe_name2,
						LENGTH(l_temp_fe_name2)+1);
 				l_offset := INSTR (l_temp_fe_name, l_temp_fe_name2);

				if (((FeOptions = 'INCLUDE') and (l_offset = 0)) or -- not found
				((FeOptions = 'EXCLUDE') and (l_offset <> 0))) then -- found
 					l_StartThisAdapter := FALSE;
				end if;
			end if;

			if l_StartThisAdapter = TRUE then

				if v_AdapterData.startup_mode = XDP_ADAPTER.pv_startOnDemand then


					if (v_AdapterData.adapter_status = XDP_ADAPTER.pv_statusDeactivatedSystem) then

						-- Reset the error count and adapter status of the DeactivatedSystem StartOnDemand Adapter
						XDP_ADAPTER.Reset_SysDeactivated_Adapter (
							p_ChannelName => v_AdapterData.channel_name);
						FND_FILE.put_line(FND_FILE.log,
							'Restart count and status of Start-on-demand Adapter '||
							v_AdapterData.adapter_display_name||
							' successfully reinitialized');

					else
						-- Reset the error count of the StartOnDemand Adapter
						XDP_ADAPTER.Reset_SysDeactivated_Adapter (
							p_ChannelName => v_AdapterData.channel_name,
							p_ResetStatusFlag => false);

						FND_FILE.put_line(FND_FILE.log,
							'Restart count of Start-on-demand Adapter '||
							v_AdapterData.adapter_display_name||
							' successfully reinitialized');

					END IF;
				else
					-- For Automatic adapters START_ADAPTER will reset
					-- the restart count

					FND_FILE.put_line(FND_FILE.log,
						'Attempting to start adapter :'||
						v_AdapterData.adapter_display_name||
						': associated with FE :'||
						v_AdapterData.fulfillment_element_name||':');

 					XDP_ADAPTER.START_ADAPTER (
						p_ChannelName => v_AdapterData.channel_name,
						p_retcode => retcode,
						p_errbuf => errbuf);

					IF retcode <> 0 THEN
						FND_FILE.put_line(FND_FILE.log,
							'Error in starting adapter '||
							v_AdapterData.adapter_display_name);
						FND_FILE.put_line(FND_FILE.log,errbuf);
						l_retCode := FALSE;
					else
						FND_FILE.put_line(FND_FILE.log,
							'Adapter '||v_AdapterData.adapter_display_name||
							' started successfully');
					END IF;

				END IF;

				commit;
			end if;

		END LOOP;
	end if;

	if (l_retCode = TRUE) then
		FND_FILE.put_line(FND_FILE.log, 'Application started successfully');
	else
		retcode := -1;
		errbuf := 'Application started with warnings or errors';
		FND_FILE.put_line(FND_FILE.log, errbuf);
	END IF;

	COMMIT;

EXCEPTION

WHEN OTHERS THEN
IF c_getQServiceTypes%ISOPEN THEN
	CLOSE c_getQServiceTypes;
end if;
IF c_getAdapterInfoAll%ISOPEN THEN
	CLOSE c_getAdapterInfoAll;
end if;
FND_FILE.put_line(FND_FILE.log,'SQL code: '||SQLCODE);
FND_FILE.put_line(FND_FILE.log,'SQL message string: '||SQLERRM);
retcode := SQLCODE;
errbuf := SUBSTR(SQLERRM,1,200);
COMMIT;

END XDP_START;

-- ************************** XDP_CM_SHUTDOWN ****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * This procedure stops the application's Concurrent Manager in abort mode
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
--	02/23/2001	sacsharm	Modified
--	Bug fix 1653820. Reverted back to abort mode in case of CM shutdown callback.
-- * --------------------------------------------------------------------------------
-- ***********************************************************************************
Procedure XDP_CM_SHUTDOWN

is

errbuf 	VARCHAR2 (2000);
retcode NUMBER;

begin
	-- Bug 2396384 fix
	-- 11.5.6 onwards this Shutdown Callback is no longer needed

	--XDP_STOP (
	--	errbuf => errbuf,
	--	retcode => retcode,
	--	FeOptions => 'ALL',
	--	FeName => NULL,
	--	StopOptions => 'NORMAL');

	null;

END XDP_CM_SHUTDOWN;

-- ************************** FETCH_CPID ****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Fetch_CPID(ConcQID in number, Caller in varchar2 default 'SERV') return number
is

l_CPID number := -1;
l_targetp number := 0;
l_activep number := 0;
l_pmon_method varchar2(80);
l_callstat number;
l_SIProcessList 	FND_CONCURRENT.SERVICE_PROCESS_TAB_TYPE;
l_ConcQName varchar2(30);

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_APPLICATION.FETCH_CPID', 'BEGIN:');
        end if;
	if Caller = 'CONC' then
		FND_FILE.put_line(FND_FILE.log, 'Checking if ServiceInstanceId '||ConcQID||' is running');
	END IF;

	l_SIProcessList.delete;

	FND_CONCURRENT.GET_MANAGER_STATUS (
  		applid => 535,
       		managerid => ConcQID,
       		targetp	   => l_targetp,
       		activep     => l_activep,
       		pmon_method => l_pmon_method,
       		callstat    => l_callstat);

	if l_callstat = 0 then
                if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		     FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_CPID',
				'Target processes: '||l_targetp||', active processes: '||l_activep);
                end if;

		if Caller = 'CONC' then
			FND_FILE.put_line(FND_FILE.log, 'Target processes: '||l_targetp||', active processes: '||l_activep);
		END IF;

		if l_activep > 0 and l_targetp > 0 then

			l_ConcQName := Fetch_ConcQ_Name (ConcQID => ConcQID);
                        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			     FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_CPID',
					'Retrieving ACTIVE services processes for '||l_ConcQName);
                        end if;

			if Caller = 'CONC' then
				FND_FILE.put_line(FND_FILE.log, 'Retrieving ACTIVE services processes for '||l_ConcQName);
			END IF;

			l_SIProcessList := FND_CONCURRENT.GET_SERVICE_PROCESSES
						(appl_short_name => 'XDP',
						svc_instance_name => l_ConcQName,
						proc_state => 'ACTIVE');

			if (l_SIProcessList.COUNT > 0) then
                                if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_CPID',
				          'ACTIVE processes for the instance found: '||l_SIProcessList.COUNT);
                                end if;

				if Caller = 'CONC' then
					FND_FILE.put_line(FND_FILE.log, l_SIProcessList.COUNT||' ACTIVE processes for the instance found');
				END IF;

				for i in 1..l_SIProcessList.COUNT loop

					if (l_SIProcessList.EXISTS(i)) then

						l_CPID := l_SIProcessList(i).CPID;
                                                if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
						     FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
							'XDP_APPLICATION.FETCH_CPID',
							'ACTIVE process CPID: '||l_CPID);
                                                end if;

						exit;

					END IF;
				END LOOP;
			else
                                if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_CPID',
					'No ACTIVE processes for Service found');
				end if;
				if Caller = 'CONC' then
					FND_FILE.put_line(FND_FILE.log, 'No ACTIVE processes for Service found');
				END IF;
			END IF;

		else
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_CPID',
				'ACTIVE and TARGET processes not greater than 0');
                        end if;
			if Caller = 'CONC' then
				FND_FILE.put_line(FND_FILE.log, 'ACTIVE and TARGET processes not greater than 0, so service instance is not running');
			END IF;
		end if;
	else
                if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		     FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_APPLICATION.FETCH_CPID',
			  'FND_CONCURRENT.GET_MANAGER_STATUS failed, callstat: '||l_callstat);
                end if;
		if Caller = 'CONC' then
			FND_FILE.put_line(FND_FILE.log, 'FND_CONCURRENT.GET_MANAGER_STATUS failed, callstat: '||l_callstat);
		END IF;
	end if;

	-- dbms_output.put_line('CPID: ' || l_CPID);

	return (l_CPID);

end Fetch_CPID;

-- ************************** FETCH_CONCQ_DETAILS ***********************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Procedure Fetch_ConcQ_Details (
	CPID in number,
	ConcQID OUT NOCOPY number,
	ConcQName OUT NOCOPY varchar2)
is

cursor c_GetConcQID is
	select a.concurrent_queue_id, b.concurrent_queue_name
	from fnd_concurrent_processes a, fnd_concurrent_queues b
	where a.concurrent_process_id = CPID and
		a.concurrent_queue_id = b.concurrent_queue_id and
		a.queue_application_id = b.application_id;

begin
 ConcQID := -1;

 for v_GetConcQID in c_GetConcQID loop
	ConcQID := v_GetConcQID.concurrent_queue_id;
	ConcQName := v_GetConcQID.concurrent_queue_name;
	exit;
 end loop;

 -- dbms_output.put_line('ConcQID: ' || ConcQID);
 -- dbms_output.put_line('ConcQName: ' || ConcQName);

end Fetch_ConcQ_Details;


-- ************************** FETCH_THREAD_CNT *********************************
-- * INPUTS : svc_handle - Service Handle of a Service
-- * OUTPUTS: num_of_threads - Number of threads running actively for that service
-- * RETURNS: none
-- *
-- * This procedure returns the Thread Count for a given service through the Service Parameters
-- *
-- * Called by: OAM Console for SFM
-- * Calls    :
-- *
-- * Modification history:
-- *    WHO                             WHEN                            WHY
-- * ---------------------------------------------------------------------------
-----
-- *****************************************************************************

PROCEDURE FETCH_THREAD_CNT (svc_handle IN VARCHAR2,
                            num_of_threads OUT NOCOPY NUMBER)
IS
    l_ServiceInstanceList   FND_CONCURRENT.SERVICE_INSTANCE_TAB_TYPE;
    l_SIProcessList         FND_CONCURRENT.SERVICE_PROCESS_TAB_TYPE;
    l_ServiceInstanceId     number := 0;
    p_num_of_threads        number;
    l_InstanceName          varchar2(30);
    l_Parameters            varchar2(2000);

BEGIN

    num_of_threads := 0;

    BEGIN

        l_ServiceInstanceList := FND_CONCURRENT.GET_SERVICE_INSTANCES(svc_handle);

    EXCEPTION
    WHEN OTHERS THEN
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'FND_CONCURRENT.GET_SERVICE_INSTANCES returned exception: ' ||to_char(SQLCODE) ||SQLERRM);
	end if;
        num_of_threads := -1;
    END;


    IF (l_ServiceInstanceList.COUNT > 0) THEN
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'No. of service_instances found: '||l_ServiceInstanceList.COUNT);
        end if;

        FOR i in 1..l_ServiceInstanceList.COUNT LOOP

            IF (l_ServiceInstanceList.EXISTS(i)) THEN

                l_InstanceName := l_ServiceInstanceList(i).INSTANCE_NAME;

                BEGIN

                    l_SIProcessList := FND_CONCURRENT.GET_SERVICE_PROCESSES
                                         (appl_short_name => 'XDP',
                                          svc_instance_name => l_InstanceName,
                                          proc_state => 'ACTIVE');

                    IF (l_SIProcessList.COUNT > 0) THEN
                        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'ACTIVE processes for the instance found: '||l_SIProcessList.COUNT);
			end if;

                        FOR i IN 1..l_SIProcessList.COUNT LOOP

                            IF (l_SIProcessList.EXISTS(i)) THEN
                                l_Parameters := l_SIProcessList(i).PARAMETERS;
                                p_num_of_threads := GET_COMPONENT_THREADS(l_Parameters, 'XDP_DQ_INIT_NUM_THREADS=');
                                EXIT;
                            END IF;

                        END LOOP;
                        num_of_threads := num_of_threads + (l_SIProcessList.COUNT * p_num_of_threads);
			if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'Number or Threads running for a service: '||num_of_threads);
			end if;

                    ELSE
                        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                            FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'No ACTIVE processes for Service found');
                        end if;

                    END IF;

                EXCEPTION
                WHEN OTHERS THEN
		    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                        FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'FND_CONCURRENT.GET_SERVICE_PROCESS returned exception: ' ||to_char(SQLCODE) ||SQLERRM);
	            end if;
                END;
            END IF;
        END LOOP;

    ELSE
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_APPLICATION.FETCH_THREAD_CNT', 'No Service Instances found for service_handle: ' ||svc_handle );
	end if;

    END IF;

END FETCH_THREAD_CNT;


-- ************************** GET_COMPONENT_THREADS ****************************
-- * INPUTS : p_service_params_str - Service Parameter string
-- *          p_tag - The tag to be parsed
-- * OUTPUTS: none
-- * RETURNS: Value for the tag viz. Thread Count
-- *
-- * This function parses the given string, and returns its value
-- *
-- * Called by: Procedure FETCH_THREAD_CNT
-- * Calls    :
-- *
-- * Modification history:
-- *    WHO                             WHEN                            WHY
-- * ---------------------------------------------------------------------------
-----
-- *****************************************************************************

FUNCTION GET_COMPONENT_THREADS (p_service_params_str IN VARCHAR2,
                                p_tag IN VARCHAR2)
RETURN NUMBER

IS
    l_index number;
    l_num_threads varchar2(3);

BEGIN

    l_index := instr(p_service_params_str, p_tag) + length(p_tag);
    l_num_threads := substr(p_service_params_str, l_index);
    return TO_NUMBER(l_num_threads);

END GET_COMPONENT_THREADS;


-- ************************** SUBMIT_SVC_CTL_REQUEST *********************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Submit_Svc_Ctl_Request (
	CPID in number, CtlCmd in varchar2)
	return number
is

l_ReqID number := 0;
l_ConcQID number := -1;
l_ConcQName varchar2(30);

begin
	if (not Is_ICM_Running ('SERV')) then
		return l_ReqID;
	END IF;

	Fetch_ConcQ_Details (
		CPID => CPID,
		ConcQID => l_ConcQID,
		ConcQName => l_ConcQName);

	if l_ConcQID > 0 then
		l_ReqID := FND_REQUEST.SUBMIT_SVC_CTL_REQUEST (
					command     => CtlCmd,
					service     => l_ConcQName,
					service_app => 'XDP');
	end if;

	return l_ReqID;

end Submit_Svc_Ctl_Request;

-- ************************** FETCH_CONCQ_NAME **************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Fetch_ConcQ_Name (ConcQID in number) return varchar2
is

cursor c_GetConcQName is
	select a.concurrent_queue_name
	from fnd_concurrent_queues a
	where a.concurrent_queue_id = ConcQID and
		a.application_id = 535;

l_ConcQName varchar2(30) := '';
begin

 for v_GetConcQName in c_GetConcQName loop
	l_ConcQName := v_GetConcQName.concurrent_queue_name;
	exit;
 end loop;

 -- dbms_output.put_line('ConcQName: ' || l_ConcQName);
 return l_ConcQName;

end Fetch_ConcQ_Name;

-- ************************** FETCH_CONCQ_ID ****************************************
-- * INPUTS : None
-- * OUTPUTS: None
-- * RETURNS: None
-- *
-- * Called by:
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * --------------------------------------------------------------------------------
Function Fetch_ConcQ_ID (ConcQName in varchar2) return number
is

cursor c_GetConcQID is
	select a.concurrent_queue_id
	from fnd_concurrent_queues a
	where upper(a.concurrent_queue_name) = upper(ConcQName);

l_ConcQID number := -1;
begin

 for v_GetConcQID in c_GetConcQID loop
	l_ConcQID := v_GetConcQID.concurrent_queue_id;
	exit;
 end loop;

 -- dbms_output.put_line('ConcQID: ' || l_ConcQID);
 return l_ConcQID;

end Fetch_ConcQ_ID;

--begin
-- pv_AckTimeout := 30;


-- ************************** XDP_CONSOLE_COUNTS_FENGINE *********************************
-- * This procedure returns the Counts for a given Queue Service
-- *
-- * Called by: OAM Console for SFM
-- * Calls    :
-- * Created by: Maya
-- *
-- * Modification history:
-- *    WHO                             WHEN                            WHY
-- * ---------------------------------------------------------------------------
--
-- *****************************************************************************


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
        ) IS

 l_order_current        number := 0;
 l_order_future1        number := 0;
 l_order_future2        number := 0;
 l_order_future         number := 0;
 l_order_exception      number := 0;
 l_order_inprogress     number := 0;
 l_order_inerror        number := 0;
 l_order_completed      number := 0;
 l_order_threads        number := 0;
 l_wi_current           number := 0;
 l_wi_future1           number := 0;
 l_wi_future2           number := 0;
 l_wi_future            number := 0;
 l_wi_exception         number := 0;
 l_wi_inprogress        number := 0;
 l_wi_inerror           number := 0;
 l_wi_completed         number := 0;
 l_wi_threads           number := 0;
 l_fa_current           number := 0;
 l_fa_future            number := 0;
 l_fa_exception         number := 0;
 l_fa_inprogress        number := 0;
 l_fa_inerror           number := 0;
 l_fa_completed         number := 0;
 l_fa_threads           number := 0;
 l_fa_ready_current     number := 0;
 l_fa_ready_future      number := 0;
 l_fa_ready_exception   number := 0;
 l_timer_current        number := 0;
 l_timer_future         number := 0;
 l_timer_exception      number := 0;
 l_timer_inprogress     number := 0;
 l_timer_completed      number := 0;
 l_timer_threads        number := 0;
 l_event_current        number := 0;
 l_event_future         number := 0;
 l_event_exception      number := 0;
 l_event_inprogress     number := 0;
 l_event_inerror        number := 0;
 l_event_completed      number := 0;
 l_event_threads        number := 0;
 l_in_current           number := 0;
 l_in_future            number := 0;
 l_in_exception         number := 0;
 l_in_inprogress        number := 0;
 l_in_inerror           number := 0;
 l_in_completed         number := 0;
 l_in_threads           number := 0;
 l_out_current          number := 0;
 l_out_exception        number := 0;
 l_out_inprogress       number := 0;
 l_out_inerror          number := 0;
 l_out_completed        number := 0;


/*****Order Load*****/
 cursor c_order_load is
      select count(*)count, msg_state
      from AQ$XDP_ORDER_PROCESSOR_QTAB
      group by msg_state;

/*****Order Volume*****/
 cursor c_order_volume is
    select count(*)count, status_code
    from xdp_order_headers
    group by status_code;

/*****WI Load*******/
 cursor c_wi_load is
      select count(*)count, msg_state
      from AQ$XDP_WORKITEM_QTAB
      group by msg_state;

/*****WI Volume*****/
 cursor c_wi_volume is
    select count(*)count, status_code
    from XDP_FULFILL_WORKLIST
    group by status_code;

/*****FA Load*****/
cursor c_fa_load is
     select count(*)count, msg_state
     from AQ$XDP_FA_QTAB
     group by msg_state;

/****FA Volume****/
cursor c_fa_volume is
    select count(*)count, status_code
    from XDP_FA_RUNTIME_LIST
    group by status_code;

/*****FA Ready******/
cursor c_fa_ready_load is
     select count(*)count,msg_state
     from AQ$XDP_WF_CHANNEL_QTAB
     group by msg_state;

/*****Timers Load*******/
cursor c_timer_load is
     select count(*)count, msg_state
     from AQ$XNP_IN_TMR_QTAB
     group by msg_state;

/*****Timers Volume******/
cursor c_timer_volume is
     select count(*)count, status
     FROM XNP_TIMER_REGISTRY
     group by status;

/*****Events Load******/
cursor c_event_load is
     select count(*)count, msg_state
     from AQ$XNP_IN_EVT_QTAB
     group by msg_state;

/*****Inbound Load****/
cursor c_in_load is
     select count(*)count,msg_state
     from AQ$XNP_IN_MSG_QTAB
     group by msg_state;

 /*****Outbound Load****/
cursor c_out_load is
     select count(*)count, msg_state
     from AQ$XNP_OUT_MSG_QTAB
     group by msg_state;

/*****Events, Invound, Outbound Volume*****/
cursor c_comb_volume is
     select count(*)count, msg_status, direction_indicator
     from XNP_MSGS
     group by msg_status,  direction_indicator;

 BEGIN

 /*********Order Load and Volume*********/

   FOR v_order in c_order_load LOOP
     IF v_order.msg_state = 'READY' THEN
        l_order_current := v_order.count;
     ELSIF v_order.msg_state = 'WAIT' THEN
        l_order_future1 := v_order.count;
     ELSIF v_order.msg_state = 'EXPIRED' THEN
        l_order_exception := v_order.count;
     ELSE
        null;
     END IF;
   END LOOP;


  FOR v_order in c_order_volume LOOP
    IF v_order.status_code IN ('READY', 'IN PROGRESS') THEN
        l_order_inprogress := l_order_inprogress +  v_order.count;
    ELSIF v_order.status_code IN ('ERROR') THEN
        l_order_inerror := l_order_inerror + v_order.count;
    ELSIF v_order.status_code IN ('CANCELLED', 'ABORTED', 'SUCCESS', 'SUCCESS_WITH_OVERRIDE') THEN
        l_order_completed := l_order_completed + v_order.count;
    ELSIF v_order.status_code = 'STANDBY' THEN
        l_order_future2 := l_order_future2 + v_order.count;
    ELSE
       null;
    END IF;
  END LOOP;

  l_order_future := l_order_future1 + l_order_future2;

  FETCH_THREAD_CNT(svc_handle => 'XDPQORDS'
                                   ,num_of_threads => l_order_threads);

  p_order_threads := l_order_threads;
  p_order_current := l_order_current;
  p_order_future := l_order_future;
  p_order_exception := l_order_exception;
  p_order_inprogress := l_order_inprogress;
  p_order_inerror := l_order_inerror;
  p_order_completed := l_order_completed;


/********Workitem Load and Volume********/

  FOR v_wi in c_wi_load LOOP
     IF v_wi.msg_state = 'READY' THEN
        l_wi_current := v_wi.count;
     ELSIF v_wi.msg_state = 'WAIT' THEN
        l_wi_future1 := v_wi.count;
     ELSIF v_wi.msg_state = 'EXPIRED' THEN
        l_wi_exception := v_wi.count;
     ELSE
        null;
     END IF;
  END LOOP;


   FOR v_wi in c_wi_volume LOOP
    IF v_wi.status_code IN ('READY', 'IN PROGRESS') THEN
        l_wi_inprogress := l_wi_inprogress +  v_wi.count;
    ELSIF v_wi.status_code IN ('ERROR') THEN
        l_wi_inerror := l_wi_inerror + v_wi.count;
    ELSIF v_wi.status_code IN ('CANCELLED', 'ABORTED', 'SUCCESS', 'SUCCESS_WITH_OVERRIDE') THEN
        l_wi_completed := l_wi_completed + v_wi.count;
    ELSIF v_wi.status_code = 'STANDBY' THEN
        l_wi_future2 := l_wi_future2 + v_wi.count;
    ELSE
       null;
    END IF;
  END LOOP;
  l_wi_future := l_wi_future1 + l_wi_future2;

  FETCH_THREAD_CNT(svc_handle => 'XDPQWIS'
                                   ,num_of_threads => l_wi_threads);

  p_wi_threads := l_wi_threads;
  p_wi_current := l_wi_current;
  p_wi_future := l_wi_future;
  p_wi_exception := l_wi_exception;
  p_wi_inprogress := l_wi_inprogress;
  p_wi_inerror := l_wi_inerror;
  p_wi_completed := l_wi_completed;


    /*********Fulfillment Action Load and Volume*******/


  FOR v_fa in c_fa_load LOOP
     IF v_fa.msg_state = 'READY' THEN
        l_fa_current := v_fa.count;
     ELSIF v_fa.msg_state = 'EXPIRED' THEN
        l_fa_exception := v_fa.count;
     ELSE
        null;
     END IF;
  END LOOP;

  FOR v_fa in c_fa_volume LOOP
    IF v_fa.status_code IN ('READY', 'IN PROGRESS') THEN
        l_fa_inprogress := l_fa_inprogress +  v_fa.count;
    ELSIF v_fa.status_code IN ('ERROR') THEN
        l_fa_inerror := l_fa_inerror + v_fa.count;
    ELSIF v_fa.status_code IN ('CANCELLED', 'ABORTED', 'SUCCESS', 'SUCCESS_WITH_OVERRIDE') THEN
        l_fa_completed := l_fa_completed + v_fa.count;
    ELSIF v_fa.status_code = 'STANDBY' THEN
        l_fa_future := l_fa_future + v_fa.count;
    ELSE
       null;
    END IF;
  END LOOP;

   FETCH_THREAD_CNT(svc_handle => 'XDPQFAS'
                                   ,num_of_threads => l_fa_threads);



  p_fa_threads := l_fa_threads;
  p_fa_current := l_fa_current;
  p_fa_future := l_fa_future;
  p_fa_exception := l_fa_exception;
  p_fa_inprogress := l_fa_inprogress;
  p_fa_inerror    := l_fa_inerror;
  p_fa_completed  := l_fa_completed;


    /******Fulfillment Action Ready*******/

   FOR v_fa_ready in c_fa_ready_load LOOP
     IF v_fa_ready.msg_state = 'READY' THEN
        l_fa_ready_current := v_fa_ready.count;
     ELSIF  v_fa_ready.msg_state = 'EXPIRED' THEN
        l_fa_ready_exception := v_fa_ready.count;
     ELSE
        null;
     END IF;
   END LOOP;

   select count(*)
   into l_fa_ready_future
   from XDP_FA_RUNTIME_LIST
   where status_code = 'WAITING_FOR_RESOURCE';


   p_fa_ready_current := l_fa_ready_current;
   p_fa_ready_future := l_fa_ready_future;
   p_fa_ready_exception := l_fa_ready_exception;




   /******Timers*********/

   FOR v_timer in c_timer_load LOOP
     IF v_timer.msg_state = 'READY' THEN
        l_timer_current := v_timer.count;
     ELSIF v_timer.msg_state = 'WAIT' THEN
        l_timer_future := v_timer.count;
     ELSIF v_timer.msg_state = 'EXPIRED' THEN
        l_timer_exception := v_timer.count;
     ELSE
        null;
     END IF;
   END LOOP;

   select count(*)
   into l_timer_future
   from XNP_IN_TMR_QTAB
   where nvl(time_manager_info,SYSDATE) > SYSDATE;

   FOR v_timer in c_timer_volume LOOP
    IF v_timer.status = 'ACTIVE' THEN
        l_timer_inprogress := l_timer_inprogress +  v_timer.count;
    ELSIF v_timer.status IN ('EXPIRED', 'REMOVED') THEN
        l_timer_completed := l_timer_completed + v_timer.count;
    ELSE
       null;
    END IF;
  END LOOP;

  FETCH_THREAD_CNT(svc_handle => 'XDPQTMRS'
                                   ,num_of_threads => l_timer_threads);


 p_timer_threads := l_timer_threads;
 p_timer_current := l_timer_current;
 p_timer_future  := l_timer_future;
 p_timer_exception := l_timer_exception;
 p_timer_inprogress := l_timer_inprogress;
 p_timer_completed := l_timer_completed;


/******Events**********/

   FOR v_event in c_event_load LOOP
     IF v_event.msg_state = 'READY' THEN
        l_event_current := v_event.count;
     ELSIF v_event.msg_state = 'EXPIRED' THEN
        l_event_exception := v_event.count;
     ELSE
        null;
     END IF;
   END LOOP;

   select count(*)
   into l_event_future
   from xnp_callback_events xce,
   xnp_msg_types_b xmt
   where xce.msg_code = xmt.msg_code and
   xce.status = 'WAITING' and
   xmt.msg_type IN ('EVENT', 'EVT_NOHEAD');

   FETCH_THREAD_CNT(svc_handle => 'XDPQEVTS'
                                   ,num_of_threads => l_event_threads);


   p_event_threads := l_event_threads;
   p_event_current :=  l_event_current;
   p_event_exception := l_event_exception;
   p_event_future := l_event_future;


 /*****Inbound Messages*****/

   FOR v_in in c_in_load LOOP
     IF v_in.msg_state = 'READY' THEN
        l_in_current := v_in.count;
     ELSIF v_in.msg_state = 'EXPIRED' THEN
        l_in_exception := v_in.count;
     ELSE
        null;
     END IF;
   END LOOP;

   select count(*)
   into l_in_future
   from xnp_callback_events xce,
   xnp_msg_types_b xmt
   where xce.msg_code = xmt.msg_code and
   xce.status = 'WAITING' and
   xmt.msg_type = 'MSG' and
   xmt.queue_name = 'XNP_IN_MSG_Q';

   FETCH_THREAD_CNT(svc_handle => 'XDPQMSGS'
                                   ,num_of_threads => l_in_threads);

   p_in_threads := l_in_threads;
   p_in_current := l_in_current;
   p_in_exception := l_in_exception;
   p_in_future := l_in_future;


 /*****Outbound Message*****/

   FOR v_out in c_out_load LOOP
     IF v_out.msg_state = 'READY' THEN
        l_out_current := v_out.count;
     ELSIF v_out.msg_state = 'EXPIRED' THEN
        l_out_exception := v_out.count;
     ELSE
        null;
     END IF;
   END LOOP;

   p_out_current := l_out_current;
   p_out_exception := l_out_exception;



/******Event, Inbound, Outbound Volume******/

  FOR v_comb in c_comb_volume LOOP
    IF v_comb.msg_status = 'READY' AND
       v_comb.direction_indicator = 'E'  THEN
       l_event_inprogress := l_event_inprogress +  v_comb.count;
    ELSIF v_comb.msg_status =  'FAILED' AND
          v_comb.direction_indicator = 'E' THEN
          l_event_inerror := l_event_inerror + v_comb.count;
    ELSIF v_comb.msg_status = 'PROCESSED' AND
          v_comb.direction_indicator = 'E' THEN
          l_event_completed := l_event_completed + v_comb.count;
    ELSIF v_comb.msg_status = 'READY' AND
          v_comb.direction_indicator = 'I' THEN
          l_in_inprogress := l_in_inprogress + v_comb.count;
    ELSIF v_comb.msg_status =  'FAILED' AND
          v_comb.direction_indicator = 'I' THEN
          l_in_inerror := l_in_inerror + v_comb.count;
    ELSIF v_comb.msg_status = 'PROCESSED' AND
          v_comb.direction_indicator = 'I' THEN
          l_in_completed := l_in_completed + v_comb.count;
    ELSIF v_comb.msg_status = 'READY' AND
          v_comb.direction_indicator = 'O' THEN
          l_out_inprogress := l_out_inprogress + v_comb.count;
    ELSIF v_comb.msg_status =  'FAILED' AND
          v_comb.direction_indicator = 'O' THEN
          l_out_inerror := l_out_inerror + v_comb.count;
    ELSIF v_comb.msg_status = 'PROCESSED' AND
          v_comb.direction_indicator = 'O' THEN
          l_out_completed := l_out_completed + v_comb.count;
    ELSE
       null;
    END IF;
  END LOOP;

    p_event_inprogress := l_event_inprogress;
    p_event_inerror := l_event_inerror;
    p_event_completed := l_event_completed;

    p_in_inprogress := l_in_inprogress;
    p_in_inerror := l_in_inerror;
    p_in_completed := l_in_completed;

    p_out_inprogress := l_out_inprogress;
    p_out_inerror := l_out_inerror;
    p_out_completed := l_out_completed;


  END XDP_CONSOLE_COUNTS_FENGINE;

end XDP_APPLICATION;

/
