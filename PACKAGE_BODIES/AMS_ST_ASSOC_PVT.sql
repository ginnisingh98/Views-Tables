--------------------------------------------------------
--  DDL for Package Body AMS_ST_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ST_ASSOC_PVT" as
/* $Header: amsvstab.pls 115.10 2002/11/22 08:56:23 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_St_Assoc_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_St_Assoc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvstab.pls';


-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_St_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_st_assoc_rec               IN   st_assoc_rec_type  := g_miss_st_assoc_rec,
    x_list_source_type_assoc_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_St_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_LIST_SOURCE_TYPE_ASSOC_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_LIST_SRC_TYPE_ASSOCS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_LIST_SRC_TYPE_ASSOCS
      WHERE LIST_SOURCE_TYPE_ASSOC_ID = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_St_Assoc_PVT;

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

   IF p_st_assoc_rec.LIST_SOURCE_TYPE_ASSOC_ID IS NULL OR p_st_assoc_rec.LIST_SOURCE_TYPE_ASSOC_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_LIST_SOURCE_TYPE_ASSOC_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_LIST_SOURCE_TYPE_ASSOC_ID);
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
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_St_Assoc');
          END IF;

          -- Invoke validation procedures
          Validate_st_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_st_assoc_rec  =>  p_st_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_LIST_SRC_TYPE_ASSOCS_PKG.Insert_Row)
      AMS_LIST_SRC_TYPE_ASSOCS_PKG.Insert_Row(
          px_list_source_type_assoc_id  => l_list_source_type_assoc_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_master_source_type_id  => p_st_assoc_rec.master_source_type_id,
          p_sub_source_type_id  => p_st_assoc_rec.sub_source_type_id,
          p_sub_source_type_pk_column  => p_st_assoc_rec.sub_source_type_pk_column,
          p_enabled_flag  => p_st_assoc_rec.enabled_flag,
          p_description  => p_st_assoc_rec.description,
          p_master_source_type_pk_column  =>
                p_st_assoc_rec.master_source_type_pk_column);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_list_source_type_assoc_id := l_list_source_type_assoc_id;
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
     ROLLBACK TO CREATE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_St_Assoc_PVT;
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

End Create_St_Assoc;


PROCEDURE Update_St_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_st_assoc_rec               IN    st_assoc_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_st_assoc(list_source_type_assoc_id NUMBER) IS
    SELECT *
    FROM  AMS_LIST_SRC_TYPE_ASSOCS;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_St_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_LIST_SOURCE_TYPE_ASSOC_ID    NUMBER;
l_ref_st_assoc_rec  c_get_St_Assoc%ROWTYPE ;
l_tar_st_assoc_rec  AMS_St_Assoc_PVT.st_assoc_rec_type := P_st_assoc_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_St_Assoc_PVT;

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

/*
      OPEN c_get_St_Assoc( l_tar_st_assoc_rec.list_source_type_assoc_id);

      FETCH c_get_St_Assoc INTO l_ref_st_assoc_rec  ;

       If ( c_get_St_Assoc%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'St_Assoc') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_St_Assoc;
*/


      If (l_tar_st_assoc_rec.object_version_number is NULL or
          l_tar_st_assoc_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_st_assoc_rec.object_version_number <> l_ref_st_assoc_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'St_Assoc') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_St_Assoc');
          END IF;

          -- Invoke validation procedures
          Validate_st_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_st_assoc_rec  =>  p_st_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;
      --this above statement cause problem of char to number conversion error

      -- Invoke table handler(AMS_LIST_SRC_TYPE_ASSOCS_PKG.Update_Row)
      AMS_LIST_SRC_TYPE_ASSOCS_PKG.Update_Row(
          p_list_source_type_assoc_id  =>
                     p_st_assoc_rec.list_source_type_assoc_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_st_assoc_rec.object_version_number,
          p_master_source_type_id  => p_st_assoc_rec.master_source_type_id,
          p_sub_source_type_id  => p_st_assoc_rec.sub_source_type_id,
          p_sub_source_type_pk_column  =>
                  p_st_assoc_rec.sub_source_type_pk_column,
          p_enabled_flag  => p_st_assoc_rec.enabled_flag,
          p_description  => p_st_assoc_rec.description,
          p_master_source_type_pk_column  =>
                  p_st_assoc_rec.master_source_type_pk_column  );
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
     ROLLBACK TO UPDATE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_St_Assoc_PVT;
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
End Update_St_Assoc;


PROCEDURE Delete_St_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_source_type_assoc_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_St_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_St_Assoc_PVT;

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

      -- Invoke table handler(AMS_LIST_SRC_TYPE_ASSOCS_PKG.Delete_Row)
      AMS_LIST_SRC_TYPE_ASSOCS_PKG.Delete_Row(
          p_LIST_SOURCE_TYPE_ASSOC_ID  => p_LIST_SOURCE_TYPE_ASSOC_ID);
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
     ROLLBACK TO DELETE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_St_Assoc_PVT;
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
End Delete_St_Assoc;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_St_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_source_type_assoc_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_St_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_LIST_SOURCE_TYPE_ASSOC_ID                  NUMBER;

CURSOR c_St_Assoc IS
   SELECT LIST_SOURCE_TYPE_ASSOC_ID
   FROM AMS_LIST_SRC_TYPE_ASSOCS
   WHERE LIST_SOURCE_TYPE_ASSOC_ID = p_LIST_SOURCE_TYPE_ASSOC_ID
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
  OPEN c_St_Assoc;

  FETCH c_St_Assoc INTO l_LIST_SOURCE_TYPE_ASSOC_ID;

  IF (c_St_Assoc%NOTFOUND) THEN
    CLOSE c_St_Assoc;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_St_Assoc;

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
     ROLLBACK TO LOCK_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_St_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_St_Assoc_PVT;
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
End Lock_St_Assoc;


PROCEDURE check_st_assoc_uk_items(
    p_st_assoc_rec               IN   st_assoc_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_SRC_TYPE_ASSOCS',
         'LIST_SOURCE_TYPE_ASSOC_ID = ''' || p_st_assoc_rec.LIST_SOURCE_TYPE_ASSOC_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_SRC_TYPE_ASSOCS',
         'LIST_SOURCE_TYPE_ASSOC_ID = ''' || p_st_assoc_rec.LIST_SOURCE_TYPE_ASSOC_ID ||
         ''' AND LIST_SOURCE_TYPE_ASSOC_ID <> ' || p_st_assoc_rec.LIST_SOURCE_TYPE_ASSOC_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_LIST_SOURCE_TYPE_ASSOC_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_st_assoc_uk_items;

PROCEDURE check_st_assoc_req_items(
    p_st_assoc_rec               IN  st_assoc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

-- p_validation_mode is always passed in JTF_PLSQL_API.g_update.
-- The following automatically generated validation need to be rewriten.

/*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_st_assoc_rec.list_source_type_assoc_id = FND_API.g_miss_num OR p_st_assoc_rec.list_source_type_assoc_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_list_source_type_assoc_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_st_assoc_rec.last_update_date = FND_API.g_miss_date OR p_st_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_st_assoc_rec.last_updated_by = FND_API.g_miss_num OR p_st_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_st_assoc_rec.creation_date = FND_API.g_miss_date OR p_st_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.created_by = FND_API.g_miss_num OR p_st_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.master_source_type_id = FND_API.g_miss_num OR p_st_assoc_rec.master_source_type_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_master_source_type_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.sub_source_type_id = FND_API.g_miss_num OR p_st_assoc_rec.sub_source_type_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_sub_source_type_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_st_assoc_rec.sub_source_type_pk_column = FND_API.g_miss_char OR p_st_assoc_rec.sub_source_type_pk_column IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_sub_source_type_pk_column');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.enabled_flag = FND_API.g_miss_char OR p_st_assoc_rec.enabled_flag IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_enabled_flag');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
  ELSE

      IF p_st_assoc_rec.list_source_type_assoc_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_list_source_type_assoc_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;



      IF p_st_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_st_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_st_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/
      IF p_st_assoc_rec.master_source_type_id IS NULL THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
          FND_MESSAGE.set_token('MISS_FIELD', 'MASTER_SOURCE_TYPE_ID' );
          FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- code required
      IF p_st_assoc_rec.sub_source_type_id IS NULL THEN
         --FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         --FND_MESSAGE.set_token('MISS_FIELD', 'SUB_SOURCE_TYPE_ID' );
         --FND_MSG_PUB.add;
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_NO_SUB_SOURCE_TYPE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      -- code foreign key required
      IF p_st_assoc_rec.sub_source_type_pk_column IS NULL THEN
         --FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         --FND_MESSAGE.set_token('MISS_FIELD', 'SUB_SOURCE_TYPE_PK_COLUMN' );
         --FND_MSG_PUB.add;
	 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_NO_SUB_SOURCE_TYPE_PK_COL');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_st_assoc_rec.enabled_flag IS NULL THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
          FND_MESSAGE.set_token('MISS_FIELD', 'ENABLED_FLAG' );
          FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
--   END IF;


END check_st_assoc_req_items;

PROCEDURE check_st_assoc_FK_items(
    p_st_assoc_rec IN st_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_st_assoc_FK_items;

PROCEDURE check_st_assoc_Lookup_items(
    p_st_assoc_rec IN st_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_st_assoc_Lookup_items;

PROCEDURE Check_st_assoc_Items (
    P_st_assoc_rec     IN    st_assoc_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_st_assoc_uk_items(
      p_st_assoc_rec => p_st_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   -- Check Items Required/NOT NULL API calls

   check_st_assoc_req_items(
      p_st_assoc_rec => p_st_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls


   check_st_assoc_FK_items(
      p_st_assoc_rec => p_st_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups


   check_st_assoc_Lookup_items(
      p_st_assoc_rec => p_st_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_st_assoc_Items;

PROCEDURE Init_StAssoc_Rec(
   x_stassoc_rec  OUT NOCOPY  st_assoc_rec_type
)
IS
BEGIN

   x_stassoc_rec.list_source_type_assoc_id         := FND_API.g_miss_num;
   x_stassoc_rec.LAST_UPDATE_DATE                  := FND_API.g_miss_date;
   x_stassoc_rec.LAST_UPDATED_BY                   := FND_API.g_miss_num;
   x_stassoc_rec.CREATION_DATE                     := FND_API.g_miss_date;
   x_stassoc_rec.CREATED_BY                        := FND_API.g_miss_num;
   x_stassoc_rec.LAST_UPDATE_LOGIN                 := FND_API.g_miss_num;
   x_stassoc_rec.OBJECT_VERSION_NUMBER             := FND_API.g_miss_num;
   x_stassoc_rec.master_source_type_id             := FND_API.g_miss_num;
   x_stassoc_rec.sub_source_type_id                := FND_API.g_miss_num;
   x_stassoc_rec.sub_source_type_pk_column         := FND_API.g_miss_char;
   x_stassoc_rec.enabled_flag                      := FND_API.g_miss_char;
   x_stassoc_rec.description                       := FND_API.g_miss_char;
   x_stassoc_rec.master_source_type_pk_column         := FND_API.g_miss_char;

END Init_StAssoc_rec;

PROCEDURE Complete_st_assoc_Rec (
   p_st_assoc_rec IN st_assoc_rec_type,
   x_complete_rec OUT NOCOPY st_assoc_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_list_src_type_assocs
      WHERE list_source_type_assoc_id = p_st_assoc_rec.list_source_type_assoc_id;
   l_st_assoc_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_st_assoc_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_st_assoc_rec;
   CLOSE c_complete;

   -- list_source_type_assoc_id
   IF p_st_assoc_rec.list_source_type_assoc_id = FND_API.g_miss_num THEN
      x_complete_rec.list_source_type_assoc_id := l_st_assoc_rec.list_source_type_assoc_id;
   END IF;

   -- last_update_date
   IF p_st_assoc_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_st_assoc_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_st_assoc_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_st_assoc_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_st_assoc_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_st_assoc_rec.creation_date;
   END IF;

   -- created_by
   IF p_st_assoc_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_st_assoc_rec.created_by;
   END IF;

   -- last_update_login
   IF p_st_assoc_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_st_assoc_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_st_assoc_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_st_assoc_rec.object_version_number;
   END IF;

   -- master_source_type_id
   IF p_st_assoc_rec.master_source_type_id = FND_API.g_miss_num THEN
      x_complete_rec.master_source_type_id := l_st_assoc_rec.master_source_type_id;
   END IF;

   -- sub_source_type_id
   IF p_st_assoc_rec.sub_source_type_id = FND_API.g_miss_num THEN
      x_complete_rec.sub_source_type_id := l_st_assoc_rec.sub_source_type_id;
   END IF;

   -- sub_source_type_pk_column
   IF p_st_assoc_rec.sub_source_type_pk_column = FND_API.g_miss_char THEN
      x_complete_rec.sub_source_type_pk_column := l_st_assoc_rec.sub_source_type_pk_column;
   END IF;

   -- enabled_flag
   IF p_st_assoc_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_st_assoc_rec.enabled_flag;
   END IF;

   -- description
   IF p_st_assoc_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_st_assoc_rec.description;
   END IF;

   -- sub_source_type_pk_column
   IF p_st_assoc_rec.master_source_type_pk_column = FND_API.g_miss_char THEN
      x_complete_rec.master_source_type_pk_column := l_st_assoc_rec.master_source_type_pk_column;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_st_assoc_Rec;
PROCEDURE Validate_st_assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_st_assoc_rec               IN   st_assoc_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_St_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_st_assoc_rec  AMS_St_Assoc_PVT.st_assoc_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_St_Assoc_;

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
              Check_st_assoc_Items(
                 p_st_assoc_rec        => p_st_assoc_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_st_assoc_Rec(
         p_st_assoc_rec        => p_st_assoc_rec,
         x_complete_rec        => l_st_assoc_rec
      );


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_st_assoc_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_st_assoc_rec           =>    l_st_assoc_rec);

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
     ROLLBACK TO VALIDATE_St_Assoc_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_St_Assoc_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_St_Assoc_;
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
End Validate_St_Assoc;


PROCEDURE Validate_st_assoc_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_st_assoc_rec               IN    st_assoc_rec_type
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
END Validate_st_assoc_Rec;

END AMS_St_Assoc_PVT;

/
