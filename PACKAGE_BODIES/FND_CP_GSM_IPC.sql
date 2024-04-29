--------------------------------------------------------
--  DDL for Package Body FND_CP_GSM_IPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_GSM_IPC" AS
/* $Header: AFCPSMIB.pls 120.5.12010000.2 2012/12/10 22:37:15 ckclark ship $ */



--=========================================================================--
/* Private Functions */
--=========================================================================--
P_Applsys_Schema varchar2(30) := NULL;

Function Q_Schema return Varchar2 is

pragma AUTONOMOUS_TRANSACTION;

begin

  if (P_Applsys_Schema is null) then
    Select TEXT
      into P_Applsys_Schema
      from WF_RESOURCES
     where TYPE =    'WFTKN'
       and NAME = 'WF_SCHEMA'
       and rownum = 1;
  end if;

  commit;
  return(P_Applsys_Schema);

exception
  when OTHERS then
              rollback;
end;

--=========================================================================--
/* ICM Functions */
--=========================================================================--

/*--------------------------------------------------------------------------
procedure Unsubscribe -unsub from AQ.  Null -> unsub all
-----------------------------------------------------------------------------*/

procedure Unsubscribe(cpid in number default null) is

sql_stmt varchar2(2000);

pragma AUTONOMOUS_TRANSACTION;

Begin
  if cpid is not null then
    DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name =>Q_Schema||'.FND_CP_GSM_IPC_AQ',
      subscriber => sys.aq$_agent('FNDCPGSMIPC_Cartridge_'||to_char(cpid),
                NULL, NULL));

    DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name =>Q_Schema||'.FND_CP_GSM_IPC_AQ',
      subscriber => sys.aq$_agent('FNDCPGSMIPC_Service_'||to_char(cpid),
                NULL, NULL));
  else
    sql_stmt := 'declare ';

    sql_stmt := sql_stmt || 'CURSOR C1 is select NAME name ';
    sql_stmt := sql_stmt || ' from '||Q_Schema||'.aq$FND_CP_GSM_IPC_AQTBL_S ';
    sql_stmt := sql_stmt || ' where QUEUE=''FND_CP_GSM_IPC_AQ'';';

    sql_stmt := sql_stmt || ' begin ';
    sql_stmt := sql_stmt || '   for c1rec in c1 loop ';

    sql_stmt := sql_stmt || 'DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name => ''';
    sql_stmt := sql_stmt || Q_Schema || '.FND_CP_GSM_IPC_AQ'', ';
    sql_stmt := sql_stmt || 'subscriber=>sys.aq$_agent(c1rec.name,NULL,NULL));';

    sql_stmt := sql_stmt || ' end loop; ';
    sql_stmt := sql_stmt || ' end;';

    EXECUTE IMMEDIATE sql_stmt ;
  end if;

  commit;

Exception
  when others then null;
                   rollback;
end;


--=========================================================================-
/* Cartridge Functions */
--=========================================================================--

/*--------------------------------------------------------------------------
procedure Init_Cartridge
-----------------------------------------------------------------------------*/

procedure Init_Cartridge is

Not_Done Boolean;
PAYLOAD system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
dq_opts DBMS_AQ.DEQUEUE_OPTIONS_T;
msg_props DBMS_AQ.MESSAGE_PROPERTIES_T;
msgid raw(16);

pragma AUTONOMOUS_TRANSACTION;

Begin
    /* we should clear expired messages out of exception queue */
    dq_opts.consumer_name := NULL;
    dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE;
    dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
    dq_opts.VISIBILITY := DBMS_AQ.ON_COMMIT;
    dq_opts.WAIT := DBMS_AQ.NO_WAIT;
    dq_opts.MSGID := NULL;

    Not_Done := TRUE;

    while Not_Done LOOP
	begin
	   DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.AQ$_FND_CP_GSM_IPC_AQTBL_E',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
		    MSGID => msgid);
	exception when others then Not_Done := FALSE;
	end;
    end LOOP;

    commit;

exception
    when OTHERS then
                rollback;
		raise;
End;

/*--------------------------------------------------------------------------
procedure Shutdown_Cartridge
-----------------------------------------------------------------------------*/

procedure Shutdown_Cartridge is

pragma AUTONOMOUS_TRANSACTION;

Begin
  /* Doesn't appear that anything is necessary...but we'll keep the hook */
  null;
  commit;

exception
    when OTHERS then
                rollback;
		raise;
End;

/*--------------------------------------------------------------------------
        procedure Cartridge_Init_Service
-----------------------------------------------------------------------------*/

procedure Cartridge_Init_Service(cpid in Number,
                        Params in Varchar2,
                        Debug_Level in Varchar2) is

pragma AUTONOMOUS_TRANSACTION;

begin
    DBMS_AQADM.ADD_SUBSCRIBER(queue_name =>Q_Schema||'.FND_CP_GSM_IPC_AQ',
      subscriber => sys.aq$_agent('FNDCPGSMIPC_Cartridge_'||to_char(cpid),
		NULL, NULL));

    DBMS_AQADM.ADD_SUBSCRIBER(queue_name =>Q_Schema||'.FND_CP_GSM_IPC_AQ',
      subscriber => sys.aq$_agent('FNDCPGSMIPC_Service_'||to_char(cpid),
		NULL, NULL));

    Send_Message(cpid,'Initialize',Params,Debug_Level);
    Update_Status (cpid, 'Uninitialized');
    commit;

exception
    when OTHERS then
                rollback;
		raise;
end;



/*--------------------------------------------------------------------------
	Procedure Send_Message:

	Handle = CPID
	Message -> Stop, Suspend, Resume, Verify, Initialize
	Payload - Currently only used to send parameters with Verify
	Debug_Level = One character Debug Level
-----------------------------------------------------------------------------*/

Procedure Send_Message (Handle in Number,
	     		Message in Varchar2,
			Parameters in Varchar2,
			Debug_Level in Varchar2) is


enq_opts	DBMS_AQ.enqueue_options_t;
msg_props	DBMS_AQ.message_properties_t;
msg_id		raw(16);
msg		system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
sessionid	number;

pragma AUTONOMOUS_TRANSACTION;

begin
    msg := system.FND_CP_GSM_IPQ_AQ_PAYLOAD(
		Handle,Message,Parameters,Debug_Level);

    enq_opts.visibility := DBMS_AQ.ON_COMMIT;
    enq_opts.sequence_deviation := NULL;
    msg_props.delay := DBMS_AQ.NO_DELAY;
    msg_props.expiration := 365 * 24 * 3600;	 -- One Year
    msg_props.recipient_list(1) := sys.aq$_agent(
		'FNDCPGSMIPC_Service_'||to_char(Handle),NULL, NULL);
    msg_props.sender_id := sys.aq$_agent(
		'FNDCPGSMIPC_Cartridge_'||to_char(Handle), NULL, NULL);

    DBMS_AQ.Enqueue(	queue_name 	   => Q_Schema||'.FND_CP_GSM_IPC_AQ',
			enqueue_options    => enq_opts,
			message_properties => msg_props,
			Payload 	   => msg,
			msgid	 	   => msg_id);

    commit;

exception
    when OTHERS then
                rollback;
		raise;
end;


/*--------------------------------------------------------------------------
Function Get_Status:

	Handle = CPID
-----------------------------------------------------------------------------*/

Function Get_Status (Handle in Number) Return Varchar2 is

Status_code Varchar2(1);

Begin
     Select GSM_INTERNAL_STATUS
	into Status_code
	from fnd_concurrent_processes
	where concurrent_process_id = handle;

     return (Status_code);
End;


/* No longer used */
Function Obsolete_Get_Status (Handle in Number) Return Varchar2 is

Not_Done Boolean;
Status_Name Varchar2(30);
Status_code Varchar2(1);
More_Flag Varchar2(1);
PAYLOAD system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
dq_opts DBMS_AQ.DEQUEUE_OPTIONS_T;
msg_props DBMS_AQ.MESSAGE_PROPERTIES_T;
msgid raw(16);
last_msg raw(16);

pragma AUTONOMOUS_TRANSACTION;

Begin
     Not_Done := TRUE;

     while (Not_Done) LOOP  -- Clear off excess messages

        dq_opts.consumer_name := 'FNDCPGSMIPC_Cartridge_'||to_char(Handle);
  	dq_opts.DEQUEUE_MODE := DBMS_AQ.BROWSE;
    	dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
	dq_opts.VISIBILITY := DBMS_AQ.ON_COMMIT;
        dq_opts.WAIT := DBMS_AQ.NO_WAIT;
        dq_opts.MSGID := NULL;

        DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
                    MSGID => msgid);

	last_msg := msgid;
        Status_Name :=  PAYLOAD.Message;

        dq_opts.NAVIGATION := DBMS_AQ.NEXT_MESSAGE;

        begin
	   DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
                    MSGID => msgid);
	exception
		when others then payload.Message:= null;
        end;


        if (payload.Message is null) then 	-- No later message
		Not_Done := FALSE;
	else					-- Kill the first message
		dq_opts.CORRELATION := Null;
		dq_opts.MSGID := last_msg;
		dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE_NODATA;

		DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
                    MSGID => msgid);
        end if;
     END LOOP;

     if (UPPER(Status_Name) = 'UNINITIALIZED') then
	Status_Code := 'Z';
     elsif (UPPER(Status_Name) = 'SUSPENDED') then
        Status_Code := 'P';
     elsif (UPPER(Status_Name) = 'RUNNING') then
        Status_Code := 'A';
     elsif (UPPER(Status_Name) = 'STOPPED') then
        Status_Code := 'S';
     else 		-- No Perfect answer, best to assume its Running
        Status_Code := 'A';
     end if;

     commit;
     return (Status_code);

exception
    when OTHERS then
                rollback;
End;

--=========================================================================--
/* Routines called Externally */
--=========================================================================--


/*--------------------------------------------------------------------------
        Procedure Send_Custom_Message:

        Handle = CPID
        Type - 8 characters for identifying format
        Message - Currently only used to send parameters with Verify
-----------------------------------------------------------------------------*/


Procedure Send_Custom_Message (Handle in Number,
                        Type in varchar2,
                        Mesg in Varchar2) is
pragma AUTONOMOUS_TRANSACTION;

begin
    Send_Message (Handle, 'Custom:' || substr(Type,1,8), Mesg, Null);
    commit;

exception
    when OTHERS then
                rollback;
		raise;
end;

--=========================================================================--
/* Routines called by Service */
--=========================================================================--

/*--------------------------------------------------------------------------
	Procedure Init_Service:

        Init_Service:
        Handle = CPID
        Parameters = Initial Parameter String
        Debug_Level = One character Debug Level
-----------------------------------------------------------------------------*/

Procedure Init_Service (Handle in Number,
			Parameters out NOCOPY Varchar2,
			Debug_Level out NOCOPY Varchar2) is


mesg Varchar2(2048);
success_f Varchar2(1);
more_f    Varchar2(1);

s_id		number;
p_id		number;
osp_id		v$process.spid%TYPE := Null;
sqlnet_str      varchar2(30) := Null;
service_name    varchar2(30) := Null;
que_rcg         varchar2(32) := Null;
old_rcg         varchar2(32);
etrace          varchar2(4) := Null;
diag_level      char := Null;
sql_stmt        VARCHAR2(200) := null;
PAYLOAD 	system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
dq_opts		DBMS_AQ.DEQUEUE_OPTIONS_T;
msg_props	DBMS_AQ.MESSAGE_PROPERTIES_T;
msgid raw(16);

pragma AUTONOMOUS_TRANSACTION;

begin
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Enter procedure - Handle = '||to_char(Handle));
    end if;
    Update_Status ( Handle, 'Running');

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': status updated to running');
    end if;
    dq_opts.consumer_name := 'FNDCPGSMIPC_Service_'|| to_char(Handle);
    dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE;
    dq_opts.NAVIGATION   := DBMS_AQ.FIRST_MESSAGE;
    dq_opts.VISIBILITY   := DBMS_AQ.IMMEDIATE;
    dq_opts.WAIT 	 := DBMS_AQ.FOREVER;
    dq_opts.MSGID 	 := NULL;

    DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
		    DEQUEUE_OPTIONS => dq_opts,
		    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
		    MSGID => msgid);

    Parameters := payload.Payload;
    mesg := payload.Message;
    Debug_Level := payload.Debug_Level;

    SELECT PID, SPID, S.AUDSID
      INTO p_id, osp_id, s_id
      FROM V$PROCESS P, V$SESSION S
     WHERE S.AUDSID = USERENV('SESSIONID')
    	   AND P.Addr = S.Paddr
    	   and rownum <= 1;   /* Probably not necessary */

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': pid='||to_char(p_id)||', spid='||osp_id||', audsid='||to_char(s_id));
    end if;

    /* 5867853- Make sure the fcp row for services, like that of FNDSM
     * and managers, is storing TWO_TASK into SQLNET_STRING.  The value
     * selected here is only important if PCP DB Instance failover is on,
     * in which case TWO_TASK is required to match the instance name.
     * Thus, the FNDSM TWO_TASK in SQLNET_STRING will be < 17 characters
     * and could fit in db_instance column.
     */

    select decode(sign(length(sqlnet_string) - 17), -1, sqlnet_string, null)
      INTO sqlnet_str
      FROM FND_CONCURRENT_PROCESSES
     WHERE MANAGER_TYPE = 6
       AND UPPER(NODE_NAME) = (select upper(node_name)
                        from fnd_concurrent_processes
                        where concurrent_process_id = Handle)
       AND PROCESS_STATUS_CODE = 'A';

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': sqlnet_string='|| sqlnet_str);
    end if;

    /* 5867853- Update DB_INSTANCE and SQLNET_STRING for services */
    UPDATE FND_CONCURRENT_PROCESSES
    set SESSION_ID = s_id,
	ORACLE_PROCESS_ID = p_id,
	OS_PROCESS_ID = osp_id,
	INSTANCE_NUMBER = (Select instance_number from v$instance),
	DB_INSTANCE = (Select instance_name from v$instance),
	SQLNET_STRING = sqlnet_str,
	last_update_date = sysdate,
	last_updated_by = 4
    where CONCURRENT_PROCESS_ID = Handle;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': fnd_concurrent_processes updated');
    end if;

    select Concurrent_Queue_Name, Resource_Consumer_Group, Diagnostic_level
                  into service_name, que_rcg, diag_level
      	          from Fnd_Concurrent_Queues Q, Fnd_Concurrent_processes P
      	         WHERE Q.Application_ID = P.Queue_Application_ID
                   And Q.Concurrent_queue_ID = P.Concurrent_Queue_ID
                   And P.Concurrent_Process_Id = Handle;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': Concurrent_Queue_Name='||service_name||', Resource_Consumer_Group='||que_rcg||', Diagnostic_level='||diag_level);
    end if;

--  Until we add explicit support for TRACE ON/OFF

    if (diag_level in ('Y', '1', '2', '3')) then
      etrace := 'TRUE';
    end if;

--    FND_CTL.FND_SESS_CTL(Null, Null, etrace, Null, Null, Null);
     if etrace is not null  then
        sql_stmt := 'ALTER SESSION SET SQL_TRACE = '|| etrace;
        EXECUTE IMMEDIATE sql_stmt ;
     end if;

    dbms_application_info.set_module(service_name,
                                            'Service Management');

    if que_rcg is null then
        que_rcg := 'DEFAULT_CONSUMER_GROUP';
     end if;

     begin
       	dbms_session.switch_current_consumer_group(que_rcg, old_rcg, false);
     exception
        when others then null;
     end;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   'fnd.plsql.FND_CP_GSM_IPC.Init_Service',
                   'Handle ' ||to_char(Handle)||': Work completed successfully, commiting');
    end if;

    commit;

exception
    when OTHERS then
                rollback;
		raise;
end;

/*--------------------------------------------------------------------------
        Procedure Get_Message:

	Handle = CPID
	Message -> Stop, Suspend, Resume, Verify, Initialize (Internal)
        Parameters - Currently only used to send parameters with Verify
	Debug_Level - One character Debug Level
        Blocking_Flag = Y/N do we wait?
        Consume_Flag = Y/N do we consume message?
        More_Flag = Y/N more messages on AQ?
	Message_Wait_Timeout = Timeout to use when waiting on AQ for msg.
		Used for both blocking and non blocking calls. Null= nowait
	Blocking_Sleep_Time = Only meaningful if blocking_flag = 'Y'.  How
		many secs to sleep between looking for messages.
-----------------------------------------------------------------------------*/

Procedure Get_Message (	Handle in Number,
                        Message out NOCOPY Varchar2,
                        Parameters out NOCOPY Varchar2,
			Debug_Level out NOCOPY Varchar2,
	     		Blocking_Flag in Varchar2,
	     		Consume_Flag in Varchar2,
                        Success_Flag out NOCOPY Varchar2,
	     		More_Flag out NOCOPY Varchar2,
			Message_Wait_Timeout in number default Null,
			Blocking_Sleep_Time in number default 30) is

Not_Done 	boolean;
payload 	system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
dq_opts		DBMS_AQ.DEQUEUE_OPTIONS_T;
msg_props	DBMS_AQ.MESSAGE_PROPERTIES_T;
msgid		raw(16);


pragma AUTONOMOUS_TRANSACTION;

Begin
    payload := system.FND_CP_GSM_IPQ_AQ_PAYLOAD(NULL,NULL,NULL,NULL);

    Not_Done := TRUE;

    if (Consume_Flag = 'Y')  then
	dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE;
    else
	dq_opts.DEQUEUE_MODE := DBMS_AQ.BROWSE;
    end if;

    dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
    dq_opts.VISIBILITY := DBMS_AQ.IMMEDIATE;

    if (Message_Wait_Timeout is null) then
    	dq_opts.WAIT := DBMS_AQ.NO_WAIT;
    else
	dq_opts.WAIT := Message_Wait_Timeout;
    end if;

    dq_opts.MSGID := NULL;
    dq_opts.consumer_name := 'FNDCPGSMIPC_Service_'||to_char(Handle);

    while (Not_Done) LOOP
        begin
	   DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
                    MSGID => msgid);
	exception
		when others then payload.Message:= null;
        end;

       Parameters := payload.Payload;
       Message := payload.Message;
       Debug_Level := payload.Debug_Level;

       if (Message is null) then
          Success_Flag := 'N';
       else
	  Success_Flag := 'Y';
       end if;

       if (Blocking_Flag = 'N') or (Success_Flag = 'Y') then
	  Not_Done := FALSE;
       else
          dbms_lock.sleep(Blocking_Sleep_Time);
       end if;

    END LOOP;

    /* set more flag */

    dq_opts.DEQUEUE_MODE := DBMS_AQ.BROWSE;
    dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
    dq_opts.VISIBILITY := DBMS_AQ.IMMEDIATE;
    dq_opts.WAIT := DBMS_AQ.NO_WAIT;

    begin
       DBMS_AQ.DEQUEUE(QUEUE_NAME=>Q_Schema||'.FND_CP_GSM_IPC_AQ',
                    DEQUEUE_OPTIONS => dq_opts,
                    MESSAGE_PROPERTIES => msg_props,
                    PAYLOAD => payload,
                    MSGID => msgid);
    exception
		when others then payload.Message:= null;
    end;

    if payload.Message is null then
	more_flag := 'N';
    else
	more_flag := 'Y';
    end if;

    commit;

exception
    when OTHERS then
                rollback;
		raise;
End;

/* Messages */

Function MSG_Stop return varchar2 is begin return('Stop'); end;
Function MSG_Suspend return varchar2 is begin return('Suspend'); end;
Function MSG_Resume return varchar2 is begin return('Resume'); end;
Function MSG_Verify return varchar2 is begin return('Verify'); end;
Function MSG_Custom return varchar2 is begin return('Custom'); end;

/*--------------------------------------------------------------------------
        Procedure Update_Status:

	Handle = CPID
        Status is one of: Running, Stopped, Suspended,
					Uninitialized (for FND Use only)
-----------------------------------------------------------------------------*/

Procedure Update_Status ( Handle in Number,
                        Status in Varchar2) is

  Status_Code varchar2(1);

pragma AUTONOMOUS_TRANSACTION;

  Begin
     if (UPPER(Status) = 'UNINITIALIZED') then
	Status_Code := 'Z';
     elsif (UPPER(Status) = 'SUSPENDED') then
        Status_Code := 'P';
     elsif (UPPER(Status) = 'RUNNING') then
        Status_Code := 'A';
     elsif (UPPER(Status) = 'STOPPED') then
        Status_Code := 'S';
     else 		-- No Perfect answer, best to assume its Running
        Status_Code := 'A';
     end if;

    Update FND_CONCURRENT_PROCESSES
	Set GSM_INTERNAL_STATUS = Status_Code
	where CONCURRENT_PROCESS_ID = Handle;

     commit;

  exception
      when OTHERS then
                  rollback;
		  raise;
  end;

/*--------------------------------------------------------------------------
        Procedure Update_Status_and_Info:

	Handle = CPID
        Status is one of: Running, Stopped, Suspended,
					Uninitialized (for FND Use only)
	Info is for service developer use.
-----------------------------------------------------------------------------*/

Procedure Update_Status_and_Info ( Handle in Number,
                        Status in Varchar2,
			Info in Varchar2) is

  Status_Code varchar2(1);

pragma AUTONOMOUS_TRANSACTION;

  Begin
     if (UPPER(Status) = 'UNINITIALIZED') then
	Status_Code := 'Z';
     elsif (UPPER(Status) = 'SUSPENDED') then
        Status_Code := 'P';
     elsif (UPPER(Status) = 'RUNNING') then
        Status_Code := 'A';
     elsif (UPPER(Status) = 'STOPPED') then
        Status_Code := 'S';
     else 		-- No Perfect answer, best to assume its Running
        Status_Code := 'A';
     end if;

    Update FND_CONCURRENT_PROCESSES
	Set GSM_INTERNAL_STATUS = Status_Code,
	GSM_INTERNAL_INFO = Info
	where CONCURRENT_PROCESS_ID = Handle;

     commit;

  exception
      when OTHERS then
                  rollback;
		  raise;
  end;

/* No longer used */
Procedure obsolete_Update_Status ( Handle in Number,
                        Status in Varchar2) is

  msg_props		dbms_aq.message_properties_t;
  enq_opts		dbms_aq.enqueue_options_t;
  msg			system.FND_CP_GSM_IPQ_AQ_PAYLOAD;
  msg_id		raw(16);

pragma AUTONOMOUS_TRANSACTION;

  Begin
    msg := system.FND_CP_GSM_IPQ_AQ_PAYLOAD(Handle, Status, NULL, NULL);

    enq_opts.visibility := DBMS_AQ.IMMEDIATE;
    enq_opts.sequence_deviation := NULL;

    msg_props.delay := DBMS_AQ.NO_DELAY;
    msg_props.expiration := 365 * 24 * 3600;        -- One Year
    msg_props.recipient_list(1) :=sys.aq$_agent(
		'FNDCPGSMIPC_Cartridge_'||to_char(Handle),NULL,NULL);
    msg_props.sender_id := sys.aq$_agent(
		'FNDCPGSMIPC_Service_'||to_char(Handle), NULL, NULL);

    DBMS_AQ.Enqueue(    queue_name         => Q_Schema||'.FND_CP_GSM_IPC_AQ',
                        enqueue_options    => enq_opts,
                        message_properties => msg_props,
                        Payload            => msg,
                        msgid              => msg_id);


    Commit;

  exception
      when OTHERS then
                  rollback;
  End;

/* Statuses */

Function Status_Running return varchar2 is begin return('Running'); end;
Function Status_Stopped return varchar2 is begin return('Stopped'); end;
Function Status_Suspended return varchar2 is begin return('Suspended'); end;

END fnd_cp_gsm_ipc;

/
