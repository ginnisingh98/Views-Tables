--------------------------------------------------------
--  DDL for Package Body WF_BES_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_BES_CLEANUP" as
/* $Header: WFBESCUB.pls 120.4 2005/11/07 06:33:28 nravindr noship $ */

-- the maximum amount of time pings will be retained (days)

G_MAX_RETENTION_TIME constant number := 30;  -- 30 days

-- the minimum amount of time which must elapse before this procedure will
-- run again (days)

G_MIN_WAIT_TIME constant number := 30/(60*24);  -- 30 min

-- status to indicate that the subscriber was pinged

STATUS_PINGED constant varchar2(30) := 'PINGED';

-- status to indicate that a subscriber responded to a ping

STATUS_RESPONDED constant varchar2(30) := 'RESPONDED';

-- status to indicate that a subscriber was removed

STATUS_REMOVED constant varchar2(30) := 'REMOVED';

-- status to indicate that an attempt to remove a subscriber failed

STATUS_REMOVE_FAILED constant varchar2(30) := 'REMOVE_FAILED';

-- return code to indicate success

RETURN_SUCCESS constant varchar2(30) := 0;

-- return code to indicate warning

RETURN_WARNING constant varchar2(30) := 1;

-- return code to indicate error

RETURN_ERROR constant varchar2(30) := 2;

--------------------------------------------------------------------------------
procedure acknowledge_ping(p_ping_number     in number,
                           p_queue_name      in varchar2,
                           p_subscriber_name in varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
   update wf_bes_subscriber_pings
   set status = STATUS_RESPONDED,
       action_time = sysdate
   where ping_number = p_ping_number
   and queue_name = p_queue_name
   and subscriber_name = p_subscriber_name;

   commit;
exception
   when others then
      rollback;
end acknowledge_ping;

--------------------------------------------------------------------------------
-- Pings a subscriber.
--
-- p_ping_number - the ping number
-- p_ping_time - the ping time
-- p_queue_name - the queue name
-- p_subscriber_name - the subscriber_name
--------------------------------------------------------------------------------
procedure ping_subscriber(p_ping_number     in number,
                          p_ping_time       in date,
                          p_queue_name      in varchar2,
                          p_subscriber_name in varchar2)
is
begin
   insert into wf_bes_subscriber_pings
   (
      ping_number,
      ping_time,
      queue_name,
      subscriber_name,
      status,
      action_time
   )
   values
   (
      p_ping_number,
      p_ping_time,
      p_queue_name,
      p_subscriber_name,
      STATUS_PINGED,
      p_ping_time
   );
end ping_subscriber;
--------------------------------------------------------------------------------
procedure dequeue_jms_queue(p_queue_name in VARCHAR2,
                            p_consumer_name in VARCHAR2,
                            p_navigation    in binary_integer,
                            p_correlation   in VARCHAR2,
                            x_have_msg      out nocopy boolean)
is
    l_dequeue_options     dbms_aq.dequeue_options_t;
    x_message_properties  dbms_aq.message_properties_t;
    x_msgid               RAW(16);
    x_payload             SYS.AQ$_JMS_TEXT_MESSAGE;
    no_messages           exception;
    pragma exception_init(no_messages, -25228);
    snap_too_old exception;
    pragma exception_init(snap_too_old, -1555);
begin
    l_dequeue_options.consumer_name := p_consumer_name;
    l_dequeue_options.wait          := dbms_aq.NO_WAIT;
    l_dequeue_options.dequeue_mode  := dbms_aq.remove_nodata;
    l_dequeue_options.navigation := p_navigation;
    l_dequeue_options.correlation := p_correlation;

    x_have_msg := true;
    dbms_aq.dequeue(queue_name         => p_queue_name,
                    dequeue_options    => l_dequeue_options,
                    message_properties => x_message_properties, -- out
                    payload            => x_payload,   -- out
                    msgid              => x_msgid);             -- out
exception
    when no_messages then
        x_have_msg := false;
    when snap_too_old then
        if (p_navigation = DBMS_AQ.NEXT_MESSAGE) then
            begin
                l_dequeue_options.navigation := dbms_aq.first_message;
                dbms_aq.dequeue(queue_name         => p_queue_name,
                                dequeue_options    => l_dequeue_options,
                                message_properties => x_message_properties, -- out
                                payload            => x_payload,   -- out
                                msgid              => x_msgid);             -- out
            exception
                when no_messages then
                    x_have_msg := false;
            end;
        else
            raise;
        end if;
end dequeue_jms_queue;
--------------------------------------------------------------------------------
procedure dequeue_evt_queue(p_queue_name in VARCHAR2,
                            p_consumer_name in VARCHAR2,
                            p_navigation    in binary_integer,
                            p_correlation   in VARCHAR2,
                            x_have_msg      out nocopy boolean)
is
    l_dequeue_options     dbms_aq.dequeue_options_t;
    x_message_properties  dbms_aq.message_properties_t;
    x_payload             WF_EVENT_T;
    x_msgid               RAW(16);
    no_messages           exception;
    pragma exception_init(no_messages, -25228);
    snap_too_old exception;
    pragma exception_init(snap_too_old, -1555);
begin
    l_dequeue_options.consumer_name := p_consumer_name;
    l_dequeue_options.wait          := dbms_aq.NO_WAIT;
    l_dequeue_options.dequeue_mode  := dbms_aq.remove_nodata;
    l_dequeue_options.navigation := p_navigation;
    l_dequeue_options.correlation := p_correlation;

    x_have_msg := true;
    dbms_aq.dequeue(queue_name         => p_queue_name,
                    dequeue_options    => l_dequeue_options,
                    message_properties => x_message_properties, -- out
                    payload            => x_payload,   -- out
                    msgid              => x_msgid);             -- out
exception
    when no_messages then
        x_have_msg := false;
    when snap_too_old then
        if (p_navigation = DBMS_AQ.NEXT_MESSAGE) then
            begin
                l_dequeue_options.navigation := dbms_aq.first_message;
                dbms_aq.dequeue(queue_name         => p_queue_name,
                                dequeue_options    => l_dequeue_options,
                                message_properties => x_message_properties, -- out
                                payload            => x_payload,   -- out
                                msgid              => x_msgid);             -- out
            exception
                when no_messages then
                    x_have_msg := false;
            end;
        else
            raise;
        end if;
end dequeue_evt_queue;
--------------------------------------------------------------------------------
procedure purge_jms_queue(p_queue_name in VARCHAR2,
                          p_consumer_name in VARCHAR2 default null,
                          p_correlation in VARCHAR2 default null,
                          p_commit_frequency in NUMBER default 100)

is
    x_have_msg boolean := true;
    l_xcount   NUMBER  := 0;
    l_navigation binary_integer := dbms_aq.first_message;
begin
    while (x_have_msg) loop
        dequeue_jms_queue(p_queue_name => p_queue_name,
                          p_consumer_name => p_consumer_name,
                          p_navigation    => l_navigation,
                          p_correlation   => p_correlation,
                          x_have_msg      => x_have_msg);
        l_xcount := l_xcount + 1;
        if (l_xcount >= p_commit_frequency) then
            commit;
            l_xcount := 0;
        end if;
        l_navigation := dbms_aq.next_message;
    end loop;
    commit;
end purge_jms_queue;
--------------------------------------------------------------------------------
procedure purge_evt_queue(p_queue_name in VARCHAR2,
                          p_consumer_name in VARCHAR2 default null,
                          p_correlation in VARCHAR2 default null,
                          p_commit_frequency in NUMBER default 100)

is
    x_have_msg boolean := true;
    l_xcount   NUMBER  := 0;
    l_navigation binary_integer := dbms_aq.first_message;
begin
    while (x_have_msg) loop
        dequeue_evt_queue(p_queue_name => p_queue_name,
                          p_consumer_name => p_consumer_name,
                          p_navigation    => l_navigation,
                          p_correlation   => p_correlation,
                          x_have_msg      => x_have_msg);
        l_xcount := l_xcount + 1;
        if (l_xcount >= p_commit_frequency) then
            commit;
            l_xcount := 0;
        end if;
        l_navigation := dbms_aq.next_message;
    end loop;
    commit;
end purge_evt_queue;
---------------------------------------------------------------------------------
-- Removes a subscriber from a queue.
--
-- p_owner - the owner (schema) of the queue
-- p_queue_name - the queue name
-- p_subscriber_name - the subscriber_name
-- p_status - the return status
--------------------------------------------------------------------------------
procedure remove_subscriber(p_owner           in varchar2,
                            p_queue_name      in varchar2,
                            p_subscriber_name in varchar2,
                            p_status          out nocopy varchar2)
is
begin

   -- Purge the queue for this subscriber.
   purge_jms_queue(p_queue_name => p_owner || '.' || p_queue_name,
                   p_consumer_name => p_subscriber_name);
   -- remove the subscriber from the queue

   dbms_aqadm.remove_subscriber(
      queue_name => p_owner || '.' || p_queue_name,
      subscriber => sys.aq$_agent(p_subscriber_name, null, null));

   -- mark the subscriber removed

   update wf_bes_subscriber_pings
   set status = STATUS_REMOVED,
       action_time = sysdate
   where queue_name = p_queue_name
   and subscriber_name = p_subscriber_name
   and status = STATUS_PINGED;

   if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.LEVEL_PROCEDURE,
                       'wf.plsql.wf_bes_cleanup.remove_subscriber.done',
                       'Removed subscriber '||p_owner ||'.'||p_queue_name||'.'||
                       p_subscriber_name);
   end if;
   commit;
   p_status := RETURN_SUCCESS;
exception
   when others then
      -- the attempt to remove the subscriber failed

      update wf_bes_subscriber_pings
      set status = STATUS_REMOVE_FAILED,
          action_time = sysdate
      where queue_name = p_queue_name
      and subscriber_name = p_subscriber_name
      and status = STATUS_PINGED;

      if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.LEVEL_UNEXPECTED,
                          'wf.plsql.wf_bes_cleanup.remove_subscriber.error',
                          'Failed to remove subscriber ' || p_owner || '.' || p_queue_name || '.' ||
                           p_subscriber_name);
      end if;
      commit;
      p_status := RETURN_ERROR;
end remove_subscriber;
--------------------------------------------------------------------------------
PROCEDURE GetQueueDetails(p_agent_name in varchar2,
                            x_queue_table OUT NOCOPY VARCHAR2,
                            x_exception_queue OUT NOCOPY VARCHAR2,
                            x_owner       OUT NOCOPY VARCHAR2,
                            x_queue_name  OUT NOCOPY VARCHAR2)
is
    l_queue_name     varchar2(80);
    l_recipients     varchar2(30);
    l_pos            number := 0;
    l_name           varchar2(30) := null;
    l_owner          varchar2(30) := null;
    l_queue_table    VARCHAR2(30) := null;
    l_exception_queue VARCHAR2(80) := null;
begin

    select queue_name
    INTO   l_queue_name
    from   wf_agents
    where  name = p_agent_name
    and    system_guid = WF_EVENT.local_system_guid;

    if(l_queue_name is not null) then
      -- derive the queue name and the schema
      l_pos := instr(l_queue_name,'.');
      l_name := substr(l_queue_name, l_pos + 1);

      if (l_pos > 0) then
        l_owner := substr(l_queue_name, 1, l_pos - 1);
      else
        -- if queue_name does not contain schema we will look in WF_SCHEMA
        l_owner := wf_event.schema_name;
      end if;

      SELECT queue_table
      into l_queue_table
      from all_queues
      where owner = l_owner
      and   name  = l_name;

      -- If default exception queue table, should be l_owner || '.AQ$_' || l_queue_table || '_E'
      -- We can't select the queue name given the queue name and queue_type = 'EXCEPTION_QUEUE',
      -- because it can have multiple result. Shall we have a column in WF_AGENTS for exception queue?
      l_exception_queue := l_owner || '.AQ$_' || l_queue_table || '_E';
      x_queue_table := l_queue_table;
      x_exception_queue := l_exception_queue;
      x_owner := l_owner;
      x_queue_name  := l_name;
    else
        raise no_data_found;
    end if;
end GetQueueDetails;

--------------------------------------------------------------------------------
procedure cleanup_subscribers(errbuf  out nocopy varchar2,
                              retcode out nocopy varchar2)
is
   -- the dead subscribers

   -- A subscriber is dead if
   -- 1. more than G_MIN_WAIT_TIME has elapsed since it was pinged and
   -- 2. its status is still STATUS_PINGED

   -- If the subscriber were alive, it would have responded and its status
   -- would be STATUS_RESPONDED.

   cursor dead_subscribers is
      select distinct queue_name, subscriber_name
      from wf_bes_subscriber_pings
      where ping_time < sysdate - G_MIN_WAIT_TIME
      and status = STATUS_PINGED;

   l_owner varchar2(30);
   l_queue_name varchar2(30);
   l_last_ping_time date;
   l_ping_time date;
   l_ping_number number;
   l_remove_failed_count number;
   l_remove_status varchar2(30);
   l_subscribers dbms_aqadm.aq$_subscriber_list_t;
   i integer;
begin
   -- get the last ping time

   select max(ping_time)
   into l_last_ping_time
   from wf_bes_subscriber_pings;

   if(l_last_ping_time is null) then
      -- wf_bes_subscriber_pings table is empty so set the last ping time to be very old

      l_last_ping_time := to_date('1900/01/01', 'YYYY/MM/DD');
   end if;

   -- check the minimum wait time

   if(l_last_ping_time < sysdate - G_MIN_WAIT_TIME) then
      -- the minimum wait time has elapsed so perform cleanup processing

      -- get the owner and queue name of the WF_CONTROL agent

      declare
         l_qualified_queue_name wf_agents.queue_name%type;
         j integer;
      begin
         select queue_name
         into l_qualified_queue_name
         from wf_agents
         where name = 'WF_CONTROL'
         and system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

         -- l_qualified_queue_name is of the form <schema>.<queue name>

         -- parse it into owner (schema) and queue name

         j := instr(l_qualified_queue_name, '.');

         l_owner := substr(l_qualified_queue_name, 1, j - 1);
         l_queue_name := substr(l_qualified_queue_name, j + 1);
      exception
         when no_data_found then
            -- WF_CONTROL agent does not exist

            errbuf := 'WF_CONTROL agent not found';

            retcode := RETURN_ERROR;

            return;
      end;


      -- remove the dead subscribers

      l_remove_failed_count := 0;

      for dead_subscriber in dead_subscribers loop
         remove_subscriber(p_owner           => l_owner,
                           p_queue_name      => dead_subscriber.queue_name,
                           p_subscriber_name => dead_subscriber.subscriber_name,
                           p_status          => l_remove_status);

         if(l_remove_status = RETURN_ERROR) then
            l_remove_failed_count := l_remove_failed_count + 1;
         end if;
      end loop;

      -- After remove the subscribers, remove all the messages that got moved to exception queue
      purge_jms_queue(p_queue_name => l_owner || '.AQ$_WF_CONTROL_E');
      -- ping the current subscribers
      l_subscribers := dbms_aqadm.queue_subscribers(l_owner || '.' || l_queue_name);

      if(l_subscribers.count() > 0) then
         -- a subscriber exists

         -- get the next ping number

         select wf_bes_ping_number_s.nextval
         into l_ping_number
         from dual;

         -- get the ping time (current time)

         l_ping_time := sysdate;

         -- ping the current subscribers

         i := l_subscribers.first;

         while i is not null loop
            ping_subscriber(p_ping_number     => l_ping_number,
                            p_ping_time       => l_ping_time,
                            p_queue_name      => l_queue_name,
                            p_subscriber_name => l_subscribers(i).name);

            i := l_subscribers.next(i);
         end loop;

         -- raise the ping event

         wf_event.raise(p_event_name => 'oracle.apps.wf.bes.control.ping',
                        p_event_key  => l_ping_number);
      end if;

      -- remove the data older than G_MAX_RETENTION_TIME

      delete
      from wf_bes_subscriber_pings
      where ping_time < sysdate - G_MAX_RETENTION_TIME;

      commit;

      if(l_remove_failed_count > 0) then
         -- at least one dead subscriber could not be removed

         errbuf := 'Failed to remove ' || l_remove_failed_count || ' dead subscriber(s).';

         retcode := RETURN_WARNING;
      else
         -- normal completion

         retcode := RETURN_SUCCESS;
      end if;
   else
      -- the minimum wait time has not yet elapsed so just return

      retcode := RETURN_SUCCESS;
   end if;
end cleanup_subscribers;

end wf_bes_cleanup;

/
