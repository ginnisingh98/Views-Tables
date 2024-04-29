--------------------------------------------------------
--  DDL for Package Body XDP_CRON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_CRON_UTIL" AS
/* $Header: XDPCRONB.pls 120.1 2005/06/08 23:51:10 appldev  $ */

Procedure SubmitAdapterAdminJob (
	p_request in number,
	p_RunDate in date,
	p_RunFreq in number default null,
	p_JobNumber OUT NOCOPY number )
IS
l_tmpdate varchar2(4000);
BEGIN
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_CRON_UTIL.SUBMITADAPTERADMINJOB',
			'BEGIN:p_request: '||p_request);
	END IF;

	if p_RunFreq is not null then
		l_tmpdate := 'sysdate + (' || TO_CHAR(p_RunFreq) || '/(24*60))';
	else
		l_tmpdate := null;
	end if;

	DBMS_JOB.SUBMIT(job => p_JobNumber,
		what => pv_jobAdapterAdmin || '('||to_char(p_request)||');',
		next_date => p_RunDate,
		interval =>l_tmpdate);

	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_CRON_UTIL.SUBMITADAPTERADMINJOB',
			'END:Job: '||p_JobNumber);
	END IF;

END SubmitAdapterAdminJob;


Procedure UpdateDBJob (
	p_jobID in number,
	p_request in number,
	p_ReqDate in date,
	p_Freq in number )
is
l_tmpdate varchar2(4000);
begin
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_CRON_UTIL.UPDATEDBJOB',
				'BEGIN:p_request: '||p_request);
	END IF;

	if p_Freq is not null then
		l_tmpdate := 'sysdate + (' || TO_CHAR(p_Freq) || '/(24*60))';
	else
		l_tmpdate := null;
	end if;

	DBMS_JOB.CHANGE(job => p_jobID,
		what => pv_jobAdapterAdmin || '('||to_char(p_request)||');',
		next_date => p_ReqDate,
		interval =>l_tmpdate);

end UpdateDBJob;

Procedure Execute_Adapter_Admin(p_request in number)
IS
l_dummydate date;
l_requestCode varchar2(30);
l_Freq number;
l_job_no number;
l_ChannelName varchar2(40);

l_Status varchar2(30) := XDP_ADAPTER.pv_adminStatusCompleted;

l_ErrorMsg     		VARCHAR2 (4000);
l_RetCode      		NUMBER := 0;

l_offset	NUMBER;
l_offset1	NUMBER;
l_LockTimeout	NUMBER;

l_User varchar2(40);

BEGIN
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
					'BEGIN:p_request: '||p_request);
	END IF;

	BEGIN
		XDP_ADAPTER_CORE_DB.FetchAdapterAdminReqInfo(
			p_RequestID => p_request,
			p_RequestType => l_requestCode,
			p_RequestDate => l_dummydate,
			p_RequestedBy => l_User,
			p_Freq => l_Freq,
			p_DBJobID => l_job_no,
			p_ChannelName => l_ChannelName);

		-- dbms_output.put_line('Request Type: ' || l_requestCode);
	EXCEPTION
	WHEN others then
		-- What can we do? - nothing
	-- WHEN NO_DATA_FOUND then
		-- This is really weird, request is getting executed and
		-- request is not there? Maybe, request got deleted and job is still
		-- getting executed. Donot do anything, return
		-- With the deletion of request, job for future will anyway be deleted

	IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
				'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
				'After FetchAdapterAdminReqInfo, SQLCODE: '||SQLCODE);
	END IF;
		return;
	END;

	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
			'Request Type: '||l_requestCode||
			', Job no.: '||l_job_no||
			', Channel name: '||l_ChannelName);
	END IF;

	if l_requestCode = XDP_ADAPTER.pv_opSuspend then
		-- dbms_output.put_line('suspending.. ');
		XDP_ADAPTER.Suspend_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);

	elsif l_requestCode = XDP_ADAPTER.pv_opConnect then
		-- dbms_output.put_line('Connecting.. ');
		XDP_ADAPTER.Connect_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);

	elsif l_requestCode = XDP_ADAPTER.pv_opDisconnect then
		-- dbms_output.put_line('Disconnecting.. ');
		XDP_ADAPTER.Disconnect_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);

	elsif l_requestCode = XDP_ADAPTER.pv_opResume then
		-- dbms_output.put_line('resuming.. ');
		XDP_ADAPTER.Resume_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);
	elsif (l_requestCode = XDP_ADAPTER.pv_opStop) then

		l_LockTimeout := XDP_ADAPTER_CORE_DB.GetLockTimeOut;

		if XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(
				p_ChannelName => l_ChannelName,
			   	p_Timeout => l_LockTimeout) = 'N' then

			l_RetCode := XDP_ADAPTER.pv_retAdapterCannotLock;

			-- Could get the lock after 1 HOUR, continue
			-- Following operation will also not get lock
			-- and the logic will flow.
			IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
				FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
					'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
					'Could get lock after waiting for :'||l_LockTimeout||' secs');
			END IF;
		end if;

		-- Special case, we donot want this to be cyclic
		if (l_RetCode <> XDP_ADAPTER.pv_retAdapterCannotLock) then
			-- dbms_output.put_line('Stopping.. ');
			XDP_ADAPTER.Stop_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);
                        -- Release the lock
			l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(
						p_ChannelName => l_ChannelName);
		END IF;

	elsif l_requestCode = XDP_ADAPTER.pv_opStartup then
		-- dbms_output.put_line('Starting.. ');
		XDP_ADAPTER.Start_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);

	elsif l_requestCode = XDP_ADAPTER.pv_opVerify then
		-- dbms_output.put_line('Verifying.. ');
		XDP_ADAPTER.Verify_Adapter(l_ChannelName, l_RetCode, l_ErrorMsg);

	-- elsif l_requestCode = XDP_ADAPTER.pv_opFtpFile then
	else
		-- dbms_output.put_line('Generic control operation.. ');
		-- TODO What about parameters?
		XDP_ADAPTER.Generic_Operation (
				l_ChannelName, l_requestCode, '',
				l_RetCode, l_ErrorMsg);
	end if;

	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
				'After adapter operation, Return code: '||l_RetCode);
	END IF;

	l_Status := XDP_ADAPTER.pv_adminStatusCompleted;

	if l_RetCode = XDP_ADAPTER.pv_retAdapterInvalidState or
		l_RetCode = XDP_ADAPTER.pv_retAdapterCannotLock then
		-- SKIPPED
		l_Status := XDP_ADAPTER.pv_adminStatusSkipped;
	elsif l_RetCode <> 0 then
		-- ERRORED cases are:
	        -- pv_retAdapterCtrlNotRunning
		-- pv_retAdapterAbnormalExit, will not happen for pv_opStart
                -- when other errors
		l_Status := XDP_ADAPTER.pv_adminStatusErrored;
	end if;

	if l_Freq is null then

		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
				'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
				'Frequency is null, removing job');
		END IF;
		-- dbms_output.put_line('No Freq found... updating req');

		XDP_ADAPTER.Delete_Admin_Request (
				p_request, l_RetCode, l_ErrorMsg);
		-- Donot care for l_RetCode
	end if;

	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN  -- Fix: 4256771, dbhagat, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
			'Request audited with status: '||l_Status);
	END IF;

	XDP_ADAPTER_CORE_DB.Audit_Adapter_Admin_Request (
			p_RequestID => p_request,
			p_RequestType => l_requestCode,
			p_RequestDate => l_dummydate,
			p_RequestedBy => l_User,
			p_Freq => l_Freq,
			p_RequestStatus => l_Status,
			p_RequestMessage => l_ErrorMsg,
			p_ChannelName => l_ChannelName);

        commit;

EXCEPTION
WHEN OTHERS THEN
-- Can come here only because of some SQL error in XDP_ADAPTER_CORE_DB.Audit_Adapter_Admin_Request
-- Still we need to commit;
IF( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN -- Fix: 4256771, dbhagat, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN',
		'Unhandled error, SQLCODE: '||SQLCODE);
END IF;
l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName => l_ChannelName);
commit;

END Execute_Adapter_Admin;

end XDP_CRON_UTIL;

/
