--------------------------------------------------------
--  DDL for Package Body AMS_LIST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_WF" AS
/* $Header: amsvwlib.pls 120.4 2006/08/01 05:20:08 bmuthukr ship $*/

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_LIST_WF ';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvwlib.pls';

-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
-- End of Comments

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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

PROCEDURE Handle_Err
   (p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    x_error_msg                OUT NOCOPY VARCHAR2
   )
IS
   l_msg_count            NUMBER ;
   l_msg_data             VARCHAR2(2000);
   l_final_data           VARCHAR2(4000);
   l_msg_index            NUMBER ;
   l_cnt                  NUMBER := 0 ;
BEGIN
   -- Retriveing Error Message from FND_MSG_PUB
   -- Called by most of the procedures if it encounter error
   WHILE l_cnt < p_msg_count
   LOOP
      FND_MSG_PUB.Get
        (p_msg_index       => l_cnt + 1,
         p_encoded         => FND_API.G_FALSE,
         p_data            => l_msg_data,
         p_msg_index_out   => l_msg_index )       ;
      l_final_data := l_final_data ||l_msg_index||': '
          ||l_msg_data||fnd_global.local_chr(10) ;
      l_cnt := l_cnt + 1 ;
   END LOOP ;
   x_error_msg   := l_final_data;
END Handle_Err;


PROCEDURE StartProcess
                   ( p_list_header_id        IN      NUMBER
                     --,workflowprocess        IN    VARCHAR2 DEFAULT NULL)  IS
                     ,workflowprocess        IN      VARCHAR2 )  IS
     itemtype     VARCHAR2(30) := 'AMSLISTG';
     itemkey      VARCHAR2(30) ;
     itemuserkey VARCHAR2(80) ;

     l_clistheader_rec AMS_ListHeader_PVT.list_header_rec_type;
     l_listheader_rec  AMS_ListHeader_PVT.list_header_rec_type;
     l_display_name    varchar2(360);
     l_requester_role  varchar2(360);
     l_return_status   varchar2(1);

  --bmuthukr changes for bug 3895455.
  l_user_id    NUMBER;
  cursor c1(l_last_updated_by number) is
  select jtf.resource_id
    from jtf_rs_resource_extns jtf
   where jtf.user_id = l_last_updated_by;
   --

BEGIN
     -- Start Process :
     --  If workflowprocess is passed, it will be run.
     --  If workflowprocess is NOT passed, the selector function
     --  defined in the item type will determine which process to run.
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Start');
     END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Item Type : '||itemtype);
     END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Item key : '||itemkey);
     END IF;

     --dbms_output.put_line('Start');
     AMS_ListHeader_PVT.Init_listheader_rec(l_listheader_rec );
     l_listheader_rec.list_header_id  := p_list_header_id;

     AMS_ListHeader_PVT.Complete_ListHeader_rec(
        p_listheader_rec  => l_listheader_rec,
        x_complete_rec    => l_clistheader_rec
     ) ;
     update ams_list_headers_all
     set object_version_number = object_version_number + 1
     where list_header_id = p_list_header_id;

     --dbms_output.put_line('list->' || l_clistheader_rec.list_header_id);
     --dbms_output.put_line('listname ->' || l_clistheader_rec.list_name);
     --dbms_output.put_line('object->' || l_clistheader_rec.object_version_number);
     itemkey      := p_list_header_id ||'_'||
                     l_clistheader_rec.object_version_number;
     WF_ENGINE.CreateProcess (itemtype   =>   'AMSLISTG', --itemtype,
                              itemkey    =>   itemkey ,
                              process    =>   'LIST_GENERATION');



     --dbms_output.put_line('listname ->' || l_clistheader_rec.list_name);
     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_NAME',
                               avalue     => l_clistheader_rec.list_name);

     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_TYPE',
                               avalue     => l_clistheader_rec.list_type);

     --dbms_output.put_line('listname ->' || l_clistheader_rec.list_header_id);
     WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID',
                               avalue     => l_clistheader_rec.list_header_id);

     --dbms_output.put_line('status ifd ->' || l_clistheader_rec.user_status_id);
     WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_STATUS_ID',
                               avalue     => l_clistheader_rec.user_status_id);

     --dbms_output.put_line('status cde ->' || l_clistheader_rec.status_code);
     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_STATUS_CODE',
                               avalue     => l_clistheader_rec.status_code);

     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'MONITOR_URL',
                               avalue     => wf_monitor.geturl(
                                             wf_core.TRANSLATE('WF_WEB_AGENT'),
                                             itemtype,
                                             itemkey,
                                             'NO'));

     --dbms_output.put_line('status ifd ->' || l_clistheader_rec.user_entered_start_time);
     WF_ENGINE.SetItemAttrDate(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'WAITING_TIME',
                               avalue     => l_clistheader_rec.user_entered_start_time);
  --bmuthukr for bug 3895455. Getting last updated user's id and passing..instead of passing owner id.
  open c1(l_clistHeader_rec.last_updated_by);
  fetch c1 into l_user_id;
  close c1;

  Get_User_Role(p_user_id              => l_user_id, --l_clistHeader_rec.owner_user_id ,
                x_role_name            => l_requester_role,
                x_role_display_name    => l_display_name,
                x_return_status        => l_return_status);
  --

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'LIST_OWNER',
                            avalue      =>  l_requester_role  );



   WF_ENGINE.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requester_role);




      WF_ENGINE.StartProcess (itemtype       => itemtype,
                              itemkey       => itemkey);

EXCEPTION
     WHEN OTHERS THEN
        wf_core.context (G_PKG_NAME, 'StartProcess',
                           p_list_header_id,itemuserkey,workflowprocess);
        RAISE;
END StartProcess;

-- Start of Comments
--
-- NAME
--   Generate_list
--
-- PURPOSE
--   This Procedure will generate List
--   Success or Failure
--
-- IN
--    Itemtype - AMSLISTG
--    Itemkey  -
--    Accid    -
--    Funmode  - Run/Cancel/Timeout
--
-- OUT
--  Result - 'COMPLETE:SUCCESS' If the list is successfully completed
--         - 'COMPLETE:FAILURE' If there is an error in list
--
-- Used By Activities
--        Item Type - AMSLISTG
--       Activity  - Generate_list
--
-- NOTES
--
--
-- HISTORY
-- End of Comments

PROCEDURE Generate_list(itemtype  IN       VARCHAR2,
                        itemkey   IN       VARCHAR2,
                        actid         IN       NUMBER,
                        funcmode  IN       VARCHAR2,
                        result    OUT NOCOPY   VARCHAR2) IS
  l_return_status   varchar2(1);
  l_list_header_id  number;
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_error_msg              VARCHAR2(4000);
BEGIN
      --  RUN mode  - Normal Process Execution
      IF (funcmode = 'RUN')      THEN
         l_list_header_id :=  WF_ENGINE.getItemAttrNumber
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID');

         l_return_status := FND_API.G_RET_STS_SUCCESS;

         AMS_ListGeneration_PKG.GENERATE_LIST
         ( p_api_version            => 1.0,
           p_init_msg_list          => FND_API.G_TRUE,
           p_commit                 => FND_API.G_FALSE,
           p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
           p_list_header_id         => l_list_header_id,
           x_return_status          => l_return_status,
           x_msg_count              => l_msg_count,
           x_msg_data               => l_msg_data) ;

          IF (l_return_status = FND_API.G_RET_STS_SUCCESS )THEN
             result := 'COMPLETE:SUCCESS' ;
             RETURN;
          ELSE
             result := 'COMPLETE:FAILURE' ;
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
EXCEPTION
      WHEN OTHERS THEN
        Handle_Err
          ( p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           x_error_msg         => l_error_msg       );
         wf_core.context(G_PKG_NAME,'Genrate_List',itemtype,
                           itemkey,actid,funcmode|| l_error_msg);
        RAISE;
            raise ;
END Generate_List ;

PROCEDURE Check_SCH(itemtype  IN       VARCHAR2,
                        itemkey   IN       VARCHAR2,
                        actid         IN       NUMBER,
                        funcmode  IN       VARCHAR2,
                        result    OUT NOCOPY   VARCHAR2) IS
  l_return_status   varchar2(1);
  l_gen_date  date;
  l_list_header_id   number;
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_error_msg              VARCHAR2(4000);
BEGIN
      --  RUN mode  - Normal Process Execution
      IF (funcmode = 'RUN')      THEN
         l_list_header_id :=  WF_ENGINE.getItemAttrNumber
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID');

         l_gen_date :=  WF_ENGINE.getItemAttrDate
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'WAITING_TIME');
         if l_gen_date > sysdate then
             update ams_list_headers_all
             set status_code                  = 'SCHEDULED',
                 user_status_id               = 301,
                 status_date                  = sysdate,
                 last_update_date             = sysdate
             WHERE  list_header_id            = l_list_header_id;

             result := 'COMPLETE:AMS_SCH_TRUE' ;
             RETURN;
         else
             update ams_list_headers_all
             set status_code                  = 'GENERATING',
                 user_status_id               = 302,
                 status_date                  = sysdate,
                 last_update_date             = sysdate
             WHERE  list_header_id            = l_list_header_id;

             result := 'COMPLETE:AMS_SCH_FALSE' ;
             RETURN;
         end if;

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
        Handle_Err
          ( p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           x_error_msg         => l_error_msg       );
         wf_core.context(G_PKG_NAME,'Genrate_List',itemtype,
                           itemkey,actid,funcmode|| l_error_msg);
        RAISE;
            raise ;
END Check_sch ;

PROCEDURE Check_TAR(itemtype  IN       VARCHAR2,
                    itemkey   IN       VARCHAR2,
                    actid         IN       NUMBER,
                    funcmode  IN       VARCHAR2,
                    result    OUT NOCOPY   VARCHAR2) IS
  l_return_status   varchar2(1);
  l_gen_date  date;
  l_list_header_id   number;
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_error_msg              VARCHAR2(4000);
  l_list_type        varchar2(30);
BEGIN
      --  RUN mode  - Normal Process Execution
      IF (funcmode = 'RUN')      THEN
         l_list_header_id :=  WF_ENGINE.getItemAttrNumber
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID');
         l_list_type :=  WF_ENGINE.getItemAttrText
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_TYPE');
             update ams_list_headers_all
             set status_code                  = 'GENERATING',
                 user_status_id               = 302,
                 status_date                  = sysdate,
                 last_update_date             = sysdate
             WHERE  list_header_id            = l_list_header_id;

         if  l_list_type = 'TARGET' then
           result := 'COMPLETE:Y' ;
         else
           result := 'COMPLETE:N' ;
         end if;

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
      COMMIT;
EXCEPTION
      WHEN OTHERS THEN
        Handle_Err
          ( p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           x_error_msg         => l_error_msg       );
         wf_core.context(G_PKG_NAME,'Genrate_List',itemtype,
                           itemkey,actid,funcmode|| l_error_msg);
        RAISE;
            raise ;
END Check_TAR ;

PROCEDURE GEN_TARGET(itemtype  IN       VARCHAR2,
                    itemkey   IN       VARCHAR2,
                    actid         IN       NUMBER,
                    funcmode  IN       VARCHAR2,
                    result    OUT NOCOPY   VARCHAR2) IS
  l_return_status   varchar2(1);
  l_gen_date  date;
  l_list_header_id   number;
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_error_msg              VARCHAR2(4000);
cursor c2 is
select list_used_by , list_used_by_id
from  ams_act_lists
where list_header_id = l_list_header_id
and   list_act_type = 'TARGET' ;
l_list_used_by         varchar2(30);
l_list_used_by_id      number;

BEGIN
      --  RUN mode  - Normal Process Execution
      IF (funcmode = 'RUN')      THEN
         l_list_header_id :=  WF_ENGINE.getItemAttrNumber
                              (itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID');

         open c2;
         fetch c2 into l_list_used_by, l_list_used_by_id;
         close c2;

         AMS_Act_List_PVT.generate_target_group_list_old
           ( p_api_version            => 1.0,
             p_init_msg_list          => FND_API.G_TRUE,
             p_commit                 => FND_API.G_FALSE,
             p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
             p_list_used_by           => l_list_used_by,
             p_list_used_by_id        => l_list_used_by_id,
             x_return_status          => l_return_status,
             x_msg_count              => l_msg_count,
             x_msg_data              => l_msg_data
             ) ;
           result := 'COMPLETE:' ;

           --To fix bug 5187640
	   IF (l_return_status = FND_API.G_RET_STS_SUCCESS )THEN
             result := 'COMPLETE:SUCCESS' ;
             RETURN;
           ELSE
             result := 'COMPLETE:FAILURE' ;
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
EXCEPTION
      WHEN OTHERS THEN
        Handle_Err
          ( p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           x_error_msg         => l_error_msg       );
         wf_core.context(G_PKG_NAME,'Genrate_List',itemtype,
                           itemkey,actid,funcmode|| l_error_msg);
        RAISE;
            raise ;
END GEN_TARGET ;
-- -----------------------------------------------------------------------
PROCEDURE StartListBizEventProcess
                   ( p_list_header_id        IN      NUMBER) IS

 l_parameter_list  WF_PARAMETER_LIST_T;
 l_new_item_key    VARCHAR2(30);
 l_return_status	VARCHAR2(30);
 l_start_time            DATE;
  l_sys_start_time        DATE;
  l_timezone              NUMBER;
  l_msg_count            NUMBER ;
  l_msg_data              VARCHAR2(2000);
  l_is_manual	          VARCHAR2(1);


  CURSOR c_list_det IS
  select USER_ENTERED_START_TIME, timezone_id
  from ams_list_headers_vl
  where list_header_id = p_list_header_id;

BEGIN

     AMS_LISTGENERATION_PKG.is_manual (
	p_list_header_id => p_list_header_id,
	x_return_status => l_return_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data,
	x_is_manual => l_is_manual
     );

     IF (l_is_manual = 'Y')
     then
	RAISE FND_API.G_EXC_ERROR;
     end if;


     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => ' Raise Business event-- in StartListBusinessEventProcess process.',
         p_msg_type        => 'DEBUG'
       );

         AMS_Utility_PVT.debug_message('Raise Business event-- in StartListBizEventProcess process');
         -- Raise a business event
         l_new_item_key    := p_list_header_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
         l_parameter_list := WF_PARAMETER_LIST_T();
         AMS_Utility_PVT.debug_message('Raise Business event-- after WF_PARAMETER_LIST_T call');
     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => ' Raise Business event-- after WF_PARAMETER_LIST_T call',
         p_msg_type        => 'DEBUG'
       );
     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => 'Raise Business event p_list_header_id= '||to_char(p_list_header_id),
         p_msg_type        => 'DEBUG'
       );
         wf_event.AddParameterToList(p_name           => 'LIST_HEADER_ID',
                                    p_value           => p_list_header_id,
                                    p_parameterlist   => l_parameter_list);
     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => 'Raise Business event-- after AddParameterToList call',
         p_msg_type        => 'DEBUG'
       );
         AMS_Utility_PVT.debug_message('Raise Business event-- after AddParameterToList call');
   OPEN  c_list_det;
   FETCH c_list_det INTO l_start_time, l_timezone;
   CLOSE c_list_det;
/*
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
*/
   -- If any errors happen let start time be sysdate
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      l_sys_start_time := SYSDATE;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      l_sys_start_time := SYSDATE;
   END IF;
         AMS_Utility_PVT.debug_message('Raise Business event-- Start');
/*
        update ams_list_headers_all set WORKFLOW_ITEM_KEY  = l_new_item_key
        where list_header_id = p_list_header_id;
*/
             update ams_list_headers_all
             set status_code                  = 'SCHEDULED',
                 user_status_id               = 301,
                 status_date                  = sysdate,
                 last_update_date             = sysdate,
                 WORKFLOW_ITEM_KEY  	      = l_new_item_key
             WHERE  list_header_id            = p_list_header_id;


     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => 'Raise Business event-- Start',
         p_msg_type        => 'DEBUG'
       );
         WF_EVENT.Raise
            ( p_event_name   =>  'oracle.apps.ams.list.ListGenerationEvent',
              p_event_key    =>  l_new_item_key,
              p_parameters   =>  l_parameter_list,
              p_send_date    =>  l_start_time);
              -- p_send_date    =>  l_sys_start_time);
     AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'LIST',
         p_log_used_by_id  => p_list_header_id,
         p_msg_data        => 'Raise Business event-- End',
         p_msg_type        => 'DEBUG'
       );
         AMS_Utility_PVT.debug_message('Raise Business event-- End');
      commit;
END StartListBizEventProcess;

PROCEDURE Wf_Init_var(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) IS
     -- itemtype     VARCHAR2(30) := 'AMSLISTG';
     -- itemkey      VARCHAR2(30) ;
     itemuserkey VARCHAR2(80) ;

     l_clistheader_rec AMS_ListHeader_PVT.list_header_rec_type;
     l_listheader_rec  AMS_ListHeader_PVT.list_header_rec_type;
     l_display_name    varchar2(360);
     l_requester_role  varchar2(360);
     l_return_status   varchar2(1);
     l_list_header_id 	number;
  --bmuthukr changes for bug 3895455.
  l_user_id    NUMBER;
  cursor c1(l_last_updated_by number) is
  select jtf.resource_id
    from jtf_rs_resource_extns jtf
   where jtf.user_id = l_last_updated_by;
  --
begin

   IF (funcmode = 'RUN')
   THEN

     IF (AMS_DEBUG_HIGH_ON) THEN

     Ams_Utility_pvt.debug_message('Start');
     END IF;

     --dbms_output.put_line('Start');
       l_list_header_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'LIST_HEADER_ID');

       AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'LIST',
            p_log_used_by_id  => l_list_header_id,
            p_msg_data        => 'WF_INIT_VAR: started',
            p_msg_type        => 'DEBUG'
            );

     AMS_ListHeader_PVT.Init_listheader_rec(l_listheader_rec );
     l_listheader_rec.list_header_id  := l_list_header_id;

     AMS_ListHeader_PVT.Complete_ListHeader_rec(
        p_listheader_rec  => l_listheader_rec,
        x_complete_rec    => l_clistheader_rec
     ) ;
     update ams_list_headers_all
     set object_version_number = object_version_number + 1
     where list_header_id = l_list_header_id;
/*
     WF_ENGINE.CreateProcess (itemtype   =>   'AMSLISTG', --itemtype,
                              itemkey    =>   itemkey ,
                              process    =>   'LIST_GENERATION');
*/
     --dbms_output.put_line('listname ->' || l_clistheader_rec.list_name);
     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_NAME',
                               avalue     => l_clistheader_rec.list_name);

     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_TYPE',
                               avalue     => l_clistheader_rec.list_type);

     --dbms_output.put_line('listname ->' || l_clistheader_rec.list_header_id);
     WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_HEADER_ID',
                               avalue     => l_clistheader_rec.list_header_id);

     --dbms_output.put_line('status ifd ->' || l_clistheader_rec.user_status_id);
     WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_STATUS_ID',
                               avalue     => l_clistheader_rec.user_status_id);

     --dbms_output.put_line('status cde ->' || l_clistheader_rec.status_code);
     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'LIST_STATUS_CODE',
                               avalue     => l_clistheader_rec.status_code);

     WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'MONITOR_URL',
                               avalue     => wf_monitor.geturl(
                                             wf_core.TRANSLATE('WF_WEB_AGENT'),
                                             itemtype,
                                             itemkey,
                                             'NO'));
     --dbms_output.put_line('status ifd ->' || l_clistheader_rec.user_entered_start_time);
     WF_ENGINE.SetItemAttrDate(itemtype  =>  itemtype,
                               itemkey    => itemkey,
                               aname      => 'WAITING_TIME',
                               avalue     => l_clistheader_rec.user_entered_start_time);
  --bmuthukr for bug 3895455. Getting last updated user's id and passing..instead of passing owner id.
  open c1(l_clistHeader_rec.last_updated_by);
  fetch c1 into l_user_id;
  close c1;

  Get_User_Role(p_user_id              => l_user_id, --l_clistHeader_rec.owner_user_id ,
                x_role_name            => l_requester_role,
                x_role_display_name    => l_display_name,
                x_return_status        => l_return_status);
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'LIST_OWNER',
                            avalue      =>  l_requester_role  );



   WF_ENGINE.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requester_role);


/*

      WF_ENGINE.StartProcess (itemtype       => itemtype,
                              itemkey       => itemkey);
*/

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
EXCEPTION
     WHEN OTHERS THEN
        wf_core.context (G_PKG_NAME, 'Wf_Init_var',itemtype,itemkey,actid,funcmode);
        RAISE;

end Wf_Init_var;

PROCEDURE Wf_abort_process
                   ( p_list_header_id        IN      NUMBER) IS


l_item_type varchar2(100) := 'AMSLISTG';
l_item_key   varchar2(100);
l_status_code  varchar2(100);

  cursor check_wf
  is select item_key
  from wf_item_activity_statuses
  where item_type = l_item_type
  and   item_key like p_list_header_id|| '%'
  and activity_status in ('ERROR','ACTIVE');

Begin
        select status_code into l_status_code from ams_list_headers_all
        where list_header_id = p_list_header_id;
        if l_status_code <> 'DRAFT' then
        update ams_list_headers_all
	   set WORKFLOW_ITEM_KEY  = null,
               status_code        = 'FAILED',
               user_status_id     = 311,
               last_update_date   = sysdate,
               status_date        = sysdate
        where list_header_id = p_list_header_id;
        commit;
        end if;

        open  check_wf ;
        fetch check_wf into l_item_key;
        close  check_wf ;
        if l_item_key is not null then
         begin
            WF_ENGINE.abortProcess(l_item_type ,
                                l_item_key);
        exception
            when no_data_found then
                 null;
        end;
        end if;

END Wf_abort_process;

-- -----------------------------------------
PROCEDURE Check_Item_Key        (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) is

    l_list_header_id             NUMBER;
    l_list_item_key 		NUMBER;
    -- l_list_item_key 		VARCHAR2(60);
    l_dummy                  NUMBER;
    l_return_status          VARCHAR2(1);

    CURSOR c_item_key_name IS
    select WORKFLOW_ITEM_KEY
    from ams_list_headers_all where list_header_id = l_list_header_id;

BEGIN
    --  RUN mode  - Normal Process Execution
    IF (funcmode = 'RUN')
    THEN
       l_list_header_id := WF_ENGINE.GetItemAttrText(
                  itemtype    =>     itemtype,
                  itemkey     =>     itemkey ,
                  aname       =>    'LIST_HEADER_ID');
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'LIST',
                     p_log_used_by_id  => l_list_header_id,
                     p_msg_data        => 'l_list_header_id  = ' || l_list_header_id,
                     p_msg_type        => 'DEBUG'
                     );
       OPEN  c_item_key_name;
       FETCH c_item_key_name INTO l_list_item_key;
       CLOSE c_item_key_name;
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'LIST',
                     p_log_used_by_id  => l_list_header_id,
                     p_msg_data        => 'l_list_item_key = ' || l_list_item_key,
                     p_msg_type        => 'DEBUG'
                     );
       IF  l_list_item_key <> itemkey THEN
             result := 'COMPLETE:N' ;
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'LIST',
                     p_log_used_by_id  => l_list_header_id,
                     p_msg_data        => 'Check_Item_Key :  1. For List Header ID = ' || itemkey || result,
                     p_msg_type        => 'DEBUG'
                     );
             RETURN;
       End if;
       IF l_list_item_key = itemkey THEN
             result := 'COMPLETE:Y' ;
             AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'LIST',
                     p_log_used_by_id  => l_list_header_id,
                     p_msg_data        => 'Check_Item_Key :  1. For List Header ID = ' || itemkey || result,
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
EXCEPTION
    WHEN OTHERS THEN
         wf_core.context(G_PKG_NAME,'AMS_LIST_WF',itemtype,itemkey,actid,funcmode);
        raise ;
END Check_Item_Key;

END AMS_LIST_WF;

/
