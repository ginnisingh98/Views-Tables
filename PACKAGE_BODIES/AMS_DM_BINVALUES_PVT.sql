--------------------------------------------------------
--  DDL for Package Body AMS_DM_BINVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_BINVALUES_PVT" as
/* $Header: amsvdbvb.pls 115.5 2003/05/07 08:23:10 rosharma ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Binvalues_PVT
-- Purpose
--
-- History
-- 07-May-2003 rosharma Bug # 2943269
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dm_Binvalues_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdbvb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_dm_binvalues_Rec (
   p_dm_binvalues_rec IN dm_binvalues_rec_type,
   x_complete_rec OUT NOCOPY dm_binvalues_rec_type
);


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Dm_Binvalues(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_binvalues_rec           IN   dm_binvalues_rec_type  := g_miss_dm_binvalues_rec,
    x_bin_value_id               OUT NOCOPY  NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30)  := 'Create_Dm_Binvalues';
   L_API_VERSION_NUMBER        CONSTANT NUMBER        := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER                 := 1;
   l_org_id                    NUMBER                 := FND_API.G_MISS_NUM;
   l_BIN_VALUE_ID              NUMBER;
   l_dummy                     NUMBER;
   l_dm_binvalues_rec          AMS_Dm_Binvalues_PVT.dm_binvalues_rec_type:= p_dm_binvalues_rec;

   CURSOR c_id IS
      SELECT AMS_DM_BIN_VALUES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_DM_BIN_VALUES
      WHERE BIN_VALUE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Dm_Binvalues_PVT;

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
      IF l_dm_binvalues_rec.BIN_VALUE_ID IS NULL OR l_dm_binvalues_rec.BIN_VALUE_ID = FND_API.g_miss_num THEN
         LOOP
            l_dummy := NULL;
            OPEN c_id;
            FETCH c_id INTO l_dm_binvalues_rec.BIN_VALUE_ID;
            CLOSE c_id;

            OPEN c_id_exists(l_dm_binvalues_rec.BIN_VALUE_ID);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;

            EXIT WHEN l_dummy IS NULL;
        END LOOP;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message( l_api_name || ' New Bin Value ID to Insert = ' || l_dm_binvalues_rec.BIN_VALUE_ID);

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

       AMS_UTILITY_PVT.debug_message('Private API: Calling Validate_Dm_Binvalues');
       END IF;

       -- Invoke validation procedures
       Validate_dm_binvalues(
         p_api_version_number     => 1.0,
         p_init_msg_list          => FND_API.G_FALSE,
         p_validation_level       => p_validation_level,
         p_validation_mode        => JTF_PLSQL_API.g_create,
         p_dm_binvalues_rec       => l_dm_binvalues_rec,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(AMS_DM_BIN_VALUES_PKG.Insert_Row)
   AMS_DM_BIN_VALUES_PKG.Insert_Row(
       px_bin_value_id		      => l_dm_binvalues_rec.bin_value_id,
       p_last_update_date		   => SYSDATE,
       p_last_updated_by		   => G_USER_ID,
       p_creation_date		      => SYSDATE,
       p_created_by			      => G_USER_ID,
       p_last_update_login		   => G_LOGIN_ID,
       px_object_version_number	=> l_object_version_number,
       p_source_field_id		   => l_dm_binvalues_rec.source_field_id,
       p_bucket			         => l_dm_binvalues_rec.bucket,
       p_bin_value			      => l_dm_binvalues_rec.bin_value,
       p_start_value			      => l_dm_binvalues_rec.start_value,
       p_end_value			      => l_dm_binvalues_rec.end_value);

   -- Set the return value for the new bin value id
   x_bin_value_id := l_dm_binvalues_rec.bin_value_id;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

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
      ROLLBACK TO CREATE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_Dm_Binvalues_PVT;
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
End Create_Dm_Binvalues;


PROCEDURE Update_Dm_Binvalues(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_binvalues_rec           IN   dm_binvalues_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

IS


   CURSOR c_get_dm_binvalues(bin_value_id NUMBER) IS
   SELECT *
   FROM AMS_DM_BIN_VALUES
   WHERE bin_value_id = bin_value_id;


	L_API_NAME                  CONSTANT VARCHAR2(30)  := 'Update_Dm_Binvalues';
	L_API_VERSION_NUMBER        CONSTANT NUMBER        := 1.0;

	-- Local Variables
	l_object_version_number     NUMBER;
	l_BIN_VALUE_ID              NUMBER;
	l_ref_dm_binvalues_rec      c_get_Dm_Binvalues%ROWTYPE ;
	l_tar_dm_binvalues_rec      AMS_Dm_Binvalues_PVT.dm_binvalues_rec_type := P_dm_binvalues_rec;
	l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Dm_Binvalues_PVT;

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

      AMS_UTILITY_PVT.debug_message('Private API: - Going to Complete Record');
      END IF;


      -- Complete missing entries in the record before updating
      Complete_dm_binvalues_Rec(
         p_dm_binvalues_rec  => p_dm_binvalues_rec,
         x_complete_rec      => l_tar_dm_binvalues_rec
      );

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;


      -- get the reference bin value, which contains
      -- data before the update operation.
      OPEN c_get_Dm_Binvalues( l_tar_dm_binvalues_rec.bin_value_id);
      FETCH c_get_Dm_Binvalues INTO l_ref_dm_binvalues_rec  ;

       If ( c_get_Dm_Binvalues%NOTFOUND) THEN
           AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                         p_token_name   => 'INFO',
                                         p_token_value  => 'Dm_Binvalues') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Dm_Binvalues;


      If (l_tar_dm_binvalues_rec.object_version_number is NULL or
          l_tar_dm_binvalues_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                        p_token_name   => 'COLUMN',
                                        p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_dm_binvalues_rec.object_version_number <> l_ref_dm_binvalues_rec.object_version_number) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                        p_token_name   => 'INFO',
                                        p_token_value  => 'Dm_Binvalues') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Calling Validate_Dm_Binvalues');
          END IF;

          IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_UTILITY_PVT.debug_message('bin_value_id = ' || l_tar_dm_binvalues_rec.bin_value_id);

          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('object_version_number = ' || l_tar_dm_binvalues_rec.object_version_number);
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('source_field_id = ' || l_tar_dm_binvalues_rec.source_field_id);
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('bucket = ' || l_tar_dm_binvalues_rec.bucket);
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('bin_value = ' || l_tar_dm_binvalues_rec.bin_value);
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('start_value = ' || l_tar_dm_binvalues_rec.start_value);
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('end_value = ' || l_tar_dm_binvalues_rec.end_value);
          END IF;

          -- Invoke validation procedures
          Validate_dm_binvalues(
            p_api_version_number	=> 1.0,
            p_init_msg_list		=> FND_API.G_FALSE,
            p_validation_level	=> p_validation_level,
            p_validation_mode		=> JTF_PLSQL_API.g_update,
            p_dm_binvalues_rec	=> l_tar_dm_binvalues_rec,
            x_return_status		=> x_return_status,
            x_msg_count			   => x_msg_count,
            x_msg_data			   => x_msg_data);
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Private API: AFTER Calling Validate_Dm_Binvalues');

      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Error while validating ---------');
          END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_DM_BIN_VALUES_PKG.Update_Row)
      AMS_DM_BIN_VALUES_PKG.Update_Row(
          p_bin_value_id		      => l_tar_dm_binvalues_rec.bin_value_id,
          p_last_update_date		   => SYSDATE,
          p_last_updated_by		   => G_USER_ID,
          p_creation_date		      => SYSDATE,
          p_created_by			      => G_USER_ID,
          p_last_update_login		   => G_LOGIN_ID,
          p_object_version_number	=> l_tar_dm_binvalues_rec.object_version_number,
          p_source_field_id		   => l_tar_dm_binvalues_rec.source_field_id,
          p_bucket			         => l_tar_dm_binvalues_rec.bucket,
          p_bin_value			      => l_tar_dm_binvalues_rec.bin_value,
          p_start_value			      => l_tar_dm_binvalues_rec.start_value,
          p_end_value			      => l_tar_dm_binvalues_rec.end_value);

      -- Set the resulting object version number
      x_object_version_number := l_tar_dm_binvalues_rec.object_version_number + 1;

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
      ROLLBACK TO UPDATE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Dm_Binvalues_PVT;
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

End Update_Dm_Binvalues;

PROCEDURE Delete_Dm_Binvalues_For_Field(
   p_datasource_field_id        IN  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Dm_Binvalues_For_Field';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_Dm_Binvalues_For_Field;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   --
   -- Api body
   --
   DELETE FROM AMS_DM_BIN_VALUES
    WHERE source_field_id = p_datasource_field_id;

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

End Delete_Dm_Binvalues_For_Field;



PROCEDURE Delete_Dm_Binvalues(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_bin_value_id               IN   NUMBER,
   p_object_version_number      IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Dm_Binvalues';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Dm_Binvalues_PVT;

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

   -- Invoke table handler(AMS_DM_BIN_VALUES_PKG.Delete_Row)
   AMS_DM_BIN_VALUES_PKG.Delete_Row(
       p_BIN_VALUE_ID  => p_BIN_VALUE_ID);
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
      ROLLBACK TO DELETE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO DELETE_Dm_Binvalues_PVT;
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
End Delete_Dm_Binvalues;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Dm_Binvalues(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,

   p_bin_value_id               IN   NUMBER,
   p_object_version             IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30)  := 'Lock_Dm_Binvalues';
   L_API_VERSION_NUMBER        CONSTANT NUMBER        := 1.0;
   L_FULL_NAME                 CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
   l_BIN_VALUE_ID              NUMBER;

   CURSOR c_Dm_Binvalues IS
      SELECT BIN_VALUE_ID
        FROM AMS_DM_BIN_VALUES
       WHERE BIN_VALUE_ID = p_BIN_VALUE_ID
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
   OPEN c_Dm_Binvalues;

   FETCH c_Dm_Binvalues INTO l_BIN_VALUE_ID;

   IF (c_Dm_Binvalues%NOTFOUND) THEN
      CLOSE c_Dm_Binvalues;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_Dm_Binvalues;

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
      ROLLBACK TO LOCK_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Dm_Binvalues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO LOCK_Dm_Binvalues_PVT;
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
End Lock_Dm_Binvalues;


PROCEDURE check_uk_items(
   p_dm_binvalues_rec               IN   dm_binvalues_rec_type,
   p_validation_mode                IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status                  OUT NOCOPY VARCHAR2)
IS

   l_valid_flag  VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'AMS_DM_BIN_VALUES',
      'BIN_VALUE_ID = ''' || p_dm_binvalues_rec.BIN_VALUE_ID ||''''
      );
   ELSE
      l_valid_flag := AMS_Utility_PVT.check_uniqueness(
      'AMS_DM_BIN_VALUES',
      'BIN_VALUE_ID = ''' || p_dm_binvalues_rec.BIN_VALUE_ID ||
      ''' AND BIN_VALUE_ID <> ' || p_dm_binvalues_rec.BIN_VALUE_ID
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      AMS_Utility_PVT.Error_Message('AMS_API_DUPLICATE_ID', 'ID_FIELD','BIN_VALUE_ID');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_uk_items;

PROCEDURE check_req_items(
   p_dm_binvalues_rec               IN  dm_binvalues_rec_type,
   p_validation_mode                IN VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status	               OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message('Private API:check_req_items for CREATE');
      END IF;

      IF p_dm_binvalues_rec.bin_value_id = FND_API.g_miss_num OR p_dm_binvalues_rec.bin_value_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','BIN_VALUE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.source_field_id = FND_API.g_miss_num OR p_dm_binvalues_rec.source_field_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.bucket = FND_API.g_miss_num OR p_dm_binvalues_rec.bucket IS NULL THEN
         --changed rosharma 07-may-2003 Bug # 2943269
         --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','BUCKET');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_BUCKET');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message('Private API:check_req_items for UPDATE');
      END IF;

      IF p_dm_binvalues_rec.bin_value_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','BIN_VALUE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.last_update_date IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATE_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.last_updated_by IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.creation_date IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATION_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.created_by IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.source_field_id IS NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_dm_binvalues_rec.bucket IS NULL THEN
         --changed rosharma 07-may-2003 Bug # 2943269
         --AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD','BUCKET');
         AMS_Utility_PVT.Error_Message('AMS_DM_NO_BUCKET');
         --end change rosharma 07-may-2003 Bug # 2943269
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_req_items;

PROCEDURE check_FK_items(
   p_dm_binvalues_rec IN dm_binvalues_rec_type,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --------------------source_field_id---------------------------
   IF p_dm_binvalues_rec.source_field_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_src_fields',
            'list_source_field_id',
            p_dm_binvalues_rec.source_field_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.error_message ('AMS_API_INVALID_FK', 'COLUMN_NAME', 'SOURCE_FIELD_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_FK_items;

PROCEDURE check_Lookup_items(
    p_dm_binvalues_rec IN dm_binvalues_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- No lookups to validate

END check_Lookup_items;

PROCEDURE Check_dm_binvalues_Items (
    P_dm_binvalues_rec     IN    dm_binvalues_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_uk_items(
      p_dm_binvalues_rec => p_dm_binvalues_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   check_req_items(
      p_dm_binvalues_rec => p_dm_binvalues_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls
   check_FK_items(
      p_dm_binvalues_rec => p_dm_binvalues_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups
   check_Lookup_items(
      p_dm_binvalues_rec => p_dm_binvalues_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_dm_binvalues_Items;



PROCEDURE Complete_dm_binvalues_Rec (
   p_dm_binvalues_rec IN dm_binvalues_rec_type,
   x_complete_rec OUT NOCOPY dm_binvalues_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_dm_bin_values
      WHERE bin_value_id = p_dm_binvalues_rec.bin_value_id;
   l_dm_binvalues_rec c_complete%ROWTYPE;
BEGIN

   x_complete_rec := p_dm_binvalues_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_dm_binvalues_rec;
   CLOSE c_complete;

   -- bin_value_id
   IF p_dm_binvalues_rec.bin_value_id = FND_API.g_miss_num THEN
      x_complete_rec.bin_value_id := l_dm_binvalues_rec.bin_value_id;
   END IF;

   -- last_update_date
   IF p_dm_binvalues_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_dm_binvalues_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_dm_binvalues_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_dm_binvalues_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_dm_binvalues_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_dm_binvalues_rec.creation_date;
   END IF;

   -- created_by
   IF p_dm_binvalues_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_dm_binvalues_rec.created_by;
   END IF;

   -- last_update_login
   IF p_dm_binvalues_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_dm_binvalues_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_dm_binvalues_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_dm_binvalues_rec.object_version_number;
   END IF;

   -- source_field_id
   IF p_dm_binvalues_rec.source_field_id = FND_API.g_miss_num THEN
      x_complete_rec.source_field_id := l_dm_binvalues_rec.source_field_id;
   END IF;

   -- bucket
   IF p_dm_binvalues_rec.bucket = FND_API.g_miss_num THEN
      x_complete_rec.bucket := l_dm_binvalues_rec.bucket;
   END IF;

   -- bin_value
   IF p_dm_binvalues_rec.bin_value = FND_API.g_miss_char THEN
      x_complete_rec.bin_value := l_dm_binvalues_rec.bin_value;
   END IF;

   -- start_value
   IF p_dm_binvalues_rec.start_value = FND_API.g_miss_num THEN
      x_complete_rec.start_value := l_dm_binvalues_rec.start_value;
   END IF;

   -- end_value
   IF p_dm_binvalues_rec.end_value = FND_API.g_miss_num THEN
      x_complete_rec.end_value := l_dm_binvalues_rec.end_value;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_dm_binvalues_Rec;

PROCEDURE Validate_dm_binvalues(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER	   := FND_API.G_VALID_LEVEL_FULL,
    p_dm_binvalues_rec           IN   dm_binvalues_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Dm_Binvalues';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_dm_binvalues_rec	    AMS_Dm_Binvalues_PVT.dm_binvalues_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Dm_Binvalues_;

       -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
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
              Check_dm_binvalues_Items(
                 p_dm_binvalues_rec        => p_dm_binvalues_rec,
                 p_validation_mode	   => p_validation_mode,
                 x_return_status	   => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_dm_binvalues_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_dm_binvalues_rec       => p_dm_binvalues_rec);

         IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_UTILITY_PVT.debug_message('After Validate_dm_binvalues_Rec   return status = ' || x_return_status);

         END IF;

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('After Validate_dm_binvalues_Rec   return status = ' || x_return_status);

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' return status = ' || x_return_status);
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
     ROLLBACK TO VALIDATE_Dm_Binvalues_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Dm_Binvalues_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Dm_Binvalues_;
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
End Validate_Dm_Binvalues;


PROCEDURE Validate_dm_binvalues_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_dm_binvalues_rec           IN   dm_binvalues_rec_type
    )
IS
BEGIN
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_binvalues_rec start');
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

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_binvalues_rec end  status = ' || x_return_status);
   END IF;

END Validate_dm_binvalues_Rec;

END AMS_Dm_Binvalues_PVT;

/
