--------------------------------------------------------
--  DDL for Package Body AMS_WFMOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WFMOD_PVT" AS
/* $Header: amsvwmdb.pls 120.0 2005/05/31 19:57:04 appldev noship $*/

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_WFMOD_PVT';
G_FILE_NAME          CONSTANT VARCHAR2(12) := 'amsvwmdb.pls';
G_STATUS_DRAFT       CONSTANT VARCHAR2(30) := 'DRAFT';
G_STATUS_BUILDING    CONSTANT VARCHAR2(30) := 'BUILDING';
G_STATUS_SCORING     CONSTANT VARCHAR2(30) := 'SCORING';
G_STATUS_AVAILABLE   CONSTANT VARCHAR2(30) := 'AVAILABLE';
G_STATUS_COMPLETED   CONSTANT VARCHAR2(30) := 'COMPLETED';
G_STATUS_QUEUED      CONSTANT VARCHAR2(30) := 'QUEUED';
G_OBJECT_TYPE_MODEL  CONSTANT VARCHAR2(30) := 'MODL';
G_OBJECT_TYPE_SCORE  CONSTANT VARCHAR2(30) := 'SCOR';

G_STATUS_PREVIEWING  CONSTANT VARCHAR2(30) := 'PREVIEWING';
G_STATUS_INVALID     CONSTANT VARCHAR2(30) := 'INVALID';
G_STATUS_FAILED      CONSTANT VARCHAR2(30) := 'FAILED';
G_PREVIEW_REQUEST    CONSTANT VARCHAR2(30) := 'PREVIEW';
G_PREVIEW_STARTED    CONSTANT VARCHAR2(30) := 'PREVIEW_STARTED';
G_PREVIEW_COMPLETE   CONSTANT VARCHAR2(30) := 'PREVIEW_COMPLETE';

--  Start of Comments
--
-- NAME
--   AMS_WFMOD_PVT
--
-- PURPOSE
--   This package contains the workflow procedures for
--   Model Building/Scoring in Oracle Marketing
--
-- HISTORY
--  11/30/2000    sveerave@us CREATED
-- 07-Mar-2001    choang      1) Changed object type from MINING to MODL.  2)
--                            replaced itemkey in call to create_log with object_id
-- 08-Mar-2001    choang      Added user_status_id in startprocess.
-- 20-Mar-2001    choang      Modified all messages.
-- 30-Mar-2001    choang      Added cancel_process and change_schedule
-- 10-Apr-2001    choang      Added log entry for response messages from dequeue.
-- 11-Apr-2001    choang      handle updates to base objects for different ending statuses.
-- 19-Apr-2001    choang      - Fixed problem in update_obj_status to use l_object_status
--                              instead of l_status_code
--                            - update logs_flag in model/score table when writing log entry
-- 03-Jul-2001    choang      Replaced callouts to AQ with submit request to concurrent
--                            manager.
-- 12-Jul-2001    choang      - added calls to bin_probability and process_scores
--                              collect_results.
--                            - added validate_concurrency.
-- 27-Jul-2001    choang      added callout to generate_odm_input_views.
-- 20-Aug-2001    choang      fixed result in validate_concurrency.
-- 04-Sep-2001    choang      Added wait for conc request to complete.
-- 11-Nov-2001    choang      Added start/end messages to main wf functions.
-- 16-Nov-2001    choang      Added commits to change_schedule and cancel_process.
-- 26-Nov-2001    choang      Changed scoring run completion status to COMPLETED
--                            from AVAILABLE.
-- 07-Dec-2001    choang      Modified logic for change_schedule
-- 30-May-2002    choang      Fixed select order of model and scoring run
--                            in validate_data details.
-- 03-Jun-2002    choang      Replaced target_group_type with data_source_id and use
--                            new version of generate_odm_input_views; do not
--                            perform party data extraction for alternative data
--                            sources.
-- 29-Aug-2002    nyostos     Added Reset_Status procedure to reset model/score status
--                            to DRAFT.
-- 17-Sep-2002    nyostos     Changes to support new Model and Scoring Run States
--                            Three new states are added: INVALID, FAILED and PREVIEWING.
--                            - Reset_Status - sets the status to FAILED
-- 22-Oct-2002    nyostos     Fixed a problem in validate_concurrency where multiple preview
--                            requests deadlocked.
-- 30-Jan-2003    nyostos     Moved the check for owner role from Validate_data() to startProcess().
--                            The WF process will not be started if the Model/Score owner does not have
--                            a valid WF approver role.
-- 23-Jul-2003    rosharma    Passed score ID to AMS_JCP_MODEL_APPLY.
-- 16-Sep-2003    nyostos     Changes related to allowing parallel mining operations.
-- 20-Sep-2003    rosharma    Changes related to Audience data source uptake.
-- 22-Sep-2003    nyostos     Fixed TRANSFORM to exit if generate_odm_input_views errors out and not
--                            proceed with ExtractMain.
-- 12-Feb-2004    rosharma    Bug # 3436093.
-- 06-Apr-2004    rosharma    Bug # 3557739.
-- 22-Apr-2005    srivikri    Bug # 4305459.
--

AMS_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Get_User_Role
  ( p_user_id            IN     NUMBER,
    x_role_name          OUT NOCOPY    VARCHAR2,
    x_role_display_name  OUT NOCOPY    VARCHAR2 ,
    x_return_status      OUT NOCOPY    VARCHAR2
);

PROCEDURE write_buffer_to_log (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER
);


/***************************  PRIVATE ROUTINES  *******************************/

-- Start of Comments
--
-- NAME
--   Intialize_Var
--
-- PURPOSE
--   This Procedure will initialize all the variables
--
-- Called By
--   Start_Process
--
-- NOTES
--   When the process is started , all the variables are extracted
--   from database using object id, request type passed to the Start Process
--
-- HISTORY
--   11/30/2000        sveerave@us            created
-- End of Comments

PROCEDURE Initialize_Var (  p_object_id         IN NUMBER
                          , p_object_type       IN VARCHAR2
                          , p_user_status_id    IN NUMBER
                          , p_scheduled_timezone_id   IN NUMBER
                          , p_scheduled_date    IN DATE
                          , p_request_type      IN VARCHAR2
                          , p_select_list       IN VARCHAR2
                          , p_enqueue_message   IN VARCHAR2
                          , p_itemtype          IN VARCHAR2
                          , p_itemkey           IN VARCHAR2
                         ) IS
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);

   l_system_scheduled_date    DATE;

BEGIN
   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'MONITOR_URL'
      , avalue      =>   wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), p_itemtype, p_itemkey, 'NO')
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('URL: ' || wf_monitor.geturl(wf_core.TRANSLATE('WF_WEB_AGENT'), p_itemtype, p_itemkey, 'NO'));
   END IF;

   WF_ENGINE.SetItemAttrNumber(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'OBJECT_ID'
      , avalue      =>   p_object_id
   );

   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'OBJECT_TYPE'
      , avalue      =>   p_object_type
   );

   WF_ENGINE.SetItemAttrNumber(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'ORIG_USER_STATUS_ID'
      , avalue      =>   p_user_status_id
   );

   -- if needed, convert the time into system time from schedule time zone ??
   -- for time being, assuming that shedule_date and workflow system date are in
   -- in same time zone ??
   AMS_Utility_PVT.convert_timezone (
      p_init_msg_list   => FND_API.G_FALSE,
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_user_tz_id      => p_scheduled_timezone_id,
      p_in_time         => p_scheduled_date,
      p_convert_type    => 'SYS',
      x_out_time        => l_system_scheduled_date
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('SYSTEM SCHEDULED - WAIT: ' || TO_CHAR (l_system_scheduled_date, 'DD-MON-RRRR HH24:MI:SS'));
   END IF;

   WF_ENGINE.SetItemAttrDate(
         itemtype    =>   p_itemtype
       , itemkey     =>   p_itemkey
       , aname       =>   'SCHEDULE_DATE'
       , avalue      =>   l_system_scheduled_date
   );

   IF p_request_type IS NULL THEN
      WF_ENGINE.SetItemAttrText(
           itemtype    =>   p_itemtype
         , itemkey     =>   p_itemkey
         , aname       =>   'REQUEST_TYPE'
         , avalue      =>   ' '
      );
   ELSE
      WF_ENGINE.SetItemAttrText(
           itemtype    =>   p_itemtype
         , itemkey     =>   p_itemkey
         , aname       =>   'REQUEST_TYPE'
         , avalue      =>   p_request_type
      );
   END IF;


   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'SELECT_LIST'
      , avalue      =>   p_select_list
   );

   /* If PREVIEW request, then set the STATUS_CODE variable to PREVIEWING */
   IF p_request_type = G_PREVIEW_REQUEST THEN
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   p_itemtype
             , itemkey     =>   p_itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_PREVIEWING
         );
   ELSE
      /* Set status to BUILDING or SCORING as per object_type */
      IF p_object_type = G_OBJECT_TYPE_MODEL THEN
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   p_itemtype
             , itemkey     =>   p_itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_BUILDING
         );
      ELSIF p_object_type = G_OBJECT_TYPE_SCORE THEN
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   p_itemtype
             , itemkey     =>   p_itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_SCORING
         );
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message ('REQUEST_TYPE: ' || p_request_type);
      AMS_Utility_PVT.debug_message ('ORIG_USER_STATUS_ID: ' || p_user_status_id);
      AMS_Utility_PVT.debug_message ('STATUS_CODE: ' || WF_ENGINE.GetItemAttrText(itemtype => p_itemtype, itemkey => p_itemkey, aname => 'STATUS_CODE'));
   END IF;

END Initialize_Var ;

-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
--   p_object_id          Object ID - Model or Score ID
--   p_object_type        Object Type - MODL or SCOR
--   p_usr_status_id      The original status of the object before WF
--   p_request_type       Request Type for data mining engine, Darwin
--   p_select_list        Select List for data mining engine, Darwin
--   processowner         Owner Of the Process
--   workflowprocess      Work Flow Process Name (MODEL_BUILD_SCORE)
--   itemtype             Item type DEFAULT NULL(AMSDMMOD)

--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000   sveerave@us	created
-- 07-mar-2001    choang      Added x_itemkey
-- End of Comments


PROCEDURE StartProcess(  p_object_id         IN    NUMBER
                       , p_object_type       IN    VARCHAR2
                       , p_user_status_id    IN    NUMBER
                       , p_scheduled_timezone_id   IN NUMBER
                       , p_scheduled_date    IN    DATE
                       , p_request_type      IN    VARCHAR2 DEFAULT NULL
                       , p_select_list       IN    VARCHAR2 DEFAULT NULL
                       , p_enqueue_message   IN    VARCHAR2 DEFAULT NULL
                       , processowner        IN    VARCHAR2 DEFAULT NULL
                       , workflowprocess     IN    VARCHAR2 DEFAULT NULL
                       , itemtype            IN    VARCHAR2 DEFAULT G_DEFAULT_ITEMTYPE
                       , x_itemkey           OUT NOCOPY   VARCHAR2
                      )  IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'STARTPROCESS';


   CURSOR c_get_model_owner(p_obj_id   NUMBER) IS
      SELECT owner_user_id
      FROM ams_dm_models_vl model
      WHERE model_id = p_obj_id
      ;

   CURSOR c_get_score_owner(p_obj_id   NUMBER) IS
      SELECT score.owner_user_id
      FROM ams_dm_scores_vl score
      WHERE score_id = p_obj_id
      ;

   l_owner_user_id         NUMBER;
   l_owner_role            VARCHAR2(80);
   l_owner_role_name       VARCHAR2(120);

   l_itemtype   VARCHAR2(30) := nvl(itemtype, G_DEFAULT_ITEMTYPE);
   itemkey      VARCHAR2(30) := p_object_id||p_object_type||TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
   itemuserkey  VARCHAR2(80) := p_object_id||'-'||p_object_type;
   l_return_status VARCHAR2(1);

BEGIN
   -- clear the message buffer
   FND_MSG_PUB.initialize;

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': begin ' || itemkey
   );

   -- Get Model/Score Owner
   IF (p_object_type = G_OBJECT_TYPE_MODEL ) THEN

      OPEN c_get_model_owner(p_object_id);
      FETCH c_get_model_owner INTO  l_owner_user_id;

      IF c_get_model_owner%NOTFOUND THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' - c_get_model_owner%NOTFOUND');
         END IF;

         x_itemkey := NULL;

         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_get_model_owner;

   ELSIF p_object_type = G_OBJECT_TYPE_SCORE THEN

      OPEN c_get_score_owner(p_object_id);
      FETCH c_get_score_owner INTO l_owner_user_id;

      IF c_get_score_owner%NOTFOUND THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' - c_get_score_owner%NOTFOUND');
         END IF;

         x_itemkey := NULL;

         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_get_score_owner;

   END IF;

   -- Check the Model/Score owner has the right role
   Get_User_Role(p_user_id              => l_owner_user_id ,
                 x_role_name            => l_owner_role,
                 x_role_display_name    => l_owner_role_name,
                 x_return_status        => l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' - Get_User_Role Failed.  ');
      END IF;

      x_itemkey := NULL;
   ELSE

      IF (AMS_DEBUG_HIGH_ON) THEN
         Ams_Utility_pvt.debug_message('ITEMTYPE: ' || l_itemtype || ' - ITEMKEY: ' || itemkey);
      END IF;

      -- dbms_output.put_line('Start');
      WF_ENGINE.CreateProcess (  itemtype   =>   l_itemtype
                               , itemkey    =>   itemkey
                               , process    =>   'MODEL_BUILD_SCORE'
                              );

      -- Call a Proc to Initialize the Variables
      Initialize_Var(  p_object_id        => p_object_id
                     , p_object_type      => p_object_type
                     , p_user_status_id   => p_user_status_id
                     , p_scheduled_timezone_id  => p_scheduled_timezone_id
                     , p_scheduled_date   => p_scheduled_date
                     , p_request_type     => p_request_type
                     , p_select_list      => p_select_list
                     , p_enqueue_message  => p_enqueue_message
                     , p_itemtype         => l_itemtype
                     , p_itemkey          => itemkey
                    );

      -- srivikri - bug4305459 04/22/05- setting item owner
      Wf_Engine.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_owner_role);

      WF_ENGINE.StartProcess (  itemtype    => l_itemtype
                              , itemkey      => itemkey
                             );

      -- return to calling procedure
      -- note: originally created for schedule cancellation in
      --       model and score screens.
      x_itemkey := itemkey;
   END IF;

   write_buffer_to_log (p_object_type, p_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => p_object_type,
      p_log_used_by_id  => p_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );

EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (p_object_type, p_object_id);

      wf_core.context (G_PKG_NAME, 'StartProcess',p_object_id,itemuserkey,workflowprocess);

      raise;
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
--   11/30/2000        sveerave@us	created
-- End of Comments


PROCEDURE selector (  itemtype    IN      VARCHAR2
                    , itemkey     IN      VARCHAR2
                    , actid       IN      NUMBER
                    , funcmode    IN      VARCHAR2
                    , resultout   OUT NOCOPY     VARCHAR2
                    )  IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'SELECTOR';

   l_return_status VARCHAR2(1);
   l_object_id     NUMBER;
   l_object_type   VARCHAR2(30);
BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );

   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   -- dbms_output.put_line('In Selector Function');
   --
   -- RUN mode - normal process execution
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;

   IF  (funcmode = 'RUN') THEN
      --
      -- Return process to run
      --
      resultout := 'MODEL_BUILD_SCORE';
   --
   -- CANCEL mode -
   --
   ELSIF  (funcmode = 'CANCEL') THEN
      --
      -- Return process to run
      --
      resultout := 'MODEL_BUILD_SCORE';
   --
   -- TIMEOUT mode
   --
   ELSIF  (funcmode = 'TIMEOUT') THEN
      resultout := 'MODEL_BUILD_SCORE';
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

   -- The line below records this function call in the error system
   -- in the case of an exception.
      wf_core.context (G_PKG_NAME, 'Selector', itemtype, itemkey, actid, funcmode);

      RAISE;
END Selector;

-- Start of Comments
--
-- NAME
--   Validate
--
-- PURPOSE
--   This Procedure will aggregate sources based on user selections, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If the validation is successfully completed
--              - 'COMPLETE:F' If there is an error in validation
--
-- Used By Activities
--       Item Type - AMSDMMOD
--       Activity  - VALIDATE
--
-- NOTES
--
--
-- HISTORY
--   02/27/2001   sveerave@us created
-- 30-Mar-2001    choang      Added convert_timezone
-- 05-Jul-2001    choang      Removed best_subtree
-- 03-Jun-2002    choang      replaced target_group_type with data_source_id
-- End of Comments

PROCEDURE validate_data (  itemtype  IN     VARCHAR2
                         , itemkey   IN     VARCHAR2
                         , actid     IN     NUMBER
                         , funcmode  IN     VARCHAR2
                         , result    OUT NOCOPY   VARCHAR2
                         ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'VALIDATE_DATA';

   CURSOR c_get_model_details(p_obj_id   NUMBER) IS
      SELECT model.model_type
         , target.data_source_id
         , target_positive_value
         , model_name
         , status_code
         , owner_user_id
	 , target.active_flag
      FROM ams_dm_models_vl model, ams_dm_targets_b target
      WHERE model_id = p_obj_id
      AND   target.target_id = model.target_id
      ;

   CURSOR c_get_score_details(p_obj_id   NUMBER) IS
      SELECT model.model_type
         , target.data_source_id
         , model.target_positive_value
         , score.score_name
         , score.status_code
         , score.owner_user_id
	 , target.active_flag
      FROM ams_dm_models_all_b model, ams_dm_scores_vl score, ams_dm_targets_b target
      WHERE score_id = p_obj_id
      AND   score.model_id = model.model_id
      AND   target.target_id = model.target_id
      ;

   l_model_type               VARCHAR2(30);
   l_data_source_id           NUMBER;
   l_target_positive_value    NUMBER;
   l_name                     VARCHAR2(120);
   l_status_code              VARCHAR2(30);
   l_object_id       NUMBER;
   l_object_type     VARCHAR2(30);
   l_result_flag     VARCHAR2(1) := 'T';

   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);

   l_owner_user_id         NUMBER;
   l_owner_role            VARCHAR2(80);
   l_owner_role_name       VARCHAR2(120);
   l_target_active_flag    VARCHAR2(1);
BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );

   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
      IF (l_object_type = G_OBJECT_TYPE_MODEL ) THEN
         OPEN c_get_model_details(l_object_id);
         FETCH c_get_model_details INTO   l_model_type
                                        , l_data_source_id
                                        , l_target_positive_value
                                        , l_name
                                        , l_status_code
                                        , l_owner_user_id
					, l_target_active_flag;

         IF c_get_model_details%NOTFOUND THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' - c_get_model_details%NOTFOUND');
            END IF;
            l_result_flag := 'F';
         END IF;
         CLOSE c_get_model_details;
      ELSIF l_object_type = G_OBJECT_TYPE_SCORE THEN
         OPEN c_get_score_details(l_object_id);
         FETCH c_get_score_details INTO   l_model_type
                                        , l_data_source_id
                                        , l_target_positive_value
                                        , l_name
                                        , l_status_code
                                        , l_owner_user_id
					, l_target_active_flag;

         IF c_get_score_details%NOTFOUND THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' - c_get_score_details%NOTFOUND');
            END IF;
            l_result_flag := 'F';
         END IF;
         CLOSE c_get_score_details;
      ELSE

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' - OBJECT_TYPE: ' || l_object_type);
         END IF;

         l_result_flag := 'F';
      END IF;

      IF l_target_active_flag = 'N' THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message (L_API_NAME || ' - Cannot proceed, the target is inactive...');
         END IF;
	 AMS_Utility_PVT.error_message ('AMS_MODEL_TARGET_DISABLED');
         l_result_flag := 'F';
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT_FLAG: ' || l_result_flag);
      END IF;

      -- Set all derived attirbutes, True status if result flag is true otherwise set False status
      IF (l_result_flag = 'F') THEN
         result := 'COMPLETE:F';
      ELSE

         -- Setting up the role
         Get_User_Role(p_user_id              => l_owner_user_id ,
                       x_role_name            => l_owner_role,
                       x_role_display_name    => l_owner_role_name,
                       x_return_status        => l_return_status);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then

            result := 'COMPLETE:F';

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' - Get_User_Role Failed. Result= ' || result);
            END IF;
         ELSE

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message (L_API_NAME || ' - Get_User_Role Succeeded. ' );
            END IF;

            WF_ENGINE.SetItemAttrText (
               itemtype    =>  itemtype
             , itemkey     =>  itemkey
             , aname       =>  'OWNER_USERNAME'
             , avalue      =>  l_owner_role  );


            WF_ENGINE.SetItemAttrText(
                  itemtype    =>   itemtype
                , itemkey     =>   itemkey
                , aname       =>   'MODEL_TYPE'
                , avalue      =>   l_model_type
            );
            WF_ENGINE.SetItemAttrNumber(
                  itemtype    =>   itemtype
                , itemkey     =>   itemkey
                , aname       =>   'DATA_SOURCE_ID'
                , avalue      =>   l_data_source_id
            );
            WF_ENGINE.SetItemAttrNumber(
                 itemtype    =>   itemtype
               , itemkey     =>   itemkey
               , aname       =>   'TARGET_POSITIVE_VALUE'
               , avalue      =>   l_target_positive_value
            );

            WF_ENGINE.SetItemAttrText(
                  itemtype    =>   itemtype
                , itemkey     =>   itemkey
                , aname       =>   'NAME'
                , avalue      =>   l_name
            );
            /* we do not need to set the status as this is already
            set in Initialize_var to BUILDING or SCORING as per OBJ_TYPE */
            result := 'COMPLETE:T';
         END IF;
      END IF; -- IF (l_result_flag = 'F')
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Validate', itemtype,itemkey,to_char(actid),funcmode);

      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;
END Validate_Data;


-- Start of Comments
--
-- NAME
--   Aggregate_sources
--
-- PURPOSE
--   This Procedure will aggregate sources based on user selections, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:SUCCESS' If the aggregation is successfully completed
--              - 'COMPLETE:FAILURE' If there is an error in aggregation
--
-- Used By Activities
--       Item Type - AMSDMMOD
--       Activity  - AGGREGATE_SOURCES
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us  created
-- End of Comments

PROCEDURE Aggregate_Sources(  itemtype  IN     VARCHAR2
                            , itemkey   IN     VARCHAR2
                            , actid     IN     NUMBER
                            , funcmode  IN     VARCHAR2
                            , result    OUT NOCOPY   VARCHAR2
                           ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'AGGREGATE_SOURCES';

   l_return_status VARCHAR2(1);

   l_msg_count    NUMBER;
   l_msg_data     VARCHAR2(2000);
   l_message      VARCHAR2(4000);
   l_object_id    NUMBER;
   l_object_type  VARCHAR2(30);
BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );

   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': begin'
   );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ' - FUNCMODE: ' || funcmode
   );


   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
      AMS_DMSelection_PVT.Aggregate_Selections (
           p_arc_object      =>  l_object_type
         , p_object_id       =>  l_object_id
         , x_return_status   =>  l_return_status
      );
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         result := 'COMPLETE:SUCCESS' ;
      ELSE
         /* populate error message */
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'AGGR_ERR_MESSAGE'
               , avalue       =>    l_message
               );
         /* populate status to DRAFT */
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
         );
         result := 'COMPLETE:FAILURE' ;
      END IF;
   --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': EXCEPTION BUFFER WRITTEN'
   );
      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;

   -- The line below records this function call in the error system
   -- in the case of an exception.
--      wf_core.context(G_PKG_NAME,'Aggregate_Sources',itemtype,itemkey,to_char(actid),funcmode);
END Aggregate_Sources ;

-- Start of Comments
--
-- NAME
--   Transform
--
-- PURPOSE
--   This Procedure will transform the untransformed data, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result   - 'COMPLETE:SUCCESS' If the transformation is successfully completed
--                - 'COMPLETE:FAILURE' If there is an error in transformation
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - TRANSFORM
--
-- NOTES
--
--
-- HISTORY
-- 30-Nov-2000 sveerave@us created
-- 03-Jun-2002 choang      changed call to generate_odm_input_views to use data_source_id
--
-- End of Comments

PROCEDURE Transform(  itemtype  IN     VARCHAR2
                    , itemkey   IN     VARCHAR2
                    , actid     IN     NUMBER
                    , funcmode  IN     VARCHAR2
                    , result    OUT NOCOPY   VARCHAR2
                   ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'TRANSFORM';
   L_SEEDED_ID_THRESHOLD   CONSTANT NUMBER := 10000;

   l_return_status      VARCHAR2(1);
   l_log_return_status  VARCHAR2(1);

   l_object_id          NUMBER;
   l_object_type        VARCHAR2(30);
   l_data_source_id     NUMBER;
   l_api_version        NUMBER := 1.0;
   l_init_msg_list      VARCHAR2(1) := FND_API.g_false;
   l_commit             VARCHAR2(1) := FND_API.g_true;
   l_validation_level   NUMBER := 100;
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_message            VARCHAR2(4000);

   l_seeded_data_source BOOLEAN := FALSE;

   CURSOR c_target_id_model (p_model_id IN NUMBER) IS
      SELECT target_id
      FROM   ams_dm_models_v
      WHERE  model_id = p_model_id
      ;

   CURSOR c_target_id_score (p_score_id IN NUMBER) IS
      SELECT model.target_id
      FROM   ams_dm_models_v model , ams_dm_scores_v score
      WHERE  score.score_id = p_score_id
      AND    score.model_id = model.model_id
      ;

   l_target_id        NUMBER;

BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': begin'
   );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ' - FUNCMODE: ' || funcmode
   );

   l_data_source_id := WF_ENGINE.GetItemAttrNumber (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'DATA_SOURCE_ID'
                              );

   -- start changes rosharma for audience data sources uptake
   /*IF l_data_source_id < L_SEEDED_ID_THRESHOLD THEN
      l_seeded_data_source := TRUE;
   END IF;*/

   IF l_object_type = 'MODL' THEN
      OPEN c_target_id_model(l_object_id);
      FETCH c_target_id_model INTO l_target_id;
      CLOSE c_target_id_model;
   ELSE
      OPEN c_target_id_score(l_object_id);
      FETCH c_target_id_score INTO l_target_id;
      CLOSE c_target_id_score;
   END IF;

   IF l_target_id < L_SEEDED_ID_THRESHOLD THEN
      l_seeded_data_source := TRUE;
   END IF;
   -- end changes rosharma for audience data sources uptake

   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN

      AMS_DMSource_PVT.generate_odm_input_views (
           p_api_version      => 2.0
         , p_init_msg_list    => l_init_msg_list
         , p_object_type      => l_object_type
         , p_object_id        => l_object_id
         , p_data_source_id   => l_data_source_id
         , x_return_status    => l_return_status
         , x_msg_count        => l_msg_count
         , x_msg_data         => l_msg_data
      );

      AMS_Utility_PVT.create_log (
         x_return_status   => l_log_return_status,
         p_arc_log_used_by => l_object_type,
         p_log_used_by_id  => l_object_id,
         p_msg_data        => ' After  generate_odm_input_views  status ' || l_return_status
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         result := 'COMPLETE:FAILURE' ;

         /* populate error message */
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'TRAN_ERR_MESSAGE'
               , avalue       =>    l_message
               );
         /* populate status to DRAFT */
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
         );
      ELSE
         result := 'COMPLETE:SUCCESS' ;
         IF l_seeded_data_source THEN

            -- only need to perform data extraction for seeded data sources
            AMS_DMExtract_pvt.ExtractMain (
                    p_api_version       => l_api_version
                  , p_init_msg_list     => l_init_msg_list
                  , p_commit            => l_commit
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data          => l_msg_data
                  , p_mode              => 'I'
                  , p_model_id          => l_object_id
                  , p_model_type        => l_object_type
            );
            IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               result := 'COMPLETE:SUCCESS' ;
            ELSE
               /* populate error message */
               WF_ENGINE.SetItemAttrText(
                       itemtype     =>    itemtype
                     , itemkey      =>    itemkey
                     , aname        =>    'TRAN_ERR_MESSAGE'
                     , avalue       =>    l_msg_data
                     );
               /* populate status to DRAFT */
               WF_ENGINE.SetItemAttrText(
                     itemtype    =>   itemtype
                   , itemkey     =>   itemkey
                   , aname       =>   'STATUS_CODE'
                   , avalue      =>   G_STATUS_DRAFT
               );
               result := 'COMPLETE:FAILURE' ;
            END IF;
         END IF; -- IF l_seeded_data_source THEN
      END IF;  --   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ' - RESULT: ' || result
   );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_log_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Transform',itemtype,itemkey,to_char(actid),funcmode);

      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;
END Transform ;

-- Start of Comments
--
-- NAME
--   Command
--
-- PURPOSE
--   This Procedure will request for data mining by posting a request to AQ, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
-- OUT
--       Result   - 'COMPLETE:SUCCESS' If sumbmitting aq request  is successfully completed
--                - 'COMPLETE:FAILURE' If there is an error in submitting the aq request
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - COMMAND
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us	created
-- End of Comments

PROCEDURE Command(  itemtype  IN    VARCHAR2
                  , itemkey   IN    VARCHAR2
                  , actid     IN    NUMBER
                  , funcmode  IN    VARCHAR2
                  , result    OUT NOCOPY   VARCHAR2
                  ) IS
   L_API_NAME        CONSTANT VARCHAR2(30) := 'COMMAND';
   L_APPLICATION_NAME      CONSTANT VARCHAR2(30) := 'AMS';
   L_SCORE_PROGRAM   CONSTANT VARCHAR2(30) := 'AMS_JCP_MODEL_APPLY';
   L_BUILD_PROGRAM   CONSTANT VARCHAR2(30) := 'AMS_JCP_MODEL_BUILD';

   l_object_id       NUMBER;
   l_object_type     VARCHAR2(30);
   l_model_type      VARCHAR2(30);
   l_model_id        NUMBER;
   l_target_group    VARCHAR2(30);
   l_request_type    VARCHAR2(30);
   l_select_list     VARCHAR2(2000);

   -- concurrent processing variables
   l_call_status     BOOLEAN;
   l_request_id      NUMBER;
   l_phase           VARCHAR2(80);
   l_status          VARCHAR2(80);
   l_dev_phase       VARCHAR2(30);
   l_dev_status      VARCHAR2(30);
   l_message         VARCHAR2(2000);

   l_return_status   VARCHAR2(1);
   l_msg_data        VARCHAR2 (2000);

   l_sysdate         DATE := SYSDATE;
   l_target_positive_value    NUMBER;

   CURSOR c_model (p_score_id IN NUMBER) IS
      SELECT model_id
      FROM   ams_dm_scores_all_b
      WHERE  score_id = p_score_id;
BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     => itemtype
                              , itemkey      => itemkey
                              , aname        => 'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   => itemtype
                              , itemkey    => itemkey
                              , aname      => 'OBJECT_TYPE'
                              );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': begin'
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
      l_model_type := WF_ENGINE.GetItemAttrText(
                                     itemtype    => itemtype
                                   , itemkey     => itemkey
                                   , aname       => 'MODEL_TYPE'
                                  );
      l_target_group := WF_ENGINE.GetItemAttrNumber(
                                   itemtype     => itemtype
                                 , itemkey      => itemkey
                                 , aname        => 'DATA_SOURCE_ID'
                                 );
      l_request_type := WF_ENGINE.GetItemAttrText (
                                   itemtype   => itemtype
                                 , itemkey    => itemkey
                                 , aname      => 'REQUEST_TYPE'
                                 );
      l_select_list := WF_ENGINE.GetItemAttrText(
                                   itemtype     => itemtype
                                 , itemkey      => itemkey
                                 , aname        => 'SELECT_LIST'
                                 );

      l_target_positive_value := WF_ENGINE.GetItemAttrNumber(
                                   itemtype     => itemtype
                                 , itemkey      => itemkey
                                 , aname        => 'TARGET_POSITIVE_VALUE'
                                 );

      IF l_object_type = G_OBJECT_TYPE_MODEL THEN
         l_request_id := fnd_request.submit_request (
                            application   => L_APPLICATION_NAME,
                            program       => L_BUILD_PROGRAM,
                            start_time    => l_sysdate,
                            argument1     => l_object_id,
                            argument2     => l_target_positive_value,
                            argument3     => l_target_group
                         );
      ELSE
         OPEN c_model (l_object_id);
         FETCH c_model INTO l_model_id;
         CLOSE c_model;

         l_request_id := fnd_request.submit_request (
                            application   => L_APPLICATION_NAME,
                            program       => L_SCORE_PROGRAM,
                            start_time    => l_sysdate,
                            argument1     => l_model_id,
                            argument2     => l_object_id,
                            argument3     => l_target_group
                         );
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' - REQUEST_ID: ' || l_request_id);
      END IF;

      IF l_request_id <> 0 THEN
         WF_ENGINE.SetItemAttrNumber(
              itemtype    =>   itemtype
            , itemkey     =>   itemkey
            , aname       =>   'REQUEST_ID'
            , avalue      =>   l_request_id
         );

         -- need to do a commit after submit_request
         -- so concurrent manager will see the request,
         -- otherwise, the process will hang.
         COMMIT;

         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => l_object_type,
            p_log_used_by_id  => l_object_id,
            p_msg_data        => L_API_NAME || ': REQUEST_ID - ' || l_request_id
         );

         -- wait for the request to complete
         l_call_status := fnd_concurrent.wait_for_request (
            request_id  => l_request_id,
            phase       => l_phase,
            status      => l_status,
            dev_phase   => l_dev_phase,
            dev_status  => l_dev_status,
            message     => l_message
         );

         IF l_dev_status = 'NORMAL' THEN
            result := 'COMPLETE:SUCCESS' ;
         ELSE
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => l_object_type,
               p_log_used_by_id  => l_object_id,
               p_msg_data        => L_API_NAME || ' - CONCURRENT REQUEST ERROR: ' || l_message
            );
--            AMS_Utility_PVT.error_message ( L_API_NAME || '- CONCURRENT REQUEST ERROR: ' || l_message);

            /* populate status to DRAFT */
            WF_ENGINE.SetItemAttrText(
                  itemtype    =>   itemtype
                , itemkey     =>   itemkey
                , aname       =>   'STATUS_CODE'
                , avalue      =>   G_STATUS_DRAFT
            );
            result := 'COMPLETE:FAILURE' ;
         END IF;
      ELSE
         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => l_object_type,
            p_log_used_by_id  => l_object_id,
            p_msg_data        => L_API_NAME || '- NO CONCURRENT REQUEST '
         );
--         AMS_Utility_PVT.error_message ( L_API_NAME || ' - NO CONCURRENT REQUEST');

         /* populate status to DRAFT */
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
         );
         result := 'COMPLETE:FAILURE' ;
      END IF; --      IF NVL(l_return_status,'N') = 'Y'
  --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Command',itemtype,itemkey,to_char(actid),funcmode);

      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;
END Command ;

-- Start of Comments
--
-- NAME
--   Check_response
--
-- PURPOSE
--   This Procedure will poll AQ to check whether there is any message
--   awaiting from Darwin after model is built/scored,
--   and will return:

--   ERROR (Successfully polled AQ with a message waiting, but the message is an Error message from mining application to build/score a model)
--   FAILURE (Failed to poll AQ for a message due to AQ system failure)
--   NO (Sucessfully polled AQ, but there are no messages waiting in the queue.)
--   YES (Sucessfully polled AQ with a message waiting, and also there are no errors from mining application (Darwin))

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - 'COMPLETE:YES' If there is message awaiting from Darwin about model building/scoring.
--             'COMPLETE:NO' If there is no message awaiting from Darwin about model building/scoring.
--             'COMPLETE:ERROR' If there is error message from Darwin'
--             'COMPLETE:FAILURE' If it could not poll aq due to aq system failure

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - CHECK_RESPONSE
--
-- NOTES
--
--
-- HISTORY
-- 11/30/2000     sveerave@us created
-- 03-Jul-2001    choang      Remove AQ dependency.
-- End of Comments

PROCEDURE Check_Response(  itemtype  IN   VARCHAR2
                         , itemkey   IN   VARCHAR2
                         , actid     IN   NUMBER
                         , funcmode  IN   VARCHAR2
                         , result    OUT NOCOPY   VARCHAR2
                        ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'CHECK_RESPONSE';

   l_object_id    NUMBER;
   l_object_type  VARCHAR2(30);
   l_request_type VARCHAR2(30);
   l_status          VARCHAR2(30);
   l_message         VARCHAR2(2000);
   l_model_type      VARCHAR2(30);

   -- Use l_return_status_log to get status
   -- for calls to create_log because the
   -- status codes that are used for workflow
   -- processing are different from those
   -- returned by the create_log api.
   l_return_status_log  VARCHAR2(1);
   l_return_status   VARCHAR2(1);

   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2 (2000);

BEGIN
/***
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);

   END IF;
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
      AMS_DM_AQ_PVT.dequeue_dm_response(
                                p_msg_for_object_id      => l_object_id
                              , p_msg_for_object_type    => l_object_type
                              , x_object_id              => l_object_id
                              , x_object_type            => l_object_type
                              , x_request_type           => l_request_type
                              , x_status                 => l_status
                              , x_message                => l_message
                              , x_return_status          => l_return_status
                              , x_msg_data               => l_msg_data
                             );
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RETURN_STATUS: ' || l_return_status);
      END IF;
      IF NVL(l_return_status,'E') = 'Y' THEN
         result := 'COMPLETE:YES' ;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message (L_API_NAME || ' - AQ MESG: ' || l_message);
         END IF;
      ELSIF NVL(l_return_status,'E') = 'N' THEN
         result := 'COMPLETE:NO' ;
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'AQ_ERR_MESSAGE'
               , avalue       =>    l_msg_data
               );
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'AQ_OPERATION'
               , avalue       =>    'Polling from Response'
               );
      ELSIF NVL(l_return_status,'E') = 'F' THEN
         result := 'COMPLETE:FAILURE' ;
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'RESP_ERR_MESSAGE'
               , avalue       =>    l_msg_data
               );
      ELSIF NVL(l_return_status,'E') = 'E' THEN
         result := 'COMPLETE:ERROR' ;
         WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'RESP_ERR_MESSAGE'
               , avalue       =>    l_message
               );
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
         );
         AMS_Utility_PVT.error_message ('AMS_DM_DDML_ERROR', 'ERROR_MESSAGE', l_message);
      END IF; --IF NVL(l_return_status,'E') = 'Y' THEN
   --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);

   END IF;

   write_buffer_to_log (l_object_type, l_object_id);
***/
   null;
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Check_Response',itemtype,itemkey,to_char(actid),funcmode);
      raise ;
END Check_Response ;

-- Start of Comments
--
-- NAME
--   Collect_Results
--
-- PURPOSE
--   This Procedure will collect results once the model is built or scored by Darwin, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:SUCCESS' If the collect results is successfully completed
--              - 'COMPLETE:FAILURE' If there is an error in collect results
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - COLLECT_RESULTS
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us	created
-- End of Comments

PROCEDURE Collect_Results(  itemtype  IN   VARCHAR2
                          , itemkey   IN   VARCHAR2
                          , actid     IN   NUMBER
                          , funcmode  IN   VARCHAR2
                          , result    OUT NOCOPY   VARCHAR2
                         )  IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'COLLECT_RESULTS';

   l_return_status VARCHAR2(1);

   l_object_id         NUMBER;
   l_object_type       VARCHAR2(30);
   l_api_version       NUMBER := 1.0;
   l_init_msg_list     VARCHAR2(1) := FND_API.g_true;
   l_commit            VARCHAR2(1) := FND_API.g_true;
   l_validation_level  NUMBER := 100;
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);
   l_message           VARCHAR2(4000);


BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': begin'
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN

      -- Call cleanup_odm_input_views to drop the input data Views
      -- and the synonyms created for them in the ODM schema
      AMS_DMSource_PVT.cleanup_odm_input_views(
			   p_object_type  => l_object_type,
			   p_object_id     => l_object_id
			   );

      IF l_object_type = G_OBJECT_TYPE_MODEL THEN
         result := 'COMPLETE:SUCCESS' ;
         /* populate status to AVAILABLE */
         WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_AVAILABLE
         );
      ELSIF l_object_type = G_OBJECT_TYPE_SCORE THEN
         AMS_DMSource_PVT.process_scores (
                    p_api_version       => l_api_version
                  , p_init_msg_list     => l_init_msg_list
                  , p_commit            => l_commit
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data          => l_msg_data
                  , p_score_id          => l_object_id
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            result := 'COMPLETE:FAILURE' ;

            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => l_object_type,
               p_log_used_by_id  => l_object_id,
               p_msg_data        => 'L_API_NAME:  AMS_DMSource_PVT.process_scores  Failed'
            );


            /* populate error message */
            WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'COLL_ERR_MESSAGE'
               , avalue       =>    l_msg_data
               );
            /* populate status to DRAFT */
            WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
            );

            write_buffer_to_log (l_object_type, l_object_id);
            RETURN;
         END IF;


         AMS_DMSource_PVT.bin_probability (
                    p_api_version       => l_api_version
                  , p_init_msg_list     => l_init_msg_list
                  , p_commit            => l_commit
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data          => l_msg_data
                  , p_score_id          => l_object_id
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            result := 'COMPLETE:FAILURE' ;

            /* populate error message */
            WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'COLL_ERR_MESSAGE'
               , avalue       =>    l_msg_data
               );
            /* populate status to DRAFT */
            WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
            );

            write_buffer_to_log (l_object_type, l_object_id);
            RETURN;
         END IF;

         AMS_Scoreresult_PVT.summarize_results (
                    p_api_version       => l_api_version
                  , p_init_msg_list     => l_init_msg_list
                  , p_commit            => l_commit
                  , x_return_status     => l_return_status
                  , x_msg_count         => l_msg_count
                  , x_msg_data          => l_msg_data
                  , p_score_id          => l_object_id
         );
         IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            result := 'COMPLETE:SUCCESS' ;
            /* populate status to COMPLETED */
            WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_COMPLETED
            );
         ELSE
            result := 'COMPLETE:FAILURE' ;

            /* populate error message */
            WF_ENGINE.SetItemAttrText(
                 itemtype     =>    itemtype
               , itemkey      =>    itemkey
               , aname        =>    'COLL_ERR_MESSAGE'
               , avalue       =>    l_msg_data
               );
            /* populate status to DRAFT */
            WF_ENGINE.SetItemAttrText(
               itemtype    =>   itemtype
             , itemkey     =>   itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
            );
         END IF; --IF (l_return_status = FND_API.G_RET_STS_SUCCESS)

         COMMIT;

      END IF; --IF l_object_type = G_OBJECT_TYPE_SCORE
   --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Collect_Results',itemtype,itemkey,to_char(actid),funcmode);

      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;
END Collect_Results ;

-- Start of Comments
--
-- NAME
--   Update_Obj_Status
--
-- PURPOSE
--   This Procedure will update object status to BUILDING or SCORING as per the object type
--   at the beginning. When error happens, it flips status to DRAFT, and succeeds, it flips status to
--   AVAILABLE

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - No Result

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - UPDATE_OBJ_STATUS
--
-- NOTES
--
--
-- HISTORY
--   02/28/2001        sveerave@uscreated
-- End of Comments

PROCEDURE Update_Obj_Status(  itemtype  IN   VARCHAR2
                            , itemkey   IN   VARCHAR2
                            , actid     IN   NUMBER
                            , funcmode  IN   VARCHAR2
                            , result    OUT NOCOPY   VARCHAR2
                           ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'UPDATE_OBJ_STATUS';

   l_object_id       NUMBER;
   l_object_type     VARCHAR2(30);
   l_object_status   VARCHAR2(30);
   l_message         VARCHAR2(2000);
   l_model_type      VARCHAR2(30);
   l_return_status   VARCHAR2(1);
   l_msg_data        VARCHAR2 (2000);

   l_request_type    VARCHAR2(30);

BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );
   l_request_type := WF_ENGINE.GetItemAttrText (
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'REQUEST_TYPE'
                              );

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': begin'
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
      l_object_status := WF_ENGINE.GetItemAttrText (
                                   itemtype   =>   itemtype
                                 , itemkey    =>   itemkey
                                 , aname      =>   'STATUS_CODE'
                                 );


      AMS_Utility_PVT.create_log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => l_object_type,
         p_log_used_by_id  => l_object_id,
         p_msg_data        => L_API_NAME || ': ' || l_object_status
      );

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message (L_API_NAME || ' - OBJECT_STATUS: ' || l_object_status);
      END IF;

      -- l_object_status is set to either DRAFT when preview process
      -- finishes or AVAILABLE when the build process is completed successfully
      -- or COMPLETED when scoring run completes successfully.
      IF l_object_status = G_STATUS_DRAFT OR l_object_status = G_STATUS_QUEUED THEN
         IF l_object_type = G_OBJECT_TYPE_MODEL THEN
            AMS_DM_Model_PVT.wf_revert (
               p_model_id        => l_object_id,
               p_status_code     => l_object_status,
               x_return_status   => l_return_status
            );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSE
            AMS_DM_Score_PVT.wf_revert (
               p_score_id        => l_object_id,
               p_status_code     => l_object_status,
               x_return_status   => l_return_status
            );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      ELSIF l_object_status = G_STATUS_AVAILABLE THEN
         AMS_DM_Model_PVT.process_build_success (
            p_model_id     => l_object_id,
            p_status_code  => l_object_status,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF l_object_status = G_STATUS_COMPLETED THEN
         AMS_DM_Score_PVT.process_score_success (
            p_score_id     => l_object_id,
            p_status_code  => l_object_status,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF l_object_status = G_STATUS_SCORING THEN
         AMS_DM_Score_PVT.wf_score (
            p_score_id     => l_object_id,
            x_status_code  => l_object_status,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         -- handle if l_status_code comes back as DRAFT
      ELSIF l_object_status = G_STATUS_BUILDING THEN
         AMS_DM_Model_PVT.wf_build (
            p_model_id        => l_object_id,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      result := 'COMPLETE' ;
   --  CANCEL mode  - Normal Process Execution
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

   AMS_Utility_PVT.create_log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => l_object_type,
      p_log_used_by_id  => l_object_id,
      p_msg_data        => L_API_NAME || ': end'
   );
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Update_Obj_Status',itemtype,itemkey,to_char(actid),funcmode);

      /* populate status to DRAFT */
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   itemtype
          , itemkey     =>   itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );
      result := 'COMPLETE:FAILURE' ;
END Update_Obj_Status ;


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


PROCEDURE write_buffer_to_log (
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER
)
IS
   l_return_status_log  VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);
BEGIN
   -- update the logs_flag in model/score table
   -- to Y.  don't increment version because this
   -- could happen often
   IF p_object_type = G_OBJECT_TYPE_MODEL THEN
      UPDATE ams_dm_models_all_b
      SET logs_flag = 'Y',
          last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.conc_login_id
      WHERE model_id = p_object_id
      AND   logs_flag = 'N';
   ELSE
      UPDATE ams_dm_scores_all_b
      SET logs_flag = 'Y',
          last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.conc_login_id
      WHERE score_id = p_object_id
      AND   logs_flag = 'N';
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   FOR i IN 1..FND_MSG_PUB.count_msg LOOP
      l_msg_data := FND_MSG_PUB.get(i, FND_API.G_FALSE);
      Ams_Utility_PVT.Create_Log (
           x_return_status   => l_return_status_log
         , p_arc_log_used_by => p_object_type
         , p_log_used_by_id  => p_object_id
         , p_msg_data        => l_msg_data
      );
   END LOOP;

   -- buffer has been written to log, clear
   -- buffer.
   FND_MSG_PUB.initialize;
END write_buffer_to_log;


--
-- Note
--
-- History
-- 30-Mar-2001 choang   Created.
--
PROCEDURE cancel_process (
   p_itemkey         VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'cancel_process';

   l_wf_result    VARCHAR2(30);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   WF_Engine.AbortProcess (
      itemtype => G_DEFAULT_ITEMTYPE,
      itemkey  => p_itemkey,
      result   => l_wf_result
   );
   -- no matter what the result returns
   -- the process should still get aborted
   -- so we can ignore the result.
   --COMMIT;
EXCEPTION
   WHEN OTHERS THEN
     -- Change by nyostos on Jan 6, 2003
     -- Commented the following line to ignore any errors when aborting the WF process
     -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --COMMIT;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
     END IF;
END cancel_process;


--
-- Note
--
-- History
-- 30-Mar-2001 choang   Created.
--
PROCEDURE change_schedule (
   p_itemkey         IN VARCHAR2,
   p_scheduled_date  IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   x_new_itemkey     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'change_schedule';

   l_system_scheduled_date    DATE;
   l_object_id                NUMBER;
   l_object_type              VARCHAR2(30);
   l_user_status_id           NUMBER;
   l_wf_result                VARCHAR2(30);

   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- after copying all the process attributes,
   -- cancel the current process and create a
   -- new one.
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                     itemtype    => G_DEFAULT_ITEMTYPE
                     , itemkey   => p_itemkey
                     , aname     => 'OBJECT_ID'
                  );
   l_object_type := WF_ENGINE.GetItemAttrText (
                       itemtype  => G_DEFAULT_ITEMTYPE
                       , itemkey => p_itemkey
                       , aname   => 'OBJECT_TYPE'
                    );
   l_user_status_id := WF_ENGINE.GetItemAttrNumber(
                     itemtype    => G_DEFAULT_ITEMTYPE
                     , itemkey   => p_itemkey
                     , aname     => 'ORIG_USER_STATUS_ID'
                  );

   AMS_Utility_PVT.convert_timezone (
      p_init_msg_list   => FND_API.G_FALSE,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_user_tz_id      => p_scheduled_timezone_id,
      p_in_time         => p_scheduled_date,
      p_convert_type    => 'SYS',
      x_out_time        => l_system_scheduled_date
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- abort the current process
   WF_Engine.AbortProcess (
      itemtype => G_DEFAULT_ITEMTYPE,
      itemkey  => p_itemkey,
      result   => l_wf_result
   );

   -- create a new process with new schedule date
   AMS_WFMOD_PVT.StartProcess(
      p_object_id       => l_object_id,
      p_object_type     => l_object_type,
      p_user_status_id  => l_user_status_id,
      p_scheduled_timezone_id => p_scheduled_timezone_id,
      p_scheduled_date  => l_system_scheduled_date,
      p_request_type    => NULL,
      p_select_list     => NULL,
      x_itemkey         => x_new_itemkey
   );

   --COMMIT;  -- otherwise, WF engine does not get this
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
     END IF;
END change_schedule;


--
-- Note
--    The current data mining configuration can only handle either
--    one model building process and one scoring process at a given
--    time.  If a model build is requested and there is already a
--    model building process running, then block the request and
--    queue it up.  Same thing with scoring run requests.
--    16-Sep-2003 nyostos: multiple -non-conflicting- mining operations
--    can now proceed at the same time.
--
-- History
-- 12-Jul-2001 choang   Created.
-- 27-Sep-2002 nyostos  Changed logic to handle PREVIEWING state.
-- 16-Sep-2003 nyostos  Allow Parallel Mining Operations.
PROCEDURE validate_concurrency (
   p_itemtype  IN VARCHAR2,
   p_itemkey   IN VARCHAR2,
   p_actid     IN NUMBER,
   p_funcmode  IN VARCHAR2,
   x_result    OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'validate_concurrency';
   L_MINUTE             CONSTANT NUMBER := 1/(24*60);

   l_object_type        VARCHAR2(30);
   l_object_id          NUMBER;
   l_model_wf_itemkey   VARCHAR2(30);
   l_score_wf_itemkey   VARCHAR2(30);
   l_temp_wf_itemkey    VARCHAR2(30);
   l_next_date          DATE := SYSDATE + L_MINUTE;

   l_request_type       VARCHAR2(30);
   l_preview_status     VARCHAR2(30);
   l_return_status      VARCHAR2(1);

   -- Cursor to get the wf_itemkey for a Model that is Building, Scoring or Previewing,
   -- excluding the current wf_itemkey
   CURSOR c_modelProcessing IS
      SELECT wf_itemkey
      FROM   ams_dm_models_all_b
      WHERE  status_code = G_STATUS_BUILDING
         OR  status_code = G_STATUS_SCORING
         OR  status_code = G_STATUS_PREVIEWING
        AND  wf_itemkey <> p_itemkey;

   -- Cursor to get the wf_itemkey for a Scoring Run that is Building, Scoring or Previewing
   -- excluding the current wf_itemkey
   CURSOR c_scoreProcessing IS
      SELECT wf_itemkey
      FROM   ams_dm_scores_all_b
      WHERE  status_code = G_STATUS_SCORING
         OR  status_code = G_STATUS_PREVIEWING
        AND  wf_itemkey <> p_itemkey;

BEGIN
   -- initialize the result to allow the model/score
   -- request to pass.
   x_result := 'COMPLETE:T';

   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype  => p_itemtype
                              , itemkey   => p_itemkey
                              , aname     => 'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype  => p_itemtype
                              , itemkey   => p_itemkey
                              , aname     => 'OBJECT_TYPE'
                              );

   -- REQUEST_TYPE will be set to PREVIEW if the WF Process is handling
   -- a Preview request. It will be blank if a Build/Score is requested.
   -- REQUEST_TYPE will be set to PREVIEW_STARTED if the Preview request
   -- is going to execute the aggregate_soruces step.
   l_request_type := WF_ENGINE.GetItemAttrText (
                                itemtype  => p_itemtype
                              , itemkey   => p_itemkey
                              , aname     => 'REQUEST_TYPE'
                              );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE:     ' || p_funcmode);
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - REQUEST_TYPE: ' || l_request_type);
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - itemkey: '      || p_itemkey);
   END IF;

   IF (p_funcmode = 'RUN') THEN

      -- Get the wf_itemkey for the Model that is currently Building/Scoring/Previewing, if any.
      --OPEN  c_modelProcessing;
      --FETCH c_modelProcessing INTO l_model_wf_itemkey;
      --CLOSE c_modelProcessing;

      -- Get the wf_itemkey for the Scoring Run that is currently Scoring/Previewing, if any.
      --OPEN  c_scoreProcessing;
      --FETCH c_scoreProcessing INTO l_score_wf_itemkey;
      --CLOSE c_scoreProcessing;

      -- If there is a Model or Scoring Run that is in progress.
      --IF (l_model_wf_itemkey IS NOT NULL)  OR (l_score_wf_itemkey IS NOT NULL) THEN

      --   IF (AMS_DEBUG_HIGH_ON) THEN
      --      AMS_Utility_PVT.debug_message (L_API_NAME || ': ' || ' Other Model/Score in Progress');
      --   END IF;

      --   IF l_model_wf_itemkey IS NOT NULL THEN
      --      l_temp_wf_itemkey := l_model_wf_itemkey;
      --   ELSE
      --      l_temp_wf_itemkey := l_score_wf_itemkey;
      --   END IF;

      --   IF (AMS_DEBUG_HIGH_ON) THEN
      --      AMS_Utility_PVT.debug_message (L_API_NAME || ': ' || ' Other Model/Score wf_itemkey: ' || l_temp_wf_itemkey);
      --   END IF;

         -- If we are handling a Preview request, then check if the other Model/Scoring Run
         -- in progress has finished the aggregate_sources step.
      --   IF l_request_type = G_PREVIEW_REQUEST THEN
      --      l_preview_status := WF_ENGINE.GetItemAttrText (
      --                                          itemtype  => p_itemtype
      --                                        , itemkey   => l_temp_wf_itemkey
      --                                        , aname     => 'REQUEST_TYPE'
      --                                        );
      --      IF (AMS_DEBUG_HIGH_ON) THEN
      --         AMS_Utility_PVT.debug_message(L_API_NAME || ': ' || ' l_preview_status (' || l_preview_status || ')');
      --      END IF;

            --IF l_preview_status = G_PREVIEW_STARTED OR l_preview_status = '' OR l_preview_status IS NULL THEN
               -- The other model/scoring run has not yet finished the aggregate_sources step,
               -- so return false and keep the status unchanged at previewing.
              --x_result := 'COMPLETE:F';
            --END IF;
          --ELSE
            -- For model build/score request, return false and set the status to QUEUED
            --x_result := 'COMPLETE:F';

            --WF_ENGINE.SetItemAttrText (
            --     itemtype  => p_itemtype
            --   , itemkey   => p_itemkey
            --   , aname     => 'STATUS_CODE'
            --   , avalue    => G_STATUS_QUEUED
            --);
        --  END IF;

        --  WF_ENGINE.SetItemAttrDate (
        --      itemtype  => p_itemtype
        --    , itemkey   => p_itemkey
        --    , aname     => 'NEXT_QUEUE_CHECK'
        --    , avalue    => l_next_date
        -- );

        -- IF (AMS_DEBUG_HIGH_ON) THEN
        --   AMS_Utility_PVT.debug_message (L_API_NAME || ': ' || ' l_next_date ' || l_next_date);
        -- END IF;

      --ELSE
         -- No Model/Scoring Run in progress.
         -- For Model, set status to BUILDING if we are not performing a Preview operation
         IF l_request_type <> G_PREVIEW_REQUEST THEN
            IF l_object_type = G_OBJECT_TYPE_MODEL THEN
               WF_ENGINE.SetItemAttrText (
                    itemtype  => p_itemtype
                  , itemkey   => p_itemkey
                  , aname     => 'STATUS_CODE'
                  , avalue    => G_STATUS_BUILDING
               );
            -- For Scoring Run, set status to SCORING if we are not performing a Preview operation
            ELSIF l_object_type = G_OBJECT_TYPE_SCORE THEN
               WF_ENGINE.SetItemAttrText (
                    itemtype  => p_itemtype
                  , itemkey   => p_itemkey
                  , aname     => 'STATUS_CODE'
                  , avalue    => G_STATUS_SCORING
               );
            END IF;
         END IF;    -- If not previewing  (i.e if building/scoring)
      --END IF;
   ELSIF (p_funcmode = 'CANCEL') THEN
      x_result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (p_funcmode = 'TIMEOUT') THEN
      x_result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      x_result := '';
   END IF;  -- funcmode

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || x_result);
   END IF;

   COMMIT;  -- otherwise, the changes don't reflect in UI

   write_buffer_to_log (l_object_type, l_object_id);
EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME, 'validate_concurrency', p_itemtype, p_itemkey, TO_CHAR(p_actid), p_funcmode);
      raise ;
END validate_concurrency;


-- Start of Comments
--
-- NAME
--   Reset_Status
--
-- PURPOSE
--   This Procedure will reset the object status back to DRAFT regardless
--   of what status it is currently in.

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - No Result

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - RESET_STATUS
--
-- NOTES
--
--
-- HISTORY
--   08/28/2002        nyostos created
-- End of Comments

PROCEDURE Reset_Status(  p_itemtype  IN   VARCHAR2
                       , p_itemkey   IN   VARCHAR2
                       , p_actid     IN   NUMBER
                       , p_funcmode  IN   VARCHAR2
                       , x_result    OUT NOCOPY  VARCHAR2
                       ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'RESET_STATUS';

   l_object_id    NUMBER;
   l_object_type  VARCHAR2(30);
   l_return_status   VARCHAR2(1);

BEGIN
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    p_itemtype
                              , itemkey      =>    p_itemkey
                              , aname        =>    'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   p_itemtype
                              , itemkey    =>   p_itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' BEGIN - FUNCMODE: ' || p_funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (p_funcmode = 'RUN') THEN

      -- nyostos 09/17/2002 - Reset status to FAILED instead of DRAFT
      -- Set status to FAILED for the model or scoring run
      IF l_object_type = G_OBJECT_TYPE_MODEL THEN
         AMS_DM_Model_PVT.wf_revert (
            p_model_id        => l_object_id,
            p_status_code     => G_STATUS_FAILED,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         AMS_DM_Score_PVT.wf_revert (
            p_score_id        => l_object_id,
            p_status_code     => G_STATUS_FAILED,
            x_return_status   => l_return_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- nyostos 09/17/2002 - Set STATUS_CODE Workflow global variable to FAILED instead of DRAFT
      -- Set STATUS_CODE Workflow global variable to FAILED
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   p_itemtype
          , itemkey     =>   p_itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_FAILED
      );

      x_result := 'COMPLETE' ;
   --  CANCEL mode  - Normal Process Execution
   ELSIF (p_funcmode = 'CANCEL') THEN
      x_result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (p_funcmode = 'TIMEOUT') THEN
      x_result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      x_result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' END - RESULT: ' || x_result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME, 'Reset_Status', p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);

      -- nyostos 09/17/2002 - Set STATUS_CODE Workflow global variable to FAILED instead of DRAFT
      -- Set STATUS_CODE Workflow global variable to FAILED
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   p_itemtype
          , itemkey     =>   p_itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_FAILED
      );
      x_result := 'COMPLETE:FAILURE' ;
END Reset_Status ;



-- Start of Comments
--
-- NAME
--   Is_Previewing
--
-- PURPOSE
--   This Procedure will be called after the aggregate sources is done. If the WF process has been
--   started to Preview data selections, the Model/Scoring Run status will be set to DRAFT and this
--   procedure will return True so that the WF Process ends. If the WF Process was started to perform a Build
--   or Score then the procedure will return F, so that the next step in the process proceeds.
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If Previewing
--              - 'COMPLETE:F' Otherwise
--
--
-- NOTES
--
--
-- HISTORY
-- 20-Sep-2002    nyostos     Created.
-- End of Comments

PROCEDURE Is_Previewing (  p_itemtype  IN     VARCHAR2
                         , p_itemkey   IN     VARCHAR2
                         , p_actid     IN     NUMBER
                         , p_funcmode  IN     VARCHAR2
                         , x_result    OUT NOCOPY   VARCHAR2
                         ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'IS_PREVIEWING';

   l_request_type    VARCHAR2(30);
   l_object_id       NUMBER;
   l_object_type     VARCHAR2(30);
   l_return_status   VARCHAR2(1);

BEGIN
   -- initialize the result
   x_result := 'COMPLETE:T';

   l_request_type := WF_ENGINE.GetItemAttrText(
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'REQUEST_TYPE'
                              );
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'OBJECT_TYPE'
                              );



   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' BEGIN - FUNCMODE: ' || p_funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (p_funcmode = 'RUN') THEN

      -- If the WF Process was started to Preview Data Selections, then set the
      -- STATUS_CODE attribute to DRAFT as the Preview Data Selections has
      -- finished successfully.
      IF l_request_type = G_PREVIEW_REQUEST OR l_request_type = G_PREVIEW_STARTED THEN

         -- Set STATUS_CODE attribute to DRAFT
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   p_itemtype
             , itemkey     =>   p_itemkey
             , aname       =>   'STATUS_CODE'
             , avalue      =>   G_STATUS_DRAFT
         );
      ELSE
         -- WF Process was started to Build/Score so return False
         x_result := 'COMPLETE:F' ;

         -- Set REQUEST_TYPE attribute to PREVIEW_COMPLETE
         WF_ENGINE.SetItemAttrText(
               itemtype    =>   p_itemtype
             , itemkey     =>   p_itemkey
             , aname       =>   'REQUEST_TYPE'
             , avalue      =>   G_PREVIEW_COMPLETE
         );
      END IF;
   --  CANCEL mode  - Normal Process Execution
   ELSIF (p_funcmode = 'CANCEL') THEN
      x_result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (p_funcmode = 'TIMEOUT') THEN
      x_result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      x_result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' END - RESULT: ' || x_result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;


      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'Is_Previewing', p_itemtype, p_itemkey,to_char(p_actid), p_funcmode);

      -- Set STATUS_CODE attribute to DRAFT
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   p_itemtype
          , itemkey     =>   p_itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );

      x_result := 'COMPLETE:FAILURE' ;


END Is_Previewing ;


--
-- Purpose
--    Returns the value of a the Model/Scoring Run original status for
--    a specific workflow process identified by p_itemkey
--
-- Parameters
--    p_itemkey            - the WF itemkey identifying the instance of the process.
--    x_orig_status_id     - original status id of the Model/Scoring Run
--    x_return_status      - standard output indicating the completion status
--
PROCEDURE get_original_status (
   p_itemkey            VARCHAR2,
   x_orig_status_id     OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_orig_status_id     NUMBER;


BEGIN


   l_orig_status_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     => G_DEFAULT_ITEMTYPE
                              , itemkey      => p_itemkey
                              , aname        => 'ORIG_USER_STATUS_ID'
                              );

   x_orig_status_id := l_orig_status_id;

END get_original_status;

-- Start of Comments
--
-- NAME
--   ok_to_proceed
--
-- PURPOSE
--   This Procedure will make final errors checks before the Build, Score or Preivew proceeds.
--   For Scoring Run, we check that the Model has not become INVALID.
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If ok to proceed
--              - 'COMPLETE:F' Otherwise
--
--
-- NOTES
--
--
-- HISTORY
-- 08-Oct-2002    nyostos     Created.
-- End of Comments

PROCEDURE ok_to_proceed (  p_itemtype  IN     VARCHAR2
                         , p_itemkey   IN     VARCHAR2
                         , p_actid     IN     NUMBER
                         , p_funcmode  IN     VARCHAR2
                         , x_result    OUT NOCOPY   VARCHAR2
                         ) IS
   L_API_NAME     CONSTANT VARCHAR2(30) := 'OK_TO_PROCEED';

   l_request_type    VARCHAR2(30);
   l_object_id       NUMBER;
   l_object_type     VARCHAR2(30);
   l_return_status   VARCHAR2(1);
   l_model_status    VARCHAR2(30);
   l_target_id       NUMBER;
   l_is_enabled      BOOLEAN;

   CURSOR c_target_id_model (p_model_id IN NUMBER) IS
      SELECT target_id
      FROM   ams_dm_models_all_b
      WHERE  model_id = p_model_id
      ;

   CURSOR c_target_id_score (p_score_id IN NUMBER) IS
      SELECT m.target_id
      FROM   ams_dm_models_all_b m , ams_dm_scores_all_b s
      WHERE  m.model_id = s.model_id
      AND    s.score_id = p_score_id
      ;

BEGIN
   -- initialize the result
   x_result := 'COMPLETE:T';

   l_request_type := WF_ENGINE.GetItemAttrText(
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'REQUEST_TYPE'
                              );
   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'OBJECT_ID'
                              );
   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>  p_itemtype
                              , itemkey    =>  p_itemkey
                              , aname      =>  'OBJECT_TYPE'
                              );



   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' BEGIN - FUNCMODE: ' || p_funcmode);
   END IF;

   --  RUN mode  - Normal Process Execution
   IF (p_funcmode = 'RUN') THEN

      -- First check if the target has not been disabled
      IF l_object_type = G_OBJECT_TYPE_SCORE THEN
         OPEN c_target_id_score(l_object_id);
	 FETCH c_target_id_score INTO l_target_id;
	 CLOSE c_target_id_score;
      ELSE
         OPEN c_target_id_model(l_object_id);
	 FETCH c_target_id_model INTO l_target_id;
	 CLOSE c_target_id_model;
      END IF;

      AMS_DM_TARGET_PVT.is_target_enabled(
	   p_target_id  => l_target_id ,
	   x_is_enabled => l_is_enabled
	   );
      IF l_is_enabled = FALSE THEN
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' ERROR: Target is disabled, cannot preview/build/score');
	 END IF;
         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => l_object_type,
            p_log_used_by_id  => l_object_id,
            p_msg_data        => L_API_NAME || ' ERROR: Target is disabled, cannot preview/build/score '
         );
	 x_result := 'COMPLETE:F' ;
      END IF;


      -- If the WF Process was started to Score, then check if the Model has
      -- not become INVALID
      IF x_result <> 'COMPLETE:F' AND l_request_type <> G_PREVIEW_REQUEST AND l_object_type = G_OBJECT_TYPE_SCORE THEN
         AMS_DM_Score_PVT.wf_checkModelStatus (
            p_score_id        => l_object_id,
            x_return_status   => l_return_status,
            x_model_status    => l_model_status
         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            AMS_Utility_PVT.create_log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => 'SCOR',
               p_log_used_by_id  => l_object_id,
               p_msg_data        => L_API_NAME || ' ERROR: Model Status is ' || l_model_status
            );
            x_result := 'COMPLETE:F' ;
        END IF;
      ELSIF x_result <> 'COMPLETE:F' AND l_request_type = G_PREVIEW_REQUEST THEN
         -- Set the Request type to PREVIEW_STARTED. This will be checked by other
         -- Preview requests when validating concurrency to resolve any potential deadlock
         WF_ENGINE.SetItemAttrText (
                          itemtype   =>  p_itemtype
                        , itemkey    =>  p_itemkey
                        , aname      =>  'REQUEST_TYPE'
                        , avalue     =>  G_PREVIEW_STARTED
                        );
      END IF;
   --  CANCEL mode  - Normal Process Execution
   ELSIF (p_funcmode = 'CANCEL') THEN
      x_result := 'COMPLETE' ;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (p_funcmode = 'TIMEOUT') THEN
      x_result := 'COMPLETE' ;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   ELSE
      x_result := '';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (L_API_NAME || ' END - RESULT: ' || x_result);
   END IF;

   write_buffer_to_log (l_object_type, l_object_id);

EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      write_buffer_to_log (l_object_type, l_object_id);

      wf_core.context(G_PKG_NAME,'ok_to_proceed', p_itemtype, p_itemkey,to_char(p_actid), p_funcmode);

      -- Set STATUS_CODE attribute to DRAFT
      WF_ENGINE.SetItemAttrText(
            itemtype    =>   p_itemtype
          , itemkey     =>   p_itemkey
          , aname       =>   'STATUS_CODE'
          , avalue      =>   G_STATUS_DRAFT
      );

      x_result := 'COMPLETE:FAILURE' ;
END ok_to_proceed;


END AMS_WFMOD_PVT;

/
