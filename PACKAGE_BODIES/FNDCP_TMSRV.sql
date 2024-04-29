--------------------------------------------------------
--  DDL for Package Body FNDCP_TMSRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FNDCP_TMSRV" as
/* $Header: AFCPTMSB.pls 120.5 2005/09/17 02:07:04 pferguso ship $ */


--
-- Private variables
--
P_CONC_QUEUE_ID   number := null;
P_REQUEST_ID      number := 0;
P_TRANSPORT_TYPE  varchar2(240) := 'QUEUE';


--
--   debug_info
-- Purpose
--   If the debug flag is set, then write to
--   the debug table.
-- Arguments
--   IN:
--    function_name - Name of the calling function
--    action_name   - Name of the current action being logged
--    message_text  - Any relevent info.
--    s_type        - Source Type ('C'- Client Send, 'M' - Manager Receive
--                                  'S' - Server Send, 'U' - Client Receive)
-- Notes
--   none.
--
procedure debug_info(function_name in varchar2,
                     action_name   in varchar2,
                     message_text  in varchar2,
                     s_type        in varchar2 default 'M') is

PRAGMA AUTONOMOUS_TRANSACTION;
begin

       insert into fnd_concurrent_debug_info
        (
          session_id, user_id, login_id,
          time, function, action, message,
          resp_appl_id, responsibility_id,
          security_group_id, transaction_id,
          concurrent_queue_id, time_in_number,
          source_type
        )
      select
          userenv('SESSIONID'), fnd_global.user_id, fnd_global.login_id,
          sysdate, function_name, action_name, substr(message_text, 1, 480),
          fnd_global.resp_appl_id, fnd_global.resp_id,
          fnd_global.security_group_id, P_REQUEST_ID, P_CONC_QUEUE_ID,
          dbms_utility.get_time, s_type
        from sys.dual;

      commit;
end;


--
-- Returns the oracle id, oracle username and the encrypted password
-- for the TM (qapid, qid) to connect.
--

procedure get_oracle_account (e_code in out nocopy number,
                  qapid  in     number,
                  qid    in     number,
                  oid    in out nocopy number,
                  ouname in out nocopy varchar2,
                  opass  in out nocopy varchar2) is

begin
  e_code := E_SUCCESS;

  select fou.oracle_id,
     fou.oracle_username,
     fou.encrypted_oracle_password
    into oid,
     ouname,
     opass
    from fnd_oracle_userid fou,
     fnd_data_group_units fdu,
     fnd_concurrent_queues fcq
   where fcq.application_id = qapid
     and fcq.concurrent_queue_id = qid
     and fcq.processor_application_id = fdu.application_id
     and fcq.data_group_id = fdu.data_group_id
     and fdu.oracle_id = fou.oracle_id;

exception
  when no_data_found then
    e_code := E_OTHER;
    fnd_message.set_name ('FND', 'CONC-Failed to get oracle name');
  when others then
    e_code := E_OTHER;
    fnd_message.set_name ('FND', 'CP-Generic oracle error');
    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
    fnd_message.set_token ('ROUTINE', 'get_oracle_account', FALSE);
end get_oracle_account;



procedure initialize (e_code in out nocopy number,
                      qid    in     number,
                      pid    in     number) is
begin


  P_CONC_QUEUE_ID := qid;
  for counter in 1..20 loop
     P_RETURN_VALS(counter) := null;
  end loop;

  FND_PROFILE.GET('CONC_TM_TRANSPORT_TYPE', P_TRANSPORT_TYPE);
  if P_TRANSPORT_TYPE is null then
     P_TRANSPORT_TYPE := 'QUEUE';
  end if;

  if P_TRANSPORT_TYPE = 'PIPE' then
     fnd_cp_tmsrv_pipe.initialize(e_code, qid, pid);
  else
     fnd_cp_tmsrv_queue.initialize(e_code, qid, pid);
  end if;

end initialize;


procedure read_message(e_code  in out nocopy number,
                   timeout in     number,
                   pktyp   in out nocopy varchar2,
                   enddate in out nocopy varchar2,
                   reqid   in out nocopy number,
                   return_id in out nocopy varchar2,
                   nlslang in out nocopy varchar2,
                   nls_num_chars in out nocopy varchar2,
                   nls_date_lang in out nocopy varchar2,
                   secgrpid in out nocopy number,
                   usrid   in out nocopy number,
                   rspapid in out nocopy number,
                   rspid   in out nocopy number,
                   logid   in out nocopy number,
                   apsname in out nocopy varchar2,
                   program in out nocopy varchar2,
                   numargs in out nocopy number,
                   org_type in out nocopy varchar2,
                   org_id  in out nocopy number,
                   arg_1   in out nocopy varchar2,
                   arg_2   in out nocopy varchar2,
                   arg_3   in out nocopy varchar2,
                   arg_4   in out nocopy varchar2,
                   arg_5   in out nocopy varchar2,
                   arg_6   in out nocopy varchar2,
                   arg_7   in out nocopy varchar2,
                   arg_8   in out nocopy varchar2,
                   arg_9   in out nocopy varchar2,
                   arg_10  in out nocopy varchar2,
                   arg_11  in out nocopy varchar2,
                   arg_12  in out nocopy varchar2,
                   arg_13  in out nocopy varchar2,
                   arg_14  in out nocopy varchar2,
                   arg_15  in out nocopy varchar2,
                   arg_16  in out nocopy varchar2,
                   arg_17  in out nocopy varchar2,
                   arg_18  in out nocopy varchar2,
                   arg_19  in out nocopy varchar2,
                   arg_20  in out nocopy varchar2) is
begin

   if P_TRANSPORT_TYPE = 'PIPE' then
      fnd_cp_tmsrv_pipe.read_message(e_code, timeout, pktyp, enddate,
                                     reqid, return_id, nlslang, nls_num_chars,
                                     nls_date_lang, secgrpid, usrid, rspapid,
                                     rspid, logid, apsname, program,
                                     numargs, org_type, org_id,
                                     arg_1, arg_2, arg_3, arg_4,
                                     arg_5, arg_6, arg_7, arg_8,
                                     arg_9, arg_10, arg_11, arg_12,
                                     arg_13, arg_14,  arg_15,  arg_16,
                                     arg_17, arg_18, arg_19, arg_20);

   else
      fnd_cp_tmsrv_queue.read_message(e_code, timeout, pktyp, enddate,
                                     reqid, return_id, nlslang, nls_num_chars,
                                     nls_date_lang, secgrpid, usrid, rspapid,
                                     rspid, logid, apsname, program,
                                     numargs, org_type, org_id,
                                     arg_1, arg_2, arg_3, arg_4,
                                     arg_5, arg_6, arg_7, arg_8,
                                     arg_9, arg_10, arg_11, arg_12,
                                     arg_13, arg_14,  arg_15,  arg_16,
                                     arg_17, arg_18, arg_19, arg_20);

   end if;

   -- Save the current transaction id
   if e_code = E_SUCCESS then
     P_REQUEST_ID := reqid;
   end if;

end read_message;



procedure write_message (e_code  in out nocopy number,
                         return_id  in     varchar2,
                         pktyp      in     varchar2,
                         reqid      in     number,
                         outcome    in     varchar2,
                         message    in     varchar2) is

begin


   if P_TRANSPORT_TYPE = 'PIPE' then
      fnd_cp_tmsrv_pipe.write_message(e_code, return_id, pktyp, reqid, outcome, message);
   else
      fnd_cp_tmsrv_queue.write_message(e_code, return_id, pktyp, reqid, outcome, message);
   end if;

end write_message;



--
-- This routine is called from a transaction program to put a return
-- to be sent back to the client.  This can be called at most, MAXVALS
-- times ane the values are stored in a table and written to the queue
-- when the TP completes.
--

procedure put_value (e_code in out nocopy number,
                     retval in     varchar2) is

begin
  e_code := E_SUCCESS;

  -- Make sure put_values is called at most MAXVALS times
  if (P_RETVALCOUNT >= MAXVALS) then
    e_code := E_MAXVALS;
    return;
  end if;

  P_RETVALCOUNT := P_RETVALCOUNT + 1;
  P_RETURN_VALS (P_RETVALCOUNT) := retval;

  if ( P_DEBUG <> DBG_OFF ) then
     debug_info('FNDCP_TMSRV.put_value',
                'Set return entry #' || to_char(P_RETVALCOUNT),
                retval, 'M');

  end if;


  return;
end put_value;



--
-- Monitor self (TM) to see if need to exit.
-- Exit if max procs is 0 or less than running, or current node is
-- different from the target when target is not null (PCP).
-- Read in sleep seconds and manager debug flag a new.
--

procedure monitor_self (e_code in out nocopy number,
            qapid  in     number,
            qid    in     number,
            cnode  in     varchar2,
            slpsec in out nocopy number,
            mgrdbg in out nocopy varchar2) is

  max_procs    number;
  run_procs    number;
  tnode        varchar2(30);    -- Target node

 begin
  e_code := E_SUCCESS;

  select max_processes,
     running_processes,
     target_node,
     sleep_seconds,
     diagnostic_level
    into max_procs,
     run_procs,
     tnode,
     slpsec,
     mgrdbg
    from fnd_concurrent_queues
   where application_id = qapid
     and concurrent_queue_id = qid;

  if ((max_procs = 0) or
      (max_procs < run_procs) or            -- Deactivate
      ((tnode is not null) and (cnode <> tnode))) then    -- Migrate
    e_code := E_EXIT;                    -- Exit
  end if;

  exception
    when others then
      e_code := E_OTHER;
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'monitor_self', FALSE);
end monitor_self;


--
-- Use this routine to stop a TM when it's running online.
--
procedure stop_tm (qid in number) is
begin
  null;
end stop_tm;


--
-- Not used.
--
procedure debug (dbg_level in number) is
begin
  P_DEBUG := dbg_level;
end;


--
-- Not used.
--
function debug return number is
begin
  return P_DEBUG;
end;




--
-- Monitor self (TM) to see if need to exit.
-- Exit if max procs is 0 or less than running, or current node is
-- different from the target when target is not null (PCP).
-- Read in sleep seconds and manager debug flag a new.
-- This version also check the process status

procedure monitor_self2 (e_code in out nocopy number,
                        qapid  in     number,
                        qid    in     number,
                        cnode  in     varchar2,
                        slpsec in out nocopy number,
                        mgrdbg in out nocopy varchar2,
                        procid in     number) is

scode varchar2(1);

begin

    monitor_self(e_code, qapid, qid, cnode, slpsec, mgrdbg);

    begin
      if (e_code = E_SUCCESS) then
        select PROCESS_STATUS_CODE
         into scode
         from fnd_concurrent_processes
         where CONCURRENT_PROCESS_ID = procid;

        if scode = 'D' then
          e_code := E_EXIT;
        end if;
      end if;

    exception when others then null;
    end;

end;


end FNDCP_TMSRV;

/
