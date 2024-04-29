--------------------------------------------------------
--  DDL for Package Body AMS_THLDCHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_THLDCHK_PVT" as
/* $Header: amsvthcb.pls 120.2 2005/09/02 23:50:59 kbasavar noship $ */

--
-- NAME
--   AMS_ThldChk_PVT
--
-- HISTORY
--   06/25/1999        ptendulk        CREATED
--   10/26/1999        ptendulk        Modified according to new standards
--   12/30/1999        ptendulk        Modified as there won't be any lookup
--                                     for Operator.
--                                     Also Chk2 Source can be Events /Campaign
--                                     Modified code for that
--   02/14/2000        ptendulk        Changed the uom Validation in Record Validation
--                                     Changed the message names
--  15-Feb-2001        ptendulk        Changed the api for Hornet release
--                                     1. chk1/chk2 Object ids were added.
--                                     2. chk1 is not restricted to the current campaigns
--                                        metric.
--  23-aug-2002        soagrawa        Fixed bug# 2528692 - cannot create trigger of type
--                                     metric to workbook due to size of l_pk_value
--
--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ThldChk_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvthcb.pls';

-- Debug mode
--g_debug boolean := FALSE;
--g_debug boolean := TRUE;

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------------------------------- Threshold Checks-------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

/***************************  PRIVATE ROUTINES  *********************************/


-- Start of Comments
--
-- NAME
--   Create_Thldchk
--
-- PURPOSE
--   This procedure is to create a row in ams_trigger_checks table that
--    satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk        created
--   10/26/1999   ptendulk         Modified according to new standards
-- End of Comments

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_thldchk
( p_api_version                   IN     NUMBER,
  p_init_msg_list                 IN     VARCHAR2 := FND_API.G_False,
  p_commit                        IN     VARCHAR2 := FND_API.G_False,
  p_validation_level              IN     NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY    VARCHAR2,
  x_msg_count                     OUT NOCOPY    NUMBER,
  x_msg_data                      OUT NOCOPY    VARCHAR2,

  p_thldchk_Rec                   IN     thldchk_rec_type,
  x_trigger_check_id              OUT NOCOPY    NUMBER
)
IS

   l_api_name       CONSTANT VARCHAR2(30)  := 'Create_Thldchk';
   l_api_version    CONSTANT NUMBER        := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status           VARCHAR2(1);  -- Return value from procedures
   l_thldchk_rec             thldchk_rec_type := p_thldchk_Rec;
   l_thldchk_count           NUMBER ;

   CURSOR c_trig_chk_seq IS
      SELECT ams_trigger_checks_s.NEXTVAL
      FROM DUAL;

   CURSOR c_check_seq(l_my_chk_id VARCHAR2) IS
      SELECT  COUNT(*)
      FROM    ams_trigger_checks
      WHERE   trigger_check_id = l_my_chk_id;

  BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Thldchk_PVT;

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
   -- Validate Trigger Check
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   Validate_Thldchk ( p_api_version        =>   1.0
                     ,p_init_msg_list      => p_init_msg_list
                     ,p_validation_level   => p_validation_level
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     ,p_thldchk_rec        => l_thldchk_rec
                     );
   -- dbms_output.put_line('Status After Validation : '||l_return_status);
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
   END IF;

   --
   -- Find the Unique Primary Key if not sent
   --
   IF l_thldchk_rec.trigger_check_id IS NULL THEN
   LOOP
      OPEN c_trig_chk_seq;
      FETCH c_trig_chk_seq INTO l_thldchk_rec.trigger_check_id;
      CLOSE c_trig_chk_seq;

      OPEN c_check_seq(l_thldchk_rec.trigger_check_id);
      FETCH c_check_seq INTO l_thldchk_count;
      CLOSE c_check_seq;

      EXIT WHEN l_thldchk_count = 0;
   END LOOP;
   END IF;


   INSERT INTO ams_trigger_checks
      (trigger_check_id

      -- standard who columns
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login

      ,object_version_number
      ,trigger_id
      ,order_number
      ,chk1_type
      ,chk1_arc_source_code_from
      ,chk1_act_object_id
      ,chk1_source_code
      ,chk1_source_code_metric_id
      ,chk1_source_code_metric_type
      ,chk1_to_chk2_operator_type
      ,chk2_type
      ,chk2_value
      ,chk2_low_value
      ,chk2_high_value
      ,chk2_uom_code
      ,chk2_currency_code
      ,chk2_arc_source_code_from
      ,chk2_act_object_id
      ,chk2_source_code
      ,chk2_source_code_metric_id
      ,chk2_source_code_metric_type
      ,chk2_workbook_name
      ,chk2_workbook_owner
      ,chk2_worksheet_name

      )
   VALUES
      (
      l_thldchk_rec.trigger_check_id

      -- standard who columns
      ,sysdate
      ,FND_GLOBAL.User_Id
      ,sysdate
      ,FND_GLOBAL.User_Id
      ,FND_GLOBAL.Conc_Login_Id

      ,1      -- Object Version Number
      ,l_thldchk_rec.trigger_id
      ,1            -- Order Number
      ,l_thldchk_rec.chk1_type
      ,l_thldchk_rec.chk1_arc_source_code_from
      ,l_thldchk_rec.chk1_act_object_id
      ,l_thldchk_rec.chk1_source_code
      ,l_thldchk_rec.chk1_source_code_metric_id
      ,l_thldchk_rec.chk1_source_code_metric_type
      ,l_thldchk_rec.chk1_to_chk2_operator_type
      ,l_thldchk_rec.chk2_type
      ,l_thldchk_rec.chk2_value
      ,l_thldchk_rec.chk2_low_value
      ,l_thldchk_rec.chk2_high_value
      ,l_thldchk_rec.chk2_uom_code
      ,l_thldchk_rec.chk2_currency_code
      ,l_thldchk_rec.chk2_arc_source_code_from
      ,l_thldchk_rec.chk2_act_object_id
      ,l_thldchk_rec.chk2_source_code
      ,l_thldchk_rec.chk2_source_code_metric_id
      ,l_thldchk_rec.chk2_source_code_metric_type
      ,l_thldchk_rec.chk2_workbook_name
      ,l_thldchk_rec.chk2_workbook_owner
      ,l_thldchk_rec.chk2_worksheet_name

   );

   -- set OUT value
   x_trigger_check_id := l_thldchk_rec.trigger_check_id;

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
          p_encoded         =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Thldchk_PVT;
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

END Create_Thldchk;


-- Start of Comments
--
-- NAME
--   Delete_Thldchk
--
-- PURPOSE
--   This procedure is to delete a ams_trigger_checks table that satisfy caller needs
--
-- NOTES
--   This procedure won't be used from Hornet release as triggers will have to have
--   check associated with it.
--
-- HISTORY
--   06/29/1999        ptendulk         created
--   10/26/1999        ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Delete_Thldchk
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_False,
  p_commit                    IN     VARCHAR2    := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_check_id          IN     NUMBER,
  p_object_version_number     IN     NUMBER
)
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Delete_Thldchk';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Delete_Thldchk_PVT;

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
   IF NOT FND_API.Compatible_API_Call (l_api_version,
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

   DELETE FROM ams_trigger_checks
   WHERE  trigger_check_id = p_trigger_check_id
   AND    object_version_number = p_object_version_number ;

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
        p_encoded         =>      FND_API.G_FALSE
       );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );
   WHEN OTHERS THEN

      ROLLBACK TO Delete_Thldchk_PVT;
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
END Delete_Thldchk;

-- Start of Comments
--
-- NAME
--   Lock_Thldchk
--
-- PURPOSE
--   This procedure is to lock a ams_trigger_checks table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Lock_Thldchk
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_check_id          IN     NUMBER,
  p_object_version_number     IN     NUMBER
)
IS

   l_api_name       CONSTANT   VARCHAR2(30)  := 'Lock_Thldchk';
   l_api_version    CONSTANT   NUMBER        := 1.0;
   l_full_name      CONSTANT   VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_check_id     NUMBER;  -- Return value from procedures

   CURSOR C_ams_trigger_checks IS
      SELECT trigger_check_id
      FROM   ams_trigger_checks
      WHERE  trigger_check_id = p_trigger_check_id
      AND      object_version_number = p_object_version_number
      FOR UPDATE of trigger_check_id NOWAIT;

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
   -- Lock the Trigger Check
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   -- Perform the database operation
   OPEN  c_ams_trigger_checks;
   FETCH c_ams_trigger_checks INTO l_check_id;
   IF (c_ams_trigger_checks%NOTFOUND) THEN
      CLOSE c_ams_trigger_checks;
      -- Error, check the msg level and added an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('FND', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

  CLOSE C_ams_trigger_checks;

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
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
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
           p_encoded         =>      FND_API.G_FALSE
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
           p_encoded         =>      FND_API.G_FALSE
           );

END Lock_Thldchk;

-- Start of Comments
--
-- NAME
--   Update_Thldchk
--
-- PURPOSE
--   This procedure is to update a ams_trigger_checks table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Update_Thldchk
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_False,
  p_commit                     IN     VARCHAR2   := FND_API.G_False,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,

  p_thldchk_rec                IN     thldchk_rec_type
)
IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Update_Thldchk';
   l_api_version      CONSTANT NUMBER        := 1.0;
   l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   --
   -- Status Local Variables
   --
   l_return_status    VARCHAR2(1);  -- Return value from procedures
   l_thldchk_rec      thldchk_rec_type ;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Update_Thldchk_PVT;

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
      Check_thldchk_Items(
         p_thldchk_rec     => p_thldchk_rec,
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
   Complete_Thldchk_Rec(p_thldchk_rec, l_thldchk_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Thldchk_Record(
         p_thldchk_rec    => p_thldchk_rec,
         p_complete_rec   => l_thldchk_rec,
         x_return_status  => l_return_status
                        );
   -- dbms_output.put_line('Status after Validation : '||l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   UPDATE ams_trigger_checks
   SET
      last_update_date                = SYSDATE
      ,last_updated_by                =  FND_GLOBAL.User_Id
      ,last_update_login              = FND_GLOBAL.Conc_Login_Id

      ,object_version_number          = l_thldchk_rec.object_version_number + 1
      ,trigger_id                     = l_thldchk_rec.trigger_id
      ,order_number                   = l_thldchk_rec.order_number
      ,chk1_type                      = l_thldchk_rec.chk1_type
      ,chk1_arc_source_code_from      = l_thldchk_rec.chk1_arc_source_code_from
      ,chk1_act_object_id             = l_thldchk_rec.chk1_act_object_id
      ,chk1_source_code               = l_thldchk_rec.chk1_source_code
      ,chk1_source_code_metric_id     = l_thldchk_rec.chk1_source_code_metric_id
      ,chk1_source_code_metric_type   = l_thldchk_rec.chk1_source_code_metric_type
      ,chk1_to_chk2_operator_type     = l_thldchk_rec.chk1_to_chk2_operator_type
      ,chk2_type                      = l_thldchk_rec.chk2_type
      ,chk2_value                     = l_thldchk_rec.chk2_value
      ,chk2_low_value                 = l_thldchk_rec.chk2_low_value
      ,chk2_high_value                = l_thldchk_rec.chk2_high_value
      ,chk2_uom_code                  = l_thldchk_rec.chk2_uom_code
      ,chk2_currency_code             = l_thldchk_rec.chk2_currency_code
      ,chk2_source_code               = l_thldchk_rec.chk2_source_code
      ,chk2_arc_source_code_from      = l_thldchk_rec.chk2_arc_source_code_from
      ,chk2_act_object_id             = l_thldchk_rec.chk2_act_object_id
      ,chk2_source_code_metric_id     = l_thldchk_rec.chk2_source_code_metric_id
      ,chk2_source_code_metric_type   = l_thldchk_rec.chk2_source_code_metric_type
      ,chk2_workbook_name             = l_thldchk_rec.chk2_workbook_name
      ,chk2_workbook_owner            = l_thldchk_rec.chk2_workbook_owner
      ,chk2_worksheet_name            = l_thldchk_rec.chk2_worksheet_name
   WHERE   trigger_check_id = l_thldchk_Rec.trigger_check_id
   AND     object_version_number = l_thldchk_Rec.object_version_number;

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
      ROLLBACK TO Update_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Thldchk_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Thldchk_PVT;
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
END Update_Thldchk;

-- Start of Comments
--
-- NAME
--   Validate_ThldChk
--
-- PURPOSE
--   This procedure is to validate a ams_trigger_checks table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Validate_Thldchk
( p_api_version                  IN     NUMBER,
  p_init_msg_list                IN     VARCHAR2    := FND_API.G_False,
  p_validation_level             IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY    VARCHAR2,
  x_msg_count                    OUT NOCOPY    NUMBER,
  x_msg_data                     OUT NOCOPY    VARCHAR2,

  p_thldchk_Rec                  IN     thldchk_rec_type

) IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Validate_Thldchk';
   l_api_version      CONSTANT NUMBER        := 1.0;
   l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status    VARCHAR2(1);  -- Return value from procedures

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
      Check_Thldchk_Items(
         p_thldchk_rec        => p_thldchk_rec,
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
      Check_Thldchk_Record(
         p_thldchk_rec    => p_thldchk_rec,
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
           p_encoded         =>      FND_API.G_FALSE
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
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
           p_encoded         =>      FND_API.G_FALSE
           );

END Validate_thldChk;


-- Start of Comments
--
-- NAME
----   Check_Thldchk_Req_Items
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs.
--
-- NOTES
--
--
-- HISTORY
--   02/28/1999        ptendulk            created
--   10/26/1999        ptendulk         Modified according to new standards
-- End of Comments

PROCEDURE Check_Thldchk_Req_Items
   ( p_thldchk_rec                       IN     thldchk_rec_type,
     x_return_status                     OUT NOCOPY    VARCHAR2
   )
IS

BEGIN
   --  Initialize API/Procedure return status to success
   x_return_status := FND_API.G_Ret_Sts_Success;

   --
   -- Trigger ID
   --
   IF p_thldchk_rec.trigger_id IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_TRIG_ID');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   --
   -- Chk1_type
   --
   IF p_thldchk_rec.chk1_type IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_CHK1_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   --
   -- Chk2_type
   --
   IF p_thldchk_rec.chk2_type IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_CHK2_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   --
   -- Chk1_to_chk2_operator_type
   --
   IF p_thldchk_rec.chk1_to_chk2_operator_type IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_OPERATOR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- chk1_source_code_metric_id
   --
   IF p_thldchk_rec.chk1_source_code_metric_id IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_MET');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   IF p_thldchk_rec.chk1_act_object_id IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_CHK1_OBJ');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   --
   -- chk1_source_code_metric_type
   --
   IF p_thldchk_rec.chk1_source_code_metric_type IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_MET_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Check_Thldchk_Req_Items;

-- Start of Comments
--
-- NAME
--   Check_ThldChk_uk_Items
--
-- PURPOSE
--   This procedure is to validate Unique Key in AMS_TRIGGER_CHECKs
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk            created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldchk_Uk_Items(
   p_thldchk_rec     IN  thldchk_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_where_clause VARCHAR2(500);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_thldchk, when trigger_check_id is passed in, we need to
   -- check if this trigger_check_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_thldchk_rec.trigger_check_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
         'ams_trigger_checks',
         'trigger_check_id = ' || p_thldchk_rec.trigger_check_id
         ) = FND_API.g_false
     THEN
        AMS_Utility_PVT.Error_Message('AMS_TRIG_DUPLICATE_CHECK');
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;
   -- check other unique items

   -- Check if Trigger_id is unique. Need to handle create and
   -- update differently.
   -- Unique TRIGGER_NAME and TRIGGER_CREATED_FOR
   l_where_clause := ' trigger_id = '|| p_thldchk_rec.trigger_id ;

   -- For Updates, must also check that uniqueness is not checked against the same record.
   IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      l_where_clause := l_where_clause || ' AND trigger_check_id <> ' || p_thldchk_rec.trigger_check_id;
   END IF;

   IF AMS_Utility_PVT.Check_Uniqueness(
      p_table_name      => 'ams_trigger_checks',
      p_where_clause    => l_where_clause
      ) = FND_API.g_false
   THEN
      AMS_Utility_PVT.Error_Message('AMS_TRIG_DUP_TRIG_ID');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Thldchk_Uk_Items;

-- Start of Comments
--
-- NAME
--   Check_ThldChk_FK_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_checks Foreign Key items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldchk_Fk_Items(
   p_thldchk_rec        IN   thldchk_rec_type,
   x_return_status      OUT NOCOPY  VARCHAR2
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
   IF p_thldchk_rec.trigger_id <> FND_API.G_MISS_NUM
   THEN
      l_table_name               :=   'AMS_TRIGGERS' ;
      l_pk_name                  :=   'trigger_id' ;
      l_pk_value                 :=   p_thldchk_rec.trigger_id;
      l_pk_data_type             :=   AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  :=   NULL ;

      IF AMS_Utility_PVT.Check_Fk_Exists
         (p_table_name               => l_table_name
         ,p_PK_name                  => l_pk_name
         ,p_PK_value                  => l_pk_value
         ,p_pk_data_type              => l_pk_data_type
         ,p_additional_where_clause    => l_additional_where_clause
         ) = FND_API.G_FALSE THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_TRIGGER_ID');
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;

   END IF;

End Check_Thldchk_Fk_Items ;

-- Start of Comments
--
-- NAME
--   Check_ThldChk_Lookup_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_checks Lookup items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999        ptendulk        Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldchk_Lookup_Items(
   p_thldchk_rec        IN  thldchk_rec_type,
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
   -- Check Chk2_type
   IF p_thldchk_rec.chk2_type <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
       ,p_lookup_type      => 'AMS_TRIGGER_CHK_TYPE'
       ,p_lookup_code      => p_thldchk_rec.chk2_type
       ) = FND_API.G_FALSE
      THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CHECK_TYPE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;

   --
   -- Check CHK1_SOURCE_CODE_METRIC_TYPE
   --
   IF p_thldchk_rec.chk1_source_code_metric_type <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
       ,p_lookup_type      => 'AMS_MONITOR_CHK_METRIC_TYPE'
       ,p_lookup_code      => p_thldchk_rec.chk1_source_code_metric_type
       ) = FND_API.G_FALSE
      THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_METRIC_TYPE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;

End Check_Thldchk_Lookup_Items ;

-- Start of Comments
--
-- NAME
--   Check_ThldChk_Items
--
-- PURPOSE
--   This procedure is to validate ams_trigger_checks items
--
-- NOTES
--
--
-- HISTORY
--   06/28/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldchk_Items(
   p_thldchk_rec     IN  thldchk_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   Check_Thldchk_Req_Items(
      p_thldchk_rec    => p_thldchk_rec,
      x_return_status  => x_return_status
   );
-- dbms_output.put_line('Status After REQ Test : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Thldchk_Uk_Items(
      p_thldchk_rec        => p_thldchk_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );
-- dbms_output.put_line('Status After UK Test : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Thldchk_Fk_Items(
      p_thldchk_rec       => p_thldchk_rec,
      x_return_status  => x_return_status
   );
-- dbms_output.put_line('Status After FK Test : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   Check_Thldchk_Lookup_Items(
      p_thldchk_rec     => p_thldchk_rec,
      x_return_status   => x_return_status
   );
-- dbms_output.put_line('Status After LOOKUP Test : '||x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Thldchk_Items;

-- Start of Comments
--
-- NAME
--   Validate_Thldchk_Record
--
-- PURPOSE
--   This procedure is to validate ams_trigger_checks table.
--   This is an example if you need to call validation procedure from the UI site.
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk        Created
--   10/26/1999         ptendulk         Modified according to new standards
-- End of Comments
PROCEDURE Check_Thldchk_Record(
   p_thldchk_rec    IN  thldchk_rec_type,
   p_complete_rec   IN  thldchk_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   l_thldchk_rec  thldchk_rec_type := p_thldchk_rec ;

   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   -- added by soagrawa on 23-aug-2002 for bug# 2528692
   l_pk_wb_value                 VARCHAR2(254);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.

   CURSOR c_met_det(l_act_met_id NUMBER) IS
   SELECT act.metric_uom_code metric_uom_code,
          act.transaction_currency_code transaction_currency_code,
          met.uom_type
   FROM   ams_act_metrics_all act,ams_metrics_all_b met
   WHERE  act.activity_metric_id =  l_act_met_id
   AND    act.metric_id = met.metric_id ;

   l_chk1_met_rec c_met_det%ROWTYPE;
   l_chk2_met_rec c_met_det%ROWTYPE;

--   CURSOR c_source_det(l_source_code VARCHAR2) IS
--   SELECT campaign_id
--   FROM     ams_campaigns_vl
--   WHERE  source_code = l_source_code ;

   -- Added By ptendulk on Dec30-1999 as
   -- Check2 can be coming from Events

--   CURSOR c_source_det_eveh(l_source_code VARCHAR2) IS
--   SELECT event_header_id
--   FROM     ams_event_headers_vl
--   WHERE  source_code = l_source_code ;

--   CURSOR c_source_det_eveo(l_source_code VARCHAR2) IS
--   SELECT event_offer_id
--   FROM     ams_event_offers_vl
--   WHERE  source_code = l_source_code ;

--   l_chk1_camp_id     NUMBER ;
--   l_chk2_source_id     NUMBER ;


BEGIN
   --
   -- Initialize the Out Variable
   --
   x_return_status := FND_API.g_ret_sts_success;

   -- Check start date time
   IF p_thldchk_rec.chk1_arc_source_code_from <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk1_act_object_id <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk1_source_code_metric_id <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk1_source_code_metric_type  <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk1_to_chk2_operator_type <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk2_type <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk2_value <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk2_low_value <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk2_high_value <> FND_API.G_MISS_NUM
   --OR p_thldchk_rec.chk2_uom_code <> FND_API.G_MISS_CHAR
   --OR p_thldchk_rec.chk2_currency_code <> FND_API.G_MISS_CHAR
   --OR p_thldchk_rec.chk2_source_code <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk2_arc_source_code_from <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk2_act_object_id <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk2_source_code_metric_id <> FND_API.G_MISS_NUM
   OR p_thldchk_rec.chk2_source_code_metric_type  <> FND_API.G_MISS_CHAR
   OR p_thldchk_rec.chk2_workbook_name   <> FND_API.G_MISS_CHAR
   THEN

      IF p_thldchk_rec.chk1_arc_source_code_from = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk1_arc_source_code_from := p_complete_rec.chk1_arc_source_code_from ;
      END IF;

      IF p_thldchk_rec.chk1_act_object_id = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk1_act_object_id := p_complete_rec.chk1_act_object_id ;
      END IF;

      --IF p_thldchk_rec.chk1_source_code = FND_API.G_MISS_CHAR THEN
      --    l_thldchk_rec.chk1_source_code := p_complete_rec.chk1_source_code ;
      --END IF;

      IF p_thldchk_rec.chk1_source_code_metric_id = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk1_source_code_metric_id := p_complete_rec.chk1_source_code_metric_id ;
      END IF;

      IF p_thldchk_rec.chk1_source_code_metric_type = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk1_source_code_metric_type := p_complete_rec.chk1_source_code_metric_type ;
      END IF;

      IF p_thldchk_rec.chk1_to_chk2_operator_type = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk1_to_chk2_operator_type := p_complete_rec.chk1_to_chk2_operator_type ;
      END IF;

      IF p_thldchk_rec.chk2_type = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_type := p_complete_rec.chk2_type ;
      END IF;

      IF p_thldchk_rec.chk2_value = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk2_value := p_complete_rec.chk2_value ;
      END IF;

      IF p_thldchk_rec.chk2_low_value = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk2_low_value := p_complete_rec.chk2_low_value ;
      END IF;

      IF p_thldchk_rec.chk2_high_value = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk2_high_value := p_complete_rec.chk2_high_value ;
      END IF;

      IF p_thldchk_rec.chk2_uom_code = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_uom_code := p_complete_rec.chk2_uom_code ;
      END IF;

      IF p_thldchk_rec.chk2_currency_code = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_currency_code := p_complete_rec.chk2_currency_code ;
      END IF;

      --IF p_thldchk_rec.chk2_source_code = FND_API.G_MISS_CHAR THEN
      --   l_thldchk_rec.chk2_source_code := p_complete_rec.chk2_source_code ;
      --END IF;

      IF p_thldchk_rec.chk2_arc_source_code_from = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_arc_source_code_from := p_complete_rec.chk2_arc_source_code_from ;
      END IF;

      IF p_thldchk_rec.chk2_act_object_id = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk2_act_object_id := p_complete_rec.chk2_act_object_id ;
      END IF;

      IF p_thldchk_rec.chk2_source_code_metric_id = FND_API.G_MISS_NUM THEN
         l_thldchk_rec.chk2_source_code_metric_id := p_complete_rec.chk2_source_code_metric_id ;
      END IF;

      IF p_thldchk_rec.chk2_source_code_metric_type = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_source_code_metric_type := p_complete_rec.chk2_source_code_metric_type ;
      END IF;

      IF p_thldchk_rec.chk2_workbook_name = FND_API.G_MISS_CHAR THEN
         l_thldchk_rec.chk2_workbook_name := p_complete_rec.chk2_workbook_name ;
      END IF;


      --OPEN c_source_det(l_thldchk_rec.chk1_source_code);
      --FETCH c_source_det INTO l_chk1_camp_id ;
      --CLOSE c_source_det ;
      --
      -- Check Chk1_source_code_Metric_id
      --

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('Sonali 1');

      END IF;

      l_table_name            := 'ams_act_metrics_all' ;
      l_pk_name               := 'activity_metric_id' ;
      l_pk_value              := l_thldchk_rec.chk1_source_code_metric_id ;
      l_pk_data_type           := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause := ' arc_act_metric_used_by = '||''''
                           ||l_thldchk_rec.chk1_arc_source_code_from||''''
                           ||' AND act_metric_used_by_id = '||l_thldchk_rec.chk1_act_object_id  ;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('Sonali 2');

      END IF;

/*      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CREATED_FOR');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
*/
      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('Sonali 3');

      END IF;

      --
      -- Do the not null check first
      --
      IF l_thldchk_rec.chk2_type      = 'METRIC'        THEN
         IF  (l_thldchk_rec.chk2_source_code_metric_id IS NULL OR
            l_thldchk_rec.chk2_arc_source_code_from IS NULL OR
            l_thldchk_rec.chk2_act_object_id IS NULL )
         THEN
            AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_CHK2_OBJ');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         ELSIF l_thldchk_rec.chk2_source_code_metric_type IS NULL
         THEN
            AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_MET_TYPE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF ;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('Sonali 4');

      END IF;

         --
         -- Chk2_source code_metric_id
         --
         IF (p_thldchk_rec.chk2_source_code_metric_id IS NOT NULL AND
           p_thldchk_rec.chk2_source_code_metric_id <> FND_API.G_MISS_NUM ) OR
          (p_thldchk_rec.chk2_act_object_id IS NOT NULL AND
           p_thldchk_rec.chk2_act_object_id <> FND_API.G_MISS_NUM )
         THEN
            -- Added By ptendulk on Dec30-1999 as
            -- Check2 can be coming from Events
            -- commented by ptendulk on 15-Feb-2001 as  not required for the hornet
            --IF l_thldchk_rec.chk2_arc_source_code_from = 'CAMP' THEN
            --  OPEN c_source_det(l_thldchk_rec.chk2_source_code);
            --   FETCH c_source_det INTO l_chk2_source_id ;
            --   CLOSE c_source_det ;
            --ELSIF l_thldchk_rec.chk2_arc_source_code_from = 'EVEH' THEN
            --   OPEN c_source_det_eveh(l_thldchk_rec.chk2_source_code);
            --   FETCH c_source_det_eveh INTO l_chk2_source_id ;
            --   CLOSE c_source_det_eveh ;
            --ELSIF l_thldchk_rec.chk2_arc_source_code_from = 'EVEO' THEN
            --   OPEN c_source_det_eveo(l_thldchk_rec.chk2_source_code);
            --   FETCH c_source_det_eveo INTO l_chk2_source_id ;
            --   CLOSE c_source_det_eveo ;
            --END IF;

            l_table_name            := 'ams_act_metrics_all' ;
            l_pk_name               := 'activity_metric_id' ;
            l_pk_value              := l_thldchk_rec.chk2_source_code_metric_id ;
            l_pk_data_type          := AMS_Utility_PVT.G_NUMBER;
            l_additional_where_clause := ' arc_act_metric_used_by = '||''''
                             ||l_thldchk_rec.chk2_arc_source_code_from||''''
                           ||' AND act_metric_used_by_id  = '||l_thldchk_rec.chk2_act_object_id ;

            IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message('Sonali 5');

            END IF;
            IF AMS_Utility_PVT.Check_FK_Exists (
                p_table_name                   => l_table_name
               ,p_pk_name                      => l_pk_name
               ,p_pk_value                     => l_pk_value
               ,p_pk_data_type                 => l_pk_data_type
               ,p_additional_where_clause      => l_additional_where_clause
             ) = FND_API.G_FALSE
            THEN
               AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CHK2_MET');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
            END IF;
         END IF;

      END IF;

      IF l_thldchk_rec.chk2_type      = 'DIWB'     THEN
         IF  l_thldchk_rec.chk2_workbook_name IS NULL
         THEN
            AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_WB_NAME');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         ELSE
            --
            -- Chk2_workbook_name
            --

            IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message('Sonali 6');

            END IF;

            IF (p_thldchk_rec.chk2_workbook_name IS NOT NULL AND
               p_thldchk_rec.chk2_workbook_name <> FND_API.G_MISS_CHAR )
            THEN
               l_table_name            := 'ams_discoverer_sql' ;
               l_pk_name               := 'workbook_name' ;
               -- modified by soagrawa on 23-aug-2002 for bug# 2528692
               l_pk_wb_value              := l_thldchk_rec.chk2_workbook_name ;
               l_pk_data_type           := AMS_Utility_PVT.G_VARCHAR2;
               l_additional_where_clause := NULL ;

               IF (AMS_DEBUG_HIGH_ON) THEN



               AMS_Utility_PVT.debug_message('Sonali 7');

               END IF;

               IF AMS_Utility_PVT.Check_FK_Exists (
                   p_table_name                   => l_table_name
                  ,p_pk_name                      => l_pk_name
                  -- modified by soagrawa on 23-aug-2002 for bug# 2528692
                  ,p_pk_value                     => l_pk_wb_value
                  ,p_pk_data_type                 => l_pk_data_type
                  ,p_additional_where_clause      => l_additional_where_clause
                 ) = FND_API.G_FALSE
               THEN
                  AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_WB_NAME');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF ;

      IF l_thldchk_rec.chk2_type      = 'STATIC_VALUE' THEN
         --
         -- Chk2_low_value and High Value
         --
         IF l_thldchk_rec.chk1_to_chk2_operator_type = 'BETWEEN' THEN
            IF l_thldchk_rec.chk2_low_value IS NULL OR
               l_thldchk_rec.chk2_high_value IS NULL
            THEN
               AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_CHK2_RANGE');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
            ELSE
               IF l_thldchk_rec.chk2_low_value > l_thldchk_rec.chk2_high_value
               THEN
                  AMS_Utility_PVT.Error_Message('AMS_TRIG_INVALID_CHK2_RANGE');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN;
               END IF;
            END IF ;
         ELSE
            IF l_thldchk_rec.chk2_value IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_TRIG_MISSING_VALUE');
               x_return_status := FND_API.G_RET_STS_ERROR ;
               RETURN ;
            END IF ;
         END IF;

      END IF ;

      -- Start of code commented by ptendulk on 15-Feb-2001 as UOM and frequency will not be used any more
      -- dbms_output.put_line('Stat Before Value Check : '||x_return_status);
      -- When The RHS of the Check is Value then the Default UOM for the Value will be
      -- UOM of the Metric , Same applies for Currencies. But user can always change it.
      --
      --IF l_thldchk_rec.chk2_value IS NOT NULL OR
      --   l_thldchk_rec.chk2_low_value IS NOT NULL OR
      --   l_thldchk_rec.chk2_high_value IS NOT NULL
      --THEN
      --   -- Following code is changed by ptendulk on 14th Feb 2000 as
      --   -- UOM is not mandatory now in Metrics now.
      --   -- If the uom of chk1 is null then uom of chk2 has to be null
      --   OPEN c_met_det(l_thldchk_rec.chk1_source_code_metric_id);
      --   FETCH c_met_det INTO l_chk1_met_rec ;
      --   CLOSE c_met_det ;

      --   IF l_thldchk_rec.chk2_uom_code IS NOT NULL
      --   THEN
      --      IF l_chk1_met_rec.metric_uom_code IS NULL THEN
      --         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --         THEN
      --           FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_UOM_NULL');
      --           FND_MSG_PUB.Add;
      --         END IF;
      --         x_return_status := FND_API.G_RET_STS_ERROR;
      --         RETURN;
      --      ELSE
      --         --
      --         --If the RHS of the Check is Static Value Check UOM  Entered is Valid
      --         --
      --         l_table_name               := 'MTL_UNITS_OF_MEASURE';
      --         l_pk_name                  := 'UOM_CODE';
      --         l_pk_value                 := l_thldchk_rec.chk2_uom_code;
      --         l_pk_data_type             := AMS_Utility_PVT.G_VARCHAR2;
      --         l_additional_where_clause  := ' uom_class = '||''''||l_chk1_met_rec.uom_type||'''';

      --         IF AMS_Utility_PVT.Check_FK_Exists (
      --             p_table_name              => l_table_name
      --             ,p_pk_name                  => l_pk_name
      --             ,p_pk_value                  => l_pk_value
      --             ,p_pk_data_type               => l_pk_data_type
      --             ,p_additional_where_clause  => l_additional_where_clause
      --                               ) = FND_API.G_FALSE
      --         THEN
      --           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --           THEN
      --              FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_UOM');
      --              FND_MSG_PUB.Add;
      --           END IF;

      --           x_return_status := FND_API.G_RET_STS_ERROR;
      --           RETURN;
      --         END IF; -- Check_FK_Exists--
      --      END IF;
      --   ELSE
      --      IF l_chk1_met_rec.metric_uom_code IS NOT NULL THEN
      --        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --      THEN
      --        FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_UOM_NULL');
      --        FND_MSG_PUB.Add;
      --      END IF;

      --      x_return_status := FND_API.G_RET_STS_ERROR;
      --      RETURN;
      --   END IF ;
      --END IF;


      --   IF l_thldchk_rec.chk2_currency_code IS NOT NULL THEN
      --      IF l_chk1_met_rec.transaction_currency_code IS NULL THEN
      --        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --      THEN
      --        FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_CURR_NULL');
      --        FND_MSG_PUB.Add;
      --       END IF;

      --       x_return_status := FND_API.G_RET_STS_ERROR;
      --     RETURN;
      --      ELSE
      --          --
      --          -- If the RHS of the Check is Static Value Check Currency Entered is Valid
      --          --
      --          l_table_name               := 'FND_CURRENCIES';
      --          l_pk_name                  := 'CURRENCY_CODE';
      --          l_pk_value                 := l_thldchk_rec.chk2_currency_code;
      --          l_pk_data_type             := AMS_Utility_PVT.G_VARCHAR2;
      --          l_additional_where_clause  := ' enabled_flag = '||''''||'Y'||'''';

      --          IF AMS_Utility_PVT.Check_FK_Exists (
      --             p_table_name              => l_table_name
      --            ,p_pk_name                  => l_pk_name
      --            ,p_pk_value                  => l_pk_value
      --           ,p_pk_data_type               => l_pk_data_type
      --            ,p_additional_where_clause  => l_additional_where_clause
      --              ) = FND_API.G_FALSE
      --         THEN
      --           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --           THEN
      --              FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_CURR');
      --            FND_MSG_PUB.Add;
      --   END IF;

      --      x_return_status := FND_API.G_RET_STS_ERROR;
      --        RETURN;
      --         END IF;  -- Check_FK_Exists
      --      END IF;
      --   ELSE
      --      IF l_chk1_met_rec.transaction_currency_code IS NOT NULL THEN
      --        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --      THEN
      --        FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_CURR_NULL');
      --        FND_MSG_PUB.Add;
      --END IF;

      --x_return_status := FND_API.G_RET_STS_ERROR;
      --     RETURN;
      --      END IF ;
      --   END IF;
      --END IF;
      -- Start of code commented by ptendulk on 15-Feb-2001 as UOM and frequency will not be used any more

      -- dbms_output.put_line('Before Metric Comparison : '||x_return_status);
      -- Check the UOM and The Currency code of both Metrics are same
      -- if the RHS of Check is Metrics
      --IF l_thldchk_rec.chk2_type = 'METRIC' THEN
      --   -- If the RHS of the Check is Metric then Check that the RHS and LHS Metric
      --   -- Has same Currency as well as same UOM
      --   OPEN c_met_det(l_thldchk_rec.chk1_source_code_metric_id);
      --   FETCH c_met_det INTO l_chk1_met_rec ;
      ---   CLOSE c_met_det ;

      --  OPEN c_met_det(l_thldchk_rec.chk2_source_code_metric_id);
      --  FETCH c_met_det INTO l_chk2_met_rec ;
      --  CLOSE c_met_det ;

      --  IF l_chk1_met_rec.transaction_currency_code <> l_chk2_met_rec.transaction_currency_code
      --  OR l_chk1_met_rec.metric_uom_code <> l_chk2_met_rec.metric_uom_code THEN
      --     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --     THEN
      --      FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_UOM_CURR');
      --      FND_MSG_PUB.Add;
      --   END IF;

      --   x_return_status := FND_API.G_RET_STS_ERROR;
      --   RETURN;

      --  END IF ;
      --END IF;
      -- Start of code commented by ptendulk on 15-Feb-2001 as UOM and frequency will not be used any more
   END IF;

END Check_Thldchk_Record;

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
-- End of Comments
PROCEDURE Init_Thldchk_Rec(
   x_thldchk_rec  OUT NOCOPY  thldchk_rec_type
)
IS
BEGIN
    x_thldchk_rec.trigger_check_id              := FND_API.G_MISS_NUM ;
    x_thldchk_rec.last_update_date              := FND_API.G_MISS_DATE ;
    x_thldchk_rec.last_updated_by               := FND_API.G_MISS_NUM ;
    x_thldchk_rec.creation_date                 := FND_API.G_MISS_DATE ;
    x_thldchk_rec.created_by                    := FND_API.G_MISS_NUM ;
    x_thldchk_rec.last_update_login             := FND_API.G_MISS_NUM ;
    x_thldchk_rec.object_version_number         := FND_API.G_MISS_NUM ;
    x_thldchk_rec.trigger_id                    := FND_API.G_MISS_NUM ;
    x_thldchk_rec.order_number                  := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk1_type                     := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk1_arc_source_code_from     := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk1_act_object_id            := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk1_source_code              := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk1_source_code_metric_id    := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk1_source_code_metric_type  := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk1_to_chk2_operator_type    := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_type                     := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_value                    := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk2_low_value                := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk2_high_value               := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk2_uom_code                 := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_currency_code            := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_source_code              := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_arc_source_code_from     := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_act_object_id            := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk2_source_code_metric_id    := FND_API.G_MISS_NUM ;
    x_thldchk_rec.chk2_source_code_metric_type  := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_workbook_name            := FND_API.G_MISS_CHAR ;
    x_thldchk_rec.chk2_workbook_owner           := FND_API.G_MISS_CHAR ;
     x_thldchk_rec.chk2_worksheet_name           := FND_API.G_MISS_CHAR ;


END Init_Thldchk_Rec ;

-- Start of Comments
--
-- NAME
--   Complete_Thldchk_Rec
--
-- PURPOSE
--   This procedure is to Initialize the check Record before Updation
--
-- NOTES
--
--
-- HISTORY
--   10/26/1999         ptendulk         Created
-- End of Comments

PROCEDURE Complete_Thldchk_rec(
   p_thldchk_rec   IN  thldchk_rec_type,
   x_complete_rec  OUT NOCOPY thldchk_rec_type
)
IS

   CURSOR c_thldchk IS
   SELECT *
     FROM ams_trigger_checks
    WHERE trigger_check_id = p_thldchk_rec.trigger_check_id;

   l_thldchk_rec  c_thldchk%ROWTYPE;

BEGIN

   x_complete_rec := p_thldchk_rec;

   OPEN c_thldchk;
   FETCH c_thldchk INTO l_thldchk_rec;
   IF c_thldchk%NOTFOUND THEN
      CLOSE c_thldchk;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_thldchk;

   IF p_thldchk_rec.trigger_id = FND_API.g_miss_num THEN
      x_complete_rec.trigger_id := l_thldchk_rec.trigger_id;
   END IF;

   IF p_thldchk_rec.order_number = FND_API.g_miss_num THEN
      x_complete_rec.order_number := l_thldchk_rec.order_number;
   END IF;

   IF p_thldchk_rec.chk1_type = FND_API.g_miss_char THEN
      x_complete_rec.chk1_type := l_thldchk_rec.chk1_type;
   END IF;

   IF p_thldchk_rec.chk1_arc_source_code_from = FND_API.g_miss_char THEN
      x_complete_rec.chk1_arc_source_code_from := l_thldchk_rec.chk1_arc_source_code_from;
   END IF;

   IF p_thldchk_rec.chk1_act_object_id = FND_API.g_miss_num THEN
      x_complete_rec.chk1_act_object_id := l_thldchk_rec.chk1_act_object_id;
   END IF;

   IF p_thldchk_rec.chk1_source_code = FND_API.g_miss_char THEN
      x_complete_rec.chk1_source_code := l_thldchk_rec.chk1_source_code;
   END IF;

   IF p_thldchk_rec.chk1_source_code_metric_id = FND_API.g_miss_num THEN
      x_complete_rec.chk1_source_code_metric_id := l_thldchk_rec.chk1_source_code_metric_id;
   END IF;

   IF p_thldchk_rec.chk1_source_code_metric_type = FND_API.g_miss_char THEN
      x_complete_rec.chk1_source_code_metric_type := l_thldchk_rec.chk1_source_code_metric_type;
   END IF;

   IF p_thldchk_rec.chk1_to_chk2_operator_type = FND_API.g_miss_char THEN
      x_complete_rec.chk1_to_chk2_operator_type := l_thldchk_rec.chk1_to_chk2_operator_type;
   END IF;

   IF p_thldchk_rec.chk2_type  = FND_API.g_miss_char THEN
      x_complete_rec.chk2_type  := l_thldchk_rec.chk2_type ;
   END IF;

   IF p_thldchk_rec.chk2_value = FND_API.g_miss_num THEN
      x_complete_rec.chk2_value := l_thldchk_rec.chk2_value;
   END IF;

   IF p_thldchk_rec.chk2_low_value = FND_API.g_miss_num THEN
      x_complete_rec.chk2_low_value := l_thldchk_rec.chk2_low_value;
   END IF;

   IF p_thldchk_rec.chk2_high_value = FND_API.g_miss_num THEN
      x_complete_rec.chk2_high_value:= l_thldchk_rec.chk2_high_value;
   END IF;

   IF p_thldchk_rec.chk2_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.chk2_uom_code := l_thldchk_rec.chk2_uom_code;
   END IF;

   IF p_thldchk_rec.chk2_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.chk2_currency_code:= l_thldchk_rec.chk2_currency_code;
   END IF;

   IF p_thldchk_rec.chk2_source_code = FND_API.g_miss_char THEN
      x_complete_rec.chk2_source_code := l_thldchk_rec.chk2_source_code;
   END IF;

   IF p_thldchk_rec.chk2_arc_source_code_from = FND_API.g_miss_char THEN
      x_complete_rec.chk2_arc_source_code_from := l_thldchk_rec.chk2_arc_source_code_from;
   END IF;

   IF p_thldchk_rec.chk2_act_object_id = FND_API.g_miss_num THEN
      x_complete_rec.chk2_act_object_id := l_thldchk_rec.chk2_act_object_id;
   END IF;

   IF p_thldchk_rec.chk2_source_code_metric_id = FND_API.g_miss_num THEN
      x_complete_rec.chk2_source_code_metric_id := l_thldchk_rec.chk2_source_code_metric_id;
   END IF;

   IF p_thldchk_rec.chk2_source_code_metric_type  = FND_API.g_miss_char THEN
      x_complete_rec.chk2_source_code_metric_type  := l_thldchk_rec.chk2_source_code_metric_type ;
   END IF;

   IF p_thldchk_rec.chk2_workbook_name  = FND_API.g_miss_char THEN
      x_complete_rec.chk2_workbook_name  := l_thldchk_rec.chk2_workbook_name ;
   END IF;

   IF p_thldchk_rec.chk2_workbook_owner  = FND_API.g_miss_char THEN
      x_complete_rec.chk2_workbook_owner  := l_thldchk_rec.chk2_workbook_owner  ;
   END IF;

   IF p_thldchk_rec.chk2_worksheet_name  = FND_API.g_miss_char THEN
      x_complete_rec.chk2_worksheet_name  := l_thldchk_rec.chk2_worksheet_name  ;
   END IF;
END Complete_Thldchk_rec ;

END AMS_ThldChk_PVT;

/
