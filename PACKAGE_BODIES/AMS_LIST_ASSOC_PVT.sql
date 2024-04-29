--------------------------------------------------------
--  DDL for Package Body AMS_LIST_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_ASSOC_PVT" as
/* $Header: amsvascb.pls 115.14 2002/11/22 08:54:58 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Assoc_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_List_Assoc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvascb.pls';


-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_List_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_assoc_rec               IN   list_assoc_rec_type  := g_miss_list_assoc_rec,
    x_list_cont_restrictions_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_LIST_CONT_RESTRICTIONs_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_LIST_CONT_RESTRICTIONS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_LIST_CONT_RESTRICTIONS
      WHERE LIST_CONTACT_RESTRICTIONs_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Assoc_PVT;

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

   IF p_list_assoc_rec.LIST_CONT_RESTRICTIONs_ID IS NULL OR p_list_assoc_rec.LIST_CONT_RESTRICTIONs_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_LIST_CONT_RESTRICTIONs_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_LIST_CONT_RESTRICTIONs_ID);
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
/*
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message

          IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Assoc');

          END IF;

          Invoke validation procedures
          Validate_list_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_assoc_rec  =>  p_list_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_LIST_CONT_RESTRICTIONS_PKG.Insert_Row)
      AMS_LIST_CONT_RESTRICTIONS_PKG.Insert_Row(
          px_list_cont_restrictions_id  => l_list_cont_restrictions_id,
          p_list_header_id  => p_list_assoc_rec.list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_do_not_contact_flag  => p_list_assoc_rec.do_not_contact_flag,
          p_media_id  => p_list_assoc_rec.media_id,
          p_list_used_by  => p_list_assoc_rec.list_used_by,
          p_list_used_by_id  => p_list_assoc_rec.list_used_by_id);
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
     ROLLBACK TO CREATE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Assoc_PVT;
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
End Create_List_Assoc;


PROCEDURE Update_List_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_assoc_rec               IN    list_assoc_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_list_assoc(list_cont_restrictions_id NUMBER) IS
    SELECT *
    FROM  AMS_LIST_CONT_RESTRICTIONS;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_LIST_CONT_RESTRICTIONs_ID    NUMBER;
l_ref_list_assoc_rec  c_get_List_Assoc%ROWTYPE ;
l_tar_list_assoc_rec  AMS_List_Assoc_PVT.list_assoc_rec_type := P_list_assoc_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Assoc_PVT;

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
      OPEN c_get_List_Assoc( l_tar_list_assoc_rec.list_cont_restrictions_id);

      FETCH c_get_List_Assoc INTO l_ref_list_assoc_rec  ;

       If ( c_get_List_Assoc%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Assoc') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_List_Assoc;
*/


      If (l_tar_list_assoc_rec.object_version_number is NULL or
          l_tar_list_assoc_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_list_assoc_rec.object_version_number <> l_ref_list_assoc_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Assoc') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Assoc');
          END IF;

          -- Invoke validation procedures
          Validate_list_assoc(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_assoc_rec  =>  p_list_assoc_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_LIST_CONT_RESTRICTIONS_PKG.Update_Row)
      AMS_LIST_CONT_RESTRICTIONS_PKG.Update_Row(
          p_list_cont_restrictions_id  => p_list_assoc_rec.list_cont_restrictions_id,
          p_list_header_id  => p_list_assoc_rec.list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_list_assoc_rec.object_version_number,
          p_do_not_contact_flag  => p_list_assoc_rec.do_not_contact_flag,
          p_media_id  => p_list_assoc_rec.media_id,
          p_list_used_by  => p_list_assoc_rec.list_used_by,
          p_list_used_by_id  => p_list_assoc_rec.list_used_by_id);
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
     ROLLBACK TO UPDATE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_List_Assoc_PVT;
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
End Update_List_Assoc;


PROCEDURE Delete_List_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_cont_restrictions_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Assoc_PVT;

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

      -- Invoke table handler(AMS_LIST_CONT_RESTRICTIONS_PKG.Delete_Row)
      AMS_LIST_CONT_RESTRICTIONS_PKG.Delete_Row(
          p_LIST_CONT_RESTRICTIONs_ID  => p_LIST_CONT_RESTRICTIONs_ID);
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
     ROLLBACK TO DELETE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Assoc_PVT;
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
End Delete_List_Assoc;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_List_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_cont_restrictions_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_List_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_LIST_CONT_RESTRICTIONs_ID                  NUMBER;

CURSOR c_List_Assoc IS
   SELECT LIST_CONTACT_RESTRICTIONs_ID
   FROM AMS_LIST_CONT_RESTRICTIONS
   WHERE LIST_CONTACT_RESTRICTIONs_ID = p_LIST_CONT_RESTRICTIONs_ID
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
  OPEN c_List_Assoc;

  FETCH c_List_Assoc INTO l_LIST_CONT_RESTRICTIONs_ID;

  IF (c_List_Assoc%NOTFOUND) THEN
    CLOSE c_List_Assoc;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_List_Assoc;

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
     ROLLBACK TO LOCK_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_List_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_List_Assoc_PVT;
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
End Lock_List_Assoc;


PROCEDURE check_list_assoc_uk_items(
    p_list_assoc_rec               IN   list_assoc_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_CONT_RESTRICTIONS',
         'LIST_CONTACT_RESTRICTIONs_ID = ''' || p_list_assoc_rec.LIST_CONT_RESTRICTIONs_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_LIST_CONT_RESTRICTIONS',
         'LIST_CONTACT_RESTRICTIONs_ID = ''' || p_list_assoc_rec.LIST_CONT_RESTRICTIONs_ID ||
         ''' AND LIST_CONTACT_RESTRICTIONs_ID <> ' || p_list_assoc_rec.LIST_CONT_RESTRICTIONs_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_LIST_CONTACT_RESTRICTIONS_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_list_assoc_uk_items;

PROCEDURE check_list_assoc_req_items(
    p_list_assoc_rec               IN  list_assoc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
  l_media_id NUMBER;
  CURSOR c_media_id IS
   select media_id
   from ams_media_vl
   where media_type_code='DIRECT_MARKETING'
   and media_id=p_list_assoc_rec.media_id;

   l_camp_id NUMBER;
   CURSOR c_camp_id IS
   select campaign_id from ams_campaigns_vl where rollup_type<>'RCAM'
      and active_flag='Y'
      and show_campaign_flag='Y'
      and status_code not in ('ARCHIVED','CANCELLED')
      and campaign_id=p_list_assoc_rec.list_used_by_id ;

BEGIN


   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_list_assoc_rec.list_cont_restrictions_id = FND_API.g_miss_num OR p_list_assoc_rec.list_cont_restrictions_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_list_contact_restrictions_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.list_header_id = FND_API.g_miss_num OR p_list_assoc_rec.list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.last_update_date = FND_API.g_miss_date OR p_list_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.last_updated_by = FND_API.g_miss_num OR p_list_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.creation_date = FND_API.g_miss_date OR p_list_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.created_by = FND_API.g_miss_num OR p_list_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_list_assoc_rec.list_cont_restrictions_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_list_contact_restrictions_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_assoc_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_assoc_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

      IF p_list_assoc_rec.do_not_contact_flag<>'Y' AND p_list_assoc_rec.do_not_contact_flag<>'N' THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'do_not_contact_flag is neither Y nor N');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
        RETURN;
      END IF;

      IF p_list_assoc_rec.list_used_by<>'CAMP' AND p_list_assoc_rec.list_used_by <> 'MEDI' THEN
         IF p_list_assoc_rec.do_not_contact_flag <> 'Y' THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'list_used_by is neither CAMP nor MEDI');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
            RETURN;
         END IF;
      END IF;

  OPEN c_media_id;

  FETCH c_media_id INTO l_media_id;

  IF (c_media_id%NOTFOUND) THEN
     IF p_list_assoc_rec.do_not_contact_flag <> 'Y' AND
        p_list_assoc_rec.list_used_by = 'MEDI' THEN
        CLOSE c_media_id;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'MEDIA_ID_NOT_VALID');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
  END IF;
  CLOSE c_media_id;

  OPEN c_camp_id;

  FETCH c_camp_id INTO l_camp_id;

  IF (c_camp_id%NOTFOUND) THEN
     IF p_list_assoc_rec.do_not_contact_flag <> 'Y' AND
        p_list_assoc_rec.list_used_by ='CAMP' THEN
        CLOSE c_camp_id;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('AMS', 'CAMPAIGN_ID_NOT_VALID');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
     END IF;
  END IF;
  CLOSE c_camp_id;

END check_list_assoc_req_items;

PROCEDURE check_list_assoc_FK_items(
    p_list_assoc_rec IN list_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_assoc_FK_items;

PROCEDURE check_list_assoc_Lookup_items(
    p_list_assoc_rec IN list_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_assoc_Lookup_items;

PROCEDURE Check_list_assoc_Items (
    P_list_assoc_rec     IN    list_assoc_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_list_assoc_uk_items(
      p_list_assoc_rec => p_list_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_list_assoc_req_items(
      p_list_assoc_rec => p_list_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

   check_list_assoc_FK_items(
      p_list_assoc_rec => p_list_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_list_assoc_Lookup_items(
      p_list_assoc_rec => p_list_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_list_assoc_Items;



PROCEDURE Complete_list_assoc_Rec (
   p_list_assoc_rec IN list_assoc_rec_type,
   x_complete_rec OUT NOCOPY list_assoc_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_list_cont_restrictions
      WHERE list_contact_restrictions_id = p_list_assoc_rec.list_cont_restrictions_id;
   l_list_assoc_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_list_assoc_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_list_assoc_rec;
   CLOSE c_complete;

   -- list_contact_restrictions_id
   IF p_list_assoc_rec.list_cont_restrictions_id = FND_API.g_miss_num THEN
      x_complete_rec.list_cont_restrictions_id := l_list_assoc_rec.list_contact_restrictions_id;
   END IF;

   -- list_header_id
   IF p_list_assoc_rec.list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.list_header_id := l_list_assoc_rec.list_header_id;
   END IF;

   -- last_update_date
   IF p_list_assoc_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_list_assoc_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_list_assoc_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_list_assoc_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_list_assoc_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_list_assoc_rec.creation_date;
   END IF;

   -- created_by
   IF p_list_assoc_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_list_assoc_rec.created_by;
   END IF;

   -- last_update_login
   IF p_list_assoc_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_list_assoc_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_list_assoc_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_list_assoc_rec.object_version_number;
   END IF;

   -- Comment out since do_not_contact_flag, media_id, camp_id are
   -- exclusively. Old data cannot keep along.

   -- do_not_contact_flag
   --IF p_list_assoc_rec.do_not_contact_flag = FND_API.g_miss_char THEN
   --   x_complete_rec.do_not_contact_flag := l_list_assoc_rec.do_not_contact_flag;
   --END IF;

   -- media_id
   --IF p_list_assoc_rec.media_id = FND_API.g_miss_num THEN
   --   x_complete_rec.media_id := l_list_assoc_rec.media_id;
   --END IF;

   -- list_used_by
   --IF p_list_assoc_rec.list_used_by = FND_API.g_miss_char THEN
   --   x_complete_rec.list_used_by := l_list_assoc_rec.list_used_by;
   --END IF;

   -- list_used_by_id
   --IF p_list_assoc_rec.list_used_by_id = FND_API.g_miss_num THEN
   --   x_complete_rec.list_used_by_id := l_list_assoc_rec.list_used_by_id;
   --END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_list_assoc_Rec;
PROCEDURE Validate_list_assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_list_assoc_rec               IN   list_assoc_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_List_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_list_assoc_rec  AMS_List_Assoc_PVT.list_assoc_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_List_Assoc_;

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
              Check_list_assoc_Items(
                 p_list_assoc_rec        => p_list_assoc_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN

                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      Complete_list_assoc_Rec(
         p_list_assoc_rec        => p_list_assoc_rec,
         x_complete_rec        => l_list_assoc_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_list_assoc_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_list_assoc_rec           =>    l_list_assoc_rec);

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
     ROLLBACK TO VALIDATE_List_Assoc_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_List_Assoc_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_List_Assoc_;
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
End Validate_List_Assoc;


PROCEDURE Validate_list_assoc_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_assoc_rec               IN    list_assoc_rec_type
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

      AMS_UTILITY_PVT.debug_message('Private API: Validate_list_assoc_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_list_assoc_Rec;

END AMS_List_Assoc_PVT;

/
