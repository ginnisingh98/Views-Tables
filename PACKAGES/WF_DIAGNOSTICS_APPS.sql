--------------------------------------------------------
--  DDL for Package WF_DIAGNOSTICS_APPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIAGNOSTICS_APPS" AUTHID CURRENT_USER as
/* $Header: WFDGAPPS.pls 120.1.12010000.4 2010/04/09 08:53:58 sstomar ship $ */

--
-- Get_GSM_Setup_Info
--    Returns the basic information about GSM Setup.
-- 'S' stands for SUCCESS and 'E' stands for ERROR
function Get_GSM_Setup_Info(p_value out nocopy clob)
return varchar2;

--
-- EcxTest
--    Returns information about well being of xml gateway engine
--
procedure EcxTest(outbound_ret_code out nocopy varchar2,
                  outbound_errbuf   out nocopy varchar2,
                  outbound_xmlfile  out nocopy varchar2,
                  outbound_logfile  out nocopy varchar2,
                  inbound_ret_code  out nocopy varchar2,
                  inbound_errbuf    out nocopy varchar2,
                  inbound_logfile   out nocopy varchar2);

--
-- TRACE_UTIL
--   Enables/disables the SQL Trace at the specified level based
--   on the value of current Trace level of a component.
--   Constructs the TRACE FILE IDENTIFIER value as combination of
--   component id and time stamp.
--   Returns Trace file name, audsid and timestamp values
-- IN:
--   p_current_TraceLevel  -  Current Trace level value
--   p_comp_id              -  Component id
--
-- OUT:
--   p_trace_filename      -  The Trace file name
--   p_audsid              -  The audsid value
--   p_timestamp           -  The current timestamp
--
procedure TRACE_UTIL
          (p_current_TraceLevel in number,
	   p_comp_id in number,
	   p_trace_filename out nocopy varchar2,
	   p_audsid out nocopy integer,
	   p_timestamp out nocopy varchar2
	  );

end WF_DIAGNOSTICS_APPS;

/
