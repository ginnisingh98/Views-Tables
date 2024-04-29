--------------------------------------------------------
--  DDL for Package Body ECX_OUT_WF_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_OUT_WF_QH" as
-- $Header: ECXOWFQB.pls 115.14 2004/06/01 21:19:23 mtai ship $


PROCEDURE Dequeue(p_agent_guid in RAW, p_event out NOCOPY WF_EVENT_T)
is
  x_queue_name          varchar2(80);
  x_agent_name          varchar2(30);
  x_dequeue_options     dbms_aq.dequeue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  x_clob                clob;
  no_messages           exception;
  pragma exception_init (no_messages, -25228);
  x_ecxmsg              system.ecxmsg;
  x_sys_guid            RAW(16);
  x_sys_name            VARCHAR2(30);
  x_from_agt            wf_agent_t := wf_agent_t(null,null);
  x_to_agt              wf_agent_t := wf_agent_t(null,null);
  l_module              varchar2(2000);

begin
  l_module := 'ecx.plsq.ecx_out_wf_qh.dequeue';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
        'getting queue details');
  end if;

  select upper(queue_name), upper(name), system_guid
  into   x_queue_name, x_agent_name, x_sys_guid
  from   wf_agents
  where  guid = p_agent_guid;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
        'getting system name');
  end if;

  select upper(name)
  into   x_sys_name
  from   wf_systems
  where  guid = x_sys_guid;

  x_from_agt := wf_agent_t(x_agent_name, x_sys_name);
  x_to_agt := wf_agent_t(x_agent_name, x_sys_name);

  wf_event_t.initialize(p_event);

  x_dequeue_options.wait := dbms_aq.no_wait;
  x_dequeue_options.navigation    := ecx_out_wf_qh.navigation;

  begin
    dbms_aq.dequeue
        (
        queue_name              => x_queue_name,
        dequeue_options         => x_dequeue_options,
        message_properties      => x_message_properties,
        payload                 => x_ecxmsg,
        msgid                   => x_msgid
        );

    ecx_out_wf_qh.navigation := dbms_aq.next_message;

    p_event.priority := 1;
    p_event.event_name := 'oracle.apps.ecx.inbound.message.receive';
    p_event.event_key := x_ecxmsg.document_number;
    p_event.from_agent := x_from_agt ;
    p_event.to_agent := x_to_agt ;
    p_event.error_subscription := null;
    p_event.error_message := null;
    p_event.error_stack := null;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
          'setting message props');
    end if;

  --p_event.AddParameterToList('ECX_MSGID', x_msgid);
    p_event.AddParameterToList('TRANSACTION_TYPE', x_ecxmsg.transaction_type);
    p_event.AddParameterToList('TRANSACTION_SUBTYPE', x_ecxmsg.transaction_subtype);
    p_event.AddParameterToList('MESSAGE_STANDARD', x_ecxmsg.message_standard);
    p_event.AddParameterToList('MESSAGE_TYPE', x_ecxmsg.message_type);
    p_event.AddParameterToList('DOCUMENT_NUMBER', x_ecxmsg.document_number);
    p_event.AddParameterToList('PARTYID', x_ecxmsg.partyid);
    p_event.AddParameterToList('PARTY_SITE_ID', x_ecxmsg.party_site_id);
    p_event.AddParameterToList('PROTOCOL_TYPE', x_ecxmsg.protocol_type);
    p_event.AddParameterToList('PROTOCOL_ADDRESS', x_ecxmsg.protocol_ADDRESS);
    p_event.AddParameterToList('USERNAME', x_ecxmsg.username);
    p_event.AddParameterToList('PASSWORD', x_ecxmsg.password);
    p_event.AddParameterToList('ATTRIBUTE1', x_ecxmsg.attribute1);
    p_event.AddParameterToList('ATTRIBUTE2', x_ecxmsg.attribute2);
    p_event.AddParameterToList('ATTRIBUTE3', x_ecxmsg.attribute3);
    p_event.AddParameterToList('ATTRIBUTE4', x_ecxmsg.attribute4);
    p_event.AddParameterToList('ATTRIBUTE5', x_ecxmsg.attribute5);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
          'setting payload');
    end if;
    p_event.setEventData(x_ecxmsg.payload);

  exception
    when no_messages then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
           'No more messages in dequeue.');
      end if;
      ecx_out_wf_qh.navigation := dbms_aq.first_message;
      p_event := NULL;
      return;
  end;

exception
   when others then
     Wf_Core.Context('ECX_OUT_WF_QH', 'Dequeue', x_queue_name);
     raise;
end Dequeue;


/**
  This procedure traverses through all the parameters in wf_event_t object, constructs the
  system.ecxmsg object and returns these to the caller procedure
**/
procedure create_ecxmsg(p_event   in wf_event_t,
                        x_ecxmsg  in out NOCOPY SYSTEM.ecxmsg
                        )
is

  i_param_list          wf_parameter_list_t;
  i_param_name          varchar2(2000);
  i_param_value         varchar2(2000);
  i_password            ecx_tp_details.password%TYPE;
  m_password            ecx_tp_details.password%TYPE;
  l_module              varchar2(2000);

begin

  l_module := 'ecx.plsql.ecx_out_wf_qh.enqueue.create_ecxmsg';
  -- loop through the parameter list and construct x_ecxmsg object
  i_param_list := p_event.getParameterList();
  if (i_param_list is null) then
     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                          'event object parameter list in empty');
     end if;

     --MLS ecx_out_wf_qh.retmsg := 'Parameter List cannot be null';
     ecx_out_wf_qh.retmsg :='ECX_PARAM_LIST_NOT_NULL';
     ecx_out_wf_qh.retcode := 2;
     raise queue_handler_exit;
  else
    x_ecxmsg  := SYSTEM.ecxmsg(null, null, null, null, null, null, null, null, null,
                               null, null, null, null, null, null, null, null, null);
    for i in i_param_list.first..i_param_list.last loop
      i_param_name := i_param_list(i).GetName;
      i_param_value := i_param_list(i).GetValue;

      if i_param_name = 'MESSAGE_TYPE' then
        x_ecxmsg.message_type := i_param_value;

      elsif i_param_name = 'MESSAGE_STANDARD' then
        x_ecxmsg.message_standard := i_param_value;

      elsif i_param_name = 'TRANSACTION_TYPE' then
        x_ecxmsg.transaction_type := i_param_value;

      elsif i_param_name = 'TRANSACTION_SUBTYPE' then
        x_ecxmsg.transaction_subtype := i_param_value;

      elsif i_param_name = 'DOCUMENT_NUMBER' then
        x_ecxmsg.document_number := i_param_value;

      elsif i_param_name = 'PARTY_TYPE' then
        x_ecxmsg.party_type := i_param_value;

      elsif i_param_name = 'PARTYID' then
        x_ecxmsg.partyid := i_param_value;

      elsif i_param_name = 'PARTY_SITE_ID' then
        x_ecxmsg.party_site_id := i_param_value;

      elsif i_param_name = 'PROTOCOL_TYPE' then
        x_ecxmsg.protocol_type := i_param_value;

      elsif i_param_name = 'PROTOCOL_ADDRESS' then
        x_ecxmsg.protocol_address := i_param_value;

      elsif i_param_name = 'USERNAME' then
        x_ecxmsg.username := i_param_value;

      elsif i_param_name = 'PASSWORD' then
        x_ecxmsg.password := i_param_value;

      elsif i_param_name = 'ATTRIBUTE1' then
        x_ecxmsg.attribute1 := i_param_value;

      elsif i_param_name = 'ATTRIBUTE2' then
        x_ecxmsg.attribute2 := i_param_value;

      elsif i_param_name = 'ATTRIBUTE3' then
        x_ecxmsg.attribute3 := i_param_value;

      elsif i_param_name = 'ATTRIBUTE4' then
        x_ecxmsg.attribute4 := i_param_value;

      elsif i_param_name = 'ATTRIBUTE5' then
        x_ecxmsg.attribute5 := i_param_value;
      end if;
    end loop;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
        'setting payload');
  end if;
  x_ecxmsg.payload := p_event.getEventData();

exception
  when queue_handler_exit then
    raise queue_handler_exit;
  when others then
    ecx_out_wf_qh.retmsg := SQLERRM;
    ecx_out_wf_qh.retcode := 2;
    raise queue_handler_exit;
end create_ecxmsg;


/**
  This procedure enqueues the message on ecx_outqueue and returns the msgid of this message
**/
procedure enqueue_msg(
                      x_out_queue		in varchar2,
                      i_protocol_type 		in out NOCOPY varchar2,
                      x_ecxmsg			in out NOCOPY SYSTEM.ecxmsg,
                      x_msgid                   out NOCOPY raw
		      )
is
  x_enqueue_options     dbms_aq.enqueue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  l_in_clob             clob;
  l_out_clob            clob;
  l_module              varchar2(2000);

begin

  l_module := 'ecx.plsq.ecx_out_wf_qh.enqueue.enqueue_msg';
  if ( (i_protocol_type = 'HTTP-WM') or (i_protocol_type = 'HTTPS-WM') ) then
     x_message_properties.correlation := 'WEBMETHODS' ;
  elsif ((i_protocol_type = 'HTTP') or (i_protocol_type = 'HTTP-OXTA') or
         (i_protocol_type = 'HTTPS') or (i_protocol_type = 'HTTPS-OXTA') or
         (i_protocol_type = 'HTTP-ATCH') or (i_protocol_type = 'HTTPS-ATCH') or
         (i_protocol_type = 'OTAH-ATCH') or (i_protocol_type = 'OTAHS-ATCH') or
         (i_protocol_type = 'SMTP')) then
    x_message_properties.correlation := 'OXTA';
  else
    x_message_properties.correlation := i_protocol_type;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
        'Correlation id: '|| x_message_properties.correlation);
  end if;

  l_in_clob := x_ecxmsg.payload;
  ecx_eng_utils.convertEncryCodeClob(l_in_clob, l_out_clob);
  x_ecxmsg.payload := l_out_clob;

  DBMS_AQ.ENQUEUE
  (
 	queue_name          => x_out_queue,
        enqueue_options     => x_enqueue_options,
   	message_properties  => x_message_properties,
   	payload             => x_ecxmsg,
   	msgid               => x_msgid
  );

  -- assign the encrpyted clob back to x_ecxmsg so it will insert the
  -- encrpyted clob to ecx_doclogs later.
  x_ecxmsg.payload := l_in_clob;

  if dbms_lob.istemporary(l_out_clob) = 1 then
     dbms_lob.freetemporary(l_out_clob);
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
        'Enqueued Message: ' || x_msgid);
  end if;
exception
  when queue_handler_exit then
    if dbms_lob.istemporary(l_out_clob) = 1 then
       dbms_lob.freetemporary(l_out_clob);
    end if;
    raise queue_handler_exit;

  when others then
    if dbms_lob.istemporary(l_out_clob) = 1 then
       dbms_lob.freetemporary(l_out_clob);
    end if;
    ecx_out_wf_qh.retmsg := SQLERRM;
    ecx_out_wf_qh.retcode := 2;
    raise queue_handler_exit;
end enqueue_msg;


PROCEDURE Enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t )
is

  x_out_agent_name      varchar2(30);
  x_out_system_name     varchar2(30);
  x_to_agent_name       varchar2(30);
  x_to_system_name      varchar2(30);
  x_out_queue           varchar2(80);
  x_to_queue            varchar2(80);
  x_msgid               RAW(16);
  x_ecxmsg		SYSTEM.ecxmsg;
  l_module              varchar2(2000);

  cursor c1
  is
  select  ecx_trigger_id_s.NEXTVAL
  from    dual;

begin
  l_module := 'ecx.plsql.ecx_out_wf_qh.enqueue';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure, l_module ||'.begin',
        'Enqueue Message');
  end if;

  -- reset global variables
  retmsg := null;
  retcode := 0;
  msgid := null;

  -- Determine the out queue
  if (p_out_agent_override is not null) then
    x_out_agent_name := p_out_agent_override.GetName();
    x_out_system_name := p_out_agent_override.GetSystem();
  else
    x_out_agent_name := p_event.GetFromAgent().GetName();
    x_out_system_name := p_event.GetFromAgent().GetSystem();
  end if;

  select agt.queue_name into x_out_queue
  from   wf_agents  agt,
         wf_systems sys
  where  agt.name = x_out_agent_name
  and    sys.name = x_out_system_name
  and    sys.guid = agt.system_guid;

  create_ecxmsg (p_event, x_ecxmsg);

  -- enqueue the message
  ecx_out_wf_qh.enqueue_msg(
                           x_out_queue		=> x_out_queue,
                           i_protocol_type 	=> x_ecxmsg.protocol_type,
                           x_ecxmsg		=> x_ecxmsg,
                           x_msgid 		=> x_msgid
                           );

  -- set msgid
  ecx_out_wf_qh.msgid := x_msgid;
  wf_event.g_msgid := x_msgid;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
        'Enqueue Message Successfully');
  end if;

/*
    -- set the msgid in the item attribute if it is not a passthrough transaction.
    if (not i_passthr) then
      if (i_activity_id is not null)
      then
        begin
          wf_engine.SetItemAttrText(i_item_type, i_item_key, 'ECX_MSGID_ATTR', x_msgid);
        exception
        when others then
          -- If attr is not already defined, add a runtime attribute
          -- with this name, then try the set again.
          if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
              'ECX_MSGID_ATTR is not defined!');
          end if;
          if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
            wf_core.clear;
            wf_engine.AddItemAttr(itemtype => i_item_type,
                        itemkey => i_item_key,
                        aname => 'ECX_MSGID_ATTR',
                        text_value => x_msgid);
            if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
              wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
                 'Created and set ECX_MSGID_ATTR ');
            end if;
            WF_CORE.Clear;
          else
            raise;
          end if;
        end;
      end if;
*/
exception
  when queue_handler_exit then
    wf_core.context('ECX_OUT_WF_QH', 'Enqueue', x_out_queue, ecx_debug.getMessage(ecx_out_wf_qh.retmsg,
                     ecx_utils.i_errparams), ecx_out_wf_qh.retcode);
    raise;

  when others then
    ecx_out_wf_qh.retmsg := SQLERRM;
    ecx_out_wf_qh.retcode := 2;
    raise queue_handler_exit;
end Enqueue;

end ECX_OUT_WF_QH;


/
