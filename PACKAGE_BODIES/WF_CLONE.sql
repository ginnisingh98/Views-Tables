--------------------------------------------------------
--  DDL for Package Body WF_CLONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_CLONE" as
/* $Header: wfcloneb.pls 120.1 2005/07/02 03:42:45 appldev noship $ */

procedure UpdateAttrValues(WEB_HOST in  varchar2,
                           DOMAIN   in varchar2,
                           WEB_PORT in varchar2,
                           SID      in varchar2,
			   URL_PROTO in varchar2 )
is
  source_web_agent    varchar2(2000);
  target_web_agent    varchar2(2000);
  l_url_proto	      varchar2(20);
begin

 if URL_PROTO IS NULL then
 	l_url_proto	 := 'http';
 else
	 l_url_proto      := URL_PROTO;
 end if;

 target_web_agent := l_url_proto||'://'||WEB_HOST||'.'||DOMAIN||':'||WEB_PORT||'/pls/'||SID||'/';

 --Select source agent
 select    text
 into      source_web_agent
 from      wf_resources
 where     name = 'WF_WEB_AGENT'
 and       language = 'US';

 --Check if there is a trailing '/' in the web_agent
 --If not add the trailing '/'
 if (instr(substr(source_web_agent,length(source_web_agent)),'/') = 0) then
   source_web_agent := source_web_agent||'/';
 end if;


 --For item attributes values
 update    WF_ITEM_ATTRIBUTE_VALUES wiav
 set       wiav.text_value =
              replace(wiav.text_value,source_web_agent,target_web_agent)
 where    (wiav.item_type, wiav.name) =
             (select wia.item_type, wia.name
              from WF_ITEM_ATTRIBUTES wia
              where wia.type = 'URL'
              and   wia.item_type = wiav.item_type
              and   wia.name = wiav.name)
 and       wiav.text_value is not null
 and       instr(wiav.text_value,source_web_agent) > 0 ;


 --For default item attribute values
 update       WF_ITEM_ATTRIBUTES
 set             text_default = replace(text_default,source_web_agent,target_web_agent)
 where         type ='URL'
 and            text_default is not null
 and           instr(text_default,source_web_agent) > 0 ;


 --Default activity attribute
 update wf_activity_attributes
 set text_default = replace(text_default,source_web_agent,target_web_agent)
 where type ='URL'
 and text_default is not null
 and instr(text_default,source_web_agent)> 0;

 --Activity attribute value
 update wf_activity_attr_values waav
 set  waav.text_value = replace(waav.text_value,source_web_agent,target_web_agent)
 where   (waav.process_activity_id,waav.name) =(
  select wpa.instance_id ,waa.name
  from   wf_process_activities wpa,wf_activity_attributes waa
  where  waa.activity_item_type = wpa.activity_item_type
  and     waa.activity_name = wpa.activity_name
  and     wpa.instance_id = waav.process_activity_id
  and     waa.name        = waav.name
  and     waa.activity_version = wpa.process_version
  and     waa.type   = 'URL')
 and     waav.text_value is not null
 and     waav.value_type  = 'CONSTANT'
 and    instr(text_value,source_web_agent) > 0;


 --Notification attributes
 update     wf_notification_attributes
 set          TEXT_VALUE = replace(text_value,source_web_agent,target_web_agent)
 where      instr(text_value,source_web_agent)> 0;

 --Message attributes
 update     wf_message_attributes
 set          text_default = replace(text_default,source_web_agent,target_web_agent)
 where      type='URL'
 and         value_type = 'CONSTANT'
 and         text_default is not null
 and         instr(text_default,source_web_agent) > 0;

 --Reset the cache
 begin
   --The execute immediate is used so that it doesn't fail
   --when wf_cache pkg does not exist.
   execute immediate 'begin WF_CACHE.Reset(); end;';
 exception
     when others then
       null;
 end;

exception
    when others then
     raise_application_error(-20000, 'Error : WF_CLONE.UpdateAttrValues -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;



procedure UpdateSysGuid as
source_guid   raw(16);
target_guid   raw(16);
source_name   VARCHAR2(30);
target_name   VARCHAR2(30);
begin

 savepoint wf_update_guid;

 select   text
 into     source_guid
 from      wf_resources
 where    name = 'WF_SYSTEM_GUID'
 and      language = 'US';

 --Get a global unique identifier here
 target_guid := sys_guid();

 --Now set this value for the sysguid in wf_resources
 update    wf_resources
 set       text = target_guid
 where     name = 'WF_SYSTEM_GUID';

 --Get the global name of source to replace
 --the address in wf_agents
 select    name
 into      source_name
 from      wf_systems
 where     guid = source_guid;

 --Get the global_name of target
 select     global_name
 into       target_name
 from       global_name;

 --Now replace the agent address with the
 --target global name.

 update wf_agents
 set    address = substr(address,1,instr(address,'@',1))||target_name
 where  address = substr(address,1,instr(address,'@',1))||source_name;

 --Update system guid references in wf_agents
 update    wf_agents
 set       system_guid = target_guid
 where     system_guid = source_guid;

 --Update system guid references in event subscription tables
 update    wf_event_subscriptions
 set       SYSTEM_GUID = target_guid
 where     SYSTEM_GUID = source_guid;

 --Update wf_system table
 update   wf_systems
 set      name = target_name
 where    name = source_name;

 --Update system guid
 update   wf_systems
 set      guid = target_guid
 where    guid = source_guid;

exception
  when others then
   --Rollback any exception
   rollback to wf_update_guid;
   raise_application_error(-20000, 'Error : WF_CLONE.UpdateSysGuid -: Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;

procedure UpdateMailer(WEB_HOST in  varchar2,
                       DOMAIN   in varchar2,
                       WEB_PORT in varchar2,
                       SID      in varchar2,
		       URL_PROTO in varchar2 )
is
source_web_agent  varchar2(2000);
 l_url_proto	      varchar2(20);
begin

 --Select source agent
 select    text
 into      source_web_agent
 from      wf_resources
 where     name = 'WF_WEB_AGENT'
 and       language = 'US';


 if URL_PROTO IS NULL then
 	l_url_proto	 := 'http';
 else
	 l_url_proto      := URL_PROTO;
 end if;
 --The mailer parameter should be the WEB_AGENT name
 --Update HTML agent
 update    wf_mailer_parameters
 set       VALUE = l_url_proto||'://'||WEB_HOST||'.'||DOMAIN||':'||WEB_PORT||'/pls/'||SID
 where     parameter = 'HTMLAGENT';

 --Update replyto with new host name
 update    wf_mailer_parameters
 set       VALUE = substr(VALUE,1,instr(VALUE,'@'))||DOMAIN
 where     parameter = 'REPLYTO';

exception
  when others then
  raise_application_error(-20000, 'Error : WF_CLONE.UpdateMailer -: Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;


--This would be called only last in the template as we
--do not have the source data stored anywhere else.
procedure UpdateResource(WEB_HOST in  varchar2,
                         DOMAIN   in varchar2,
                         WEB_PORT in varchar2,
                         SID      in varchar2,
			 URL_PROTO in varchar2 )
is
 target_web_agent    varchar2(2000);
 l_url_proto	      varchar2(20);
begin

 if URL_PROTO IS NULL then
 	l_url_proto	 := 'http';
 else
	 l_url_proto      := URL_PROTO;
 end if;

 target_web_agent :=  l_url_proto||'://'||WEB_HOST||'.'||DOMAIN||':'||WEB_PORT||'/pls/'||SID;

 --Update the target webagent.
 update     wf_resources
 set        text = target_web_agent
 where      name = 'WF_WEB_AGENT';

exception
  when others then
   raise_application_error(-20000, 'Error : WF_CLONE.UpdateResource -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;

Function    DetermineClone(WEB_HOST in  varchar2,
                           DOMAIN   in varchar2,
                           WEB_PORT in varchar2,
                           SID      in varchar2,
			   URL_PROTO in varchar2 )
return boolean is
target_agent       varchar2(2000);
source_agent       varchar2(2000);
 l_url_proto	      varchar2(20);
begin

  begin
   select       text
   into         source_agent
   from         wf_resources
   where        name  = 'WF_WEB_AGENT'
   and          language = 'US';
  exception
   when no_data_found then
     --Install has not seeded the token WF_WEB_AGENT,
     --return false here
     return false;
  end;

  --Get the target agent
   if URL_PROTO IS NULL then
 	l_url_proto	 := 'http';
  else
	 l_url_proto      := URL_PROTO;
  end if;


  target_agent  := l_url_proto||'://'||WEB_HOST||'.'||DOMAIN||':'||WEB_PORT||'/pls/'||SID;

  --Now check if source = target . If so skip calling the clone
  --APIs and exit off
  if ((source_agent = target_agent) OR
      (rtrim(source_agent,'/') = target_agent)) then
    return false;
  else
    return true;
  end if;

end ;

--Procedure Clone
--This API calls all the cloning related APIs
--This will be invoked by the concurrent program
Procedure WFClone(P_WEB_HOST    in  varchar2,
                P_DOMAIN      in  varchar2,
                P_WEB_PORT    in  varchar2,
                P_SID         in  varchar2,
		P_URL_PROTO   in varchar2)
is
begin
  wf_clone.UpdateAttrValues(p_web_host,p_domain, p_web_port,p_sid,p_url_proto);
  wf_clone.UpdateSysGuid;
  wf_clone.UpdateMailer(p_web_host, p_domain, p_web_port,p_sid,p_url_proto );
  wf_clone.UpdateResource(p_web_host,p_domain, p_web_port,p_sid,p_url_proto );
exception
 when others then
  raise;
end;

procedure purgedata
is
l_owner   varchar2(30);
cursor queue_curs is
  select  queue_name , name
  from    wf_agents
  where   type ='AGENT';

begin
 --WF Tables we depend are created in the schema given by the token
 --wf_schema
 l_owner := wf_core.translate('WF_SCHEMA');

 --Truncate run-time data tables
 TruncateTable('wf_notifications',l_owner);
 TruncateTable('WF_ATTRIBUTE_CACHE',l_owner);
 TruncateTable('WF_ITEM_ACTIVITY_STATUSES',l_owner);
 TruncateTable('WF_ITEM_ACTIVITY_STATUSES_H',l_owner);
 TruncateTable('WF_ITEM_ATTRIBUTE_VALUES' ,l_owner);
 TruncateTable('WF_NOTIFICATION_ATTRIBUTES',l_owner);
 TruncateTable('WF_ITEMS',l_owner);

 --Clear Cache off
 begin
   --The execute immediate is used so that it doesn't fail
   --when wf_cache pkg does not exist.
   execute immediate 'begin wf_cache.clear; end;';
 exception
   when others then
     null;
 end;

for q_curs in queue_curs loop
   begin
     wf_clone.QDequeue(substr(q_curs.queue_name,instr(q_curs.queue_name,'.')+1),substr(q_curs.queue_name,1,instr(q_curs.queue_name,'.')-1),q_curs.name,true);
   exception
    when others then
      null;
   end;
end loop;

--Now clear the background queues
wf_clone.QDequeue('WF_DEFERRED_QUEUE_M',l_owner);
wf_clone.QDequeue('WF_INBOUND_QUEUE',l_owner);
wf_clone.QDequeue('WF_OUTBOUND_QUEUE',l_owner);

exception
  when others then
  raise_application_error(-20000, 'Error : WF_CLONE.PurgeData -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;


--Generic API to trucate runtime data tables
--A seperate API will allow more flexibility
PROCEDURE TruncateTable (TableName      IN     VARCHAR2,
                         Owner          IN     VARCHAR2,
                         raise_error    IN     BOOLEAN )  is

  tableNotFound EXCEPTION;
  pragma exception_init(tableNotFound, -942);
BEGIN
    execute IMMEDIATE 'truncate table '||Owner||'.'||TableName;

EXCEPTION
  when tableNotFound then
    if (raise_error) then
      null;
    else
      raise_application_error(-20000, 'Error : WF_CLONE.TruncateTable -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
    end if;
  when OTHERS then
   raise_application_error(-20000, 'Error : WF_CLONE.TruncateTable -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;

--Truncate Queue Table
PROCEDURE QTableTruncate(QName      IN     VARCHAR2,
                      raise_error    IN     BOOLEAN )
is
l_owner     varchar2(30);
l_queue_tab varchar2(30);
tableNotFound EXCEPTION;
pragma exception_init(tableNotFound, -942);

begin
  /* This code is not used
     so commenting it off for bug #3548589

  select      que.queue_table , que.owner
  into        l_queue_tab , l_owner
  from        all_queues que
  where       que.name = QTableTruncate.QName ;

  execute IMMEDIATE 'truncate table '||l_Owner||'.'||l_queue_tab;
  */
  --Any day AQ allows truncation this will be faster than
  --dequeue.
  null;

exception
  when tableNotFound then
    if (raise_error) then
      null;
    else
      raise_application_error(-20000, 'Error : WF_CLONE.TruncateTable -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
    end if;
  when OTHERS then
   raise_application_error(-20000, 'Error : WF_CLONE.TruncateTable -:Oracle Error = '||to_char(sqlcode)||' -'||sqlerrm);
end;

PROCEDURE CLONE(errbuf        out NOCOPY varchar2,
                     retcode       out NOCOPY varchar2,
                     P_WEB_HOST      in  varchar2,
                     P_DOMAIN        in varchar2,
                     P_WEB_PORT      in varchar2,
                     P_SID           in varchar2,
		     P_URL_PROTO     in varchar2 )
is
l_clonable boolean;
begin
  --Lets call DetermineClone to avoid unnecessary update
  l_clonable := determineClone(P_WEB_HOST,P_DOMAIN,P_WEB_PORT,P_SID,P_URL_PROTO);
  if l_clonable then
    wf_clone.WFClone(P_WEB_HOST,P_DOMAIN,P_WEB_PORT,P_SID,P_URL_PROTO);
  end if;

 retcode := '0';                     -- (successful completion)
 errbuf  := '';

exception
  when others then
    retcode := '2';                   -- (error)
    errbuf  := sqlerrm;
end;

PROCEDURE QDequeue(QName          IN     VARCHAR2,
                   owner          in      VARCHAR2,
                   AgtName        IN    VARCHAR2,
                   raise_error    IN     BOOLEAN default FALSE )
is
 dequeue_timeout exception;
 pragma EXCEPTION_INIT(dequeue_timeout, -25228);

 dequeue_disabled exception;
 pragma EXCEPTION_INIT(dequeue_disabled, -25226);

 dequeue_outofseq exception;
 pragma EXCEPTION_INIT(dequeue_outofseq, -25237);

 no_queue exception;
 pragma EXCEPTION_INIT(no_queue, -24010);

 multiconsumer_q exception;
 pragma EXCEPTION_INIT(multiconsumer_q, -25231);

 l_commit_level integer := 500;    --commit frequency default to 500
 l_timeout      integer;
 l_queue_name   varchar2(200);     --queue name

 l_deq integer;       -- dequeue count
 l_xcount integer;    -- commit frequency

 --Message Properties
 l_dequeue_options dbms_aq.dequeue_options_t;
 l_message_properties dbms_aq.message_properties_t;
 l_message_handle RAW(16) := NULL;
 l_payload wf_event_t;
 l_consumer     varchar2(100);
 l_msgid        RAW(16);
 type wait_message is ref cursor;
 wait_msg     wait_message ;
 l_sql   varchar2(4000);
 l_qTable varchar2(30);

begin

   l_timeout     := 0;
   l_deq         := 0;
   l_xcount      := 0;

   --Since we are not planning any processing of the
   --payload data take in the remove_nodata mode
   --This avoids overhead of payload reterival
   l_dequeue_options.dequeue_mode := dbms_aq.REMOVE_NODATA;
   l_dequeue_options.wait         := dbms_aq.NO_WAIT;

   l_dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;

   select   qtab.RECIPIENTS ,qtab.queue_table
   into     l_consumer , l_qTable
   from     dba_queue_tables qtab , dba_queues aq
   where    aq.name = QDequeue.Qname
   and      aq.owner = QDequeue.owner
   and      qtab.queue_table = aq.queue_table
   and      qtab.owner = aq.owner ;

   if (l_consumer = 'MULTIPLE') then
     --Set the consumer name
     if AgtName is null then
        --In this case try setting the account name as consumer
        --Do not put APIs to minimise dependencies
        select sys_context('USERENV', 'CURRENT_SCHEMA')
        into l_dequeue_options.consumer_name
        from sys.dual;
     else
        l_dequeue_options.consumer_name := AgtName ;
     end if;
    end if;

    --Dequeue waiting messages
    -- Owner and Qname were verified in sql earlier and l_qTable was from
    -- dba_queue_tables.
    -- BINDVAR_SCAN_IGNORE
    l_sql := 'select msgid from '||QDequeue.owner||'.'||l_qTable||' where q_name ='||''''||QDequeue.Qname||''''||' and   state=1';

    open wait_msg for l_sql ;
    loop
      fetch wait_msg into l_msgid;
        exit when wait_msg%NOTFOUND;
        l_dequeue_options.correlation := null;
        l_dequeue_options.msgid       := l_msgid;
        begin
        dbms_aq.dequeue
        (
          queue_name         => QDequeue.owner||'.'||QDequeue.Qname,
          dequeue_options    => l_dequeue_options,
          message_properties => l_message_properties,
          payload            => l_payload,
          msgid              => l_msgid
         );
        exception
          when others then
          --Move ahead assuming success
          null;

        end;
    end loop;
    close wait_msg;

    l_dequeue_options.msgid       :=  null;
    while (l_timeout = 0) loop
      begin
        dbms_aq.Dequeue(queue_name           => QDequeue.owner||'.'||QDequeue.Qname,
                        dequeue_options      => l_dequeue_options,
                        message_properties   => l_message_properties,
                        payload              => l_payload,
                        msgid                => l_message_handle);
        l_deq       := l_deq + 1;
        l_xcount  := l_xcount + 1;
        l_timeout := 0;
       exception
          when dequeue_disabled then
              --Incase dequeue has been disabled on the queue
              --Enable the same and re-try the operation.
              dbms_aqadm.start_queue(
                  queue_name =>QDequeue.Qname,
                  enqueue    =>FALSE,
                  dequeue    =>TRUE);
              dbms_aq.Dequeue(queue_name           => QDequeue.Qname,
                              dequeue_options      => l_dequeue_options,
                              message_properties   => l_message_properties,
                              payload              => l_payload,
                              msgid                => l_message_handle);
              l_deq       := l_deq + 1;
              l_xcount    := l_xcount + 1;
              l_timeout   := 0;
            when dequeue_timeout then
               l_timeout := 1;
            when others then
               if (raise_error) then
               raise_application_error(-20000, 'Oracle Error = '||
                        to_char(sqlcode)||' - '||sqlerrm);
                else
                 null;
                end if;
         end;

         --Move to next message
         l_dequeue_options.navigation   := dbms_aq.NEXT_MESSAGE;

         --Commit if commit frequency
         if l_xcount >= l_commit_level then
            commit;
            l_xcount := 0;
         end if;

      end loop;           --End of while loop
   commit;
exception
  when others then
    if (raise_error) then
      raise_application_error(-20000, 'Oracle Error = '||to_char(sqlcode)||' - '||sqlerrm);
     else
       null;
     end if;
end;

--#2. PURGE - Where u do a complete purge of transaction/
--            runtime data.
PROCEDURE PURGE(errbuf        out NOCOPY varchar2,
                retcode       out NOCOPY varchar2)
is
begin
  wf_clone.purgedata;
  retcode := '0';                     -- (successful completion)
  errbuf  := '';
exception
  when others then
    retcode := '2';                   -- (error)
    errbuf  := sqlerrm;
    WF_CORE.Clear;
end;



end wf_clone;


/
