--------------------------------------------------------
--  DDL for Package Body AMS_CNT_POINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CNT_POINT_PVT" as
/* $Header: amsvconb.pls 120.0 2005/05/31 22:01:31 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Cnt_Point_PVT
-- Purpose
--
-- History
--     30-aug-2001    soagrawa    Modified names of all error messages, whose length was
--                                > 30 chars. Added those messages to seed.
--     31-oct-2001    soagrawa    Modified check_conact_point_fk_rec for bug# 2074740.
--     27-dec-2001    aranka      Modified check_conact_point_fk_rec, contact_point_value size from 30 to 256 for bug# 2163252
--     21-jan-2003    soagrawa    Fixed validation of inbounud outbound script - bug# 2757856
--     20-may-2005    musman      Added contact_point_value_id column for webadi collaboration script usage

-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Cnt_Point_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvconb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_cnt_point_rec               IN   cnt_point_rec_type  := g_miss_cnt_point_rec,
    x_contact_point_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Cnt_Point';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CONTACT_POINT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_ACT_CONTACT_POINTS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_ACT_CONTACT_POINTS
                    WHERE CONTACT_POINT_ID = l_id);

BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Inside Procedure Create_cnt_point');
     END IF;
        -- Standard Start of API savepoint
      SAVEPOINT CREATE_Cnt_Point_PVT;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Save point : CREATE_Cnt_Point_PVT created');
        END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Save point : CREATE_Cnt_Point_PVT created');
         END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( L_API_VERSION_NUMBER,
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_cnt_point_rec.CONTACT_POINT_ID IS NULL OR p_cnt_point_rec.CONTACT_POINT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_CONTACT_POINT_ID;
         CLOSE c_id;


         OPEN c_id_exists(l_CONTACT_POINT_ID);
         FETCH c_id_exists INTO l_dummy;

         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Retreived pk');

      END IF;
      -- =========================================================================
      -- Validate Environment
      -- =========================================================================


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
         THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Cnt_Point');
          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Cnt_Point');
          END IF;
          -- Invoke validation procedures

          Validate_cnt_point(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_create,
            p_cnt_point_rec    =>  p_cnt_point_rec,
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

      -- Invoke table handler(AMS_ACT_CONTACT_POINTS_PKG.Insert_Row)
      AMS_ACT_CONTACT_POINTS_PKG.Insert_Row(
          px_contact_point_id       => l_contact_point_id,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => FND_GLOBAL.user_id,
          p_creation_date           => SYSDATE,
          p_created_by              => FND_GLOBAL.user_id,
          p_last_update_login       => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_arc_contact_used_by     => p_cnt_point_rec.arc_contact_used_by,
          p_act_contact_used_by_id  => p_cnt_point_rec.act_contact_used_by_id,
          p_contact_point_type      => p_cnt_point_rec.contact_point_type,
          p_contact_point_value     => p_cnt_point_rec.contact_point_value,
          p_city                    => p_cnt_point_rec.city,
          p_country                 => p_cnt_point_rec.country,
          p_zipcode                 => p_cnt_point_rec.zipcode,
          p_attribute_category      => p_cnt_point_rec.attribute_category,
          p_attribute1              => p_cnt_point_rec.attribute1,
          p_attribute2              => p_cnt_point_rec.attribute2,
          p_attribute3              => p_cnt_point_rec.attribute3,
          p_attribute4              => p_cnt_point_rec.attribute4,
          p_attribute5              => p_cnt_point_rec.attribute5,
          p_attribute6              => p_cnt_point_rec.attribute6,
          p_attribute7              => p_cnt_point_rec.attribute7,
          p_attribute8              => p_cnt_point_rec.attribute8,
          p_attribute9              => p_cnt_point_rec.attribute9,
          p_attribute10             => p_cnt_point_rec.attribute10,
          p_attribute11             => p_cnt_point_rec.attribute11,
          p_attribute12             => p_cnt_point_rec.attribute12,
          p_attribute13             => p_cnt_point_rec.attribute13,
          p_attribute14             => p_cnt_point_rec.attribute14,
          p_attribute15             => p_cnt_point_rec.attribute15,
         p_contact_point_value_id => p_cnt_point_rec.contact_point_value_id
          );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSE
	x_contact_point_id := l_contact_point_id;
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
     ROLLBACK TO CREATE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Cnt_Point_PVT;
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
End Create_Cnt_Point;


PROCEDURE Update_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,


    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_cnt_point_rec               IN    cnt_point_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_cnt_point(contact_point_id NUMBER) IS
    SELECT *
    FROM  AMS_ACT_CONTACT_POINTS
    WHERE contact_point_id = p_cnt_point_rec.contact_point_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Cnt_Point';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_CONTACT_POINT_ID    NUMBER;
l_ref_cnt_point_rec  c_get_Cnt_Point%ROWTYPE ;
l_tar_cnt_point_rec  AMS_Cnt_Point_PVT.cnt_point_rec_type := P_cnt_point_rec;
l_rowid  ROWID;

 BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Inside Update_cnt_point');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Cnt_Point_PVT;

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


      OPEN c_get_Cnt_Point( l_tar_cnt_point_rec.contact_point_id);

      FETCH c_get_Cnt_Point INTO l_ref_cnt_point_rec  ;

       If ( c_get_Cnt_Point%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Cnt_Point') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Cnt_Point;



      If (l_tar_cnt_point_rec.object_version_number is NULL or
          l_tar_cnt_point_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_cnt_point_rec.object_version_number <> l_ref_cnt_point_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Cnt_Point') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Cnt_Point  '|| x_return_status);
          END IF;

          -- Invoke validation procedures
          Validate_cnt_point(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_update,
            p_cnt_point_rec    =>  p_cnt_point_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_ACT_CONTACT_POINTS_PKG.Update_Row)
      AMS_ACT_CONTACT_POINTS_PKG.Update_Row(
          p_contact_point_id  => p_cnt_point_rec.contact_point_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.user_id,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_cnt_point_rec.object_version_number,
          p_arc_contact_used_by  => p_cnt_point_rec.arc_contact_used_by,
          p_act_contact_used_by_id  => p_cnt_point_rec.act_contact_used_by_id,
          p_contact_point_type  => p_cnt_point_rec.contact_point_type,
          p_contact_point_value  => p_cnt_point_rec.contact_point_value,
          p_city  => p_cnt_point_rec.city,
          p_country  => p_cnt_point_rec.country,
          p_zipcode  => p_cnt_point_rec.zipcode,
          p_attribute_category  => p_cnt_point_rec.attribute_category,
          p_attribute1  => p_cnt_point_rec.attribute1,
          p_attribute2  => p_cnt_point_rec.attribute2,
          p_attribute3  => p_cnt_point_rec.attribute3,
          p_attribute4  => p_cnt_point_rec.attribute4,
          p_attribute5  => p_cnt_point_rec.attribute5,
          p_attribute6  => p_cnt_point_rec.attribute6,
          p_attribute7  => p_cnt_point_rec.attribute7,
          p_attribute8  => p_cnt_point_rec.attribute8,
          p_attribute9  => p_cnt_point_rec.attribute9,
          p_attribute10  => p_cnt_point_rec.attribute10,
          p_attribute11  => p_cnt_point_rec.attribute11,
          p_attribute12  => p_cnt_point_rec.attribute12,
          p_attribute13  => p_cnt_point_rec.attribute13,
          p_attribute14  => p_cnt_point_rec.attribute14,
          p_attribute15  => p_cnt_point_rec.attribute15
         ,p_contact_point_value_id => p_cnt_point_rec.contact_point_value_id
          );
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
     ROLLBACK TO UPDATE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Cnt_Point_PVT;
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
End Update_Cnt_Point;


PROCEDURE Delete_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_contact_point_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS

 CURSOR c_Cnt_Point IS
   SELECT CONTACT_POINT_ID
   FROM AMS_ACT_CONTACT_POINTS
   WHERE CONTACT_POINT_ID = p_CONTACT_POINT_ID
   AND object_version_number = p_object_version_number ;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Cnt_Point';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_contact_point_id          NUMBER;

 BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Inside Delete_cnt_point');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Cnt_Point_PVT;

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

       OPEN c_Cnt_Point;

      FETCH c_Cnt_Point INTO l_CONTACT_POINT_ID ;

      IF (c_Cnt_Point%NOTFOUND) THEN
      CLOSE c_Cnt_Point;
      AMS_Utility_PVT.Error_Message(p_message_name =>  'AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
     END IF;

     CLOSE c_Cnt_Point;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_ACT_CONTACT_POINTS_PKG.Delete_Row)
      AMS_ACT_CONTACT_POINTS_PKG.Delete_Row(
          p_CONTACT_POINT_ID  => p_CONTACT_POINT_ID);
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
     ROLLBACK TO DELETE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Cnt_Point_PVT;
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
End Delete_Cnt_Point;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Cnt_Point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_contact_point_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Cnt_Point';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_CONTACT_POINT_ID                  NUMBER;

CURSOR c_Cnt_Point IS
   SELECT CONTACT_POINT_ID
   FROM AMS_ACT_CONTACT_POINTS
   WHERE CONTACT_POINT_ID = p_CONTACT_POINT_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Inside LockCnt_point');

      END IF;
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
  OPEN c_Cnt_Point;

  FETCH c_Cnt_Point INTO l_CONTACT_POINT_ID;

  IF (c_Cnt_Point%NOTFOUND) THEN
    CLOSE c_Cnt_Point;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Cnt_Point;

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
     ROLLBACK TO LOCK_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Cnt_Point_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Cnt_Point_PVT;
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
End Lock_Cnt_Point;


PROCEDURE check_cnt_point_uk_items(
    p_cnt_point_rec               IN   cnt_point_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Inside check_uk_items');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(p_cnt_point_rec.arc_contact_used_by);
      END IF;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_CONTACT_POINTS',
         'CONTACT_POINT_ID = ' || p_cnt_point_rec.CONTACT_POINT_ID
         );
        IF l_valid_flag = FND_API.g_false THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_POINT_ID_DUPLICATE');
          x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
         -- code added by me
         /*l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                                                         'AMS_ACT_CONTACT_POINTS'
                                                         , '''ARC_CONTACT_USED_BY = ''' || p_cnt_point_rec.ARC_CONTACT_USED_BY  ||
                                                          ''' AND ACT_CONTACT_USED_BY_ID  = ' || p_cnt_point_rec.ACT_CONTACT_USED_BY_ID ||
                                                          ''' AND CONTACT_POINT_TYPE = ''' || p_cnt_point_rec.CONTACT_POINT_TYPE ||
                                                          ''' AND CONTACT_POINT_VALUE  = ''' || p_cnt_point_rec.CONTACT_POINT_VALUE
                                                          ''' AND CONTACT_POINT_ID  <> ''' || p_cnt_point_rec.CONTACT_POINT_TYPE
                                                         );*/


         -- end code added by me


      /*ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_CONTACT_POINTS',
         'CONTACT_POINT_ID =  ' || p_cnt_point_rec.CONTACT_POINT_ID
         );


        -- ||
         --''' AND CONTACT_POINT_ID <> ' || p_cnt_point_rec.CONTACT_POINT_ID
         --);
          IF l_valid_flag = FND_API.g_false THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_POINT_ID_DUPLICATE');
          x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;*/


      END IF;
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message(p_cnt_point_rec.arc_contact_used_by);
       END IF;

END check_cnt_point_uk_items;


/**
  --  PURPOSE
            Checks whether the required fields are not null
  -- HISTORY
            rssharma
            01/29/2001  Removed check from all the who fields
            and object version Number as these values are
            supplied by Table API in case they are missing
  */


PROCEDURE check_cnt_point_req_items(
    p_cnt_point_rec               IN  cnt_point_rec_type,
    p_validation_mode             IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status            OUT NOCOPY VARCHAR2
)
IS
BEGIN

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('Inside check_cnt_point_req_items');

  END IF;

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

   /*
      IF p_cnt_point_rec.contact_point_id = FND_API.g_miss_num OR p_cnt_point_rec.contact_point_id IS NULL THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_ID');
         x_return_status := FND_API.g_ret_sts_error;

         RETURN;
      END IF;
   */

      /*IF p_cnt_point_rec.last_update_date = FND_API.g_miss_date OR p_cnt_point_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.last_updated_by = FND_API.g_miss_num OR p_cnt_point_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.creation_date = FND_API.g_miss_date OR p_cnt_point_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.created_by = FND_API.g_miss_num OR p_cnt_point_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.object_version_number = FND_API.g_miss_num OR p_cnt_point_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;  */


      IF p_cnt_point_rec.arc_contact_used_by = FND_API.g_miss_char OR p_cnt_point_rec.arc_contact_used_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_USED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.act_contact_used_by_id = FND_API.g_miss_num OR p_cnt_point_rec.act_contact_used_by_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_USED_BY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.contact_point_type = FND_API.g_miss_char OR p_cnt_point_rec.contact_point_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.contact_point_value = FND_API.g_miss_char OR p_cnt_point_rec.contact_point_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_cnt_point_rec.contact_point_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      /*IF p_cnt_point_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_cnt_point_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;  */


      IF p_cnt_point_rec.arc_contact_used_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_USED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.act_contact_used_by_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_USED_BY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.contact_point_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_cnt_point_rec.contact_point_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_NO_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_UTILITY_PVT.debug_message(' Exiting check_cnt_point_req_items');

END IF;

END check_cnt_point_req_items;

PROCEDURE check_country_exists(
    p_cnt_point_rec   IN  cnt_point_rec_type
    , x_return_status  OUT NOCOPY VARCHAR2
    )
    IS
    l_table_name VARCHAR2(30):= 'jtf_loc_hierarchies_vl';
    l_pk_name VARCHAR2(30) := 'location_hierarchy_id';
    l_pk_value NUMBER := p_cnt_point_rec.country;
    l_pk_data_type NUMBER := AMS_Utility_PVT.g_number;


    BEGIN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Inside   check_country_exists');
     END IF;
      -- initialise the return status to success
      x_return_status := FND_API.g_ret_sts_success ;

      -- if country is null or missing then perform the check
      IF p_cnt_point_rec.country <> FND_API.g_miss_num
       AND p_cnt_point_rec.country IS NOT NULL  THEN
      IF
       AMS_Utility_PVT.check_fk_exists(
                                       p_table_name  => l_table_name
                                       , p_pk_name   => l_pk_name
                                       , p_pk_value  => l_pk_value
                                       , p_pk_data_type => l_pk_data_type
                                       ,  p_additional_where_clause => NULL
                                       ) = FND_API.g_false
         THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CNT_POINT_BAD_COUNTRY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN ;
       END IF;
       END IF;

    END check_country_exists;

PROCEDURE check_cnt_point_FK_items(
    p_cnt_point_rec IN cnt_point_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
--
-- Initialize the OUT parameter
--
  x_return_status := FND_API.g_ret_sts_success ;
-- code added by me
-- Check arc_contact_used_by
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Inside check_cnt_point_fk_items');
   END IF;

   IF p_cnt_point_rec.arc_contact_used_by <> FND_API.G_MISS_CHAR THEN
        IF p_cnt_point_rec.arc_contact_used_by <> 'CAMP' AND
           p_cnt_point_rec.arc_contact_used_by <> 'CSCH' AND
                 p_cnt_point_rec.arc_contact_used_by <> 'EVEH' AND
                 p_cnt_point_rec.arc_contact_used_by <> 'EVEO'
        THEN
      -- invalid item
           AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_INVALID_USED_BY'); -- TO CHECK THE ERROR MESSAGE TO BE RAISED*/
         /*IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN -- MMSG
--             IF (AMS_DEBUG_HIGH_ON) THEN                          AMS_UTILITY_PVT.debug_message('Foreign Key Does not Exist');             END IF;
            FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_CREATED_FOR');
                FND_MSG_PUB.Add;
        END IF;*/


         x_return_status := FND_API.G_RET_STS_ERROR;
        -- If any errors happen abort API/Procedure.
        RETURN;
      END IF;
   END IF;

   IF p_cnt_point_rec.country <> FND_API.G_MISS_NUM AND  p_cnt_point_rec.country IS NOT NULL  THEN
   check_country_exists(
                        p_cnt_point_rec  => p_cnt_point_rec
                        , x_return_status => x_return_status
                        );

      IF x_return_status <>  FND_API.g_ret_sts_success THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_CONTACT_INVALID_COUNTRY');
      RETURN;
      END IF;
    END IF;


   -- end code added by me

   -- Enter custom code here



END check_cnt_point_FK_items;

PROCEDURE check_cnt_point_Lookup_items(
    p_cnt_point_rec IN cnt_point_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Inside Ckeck lookups');
   END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message(p_cnt_point_rec.arc_contact_used_by);
    END IF;
   x_return_status := FND_API.g_ret_sts_success;
-- code added by me
 IF p_cnt_point_rec.CONTACT_POINT_TYPE <> FND_API.G_MISS_CHAR
  THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message(' LookUp type   lookup code  = '''|| p_cnt_point_rec.contact_point_value);
       END IF;
   IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
             ,p_lookup_type         => 'AMS_CONTACT_POINT_TYPE'
        ,p_lookup_code         => p_cnt_point_rec.contact_point_type
        ) = FND_API.G_FALSE then

      -- invalid item
      /*   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
--            IF (AMS_DEBUG_HIGH_ON) THEN                        AMS_UTILITY_PVT.debug_message('Triggering Type is invalid');            END IF;

          FND_MSG_PUB.Add;
        END IF;*/
        AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_INVALID_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;
  END IF;
  -- end code added by me
   -- Enter custom code here
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message(p_cnt_point_rec.arc_contact_used_by);
       END IF;
END check_cnt_point_Lookup_items;

PROCEDURE Check_cnt_point_Items (
    P_cnt_point_rec     IN    cnt_point_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Inside Check_cnt_point_items');
   END IF;
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_UTILITY_PVT.debug_message('Before Calling uk Items');
  END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Validation mode is ' || p_validation_mode);
   END IF;
   check_cnt_point_uk_items(
      p_cnt_point_rec => p_cnt_point_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('After Calling uk Items '||x_return_status);
   END IF;

   -- Check Items Required/NOT NULL API calls
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Before Calling req Items');
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Validation mode is ' || p_validation_mode);
   END IF;
   check_cnt_point_req_items(
      p_cnt_point_rec => p_cnt_point_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('After Calling req Items'|| x_return_status);
   END IF;

/* Commented by nrengasw 05/07/2001. No validation required on contact point used by.
   Country is a free format column. Do not validate against geographies

   -- Check Items Foreign Keys API calls
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('Before Calling fk Items');
    END IF;
   check_cnt_point_FK_items(
      p_cnt_point_rec => p_cnt_point_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('After Calling fk Items' || x_return_status);
   END IF;

End of comments by nrengasw
*/
   -- Check Items Lookups
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Before Calling Lk Items');
   END IF;
   check_cnt_point_Lookup_items(
      p_cnt_point_rec => p_cnt_point_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('After Calling lk Items'|| x_return_status);
   END IF;
END Check_cnt_point_Items;


PROCEDURE Complete_cnt_point_Rec (
    P_cnt_point_rec     IN    cnt_point_rec_type,
     x_complete_rec        OUT NOCOPY    cnt_point_rec_type
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Complete_cnt_point_Rec;


PROCEDURE Validate_cnt_point(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,
    p_cnt_point_rec              IN   cnt_point_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Cnt_Point';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_cnt_point_rec  AMS_Cnt_Point_PVT.cnt_point_rec_type;

 BEGIN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Inside Validate_cnt_points');
       END IF;

      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Cnt_Point_;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Validate Api is compatible');

      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

     IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Calling Check_cnt_point');
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Validation mode is ' || p_validation_mode);
         END IF;
              Check_cnt_point_Items(
                 p_cnt_point_rec        => p_cnt_point_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

           IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_UTILITY_PVT.debug_message('DOne calling check_cnt_point '||p_cnt_point_rec.arc_contact_used_by|| x_return_status);

           END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
    END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Callin Complete rec');

      END IF;
      Complete_cnt_point_Rec(
         p_cnt_point_rec        => p_cnt_point_rec,
         x_complete_rec        => l_cnt_point_rec
      );

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('DOne calling Complete_rec '|| x_return_status);

      END IF;



      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Calling Validate rec'||p_cnt_point_rec.arc_contact_used_by|| x_return_status);
         END IF;
         Validate_cnt_point_Rec(
           p_api_version_number     => 1.0,
           p_validation_mode        => p_validation_mode,
           p_init_msg_list          => FND_API.G_FALSE,

           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_cnt_point_rec           =>    p_cnt_point_rec);
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('DOne calling Validate rec ' ||p_cnt_point_rec.arc_contact_used_by|| x_return_status);
          END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start '||x_return_status);
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end  ' || x_return_status);
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Cnt_Point_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Cnt_Point_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Cnt_Point_;
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
End Validate_Cnt_Point;

-- procedure added by me
PROCEDURE check_cnt_point_uk_rec(
    p_cnt_point_rec            IN cnt_point_rec_type,
    p_validation_mode          IN VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
    )
    IS
    l_contact_point_id  NUMBER ;
    CURSOR c_check_cnt_point_uk_rec_cr IS
    SELECT contact_point_id
    FROM ams_act_contact_points
    WHERE arc_contact_used_by = p_cnt_point_rec.arc_contact_used_by
    AND   act_contact_used_by_id = p_cnt_point_rec.act_contact_used_by_id
    AND   contact_point_type = p_cnt_point_rec.contact_point_type
    AND   contact_point_value = p_cnt_point_rec.contact_point_value
    AND   contact_point_value_id  = p_cnt_point_rec.contact_point_value_id;

    CURSOR c_check_cnt_point_uk_rec_up IS
    SELECT contact_point_id
    FROM ams_act_contact_points
    WHERE arc_contact_used_by = p_cnt_point_rec.arc_contact_used_by
    AND   act_contact_used_by_id = p_cnt_point_rec.act_contact_used_by_id
    AND   contact_point_type = p_cnt_point_rec.contact_point_type
    AND   contact_point_value = p_cnt_point_rec.contact_point_value
    AND contact_point_id <> p_cnt_point_rec.contact_point_id
    AND   contact_point_value_id  = p_cnt_point_rec.contact_point_value_id;

    BEGIN

     -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = JTF_PLSQL_API.g_create)
      THEN
           OPEN c_check_cnt_point_uk_rec_cr ;
           FETCH c_check_cnt_point_uk_rec_cr INTO l_contact_point_id;
           IF  c_check_cnt_point_uk_rec_cr%FOUND THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_POINT_ID_DUPLICATE');
             CLOSE c_check_cnt_point_uk_rec_cr ;
             RETURN;
           END IF;
           CLOSE c_check_cnt_point_uk_rec_cr ;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.g_update) THEN
       OPEN c_check_cnt_point_uk_rec_up ;
       FETCH c_check_cnt_point_uk_rec_up INTO l_contact_point_id;

      IF  c_check_cnt_point_uk_rec_up%FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTACT_POINT_ID_DUPLICATE');
        CLOSE c_check_cnt_point_uk_rec_up ;
        RETURN;
      END IF;
      CLOSE c_check_cnt_point_uk_rec_up ;
      END IF;

    END check_cnt_point_uk_rec;
-- end procedure added by me



-- procedure added by me
PROCEDURE check_cnt_point_fk_rec(
          p_cnt_point_rec  IN    cnt_point_rec_type
          ,x_return_status  OUT NOCOPY   VARCHAR2
                                 )
     IS

    l_arc_contact_used_by VARCHAR2(30) := p_cnt_point_rec.arc_contact_used_by ;
    l_table_name  VARCHAR2(30);
    l_pk_name  VARCHAR2(30)  ;
    l_pk_value NUMBER;
    l_pk_data_type NUMBER;
    l_additional_where_clause VARCHAR2(100);

    --added by soagrawa on 31-oct-2001; bug# 2074740
    l_contact_point_type  VARCHAR2(30) := p_cnt_point_rec.contact_point_type;

-- added by aranka on 27-dec-2001; bug# 2163252
--    l_contact_point_value VARCHAR2(30) := p_cnt_point_rec.contact_point_value;
    l_contact_point_value VARCHAR2(256) := p_cnt_point_rec.contact_point_value;
-- added by aranka on 27-dec-2001; bug# 2163252

    BEGIN
      /* check if the arc_contact_point_id is valid */
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Calling  Get_Qual_Table_Name_And_PK');
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(l_arc_contact_used_by || '     '|| p_cnt_point_rec.arc_contact_used_by );
      END IF;
         AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
           p_sys_qual                     => l_arc_contact_used_by,
           x_return_status                => x_return_status,
           x_table_name                   => l_table_name,
           x_pk_name                      => l_pk_name
        );

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Done Calling  Get_Qual_Table_Name_And_PK ' || l_arc_contact_used_by ||l_table_name|| l_pk_name || x_return_status);

      END IF;

      l_pk_value                 := p_cnt_point_rec.ACT_CONTACT_USED_BY_ID ; -- findout what to assign
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(' Calling  Check FK Exists  '|| l_table_name || l_pk_name || l_pk_value || l_pk_data_type || x_return_status );
      END IF;
      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            --,p_pk_data_type                 => l_pk_data_type
            --,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN

           AMS_Utility_PVT.Error_Message(p_message_name =>  'AMS_TRIG_INVALID_CREATED_FOR');


            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_UTILITY_PVT.debug_message(' Done Calling  Check FK Exists  '|| l_table_name || l_pk_name || l_pk_value || l_pk_data_type || x_return_status );
            END IF;
          RETURN;
      END IF;

      /* in case of inbound/outbound script - check if the name is valid
         added by soagrawa on 31-oct-2001 : bug# 2074740 */
      IF l_contact_point_type IS NOT NULL AND l_contact_point_value IS NOT null
      THEN
         IF l_contact_point_type = 'INBOUND_SCRIPT' OR l_contact_point_type = 'OUTBOUND_SCRIPT'
         THEN

            -- soagrawa 21-jan-2003 fixed bug# 2757856
            -- now comparing trimmed values
            IF AMS_Utility_PVT.Check_FK_Exists (
                   p_table_name                   => 'ies_deployed_scripts'
                  ,p_pk_name                      => 'ltrim(rtrim(dscript_name))'
                  ,p_pk_value                     => ltrim(rtrim(l_contact_point_value))
               ) = FND_API.G_FALSE
            THEN
                 IF l_contact_point_type = 'INBOUND_SCRIPT'
                 THEN
                    AMS_Utility_PVT.Error_Message(p_message_name =>  'AMS_CSCH_BAD_INBOUND_DSCRIPT');
                 ELSIF  l_contact_point_type = 'OUTBOUND_SCRIPT'
                 THEN
                    AMS_Utility_PVT.Error_Message(p_message_name =>  'AMS_CSCH_BAD_OUTBOUND_DSCRIPT');
                 END IF;

                 x_return_status := FND_API.G_RET_STS_ERROR;
                 IF (AMS_DEBUG_HIGH_ON) THEN

                 AMS_UTILITY_PVT.debug_message(' Done Calling  Check FK Exists  '|| l_table_name || l_pk_name || l_pk_value || l_pk_data_type || x_return_status );
                 END IF;
                 RETURN;
            END IF;

         END IF;
      END IF;



 END check_cnt_point_fk_rec;

    -- end procedure added by me

PROCEDURE Validate_cnt_point_rec(
    p_api_version_number         IN   NUMBER,
    p_validation_mode            IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cnt_point_rec               IN    cnt_point_rec_type
    )
IS
    l_arc_contact_used_by VARCHAR2(30) := p_cnt_point_rec.arc_contact_used_by ;
    l_table_name  VARCHAR2(30);
    l_pk_name  VARCHAR2(30)  ;
    l_pk_value NUMBER;
    l_pk_data_type NUMBER;
    l_additional_where_clause VARCHAR2(100);
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Inside Validate rec'||p_cnt_point_rec.arc_contact_used_by|| x_return_status);

      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;
     -- code added by rssharma
     /* check_cnt_point_FK_items(
      p_cnt_point_rec =>  p_cnt_point_rec,
      x_return_status => x_return_status
       );

       IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
         END IF;*/
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Calling check_cnt_point_fk_rec'||p_cnt_point_rec.arc_contact_used_by|| x_return_status);
         END IF;

          check_cnt_point_fk_rec(
           p_cnt_point_rec => p_cnt_point_rec
           ,x_return_status => x_return_status
           );
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message(' Done calling check_cnt_point_fk_rec '||p_cnt_point_rec.arc_contact_used_by|| x_return_status);
          END IF;
         IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
         END IF;


         IF (AMS_DEBUG_HIGH_ON) THEN





         AMS_UTILITY_PVT.debug_message('Calling check_cnt_point_uk_rec');


         END IF;
      check_cnt_point_uk_rec(
         p_cnt_point_rec       =>  p_cnt_point_rec,
         p_validation_mode     => p_validation_mode,
         x_return_status       =>  x_return_status);
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message(' Done calling check_cnt_point_uk_rec '||x_return_status);
         END IF;

          IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
         END IF;
      -- end code added by me




      -- Debug Message
END Validate_cnt_point_Rec;



END AMS_Cnt_Point_PVT;

/
