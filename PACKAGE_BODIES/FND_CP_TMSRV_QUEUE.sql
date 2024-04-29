--------------------------------------------------------
--  DDL for Package Body FND_CP_TMSRV_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_TMSRV_QUEUE" as
/* $Header: AFCPTMQB.pls 120.1 2005/09/17 02:01:13 pferguso noship $ */



--
-- Constants
--

-- Name of the TM AQ
QUEUE_NAME         constant VARCHAR2(30) := 'FND_CP_TM_AQ';

-- Name of the TM Return AQ
RETURN_QUEUE_NAME  constant VARCHAR2(30) := 'FND_CP_TM_RET_AQ';

-- Prefix added to all recipient and consumer names
TMPREFIX           constant VARCHAR2(3)  := 'TM';

-- Largest increment to wait for dequeue
TIMEOUT_INCREMENT  constant number := 10;

-- Consumer name for all managers
TMQID              constant varchar2(30) := 'TMSRV';



--
-- Private variables
--

P_DEBUG         varchar2(1)    := FNDCP_TMSRV.DBG_OFF;
Q_Name          varchar2(64) := null;
RetQ_Name       varchar2(64) := null;
P_SENDER_ID     varchar2(30) := null;
P_SENDER_AGENT  sys.aq$_agent;
P_ENQ_OPTS      DBMS_AQ.enqueue_options_t;
P_DEQ_OPTS      DBMS_AQ.dequeue_options_t;
P_CORRELATION_ID varchar2(32);


--
-- Queue initialization
--

procedure initialize (e_code in out nocopy number,
                      qid    in     number,
                      pid    in     number) is

 status    varchar2(1);
 industry  varchar2(1);
 schema    varchar2(30);
 r         boolean;

pragma AUTONOMOUS_TRANSACTION;
begin


  P_SENDER_ID := TMPREFIX || pid;
  P_SENDER_AGENT := sys.aq$_agent(P_SENDER_ID, NULL, NULL);

  P_ENQ_OPTS.visibility := DBMS_AQ.IMMEDIATE;
  P_ENQ_OPTS.sequence_deviation := NULL;

  select PROCESSOR_APPLICATION_ID || '.' || CONCURRENT_PROCESSOR_ID
    into P_CORRELATION_ID
    from fnd_concurrent_queues
    where concurrent_queue_id = qid;

  P_DEQ_OPTS.dequeue_mode := DBMS_AQ.REMOVE;
  P_DEQ_OPTS.navigation := DBMS_AQ.FIRST_MESSAGE;
  P_DEQ_OPTS.visibility := DBMS_AQ.IMMEDIATE;
  P_DEQ_OPTS.consumer_name := TMQID;
  P_DEQ_OPTS.correlation := P_CORRELATION_ID;

  r := fnd_installation.get_app_info('FND', status, industry, schema);

  Q_Name := schema || '.' || QUEUE_NAME;
  RetQ_Name := schema || '.' || RETURN_QUEUE_NAME;

  e_code := FNDCP_TMSRV.E_SUCCESS;

  commit;

end initialize;



procedure set_debug(dbgtype  in varchar2) is
begin
   P_DEBUG := dbgtype;
   FNDCP_TMSRV.P_DEBUG := dbgtype;
end set_debug;




procedure read_message (e_code  in out nocopy number,
                        timeout in     number,
                        pktyp   in out nocopy varchar2,
                        enddate in out nocopy varchar2,
                        reqid   in out nocopy number,
                        return_id in out nocopy varchar2,
                        nlslang in out nocopy varchar2,
                        nls_num_chars in out nocopy varchar2,
                        nls_date_lang in out nocopy varchar2,
                        secgrpid in out nocopy number,
                        usrid   in out nocopy number,
                        rspapid in out nocopy number,
                        rspid   in out nocopy number,
                        logid   in out nocopy number,
                        apsname in out nocopy varchar2,
                        program in out nocopy varchar2,
                        numargs in out nocopy number,
                        org_type in out nocopy varchar2,
                        org_id  in out nocopy number,
                        arg_1   in out nocopy varchar2,
                        arg_2   in out nocopy varchar2,
                        arg_3   in out nocopy varchar2,
                        arg_4   in out nocopy varchar2,
                        arg_5   in out nocopy varchar2,
                        arg_6   in out nocopy varchar2,
                        arg_7   in out nocopy varchar2,
                        arg_8   in out nocopy varchar2,
                        arg_9   in out nocopy varchar2,
                        arg_10  in out nocopy varchar2,
                        arg_11  in out nocopy varchar2,
                        arg_12  in out nocopy varchar2,
                        arg_13  in out nocopy varchar2,
                        arg_14  in out nocopy varchar2,
                        arg_15  in out nocopy varchar2,
                        arg_16  in out nocopy varchar2,
                        arg_17  in out nocopy varchar2,
                        arg_18  in out nocopy varchar2,
                        arg_19  in out nocopy varchar2,
                        arg_20  in out nocopy varchar2) is

payload         system.FND_CP_TM_AQ_PAYLOAD;
msg_props       DBMS_AQ.MESSAGE_PROPERTIES_T;
msgid           raw(16);
queue_timeout   exception;
enable_trace    varchar2(255);
sql_stmt        varchar2(255);


pragma exception_init(queue_timeout, -25228);
begin

    payload := system.FND_CP_TM_AQ_PAYLOAD(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


    P_DEQ_OPTS.MSGID := NULL;
    P_DEQ_OPTS.WAIT := timeout;

    begin

      DBMS_AQ.DEQUEUE(QUEUE_NAME         => Q_Name,
                      DEQUEUE_OPTIONS    => P_DEQ_OPTS,
                      MESSAGE_PROPERTIES => msg_props,
                      PAYLOAD            => payload,
                      MSGID              => msgid);

      e_code := FNDCP_TMSRV.E_SUCCESS;

    exception
      when queue_timeout then
        e_code := FNDCP_TMSRV.E_TIMEOUT;
        return;

      when others then
        fndcp_tmsrv.debug_info('tmsrv_queue.read_message', 'Caught exception in DQ', sqlerrm);
        return;
    end;


    pktyp := payload.msgtype;
    if (pktyp not in (FNDCP_TMSRV.PK_TRN, FNDCP_TMSRV.PK_TRN_D1, FNDCP_TMSRV.PK_TRN_D2)) then
       e_code := FNDCP_TMSRV.E_OTHER;
       return;
    end if;

    set_debug(pktyp);

    enddate       := payload.enddate;
    reqid         := payload.reqid;
    nlslang       := payload.nlslang;
    nls_num_chars := payload.nls_num_chars;
    nls_date_lang := payload.nls_date_lang;
    secgrpid      := payload.secgrpid;
    enable_trace  := payload.enable_trace;
    usrid         := payload.userid;
    rspapid       := payload.rspapid;
    rspid         := payload.rspid;
    logid         := payload.logid;
    apsname       := payload.apsname;
    program       := payload.program;
    org_type      := payload.org_type;
    org_id        := payload.org_id;

    numargs := 0;
    arg_1 := payload.arg1;
    if arg_1 <> chr(0) then numargs := numargs + 1; end if;
    arg_2 := payload.arg2;
    if arg_2 <> chr(0) then numargs := numargs + 1; end if;
    arg_3 := payload.arg3;
    if arg_3 <> chr(0) then numargs := numargs + 1; end if;
    arg_4 := payload.arg4;
    if arg_4 <> chr(0) then numargs := numargs + 1; end if;
    arg_5 := payload.arg5;
    if arg_5 <> chr(0) then numargs := numargs + 1; end if;
    arg_6 := payload.arg6;
    if arg_6 <> chr(0) then numargs := numargs + 1; end if;
    arg_7 := payload.arg7;
    if arg_7 <> chr(0) then numargs := numargs + 1; end if;
    arg_8 := payload.arg8;
    if arg_8 <> chr(0) then numargs := numargs + 1; end if;
    arg_9 := payload.arg9;
    if arg_9 <> chr(0) then numargs := numargs + 1; end if;
    arg_10 := payload.arg10;
    if arg_10 <> chr(0) then numargs := numargs + 1; end if;
    arg_11 := payload.arg11;
    if arg_11 <> chr(0) then numargs := numargs + 1; end if;
    arg_12 := payload.arg12;
    if arg_12 <> chr(0) then numargs := numargs + 1; end if;
    arg_13 := payload.arg13;
    if arg_13 <> chr(0) then numargs := numargs + 1; end if;
    arg_14 := payload.arg14;
    if arg_14 <> chr(0) then numargs := numargs + 1; end if;
    arg_15 := payload.arg15;
    if arg_15 <> chr(0) then numargs := numargs + 1; end if;
    arg_16 := payload.arg16;
    if arg_16 <> chr(0) then numargs := numargs + 1; end if;
    arg_17 := payload.arg17;
    if arg_17 <> chr(0) then numargs := numargs + 1; end if;
    arg_18 := payload.arg18;
    if arg_18 <> chr(0) then numargs := numargs + 1; end if;
    arg_19 := payload.arg19;
    if arg_19 <> chr(0) then numargs := numargs + 1; end if;
    arg_20 := payload.arg20;
    if arg_20 <> chr(0) then numargs := numargs + 1; end if;

    if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
      fndcp_tmsrv.debug_info('TMSRV_QUEUE.read_message',
                 'Unpacked request details', NULL, 'M');

    end if;

    sql_stmt := 'ALTER SESSION SET SQL_TRACE = '|| enable_trace;
    EXECUTE IMMEDIATE sql_stmt ;

    if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
      fndcp_tmsrv.debug_info('TMSRV_QUEUE.read_message',
                 'SQL_TRACE:', enable_trace, 'M');

    end if;


exception

   when OTHERS then
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'TMSRV_QUEUE.READ_MESSAGE', FALSE);
        fndcp_tmsrv.debug_info('tmsrv_queue.read_message', 'Caught exception', sqlerrm);
        e_code := FNDCP_TMSRV.E_OTHER;
end read_message;




procedure write_message (e_code     in out nocopy number,
                         return_id  in     varchar2,
                         pktyp      in     varchar2,
                         reqid      in     number,
                         outcome    in     varchar2,
                         message    in     varchar2) is

msg_props  DBMS_AQ.message_properties_t;
msg_id     raw(16);
msg        system.FND_CP_TM_AQ_PAYLOAD;

begin

  e_code := FNDCP_TMSRV.E_SUCCESS;

  FNDCP_TMSRV.P_RETVALCOUNT := 0;    -- Reset the return values table.

  if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
      fndcp_tmsrv.debug_info('TMSRV_QUEUE.write_message',
                 'Packing return message' ,
                 reqid, 'S');

  end if;

  msg := system.FND_CP_TM_AQ_PAYLOAD(reqid,
                                     pktyp,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     outcome,
                                     message,
                                     null,
                                     null,
                                     FNDCP_TMSRV.P_RETURN_VALS(1),
                                     FNDCP_TMSRV.P_RETURN_VALS(2),
                                     FNDCP_TMSRV.P_RETURN_VALS(3),
                                     FNDCP_TMSRV.P_RETURN_VALS(4),
                                     FNDCP_TMSRV.P_RETURN_VALS(5),
                                     FNDCP_TMSRV.P_RETURN_VALS(6),
                                     FNDCP_TMSRV.P_RETURN_VALS(7),
                                     FNDCP_TMSRV.P_RETURN_VALS(8),
                                     FNDCP_TMSRV.P_RETURN_VALS(9),
                                     FNDCP_TMSRV.P_RETURN_VALS(10),
                                     FNDCP_TMSRV.P_RETURN_VALS(11),
                                     FNDCP_TMSRV.P_RETURN_VALS(12),
                                     FNDCP_TMSRV.P_RETURN_VALS(13),
                                     FNDCP_TMSRV.P_RETURN_VALS(14),
                                     FNDCP_TMSRV.P_RETURN_VALS(15),
                                     FNDCP_TMSRV.P_RETURN_VALS(16),
                                     FNDCP_TMSRV.P_RETURN_VALS(17),
                                     FNDCP_TMSRV.P_RETURN_VALS(18),
                                     FNDCP_TMSRV.P_RETURN_VALS(19),
                                     FNDCP_TMSRV.P_RETURN_VALS(20)
                                     );

     msg_props.delay := DBMS_AQ.NO_DELAY;

     msg_props.sender_id := P_SENDER_AGENT;

     msg_props.recipient_list(0) := sys.aq$_agent(TMPREFIX || reqid, NULL, NULL);

     -- don't let the message stay on the queue forever, but don't make the queue monitor
     -- work too hard...
     msg_props.expiration := 600;

     DBMS_AQ.Enqueue( queue_name         => RetQ_Name,
                      enqueue_options    => P_ENQ_OPTS,
                      message_properties => msg_props,
                      Payload            => msg,
                      msgid              => msg_id);

     if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
       fndcp_tmsrv.debug_info('TMSRV_QUEUE.write_message',
                  'Sent Message' ,
                  reqid, 'S');

     end if;

     -- Turn off debug.
     set_debug(FNDCP_TMSRV.DBG_OFF);

     -- Reset all the return values
     for counter in 1..20 loop
       FNDCP_TMSRV.P_RETURN_VALS(counter) := null;
     end loop;

 exception
     when OTHERS then
       e_code := FNDCP_TMSRV.E_OTHER;
       fnd_message.set_name ('FND', 'SQL-Generic error');
       fnd_message.set_token ('ERRNO', sqlcode, FALSE);
       fnd_message.set_token ('REASON', sqlerrm, FALSE);
       fnd_message.set_token ('ROUTINE', 'TMSRV_QUEUE.COMPLETE_TRANS', FALSE);
       fndcp_tmsrv.debug_info('tmsrv_queue.complete_trans', 'Caught exception', sqlerrm);
       raise;

end write_message;



end fnd_cp_tmsrv_queue;

/
