--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PLCMNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PLCMNT_PVT" as
/* $Header: amsvplcb.pls 115.16 2002/11/25 20:48:12 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Iba_Plcmnt_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Iba_Plcmnt_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvplcb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Iba_Plcmnt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_iba_plcmnt_rec               IN   iba_plcmnt_rec_type  := g_miss_iba_plcmnt_rec,
    x_placement_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Iba_Plcmnt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_PLACEMENT_ID                  NUMBER;
   l_dummy       NUMBER;
   l_site_ref_code              VARCHAR2(30);
   l_site_id                    NUMBER;
   l_page_ref_code              VARCHAR2(30);
   l_page_id                    NUMBER;


   CURSOR c_id IS
      SELECT AMS_IBA_PL_PLACEMENTS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PL_PLACEMENTS_B
      WHERE PLACEMENT_ID = l_id;

   CURSOR c_site_id (l_site_ref_code IN VARCHAR2) IS
        SELECT site_id
        FROM ams_iba_pl_sites_b
        WHERE site_ref_code = l_site_ref_code;

   CURSOR c_page_id (l_page_ref_code IN VARCHAR2, l_site_ref_code IN VARCHAR2) IS
        SELECT page_id
        FROM ams_iba_pl_pages_b
        WHERE page_ref_code = l_page_ref_code
	AND site_ref_code = l_site_ref_code;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Iba_Plcmnt_PVT;

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

   -- Local variable initialization

   IF p_iba_plcmnt_rec.PLACEMENT_ID IS NULL OR p_iba_plcmnt_rec.PLACEMENT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_PLACEMENT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_PLACEMENT_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
	x_PLACEMENT_ID := l_PLACEMENT_ID;
   END IF;

   IF p_iba_plcmnt_rec.site_id IS NULL OR p_iba_plcmnt_rec.page_id = FND_API.g_miss_num THEN
        OPEN c_site_id(p_iba_plcmnt_rec.site_ref_code);
        FETCH c_site_id INTO l_site_id;
        CLOSE c_site_id;
   else
	l_site_id := p_iba_plcmnt_rec.site_id;
   END IF;

   IF p_iba_plcmnt_rec.page_id IS NULL OR p_iba_plcmnt_rec.page_id = FND_API.g_miss_num THEN
        OPEN c_page_id(p_iba_plcmnt_rec.page_ref_code,p_iba_plcmnt_rec.site_ref_code);
        FETCH c_page_id INTO l_page_id;
        CLOSE c_page_id;
   else
	l_page_id := p_iba_plcmnt_rec.page_id;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Iba_Plcmnt');
          END IF;

          -- Invoke validation procedures
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Create_Iba_Plcmnt: before Validate_iba_plcmnt call ' );
	END IF;
          Validate_iba_plcmnt(
              p_api_version_number     => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_plcmnt_rec  =>  p_iba_plcmnt_rec
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data
            , p_validation_mode  => JTF_PLSQL_API.g_create
	   );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IBA_PL_PLACEMENTS_B_PKG.Insert_Row)
      AMS_IBA_PL_PLACEMENTS_B_PKG.Insert_Row(
          px_placement_id  => l_placement_id,
          p_site_id  => l_site_id,
          p_site_ref_code  => p_iba_plcmnt_rec.site_ref_code,
          p_page_id  => l_page_id,
          p_page_ref_code  => p_iba_plcmnt_rec.page_ref_code,
          p_location_code  => p_iba_plcmnt_rec.location_code,
          p_param1  => p_iba_plcmnt_rec.param1,
          p_param2  => p_iba_plcmnt_rec.param2,
          p_param3  => p_iba_plcmnt_rec.param3,
          p_param4  => p_iba_plcmnt_rec.param4,
          p_param5  => p_iba_plcmnt_rec.param5,
          p_stylesheet_id  => p_iba_plcmnt_rec.stylesheet_id,
          p_posting_id  => p_iba_plcmnt_rec.posting_id,
          p_status_code  => p_iba_plcmnt_rec.status_code,
          p_track_events_flag  => p_iba_plcmnt_rec.track_events_flag,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_name                => p_iba_plcmnt_rec.name,
          p_description         => p_iba_plcmnt_rec.description);

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
     ROLLBACK TO CREATE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Iba_Plcmnt_PVT;
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
End Create_Iba_Plcmnt;


PROCEDURE Update_Iba_Plcmnt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_iba_plcmnt_rec               IN    iba_plcmnt_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
--/*
CURSOR c_get_iba_plcmnt(placement_id NUMBER) IS
    SELECT *
    FROM  AMS_IBA_PL_PLACEMENTS_B;
    -- Hint: Developer need to provide Where clause
--*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Iba_Plcmnt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_PLACEMENT_ID    NUMBER;
l_ref_iba_plcmnt_rec  c_get_Iba_Plcmnt%ROWTYPE ;
l_tar_iba_plcmnt_rec  AMS_Iba_Plcmnt_PVT.iba_plcmnt_rec_type := P_iba_plcmnt_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Iba_Plcmnt_PVT;

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

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

--/*
      OPEN c_get_Iba_Plcmnt( l_tar_iba_plcmnt_rec.placement_id);

      FETCH c_get_Iba_Plcmnt INTO l_ref_iba_plcmnt_rec  ;

       If ( c_get_Iba_Plcmnt%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Iba_Plcmnt') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Iba_Plcmnt;
--*/


      If (l_tar_iba_plcmnt_rec.object_version_number is NULL or
          l_tar_iba_plcmnt_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_iba_plcmnt_rec.object_version_number <> l_ref_iba_plcmnt_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Iba_Plcmnt') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Iba_Plcmnt');
          END IF;

          -- Invoke validation procedures
          Validate_iba_plcmnt(
             p_api_version_number     => 1.0
            , p_init_msg_list    => FND_API.G_FALSE
            , p_validation_level => p_validation_level
            , p_iba_plcmnt_rec  =>  p_iba_plcmnt_rec
            , x_return_status    => x_return_status
            , x_msg_count        => x_msg_count
            , x_msg_data         => x_msg_data
	    , p_validation_mode  => JTF_PLSQL_API.g_update
	  );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
 --     IF (AMS_DEBUG_HIGH_ON) THEN          AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');     END IF;

      -- Invoke table handler(AMS_IBA_PL_PLACEMENTS_B_PKG.Update_Row)
      AMS_IBA_PL_PLACEMENTS_B_PKG.Update_Row(
          p_placement_id  => p_iba_plcmnt_rec.placement_id,
          p_site_id  => p_iba_plcmnt_rec.site_id,
          p_site_ref_code  => p_iba_plcmnt_rec.site_ref_code,
          p_page_id  => p_iba_plcmnt_rec.page_id,
          p_page_ref_code  => p_iba_plcmnt_rec.page_ref_code,
          p_location_code  => p_iba_plcmnt_rec.location_code,
          p_param1  => p_iba_plcmnt_rec.param1,
          p_param2  => p_iba_plcmnt_rec.param2,
          p_param3  => p_iba_plcmnt_rec.param3,
          p_param4  => p_iba_plcmnt_rec.param4,
          p_param5  => p_iba_plcmnt_rec.param5,
          p_stylesheet_id  => p_iba_plcmnt_rec.stylesheet_id,
          p_posting_id  => p_iba_plcmnt_rec.posting_id,
          p_status_code  => p_iba_plcmnt_rec.status_code,
          p_track_events_flag  => p_iba_plcmnt_rec.track_events_flag,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_iba_plcmnt_rec.object_version_number,
          p_name                => p_iba_plcmnt_rec.name,
          p_description         => p_iba_plcmnt_rec.description);

      --
      -- End of API body.
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
     ROLLBACK TO UPDATE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Iba_Plcmnt_PVT;
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
End Update_Iba_Plcmnt;


PROCEDURE Delete_Iba_Plcmnt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_placement_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Iba_Plcmnt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Iba_Plcmnt_PVT;

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

      -- Invoke table handler(AMS_IBA_PL_PLACEMENTS_B_PKG.Delete_Row)
      AMS_IBA_PL_PLACEMENTS_B_PKG.Delete_Row(
          p_PLACEMENT_ID  => p_PLACEMENT_ID);
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
     ROLLBACK TO DELETE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Iba_Plcmnt_PVT;
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
End Delete_Iba_Plcmnt;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Iba_Plcmnt(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_placement_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Iba_Plcmnt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_PLACEMENT_ID                  NUMBER;

CURSOR c_Iba_Plcmnt IS
   SELECT PLACEMENT_ID
   FROM AMS_IBA_PL_PLACEMENTS_B
   WHERE PLACEMENT_ID = p_PLACEMENT_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

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

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Iba_Plcmnt;

  FETCH c_Iba_Plcmnt INTO l_PLACEMENT_ID;

  IF (c_Iba_Plcmnt%NOTFOUND) THEN
    CLOSE c_Iba_Plcmnt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Iba_Plcmnt;

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
     ROLLBACK TO LOCK_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Iba_Plcmnt_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Iba_Plcmnt_PVT;
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
End Lock_Iba_Plcmnt;

/******************************************************
-- checks if the combination of site, page, location and
-- parameters are unique
-- returns the true if it is unique else returns false
-- fills the p_situation (out parameter) with a number based on the
-- following situations
-- 	p_situation = 1 means the its istore site and shopping_cart page
-- 	p_situation = 2 means the its istore site and non shopping_cart page
-- 	p_situation = 3 means the its non istore site
******************************************************/
FUNCTION check_unique_placement(
	p_iba_plcmnt_rec             IN   iba_plcmnt_rec_type,
    	p_validation_mode            IN  VARCHAR2,
	p_situation		     OUT NOCOPY NUMBER
)
RETURN VARCHAR2
IS
l_plcmnt_count NUMBER;
BEGIN
   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
   	if p_iba_plcmnt_rec.site_ref_code = 'ISTORE' then
		if p_iba_plcmnt_rec.page_ref_code = 'SHOPPING_CART' then
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code
                    and NVL(param1,'-1') = NVL(p_iba_plcmnt_rec.param1,'-1')
		    and placement_id <> p_iba_plcmnt_rec.placement_id;

		    p_situation := 1;
		else
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code
                    and NVL(param1,'-1') = NVL(p_iba_plcmnt_rec.param1,'-1')
                    and NVL(param2,'-1') = NVL(p_iba_plcmnt_rec.param2,'-1')
		    and placement_id <> p_iba_plcmnt_rec.placement_id;

		    p_situation := 2;
		end if;
	else
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code
		    and placement_id <> p_iba_plcmnt_rec.placement_id;

		    p_situation := 3;
	end if;
   else
   	if p_iba_plcmnt_rec.site_ref_code = 'ISTORE' then
		if p_iba_plcmnt_rec.page_ref_code = 'SHOPPING_CART' then
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code
		    and NVL(param1,'-1') = NVL(p_iba_plcmnt_rec.param1,'-1');

		    p_situation := 1;
		else
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code
		    and NVL(param1,'-1') = NVL(p_iba_plcmnt_rec.param1,'-1')
		    and NVL(param2,'-1') = NVL(p_iba_plcmnt_rec.param2,'-1');

		    p_situation := 2;
		end if;
	else
		   select count(*) into l_plcmnt_count
		   from ams_iba_pl_placements_b
		   where site_ref_code = p_iba_plcmnt_rec.site_ref_code
		    and page_ref_code = p_iba_plcmnt_rec.page_ref_code
		    and location_code = p_iba_plcmnt_rec.location_code;

		    p_situation := 3;
	end if;
   end if;

   if l_plcmnt_count = 0 then
	return FND_API.g_true;
   else
	return FND_API.g_false;
   end if;
END check_unique_placement;

PROCEDURE check_iba_plcmnt_uk_items(
    p_iba_plcmnt_rec               IN   iba_plcmnt_rec_type,
    p_validation_mode            IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1) := FND_API.g_true;
l_is_unique  VARCHAR2(1);
l_situation  NUMBER;

BEGIN
      x_return_status := FND_API.g_ret_sts_success;

	--check if the combination of site, page, location and parameters are unique
	l_is_unique := check_unique_placement(p_iba_plcmnt_rec,p_validation_mode,l_situation);
      IF l_is_unique = FND_API.g_false THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
	    THEN
		if l_situation = 1 then -- placement is for istore and shopping_cart page
	                FND_MESSAGE.set_name('AMS','AMS_PLCE_PLCMNT_SHCRT_DUP');
		elsif l_situation = 2 then -- placement is for istore and non shopping cart page
	                FND_MESSAGE.set_name('AMS','AMS_PLCE_PLCMNT_ISTORE_DUP');
		else -- placement is for non istore site
	                FND_MESSAGE.set_name('AMS','AMS_PLCE_PLCMNT_DUP');
		end if;
                FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.g_exc_error;
--	 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_PLACEMENT_NAME_DUPLICATE');
      END IF;


      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In check_iba_plcmnt_uk_items : before check_uniqueness call plcmnt_name = ' || p_iba_plcmnt_rec.name );
	END IF;
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
 	          'AMS_IBA_PL_PLACEMENTS_VL',
       		  'NAME = ''' || p_iba_plcmnt_rec.name ||''''
		   );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
	          'AMS_IBA_PL_PLACEMENTS_VL',
       		  'NAME = ''' || p_iba_plcmnt_rec.name ||''' AND PLACEMENT_ID <> ' || p_iba_plcmnt_rec.PLACEMENT_ID
	         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
	    THEN
                FND_MESSAGE.set_name('AMS','AMS_PLCE_PLCMNT_NAME_DUP');
                FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.g_exc_error;
--	 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_PLACEMENT_NAME_DUPLICATE');
      END IF;

END check_iba_plcmnt_uk_items;

PROCEDURE check_iba_plcmnt_req_items(
    p_iba_plcmnt_rec               IN  iba_plcmnt_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_iba_plcmnt_rec.placement_id = FND_API.g_miss_num OR p_iba_plcmnt_rec.placement_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_placement_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.site_id = FND_API.g_miss_num OR p_iba_plcmnt_rec.site_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_site_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.site_ref_code = FND_API.g_miss_char OR p_iba_plcmnt_rec.site_ref_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_site_ref_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.page_id = FND_API.g_miss_num OR p_iba_plcmnt_rec.page_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_page_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.page_ref_code = FND_API.g_miss_char OR p_iba_plcmnt_rec.page_ref_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_page_ref_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.location_code = FND_API.g_miss_char OR p_iba_plcmnt_rec.location_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_location_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.status_code = FND_API.g_miss_char OR p_iba_plcmnt_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.created_by = FND_API.g_miss_num OR p_iba_plcmnt_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.creation_date = FND_API.g_miss_date OR p_iba_plcmnt_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.last_updated_by = FND_API.g_miss_num OR p_iba_plcmnt_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.last_update_date = FND_API.g_miss_date OR p_iba_plcmnt_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_iba_plcmnt_rec.placement_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_placement_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.site_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_site_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.site_ref_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_site_ref_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.page_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_page_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.page_ref_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_page_ref_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.location_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_location_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_iba_plcmnt_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_iba_plcmnt_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_iba_plcmnt_req_items;

PROCEDURE check_iba_plcmnt_FK_items(
    p_iba_plcmnt_rec IN iba_plcmnt_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_iba_plcmnt_FK_items;

PROCEDURE check_iba_plcmnt_Lookup_items(
    p_iba_plcmnt_rec IN iba_plcmnt_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_iba_plcmnt_Lookup_items;

PROCEDURE Check_iba_plcmnt_Items (
    P_iba_plcmnt_rec     IN    iba_plcmnt_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

	IF (AMS_DEBUG_HIGH_ON) THEN



	AMS_UTILITY_PVT.debug_message('In Check_iba_plcmnt_Items: before check_iba_plcmnt_uk_items call plcmnt_name = ' || p_iba_plcmnt_rec.name );

	END IF;
   check_iba_plcmnt_uk_items(
      p_iba_plcmnt_rec => p_iba_plcmnt_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

-- sodixit : commenting following lines : 05/21/01
-- check_iba_plcmnt_req_items(
--      p_iba_plcmnt_rec => p_iba_plcmnt_rec,
--      p_validation_mode => p_validation_mode,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;
   -- Check Items Foreign Keys API calls

--   check_iba_plcmnt_FK_items(
--      p_iba_plcmnt_rec => p_iba_plcmnt_rec,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;
   -- Check Items Lookups

--  check_iba_plcmnt_Lookup_items(
--      p_iba_plcmnt_rec => p_iba_plcmnt_rec,
--      x_return_status => x_return_status);
--   IF x_return_status <> FND_API.g_ret_sts_success THEN
--      RETURN;
--   END IF;

END Check_iba_plcmnt_Items;


PROCEDURE Complete_iba_plcmnt_Rec (
   p_iba_plcmnt_rec IN iba_plcmnt_rec_type,
   x_complete_rec OUT NOCOPY iba_plcmnt_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_pl_placements_b
      WHERE placement_id = p_iba_plcmnt_rec.placement_id;
   l_iba_plcmnt_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_iba_plcmnt_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_iba_plcmnt_rec;
   CLOSE c_complete;

   -- placement_id
   IF p_iba_plcmnt_rec.placement_id = FND_API.g_miss_num THEN
      x_complete_rec.placement_id := l_iba_plcmnt_rec.placement_id;
   END IF;

   -- site_id
   IF p_iba_plcmnt_rec.site_id = FND_API.g_miss_num THEN
      x_complete_rec.site_id := l_iba_plcmnt_rec.site_id;
   END IF;

   -- site_ref_code
   IF p_iba_plcmnt_rec.site_ref_code = FND_API.g_miss_char THEN
      x_complete_rec.site_ref_code := l_iba_plcmnt_rec.site_ref_code;
   END IF;

   -- page_id
   IF p_iba_plcmnt_rec.page_id = FND_API.g_miss_num THEN
      x_complete_rec.page_id := l_iba_plcmnt_rec.page_id;
   END IF;

   -- page_ref_code
   IF p_iba_plcmnt_rec.page_ref_code = FND_API.g_miss_char THEN
      x_complete_rec.page_ref_code := l_iba_plcmnt_rec.page_ref_code;
   END IF;

   -- location_code
   IF p_iba_plcmnt_rec.location_code = FND_API.g_miss_char THEN
      x_complete_rec.location_code := l_iba_plcmnt_rec.location_code;
   END IF;

   -- param1
   IF p_iba_plcmnt_rec.param1 = FND_API.g_miss_char THEN
      x_complete_rec.param1 := l_iba_plcmnt_rec.param1;
   END IF;

   -- param2
   IF p_iba_plcmnt_rec.param2 = FND_API.g_miss_char THEN
      x_complete_rec.param2 := l_iba_plcmnt_rec.param2;
   END IF;

   -- param3
   IF p_iba_plcmnt_rec.param3 = FND_API.g_miss_char THEN
      x_complete_rec.param3 := l_iba_plcmnt_rec.param3;
   END IF;

   -- param4
   IF p_iba_plcmnt_rec.param4 = FND_API.g_miss_char THEN
      x_complete_rec.param4 := l_iba_plcmnt_rec.param4;
   END IF;

   -- param5
   IF p_iba_plcmnt_rec.param5 = FND_API.g_miss_char THEN
      x_complete_rec.param5 := l_iba_plcmnt_rec.param5;
   END IF;

   -- stylesheet_id
   IF p_iba_plcmnt_rec.stylesheet_id = FND_API.g_miss_num THEN
      x_complete_rec.stylesheet_id := l_iba_plcmnt_rec.stylesheet_id;
   END IF;

   -- posting_id
   IF p_iba_plcmnt_rec.posting_id = FND_API.g_miss_num THEN
      x_complete_rec.posting_id := l_iba_plcmnt_rec.posting_id;
   END IF;

   -- status_code
   IF p_iba_plcmnt_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_iba_plcmnt_rec.status_code;
   END IF;

   -- track_events_flag
   IF p_iba_plcmnt_rec.track_events_flag = FND_API.g_miss_char THEN
      x_complete_rec.track_events_flag := l_iba_plcmnt_rec.track_events_flag;
   END IF;

   -- created_by
   IF p_iba_plcmnt_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_iba_plcmnt_rec.created_by;
   END IF;

   -- creation_date
   IF p_iba_plcmnt_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_iba_plcmnt_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_iba_plcmnt_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_iba_plcmnt_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_iba_plcmnt_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_iba_plcmnt_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_iba_plcmnt_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_iba_plcmnt_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_iba_plcmnt_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_iba_plcmnt_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_iba_plcmnt_Rec;
PROCEDURE Validate_iba_plcmnt(
      p_api_version_number         IN   NUMBER
    , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    , p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL
    , p_iba_plcmnt_rec               IN   iba_plcmnt_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
    , x_msg_count                  OUT NOCOPY  NUMBER
    , x_msg_data                   OUT NOCOPY  VARCHAR2
    , p_validation_mode            IN   VARCHAR2
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Iba_Plcmnt';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_iba_plcmnt_rec  AMS_Iba_Plcmnt_PVT.iba_plcmnt_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Iba_Plcmnt_;

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
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Validate: before Check_iba_plcmnt_Items call plcmnt_name = ' || p_iba_plcmnt_rec.name );
	END IF;
              Check_iba_plcmnt_Items(
                 p_iba_plcmnt_rec        => p_iba_plcmnt_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_iba_plcmnt_Rec(
         p_iba_plcmnt_rec        => p_iba_plcmnt_rec,
         x_complete_rec        => l_iba_plcmnt_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Validate: before Validate_iba_plcmnt_Rec call ' );
	END IF;
         Validate_iba_plcmnt_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_iba_plcmnt_rec           =>    l_iba_plcmnt_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
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
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Iba_Plcmnt_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Iba_Plcmnt_;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Validate - unexpected err: validation_mode= ' || p_validation_mode);
	END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Iba_Plcmnt_;
	IF (AMS_DEBUG_HIGH_ON) THEN

	AMS_UTILITY_PVT.debug_message('In Validate - others err: validation_mode= ' || p_validation_mode);
	END IF;
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
End Validate_Iba_Plcmnt;


PROCEDURE Validate_iba_plcmnt_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_iba_plcmnt_rec               IN    iba_plcmnt_rec_type
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
END Validate_iba_plcmnt_Rec;

END AMS_Iba_Plcmnt_PVT;

/
