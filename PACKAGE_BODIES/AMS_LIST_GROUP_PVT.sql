--------------------------------------------------------
--  DDL for Package Body AMS_LIST_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_GROUP_PVT" as
/* $Header: amsvlgpb.pls 115.5 2002/11/22 08:55:26 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Group_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_List_Group_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvlgpb.pls';


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_List_Group(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_list_group_rec         IN   list_group_rec_type  := g_miss_list_group_rec,
    x_act_list_group_id      OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_List_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_ACT_LIST_GROUP_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_ACT_LIST_GROUPS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_ACT_LIST_GROUPS
      WHERE ACT_LIST_GROUP_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_List_Group_PVT;

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

   IF p_list_group_rec.ACT_LIST_GROUP_ID IS NULL OR p_list_group_rec.ACT_LIST_GROUP_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ACT_LIST_GROUP_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ACT_LIST_GROUP_ID);
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Group');
          END IF;

          -- Invoke validation procedures
          Validate_list_group(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_group_rec  =>  p_list_group_rec,
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

      -- Invoke table handler(AMS_ACT_LIST_GROUPS_PKG.Insert_Row)
      AMS_ACT_LIST_GROUPS_PKG.Insert_Row(
          px_act_list_group_id  => l_act_list_group_id,
          p_act_list_used_by_id  => p_list_group_rec.act_list_used_by_id,
          p_arc_act_list_used_by  => p_list_group_rec.arc_act_list_used_by,
          p_group_code  => p_list_group_rec.group_code,
          p_group_priority  => p_list_group_rec.group_priority,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_status_code  => p_list_group_rec.status_code,
          p_user_status_id  => p_list_group_rec.user_status_id,
          p_calling_calendar_id  => p_list_group_rec.calling_calendar_id,
          p_release_control_alg_id  => p_list_group_rec.release_control_alg_id,
          p_release_strategy  => p_list_group_rec.release_strategy,
          p_recycling_alg_id  => p_list_group_rec.recycling_alg_id,
          p_callback_priority_flag  => p_list_group_rec.callback_priority_flag,
          p_call_center_ready_flag  => p_list_group_rec.call_center_ready_flag,
          p_dialing_method  => p_list_group_rec.dialing_method,
          p_quantum  => p_list_group_rec.quantum,
          p_quota  => p_list_group_rec.quota,
          p_quota_reset  => p_list_group_rec.quota_reset);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

    x_act_list_group_id      := l_act_list_group_id;
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
     ROLLBACK TO CREATE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_List_Group_PVT;
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
End Create_List_Group;


PROCEDURE Update_List_Group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_group_rec               IN    list_group_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
CURSOR c_get_list_group(cur_act_list_group_id NUMBER) IS
    SELECT *
    FROM  AMS_ACT_LIST_GROUPS
    where act_list_group_id = cur_act_list_group_id ;
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_List_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ACT_LIST_GROUP_ID    NUMBER;
l_ref_list_group_rec  c_get_List_Group%ROWTYPE ;
l_tar_list_group_rec  AMS_List_Group_PVT.list_group_rec_type := P_list_group_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_List_Group_PVT;

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

      OPEN c_get_List_Group( l_tar_list_group_rec.act_list_group_id);

      FETCH c_get_List_Group INTO l_ref_list_group_rec  ;

       If ( c_get_List_Group%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Group') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_List_Group;


      If (l_tar_list_group_rec.object_version_number is NULL or
          l_tar_list_group_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_list_group_rec.object_version_number <> l_ref_list_group_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'List_Group') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_List_Group');
          END IF;

          -- Invoke validation procedures
          Validate_list_group(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_list_group_rec  =>  p_list_group_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_ACT_LIST_GROUPS_PKG.Update_Row)
      AMS_ACT_LIST_GROUPS_PKG.Update_Row(
          p_act_list_group_id  => p_list_group_rec.act_list_group_id,
          p_act_list_used_by_id  => p_list_group_rec.act_list_used_by_id,
          p_arc_act_list_used_by  => p_list_group_rec.arc_act_list_used_by,
          p_group_code  => p_list_group_rec.group_code,
          p_group_priority  => p_list_group_rec.group_priority,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_list_group_rec.object_version_number,
          p_status_code  => p_list_group_rec.status_code,
          p_user_status_id  => p_list_group_rec.user_status_id,
          p_calling_calendar_id  => p_list_group_rec.calling_calendar_id,
          p_release_control_alg_id  => p_list_group_rec.release_control_alg_id,
          p_release_strategy  => p_list_group_rec.release_strategy,
          p_recycling_alg_id  => p_list_group_rec.recycling_alg_id,
          p_callback_priority_flag  => p_list_group_rec.callback_priority_flag,
          p_call_center_ready_flag  => p_list_group_rec.call_center_ready_flag,
          p_dialing_method  => p_list_group_rec.dialing_method,
          p_quantum  => p_list_group_rec.quantum,
          p_quota  => p_list_group_rec.quota,
          p_quota_reset  => p_list_group_rec.quota_reset);
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
     ROLLBACK TO UPDATE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_List_Group_PVT;
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
End Update_List_Group;


PROCEDURE Delete_List_Group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_act_list_group_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_List_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_List_Group_PVT;

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

      -- Invoke table handler(AMS_ACT_LIST_GROUPS_PKG.Delete_Row)
      AMS_ACT_LIST_GROUPS_PKG.Delete_Row(
          p_ACT_LIST_GROUP_ID  => p_ACT_LIST_GROUP_ID);
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
     ROLLBACK TO DELETE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_List_Group_PVT;
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
End Delete_List_Group;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_List_Group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_act_list_group_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_List_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ACT_LIST_GROUP_ID                  NUMBER;

CURSOR c_List_Group IS
   SELECT ACT_LIST_GROUP_ID
   FROM AMS_ACT_LIST_GROUPS
   WHERE ACT_LIST_GROUP_ID = p_ACT_LIST_GROUP_ID
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
  OPEN c_List_Group;

  FETCH c_List_Group INTO l_ACT_LIST_GROUP_ID;

  IF (c_List_Group%NOTFOUND) THEN
    CLOSE c_List_Group;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_List_Group;

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
     ROLLBACK TO LOCK_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_List_Group_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_List_Group_PVT;
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
End Lock_List_Group;


PROCEDURE check_list_group_uk_items(
    p_list_group_rec               IN   list_group_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_LIST_GROUPS',
         'ACT_LIST_GROUP_ID = ''' || p_list_group_rec.ACT_LIST_GROUP_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_LIST_GROUPS',
         'ACT_LIST_GROUP_ID = ''' || p_list_group_rec.ACT_LIST_GROUP_ID ||
         ''' AND ACT_LIST_GROUP_ID <> ' || p_list_group_rec.ACT_LIST_GROUP_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ACT_LIST_GROUP_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_list_group_uk_items;

PROCEDURE check_list_group_req_items(
    p_list_group_rec               IN  list_group_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_list_group_rec.act_list_group_id = FND_API.g_miss_num OR p_list_group_rec.act_list_group_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_act_list_group_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.act_list_used_by_id = FND_API.g_miss_num OR p_list_group_rec.act_list_used_by_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_act_list_used_by_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.arc_act_list_used_by = FND_API.g_miss_char OR p_list_group_rec.arc_act_list_used_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_arc_act_list_used_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.group_code = FND_API.g_miss_char OR p_list_group_rec.group_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_group_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.last_update_date = FND_API.g_miss_date OR p_list_group_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.last_updated_by = FND_API.g_miss_num OR p_list_group_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.creation_date = FND_API.g_miss_date OR p_list_group_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.created_by = FND_API.g_miss_num OR p_list_group_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_list_group_rec.act_list_group_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_act_list_group_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.act_list_used_by_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_act_list_used_by_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.arc_act_list_used_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_arc_act_list_used_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.group_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_group_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_list_group_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_list_group_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_list_group_req_items;

PROCEDURE check_list_group_FK_items(
    p_list_group_rec IN list_group_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_group_FK_items;

PROCEDURE check_list_group_Lookup_items(
    p_list_group_rec IN list_group_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_list_group_Lookup_items;

PROCEDURE Check_list_group_Items (
    P_list_group_rec     IN    list_group_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_list_group_uk_items(
      p_list_group_rec => p_list_group_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_list_group_req_items(
      p_list_group_rec => p_list_group_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_list_group_FK_items(
      p_list_group_rec => p_list_group_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_list_group_Lookup_items(
      p_list_group_rec => p_list_group_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_list_group_Items;


PROCEDURE Complete_list_group_Rec (
   p_list_group_rec IN list_group_rec_type,
   x_complete_rec OUT NOCOPY list_group_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_act_list_groups
      WHERE act_list_group_id = p_list_group_rec.act_list_group_id;
   l_list_group_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_list_group_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_list_group_rec;
   CLOSE c_complete;

   -- act_list_group_id
   IF p_list_group_rec.act_list_group_id = FND_API.g_miss_num THEN
      x_complete_rec.act_list_group_id := l_list_group_rec.act_list_group_id;
   END IF;

   -- act_list_used_by_id
   IF p_list_group_rec.act_list_used_by_id = FND_API.g_miss_num THEN
      x_complete_rec.act_list_used_by_id := l_list_group_rec.act_list_used_by_id;
   END IF;

   -- arc_act_list_used_by
   IF p_list_group_rec.arc_act_list_used_by = FND_API.g_miss_char THEN
      x_complete_rec.arc_act_list_used_by := l_list_group_rec.arc_act_list_used_by;
   END IF;

   -- group_code
   IF p_list_group_rec.group_code = FND_API.g_miss_char THEN
      x_complete_rec.group_code := l_list_group_rec.group_code;
   END IF;

   -- group_priority
   IF p_list_group_rec.group_priority = FND_API.g_miss_num THEN
      x_complete_rec.group_priority := l_list_group_rec.group_priority;
   END IF;

   -- last_update_date
   IF p_list_group_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_list_group_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_list_group_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_list_group_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_list_group_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_list_group_rec.creation_date;
   END IF;

   -- created_by
   IF p_list_group_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_list_group_rec.created_by;
   END IF;

   -- last_update_login
   IF p_list_group_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_list_group_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_list_group_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_list_group_rec.object_version_number;
   END IF;

   -- status_code
   IF p_list_group_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_list_group_rec.status_code;
   END IF;

   -- user_status_id
   IF p_list_group_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_list_group_rec.user_status_id;
   END IF;


   -- calling_calendar_id
   IF p_list_group_rec.calling_calendar_id = FND_API.g_miss_num THEN
      x_complete_rec.calling_calendar_id := l_list_group_rec.calling_calendar_id;
   END IF;

   -- release_control_alg_id
   IF p_list_group_rec.release_control_alg_id = FND_API.g_miss_num THEN
      x_complete_rec.release_control_alg_id := l_list_group_rec.release_control_alg_id;
   END IF;

   -- release_strategy
   IF p_list_group_rec.release_strategy = FND_API.g_miss_char THEN
      x_complete_rec.release_strategy := l_list_group_rec.release_strategy;
   END IF;

   -- recycling_alg_id
   IF p_list_group_rec.recycling_alg_id = FND_API.g_miss_num THEN
      x_complete_rec.recycling_alg_id := l_list_group_rec.recycling_alg_id;
   END IF;

   -- callback_priority_flag
   IF p_list_group_rec.callback_priority_flag = FND_API.g_miss_char THEN
      x_complete_rec.callback_priority_flag := l_list_group_rec.callback_priority_flag;
   END IF;

   -- call_center_ready_flag
   IF p_list_group_rec.call_center_ready_flag = FND_API.g_miss_char THEN
      x_complete_rec.call_center_ready_flag := l_list_group_rec.call_center_ready_flag;
   END IF;

   -- dialing_method
   IF p_list_group_rec.dialing_method = FND_API.g_miss_char THEN
      x_complete_rec.dialing_method := l_list_group_rec.dialing_method;
   END IF;

   -- quantum
   IF p_list_group_rec.quantum = FND_API.g_miss_num THEN
      x_complete_rec.quantum := l_list_group_rec.quantum;
   END IF;

   -- quota
   IF p_list_group_rec.quota = FND_API.g_miss_num THEN
      x_complete_rec.quota := l_list_group_rec.quota;
   END IF;

   -- quota_reset
   IF p_list_group_rec.quota_reset = FND_API.g_miss_num THEN
      x_complete_rec.quota_reset := l_list_group_rec.quota_reset;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_list_group_Rec;
PROCEDURE Validate_list_group(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_list_group_rec               IN   list_group_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_List_Group';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_list_group_rec  AMS_List_Group_PVT.list_group_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_List_Group_;

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
              Check_list_group_Items(
                 p_list_group_rec        => p_list_group_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_list_group_Rec(
         p_list_group_rec        => p_list_group_rec,
         x_complete_rec        => l_list_group_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_list_group_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_list_group_rec           =>    l_list_group_rec);

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
     ROLLBACK TO VALIDATE_List_Group_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_List_Group_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_List_Group_;
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
End Validate_List_Group;


PROCEDURE Validate_list_group_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_group_rec               IN    list_group_rec_type
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
END Validate_list_group_Rec;

END AMS_List_Group_PVT;

/
