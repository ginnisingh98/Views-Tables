--------------------------------------------------------
--  DDL for Package Body HR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTILITY" as
/* $Header: pyutilty.pkb 120.1.12010000.2 2008/12/12 10:54:18 sathkris ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   hr_utility

  Description:  See package specification.

  Change List
  ----------
  SuSivasu       24-OCT-2005   Carry out the check for the fnd log is enabled
                               before calling the fnd_log.string as this procedure
                               does the same check.
  dkerr          17-FEB-2005   4192532 : truncate procedure_name parameter
                               at 128 characters.
  nbristow       28-JAN-2005   Added PAY_LOG option to dump to the
                               Log file.
  dkerr          11-DEC-2002   Added NOCOPY hint to OUT and IN OUT parameters
  dkerr          03-DEC-2002   Added debug_enabled()
  dkerr          13-MAY-2002   Added support for AOL logging to trace() and
                               trace_udf()
  dkerr          09-MAY-2002   Code workaround for RDBMS 2367861 in
                               write_trace_file()

  nbristow       28-FEB-2002   Added dbdrv statements.
  nbristow       28-FEB-2002   Changed read_trace_table to have a smaller PL/SQL
                               table. NT could not support a large table.
  PZWALKER       06-SEP-2001   change if statement in set_location_trace local
                               procedures to enable parallel operation of
                               HR Trace and AOL Logging
  PZWALKER       05-SEP-2001   Performance Changes:
                               1) Added the following new PRIVATE global
                                  variables
                                  g_error_stage_aol, g_error_in_procedure_aol
                               2) The set_location procedure has been re-written
                                  for performance:
                                  - no local variables are initialised
                                  - all global package variables are fully
                                    qualified
                               3) Removed AOL logging code from main block in
                                  set_location to local procedure

                               Moved code from from local procedure
                               set_location_trace to procedure
                               set_location_hr_trace_internal to enable
                               code to be called from log_at.. procedures

                               Changes to switch_logging_on, switch_logging_off:
                               1) Replaced raise_application_error call with
                                  hr_utility.raise_error
                               2) Removed insert/delete into/from fnd_sessions

                               Changes to log_at... procedures
                               1) Replaced if-then-else checks for p_message
                                  with nvl call
                               2) Removed local variable l_message
                               3) added local procedure set_location_trace
                               4) added call to set_location_hr_trace_internal
                               5) added lower() calls to set module names to
                                  lower case

  PZWALKER       24-AUG-2001   Added AOL Logging to set_location()
                               added following procedures for AOL logging:
                               log_at_statement_level()
                               log_at_procedure_level()
                               log_at_event_level()
                               log_at_exception_level()
                               log_at_error_level()
                               log_at_unexpected_level()
                               switch_logging_on()
                               switch_logging_off()
                               changed != to <>
  NBRISTOW       18-JUL-2001   Added read_trace_table to improve PYUPIP
                                performance.
  DKERR          24-SEP-1999   Call dbms_output.enable(1000000) if trace dest
                               set appropriately
  DHARRIS        23-AUG-1999   115.12
                               Performance changes for set_location which
                               comprise of:
                               1) Added the following new PRIVATE global variables
                                  g_trace_on, g_sl_x, g_sl_mess_text
                               2) Set the g_trace_on boolean trace indicator variable
                                  to TRUE in private_trace_on.
                               3) Set the g_trace_on boolean trace indicator variable
                                  to FALSE in trace_off.
                               4) The set_location procedure has been re-written for
                                  performance:
                                  - no local variables are initialised
                                  - all global package variables are fully qualified
                                  - the new sub-procedure set_location_trace is only
                                  - called when trace is on.
  TBATTOO        24-MAY-1999   changed chk_product_install to use hr_legislation_installations
  MREID          18-MAY-1999   Added I to language code check for 11i
  DKERR          13-MAY-1999   Replaced chr() with fnd_global.local_chr()
                               which is portable.
  DKERR          12-May-1999   trace/set_location can use dbms_output.
  scgrant        21-Apr-1999   Multi-radix changes.
  DKERR          23-MAR-1999   Added set_trace_options and support for
                               writing to the rdbms trace file.
  MREID          06-NOV-1998   Added language parameter to chk_product_install
  DKERR          19-AUG-1998   523846: changed substr to substrb
  DKERR          20-JUL-1998   Changes to trace to ensure compatiblity with NT
                               Added trace_udf to allow trace statements
                               to be added to formula.
  MREID          02-JUL-1998   Change to chk_product_install - only accept
                               fully installed.
  ACHAUHAN       17-OCT-1997   Changed the chk_product_install to check
                               the fnd_application table against the
                               application short name and not the application
                               name. If the product is passed as
                               'Oracle Payroll' then the application short
                               name is formed as 'PAY'.

  D Kerr         22-SEP-1997   Fix to get_message to ensure it works in
                               the same way as R10. ie calling it still leaves
                               the message on the FND message stack.

  D Kerr         27-JUL-1997   R11 changes.
                   WARNING : Not compatible with R10

    Removed most of the code from message routines as it
    was either accessing obsoleted tables or was non NLS compliant
    or both. The code now uses FND_MESSAGE routines rather than
    accessing tables directly. Package globals are still maintained
        for use in get_message and get_message_details.

        Removed : show_error, get_token_details.

  110.1 10-JUL-1997 M.J.Hoyes  Bug 513048. Switched the cursors in the
  10.7 version 40.14            set_message procedure to validate against
                                fnd_new_messages and then fnd_messages
                                rather than vice versa. Re coded the
                                set message token procedure to use cursors
                                rather than PLSQL blocks and switched the
                                first table to drive off to fnd_new_messages.

  K Mundair      02-JUN-1997    Added procedure chk_product_install
  D Kerr         29-Nov-1996    New trace functionality
                    1. trace_on now takes a parameter which can
                   be used to give an alternative name to
                   the pipe.
                                2. read_trace_pipe routine moves the pipe
                   handling code from PYUPIP to this package.
  T Mathers      18-Aug-1996    Changed message and message token code
                    to use fnd_new_messages id there is no row
                in fnd_messages. Behave as normal if not in
                both.
  D Kerr     08-Jul-1996    Set a message in the case of pipe timeout
  D Kerr     03-Jul-1996    Added timeout parameter to send_message calls
                in trace and set_location.
  D Harris       24-Jun-1995    merged trace with set_location to improve
                                performance.
  T Mathers      28-Jun-1995    Added joins to fnd_current_language_view
                                for fnd_messages cursor in set_message
                                and set_message_token. WWBUG#288067
  D Harris       22-Jun-1995    Increased g_message_text from 240 to
                                2048 (max length required for use
                                in dbms_standard.raise_application_error).
  P Gowers       28-NOV-1994    G1682: Always call fnd_message.set_name()
  D Harris       07-OCT-1994    Increment length of set_location pipe
                                details from 40 to 72.
  D Harris       16-SEP-1993    Changes made for 10x compatibility for
                                forms 4 and aol api's.
  P Gowers       04-MAY-1993    Handle hint messages in set_message
  P Gowers       05-APR-1993    Add get_message_details, get_token_details
  P Gowers       02-MAR-1993    Add set_message_token which translates token
  P Gowers       20-JAN-1993    Big bang.

  Sathkris       12-DEC-2008     Added get_icx_val function


*/

--
-- Private Package variables
--
   g_warning_flag   boolean default FALSE;
   g_pipe_session   varchar2(30);
   g_trace_coverage varchar2(1);  -- null (same as 'F'), 'F' or 'T'

   -- DK 23-MAR-99 This feature is new
   -- The default destination is DBMS_PIPE but may also be
   -- 1. TRACE_FILE
   -- 2. TBD ..
   g_trace_dest   varchar2(30) default 'DBMS_PIPE';

  -- [115.12 START] DH 23-AUG-1999
  -- Performance changes for set_location
  g_trace_on     BOOLEAN := FALSE; -- determines if trace is on
  g_sl_x         INTEGER;
  g_sl_mess_text VARCHAR2(200);
  -- [115.12 END]

  --
  -- Error location variables - help to locate oracle errors
  --
  g_error_stage        number        := 0 ;
  g_error_in_procedure varchar2(128) := null ;
  g_error_stage_aol           varchar2(128) := null ;
  g_error_in_procedure_aol    varchar2(128) := null ;

  --  These variables are needed to support get_message and get_message_details
  g_message_name   varchar2(30);
  g_message_number number;
  g_message_applid number;
  g_msg_prefix     varchar2(30) := fnd_message.get_string('FND','AFDICT_APP_PREFIX');

-- NAME
--
--   who_called_me
--
-- DESCRIPTION
--
--  Returns details of the invoking program unit call at a given depth
--  in the call stack.
--
-- PARAMETERS
--
--     str    OUT varchar2
--
--       String identifying line number in calling package
--         eg  HRENTMNT.LINE234
--
--     call_depth IN number
--
--       The depth from this function in the call stack for which details
--       are returned.
--
--            1  ME
--            2  MY Caller
--            3  Their Caller
--            4  Their Caller's Caller
--
-- NOTES
--
-- This procedure is taken from OWA_UTIL (privutil.sql) package - passing
-- a single out parameter and adding an additional parameter which reports
-- on the given invoker in the call stack.
-- Note this routine will not return the calling function if the current pl/sql
-- context was invokved via an RPC. Unfortunately this includes clients
-- with embedded pl/sql engines such as Forms and Reports.
-- See bugs 1011954, 505441 and 1089472 for details.
--
-- If this routine is public most clients will want call_depth 3 (the default)
-- supporting the use of this procedure embedded in a utility procedure and
-- returns the name of callers to that utility function.
--
-- The routine in this package which call WHO_CALLED_ME passes a call_depth
-- value of 4 because, for performance reasons, it is itself in a local
-- procedure of such a utility function (hr_utility.trace())
--
-- It doesn't look feasible to return the name of the PU within the calling
-- package so we return just the package name and line number. There may be
-- value in adding the version number of the package, or if called from
-- FastFormula the name of the formula.
--
--
procedure who_called_me (str        out nocopy varchar2,
                         call_depth in number default 3) is
owner   varchar2(100);
name    varchar2(100);
lineno  number ;
caller_t varchar2(100);

call_stack  varchar2(4096);
n           number;
found_stack BOOLEAN default FALSE;
line        varchar2(255);
t           varchar2(255);
cnt         number := 0;
begin
--

    --
    -- If stack unavailable then return a tag indicating the current
    -- pl/sql stack is the result of an RPC invocation.
    -- See bugs 1011954, 505441 and 1089472.
    --
    call_stack  :=  dbms_utility.format_call_stack;
    if ( call_stack is null ) then
       str := 'RPC-CALL';
       return;
    end if;

    loop

	n := instr( call_stack, fnd_global.local_chr(10) );
	exit when ( cnt = call_depth or n is NULL or n = 0 );
--
	line := substr( call_stack, 1, n-1 );
	call_stack := substr( call_stack, n+1 );
--
	if ( NOT found_stack ) then
	    if ( line like '%handle%number%name%' ) then
		found_stack := TRUE;
	    end if;
	else
	    cnt := cnt + 1;
	    if ( cnt = call_depth ) then
		-- Fix 718865
		--lineno := to_number(substr( line, 13, 6 ));
		--line   := substr( line, 21 );
		n := instr(line, ' ');
		if (n > 0)
		then
		    t := ltrim(substr(line, n));
		    n := instr(t, ' ');
		end if;
		if (n > 0)
		then
		   lineno := to_number(substr(t, 1, n - 1));
		   line := ltrim(substr(t, n));
		else
		    lineno := 0;
		end if;
		if ( line like 'pr%' ) then
		    n := length( 'procedure ' );
		elsif ( line like 'fun%' ) then
		    n := length( 'function ' );
		elsif ( line like 'package body%' ) then
		    n := length( 'package body ' );
		elsif ( line like 'pack%' ) then
		    n := length( 'package ' );
		else
		    n := length( 'anonymous block ' );
		end if;
		caller_t := ltrim(rtrim(upper(substr( line, 1, n-1 ))));
		line := substr( line, n );
		n := instr( line, '.' );
		owner := ltrim(rtrim(substr( line, 1, n-1 )));
		name  := ltrim(rtrim(substr( line, n+1 )));
	    end if;
	end if;
    end loop;

    str := name || '.LINE' || lineno ;

end who_called_me ;

procedure write_trace_file (p_text         in varchar2 )  is
pragma autonomous_transaction ;
begin

   --
   -- Write change to trace file
   --

   -- Bug 2367861
   --
   -- Passing an empty but not null string causes server core dump
   -- in 9.0.1. The intent is to give a blank line in the output
   -- which can be achieved with a space character.
   --
   -- 13-MAY-2002 - add length restriction. ksdwrt max length is undocumented
   -- 1100 can cause a coredump, 900 seems to work but for the use for which
   -- hr_utility.trace() was originally designed, truncating at 255 seems
   -- safe - particularly when there is the alternative of AOL's log feature
   -- allows 4000 characters
   --
   sys.dbms_system.ksdwrt(1,substr(nvl(p_text,' '),1,255));

   --
   -- Flush changes immediately. Potentially slow  ??
   --
   sys.dbms_system.ksdfls;
end;
--
---------------------------------- trace ------------------------------
/*
  NAME
    trace - output text string (if tracing on)
*/
  procedure trace_local(trace_data in varchar2)  is
  l_x      integer;
  l_caller varchar2(100);
  begin

    --
    --Optimize for fnd_log - uncomment if required
    --
    if fnd_log.g_current_runtime_level <= fnd_log.level_statement
    then
    --

      who_called_me(l_caller,4);

      -- A couple of modules call hr_trace('') in order to separate groups of
      -- related trace() calls. As it stands fnd_log.string won't accept a
      -- null value but instead raises an ORA-1400 with no fnd_message
      -- context back to forms. fnd_log.string will accept a ' ' however
      -- it seems risky to leave that in case the routine rtrims. For now
      -- we pass a '.' and may file bug.

      fnd_log.string(fnd_log.level_statement,
                     lower('per.plsql.'||l_caller),
                     nvl(trace_data,'.'));
    --
    --Optimize for fnd_log - uncomment if required
    --
    end if;
    --

    --  output information to pipe if tracing is enabled
    if g_pipe_session is not null then
       if g_trace_dest = 'DBMS_PIPE'
       then
           dbms_pipe.pack_message( trace_data );
           l_x := dbms_pipe.send_message( pipename => g_pipe_session,
                          timeout  => PIPE_PUT_TIMEOUT );
           if ( l_x <> 0 ) then

           -- Don't call other functions here if they call trace
           -- Set a message so that the error is visible in forms.
           fnd_message.set_name('PAY','HR_51356_UTILITY_PIPE_TIMEOUT');
               fnd_message.raise_error ;

               end if;

       elsif g_trace_dest = 'DBMS_OUTPUT'  then

              -- DK 14-MAY-2002 Truncate at 255 to prevent error
              dbms_output.put_line(substr(trace_data,1,255));
--
       elsif g_trace_dest = 'PAY_LOG'  then
--
          pay_proc_logging.PY_LOG_TXT(
                     p_logging_type => pay_proc_logging.PY_HRTRACE,
                     p_print_string => substr(trace_data,1,3000));
--
       else

         write_trace_file(trace_data);

       end if;
    end if;
  end trace_local;

  procedure trace (trace_data in varchar2) is
  pragma autonomous_transaction ;
  begin

    if fnd_log.g_current_runtime_level > fnd_log.level_statement
       and NOT hr_utility.g_trace_on
    then
      return ;
    else
      trace_local(trace_data);
    end if;

  end trace;
---------------------------------- trace_on ------------------------------
/*
  NAME
    trace_on - enables output to debugging pipe
  DESCRIPTION

    If the session_identifier is not entered then the name of the pipe
    defaults to PIPE<session_id>.
    Otherwise it is set in the following way

    PID   - PID<process id>.
      'process id' is the PID column from v$process

    REQID - REQID<conc. request id>.
      'conc. request id' is taken from the CONC_REQUEST_ID profile option


    WEB   - WEB<icx session id>
      'icx session id' is taken from ICX_SESSIONS

    If any other value is passed then this is used as the pipe name.

    Ideally a pipe receiver should be started before running this statement.
    Note that an unmonitored client process will hang once the default max
    pipesize has been reached. This is currently 8192 bytes.
    The timeout period for unread pipes is set to PIPE_PUT_TIMEOUT seconds

   NOTES
    In order to allow this routine to be called from Forms which uses
    PL/SQL v1 overloads and a private implementation are used to handle
    the defaulting
*/
  procedure private_trace_on(trace_mode         in varchar2 default null,
                 session_identifier in varchar2 default null ) is

  --Retrieves the session_id value from ICX_SESSIONS. As web server is only
  --optionally installed need to use DBMS_SQL
  function get_web_id return number is
  l_cursor   integer;
  l_retval   varchar2(40) := 'NULL'; -- Need to initialize
  l_ignore   number ;
  begin

    l_cursor := dbms_sql.open_cursor ;
    dbms_sql.parse(l_cursor,
           'begin :retval := icx_sec.getID(icx_sec.pv_session_id);end;',
            dbms_sql.v7);
    dbms_sql.bind_variable(l_cursor,':retval',l_retval);
    l_ignore := dbms_sql.execute(l_cursor);
    dbms_sql.variable_value(l_cursor,':retval' , l_retval ) ;

    return( fnd_number.canonical_to_number(l_retval) ) ;

  end get_web_id ;

  -- Retrieves the current process id from V$PROCESS
  function get_process_id return number is
  l_retval number := null ;
  cursor getpid is
  select p.pid
  from   v$process p,
     v$session s
  where  s.paddr = p.addr
  and    s.audsid = userenv('sessionid');
  begin

     open  getpid;
     fetch getpid into l_retval ;
     close getpid ;

     return ( l_retval ) ;

  end get_process_id ;


  begin

     if ( session_identifier is null )
     then

       select 'PIPE' || userenv('sessionid')
       into   g_pipe_session
       from   dual;

     elsif ( session_identifier = 'PID' )
     then


       g_pipe_session := session_identifier||to_char(get_process_id);

     elsif ( session_identifier = 'REQID' )
     then

       g_pipe_session := session_identifier||fnd_profile.value('CONC_REQUEST_ID');

     elsif ( session_identifier = 'WEB' )
     then

       g_pipe_session := session_identifier||to_char(get_web_id) ;

     else

       g_pipe_session := session_identifier ;

     end if;

     g_trace_coverage := trace_mode;

     -- [115.12 START] DH 23-AUG-1999
     -- set the global TRACE BOOLEAN indicator to TRUE
     g_trace_on := TRUE;
     -- [115.12 END]

  end private_trace_on;
  procedure trace_on is
  begin
     private_trace_on;
  end trace_on ;
  procedure trace_on (trace_mode     in varchar2 ) is
  begin
     private_trace_on(trace_mode) ;
  end trace_on ;
  procedure trace_on (trace_mode         in varchar2 ,
              session_identifier in varchar2 ) is
  begin
     private_trace_on(trace_mode,session_identifier) ;
  end trace_on ;
---------------------------------- trace_off ------------------------------
/*
  NAME
    trace_off - disables output to debugging pipe
  DESCRIPTION
    don't use until a pipe receiver has been started
*/
  procedure trace_off is
  begin
    g_pipe_session := null;

    -- [115.12 START] DH 23-AUG-1999
    -- set the global TRACE BOOLEAN indicator to FALSE
    g_trace_on := FALSE;
    -- [115.12 END]

  end trace_off;
---------------------------------- hr_error ----------------------------------
/*
  NAME
    hr_error  -  Returns the equivalent sqlcode of hr_error exception
  DESCRIPTION
    Needed because forms 3.0/4.0 cannot handle package exception 'hr_error'
  function hr_error return number is
  begin
    return HR_ERROR_NUMBER;
  end hr_error;
*/
-------------------------- set_location_hr_trace_internal ----------------------
/*
  NAME
    set_location_hr_trace_internal
  DESCRIPTION
    Sets package variables to store location name and stage number which
    enables unexpected errors to be located more easily
    This procedure incorporates the trace procedure for performance reasons
*/
  -- [115.16 START] PW 05-SEP-2001
  -- This code was moved from local procedure set_location_trace declared
  -- in procedure set_location to enable it to be called from log_at..
  -- procedures

  PROCEDURE set_location_hr_trace_internal IS
  BEGIN
    hr_utility.g_sl_mess_text := RPAD(hr_utility.g_error_in_procedure,72)||
                              TO_CHAR(hr_utility.g_error_stage);
    IF hr_utility.g_trace_dest = 'DBMS_PIPE' THEN
      dbms_pipe.pack_message(hr_utility.g_sl_mess_text);
      hr_utility.g_sl_x := dbms_pipe.send_message
                             (pipename => hr_utility.g_pipe_session
                             ,timeout  => PIPE_PUT_TIMEOUT);
      IF (hr_utility.g_sl_x <> 0) THEN
        -- Don't call other functions here if they call trace
        -- Set a message so that the error is visible in forms.
        fnd_message.set_name('PAY','HR_51356_UTILITY_PIPE_TIMEOUT');
        fnd_message.raise_error ;
      END IF;
    ELSIF hr_utility.g_trace_dest = 'DBMS_OUTPUT' THEN
      dbms_output.put_line(hr_utility.g_sl_mess_text);
--
    ELSIF hr_utility.g_trace_dest = 'PAY_LOG'  then
--
          pay_proc_logging.PY_LOG_TXT(
                     p_logging_type => pay_proc_logging.PY_HRTRACE,
                     p_print_string => substr(hr_utility.g_sl_mess_text,1,3000));
--
    ELSE
      write_trace_file(hr_utility.g_sl_mess_text);
    END IF;
  END set_location_hr_trace_internal;
-------------------------------- set_location --------------------------------
/*
  NAME
    set_location
  DESCRIPTION
    Sets package variables to store location name and stage number which
    enables unexpected errors to be located more easily
    This procedure incorporates the trace procedure for performance reasons
*/
  -- [115.12 START] DH 23-AUG-1999
  -- The set_location procedure has been re-written for performance
  -- no local variables are initialised
  -- all global package variables are fully qualified
  -- the new sub-procedure set_location_trace is only called
  -- when trace is on.
  PROCEDURE set_location (procedure_name IN VARCHAR2, stage IN NUMBER) IS
    -- sub-procedure for AOL Logging
    PROCEDURE set_location_trace IS
    BEGIN
      if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then

        --
        -- 4192532 Callers to set_location may be passing in very long
        -- text strings for the procedure_name param. In these cases the
        -- hr_utility.trace() should have been used instead.
        -- Defensively we truncate the procedure_name at 128 characters
        -- which should be long enough for correct use of set_location()
        --
        hr_utility.g_error_in_procedure_aol
                   := substr(LTRIM(procedure_name),1,128);

        if SUBSTR(hr_utility.g_error_in_procedure_aol,1,10)
                      ='Entering: ' then
          fnd_log.string(fnd_log.level_procedure,'per.plsql.'
          ||LTRIM(SUBSTR(hr_utility.g_error_in_procedure_aol,11))
          ||'.entering',to_char(stage));
        elsif SUBSTR(hr_utility.g_error_in_procedure_aol,1,9)
                      ='Leaving: ' then
          fnd_log.string(fnd_log.level_procedure,'per.plsql.'
          ||LTRIM(SUBSTR(hr_utility.g_error_in_procedure_aol,10))
          ||'.leaving',to_char(stage));
        elsif fnd_log.g_current_runtime_level <=fnd_log.level_statement then
          hr_utility.g_error_stage_aol := TO_CHAR(stage);
          fnd_log.string(fnd_log.level_statement,
          'per.plsql.'||hr_utility.g_error_in_procedure_aol
          ||'.'||hr_utility.g_error_stage_aol,
          hr_utility.g_error_stage_aol);
        end if;
      end if;
      if hr_utility.g_trace_on THEN
        hr_utility.g_error_stage := stage;

        -- 4192532
        hr_utility.g_error_in_procedure := substr(procedure_name,1,128);

        hr_utility.set_location_hr_trace_internal;
      end if;
    END set_location_trace;
  BEGIN
    -- Check for Logging
    if fnd_log.g_current_runtime_level>fnd_log.level_procedure
       and NOT hr_utility.g_trace_on then
      RETURN;
    else
      set_location_trace;
    END IF;
  END set_location;
  -- [115.12 END]
----------------------------- clear_message --------------------------------
/*
  NAME
    clear_message
  DESCRIPTION
    Clears message globals
*/
  procedure clear_message is
  begin

    hr_utility.g_message_number := null;
    hr_utility.g_message_name   := null;
    fnd_message.clear ;

  end clear_message;
-------------------------------- set_message --------------------------------
/*
  NAME
    set_message
  DESCRIPTION
    Calls FND_MESSAGE.SET_NAME and sets the message name and application id as
    package globals.

*/
  procedure set_message (applid in number, l_message_name in varchar2) is
  --
  begin

    g_message_name   := l_message_name;
    g_message_applid := applid;
    --
    fnd_message.set_name( hr_general.get_application_short_name(applid),
              l_message_name );

  end set_message;
--
------------------------------ set_message_token ------------------------------
/*
  NAME
    set_message_token
  DESCRIPTION
    Sets message token. Just calls AOL routine.
*/
  procedure set_message_token (l_token_name in varchar2,
                               l_token_value in varchar2) is
  begin

    fnd_message.set_token(l_token_name, l_token_value, translate => false );

  end set_message_token;
------------------------------ set_message_token ------------------------------
/*
  NAME
    set_message_token
  DESCRIPTION
    Overloaded: Sets up a translated message token
    Note that the application id passed a parameter is ignored. The FND_MESSAGE
    routine uses the application of the last message that was set.
*/
  procedure set_message_token (l_applid        in number,
                               l_token_name    in varchar2,
                               l_token_message in varchar2)
  is
  begin

    fnd_message.set_token(l_token_name,l_token_message, translate => true );

  end set_message_token;
-------------------------------- get_message --------------------------------
/*
  NAME
    get_message
  DESCRIPTION
    Assembles the current message text and returns it. This is different to
    FND_MESSAGE.GET in that it prefixes the text with 'APP-nnnnn' where
    nnnnn is the zero padded message number

    Note that after calling the FND get routines we put the message back
    onto the 'stack' so that the routine can be called more than once.

*/
  function get_message return varchar2 is

  l_msg_encoded varchar2(2048) ;
  l_msg_appl    varchar2(40) ;
  l_msg_name    varchar2(80) ;
  l_msg_number  number ;
  l_pos1        number ;
  l_pos2        number ;
  l_msg_text    varchar2(2048) ;

  begin

    -- After retrieving the message it mut be set again so that
    -- subsequent calls to 'get' routines work.
    --
    l_msg_encoded := fnd_message.get_encoded ;
    fnd_message.set_encoded(l_msg_encoded);

    if ( l_msg_encoded is null )
    then
       return null;
    end if;


    -- Extract the message application and name from the encoded string
    -- so that we can get the message number for display purposes.
    l_pos1       := instr(l_msg_encoded,fnd_global.local_chr(12));
    l_pos2       := instr(l_msg_encoded,fnd_global.local_chr(12),1,2);
    l_msg_appl   := substrb(l_msg_encoded,1,l_pos1 -1 );
    l_msg_name   := substrb(l_msg_encoded,
                            l_pos1 +1,
                            l_pos2 - l_pos1 - 1);
    l_msg_number := fnd_message.get_number(l_msg_appl,l_msg_name);


    if ( l_msg_number is null or l_msg_number = 0 ) then

      l_msg_text := fnd_message.get ;

    else

       -- Assemble the message in the form 'APP-nnnnn : message text'
       -- The number of zeros is AFD_MSG_NUM_BYTES
       l_msg_text := g_msg_prefix||'-'||to_char(l_msg_number,'FM00000')||' '
                              ||fnd_message.get;

    end if;

    -- Put the message back so that it is available in other contexts
    fnd_message.set_encoded(l_msg_encoded);

    return(l_msg_text) ;

  end get_message;
---------------------------- get_message_details ----------------------------
/*
  NAME
    get_message_details
  DESCRIPTION
    Gets the name and the application short name of the message last set
    Ideally would use FND_MESSAGE.RETRIEVE but this is AOL only at present.
*/
  procedure get_message_details (msg_name in out nocopy varchar2,
                                 msg_appl in out nocopy varchar2) is
  begin
    msg_appl := 'FND';
    if hr_utility.g_message_name is null then
       msg_name := 'NO_MESSAGE';
    else
       msg_name := g_message_name;
       msg_appl := hr_general.get_application_short_name(g_message_applid) ;
    end if;
  end get_message_details;
-------------------------------- set_warning --------------------------------
/*
  NAME
    set_warning
  DESCRIPTION
    Sets the package warning flag to indicate that a warning has occurred
*/
  procedure set_warning is
  begin
    g_warning_flag:=TRUE;
  end set_warning;
-------------------------------- check_warning --------------------------------
/*
  NAME
    check_warning
  DESCRIPTION
    Returns the value of the warning flag
*/
  function check_warning return boolean is
  begin
    return g_warning_flag;
  end check_warning;
-------------------------------- clear_warning --------------------------------
/*
  NAME
    clear_warning
  DESCRIPTION
    Resets the package warning flag
*/
  procedure clear_warning is
  begin
    g_warning_flag:=FALSE;
  end clear_warning;
-------------------------------- oracle_error --------------------------------
/*
  NAME
    oracle_error
  DESCRIPTION
    Sets generic oracle error message and passes the sqlcode, and error
    location information
*/
  procedure oracle_error (oracode in number) is
  begin
    set_message (801,'HR_ORACLE_ERROR');
    set_message_token ('PROCEDURE', g_error_in_procedure);
    set_message_token ('TABLE', to_char(g_error_stage));
    set_message_token ('ORA_MESG', 'ORA' || to_char(oracode));
    -- reset error location information
    g_error_stage:=0;
    g_error_in_procedure:= null;
  exception
    -- this gets called from top level exception handler, so never want
    -- to leave this function with an exception, otherwise we will always
    -- get 'Unhandled exception' error
    when others then
      null;
  end oracle_error;
-------------------------------- raise_error --------------------------------
/*
  NAME
    raise_error
  DESCRIPTION
    Performs raise_application_error but always with the same error number
    HR_ERROR_NUMBER for consistency
*/
  procedure raise_error is
  begin
    raise_application_error (hr_utility.hr_error_number, hr_utility.get_message);
--    app_exception.raise_exception;
  end raise_error;
-------------------------------- fnd_insert --------------------------------
/*
  NAME
    fnd_insert
  DESCRIPTION
    Inserts a row into FND_SESSIONS for the date passed for the current
    session id
*/
  procedure fnd_insert (l_effective_date in date) is
  begin
     insert into fnd_sessions (session_id, effective_date)
     values (userenv('SESSIONID'), trunc(l_effective_date));
  end fnd_insert;

-------------------------------- read_trace_pipe  -----------------------------
/*
  NAME
    read_trace_pipe
  DESCRIPTION
    Reads the next message from the named pipe.

    If the pipename is PIPEnnnn then after the given timeout period.
    The routine will check whether the corresponding session still
    exists. Support for other types may be added later.

  PARAMETERS

       p_pipename      Name of the pipe
       p_timeout       Timeout period. When it is reached the routine
               will check whether the given session still exists.
       p_status        The return status from DBMS_PIPE.RECEIEVE_MESSAGE
       p_retval        The text retrieved from the pipe
*/
-- See header - this overload provided to w/a NT bug.
procedure read_trace_pipe(p_pipename in varchar2,
                          p_status   in out nocopy number,
                          p_retval   in out nocopy varchar2 ) is
begin
   read_trace_pipe(p_pipename,
                   PIPE_READ_TIMEOUT,
                   p_status,
                   p_retval ) ;
end read_trace_pipe;

procedure read_trace_pipe(p_pipename in varchar2,
                          p_timeout  in number,
                          p_status   in out nocopy number,
                          p_retval   in out nocopy varchar2 ) is
s       integer;
t       integer;
num     number;
dt      date;
chr     varchar2(2000);
l_dummy varchar2(2000);

cursor get_session is
select 1
from   v$session
where  audsid = replace(p_pipename,'PIPE')
and    status <> 'KILLED' ;

begin
 chr := null;
 loop
    s := dbms_pipe.receive_message(p_pipename,p_timeout);
     if ( (s = 1) and (p_pipename like 'PIPE%')) then
       open get_session ;
       fetch get_session into l_dummy ;
       if get_session%notfound then
          close get_session ;
          exit ;
       else
          close get_session ;
       end if;
    else
       exit ;
    end if    ;
  end loop ;

  if s = 0 then
    t := 0;
    t := dbms_pipe.next_item_type;
    if t = 9 then
       dbms_pipe.unpack_message(chr);
    elsif t = 6 then
       dbms_pipe.unpack_message(num);
       chr := fnd_number.number_to_canonical(num);
    elsif t = 12 then
       dbms_pipe.unpack_message(dt);
       chr := to_char(dt);
    end if;
  end if;

  p_status := s;
  p_retval := chr;

end read_trace_pipe;
--
-------------------------------- read_trace_table -----------------------------
/*
  NAME
    read_trace_table
  DESCRIPTION
    Reads the next message from the named pipe into a PL/SQL table.

    If the pipename is PIPEnnnn then after the given timeout period.
    The routine will check whether the corresponding session still
    exists. Support for other types may be added later.

  PARAMETERS

       p_pipename      Name of the pipe
       p_status        The return status from DBMS_PIPE.RECEIEVE_MESSAGE
       p_retval        The text PL/SQL table containing the messages
       p_messages      The maximum number of entries that should be placed
                       in the PL/SQL table.
       p_cnt_mess      The number of entries actually created in PL/SQL
                       table.
*/
procedure read_trace_table(p_pipename in varchar2,
                           p_status   in out nocopy number,
                           p_retval   in out nocopy t_varchar180,
                           p_messages in number,
                           p_cnt_mess in out nocopy number ) is
s       integer;
t       integer;
num     number;
dt      date;
stri    varchar2(2000);
l_dummy varchar2(2000);
l_rettab t_varchar180;
int_cnt number;
complete boolean;
--
cursor get_session is
select 1
from   v$session
where  audsid = replace(p_pipename,'PIPE')
and    status <> 'KILLED' ;
--
begin
 l_rettab.delete;
 int_cnt := 0;
 complete := FALSE;
 while (complete = FALSE) loop
--
    int_cnt := int_cnt + 1;
    s := dbms_pipe.receive_message(p_pipename,5);
     if ( (s = 1) and (p_pipename like 'PIPE%')) then
       open get_session ;
       fetch get_session into l_dummy ;
       if get_session%notfound then
          close get_session ;
          s := 6;
       else
          close get_session ;
       end if;
     end if;

     if s = 0 then
       t := 0;
       t := dbms_pipe.next_item_type;
       if t = 9 then
          dbms_pipe.unpack_message(stri);
          l_rettab(int_cnt) := substr(stri, 1, 180);
       elsif t = 6 then
          dbms_pipe.unpack_message(num);
          l_rettab(int_cnt) := substr(fnd_number.number_to_canonical(num), 1, 180);
       elsif t = 12 then
          dbms_pipe.unpack_message(dt);
          l_rettab(int_cnt) := substr(to_char(dt), 1, 180);
       end if;
     end if;
--
     if (int_cnt = p_messages) then
        complete := TRUE;
     else
       if (s <> 0) then
         complete := TRUE;
       end if;
     end if;
  end loop;
--
  p_status := s;
  p_retval := l_rettab;
  p_cnt_mess := l_rettab.count;
--
end read_trace_table;
-------------------------------- get_trace_id  --------------------------------
/*
  NAME
    get_trace_id
  DESCRIPTION
    Returns the name of the PIPE that HR trace statements are written
    to.
*/
  function get_trace_id return varchar2 is
  begin

     return ( g_pipe_session ) ;

  end get_trace_id ;
-------------------------------- trace_udf  --------------------------------
/*
  NAME
    trace_udf
  DESCRIPTION
    Performs the same as trace() but written as a fuction to allow it
    to be used as a UDF.
    Returns the value 'TRUE' if tracing is enabled otherwise 'FALSE'
*/
  function trace_udf (trace_data in varchar2) return varchar2 is
  retval boolean ;
  pragma autonomous_transaction ;
  begin


     --
     -- 13-MAY-2002 Check for AOL logging being enabled.
     -- replicates logic of trace() so that trace_local() can
     -- be called directly.
     --
     retval := (fnd_log.g_current_runtime_level = 1) or hr_utility.g_trace_on ;

     if (retval) then
       trace_local(trace_data) ;
     end if;

     return( hr_general.bool_to_char(retval) ) ;

  end trace_udf ;

-------------------------------- chk_product_install -------------------------
/*
  NAME
    chk_product_install
  DESCRIPTION
    Checks whether the product specified is installed for the legislation
    specified
  PARAMETERS
    p_product      Short name of the application e.g. PAY,PER,...
    p_legislation  Legislation code(US,GB...)
*/
function chk_product_install (
        p_product             VARCHAR2,
        p_legislation         VARCHAR2,
        p_language            VARCHAR2) return boolean is

--

v_chk         VARCHAR2(1);
l_short_name  VARCHAR2(10);
v_language    VARCHAR2(1);

begin

   if p_product = 'Oracle Payroll' then
       l_short_name := 'PAY';
    elsif p_product = 'Oracle Human Resources' then
       l_short_name := 'PER';
    else
       l_short_name := p_product;
    end if;


    select 'x'
    into   v_chk
    from   hr_legislation_installations
    where  l_short_name=application_short_name
    and    nvl(p_legislation,'x')=nvl(legislation_code,'x')
    and    (status='I' or action is not NULL);

    if v_chk = 'x' then
       return(true);
    else
       return(false);
    end if;

  exception
  when no_data_found then
          return(false);

--
end chk_product_install;
--
function chk_product_install (
        p_product             VARCHAR2,
        p_legislation         VARCHAR2
                             ) return boolean is
begin
--
    return(chk_product_install(p_product, p_legislation, 'US'));
--
end chk_product_install;

procedure set_trace_options (p_options         in varchar2 ) is
l_trace_dest varchar2(80) := 'TRACE_DEST:' ;
begin
   if (instr(p_options,l_trace_dest) = 1 )
   then
      g_trace_dest := replace(p_options,l_trace_dest);

      -- DK 99-09-24
      -- If the user has set dbms_output then
      -- we set the buffer to be the maximum size. Ideally
      -- the buffer size would only be set if it was the default
      -- size but there doesn't seem to be an easy way of doing that
      --
      if ( g_trace_dest = 'DBMS_OUTPUT' )
      then
         dbms_output.enable(1000000);
      end if;

   end if;
end;

---------------------------- log_at_statement_level -------------------------
/*
  NAME
      log_at_statement_level

  DESCRIPTION

      Used for low level logging messages giving maximum detail
      Example:  Copying string from buffer xyz to buffer zyx

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_statement_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_statement then
      fnd_log.string(fnd_log.level_statement,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_statement
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_statement_level;
---------------------------- log_at_procedure_level -------------------------
/*
  NAME
      log_at_procedure_level

  DESCRIPTION

      Used to log messages called upon entry and/or exit from a routine
      Example:  Entering routine fdllov()

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_procedure_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
      fnd_log.string(fnd_log.level_procedure,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_procedure
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_procedure_level;
-------------------------------- log_at_event_level -------------------------
/*
  NAME
      log_at_event_level

  DESCRIPTION

      Used for high level logging message
      Examples: User pressed "Abort" button
                Beginning establishment of apps security session

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_event_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_event then
      fnd_log.string(fnd_log.level_event,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_event
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_event_level;
----------------------------- log_at_exception_level -------------------------
/*
  NAME
      log_at_exception_level

  DESCRIPTION

      Used to to log a message when an internal routine is returning a failure
      code or exception, but the error does not necessarily indicate a
      problem at the user's level.

      Examples: Profile ABC not found,
                Networking routine XYZ could not connect; retrying.
                File not found (in a low-level file routine)
                Database error (in a low-level database routine like afupi)
  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_exception_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_exception then
      fnd_log.string(fnd_log.level_exception,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_exception
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_exception_level;
-------------------------------- log_at_error_level -------------------------
/*
  NAME
      log_at_error_level
  DESCRIPTION
      An error message to the user; logged automatically by Message
      Dict calls to "Error()" routines, but can also be logged
      by other code.

      Examples: User entered a duplicate value for field XYZ
                Invalid apps username or password at Signon screen.
                Function not available

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_error_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_error then
      fnd_log.string(fnd_log.level_error,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_error
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_error_level;
----------------------------- log_at_unexpected_level -----------------------
/*
  NAME
      log_at_unexpected_level

  DESCRIPTION

      An unexpected situation occurred which is likely to indicate
      or cause instabilities in the runtime behavior, and which
      the System Administrator needs to take action on.
      Note to developers: Think very carefully before logging
      messages at this level; Administrators are going to get worried
      and file high priority bugs if your code logs at this level
      frequently.

      Examples: Out of memory, Required file not found, Data integrity error
                Network integrity error, Internal error, Fatal database error

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/
procedure log_at_unexpected_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null ) IS
  PROCEDURE set_location_trace IS
  BEGIN
    if fnd_log.g_current_runtime_level<=fnd_log.level_unexpected then
      fnd_log.string(fnd_log.level_unexpected,lower(p_product||'.plsql.'
                 ||p_procedure_name)||'.'||p_label,nvl(p_message,p_label));
    end if;
    if hr_utility.g_trace_on THEN
      hr_utility.g_error_stage := p_label;
      hr_utility.g_error_in_procedure := p_procedure_name;
      hr_utility.set_location_hr_trace_internal;
    end if;
  END set_location_trace;
BEGIN
  -- Check for Logging
  if fnd_log.g_current_runtime_level>fnd_log.level_unexpected
     and NOT hr_utility.g_trace_on then
    RETURN;
  else
    set_location_trace;
  END IF;
END log_at_unexpected_level;

-------------------------------- switch_logging_on -------------------------
/*
  NAME
    switch_logging_on

  DESCRIPTION

    Turns on AOL debug message logging at specified level when not using
    standard applications login (eg sqlplus session). Logging is enabled
    for a user by setting user profile options. The user and responsibility
    can be specified with p_user_id and p_responsibility_id .If p_user_id
    is not specified the user will default to SYSADMIN. If p_responsibility_id
    is not specified the responsibility will default to the first
    responsibility in the list of responsibilities for the user ordered by
    responsibility_id.

  PARAMETERS

    p_logging_level:       possible values: FND_LOG.LEVEL_UNEXPECTED
                                            FND_LOG.LEVEL_ERROR
                                            FND_LOG.LEVEL_EXCEPTION
                                            FND_LOG.LEVEL_EVENT
                                            FND_LOG.LEVEL_PROCEDURE
                                            FND_LOG.LEVEL_STATEMENT
                           default is FND_LOG.LEVEL_STATEMENT
    p_user_id:                 user id for which logging will be enabled
    p_responsibility_id:       responsibility id for which logging will
                               be enabled
*/

procedure switch_logging_on
                (p_logging_level     in number default fnd_log.level_statement
                ,p_user_id           in number default null
                ,p_responsibility_id in number default null) is
    --
    -- we'll be updating user profile values so use an autonomous transaction
    pragma autonomous_transaction;
    --
    l_b boolean;
    l_user_id number;
    l_responsibility_id number;
    l_application_id number;
    --
    cursor c_sysadmin_usr is
        select usr.user_id
        from fnd_user usr
        where usr.user_name = 'SYSADMIN';
    --
    cursor c_get_responsibility_id(p_user_id number) is
        select fur.responsibility_id, fur.responsibility_application_id
        from fnd_user_resp_groups fur
        where fur.user_id = p_user_id
        order by fur.responsibility_id;
    --
    cursor c_get_application_id(p_resp_id number) is
        select resp.application_id
        from fnd_responsibility resp
        where resp.responsibility_id = p_resp_id;
    --
BEGIN
    -- if user_id is null then set to sysadmin user
    if p_user_id is null then
       OPEN c_sysadmin_usr;
       FETCH c_sysadmin_usr INTO l_user_id;
       if c_sysadmin_usr%notfound then
         CLOSE c_sysadmin_usr;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_on');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
       else
         CLOSE c_sysadmin_usr;
       end if;
    else
       l_user_id := p_user_id;
    end if;
    --
    -- if responsibility_id is null then select first resp in
    -- list ordered by resp key
    if p_responsibility_id is null then
       OPEN  c_get_responsibility_id(l_user_id);
       FETCH c_get_responsibility_id INTO l_responsibility_id,
                                          l_application_id;
       if c_get_responsibility_id%notfound then
         CLOSE c_get_responsibility_id;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_on');
         hr_utility.set_message_token('STEP','2');
         hr_utility.raise_error;
       else
         CLOSE c_get_responsibility_id;
       end if;
    else
       l_responsibility_id := p_responsibility_id;
       open c_get_application_id(p_responsibility_id);
       fetch c_get_application_id into l_application_id;
       if c_get_application_id%notfound then
         close c_get_application_id;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_on');
         hr_utility.set_message_token('STEP','3');
         hr_utility.raise_error;
       else
         close c_get_application_id;
       end if;
    end if;

    -- initialize user/resp
    fnd_global.apps_initialize(l_user_id,
                               l_responsibility_id,
                               l_application_id);
    --
    -- set user profiles to enable logging and set level
     l_b:=fnd_profile.save_user('AFLOG_ENABLED','Y');
     l_b:=fnd_profile.save_user('AFLOG_LEVEL',to_char(p_logging_level));
    --
    -- re-initialize to enable user profiles
    fnd_global.apps_initialize(l_user_id,
                               l_responsibility_id,
                               l_application_id);
    --
    -- commit profile option settings
    commit;
    --
END switch_logging_on;
--
-------------------------------- switch_logging_off -------------------------
/*
  NAME
    switch_logging_off

  DESCRIPTION
    Turns off AOL debug messaging previously turned on by calling
    switch_logging_on. Logging is disabled by setting user profile
    options for the user defined in the prior call to switch_logging_on.
    If switch_logging_on is not called before calling
    switch_logging_off, the user is set to 'SYSADMIN'.

*/
procedure switch_logging_off is
    --
    -- we'll be updating user profile values so use an autonomous transaction
    pragma autonomous_transaction;
    --
    l_b boolean;
    l_user_id number;
    l_responsibility_id number;
    l_application_id number;
    l_temp_responsibility_id number;
    l_temp_application_id number;
    --
    cursor c_sysadmin_usr is
        select usr.user_id
        from fnd_user usr
        where usr.user_name = 'SYSADMIN';
    --
    cursor c_get_responsibility_id(p_user_id number) is
        select fur.responsibility_id, fur.responsibility_application_id
        from fnd_user_resp_groups fur
        where fur.user_id = p_user_id
        order by fur.responsibility_id;
    --
    cursor c_get_application_id(p_resp_id number) is
        select resp.application_id
        from fnd_responsibility resp
        where resp.responsibility_id = p_resp_id;
--
BEGIN
    --
    l_user_id := fnd_global.user_id;
    -- if user_id is not set then set to sysadmin user
    if l_user_id = -1 then
      OPEN c_sysadmin_usr;
      FETCH c_sysadmin_usr INTO l_user_id;
      if c_sysadmin_usr%notfound then
        CLOSE c_sysadmin_usr;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_off');
        hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
      else
        CLOSE c_sysadmin_usr;
      end if;
    end if;
    --
    l_responsibility_id := fnd_global.resp_id;
    -- if responsibility_id is null then select first resp in list
    -- ordered by resp key
    if l_responsibility_id = -1 then
      OPEN  c_get_responsibility_id(l_user_id);
      FETCH c_get_responsibility_id INTO l_responsibility_id, l_application_id;
      if c_get_responsibility_id%notfound then
        CLOSE c_get_responsibility_id;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_off');
        hr_utility.set_message_token('STEP','2');
        hr_utility.raise_error;
      else
        CLOSE c_get_responsibility_id;
      end if;
    else
      open c_get_application_id(l_responsibility_id);
      fetch c_get_application_id into l_application_id;
      if c_get_application_id%notfound then
        close c_get_application_id;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', 'hr_utility.switch_logging_off');
        hr_utility.set_message_token('STEP','3');
        hr_utility.raise_error;
      else
        close c_get_application_id;
      end if;
    end if;
    --
    -- initialize as user/resp
    fnd_global.apps_initialize(l_user_id,
                               l_responsibility_id,
                               l_application_id);
    --
    -- set user profiles to disable logging and set level
    l_b:=fnd_profile.save_user('AFLOG_ENABLED','N');
    l_b:=fnd_profile.save_user('AFLOG_LEVEL',null);
    --
    -- re-initialize to enable user profiles
    fnd_global.apps_initialize(l_user_id,
                               l_responsibility_id,
                               l_application_id);
    --
    -- commit profile option settings
    commit;
    --
END switch_logging_off;

---------------------------- debug_enabled -------------------------
/*
  NAME
    debug_enabled

  DESCRIPTION
    Please see package specification for a description and usage examples.
*/
function debug_enabled return boolean is
begin
  return( fnd_log.g_current_runtime_level <= fnd_log.level_procedure
          or hr_utility.g_trace_on ) ;
end debug_enabled;

/*Function added to get the ICX Attribute value*/
   FUNCTION get_icx_val(p_attribute_name varchar2,p_session_id number)
   RETURN VARCHAR2
   IS
    p_value varchar2(250);

    CURSOR csr_prof_value(p_att_name varchar2,p_sess_id number) is
    SELECT  value
    FROM icx_session_attributes
    WHERE session_id = p_sess_id
    AND name = p_att_name;


    BEGIN

     OPEN csr_prof_value(p_attribute_name,p_session_id);
	 FETCH csr_prof_value INTO p_value;
	 CLOSE csr_prof_value;

     RETURN p_value;

    EXCEPTION
    WHEN OTHERS THEN
    RETURN '0';

    END;

end hr_utility;

/

  GRANT EXECUTE ON "APPS"."HR_UTILITY" TO "HR";
