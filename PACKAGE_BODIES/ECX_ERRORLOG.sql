--------------------------------------------------------
--  DDL for Package Body ECX_ERRORLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_ERRORLOG" as
-- $Header: ECXERRB.pls 120.4 2006/07/21 16:27:08 gsingh ship $

cursor c_ecx_errorno
is
select	ecx_error_no_s.nextval
from	dual;
l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

procedure outbound_engine
	(
	i_trigger_id		IN	number,
	i_status		IN	varchar2,
	i_errmsg		IN	varchar2,
	i_outmsgid		IN	RAW,
        i_errparams             IN      varchar2 ,
        i_party_type            IN      varchar2
	)
is
i_error_no	pls_integer;
PRAGMA 		AUTONOMOUS_TRANSACTION;
begin
if i_trigger_id is null
then
	return;
end if;

if i_errmsg is not null
then
	open 	c_ecx_errorno;
	fetch 	c_ecx_errorno into i_error_no;
	close 	c_ecx_errorno;
end if;
        update ecx_outbound_logs
        set     status=i_status,
                out_msgid = i_outmsgid,
                error_id = i_error_no,
                logfile = ecx_utils.g_logfile,
                time_stamp = sysdate,
                party_type = decode(i_party_type,null,party_type,i_party_type)
         where  trigger_id=i_trigger_id;

if i_errmsg is not null
then
        insert into ecx_msg_logs
                (
                  log_id,
                  trigger_id,
                  error_id
                )
        values
                (
                  ecx_msg_logs_s.NEXTVAL,
                  i_trigger_id,
                  i_error_no
                );

        insert into ecx_error_msgs
                (
                error_id,
                message,
                message_parameters
                )
        values  (
                i_error_no,
                i_errmsg,
                nvl(i_errparams, ecx_utils.i_errparams)
                );
        ecx_utils.i_curr_errid := i_error_no;

end if;

/**
Commit for the Autonomous transaction.
**/
commit;
exception
when others then
	rollback;
	raise;
end outbound_engine;

procedure inbound_engine
	(
	i_process_id		IN	RAW,
	i_status		IN	varchar2,
	i_errmsg		IN	varchar2,
        i_errparams             IN      varchar2
	)
is
i_error_no	pls_integer;
i_trigger_id    number;

cursor get_curr_trigger_id(p_process_id raw)
is
select trigger_id
  from ecx_inbound_logs
 where process_id = p_process_id;

PRAGMA 		AUTONOMOUS_TRANSACTION;
begin
if i_process_id is null
then
	return;
end if;

if i_errmsg is not null
then
	open 	c_ecx_errorno;
	fetch 	c_ecx_errorno into i_error_no;
	close 	c_ecx_errorno;
end if;

	update	ecx_inbound_logs
	set	status = i_status,
		error_id = i_error_no,
                logfile = ecx_utils.g_logfile,
		time_stamp = sysdate
	where	process_id = i_process_id;

        for c_curr_trigger_id in get_curr_trigger_id(i_process_id)
        loop
          i_trigger_id := c_curr_trigger_id.trigger_id;
        end loop;

if i_errmsg is not null
then
         insert into ecx_msg_logs
                (
                  log_id,
                  trigger_id,
                  error_id
                )
        values
                (
                  ecx_msg_logs_s.NEXTVAL,
                  i_trigger_id,
                  i_error_no
                );

	insert into ecx_error_msgs
		(
		error_id,
		message,
                message_parameters
		)
	values	(
		i_error_no,
		i_errmsg,
                nvl(i_errparams, ecx_utils.i_errparams)
		);
        ecx_utils.i_curr_errid := i_error_no;
end if;
/**
Commit for the Autonomous transaction.
**/
commit;

exception
when others then
	rollback;
	raise;
end inbound_engine;

procedure external_system
        (
        i_outmsgid              IN      RAW,
        i_status                IN      pls_integer,
        i_errmsg                IN      varchar2,
        i_timestamp             IN      date,
        o_ret_code              OUT     NOCOPY pls_integer,
        o_ret_msg               OUT     NOCOPY varchar2,
        i_errparams             IN      varchar2
        )
is
i_error_no      pls_integer;
i_trigger_id    number;

i_params               wf_parameter_list_t;
i_event_name           varchar2(240);
i_event_key            varchar2(240);
i_item_type            varchar2(8);
i_item_key             varchar2(240);
i_transaction_type     varchar2(100);
i_transaction_subtype  varchar2(100);
i_party_type           varchar2(30);
i_party_id             varchar2(100);
i_party_site_id        varchar2(100);
i_msgid                raw(16);
i_message_type         varchar2(100);
i_message_standard     varchar2(100);
i_document_number      varchar2(256);
i_protocol_type        varchar2(500);
i_protocol_address     varchar2(2000);
i_username             varchar2(500);
i_attribute1           varchar2(500);
i_attribute2           varchar2(500);
i_attribute3           varchar2(500);
i_attribute4           varchar2(500);
i_attribute5           varchar2(500);
i_block_mode           varchar2(1);
i_activity_id          number;
i_admin_email          ecx_tp_headers.company_admin_email%type;
i_sysdate              date;
i_command              Varchar2(10);
i_text_val             varchar2(2000);
i_err_code             varchar2(100);
i_num_val              number;
i_date                 date;
i_error_type           varchar2(10);
i_random_value         number;
debug_mode             number := 0;
cnt                    number;
i_message_id           raw(16);

cursor c_trigger_id
is
select ecx_trigger_id_s.NEXTVAL
  from dual;

PRAGMA          AUTONOMOUS_TRANSACTION;
i_method_name   varchar2(2000) := 'ecx_errorlog.external_system';

begin

--- Sets the Log Directory in both Standalone and the Embedded mode
ecx_utils.getLogDirectory;
ecx_debug.enable_debug_new(debug_mode, ecx_utils.g_logdir, 'otacb_'||i_outmsgid||'.log', 'otacb_'||i_outmsgid||'.log');

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if i_outmsgid is null
then
        o_ret_code :=1;
        o_ret_msg := 'Message Id is null';
        return;
end if;

open  c_trigger_id;
fetch c_trigger_id into i_trigger_id;
close c_trigger_id;

if i_errmsg is not null
then
        open c_ecx_errorno;
        fetch c_ecx_errorno into i_error_no;
        close c_ecx_errorno;
end if;
        insert into ecx_external_logs
                (
                external_process_id,
                out_msgid,
                status,
                error_id,
                time_stamp
                )
        values
                (
                i_trigger_id,
                i_outmsgid,
                i_status,
                i_error_no,
                i_timestamp
                );

if i_errmsg is not null
then
        insert into ecx_msg_logs
                (
                  log_id,
                  trigger_id,
                  error_id
                )
        values
                (
                  ecx_msg_logs_s.NEXTVAL,
                  i_trigger_id,
                  i_error_no
                );

        insert into ecx_error_msgs
                (
                error_id,
                message,
                message_parameters
                )
        values  (
                i_error_no,
                i_errmsg,
                nvl(i_errparams, ecx_utils.i_errparams)
                );
        ecx_utils.i_curr_errid := i_error_no;
end if;
/* Start of Bug #2167164 */
BEGIN
  update ecx_external_retry set status= i_status,time_stamp = i_timestamp,error_id=i_error_no where retry_msgid=i_outmsgid;
  If sql%notfound then
          NULL;
  end if;
END;
/* End of Bug 2167164 */

/** Begin of the Bug 1999883 Callback to Workflow Routine   **/
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'ecx_errorlog.external_system- callback to Workflow Code',
               i_method_name);
  ecx_debug.log(l_statement,'i_outmsgid',i_outmsgid,i_method_name);
end if;

Begin
   Select count(*)
   into cnt
   from ecx_doclogs
   where msgid = i_outmsgid;
Exception
When others then
 Null;
End;

if cnt = 0 then
  -- since the msgid is not in ecx_doclogs it is possible that this was a resend of the
  -- original msgid. So, check if it exists in ecx_external_retry and get the original
  -- msgid
  begin
    select msgid
    into   i_message_id
    from   ecx_external_retry
    where  retry_msgid = i_outmsgid;
  exception
  when no_data_found then
    null;
  when others then
    raise;
  end;
else
  -- msgid found in ecx_doclogs
  i_message_id := i_outmsgid;
end if;

if (i_message_id is not null) then

  Begin
    select  cb_event_name, cb_event_key, block_mode,
            msgid,message_type,message_standard,
            transaction_type, transaction_subtype,
            msgid, message_type, message_standard,
            document_number,protocol_type,protocol_address,
            username,attribute1, attribute2,
            attribute3, attribute4, attribute5,
            party_type, partyid, party_site_id,
            item_type, item_key, activity_id
     into   i_event_name, i_event_key, i_block_mode,
            i_msgid,i_message_type,i_message_standard,
            i_transaction_type, i_transaction_subtype,
            i_msgid, i_message_type, i_message_standard,
            i_document_number,i_protocol_type,i_protocol_address,
            i_username,i_attribute1, i_attribute2,
            i_attribute3, i_attribute4, i_attribute5,
            i_party_type, i_party_id, i_party_site_id,
            i_item_type, i_item_key, i_activity_id
    from    ecx_doclogs
    where   msgid = i_message_id;
  exception
  when others then
       raise;
  end;

  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_event_name',i_event_name,i_method_name);
    ecx_debug.log(l_statement,'i_event_key',i_event_key,i_method_name);
    ecx_debug.log(l_statement,'i_block_mode',i_block_mode,i_method_name);
    ecx_debug.log(l_statement,'i_transaction_type',i_transaction_type,i_method_name);
    ecx_debug.log(l_statement,'i_transaction_subtype',i_transaction_subtype,i_method_name);
    ecx_debug.log(l_statement,'i_party_site_id',i_party_site_id,i_method_name);
    ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
    ecx_debug.log(l_statement,'i_message_type',i_message_type,i_method_name);
    ecx_debug.log(l_statement,'i_message_standard',i_message_standard,i_method_name);
    ecx_debug.log(l_statement,'i_document_number',i_document_number,i_method_name);
    ecx_debug.log(l_statement,'i_protocol_type',i_protocol_Type,i_method_name);
    ecx_debug.log(l_statement,'i_protocol_address',i_protocol_address,i_method_name);
    ecx_debug.log(l_statement,'i_username',i_username,i_method_name);
    ecx_debug.log(l_statement,'i_attribute1',i_attribute1,i_method_name);
    ecx_debug.log(l_statement,'i_attribute2',i_attribute2,i_method_name);
    ecx_debug.log(l_statement,'i_attribute3',i_attribute3,i_method_name);
    ecx_debug.log(l_statement,'i_attribute4',i_attribute4,i_method_name);
    ecx_debug.log(l_statement,'i_attribute5',i_attribute5,i_method_name);
  end if;

  i_err_code := i_errmsg;
  i_text_val := ecx_debug.getMessage(i_errmsg);
  i_num_val :=  i_status;

---- Raise a custom Event

  if (i_event_name is not null)
    then

     i_params := wf_parameter_list_t();
     wf_event.addParameterToList(p_name          => 'ECX_PARTY_TYPE',
                                p_value          => i_party_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PARTY_ID',
                                p_value         => i_party_id,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PARTY_SITE_ID',
                                p_value         => i_party_site_id,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_TRANSACTION_TYPE',
                                p_value         => i_transaction_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_TRANSACTION_SUBTYPE',
                                p_value         => i_transaction_subtype,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_MESSAGE_TYPE',
                                p_value         => i_message_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_MESSAGE_STANDARD',
                                p_value         => i_message_standard,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_DOCUMENT_ID',
                                p_value         => i_document_number,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PROTOCOL_TYPE',
                                p_value         => i_protocol_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PROTOCOL_ADDRESS',
                                p_value         => i_protocol_address,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_USERNAME',
                                p_value         => i_username,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_MSGID',
                                 p_value          => i_message_id,
                                 p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE1',
                                p_value         => i_attribute1,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE2',
                                p_value         => i_attribute2,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE3',
                                p_value         => i_attribute3,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE4',
                                p_value         => i_attribute4,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE5',
                                p_value         => i_attribute5,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name         => 'ECX_ERROR_MSG',
                                 p_value         => i_text_val,
                                 p_parameterlist => i_params);
     wf_event.addParameterToList(p_name         => 'ECX_RETURN_CODE',
                                 p_value         => i_status,
                                 p_parameterlist => i_params);
     wf_event.addParameterToList(p_name         => 'ECX_ERR_PARAMS',
                                 p_value         => i_errparams,
                                 p_parameterlist => i_params);


     if(l_statementEnabled) then
       ecx_debug.log(l_statement,'Raising the Customized event', i_event_name,
                    i_method_name);
     end if;
     i_random_value := wf_core.random;
     i_event_key := i_event_key||i_random_value;
     wf_event.raise(i_event_name, i_event_key, null, i_params);

  end if;

  if (i_block_mode = 'Y')
    then
      if (i_status = 0) then
      i_command := 'COMPLETE';
    else
      i_command := 'ERROR';
    end if;

    wf_core.error_name := i_command;
    wf_core.error_message := i_text_val;

    if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_command',i_command,i_method_name);
     ecx_debug.log(l_statement,'i_errmsg',i_errmsg,i_method_name);
     ecx_debug.log(l_statement,'i_status',i_status,i_method_name);
     ecx_debug.log(l_statement,'i_text_val',i_text_val,i_method_name);
     ecx_debug.log(l_statement,'i_num_val',i_num_val,i_method_name);
     ecx_debug.log(l_statement,'i_item_type',i_item_type,i_method_name);
     ecx_debug.log(l_statement,'i_item_key',i_item_key,i_method_name);
     ecx_debug.log(l_statement,'i_activity_id',i_activity_id,i_method_name);
    end if;

    wf_engine.CB(command       => i_command,
                 context       => i_item_type || ':' || i_item_key ||
                                 ':' || i_activity_id,
                 text_value    => i_err_code,
                 number_value  => i_num_val,
                 date_value    => i_date);

    if(l_statementEnabled) then
      ecx_debug.log(l_statement,'wf error_name',wf_core.error_name,
                   i_method_name);
      ecx_debug.log(l_statement,'wf error_message',wf_core.error_message,
                   i_method_name);
      ecx_debug.log(l_statement,'ecx_errorlog.external_system Callback DONE         ',
                   i_method_name);
    end if;
  else
    if(l_statementEnabled) then
      ecx_debug.log(l_statement,'ecx_errorlog.external_system-testing non block mode',
                   i_method_name);
      ecx_debug.log(l_statement,'ecx_errorlog.external_system-i_status',
                   i_status,i_method_name);
    end if;
    if (i_status <> 0)
    then
      i_params := wf_parameter_list_t();
      wf_event.addParameterToList(p_name          => 'ECX_PARTY_TYPE',
                                 p_value          => i_party_type,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name          => 'ECX_PARTY_ID',
                                 p_value         => i_party_id,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name          => 'ECX_PARTY_SITE_ID',
                                 p_value         => i_party_site_id,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name          => 'ECX_TRANSACTION_TYPE',
                                 p_value         => i_transaction_type,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name          => 'ECX_TRANSACTION_SUBTYPE',
                                 p_value         => i_transaction_subtype,
                                 p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_MESSAGE_TYPE',
                                p_value         => i_message_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_MESSAGE_STANDARD',
                                p_value         => i_message_standard,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_DOCUMENT_ID',
                                p_value         => i_document_number,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PROTOCOL_TYPE',
                                p_value         => i_protocol_type,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_PROTOCOL_ADDRESS',
                                p_value         => i_protocol_address,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_USERNAME',
                                p_value         => i_username,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE1',
                                p_value         => i_attribute1,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE2',
                                p_value         => i_attribute2,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE3',
                                p_value         => i_attribute3,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE4',
                                p_value         => i_attribute4,
                                p_parameterlist => i_params);
     wf_event.addParameterToList(p_name          => 'ECX_ATTRIBUTE5',
                                p_value         => i_attribute5,
                                p_parameterlist => i_params);
      wf_event.addParameterToList(p_name          => 'ECX_MSGID',
                                 p_value          => i_message_id,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name         => 'ECX_ERROR_MSG',
                                 p_value         => i_text_val,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name         => 'ECX_RETURN_CODE',
                                 p_value         => i_status,
                                 p_parameterlist => i_params);
      wf_event.addParameterToList(p_name         => 'ECX_ERR_PARAMS',
                                 p_value         => i_errparams,
                                 p_parameterlist => i_params);
      -- set the error type
      If (i_status <> 0)
      then
         i_error_type := 30; /*** Notify System Administrator  ***/
      ---   ECX_Trading_Partner_PVT.get_sysadmin_email(i_admin_email,o_ret_code,o_ret_msg);
      end if;

   wf_event.addParameterToList(p_name      =>   'ECX_ERROR_TYPE',
                               p_value     =>   i_error_Type,
                               p_parameterlist => i_params);

   wf_event.addParameterToList(p_name      =>  'ECX_SA_ROLE',
                               p_value      =>   'ECX_SA',
                               p_parameterlist  =>   i_params);

    if(l_statementEnabled) then
      ecx_debug.log(l_statement,'Raising the event - oracle.apps.ecx.processing.message.callback',
                   i_method_name);
    end if;
    wf_event.raise('oracle.apps.ecx.processing.message.callback',
                   i_transaction_type|| '-' || i_transaction_subtype || '-' ||
                   i_party_site_id || '-' || i_error_no,
                  null,
                  i_params
                 );
    if(l_statementEnabled) then
      ecx_debug.log(l_statement,'i_message_id', i_message_id,i_method_name);
    end if;
    end if;
  end if;
end if;

/** End of the Bug 1999883 Callback to Workflow Routine   **/

o_ret_code      :=0;
o_ret_msg       := 'Message Successfully recorded';

/**
Commit for the Autonomous transaction.
**/
commit;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
ecx_debug.print_log;
ecx_debug.disable_debug;

exception
when dup_val_on_index then
        o_ret_code := ecx_util_api.g_dup_error;
        o_ret_msg := SQLERRM;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
        ecx_debug.print_log;
        ecx_debug.disable_debug;
when others then
        rollback;
        o_ret_code :=2;
        o_ret_msg := SQLERRM||' - ECT_ERRLOG.EXTERNAL_SYSTEM';
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
        ecx_debug.print_log;
        ecx_debug.disable_debug;
end external_system;

procedure send_error
	(
	i_ret_code		IN	pls_integer,
	i_errbuf		IN	varchar2,
	i_snd_tp_id		IN	varchar2,
	i_document_number	IN	varchar2,
	i_transaction_type	IN	varchar2,
	o_ret_code 		OUT	NOCOPY pls_integer,
	o_ret_msg		OUT	NOCOPY varchar2
	)
is
p_event                 wf_event_t;
x_from_agt              wf_agent_t := wf_agent_t(null, null);
m_transaction_subtype   varchar2(250);
m_party_id              number;         /* Bug 2122579 */
m_party_site_id         number;         /* Bug 2122579 */
m_org_id                pls_integer;
m_admin_email           varchar2(256);
retcode                 pls_integer;
retmsg                  varchar2(2000);
i_sysdate               date;
i_error_no              number(15);

cursor c1
is
select sysdate from dual;

begin

/* Since ret_code tells us whether there was an error,
   return back to the calling program if it is null */

if (i_ret_code is null) or (i_ret_code = 0)
then
   return;
elsif (i_ret_code = 1)
then
   ecx_utils.error_type := 20;
elsif (i_ret_code = 2)
then
   ecx_utils.error_type := 30;
end if;

open c1;
fetch c1 into i_sysdate;
close c1;

if ( ecx_utils.g_direction = 'IN' ) and (ecx_utils.error_type = 20)
then
    ecx_trading_partner_pvt.get_senders_tp_info
                        (
                        p_party_id => m_party_id,
                        p_party_site_id => m_party_site_id,
                        p_org_id => m_org_id,
                        p_admin_email => m_admin_email,
                        retcode => retcode,
                        retmsg => retmsg
                        );
elsif ( ecx_utils.g_direction = 'OUT' ) and (ecx_utils.error_type = 20)
then
     ecx_trading_partner_pvt.get_receivers_tp_info
                        (
                        p_party_id => m_party_id,
                        p_party_site_id => m_party_site_id,
                        p_org_id => m_org_id,
                        p_admin_email => m_admin_email,
                        retcode => retcode,
                        retmsg => retmsg
                        );

end if;

open    c_ecx_errorno;
fetch   c_ecx_errorno into i_error_no;
close   c_ecx_errorno;

wf_event_t.initialize(p_event);
x_from_agt := null;
p_event.setEventName('oracle.apps.ecx.processing.notification.send');
p_event.setEventKey(i_transaction_type|| '-' || m_transaction_subtype || '-' || m_party_site_id || '-' || i_error_no);
p_event.setFromAgent(x_from_agt);
p_event.setSendDate(i_sysdate);

p_event.addParameterToList('ECX_RETURN_CODE', i_ret_code);
p_event.addParameterToList('ECX_ERROR_MSG',i_errbuf);
p_event.addParameterToList('ECX_ERROR_TYPE',ecx_utils.error_type);
p_event.addParameterToList('ECX_PARTY_ID', m_party_id);
p_event.addParameterToList('ECX_PARTY_SITE_ID', m_party_site_id);
p_event.addParameterToList('ECX_TRANSACTION_TYPE', ecx_utils.g_transaction_type);
p_event.addParameterToList('ECX_TRANSACTION_SUBTYPE',ecx_utils.g_transaction_subtype);
p_event.addParameterToList('ECX_PARTY_ADMIN_EMAIL',m_admin_email);

wf_event.raise(p_event.getEventName(),
               p_event.getEventKey(),
               null,
               p_event.getParameterList()
              );

o_ret_code :=0;
o_ret_msg := 'SUCCESS';
exception
when others then
	o_ret_code :=2;
	o_ret_msg :=SQLERRM || ' at ECX_ERRORLOG.SEND_ERROR';
end send_error;

procedure send_msg_api
        (
        x_retcode               OUT     NOCOPY pls_integer,
        x_retmsg                OUT     NOCOPY varchar2,
        p_retcode               IN      pls_integer,
        p_errbuf                IN      varchar2,
        p_error_type            IN      pls_integer ,
        p_party_id              IN      varchar2,
        p_party_site_id         IN      varchar2,
        p_transaction_type      IN      varchar2,
        p_transaction_subtype   IN      varchar2,
        p_party_type            IN      varchar2 ,
        p_document_number       IN      varchar2
        )
is
cursor c1
is
select sysdate from dual;

cursor c_party_type(i_transaction_type in varchar2, i_transaction_subtype in varchar2)
is
select party_type
  from ecx_transactions
 where transaction_type = i_transaction_type
   and transaction_subtype = i_transaction_subtype;

p_event         wf_event_t;
x_from_agt      wf_agent_t := wf_agent_t(null, null);

i_admin_email   ecx_tp_headers.company_admin_email%type;
i_party_type    ecx_tp_headers.party_type%type;
i_error_no      pls_integer;
i_sysdate       date;
i_c_dt          date;
i_c_by          pls_integer;
i_l_by          pls_integer;
i_l_dt          date;
i_tp_hdr_id     number;

begin

ecx_utils.error_type := p_error_type;
ecx_utils.g_transaction_type := p_transaction_type;
ecx_utils.g_transaction_subtype := p_transaction_subtype;

open c1;
fetch c1 into i_sysdate;
close c1;

if p_party_type is null
then
    for party_type_rec in c_party_type(p_transaction_type, p_transaction_subtype) loop
      i_party_type := party_type_rec.party_type;
    end loop;
elsif NOT(ecx_util_api.validate_party_type(p_party_type)) then
    x_retmsg := ecx_debug.getTranslatedMessage('ECX_INVALID_PARTY_TYPE',
                                   'p_party_type',p_party_type);
    x_retcode := 2;
end if;

if ecx_utils.error_type = 20
then
    ecx_tp_api.retrieve_trading_partner(
               x_return_status         => x_retcode,
               x_msg                   => x_retmsg,
               x_tp_header_id          => i_tp_hdr_id,
               p_party_type            => p_party_type,
               p_party_id              => p_party_id,
               p_party_site_id         => p_party_site_id,
               x_company_admin_email   => i_admin_email,
               x_created_by            => i_c_by,
               x_creation_date         => i_c_dt,
               x_last_updated_by       => i_l_by,
               x_last_update_date      => i_l_dt);

end if;

open    c_ecx_errorno;
fetch   c_ecx_errorno into i_error_no;
close   c_ecx_errorno;

wf_event_t.initialize(p_event);
x_from_agt := null;
p_event.setEventName('oracle.apps.ecx.processing.notification.send');
p_event.setEventKey(p_transaction_type|| '-' || p_transaction_subtype || '-' || p_party_site_id || '-' || i_error_no);
p_event.setFromAgent(x_from_agt);
p_event.setSendDate(i_sysdate);

p_event.addParameterToList('ECX_RETURN_CODE', p_retcode);
p_event.addParameterToList('ECX_ERROR_MSG',p_errbuf);
p_event.addParameterToList('ECX_ERROR_TYPE',ecx_utils.error_type);
p_event.addParameterToList('ECX_PARTY_ID', p_party_id);
p_event.addParameterToList('ECX_PARTY_SITE_ID', p_party_site_id);
p_event.addParameterToList('ECX_TRANSACTION_TYPE', p_transaction_type);
p_event.addParameterToList('ECX_TRANSACTION_SUBTYPE',p_transaction_subtype);
p_event.addParameterToList('ECX_PARTY_ADMIN_EMAIL',i_admin_email);


wf_event.raise(p_event.getEventName(),
               p_event.getEventKey(),
               null,
               p_event.getParameterList()
              );

x_retcode := ecx_util_api.g_no_error;
x_retmsg := 'SUCCESS';
exception
when others then
        x_retcode := ecx_util_api.g_unexp_error;
        x_retmsg := SQLERRM || ' at ECX_ERRORLOG.SEND_ERROR_API';
end send_msg_api;

procedure inbound_trigger
	(
        i_trigger_id    IN      number,
	i_msgid		IN	raw,
	i_process_id	IN	raw,
        i_status        IN      varchar2,
	i_errmsg	IN	varchar2,
        i_errparams     IN      varchar2
	)
is
i_error_no	pls_integer;
PRAGMA 		AUTONOMOUS_TRANSACTION;
begin

if i_trigger_id is null or i_msgid is null
then
	return;
end if;

if i_errmsg is not null
then
	open 	c_ecx_errorno;
	fetch 	c_ecx_errorno into i_error_no;
	close 	c_ecx_errorno;
end if;

     begin
	insert into ecx_inbound_logs
	(
	trigger_id,
	process_id,
        error_id,
	msgid,
        status,
	time_stamp
	)
	values
	(
        i_trigger_id,
	i_process_id,
        i_error_no,
	i_msgid,
        i_status,
	sysdate
	);
    exception
      /** Requires unique index on trigger_id **/
      when dup_val_on_index then
        update ecx_inbound_logs
           set process_id = i_process_id,
               msgid = i_msgid,
               error_id = i_error_no,
               status = i_status,
               time_stamp = sysdate
         where trigger_id = i_trigger_id;
    end;

if i_errmsg is not null
then
        insert into ecx_msg_logs
                (
                  log_id,
                  trigger_id,
                  error_id
                )
        values
                (
                  ecx_msg_logs_s.NEXTVAL,
                  i_trigger_id,
                  i_error_no
                );
	insert into ecx_error_msgs
		(
		error_id,
		message,
                message_parameters
		)
	values	(
		i_error_no,
		i_errmsg,
                nvl(i_errparams, ecx_utils.i_errparams)
		);
        ecx_utils.i_curr_errid := i_error_no;
end if;

/**
Commit for the Autonomous transaction.
**/
commit;
exception
when others then
	rollback;
	raise;
end inbound_trigger;

procedure outbound_trigger
	(
	i_trigger_id		IN	number,
	i_transaction_type	IN	varchar2,
        i_transaction_subtype   IN      varchar2,
        i_party_id              IN      number,
        i_party_site_id         IN      varchar2,
        i_party_type            IN      varchar2 , -- 2183619
	i_document_number	IN	varchar2,
        i_status                IN      varchar2,
        i_errmsg                IN      varchar2,
        i_errparams             IN      varchar2
	)
is
i_error_no      number(15);
PRAGMA 		AUTONOMOUS_TRANSACTION;
l_document_number varchar2(2000);

begin
if i_trigger_id is null
then
    return;
end if;

if i_errmsg is not null
then
        open    c_ecx_errorno;
        fetch   c_ecx_errorno into i_error_no;
        close   c_ecx_errorno;
end if;

-- bug 4224455
if i_document_number is null then
  l_document_number := i_trigger_id;
else
  l_document_number := i_document_number;
end if;
      begin
	insert into ecx_outbound_logs
	(
	trigger_id,
	transaction_type,
        transaction_subtype,
        party_id,
        party_site_id,
        party_type, --bug #2183619
	document_number,
        error_id,
        status,
	time_stamp
	)
	values
	(
	i_trigger_id,
	i_transaction_type,
        i_transaction_subtype,
        i_party_id,
        i_party_site_id,
        i_party_type, --bug #2183619
	l_document_number,
        i_error_no,
        i_status,
	sysdate
	);
    exception
      when dup_val_on_index then
       update  ecx_outbound_logs
          set  error_id = i_error_no,
               status   = i_status,
               time_stamp = sysdate
        where  trigger_id = i_trigger_id;
    end;

if i_errmsg is not null
then
        insert into ecx_msg_logs
                (
                  log_id,
                  trigger_id,
                  error_id
                )
        values
                (
                  ecx_msg_logs_s.NEXTVAL,
                  i_trigger_id,
                  i_error_no
                );

        insert into ecx_error_msgs
                (
                error_id,
                message,
                message_parameters
                )
        values  (
                i_error_no,
                i_errmsg,
                nvl(i_errparams, ecx_utils.i_errparams)
                );
        ecx_utils.i_curr_errid := i_error_no;
end if;

/**
Commit for the Autonomous transaction.
**/
commit;
exception
when others then
	rollback;
	raise;
end outbound_trigger;

procedure log_document
        (
        o_retcode              OUT    NOCOPY pls_integer,
        o_retmsg               OUT    NOCOPY varchar2,
        i_msgid                 IN    raw,
        i_message_type          IN    varchar2,
        i_message_standard      IN    varchar2,
        i_transaction_type      IN    varchar2,
        i_transaction_subtype   IN    varchar2,
        i_document_number       IN    varchar2,
        i_partyid               IN    varchar2,
        i_party_site_id         IN    varchar2,
        i_party_type            IN    varchar2,
        i_protocol_type         IN    varchar2,
        i_protocol_address      IN    varchar2,
        i_username              IN    varchar2,
        i_password              IN    varchar2,
        i_attribute1            IN    varchar2,
        i_attribute2            IN    varchar2,
        i_attribute3            IN    varchar2,
        i_attribute4            IN    varchar2,
        i_attribute5            IN    varchar2,
        i_payload               IN    clob,
        i_internal_control_num  IN    number,
        i_status                IN    varchar2  ,
        i_direction             IN    varchar2  ,
        i_outmsgid              IN    raw,
        i_logfile               IN    varchar2,
        i_item_type             IN    varchar2,
        i_item_key              IN    varchar2,
        i_activity_id           IN    varchar2,
        i_event_name            IN    varchar2,
        i_event_key             IN    varchar2,
        i_cb_event_name         IN    varchar2,
        i_cb_event_key          IN    varchar2,
        i_block_mode            IN    varchar2
       )
is

        l_party_type      Varchar2(30) := null;
        l_size            number;
        l_payload         clob;
        PRAGMA            AUTONOMOUS_TRANSACTION;

begin
        o_retcode := 0;
        l_size := dbms_lob.getlength(i_payload);
        dbms_lob.createtemporary(l_payload, TRUE, DBMS_LOB.SESSION);
        dbms_lob.copy(l_payload, i_payload, l_size);

         if NOT (ecx_util_api.validate_direction(i_direction)) then
            o_retcode := ecx_util_api.G_INVALID_PARAM;
            o_retmsg := 'ECX_INVALID_DIRECTION';
         end if;

         ecx_utils.convertPartyTypeToCode(i_party_type, l_party_type);

         insert into ecx_doclogs
         (
                msgid,
                message_type,
                message_standard,
                transaction_type,
                transaction_subtype,
                document_number,
                partyid,
                party_site_id,
                party_type,
                protocol_type,
                protocol_address,
                username,
                password,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                payload,
                internal_control_number,
                status,
                direction,
                time_stamp,
                out_msgid,
                logfile,
                item_type,
                item_key,
                activity_id,
                event_name,
                event_key,
                cb_event_name,
                cb_event_key,
                block_mode
          )
          values
         (
                i_msgid,
                i_message_type,
                i_message_standard,
                i_transaction_type,
                i_transaction_subtype,
                i_document_number,
                i_partyid,
                i_party_site_id,
                l_party_type,
                i_protocol_type,
                i_protocol_address,
                i_username,
                i_password,
                i_attribute1,
                i_attribute2,
                i_attribute3,
                i_attribute4,
                i_attribute5,
                l_payload,
                i_internal_control_num,
                i_status,
                i_direction,
                sysdate,
                i_outmsgid,
                i_logfile,
                i_item_type,
                i_item_key,
                i_activity_id,
                i_event_name,
                i_event_key,
                i_cb_event_name,
                i_cb_event_key,
                i_block_mode
          );

      /**
       Commit for the Autonomous transaction.
       **/
       commit;

exception
when dup_val_on_index then
    o_retcode := 1;
    o_retmsg := ecx_debug.getTranslatedMessage('ECX_DOCLOGS_EXISTS','p_msgid',i_msgid);
    ecx_debug.setErrorInfo(2, 30, 'ECX_DOCLOGS_EXISTS', 'p_msgid', i_msgid);

when others then
    o_retcode := 2;
    o_retmsg  := SQLERRM;
    ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_ERRORLOG.LOG_DOCUMENT');
end log_document;


procedure update_log_document
       (
        i_msgid       In   raw,
        i_outmsgid    In   raw,
        i_status      In   varchar2,
        i_logfile     In   varchar2,
        i_update_type In   varchar2
       )
is

begin
if i_update_type = 'STATUS'
then
  update ecx_doclogs
     set status = i_status,
         time_stamp = sysdate
   where msgid = i_msgid;
else
  update ecx_doclogs
     set status = i_status,
         logfile = i_logfile,
         out_msgid = i_outmsgid,
         time_stamp = sysdate
   where msgid = i_msgid;

end if;
exception
when others then
    raise;
end update_log_document;

procedure getDoclogDetails
       (
        i_msgid                    	in 	raw,
	i_message_type			OUT	NOCOPY varchar2,
	i_message_standard		OUT	NOCOPY varchar2,
        i_transaction_type        	OUT 	NOCOPY varchar2,
        i_transaction_subtype     	OUT 	NOCOPY varchar2,
	i_document_number		OUT	NOCOPY varchar2,
        i_party_id                	OUT 	NOCOPY varchar2,
        i_party_site_id           	OUT 	NOCOPY varchar2,
	i_protocol_type			OUT	NOCOPY varchar2,
	i_protocol_address		OUT	NOCOPY varchar2,
	i_username			OUT	NOCOPY varchar2,
	i_password			OUT	NOCOPY varchar2,
	i_attribute1			OUT	NOCOPY varchar2,
	i_attribute2			OUT	NOCOPY varchar2,
	i_attribute3			OUT	NOCOPY varchar2,
	i_attribute4			OUT	NOCOPY varchar2,
	i_attribute5			OUT	NOCOPY varchar2,
	i_logfile			OUT	NOCOPY varchar2,
        i_internal_control_number 	OUT 	NOCOPY number,
	i_status			OUT	NOCOPY varchar2,
	i_time_stamp			OUT	NOCOPY date,
	i_direction			OUT	NOCOPY varchar2,
	 /* Bug 2241292 */
        o_retcode                       OUT    NOCOPY pls_integer,
        o_retmsg                        OUT    NOCOPY varchar2

       )
is

cursor get_msg_attributes(p_msgid raw)
is
select 	1 msg_count,
        message_type,
	message_standard,
       	transaction_type,
       	transaction_subtype,
	document_number,
       	partyid,
       	party_site_id,
	protocol_type,
	protocol_address,
	username,
	password,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	logfile,
	internal_control_number,
	status,
	time_stamp,
	direction
  from ecx_doclogs
 where msgid = p_msgid;

i_msg_count number :=0;

begin
 o_retcode := 0; --Bug 2241292

    for c_msg_attributes in get_msg_attributes(i_msgid)
    loop
                i_msg_count                     := c_msg_attributes.msg_count;
		i_message_type 			:= c_msg_attributes.message_type;
		i_message_standard 		:= c_msg_attributes.message_standard;
          	i_transaction_type 		:= c_msg_attributes.transaction_type;
          	i_transaction_subtype 		:= c_msg_attributes.transaction_subtype;
          	i_document_number 		:= c_msg_attributes.document_number;
          	i_party_id 			:= c_msg_attributes.partyid;
          	i_party_site_id 		:= c_msg_attributes.party_site_id;
          	i_protocol_type 		:= c_msg_attributes.protocol_type;
          	i_protocol_address 		:= c_msg_attributes.protocol_address;
          	i_username 			:= c_msg_attributes.username;
          	i_password 			:= c_msg_attributes.password;
          	i_attribute1 			:= c_msg_attributes.attribute1;
          	i_attribute2 			:= c_msg_attributes.attribute2;
          	i_attribute3 			:= c_msg_attributes.attribute3;
          	i_attribute4 			:= c_msg_attributes.attribute4;
          	i_attribute5 			:= c_msg_attributes.attribute5;
          	i_logfile 			:= c_msg_attributes.logfile;
          	i_internal_control_number 	:= c_msg_attributes.internal_control_number;
          	i_status 			:= c_msg_attributes.status;
          	i_time_stamp 			:= c_msg_attributes.time_stamp;
          	i_direction 			:= c_msg_attributes.direction;
    end loop;

if (i_msg_count = 0) then
    raise no_data_found;
end if;

o_retmsg :=  'SUCCESS';
exception
when no_data_found then
   o_retcode := 2;
   o_retmsg := ecx_debug.getTranslatedMessage('ECX_DOCLOGS_NOT_EXISTS', 'p_msgid', i_msgid);
   ecx_utils.i_ret_code     := o_retcode;
   ecx_utils.i_errbuf       := o_retmsg;
when others then
   o_retcode := 2;
   o_retmsg  := SQLERRM;
   ecx_utils.i_ret_code     := o_retcode;
   ecx_utils.i_errbuf       := o_retmsg;

end getDoclogDetails;

procedure log_resend(
        o_retcode        OUT   NOCOPY pls_integer,
        o_retmsg         OUT   NOCOPY varchar2,
        i_resend_msgid    IN   raw,
        i_msgid           IN   raw,
        i_errmsg          IN   varchar2,
        i_status          IN   varchar2,
        i_timestamp       IN   date
)
is
i_error_no    pls_integer:= 0;
begin
        o_retcode := 0;
        o_retmsg := null;

 if(i_errmsg is not null) then
        open    c_ecx_errorno;
        fetch   c_ecx_errorno into i_error_no;
        close   c_ecx_errorno;
 end if;

        insert into ecx_external_retry
                (
                retry_msgid,
                msgid,
                status,
                error_id,
                time_stamp
                )
                values
                (
                i_resend_msgid,
                i_msgid,
                i_status,
                i_error_no,
                i_timestamp
                );

 if (i_errmsg is not null) then
         insert into ecx_error_msgs
                (
                error_id,
                message
                )
                values
                (
                i_error_no,
                i_errmsg
                );
 end if;
exception
 when dup_val_on_index then
   o_retcode := ecx_util_api.g_dup_error;
   o_retmsg := SQLERRM;
 when others then
   o_retcode := 2;
   o_retmsg  := SQLERRM;
end log_resend;


procedure get_event_params
                    (p_event               in wf_event_t,
                     x_message_type        out NOCOPY varchar2,
                     x_message_standard    out NOCOPY varchar2,
                     x_ext_type            out NOCOPY varchar2,
                     x_ext_subtype         out NOCOPY varchar2,
                     x_document_id         out NOCOPY varchar2,
                     x_logfile             out NOCOPY varchar2,
                     x_party_id            out NOCOPY varchar2,
                     x_party_type          out NOCOPY varchar2,
                     x_party_site_id       out NOCOPY varchar2,
                     x_protocol_type       out NOCOPY varchar2,
                     x_protocol_address    out NOCOPY varchar2,
                     x_username            out NOCOPY ecx_tp_details.username%TYPE,
                     x_password            out NOCOPY ecx_tp_details.password%TYPE,
                     x_attribute1          out NOCOPY varchar2,
                     x_attribute2          out NOCOPY varchar2,
                     x_attribute3          out NOCOPY varchar2,
                     x_attribute4          out NOCOPY varchar2,
                     x_attribute5          out NOCOPY varchar2,
                     x_direction           out NOCOPY varchar2,
                     x_trigger_id          out NOCOPY varchar2,
                     x_ecx_msgid           out NOCOPY raw,
                     x_item_type           out NOCOPY varchar2,
                     x_item_key            out NOCOPY varchar2,
                     x_activity_id         out NOCOPY varchar2,
                     x_cb_event_name       out NOCOPY varchar2,
                     x_cb_event_key        out NOCOPY varchar2,
                     x_block_mode          out NOCOPY varchar2,
                     x_int_type            out NOCOPY varchar2,
                     x_int_subtype         out NOCOPY varchar2,
                     x_int_party_site_id   out NOCOPY number,
                     x_resend              out NOCOPY boolean
                     )
is
  l_param_list          wf_parameter_list_t;
  l_param_name          varchar2(2000);
  l_param_value         varchar2(2000);
  l_module              varchar2(2000);

begin

  -- loop through the parameter list and get all the info for logging
  l_param_list := p_event.getParameterList();
  l_module := 'ecx.plsql.ecx_errorlog.get_event_params';
  if (l_param_list is null) then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
           'event object parameter list in empty');
     end if;
     return;
  else
    x_ecx_msgid := p_event.GetValueForParameter('ECX_MSG_ID');
    l_param_value := p_event.GetValueForParameter('RESEND');
    if l_param_value = 'Y' then
       x_resend := true;
       return;
    else
       x_resend := false;
    end if;

    for i in l_param_list.first..l_param_list.last loop
      l_param_name := l_param_list(i).GetName;
      l_param_value := l_param_list(i).GetValue;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
            l_param_name || ': ' || l_param_value);
      end if;

      if l_param_name = 'MESSAGE_TYPE' then
        x_message_type := l_param_value;

      elsif l_param_name = 'MESSAGE_STANDARD' then
        x_message_standard := l_param_value;

      elsif l_param_name = 'TRANSACTION_TYPE' then
        x_ext_type := l_param_value;

      elsif l_param_name = 'TRANSACTION_SUBTYPE' then
        x_ext_subtype := l_param_value;

      elsif l_param_name = 'DOCUMENT_NUMBER' then
        x_document_id := l_param_value;

      elsif l_param_name = 'PARTY_TYPE' then
        x_party_type := l_param_value;

      elsif l_param_name = 'PARTYID' then
        x_party_id := l_param_value;

      elsif l_param_name = 'PARTY_SITE_ID' then
        x_party_site_id := l_param_value;

      elsif l_param_name = 'PROTOCOL_TYPE' then
        x_protocol_type := l_param_value;

      elsif l_param_name = 'PROTOCOL_ADDRESS' then
        x_protocol_address := l_param_value;

      elsif l_param_name = 'USERNAME' then
        x_username := l_param_value;

      elsif l_param_name = 'PASSWORD' then
        x_password := l_param_value;

      elsif l_param_name = 'ATTRIBUTE1' then
        x_attribute1 := l_param_value;

      elsif l_param_name = 'ATTRIBUTE2' then
        x_attribute2 := l_param_value;

      elsif l_param_name = 'ATTRIBUTE3' then
        x_attribute3 := l_param_value;

      elsif l_param_name = 'ATTRIBUTE4' then
        x_attribute4 := l_param_value;

      elsif l_param_name = 'ATTRIBUTE5' then
        x_attribute5 := l_param_value;

      elsif l_param_name = 'DIRECTION' then
        x_direction:= l_param_value;

      elsif l_param_name = 'ITEM_TYPE' then
        x_item_type := l_param_value;

      elsif l_param_name = 'ITEM_KEY' then
        x_item_key := l_param_value;

      elsif l_param_name = 'ACTIVITY_ID' then
        x_activity_id := l_param_value;

      elsif l_param_name = '#CB_EVENT_NAME' then
        x_cb_event_name := l_param_value;

      elsif l_param_name = '#CB_EVENT_KEY' then
        x_cb_event_key := l_param_value;

      elsif l_param_name = '#BLOCK_MODE' then
        x_block_mode := l_param_value;

      elsif l_param_name = 'LOGFILE' then
        x_logfile := l_param_value;

      elsif l_param_name = 'TRIGGER_ID' then
        x_trigger_id := l_param_value;

      elsif l_param_name = 'INT_TRANSACTION_TYPE' then
        x_int_type := l_param_value;

      elsif l_param_name = 'INT_TRANSACTION_SUBTYPE' then
        x_int_subtype := l_param_value;

      elsif l_param_name = 'INT_PARTY_SITE_ID' then
        x_int_party_site_id := l_param_value;

      end if;
    end loop;
  end if;

exception
  when others then
    raise;
end;


procedure outbound_log (
  p_event    in  wf_event_t)

is

  l_out_msgid           raw(16);
  l_ecx_msgid           raw(16);
  l_message_type        varchar2(200);
  l_message_standard    varchar2(200);
  l_ext_type            varchar2(200);
  l_ext_subtype         varchar2(200);
  l_document_id         varchar2(200);
  l_retcode             pls_integer;
  l_retmsg              varchar2(200);
  l_logfile             varchar2(500);
  l_party_id            varchar2(200);
  l_party_type          varchar2(200);
  l_party_site_id       varchar2(200);
  l_protocol_type       varchar2(200);
  l_protocol_address   ecx_tp_details.protocol_address%TYPE;
  l_username            ecx_tp_details.username%TYPE;
  l_password            ecx_tp_details.password%TYPE;
  l_attribute1          varchar2(200);
  l_attribute2          varchar2(200);
  l_attribute3          varchar2(200);
  l_attribute4          varchar2(200);
  l_attribute5          varchar2(200);
  l_item_type           varchar2(200);
  l_item_key            varchar2(200);
  l_activity_id         varchar2(200);
  l_cb_event_name       varchar2(200);
  l_cb_event_key        varchar2(200);
  l_block_mode          varchar2(200);
  l_direction           varchar2(200);
  l_trigger_id          varchar2(200);

  -- internal transaction type and subtype for loging outbound passthrough
  l_tran_type           varchar2(200);
  l_tran_subtype        varchar2(200);
  l_int_party_site_id   number;

  l_resend              boolean := false;
  l_log_msg             varchar2(2000);
  l_passthr_trigger_id  varchar2(200);
  l_module              varchar2(2000);

  cursor c1
  is
  select  ecx_trigger_id_s.NEXTVAL
  from    dual;

begin
  if (p_event is null) then
    return;
  end if;

  if (wf_event.g_msgid is null) then
    return;
  else
    l_out_msgid := wf_event.g_msgid;
  end if;

  l_module := 'ecx.plsql.ecx_errorlog.outbound_log';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
       'outbound_log');
  end if;

  get_event_params(p_event              => p_event,
                   x_message_type       => l_message_type,
                   x_message_standard   => l_message_standard,
                   x_ext_type           => l_ext_type,
                   x_ext_subtype        => l_ext_subtype,
                   x_document_id        => l_document_id,
                   x_logfile            => l_logfile,
                   x_party_id           => l_party_id,
                   x_party_type         => l_party_type,
                   x_party_site_id      => l_party_site_id,
                   x_protocol_type      => l_protocol_type,
                   x_protocol_address   => l_protocol_address,
                   x_username           => l_username,
                   x_password           => l_password,
                   x_attribute1         => l_attribute1,
                   x_attribute2         => l_attribute2,
                   x_attribute3         => l_attribute3,
                   x_attribute4         => l_attribute4,
                   x_attribute5         => l_attribute5,
                   x_direction          => l_direction,
                   x_trigger_id         => l_trigger_id,
                   x_ecx_msgid          => l_ecx_msgid,
                   x_item_type          => l_item_type,
                   x_item_key           => l_item_key,
                   x_activity_id        => l_activity_id,
                   x_cb_event_name      => l_cb_event_name,
                   x_cb_event_key       => l_cb_event_key,
                   x_block_mode         => l_block_mode,
                   x_int_type           => l_tran_type,
                   x_int_subtype        => l_tran_subtype,
                   x_int_party_site_id  => l_int_party_site_id,
                   x_resend             => l_resend
                   );

  -- logging resend and doesn't need to log to ecx_doclogs and outbound_logs
  if l_resend then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'Logged resend for outbound.');
    end if;
    ecx_errorlog.log_resend (
                 o_retcode        => l_retcode,
                 o_retmsg         => l_retmsg,
                 i_resend_msgid   => l_out_msgid, -- RESEND ID
                 i_msgid          => l_ecx_msgid,
                 i_errmsg         => 'ECX_PENDING_AFTER_RESEND',
                 i_status         => '0',
                 i_timestamp      => sysdate
                 );
    ecx_attachment.map_attachments(p_event, l_out_msgid);
    return;
  end if;

  -- This is not a ecx message since l_ext_type and
  -- l_ext_subtype are required.
  if (l_ext_type is null or
      l_ext_subtype is null) then
    return;
  end if;

  l_log_msg := 'ECX_MSG_CREATED_ENQUEUED';

  -- for passthrough, update doclogs with the inbound status
  if (l_direction = 'IN') then
    ecx_errorlog.update_log_document
      (
       l_ecx_msgid,
       l_out_msgid,  -- OUT MSG ID
       'Inbound processing complete.',
       l_logfile,
       null
      );

    open  c1;
    fetch c1 into l_passthr_trigger_id;
    close c1;

    ecx_errorlog.outbound_trigger
      (
      i_trigger_id            => l_passthr_trigger_id,
      i_transaction_type      => l_tran_type,
      i_transaction_subtype   => l_tran_subtype,
      i_party_id              => l_party_id,
      i_party_site_id         => l_int_party_site_id,
      i_party_type            => l_party_type,
      i_document_number       => l_document_id,
      i_status                => '0',
      i_errmsg                => 'ECX_PASSTHRU_OUTBOUND'
      );

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'Logged passthrough on outbound.');
    end if;

    l_trigger_id := l_passthr_trigger_id;
    l_log_msg := 'ECX_PASSTHRU_MSG_ENQUEUED';

    ecx_attachment.remap_attachments(l_out_msgid);
  else
    ecx_attachment.map_attachments(p_event, l_out_msgid);
  end if;

  -- This is commong logging for regular outbound and passthru on the outbound side.
  ecx_errorlog.log_document
    (o_retcode             => l_retcode,
     o_retmsg              => l_retmsg,
     i_msgid               => l_out_msgid,
     i_message_type        => l_message_type,
     i_message_standard    => l_message_standard,
     i_transaction_type    => l_ext_type,
     i_transaction_subtype => l_ext_subtype,
     i_document_number     => l_document_id,
     i_partyid             => l_party_id,
     i_party_site_id       => l_party_site_id,
     i_party_type          => l_party_type,
     i_protocol_type       => l_protocol_type,
     i_protocol_address    => l_protocol_address,
     i_username            => l_username,
     i_password            => l_password,
     i_attribute1          => l_attribute1,
     i_attribute2          => l_attribute2,
     i_attribute3          => l_attribute3,
     i_attribute4          => l_attribute4,
     i_attribute5          => l_attribute5,
     i_payload             => p_event.getEventData(),
     i_status              => 'Message pending delivery.',
     i_direction           => 'OUT',
     i_logfile             => l_logfile,
     i_item_type           => l_item_type,
     i_item_key            => l_item_key,
     i_activity_id         => l_activity_id,
     i_event_name          => p_event.getEventName(),
     i_event_key           => p_event.getEventKey(),
     i_cb_event_name       => l_cb_event_name,
     i_cb_event_key        => l_cb_event_key,
     i_block_mode          => l_block_mode
     );

  -- This code was originally in the queue handler and this is moved to here for
  -- backward compatible purpose.  Not sure who is using this.
  if (l_direction is null) then
    l_direction := ecx_utils.g_direction;
  end if;

  if (UPPER(l_direction) = 'OUT') then
    if (l_activity_id is not null) then
      begin
        wf_engine.SetItemAttrText(l_item_type, l_item_key, 'ECX_MSGID_ATTR', l_out_msgid);
      exception
        when others then
          -- If attr is not already defined, add a runtime attribute
          -- with this name, then try the set again.
          if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
              wf_core.clear;
              wf_engine.AddItemAttr(itemtype => l_item_type,
                                    itemkey => l_item_key,
                                    aname => 'ECX_MSGID_ATTR',
                                    text_value => l_out_msgid);
              WF_CORE.Clear;
          else
              raise;
          end if;
      end;
    end if;
  end if;

  ecx_errorlog.outbound_engine
    (
    l_trigger_id,
    '0',
    l_log_msg,
    l_out_msgid
    );

exception
  when others then
    raise;
end outbound_log;

procedure log_receivemessage
    (caller varchar2,status_text varchar2,err_msg varchar2,receipt_msgid raw,trigger_id pls_integer,
message_type varchar2,message_standard varchar2,transaction_type varchar2,transaction_subtype varchar2,
document_number varchar2,partyid varchar2,party_site_id varchar2,party_type varchar2,protocol_type varchar2,
protocol_address varchar2,username varchar2,encrypt_password varchar2,attribute1 varchar2,attribute2 varchar2,
attribute3 varchar2,attribute4 varchar2,attribute5 varchar2,payload clob,returnval out nocopy varchar2) --return varchar2
is

    status 		binary_integer;
--  err_msg		varchar2(4000);
  err_params            varchar2(255);
  i_message_counter     pls_integer;
  l_retcode             pls_integer := 0;
  l_retmsg              varchar2(2000) := null;

begin
   select ecx_inlstn_s.nextval into i_message_counter from dual ;
   status := 2;
   if (status_text = 'SUCCESS') then
    status := 10;
   end if;
   begin
          ecx_errorlog.log_document(
                                l_retcode,
                                l_retmsg,
                                receipt_msgid,
                                message_type,
                                message_standard,
                                transaction_type,
                                transaction_subtype,
                                document_number,
                                partyid,
                                party_site_id,
                                party_type,
                                protocol_type,
                                protocol_address,
                                username,
                                encrypt_password,
                                attribute1,
                                attribute2,
                                attribute3,
                                attribute4,
                                attribute5,
                                payload,
                                i_message_counter,
                                caller || ' receives and accepts inbound message.',
                                'IN',
                                null
                                );

            if (l_retcode = 1) then
               wf_log_pkg.string(6, 'WF_ECX_Q', l_retmsg);
            elsif (l_retcode >= 2) then
               raise ecx_log_exit;
            end if;
   end;

   ecx_errorlog.inbound_trigger
                (
                 trigger_id,
                 receipt_msgid,
                 null,
                 status,
                 err_msg,
                 err_params
                );

  returnval:= 'SUCCESS';

exception
         when others then
           returnval := 'ERROR. SQLERRM:='||sqlerrm;

end log_receivemessage;

end ecx_errorlog;

/
