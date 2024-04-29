--------------------------------------------------------
--  DDL for Package FND_AMP_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AMP_PRIVATE" AUTHID CURRENT_USER as
/* $Header: AFCPAMPS.pls 120.2.12000000.2 2007/10/05 19:51:53 ckclark ship $ */

--
-- Package
--   FND_AMP_PRIVATE
-- Purpose
--   Utilities for the Applications Management Pack
-- History
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
                     parent_request2       in number) return varchar2;

 pragma restrict_references (why_wait, WNDS);


  --
  -- Name
  --   get_phase
  -- Purpose
  --   Returns a translated phase description.
  --
  function get_phase (pcode  in char,
	              scode  in char,
		      hold   in char,
	              enbld  in char,
	              stdate in date,
		      rid    in number) return varchar2;

  pragma restrict_references (get_phase, WNDS);

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
		       rid    in number) return varchar2;

  pragma restrict_references (get_status, WNDS);


  --
  -- Name
  --   kill_session
  -- Purpose
  --   Kills a session given an audsid.
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
                         inst_id in number default 1) return number;


  --
  -- Name
  --   cancel_request
  -- Purpose
  --   Cancel or terminate a request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  --   WARNING: A commit will be issued on success.
  --
  -- Parameters:
  --       req_id - ID of request to cancel.
  --      message - Error message.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Could not lock request row
  --     2 - Request has already completed.
  --     3 - Request cancelled.
  --     4 - Request marked for termination.
  --
  function cancel_request ( req_id in number,
                           message in out NOCOPY varchar2) return number;


  --
  -- Name
  --   toggle_hold
  -- Purpose
  --   Toggles the hold flag for a concurrent request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  --   WARNING: A commit will be issued on success.
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
                                message in out NOCOPY varchar2) return number;


  --
  -- Name
  --   alter_priority
  -- Purpose
  --   Alters the priority for a concurrent request.
  --   Make sure fnd_global.apps_initialize was called first.
  --
  --   WARNING: A commit will be issued on success.
  --
  -- Parameters:
  --       req_id - ID of request to toggle.
  -- new_priority - New priority.
  --      message - Error message.
  --
  -- Returns:
  --     0 - Oracle error.  Check message.
  --     1 - Could not lock request row
  --     2 - Request has already started.
  --     3 - Request priority altered.
  --
  function alter_request_priority ( req_id in number,
                              new_priority in number,
                                   message in out NOCOPY varchar2) return number;





 end FND_AMP_PRIVATE;

 

/
