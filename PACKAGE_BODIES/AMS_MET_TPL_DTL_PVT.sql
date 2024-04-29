--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_DTL_PVT" AS
/* $Header: amsvmtdb.pls 115.8 2003/10/25 00:21:35 choang ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Met_Tpl_Dtl_PVT
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   30/01/2003  sunkumar  restricted updation for seeded metrics apart from the enable flag.
--  24-oct-2003  choang    added FORMULA for enh 3130095
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Met_Tpl_Dtl_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvmtdb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Complete_met_tpl_dtl_Rec (
   p_ref_met_tpl_dtl_rec IN met_tpl_dtl_rec_type,
   x_tar_met_tpl_dtl_rec IN OUT NOCOPY met_tpl_dtl_rec_type);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Met_Tpl_Dtl(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_met_tpl_dtl_rec            IN   met_tpl_dtl_rec_type := g_miss_met_tpl_dtl_rec,
    x_metric_template_detail_id  OUT NOCOPY  NUMBER
     )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Met_Tpl_Dtl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_METRIC_TEMPLATE_DETAIL_ID NUMBER;
   l_dummy                     NUMBER;

   CURSOR c_id IS
      SELECT AMS_MET_TPL_DETAILS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_MET_TPL_DETAILS
      WHERE METRIC_TEMPLATE_DETAIL_ID = l_id;

   l_met_tpl_dtl_rec  met_tpl_dtl_rec_type := p_met_tpl_dtl_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Met_Tpl_Dtl_PVT;

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

   --sunkumar 30/01/2003
  --check if the template is a seeded one
 /* IF p_met_tpl_dtl_rec.metric_tpl_header_id  < 10000 THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED');
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF; */


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF l_met_tpl_dtl_rec.METRIC_TEMPLATE_DETAIL_ID IS NULL OR
      l_met_tpl_dtl_rec.METRIC_TEMPLATE_DETAIL_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_METRIC_TEMPLATE_DETAIL_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_METRIC_TEMPLATE_DETAIL_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      l_met_tpl_dtl_rec.metric_template_detail_id := l_metric_template_detail_id;
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

       Ams_Utility_Pvt.debug_message('Private API: Validate_Met_Tpl_Dtl');
       END IF;

       -- Invoke validation procedures
       Validate_met_tpl_dtl(
         p_api_version_number     => 1.0,
         p_init_msg_list    => FND_API.G_FALSE,
         p_validation_level => p_validation_level,
         p_validation_mode => JTF_PLSQL_API.g_create,
         p_met_tpl_dtl_rec  =>  l_met_tpl_dtl_rec,
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

   -- Invoke table handler(AMS_MET_TPL_DETAILS_PKG.Insert_Row)
   Ams_Met_Tpl_Details_Pkg.Insert_Row(
       px_metric_template_detail_id  => l_metric_template_detail_id,
       p_last_update_date  => SYSDATE,
       p_last_updated_by  => FND_GLOBAL.USER_ID,
       p_creation_date  => SYSDATE,
       p_created_by  => FND_GLOBAL.USER_ID,
       p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
       px_object_version_number  => l_object_version_number,
       p_metric_tpl_header_id  => p_met_tpl_dtl_rec.metric_tpl_header_id,
       p_metric_id  => p_met_tpl_dtl_rec.metric_id,
       p_enabled_flag  => p_met_tpl_dtl_rec.enabled_flag);

       x_metric_template_detail_id := l_metric_template_detail_id;
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
     ROLLBACK TO CREATE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Met_Tpl_Dtl_PVT;
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
END Create_Met_Tpl_Dtl;


PROCEDURE Update_Met_Tpl_Dtl(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,

   p_met_tpl_dtl_rec            IN    met_tpl_dtl_rec_type,
   x_object_version_number      OUT NOCOPY  NUMBER
   )

IS
   CURSOR c_get_met_tpl_dtl(l_metric_template_detail_id NUMBER) IS
       SELECT METRIC_TEMPLATE_DETAIL_ID,
             LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
            METRIC_TPL_HEADER_ID,
            METRIC_ID,
            ENABLED_FLAG
       FROM  AMS_MET_TPL_DETAILS
      WHERE METRIC_TEMPLATE_DETAIL_ID = l_metric_template_detail_id;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Met_Tpl_Dtl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_METRIC_TEMPLATE_DETAIL_ID NUMBER;
   l_ref_met_tpl_dtl_rec  met_tpl_dtl_rec_type ;
   l_tar_met_tpl_dtl_rec  met_tpl_dtl_rec_type := p_met_tpl_dtl_rec;
   l_rowid  ROWID;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Met_Tpl_Dtl_PVT;

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

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: - Open Cursor to Select');
   END IF;

   OPEN c_get_Met_Tpl_Dtl( l_tar_met_tpl_dtl_rec.metric_template_detail_id);

   FETCH c_get_Met_Tpl_Dtl INTO l_ref_met_tpl_dtl_rec;

   IF ( c_get_Met_Tpl_Dtl%NOTFOUND) THEN
      CLOSE c_get_Met_Tpl_Dtl;
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
         p_token_name   => 'INFO',
         p_token_value  => 'Met_Tpl_Dtl');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: - Close Cursor');
   END IF;
   CLOSE c_get_Met_Tpl_Dtl;

   Complete_met_tpl_dtl_rec(l_ref_met_tpl_dtl_rec, l_tar_met_tpl_dtl_rec);

   IF (l_tar_met_tpl_dtl_rec.object_version_number IS NULL OR
       l_tar_met_tpl_dtl_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
         p_token_name   => 'COLUMN',
         p_token_value  => 'Last_Update_Date');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check Whether record has been changed by someone else
   IF (l_tar_met_tpl_dtl_rec.object_version_number <> l_ref_met_tpl_dtl_rec.object_version_number) THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
         p_token_name   => 'INFO',
         p_token_value  => 'Met_Tpl_Dtl');
      RAISE FND_API.G_EXC_ERROR;
   END IF;


 --sunkumar 30/01/2003
  --check if we are trying to update a seeded metric template
  IF p_met_tpl_dtl_rec.metric_tpl_header_id  < 10000 THEN
   IF (( (l_tar_met_tpl_dtl_rec.metric_template_detail_id <>l_ref_met_tpl_dtl_rec.metric_template_detail_id )
	  OR (l_tar_met_tpl_dtl_rec.metric_id   <>l_ref_met_tpl_dtl_rec.metric_id)
	  OR (l_tar_met_tpl_dtl_rec.metric_tpl_header_id <>l_ref_met_tpl_dtl_rec.metric_tpl_header_id))
	  AND (l_tar_met_tpl_dtl_rec.enabled_flag=l_ref_met_tpl_dtl_rec.enabled_flag)) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
        THEN
           Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_METR_TPL_SEEDED_MOD');
        END IF;


        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;




   IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
   THEN
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Private API: Validate_Met_Tpl_Dtl');
      END IF;

      -- Invoke validation procedures
      Validate_met_tpl_dtl(
        p_api_version_number => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_validation_level => p_validation_level,
        p_validation_mode  => JTF_PLSQL_API.g_update,
        p_met_tpl_dtl_rec  => l_tar_met_tpl_dtl_rec,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);
      -- Debug message
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Private API: Validate_Met_Tpl_Dtl: return status='||x_return_status);
      END IF;
   END IF;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_object_version_number :=
       l_ref_met_tpl_dtl_rec.object_version_number + 1;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: Calling update table handler');
   END IF;

   -- Invoke table handler(AMS_MET_TPL_DETAILS_PKG.Update_Row)
   Ams_Met_Tpl_Details_Pkg.Update_Row(
      p_metric_template_detail_id  => p_met_tpl_dtl_rec.metric_template_detail_id,
      p_last_update_date  => SYSDATE,
      p_last_updated_by  => FND_GLOBAL.USER_ID,
      p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
      p_object_version_number  => l_object_version_number,
      p_metric_tpl_header_id  => p_met_tpl_dtl_rec.metric_tpl_header_id,
      p_metric_id  => p_met_tpl_dtl_rec.metric_id,
      p_enabled_flag  => p_met_tpl_dtl_rec.enabled_flag);

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
     ROLLBACK TO UPDATE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Met_Tpl_Dtl_PVT;
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
END Update_Met_Tpl_Dtl;


PROCEDURE Delete_Met_Tpl_Dtl(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_metric_template_detail_id  IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Met_Tpl_Dtl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_Met_Tpl_Dtl_PVT;

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

  --sunkumar 30/01/2003
  --check if the template is a seeded one
  IF  p_metric_template_detail_id   < 10000 THEN
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

   -- Invoke table handler(AMS_MET_TPL_DETAILS_PKG.Delete_Row)
   Ams_Met_Tpl_Details_Pkg.Delete_Row(
       p_METRIC_TEMPLATE_DETAIL_ID  => p_METRIC_TEMPLATE_DETAIL_ID);
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
     ROLLBACK TO DELETE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Met_Tpl_Dtl_PVT;
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
END Delete_Met_Tpl_Dtl;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Met_Tpl_Dtl(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_metric_template_detail_id  IN  NUMBER,
    p_object_version             IN  NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Met_Tpl_Dtl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_METRIC_TEMPLATE_DETAIL_ID NUMBER;

   CURSOR c_Met_Tpl_Dtl IS
      SELECT METRIC_TEMPLATE_DETAIL_ID
      FROM AMS_MET_TPL_DETAILS
      WHERE METRIC_TEMPLATE_DETAIL_ID = p_METRIC_TEMPLATE_DETAIL_ID
      AND object_version_number = p_object_version
      FOR UPDATE NOWAIT;

BEGIN

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('Private API: ' || l_api_name || ': start');
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
  OPEN c_Met_Tpl_Dtl;

  FETCH c_Met_Tpl_Dtl INTO l_METRIC_TEMPLATE_DETAIL_ID;

  IF (c_Met_Tpl_Dtl%NOTFOUND) THEN
    CLOSE c_Met_Tpl_Dtl;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Met_Tpl_Dtl;

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
     ROLLBACK TO LOCK_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Met_Tpl_Dtl_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Met_Tpl_Dtl_PVT;
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
END Lock_Met_Tpl_Dtl;


PROCEDURE check_met_tpl_dtl_uk_items(
    p_met_tpl_dtl_rec            IN  met_tpl_dtl_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
l_dummy NUMBER;

   CURSOR c_check_duplicate(p_METRIC_ID NUMBER, p_METRIC_TPL_HEADER_ID NUMBER) IS
      SELECT 1 FROM AMS_MET_TPL_DETAILS
     WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID
     AND METRIC_ID = p_METRIC_ID;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      l_valid_flag := Ams_Utility_Pvt.check_uniqueness(
      'AMS_MET_TPL_DETAILS',
      'METRIC_TEMPLATE_DETAIL_ID = ' || p_met_tpl_dtl_rec.METRIC_TEMPLATE_DETAIL_ID
      );
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTD_ID_DUP');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      OPEN c_check_duplicate(p_met_tpl_dtl_rec.metric_id, p_met_tpl_dtl_rec.metric_tpl_header_id);
      FETCH c_check_duplicate INTO l_dummy;
      IF c_check_duplicate%FOUND THEN
         Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTD_DUP_METRIC_ID');
        x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE c_check_duplicate;
   END IF;

END check_met_tpl_dtl_uk_items;

PROCEDURE check_met_tpl_dtl_req_items(
    p_met_tpl_dtl_rec               IN  met_tpl_dtl_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_met_tpl_dtl_rec.metric_template_detail_id = FND_API.g_miss_num OR p_met_tpl_dtl_rec.metric_template_detail_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TEMPLATE_DETAIL_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_dtl_rec.metric_tpl_header_id = FND_API.g_miss_num OR p_met_tpl_dtl_rec.metric_tpl_header_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_TPL_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_dtl_rec.metric_id = FND_API.g_miss_num OR p_met_tpl_dtl_rec.metric_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_dtl_rec.enabled_flag = FND_API.g_miss_char OR p_met_tpl_dtl_rec.enabled_flag IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE  -- Update

      IF p_met_tpl_dtl_rec.metric_template_detail_id IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTD_NO_MET_TPL_DTL_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_met_tpl_dtl_rec.metric_tpl_header_id IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTD_NO_METRIC_TPL_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_met_tpl_dtl_rec.metric_id IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTD_NO_METRIC_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_met_tpl_dtl_rec.enabled_flag IS NULL THEN
 Ams_Utility_Pvt.Error_Message(p_message_name => 'AMS_MTD_NO_ENABLED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_met_tpl_dtl_req_items;

PROCEDURE check_met_tpl_dtl_FK_items(
    p_met_tpl_dtl_rec IN met_tpl_dtl_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_check_header_id(p_METRIC_TPL_HEADER_ID NUMBER) IS
      SELECT 1 FROM AMS_MET_TPL_HEADERS_VL
     WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID;

   -- choang - 24-oct-2003
   -- added FORMULA for enh 3130095
   CURSOR c_check_metric(p_metric_id NUMBER) IS
      SELECT 1 FROM ams_metrics_all_b
     WHERE metric_id = p_metric_id
     AND metric_calculation_type IN ('FUNCTION', 'MANUAL', 'FORMULA');

   l_dummy NUMBER;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

   -- Validate metric_tpl_header_id exists.
   OPEN c_check_header_id(p_met_tpl_dtl_rec.metric_tpl_header_id);
   FETCH c_check_header_id INTO l_dummy;
   IF c_check_header_id%NOTFOUND THEN
     Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTD_BAD_HEADER_ID');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_check_header_id;

   -- Validate the metric_id exists and is FUNCTION or MANUAL
   OPEN c_check_metric(p_met_tpl_dtl_rec.metric_id);
   FETCH c_check_metric INTO l_dummy;
   IF c_check_metric%NOTFOUND THEN
     Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTD_BAD_METRIC_ID');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
   CLOSE c_check_metric;

END check_met_tpl_dtl_FK_items;

PROCEDURE check_met_tpl_dtl_Lookup_items(
    p_met_tpl_dtl_rec IN met_tpl_dtl_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
   IF Ams_Utility_Pvt.is_y_or_n(p_met_tpl_dtl_rec.enabled_flag) = FND_API.G_FALSE THEN
      Ams_Utility_Pvt.error_message(p_message_name => 'AMS_MTD_BAD_ENABLED_FLAG');
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END check_met_tpl_dtl_Lookup_items;

PROCEDURE Check_met_tpl_dtl_Items (
    P_met_tpl_dtl_rec  IN    met_tpl_dtl_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_met_tpl_dtl_uk_items(
      p_met_tpl_dtl_rec => p_met_tpl_dtl_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_met_tpl_dtl_req_items(
      p_met_tpl_dtl_rec => p_met_tpl_dtl_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_met_tpl_dtl_FK_items(
      p_met_tpl_dtl_rec => p_met_tpl_dtl_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_met_tpl_dtl_Lookup_items(
      p_met_tpl_dtl_rec => p_met_tpl_dtl_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_met_tpl_dtl_Items;



PROCEDURE Complete_met_tpl_dtl_Rec (
   p_ref_met_tpl_dtl_rec IN met_tpl_dtl_rec_type,
   x_tar_met_tpl_dtl_rec IN OUT NOCOPY met_tpl_dtl_rec_type)
IS
--    l_return_status  VARCHAR2(1);

--    CURSOR c_complete IS
--       SELECT *
--       FROM ams_met_tpl_details
--       WHERE metric_template_detail_id = p_met_tpl_dtl_rec.metric_template_detail_id;
--    l_met_tpl_dtl_rec c_complete%ROWTYPE;
BEGIN
--   x_complete_rec := p_met_tpl_dtl_rec;

--    OPEN c_complete;
--    FETCH c_complete INTO l_met_tpl_dtl_rec;
--    CLOSE c_complete;

   -- metric_template_detail_id
--    IF p_met_tpl_dtl_rec.metric_template_detail_id = FND_API.g_miss_num THEN
--       x_complete_rec.metric_template_detail_id := l_met_tpl_dtl_rec.metric_template_detail_id;
--    END IF;

   -- last_update_date
--    IF p_met_tpl_dtl_rec.last_update_date = FND_API.g_miss_date THEN
--       x_complete_rec.last_update_date := l_met_tpl_dtl_rec.last_update_date;
--    END IF;

   -- last_updated_by
--    IF p_met_tpl_dtl_rec.last_updated_by = FND_API.g_miss_num THEN
--       x_complete_rec.last_updated_by := l_met_tpl_dtl_rec.last_updated_by;
--    END IF;

   -- creation_date
--    IF p_met_tpl_dtl_rec.creation_date = FND_API.g_miss_date THEN
--       x_complete_rec.creation_date := l_met_tpl_dtl_rec.creation_date;
--    END IF;

   -- created_by
--    IF p_met_tpl_dtl_rec.created_by = FND_API.g_miss_num THEN
--       x_complete_rec.created_by := l_met_tpl_dtl_rec.created_by;
--    END IF;

   -- last_update_login
--    IF p_met_tpl_dtl_rec.last_update_login = FND_API.g_miss_num THEN
--       x_complete_rec.last_update_login := l_met_tpl_dtl_rec.last_update_login;
--    END IF;

   -- object_version_number
--    IF p_met_tpl_dtl_rec.object_version_number = FND_API.g_miss_num THEN
--       x_complete_rec.object_version_number := l_met_tpl_dtl_rec.object_version_number;
--    END IF;

   -- metric_tpl_header_id
   IF x_tar_met_tpl_dtl_rec.metric_tpl_header_id = FND_API.g_miss_num THEN
      x_tar_met_tpl_dtl_rec.metric_tpl_header_id := p_ref_met_tpl_dtl_rec.metric_tpl_header_id;
   END IF;

   -- metric_id
   IF x_tar_met_tpl_dtl_rec.metric_id = FND_API.g_miss_num THEN
      x_tar_met_tpl_dtl_rec.metric_id := p_ref_met_tpl_dtl_rec.metric_id;
   END IF;

   -- enabled_flag
   IF x_tar_met_tpl_dtl_rec.enabled_flag = FND_API.g_miss_char THEN
      x_tar_met_tpl_dtl_rec.enabled_flag := p_ref_met_tpl_dtl_rec.enabled_flag;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_met_tpl_dtl_Rec;


PROCEDURE Validate_met_tpl_dtl(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_met_tpl_dtl_rec            IN   met_tpl_dtl_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Met_Tpl_Dtl';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_met_tpl_dtl_rec  Ams_Met_Tpl_Dtl_Pvt.met_tpl_dtl_rec_type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT VALIDATE_Met_Tpl_Dtl_;

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
      Check_met_tpl_dtl_Items(
         p_met_tpl_dtl_rec        => p_met_tpl_dtl_rec,
         p_validation_mode   => p_validation_mode,
         x_return_status     => x_return_status
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

--    Complete_met_tpl_dtl_Rec(
--       p_met_tpl_dtl_rec        => p_met_tpl_dtl_rec,
--       x_complete_rec        => l_met_tpl_dtl_rec
--    );

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_met_tpl_dtl_Rec(
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_met_tpl_dtl_rec        => l_met_tpl_dtl_rec);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   Ams_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || ': START');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


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
     ROLLBACK TO VALIDATE_Met_Tpl_Dtl_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Met_Tpl_Dtl_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Met_Tpl_Dtl_;
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
END Validate_Met_Tpl_Dtl;


PROCEDURE Validate_met_tpl_dtl_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_met_tpl_dtl_rec            IN    met_tpl_dtl_rec_type
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

      Ams_Utility_Pvt.debug_message('PRIVATE API: Validate_met_tpl_dtl_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_met_tpl_dtl_Rec;

END Ams_Met_Tpl_Dtl_Pvt;

/
