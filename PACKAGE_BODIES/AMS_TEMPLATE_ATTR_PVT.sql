--------------------------------------------------------
--  DDL for Package Body AMS_TEMPLATE_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TEMPLATE_ATTR_PVT" as
/* $Header: amsvpatb.pls 115.8 2004/05/06 00:18:52 musman ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Template_Attr_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Template_Attr_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvpatb.pls';


-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Template_Attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_template_attr_rec               IN   template_attr_rec_type  := g_miss_template_attr_rec,
    x_template_attribute_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Template_Attr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_TEMPLATE_ATTRIBUTE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_PROD_TEMPLATE_ATTR_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_PROD_TEMPLATE_ATTR
      WHERE TEMPLATE_ATTRIBUTE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Template_Attr_PVT;

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

   IF p_template_attr_rec.TEMPLATE_ATTRIBUTE_ID IS NULL OR p_template_attr_rec.TEMPLATE_ATTRIBUTE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_TEMPLATE_ATTRIBUTE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_TEMPLATE_ATTRIBUTE_ID);
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Template_Attr');
          END IF;

          -- Invoke validation procedures
          Validate_template_attr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_template_attr_rec  =>  p_template_attr_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      INSERT INTO AMS_PROD_TEMPLATE_ATTR(
           template_attribute_id,
           template_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           object_version_number,
           last_update_login,
           parent_attribute_code,
           parent_select_all,
           attribute_code,
           default_flag,
           editable_flag,
           hide_flag
      ) VALUES (
           DECODE( l_template_attribute_id, FND_API.g_miss_num, NULL, l_template_attribute_id),
           DECODE( p_template_attr_rec.template_id, FND_API.g_miss_num, NULL, p_template_attr_rec.template_id),
           sysdate,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           l_object_version_number,
           FND_GLOBAL.CONC_LOGIN_ID,
           DECODE( p_template_attr_rec.parent_attribute_code, FND_API.g_miss_char, NULL, p_template_attr_rec.parent_attribute_code),
           DECODE( p_template_attr_rec.parent_select_all, FND_API.g_miss_char, NULL, p_template_attr_rec.parent_select_all),
           DECODE( p_template_attr_rec.attribute_code, FND_API.g_miss_char, NULL, p_template_attr_rec.attribute_code),
           DECODE( p_template_attr_rec.default_flag, FND_API.g_miss_char, NULL, p_template_attr_rec.default_flag),
           DECODE( p_template_attr_rec.editable_flag, FND_API.g_miss_char, NULL, p_template_attr_rec.editable_flag),
           DECODE( p_template_attr_rec.hide_flag, FND_API.g_miss_char, NULL, p_template_attr_rec.hide_flag));

          x_template_attribute_id := l_template_attribute_id ;
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
     ROLLBACK TO CREATE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Template_Attr_PVT;
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
End Create_Template_Attr;


PROCEDURE Update_Template_Attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_template_attr_rec          IN    template_attr_rec_type
    )

 IS

CURSOR c_get_template_attr(p_template_attribute_id NUMBER) IS
    SELECT *
    FROM  AMS_PROD_TEMPLATE_ATTR
    WHERE template_attribute_id = p_template_attribute_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Template_Attr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_TEMPLATE_ATTRIBUTE_ID    NUMBER;
l_ref_template_attr_rec  c_get_Template_Attr%ROWTYPE ;
l_tar_template_attr_rec  AMS_Template_Attr_PVT.template_attr_rec_type := P_template_attr_rec;
l_rowid  ROWID;

  l_template_attr_rec   template_attr_rec_Type := p_template_attr_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Template_Attr_PVT;

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
      OPEN c_get_Template_Attr( l_tar_template_attr_rec.template_attribute_id);

      FETCH c_get_Template_Attr INTO l_ref_template_attr_rec  ;

       If ( c_get_Template_Attr%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Template_Attr') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Template_Attr;
*/


      If (l_tar_template_attr_rec.object_version_number is NULL or
          l_tar_template_attr_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_template_attr_rec.object_version_number <> l_ref_template_attr_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Template_Attr') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Template_Attr');
          END IF;

          -- Invoke validation procedures
          Validate_template_attr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_template_attr_rec  =>  l_template_attr_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message(' IN UPDATE API VALUE FOR DeFAULT FLAG IS :'||l_template_attr_rec.default_flag);
      END IF;

      /*  If select all flag is "Y" then defaulting the default,editable flag to "Y" */
      --IF l_template_attr_rec.parent_select_all ='Y'
      --THEN
      -- l_template_attr_rec.editable_flag := 'Y';
      -- l_template_attr_rec.default_flag := 'Y';
      --END IF;


   Update AMS_PROD_TEMPLATE_ATTR
   SET template_attribute_id = DECODE( l_template_attr_rec.template_attribute_id, FND_API.g_miss_num, template_attribute_id, l_template_attr_rec.template_attribute_id),
          template_id = DECODE( l_template_attr_rec.template_id, FND_API.g_miss_num, template_id, l_template_attr_rec.template_id),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          object_version_number = l_template_attr_rec.object_version_number + 1,
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID,
          parent_attribute_code = DECODE( l_template_attr_rec.parent_attribute_code, FND_API.g_miss_char, parent_attribute_code, l_template_attr_rec.parent_attribute_code),
          --parent_select_all = DECODE( l_template_attr_rec.parent_select_all, FND_API.g_miss_char, 'N', l_template_attr_rec.parent_select_all),
          attribute_code = DECODE( l_template_attr_rec.attribute_code, FND_API.g_miss_char, attribute_code, l_template_attr_rec.attribute_code),
          default_flag = DECODE( l_template_attr_rec.default_flag, FND_API.g_miss_char,'N', l_template_attr_rec.default_flag),
          editable_flag = DECODE( l_template_attr_rec.editable_flag, FND_API.g_miss_char, 'N', l_template_attr_rec.editable_flag),
          hide_flag = DECODE( l_template_attr_rec.hide_flag, FND_API.g_miss_char, 'N', l_template_attr_rec.hide_flag)
   WHERE TEMPLATE_ATTRIBUTE_ID = l_template_attr_rec.TEMPLATE_ATTRIBUTE_ID
   AND   object_version_number = l_template_attr_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (AMS_DEBUG_HIGH_ON)
   THEN
      AMS_UTILITY_PVT.debug_message(' l_template_attr_rec.attribute_code:' ||l_template_attr_rec.attribute_code);
      AMS_UTILITY_PVT.debug_message(' l_template_attr_rec.parent_select_all:' ||l_template_attr_rec.parent_select_all);
      AMS_UTILITY_PVT.debug_message(' l_template_attr_rec.parent_attribute_code:' ||l_template_attr_rec.parent_attribute_code);
      AMS_UTILITY_PVT.debug_message(' l_template_attr_rec.template_id:' ||l_template_attr_rec.template_id);
   END IF;

   IF (l_template_attr_rec.attribute_code = 'AMS_PROD_INV_ITM'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_BOA'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_COST'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_COLL_ITM'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_CUST_O'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_INV'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_SRP'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_ORDWB'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_DEFTR'
   OR l_template_attr_rec.attribute_code = 'AMS_PROD_ORDWB')
   THEN

      IF l_template_attr_rec.parent_select_all = FND_API.G_MISS_CHAR
      THEN
         l_template_attr_rec.parent_select_all := 'N';
      END IF;

      -- bug 3544835 fix start
      -- standard who columns should be also modified ,so that the changes
      -- in the seeded template done by the user,doesn't gets overwritten by the ldts

      UPDATE ams_prod_template_attr
      SET parent_select_all = l_template_attr_rec.parent_select_all
         , last_update_date = sysdate
         , last_updated_by = fnd_global.user_id
         , last_update_login = FND_GLOBAL.CONC_LOGIN_ID
         --, object_version_number = object_version_number + 1
      WHERE template_id = l_template_attr_rec.template_id
      AND parent_attribute_code = l_template_attr_rec.parent_attribute_code;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('AFTER UPDATe for l_template_attr_rec.parent_select_all :'||l_template_attr_rec.parent_select_all );

      END IF;
   END IF;

   --x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;

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
     ROLLBACK TO UPDATE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Template_Attr_PVT;
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
End Update_Template_Attr;


PROCEDURE Delete_Template_Attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_template_attribute_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Template_Attr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Template_Attr_PVT;

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


      DELETE FROM AMS_PROD_TEMPLATE_ATTR
      WHERE TEMPLATE_ATTRIBUTE_ID = p_TEMPLATE_ATTRIBUTE_ID;

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
     ROLLBACK TO DELETE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Template_Attr_PVT;
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
End Delete_Template_Attr;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Template_Attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_template_attribute_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Template_Attr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_TEMPLATE_ATTRIBUTE_ID                  NUMBER;

CURSOR c_Template_Attr IS
   SELECT TEMPLATE_ATTRIBUTE_ID
   FROM AMS_PROD_TEMPLATE_ATTR
   WHERE TEMPLATE_ATTRIBUTE_ID = p_TEMPLATE_ATTRIBUTE_ID
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
  OPEN c_Template_Attr;

  FETCH c_Template_Attr INTO l_TEMPLATE_ATTRIBUTE_ID;

  IF (c_Template_Attr%NOTFOUND) THEN
    CLOSE c_Template_Attr;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Template_Attr;

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
     ROLLBACK TO LOCK_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Template_Attr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Template_Attr_PVT;
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
End Lock_Template_Attr;


PROCEDURE check_template_attr_uk_items(
    p_template_attr_rec               IN   template_attr_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PROD_TEMPLATE_ATTR',
         'TEMPLATE_ATTRIBUTE_ID = ''' || p_template_attr_rec.TEMPLATE_ATTRIBUTE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PROD_TEMPLATE_ATTR',
         'TEMPLATE_ATTRIBUTE_ID = ''' || p_template_attr_rec.TEMPLATE_ATTRIBUTE_ID ||
         ''' AND TEMPLATE_ATTRIBUTE_ID <> ' || p_template_attr_rec.TEMPLATE_ATTRIBUTE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_TEMPLATE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_template_attr_uk_items;

PROCEDURE check_template_attr_req_items(
    p_template_attr_rec               IN  template_attr_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_template_attr_rec.template_id = FND_API.g_miss_num OR p_template_attr_rec.template_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','TEMPLATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE

      IF p_template_attr_rec.template_attribute_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_template_attr_NO_template_attribute_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_template_attr_rec.template_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_template_attr_NO_template_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
/*
      IF (p_template_attr_rec.parent_select_all = 'Y'
      AND(( p_template_attr_rec.editable_flag = 'N')
       OR (p_template_attr_rec.default_flag = 'N')))
      THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_EDIT_SELECT_DEF_ERROR');
             FND_MSG_PUB.Add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
*/

   END IF;

END check_template_attr_req_items;

PROCEDURE check_template_attr_FK_items(
    p_template_attr_rec IN template_attr_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_template_attr_FK_items;

PROCEDURE check_template_attr_Lkup_items(
    p_template_attr_rec IN template_attr_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_template_attr_Lkup_items;

PROCEDURE Check_template_attr_Items (
    P_template_attr_rec     IN    template_attr_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_template_attr_uk_items(
      p_template_attr_rec => p_template_attr_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_template_attr_req_items(
      p_template_attr_rec => p_template_attr_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_template_attr_FK_items(
      p_template_attr_rec => p_template_attr_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_template_attr_Lkup_items(
      p_template_attr_rec => p_template_attr_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_template_attr_Items;



PROCEDURE Complete_template_attr_Rec (
   p_template_attr_rec IN template_attr_rec_type,
   x_complete_rec OUT NOCOPY template_attr_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_prod_template_attr
      WHERE template_attribute_id = p_template_attr_rec.template_attribute_id;
   l_template_attr_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_template_attr_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_template_attr_rec;
   CLOSE c_complete;

   -- template_attribute_id
   IF p_template_attr_rec.template_attribute_id = FND_API.g_miss_num THEN
      x_complete_rec.template_attribute_id := l_template_attr_rec.template_attribute_id;
   END IF;

   -- template_id
   IF p_template_attr_rec.template_id = FND_API.g_miss_num THEN
      x_complete_rec.template_id := l_template_attr_rec.template_id;
   END IF;

   -- last_update_date
   IF p_template_attr_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_template_attr_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_template_attr_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_template_attr_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_template_attr_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_template_attr_rec.creation_date;
   END IF;

   -- created_by
   IF p_template_attr_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_template_attr_rec.created_by;
   END IF;

   -- object_version_number
   IF p_template_attr_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_template_attr_rec.object_version_number;
   END IF;

   -- last_update_login
   IF p_template_attr_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_template_attr_rec.last_update_login;
   END IF;

   -- security_group_id
   IF p_template_attr_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_template_attr_rec.security_group_id;
   END IF;

   -- parent_attribute_code
   IF p_template_attr_rec.parent_attribute_code = FND_API.g_miss_char THEN
      x_complete_rec.parent_attribute_code := l_template_attr_rec.parent_attribute_code;
   END IF;

   -- parent_select_all
   IF p_template_attr_rec.parent_select_all = FND_API.g_miss_char THEN
      x_complete_rec.parent_select_all := l_template_attr_rec.parent_select_all;
   END IF;

   -- attribute_code
   IF p_template_attr_rec.attribute_code = FND_API.g_miss_char THEN
      x_complete_rec.attribute_code := l_template_attr_rec.attribute_code;
   END IF;

   -- default_flag
   IF p_template_attr_rec.default_flag = FND_API.g_miss_char THEN
      x_complete_rec.default_flag := l_template_attr_rec.default_flag;
   END IF;

   -- editable_flag
   IF p_template_attr_rec.editable_flag = FND_API.g_miss_char THEN
      x_complete_rec.editable_flag := l_template_attr_rec.editable_flag;
   END IF;

   -- hide_flag
   IF p_template_attr_rec.hide_flag = FND_API.g_miss_char THEN
      x_complete_rec.hide_flag := l_template_attr_rec.hide_flag;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_template_attr_Rec;
PROCEDURE Validate_template_attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_template_attr_rec               IN   template_attr_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Template_Attr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_template_attr_rec  AMS_Template_Attr_PVT.template_attr_rec_type;

 BEGIN

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Template_Attr_;

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
              Check_template_attr_Items(
                 p_template_attr_rec        => p_template_attr_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_template_attr_Rec(
         p_template_attr_rec        => p_template_attr_rec,
         x_complete_rec        => l_template_attr_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_template_attr_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_template_attr_rec           =>    l_template_attr_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end and the return status is '||x_return_status);
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
     ROLLBACK TO VALIDATE_Template_Attr_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Template_Attr_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Template_Attr_;
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
End Validate_Template_Attr;


PROCEDURE Validate_template_attr_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_template_attr_rec               IN    template_attr_rec_type
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
END Validate_template_attr_Rec;

END AMS_Template_Attr_PVT;

/
