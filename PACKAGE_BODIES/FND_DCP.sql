--------------------------------------------------------
--  DDL for Package Body FND_DCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DCP" as
/* $Header: AFCPDCPB.pls 120.5.12010000.5 2018/12/13 19:57:22 pferguso ship $ */

  --
  -- PRIVATE VARIABLES
  --

  DAY	   constant number	:= 86400;	-- In secs
  EON	   constant number	:= 86400000;	-- 1000 days in secs
  NTRUE	   constant number	:= 1;
  NFALSE   constant number	:= 0;
  SYSADMIN constant number	:= 0;
  MGRUSRID constant number	:= 4;
  THRSHLD  constant number	:= 2;		-- PMON method
  DEFSLEEP constant number	:= 60;		-- PMON method
  TSTAMP   constant number	:= 1;		-- PMON method
  FNDCPLK  constant varchar2(8) := 'FNDCPLK_';


  --
  -- PRIVATE PROCEDURES, FUNCTIONS
  --

  /* Private -- inserts info in FND_CONCURRENT_DEBUG_INFO */

  procedure debug_fnd_dcp (fn  in varchar2,
                           msg in varchar2,
                           txn in number default NULL) is
  pragma AUTONOMOUS_TRANSACTION;
  userid number;
  begin
   select user_id into userid from user_users;

   insert into fnd_concurrent_debug_info
     (SESSION_ID, USER_ID, LOGIN_ID, FUNCTION, TIME, ACTION, MESSAGE)
   values
     (userenv('SESSIONID'), userid, fnd_global.login_id, fn,
     sysdate, 'TXN NO '|| nvl(to_char(txn),'NULL'), msg);

   commit;

  end debug_fnd_dcp;

  function get_icm_info (logf in out nocopy varchar2,
			 node in out nocopy varchar2,
			 inst in out nocopy varchar2)
			 return number is

	cpid	number(15) := null;

  begin
	select concurrent_process_id,
               node_name,
	       logfile_name,
	       db_instance
	  into cpid,
               node,
	       logf,
	       inst
	  from fnd_concurrent_processes
	 where concurrent_process_id in (
			select max (concurrent_process_id)
			  from fnd_concurrent_processes
			 where queue_application_id = 0
			   and concurrent_queue_id  = 1
			   and process_status_code in ('A', 'M', 'K'));

        if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_EVENT, 'fnd.plsql.FND_DCP.GET_ICM_INFO',
                  'ICM info: cpid=' ||cpid||', node='||node||', inst=' ||inst);
        end if;

	return (cpid);

	exception
	  when others then
	    return (null);
  end get_icm_info;


  function get_pid_time (ti   in out nocopy number,	-- PMON method
			 td   in out nocopy number,
			 apid in     number,
			 qid  in     number,
			 psc1 in     varchar2 default null,
			 psc2 in     varchar2 default null,
			 psc3 in     varchar2 default null,
			 psc4 in     varchar2 default null)
			 return number is

	cpid	number(15) := null;

  begin
	select nvl (sleep_seconds, DEFSLEEP)
	  into ti
	  from fnd_concurrent_queues
	 where application_id      = apid
	   and concurrent_queue_id = qid;

	select concurrent_process_id,
	       (sysdate - last_update_date) * DAY
	  into cpid,
	       td
	  from fnd_concurrent_processes
	 where concurrent_process_id in (
			select max (concurrent_process_id)
			  from fnd_concurrent_processes
			 where queue_application_id = apid
			   and concurrent_queue_id  = qid
			   and process_status_code in (
					psc1, psc2, psc3, psc4))
	   for update nowait;

	return (cpid);

	exception
	  when others then
	    return (null);
  end get_pid_time;				-- PMON method

  -- ### OVERLOADED ###
  /*------------------------------------------------------------------|
   | Private: For use by ATG Only. Please use Check_Process_Status or |
   |          Request_Session_Lock                                    |
   |------------------------------------------------------------------|
   | Bug 2093806: The purpose of this overload for Request_Lock is    |
   | request a lock by a known handle and to offer more flexibility   |
   | for the call to DBMS_LOCK.Request.  This procedure accepts a     |
   | timeout value, and lock mode value.  Instead of interpreting the |
   | return code from DBMS_LOCK.Request as the  parameter "e_code" set|
   | to NTRUE (1) or NFALSE (0), the parameter "result" is set to the |
   | return code for interpretation by the calling function.  If      |
   | result = NULL, indicates when others exception was raised.       |
   |------------------------------------------------------------------*/
  procedure request_lock (hndl    in	 varchar2,
                          lmode   in     number   default null, -- lock mode
                          timeout in     number   default null,
			  result  in out nocopy number) is
  begin

        result := NULL;

        if ((timeout IS NULL) and (lmode IS NULL )) then
        /*-------------------------------------------------------+
         | When caller does not specify, use dbms_lock defaults, |
         | currently MAXWAIT (32767 secs) X_MODE (6-Exclusive)   |
         +-------------------------------------------------------*/
	  result := dbms_lock.request ( lockhandle => hndl );
        elsif (timeout IS NULL) then
          result := dbms_lock.request ( lockhandle => hndl,
                                        lockmode   => lmode );    -- MAXWAIT
        elsif (lmode IS NULL) then
          result := dbms_lock.request ( lockhandle  => hndl,
                                        timeout     => timeout ); -- ULX lock
        else
	  result := dbms_lock.request ( lockhandle  => hndl,
                                        lockmode    => lmode,
                                        timeout     => timeout);
        end if;

        /*-------------------------------------------------------+
         | DBMS_LOCK.Request Result codes:                       |
         | 0 - Success                                           |
         | 1 - Timeout                                           |
         | 2 - Deadlock                                          |
         | 3 - Parameter error                                   |
         | 4 - Already own lock specified by lockhandle          |
         | 5 - Illegal lock handle                               |
         +-------------------------------------------------------*/

  exception
     when others then
       fnd_message.set_name ('FND', 'CP-Generic oracle error');
       fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
       fnd_message.set_token ('ROUTINE', 'REQUEST_LOCK (hndl)', FALSE);
  end request_lock;

  --
  -- PUBLIC PROCEDURES, FUNCTIONS
  --

  procedure get_lk_handle (apid	  in     number,
			   qid	  in     number,
			   pid	  in     number,
			   hndl	  in out nocopy varchar2,
			   e_code in out nocopy number,
			   exp_sec in number default 86400000) is

	result	number;
	lk	varchar2(128);

  begin
	e_code := NTRUE;

	hndl := NULL;

	if (apid = 0 and qid = 1 and pid = 0) then
	  lk := FNDCPLK || 'ICM';
	else
	  lk := FNDCPLK || apid || '_' || qid || '_' || pid;
	end if;

	dbms_lock.allocate_unique (lk, hndl, exp_sec);

	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'get_lk_handle', FALSE);
  end get_lk_handle;

  /*------------------------------------------------------------------|
   | Bug 2093806: The purpose of Request_Session_Lock is to provide   |
   | an API which can be used for a manager process (ICM, CM, IM, CRM,|
   | TM) to request it's own lock for the session.  This procedure    |
   | is not meant to be used for a process (such as an Apps form, OAM |
   | procedure or ICM in PMON cycle) to check the lock of another     |
   | process.  This procedure will wait for the default of  MAXWAIT   |
   | for the RDBMS to grant the requested lock. If the parameters "lk"|
   | and "hndl" are returned as NULL, then there was a problem. The   |
   | calling process can analyze the "result" parameter to determine  |
   | why the request was not granted.                                 |
   |------------------------------------------------------------------*/
  procedure request_session_lock (apid	 in     number,
			          qid    in     number,
			          pid    in     number,
			          lk     in out nocopy varchar2,
			          hndl   in out nocopy varchar2,
			          result in out nocopy number) is
	ecode     number;
	timeout   number;
  begin
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.REQUEST_SESSION_LOCK',
                  'request_session_lock called for apid='||to_char(apid)||
                  ', qid='||to_char(qid)||', pid='||to_char(pid));
        end if;

        result := null;

        /*-------------------------------------------------------+
         | Construct the lock name for out parameter "lk" and    |
         | set timeout for Request_Lock.                         |
         +-------------------------------------------------------*/
	if (apid = 0 and qid = 1 and pid = 0) then
	  lk      := FNDCPLK || 'ICM';
          timeout := 5;     -- ICM only waits 5 secs for lock request.
	else
	  lk      := FNDCPLK || apid || '_' || qid || '_' || pid;
          timeout := null;  -- Others wait MAXWAIT for lock request.
	end if;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.REQUEST_SESSION_LOCK',
                  'lock name='||lk);
        end if;

        /*-------------------------------------------------------+
         | Get handle for the request.                           |
         +-------------------------------------------------------*/
        get_lk_handle (apid      => apid,
                       qid       => qid,
                       pid       => pid,
                       hndl      => hndl,
                       e_code    => ecode);
        if (ecode = NFALSE) then
        /*-------------------------------------------------------+
         | Message available in dictionary set by Get_Lk_Handle  |
         +-------------------------------------------------------*/
          lk   := null;
          hndl := null;
          return;
        else
          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.REQUEST_SESSION_LOCK',
                  'for lock name='||lk||' hndl='||hndl);
          end if;
        end if;

        /*-------------------------------------------------------+
         | Request with mode of exclusive (ULX), with timeout    |
         +-------------------------------------------------------*/
        request_lock (hndl    =>     hndl,
                      lmode   =>     6,
                      timeout =>     timeout,
                      result  =>     result);
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.REQUEST_SESSION_LOCK',
                  'result of request_lock: '||to_char(result));
        end if;

        if (result in (0, 4)) then
          return;
        else
          fnd_message.set_name ('FND', 'CONC-DBMS_LOCK.Request result');
          fnd_message.set_token ('ROUTINE',
                                 'FND_DCP.REQUEST_SESSION_LOCK', FALSE);
          fnd_message.set_token ('RESULT',
                                 nvl(to_char(result),'NULL'), FALSE);
          lk   := null;
          hndl := null;
          return;
        end if;

  end request_session_lock;

  /*------------------------------------------------------------------|
   | Bug 2093806: The purpose of Check_Process_Status_By_Handle is to |
   | provide an API which can be used for a process (such as an Apps  |
   | form, OAM procedure or ICM in PMON cycle) to check the lock of   |
   | another process (such as ICM, CM, IM, CRM, TM).  This procedure  |
   | will immediately time out if the RDBMS does not grant the lock.  |
   | If process is alive, alive = NTRUE(1). Otherwise, alive =        |
   | NFALSE(0).  Calling process can analyze the "result" parameter to|
   | determine  why/why not the lock was granted, if desired.         |
   |------------------------------------------------------------------*/
  procedure check_process_status_by_handle (hndl   in   varchar2,
                                            result out  nocopy number,
                                            alive  out  nocopy number) is

	dummy	    number;

  begin
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.CHECK_PROCESS_STATUS_BY_HANDLE',
                  'check_process_status_by_handle called for hndl='||hndl);
        end if;

        /*-------------------------------------------------------+
         | Request with mode of row share (ULRS), timeout of 0   |
         +-------------------------------------------------------*/
        request_lock (hndl    =>     hndl,
                      lmode   =>     2,
                      timeout =>     0,
                      result  =>     result);
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.CHECK_PROCESS_STATUS_BY_HANDLE',
                  'result of request_lock: '||to_char(result));
        end if;

        if (result = 0) then
            /*-------------------------------------------------------+
             | Lock for handle was granted                           |
             +-------------------------------------------------------*/
             alive := NFALSE;            -- manager not alive
             release_lock(hndl, dummy);
             return;
        elsif (result = 4) then
            /*-------------------------------------------------------+
             | This process owns the lock, it must be alive!         |
             +-------------------------------------------------------*/
             alive := NTRUE;
             release_lock(hndl, dummy);
             return;
        elsif (result in (1, 2)) then
            /*-------------------------------------------------------+
             | Lock for handle not granted (2 should never occur)    |
             +-------------------------------------------------------*/
             alive := NTRUE;             -- manager alive
             return;
        else
            /*-------------------------------------------------------+
             | Lock for handle not granted:                          |
             | result = (3 or 5 from DBMS_LOCK.Request or            |
             |          still NULL from Request_Lock                 |
             +-------------------------------------------------------*/
             alive := NTRUE;             -- assume manager alive
             fnd_message.set_name ('FND', 'CONC-DBMS_LOCK.Request result');
         fnd_message.set_token ('ROUTINE',
                                    'FND_DCP.CHECK_PROCESS_STATUS_BY_HANDLE',
                                    FALSE);
         fnd_message.set_token ('RESULT',
                                    nvl(to_char(result), 'NULL'), FALSE);

        end if;

  end check_process_status_by_handle;

  /*------------------------------------------------------------------|
   | Bug 2093806: The purpose of Check_Process_Status_By_Ids is to    |
   | provide an API which can be used for a process (such as an Apps  |
   | form, OAM procedure or ICM in PMON cycle) to check the lock of   |
   | another process (such as ICM, CM, IM, CRM, TM).  This procedure  |
   | uses the Application Id, Queue Id, and O/S Pid to construct the  |
   | named lock for the request. The procedure  will immediately time |
   | out if the RDBMS does not grant the lock.  If process is alive,  |
   | alive = NTRUE(1). Otherwise, alive = NFALSE(0). Calling process  |
   | can analyze the "result" parameter to determine why/why not the  |
   | lock was granted, if desired.                                    |
   |------------------------------------------------------------------*/
  procedure check_process_status_by_ids (apid    in     number,
                                         qid     in     number,
                                         pid     in     number,
                                         result  out    nocopy number,
                                         alive   out    nocopy number) is

        hndl        varchar2(128) := NULL;
	dummy	    number;

  begin

        /*-------------------------------------------------------+
         | Get handle for the request                            |
         +-------------------------------------------------------*/
        get_lk_handle (apid      => apid,
                       qid       => qid,
                       pid       => pid,
                       hndl      => hndl,
                       e_code    => dummy);

        /*-------------------------------------------------------+
         | Check the process' status by the handle               |
         +-------------------------------------------------------*/
        check_process_status_by_handle (hndl   => hndl,
                                        result => result,
                                        alive  => alive);

  end check_process_status_by_ids;


  -- ### OVERLOADED ###
  /*------------------------------------------------------------------|
   | Obsolete: Please use Request_Session_Lock, Check_Process_Status  |
   |           or Check_Process_Status_By_Handle                      |
   +------------------------------------------------------------------*/
  procedure request_lock (apid	in     number,
			  qid	in     number,
			  pid	in     number,
			  lk	in out nocopy varchar2,
			  hndl	in out nocopy varchar2,
			  e_code in out nocopy number) is

	result	number;
        count   number;

  begin
	e_code := NTRUE;

	if (apid = 0 and qid = 1 and pid = 0) then
	  lk := FNDCPLK || 'ICM';
	else
	  lk := FNDCPLK || apid || '_' || qid || '_' || pid;
	end if;

	dbms_lock.allocate_unique (lk, hndl, EON);
	result := dbms_lock.request (hndl, 6, 0);  -- ULX lock

	if (result in (0, 4)) then	-- Success or own lock
	  return;
	elsif (result in (1, 2)) then	-- Timeout or deadlock

          /* ------------------------------------------------------- */
          /* Bug 1967288: Timout occasionally returned when manager  */
          /* log backs into database with afpcsq(). So, try up to 2  */
          /* more times with 5 second timeout.                       */
          /* We cannot wait much longer since Forms and OAM use this */
          /* version of Request_Lock to check each manager's status  */
          /* This is a short-term fix until more robust restructuring*/
          /* can be done with lock management procedures, functions. */
          /* ------------------------------------------------------- */

	  for count in 1..2 loop
	    result := dbms_lock.request (hndl, 6, 5);
	    exit when result in (0, 4);
	  end loop;

	  if (result in (0, 4)) then	-- Success or own lock
	    return;
	  elsif (result in (1, 2)) then	-- Timeout or deadlock
	      lk := null;
	      hndl := null;
	  else                          -- Bad lock handle or bad param
	      lk   := null;
	      hndl := null;
	      e_code := NFALSE;
	  end if;

	else				-- Bad lock handle or bad param
	  lk   := null;
	  hndl := null;
	  e_code := NFALSE;
	end if;

	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'REQUEST_LOCK', FALSE);
  end request_lock;

  -- ### OVERLOADED ###
  /*------------------------------------------------------------------|
   | Obsolete: Please use Request_Session_Lock, Check_Process_Status  |
   |           or Check_Process_Status_By_Handle                      |
   +------------------------------------------------------------------*/
  procedure request_lock (hndl   in	varchar2,
			  status in out nocopy number,
			  e_code in out nocopy number) is

	result	number;

  begin
	e_code := NTRUE;

	result := dbms_lock.request (hndl, 6, 0);  -- ULX lock

	if (result in (0, 4)) then	-- Success or own lock
	  status := NTRUE;
	elsif (result in (1, 2)) then	-- Timeout or deadlock
	  status := NFALSE;
	else				-- Bad lock handle or bad param
	  e_code := NFALSE;
	end if;

	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'REQUEST_LOCK (hndl)', FALSE);
  end request_lock;


  procedure release_lock (hndl	 in     varchar2,
			  e_code in out nocopy number) is

	result	number;

  begin
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.RELEASE_LOCK',
                  'release_lock called for hndl='||hndl);
        end if;
	result := dbms_lock.release (hndl);

	if ((result = 0) or (result = 4)) then
	  e_code := NTRUE;
	else
	  e_code := NFALSE;
	end if;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_DCP.RELEASE_LOCK',
                  'release result='||to_char(result));
        end if;
	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'release_lock', FALSE);
  end release_lock;


  procedure clean_mgrs (e_code in out nocopy number) is

  begin
	null;
  end clean_mgrs;


  procedure monitor_icm (hndl   in out nocopy varchar2,
			 up	in out nocopy number,
			 logf	in out nocopy varchar2,
			 node	in out nocopy varchar2,
			 inst	in out nocopy varchar2,
			 cpid	in out nocopy number,
			 mthd	in     number,	-- PMON method
			 e_code in out nocopy number) is

	lk		varchar2(50);
	result		number;
	bad_lock	exception;
	time_interval	number;			-- PMON method = TSTAMP
	time_difference	number;			-- PMON method = TSTAMP
	dummy		number;

  begin
	e_code := NTRUE;

	if (mthd = TSTAMP) then			-- PMON method = TSTAMP
	  cpid := get_pid_time (time_interval,
				time_difference,
				0, 1, 'A', 'C', 'M', 'K');

	  if (time_difference < THRSHLD * time_interval) then
	    up := NTRUE;
	    rollback;
	    return;
	  end if;

	else					-- PMON method = DBLOCK
	  cpid := get_icm_info (logf, node, inst);

	  if (hndl is not null) then
	    result := dbms_lock.request (hndl, 6, 0);  -- ULX lock

            if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.string(FND_LOG.LEVEL_EVENT,
                  'fnd.plsql.FND_DCP.MONITOR_ICM',
                  'lock request result='||to_char(result)||' for hndl='||hndl);
            end if;


	    if (result in (1, 2)) then	-- Timeout or deadlock
	      up := NTRUE;
	      return;
	    end if;

	  end if;

	end if;					-- PMON method TSTAMP/DBLOCK

	if (cpid is null) then
          if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_EVENT, 'fnd.plsql.FND_DCP.MONITOR_ICM',
                    'get_icm_info returned cpid NULL');
          end if;

	  up := NTRUE;
	  hndl := null;
          rollback;
	  return;

	else
          if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_EVENT, 'fnd.plsql.FND_DCP.MONITOR_ICM',
                    'get_icm_info returned cpid='||to_char(cpid));
          end if;

	  lk := FNDCPLK || '0_1_' || cpid;
	  dbms_lock.allocate_unique (lk, hndl, EON);
	  result := dbms_lock.request (hndl, 6, 0);  -- ULX lock

          if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_EVENT, 'fnd.plsql.FND_DCP.MONITOR_ICM',
                  'new lock name = '||lk);
            fnd_log.string(FND_LOG.LEVEL_EVENT, 'fnd.plsql.FND_DCP.MONITOR_ICM',
                  'lock request result='||to_char(result)||' for hndl='||hndl);
          end if;

	  if (result = 0) then		-- Success
	    select 1 into dummy
            from fnd_concurrent_processes
	    where concurrent_process_id = cpid
	    for update nowait;

	    update fnd_concurrent_processes
	       set process_status_code = decode (process_status_code,
						 'A', 'K',
						 'M', 'S',
						       process_status_code)
	     where concurrent_process_id = cpid;
	    up := NFALSE;
	    commit;
	  elsif (result in (1, 2)) then	-- Timeout or deadlock
	    up := NTRUE;
	  elsif (result = 4) then	-- Own the lock (shouldn't happen)
	    up := NFALSE;
	  else				-- Bad lock handle or bad param
	    raise bad_lock;
	  end if;

	end if;

	exception
	  when others then
	    e_code := NFALSE;
	    rollback;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'monitor_icm', FALSE);
  end monitor_icm;


  procedure monitor_im (apid   in     number,
			qid    in     number,
			pid    in     number,
			cnode  in     varchar2,
			status in out nocopy number,
			e_code in out nocopy number) is

	max_procs	number;
	run_procs	number;
	ccode		varchar2(1);	-- Control code
	tnode		fnd_concurrent_queues.target_node%type;	-- Target node

  begin
	e_code := NTRUE;

	select max_processes,
	       running_processes,
	       control_code,
	       target_node
	  into max_procs,
	       run_procs,
	       ccode,
	       tnode
	  from fnd_concurrent_queues
	 where application_id = apid
	   and concurrent_queue_id = qid;

	if ((max_procs < run_procs) or
	    (cnode <> tnode)) then	-- Migrate
	  status := NFALSE;			-- Exit
	else
	  status := NTRUE;			-- Stay up
	end if;

	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'monitor_im', FALSE);
  end monitor_im;


  procedure reassign_lkh (e_code in out nocopy number) is

	cursor 	c1 is
		   select queue_application_id,
			  concurrent_queue_id,
			  concurrent_process_id,
			  rowid
		     from fnd_concurrent_processes
		    where manager_type between 1 and 5
		      and process_status_code in ('A', 'C')
		 order by concurrent_process_id;

	apid	number(15);
	qid	number(15);
	pid	number(15);
	rid	ROWID;
	hndl	varchar2(128);

  begin
	e_code := NTRUE;

	open c1;

	loop
	  fetch c1 into apid, qid, pid, rid;
	  exit when c1%notfound;

	  dbms_lock.allocate_unique (FNDCPLK ||
				     apid || '_' || qid || '_' || pid,
				     hndl, EON);

	  update fnd_concurrent_processes
	     set lk_handle = hndl
	   where rowid = rid;

	end loop;

	close c1;
	commit;

	exception
	  when others then
	    e_code := NFALSE;
	    fnd_message.set_name ('FND', 'CP-Generic oracle error');
	    fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
	    fnd_message.set_token ('ROUTINE', 'reassign_lkh', FALSE);
  end reassign_lkh;


  /* function get_inst_num
   *
   * This function is used to determine the OPS instance
   * to which a manager should "specialize".  For Parallel
   * Concurrent Processing, we want the a manager to
   * service requests only for the instance associated with
   * its primary node.
   *
   * If the manager was started on its primary node, then
   * the current instance number is retrieved from v$instance,
   * stored in fnd_concurrent_queues, and returned to the caller.
   *
   * If the manager was started on its secondary node, then
   * the instance number is retrieved from fnd_concurrent_queues
   *
   * Parameters:
   *   queue_appl_id - Concurrent queue application ID.
   *   queue_id      - Concurrent queue ID.
   *   current_node  - Node where manager is running.
   *
   * Returns:
   *   An OPS instance number.
   *
   * Alters:
   *   The table fnd_concurrent_queues may be updated.
   *
   * Assumptions:
   *   This function assumes that the node names stored in
   *   fnd_concurrent_queues exactly match those in the manager's
   *   sysinfo structure.  (i.e. Both fully qualified, or both not
   *   fully qualified)
   *
   * Error conditions:
   *
   *   All other exceptions are unhandled.
   */

  function get_inst_num	(queue_appl_id	in	number,
			 queue_id	in	number,
			 current_node	in	varchar2)
			return number is
    primary_node   fnd_concurrent_queues.node_name%type;
    secondary_node fnd_concurrent_queues.node_name2%type;
    inst_num number; /* OPS Instance Number */
  begin
    /* Are we on the primary node?*/
    select upper(node_name), upper(node_name2)
      into primary_node, secondary_node
      from fnd_concurrent_queues
      where concurrent_queue_id = queue_id
        and application_id = queue_appl_id;


    if (upper(current_node) = primary_node) then /* PCP Primary node */
      /* Get inst number from v$instance */
      select instance_number
        into inst_num
        from v$instance;

      /* Store it into fnd_concurrent_queues. */

      update fnd_concurrent_queues
		set instance_number = inst_num
		where application_id = queue_appl_id
		and concurrent_queue_id = queue_id;

      /* Update the global */
      FND_CONC_GLOBAL.Override_OPS_INST_NUM(inst_num);

    else /* we aren't on the primary node...maybe we still know the inst num*/
      select INSTANCE_NUMBER
      into inst_num
      from fnd_concurrent_queues
      where application_id = queue_appl_id
      and concurrent_queue_id = queue_id;

      /* Update the global...if not null */
      if (inst_num is not null) then
	  FND_CONC_GLOBAL.Override_OPS_INST_NUM(inst_num);
      end if;
    end if;

    return inst_num;
  end;

  /* function target_node_mgr_chk
   * If a request is targeted to a specific node, the concurrent
   * manager will use this function in his request query (afpgrq)
   * to filter it out if it doesn't meet any of the following conditions:
   * a) request's target node is the same as manager's current node
   * b)	request's target node is different from manager's current node, but the
   *    FND_NODES status is 'N' or node_mode is not 'O' (online).
   * c)	There are no managers specialized to run this request on request's
   *    target node
   *
   * Parameters:
   *   request_id - id of request that is targeted to a secific node
   *
   * Returns:
   *   NTRUE/TRUE/1   if this request can appear in query results
   *   NFALSE/FALSE/0 if this request should be filtered from query results
   *
   * Assumptions:
   *   The manager's target_node in fnd_concurrent_queues is it's current
   *   node.  This should always be true for active managers in afpgrq.
   *
   * Error conditions:
   *
   *   All other exceptions are unhandled.
   */

   function target_node_mgr_chk (req_id  in number) return number is

      cursor mgr_cursor (rid number, qappid number, qid number) is
        select queue_application_id, concurrent_queue_id,
             running_processes, max_processes,
             decode(control_code,
                    'T','N',       -- Abort
                    'X','N',       -- Aborted
                    'D','N',       -- Deactivate
                    'E','N',       -- Deactivated
                        'Y') active,
             target_node
          from fnd_concurrent_worker_requests
          where request_id = rid
            and not((queue_application_id = 0)
                  and (concurrent_queue_id in (1,4)))
            and not((queue_application_id = qappid)
                  and (concurrent_queue_id = qid ));

      my_q_appl_id    number := FND_GLOBAL.queue_appl_id ;
      my_q_id         number := FND_GLOBAL.conc_queue_id;
      req_node        varchar2(30) := null;
      dummy           number := 0;
      retval          number := NFALSE;
      my_node         fnd_concurrent_queues.target_node%type;

   begin

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Enter TARGET_NODE_MGR_CHK for manager ('||
               to_char(my_q_appl_id)|| '/'||my_q_id||
               ') and request_id '|| to_char(req_id));
      end if;

      /* Retrieve the request's target node */
      select node_name1
        into req_node
        from fnd_concurrent_requests
       where request_id = req_id;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Target node for request '||to_char(req_id)||' is '||
               NVL(req_node,'NULL'));
      end if;

      /* If request has no target node, okay to run it */
      if (req_node is null) then
         retval := NTRUE;
      end if;

      /* Check if the request node matches my node */
      if (retval = NFALSE) then

          select target_node
            into my_node
            from fnd_concurrent_queues
           where application_id = my_q_appl_id
             and concurrent_queue_id = my_q_id;


        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                 'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
                 'Manager node is '||NVL(my_node,'NULL'));
        end if;

        /* If request target node matches my node, okay to run it */
        if (req_node = my_node) then
           retval := NTRUE;
        end if;
      end if;

      /* Check if the request node is down */
      if (retval = NFALSE) then
        select count(*)
          into dummy
          from fnd_nodes
         where node_name = req_node
           and (node_mode <> 'O'
            or status <> 'Y');

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          if dummy >= 1 then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Request target node '||req_node||' is DOWN');
          else
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Request target node '||req_node||' is UP');
          end if;
        end if;

         /* If request target node is down, okay to run it */
         if (dummy >= 1) then
            retval := NTRUE;
	    fnd_message.set_name ('FND', 'CONC-REQ NODE NOT HONORED');
	    fnd_message.set_token ('REQID', to_char(req_id), FALSE);
	    fnd_message.set_token ('NODE', req_node, FALSE);
            if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              fnd_log.message(FND_LOG.LEVEL_EVENT,
                              'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
                              FALSE);
            end if;
         end if;
      end if;

      /* Check if a manager is available to run this request on target node */
      /* The first available manager we find, exit and return NFALSE        */
      if (retval = NFALSE) then
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,
              'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
              'Enter loop to determine if another manager can run');
        end if;
        for mgr_rec in mgr_cursor(req_id, my_q_appl_id, my_q_id) loop
          if ((mgr_rec.active = 'Y')
              and (mgr_rec.max_processes > 0)
              and (mgr_rec.running_processes > 0)
              and mgr_rec.target_node = req_node) then
                 /* Here is an available manager, no need to continue. */
                 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                          'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
                          'Another manager ('||
                           to_char(mgr_rec.queue_application_id )||'/'||
                           to_char(mgr_rec.concurrent_queue_id)||
                          ') can run this request');
                 end if;
                 retval := NFALSE;
                 exit;
          else
              retval := NTRUE;
	      fnd_message.set_name ('FND', 'CONC-REQ NODE NOT HONORED');
	      fnd_message.set_token ('REQID', to_char(req_id), FALSE);
	      fnd_message.set_token ('NODE', req_node, FALSE);
              if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                fnd_log.message(FND_LOG.LEVEL_EVENT,
                                'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
                                FALSE);
              end if;
          end if;
        end loop;
      end if;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       if retval = NTRUE then
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Returning retval= NTRUE');
       else
         fnd_log.string(FND_LOG.LEVEL_STATEMENT,
               'fnd.plsql.FND_DCP.TARGET_NODE_MGR_CHK',
               'Returning retval= NFALSE');
       end if;
      end if;
      return retval;

   end target_node_mgr_chk;

  --
  -- Name
  --   is_dcp
  -- Purpose
  --   Returns TRUE if the environment has multiple CP nodes,
  --   FALSE if not.
  --
  -- Parameters:
  -- None
  --
  -- Returns:
  --   NTRUE/TRUE/1   - environment is DCP
  --   NFALSE/FALSE/0 - environment is non-DCP
  --
  function is_dcp return number is

    node_count number := 0;
  begin

    select count(*)
      into node_count
      from fnd_nodes
     where node_name <> 'AUTHENTICATION'
       and support_cp = 'Y';

    if (node_count > 1) then
      return NTRUE;
    else
      return NFALSE;
    end if;

  end is_dcp;


end FND_DCP;

/

  GRANT EXECUTE ON "APPS"."FND_DCP" TO "EM_OAM_MONITOR_ROLE";
