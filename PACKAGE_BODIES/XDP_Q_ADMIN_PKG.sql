--------------------------------------------------------
--  DDL for Package Body XDP_Q_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_Q_ADMIN_PKG" AS
/* $Header: XDPQADMB.pls 120.4 2006/04/10 23:21:23 dputhiye ship $ */

/********** Commented out - START - sacsharm - 11.5.6 **************

 PROCEDURE VerifyDQProcesses (
		p_q_name IN VARCHAR2,
		p_dq_count OUT NUMBER,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2);

-- ************************** PROCEDURE UPDATE_Q_STATUS **************************************
-- * Author: Sachin Sharma
-- * Date Created: April 20, 1999
-- *
-- * INPUTS : Queue name
-- *          Action code
-- * OUTPUTS: Standard error handling parameters
-- * RETURNS: None
-- *
-- * This procedure updates the state of an queue. State of an queue has impact on the
-- * DQ processes for e.g. if queue state is updated to SHUTDOWN, related DQ processes
-- * automatically shutdown.
-- *
-- * Called by: Console UI to suspend, resume, start, stop queue.
-- * Calls    :
-- *		XDP_AQ_UTILITIES.SHUTDOWN_SDP_AQ
-- *		XDP_AQ_UTILITIES.ENABLE_SDP_AQ
-- *		FND_MESSAGE.CLEAR
-- *		FND_MESSAGE.SET_NAME
-- *		FND_MESSAGE.SET_TOKEN
-- *		FND_MESSAGE.GET
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * -----------------------------------------------------------------------------------------
-- ********************************************************************************************

 PROCEDURE Update_Q_Status (
		p_q_name IN VARCHAR2,
		p_action_code IN VARCHAR2,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS

 l_CurrentState			VARCHAR2(10);
 l_CurrentCount			NUMBER;
 l_ResourceName       		VARCHAR2 (80);
 l_IncorrectQStateError		BOOLEAN := TRUE;
 l_Status       		VARCHAR2 (1024);

 e_ResourceBusy     		EXCEPTION;
 e_IncorrectQState     		EXCEPTION;
 e_CalledProgErr		EXCEPTION;
 pragma exception_init (e_ResourceBusy, -00054);

 begin
	p_sql_code := 0;
	p_sql_desc := '';

	-- Lock the row related to the Q and get the display name

	SELECT display_name, state, num_of_dqer INTO l_ResourceName, l_CurrentState, l_CurrentCount
        FROM XDP_DQ_CONFIGURATION_VL
        --skilaru 03/28/2001
        --WHERE UPPERi(nternal_q_name) = UPPER(p_q_name)
        WHERE internal_q_name = UPPER(p_q_name)
          and DQ_PROC_NAME <> 'NODQPROC'
        FOR UPDATE NOWAIT;

	if (p_action_code = 'STARTUP') then
		if (l_CurrentState = 'SHUTDOWN') then

			XDP_Q_ADMIN_PKG.START_Q (
				p_q_name,
				l_ResourceName,
				l_CurrentState,
				l_CurrentCount,
				1,
				'NON_CONC_JOB',
				p_sql_code,
				p_sql_desc);

			if (p_sql_code <> 0) then
				RAISE e_CalledProgErr;
			end if;

		elsif (l_CurrentState = 'ENABLED') then

			-- Warn only -- already started
 			l_IncorrectQStateError := FALSE;
			RAISE e_IncorrectQState;
		else
			RAISE e_IncorrectQState;
		END IF;

	elsif (p_action_code = 'SHUTDOWN') then
		if (l_CurrentState <> 'SHUTDOWN') then
			XDP_AQ_UTILITIES.SHUTDOWN_SDP_AQ (p_q_name, p_sql_code, p_sql_desc);
			if (p_sql_code <> 0) then
				RAISE e_CalledProgErr;
			end if;
		else
			-- Warn only already stopped ?
 			l_IncorrectQStateError := FALSE;
			RAISE e_IncorrectQState;
		END IF;

	elsif (p_action_code = 'SUSPEND') then
		if (l_CurrentState = 'ENABLED') then
      			update XDP_DQ_CONFIGURATION set
				STATE = 'SUSPENDED',
				LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
				LAST_UPDATE_DATE = SYSDATE,
				LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
                        --skilaru 03/28/2001
			--where UPPER(INTERNAL_Q_NAME) = UPPER(p_q_name);
			where INTERNAL_Q_NAME = UPPER(p_q_name);
		elsif (l_CurrentState = 'SUSPENDED') then
			-- Warn already suspended ?
 			l_IncorrectQStateError := FALSE;
			RAISE e_IncorrectQState;
		else
			RAISE e_IncorrectQState;
		END IF;

	elsif (p_action_code = 'RESUME') then
		if (l_CurrentState = 'SUSPENDED') then
			XDP_AQ_UTILITIES.ENABLE_SDP_AQ (p_q_name, p_sql_code, p_sql_desc);
			if (p_sql_code <> 0) then
				RAISE e_CalledProgErr;
			end if;
		else
			RAISE e_IncorrectQState;
		END IF;
	else
		-- Development time error message, no translation required
		p_sql_code := -20001;
		p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.UPDATE_Q_STATUS. Invalid action code :'
				||p_action_code||': passed';
		ROLLBACK;
		return;
	END IF;

	COMMIT;

 EXCEPTION

 WHEN e_ResourceBusy THEN
 p_sql_code := -54;
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'RESOURCE_BUSY');
 FND_MESSAGE.SET_TOKEN ('RESOURCE_NAME', l_ResourceName);
 p_sql_desc := FND_MESSAGE.GET;
 ROLLBACK;
 -- DBMS_OUTPUT.PUT_LINE (p_sql_desc);
 -- APP_EXCEPTION.RAISE_EXCEPTION;


 WHEN e_IncorrectQState THEN
 p_sql_code := -20001;
 FND_MESSAGE.CLEAR;
 if (l_IncorrectQStateError = FALSE) then  -- Warn case
 	FND_MESSAGE.SET_NAME ('XDP', 'OPERATION_ALREADY_PERFORMED');
 else
 	FND_MESSAGE.SET_NAME ('XDP', 'INCORRECT_Q_STATE');
	FND_MESSAGE.SET_TOKEN ('CURRENT_STATE', l_CurrentState);
 END IF;
 p_sql_desc := FND_MESSAGE.GET;
 ROLLBACK;
 -- DBMS_OUTPUT.PUT_LINE (p_sql_desc);
 -- APP_EXCEPTION.RAISE_EXCEPTION;

 WHEN e_CalledProgErr THEN
 ROLLBACK;
 -- APP_EXCEPTION.RAISE_EXCEPTION;

 WHEN OTHERS THEN
 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.UPDATE_Q_STATUS, Error Desc.: '||
			 SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.UPDATE_Q_STATUS, Other non-SQL error';
 END IF;

 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');
 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;
 ROLLBACK;
 -- DBMS_OUTPUT.PUT_LINE (p_sql_desc);
 -- APP_EXCEPTION.RAISE_EXCEPTION;

 END UPDATE_Q_STATUS;

-- ****************************** PROCEDURE START_Q *******************************************
-- * Author: Sachin Sharma
-- * Date Created: April 20, 1999
-- *
-- * INPUTS : Queue name
-- * OUTPUTS: Standard error handling parameters
-- * RETURNS: None
-- *
-- * This procedure checks whether the DQers processes associated with a queue have
-- * shutdown, if yes, it enables the queue and starts the DQer processes associated with it.
-- *
-- * Called by: Administration utilities
-- *		XDP_Q_ADMIN_PKG.UPDATE_Q_STATUS
-- * Calls    :
-- *        	XDP_ADAPTER_ADMIN.LockVerifyController;
-- *		XDP_AQ_UTILITIES.ENABLE_SDP_AQ
-- *		XDP_RECOVERY.CHECKNSTARTDQPROCESSES
-- *		FND_MESSAGE.CLEAR;
-- *		FND_MESSAGE.SET_NAME
-- *		FND_MESSAGE.SET_TOKEN
-- *		FND_MESSAGE.GET
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * -----------------------------------------------------------------------------------------
-- ****************************************************************************************

 PROCEDURE Start_Q (
		p_q_name IN VARCHAR2,
		p_q_display_name IN VARCHAR2,
		p_q_state IN VARCHAR2,
		p_q_count IN NUMBER,
		p_max_tries IN NUMBER DEFAULT 1,
		p_caller IN VARCHAR2 DEFAULT 'NON_CONC_JOB',
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS

 l_Status       		VARCHAR2 (1024);
 l_dq_count       		NUMBER := 0;
 l_ControllerFlag1		BOOLEAN := FALSE;
 l_ControllerFlag2		BOOLEAN := FALSE;
 l_RetNumber			NUMBER := 0;

 e_CalledProgErr		EXCEPTION;
 e_ShutDownInProgress		EXCEPTION;
 e_ResourceBusy     		EXCEPTION;

 pragma exception_init (e_ResourceBusy, -00054);

 begin
	p_sql_code := 0;
	p_sql_desc := '';

	-- No need to lock the row related to the queue as already locked by the
	-- caller Update_Q_Status or Start_All_Qs

        XDP_ADAPTER_ADMIN.LockVerifyController
		(
		errbuf 			=> p_sql_desc,
		retcode 		=> p_sql_code,
		IsControllerLocked 	=> l_ControllerFlag1,
		IsControllerDown 	=> l_ControllerFlag2,
		MaxTries 		=> p_max_tries,
		MaxTriesLock 		=> p_max_tries,
		Caller 			=> p_caller
		);

	if p_sql_code <> 0 then
		if p_caller = 'CONC_JOB' then
      			FND_FILE.put_line(FND_FILE.log,
				'LockVerifyController returned error');
      			FND_FILE.put_line(FND_FILE.log, p_sql_desc);
		END IF;
		RAISE e_CalledProgErr;
	else
		l_dq_count := 0;

		if p_caller = 'CONC_JOB' then
      			FND_FILE.put_line(FND_FILE.output,
				'Verifying the DQ processes for the queue');
		END IF;

		VerifyDQProcesses (
			p_q_name,
			l_dq_count,
			p_sql_code,
			p_sql_desc);

		if p_sql_code <> 0 then
			if p_caller = 'CONC_JOB' then
      				FND_FILE.put_line(FND_FILE.log,
					'VerifyDQProcesses returned error');
      				FND_FILE.put_line(FND_FILE.log, p_sql_desc);
			END IF;
			RAISE e_CalledProgErr;

		else

			if p_caller = 'CONC_JOB' then
      				FND_FILE.put_line(FND_FILE.output,
					'Found '||l_dq_count
					||' DQ processes running for the queue');
			END IF;

			if p_q_state = 'SHUTDOWN' then

				if l_dq_count > 0 then
					if p_caller = 'CONC_JOB' then
      						FND_FILE.put_line(FND_FILE.log,
						'Cannot start the queue, shutdown is in progress');
					END IF;
					RAISE e_ShutdownInProgress;
				else
					-- Enable the queue

					if p_caller = 'CONC_JOB' then
      						FND_FILE.put_line(FND_FILE.output,
							'Enabling the queue');
					END IF;

					XDP_AQ_UTILITIES.ENABLE_SDP_AQ (p_q_name, p_sql_code, p_sql_desc);
					if p_sql_code <> 0 then
						if p_caller = 'CONC_JOB' then
      							FND_FILE.put_line(FND_FILE.log,
								'Enable queue returned error');
      							FND_FILE.put_line(FND_FILE.log, p_sql_desc);
						END IF;
						RAISE e_CalledProgErr;
					else

-- Reason: Fixed BUG 1085175 By: sacsharm On: 06-Dec-1999

						-- Commit required else DQ processes might not see the
						-- Q status to be enabled but this will release all locks
						-- But for this COMMIT no commits, rollbacks required
						-- as they are present in caller logic

						COMMIT;
					END IF;

				END IF;

				-- COMMIT done Lock the queue and Controller again

				SELECT 1 INTO l_RetNumber
       				FROM XDP_DQ_CONFIGURATION
                                --skilaru 03/27/2001
       				--WHERE UPPER(internal_q_name) = UPPER(p_q_name)
       				WHERE internal_q_name = UPPER(p_q_name)
       				FOR UPDATE NOWAIT;

       				XDP_ADAPTER_ADMIN.LockVerifyController
				(
				errbuf 			=> p_sql_desc,
				retcode 		=> p_sql_code,
				IsControllerLocked 	=> l_ControllerFlag1,
				IsControllerDown 	=> l_ControllerFlag2,
				MaxTries 		=> p_max_tries,
				MaxTriesLock 		=> p_max_tries,
				Caller 			=> p_caller
				);

				if p_sql_code <> 0 then
					if p_caller = 'CONC_JOB' then
						FND_FILE.put_line(FND_FILE.log,
							'Could not lock the Controller again');
      						FND_FILE.put_line(FND_FILE.log, p_sql_desc);
					END IF;

					-- Revert back the status in case of error

      					update XDP_DQ_CONFIGURATION
      					set STATE = 'SHUTDOWN',
      					LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
      					LAST_UPDATE_DATE = sysdate,
      					LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
       					where internal_q_name = UPPER(p_q_name);
					COMMIT;

					RAISE e_CalledProgErr;
				END IF;

			elsif p_q_state = 'ENABLED' then

				if p_q_count = l_dq_count then
					if p_caller = 'CONC_JOB' then
      						FND_FILE.put_line(FND_FILE.output,
						'Required number of DQ processes '||
						p_q_count||' already running');
					END IF;
					return;
				else
					if p_caller = 'CONC_JOB' then
      						FND_FILE.put_line(FND_FILE.output,
						'Some DQ processes are required to be restarted');
					END IF;

				END IF;
			END IF;

		END IF;

		if p_caller = 'CONC_JOB' then
      			FND_FILE.put_line(FND_FILE.output,
				'Attempting to start DQ processes');
		END IF;

		-- Start DQ processes as per configuration
       		XDP_RECOVERY.CheckNStartDQProcesses (p_q_name, TRUE, l_Status,
			p_sql_code, p_sql_desc);

		if p_sql_code = 0 then
			-- Donot commit in success case, caller will
			if p_caller = 'CONC_JOB' then
      				FND_FILE.put_line(FND_FILE.output,
				'DQ processes successfully started');
			END IF;
		else
			if p_caller = 'CONC_JOB' then
      				FND_FILE.put_line(FND_FILE.log,
				'CheckNStartDQProcesses returned error');
				FND_FILE.put_line(FND_FILE.log, p_sql_desc);
			END IF;
			-- Here we are commiting as some DQ processes at OS may
			-- have been started
			COMMIT;
		END IF;

	END IF;


 EXCEPTION

 WHEN e_ResourceBusy THEN
 p_sql_code := -54;
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'RESOURCE_BUSY');
 FND_MESSAGE.SET_TOKEN ('RESOURCE_NAME', p_q_display_name);
 p_sql_desc := FND_MESSAGE.GET;
-- Revert back the status in case of error
-- Logic will come here only if queue cannot be locked after
-- first COMMIT
if p_caller = 'CONC_JOB' then
	FND_FILE.put_line(FND_FILE.log,
	'Could not lock the queue again');
END IF;
update XDP_DQ_CONFIGURATION
set STATE = 'SHUTDOWN',
LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
LAST_UPDATE_DATE = sysdate,
LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
where internal_q_name = UPPER(p_q_name);
COMMIT;

 WHEN e_ShutdownInProgress THEN
 p_sql_code := -20001;
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'Q_SHUTDOWN_IN_PROGRESS');
 FND_MESSAGE.SET_TOKEN ('QUEUE_NAME', p_q_display_name);
 p_sql_desc := FND_MESSAGE.GET;

 WHEN e_CalledProgErr THEN
 NULL;

 WHEN OTHERS THEN
 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.START_Q, Error Desc.: '
			|| SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.START_Q, Other non-SQL error';
 END IF;

 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');
 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;

 END START_Q;


-- *************************** PROCEDURE START_ALL_QS ******************************************
-- * Author: Sachin Sharma
-- * Date Created: Dec. 09 1999
-- *
-- * INPUTS : None
-- * OUTPUTS: Standard error handling parameters
-- * RETURNS: None
-- *
-- * This procedure checks whether the DQers processes associated with all queue have
-- * shutdown, if yes, it enables the queues and starts the DQer processes associated with them.
-- *
-- * Called by: Administration utilities
-- *		XDP_ADAPTER_ADMIN.XDP_START
-- * Calls    :
-- *		XDP_Q_ADMIN.START_Q
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * -----------------------------------------------------------------------------------------
-- *******************************************************************************************

 PROCEDURE Start_All_Qs (
		p_caller IN VARCHAR2 DEFAULT 'CONC_JOB',
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS

 -- If the caller is CONC_JOB i.e. application start then start all queues
 -- in state SHUTDOWN and ENABLED else i.e. it is called from Watchdog
 -- start queues having state ENABLED only. In former resultant state list
 -- will be ('ENABLED', 'SHUTDOWN') and in latter it will be ('ENABLED', 'ENABLED')

 cursor c_GetQList (lc_caller VARCHAR2) is
	select INTERNAL_Q_NAME, DISPLAY_NAME, STATE, NUM_OF_DQER
	from XDP_DQ_CONFIGURATION_VL
          where DQ_PROC_NAME <> 'NODQPROC'
		and STATE in
			('ENABLED', decode (lc_caller, 'CONC_JOB', 'SHUTDOWN', 'ENABLED'))
	order by STATE, INTERNAL_Q_NAME;

 l_RetNumber			NUMBER := 0;
 l_SomeErrorFlag		BOOLEAN := FALSE;

 e_ResourceBusy			EXCEPTION;
 e_CalledProgErr		EXCEPTION;

 pragma exception_init (e_ResourceBusy, -00054);

 begin
	p_sql_code := 0;
	p_sql_desc := '';

	for v_QData in c_GetQList (p_caller) loop

		if p_caller = 'CONC_JOB' then
			if v_QData.STATE = 'SHUTDOWN' then
				FND_FILE.put_line(FND_FILE.output,
					'Attempting to start the queue: '||v_QData.INTERNAL_Q_NAME);
			else
				FND_FILE.put_line(FND_FILE.output,
					'Verifying the queue: '||v_QData.INTERNAL_Q_NAME);
			END IF;
		END IF;

		-- Lock the current row

		begin

			SELECT 1 INTO l_RetNumber
        		FROM XDP_DQ_CONFIGURATION
                        --skilaru 03/27/2001
        		--WHERE UPPER(internal_q_name) = UPPER(v_QData.INTERNAL_Q_NAME)
        		WHERE internal_q_name = UPPER(v_QData.INTERNAL_Q_NAME)
        		FOR UPDATE NOWAIT;

		EXCEPTION

 		WHEN e_ResourceBusy THEN
		l_SomeErrorFlag := TRUE;
		if p_caller = 'CONC_JOB' then
			FND_FILE.put_line(FND_FILE.log,
				'Could not lock the queue: '||v_QData.INTERNAL_Q_NAME);
		END IF;
		GOTO l_EndOfLoop;

		END;

		XDP_Q_ADMIN_PKG.START_Q (
			v_QData.INTERNAL_Q_NAME,
			v_QData.DISPLAY_NAME,
			v_QData.STATE,
			v_QData.NUM_OF_DQER,
			1,
			'CONC_JOB',
			p_sql_code,
			p_sql_desc);

		if p_sql_code <> 0 then
			l_SomeErrorFlag := TRUE;
			if p_caller = 'CONC_JOB' then
				FND_FILE.put_line(FND_FILE.log,
					'Error in starting/verifying the queue: '||v_QData.INTERNAL_Q_NAME);
				FND_FILE.put_line(FND_FILE.log,p_sql_desc);
			END IF;
			ROLLBACK;
		else
			if p_caller = 'CONC_JOB' then
				if v_QData.STATE = 'SHUTDOWN' then
					FND_FILE.put_line(FND_FILE.output,
						'Successfully started the queue: '
						||v_QData.INTERNAL_Q_NAME);
				else
					FND_FILE.put_line(FND_FILE.output,
						'Successfully verified the queue: '
						||v_QData.INTERNAL_Q_NAME);
				END IF;
			END IF;
			COMMIT;
		END IF;

		<<l_EndOfLoop>>
			null;

	END LOOP;

	if l_SomeErrorFlag = TRUE then
 		p_sql_code := -20001;
		p_sql_desc := 'Some application queues started with warnings';
	END IF;

 EXCEPTION

 WHEN OTHERS THEN

 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.START_ALL_QS, Error Desc.: '||
		 SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.START_ALL_QS, Other non-SQL error';
 END IF;

 if c_GetQlist%ISOPEN then
	CLOSE c_GetQList;
 END IF;
 ROLLBACK;
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');
 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;

 END START_ALL_QS;


-- **************************** PROCEDURE CHECK_Q_STATUS **************************************
-- * Author: Sachin Sharma
-- * Date Created: April 20, 1999
-- *
-- * INPUTS : Queue name
-- * OUTPUTS: DQ process count
-- *          Standard error handling parameters
-- * RETURNS: None
-- *
-- * This proceduer checks the status of an queue and returns the number of DQ processes running.
-- *
-- * Called by: Console UI
-- * Calls    :
-- *        	XDP_ADAPTER_ADMIN.LockVerifyController;
-- *		FND_MESSAGE.CLEAR;
-- *		FND_MESSAGE.SET_NAME
-- *		FND_MESSAGE.SET_TOKEN
-- *		FND_MESSAGE.GET
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * -------------------------------------------------------------------------------------------
-- **********************************************************************************************
 PROCEDURE Check_Q_Status (
		p_q_name IN VARCHAR2,
		p_dq_count OUT NUMBER,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS

 l_ControllerFlag1		BOOLEAN := FALSE;
 l_ControllerFlag2		BOOLEAN := FALSE;

 e_CalledProgErr		EXCEPTION;

 begin
	p_sql_code := 0;
	p_sql_desc := '';
	p_dq_count := 0;

        XDP_ADAPTER_ADMIN.LockVerifyController
		(
		errbuf 			=> p_sql_desc,
		retcode 		=> p_sql_code,
		IsControllerLocked 	=> l_ControllerFlag1,
		IsControllerDown 	=> l_ControllerFlag2,
		MaxTries 		=> 1,
		MaxTriesLock 		=> 1,
		Caller 			=> 'NON_CONC_JOB'
		);

	if p_sql_code <> 0 then
		RAISE e_CalledProgErr;
	else
		VerifyDQProcesses (
			p_q_name,
			p_dq_count,
			p_sql_code,
			p_sql_desc);

		if p_sql_code <> 0 then
			RAISE e_CalledProgErr;
		END IF;
	END IF;

	COMMIT;

 EXCEPTION

 WHEN e_CalledProgErr THEN
 ROLLBACK;

 WHEN OTHERS THEN
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');

 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.CHECK_Q_STATUS, Error Desc.: '
		|| SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.CHECK_Q_STATUS, Other non-SQL error';
 END IF;

 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;
 ROLLBACK;
 -- DBMS_OUTPUT.PUT_LINE (p_sql_desc);
 -- APP_EXCEPTION.RAISE_EXCEPTION;

 END CHECK_Q_STATUS;

-- **************************** PROCEDURE GET_Q_ERRORS ****************************************
-- * Author: Sachin Sharma
-- * Date Created: April 20, 1999
-- *
-- * INPUTS : Queue name
-- * OUTPUTS: List of translated messages associated with the queue
-- *          Standard error handling parameters
-- * RETURNS: None
-- *
-- * This procedure returns the exceptions associated with a queue.
-- *
-- * Called by: Console UI.
-- * Calls    :
-- *
-- * Modification history:
-- *	WHO				WHEN				WHY
-- * ------------------------------------------------------------------------------------------
-- ********************************************************************************************
 PROCEDURE Get_Q_Errors (
		p_q_name IN VARCHAR2,
		p_message_list OUT XDP_TYPES.MESSAGE_LIST,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS
-- cursor c_GetMessagesForQ (q_name VARCHAR2) is
-- 	select excep.ERROR_REF_ID, excep.TIME_STAMP
-- 	from XDP_DQ_EXCEPTIONS excep
        --skilaru 03/27/2001
	--where UPPER(excep.Q_NAME) = UPPER(q_name) and excep.Q_NAME is not NULL
-- 	where excep.Q_NAME = UPPER(q_name) and excep.Q_NAME is not NULL
-- 	order by TIME_STAMP desc;

 -- Changed - sacsharm - 11.5.6 ErrorHandling changes
 cursor c_GetMessagesForQ (q_name VARCHAR2) is
	select excep.MESSAGE, excep.ERROR_TIMESTAMP
	from XDP_ERROR_LOG_V excep
	where excep.OBJECT_KEY = UPPER(q_name) and excep.OBJECT_TYPE = 'QUEUE'
 	order by ERROR_TIMESTAMP desc;

 l_count 			NUMBER;

 begin
	p_sql_code := 0;
	p_sql_desc := '';
	p_message_list.DELETE;
	l_count := 1;

	for v_QExceps in c_GetMessagesForQ (p_q_name) loop
		p_message_list(l_count).MESSAGE_TIME := v_QExceps.ERROR_TIMESTAMP;
		p_message_list(l_count).MESSAGE_TEXT := v_QExceps.MESSAGE;
		l_count := l_count + 1;
	END LOOP;

 EXCEPTION

 WHEN OTHERS THEN

 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');
 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.GET_Q_ERRORS, Error Desc.: '|| SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.GET_Q_ERRORS, Other non-SQL error';
 END IF;

 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;
 if c_GetMessagesForQ%ISOPEN then
	CLOSE c_GetMessagesForQ;
 END IF;
 p_message_list.DELETE;
 ROLLBACK;

 -- DBMS_OUTPUT.PUT_LINE (p_sql_desc);
 -- APP_EXCEPTION.RAISE_EXCEPTION;

 END GET_Q_ERRORS;





 PROCEDURE VerifyDQProcesses (
		p_q_name IN VARCHAR2,
		p_dq_count OUT NUMBER,
		p_sql_code OUT NUMBER,
		p_sql_desc OUT VARCHAR2)
 IS

 cursor c_GetDQPIDsForQ (q_name VARCHAR2) is
	select DQER_PROCESS_ID
	from XDP_DQER_REGISTRATION a
        --skilaru 03/28/2001
	--where UPPER(a.INTERNAL_Q_NAME) = UPPER(q_name )
	where a.INTERNAL_Q_NAME = UPPER(q_name )
	FOR UPDATE OF DQER_PROCESS_ID NOWAIT
	order by DQER_PROCESS_ID;

 l_Status       		VARCHAR2 (1024);

 e_CalledProgErr		EXCEPTION;

 begin
	p_sql_code := 0;
	p_sql_desc := '';
	p_dq_count := 0;

	for v_DQProcessData in c_GetDQPIDsForQ (p_q_name) loop

		l_Status := 'FAILURE';

		XDP_RECOVERY.ValidatePID (v_DQProcessData.DQER_PROCESS_ID,
					l_Status, p_sql_code, p_sql_desc);
		if p_sql_code <> 0 then
			RAISE e_CalledProgErr;
		else
			if l_Status = 'SUCCESS' then
				-- Process running
    				p_dq_count := p_dq_count + 1;
			else
				-- Redundant row, process not running
				-- Delete the row from XDP_DQER_REGISTRATION
				DELETE XDP_DQER_REGISTRATION
				WHERE CURRENT OF c_GetDQPIDsForQ;
			END IF;
		END IF;

	END LOOP;

 EXCEPTION

 WHEN e_CalledProgErr THEN
 if c_GetDQPIDsForQ%ISOPEN then
	CLOSE c_GetDQPIDsForQ;
 END IF;

 WHEN OTHERS THEN
 if SQLCODE <> 0 then
 	p_sql_code := SQLCODE;
 	p_sql_desc := SUBSTR ('Location: XDP_Q_ADMIN_PKG.VerifyDQProcesses, Error Desc.: '||
			SQLERRM, 1, 2000);
 else
 	p_sql_code := -20001;
 	p_sql_desc := 'Location: XDP_Q_ADMIN_PKG.VerifyDQProcesses, Other non-SQL error';
 END IF;

 IF c_GetDQPIDsForQ%ISOPEN THEN
	CLOSE c_GetDQPIDsForQ;
 END IF;
 FND_MESSAGE.CLEAR;
 FND_MESSAGE.SET_NAME ('XDP', 'INTERNAL_ERROR');
 FND_MESSAGE.SET_TOKEN ('ERROR_CODE', p_sql_code);
 FND_MESSAGE.SET_TOKEN ('ERROR_DESC', p_sql_desc);
 p_sql_desc := FND_MESSAGE.GET;

 END VerifyDQProcesses;

*********** Commented out - END - sacsharm - 11.5.6 *************/

END XDP_Q_ADMIN_PKG;

/
