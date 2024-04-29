--------------------------------------------------------
--  DDL for Package FND_CONC_RAC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_RAC_UTILS" AUTHID CURRENT_USER as
/* $Header: AFCPRACS.pls 120.2.12010000.2 2014/11/12 17:12:08 ckclark ship $ */

--
-- Package
--   FND_CONC_RAC_UTILS
-- Purpose
--   Utilities for RAC
-- History

  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --
  -- Name
  --   kill_session
  -- Purpose
  --   Called by DBMS_JOB
  --   Kills a session given a session id (sid) and serial#
  --
  -- Parameters:
  --  p_sid     - ID of session to kill.
  --  p_serial  - Instance ID of session.
  --
  --
  procedure kill_session (p_sid      in number,
                          p_serial#  in number) ;

  --
  -- Name
  --   submit_kill_session
  -- Purpose
  --   Calls dbms_scheduler to submit a job to kill a session
  --   in a specific instance
  --   CAUTION: This procedure does a COMMIT
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
                     p_inst    in number default 1) return number;

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
           return number;

  --
  -- Name
  --   submit_req_mgr_kill_session
  -- Purpose
  --   Calls submit_kill_session given the request_id of a concurrent request
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
           return number;



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
           return number;

 end FND_CONC_RAC_UTILS;

/
