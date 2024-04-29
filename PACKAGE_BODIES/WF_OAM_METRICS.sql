--------------------------------------------------------
--  DDL for Package Body WF_OAM_METRICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_OAM_METRICS" as
/* $Header: WFOAMMTB.pls 120.2.12010000.2 2014/05/13 07:10:08 skandepu ship $ */

--workItemsStatConcurrent
--      This procedure is invoked by the concurrent program FNDWFWITSTATCC
--      to populate the metrics data corresponding to Work Items.
procedure workItemsStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
				  errorCode  OUT NOCOPY VARCHAR2) is

begin

    populateWorkItemsGraphData();
    populateActiveWorkItemsData();
    populateErroredWorkItemsData();
    populateDeferredWorkItemsData();
    populateSuspendedWorkItemsData();
    populateCompletedWorkItemsData();

    commit;
    errorCode := '0';

   exception
   when others then
     errorCode := '2';
     wf_core.context('WF_METRICS', 'workItemsStatConcurrent' );
     raise;

end workItemsStatConcurrent;


procedure  populateWorkItemsGraphData
is

activeCount pls_integer :=0 ;
deferredCount pls_integer :=0;
suspendedCount pls_integer :=0;
erroredCount pls_integer := 0;

Begin

   SELECT count(item_key) into activeCount FROM
               (select /*+ PARALLEL(wf_item_activity_statuses) */
                distinct item_type, item_key from wf_item_activity_statuses
                WHERE activity_status in ('ACTIVE','NOTIFIED','WAITING'));

   SELECT count(*) into deferredCount FROM wf_item_activity_statuses WHERE activity_status = 'DEFERRED';

   SELECT count(item_key) into erroredCount FROM
               (select /*+ PARALLEL(wf_item_activity_statuses) */
                distinct item_type, item_key from wf_item_activity_statuses
                WHERE activity_status = 'ERROR');

   SELECT count(*) into suspendedCount FROM wf_item_activity_statuses WHERE activity_status = 'SUSPEND';

   update FND_USER_PREFERENCES set preference_value = to_char(activeCount) where preference_name = 'NUM_ACTIVE' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFItemsGraph';

   update FND_USER_PREFERENCES set preference_value = to_char(deferredCount) where preference_name = 'NUM_DEFER' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFItemsGraph';

   update FND_USER_PREFERENCES set preference_value = to_char(erroredCount) where preference_name = 'NUM_ERROR' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFItemsGraph';

   update FND_USER_PREFERENCES set preference_value = to_char(suspendedCount) where preference_name = 'NUM_SUSPEND' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFItemsGraph';

  --Update the Last Updated Time
  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerWFItemsGraph' and
              user_name = '-WF_DEFAULT-';

 exception
   when others then
     wf_core.context('WF_METRICS', 'populateWorkItemGraphsData' );
     raise;


end populateWorkItemsGraphData;


procedure populateActiveWorkItemsData
is

l_item_type dbms_sql.VARCHAR2_table;
l_cnt       dbms_sql.NUMBER_table;

cursor wf_items_cursor is
             SELECT /*+ PARALLEL(wf_item_activity_statuses) */
             item_type, count(distinct(item_key)) cnt
             FROM wf_item_activity_statuses
             WHERE activity_status in ('ACTIVE','NOTIFIED','WAITING')
             GROUP BY item_type ORDER BY item_type;
begin

  update wf_item_types set NUM_ACTIVE = 0;

  open wf_items_cursor;

  loop
      fetch wf_items_cursor bulk collect into l_item_type, l_cnt limit 1000;

      forall i in 1 .. l_item_type.COUNT
    	update wf_item_types set NUM_ACTIVE = l_cnt(i)
	 where name = l_item_type(i);

      exit when wf_items_cursor%notfound;

  end loop;
  close wf_items_cursor;

  update fnd_user_preferences
	set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
	where preference_name = 'LAST_UPDATE_TIME' and
	      module_name = 'WFManagerActiveWFItems' and
	      user_name = '-WF_DEFAULT-';

  exception
   when others then
     if wf_items_cursor%ISOPEN then
       close wf_items_cursor;
     end if;
     wf_core.context('WF_METRICS', 'populateActiveWorkItemsData' );
     raise;

end populateActiveWorkItemsData;


procedure populateErroredWorkItemsData
is

l_item_type dbms_sql.VARCHAR2_table;
l_cnt       dbms_sql.NUMBER_table;

cursor wf_items_cursor is
		SELECT item_type, count(distinct(item_key)) cnt
		FROM wf_item_activity_statuses
		WHERE activity_status = 'ERROR'
		GROUP BY item_type ORDER BY item_type;
begin

  update wf_item_types set NUM_ERROR = 0;

  open wf_items_cursor;

  loop

     fetch wf_items_cursor Bulk Collect into l_item_type, l_cnt limit 1000;

     forall i in 1 .. l_item_type.COUNT
        update wf_item_types set NUM_ERROR = l_cnt(i)
         where name = l_item_type(i);

     exit when wf_items_cursor%notfound;

  end loop;
  close wf_items_cursor;

  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerErrorWFItems' and
              user_name = '-WF_DEFAULT-';

  exception
   when others then
     if wf_items_cursor%isopen then
        close wf_items_cursor;
     end if;
     wf_core.context('WF_METRICS', 'populateErroredWorkItemsData' );
     raise;

end populateErroredWorkItemsData;


procedure populateDeferredWorkItemsData
is

l_item_type dbms_sql.VARCHAR2_table;
l_cnt       dbms_sql.NUMBER_table;

cursor wf_items_cursor is
                SELECT item_type, count(distinct(item_key)) cnt
                FROM wf_item_activity_statuses
                WHERE activity_status = 'DEFERRED'
                GROUP BY item_type ORDER BY item_type;
begin

  update wf_item_types set NUM_DEFER = 0;

  open wf_items_cursor;

  loop

     fetch wf_items_cursor Bulk Collect into l_item_type, l_cnt limit 1000;

     forall i in 1 .. l_item_type.COUNT
        update wf_item_types set NUM_DEFER = l_cnt(i)
         where name = l_item_type(i);

     exit when wf_items_cursor%notfound;

  end loop;
  close wf_items_cursor;

  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerDeferWFItems' and
              user_name = '-WF_DEFAULT-';

  exception
   when others then
     if wf_items_cursor%isopen then
        close wf_items_cursor;
     end if;
     wf_core.context('WF_METRICS', 'populateDeferredWorkItemsData' );
     raise;

end populateDeferredWorkItemsData;


procedure populateSuspendedWorkItemsData
is

l_item_type dbms_sql.VARCHAR2_table;
l_cnt       dbms_sql.NUMBER_table;

cursor wf_items_cursor is
                SELECT item_type, count(distinct(item_key)) cnt
                FROM wf_item_activity_statuses
                WHERE activity_status = 'SUSPEND'
                GROUP BY item_type ORDER BY item_type;
begin

  update wf_item_types set NUM_SUSPEND = 0;

  open wf_items_cursor;

  loop

     fetch wf_items_cursor Bulk Collect into l_item_type, l_cnt limit 1000;

     forall i in 1 .. l_item_type.COUNT
        update wf_item_types set NUM_SUSPEND = l_cnt(i)
         where name = l_item_type(i);

     exit when wf_items_cursor%notfound;

  end loop;
  close wf_items_cursor;

  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerSuspendWFItems' and
              user_name = '-WF_DEFAULT-';

  exception
   when others then
     if wf_items_cursor%isopen then
        close wf_items_cursor;
     end if;
     wf_core.context('WF_METRICS', 'populateSuspendedWorkItemsData' );
     raise;

end populateSuspendedWorkItemsData;


procedure populateCompletedWorkItemsData
is

l_item_type dbms_sql.VARCHAR2_table;
l_cnt       dbms_sql.NUMBER_table;
l_purgeCnt  dbms_sql.NUMBER_table;

cursor wf_items_cursor is
        SELECT /*+ PARALLEL(wi) */ wi.item_type, count(wi.item_key) cnt
         FROM wf_items wi
        WHERE wi.end_date IS NOT NULL
        GROUP BY wi.item_type
        order by wi.item_type;
begin

  update wf_item_types set NUM_COMPLETE = 0, NUM_PURGEABLE = 0;

  open wf_items_cursor;
  loop
  	fetch wf_items_cursor bulk collect into l_item_type, l_cnt limit 1000;

	for i in 1 .. l_item_type.COUNT loop
		l_purgeCnt(i) := wf_purge.getpurgeablecount(l_item_type(i));
	end loop;

        forall i in 1 .. l_item_type.COUNT
           update wf_item_types set NUM_COMPLETE = l_cnt(i),
			 NUM_PURGEABLE = l_purgeCnt(i)
           where  name = l_item_type(i);

        exit when wf_items_cursor%notfound;

  end loop;
  close wf_items_cursor;

  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerCompleteWFItems' and
              user_name = '-WF_DEFAULT-';

  exception
   when others then
    if wf_items_cursor%ISOPEN then
       close wf_items_cursor;
    end if;
     wf_core.context('WF_METRICS', 'populateCompletedWorkItemsData' );
     raise;

end populateCompletedWorkItemsData;


--agentActivityStatConcurrent
--      This procedure is invoked by the concurrent program FNDWFAASTATCC
--      to populate the metrics data corresponding to Agent Activity.
procedure agentActivityStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
                                      errorCode  OUT NOCOPY VARCHAR2) is

begin

	populateAgentActivityGraphData();
	populateAgentActivityData();

	commit;

	errorCode:= '0';

	exception
	  when others then
	     errorCode := '2';
	     wf_core.context('WF_METRICS', 'agentActivityStatConcurrent' );
	     raise;

end agentActivityStatConcurrent;

procedure populateAgentActivityGraphData
is

readyCount number := 0;
waitingCount number := 0;
processedCount number := 0;
expiredCount number := 0;
undeliverableCount number := 0;
erroredCount number := 0;
agentname varchar2(10) := '%';
begin

       wf_queue.getcntmsgst(agentname, readyCount, waitingCount, processedCount,
                             expiredCount, undeliverableCount, erroredCount);


        update FND_USER_PREFERENCES set preference_value = to_char(readyCount) where preference_name = 'NUM_READY' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

        update FND_USER_PREFERENCES set preference_value = to_char(waitingCount) where preference_name = 'NUM_WAITING' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

        update FND_USER_PREFERENCES set preference_value = to_char(processedCount) where preference_name = 'NUM_PROCESSED' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

        update FND_USER_PREFERENCES set preference_value = to_char(expiredCount) where preference_name = 'NUM_EXPIRED' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

        update FND_USER_PREFERENCES set preference_value = to_char(undeliverableCount) where preference_name = 'NUM_UNDELIV' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

        update FND_USER_PREFERENCES set preference_value = to_char(erroredCount) where preference_name = 'NUM_ERROR' and user_name='-WF_DEFAULT-' and module_name='WFManagerWFAgentsGraph';

  update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerWFAgentsGraph' and
              user_name = '-WF_DEFAULT-';

        exception
          when others then
             wf_core.context('WF_METRICS', 'populateAgentActivityGraphData' );
             raise;

end populateAgentActivityGraphData;


procedure populateAgentActivityData
is

readyCount number := 0;
waitingCount number := 0;
processedCount number := 0;
expiredCount number := 0;
undeliverableCount number := 0;
erroredCount number := 0;

agentName varchar2(60);

cursor wf_agents_cursor is
		 SELECT distinct(queue_name) as queue_name  FROM wf_agents
		 WHERE queue_name is not null
		 AND queue_name not like '%WF_SMTP_O_1_QUEUE'
	 	 AND system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));


begin

   UPDATE wf_agents
	SET NUM_READY = 0, NUM_WAITING = 0,  NUM_EXPIRED = 0, NUM_UNDELIV = 0,
	    NUM_ERROR = 0, NUM_PROCESS = 0;


   for agent_row in wf_agents_cursor loop
	readyCount := 0;
	waitingCount := 0;
	processedCount := 0;
	expiredCount := 0;
	undeliverableCount := 0;
	erroredCount := 0;

	agentName := extractAgentName(agent_row.queue_name);

        wf_queue.getcntmsgst(agentName, readyCount, waitingCount,
			     processedCount, expiredCount, undeliverableCount,
			     erroredCount);

	update wf_agents
	      SET  NUM_READY = readyCount, NUM_WAITING = waitingCount,
	           NUM_EXPIRED = expiredCount, NUM_UNDELIV = undeliverableCount,
		   NUM_ERROR = erroredCount, NUM_PROCESS = processedCount
	      WHERE queue_name = agent_row.queue_name and
		    system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

   end loop;

   update fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerWFAgents' and
              user_name = '-WF_DEFAULT-';

  exception
   when others then
     wf_core.context('WF_METRICS', 'populateAgentActivityData' );
     raise;

end populateAgentActivityData;


function extractAgentName(pName varchar2) return varchar2
is
agentName varchar2(60);

begin
   begin
     --Bug 18497619: Query the wf_agents to get the agent name from the queue name,
     --as the agent name can be different from queue name
     select name
     into agentName
     from wf_agents
     where queue_name = pName;
   exception
     when NO_DATA_FOUND then
       if instr(pName, '.') = 0 then
         agentName := pName;
       else
         agentName := substr(pName, instr(pName, '.')+1);
       end if;
   end;

   return agentName;

exception
   when others then
     wf_core.context('WF_METRICS', 'extractAgentName' );
     raise;

end extractAgentName;



--ntfMailerStatConcurrent
--      This procedure is invoked by the concurrent program FNDWFMLRSTATCC
--      to populate the Notification Mailer throughput data.
procedure ntfMailerStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
                               errorCode  OUT NOCOPY VARCHAR2)
is

begin

        populateNtfMailerGraphData();
        commit;

        errorCode:= '0';

        exception
          when others then
             errorCode := '2';
             wf_core.context('WF_METRICS', 'ntfMailerStatConcurrent' );
             raise;


end ntfMailerStatConcurrent;


procedure populateNtfMailerGraphData
is

processedCount number := 0;
waitingCount number := 0;

begin

        SELECT count(*) into processedCount FROM wf_notifications
        WHERE mail_status = 'SENT' AND status = 'OPEN';

        SELECT count(*) into waitingCount FROM wf_notifications
        WHERE mail_status = 'MAIL';

        UPDATE FND_USER_PREFERENCES
                SET preference_value = to_char(processedCount)
                WHERE preference_name = 'NUM_PROCESSED' and
                user_name='-WF_DEFAULT-' and module_name='WFManagerWFNtfsGraph';

        UPDATE FND_USER_PREFERENCES SET preference_value = to_char(waitingCount)        WHERE preference_name = 'NUM_WAITING' and
         user_name='-WF_DEFAULT-' and module_name='WFManagerWFNtfsGraph';


        UPDATE fnd_user_preferences
        set preference_value = to_char(sysdate,'dd/MM/YYYY HH24:MI:SS')
        where preference_name = 'LAST_UPDATE_TIME' and
              module_name = 'WFManagerWFNtfsGraph' and
              user_name = '-WF_DEFAULT-';

        exception
          when others then
             wf_core.context('WF_METRICS', 'populateNtfMailerGraphData' );
             raise;


end populateNtfMailerGraphData;


END WF_OAM_METRICS;

/
