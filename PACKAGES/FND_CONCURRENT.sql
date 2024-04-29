--------------------------------------------------------
--  DDL for Package FND_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONCURRENT" AUTHID CURRENT_USER as
/* $Header: AFCPUTLS.pls 120.4.12010000.3 2018/02/16 22:22:49 ckclark ship $ */
/*#
 * Utility APIs for concurrent processing.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Request Set
 * @rep:lifecycle active
 * @rep:compatibility S
 */
--
-- Package
--   FND_CONCURRENT
-- Purpose
--   Concurrent processing related utilities
-- History
--   XX/XX/93	Ram Bhoopalam	Created
--
  --
  -- PUBLIC VARIABLES
  --

  TYPE Print_Options_Rec_Typ IS RECORD
  (    number_of_copies    number        := null
  ,    print_style         varchar2(30)  := null
  ,    printer             varchar2(30)  := null
  ,    save_output_flag    varchar2(1)   := null
  );

  TYPE Print_Options_Tbl_Typ IS TABLE OF Print_Options_Rec_Typ
       INDEX BY BINARY_INTEGER;

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   GET_REQUEST_STATUS
  -- Purpose
  --   returns the status of concurrent request and completion message
  --   if the request has completed. Returns both user ( translatable )
  --   and developer ( could you be used to compare/check and base their
  --   program logic ) version for phase and status values.
  -- Arguments ( input )
  --   request_id	- Request id for which status has to be checked
  --                    - If Application and prorgram information is passed,
  --			- most recent request id for this program is returned
  --			- along with the status and phase.
  --   appl_shortname   - Application to which the program belongs
  --   program          - Program name  ( appl and program information used
  --			- only if request id is not provided )
  -- Arguments ( output )
  --   phase 		- Request phase ( from meaning in fnd_lookups )
  --   status		- Request status( for display purposes	      )
  --   dev_phase	- Request phase as a constant string so that it
  --			- can be used for comparisons )
  --   dev_status	- Request status as a constatnt string
  --   message		- Completion message if request has completed
  --
/*#
 * Returns the Status of a concurrent request. Also returns the completion text if the request is already completed.
 * @param request_id Request ID of the program to be checked
 * @param appl_shortname Short name of the application associated with the program
 * @param program Short name of the concurrent program
 * @param phase Request phase
 * @param status Request status
 * @param dev_phase Request phase as a string constant
 * @param dev_status Request status as a string constant
 * @param message Request completion message
 * @return Returns TRUE on succesful retrieval of the information, FALSE otherwise
 * @rep:displayname Get Request Status
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function get_request_status(request_id     IN OUT NOCOPY number,
		              appl_shortname IN varchar2 default NULL,
		              program        IN varchar2 default NULL,
		              phase      OUT NOCOPY varchar2,
		              status     OUT NOCOPY varchar2,
		              dev_phase  OUT NOCOPY varchar2,
		              dev_status OUT NOCOPY varchar2,
		              message    OUT NOCOPY varchar2) return boolean;
  pragma restrict_references (get_request_status, WNDS);

  --
  -- Name
  --   WAIT_FOR_REQUEST
  -- Purpose
  --   Waits for the request completion, returns phase/status and
  --   completion text to the caller. Calls sleep between db checks.
  -- Arguments (input)
  --   request_id	- Request ID to wait on
  --   interval         - time b/w checks. Number of seconds to sleep
  --			- (default 60 seconds)
  --   max_wait		- Max amount of time to wait (in seconds)
  --			- for request's completion
  -- Arguments (output)
  --   			User version of      phase and status
  --   			Developer version of phase and status
  --   			Completion text if any
  --   phase 		- Request phase ( from meaning in fnd_lookups )
  --   status		- Request status( for display purposes	      )
  --   dev_phase	- Request phase as a constant string so that it
  --			- can be used for comparisons )
  --   dev_status	- Request status as a constatnt string
  --   message		- Completion message if request has completed
  --
  --
/*#
 * Waits for the request completion, then returns the request phase/status and
 * completion message to the caller. Goes to sleep between checks for the
 * request completion.
 * @param request_id Request ID of the request to wait on
 * @param interval Number of seconds to wait between checks
 * @param max_wait Maximum number of seconds to wait for the request completion
 * @param phase User-friendly Request phase
 * @param status User-friendly Request status
 * @param dev_phase Request phase as a constant string
 * @param dev_status Request status as a constant string
 * @param message Request completion message
 * @return Returns TRUE on succesful retrieval of the information, FALSE otherwise
 * @rep:displayname Wait for Request
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
  function wait_for_request(request_id IN number default NULL,
		  interval   IN  number default 60,
		  max_wait   IN  number default 0,
		  phase      OUT NOCOPY varchar2,
		  status     OUT NOCOPY varchar2,
		  dev_phase  OUT NOCOPY varchar2,
		  dev_status OUT NOCOPY varchar2,
		  message    OUT NOCOPY varchar2) return  boolean;

  --
  -- Name
  --   FND_CONCURRENT.GET_MANAGER_STATUS
  -- Purpose
  --   Returns the target ( number that should be active at this instant )
  --   and active number of processes for a given manager.
  --   along with the current PMON method currently in use
  -- Arguments (input)
  --   applid		- Application ID of application under which the
  --			- manager is registered
  --   managerid	- Concurrent manager ID ( queue id )
  --           (output)
  --   target		- Number of manager processes that should be active
  --			- for the current workshift in effect
  --   active           - actual number of processes that are active
  --   pmon_method	- RDBMS/OS
  --   message		- message if any
  --

  procedure get_manager_status (applid      IN  number default 0,
			       managerid   IN  number default 1,
			       targetp	   OUT NOCOPY number,
			       activep     OUT NOCOPY number,
			       pmon_method OUT NOCOPY varchar2,
			       callstat    OUT NOCOPY number);

  --
  -- Name
  --   FND_CONCURRENT.SET_COMPLETION_STATUS
  -- Purpose
  --   Called from a concurrent request to set its completion
  --   status and message.
  --
  -- Arguments (input)
  --   status		- 'NORMAL', 'WARNING', or 'ERROR'
  --   message		- Optional message
  --
  -- Returns:
  --   TRUE on success.  FALSE on error.
  --

  function set_completion_status (status  IN  varchar2,
			          message IN  varchar2) return boolean;

  --
  -- Name
  --   Get_Request_Print_Options
  -- Purpose
  --   Returns the print options for a concurrent request.
  --
  function GET_REQUEST_PRINT_OPTIONS
               (request_id        IN number,
                number_of_copies OUT NOCOPY number,
                print_style      OUT NOCOPY varchar2,
                printer          OUT NOCOPY varchar2,
                save_output_flag OUT NOCOPY varchar2) return boolean;

  pragma restrict_references (get_request_print_options, WNDS);

  --
  -- Name
  --   Get_Request_Print_Options
  -- Purpose
  --   Returns the print options for a concurrent request.
  -- Parameters
  --   request_id: The request_id for the concurrent request
  --   print_options: pl/sql table of print_options_tbl_typ
  --                  (see spec for details)
  -- Returns
  --   The total number post-processing actions for printing
  --
  function GET_REQUEST_PRINT_OPTIONS
               (request_id        IN  number,
                print_options     OUT NOCOPY print_options_tbl_typ) return number;

  --
  -- Name
  --   Check_Lock_Contention
  -- Purpose
  --   Identifies the process that is holding the lock(s) on resources
  --   that are needed by the process identified by the Queue Name or
  --   Session ID parameter.
  -- Arguments (input)
  --   Queue_Name	- Concurrent Manager name (optional)
  --   Session ID       - Session ID of manager or other process (optional)
  --
  -- 			Only one of the above arguments needs to be passed
  -- Arguments (output)
  --   Returns information about the holding process ...
  --
  --   Process ID	- Oracle Process ID of the process holding the lock
  --   Terminal		- Terminal (if any) associated with the holding process
  --   Node		- Node on which the holding process resides
  --   User		- Owner of the holding process
  --   Program		- Name of the program that is holding the lock/resource
  --
  --
  function Check_Lock_Contention
		 (Queue_Name   IN  varchar2 default NULL,
		  Session_ID   IN  number  default NULL,
		  UProcess_ID OUT NOCOPY number,
		  UTerminal   OUT NOCOPY varchar2,
		  UNode       OUT NOCOPY varchar2,
		  UName      OUT NOCOPY varchar2,
		  UProgram    OUT NOCOPY varchar2) return  boolean;
  -- pragma restrict_references (Check_Lock_Contention, WNDS);

  function get_program_attributes
		 (appl_shortname IN varchar2 default NULL,
		  program        IN varchar2 default NULL,
		  printer     OUT NOCOPY varchar2,
		  style       OUT NOCOPY varchar2,
		  save_output OUT NOCOPY varchar2) return boolean;
  pragma restrict_references (get_program_attributes, WNDS);

  --
  -- Name
  --   FND_CONCURRENT.INIT_REQUEST
  -- Purpose
  --   Called for all concurrent requests to update session id and process
  --   id information
  --
  -- Arguments (input)
  --
  --
  -- Returns:
  --
  --

  procedure init_request;

  PROCEDURE SET_PREFERRED_RBS;

  function Reset_Context(Request_ID IN Number default NULL) return boolean;

  -- Name
  --   FND_CONCURRENT.AF_COMMIT
  -- Purpose
  --   It does the commit and set the preferred rollback segment for the
  --   program. Call this routine only in the concurrent program context.
  --
  -- Arguments (input)
  --
  -- Returns:
  Procedure AF_COMMIT;

  -- Name
  --   FND_CONCURRENT.AF_ROLLBACK
  -- Purpose
  --   It does the rollback and set the preferred rollback segment for the
  --   program. Call this routine only in the concurrent program context.
  --
  -- Arguments (input)
  --
  -- Returns:
  Procedure AF_ROLLBACK;

  -- Name
  --   FND_CONCURRENT.SHUT_DOWN_PROCS
  -- Purpose
  --   Runs the pl/sql shutdown procedures stored in FND_EXECUTABLES
  --   with EXECUTION_METHOD_CODE = 'Z'.
  --

  procedure shut_down_procs;

  -- Name
  --   FND_CONCURRENT.SET_INTERIM_STATUS
  -- Purpose
  --   sets the requests phase_code, interim_status_code and completion_text
  --   this is used in Java Concurrent Programs.
  --
  -- Arguments (input)
  --   status		- 'NORMAL', 'WARNING', or 'ERROR'
  --   message		- Optional message
  --
  -- Returns:
  --   TRUE on success.  FALSE on error.
  --

  function set_interim_status( status  IN VARCHAR2,
				message IN VARCHAR2) return boolean;

  -- Name
  --   FND_CONCURRENT.SET_INTERIM_STATUS
  -- Purpose
  --   sets the requests phase_code, interim_status_code and completion_text
  --   this is used in Java Concurrent Programs.
  --
  -- Arguments (input)
  --   request_id	- Request id
  --   status		- 'NORMAL', 'WARNING', or 'ERROR'
  --   message		- Optional message
  --
  -- Returns:
  --   TRUE on success.  FALSE on error.
  --

  function set_interim_status( request_id IN NUMBER,
                               status  IN VARCHAR2,
			       message IN VARCHAR2) return boolean;

  TYPE requests_rec IS RECORD ( request_id       number,
			      	phase            varchar2(80),
				status  	 varchar2(80),
				dev_phase        varchar2(30),
				dev_status	 varchar2(30),
				message		 varchar2(240));

  TYPE requests_tab_type IS TABLE of requests_rec
	index by binary_integer;

  -- Name
  --   FND_CONCURRENT.DEBUG
  -- Purpose
  --   Used to put some debug statements
  --
  --	procedure debug(message in varchar2);

  -- Name
  --   FND_CONCURRENT.GET_SUB_REQUESTS
  -- Purpose
  --   gets all sub-requests for a given request id. For each sub-request it
  --   provides request_id, phase,status, developer phase , developer status
  --   completion text.
  --
  -- Arguments (input)
  --   request_id       - Request Id for which sub-requests are required.
  --
  -- Returns:
  --   Table FND_CONCURRENT.REQUESTS_TAB_TYPE.If the table size is 0 then
  --   there are no sub requests for the given request.
  --

  function get_sub_requests(p_request_id IN number)  return requests_tab_type;


  -- Name
  --   FND_CONCURRENT.CHILDREN_DONE
  -- Purpose
  --   Examines all descendant requests of a given request id.  Returns TRUE if
  --   all have completed.
  --
  -- Arguments (input)
  --   Parent_Request_ID - Request Id for which sub-requests are required. Null
  --                       will be interpreted as current req_id.
  --   Recursive_Flag    - Should the function check/wait for all descendants (grandchildren)as well
  --
  --   Interval          - If Timeout>0, then we sleep this many seconds between queries(default 60)
  --   Max_Wait          - If > 0 and children not done, we will wait up to Timeout seconds before
  --                       responding  FALSE
  --  Function returns TRUE if all descendant requests have "Completed".
  --  Outcome (Success/Error/Warning) of the completed requests does not influence the outcome of
  --  "Children_Done" function. Function returns FALSE if it's unable to determine the
  --  status of all the descendant requests OR if it timesout.


  function CHILDREN_DONE(Parent_Request_ID IN NUMBER default NULL,
                               Recursive_Flag in varchar2 default 'N',
                               Interval IN number default 60,
                               Max_Wait IN number default 0) return boolean;

procedure register_node( name          varchar2,               /* Max 30 bytes */
                         platform_id   number,                 /* Platform ID from BugDB */
                         forms_tier    varchar2,               /* 'Y'/'N' */
                         cp_tier       varchar2,               /* 'Y'/'N' */
                         web_tier      varchar2,               /* 'Y'/'N' */
                         admin_tier    varchar2,               /* 'Y'/'N' */
                         p_server_id   varchar2 default NULL,  /* ID of server */
                         p_address     varchar2 default NULL,  /* IP address of server */
                         p_description varchar2 default NULL,
			 p_host_name   varchar2 default NULL,
			 p_domain      varchar2 default NULL, /* description of server*/
			 db_tier       varchar2 default NULL,  /* 'Y'/'N'  */
                         p_virtual_ip  varchar2 default NULL); /* Virtual IP */

TYPE Service_Instance_Rec IS RECORD ( Service_Handle  varchar2(8),
                                      Application     varchar2(50),
                                      Instance_Name   varchar2(30),
                                      State           varchar2(30));

TYPE Service_Instance_Tab_Type IS TABLE of Service_Instance_Rec
       index by binary_integer;

  -- Name
  --   Fnd_Concurrent.Get_Service_Instances
  -- Purpose
  --   Fetch all service instances defined for a Service type
  --   Returns the service instance identity along with it's current
  --   state (Active/Disabled/Inactive/Suspended/Transit )
  --
  -- Arguments (input)
  --   svc_handle   - Developer name for the Service type
  --
  -- Returns:
  --   Table Fnd_Concurrent.Service_Instance_Tab_Type. A table size of 0
  --   indicates absence of any service instances for the specified service
  --   type
  --

function Get_Service_Instances(svc_handle IN  VARCHAR2)
                         return Service_Instance_Tab_Type;

TYPE Service_Process_Rec IS RECORD ( CPID         number,
                                     State        varchar2(80),
                                     Node         varchar2(256),
                                     Parameters   varchar2(2000));

TYPE Service_Process_Tab_Type IS TABLE of Service_Process_Rec
 index by binary_integer;

  -- Name
  --   Fnd_Concurrent.Get_Service_Processes
  -- Purpose
  --   Fetch all service instance processes for a service instance
  --
  -- Arguments (input)
  --   appl_short_name        - Application Short Name under which the service
  --                          - instance is registered
  --   svc_instance_name      - Developer name for the service instance
  --   proc_state             - Service process state
  --
  --   Application and Service Instance Name together can be used to locate
  --   all processes
  --
  --   Returns (Fnd_Concurrent.Service_Process_Tab_Type)
  --     Fnd_Concurrent.Service_Process_Tab_Type.
  --     CPID (Concurrent_Process_ID) - Can be used to address/act on the
  --                                    process
  --     Service_Parameters           - To be used to target particular
  --                                  - service instances
  --   A table size of 0 indicates absence of any service processes
  --   for the specified service instance and state
  --

function Get_Service_Processes(appl_short_name       IN varchar2,
                               svc_instance_name     IN varchar2,
                               proc_state            IN varchar2)
           return Service_Process_Tab_Type;


  /* internal use only . . .need to put in spec for pragma */
function MSC_MATCH(requestid number,
        app_id number, que_id number, mtype number) return number;

  pragma restrict_references(MSC_MATCH,WNDS);



  -- Name
  --   FND_CONCURRENT.find_pending_svc_ctrl_reqs
  -- Purpose
  --   gets all pending service control requests for a given service or service
  --   instance.  Returns number of requests found and has an out parameter
  --   containing a comma delimited list of matching requests.
  --
  -- Arguments (input)
  --   service_id       - Service ID of service in which we are interested.
  --				(Set to null if this doesn't matter)
  --   service_inst_id  - Service instance ID of svc in which we are interested.
  --				(Set to null if this doesn't matter)
  --   request_list     - Comma delimited list of matching request ids.
  --
  -- Returns:
  --   Number of mathcing requests.
  --


function find_pending_svc_ctrl_reqs(service_id in number,
				service_inst_id in number,
				req_list out NOCOPY varchar2)  return number;


  -- Name
  --   FND_CONCURRENT.Function Wait_for_SCTL_Done
  -- Purpose
  --	Waits for Svc Ctrl request to finish, or another conflicting request,
  --    or timeout.
  --
  -- Arguments (input)
  --   reqid		-  request id we are interested in.
  --
  --   timeout		-  timeout in seconds;
  --
  -- Returns:
  --   Number -
  --			- 1: request not found.
  --                    - 2: request is not a supported type.
  --                    - 3: request has not run before timeout.
  --			- 4: later request conflicts with this request.
  --           		- 5: request has run, but not complete before timeout.
  --	             	- 6: requested actions have completed.
  --
  -- Supporting routines:
  --   For readability the following functions are available to compare to
  --   result:

 Function SCTL_REQ_NOT_FOUND return number; -- 1
 Function SCTL_REQ_NOT_SUPPD return number; -- 2
 Function SCTL_TIMEOUT_NOT_R return number; -- 3
 Function SCTL_REQ_CONFLICTS return number; -- 4
 Function SCTL_TIMEOUT_NOT_C return number; -- 5
 Function SCTL_REQ_COMPLETED return number; -- 6

 Function Wait_for_SCTL_Done(reqid in number, timeout in number) return number;
  -- Name
  --   FND_CONCURRENT.Find_SC_Conflict
  -- Purpose
  --    Finds later conflicting service control request (if any) for another
  --    service control request.
  --
  -- Arguments (input)
  --   reqid            -  request id we are interested in.
  --
  -- Returns:
  --   Request ID of a conflicting request, or -1 if none exist.

 Function Find_SC_Conflict(reqid in number) return number;


  -- Name
  --   FND_CONCURRENT.Wait_For_All_Down
  -- Purpose
  --    Waits for all services, managers, and icm to go down, or timesout.
  --
  -- Arguments (input)
  --   Timeout            -  in seconds.
  --
  -- Returns:
  --   True if all shut down, false for timeout.

  Function Wait_For_All_Down(Timeout in number) return boolean;

  -- Name
  --   FND_CONCURRENT.Build_Svc_Ctrl_Desc.
  -- Purpose
  --    Provides description text for svc ctrl request based on args.
  --
  -- Arguments (input)
  --    Arg1, Arg2, Arg3 - request arguments for svc ctrl request.
  --
  -- Returns:
  --    Description of Request

  Function Build_Svc_Ctrl_Desc(Arg1 in number,
			       Arg2 in number,
                               Arg3 in number,
                               Prog in varchar2
                               ) return varchar2;

  -- Name
  --   FND_CONCURRENT.Cancel_Request.
  -- Purpose
  --    It Cancels given Concurrent Request.
  --
  -- Arguments (input)
  --    request_id - request id of the request you want to cancel.
  --
  --   (out args)
  --    message    - API will fill the message with any errors while canceling
  --                 request.
  --
  -- Returns:
  --    Returns TRUE if success or FALSE on failure.

  function cancel_request( request_id in  number,
                           message    out NOCOPY varchar2) return boolean;
  --
  -- Name
  --   FND_CONCURRENT.get_resource_lock
  -- Purpose
  --   It gets an exclusive lock for a given resource or task name.
  --
  -- Arguments (input)
  --   Resource_name  - Name of the resource that uniquely identifies
  --                    in the system.
  --   timeout   - Number of seconds to continue trying to grant the lock
  --               default is 2 seconds.
  --
  -- Returns:
  --      0 - Success
  --      1 - Timeout ( Resource is locked by other session)
  --      2 - Deadlock
  --      3 - Parameter error
  --      4 - Already own lock specified by lockhandle
  --      5 - Illegal lock handle
  --      -1 - Other exceptions, get the message from message stack for reason.

  function get_resource_lock ( resource_name in varchar2,
				timeout in number default 2 ) return number;

  --
  -- Name
  --   FND_CONCURRENT.release_resource_lock
  -- Purpose
  --   It releases an exclusive lock for a given resource or task name.
  --
  -- Arguments (input)
  --   Resource_name  - Name of the resource that uniquely identifies
  --                    in the system.
  --
  -- Returns:
  --    0  - Success
  --    3  - Parameter Error
  --    4  - Do not own lock
  --    5  - Illegal lock handle
  --    -1 - Other exceptions, get the message from message stack for reason.

  function release_resource_lock ( resource_name in varchar2 ) return number;

 --
  -- Name
  --   FND_CONCURRENT.INIT_SQL_REQUEST
  -- Purpose
  --   Called for all SQL*PLUS concurrent requests to perform request initialization.
  --

  procedure init_sql_request;


  function check_user_privileges( p_user_name IN varchar2,
                                  p_test_code IN varchar2 DEFAULT NULL) RETURN number;

  function check_program_privileges( p_user_name IN varchar2,
                                     p_resp_id IN number DEFAULT NULL,
                                     p_resp_appl_id IN number DEFAULT NULL,
                                     p_program_name IN varchar2,
                                     p_application_short_name IN varchar2,
                                     p_sec_group_id IN number ) RETURN number;

end FND_CONCURRENT;

/

  GRANT EXECUTE ON "APPS"."FND_CONCURRENT" TO "EM_OAM_MONITOR_ROLE";
