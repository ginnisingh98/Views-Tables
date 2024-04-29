--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_ASSOC_PVT" AS
/* $Header: amsvmtab.pls 115.8 2003/02/14 06:53:19 sunkumar noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Met_Tpl_Assoc_PVT
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   06/03/2002  dmvincen  Restrict duplicate associations.
--   30/01/2003  sunkumar  restricted updation of associations
--                         for seeded metrics apart from the enable flag.
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Met_Tpl_Assoc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmtab.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_met_tpl_assoc_Rec (
   p_ref_met_tpl_assoc_rec IN met_tpl_assoc_rec_type,
   x_tar_met_tpl_assoc_rec OUT NOCOPY met_tpl_assoc_rec_type);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Met_Tpl_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_met_tpl_assoc_rec          IN   met_tpl_assoc_rec_type  := g_miss_met_tpl_assoc_rec,
    x_METRIC_TPL_ASSOC_ID    OUT NOCOPY  NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Met_Tpl_Assoc';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_METRIC_TPL_ASSOC_ID       NUMBER;
   l_dummy                     NUMBER;

   CURSOR c_id IS
      SELECT AMS_MET_TPL_ASSOCS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_MET_TPL_ASSOCS
      WHERE METRIC_TPL_ASSOC_ID = l_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Met_Tpl_Assoc_PVT;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


  --sunkumar 30/01/2003
  --check if we are trying to create associations for a seeded metric template
  /*IF p_met_tpl_assoc_rec.metric_tpl_header_id  < 10000 THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;  */

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID IS NULL OR
      p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_METRIC_TPL_ASSOC_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_METRIC_TPL_ASSOC_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
      l_METRIC_TPL_ASSOC_ID := p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID;
   END IF;

   -- =========================================================================
   -- Validate Environment
   -- =========================================================================

   IF FND_GLOBAL.User_Id IS NULL
   THEN
       Ams_Utility_Pvt.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Private API: Validate_Met_Tpl_Assoc');
      END IF;

      -- Invoke validation procedures
      Validate_met_tpl_assoc(
        p_api_version_number => 1.0,
        p_init_msg_list      => FND_API.G_FALSE,
        p_validation_level   => p_validation_level,
        p_validation_mode    => JTF_PLSQL_API.g_create,
        p_met_tpl_assoc_rec  =>  p_met_tpl_assoc_rec,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_ASSOCS_PKG.Insert_Row)
   Ams_Met_Tpl_Assocs_Pkg.Insert_Row(
       p_metric_tpl_assoc_id  => l_METRIC_TPL_ASSOC_ID,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_creation_date  => SYSDATE,
       p_created_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       px_object_version_number  => l_object_version_number,
       p_metric_tpl_header_id  => p_met_tpl_assoc_rec.metric_tpl_header_id,
       p_association_type  => p_met_tpl_assoc_rec.association_type,
       p_used_by_id  => p_met_tpl_assoc_rec.used_by_id,
       p_used_by_code  => p_met_tpl_assoc_rec.used_by_code,
       p_enabled_flag  => p_met_tpl_assoc_rec.enabled_flag);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_METRIC_TPL_ASSOC_ID := l_METRIC_TPL_ASSOC_ID;
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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Met_Tpl_Assoc_PVT;
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
END Create_Met_Tpl_Assoc;


PROCEDURE Update_Met_Tpl_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_met_tpl_assoc_rec          IN   met_tpl_assoc_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

IS

   CURSOR c_get_met_tpl_assoc(l_metric_tpl_assoc_id NUMBER) IS
    SELECT METRIC_TPL_ASSOC_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           METRIC_TPL_HEADER_ID,
           ASSOCIATION_TYPE,
           USED_BY_ID,
           USED_BY_CODE,
           ENABLED_FLAG
    FROM  AMS_MET_TPL_ASSOCS
    WHERE metric_tpl_assoc_id = l_metric_tpl_assoc_id;
    -- Hint: Developer need to provide Where clause

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Met_Tpl_Assoc';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_METRIC_TPL_ASSOC_ID   NUMBER;
   l_ref_met_tpl_assoc_rec  met_tpl_assoc_rec_type ;
   l_tar_met_tpl_assoc_rec  met_tpl_assoc_rec_type := P_met_tpl_assoc_rec;
   l_rowid  ROWID;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Met_Tpl_Assoc_PVT;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
   END IF;



   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: - Open Cursor to Select');
   END IF;

   OPEN c_get_Met_Tpl_Assoc( l_tar_met_tpl_assoc_rec.metric_tpl_assoc_id);

   FETCH c_get_Met_Tpl_Assoc INTO l_ref_met_tpl_assoc_rec  ;

   IF ( c_get_Met_Tpl_Assoc%NOTFOUND) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
           p_token_name   => 'INFO',
           p_token_value  => 'Met_Tpl_Assoc') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE  c_get_Met_Tpl_Assoc;

   IF (l_tar_met_tpl_assoc_rec.object_version_number IS NULL OR
       l_tar_met_tpl_assoc_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
             p_token_name   => 'COLUMN',
             p_token_value  => 'Last_Update_Date') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Whether record has been changed by someone else
   IF (l_tar_met_tpl_assoc_rec.object_version_number <>
          l_ref_met_tpl_assoc_rec.object_version_number) THEN
       Ams_Utility_Pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
             p_token_name   => 'INFO',
             p_token_value  => 'Met_Tpl_Assoc') ;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Complete_met_tpl_assoc_Rec(l_ref_met_tpl_assoc_rec, l_tar_met_tpl_assoc_rec);


  --sunkumar 30/01/2003
  --check if we are trying to update associations for a seeded metric template
  IF p_met_tpl_assoc_rec.metric_tpl_header_id  < 10000 THEN
   IF (( (l_tar_met_tpl_assoc_rec.association_type <>l_ref_met_tpl_assoc_rec.association_type )
	  OR (l_tar_met_tpl_assoc_rec.used_by_id <>l_ref_met_tpl_assoc_rec.used_by_id)
	  OR (l_tar_met_tpl_assoc_rec.metric_tpl_header_id <>l_ref_met_tpl_assoc_rec.metric_tpl_header_id))
	  AND (l_tar_met_tpl_assoc_rec.enabled_flag=l_ref_met_tpl_assoc_rec.enabled_flag)) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED_MOD');
        END IF;


        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;


   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Private API: Validate_Met_Tpl_Assoc');
      END IF;

      -- Invoke validation procedures
      Validate_met_tpl_assoc(
        p_api_version_number     => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_validation_level => p_validation_level,
        p_validation_mode => JTF_PLSQL_API.g_update,
        p_met_tpl_assoc_rec  =>  p_met_tpl_assoc_rec,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_object_version_number :=
       l_ref_met_tpl_assoc_rec.object_version_number + 1;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: Calling update table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_ASSOCS_PKG.Update_Row)
   Ams_Met_Tpl_Assocs_Pkg.Update_Row(
       p_metric_tpl_assoc_id  => p_met_tpl_assoc_rec.metric_tpl_assoc_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       p_object_version_number  => x_object_version_number,
       p_metric_tpl_header_id  => p_met_tpl_assoc_rec.metric_tpl_header_id,
       p_association_type  => p_met_tpl_assoc_rec.association_type,
       p_used_by_id  => p_met_tpl_assoc_rec.used_by_id,
       p_used_by_code  => p_met_tpl_assoc_rec.used_by_code,
       p_enabled_flag  => p_met_tpl_assoc_rec.enabled_flag);

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Met_Tpl_Assoc_PVT;
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
END Update_Met_Tpl_Assoc;


PROCEDURE Delete_Met_Tpl_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_METRIC_TPL_ASSOC_ID    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Met_Tpl_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Met_Tpl_Assoc_PVT;

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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   --sunkumar 30/01/2003
  --check if we are trying to delete associations for a seeded metric template
  IF  p_METRIC_TPL_ASSOC_ID  < 10000 THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;



   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Api body
   --
   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'Private API: Calling delete table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_ASSOCS_PKG.Delete_Row)
   Ams_Met_Tpl_Assocs_Pkg.Delete_Row(
       p_METRIC_TPL_ASSOC_ID  => p_METRIC_TPL_ASSOC_ID);
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

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Met_Tpl_Assoc_PVT;
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
END Delete_Met_Tpl_Assoc;


-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Met_Tpl_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_METRIC_TPL_ASSOC_ID    IN  NUMBER,
    p_object_version             IN  NUMBER
    )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Met_Tpl_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_METRIC_TPL_ASSOC_ID   NUMBER;

CURSOR c_Met_Tpl_Assoc IS
   SELECT METRIC_TPL_ASSOC_ID
   FROM AMS_MET_TPL_ASSOCS
   WHERE METRIC_TPL_ASSOC_ID = p_METRIC_TPL_ASSOC_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
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



  Ams_Utility_Pvt.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Met_Tpl_Assoc;

  FETCH c_Met_Tpl_Assoc INTO l_METRIC_TPL_ASSOC_ID;

  IF (c_Met_Tpl_Assoc%NOTFOUND) THEN
    CLOSE c_Met_Tpl_Assoc;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Met_Tpl_Assoc;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  Ams_Utility_Pvt.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Met_Tpl_Assoc_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Met_Tpl_Assoc_PVT;
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
END Lock_Met_Tpl_Assoc;


PROCEDURE check_met_tpl_assoc_uk_items(
    p_met_tpl_assoc_rec               IN   met_tpl_assoc_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
    l_valid_flag  VARCHAR2(1);
   CURSOR c_dup_assoc (p_met_tpl_hdr_id NUMBER, p_assoc_type VARCHAR2,
            p_used_by_id NUMBER, p_used_by_code VARCHAR2) IS
      SELECT FND_API.G_FALSE
      FROM AMS_MET_TPL_ASSOCS
      WHERE METRIC_TPL_HEADER_ID = p_met_tpl_hdr_id
      AND ASSOCIATION_TYPE = p_assoc_type
      AND NVL(p_used_by_id,-1) = NVL(used_by_id,-1)
      AND NVL(p_used_by_code, '0') = NVL(used_by_code, '0');

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
      'AMS_MET_TPL_ASSOCS',
      'METRIC_TPL_ASSOC_ID = ' || p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID
      );
--    ELSE
--       l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
--       'AMS_MET_TPL_ASSOCS',
--       'METRIC_TPL_ASSOC_ID = ' || p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID ||
--       ' AND METRIC_TPL_ASSOC_ID <> ' || p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID
--       );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METRIC_TPL_ASSOC_ID_DUPLICATE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      OPEN c_dup_assoc(p_met_tpl_assoc_rec.METRIC_TPL_HEADER_ID,
         p_met_tpl_assoc_rec.ASSOCIATION_TYPE,
         p_met_tpl_assoc_rec.used_by_id,
         p_met_tpl_assoc_rec.used_by_code);
      FETCH c_dup_assoc INTO l_valid_flag;
      CLOSE c_dup_assoc;
      IF l_valid_flag = FND_API.g_false THEN
         Ams_Utility_Pvt.Error_Message(p_message_name =>
               'AMS_METRIC_TPL_ASSOC_VALUE_DUP');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_met_tpl_assoc_uk_items;

PROCEDURE check_met_tpl_assoc_req_items(
    p_met_tpl_assoc_rec               IN  met_tpl_assoc_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

--       IF p_met_tpl_assoc_rec.metric_tpl_assoc_id = FND_API.g_miss_num OR
--          p_met_tpl_assoc_rec.metric_tpl_assoc_id IS NULL THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
--          FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_ASSOC_ID');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.last_update_date = FND_API.g_miss_date OR p_met_tpl_assoc_rec.last_update_date IS NULL THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
--          FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATE_DATE');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.last_updated_by = FND_API.g_miss_num OR p_met_tpl_assoc_rec.last_updated_by IS NULL THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
--          FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATED_BY');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.creation_date = FND_API.g_miss_date OR p_met_tpl_assoc_rec.creation_date IS NULL THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
--          FND_MESSAGE.set_token('MISS_FIELD','CREATION_DATE');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.created_by = FND_API.g_miss_num OR p_met_tpl_assoc_rec.created_by IS NULL THEN
--          FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
--          FND_MESSAGE.set_token('MISS_FIELD','CREATED_BY');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
      IF p_met_tpl_assoc_rec.metric_tpl_header_id = FND_API.g_miss_num OR p_met_tpl_assoc_rec.metric_tpl_header_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_assoc_rec.association_type = FND_API.g_miss_char OR p_met_tpl_assoc_rec.association_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ASSOCIATION_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_assoc_rec.enabled_flag = FND_API.g_miss_char OR p_met_tpl_assoc_rec.enabled_flag IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE

      IF p_met_tpl_assoc_rec.metric_tpl_assoc_id IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTA_NO_MTA_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

--       IF p_met_tpl_assoc_rec.last_update_date IS NULL THEN
--  Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_met_tpl_assoc_NO_last_update_date');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.last_updated_by IS NULL THEN
--  Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_met_tpl_assoc_NO_last_updated_by');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.creation_date IS NULL THEN
--  Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_met_tpl_assoc_NO_creation_date');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;
--
--       IF p_met_tpl_assoc_rec.created_by IS NULL THEN
--  Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_met_tpl_assoc_NO_created_by');
--          x_return_status := FND_API.g_ret_sts_error;
--          RETURN;
--       END IF;

      IF p_met_tpl_assoc_rec.metric_tpl_header_id IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTA_NO_MTH_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_assoc_rec.association_type IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTA_NO_ASSOCIATION_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_assoc_rec.enabled_flag IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTA_NO_ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_met_tpl_assoc_req_items;

PROCEDURE check_met_tpl_assoc_FK_items(
    p_met_tpl_assoc_rec IN met_tpl_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_check_header_id(p_METRIC_TPL_HEADER_ID NUMBER) IS
      SELECT 1 FROM AMS_MET_TPL_HEADERS_VL
       WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID;

   CURSOR c_check_custom_setup(p_used_by_id NUMBER) IS
      SELECT 1 FROM ams_custom_setups_vl
       WHERE custom_setup_id = p_used_by_id;

   CURSOR c_check_object_type(p_used_by_code VARCHAR2) IS
       SELECT 1 FROM ams_lookups
        WHERE lookup_code = p_used_by_code
        AND lookup_type = 'AMS_SYS_ARC_QUALIFIER';

   l_dummy NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

   -- Validate metric_tpl_header_id exists.
   OPEN c_check_header_id(p_met_tpl_assoc_rec.metric_tpl_header_id);
   FETCH c_check_header_id INTO l_dummy;
   IF c_check_header_id%NOTFOUND THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_HEADER_ID');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_check_header_id;

   IF p_met_tpl_assoc_rec.association_type = 'CUSTOM_SETUP' THEN
      OPEN c_check_custom_setup(p_met_tpl_assoc_rec.used_by_id);
      FETCH c_check_custom_setup INTO l_dummy;
      IF c_check_custom_setup%NOTFOUND THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_CUSTOM_SETUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_check_custom_setup;
      IF p_met_tpl_assoc_rec.used_by_code IS NOT NULL THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_USED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSIF p_met_tpl_assoc_rec.association_type = 'OBJECT_TYPE' THEN
      OPEN c_check_object_type(p_met_tpl_assoc_rec.used_by_code);
      FETCH c_check_object_type INTO l_dummy;
      IF c_check_object_type%NOTFOUND THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_OBJECT_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_check_object_type;
      IF p_met_tpl_assoc_rec.used_by_id IS NOT NULL THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_USED_BY');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_met_tpl_assoc_FK_items;

PROCEDURE check_met_tpl_assoc_lkp_items(
    p_met_tpl_assoc_rec IN met_tpl_assoc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

   -- Validate association types.
   IF Ams_Utility_Pvt.check_lookup_exists(p_lookup_type => 'AMS_METRIC_TPL_ASSOC_TYPES',
      p_lookup_code => p_met_tpl_assoc_rec.association_type) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_ASSOC_TYPE');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF Ams_Utility_Pvt.is_y_or_n(p_met_tpl_assoc_rec.enabled_flag) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTA_BAD_ENABLED_FLAG');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END check_met_tpl_assoc_lkp_items;

PROCEDURE Check_met_tpl_assoc_Items (
    P_met_tpl_assoc_rec     IN    met_tpl_assoc_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_met_tpl_assoc_uk_items(
      p_met_tpl_assoc_rec => p_met_tpl_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_met_tpl_assoc_req_items(
      p_met_tpl_assoc_rec => p_met_tpl_assoc_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_met_tpl_assoc_FK_items(
      p_met_tpl_assoc_rec => p_met_tpl_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_met_tpl_assoc_lkp_items(
      p_met_tpl_assoc_rec => p_met_tpl_assoc_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_met_tpl_assoc_Items;



PROCEDURE Complete_met_tpl_assoc_Rec (
   p_ref_met_tpl_assoc_rec IN met_tpl_assoc_rec_type,
   x_tar_met_tpl_assoc_rec OUT NOCOPY met_tpl_assoc_rec_type)
IS
   l_return_status  VARCHAR2(1);
/*
   CURSOR c_complete IS
      SELECT *
      FROM ams_met_tpl_assocs
      WHERE METRIC_TPL_ASSOC_ID = p_met_tpl_assoc_rec.METRIC_TPL_ASSOC_ID;
   l_met_tpl_assoc_rec c_complete%ROWTYPE;
*/
BEGIN
   --x_complete_rec := p_met_tpl_assoc_rec;


   --OPEN c_complete;
   --FETCH c_complete INTO l_met_tpl_assoc_rec;
   --CLOSE c_complete;

--    -- metric_tpl_assoc_id
--    IF p_met_tpl_assoc_rec.metric_tpl_assoc_id = FND_API.g_miss_num THEN
--       x_complete_rec.metric_tpl_assoc_id := l_met_tpl_assoc_rec.metric_tpl_assoc_id;
--    END IF;
--
--    -- last_update_date
--    IF p_met_tpl_assoc_rec.last_update_date = FND_API.g_miss_date THEN
--       x_complete_rec.last_update_date := l_met_tpl_assoc_rec.last_update_date;
--    END IF;
--
--    -- last_updated_by
--    IF p_met_tpl_assoc_rec.last_updated_by = FND_API.g_miss_num THEN
--       x_complete_rec.last_updated_by := l_met_tpl_assoc_rec.last_updated_by;
--    END IF;
--
--    -- creation_date
--    IF p_met_tpl_assoc_rec.creation_date = FND_API.g_miss_date THEN
--       x_complete_rec.creation_date := l_met_tpl_assoc_rec.creation_date;
--    END IF;
--
--    -- created_by
--    IF p_met_tpl_assoc_rec.created_by = FND_API.g_miss_num THEN
--       x_complete_rec.created_by := l_met_tpl_assoc_rec.created_by;
--    END IF;
--
--    -- last_update_login
--    IF p_met_tpl_assoc_rec.last_update_login = FND_API.g_miss_num THEN
--       x_complete_rec.last_update_login := l_met_tpl_assoc_rec.last_update_login;
--    END IF;
--
--    -- object_version_number
--    IF p_met_tpl_assoc_rec.object_version_number = FND_API.g_miss_num THEN
--       x_complete_rec.object_version_number := l_met_tpl_assoc_rec.object_version_number;
--    END IF;

   -- metric_tpl_header_id
   IF x_tar_met_tpl_assoc_rec.metric_tpl_header_id = FND_API.g_miss_num THEN
      x_tar_met_tpl_assoc_rec.metric_tpl_header_id := p_ref_met_tpl_assoc_rec.metric_tpl_header_id;
   END IF;

   -- association_type
   IF x_tar_met_tpl_assoc_rec.association_type = FND_API.g_miss_char THEN
      x_tar_met_tpl_assoc_rec.association_type := p_ref_met_tpl_assoc_rec.association_type;
   END IF;

   -- used_by_id
   IF x_tar_met_tpl_assoc_rec.used_by_id = FND_API.g_miss_num THEN
      x_tar_met_tpl_assoc_rec.used_by_id := p_ref_met_tpl_assoc_rec.used_by_id;
   END IF;

   -- used_by_code
   IF x_tar_met_tpl_assoc_rec.used_by_code = FND_API.g_miss_char THEN
      x_tar_met_tpl_assoc_rec.used_by_code := p_ref_met_tpl_assoc_rec.used_by_code;
   END IF;

   -- enabled_flag
   IF x_tar_met_tpl_assoc_rec.enabled_flag = FND_API.g_miss_char THEN
      x_tar_met_tpl_assoc_rec.enabled_flag := p_ref_met_tpl_assoc_rec.enabled_flag;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_met_tpl_assoc_Rec;

PROCEDURE Validate_met_tpl_assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_met_tpl_assoc_rec               IN   met_tpl_assoc_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Met_Tpl_Assoc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_met_tpl_assoc_rec  Ams_Met_Tpl_Assoc_Pvt.met_tpl_assoc_rec_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_Met_Tpl_Assoc_;

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
      Check_met_tpl_assoc_Items(
         p_met_tpl_assoc_rec        => p_met_tpl_assoc_rec,
         p_validation_mode   => p_validation_mode,
         x_return_status     => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

--       Complete_met_tpl_assoc_Rec(
--          p_met_tpl_assoc_rec        => p_met_tpl_assoc_rec,
--          x_complete_rec        => l_met_tpl_assoc_rec
--       );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_met_tpl_assoc_Rec(
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_met_tpl_assoc_rec      =>    l_met_tpl_assoc_rec);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'END');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Met_Tpl_Assoc_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Met_Tpl_Assoc_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Met_Tpl_Assoc_;
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
END Validate_Met_Tpl_Assoc;


PROCEDURE Validate_met_tpl_assoc_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_met_tpl_assoc_rec               IN    met_tpl_assoc_rec_type
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

   Ams_Utility_Pvt.debug_message('PRIVATE API: Validate_met_tpl_assoc_rec');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
END Validate_met_tpl_assoc_Rec;

END Ams_Met_Tpl_Assoc_Pvt;

/
