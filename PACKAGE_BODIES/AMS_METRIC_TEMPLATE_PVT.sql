--------------------------------------------------------
--  DDL for Package Body AMS_METRIC_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_METRIC_TEMPLATE_PVT" AS
/* $Header: amsvmthb.pls 120.0 2005/05/31 13:58:49 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Metric_Template_PVT
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   08-Sep-2003 Sunkumar  Bug#3130095 Metric Template UI Enh. 11510
--   20-apr-2004 sunkumar  Cannot create/update template header name
--                         to contain phrases like 'AND'
--   19-Jan-2005 dmvincen  Bug4057287: Fixed many bugs see bug details.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Metric_Template_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmthb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_metric_tpl_header_Rec (
   p_ref_metric_tpl_header_rec IN metric_tpl_header_rec_type,
   x_tar_metric_tpl_header_rec IN OUT NOCOPY metric_tpl_header_rec_type);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Metric_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_metric_tpl_header_rec      IN   metric_tpl_header_rec_type  := g_miss_metric_tpl_header_rec,
    x_metric_tpl_header_id       OUT NOCOPY  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Metric_Template';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_METRIC_TPL_HEADER_ID      NUMBER;
   l_dummy                     NUMBER;
   l_metric_tpl_header_rec     metric_tpl_header_rec_type := p_metric_tpl_header_rec;

   CURSOR c_id IS
      SELECT AMS_MET_TPL_HEADERS_ALL_S.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_MET_TPL_HEADERS_B
      WHERE METRIC_TPL_HEADER_ID = l_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Metric_Template_PVT;

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

   -- Local variable initialization

   IF l_metric_tpl_header_rec.METRIC_TPL_HEADER_ID IS NULL OR
      l_metric_tpl_header_rec.METRIC_TPL_HEADER_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_METRIC_TPL_HEADER_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_METRIC_TPL_HEADER_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      l_metric_tpl_header_rec.metric_tpl_header_id := l_metric_tpl_header_id;
   ELSE
      l_metric_tpl_header_id := p_metric_tpl_header_rec.metric_tpl_header_id;
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

       Ams_Utility_Pvt.debug_message('Private API: Validate_Metric_Template');
       END IF;

       -- Invoke validation procedures
       Validate_metric_template(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_validation_mode => JTF_PLSQL_API.g_create,
         p_metric_tpl_header_rec  =>  l_metric_tpl_header_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'Private API: Calling create table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_HEADERS_B_PKG.Insert_Row)
   Ams_Met_Tpl_Headers_B_Pkg.Insert_Row(
       px_metric_tpl_header_id  => l_metric_tpl_header_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_creation_date  => SYSDATE,
       p_created_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       px_object_version_number  => l_object_version_number,
       p_enabled_flag  => l_metric_tpl_header_rec.enabled_flag,
       p_application_id  => l_metric_tpl_header_rec.application_id,
       p_METRIC_TPL_HEADER_NAME => l_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME,
       p_DESCRIPTION => l_metric_tpl_header_rec.DESCRIPTION,
       p_object_type => l_metric_tpl_header_rec.object_type,
       p_association_type => l_metric_tpl_header_rec.association_type,
       p_used_by_id => l_metric_tpl_header_rec.used_by_id,
       p_used_by_code => l_metric_tpl_header_rec.used_by_code);

       x_metric_tpl_header_id := l_metric_tpl_header_id;

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
     ROLLBACK TO CREATE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Metric_Template_PVT;
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
END Create_Metric_Template;


PROCEDURE Update_Metric_Template(
   p_api_version_number         IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,

   p_metric_tpl_header_rec      IN   metric_tpl_header_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
)
IS

   CURSOR c_get_metric_template(l_metric_tpl_header_id NUMBER) IS
    SELECT METRIC_TPL_HEADER_ID   ,
      LAST_UPDATE_DATE       ,
      LAST_UPDATED_BY        ,
      CREATION_DATE          ,
      CREATED_BY             ,
      LAST_UPDATE_LOGIN      ,
      OBJECT_VERSION_NUMBER  ,
      APPLICATION_ID         ,
      ENABLED_FLAG           ,
      METRIC_TPL_HEADER_NAME,
      DESCRIPTION,
      OBJECT_TYPE,
      ASSOCIATION_TYPE,
      USED_BY_ID,
      USED_BY_CODE

    FROM  AMS_MET_TPL_HEADERS_VL
   WHERE metric_tpl_header_id = l_metric_tpl_header_id;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Metric_Template';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_METRIC_TPL_HEADER_ID      NUMBER;
   l_ref_metric_tpl_header_rec  metric_tpl_header_rec_type;
   l_tar_metric_tpl_header_rec  metric_tpl_header_rec_type;
   l_rowid  ROWID;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Metric_Template_PVT;

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
      Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize the tar record.
   l_tar_metric_tpl_header_rec  := P_metric_tpl_header_rec;

   IF (AMS_DEBUG_HIGH_ON) THEN
      Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name ||
      ': ASSOCIATION_TYPE = '|| l_tar_metric_tpl_header_rec.association_type);
   END IF;

   IF (l_tar_metric_tpl_header_rec.METRIC_TPL_HEADER_ID IS NULL OR
       l_tar_metric_tpl_header_rec.METRIC_TPL_HEADER_ID = FND_API.G_MISS_NUM )
   THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD',
         p_token_name   => 'COLUMN',
         p_token_value  => 'METRIC_TPL_HEADER_ID');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_tar_metric_tpl_header_rec.object_version_number IS NULL OR
       l_tar_metric_tpl_header_rec.object_version_number = FND_API.G_MISS_NUM)
   THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
         p_token_name   => 'COLUMN',
         p_token_value  => 'object_version_number');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN c_get_Metric_Template(l_tar_metric_tpl_header_rec.metric_tpl_header_id);

   FETCH c_get_Metric_Template INTO l_ref_metric_tpl_header_rec;

   IF ( c_get_Metric_Template%NOTFOUND) THEN
      Ams_Utility_Pvt.Error_Message(
         p_message_name => 'API_MISSING_UPDATE_TARGET',
         p_token_name   => 'INFO',
         p_token_value  => 'Metric_Template');
      CLOSE     c_get_Metric_Template;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_get_Metric_Template;

   -- Check Whether record has been changed by someone else
   IF (l_tar_metric_tpl_header_rec.object_version_number <>
       l_ref_metric_tpl_header_rec.object_version_number) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
         p_token_name   => 'INFO',
         p_token_value  => 'Metric_Template');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- 13-Jan-2005 dmvincen : Changing name, desc, and enabled is allowed.
  /*************
  --11/26/02 sunil : check if the template is a seeded one
   IF (l_ref_metric_tpl_header_rec.metric_tpl_header_id  < 10000) THEN
     IF (((l_tar_metric_tpl_header_rec.metric_tpl_header_name <>
             l_ref_metric_tpl_header_rec.metric_tpl_header_name)
          OR (l_tar_metric_tpl_header_rec.description  <>
              l_ref_metric_tpl_header_rec.description ))
     AND (l_tar_metric_tpl_header_rec.enabled_flag =
           l_ref_metric_tpl_header_rec.enabled_flag)) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED_MOD');
        END IF;

        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   ***************/

   l_object_version_number := l_ref_metric_tpl_header_rec.object_version_number + 1;

   Complete_metric_tpl_header_Rec(l_ref_metric_tpl_header_rec,
                                  l_tar_metric_tpl_header_rec);

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Private API: Validate_Metric_Template');
      END IF;

      -- Invoke validation procedures
      Validate_metric_template(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_validation_mode => JTF_PLSQL_API.g_update,
         p_metric_tpl_header_rec  =>  l_tar_metric_tpl_header_rec,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data);
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: Calling Ams_Met_Tpl_Headers_B_Pkg.Update_Row');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_HEADERS_B_PKG.Update_Row)
   Ams_Met_Tpl_Headers_B_Pkg.Update_Row(
       p_metric_tpl_header_id  => l_ref_metric_tpl_header_rec.metric_tpl_header_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       p_object_version_number  => l_object_version_number,
       p_enabled_flag  => l_tar_metric_tpl_header_rec.enabled_flag,
       p_application_id  => l_tar_metric_tpl_header_rec.application_id,
      p_METRIC_TPL_HEADER_NAME => l_tar_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME,
      p_DESCRIPTION => l_tar_metric_tpl_header_rec.DESCRIPTION,
       p_object_type => l_ref_metric_tpl_header_rec.object_type,
        p_association_type => l_ref_metric_tpl_header_rec.association_type,
        p_used_by_id => l_ref_metric_tpl_header_rec.used_by_id,
        p_used_by_code => l_ref_metric_tpl_header_rec.used_by_code);
   x_object_version_number := l_object_version_number;

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

   Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': END');
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
     ROLLBACK TO UPDATE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Metric_Template_PVT;
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
END Update_Metric_Template;


PROCEDURE Delete_Metric_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_tpl_header_id       IN  NUMBER,
    p_object_version_number      IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Metric_Template';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Metric_Template_PVT;

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

   Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': START');
   END IF;


   --11/26/02 sunil : check if the template is a seeded one
   IF p_metric_tpl_header_id  < 10000 THEN
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

   Ams_Utility_Pvt.debug_message(
      'PRIVATE API: DELETING metric template id='||p_metric_tpl_header_id);
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'PRIVATE API: DELETING metric template details');
   END IF;

   DELETE FROM ams_met_tpl_details
   WHERE metric_tpl_header_id = p_metric_tpl_header_id;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'PRIVATE API: DELETING metric template associations');
   END IF;

   DELETE FROM ams_met_tpl_assocs
   WHERE metric_tpl_header_id = p_metric_tpl_header_id;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message( 'PRIVATE API: Calling DELETE TABLE handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_HEADERS_B_PKG.Delete_Row)
   Ams_Met_Tpl_Headers_B_Pkg.Delete_Row(
       p_METRIC_TPL_HEADER_ID  => p_METRIC_TPL_HEADER_ID);
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
     ROLLBACK TO DELETE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Metric_Template_PVT;
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
END Delete_Metric_Template;

-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Metric_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_metric_tpl_header_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Metric_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_METRIC_TPL_HEADER_ID                  NUMBER;

CURSOR c_Metric_Template IS
   SELECT METRIC_TPL_HEADER_ID
   FROM AMS_MET_TPL_HEADERS_B
   WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
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



  Ams_Utility_Pvt.debug_message(l_full_name||': START');

  END IF;
  OPEN c_Metric_Template;

  FETCH c_Metric_Template INTO l_METRIC_TPL_HEADER_ID;

  IF (c_Metric_Template%NOTFOUND) THEN
    CLOSE c_Metric_Template;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Metric_Template;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  Ams_Utility_Pvt.debug_message(l_full_name ||': END');
  END IF;
EXCEPTION

   WHEN Ams_Utility_Pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Metric_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Metric_Template_PVT;
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
END Lock_Metric_Template;


PROCEDURE CHECK_met_tpl_hdr_UK_ITEMS(
    p_metric_tpl_header_rec      IN   metric_tpl_header_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
   l_valid_flag  VARCHAR2(1) := FND_API.g_false;


/*sunkumar - 20-apr-2004 validations for name of metric template */
/* CREATING template WITH THE WORD "AND" RATHER THAN "&" CREATES ERROR */

CURSOR c_check_header_name(p_met_tpl_header_name VARCHAR2) IS
SELECT count(1)
FROM AMS_MET_TPL_HEADERS_VL
WHERE METRIC_TPL_HEADER_NAME = p_met_tpl_header_name;

CURSOR c_check_header_detail(p_met_tpl_header_id number,
                             p_met_tpl_header_name VARCHAR2) IS
SELECT 1
FROM AMS_MET_TPL_HEADERS_VL
WHERE METRIC_TPL_HEADER_ID <> p_met_tpl_header_id
AND   METRIC_TPL_HEADER_NAME = p_met_tpl_header_name;

/*ENd Changes sunkumar */

 CURSOR c_crt_get_dup_names(p_metrics_name VARCHAR2,
               p_arc_metric_used_for_object VARCHAR2) IS
     SELECT 1
     FROM ams_metrics_vl
     WHERE UPPER(METRICS_NAME) = UPPER(p_metrics_name)
        AND arc_metric_used_for_object = p_arc_metric_used_for_object;

   l_count number;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_UK_items:'
        || ' name/id=' || p_metric_tpl_header_rec.metric_tpl_header_name
        || '/' || p_metric_tpl_header_rec.metric_tpl_header_id);
   END IF;

   -- Validate the PK ID is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
      'AMS_MET_TPL_HEADERS_VL',
      'METRIC_TPL_HEADER_ID = ' || p_metric_tpl_header_rec.METRIC_TPL_HEADER_ID
      );
      IF l_valid_flag = FND_API.g_false THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTH_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
--    ELSE
--       l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
--       'AMS_MET_TPL_HEADERS_VL',
--       'METRIC_TPL_HEADER_ID = ' || p_metric_tpl_header_rec.METRIC_TPL_HEADER_ID ||
--       ' AND METRIC_TPL_HEADER_ID <> ' || p_metric_tpl_header_rec.METRIC_TPL_HEADER_ID
--       );
   END IF;

   -- Validate the name is unique.

/*sunkumar - 20-apr-2004 validations for name of metric template */
/* CREATING template WITH THE WORD "AND" RATHER THAN "&" CREATES ERROR */

   l_valid_flag := FND_API.G_TRUE;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      OPEN c_check_header_name(p_metric_tpl_header_rec.Metric_Tpl_header_name);
      FETCH c_check_header_name INTO l_count;
      CLOSE c_check_header_name;
      IF l_count > 0 THEN
         l_valid_flag := FND_API.G_FALSE;
      END IF;

   ELSE

      OPEN c_check_header_detail(p_metric_tpl_header_rec.metric_tpl_header_id,
                               p_metric_tpl_header_rec.metric_tpl_header_name);
      FETCH c_check_header_detail INTO l_count;
      CLOSE c_check_header_detail;
      IF l_count > 0 THEN
         l_valid_flag := FND_API.G_FALSE;
      END IF;

   END IF;

   /*End changes sunkumar */

   IF l_valid_flag = FND_API.g_false THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTH_NAME_DUPLICATE');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END check_met_tpl_hdr_uk_items;

PROCEDURE CHECK_met_tpl_hdr_REQ_ITEMS(
    p_metric_tpl_header_rec      IN  metric_tpl_header_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_metric_tpl_header_rec.metric_tpl_header_id IS NULL OR
        p_metric_tpl_header_rec.metric_tpl_header_id = FND_API.g_miss_num THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.enabled_flag IS NULL OR
        p_metric_tpl_header_rec.enabled_flag = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME IS NULL OR
        p_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_HEADER_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.DESCRIPTION IS NOT NULL AND
        p_metric_tpl_header_rec.DESCRIPTION = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','DESCRIPTION');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.ASSOCIATION_TYPE IS NULL OR
         p_metric_tpl_header_rec.ASSOCIATION_TYPE = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ASSOCIATION_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'CUSTOM_SETUP' AND
         (p_metric_tpl_header_rec.USED_BY_ID IS NULL OR
         p_metric_tpl_header_rec.USED_BY_ID = FND_API.g_miss_num) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','USED_BY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'OBJECT_TYPE' AND
         (p_metric_tpl_header_rec.USED_BY_CODE IS NULL OR
         p_metric_tpl_header_rec.USED_BY_CODE = FND_API.g_miss_char) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','USED_BY_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE -- Update

      IF p_metric_tpl_header_rec.metric_tpl_header_id IS NULL OR
        p_metric_tpl_header_rec.metric_tpl_header_id = FND_API.g_miss_num THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTH_NO_MET_TPL_HDR_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.enabled_flag IS NULL OR
        p_metric_tpl_header_rec.enabled_flag = FND_API.g_miss_char THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTH_NO_ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME IS NULL OR
        p_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_HEADER_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.DESCRIPTION IS NOT NULL AND
        p_metric_tpl_header_rec.DESCRIPTION = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','DESCRIPTION');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.ASSOCIATION_TYPE IS NULL OR
         p_metric_tpl_header_rec.ASSOCIATION_TYPE = FND_API.g_miss_char THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ASSOCIATION_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'CUSTOM_SETUP' AND
         (p_metric_tpl_header_rec.USED_BY_ID IS NULL OR
         p_metric_tpl_header_rec.USED_BY_ID = FND_API.g_miss_num) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','USED_BY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'OBJECT_TYPE' AND
         (p_metric_tpl_header_rec.USED_BY_CODE IS NULL OR
         p_metric_tpl_header_rec.USED_BY_CODE = FND_API.g_miss_char) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','USED_BY_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

END CHECK_met_tpl_hdr_REQ_ITEMS;

PROCEDURE CHECK_met_tpl_hdr_FK_ITEMS(
    p_metric_tpl_header_rec IN metric_tpl_header_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_checkObjectType(p_objectType VARCHAR2) IS
      SELECT count(1) FROM ams_lookups
      WHERE lookup_type = 'AMS_METRIC_OBJECT_TYPE'
      AND lookup_code = p_objectType;

   CURSOR c_checkCustomSetup(p_setupId NUMBER) IS
      SELECT count(1)
      FROM ams_custom_setups_B a, ams_lookups b
      WHERE custom_setup_id = p_setupId
      AND b.lookup_type in ( 'AMS_METRIC_OBJECT_TYPE', 'AMS_ROLLUP_TYPE')
      AND b.lookup_code = a.object_type;

   l_count NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'OBJECT_TYPE' THEN

      IF AMS_DEBUG_HIGH_ON THEN
         Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_FK'||
            ': object_type = '|| p_metric_tpl_header_rec.USED_BY_CODE);
      END IF;

      OPEN c_checkObjectType(p_metric_tpl_header_rec.USED_BY_CODE);
      FETCH c_checkObjectType INTO l_count;
      CLOSE c_checkObjectTYpe;

      IF l_count = 0 THEN
         Ams_Utility_Pvt.error_message('AMS_MTH_INVALID_OBJECT_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSIF p_metric_tpl_header_rec.ASSOCIATION_TYPE = 'CUSTOM_SETUP' THEN

      IF AMS_DEBUG_HIGH_ON THEN
         Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_FK'||
            ': custom_setup_id = '|| p_metric_tpl_header_rec.USED_BY_ID);
      END IF;

      OPEN c_checkCustomSetup(p_metric_tpl_header_rec.USED_BY_ID);
      FETCH c_checkCustomSetup INTO l_count;
      CLOSE c_checkCustomSetup;

      IF l_count = 0 THEN
         Ams_Utility_Pvt.error_message('AMS_MTH_INVALID_CUSTOM_SETUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_FK'||
         ': x_return_status = '|| x_return_status);
   END IF;

END CHECK_met_tpl_hdr_FK_ITEMS;

PROCEDURE CHECK_met_tpl_hdr_LKP(
    p_metric_tpl_header_rec IN metric_tpl_header_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
   IF Ams_Utility_Pvt.is_y_or_n(p_metric_tpl_header_rec.enabled_flag) =
      FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(
               p_message_name => 'AMS_MTH_BAD_ENABLED_FLAG');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_LKP'||
         ': lookup_code = '|| p_metric_tpl_header_rec.ASSOCIATION_TYPE);
   END IF;

   IF AMS_UTILITY_PVT.Check_Lookup_Exists('ams_lookups',
         'AMS_METRIC_TPL_ASSOC_TYPES',
         p_metric_tpl_header_rec.ASSOCIATION_TYPE) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(
               p_message_name => 'AMS_MTH_INVALID_ASSOC_TYPE');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END CHECK_met_tpl_hdr_LKP;

PROCEDURE Check_met_tpl_hdr_Items (
    P_metric_tpl_header_rec     IN    metric_tpl_header_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_items: UK');
   END IF;

   check_met_tpl_hdr_uk_items(
      p_metric_tpl_header_rec => p_metric_tpl_header_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_items: REQ');
   END IF;

   CHECK_met_tpl_hdr_REQ_ITEMS(
      p_metric_tpl_header_rec => p_metric_tpl_header_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Lookups

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_items: LKP');
   END IF;

   CHECK_met_tpl_hdr_LKP(
      p_metric_tpl_header_rec => p_metric_tpl_header_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_items: FK');
   END IF;

   CHECK_met_tpl_hdr_FK_ITEMS(
      p_metric_tpl_header_rec => p_metric_tpl_header_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: Check_met_tpl_hdr_items: DONE');
   END IF;

END Check_met_tpl_hdr_Items;


-- PARAMETERS:
--   p_ref_metric_tpl_header_rec - record copy from the database
--   x_tar_metric_tpl_header_rec - input record to complete.
PROCEDURE Complete_metric_tpl_header_Rec (
   p_ref_metric_tpl_header_rec IN metric_tpl_header_rec_type,
   x_tar_metric_tpl_header_rec IN OUT NOCOPY metric_tpl_header_rec_type)
IS
--    l_return_status  VARCHAR2(1);

--    CURSOR c_complete IS
--       SELECT *
--       FROM ams_met_tpl_headers_vl
--       WHERE metric_tpl_header_id = p_metric_tpl_header_rec.metric_tpl_header_id;
--    l_metric_tpl_header_rec c_complete%ROWTYPE;
BEGIN
   -- x_complete_rec := p_metric_tpl_header_rec;

--    OPEN c_complete;
--    FETCH c_complete INTO l_metric_tpl_header_rec;
--    CLOSE c_complete;

   -- metric_tpl_header_id
--    IF p_metric_tpl_header_rec.metric_tpl_header_id = FND_API.g_miss_num THEN
--       x_complete_rec.metric_tpl_header_id := l_metric_tpl_header_rec.metric_tpl_header_id;
--    END IF;

   -- last_update_date
--    IF p_metric_tpl_header_rec.last_update_date = FND_API.g_miss_date THEN
--       x_complete_rec.last_update_date := l_metric_tpl_header_rec.last_update_date;
--    END IF;

   -- last_updated_by
--    IF p_metric_tpl_header_rec.last_updated_by = FND_API.g_miss_num THEN
--       x_complete_rec.last_updated_by := l_metric_tpl_header_rec.last_updated_by;
--    END IF;

   -- creation_date
--    IF p_metric_tpl_header_rec.creation_date = FND_API.g_miss_date THEN
--       x_complete_rec.creation_date := l_metric_tpl_header_rec.creation_date;
--    END IF;

   -- created_by
--    IF p_metric_tpl_header_rec.created_by = FND_API.g_miss_num THEN
--       x_complete_rec.created_by := l_metric_tpl_header_rec.created_by;
--    END IF;

   -- last_update_login
--    IF p_metric_tpl_header_rec.last_update_login = FND_API.g_miss_num THEN
--       x_complete_rec.last_update_login := l_metric_tpl_header_rec.last_update_login;
--    END IF;

   -- object_version_number
--    IF p_metric_tpl_header_rec.object_version_number = FND_API.g_miss_num THEN
--       x_complete_rec.object_version_number := l_metric_tpl_header_rec.object_version_number;
--    END IF;

   -- enabled_flag
   IF x_tar_metric_tpl_header_rec.enabled_flag = FND_API.g_miss_char THEN
      x_tar_metric_tpl_header_rec.enabled_flag := p_ref_metric_tpl_header_rec.enabled_flag;
   END IF;

   -- application_id
   IF x_tar_metric_tpl_header_rec.application_id = FND_API.g_miss_num THEN
      x_tar_metric_tpl_header_rec.application_id := p_ref_metric_tpl_header_rec.application_id;
   END IF;

   -- METRIC_TPL_HEADER_NAME
   IF x_tar_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME = FND_API.g_miss_char
   THEN
      x_tar_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME :=
            p_ref_metric_tpl_header_rec.METRIC_TPL_HEADER_NAME;
   END IF;

   -- DESCRIPTION
   IF x_tar_metric_tpl_header_rec.DESCRIPTION = FND_API.g_miss_char THEN
      x_tar_metric_tpl_header_rec.DESCRIPTION :=
            p_ref_metric_tpl_header_rec.DESCRIPTION;
   END IF;

   -- ASSOCIATION_TYPE
   IF x_tar_metric_tpl_header_rec.ASSOCIATION_TYPE = FND_API.g_miss_char THEN
      x_tar_metric_tpl_header_rec.ASSOCIATION_TYPE :=
            p_ref_metric_tpl_header_rec.ASSOCIATION_TYPE;
   END IF;

   -- USED_BY_ID
   IF x_tar_metric_tpl_header_rec.USED_BY_ID = FND_API.g_miss_num THEN
      x_tar_metric_tpl_header_rec.USED_BY_ID :=
            p_ref_metric_tpl_header_rec.USED_BY_ID;
   END IF;

   -- USED_BY_CODE
   IF x_tar_metric_tpl_header_rec.USED_BY_CODE = FND_API.g_miss_char THEN
      x_tar_metric_tpl_header_rec.USED_BY_CODE :=
            p_ref_metric_tpl_header_rec.USED_BY_CODE;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_metric_tpl_header_Rec;

PROCEDURE Validate_metric_template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_metric_tpl_header_rec      IN   metric_tpl_header_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Validate_Metric_Template';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
   l_object_version_number  NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_Metric_Template_;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      -- Debug Message
      IF AMS_DEBUG_HIGH_ON THEN
         Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': Checking header items');
      END IF;

      Check_met_tpl_hdr_Items(
         p_metric_tpl_header_rec => p_metric_tpl_header_rec,
         p_validation_mode   => p_validation_mode,
         x_return_status     => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN

      -- Debug Message
      IF AMS_DEBUG_HIGH_ON THEN
         Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': UPDATE MODE');
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_met_tpl_hdr_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_metric_tpl_header_rec  => p_metric_tpl_header_rec);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END IF;

   -- Debug Message
   IF AMS_DEBUG_HIGH_ON THEN
      Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': END');
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
     ROLLBACK TO VALIDATE_Metric_Template_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Metric_Template_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Metric_Template_;
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
END Validate_Metric_Template;


PROCEDURE Validate_met_tpl_hdr_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_tpl_header_rec               IN    metric_tpl_header_rec_type
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

   Ams_Utility_Pvt.debug_message('PRIVATE API: Validate_met_tpl_hdr_rec');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
END Validate_met_tpl_hdr_Rec;

END Ams_Metric_Template_Pvt;

/
