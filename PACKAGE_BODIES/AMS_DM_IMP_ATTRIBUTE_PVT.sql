--------------------------------------------------------
--  DDL for Package Body AMS_DM_IMP_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_IMP_ATTRIBUTE_PVT" as
/* $Header: amsvdiab.pls 115.7 2004/06/21 08:11:13 rosharma ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Imp_Attribute_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dm_Imp_Attribute_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdiab.pls';

--
-- Foreward Procedure Declarations
--
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Default_Imp_Attribute_Items (
   p_imp_attribute_rec IN imp_attribute_rec_type ,
   x_imp_attribute_rec OUT NOCOPY imp_attribute_rec_type
);


-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Imp_Attribute
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
--       p_imp_attribute_rec            IN   imp_attribute_rec_type  Required
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

PROCEDURE Create_Imp_Attribute(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_imp_attribute_rec          IN   imp_attribute_rec_type  := g_miss_imp_attribute_rec,
    x_Dm_Imp_Attribute_id        OUT NOCOPY  NUMBER
     )
IS
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Create_Imp_Attribute';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
   l_return_status_full       VARCHAR2(1);
   l_object_version_number    NUMBER := 1;
   l_org_id                   NUMBER := FND_API.G_MISS_NUM;
   l_Dm_Imp_Attribute_id      NUMBER;
   l_dummy                    NUMBER;
   l_imp_attribute_rec        imp_attribute_rec_type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_Dm_Imp_Attribute_pvt;

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
   Default_Imp_Attribute_Items (
      p_imp_attribute_rec  => p_imp_attribute_rec,
      x_imp_attribute_rec  => l_imp_attribute_rec
   );

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

   IF FND_GLOBAL.USER_ID IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
       -- Debug message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: Validate_Imp_Attribute');
       END IF;

       -- Invoke validation procedures
       Validate_imp_attribute(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_validation_mode => JTF_PLSQL_API.g_create,
         p_imp_attribute_rec  => l_imp_attribute_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(Ams_Dm_Imp_Attribute_Pkg.Insert_Row)
   Ams_Dm_Imp_Attribute_Pkg.Insert_Row(
       px_Dm_Imp_Attribute_id  => l_imp_attribute_rec.imp_attribute_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_creation_date  => SYSDATE,
       p_created_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.conc_login_id,
       px_object_version_number  => l_object_version_number,
       p_model_id  => l_imp_attribute_rec.model_id,
       p_source_field_id  => l_imp_attribute_rec.source_field_id,
       p_rank  => l_imp_attribute_rec.rank,
       p_value  => l_imp_attribute_rec.value
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
--
-- End of API body
--

   x_Dm_Imp_Attribute_id := l_imp_attribute_rec.imp_attribute_id;

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
     (p_count  => x_msg_count,
      p_data   => x_msg_data
   );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Dm_Imp_Attribute_PVT;
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
End Create_Imp_Attribute;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Imp_Attribute
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
--       p_imp_attribute_rec            IN   imp_attribute_rec_type  Required
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

PROCEDURE Update_Imp_Attribute(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_imp_attribute_rec               IN    imp_attribute_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

   CURSOR c_get_imp_attribute(imp_attribute_id NUMBER) IS
      SELECT *
      FROM  AMS_DM_IMP_ATTRIBUTES
      WHERE  imp_attribute_id = p_imp_attribute_rec.imp_attribute_id;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Imp_Attribute';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER := p_imp_attribute_rec.object_version_number;
   l_Dm_Imp_Attribute_id    NUMBER;
   l_ref_imp_attribute_rec  c_get_Imp_Attribute%ROWTYPE ;
   l_tar_imp_attribute_rec  imp_attribute_rec_type := p_imp_attribute_rec;
   l_rowid  ROWID;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_Dm_Imp_Attribute_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
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

   OPEN c_get_Imp_Attribute( l_tar_imp_attribute_rec.imp_attribute_id);
   FETCH c_get_Imp_Attribute INTO l_ref_imp_attribute_rec  ;
   If ( c_get_Imp_Attribute%NOTFOUND) THEN
      AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
         p_token_name   => 'INFO',
         p_token_value  => 'Imp_Attribute') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
    -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE c_get_Imp_Attribute;


   If (l_tar_imp_attribute_rec.object_version_number is NULL or
       l_tar_imp_attribute_rec.object_version_number = FND_API.G_MISS_NUM ) Then
      AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
         p_token_name   => 'COLUMN',
         p_token_value  => 'Last_Update_Date') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Check Whether record has been changed by someone else
   If (l_tar_imp_attribute_rec.object_version_number <> l_ref_imp_attribute_rec.object_version_number) Then
      AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
         p_token_name   => 'INFO',
         p_token_value  => 'Imp_Attribute') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_Imp_Attribute');
      END IF;

      -- Invoke validation procedures
      Validate_imp_attribute(
         p_api_version_number => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_validation_level   => p_validation_level,
         p_validation_mode    => JTF_PLSQL_API.g_update,
         p_imp_attribute_rec  => p_imp_attribute_rec,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);
   END IF;
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
   END IF;

   -- Invoke table handler(Ams_Dm_Imp_Attribute_Pkg.Update_Row)
   Ams_Dm_Imp_Attribute_Pkg.Update_Row(
       p_Dm_Imp_Attribute_id  => p_imp_attribute_rec.imp_attribute_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.conc_login_id,
       px_object_version_number  => l_object_version_number,
       p_model_id  => p_imp_attribute_rec.model_id,
       p_source_field_id  => p_imp_attribute_rec.source_field_id,
       p_rank  => p_imp_attribute_rec.rank,
       p_value  => p_imp_attribute_rec.value
   );
   --
   -- End of API body.
   --

   x_object_version_number := l_object_version_number;

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
     (p_count  => x_msg_count,
      p_data   => x_msg_data
   );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Dm_Imp_Attribute_PVT;
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
End Update_Imp_Attribute;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Imp_Attribute
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
--       p_Dm_Imp_Attribute_id                IN   NUMBER
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

PROCEDURE Delete_Imp_Attribute(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_Dm_Imp_Attribute_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Imp_Attribute';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT delete_Dm_Imp_Attribute_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

   -- Invoke table handler(Ams_Dm_Imp_Attribute_Pkg.Delete_Row)
   Ams_Dm_Imp_Attribute_Pkg.Delete_Row(
       p_Dm_Imp_Attribute_id  => p_Dm_Imp_Attribute_id,
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
     (p_count  => x_msg_count,
      p_data   => x_msg_data
   );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Dm_Imp_Attribute_PVT;
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
End Delete_Imp_Attribute;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Imp_Attribute
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
--       p_imp_attribute_rec            IN   imp_attribute_rec_type  Required
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

PROCEDURE Lock_Imp_Attribute(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_Dm_Imp_Attribute_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
)
IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Lock_Imp_Attribute';
   L_API_VERSION_NUMBER    CONSTANT NUMBER   := 1.0;
   L_FULL_NAME             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_Dm_Imp_Attribute_id   NUMBER;

   CURSOR c_imp_attribute IS
      SELECT imp_attribute_id
      FROM ams_dm_imp_attributes
      WHERE imp_attribute_id = p_Dm_Imp_Attribute_id
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
   OPEN c_imp_attribute;
   FETCH c_imp_attribute INTO l_Dm_Imp_Attribute_id;
   IF (c_imp_attribute%NOTFOUND) THEN
      CLOSE c_imp_attribute;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_imp_attribute;

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
     ROLLBACK TO LOCK_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Dm_Imp_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Dm_Imp_Attribute_PVT;
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
End Lock_Imp_Attribute;


PROCEDURE check_Imp_Attribute_UK_Items(
    p_imp_attribute_rec IN   imp_attribute_rec_type,
    p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status     OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                        'ams_dm_imp_attributes',
                        'model_id = ' || p_imp_attribute_rec.model_id ||
                        ' AND source_field_id = ' || p_imp_attribute_rec.source_field_id
                      );
      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_DM_MODEL_FIELD_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                        'ams_dm_imp_attributes',
                        'imp_attribute_id = ' || p_imp_attribute_rec.imp_attribute_id ||
                        ' AND imp_attribute_id <> ' || p_imp_attribute_rec.imp_attribute_id
                      );
      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','IMP_ATTRIBUTE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_Imp_Attribute_UK_Items;


PROCEDURE check_Imp_Attribute_Req_Items(
   p_imp_attribute_rec  IN  imp_attribute_rec_type,
   p_validation_mode    IN VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_imp_attribute_rec.model_id = FND_API.G_MISS_NUM OR p_imp_attribute_rec.model_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MODEL_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_imp_attribute_rec.source_field_id = FND_API.G_MISS_NUM OR p_imp_attribute_rec.source_field_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_imp_attribute_rec.value = FND_API.G_MISS_NUM OR p_imp_attribute_rec.value IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      IF p_imp_attribute_rec.model_id = FND_API.G_MISS_NUM THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MODEL_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_imp_attribute_rec.source_field_id = FND_API.G_MISS_NUM THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_imp_attribute_rec.value = FND_API.G_MISS_NUM THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_Imp_Attribute_Req_Items;


PROCEDURE Check_Imp_Attribute_FK_Items(
   p_imp_attribute_rec  IN imp_attribute_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_model (p_model_id IN NUMBER) IS
      SELECT 1
      FROM   ams_dm_models_all_b
      WHERE  model_id = p_model_id;

   CURSOR c_field (p_source_field_id IN NUMBER) IS
      SELECT 1
      FROM   ams_list_src_fields
      WHERE  list_source_field_id = p_source_field_id;

   l_dummy     NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_model (p_imp_attribute_rec.model_id);
   FETCH c_model INTO l_dummy;
   IF c_model%NOTFOUND THEN
      AMS_Utility_PVT.error_message ('AMS_DM_INVALID_MODEL_REF');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_model;

   OPEN c_field (p_imp_attribute_rec.source_field_id);
   FETCH c_field INTO l_dummy;
   IF c_field%NOTFOUND THEN
      AMS_Utility_PVT.error_message ('AMS_DM_INVALID_SOURCE_FIELD');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_field;
END Check_Imp_Attribute_FK_Items;


PROCEDURE Check_Imp_Attrib_Lookup_Items(
   p_imp_attribute_rec  IN imp_attribute_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- no lookups for this object
END Check_Imp_Attrib_Lookup_Items;


--
-- NOTE
--    Validate every item for every validation
--    type before returning to main api, so all
--    errors are displayed after a single api call.
--
PROCEDURE Check_Imp_Attribute_Items (
    p_imp_attribute_rec     IN    imp_attribute_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN
   l_return_status := FND_API.g_ret_sts_success;

   -- Check Items Uniqueness API calls
   check_Imp_Attribute_UK_Items(
      p_imp_attribute_rec => p_imp_attribute_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_Imp_Attribute_Req_Items(
      p_imp_attribute_rec => p_imp_attribute_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   Check_Imp_Attribute_FK_Items(
      p_imp_attribute_rec => p_imp_attribute_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   Check_Imp_Attrib_Lookup_Items(
      p_imp_attribute_rec => p_imp_attribute_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;
END Check_Imp_Attribute_Items;


PROCEDURE Complete_Imp_Attribute_Rec (
   p_imp_attribute_rec IN imp_attribute_rec_type,
   x_complete_rec OUT NOCOPY imp_attribute_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_imp_attributes
      WHERE imp_attribute_id = p_imp_attribute_rec.imp_attribute_id;
   l_imp_attribute_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_imp_attribute_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_imp_attribute_rec;
   CLOSE c_complete;

   -- imp_attribute_id
   IF p_imp_attribute_rec.imp_attribute_id IS NULL THEN
      x_complete_rec.imp_attribute_id := l_imp_attribute_rec.imp_attribute_id;
   END IF;

   -- last_update_date
   IF p_imp_attribute_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_imp_attribute_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_imp_attribute_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_imp_attribute_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_imp_attribute_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_imp_attribute_rec.creation_date;
   END IF;

   -- created_by
   IF p_imp_attribute_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_imp_attribute_rec.created_by;
   END IF;

   -- last_update_login
   IF p_imp_attribute_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_imp_attribute_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_imp_attribute_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_imp_attribute_rec.object_version_number;
   END IF;

   -- model_id
   IF p_imp_attribute_rec.model_id IS NULL THEN
      x_complete_rec.model_id := l_imp_attribute_rec.model_id;
   END IF;

   -- source_field_id
   IF p_imp_attribute_rec.source_field_id IS NULL THEN
      x_complete_rec.source_field_id := l_imp_attribute_rec.source_field_id;
   END IF;

   -- rank
   IF p_imp_attribute_rec.rank IS NULL THEN
      x_complete_rec.rank := l_imp_attribute_rec.rank;
   END IF;

   -- value
   IF p_imp_attribute_rec.value IS NULL THEN
      x_complete_rec.value := l_imp_attribute_rec.value;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Imp_Attribute_Rec;


PROCEDURE Default_Imp_Attribute_Items (
   p_imp_attribute_rec IN imp_attribute_rec_type ,
   x_imp_attribute_rec OUT NOCOPY imp_attribute_rec_type
)
IS
   CURSOR c_id IS
      SELECT ams_dm_imp_attributes_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_DM_IMP_ATTRIBUTES
      WHERE imp_attribute_id = l_id;

   CURSOR c_lookup_field_id (l_model_id IN NUMBER, l_source_column_name IN VARCHAR2 ) IS
      SELECT f.list_source_field_id
        FROM ams_list_src_fields f, ams_dm_models_all_b m, ams_dm_targets_b t
      WHERE t.target_id = m.target_id
        AND m.model_id = l_model_id
        AND f.list_source_type_id = t.data_source_id
        AND f.source_column_name = l_source_column_name
      UNION
      SELECT f.list_source_field_id
        FROM ams_list_src_fields f, ams_dm_models_all_b m
      WHERE f.list_source_type_id IN (SELECT dts.data_source_id
                                      FROM ams_dm_target_sources dts
                                      WHERE dts.target_id = m.target_id)
        AND m.model_id = l_model_id
        AND f.source_column_name = l_source_column_name
      ;

   l_dummy                 NUMBER;
   l_dm_imp_attribute_id   NUMBER;
   l_source_field_id       NUMBER;

BEGIN
   x_imp_attribute_rec := p_imp_attribute_rec;

   -- default imp_attribute_id
   IF p_imp_attribute_rec.imp_attribute_id IS NULL OR p_imp_attribute_rec.imp_attribute_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_dm_imp_attribute_id;
         CLOSE c_id;

         OPEN c_id_exists(l_dm_imp_attribute_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
      l_dm_imp_attribute_id := p_imp_attribute_rec.imp_attribute_id;
   END IF;

   -- look up source_field_id for the source field name
   IF p_imp_attribute_rec.source_field_name IS NOT NULL AND p_imp_attribute_rec.source_field_name <> FND_API.g_miss_char THEN

         -- Open the cursor and fetch the source field id into a local variable
         OPEN c_lookup_field_id (p_imp_attribute_rec.model_id , p_imp_attribute_rec.source_field_name);
         FETCH c_lookup_field_id INTO l_source_field_id;
         CLOSE c_lookup_field_id;

         x_imp_attribute_rec.source_field_id := l_source_field_id;

   END IF;

   x_imp_attribute_rec.imp_attribute_id := l_dm_imp_attribute_id;
END Default_Imp_Attribute_Items;


PROCEDURE Validate_Imp_Attribute(
   p_api_version_number IN   NUMBER,
   p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_imp_attribute_rec  IN   imp_attribute_rec_type,
   p_validation_mode    IN    VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Validate_Imp_Attribute';
   L_API_VERSION_NUMBER    CONSTANT NUMBER   := 1.0;
   l_object_version_number NUMBER;
   l_imp_attribute_rec     imp_attribute_rec_type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT validate_Dm_Imp_Attribute_;

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
      Check_Imp_Attribute_Items(
         p_imp_attribute_rec        => p_imp_attribute_rec,
         p_validation_mode   => p_validation_mode,
         x_return_status     => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   Complete_Imp_Attribute_Rec(
      p_imp_attribute_rec  => p_imp_attribute_rec,
      x_complete_rec       => l_imp_attribute_rec
   );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_Imp_Attribute_Rec(
         p_api_version_number => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_imp_attribute_rec  => l_imp_attribute_rec);

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
     ROLLBACK TO VALIDATE_Dm_Imp_Attribute_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Dm_Imp_Attribute_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Dm_Imp_Attribute_;
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
End Validate_Imp_Attribute;


PROCEDURE Validate_Imp_Attribute_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_imp_attribute_rec               IN    imp_attribute_rec_type
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

END Validate_Imp_Attribute_Rec;

END AMS_Dm_Imp_Attribute_PVT;

/
