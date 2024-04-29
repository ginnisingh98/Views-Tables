--------------------------------------------------------
--  DDL for Package FND_OAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM" AUTHID CURRENT_USER as
/* $Header: AFCPOAMS.pls 120.3 2005/11/16 13:17:24 ravmohan ship $ */
--
-- Package
--   FND_OAM
-- Purpose
--   Utilities for the Oracle Applications Manager
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
  --   APPS_SESSIONS
  --
  -- Purpose
  --   Returns the number of Apps logins, and the number
  --   of open forms.
  --
  -- Output Arguments
  --   logins - Current number of Apps logins.
  --   forms  - Current number of open forms.
  --
  -- Notes:
  --   Login Auditing must be set to the FORM level.
  --
  procedure APPS_SESSIONS(logins out nocopy number, forms out nocopy number);


  --
  -- Name
  --  COMPLETED_REQS
  --
  -- Purpose
  --  Returns the numbers of requests that completed with
  --  the statuses Normal, Warning, Error, and Terminated.
  --
  -- Output Arguments
  --   Normal     - Number of Completed/Normal requests.
  --   Warning    - Number of Completed/Warning requests.
  --   Error      - Number of Completed/Error requests.
  --   Terminated - Number of Completed/Terminated requests.
  --
  procedure COMPLETED_REQS (normal out nocopy number, warning out nocopy number,
                            error out nocopy number, terminated out nocopy number);


  --
  -- Name
  -- PENDING_REQS
  --
  -- Purpose
  --  Returns the numbers of requests that are pending with
  --  the statuses Normal, Scheduled, and Standby.
  --
  --  Output Arguments
  --    Normal    - Number of Pending/Normal requests.
  --    Scheduled - Number of Pending/Scheduled requests.
  --    Standby   - Number of Pending/Standby Requests.
  --
  procedure PENDING_REQS (normal out nocopy number, scheduled out nocopy number,
                          standby out nocopy number);


  --
  -- Name
  --   CONC_MGR_PROCS
  --
  -- Purpose
  --   Returns the number of running requests and total number
  --   of running concurrent manager processes.
  --
  -- Output Arguments
  --   running_reqs - Number of running requests.
  --   mgr_procs    - Number of manager processes.
  --
  procedure CONC_MGR_PROCS (running_reqs out nocopy number, mgr_procs out nocopy number);

  --
  -- Name
  --   VALIDATE_USER
  --
  -- Purpose
  --   To validate if user has access to 'System Administrator' responsibility
  --   and if access to Oracle Applications using the current username/password
  --   combination has expired.
  -- Parameters/Arguments:
  --   Input  - Application username
  --   Output - Error message indicating the reason for validation failure
  --            (upto 1800 bytes long)
  -- Returns:
  --   0 - When it fails to validate the user.
  --       Reason for failure will be in message variable.
  --   1 - When the specified User has access to System Administrator responsibility.
  --
  -- Notes:
  --
  --
  function VALIDATE_USER(username in varchar2, message in out nocopy varchar2 ) return number;


  --
  -- Name
  --   Set_Debug
  --
  -- Purpose
  --   To dynamically change the diagnostics level of individual manager or
  --   service
  -- Parameters/Arguments:
  --   Input  - Application ID, Concurrent Queue ID, Manager Type,
  --            Diagnostic Level
  -- Returns:
  --   0 - When it fails
  --       Reason for failure will be in message variable.
  --   1 - When the operation of requesting diagnostic level change succeeds
  --
  -- Notes:
  --
  --
  function Set_Debug(Application  in number,
                     QueueID      in number,
                     ManagerType  in number,
                     DiagLevel    in varchar2,
                     Message      in out nocopy varchar2) return number;


  -- Service Status Procedure
  -- Input Arguments:
  --    Service_id    - ID of the service instance.
  -- Output Arguments:
  --    target        - Total number of processes that should be
  --			    alive for this service.
  --    actual	  - Total number of processes that are actually
  --                    alive for this service instance.
  --    status        - Status of the service:
  --                    0 = Normal, 1 = Warning, 2 = Error
  --                    3 = All instanaces are inactive (Deactivated,
  --                        terminated, etc.)
  --    Description   - Describes the status.  All warnings and
  --                    errors must have a description.  The
  --                    description must not exceed 2000 characters.
  --    error_code    - Indicates if there was a runtime error in
  --                    the function.  0 = Normal, > 0 = Error.  All
  --                    exceptions must be caught by the procedure.
  --                    The "when others" clause is mandatory for
  --                    these procedures.
  --    error_message - Describes any runtime errors within the
  --                    procedure.  The error message must not
  --                    exceed 2000 characters.
  --
  procedure get_svc_status(service_id 	 in  number,
		           target     	 out nocopy number,
			   actual 	 out nocopy number,
			   status 	 out nocopy number,
                   	   description 	 out nocopy varchar2,
                   	   error_code 	 out nocopy number,
                           error_message out nocopy varchar2);





  -- Service Instance Status Procedure
  -- Input Arguments:
  --   application_id      - Application ID of the service instance
  --   concurrent_queue_id - ID of the service instance
  -- Output Arguments:
  --    target        - Number of processes that should be alive for
  --			    this service instance.
  --    actual	  - Number of processes that are actually alive
  --                    for this service instance.
  --    status        - Status of the service instance:
  --                    0 = Normal, 1 = Warning, 2 = Error,
  --                    3 = Inactive (Deactivated, Terminated, etc.)
  --    Description   - Describes the status.  All warnings and
  --                    errors must have a description.  The
  --                    description must not exceed 2000 characters.
  --    error_code    - Indicates if there was a runtime error in
  --                    the function.  0 = Normal, > 0 = Error.  All
  --                    exceptions must be caught by the procedure.
  --                    The "when others" clause is mandatory for
  --                    these procedures.
  --    error_message - Describes any runtime errors within the
  --                    procedure.  The error message must not
  --                    exceed 2000 characters.
  --
  procedure get_svc_inst_status(appl_id 	   in  number,
                    	       conc_queue_id       in  number,
	                       target 		   out nocopy number,
			       actual  	 	   out nocopy number,
			       status 		   out nocopy number,
                     	       description 	   out nocopy varchar2,
                   	       error_code 	   out nocopy number,
                   	       error_message  	   out nocopy varchar2);


  -- Node Status Procedure
  -- Input Arguments:
  -- node_name - Name of the node
  -- Output Arguments:
  --    status        - Status of the node:
  --                    0 = Normal, 1 = Warning, 2 = Error
  --                    3 = All instanaces are inactive (Deactivated,
  --                        terminated, etc.)
  --    Description   - Describes the status.  All warnings and
  --                    errors must have a description.  The
  --                    description must not exceed 2000 characters.
  --    error_code    - Indicates if there was a runtime error in
  --                    the function.  0 = Normal, > 0 = Error.  All
  --                    exceptions must be caught by the procedure.
  --                    The "when others" clause is mandatory for
  --                    these procedures.
  --    error_message - Describes any runtime errors within the
  --                    procedure.  The error message must not
  --                    exceed 2000 characters.
  --
  procedure get_node_status(node_name 	 in  varchar2,
			   status   	 out nocopy number,
                     	   description 	 out nocopy varchar2,
                   	   error_code 	 out nocopy number,
                           error_message out nocopy varchar2);

 -- Request Procedure
  --
  -- Purpose
  --   Returns a translated status, phase and schedule description
  -- Input Arguments:
  -- pcode - Phase Code
  -- scode - Status Code
  -- hold  - hold code
  -- enabld - enabled Code
  -- stdate - Start date
  -- rid - request id
  --
  procedure get_req_status_phase_schDesc(
		      pcode  in char,
	              scode  in char,
		      hold   in char,
	              enbld  in char,
	              stdate in date,
		      rid    in number,
                      status out nocopy varchar2,
	 	      phase  out nocopy varchar2,
	 	      schDesc  out nocopy varchar2);

end FND_OAM;

 

/

  GRANT EXECUTE ON "APPS"."FND_OAM" TO "EM_OAM_MONITOR_ROLE";
