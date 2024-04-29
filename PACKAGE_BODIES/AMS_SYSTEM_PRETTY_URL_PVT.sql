--------------------------------------------------------
--  DDL for Package Body AMS_SYSTEM_PRETTY_URL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SYSTEM_PRETTY_URL_PVT" as
/* $Header: amsvspub.pls 120.0 2005/07/01 03:51:51 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_System_Pretty_Url_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_System_Pretty_Url_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvspub.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_System_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_system_pretty_url_rec               IN   system_pretty_url_rec_type  := g_miss_system_pretty_url_rec,
    x_system_url_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_System_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_SYSTEM_URL_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_SYSTEM_PRETTY_URL_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_SYSTEM_PRETTY_URL
      WHERE SYSTEM_URL_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_System_Pretty_Url_PVT;

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

   -- Local variable initialization

   IF p_system_pretty_url_rec.SYSTEM_URL_ID IS NULL OR p_system_pretty_url_rec.SYSTEM_URL_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_SYSTEM_URL_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_SYSTEM_URL_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
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
          AMS_UTILITY_PVT.debug_message('Private API: Validate_System_Pretty_Url');

          -- Invoke validation procedures
          Validate_system_pretty_url(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_system_pretty_url_rec  =>  p_system_pretty_url_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_SYSTEM_PRETTY_URL_PKG.Insert_Row)
      AMS_SYSTEM_PRETTY_URL_PKG.Insert_Row(
          px_system_url_id  => l_system_url_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_pretty_url_id  => p_system_pretty_url_rec.pretty_url_id,
          p_additional_url_param  => p_system_pretty_url_rec.additional_url_param,
          p_system_url  => p_system_pretty_url_rec.system_url,
          p_ctd_id  => p_system_pretty_url_rec.ctd_id,
          p_track_url  => p_system_pretty_url_rec.track_url);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_system_url_id := l_system_url_id;
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
     ROLLBACK TO CREATE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_System_Pretty_Url_PVT;
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
End Create_System_Pretty_Url;


PROCEDURE Update_System_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_system_pretty_url_rec               IN    system_pretty_url_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
    CURSOR c_get_system_pretty_url(system_url_id NUMBER) IS
    SELECT *
    FROM  AMS_SYSTEM_PRETTY_URL;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_System_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_SYSTEM_URL_ID    NUMBER;
l_ref_system_pretty_url_rec  c_get_System_Pretty_Url%ROWTYPE ;
l_tar_system_pretty_url_rec  AMS_System_Pretty_Url_PVT.system_pretty_url_rec_type := P_system_pretty_url_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_System_Pretty_Url_PVT;

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

/*
      OPEN c_get_System_Pretty_Url( l_tar_system_pretty_url_rec.system_url_id);

      FETCH c_get_System_Pretty_Url INTO l_ref_system_pretty_url_rec  ;

       If ( c_get_System_Pretty_Url%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'System_Pretty_Url') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_System_Pretty_Url;
*/


      If (l_tar_system_pretty_url_rec.object_version_number is NULL or
          l_tar_system_pretty_url_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_system_pretty_url_rec.object_version_number <> l_ref_system_pretty_url_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'System_Pretty_Url') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_System_Pretty_Url');

          -- Invoke validation procedures
          Validate_system_pretty_url(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_system_pretty_url_rec  =>  p_system_pretty_url_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_SYSTEM_PRETTY_URL_PKG.Update_Row)
      AMS_SYSTEM_PRETTY_URL_PKG.Update_Row(
          p_system_url_id  => p_system_pretty_url_rec.system_url_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_system_pretty_url_rec.object_version_number,
          p_pretty_url_id  => p_system_pretty_url_rec.pretty_url_id,
          p_additional_url_param  => p_system_pretty_url_rec.additional_url_param,
          p_system_url  => p_system_pretty_url_rec.system_url,
          p_ctd_id  => p_system_pretty_url_rec.ctd_id,
          p_track_url  => p_system_pretty_url_rec.track_url);
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
     ROLLBACK TO UPDATE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_System_Pretty_Url_PVT;
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
End Update_System_Pretty_Url;


PROCEDURE Delete_System_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_system_url_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_System_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_System_Pretty_Url_PVT;

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

      -- Invoke table handler(AMS_SYSTEM_PRETTY_URL_PKG.Delete_Row)
      AMS_SYSTEM_PRETTY_URL_PKG.Delete_Row(
          p_SYSTEM_URL_ID  => p_SYSTEM_URL_ID);
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
     ROLLBACK TO DELETE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_System_Pretty_Url_PVT;
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
End Delete_System_Pretty_Url;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_System_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_system_url_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_System_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_SYSTEM_URL_ID                  NUMBER;

CURSOR c_System_Pretty_Url IS
   SELECT SYSTEM_URL_ID
   FROM AMS_SYSTEM_PRETTY_URL
   WHERE SYSTEM_URL_ID = p_SYSTEM_URL_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

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

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_System_Pretty_Url;

  FETCH c_System_Pretty_Url INTO l_SYSTEM_URL_ID;

  IF (c_System_Pretty_Url%NOTFOUND) THEN
    CLOSE c_System_Pretty_Url;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_System_Pretty_Url;

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
     ROLLBACK TO LOCK_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_System_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_System_Pretty_Url_PVT;
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
End Lock_System_Pretty_Url;


PROCEDURE CHECK_SYS_PRETTY_URL_uk_itm(
    p_system_pretty_url_rec               IN   system_pretty_url_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_SYSTEM_PRETTY_URL',
         'SYSTEM_URL_ID = ''' || p_system_pretty_url_rec.SYSTEM_URL_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_SYSTEM_PRETTY_URL',
         'SYSTEM_URL_ID = ''' || p_system_pretty_url_rec.SYSTEM_URL_ID ||
         ''' AND SYSTEM_URL_ID <> ' || p_system_pretty_url_rec.SYSTEM_URL_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_SYSTEM_URL_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END CHECK_SYS_PRETTY_URL_uk_itm;

PROCEDURE CHECK_SYS_PRETTY_URL_req_items(
    p_system_pretty_url_rec               IN  system_pretty_url_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_system_pretty_url_rec.system_url_id = FND_API.g_miss_num OR p_system_pretty_url_rec.system_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_system_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.creation_date = FND_API.g_miss_date OR p_system_pretty_url_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.created_by = FND_API.g_miss_num OR p_system_pretty_url_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.last_update_date = FND_API.g_miss_date OR p_system_pretty_url_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.last_updated_by = FND_API.g_miss_num OR p_system_pretty_url_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.pretty_url_id = FND_API.g_miss_num OR p_system_pretty_url_rec.pretty_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_pretty_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.system_url = FND_API.g_miss_char OR p_system_pretty_url_rec.system_url IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_system_url');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_system_pretty_url_rec.system_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_system_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.pretty_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_pretty_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_system_pretty_url_rec.system_url IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_system_pretty_url_NO_system_url');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END CHECK_SYS_PRETTY_URL_req_items;

PROCEDURE CHECK_SYS_PRETTY_URL_FK_items(
    p_system_pretty_url_rec IN system_pretty_url_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END CHECK_SYS_PRETTY_URL_FK_items;

PROCEDURE CHECK_SYS_PRETTY_URL_Lkup_item(
    p_system_pretty_url_rec IN system_pretty_url_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END CHECK_SYS_PRETTY_URL_Lkup_item;

PROCEDURE CHECK_SYS_PRETTY_URL_ITM(
    P_system_pretty_url_rec     IN    system_pretty_url_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   CHECK_SYS_PRETTY_URL_uk_itm(
      p_system_pretty_url_rec => p_system_pretty_url_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   CHECK_SYS_PRETTY_URL_req_items(
      p_system_pretty_url_rec => p_system_pretty_url_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   CHECK_SYS_PRETTY_URL_FK_items(
      p_system_pretty_url_rec => p_system_pretty_url_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   CHECK_SYS_PRETTY_URL_Lkup_item(
      p_system_pretty_url_rec => p_system_pretty_url_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END CHECK_SYS_PRETTY_URL_ITM;


PROCEDURE Complete_system_pretty_url_Rec (
   p_system_pretty_url_rec IN system_pretty_url_rec_type,
   x_complete_rec OUT NOCOPY system_pretty_url_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_system_pretty_url
      WHERE system_url_id = p_system_pretty_url_rec.system_url_id;
   l_system_pretty_url_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_system_pretty_url_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_system_pretty_url_rec;
   CLOSE c_complete;

   -- system_url_id
   IF p_system_pretty_url_rec.system_url_id = FND_API.g_miss_num THEN
      x_complete_rec.system_url_id := l_system_pretty_url_rec.system_url_id;
   END IF;

   -- creation_date
   IF p_system_pretty_url_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_system_pretty_url_rec.creation_date;
   END IF;

   -- created_by
   IF p_system_pretty_url_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_system_pretty_url_rec.created_by;
   END IF;

   -- last_update_date
   IF p_system_pretty_url_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_system_pretty_url_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_system_pretty_url_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_system_pretty_url_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_system_pretty_url_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_system_pretty_url_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_system_pretty_url_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_system_pretty_url_rec.object_version_number;
   END IF;

   -- pretty_url_id
   IF p_system_pretty_url_rec.pretty_url_id = FND_API.g_miss_num THEN
      x_complete_rec.pretty_url_id := l_system_pretty_url_rec.pretty_url_id;
   END IF;

   -- additional_url_param
   IF p_system_pretty_url_rec.additional_url_param = FND_API.g_miss_char THEN
      x_complete_rec.additional_url_param := l_system_pretty_url_rec.additional_url_param;
   END IF;

   -- system_url
   IF p_system_pretty_url_rec.system_url = FND_API.g_miss_char THEN
      x_complete_rec.system_url := l_system_pretty_url_rec.system_url;
   END IF;

   -- ctd_id
   IF p_system_pretty_url_rec.ctd_id = FND_API.g_miss_num THEN
      x_complete_rec.ctd_id := l_system_pretty_url_rec.ctd_id;
   END IF;

   -- track_url
   IF p_system_pretty_url_rec.track_url = FND_API.g_miss_char THEN
      x_complete_rec.track_url := l_system_pretty_url_rec.track_url;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_system_pretty_url_Rec;
PROCEDURE Validate_system_pretty_url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_system_pretty_url_rec               IN   system_pretty_url_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_System_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_system_pretty_url_rec  AMS_System_Pretty_Url_PVT.system_pretty_url_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_System_Pretty_Url_;

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
              CHECK_SYS_PRETTY_URL_ITM(
                 p_system_pretty_url_rec        => p_system_pretty_url_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_system_pretty_url_Rec(
         p_system_pretty_url_rec        => p_system_pretty_url_rec,
         x_complete_rec        => l_system_pretty_url_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_system_pretty_url_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_system_pretty_url_rec           =>    l_system_pretty_url_rec);

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
     ROLLBACK TO VALIDATE_System_Pretty_Url_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_System_Pretty_Url_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_System_Pretty_Url_;
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
End Validate_System_Pretty_Url;


PROCEDURE Validate_system_pretty_url_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_system_pretty_url_rec               IN    system_pretty_url_rec_type
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
END Validate_system_pretty_url_Rec;

END AMS_System_Pretty_Url_PVT;

/
