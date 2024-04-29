--------------------------------------------------------
--  DDL for Package Body AMS_TRIGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRIGGER_PVT" as
/* $Header: amsvtgrb.pls 120.2 2006/02/21 22:25:34 srivikri ship $*/

--
-- NAME
--   AMS_Trigger_PVT
--
-- PURPOSE
--   This package is a wrapper package which calls all the Trigger APIs inside it.
--   It also gives call to Trigger Engine to start the Process
--
-- HISTORY
--   12/27/1999        ptendulk    CREATED
--   02/25/2000        ptendulk    Modified - Added the Workflow process calls
--   10/28/2000        ptendulk    Added user id in the start process call
--   04/04/2001        soagrawa    Modified Create_Trigger to create trigger instead of
--                                 just updating it
--   02/17/2006        srivikri    Added procedure activate_trigger

--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_Trigger_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvtgrb.pls';


-- Debug mode
-- g_debug boolean := FALSE;
-- g_debug boolean := TRUE;

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------------------------------- Triggers --------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

/***************************  PRIVATE ROUTINES  *********************************/

-- Start of Comments
--
-- NAME
--   Create_Trigger
--
-- PURPOSE
--   This procedure is to create a row in ams_triggers,ams_trigger_checks,ams_trigger_actions
--   table that satisfy caller needs
--
-- NOTES
--   As soon as the Trigger is created Start the Workflow Process
--
-- HISTORY
--   07/26/1999        ptendulk        Created
--    10/25/1999       ptendulk       Modified according to new standards
--   01/11/2000        ptendulk        Modified API calls , Send p_commit = False
--                                     to API calls
--   02/25/2000        ptendulk        Modified - Added the Workflow process calls
--  15-Feb-2001        ptendulk        Modified 1. trigger action table won't be used since Hornet
--                                     2. Check will be mandatory so removed p_create_type para.
--                                     3. Commented workflow call.
--   04/04/2001        soagrawa        Now calling create_trigger instead of update_trigger.
--                                     Also, the API now returns trigger_id  of the trigger created
--   13/jun/03         cgoyal          modified create trigger method to create a row in the table
--                                     ams_trigger_actions for 11.5.8 backport
-- End of Comments

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

--  p_create_type              IN     VARCHAR2    := 'ALL'  ,
  p_trig_Rec                 IN     Ams_Trig_pvt.trig_rec_type,
  p_thldchk_rec              IN     Ams_Thldchk_pvt.thldchk_rec_type DEFAULT NULL,
  p_thldact_rec              IN     Ams_Thldact_pvt.thldact_rec_type ,

  x_trigger_check_id         OUT NOCOPY    NUMBER,
  x_trigger_action_id        OUT NOCOPY    NUMBER,
  x_trigger_id                OUT NOCOPY     NUMBER
) IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Create_Trigger';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status          VARCHAR2(1);  -- Return value from procedures
   l_thldchk_rec     Ams_Thldchk_pvt.thldchk_rec_type := p_thldchk_rec;
   l_thldact_rec     Ams_Thldact_pvt.thldact_rec_type := p_thldact_rec;
   -- soagrawa 30-apr-2003 added for action for execution
   l_thldact_exec_rec     Ams_Thldact_pvt.thldact_rec_type ;

   -- soagrawa 05-may-2003
   l_parameter_list  WF_PARAMETER_LIST_T;
   l_new_item_key    VARCHAR2(30);

   -- soagrawa added on 09-jul-2003 for bug 3043277
   CURSOR c_st_dt (p_trigger_id NUMBER) IS
   SELECT start_date_time
     FROM ams_triggers
    WHERE trigger_id = p_trigger_id;

   l_st_dt DATE;

  BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_Trig_PVT;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   --
   -- Perform the database operation Here Update Trigger is called as Trigger is already
   -- created in Overview Screen
   --

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': Update Trigger');

   END IF;


   AMS_TRIG_PVT.Create_Trigger
        ( p_api_version         => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_commit             => FND_API.G_FALSE,
          p_validation_level    => p_validation_level,

          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,

          p_trig_rec            => p_trig_rec,
          x_trigger_id          => x_trigger_id
            ) ;

   --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --IF (p_create_type = 'CREATE')  THEN
   --
   -- Create Check
   --


   l_thldchk_rec.trigger_id := x_trigger_id;
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||'CG : Create Trigger Check' || 'Trigger type = ' || p_trig_rec.triggering_type);
   END IF;

   IF ( p_trig_rec.triggering_type <> 'DATE' ) THEN
   AMS_THLDCHK_PVT.Create_thldchk
          ( p_api_version          => l_api_version,
            p_init_msg_list        => p_init_msg_list,
            p_commit              => FND_API.G_FALSE,
            p_validation_level     => p_validation_level,
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_thldchk_Rec          => l_thldchk_rec,
            x_trigger_check_id    => x_trigger_check_id
              )   ;
   --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   END IF;

   --
   -- Perform the database operation
   --

   --=================================================================================
   -- 22/apr/03 cgoyal uncommented the Create Trigger Actions code for 11.5.8 backport
   --=================================================================================

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': Create Trigger Actions');
   END IF;

   IF (p_trig_Rec.notify_flag = 'Y')
   THEN
      l_thldact_rec.trigger_id := x_trigger_id;
      l_thldact_rec.trigger_action_id := null;
      -- soagrawa 30-apr-2003
      l_thldact_rec.execute_action_type := 'NOTIFY';
      AMS_THLDACT_PVT.Create_thldact
             ( p_api_version          => l_api_version,
               p_init_msg_list        => p_init_msg_list,
               p_commit               => FND_API.G_FALSE,
               p_validation_level     => p_validation_level,
               x_return_status        => l_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data,
               p_thldact_Rec          => l_thldact_rec,
               x_trigger_action_id    => x_trigger_action_id
              );
      --
      -- If any errors happen abort API.
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- soagrawa 30-apr-2003 added for action for execute associated schedules
   IF (p_trig_Rec.EXECUTE_SCHEDULE_FLAG = 'Y')
   THEN
      l_thldact_exec_rec.trigger_id := x_trigger_id;
      l_thldact_exec_rec.execute_action_type := 'EXECUTE';
      AMS_THLDACT_PVT.Create_thldact
             ( p_api_version          => l_api_version,
               p_init_msg_list        => p_init_msg_list,
               p_commit               => FND_API.G_FALSE,
               p_validation_level     => p_validation_level,
               x_return_status        => l_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data,
               p_thldact_Rec          => l_thldact_exec_rec,
               x_trigger_action_id    => x_trigger_action_id
              );
   --
   -- If any errors happen abort API.
   --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   --
   -- Give Call to Trigger Engine here
   --
   --=====================================================================
   -- Following code is modified by ptendulk on 28-Oct-2000
   -- User id is added in the procedure
   --=====================================================================
   --ams_wfcamp_pvt.StartProcess( p_trigger_id => p_trig_rec.trigger_id,
   --                              p_user_id    => FND_GLOBAL.user_id );

   -- soagrawa 05-may-2003
   -- raise an event with send date as the trigger start date

   l_parameter_list := WF_PARAMETER_LIST_T();

   AMS_Utility_PVT.debug_message(l_full_name ||': before calling initialize var');

--   AMS_WFTrig_PVT.Initialize_Var( p_trigger_id => x_trigger_id
--                             , x_param_list => l_parameter_list);

/* srivikri - start commenting workflow
   wf_event.AddParameterToList(p_name => 'AMS_TRIGGER_ID',
                                   p_value => x_trigger_id,
                                   p_parameterlist => l_parameter_list);

   AMS_Utility_PVT.debug_message(l_full_name ||': after calling initialize var');

  l_new_item_key := x_trigger_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

   -- soagrawa added on 09-jul-2003 for bug 3043277
   OPEN  c_st_dt(x_trigger_id);
   FETCH c_st_dt INTO l_st_dt;
   CLOSE c_st_dt;

    AMS_Utility_PVT.Create_Log (
            x_return_status   => x_msg_data,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => x_trigger_id,
            -- soagrawa modified on 09-jul-2003 for bug 3043277
            -- p_msg_data        => 'Create_Trigger :  1. For Trigger ID = ' || x_trigger_id || ' l_new_item_key = ' || l_new_item_key || 'event send date ' || p_trig_rec.start_date_time,
            p_msg_data        => 'Create_Trigger :  1. For Trigger ID = ' || x_trigger_id || ' l_new_item_key = ' || l_new_item_key || 'event send date ' || l_st_dt,
            p_msg_type        => 'DEBUG'
            );

   Wf_Event.Raise
   ( p_event_name   =>  'oracle.apps.ams.trigger.TriggerEvent',
     p_event_key    =>  l_new_item_key,
     p_parameters   =>  l_parameter_list,
     -- soagrawa modified on 09-jul-2003 for bug 3043277
     -- p_send_date    =>  p_trig_rec.start_date_time);
     p_send_date    =>  l_st_dt);

   AMS_Utility_PVT.debug_message(l_full_name ||': raised WF event');

    AMS_Utility_PVT.Create_Log (
            x_return_status   => x_msg_data,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => x_trigger_id,
            -- soagrawa modified on 09-jul-2003 for bug 3043277
            -- p_msg_data        => 'Create_Trigger :  raised with send date '||to_char(p_trig_rec.start_date_time,'DD-MM-YYYY HH:MI:SS AM'),
            p_msg_data        => 'Create_Trigger :  raised with send date '||to_char(l_st_dt,'DD-MM-YYYY HH:MI:SS AM'),
            p_msg_type        => 'DEBUG'
            );

   UPDATE ams_triggers
      SET process_id = to_number(l_new_item_key)
    WHERE trigger_id = x_trigger_id;

srivikri - end comment*/

   --
   -- END of API body.
   --

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );
END Create_Trigger;


-- Start of Comments
--
-- NAME
--   Update_Trigger
--
-- PURPOSE
--   This procedure is to update a ams_triggers,ams_trigger_checks,ams_trigger_actions table
--   that satisfy caller needs . It will also Call the Cancel Workflow Process
--
-- NOTES
--   As soon as the Trigger is modied Abort the Workflow Process and Submit the new one
--
-- HISTORY
--   12/27/1999        ptendulk    created
--   02/25/2000        ptendulk    Modified - Added the Workflow Process Calls
--   10/28/2000        ptendulk    Added user id in the start process call
--  15-Feb-2001        ptendulk    Modified 1. trigger action table won't be used since Hornet
--                                 2. Check will be mandatory so removed p_create_type para.
--                                 3. Commented workflow call to abort and start.
--   22/apr/03         cgoyal      modified update trigger method to update the table
--                                 ams_trigger_actions for 11.5.8 backport
-- End of Comments

PROCEDURE Update_Trigger
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit              IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_trig_rec            IN     Ams_Trig_pvt.trig_rec_type,
  p_thldchk_rec         IN     Ams_Thldchk_pvt.thldchk_rec_type DEFAULT NULL,
  p_thldact_rec         IN     Ams_Thldact_pvt.thldact_rec_type
--  p_updt_type           IN     VARCHAR2

) IS

   l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Trigger';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_trigger_check_id  NUMBER ;
   -- Status Local Variables
   l_return_status      VARCHAR2(1);  -- Return value from procedures
   l_trigger_process_id  NUMBER ;

   CURSOR c_trig_process_id (l_my_trig_id IN number) IS
   SELECT process_id
   FROM ams_triggers
   WHERE trigger_id = l_my_trig_id;

   CURSOR c_trig_actions_det (l_my_trig_id IN number) IS
   SELECT notify_flag, EXECUTE_SCHEDULE_FLAG
   FROM ams_triggers
   WHERE trigger_id = l_my_trig_id;

   CURSOR c_actions_det (p_my_trig_id IN number, p_action_type IN VARCHAR2) IS
   SELECT trigger_action_id, object_version_number
   FROM ams_trigger_Actions
   WHERE trigger_id = p_my_trig_id
   AND   execute_Action_type = p_action_type;

   l_notify_flag            VARCHAR2(1);
   l_execute_schedule_flag  VARCHAR2(1);
   l_thldact_rec            Ams_Thldact_pvt.thldact_rec_type := p_thldact_rec;
   l_thldact_exec_rec       Ams_Thldact_pvt.thldact_rec_type ;
   l_trig_action_id         NUMBER;
   l_object_version_number  NUMBER;
   l_trigger_action_id      NUMBER;
   l_thldchk_rec            Ams_Thldchk_pvt.thldchk_rec_type:= p_thldchk_rec;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Update_Trig_PVT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
/*
IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': Update Trigger');
   END IF;
   -- following code added by soagrawa for update modification on 04/18/2001
   OPEN c_trig_process_id(p_trig_rec.trigger_id);
   FETCH c_trig_process_id INTO l_trigger_process_id;
   CLOSE c_trig_process_id;
   AMS_TRIG_PVT.Update_Trigger
      ( p_api_version         => l_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => p_validation_level,
        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_trig_rec            => p_trig_rec
          ) ;
    --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --IF (p_updt_type = 'UPDATE' ) THEN
   --
   -- Perform the database operation
   --
*/

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': Create Trigger Check');
   END IF;

   IF ( p_trig_rec.triggering_type <> 'DATE' )
   THEN
      l_thldchk_rec.trigger_id := p_trig_rec.trigger_id;
      AMS_THLDCHK_PVT.Update_Thldchk
         ( p_api_version         => l_api_version,
         p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => p_validation_level,
           x_return_status       => l_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
         p_thldchk_rec         => l_thldchk_rec
               ) ;
   END IF;

      --
      -- If any errors happen abort API.
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   --ELSIF (p_updt_type = 'CREATE' ) THEN
   --   AMS_THLDCHK_PVT.Create_thldchk
   --       ( p_api_version          => l_api_version,
   --         p_init_msg_list        => p_init_msg_list,
   --         p_commit              => FND_API.G_FALSE,
   --         p_validation_level     => p_validation_level,
   --         x_return_status        => l_return_status,
   --         x_msg_count            => x_msg_count,
   --         x_msg_data             => x_msg_data,

   --         p_thldchk_Rec          => p_thldchk_rec,
   --         x_trigger_check_id    => l_trigger_check_id
   --           )   ;
   --    --
   --   -- If any errors happen abort API.
   --   --
   --   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
   --      RAISE FND_API.G_EXC_ERROR;
   --   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   --      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   --   END IF;

   --ELSIF (p_updt_type = 'DELETE' ) THEN
   --   AMS_THLDCHK_PVT.Delete_thldchk
   --       ( p_api_version          => l_api_version,
   --         p_init_msg_list        => p_init_msg_list,
   --         p_commit              => FND_API.G_FALSE,

   --         x_return_status        => l_return_status,
   --         x_msg_count            => x_msg_count,
   --         x_msg_data             => x_msg_data,

   --         p_trigger_check_id          => p_thldchk_rec.trigger_check_id,
   --         p_object_version_number    => p_thldchk_rec.object_version_number
   --           )   ;

   --
   -- If any errors happen abort API.
   --
   --  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
   --     RAISE FND_API.G_EXC_ERROR;
   --   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   --  END IF;
   -- END IF ;

   --
   -- Perform the database operation
   --
--=================================================================================
-- 22/apr/03 cgoyal uncommented the Update Trigger Actions code for 11.5.8 backport
--=================================================================================

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message(l_full_name ||': Create Trigger Actions');
   END IF;

   OPEN  c_trig_actions_det(p_trig_rec.trigger_id);
   FETCH c_trig_actions_det INTO l_notify_flag, l_execute_schedule_flag;
   IF (c_trig_actions_det%NOTFOUND) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_trig_actions_det;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message(l_full_name ||'l_notify_flag: '||l_notify_flag);
     AMS_Utility_PVT.debug_message(l_full_name ||'l_execute_schedule_flag: '||l_execute_schedule_flag);
     AMS_Utility_PVT.debug_message(l_full_name ||'p_trig_rec.notify_flag: '||p_trig_rec.notify_flag);
     AMS_Utility_PVT.debug_message(l_full_name ||'p_trig_rec.EXECUTE_SCHEDULE_FLAG : '||p_trig_rec.EXECUTE_SCHEDULE_FLAG );
   END IF;

   /* ----------------------- NOTIFICATION ACTION ------------------------------------- */

   -- notify flag action didnt change => update
   IF (p_trig_rec.notify_flag = 'Y' AND l_notify_flag = 'Y')
   THEN

      AMS_Utility_PVT.debug_message(l_full_name ||': Case 1');

      OPEN  c_actions_det(p_trig_rec.trigger_id, 'NOTIFY');
      FETCH c_actions_det INTO l_trig_action_id, l_object_version_number;
      IF (c_actions_det%NOTFOUND) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN -- MMSG
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_actions_det;

      l_thldact_rec.trigger_id := p_trig_rec.trigger_id;
      l_thldact_rec.trigger_action_id := l_trig_action_id;
      l_thldact_rec.object_version_number := l_object_version_number;
      l_thldact_rec.execute_action_type := 'NOTIFY';

      AMS_THLDACT_PVT.Update_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   p_validation_level    => p_validation_level,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_thldact_rec         => l_thldact_rec
                ) ;
      --     --
      --     -- If any errors happen abort API.
      --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- notify flag action was added => create
   IF (p_trig_rec.notify_flag = 'Y' AND l_notify_flag = 'N')
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Case 2');
      l_thldact_rec.trigger_id := p_trig_rec.trigger_id;
      l_thldact_rec.trigger_action_id := null;
      l_thldact_rec.execute_action_type := 'NOTIFY';

      AMS_THLDACT_PVT.Create_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   p_validation_level    => p_validation_level,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_thldact_rec         => l_thldact_rec,
                   x_trigger_action_id   => l_trigger_action_id
                ) ;
      --     --
      --     -- If any errors happen abort API.
      --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- notify flag action was removed => delete
   IF (p_trig_rec.notify_flag = 'N' AND l_notify_flag = 'Y')
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Case 3');
      OPEN  c_actions_det(p_trig_rec.trigger_id, 'NOTIFY');
      FETCH c_actions_det INTO l_trig_action_id, l_object_version_number;
      IF (c_actions_det%NOTFOUND) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN -- MMSG
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_actions_det;


      AMS_THLDACT_PVT.Delete_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_trigger_action_id   => l_trig_action_id,
                   p_object_version_number => l_object_version_number
                ) ;
      --     --
      --     -- If any errors happen abort API.
      --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   /* ----------------------- EXECUTE SCHEDULE ACTION ------------------------------------- */

   -- EXECUTE_SCHEDULE_FLAG action didnt change => update
   IF (p_trig_rec.EXECUTE_SCHEDULE_FLAG = 'Y' AND l_execute_schedule_flag = 'Y')
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Case 4');
      NULL;
      -- nothing to update
      /*
      OPEN  c_actions_det(p_trig_rec.trigger_id, 'EXECUTE');
      FETCH c_actions_det INTO l_trig_action_id, l_object_version_number;
      IF (c_actions_det%NOTFOUND) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN -- MMSG
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_actions_det;

      l_thldact_rec.trigger_id := p_trig_rec.trigger_id;
      l_thldact_rec.trigger_action_id := l_trig_action_id;
      l_thldact_rec.execute_action_type := 'EXECUTE';

      AMS_THLDACT_PVT.Update_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   p_validation_level    => p_validation_level,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_thldact_rec         => l_thldact_rec
                ) ;
      --     --
      --     -- If any errors happen abort API.
      --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */
   END IF;

   -- EXECUTE_SCHEDULE_FLAG action was added => create
   IF (p_trig_rec.EXECUTE_SCHEDULE_FLAG = 'Y' AND l_execute_schedule_flag = 'N')
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Case 5');
      l_thldact_rec.trigger_id := p_trig_rec.trigger_id;
      l_thldact_rec.trigger_action_id := null;
      l_thldact_rec.execute_action_type := 'EXECUTE';
      l_thldact_rec.action_for_id := null;

      AMS_THLDACT_PVT.Create_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   p_validation_level    => p_validation_level,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_thldact_rec         => l_thldact_rec,
                   x_trigger_action_id   => l_trigger_action_id
                ) ;
      --     --
      --     -- If any errors happen abort API.
      --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- EXECUTE_SCHEDULE_FLAG action was removed => delete
   IF (p_trig_rec.EXECUTE_SCHEDULE_FLAG = 'N' AND l_execute_schedule_flag = 'Y')
   THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Case 6');
      OPEN  c_actions_det(p_trig_rec.trigger_id, 'EXECUTE');
      FETCH c_actions_det INTO l_trig_action_id, l_object_version_number;
      IF (c_actions_det%NOTFOUND) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN -- MMSG
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_actions_det;

      AMS_THLDACT_PVT.Delete_ThldAct
                 ( p_api_version         => l_api_version,
                   p_init_msg_list       => FND_API.G_FALSE,
                   p_commit              => FND_API.G_FALSE,
                   x_return_status       => l_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_trigger_action_id   => l_trig_action_id,
                   p_object_version_number => l_object_version_number
                ) ;

   --     --
   --     -- If any errors happen abort API.
   --     --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   /* ------------------- update trigger now ---------------------- */
   -- moved to later by soagrawa 30-apr-2003

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name||': Update Trigger');
   END IF;


   -- following code added by soagrawa for update modification on 04/18/2001

   AMS_TRIG_PVT.Update_Trigger
      ( p_api_version         => l_api_version,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => p_validation_level,

        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_trig_rec            => p_trig_rec
          ) ;
    --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Give Call to Trigger Engine here to Cancel and Resubmit the Process
   --
   -- ams_wfcamp_pvt.AbortProcess( p_trigger_id => p_trig_rec.trigger_id );

   --=====================================================================
   -- Following code is modified by ptendulk on 28-Oct-2000
   -- User id is added in the procedure
   --=====================================================================
   --ams_wfcamp_pvt.StartProcess( p_trigger_id => p_trig_rec.trigger_id ,
   --                              p_user_id    => FND_GLOBAL.user_id );


   --
   -- END of API body.
   --

   --
   -- Standard check of p_commit.
   --
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );


   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_AND_Get
        (p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded          =>      FND_API.G_FALSE
         );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
        (p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded          =>      FND_API.G_FALSE
         );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_AND_Get
        (p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded          =>      FND_API.G_FALSE
         );
END Update_Trigger;


/* srivikri 17-Feb-2006 */
-- Start of Comments
--
-- NAME
--   Activate_Trigger
--
-- PURPOSE
--   This procedure is to activate the monitor and kick off the workflow process for monitoring the
--   performance of initiative
--
-- HISTORY
--   srivikri   17-Feb-2006    Created
--
-- End of Comments

PROCEDURE Activate_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

  p_trigger_id               IN     NUMBER
) IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Activate_Trigger';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status          VARCHAR2(1);

   l_parameter_list  WF_PARAMETER_LIST_T;
   l_new_item_key    VARCHAR2(30);

   CURSOR c_st_dt (p_trig_id NUMBER) IS
   SELECT start_date_time,
          timezone_id,
          user_start_date_time
     FROM ams_triggers
    WHERE trigger_id = p_trig_id;

   l_st_dt DATE;
   l_timezone_id NUMBER;
   l_user_st_dt DATE;

  BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Activate_Trig_PVT;

   IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': Activate Trigger');
   END IF;

   -- Give Call to Trigger Engine here
   l_parameter_list := WF_PARAMETER_LIST_T();

   AMS_Utility_PVT.debug_message(l_full_name ||': before calling Activate');

   wf_event.AddParameterToList(p_name => 'AMS_TRIGGER_ID',
                                   p_value => p_trigger_id,
                                   p_parameterlist => l_parameter_list);

   AMS_Utility_PVT.debug_message(l_full_name ||': after AddParameterToList');

  l_new_item_key := p_trigger_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

   OPEN  c_st_dt(p_trigger_id);
   FETCH c_st_dt INTO l_st_dt, l_timezone_id, l_user_st_dt;
   CLOSE c_st_dt;

   -- if start_date_time is in past, reset it to current date time.
   IF l_st_dt < SYSDATE THEN
        l_st_dt := SYSDATE;
        -- get the user date for current time.
        AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list
                    , x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                    , p_user_tz_id      => l_timezone_id
                    , p_in_time         => l_st_dt
                    , p_convert_type    => 'USER'
                    , x_out_time        => l_user_st_dt
      );
   END IF;

    AMS_Utility_PVT.Create_Log (
            x_return_status   => x_msg_data,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => p_trigger_id,
            p_msg_data        => 'Activate_Trigger :  1. For Trigger ID = ' || p_trigger_id || ' l_new_item_key = ' || l_new_item_key || 'event send date ' || l_st_dt,
            p_msg_type        => 'DEBUG'
            );

   Wf_Event.Raise
   ( p_event_name   =>  'oracle.apps.ams.trigger.TriggerEvent',
     p_event_key    =>  l_new_item_key,
     p_parameters   =>  l_parameter_list,
     p_send_date    =>  l_st_dt);

   AMS_Utility_PVT.debug_message(l_full_name ||': raised WF event');

    AMS_Utility_PVT.Create_Log (
            x_return_status   => x_msg_data,
            p_arc_log_used_by => 'TRIG',
            p_log_used_by_id  => p_trigger_id,
            p_msg_data        => 'Activate_Trigger :  raised with send date '||to_char(l_st_dt,'DD-MM-YYYY HH:MI:SS AM'),
            p_msg_type        => 'DEBUG'
            );

   UPDATE ams_triggers
      SET process_id = to_number(l_new_item_key)
          , start_date_time = l_st_dt
          , user_start_date_time = l_user_st_dt
    WHERE trigger_id = p_trigger_id;

   -- END of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Activate_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Activate_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Activate_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );
END Activate_Trigger;
/* end srivikri 17-Feb-2006 */


END AMS_Trigger_PVT;

/
