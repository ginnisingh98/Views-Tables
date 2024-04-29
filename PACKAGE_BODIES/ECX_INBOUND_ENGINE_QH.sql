--------------------------------------------------------
--  DDL for Package Body ECX_INBOUND_ENGINE_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_INBOUND_ENGINE_QH" as
-- $Header: ECXIEQHB.pls 120.4.12010000.2 2010/02/24 14:32:59 alsosa ship $
------------------------------------------------------------------------------+
PROCEDURE Dequeue(p_agent_guid in RAW, p_event out nocopy WF_EVENT_T)
is
  x_queue_name          varchar2(80);
  x_agent_name          varchar2(30);
  x_msgid               RAW(16);
  x_clob		clob;
  no_messages           exception;
  pragma exception_init (no_messages, -25228);
  no_event_name 	exception;
  inbound_engine_error 	exception;
  x_sys_guid            RAW(16);
  x_sys_name            VARCHAR2(30);
  x_from_agt            wf_agent_t := wf_agent_t(null,null);
  x_to_agt              wf_agent_t := wf_agent_t(null,null);

  v_message             system.ecx_inengobj;
  v_dequeueoptions      dbms_aq.dequeue_options_t;
  v_messageproperties   dbms_aq.message_properties_t;
  v_msgid               raw(16);
  l_module              varchar2(2000);
  v_log_enabled_appl     varchar2(1);
  v_log_enabled_site     varchar2(1);
  v_log_module_appl       varchar2(240);
  v_log_module_site        varchar2(240);
begin
  l_module := 'ecx.plsql.ecx_inbound_engine_qh';
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

  BEGIN
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'p_agent_guid' ||hextoraw(p_agent_guid));
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'System: ' || x_sys_name);
    end if;

    v_dequeueoptions.wait := 1;

    wf_event_t.initialize(p_event);
    wf_event_t.initialize(ecx_utils.g_event);
    p_event.event_name := 'oracle.apps.ecx.inbound.message.process';

    savepoint before_dequeue;
    v_log_enabled_appl := fnd_profile.value_specific(name=>'AFLOG_ENABLED',
			                      	     user_id=>0,
                                                     responsibility_id=>20420,
				                     application_id=>174,
                                                     org_id=>null,
                             	                     server_id=>null);
    v_log_module_appl := fnd_profile.value_specific(name=>'AFLOG_MODULE',
                                                    user_id=>0,
                                                    responsibility_id=>20420,
                                                    application_id=>174,
                                                    org_id=>null,
                                                    server_id=>null);

    if ((v_log_enabled_appl='Y' OR v_log_enabled_appl='N') AND (v_log_module_appl like 'ecx%'or v_log_module_appl = '%'))
	then
     fnd_global.apps_initialize(0,20420,174);
    else
     v_log_enabled_site := fnd_profile.value_specific(name=>'AFLOG_ENABLED',
                                                     user_id=>0,
                                                     responsibility_id=>20420,
                                                     application_id=>0,
                                                     org_id=>null,
                                                     server_id=>null);
    v_log_module_site := fnd_profile.value_specific(name=>'AFLOG_MODULE',
                                                    user_id=>0,
                                                    responsibility_id=>20420,
                                                    application_id=>0,
                                                    org_id=>null,
                                                    server_id=>null);
    if (v_log_enabled_site='Y' AND (v_log_module_site like 'ecx%'or v_log_module_site = '%')) then                                     fnd_global.apps_initialize(0,20420,0);
    end if;
    end if;
    dbms_aq.dequeue (
      queue_name => x_queue_name,
      dequeue_options => v_dequeueoptions,
      message_properties => v_messageproperties,
      payload => v_message,
      msgid => v_msgid
    );

    p_event.AddParameterToList('ECX_MSGID', v_message.msgid);
    p_event.AddParameterToList('ECX_DEBUG_LEVEL', v_message.debug_mode);
    p_event.AddParameterToList('ECX_PROCESS_ID', v_msgid);
    p_event.event_key := v_msgid;
    p_event.from_agent := x_from_agt ;
    p_event.to_agent := x_to_agt;
    p_event.send_date := sysdate;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
         'After Dequeue.  Message Id: ' || x_msgid);
    end if;

  EXCEPTION
    when no_messages then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
           'No more messages in dequeue.');
      end if;
      p_event := NULL;
      return;
  END;
exception
  when others then
     rollback to before_dequeue;
     if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_unexpected, l_module,
           substr(sqlerrm, 1,2000));
     end if;
     Wf_Core.Context('Wf_Event_ECXMSG_QH', 'Dequeue', x_queue_name);
     raise;
end Dequeue;


PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t )
is
  	x_out_agent_name      	varchar2(30);
  	x_out_system_name     	varchar2(30);
  	x_to_agent_name       	varchar2(30) := p_event.GetToAgent().GetName();
  	x_to_system_name      	varchar2(30) := p_event.GetToAgent().GetSystem();
  	x_out_queue           	varchar2(80);
  	x_to_queue            	varchar2(80);
  	x_enqueue_options     	dbms_aq.enqueue_options_t;
  	x_message_properties  	dbms_aq.message_properties_t;
  	v_msgid               	RAW(16);
	v_message		SYSTEM.ECX_INENGOBJ ;
        x_trigger_id            number;
        l_module                varchar2(2000);

        cursor c_ecx_trigger_id
        is
        select ecx_trigger_id_s.NEXTVAL
        from dual;


begin
  l_module := 'ecx.plsql.ecx_inbound_engine_qh.enqueue';
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module || '.begin',
       'in enqueue');
  end if;

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

  v_message := SYSTEM.ECX_INENGOBJ(null,null);

  v_message.msgid := p_event.getValueForParameter('ECX_MSGID');
  v_message.debug_mode := p_event.getValueForParameter('ECX_DEBUG_LEVEL');
  x_trigger_id := p_event.getValueForParameter('ECX_TRIGGER_ID');

  if (x_trigger_id is null) then
     open c_ecx_trigger_id;
     fetch c_ecx_trigger_id into x_trigger_id;
     close c_ecx_trigger_id;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Trigger Id: ' || x_trigger_id);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Message Id: ' || v_message.msgid);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Debug Mode: ' || v_message.debug_mode);
    wf_log_pkg.string(wf_log_pkg.level_statement, l_module,
       'Enqueuing on Queue: ' || x_out_queue);
  end if;

	/*
  	** Set the Priority
  	*/
  x_message_properties.priority := p_event.GetPriority();

  begin
        DBMS_AQ.ENQUEUE(
   	queue_name          => x_out_queue,
   	enqueue_options     => x_enqueue_options,
   	message_properties  => x_message_properties,
   	payload             => v_message,
   	msgid               => v_msgid);             /* OUT*/

        ecx_debug.setErrorInfo(10,10, 'ECX_REPROCESSING_MESSAGE');

        ecx_errorlog.inbound_trigger
                        (
                           x_trigger_id,
                           v_message.msgid,
                           v_msgid,
                           ecx_utils.i_ret_code,
                           ecx_utils.i_errbuf
                        );

  exception
    when others then
         ecx_debug.setErrorInfo(1,30, 'ECX_REPROCESSING_ENQ_ERROR',
                                'p_out_queue', x_out_queue);

         ecx_errorlog.inbound_trigger(
                      x_trigger_id,
                      v_message.msgid,
                      v_msgid,
                      ecx_utils.i_ret_code,
                      ecx_utils.i_errbuf,
                      ecx_utils.i_errparams
                      );

  end;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure, l_module || '.end',
       'finished calling dbms_aq.enqueue');
  end if;

exception
  when others then
	Wf_Core.Context('ECX_INBOUND_ENGINE_QH', 'Enqueue', x_out_queue,
                     'SQL err is '||substr(sqlerrm,1,200));
    	raise;
end enqueue;


end ECX_INBOUND_ENGINE_QH;

/
