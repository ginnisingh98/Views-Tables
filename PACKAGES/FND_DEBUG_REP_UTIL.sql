--------------------------------------------------------
--  DDL for Package FND_DEBUG_REP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DEBUG_REP_UTIL" AUTHID CURRENT_USER as
/* $Header: AFCPRTUS.pls 115.0 2004/01/27 00:23:46 vvengala ship $ */

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
  --   generate trace file name for use in os level.
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
  -- Name
  --  get_program_comp
  -- Description
  --  returns Concurrent Program component name for a given Execution Method
  --  code.

  function get_program_comp(emethod  varchar2) return varchar2;

 end FND_DEBUG_REP_UTIL;

 

/
