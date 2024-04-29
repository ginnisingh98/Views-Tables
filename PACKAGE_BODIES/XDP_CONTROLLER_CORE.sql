--------------------------------------------------------
--  DDL for Package Body XDP_CONTROLLER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_CONTROLLER_CORE" AS
/* $Header: XDPCCORB.pls 120.1 2005/06/08 23:42:19 appldev  $ */

-- Private procedures Begin

TYPE term_adapter_rec IS RECORD
                (Channel_Name   varchar2(40),
                Lock_Retry      varchar2(1),
                Process_id           number);

TYPE term_adapters_tab IS TABLE of term_adapter_rec
       index by binary_integer;

Procedure Stop_Impl_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2);

Function GetCtrlWaitToKillMins return number;

-- Private procedures END

-- Public Procedures BEGIN
Procedure LaunchAdapter (CPID in number,
			 AdapterInfo in varchar2)
is
begin

 -- dbms_output.put_line('Sending CUSTOM Message to CPID: ' || CPID);
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_StartCustomMessage,
				    AdapterInfo);

end LaunchAdapter;


Procedure VerifyAdapters (CPID in number,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_VerifyCustomMessage,
				    AdapterInfo);

end VerifyAdapters;


Procedure TerminateAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is

begin

 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_TermCustomMessage,
				    AdapterInfo);

end TerminateAdapter;

Procedure SuspendAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_SuspCustomMessage,
				    AdapterInfo);
end SuspendAdapter;

Procedure ResumeAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_ResuCustomMessage,
				    AdapterInfo);
end ResumeAdapter;

Procedure ConnectAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_ConnCustomMessage,
				    AdapterInfo);
end ConnectAdapter;

Procedure DisconnectAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_DiscCustomMessage,
				    AdapterInfo);
end DisconnectAdapter;

Procedure StopAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_StopCustomMessage,
				    AdapterInfo);
end StopAdapter;

Procedure GenericOperationAdapter(CPID in varchar2,
			  AdapterInfo in varchar2)
is
begin
 fnd_cp_gsm_ipc.Send_Custom_Message(CPID,
				    pv_GenOpCustomMessage,
				    AdapterInfo);
end GenericOperationAdapter;

Procedure VerifyControllerStatus(p_ConcQID in number,
				 p_CPID OUT NOCOPY number,
				 p_ControllerRunning OUT NOCOPY varchar2)
is
begin
	p_CPID := XDP_APPLICATION.Fetch_CPID(ConcQID => p_ConcQID);
	if p_CPID > 0 then
		p_ControllerRunning := 'Y';
	else
		p_ControllerRunning := 'N';
	end if;

end VerifyControllerStatus;

-- Does processing that is required before Controller stops
-- Added - sacsharm
Procedure Perform_Stop_Processing (p_CPID in varchar2,
			  p_AdapterInfo OUT NOCOPY varchar2)
is

l_ConcQID 		number := 0;
l_ConcQName 		varchar2 (30);
l_ErrorMsg     		VARCHAR2 (4000);
l_RetCode      		NUMBER := 0;
l_req      		NUMBER;
l_job      		NUMBER;

l_AdapterTobeTerminated boolean;

l_term_adapters_list term_adapters_tab;
l_term_adapter_count number := 0;
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
					'BEGIN:p_CPID: '||p_CPID);
	end if;

	p_AdapterInfo := 'NONE';
	XDP_APPLICATION.Fetch_ConcQ_Details (
		CPID => p_CPID,
		ConcQID => l_ConcQID,
		ConcQName => l_ConcQName);

	if l_ConcQID > 0 then

                l_term_adapters_list.delete;

		--***************************************************************
		--*********  SET THE CONTEXT ************************************

		XDP_ADAPTER.pv_callerContext := XDP_ADAPTER.pv_callerContextAdmin;

		--***************************************************************
		--***************************************************************

		XDP_ADAPTER.Verify_Running_Adapters (
				p_controller_instance_id => l_ConcQID,
				x_adapter_info => p_AdapterInfo,
				p_retcode => l_RetCode,
				p_errbuf => l_ErrorMsg
				);

		if (l_RetCode <> 0) then
		    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
				'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
				'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS returned error: '||
					l_RetCode||', Desc: '||l_ErrorMsg);
		    end if;
		END IF;

		-- Either way, we donot want Controller to verify adapters on basis of
		-- PIDs

		p_AdapterInfo := 'NONE';

		for v_AdapterPID in XDP_ADAPTER_CORE_DB.G_Get_Running_Adapters (l_ConcQID) loop

			if (((v_AdapterPID.is_implemented = 'Y') and (v_AdapterPID.process_id > 0)) or
				(v_AdapterPID.is_implemented = 'N')) then
			        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			  	    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
					'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
					'Stopping adapter: '||v_AdapterPID.channel_name);
			        end if;
				l_AdapterTobeTerminated := FALSE;

				if v_AdapterPID.is_implemented = 'N' then
					-- This will also submit the job incase we are not able to
					-- lock, so no need to submit job to stop adapter
					XDP_ADAPTER.Stop_Adapter (v_AdapterPID.channel_name,
							l_RetCode, l_ErrorMsg);
				else
					-- We shouldnt call Stop_Adapter API for implemented adapters
					-- as that will submit CUSTOM request on Controller queue
					-- and Controller is STOPPING
					Stop_Impl_Adapter (v_AdapterPID.channel_name,
							l_RetCode, l_ErrorMsg);
				END IF;

				-- pv_retAdapterInvalidState -- already down
		        	-- pv_retAdapterCannotLockReqSub-- Not a ERROR
               		 	-- pv_retAdapterCtrlNotRunning -- Not possible
		                -- pv_retAdapterAbnormalExit/CommFailed -- will stop on its own
				-- when other errors -- ERROR

				if ((l_RetCode <> 0) and
				(l_retcode <> XDP_ADAPTER.pv_retAdapterInvalidState) and
				(l_retcode <> XDP_ADAPTER.pv_retAdapterCommFailed) and
				(l_retcode <> XDP_ADAPTER.pv_retAdapterCannotLockReqSub)) THEN

 					-- dbms_output.put_line('l_Retcode: ' || l_RetCode);
 					-- dbms_output.put_line('l_ErrorMsg: ' || l_ErrorMsg);

					l_AdapterTobeTerminated := TRUE;
					if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
					    FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
						'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
						'Adapter stop failed with error: '||l_RetCode||', error msg: '||l_ErrorMsg);
					end if;

				elsif (l_retcode = XDP_ADAPTER.pv_retAdapterCannotLockReqSub) then
				        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
				 	    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
						'Adapter stop request submitted');
					    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
						l_ErrorMsg);
					end if;

					-- Although request has been submitted
					-- Hopefully it should complete
					-- before XDP_CTRL_WAIT_TO_KILL_MINUTES

					l_AdapterTobeTerminated := TRUE;
				else
					-- Success, InvalidState, CommFailed case
					-- InvalidState means already stoppped
					-- CommFailed means adapter will stop on its own
				   if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
					FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
						'Adapter successfully stopped');
				   end if;
				end if;

				-- Irrespective of Stop_Adapter outcome
				-- Adapters have to be terminated
				-- incase they donot shutdown gracefully
				-- on their own

				if ((v_AdapterPID.process_id > 0) and
					(l_AdapterToBeTerminated = TRUE)) then
					if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
					    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
						'Adapter '||v_AdapterPID.channel_name||
						' will be forcefully terminated');
					end if;

					l_term_adapter_count := l_term_adapter_count + 1;
                			l_term_adapters_list(l_term_adapter_count).channel_name :=
								v_AdapterPID.channel_name;
                			l_term_adapters_list(l_term_adapter_count).process_id :=
								v_AdapterPID.process_id;
					if l_retcode = XDP_ADAPTER.pv_retAdapterCannotLockReqSub then
                                            l_term_adapters_list(l_term_adapter_count).lock_retry :=
                                                                                          'Y';
                                        else
                                            l_term_adapters_list(l_term_adapter_count).lock_retry :=
                                                                                          'N';
                                        END IF;

				end if;

				commit;
			end if;
		end loop;

		if l_term_adapters_list.COUNT > 0 then

			DBMS_LOCK.SLEEP (GetCtrlWaitToKillMins*60);

			for i in 1..l_term_adapters_list.COUNT loop
				if (l_term_adapters_list.EXISTS(i) and
					(l_term_adapters_list(i).lock_retry = 'Y')) then

					Stop_Impl_Adapter (l_term_adapters_list(i).channel_name,
								l_RetCode, l_ErrorMsg);
					commit;

					if ((l_RetCode = 0) or
					(l_retcode = XDP_ADAPTER.pv_retAdapterInvalidState) or
					(l_retcode = XDP_ADAPTER.pv_retAdapterCommFailed)) THEN
					    l_term_adapters_list(i).process_id := -1;
					END IF;
				END IF;
			END LOOP;

			for i in 1..l_term_adapters_list.COUNT loop
				if (l_term_adapters_list.EXISTS(i) and
					(l_term_adapters_list(i).process_id > 0)) then

					if p_AdapterInfo = 'NONE' then
						p_AdapterInfo :=
						l_term_adapters_list(i).channel_name||':'||
						l_term_adapters_list(i).process_id||':';
					else
						p_AdapterInfo := p_AdapterInfo||
						l_term_adapters_list(i).channel_name||':'||
						l_term_adapters_list(i).process_id||':';
					end if;

				END IF;
			END LOOP;
		END IF;
                if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		   FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
				'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
				'Adapters to be forcefully stopped: '||p_AdapterInfo);
		end if;

	else
 		-- dbms_output.put_line('ConcQID: ' || l_ConcQID);
		if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		    FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
			'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
			'Could not get concurrent queue id for CPID: '||p_CPID);
	        end if;
	end if;

exception
when others then
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_CONTROLLER_CORE.PERFORM_STOP_PROCESSING',
	'Unhandled error, SQLCODE: '||SQLCODE);
end if;

end Perform_Stop_Processing;

Procedure NotifyControllerNotRunning (p_Controllers in VARCHAR2)
is
 l_NotifID number;
 l_NotifRecipient varchar2(80);
begin
 l_NotifRecipient := xdp_utilities.GetSystemErrNotifRecipient;

   l_NotifID := wf_notification.Send(role => l_NotifRecipient,
			msg_type => xdp_utilities.pv_ErrorNotifItemType,
                        msg_name => XDP_CONTROLLER_CORE.pv_ControllerNotRunningMsg,
                        due_date =>sysdate);

   wf_notification.SetAttrText( nid    => l_NotifID,
                                aname  => 'CONTROLLER_SERVICE',
                                avalue => p_Controllers );

end NotifyControllerNotRunning;

-- Does processing that is required when Controller starts
-- Added - sacsharm
Procedure Perform_Start_Processing (p_CPID in varchar2,
			  p_AdapterInfo OUT NOCOPY varchar2)
is

l_ConcQID 		number := 0;
l_ConcQName 		varchar2 (30);
l_ErrorMsg     		VARCHAR2 (4000);
l_RetCode      		NUMBER := 0;
l_req      		NUMBER;
l_job      		NUMBER;

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_CONTROLLER_CORE.PERFORM_START_PROCESSING',
					'BEGIN:p_CPID: '||p_CPID);
	end if;

	p_AdapterInfo := 'NONE';
	XDP_APPLICATION.Fetch_ConcQ_Details (
		CPID => p_CPID,
		ConcQID => l_ConcQID,
		ConcQName => l_ConcQName);

	if l_ConcQID > 0 then

		XDP_ADAPTER.Verify_Running_Adapters (
				p_controller_instance_id => l_ConcQID,
				x_adapter_info => p_AdapterInfo,
				p_retcode => l_RetCode,
				p_errbuf => l_ErrorMsg
				);

		if (l_RetCode = 0) then
		    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
				'XDP_CONTROLLER_CORE.PERFORM_START_PROCESSING',
				'Adapters to be resetted: '||p_AdapterInfo);
		    end if;
		else
		    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
				'XDP_CONTROLLER_CORE.PERFORM_START_PROCESSING',
				'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS returned error: '||
					l_RetCode||', Desc: '||l_ErrorMsg);
		    end if;
		END IF;

		-- Either way, we donot want Controller to verify adapters on basis of
		-- PIDs

		p_AdapterInfo := 'NONE';

		XDP_ADAPTER.Reset_SysDeactivated_Adapters (p_controller_instance_id => l_ConcQID);

	else
 		-- dbms_output.put_line('ConcQID: ' || l_ConcQID);
		if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		    FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
			'XDP_CONTROLLER_CORE.PERFORM_START_PROCESSING',
			'Could not get concurrent queue id for CPID: '||p_CPID);
		end if;
	end if;

exception
when others then
p_AdapterInfo := 'NONE';
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_CONTROLLER_CORE.PERFORM_START_PROCESSING',
	'Unhandled error, SQLCODE: '||SQLCODE);
end if;

end Perform_Start_Processing;

Procedure Process_Control_Command(p_ChannelName in varchar2,
                                p_Operation in varchar2,
                                p_OpData in varchar2 default null,
                                p_Caller in varchar2 default 'USER',
                                p_Status OUT NOCOPY varchar2,
                                p_ErrorMessage OUT NOCOPY varchar2)
is
l_ErrorMsg     		VARCHAR2 (4000);
l_RetCode      		NUMBER := 0;
begin

    p_Status := XDP_ADAPTER_CORE.pv_AdapterResponseSuccess;
    p_ErrorMessage := '';

    -- Lock adapter incase p_Operation is pv_opConnect or pv_opResume
    if p_Operation = XDP_ADAPTER.pv_opConnect or p_Operation = XDP_ADAPTER.pv_opResume then
        if (XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName) = 'N') then
                --Should not happen
                --raise e_UnabletoLockAdapter;
                null;
        end if;
    END IF;

    XDP_ADAPTER_CORE.ProcessControlCommand (
                         p_ChannelName => p_ChannelName,
                         p_Operation => p_Operation,
                         p_OpData => p_OpData,
                         p_Status => p_Status,
                         p_ErrorMessage => p_ErrorMessage);

    if p_Status = XDP_ADAPTER_CORE.pv_AdapterResponseSuccess then

        -- Deactivate the automatic adapter in case user stops it.
        if p_Operation = XDP_ADAPTER.pv_opStop then

            if (p_Caller = XDP_ADAPTER.pv_CallerContextUser) then

                if (XDP_ADAPTER_CORE_DB.Is_Adapter_Automatic(p_ChannelName)) then

                    XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
                        p_ChannelName => p_ChannelName,
                        p_Status => XDP_ADAPTER.pv_statusDeactivated);
                END IF;
            END IF;

        elsif p_Operation = XDP_ADAPTER.pv_opConnect or p_Operation = XDP_ADAPTER.pv_opResume then
            -- Handover the channel
            XDPCORE_FA.HandOverChannel (ChannelName => p_ChannelName,
                                        FeID => 0,
                                        ChannelUsageCode => NULL,
                                        Caller => 'ADMIN',
                                        ErrCode => l_RetCode,
                                        ErrStr => l_ErrorMsg);
	    if l_RetCode <> 0 then
		rollback;
                p_Status := XDP_ADAPTER_CORE.pv_ProcessCommandError;
                p_ErrorMessage := 'Error in HandOverChannel, error: '||substr(l_ErrorMsg,1,255);
	    end if;
        END IF;

    elsif p_Status = XDP_ADAPTER_CORE.pv_AdapterResponseFailure then
            -- p_ErrorMessage will already be set by Adapter
            -- Adapter will go down on its own
            -- Do nothing
            null;

    elsif p_Status = XDP_ADAPTER_CORE.pv_ProcessCommandTimedout then

                p_ErrorMessage := 'Operation timed out';
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
				p_ChannelName => p_ChannelName,
				p_Status => XDP_ADAPTER.pv_statusStoppedError,
				p_ErrorMsg => 'XDP_ADAPTER_OP_COMM_FAILURE');

	-- elsif p_Status = XDP_ADAPTER_CORE.pv_ProcessCommandError then
    else
                p_ErrorMessage := 'dbms_pipe error';
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
				p_ChannelName => p_ChannelName,
				p_Status => XDP_ADAPTER.pv_statusStoppedError,
				p_ErrorMsg => 'XDP_ADAPTER_PIPE_ERROR');

    end if;

    if p_Operation = XDP_ADAPTER.pv_opConnect or p_Operation = XDP_ADAPTER.pv_opResume then
        -- Release adapter lock
	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
            if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                'XDP_CONTROLLER_CORE.PROCESS_CONTROL_COMMAND',
                                'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;
    END IF;

    commit;

exception
when others then
if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                        'XDP_CONTROLLER_CORE.PROCESS_CONTROL_COMMAND',
                        'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_CONTROLLER_CORE.PROCESS_CONTROL_COMMAND',
	'Unhandled error, SQLCODE: '||SQLCODE);
end if;
rollback;
p_Status := XDP_ADAPTER_CORE.pv_ProcessCommandError;
p_ErrorMessage := 'Unhandled error, SQLCODE: '||SQLCODE;

end Process_Control_Command;


Procedure Stop_Impl_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is
l_Status varchar2(4000);

begin
        if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.STOP_IMPL_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName, XDP_ADAPTER.pv_OpStop,
                                                       l_Status) then
	    p_retcode := XDP_ADAPTER.pv_retAdapterInvalidState;
            return;
        end if;

        if (XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName) = 'N') then
	    p_retcode := XDP_ADAPTER.pv_retAdapterCannotLockReqSub;
            return;
        end if;

        -- Cannot use Verify_Adapter API as call to update row has to be autonomous
        if not XDP_ADAPTER_CORE_DB.Verify_Adapter (p_ChannelName) then
            if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	         if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
                        FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VALIDATE_OPERATION',
                        'Could not release the lock, Channel name: '||p_ChannelName);
		end if;
            end if;
	    p_retCode := XDP_ADAPTER.pv_retAdapterCommFailed;
            return;
        END IF;

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
		p_ChannelName => p_ChannelName,
		p_Status => XDP_ADAPTER.pv_statusStopping);

	Process_Control_Command(p_ChannelName => p_ChannelName,
                               p_Operation           => XDP_ADAPTER.pv_opStop,
                               p_Caller              => XDP_ADAPTER.pv_callerContextAdmin,
                               p_Status              => l_Status,
                               p_ErrorMessage        => p_errbuf);

        -- pv_AdapterResponseFailure means handshake happened with adapter, adapter will go down
        if ((l_Status <> XDP_ADAPTER_CORE.pv_AdapterResponseSuccess) and
            (l_Status <> XDP_ADAPTER_CORE.pv_AdapterResponseFailure)) then
		p_retCode := XDP_ADAPTER.pv_retAdapterOtherError;
        END IF;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.STOP_IMPL_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.STOP_IMPL_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;

p_retCode := SQLCODE;
p_errbuf :=  SQLERRM;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.STOP_IMPL_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Stop_Impl_Adapter;

Function GetCtrlWaitToKillMins return number
is
 l_ProfileValue varchar2(40);
begin
        if fnd_profile.defined('XDP_CTRL_WAIT_TO_KILL_MINUTES') then
                fnd_profile.get('XDP_CTRL_WAIT_TO_KILL_MINUTES', l_ProfileValue);
                        if to_number(l_ProfileValue) <= 0 then
                                l_ProfileValue := '2';
                        end if;
        else
                l_ProfileValue := '2';
        end if;

        return to_number(l_ProfileValue);

end GetCtrlWaitToKillMins;

end XDP_CONTROLLER_CORE;

/
