--------------------------------------------------------
--  DDL for Package Body AMS_COMPETITOR_PRODUCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COMPETITOR_PRODUCT_PVT" as
/* $Header: amsvcprb.pls 120.1 2005/08/04 08:24:57 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Ams_Competitor_Product_Pvt
-- Purpose
--
-- History
--   01-Oct-2001   musman   created
--   05-Nov-2001   musman   Commented out the reference to security_group_id
--   17-MAY-2002   abhola   removed g_user_id and g_login_id
--   10-Sep-2003   Musman     Added Changes reqd for interest type to category
--   04-Aug-2005   inanaiah  R12 change - added a DFF
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Ams_Competitor_Product_Pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcprb.pls';


-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_comp_prod_rec              IN   comp_prod_rec_type  := g_miss_comp_prod_type_rec ,
    x_competitor_product_id      OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ams_Comp_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_COMPETITOR_PRODUCT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_COMPETITOR_PRODUCTS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_COMPETITOR_PRODUCTS_B
      WHERE COMPETITOR_PRODUCT_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ams_Comp_Product_PVT;

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

   IF p_comp_prod_rec.COMPETITOR_PRODUCT_ID IS NULL
      OR
      p_comp_prod_rec.COMPETITOR_PRODUCT_ID = FND_API.g_miss_num
   THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_COMPETITOR_PRODUCT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_COMPETITOR_PRODUCT_ID);
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

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ams_Comp_Product');
          END IF;

          -- Invoke validation procedures
          Validate_comp_prod(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_comp_prod_rec  =>  p_comp_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(AMS_COMPETITOR_PRODUCTS_B_PKG.Insert_Row)
      AMS_COMPETITOR_PRODUCTS_B_PKG.Insert_Row(
          px_competitor_product_id  => l_competitor_product_id,
          px_object_version_number  => l_object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  =>  FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  =>  FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_competitor_party_id  => p_comp_prod_rec.competitor_party_id,
          p_competitor_product_code  => p_comp_prod_rec.competitor_product_code,
          p_interest_type_id  => p_comp_prod_rec.interest_type_id,
          p_inventory_item_id  => p_comp_prod_rec.inventory_item_id,
          p_organization_id  => p_comp_prod_rec.organization_id,
          p_comp_product_url  => p_comp_prod_rec.comp_product_url,
          p_original_system_ref  => p_comp_prod_rec.original_system_ref,
          --p_security_group_id  => p_comp_prod_rec.security_group_id,
          p_competitor_product_name => p_comp_prod_rec.competitor_product_name,
          p_description => p_comp_prod_rec.description,
          p_start_date => p_comp_prod_rec.start_date,
          p_end_date => p_comp_prod_rec.end_date
         ,p_category_id => p_comp_prod_rec.category_id
         ,p_category_set_id => p_comp_prod_rec.category_set_id
         , p_context                      => p_comp_prod_rec.context
         , p_attribute1                   => p_comp_prod_rec.attribute1
         , p_attribute2                   => p_comp_prod_rec.attribute2
         , p_attribute3                   => p_comp_prod_rec.attribute3
         , p_attribute4                   => p_comp_prod_rec.attribute4
         , p_attribute5                   => p_comp_prod_rec.attribute5
         , p_attribute6                   => p_comp_prod_rec.attribute6
         , p_attribute7                   => p_comp_prod_rec.attribute7
         , p_attribute8                   => p_comp_prod_rec.attribute8
         , p_attribute9                   => p_comp_prod_rec.attribute9
         , p_attribute10                   => p_comp_prod_rec.attribute10
         , p_attribute11                   => p_comp_prod_rec.attribute11
         , p_attribute12                   => p_comp_prod_rec.attribute12
         , p_attribute13                   => p_comp_prod_rec.attribute13
         , p_attribute14                   => p_comp_prod_rec.attribute14
         , p_attribute15                   => p_comp_prod_rec.attribute15
          );

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

      x_competitor_product_id := l_competitor_product_id;

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
     ROLLBACK TO CREATE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ams_Comp_Product_PVT;
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

End Create_Comp_Product;


PROCEDURE Update_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_comp_prod_rec               IN    comp_prod_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS



CURSOR c_get_ams_Comp_Product(competitor_product_id NUMBER) IS
    SELECT *
    FROM  AMS_COMPETITOR_PRODUCTS_B
    WHERE competitor_product_id = p_comp_prod_rec.competitor_product_id;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ams_Comp_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_COMPETITOR_PRODUCT_ID    NUMBER;
l_ref_comp_prod_rec  c_get_Ams_Comp_Product%ROWTYPE ;
l_tar_comp_prod_type_rec  Ams_Competitor_Product_Pvt.comp_prod_rec_type := p_comp_prod_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ams_Comp_Product_PVT;

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


      OPEN c_get_Ams_Comp_Product( l_tar_comp_prod_type_rec.competitor_product_id);
      FETCH c_get_Ams_Comp_Product INTO l_ref_comp_prod_rec  ;

       If ( c_get_Ams_Comp_Product%NOTFOUND) THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                p_token_name   => 'INFO',
                p_token_value  => 'Ams_Competitor_Product_Pvt') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ams_Comp_Product;


      If (l_tar_comp_prod_type_rec.object_version_number is NULL or
          l_tar_comp_prod_type_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_comp_prod_type_rec.object_version_number <> l_ref_comp_prod_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ams_Competitor_Product_Pvt') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_comp_prod');
          END IF;

          -- Invoke validation procedures
          Validate_comp_prod(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_comp_prod_rec  =>  p_comp_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Invoke table handler(AMS_COMPETITOR_PRODUCTS_B_PKG.Update_Row)
      AMS_COMPETITOR_PRODUCTS_B_PKG.Update_Row(
          p_competitor_product_id  => p_comp_prod_rec.competitor_product_id
        , p_object_version_number  => p_comp_prod_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  =>  FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  =>  FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_competitor_party_id  => p_comp_prod_rec.competitor_party_id,
          p_competitor_product_code  => p_comp_prod_rec.competitor_product_code,
          p_interest_type_id  => p_comp_prod_rec.interest_type_id,
          p_inventory_item_id  => p_comp_prod_rec.inventory_item_id,
          p_organization_id  => p_comp_prod_rec.organization_id,
          p_comp_product_url  => p_comp_prod_rec.comp_product_url,
          p_original_system_ref  => p_comp_prod_rec.original_system_ref,
          --p_security_group_id  => p_comp_prod_rec.security_group_id,
          p_competitor_product_name => p_comp_prod_rec.competitor_product_name,
          p_description => p_comp_prod_rec.description,
          p_start_date => p_comp_prod_rec.start_date,
          p_end_date => p_comp_prod_rec.end_date
         ,p_category_id => p_comp_prod_rec.category_id
         ,p_category_set_id => p_comp_prod_rec.category_set_id
         , p_context                      => p_comp_prod_rec.context
         , p_attribute1                   => p_comp_prod_rec.attribute1
         , p_attribute2                   => p_comp_prod_rec.attribute2
         , p_attribute3                   => p_comp_prod_rec.attribute3
         , p_attribute4                   => p_comp_prod_rec.attribute4
         , p_attribute5                   => p_comp_prod_rec.attribute5
         , p_attribute6                   => p_comp_prod_rec.attribute6
         , p_attribute7                   => p_comp_prod_rec.attribute7
         , p_attribute8                   => p_comp_prod_rec.attribute8
         , p_attribute9                   => p_comp_prod_rec.attribute9
         , p_attribute10                   => p_comp_prod_rec.attribute10
         , p_attribute11                   => p_comp_prod_rec.attribute11
         , p_attribute12                   => p_comp_prod_rec.attribute12
         , p_attribute13                   => p_comp_prod_rec.attribute13
         , p_attribute14                   => p_comp_prod_rec.attribute14
         , p_attribute15                   => p_comp_prod_rec.attribute15
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
     ROLLBACK TO UPDATE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ams_Comp_Product_PVT;
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

End Update_Comp_Product;


PROCEDURE Delete_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_competitor_product_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ams_Comp_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ams_Comp_Product_PVT;

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

      -- Invoke table handler(AMS_COMPETITOR_PRODUCTS_B_PKG.Delete_Row)
      AMS_COMPETITOR_PRODUCTS_B_PKG.Delete_Row(
          p_COMPETITOR_PRODUCT_ID  => p_COMPETITOR_PRODUCT_ID,
          p_Object_Version_number => p_object_version_number
          );
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
     ROLLBACK TO DELETE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ams_Comp_Product_PVT;
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
End Delete_Comp_Product;



-- Hint: Primary key needs to be returned.

PROCEDURE Lock_Comp_Product(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_competitor_product_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ams_Comp_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_COMPETITOR_PRODUCT_ID                  NUMBER;

CURSOR c_Ams_Comp_Product IS
   SELECT COMPETITOR_PRODUCT_ID
   FROM AMS_COMPETITOR_PRODUCTS_B
   WHERE COMPETITOR_PRODUCT_ID = p_COMPETITOR_PRODUCT_ID
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
  OPEN c_Ams_Comp_Product;

  FETCH c_Ams_Comp_Product INTO l_COMPETITOR_PRODUCT_ID;

  IF (c_Ams_Comp_Product%NOTFOUND) THEN
    CLOSE c_Ams_Comp_Product;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ams_Comp_Product;

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
     ROLLBACK TO LOCK_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ams_Comp_Product_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ams_Comp_Product_PVT;
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
End ;




PROCEDURE Complete_comp_prod_rec (
   p_comp_prod_rec IN comp_prod_rec_type,
   x_complete_rec OUT NOCOPY comp_prod_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_competitor_products_vl
      WHERE competitor_product_id = p_comp_prod_rec.competitor_product_id;
   l_comp_prod_rec_type_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_comp_prod_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_comp_prod_rec_type_rec;
   CLOSE c_complete;

   -- competitor_product_id
   IF p_comp_prod_rec.competitor_product_id = FND_API.g_miss_num THEN
      x_complete_rec.competitor_product_id := l_comp_prod_rec_type_rec.competitor_product_id;
   END IF;

   -- object_version_number
   IF p_comp_prod_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_comp_prod_rec_type_rec.object_version_number;
   END IF;

   -- last_update_date
   IF p_comp_prod_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_comp_prod_rec_type_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_comp_prod_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_comp_prod_rec_type_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_comp_prod_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_comp_prod_rec_type_rec.creation_date;
   END IF;

   -- created_by
   IF p_comp_prod_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_comp_prod_rec_type_rec.created_by;
   END IF;

   -- last_update_login
   IF p_comp_prod_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_comp_prod_rec_type_rec.last_update_login;
   END IF;

   -- competitor_party_id
   IF p_comp_prod_rec.competitor_party_id = FND_API.g_miss_num THEN
      x_complete_rec.competitor_party_id := l_comp_prod_rec_type_rec.competitor_party_id;
   END IF;

   -- competitor_product_code
   IF p_comp_prod_rec.competitor_product_code = FND_API.g_miss_char THEN
      x_complete_rec.competitor_product_code := l_comp_prod_rec_type_rec.competitor_product_code;
   END IF;

   -- interest_type_id
   IF p_comp_prod_rec.interest_type_id = FND_API.g_miss_num THEN
      x_complete_rec.interest_type_id := l_comp_prod_rec_type_rec.interest_type_id;
   END IF;

   -- inventory_item_id
   IF p_comp_prod_rec.inventory_item_id = FND_API.g_miss_num THEN
      x_complete_rec.inventory_item_id := l_comp_prod_rec_type_rec.inventory_item_id;
   END IF;

   -- organization_id
   IF p_comp_prod_rec.organization_id = FND_API.g_miss_num THEN
      x_complete_rec.organization_id := l_comp_prod_rec_type_rec.organization_id;
   END IF;

   -- comp_product_url
   IF p_comp_prod_rec.comp_product_url = FND_API.g_miss_char THEN
      x_complete_rec.comp_product_url := l_comp_prod_rec_type_rec.comp_product_url;
   END IF;

   -- original_system_ref
   IF p_comp_prod_rec.original_system_ref = FND_API.g_miss_char THEN
      x_complete_rec.original_system_ref := l_comp_prod_rec_type_rec.original_system_ref;
   END IF;
/*
   -- security_group_id
   IF p_comp_prod_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_comp_prod_rec_type_rec.security_group_id;
   END IF;
*/
      -- competitor_product_name
   IF p_comp_prod_rec.competitor_product_name = FND_API.g_miss_char THEN
      x_complete_rec.competitor_product_name := l_comp_prod_rec_type_rec.competitor_product_name;
   END IF;

   -- description
   IF p_comp_prod_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_comp_prod_rec_type_rec.description;
   END IF;

   IF p_comp_prod_rec.start_date = FND_API.g_miss_date THEN
      x_complete_rec.start_date := l_comp_prod_rec_type_rec.start_date;
   END IF;

   IF p_comp_prod_rec.end_date = FND_API.g_miss_date THEN
      x_complete_rec.end_date := l_comp_prod_rec_type_rec.end_date;
   END IF;

   IF p_comp_prod_rec.category_id = FND_API.g_miss_NUM THEN
      x_complete_rec.category_id := l_comp_prod_rec_type_rec.category_id;
   END IF;

   IF p_comp_prod_rec.category_set_id = FND_API.g_miss_NUM THEN
      x_complete_rec.category_set_id := l_comp_prod_rec_type_rec.category_set_id;
   END IF;

   -- to handle any business specific requirements.
END Complete_comp_prod_rec;

PROCEDURE check_comp_prod_uk_items(
    p_comp_prod_rec               IN   comp_prod_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create  THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
                                       'AMS_COMPETITOR_PRODUCTS_B',
                                       'competitor_product_id = '|| p_comp_prod_rec.competitor_product_id
                                        );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_COMPETITOR_PRODUCTS_B',
         'competitor_product_id = ''' || p_comp_prod_rec.competitor_product_id ||
         ''' AND competitor_product_id <> ' || p_comp_prod_rec.competitor_product_id
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_competitor_product_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;



END check_comp_prod_uk_items;

PROCEDURE check_comp_Prod_req_items(
    p_comp_Prod_rec               IN  comp_Prod_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON)
   THEN
      AMS_UTILITY_PVT.debug_message('INSIDE THE check_comp_Prod_req_items and p_validation_mode is:'||p_validation_mode);
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_comp_Prod_rec.competitor_party_id = FND_API.g_miss_num OR p_comp_Prod_rec.competitor_party_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_competitor_party_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_comp_Prod_rec.competitor_product_name = FND_API.g_miss_char OR p_comp_Prod_rec.competitor_product_name IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_competitor_product_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF (AMS_DEBUG_HIGH_ON)
      THEN
         AMS_UTILITY_PVT.debug_message('before error msf');
         IF( p_comp_Prod_rec.inventory_item_id=FND_API.g_miss_num
         AND p_comp_prod_rec.category_id=FND_API.g_miss_num)
         THEN
            AMS_UTILITY_PVT.debug_message('inv_id and cat id is g_miss num');
         ELSE
            AMS_UTILITY_PVT.debug_message(' in the else part before erroring out');
            AMS_UTILITY_PVT.debug_message('p_comp_Prod_rec.inventory_item_id:'||p_comp_Prod_rec.inventory_item_id);
            AMS_UTILITY_PVT.debug_message('p_comp_Prod_rec.category_id:'||p_comp_Prod_rec.category_id);
         END IF;
      END IF;

      IF ((p_comp_Prod_rec.inventory_item_id=FND_API.g_miss_num AND p_comp_prod_rec.category_id=FND_API.g_miss_num)
           OR
         ((p_comp_Prod_rec.inventory_item_id IS NULL) AND (p_comp_prod_rec.category_id IS NULL)))
      THEN
           AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_INV_AND_CAT_NULL');
           x_return_status := FND_API.g_ret_sts_error;
       RETURN;
      END IF;
   ELSE

      IF p_comp_Prod_rec.competitor_product_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_competitor_product_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

        IF ((  p_comp_Prod_rec.inventory_item_id IS NULL ) AND (p_comp_prod_rec.category_id IS NULL)) --interest_type_id
        THEN
             AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_INV_AND_CAT_NULL');
             x_return_status := FND_API.g_ret_sts_error;
         RETURN;
        END IF;

      IF p_comp_Prod_rec.competitor_party_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_competitor_party_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_comp_Prod_rec.competitor_product_name IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_competitor_product_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      /***

      IF p_comp_Prod_rec.inventory_item_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_inventory_item_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_comp_Prod_rec.organization_id IS NULL THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_comp_Prod_NO_organization_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      ***/


   END IF;

END  check_comp_Prod_req_items;

PROCEDURE check_comp_prod_FK_items(
    p_comp_prod_rec IN comp_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   ---  checking the inventory_item_id
   IF p_comp_prod_rec.inventory_item_id <> FND_API.g_miss_num
   AND p_comp_prod_rec.inventory_item_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'mtl_system_items_b',
            'inventory_item_id',
            p_comp_prod_rec.inventory_item_id ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_PCMP_BAD_ITEM_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ---  checking the organization_id
   IF p_comp_prod_rec.organization_id <> FND_API.G_MISS_NUM
   AND p_comp_prod_rec.organization_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
                      'mtl_system_items_b'
                      ,'organization_id'
                      ,p_comp_prod_rec.organization_id) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_PCMP_BAD_ORG_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- checking the  competitor_party_id
   IF p_comp_prod_rec.competitor_party_id <> FND_API.g_miss_num
   AND p_comp_prod_rec.competitor_party_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
                      'hz_parties'
                      ,'party_id '
                      ,p_comp_prod_rec.competitor_party_id) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_PCMP_BAD_PARTY_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
/*
   -- checking the interest_Type_id
   IF p_comp_prod_rec.interest_type_id <> FND_API.G_MISS_NUM
   AND p_comp_prod_rec.interest_type_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
                      'as_interest_types_v'
                      ,'interest_type_id'
                      ,p_comp_prod_rec.interest_type_id) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_PCMP_BAD_INTEREST_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
END check_comp_prod_FK_items;

PROCEDURE Check_comp_prod_Items (
    p_comp_prod_rec     IN    comp_prod_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Check_Comp_prod_Items - is first the return status '||x_return_status);
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_comp_prod_uk_items(
      p_comp_prod_rec => p_comp_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('Check_Comp_prod_Items - return status  after  uk_items :'||x_return_status);
    END IF;

   check_comp_prod_req_items(
      p_comp_prod_rec => p_comp_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_UTILITY_PVT.debug_message('Check_Comp_prod_Items - return status  after  reg_items :'||x_return_status);

    END IF;
   -- Check Items Foreign Keys API calls

   check_comp_prod_FK_items(
      p_comp_prod_rec => p_comp_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Check_Comp_prod_Items - is sucess the return status '||x_return_status);

   END IF;

END Check_Comp_prod_Items;


PROCEDURE Validate_comp_prod_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_comp_prod_rec              IN    comp_prod_rec_type
    )
IS

    l_api_name varchar2(30) := 'Validate_comp_prod_rec';
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
   IF(p_comp_prod_rec.start_date > p_comp_prod_rec.end_date)
   THEN
      Ams_Utility_Pvt.debug_message('The End date is greater than Start date');
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
             Fnd_Message.set_name('AMS', 'AMS_DATE_FROM_AFTER_DATE_TO');
             Fnd_Msg_Pub.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF; -- (p_agenda_rec.start_date_time > p_agenda_rec.end_date_time)


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_comp_prod_rec;

PROCEDURE Validate_comp_prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN VARCHAR2 := JTF_PLSQL_API.g_create,
    p_comp_prod_rec               IN   comp_prod_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(50) := 'Validate_Ams_Comp_Product';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_comp_prod_rec_type_rec  Ams_Competitor_Product_Pvt.comp_prod_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ams_Comp_Product_;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


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
              Check_comp_prod_Items(
                 p_comp_prod_rec        => p_comp_prod_rec,
                 p_validation_mode   => p_validation_mode, --JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_comp_prod_rec(
         p_comp_prod_rec        => p_comp_prod_rec,
         x_complete_rec        => l_comp_prod_rec_type_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_comp_prod_rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_comp_prod_rec          => l_comp_prod_rec_type_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
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
     ROLLBACK TO VALIDATE_Ams_Comp_Product_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ams_Comp_Product_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ams_Comp_Product_;
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
End Validate_comp_prod;

End Ams_Competitor_Product_Pvt;

/
