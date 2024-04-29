--------------------------------------------------------
--  DDL for Package Body AMS_CTD_PRM_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTD_PRM_VAL_PVT" as
/* $Header: amsvcpvb.pls 120.0 2005/07/01 03:53:11 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ctd_Prm_Val_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ctd_Prm_Val_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcpvb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Ctd_Prm_Val(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ctd_prm_val_rec               IN   ctd_prm_val_rec_type  := g_miss_ctd_prm_val_rec,
    x_action_param_value_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ctd_Prm_Val';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_ACTION_PARAM_VALUE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_CTD_PARAM_VALUES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_CTD_PARAM_VALUES
      WHERE ACTION_PARAM_VALUE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ctd_Prm_Val_PVT;

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

   IF p_ctd_prm_val_rec.ACTION_PARAM_VALUE_ID IS NULL OR p_ctd_prm_val_rec.ACTION_PARAM_VALUE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ACTION_PARAM_VALUE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ACTION_PARAM_VALUE_ID);
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
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ctd_Prm_Val');

          -- Invoke validation procedures
          Validate_ctd_prm_val(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ctd_prm_val_rec  =>  p_ctd_prm_val_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_CTD_PARAM_VALUES_PKG.Insert_Row)
      AMS_CTD_PARAM_VALUES_PKG.Insert_Row(
          px_action_param_value_id  => l_action_param_value_id,
          p_action_param_value  => p_ctd_prm_val_rec.action_param_value,
          p_ctd_id  => p_ctd_prm_val_rec.ctd_id,
          p_action_param_id  => p_ctd_prm_val_rec.action_param_id,
          px_object_version_number  => l_object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_security_group_id  => p_ctd_prm_val_rec.security_group_id);
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
     ROLLBACK TO CREATE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ctd_Prm_Val_PVT;
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
End Create_Ctd_Prm_Val;


PROCEDURE Update_Ctd_Prm_Val(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ctd_prm_val_rec               IN    ctd_prm_val_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
CURSOR c_get_ctd_prm_val(action_param_value_id NUMBER) IS
    SELECT *
    FROM  AMS_CTD_PARAM_VALUES;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ctd_Prm_Val';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ACTION_PARAM_VALUE_ID    NUMBER;
l_ref_ctd_prm_val_rec  c_get_Ctd_Prm_Val%ROWTYPE ;
l_tar_ctd_prm_val_rec  AMS_Ctd_Prm_Val_PVT.ctd_prm_val_rec_type := P_ctd_prm_val_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ctd_Prm_Val_PVT;

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
      OPEN c_get_Ctd_Prm_Val( l_tar_ctd_prm_val_rec.action_param_value_id);

      FETCH c_get_Ctd_Prm_Val INTO l_ref_ctd_prm_val_rec  ;

       If ( c_get_Ctd_Prm_Val%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ctd_Prm_Val') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Ctd_Prm_Val;
*/


      If (l_tar_ctd_prm_val_rec.object_version_number is NULL or
          l_tar_ctd_prm_val_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ctd_prm_val_rec.object_version_number <> l_ref_ctd_prm_val_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ctd_Prm_Val') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ctd_Prm_Val');

          -- Invoke validation procedures
          Validate_ctd_prm_val(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ctd_prm_val_rec  =>  p_ctd_prm_val_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_CTD_PARAM_VALUES_PKG.Update_Row)
      AMS_CTD_PARAM_VALUES_PKG.Update_Row(
          p_action_param_value_id  => p_ctd_prm_val_rec.action_param_value_id,
          p_action_param_value  => p_ctd_prm_val_rec.action_param_value,
          p_ctd_id  => p_ctd_prm_val_rec.ctd_id,
          p_action_param_id  => p_ctd_prm_val_rec.action_param_id,
          p_object_version_number  => p_ctd_prm_val_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_security_group_id  => p_ctd_prm_val_rec.security_group_id);
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
     ROLLBACK TO UPDATE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ctd_Prm_Val_PVT;
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
End Update_Ctd_Prm_Val;


PROCEDURE Delete_Ctd_Prm_Val(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_action_param_value_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ctd_Prm_Val';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ctd_Prm_Val_PVT;

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

      -- Invoke table handler(AMS_CTD_PARAM_VALUES_PKG.Delete_Row)
      AMS_CTD_PARAM_VALUES_PKG.Delete_Row(
          p_ACTION_PARAM_VALUE_ID  => p_ACTION_PARAM_VALUE_ID);
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
     ROLLBACK TO DELETE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ctd_Prm_Val_PVT;
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
End Delete_Ctd_Prm_Val;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ctd_Prm_Val(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_action_param_value_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ctd_Prm_Val';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ACTION_PARAM_VALUE_ID                  NUMBER;

CURSOR c_Ctd_Prm_Val IS
   SELECT ACTION_PARAM_VALUE_ID
   FROM AMS_CTD_PARAM_VALUES
   WHERE ACTION_PARAM_VALUE_ID = p_ACTION_PARAM_VALUE_ID
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
  OPEN c_Ctd_Prm_Val;

  FETCH c_Ctd_Prm_Val INTO l_ACTION_PARAM_VALUE_ID;

  IF (c_Ctd_Prm_Val%NOTFOUND) THEN
    CLOSE c_Ctd_Prm_Val;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ctd_Prm_Val;

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
     ROLLBACK TO LOCK_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ctd_Prm_Val_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ctd_Prm_Val_PVT;
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
End Lock_Ctd_Prm_Val;


PROCEDURE check_ctd_prm_val_uk_items(
    p_ctd_prm_val_rec               IN   ctd_prm_val_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CTD_PARAM_VALUES',
         'ACTION_PARAM_VALUE_ID = ''' || p_ctd_prm_val_rec.ACTION_PARAM_VALUE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CTD_PARAM_VALUES',
         'ACTION_PARAM_VALUE_ID = ''' || p_ctd_prm_val_rec.ACTION_PARAM_VALUE_ID ||
         ''' AND ACTION_PARAM_VALUE_ID <> ' || p_ctd_prm_val_rec.ACTION_PARAM_VALUE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ACTION_PARAM_VALUE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ctd_prm_val_uk_items;

PROCEDURE check_ctd_prm_val_req_items(
    p_ctd_prm_val_rec               IN  ctd_prm_val_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ctd_prm_val_rec.action_param_value_id = FND_API.g_miss_num OR p_ctd_prm_val_rec.action_param_value_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_value_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.action_param_value = FND_API.g_miss_char OR p_ctd_prm_val_rec.action_param_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_value');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.ctd_id = FND_API.g_miss_num OR p_ctd_prm_val_rec.ctd_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_ctd_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.action_param_id = FND_API.g_miss_num OR p_ctd_prm_val_rec.action_param_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.object_version_number = FND_API.g_miss_num OR p_ctd_prm_val_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.last_update_date = FND_API.g_miss_date OR p_ctd_prm_val_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.last_updated_by = FND_API.g_miss_num OR p_ctd_prm_val_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.creation_date = FND_API.g_miss_date OR p_ctd_prm_val_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.created_by = FND_API.g_miss_num OR p_ctd_prm_val_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ctd_prm_val_rec.action_param_value_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_value_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.action_param_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_value');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.ctd_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_ctd_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.action_param_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_action_param_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ctd_prm_val_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ctd_prm_val_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_ctd_prm_val_req_items;

PROCEDURE check_ctd_prm_val_FK_items(
    p_ctd_prm_val_rec IN ctd_prm_val_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ctd_prm_val_FK_items;

PROCEDURE check_ctd_prm_val_Lookup_items(
    p_ctd_prm_val_rec IN ctd_prm_val_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ctd_prm_val_Lookup_items;

PROCEDURE Check_ctd_prm_val_Items (
    P_ctd_prm_val_rec     IN    ctd_prm_val_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_ctd_prm_val_uk_items(
      p_ctd_prm_val_rec => p_ctd_prm_val_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ctd_prm_val_req_items(
      p_ctd_prm_val_rec => p_ctd_prm_val_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ctd_prm_val_FK_items(
      p_ctd_prm_val_rec => p_ctd_prm_val_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_ctd_prm_val_Lookup_items(
      p_ctd_prm_val_rec => p_ctd_prm_val_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_ctd_prm_val_Items;


PROCEDURE Complete_ctd_prm_val_Rec (
   p_ctd_prm_val_rec IN ctd_prm_val_rec_type,
   x_complete_rec OUT NOCOPY ctd_prm_val_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_ctd_param_values
      WHERE action_param_value_id = p_ctd_prm_val_rec.action_param_value_id;
   l_ctd_prm_val_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ctd_prm_val_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ctd_prm_val_rec;
   CLOSE c_complete;

   -- action_param_value_id
   IF p_ctd_prm_val_rec.action_param_value_id = FND_API.g_miss_num THEN
      x_complete_rec.action_param_value_id := l_ctd_prm_val_rec.action_param_value_id;
   END IF;

   -- action_param_value
   IF p_ctd_prm_val_rec.action_param_value = FND_API.g_miss_char THEN
      x_complete_rec.action_param_value := l_ctd_prm_val_rec.action_param_value;
   END IF;

   -- ctd_id
   IF p_ctd_prm_val_rec.ctd_id = FND_API.g_miss_num THEN
      x_complete_rec.ctd_id := l_ctd_prm_val_rec.ctd_id;
   END IF;

   -- action_param_id
   IF p_ctd_prm_val_rec.action_param_id = FND_API.g_miss_num THEN
      x_complete_rec.action_param_id := l_ctd_prm_val_rec.action_param_id;
   END IF;

   -- object_version_number
   IF p_ctd_prm_val_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ctd_prm_val_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_ctd_prm_val_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ctd_prm_val_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ctd_prm_val_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ctd_prm_val_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_ctd_prm_val_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ctd_prm_val_rec.last_update_login;
   END IF;

   -- creation_date
   IF p_ctd_prm_val_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ctd_prm_val_rec.creation_date;
   END IF;

   -- created_by
   IF p_ctd_prm_val_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ctd_prm_val_rec.created_by;
   END IF;

   -- security_group_id
   IF p_ctd_prm_val_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_ctd_prm_val_rec.security_group_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ctd_prm_val_Rec;
PROCEDURE Validate_ctd_prm_val(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ctd_prm_val_rec               IN   ctd_prm_val_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ctd_Prm_Val';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ctd_prm_val_rec  AMS_Ctd_Prm_Val_PVT.ctd_prm_val_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ctd_Prm_Val_;

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
              Check_ctd_prm_val_Items(
                 p_ctd_prm_val_rec        => p_ctd_prm_val_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_ctd_prm_val_Rec(
         p_ctd_prm_val_rec        => p_ctd_prm_val_rec,
         x_complete_rec        => l_ctd_prm_val_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ctd_prm_val_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ctd_prm_val_rec           =>    l_ctd_prm_val_rec);

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
     ROLLBACK TO VALIDATE_Ctd_Prm_Val_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ctd_Prm_Val_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ctd_Prm_Val_;
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
End Validate_Ctd_Prm_Val;


PROCEDURE Validate_ctd_prm_val_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ctd_prm_val_rec               IN    ctd_prm_val_rec_type
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
END Validate_ctd_prm_val_Rec;

END AMS_Ctd_Prm_Val_PVT;

/
