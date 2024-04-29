--------------------------------------------------------
--  DDL for Package Body FND_AMP_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AMP_PRIVATE" as
/* $Header: AFCPAMPB.pls 120.5.12010000.5 2018/05/04 20:09:17 ckclark ship $ */

--
-- Package
--   FND_AMP_PRIVATE
-- Purpose
--   Utilities for the Applications Management Pack
-- History
  --
  -- PRIVATE VARIABLES
  --

  req_phase  varchar2(80);
  req_status varchar2(80);
  ran_get_phase  number := -1;
  ran_get_status number := -1;

  -- Exceptions

  -- Exception Pragmas

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Function
  --   process_alive
  -- Purpose
  --   Return TRUE if the process is alive,
  --   FALSE otherwise.
  -- Arguments
  --   pid - process ID
  -- Notes
  --   Return FALSE on error.
  --
  --
  function process_alive(pid in number) return boolean is

     alive       boolean;

  begin

      alive := FND_CONC.process_alive(pid);
      return alive;

  end process_alive;


-- This routine handles the cases of restarting the parent
-- request (if necessary) of cancelled child requests, and
-- canceling child jobs.
-- Used in cancel_request routine.
-- This is a local routine
procedure cancel_subrequests( request_id        in number,
                              parent_request_id in number,
                              is_sub_request    in varchar2,
                              has_sub_request   in varchar2
                            ) is
begin
    -- When a request is deleted, restart parent (if this
    -- is the last subrequest) and terminate subrequests
    -- (if this is a parent)
    if (is_sub_request = 'Y') then
      -- Lock the parent so that no other process can
      -- perform the same actions to follow (including CM).
      -- If parent status is W (Paused), no need to update.
      if (fnd_conc_request_pkg.lock_parent (parent_request_id)) then
        -- If request to delete is the last pending child,
        -- set paused parent request to pending for restart
        -- Need to maintain the parent-child order of
        -- request locking, so update parent first before
        -- deleting child jobs.
        -- Status codes between 'I' and 'T' are pending or
        -- running.  They include 'I' Pending Normal,
        -- 'Q' Pending Standby, 'R' Running Normal, and
        -- 'T' Running Terminating.
        if (fnd_conc_request_pkg.restart_parent (
                        request_id,
                        parent_request_id,
                        fnd_global.user_id)) then
          fnd_message.set_name (
                        'FND',
                        'CONC-Restart parent request');
        end if;
      end if;
    end if;

    if (has_sub_request = 'Y') then
      -- Update status of children to terminating,
      -- terminated or cancelled unless they are already
      -- complete or terminating.
      fnd_conc_request_pkg.delete_children (
                        request_id,
                        fnd_global.user_id);
    end if;
end cancel_subrequests;


  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   why_wait
  -- Purpose
  --   Returns a translated string describing the reaons why request1
  --   is waiting on request2.  If request1 is not waiting on request2,
  --   then null is returned.
  --
  --   Request2 must be a pending or running program queued ahead of
  --   request1, in the same conflict domain, with a queue_method_code of
  --   'B'.  No checks are made on these constraints,
  --   since this procedure is part of a data gatherer select
  --   statement that must run fast.
  --
  --
  function why_wait (request_id1           in number,
                     single_thread_flag1   in varchar2,
                     request_limit1        in varchar2,
                     requested_by1         in number,
                     program_appl1         in number,
                     program_id1           in number,
                     status_code1          in varchar2,
                     request_id2           in number,
                     single_thread_flag2   in varchar2,
                     request_limit2        in varchar2,
                     requested_by2         in number,
                     run_alone_flag2       in varchar2,
                     program_appl2         in number,
                     program_id2           in number,
                     is_sub_request2       in varchar2,
                     parent_request2       in number) return varchar2 is
    c number;
  begin

    /* Is request 2 a run alone program? */
    if (run_alone_flag2 = 'Y') then
      fnd_message.set_name('FND', 'CONC-RUN ALONE AHEAD');
      return fnd_message.get;
    end if;

    /* Are they single threaded? */
    if (single_thread_flag1 = 'Y' and single_thread_flag2 = 'Y' and
        requested_by1 = requested_by2) then
      fnd_message.set_name('FND', 'CONC-SINGLE THREAD AHEAD');
      fnd_message.set_token('REQUEST_ID', request_id1);
      return fnd_message.get;
    end if;

    /* Are they incompatible? */
    select count(*) into c
      from fnd_concurrent_program_serial
     where running_application_id = program_appl2
       and running_concurrent_program_id = program_id2
       and to_run_application_id = program_appl1
       and to_run_concurrent_program_id = program_id1;

    if (c > 0) then
      fnd_message.set_name('FND', 'CONC-INCOMPATIBLE AHEAD');
      fnd_message.set_token('REQUEST_ID', request_id1);
      return fnd_message.get;
    end if;

    /* Is this the wating request1 the parent of request2? */
    if (status_code1 = 'W' and is_sub_request2 = 'Y'
        and parent_request2 = request_id1) then
      fnd_message.set_name('FND', 'CONC-SUB-REQUEST');
      fnd_message.set_token('REQUEST_ID', request_id1);
      return fnd_message.get;
    end if;


    /* Finally check user limit */
    if (request_limit1 = 'Y' and request_limit2 = 'Y' and
        requested_by1 = requested_by2) then
      fnd_message.set_name('FND', 'CONC-LIMITED REQUESTS');
      return fnd_message.get;
    end if;

    return NULL;
  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_AMP_PRIVATE.WHY_WAIT');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      return fnd_message.get;
  end why_wait;


  --
  -- Name
  --   get_phase_and_status
  -- Purpose
  --   Used by get_phase and get_status to get the
  --   phase and status descriptions.
  --
  procedure get_phase_and_status(pcode  in char,
 	                         scode  in char,
		                 hold   in char,
	                         enbld  in char,
	                         stdate in date,
		                 rid    in number) is

  begin

    fnd_conc_request_pkg.get_phase_status(pcode, scode, hold, enbld,
			                  null, stdate, rid,
					  req_phase, req_status);

  end get_phase_and_status;



  --
  -- Name
  --   get_status
  -- Purpose
  --   Returns a translated status description.
  --
  function get_phase (pcode  in char,
 	              scode  in char,
		      hold   in char,
	              enbld  in char,
	              stdate in date,
	              rid    in number) return varchar2 is
  begin

    /* Did we already run get_status for this request?
     * If so, then return the cached phase value.
     */
    if (ran_get_status = rid) then
      ran_get_status := -1;
      return req_phase;
    end if;

    /* Get phase and status.  Return phase. */
    get_phase_and_status(pcode, scode, hold, enbld, stdate, rid);
    ran_get_phase := rid;
    return req_phase;

  exception
    when others then
      return 'ORA'||SQLCODE;
  end;



  --
  -- Name
  --   get_status
  -- Purpose
  --   Returns a translated status description.
  --
  function get_status (pcode  in char,
	               scode  in char,
		       hold   in char,
	               enbld  in char,
	               stdate in date,
	               rid    in number) return varchar2 is
  begin
    /* Did we already run get_phase for this request?
     * If so, then return the cached status value.
     */
    if (ran_get_phase = rid) then
      ran_get_phase := -1;
      return req_status;
    end if;

    /* Get phase and status.  Return status. */
    get_phase_and_status(pcode, scode, hold, enbld, stdate, rid);
    ran_get_status := rid;
    return req_status;

  exception
    when others then
      return 'ORA'||SQLCODE;
  end;



  --
  -- Name
  --   kill_session
  -- Purpose
  --   Kills a session given an audsid and instance id
  --
  -- Parameters:
  --   audsid - ID of session to kill.
  --  message - Oracle error message.
  --  inst_id - Instance ID of session.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Session not found.
  --     2 - Success.
  --
  function kill_session (audsid  in number,
                         message in out NOCOPY varchar2,
                         inst_id in number default 1) return number is
    kcursor  varchar2(75);  /* Cursor string for dbms_sql */
    cid      number;        /* Cursor ID for dbms_sql */
    ssid     number;
    sserial# number;
    dummy    number;
  begin
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.kill_session',
                'audsid: ' ||audsid||', inst_id=' ||inst_id);
    end if;

    begin
      select sid, serial#
        into ssid, sserial#
        from gv$session
       where kill_session.audsid = gv$session.audsid
         and kill_session.inst_id = gv$session.inst_id;
    exception
      when no_data_found then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_AMP_PRIVATE.kill_session',
                'Session (audsid) ' ||audsid||' in instance '||inst_id||' not found');
        end if;
        return 1;
      when others then
        raise;
    end;

    kcursor := 'alter system kill session '''|| to_char(ssid) || ',' ||
               to_char(sserial#)||'''';
    begin
      cid := dbms_sql.open_cursor;
      dbms_sql.parse(cid, kcursor, dbms_sql.v7);
      dummy := dbms_sql.execute(cid);
      dbms_sql.close_cursor(cid);
    exception
      when others then
        if SQLCODE = -30 then
          return 1;
        else
          raise;
      end if;
    end;

    return 2;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_AMP_PRIVATE.KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      return 0;
  end;


  --
  -- Name
  --   cancel_request
  -- Purpose
  --   Cancel or terminate a request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  -- Parameters:
  --       req_id - ID of request to cancel.
  --      message - Error message.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Could not lock request row
  --     2 - Request has already completed.
  --     3 - Cannot cancel.  Manager dead.
  --     4 - Request cancelled.
  --     5 - Request marked for termination.
  --
  function cancel_request (  req_id in number,
                            message in out NOCOPY varchar2) return number is
    PRAGMA AUTONOMOUS_TRANSACTION;
    req_phase     varchar2(1);
    req_status    varchar2(1);
    new_status    varchar2(1);
    is_sub_req    varchar2(1);
    has_sub_req   varchar2(1);
    mgr_proc      number;
    current_user  VARCHAR2(100);
    who_cancelled varchar2(255);
    par_req_id    number;

  begin

    begin
      select phase_code, status_code,
             is_sub_request, has_sub_request,
             controlling_manager, parent_request_id
        into req_phase, req_status,
             is_sub_req, has_sub_req,
             mgr_proc, par_req_id
        from fnd_concurrent_requests
       where request_id = req_id
         for update of phase_code nowait;
    exception
      when others then
        if (SQLCODE = -54) then
          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                'Could not lock FND_CONCURRENT_REQUEST row for request '||req_id||', return 1');
          end if;
          return 1;
        else
          raise;
        end if;
    end;
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                'Request '||req_id||' has current phase_code=' ||req_phase||', status_code=' ||req_status);
    end if;

    if (req_phase = 'R') then
      if (req_status = 'T') then
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                   'Request '||req_id||' already marked for termination, return 5');
         end if;
         rollback;
         return 5;
      end if;
      if (not process_alive(mgr_proc)) then
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                   'Manager process '||to_char(mgr_proc)||' for request '||req_id||' is dead, return 3');
         end if;
         rollback;
         return 3;
      end if;
    end if;

    if (req_phase = 'C') then
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                'Request '||req_id||' is already complete, return 2');
      end if;
      rollback;
      return 2;
    end if;

    if (req_status = 'R') then
      new_status := 'T';
    elsif (req_status in ('W', 'B')) then
      new_status := 'X';
    else
      new_status := 'D';
    end if;
    -- Who cancelled the request
    current_user := FND_PROFILE.VALUE('USERNAME');
    fnd_message.set_name ('FND', 'CONC-Cancelled by');
    fnd_message.set_token ('USER', current_user);
    who_cancelled := fnd_message.get;

    update fnd_concurrent_requests
       set phase_code = decode(new_status, 'T', phase_code, 'C'),
           status_code = new_status,
           completion_text = who_cancelled,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id
     where request_id = req_id;

    cancel_subrequests(req_id, par_req_id, is_sub_req, has_sub_req);

    commit;

    if (new_status = 'T') then
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                'Request '||req_id||' marked for termination with status_code='||new_status||', return 5');
      end if;
      return 5;
    else
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_AMP_PRIVATE.cancel_request',
                'Request '||req_id||' cancelled with status_code='||new_status||', return 4');
      end if;
      return 4;
    end if;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_AMP_PRIVATE.TERMINATE_REQUEST');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      rollback;
      return 0;
  end;


  --
  -- Name
  --   toggle_hold
  -- Purpose
  --   Toggles the hold flag for a concurrent request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  -- Parameters:
  --       req_id - ID of request to toggle.
  --      message - Error message.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Could not lock request row
  --     2 - Request has already started.
  --     3 - Request placed on hold.
  --     4 - Request hold removed.
  --
  function toggle_request_hold ( req_id in number,
                                message in out NOCOPY varchar2) return number is
    req_phase     varchar2(1);
    req_hold      varchar2(1);
    req_type      varchar2(1);
    new_hold      varchar2(1);
    retval        number;
    new_start_date date := null;
  begin
    savepoint fnd_amp_private_hold_req;

    begin
      select phase_code, hold_flag, request_type
        into req_phase, req_hold, req_type
        from fnd_concurrent_requests
       where request_id = req_id
         for update of phase_code nowait;
    exception
      when others then
        if (SQLCODE = -54) then
          return 1;
        else
          raise;
        end if;
    end;

    if (req_phase <> 'P' ) then
    	-- to fix bug # 4761862
    	-- Request Sets in Running phase can be hold.
    	if ( req_type <> 'M' or req_phase <> 'R') then
	      rollback to fnd_amp_private_hold_req;
	      return 2;
	end if;
    end if;

    if (req_hold = 'Y') then
      new_hold := 'N';
      -- bug# 25240958
      -- call new function fnd_conc_private_utils.adjust_start_date
      -- if request is scheduled on Specific Days and the start date
      -- is in the past, it needs to be adjusted to be future.
      new_start_date := to_date(
                        fnd_conc_private_utils.adjust_start_date(req_id),
                        'DD-MON-YYYY HH24:MI:SS') ;
      retval := 4;
    else
      new_hold := 'Y';
      retval := 3;
   end if;


    update fnd_concurrent_requests
       set hold_flag = new_hold,
           requested_start_date =
              nvl(new_start_date, requested_start_date),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id
     where request_id = req_id;

    commit;

    return retval;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_AMP_PRIVATE.TOGGLE_REQUEST_HOLD');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      rollback to fnd_amp_private_hold_req;
      return 0;
  end;


  --
  -- Name
  --   alter_priority
  -- Purpose
  --   Alters the priority for a concurrent request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  -- Parameters:
  --       req_id - ID of request to toggle.
  --     priority - New priority.
  --      message - Error message.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Could not lock request row
  --     2 - Request has already started.
  --     3 - Request priority altered.
  --
  function alter_request_priority (  req_id in number,
                               new_priority in number,
                                    message in out NOCOPY varchar2) return number is
    req_phase     varchar2(1);

  begin
    savepoint fnd_amp_private_alter_priority;

    begin
      select phase_code
        into req_phase
        from fnd_concurrent_requests
       where request_id = req_id
         for update of phase_code nowait;
    exception
      when others then
        if (SQLCODE = -54) then
          return 1;
        else
          raise;
        end if;
    end;

    if (req_phase <> 'P') then
      rollback to fnd_amp_private_alter_priority;
      return 2;
    end if;


    update fnd_concurrent_requests
       set priority = new_priority,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id
     where request_id = req_id;

    commit;

    return 3;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_AMP_PRIVATE.ALTER_REQUEST_PRIORITY');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      rollback to fnd_amp_private_alter_priority;
      return 0;
  end;

end FND_AMP_PRIVATE;

/
