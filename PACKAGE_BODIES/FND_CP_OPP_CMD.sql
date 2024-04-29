--------------------------------------------------------
--  DDL for Package Body FND_CP_OPP_CMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_OPP_CMD" AS
/* $Header: AFCPOPCB.pls 120.2.12010000.2 2009/10/30 19:25:25 smadhapp ship $ */


ICM_ID       constant varchar2(8)  := 'FNDICM';
OPP_ID       constant varchar2(8)  := 'FNDOPP';
OPP_PACKAGE  constant varchar2(30) := 'oracle.apps.fnd.cp.opp';

-- Commands
OPP_SHUTDOWN_CMD  constant varchar2(64) := OPP_PACKAGE || '.' || 'OPPImmediateShutdownCommand';
OPP_TERMINATE_CMD constant varchar2(64) := OPP_PACKAGE || '.' || 'OPPTerminateCommand';
OPP_PING_CMD      constant varchar2(64) := OPP_PACKAGE || '.' || 'OPPPingCommand';


--------------------------------------------------------------------------------


--
-- Send an immediate shutdown request to a specific OPP process
--
procedure send_opp_shutdown_request(cpid in number) is

begin

  fnd_cp_opp_ipc.send_command(cpid, ICM_ID, OPP_SHUTDOWN_CMD, '');


end;


--
-- Requests termination of postprocessing for a specific request
--
procedure terminate_opp_request(reqid in number, senderid in number) is

pragma autonomous_transaction;

cpid                number;
complete            varchar2(1);
deadlock_detected   exception;
dummy               number;
resource_busy       exception;
pragma exception_init(resource_busy, -54);
pragma exception_init(deadlock_detected , -60);

begin

    select processor_id, completed
      into cpid, complete
	  from fnd_conc_pp_actions
	  where concurrent_request_id = reqid
	  and action_type = 6
	  and sequence = 1;

	if cpid is null then

	    -- post-processor has not started yet, update the table with our id
	    -- so the post-processor will not pick it up.

	    update fnd_conc_pp_actions
	      set processor_id = senderid
		  where concurrent_request_id = reqid;

		commit;

	    -- also update the post-processing status of the request
		-- this could possibly cause a deadlock if the manager running the request still has the lock
		begin
		select 1 into dummy from fnd_concurrent_requests where request_id = reqid for update of pp_end_date, post_request_status nowait;
	      update fnd_concurrent_requests
	        set pp_end_date = sysdate,
		    post_request_status = 'E'
		    where request_id = reqid;
		  commit;
	    exception
		  when deadlock_detected then
		    rollback;
		  when resource_busy then
		    rollback;
		end;

	else
	    if complete <> 'Y' then

	      -- post-processor is actively running it, send a terminate command

          fnd_cp_opp_ipc.send_command(cpid, senderid, OPP_TERMINATE_CMD, reqid);

		end if;

    end if;

	commit;

exception
    when no_data_found then
	  rollback;


end;

--
-- BUG 9062358 - GSI:GLOBAL ENQUEUE SERVICES DEADLOCK DETECTED
-- Requests termination of postprocessing for a specific request without autonomous_transaction
--
procedure terminate_opp_request_this_txn(reqid in number, senderid in number) is
cpid                number;
complete            varchar2(1);
begin

    select processor_id, completed
      into cpid, complete
	  from fnd_conc_pp_actions
	  where concurrent_request_id = reqid
	  and action_type = 6
	  and sequence = 1;

	if cpid is null then
	    -- post-processor has not started yet, update the table with our id
	    -- so the post-processor will not pick it up.
	    update fnd_conc_pp_actions
	      set processor_id = senderid
		  where concurrent_request_id = reqid;

	      update fnd_concurrent_requests
	        set pp_end_date = sysdate,
		    post_request_status = 'E'
		    where request_id = reqid;
	else
	    if complete <> 'Y' then
	      -- post-processor is actively running it, send a terminate command
	      fnd_cp_opp_ipc.send_command(cpid, senderid, OPP_TERMINATE_CMD, reqid);
   	    end if;
       end if;
exception
    when no_data_found then
	  null;
end;

--
-- Ping a specific OPP service process
-- Returns TRUE if process replies.
--
function ping_opp_service(cpid in number, senderid in number, timeout in number) return boolean is

flag       varchar2(1);
msgtype    number;
message    varchar2(240);
params     varchar2(2000);
sender     varchar2(30);
msggroup   varchar2(30);

begin

  fnd_cp_opp_ipc.send_command(cpid, senderid, OPP_PING_CMD, '');

  -- should not have to wait long for the reply
  fnd_cp_opp_ipc.get_message(senderid, flag, msgtype, msggroup, message, params, sender, timeout);

  if flag = 'Y' and message = 'PING' then
    return true;
  end if;

  return false;

end;


END fnd_cp_opp_cmd;

/
