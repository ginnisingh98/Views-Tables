--------------------------------------------------------
--  DDL for Package FND_DEBUG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DEBUG_UTIL" AUTHID CURRENT_USER as
/* $Header: AFCPDBUS.pls 115.1 2004/01/27 00:30:37 vvengala ship $ */

  --
  -- PUBLIC VARIABLES
  --


  -- Exceptions

  -- Exception Pragmas

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
  function get_trace_file_name return varchar2;

  --
  -- Name
  --   get_trace_file_node
  -- Purpose
  --   get the node m/c name on which trace file will be generated
  --   for the current session
  --
  --   return string which will contain the node name
  --
  function get_trace_file_node return varchar2;

  --
  -- Name:
  --   STOP_PLSQL_PROFILER
  -- Description:
  --   This procedure will stop PLSQL profiler by calling FND_TRACE
  --   and submit concurrent request to generate profiler output.
  --   It updates the request_id in fnd_debug_rule_executions table as
  --   log_request_id.

  procedure stop_plsql_profiler;

  --
  -- Name : Enable_logging
  -- Description:
  --    Enable Logging with a given log level.
  --
  procedure enable_logging( log_level IN number);

 end FND_DEBUG_UTIL;

 

/
