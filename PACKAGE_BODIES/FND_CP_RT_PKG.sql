--------------------------------------------------------
--  DDL for Package Body FND_CP_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_RT_PKG" as
/* $Header: AFCPPRTB.pls 120.2 2007/12/18 22:23:51 ckclark ship $ */
 --
 -- Package
 --   FND_CP_RT_PKG
 --
 -- Purpose
 --   Concurrent processing PL/SQL regression testing
 --
 -- History
 --   XX-XXX-02	Christina Clark         Created
 --

  --
  -- PRIVATE VARIABLES
  --

  --
  -- EXCEPTION INFO
  --

  --
  -- PRIVATE PROCEDURES/FUNCTIONS
  --

  -- --
  -- Name
  --   section_title
  -- Purpose
  --   Called to print title for each section
  -- Parameters
  --   which - log or output file? Either FND_FILE.LOG or FND_FILE.OUTPUT
  --   title - title of section
  --
  -- --

  procedure section_title (which IN number,
                           title IN varchar2) is

  begin
     FND_FILE.NEW_LINE(which);
     FND_FILE.PUT_LINE(which, '----------------------------------------------------------------');
     FND_FILE.PUT_LINE(which, title);
     FND_FILE.PUT_LINE(which, '----------------------------------------------------------------');
  end section_title;

  --
  -- PUBLIC PROCEDURES/FUNCTIONS
  --

  /* Sleep for duration seconds */
  procedure sleep (               duration IN varchar2) is
    begin
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sleeping for '
                                      || duration
                                      || ' seconds... Current time: '
                                      || to_char(sysdate, 'DD-MON-RR HH24:MI:SS'));

      DBMS_LOCK.SLEEP(TO_NUMBER(duration));

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sleep finished... Current time: '
                                      || to_char(sysdate, 'DD-MON-RR HH24:MI:SS'));
      FND_FILE.NEW_LINE(FND_FILE.LOG);
    end sleep;

  /* Run program in stripped down fashion */
  procedure basic(                errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2) is
    begin

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of Concurrent Processing Regression Test...');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'End of Concurrent Processing Regression Test...');
        -- -----------------------------
        -- Set errbuf and retcode
        -- -----------------------------
        errbuf := 'Success';
        retcode := 0 ;
        return;
    end basic;

  /* Select and display data */
  procedure verify_values (       run_mode IN varchar2,
                                  duration IN varchar2,
                                  p_num IN varchar2,
                                  p_date IN varchar2,
                                  p_varchar IN varchar2) is

    l_nls_lang          nls_session_parameters.value%TYPE;
    l_nls_terr          nls_session_parameters.value%TYPE;
    l_nls_num_char      nls_session_parameters.value%TYPE;
    l_nls_date_fmt      nls_session_parameters.value%TYPE;
    l_nls_date_lang     nls_session_parameters.value%TYPE;
    l_db_inst           v$instance.instance_name%TYPE;

  begin
    -- ----------------------------------------------
    -- Use FND_FILE to output messages at each stage
    -- ----------------------------------------------

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of Concurrent Processing Regression Test...');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Start of Concurrent Processing Regression Test...');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    --
    -- Verify IN parameter values
    -- Right now we simply print out all three as varchar parameters.  May find value
    -- later in adding some verification for dates and numbers...
    --
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Verify IN parameter values...');
    section_title(FND_FILE.OUTPUT, 'Verify IN parameter values...');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'run_mode = ' || run_mode);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'duration = ' || duration);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_num = ' ||  nvl(p_num, 'NULL'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_date = ' || nvl(p_date, 'NULL'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_varchar ' || nvl(p_varchar, 'NULL'));

    --
    -- Verify the FND_GLOBAL values
    --
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Verify FND_GLOBAL values...');
    SECTION_TITLE(FND_FILE.OUTPUT, 'Verify FND_GLOBAL values...');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'User name = ' || fnd_global.user_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'User id = ' || fnd_global.user_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resp name = ' || fnd_global.resp_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resp id = ' || fnd_global.resp_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resp app name = ' || fnd_global.application_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resp app short name = ' || fnd_global.application_short_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resp app id = ' || fnd_global.resp_appl_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Security group id = ' || fnd_global.security_group_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Login id = ' || fnd_global.login_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Conc login id = ' || fnd_global.conc_login_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Prog app id = ' || fnd_global.prog_appl_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Conc program id = ' || fnd_global.conc_program_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Conc request id = ' || fnd_global.conc_request_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Conc priority request = ' || fnd_global.conc_priority_request);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Per business group id = ' || fnd_global.per_business_group_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Per security profile id = ' || fnd_global.per_security_profile_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Language count = ' || fnd_global.language_count);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Current language = ' || fnd_global.current_language);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Base language = ' || fnd_global.base_language);

    --
    -- Verify NLS session parameter values
    --
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Verify NLS session parameter values...');
    SECTION_TITLE(FND_FILE.OUTPUT, 'Verify NLS session parameter values...');

    Select Value Into l_nls_lang
    From   Nls_Session_Parameters
    Where  Upper(Parameter) = 'NLS_LANGUAGE';
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NLS_LANGUAGE = ' || l_nls_lang);

    Select Value Into l_nls_terr
    From   Nls_Session_Parameters
    Where  Upper(Parameter) = 'NLS_TERRITORY';
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NLS_TERRITORY = ' || l_nls_terr);

    Select Value Into l_nls_num_char
    From   Nls_Session_Parameters
    Where  Upper(Parameter) = 'NLS_NUMERIC_CHARACTERS';
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NLS_NUMERIC_CHARACTERS = ' || l_nls_num_char);

    Select Value Into l_nls_date_fmt
    From   Nls_Session_Parameters
    Where  Upper(Parameter) = 'NLS_DATE_FORMAT';
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NLS_DATE_FORMAT = ' || l_nls_date_fmt);

    Select Value Into l_nls_date_lang
    From   Nls_Session_Parameters
    Where  Upper(Parameter) = 'NLS_DATE_LANGUAGE';
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'NLS_DATE_LANGUAGE = ' || l_nls_date_lang);

    --
    -- Verify current database instance
    --
    Select Instance_Name Into l_db_inst
    From   V$Instance;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Current DB Instance = ' || l_db_inst);


  end verify_values;

  /* Submit a single request */
  procedure submit_single_request(errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2) is

    l_rpt_end_time      varchar2(30);
    l_printer           fnd_printer.printer_name%TYPE;
    reqid               fnd_concurrent_requests.request_id%TYPE;

  begin

         -- -----------------------
         -- Submit a single request
         -- -----------------------
         FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Submit a single request...');
         SECTION_TITLE(FND_FILE.LOG, 'Submit a single request...');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Prepare to submit a single request...');

         -- Set repeat options
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Set repeat options...2 resubmissions, 1 min apart, increment dates.');

         Select to_char(SYSDATE + (3/1440), 'DD-MON-YYYY HH24:MI:SS')
         Into   l_rpt_end_time
         From   Dual;
         if (not fnd_request.set_repeat_options(
                                     repeat_interval => 1,
                                     repeat_unit => 'MINUTES',
                                     repeat_end_time => l_rpt_end_time,
                                     increment_dates => 'Y'))
         then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
         end if;

         -- Set print options

         FND_PROFILE.GET('PRINTER', l_printer);
         if l_printer IS NULL then
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Printer is null, will not set print options.');
         else
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Printer is ' || l_printer );
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Set print options...one copy to default printer.');
         end if;
         if (not fnd_request.set_print_options(
                                     printer => l_printer,
                                     style => 'PORTRAIT',
                                     copies => 1,
                                     save_output => TRUE,
                                     print_together => NULL))
         then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
         end if;

         -- Add a notification to SYSADMIN user
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Add notification to SYSADMIN user...');

         if (not fnd_request.add_notification(user => 'SYSADMIN')) then
             errbuf := substr(fnd_message.get, 1, 240);
             retcode := 2;
             rollback;
             return;
         end if;

         -- Submit the request for FNDCPRT_PLSQL with run_mode='BASIC'
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submit a request for FNDCPRT_PLSQL in BASIC run_mode...');

         reqid := fnd_request.submit_request(application => 'FND',
                                             program => 'FNDCPRT_PLSQL',
                                             description => 'Test of Single Request Submission',
                                             argument1 => 'BASIC');  -- run_mode = 'BASIC'

         if reqid = 0 then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
         end if;

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Single submission request id = ' || reqid);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Single request submission completed successfully.');
  end submit_single_request;

  /* Submit a single child request */
  procedure submit_sub_request(   errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2) is

    reqid               fnd_concurrent_requests.request_id%TYPE;

  begin
         -- ---------------------------
         -- Submit a single sub-request
         -- ---------------------------
         FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Submit a single sub-request...');
         SECTION_TITLE(FND_FILE.LOG, 'Submit a single sub-request...');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submit a single sub-request...');
         -- Submit the child request.  The sub_request parameter must be set to 'Y'.
         reqid := fnd_request.submit_request(application => 'FND',
                                             program => 'FNDCPRT_PLSQL',
                                             description => 'Test of Single Sub-request Submission',
                                             sub_request => TRUE,
                                             argument1 => 'BASIC');  -- run_mode = 'BASIC'

         if reqid = 0 then
           -- If request submission failed, exit with error.
           errbuf := fnd_message.get;
           retcode := 2;
         else
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Single sub-request submission completed successfully.');

           errbuf := 'Phase 1 complete:';
           retcode := 0 ;
         end if;

         return;

  end submit_sub_request;

  /* Submit a request set */
  procedure submit_request_set(   errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2) is

    l_success           boolean;
    reqid               fnd_concurrent_requests.request_id%TYPE;
    req_data            varchar2(10);
    srs_failed          exception;
    submitprog_failed   exception;
    submitset_failed    exception;

  begin

       -- --------------------
       -- Submit a request set
       -- --------------------

       FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Submit a request set...');
       SECTION_TITLE(FND_FILE.LOG, 'Submit a request set...');

       -- Step 1 - call set_request_set
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call set_request_set...');

       l_success := fnd_submit.set_request_set('FND', 'FNDCPRT_SET');
       if ( not l_success ) then
          raise srs_failed;
       end if;

       -- Step 2 - call submit program for each program in the set

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program first time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_PLSQL', 'STAGE10', 'BASIC', '0',  chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program second time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_SQLPLUS', 'STAGE20', 'BASIC', '0', '', '', '', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program third time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_HOST', 'STAGE30', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program fourth time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_SQLLOAD', 'STAGE40', '$FND_TOP/patch/115/import/fndcpldr.dat', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program fifth time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_JAVA', 'STAGE50', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program sixth time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_SPWN', 'STAGE60', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program seventh time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_RPTTXT', 'STAGE70', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program eighth time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_RPTPS', 'STAGE80', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
       end if;

	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit program ninth time...');

       l_success := fnd_submit.submit_program('FND','FNDCPRT_PERL', 'STAGE90', 'BASIC', '0', chr(0));
       if ( not l_success ) then
          raise submitprog_failed;
	   end if;

       -- Step 3 - call submit_set
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Call submit_set...');

       -- ----------------------------------------------
       -- If we are running as a PL/SQL concurrent program, submit the set as a sub-request.
       -- If we are running as a standalone PL/SQL procedure, submit the set as an in indivdual request.
       -- Check req_data: if NULL, we are running as a standalone
       -- ----------------------------------------------
       req_data := fnd_conc_global.request_data;
       if (req_data IS NULL) then
         reqid := fnd_submit.submit_set(null,false);
       else
         reqid := fnd_submit.submit_set(null,true);
       end if;

       if (reqid = 0 ) then
          raise submitset_failed;
       end if;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Request set submission completed successfully.');

       errbuf := 'Phase 2 complete:';
       retcode := 0 ;

       return;
  exception
      when srs_failed then
        errbuf := 'Call to set_request_set failed: ' || fnd_message.get;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, errbuf);
      when submitprog_failed then
        errbuf := 'Call to submit_program failed: ' || fnd_message.get;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, errbuf);
      when submitset_failed then
        errbuf := 'Call to submit_set failed: ' || fnd_message.get;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, errbuf);
      when others then
        errbuf := 'Request set submission failed - unknown error: ' || sqlerrm;
        retcode := 2;
        fnd_file.put_line(fnd_file.log, errbuf);

  end submit_request_set;

  /* Write a message that all phases complete */
  procedure finish(               errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2) is

  begin

      FND_FILE.NEW_LINE(FND_FILE.LOG, 2);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'All tests complete!');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'End of Concurrent Processing Regression Test...');
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'End of Concurrent Processing Regression Test...');


      errbuf := 'Success:';
      retcode := 0 ;
      return;

  end finish;

  /* Main concurrent program procedure */
  procedure fnd_cp_rt_proc(
                                  errbuf    out NOCOPY varchar2,
                                  retcode   out NOCOPY varchar2,
                                  run_mode  in  varchar2 default 'BASIC',
                                  duration  in  varchar2 default '0',
                                  p_num     in  varchar2 default NULL,
                                  p_date    in  varchar2 default NULL,
                                  p_varchar in  varchar2 default NULL) is

    req_data            varchar2(10);

  begin

    -- ----------------------------------------------
    --   Check req_data:
    --   if req_data IS NULL, first time into the program - Phase 1
    --   if req_data = 'Phase_2' reawakened after sub-request has completed - Phase 2
    --   if req_data = 'Phase_3' reawakened after request set has completed - Phase 3
    -- ----------------------------------------------
    req_data := fnd_conc_global.request_data;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'req_data = ' || req_data);

    if (req_data IS NULL and TO_NUMBER(duration) > 0) then
      sleep (duration);
    end if;

    if (upper(run_mode) = 'FULL') then

      if (req_data IS NULL) then
        /*------------------------------------------------------------------------------+
        | PHASE 1                                                                       |
        +-------------------------------------------------------------------------------*/
        sleep(duration);
        verify_values(run_mode, duration, p_num, p_date, p_varchar);
        submit_single_request(errbuf, retcode);
        submit_sub_request(errbuf, retcode);

        -- Set the globals to put the program into the PAUSED status on exit,
        -- and to save the state in request_data.
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => 'Phase_2') ;

      elsif (req_data = 'Phase_2') then -- Phase 1 has completed
        /*------------------------------------------------------------------------------+
        | PHASE 2                                                                       |
        +-------------------------------------------------------------------------------*/
        submit_request_set(errbuf, retcode);
        -- Here we set the globals to put the program into the PAUSED status on exit,
        -- and to save the state in request_data.
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => 'Phase_3') ;

      else                              -- Phase 2 has completed
        /*-------------------------------------------------------------------------------+
         | PHASE 3                                                                       |
         +-------------------------------------------------------------------------------*/
        finish(errbuf, retcode);
        -- Set globals to set request_data for program into FINISHED state
        fnd_conc_global.set_req_globals(request_data => 'Finished');
      end if;

    elsif (upper(run_mode) = 'BASIC') then
      basic(errbuf, retcode);
    else
      -- -----------------------------
      -- Set errbuf and retcode
      -- -----------------------------
      errbuf := 'Failure: Invalid RUN_MODE parameter:  '|| run_mode;
      retcode := 2 ;
      return;
    end if;

  end fnd_cp_rt_proc;

end fnd_cp_rt_pkg;

/
