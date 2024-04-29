--------------------------------------------------------
--  DDL for Package Body WF_ERROR_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ERROR_QH" as
/* $Header: wferrqhb.pls 120.2 2006/02/16 05:49:22 nravindr ship $ */
------------------------------------------------------------------------------
PROCEDURE dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t)
is
  x_queue_name          varchar2(80);
  x_agent_name          varchar2(30);
  x_dequeue_options     dbms_aq.dequeue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  no_messages           exception;
  pragma exception_init (no_messages, -25228);

   snap_too_old exception;
   pragma exception_init(snap_too_old, -1555);
begin
  select upper(queue_name), upper(name)
  into   x_queue_name, x_agent_name
  from   wf_agents
  where  guid = p_agent_guid;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_ERROR_QH.dequeue.Begin',
                      'Dequeuing '||x_queue_name||' on '||x_agent_name);
  end if;


  -- Set correlation Id for dequeue if only available
  if (wf_event.g_correlation is not null) then
     -- Seeded agent with this queue handler
     if (x_agent_name like 'WF_%') then
        if (wf_event.account_name is null) then
           wf_event.SetAccountName;
        end if;
        x_dequeue_options.correlation := wf_event.account_name || ':' || wf_event.g_correlation;
     else
        x_dequeue_options.correlation := wf_event.g_correlation;
     end if;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     if (wf_event.g_correlation is not null) then
        wf_log_pkg.string(wf_log_pkg.level_procedure,
                         'wf.plsql.WF_ERROR_QH.dequeue.corrid',
                         'Dequeuing with Correlation ' || x_dequeue_options.correlation);
     else
        wf_log_pkg.string(wf_log_pkg.level_procedure,
                         'wf.plsql.WF_ERROR_QH.dequeue.corrid',
                         'Dequeuing with No Correlation');
     end if;
  end if;

  x_dequeue_options.consumer_name := x_agent_name;
  --x_dequeue_options.wait          := DBMS_AQ.NO_WAIT;
  x_dequeue_options.navigation    := wf_event.navigation;
  x_dequeue_options.wait          := 1;
  BEGIN
    DBMS_AQ.DEQUEUE(queue_name         => x_queue_name,
                    dequeue_options    => x_dequeue_options,
                    message_properties => x_message_properties, /* OUT */
                    payload            => p_event,              /* OUT */
                    msgid              => x_msgid);             /* OUT */
    wf_event.navigation    := dbms_aq.next_message;
  EXCEPTION
    when no_messages then

      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_event,
                          'wf.plsql.WF_ERROR_QH.dequeue.queue_empty',
                          'No more messages in dequeue.');
      end if;

      wf_event.navigation := dbms_aq.first_message;
      p_event := NULL;
      return;
    --Capture the snapshot too old error
    when snap_too_old then
      --Workaround for AQ when receiving ORA-01555 using NEXT_MESSAGE as
      --navigation.  We will try to set to FIRST_MESSAGE and dequeue to
      --silently handle this exception.
      if (wf_event.navigation = dbms_aq.FIRST_MESSAGE) then
        raise;
      else
        wf_event.navigation := dbms_aq.FIRST_MESSAGE;
        x_dequeue_options.navigation    := wf_event.navigation;
        dbms_aq.dequeue(queue_name         => x_queue_name,
                        dequeue_options    => x_dequeue_options,
                        message_properties => x_message_properties, -- out
                        payload            => p_event,   -- out
                        msgid              => x_msgid);             -- out

        --Set the navigation now to the next message
        wf_event.navigation := dbms_aq.next_message;
      end if;
     when others then
        wf_event.navigation := dbms_aq.FIRST_MESSAGE;
        raise;
  END;
exception
  when others then
    Wf_Core.Context('Wf_Error_QH', 'Dequeue', x_queue_name,
                     'SQL err is '||substr(sqlerrm,1,200));
    raise;
end dequeue;
------------------------------------------------------------------------------
-- Bug 5034154
-- Added as a wrapper over the existing dequeue
-- calls existing dequeue with two parameters ignoring p_wait
PROCEDURE dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t,
                  p_wait       in         binary_integer)
is
begin
    dequeue(p_agent_guid, p_event);
end dequeue;
------------------------------------------------------------------------------
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t )
is
  x_out_agent_name      varchar2(30);
  x_out_system_name     varchar2(30);
  x_out_queue           varchar2(80);
  x_enqueue_options     dbms_aq.enqueue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  x_name                varchar2(30);
  x_address             varchar2(1024);
  x_protocol            varchar2(30);
  x_protocol_num        number := 0;
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_ERROR_QH.enqueue.Begin',
                      'Entered Enqueue ');
  end if;

  -- Determine the out queue --

  x_out_agent_name := p_out_agent_override.GetName();
  x_out_system_name := p_out_agent_override.GetSystem();

  select agt.queue_name into x_out_queue
  from   wf_agents  agt,
         wf_systems sys
  where  agt.name = x_out_agent_name
  and    sys.name = x_out_system_name
  and    sys.guid = agt.system_guid;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_ERROR_QH.enqueue.Enqueuing',
                      'Enqueuing on Queue: '||x_out_queue);
  end if;

  x_protocol_num := 0;
  x_message_properties.recipient_list(1) := sys.aq$_agent(x_out_agent_name,
                                                          null,
                                                          x_protocol_num);

  if (x_out_agent_name like 'WF_%') then
    if wf_event.account_name is null then
       wf_event.SetAccountName;
    end if;
     --<rwunderl:2867245>
     --Append the event name to the correlation id
     x_message_properties.correlation := wf_event.account_name||
                                         ':'||p_event.event_name;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_ERROR_QH.enqueue.dbms_qa',
                      'calling dbms_aq.enqueue');
  end if;

  DBMS_AQ.ENQUEUE(
   queue_name          => x_out_queue,
   enqueue_options     => x_enqueue_options,
   message_properties  => x_message_properties,
   payload             => p_event,
   msgid               => x_msgid);             /* OUT*/

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_ERROR_QH.enqueue.done',
                      'finished calling dbms_aq.enqueue');
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Error_QH', 'Enqueue', x_out_queue
                     );
    raise;
end enqueue;
------------------------------------------------------------------------------
end WF_ERROR_QH;

/
