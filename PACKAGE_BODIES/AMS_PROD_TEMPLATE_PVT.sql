--------------------------------------------------------
--  DDL for Package Body AMS_PROD_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PROD_TEMPLATE_PVT" as
/* $Header: amsvptmb.pls 115.8 2002/12/04 20:00:47 musman ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Prod_Template_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Prod_Template_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvptmb.pls';



-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Prod_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prod_template_rec               IN   prod_template_rec_type  := g_miss_prod_template_rec,
    x_template_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Prod_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_TEMPLATE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_PROD_TEMPLATES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_PROD_TEMPLATES_B
      WHERE TEMPLATE_ID = l_id;

   CURSOR c_get_prod_attr
   IS
   SELECT stp.parent_setup_attribute,
          stp.setup_attribute
   FROM  ams_setup_types stp
   WHERE stp.object_type = 'PTMP'
   AND stp.setup_attribute not in ('AMS_PROD_SUPP_SRV','AMS_PROD_WARRN','AMS_PROD_COV_TEMP'
                           ,'AMS_PROD_DUR_VAL','AMS_PROD_DUR_PER','AMS_CONTRACT_ITEM_TYPE')
                           --,'AMS_SUBSCRIPTION_DEPENDENCY')
   ORDER BY display_sequence_no;

   l_get_prod_attr c_get_prod_attr%ROWTYPE;

   CURSOR c_get_service_attr
   IS
   SELECT stp.parent_setup_attribute,
          stp.setup_attribute
   FROM  ams_setup_types stp
   WHERE stp.object_type = 'PTMP'
   AND parent_setup_attribute not in ('AMS_INVENTORY','AMS_BILL_OF_MATERIAL')
   AND setup_attribute not in ('AMS_PROD_RET','AMS_PROD_SHP','AMS_PROD_BACK_ORD','AMS_PROD_SRP','AMS_BILLING_TYPE','AMS_SUBSCRIPTION_DEPENDENCY','AMS_CONTRACT_ITEM_TYPE')
   ORDER BY display_sequence_no;

   l_get_service_attr c_get_service_attr%ROWTYPE;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Prod_Template_PVT;

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

   IF p_prod_template_rec.TEMPLATE_ID IS NULL
   OR p_prod_template_rec.TEMPLATE_ID = FND_API.g_miss_num
   THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_TEMPLATE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_TEMPLATE_ID);
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Prod_Template');
          END IF;

          -- Invoke validation procedures
          Validate_prod_template(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_prod_template_rec  =>  p_prod_template_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      INSERT INTO AMS_PROD_TEMPLATES_B(
           template_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login,
           product_service_flag
     ) VALUES (
           DECODE( l_template_id, FND_API.g_miss_num, NULL, l_template_id)
           ,SYSDATE
           ,fnd_global.user_id
           ,SYSDATE
           ,fnd_global.user_id
           ,l_object_version_number
           ,FND_GLOBAL.CONC_LOGIN_ID
           ,DECODE( p_prod_template_rec.product_service_flag, FND_API.g_miss_char, NULL, p_prod_template_rec.product_service_flag)
           );


      INSERT  INTO AMS_PROD_TEMPLATES_TL(
           template_id
           ,language
           ,source_lang
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,creation_date
           ,created_by
           ,template_name
           ,description
       )   SELECT
           DECODE( l_template_id, FND_API.g_miss_num, NULL, l_template_id),
           l.language_code,
           USERENV('LANG'),
           sysdate,
           FND_GLOBAL.user_id,
           FND_GLOBAL.conc_login_id,
           sysdate,
           FND_GLOBAL.user_id,
           DECODE( p_prod_template_rec.template_name, FND_API.g_miss_char, NULL, p_prod_template_rec.template_name),
           DECODE( p_prod_template_rec.description, FND_API.g_miss_char, NULL, p_prod_template_rec.description)
   FROM    fnd_languages l
   WHERE   l.installed_flag IN ('I','B')
   AND     NOT EXISTS(
                      SELECT NULL
                      FROM   AMS_PROD_TEMPLATES_TL t
                      WHERE  t.template_id = DECODE( l_template_id, FND_API.g_miss_num, NULL, l_template_id)
                      AND    t.language = l.language_code ) ;

          x_template_id := l_template_id;


   IF  p_prod_template_rec.product_service_flag= 'P'
   THEN

      OPEN  c_get_prod_attr;
         LOOP
            FETCH c_get_prod_attr INTO l_get_prod_attr;
            EXIT WHEN c_get_prod_attr%NOTFOUND;

            INSERT INTO ams_prod_template_attr
            (
              template_attribute_id
              ,template_id
              ,last_update_date
              ,last_updated_by
              ,creation_date
              ,created_by
              ,object_version_number
              ,last_update_login
              ,parent_attribute_code
              ,parent_select_all
              ,attribute_code
              ,default_flag
              ,editable_flag
              ,hide_flag
           ) VALUES
            (  ams_prod_template_attr_s.nextval,
                x_template_id,
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                1,
                FND_GLOBAL.CONC_LOGIN_ID,
                l_get_prod_attr.parent_setup_attribute,
                'Y',
                l_get_prod_attr.setup_attribute,
                'Y',
                'Y',
                'N') ;
         END LOOP;
      CLOSE c_get_prod_attr;

   ELSIF  p_prod_template_rec.product_service_flag= 'S'
   THEN
      OPEN  c_get_service_attr;
         LOOP
            FETCH c_get_service_attr INTO l_get_service_attr;
            EXIT WHEN c_get_service_attr%NOTFOUND;
            INSERT INTO ams_prod_template_attr
            (
               template_attribute_id
               ,template_id
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,object_version_number
               ,last_update_login
               ,parent_attribute_code
               ,parent_select_all
               ,attribute_code
               ,default_flag
               ,editable_flag
               ,hide_flag
             ) VALUES
             (ams_prod_template_attr_s.nextval,
                 x_template_id,
                 SYSDATE,
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.user_id,
                 1,
                 FND_GLOBAL.CONC_LOGIN_ID,
                 l_get_service_attr.parent_setup_attribute,
                 'Y',
                 l_get_service_attr.setup_attribute,
                 'Y',
                 'Y',
                 'N');
        END LOOP;
      CLOSE c_get_service_attr;
   END IF;


          /*
          SELECT ams_prod_template_attr_s.nextval,
              x_template_id,
              SYSDATE,
              fnd_global.user_id,
              SYSDATE,
              fnd_global.user_id,
              1,
              FND_GLOBAL.CONC_LOGIN_ID,
              stp.parent_setup_attribute,
              'N',
              stp.setup_attribute,
              'N',
              'N',
              'N'
        FROM  ams_setup_types stp
        WHERE stp.object_type = 'PTMP'
        AND parent_setup_attribute not in ('AMS_INVENTORY','AMS_BILL_OF_MATERIAL')
        AND setup_attribute not in ('AMS_PROD_RET','AMS_PROD_SHP','AMS_PROD_BACK_ORD','AMS_PROD_SRP','AMS_BILLING_TYPE') ;
        */

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
     ROLLBACK TO CREATE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Prod_Template_PVT;
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
End Create_Prod_Template;


PROCEDURE Update_Prod_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_prod_template_rec               IN    prod_template_rec_type
    )

 IS

  CURSOR c_get_prod_template(p_template_id NUMBER) IS
    SELECT *
    FROM  AMS_PROD_TEMPLATES_B
    WHERE template_id =p_template_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Prod_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_TEMPLATE_ID    NUMBER;
l_ref_prod_template_rec  c_get_Prod_Template%ROWTYPE ;
l_tar_prod_template_rec  AMS_Prod_Template_PVT.prod_template_rec_type := P_prod_template_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Prod_Template_PVT;

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
      OPEN c_get_Prod_Template( l_tar_prod_template_rec.template_id);

      FETCH c_get_Prod_Template INTO l_ref_prod_template_rec  ;

       If ( c_get_Prod_Template%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Prod_Template') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Prod_Template;
*/


      If (l_tar_prod_template_rec.object_version_number is NULL or
          l_tar_prod_template_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_prod_template_rec.object_version_number <> l_ref_prod_template_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Prod_Template') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Prod_Template');
          END IF;

          -- Invoke validation procedures
          Validate_prod_template(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_prod_template_rec  =>  p_prod_template_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Update AMS_PROD_TEMPLATES_B
      SET  template_id = DECODE( p_prod_template_rec.template_id, FND_API.g_miss_num, template_id, p_prod_template_rec.template_id),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           object_version_number = p_prod_template_rec.object_version_number +1,
           last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
           product_service_flag = DECODE(p_prod_template_rec.product_service_flag, FND_API.g_miss_char, product_service_flag, p_prod_template_rec.product_service_flag)
      WHERE TEMPLATE_ID =  p_prod_template_rec.template_id
      AND   object_version_number = p_prod_template_rec.object_version_number;

      If (SQL%NOTFOUND) then
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;


      UPDATE  AMS_PROD_TEMPLATES_TL
      SET template_name = DECODE( p_prod_template_rec.template_name, FND_API.g_miss_char, template_name, p_prod_template_rec.template_name)
      ,description   = DECODE(p_prod_template_rec.description,FND_API.g_miss_char,description,p_prod_template_rec.description)
      ,last_update_date = sysdate
      ,last_updated_by = fnd_global.user_id
      ,last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      ,source_lang = USERENV('LANG')
      WHERE  TEMPLATE_ID =  p_prod_template_rec.template_id
      AND    USERENV('LANG') IN (language, source_lang);

      If (SQL%NOTFOUND) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      End If;


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
     ROLLBACK TO UPDATE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Prod_Template_PVT;
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
End Update_Prod_Template;


PROCEDURE Delete_Prod_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_template_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Prod_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Prod_Template_PVT;

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
      /*
      IF p_template_id = 1000
      OR p_template_id = 1001
      THEN
      */
      IF p_template_id < 10000
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_CANNOT_DELETE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      DELETE FROM AMS_PROD_TEMPLATES_B
      WHERE TEMPLATE_ID = p_TEMPLATE_ID
      AND object_version_number = p_object_version_number;

      IF (SQL%NOTFOUND) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      DELETE FROM AMS_PROD_TEMPLATES_TL
      WHERE TEMPLATE_ID = p_TEMPLATE_ID;

      IF (SQL%NOTFOUND) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      DELETE FROM ams_prod_template_attr
      WHERE template_id = p_template_id;

      DELETE FROM  ams_templ_responsibility
      WHERE template_id = p_template_id;

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
     ROLLBACK TO DELETE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Prod_Template_PVT;
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
End Delete_Prod_Template;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Prod_Template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_template_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Prod_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_TEMPLATE_ID                  NUMBER;

CURSOR c_Prod_Template IS
   SELECT TEMPLATE_ID
   FROM AMS_PROD_TEMPLATES_B
   WHERE TEMPLATE_ID = p_TEMPLATE_ID
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
  OPEN c_Prod_Template;

  FETCH c_Prod_Template INTO l_TEMPLATE_ID;

  IF (c_Prod_Template%NOTFOUND) THEN
    CLOSE c_Prod_Template;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Prod_Template;

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
     ROLLBACK TO LOCK_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Prod_Template_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Prod_Template_PVT;
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
End Lock_Prod_Template;


PROCEDURE check_prod_template_uk_items(
    p_prod_template_rec               IN   prod_template_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS

l_valid_flag  VARCHAR2(1);

CURSOR c_check_unique(p_name  IN VARCHAR2)
   IS
   SELECT 'Y'
   FROM ams_prod_templates_tl
   WHERE template_name = p_name;


 CURSOR c_check_unik_upd(p_name    IN VARCHAR2
                        ,p_template_id IN NUMBER)
   IS
   SELECT 'Y'
   FROM ams_prod_templates_tl
   WHERE template_name = p_name
   AND template_id <> p_template_id;



BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PROD_TEMPLATES_B',
         'TEMPLATE_ID = ''' || p_prod_template_rec.TEMPLATE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PROD_TEMPLATES_B',
         'TEMPLATE_ID = ''' || p_prod_template_rec.TEMPLATE_ID ||
         ''' AND TEMPLATE_ID <> ' || p_prod_template_rec.TEMPLATE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_TEMPLATE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF  p_prod_template_rec.template_name IS NOT NULL
      AND p_prod_template_rec.template_name <> FND_API.g_miss_char
      THEN

         IF p_validation_mode =JTF_PLSQL_API.g_create
         THEN
            OPEN c_check_unique(p_prod_template_rec.template_name);
            FETCH c_check_unique INTO l_valid_flag;
            CLOSE c_check_unique;

         ELSIF p_validation_mode =JTF_PLSQL_API.g_update
         THEN
            OPEN c_check_unik_upd(p_prod_template_rec.template_name,p_prod_template_rec.template_id);
            FETCH c_check_unik_upd INTO l_valid_flag;
            CLOSE c_check_unik_upd;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_UTILITY_PVT.debug_message('l_valid_flag:'||l_valid_flag||' vd mode:'|| p_validation_mode||' g_create:'||JTF_PLSQL_API.g_create);

         END IF;

         IF l_valid_flag = 'Y'
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS','AMS_dup_name');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;

   END IF;


END check_prod_template_uk_items;

PROCEDURE check_prod_template_req_items(
    p_prod_template_rec               IN  prod_template_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;




      IF p_prod_template_rec.template_name = FND_API.g_miss_char
      OR p_prod_template_rec.template_name IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','TEMPLATE_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN

      IF p_prod_template_rec.template_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_prod_template_NO_template_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

END check_prod_template_req_items;

PROCEDURE check_prod_template_FK_items(
    p_prod_template_rec IN prod_template_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_prod_template_FK_items;

PROCEDURE check_template_lkup_items(
    p_prod_template_rec IN prod_template_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_template_lkup_items;

PROCEDURE Check_prod_template_Items (
    P_prod_template_rec     IN    prod_template_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_prod_template_uk_items(
      p_prod_template_rec => p_prod_template_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_prod_template_req_items(
      p_prod_template_rec => p_prod_template_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_prod_template_FK_items(
      p_prod_template_rec => p_prod_template_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_template_lkup_items(
      p_prod_template_rec => p_prod_template_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_prod_template_Items;



PROCEDURE Complete_prod_template_Rec (
   p_prod_template_rec IN prod_template_rec_type,
   x_complete_rec OUT NOCOPY prod_template_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_prod_templates_b
      WHERE template_id = p_prod_template_rec.template_id;
   l_prod_template_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_prod_template_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prod_template_rec;
   CLOSE c_complete;

   -- template_id
   IF p_prod_template_rec.template_id = FND_API.g_miss_num THEN
      x_complete_rec.template_id := l_prod_template_rec.template_id;
   END IF;

   -- last_update_date
   IF p_prod_template_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_prod_template_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_prod_template_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_prod_template_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_prod_template_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_prod_template_rec.creation_date;
   END IF;

   -- created_by
   IF p_prod_template_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_prod_template_rec.created_by;
   END IF;

   -- object_version_number
   IF p_prod_template_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_prod_template_rec.object_version_number;
   END IF;

   -- last_update_login
   IF p_prod_template_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_prod_template_rec.last_update_login;
   END IF;

   -- security_group_id
   IF p_prod_template_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_prod_template_rec.security_group_id;
   END IF;

   -- product_service_flag
   IF p_prod_template_rec.product_service_flag = FND_API.g_miss_char THEN
      x_complete_rec.product_service_flag := l_prod_template_rec.product_service_flag;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_prod_template_Rec;
PROCEDURE Validate_prod_template(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_prod_template_rec               IN   prod_template_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Prod_Template';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_prod_template_rec  AMS_Prod_Template_PVT.prod_template_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Prod_Template_;

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
              Check_prod_template_Items(
                 p_prod_template_rec        => p_prod_template_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_prod_template_Rec(
         p_prod_template_rec        => p_prod_template_rec,
         x_complete_rec        => l_prod_template_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_prod_template_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_prod_template_rec           =>    l_prod_template_rec);

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
     ROLLBACK TO VALIDATE_Prod_Template_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Prod_Template_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Prod_Template_;
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
End Validate_Prod_Template;


PROCEDURE Validate_prod_template_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_prod_template_rec               IN    prod_template_rec_type
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
END Validate_prod_template_Rec;

END AMS_Prod_Template_PVT;

/
