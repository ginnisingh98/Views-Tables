--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGET_PVT" as
/* $Header: amsvdtgb.pls 120.0 2005/05/31 19:31:20 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGET_PVT
-- Purpose
--
-- History
--          10-Apr-2002  nyostos  Created.
--          30-Jan-2003  nyostos  Changed target name uniqueness code.
--          12-Feb-2004  rosharma Bug # 3436093.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME		CONSTANT VARCHAR2(30)	:= 'AMS_DM_TARGET_PVT';
G_FILE_NAME		CONSTANT VARCHAR2(12)	:= 'amsvdtgb.pls';

G_USER_ID		NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID		NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_dm_target_Rec (
   p_dm_target_rec IN dm_target_rec_type,
   x_complete_rec OUT NOCOPY dm_target_rec_type
);


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_rec              IN   dm_target_rec_type  := g_miss_dm_target_rec,
    x_target_id                  OUT NOCOPY  NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Dmtarget';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_TARGET_ID                 NUMBER;
   l_dummy                     NUMBER;
   l_dm_target_rec             AMS_DM_TARGET_PVT.dm_target_rec_type := p_dm_target_rec;

   CURSOR c_id IS
      SELECT AMS_DM_TARGETS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_DM_TARGETS_VL
      WHERE TARGET_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Dmtarget_PVT;

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

   IF l_dm_target_rec.TARGET_ID IS NULL OR l_dm_target_rec.TARGET_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_dm_target_rec.TARGET_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_dm_target_rec.TARGET_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message( l_api_name || ' New Target ID to Insert = ' || l_dm_target_rec.TARGET_ID );

   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_dmtarget(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_create,
            p_dm_target_rec    => l_dm_target_rec,
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

      -- Invoke table handler(AMS_DM_TARGETS_B_PKG.Insert_Row)
      AMS_DM_TARGETS_B_PKG.Insert_Row(
          px_target_id		=> l_dm_target_rec.target_id,
          p_last_update_date	=> SYSDATE,
          p_last_updated_by	=> G_USER_ID,
          p_creation_date	=> SYSDATE,
          p_created_by		=> G_USER_ID,
          p_last_update_login	=> G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_active_flag		=> l_dm_target_rec.active_flag,
          p_model_type		=> l_dm_target_rec.model_type,
          p_data_source_id	=> l_dm_target_rec.data_source_id,
          p_source_field_id	=> l_dm_target_rec.source_field_id,
	  p_target_name		=> l_dm_target_rec.target_name,
	  p_description		=> l_dm_target_rec.description,
	  p_target_source_id	=> l_dm_target_rec.target_source_id
      );

      x_target_id := l_dm_target_rec.target_id;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* obsoleted rosharma 11.5.10 for Audience data source uptake
      -- After successfully inserting the Target, enable the data source
      -- associated with it if the target is active
      IF l_dm_target_rec.active_flag = 'Y' THEN
	update ams_list_src_types
	   set enabled_flag = 'Y'
         where list_source_type_id = l_dm_target_rec.data_source_id;
      END IF;
      */

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
     ROLLBACK TO CREATE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Dmtarget_PVT;
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
End Create_Dmtarget;


PROCEDURE Update_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_rec              IN    dm_target_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
)

IS
    CURSOR c_get_dmtarget(p_target_id IN NUMBER) IS
       SELECT *
       FROM  AMS_DM_TARGETS_VL
       WHERE target_id = p_target_id;

    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Dmtarget';
    L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

    -- Local Variables
    l_object_version_number     NUMBER;
    l_TARGET_ID                 NUMBER;
    l_ref_dm_target_rec  c_get_Dmtarget%ROWTYPE ;
    l_tar_dm_target_rec  AMS_DM_TARGET_PVT.dm_target_rec_type := P_dm_target_rec;
    l_rowid  ROWID;


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Dmtarget_PVT;

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

      -- Complete missing entries in the record before updating
      Complete_dm_target_Rec(
         p_dm_target_rec        => p_dm_target_rec,
         x_complete_rec         => l_tar_dm_target_rec
      );

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Target Reference Cursor');
      END IF;

      -- get the reference target, which contains
      -- data before the update operation.
      OPEN c_get_Dmtarget( l_tar_dm_target_rec.target_id);
      FETCH c_get_Dmtarget INTO l_ref_dm_target_rec  ;

      IF ( c_get_Dmtarget%NOTFOUND) THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET', p_token_name   => 'INFO', p_token_value  => 'Dmtarget') ;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Close Target Reference Cursor');
      END IF;
      CLOSE c_get_Dmtarget;

      IF (l_tar_dm_target_rec.object_version_number is NULL or
          l_tar_dm_target_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING', p_token_name   => 'COLUMN', p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      IF (l_tar_dm_target_rec.object_version_number <> l_ref_dm_target_rec.object_version_number) Then
         AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED', p_token_name   => 'INFO', p_token_value  => 'Dmtarget') ;
         raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_dmtarget(
            p_api_version_number	=> 1.0,
            p_init_msg_list		=> FND_API.G_FALSE,
            p_validation_level		=> p_validation_level,
            p_validation_mode		=> JTF_PLSQL_API.g_update,
            p_dm_target_rec		=> l_tar_dm_target_rec,
            x_return_status		=> x_return_status,
            x_msg_count			=> x_msg_count,
            x_msg_data			=> x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Updating .........');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_target_id = ' || p_dm_target_rec.target_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_last_update_date = ' || SYSDATE);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_last_updated_by = ' || G_USER_ID);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_creation_date = ' || SYSDATE);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_created_by = ' || G_USER_ID);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_last_update_login = ' || G_LOGIN_ID);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_object_version_number = ' || l_tar_dm_target_rec.object_version_number);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_active_flag = ' || l_tar_dm_target_rec.active_flag);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_model_type = ' || l_tar_dm_target_rec.model_type);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_data_source_id = ' || l_tar_dm_target_rec.data_source_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_source_field_id = ' || l_tar_dm_target_rec.source_field_id);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_target_name = ' || l_tar_dm_target_rec.target_name);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('p_description = ' || l_tar_dm_target_rec.description);
      END IF;

      BEGIN
      -- Invoke table handler(AMS_DM_TARGETS_B_PKG.Update_Row)
      AMS_DM_TARGETS_B_PKG.Update_Row(
	  p_target_id			=> l_tar_dm_target_rec.target_id,
	  p_last_update_date		=> SYSDATE,
	  p_last_updated_by		=> G_USER_ID,
	  p_creation_date		=> SYSDATE,
	  p_created_by			=> G_USER_ID,
	  p_last_update_login		=> G_LOGIN_ID,
	  p_object_version_number	=> l_tar_dm_target_rec.object_version_number,
	  p_active_flag			=> l_tar_dm_target_rec.active_flag,
	  p_model_type			=> l_tar_dm_target_rec.model_type,
	  p_data_source_id		=> l_tar_dm_target_rec.data_source_id,
	  p_source_field_id		=> l_tar_dm_target_rec.source_field_id,
	  p_target_name			=> l_tar_dm_target_rec.target_name,
	  p_description			=> l_tar_dm_target_rec.description,
	  p_target_source_id	        => l_tar_dm_target_rec.target_source_id
      );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
            RAISE FND_API.G_EXC_ERROR;
      END;

      x_object_version_number :=  l_tar_dm_target_rec.object_version_number + 1;

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
     ROLLBACK TO UPDATE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Dmtarget_PVT;
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
End Update_Dmtarget;


PROCEDURE Delete_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_target_id                  IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
      L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Dmtarget';
      L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
      l_object_version_number     NUMBER;
      l_no_of_models              NUMBER;
      l_no_of_active_targets      NUMBER;
      l_datasource_id		  NUMBER;

      -- Cursor to check if target is used in any models
      CURSOR c_target_used (l_id IN NUMBER) IS
      SELECT count(*)
      FROM AMS_DM_MODELS_VL
      WHERE TARGET_ID = l_id;

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
      SAVEPOINT DELETE_Dmtarget_PVT;

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

      -- Validate that the Target is not used by any model
      OPEN c_target_used(p_target_id);
      FETCH c_target_used INTO l_no_of_models;
      CLOSE c_target_used;
      IF l_no_of_models > 0 THEN
	      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_DM_TARGET_USED');
         x_return_status := FND_API.g_ret_sts_error;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- First Delete Target Values associated with this target (if any)
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Going to Delete Target Values Associated with this Target ');
      END IF;

      AMS_Dm_Target_Value_PVT.Delete_TgtValues_For_Target ( p_TARGET_ID );

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message( 'Private API: After Deleting Target Values Associated with this Target ');

      END IF;

      -- added rosharma for audience DS uptake
      -- Delete Child Data Sources associated with this target (if any)
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Going to Delete Child Data Sources Associated with this Target ');
      END IF;

      AMS_Dm_Target_Sources_PVT.delete_tgtsources_for_target ( p_TARGET_ID );

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message( 'Private API: After Deleting Child Data Sources Associated with this Target ');

      END IF;

      /* obsoleted rosharma 11.5.10 for Audience data source uptake
       -- Get the data source id for this target record before deleting it
      OPEN c_datasource_id(p_TARGET_ID);
      FETCH c_datasource_id INTO l_datasource_id;
      CLOSE c_datasource_id;
      */


      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_DM_TARGETS_B_PKG.Delete_Row)
      AMS_DM_TARGETS_B_PKG.Delete_Row(
          p_TARGET_ID  => p_TARGET_ID);

      /* obsoleted rosharma 11.5.10 for Audience data source uptake
       -- After successfully deleteing the target, check if there are no more
       -- active targets for the associated datasource. If none exist, then disable the datasource.
      OPEN c_target_count(l_datasource_id);
      FETCH c_target_count INTO l_no_of_active_targets;
      CLOSE c_target_count;

      IF l_no_of_active_targets = 0 THEN
	update ams_list_src_types
	   set enabled_flag = 'N'
         where list_source_type_id = l_datasource_id;
      END IF;
      */

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
     ROLLBACK TO DELETE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Dmtarget_PVT;
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
End Delete_Dmtarget;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_target_id                  IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Dmtarget';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_TARGET_ID                 NUMBER;

CURSOR c_Dmtarget IS
   SELECT TARGET_ID
   FROM AMS_DM_TARGETS_B
   WHERE TARGET_ID = p_TARGET_ID
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
  OPEN c_Dmtarget;

  FETCH c_Dmtarget INTO l_TARGET_ID;

  IF (c_Dmtarget%NOTFOUND) THEN
    CLOSE c_Dmtarget;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Dmtarget;

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
     ROLLBACK TO LOCK_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Dmtarget_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Dmtarget_PVT;
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
End Lock_Dmtarget;


PROCEDURE check_dm_target_uk_items(
    p_dm_target_rec               IN   dm_target_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1);
   l_number      NUMBER;

   CURSOR c_target_name
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_targets_vl
                     WHERE UPPER(target_name) = UPPER(p_dm_target_rec.target_name)) ;
   CURSOR c_target_name_updt
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_dm_targets_vl
                     WHERE UPPER(target_name) = UPPER(p_dm_target_rec.target_name)
                     AND target_id <> p_dm_target_rec.target_id );

   l_dummy NUMBER ;

   /* commented rosharma. not needed anymore for 11.5.10 and hence
   CURSOR c_unique_values (l_dsId IN NUMBER, l_sfId IN NUMBER, l_modelType IN VARCHAR2, l_targetId IN NUMBER) IS
      SELECT count(*)
      FROM AMS_DM_TARGETS_VL
      WHERE DATA_SOURCE_ID = l_dsId
        AND SOURCE_FIELD_ID = l_sfId
	AND MODEL_TYPE = l_modelType
	AND TARGET_ID <> l_targetId;
   */

BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API:check_dm_target_uk_items');
      END IF;
      x_return_status := FND_API.g_ret_sts_success;

      --Validate unique target_id
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_TARGETS_B',
         'TARGET_ID = ''' || p_dm_target_rec.TARGET_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_TARGETS_B',
         'TARGET_ID = ''' || p_dm_target_rec.TARGET_ID ||
         ''' AND TARGET_ID <> ' || p_dm_target_rec.TARGET_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
	      RETURN;
      END IF;

      --Validate unique target_name
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         OPEN c_target_name ;
         FETCH c_target_name INTO l_dummy;
         CLOSE c_target_name ;
      ELSE
         OPEN c_target_name_updt ;
         FETCH c_target_name_updt INTO l_dummy;
         CLOSE c_target_name_updt ;
      END IF;

      IF l_dummy IS NOT NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_DM_DUP_TARGET_NAME');
         x_return_status := FND_API.g_ret_sts_error;
	      RETURN;
      END IF;

      /* commented rosharma. not needed anymore for 11.5.10 and hence
      --Validate unique model_type + data_source_id + source_field_id combination
      OPEN c_unique_values(p_dm_target_rec.data_source_id, p_dm_target_rec.source_field_id,
                           p_dm_target_rec.model_type, p_dm_target_rec.target_id);
      FETCH c_unique_values INTO l_number;
      CLOSE c_unique_values;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('l_number ' || l_number);
      END IF;
      IF l_number > 0 THEN
	      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_DM_DUP_MODEL_TARGET');
         x_return_status := FND_API.g_ret_sts_error;
	 RETURN;
      END IF;
      */



END check_dm_target_uk_items;

PROCEDURE check_dm_target_req_items(
    p_dm_target_rec     IN  dm_target_rec_type,
    p_validation_mode	IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF (AMS_DEBUG_HIGH_ON) THEN



      ams_utility_pvt.debug_message('Private API:check_dm_target_req_items for CREATE');

      END IF;

      IF p_dm_target_rec.target_id = FND_API.g_miss_num OR p_dm_target_rec.target_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.active_flag = FND_API.g_miss_char OR p_dm_target_rec.active_flag IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','ACTIVE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.model_type = FND_API.g_miss_char OR p_dm_target_rec.model_type IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','MODEL_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.data_source_id = FND_API.g_miss_num OR p_dm_target_rec.data_source_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','DATA_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.source_field_id = FND_API.g_miss_num OR p_dm_target_rec.source_field_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      -- added rosharma for audience DS uptake
      IF p_dm_target_rec.target_source_id = FND_API.g_miss_num OR p_dm_target_rec.target_source_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message('Private API:check_dm_target_req_items for UPDATE');
      END IF;

      IF p_dm_target_rec.target_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.last_update_date IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATE_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.last_updated_by IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.creation_date IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATION_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.created_by IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.active_flag IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','ACTIVE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.model_type IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','MODEL_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.data_source_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','DATA_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_target_rec.source_field_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF (p_dm_target_rec.object_version_number IS NULL OR p_dm_target_rec.object_version_number = FND_API.G_MISS_NUM) THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','OBJECT_VERSION_NUMBER');
         x_return_status := FND_API.g_ret_sts_error;
       END IF;
      -- added rosharma for audience DS uptake
      IF p_dm_target_rec.target_source_id = FND_API.g_miss_num OR p_dm_target_rec.target_source_id IS NULL THEN
	      AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','TARGET_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_dm_target_req_items;

PROCEDURE check_dm_target_FK_items(
    p_dm_target_rec IN dm_target_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_dm_target_FK_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   --------------------data_source_id---------------------------
   IF p_dm_target_rec.data_source_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_src_types',
            'list_source_type_id',
            p_dm_target_rec.data_source_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'DATA_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;


   --------------------source_field_id---------------------------
   IF p_dm_target_rec.source_field_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_src_fields',
            'list_source_field_id',
            p_dm_target_rec.source_field_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;


   -- added rosharma for audience DS uptake
   --------------------target_source_id---------------------------
   IF p_dm_target_rec.target_source_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_src_types',
            'list_source_type_id',
            p_dm_target_rec.target_source_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'TARGET_SOURCE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_dm_target_FK_items;

PROCEDURE check_dm_target_Lookup_items(
    p_dm_target_rec IN dm_target_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API:check_dm_target_Lookup_items');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

 ----------------------- model_type  ------------------------
   IF p_dm_target_rec.model_type <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_DM_MODEL_TYPE',
            p_lookup_code => p_dm_target_rec.model_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_INVALID_LOOKUP');
            FND_MESSAGE.set_token ('LOOKUP_CODE', p_dm_target_rec.model_type);
            FND_MESSAGE.set_token ('COLUMN_NAME', 'MODEL_TYPE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_dm_target_Lookup_items;

PROCEDURE Check_dm_target_Items (
    P_dm_target_rec     IN    dm_target_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN


   -- Check Items Uniqueness API calls
   check_dm_target_uk_items(
      p_dm_target_rec => p_dm_target_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_dm_target_req_items(
      p_dm_target_rec => p_dm_target_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls
   check_dm_target_FK_items(
      p_dm_target_rec => p_dm_target_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups
   check_dm_target_Lookup_items(
      p_dm_target_rec => p_dm_target_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_dm_target_Items;



PROCEDURE Complete_dm_target_Rec (
   p_dm_target_rec IN dm_target_rec_type,
   x_complete_rec OUT NOCOPY dm_target_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_targets_vl
      WHERE target_id = p_dm_target_rec.target_id;
   l_dm_target_rec c_complete%ROWTYPE;

BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Complete_dm_target_Rec start');
   END IF;

   x_complete_rec := p_dm_target_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_dm_target_rec;
   CLOSE c_complete;

   -- target_id
   IF p_dm_target_rec.target_id = FND_API.g_miss_num THEN
      x_complete_rec.target_id := l_dm_target_rec.target_id;
   END IF;

   -- last_update_date
   IF p_dm_target_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_dm_target_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_dm_target_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_dm_target_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_dm_target_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_dm_target_rec.creation_date;
   END IF;

   -- created_by
   IF p_dm_target_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_dm_target_rec.created_by;
   END IF;

   -- last_update_login
   IF p_dm_target_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_dm_target_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_dm_target_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_dm_target_rec.object_version_number;
   END IF;

   -- active_flag
   IF p_dm_target_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_dm_target_rec.active_flag;
   END IF;

   -- model_type
   IF p_dm_target_rec.model_type = FND_API.g_miss_char THEN
      x_complete_rec.model_type := l_dm_target_rec.model_type;
   END IF;

   -- data_source_id
   IF p_dm_target_rec.data_source_id = FND_API.g_miss_num THEN
      x_complete_rec.data_source_id := l_dm_target_rec.data_source_id;
   END IF;

   -- source_field_id
   IF p_dm_target_rec.source_field_id = FND_API.g_miss_num THEN
      x_complete_rec.source_field_id := l_dm_target_rec.source_field_id;
   END IF;

   -- target_source_id
   IF p_dm_target_rec.target_source_id = FND_API.g_miss_num THEN
      x_complete_rec.target_source_id := l_dm_target_rec.target_source_id;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Complete_dm_target_Rec end');
   END IF;

END Complete_dm_target_Rec;

PROCEDURE Validate_dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_dm_target_rec              IN   dm_target_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Dmtarget';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_dm_target_rec  AMS_DM_TARGET_PVT.dm_target_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Dmtarget_;

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

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_dm_target_Items(
                 p_dm_target_rec     => p_dm_target_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_dm_target_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_dm_target_rec          => l_dm_target_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
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
     ROLLBACK TO VALIDATE_Dmtarget_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Dmtarget_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Dmtarget_;
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
End Validate_Dmtarget;


PROCEDURE Validate_dm_target_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_dm_target_rec              IN    dm_target_rec_type
    )
IS
BEGIN
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_target_rec');
      END IF;

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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_dm_target_Rec;

--
-- Purpose
-- Validate access privileges of the selected
-- target.  Access privileges can include team
-- based access.
--
PROCEDURE check_access (
   p_dm_target_rec       IN  dm_target_rec_type,
   p_validation_mode     IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2
);

--
-- History
PROCEDURE check_access (
   p_dm_target_rec       IN  dm_target_rec_type,
   p_validation_mode	 IN  VARCHAR2,
   x_return_status	 OUT NOCOPY VARCHAR2
)
IS
   L_TARGET_QUALIFIER       CONSTANT VARCHAR2(30) := 'TARGET';
   L_ACCESS_TYPE_USER       CONSTANT VARCHAR2(30) := 'USER';

   -- user id of the currently logged in user.
   l_owner_user_id         NUMBER := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   ams_utility_pvt.debug_message ('qualifier: ' || l_target_qualifier || ' id: ' || p_dm_target_rec.target_id || ' resource: ' || l_owner_user_id);

   END IF;
   -- validate access privileges
   IF AMS_Access_PVT.check_update_access (
         p_object_id       => p_dm_target_rec.target_id,
         p_object_type     => L_TARGET_QUALIFIER,
         p_user_or_role_id => l_owner_user_id,
         p_user_or_role_type  => L_ACCESS_TYPE_USER) = 'N' THEN
      AMS_Utility_PVT.error_message ('AMS_TARGET_NO_UPDATE_ACCESS');
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
END check_access;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_Data_Source_Disabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_data_source_id          IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_Data_Source_Disabling(
    p_data_source_id         IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Handle_Data_Source_Disabling';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

l_user_status_id        NUMBER;
l_status_code           VARCHAR2(30);

CURSOR c_user_status_id (p_status_type IN VARCHAR2, p_status_code IN VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = p_status_type
   AND    system_status_code = p_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y'
   ;

CURSOR c_pass_status_code (p_user_status_id IN NUMBER) IS
  SELECT system_status_code
  FROM ams_user_statuses_vl
  WHERE user_status_id = p_user_status_id;

BEGIN
      UPDATE ams_dm_targets_b
      SET    active_flag            = 'N',
	     last_update_date       = SYSDATE,
             last_updated_by        = FND_GLOBAL.user_id
      WHERE  (data_source_id = p_data_source_id OR target_source_id = p_data_source_id)
      AND    active_flag = 'Y'
      ;

      OPEN c_user_status_id('AMS_DM_MODEL_STATUS' , 'INVALID');
      FETCH c_user_status_id INTO l_user_status_id;
      CLOSE c_user_status_id;

      OPEN c_pass_status_code (l_user_status_id);
      FETCH c_pass_status_code INTO l_status_code;
      CLOSE c_pass_status_code;

      UPDATE ams_dm_models_all_b a
      SET a.status_code            = l_status_code,
          a.user_status_id         = l_user_status_id,
	  a.last_update_date       = SYSDATE,
          a.last_updated_by        = FND_GLOBAL.user_id,
          a.status_date            = SYSDATE
      WHERE a.status_code = 'AVAILABLE'
      AND (EXISTS
      (SELECT 1
       from ams_dm_targets_b b
       where b.target_id=a.target_id
       and b.data_source_id=p_data_source_id)
      OR EXISTS
      (SELECT 1
       from ams_dm_target_sources c
       where c.target_id=a.target_id
       and c.data_source_id=p_data_source_id));

End Handle_Data_Source_Disabling;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_Data_Source_Enabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_data_source_id          IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_Data_Source_Enabling(
    p_data_source_id         IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Handle_Data_Source_Enabling';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

BEGIN
      UPDATE ams_dm_targets_b a
      SET    a.active_flag            = 'Y',
	     a.last_update_date       = SYSDATE,
             a.last_updated_by        = FND_GLOBAL.user_id
      WHERE  (a.data_source_id = p_data_source_id OR a.target_source_id = p_data_source_id)
      AND EXISTS (SELECT 1 FROM ams_list_src_types b WHERE b.list_source_type_id = a.data_source_id AND b.enabled_flag = 'Y')
      AND EXISTS (SELECT 1 FROM ams_list_src_types c WHERE c.list_source_type_id = a.target_source_id AND c.enabled_flag = 'Y')
      AND (EXISTS (SELECT 1 FROM ams_list_src_type_assocs d WHERE d.MASTER_SOURCE_TYPE_ID = a.data_source_id AND d.SUB_SOURCE_TYPE_ID = a.target_source_id AND d.enabled_flag = 'Y')
           OR a.data_source_id = a.target_source_id)
      AND EXISTS (SELECT 1 FROM ams_dm_target_values_b e where e.target_id = a.target_id)
      AND a.active_flag = 'N'
      ;
End Handle_Data_Source_Enabling;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_DS_Assoc_Enabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_master_source_id          IN   NUMBER
--       p_sub_source_id             IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_DS_Assoc_Enabling(
    p_master_source_id          IN   NUMBER,
    p_sub_source_id             IN   NUMBER
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Handle_DS_Assoc_Enabling';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

BEGIN
      UPDATE ams_dm_targets_b a
      SET    a.active_flag            = 'Y',
	     a.last_update_date       = SYSDATE,
             a.last_updated_by        = FND_GLOBAL.user_id
      WHERE  (a.data_source_id = p_master_source_id AND a.target_source_id = p_sub_source_id)
      AND EXISTS (SELECT 1 FROM ams_list_src_types b WHERE b.list_source_type_id = a.data_source_id AND b.enabled_flag = 'Y')
      AND EXISTS (SELECT 1 FROM ams_list_src_types c WHERE c.list_source_type_id = a.target_source_id AND c.enabled_flag = 'Y')
      AND EXISTS (SELECT 1 FROM ams_list_src_type_assocs d WHERE d.MASTER_SOURCE_TYPE_ID = a.data_source_id AND d.SUB_SOURCE_TYPE_ID = a.target_source_id AND d.enabled_flag = 'Y')
      AND EXISTS (SELECT 1 FROM ams_dm_target_values_b e where e.target_id = a.target_id)
      AND a.active_flag = 'N'
      ;
End Handle_DS_Assoc_Enabling;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_DS_Assoc_Disabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_master_source_id          IN   NUMBER
--       p_sub_source_id             IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_DS_Assoc_Disabling(
    p_master_source_id          IN   NUMBER,
    p_sub_source_id             IN   NUMBER
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Handle_DS_Assoc_Disabling';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

l_user_status_id        NUMBER;
l_status_code           VARCHAR2(30);

CURSOR c_user_status_id (p_status_type IN VARCHAR2, p_status_code IN VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = p_status_type
   AND    system_status_code = p_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y'
   ;

CURSOR c_pass_status_code (p_user_status_id IN NUMBER) IS
  SELECT system_status_code
  FROM ams_user_statuses_vl
  WHERE user_status_id = p_user_status_id;

BEGIN
      UPDATE ams_dm_targets_b
      SET    active_flag            = 'N',
	     last_update_date       = SYSDATE,
             last_updated_by        = FND_GLOBAL.user_id
      WHERE  (data_source_id = p_master_source_id AND target_source_id = p_sub_source_id)
      AND    active_flag = 'Y'
      ;

      OPEN c_user_status_id('AMS_DM_MODEL_STATUS' , 'INVALID');
      FETCH c_user_status_id INTO l_user_status_id;
      CLOSE c_user_status_id;

      OPEN c_pass_status_code (l_user_status_id);
      FETCH c_pass_status_code INTO l_status_code;
      CLOSE c_pass_status_code;

      UPDATE ams_dm_models_all_b a
      SET a.status_code            = l_status_code,
          a.user_status_id         = l_user_status_id,
	  a.last_update_date       = SYSDATE,
          a.last_updated_by        = FND_GLOBAL.user_id,
          a.status_date            = SYSDATE
      WHERE a.status_code = 'AVAILABLE'
      AND (EXISTS
      (SELECT 1
       from ams_dm_targets_b b
       where b.target_id=a.target_id
       and b.data_source_id=p_master_source_id)
      OR EXISTS
      (SELECT 1
       from ams_dm_target_sources c
       where c.target_id=a.target_id
       and c.data_source_id=p_sub_source_id));

      DELETE FROM ams_dm_target_sources
      WHERE  target_id IN (SELECT target_id FROM ams_dm_targets_b WHERE data_source_id = p_master_source_id AND target_source_id <> p_sub_source_id)
      AND    data_source_id = p_sub_source_id
      ;

End Handle_DS_Assoc_Disabling;

PROCEDURE is_target_enabled(
    p_target_id   IN NUMBER,
    x_is_enabled  OUT NOCOPY BOOLEAN
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'is_target_enabled';

l_target_status VARCHAR2(1);

CURSOR c_target_status(p_tgt_id IN NUMBER) IS
   SELECT active_flag from ams_dm_targets_b where target_id = p_tgt_id;

BEGIN
   x_is_enabled := FALSE;

   OPEN c_target_status(p_target_id);
   FETCH c_target_status INTO l_target_status;
   CLOSE c_target_status;

   IF l_target_status = 'Y' THEN
      x_is_enabled := TRUE;
   END IF;
END is_target_enabled;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           in_list
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_string      IN   VARCHAR2     Required
--
--   OUT
--       None
--
--   Version : Current version 1.0
--   History
--          11-May-2005  srivikri  Created. Fix for bug 4360174
--
--   This function is used for binding a list of numbers in an IN clause.
--   The parameter p_string contains a list of numbers separated by "," (comma)
--   The function parses the list of numbers and returns a PL/SQL table of
--   data type NUMBER.
--   This function is used in java/mining/DataSourceFieldsLOV.java
--
--   End of Comments
--   ==============================================================================
--
FUNCTION in_list ( p_string IN VARCHAR2 ) RETURN JTF_NUMBER_TABLE
IS
    l_table            JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
    l_string           LONG DEFAULT p_string || ',';
    l_num              NUMBER;
BEGIN

  LOOP
    EXIT WHEN l_string IS NULL;
    l_table.extend;
    l_num := instr( l_string, ',' );
    l_table( l_table.count ) := substr( l_string, 1, l_num-1 );
    l_string := substr( l_string, l_num+1 );
  END LOOP;
  RETURN l_table;
END in_list;

END AMS_DM_TARGET_PVT;

/
