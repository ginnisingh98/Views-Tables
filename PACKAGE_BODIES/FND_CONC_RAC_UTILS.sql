--------------------------------------------------------
--  DDL for Package Body FND_CONC_RAC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_RAC_UTILS" as
/* $Header: AFCPRACB.pls 120.2.12010000.2 2014/11/11 19:58:15 ckclark ship $ */
--
-- Package
--   FND_CONC_RAC_UTILS
-- Purpose
--   Utilities for RAC
-- History
  --
  -- PRIVATE VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Name
  --   kill_session
  -- Purpose
  --   Kills a session given a session id (sid) and serial#
  --
  -- Parameters:
  --  p_sid     - ID of session to kill.
  --  p_serial  - Instance ID of session.
  --
  --
  procedure kill_session (p_sid      in number,
                          p_serial#  in number) is
    l_sql  varchar2(75);  /* Cursor string for dbms_sql */
    l_inst    number;
    l_respid number;
    l_appid number;
    l_userid number;
    dummy number;
    l_hndl       varchar2(4000);
    l_result     number;
    l_alive      number;

  begin

   /* Call to FND_GLOBAL.APPS_INITIALIZE, so we can log messages */
   SELECT user_id
     into l_userid
     from fnd_user
    where user_name = 'CONCURRENT MANAGER';

   SELECT responsibility_id
     into l_respid
     from fnd_responsibility
    where responsibility_key = 'SYSTEM_ADMINISTRATOR';

   SELECT application_id
     into l_appid
     from fnd_application
    where application_short_name = 'SYSADMIN';

   FND_GLOBAL.APPS_INITIALIZE(l_userid,l_respid,l_appid);

    select instance_number
      into l_inst
      from v$instance;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.kill_session',
                'Session ID=' ||to_char(p_sid)||', serial#=' ||to_char(p_serial#)||', instance='||to_char(l_inst));
    end if;

    l_sql   := 'alter system kill session '''|| to_char(p_sid) || ',' ||
               to_char(p_serial#)||'''';
    begin
      execute immediate l_sql;

    exception
      when others then
        if SQLCODE = -30 then
          if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.kill_session',
                'Session ID ' ||to_char(p_sid)||', serial# '||to_char(p_serial#)||' not found:  '||' in instance '||to_char(l_inst));
          end if;
          raise;
        else
          if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.kill_session',
                'Unexpected error executing kill for session ID ' ||to_char(p_sid)||', serial# '||to_char(p_serial#)||' in instance '||to_char(l_inst));
          end if;
          raise;
      end if;
    end;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.kill_session',
                'Alter system kill session executed');
    end if;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_CONC_RAC_UTILS.KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.kill_session',
                'Oracle Error kill_session: '||SQLCODE||': '||SQLERRM);
      end if;
  end;

  --
  -- Name
  --   submit_kill_session
  -- Purpose
  --   Calls dbms_scheduler to submit a job to kill a session
  --   in a specific instance
  --   CAUTION: This procedure does a COMMIT
  --   (Now uses an autonomous_transaction)
  --
  -- Parameters:
  --  p_jobno   - Job number of the dbms_job
  --  p_message - Oracle error message, allow 4000 characters
  --  p_sid     - Session ID of session to kill
  --  p_serial# - Serial# of session to kill
  --  p_inst    - Instance ID where dbms_job should run
  --
  -- Returns:
  --     0 - Oracle error, message available
  --     1 - Could not submit job in given instance, message available
  --     2 - Success
  --
  function submit_kill_session (
                     p_jobno   in out NOCOPY number,
                     p_message in out NOCOPY varchar2,
                     p_sid     in number,
                     p_serial# in number,
                     p_inst    in number default 1) return number is

    l_inst    number := 1;
    l_retcode number := 2;

	pragma autonomous_transaction;

  begin
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Session ID ' ||to_char(p_sid)||', serial# ' ||to_char(p_serial#)||', instance '||to_char(p_inst));
    end if;

    select instance_number
      into l_inst
      from v$instance;

    begin
     if (l_inst = p_inst) then
         p_jobno := 0;
         kill_session(p_sid, p_serial#);
     else
         DBMS_JOB.SUBMIT(
            job      => p_jobno,
            what     => 'FND_CONC_RAC_UTILS.kill_session('''||to_char(p_sid)||''', '''||to_char(p_serial#)||''');',
            instance => p_inst);
     end if;

    exception
      when others then
        if SQLCODE = -23428 then
          if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Cannot submit dbms_job.  Instance '||to_char(p_inst)||' not available.');
          end if;
          l_retcode := 1;
          raise;
        else
          if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           if l_inst <> p_inst then
              fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Unexpected error submitting dbms_job to kill session ' ||to_char(p_sid)||', serial# '||to_char(p_serial#)||' in instance '||to_char(p_inst));
           else
              fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Unexpected error: '||fnd_message.get||' calling kill_session for session ' ||to_char(p_sid)||', serial# '||to_char(p_serial#)||' in instance '||to_char(p_inst));
           end if;

          end if;
          l_retcode := 0;
          raise;
      end if;
    end;

    COMMIT;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        if l_inst <> p_inst then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Job '||to_char(p_jobno)||' submitted to kill session ID ' ||to_char(p_sid)||', serial# ' ||to_char(p_serial#)||', instance '||to_char(p_inst));
        else
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Called kill_session '||'for session ID ' ||to_char(p_sid)||', serial# ' ||to_char(p_serial#)||', in current instance '||to_char(p_inst));
        end if;
    end if;

    return l_retcode;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_CONC_RAC_UTILS.SUBMIT_KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      p_message :=  fnd_message.get;
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_kill_session',
                'Exception in submit_kill_session: '||p_message);
      end if;
      return l_retcode;
  end;

  --
  -- Name
  --   submit_manager_kill_session
  -- Purpose
  --   Calls submit_kill_session given the concurrent_process_id of a manager
  --
  -- Parameters:
  --  p_cpid    - concurrent_process_id of manager to kill
  --  p_jobno   - job number of the dbms_job
  --  p_message - message buffer for error, allow 4000 characters
  --
  -- Returns:
  --     0 - Oracle error.  Check message
  --     1 - Session not found
  --     2 - Success
  --
  function submit_manager_kill_session (p_cpid in number,
                                        p_jobno in out NOCOPY number,
                                        p_message in out NOCOPY varchar2)
           return number is

    l_audsid  number;
    l_inst    number;
    l_sid     number;
    l_serial# number;
    l_retcode number := 2;

  begin

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
          'Concurrent process ' ||to_char(p_cpid));
    end if;

    begin
      select Session_Id, Instance_Number
        into l_audsid, l_inst
      from FND_CONCURRENT_PROCESSES
      where CONCURRENT_PROCESS_ID = p_cpid;

    exception
      when no_data_found then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
                'Concurrent process ' ||to_char(p_cpid)||' not found');
        end if;
        l_retcode := 1;
        raise;
      when others then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
                'Unexpected Error querying concurrent process ' ||to_char(p_cpid));
        end if;
        l_retcode := 0;
        raise;
    end;

    begin
      select sid, serial#
        into l_sid, l_serial#
        from gv$session
       where audsid = l_audsid
         and inst_id = l_inst;
    exception
      when no_data_found then
        if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_EVENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
                'Session (audsid) ' ||to_char(l_audsid)||' in instance '||to_char(l_inst)||' no longer exists for concurrent process '||to_char(p_cpid));

        end if;
        -- If the session does not exist, our work here is done...
        return 2;
      when others then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
                'Unexpected Error querying audsid '||to_char(l_audsid)||' in instance '||to_char(l_inst)||'for concurrent process '||to_char(p_cpid));
        end if;
        l_retcode := 0;
        raise;
    end;

    l_retcode := submit_kill_session(p_jobno, p_message, l_sid, l_serial#, l_inst );

    if (l_retcode <> 2) then
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_ERROR,
            'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
            'Submit_kill_session retcode: '||to_char(l_retcode)||', message: '||p_message);
      end if;
    end if;

    return l_retcode;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
                            'FND_CONC_RAC_UTILS.SUBMIT_MANAGER_KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      p_message :=  fnd_message.get;
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_manager_kill_session',
                'Exception in submit_manager_kill_session: '||p_message);
      end if;
      return l_retcode;
  end;

  --
  -- Name
  --   submit_req_mgr_kill_session
  -- Purpose
  --   Kills a manager session based on the request it is running
  --
  -- Parameters:
  --  p_reqid   - request_id for which manager session must be killed
  --  p_jobno   - job number of the dbms_job
  --  p_message - message buffer for error, allow 4000 characters
  --
  -- Returns:
  --     0 - Oracle error.  Check message
  --     1 - Request/Session not found
  --     2 - Success
  --
  function submit_req_mgr_kill_session (p_reqid in number,
                                        p_jobno in out NOCOPY number,
                                        p_message in out NOCOPY varchar2)
           return number is

    l_retcode number := 2;
    l_cpid    number := 2;

  begin

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
          'Concurrent request ' ||to_char(p_reqid));
    end if;

    begin
      select controlling_manager
        into l_cpid
      from FND_CONCURRENT_REQUESTS
      where request_id = p_reqid;

    exception
      when no_data_found then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
                'Concurrent request ' ||to_char(p_reqid)||' not found');
        end if;
        l_retcode := 1;
        raise;
      when others then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
                'Unexpected Error querying concurrent request '
||to_char(p_reqid));
        end if;
        l_retcode := 0;
        raise;
    end;

    l_retcode := submit_manager_kill_session(l_cpid, p_jobno, p_message);

    if (l_retcode = 2) then
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
            'Job '||to_char(p_jobno)||' to kill manager session of request '||to_char(p_reqid)||' submitted.');
      end if;
    else
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_ERROR,
            'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
            'Could not submit job to kill manager session of request '||to_char(p_reqid));
      end if;
    end if;

    return l_retcode;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
                            'FND_CONC_RAC_UTILS.SUBMIT_REQ_MGR_KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.message(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_mgr_kill_session',
                TRUE);
      end if;
      return l_retcode;
  end;




  --
  -- Name
  --   submit_req_kill_session
  -- Purpose
  --   Calls submit_kill_session given the request_id of a concurrent request
  --
  -- Parameters:
  --  p_reqid   - request_id for which session must be killed
  --  p_jobno   - job number of the dbms_job
  --  p_message - message buffer for error, allow 4000 characters
  --
  -- Returns:
  --     0 - Oracle error.  Check message
  --     1 - Request/Session not found
  --     2 - Success
  --
  function submit_req_kill_session (p_reqid in number,
                                    p_jobno in out NOCOPY number,
                                    p_message in out NOCOPY varchar2)
           return number is

    l_audsid  number;
    l_inst    number;
    l_sid     number;
    l_serial# number;
    l_retcode number := 2;

  begin

     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
          'Concurrent request ' ||to_char(p_reqid));
     end if;

     begin
      select oracle_session_id
        into l_audsid
      from FND_CONCURRENT_REQUESTS
      where request_id = p_reqid;

      if l_audsid is null then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                'Cannot find audsid for request ' ||to_char(p_reqid));
        end if;
        return 1;
      end if;

    exception
      when no_data_found then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                'Concurrent request ' ||to_char(p_reqid)||' not found');
        end if;
        l_retcode := 1;
        raise;
      when others then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                'Unexpected Error querying concurrent request ' ||to_char(p_reqid));
        end if;
        l_retcode := 0;
        raise;
    end;


    begin
     select inst_id, sid, serial#
       into l_inst, l_sid, l_serial#
       from gv$session
       where audsid = l_audsid;

    exception
      when no_data_found then
        if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_EVENT,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                'Session (audsid) ' ||to_char(l_audsid)|| ' no longer exists for concurrent request '||to_char(p_reqid));

		end if;
		-- If the session does not exist, our work here is done...
		return 2;

      when others then
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                'Unexpected Error querying audsid '||to_char(l_audsid)|| 'for concurrent request '||to_char(p_reqid));
        end if;
        l_retcode := 0;
        raise;
    end;



    l_retcode := submit_kill_session(p_jobno, p_message, l_sid, l_serial#, l_inst );

    if (l_retcode <> 2) then
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(FND_LOG.LEVEL_ERROR,
            'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
            'Submit_kill_session retcode: '||to_char(l_retcode)||', message: '||p_message);
      end if;
    end if;

    return l_retcode;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
                            'FND_CONC_RAC_UTILS.SUBMIT_REQ_KILL_SESSION');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.message(FND_LOG.LEVEL_ERROR,
                'fnd.plsql.FND_CONC_RAC_UTILS.submit_req_kill_session',
                TRUE);
      end if;
      return l_retcode;

  end;

end FND_CONC_RAC_UTILS;

/
