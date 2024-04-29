--------------------------------------------------------
--  DDL for Package Body FND_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TRANSACTION" as
/* $Header: AFCPTRNB.pls 120.9 2006/05/26 21:29:34 ckclark ship $ */


--
-- Private Variables
--
sid               number       := null;
send_type         varchar2(1);
request_id        number       := -1;
g_program_appl_id number;
g_program_id      number;
action_cnt        number       := 1;
p_transport_type  varchar2(32) := 'QUEUE';
token_timeout     number;
temp_fcp_application_id number;
temp_fcp_concurrent_program_id number;




--
--   debug_info
-- Purpose
--   If the debug flag is set, then write to
--   the debug table.
-- Arguments
--   IN:
--    function_name - Name of the calling function
--    action_name   - Name of the current action being logged
--    message_text  - Any relevent info.
--    s_type        - Source Type ('C'- Client Send, 'M' - Manager Receive
--                                  'S' - Server Send, 'U' - Client Receive)
-- Notes
--   none.
--
procedure debug_info(function_name in varchar2,
                     action_name   in varchar2,
                     message_text  in varchar2,
                     s_type        in varchar2 default 'C') is
    PRAGMA AUTONOMOUS_TRANSACTION;
begin

      insert into fnd_concurrent_debug_info
        (
          session_id, user_id, login_id,
          time, function, action, message,
          resp_appl_id, responsibility_id,
          security_group_id, transaction_id,
          program_application_id, concurrent_program_id,
          concurrent_queue_id, time_in_number, source_type
        )
      values
        (
          sid, fnd_global.user_id, fnd_global.login_id,
          sysdate, function_name, substr(action_cnt || '|' || action_name, 1, 30),
          substr(message_text, 1, ARGMAX),
          fnd_global.resp_appl_id, fnd_global.resp_id,
          fnd_global.security_group_id,request_id,
          g_program_appl_id, g_program_id,
          conc_queue_id, dbms_utility.get_time, s_type
        );

      action_cnt := action_cnt + 1;

      commit;
end;


--
--   post_tm_event
-- Purpose
--   Posts TM Event into FND_TM_EVENTS table as autonomous transaction
-- Arguments
--   event_type  number
procedure post_tm_event( event_type  in number,
                         application in varchar2,
                         program     in varchar2,
                         queue_id    in number,
                         timeout     in number default null,
                         tm_pipe     in varchar2 default null ) is
   PRAGMA AUTONOMOUS_TRANSACTION;
  begin
     if ( event_type = 1 ) then
      -- NO MANAGER DEFINED EVENT
      insert into fnd_tm_events
        (EVENT_TYPE, TIMESTAMP, TRANSACTION_ID,
         PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
         USER_ID, RESP_APPL_ID, RESPONSIBILITY_ID)
        SELECT event_type, sysdate, request_id,
                fcp.application_id, fcp.concurrent_program_id,
                fnd_global.user_id, fnd_global.resp_appl_id, fnd_global.resp_id
        from fnd_concurrent_programs fcp, fnd_application fa
        where fcp.concurrent_program_name = program
        and fcp.application_id = fa.application_id
 	and fa.application_short_name = application;
     elsif ( event_type = 2 ) then
      -- MANAGER BUSY EVENT
      /* mark soft busy event (2) */
      insert into fnd_tm_events
        (EVENT_TYPE, TIMESTAMP, TRANSACTION_ID,
         QUEUE_APPLICATION_ID, CONCURRENT_QUEUE_ID,
         PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
         USER_ID, RESP_APPL_ID, RESPONSIBILITY_ID,
         RUNNING_PROCESSES, TARGET_PROCESSES)
        SELECT event_type, sysdate, request_id,
                FCQ.application_id, queue_id,
                fcp.application_id, fcp.concurrent_program_id,
                fnd_global.user_id, fnd_global.resp_appl_id, fnd_global.resp_id,
                fcq.RUNNING_PROCESSES, fcq.max_processes
        from fnd_concurrent_programs fcp,
             fnd_concurrent_queues fcq,
	     fnd_application fa
        where fcp.concurrent_program_name = program
          and fcq.concurrent_queue_id = queue_id
	and fcp.application_id = fa.application_id
	and fa.application_short_name = application;

     elsif ( event_type = 3 ) then
      -- ALL MANAGERS WERE BUSY EVENT
      -- delete previously posted soft busy events before posting hard busy
      -- event.
      delete from fnd_tm_events
       where transaction_id = request_id
         and event_type = 2;

      /* mark all appropriate managers as hard busy events */
      insert into fnd_tm_events
        (EVENT_TYPE, TIMESTAMP, TRANSACTION_ID,
         QUEUE_APPLICATION_ID, CONCURRENT_QUEUE_ID,
         PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
         USER_ID, RESP_APPL_ID, RESPONSIBILITY_ID,
         RUNNING_PROCESSES, TARGET_PROCESSES)
        SELECT
           /*+ ORDERED USE_NL (fa fcp fr fcpp fcq)
           INDEX (fcq,FND_CONCURRENT_QUEUES_N1)
           INDEX (fcpp,FND_CONC_PROCESSOR_PROGRAMS_U2) */
                3, sysdate, request_id,
                FCQ.application_id, FCQ.concurrent_queue_id,
                fcp.application_id, fcp.concurrent_program_id,
                fnd_global.user_id, fnd_global.resp_appl_id, fnd_global.resp_id,
                fcq.RUNNING_PROCESSES, fcq.max_processes
        from fnd_application fa,
             fnd_concurrent_programs fcp,
             fnd_conc_processor_programs fcpp,
             fnd_responsibility fr,
             fnd_concurrent_queues fcq
        where fcp.concurrent_program_name = program
         and fcq.processor_application_id = fcpp.processor_application_id
         and fcq.concurrent_processor_id =  fcpp.concurrent_processor_id
         and fcpp.concurrent_program_id = fcp.concurrent_program_id
         and fcpp.program_application_id = fcp.application_id
         and fcp.application_id = fa.application_id
         and fa.application_short_name = application
         and fr.responsibility_id = fnd_global.resp_id
         and fr.application_id = fnd_global.resp_appl_id
         and fr.data_group_id = fcq.data_group_id
         and fcq.manager_type = '3';
     elsif ( event_type = 4 ) then
       /* mark timeout event (4) */
       if p_transport_type = 'PIPE' then
         /* bug5007493 - separating sql */
         SELECT  fcp.application_id, fcp.concurrent_program_id
           into temp_fcp_application_id, temp_fcp_concurrent_program_id
          from fnd_concurrent_programs fcp
          where fcp.concurrent_program_name = program
            and fcp.application_id = (
                                       SELECT application_id
                                         from fnd_application
                                        where application_short_name = application);

         insert into fnd_tm_events
          (EVENT_TYPE, TIMESTAMP, TRANSACTION_ID,
           QUEUE_APPLICATION_ID, CONCURRENT_QUEUE_ID,
           PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
           USER_ID, RESP_APPL_ID, RESPONSIBILITY_ID,
           RUNNING_PROCESSES, TARGET_PROCESSES, NUMDATA)
           SELECT 4, sysdate, request_id,
                FCQ.application_id, fcq.concurrent_queue_id,
                temp_fcp_application_id, temp_fcp_concurrent_program_id,
                fnd_global.user_id, fnd_global.resp_appl_id, fnd_global.resp_id,
                fcq.RUNNING_PROCESSES, fcq.max_processes, timeout
          from fnd_concurrent_queues fcq
          where fcq.concurrent_queue_id = to_number(substr(tm_pipe,11));
       else
          insert into fnd_tm_events
          (EVENT_TYPE, TIMESTAMP, TRANSACTION_ID,
           PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID,
           USER_ID, RESP_APPL_ID, RESPONSIBILITY_ID, NUMDATA)
           SELECT event_type, sysdate, request_id,
                fcp.application_id, fcp.concurrent_program_id,
                fnd_global.user_id, fnd_global.resp_appl_id, fnd_global.resp_id, timeout
          from fnd_concurrent_programs fcp, fnd_application fa
          where fcp.concurrent_program_name = program
	  and fcp.application_id = fa.application_id
	  and fa.application_short_name = application;
       end if;

     end if;

    commit;
  end;

--
-- Private Procedure
--   initialize_globals
-- Purpose
--   Initialize the package globals for
--   this session.
-- Arguments
--   None
-- Notes
--   None
--
procedure initialize_globals is
    conc_debug varchar2(240);
  begin
    -- get transaction request_id from sequence
    select fnd_trn_request_id_s.nextval
       into request_id
       from dual;

    /* initialize and seed random... */
    dbms_random.initialize(request_id);

    --bug 3623063 - init queue_id  for session
    /* initialize conc_queue_id */
    conc_queue_id := null;

    -- session id
    if (sid is null) then
      select userenv('SESSIONID')
        into sid
        from sys.dual;
    end if;

    -- PIPE/QUEUE profile option switch
    FND_PROFILE.GET('CONC_TM_TRANSPORT_TYPE', p_transport_type);
    if p_transport_type is null then
      p_transport_type := 'QUEUE';
    end if;

    -- debug
    fnd_profile.get('CONC_DEBUG', conc_debug);
    if (instr(conc_debug, 'TC') <> 0) then
      debug_flag := TRUE;
    end if;
    if (instr(conc_debug, 'TM1') <> 0) then
      send_type := TYPE_REQUEST_DEBUG1;
    elsif (instr(conc_debug, 'TM2') <> 0) then
      send_type := TYPE_REQUEST_DEBUG2;
    else
      send_type := TYPE_REQUEST;
    end if;

    action_cnt := 1;

    begin
         fnd_profile.get('CONC_TOKEN_TIMEOUT', token_timeout);
         if (token_timeout is null) then
           token_timeout := DEFAULT_TIMEOUT;
         end if;
     exception
         when VALUE_ERROR then
           token_timeout := DEFAULT_TIMEOUT;
    end;

    for counter in 1..20 loop
       return_values(counter) := null;
    end loop;

end initialize_globals;





--
-- Function
--   synchronous
-- Purpose
--   Submit a synchronous transaction request.
-- Arguments
--   IN
--     timeout     - Number of seconds to wait for transaction completion.
--     application - Transaction program application short name.
--     program     - Transaction program short name.
--     arg_n       - Arguments 1 through 20 to the transaction program.
--
--                   Each argument is at most 480 characters.
--                   Individual arguments longer than 480 chars will be truncated.
--
--
--   OUT
--     outcome     - varchar(30)  - Transaction program completion status.
--     message     - varchar(240) - Transaction program completion message.
--
function synchronous (timeout     in     number,
                      outcome     in out NOCOPY varchar2,
                      message     in out NOCOPY varchar2,
                      application in     varchar2,
                      program     in     varchar2,
                      arg_1       in     varchar2 default chr(0),
                      arg_2       in     varchar2 default chr(0),
                      arg_3       in     varchar2 default chr(0),
                      arg_4       in     varchar2 default chr(0),
                      arg_5       in     varchar2 default chr(0),
                      arg_6       in     varchar2 default chr(0),
                      arg_7       in     varchar2 default chr(0),
                      arg_8       in     varchar2 default chr(0),
                      arg_9       in     varchar2 default chr(0),
                      arg_10      in     varchar2 default chr(0),
                      arg_11      in     varchar2 default chr(0),
                      arg_12      in     varchar2 default chr(0),
                      arg_13      in     varchar2 default chr(0),
                      arg_14      in     varchar2 default chr(0),
                      arg_15      in     varchar2 default chr(0),
                      arg_16      in     varchar2 default chr(0),
                      arg_17      in     varchar2 default chr(0),
                      arg_18      in     varchar2 default chr(0),
                      arg_19      in     varchar2 default chr(0),
                      arg_20      in     varchar2 default chr(0))
                    return number is

    status            number;
    expiration_time   date;
    nls_lang          varchar2(60);
    nls_num_chars     varchar2(60);
    nls_date_lang     varchar2(60);
    secgrpid          number;
    enable_trace_flag varchar2(255);
    error             exception;
    morg_cat          varchar2(1);
    org_type          varchar2(1);
    org_id            number;

  begin

    initialize_globals;

    if (debug_flag) then
      debug_info('fnd_transaction.synchronous', 'Starting transaction', NULL);
    end if;

    if (timeout <= 0 or timeout is null) then
      fnd_message.set_name('FND', 'CONC-TM-Invalid timeout');
      debug_info('fnd_transaction.synchronous', 'Invalid timeout parameter', to_char(timeout));
      raise error;
    end if;

    if (application is null) then
      fnd_message.set_name('FND', 'CONC-TM-Application null');
      debug_info('fnd_transaction.synchronous', 'NULL application parameter', NULL);
      raise error;
    end if;

    if (program is null) then
      fnd_message.set_name('FND', 'CONC-TM-Program null');
      debug_info('fnd_transaction.synchronous', 'NULL program parameter', NULL);
      raise error;
    end if;

    if (debug_flag) then
        debug_info('fnd_transaction.synchronous', 'Using transport type', p_transport_type);
    end if;

    -- Get SQL_TRACE   MULTI_ORG_CATEGORY
    fnd_profile.get('SQL_TRACE', enable_trace_flag);

    SELECT DECODE(P.ENABLE_TRACE, 'Y', 'Y', enable_trace_flag),
           NVL(P.MULTI_ORG_CATEGORY, 'N'),
           P.APPLICATION_ID, P.CONCURRENT_PROGRAM_ID
    INTO enable_trace_flag, morg_cat,
         g_program_appl_id, g_program_id
    FROM FND_CONCURRENT_PROGRAMS P,
         FND_APPLICATION A
    where p.concurrent_program_name = program
         and p.application_id = a.application_id
         and a.application_short_name = application;

    -- Get manager
    if p_transport_type = 'PIPE' then
       status := fnd_transaction_pipe.get_manager(application, program, token_timeout);
    else
       status := fnd_transaction_queue.get_manager(application, program, token_timeout);
    end if;

    if status = E_NOMGR then -- All managers busy
      return status;
    elsif status = E_OTHER then
      raise error;
    end if;


    -- Get nls_lang, nls_date_language, nls_numeric_characters
    nls_lang := substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1);

    SELECT VALUE
    into nls_date_lang
    FROM V$NLS_PARAMETERS
    Where PARAMETER = 'NLS_DATE_LANGUAGE';

    SELECT VALUE
    into nls_num_chars
    FROM V$NLS_PARAMETERS
    Where PARAMETER = 'NLS_NUMERIC_CHARACTERS';


    --get security_group_id
    secgrpid := fnd_global.security_group_id;

    if (enable_trace_flag = 'Y') then
       enable_trace_flag := 'TRUE';
    else
       enable_trace_flag := 'FALSE';
    end if;

    -- get org type and id
    select nvl(mo_global.get_access_mode, morg_cat) into org_type from dual;
    select nvl(mo_global.get_current_org_id, 0) into org_id from dual;

    -- Request expires at SYSDATE + timeout
    expiration_time := sysdate + (timeout * DAY_PER_SEC);

    if (debug_flag) then
        debug_info('fnd_transaction.synchronous',
                   'REQID:SECID:TRACE:EXPIRES',
                   to_char(request_id) || ':' || to_char(secgrpid) || ':'
                   || enable_trace_flag || ':' || to_char(expiration_time, 'DD-MON-RR HH24:MI:SS'));
        debug_info('fnd_transaction.synchronous',
                   'NLS_LANG:DATE_LANG:NUM_CHARS',
                   nls_lang || ':' || nls_date_lang || ':' || nls_num_chars);


        debug_info('fnd_transaction.synchronous',
                   'Packing packet type',
                   send_type);
        debug_info('fnd_transaction.synchronous',
                   'Packing program application',
                   application);
        debug_info('fnd_transaction.synchronous',
                   'Packing program',
                     program);
        debug_info('fnd_transaction.synchronous',
                   'Packing org_type',
                     org_type);
        debug_info('fnd_transaction.synchronous',
                   'Packing org_id',
                     org_id);
        if (arg_1 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 1',
                   arg_1);
        if (arg_2 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 2',
                   arg_2);
        if (arg_3 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 3',
                   arg_3);
        if (arg_4 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 4',
                   arg_4);
        if (arg_5 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 5',
                   arg_5);
        if (arg_6 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 6',
                   arg_6);
        if (arg_7 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 7',
                   arg_7);
        if (arg_8 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 8',
                   arg_8);
        if (arg_9 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 9',
                   arg_9);
        if (arg_10 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 10',
                   arg_10);
        if (arg_11 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 11',
                   arg_11);
        if (arg_12 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 12',
                   arg_12);
        if (arg_13 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 13',
                   arg_13);
        if (arg_14 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 14',
                   arg_14);
        if (arg_15 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 15',
                   arg_15);
        if (arg_16 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 16',
                   arg_16);
        if (arg_17 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 17',
                   arg_17);
        if (arg_18 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 18',
                   arg_18);
        if (arg_19 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 19',
                   arg_19);
        if (arg_20 = CHR(0)) then goto end_dbg; end if;
        debug_info('fnd_transaction.synchronous',
                   'Packing arg 20',
                   arg_20);

     <<end_dbg>>
       debug_info('fnd_transaction.synchronous', 'Timeout value', to_char(timeout));
    end if;


    if p_transport_type = 'PIPE' then
       status := fnd_transaction_pipe.send_message(timeout, send_type, expiration_time, request_id,
                                                   nls_lang, nls_num_chars, nls_date_lang,
                                                   secgrpid, enable_trace_flag, application, program,
                                                   org_type, org_id, outcome, message,
                                                   arg_1, arg_2, arg_3, arg_4, arg_5,
                                                   arg_6, arg_7, arg_8, arg_9, arg_10,
                                                   arg_11, arg_12, arg_13, arg_14, arg_15,
                                                   arg_16, arg_17, arg_18, arg_19, arg_20);

    else
       status := fnd_transaction_queue.send_message(timeout, send_type, expiration_time, request_id,
                                                   nls_lang, nls_num_chars, nls_date_lang,
                                                   secgrpid, enable_trace_flag, application, program,
                                                   org_type, org_id, outcome, message,
                                                   arg_1, arg_2, arg_3, arg_4, arg_5,
                                                   arg_6, arg_7, arg_8, arg_9, arg_10,
                                                   arg_11, arg_12, arg_13, arg_14, arg_15,
                                                   arg_16, arg_17, arg_18, arg_19, arg_20);
    end if;


    if (debug_flag) then
       debug_info('fnd_transaction.synchronous', 'Transaction complete', request_id, 'U');
    end if;

    return status;

exception

    when error then
        return E_OTHER;

    when OTHERS then
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'FND_TRANSACTION.SYNCHRONOUS', FALSE);
        debug_info('fnd_transaction.synchronous', 'Caught exception', sqlerrm);
        return E_OTHER;

end synchronous;


--
-- Function
--   get_values
-- Purpose
--   Retrieve the last transaction's return
--   values from the global table.
-- Arguments
--   OUT
--     arg_n - Returned values 1 through 20
--
function get_values  (arg_1       in out NOCOPY varchar2,
                      arg_2       in out NOCOPY varchar2,
                      arg_3       in out NOCOPY varchar2,
                      arg_4       in out NOCOPY varchar2,
                      arg_5       in out NOCOPY varchar2,
                      arg_6       in out NOCOPY varchar2,
                      arg_7       in out NOCOPY varchar2,
                      arg_8       in out NOCOPY varchar2,
                      arg_9       in out NOCOPY varchar2,
                      arg_10      in out NOCOPY varchar2,
                      arg_11      in out NOCOPY varchar2,
                      arg_12      in out NOCOPY varchar2,
                      arg_13      in out NOCOPY varchar2,
                      arg_14      in out NOCOPY varchar2,
                      arg_15      in out NOCOPY varchar2,
                      arg_16      in out NOCOPY varchar2,
                      arg_17      in out NOCOPY varchar2,
                      arg_18      in out NOCOPY varchar2,
                      arg_19      in out NOCOPY varchar2,
                      arg_20      in out NOCOPY varchar2)
                    return number is
  begin
    arg_1 := return_values(1);
    arg_2 := return_values(2);
    arg_3 := return_values(3);
    arg_4 := return_values(4);
    arg_5 := return_values(5);
    arg_6 := return_values(6);
    arg_7 := return_values(7);
    arg_8 := return_values(8);
    arg_9 := return_values(9);
    arg_10 := return_values(10);
    arg_11 := return_values(11);
    arg_12 := return_values(12);
    arg_13 := return_values(13);
    arg_14 := return_values(14);
    arg_15 := return_values(15);
    arg_16 := return_values(16);
    arg_17 := return_values(17);
    arg_18 := return_values(18);
    arg_19 := return_values(19);
    arg_20 := return_values(20);

    for counter in 1..20 loop
      return_values(counter) := null;
    end loop;

    return E_SUCCESS;

  exception
    when others then
      fnd_message.set_name ('FND', 'SQL-Generic error');
      fnd_message.set_token ('ERRNO', sqlcode, FALSE);
      fnd_message.set_token ('REASON', sqlerrm, FALSE);
      fnd_message.set_token ('ROUTINE', 'FND_TRANSACTION.GET_VALUES', FALSE);
      return E_OTHER;
  end get_values;




end fnd_transaction;

/
