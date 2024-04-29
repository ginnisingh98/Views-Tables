--------------------------------------------------------
--  DDL for Package Body AMS_THLDACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_THLDACT_PVT" as
/* $Header: amsvthab.pls 115.19 2003/07/03 14:22:57 cgoyal ship $ */

--
-- NAME
--   AMS_ThldAct_PVT
--
-- HISTORY
--   06/25/1999        ptendulk      CREATED
--   10/26/1999        ptendulk      Modified according to new standards
--   12/27/1999        ptendulk      Added Validations for New columns in Action
--                                   Table(Del_id,..).
--   02/24/2000        ptendulk      Modified the validation for Collaterals
--   03/16/2000        ptendulk      Modified the Check_ThldAct_Fk_Items procedure
--   04/27/2000        ptendulk      Changed the JTF resource view name in check fk
--                                   procedure
--   09/08/2000        ptendulk      Added Additional columns for fulfillment
--   22/04/03          cgoyal        modified for 11.5.8 backport

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ThldAct_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvthab.pls';

-- Debug mode
--g_debug boolean := FALSE;
--g_debug boolean := TRUE;

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------------------------------- Threshold Actions-------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

/***************************  PRIVATE ROUTINES  *********************************/


-- Start of Comments
--
-- NAME
--   Create_Thldact
--
-- PURPOSE
--   This procedure is to create a row in ams_trigger_actions table that
--    satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999    ptendulk        created
--   10/26/1999      ptendulk      Modified according to new standards
--   22/04/03      cgoyal          added ACTION_NOTIF_USER_ID column value insert, for 11.5.8 backport
-- End of Comments

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_thldact
( p_api_version                   IN         NUMBER,
  p_init_msg_list                 IN         VARCHAR2 := FND_API.G_False,
  p_commit           IN         VARCHAR2 := FND_API.G_False,
  p_validation_level              IN         NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_thldact_Rec                   IN         thldact_rec_type,
  x_trigger_action_id             OUT NOCOPY      NUMBER
) IS
    l_api_name       CONSTANT VARCHAR2(30)  := 'Create_Thldact';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   -- Status Local Variables
        l_return_status           VARCHAR2(1);  -- Return value from procedures
        l_thldact_rec             thldact_rec_type := p_thldact_rec;
   l_thldact_count           NUMBER ;

   CURSOR c_trig_act_seq IS
       SELECT ams_trigger_actions_s.NEXTVAL
       FROM DUAL;

   CURSOR c_action_seq(l_my_act_id VARCHAR2) IS
       SELECT  COUNT(*)
       FROM    ams_trigger_actions
            WHERE     trigger_action_id = l_my_act_id;
  BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Thldact_PVT;

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

   --
   -- Validate Trigger Action
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   --
   -- Find the Unique Primary Key if not sent
   --
   IF l_thldact_rec.trigger_action_id IS NULL THEN
      LOOP
      OPEN c_trig_act_seq;
      FETCH c_trig_act_seq INTO l_thldact_rec.trigger_action_id;
      CLOSE c_trig_act_seq;

      OPEN c_action_seq(l_thldact_rec.trigger_action_id);
      FETCH c_action_seq INTO l_thldact_count;
      CLOSE c_action_seq;

           EXIT WHEN l_thldact_count = 0;
      END LOOP;
   END IF;

   Validate_Thldact ( p_api_version         => 1.0
                      ,p_init_msg_list      => FND_API.G_FALSE
                      ,p_validation_level   => p_validation_level
                      ,x_return_status       => l_return_status
                      ,x_msg_count       => x_msg_count
                      ,x_msg_data       => x_msg_data
                      ,p_thldact_rec       => l_thldact_rec
          );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Insert the Record in Trigger Checks table
   --

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   AMS_Utility_PVT.debug_message('CG: the value of trigger_action_id = ' || l_thldact_rec.trigger_action_id);
   AMS_Utility_PVT.debug_message('CG: the value of process_id = ' || l_thldact_rec.process_id);
   AMS_Utility_PVT.debug_message('CG: the value of trigger_id = ' || l_thldact_rec.trigger_id);
   AMS_Utility_PVT.debug_message('CG: the value of order_number = ' || l_thldact_rec.order_number);
   --AMS_Utility_PVT.debug_message('CG: the value of action_notif_user_id = ' || l_thldact_rec.action_notif_user_id);
   AMS_Utility_PVT.debug_message('CG: the value of action_approver_user_id = ' || l_thldact_rec.action_approver_user_id);
   AMS_Utility_PVT.debug_message('CG: the value of list_header_id = ' || l_thldact_rec.list_header_id);
   AMS_Utility_PVT.debug_message('CG: the value of list_connected_to_id = ' || l_thldact_rec.list_connected_to_id);
   AMS_Utility_PVT.debug_message('CG: the value of deliverable_id = ' || l_thldact_rec.deliverable_id);
   AMS_Utility_PVT.debug_message('CG: the value of activity_offer_id = ' || l_thldact_rec.activity_offer_id);
   AMS_Utility_PVT.debug_message('CG: the value of cover_letter_id = ' || l_thldact_rec.cover_letter_id);
   END IF;

   IF (l_thldact_rec.process_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.process_id := NULL;
   END IF;
   IF (l_thldact_rec.order_number = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.order_number := NULL;
   END IF;
/*
   IF (l_thldact_rec.action_notif_user_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.action_notif_user_id := NULL;
   END IF;
*/

   IF (l_thldact_rec.action_approver_user_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.action_approver_user_id := NULL;
   END IF;
   IF (l_thldact_rec.list_header_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.list_header_id := NULL;
   END IF;
   IF (l_thldact_rec.list_connected_to_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.list_connected_to_id := NULL;
   END IF;
   IF (l_thldact_rec.deliverable_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.deliverable_id := NULL;
   END IF;
   IF (l_thldact_rec.activity_offer_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.activity_offer_id := NULL;
   END IF;
   IF (l_thldact_rec.cover_letter_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.cover_letter_id := NULL;
   END IF;
   -- soagrawa 30-apr-2003
   IF (l_thldact_rec.action_for_id = FND_API.G_MISS_NUM) THEN
   l_thldact_rec.action_for_id := NULL;
   END IF;

   IF (l_thldact_rec.notify_flag = FND_API.G_MISS_CHAR) THEN
   l_thldact_rec.notify_flag := NULL;
   END IF;

   IF (l_thldact_rec.generate_list_flag = FND_API.G_MISS_CHAR) THEN
   l_thldact_rec.generate_list_flag := NULL;
   END IF;

   IF (l_thldact_rec.action_need_approval_flag = FND_API.G_MISS_CHAR) THEN
   l_thldact_rec.action_need_approval_flag := NULL;
   END IF;
   --end soagrawa

   INSERT INTO ams_trigger_actions
   (trigger_action_id
   -- standard who columns
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
   ,last_update_login
   ,object_version_number
   ,process_id
   ,trigger_id
   ,order_number
   ,notify_flag
   --,action_notif_user_id
   ,generate_list_flag
   ,action_need_approval_flag
   ,action_approver_user_id
   ,execute_action_type
        ,list_header_id
   ,list_connected_to_id
   ,arc_list_connected_to
        ,deliverable_id
        ,activity_offer_id
        ,dscript_name
   ,program_to_call
        ,cover_letter_id
        ,mail_subject
        ,mail_sender_name
        ,from_fax_no
        , action_for_id
   )
   VALUES
   (
   l_thldact_rec.trigger_action_id
   -- standard who columns
   ,sysdate
   ,FND_GLOBAL.User_Id
   ,sysdate
   ,FND_GLOBAL.User_Id
   ,FND_GLOBAL.Conc_Login_Id
   -- end standard who columns
   ,1                   -- Object Version Number
   ,l_thldact_rec.process_id          --??
   ,l_thldact_rec.trigger_id
   ,l_thldact_rec.order_number          --??
   ,nvl(l_thldact_rec.notify_flag,'N')              -- cgoyal changed default value to 'N'
   --,l_thldact_rec.action_notif_user_id
   ,nvl(l_thldact_rec.generate_list_flag,'N')
   ,nvl(l_thldact_rec.action_need_approval_flag,'N')
   ,l_thldact_rec.action_approver_user_id       --??
   ,l_thldact_rec.execute_action_type       --??
   ,l_thldact_rec.list_header_id          --??
   ,l_thldact_rec.list_connected_to_id       --??
   ,l_thldact_rec.arc_list_connected_to       --??
        ,l_thldact_rec.deliverable_id          --??
        ,l_thldact_rec.activity_offer_id       --??
        ,l_thldact_rec.dscript_name          --??
   ,l_thldact_rec.program_to_call          --??
   ,l_thldact_rec.cover_letter_id          --??
   ,l_thldact_rec.mail_subject          --??
   ,l_thldact_rec.mail_sender_name          --??
   ,l_thldact_rec.from_fax_no          --??
   ,l_thldact_rec.action_for_id
   );
   -- set OUT value
   x_trigger_action_id := l_thldact_rec.trigger_action_id;
    --
    -- END of API body.
    --
    --
    -- Standard check of p_commit.
    --
    IF FND_API.To_Boolean ( p_commit )
    THEN
           COMMIT WORK;
    END IF;
    --
    -- Standard call to get message count AND IF count is 1, get message info.
    --
    FND_MSG_PUB.Count_AND_Get
    (
   p_count           =>      x_msg_count,
   p_data            =>      x_msg_data,
   p_encoded          =>      FND_API.G_FALSE
    );

    IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': end');
    END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Create_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Create_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN OTHERS THEN
           ROLLBACK TO Create_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
END Create_Thldact;

-- Start of Comments
--
-- NAME
--   Delete_Thldact
--
-- PURPOSE
--   This procedure is to delete a ams_trigger_actions table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Delete_Thldact
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_False,
  p_commit                    IN     VARCHAR2    := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_action_id        IN     NUMBER,
  p_object_version_number     IN     NUMBER
) IS

    l_api_name      CONSTANT VARCHAR2(30)  := 'Delete_Thldact';
    l_api_version   CONSTANT NUMBER        := 1.0;
    l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

  BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT Delete_Thldact_PVT;

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

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API body
  --

  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': delete');
  END IF;

  --
  -- Debug Message
  --

  -- Call Private API to cascade delete any children data if necessary

  DELETE FROM ams_trigger_actions
  WHERE  trigger_action_id = p_trigger_action_id
  AND     object_version_number = p_object_version_number ;

  IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- END of API body.
  --
  --
  -- Standard check of p_commit.
  --
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

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

           ROLLBACK TO Delete_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           ROLLBACK TO Delete_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
      WHEN OTHERS THEN

           ROLLBACK TO Delete_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
END Delete_Thldact;

-- Start of Comments
--
-- NAME
--   Lock_Thldact
--
-- PURPOSE
--   This procedure is to lock a ams_trigger_actions table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Lock_Thldact
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_action_id           IN     NUMBER,
  p_object_version_number     IN     NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_Thldact';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


  -- Status Local Variables
  l_action_id     NUMBER;  -- Return value from procedures

  CURSOR C_ams_trigger_actions IS
       SELECT trigger_action_id
      FROM   ams_trigger_actions
       WHERE  trigger_action_id = p_trigger_action_id
      AND      object_version_number = p_object_version_number
      FOR UPDATE of trigger_action_id NOWAIT;

BEGIN
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
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

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   --
   -- Lock the Trigger Action
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   -- Perform the database operation
   OPEN  C_ams_trigger_actions;
   FETCH C_ams_trigger_actions INTO l_action_id;
   IF (C_ams_trigger_actions%NOTFOUND) THEN
      CLOSE C_ams_trigger_actions;
      -- Error, check the msg level and added an error message to the
      -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
         FND_MESSAGE.Set_Name('FND', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

  CLOSE C_ams_trigger_actions;

    --
    -- END of API body.
    --

    --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
    FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN AMS_UTILITY_PVT.RESOURCE_LOCKED THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN -- MMSG
             FND_MESSAGE.SET_NAME('AMS','AMS_API_RESOURCE_LOCKED');
             FND_MSG_PUB.Add;
         END IF;

             FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                p_encoded          =>      FND_API.G_FALSE
                );

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );

END Lock_Thldact;

-- Start of Comments
--
-- NAME
--   Update_Thldact
--
-- PURPOSE
--   This procedure is to update a ams_trigger_actions table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Update_Thldact
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_False,
  p_commit                    IN     VARCHAR2   := FND_API.G_False,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,

  p_thldact_rec                IN     thldact_rec_type
) IS

   l_api_name              CONSTANT VARCHAR2(30)  := 'Update_Thldact';
   l_api_version           CONSTANT NUMBER        := 1.0;
   l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   --
   -- Status Local Variables
   --
   l_return_status         VARCHAR2(1);  -- Return value from procedures
   l_thldact_rec           thldact_rec_type ;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Update_Thldact_PVT;

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

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_thldact_Items(
         p_thldact_rec     => p_thldact_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_thldact_rec(p_thldact_rec, l_thldact_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_thldact_record(
         p_thldact_rec    => p_thldact_rec,
         p_complete_rec   => l_thldact_rec,
         x_return_status  => l_return_status
                        );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   UPDATE ams_trigger_actions
   SET   last_update_date           = sysdate
              ,last_updated_by             = FND_GLOBAL.User_Id
              ,last_update_login         = FND_GLOBAL.Conc_Login_Id
              ,object_version_number     = l_thldact_rec.object_version_number + 1
              ,process_id                = l_thldact_rec.process_id
              ,trigger_id                = l_thldact_rec.trigger_id
              ,order_number              = l_thldact_rec.order_number
              ,notify_flag               = nvl(l_thldact_rec.notify_flag,'N')               --cgoyal modified the default value of notify_flag as 'N' for 11.5.8 backport
         --,ACTION_NOTIF_USER_ID      = l_thldact_rec.ACTION_NOTIF_USER_ID          --cgoyal added column for 11.5.8 backport
              ,generate_list_flag        = nvl(l_thldact_rec.generate_list_flag,'N')
              ,action_need_approval_flag = nvl(l_thldact_rec.action_need_approval_flag,'N')
              ,action_approver_user_id    = l_thldact_rec.action_approver_user_id
              ,execute_action_type       = l_thldact_rec.execute_action_type
              ,list_header_id            = l_thldact_rec.list_header_id
              ,list_connected_to_id      = l_thldact_rec.list_connected_to_id
              ,arc_list_connected_to     = l_thldact_rec.arc_list_connected_to
              ,deliverable_id            = l_thldact_rec.deliverable_id
              ,activity_offer_id         = l_thldact_rec.activity_offer_id
              ,dscript_name              = l_thldact_rec.dscript_name
              ,program_to_call           = l_thldact_rec.program_to_call
              ,cover_letter_id           = l_thldact_rec.cover_letter_id
              ,mail_subject              = l_thldact_rec.mail_subject
              ,mail_sender_name          = l_thldact_rec.mail_sender_name
              ,from_fax_no               = l_thldact_rec.from_fax_no
              ,action_for_id             = l_thldact_rec.action_for_id
   WHERE   trigger_action_id = l_thldact_Rec.trigger_action_id
   AND object_version_number = l_thldact_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      -- Error, check the msg level and added an error message to the
      -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG

          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

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

   --
   --   Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

           ROLLBACK TO Update_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           ROLLBACK TO Update_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
        WHEN OTHERS THEN

           ROLLBACK TO Update_Thldact_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
END Update_Thldact;

-- Start of Comments
--
-- NAME
--   Validate_Thldact
--
-- PURPOSE
--   This procedure is to validate a ams_trigger_actions table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Validate_Thldact
( p_api_version                  IN     NUMBER,
  p_init_msg_list                IN     VARCHAR2    := FND_API.G_False,
  p_validation_level             IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY    VARCHAR2,
  x_msg_count                    OUT NOCOPY    NUMBER,
  x_msg_data                     OUT NOCOPY    VARCHAR2,

  p_thldact_rec                  IN     thldact_rec_type

) IS

   l_api_name           CONSTANT VARCHAR2(30)  := 'Validate_Thldact';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status      VARCHAR2(1);  -- Return value from procedures

BEGIN

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
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

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Thldact_Items(
         p_thldact_rec        => p_thldact_rec,
         p_validation_mode      => JTF_PLSQL_API.g_create,
         x_return_status        => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_thldact_record(
         p_thldact_rec    => p_thldact_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );


      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

    --
    -- Standard call to get message count AND IF count is 1, get message info.
   --
    FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );

   --
   --   Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
           p_encoded          =>      FND_API.G_FALSE
           );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );


        WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );

END Validate_thldAct;


-- Start of Comments
--
-- NAME
----   Check_ThldAct_Req_Items
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs.
--
-- NOTES
--
--
-- HISTORY
--   02/28/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Check_ThldAct_Req_Items
( p_thldact_rec                       IN     thldact_rec_type,
  x_return_status                     OUT NOCOPY    VARCHAR2
) IS

BEGIN
   --
    --  Initialize API/Procedure return status to success
   --
   x_return_status := FND_API.G_Ret_Sts_Success;

    --
   -- Check required parameters
   --

   --
   -- Trigger_ID
   --
   IF p_thldact_rec.trigger_id IS NULL
   THEN
      -- missing required field
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
            --dbms_output.put_line('trigger_id is missing');
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_MISSING_TRIG_ID');
             FND_MSG_PUB.Add;
        END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      return;
   END IF;


  EXCEPTION
   WHEN OTHERS THEN
      NULL;


END Check_Thldact_Req_Items;

--- Start of Comments
--
-- NAME
--   Check_Thldact_uk_Items
--
-- PURPOSE
--   This procedure is to validate Unique Key in AMS_TRIGGER_ACTIONS
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldact_Uk_Items(
   p_thldact_rec     IN  thldact_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_where_clause VARCHAR2(500);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_thldact, when trigger_action_id is passed in, we need to
   -- check if this trigger_action_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_thldact_rec.trigger_action_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
              'ams_trigger_actions',
            'trigger_action_id = ' || p_thldact_rec.trigger_action_id
         ) = FND_API.g_false
     THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_TRIG_DUPLICATE_ACTION');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other unique items

/*
   -- Check if Trigger_id is unique. Need to handle create and
   -- update differently.
   -- Unique TRIGGER_NAME and TRIGGER_CREATED_FOR
   l_where_clause := ' trigger_id = '|| p_thldact_rec.trigger_id ;

      -- For Updates, must also check that uniqueness is not checked against the same record.
--   IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      l_where_clause := l_where_clause || ' AND trigger_action_id <> ' || p_thldact_rec.trigger_action_id;
      -- soagrawa 30-apr-2003
      l_where_clause := l_where_clause || ' AND execute_action_type <> ' || p_thldact_rec.execute_action_type;
  -- END IF;

   IF AMS_Utility_PVT.Check_Uniqueness(
         p_table_name      => 'ams_trigger_actions',
      p_where_clause    => l_where_clause
      ) = FND_API.g_false
   THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
           FND_MESSAGE.set_name('AMS', 'AMS_TRIG_DUP_TRIG_ID');
           FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_error;
       RETURN;
   END IF;
*/
   -- check other unique items


END Check_Thldact_Uk_Items;

-- Start of Comments
--
-- NAME
--   Check_ThldAct_FK_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_actions Foreign Key items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999          ptendulk          Modified according to new standards
--   03/16/2000        ptendulk        Modified , the list of type 'TEMPLATE'
--                                     can only be attached to the Triggers
-- End of Comments
PROCEDURE Check_ThldAct_Fk_Items(
   p_thldact_rec        IN  thldact_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
BEGIN
  --
  -- Initialize API/Procedure return status to success
  --
  x_return_status := FND_API.g_ret_sts_success;

  --
  --  Trigger ID
  --
  IF p_thldact_rec.trigger_id <> FND_API.G_MISS_NUM
  THEN
     l_table_name           := 'AMS_TRIGGERS' ;
     l_pk_name           :=   'trigger_id' ;
     l_pk_value                 := p_thldact_rec.trigger_id;
     l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
     l_additional_where_clause  := NULL ;

     IF AMS_Utility_PVT.Check_Fk_Exists
          (p_table_name               => l_table_name
              ,p_PK_name         => l_pk_name
              ,p_PK_value         => l_pk_value
              ,p_pk_data_type         => l_pk_data_type
              ,p_additional_where_clause => l_additional_where_clause
            ) = FND_API.G_FALSE THEN
         -- invalid item
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
--                 DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
      FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_TRIGGER_ID');
             FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- If any errors happen abort API/Procedure.
     RETURN;
     END IF;
  END IF;

  --
  -- Check list_header_id
  --


/*
  IF p_thldact_rec.list_header_id <> FND_API.G_MISS_NUM AND
     p_thldact_rec.list_header_id IS NOT NULL THEN
        l_table_name               := 'AMS_LIST_HEADERS_ALL' ;
        l_pk_name                  := 'LIST_HEADER_ID' ;
        l_pk_value                 := p_thldact_rec.list_header_id;
        l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
        l_additional_where_clause  := ' list_type = '||''''||'TEMPLATE'||'''' ;

-- Following code is modified by ptendulk on Mar16th
-- The list of type TEMPLATE can 0nly be attached to the Triggers

--      l_additional_where_clause  := ' generation_type = '||''''||'REPEAT'||''''
--             ||' and status_code = '||''''||'RESERVED'||'''' ;
--
-- dbms_output.put_line('Where Clause '||l_additional_where_clause);
     IF AMS_Utility_PVT.Check_Fk_Exists
             (p_table_name               => l_table_name
             ,p_PK_name                  => l_pk_name
             ,p_PK_value                 => l_pk_value
             ,p_pk_data_type             => l_pk_data_type
             ,p_additional_where_clause  => l_additional_where_clause
             ) = FND_API.G_FALSE THEN
       -- invalid item
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN -- MMSG
--           DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
                FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_LIST');
                FND_MSG_PUB.Add;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             -- If any errors happen abort API/Procedure.
             RETURN;
     END IF;
  END IF;
*/
  ----------------------------------------------------------------------
  -- Following code is changed by ptendulk on 27th Apr
  -- Changed the name of the resource view and added the condition
  -- to check the resource entered is Employee
  --
  ----------------------------------------------------------------------
  --
  -- Check action_approver_user_id
  --
  /*
  IF p_thldact_rec.action_approver_user_id <> FND_API.G_MISS_NUM
  AND p_thldact_rec.action_approver_user_id IS NOT NULL THEN
     l_table_name             := 'jtf_rs_resource_extns' ;
     l_pk_name                :=   'resource_id' ;
     l_pk_value                 := p_thldact_rec.action_approver_user_id;
       l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
       l_additional_where_clause             := ' category = '||''''||'EMPLOYEE'||'''' ;

    IF AMS_Utility_PVT.Check_Fk_Exists
            (p_table_name               => l_table_name
           ,p_PK_name                  => l_pk_name
          ,p_PK_value                  => l_pk_value
          ,p_pk_data_type              => l_pk_data_type
             ,p_additional_where_clause    => l_additional_where_clause
            ) = FND_API.G_FALSE THEN

      -- invalid item
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
--          DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_APPROVER');
         FND_MSG_PUB.Add;
       END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
      END IF;
  END IF;
*/
  --
  -- Check dscript_name
  --
  /*
  IF p_thldact_rec.dscript_name <> FND_API.G_MISS_CHAR
  AND p_thldact_rec.dscript_name IS NOT NULL THEN
     l_table_name             := 'ies_deployed_scripts' ;
     l_pk_name                :=   'dscript_name' ;
     l_pk_value                 := p_thldact_rec.dscript_name;
      l_pk_data_type             := AMS_Utility_PVT.G_VARCHAR2;
      l_additional_where_clause  := NULL ;

    IF AMS_Utility_PVT.Check_Fk_Exists
            (p_table_name               => l_table_name
           ,p_PK_name                  => l_pk_name
          ,p_PK_value                  => l_pk_value
          ,p_pk_data_type              => l_pk_data_type
             ,p_additional_where_clause    => l_additional_where_clause
            ) = FND_API.G_FALSE THEN

      -- invalid item
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
--          DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_DSCRIPT');
         FND_MSG_PUB.Add;
       END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
      END IF;
  END IF;
*/
  --
  -- Check Offers
  --
  /*
  IF p_thldact_rec.activity_offer_id <> FND_API.G_MISS_NUM
  AND p_thldact_rec.activity_offer_id IS NOT NULL THEN
     l_table_name      := 'ams_act_offers' ;
     l_pk_name       :=   'activity_offer_id' ;
     l_pk_value             := p_thldact_rec.activity_offer_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL ;

    IF AMS_Utility_PVT.Check_Fk_Exists
            (p_table_name               => l_table_name
           ,p_PK_name                  => l_pk_name
          ,p_PK_value                  => l_pk_value
          ,p_pk_data_type              => l_pk_data_type
             ,p_additional_where_clause    => l_additional_where_clause
            ) = FND_API.G_FALSE THEN

      -- invalid item
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
--          DBMS_OUTPUT.Put_Line('Foreign Key Does not Exist');
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_OFFER');
         FND_MSG_PUB.Add;
       END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
      END IF;
  END IF;
*/

--============================================================================
-- Following code is added by ptendulk on 08-Sep-2000
-- This is the validation for the newly added columns for fullfillment
--
--============================================================================
/*
   IF p_thldact_rec.cover_letter_id IS NOT NULL AND
      p_thldact_rec.cover_letter_id <> FND_API.G_MISS_NUM
   THEN
      l_table_name     := 'jtf_amv_items_vl';
      l_pk_name        := 'item_id' ;
      l_pk_data_type   := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value       := p_thldact_rec.cover_letter_id   ;
      l_additional_where_clause   := ' content_type_id = 20'||
                          ' AND (effective_start_date <= SYSDATE OR effective_start_date IS NULL)'||
                          ' AND (expiration_date >= SYSDATE OR expiration_date IS NULL)' ;

         IF AMS_Utility_PVT.Check_FK_Exists (
               p_table_name                   => l_table_name
              ,p_pk_name                      => l_pk_name
              ,p_pk_value                     => l_pk_value
              ,p_pk_data_type                 => l_pk_data_type
              ,p_additional_where_clause      => l_additional_where_clause
           ) = FND_API.G_FALSE
         THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_TRIG_INVALID_COVER_LETTER');
            FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
   END IF ;
*/
End Check_ThldAct_Fk_Items ;

-- Start of Comments
--
-- NAME
--   Check_ThldAct_Lookup_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_actions Lookup items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldact_Lookup_Items(
   p_thldact_rec        IN  thldact_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
BEGIN
  --
  -- Initialize API/Procedure return status to success
  --
  x_return_status := FND_API.g_ret_sts_success;

  --
  -- Execute_action_type
  --
  IF p_thldact_rec.execute_action_type <> FND_API.G_MISS_CHAR
  AND p_thldact_rec.execute_action_type IS NOT NULL
  THEN
    IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
        ,p_lookup_type      => 'AMS_TRIG_ACTION_TYPE'
        ,p_lookup_code      => p_thldact_rec.execute_action_type
      ) = FND_API.G_FALSE then
         -- invalid item
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN -- MMSG
--               DBMS_OUTPUT.Put_Line('Check1 Type is invalid');
            FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_ACTION_TYPE');
                FND_MSG_PUB.Add;
           END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
    END IF;
  END IF;


End Check_ThldAct_Lookup_Items ;

-- Start of Comments
--
-- NAME
--   Check_ThldAct_Flag_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_actions Flags
--
-- NOTES
--
--
-- HISTORY
--   10/29/1999        ptendulk        Created
-- End of Comments
PROCEDURE check_thldact_flag_items(
   p_thldact_rec        IN  thldact_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   --Initialize OUT NOCOPY Variable
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- Notify Flag
   --
   /*
   IF  p_thldact_rec.notify_flag <> FND_API.g_miss_char
   AND  p_thldact_rec.notify_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_thldact_rec.notify_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_TRIG_BAD_NOTIFY_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   */
   --
   -- generate_list_flag
   --
   /*
   IF  p_thldact_rec.generate_list_flag <> FND_API.g_miss_char
   AND p_thldact_rec.generate_list_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_thldact_rec.generate_list_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_TRIG_BAD_GEN_LIST_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
   --
   -- Action_need_approval_flag
   --
   /*
   IF  p_thldact_rec.action_need_approval_flag <> FND_API.g_miss_char
   AND p_thldact_rec.action_need_approval_flag IS NOT NULL
    THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_thldact_rec.action_need_approval_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_TRIG_BAD_APPR_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   */
END check_thldact_flag_items;



-- Start of Comments
--
-- NAME
--   Check_ThldAct_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_actions items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_ThldAct_Items(
   p_thldact_rec     IN  thldact_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   Check_ThldAct_Req_Items(
      p_thldact_rec    => p_thldact_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ThldAct_Uk_Items(
      p_thldact_rec        => p_thldact_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );
-- dbms_output.put_line('After UK : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ThldAct_Fk_Items(
      p_thldact_rec       => p_thldact_rec,
      x_return_status  => x_return_status
   );
-- dbms_output.put_line('After fK : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_ThldAct_Lookup_Items(
      p_thldact_rec        => p_thldact_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Thldact_flag_items(
      p_thldact_rec        => p_thldact_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Thldact_Items;

-- Start of Comments
--
-- NAME
--   Validate_thldact_record
--
-- PURPOSE
--   This procedure is to validate ams_trigger_Actions table.
--   This is an example if you need to call validation procedure from the UI site.
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk    Created
--   10/26/1999          ptendulk      Modified according to new standards
--   02/24/2000        ptendulk    Modified the validation for Collaterals
--   22/04/03          CGOYAL      Added check for 11.5.8 backport

-- End of Comments
PROCEDURE Check_thldact_record(
   p_thldact_rec    IN  thldact_rec_type,
   p_complete_rec   IN  thldact_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR c_trig_det(l_trig_id NUMBER) IS
select  arc_trigger_created_for,
        trigger_created_for_id
from    ams_triggers
where   trigger_id = l_trig_id ;

   l_obj_type        VARCHAR2(30);
   l_obj_id          NUMBER ;
   l_trigger_id      NUMBER ;

   l_appr_flag         VARCHAR2(1) ;
   l_appr_id          NUMBER ;
   l_list_header_id   NUMBER ;

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);
   l_cover_letter_id             NUMBER ;
BEGIN
   --
   -- Initialize the Out Variable
   --
   x_return_status := FND_API.g_ret_sts_success;

   --
   -- Generate List Flag
   --
   /*
   IF p_thldact_rec.generate_list_flag  <>  FND_API.G_MISS_CHAR
   THEN
      IF p_thldact_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_list_header_id := p_complete_rec.list_header_id  ;
      ELSE
       l_list_header_id := p_thldact_rec.list_header_id ;
      END IF;

      IF  p_thldact_rec.generate_list_flag = 'Y' AND
         l_list_header_id           IS NULL
      THEN
   -- missing required field
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
            --dbms_output.put_line('list_use_this_source_code is missing');
      FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_MISSING_LIST');
             FND_MSG_PUB.Add;
        END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- If any errors happen abort API/Procedure.
   RETURN;
      END IF;
   END IF;
   */
    --
    -- Validate Deliverable_id
    --
    /*
   IF p_thldact_rec.deliverable_id <> FND_API.G_MISS_NUM THEN
     IF p_thldact_rec.trigger_id = FND_API.G_MISS_NUM THEN
         l_trigger_id  := p_complete_rec.trigger_id ;
     ELSE
         l_trigger_id  := p_thldact_rec.trigger_id ;
     END IF;

      OPEN  c_trig_det(l_trigger_id)   ;
      FETCH c_trig_det INTO l_obj_type,l_obj_id ;
      CLOSE c_trig_det ;


      l_pk_value                 := p_thldact_rec.deliverable_id;
      l_pk_name                  := 'using_object_id';
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_table_name               := 'ams_object_associations';

--    Following code has been modified by ptendulk on 24Feb2000
      l_additional_where_clause  := ' master_object_type = '||''''||l_obj_type||''''||
                                    ' and using_object_type = '||''''||'DELV'||''''||
                                    ' and master_object_id = '||l_obj_id ;

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_TRIG_INVALID_DELV_ID');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
   END IF;
   */
   --
   -- Generate List Flag
   --
   -- soagrawa 30-apr-2003 removed this
   /*
   IF p_thldact_rec.execute_action_type  <>  FND_API.G_MISS_CHAR
   AND p_thldact_rec.execute_action_type IS NOT NULL
   AND p_thldact_rec.execute_action_type <> 'FULFILL_LIST'
   THEN
      IF p_thldact_rec.cover_letter_id = FND_API.G_MISS_NUM THEN
        l_cover_letter_id := p_complete_rec.cover_letter_id  ;
      ELSE
       l_cover_letter_id := p_thldact_rec.cover_letter_id ;
      END IF;

      IF  p_thldact_rec.cover_letter_id IS NULL
      THEN
   -- missing required field
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
            --dbms_output.put_line('list_use_this_source_code is missing');
      FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_MISSING_COVER_LETTER');
             FND_MSG_PUB.Add;
        END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- If any errors happen abort API/Procedure.
   RETURN;
      END IF;
   END IF;
   */
   -- CGOYAL added for 11.5.8 backport
   -- Validate Notify User if notify flag is checked.
   --
   /*
   IF ((p_thldact_rec.ACTION_NOTIF_USER_ID IS NULL) OR (p_thldact_rec.ACTION_NOTIF_USER_ID = FND_API.G_MISS_NUM)) THEN
    IF p_thldact_rec.notify_flag = 'Y' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_MISSING_NOTIFY_USER');
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
   END IF;
   */

   IF p_thldact_rec.execute_action_type = 'NOTIFY'
      AND ((p_thldact_rec.action_for_id IS NULL) OR (p_thldact_rec.action_for_id = FND_API.G_MISS_NUM))
   THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_MISSING_NOTIFY_USER');
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

END Check_thldact_record;

-- Start of Comments
--
-- NAME
--   Init_thldck_rec
--
-- PURPOSE
--   This procedure is to Initialize the check Record before Updation
--
-- NOTES
--
--
-- HISTORY
--   10/26/1999         ptendulk         Created
--   22/04/03              cgoyal                  modified for 11.5.8 backport
-- End of Comments
PROCEDURE Init_thldact_rec(
   x_thldact_rec  OUT NOCOPY  thldact_rec_type
)
IS
BEGIN
  x_thldact_rec.trigger_action_id             := FND_API.G_MISS_NUM ;
  x_thldact_rec.last_update_date              := FND_API.G_MISS_DATE ;
  x_thldact_rec.last_updated_by               := FND_API.G_MISS_NUM ;
  x_thldact_rec.creation_date                 := FND_API.G_MISS_DATE ;
  x_thldact_rec.created_by                    := FND_API.G_MISS_NUM ;
  x_thldact_rec.last_update_login             := FND_API.G_MISS_NUM ;
  x_thldact_rec.object_version_number         := FND_API.G_MISS_NUM ;
  x_thldact_rec.process_id                    := FND_API.G_MISS_NUM ;
  x_thldact_rec.trigger_id                    := FND_API.G_MISS_NUM ;
  x_thldact_rec.order_number                  := FND_API.G_MISS_NUM ;
  x_thldact_rec.notify_flag                   := FND_API.G_MISS_CHAR ;

-- cgoyal added ACTION_NOTIF_USER_ID column initialise
  --x_thldact_rec.ACTION_NOTIF_USER_ID          := FND_API.G_MISS_NUM ;
  x_thldact_rec.action_for_id                 := FND_API.G_MISS_NUM ;

  x_thldact_rec.generate_list_flag            := FND_API.G_MISS_CHAR ;
  x_thldact_rec.action_need_approval_flag     := FND_API.G_MISS_CHAR ;
  x_thldact_rec.action_approver_user_id       := FND_API.G_MISS_NUM ;
  x_thldact_rec.execute_action_type           := FND_API.G_MISS_CHAR ;
  x_thldact_rec.list_header_id                := FND_API.G_MISS_NUM ;
  x_thldact_rec.list_connected_to_id          := FND_API.G_MISS_NUM ;
  x_thldact_rec.arc_list_connected_to         := FND_API.G_MISS_CHAR ;
  x_thldact_rec.deliverable_id                := FND_API.G_MISS_NUM ;
  x_thldact_rec.activity_offer_id             := FND_API.G_MISS_NUM ;
  x_thldact_rec.dscript_name                  := FND_API.G_MISS_CHAR ;
  x_thldact_rec.program_to_call               := FND_API.G_MISS_CHAR ;

  x_thldact_rec.cover_letter_id               :=  FND_API.G_MISS_NUM  ;
  x_thldact_rec.mail_subject                  :=  FND_API.G_MISS_CHAR ;
  x_thldact_rec.mail_sender_name              :=  FND_API.G_MISS_CHAR ;
  x_thldact_rec.from_fax_no                   :=  FND_API.G_MISS_CHAR ;

END Init_thldact_rec ;

-- Start of Comments
--
-- NAME
--   Complete_thldact_rec
--
-- PURPOSE
--   This procedure is to Initialize the check Record before Updation
--
-- NOTES
--
--
-- HISTORY
--   10/26/1999         ptendulk         Created
--   22-apr-03         cgoyal added            ACTION_NOTIF_USER_ID column defaulting
-- End of Comments

PROCEDURE Complete_thldact_rec(
   p_thldact_rec   IN  thldact_rec_type,
   x_complete_rec  OUT NOCOPY thldact_rec_type
)
IS

   CURSOR c_thldact IS
   SELECT *
     FROM ams_trigger_actions
    WHERE trigger_action_id = p_thldact_rec.trigger_action_id;

   l_thldact_rec  c_thldact%ROWTYPE;

BEGIN

   x_complete_rec := p_thldact_rec;

   OPEN c_thldact;
   FETCH c_thldact INTO l_thldact_rec;
   IF c_thldact%NOTFOUND THEN
      CLOSE c_thldact;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_thldact;

   IF p_thldact_rec.trigger_id = FND_API.g_miss_num THEN
      x_complete_rec.trigger_id := l_thldact_rec.trigger_id;
   END IF;

   IF p_thldact_rec.order_number = FND_API.g_miss_num THEN
      x_complete_rec.order_number := l_thldact_rec.order_number;
   END IF;

   IF p_thldact_rec.process_id = FND_API.g_miss_num THEN
      x_complete_rec.process_id := l_thldact_rec.process_id;
   END IF;

   IF p_thldact_rec.notify_flag = FND_API.g_miss_char THEN
      x_complete_rec.notify_flag := l_thldact_rec.notify_flag;
   END IF;
/*
-- CGOYAL added for 11.5.8 backport
   IF p_thldact_rec.ACTION_NOTIF_USER_ID = FND_API.g_miss_num THEN
      x_complete_rec.ACTION_NOTIF_USER_ID := l_thldact_rec.ACTION_NOTIF_USER_ID;
   END IF;
-- End add.
*/

   IF p_thldact_rec.action_for_id = FND_API.g_miss_num THEN
      x_complete_rec.action_for_id := l_thldact_rec.action_for_id;
   END IF;


   IF p_thldact_rec.generate_list_flag = FND_API.g_miss_char THEN
      x_complete_rec.generate_list_flag := l_thldact_rec.generate_list_flag;
   END IF;

   IF p_thldact_rec.action_need_approval_flag = FND_API.g_miss_char THEN
      x_complete_rec.action_need_approval_flag := l_thldact_rec.action_need_approval_flag;
   END IF;

   IF p_thldact_rec.action_approver_user_id = FND_API.g_miss_num THEN
      x_complete_rec.action_approver_user_id := l_thldact_rec.action_approver_user_id;
   END IF;

   IF p_thldact_rec.execute_action_type = FND_API.g_miss_char THEN
      x_complete_rec.execute_action_type := l_thldact_rec.execute_action_type;
   END IF;

   IF p_thldact_rec.list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.list_header_id := l_thldact_rec.list_header_id;
   END IF;

   IF p_thldact_rec.list_connected_to_id = FND_API.g_miss_num THEN
      x_complete_rec.list_connected_to_id := l_thldact_rec.list_connected_to_id;
   END IF;

   IF p_thldact_rec.arc_list_connected_to = FND_API.g_miss_char THEN
      x_complete_rec.arc_list_connected_to := l_thldact_rec.arc_list_connected_to;
   END IF;

   IF p_thldact_rec.deliverable_id = FND_API.g_miss_num THEN
      x_complete_rec.deliverable_id := l_thldact_rec.deliverable_id;
   END IF;

   IF p_thldact_rec.activity_offer_id = FND_API.g_miss_num THEN
      x_complete_rec.activity_offer_id := l_thldact_rec.activity_offer_id;
   END IF;

   IF p_thldact_rec.dscript_name = FND_API.g_miss_char THEN
      x_complete_rec.dscript_name := l_thldact_rec.dscript_name;
   END IF;

   IF p_thldact_rec.program_to_call = FND_API.g_miss_char THEN
      x_complete_rec.program_to_call := l_thldact_rec.program_to_call;
   END IF;

   IF p_thldact_rec.cover_letter_id     = FND_API.G_MISS_NUM THEN
      x_complete_rec.cover_letter_id := l_thldact_rec.cover_letter_id ;
   END IF;

   IF p_thldact_rec.mail_subject     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.mail_subject := l_thldact_rec.mail_subject ;
   END IF;

   IF p_thldact_rec.mail_sender_name     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.mail_sender_name := l_thldact_rec.mail_sender_name ;
   END IF;

   IF p_thldact_rec.from_fax_no     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.from_fax_no := l_thldact_rec.from_fax_no ;
   END IF;

END Complete_thldact_rec ;

END AMS_ThldAct_PVT;

/
