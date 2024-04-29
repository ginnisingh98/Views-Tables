--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGET_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGET_SOURCES_PVT" as
/* $Header: amsvdtsb.pls 115.6 2004/06/16 12:27:36 rosharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Target_Sources_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dm_Target_Sources_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdtsb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Target_Source_Items (
   p_target_source_rec_type_rec IN  target_source_rec_type ,
   x_target_source_rec_type_rec OUT NOCOPY target_source_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Dm_Target_Sources
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
--       p_target_source_rec_type_rec            IN   target_source_rec_type  Required
--
--   OUT
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
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

PROCEDURE Create_Dm_Target_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_target_source_rec_type_rec              IN   target_source_rec_type  := g_miss_target_source_rec,
    x_target_source_id              OUT  NOCOPY NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Dm_Target_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_target_source_rec         target_source_rec_type := p_target_source_rec_type_rec;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ams_dm_target_sources_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_DM_TARGET_SOURCES
      WHERE target_source_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_dm_target_sources_pvt;

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


   -- Local variable initialization

   IF l_target_source_rec.target_source_id IS NULL OR l_target_source_rec.target_source_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_target_source_rec.target_source_id;
         CLOSE c_id;

         OPEN c_id_exists(l_target_source_rec.target_source_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Dm_Target_Sources');

          -- Invoke validation procedures
          Validate_dm_target_sources(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_target_source_rec_type_rec  =>  l_target_source_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ams_Dm_Target_Sources_Pkg.Insert_Row)
      Ams_Dm_Target_Sources_Pkg.Insert_Row(
          px_target_source_id  => l_target_source_rec.target_source_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_target_id  => l_target_source_rec.target_id,
          p_data_source_id  => l_target_source_rec.data_source_id
);

          x_target_source_id := l_target_source_rec.target_source_id;
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
     ROLLBACK TO CREATE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Dm_Target_Sources_PVT;
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
End Create_Dm_Target_Sources;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Dm_Target_Sources
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
--       p_target_source_rec_type_rec            IN   target_source_rec_type  Required
--
--   OUT
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--   15-Dec-2003  choang   pass in new object ver number to table handler; table
--                         handler to only do update
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Dm_Target_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_target_source_rec_type_rec               IN    target_source_rec_type
    )

 IS


CURSOR c_get_dm_target_sources(p_target_source_id NUMBER) IS
    SELECT *
    FROM  AMS_DM_TARGET_SOURCES
    WHERE  target_source_id = p_target_source_id;


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Dm_Target_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_new_object_version_number     NUMBER := p_target_source_rec_type_rec.object_version_number + 1;
l_target_source_id    NUMBER;
l_ref_target_source_rec  c_get_Dm_Target_Sources%ROWTYPE ;
l_tar_target_source_rec  target_source_rec_type := P_target_source_rec_type_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_dm_target_sources_pvt;

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

      OPEN c_get_Dm_Target_Sources( l_tar_target_source_rec.target_source_id);

      FETCH c_get_Dm_Target_Sources INTO l_ref_target_source_rec  ;

       If ( c_get_Dm_Target_Sources%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Dm_Target_Sources') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Dm_Target_Sources;


      If (l_tar_target_source_rec.object_version_number is NULL or
          l_tar_target_source_rec.object_version_number = FND_API.G_MISS_NUM ) Then
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
            p_token_name   => 'COLUMN',
            p_token_value  => 'Last_Update_Date') ;
         raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_target_source_rec.object_version_number <> l_ref_target_source_rec.object_version_number) Then
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
            p_token_name   => 'INFO',
            p_token_value  => 'Dm_Target_Sources') ;
         raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Dm_Target_Sources');

          -- Invoke validation procedures
          Validate_dm_target_sources(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_target_source_rec_type_rec  =>  p_target_source_rec_type_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ams_Dm_Target_Sources_Pkg.Update_Row)
      Ams_Dm_Target_Sources_Pkg.Update_Row(
          p_target_source_id  => p_target_source_rec_type_rec.target_source_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => l_new_object_version_number,
          p_target_id  => p_target_source_rec_type_rec.target_id,
          p_data_source_id  => p_target_source_rec_type_rec.data_source_id
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
     ROLLBACK TO UPDATE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Dm_Target_Sources_PVT;
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
End Update_Dm_Target_Sources;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Dm_Target_Sources
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
--       p_target_source_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
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

PROCEDURE Delete_Dm_Target_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_target_source_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Dm_Target_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

   CURSOR c_target_source (p_target_source_id IN NUMBER)
   IS SELECT 1 FROM AMS_DM_TARGETS_B t, AMS_DM_TARGET_SOURCES s
      WHERE s.target_source_id = p_target_source_id
      AND   s.target_id = t.target_id
      AND   s.data_source_id = t.target_source_id;

 l_dummy NUMBER ;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_dm_target_sources_pvt;

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

      OPEN c_target_source(p_target_source_id) ;
        FETCH c_target_source INTO l_dummy;
      CLOSE c_target_source ;

      IF l_dummy IS NOT NULL THEN
         AMS_Utility_PVT.error_message ('AMS_DM_CHLD_DS_DEL_ERR');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ams_Dm_Target_Sources_Pkg.Delete_Row)
      Ams_Dm_Target_Sources_Pkg.Delete_Row(
          p_target_source_id  => p_target_source_id,
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
     ROLLBACK TO DELETE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Dm_Target_Sources_PVT;
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
End Delete_Dm_Target_Sources;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Dm_Target_Sources
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
--       p_target_source_rec_type_rec            IN   target_source_rec_type  Required
--
--   OUT
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
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

PROCEDURE Lock_Dm_Target_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_target_source_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Dm_Target_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_target_source_id                  NUMBER;

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
Ams_Dm_Target_Sources_Pkg.Lock_Row(l_target_source_id,p_object_version);


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
     ROLLBACK TO LOCK_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Dm_Target_Sources_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Dm_Target_Sources_PVT;
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
End Lock_Dm_Target_Sources;




PROCEDURE check_Target_Source_Uk_Items(
    p_target_source_rec_type_rec               IN   target_source_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_target_source_rec_type_rec.target_source_id IS NOT NULL
      THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_dm_target_sources',
         'target_source_id = ''' || p_target_source_rec_type_rec.target_source_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_target_source_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Target_Source_Uk_Items;



PROCEDURE check_Target_Source_Req_Items(
    p_target_source_rec_type_rec               IN  target_source_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_target_source_rec_type_rec.target_source_id = FND_API.G_MISS_NUM OR p_target_source_rec_type_rec.target_source_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_SOURCE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_target_source_rec_type_rec.target_id = FND_API.G_MISS_NUM OR p_target_source_rec_type_rec.target_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_target_source_rec_type_rec.data_source_id = FND_API.G_MISS_NUM OR p_target_source_rec_type_rec.data_source_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'DATA_SOURCE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_target_source_rec_type_rec.target_source_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_SOURCE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_target_source_rec_type_rec.target_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'TARGET_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_target_source_rec_type_rec.data_source_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'DATA_SOURCE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Target_Source_Req_Items;



PROCEDURE check_Target_Source_Fk_Items(
    p_target_source_rec_type_rec IN target_source_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_Target_Source_Fk_Items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   --------------------- data_source_id ------------------------
   IF p_target_source_rec_type_rec.data_source_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_src_types',
            'LIST_SOURCE_TYPE_ID',
            p_target_source_rec_type_rec.data_source_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'DATA_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

   --------------------- target_id ------------------------
   IF p_target_source_rec_type_rec.target_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_dm_targets_b',
            'target_id',
            p_target_source_rec_type_rec.target_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Target_Source_Fk_Items;



PROCEDURE check_Tgt_Src_Lookup_Items(
    p_target_source_rec_type_rec IN target_source_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Tgt_Src_Lookup_Items;



PROCEDURE Check_Target_Source_Items (
    P_target_source_rec_type_rec     IN    target_source_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT   NOCOPY VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Target_Source_Uk_Items(
      p_target_source_rec_type_rec => p_target_source_rec_type_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_Target_Source_Req_Items(
      p_target_source_rec_type_rec => p_target_source_rec_type_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_Target_Source_Fk_Items(
      p_target_source_rec_type_rec => p_target_source_rec_type_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Tgt_Src_Lookup_Items(
      p_target_source_rec_type_rec => p_target_source_rec_type_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_Target_Source_Items;





PROCEDURE Complete_Target_Source_Rec (
   p_target_source_rec_type_rec IN target_source_rec_type,
   x_complete_rec OUT NOCOPY target_source_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_target_sources
      WHERE target_source_id = p_target_source_rec_type_rec.target_source_id;
   l_target_source_rec_type_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_target_source_rec_type_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_target_source_rec_type_rec;
   CLOSE c_complete;

   -- target_source_id
   IF p_target_source_rec_type_rec.target_source_id IS NULL THEN
      x_complete_rec.target_source_id := l_target_source_rec_type_rec.target_source_id;
   END IF;

   -- last_update_date
   IF p_target_source_rec_type_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_target_source_rec_type_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_target_source_rec_type_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_target_source_rec_type_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_target_source_rec_type_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_target_source_rec_type_rec.creation_date;
   END IF;

   -- created_by
   IF p_target_source_rec_type_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_target_source_rec_type_rec.created_by;
   END IF;

   -- last_update_login
   IF p_target_source_rec_type_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_target_source_rec_type_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_target_source_rec_type_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_target_source_rec_type_rec.object_version_number;
   END IF;

   -- target_id
   IF p_target_source_rec_type_rec.target_id IS NULL THEN
      x_complete_rec.target_id := l_target_source_rec_type_rec.target_id;
   END IF;

   -- data_source_id
   IF p_target_source_rec_type_rec.data_source_id IS NULL THEN
      x_complete_rec.data_source_id := l_target_source_rec_type_rec.data_source_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Target_Source_Rec;




PROCEDURE Default_Target_Source_Items ( p_target_source_rec_type_rec IN target_source_rec_type ,
                                x_target_source_rec_type_rec OUT NOCOPY target_source_rec_type )
IS
   l_target_source_rec_type_rec target_source_rec_type := p_target_source_rec_type_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Dm_Target_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_target_source_rec_type_rec               IN   target_source_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Dm_Target_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_target_source_rec_type_rec  target_source_rec_type := p_target_source_rec_type_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_dm_target_sources_;

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
              Check_Target_Source_Items(
                 p_target_source_rec_type_rec        => l_target_source_rec_type_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      /*IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Target_Source_Items (p_target_source_rec_type_rec => p_target_source_rec_type_rec ,
                                x_target_source_rec_type_rec => l_target_source_rec_type_rec) ;
      END IF ;


      Complete_Target_Source_Rec(
         p_target_source_rec_type_rec        => l_target_source_rec_type_rec,
         x_complete_rec        => l_target_source_rec_type_rec
      );*/

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Target_Source_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
	   p_validation_mode        => p_validation_mode,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_target_source_rec_type_rec           =>    l_target_source_rec_type_rec);

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
     ROLLBACK TO VALIDATE_Dm_Target_Sources_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Dm_Target_Sources_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Dm_Target_Sources_;
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
End Validate_Dm_Target_Sources;


PROCEDURE Validate_Target_Source_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_target_source_rec_type_rec               IN    target_source_rec_type
    )
IS
    CURSOR c_check_underlying_obj(p_ds_id IN NUMBER, p_target_id IN NUMBER) IS
       SELECT 1
       FROM   ams_dm_target_sources dts, ams_list_src_types lst1, ams_list_src_types lst2
       WHERE  dts.target_id = p_target_id
       AND    lst1.list_source_type_id = p_ds_id
       AND    lst2.list_source_type_id = dts.data_source_id
       AND    lst2.list_source_type_id <> p_ds_id
       AND    lst1.source_object_name = lst2.source_object_name
       ;

    l_dummy   NUMBER := 0;
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
         AMS_UTILITY_PVT.debug_message('Private API: Validate_Target_Source_Rec');
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         OPEN c_check_underlying_obj(p_target_source_rec_type_rec.data_source_id, p_target_source_rec_type_rec.target_id);
         FETCH c_check_underlying_obj INTO l_dummy;
         CLOSE c_check_underlying_obj;

	 IF l_dummy <> 0 THEN
            AMS_Utility_PVT.error_message ('AMS_DM_CHILD_OBJ_EXISTS');
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Target_Source_Rec;

PROCEDURE delete_tgtsources_for_target ( p_target_id IN   NUMBER)
 IS
      L_API_NAME                  CONSTANT VARCHAR2(30) := 'delete_tgtsources_for_target';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_tgtsources_for_target;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      --
      -- Api body
      --
      DELETE FROM ams_dm_target_sources
       WHERE TARGET_SOURCE_ID in (SELECT TARGET_SOURCE_ID FROM ams_dm_target_sources WHERE TARGET_ID = p_TARGET_ID);

      --
      -- End of API body
      --

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_tgtsources_for_target;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_tgtsources_for_target;

   WHEN OTHERS THEN
     ROLLBACK TO delete_tgtsources_for_target;

End delete_tgtsources_for_target;

END AMS_Dm_Target_Sources_PVT;

/
