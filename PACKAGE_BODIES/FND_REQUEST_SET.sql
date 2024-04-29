--------------------------------------------------------
--  DDL for Package Body FND_REQUEST_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REQUEST_SET" as
/* $Header: AFRSSUBB.pls 120.14.12010000.7 2015/01/26 21:15:50 jtoruno ship $ */


-- Used to get stage function values
g_set_id number;
g_set_appl_id number;
g_stage_id number;
g_function_id number;
g_function_appl_id number;

/*
** GEN_ERROR (Internal)
**
** Return error message for unexpected sql errors
*/
function GEN_ERROR(routine in varchar2,
	           errcode in number,
	           errmsg in varchar2) return varchar2 is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    return substr( fnd_message.get, 1, 240);
end;


/*
** FNDRSSUB
**
** Request set master program.
**
*/
procedure FNDRSSUB  (errbuf    out nocopy varchar2,
                     retcode   out nocopy number,
                     appl_id   in number,
                     set_id    in number) is
  stage_id         number;        /* ID of current stage.            */
  req_id           number;        /* Request_ID for current stage.   */
  req_data         varchar2(240); /* State of last FNDRSSUB run.     */
  pos              number;        /* Counter for parsing req_data.   */
  pos2             number;        /* Counter for parsing req_data.   */
  critical_outcome varchar2(240);  /* Outcome and name of last       */
                                  /*   critical stage.               */
  previous_outcome varchar2(1);
  next_stage       number;        /* Next stage to run.              */
  current_outcome  varchar2(1);   /* Outcome of current stage.       */
            /*   'S' = Success                 */
            /*   'W' = Warning                 */
            /*   'E' = Error                   */
  is_critical      varchar2(1);   /* Is the current stage critical?  */
  user_stage_name  varchar2(240); /* Name of the current stage.      */
  outcome_meaning  varchar2(80);  /* Translated outcome meaning.     */
  critical_stages  boolean;       /* Were any critical stages        */
                                  /*   executed in this set?         */
  request_desc     varchar2(240); /* Description for submit_request  */
  conc_req_id      number; /* Request Id for the Concurrent Program */
  runinfo_id       varchar2(2); /* Flag to find whether request is started or restarted*/
  error_stage_id   number; /*Stage id of failed stage in the last run.*/
  restart_flag     number; /* represents whether stage needs to be restarted or not */
  req_request_date date;
  rset_last_updated_date date;
  tmpDate               date;
  tmp_number            number;
  current_run_number    number;
  /*Bug 5680669*/
  t_app_name        varchar2(50);
  req_set_name      varchar2(30);
  warn_flag         varchar2(1)     default 'N';
  tmp_buf        varchar2(240);

begin
  /* Get state from last run if any. */
  req_data := fnd_conc_global.request_data;
  conc_req_id := fnd_global.conc_request_id();
  restart_flag := 0;

    /*Bug 5680669 -START-*/
select fa.application_short_name,frs.request_set_name
into t_app_name, req_set_name
from fnd_request_sets_vl frs, fnd_application fa
where frs.application_id=appl_id
and frs.request_set_id=set_id
and frs.application_id=fa.application_id;

tmp_buf := fnd_submit.justify_program(t_app_name,req_set_name);
if tmp_buf is not null then
  if substr(tmp_buf,1,1) = 'E' then
        fnd_message.set_name('FND','CONC-RS-CRITICAL DISABLED');
        fnd_message.set_token('PROGRAM', substr(tmp_buf,3,240));
        errbuf := substr(fnd_message.get, 1, 240);
        retcode := 2;
        return;
  elsif substr(tmp_buf,1,1) = 'W' then
        warn_flag := 'Y';
        fnd_message.set_name('FND','CONC-RS-NONCRITICAL DISABLED');
        fnd_message.set_token('PROGRAM', substr(tmp_buf,3,240));
        tmp_buf := substr(fnd_message.get, 1, 240);
  end if;
end if;
  /*Bug 5680669 -END-*/

  /* Is this the first run? */
  if (req_data is null) then
    update FND_CONCURRENT_REQUESTS set RUN_NUMBER = 1 where request_id = conc_req_id;
    /* Get info for first stage. */
    begin
      select request_set_stage_id, request_set_stage_id, user_stage_name
        into stage_id, next_stage, request_desc
        from fnd_request_sets sets,
             fnd_request_set_stages_vl stages
        where sets.application_id = appl_id
          and sets.request_set_id = set_id
          and stages.set_application_id = sets.application_id
          and stages.request_set_id = sets.request_set_id
          and sets.start_stage = stages.request_set_stage_id;
    exception
      when NO_DATA_FOUND then
        fnd_message.set_name('FND','CONC-Missing first stage');
        errbuf := substr(fnd_message.get, 1, 240);
        retcode := 2;
        return;
    end;
    /* Initialize critical outcome */
    critical_outcome := 'NONE';
    runinfo_id := 'F';
  else /* Program was restarted */
     /* Parse Request data: "runinfo_id, Error Stage, stage_id, request_id, critical_outcome" */
     /* runinfo_id can take Following values
       (null) - Request Set was running for the first time, this module is getting invoked first time.
       F      - Request Set was running for the first time, this module is invoked more than once
       R      - Request Set was restarted.
       C      - Request Set completed it's Execution.
       */
    pos := instr(req_data, ',', 1, 1);
    runinfo_id := substr(req_data, 1, pos - 1);
    pos2 := instr(req_data, ',', pos + 1, 1);
    error_stage_id := to_number(substr(req_data, pos + 1, pos2 - pos -1));
    pos := pos2;
    pos2 := instr(req_data, ',', pos + 1, 1);
    stage_id := to_number(substr(req_data, pos + 1, pos2 - pos -1));
    pos := pos2;
    pos2 := instr(req_data, ',', pos + 1, 1);
    req_id := to_number(substr(req_data, pos + 1, pos2 - pos -1));
    /* bug 1961715 Removed null as the 3rd parameter */
    critical_outcome := substr(req_data, pos2 + 1);
    if (runinfo_id = 'C') then
      begin
      select REQUEST_DATE into req_request_date from FND_CONCURRENT_REQUESTS where REQUEST_ID = conc_req_id;
    select LAST_UPDATE_DATE into rset_last_updated_date from FND_REQUEST_SETS sets
    where REQUEST_SET_ID = set_id AND application_id = appl_id;
    SELECT max(last_update_date) INTO tmpDate FROM fnd_request_set_stages
    WHERE request_set_id = set_id
      AND SET_APPLICATION_ID = appl_id;
    IF( tmpDate > rset_last_updated_date) THEN
      rset_last_updated_date := tmpDate;
    END IF;
    SELECT max(last_update_date) INTO tmpDate FROM fnd_request_set_programs
    WHERE request_set_id = set_id AND set_application_id = appl_id;
    IF( tmpDate > rset_last_updated_date) THEN
      rset_last_updated_date := tmpDate;
    END IF;
    if( rset_last_updated_date > req_request_date ) then
        errbuf := gen_error('FNDRSSUB', SQLCODE, 'Request Set Definition Changed');
        retcode := 2;
        return;
    end if;
    exception
    when no_data_found then
      NULL;
  end;
  SELECT run_number INTO current_run_number FROM fnd_concurrent_requests WHERE request_id = conc_req_id;
  select count(r.request_set_program_id) INTO tmp_number
  from fnd_run_requests r,
             fnd_concurrent_requests fcr1, fnd_concurrent_requests fcr2
       where r.parent_request_id = conc_req_id
         and fcr1.parent_request_id = fcr2.request_id
         and fcr1.concurrent_program_id = r.concurrent_program_id
         and r.request_id = fcr1.request_id
         and fcr1.status_code = 'E'
         and fcr2.parent_request_id = conc_req_id
         and fcr2.run_number = current_run_number
         and error_stage_id = to_number(fcr2.argument3)
         AND r.request_set_program_id IS NOT NULL
         AND r.request_set_program_id NOT IN
         (
         SELECT REQUEST_SET_PROGRAM_ID FROM FND_REQUEST_SET_PROGRAMS WHERE SET_APPLICATION_ID = appl_id
         AND REQUEST_SET_ID = set_id AND REQUEST_SET_STAGE_ID = error_stage_id
         );
    if( tmp_number <> 0)THEN
        errbuf := gen_error('FNDRSSUB', SQLCODE, 'Request Set Definition Changed');
        retcode := 2;
        return;
    END IF;


      if ( error_stage_id IS null )  then
        errbuf := gen_error('FNDRSSUB', SQLCODE, 'Already Succeeded or Last Error Stage id not available');
        retcode := 2;
        return;
      else
        begin
        update FND_CONCURRENT_REQUESTS set RUN_NUMBER = RUN_NUMBER + 1, COMPLETION_TEXT = null where request_id = conc_req_id;
        critical_outcome := 'NONE';
        restart_flag := 1;
        runinfo_id := 'R';
        stage_id := error_stage_id;
        error_stage_id := null;
        select request_set_stage_id, user_stage_name
          into next_stage, request_desc
          from fnd_request_set_stages_vl stages
          where stages.set_application_id = appl_id
            and stages.request_set_id = set_id
            and stages.request_set_stage_id = stage_id;
        exception
        when NO_DATA_FOUND then
          fnd_message.set_name('FND','CONC-Missing first stage');
          errbuf := substr(fnd_message.get, 1, 240);
          retcode := 2;
          return;
        end;
      end if;
    else
      /* Get status for current stage */
      begin
        select decode(status_code, 'C', 'S', 'G', 'W', 'E')
          into current_outcome
          from fnd_concurrent_requests
          where request_id = req_id;
      exception
        when NO_DATA_FOUND then
          fnd_message.set_name('FND','CONC-Missing Request');
          fnd_message.set_token('ROUTINE', 'FND_REQUEST_SET.FNDRSSUB');
          fnd_message.set_token('REQUEST', to_char(req_id));
          errbuf := fnd_message.get;
          retcode := 2;
          return;
      end;
      /* Get Next Stage and Critical info*/
      begin
        select decode(current_outcome, 'S', success_link, 'W', warning_link, error_link), critical, user_stage_name
          into next_stage, is_critical, user_stage_name
          from fnd_request_set_stages_vl
          where request_set_id = set_id
          and set_application_id = appl_id
          and request_set_stage_id = stage_id;
        exception
        when NO_DATA_FOUND then
          fnd_message.set_name('FND','CONC-Missing stage');
          errbuf := substr(fnd_message.get,1, 240);
          retcode := 2;
          return;
      end;
      /* update the error stage id in this run */
      if( current_outcome = 'E' and error_stage_id is null ) then
        error_stage_id := stage_id;
      end if;
      /* Update critical_outcome if necessary */
      /*  new code added to check the outcome of all the stages
          if we have more than one critical stages then
          considering the 'worst' critical stage outcome as set outcome
          bug 3785411
      */
     /* Bug10116616: Added the condition previous_outcome = 'W' to
         consider the previous warning outcome */
      if (is_critical = 'Y') then
        previous_outcome := substr(critical_outcome, 1, 1);
        if (previous_outcome <> 'E') then
          if(current_outcome = 'E') then
            critical_outcome := substrb(current_outcome || user_stage_name, 1, 240);
          elsif(current_outcome = 'W' /*AND previous_outcome <> 'W'*/) then
            critical_outcome := substrb(current_outcome || user_stage_name, 1, 240);
          /*elsif(current_outcome = 'S' AND previous_outcome = 'W') then
            critical_outcome := substrb(previous_outcome || user_stage_name, 1, 240);*/
          elsif(current_outcome = 'S' AND previous_outcome <> 'W') then
            critical_outcome := substrb(current_outcome || user_stage_name, 1, 240);
          end if;
        end if;
      end if;
      /* Is the set complete? */
      if (next_stage is null) then
        /* Were there any critical stages? */
        if (critical_outcome <> 'NONE') then
          critical_stages := TRUE;
          current_outcome := substr(critical_outcome, 1, 1);
          /* bug 1961715 Removed null as the 3rd parameter */
          user_stage_name := substr(critical_outcome, 2);
        else
          critical_stages := FALSE;
        end if;
        /* Get final outcome meaning */
        select meaning
          into outcome_meaning
          from fnd_lookups
          where lookup_type = 'CP_SET_OUTCOME'
          and lookup_code = current_outcome;
        retcode := to_number(translate(current_outcome, 'SWE', '012'));
        if (critical_stages) then
          fnd_message.set_name('FND','CONC-Set Completed Critical');
        else
          fnd_message.set_name('FND', 'CONC-Set Completed');
        end if;
        fnd_message.set_token('OUTCOME', outcome_meaning);
        fnd_message.set_token('STAGE', user_stage_name);
        errbuf := substr(fnd_message.get, 1, 240);
        fnd_conc_global.set_req_globals( request_data =>
          substrb( 'C,' || to_char(error_stage_id) || ',' || to_char(stage_id) || ',' ||
          to_char(req_id)   || ',' ||
          critical_outcome, 1, 240));

	  /*Bug 5680669 */
	  if warn_flag = 'Y' then
            retcode := 1;
            errbuf := tmp_buf;
          end if;
        return;
      end if;
      /* Get next stage  */
      begin
        Select user_stage_name
          into request_desc
          from fnd_request_set_stages_vl
         where request_set_id = set_id
           and set_application_id = appl_id
           and request_set_stage_id = next_stage;
        exception
        when NO_DATA_FOUND then
          if (current_outcome = 'S') then
            fnd_message.set_name('FND','CONC-BAD SUCCESS LINK');
          elsif (current_outcome = 'W') then
            fnd_message.set_name('FND','CONC-BAD WARNING LINK');
          else
            fnd_message.set_name('FND','CONC-BAD ERROR LINK');
          end if;
          errbuf := substr(fnd_message.get,1, 240);
          retcode := 2;
          return;
      end;
    end if;
  end if;
  /* Submit Request for the stage. */
  fnd_request.internal(type=>'S');
  req_id := fnd_request.submit_request('FND', 'FNDRSSTG',
       request_desc, NULL, TRUE,
       to_char(appl_id), to_char(set_Id),
       to_char(next_stage),
       to_char(fnd_global.conc_request_id),to_char(restart_flag));
  if (req_id = 0) then
    errbuf := substr(fnd_message.get,1, 240);
    retcode := 2;
    return;
  else
     update fnd_concurrent_requests set RUN_NUMBER =
          (select RUN_NUMBER from fnd_concurrent_requests where request_id = conc_req_id)
          where request_id = req_id;
     fnd_conc_global.set_req_globals(
                     conc_status => 'PAUSED',
                     request_data => runinfo_id||','||to_char(error_stage_id)||','||substrb( to_char(next_stage) || ',' ||
                     to_char(req_id)   || ',' ||
                     critical_outcome, 1, 240));
     fnd_message.set_name('FND','CONC-Stage Submitted');
     fnd_message.set_token('STAGE', request_desc);
     errbuf := substr(fnd_message.get,1, 240);
     retcode := 0;
     return;
  end if;

  exception
    when OTHERS then
      errbuf := gen_error('FNDRSSUB', SQLCODE, SQLERRM);
      retcode := 2;
      return;
end FNDRSSUB;


/*
** FNDRSSTG
**
** Request set stage master program.
**
*/
procedure FNDRSSTG  (errbuf            out nocopy varchar2,
                     retcode           out nocopy number,
                     appl_id           in number,
                     set_id            in number,
                     stage_Id          in number,
                     parent_id         in number,
                     restart_flag      in number default 0) is
cursor stage_requests(appl_id number, set_id number,
                      stage_id number, parent_id number) is
  select sp.critical,
         sp.sequence,
         a.application_short_name,
         cp.concurrent_program_name,
         r.request_set_program_id,
         r.application_id,
         r.concurrent_program_id,
         r.number_of_copies,
         r.printer,
         r.print_style,
         r.save_output_flag,
         r.nls_language,
         r.nls_territory,
/* NLS Project */
         r.numeric_characters,
         r.nls_sort,
         argument1, argument2, argument3, argument4, argument5,
         argument6, argument7, argument8, argument9, argument10,
         argument11, argument12, argument13, argument14, argument15,
         argument16, argument17, argument18, argument19, argument20,
         argument21, argument22, argument23, argument24, argument25,
         argument26, argument27, argument28, argument29, argument30,
         argument31, argument32, argument33, argument34, argument35,
         argument36, argument37, argument38, argument39, argument40,
         argument41, argument42, argument43, argument44, argument45,
         argument46, argument47, argument48, argument49, argument50,
         argument51, argument52, argument53, argument54, argument55,
         argument56, argument57, argument58, argument59, argument60,
         argument61, argument62, argument63, argument64, argument65,
         argument66, argument67, argument68, argument69, argument70,
         argument71, argument72, argument73, argument74, argument75,
         argument76, argument77, argument78, argument79, argument80,
         argument81, argument82, argument83, argument84, argument85,
         argument86, argument87, argument88, argument89, argument90,
         argument91, argument92, argument93, argument94, argument95,
         argument96, argument97, argument98, argument99, argument100,
         r.org_id, r.recalc_parameters
    from fnd_request_set_programs sp, fnd_run_requests r,
         fnd_concurrent_programs cp, fnd_application a
   where sp.set_application_id = appl_id
     and sp.request_set_id = set_id
     and sp.request_set_stage_id = stage_id
     and sp.request_set_program_id = r.request_set_program_id
     and sp.set_application_id = r.set_application_id
     and sp.request_set_id = r.request_set_id
     and r.parent_request_id = parent_id
     and a.application_id = r.application_id
     and cp.application_id = r.application_id
     and cp.concurrent_program_id = r.concurrent_program_id
   order by sp.sequence;

  cursor stage_requests_restart( appl_id number, set_id number,
                                 stage_id number, parent_id number,
				 current_run_number number) is
     select sp.critical,
             sp.sequence,
             a.application_short_name,
             cp.concurrent_program_name,
             r.request_set_program_id,
             r.application_id,
             r.concurrent_program_id,
             r.number_of_copies,
             r.printer,
             r.print_style,
             r.save_output_flag,
             r.nls_language,
             r.nls_territory,
    /* NLS Project */
             r.numeric_characters,
             r.nls_sort,
             r.argument1, r.argument2, r.argument3, r.argument4, r.argument5,
             r.argument6, r.argument7, r.argument8, r.argument9, r.argument10,
             r.argument11, r.argument12, r.argument13, r.argument14, r.argument15,
             r.argument16, r.argument17, r.argument18, r.argument19, r.argument20,
             r.argument21, r.argument22, r.argument23, r.argument24, r.argument25,
             r.argument26, r.argument27, r.argument28, r.argument29, r.argument30,
             r.argument31, r.argument32, r.argument33, r.argument34, r.argument35,
             r.argument36, r.argument37, r.argument38, r.argument39, r.argument40,
             r.argument41, r.argument42, r.argument43, r.argument44, r.argument45,
             r.argument46, r.argument47, r.argument48, r.argument49, r.argument50,
             r.argument51, r.argument52, r.argument53, r.argument54, r.argument55,
             r.argument56, r.argument57, r.argument58, r.argument59, r.argument60,
             r.argument61, r.argument62, r.argument63, r.argument64, r.argument65,
             r.argument66, r.argument67, r.argument68, r.argument69, r.argument70,
             r.argument71, r.argument72, r.argument73, r.argument74, r.argument75,
             r.argument76, r.argument77, r.argument78, r.argument79, r.argument80,
             r.argument81, r.argument82, r.argument83, r.argument84, r.argument85,
             r.argument86, r.argument87, r.argument88, r.argument89, r.argument90,
             r.argument91, r.argument92, r.argument93, r.argument94, r.argument95,
             r.argument96, r.argument97, r.argument98, r.argument99, r.argument100,
             r.org_id, r.recalc_parameters
        from fnd_request_set_programs sp, fnd_run_requests r,
             fnd_concurrent_programs cp, fnd_application a, fnd_concurrent_requests fcr1, fnd_concurrent_requests fcr2
       where sp.set_application_id = appl_id
         and sp.request_set_id = set_id
         and sp.request_set_stage_id = stage_id
         and sp.request_set_program_id = r.request_set_program_id
         and sp.set_application_id = r.set_application_id
         and sp.request_set_id = r.request_set_id
         and r.parent_request_id = parent_id
         and a.application_id = r.application_id
         and cp.application_id = r.application_id
         and cp.concurrent_program_id = r.concurrent_program_id
         and fcr1.parent_request_id = fcr2.request_id
         and fcr1.concurrent_program_id = r.concurrent_program_id
         and r.request_id = fcr1.request_id
         and fcr1.status_code = 'E'
         and fcr2.parent_request_id = parent_id
         and fcr2.run_number = current_run_number - 1
         and stage_id = to_number(fcr2.argument3)
       order by sp.sequence;

  cursor critical_outcomes (req_id number) is
    select decode(status_code, 'C', 'S', 'G', 'W', 'E') outcome
      from fnd_concurrent_requests
     where parent_request_id = req_id
       and critical = 'Y';

  cursor stage_req_printers(parent_req_id number, set_program_id number) is
    select arguments printer, number_of_copies
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 1
     order by sequence;

  cursor stage_req_notifications(parent_req_id number,
    set_program_id number) is
    select arguments notify
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 2
     order by sequence;

    cursor stage_req_layouts(parent_req_id number,
          set_program_id number) is
    select argument1, argument2, argument3, argument4, argument5
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type = 6
     order by sequence;

    cursor stage_req_delivery(parent_req_id number,
                              set_program_id number) is
    select argument1, argument2, argument3, argument4, argument5,
	   argument6, argument7, argument8, argument9, argument10
      from fnd_run_req_pp_actions
     where parent_request_id = parent_req_id
       and request_set_program_id = set_program_id
       and action_type in (7, 8)
     order by sequence;

  req_id            number;
  critical_request  varchar2(1)     default 'N';
  hardwired_outcome varchar2(1);
  current_outcome   varchar2(1)     default 'S';
  warning           boolean         default FALSE;
  error             boolean         default FALSE;
  outcome_meaning   varchar2(80);  /* Translated outcome meaning.     */
  req_data          varchar2(10);  /* State of last FNDRSSUB run.     */
  has_reqs          boolean         default FALSE;
  funct             varchar2(61);  /* Function string */
  fcursor           varchar2(75);  /* Cursor sting for dbms_sql */
  cid               number;        /* Cursor ID for dbms_sql */
  dummy             number;
  printer           varchar2(30);
  copies            number;
  /* xml project */
  t_app_name        varchar2(50);
  t_code            varchar2(80);
  t_language        varchar2(2);
  t_territory       varchar2(2);
  t_format          varchar2(6);
  req               stage_requests%ROWTYPE;
  old_reqid         number;
  run_number_var    number;
begin
  /* Get outcome and function for stage if any.
   * Also, set up function globals.            */
  begin
    errbuf := null;
    select outcome, execution_file_name,
           s.set_application_id, s.request_set_id, s.request_set_stage_id,
           s.function_id, s.function_application_id
      into hardwired_outcome, funct,
           g_set_appl_id, g_set_id, g_stage_id,
           g_function_id, g_function_appl_id
      from fnd_request_set_stages s, fnd_executables e
     where s.set_application_id = appl_id
       and s.request_set_id = set_id
       and s.request_set_stage_id = stage_id
       and e.executable_id(+) = s.function_id
       and e.application_id(+) = s.function_application_id;
  exception
    when NO_DATA_FOUND then
      fnd_message.set_name('FND','CONC-Missing stage');
      errbuf := substr(fnd_message.get,1, 240);
      retcode := 2;
      return;
  end;

  /* Get state from last run if any. */
  req_data := fnd_conc_global.request_data;

  /* Is this the first run? */
  if (req_data is null) then
    begin
      select run_number into run_number_var from fnd_concurrent_requests where request_id = parent_id;
      if( restart_flag = 0) then
        open stage_requests( appl_id, set_id, stage_id, parent_id);
      else
        open stage_requests_restart( appl_id, set_id, stage_id, parent_id,
                                     run_number_var);
      end if;
      loop
        if( restart_flag = 0 ) then
          fetch stage_requests into req;
          exit when stage_requests%NOTFOUND;
        else
          fetch stage_requests_restart into req;
          exit when stage_requests_restart%NOTFOUND;
        end if;
--      for req in stage_requests(appl_id, set_id, stage_id, parent_id) loop
        if (req.critical = 'Y') then
          critical_request := 'Y';
        end if;

        open stage_req_printers(parent_id, req.request_set_program_id);
        fetch stage_req_printers into printer, copies;
        if (stage_req_printers%found) then
          if (not fnd_request.set_print_options(
                              printer => printer,
                              style => req.print_style,
                              copies => copies,
                              save_output => (req.save_output_flag = 'Y'),
                              print_together => NULL))
          then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            close stage_req_printers;
            rollback;
            return;
          end if;

          fetch stage_req_printers into printer, copies;
          while (stage_req_printers%found) loop
            if (not fnd_request.add_printer(
                              printer => printer,
                              copies => copies)) then
              errbuf := substr(fnd_message.get, 1, 240);
              retcode := 2;
              close stage_req_printers;
              rollback;
              return;
            end if;
            fetch stage_req_printers into printer, copies;
          end loop;
        else
          if (not fnd_request.set_print_options(
                              printer => null,
                              style => req.print_style,
                              copies => 0,
                              save_output => (req.save_output_flag = 'Y'),
                              print_together => NULL))
          then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            close stage_req_printers;
            rollback;
            return;
          end if;
        end if;
        close stage_req_printers;

        for notify_rec in stage_req_notifications
                            (parent_id, req.request_set_program_id) loop
          if (not fnd_request.add_notification(
                              user=>notify_rec.notify)) then
            /* 3900886: User not found in wf_roles, continue with warning */
            if (errbuf is NULL) then
              errbuf := substr(fnd_message.get||
                               ': '|| notify_rec.notify, 1, 240);
            else
              if (instr(errbuf, notify_rec.notify, -1, 1) = 0) then
                errbuf := substr(errbuf ||', '|| notify_rec.notify, 1, 240);
              end if;
            end if;
            retcode := 1;
          end if;
        end loop;

        -- XML Project
        open stage_req_layouts(parent_id, req.request_set_program_id);

        fetch stage_req_layouts into t_app_name,
                                     t_code,
                                     t_language,
                                     t_territory,
                                     t_format;
        while (stage_req_layouts%found) loop
          if (not fnd_request.add_layout(
                            t_app_name,
                            t_code,
                            t_language,
                            t_territory,
                            t_format)) then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            close stage_req_printers;
            rollback;
            return;
          end if;
          fetch stage_req_layouts into t_app_name,
                                       t_code,
                                       t_language,
                                       t_territory,
                                       t_format;
        end loop;
        close stage_req_layouts;



	/* set delivery pp actions for this request */
        for delivery_rec in stage_req_delivery
                            (parent_id, req.request_set_program_id)
	  loop
            if (not fnd_request.add_delivery_option(
                                                  delivery_rec.argument1,
                                                  delivery_rec.argument2,
						  delivery_rec.argument3,
						  delivery_rec.argument4,
						  delivery_rec.argument5,
						  delivery_rec.argument6,
						  delivery_rec.argument7,
						  delivery_rec.argument8,
						  delivery_rec.argument9,
						  delivery_rec.argument10
						  )) then
            errbuf := substr(fnd_message.get, 1, 240);
            retcode := 2;
            rollback;
            return;
          end if;
        end loop;


/* NLS Project - Added Numeric Character to set_options */
        if (not fnd_request.set_options(language=>req.nls_language,
                            territory=>req.nls_territory,
                            datagroup=>'',
                            numeric_characters=>req.numeric_characters,
                            nls_sort=>req.nls_sort)) then
          errbuf := substr(fnd_message.get, 1, 240);
          retcode := 2;
          rollback;
          return;
        end if;

        fnd_request.internal(critical => req.critical, type=>'P');

        /* MOAC */
        fnd_request.set_org_id(req.org_id);
        fnd_request.set_recalc_parameters_option(req.recalc_parameters);

        req_id := fnd_request.submit_request(
                      req.application_short_name, req.concurrent_program_name,
                      Null, NULL, TRUE,
                      req.argument1, req.argument2, req.argument3,
                      req.argument4, req.argument5, req.argument6,
                      req.argument7, req.argument8, req.argument9,
                      req.argument10, req.argument11, req.argument12,
                      req.argument13, req.argument14, req.argument15,
                      req.argument16, req.argument17, req.argument18,
                      req.argument19, req.argument20, req.argument21,
                      req.argument22, req.argument23, req.argument24,
                      req.argument25, req.argument26, req.argument27,
                      req.argument28, req.argument29, req.argument30,
                      req.argument31, req.argument32, req.argument33,
                      req.argument34, req.argument35, req.argument36,
                      req.argument37, req.argument38, req.argument39,
                      req.argument40, req.argument41, req.argument42,
                      req.argument43, req.argument44, req.argument45,
                      req.argument46, req.argument47, req.argument48,
                      req.argument49, req.argument50, req.argument51,
                      req.argument52, req.argument53, req.argument54,
                      req.argument55, req.argument56, req.argument57,
                      req.argument58, req.argument59, req.argument60,
                      req.argument61, req.argument62, req.argument63,
                      req.argument64, req.argument65, req.argument66,
                      req.argument67, req.argument68, req.argument69,
                      req.argument70, req.argument71, req.argument72,
                      req.argument73, req.argument74, req.argument75,
                      req.argument76, req.argument77, req.argument78,
                      req.argument79, req.argument80, req.argument81,
                      req.argument82, req.argument83, req.argument84,
                      req.argument85, req.argument86, req.argument87,
                      req.argument88, req.argument89, req.argument90,
                      req.argument91, req.argument92, req.argument93,
                      req.argument94, req.argument95, req.argument96,
                      req.argument97, req.argument98, req.argument99,
                      req.argument100);
        if (req_id = 0) then
          errbuf := substr(fnd_message.get, 1, 240);
          retcode := 2;
          return;
        end if;

        -- set the request_id in fnd_run_requests so that
        -- we can identify the failed request later if we
        -- restart this stage.
        UPDATE fnd_run_requests
          SET request_id = req_id
          WHERE request_set_program_id = req.request_set_program_id
          AND application_id = req.application_id
          AND concurrent_program_id = req.concurrent_program_id
          AND parent_request_id = parent_id
          AND set_application_id = appl_id
          AND request_set_id = set_id;

        UPDATE fnd_concurrent_requests
          SET RUN_NUMBER = run_number_var
          WHERE request_id = req_id;

        has_reqs := TRUE;
      end loop;
      /* close the cursor open  */
      if( restart_flag = 0) then
        close stage_requests;
      else
        close stage_requests_restart;
      end if;

      if (has_reqs = FALSE) then
        fnd_message.set_name('FND','CONC-Stage has no requests');
        errbuf := substr(fnd_message.get,1, 240);
        /* Exit with error unless we have a hardwired outcome. */
        if (hardwired_outcome = 'C') then
          retcode := 2;
        else
          retcode := to_number(translate(hardwired_outcome, 'SWE', '012'));
        end if;
        return;
      end if;
    end;

    fnd_conc_global.set_req_globals(
                    conc_status => 'PAUSED',
                    request_data => critical_request);
    if (retcode = 1) then  /* submission with warnings, message set */
       fnd_message.set_name('FND','CONC-Stage Reqs Submitted Warn');
       fnd_message.set_token('WARNING', substr (errbuf, 1, 240), FALSE);
       errbuf := substr(fnd_message.get,1, 240);
       return;
    else
       fnd_message.set_name('FND','CONC-Stage Reqs Submitted');
       errbuf := substr(fnd_message.get,1, 240);
       retcode := 0;
       return;
    end if;

  else  /* FNDRSSTG has been restarted. */

    /* Compute stage exit code. */

    /* Do we have a hardwired outcome? */
    if (hardwired_outcome <>'C') then
      fnd_message.set_name('FND','CONC-Stage outcome hardwired');
      current_outcome := hardwired_outcome;

    else  /* Call evaluation function */
      if (funct is null) then
        fnd_message.set_name('FND','CONC-Invalid Stage Function');
        errbuf := substr(fnd_message.get,1, 240);
        retcode := 2;
        return;
      end if;


      fcursor := 'begin :r := '||funct||'; end;';
      begin
        cid := dbms_sql.open_cursor;
        dbms_sql.parse(cid, fcursor, dbms_sql.v7);
        dbms_sql.bind_variable(cid, ':r', 'a');
        dummy := dbms_sql.execute(cid);
        dbms_sql.variable_value(cid, ':r', current_outcome);
        dbms_sql.close_cursor(cid);
      exception
        when others then
          errbuf := gen_error(funct, SQLCODE, SQLERRM);
          retcode := 2;
          return;
      end;

    end if;

    select meaning
      into outcome_meaning
      from fnd_lookups
     where lookup_type = 'CP_SET_OUTCOME'
       and lookup_code = current_outcome;

    fnd_message.set_name('FND', 'CONC-Stage outcome computed');
    fnd_message.set_token('OUTCOME', outcome_meaning);
    errbuf := substr(fnd_message.get, 1, 240);
    retcode := to_number(translate(current_outcome, 'SWE', '012'));

    return;
  end if;
exception
  when OTHERS then
    errbuf := gen_error('FNDRSSTG', SQLCODE, SQLERRM);
    retcode := 2;
    return;
end FNDRSSTG;



/* 1310211 - Need to handle the case where the child request has restarted the
   parent but has not yet finished the post-processing steps. In this case the child's
   status will still be 'R'.
   If we find a child still running, we will wait a small amount of time, then try the
   query again. After 5 repetitions if the child is still running we will report it as an
   error condition
*/

function standard_stage_evaluation return varchar2 is
  warning      boolean := FALSE;
  stillrunning boolean := FALSE;
  i            integer;
begin

  <<outer>>
  for i in 1 .. stage_looptimes loop
    stillrunning := FALSE;
    for request in fnd_request_set.stage_request_info loop
        if (request.exit_status = 'E') then
            return 'E';
        elsif (request.exit_status = 'R') then
            stillrunning := TRUE;
        elsif (request.exit_status = 'W') then
            warning := TRUE;
        end if;
    end loop;


    exit outer when stillrunning = FALSE;
    dbms_lock.sleep(stage_sleeptime);

  end loop;

  if (warning) then
    return 'W';
  elsif (stillrunning) then
    return 'E';
  else
    return 'S';
  end if;
end;


-- Name
--   GET_STAGE_PARAMETER
--
-- Purpose
--  Used by stage functions to retrieve parameter
--  values for the current stage.
--
function get_stage_parameter(name in varchar2) return varchar2 is
  val varchar2(240);
begin
  select value into val
    from fnd_stage_fn_parameters_vl p, fnd_stage_fn_parameter_values v
   where v.set_application_id = g_set_appl_id
     and v.request_set_id = g_set_id
     and v.request_set_stage_id = g_stage_id
     and v.function_id = g_function_id
     and v.function_application_id =g_function_appl_id
     and v.parameter_id = p.parameter_id
     and p.parameter_name = name
     and p.function_id = v.function_id
     and p.application_id = v.function_application_id;

  return val;
exception
  when no_data_found then
    return null;
end;


end FND_REQUEST_SET;

/
