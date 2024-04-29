--------------------------------------------------------
--  DDL for Package Body ECX_INBOUND_LISTENER_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_INBOUND_LISTENER_QH" as
-- $Header: ECXILQHB.pls 120.1.12000000.7 2007/06/06 09:55:55 susaha ship $
------------------------------------------------------------------------------+

/**
  Returns the correct event name based on the value of attributte4
**/
procedure get_event_name (p_attribute4  in         varchar2,
                          p_event_name  out nocopy varchar2)
is
  l_position	pls_integer;
  l_temp	varchar2(240);
begin
  if (p_attribute4 is not null)
  then
    if (substr(p_attribute4, 1, 12) = 'oracle.apps.')
    then
      p_event_name := lower(p_attribute4);
    else
      -- starting from 1st position get the characters till the first underscore
      l_position := instrb(p_attribute4, '_');
      l_temp := substr(p_attribute4, 1, l_position - 1);

      if (length(l_temp) <= 3)
      then
        p_event_name := 'oracle.apps.' || lower(l_temp) || '.inbound.message.receive';
      else
        p_event_name := 'oracle.apps.ecx.inbound.message.receive';
      end if;
    end if;
  else
    p_event_name := 'oracle.apps.ecx.inbound.message.receive';
  end if;
exception
when others then
  raise;
end get_event_name;


PROCEDURE Dequeue(p_agent_guid in RAW, p_event out nocopy WF_EVENT_T)
is
  x_queue_name          varchar2(80);
  x_agent_name          varchar2(30);
  x_dequeue_options     dbms_aq.dequeue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  x_clob		clob;
  no_messages           exception;
  pragma exception_init (no_messages, -25228);
  x_ecxmsg            	system.ecxmsg;
  x_sys_guid            RAW(16);
  x_sys_name            VARCHAR2(30);
  x_from_agt            wf_agent_t := wf_agent_t(null,null);
  x_to_agt              wf_agent_t := wf_agent_t(null,null);
  i_message_counter	pls_integer;
  x_trigger_id          number;
  l_retcode             pls_integer := 0;
  l_retmsg              varchar2(200) := null;
  encrypt_password      ecx_tp_details.password%type;
  l_module              varchar2(2000);
  cursor c_ecx_trigger_id
  is
  select ecx_trigger_id_s.NEXTVAL
  from dual;

begin
  l_module := 'ecx.plsql.ecx_inbound_listener_qh.dequeue';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module || '.begin',
       'in dequeue');
  end if;

  select upper(queue_name), upper(name), system_guid
  into   x_queue_name, x_agent_name, x_sys_guid      -- 20
  from   wf_agents
  where  guid = p_agent_guid;

  select upper(name)
  into   x_sys_name
  from   wf_systems
  where  guid = x_sys_guid;

  x_from_agt := wf_agent_t(x_agent_name, x_sys_name);
  x_to_agt := wf_agent_t(x_agent_name, x_sys_name);

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,'p_agent_guid' ||hextoraw(p_agent_guid));
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,'System: ' || x_sys_name);
  end if;

  x_dequeue_options.wait := 1;

  savepoint before_dequeue;

  dbms_aq.dequeue
    (
     queue_name         => x_queue_name,
     dequeue_options    => x_dequeue_options,
     message_properties => x_message_properties,
     payload            => x_ecxmsg,
     msgid              => x_msgid
    );

  --- bug#2016123. If the transaction subtype is null ,
  --- default it to the transaction_type
  if x_ecxmsg.transaction_subtype is null
  then
    x_ecxmsg.transaction_subtype := x_ecxmsg.transaction_type;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'after dequeue');
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Message Id: ' || x_msgid);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Message Type: ' || x_ecxmsg.message_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Message Standard: ' || x_ecxmsg.message_standard);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'transaction type: ' || x_ecxmsg.transaction_type);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'transaction subtype: '|| x_ecxmsg.transaction_subtype);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       ' Defaulted transaction subtype: '|| x_ecxmsg.transaction_subtype);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Party Site Id: '|| x_ecxmsg.party_site_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'From: '|| x_ecxmsg.attribute1);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Final Destination: '|| x_ecxmsg.attribute3);
  end if;

  x_from_agt := wf_agent_t(substr(x_ecxmsg.party_site_id,1,30),
                                  'EXTERNAL_PARTY_SITEID');

  wf_event_t.initialize(p_event);

  -- get the correct event name
  get_event_name(x_ecxmsg.attribute4, p_event.event_name);
  p_event.priority := 1;
  p_event.event_key := x_msgid;
  p_event.from_agent := x_from_agt ;
  p_event.to_agent := x_to_agt ;
  p_event.error_subscription := null;
  p_event.error_message := null;
  p_event.error_stack := null;

  select ecx_inlstn_s.nextval into i_message_counter from dual ;
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'setting message props');
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'msg_counter: ' || i_message_counter);
  end if;

  --- Encrypt the password
  ecx_obfuscate.ecx_data_encrypt(
     l_input_string    => x_ecxmsg.password,
     l_output_string   => encrypt_password,
     errmsg            => l_retmsg,
     retcode           => l_retcode);

  p_event.AddParameterToList('ECX_MSGID', x_msgid);
  p_event.AddParameterToList('ECX_TRANSACTION_TYPE', x_ecxmsg.transaction_type);
  p_event.AddParameterToList('ECX_TRANSACTION_SUBTYPE', x_ecxmsg.transaction_subtype);
  p_event.AddParameterToList('ECX_MESSAGE_STANDARD', x_ecxmsg.message_standard);
  p_event.AddParameterToList('ECX_MESSAGE_TYPE', x_ecxmsg.message_type);
  p_event.AddParameterToList('ECX_DOCUMENT_NUMBER', x_ecxmsg.document_number);
  p_event.AddParameterToList('ECX_PARTY_ID', x_ecxmsg.partyid);
  p_event.AddParameterToList('ECX_PARTY_SITE_ID', x_ecxmsg.party_site_id);
  p_event.AddParameterToList('ECX_PARTY_TYPE', x_ecxmsg.party_type);
  p_event.AddParameterToList('ECX_PROTOCOL_TYPE', x_ecxmsg.protocol_type);
  p_event.AddParameterToList('ECX_PROTOCOL_ADDRESS', x_ecxmsg.protocol_ADDRESS);
  p_event.AddParameterToList('ECX_USERNAME', x_ecxmsg.username);
  p_event.AddParameterToList('ECX_PASSWORD', encrypt_password);
  p_event.AddParameterToList('ECX_ATTRIBUTE1', x_ecxmsg.attribute1);
  p_event.AddParameterToList('ECX_ATTRIBUTE2', nvl(to_number(x_ecxmsg.attribute2),0));
  p_event.AddParameterToList('ECX_ATTRIBUTE3', x_ecxmsg.attribute3);
  p_event.AddParameterToList('ECX_ATTRIBUTE4', x_ecxmsg.attribute4);
  p_event.AddParameterToList('ECX_ATTRIBUTE5', x_ecxmsg.attribute5);
  p_event.AddParameterToList('ECX_ICN', i_message_counter);
  open c_ecx_trigger_id;
  fetch c_ecx_trigger_id into x_trigger_id;
  close c_ecx_trigger_id;

  p_event.AddParameterToList('ECX_TRIGGER_ID', x_trigger_id);

  -- KH How do we pass this parameter dynamically through the Interface
  --p_event.AddParameterToList('ECX_DEBUG_LEVEL', 0);
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module, 'Setting payload');
  end if;
  p_event.setEventData(x_ecxmsg.payload);

exception
  when no_messages then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'No more messages in dequeue.');
    end if;
    p_event := NULL;
    return;

  when queue_handler_exit then
    rollback to before_dequeue;
    if (wf_log_pkg.level_error >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         ecx_debug.getMessage(ecx_utils.i_errbuf, ecx_utils.i_errparams));
      wf_log_pkg.string(wf_log_pkg.level_error, l_module,
         'Exception in dequeue ' || x_queue_name);
    end if;
    Wf_Core.Context('ECX_INBOUND_LISTENER_QH', 'Dequeue', x_queue_name);
    raise;

  when others then
    rollback to before_dequeue;
    if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
        substr(sqlerrm, 1,2000));
      wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
        'Exception in dequeue '|| x_queue_name);
    end if;
    Wf_Core.Context('ECX_INBOUND_LISTENER_QH', 'Dequeue', x_queue_name);
    raise;
end Dequeue;


PROCEDURE Enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t )
is

  	x_out_queue           varchar2(80);
  	x_enqueue_options     dbms_aq.enqueue_options_t;
  	x_message_properties  dbms_aq.message_properties_t;
  	x_msgid               RAW(16);
	x_ecxmsg              SYSTEM.ecxmsg ;
        l_module              varchar2(2000);

begin
  l_module := 'ecx.plsql.ecx_inbound_listener_qh.enqueue';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module || '.begin',
       'in enqueue');
  end if;

  x_out_queue := 'APPLSYS.ECX_INBOUND';

  x_ecxmsg  := SYSTEM.ecxmsg(null,null,null,null, null,null,null,null,
                             null,null,null,null, null,null,
                             null,null,null,null);

  x_ecxmsg.message_type     := p_event.getValueForParameter('ECX_MESSAGE_TYPE');
  x_ecxmsg.message_standard := p_event.getValueForParameter('ECX_MESSAGE_STANDARD');
  x_ecxmsg.transaction_type := p_event.getValueForParameter('ECX_TRANSACTION_TYPE');
  x_ecxmsg.transaction_subtype := p_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
  x_ecxmsg.document_number := p_event.getValueForParameter('ECX_DOCUMENT_NUMBER');
  x_ecxmsg.partyid := p_event.getValueForParameter('ECX_PARTY_ID');
  x_ecxmsg.party_site_id := p_event.getValueForParameter('ECX_PARTY_SITE_ID');
  x_ecxmsg.protocol_type := p_event.getValueForParameter('ECX_PROTOCOL_TYPE');
  x_ecxmsg.protocol_address := p_event.getValueForParameter('ECX_PROTOCOL_ADDRESS');
  x_ecxmsg.username := p_event.getValueForParameter('ECX_USERNAME');
  x_ecxmsg.password := p_event.getValueForParameter('ECX_PASSWORD');
  x_ecxmsg.attribute1 := p_event.getValueForParameter('ECX_ATTRIBUTE1');
  x_ecxmsg.attribute2 := p_event.getValueForParameter('ECX_ATTRIBUTE2');
  x_ecxmsg.attribute3 := p_event.getValueForParameter('ECX_ATTRIBUTE3');
  x_ecxmsg.attribute4 := p_event.getValueForParameter('ECX_ATTRIBUTE4');
  x_ecxmsg.attribute5 := p_event.getValueForParameter('ECX_ATTRIBUTE5');
  x_ecxmsg.payload := p_event.getEventData();

  x_message_properties.priority := p_event.GetPriority();


  DBMS_AQ.ENQUEUE
  (
    queue_name          => x_out_queue,
    enqueue_options     => x_enqueue_options,
    message_properties  => x_message_properties,
    payload             => x_ecxmsg,
    msgid               => x_msgid
  );

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module || '.end',
       'finished calling dbms_aq.enqueue');
  end if;

exception
when others then
	Wf_Core.Context('ECX_INBOUND_LISTENER_QH', 'Enqueue', x_out_queue);
	raise;
end Enqueue;


end ECX_INBOUND_LISTENER_QH;

/
