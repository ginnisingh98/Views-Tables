--------------------------------------------------------
--  DDL for Package Body WF_EVENT_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_QH" as
/* $Header: wfquhndb.pls 120.2.12010000.2 2009/03/20 19:54:12 alepe ship $ */
------------------------------------------------------------------------------
PROCEDURE dequeue(p_agent_guid in  raw,
                  p_event      out nocopy wf_event_t,
                  p_wait       in binary_integer default dbms_aq.no_wait)
is
  x_queue_name          varchar2(80);
  x_agent_name          varchar2(30);
  x_dequeue_options     dbms_aq.dequeue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  no_messages           exception;
  pragma exception_init (no_messages, -25228);
  --Define the snapshot too old error
  snap_too_old exception;
  pragma exception_init(snap_too_old, -1555);

begin
  select upper(queue_name), upper(name)
  into   x_queue_name, x_agent_name
  from   wf_agents
  where  guid = p_agent_guid;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_QH.dequeue.Begin',
                      'Dequeuing '||x_queue_name||' on '||x_agent_name);
  end if;

  -- Set correlation Id for dequeue if only available and not '%'
  if (wf_event.g_correlation is not null  and wf_event.g_correlation <> '%') then
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
                         'wf.plsql.WF_EVENT_QH.dequeue.corrid',
                         'Dequeuing with Correlation ' || x_dequeue_options.correlation);
     else
        wf_log_pkg.string(wf_log_pkg.level_procedure,
                         'wf.plsql.WF_EVENT_QH.dequeue.corrid',
                         'Dequeuing with No Correlation');
     end if;
  end if;

  if ((WF_EVENT.g_queueType is NULL) or
      (WF_EVENT.g_queueType <> 'EXCEPTION_QUEUE')) then
         x_dequeue_options.consumer_name := x_agent_name;
  end if;

  -- This functionality is dependent on 9i, so it cannot be uncommented in this
  -- file until 9i is the minimum rdbms on both e-business suite and iAS.
  --
  --  if (WF_EVENT.g_deq_condition is not NULL) then
  --   x_dequeue_options.deq_condition := WF_EVENT.g_deq_condition;
  --
  --  end if;
  --

  x_dequeue_options.wait          := p_wait;
  x_dequeue_options.navigation    := wf_event.getQueueNavigation;


  BEGIN
    DBMS_AQ.DEQUEUE(queue_name         => x_queue_name,
                    dequeue_options    => x_dequeue_options,
                    message_properties => x_message_properties, /* OUT */
                    payload            => p_event,              /* OUT */
                    msgid              => x_msgid);             /* OUT */

--    wf_event.navigation := dbms_aq.next_message;
  EXCEPTION
    when no_messages then
      if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_event,
                          'wf.plsql.WF_EVENT_QH.dequeue.queue_empty',
                          'No more messages in dequeue.');
      end if;

      -- reset navigation
      wf_event.resetNavigationParams;
      p_event := NULL;
      return;
    --Capture the snapshot too old error
    when snap_too_old then
        -- reset navigation
        wf_event.resetNavigationParams;
        x_dequeue_options.navigation := wf_event.getQueueNavigation;
        DBMS_AQ.DEQUEUE(queue_name         => x_queue_name,
                        dequeue_options    => x_dequeue_options,
                        message_properties => x_message_properties, /* OUT */
                        payload            => p_event,              /* OUT */
                        msgid              => x_msgid);             /* OUT */


    when others then
        raise;
  END;

  -- Set the Receive Date
  p_event.SetReceiveDate(sysdate);
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_QH.dequeue.End',
                      'Finished');
  end if;
exception
  when others then
    Wf_Core.Context('Wf_Event_QH', 'Dequeue', x_queue_name,
                     'SQL err is '||substr(sqlerrm,1,200));
    raise;
end dequeue;
------------------------------------------------------------------------------
PROCEDURE enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t default null)
is
  x_out_agent_name      varchar2(30);
  x_out_system_name     varchar2(30);
  x_to_agent_name       varchar2(30);
  x_to_system_name      varchar2(30);
  x_out_queue           varchar2(80);
  x_to_queue		varchar2(80);
  x_enqueue_options     dbms_aq.enqueue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  x_name                varchar2(30);
  x_address             varchar2(1024);
  x_protocol            varchar2(30);
  x_protocol_num        number := 0;
  delay			number := 0;

  l_q_correlation_id   varchar2(240);

  --Bug 2676549
  --Cursor to select the to_agents for the recipient list
CURSOR   recipients(agent_name varchar2,system_name varchar2) is
  select agt2.name ,agt2.address, agt2.protocol, agt2.queue_name
  from   wf_agent_groups agp ,
         wf_agents agt1 ,
         wf_agents agt2 ,
         wf_systems sys
  where  agt1.name      =  agent_name
  and    agp.group_guid =  agt1.guid
  and    agt1.type      = 'GROUP'
  and    agt1.status    = 'ENABLED'
  and    agt2.guid      =  agp.member_guid
  and    sys.name       =  system_name
  and    sys.guid       =  agt2.system_guid;

  i      number  := 1;
  x_type  varchar2(8);
begin
  -- Determine the out queue --
  if (p_out_agent_override is not null) then
    x_out_agent_name := p_out_agent_override.GetName();
    x_out_system_name := p_out_agent_override.GetSystem();
  else
    x_out_agent_name := p_event.From_Agent.Name;
    x_out_system_name := p_event.From_Agent.System;
  end if;

  -- Get Out Agent details --
  select agt.queue_name into x_out_queue
  from   wf_agents  agt,
         wf_systems sys
  where  agt.name = x_out_agent_name
  and    sys.name = x_out_system_name
  and    sys.guid = agt.system_guid;

  -- Determine the to queue (if set) --
  -- If there is a to queue, need to set recipient list address --
  if (p_event.To_Agent is not null) AND
  (x_out_agent_name <> 'WF_DEFERRED') then
        WF_EVENT.Set_Recipient_List(p_event,
                                    x_out_agent_name ,
                                    x_out_system_name,
                                    x_message_properties);
  end if;

  /*
  ** Set the Priority
  */
  x_message_properties.priority := p_event.Priority;

  /*
  ** Set the Delay if required, also used for Deferred Agent
  */
  if (p_event.Send_Date > sysdate) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_QH.enqueue.delay',
                        'Delay Detected');
    end if;

    delay := (p_event.Send_Date - sysdate) *24*60*60;

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_QH.enqueue.delay_time',
                        'Delay ='||to_char(delay));
    end if;

    if delay > 1 then
    -- message_properties.delay is BINARY_INTEGER, so check if delay is
    -- too big, and set the max delay to be (2**31)-1.
      if (delay >= power(2,31)) then
        x_message_properties.delay := power(2,31)-1;
      else
        x_message_properties.delay := delay;
      end if;
    end if;
  end if;

  /*
  ** if we are enqueuing for an internal agent, must set the account name
  ** into the correlation id
  */
  if (x_out_agent_name like 'WF_%'
      or x_to_agent_name like 'WF_%') then
    if wf_event.account_name is null then
      wf_event.SetAccountName;
    end if;
    x_message_properties.correlation := wf_event.account_name;
  end if;
  if (x_out_agent_name = 'WF_DEFERRED'
      or x_to_agent_name = 'WF_DEFERRED') then
    --Bug 2505492
    --Append the event name to the correlation id for DEFERRED/ERROR agent.
    --We have a separate queue handler for WF_ERROR
    l_q_correlation_id := p_event.event_name;
  else
    --Bug 3992967
    --For application agents (agents other than DEFERRED or ERROR),
    --correlation id should be extracted from Q_CORRELATION_ID
    l_q_correlation_id := p_event.getValueForParameter('Q_CORRELATION_ID');

  end if;

  IF (l_q_correlation_id IS NOT NULL) THEN
     -- If account name is set, append account name in front of correlation id.
     if (x_message_properties.correlation is not null) then
        x_message_properties.correlation := x_message_properties.correlation ||
                                            ':' || l_q_correlation_id;
     else
        x_message_properties.correlation := l_q_correlation_id;
     end if;
   END IF;
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_QH.enqueue.dbms_aq',
                      'calling dbms_aq.enqueue');
  end if;

  DBMS_AQ.ENQUEUE(
   queue_name          => x_out_queue,
   enqueue_options     => x_enqueue_options,
   message_properties  => x_message_properties,
   payload             => p_event,
   msgid               => x_msgid);             /* OUT*/

  --<rwunderl:2699059> Storing the msgid.
  WF_EVENT.g_msgid := x_msgid;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_QH.enqueue.End',
                      'finished calling dbms_aq.enqueue');
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Event_QH', 'Enqueue', x_out_queue,
                     'SQL err is '||substr(sqlerrm,1,200));
    raise;
end enqueue;
------------------------------------------------------------------------------
end WF_EVENT_QH;

/
