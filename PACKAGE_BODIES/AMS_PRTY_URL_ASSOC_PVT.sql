--------------------------------------------------------
--  DDL for Package Body AMS_PRTY_URL_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PRTY_URL_ASSOC_PVT" as
/* $Header: amsvpuab.pls 120.0 2005/07/01 03:52:48 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Prty_Url_Assoc_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Prty_Url_Assoc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvpuab.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Prty_Url_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prty_url_assoc_rec               IN   prty_url_assoc_rec_type  := g_miss_prty_url_assoc_rec,
    x_assoc_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Prty_Url_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_ASSOC_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_PRETTY_URL_ASSOC_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_PRETTY_URL_ASSOC
      WHERE ASSOC_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Prty_Url_Assoc_PVT;

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

   IF p_prty_url_assoc_rec.ASSOC_ID IS NULL OR p_prty_url_assoc_rec.ASSOC_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ASSOC_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ASSOC_ID);
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
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Prty_Url_Assoc');

          -- Invoke validation procedures
          Validate_prty_url_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_prty_url_assoc_rec  =>  p_prty_url_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_PRETTY_URL_ASSOC_PKG.Insert_Row)
      AMS_PRETTY_URL_ASSOC_PKG.Insert_Row(
          px_assoc_id  => l_assoc_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_system_url_id  => p_prty_url_assoc_rec.system_url_id,
          p_used_by_obj_type  => p_prty_url_assoc_rec.used_by_obj_type,
          p_used_by_obj_id  => p_prty_url_assoc_rec.used_by_obj_id);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_assoc_id := l_assoc_id;
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
     ROLLBACK TO CREATE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Prty_Url_Assoc_PVT;
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
End Create_Prty_Url_Assoc;


PROCEDURE Update_Prty_Url_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prty_url_assoc_rec               IN    prty_url_assoc_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
CURSOR c_get_prty_url_assoc(assoc_id NUMBER) IS
    SELECT *
    FROM  AMS_PRETTY_URL_ASSOC;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Prty_Url_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ASSOC_ID    NUMBER;
l_ref_prty_url_assoc_rec  c_get_Prty_Url_Assoc%ROWTYPE ;
l_tar_prty_url_assoc_rec  AMS_Prty_Url_Assoc_PVT.prty_url_assoc_rec_type := P_prty_url_assoc_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Prty_Url_Assoc_PVT;

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
      OPEN c_get_Prty_Url_Assoc( l_tar_prty_url_assoc_rec.assoc_id);

      FETCH c_get_Prty_Url_Assoc INTO l_ref_prty_url_assoc_rec  ;

       If ( c_get_Prty_Url_Assoc%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Prty_Url_Assoc') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Prty_Url_Assoc;
*/


      If (l_tar_prty_url_assoc_rec.object_version_number is NULL or
          l_tar_prty_url_assoc_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_prty_url_assoc_rec.object_version_number <> l_ref_prty_url_assoc_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Prty_Url_Assoc') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Prty_Url_Assoc');

          -- Invoke validation procedures
          Validate_prty_url_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_prty_url_assoc_rec  =>  p_prty_url_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_PRETTY_URL_ASSOC_PKG.Update_Row)
      AMS_PRETTY_URL_ASSOC_PKG.Update_Row(
          p_assoc_id  => p_prty_url_assoc_rec.assoc_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_prty_url_assoc_rec.object_version_number,
          p_system_url_id  => p_prty_url_assoc_rec.system_url_id,
          p_used_by_obj_type  => p_prty_url_assoc_rec.used_by_obj_type,
          p_used_by_obj_id  => p_prty_url_assoc_rec.used_by_obj_id);
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
     ROLLBACK TO UPDATE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Prty_Url_Assoc_PVT;
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
End Update_Prty_Url_Assoc;


PROCEDURE Delete_Prty_Url_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_assoc_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Prty_Url_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Prty_Url_Assoc_PVT;

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

      -- Invoke table handler(AMS_PRETTY_URL_ASSOC_PKG.Delete_Row)
      AMS_PRETTY_URL_ASSOC_PKG.Delete_Row(
          p_ASSOC_ID  => p_ASSOC_ID);
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
     ROLLBACK TO DELETE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Prty_Url_Assoc_PVT;
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
End Delete_Prty_Url_Assoc;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Prty_Url_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_assoc_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Prty_Url_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ASSOC_ID                  NUMBER;

CURSOR c_Prty_Url_Assoc IS
   SELECT ASSOC_ID
   FROM AMS_PRETTY_URL_ASSOC
   WHERE ASSOC_ID = p_ASSOC_ID
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
  OPEN c_Prty_Url_Assoc;

  FETCH c_Prty_Url_Assoc INTO l_ASSOC_ID;

  IF (c_Prty_Url_Assoc%NOTFOUND) THEN
    CLOSE c_Prty_Url_Assoc;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Prty_Url_Assoc;

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
     ROLLBACK TO LOCK_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Prty_Url_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Prty_Url_Assoc_PVT;
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
End Lock_Prty_Url_Assoc;


PROCEDURE check_prty_url_assoc_uk_items(
    p_prty_url_assoc_rec               IN   prty_url_assoc_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PRETTY_URL_ASSOC',
         'ASSOC_ID = ''' || p_prty_url_assoc_rec.ASSOC_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PRETTY_URL_ASSOC',
         'ASSOC_ID = ''' || p_prty_url_assoc_rec.ASSOC_ID ||
         ''' AND ASSOC_ID <> ' || p_prty_url_assoc_rec.ASSOC_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ASSOC_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_prty_url_assoc_uk_items;

PROCEDURE check_prty_url_assoc_req_items(
    p_prty_url_assoc_rec               IN  prty_url_assoc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_prty_url_assoc_rec.assoc_id = FND_API.g_miss_num OR p_prty_url_assoc_rec.assoc_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_assoc_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.creation_date = FND_API.g_miss_date OR p_prty_url_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.created_by = FND_API.g_miss_num OR p_prty_url_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.last_update_date = FND_API.g_miss_date OR p_prty_url_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.last_updated_by = FND_API.g_miss_num OR p_prty_url_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.system_url_id = FND_API.g_miss_num OR p_prty_url_assoc_rec.system_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_system_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.used_by_obj_type = FND_API.g_miss_char OR p_prty_url_assoc_rec.used_by_obj_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_used_by_obj_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.used_by_obj_id = FND_API.g_miss_num OR p_prty_url_assoc_rec.used_by_obj_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_used_by_obj_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_prty_url_assoc_rec.assoc_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_assoc_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.system_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_system_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.used_by_obj_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_used_by_obj_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prty_url_assoc_rec.used_by_obj_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prty_url_assoc_NO_used_by_obj_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_prty_url_assoc_req_items;

PROCEDURE check_prty_url_assoc_FK_items(
    p_prty_url_assoc_rec IN prty_url_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_prty_url_assoc_FK_items;

PROCEDURE check_prty_url_asoc_lkup_itms(
    p_prty_url_assoc_rec IN prty_url_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_prty_url_asoc_lkup_itms;

PROCEDURE Check_prty_url_assoc_Items (
    P_prty_url_assoc_rec     IN    prty_url_assoc_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_prty_url_assoc_uk_items(
      p_prty_url_assoc_rec => p_prty_url_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_prty_url_assoc_req_items(
      p_prty_url_assoc_rec => p_prty_url_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_prty_url_assoc_FK_items(
      p_prty_url_assoc_rec => p_prty_url_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_prty_url_asoc_lkup_itms(
      p_prty_url_assoc_rec => p_prty_url_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_prty_url_assoc_Items;

PROCEDURE Complete_prty_url_assoc_Rec (
   p_prty_url_assoc_rec IN prty_url_assoc_rec_type,
   x_complete_rec OUT NOCOPY prty_url_assoc_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_pretty_url_assoc
      WHERE assoc_id = p_prty_url_assoc_rec.assoc_id;
   l_prty_url_assoc_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_prty_url_assoc_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prty_url_assoc_rec;
   CLOSE c_complete;

   -- assoc_id
   IF p_prty_url_assoc_rec.assoc_id = FND_API.g_miss_num THEN
      x_complete_rec.assoc_id := l_prty_url_assoc_rec.assoc_id;
   END IF;

   -- creation_date
   IF p_prty_url_assoc_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_prty_url_assoc_rec.creation_date;
   END IF;

   -- created_by
   IF p_prty_url_assoc_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_prty_url_assoc_rec.created_by;
   END IF;

   -- last_update_date
   IF p_prty_url_assoc_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_prty_url_assoc_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_prty_url_assoc_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_prty_url_assoc_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_prty_url_assoc_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_prty_url_assoc_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_prty_url_assoc_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_prty_url_assoc_rec.object_version_number;
   END IF;

   -- system_url_id
   IF p_prty_url_assoc_rec.system_url_id = FND_API.g_miss_num THEN
      x_complete_rec.system_url_id := l_prty_url_assoc_rec.system_url_id;
   END IF;

   -- used_by_obj_type
   IF p_prty_url_assoc_rec.used_by_obj_type = FND_API.g_miss_char THEN
      x_complete_rec.used_by_obj_type := l_prty_url_assoc_rec.used_by_obj_type;
   END IF;

   -- used_by_obj_id
   IF p_prty_url_assoc_rec.used_by_obj_id = FND_API.g_miss_num THEN
      x_complete_rec.used_by_obj_id := l_prty_url_assoc_rec.used_by_obj_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_prty_url_assoc_Rec;
PROCEDURE Validate_prty_url_assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_prty_url_assoc_rec               IN   prty_url_assoc_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Prty_Url_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_prty_url_assoc_rec  AMS_Prty_Url_Assoc_PVT.prty_url_assoc_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Prty_Url_Assoc_;

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
              Check_prty_url_assoc_Items(
                 p_prty_url_assoc_rec        => p_prty_url_assoc_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_prty_url_assoc_Rec(
         p_prty_url_assoc_rec        => p_prty_url_assoc_rec,
         x_complete_rec        => l_prty_url_assoc_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_prty_url_assoc_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_prty_url_assoc_rec           =>    l_prty_url_assoc_rec);

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
     ROLLBACK TO VALIDATE_Prty_Url_Assoc_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Prty_Url_Assoc_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Prty_Url_Assoc_;
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
End Validate_Prty_Url_Assoc;


PROCEDURE Validate_prty_url_assoc_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_prty_url_assoc_rec               IN    prty_url_assoc_rec_type
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
END Validate_prty_url_assoc_Rec;

END AMS_Prty_Url_Assoc_PVT;

/
