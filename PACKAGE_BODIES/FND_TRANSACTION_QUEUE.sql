--------------------------------------------------------
--  DDL for Package Body FND_TRANSACTION_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TRANSACTION_QUEUE" as
 /* $Header: AFCPTRQB.pls 120.1.12010000.2 2019/10/02 18:27:47 pferguso ship $ */


--
-- Constants
--

-- Name of the TM AQ
QUEUE_NAME         constant VARCHAR2(30) := 'FND_CP_TM_AQ';

-- Name of the TM Return AQ
RETURN_QUEUE_NAME  constant VARCHAR2(30) := 'FND_CP_TM_RET_AQ';

-- Prefix added to all recipient and consumer names
TMPREFIX           constant VARCHAR2(3)  := 'TM';

-- Consumer name for all managers
TMQID              constant varchar2(30) := 'TMSRV';

-- Largest increment to wait for dequeue
TIMEOUT_INCREMENT  constant number := 5;


--
-- Private Variables
--
processor_id      varchar2(32);
Q_Name            varchar2(64) := null;
RetQ_Name         varchar2(64) := null;



 --
 --   get_manager
 -- Purpose
 --   Find an available manager process to run the transaction program
 -- Arguments
 --   IN:
 --     application - program application short name
 --     program     - program short name
 --     timeout     - timeout in seconds
 -- Returns
 --   E_SUCCESS on success.
 --   E_NOMGR if no manager is available
 --   E_OTHER on failure.
 --
 -- Notes
 -- If successful, processor_id will be set
 --
 function get_manager(application   in  varchar2,
                      program       in  varchar2,
                      timeout       in number) return number is

    status       number;
    all_busy     exception;
    resp_appl_id number;
    resp_id      number;

    cursor tm(appl_short_name varchar2, prog_short_name varchar2,
              resp_appl_id number, resp_id number) is
    select /*+ ORDERED USE_NL (fa fcp fr fcpp fcq fcpr)
            INDEX (fcq,FND_CONCURRENT_QUEUES_N1)
            INDEX (fcpp,FND_CONC_PROCESSOR_PROGRAMS_U2) */
         fcq.processor_application_id || '.' || fcq.concurrent_processor_id
    from fnd_application fa,
         fnd_concurrent_programs fcp,
         fnd_conc_processor_programs fcpp,
         fnd_responsibility fr,
         fnd_concurrent_queues fcq,
         fnd_concurrent_processes fcpr
       where fcq.processor_application_id = fcpp.processor_application_id
         and fcq.concurrent_processor_id =  fcpp.concurrent_processor_id
         and fcpp.concurrent_program_id = fcp.concurrent_program_id
         and fcpp.program_application_id = fcp.application_id
         and fcp.application_id = fa.application_id
         and fa.application_short_name = appl_short_name
         and fcp.concurrent_program_name = prog_short_name
         and fr.responsibility_id = resp_id
         and fr.application_id = resp_appl_id
         and fr.data_group_id = fcq.data_group_id
         and fcq.manager_type = '3'
         and fcpr.concurrent_queue_id = fcq.concurrent_queue_id
         and fcpr.queue_application_id = fcq.application_id
         and fcpr.process_status_code = 'A';

  begin
    resp_appl_id := fnd_global.resp_appl_id;
    resp_id := fnd_global.resp_id;

    if (fnd_transaction.debug_flag) then
      fnd_transaction.debug_info('fnd_trn_queue.get_manager',
                 'Searching for manager to run:',
                 application || ':' || program);
      fnd_transaction.debug_info('fnd_trn_queue.get_manager',
                 'RESP_APPL_ID:RESP_ID',
                 to_char(resp_appl_id) || ':' || to_char(resp_id));
    end if;

    open tm(application, program, resp_appl_id, resp_id);

    -- Fetch ID of first manager
    fetch tm into processor_id;
    -- If cursor is empty, then no manager is defined for request.
    if (tm%rowcount = 0 ) then
      fnd_transaction.debug_info('fnd_trn_queue.get_manager', 'No manager available', NULL);

      fnd_transaction.post_tm_event(1, application, program, -1);

      fnd_message.set_name('FND', 'CONC-TM-No manager defined');
      fnd_message.set_token('APPLICATION', application);
      fnd_message.set_token('PROGRAM', program);
      fnd_message.set_token('RESP_ID', resp_id);
      fnd_message.set_token('RESP_APPL_ID', resp_appl_id);
      close tm;
      return fnd_transaction.E_OTHER;
    end if;

    if (fnd_transaction.debug_flag) then
      fnd_transaction.debug_info('fnd_trn_queue.get_manager',
                 'Got available TM process',
                 processor_id);
    end if;

    close tm;
    return fnd_transaction.E_SUCCESS;

  exception
    when others then
      if tm%isopen then
        close tm;
      end if;
      fnd_message.set_name ('FND', 'SQL-Generic error');
      fnd_message.set_token ('ERRNO', sqlcode, FALSE);
      fnd_message.set_token ('REASON', sqlerrm, FALSE);
      fnd_message.set_token ('ROUTINE', 'FND_TRANSACTION_QUEUE.GET_MANAGER', FALSE);
      fnd_transaction.debug_info('fnd_trn_queue.get_manager', 'Caught exception', sqlerrm);

      return fnd_transaction.E_OTHER;

end get_manager;



 --
 --  send_message
 -- Purpose
 --   Puts the transaction message on the queue and waits for the return message
 -- Returns
 --   E_SUCCESS on success
 --   E_TIMEOUT if return message times out
 --   E_OTHER on failure
 --
 --
 function send_message( timeout            in number,
                        send_type          in varchar2,
                        expiration_time    in date,
                        request_id         in number,
                        nls_lang           in varchar2,
                        nls_num_chars      in varchar2,
                        nls_date_lang      in varchar2,
                        secgrpid           in number,
                        enable_trace_flag  in varchar2,
                        application        in varchar2,
                        program            in varchar2,
                        org_type           in varchar2,
                        org_id             in number,
                        outcome in out nocopy varchar2,
                        message in out nocopy varchar2,
                        arg_1              in varchar2,
                        arg_2              in varchar2,
                        arg_3              in varchar2,
                        arg_4              in varchar2,
                        arg_5              in varchar2,
                        arg_6              in varchar2,
                        arg_7              in varchar2,
                        arg_8              in varchar2,
                        arg_9              in varchar2,
                        arg_10             in varchar2,
                        arg_11             in varchar2,
                        arg_12             in varchar2,
                        arg_13             in varchar2,
                        arg_14             in varchar2,
                        arg_15             in varchar2,
                        arg_16             in varchar2,
                        arg_17             in varchar2,
                        arg_18             in varchar2,
                        arg_19             in varchar2,
                        arg_20             in varchar2) return number is

 status            varchar2(1);
 industry          varchar2(1);
 retval            number;
 schema            varchar2(30);
 dq_opts           DBMS_AQ.DEQUEUE_OPTIONS_T;
 queue_timeout     exception;
 enq_opts          DBMS_AQ.enqueue_options_t;
 msg_props         DBMS_AQ.message_properties_t;
 msg               system.FND_CP_TM_AQ_PAYLOAD;
 msg_id            raw(16);
 time_left         number;
 end_time          date;
 retval            number;
 debug_flag        boolean := fnd_transaction.debug_flag;
 r                 boolean;
 argmax            number := fnd_transaction.ARGMAX;
 l_arg_1           varchar2(480);
 l_arg_2           varchar2(480);
 l_arg_3           varchar2(480);
 l_arg_4           varchar2(480);
 l_arg_5           varchar2(480);
 l_arg_6           varchar2(480);
 l_arg_7           varchar2(480);
 l_arg_8           varchar2(480);
 l_arg_9           varchar2(480);
 l_arg_10          varchar2(480);
 l_arg_11          varchar2(480);
 l_arg_12          varchar2(480);
 l_arg_13          varchar2(480);
 l_arg_14          varchar2(480);
 l_arg_15          varchar2(480);
 l_arg_16          varchar2(480);
 l_arg_17          varchar2(480);
 l_arg_18          varchar2(480);
 l_arg_19          varchar2(480);
 l_arg_20          varchar2(480);

 pragma exception_init(queue_timeout, -25228);

begin

   r := fnd_installation.get_app_info('FND', status, industry, schema);

   Q_Name := schema || '.' || QUEUE_NAME;
   RetQ_Name := schema || '.' || RETURN_QUEUE_NAME;

   -- 29392932 - Substitute null characters with null strings. The null characters cause a problem
   -- for the AQ if supplemental logging is enabled.
   if (arg_1 = chr(0)) then l_arg_1 := ''; else l_arg_1 := substr(arg_1, 1, argmax); end if;
   if (arg_2 = chr(0)) then l_arg_2 := ''; else l_arg_2 := substr(arg_2, 1, argmax); end if;
   if (arg_3 = chr(0)) then l_arg_3 := ''; else l_arg_3 := substr(arg_3, 1, argmax); end if;
   if (arg_4 = chr(0)) then l_arg_4 := ''; else l_arg_4 := substr(arg_4, 1, argmax); end if;
   if (arg_5 = chr(0)) then l_arg_5 := ''; else l_arg_5 := substr(arg_5, 1, argmax); end if;
   if (arg_6 = chr(0)) then l_arg_6 := ''; else l_arg_6 := substr(arg_6, 1, argmax); end if;
   if (arg_7 = chr(0)) then l_arg_7 := ''; else l_arg_7 := substr(arg_7, 1, argmax); end if;
   if (arg_8 = chr(0)) then l_arg_8 := ''; else l_arg_8 := substr(arg_8, 1, argmax); end if;
   if (arg_9 = chr(0)) then l_arg_9 := ''; else l_arg_9 := substr(arg_9, 1, argmax); end if;
   if (arg_10 = chr(0)) then l_arg_10 := ''; else l_arg_10 := substr(arg_10, 1, argmax); end if;
   if (arg_11 = chr(0)) then l_arg_11 := ''; else l_arg_11 := substr(arg_11, 1, argmax); end if;
   if (arg_12 = chr(0)) then l_arg_12 := ''; else l_arg_12 := substr(arg_12, 1, argmax); end if;
   if (arg_13 = chr(0)) then l_arg_13 := ''; else l_arg_13 := substr(arg_13, 1, argmax); end if;
   if (arg_14 = chr(0)) then l_arg_14 := ''; else l_arg_14 := substr(arg_14, 1, argmax); end if;
   if (arg_15 = chr(0)) then l_arg_15 := ''; else l_arg_15 := substr(arg_15, 1, argmax); end if;
   if (arg_16 = chr(0)) then l_arg_16 := ''; else l_arg_16 := substr(arg_16, 1, argmax); end if;
   if (arg_17 = chr(0)) then l_arg_17 := ''; else l_arg_17 := substr(arg_17, 1, argmax); end if;
   if (arg_18 = chr(0)) then l_arg_18 := ''; else l_arg_18 := substr(arg_18, 1, argmax); end if;
   if (arg_19 = chr(0)) then l_arg_19 := ''; else l_arg_19 := substr(arg_19, 1, argmax); end if;
   if (arg_20 = chr(0)) then l_arg_20 := ''; else l_arg_20 := substr(arg_20, 1, argmax); end if;

   -- Create the transaction message
   msg := system.FND_CP_TM_AQ_PAYLOAD(request_id,
                                       send_type,
                                       expiration_time,
                                       nls_lang,
                                       nls_num_chars,
                                       nls_date_lang,
                                       secgrpid,
                                       enable_trace_flag,
                                       fnd_global.user_id,
                                       fnd_global.resp_appl_id,
                                       fnd_global.resp_id,
                                       fnd_global.login_id,
                                       application,
                                       program,
                                       NULL,
                                       NULL,
                                       org_type,
                                       org_id,
                                       l_arg_1,
                                       l_arg_2,
                                       l_arg_3,
                                       l_arg_4,
                                       l_arg_5,
                                       l_arg_6,
                                       l_arg_7,
                                       l_arg_8,
                                       l_arg_9,
                                       l_arg_10,
                                       l_arg_11,
                                       l_arg_12,
                                       l_arg_13,
                                       l_arg_14,
                                       l_arg_15,
                                       l_arg_16,
                                       l_arg_17,
                                       l_arg_18,
                                       l_arg_19,
                                       l_arg_20
                                       );

    enq_opts.visibility := DBMS_AQ.IMMEDIATE;
    enq_opts.sequence_deviation := NULL;
    msg_props.delay := DBMS_AQ.NO_DELAY;

    msg_props.sender_id := sys.aq$_agent(TMPREFIX || request_id, NULL, NULL);

    msg_props.recipient_list(0) := sys.aq$_agent(TMQID, NULL, NULL);

    msg_props.correlation := processor_id;


    -- Queue the transaction message
    DBMS_AQ.Enqueue( queue_name          => Q_Name,
                     enqueue_options     => enq_opts,
                     message_properties  => msg_props,
                     Payload             => msg,
                     msgid               => msg_id);


    if (debug_flag) then
      fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Waiting for return message', request_id, 'U');
    end if;

    msg := system.FND_CP_TM_AQ_PAYLOAD(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

    dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE;
    dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
    dq_opts.VISIBILITY := DBMS_AQ.IMMEDIATE;
    dq_opts.MSGID := NULL;



    -- Use the request id as our consumer name.
    -- The TM will address the return message to this id
    dq_opts.consumer_name := TMPREFIX || request_id;

    time_left := timeout;
    end_time := sysdate + (timeout * fnd_transaction.DAY_PER_SEC);


    -- Loop until the return message arrives or the timeout expires,
    -- but do not wait on any single dequeue call more than TIMEOUT_INCREMENT seconds
    loop
      if time_left > TIMEOUT_INCREMENT then
        dq_opts.WAIT := TIMEOUT_INCREMENT;
      else
        dq_opts.WAIT := time_left;
      end if;

      begin

        -- Listen for the return message
        DBMS_AQ.DEQUEUE(QUEUE_NAME => RetQ_Name,
                        DEQUEUE_OPTIONS => dq_opts,
                        MESSAGE_PROPERTIES => msg_props,
                        PAYLOAD => msg,
                        MSGID => msg_id);
        if (debug_flag) then
           fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Got return message', request_id, 'U');
        end if;
        exit;

      exception
         when queue_timeout then
          if (debug_flag) then
            fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Dequeue timeout', request_id, 'U');
          end if;

          if sysdate >= end_time then

            -- Timed out waiting for return message
            begin
              /* remove our message from the queue */
              dq_opts.MSGID := msg_id;
              dq_opts.WAIT := DBMS_AQ.NO_WAIT;
              dq_opts.consumer_name := TMQID;
              DBMS_AQ.DEQUEUE(QUEUE_NAME => Q_Name,
                              DEQUEUE_OPTIONS => dq_opts,
                              MESSAGE_PROPERTIES => msg_props,
                              PAYLOAD => msg,
                              MSGID => msg_id);
            exception
               when others then
                 fnd_transaction.debug_info('fnd_trn_queue.send_message',
                                            'Unable to remove timed-out message', sqlerrm, 'U');
            end;

            if (debug_flag) then
                fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Return message timed out', request_id, 'U');
            end if;
            fnd_transaction.post_tm_event(4, application, program, -1, timeout);
            return fnd_transaction.E_TIMEOUT;

          end if;

          -- Time is not up yet, keep waiting
          time_left := (end_time - sysdate) * fnd_transaction.SEC_PER_DAY;
      end;

    end loop;

    outcome := msg.outcome;
    message := msg.message;

    if (debug_flag) then
       fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Outcome', outcome, 'U');
       fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Message', message, 'U');
    end if;

    fnd_transaction.return_values(1) := msg.arg1;
    fnd_transaction.return_values(2) := msg.arg2;
    fnd_transaction.return_values(3) := msg.arg3;
    fnd_transaction.return_values(4) := msg.arg4;
    fnd_transaction.return_values(5) := msg.arg5;
    fnd_transaction.return_values(6) := msg.arg6;
    fnd_transaction.return_values(7) := msg.arg7;
    fnd_transaction.return_values(8) := msg.arg8;
    fnd_transaction.return_values(9) := msg.arg9;
    fnd_transaction.return_values(10) := msg.arg10;
    fnd_transaction.return_values(11) := msg.arg11;
    fnd_transaction.return_values(12) := msg.arg12;
    fnd_transaction.return_values(13) := msg.arg13;
    fnd_transaction.return_values(14) := msg.arg14;
    fnd_transaction.return_values(15) := msg.arg15;
    fnd_transaction.return_values(16) := msg.arg16;
    fnd_transaction.return_values(17) := msg.arg17;
    fnd_transaction.return_values(18) := msg.arg18;
    fnd_transaction.return_values(19) := msg.arg19;
    fnd_transaction.return_values(20) := msg.arg20;

    if (debug_flag) then
       for counter1 in 1..20 loop
         fnd_transaction.debug_info('fnd_trn_queue.send_message',
                    'Return table entry #'||to_char(counter1),
                    fnd_transaction.return_values(counter1), 'U');
       end loop;
    end if;

    if (debug_flag) then
       fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Transaction complete', '', 'U');
    end if;

    return fnd_transaction.E_SUCCESS;

exception
    when OTHERS then
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'FND_TRANSACTION_QUEUE.SEND_MESSAGE', FALSE);
        fnd_transaction.debug_info('fnd_trn_queue.send_message', 'Caught exception', sqlerrm);
        return fnd_transaction.E_OTHER;

end send_message;


end fnd_transaction_queue;

/
