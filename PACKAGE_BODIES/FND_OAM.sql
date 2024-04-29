--------------------------------------------------------
--  DDL for Package Body FND_OAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM" as
/* $Header: AFCPOAMB.pls 120.3 2005/11/16 13:17:40 ravmohan ship $ */

--
-- Package
--   FND_OAM
-- Purpose
--   Utilities for the Oracle Applications Manager
-- History

  --
  -- GENERIC_ERROR (Internal)
  --
  -- Set error message and raise exception for unexpected sql errors.
  --
  procedure GENERIC_ERROR(routine in varchar2,
                          errcode in number,
                          errmsg in varchar2) is
  begin
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', routine);
      fnd_message.set_token('ERRNO', errcode);
      fnd_message.set_token('REASON', errmsg);
  end;



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
  procedure APPS_SESSIONS(logins out nocopy number, forms out nocopy number) is
  begin
    select count(distinct(r.login_id))
      into logins
      from fnd_login_responsibilities r, v$session s
     where r.audsid = s.audsid;

    select count(*)
      into forms
      from fnd_login_resp_forms f, v$session s
     where f.audsid = s.audsid;
  end;




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
                            error out nocopy number, terminated out nocopy number) is
  begin
    select count(*)
      into normal
      from fnd_concurrent_requests
     where status_code = 'C';

    select count(*)
      into warning
      from fnd_concurrent_requests
     where status_code = 'G';

    select count(*)
      into error
      from fnd_concurrent_requests
     where status_code = 'E';

    select count(*)
      into terminated
      from fnd_concurrent_requests
     where status_code = 'X';
  end;


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
                          standby out nocopy number) is
  begin
    select count(*)
      into normal
      from fnd_concurrent_requests
     where status_code = 'I'
       and requested_start_date <= sysdate
       and hold_flag = 'N';

    select count(*)
      into standby
      from fnd_concurrent_requests
     where status_code = 'Q'
       and requested_start_date <= sysdate
       and hold_flag = 'N';

    select count(*)
      into scheduled
      from fnd_concurrent_requests
     where (status_code = 'P' or
             (status_code in ('I', 'Q') and requested_start_date > sysdate))
       and hold_flag = 'N';
  end;


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
  procedure CONC_MGR_PROCS (running_reqs out nocopy number, mgr_procs out nocopy number) is
  begin
    select count(*)
      into running_reqs
      from fnd_concurrent_requests
     where status_code = 'R'
        or status_code = 'T';

    select sum(running_processes)
      into mgr_procs
      from fnd_concurrent_queues
     where manager_type = '1';
  end;

  --
  -- Name
  --   VALIDATE_USER
  --
  -- Purpose
  --   To check if user has access to 'System Administrator' responsibility
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
  function VALIDATE_USER(username in varchar2, message in out nocopy varchar2) return number is
	dummy number;
  begin

	  select 1
	    into dummy
          from fnd_responsibility r,
               fnd_user_resp_groups u,
		   fnd_user fu
         where fu.user_name=upper(username)
	     and u.user_id = fu.user_id
	     and u.responsibility_id = r.responsibility_id
           and u.responsibility_application_id = r.application_id
           and r.responsibility_key='SYSTEM_ADMINISTRATOR'
           and r.version = '4'
           and r.start_date <= sysdate
           and (r.end_date is null or r.end_date > sysdate);


	  return 1;

	exception
         when no_data_found then
            return 0;
	   when others then
	      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      	fnd_message.set_token('ROUTINE', 'FND_OAM.VALIDATE_USER');
	      fnd_message.set_token('ERRNO', SQLCODE);
      	fnd_message.set_token('REASON', SQLERRM);
	      message :=  fnd_message.get;
      	return 0;

  end;

  --
  -- Name
  --   Set_Debug
  --
  -- Purpose
  --   To dynamically change/alter the diagnostics level of
  --    individual manager or service
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
  function Set_Debug(Application in number,
                     QueueID     in number,
                     ManagerType in number,
                     DiagLevel   in varchar2,
                     Message     in out nocopy varchar2) return number is
  begin

  -- Following is just a place holder .. the logic should change ..
  --
	if (ManagerType is not null) then
            Update Fnd_Concurrent_Queues
               Set Diagnostic_Level = DiagLevel
             Where Manager_Type = ManagerType;
        else
            Update Fnd_Concurrent_Queues
               Set Diagnostic_Level = DiagLevel
             Where Application_ID = Application
               and Concurrent_queue_ID = QueueID;
	end if;

        commit;
        return 1;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_OAM.Set_Debug');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      return 0;
  end;


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
                           error_message out nocopy varchar2) is
    n number;
  Begin
    /* Due to NLS issues and UI concerns, we will not be
     * passing back concatenated error and warning messages
     * in the description parameter.  We will pass back
     * a single, somewhat generic message that describes the
     * worst error or warning found.  e.g. "One or more service
     * instances is down."
     *
     */

    n := 0;
    error_code := 0;
    error_message := null;


---    if (service_id < 1000) then //this is no longer needed
      /*
       * Need to call get_manager_status
       * for and Accurate count.
       */
      declare
        appl_id       number;
        conc_queue_id number;
        tmp_target    number;
        tmp_actual    number;
        pmon          varchar2(10);
        callstat      number;

        cursor svc_cursor (svc_id number) is
          select application_id, concurrent_queue_id
            from fnd_concurrent_queues
           where (max_processes > 0 or running_processes > 0)
             and manager_type = svc_id;

      begin
        target := 0;
        actual := 0;

        for svc_rec in svc_cursor(service_id) loop
          appl_id := svc_rec.application_id;
          conc_queue_id := svc_rec.concurrent_queue_id;
          fnd_concurrent.get_manager_status( appl_id,
                                             conc_queue_id,
                                             tmp_target,
                                             tmp_actual,
                                             pmon,
                                             callstat);
          if (callstat > 0) then
            error_message := fnd_message.get;
            error_code := 1;
            return;
          end if;

          actual := actual + tmp_actual;
          target := target + tmp_target;

        end loop;
      end;


    /* Were any processes down? */
    if ( actual < target) then

      /* Are all of the service processes for an instance down? */
      select count(*) into n
        from fnd_concurrent_queues
       where running_processes = 0
         and max_processes > 0;

      if ( n > 0) then /* All processes for an instance are down. */

        fnd_message.set_name('FND', 'CONC-SM SOME INST DOWN');
        status := 2; /* Error*/

      else /* No one instance is completely down. */

        fnd_message.set_name('FND', 'CONC-SM SOME PROCS DOWN');
        /* The message name is slightly misleading.  This is an imbalance. */

        status := 1; /* Warning */

      end if;

      description := fnd_message.get;
      return;

    elsif (actual = 0 and target = 0) then /* All are inactive */

      description := null;

      -- Change for Bug 2640311
      if service_id = 0 then
	status := 2; /* Error because ICM should always be up */
      else
      	status := 3; /* Deactivated */
      end if;
      -- End change for Bug 2640311

      return;

    end if;

    description := null;
    status := 0; /* Normal */
    return;

  exception
    when others then
      generic_error('fnd_oam.get_service_status', SQLCODE, SQLERRM);
      error_message := fnd_message.get;
      error_code := 1;
  end;




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
  --    error_message - Describes any runtime errors within theif;

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
                   	       error_message  	   out nocopy varchar2) is
    mgr_type number;
    pmon     varchar2(10);
    callstat number;
  begin

    error_code := 0;

    fnd_concurrent.get_manager_status(appl_id,
                                        conc_queue_id,
                                        target,
                                        actual,
                                        pmon,
                                        callstat);
    if (callstat > 0) then
        error_message := fnd_message.get;
        error_code := 1;
        return;
    end if;

    if (actual = 0 and target > 0) then /* All processes down */

      fnd_message.set_name('FND', 'CONC-SM SVC INST DOWN');
      description := fnd_message.get;
      status := 2; /* Error */

    elsif (actual > 0 and actual < target) then /* Some procs down */

      fnd_message.set_name('FND', 'CONC-SM INST PROCS DOWN');
      /* Again, the message name is slightly misleading. */

      description := fnd_message.get;
      status := 1; /* Warning */

    elsif (actual = 0 and target = 0) then /* Inactive */

      description := null;

      -- Change for Bug 2640311
      if appl_id = 0 and conc_queue_id = 1 then
	status := 2; /* Error because ICM should always be up and running */
      else
      	status := 3; /* Deactivated */
      end if;
      -- end Change for Bug 2640311

    else

      description := null;
      status := 0; /* Warning */

    end if;


  exception
    when others then
      generic_error('fnd_oam.get_svc_inst_status', SQLCODE, SQLERRM);
      error_message := fnd_message.get;
      error_code := 1;
  end;




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
                           error_message out nocopy varchar2) is
    icm_node varchar2(30);
    target                     number;
    actual                     number;
    all_procs_down_for_service boolean;
    total_target               number;
    total_actual               number;
    appl_id                    number;
    conc_queue_id              number;
    pmon                       varchar2(10);
    callstat                   number;

  cursor svc_cursor (tnode varchar2, inode varchar2) is
          select application_id, concurrent_queue_id,
                 manager_type, max_processes, running_processes
            from fnd_concurrent_queues
           where target_node = tnode
              or (target_node is null and tnode = inode);

  begin
    /* Get ICM_NODE */
    select target_node into icm_node
      from fnd_concurrent_queues
     where concurrent_queue_id = 1
       and application_id = 0;

    total_target := 0;
    total_actual := 0;
    all_procs_down_for_service := false;

    for svc_rec in svc_cursor(node_name, icm_node) loop

      if (to_number(svc_rec.manager_type) < 1000) then
        /*
         * Internal service - Need to call get_manager_status
         * for and Accurate count.
         */
        appl_id := svc_rec.application_id;
        conc_queue_id := svc_rec.concurrent_queue_id;

        fnd_concurrent.get_manager_status(appl_id,
                                          conc_queue_id,
                                          target,
                                          actual,
                                          pmon,
                                          callstat);
        if (callstat > 0) then
          error_message := fnd_message.get;
          error_code := 1;
          return;
        end if;
      else
        target := svc_rec.max_processes;
        actual := svc_rec.running_processes;
      end if;


      total_target := total_target + target;
      total_actual := total_actual + actual;

      if (target > 0 and actual = 0) then
        all_procs_down_for_service := true;
      end if;

    end loop;


    if (total_actual = 0 and total_target > 0) then /* All processes down */

      fnd_message.set_name('FND', 'CONC-NODE ALL PROCS DOWN');
      description := fnd_message.get;
      status := 2; /* Error */

    elsif (all_procs_down_for_service) then /* Some service down */

      fnd_message.set_name('FND', 'CONC-NODE SVC DOWN');
      description := fnd_message.get;
      status := 2; /* Error */

    elsif (total_target > total_actual) then /* Some procs down */

      fnd_message.set_name('FND', 'CONC-NODE PROCS DOWN');
      description := fnd_message.get;
      status := 1; /* WARNING */

    else

      description := null;
      status := 0; /* Normal */

    end if;

  exception
    when others then
      generic_error('fnd_oam.get_node_status', SQLCODE, SQLERRM);
      error_message := fnd_message.get;
      error_code := 1;
  end;


  procedure get_req_status_phase_schDesc(
		      pcode  in char,
	              scode  in char,
		      hold   in char,
	              enbld  in char,
	              stdate in date,
		      rid    in number,
                      status out nocopy varchar2,
	 	      phase  out nocopy varchar2,
	 	      schDesc  out nocopy varchar2) is
   begin
       status  :=  fnd_amp_private.get_phase(pcode, scode, hold, enbld, stdate, rid);
        phase  :=  fnd_amp_private.get_status(pcode, scode, hold, enbld, stdate, rid);
      schDesc  :=  fnd_conc_sswa.get_sch_desc(rid);
   end;



end FND_OAM;

/

  GRANT EXECUTE ON "APPS"."FND_OAM" TO "EM_OAM_MONITOR_ROLE";
