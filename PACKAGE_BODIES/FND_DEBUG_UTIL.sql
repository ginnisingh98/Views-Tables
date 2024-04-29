--------------------------------------------------------
--  DDL for Package Body FND_DEBUG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DEBUG_UTIL" as
/* $Header: AFCPDBUB.pls 120.2.12010000.3 2016/04/27 17:54:16 ckclark ship $ */

  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PRIVATE ROUTINES
  --
  --
  -- Name
  --   get_db_version
  -- Purpose
  --   get the current database version
  --
  --   return string which will contain the db version
  --
  function get_db_version
    return varchar2 is

    dbversion varchar2(64);
  begin
    begin
      select version
        into dbversion
        from v$instance;

      exception
        when others then
           null;
    end;
    return dbversion;
  end;

  -- Name
  --   get_db_name
  -- Purpose
  --   get the current database name
  --
  --   return string which will contain the db name
  --
  function get_db_name
    return varchar2 is

    dbname varchar2(64);
  begin
    begin
      select sys_context('userenv','db_name')
        into dbname
        from dual;

      exception
        when others then
           null;
    end;
    return dbname;
  end;

  --
  -- Name
  --   construct_trace_file_name
  -- Purpose
  --   constructs the trace file name
  --   depending on the oracle service id,
  --   process id, platform and dbversion
  --   the actual trace file name being used
  --   to dump the trace
  --
  -- returns a string containing the trace file name
  --
  function construct_trace_file_name (sid       in varchar2,
                                      spid      in varchar2,
                                      platform  in varchar2,
                                      dbver     in varchar2) return varchar2 is

    fname       varchar2(256);
    upplatform  varchar2(64);
    t_ident     varchar2(80);

  begin

    select DECODE(value, NULL, NULL, '_' || value)
      into t_ident
      from v$parameter
     where name='tracefile_identifier';

    fname := sid || '_ora_' || spid || t_ident || '.trc';

    if (dbver is not null and
        substr(dbver, 1, 5) = '8.1.7'
        and platform is not null) then

      upplatform := upper(platform);
      if (instr(upplatform, 'LINUX') >= 1) then
       fname := 'ora_' || spid || t_ident || '.trc';
      elsif (instr(upplatform, 'WIN_NT') >= 1) then
       fname := 'ora0' || spid || '.trc';
      elsif (instr(upplatform, 'HP') >= 1) then
       fname := 'ora_' || spid || '_' || sid || t_ident || '.trc';
      elsif (instr(upplatform, 'AIX') >= 1) then
       fname := 'ora_' || spid || '_' || sid || t_ident || '.trc';
      else
       fname := 'ora_' || spid || t_ident || '.trc';
      end if;
    end if;

    return fname;
  end;

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   get_trace_file_name
  -- Purpose
  --   get the trace file name
  --   for the current database session
  --   including the directory path ex ($ORACLE_HOME/log/udump/ora_8085.trc)
  --
  --   return string which will contain the trace file name
  --
  function get_trace_file_name return varchar2 is

    CURSOR CURPID (aud_sid number) is
      select p.spid
        from v$session s, v$process p
        where s.audsid = aud_sid and s.paddr=p.addr;


    db_name           varchar2(64);
    path              varchar2(512);
    name              varchar2(64);
    trace_file_name   varchar2(512);
    spid              varchar2(12);
    node              varchar2(64);
    platform          varchar2(64);
    dbver             varchar2(32);
    audsid            number;
    dir_sep	          varchar2(2) := '/';

  begin

    -- get db version
    dbver := get_db_version;
    -- get db name
    db_name := get_db_name;

    begin

      EXECUTE IMMEDIATE 'select value ' ||
        'from v$diag_info ' ||
       'where name = ''Diag Trace'''
        into path;

      exception
        when others then
          select value
            into path
            from v$parameter
           where name = 'user_dump_dest';
    end;

    select userenv('SESSIONID') into audsid from dual;

    for pid_rec in CURPID(audsid) loop
      spid := pid_rec.spid;
    end loop;


    -- get platform
    select dbms_utility.port_string into platform from dual;
    -- dbms_output.put_line('Platform : ' || platform);

    trace_file_name := construct_trace_file_name(db_name, spid, platform, dbver);
    -- dbms_output.put_line('Trace File Name : ' || trace_file_name);


    if(substr(path,1,1) = '?') then
      path := '$ORACLE_HOME' || substr(path,2);
    end if;

    select DECODE(instr(upper(platform), 'WIN_NT') , 0, '/', '\')
      into dir_sep
      from dual;

    trace_file_name := path || dir_sep || trace_file_name;

    return trace_file_name;

  end;

  --
  -- Name
  --   get_trace_file_node
  -- Purpose
  --   get the node m/c name on which trace file will be generated
  --   for the current session
  --
  --   return string which will contain the node name
  --
  function get_trace_file_node return varchar2 is

    node_name     varchar2(64);

    begin

      select host_name
        into node_name
        from v$instance;

    return node_name;

      exception
         when others then
           null;
  end;

  --
  -- Name:
  --   STOP_PLSQL_PROFILER
  -- Description:
  --   This procedure will stop PLSQL profiler by calling FND_TRACE
  --   and submit concurrent request to generate profiler output.
  --   It updates the request_id in fnd_debug_rule_executions table as
  --   log_request_id.

  procedure stop_plsql_profiler is
      sql_str  varchar2(500);
      req_id   number;
  begin
      -- Stop plsql profiler by calling fnd_trace.
      -- using dynamic sql to avoid compile time dependency.
      sql_str := 'begin fnd_trace.stop_trace(fnd_trace.plsql_prof); end;';

      execute immediate sql_str;

      -- submit request for pl/sql profiler output.
      sql_str := 'begin :1 := fnd_trace.submit_profiler_report; end; ';

      execute immediate sql_str using out req_id;

      -- update fnd_debug_rule_executions table with request_id
      update fnd_debug_rule_executions
         set log_request_id = req_id
       where transaction_id = fnd_log.g_transaction_context_id
         and debug_option_name = 'PLSQL_PROFILER';

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
				   'FND_DEBUG_UTIL.STOP_PLSQL_PROFILER', FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.FND_DEBUG_UTIL.STOP_PLSQL_PROFILER.others',
                            FALSE);
            end if;

  end;

  --
  -- Name : Enable_logging
  -- Description:
  --    Enable Logging with a given log level.
  --
  procedure enable_logging( log_level IN number) is
  begin
     -- set the logging level based on current runtime level.
     -- we will allow from EXCEPTION to STATEMENT but not from
     -- STATEMENT to EXCEPTION, etc.
     if ( FND_LOG.G_CURRENT_RUNTIME_LEVEL > log_level ) then

         fnd_profile.put('AFLOG_ENABLED', 'Y');
         fnd_profile.put('AFLOG_MODULE', '%');
         fnd_profile.put('AFLOG_LEVEL', to_char(log_level));
         fnd_profile.put('AFLOG_FILENAME', '');
         fnd_log_repository.init;

     end if;

     -- ignore all exceptions
     exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
                                   'FND_DEBUG_UTIL.enable_logging', FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                          'fnd.plsql.FND_DEBUG_UTIL.ENABLE_LOGGING.others',                            FALSE);
            end if;
  end;

end FND_DEBUG_UTIL;

/
