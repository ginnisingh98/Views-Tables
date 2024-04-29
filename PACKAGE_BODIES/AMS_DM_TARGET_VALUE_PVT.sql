--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGET_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGET_VALUE_PVT" as
/* $Header: amsvdtvb.pls 115.9 2003/03/19 06:08:40 rosharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Target_Value_PVT
-- Purpose
--
-- History
-- 08-Oct-2002 nyostos  Added value_condition column
-- 16-Oct-2002 choang   Added target_operator and range_value, replacing value_condition
-- 28-Nov-2002 rosharma Added validation for numeric vs varchar target value depending on the field type
-- 17-Mar-2003 nyostos  Added unqiueness check for target_operator + target_value in UPDATE mode.
--                      Fix for bug 2853646.
-- 19-Feb-2003 rosharma Bug # 2853640
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'AMS_Dm_Target_Value_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdtvb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_dm_target_value_Rec (
   p_dm_target_value_rec IN dm_target_value_rec_type,
   x_complete_rec OUT NOCOPY dm_target_value_rec_type
);



-- Hint: Primary key needs to be returned.
PROCEDURE Create_Dm_Target_Value(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_value_rec        IN   dm_target_value_rec_type  := g_miss_dm_target_value_rec,
    x_target_value_id            OUT NOCOPY  NUMBER
 )

 IS
   L_API_NAME                    CONSTANT VARCHAR2(30) := 'Create_Dm_Target_Value';
   L_API_VERSION_NUMBER          CONSTANT NUMBER   := 1.0;
   l_return_status_full          VARCHAR2(1);
   l_object_version_number       NUMBER := 1;
   l_org_id                      NUMBER := FND_API.G_MISS_NUM;
   l_TARGET_VALUE_ID             NUMBER;
   l_dummy                       NUMBER;
   l_dm_target_value_rec         AMS_Dm_Target_Value_PVT.dm_target_value_rec_type := p_dm_target_value_rec;
   l_datasource_id               NUMBER;

   CURSOR c_id IS
      SELECT AMS_DM_TARGET_VALUES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_DM_TARGET_VALUES_VL
      WHERE TARGET_VALUE_ID = l_id;

   -- Cursor to get the data source id for the target
   CURSOR c_datasource_id (l_tgtId IN NUMBER) IS
   SELECT data_source_id
     FROM ams_dm_targets_vl
    WHERE target_id = l_tgtId;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Dm_Target_Value_PVT;

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
   IF l_dm_target_value_rec.TARGET_VALUE_ID IS NULL OR l_dm_target_value_rec.TARGET_VALUE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_dm_target_value_rec.TARGET_VALUE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_dm_target_value_rec.TARGET_VALUE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message( l_api_name || ' New Target Value ID to Insert = ' || l_dm_target_value_rec.TARGET_VALUE_ID);

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
       -- Invoke validation procedures
       Validate_dm_target_value(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => p_validation_level,
            p_validation_mode       => JTF_PLSQL_API.g_create,
            p_dm_target_value_rec   => l_dm_target_value_rec,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(AMS_DM_TARGET_VALUES_B_PKG.Insert_Row)
   AMS_DM_TARGET_VALUES_B_PKG.Insert_Row(
       px_target_value_id        => l_dm_target_value_rec.TARGET_VALUE_ID,
       p_last_update_date        => SYSDATE,
       p_last_updated_by         => G_USER_ID,
       p_creation_date           => SYSDATE,
       p_created_by              => G_USER_ID,
       p_last_update_login       => G_LOGIN_ID,
       px_object_version_number  => l_object_version_number,
       p_target_id               => l_dm_target_value_rec.target_id,
       p_target_value            => l_dm_target_value_rec.target_value,
       p_target_operator         => l_dm_target_value_rec.target_operator,
       p_range_value             => l_dm_target_value_rec.range_value,
       p_description             => l_dm_target_value_rec.description
   );

   -- Set the return value for the new target value id
   x_target_value_id := l_dm_target_value_rec.target_value_id;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message( l_api_name || ' Going to activate target: ' || l_dm_target_value_rec.target_id);

   END IF;

   -- After successfully inserting the target value record, Set the target to Active
   update ams_dm_targets_b
      set active_flag = 'Y'
    where target_id = l_dm_target_value_rec.target_id;

   -- Also enable the associated data source
   -- Get the data source id for this target
   OPEN  c_datasource_id(l_dm_target_value_rec.target_id);
   FETCH c_datasource_id INTO l_datasource_id;
   CLOSE c_datasource_id;

   update ams_list_src_types
      set enabled_flag = 'Y',
          object_version_number = object_version_number + 1
    where list_source_type_id = l_datasource_id;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
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
     ROLLBACK TO CREATE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Dm_Target_Value_PVT;
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
End Create_Dm_Target_Value;


PROCEDURE Update_Dm_Target_Value(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_value_rec        IN   dm_target_value_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
)

 IS


    CURSOR c_get_dm_target_value(p_target_value_id NUMBER) IS
        SELECT *
        FROM  AMS_DM_TARGET_VALUES_VL
        WHERE target_value_id = p_target_value_id;


    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Dm_Target_Value';
    L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

    -- Local Variables
    l_object_version_number     NUMBER;
    l_TARGET_VALUE_ID      NUMBER;
    l_ref_dm_target_value_rec c_get_Dm_Target_Value%ROWTYPE ;
    l_tar_dm_target_value_rec AMS_Dm_Target_Value_PVT.dm_target_value_rec_type := P_dm_target_value_rec;
    l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Dm_Target_Value_PVT;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Going to Complete Record');
      END IF;


      -- Complete missing entries in the record before updating
      Complete_dm_target_value_Rec(
         p_dm_target_value_rec  => p_dm_target_value_rec,
         x_complete_rec         => l_tar_dm_target_value_rec
      );

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Reference Cursor');
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('target value id: ' || l_tar_dm_target_value_rec.target_value_id);

      END IF;

      -- get the reference target, which contains
      -- data before the update operation.
      OPEN c_get_Dm_Target_Value( l_tar_dm_target_value_rec.target_value_id);
      FETCH c_get_Dm_Target_Value INTO l_ref_dm_target_value_rec  ;

       If ( c_get_Dm_Target_Value%NOTFOUND) THEN
           AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                         p_token_name   => 'INFO',
                                         p_token_value  => 'Dm_Target_Value') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Reference Cursor');
       END IF;
       CLOSE     c_get_Dm_Target_Value;


      If (l_tar_dm_target_value_rec.object_version_number is NULL or
          l_tar_dm_target_value_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                        p_token_name   => 'COLUMN',
                                        p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_dm_target_value_rec.object_version_number <> l_ref_dm_target_value_rec.object_version_number) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                        p_token_name   => 'INFO',
                                        p_token_value  => 'Dm_Target_Value') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_dm_target_value(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => p_validation_level,
            p_validation_mode       => JTF_PLSQL_API.g_update,
            p_dm_target_value_rec   => l_tar_dm_target_value_rec,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_DM_TARGET_VALUES_B_PKG.Update_Row)
      AMS_DM_TARGET_VALUES_B_PKG.Update_Row(
          p_target_value_id         => l_tar_dm_target_value_rec.target_value_id,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => G_USER_ID,
          p_last_update_login       => G_LOGIN_ID,
          p_object_version_number   => l_tar_dm_target_value_rec.object_version_number + 1,
          p_target_id               => l_tar_dm_target_value_rec.target_id,
          p_target_value            => l_tar_dm_target_value_rec.target_value,
          p_target_operator         => l_tar_dm_target_value_rec.target_operator,
          p_range_value             => l_tar_dm_target_value_rec.range_value,
          p_description             => l_tar_dm_target_value_rec.description
      );

      x_object_version_number := l_tar_dm_target_value_rec.object_version_number + 1;

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
     ROLLBACK TO UPDATE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Dm_Target_Value_PVT;
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
End Update_Dm_Target_Value;

PROCEDURE Delete_TgtValues_For_Target ( p_target_id IN   NUMBER)
 IS
      L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_TgtValues_For_Target';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_TgtValues_For_Target;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      --
      -- Api body
      --
      DELETE FROM ams_dm_target_values_tl
       WHERE TARGET_VALUE_ID in (SELECT TARGET_VALUE_ID FROM AMS_DM_TARGET_VALUES_B WHERE TARGET_ID = p_TARGET_ID);

      DELETE FROM AMS_DM_TARGET_VALUES_B
       WHERE TARGET_ID = p_TARGET_ID;

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
     ROLLBACK TO Delete_TgtValues_For_Target;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_TgtValues_For_Target;

   WHEN OTHERS THEN
     ROLLBACK TO Delete_TgtValues_For_Target;

End Delete_TgtValues_For_Target;




PROCEDURE Delete_Dm_Target_Value(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_target_value_id            IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
      L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Dm_Target_Value';
      L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
      l_object_version_number     NUMBER;
      l_no_of_target_values       NUMBER;
      l_target_id      NUMBER;
      l_no_of_active_targets      NUMBER;
      l_datasource_id        NUMBER;

      -- Cursor to get the target id for the target value
      CURSOR c_target_id (l_tgtValueId IN NUMBER) IS
      SELECT target_id
        FROM ams_dm_target_values_vl
       WHERE target_value_id = l_tgtValueId;

      -- Cursor to count the target values for a target
      CURSOR c_target_values_count (l_tgtId IN NUMBER) IS
      SELECT count(*)
      FROM AMS_DM_TARGET_VALUES_VL
      WHERE TARGET_ID = l_tgtId;

      -- Cursor to get the data source id for the target
      CURSOR c_datasource_id (l_tgtId IN NUMBER) IS
      SELECT data_source_id
        FROM ams_dm_targets_vl
       WHERE target_id = l_tgtId;

      -- Cursor to count the active targets defined for a data source
      CURSOR c_target_count (l_dsId IN NUMBER) IS
      SELECT count(*)
      FROM AMS_DM_TARGETS_VL
      WHERE DATA_SOURCE_ID = l_dsId
        AND ACTIVE_FLAG = 'Y';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Dm_Target_Value_PVT;

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

       -- Get the target id for this target value record before deleting it
      OPEN c_target_id(p_target_value_id);
      FETCH c_target_id INTO l_target_id;
      CLOSE c_target_id;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Before Delete: TARGET_ID = ' || l_target_id );

      END IF;

      -- Invoke table handler(AMS_DM_TARGET_VALUES_B_PKG.Delete_Row)
      AMS_DM_TARGET_VALUES_B_PKG.Delete_Row(
          p_TARGET_VALUE_ID  => p_TARGET_VALUE_ID);


       -- After successfully deleteing the target value, check if there are no more
       -- target values for the target. If none exist, then de-activate the target.
      OPEN c_target_values_count(l_target_id);
      FETCH c_target_values_count INTO l_no_of_target_values;
      CLOSE c_target_values_count;


      IF l_no_of_target_values = 0 THEN

         -- Disable this target
         update ams_dm_targets_b
            set active_flag = 'N'
          where target_id = l_target_id;

         -- Also disable the associated data source if it has no more active targets
         -- Get the data source id for this target
         OPEN c_datasource_id(l_target_id);
         FETCH c_datasource_id INTO l_datasource_id;
         CLOSE c_datasource_id;

         -- Count the number of active targets for the data source
         OPEN c_target_count(l_datasource_id);
         FETCH c_target_count INTO l_no_of_active_targets;
         CLOSE c_target_count;

         IF l_no_of_active_targets = 0 THEN
            update ams_list_src_types
               set enabled_flag = 'N'
             where list_source_type_id = l_datasource_id;
         END IF;

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
     ROLLBACK TO DELETE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Dm_Target_Value_PVT;
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
End Delete_Dm_Target_Value;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Dm_Target_Value(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_target_value_id            IN   NUMBER,
    p_object_version             IN   NUMBER
    )

 IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Dm_Target_Value';
    L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
    L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_TARGET_VALUE_ID                  NUMBER;

    CURSOR c_Dm_Target_Value IS
       SELECT TARGET_VALUE_ID
         FROM AMS_DM_TARGET_VALUES_B
        WHERE TARGET_VALUE_ID = p_TARGET_VALUE_ID
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
  OPEN c_Dm_Target_Value;

  FETCH c_Dm_Target_Value INTO l_TARGET_VALUE_ID;

  IF (c_Dm_Target_Value%NOTFOUND) THEN
    CLOSE c_Dm_Target_Value;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Dm_Target_Value;

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
     ROLLBACK TO LOCK_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Dm_Target_Value_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Dm_Target_Value_PVT;
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
End Lock_Dm_Target_Value;


PROCEDURE check_uk_items(
    p_dm_target_value_rec               IN   dm_target_value_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);

   CURSOR c_op_value IS
      SELECT FND_API.g_false
      FROM   ams_dm_target_values_b tvb
      WHERE  tvb.target_id = p_dm_target_value_rec.target_id
      AND    tvb.target_operator = p_dm_target_value_rec.target_operator
      AND    tvb.target_value = p_dm_target_value_rec.target_value
      ;

   -- March 17, 2003 - nyostos
   -- Added following query for UPDATE mode
   CURSOR c_op_value_updt IS
      SELECT FND_API.g_false
      FROM   ams_dm_target_values_b tvb
      WHERE  tvb.target_id = p_dm_target_value_rec.target_id
      AND    tvb.target_operator = p_dm_target_value_rec.target_operator
      AND    tvb.target_value = p_dm_target_value_rec.target_value
      AND    tvb.target_value_id <> p_dm_target_value_rec.target_value_id
      ;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- validate uniqueness of primary key
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'AMS_DM_TARGET_VALUES_B',
      'TARGET_VALUE_ID = ''' || p_dm_target_value_rec.TARGET_VALUE_ID ||''''
      );
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'AMS_DM_TARGET_VALUES_B',
      'TARGET_VALUE_ID = ''' || p_dm_target_value_rec.TARGET_VALUE_ID ||
      ''' AND TARGET_VALUE_ID <> ' || p_dm_target_value_rec.TARGET_VALUE_ID
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','TARGET_VALUE_ID');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- validate uniqueness of target_id, target_operator and target_value
   l_valid_flag := FND_API.g_true;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      OPEN c_op_value;
      FETCH c_op_value INTO l_valid_flag;
      CLOSE c_op_value;
   ELSE
      -- March 17, 2003 - nyostos
      -- Added following check for UPDATE mode
      OPEN c_op_value_updt;
      FETCH c_op_value_updt INTO l_valid_flag;
      CLOSE c_op_value_updt;
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','TARGET_OPERATOR');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
END check_uk_items;

PROCEDURE check_req_items(
    p_dm_target_value_rec  IN  dm_target_value_rec_type,
    p_validation_mode      IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF (AMS_DEBUG_HIGH_ON) THEN



      ams_utility_pvt.debug_message('Private API:check_req_items for CREATE');

      END IF;

      IF p_dm_target_value_rec.target_value_id = FND_API.g_miss_num OR p_dm_target_value_rec.target_value_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_VALUE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_id = FND_API.g_miss_num OR p_dm_target_value_rec.target_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_value = FND_API.g_miss_char OR p_dm_target_value_rec.target_value IS NULL THEN
         --changed rosharma 19-feb-2003 Bug # 2853640
	 --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_VALUE');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_TARVAL');
         --end change rosharma 19-feb-2003 Bug # 2853640
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_operator = FND_API.g_miss_char OR p_dm_target_value_rec.target_operator IS NULL THEN
         --changed rosharma 19-feb-2003 Bug # 2853640
         --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_OPERATOR');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_TARVAL_OP');
         --end change rosharma 19-feb-2003 Bug # 2853640
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message('Private API:check_req_items for UPDATE');
      END IF;
      IF p_dm_target_value_rec.target_value_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_VALUE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.last_update_date IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATE_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.last_updated_by IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.creation_date IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATION_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.created_by IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.last_update_login IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATE_LOGIN');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.object_version_number IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','OBJECT_VERSION_NUMBER');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_value IS NULL THEN
         --changed rosharma 19-feb-2003 Bug # 2853640
	 --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_VALUE');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_TARVAL');
         --end change rosharma 19-feb-2003 Bug # 2853640
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_value_rec.target_operator IS NULL THEN
         --changed rosharma 19-feb-2003 Bug # 2853640
         --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_OPERATOR');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_TARVAL_OP');
         --end change rosharma 19-feb-2003 Bug # 2853640
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_req_items;

PROCEDURE check_dm_target_value_FK_items(
    p_dm_target_value_rec IN dm_target_value_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --------------------target_id---------------------------
   IF p_dm_target_value_rec.target_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_dm_targets_b',
            'target_id',
            p_dm_target_value_rec.target_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_dm_target_value_FK_items;

PROCEDURE check_Lookup_items(
    p_dm_target_value_rec IN dm_target_value_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- target operator --
   IF p_dm_target_value_rec.target_operator <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_DM_TARGET_OPERATORS',
            p_lookup_code => p_dm_target_value_rec.target_operator
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_INVALID_LOOKUP');
            FND_MESSAGE.set_token ('LOOKUP_CODE', p_dm_target_value_rec.target_operator);
            FND_MESSAGE.set_token ('COLUMN_NAME', 'TARGET_OPERATOR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_Lookup_items;

PROCEDURE Check_dm_target_value_Items (
    P_dm_target_value_rec     IN    dm_target_value_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_uk_items(
      p_dm_target_value_rec => p_dm_target_value_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_req_items(
      p_dm_target_value_rec => p_dm_target_value_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls
   check_dm_target_value_FK_items(
      p_dm_target_value_rec => p_dm_target_value_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups
   check_Lookup_items(
      p_dm_target_value_rec => p_dm_target_value_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_dm_target_value_Items;



PROCEDURE Complete_dm_target_value_Rec (
   p_dm_target_value_rec IN dm_target_value_rec_type,
   x_complete_rec OUT NOCOPY dm_target_value_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_target_values_vl
      WHERE target_value_id = p_dm_target_value_rec.target_value_id;
   l_dm_target_value_rec c_complete%ROWTYPE;
BEGIN

   x_complete_rec := p_dm_target_value_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_dm_target_value_rec;
   CLOSE c_complete;

   -- target_value_id
   IF p_dm_target_value_rec.target_value_id = FND_API.g_miss_num THEN
      x_complete_rec.target_value_id := l_dm_target_value_rec.target_value_id;
   END IF;

   -- last_update_date
   IF p_dm_target_value_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_dm_target_value_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_dm_target_value_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_dm_target_value_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_dm_target_value_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_dm_target_value_rec.creation_date;
   END IF;

   -- created_by
   IF p_dm_target_value_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_dm_target_value_rec.created_by;
   END IF;

   -- last_update_login
   IF p_dm_target_value_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_dm_target_value_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_dm_target_value_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_dm_target_value_rec.object_version_number;
   END IF;

   -- target_id
   IF p_dm_target_value_rec.target_id = FND_API.g_miss_num THEN
      x_complete_rec.target_id := l_dm_target_value_rec.target_id;
   END IF;

   -- target_value
   IF p_dm_target_value_rec.target_value = FND_API.g_miss_char THEN
      x_complete_rec.target_value := l_dm_target_value_rec.target_value;
   END IF;

   -- target_operator
   IF p_dm_target_value_rec.target_operator = FND_API.g_miss_char THEN
      x_complete_rec.target_operator := l_dm_target_value_rec.target_operator;
   END IF;

   -- range_value
   IF p_dm_target_value_rec.range_value = FND_API.g_miss_char THEN
      x_complete_rec.range_value := l_dm_target_value_rec.range_value;
   END IF;

   -- description
   IF p_dm_target_value_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_dm_target_value_rec.description;
   END IF;

END Complete_dm_target_value_Rec;

PROCEDURE Validate_dm_target_value(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_dm_target_value_rec        IN   dm_target_value_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Dm_Target_Value';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
--   l_dm_target_value_rec  AMS_Dm_Target_Value_PVT.dm_target_value_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Dm_Target_Value_;

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
              Check_dm_target_value_Items(
                 p_dm_target_value_rec  => p_dm_target_value_rec,
                 p_validation_mode  => p_validation_mode,
                 x_return_status => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
         Validate_dm_target_value_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_dm_target_value_rec    => p_dm_target_value_rec);

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
     ROLLBACK TO VALIDATE_Dm_Target_Value_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Dm_Target_Value_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Dm_Target_Value_;
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
End Validate_Dm_Target_Value;


PROCEDURE Validate_dm_target_value_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_dm_target_value_rec        IN   dm_target_value_rec_type
    )
IS
   l_data_type       VARCHAR2(30) := NULL;

    -- Cursor to get the data type for the target field
    -- Added rosharma 28-Nov-2002
    CURSOR c_field_data_type (l_tgtId IN NUMBER) IS
    SELECT a.field_data_type
      FROM ams_list_src_fields a, ams_dm_targets_b b
    WHERE b.target_id = l_tgtId
    AND a.list_source_field_id = b.source_field_id;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_target_value_rec');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- if target_operator = BETWEEN then range value is required
   -- and the range must be from lower value to higher value
   IF p_dm_target_value_rec.target_operator IS NOT NULL AND
      p_dm_target_value_rec.target_operator <> FND_API.g_miss_char THEN
      IF p_dm_target_value_rec.target_operator = 'BETWEEN' THEN
         IF p_dm_target_value_rec.range_value IS NULL OR
            p_dm_target_value_rec.range_value = FND_API.g_miss_char THEN
            AMS_Utility_PVT.error_message ('AMS_DM_TARVAL_NO_BETWEEN');
            x_return_status := FND_API.G_RET_STS_ERROR;
         ELSE
            DECLARE
               l_low       NUMBER;
               l_high      NUMBER;
            BEGIN
               -- try to convert to numbers to do
               -- between numbers, else use chars
               -- if invalid number exception thrown
               l_low := TO_NUMBER (p_dm_target_value_rec.target_value);
               l_high := TO_NUMBER (p_dm_target_value_rec.range_value);
               IF l_low > l_high THEN
                  AMS_Utility_PVT.error_message ('AMS_DM_TARVAL_INVALID_RANGE');
                  x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            EXCEPTION
               WHEN VALUE_ERROR THEN
                  NULL; -- we don't care about char comparisons for between
            END;
         END IF;
      END IF;
   -- x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- start add rosharma 28-Nov-2002
   -- if target field type is NUMBER then value must be a number
   OPEN c_field_data_type(p_dm_target_value_rec.TARGET_ID);
   FETCH c_field_data_type INTO l_data_type;
   CLOSE c_field_data_type;

   IF l_data_type = 'NUMBER' THEN
      DECLARE
         l_value       NUMBER;
      BEGIN
         l_value := TO_NUMBER (p_dm_target_value_rec.target_value);
         IF p_dm_target_value_rec.target_operator IS NOT NULL AND
            p_dm_target_value_rec.target_operator <> FND_API.g_miss_char THEN
            IF p_dm_target_value_rec.target_operator = 'BETWEEN' THEN
	       DECLARE
	          l_high_value       NUMBER;
	       BEGIN
                  l_high_value := TO_NUMBER (p_dm_target_value_rec.range_value);
	       END;
	    END IF;
	 END IF;
      EXCEPTION
            WHEN VALUE_ERROR THEN
               AMS_Utility_PVT.error_message ('AMS_DM_TARVAL_NOT_NUMBER');
               x_return_status := FND_API.G_RET_STS_ERROR;
      END;
   END IF;
   -- end add rosharma 28-Nov-2002

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
END Validate_dm_target_value_Rec;

END AMS_Dm_Target_Value_PVT;

/
