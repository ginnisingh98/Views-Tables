--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT" as
/* $Header: AFCPUTLB.pls 120.12.12010000.10 2018/02/16 22:24:56 ckclark ship $ */
--
-- Package
--   FND_CONCURRENT
-- Purpose
--   Concurrent processing related utilities
-- History
--   XX/XX/93	Ram Bhoopalam	Created
--
  --
  -- PRIVATE VARIABLES
  --
	oraerrmesg	  varchar2(240) := NULL;
	P_ICMCID          number        := 0;
	P_CRM             boolean       := FALSE;

	PHASE_LOOKUP_TYPE constant varchar2(16) := 'CP_PHASE_CODE';
	STATUS_LOOKUP_TYPE constant varchar2(16) := 'CP_STATUS_CODE';

	TYpe ConcProcessLocks Is Table of
		Fnd_Concurrent_Processes.Lk_Handle%TYPE
			Index By Binary_Integer;

	CmLkHandles  ConcProcessLocks;


  -- Exception info.

  --
  -- PRIVATE FUNCTIONS
  -- --

  function get_handle(cpid  IN    number default 0,
		      apid  IN    number default 0,
		      cqid  IN    number default 0,
		      lkhn IN OUT NOCOPY varchar2) return boolean is
  result    number;
  icm_cid   varchar2(20);
  begin

     if ( apid = 0 AND cqid = 1 ) then
	Select Max(Concurrent_Process_ID)
          Into icm_cid
	  From Fnd_Concurrent_Processes
	 Where Process_Status_Code = 'A'
	   And (Queue_Application_ID = 0 And
		Concurrent_Queue_ID  = 1);

	if (Sql%NotFound) then
	   P_ICMCID := 0;
	   raise no_data_found;
	end if;

	if ( icm_cid <> P_ICMCID ) then
	   P_ICMCID := icm_cid;
	   raise no_data_found;
	end if;
     end if;

     lkhn := CmLkHandles(cpid);
     return TRUE;

  exception
     when no_data_found then
	FND_DCP.get_lk_handle(apid, cqid, cpid, lkhn, result);
	if ( result = 1 ) then
	   CmLKHandles(cpid) := lkhn;
	   return TRUE;
        else
	   return FALSE;
	end if;

     when others then
       oraerrmesg := substr(SQLERRM, 1, 80);
       Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
       Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
       Fnd_Message.Set_Token('ROUTINE', 'FND_CONCURRENT.Get_Handle', FALSE);
       return FALSE;
  end get_handle;

  -- procedure is internal to this package.
  -- returns developer phase and status values for a given phase and status
  -- codes.

  procedure get_dev_phase_status(phase_code  IN  varchar2,
				 status_code IN  varchar2,
				 dev_phase   OUT NOCOPY varchar2,
				 dev_status  OUT NOCOPY varchar2) is
  begin
    IF (phase_code = 'R') THEN
	Dev_Phase := 'RUNNING';
    ELSIF (phase_code = 'P') THEN
	Dev_Phase := 'PENDING';
    ELSIF (phase_code = 'C') THEN
	Dev_Phase := 'COMPLETE';
    ELSIF (phase_code = 'I') THEN
	Dev_Phase := 'INACTIVE';
    END IF;

    IF (status_code = 'R') THEN
	Dev_Status := 'NORMAL';
    ELSIF (status_code = 'T') THEN
	Dev_Status := 'TERMINATING';
    ELSIF (status_code = 'A') THEN
	Dev_Status := 'WAITING';
    ELSIF (status_code = 'B') THEN
	Dev_Status := 'RESUMING';

    ELSIF (status_code = 'I') THEN
	Dev_Status := 'NORMAL';		-- Pending normal
    ELSIF (status_code = 'Q') THEN
	Dev_Status := 'STANDBY';	-- Pending, due to incompatabilities
    ELSIF (status_code = 'F' or status_code = 'P') THEN
	Dev_Status := 'SCHEDULED';	--
    ELSIF (status_code = 'W') THEN
	Dev_Status := 'PAUSED';		--

    ELSIF (status_code = 'H') THEN
	Dev_Status := 'ON_HOLD';	-- Request Pending and on hold
    ELSIF (status_code = 'S') THEN
	Dev_Status := 'SUSPENDED';	--
    ELSIF (status_code = 'U') THEN
	Dev_Status := 'DISABLED';	-- Program has been disabled
    ELSIF (status_code = 'M') THEN
	Dev_Status := 'NO_MANAGER';	-- No defined manager can run it

    ELSIF (status_code = 'C') THEN
	Dev_Status := 'NORMAL';		-- Completed normally
    ELSIF (status_code = 'G') THEN
	Dev_Status := 'WARNING';	-- Completed with warning
    ELSIF (status_code = 'E') THEN
	Dev_Status := 'ERROR';		-- Completed with error
    ELSIF (status_code = 'X') THEN
	Dev_Status := 'TERMINATED';	-- Was terminated by user
    ELSIF (status_code = 'D') THEN
	--Bug8795072
	--Dev_Status := 'DELETED';	-- Was deleted when pending
	Dev_Status := 'CANCELLED';	-- Was deleted when pending
    END IF;
  end;

  function get_svc_state(p_enabled    IN  varchar2,
                         p_ctrl_code  IN  varchar2,
                         p_run_procs  IN  varchar2,
                         p_max_procs  IN  varchar2) return varchar2 is

  begin
        if (p_enabled = 'N') then
           return 'DISABLED';
        elsif (p_ctrl_code IS NULL and p_run_procs > 0) then
           return 'ACTIVE';
        elsif ((p_ctrl_code IN ('E', 'X', 'N') or
                                 p_ctrl_code IS NULL) and
               p_run_procs = 0 and p_max_procs = 0) then
           return 'INACTIVE';
        elsif (p_ctrl_code = 'P') then
           return 'SUSPENDED';
        else
           return 'TRANSIT';
        end if;
  end;


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
  -- status		- Request status( for display purposes	 )
  --   dev_phase	- Request phase as a constant string so that it
  --			- can be used for comparisons )
  --   dev_status	- Request status as a constatnt string
  --   message		- Completion message if request has completed
  --
  function get_request_status(request_id      IN OUT NOCOPY number,
		 	      appl_shortname  IN varchar2 default NULL,
			      program         IN varchar2 default NULL,
	    		      phase      OUT NOCOPY varchar2,
			      status     OUT NOCOPY varchar2,
			      dev_phase  OUT NOCOPY varchar2,
			      dev_status OUT NOCOPY varchar2,
			      message    OUT NOCOPY varchar2) return  boolean is

	Prog_Appl_ID      number;
	Program_ID        number;
	phase_code        char;
	status_code	  char;
	req_phase	  char;
	req_status	  char;
	phasem		  varchar2(80);
	statusm		  varchar2(80);
	comptext	  varchar2(255);
        Reqid_for_message varchar2(15);

	Req_ID            number := Request_ID;
	program_validate_error exception;
        fcr_access_error       exception;
		status_fetch_error     exception;

  begin
    --
    -- Check if request id is provided. If request id is not provided
    -- then get the most recent request id for the program name given
    --
    dev_status := NULL;
    dev_phase  := NULL;
    status     := NULL;
    phase      := NULL;


    if (Request_ID is null) then
	if (Program is null or Appl_ShortName is null) then
	   Fnd_Message.Set_Name('FND', 'CONC-Req information required');
	   return FALSE;
	end if;
      begin
	Select Concurrent_Program_ID, P.Application_ID
	  Into Program_ID, Prog_Appl_ID
	  From Fnd_Concurrent_Programs P,
	       Fnd_Application A
	 Where Concurrent_Program_Name  = Program
	   And P.Application_ID         = A.Application_ID
	   And A.Application_Short_Name = Appl_ShortName;
    --
    --  If no rows returned, return message "CONC-Invalid Appl/Prog combo"
    --
	exception
    	  when no_data_found THEN
	     Fnd_Message.Set_Name('FND', 'CONC-Invalid Appl/Prog combo');
	     return FALSE;
	  when others then
	     raise;		--  program_validate_error
	end;
    --
    -- Check for the most recently submitted request for this program
    --
      begin
	Select Max(Request_ID)
          Into Req_ID
	  From Fnd_Concurrent_Requests
	 Where Program_Application_ID = Prog_Appl_ID
	   And Concurrent_Program_ID  = Program_ID;
    --
    --   If No rows returned, then return message saying there are no
    --   requests for this program "CONC-No req for appl/prog"
    --
      exception
	when no_data_found then
	     Fnd_Message.Set_Name('FND', 'CONC-No req for appl/prog');
	     Fnd_Message.Set_Token('APPL', Appl_ShortName, FALSE);
	     Fnd_Message.Set_Token('PROGRAM', Program, FALSE);
	     return FALSE;
	when others then
	     raise;		--  fcr_access_error
	end;

	Request_ID := Req_ID;

    end if;

    --
    --   Get Request Phase, Status and Completion Text
    --
  begin



    Select Phase_Code, Status_Code, Completion_Text,
                    Phase.Lookup_Code, Status.Lookup_Code,
                    Phase.Meaning, Status.Meaning
               Into req_phase, req_status, comptext,
		    phase_code, status_code,
                    phasem, statusm
               From Fnd_Concurrent_Requests R,
                    Fnd_Concurrent_programs P,
                    Fnd_Lookups Phase,
                    Fnd_Lookups Status
              Where
                    Phase.Lookup_Type = PHASE_LOOKUP_TYPE
                AND Phase.Lookup_Code = Decode(Status.Lookup_Code,
                                    'H', 'I',
                                    'S', 'I',
                                    'U', 'I',
                                    'M', 'I',
                                    R.Phase_Code) AND
            Status.Lookup_Type = STATUS_LOOKUP_TYPE AND
            Status.Lookup_Code =
             Decode(R.Phase_Code,
             'P', Decode(R.Hold_Flag,          'Y', 'H',
                  Decode(P.Enabled_Flag,       'N', 'U',
                  Decode(Sign(R.Requested_Start_Date - SYSDATE),1,'P',
                  R.Status_Code))),
             'R', Decode(R.Hold_Flag,          'Y', 'S',
                  Decode(R.Status_Code,        'Q', 'B',
                                               'I', 'B',
                  R.Status_Code)),
                  R.Status_Code)
                And (R.Concurrent_Program_Id = P.Concurrent_program_ID AND
                     R.Program_Application_ID= P.Application_ID )
                And Request_Id = Req_ID;
    --
    --   If no rows, return message...
    --
  exception
    when no_data_found then
	Reqid_for_message := Req_ID;
	Fnd_Message.Set_Name('FND', 'CONC-Request missing');
	Fnd_Message.Set_Token('ROUTINE',
		   'FND_CONCURRENT.GET_REQUEST_STATUS', FALSE);
	Fnd_Message.Set_Token('REQUEST', Reqid_for_message, FALSE);
	return FALSE;
    when others then
	raise;			--  status_fetch_error
  end;
    --
    --   Copy phase, status and completion text to out varaibles and
    --   fill in developer names for phase and status
    --
    Phase   := phasem;
    Status  := statusm;
    message := comptext;

    get_dev_phase_status(phase_code, status_code, dev_phase,  dev_status);

    return TRUE;
    exception
      -- when program_validate_error then
      --   null;
      -- when fcr_access_error then
      --   null;
      -- when status_fetch_error then
      --   null;
      when others then
	oraerrmesg := substr(SQLERRM, 1, 80);
	Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
	Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
	Fnd_Message.Set_Token('ROUTINE',
			      'FND_CONCURRENT.GET_REQUEST_STATUS', FALSE);
        return FALSE;
  end get_request_status;


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
  function wait_for_request(request_id IN number default NULL,
		  interval   IN number default 60,
		  max_wait   IN number default 0,
		  phase      OUT NOCOPY varchar2,
		  status     OUT NOCOPY varchar2,
		  dev_phase  OUT NOCOPY varchar2,
		  dev_status OUT NOCOPY varchar2,
		  message    OUT NOCOPY varchar2) return  boolean is
	Call_Status    boolean;
	Time_Out       boolean := FALSE;
	pipename       varchar2(60);
	req_phase      varchar2(15);
	STime	       number(30);
	ETime	       number(30);
	Rid            number := request_id;
	i	       number;
  begin
    if (Rid is null) then
       Fnd_Message.Set_Name('FND', 'CONC-Req information required');
       return FALSE;
    end if;

    if ( max_wait > 0 ) then
	Time_Out := TRUE;
	Select To_Number(((To_Char(Sysdate, 'J') - 1 ) * 86400) +
		 To_Char(Sysdate, 'SSSSS'))
	  Into STime From Sys.Dual;
    end if;

    LOOP
	call_status := FND_CONCURRENT.get_request_status(Rid, '', '',
 			    phase, status, req_phase, dev_status, message);
    	if ( call_status = FALSE OR req_phase = 'COMPLETE' ) then
	   dev_phase := req_phase;
	   return (call_status);
        end if;

	if ( Time_Out ) then
	   Select To_Number(((To_Char(Sysdate, 'J') - 1 ) * 86400) +
		  To_Char(Sysdate, 'SSSSS'))
	     Into ETime From Sys.Dual;

	   if ( (ETime - STime) >= max_wait ) then
	      dev_phase := req_phase;
	      return (call_status);
	   end if;
	end if;
	   dbms_lock.sleep(interval);
    END LOOP;

    exception
       when others then
	  oraerrmesg := substr(SQLERRM, 1, 80);
	  Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
	  Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
	  Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.WAIT_FOR_REQUEST', FALSE);
          return FALSE;
  end wait_for_request;

  --
  -- Name
  --   FND_CONCURRENT_GET_MANAGER_STATUS
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

  procedure get_manager_status(applid      IN  number default 0,
			       managerid   IN  number default 1,
			       targetp	   OUT NOCOPY number,
			       activep     OUT NOCOPY number,
			       pmon_method OUT NOCOPY varchar2,
			       callstat    OUT NOCOPY number) is
  lkh        FND_CONCURRENT_PROCESSES.Lk_Handle%TYPE;
  result     number;             -- result code from DBMS_LOCK.Request_Lock
  alive      number;             -- is process alive? 1=TRUE 0=FALSE
  i          number  := 0;
  errflag    boolean := FALSE;
  gothandle  boolean;
  mtype	     number;
  CartType   varchar2(10);
  cur_session_id  number;

  Cursor C1 IS
	Select  Concurrent_Process_Id, Session_Id
	  From  Fnd_Concurrent_Processes
	 Where  Process_Status_Code in ( 'A', 'C', 'T' )
	   And (Queue_Application_ID = applid and
		Concurrent_Queue_ID  = managerid );
  begin
     callstat := 0;
     pmon_method := 'LOCK';


    /* If a service and uses AQCART, use RDBMS PMON method */
    /* If a service and does not use AQCART, return values */
    /* from FCQ                                            */
     select manager_type,
            Running_processes, MAX_PROCESSES, Cartridge_Handle
	into mtype, ActiveP, TargetP, CartType
        from Fnd_Concurrent_Queues Q, Fnd_Cp_Services S
        Where S.Service_ID = Q.Manager_Type
        And (Q.Application_ID = applid
 	And  Q.Concurrent_Queue_ID  = managerid);

     if (mtype>999) then
	 if (CartType = 'AQCART') then
       select count(*)
         into ActiveP
         from gv$session GV, fnd_concurrent_processes P
        where
              GV.Inst_id = P.Instance_number
          And GV.audsid = p.session_id
          And (Process_Status_Code not in ('S','K','U'))
          And ( Queue_Application_ID = applid AND
		Concurrent_Queue_ID = managerid );

	pmon_method := 'RDBMS';
	end if;

	return;
     end if;

     --
     -- Lock PMON method
     --
     ActiveP := 0;
     TargetP := 0;

     /* By convention we want FNDSM's to show exactly the same data as
	the ICM so we have added the mtype = 6 condition to trigger the
	icm status detection */

     if (( applid = 0 AND managerid = 1 ) OR (mtype = 6)) then
	TargetP := 1;
	gothandle := get_handle(0, 0, 1, lkh);
	if ( gothandle ) then
          /*---------------------------------------------------------+
           | Bug 2093806: Use FND_DCP.Check_Process_Status_By_Handle |
           +---------------------------------------------------------*/
           FND_DCP.check_process_status_by_handle(lkh, result, alive);
           if (alive = 1) then
                ActiveP := 1;
           elsif ((alive = 0) and ( result <> 0 )) then
               /*-------------------------------------------------------+
                | Message set by FND_DCP.Check_Process_Status_By_Handle |
                | available for retreival.                              |
                +-------------------------------------------------------*/
		callstat := result;
	   end if;
	   return;
	else
	   callstat := 1;
	   return;
        end if;
     end if;

     Select Max_Processes Into TargetP From Fnd_Concurrent_Queues
      Where Concurrent_Queue_ID = ManagerID
    And Application_ID      = ApplID;


    /* Bug 3443136: Since this API may be called from within a concurrent
       program running in this session, select the current session id and
       compare it with the session id of each manager process.
       If they are they same, do not call check_process_status_by_handle,
       as this will cause this session to lose its lock.
    */
    SELECT userenv('SESSIONID') INTO cur_session_id FROM dual;


    For C1REC in C1 Loop

      if C1REC.SESSION_ID = cur_session_id then
        /* This session is obviously alive ... */
        i := i + 1;
      else
         gothandle := get_handle(C1REC.CONCURRENT_PROCESS_ID,
                                 applid, managerid, lkh);
         if ( gothandle ) then
           /*---------------------------------------------------------+
            | Bug 2093806: Use FND_DCP.Check_Process_Status_By_Handle |
            +---------------------------------------------------------*/
           FND_DCP.check_process_status_by_handle(lkh, result, alive);
           if (alive = 1) then
             i := i + 1;
           elsif ((alive = 0) and ( result <> 0 )) then
             /*-------------------------------------------------------+
              | Message set by FND_DCP.Check_Process_Status_By_Handle |
              | available for retrieval.                              |
              +-------------------------------------------------------*/
             callstat := result;
           end if;
         else
           callstat := 1;
           return;
         end if;
      end if;
     End Loop;

     ActiveP  := i;
     return;

     exception
       when no_data_found then
         ActiveP  := i;
       return;

       when others then
          TargetP  := 0;
          ActiveP  := 0;
      callstat := 1;
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
          'FND_CONCURRENT.GET_MANAGER_STATUS', FALSE);
      return;
  end get_manager_status;

  -- Name
  --   FND_CONCURRENT.SET_STATUS_AUTONUMOUS
  -- Purpose
  --   Updates given request status and completion text in an autonomous
  --   transaction. This is function is called in set_completion_status
  --   function. (Internal use only).
  --
  -- Arguments (input)
  --   Request_ID- Request Id for which it needs update status.
  --   Stutus - 'NORMAL','WARNING', or 'ERROR'
  --   message - Optional message
  --
  -- Returns:
  --   If there is any sql error then returns sql error other-wise null string

  function DO_SET_STATUS_AUTONOMOUS(request_id IN number,
				 status     IN varchar2,
				 message    IN varchar2,
				 interim    IN boolean default FALSE)
			return varchar2 is
    ret_str varchar2(80) := null;
    l_request_id number;
    l_status varchar2(10);
  begin
    if ( fnd_adg_support.is_standby )
    then
$if fnd_adg_compile_directive.enable_rpc
$then

              l_request_id := do_set_status_autonomous.request_id;
	      l_status     := do_set_status_autonomous.status;

	      if ( interim ) then
		if(upper(status) = 'W') then
			update fnd_concurrent_requests_remote
			set interim_status_code = 'W',
			    req_information = substrb(message,1,240)
			where request_id = l_request_id;
		 else
			update fnd_concurrent_requests_remote
			    set interim_status_code = l_status,
			    completion_text = substrb(message, 1, 240)
			    where request_id = l_request_id;
		end if;

	      else
		update fnd_concurrent_requests_remote
		    set phase_code = 'C',
			status_code = l_status,
			completion_text = substrb(message, 1, 240)
		  where request_id = l_request_id;

	      end if;

$else
      null;
$end
    else

      if ( interim ) then
      	if(upper(status) = 'W') then
		update fnd_concurrent_requests
		set interim_status_code = 'W',
		    req_information = substrb(message,1,240)
		where request_id = do_set_status_autonomous.request_id;
		--debug('updated req_information for request_id '|| do_set_status_autonomous.request_id);
	 else
         	update fnd_concurrent_requests
	            set interim_status_code = do_set_status_autonomous.status,
                    completion_text = substrb(message, 1, 240)
        	    where request_id = do_set_status_autonomous.request_id;
		--debug('updated completion_text for request_id '|| do_set_status_autonomous.request_id);
	end if;

      else
	update fnd_concurrent_requests
            set phase_code = 'C',
                status_code = do_set_status_autonomous.status,
                completion_text = substrb(message, 1, 240)
          where request_id = do_set_status_autonomous.request_id;

      end if;

      end if;

      commit;

      return ret_str;

  exception
    when others then
       rollback;
       ret_str := substrb(SQLERRM, 1, 80);
       return ret_str;
  end;

  function DO_AUTO_SET_STATUS_AUTONOMOUS(request_id IN number,
                                 status     IN varchar2,
                                 message    IN varchar2,
                                 interim    IN boolean default FALSE)
                        return varchar2 is
  PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    return DO_SET_STATUS_AUTONOMOUS(request_id,status,message,interim);
  end;

  function SET_STATUS_AUTONOMOUS(request_id IN number,
                                 status     IN varchar2,
                                 message    IN varchar2,
                                 interim    IN boolean default FALSE)
                        return varchar2 is
  begin

    if ( fnd_adg_support.is_standby )
    then
       return DO_SET_STATUS_AUTONOMOUS(request_id,status,message,interim);
    end if;

    return DO_AUTO_SET_STATUS_AUTONOMOUS(request_id,status,message,interim);

  end;




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
			          message IN  varchar2) return boolean is
    scode varchar2(1);
    ret_str varchar2(80) := null;
    req_id number;
  begin
      if (upper(status) = 'NORMAL') then
      scode := 'C';
    elsif (upper(status) = 'WARNING') then
      scode := 'G';
    elsif (upper(status) = 'ERROR') then
      scode := 'E';

    else
      fnd_message.set_name('FND', 'CONC-SCS BAD STATUS');
      fnd_message.set_token('STATUS', status);
      return FALSE;
    end if;

    if ( lengthb(message) > 240 ) then
       fnd_file.put_line( fnd_file.log, message);
    end if;

    req_id := fnd_global.conc_request_id;

    ret_str := set_status_autonomous(req_id, scode, message);

    -- if ret_str has some string that means some error otherwise return TRUE
    if ( nvl(lengthb(ret_str), 0 ) > 0 ) then
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', ret_str, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
              'FND_CONCURRENT.SET_COMPLETION_STATUS', FALSE);
      return FALSE;
    else
      return TRUE;
    end if;

  end set_completion_status;

  --
  -- Name
  --   Get_Request_Print_Options
  -- Purpose
  --   Returns the print options for a concurrent request in the
  --   form of a PLSQL table type Print_Options_Tbl_Typ.
  --   This function is required when multiple printers have been
  --   specified for the request.
  --
  function GET_REQUEST_PRINT_OPTIONS
               (request_id        IN number,
                number_of_copies OUT NOCOPY number,
                print_style      OUT NOCOPY varchar2,
                printer          OUT NOCOPY varchar2,
                save_output_flag OUT NOCOPY varchar2) return boolean is
  begin
    select number_of_copies, print_style, printer, save_output_flag
      into number_of_copies, print_style, printer, save_output_flag
      from fnd_concurrent_requests r
     where r.request_id = get_request_print_options.request_id;

     return TRUE;

  exception
    when others then
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS', FALSE);
      return FALSE;
  end get_request_print_options;

  --
  -- Name
  --   Get_Request_Print_Options
  -- Purpose
  --   Returns the print options for a concurrent request.
  -- Parameters
  --   request_id: The request_id for the concurrent request
  --   print_options: pl/sql table of print_options_tbl_typ
  --                  (see spec for type details)
  -- Returns
  --   The total number post-processing actions for printing
  --
  function GET_REQUEST_PRINT_OPTIONS
               (request_id        IN  number,
                print_options     OUT NOCOPY print_options_tbl_typ)
  return number is
  counter number := 0;
  cursor c1 is
    select p.number_of_copies, r.print_style,
           p.arguments, r.save_output_flag
      from fnd_concurrent_requests r,
           fnd_conc_pp_actions p
     where r.request_id = p.concurrent_request_id
       and p.action_type = 1
       and p.concurrent_request_id = get_request_print_options.request_id
  order by sequence;
  begin
      for c1_data in c1 loop
         counter := counter + 1;
         print_options(counter).number_of_copies := c1_data.number_of_copies;
         print_options(counter).print_style := c1_data.print_style;
         print_options(counter).printer := c1_data.arguments;
         print_options(counter).save_output_flag := c1_data.save_output_flag;
      end loop;
      return counter;

  exception
    when others then
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS', FALSE);
      return counter;
  end get_request_print_options;

  --
  -- Name
  --   Check_Lock_Contention
  -- Purpose
  --   Identifies the process that is holding the lock(s) on resources
  --   that are needed by the process identified by the Queue Name or
  --   Session ID parameter.
  --
  function Check_Lock_Contention
               (Queue_Name       IN  varchar2 default NULL,
                Session_ID       IN  number   default NULL,
                UProcess_ID     OUT NOCOPY number,
	        UTerminal       OUT NOCOPY varchar2,
		UNode           OUT NOCOPY varchar2,
                UName           OUT NOCOPY varchar2,
                UProgram        OUT NOCOPY varchar2) return boolean is
  C_SessionID  number := Session_ID;
  P_ProcessID  number;
  begin

    UProcess_ID  := NULL;
    UTerminal    := NULL;
    UNode        := NULL;
    UName        := NULL;
    UProgram     := NULL;

  -- If session id is not null skip this step else
  -- Get session id based on queue name.
  --
  if (C_SessionID is NULL ) then
     Select Session_ID
       into C_SessionID
       from fnd_concurrent_processes cp,
	    fnd_concurrent_queues cq
      where  process_status_code = 'A'
	and  cp.Queue_Application_ID = cq.application_ID
        and cp.concurrent_queue_id  = cq.concurrent_queue_id
	and cq.concurrent_queue_name = Queue_Name;

	if (Sql%NotFound) then
	    Fnd_Message.Set_Name('FND', 'CP-Need valid manager name');
	    return FALSE;
	end if;
  end if;

  -- Check for resource/locks that process with session id C_SessionID
  -- is waiting for
  --

      select SH.OSUSER,
    	     SH.PROCESS,
	     SH.MACHINE,
             SH.TERMINAL,
             SH.PROGRAM
       into UName, UProcess_ID, UNode, UTerminal, UProgram
       from V$SESSION SH,
            V$LOCK LW,
            V$LOCK LH,
            V$SESSION SW
      where LH.SID = SH.SID
        and LH.SID <> SW.SID
        and LH.ID1 = LW.ID1
        and LH.ID2 = LW.ID2
        and LW.KADDR = SW.LOCKWAIT
        and SW.LOCKWAIT is not null
        and SW.AUDSID = C_SessionID;

	return TRUE;

  exception
    when no_data_found then
      UProcess_ID  := NULL;
      UTerminal    := NULL;
      UNode        := NULL;
      UName        := NULL;
      UProgram     := NULL;
      return TRUE;

    when others then
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.Check_Lock_Contention', FALSE);
      return FALSE;

  end Check_Lock_Contention;

  --
  -- Name
  --   get_program_attributes
  -- Purpose
  --   Returns the print options for a concurrent program.
  --
  -- Short term usage - only known users are from AP
  function GET_PROGRAM_ATTRIBUTES
               (appl_shortname IN varchar2 default NULL,
		program        IN varchar2 default NULL,
		printer     OUT NOCOPY varchar2,
		style       OUT NOCOPY varchar2,
	    save_output OUT NOCOPY varchar2) return boolean IS

	 ltype   varchar2(8) := 'YES_NO';
  begin
    select PRINTER_NAME, user_printer_style_name, l.meaning
      into printer, style, save_output
      from fnd_concurrent_programs p, fnd_printer_styles_VL ps,
	   fnd_lookups L, fnd_application_vl A
     where
	    l.lookup_code          = p.SAVE_OUTPUT_FLAG
	and l.lookup_type          = ltype
	and ps.printer_style_name  = p.OUTPUT_PRINT_STYLE
 	and p.application_id 	  = a.application_id
	and p.concurrent_program_name = program
	and a.application_short_name  = appl_shortname;

	if (Sql%NotFound) then
	    Fnd_Message.Set_Name('FND', 'CONC-Invalid Appl/Prog combo');
	    return FALSE;
	end if;

     return TRUE;

  exception
    when others then
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES', FALSE);
      return FALSE;
  end get_program_attributes;

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

  PROCEDURE init_request is
    csid   number;	   -- Auditing session ID
    cpid   number;	   -- Oracle process identifier
    cspid  varchar2(30);   -- client process os pid
    csspid varchar2(30);   -- Shadow process os pid
    codeset varchar2(30);  -- NLS_CodeSet
    optmode varchar2(30);  -- Optimizer mode
    que_rcg varchar2(32);
    prg_rcg varchar2(32);
    new_rcg varchar2(32);
    old_rcg varchar2(32);
    program_name varchar2(30);
    plog    varchar2(56);
    pout    varchar2(56);
    pdir    varchar2(255);
    etstat  varchar2(4) := Null;
    etrace  varchar2(4) := Null;
    rtrace  char;
    ptrace  char;
    emethod varchar2(1);
    ret_val boolean;
    dbg_comp varchar2(30);
    morg_cat varchar2(1) := null;
    orgid    number;
    l_request_id number;
    temp varchar2(100);
    lmessage varchar2(2000);
    cssid    number;  --bug16564651

    FND_MESSAGE_RAISED_ERR EXCEPTION;
    pragma exception_init(FND_MESSAGE_RAISED_ERR, -20001);

  begin

    if (fnd_global.conc_request_id > 0) then

       if ( fnd_adg_support.is_standby )
       then
$if fnd_adg_compile_directive.enable_rpc
$then

		       Select P.PID, P.SPID, AUDSID, PROCESS,
			substr(userenv('LANGUAGE'),
			    instr( userenv('LANGUAGE'), '.') + 1)
		      Into cpid, csspid, csid, cspid, codeset
			 From V$Session S, V$Process P,
			      (select distinct sid from v$mystat ) m
			Where P.Addr = S.Paddr
			  and s.sid = m.sid;

		       l_request_id := fnd_global.conc_request_id;

		       update fnd_concurrent_requests_remote
		       set ORACLE_SESSION_ID = csid,
			   ORACLE_PROCESS_ID = csspid,
			   OS_PROCESS_ID     = cspid,
			   NLS_CodeSet       = codeset
			where request_id = l_request_id;

$else
       null;
$end
       else
    --bug16564651
            select userenv('SID'), userenv('PID')
                  into cssid, cpid
                  from dual;

            select
                /*+ leading (S.S S.W S.E P) use_nl(S.S. S.W S.E P)
                    opt_param('_optimizer_sortmerge_join_enabled','FALSE') */
                P.SPID, AUDSID, PROCESS,
                substr(userenv('LANGUAGE'),
                    instr( userenv('LANGUAGE'), '.') + 1)
              into csspid, csid, cspid, codeset
              from V$Session S, V$Process P
             where P.Addr = S.Paddr
               and S.SID = cssid
               and P.PID = cpid;

	       update fnd_concurrent_requests
	          set ORACLE_SESSION_ID = csid,
		      ORACLE_PROCESS_ID = csspid,
		      OS_PROCESS_ID     = cspid,
                      NLS_CodeSet       = codeset
   	        where request_id = fnd_global.conc_request_id;
        end if;

              -- DOING COMMIT HERE SO THAT GUI TOOLS GET THE SESSION INFO
             -- DURING PROGRAM EXECUTION.

             commit;

	     begin
                select P.Optimizer_Mode, P.CONCURRENT_PROGRAM_NAME,
                       upper(P.enable_Trace),   upper(R.enable_trace),
                       Decode(upper(P.ENABLE_TIME_STATISTICS),'Y','TRUE',NULL),
		       execution_method_code,
                       multi_org_category, org_id, p.application_id
                  into optmode, program_name, ptrace, rtrace, etstat, emethod,
                       morg_cat, orgid, temp
      	          from FND_CONCURRENT_PROGRAMS P,
      	   	       FND_CONCURRENT_REQUESTS R
      	         WHERE P.CONCURRENT_PROGRAM_ID  = R.CONCURRENT_PROGRAM_ID
	           And P.APPLICATION_ID = R.Program_APPLICATION_ID
                   And R.request_id = fnd_global.conc_request_id;
             exception
		when others then
		   optmode := null;
		   program_name := null;
             end;

             if ( ptrace = 'Y' OR rtrace = 'Y') then
                  etrace := 'TRUE';
             end if;

             /* bug 3657332 */
             if ( optmode <> 'FIRST_ROWS' ) then
                optmode := NULL;
             end if;

	     FND_CTL.FND_SESS_CTL(Null, optmode, etrace, etstat, Null, Null);

	     dbms_application_info.set_module(program_name,
						'Concurrent Request');
	     select lower(application_short_name) || '/' || upper(program_name) into temp
	     from fnd_application where application_id = temp;

	     fnd_global.tag_db_session('cp', temp);

             Select plsql_log, plsql_out, plsql_dir
	       Into plog, pout, pdir
               From Fnd_Concurrent_Processes P, Fnd_Concurrent_Requests R
              Where P.Concurrent_Process_ID = R.Controlling_Manager
	        And R.Request_ID = fnd_global.conc_request_id;

             fnd_file.put_names(plog, pout, pdir);
             fnd_file_private.put_names(plog, pout, pdir);

	     begin
	         mo_global.init('M');
	         -- initialize Multi-Org Context
	         if ( morg_cat = 'S' ) then
	            mo_global.set_policy_context(morg_cat, orgid);
	         elsif ( morg_cat = 'M' ) then
	            mo_global.set_policy_context(morg_cat, null);
	         end if;
	     exception
	        when FND_MESSAGE_RAISED_ERR then
	           lmessage := fnd_message.get;
	           fnd_file.put_line(fnd_file.log, lmessage);
	        when others then
	           oraerrmesg := substr(SQLERRM, 1, 80);
	           Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
	           Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
	           Fnd_Message.Set_Token('ROUTINE', 'FND_CONCURRENT.INIT_REQUEST', FALSE);
	     end;

	     begin
   	     	select Q.RESOURCE_CONSUMER_GROUP
             	into que_rcg
   	     	from fnd_concurrent_requests r,
		     fnd_concurrent_processes p,
		     fnd_concurrent_queues q
             	where R.request_id = fnd_global.conc_request_id
		  and R.controlling_manager = P.concurrent_process_id
		  and Q.CONCURRENT_QUEUE_ID= P.CONCURRENT_QUEUE_ID
   	     	  and Q.APPLICATION_ID  = P.QUEUE_APPLICATION_ID;
             exception
   		when others then
     			que_rcg := null;
  	     end;

  	     begin
   		select p.RESOURCE_CONSUMER_GROUP
   		into prg_rcg
   		from fnd_concurrent_programs P,
   		fnd_concurrent_requests R
   		where R.request_id = fnd_global.conc_request_id
   		and r.PROGRAM_APPLICATION_ID = P.APPLICATION_ID
   		and R.CONCURRENT_PROGRAM_ID = P.CONCURRENT_PROGRAM_ID;
  	     exception
   		when others then
     			prg_rcg := null;
	     end;

  	     if prg_rcg is not null then
    		new_rcg := prg_rcg;
  	     elsif que_rcg is not null then
    		new_rcg := que_rcg;
  	     else
    		new_rcg := 'DEFAULT_CONSUMER_GROUP';
  	     end if;

	     begin
        	dbms_session.switch_current_consumer_group(new_rcg,
								old_rcg,false);
             exception when others then null;
  	     end;

             if ( not fnd_adg_support.is_standby )
             then
	     begin
                dbg_comp := fnd_debug_rep_util.get_program_comp(emethod);

                -- ignore return value from fnd_debug.
		ret_val := fnd_debug.enable_db_rules(comp_type => dbg_comp,
					  comp_name => program_name,
					  comp_appl_id => null,
					  comp_id   => null,
					  req_id => fnd_global.conc_request_id);
             end;
    end if;
    end if;

    return;

  exception
    when others then
      oraerrmesg := substr(SQLERRM, 1, 80);
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
	      'FND_CONCURRENT.INIT_REQUEST', FALSE);
      fnd_adg_support.log_unhandled_exception('fnd_concurrent.init_request',SQLERRM);
      return;

  end init_request;


  --
  -- Name
  --   FND_CONCURRENT.SET_PREFERRED_RBS
  -- Purpose
  --   Called from afpirq, etc to set the Rollback Segment associated with req.
  --
  -- Arguments (input)
  --
  -- Returns:

  Procedure SET_PREFERRED_RBS is

    RBS varchar2(101);  --  Rollback segment.
    sql_stmt varchar2(101);

  begin
    select P.Rollback_Segment
      into RBS
      from FND_CONCURRENT_PROGRAMS P,
      FND_CONCURRENT_REQUESTS R
      WHERE R.request_id = fnd_global.conc_request_id
      AND R.CONCURRENT_PROGRAM_ID  = P.CONCURRENT_PROGRAM_ID
      And R.PROGRAM_APPLICATION_ID = P.APPLICATION_ID;

    if RBS is not Null then
        sql_stmt := 'Set Transaction Use Rollback Segment '|| RBS;
        commit;
        execute immediate sql_stmt;
    end if;

    return;

  exception
    when others then
      return;

  end SET_PREFERRED_RBS;

--
  -- Name
  --   Fnd_Concurrent.Reset_Context
  -- Purpose
  --   To reset/re-establish context that may have been lost due to commits
  --
  -- Arguments (input)
  --
  -- Returns:

  function Reset_Context(Request_ID IN number default NULL) return boolean is

  g_request_id  number := NULL;

  begin
    --
    -- Use request id from global context if one exists, else
    -- use the one provided by the caller (security hole?)
    --
    g_request_id := fnd_global.conc_request_id;

    if (g_request_id is null) then
	g_request_id := Request_Id;
    end if;

    Fnd_Concurrent.Set_Preferred_RBS;

    return TRUE;

  exception
    when others then
      return TRUE;

  end Reset_Context;

  -- Name
  --   FND_CONCURRENT.AF_COMMIT
  -- Purpose
  --   It does the commit and set the preferred rollback segment for the
  --   program. Call this routine only in the concurrent program context.
  --
  -- Arguments (input)
  --
  -- Returns:

  Procedure AF_COMMIT is
  Begin
     -- do the commit first
     commit;

     -- if the context is concurrent program then set the rollback segment to
     -- program preferred
     if (fnd_global.conc_request_id > 0) then
        fnd_concurrent.set_preferred_rbs;
     end if;

  End AF_COMMIT;

  -- Name
  --   FND_CONCURRENT.AF_ROLLBACK
  -- Purpose
  --   It does the rollback and set the preferred rollback segment for the
  --   program. Call this routine only in the concurrent program context.
  --
  -- Arguments (input)
  --
  -- Returns:

  Procedure AF_ROLLBACK is
  Begin
     -- do the rollback first
     rollback;

     -- if the context is concurrent program then set the rollback segment to
     -- program preferred
     if (fnd_global.conc_request_id > 0) then
        fnd_concurrent.set_preferred_rbs;
     end if;

  End AF_ROLLBACK;

  -- Name
  --   FND_CONCURRENT.SHUT_DOWN_PROCS
  -- Purpose
  --   Runs the pl/sql shutdown procedures stored in FND_EXECUTABLES
  --   with EXECUTION_METHOD_CODE = 'Z'.
  --
  --   Errors encountered during execution of stored procedures are
  --      logged to FND_EVENTS

  procedure shut_down_procs is
	errbuf      VARCHAR2(256);

        CURSOR c IS
           SELECT execution_file_name from fnd_executables
             where execution_method_code = 'Z';
     begin
        FOR c_rec IN c LOOP
        begin
          savepoint startpoint;
          EXECUTE IMMEDIATE 'begin ' || c_rec.execution_file_name || '; end;';
	EXCEPTION
          -- if error arises we want to continue executing the rest of the
          -- shutdowns
         WHEN OTHERS THEN
             rollback to startpoint;

	     errbuf := SQLERRM;
             if ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                fnd_message.set_name('FND', 'CONC-SHUTDOWN_ACTION_FAILURE');
	        fnd_message.set_token('PROCEDURE', c_rec.execution_file_name);
	        fnd_message.set_token('REASON', errbuf);
	        fnd_log.message(FND_LOG.LEVEL_ERROR, 'fnd.plsql.fnd_concurrent.shut_down_procs', FALSE);
             end if;
        end;
        END LOOP;

     end shut_down_procs;

  -- Name
  --   FND_CONCURRENT.SET_INTERIM_STATUS
  -- Purpose
  --   sets the requests phase_code, interim_status_code and completion_text
  --   this is used in Java Concurrent Programs.
  --
  -- Arguments (input)
  --   status           - 'NORMAL', 'WARNING', or 'ERROR'
  --   message          - Optional message
  --
  -- Returns:
  --   TRUE on success.  FALSE on error.
  --

  function set_interim_status (status  IN  varchar2,
                               message IN  varchar2) return boolean is

    req_id number;

  begin

    req_id := fnd_global.conc_request_id;
    return set_interim_status (req_id, status, message);

  end set_interim_status;

  -- Name
  --   FND_CONCURRENT.SET_INTERIM_STATUS
  -- Purpose
  --   sets the requests phase_code, interim_status_code and completion_text
  --   this is used in Java Concurrent Programs.
  --
  -- Arguments (input)
  --   request_id 	- Request id
  --   status           - 'NORMAL', 'WARNING', or 'ERROR'
  --   message          - Optional message
  --
  -- Returns:
  --   TRUE on success.  FALSE on error.
  --

  function set_interim_status (request_id IN number,
                               status  IN  varchar2,
                               message IN  varchar2) return boolean is
    scode varchar2(1);
    lmessage varchar2(2000);
    ret_str varchar2(80) := null;
    req_id number;
  begin

    -- these status codes from the afcp.h.
   req_id := fnd_global.conc_request_id;
   if (request_id <> req_id) then
       if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(fnd_log.level_statement,
                          'fnd.plsql.fnd_concurrent.set_interim_status',
                          'REQUEST_ID MISMATCH WARNING: setting status of request_id '||request_id||' to status '||status||'.  Current database (fnd_global) context request_id = '||req_id||' does not match parameter passed = '||request_id);
       end if;
   end if;



   if (upper(status) = 'NORMAL') then
      scode := 'N';
    elsif (upper(status) = 'WARNING') then
      scode := 'G';
    elsif (upper(status) = 'ERROR') then
      scode := 'E';
    elsif (upper(status) = 'PAUSED') then
      scode := 'W';
    else
      fnd_message.set_name('FND', 'CONC-SCS BAD STATUS');
      fnd_message.set_token('STATUS', status);
      return FALSE;
    end if;


    if ( (lengthb(message) = 0) and scode in ('G','E')) then
       fnd_message.set_name('FND', 'CONC-REQ RETURNED NO MESG');
       lmessage := fnd_message.get;
    elsif( (lengthb(message) = 0) and scode in ('W')) then
       fnd_message.set_name('FND', 'CONC_REQ REQUEST INFO');
       lmessage := message;
    else
       lmessage := message;
    end if;

    if ( lengthb(lmessage) > 240 ) then
       fnd_file.put_line( fnd_file.log, lmessage);
    end if;

    ret_str := set_status_autonomous(request_id, scode, lmessage, TRUE);

    -- if ret_str has some string that means some error otherwise return TRUE
    if ( nvl(lengthb(ret_str), 0 ) > 0 ) then
      Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
      Fnd_Message.Set_Token('ERROR', ret_str, FALSE);
      Fnd_Message.Set_Token('ROUTINE',
              'FND_CONCURRENT.SET_INTERIM_STATUS', FALSE);
      return FALSE;
    else
      return TRUE;
    end if;

  end set_interim_status;

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
  --   Table FND_CONCURRENT.REQUESTS_TAB_TYPE.
  --

  function get_sub_requests( p_request_id IN number)
       return requests_tab_type is
   CURSOR C1 is
    Select Request_Id, Completion_Text,
                    Phase.Lookup_Code p_lookup_code,
		    Status.Lookup_Code s_lookup_code,
                    Phase.Meaning p_meaning, Status.Meaning s_meaning
               From Fnd_Concurrent_Requests R,
                    Fnd_Concurrent_programs P,
                    Fnd_Lookups Phase,
                    Fnd_Lookups Status
              Where
                    Phase.Lookup_Type = PHASE_LOOKUP_TYPE
                AND Phase.Lookup_Code = Decode(Status.Lookup_Code,
                                    'H', 'I',
                                    'S', 'I',
                                    'U', 'I',
                                    'M', 'I',
                                    R.Phase_Code) AND
            Status.Lookup_Type = STATUS_LOOKUP_TYPE AND
            Status.Lookup_Code =
             Decode(R.Phase_Code,
             'P', Decode(R.Hold_Flag,          'Y', 'H',
                  Decode(P.Enabled_Flag,       'N', 'U',
                  Decode(Sign(R.Requested_Start_Date - SYSDATE),1,'P',
                  R.Status_Code))),
             'R', Decode(R.Hold_Flag,          'Y', 'S',
                  Decode(R.Status_Code,        'Q', 'B',
                                               'I', 'B',
                  R.Status_Code)),
                  R.Status_Code)
                And (R.Concurrent_Program_Id = P.Concurrent_program_ID AND
                     R.Program_Application_ID= P.Application_ID )
                And Parent_Request_Id = p_request_id;
   sub_reqs    requests_tab_type;
   i           number := 0;
   phase_code  varchar2(30);
   status_code varchar2(30);
   Dev_Phase   varchar2(30);
   Dev_Status  varchar2(30);
  begin
     FOR c1_rec in C1 LOOP
        i := i + 1;
	sub_reqs(i).request_id := c1_rec.request_id;
	sub_reqs(i).phase      := c1_rec.p_meaning;
    	sub_reqs(i).status     := c1_rec.s_meaning;
	sub_reqs(i).message    := c1_rec.completion_text;
	phase_code 	       := c1_rec.p_lookup_code;
   	status_code  	       := c1_rec.s_lookup_code;

	get_dev_phase_status(phase_code, status_code, dev_phase, dev_status);

        sub_reqs(i).dev_phase := Dev_Phase;
	sub_reqs(i).dev_status := Dev_Status;
     END LOOP;

     return sub_reqs;
  end get_sub_requests;

  -- Name
  --   FND_CONCURRENT.CHILDREN_DONE
  -- Purpose
  --   Examines all child requests of a given request id.  Returns TRUE if
  --   all have completed.  Does not consider grandchildren or parent
  --
  -- Arguments (input)
  --   Parent_Request_ID- Request Id for which sub-requests are required. Null
  --                            will be interpreted as current req_id.
  --   Recursive_Flag   - Shall we look for grandchildren, etc.?
  --
  --   Interval       	- If Timeout>0, then we sleep this many seconds
  --                            between queries (default 60)
  --   Max_Wait		- if > 0 and children not done, we will wait up to Max_Wait
  --				seconds before responding FALSE

  function CHILDREN_DONE(Parent_Request_ID IN NUMBER default NULL,
                               Recursive_Flag in varchar2 default 'N',
                               Interval IN number default 60,
                               Max_Wait IN number default 0) return boolean is

    kount number;
    end_of_time date;
    time_left number;
    parent_req_id number;
    cursor kidslist(parent_id number) is
	Select request_id
	from fnd_concurrent_requests
	where parent_request_id = parent_id;

  begin
    Select sysdate + (greatest(Max_Wait, 0)/86400)
    into end_of_time
    from dual;

    Select NVL(Parent_Request_ID,FND_GLOBAL.CONC_REQUEST_ID)
      into parent_req_id
      from dual;

    if (parent_req_id = -1) then return TRUE; end if;

    LOOP
      Select count(*) into kount
      from fnd_concurrent_requests
      where parent_request_id = parent_req_id
        and phase_code <> 'C';

      if (kount = 0) AND (Recursive_Flag = 'Y') then -- check for kids
        for kidreq in kidslist(parent_req_id) loop
           if (NOT CHILDREN_DONE(kidreq.request_id, 'Y', 0, 0) ) then
		kount := 1;
		exit;
	   end if;
	end loop;
      end if;

      /* if we haven't found one then exit */
      if (kount = 0) then return TRUE; end if;

      /* otherwise return false if we have run out of time */
      select (end_of_time - sysdate) * 86400
      into time_left
      from dual;

      if (time_left <= Interval) then return FALSE; end if;

      /* If we still have time, take a nap before trying again */
      dbms_lock.sleep(Interval);
    end LOOP;

  end CHILDREN_DONE;

procedure register_node( name          varchar2,  /* Max 30 bytes */
                         platform_id   number,    /* Platform ID from BugDB */
                         forms_tier    varchar2,  /* 'Y'/'N' */
                         cp_tier       varchar2,  /* 'Y'/'N' */
                         web_tier      varchar2,  /* 'Y'/'N' */
                         admin_tier    varchar2,  /* 'Y'/'N' */
                         p_server_id   varchar2,  /* ID of server */
                         p_address     varchar2,  /* IP address of server */
                         p_description varchar2,
                         p_host_name   varchar2 default null,
                         p_domain      varchar2 default null,  /* description of server*/
			 db_tier       varchar2 default null, /* 'Y'/'N' */
                         p_virtual_ip  varchar2 default null  /* Virtual IP */  )

  is

  kount number;

begin
	/*
	* Create node.  If it already exists,then we'll Update instead
	*/
	select count(*)
	into kount
	from fnd_nodes
	where upper(node_name) = upper(name);

	if (kount = 0) then
		insert into fnd_nodes
			(node_id, node_name,
			 support_forms, support_cp, support_web, support_admin,
			 platform_code, created_by, creation_date,
			 last_updated_by, last_update_date, last_update_login,
			 node_mode, server_id, server_address, description,
                         host, domain,support_db, virtual_ip)
		select
			fnd_nodes_s.nextval, name,
			forms_tier, cp_tier, web_tier, admin_tier,
			platform_id, 1, SYSDATE,
			1, SYSDATE, 0,
			'O', p_server_id, p_address, p_description,
                        p_host_name, p_domain,db_tier, p_virtual_ip
		from dual;
	else
		/*
		* Node exists already.
		* Allow for the case where multiple APPL_TOPs
		* are installed on the same node for the same
		* Apps system, but for different tiers.  Essentially,
		* we're performing an 'OR' of the flags in the table
		* and those passed into the procedure.
		*/
		update fnd_nodes set
			description   = p_description,
			support_forms = decode(forms_tier, 'Y', 'Y', support_forms),
			support_cp    = decode(cp_tier,    'Y', 'Y', support_cp),
			support_web   = decode(web_tier,   'Y', 'Y', support_web),
			support_admin = decode(admin_tier, 'Y', 'Y', support_admin),
			platform_code = platform_id,
			last_update_date = SYSDATE, last_updated_by = 1,
                        host          = p_host_name,
                        domain        = p_domain,
			support_db    = decode(db_tier,'Y','Y',support_db)
		where upper(node_name) = upper(name);

		-- If server_id is not null, update fnd_nodes.server_id.
		-- fnd_nodes.server_id can only be null if the application server node has been
		-- removed.
 		if (p_server_id is not null) then
			update fnd_nodes
			set server_id = p_server_id
			where upper(node_name) = upper(name);
		end if;

		-- If server_address is not null, update fnd_nodes.server_address.
		if (p_address is not null) then
			update fnd_nodes
			set server_address = p_address
			where upper(node_name) = upper(name);
		end if;

                -- if p_virtual_ip is not null update the fnd_node.virtual_ip
		if (p_virtual_ip is not null) then
		        update fnd_nodes
			set virtual_ip = p_virtual_ip
			where upper(node_name) = upper(name);
                end if;
	end if;
end register_node;

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
                         return Service_Instance_Tab_Type is

   svc_id          number;
   CURSOR C1 is
     select APPLICATION_SHORT_NAME c_appl_short_name,
                    CONCURRENT_QUEUE_NAME c_svc_name,
		    RUNNING_PROCESSES c_run_procs,
		    MAX_PROCESSES c_max_procs,
                    CONTROL_CODE c_ctrl_code,
                    ENABLED_FLAG c_enabled
               from FND_CONCURRENT_QUEUES fcq,
                    FND_CP_SERVICES fcs,
                    FND_APPLICATION fa
              where
                    fcq.MANAGER_TYPE = to_char(fcs.SERVICE_id)
                and fcq.application_id = fa.application_id
                and fcs.SERVICE_ID = svc_id;
   svc_inst_inf   Service_Instance_Tab_Type;
   i               number := 0;
   user_error      varchar2(255);      -- to store translated file_error

  begin

      -- Validate service type

      begin
      select SERVICE_ID
      into svc_id
      from FND_CP_SERVICES
      where SERVICE_HANDLE = upper(svc_handle);
      exception
        when no_data_found then
          fnd_message.set_name('FND', 'CONC-SM INVALID SVC HANDLE');
          fnd_message.set_token('HANDLE', svc_handle);
          user_error := substrb(fnd_message.get, 1, 255);
          raise_application_error(-20100, user_error);
      end;


      FOR c1_rec in C1 LOOP
        i := i + 1;
        svc_inst_inf(i).Service_Handle        := upper(svc_handle);
	svc_inst_inf(i).Application           := c1_rec.c_appl_short_name;
	svc_inst_inf(i).Instance_Name         := c1_rec.c_svc_name;

        svc_inst_inf(i).State := get_svc_state(c1_rec.c_enabled,
                                               c1_rec.c_ctrl_code,
                                               c1_rec.c_run_procs,
                                               c1_rec.c_max_procs);
     END LOOP;

     return svc_inst_inf;
  end Get_Service_Instances;

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
           return Service_Process_Tab_Type is

   ltype   varchar2(32) := 'CP_PROCESS_STATUS_CODE';

   CURSOR C1 is
     select CONCURRENT_PROCESS_ID c_cpid,
                    MEANING c_state,
                    fcp.NODE_NAME c_node,
                    fcp.SERVICE_PARAMETERS c_parameters
               from FND_CONCURRENT_QUEUES fcq,
                    FND_CONCURRENT_PROCESSES fcp,
                    FND_APPLICATION fa,
                    FND_LOOKUP_VALUES_VL flv
              where
                    fcp.QUEUE_APPLICATION_ID   = fcq.APPLICATION_ID
                and fcp.CONCURRENT_QUEUE_ID    = fcq.CONCURRENT_QUEUE_ID
                and fcq.APPLICATION_ID         = fa.APPLICATION_ID
                and flv.LOOKUP_TYPE            = ltype
                and flv.LOOKUP_CODE            = fcp.PROCESS_STATUS_CODE
                and fa.APPLICATION_SHORT_NAME  = upper(appl_short_name)
                and fcq.CONCURRENT_QUEUE_NAME  = upper(svc_instance_name)
                and ((proc_state is not null)
                      or (fcp.PROCESS_STATUS_CODE not in ('S', 'K', 'U')))
                and exists
                    (select 1
                     from fnd_lookup_values flv2
                     where flv2.LOOKUP_TYPE = ltype
                     and flv2.LOOKUP_CODE = fcp.PROCESS_STATUS_CODE
                     and upper(flv2.meaning) =
                                   upper(nvl(proc_state,flv2.meaning)));

   svc_proc_inf    Service_Process_Tab_Type;
   i               number := 0;
   user_error      varchar2(255);      -- to store translated file_error

  begin

      -- Validate service application and name
      begin
        select 0
               into i
               from FND_CONCURRENT_QUEUES fcq,
                    FND_APPLICATION fa
              where fcq.APPLICATION_ID = fa.APPLICATION_ID
                and APPLICATION_SHORT_NAME = upper(appl_short_name)
                and upper(CONCURRENT_QUEUE_NAME) = upper(svc_instance_name);
      exception
        when no_data_found then
          fnd_message.set_name('FND', 'CONC-SM INVALID SVC INSTANCE');
          fnd_message.set_token('APPLICATION', appl_short_name);
          fnd_message.set_token('INSTANCE', svc_instance_name);
          user_error := substrb(fnd_message.get, 1, 255);
          raise_application_error(-20100, user_error);
      end;

      FOR c1_rec in C1 LOOP

        i := i + 1;
              svc_proc_inf(i).CPID       := c1_rec.c_cpid;
              svc_proc_inf(i).State      := c1_rec.c_state;
              svc_proc_inf(i).Node       := c1_rec.c_node;
              svc_proc_inf(i).Parameters := c1_rec.c_parameters;

     END LOOP;

     return svc_proc_inf;
  end Get_Service_Processes;

  -- Name
  --   FND_CONCURRENT.MSC_MATCH_BY_SERVICE_TYPE
  -- Purpose
  --   internal function used to find matches of svc cntl requests and
  --   Service types. returns 1 for a match, 0 for no.

  function MSC_MATCH_BY_SERVICE_TYPE(requestid number, mtype number)
	return number is

  rarg1 number;
  rarg2 number;
  rarg3 number;
  kount number;

  begin
    /* get request arguments. Last sane thing we do before the arbitrary
       ugly piece of coding where we decipher if we have a hit */

    select argument1, argument2, argument3
	into rarg1, rarg2, rarg3
	from fnd_concurrent_requests R
	where requestid = R.request_id;

    /* CASE positive : old style requests */
    if (rarg1 >= 0)  then

      select count(concurrent_queue_id)
        into kount
      from fnd_concurrent_queues
      where concurrent_queue_id = rarg1
        and application_id = rarg2
        and manager_type = mtype;

      if ((kount > 0) or (rarg1 = 1)) then return 1;
      else return 0;
      end if;


    /* CASE -1 : By app id */
    elsif ((rarg1 = -1) and (
           /* either CM or TM and request is for mgrs (or both) */
           (((mtype = 1) or (mtype = 3)) and ((rarg3 = 0) or (rarg3 = 2)))
       or  /* or service and request is for services (or both) */
           ((mtype > 999) and ((rarg3 = 1) or (rarg3 = 2)))
       )) then


      select count(concurrent_queue_id)
        into kount
      from fnd_concurrent_queues
      where application_id = rarg2
        and manager_type = mtype;

      if (kount > 0) then return 1;
      else return 0;
      end if;



    elsif (rarg1 = -1) then
        return 0;

    /* CASE -2 : cp fun pak */
    elsif ((rarg1 = -2) and (mtype > 0) and (mtype < 6) and (mtype <> 2)) then
	return 1;
    elsif (rarg1 = -2) then
        return 0;

    /* CASE -3 : By service type */
    elsif ((rarg1 = -3) and ((mtype = rarg2) or (rarg2 = 0))) then
        return 1;
    elsif (rarg1 = -3) then
        return 0;

    /* CASE -4 : cp all */
    elsif ((rarg1 = -4) and (mtype < 1000)) then
	return 1;
    elsif (rarg1 = -4) then
        return 0;

    else -- for expansion...we'll assume no match.
        return 0;
    end if;

  end MSC_MATCH_BY_SERVICE_TYPE;

  -- Name
  --   FND_CONCURRENT.MSC_MATCH
  -- Purpose
  --   internal function used to find matches of svc cntl requests and services
  --   or managers. returns 1 for a match, 0 for no.

  function MSC_MATCH(requestid number,
	app_id number, que_id number, mtype number) return number is

  rarg1 number;
  rarg2 number;
  rarg3 number;

  begin
    if (que_id is null) then
	/* Deal with special case required for OAM */
	return MSC_MATCH_BY_SERVICE_TYPE(requestid, mtype);
    end if;

    /* get request arguments. Last sane thing we do before the arbitrary
       ugly piece of coding where we decipher if we have a hit */

    select argument1, argument2, argument3
	into rarg1, rarg2, rarg3
	from fnd_concurrent_requests R
	where requestid = R.request_id;

    /* CASE positive : old style requests */
    if ((rarg1 >= 0) and (rarg1 = que_id) and (rarg2 = app_id)) then
        return 1;
    elsif ((rarg1 >= 0) and (rarg1 = 1) and (rarg2 = 0)) then
        return 1;
    elsif (rarg1 >= 0) then
	return 0;

    /* CASE -1 : By app id */
    elsif ((rarg1 = -1) and (rarg2 = app_id) and (
           /* either CM or TM and request is for mgrs (or both) */
           (((mtype = 1) or (mtype = 3)) and ((rarg3 = 0) or (rarg3 = 2)))
       or  /* or service and request is for services (or both) */
           ((mtype > 999) and ((rarg3 = 1) or (rarg3 = 2)))
       )) then return 1;
    elsif (rarg1 = -1) then
        return 0;

    /* CASE -2 : cp fun pak */
    elsif ((rarg1 = -2) and (mtype > 0) and (mtype < 6) and (mtype <> 2)) then
	return 1;
    elsif (rarg1 = -2) then
        return 0;

    /* CASE -3 : By service type */
    elsif ((rarg1 = -3) and (mtype = rarg2)) then
        return 1;
    elsif (rarg1 = -3) then
        return 0;

    /* CASE -4 : cp all */
    elsif ((rarg1 = -4) and (mtype < 1000) ) then
	return 1;
    elsif (rarg1 = -4) then
        return 0;

    else -- for expansion...we'll assume no match.
        return 0;
    end if;

  end MSC_MATCH;
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
  --   Number of matching requests.
  --


  function find_pending_svc_ctrl_reqs(service_id in number,
				service_inst_id in number,
				req_list out NOCOPY varchar2)  return number is

  app_id	number 	:= null;
  kount		number	:= 0;
  my_service_id number  := service_id;

  Cursor C1 IS
	Select request_id
	from fnd_concurrent_requests R, fnd_concurrent_programs P
 	where r.phase_code = 'P'
        and p.application_id = r.PROGRAM_APPLICATION_ID
	and p.concurrent_program_id = r.concurrent_program_id
        and p.queue_control_flag = 'Y'
        and msc_match(request_id, app_id, service_inst_id, my_service_id) = 1
	order by request_id;

  begin
    req_list := '';

    If ((service_id is null) and (service_inst_id is null)) then
	/* all null case */
        return 0;
    elsif (service_id is null) then
        /* populate app and service id */
	select manager_type, application_id
	into my_service_id, app_id
	from fnd_concurrent_queues
	where concurrent_queue_id = service_inst_id;
    end if;

    /* find results */
    For C1REC in C1 Loop
	kount := kount + 1;

	if (kount = 0) then
          req_list := to_char(C1REC.request_id);
	else
	  req_list := req_list || ',' || to_char(C1REC.request_id);
	end if;
     End Loop;

     return kount;
  end find_pending_svc_ctrl_reqs;


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

 Function Find_SC_Conflict(reqid in number) return number is
  app_id        number  := null;
  kount         number  := 0;

  Cursor C1 IS
        Select R2.request_id
        from fnd_concurrent_requests R1,
	     fnd_concurrent_requests R2,
	     fnd_concurrent_programs P1,
             fnd_concurrent_programs P2,
             fnd_concurrent_queues Q,
             fnd_application A
        where r1.request_id = reqid
	  and P1.APPLICATION_ID = R1.PROGRAM_APPLICATION_ID
	  and P1.concurrent_program_id = R1.concurrent_program_id
	  and p1.queue_control_flag = 'Y'
	  and r2.request_id > r1.request_id
	  and P2.APPLICATION_ID = R2.PROGRAM_APPLICATION_ID
          and P2.concurrent_program_id = R2.concurrent_program_id
          and P2.concurrent_program_id <> 2
          and P2.concurrent_program_id <> 6
          and p2.queue_control_flag = 'Y'
          AND a.application_id = p2.application_id
          AND a.application_short_name = 'FND'
          and msc_match(reqid,
		Q.application_id, Q.concurrent_queue_id, Q.manager_type) +
            msc_match(R2.request_id,
		Q.application_id, Q.concurrent_queue_id, Q.manager_type) = 2
        order by R2.request_id;

  begin
    For C1REC in C1 Loop
        return C1REC.request_id;
    End Loop;

    return -1;
  end Find_SC_Conflict;

  -- Private Function
  Function private_check_for_sctl_done(goal_state varchar2,
	rarg1 number, rarg2 number, rarg3 number) return number is

  kount number;

  begin
    /* CASE positive : old style requests */
    if (rarg1 >= 0) then
      select count(concurrent_queue_id)
      into kount
      from fnd_concurrent_queues
      where concurrent_queue_id = rarg1
        and application_id = rarg2
	and ((Running_processes <> MAX_PROCESSES)
	    or ((goal_state is not null) and
		((CONTROL_CODE <> goal_state) or (CONTROL_CODE is null)))
	    or ((goal_state is null) and (CONTROL_CODE is null)));


    /* CASE -1 : By app id */
    elsif (rarg1 = -1) then
      select count(concurrent_queue_id)
      into kount
      from fnd_concurrent_queues
      where application_id = rarg2
	and (
           /* either CM or TM and request is for mgrs (or both) */
           (((manager_type = 1) or (manager_type = 3))
		and ((rarg3 = 0) or (rarg3 = 2)))
          or  /* or service and request is for services (or both) */
           ((manager_type > 999) and ((rarg3 = 1) or (rarg3 = 2))))
               and ((Running_processes <> MAX_PROCESSES)
            or ((goal_state is not null) and
                ((CONTROL_CODE <> goal_state) or (CONTROL_CODE is null)))
            or ((goal_state is null) and (CONTROL_CODE is null)));

    /* CASE -2 : cp fun pak */
    elsif (rarg1 = -2) then
      select count(concurrent_queue_id)
      into kount
      from fnd_concurrent_queues
      where manager_type IN ('1', '3', '4', '5')
        and ((Running_processes <> MAX_PROCESSES)
            or ((goal_state is not null) and
                ((CONTROL_CODE <> goal_state) or (CONTROL_CODE is null)))
            or ((goal_state is null) and (CONTROL_CODE is null)));


    /* CASE -3 : By service type */
    elsif (rarg1 = -3)  then
      select count(concurrent_queue_id)
      into kount
      from fnd_concurrent_queues
      where manager_type = to_char(rarg2)
        and ((Running_processes <> MAX_PROCESSES)
            or ((goal_state is not null) and
                ((CONTROL_CODE <> goal_state) or (CONTROL_CODE is null)))
            or ((goal_state is null) and (CONTROL_CODE is null)));

    /* CASE -4 : cp all */
    elsif (rarg1 = -4) then
      select count(concurrent_queue_id)
      into kount
      from fnd_concurrent_queues
      where manager_type < 1000
        and ((Running_processes <> MAX_PROCESSES)
            or ((goal_state is not null) and
                ((CONTROL_CODE <> goal_state) or (CONTROL_CODE is null)))
            or ((goal_state is null) and (CONTROL_CODE is null)));

    else -- for expansion...we'll assume not complete.
        kount := 1;
    end if;

    if (kount > 0) then return 0;
    else return 1; end if;

  end private_check_for_sctl_done;



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

  Function Wait_for_SCTL_Done(reqid in number,timeout in number)return number is
    mystart       date;
    done          number  := -1;  -- -1 = unrun, 0 = run, 2 = finished
    timesup	  number;
    r_app_id	  number;
    prog_id 	  number;
    r_phase	  varchar2(1);
    rarg1	  number;
    rarg2	  number;
    rarg3	  number;
    goal_state	  varchar2(1);

  begin
    /* start time */
    select sysdate
    into mystart
    from dual;

    /* get request info */
    begin
      select concurrent_program_id, program_application_id, phase_code,
		argument1, argument2, argument3, Decode(concurrent_program_id,
		0,null, 1,'E', 3, null, 4, 'X', 5, 'E', 7, 'P', 8, null, null)
	into prog_id, r_app_id, r_phase, rarg1, rarg2, rarg3, goal_state
        from fnd_concurrent_requests
       where request_id = reqid;
    exception
      when others then
       return SCTL_REQ_NOT_FOUND;
    end;

    /* take out the trash */
    if ((r_app_id <> 0) OR (prog_id = 2) OR (prog_id = 6) OR (prog_id < 0) OR
      (prog_id > 8)) then
	return SCTL_REQ_NOT_SUPPD;
    end if;

  LOOP
    /* see if we finished */
    if (Done = 0) then   -- request ran...let's see if everything done
       Done := private_check_for_sctl_done(goal_state, rarg1, rarg2, rarg3);
    end if;

    /* are we done? */
    if (Done = 1) then
	return SCTL_REQ_COMPLETED;
    end if;

    /* Let's see if there is a reason that we are not done */
    if (Done = 0) then
	if (Find_SC_Conflict(reqid) > -1) then
	    return SCTL_REQ_CONFLICTS;
	end if;
    end if;

    /* time out? */
    select ((sysdate - mystart) * 86400) - Timeout
        into timesup
        from dual;

    /* have we run yet? */
    select decode(phase_code, 'C', 0, -1)
	into Done
        from fnd_concurrent_requests
       where request_id = reqid;

    if ((timesup > 0) and (Done = 0)) then
	return SCTL_TIMEOUT_NOT_C;
    elsif (timesup > 0) then
	return SCTL_TIMEOUT_NOT_R;
    end if;

    dbms_lock.sleep(5);
  END LOOP;

  end Wait_for_SCTL_Done;

  Function SCTL_REQ_NOT_FOUND return number is
    begin
	return 1;
    end SCTL_REQ_NOT_FOUND;

  Function SCTL_REQ_NOT_SUPPD return number is
    begin
	return 2;
    end SCTL_REQ_NOT_SUPPD;

  Function SCTL_TIMEOUT_NOT_R return number is
    begin
	return 3;
    end SCTL_TIMEOUT_NOT_R;

  Function SCTL_REQ_CONFLICTS return number is
    begin
	return 4;
    end SCTL_REQ_CONFLICTS;

  Function SCTL_TIMEOUT_NOT_C return number is
    begin
	return 5;
    end SCTL_TIMEOUT_NOT_C;

  Function SCTL_REQ_COMPLETED return number is
    begin
	return 6;
    end SCTL_REQ_COMPLETED;


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

  Function Wait_For_All_Down(Timeout in number) return boolean is

  mystart	date;
  done		number	:= -1;
  icm_tgt 	number;
  icm_act 	number;
  icm_pmon	varchar2(255);
  icm_callstat	number;

  begin

    select sysdate
    into mystart
    from dual;


    LOOP
        /* check to see if the icm is down */
	get_manager_status(0,1,icm_tgt,icm_act,icm_pmon,icm_callstat);

        if ((icm_tgt = 0) and (icm_act = 0) and (icm_callstat = 0)) then
		return TRUE;
	end if;

	/* time out? */
        select ((sysdate - mystart) * 86400) - Timeout
        into done
        from dual;

        if (done > 0) then return FALSE;
        end if;

        dbms_lock.sleep(5);
    END LOOP;

  exception
       when others then
          oraerrmesg := substr(SQLERRM, 1, 80);
          Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
          Fnd_Message.Set_Token('ERROR', oraerrmesg, FALSE);
          Fnd_Message.Set_Token('ROUTINE',
              'FND_CONCURRENT.WAIT_FOR_ALL_DOWN', FALSE);
          return FALSE;
  end Wait_For_All_Down;


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
                               ) return varchar2 is


     action varchar2(255) := Prog;
     descr  varchar2(255) := null;
     detail varchar2(255) := null;

  begin
       begin
         select cp.USER_CONCURRENT_PROGRAM_NAME
         into action
         from fnd_concurrent_programs_vl cp, fnd_application a
           where cp.concurrent_program_name = prog
           AND cp.application_id = a.application_id
           AND a.application_short_name = 'FND';
       exception when others then
	 null;
       end;

       if (Arg1 >=0) then

         begin
           select USER_CONCURRENT_QUEUE_NAME
  	     into Detail
	     from fnd_concurrent_queues_vl
            where APPLICATION_ID = Arg2
	      and concurrent_queue_id = Arg1;
         exception
	   when others then
		Detail := 'QID = ' || to_char(Arg1);
         end;

         Fnd_Message.Set_Name('FND', 'CP-MultiQC OldStyle');
         Fnd_Message.Set_Token('ACTION', action, FALSE);
         Fnd_Message.Set_Token('QUEUE', detail, FALSE);
         Descr := Fnd_Message.get;

	 return Descr;

      elsif (Arg1 = -1) then
         begin
           select APPLICATION_NAME
             into Detail
             from fnd_application_vl
            where APPLICATION_ID = Arg2;
         exception
           when others then
                Detail := 'APPID = ' || to_char(Arg2);
         end;

         Fnd_Message.Set_Name('FND', 'CP-MultiQC -1 ' || to_char(Arg3));
         Fnd_Message.Set_Token('ACTION', action, FALSE);
         Fnd_Message.Set_Token('APP', detail, FALSE);
         Descr := Fnd_Message.get;

         return Descr;

      elsif (Arg1 = -2) then

         Fnd_Message.Set_Name('FND', 'CP-MultiQC -2');
         Fnd_Message.Set_Token('ACTION', action, FALSE);
         Descr := Fnd_Message.get;

         return Descr;

      elsif (Arg1 = -3) then
         begin
           select SERVICE_NAME
             into Detail
             from fnd_cp_services_vl
            where SERVICE_ID = Arg2;
         exception
           when others then
                Detail := 'SVCID = ' || to_char(Arg2);
         end;

         Fnd_Message.Set_Name('FND', 'CP-MultiQC -3');
         Fnd_Message.Set_Token('ACTION', action, FALSE);
         Fnd_Message.Set_Token('SVC', detail, FALSE);
         Descr := Fnd_Message.get;

         return Descr;

      elsif (Arg1 = -4) then

         Fnd_Message.Set_Name('FND', 'CP-MultiQC -4');
         Fnd_Message.Set_Token('ACTION', action, FALSE);
         Descr := Fnd_Message.get;

         return Descr;


      else
	return Null;
      end if;

  end Build_Svc_Ctrl_Desc;

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
  Function Cancel_Request( Request_Id   in NUMBER,
                           Message      out NOCOPY VARCHAR2) return boolean is
    ret_val          number;
    submitter        number;
    request_missing  exception;
    no_privilege     exception;

  begin
     -- check this user got privilege to cancel request
     begin
       Select Requested_By
         into submitter
         from fnd_concurrent_requests
        where request_id = Cancel_Request.request_id;
     exception
        when no_data_found then
           raise request_missing;
     end;

     if ( submitter <> fnd_global.user_id ) then
        raise no_privilege;
     end if;

     ret_val :=  FND_AMP_PRIVATE.cancel_request(request_id, message);

     if ( ret_val = 0 ) then
       return FALSE;
     elsif ( ret_val = 1 ) then
       fnd_message.set_name('FND', 'CONC-Could not lock Request');
       message := fnd_message.get;
       return FALSE;
     elsif ( ret_val = 2 ) then
       fnd_message.set_name('FND', 'CONC-request completed');
       message := fnd_message.get;
       return FALSE;
     elsif ( ret_val = 3 ) then
       fnd_message.set_name('FND', 'CONC-cannot cancel mgr dead');
       message := fnd_message.get;
       return FALSE;
     elsif ( ret_val in (4,5)) then
       return TRUE;
     end if;

   exception
     when request_missing then
         fnd_message.set_name('FND', 'CONC-MISSING REQUEST');
         fnd_message.set_token('ROUTINE', 'FND_CONCURRENT.CANCEL_REQUEST');
         fnd_message.set_token('REQUEST', to_char(request_id));
         message := fnd_message.get;
         return FALSE;
     when no_privilege then
         fnd_message.set_name('FND', 'CONC-NOT OWNER OF REQUEST');
         fnd_message.set_token('REQUEST', to_char(request_id));
         message := fnd_message.get;
         return FALSE;
     when others then
         fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
         fnd_message.set_token('ROUTINE', 'FND_CONCURRENT.CANCEL_REQUEST');
         fnd_message.set_token('ERRNO', SQLCODE);
         fnd_message.set_token('REASON', SQLERRM);
         message :=  fnd_message.get;
         return FALSE;

  end Cancel_Request;

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
  --      1 - Timeout
  --      2 - Deadlock
  --      3 - Parameter error
  --      4 - Already own lock specified by lockhandle
  --      5 - Illegal lock handle
  --     -1 - Other exceptions, get the message from message stack for reason.

  function get_resource_lock ( resource_name in varchar2,
				timeout      in number default 2 )
			return number is
      hndl       varchar2(128);
      lk         varchar2(128);
      result     number := -1;
  begin

    lk := 'FND$_' || resource_name;

    dbms_lock.allocate_unique( lockname => lk,
				lockhandle => hndl );

    result := dbms_lock.request( lockhandle => hndl,
				 lockmode => 6,
				 timeout => timeout );

    return result;

    exception
     when others then
       fnd_message.set_name ('FND', 'CP-Generic oracle error');
       fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
       fnd_message.set_token ('ROUTINE', 'fnd_concurrent.get_resource_lock',
					FALSE);
       return result;

  end;

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

  function release_resource_lock ( resource_name in varchar2 ) return number is
      hndl       varchar2(128);
      lk         varchar2(128);
      result     number := -1;
  begin

    lk := 'FND$_' || resource_name;

    dbms_lock.allocate_unique( lockname => lk,
                                lockhandle => hndl );

    result := dbms_lock.release( lockhandle => hndl );

    return result;

    exception
     when others then
       fnd_message.set_name ('FND', 'CP-Generic oracle error');
       fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
       fnd_message.set_token ('ROUTINE', 'fnd_concurrent.release_resource_lock',
                                        FALSE);
       return result;

  end;







 --
  -- Name
  --   FND_CONCURRENT.INIT_SQL_REQUEST
  -- Purpose
  --   Called for all SQL*PLUS concurrent requests to perform request initialization.
  --

  procedure init_sql_request is

    creqid       number;
    session_id   number;
    userid       number;
    respid       number;
    respappid    number;
    secgrpid     number;
    siteid       number;
    loginid      number;
    cloginid     number;
    progappid    number;
    cprogid      number;
    cprireqid    number;
    counter      number := 0;

    lpid         v$session.process%type;
    lmachine     v$session.machine%type;
    position     number;
    ssid         number; --bug16564651

  begin

	-- Select all the information needed for this request from fnd_concurrent_requests,
	-- using the fnd_cp_sql_requests table.
	-- A row should have been inserted earlier in usdspid, containing the current request id,
	-- machine name, and process id.
	-- By joining these tables with v$session, we can pull out all the information we need,
	-- using only our own session id.
    begin


--bug16564651
select userenv('sid') into ssid from dual;

select /*+ use_nl (S.S S.W) index (S.S)
       opt_param('_optimizer_sortmerge_join_enabled','FALSE') */
       process, machine
  into lpid, lmachine
  from v$session
  where sid = ssid;


position := instr(lpid,':');
if ( position>0 ) then
	lpid := substr(lpid,1,position-1);
end if;

while counter <= 4 loop
  counter := counter + 1;
  begin
      select 0, fcr.requested_by,
             fcr.responsibility_id, fcr.responsibility_application_id,
             fcr.security_group_id, 0,
             fcr.requested_by, fcr.conc_login_id,
             fcr.program_application_id, fcr.concurrent_program_id,
             fcr.request_id, fcr.priority_request_id
      into session_id, userid, respid, respappid,
           secgrpid, siteid, loginid, cloginid,
           progappid, cprogid, creqid, cprireqid
      from fnd_concurrent_requests fcr,
           fnd_cp_sql_requests sr
      where fcr.phase_code = 'R'
      and   fcr.status_code = 'R'
      and   fcr.request_id = sr.request_id
      and   sr.machine = lmachine
      and   sr.client_process_id = lpid;

          fnd_global.bless_next_init('FND_PERMIT_0002');
	  FND_GLOBAL.INITIALIZE(session_id, userid, respid, respappid, secgrpid, siteid, loginid,
		                    cloginid, progappid, cprogid, creqid, cprireqid);

	  -- now delete the row, to avoid having to purge the table.
	  DELETE from fnd_cp_sql_requests where request_id = creqid;

      exit;
  exception
      when no_data_found then
         if (counter = 1) then
            DBMS_LOCK.sleep(5);
         elsif (counter > 1 and counter <= 4) then
            DBMS_LOCK.sleep(10);
         else
		-- no row found, most likely ran from the command line.
		-- Initialize a default context:
		-- USER = ANONYMOUS (-1)
		-- RESP = System Administrator (20420)
		-- RESP APPL = System Administration (1)
            FND_GLOBAL.APPS_INITIALIZE(-1, 20420, 1);
         end if;

  end;
end loop;

	-- The rest of the initialization used to be hardcoded into the SQL script by fdpsql().
    INIT_REQUEST;

    FND_PROFILE.PUT('SECURITY_GROUP_ID', FND_GLOBAL.SECURITY_GROUP_ID);

    SET_PREFERRED_RBS;

  exception
	 when others then

           if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      fnd_message.set_name ('FND', 'SQL-Generic error');
              fnd_message.set_token ('ERRNO', sqlcode, FALSE);
              fnd_message.set_token ('REASON', sqlerrm, FALSE);
              fnd_message.set_token ('ROUTINE', 'FND_CONCURRENT.INIT_SQL_REQUEST', FALSE);
              fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                             'fnd.plsql.FND_CONCURRENT.INIT_SQL_REQUEST.others', FALSE);
           end if;
  end;

end init_sql_request;

	--procedure debug(message in varchar2) is
	--	pragma autonomous_transaction;
	--	msg varchar2(2000);
	--	l_count number;
	--	begin

	--		insert into     FND_CONCURRENT_DEBUG_INFO(TIME, ACTION, message,  TIME_IN_NUMBER)
	--		 VALUES(sysdate,'FND_CONCURRENT.get_m_s',message,0);
	--commit;
	--end debug;


function check_user_privileges( p_user_name IN varchar2,
                                p_test_code IN varchar2 DEFAULT NULL) RETURN number IS
   l_user_id number := -1;
   l_resp_id number := -1;
   l_ret_value  number := 0;
   CURSOR l_user_csr(p_user_name  varchar2) IS
     SELECT user_id
       FROM fnd_user
       WHERE user_name = upper(p_user_name);
   CURSOR l_resp_csr(p_responsibility_key varchar2) IS
     SELECT responsibility_id
       FROM fnd_responsibility
       WHERE responsibility_key = p_responsibility_key;
     CURSOR l_user_resp_csr( p_user_id  number, p_responsibility_id  number)IS
     SELECT count(responsibility_id)
       FROM fnd_user_resp_groups
       WHERE user_id = p_user_id
       AND responsibility_id = p_responsibility_id;
BEGIN
   IF (p_test_code <> 'STARTMGR' and p_test_code <> 'RUNCONCPROG') THEN
      l_ret_value := -1;
      RETURN l_ret_value;
   END IF;

   OPEN l_user_csr(check_user_privileges.p_user_name);
   FETCH l_user_csr INTO l_user_id;
   CLOSE l_user_csr;

   OPEN l_resp_csr('SYSTEM_ADMINISTRATOR');
   FETCH l_resp_csr INTO l_resp_id;
   CLOSE l_resp_csr;

   IF (l_user_id <> -1 and l_resp_id <> -1) THEN
      OPEN l_user_resp_csr(l_user_id, l_resp_id);
      FETCH l_user_resp_csr INTO l_ret_value;
      CLOSE l_user_resp_csr;
   END IF;

   IF (l_user_id <> -1 and l_ret_value = 0) THEN
      OPEN l_resp_csr('FND_CM_OPERATOR_RESP');
      FETCH l_resp_csr INTO l_resp_id;
      CLOSE l_resp_csr;
      IF (l_resp_id <> -1) THEN
         OPEN l_user_resp_csr(l_user_id, l_resp_id);
         FETCH l_user_resp_csr INTO l_ret_value;
         CLOSE l_user_resp_csr;
      END IF;
   END IF;

   RETURN l_ret_value;
END check_user_privileges;

function check_program_privileges( p_user_name IN varchar2,
                                   p_resp_id IN number DEFAULT NULL,
                                   p_resp_appl_id IN number DEFAULT NULL,
                                   p_program_name IN varchar2,
                                   p_application_short_name IN varchar2,
                                   p_sec_group_id IN number ) RETURN number IS
   l_ret_value number := 0;
   l_application_id number;
   l_conc_program_id number;
   l_user_id  number := -1;
   l_srs_flag varchar2(1);
   l_predicate varchar2(9500);
   l_sql_stmt varchar2(10000);
   l_return_status varchar2(1);

   CURSOR l_user_resp_csr(p_user_id  number,
                          p_resp_id   number,
                          p_resp_appl_id  number,
                          p_sec_group_id  number)IS
     SELECT count(responsibility_id)
       FROM fnd_user_resp_groups
       WHERE user_id = p_user_id
       AND responsibility_id = p_resp_id
       AND responsibility_application_id = p_resp_appl_id
       AND security_group_id = p_sec_group_id;

   CURSOR l_user_csr(p_user_name  varchar2) IS
     SELECT user_id
       FROM fnd_user
       WHERE user_name = upper(p_user_name);

   CURSOR l_appl_id_csr(p_application_short_name  varchar2) IS
     SELECT application_id
       FROM fnd_application
       WHERE application_short_name = p_application_short_name;

   CURSOR l_prog_id_csr(p_program_name  varchar2,
                        p_application_id  number) IS
     SELECT concurrent_program_id, srs_flag
       FROM fnd_concurrent_programs
       WHERE concurrent_program_name = p_program_name
       AND application_id = p_application_id;

BEGIN
   OPEN l_user_csr(check_program_privileges.p_user_name);
   FETCH l_user_csr INTO l_user_id;
   CLOSE l_user_csr;

   OPEN l_appl_id_csr(p_application_short_name);
   FETCH l_appl_id_csr INTO l_application_id;
   CLOSE l_appl_id_csr;

   OPEN l_prog_id_csr(p_program_name, l_application_id);
   FETCH l_prog_id_csr INTO l_conc_program_id, l_srs_flag;
   CLOSE l_prog_id_csr;

   IF (l_application_id is not null and l_conc_program_id is not NULL
       AND l_user_id IS NOT null) THEN

      OPEN l_user_resp_csr(l_user_id, check_program_privileges.p_resp_id,
        check_program_privileges.p_resp_appl_id,
        check_program_privileges.p_sec_group_id);
      FETCH l_user_resp_csr INTO l_ret_value;
      CLOSE l_user_resp_csr;
      IF (l_ret_value = 0) THEN
         l_ret_value := -1;
         RETURN l_ret_value;
      END IF;
      l_ret_value := 0;

      --check IF this program is not SRS-enabled and IF true let it pass through
      IF (check_user_privileges(p_user_name, 'RUNCONCPROG') > 0 AND (l_srs_flag = 'N' OR l_srs_flag = 'Q')) THEN
         l_ret_value := 1;
      ELSIF (l_srs_flag = 'Y') THEN
        fnd_global.apps_initialize
          (user_id => l_user_id,
          resp_id => p_resp_id,
          resp_appl_id => p_resp_appl_id,
          security_group_id => p_sec_group_id);

        fnd_data_security.get_security_predicate
          (p_api_version => 1.0,
          p_function => 'FND_CP_REQ_SUBMIT',
          p_object_name => 'FND_CONCURRENT_PROGRAMS',
          x_predicate => l_predicate,
          x_return_status => l_return_status,
          p_table_alias => 'p');

        l_sql_stmt := 'select count(p.concurrent_program_id) from fnd_concurrent_programs p where p.concurrent_program_id = :1 and p.application_id = :2 and ' || l_predicate || '';

        execute immediate l_sql_stmt INTO l_ret_value using l_conc_program_id, l_application_id;

        IF (l_ret_value > 0) THEN
           l_ret_value := 1;
        ELSE
           l_ret_value := 0;
        END IF;

      END IF; --IF (l_srs...
   ELSE
      l_ret_value := -1;
   END IF; --IF l_application_id...

   RETURN l_ret_value;
END check_program_privileges;


end FND_CONCURRENT;

/

  GRANT EXECUTE ON "APPS"."FND_CONCURRENT" TO "EM_OAM_MONITOR_ROLE";
