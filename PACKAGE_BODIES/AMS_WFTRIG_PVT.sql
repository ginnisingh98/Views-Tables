--------------------------------------------------------
--  DDL for Package Body AMS_WFTRIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WFTRIG_PVT" AS
/* $Header: amsvwftb.pls 120.3 2005/09/13 16:00:40 soagrawa ship $*/

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_WfTrig_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvwtrb.pls';

--  Start of Comments
--
-- NAME
--   AMS_WFTrig_PVT
--
-- PURPOSE
--   This package performs contains the workflow procedures for
--   Continuous Campaigning in Oracle Marketing
--
-- HISTORY
--    22-MAR-2001    julou     created
--    31-May-2001    ptendulk  modified Start_process process.
--    29-aug-2002    soagrawa  Fixed bug# 2535736
--    25-nov-2002    soagrawa  In execute_schedule : added generation of Target group before CSCH activation
--    28-apr-2003    soagrawa  Modified/Added APIs for trigger redesign
--    25-aug-2003    soagrawa  modified code to fix bug# 3111622 in execute_schedule
--    26-aug-2003    soagrawa  modified code to fix bug# 3114609 in get_Aval_repeat_sch
--    26-sep-2003    soagrawa  modified code to replace execution of schedule API with WF Bus Event in execute_schedule
--    23-feb-2004    soagrawa  bug fix 3452264
--    13-may-2004    soagrawa  Fixed bug# 3621786 in get_aval_repeat_Csch
--    09-nov-2004    anchaudh  Fixed setting of WF item owners for triggers WF
--    20-aug-2005    soagrawa  Added code for Conc Program that will purge monitor history
--    26-aug-2005    soagrawa  Fixes for R12

-- End of Comments

/***************************  PRIVATE ROUTINES  *******************************/

-- Start of Comments
--
-- NAME
--   Find_Owner
--
-- PURPOSE
--   This Procedure will be called by Initialize_Var to find
--   username of the Owner of the Activity
--
-- Called By
--   Initialize_Var
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using trigger id passed to the Start Process
--
-- HISTORY
--   22-MAR-2001       julou     created
--   26 aug-2005   soagrawa  Modified to add flexibility around initiative being monitored for R12
-- End of Comments

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Find_Owner
            (p_activity_id             IN  NUMBER           ,
             p_activity_type           IN  VARCHAR2         ,
             x_owner_user_name         OUT NOCOPY VARCHAR2
            )
IS

CURSOR c_camp_det IS
    SELECT  owner_user_id
    FROM    ams_campaigns_vl
    WHERE   campaign_id = p_activity_id ;

CURSOR c_csch_det IS
    SELECT  owner_user_id
    FROM    ams_campaign_schedules_vl
    WHERE   schedule_id = p_activity_id ;

CURSOR c_deli_det IS
    SELECT  owner_user_id
    FROM    ams_deliverables_vl
    WHERE   deliverable_id = p_activity_id ;

CURSOR c_eveh_det IS
    SELECT  owner_user_id
    FROM    ams_event_headers_vl
    WHERE   event_header_id = p_activity_id ;

CURSOR c_eveo_det IS
    SELECT  owner_user_id
    FROM    ams_event_offers_vl
    WHERE   event_offer_id = p_activity_id ;

CURSOR c_emp_dtl(l_res_id IN NUMBER) IS
    SELECT employee_id
    FROM   ams_jtf_rs_emp_v
    WHERE  resource_id = l_res_id ;

l_user_id      NUMBER ;
l_emp_id       NUMBER ;
l_display_name VARCHAR2(100);

BEGIN

IF      p_activity_type in ('CAMP','RCAM') THEN
        OPEN  c_camp_det;
        FETCH c_camp_det INTO l_user_id;
        CLOSE c_camp_det ;
    ELSIF   p_activity_type = 'DELI' THEN
        OPEN  c_deli_det;
        FETCH c_deli_det INTO l_user_id;
        CLOSE c_deli_det ;
    ELSIF   p_activity_type = 'EVEH' THEN
        OPEN  c_eveh_det;
        FETCH c_eveh_det INTO l_user_id;
        CLOSE c_eveh_det ;
    ELSIF   p_activity_type in ('EVEO','EONE') THEN
        OPEN  c_eveo_det;
        FETCH c_eveo_det INTO l_user_id;
        CLOSE c_eveo_det ;
    ELSIF   p_activity_type = 'CSCH' THEN
        OPEN  c_csch_det;
        FETCH c_csch_det INTO l_user_id;
        CLOSE c_csch_det ;
    ELSIF   p_activity_type = 'JTF' THEN
        l_user_id := p_activity_id ;
    END IF ;

    OPEN c_emp_dtl(l_user_id);
    FETCH c_emp_dtl INTO l_emp_id  ;
    CLOSE c_emp_dtl ;

--    x_owner_user_name := l_resource_name ;

--    IF (l_emp_id IS NOT NULL) THEN
      WF_DIRECTORY.getrolename
           ( p_orig_system      => 'PER',
             p_orig_system_id   => l_emp_id ,
             p_name      => x_owner_user_name,
             p_display_name   => l_display_name );

-- used for testing
--    x_owner_user_name := 'PTENDULK' ;
END Find_Owner    ;


-- Start of Comments
--
-- NAME
--   Handle_Err
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--   Set the Workflow item attribut with the Error Messages
--
-- Used By Activities
--
--
-- NOTES
--
-- HISTORY
--   11/05/1999        ptendulk            created
-- End of Comments
PROCEDURE Handle_Err
            (p_itemtype                 IN VARCHAR2    ,
             p_itemkey                  IN VARCHAR2    ,
             p_msg_count                IN NUMBER      , -- Number of error Messages
             p_msg_data                 IN VARCHAR2    ,
             p_attr_name                IN VARCHAR2
            )
IS
 l_msg_count   NUMBER ;
 l_msg_data    VARCHAR2(2000);
 l_final_data  VARCHAR2(4000);
 l_msg_index   NUMBER ;
 l_cnt         NUMBER := 0 ;
 l_trigger_id  NUMBER ;
 l_return_status  VARCHAR2(1);
 l_obj_type    VARCHAR2(30);
BEGIN

   IF p_itemtype = 'AMS_CSCH'
   THEN
      l_trigger_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey ,
                                 aname    => 'SCHEDULE_ID');
      l_obj_type := 'CSCH';
   ELSE
      l_trigger_id := WF_ENGINE.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey ,
                                 aname    => 'AMS_TRIGGER_ID');
      l_obj_type := 'TRIG';
   END IF;

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => l_obj_type,
                     p_log_used_by_id  => l_trigger_id,
                     p_msg_data        => 'Error msgs from handle_err for attribute '||p_attr_name,
                     p_msg_type        => 'DEBUG'
                     );

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => l_obj_type,
                     p_log_used_by_id  => l_trigger_id,
                     p_msg_data        => 'Total messages '||p_msg_count,
                     p_msg_type        => 'DEBUG'
                     );

   WHILE l_cnt < p_msg_count
   LOOP
      FND_MSG_PUB.Get(p_msg_index     => l_cnt + 1,
            p_encoded    => FND_API.G_FALSE,
            p_data          => l_msg_data,
            p_msg_index_out  => l_msg_index )       ;
                l_final_data := l_final_data ||l_msg_index||': '||l_msg_data||fnd_global.local_chr(10);
      l_cnt := l_cnt + 1 ;

      AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => l_obj_type,
                     p_log_used_by_id  => l_trigger_id,
                     p_msg_data        => l_msg_index||': '||l_msg_data ,
                     p_msg_type        => 'DEBUG'
                     );

   END LOOP ;

   WF_ENGINE.SetItemAttrText(itemtype     =>    p_itemtype,
              itemkey      =>     p_itemkey ,
              aname            =>    p_attr_name,
                 avalue      =>      l_final_data   );

END Handle_Err;

-- Start of Comments
--
-- NAME
--   Action_performed
--
-- PURPOSE
--   This Function will return the meaning of the Action performed
--   Used to create the Check Message
-- Used By Activities
--
--
-- NOTES
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments
FUNCTION Action_performed
            (p_lookup_code              IN VARCHAR2  )
RETURN VARCHAR2
IS
l_meaning VARCHAR2(80);
    CURSOR c_lookup_det
    IS
    SELECT  meaning
    FROM    ams_lookups
    WHERE   lookup_type = 'AMS_TRIGGER_ACTION_TYPE'
    AND     lookup_code = p_lookup_code
    AND     enabled_flag = 'Y' ;

BEGIN
    OPEN  c_lookup_det ;
    FETCH c_lookup_det INTO l_meaning ;
    CLOSE c_lookup_det ;

    RETURN l_meaning ;

END Action_performed;

-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
--   p_trigger_id                 Trigger id
--   p_trigger_name             Trigger Name
--   processowner            Owner Of the Process
--    workflowprocess         Work Flaow Process Name (AMS_TRIGGERS)
--    item_type               Item type    DEFAULT NULL(AMS_TRIG)

--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001     julou     created
--   31-May-2001     ptendulk  Commented out the trigger action table update call.
-- End of Comments

PROCEDURE StartProcess
              (p_trigger_id     IN   NUMBER    -- Trigger id
--              ,p_user_id        IN   NUMBER
--            ,p_trigger_name   IN   VARCHAR2

              ,processowner     IN   VARCHAR2   DEFAULT NULL
              ,workflowprocess  IN   VARCHAR2   DEFAULT NULL
              ,item_type        IN   VARCHAR2   DEFAULT NULL
         )
IS
     itemtype   VARCHAR2(30) := nvl(item_type,'AMS_TRIG');
     itemkey    VARCHAR2(30) := p_trigger_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
     itemuserkey VARCHAR2(80) ;
BEGIN
     -- Start Process :
     --  If workflowprocess is passed, it will be run.
     --  If workflowprocess is NOT passed, the selector function
     --  defined in the item type will determine which process to run.
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Start');
     END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Item Type : ' || itemtype);
     END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Item key : ' || itemkey);
     END IF;

--      dbms_output.put_line('Creating process');
     WF_ENGINE.CreateProcess (itemtype   =>   'AMS_TRIG', --itemtype,
                              itemkey    =>   itemkey ,
                              process     =>   workflowprocess);
--dbms_output.put_line('Created process');
     -- Call a Proc to Initialize the Variables
--     dbms_output.put_line('Calling initialazion');
/*     Initialize_Var
            (p_trigger_id               => p_trigger_id      , -- Trigger ID
             p_itemtype                 => itemtype   ,
             p_itemkey                  => itemkey
            ) ;
*/
/*
     WF_ENGINE.SetItemAttrText(itemtype    =>   itemtype ,
                               itemkey     =>   itemkey,
                               aname     =>   'AMS_USER_ID',
                               avalue    =>   p_user_id  );
*/
     itemuserkey := WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                               itemkey     =>  itemkey ,
                               aname     =>   'AMS_TRIGGER_NAME');

     IF (AMS_DEBUG_HIGH_ON) THEN
     Ams_Utility_pvt.debug_message('After create desc wf_itemsItem key : ' || itemkey);

     END IF;

     WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                              itemkey     =>   itemkey ,
                userkey     =>   itemuserkey);

     WF_ENGINE.SetItemAttrText(itemtype  =>   itemtype,
                              itemkey     =>   itemkey,
                              aname     =>   'MONITOR_URL',
                              avalue     =>   wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), itemtype, itemkey, 'NO'));

--dbms_output.put_line('Calling WF_ENGINE to start process');
--dbms_output.put_line('itemtype: '||itemtype);
--dbms_output.put_line('itemkey: '||itemkey);
     WF_ENGINE.StartProcess (itemtype     => itemtype,
                             itemkey     => itemkey);
--dbms_output.put_line('done');
   -- Following lines of code is modified by ptendulk on 31-May-2001
   -- As the trigger action table is no longer required.
   --  DECLARE
   --     CURSOR  c_trigger_action(l_my_trigger_id NUMBER) IS
   --     SELECT  trigger_id
   --     FROM    ams_trigger_actions
   --     WHERE   trigger_id = l_my_trigger_id ;
   --     l_dummy NUMBER;
   --  BEGIN
        UPDATE  ams_triggers
        SET     process_id = TO_NUMBER(itemkey)
        WHERE   trigger_id = p_trigger_id ;

   --     OPEN    c_trigger_action(p_trigger_id);
   --     FETCH   c_trigger_action INTO l_dummy ;
   --     IF c_trigger_action%FOUND THEN
   --         UPDATE  ams_trigger_actions
   --         SET     process_id = TO_NUMBER(itemkey)
   --         WHERE   trigger_id = p_trigger_id ;
   --     END IF;
   --     CLOSE c_trigger_action;
   --END;

EXCEPTION
     WHEN OTHERS
     THEN
        wf_core.context (G_PKG_NAME, 'StartProcess', p_trigger_id, itemuserkey, workflowprocess);
         RAISE;

END StartProcess;

-- Start of Comments
--
-- NAME
--   Selector
--
-- PURPOSE
--   This Procedure will determine which process to run
--
-- IN
-- itemtype     - A Valid item type from (WF_ITEM_TYPES Table).
-- itemkey      - A string generated from application object's primary key.
-- actid        - The function Activity
-- funcmode     - Run / Cancel
--
-- OUT
-- resultout    - Name of workflow process to run
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Selector( itemtype    IN      VARCHAR2,
                    itemkey     IN      VARCHAR2,
                    actid       IN      NUMBER,
                    funcmode    IN      VARCHAR2,
                    resultout   OUT NOCOPY     VARCHAR2
                    )
  IS
   -- PL/SQL Block
  BEGIN
-- dbms_output.put_line('In Selector Function');
      --
      -- RUN mode - normal process execution
      --
      IF  (funcmode = 'RUN')
      THEN
         -- Return process to run
         resultout := 'AMS_TRIGGERS';
         RETURN;
      END IF;
      -- CANCEL mode - activity 'compensation'
      IF  (funcmode = 'CANCEL')
      THEN
         -- Return process to run
         resultout := 'AMS_TRIGGERS';
         RETURN;
      END IF;
      -- TIMEOUT mode
      IF  (funcmode = 'TIMEOUT')
      THEN
         resultout := 'AMS_TRIGGERS';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.context (G_PKG_NAME, 'Selector', itemtype, itemkey, actid, funcmode);
         RAISE;
   END Selector;

-- Start of Comments
--
-- NAME
--   Check_Repeat
--
-- PURPOSE
--   This Procedure will return Yes if there the Trigger is repeating
--     or it will return No
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is repeating
--           - 'COMPLETE:N' If the trigger is not repeating
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_CHECK_REPEAT
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Check_Repeat          (itemtype     IN     VARCHAR2,
                           itemkey        IN     VARCHAR2,
                         actid        IN     NUMBER,
                         funcmode    IN     VARCHAR2,
                         result       OUT NOCOPY  VARCHAR2) IS
     l_repeat_check   VARCHAR2(30) ;
BEGIN
-- dbms_output.put_line('Process Check_Repeat');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
        l_repeat_check  := WF_ENGINE.GetItemAttrText(
                              itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                       aname      =>    'AMS_REPEAT_FREQUENCY_TYPE' );

      IF   l_repeat_check  = 'NONE' THEN
         result := 'COMPLETE:N' ;
      ELSE
         result := 'COMPLETE:Y' ;
      END IF ;
    END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:N' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:N' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_Repeat',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Repeat ;

-- Start of Comments
--
-- NAME
--   Schedule_Trig_Run
--
-- PURPOSE
--   This Procedure will Calculate the next schedule date for Trigger to fire
--
--   It will Return - Success if the check is successful
--                - Error   If there is an error in the Check Process
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:SUCCESS' If the Scheduling is successful
--            - 'COMPLETE:ERROR' If the scheduling is errored out
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_SCHEDULE_TRIG_RUN
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Schedule_Trig_Run   (itemtype    IN     VARCHAR2,
                         itemkey    IN     VARCHAR2,
                         actid        IN     NUMBER,
                         funcmode    IN     VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) IS
    l_msg_count             NUMBER ;
    l_msg_data               VARCHAR2(2000);
    l_final_data            VARCHAR2(4000);
    l_msg_index            NUMBER ;
    l_cnt                  NUMBER := 0 ;
    l_trigger_id          NUMBER ;
    l_return_status        VARCHAR2(1);
    l_sch_date             DATE;
--    l_trigger_date          DATE;
     l_trigger_date          VARCHAR2(30);
    --l_repeat_frequency_type VARCHAR2(30);

    l_user_last_run_date_time  DATE ;
    l_user_next_run_date_time  DATE ;

    -- Store the Ref. Date from which to calculate next date
    l_cur_date       DATE ;
    l_last_run_date   DATE;

    -- Temp. Variables
    l_tmp                VARCHAR2(2) ;
    l_str             VARCHAR2(30) ;

   -- Start :anchaudh: 15 Oct'03 : added the following cursor and the variable.
   CURSOR  c_triggers(l_my_trigger_id NUMBER) IS
   SELECT  *
   FROM    ams_triggers
   WHERE   trigger_id  = l_my_trigger_id ;

   l_trigger      c_triggers%rowtype ;
    -- End :anchaudh: 15 Oct'03 : added the following cursor and the variable.

/*
   CURSOR c_sch_date(l_trigger_id NUMBER) IS
   SELECT next_run_date_time
   FROM ams_triggers
   WHERE trigger_id = l_trigger_id;
   l_trig_date    c_sch_date%ROWTYPE;
*/
BEGIN
/*
l_trigger_id   := WF_ENGINE.GetItemAttrText   (itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIGGER_ID');

UPDATE ams_triggers SET next_run_date_time = (next_run_date_time+1/360) WHERE trigger_id = l_trigger_id;
COMMIT;
OPEN c_sch_date(l_trigger_id);
    FETCH c_sch_date INTO l_sch_date;
    CLOSE c_sch_date;
    WF_ENGINE.SetItemAttrText(itemtype  =>    itemtype,
                                     itemkey   =>     itemkey ,
                                     aname      =>    'AMS_TRIGGER_SCHEDULE_DATE',
                                        avalue      =>      to_char(l_sch_date,'DD-MON-RRRR HH:MI:SS AM'));

result := 'COMPLETE:ERROR' ;
*/
-- dbms_output.put_line('Process Schedule_Trig_Run');
    IF (funcmode = 'RUN')
    THEN

     FND_MSG_PUB.initialize;

       l_trigger_id   := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIGGER_ID');

        l_trigger_date := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIGGER_SCHEDULE_DATE');

-- dbms_output.put_line('l_trigger_date '|| l_trigger_date);
-- dbms_output.put_line('l_trigger_date '||to_char(l_trigger_date,'DD-MON-RRRR HH:MI:SS AM'));

        WF_ENGINE.SetItemAttrText(itemtype  =>    itemtype,
                             itemkey   =>     itemkey ,
                            aname      =>    'AMS_TRIGGER_DATE',
                                avalue    =>    l_trigger_date
            );

-- dbms_output.put_line('Before Condi '||l_trigger_id);
      -- Call Schedule Procedure only if the trigger is repeating


-- Start :anchaudh: 15 Oct'03 : uncommented the call to "Schedule_Next_Trigger_Run" and calling "Schedule_Repeat" instead.

 /*    AMS_ContCampaign_PVT.Schedule_Next_Trigger_Run
         (p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          p_trigger_id         => l_trigger_id,
               x_msg_count         => l_msg_count,
          x_msg_data          => l_msg_data,
          x_return_status    => l_return_status,
          x_sch_date           => l_sch_date)       ;*/

       OPEN c_triggers(l_trigger_id) ;
       FETCH c_triggers INTO l_trigger ;
       CLOSE c_triggers ;

        -- First Mark the Last Run Date Time (Update AMS_TRIGGERS with this date
        -- at the end   )
       IF l_trigger.last_run_date_time IS NULL THEN
         l_cur_date := l_trigger.start_date_time ;
         l_last_run_date := l_trigger.start_date_time ;
       ELSE
          l_cur_date :=  l_trigger.next_run_date_time ;
          l_last_run_date := l_trigger.next_run_date_time ;
       END IF;

       IF SYSDATE > l_cur_date
       THEN
          l_cur_date := sysdate;
          l_last_run_date := sysdate;
        END IF;

       AMS_SCHEDULER_PVT.Schedule_Repeat( p_last_run_date => l_cur_date,
                                        p_frequency       => l_trigger.repeat_every_x_frequency,
                                        p_frequency_type  => l_trigger.repeat_frequency_type ,
                                        x_next_run_date   => l_sch_date,
                                        x_return_status   => l_return_status,
                                        x_msg_count       => l_msg_count,
                                        x_msg_data        => l_msg_data);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             Handle_Err
                 (p_itemtype          => itemtype   ,
                   p_itemkey           => itemkey    ,
                   p_msg_count         => l_msg_count, -- Number of error Messages
                   p_msg_data          => l_msg_data ,
                   p_attr_name         => 'AMS_SCH_ERROR_MSG'
                 );

              result := 'COMPLETE:ERROR' ;
              RETURN;
       END IF;

       -- The calls added to calculate the time in User's timezone

       AMS_Utility_PVT.Convert_Timezone(
          p_init_msg_list       => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,

          p_user_tz_id          => l_trigger.timezone_id,
          p_in_time             => l_cur_date  ,
          p_convert_type        => 'USER' ,

          x_out_time            => l_user_last_run_date_time
          ) ;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             Handle_Err
                 (p_itemtype          => itemtype   ,
                   p_itemkey           => itemkey    ,
                   p_msg_count         => l_msg_count, -- Number of error Messages
                   p_msg_data          => l_msg_data ,
                   p_attr_name         => 'AMS_SCH_ERROR_MSG'
                 );

              result := 'COMPLETE:ERROR' ;
              RETURN;
       END IF;

       AMS_Utility_PVT.Convert_Timezone(
              p_init_msg_list       => FND_API.G_FALSE,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data,

              p_user_tz_id          => l_trigger.timezone_id,
              p_in_time             => l_sch_date  ,
              p_convert_type        => 'USER' ,

              x_out_time            => l_user_next_run_date_time
              );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_SCH_ERROR_MSG'
                        );

                   result := 'COMPLETE:ERROR' ;
                   RETURN;
       END IF;

       UPDATE ams_triggers
             SET    last_run_date_time = l_cur_date,
                      next_run_date_time = l_sch_date,
                      user_last_run_date_time = l_user_last_run_date_time,
                      user_next_run_date_time = l_user_next_run_date_time
             WHERE  trigger_id = l_trigger_id ;


-- End :anchaudh: 15 Oct'03 : uncommented the call to "Schedule_Next_Trigger_Run" and calling "Schedule_Repeat" instead.

-- dbms_OUTPUT.PUT_LINE('Next Scheduled Date is : '||to_char(l_sch_date,'DD-MON-RRRR:HH-MI-SS AM'));

       --IF (l_return_status = FND_API.G_RET_STS_SUCCESS)  THEN
       WF_ENGINE.SetItemAttrText(itemtype  =>    itemtype,
                                     itemkey   =>     itemkey ,
                                     aname      =>    'AMS_TRIGGER_SCHEDULE_DATE',
                                     avalue      =>      to_char(l_sch_date,'DD-MON-RRRR HH:MI:SS AM'));

                      result := 'COMPLETE:SUCCESS' ;
          /*  ELSE
                    Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_SCH_ERROR_MSG'
                            )               ;

              result := 'COMPLETE:ERROR' ;*/
       --END IF ;

    END IF;

    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Schedule_Trig_Run',itemtype,itemkey,actid,funcmode);
        raise ;

END Schedule_Trig_Run ;

-- Start of Comments
--
-- NAME
--   Check_Trigger_Status
--
-- PURPOSE
--   This Procedure will check whether the Trigger is Active or Expired
--   It will Return - Yes  if the trigger is Active
--                 - No If the trigger is Expired
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--            - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_CHECK_TRIGGER_STATUS
--
-- NOTES
--
--
-- HISTORY
--    28-apr-2003   soagrawa  Modified for retrieval of date thru database
--
-- End of Comments

PROCEDURE Check_Trigger_Status    (itemtype    IN     VARCHAR2,
                           itemkey        IN     VARCHAR2,
                         actid        IN     NUMBER,
                         funcmode    IN     VARCHAR2,
                         result       OUT NOCOPY  VARCHAR2) IS

   l_end_date                DATE; -- VARCHAR2(30)    ;
    l_sch_date               VARCHAR2(30)    ;
    l_trigger_id             NUMBER;
    itemuserkey              VARCHAR2(80) ;

    -- soagrawa 28-apr-2003 added this cursor to get end date of trigger
    CURSOR c_trig_end_dt(p_trig_id NUMBER) IS
    SELECT repeat_stop_date_time --to_char(repeat_stop_date_time,'DD-MM-RRRR HH:MI:SS AM')
    FROM   ams_triggers
    WHERE  trigger_id = p_trig_id;

BEGIN
-- dbms_output.put_line('Process Check_Trigger_Status');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN') THEN

       l_trigger_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_TRIGGER_ID');

       OPEN  c_trig_end_dt(l_trigger_id);
       FETCH c_trig_end_dt INTO l_end_date;
       CLOSE c_trig_end_dt;

       /*l_end_date  := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname       =>    'AMS_TRIGGER_REPEAT_END_DATE');*/

      /*l_sch_date  := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname       =>    'AMS_TRIGGER_SCHEDULE_DATE');*/

      IF (l_end_date IS NOT NULL) THEN
--cgoyal removed date formatting on 30/may/03 to fix GSCC errors
         IF (sysdate < l_end_date) THEN
            result := 'COMPLETE:Y' ;
         ELSE
            result := 'COMPLETE:N' ;
         END IF ;
      ELSE
         result := 'COMPLETE:Y' ;
      END IF;

   END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
-- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_Trigger_Status',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Trigger_Status ;

-- Start of Comments
--
-- NAME
--   Perform_Check
--
-- PURPOSE
--   This Procedure will perform the check on standard item and Comparison Item
--   with the operator provided
--   It will Return - Success if the check is successful
--                 - Failure If the check is not successful
--                - Error   If there is an error in the Check Process
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:SUCCESS' If the check is successful
--            - 'COMPLETE:FAILURE' If the check is Failure
--          - 'COMPLETE:ERROR' If there is an Error in the check Process
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_PERFORM_CHECK
--
-- NOTES
--
-- HISTORY
--   22-MAR-2001   julou       Created
--   28-APR-2003   soagrawa    Modified
--
-- End of Comments

PROCEDURE Perform_check    (itemtype    IN     VARCHAR2,
                        itemkey        IN     VARCHAR2,
                      actid        IN     NUMBER,
                      funcmode    IN     VARCHAR2,
                      result       OUT NOCOPY  VARCHAR2) IS
     l_msg_count            NUMBER ;
    l_msg_data              VARCHAR2(2000);
    l_final_data           VARCHAR2(4000);
    l_msg_index           NUMBER ;
    l_cnt                 NUMBER := 0 ;
    l_trigger_id         NUMBER ;
    l_return_status       VARCHAR2(1);
    l_chk_success         NUMBER(1) ;
     l_message              VARCHAR2(1000);

     l_metric_name          VARCHAR2(120) ;
    l_camp_name            VARCHAR2(120) ;
    l_operator             VARCHAR2(30) ;
    l_value                NUMBER;
     l_high_value           NUMBER;
     l_uom                  VARCHAR2(3) ;
     l_currency             VARCHAR2(15) ;
     l_result_id            NUMBER  ;
--     l_errbuf              VARCHAR2;
     l_retcode             NUMBER;

     CURSOR c_check_det (p_trigger_id NUMBER) IS
     SELECT chk1_type, chk1_source_code_metric_id,
            chk2_type, chk2_source_code_metric_id
     FROM   ams_trigger_checks
     WHERE  trigger_id = p_trigger_id;

     l_chk1_type        VARCHAR2(30);
     l_chk2_type        VARCHAR2(30);
     l_chk1_metric_id   NUMBER;
     l_chk2_metric_id   NUMBER;

--     CURSOR c_metric_det(p_metric_id NUMBER) IS
--     SELECT arc_act_metric_used_by, arc_metric_used_by_id
--     FROM   ams_act_metrics_all
--     WHERE  activity_metric_id = p_metric_id;

     l_chk1_source_type VARCHAR2(30);
     l_chk2_source_type VARCHAR2(30);
     l_chk1_source_id   NUMBER;
     l_chk2_source_id   NUMBER;

BEGIN
--result := 'COMPLETE:SUCCESS';
-- dbms_output.put_line('Process Perform_check');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN

     FND_MSG_PUB.initialize;
      l_trigger_id  := WF_ENGINE.GetItemAttrText(itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                  aname      =>    'AMS_TRIGGER_ID'
                  );
/*
      OPEN  c_check_det(l_trigger_id);
      FETCH c_check_det INTO l_chk1_type,  l_chk1_metric_id,
                              l_chk2_type, l_chk2_metric_id;
      CLOSE c_check_det;

      IF l_chk1_type = 'METRIC'
      THEN
         OPEN  c_metric_det(l_chk1_metric_id);
         FETCH c_metric_det INTO l_chk1_source_type, l_chk1_source_id;
         CLOSE c_metric_det;

         ams_actmetrics_engine_pvt.Refresh_Act_Metrics_Engine
             (p_arc_act_metric_used_by => l_chk1_source_type,
              p_act_metric_used_by_id  => l_chk1_source_id,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data,
              p_commit                 => Fnd_Api.G_FALSE);

         IF l_return_status <> FND_API.g_ret_sts_success THEN
          result := 'COMPLETE:FAILURE';
          return;
         END IF;
      END IF;

      IF l_chk2_type = 'METRIC'
      THEN
         OPEN  c_metric_det(l_chk2_metric_id);
         FETCH c_metric_det INTO l_chk2_source_type, l_chk2_source_id;
         CLOSE c_metric_det;

         IF (l_chk1_source_type = l_chk2_source_type)
            AND (l_chk2_source_id = l_chk1_source_id)
         THEN
           NULL;
         ELSE
            ams_actmetrics_engine_pvt.Refresh_Act_Metrics_Engine
                (p_arc_act_metric_used_by => l_chk2_source_type,
                 p_act_metric_used_by_id  => l_chk2_source_id,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data,
                 p_commit                 => Fnd_Api.G_FALSE);

            IF l_return_status <> FND_API.g_ret_sts_success THEN
             result := 'COMPLETE:FAILURE';
             return;
            END IF;
         END IF;
      END IF;
*/
    AMS_ContCampaign_PVT.Perform_Checks
                       (p_api_version       => 1.0 ,
                              p_init_msg_list     => FND_API.G_FALSE,
                              x_return_status     => l_return_status,
                          x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data,
                          p_trigger_id          => l_trigger_id,
                        x_chk_success           => l_chk_success,
                              x_check_val         => l_value,
                              x_check_high_val    => l_high_value,
                              x_result_id         => l_result_id
                               ) ;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF l_chk_success = '0' THEN
               result := 'COMPLETE:FAILURE' ;
         ELSIF  l_chk_success = '1' THEN
                l_camp_name  := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_CAMPAIGN_NAME');

                l_operator  := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_OPERATOR');

                -- Create Message to Define the Check Condition met
                IF l_operator = 'BETWEEN' THEN
                    FND_MESSAGE.Set_Name('AMS','AMS_TRIG_CHECK_BET_EXIST');
                       FND_MESSAGE.Set_Token('CAMP_NAME', l_camp_name, FALSE);
                       FND_MESSAGE.Set_Token('OPERATOR', l_operator, FALSE);
                       FND_MESSAGE.Set_Token('VALUE', l_value, FALSE);
                    FND_MESSAGE.Set_Token('HIGH_VALUE', l_high_value, FALSE);
                ELSE
                    FND_MESSAGE.Set_Name('AMS','AMS_TRIG_CHECK_EXIST');
                       FND_MESSAGE.Set_Token('CAMP_NAME', l_camp_name, FALSE);
                       FND_MESSAGE.Set_Token('OPERATOR', l_operator, FALSE);
                       FND_MESSAGE.Set_Token('VALUE', l_value, FALSE);
                END IF ;

             l_message := FND_MESSAGE.Get;

               WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                    itemkey     =>   itemkey,
                                   aname        =>     'AMS_NTF_MESSAGE',
                                  avalue        =>     l_message);

               WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                    itemkey     =>   itemkey,
                                   aname        =>     'AMS_TRIG_RESULT_ID',
                                  avalue        =>     l_result_id);

                result := 'COMPLETE:SUCCESS' ;
         END IF ;
      ELSE
            Handle_Err
                        (p_itemtype          => itemtype   ,
                         p_itemkey           => itemkey    ,
                         p_msg_count         => l_msg_count, -- Number of error Messages
                         p_msg_data          => l_msg_data ,
                         p_attr_name         => 'AMS_CHECK_ERROR_MSG'
                            )               ;
         result := 'COMPLETE:ERROR' ;
      END IF ;

    END IF;

    --  CANCEL mode  - Normal Process Execution
    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    --  TIMEOUT mode  - Normal Process Execution
    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Perform_check',itemtype,itemkey,actid,funcmode);
        raise ;

END Perform_check ;

-- Start of Comments
--
-- NAME
--   Notify_Chk_Met
--
-- PURPOSE
--   This Procedure will return Yes if Notification is required for the Trigger
--    or it will return No if No Notification required
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the notification is required
--           - 'COMPLETE:N' If the notification is not required
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_Notify_Chk_Met
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Notify_Chk_Met (itemtype    IN     VARCHAR2,
                          itemkey      IN     VARCHAR2,
                        actid      IN     NUMBER,
                        funcmode      IN     VARCHAR2,
                        result      OUT NOCOPY     VARCHAR2) IS
     l_notify_chk   VARCHAR2(30) ;
     l_action_performed       VARCHAR2(80);
     l_return_status   VARCHAR2(1);
     l_trigger_id      NUMBER;
BEGIN
   IF (funcmode = 'RUN') THEN

         l_notify_chk := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_NOTIF_TO_USER_NAME');

        IF   l_notify_chk = '' OR l_notify_chk IS NULL THEN
          result := 'COMPLETE:N' ;
        ELSE
           result := 'COMPLETE:Y' ;
     END IF ;

  END IF;

    IF (funcmode = 'CANCEL')
    THEN
        result := 'COMPLETE:' ;
       RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
        result := 'COMPLETE:' ;
       RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Notify_Chk_Met',itemtype,itemkey,actid,funcmode);
        raise ;

END Notify_Chk_Met ;


-- Start of Comments
--
-- NAME
--   Require_Approval
--
-- PURPOSE
--   This Procedure will return Y if there is an Approval is required for the List
--     or it will return N if there is no Approval is required
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the notification is required
--              - 'COMPLETE:N' If the notification is not required
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_REQUIRE_APPROVAL
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Require_Approval    (itemtype    IN     VARCHAR2,
                        itemkey        IN     VARCHAR2,
                      actid        IN     NUMBER,
                      funcmode    IN     VARCHAR2,
                      result       OUT NOCOPY  VARCHAR2) IS
     l_req_approval   VARCHAR2(30) ;
BEGIN
-- dbms_output.put_line('Process Require Approval');
    IF (funcmode = 'RUN')
    THEN
       l_req_approval := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_APPROVER_NAME');

      IF   l_req_approval = '' OR l_req_approval IS NULL THEN
         result := 'COMPLETE:N' ;
      ELSE
         result := 'COMPLETE:Y' ;
      END IF ;

    END IF;

    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Require_Approval',itemtype,itemkey,actid,funcmode);
        raise ;
END Require_Approval ;

-- Start of Comments
--
-- NAME
--   Record_Result
--
-- PURPOSE
--   This Procedure will record the the Actions taken
--     when the trigger was filed
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:'
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_RECORD_RESULT
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001       julou     created
-- End of Comments

PROCEDURE Record_Result       (itemtype    IN     VARCHAR2,
                        itemkey        IN     VARCHAR2,
                      actid        IN     NUMBER,
                      funcmode    IN     VARCHAR2,
                      result       OUT NOCOPY  VARCHAR2) IS
l_action_taken         VARCHAR2(80);
l_trigger_id           NUMBER ;
l_return_status        VARCHAR2(1);
l_process_id            NUMBER ;
BEGIN
-- dbms_output.put_line('Process Record Result');
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIGGER_ID');
/*
       l_action_taken := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_ACTION_TAKEN');
*/
       l_process_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIG_RESULT_ID');

l_action_taken := 'Trigger ' || l_trigger_id;
l_process_id := l_trigger_id;
-- Here the Pass the Result ID set by Check Process. So, If there is no check with
-- this trigger(Process ID will be null) , create new row in Result table and Record Action
-- If there is Check associated with trigger, modify the row created for check with Actions performed

        AMS_ContCampaign_PVT.Record_Result (p_result_for_id     => l_trigger_id,
                    p_process_id          => l_process_id,
                        p_action_taken        => l_action_taken,
                  x_return_status         => l_return_status,
                   x_result_id         => l_process_id
                   );

        WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                             itemkey     =>   itemkey,
                              aname        =>     'AMS_TRIG_RESULT_ID',
                                   avalue      =>   NULL
               );
/*
        UPDATE ams_triggers
        SET    process_id = null
        WHERE  trigger_id = l_trigger_id;
*/
        result := 'COMPLETE:' ;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;

    IF (funcmode = 'TIMEOUT')
    THEN
       result := 'COMPLETE:' ;
      RETURN;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Record_Result',itemtype,itemkey,actid,funcmode);
        raise ;
END Record_Result ;

-- Start of Comments
--
-- NAME
--   Execute_Schedule
--
-- PURPOSE
--   This Procedure will execute the schedule
--   Action will be implemented later.
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:'
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - EXECUTE_SCHEDULE
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001    julou     created
--   06-APR-2001    julou     change schedule id to null
--   25-nov-2002    soagrawa  added generation of Target group before CSCH activation
--   25-aug-2003    soagrawa  modified code to fix bug# 3111622
--   26-sep-2003    soagrawa  modified code to replace execution of schedule API with WF Bus Event
-- End of Comments

PROCEDURE Execute_Schedule    (itemtype    IN     VARCHAR2,
                        itemkey        IN     VARCHAR2,
                      actid        IN     NUMBER,
                      funcmode    IN     VARCHAR2,
                      result       OUT NOCOPY  VARCHAR2) IS

  l_return_status       VARCHAR2(1);
  l_log_return_status       VARCHAR2(1);
  l_msg_count            NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_sch_id            NUMBER;
  l_tgrp_name         VARCHAR2(240);

 CURSOR c_det_tgrp_name (p_sch_id NUMBER) IS
   select list.list_name
   from ams_list_headers_vl list, ams_Act_lists act
   where list.list_header_id = act.list_header_id
   and act.list_used_by_id = p_sch_id
   and act.list_Act_Type = 'TARGET';

  -- soagrawa added following code on 26-sep-2003 for replacing execute schedule with raising business event
  l_parameter_list  WF_PARAMETER_LIST_T;
  l_new_item_key    VARCHAR2(30);
  l_start_time            DATE;
  l_sys_start_time        DATE;
  l_timezone              NUMBER;

  CURSOR c_sch_det (p_schedule_id NUMBER) IS
  SELECT start_date_time, timezone_id
  FROM   ams_campaign_schedules_b
  WHERE  schedule_id = p_schedule_id;
  -- end soagrawa 26-sep-2003

BEGIN
-- 06-APR-2001  julou  Comment out schedule_id
--                     Pass the schedule id which is null by default for now.



  l_sch_id := WF_ENGINE.GetItemAttrText(
                    itemtype =>    itemtype,
                    itemkey    =>     itemkey ,
                    aname      =>    'AMS_SCHEDULE_ID');

  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'Activate Schedule through triggers: schedule id is '||l_sch_id,
                     p_msg_type        => 'DEBUG'
                     );

  l_tgrp_name := NULL;

  OPEN  c_det_tgrp_name(l_sch_id);
  FETCH c_det_tgrp_name INTO l_tgrp_name;
  CLOSE c_det_tgrp_name;

  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'Target group name is '||l_tgrp_name,
                     p_msg_type        => 'DEBUG'
                     );

  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'Item type is '||itemtype,
                     p_msg_type        => 'DEBUG'
                     );

  WF_ENGINE.SetItemAttrText(itemtype  =>    itemtype,
                                     itemkey   =>     itemkey ,
                                     aname      =>    'AMS_NEW_LIST_NAME',
                                        avalue      => l_tgrp_name);
 IF (l_tgrp_name is not NULL) THEN

  Ams_Utility_pvt.debug_message('Before generating tgrp');
  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'Before generating tgrp ' || itemkey ,
                     p_msg_type        => 'DEBUG'
                     );
  Ams_Utility_pvt.debug_message('Schedule id: '||l_sch_id);

  AMS_Act_List_PVT.generate_target_group_list_old
   ( p_api_version            => 1.0,
     p_init_msg_list          => FND_API.G_FALSE,
     p_commit                 => FND_API.G_FALSE,
     p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
     p_list_used_by           => 'CSCH',
     p_list_used_by_id        => l_sch_id,
     x_return_status          => l_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data
     ) ;

  Ams_Utility_pvt.debug_message('return status from generate target group: '||l_return_status);
  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'return status from generate target group: ' || l_return_status ,
                     p_msg_type        => 'DEBUG'
                     );

  IF l_return_status = FND_API.g_ret_sts_success THEN
    result := 'COMPLETE:SUCCESS';
  ELSE
    result := 'COMPLETE:ERROR';
/*    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_LIST_ERROR_MSG',
                              avalue   => l_msg_data);*/
     Handle_Err
         (p_itemtype          => itemtype   ,
          p_itemkey           => itemkey    ,
          p_msg_count         => l_msg_count, -- Number of error Messages
          p_msg_data          => l_msg_data ,
          p_attr_name         => 'AMS_LIST_ERROR_MSG'
             )               ;
    RETURN;
  END IF;
 ELSE
    -- soagrawa 13-sep-2005 , added for when target group is not there
    result := 'COMPLETE:SUCCESS';
 END IF;

  -- soagrawa 26-sep-2003 commented the activation code and replaced it with raising business event
  /*
  Ams_Utility_pvt.debug_message('Before activating csch');
  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'Before activating csch: ' ,
                     p_msg_type        => 'DEBUG'
                     );

  AMS_ScheduleRules_PVT.Activate_Schedule(p_api_version   => 1.0
                                         ,p_init_msg_list => FND_API.G_FALSE
                                         ,p_commit        => FND_API.G_False
                                         ,x_return_status => l_return_status
                                         ,x_msg_count     => l_msg_count
                                         ,x_msg_data      => l_msg_data
                                         ,p_schedule_id   => l_sch_id
                                         );
-- end of the change 06-APR-2001
  Ams_Utility_pvt.debug_message('return status from activate schedule: '||l_return_status);

  AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_log_return_status,
                     p_arc_log_used_by => 'CSCH',
                     p_log_used_by_id  => l_sch_id,
                     p_msg_data        => 'return status from activate schedule: ' || l_return_status ,
                     p_msg_type        => 'DEBUG'
                     );
  IF l_return_status = FND_API.g_ret_sts_success THEN
    result := 'COMPLETE:SUCCESS';
  ELSE
    result := 'COMPLETE:ERROR';
    --WF_ENGINE.SetItemAttrText(itemtype => itemtype,
    --                          itemkey  => itemkey,
    --                          aname    => 'AMS_LIST_ERROR_MSG',
    --                          avalue   => l_msg_data);
     Handle_Err
         (p_itemtype          => itemtype   ,
          p_itemkey           => itemkey    ,
          p_msg_count         => l_msg_count, -- Number of error Messages
          p_msg_data          => l_msg_data ,
          p_attr_name         => 'AMS_LIST_ERROR_MSG'
             )               ;
  END IF;
  */

   l_new_item_key    := l_sch_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
   l_parameter_list := WF_PARAMETER_LIST_T();
   wf_event.AddParameterToList(p_name           => 'SCHEDULE_ID',
                              p_value           => l_sch_id,
                              p_parameterlist   => l_parameter_list);

   OPEN  c_sch_det(l_sch_id);
   FETCH c_sch_det INTO l_start_time, l_timezone;
   CLOSE c_sch_det;

   AMS_UTILITY_PVT.Convert_Timezone(
         p_init_msg_list   => FND_API.G_TRUE,
         x_return_status   => l_return_status,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data,

         p_user_tz_id      => l_timezone,
         p_in_time         => l_start_time,
         p_convert_type    => 'SYS',

         x_out_time        => l_sys_start_time
         );

   -- If any errors happen let start time be sysdate
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      l_sys_start_time := SYSDATE;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      l_sys_start_time := SYSDATE;
   END IF;

   --AMS_Utility_PVT.debug_message('Raise Business event for schedule execution');
   WF_EVENT.Raise
      ( p_event_name   =>  'oracle.apps.ams.campaign.ExecuteSchedule',
        p_event_key    =>  l_new_item_key,
        p_parameters   =>  l_parameter_list,
        p_send_date    =>  l_sys_start_time);


END Execute_Schedule;

-- Start of Comments
--
-- NAME
--   Get_Aval_Sch
--
-- PURPOSE
--   This Procedure will get the available schedule that is attached to
--   the given trigger. Schedule id, notify flag and require approveal flag
--   will be set based on the status_code, notify_user_id and approver_user_id,
--   respectively.
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:'
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - GET_AVAL_SCH
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001    julou     created
--   28-apr-2003    soagrawa  Modified for redesign
--
-- End of Comments

PROCEDURE Get_Aval_Sch(itemtype IN  VARCHAR2,
                       itemkey  IN  VARCHAR2,
                       actid    IN  NUMBER,
                       funcmode IN  VARCHAR2,
                       result   OUT NOCOPY VARCHAR2)
IS

  l_trigger_id    NUMBER;
  l_return_status VARCHAR2(1);
  l_return_log_status VARCHAR2(1);
  l_msg_count     NUMBER ;
  l_msg_data      VARCHAR2(2000);
  l_item_key      VARCHAR2(30);
  l_approver      VARCHAR2(30);
  l_notify        VARCHAR2(30);
  l_owner         VARCHAR2(30);
  l_display_name  VARCHAR2(30);

  CURSOR c_sch_det(l_trig_id NUMBER) IS
    SELECT schedule_id, notify_user_id, approver_user_id, owner_user_id, schedule_name
    FROM ams_campaign_schedules_vl
    WHERE trigger_id = l_trig_id
      AND status_code = 'AVAILABLE'
      -- soagrawa 28-apr-2003 added the following to this cursor
      AND (trig_repeat_flag IS NULL OR trig_repeat_flag = 'N');

BEGIN

   IF (funcmode = 'RUN')
   THEN
  l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype => itemtype,
                        itemkey  => itemkey ,
                        aname    => 'AMS_TRIGGER_ID');

        AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_log_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => l_trigger_id,
         p_msg_data        => 'Get_Aval_Sch :  1. Started ' || to_char(sysdate,'DD-MON-RRRR HH:MI:SS AM') ,
         p_msg_type        => 'DEBUG'
        );

--  dbms_output.put_line('master itemkey: ' || itemkey);
--  dbms_output.put_line('trigger id: ' || l_trigger_id);

  FOR l_sch_det_rec IN c_sch_det(l_trigger_id)
  LOOP

        AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_log_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => l_trigger_id,
         p_msg_data        => 'Get_Aval_Sch :  Looping for schedule id ' ||l_sch_det_rec.schedule_id ,
         p_msg_type        => 'DEBUG'
        );

    l_item_key := l_sch_det_rec.schedule_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
--    dbms_output.put_line('detail itemkey: ' || l_item_key);


     --dbms_output.put_line('Creating process');
     WF_ENGINE.CreateProcess (itemtype => itemtype, --itemtype,
                              itemkey  => l_item_key ,
                                    user_key => l_sch_det_rec.schedule_name,
                              process  => 'AMS_EXEC_ATTCH_SCH'); -- name of the process

    -- set schedule owner
    Get_User_Role(p_user_id           => l_sch_det_rec.owner_user_id,
                  x_role_name         => l_owner,
                  x_role_display_name => l_display_name,
                  x_return_status     => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    WF_ENGINE.SetItemAttrText(itemtype => itemtype
                             ,itemkey  => l_item_key
                             ,aname    => 'AMS_SCHEDULE_OWNER'
                             ,avalue   => l_owner);

    WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                      ,itemkey  => l_item_key
                                      ,aname    => 'AMS_REQUESTOR_USERNAME'
                                      ,avalue   => l_owner);

    -- set schedule id
    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                               itemkey  => l_item_key,
                              aname    => 'AMS_SCHEDULE_ID',
                              avalue   => l_sch_det_rec.schedule_id);

    -- set schedule name
    WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                              itemkey  => l_item_key,
                              aname    => 'AMS_SCHEDULE_NAME',
                              avalue   => l_sch_det_rec.schedule_name);

    -- set notify user
          IF l_sch_det_rec.notify_user_id IS NOT NULL
          THEN
      Get_User_Role(p_user_id           => l_sch_det_rec.notify_user_id,
                    x_role_name         => l_notify,
                    x_role_display_name => l_display_name,
                    x_return_status     => l_return_status);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS
             THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      WF_ENGINE.SetItemAttrText(itemtype => itemtype
                               ,itemkey  => l_item_key
                               ,aname    => 'AMS_NOTIF_TO_USER_NAME'
                               ,avalue   => l_notify);
    ELSE
      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => l_item_key,
                                aname    => 'AMS_NOTIF_TO_USER_NAME',
                                avalue   => '' );
    END IF;

    -- set approver
          IF l_sch_det_rec.approver_user_id IS NOT NULL
          THEN
      Get_User_Role(p_user_id           => l_sch_det_rec.approver_user_id,
                    x_role_name         => l_approver,
                    x_role_display_name => l_display_name,
                    x_return_status     => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      WF_ENGINE.SetItemAttrText(itemtype => itemtype
                               ,itemkey  => l_item_key
                               ,aname    => 'AMS_APPROVER_NAME'
                               ,avalue   => l_approver);
    ELSE
      WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => l_item_key,
                                aname    => 'AMS_APPROVER_NAME',
                                avalue   => '' );
    END IF;

   -- soagrawa added setting all the other values...
    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype ,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_TRIGGER_ID',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_TRIGGER_ID')  );

    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_TRIGGER_NAME',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_TRIGGER_NAME')  );


    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_TRIGGER_SCHEDULE_DATE',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_TRIGGER_SCHEDULE_DATE')  );


    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_TRIGGER_DATE',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_TRIGGER_DATE')  );


    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_REPEAT_FREQUENCY_TYPE',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_REPEAT_FREQUENCY_TYPE')  );


    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                         itemkey     =>   l_item_key,
                        aname    =>     'AMS_TRIGGER_REPEAT_END_DATE',
                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_TRIGGER_REPEAT_END_DATE')  );


    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   l_item_key,
                            aname        =>     'AMS_CAMPAIGN_NAME',
                            avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
                                                                   itemkey     =>  itemkey ,
                                                                   aname     =>   'AMS_CAMPAIGN_NAME')  );

--    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
--                         itemkey     =>   l_item_key,
--                        aname    =>     'AMS_CHK_MET_MSG',
--                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
--                                                                   itemkey     =>  itemkey ,
--                                                                   aname     =>   'AMS_CHK_MET_MSG')  );


--    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
--                            itemkey     =>   l_item_key,
--                            aname        =>     'AMS_NTF_MESSAGE',
--                            avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
--                                                                   itemkey     =>  itemkey ,
--                                                                   aname     =>   'AMS_NTF_MESSAGE')  );

   -- end soagrawa setting values

    -- set the parent process
    WF_ENGINE.SetItemParent(itemtype        => itemtype
                           ,itemkey         => l_item_key
                           ,parent_itemtype => itemtype
                           ,parent_itemkey  => itemkey
                           ,parent_context  => NULL
                           );

    WF_ENGINE.StartProcess (itemtype => itemtype,
                            itemkey  => l_item_key);

  END LOOP;
        RETURN;
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;

END Get_Aval_Sch;


/*
-- Start of Comments
--
-- NAME
--   CHECK_ACTIVE_SCH
--
-- PURPOSE
--   This Procedure will check if there are more active schedules available,
--   by counting the number of active schedules.
--   It will return 'COMPLETE:Y' if there are active schedules available
--   and 'COMPLETE:N' if no active schedules.
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:'
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - CHECK_ACTIVE_SCH
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001  julou     created
-- End of Comments

PROCEDURE Check_Active_Sch    (itemtype    IN     VARCHAR2,
                        itemkey        IN     VARCHAR2,
                      actid        IN     NUMBER,
                      funcmode    IN     VARCHAR2,
                      result       OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_sch_count(l_trig_id NUMBER) IS
  SELECT count(1)
  FROM ams_campaign_schedules_vl
  WHERE trigger_id = l_trig_id
  AND status_code = 'AVAILABLE';


--  l_status    VARCHAR2(30);
  l_sch_count    NUMBER;
  l_trigger_id   NUMBER;
--  l_notify_id    NUMBER;
--  l_approver_id  NUMBER;

BEGIN
  l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>    itemtype,
                        itemkey      =>     itemkey ,
                        aname      =>    'AMS_TRIGGER_ID');

  OPEN c_sch_count(l_trigger_id);
  FETCH c_sch_count INTO l_sch_count;
  CLOSE c_sch_count;

  IF l_sch_count > 0 THEN
    result := 'COMPLETE:Y';
  ELSE
    result := 'COMPLETE:N';
  END IF;
END Check_Active_Sch;
*/

-- Start of Comments
-- NAME
--   Get_User_Role
--
-- PURPOSE
--   This procedure returns the User role for the userid sent
-- Called By
-- NOTES
-- End of Comments

PROCEDURE Get_User_Role
  ( p_user_id            IN     NUMBER,
    x_role_name          OUT NOCOPY    VARCHAR2,
    x_role_display_name  OUT NOCOPY    VARCHAR2 ,
    x_return_status      OUT NOCOPY    VARCHAR2)
IS
    CURSOR c_resource IS
    SELECT employee_id source_id
      FROM ams_jtf_rs_emp_v
     WHERE resource_id = p_user_id ;
     l_person_id number;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN c_resource ;
   FETCH c_resource INTO l_person_id ;
     IF c_resource%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_RESOURCE_ID');
          FND_MSG_PUB.Add;
     END IF;
   CLOSE c_resource ;
      -- Pass the Employee ID to get the Role
      WF_DIRECTORY.getrolename
             ( p_orig_system     => 'PER',
             p_orig_system_id    => l_person_id ,
             p_name              => x_role_name,
             p_display_name      => x_role_display_name );
     IF x_role_name is null  then
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
          FND_MSG_PUB.Add;
     END IF;
END Get_User_Role;

-- Start of Comments
--
-- NAME
--   AbortProcess
--
-- PURPOSE
--   This Procedure will abort the process of trigger
--

--
-- IN
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   24-MAR-2001       julou     created
-- End of Comments

PROCEDURE AbortProcess
      (p_trigger_id      IN   NUMBER,
            p_itemtype                  IN   VARCHAR2 DEFAULT NULL,
            p_workflow_process          IN   VARCHAR2 DEFAULT NULL  )
IS
     l_itemtype  VARCHAR2(30) := nvl(p_itemtype,'AMS_TRIG');
   l_itemkey   VARCHAR2(30) ;
        l_process   VARCHAR2(30) := nvl(p_workflow_process,'AMS_TRIGGERS');
CURSOR c_trig_det IS
    SELECT  process_id
    FROM    ams_triggers
    WHERE   trigger_id = p_trigger_id ;

l_status VARCHAR2(30);
l_result VARCHAR2(30);

BEGIN
-- dbms_output.put_line('Abort Process');
-- dbms_output.put_line('Item key : '||l_itemkey);

OPEN  c_trig_det ;
FETCH c_trig_det INTO l_itemkey;
IF c_trig_det%FOUND THEN

    WF_ENGINE.ItemStatus(itemtype   => l_itemtype,
                         itemkey    => l_itemkey,
                         status     => l_status,
                         result     => l_result);

--dbms_output.put_line('Item key: ' || l_itemkey);
--dbms_output.put_line('Status: ' || l_status);
    IF l_status <> 'COMPLETE' THEN
    WF_ENGINE.AbortProcess (itemtype => l_itemtype,
                                itemkey  => l_itemkey ,
                            process  => l_process);
    END IF;
END IF;
CLOSE c_trig_det ;
-- dbms_output.put_line('After Aborting Process ');
EXCEPTION
     WHEN OTHERS
     THEN
        wf_core.context(G_PKG_NAME,'AbortProcess',l_itemtype,l_itemkey);
         RAISE;

END AbortProcess;


-- Start of Comments
--
-- NAME
--   Trig_Type_Date
--
-- PURPOSE
--   This Procedure will check whether the Trigger isof type date
--   It will Return - Yes  if the trigger is of type date
--                  - No   Otherwise
--
-- IN
--    Itemtype - AMS_TRIG
--    Itemkey  - Trigger ID
--    Accid    - Activity ID
--    Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--             - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--      Activity  - AMS_CHECK_TRIG_TYPE
--
-- NOTES
--
--
-- HISTORY
--    28-apr-2003  soagrawa  Created
--
-- End of Comments

PROCEDURE Trig_Type_Date    (itemtype    IN     VARCHAR2,
                             itemkey     IN     VARCHAR2,
                             actid       IN     NUMBER,
                             funcmode    IN     VARCHAR2,
                             result      OUT NOCOPY    VARCHAR2) IS

    l_trig_type              VARCHAR2(30);
    l_trigger_id             NUMBER;

    -- soagrawa 28-apr-2003 added this cursor to get type of trigger
    CURSOR c_trig_type(p_trig_id NUMBER) IS
    SELECT triggering_type
    FROM   ams_triggers
    WHERE  trigger_id = p_trig_id;

BEGIN
   -- dbms_output.put_line('Process Trig_Type_Date');
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_TRIGGER_ID');

       OPEN  c_trig_type(l_trigger_id);
       FETCH c_trig_type INTO l_trig_type;
       CLOSE c_trig_type;

       IF l_trig_type = 'DATE'
       THEN
          result := 'COMPLETE:Y' ;
       ELSE
          result := 'COMPLETE:N' ;
       END IF;
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;
   -- dbms_output.put_line('End Trig_Type_Date :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Trig_Type_Date',itemtype,itemkey,actid,funcmode);
        raise ;
END Trig_Type_Date ;


-- Start of Comments
--
-- NAME
--   ACTION_NOTIFICATION
--
-- PURPOSE
--   This Procedure will check whether the Trigger needs to send notification as one of its actions
--   It will Return - Yes  if the trigger needs to send notifications
--                  - No   Otherwise
--
-- IN
--    Itemtype - AMS_TRIG
--    Itemkey  - Trigger ID
--    Accid    - Activity ID
--    Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--             - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--      Activity  - AMS_ACTION_NOTIFICATION
--
-- NOTES
--
--
-- HISTORY
--    28-apr-2003  soagrawa  Created
--
-- End of Comments

PROCEDURE Action_Notification    (itemtype    IN     VARCHAR2,
                             itemkey     IN     VARCHAR2,
                             actid       IN     NUMBER,
                             funcmode    IN     VARCHAR2,
                             result      OUT NOCOPY    VARCHAR2) IS

    l_notify_flag    VARCHAR2(1);
    l_trigger_id     NUMBER;

    -- soagrawa 28-apr-2003 added this cursor to get end date of trigger
    CURSOR c_trig_notify (p_trig_id NUMBER) IS
    SELECT notify_flag
    FROM   ams_triggers
    WHERE  trigger_id = p_trig_id;

    CURSOR c_notify_action_det (p_trig_id NUMBER) IS
    SELECT *
    FROM   ams_trigger_actions
    WHERE  trigger_id = p_trig_id
    AND    execute_action_type = 'NOTIFY';

    l_notify_action_det    c_notify_action_det%ROWTYPE;
    l_display_name         VARCHAR2(100);
    l_return_status        VARCHAR2(1);
    l_notify               VARCHAR2(30);



BEGIN
   -- dbms_output.put_line('Process Trig_Type_Date');
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN

       -- soagrawa 28-apr-2003 modified retrieval of end date via database as
       -- end date can now be changed even if workflow process is there for the trigger
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_TRIGGER_ID');

       AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => l_trigger_id,
         p_msg_data        => 'Action_Notification :  trigger in RUN mode' ,
         p_msg_type        => 'DEBUG'
        );

       OPEN  c_trig_notify(l_trigger_id);
       FETCH c_trig_notify INTO l_notify_flag;
       CLOSE c_trig_notify;

       AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => l_trigger_id,
         p_msg_data        => 'Action_Notification :  notification flag is ' ||l_notify_flag,
         p_msg_type        => 'DEBUG'
        );

       IF l_notify_flag = 'Y'
       THEN
         OPEN  c_notify_action_det(l_trigger_id);
         FETCH c_notify_action_det INTO l_notify_action_det;
         IF c_notify_action_det%FOUND
         THEN
             -- set notify user
             IF l_notify_action_det.action_for_id IS NOT NULL
             THEN
                Get_User_Role(p_user_id           => l_notify_action_det.action_for_id,
                             x_role_name         => l_notify,
                             x_role_display_name => l_display_name,
                             x_return_status     => l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

                WF_ENGINE.SetItemAttrText(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'AMS_TRIG_NOTIFTIER'
                             ,avalue   => l_notify);
                result := 'COMPLETE:Y' ;
             ELSE
                WF_ENGINE.SetItemAttrText(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'AMS_TRIG_NOTIFTIER'
                             ,avalue   => '');
                result := 'COMPLETE:N' ;
             END IF;

             AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Action_notification :  AMS_NOTIF_TO_USER_NAME = ' || l_notify || ', '||l_display_name,
               p_msg_type        => 'DEBUG'
              );

         END IF;
         CLOSE c_notify_action_det;
--cgoyal 26 May 03, fixed else condition
       ELSE
         result := 'COMPLETE:N' ;
       END IF;

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;
   -- dbms_output.put_line('End Trig_Type_Date :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'ACTION_NOTIFICATION',itemtype,itemkey,actid,funcmode);
        raise ;
END Action_Notification ;


-- Start of Comments
--
-- NAME
--   Action_Execute
--
-- PURPOSE
--   This Procedure will check whether the Trigger needs to send notification as one of its actions
--   It will Return - Yes  if the trigger needs to send notifications
--                  - No   Otherwise
--
-- IN
--    Itemtype - AMS_TRIG
--    Itemkey  - Trigger ID
--    Accid    - Activity ID
--    Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--             - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--      Activity  - AMS_ACTION_EX_CSCH
--
-- NOTES
--
--
-- HISTORY
--    28-apr-2003  soagrawa  Created
--
-- End of Comments

PROCEDURE Action_Execute    (itemtype    IN     VARCHAR2,
                             itemkey     IN     VARCHAR2,
                             actid       IN     NUMBER,
                             funcmode    IN     VARCHAR2,
                             result      OUT NOCOPY    VARCHAR2) IS

    l_exec_csch_flag    VARCHAR2(1);
    l_trigger_id        NUMBER;

    -- soagrawa 28-apr-2003 added this cursor to get end date of trigger
    CURSOR c_trig_exec_csch (p_trig_id NUMBER) IS
    SELECT execute_schedule_flag
    FROM   ams_triggers
    WHERE  trigger_id = p_trig_id;

BEGIN
   -- dbms_output.put_line('Process Trig_Type_Date');
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN')
   THEN

       -- soagrawa 28-apr-2003 modified retrieval of end date via database as
       -- end date can now be changed even if workflow process is there for the trigger
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                        itemtype    =>     itemtype,
                        itemkey     =>     itemkey ,
                        aname       =>    'AMS_TRIGGER_ID');

       OPEN  c_trig_exec_csch(l_trigger_id);
       FETCH c_trig_exec_csch INTO l_exec_csch_flag;
       CLOSE c_trig_exec_csch;

       IF l_exec_csch_flag = 'Y'
       THEN
          result := 'COMPLETE:Y' ;
       ELSE
          result := 'COMPLETE:N' ;
       END IF;
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;
   -- dbms_output.put_line('End Trig_Type_Date :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'ACTION_NOTIFICATION',itemtype,itemkey,actid,funcmode);
        raise ;
END Action_Execute ;


-- Start of Comments
--
-- NAME
--   Get_Aval_Repeat_Sch
--
-- PURPOSE
--   This Procedure will get the available/active repeat-execute schedules that are attached to
--   the given trigger. Schedule id, notify flag and require approveal flag
--   will be set based on the status_code, notify_user_id and approver_user_id,
--   respectively.
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--     Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:'
--
-- Used By Activities
--      Item Type - AMS_TRIG
--      Activity  - AMS_GENERATE_EXEC_CSCH
--
-- NOTES
--
--
-- HISTORY
--   28-apr-2003    soagrawa  Created
--   18-feb-2004    soagrawa  Fixed bug# 3452264
--   13-may-2004    soagrawa  Fixed bug# 3621786

-- End of Comments

PROCEDURE Get_Aval_Repeat_Sch(itemtype IN  VARCHAR2,
                              itemkey  IN  VARCHAR2,
                              actid    IN  NUMBER,
                              funcmode IN  VARCHAR2,
                              result   OUT NOCOPY VARCHAR2)
IS

  l_trigger_id    NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER ;
  l_msg_data      VARCHAR2(2000);
  l_item_key      VARCHAR2(30);
  l_approver      VARCHAR2(30);
  l_notify        VARCHAR2(30);
  l_owner         VARCHAR2(30);
  l_display_name  VARCHAR2(30);

  l_child_sched_st_date DATE;
  l_child_sched_start_date DATE;
  l_child_sched_end_date_time DATE;

   --cgoyal added on 6/may/03
  l_trigger_sched_date    DATE;
  l_trigger_end_date      DATE;
  l_new_sched_id          NUMBER := NULL;
  l_schedule_id           NUMBER;
  l_schedule_rec     AMS_Camp_Schedule_PVT.schedule_rec_type;
/*
   CURSOR c_sched_seq IS
   SELECT ams_campaign_schedules_s.NEXTVAL
   FROM   dual;
*/
   CURSOR c_sched_rec (l_sched_id IN NUMBER) IS
   SELECT *
   from   ams_campaign_schedules_vl
   where  schedule_id = l_sched_id;

   l_csch_rec         c_sched_rec%ROWTYPE;
   --end additions by cgoyal on 6/may/03

  CURSOR c_sch_det(p_schedule_id NUMBER) IS
    SELECT schedule_id, notify_user_id, approver_user_id, owner_user_id, schedule_name
    FROM ams_campaign_schedules_vl
    WHERE schedule_id = p_schedule_id;

    l_sch_det_rec    c_sch_det%ROWTYPE;

  CURSOR c_sch_all_det(l_trig_id NUMBER) IS
  select distinct nvl(orig_csch_id, schedule_id) AS id, count(*) AS total
  from ams_Campaign_schedules_b
  where trigger_id = l_trig_id
       and status_code = 'AVAILABLE'
       and trig_repeat_flag = 'Y'
  group by nvl(orig_csch_id, schedule_id);

  l_sch_all_det_rec c_sch_all_det%ROWTYPE;

  CURSOR c_max_sch_det(p_schedule_id NUMBER) IS
  select schedule_id
  from ams_campaign_schedules_b
  where creation_date = (select max(creation_date)
                              from ams_campaign_schedules_b
                             where nvl(orig_csch_id, schedule_id) = p_schedule_id);

--    18-feb-2004   soagrawa   Fixed bug# 3452264
  CURSOR c_orig_csch_name(p_Schedule_id NUMBER) IS
  select schedule_name
    from ams_Campaign_schedules_vl
   where schedule_id = ( select nvl(orig_csch_id, schedule_id)
                           From ams_campaign_Schedules_b
                           where schedule_id = p_schedule_id);

   l_new_cover_letter_id   NUMBER;
   l_ci_base_lang          VARCHAR2(4);
   l_ci_version            NUMBER;
   l_ci_obj_ver_num        NUMBER;
   l_ver_obj_ver_num       NUMBER;
   l_ci_id                 NUMBER;
   l_html_file_id          NUMBER;
   l_text_file_id          NUMBER;
   l_new_html_file_id      NUMBER;
   l_new_text_file_id      NUMBER;
   l_ci_ver_name_det       VARCHAR2(240);
   l_new_ci_ver_name_det   VARCHAR2(240);
   l_date_suffix           VARCHAR2(25);
   l_orig_schedule_name    VARCHAR2(240); --    18-feb-2004   soagrawa   Fixed bug# 3452264

   l_def_avail_status    NUMBER;
   l_def_new_status      NUMBER;

   l_file_name           VARCHAR2(256);
   l_file_content_type   VARCHAR2(256);
   l_file_data           BLOB;
   l_text_file_data      BLOB;
   l_html_file_data      BLOB;
   l_program_name        VARCHAR2(32);
   l_program_tag         VARCHAR2(32);
   l_file_format         VARCHAR2(10);
   l_file_language       VARCHAR2(4);
   l_file_charset        VARCHAR2(30);

   l_attribute_type_codes     JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100()   ;
   l_attribute_type_names     JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300()   ;
   l_attributes               JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000()  ;
   l_schedules_to_update      JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE()         ;


   CURSOR c_trigger_det (p_trigger_id NUMBER) IS
   SELECT repeat_frequency_type, repeat_every_x_frequency
     FROM ams_Triggers
    WHERE trigger_id = p_trigger_id;


    CURSOR c_camp_det   (p_campaign_id IN NUMBER) IS
       SELECT actual_exec_end_date
       FROM   ams_campaigns_all_b
       WHERE  campaign_id = p_campaign_id ;

   l_camp_end_dt       DATE;
   l_dummy             NUMBER;
   l_trig_freq_type    VARCHAR2(30);
   l_trig_freq_every_x NUMBER;
   l_repeat_check      VARCHAR2(30);
   l_csch_count        NUMBER := 1;
   l_failed            NUMBER := 0;
   l_query_id          VARcHAR2(30);
   l_query_id_num      NUMBER;

   l_return_log_status   VARCHAR2(1);

BEGIN
   IF (funcmode = 'RUN')
   THEN
        l_trigger_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey ,
                              aname    => 'AMS_TRIGGER_ID');

        AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_log_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => l_trigger_id,
         p_msg_data        => 'Get_Aval_Repeat_Sch :  1. Started '|| to_char(sysdate,'DD-MON-RRRR HH:MI:SS AM') ,
         p_msg_type        => 'DEBUG'
        );

        l_repeat_check  := WF_ENGINE.GetItemAttrText(itemtype    =>    itemtype,
                                                     itemkey      =>     itemkey ,
                                                     aname      =>    'AMS_REPEAT_FREQUENCY_TYPE'
                                                     );
        IF l_repeat_check  <> 'NONE' THEN

           --cgoyal - added following code on 06/may/03 for new instance creation for repeat schedules
           l_trigger_sched_date := WF_ENGINE.getItemAttrDate(itemtype  =>   itemtype,
                                                                itemkey   =>  itemkey ,
                                                                aname     =>   'AMS_TRIGGER_SCHEDULE_DATE') ;

           OPEN  c_trigger_det(l_trigger_id);
           FETCH c_trigger_det INTO l_trig_freq_type, l_trig_freq_every_x;
           CLOSE c_trigger_det;

       /*    IF l_trig_freq_type = 'DAILY' THEN
                l_trigger_sched_date := l_trigger_sched_date + l_trig_freq_every_x ;
           ELSIF l_trig_freq_type = 'WEEKLY' THEN
                l_trigger_sched_date := l_trigger_sched_date + (7 * l_trig_freq_every_x) ;
           ELSIF  l_trig_freq_type = 'MONTHLY' THEN
                l_trigger_sched_date := add_months(l_trigger_sched_date , l_trig_freq_every_x) ;
           ELSIF l_trig_freq_type = 'YEARLY' THEN
                l_trigger_sched_date := add_months(l_trigger_sched_date , (12*l_trig_freq_every_x)) ;
           ElSIF l_trig_freq_type = 'HOURLY' THEN
                l_trigger_sched_date := l_trigger_sched_date + (l_trig_freq_every_x/24) ;
           END IF;*/

           -- Start: anchaudh: commented out the above portion and instead calling api below.

           AMS_SCHEDULER_PVT.Schedule_Repeat( p_last_run_date => l_trigger_sched_date,
                                        p_frequency   =>    l_trig_freq_every_x,
                                        p_frequency_type  => l_trig_freq_type,
                                        x_next_run_date     => l_child_sched_start_date,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data);

           IF l_return_status <> FND_API.g_ret_sts_success THEN
               l_failed := l_failed + 1;
               result := 'COMPLETE:ERROR';
           END IF;

           l_trigger_sched_date := l_child_sched_start_date;

          -- End: anchaudh: commented out the above portion and instead calling api below.


           l_trigger_end_date := WF_ENGINE.getItemAttrDate(itemtype  =>   itemtype,
                                                           itemkey   =>  itemkey ,
                                                           aname     =>   'AMS_TRIGGER_REPEAT_END_DATE');

           AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_log_status,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => l_trigger_id,
            p_msg_data        => 'Get_Aval_Repeat_Sch : Trigger Sched Date is '|| to_char(l_trigger_sched_date,'DD-MON-RRRR HH:MI:SS AM') || 'Trigger End Date is '|| to_char(l_trigger_end_date,'DD-MON-RRRR HH:MI:SS AM'),
            p_msg_type        => 'DEBUG'
           );

        END IF;

        FOR l_sch_all_det_rec IN c_sch_all_det(l_trigger_id)
        LOOP
      -- pick the latest available one
              OPEN  c_max_sch_det(l_sch_all_det_rec.id);
              FETCH c_max_sch_det INTO l_schedule_id;
              CLOSE c_max_sch_det;

              OPEN c_sch_det(l_schedule_id);
              FETCH c_sch_det INTO l_sch_det_rec;
              CLOSE c_sch_det;

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  2.Processing for schedule_id '|| l_sch_det_rec.schedule_id,
               p_msg_type        => 'DEBUG'
              );

               l_item_key := l_sch_det_rec.schedule_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  3.detail itemkey: '|| l_item_key,
               p_msg_type        => 'DEBUG'
              );

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  4.Creating Process',
               p_msg_type        => 'DEBUG'
              );

             WF_ENGINE.CreateProcess (itemtype => itemtype, --itemtype,
                                       itemkey  => l_item_key ,
                                       user_key => l_sch_det_rec.schedule_name,
                                       process  => 'AMS_EXEC_ATTCH_SCH'); -- name of the process

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  5.Created Process',
               p_msg_type        => 'DEBUG'
              );

             -- set schedule owner
             Get_User_Role(p_user_id           => l_sch_det_rec.owner_user_id,
                           x_role_name         => l_owner,
                           x_role_display_name => l_display_name,
                           x_return_status     => l_return_status);
             IF l_return_status <> FND_API.g_ret_sts_success THEN
                result := 'COMPLETE:ERROR';
                RETURN;
             END IF;

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  Setting WF Engine params',
               p_msg_type        => 'DEBUG'
              );
             WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                      ,itemkey  => l_item_key
                                      ,aname    => 'AMS_SCHEDULE_OWNER'
                                      ,avalue   => l_owner);

             WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                      ,itemkey  => l_item_key
                                      ,aname    => 'AMS_REQUESTOR_USERNAME'
                                      ,avalue   => l_owner);


             -- set schedule id
             WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                        itemkey  => l_item_key,
                                       aname    => 'AMS_SCHEDULE_ID',
                                       avalue   => l_sch_det_rec.schedule_id);

             -- set schedule name
             WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                       itemkey  => l_item_key,
                                       aname    => 'AMS_SCHEDULE_NAME',
                                       avalue   => l_sch_det_rec.schedule_name);

             -- set notify user
             IF l_sch_det_rec.notify_user_id IS NOT NULL
             THEN
                Get_User_Role(p_user_id           => l_sch_det_rec.notify_user_id,
                             x_role_name         => l_notify,
                             x_role_display_name => l_display_name,
                             x_return_status     => l_return_status);
                IF l_return_status <> FND_API.g_ret_sts_success THEN
                   result := 'COMPLETE:ERROR';
                   RETURN;
                END IF;

                WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                        ,itemkey  => l_item_key
                                        ,aname    => 'AMS_NOTIF_TO_USER_NAME'
                                        ,avalue   => l_notify);
             ELSE
                WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                          itemkey  => l_item_key,
                                          aname    => 'AMS_NOTIF_TO_USER_NAME',
                                          avalue   => '' );
             END IF;

             -- set approver
             IF l_sch_det_rec.approver_user_id IS NOT NULL
             THEN
                Get_User_Role(p_user_id           => l_sch_det_rec.approver_user_id,
                             x_role_name         => l_approver,
                             x_role_display_name => l_display_name,
                             x_return_status     => l_return_status);
                IF l_return_status <> FND_API.g_ret_sts_success THEN
                   result := 'COMPLETE:ERROR';
                   RETURN;
                END IF;

                WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                        ,itemkey  => l_item_key
                                        ,aname    => 'AMS_APPROVER_NAME'
                                        ,avalue   => l_approver);
             ELSE
                WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                          itemkey  => l_item_key,
                                          aname    => 'AMS_APPROVER_NAME',
                                          avalue   => '' );
             END IF;

             -- soagrawa added setting all the other values...
             WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype ,
                                       itemkey     =>  l_item_key,
                                       aname       =>  'AMS_TRIGGER_ID',
                                       avalue      =>  WF_ENGINE.getItemAttrText(itemtype  => itemtype,
                                                                                 itemkey   => itemkey ,
                                                                                 aname     => 'AMS_TRIGGER_ID')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname    =>     'AMS_TRIGGER_NAME',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_TRIGGER_NAME')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname    =>     'AMS_TRIGGER_SCHEDULE_DATE',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_TRIGGER_SCHEDULE_DATE')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname    =>     'AMS_TRIGGER_DATE',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_TRIGGER_DATE')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname    =>     'AMS_REPEAT_FREQUENCY_TYPE',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_REPEAT_FREQUENCY_TYPE')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname    =>     'AMS_TRIGGER_REPEAT_END_DATE',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_TRIGGER_REPEAT_END_DATE')  );

             WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                       itemkey     =>   l_item_key,
                                       aname        =>     'AMS_CAMPAIGN_NAME',
                                       avalue    =>     WF_ENGINE.getItemAttrText(itemtype  =>   itemtype,
                                                                                  itemkey   =>  itemkey ,
                                                                                  aname     =>   'AMS_CAMPAIGN_NAME')  );

         --    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
         --                         itemkey     =>   l_item_key,
         --                        aname    =>     'AMS_CHK_MET_MSG',
         --                        avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
         --                                                                   itemkey     =>  itemkey ,
         --                                                                   aname     =>   'AMS_CHK_MET_MSG')  );


         --    WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
         --                            itemkey     =>   l_item_key,
         --                            aname        =>     'AMS_NTF_MESSAGE',
         --                            avalue    =>     WF_ENGINE.getItemAttrText(itemtype   =>   itemtype,
         --                                                                   itemkey     =>  itemkey ,
         --                                                                   aname     =>   'AMS_NTF_MESSAGE')  );

            -- end soagrawa setting values

              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  6.Finished setting all params',
               p_msg_type        => 'DEBUG'
              );


             -- set the parent process
             WF_ENGINE.SetItemParent(itemtype        => itemtype
                                    ,itemkey         => l_item_key
                                    ,parent_itemtype => itemtype
                                    ,parent_itemkey  => itemkey
                                    ,parent_context  => NULL
                                    );

             WF_ENGINE.StartProcess (itemtype => itemtype,
                                     itemkey  => l_item_key);


              AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_log_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Get_Aval_Repeat_Sch :  7.Started Process',
               p_msg_type        => 'DEBUG'
              );


              IF (l_trigger_sched_date < l_trigger_end_date) THEN

                        AMS_Utility_PVT.Create_Log (
                           x_return_status   => l_return_log_status,
                           p_arc_log_used_by => 'TRIG',
                           p_log_used_by_id  => l_trigger_id,
                           p_msg_data        => 'Get_Aval_Repeat_Sch :  8.Yes gotta create new csch',
                           p_msg_type        => 'DEBUG'
                          );

                        open c_sched_rec(l_sch_det_rec.schedule_id);
                        FETCH c_sched_rec INTO l_csch_rec;
                        CLOSE c_sched_rec;

                        /*   l_schedule_rec.schedule_id := FND_API.G_MISS_NUM;
                        l_schedule_rec.campaign_id := l_csch_rec.campaign_id;

                        l_schedule_rec.use_parent_code_flag := l_csch_rec.use_parent_code_flag;
                        l_schedule_rec.source_code := null;      */


                        -- set start and end dates
                        /* IF l_trig_freq_type = 'DAILY' THEN
                             l_schedule_rec.start_date_time := l_csch_rec.start_date_time + l_trig_freq_every_x ;
                        ELSIF l_trig_freq_type = 'WEEKLY' THEN
                             l_schedule_rec.start_date_time := l_csch_rec.start_date_time + (7 * l_trig_freq_every_x) ;
                        ELSIF  l_trig_freq_type = 'MONTHLY' THEN
                             l_schedule_rec.start_date_time := add_months(l_csch_rec.start_date_time , l_trig_freq_every_x) ;
                        ELSIF l_trig_freq_type = 'YEARLY' THEN
                             l_schedule_rec.start_date_time := add_months(l_csch_rec.start_date_time , (12*l_trig_freq_every_x)) ;
                        ElSIF l_trig_freq_type = 'HOURLY' THEN
                             l_schedule_rec.start_date_time := l_csch_rec.start_date_time + (l_trig_freq_every_x/24) ;
                        END IF;*/

                        -- Start: anchaudh:15 Oct'03: Calling central api directly to get the start date of the child schedule.

                        AMS_SCHEDULER_PVT.Schedule_Repeat( p_last_run_date => l_csch_rec.start_date_time ,
                                        p_frequency   =>    l_trig_freq_every_x,
                                        p_frequency_type  => l_trig_freq_type,
                                        x_next_run_date     => l_child_sched_st_date,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data);

                        IF l_return_status <> FND_API.g_ret_sts_success THEN
                             l_failed := l_failed + 1;
                             result := 'COMPLETE:ERROR';
                        END IF;

                        -- End: anchaudh:15 Oct'03: Calling central api directly to get the start date of the child schedule.


                        --cgoyal fixed bug#3063816
                        OPEN  c_camp_det(l_csch_rec.campaign_id);
                        FETCH c_camp_det INTO l_camp_end_dt; -- campaign's end date
                        CLOSE c_camp_det;

                        AMS_Utility_PVT.Create_Log (
                           x_return_status   => l_return_log_status,
                           p_arc_log_used_by => 'TRIG',
                           p_log_used_by_id  => l_trigger_id,
                           p_msg_data        => 'l_csch_rec.campaign_id = ' || l_csch_rec.campaign_id || ' l_camp_end_dt = ' || l_camp_end_dt,
                           p_msg_type        => 'DEBUG'
                          );

                        --   IF (l_schedule_rec.start_date_time <= l_camp_end_dt) THEN
                     IF (l_child_sched_st_date <= l_camp_end_dt) THEN
                        -- end fix#3063816 by cgoyal

                        IF l_csch_rec.end_date_time IS null THEN
                              --  l_schedule_rec.end_date_time := null;
                              l_child_sched_end_date_time := null;
                        ELSE
                              l_child_sched_end_date_time := l_child_sched_st_date + (l_csch_rec.end_date_time - l_csch_rec.start_date_time);

                              AMS_Utility_PVT.Create_Log (
                              x_return_status   => l_return_log_status,
                              p_arc_log_used_by => 'TRIG',
                              p_log_used_by_id  => l_trigger_id,
                              p_msg_data        => 'l_csch_rec.schedule_id = ' || l_csch_rec.schedule_id || ' l_camp_end_dt = ' || l_camp_end_dt || 'l_csch_rec.orig_csch_id = ' || l_csch_rec.orig_csch_id ,
                              p_msg_type        => 'DEBUG'
                              );

                             IF l_child_sched_end_date_time > l_camp_end_dt
                             THEN
                               l_child_sched_end_date_time := l_camp_end_dt;
                             END IF;
                        END IF;
                        -- end fix#3063816 by cgoyal

                        -- soagrawa added on 18-feb-2004 for bug# 3452264
                        OPEN  c_orig_csch_name(l_csch_rec.schedule_id);
                        FETCH c_orig_csch_name INTO l_orig_schedule_name;
                        CLOSE c_orig_csch_name;

                        AMS_Utility_PVT.Create_Log (
                           x_return_status   => l_return_log_status,
                           p_arc_log_used_by => 'TRIG',
                           p_log_used_by_id  => l_trigger_id,
                           p_msg_data        => 'l_csch_rec.schedule_id used for getting ORIG CSCH NAME is '||l_csch_rec.schedule_id,
                           p_msg_type        => 'DEBUG'
                          );

                        AMS_Utility_PVT.Create_Log (
                           x_return_status   => l_return_log_status,
                           p_arc_log_used_by => 'TRIG',
                           p_log_used_by_id  => l_trigger_id,
                           p_msg_data        => 'ORIG CSCH NAME is '||l_orig_schedule_name,
                           p_msg_type        => 'DEBUG'
                          );

                        -- Start: anchaudh:15 Oct'03: Calling central api directly to create the schedule and copy its various components.
                        -- soagrawa modified on 13-may-2004 to fix bug# 3621786
                        AMS_SCHEDULER_PVT.Create_Next_Schedule( p_parent_sched_id  => nvl(l_csch_rec.orig_csch_id,l_csch_rec.schedule_id),
                        -- AMS_SCHEDULER_PVT.Create_Next_Schedule( p_parent_sched_id  => l_csch_rec.schedule_id,
                                                                   p_child_sched_st_date  =>  l_child_sched_st_date,
                                                                   p_child_sched_en_date  =>  l_child_sched_end_date_time,
                                                                   x_child_sched_id     => l_new_sched_id,
                                                                   -- soagrawa added on 18-feb-2004 for bug# 3452264
                                                                   p_orig_sch_name      => l_orig_schedule_name,
                                                                   p_trig_repeat_flag   => 'Y',
                                                                   x_msg_count              => l_msg_count,
                                                                   x_msg_data      => l_msg_data,
                                                                   x_return_status => l_return_status
                                                                   );

                        IF l_return_status <> FND_API.g_ret_sts_success THEN
                            l_failed := l_failed + 1;
                            result := 'COMPLETE:ERROR';
                            AMS_Utility_PVT.Create_Log (
                                    x_return_status   => l_return_log_status,
                                    p_arc_log_used_by => 'TRIG',
                                    p_log_used_by_id  => l_trigger_id,
                                    p_msg_data        => 'Get_Aval_Repeat_Sch : 9.After AMS_SCHEDULER_PVT.Create_Next_Schedule call'||l_return_status,
                                    p_msg_type        => 'DEBUG'
                                   );
                        END IF;
                       -- End: anchaudh:15 Oct'03: Calling central api directly to create the schedule and copy its various components.

                    --fix#3063816 by cgoyal
                     END IF;
                    --end fix#3063816 by cgoyal
              END IF;
        END LOOP;

         AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_log_status,
                  p_arc_log_used_by => 'TRIG',
                  p_log_used_by_id  => l_trigger_id,
                  p_msg_data        => 'Get_Aval_Repeat_Sch : Loop ends',
                  p_msg_type        => 'DEBUG' );


         IF l_failed > 0
         THEN
            result := 'COMPLETE:ERROR';
         ELSE
            result := 'COMPLETE:SUCCESS';
         END IF;


      RETURN;
   END IF; -- if funcmode is run

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

END Get_Aval_Repeat_Sch;


-- Start of Comments
--
-- NAME
--   Event_Custom_action
--
-- PURPOSE
--   This Procedure will check whether the Trigger is Active or Expired
--   It will Return - Yes  if the trigger is Active
--                 - No If the trigger is Expired
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--            - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_CHECK_TRIGGER_STATUS
--
-- NOTES
--
--
-- HISTORY
--    07-may-2003   soagrawa  Added to programatically raise a WF event for custom action
--
-- End of Comments

PROCEDURE Event_Custom_action    (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS

    l_trigger_id             NUMBER;
    l_parameter_list         WF_PARAMETER_LIST_T;

BEGIN
   IF (funcmode = 'RUN')
   THEN
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_TRIGGER_ID');

       l_parameter_list := WF_PARAMETER_LIST_T();

       wf_event.AddParameterToList(p_name => 'AMS_TRIGGER_ID',
                                   p_value => l_trigger_id,
                                   p_parameterlist => l_parameter_list);


       Wf_Event.Raise
         ( p_event_name   =>  'oracle.apps.ams.trigger.TriggerCustomActionEvent',
           p_event_key    =>  l_trigger_id || 'CUST' || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS'),
           p_parameters   =>  l_parameter_list
         );
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Event_Custom_action',itemtype,itemkey,actid,funcmode);
        raise ;
END Event_Custom_action ;


-- Start of Comments
--
-- NAME
--   Event_Custom_action
--
-- PURPOSE
--   This Procedure will check whether the Trigger is Active or Expired
--   It will Return - Yes  if the trigger is Active
--                 - No If the trigger is Expired
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--            - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_CHECK_TRIGGER_STATUS
--
-- NOTES
--
--
-- HISTORY
--    07-may-2003   soagrawa  Added to programatically raise a WF event for custom action
--
-- End of Comments

PROCEDURE Event_trig_next(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS

    l_trigger_id             NUMBER;
    l_parameter_list         WF_PARAMETER_LIST_T;
    l_sch_date               DATE;
    l_sch_text               VARCHAR2(100);
    l_new_item_key           VARCHAR2(30);

BEGIN
   IF (funcmode = 'RUN')
   THEN
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_TRIGGER_ID');

       l_parameter_list := WF_PARAMETER_LIST_T();

       wf_event.AddParameterToList(p_name => 'AMS_TRIGGER_ID',
                                   p_value => l_trigger_id,
                                   p_parameterlist => l_parameter_list);

       l_sch_date := WF_ENGINE.GetItemAttrDate(itemtype  =>    itemtype,
                                   itemkey   =>    itemkey ,
                                   aname     =>    'AMS_TRIGGER_SCHEDULE_DATE'
                                   );

       l_new_item_key := l_trigger_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

       Wf_Event.Raise
         ( p_event_name   =>  'oracle.apps.ams.trigger.TriggerEvent',
           p_event_key    =>  l_new_item_key,
           p_parameters   =>  l_parameter_list,
           p_send_date    => l_sch_date
         );

       UPDATE ams_triggers
          SET process_id = to_number(l_new_item_key)
        WHERE trigger_id = l_trigger_id;

   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Event_trig_next',itemtype,itemkey,actid,funcmode);
        raise ;
END Event_trig_next ;


-- Start of Comments
--
-- NAME
--   Wf_Init_var
--
-- PURPOSE
--   This Procedure will check whether the Trigger is Active or Expired
--   It will Return - Yes  if the trigger is Active
--                 - No If the trigger is Expired
--
-- IN
--    Itemtype - AMS_TRIG
--     Itemkey  - Trigger ID
--     Accid    - Activity ID
--      Funmode  - Run/Cancel/Timeout
--
-- OUT
--      Result - 'COMPLETE:Y' If the trigger is Active
--            - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
--      Item Type - AMS_TRIG
--     Activity  - AMS_CHECK_TRIGGER_STATUS
--
-- NOTES
--
--
-- HISTORY
--    07-may-2003   soagrawa  Added to programatically raise a WF event for custom action
--    09 Nov-2004   anchaudh   Fixed setting of WF owner for triggers WF
--    26 aug-2005   soagrawa  Modified to add flexibility around initiative being monitored for R12
-- End of Comments

PROCEDURE Wf_Init_var(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS

     l_trigger_id             NUMBER;
     l_username            VARCHAR2(100);
     l_approver_username   VARCHAR2(100);
     l_list_name           VARCHAR2(240);
     l_timeout_days        NUMBER       ;
     l_priority            NUMBER       ;

     l_emp_id NUMBER;
     l_user_name VARCHAR2(100);
     l_disp_name VARCHAR2(100);

     -- anchaudh defining cursor for setting item owner along with bug fix for bug# 3799053
     CURSOR c_emp_dtl(l_res_id IN NUMBER) IS
      SELECT employee_id
      FROM   ams_jtf_rs_emp_v
      WHERE  resource_id = l_res_id ;

     CURSOR c_trig_det IS
       SELECT *
       -- modified by soagrawa
       -- FROM   ams_triggers
       FROM   ams_triggers_vl
       WHERE  trigger_id = l_trigger_id ;
     l_trig_rec      c_trig_det%ROWTYPE;

     CURSOR c_check_det IS
       SELECT *
       FROM   ams_trigger_checks
       WHERE  trigger_id = l_trigger_id ;
     l_check_rec     c_check_det%ROWTYPE;

     CURSOR c_notify_action_det IS
       SELECT *
       FROM   ams_trigger_actions
       WHERE  trigger_id = l_trigger_id
       AND    execute_action_type = 'NOTIFY';
     l_notify_action_det    c_notify_action_det%ROWTYPE;

     -- The Campaign_owner Username has tobe selected from jtf_resource_extn_vl
     -- Has to be changed once the view is modified
  CURSOR c_camp_det   IS
    SELECT campaign_name, priority, owner_user_id
    FROM   ams_campaigns_vl
    WHERE  campaign_id = l_trig_rec.trigger_created_for_id ;

  CURSOR c_csch_det   IS
    SELECT schedule_name, priority, owner_user_id
    FROM   ams_campaign_schedules_vl
    WHERE  schedule_id = l_trig_rec.trigger_created_for_id ;

  CURSOR c_eveo_eone_det   IS
    SELECT event_offer_name, 'STANDARD', owner_user_id
    FROM   ams_event_offers_vl
    WHERE  event_offer_id = l_trig_rec.trigger_created_for_id ;

  CURSOR c_eveh_det   IS
    SELECT event_header_name, 'STANDARD', owner_user_id
    FROM   ams_event_headers_vl
    WHERE  event_header_id = l_trig_rec.trigger_created_for_id ;

   l_monitor_obj_name        VARCHAR2(240);
   l_monitor_obj_priority    VARCHAR2(30);
   l_monitor_obj_owner       NUMBER;

     -- Cursor to get metric details if the trigger is created for Metric
     CURSOR c_metric_det(l_metric_id NUMBER) IS
       SELECT met.metrics_name metrics_name,act.act_metric_used_by_id metric_used_by_id,
              act.arc_act_metric_used_by metric_used_by
       FROM   ams_metrics_vl met,ams_act_metrics_all act
       WHERE  met.metric_id = act.metric_id
       AND    act.activity_metric_id = l_metric_id ;
     l_metric_rec    c_metric_det%ROWTYPE;

     CURSOR c_timeout_det IS
     SELECT   timeout_days_low_prio,
              timeout_days_std_prio,
              timeout_days_high_prio,
              timeout_days_medium_prio
     FROM     ams_approval_rules
     WHERE    arc_approval_for_object = l_trig_rec.arc_trigger_created_for;
     l_timeout_rec   c_timeout_det%ROWTYPE;

     l_display_name  VARCHAR2(100);
     l_return_status VARCHAR2(1);
     l_notify        VARCHAR2(30);

BEGIN
   IF (funcmode = 'RUN')
   THEN

       l_trigger_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_TRIGGER_ID');

       AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => l_trigger_id,
            p_msg_data        => 'WF_INIT_VAR: started',
            p_msg_type        => 'DEBUG'
            );

/*
       UPDATE  ams_triggers
       SET     process_id = TO_NUMBER(itemkey)
       WHERE   trigger_id = l_trigger_id ;
*/
       OPEN  c_trig_det;
       FETCH c_trig_det INTO l_trig_rec ;
       CLOSE c_trig_det;

        -- soagrawa modified logic for R12
        IF l_trig_rec.arc_trigger_Created_for in ('CAMP','RCAM')
	THEN
		OPEN  c_camp_det;
		FETCH c_camp_det INTO l_monitor_obj_name, l_monitor_obj_priority, l_monitor_obj_owner ;
		CLOSE c_camp_det;
	ELSIF l_trig_rec.arc_trigger_Created_for in ('CSCH')
	THEN
		OPEN  c_csch_det;
		FETCH c_csch_det INTO l_monitor_obj_name, l_monitor_obj_priority, l_monitor_obj_owner ;
		CLOSE c_csch_det;
	ELSIF l_trig_rec.arc_trigger_Created_for in ('EVEH')
	THEN
		OPEN  c_eveh_det;
		FETCH c_eveh_det INTO l_monitor_obj_name, l_monitor_obj_priority, l_monitor_obj_owner ;
		CLOSE c_eveh_det;
	ELSIF l_trig_rec.arc_trigger_Created_for in ('EONE','EVEO')
	THEN
		OPEN  c_eveo_eone_det;
		FETCH c_eveo_eone_det INTO l_monitor_obj_name, l_monitor_obj_priority, l_monitor_obj_owner ;
		CLOSE c_eveo_eone_det;
        END IF;


       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_CAMPAIGN_NAME',
                           avalue    =>     l_monitor_obj_name  );

        -- end soagrawa


       OPEN c_emp_dtl(l_monitor_obj_owner);
       FETCH c_emp_dtl INTO l_emp_id;
         -- anchaudh setting item owner along with bug fix for bug# 3799053
         IF c_emp_dtl%FOUND
         THEN
            WF_DIRECTORY.getrolename
                 ( p_orig_system      => 'PER',
                   p_orig_system_id   => l_emp_id ,
                   p_name             => l_user_name,
                   p_display_name     => l_disp_name );

            IF l_user_name IS NOT NULL THEN
               Wf_Engine.SetItemOwner(itemtype    => itemtype,
                                itemkey     => itemkey,
                                owner       => l_user_name);
            END IF;
         END IF;
      CLOSE c_emp_dtl;

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_TRIGGER_NAME',
                           avalue    =>     l_trig_rec.trigger_name  );

       WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                                itemkey     =>   itemkey ,
                                userkey     =>   l_trig_rec.trigger_name);

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_TRIGGER_SCHEDULE_DATE',
                           avalue    =>     to_char(l_trig_rec.start_date_time,'DD-MON-RRRR HH:MI:SS AM')  );

       -- soagrawa set this value as other the first time around it would be empty
       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_TRIGGER_DATE',
                           avalue    =>     to_char(l_trig_rec.start_date_time,'DD-MON-RRRR HH:MI:SS AM')  );

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_REPEAT_FREQUENCY_TYPE',
                           avalue    =>     l_trig_rec.repeat_frequency_type  );

       WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname    =>     'AMS_TRIGGER_REPEAT_END_DATE',
                           avalue    =>     to_char(l_trig_rec.repeat_stop_date_time,'DD-MON-RRRR HH:MI:SS AM')  );

       IF l_trig_rec.notify_flag = 'Y'
       THEN
         OPEN  c_notify_action_det;
         FETCH c_notify_action_det INTO l_notify_action_det;
         IF c_notify_action_det%FOUND
         THEN
             -- set notify user
             IF l_notify_action_det.action_for_id IS NOT NULL
             THEN
                Get_User_Role(p_user_id           => l_notify_action_det.action_for_id,
                             x_role_name         => l_notify,
                             x_role_display_name => l_display_name,
                             x_return_status     => l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                     itemkey     =>   itemkey,
                                    aname    =>     'AMS_TRIG_NOTIFTIER',
                                    avalue    =>     l_notify);
             ELSE
                WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                     itemkey     =>   itemkey,
                                    aname    =>     'AMS_TRIG_NOTIFTIER',
                                    avalue    =>     '');
             END IF;
         END IF;
         CLOSE c_notify_action_det;

       END IF;


       -- Fetch the username of the Owner of Trigger (Campaign Owner)
       Find_Owner  (p_activity_id             => l_trig_rec.trigger_created_for_id,
                    p_activity_type           => l_trig_rec.arc_trigger_created_for,
                    x_owner_user_name         => l_username
                   );

        WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname        =>     'AMS_REQUESTOR_USERNAME',
                           avalue    =>     l_username  );

       -- Initialize Check Attributes
       OPEN  c_check_det;
       FETCH c_check_det INTO l_check_rec;
       IF (c_check_det%FOUND)
       THEN
          OPEN  c_metric_det(l_check_rec.chk1_source_code_metric_id);
          FETCH c_metric_det INTO l_metric_rec ;
          CLOSE c_metric_det;

          WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                                 itemkey     =>   itemkey,
                               aname    =>     'AMS_OPERATOR',
                               avalue    =>     l_check_rec.chk1_to_chk2_operator_type);
       END IF;
       CLOSE c_check_det;

       OPEN  c_timeout_det;
       FETCH c_timeout_det INTO l_timeout_rec ;
       CLOSE c_timeout_det ;

         IF    l_monitor_obj_priority = 'STANDARD' THEN
            l_timeout_days := l_timeout_rec.timeout_days_std_prio ;
            l_priority := 50 ; -- Standard
         ELSIF l_monitor_obj_priority = 'LOW' THEN
            l_timeout_days := l_timeout_rec.timeout_days_low_prio ;
            l_priority := 99 ; -- Low
         ELSIF l_monitor_obj_priority = 'HIGH' THEN
            l_timeout_days := l_timeout_rec.timeout_days_high_prio ;
            l_priority := 1 ; -- High
         ELSIF l_monitor_obj_priority = 'MEDIUM' THEN
            l_timeout_days := l_timeout_rec.timeout_days_medium_prio ;
            l_priority := 50 ; -- standard
	 ELSE
            l_timeout_days := l_timeout_rec.timeout_days_medium_prio ;
            l_priority := 50 ; -- standard
         END IF;


         WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                               itemkey     =>   itemkey,
                             aname    =>     'AMS_TIMEOUT',
                             avalue    =>     l_timeout_days    );


   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Wf_Init_var',itemtype,itemkey,actid,funcmode);
        raise ;
END Wf_Init_var ;


-- Start of Comments
--
-- NAME
--   Check_Trig_Exist
--
-- PURPOSE
--   This Procedure will check whether the Trigger id exists or not
--   It will Return - Yes  if the trigger does exist
--                 - No If the trigger does not exist
--
-- HISTORY
--    16-may-2003   soagrawa  Created to support delete trigger
--
-- End of Comments

PROCEDURE Check_Trig_Exist        (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS

    l_trigger_id             NUMBER;
    l_dummy                  NUMBER;
    l_return_status          VARCHAR2(1);
    CURSOR c_trig_exist_det(p_trig_id NUMBER) IS
    SELECT 1
    FROM   ams_triggers
    WHERE  trigger_id = p_trig_id;

BEGIN
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
       l_trigger_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'AMS_TRIGGER_ID');

       OPEN  c_trig_exist_det(l_trigger_id);
       FETCH c_trig_exist_det INTO l_dummy;
       CLOSE c_trig_exist_det;

       IF l_dummy IS NULL THEN
             result := 'COMPLETE:N' ;
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'TRIG',
                     p_log_used_by_id  => l_trigger_id,
                     p_msg_data        => 'Check_Trig_Exist :  1. For Trigger ID = ' || itemkey || result,
                     p_msg_type        => 'DEBUG'
                     );
             RETURN;
       ELSE
             result := 'COMPLETE:Y' ;
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'TRIG',
                     p_log_used_by_id  => l_trigger_id,
                     p_msg_data        => 'Check_Trig_Exist :  1. For Trigger ID = ' || itemkey  || result,
                     p_msg_type        => 'DEBUG'
                     );
             RETURN;
       END IF;
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT')
   THEN
      result := 'COMPLETE:' ;
      RETURN;
   END IF;
   -- dbms_output.put_line('End Check Trigger stat :'||result);
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'Check_Trig_Exist',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Trig_Exist ;


--========================================================================
-- PROCEDURE
--    write_msg
-- Purpose
--    API to write concurrent program debugs
-- HISTORY
--    20-Aug-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE write_msg(p_procedure IN VARCHAR2, p_message IN VARCHAR2)
IS
BEGIN
    Ams_Utility_Pvt.Write_Conc_Log(TO_CHAR(DBMS_UTILITY.get_time)||': '||
            G_PKG_NAME||'.'||p_procedure||': '||p_message);
END;


--========================================================================
-- PROCEDURE
--    write_error
-- Purpose
--    API to write concurrent program error logs
-- HISTORY
--    20-Aug-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE write_error(p_procedure IN varchar2)
IS
   l_msg varchar2(4000);
BEGIN
   LOOP
      l_msg := fnd_msg_pub.get(p_encoded => FND_API.G_FALSE);
      EXIT WHEN l_msg IS NULL;
      write_msg(p_procedure, 'ERROR: '||l_msg);
   END LOOP;
END;


--========================================================================
-- PROCEDURE
--    purge_history
-- Purpose
--    Purges monitor history. Called by Concurrent Program.
-- HISTORY
--    20-Aug-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE purge_history(
                errbuf             OUT NOCOPY    VARCHAR2,
                retcode            OUT NOCOPY    NUMBER,
                trig_end_date_days IN     NUMBER := 60
) IS

BEGIN
   FND_MSG_PUB.initialize;

   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('purge_history','Starting to purge Monitor history...');
     write_msg('purge_history','History for all triggers that have ended more than '||trig_end_date_days||' days is being deleted...');
   END IF;

   Delete from ams_trigger_results
   where trigger_result_for_id in
   		   (SELECT  trigger_id
		   FROM ams_triggers
		   WHERE (repeat_stop_date_time + trig_end_date_days) < sysdate);

   retcode :=0;

   IF AMS_DEBUG_HIGH_ON THEN
     write_msg('purge_history','Done deleting Monitor History with status : '||TO_CHAR(retcode));
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      retcode  := 2;
      write_msg('purge_history','Done deleting Monitor History with status : '||TO_CHAR(retcode));

END	purge_history ;




END AMS_WFTrig_PVT ;

/
