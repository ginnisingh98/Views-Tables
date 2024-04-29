--------------------------------------------------------
--  DDL for Package WF_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_SETUP" AUTHID CURRENT_USER as
/* $Header: wfevsets.pls 115.8 2002/12/12 20:32:31 dlam ship $ */

function GetLocalSystemGUID
  return raw;

procedure Check_All;

procedure Create_Queue(
  aguid  in raw
);


--
-- List_Listener
--   List the content of DBMS_JOB for a local agent
--
procedure List_Listener(
  aguid  in raw default null
);


--
-- Edit_Listener
--   Edit/Create a listener for agent provided
--   if jobnum is not null, it is editing an existing job.
--   if url is provided, return to the url specified, otherwise, to check_all.
--
procedure Edit_Listener(
  aguid  in raw,
  jobnum in pls_integer default -1,
  url    in varchar2 default null
);

procedure Edit_Propagation(
  oqueue   in varchar2,
  tosystem in varchar2,
  edit     in varchar2 default 'N',
  url      in varchar2 default null
);

--
-- SubmitListener
--   Put in the change to the DBMS_JOB for Wf_Event.Listen().
--
procedure SubmitListener(
  h_job      in varchar2,
  h_name     in varchar2,
  h_rundate  in varchar2,
  h_day      in varchar2,
  h_hour     in varchar2,
  h_minute   in varchar2,
  h_sec      in varchar2,
  h_url      in varchar2
);

--
-- SubmitPropagation
--   Put in the change to the DBMS_AQADM.Schedule_Propagation.
--
procedure SubmitPropagation(
  h_qname    in varchar2,
  h_system   in varchar2,
  h_duration in varchar2,
  h_interval in varchar2,
  h_latency  in varchar2,
  h_url      in varchar2,
  h_action   in varchar2,
  h_edit     in varchar2
);

--
-- DeleteJob
--
procedure DeleteJob(
  h_job pls_integer,
  h_url varchar2
);

--
-- DeletePropagation
--
procedure DeletePropagation(
  h_qname    in varchar2,
  h_system   in varchar2
);

--
-- JobNextRunDate (Private)
--   Return the next run date for DBMS_JOB
--
function JobNextRunDate(
  jobnum in pls_integer,
  mday   in number default 0,
  mhour  in number default 0,
  mmin   in number default 0,
  msec   in number default 0
) return date;

--
-- SubmitPropagation
--   For eBusiness Suite: Scheduling Propagation from Concurrent Manager
--
procedure SubmitPropagation(
  errbuf       out nocopy varchar2,
  retcode      out nocopy varchar2,
  h_qname    in varchar2,
  h_system   in varchar2,
  h_duration in varchar2,
  h_latency  in varchar2
);

end WF_SETUP;

 

/
