--------------------------------------------------------
--  DDL for Package Body AMS_CAL_CRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAL_CRT_PVT" as
/* $Header: amsvcctb.pls 115.13 2003/03/09 20:14:21 ptendulk noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Cal_Crt_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Cal_Crt_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcctb.pls';
-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE Default_Cal_Crt_Rec_Items (
   p_cal_crt_rec_rec IN  cal_crt_rec_rec_type ,
   x_cal_crt_rec_rec OUT NOCOPY cal_crt_rec_rec_type
) ;
-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Cal_Crt
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_cal_crt_rec_rec            IN   cal_crt_rec_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================
PROCEDURE Create_Cal_Crt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cal_crt_rec_rec            IN   cal_crt_rec_rec_type  := g_miss_cal_crt_rec_rec,
    x_criteria_id                OUT NOCOPY  NUMBER
    )
 IS
L_API_NAME                       CONSTANT VARCHAR2(30) := 'Create_Cal_Crt';
L_API_VERSION_NUMBER             CONSTANT NUMBER   := 1.0;
   l_return_status_full          VARCHAR2(1);
   l_object_version_number       NUMBER := 1;
--   l_org_id                      NUMBER := FND_API.G_MISS_NUM;
   l_criteria_id                 NUMBER;
   l_dummy                       NUMBER;
   l_cal_crt_rec_rec       cal_crt_rec_rec_type := p_cal_crt_rec_rec;

  CURSOR c_id IS
      SELECT ams_calendar_criteria_s.NEXTVAL
      FROM dual;
   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ams_calendar_criteria
      WHERE criteria_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_cal_crt_pvt;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- =========================================================================
      -- Validate Environment
      -- =========================================================================
      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Cal_Crt');
          END IF;
       --  Charu: Populate the default required items.
           l_cal_crt_rec_rec.last_update_date      := SYSDATE;
           l_cal_crt_rec_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_cal_crt_rec_rec.creation_date         := SYSDATE;
           l_cal_crt_rec_rec.created_by            := FND_GLOBAL.user_id;
           l_cal_crt_rec_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_cal_crt_rec_rec.object_version_number := l_object_version_number;
          -- Invoke validation procedures
          Validate_cal_crt(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_cal_crt_rec_rec  =>  l_cal_crt_rec_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   -- Local variable initialization
   IF l_cal_crt_rec_rec.criteria_id IS NULL OR l_cal_crt_rec_rec.criteria_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_criteria_id;
         CLOSE c_id;
         OPEN c_id_exists(l_criteria_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_criteria_id := l_cal_crt_rec_rec.criteria_id;
   END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Ams_Cal_Crt_Pkg.Insert_Row)
      Ams_Cal_Crt_Pkg.Insert_Row(
          px_criteria_id  => l_criteria_id,
          p_object_type_code  => l_cal_crt_rec_rec.object_type_code,
          p_custom_setup_id  => l_cal_crt_rec_rec.custom_setup_id,
          p_activity_type_code  => l_cal_crt_rec_rec.activity_type_code,
          p_activity_id  => l_cal_crt_rec_rec.activity_id,
          p_status_id  => l_cal_crt_rec_rec.status_id,
          p_priority_id  => l_cal_crt_rec_rec.priority_id,
          p_object_id  => l_cal_crt_rec_rec.object_id,
          p_criteria_start_date  => l_cal_crt_rec_rec.criteria_start_date,
          p_criteria_end_date  => l_cal_crt_rec_rec.criteria_end_date,
          p_criteria_deleted  => l_cal_crt_rec_rec.criteria_deleted,
          p_criteria_enabled  => l_cal_crt_rec_rec.criteria_enabled,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number
);

          x_criteria_id := l_criteria_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Cal_Crt;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Cal_Crt
--   Type
--           Private
--   Pre-Req
--
--   Parameters

--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_cal_crt_rec_rec            IN   cal_crt_rec_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Cal_Crt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cal_crt_rec_rec               IN    cal_crt_rec_rec_type
    )
 IS
CURSOR c_get_cal_crt(criteria_id NUMBER) IS
    SELECT *
    FROM  ams_calendar_criteria
    WHERE  criteria_id = p_cal_crt_rec_rec.criteria_id;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Cal_Crt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_criteria_id    NUMBER;
l_ref_cal_crt_rec_rec  c_get_Cal_Crt%ROWTYPE ;
l_tar_cal_crt_rec_rec  cal_crt_rec_rec_type := P_cal_crt_rec_rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_cal_crt_pvt;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

     -- Charu added
   l_tar_cal_crt_rec_rec.last_update_date      := SYSDATE;
   l_tar_cal_crt_rec_rec.last_updated_by       := FND_GLOBAL.user_id;
   l_tar_cal_crt_rec_rec.last_update_login     := FND_GLOBAL.conc_login_id;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('l_tar_cal_crt_rec_rec.criteria_deleted: ' || l_tar_cal_crt_rec_rec.criteria_deleted);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('l_tar_cal_crt_rec_rec.criteria_id: ' || l_tar_cal_crt_rec_rec.criteria_id);
   END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;
      IF ( (l_tar_cal_crt_rec_rec.criteria_deleted = 'Y') AND (l_tar_cal_crt_rec_rec.criteria_enabled = 'Y') ) THEN
   x_return_status := FND_API.g_ret_sts_error;
--   AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CAL_CRT_ENABLED_DELETE');
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name ('AMS', 'AMS_CAL_CRT_ENABLED_DELETE');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        OPEN c_get_Cal_Crt( l_tar_cal_crt_rec_rec.criteria_id);
        FETCH c_get_Cal_Crt INTO l_ref_cal_crt_rec_rec  ;
   If ( c_get_Cal_Crt%NOTFOUND) THEN
     AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
     p_token_name   => 'INFO',
     p_token_value  => 'Cal_Crt'
     ) ;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE     c_get_Cal_Crt;

   If (l_tar_cal_crt_rec_rec.object_version_number is NULL or
     l_tar_cal_crt_rec_rec.object_version_number = FND_API.G_MISS_NUM ) Then
     AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
    p_token_name   => 'COLUMN',
    p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
   End if;
   -- Check Whether record has been changed by someone else
   If (l_tar_cal_crt_rec_rec.object_version_number <> l_ref_cal_crt_rec_rec.object_version_number) Then
      AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
      p_token_name   => 'INFO',
      p_token_value  => 'Cal_Crt') ;
      raise FND_API.G_EXC_ERROR;
   End if;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Cal_Crt');
          END IF;
          -- Invoke validation procedures
          Validate_cal_crt(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_cal_crt_rec_rec  =>  l_tar_cal_crt_rec_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
   END IF;

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Calling Table Handler Update');
   END IF;
   -- Invoke table handler(Ams_Cal_Crt_Pkg.Update_Row)
   Ams_Cal_Crt_Pkg.Update_Row(
          p_criteria_id  => l_tar_cal_crt_rec_rec.criteria_id,
          p_object_type_code  => l_tar_cal_crt_rec_rec.object_type_code,
          p_custom_setup_id  => l_tar_cal_crt_rec_rec.custom_setup_id,
          p_activity_type_code  => l_tar_cal_crt_rec_rec.activity_type_code,
          p_activity_id  => l_tar_cal_crt_rec_rec.activity_id,
          p_status_id  => l_tar_cal_crt_rec_rec.status_id,
          p_priority_id  => l_tar_cal_crt_rec_rec.priority_id,
          p_object_id  => l_tar_cal_crt_rec_rec.object_id,
          p_criteria_start_date  => l_tar_cal_crt_rec_rec.criteria_start_date,
          p_criteria_end_date  => l_tar_cal_crt_rec_rec.criteria_end_date,
          p_criteria_deleted  => l_tar_cal_crt_rec_rec.criteria_deleted,
          p_criteria_enabled  => l_tar_cal_crt_rec_rec.criteria_enabled,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => l_tar_cal_crt_rec_rec.object_version_number
     );
   --
   -- End of API body.
   --
      END IF;

     -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )THEN
    COMMIT WORK;
      END IF;

     -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;
     -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
      );

EXCEPTION

  WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Cal_Crt;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Cal_Crt
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_criteria_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE

--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Cal_Crt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_criteria_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Cal_Crt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_cal_crt_pvt;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;
      -- Invoke table handler(Ams_Cal_Crt_Pkg.Delete_Row)
      Ams_Cal_Crt_Pkg.Delete_Row(
          p_criteria_id  => p_criteria_id,
          p_object_version_number => p_object_version_number     );
     --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Cal_Crt;

-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   API Name
--           Lock_Cal_Crt
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_cal_crt_rec_rec            IN   cal_crt_rec_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================




PROCEDURE Lock_Cal_Crt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_criteria_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Cal_Crt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_criteria_id                  NUMBER;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;

      END IF;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
Ams_Cal_Crt_Pkg.Lock_Row(l_criteria_id,p_object_version);
 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Cal_Crt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Cal_Crt;
-- Charu: Check for duplicate/ subset criteria --
PROCEDURE check_Cal_crt_rec_Dup_Items(
      p_cal_crt_rec_rec      IN   cal_crt_rec_rec_type,
      p_validation_mode      IN  VARCHAR2 := JTF_PLSQL_API.g_create,
      x_return_status    OUT NOCOPY VARCHAR2)
IS
      CURSOR c_criteria IS
      SELECT 'X'
      FROM ams_calendar_criteria
      WHERE  ( criteria_deleted = 'N'
        AND object_type_code = p_cal_crt_rec_rec.object_type_code
        AND DECODE(custom_setup_id, null, 1,
            DECODE(p_cal_crt_rec_rec.custom_setup_id, null, 0, p_cal_crt_rec_rec.custom_setup_id)) =
            DECODE(custom_setup_id, null, 1, custom_setup_id)
        AND DECODE(activity_type_code, null, '1',
            DECODE(p_cal_crt_rec_rec.activity_type_code, null, 'xxx', p_cal_crt_rec_rec.activity_type_code)) =
            DECODE(activity_type_code, null, '1', activity_type_code)
        AND DECODE(activity_id, null, 1,
            DECODE(p_cal_crt_rec_rec.activity_id, null, 0, p_cal_crt_rec_rec.activity_id)) =
            DECODE(activity_id, null, 1, activity_id)
        AND DECODE(status_id, null, 1,
            DECODE(p_cal_crt_rec_rec.status_id, null, 0, p_cal_crt_rec_rec.status_id)) =
            DECODE(status_id, null, 1, status_id)
        AND DECODE(priority_id, null, '1',
            DECODE(p_cal_crt_rec_rec.priority_id, null, 'xxx', p_cal_crt_rec_rec.priority_id)) =
            DECODE(priority_id, null, '1', priority_id)
        AND DECODE(object_id, null, 1,
            DECODE(p_cal_crt_rec_rec.object_id, null, 0, p_cal_crt_rec_rec.object_id)) =
            DECODE(object_id, null, 1, object_id)
        AND DECODE(criteria_start_date, null, SYSDATE,
            DECODE(p_cal_crt_rec_rec.criteria_start_date, null, (SYSDATE - 1000000), p_cal_crt_rec_rec.criteria_start_date)) >=
            DECODE(criteria_start_date, null, SYSDATE, criteria_start_date)
        AND DECODE(criteria_end_date, null, SYSDATE, nvl(p_cal_crt_rec_rec.criteria_end_date,
            (SYSDATE + 1000000))) <= nvl(criteria_end_date, SYSDATE)
--        AND DECODE(criteria_end_date, null, SYSDATE, DECODE(p_cal_crt_rec_rec.criteria_end_date, null, (SYSDATE + 1000000),
         --p_cal_crt_rec_rec.criteria_end_date)) <= DECODE(criteria_end_date, null, SYSDATE, criteria_end_date)
        );
   l_cal_crt_rec_rec c_criteria%ROWTYPE;
   l_exist VARCHAR2(1);
BEGIN
   OPEN c_criteria;
   FETCH c_criteria INTO l_exist;
   IF c_criteria%NOTFOUND THEN
        x_return_status  := FND_API.g_ret_sts_success;
   ELSE
   x_return_status := FND_API.g_ret_sts_error;
--   AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CAL_CRT_DUPLICATE');
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name ('AMS', 'AMS_CAL_CRT_DUPLICATE');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF;

   CLOSE c_criteria;
END check_Cal_crt_rec_Dup_Items;

PROCEDURE check_Cal_Crt_Rec_Uk_Items(
    p_cal_crt_rec_rec               IN   cal_crt_rec_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_cal_crt_rec_rec.criteria_id IS NOT NULL
      THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_calendar_criteria',
         'criteria_id = ''' || p_cal_crt_rec_rec.criteria_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_criteria_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
END check_Cal_Crt_Rec_Uk_Items;

PROCEDURE check_Cal_Crt_Rec_Req_Items(
    p_cal_crt_rec_rec               IN  cal_crt_rec_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status            OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_cal_crt_rec_rec.object_type_code = FND_API.g_miss_char OR p_cal_crt_rec_rec.object_type_code IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_cal_crt_rec_rec.last_update_login = FND_API.G_MISS_NUM OR p_cal_crt_rec_rec.last_update_login IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_LOGIN' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      IF p_cal_crt_rec_rec.criteria_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CRITERIA_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*
      IF p_cal_crt_rec_rec.object_type_code = FND_API.g_miss_char THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_cal_crt_rec_rec.last_update_login = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_LOGIN' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/
   END IF;

END check_Cal_Crt_Rec_Req_Items;

PROCEDURE check_Cal_Crt_Rec_Fk_Items(
    p_cal_crt_rec_rec IN cal_crt_rec_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- Enter custom code here
END check_Cal_Crt_Rec_Fk_Items;

PROCEDURE check_Cal_Crt_Rec_Lookup_Items(
    p_cal_crt_rec_rec IN cal_crt_rec_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- Enter custom code here
END check_Cal_Crt_Rec_Lookup_Items;
PROCEDURE Check_Cal_Crt_Rec_Items (
    P_cal_crt_rec_rec     IN    cal_crt_rec_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Charu: Check if the current criteria is duplicate/ subset of an existing criteria
   check_Cal_crt_rec_Dup_Items(
      p_cal_crt_rec_rec => p_cal_crt_rec_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Charu: Check if the current criteria endDate > startDate
   IF ((p_cal_crt_rec_rec.criteria_start_date IS NOT NULL) AND (p_cal_crt_rec_rec.criteria_end_date IS NOT NULL)
   AND (p_cal_crt_rec_rec.criteria_end_date < p_cal_crt_rec_rec.criteria_start_date)) THEN
--   AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CAL_CRT_INVALID_DATES');
        IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name ('AMS', 'AMS_CAL_CRT_INVALID_DATES');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
        END IF;
   l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Uniqueness API calls
   check_Cal_crt_rec_Uk_Items(
      p_cal_crt_rec_rec => p_cal_crt_rec_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_cal_crt_rec_req_items(
      p_cal_crt_rec_rec => p_cal_crt_rec_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Foreign Keys API calls
   check_cal_crt_rec_FK_items(
      p_cal_crt_rec_rec => p_cal_crt_rec_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups
   check_cal_crt_rec_Lookup_items(
      p_cal_crt_rec_rec => p_cal_crt_rec_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;
END Check_cal_crt_rec_Items;

PROCEDURE Complete_Cal_Crt_Rec_Rec (
   p_cal_crt_rec_rec IN cal_crt_rec_rec_type,
   x_complete_rec OUT NOCOPY cal_crt_rec_rec_type)
IS
   l_return_status  VARCHAR2(1);
   CURSOR c_complete IS
      SELECT *
      FROM ams_calendar_criteria
      WHERE criteria_id = p_cal_crt_rec_rec.criteria_id;
   l_cal_crt_rec_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_cal_crt_rec_rec;
   OPEN c_complete;
   FETCH c_complete INTO l_cal_crt_rec_rec;
   CLOSE c_complete;
   -- criteria_id
   IF p_cal_crt_rec_rec.criteria_id IS NULL THEN
      x_complete_rec.criteria_id := l_cal_crt_rec_rec.criteria_id;
   END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('criteria_id is: ' || x_complete_rec.criteria_id);
      END IF;
   -- object_type_code
   IF p_cal_crt_rec_rec.object_type_code IS NULL THEN
      x_complete_rec.object_type_code := l_cal_crt_rec_rec.object_type_code;
   END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('object_type_code is: ' || x_complete_rec.object_type_code);
      END IF;
   -- custom_setup_id
   IF p_cal_crt_rec_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_cal_crt_rec_rec.custom_setup_id;
   END IF;
   -- activity_type_code
   IF p_cal_crt_rec_rec.activity_type_code IS NULL THEN
      x_complete_rec.activity_type_code := l_cal_crt_rec_rec.activity_type_code;
   END IF;
   -- activity_id
   IF p_cal_crt_rec_rec.activity_id IS NULL THEN
      x_complete_rec.activity_id := l_cal_crt_rec_rec.activity_id;
   END IF;
   -- status_id
   IF p_cal_crt_rec_rec.status_id IS NULL THEN
      x_complete_rec.status_id := l_cal_crt_rec_rec.status_id;
   END IF;

   -- priority_id
   IF p_cal_crt_rec_rec.priority_id IS NULL THEN
      x_complete_rec.priority_id := l_cal_crt_rec_rec.priority_id;
   END IF;

   -- object_id
   IF p_cal_crt_rec_rec.object_id IS NULL THEN
      x_complete_rec.object_id := l_cal_crt_rec_rec.object_id;
   END IF;
   -- criteria_start_date
   IF p_cal_crt_rec_rec.criteria_start_date IS NULL THEN
      x_complete_rec.criteria_start_date := l_cal_crt_rec_rec.criteria_start_date;
   END IF;
   -- criteria_end_date
   IF p_cal_crt_rec_rec.criteria_end_date IS NULL THEN
      x_complete_rec.criteria_end_date := l_cal_crt_rec_rec.criteria_end_date;
   END IF;
   -- criteria_deleted
   IF p_cal_crt_rec_rec.criteria_deleted IS NULL THEN
      x_complete_rec.criteria_deleted := l_cal_crt_rec_rec.criteria_deleted;
   END IF;
   -- criteria_enabled
   IF p_cal_crt_rec_rec.criteria_enabled IS NULL THEN
      x_complete_rec.criteria_enabled := l_cal_crt_rec_rec.criteria_enabled;
   END IF;

   -- last_update_date
   IF p_cal_crt_rec_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_cal_crt_rec_rec.last_update_date;
   END IF;
   -- last_updated_by
   IF p_cal_crt_rec_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_cal_crt_rec_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_cal_crt_rec_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_cal_crt_rec_rec.creation_date;
   END IF;
   -- created_by
   IF p_cal_crt_rec_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_cal_crt_rec_rec.created_by;
   END IF;
   -- last_update_login
   IF p_cal_crt_rec_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_cal_crt_rec_rec.last_update_login;
   END IF;
   -- object_version_number
   IF p_cal_crt_rec_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_cal_crt_rec_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Cal_Crt_Rec_Rec;


PROCEDURE Default_Cal_Crt_Rec_Items ( p_cal_crt_rec_rec IN cal_crt_rec_rec_type ,
                                x_cal_crt_rec_rec OUT NOCOPY cal_crt_rec_rec_type )
IS
   l_cal_crt_rec_rec cal_crt_rec_rec_type := p_cal_crt_rec_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
/*
   x_cal_crt_rec_rec := p_cal_crt_rec_rec;
   IF (p_cal_crt_rec_rec.criteria_enabled IS NULL) THEN
      x_cal_crt_rec_rec.criteria_enabled := 'Y';
   END IF;
   IF p_cal_crt_rec_rec.criteria_deleted IS NULL THEN
      x_cal_crt_rec_rec.criteria_enabled := 'N';
   END IF;
*/
END;

PROCEDURE Validate_Cal_Crt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_cal_crt_rec_rec               IN   cal_crt_rec_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Cal_Crt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_cal_crt_rec_rec  cal_crt_rec_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_cal_crt_;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_cal_crt_rec_Items(
                 p_cal_crt_rec_rec        => p_cal_crt_rec_rec,
                 p_validation_mode   => p_validation_mode,

                 x_return_status     => x_return_status
              );
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('2');
      END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Cal_Crt_Rec_Items (p_cal_crt_rec_rec => p_cal_crt_rec_rec ,
                                x_cal_crt_rec_rec => l_cal_crt_rec_rec) ;
      END IF ;

      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('3');
      END IF;

      Complete_cal_crt_rec_Rec(
         p_cal_crt_rec_rec        => p_cal_crt_rec_rec,
         x_complete_rec        => l_cal_crt_rec_rec
      );
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('4');
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_cal_crt_rec_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_cal_crt_rec_rec           =>    l_cal_crt_rec_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('5');
      END IF;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'ended fully');
      END IF;
EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Cal_Crt_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Cal_Crt_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Cal_Crt_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Cal_Crt;

PROCEDURE Validate_Cal_Crt_Rec_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cal_crt_rec_rec               IN    cal_crt_rec_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_cal_crt_rec_Rec;
END AMS_Cal_Crt_PVT;

/
