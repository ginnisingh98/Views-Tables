--------------------------------------------------------
--  DDL for Package Body FND_TRANSACTION_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TRANSACTION_PIPE" as
 /* $Header: AFCPTRPB.pls 120.1 2005/09/17 02:02:11 pferguso noship $ */

 --
 -- Constants
 --
 FNDCPRP   constant varchar2(10) := 'FNDCPTM:R:';       -- R pipe prefix
 FNDCPTP   constant varchar2(10) := 'FNDCPTM:T:';       -- T pipe prefix

 --
 -- Private Variables
 --
 tm_pipe           varchar2(80);
 debug_flag        boolean := FALSE;


 --   get_manager
 -- Purpose
 --   Build the names of the request and token pipes
 --   to which a request will be sent.
 -- Arguments
 --   IN:
 --     application - program application short name
 --     program     - program short name
 -- Returns
 --   0 on success.
 --   2 if no manager is available
 --   3 on failure.
 -- Notes
 --   Pipe names have the following format:
 --     prefix:concurrent_queue_id
 --
 function get_manager(application   in  varchar2,
                      program       in  varchar2,
                      timeout       in number) return number is

     queue_id     number;
     status       number;
     all_busy     exception;
     error        exception;
     token_pipe   varchar2(80);
     resp_appl_id number;
     resp_id      number;

     cursor tm(appl_short_name varchar2, prog_short_name varchar2,
               resp_appl_id number, resp_id number) is
     select /*+ ORDERED USE_NL (fa fcp fr fcpp fcq)
            INDEX (fcq,FND_CONCURRENT_QUEUES_N1)
            INDEX (fcpp,FND_CONC_PROCESSOR_PROGRAMS_U2) */
          fcq.concurrent_queue_id
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
          and fcpr.process_status_code = 'A'
          and fcpr.instance_number = userenv('instance')
         order by DBMS_RANDOM.RANDOM;


 begin

     debug_flag := fnd_transaction.debug_flag;

     resp_appl_id := fnd_global.resp_appl_id;
     resp_id := fnd_global.resp_id;

     if (debug_flag) then
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager',
                                  'Searching for manager to run:',
                                  application || ':' || program);
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager',
                                  'RESP_APPL_ID:RESP_ID',
                                  to_char(resp_appl_id) || ':' || to_char(resp_id));
     end if;

     open tm(application, program, resp_appl_id, resp_id);

     -- Fetch ID of first manager
     fetch tm into queue_id;
     -- If cursor is empty, then no manager is defined for request.
     if (tm%rowcount = 0 ) then
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager', 'No manager defined', NULL);

       fnd_transaction.post_tm_event(1, application, program, -1);

       fnd_message.set_name('FND', 'CONC-TM-No manager defined');
       fnd_message.set_token('APPLICATION', application);
       fnd_message.set_token('PROGRAM', program);
       fnd_message.set_token('RESP_ID', resp_id);
       fnd_message.set_token('RESP_APPL_ID', resp_appl_id);
       raise error;
     end if;

     if (debug_flag) then
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager',
                                  'Timeout for token pipe',
                                  to_char(timeout));
     end if;

     loop
       -- Attempt to get the token for the manager
       token_pipe := FNDCPTP || to_char(queue_id);
       if (debug_flag) then
         fnd_transaction.debug_info('fnd_trn_pipe.get_manager',
                                    'Trying token pipe',
                                    token_pipe);
       end if;
       status := dbms_pipe.receive_message(token_pipe, timeout);

       -- Exit loop if we got the token
       exit when (status = 0);

       -- Raise exception on error other than timeout.
       if (status <> 1) then
         fnd_transaction.debug_info('fnd_trn_pipe.get_manager', 'Token read error:', to_char(status));
         fnd_message.set_name('FND', 'CONC-TM-Token read error');
         raise error;
       end if;

       /* mark soft busy event (2) */
       fnd_transaction.post_tm_event(2, application, program, queue_id);

       -- Fetch next manager name
       fetch tm into queue_id;
       if tm%notfound then raise all_busy; end if;  -- Exhausted the list
     end loop;

     -- bug 3623063
     -- save queue_id to be used for logging msgs to fnd_concurrent_debug_info
     fnd_transaction.conc_queue_id := queue_id;

     -- Construct the manager pipe name and return with success.
     tm_pipe := FNDCPRP || to_char(queue_id);
     close tm;

     if (debug_flag) then
      fnd_transaction.debug_info('fnd_trn_pipe.get_manager',
                 'Got available TM process',
                 tm_pipe);
     end if;

     return fnd_transaction.E_SUCCESS;

   exception
     when all_busy then  -- All managers capable of running the request
                         -- are busy or down.

       /* mark all appropriate managers as hard busy events */
       fnd_transaction.post_tm_event(3, application, program, -1 );

       close tm;
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager', 'All managers busy or down', NULL);
       return fnd_transaction.E_NOMGR;
     when error then
       if tm%isopen then
         close tm;
       end if;
       return fnd_transaction.E_OTHER;
     when others then
       if tm%isopen then
         close tm;
       end if;
       fnd_message.set_name ('FND', 'SQL-Generic error');
       fnd_message.set_token ('ERRNO', sqlcode, FALSE);
       fnd_message.set_token ('REASON', sqlerrm, FALSE);
       fnd_message.set_token ('ROUTINE', 'FND_TRN_PIPE.GET_MANAGER', FALSE);
       fnd_transaction.debug_info('fnd_trn_pipe.get_manager', 'Caught exception', sqlerrm);

       return fnd_transaction.E_OTHER;

end get_manager;




 --
 --  send_message
 -- Purpose
 --   Puts the transaction message on the pipe and waits for the return message
 -- Returns
 --   E_SUCCESS on success
 --   E_TIMEOUT if return message times out
 --   E_OTHER on failure
 --
function send_message( timeout in number,
                        send_type in varchar2,
                        expiration_time in date,
                        request_id       in number,
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
                        arg_1             in varchar2,
                        arg_2             in varchar2,
                        arg_3             in varchar2,
                        arg_4             in varchar2,
                        arg_5             in varchar2,
                        arg_6             in varchar2,
                        arg_7             in varchar2,
                        arg_8             in varchar2,
                        arg_9             in varchar2,
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

   return_pipe       varchar2(30) := dbms_pipe.unique_session_name;
   argtotal          number;
   argslen_err       exception;
   tmpstr            varchar2(480);
   submit_time       date;
   remaining_time    number;
   status            number;
   return_val        varchar2(480);
   error             exception;
   return_request_id number;
   counter1          number;
   counter2          number;

begin

     dbms_pipe.reset_buffer;

     -- Pack message header
     dbms_pipe.pack_message (send_type);
     dbms_pipe.pack_message (expiration_time);
     dbms_pipe.pack_message (request_id);
     dbms_pipe.pack_message (return_pipe);
     dbms_pipe.pack_message (nls_lang);
     dbms_pipe.pack_message (nls_num_chars);
     dbms_pipe.pack_message (nls_date_lang);
     dbms_pipe.pack_message (secgrpid);
     dbms_pipe.pack_message (FND_CONC_GLOBAL.OPS_INST_NUM);
     dbms_pipe.pack_message (enable_trace_flag);
     dbms_pipe.pack_message (fnd_global.user_id);
     dbms_pipe.pack_message (fnd_global.resp_appl_id);
     dbms_pipe.pack_message (fnd_global.resp_id);
     dbms_pipe.pack_message (fnd_global.login_id);
     dbms_pipe.pack_message (application);
     dbms_pipe.pack_message (program);
     dbms_pipe.pack_message (org_type);
     dbms_pipe.pack_message (org_id);

     -- Pack arguments
     argtotal := 0;

     if (arg_1 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_1, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_2 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_2, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_3 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_3, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_4 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_4, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_5 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_5, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_6 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_6, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_7 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_7, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_8 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_8, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_9 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_9, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_10 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_10, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_11 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_11, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_12 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_12, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_13 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_13, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_14 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_14, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_15 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_15, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_16 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_16, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_17 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_17, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_18 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_18, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_19 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_19, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);
     if (arg_20 = CHR(0)) then goto end_pack; end if;
     tmpstr := substr(arg_20, 1, fnd_transaction.ARGMAX);
     argtotal := argtotal + length(tmpstr);
     if argtotal > fnd_transaction.ARGSTOTAL then
        raise argslen_err;
     end if;
     dbms_pipe.pack_message (tmpstr);

     <<end_pack>>


     -- Set time stamps
     submit_time := sysdate;
     remaining_time := timeout;

     -- Send the message.  Exit on timeout or error.
     status := dbms_pipe.send_message(tm_pipe, remaining_time);
     if (status = 1) then
       fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'send_message timeout', NULL);

       /* mark timeout event (4) */
       fnd_transaction.post_tm_event(4, application, program, -1, timeout, tm_pipe );

       return fnd_transaction.E_TIMEOUT;
     elsif (status <> 0) then
        fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'send_message returned:', to_char(status));
        raise error;
     end if;

     -- Loop until timeout or we recieve a message on the return pipe
     -- with a matching request ID.  Throw out all other received messages.
     loop
       -- calculate the remaining timeout
       remaining_time := remaining_time - ((sysdate-submit_time)*fnd_transaction.SEC_PER_DAY);

       -- 906219 - added call to reset_buffer here to clear the buffer
       -- before receiving the message.
       -- Leftover data in the buffer was causing messages to come out incorrect.
       -- Also added calls in FNDCP_TMSRV
       dbms_pipe.reset_buffer;

       -- Wait on return pipe.  Exit on timoeout or error
       status := dbms_pipe.receive_message(return_pipe, remaining_time);
       if (status = 1) then
         fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'receive_message timeout', NULL, 'U');

         /* mark timeout event (4) */
         fnd_transaction.post_tm_event(4, application, program, -1, timeout, tm_pipe);

         return fnd_transaction.E_TIMEOUT;
       elsif (status <> 0) then
      fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'receive_message returned:', to_char(status), 'U');
      raise error;
       end if;

       -- Exit loop only if we got the proper response
       if (dbms_pipe.next_item_type = 9) then
          dbms_pipe.unpack_message(tmpstr); -- Discard return type
         if (dbms_pipe.next_item_type = 6) then
           dbms_pipe.unpack_message(return_request_id);
           exit when (request_id = return_request_id);
         end if;
       end if;
     end loop;

     -- Unpack return arguments
     dbms_pipe.unpack_message(outcome);
     dbms_pipe.unpack_message(message);

     -- Populate return value table
     for counter in 1..21 loop
       counter1 := counter;
       exit when dbms_pipe.next_item_type <> 9;
       dbms_pipe.unpack_message(return_val);
       fnd_transaction.return_values(counter) := return_val;
     end loop;

     -- Null out the unused table elements
     if (counter1 < 21) then
        for counter2 in counter1..20 loop
          fnd_transaction.return_values(counter2) := null;
        end loop;
     end if;
     if (debug_flag) then
       for counter1 in 1..20 loop
         fnd_transaction.debug_info('fnd_trn_pipe.send_message',
                    'Return table entry #'||to_char(counter1),
                    fnd_transaction.return_values(counter1), 'U');
       end loop;
     end if;

     return fnd_transaction.E_SUCCESS;

   exception
     when error then
       return fnd_transaction.E_OTHER;
     when argslen_err then
        fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'Total size of args too long', to_char(argtotal));
        return fnd_transaction.E_ARGSIZE;
     when others then
       fnd_message.set_name ('FND', 'SQL-Generic error');
       fnd_message.set_token ('ERRNO', sqlcode, FALSE);
       fnd_message.set_token ('REASON', sqlerrm, FALSE);
       fnd_message.set_token (
             'ROUTINE', 'FND_TRN_PIPE.SEND_MESSAGE', FALSE);
       fnd_transaction.debug_info('fnd_trn_pipe.send_message', 'Caught exception', sqlerrm);
       return fnd_transaction.E_OTHER;


end send_message;

end fnd_transaction_pipe;

/
