--------------------------------------------------------
--  DDL for Package Body XDP_RECOVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_RECOVERY" AS
/* $Header: XDPRECOB.pls 120.1 2005/06/09 00:28:59 appldev  $ */

-- Private procedures Begin
-- Private procedures END

-- Public Procedures BEGIN

-- Added sacsharm - Application Monitoring service

PROCEDURE  Start_Watchdog_Process (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2)
is

l_ControllersNotRunning	varchar2 (4000);
l_CPID 			number;
l_ContRunning 		varchar2(1);

l_RetCode		number;
l_ErrBuf		varchar2 (4000);

l_GenCountActive NUMBER := 0;
l_GenCountFuture NUMBER := 0;

l_StartFlag 	 	boolean := FALSE;

BEGIN
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_RECOVERY.START_WATCHDOG_PROCESS', 'BEGIN:');
END IF;


	-- So that Dequeuer blocks as per parameter else it immediately starts
	-- dequeuing the next message
	x_queue_timed_out := 'Y';

	--***************************************************************
	--*********  SET THE CONTEXT ************************************

	XDP_ADAPTER.pv_callerContext := XDP_ADAPTER.pv_callerContextAdmin;

	--***************************************************************
	--***************************************************************

	----------------------------------------------------------------
	-- Verify Running adapters
	----------------------------------------------------------------

	XDP_ADAPTER.Verify_All_Adapters (
				p_retcode => l_RetCode,
				p_errbuf => l_ErrBuf);

	----------------------------------------------------------------
	-- Enable/Disable NOT_AVAILABLE/Other adapters, if required
	----------------------------------------------------------------

	for v_AllAdapters in XDP_ADAPTER_CORE_DB.G_Get_All_Adapters loop


		l_GenCountActive := 0;
		l_GenCountFuture := 0;

		if v_AllAdapters.adapter_status = XDP_ADAPTER.pv_statusNotAvailable then

			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
				FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
					'XDP_RECOVERY.START_WATCHDOG_PROCESS',
					'Adapter not available: '||v_AllAdapters.CHANNEL_NAME);
			END IF;

			XDP_ADAPTER_CORE_DB.Are_Adapter_Generics_Available (
				p_fe_id => v_AllAdapters.FE_ID,
				p_AdapterType => v_AllAdapters.ADAPTER_TYPE,
				p_GenCountActive => l_GenCountActive,
				p_GenCountFuture => l_GenCountFuture);

			--if XDP_ADAPTER_CORE_DB.Is_Adapter_Available (
			--		p_fe_id => v_AllAdapters.FE_ID,
			--		p_AdapterType => v_AllAdapters.ADAPTER_TYPE) then

			if l_GenCountActive > 0 then

				IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
					FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_RECOVERY.START_WATCHDOG_PROCESS',
						'Adapter NOW available: '||v_AllAdapters.CHANNEL_NAME);
				END IF;

				-- Set the adapter status to SHUTDOWN
				XDP_ADAPTER_CORE_DB.UpdateAdapter (
					p_ChannelName => v_AllAdapters.CHANNEL_NAME,
					p_Status => XDP_ADAPTER.pv_statusStopped);

				commit;
			end if;

		else

			XDP_ADAPTER_CORE_DB.Are_Adapter_Generics_Available (
				p_fe_id => v_AllAdapters.FE_ID,
				p_AdapterType => v_AllAdapters.ADAPTER_TYPE,
				p_GenCountActive => l_GenCountActive,
				p_GenCountFuture => l_GenCountFuture);

			--if not XDP_ADAPTER_CORE_DB.Is_Adapter_Available (
			--		p_fe_id => v_AllAdapters.FE_ID,
			--		p_AdapterType => v_AllAdapters.ADAPTER_TYPE) then

			if l_GenCountActive = 0 then

				IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
					FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_RECOVERY.START_WATCHDOG_PROCESS',
						'Adapter NO LONGER available: '||v_AllAdapters.CHANNEL_NAME);
				END IF;

				-- Terminate the adapter if running
				-- if v_AllAdapters.PROCESS_ID > 0 then
				-- Could be an unimplemented adapter type
				-- if v_AllAdapters.adapter_status != XDP_ADAPTER.pv_statusStopped then

				if (v_AllAdapters.adapter_status not in
						(XDP_ADAPTER.pv_statusStopped,
						XDP_ADAPTER.pv_statusStoppedError,
						XDP_ADAPTER.pv_statusTerminated,
						XDP_ADAPTER.pv_statusDeactivated,
						XDP_ADAPTER.pv_statusDeactivatedSystem)) then

					-- This API will also check if Controller is UP

					XDP_ADAPTER.Terminate_Adapter (
						p_ChannelName => v_AllAdapters.channel_name,
						p_retcode => l_RetCode,
						p_errbuf => l_ErrBuf);

					commit;

					-- pv_retAdapterInvalidState -- Not possible as state not checked
			        	-- pv_retAdapterCannotLock -- ERROR, possibly being used
               			 	-- pv_retAdapterCtrlNotRunning -- ERROR
			                -- pv_retAdapterAbnormalExit -- Not a error
					-- when other errors -- ERROR

					if ((l_RetCode <> 0) and
                                            (l_RetCode <> XDP_ADAPTER.pv_retAdapterAbnormalExit)) then

						-- If termination is not successful, we donot
						-- update adapter status to NOT_AVAILABLE
						-- Send notification

						XDP_ADAPTER_CORE.NotifyAdapterTerminateFailure
							(v_AllAdapters.adapter_display_name);

						IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter was running, termination failed with error: '||
								l_RetCode||', message: '||l_ErrBuf);
						END IF;
					else
                                            if l_RetCode = 0 then
						IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
							'XDP_RECOVERY.START_WATCHDOG_PROCESS',
							'Adapter was running, terminated successfully');
						END IF;
                                            END IF;

                                            -- Set the adapter status to NOT_AVAILABLE
					    XDP_ADAPTER_CORE_DB.UpdateAdapter (
						p_ChannelName => v_AllAdapters.CHANNEL_NAME,
						p_Status => XDP_ADAPTER.pv_statusNotAvailable);
					end if;

				else
					-- Set the adapter status to NOT_AVAILABLE
					XDP_ADAPTER_CORE_DB.UpdateAdapter (
						p_ChannelName => v_AllAdapters.CHANNEL_NAME,
						p_Status => XDP_ADAPTER.pv_statusNotAvailable);

				end if;

				commit;
			end if;
		end if;
	end loop;

	l_ControllersNotRunning := 'NONE';

	for v_GetSvcID in XDP_ADAPTER_CORE_DB.G_Get_Controller_Instances loop

		XDP_CONTROLLER_CORE.VerifyControllerStatus
			(p_ConcQID => v_GetSvcID.service_instance_Id,
			p_CPID => l_CPID,
			p_ControllerRunning => l_ContRunning);

		if l_ContRunning <> 'Y' then
			if l_ControllersNotRunning = 'NONE' then
				-- First time
				l_ControllersNotRunning :=
					v_GetSvcID.USER_CONCURRENT_QUEUE_NAME||':';
			else
				l_ControllersNotRunning := l_ControllersNotRunning||
					v_GetSvcID.USER_CONCURRENT_QUEUE_NAME||':';
			end if;
		else
			-- Controller is running

			----------------------------------------------------------------
			-- Start the automatic (AUTO and SOD) adapters for a controller
			----------------------------------------------------------------

			for v_GetAutoAdapters in
				XDP_ADAPTER_CORE_DB.G_Get_Automatic_Adapters
					(v_GetSvcID.service_instance_id) loop

				l_StartFlag := FALSE;

				if v_GetAutoAdapters.STARTUP_MODE =
					XDP_ADAPTER.pv_startAutomatic then

					l_StartFlag := TRUE;

				else
					-- If SOD adapter

					if v_GetAutoAdapters.APPLICATION_MODE =
						XDP_ADAPTER.pv_applModeQueue then

						-- If async. messaging adapter
						-- Peek into Outbound message queue

 						if (XDP_ADAPTER_CORE_DB.GetNumOfJobsCount(
							p_fe_id => v_GetAutoAdapters.fe_id,
							p_fe_name => v_GetAutoAdapters.fulfillment_element_name,
							p_mode => 'ASYNC') > 0) then
							l_StartFlag := TRUE;
						END IF;
					else

						-- If sync. messaging adapter (PIPE OR NONE)
						-- Peek into FA job queue

						if (XDP_ADAPTER_CORE_DB.PeekIntoFeWaitQueue(
							p_ChannelName => v_GetAutoAdapters.channel_name) = 'Y') then
							l_StartFlag := TRUE;
						END IF;
					END IF;
				END IF;

				if (l_StartFlag) then

					IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
						FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
							'XDP_RECOVERY.START_WATCHDOG_PROCESS',
							'Automatic adapter required to be started: '||v_GetAutoAdapters.CHANNEL_NAME);
					END IF;

					XDP_ADAPTER.Start_Adapter (
						p_ChannelName => v_GetAutoAdapters.channel_name,
						p_retcode => l_RetCode,
						p_errbuf => l_ErrBuf);

					-- pv_retAdapterInvalidState --Not possible as cursor ensures this
			        	-- pv_retAdapterCannotLock --Not possible unless someone else
                                        --                           starting
               			 	-- pv_retAdapterCtrlNotRunning -- Not possible, already verified
			                -- pv_retAdapterAbnormalExit -- Not possible
					-- when other errors -- ERROR

					if (l_RetCode not in (0,
						XDP_ADAPTER.pv_retAdapterInvalidState,
						XDP_ADAPTER.pv_retAdapterCannotLock)) then
						IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter start failed with error: '||l_RetCode||
								', message: '||l_ErrBuf);
						END IF;
					else
						IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter started successfully');
						END IF;
					END IF;

					commit;

				END IF;

			END LOOP; -- Start automatic adapters loop

			----------------------------------------------------------------
			-- Disconnect/Stop the DWI adapters for a controller
			----------------------------------------------------------------

			for v_DWIAdapters in XDP_ADAPTER_CORE_DB.G_Get_DWI_Adapters
							(v_GetSvcID.service_instance_id) loop

				if (v_DWIAdapters.STARTUP_MODE = XDP_ADAPTER.pv_startOnDemand) then

					-- Stop IDLE SOD adapters

					IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
						FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
							'XDP_RECOVERY.START_WATCHDOG_PROCESS',
							'Adapter idle, required to be stopped: '||v_DWIAdapters.CHANNEL_NAME);
					END IF;

					XDP_ADAPTER.Stop_Adapter (
						p_ChannelName => v_DWIAdapters.channel_name,
						p_retcode => l_RetCode,
						p_errbuf => l_ErrBuf);

					-- pv_retAdapterInvalidState -- Not an ERROR
			        	-- pv_retAdapterCannotLock -- getting used NOW
               			 	-- pv_retAdapterCtrlNotRunning -- Not possible, already verified
			                -- pv_retAdapterAbnormalExit --
					-- when other errors -- ERROR

					if (l_RetCode not in (0,
						XDP_ADAPTER.pv_retAdapterInvalidState,
						XDP_ADAPTER.pv_retAdapterCannotLockReqSub,
						XDP_ADAPTER.pv_retAdapterOpFailed)) then
						IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter stop failed with error: '||l_RetCode||
								', message: '||l_ErrBuf);
						END IF;
					elsif l_RetCode = XDP_ADAPTER.pv_retAdapterCannotLockReqSub then
						-- Admin request would be submitted as lock
						-- was not obtained on adapter
						-- We donot need to stop adapter as it needs to be used
						-- as someother process (FA) has locked it for use
						rollback;
                                        else
						IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter stopped successfully');
						END IF;
					END IF;
				else
					-- Disconnect IDLE COD adapters

					IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
						FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
							'XDP_RECOVERY.START_WATCHDOG_PROCESS',
							'Adapter idle, required to be disconnected: '||v_DWIAdapters.CHANNEL_NAME);
					END IF;

					XDP_ADAPTER.Disconnect_Adapter (
						p_ChannelName => v_DWIAdapters.channel_name,
						p_retcode => l_RetCode,
						p_errbuf => l_ErrBuf);

					-- pv_retAdapterInvalidState -- Not an ERROR
			        	-- pv_retAdapterCannotLock -- getting used NOW
               			 	-- pv_retAdapterCtrlNotRunning -- Not possible, already verified
			                -- pv_retAdapterAbnormalExit -- Not an ERROR
					-- when other errors -- ERROR

					if (l_RetCode not in (0,
						XDP_ADAPTER.pv_retAdapterInvalidState,
						XDP_ADAPTER.pv_retAdapterCannotLock,
						XDP_ADAPTER.pv_retAdapterOpFailed)) then
						IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
							'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter disconnect failed with error: '||l_RetCode||
								', message: '||l_ErrBuf);
						END IF;
					else
						IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
							FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
								'XDP_RECOVERY.START_WATCHDOG_PROCESS',
								'Adapter disconnected successfully');
						END IF;
					end if;

				END IF;

				commit;

			end loop; -- Stop/DWI adapters

		end if; -- Controller running

	END LOOP; -- Controller loop

	if l_ControllersNotRunning <> 'NONE' then

		IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_RECOVERY.START_WATCHDOG_PROCESS',
				'Controllers NOT running: '||l_ControllersNotRunning);
		END IF;

		-- Send notification with messages text as
		-- l_ControllersNotRunning
		XDP_CONTROLLER_CORE.NotifyControllerNotRunning (l_ControllersNotRunning);
		commit;

	end if;

EXCEPTION
WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_RECOVERY.START_WATCHDOG_PROCESS',
			'Unhandled error, SQLCODE: '||SQLCODE);
	END IF;
commit;

end Start_Watchdog_Process;

--
--  Package Initialization values
--

-- BEGIN

END XDP_RECOVERY;

/
