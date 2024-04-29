--------------------------------------------------------
--  DDL for Package Body OZF_ADJ_NEW_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ADJ_NEW_PROD_PVT" as
/* $Header: ozfvanpb.pls 120.1 2006/03/30 13:52:58 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Adj_New_Prod_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Adj_New_Prod_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvanpb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Adj_New_Prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_adj_new_prod_rec               IN   adj_new_prod_rec_type  := g_miss_adj_new_prod_rec,
    x_offer_adj_new_product_id       OUT NOCOPY NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Adj_New_Prod';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := NULL;
   l_OFFER_ADJ_NEW_PRODUCT_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT OZF_OFFER_ADJ_NEW_PRODUCTS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_ADJ_NEW_PRODUCTS
      WHERE OFFER_ADJ_NEW_PRODUCT_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Adj_New_Prod_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_adj_new_prod_rec.OFFER_ADJ_NEW_PRODUCT_ID IS NULL OR p_adj_new_prod_rec.OFFER_ADJ_NEW_PRODUCT_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ADJ_NEW_PRODUCT_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ADJ_NEW_PRODUCT_ID);
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
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Adj_New_Prod');

          -- Invoke validation procedures
          Validate_adj_new_prod(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_create,
            p_adj_new_prod_rec  =>  p_adj_new_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Insert_Row)
      OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Insert_Row(
          px_offer_adj_new_product_id  => l_offer_adj_new_product_id,
          p_offer_adj_new_line_id  => p_adj_new_prod_rec.offer_adj_new_line_id,
          p_offer_adjustment_id    => p_adj_new_prod_rec.offer_adjustment_id,
          p_product_context  => p_adj_new_prod_rec.product_context,
          p_product_attribute  => p_adj_new_prod_rec.product_attribute,
          p_product_attr_value  => p_adj_new_prod_rec.product_attr_value,
          p_excluder_flag  => p_adj_new_prod_rec.excluder_flag,
          p_uom_code  => p_adj_new_prod_rec.uom_code,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

     x_offer_adj_new_product_id:= l_offer_adj_new_product_id;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Adj_New_Prod_PVT;
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
End Create_Adj_New_Prod;


PROCEDURE Update_Adj_New_Prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_adj_new_prod_rec               IN    adj_new_prod_rec_type,
    x_object_version_number      OUT NOCOPY NUMBER
    )

 IS
CURSOR c_get_adj_new_prod(cp_offerAdjNewProductId NUMBER, cp_objectVersionNumber NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_ADJ_NEW_PRODUCTS
    WHERE offer_adj_new_product_id = cp_offerAdjNewProductId
    AND object_version_number = cp_objectVersionNumber;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Adj_New_Prod';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_OFFER_ADJ_NEW_PRODUCT_ID    NUMBER;
l_ref_adj_new_prod_rec  c_get_Adj_New_Prod%ROWTYPE ;
l_tar_adj_new_prod_rec  OZF_Adj_New_Prod_PVT.adj_new_prod_rec_type := P_adj_new_prod_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Adj_New_Prod_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      OPEN c_get_Adj_New_Prod( l_tar_adj_new_prod_rec.offer_adj_new_product_id , l_tar_adj_new_prod_rec.object_version_number);
      FETCH c_get_Adj_New_Prod INTO l_ref_adj_new_prod_rec  ;
       If ( c_get_Adj_New_Prod%NOTFOUND) THEN
                OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                                p_token_name   => 'INFO',
                                                p_token_value  => 'Adj_New_Prod') ;
                RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Adj_New_Prod;

      If (l_tar_adj_new_prod_rec.object_version_number is NULL or
          l_tar_adj_new_prod_rec.object_version_number = FND_API.G_MISS_NUM ) Then
                OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                                p_token_name   => 'COLUMN',
                                                p_token_value  => 'Last_Update_Date') ;
                raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_adj_new_prod_rec.object_version_number <> l_ref_adj_new_prod_rec.object_version_number) Then
                OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                                p_token_name   => 'INFO',
                                                p_token_value  => 'Adj_New_Prod') ;
                raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Adj_New_Prod');
          -- Invoke validation procedures
          Validate_adj_new_prod(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_update,
            p_adj_new_prod_rec  =>  p_adj_new_prod_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Update_Row)
      OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Update_Row(
          p_offer_adj_new_product_id  => p_adj_new_prod_rec.offer_adj_new_product_id,
          p_offer_adj_new_line_id  => p_adj_new_prod_rec.offer_adj_new_line_id,
          p_offer_adjustment_id     => p_adj_new_prod_rec.offer_adjustment_id,
          p_product_context  => p_adj_new_prod_rec.product_context,
          p_product_attribute  => p_adj_new_prod_rec.product_attribute,
          p_product_attr_value  => p_adj_new_prod_rec.product_attr_value,
          p_excluder_flag  => p_adj_new_prod_rec.excluder_flag,
          p_uom_code  => p_adj_new_prod_rec.uom_code,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_adj_new_prod_rec.object_version_number);
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
        x_return_status := FND_API.g_ret_sts_error;
        OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Adj_New_Prod_PVT;
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
End Update_Adj_New_Prod;


PROCEDURE Delete_Adj_New_Prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_offer_adj_new_product_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Adj_New_Prod';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Adj_New_Prod_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      -- Invoke table handler(OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Delete_Row)
      OZF_OFFER_ADJ_NEW_PRODUCTS_PKG.Delete_Row(
          p_OFFER_ADJ_NEW_PRODUCT_ID  => p_OFFER_ADJ_NEW_PRODUCT_ID);
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Adj_New_Prod_PVT;
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
End Delete_Adj_New_Prod;
-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Adj_New_Prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_offer_adj_new_product_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Adj_New_Prod';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_OFFER_ADJ_NEW_PRODUCT_ID                  NUMBER;

CURSOR c_Adj_New_Prod IS
   SELECT OFFER_ADJ_NEW_PRODUCT_ID
   FROM OZF_OFFER_ADJ_NEW_PRODUCTS
   WHERE OFFER_ADJ_NEW_PRODUCT_ID = p_OFFER_ADJ_NEW_PRODUCT_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  OZF_UTILITY_PVT.debug_message(l_full_name||': start');
  OPEN c_Adj_New_Prod;

  FETCH c_Adj_New_Prod INTO l_OFFER_ADJ_NEW_PRODUCT_ID;

  IF (c_Adj_New_Prod%NOTFOUND) THEN
    CLOSE c_Adj_New_Prod;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Adj_New_Prod;
 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_UTILITY_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Adj_New_Prod_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Adj_New_Prod_PVT;
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
End Lock_Adj_New_Prod;


PROCEDURE check_adj_new_prod_uk_items(
    p_adj_new_prod_rec               IN   adj_new_prod_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_UTILITY_PVT.check_uniqueness(
         'OZF_OFFER_ADJ_NEW_PRODUCTS',
         'OFFER_ADJ_NEW_PRODUCT_ID = ''' || p_adj_new_prod_rec.OFFER_ADJ_NEW_PRODUCT_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_UTILITY_PVT.check_uniqueness(
         'OZF_OFFER_ADJ_NEW_PRODUCTS',
         'OFFER_ADJ_NEW_PRODUCT_ID = ''' || p_adj_new_prod_rec.OFFER_ADJ_NEW_PRODUCT_ID ||
         ''' AND OFFER_ADJ_NEW_PRODUCT_ID <> ' || p_adj_new_prod_rec.OFFER_ADJ_NEW_PRODUCT_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_OFFER_ADJ_NEW_PRODUCT_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_adj_new_prod_uk_items;

PROCEDURE check_adj_new_prod_req_items(
    p_adj_new_prod_rec               IN  adj_new_prod_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
ozf_utility_pvt.debug_message('Validation Mode is:'||p_validation_mode||' : '||JTF_PLSQL_API.g_create);
ozf_utility_pvt.debug_message('Product Ctx is :'||p_adj_new_prod_rec.product_context);
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_adj_new_prod_rec.offer_adj_new_line_id = FND_API.g_miss_num OR p_adj_new_prod_rec.offer_adj_new_line_id IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adj_new_line_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.excluder_flag = FND_API.g_miss_char OR p_adj_new_prod_rec.excluder_flag IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'excluder_flag' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.product_context = FND_API.g_miss_char OR p_adj_new_prod_rec.product_context IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_context' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.product_attribute = FND_API.g_miss_char OR p_adj_new_prod_rec.product_attribute IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_attribute' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.product_attr_value = FND_API.g_miss_char OR p_adj_new_prod_rec.product_attr_value IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_attr_value' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

--       IF p_adj_new_prod_rec.offer_type = 'VOLUME_OFFER' THEN
       IF p_adj_new_prod_rec.offer_adjustment_id IS NULL OR p_adj_new_prod_rec.offer_adjustment_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adjustment_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;
--       END IF;

   ELSE
      IF p_adj_new_prod_rec.offer_adj_new_product_id = FND_API.G_MISS_NUM THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adj_new_product_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.offer_adj_new_line_id = FND_API.G_MISS_NUM THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adj_new_line_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'excluder_flag' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.object_version_number = FND_API.G_MISS_NUM THEN
         OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'object_version_number' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_adj_new_prod_rec.product_context = FND_API.g_miss_char THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_context' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.product_attribute = FND_API.g_miss_char THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_attribute' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_prod_rec.product_attr_value = FND_API.g_miss_char THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'product_attr_value' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

--       IF p_adj_new_prod_rec.offer_type = 'VOLUME_OFFER' THEN
       IF p_adj_new_prod_rec.offer_adjustment_id = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adjustment_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;
--       END IF;
   END IF;
END check_adj_new_prod_req_items;

PROCEDURE check_adj_new_prod_FK_items(
    p_adj_new_prod_rec IN adj_new_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   ozf_utility_pvt.debug_message('Offer Type is :'||p_adj_new_prod_rec.offer_type);
   IF p_adj_new_prod_rec.offer_type <> 'VOLUME_OFFER' THEN
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_ADJ_NEW_LINES','OFFER_ADJ_NEW_LINE_ID',to_char(p_adj_new_prod_rec.OFFER_ADJ_NEW_LINE_ID)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_ADJ_LINE_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
   END IF;
    IF p_adj_new_prod_rec.offer_adjustment_id IS NOT NULL AND p_adj_new_prod_rec.offer_adjustment_id <> FND_API.G_MISS_NUM THEN
           IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_ADJUSTMENTS_B','OFFER_ADJUSTMENT_ID',to_char(p_adj_new_prod_rec.offer_adjustment_id)) = FND_API.g_false THEN
                OZF_Utility_PVT.Error_Message('OZF_INVALID_OFFER_ADJ_ID' );
                x_return_status := FND_API.g_ret_sts_error;
                return;
            END IF;
    END IF;
   -- Enter custom code here
END check_adj_new_prod_FK_items;

PROCEDURE check_adj_prod_Lkup_items(
    p_adj_new_prod_rec IN adj_new_prod_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
    CURSOR C_UOM_CODE_EXISTS  (p_uom_code VARCHAR2,p_organization_id NUMBER,p_inventory_item_id NUMBER)
    IS
        SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1 FROM mtl_item_uoms_view
                                         WHERE  ( organization_id = p_organization_id
                                            OR p_organization_id is NULL )
                                            AND uom_code =  p_uom_code
                                            AND inventory_item_id =  p_inventory_item_id);
    l_organization_id NUMBER := -999;
    l_UOM_CODE_EXISTS C_UOM_CODE_EXISTS%ROWTYPE;

    CURSOR c_general_uom(p_uom_code VARCHAR2)
    IS
    SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1
                                    FROM mtl_units_of_measure_vl
                                    WHERE uom_code =  p_uom_code);
    l_general_uom c_general_uom%rowtype;

l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_Lkup_Items';
CURSOR c_listHeaderId(cp_offerAdjNewLineId NUMBER)
IS
SELECT list_header_id
FROM ozf_offer_adjustments_b a, ozf_offer_adj_new_lines b
WHERE a.offer_adjustment_id = b.offer_adjustment_id
AND b.offer_adj_new_line_id = cp_offerAdjNewLineId;

l_listHeaderId NUMBER;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Enter custom code here
--=====================================================================
-- uom validation begin
--=====================================================================

    l_organization_id :=  FND_PROFILE.Value('QP_ORGANIZATION_ID');--QP_UTIL.Get_Item_Validation_Org;
    IF p_adj_new_prod_rec.uom_code IS NOT NULL AND p_adj_new_prod_rec.uom_code <> FND_API.G_MISS_CHAR THEN
        IF(p_adj_new_prod_rec.product_attribute = 'PRICING_ATTRIBUTE1') THEN

        OPEN c_uom_code_exists(p_adj_new_prod_rec.uom_code,l_organization_id,p_adj_new_prod_rec.product_attr_value);
            FETCH c_uom_code_exists INTO l_uom_code_exists;
           IF ( c_uom_code_exists%NOTFOUND) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
                   FND_MSG_PUB.add;
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            END IF;
       CLOSE c_uom_code_exists;
        ELSIF(p_adj_new_prod_rec.product_attribute = 'PRICING_ATTRIBUTE2') THEN
        open c_listHeaderId(cp_offerAdjNewLineId => p_adj_new_prod_rec.offer_adj_new_line_id);
        FETCH c_listHeaderId INTO l_listHeaderId;
        CLOSE c_listHeaderId;
         IF QP_Validate.Product_Uom ( p_product_uom_code => p_adj_new_prod_rec.uom_code
                                    ,p_category_id => to_number(p_adj_new_prod_rec.product_attr_value)
                                    ,p_list_header_id => l_listHeaderId) THEN

/*            IF QP_CATEGORY_MAPPING_RULE.Validate_UOM(
              l_organization_id,
              to_number(p_adj_new_prod_rec.product_attr_value),
              p_adj_new_prod_rec.uom_code) = 'N'
           THEN
           */
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
             FND_MSG_PUB.add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
            END IF;
        ELSE
            OPEN c_general_uom(p_adj_new_prod_rec.uom_code);
            FETCH c_general_uom INTO l_general_uom;
               IF ( c_general_uom%NOTFOUND) THEN
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                       FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
                       FND_MSG_PUB.add;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
                END IF;
             CLOSE c_general_uom;
        END IF;
    END IF;
END check_adj_prod_Lkup_items;

PROCEDURE Check_adj_new_prod_inter_attr(
    p_adj_new_prod_rec     IN    adj_new_prod_rec_type
    , p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create
    , x_return_status              OUT NOCOPY  VARCHAR2
      )
IS

CURSOR c_volumeType(cp_offerAdjLineId NUMBER) IS
SELECT volume_type , parent_adj_line_id FROM ozf_offer_adj_new_lines
WHERE offer_adj_new_line_id = cp_offerAdjLineId;
l_volumeType c_volumeType%ROWTYPE;
CURSOR c_listLineType(cp_offerAdjLineId NUMBER) IS
SELECT tier_type
FROM ozf_offer_adj_new_lines
WHERE offer_adj_new_line_id = cp_offerAdjLineId;
l_listLineType VARCHAR2(30);
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN c_volumeType(p_adj_new_prod_rec.offer_adj_new_line_id);
    FETCH c_volumeType INTO l_volumeType;
CLOSE c_volumeType;
IF l_volumeType.parent_adj_line_id IS NULL  AND l_volumeType.volume_type = 'PRICING_ATTRIBUTE10' THEN
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    IF p_adj_new_prod_rec.uom_code = FND_API.G_MISS_CHAR OR p_adj_new_prod_rec.uom_code IS NULL
    THEN
        OZF_Utility_PVT.Error_Message('OZF_UOM_QTY_REQD' );
        x_return_status := FND_API.g_ret_sts_error;
        return;
    END IF;
    ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF p_adj_new_prod_rec.uom_code = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_UOM_QTY_REQD' );
        x_return_status := FND_API.g_ret_sts_error;
        return;
    END IF;
    END IF;
END IF;

OPEN c_listLineType(p_adj_new_prod_rec.offer_adj_new_line_id);
        FETCH c_listLineType INTO l_listLineType;
        IF c_listLineType%NOTFOUND THEN
                l_listLineType := null;
        END IF;
CLOSE c_listLineType;

IF l_listLineType = 'PBH' THEN
        IF p_validation_mode = JTF_PLSQL_API.g_create THEN
                IF p_adj_new_prod_rec.uom_code = FND_API.G_MISS_CHAR OR p_adj_new_prod_rec.uom_code IS NULL THEN
                        OZF_Utility_PVT.Error_Message('OZF_PBH_UOM_REQD' );
                        x_return_status := FND_API.g_ret_sts_error;
                        return;
                END IF;
        ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
                IF p_adj_new_prod_rec.uom_code = FND_API.G_MISS_CHAR THEN
                        OZF_Utility_PVT.Error_Message('OZF_PBH_UOM_REQD' );
                        x_return_status := FND_API.g_ret_sts_error;
                        return;
                END IF;
        END IF;
END IF;
END Check_adj_new_prod_inter_attr;


PROCEDURE Check_adj_new_prod_attr(
    p_adj_new_prod_rec     IN    adj_new_prod_rec_type
    , x_return_status              OUT NOCOPY  VARCHAR2
      )
      IS
l_api_name CONSTANT VARCHAR2(30) := 'check_vo_product_attr';
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_UTIL.validate_qp_flexfield(flexfield_name                  =>'QP_ATTR_DEFNS_PRICING'
                                     ,context                        =>p_adj_new_prod_rec.product_context
                                     ,attribute                      =>p_adj_new_prod_rec.product_attribute
                                     ,value                          =>p_adj_new_prod_rec.product_attr_value
                                     ,application_short_name         => 'QP'
                                     ,context_flag                   =>l_context_flag
                                     ,attribute_flag                 =>l_attribute_flag
                                     ,value_flag                     =>l_value_flag
                                     ,datatype                       =>l_datatype
                                     ,precedence                     =>l_precedence
                                     ,error_code                     =>l_error_code
                                     );
       If (l_context_flag = 'N'  AND l_error_code = 7)       --  invalid context
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_CONTEXT'  );
               FND_MSG_PUB.add;
            END IF;
       End If;

       If (l_attribute_flag = 'N'  AND l_error_code = 8)       --  invalid attribute
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_ATTR'  );
               FND_MSG_PUB.add;
            END IF;
       End If;

       If (l_value_flag = 'N'  AND l_error_code = 9)       --  invalid value
      Then
          x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_VALUE'  );
               FND_MSG_PUB.add;
            END IF;
       End If;
END Check_adj_new_prod_attr;

PROCEDURE Check_adj_new_prod_Items (
    P_adj_new_prod_rec     IN    adj_new_prod_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
   -- Check Items Required/NOT NULL API calls

   check_adj_new_prod_req_items(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

Check_adj_new_prod_attr(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

Check_adj_new_prod_inter_attr(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Uniqueness API calls
   check_adj_new_prod_uk_items(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

   check_adj_new_prod_FK_items(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_adj_prod_Lkup_items(
      p_adj_new_prod_rec => p_adj_new_prod_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


END Check_adj_new_prod_Items;


PROCEDURE Complete_adj_new_prod_Rec (
   p_adj_new_prod_rec IN adj_new_prod_rec_type,
   x_complete_rec OUT NOCOPY adj_new_prod_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adj_new_products
      WHERE offer_adj_new_product_id = p_adj_new_prod_rec.offer_adj_new_product_id;
   l_adj_new_prod_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_adj_new_prod_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_adj_new_prod_rec;
   CLOSE c_complete;

   -- offer_adj_new_product_id
   IF p_adj_new_prod_rec.offer_adj_new_product_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_adj_new_product_id := l_adj_new_prod_rec.offer_adj_new_product_id;
   END IF;

   -- offer_adj_new_line_id
   IF p_adj_new_prod_rec.offer_adj_new_line_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_adj_new_line_id := l_adj_new_prod_rec.offer_adj_new_line_id;
   END IF;

   -- product_context
   IF p_adj_new_prod_rec.product_context = FND_API.g_miss_char THEN
      x_complete_rec.product_context := l_adj_new_prod_rec.product_context;
   END IF;

   -- product_attribute
   IF p_adj_new_prod_rec.product_attribute = FND_API.g_miss_char THEN
      x_complete_rec.product_attribute := l_adj_new_prod_rec.product_attribute;
   END IF;

   -- product_attr_value
   IF p_adj_new_prod_rec.product_attr_value = FND_API.g_miss_char THEN
      x_complete_rec.product_attr_value := l_adj_new_prod_rec.product_attr_value;
   END IF;

   -- excluder_flag
   IF p_adj_new_prod_rec.excluder_flag = FND_API.g_miss_char THEN
      x_complete_rec.excluder_flag := l_adj_new_prod_rec.excluder_flag;
   END IF;

   -- uom_code
   IF p_adj_new_prod_rec.uom_code = FND_API.g_miss_char THEN
      x_complete_rec.uom_code := l_adj_new_prod_rec.uom_code;
   END IF;

   -- creation_date
   IF p_adj_new_prod_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_adj_new_prod_rec.creation_date;
   END IF;

   -- created_by
   IF p_adj_new_prod_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_adj_new_prod_rec.created_by;
   END IF;

   -- last_update_date
   IF p_adj_new_prod_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_adj_new_prod_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_adj_new_prod_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_adj_new_prod_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_adj_new_prod_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_adj_new_prod_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_adj_new_prod_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_adj_new_prod_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_adj_new_prod_Rec;

PROCEDURE Validate_adj_new_prod(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_update,
    p_adj_new_prod_rec               IN   adj_new_prod_rec_type,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Adj_New_Prod';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_adj_new_prod_rec  OZF_Adj_New_Prod_PVT.adj_new_prod_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Adj_New_Prod_;

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
              Check_adj_new_prod_Items(
                 p_adj_new_prod_rec        => p_adj_new_prod_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_adj_new_prod_Rec(
         p_adj_new_prod_rec        => p_adj_new_prod_rec,
         x_complete_rec        => l_adj_new_prod_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_adj_new_prod_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_adj_new_prod_rec           =>    l_adj_new_prod_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Adj_New_Prod_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Adj_New_Prod_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Adj_New_Prod_;
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
End Validate_Adj_New_Prod;


PROCEDURE Validate_adj_new_prod_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_adj_new_prod_rec               IN    adj_new_prod_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_adj_new_prod_Rec;

END OZF_Adj_New_Prod_PVT;

/
