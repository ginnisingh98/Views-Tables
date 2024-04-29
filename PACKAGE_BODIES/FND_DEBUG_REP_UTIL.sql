--------------------------------------------------------
--  DDL for Package Body FND_DEBUG_REP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DEBUG_REP_UTIL" as
/* $Header: AFCPRTUB.pls 120.3.12010000.2 2014/02/12 20:33:06 tkamiya ship $ */

  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PRIVATE ROUTINES
  --
  --

  --
  -- PUBLIC FUNCTIONS
  --
 --
  -- Name
  --   get_trace_file_name
  -- Purpose
  --   get the trace file name
  --   generate trace file name for use in os level.
  --
  --   return string which will contain the trace file name
  --
  function get_trace_file_name return varchar2 is
     trc_file      varchar2(500);
     trc_file_node varchar2(100);
     trc_file_name varchar2(30);
     trc_file_dir  varchar2(250);
     path_sep      varchar2(1);
     default_path  varchar2(16) := '/var/tmp';
  begin

     trc_file := '';

     select 'dbg' || fnd_debug_rule_executions_s.nextval || '.log'
       into trc_file_name
       from dual;

     trc_file_node := fnd_debug_rep_util.get_trace_file_node;

     trc_file_dir := fnd_context_util.get_tag_value(trc_file_node, 'APPLTMP');
     path_sep := fnd_context_util.get_tag_value(trc_file_node, 'pathsep');

     if ( path_sep is null ) then
        path_sep := '/';
     end if;
 --
 -- if location is not specified, just write it to a default location
 -- so it does not error out
 --
     if (trc_file_dir is null ) then
        trc_file := default_path || path_sep || trc_file_name;
     else
        trc_file := trc_file_dir || path_sep || trc_file_name;
     end if;

     return trc_file;

     exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
				   'FND_DEBUG_REP_UTIL.GET_TRACE_FILE_NAME',
				   FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG_REP_UTIL.GET_TRACE_FILE_NAME.others',
                            FALSE);
            end if;
            return trc_file;

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

      select rtrim(substr(machine, instr(machine,'\')+1),
			FND_GLOBAL.local_chr(0))
        into node_name
        from gv$session
       where audsid = userenv('SESSIONID');

      return node_name;

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
                                   'FND_DEBUG_REP_UTIL.GET_TRACE_FILE_NODE',
                                   FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG_REP_UTIL.GET_TRACE_FILE_NODE.others',
                            FALSE);
            end if;
            return null;
  end;

  --
  -- Name
  --  get_program_comp
  -- Description
  --  returns Concurrent Program component name for a given Execution Method
  --  code.

  function get_program_comp(emethod  varchar2) return varchar2 is
    dbg_comp varchar2(30) := 'NOT_SUPPORTED';
  begin

    select DECODE(emethod, 'P', 'REPORTS',
                                'I', 'PLSQL_CP',
                                'J', 'JAVA_STORED_CP',
                                'K', 'JAVA_CP',
                                'Q', 'SQLPLUS_CP',
                                'E', 'PERL_CP',
                                'S', 'SUBROUTINE_CP',
                                'A', 'SPAWNED_CP',
                                'H', 'HOST_CP',
                                'L', 'LOADER_CP',
                                'NOT_SUPPORTED')
       into dbg_comp
       from dual;

    return dbg_comp;

      exception
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token ('ROUTINE',
                                   'FND_DEBUG_REP_UTIL.GET_PROGRAM_COMP',
                                   FALSE);
            if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                            'fnd.plsql.FND_DEBUG_REP_UTIL.PROGRAM_COMP.others',
                            FALSE);
            end if;
            return 'NOT_SUPPORTED';
  end;

end FND_DEBUG_REP_UTIL;

/
