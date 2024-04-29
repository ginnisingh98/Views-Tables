--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_WF" as
--$Header: iexstrwb.pls 120.23.12010000.13 2010/05/26 13:03:27 pnaveenk ship $


--------------private procedures and funtion --------------------------------

/** check if the process is active or not
 *  for fulfillment and custom work flows
 * abort the processes that are not completed.
 **/

wf_yes 		varchar2(1) ;
wf_no 		varchar2(1) ;
-- PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;
procedure custom_abort_process(p_itemtype IN varchar2, p_itemkey IN varchar2) is
begin
    wf_engine.abortprocess(itemtype => p_itemtype, itemkey => p_itemkey);
   exception
     when others then
         iex_debug_pub.logmessage('Exception of custom abort_processes: ');
end;

PROCEDURE abort_processes(p_strategy_id  IN NUMBER) IS

 cursor c_get_itemtype is
 select a.workflow_item_type itemtype,
        b.work_item_id
 from iex_stry_temp_work_items_vl a,
      iex_strategy_work_items b
 where a.work_item_temp_id =b.WORK_ITEM_TEMPLATE_ID
 and   b.strategy_id     =p_strategy_id
  and a.workflow_item_type IS NOT NULL;

 cursor c_workitems is
 select a.work_item_id
 from  iex_strategy_work_items  a,
       iex_stry_temp_work_items_vl b
 where a.strategy_id = p_strategy_id
 and a.work_item_template_id  =b.work_item_temp_id
 and (b.fulfil_temp_id IS NOT NULL or b.xdo_template_id IS NOT NULL)
 -- Added for bug 8996459 PNAVEENK 27-OCT-2009
 and exists ( select 1 from wf_items
              where item_type='IEXSTFFM'
              and item_key = a.work_item_id );
 -- and b.fulfil_temp_id IS NOT NULL ;

l_itemtype VARCHAR2(100);
l_result VARCHAR2(100);
l_Status VARCHAR2(8);

-- begin bug 7703319
 l_itemkey         varchar2(240);
 l_jtf_object_type varchar2(30);
 l_jtf_object_id   number;

 cursor get_itemkey(c_id IN varchar2) is
       select distinct item_key from wf_item_attr_values_ondemand
         where name = 'WRITEOFF_ID' and text_value = c_id and item_type = 'IEXWRREQ';

 cursor get_strategy_info(c_strategy_id IN number) is
      select jtf_object_type,jtf_object_id from iex_strategies
        where strategy_id = c_strategy_id;
 -- end bug 7703319

 BEGIN
      --check for custom work flow first
      --abort all the custom workflow for the given strategy_id
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN New abort_processes ************');
     END IF;

     -- Begin  bug 7703319
     begin
         Open get_strategy_info(p_strategy_id);
         Fetch get_strategy_info into l_jtf_object_type,l_jtf_object_id;

         if l_jtf_object_type = 'IEX_WRITEOFF' then

            open get_itemkey(l_jtf_object_id);
            Loop
                 fetch get_itemkey into l_itemkey;
                 exit when get_itemkey%NOTFOUND;

                 iex_debug_pub.logmessage('IEXWRREQ Workflow and itemkey is...'||l_itemkey);

                 wf_engine.itemstatus(itemtype => 'IEXWRREQ',   itemkey => l_itemkey,   status => l_status,   result => l_result);
                 iex_debug_pub.logmessage('IEXWRREQ Workflow Status = :: =>' || l_status||'and itemkey is...'||l_itemkey);

                 if l_status <> wf_engine.eng_completed then
                            wf_engine.abortprocess(itemtype => 'IEXWRREQ', itemkey => l_itemkey);
                            wf_engine.itemstatus(itemtype => 'IEXWRREQ', itemkey => l_itemkey,   status => l_status,   result => l_result);
                            iex_debug_pub.logmessage('cancel Writeoff workflow: Abort process has completed and status =>' || l_status);
                 end if;
            End Loop;
            close get_itemkey;

         end if;
         exception
            when others then
                 iex_debug_pub.logmessage('Exception for WriteOFF Aborting.. Strategy ID =>'||p_strategy_id||'id =>'||l_jtf_object_id);
     end;
     iex_debug_pub.logmessage('Ending....cancel Writeoff workflow: ');
     -- End bug 7703319

     FOR c_rec in c_get_itemtype
     LOOP
     begin  -- Added for bug#8493656  by PNAVEENK Moved all the code in the loop into the scope of exception handler
      if c_rec.itemtype IS  NOT NULL THEN
              wf_engine.itemstatus(itemtype  => c_rec.itemtype,
                                   itemkey   => c_rec.work_item_id,
                                   status    => l_status,
                                   result    => l_result);
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage('abort_processes: ' || 'after workflow status check ' ||l_status || ' item key'
                                                                        || c_rec.work_item_id);
              END IF;

            IF l_status <> wf_engine.eng_completed THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('abort_processes: ' || ' process has not completed and status =>'|| l_status);
               END IF;
            --   BEGIN  commented for bug#8493656
                    wf_engine.abortprocess(itemtype => c_rec.itemtype,
                                           itemkey   => c_rec.work_item_id);
             	   END IF;  -- Added for bug#8493656
	    end if;  -- Added for bug#8493656
		     EXCEPTION
              WHEN OTHERS THEN
--                  IF PG_DEBUG < 10  THEN
                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     iex_debug_pub.logmessage('abort_processes: ' || 'abort process ' ||  c_rec.itemtype ||
                                           'itemkey ' || c_rec.work_item_id ||'has failed');
                  END IF;
               END;
   --     end if;  commented for bug#8453656

   --  end if;   commented for bug#8453656

    END LOOP;

    --abort all fulfillment workflow for
    -- the given strategy.
     BEGIN
           l_itemtype :='IEXSTFFM';
           FOR c_rec in c_workitems
           LOOP
	   -- Start for the bug 8996459 PNAVEENK
          Begin
	  wf_engine.itemstatus(itemtype  => l_itemtype,
                                      itemkey   => c_rec.work_item_id,
                                      status    =>l_status,
                                      result    =>l_result);
--                 IF PG_DEBUG < 10  THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('abort_processes: ' || 'after workflow status check ' ||l_status || ' item key'
                                                                            ||c_rec.work_item_id);
                 END IF;

		  Exception
	      when others then
                 iex_debug_pub.logmessage(' Exception in finding workflow of work_item_id ' || c_rec.work_item_id);
	      end;

            -- end for bug 8996459
                IF l_status <> wf_engine.eng_completed THEN
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage  ('abort_processes: ' || ' in fulfilment and process has not completed '||
                                               'and status =>'||l_status);
                   END IF;


               BEGIN
                        wf_engine.abortprocess(itemtype => l_itemtype,
                                               itemkey   => c_rec.work_item_id);



		 --Begin bug#8490070 snuthala 25-May-2009
			--cancel the delivery request when corresponding workitem is cancelled
			iex_debug_pub.logmessage('abort_processes: ' || 'Cancelling the xml delivery requests corresponding to workitem: '||c_rec.work_item_id);
			update iex_xml_request_histories
	  		set status='CANCELLED'
			where object_type='IEX_STRATEGY'
			and status = 'XMLDATA'
			and xml_request_id in (select xml_request_id
	                                from iex_dunnings
					where object_type='IEX_STRATEGY'
					and object_id=c_rec.work_item_id);
			iex_debug_pub.logmessage('abort_processes: ' || 'Completed cancelling the xml delivery requests corresponding to workitem: '||c_rec.work_item_id);
			--Begin bug#8490070 snuthala 25-May-2009
                   EXCEPTION
                   WHEN OTHERS THEN
--                            IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               iex_debug_pub.logmessage('abort_processes: ' || 'abort process ' ||  l_itemtype ||
                                        'itemkey ' || c_rec.work_item_id ||'has failed');
                            END IF;
                   END;

           end if;
             END LOOP;
      EXCEPTION WHEN OTHERS THEN
           null; -- if itemkey does not exists ..do nothing.
      END ;


--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** END abort_processes ************');
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage('abort_processes: ' || 'abort process has failed' );
           END IF;
 END abort_processes;

/**
 * to see if the current work item is still open
 * this is because custom and fulfillment work flows updates
 * the work item and if the strategy is changed back from ONHOLD to OPEN,
 * we need to resume the process.
 **/

FUNCTION  CHECK_WORK_ITEM_OPEN(p_strategy_id  IN NUMBER)
                                RETURN NUMBER IS
v_result NUMBER;
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN CHECK_WORK_ITEM_OPEN ************');
     END IF;
   select  count(*)
   INTO v_result
   from iex_strategies a,
        ieX_strategy_work_items b
   where a.strategy_id =p_strategy_id
   and a.strategy_id =b.strategy_id
   and a.next_work_item_id =b.work_item_id
   and b.status_code ='OPEN'
   and a.status_code ='OPEN';

       return v_result;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END CHECK_WORK_ITEM_OPEN ************');
     END IF;
END CHECK_WORK_ITEM_OPEN;


/**
 * work item is a match
 **/

FUNCTION  CHECK_CURRENT_WORK_ITEM(p_strategy_id  IN NUMBER,
                                  p_work_item_id IN NUMBER)
                                  RETURN NUMBER IS
v_result NUMBER;
BEGIN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** BEGIN CHECK_CURRENT_WORK_ITEM ************');
       END IF;
       select  count(*) INTO v_result from iex_strategies
       where strategy_id =p_strategy_id
       and next_work_item_id =p_work_item_id
       and status_code ='OPEN';
       return v_result;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END CHECK_CURRENT_WORK_ITEM ************');
       END IF;
END CHECK_CURRENT_WORK_ITEM;

/**
* update work item status
*/
PROCEDURE update_workitem_Status(p_work_item_id IN NUMBER,
                                 p_status        IN VARCHAR2 )IS

l_api_version   NUMBER       := 1.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** BEGIN update_workitem_Status ************');
      END IF;
      IEX_STRY_UTL_PUB.UPDATE_WORK_ITEM (p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_TRUE,
                                         p_commit        => FND_API.G_FALSE,
                                         x_msg_count     => l_msg_count,
                                         x_msg_data      => l_msg_data,
                                         x_return_status => l_return_status,
                                         p_work_item_id   => p_work_item_id,
                                         p_status        => p_status);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** END update_workitem_Status ************');
    END IF;
END update_workitem_Status;

/** get user name
 * this will used to send the notification
**/

procedure get_username
                       ( p_resource_id IN NUMBER,
                         --x_username    OUT NOCOPY VARCHAR2 ) IS  bug 6717880/7170165 by Ehuh
                         x_username    OUT NOCOPY VARCHAR2,
                         x_source_name OUT NOCOPY VARCHAR2 ) IS  -- bug 6717880/7170165 by Ehuh

cursor c_getname(p_resource_id NUMBER) is
--Select user_name  -- bug 6717880/7170165 by Ehuh
Select user_name,source_name  -- bug 6717880/7170165 by Ehuh
from jtf_rs_resource_extns
where resource_id =p_resource_id;

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN get_username ************');
     END IF;
     OPEN c_getname(p_resource_id);
     --FETCH c_getname INTO x_username;  -- bug 6717880/7170165 by Ehuh
     FETCH c_getname INTO x_username, x_source_name;  -- bug 6717880/7170165 by Ehuh
     CLOSE c_getname;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END get_username ************');
     END IF;
END get_username;

-----populate set_notification_resources---------------------------------
procedure set_notification_resources(
            p_resource_id       in number,
            itemtype            in varchar2,
            itemkey             in varchar2
           ) IS
l_username VARCHAR2(100);
l_mgrname  VARCHAR2(100);
l_mgr_resource_id NUMBER ;
l_mgr_id number;

      CURSOR c_manager(p_resource_id NUMBER) IS
      SELECT b.user_id, b.user_name , b.resource_id
      FROM JTF_RS_RESOURCE_EXTNS a
      ,    JTF_RS_RESOURCE_EXTNS b
      WHERE b.source_id = a.source_mgr_id
      AND a.resource_id = p_resource_id;

     --Start bug 6717880/7170165 by Ehuh
     Cursor c_get_assignee(p_resource_id number) is
        select source_name from JTF_RS_RESOURCE_EXTNS
          where resource_id = p_resource_id;
     l_source_name varchar2(50);
     --End bug 6717880/7170165 by Ehuh


BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN set_notification_resources ************');
     END IF;
     -- get user name from  jtf_rs_resource_extns
     --Start bug 6717880/7170165 by Ehuh
                     --get_username
                     --  ( p_resource_id =>p_resource_id,
                     --   x_username    =>l_username);
      get_username ( p_resource_id =>p_resource_id,
                    x_username    =>l_username,
                    x_source_name  =>l_source_name);

      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'ASSIGNEE',
                                 avalue    =>  l_source_name);
     --End   bug 6717880/7170165 by Ehuh

      wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'NOTIFICATION_USERNAME',
                                 avalue    =>  l_username);

     -- get mgr name from  jtf_rs_resource_extns
     -- haveto get the mgr resource id
     -- for the time being assign mgr =resource_id
     BEGIN
         open c_manager(p_resource_id);
         fetch c_manager into l_mgr_id, l_mgrname, l_mgr_resource_id;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Manager Info ' || l_mgrName || ' ID ' ||
                   l_mgr_id || 'Resource ID ' || l_mgr_resource_id);
END IF;
         close c_manager;

     EXCEPTION
         WHEN OTHERS then
            null;

     END;

     if l_mgrname is NULL then
              l_mgrname := l_username;
              l_mgr_resource_id := p_resource_id;
     end if;


       wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'NOTIFICATION_MGRNAME',
                                 avalue    =>  l_mgrname);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** END set_notification_resources ************');
      END IF;
exception
  when others then
     null;

END  set_notification_resources;




--------------populate set_escalate_wait_time---------------------------------
procedure set_escalate_wait_time
          ( p_escalate_date IN   DATE,
            itemtype        in   varchar2,
            itemkey         in   varchar2
           ) IS

l_grace_period NUMBER ;

BEGIN
     -- initialize variable
     l_grace_period :=  nvl(fnd_profile.value('IEX_STRY_GRACE_PERIOD'),0);

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** BEGIN set_escalate_wait_time ************');
      END IF;
      wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'ESCALATE_WAIT_TIME',
                                 avalue    => p_escalate_date);
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('set_escalate_wait_time: ' || 'ESCALATETIME' ||TO_CHAR(p_escalate_date,'DD-MON-YYYY:HH:MI:SS'));
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END set_escalate_wait_time ************');
     END IF;
exception
  when others then
       null;
END  set_escalate_wait_time;

-----populate set_optional_wait_time---------------------------------
procedure set_optional_wait_time(
            p_optional_date     IN DATE,
            itemtype            in   varchar2,
            itemkey             in   varchar2
           ) IS

BEGIN

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** BEGIN set_optional_wait_time ************');
       END IF;
       wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'OPTIONAL_WAIT_TIME',
                                 avalue    => p_optional_date);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('set_optional_wait_time: ' || 'OPTIONALTIME' ||TO_CHAR(p_optional_date,'DD-MON-YYYY:HH:MI:SS'));
      END IF;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END set_optional_wait_time ************');
       END IF;
exception
  when others then
       null;

END  set_optional_wait_time;

-----populate schedule_times---------------------------------
--set coptional wait period
--set escalte wait period
--set work_item_template_id
--populate schedule_end and schedule_start

procedure populate_schedule_times
          (
            p_work_item_temp_id IN NUMBER,
            itemtype            IN   varchar2,
            itemkey             IN   varchar2,
            x_schedule_start    OUT NOCOPY DATE,
            x_schedule_end      OUT NOCOPY DATE
           ) IS


cursor c_get_witem_temp(p_work_item_temp_id NUMBER) is
select closure_time_limit, closure_time_uom,
       schedule_wait, schedule_uom,
       optional_yn,escalate_yn,
        option_wait_time, option_wait_time_uom
from iex_stry_temp_work_items_vl
where work_item_temp_id =p_work_item_temp_id;
l_optional_date DATE;
BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** BEGIN populate_schedule_times ************');
    END IF;
     FOR c_rec in c_get_witem_temp(p_work_item_temp_id)
     LOOP
          x_schedule_start:=IEX_STRY_UTL_PUB.get_Date
                            (p_date =>SYSDATE,
                             l_UOM  =>c_rec.schedule_uom,
                             l_UNIT =>c_rec.schedule_wait);
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('populate_schedule_times: ' || 'schedulestart'||x_schedule_start);
          END IF;
          x_schedule_end:=IEX_STRY_UTL_PUB.get_Date
                            (p_date =>x_schedule_start,
                             l_UOM  =>c_rec.closure_time_uom,
                             l_UNIT =>c_rec.closure_time_limit);
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('populate_schedule_times: ' || 'schedulestart'||x_schedule_end);
          END IF;
         -- populate the escalate wait period
         if c_rec.escalate_yn =wf_yes THEN

            set_escalate_wait_time
               ( p_escalate_date =>x_schedule_end,
                 itemtype        =>itemtype,
                 itemkey         =>itemkey);
          end if;

        --populate optional wait period
        if c_rec.optional_yn =wf_yes THEN
            l_optional_date:= IEX_STRY_UTL_PUB.get_Date
                               (p_date =>x_schedule_start,
                                l_UOM  =>c_rec.option_wait_time_uom,
                                l_UNIT =>c_rec.option_wait_time);
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage('populate_schedule_times: ' || 'sysdate '
                ||TO_CHAR(sysdate,'DD-MON-YYYY:HH:MI:SS'));
           END IF;

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage('populate_schedule_times: ' || 'l_optional_date '
                ||TO_CHAR(l_optional_date,'DD-MON-YYYY:HH:MI:SS'));
           END IF;

           set_optional_wait_time
                 ( p_optional_date => l_optional_date,
                   itemtype        =>itemtype,
                   itemkey         =>itemkey);
        end if;
        --set workitem_template_id attribute
         wf_engine.SetItemAttrNumber(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'WORKITEM_TEMPLATE_ID',
                                   avalue    => p_work_item_temp_id);
        --reset the activity_label
          wf_engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'ACTIVITY_NAME',
                                    avalue    => null);
       --reset the status
         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   =>  itemkey,
                                   aname     => 'STRATEGY_STATUS',
                                   avalue    => null);


     END LOOP;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END populate_schedule_times ************');
     END IF;
EXCEPTION WHEN OTHERS THEN
    null;
END  populate_schedule_times;


------------------- procedure get_resource ------------------------------
/** get resource id for the given competence
*
**/
procedure get_resource ( p_party_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER)  IS

l_api_version   NUMBER       ;
l_init_msg_list VARCHAR2(1)  ;
l_resource_tab iex_utilities.resource_tab_type;

l_commit VARCHAR2(1)         ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_validation_level NUMBER ;

l_resource_id NUMBER   ;
l_count       NUMBER ;
l_found       BOOLEAN ;
cursor c_get_person_id (l_person_id NUMBER,
                        l_competence_id NUMBER)is
select count(person_id)
from per_competence_elements
where competence_id = l_competence_id
and   person_id     = l_person_id
and   trunc(NVL(effective_date_to,SYSDATE)) >= trunc(sysdate)
and   trunc(effective_date_from) <=  trunc(sysdate) ;


BEGIN
  -- initialize variable
  l_api_version   := 1.0;
  l_init_msg_list := FND_API.G_TRUE;
  l_commit := FND_API.G_FALSE;
  l_validation_level := FND_API.G_VALID_LEVEL_FULL;
  l_resource_id :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);
  l_count       :=0;
  l_found       := TRUE;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('populate_schedule_times: ' || '**** BEGIN  get_resource ************');
        iex_debug_pub.logmessage ('default resource id from profile iex_stry_default_resource) ' || l_resource_id);
        iex_debug_pub.logmessage ('calling get_access_resources ' || p_party_id);
     END IF;
-- get resource id table of reords for the given party id
-- the record has resource id and person id along with the user name
--Begin bug#5373412 schekuri 10-Jul-2006
--Call new consolidated procedure get_assigned_collector
/*iex_utilities.get_assign_resources(p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_TRUE,
                                   p_commit           => FND_API.G_FALSE,
                                   p_validation_level => l_validation_level,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_return_status    => l_return_status,
                                   p_party_id         => p_party_id,
                                   x_resource_tab     => l_resource_tab);*/

iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'PARTY',
                               p_level_id          => p_party_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);

--End bug#5373412 schekuri 10-Jul-2006

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage('populate_schedule_times: ' || 'in get resource and l_return_status = '||l_return_status);
  iex_debug_pub.logmessage('in get resource and l_return_status from iex_utilities.get_access_resources = '||l_return_status);
  iex_debug_pub.logmessage('resource count from iex_utilities.get_access_resources = '||l_resource_tab.count);
END IF;

  -- if COMPETENCE id exists for the given work template Id,
  -- see if the person id from the
  -- the above l_resource_tab matches with the competence Id
  -- pick if there is match or pick any resource if there is no match
  -- or competence id of the work template id is null


     --if  p_competence_id IS  NULL  THEN
     if  p_competence_tab.count = 0    THEN
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('populate_schedule_times: ' || 'Competence table is empty');
         END IF;
        --get the first resource id if competence id is null from
        -- the work item template
         FOR i in 1..l_resource_tab.count LOOP
             l_resource_id := l_resource_tab(i).resource_id;
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
             END IF;
             EXIT;
         END LOOP;
     else
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('Loop for matching competence. count = '||p_competence_tab.count );
       END IF;
           FOR i in 1..l_resource_tab.count LOOP
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('populate_schedule_times: ' || 'PERSON ID is '||l_resource_tab(i).person_id);
                  iex_debug_pub.logmessage('populate_schedule_times: ' || 'RESOURCE ID is '||l_resource_tab(i).resource_id);
               END IF;

               FOR j in 1..p_competence_tab.count LOOP

                   OPEN c_get_person_id (l_resource_tab(i).person_id,
                                                    p_competence_tab(j));
                   FETCH c_get_person_id INTO l_count;
                   CLOSE c_get_person_id;
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('populate_schedule_times: ' || 'COMPETENCE ID is '||
                                       p_competence_tab(j));
                   END IF;
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('populate_schedule_times: ' || 'no of matches  '|| l_count);
                   END IF;
                   If l_count =0 THEN
                      -- match not found, use the first resource and exit out NOCOPY
                      -- from the competence loop.
		      --Begin bug#5373412 schekuri 10-Jul-2006
		      --Commented the below the code to return default resource id instead of first resource id
		      --when there is no resource found matching the competency of the workitem.
                      /*l_resource_id := l_resource_tab(1).resource_id;
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
                      END IF;*/
		      --End bug#5373412 schekuri 10-Jul-2006
                      -- have to look for the next resource if l_found is false
                      l_found :=FALSE;
                      EXIT;
                   ELSE
                       l_resource_id := l_resource_tab(i).resource_id;
--                       IF PG_DEBUG < 10  THEN
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record found with competence matched l_resource_tab l_resource_id = '|| l_resource_id);
                       END IF;
                       l_found :=TRUE;
                  End if;
                END LOOP;
                if l_found THEN
                   -- a matching resource with all the competencies
                   --have been found ,stop looking for next resource
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('populate_schedule_times: ' || 'match found and RESOURCE ID is =>'
                                             ||l_resource_tab(i).resource_id);
                   END IF;
                   exit;
                end if;
             END LOOP;
       end if;
    --assign out NOCOPY variable
      x_resource_id :=l_resource_id;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('populate_schedule_times: ' || 'value of x_resource_id' ||x_resource_id);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('populate_schedule_times: ' || '**** END  get_resource ************');
      END IF;
END get_resource;


----------- procedure  create_work_item ------------------------------
/** to create work item
**/

procedure create_work_item
               ( itemtype    in   varchar2
                ,itemkey     in   varchar2
                ,p_strategy_id   IN NUMBER
                ,p_template_id   IN NUMBER
                ,p_party_id     IN NUMBER
                ,x_return_status OUT NOCOPY VARCHAR2
                ,x_error_msg OUT NOCOPY VARCHAR2) IS


l_resource_id   NUMBER;
l_competence_id NUMBER;

-- Begin- Andre 07/28/2004 - Add bill to assignmnet
l_siteuse_id NUMBER;
l_object_code VARCHAR2(30);
l_cust_account_id NUMBER;
l_object_id number;
-- End- Andre 07/28/2004 - Add bill to assignmnet

cursor c_get_next_witem(p_strategy_id NUMBER,
                        p_template_id NUMBER)
is

/*select sxref.strategy_temp_id TEMPLATE_ID,
       sxref.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
       sxref.work_item_order ORDER_BY
       ,nvl(swit.status_code,'NOTCREATED') STATUS
       ,swit.work_item_id     WORK_ITEM_ID
       ,swit.strategy_id      STRATEGY_ID
from iex_strategy_work_temp_xref sxref
     ,iex_strategy_work_items swit
where sxref.strategy_temp_id =p_template_id
and   swit.work_item_template_id(+)  =sxref.work_item_temp_id
and   swit.strategy_id(+) =p_strategy_id
union all
select susit.strategy_template_id TEMPLATE_ID,
       susit.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
       susit.work_item_order ORDER_BY
       ,nvl(swit.status_code,'NOTCREATED') STATUS
       ,swit.work_item_id     WORK_ITEM_ID
       ,susit.strategy_id      STRATEGY_ID
  from iex_strategy_user_items susit
     ,iex_strategy_work_items swit
where susit.strategy_id =p_strategy_id
and   swit.work_item_template_id(+)  =susit.work_item_temp_id
and   swit.strategy_id(+) =p_strategy_id
order by order_by;
*/

--created work items
SELECT wkitem.strategy_id     STRATEGY_ID,
wkitem.strategy_temp_id       TEMPLATE_ID,
wkitem.work_item_order        ORDER_BY,
wkitem.work_item_id           WORK_ITEM_ID,
wkitem.work_item_template_id  WORK_ITEM_TEMPLATE_ID,
wkitem.status_code            STATUS
from iex_strategy_work_items wkitem,
iex_stry_temp_work_items_vl stry_temp_wkitem
WHERE
wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
and wkitem.strategy_id =p_strategy_id
--to be created work items
union all
SELECT stry.STRATEGY_ID       STRATEGY_ID
, xref.STRATEGY_TEMP_ID       TEMPLATE_ID
, xref.WORK_ITEM_ORDER        ORDER_BY
, TO_NUMBER(NULL)             WORK_ITEM_ID
, xref.WORK_ITEM_TEMP_ID      WORK_ITEM_TEMPLATE_ID
, 'NOTCREATED'                STATUS
FROM IEX_STRATEGIES stry
, IEX_STRATEGY_WORK_TEMP_XREF xref
, IEX_STRY_TEMP_WORK_ITEMS_VL stry_temp_wkitem
WHERE stry.STRATEGY_TEMPLATE_ID = xref.STRATEGY_TEMP_ID
and xref.WORK_ITEM_TEMP_ID = stry_temp_wkitem.WORK_ITEM_TEMP_ID
and stry.strategy_id =p_strategy_id
--not in workitems table
AND not exists ( select 'x' from iex_strategy_work_items wkitem where
wkitem.strategy_id = stry.strategy_id
and wkitem.work_item_template_id = xref.work_item_temp_id
and wkitem.work_item_order = xref.work_item_order
and  wkitem.strategy_id =p_strategy_id
)
----skip workitems which is status-ed SKIP
and not exists ( select 'x' from iex_strategy_user_items uitems where
uitems.strategy_id = stry.strategy_id  and
uitems.work_item_temp_id = xref.work_item_temp_id and
uitems.work_item_order = xref.work_item_order and
uitems.operation = 'SKIP'
and  uitems.strategy_id =p_strategy_id
)
and (xref.work_item_order > (select max(wkitem_order) from iex_work_item_bali_v
     where strategy_id = p_strategy_id and start_time is not null)
   or (select count(*) from iex_work_item_bali_v where strategy_id = p_strategy_id ) = 0
    )      -- later on assignment of  prior work items, and case of initial creation of wkitem
-- get all user items
union all
SELECT stry.STRATEGY_ID          STRATEGY_ID
, uitem.STRATEGY_TEMPLATE_ID     TEMPLATE_ID
, uitem.WORK_ITEM_ORDER          ORDER_BY
, TO_NUMBER(NULL)                WORK_ITEM_ID
, uitem.WORK_ITEM_TEMP_ID        WORK_ITEM_TEMPLATE_ID
, uitem.operation                   STATUS
FROM IEX_STRATEGIES stry
, IEX_STRATEGY_user_items uitem
, IEX_STRY_TEMP_WORK_ITEMS_VL stry_temp_wkitem
WHERE stry.STRATEGY_ID = uitem.STRATEGY_ID
and uitem.WORK_ITEM_TEMP_ID = stry_temp_wkitem.WORK_ITEM_TEMP_ID
and stry.strategy_id =p_strategy_id
AND not exists
-- exclude useritem whoch is already a workitem
( select 'x' from iex_strategy_work_items wkitem
where wkitem.strategy_id = stry.strategy_id
and wkitem.work_item_template_id = uitem.work_item_temp_id
and uitem.work_item_order = wkitem.work_item_order
and wkitem.strategy_id =p_strategy_id)
order by ORDER_BY;

/*cursor c_get_competence_id (p_work_item_temp_id NUMBER) IS
SELECT competence_id from iex_stry_temp_work_items_vl
where work_item_temp_id =p_work_item_temp_id;
*/

-- Start Bug 6717880/7170165 by Ehuh
Cursor c_get_accloc(p_str_id number) Is
    select account_number,location from iex_strategies_bali_v
      where strategy_id = p_str_id;

l_location varchar2(50);
l_acct_number varchar2(50);
l_assignee varchar2(50);
-- End Bug 6717880/7170165 by Ehuh

cursor c_get_competence_id (p_work_item_temp_id NUMBER) IS
SELECT competence_id from iex_strategy_work_skills
where work_item_temp_id =p_work_item_temp_id;

cursor c_get_callback_dt (p_work_item_temp_id NUMBER) IS
SELECT callback_wait, callback_uom,optional_yn,option_wait_time,
option_wait_time_uom,escalate_yn, notify_yn,workflow_item_type,work_type,
category_type,fulfil_temp_id
from iex_stry_temp_work_items_vl
where work_item_temp_id =p_work_item_temp_id;

l_strategy_work_item_rec IEX_STRATEGY_WORK_ITEMS_PVT.STRATEGY_WORK_ITEM_REC_TYPE;
l_return_status VARCHAR2(1) ;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
x_work_item_id  NUMBER;
x_schedule_start DATE;
x_schedule_end   DATE;
l_api_version   NUMBER       := 1.0;
l_competence_tab tab_of_comp_id;
l_index NUMBER :=1;
l_workitem_name varchar2(2000);

l_Assignment_level varchar2(100);
l_Default_Resource_ID number;
bReturn Boolean;
l_wkitem_status varchar2(30);  --bug#5874874 gnramasa
l_str_level_count number; -- Added for bug 8708271 multi level strategy

BEGIN
  -- initialize variable
  l_Default_Resource_id   :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);
  l_Resource_ID := l_Default_Resource_ID;

  l_Assignment_Level  :=  NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
  l_return_status :=FND_API.G_RET_STS_SUCCESS;

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('populate_schedule_times: ' || '**** BEGIN  create_work_item ************');
  END IF;

  -- Start for  bug 8708271 pnaveenk multi level strategy

   Begin
   SELECT count(*) into l_str_level_count
   FROM IEX_LOOKUPS_V
   WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
   AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
   Exception
   when others then
    iex_debug_pub.logmessage (' Exception in str_level_count ');
   End;

  FOR c_get_witem_rec in c_get_next_witem
                            (p_strategy_id,
                             p_template_id )
   LOOP
        -- check to see if the work item has not been created
             if c_get_witem_rec.status ='NOTCREATED'
		THEN
          -- then the status is UNASSIGNED .. create the work item
          --get the competence id from the work item template table

          /* OPEN c_get_competence_id(c_get_witem_rec.work_item_template_id);
           FETCH c_get_competence_id INTO l_competence_id;
           CLOSE c_get_competence_id;
           */

           FOR c_rec IN c_get_competence_id(c_get_witem_rec.work_item_template_id)
           LOOP
               l_competence_tab(l_index):=c_rec.competence_id;
               l_index :=l_index +1;
           END LOOP;

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('populate_schedule_times: ' || 'No. of competence is =>'||l_competence_tab.count);
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('populate_schedule_times: ' || 'in create work item private and going to call get_resource');
          END IF;

            -- get resource for the given competence_id
            -- if resource is not returned, return out NOCOPY of the procedure
            --get_resource(p_party_id,l_competence_id,l_resource_id);
-- Begin- Andre 07/28/2004 - Add bill to assignmnet
-- Begin- Kasreeni 01/17/2005 - Modified for multiple level resource check
           -- get_resource(p_party_id,l_competence_tab,l_resource_id);
           begin
		      select jtf_object_type, jtf_object_id, cust_account_id,customer_site_use_id
		      into l_object_code, l_object_id, l_cust_account_id,l_siteuse_id
		      from iex_strategies
		      where strategy_id = p_strategy_id;
          exception
               when others then
                 iex_debug_pub.logmessage ('populate_schedule_times: More than one row for this Strategy. Exception on selecting strategy!!!!!');
           end;

       /* For Party, we try party only */
		   if l_object_code =  'PARTY' then
		     if l_str_level_count >1 then
                      l_Assignment_Level := 'PARTY';
                     end if;

          if l_Assignment_Level = 'PARTY' then

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Party Level :Party ID ' || p_Party_ID);
              end if;
		   		    get_resource(p_party_id,l_competence_tab,l_resource_id);

           else
			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('No Territory Access Call :Party ID ' || p_Party_ID);
              end if;
           end if;

       /* For Account Level, we try Account, if missed try Party */
		   elsif l_object_code = 'IEX_ACCOUNT' then
                     if l_str_level_count >1 then
                      l_Assignment_Level := 'ACCOUNT';
                     end if;
          if l_Assignment_Level = 'PARTY' then

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Party Level :Party ID ' || p_Party_ID);
              end if;
		   		    get_resource(p_party_id,l_competence_tab,l_resource_id);

          elsif l_Assignment_level = 'ACCOUNT' then

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Account Level :Account ID ' || l_Object_ID);
              end if;

              bReturn:=get_account_resource(l_object_id, l_competence_tab, l_resource_id);

          else

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('No Territory Access Call :Party ID ' || p_Party_ID);
              end if;

          end if;

		   else
		   if l_str_level_count >1 then
                      l_Assignment_Level := 'BILL_TO';
                   end if;
          if l_Assignment_Level = 'PARTY' then

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Party Level :Party ID ' || p_Party_ID);
              end if;
		   		    get_resource(p_party_id,l_competence_tab,l_resource_id);

          elsif l_Assignment_level = 'ACCOUNT' then

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Account Level :Account ID ' || l_cust_account_ID);
              end if;

              bReturn:=get_account_resource(l_cust_account_id, l_competence_tab, l_resource_id);

          else

			        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   		    	iex_debug_pub.logmessage ('Calling Get_Resource! Bill To Level :Site Use ID ' || l_Object_ID);
              end if;
                                   --Bug5373412. Fix By LKKUMAR on 11-July-2006.Start.
		   		    --bReturn:=get_billto_resource(l_object_id,l_competence_tab,l_resource_id);
				    bReturn:=get_billto_resource(l_siteuse_id,l_competence_tab,l_resource_id);
                                   --Bug5373412. Fix By LKKUMAR on 11-July-2006.End.
          end if;

       end if;
       -- end for bug 8708271 pnaveenk multi level strategy
-- End - Kasreeni 01/17/2005 - Modified for multiple level resource check
-- End- Andre 07/28/2004 - Add bill to assignmnet

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('populate_schedule_times: ' || 'after get_resource and resource_id ='||
                                            l_resource_id);
           END IF;

          if l_resource_id is null then
             l_Resource_id := l_Default_Resource_ID;
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage ('populate_schedule_times: ' || 'Assigning Default resource_id ='|| l_resource_id);
             end if;
          end if;


          if l_resource_id is null then

               x_return_Status :=FND_API.G_RET_STS_ERROR;
               x_error_msg     := 'resource_id is Null';
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage ('populate_schedule_times: ' || 'resource id is null ');
               END IF;
               return;
           end if;

          -- resource id is found, ready for creating work item in
          -- the database.(finally)
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage ('populate_schedule_times: ' || 'ready to insert work items');
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage ('populate_schedule_times: ' || 'work_item_template_id'||c_get_witem_rec.work_item_template_id);
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage ('populate_schedule_times: ' || 'status_code'||c_get_witem_rec.status);
          END IF;

          l_strategy_work_item_rec.resource_id :=l_resource_id;
          l_strategy_work_item_rec.work_item_template_id
                                 :=c_get_witem_rec.work_item_template_id;
          l_strategy_work_item_rec.strategy_id := p_strategy_id;
       	  --begin bug#4506922 schekuri 06-Dec-2005
	  -- All work items are created as PRE-WAIT
          /*l_strategy_work_item_rec.status_code
                                :='OPEN';*/
	  l_strategy_work_item_rec.status_code
                                :='PRE-WAIT';
	  --end bug#4506922 schekuri 06-Dec-2005
          l_strategy_work_item_rec.strategy_temp_id :=p_template_id;
          l_strategy_work_item_rec.work_item_order  :=c_get_witem_rec.order_by;

          --populate schedule_start and schedule_end
            populate_schedule_times(
                    p_work_item_temp_id =>c_get_witem_rec.work_item_template_id,
                    itemtype            =>itemtype,
                    itemkey             =>itemkey,
                    x_schedule_start    =>x_schedule_start,
                    x_schedule_end      =>x_schedule_end);

          --populate notification_resource
                set_notification_resources(
                     p_resource_id    =>l_resource_id,
                     itemtype         =>itemtype,
                     itemkey          =>itemkey);

          -- Start Bug 6717880/7170165 by Ehuh
          begin

            Open c_get_accloc(p_strategy_id);
            Fetch c_get_accloc into l_acct_number,l_location;
            if c_get_accloc%NOTFOUND then null;
            else
                wf_engine.SetItemAttrText(
                                     itemtype  =>itemtype,
                                     itemkey   =>itemkey,
                                     aname     => 'ACCOUNT_NUMBER',
                                     avalue    => l_acct_number);

                wf_engine.SetItemAttrText(
                                     itemtype  =>itemtype,
                                     itemkey   =>itemkey,
                                     aname     => 'BILL_TO',
                                     avalue    => l_location);
            end if;
            close c_get_accloc;

          exception
            when others then null;
          end;
          -- End Bug 6717880/7170165  by Ehuh

          l_strategy_work_item_rec.schedule_start  :=x_schedule_start;
          l_strategy_work_item_rec.schedule_end    :=x_schedule_end;
          l_strategy_work_item_rec.execute_start   :=SYSDATE;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('before calling create_work_pvt.create');
END IF;

          iex_strategy_work_items_pvt.create_strategy_work_items
                   (P_Api_Version_Number     =>2.0,
                    P_Init_Msg_List          =>FND_API.G_TRUE,
                    P_Commit                 =>FND_API.G_FALSE,
                    p_validation_level       =>FND_API.G_VALID_LEVEL_FULL,
                    p_strategy_work_item_rec =>l_strategy_work_item_rec,
                    x_work_item_id           =>x_work_item_id,
                    x_return_status          =>l_return_status,
                    x_msg_count              =>l_msg_count,
                    x_msg_data               =>l_msg_data);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('after calling create_work_pvt.create');
          iex_debug_pub.logmessage ('and l_return_status from the pvt ='||l_return_status);
END IF;
          x_return_status :=l_return_Status;
          if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
             --update nextwork item i nthe strategy table
               IEX_STRY_UTL_PUB.UPDATE_NEXT_WORK_ITEM
                                         (p_api_version => l_api_version,
                                          p_init_msg_list => FND_API.G_TRUE,
                                          p_commit        => FND_API.G_FALSE,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          x_return_status => l_return_status,
                                          p_strategy_id   => p_strategy_id,
                                          p_work_item_id  => x_work_item_id);

                  wf_engine.SetItemAttrNumber(
                                     itemtype  =>itemtype,
                                     itemkey   =>itemkey,
                                     aname     => 'WORK_ITEMID',
                                     avalue    => x_work_item_id);

              if x_work_item_id is not null then
              begin
                select a.name,b.status_code into l_workitem_name , l_wkitem_status   ----bug#5874874 gnramasa
                from  IEX_STRY_TEMP_WORK_ITEMS_VL a, IEX_STRATEGY_WORK_ITEMS b
                where b.work_item_template_id = a.work_item_temp_id
                and b.work_item_id = x_work_item_id;

                 wf_engine.SetItemAttrText(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'WORK_ITEM_NAME',
                             avalue    => l_workitem_name);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('work_item_name' ||l_workitem_name);
END IF;

            --Begin bug#5874874 gnramasa 25-Apr-2007
	       --Update the UWQ summary table after creating workitem in OPEN status.
               if l_wkitem_status='OPEN' then
	           IEX_STRY_UTL_PUB.refresh_uwq_str_summ(x_work_item_id);
	       end if;
	       --End bug#5874874 gnramasa 25-Apr-2007

               exception
               when others then
                 null;
              end;
              end if;

                 -- if next work_item updation fails then also get the error message
                 -- get error message and passit pass it
                 --add new message
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    fnd_message.set_name('IEX', 'IEX_UPD_NEXT_WORK_ITEM_FAILED');
                    fnd_msg_pub.add;
                    FND_MSG_PUB.Count_And_Get
                      (  p_count          =>   l_msg_count,
                         p_data           =>   l_msg_data
                     );
                     Get_Messages(l_msg_count,x_error_msg);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     iex_debug_pub.logmessage('error message is ' ||x_error_msg);
END IF;
                 END IF;

                 -- reset activity_name attribute each time a work item is created
                 --06/26
                     wf_engine.SetItemAttrText(itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'ACTIVITY_NAME',
                                               avalue    => NULL);

           ELSE
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('X_MSG_COUNT' ||l_msg_count);
                iex_debug_pub.logmessage('X_MSG_DATA' ||l_msg_data);
END IF;
                -- get error message and passit pass it
                --

                --add new message
                fnd_message.set_name('IEX', 'IEX_METAPHOR_CREATION_FAILED');
                fnd_msg_pub.add;
                FND_MSG_PUB.Count_And_Get
                 (  p_count          =>   l_msg_count,
                    p_data           =>   l_msg_data
                 );

                Get_Messages(l_msg_count,x_error_msg);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('error message is ' || x_error_msg);
END IF;
           end if;
           EXIT;
      END IF;

     x_return_status :=l_return_Status;
    END LOOP;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('after calling create_work_pvt.create ' ||
                              'and   x_return status=>'||x_return_status );
END IF;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** END create_work_item ************');
END IF;
End  create_work_item;

-----------get the status of the process---------------------------------------
-- to see if the process is SUSPEND(wf_engine.eng_suspended )

PROCEDURE process_status (  p_process     in   varchar2,
                            p_itemtype    in   varchar2,
                            p_itemkey     in   varchar2,
                            x_status      out NOCOPY  varchar2) IS
rootid NUMBER;


BEGIN
     rootid :=Wf_Process_Activity.RootInstanceId(p_itemtype,
                                                 p_itemkey,
                                                 p_process);

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('process_status: ' || 'root is '||rootid);
     END IF;
     Wf_Item_Activity_Status.Status(p_itemtype
                                    ,p_itemkey
                                    ,rootid
                                    ,x_status);

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('process_status: ' || 'status is '||x_status);
     END IF;
EXCEPTION WHEN OTHERS THEN
-- send the status has active
   x_status :=wf_engine.eng_active;

END process_status;

--- populate strategy mailer record type
PROCEDURE populate_strategy_mailer
                 (itemtype IN VARCHAR2,
                  itemkey  IN VARCHAR2,
                  l_strategy_mailer_rec OUT NOCOPY iex_strategy_work_pub.STRATEGY_Mailer_Rec_Type) IS
BEGIN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage ('**** BEGIN populate_strategy_mailer ************');
        END IF;
        l_strategy_mailer_rec.strategy_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'STRATEGY_ID');

        l_strategy_mailer_rec.delinquency_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'DELINQUENCY_ID');


       l_strategy_mailer_rec.workitem_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'WORK_ITEMID');

       l_strategy_mailer_rec.user_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'USER_ID');

       l_strategy_mailer_rec.resp_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'RESP_ID');

       l_strategy_mailer_rec.resp_appl_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'RESP_APPL_ID');
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage ('populate_strategy_mailer: ' || 'resp_id ' || l_strategy_mailer_rec.resp_id ||
             ' USER_ID ' || l_strategy_mailer_rec.user_id||' APPL ID '
             ||l_strategy_mailer_rec.resp_appl_id);
         END IF;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END populate_strategy_mailer ************');
       END IF;
END populate_strategy_mailer;

--custom workflow record population
PROCEDURE populate_custom_workflow
                    (itemtype IN VARCHAR2,
                     itemkey  IN VARCHAR2,
                     p_custom_itemtype IN VARCHAR2,
                     l_custom_wf_rec OUT NOCOPY IEX_STRY_CUWF_PUB.CUSTOM_WF_Rec_Type) IS
BEGIN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage ('**** BEGIN populate_custom_workflow ************');
        END IF;
        l_custom_wf_rec.strategy_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'STRATEGY_ID');



       l_custom_wf_rec.workitem_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');

       l_custom_wf_rec.custom_itemtype := p_custom_itemtype;

       l_custom_wf_rec.user_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'USER_ID');

      l_custom_wf_rec.resp_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'RESP_ID');

       l_custom_wf_rec.resp_appl_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'RESP_APPL_ID');


--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('populate_custom_workflow: ' || 'strategy_id ' || l_custom_wf_rec.strategy_id);
       END IF;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('populate_custom_workflow: ' || 'workitem_id ' || l_custom_wf_rec.workitem_id);
       END IF;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('populate_custom_workflow: ' || 'custom_itemtype ' || l_custom_wf_rec.custom_itemtype);
       END IF;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('populate_custom_workflow: ' || 'resp_id ' || l_custom_wf_rec.resp_id ||
          ' USER_ID ' || l_custom_wf_rec.user_id||' APPL ID '
           ||l_custom_wf_rec.resp_appl_id);
       END IF;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END populate_custom_workflow ************');
       END IF;
END populate_custom_workflow;

-------------end of private procedures and funtion -------------------------
------------- PUBLIC PROCEDURES---------------------------------------------

-----get messages from the server side-----------------
PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(5000) ;
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(50) ;
      l_message_name    VARCHAR2(30) ;
      l_id              NUMBER;
      l_message_num     NUMBER;
  	  l_msg_count       NUMBER;
	  l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN
  -- initialize variable
      l_msg_list := '';

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** BEGIN Get_Messages ************');
      END IF;
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;
          l_message_num := NULL;

          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_msgs := l_msg_list;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('Get_Messages: ' || 'L_MSG_LIST'||l_msg_list);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** END Get_Messages ************');
      END IF;
END Get_Messages;



----------- procedure check_work_items_completed ------------------------------
/**
 * check to see if there are any pending
 * work items to be processed
 **/
procedure check_work_items_completed(
                                      itemtype    in   varchar2,
                                      itemkey     in   varchar2,
                                      actid       in   number,
                                      funcmode    in   varchar2,
                                      result      out NOCOPY  varchar2) IS



cursor c_get_strat_template_id (p_strategy_id NUMBER) IS
select strategy_template_id from iex_strategies
where  strategy_id =p_strategy_id;


cursor c_get_next_witem(p_strategy_id NUMBER,
                        p_template_id NUMBER)
is
/*select sxref.strategy_temp_id TEMPLATE_ID,
       sxref.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
       sxref.work_item_order ORDER_BY
       ,nvl(swit.status_code,'NOTCREATED') STATUS
       ,swit.work_item_id     WORK_ITEM_ID
       ,swit.strategy_id      STRATEGY_ID
from iex_strategy_work_temp_xref sxref
     ,iex_strategy_work_items swit
where sxref.strategy_temp_id =p_template_id
and   swit.work_item_template_id(+)  =sxref.work_item_temp_id
and   swit.strategy_id(+) =p_strategy_id
union all
select susit.strategy_template_id TEMPLATE_ID,
       susit.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
       susit.work_item_order ORDER_BY
       ,nvl(swit.status_code,'NOTCREATED') STATUS
       ,swit.work_item_id     WORK_ITEM_ID
       ,susit.strategy_id      STRATEGY_ID
  from iex_strategy_user_items susit
     ,iex_strategy_work_items swit
where susit.strategy_id =p_strategy_id
and   swit.work_item_template_id(+)  =susit.work_item_temp_id
and   swit.strategy_id(+) =p_strategy_id
order by order_by;
*/

--created work items
SELECT wkitem.strategy_id     STRATEGY_ID,
wkitem.strategy_temp_id       TEMPLATE_ID,
wkitem.work_item_order        ORDER_BY,
wkitem.work_item_id           WORK_ITEM_ID,
wkitem.work_item_template_id  WORK_ITEM_TEMPLATE_ID,
wkitem.status_code            STATUS
from iex_strategy_work_items wkitem,
iex_stry_temp_work_items_vl stry_temp_wkitem
WHERE
wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
and wkitem.strategy_id =p_strategy_id
--to be created work items
union all
SELECT stry.STRATEGY_ID       STRATEGY_ID
, xref.STRATEGY_TEMP_ID       TEMPLATE_ID
, xref.WORK_ITEM_ORDER        ORDER_BY
, TO_NUMBER(NULL)             WORK_ITEM_ID
, xref.WORK_ITEM_TEMP_ID      WORK_ITEM_TEMPLATE_ID
, 'NOTCREATED'                STATUS
FROM IEX_STRATEGIES stry
, IEX_STRATEGY_WORK_TEMP_XREF xref
, IEX_STRY_TEMP_WORK_ITEMS_VL stry_temp_wkitem
WHERE stry.STRATEGY_TEMPLATE_ID = xref.STRATEGY_TEMP_ID
and xref.WORK_ITEM_TEMP_ID = stry_temp_wkitem.WORK_ITEM_TEMP_ID
and stry.strategy_id =p_strategy_id
--not in workitems table
AND not exists ( select 'x' from iex_strategy_work_items wkitem where
wkitem.strategy_id = stry.strategy_id
and wkitem.work_item_template_id = xref.work_item_temp_id
and wkitem.work_item_order = xref.work_item_order
and  wkitem.strategy_id =p_strategy_id
)
----skip workitems which is status-ed SKIP
and not exists ( select 'x' from iex_strategy_user_items uitems where
uitems.strategy_id = stry.strategy_id  and
uitems.work_item_temp_id = xref.work_item_temp_id and
uitems.work_item_order = xref.work_item_order and
uitems.operation = 'SKIP'
and  uitems.strategy_id =p_strategy_id
)
and (xref.work_item_order > (select max(wkitem_order) from iex_work_item_bali_v
     where strategy_id = p_strategy_id and start_time is not null)
   or (select count(*) from iex_work_item_bali_v where strategy_id = p_strategy_id ) = 0
    )      -- later on assignment of  prior work items, and case of initial creation of wkitem
-- get all user items
union all
SELECT stry.STRATEGY_ID          STRATEGY_ID
, uitem.STRATEGY_TEMPLATE_ID     TEMPLATE_ID
, uitem.WORK_ITEM_ORDER          ORDER_BY
, TO_NUMBER(NULL)                WORK_ITEM_ID
, uitem.WORK_ITEM_TEMP_ID        WORK_ITEM_TEMPLATE_ID
, uitem.operation                   STATUS
FROM IEX_STRATEGIES stry
, IEX_STRATEGY_user_items uitem
, IEX_STRY_TEMP_WORK_ITEMS_VL stry_temp_wkitem
WHERE stry.STRATEGY_ID = uitem.STRATEGY_ID
and uitem.WORK_ITEM_TEMP_ID = stry_temp_wkitem.WORK_ITEM_TEMP_ID
and stry.strategy_id =p_strategy_id
AND not exists
-- exclude useritem whoch is already a workitem
( select 'x' from iex_strategy_work_items wkitem
where wkitem.strategy_id = stry.strategy_id
and wkitem.work_item_template_id = uitem.work_item_temp_id
and uitem.work_item_order = wkitem.work_item_order
and wkitem.strategy_id =p_strategy_id)
order by ORDER_BY;

l_strategy_id NUMBER ;
l_count       NUMBER :=0;
l_strategy_status VARCHAR2(100);
l_strategy_template_id NUMBER;
l_work_item_id  NUMBER ;
l_value VARCHAR2(300);

Begin

 if funcmode <> 'RUN' then
   result := wf_engine.eng_null;
   return;
 end if;

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('**** BEGIN check_work_items_completed  ************');
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('check_work_items_completed: ' || 'ITEMTYPE =>'||itemtype);
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('check_work_items_completed: ' || 'ITEMKEY =>'||itemkey);
END IF;

/* l_value :=wf_engine.GetActivityLabel(actid);
 wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logMessage('check_work_items_completed: ' || 'ACTIVITYNAME' ||l_value);
END IF;
*/

 -- if the l_work_item_id is NULL
-- don't check for pending work items
-- set result to 'Y' indicating there are no pending
-- items.The next node in the workflow 'close_strategy'
-- will close the pending work items to the right status
--- depending on the strategy_status attribute which is set in
--send_signal process

/**
* 04/17/02
* if the strategy status is changed to 'OPEN' from ONHOLD
* work item id is not passed, but we still have to
* check for pending work item if status is 'OPEN'
**/

l_strategy_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_STATUS');


l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');


--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('in check_work_items_completed and '||
                          'l_work_item_id =>'||l_work_item_id);
END IF;

IF l_work_item_id IS NULL and l_strategy_status <> 'OPEN' THEN
     result := wf_engine.eng_completed||':'||wf_yes;
     return;
END IF;



 ---get strategy_id from the work flow

l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('check_work_items_completed: ' || 'strategy id =>'||l_strategy_id);
END IF;

--get strategy template id
OPEN c_get_strat_template_id (l_strategy_id);
FETCH c_get_strat_template_id INTO l_strategy_template_id;
CLOSE c_get_strat_template_id;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('check_work_items_completed: ' || 'template id =>'||l_strategy_template_id);
END IF;

--get the work items along with the status
   FOR c_get_witem_rec in c_get_next_witem
                            (l_strategy_id,
                             l_strategy_template_id )
    LOOP
         IF c_get_witem_rec.status IN ('NOTCREATED') THEN
            -- NOT IN ('COMPLETE','CANCELLED','TIMEOUT','SKIP') THEN
            -- there are pending work items to be processed
            result := wf_engine.eng_completed ||':'||wf_no;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('check_work_items_completed: ' || 'there are pending witems to be created and result is'||
             '=>'||result);
            END IF;
            return;
         END IF;

    END LOOP;
    result := wf_engine.eng_completed ||':'||wf_yes;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('check_work_items_completed: ' || 'result =>'||result);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** END check_work_items_completed  ************');
    END IF;
exception
  when others then
   wf_core.context('IEX_STRATEGY_WF','check_work_items_completed',itemtype,
                    itemkey,to_char(actid),funcmode);
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('check_work_items_completed: ' || 'in error');
  END IF;
   raise;

end check_work_items_completed;


----------- procedure close_strategy ------------------------------
/**
 * Close all the pending work items
 * and close the strategy
 * if the update fails , go and wait
 * for the signal again
 **/

procedure close_strategy(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS


l_strategy_id NUMBER ;
l_api_version   NUMBER       := 1.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_strategy_status VARCHAR2(100);
l_work_item_id NUMBER ;
l_value VARCHAR2(300);
l_error VARCHAR2(32767);

Begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** BEGIN close_strategy  ************');
 END IF;
 if funcmode <> 'RUN' then
   result := wf_engine.eng_null;
   return;
 end if;

/*l_value :=wf_engine.GetActivityLabel(actid);
 wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logMessage('close_strategy: ' || 'ACTIVITYNAME' ||l_value);
 END IF;
 */

 ---get strategy_id from the work flow

l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');

l_strategy_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_STATUS');

l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');


--if l_work_item id NULL then ,close or cancel strategy and the
--pending work items. The action 'CANCEL ' or 'CLOSE is based on the
-- the value of l_strategy_status.

-- if the l_work_item is not null then, it means all the pending work items are processed
-- update the stategy_status to 'CLOSED'

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage('close_strategy: ' || ' close strategy procedure and status is =>'||l_strategy_status);
  END IF;

   IF l_work_item_id IS NOT NULL  THEN
   -- normal processing, all work items are done
   --set the l_strategy_status to 'CLOSED'
      l_strategy_status := 'CLOSED';

   END IF;

   IEX_STRY_UTL_PUB.CLOSE_STRY_AND_WITEMS(p_api_version => l_api_version,
                                          p_init_msg_list => FND_API.G_TRUE,
                                          p_commit        => FND_API.G_FALSE,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          x_return_status => l_return_status,
                                          p_strategy_id   => l_strategy_id,
                                          p_status        => l_strategy_status);


--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage('close_strategy: ' || ' close strategy procedure and x_status is =>'||l_return_status);
   END IF;

   -- if the result is 'N' then go back to
   -- sleep or wait mode
     if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        result := wf_engine.eng_completed ||':'||wf_yes;
     else
         result := wf_engine.eng_completed ||':'||wf_no;
          --set the strategy_status back to 'OPEN'
          --and go back to sleep mode
         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'STRATEGY_STATUS',
                                   avalue    => 'OPEN');

      --pass the error message
      -- get error message and passit
      --add new message
       fnd_message.set_name('IEX', 'IEX_CLOSE_STRATEGY_FAILED');
       fnd_msg_pub.add;
       FND_MSG_PUB.Count_And_Get
                   (  p_count          =>   l_msg_count,
                      p_data           =>   l_msg_data
                   );
         Get_Messages(l_msg_count,l_error);
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('close_strategy: ' || 'error message is ' || l_error);
         END IF;

         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

     end if;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('**** END close_strategy  ************');
      END IF;
exception
  when others then
   wf_core.context('IEX_STRATEGY_WF',' close_strategy ',itemtype,
                    itemkey,to_char(actid),funcmode);
   raise;

end close_strategy;


----------- procedure create_next_work_item------------------------------
/**
 * Get the next work item for the strategy
 * from work_item_template,user_work_item for a given strategy
 * get resource id for the given strategy
 * for the  matching competence id vcrom work item template
 * creates the work item in strategy_work_items table
 * update the attribute work_item_id in the workflow with the
 * create workitem_id.
 **/
procedure create_next_work_item(
                             itemtype    in   varchar2,
                             itemkey     in   varchar2,
                             actid       in   number,
                             funcmode    in   varchar2,
                             result      out NOCOPY  varchar2) IS

l_api_version   NUMBER       := 1.0;
l_init_msg_list VARCHAR2(1)  ;
l_commit VARCHAR2(1)         ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

l_strategy_id   NUMBER;
l_party_id      NUMBER;
l_strategy_template_id NUMBER;
l_error        VARCHAR2(32767);

cursor c_get_strat_template_id (p_strategy_id NUMBER) IS
select strategy_template_id from iex_strategies
where  strategy_id =p_strategy_id;
l_value VARCHAR2(300);
Begin
  -- initialize variable
  l_init_msg_list := FND_API.G_TRUE;
  l_commit := FND_API.G_TRUE;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** BEGIN create_next_work_item  ************');
     END IF;
 if funcmode <> 'RUN' then
   result := wf_engine.eng_null;
   return;
 end if;

 /*l_value :=wf_engine.GetActivityLabel(actid);
 wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logMessage('create_next_work_item: ' || 'ACTIVITYNAME' ||l_value);
END IF;
*/

 ---get strategy_id from the work flow
l_strategy_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_ID');

 ---get party_id from the work flow
l_party_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'PARTY_ID');


--get next strategy_template_id
OPEN c_get_strat_template_id (l_strategy_id);
FETCH c_get_strat_template_id INTO l_strategy_template_id;
CLOSE c_get_strat_template_id;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage('create_next_work_item: ' || 'in create next work item');
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage('create_next_work_item: ' || 'before calling create work item private proc');
END IF;

--create work item in the database
create_work_item (itemtype,
                  itemkey,
                  l_strategy_id,
                  l_strategy_template_id,
                  l_party_id,
                  l_return_status,
                  l_error);

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_next_work_item: ' || ' creation of work items and status => '||l_return_status);
END IF;

if l_return_status <>FND_API.G_RET_STS_SUCCESS THEN
     result := wf_engine.eng_completed ||':'||wf_no;
     --pass the error message
       wf_engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'ERROR_MESSAGE',
                                 avalue    => l_error);

else
     result := wf_engine.eng_completed ||':'||wf_yes;

end if;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_next_work_item: ' || ' RESULT IS  => '||result);
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('**** END create_next_work_item  ************');
END IF;
exception
  when others then
   wf_core.context('IEX_STRATEGY_WF',' create_next_work_item',itemtype,
                    itemkey,to_char(actid),funcmode);
   raise;

end create_next_work_item;

----------- procedure wait_signal ------------------------------
procedure wait_signal(
                       itemtype    in   varchar2,
                       itemkey     in   varchar2,
                       actid       in   number,
                       funcmode    in   varchar2,
                       result      out NOCOPY  varchar2) IS

l_value VARCHAR2(300);
Begin
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** BEGIN WAIT_SIGNAL ************');
 END IF;
 if funcmode <> 'RUN' then
   result := wf_engine.eng_null;
   return;
 end if;

/*l_value :=wf_engine.GetActivityLabel(actid);
 wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logMessage('wait_signal: ' || 'ACTIVITYNAME' ||l_value);
END IF;
*/

 --- suspend process
  wf_engine.SuspendProcess(
                           itemtype  => itemtype,
                           itemkey   => itemkey);
  -- 05/10/02 the form doesnot know the workflow is
  -- suspended, so trying to issue a commit to see
  --if it works.
  --COMMIT;
  result := wf_engine.eng_completed ||':'||wf_yes;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** END WAIT_SIGNAL ************');
  END IF;
exception
  when others then
   wf_core.context('IEX_STRATEGY_WF','wait_signal',itemtype,
                    itemkey,to_char(actid),funcmode);
   raise;

end wait_signal;


/**
 * check whether the work item  has post execution wait
 **/
procedure wait_complete_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** START wait_complete_signal ************');
END IF;
    if funcmode <> wf_engine.eng_run then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('SECOND TIME FUNCMODE' ||funcmode);
END IF;
        result := wf_engine.eng_null;
        return;
    end if;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage('FUNCMODE' ||funcmode);
END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('ACTIVITYNAME' ||l_value);
END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** END wait_complete_signal ************');
END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','wait_complete_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  wait_complete_signal;




/**
 * This will be called from the form or the concurrent program
 * once the work item
 * status is changed or if the strategy is closed or cancelled
 * if the work item is null ,then the strategy and the pending
 * work items are to be closed/cancelled
 * else just complete or cancel the work item only
 *03/19/02
 * --sub process addition --
 * if it is waiting for optional check or escalate check
 * then we have not reached the wait for response activity
 * or the process is not suspended so these are the things we should do
 * 1.DO NOT resume process
 * 2.Complete activity (depending on the activity label - this will be
 * either escalate_check or optional_check)
 * then the subprocess will be completed
 *04/02/2002
 * add a new parameter signal_source for custom work flow and fulfilment work flow
 * check if the agent has already changed the work item status before the completion
 *of custom or fulfillment wf's.then do nothing ,else update workitem and resume process
 * If the strategy is ON-HOLD' or 'OPEN' THEN do not resume process, the agent will update the
 *work item and update the strategy to 'OPEN' .
 *04/08/02
 * abort fulfilment and custom workflow when agent updates fulfilment or custom workitem
 *04/16/02
 *if the strategy status is 'OPEN' THEN resume process and it is ON-HOLD then do not resume,
 * remain suspended
 04/18/02
 -- if the strategy is changed from on hold to OPEN and if the current work item has
 -- aleady completed ( changed the status from 'OPEN to CCANCELLED, CLOSED, TIMEOUT),
 -- then resume the process, othere wise remain suspended.
 **/
--04/26/02  check if activity label is null before resuming process
-- agent is not going to do update, so send signal will do it.
--07/31/02 --abort the strategy workflow if the workflow is active or
--in error
procedure send_signal(
                         process     in   varchar2 ,
                         strategy_id in   varchar2,
                         status      in   VARCHAR2,
                         work_item_id in number ,
                         signal_source in varchar2 ) IS
l_result VARCHAR2(100);
l_Status VARCHAR2(8);
l_activity_label VARCHAR2(100);

Begin
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START WAIT_SIGNAL ************');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('wait_signal: ' || 'status' ||status ||'workitemid  ' ||work_item_id || '**'||
                                'signal source '||signal_source||'strategy_id' ||strategy_id);
     END IF;

     wf_engine.itemstatus(itemtype  => process,
                          itemkey   => strategy_id,
                          status    =>l_status,
                          result    =>l_result);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('wait_signal: ' || 'status ofthe process  '|| l_status);
    END IF;

 --- resume process only if it is suspend
 -- check for other than fulfilment and custom work flow

  IF l_status =wf_engine.eng_suspended THEN

       --check if the signal_source is fulfillment or optional
       if signal_source in ('FULFILLMENT','CUSTOM') THEN
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('wait_signal: ' || 'signal source  '|| signal_source);
          END IF;
           -- the agent has not updated the current work item
              l_result := CHECK_CURRENT_WORK_ITEM(strategy_id,work_item_id);
           IF  l_result >0 THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('wait_signal: ' || 'agent has not updated the work item');
               END IF;
               -- do not call update since custom or fulfilment is going to update it
               --update_workitem_Status(work_item_id,status );
           else
               --agent has updated and we are on the next work item or the strategy is
               --closed or complete, or ON HOLD
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('wait_signal: ' || 'agent has updated the work item');
               END IF;
               return;
           END IF;

       else  -- signal source is null
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('wait_signal: ' || 'signal source is null');
            END IF;
            if work_item_id is NULL THEN
               -- the status could be ON-HOLD or 'OPEN' (from promises API)
                  If  status IN ('CLOSED','CANCELLED') THEN
                      -- strategy is being closed or cancelled
                      -- complete fulfilment and custom has to be aborted
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('wait_signal: ' || 'work item is null');
                      END IF;
                    --abort custom or fulfillment wfs' if they are not completed
                      abort_processes(strategy_id);
                 elsif status ='ONHOLD' THEN
                         --continue being suspended
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logmessage('wait_signal: ' || 'work item is null and status is '||status);
                        END IF;
                        return;
                  else  --status is OPEN
                        --if it is open resume process only if the existing work item has been
                         -- completed, otherwise remain suspended.
                         l_result := CHECK_WORK_ITEM_OPEN(strategy_id);
                         IF  l_result >0 THEN
                            --remain suspended, do nothing
--                            IF PG_DEBUG < 10  THEN
                            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                               iex_debug_pub.logmessage('wait_signal: ' || 'work item is still open ');
                            END IF;
                            return;
                         else
                             --work item has completed, resume process
--                             IF PG_DEBUG < 10  THEN
                             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                iex_debug_pub.logmessage('wait_signal: ' || 'work item has been completed');
                             END IF;
                         END IF;
                 end if; -- status check
            else
                 --04/08/02 abort the process if it is custom or fulfilment
                 -- maybe the agent can indicate if it is custom or fulfilment
                 --work item . this portion is not there .so call abort on the
                 -- strategy_id.
                 -- 04/26/02 -- update work item
                 --update_workitem_Status(work_item_id,status );
                 abort_processes(strategy_id);
            end if;--work item id is null
       end if; -- signal source check

      wf_engine.SetItemAttrText(itemtype  => process,
                             itemkey   =>  strategy_id,
                             aname     => 'STRATEGY_STATUS',
                             avalue    => status);

      wf_engine.SetItemAttrNumber(itemtype  => process,
                             itemkey   =>  strategy_id,
                             aname     => 'WORK_ITEMID',
                             avalue    => work_item_id);

       wf_engine.ResumeProcess(itemtype  => process,
                               itemkey   =>  strategy_id);

        --COMMIT; -- the work flow was not going to end from the close strategy

  ELSIF  l_status =wf_engine.eng_active THEN

       --complete the current activity
       --this will be either complete the ESCALATE_CHECK
       --OR OPTIONAL_CHECK activity
       --get the label first. ( the name of the activity is set in
       --the attribute)
       -- the fulfilment or custom work flow might send the signal later
       -- do not do anything if the process is active.

       if signal_source in ('FULFILLMENT','CUSTOM') THEN
           return;
       else  -- signal source is null
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('wait_signal: ' || 'signal source is null');
            END IF;
            if work_item_id is NULL THEN
               -- the status could be ON-HOLD or 'OPEN' (from promises API)
                  If  status IN ('CLOSED','CANCELLED') THEN
                      -- strategy is being closed or cancelled
                      -- complete fulfilment and custom has to be aborted
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('wait_signal: ' || 'work item is null');
                      END IF;
                 else
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logmessage('wait_signal: ' || 'work item is null and status is '||status);
                        END IF;
                        return;
                 end if; -- status check
            else
                 --04/08/02 abort the process if it is custom or fulfilment
                 -- maybe the agent can indicate if it is custom or fulfilment
                 --work item . this portion is not there .so call abort on the
                 -- strategy_id.
--                 IF PG_DEBUG < 10  THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('wait_signal: ' || 'work item is not null ');
                 END IF;
                 --05/10 if sendsiganl fails we don't want to abort process
                 --so abort shoud be part of complete activity and send signal want complete
                 --activity without the label being set.

            end if;--work item id is null

            l_activity_label := wf_engine.GetItemAttrText(
                                           itemtype  => process,
                                           itemkey   => strategy_id,
                                           aname     => 'ACTIVITY_NAME');
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('wait_signal: ' || 'BEFORE CALLING COMPLETE ACTIVITY');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('wait_signal: ' || process ||strategy_id||l_activity_label);
            END IF;

           wf_engine.SetItemAttrText(itemtype  => process,
                                     itemkey   =>  strategy_id,
                                     aname     => 'STRATEGY_STATUS',
                                     avalue    => status);

          wf_engine.SetItemAttrNumber(itemtype  => process,
                                     itemkey   =>  strategy_id,
                                     aname     => 'WORK_ITEMID',
                                     avalue    => work_item_id);

          -- 04/26/02
          -- change strategy from the UI, then send signal was failing
          --check value of activity label before resuming process
          If l_activity_label IS NOT NULL  THEN
             abort_processes(strategy_id); -- added on 05/10/02
             wf_engine.CompleteActivity(
                                        itemtype    => process,
                                        itemkey     => strategy_id,
                                        activity    =>l_activity_label,
                                        result      =>'Yes');
          ELSE
             --07/31/02
             --abort the strategy workflow
             --update the work items,
             --close or cancel strategy
             --abort all the custom workflows
             --this will happen if the workflow failed before
             --being suspended, for example if notification
             -- does not have a performer.
             -- Bug 7703319 by Ehuh
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('l_activity is NULL ..... ');
             END IF;
             CLOSE_AND_ABORT_STRATEGY_WF(strategy_id,status);
             --return;
         end if;

      end if; --signal_source

  ELSIF  l_status =wf_engine.eng_error THEN
         CLOSE_AND_ABORT_STRATEGY_WF(strategy_id,status);
         NULL;
       --COMMIT; -- the work flow was not going to end from the close strategy
  END IF; -- item status
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** END WAIT_SIGNAL ************');
END IF;

exception
  when others then
   wf_core.context('IEX_STRATEGY_WF','send_signal',process,
                    strategy_id,to_char(111),'RUN');
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('Error in SEND_SIGNAL  -->' ||sqlerrm);
END IF;
   raise;

end send_signal;

/**
 * check whether there is a custom worlflow attached
 **/
procedure CUSTOM_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS
l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);
l_custom_wf_rec IEX_STRY_CUWF_PUB.custom_wf_Rec_Type;
l_return_status VARCHAR2(1) ;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_custom_itemtype VARCHAR2 (100);
--Added for bug#4506922
L_STATUS_CODE VARCHAR2(25);
l_work_item_id NUMBER(25);
BEGIN
  -- initialize variable
  l_return_status :=FND_API.G_RET_STS_SUCCESS;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START CUSTOM_CHECK ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      /* Begin 06-dec-2005 schekuri bug 4506922 - All work items are created as PRE-WAIT */
      l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'WORK_ITEMID');

     SELECT STATUS_CODE INTO l_status_code FROM IEX_STRATEGY_WORK_ITEMS WHERE WORK_ITEM_ID = l_work_item_id;

     if (l_status_code = 'PRE-WAIT') THEN
     BEGIN

        UPDATE IEX_STRATEGY_WORK_ITEMS SET STATUS_CODE = 'OPEN' WHERE WORK_ITEM_ID = l_work_item_id;
	--Begin bug#5874874 gnramasa 25-Apr-2007
	--Update the UWQ summary table after workitem's status changes to OPEN from PRE-WAIT.
        IEX_STRY_UTL_PUB.refresh_uwq_str_summ(l_work_item_id);
        --End bug#5874874 gnramasa 25-Apr-2007
        commit work;
     END;
     END IF;

      /* End 06-dec-2005 schekuri bug 4506922 - All work items are created as PRE-WAIT */

     /* l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CUSTOM_CHECK: ' || 'ACTIVITYNAME' ||l_value);
     END IF;
     */
       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       select decode(workflow_item_type,null,'N','Y'),
       workflow_item_type INTO l_result,l_custom_itemtype
       from iex_stry_temp_work_items_vl
       where work_item_temp_id =l_work_item_temp_id;

       --start custom work flow process
       If l_result = wf_yes THEN
          populate_custom_workflow (itemtype,
                                    itemkey,
                                    l_custom_itemtype,
                                    l_custom_wf_rec);

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('CUSTOM_CHECK: ' || 'before calling custom workflow');
          END IF;

          IEX_STRY_cuwf_pub.Start_CustomWF
                    (
                      p_api_version         =>1.0,
                      p_init_msg_list       => FND_API.G_TRUE,
                      p_commit              => FND_API.G_FALSE,
                      p_custom_wf_rec       =>l_custom_wf_rec,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data,
                      x_return_status       => l_return_status);
        End if;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('CUSTOM_CHECK: ' || 'End of custom work flow ');
       END IF;
       result := wf_engine.eng_completed ||':'||l_result;
       return;
--       result := wf_engine.eng_completed ||':'||l_result;

        -- don't check for result, what ever is the outcome
        -- go and wait, the UI will relaunch the custom workflow

        /*    if l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                result := wf_engine.eng_completed ||':'||wf_yes;
            else
                result := wf_engine.eng_completed ||':'||wf_no;
            end if;

      */


--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END CUSTOM_CHECK ************');
       END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','CUSTOM_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  CUSTOM_CHECK;

/**
 * check whether the fulfil_temp_id is populated for this work item
 *
 **/
procedure FULFIL_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2)IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_fulfil_temp_id NUMBER;
l_value VARCHAr2(300);
l_strategy_mailer_rec iex_strategy_work_pub.STRATEGY_Mailer_Rec_Type;
l_return_status VARCHAR2(1) ;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_curr_dmethod varchar2(10);

BEGIN
  -- initialize variable
  l_return_status :=FND_API.G_RET_STS_SUCCESS;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START FULFIL_CHECK ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

     /* l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('FULFIL_CHECK: ' || 'ACTIVITYNAME' ||l_value);
     END IF;
     */

       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       l_curr_dmethod := iex_send_xml_pvt.getCurrDeliveryMethod();
       if (l_curr_dmethod = 'FFM') then
         select decode(fulfil_temp_id,null,'N',wf_yes),fulfil_temp_id
         INTO l_result,l_fulfil_temp_id
         from iex_stry_temp_work_items_vl
         where work_item_temp_id =l_work_item_temp_id;
       else
         select decode(xdo_template_id,null,'N',wf_yes),xdo_template_id
         INTO l_result,l_fulfil_temp_id
         from iex_stry_temp_work_items_vl
         where work_item_temp_id =l_work_item_temp_id;
       end if;

       --start fulfilment process
       If l_result = wf_yes THEN
          populate_strategy_mailer (itemtype,itemkey,l_strategy_mailer_rec);
          --fulfilment ID -- xdo_template_id

          if (l_curr_dmethod = 'FFM') then
            l_strategy_mailer_rec.template_id  := l_fulfil_temp_id;
          else
            l_strategy_mailer_rec.xdo_template_id  := l_fulfil_temp_id;
          end if;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('FULFIL_CHECK: ' || 'fulful template id' ||l_fulfil_temp_id);
          END IF;
           iex_strategy_work_pub.strategy_mailer(
                     p_api_version         =>1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_TRUE,
                     p_strategy_mailer_rec => l_strategy_mailer_rec,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     x_return_status       => l_return_status);

       End if;

       result := wf_engine.eng_completed ||':'||l_result;

        -- don't check for result, what ever is the outcome
        -- go and wait, the UI will relaunch the fulilment workflow

        /*    if l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                result := wf_engine.eng_completed ||':'||wf_yes;
            else
                result := wf_engine.eng_completed ||':'||wf_no;
            end if;

      */


--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END FULFIL_CHECK ************');
       END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','FULFIL_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  FULFIL_CHECK;


/*  calculate the post execution wait
 *
 **/
procedure cal_post_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2)IS

l_work_item_temp_id NUMBER;
l_work_item_id  NUMBER ;

l_result VARCHAR2(1);
l_fulfil_temp_id NUMBER;
l_value VARCHAr2(300);
l_strategy_mailer_rec iex_strategy_work_pub.STRATEGY_Mailer_Rec_Type;
l_return_status VARCHAR2(1) ;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_execution_time date;
l_post_execution_wait  IEX_STRY_TEMP_WORK_ITEMS_VL.post_execution_wait%type := 0.0;
l_execution_time_uom  IEX_STRY_TEMP_WORK_ITEMS_VL.execution_time_uom%type;
l_conversion mtl_uom_conversions.conversion_rate%type := 0.0;
l_return VARCHAR2(1);
l_strategy_status varchar2(100);
l_curr_dmethod varchar2(10);

BEGIN
  -- initialize variable
  l_return_status :=FND_API.G_RET_STS_SUCCESS;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** START cal_post_wait ************');
END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_strategy_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                             itemkey   =>  itemkey,
                             aname     => 'STRATEGY_STATUS');

      l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'WORK_ITEMID');

      if l_strategy_status = 'CANCELLED' then
          --Begin bug#5874874 gnramasa 25-Apr-2007
          --Update the UWQ summary table after CANCELLING the strategy.
          if l_work_item_id is not null then
		  IEX_STRY_UTL_PUB.refresh_uwq_str_summ(l_work_item_id);
	  end if;
	  --End bug#5874874 gnramasa 25-Apr-2007
          l_return := wf_no;
          result := wf_engine.eng_completed ||':'||l_return;
          return;
      end if;

       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('cal_post_wait workitemtempid = ' ||l_work_item_temp_id);
     END IF;

	--Begin bug#5502077 schekuri 30-Apr-2007
	--If the Fulfillment workitem has post execution wait time, it should wait after completion
	--of workitem in the main workflow only. It shouldn't wait in the fulfillment workflow.
     --  xdo check
     /*begin
       l_curr_dmethod := iex_send_xml_pvt.getCurrDeliveryMethod();
       if (l_curr_dmethod = 'FFM') then
           select decode(fulfil_temp_id,null,'N',wf_yes),fulfil_temp_id
           INTO l_result,l_fulfil_temp_id
           from iex_stry_temp_work_items_vl
           where work_item_temp_id =l_work_item_temp_id;
       else
           select decode(xdo_template_id,null,'N',wf_yes),xdo_template_id
           INTO l_result,l_fulfil_temp_id
           from iex_stry_temp_work_items_vl
           where work_item_temp_id =l_work_item_temp_id;
       end if;
     exception
     when others then
         l_result := wf_no;
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logMessage('cal_post_wait GET FULFILLMENT ERROR ');
          END IF;
     end;

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('cal_post_wait l_result = ' ||l_result);
     END IF;

       --start fulfilment process
       If l_result = wf_yes THEN
          select sysdate into l_execution_time from dual;
          l_return := wf_no;
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logMessage('cal_post_wait l_execution_time = ' ||l_execution_time);
          END IF;
       else*/
       --End bug#5502077 schekuri 30-Apr-2007
         begin
           select a.post_execution_wait, a.execution_time_uom
           into l_post_execution_wait, l_execution_time_uom
           from  IEX_STRY_TEMP_WORK_ITEMS_VL a, IEX_STRATEGY_WORK_ITEMS b
           where b.work_item_template_id = a.work_item_temp_id
           and b.work_item_id = l_work_item_id;
         exception
         when others then
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logMessage('cal_post_wait get execution time error ');
           END IF;
         end;

         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('fulfil_check post_execution_wait = ' ||l_post_execution_wait);
                  iex_debug_pub.logMessage('fulfil_check execution_time_uom = ' ||l_execution_time_uom);
         END IF;
         if (l_post_execution_wait = 0) then
           l_return := wf_no;
         else
           begin
           l_execution_time:= IEX_STRY_UTL_PUB.get_Date
                               (p_date =>sysdate,
                                l_UOM  =>l_execution_time_uom,
                                l_UNIT =>l_post_execution_wait);
           exception
           when others then
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          iex_debug_pub.logMessage('cal_post_wait convert date error ');
             END IF;
           end;
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('fulfil_check l_execution_time = ' ||l_execution_time);
             END IF;

           l_return := wf_yes;
         end if;

       --End if;  --Removed if for bug#5502077 schekuri 30-Apr-2007

          wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'EXECUTION_TIME',
                                 avalue    => l_execution_time);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('cal_post_wait result = ' ||l_return);
      END IF;

      --Begin bug#5874874 gnramasa 25-Apr-2007
      --Update the UWQ summary table after completing the workitem.
          if l_work_item_id is not null then
		  IEX_STRY_UTL_PUB.refresh_uwq_str_summ(l_work_item_id);
	  end if;
      --End bug#5874874 gnramasa 25-Apr-2007

      result := wf_engine.eng_completed ||':'||l_return;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('**** END cal_post_wait ************');
      END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','cal_post_wait',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;



END  cal_post_wait;


/*  calculate the pre execution wait
 *
 **/
procedure cal_pre_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2)IS

l_work_item_temp_id NUMBER;
l_work_item_id  NUMBER ;

l_schedule date;
l_pre_execution_wait  IEX_STRY_TEMP_WORK_ITEMS_VL.pre_execution_wait%type := 0.0;
l_schedule_uom  IEX_STRY_TEMP_WORK_ITEMS_VL.schedule_uom%type;
l_return VARCHAR2(1);
l_strategy_status varchar2(100);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** START cal_pre_wait ************');
END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_strategy_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                             itemkey   =>  itemkey,
                             aname     => 'STRATEGY_STATUS');
      if l_strategy_status = 'CANCELLED' then
          l_return := wf_no;
          result := wf_engine.eng_completed ||':'||l_return;
          return;
      end if;

       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'WORK_ITEMID');

       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('cal_pre_wait workitemtempid = ' ||l_work_item_temp_id);
       END IF;

         begin
         select a.pre_execution_wait, a.schedule_uom
         into l_pre_execution_wait, l_schedule_uom
         from  IEX_STRY_TEMP_WORK_ITEMS_VL a, IEX_STRATEGY_WORK_ITEMS b
         where b.work_item_template_id = a.work_item_temp_id
         and b.work_item_id = l_work_item_id;
	 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logMessage('Collections cal_pre_wait pre_execution_wait = ' ||l_pre_execution_wait);
	        iex_debug_pub.logMessage('Collections cal_pre_wait schedule_uom = ' ||l_schedule_uom);
         END IF;
         exception
         when others then
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('cal_pre_wait get execution time error ');
              END IF;
         end;

         if (l_pre_execution_wait = 0) then
           l_return := wf_no;
         else
           begin
           l_schedule:= IEX_STRY_UTL_PUB.get_Date
                               (p_date =>sysdate,
                                l_UOM  =>l_schedule_uom,
                                l_UNIT =>l_pre_execution_wait);
	   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('Collections cal_pre_wait l_schedule = ' || to_char(l_schedule, 'hh24:mi:ss mm/dd/yyyy'));
	   END IF;
           exception
           when others then
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          iex_debug_pub.logMessage('cal_pre_wait convert date error ');
             END IF;
           end;

           l_return := wf_yes;
           end if;


          wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'PRE_WAIT_TIME',
                                 avalue    => l_schedule);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('cal_pre_wait result = ' ||l_return);
        END IF;

       result := wf_engine.eng_completed ||':'||l_return;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('**** END cal_pre_wait ************');
        END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','cal_pre_wait',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;



END  cal_pre_wait;




/* begin bug 4141678 by ctlee 3/14/2005 - loop one when create workitem failed */
/*  calculate  re-create work item time wait
 *
 **/
procedure wi_failed_first_time(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2)IS

l_create_wi_error_count NUMBER;
l_restart_create_wi_time date;
l_return VARCHAR2(1);
l_strategy_status varchar2(100);

BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('**** START wi_failed_first_time ************');
    END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_strategy_status := wf_engine.GetItemAttrText(itemtype  => itemtype,
                             itemkey   =>  itemkey,
                             aname     => 'STRATEGY_STATUS');
      if l_strategy_status = 'CANCELLED' then
          l_return := wf_no;
          result := wf_engine.eng_completed ||':'||l_return;
          return;
      end if;

       l_create_wi_error_count := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'CREATE_WI_ERROR_COUNT');


     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('wi_failed_first_time l_create_wi_error_count = ' ||l_create_wi_error_count);
     END IF;

     if (l_create_wi_error_count = 1) then
         l_create_wi_error_count := 0;
         l_return := wf_no;
     else
       -- wait for one day, the workflow background process will pick it up
       begin
         select sysdate + 1
         into l_restart_create_wi_time
         from  dual;
         exception
         when others then
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('wi_failed_first_time get sysdate time error ');
              END IF;
       end;

       iex_debug_pub.logMessage('wi_failed_first_time l_restart_create_wi_time = ' ||l_restart_create_wi_time);

       l_create_wi_error_count := 1;
       l_return := wf_yes;

        wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'RESTART_CREATE_WI_TIME',
                                 avalue    => l_restart_create_wi_time);
     end if;

       wf_engine.SetItemAttrNumber(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'CREATE_WI_ERROR_COUNT',
                             avalue    => l_create_wi_error_count);

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('wi_failed_first_time result = ' ||l_return);
        END IF;

        result := wf_engine.eng_completed ||':'||l_return;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('**** END wi_failed_first_time ************');
        END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('IEX_STRATEGY_WF','wi_failed_first_time',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;

END  wi_failed_first_time;
/* end bug 4141678 by ctlee 3/14/2005 - loop one when create workitem failed */


/**
 * check whether the work item is optional or not
 **/
procedure OPTIONAL_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAr2(300);

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** START OPTIONAL_CHECK ************');
    END IF;
    if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('OPTIONAL_CHECK: ' || '*************FUNCMODE' ||funcmode||'**********************');
     END IF;

     l_value :=wf_engine.GetActivityLabel(actid);
       wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('OPTIONAL_CHECK: ' || 'ACTIVITYNAME' ||l_value);
     END IF;

       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       select nvl(optional_yn,'N') INTO l_result
       from iex_stry_temp_work_items_vl
       where work_item_temp_id =l_work_item_temp_id;

       result := wf_engine.eng_completed ||':'||l_result;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END OPTIONAL_CHECK ************');
       END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','OPTIONAL_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  OPTIONAL_CHECK;

/**
 * check whether the work item should be escalated or not
 **/
procedure ESCALATE_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2)IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAr2(300);

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START ESCALATE_CHECK ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('ESCALATE_CHECK: ' || 'ACTIVITYNAME' ||l_value);
      END IF;

       l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       select nvl(escalate_yn,'N') INTO l_result
       from iex_stry_temp_work_items_vl
       where work_item_temp_id =l_work_item_temp_id;

       result := wf_engine.eng_completed ||':'||l_result;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END ESCALATE_CHECK ************');
       END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','ESCALATE_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  ESCALATE_CHECK;

/**
 * check whether the to send a notification
 **/
procedure NOTIFY_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2)IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAr2(300);
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START NOTIFY_CHECK ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

    /*  l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('NOTIFY_CHECK: ' || 'ACTIVITYNAME' ||l_value);
    END IF;
    */
    l_work_item_temp_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'WORKITEM_TEMPLATE_ID');

       select nvl(notify_yn,'N') INTO l_result
       from iex_stry_temp_work_items_vl
       where work_item_temp_id =l_work_item_temp_id;

       result := wf_engine.eng_completed ||':'||l_result;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END NOTIFY_CHECK ************');
       END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','NOTIFY_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END NOTIFY_CHECK;


--Begin - schekuri - 03-Dec-2005 - Bug#4506922
--set the ON_HOLD_WAIT_TIME attribute
procedure set_on_hold_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2) IS

l_execution_time date;

BEGIN

       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** BEGIN set_on_hold_wait ************');
       END IF;
       select sysdate+(23/24)
         into l_execution_time
	 from dual;
         wf_engine.SetItemAttrDate(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'ON_HOLD_WAIT_TIME',
                                 avalue    => l_execution_time);

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('set_on_hold_wait: ' || 'ON_HOLD_WAIT_TIME' ||TO_CHAR(l_execution_time,'DD-MON-YYYY:HH:MI:SS'));
      END IF;
exception
  when others then
       null;

END  set_on_hold_wait;
--end - schekuri - 03-Dec-2005 - Bug#4506922


/**
 * check whether the work item status is on hold
 **/
procedure ONHOLD_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2)IS

l_strategy_id NUMBER;
l_result VARCHAR2(1);
l_count NUMBER ;
l_value VARCHAr2(300);
--Added by schekuri for bug#4506922 on 03-Dec-2005
l_work_item_id NUMBER;
l_timeout_wi NUMBER;
l_strategy_status VARCHAR2(100);
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START ONHOLD_CHECK ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      /*l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('ONHOLD_CHECK: ' || 'ACTIVITYNAME' ||l_value);
      END IF;
      */

       --begin bug#4506922 schekuri 03-Dec-2005
       --When the delinquency corresponding to the strategy becomes CURRENT or CLOSED,
       --strategy management concurrent program calls the procedure IEX_STRATEGY_WF.SEND_SIGNAL.
       --This procedure just updates the "STRATEGY_STATUS" attribute to "CLOSED" and completes the current activity.
       --But status of the strategy in table IEX_STRATEGIES is still 'ONHOLD'.
       --If workflow is waiting at WAIT_ON_HOLD_SIGNAL node, it will be completed and it goes to ONHOLD_CHECK node.
       --Since the status of the strategy in table IEX_STRATEGIES is still 'ONHOLD', it again goes to WAIT_ON_HOLD_SIGNAL node
       --and waits for 23 hrs. To avoid this added the following code.
       l_value :=wf_engine.GetActivityLabel(actid);
       if instr(l_value,'STRATEGY_WORKFLOW')>0 then
	       l_strategy_status := wf_engine.GetItemAttrText(
		                                   itemtype  => itemtype,
			                           itemkey   => itemkey,
				                   aname     => 'STRATEGY_STATUS');

		if l_strategy_status in ('CLOSED','CANCELLED') then
			result := wf_engine.eng_completed ||':'||'N';
			return;
		end if;
       end if;
       --end bug#4506922 schekuri 03-Dec-2005

       l_strategy_id := wf_engine.GetItemAttrNumber(
                                itemtype  => itemtype,
                                itemkey   => itemkey,
                                aname     => 'STRATEGY_ID');

       select decode(count(*),0,'N','Y') into l_result
       from iex_Strategies
       where strategy_id =l_strategy_id
       and   status_code ='ONHOLD';

	--begin bug#4506922 schekuri 03-Dec-2005
       --added the following code to avoid the workflow to get suspended at calc post wait node
       --after the timeout of the optional work item when the status of strategy is onhold.
       --Onhold check after calc post wait node stops the workflow when the strategy is onhold.
       --This is needed for workflows which are already started by the time this patch applied.
       --l_value :=wf_engine.GetActivityLabel(actid);
       if instr(l_value,'STRATEGY_SUBPROCESS')>0 and l_result = 'Y' then
          l_work_item_id := wf_engine.GetItemAttrText(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');
	  if l_work_item_id is not null then
	       begin
	       select count(*)
	       into l_timeout_wi
	       from iex_strategy_work_items
	       where work_item_id=l_work_item_id
	       and status_code='TIMEOUT';
	       exception
	       when others then
	       l_timeout_wi:=0;
	       end ;
	       if l_timeout_wi>0 then
                  l_result := 'N';
	       end if;
	  end if;
       end if;

       --end bug#4506922 schekuri 03-Dec-2005

       result := wf_engine.eng_completed ||':'||l_result;

       --Begin - schekuri - 03-Dec-2005 - bug#4506922
       --if strategy is ONHOLD update the attribute 'ON_HOLD_WAIT_TIME' to sysdate + 23 hrs.
       if l_result='Y' then
       --setting on_hold_wait_time_attribute;
       set_on_hold_wait(itemtype,itemkey);
       end if;
       --End - schekuri - 03-Dec-2005 - bug#4506922

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage ('**** END ONHOLD_CHECK ************');
       END IF;

exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','ONHOLD_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  ONHOLD_CHECK;




procedure UPDATE_WORK_ITEM(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS
l_api_version   NUMBER       := 1.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_work_item_id NUMBER;
exc                 EXCEPTION;
l_error VARCHAR2(32767);
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START UPDATE_WORK_ITEM ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_work_item_id := wf_engine.GetItemAttrText(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('UPDATE_WORK_ITEM: ' || 'value of workitem id '||l_work_item_id);
      END IF;
      IEX_STRY_UTL_PUB.UPDATE_WORK_ITEM (p_api_version => l_api_version,
                                        p_init_msg_list => FND_API.G_TRUE,
                                        p_commit        => FND_API.G_FALSE,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        x_return_status => l_return_status,
                                        p_work_item_id   => l_work_item_id,
                                        p_status        => 'TIMEOUT');
     if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        result := wf_engine.eng_completed ||':'||wf_yes;
     else
          RAISE EXC;
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** END UPDATE_WORK_ITEM ************');
    END IF;


exception
WHEN EXC THEN
     --pass the error message
      -- get error message and passit pass it
      Get_Messages(l_msg_count,l_error);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('UPDATE_WORK_ITEM: ' || 'error message is ' || l_error);
      END IF;
     wf_core.context('IEX_STRATEGY_WF','CUSTOM_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode,l_error);
     raise;
when others then
  wf_core.context('IEX_STRATEGY_WF','CUSTOM_CHECK',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
END UPDATE_WORK_ITEM;


/**
 * check whether the work item is optional or not
 **/
procedure WAIT_OPTIONAL(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** START WAIT_OPTIONAL ************');
    END IF;
    if funcmode <> wf_engine.eng_run then
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('WAIT_OPTIONAL: ' || 'SECOND TIME FUNCMODE' ||funcmode);
       END IF;
        result := wf_engine.eng_null;
        return;
    end if;



--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('WAIT_OPTIONAL: ' || 'FUNCMODE' ||funcmode);
     END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('WAIT_OPTIONAL: ' || 'ACTIVITYNAME' ||l_value);
      END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** END WAIT_OPTIONAL ************');
  END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','WAIT_OPTIONAL',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  WAIT_OPTIONAL;

/**
 * check whether the work item is optional or not
 **/
procedure WAIT_ESCALATION(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** START WAIT_ESCALATION ************');
    END IF;
    if funcmode <> wf_engine.eng_run then
        result := wf_engine.eng_null;
        return;
    end if;



--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('WAIT_ESCALATION: ' || 'FUNCMODE' ||funcmode);
     END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('WAIT_ESCALATION: ' || 'ACTIVITYNAME' ||l_value);
      END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** END WAIT_ESCALATION ************');
  END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','WAIT_ESCALATION',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  WAIT_ESCALATION;

/**
 * 04/29/02
 * sets the  strategy to wait
 * before the work item gets created
 * this is because if the background process
 * is not active and if the user clicks change
 * strategy , the workflow should close the
 * strategy .if the back ground process is
 * running , clear the activity label and
 * step over to 'work_items_complete node'
 **/
procedure WAIT_STRATEGY(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** START WAIT_STRATEGY ************');
    END IF;
    if funcmode <> wf_engine.eng_run then
        result := wf_engine.eng_null;
        return;
    end if;



--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('WAIT_STRATEGY: ' || 'FUNCMODE' ||funcmode);
     END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('WAIT_STRATEGY: ' || 'ACTIVITYNAME' ||l_value);
      END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** END WAIT_STRATEGY ************');
  END IF;
exception
when others then
       result := wf_engine.eng_completed ||':'||wf_engine.eng_null;
  wf_core.context('IEX_STRATEGY_WF','WAIT_STRATEGY',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  WAIT_STRATEGY;

----------------------------------------------
--if work item creation fails ,
--and if adminstartor does not want to continue
--replies via email 'NO' then close strategy and
--complete the workflow.
--set the status attribute to 'CANCELLED'
-- when closing strategy(CLOSE_STRATEGY procedure)
-- this attribute is checked.
--05/02/02

procedure SET_STRATEGY_STATUS(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS
l_strategy_id NUMBER;

BEGIN

       wf_engine.SetItemAttrText(itemtype  =>  itemtype,
                             itemkey   =>  itemkey,
                             aname     => 'STRATEGY_STATUS',
                             avalue    => 'CANCELLED');

       -- inside the close_strategy_procedure , the
       --existing strategy is CANCELLED.
       wf_engine.SetItemAttrNumber(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'WORK_ITEMID',
                             avalue    => NULL);

exception
when others then
       result := wf_engine.eng_completed ||':'||wf_engine.eng_null;
  wf_core.context('IEX_STRATEGY_WF','SET_STRATEGY_STATUS',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
END  SET_STRATEGY_STATUS;

/**
 --07/31/02
 --abort the strategy workflow
 --update the work items,
 --close or cancel strategy
 --abort all the custom workflows
 --this will happen if the workflow failed before
 --being suspended, for example if notification
 -- does not have a performer.

**/
procedure  CLOSE_AND_ABORT_STRATEGY_WF(
                           l_strategy_id   in   NUMBER,
                           l_status        in  VARCHAR2 ) IS

l_api_version   NUMBER       := 1.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);


BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** start CLOSE_AND_ABORT_STRATEGY_WF ************');
     END IF;

     abort_processes(l_strategy_id);

     IEX_STRY_UTL_PUB.CLOSE_STRY_AND_WITEMS(p_api_version => l_api_version,
                                            p_init_msg_list => FND_API.G_TRUE,
                                            p_commit        => FND_API.G_FALSE,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            x_return_status => l_return_status,
                                            p_strategy_id   => l_strategy_id,
                                            p_status        => l_status);

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('CLOSE_AND_ABORT_STRATEGY_WF: ' || '**** status after closing/cancelling strategy is '||
                                     l_return_status);
     END IF;

      BEGIN
            wf_engine.abortprocess(itemtype =>'IEXSTRY',
                                  itemkey   => l_strategy_id);
      EXCEPTION
      WHEN OTHERS THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage('CLOSE_AND_ABORT_STRATEGY_WF: ' || 'abort process ' ||  l_strategy_id ||
                                                     'has failed');
           END IF;
      END;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** end CLOSE_AND_ABORT_STRATEGY_WF ************');
     END IF;
END  CLOSE_AND_ABORT_STRATEGY_WF;


--set user_id,responsibility_id
--and application responsibility id
--which will then used by the the an other activity
-- which comes after a deferred activitiy
--08/02/02

procedure SET_SESSION_CTX(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS

l_party_id      NUMBER;
l_party_name    varchar2(2000);


BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** start SET_SESSION_CTX ************');
     END IF;
     --set item Attributes
     --set org_id
       wf_engine.SetItemAttrNumber(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'USER_ID',
                             avalue    => FND_GLOBAL.USER_ID);
     --set resp_id
       wf_engine.SetItemAttrNumber(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'RESP_ID',
                             avalue    => FND_GLOBAL.RESP_ID);
     --set app_resp_id
       wf_engine.SetItemAttrNumber(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'RESP_APPL_ID',
                             avalue    => FND_GLOBAL.RESP_APPL_ID );

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('SET_SESSION_CTX: ' || 'USER_ID' ||  FND_GLOBAL.USER_ID);
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('SET_SESSION_CTX: ' || 'RESP_ID' ||  FND_GLOBAL.RESP_ID);
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('SET_SESSION_CTX: ' || 'RESP_APPL_ID' ||FND_GLOBAL.RESP_APPL_ID);
     END IF;


 ---get party_id from the work flow
    l_party_id := wf_engine.GetItemAttrNumber(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'PARTY_ID');

    if l_party_id is not null then
    begin
     select party_name into l_party_name from hz_parties where party_id = l_party_id;
       wf_engine.SetItemAttrText(itemtype  =>itemtype,
                             itemkey   => itemkey,
                             aname     => 'CUSTOMER_NAME',
                             avalue    => l_party_name);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('party_name' ||l_party_name);
END IF;
     exception
     when others then
       null;
    end;
    end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage ('**** End SET_SESSION_CTX ************');
END IF;
EXCEPTION
when others then
  result := wf_engine.eng_completed ||':'||wf_engine.eng_null;
  wf_core.context('IEX_STRATEGY_WF','SET_SESSION_CTX',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END;

-- Begin- Andre 07/28/2004 - Add bill to assignmnet

------------------- procedure get_billto_resource ------------------------------
/** get resource id for the given competence and bill to address
*
**/
function get_billto_resource ( p_siteuse_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER)
						 RETURN BOOLEAN IS

l_bReturn boolean := FALSE;

l_vTest varchar2(20) ;

l_api_version   NUMBER       := 1.0;
l_init_msg_list VARCHAR2(1)  ;
l_resource_tab iex_utilities.resource_tab_type;

l_commit VARCHAR2(1)         ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_validation_level NUMBER ;

l_resource_id NUMBER   ;
l_count       NUMBER :=0;
l_found       BOOLEAN := TRUE;
-- Changed for the bug#7656223 by PNAVEENK on 2-1-2009
cursor c_get_person_id (l_person_id NUMBER,
                        l_competence_id NUMBER)is
select count(person_id)
from per_competence_elements
where competence_id =l_competence_id
and   person_id     =l_person_id
and   trunc(NVL(effective_date_to,SYSDATE)) >= trunc(sysdate)
and   trunc(effective_date_from) <=  trunc(sysdate) ;
-- End for the bug#7656223
BEGIN
  -- initialize variable
  l_vTest := 'Instance time';
  l_init_msg_list := FND_API.G_TRUE;
  l_commit := FND_API.G_FALSE;
  l_validation_level := FND_API.G_VALID_LEVEL_FULL;
  l_resource_id :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);

iex_debug_pub.logmessage ('get_billto_resource: Test variable is: ' || l_vTest);

l_vTest := 'Runtime Changed';

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('get_billto_resource: ' || '**** BEGIN  get_billto_resource ************');
        iex_debug_pub.logmessage ('default resource id from profile iex_stry_default_resource) ' || l_resource_id);
        iex_debug_pub.logmessage ('calling get_billto_resources ' || p_siteuse_id);
     END IF;
-- get resource id table of reords for the given site use id
-- the record has resource id and person id along with the user name
--Begin bug#5373412 schekuri 10-Jul-2006
--Call new consolidated procedure get_assigned_collector
/*iex_utilities.get_billto_resources(p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_TRUE,
                                   p_commit           => FND_API.G_FALSE,
                                   p_validation_level => l_validation_level,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_return_status    => l_return_status,
                                   p_site_use_id      => p_siteuse_id,
                                   x_resource_tab     => l_resource_tab);*/

iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'BILLTO',
                               p_level_id          => p_siteuse_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);

--End bug#5373412 schekuri 10-Jul-2006
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage('get_billto_resource: ' || 'in get resource and l_return_status = '||l_return_status);
  iex_debug_pub.logmessage('in get resource and l_return_status from iex_utilities.get_billto_resources = '||l_return_status);
  iex_debug_pub.logmessage('resource count from iex_utilities.get_billto_resources = '||l_resource_tab.count);
END IF;

if l_resource_tab.count > 0 then
	l_bReturn := true;
end if;
  -- if COMPETENCE id exists for the given work template Id,
  -- see if the person id from the
  -- the above l_resource_tab matches with the competence Id
  -- pick if there is match or pick any resource if there is no match
  -- or competence id of the work template id is null


     --if  p_competence_id IS  NULL  THEN
     if  p_competence_tab.count = 0    THEN
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('get_billto_resource: ' || 'Competence table is empty');
         END IF;
        --get the first resource id if competence id is null from
        -- the work item template
         FOR i in 1..l_resource_tab.count LOOP
             l_resource_id := l_resource_tab(i).resource_id;
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
             END IF;
             EXIT;
         END LOOP;
     else
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('Loop for matching competence. count = '||p_competence_tab.count );
       END IF;
           FOR i in 1..l_resource_tab.count LOOP
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('get_billto_resource: ' || 'PERSON ID is '||l_resource_tab(i).person_id);
                  iex_debug_pub.logmessage('get_billto_resource: ' || 'RESOURCE ID is '||l_resource_tab(i).resource_id);
               END IF;

               FOR j in 1..p_competence_tab.count LOOP

                   OPEN c_get_person_id (l_resource_tab(i).person_id,
                                                    p_competence_tab(j));
                   FETCH c_get_person_id INTO l_count;
                   CLOSE c_get_person_id;
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_billto_resource: ' || 'COMPETENCE ID is '||
                                       p_competence_tab(j));
                   END IF;
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_billto_resource: ' || 'no of matches  '|| l_count);
                   END IF;
                   If l_count =0 THEN
                      -- match not found, use the first resource and exit out NOCOPY
                      -- from the competence loop.
      		      --Begin bug#5373412 schekuri 10-Jul-2006
		      --Commented the below the code to return default resource id instead of first resource id
		      --when there is no resource found matching the competency of the workitem.
                      /*l_resource_id := l_resource_tab(1).resource_id;
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
                      END IF;*/
		      --End bug#5373412 schekuri 10-Jul-2006
                      -- have to look for the next resource if l_found is false
                      l_found :=FALSE;
                      EXIT;
                   ELSE
                       l_resource_id := l_resource_tab(i).resource_id;
--                       IF PG_DEBUG < 10  THEN
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record found with competence matched l_resource_tab l_resource_id = '|| l_resource_id);
                       END IF;
                       l_found :=TRUE;
                  End if;
                END LOOP;
                if l_found THEN
                   -- a matching resource with all the competencies
                   --have been found ,stop looking for next resource
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_billto_resource: ' || 'match found and RESOURCE ID is =>'
                                             ||l_resource_tab(i).resource_id);
                   END IF;
                   exit;
                end if;
             END LOOP;
       end if;
    --assign out NOCOPY variable
      x_resource_id :=l_resource_id;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('get_billto_resource: ' || 'value of x_resource_id' ||x_resource_id);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('get_billto_resource: ' || '**** END  get_billto_resource ************');
      END IF;

      return l_bReturn;
END get_billto_resource;
-- End- Andre 07/28/2004 - Add bill to assignmnet



-- Begin- krishna 07/01/2005 - Add account assignment

------------------- procedure get_billto_resource ------------------------------
/** get resource id for the given competence and account id
*
**/
function get_account_resource ( p_account_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER)
						 RETURN BOOLEAN IS

l_bReturn boolean := FALSE;

l_vTest varchar2(20) ;

l_api_version   NUMBER       := 1.0;
l_init_msg_list VARCHAR2(1)  ;
l_resource_tab iex_utilities.resource_tab_type;

l_commit VARCHAR2(1)         ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_validation_level NUMBER ;

l_resource_id NUMBER   ;
l_count       NUMBER :=0;
l_found       BOOLEAN := TRUE;
-- Changed for the bug#7656223 by PNAVEENK on 2-1-2009
cursor c_get_person_id (l_person_id NUMBER,
                        l_competence_id NUMBER)is
select count(person_id)
from per_competence_elements
where competence_id =l_competence_id
and   person_id     =l_person_id
and   trunc(NVL(effective_date_to,SYSDATE)) >= trunc(sysdate)
and   trunc(effective_date_from) <=  trunc(sysdate) ;
-- End for bug#7656223

BEGIN
  -- initialize variable
  l_vTest := 'Instance time';
  l_init_msg_list := FND_API.G_TRUE;
  l_commit := FND_API.G_FALSE;
  l_validation_level := FND_API.G_VALID_LEVEL_FULL;
  l_resource_id :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);

iex_debug_pub.logmessage ('get_account_resource: Test variable is: ' || l_vTest);

l_vTest := 'Runtime Changed';

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('get_account_resource: ' || '**** BEGIN  get_billto_resource ************');
        iex_debug_pub.logmessage ('default resource id from profile iex_stry_default_resource) ' || l_resource_id);
        iex_debug_pub.logmessage ('calling get_account_resources ' || p_account_id);
     END IF;
-- get resource id table of reords for the given site use id
-- the record has resource id and person id along with the user name
--Begin bug#5373412 schekuri 10-Jul-2006
--Call new consolidated procedure get_assigned_collector
iex_utilities.get_assigned_collector(p_api_version => l_api_version,
                               p_init_msg_list     => FND_API.G_TRUE,
                               p_commit            => FND_API.G_FALSE,
                               p_validation_level  => l_validation_level,
                               p_level             => 'ACCOUNT',
                               p_level_id          => p_account_id,
                               x_msg_count         => l_msg_count,
                               x_msg_data          => l_msg_data,
                               x_return_status     => l_return_status,
                               x_resource_tab      => l_resource_tab);
/*iex_utilities.get_assign_account_resources(p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_TRUE,
                                   p_commit           => FND_API.G_FALSE,
                                   p_validation_level => l_validation_level,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_return_status    => l_return_status,
                                   p_account_id      => p_account_id,
                                   x_resource_tab     => l_resource_tab);*/
--End bug#5373412 schekuri 10-Jul-2006
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage('get_billto_resource: ' || 'in get resource and l_return_status = '||l_return_status);
  iex_debug_pub.logmessage('in get resource and l_return_status from iex_utilities.get_assign_account_resources = '||l_return_status);
  iex_debug_pub.logmessage('resource count from iex_utilities.get_assign_account_resources = '||l_resource_tab.count);
END IF;

if l_resource_tab.count > 0 then
	l_bReturn := true;
end if;
  -- if COMPETENCE id exists for the given work template Id,
  -- see if the person id from the
  -- the above l_resource_tab matches with the competence Id
  -- pick if there is match or pick any resource if there is no match
  -- or competence id of the work template id is null


     --if  p_competence_id IS  NULL  THEN
     if  p_competence_tab.count = 0    THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('get_account_resource: ' || 'Competence table is empty');
         END IF;
        --get the first resource id if competence id is null from
        -- the work item template
         FOR i in 1..l_resource_tab.count LOOP
             l_resource_id := l_resource_tab(i).resource_id;
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
             END IF;
             EXIT;
         END LOOP;
     else
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('Loop for matching competence. count = '||p_competence_tab.count );
       END IF;
           FOR i in 1..l_resource_tab.count LOOP
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('get_account_resource: ' || 'PERSON ID is '||l_resource_tab(i).person_id);
                  iex_debug_pub.logmessage('get_account_resource: ' || 'RESOURCE ID is '||l_resource_tab(i).resource_id);
               END IF;

               FOR j in 1..p_competence_tab.count LOOP

                   OPEN c_get_person_id (l_resource_tab(i).person_id,
                                                    p_competence_tab(j));
                   FETCH c_get_person_id INTO l_count;
                   CLOSE c_get_person_id;
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_account_resource: ' || 'COMPETENCE ID is '||
                                       p_competence_tab(j));
                   END IF;
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_account_resource: ' || 'no of matches  '|| l_count);
                   END IF;
                   If l_count =0 THEN
                      -- match not found, use the first resource and exit out NOCOPY
                      -- from the competence loop.
		      --Begin bug#5373412 schekuri 10-Jul-2006
		      --Commented the below the code to return default resource id instead of first resource id
		      --when there is no resource found matching the competency of the workitem.
                      /*l_resource_id := l_resource_tab(1).resource_id;
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record from l_resource_tab l_resource_id = '|| l_resource_id);
                      END IF;*/
		      --End bug#5373412 schekuri 10-Jul-2006
                      -- have to look for the next resource if l_found is false
                      l_found :=FALSE;
                      EXIT;
                   ELSE
                       l_resource_id := l_resource_tab(i).resource_id;
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logmessage('1st record found with competence matched l_resource_tab l_resource_id = '|| l_resource_id);
                       END IF;
                       l_found :=TRUE;
                  End if;
                END LOOP;
                if l_found THEN
                   -- a matching resource with all the competencies
                   --have been found ,stop looking for next resource
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logmessage('get_account_resource: ' || 'match found and RESOURCE ID is =>'
                                             ||l_resource_tab(i).resource_id);
                   END IF;
                   exit;
                end if;
             END LOOP;
       end if;
    --assign out NOCOPY variable
      x_resource_id :=l_resource_id;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('get_account_resource: ' || 'value of x_resource_id' ||x_resource_id);
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('get_account_resource: ' || '**** END  get_account_resource ************');
      END IF;

      return l_bReturn;
END get_account_resource;

--Begin - schekuri - 03-Dec-2005 - bug#4506922
--to make the wf wait, if the status of strategy is ONHOLD
--after 23 hrs. it rechecks the status
procedure wait_on_hold_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2) IS

l_work_item_temp_id NUMBER;
l_result VARCHAR2(1);
l_value VARCHAR2(300);

BEGIN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('**** START wait_on_hold_signal ************');
END IF;
    if funcmode <> wf_engine.eng_run then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('SECOND TIME FUNCMODE' ||funcmode);
END IF;
        result := wf_engine.eng_null;
        return;
    end if;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.logmessage('FUNCMODE' ||funcmode);
END IF;
      l_value :=wf_engine.GetActivityLabel(actid);
      wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('ACTIVITYNAME' ||l_value);
END IF;


   result := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('**** END wait_on_hold_signal ************');
END IF;
 exception
when others then
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','wait_on_hold_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;

END  wait_on_hold_signal;
--End - schekuri - 03-Dec-2005 - bug#4506922

--Begin - kasreeni- 11-03-2005 - Bug# 4667500
-- procedure to update the workitem to open
-- if the strategy is cancelled, we don't have to do anything
 /* Begin 05-dec-2005 schekuri bug#4506922 - All work items are created as PRE-WAIT */
procedure update_work_item_to_open(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2) IS
    L_STATUS_CODE varchar2(30);
    l_work_item_id  NUMBER(30);
    l_result VARCHAR2(5);
    l_value VARCHAR2(300);
    l_strategy_status  VARCHAR2(50);

BEGIN

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** START update_work_item_to_open ************');
    END IF;
    if funcmode <> wf_engine.eng_run then
        result := wf_engine.eng_null;
        return;
    end if;

    l_work_item_id := wf_engine.GetItemAttrNumber(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                 aname     => 'WORK_ITEMID');

    l_strategy_status := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'STRATEGY_STATUS');

    iex_debug_pub.logMessage('Got the work item ' || itemtype || ' item key ' || itemkey
           || ' l_work_item_ID ' || l_work_item_id || ' Strategy_status ' || l_strategy_status);

		if l_strategy_status in ('CLOSED','CANCELLED') then
      result := wf_engine.eng_completed ||':'||wf_yes;
			return;
		end if;

    if (l_work_item_id is not null ) then

      SELECT STATUS_CODE INTO l_status_code FROM IEX_STRATEGY_WORK_ITEMS WHERE WORK_ITEM_ID = l_work_item_id;

      iex_debug_pub.logMessage('Got the Status ' || l_status_code );

      if (l_status_code = 'PRE-WAIT') THEN

        UPDATE IEX_STRATEGY_WORK_ITEMS SET STATUS_CODE = 'OPEN' WHERE WORK_ITEM_ID = l_work_item_id;
      END IF;
    end if;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** END  update_work_item_to_open ************');
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage('FUNCMODE  ' ||funcmode);
    END IF;

    l_value :=wf_engine.GetActivityLabel(actid);

    wf_engine.SetItemAttrText(itemtype  => itemtype,
                           itemkey   => itemkey,
                           aname     => 'ACTIVITY_NAME',
                           avalue    => l_value);

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('ACTIVITYNAME  ' ||l_value);
    END IF;


    result := wf_engine.eng_completed ||':'||wf_yes;

exception
  when others then
     iex_debug_pub.logmessage ('**** EXCEPTION  update_work_item_to_open ************');
       result := wf_engine.eng_completed ||':'||wf_no;
  wf_core.context('IEX_STRATEGY_WF','wait_on_hold_signal',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
END;

--End - 05-dec-2005 schekuri bug#4506922

procedure UPDATE_ESC_FLAG(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) IS
l_api_version_number   NUMBER       := 2.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_work_item_id NUMBER;
l_party_id NUMBER;
exc                 EXCEPTION;
l_error VARCHAR2(32767);
l_object_version_number number;
l_strategy_work_item_rec IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type;
l_status_code iex_strategy_work_items.status_code%type;
Cursor c_get_work_items (p_work_item_id NUMBER) is
  SELECT status_code, object_version_number
  FROM   iex_strategy_work_items
  WHERE  work_item_id = p_work_item_id;
 l_resource_id number; -- added for bug 8919933 PNAVEENK
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START UPDATE_ESCALATION_FLAG ************');
     END IF;
     if funcmode <> 'RUN' then
        result := wf_engine.eng_null;
        return;
    end if;

      l_work_item_id := wf_engine.GetItemAttrText(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'WORK_ITEMID');
       l_party_id := wf_engine.GetItemAttrText(
                                                itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'PARTY_ID');
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('UPDATE_ESC_FLAG: ' || 'value of workitem id '||l_work_item_id);
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('UPDATE_ESC_FLAG: ' || 'Updating the work item..');
      END IF;
      open c_get_work_items(l_work_item_id);
      fetch c_get_work_items into l_status_code,l_object_version_number;
      close c_get_work_items;
      l_strategy_work_item_Rec.work_item_id  := l_work_item_id;
      l_strategy_work_item_Rec.object_version_number :=l_object_version_number;
      l_strategy_work_item_Rec.escalated_yn := 'Y';
      IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items(
              P_Api_Version_Number         =>l_api_version_number,
              P_strategy_work_item_Rec     =>l_strategy_work_item_Rec,
              P_Init_Msg_List             =>FND_API.G_TRUE,
              p_commit                    =>FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data,
              x_return_status              => l_return_status,
              XO_OBJECT_VERSION_NUMBER     =>l_object_version_number );
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('UPDATE_ESC_FLAG: Return status = ' || l_return_status);
      END IF;
     if l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        begin
	iex_debug_pub.logmessage('UPDATE_ESC_FLAG: Refreshing UWQ Summary..');
        IEX_STRY_UTL_PUB.refresh_uwq_str_summ(l_work_item_id);
	exception
	when others then
		iex_debug_pub.logmessage('UPDATE_ESC_FLAG:Exception when refreshing UWQ Summary: '||SQLERRM);
	end;

        result := wf_engine.eng_completed ||':'||wf_yes;
     else
          RAISE EXC;
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** END UPDATE_ESC_FLAG ************');
    END IF;

    -- start for bug 8919933 PNAVEENK

      Begin
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('**** START UPDATE_NOTIFICATION_RESOURCE ************');
      END IF;


      if (l_work_item_id is not null ) then

      SELECT resource_id INTO l_resource_id FROM IEX_STRATEGY_WORK_ITEMS WHERE WORK_ITEM_ID = l_work_item_id;

      end if;
      iex_debug_pub.logMessage('Current resource id ' || l_resource_id );

      set_notification_resources(l_resource_id, itemtype, itemkey);

      result := wf_engine.eng_completed ||':'||wf_yes;

       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('**** END UPDATE_NOTIFICATION_RESOURCE ************');
       END IF;

       exception
            when others then
                iex_debug_pub.logmessage('UPDATE_ESC_FLAG:Exception UPDATE NOTIFICATION RESOURCE '||SQLERRM);
       end;

     -- end for bug 8919933


exception
WHEN EXC THEN
     --pass the error message
      -- get error message and passit pass it
      Get_Messages(l_msg_count,l_error);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage('UPDATE_ESC_FLAG: ' || 'error message is ' || l_error);
      END IF;
     wf_core.context('IEX_STRATEGY_WF','UPDATE_ESC_FLAG',itemtype,
                   itemkey,to_char(actid),funcmode,l_error);
     raise;
when others then
  wf_core.context('IEX_STRATEGY_WF','UPDATE_ESC_FLAG',itemtype,
                   itemkey,to_char(actid),funcmode);
  raise;
END UPDATE_ESC_FLAG;


begin
  -- initialize variable
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  wf_yes      := 'Y';
  wf_no       := 'N';
end IEX_STRATEGY_WF;

/
