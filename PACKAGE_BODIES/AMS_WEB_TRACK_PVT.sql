--------------------------------------------------------
--  DDL for Package Body AMS_WEB_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WEB_TRACK_PVT" as
/* $Header: amsvwtgb.pls 120.1 2005/06/27 05:42:14 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Web_Track_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Web_Track_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvwtgb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

/*
PROCEDURE insert_log_mesg (p_mesg IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 insert into raghu_table values (p_mesg,sysdate);
 commit;
END;
*/

PROCEDURE Default_Web_Track_Items (
   p_web_track_rec IN  web_track_rec_type ,
   x_web_track_rec OUT NOCOPY web_track_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Create_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_track_rec              IN   web_track_rec_type, -- := g_miss_web_track_rec,
    x_web_tracking_id              OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Web_Track';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_web_tracking_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT AMS_WEB_TRACKING_S.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_WEB_TRACKING
      WHERE web_tracking_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_web_track_pvt;

      --insert_log_mesg('SAVEPOINT create_web_track_pvt ::::');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --insert_log_mesg('Standard call to check for call compatibility');
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



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

      --insert_log_mesg('Validate Environment');

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Web_Track');

          -- Invoke validation procedures
          Validate_web_track(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_web_track_rec  =>  p_web_track_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      --insert_log_mesg('Done Validate_web_track');
      --insert_log_mesg('Done Validate_web_track'||x_return_status);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

	--insert_log_mesg('Local variable initialization');


   IF p_web_track_rec.web_tracking_id IS NULL OR p_web_track_rec.web_tracking_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_web_tracking_id;
         CLOSE c_id;

         OPEN c_id_exists(l_web_tracking_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_web_tracking_id := p_web_track_rec.web_tracking_id;
   END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      --insert_log_mesg('Private API: Calling create table handler ::::');

      -- Invoke table handler(Ams_Web_Track_Pkg.Insert_Row)
      Ams_Web_Track_Pkg.Insert_Row(
          px_web_tracking_id  => l_web_tracking_id,
          p_schedule_id  => p_web_track_rec.schedule_id,
          p_party_id  => p_web_track_rec.party_id,
          p_placement_id  => p_web_track_rec.placement_id,
          p_content_item_id  => p_web_track_rec.content_item_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_attribute_category  => p_web_track_rec.attribute_category,
          p_attribute1  => p_web_track_rec.attribute1,
          p_attribute2  => p_web_track_rec.attribute2,
          p_attribute3  => p_web_track_rec.attribute3,
          p_attribute4  => p_web_track_rec.attribute4,
          p_attribute5  => p_web_track_rec.attribute5,
          p_attribute6  => p_web_track_rec.attribute6,
          p_attribute7  => p_web_track_rec.attribute7,
          p_attribute8  => p_web_track_rec.attribute8,
          p_attribute9  => p_web_track_rec.attribute9,
          p_attribute10  => p_web_track_rec.attribute10,
          p_attribute11  => p_web_track_rec.attribute11,
          p_attribute12  => p_web_track_rec.attribute12,
          p_attribute13  => p_web_track_rec.attribute13,
          p_attribute14  => p_web_track_rec.attribute14,
          p_attribute15  => p_web_track_rec.attribute15
);

          x_web_tracking_id := l_web_tracking_id;
	  --insert_log_mesg('Web Tracking Id ::::'||x_web_tracking_id);
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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
	 --insert_log_mesg('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_web_track_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
     --insert_log_mesg('x_return_status');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_web_track_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO create_web_track_pvt;
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
     --insert_log_mesg('Ams_Web_Track_Pkg.Insert_Row'||x_return_status);
End Create_Web_Track;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Update_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_track_rec               IN    web_track_rec_type
    )

 IS


CURSOR c_get_web_track(web_tracking_id NUMBER) IS
    SELECT *
    FROM  AMS_WEB_TRACKING
    WHERE  web_tracking_id = p_web_track_rec.web_tracking_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Web_Track';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_web_tracking_id    NUMBER;
l_ref_web_track_rec  c_get_Web_Track%ROWTYPE ;
l_tar_web_track_rec  web_track_rec_type := P_web_track_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_web_track_pvt;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Web_Track( l_tar_web_track_rec.web_tracking_id);

      FETCH c_get_Web_Track INTO l_ref_web_track_rec  ;

       If ( c_get_Web_Track%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Web_Track') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Web_Track;


      If (l_tar_web_track_rec.object_version_number is NULL or
          l_tar_web_track_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_web_track_rec.object_version_number <> l_ref_web_track_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Web_Track') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Web_Track');


          -- Invoke validation procedures
          Validate_web_track(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_web_track_rec  =>  p_web_track_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ams_Web_Track_Pkg.Update_Row)
      Ams_Web_Track_Pkg.Update_Row(
          p_web_tracking_id  => p_web_track_rec.web_tracking_id,
          p_schedule_id  => p_web_track_rec.schedule_id,
          p_party_id  => p_web_track_rec.party_id,
          p_placement_id  => p_web_track_rec.placement_id,
          p_content_item_id  => p_web_track_rec.content_item_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_web_track_rec.object_version_number,
          p_attribute_category  => p_web_track_rec.attribute_category,
          p_attribute1  => p_web_track_rec.attribute1,
          p_attribute2  => p_web_track_rec.attribute2,
          p_attribute3  => p_web_track_rec.attribute3,
          p_attribute4  => p_web_track_rec.attribute4,
          p_attribute5  => p_web_track_rec.attribute5,
          p_attribute6  => p_web_track_rec.attribute6,
          p_attribute7  => p_web_track_rec.attribute7,
          p_attribute8  => p_web_track_rec.attribute8,
          p_attribute9  => p_web_track_rec.attribute9,
          p_attribute10  => p_web_track_rec.attribute10,
          p_attribute11  => p_web_track_rec.attribute11,
          p_attribute12  => p_web_track_rec.attribute12,
          p_attribute13  => p_web_track_rec.attribute13,
          p_attribute14  => p_web_track_rec.attribute14,
          p_attribute15  => p_web_track_rec.attribute15
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO UPDATE_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Web_Track_PVT;
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
End Update_Web_Track;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Web_Track
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
--       p_web_tracking_id                IN   NUMBER
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
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_tracking_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Web_Track';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_web_track_pvt;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ams_Web_Track_Pkg.Delete_Row)
      Ams_Web_Track_Pkg.Delete_Row(
          p_web_tracking_id  => p_web_tracking_id,
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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO DELETE_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Web_Track_PVT;
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
End Delete_Web_Track;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Lock_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_tracking_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Web_Track';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_web_tracking_id                  NUMBER;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
Ams_Web_Track_Pkg.Lock_Row(l_web_tracking_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Web_Track_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Web_Track_PVT;
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
End Lock_Web_Track;




PROCEDURE check_Web_Track_Uk_Items(
    p_web_track_rec               IN   web_track_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_web_track_rec.web_tracking_id IS NOT NULL
      THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_web_tracking',
         'web_tracking_id = ''' || p_web_track_rec.web_tracking_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_web_tracking_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Web_Track_Uk_Items;



PROCEDURE check_Web_Track_Req_Items(
    p_web_track_rec               IN  web_track_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --insert_log_mesg('check_Web_Track_Req_Items');
   --insert_log_mesg(x_return_status);

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      --insert_log_mesg('Web Tracking Id ::::'||p_web_track_rec.web_tracking_id);

     -- IF p_web_track_rec.web_tracking_id = FND_API.G_MISS_NUM OR p_web_track_rec.web_tracking_id IS NULL THEN
       --insert_log_mesg('error');
	 --      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_TRACKING_ID' );
           --    x_return_status := FND_API.g_ret_sts_error;
     -- END IF;
      --insert_log_mesg(x_return_status);

      IF p_web_track_rec.schedule_id = FND_API.G_MISS_NUM OR p_web_track_rec.schedule_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SCHEDULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

       --insert_log_mesg('Schedule Id ::::'||p_web_track_rec.schedule_id);
      IF p_web_track_rec.party_id = FND_API.G_MISS_NUM OR p_web_track_rec.party_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

	--insert_log_mesg(p_web_track_rec.placement_id);
      IF p_web_track_rec.placement_id = FND_API.G_MISS_NUM OR p_web_track_rec.placement_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PLACEMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE

         --insert_log_mesg('else check_Web_Track_Req_Items');
      IF p_web_track_rec.web_tracking_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_TRACKING_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_web_track_rec.schedule_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SCHEDULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_web_track_rec.party_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_web_track_rec.placement_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PLACEMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --insert_log_mesg('check_Web_Track_Req_Items done');

END check_Web_Track_Req_Items;



PROCEDURE check_Web_Track_Fk_Items(
    p_web_track_rec IN web_track_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Web_Track_Fk_Items;



PROCEDURE check_Web_Track_Lookup_Items(
    p_web_track_rec IN web_track_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Web_Track_Lookup_Items;



PROCEDURE Check_Web_Track_Items (
    P_web_track_rec     IN    web_track_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls
   --insert_log_mesg('inside Check_web_track_Items');
   --insert_log_mesg(l_return_status);
   check_Web_track_Uk_Items(
      p_web_track_rec => p_web_track_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
      --insert_log_mesg(x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
      --insert_log_mesg('done check_Web_track_Uk_Items');

   -- Check Items Required/NOT NULL API calls
  --insert_log_mesg('start check_web_track_req_items');
   check_web_track_req_items(
      p_web_track_rec => p_web_track_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
      --insert_log_mesg(x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   --insert_log_mesg('Check Items Required/NOT NULL API calls');
   -- Check Items Foreign Keys API calls

   check_web_track_FK_items(
      p_web_track_rec => p_web_track_rec,
      x_return_status => x_return_status);
      --insert_log_mesg(x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups
   --insert_log_mesg('Check Items Lookups');
   check_web_track_Lookup_items(
      p_web_track_rec => p_web_track_rec,
      x_return_status => x_return_status);
      --insert_log_mesg(x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;
   --insert_log_mesg(x_return_status);

END Check_web_track_Items;





PROCEDURE Complete_Web_Track_Rec (
   p_web_track_rec IN web_track_rec_type,
   x_complete_rec OUT NOCOPY web_track_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_web_tracking
      WHERE web_tracking_id = p_web_track_rec.web_tracking_id;
   l_web_track_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_web_track_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_web_track_rec;
   CLOSE c_complete;

   -- web_tracking_id
   IF p_web_track_rec.web_tracking_id IS NULL THEN
      x_complete_rec.web_tracking_id := l_web_track_rec.web_tracking_id;
   END IF;

   -- schedule_id
   IF p_web_track_rec.schedule_id IS NULL THEN
      x_complete_rec.schedule_id := l_web_track_rec.schedule_id;
   END IF;

   -- party_id
   IF p_web_track_rec.party_id IS NULL THEN
      x_complete_rec.party_id := l_web_track_rec.party_id;
   END IF;

   -- placement_id
   IF p_web_track_rec.placement_id IS NULL THEN
      x_complete_rec.placement_id := l_web_track_rec.placement_id;
   END IF;

   -- content_item_id
   IF p_web_track_rec.content_item_id IS NULL THEN
      x_complete_rec.content_item_id := l_web_track_rec.content_item_id;
   END IF;

   -- last_update_date
   IF p_web_track_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_web_track_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_web_track_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_web_track_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_web_track_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_web_track_rec.creation_date;
   END IF;

   -- created_by
   IF p_web_track_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_web_track_rec.created_by;
   END IF;

   -- last_update_login
   IF p_web_track_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_web_track_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_web_track_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_web_track_rec.object_version_number;
   END IF;

   -- attribute_category
   IF p_web_track_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_web_track_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_web_track_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_web_track_rec.attribute1;
   END IF;

   -- attribute2
   IF p_web_track_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_web_track_rec.attribute2;
   END IF;

   -- attribute3
   IF p_web_track_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_web_track_rec.attribute3;
   END IF;

   -- attribute4
   IF p_web_track_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_web_track_rec.attribute4;
   END IF;

   -- attribute5
   IF p_web_track_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_web_track_rec.attribute5;
   END IF;

   -- attribute6
   IF p_web_track_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_web_track_rec.attribute6;
   END IF;

   -- attribute7
   IF p_web_track_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_web_track_rec.attribute7;
   END IF;

   -- attribute8
   IF p_web_track_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_web_track_rec.attribute8;
   END IF;

   -- attribute9
   IF p_web_track_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_web_track_rec.attribute9;
   END IF;

   -- attribute10
   IF p_web_track_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_web_track_rec.attribute10;
   END IF;

   -- attribute11
   IF p_web_track_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_web_track_rec.attribute11;
   END IF;

   -- attribute12
   IF p_web_track_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_web_track_rec.attribute12;
   END IF;

   -- attribute13
   IF p_web_track_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_web_track_rec.attribute13;
   END IF;

   -- attribute14
   IF p_web_track_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_web_track_rec.attribute14;
   END IF;

   -- attribute15
   IF p_web_track_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_web_track_rec.attribute15;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Web_Track_Rec;




PROCEDURE Default_Web_Track_Items ( p_web_track_rec IN web_track_rec_type ,
                                x_web_track_rec OUT NOCOPY web_track_rec_type )
IS
   l_web_track_rec web_track_rec_type := p_web_track_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_web_track_rec               IN   web_track_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Web_Track';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_web_track_rec  web_track_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_web_track_;

      --insert_log_mesg('Standard Start of API savepoint');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --insert_log_mesg('Standard call to check for call');
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      --insert_log_mesg('Private API: Validate_Web_Track');

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
	--insert_log_mesg('Check_web_track_Items');
              Check_web_track_Items(
                 p_web_track_rec        => p_web_track_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );
	--insert_log_mesg('done Check_web_track_Items');
	--insert_log_mesg(x_return_status);
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	          RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
	 --insert_log_mesg('before Default_Web_Track_Items');
         Default_Web_Track_Items (p_web_track_rec => p_web_track_rec ,
                                x_web_track_rec => l_web_track_rec) ;
      END IF ;
	--insert_log_mesg('before Complete_web_track_Rec');

      Complete_web_track_Rec(
         p_web_track_rec        => l_web_track_rec,
         x_complete_rec        => l_web_track_rec
      );
      --insert_log_mesg('Complete_web_track_Rec');

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_web_track_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_web_track_rec           =>    l_web_track_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --insert_log_mesg(x_return_status);
      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO VALIDATE_Web_Track_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Web_Track_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Web_Track_;
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
End Validate_Web_Track;


PROCEDURE Validate_Web_Track_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_track_rec               IN    web_track_rec_type
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
      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_web_track_Rec;

-- Foreward Procedure Declarations
--

PROCEDURE Default_Web_Recomms_Items (
   p_web_recomms_rec IN  web_recomms_rec_type ,
   x_web_recomms_rec OUT NOCOPY web_recomms_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Create_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_recomms_rec            IN   web_recomms_rec_type  := g_miss_web_recomms_rec,
    x_web_recomm_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Web_Recomms';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_web_recomm_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ams_web_recomms_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_WEB_RECOMMS
      WHERE web_recomm_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_web_recomms_pvt;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



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
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Web_Recomms');

          -- Invoke validation procedures
          Validate_web_recomms(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_web_recomms_rec  =>  p_web_recomms_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_web_recomms_rec.web_recomm_id IS NULL OR p_web_recomms_rec.web_recomm_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_web_recomm_id;
         CLOSE c_id;

         OPEN c_id_exists(l_web_recomm_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_web_recomm_id := p_web_recomms_rec.web_recomm_id;
   END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ams_Web_Recomms_Pkg.Insert_Row)
      Ams_Web_Recomms_Pkg.Insert_Row(
          px_web_recomm_id  => l_web_recomm_id,
          p_web_tracking_id  => p_web_recomms_rec.web_tracking_id,
          p_recomm_object_id  => p_web_recomms_rec.recomm_object_id,
          p_recomm_type  => p_web_recomms_rec.recomm_type,
          p_rule_id  => p_web_recomms_rec.rule_id,
          p_offer_id  => p_web_recomms_rec.offer_id,
          p_offer_src_code  => p_web_recomms_rec.offer_src_code,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_attribute_category  => p_web_recomms_rec.attribute_category,
          p_attribute1  => p_web_recomms_rec.attribute1,
          p_attribute2  => p_web_recomms_rec.attribute2,
          p_attribute3  => p_web_recomms_rec.attribute3,
          p_attribute4  => p_web_recomms_rec.attribute4,
          p_attribute5  => p_web_recomms_rec.attribute5,
          p_attribute6  => p_web_recomms_rec.attribute6,
          p_attribute7  => p_web_recomms_rec.attribute7,
          p_attribute8  => p_web_recomms_rec.attribute8,
          p_attribute9  => p_web_recomms_rec.attribute9,
          p_attribute10  => p_web_recomms_rec.attribute10,
          p_attribute11  => p_web_recomms_rec.attribute11,
          p_attribute12  => p_web_recomms_rec.attribute12,
          p_attribute13  => p_web_recomms_rec.attribute13,
          p_attribute14  => p_web_recomms_rec.attribute14,
          p_attribute15  => p_web_recomms_rec.attribute15
);

          x_web_recomm_id := l_web_recomm_id;
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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO CREATE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Web_Recomms_PVT;
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
End Create_Web_Recomms;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Update_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_recomms_rec               IN    web_recomms_rec_type
    )

 IS


CURSOR c_get_web_recomms(web_recomm_id NUMBER) IS
    SELECT *
    FROM  AMS_WEB_RECOMMS
    WHERE  web_recomm_id = p_web_recomms_rec.web_recomm_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Web_Recomms';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_web_recomm_id    NUMBER;
l_ref_web_recomms_rec  c_get_Web_Recomms%ROWTYPE ;
l_tar_web_recomms_rec  web_recomms_rec_type := P_web_recomms_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_web_recomms_pvt;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Web_Recomms( l_tar_web_recomms_rec.web_recomm_id);

      FETCH c_get_Web_Recomms INTO l_ref_web_recomms_rec  ;

       If ( c_get_Web_Recomms%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Web_Recomms') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Web_Recomms;


      If (l_tar_web_recomms_rec.object_version_number is NULL or
          l_tar_web_recomms_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_web_recomms_rec.object_version_number <> l_ref_web_recomms_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Web_Recomms') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Web_Recomms');

          -- Invoke validation procedures
          Validate_web_recomms(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_web_recomms_rec  =>  p_web_recomms_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ams_Web_Recomms_Pkg.Update_Row)
      Ams_Web_Recomms_Pkg.Update_Row(
          p_web_recomm_id  => p_web_recomms_rec.web_recomm_id,
          p_web_tracking_id  => p_web_recomms_rec.web_tracking_id,
          p_recomm_object_id  => p_web_recomms_rec.recomm_object_id,
          p_recomm_type  => p_web_recomms_rec.recomm_type,
          p_rule_id  => p_web_recomms_rec.rule_id,
          p_offer_id  => p_web_recomms_rec.offer_id,
          p_offer_src_code  => p_web_recomms_rec.offer_src_code,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_web_recomms_rec.object_version_number,
          p_attribute_category  => p_web_recomms_rec.attribute_category,
          p_attribute1  => p_web_recomms_rec.attribute1,
          p_attribute2  => p_web_recomms_rec.attribute2,
          p_attribute3  => p_web_recomms_rec.attribute3,
          p_attribute4  => p_web_recomms_rec.attribute4,
          p_attribute5  => p_web_recomms_rec.attribute5,
          p_attribute6  => p_web_recomms_rec.attribute6,
          p_attribute7  => p_web_recomms_rec.attribute7,
          p_attribute8  => p_web_recomms_rec.attribute8,
          p_attribute9  => p_web_recomms_rec.attribute9,
          p_attribute10  => p_web_recomms_rec.attribute10,
          p_attribute11  => p_web_recomms_rec.attribute11,
          p_attribute12  => p_web_recomms_rec.attribute12,
          p_attribute13  => p_web_recomms_rec.attribute13,
          p_attribute14  => p_web_recomms_rec.attribute14,
          p_attribute15  => p_web_recomms_rec.attribute15
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO UPDATE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Web_Recomms_PVT;
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
End Update_Web_Recomms;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Web_Recomms
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
--       p_web_recomm_id                IN   NUMBER
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
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_recomm_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Web_Recomms';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_web_recomms_pvt;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ams_Web_Recomms_Pkg.Delete_Row)
      Ams_Web_Recomms_Pkg.Delete_Row(
          p_web_recomm_id  => p_web_recomm_id,
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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO DELETE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Web_Recomms_PVT;
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
End Delete_Web_Recomms;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Lock_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_recomm_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Web_Recomms';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_web_recomm_id                  NUMBER;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
Ams_Web_Recomms_Pkg.Lock_Row(l_web_recomm_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Web_Recomms_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Web_Recomms_PVT;
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
End Lock_Web_Recomms;




PROCEDURE check_Web_Recomms_Uk_Items(
    p_web_recomms_rec               IN   web_recomms_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_web_recomms_rec.web_recomm_id IS NOT NULL
      THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_web_recomms',
         'web_recomm_id = ''' || p_web_recomms_rec.web_recomm_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_web_recomm_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Web_Recomms_Uk_Items;



PROCEDURE check_Web_Recomms_Req_Items(
    p_web_recomms_rec               IN  web_recomms_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


     -- IF p_web_recomms_rec.web_recomm_id = FND_API.G_MISS_NUM OR p_web_recomms_rec.web_recomm_id IS NULL THEN
       --        AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_RECOMM_ID' );
         --      x_return_status := FND_API.g_ret_sts_error;
    --  END IF;


      IF p_web_recomms_rec.web_tracking_id = FND_API.G_MISS_NUM OR p_web_recomms_rec.web_tracking_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_TRACKING_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_web_recomms_rec.web_recomm_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_RECOMM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_web_recomms_rec.web_tracking_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'WEB_TRACKING_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Web_Recomms_Req_Items;



PROCEDURE check_Web_Recomms_Fk_Items(
    p_web_recomms_rec IN web_recomms_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Web_Recomms_Fk_Items;



PROCEDURE check_Web_Recomms_Lookup_Items(
    p_web_recomms_rec IN web_recomms_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Web_Recomms_Lookup_Items;



PROCEDURE Check_Web_Recomms_Items (
    P_web_recomms_rec     IN    web_recomms_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Web_recomms_Uk_Items(
      p_web_recomms_rec => p_web_recomms_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_web_recomms_req_items(
      p_web_recomms_rec => p_web_recomms_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_web_recomms_FK_items(
      p_web_recomms_rec => p_web_recomms_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_web_recomms_Lookup_items(
      p_web_recomms_rec => p_web_recomms_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_web_recomms_Items;





PROCEDURE Complete_Web_Recomms_Rec (
   p_web_recomms_rec IN web_recomms_rec_type,
   x_complete_rec OUT NOCOPY web_recomms_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_web_recomms
      WHERE web_recomm_id = p_web_recomms_rec.web_recomm_id;
   l_web_recomms_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_web_recomms_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_web_recomms_rec;
   CLOSE c_complete;

   -- web_recomm_id
   IF p_web_recomms_rec.web_recomm_id IS NULL THEN
      x_complete_rec.web_recomm_id := l_web_recomms_rec.web_recomm_id;
   END IF;

   -- web_tracking_id
   IF p_web_recomms_rec.web_tracking_id IS NULL THEN
      x_complete_rec.web_tracking_id := l_web_recomms_rec.web_tracking_id;
   END IF;

   -- recomm_object_id
   IF p_web_recomms_rec.recomm_object_id IS NULL THEN
      x_complete_rec.recomm_object_id := l_web_recomms_rec.recomm_object_id;
   END IF;

   -- recomm_type
   IF p_web_recomms_rec.recomm_type IS NULL THEN
      x_complete_rec.recomm_type := l_web_recomms_rec.recomm_type;
   END IF;

   -- rule_id
   IF p_web_recomms_rec.rule_id IS NULL THEN
      x_complete_rec.rule_id := l_web_recomms_rec.rule_id;
   END IF;

   -- offer_id
   IF p_web_recomms_rec.offer_id IS NULL THEN
      x_complete_rec.offer_id := l_web_recomms_rec.offer_id;
   END IF;

   -- offer_src_code
   IF p_web_recomms_rec.offer_src_code IS NULL THEN
      x_complete_rec.offer_src_code := l_web_recomms_rec.offer_src_code;
   END IF;

   -- last_update_date
   IF p_web_recomms_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_web_recomms_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_web_recomms_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_web_recomms_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_web_recomms_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_web_recomms_rec.creation_date;
   END IF;

   -- created_by
   IF p_web_recomms_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_web_recomms_rec.created_by;
   END IF;

   -- last_update_login
   IF p_web_recomms_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_web_recomms_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_web_recomms_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_web_recomms_rec.object_version_number;
   END IF;

   -- attribute_category
   IF p_web_recomms_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_web_recomms_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_web_recomms_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_web_recomms_rec.attribute1;
   END IF;

   -- attribute2
   IF p_web_recomms_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_web_recomms_rec.attribute2;
   END IF;

   -- attribute3
   IF p_web_recomms_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_web_recomms_rec.attribute3;
   END IF;

   -- attribute4
   IF p_web_recomms_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_web_recomms_rec.attribute4;
   END IF;

   -- attribute5
   IF p_web_recomms_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_web_recomms_rec.attribute5;
   END IF;

   -- attribute6
   IF p_web_recomms_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_web_recomms_rec.attribute6;
   END IF;

   -- attribute7
   IF p_web_recomms_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_web_recomms_rec.attribute7;
   END IF;

   -- attribute8
   IF p_web_recomms_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_web_recomms_rec.attribute8;
   END IF;

   -- attribute9
   IF p_web_recomms_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_web_recomms_rec.attribute9;
   END IF;

   -- attribute10
   IF p_web_recomms_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_web_recomms_rec.attribute10;
   END IF;

   -- attribute11
   IF p_web_recomms_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_web_recomms_rec.attribute11;
   END IF;

   -- attribute12
   IF p_web_recomms_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_web_recomms_rec.attribute12;
   END IF;

   -- attribute13
   IF p_web_recomms_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_web_recomms_rec.attribute13;
   END IF;

   -- attribute14
   IF p_web_recomms_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_web_recomms_rec.attribute14;
   END IF;

   -- attribute15
   IF p_web_recomms_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_web_recomms_rec.attribute15;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Web_Recomms_Rec;




PROCEDURE Default_Web_Recomms_Items ( p_web_recomms_rec IN web_recomms_rec_type ,
                                x_web_recomms_rec OUT NOCOPY web_recomms_rec_type )
IS
   l_web_recomms_rec web_recomms_rec_type := p_web_recomms_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_web_recomms_rec               IN   web_recomms_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Web_Recomms';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_web_recomms_rec  web_recomms_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_web_recomms_;

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
              Check_web_recomms_Items(
                 p_web_recomms_rec        => p_web_recomms_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Web_Recomms_Items (p_web_recomms_rec => p_web_recomms_rec ,
                                x_web_recomms_rec => l_web_recomms_rec) ;
      END IF ;


      Complete_web_recomms_Rec(
         p_web_recomms_rec        => l_web_recomms_rec,
         x_complete_rec        => l_web_recomms_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_web_recomms_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_web_recomms_rec           =>    l_web_recomms_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO VALIDATE_Web_Recomms_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Web_Recomms_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Web_Recomms_;
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
End Validate_Web_Recomms;


PROCEDURE Validate_Web_Recomms_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_recomms_rec               IN    web_recomms_rec_type
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
      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_web_recomms_Rec;




PROCEDURE Create_Web_Imp_Track (
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_web_track_rec        IN   web_track_rec_type,
    p_web_recomms_tbl      IN  web_recomms_tbl_type,
    --p_web_prod             IN  VARCHAR2,
    x_impr_obj_id_rec     OUT NOCOPY impr_obj_id_tbl_type,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2
          )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'CreateWebImpTrack';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_web_track_rec	       web_track_rec_type;
   l_web_recomms_rec	       web_recomms_rec_type;
   l_impr_obj_id_tbl          impr_obj_id_tbl_type;
   l_web_tracking_id	       NUMBER;
   l_schedule_id	       NUMBER;
   l_party_id		       NUMBER;
   l_placement_id	       NUMBER;
   l_content_item_id	       NUMBER;
   l_web_recomm_id	       NUMBER;
   l_recomm_object_id	       NUMBER;
   l_recomm_type	       VARCHAR2(30);
   l_rule_id		       NUMBER;
   l_offer_src_code	       VARCHAR2(30);
   l_offer_id		       NUMBER;

BEGIN

 -- Standard Start of API savepoint
      SAVEPOINT Create_Web_Imp_Track;

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
      AMS_UTILITY_PVT.debug_message('Private API: Create_Web_Imp_Track');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      --insert_log_mesg('Private API: Create_Web_Imp_Track');

 --validate web_track_rec_type
 -- dbms_output.put_line('before inserting into AMS_Web_Tracking web_tracking_id'||l_web_tracking_id );
 -- dbms_output.put_line('before inserting into AMS_Web_Tracking schedule_id '||l_schedule_id );
 -- dbms_output.put_line('before inserting into AMS_Web_Tracking party_id'||l_party_id );
 -- dbms_output.put_line('before inserting into AMS_Web_Tracking placement_id '||l_placement_id );
 -- dbms_output.put_line('before inserting into AMS_Web_Tracking content_item_id'||l_content_item_id );

	 --insert_log_mesg(p_web_track_rec.schedule_id);
	l_web_track_rec.web_tracking_id := null;
	l_web_track_rec.schedule_id := p_web_track_rec.schedule_id;
	l_web_track_rec.party_id := p_web_track_rec.party_id ;
	l_web_track_rec.placement_id := p_web_track_rec.placement_id;
	l_web_track_rec.content_item_id := p_web_track_rec.content_item_id;


	 IF  (p_web_track_rec.schedule_id) IS NOT NULL THEN
			--insert_log_mesg('Calling Create_Web_Track ::::');
	     		Create_Web_Track(p_api_version_number  => 1.0,
					   p_init_msg_list       => FND_API.G_FALSE,
					   p_commit              => FND_API.G_FALSE,
					   p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
					   x_return_status       => x_return_status,
					   x_msg_count           => x_msg_count,
					   x_msg_data            => x_msg_data,
					   p_web_track_rec       => l_web_track_rec,
					   x_web_tracking_id     => l_web_tracking_id
				           );
		--insert_log_mesg('Done Create_Web_Track ::::');
	--dbms_output.put_line('before inserting into AMS_Web_Tracking web_tracking_id'||l_web_tracking_id );
	--insert_log_mesg('l_web_tracking_id');
	--insert_log_mesg('Web Tracking Id ::::'||l_web_tracking_id);

	IF l_web_tracking_id IS NULL    THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_NO_PRIMARY_KEY');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	--dbms_output.put_line('after inserting into AMS_WEB_TRACKING '||l_web_tracking_id );
	--dbms_output.put_line('l_web_recomms_tbl_type.COUNT '||web_recomms_tbl_type.COUNT);

	IF ( (p_web_track_rec.schedule_type = 'WEB_ADV') OR (p_web_track_rec.schedule_type = 'WEB_OFFER') ) THEN
		x_impr_obj_id_rec(0).impr_track_id := l_web_tracking_id;
	        x_impr_obj_id_rec(0).obj_id := null;
	END IF;

	--insert_log_mesg('RECORD POPULATED');

/*	IF( (p_web_track_rec.schedule_type = 'AMS_WEB_ADV') OR (p_web_track_rec.schedule_type = 'AMS_WEB_OFFER') )

	THEN

	IF(p_web_recomms_tbl.COUNT = 0) THEN  -- also compare for schedule_type
	    l_web_recomms_rec.web_tracking_id := l_web_tracking_id;
            l_web_recomms_rec.recomm_type := 'IMPR_ONLY';

	     Create_Web_Recomms(p_api_version_number => 1.0,
					     p_init_msg_list => FND_API.G_FALSE,
			                     p_commit => FND_API.G_FALSE,
                                             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
					     x_return_status => x_return_status,
					     x_msg_count  => x_msg_count,
					     x_msg_data  =>  x_msg_data,
					     p_web_recomms_rec =>  l_web_recomms_rec,
					     x_web_recomm_id => l_web_recomm_id
					     );
	   x_impr_obj_id_rec(1).impr_track_id := l_web_recomm_id;
	   x_impr_obj_id_rec(1).obj_id := null;
    	END IF;

	IF(p_web_recomms_tbl.COUNT = 1) THEN  -- also compare for schedule_type
	    l_web_recomms_rec.web_tracking_id := l_web_tracking_id;
            l_web_recomms_rec.recomm_type := 'PROD';

	     Create_Web_Recomms(p_api_version_number => 1.0,
					     p_init_msg_list => FND_API.G_FALSE,
			                     p_commit => FND_API.G_FALSE,
                                             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
					     x_return_status => x_return_status,
					     x_msg_count  => x_msg_count,
					     x_msg_data  =>  x_msg_data,
					     p_web_recomms_rec =>  l_web_recomms_rec,
					     x_web_recomm_id => l_web_recomm_id
					     );
	   x_impr_obj_id_rec(0).impr_track_id := l_web_recomm_id;
	   x_impr_obj_id_rec(0).obj_id := null;
    	END IF;


	END IF;  -- compared WEB-ADV OR WEB-OFFER
*/
	--insert_log_mesg('Schedule Type ::::'||p_web_track_rec.schedule_type);

	IF( p_web_track_rec.schedule_type = 'WEB_PRODUCT' )
--	IF( p_web_track_rec.schedule_type = 'WEB_ADV' )
	THEN
	IF(p_web_recomms_tbl.COUNT > 0) THEN

  	   FOR i IN 1..p_web_recomms_tbl.COUNT
	   LOOP
	   l_web_recomms_rec := p_web_recomms_tbl(i);
	   l_web_recomms_rec.web_tracking_id := l_web_tracking_id;
           l_web_recomms_rec.recomm_type := 'WEB_PROD';
	   Create_Web_Recomms(p_api_version_number => 1.0,
					     p_init_msg_list => FND_API.G_FALSE,
			                     p_commit => FND_API.G_FALSE,
                                             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
					     x_return_status => x_return_status,
					     x_msg_count  => x_msg_count,
					     x_msg_data  =>  x_msg_data,
					     p_web_recomms_rec =>  l_web_recomms_rec,
					     x_web_recomm_id => l_web_recomm_id
					     );

     -- dbms_output.put_line('before inserting into AMS_Web_Recomms web recomm id '|| l_web_recomm_id );
     --insert_log_mesg('Web Recomm Id ::::'||l_web_recomm_id);

         IF l_web_recomm_id IS NULL THEN
		 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		    FND_MESSAGE.set_name('AMS', 'AMS_NO_PRIMARY_KEY');
		    FND_MSG_PUB.add;
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
	  x_impr_obj_id_rec(i).impr_track_id := l_web_recomm_id;
	  x_impr_obj_id_rec(i).obj_id := l_web_recomms_rec.recomm_object_id;


	 END LOOP;
	END IF;
       END IF;

      END IF; --
       	--insert_log_mesg('Return Status ::::'||x_return_status);
	x_return_status := FND_API.g_ret_sts_success;

		--insert_log_mesg(p_commit);

   --    IF FND_API.to_Boolean( p_commit )
     --  THEN
         --insert_log_mesg('COMMIT WORK');
         COMMIT WORK;
     --  END IF;

	--insert_log_mesg('FINALLY DONE ::::');

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
	 --insert_log_mesg(x_return_status);

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Web_Imp_Track;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
     --insert_log_mesg(x_return_status);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Web_Imp_Track;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
     --insert_log_mesg(x_return_status);

   WHEN OTHERS THEN
     ROLLBACK TO Create_Web_Imp_Track;
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
     --insert_log_mesg(x_return_status);

END Create_Web_Imp_Track;



END AMS_Web_Track_PVT;

/
