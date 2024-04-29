--------------------------------------------------------
--  DDL for Package Body OZF_ADJ_NEW_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ADJ_NEW_LINE_PVT" as
/* $Header: ozfvanlb.pls 120.0 2006/03/30 13:54:36 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Adj_New_Line_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Adj_New_Line_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvoanb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_line_rec               IN   adj_new_line_rec_type  := g_miss_adj_new_line_rec,
    x_offer_adj_new_line_id                   OUT NOCOPY   NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Adj_New_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_OFFER_ADJ_NEW_LINE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT OZF_OFFER_ADJ_NEW_LINES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_ADJ_NEW_LINES
      WHERE OFFER_ADJ_NEW_LINE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Adj_New_Line_PVT;

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

   IF p_adj_new_line_rec.OFFER_ADJ_NEW_LINE_ID IS NULL OR p_adj_new_line_rec.OFFER_ADJ_NEW_LINE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_ADJ_NEW_LINE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_ADJ_NEW_LINE_ID);
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
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Adj_New_Line');

          -- Invoke validation procedures
          Validate_adj_new_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_create,
            p_adj_new_line_rec  =>  p_adj_new_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(OZF_OFFER_ADJ_NEW_LINES_PKG.Insert_Row)

      OZF_OFFER_ADJ_NEW_LINES_PKG.Insert_Row(
          px_offer_adj_new_line_id  => l_offer_adj_new_line_id,
          p_offer_adjustment_id  => p_adj_new_line_rec.offer_adjustment_id,
          p_volume_from  => p_adj_new_line_rec.volume_from,
          p_volume_to  => p_adj_new_line_rec.volume_to,
          p_volume_type  => p_adj_new_line_rec.volume_type,
          p_discount  => p_adj_new_line_rec.discount,
          p_discount_type  => p_adj_new_line_rec.discount_type,
          p_tier_type  => p_adj_new_line_rec.tier_type,
          p_td_discount     => p_adj_new_line_rec.td_discount,
          p_td_discount_type => p_adj_new_line_rec.td_discount_type,
          p_quantity         => p_adj_new_line_rec.quantity,
          p_benefit_price_list_line_id => p_adj_new_line_rec.benefit_price_list_line_id,
          p_parent_adj_line_id          => p_adj_new_line_rec.parent_adj_line_id,
          p_start_date_active           => p_adj_new_line_rec.start_date_active,
          p_end_date_active             => p_adj_new_line_rec.end_date_active,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

          x_offer_adj_new_line_id := l_offer_adj_new_line_id;
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
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Adj_New_Line_PVT;
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
End Create_Adj_New_Line;


PROCEDURE Update_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_line_rec               IN    adj_new_line_rec_type,
    x_object_version_number      OUT NOCOPY   NUMBER
    )

 IS

CURSOR c_get_adj_new_line(cp_offerAdjNewLineId NUMBER, cp_objectVersionNumber NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_ADJ_NEW_LINES
    WHERE offer_adj_new_line_id = cp_offerAdjNewLineId
    AND object_version_number = cp_objectVersionNumber;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Adj_New_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_OFFER_ADJ_NEW_LINE_ID    NUMBER;
l_ref_adj_new_line_rec  c_get_Adj_New_Line%ROWTYPE ;
l_tar_adj_new_line_rec  OZF_Adj_New_Line_PVT.adj_new_line_rec_type := P_adj_new_line_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Adj_New_Line_PVT;

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
      OPEN c_get_Adj_New_Line( l_tar_adj_new_line_rec.offer_adj_new_line_id , l_tar_adj_new_line_rec.object_version_number);
      FETCH c_get_Adj_New_Line INTO l_ref_adj_new_line_rec  ;

       If ( c_get_Adj_New_Line%NOTFOUND) THEN
  OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Adj_New_Line') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Adj_New_Line;



      If (l_tar_adj_new_line_rec.object_version_number is NULL or
          l_tar_adj_new_line_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_adj_new_line_rec.object_version_number <> l_ref_adj_new_line_rec.object_version_number) Then
  OZF_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Adj_New_Line') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Adj_New_Line');

          -- Invoke validation procedures
          Validate_adj_new_line(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => JTF_PLSQL_API.g_update,
            p_adj_new_line_rec =>  p_adj_new_line_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
ozf_utility_pvt.debug_message('After validate: return:'||x_return_status);
      -- Invoke table handler(OZF_OFFER_ADJ_NEW_LINES_PKG.Update_Row)
      OZF_OFFER_ADJ_NEW_LINES_PKG.Update_Row(
          p_offer_adj_new_line_id  => p_adj_new_line_rec.offer_adj_new_line_id,
          p_offer_adjustment_id  => p_adj_new_line_rec.offer_adjustment_id,
          p_volume_from  => p_adj_new_line_rec.volume_from,
          p_volume_to  => p_adj_new_line_rec.volume_to,
          p_volume_type  => p_adj_new_line_rec.volume_type,
          p_discount  => p_adj_new_line_rec.discount,
          p_discount_type  => p_adj_new_line_rec.discount_type,
          p_tier_type  => p_adj_new_line_rec.tier_type,
          p_td_discount => p_adj_new_line_rec.td_discount,
          p_td_discount_type => p_adj_new_line_rec.td_discount_type,
          p_quantity         => p_adj_new_line_rec.quantity,
          p_benefit_price_list_line_id => p_adj_new_line_rec.benefit_price_list_line_id,
          p_parent_adj_line_id          => p_adj_new_line_rec.parent_adj_line_id,
          p_start_date_active           => p_adj_new_line_rec.start_date_active,
          p_end_date_active             => p_adj_new_line_rec.end_date_active,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_adj_new_line_rec.object_version_number);
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
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Adj_New_Line_PVT;
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
End Update_Adj_New_Line;


PROCEDURE Delete_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    p_offer_adj_new_line_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Adj_New_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

CURSOR c_products(cp_offerAdjNewLineId NUMBER) IS
SELECT offer_adj_new_product_id, object_version_number
FROM ozf_offer_adj_new_products
WHERE offer_adj_new_line_id = cp_offerAdjNewLineId;

CURSOR c_tiers(cp_offerAdjNewLineId NUMBER) IS
SELECT offer_adj_new_line_id
FROM ozf_offer_adj_new_lines
WHERE parent_adj_line_id = cp_offerAdjNewLineId;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Adj_New_Line_PVT;

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
      FOR l_products IN c_products(p_OFFER_ADJ_NEW_LINE_ID) LOOP
        OZF_Adj_New_Prod_PVT.Delete_Adj_New_Prod(
                                                    p_api_version_number         => 1.0
                                                    , p_init_msg_list              => FND_API.G_FALSE
                                                    , p_commit                     => FND_API.G_FALSE
                                                    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                                                    , x_return_status              => x_return_status
                                                    , x_msg_count                  => x_msg_count
                                                    , x_msg_data                   => x_msg_data
                                                    , p_offer_adj_new_product_id   => l_products.offer_adj_new_product_id
                                                    , p_object_version_number      => l_products.object_version_number
                                                );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END LOOP;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete Tiers');

for l_tiers in c_tiers(p_OFFER_ADJ_NEW_LINE_ID) LOOP
ozf_utility_pvt.debug_message('Line id is :'||l_tiers.offer_adj_new_line_id);
IF l_tiers.offer_adj_new_line_id IS NOT NULL THEN
      OZF_OFFER_ADJ_NEW_LINES_PKG.Delete_Row(
          p_OFFER_ADJ_NEW_LINE_ID  => l_tiers.offer_adj_new_line_id);
END IF;
END LOOP;
ozf_utility_pvt.debug_message('Line id is :'||p_OFFER_ADJ_NEW_LINE_ID);
     -- Invoke table handler(OZF_OFFER_ADJ_NEW_LINES_PKG.Delete_Row)
      OZF_OFFER_ADJ_NEW_LINES_PKG.Delete_Row(
          p_OFFER_ADJ_NEW_LINE_ID  => p_OFFER_ADJ_NEW_LINE_ID);
      --
      -- End of API body
      --
      OZF_UTILITY_PVT.debug_message( 'Private API: Called delete table handler');

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
     ROLLBACK TO DELETE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Adj_New_Line_PVT;
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
End Delete_Adj_New_Line;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Adj_New_Line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_offer_adj_new_line_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Adj_New_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_OFFER_ADJ_NEW_LINE_ID                  NUMBER;

CURSOR c_Adj_New_Line IS
   SELECT OFFER_ADJ_NEW_LINE_ID
   FROM OZF_OFFER_ADJ_NEW_LINES
   WHERE OFFER_ADJ_NEW_LINE_ID = p_OFFER_ADJ_NEW_LINE_ID
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
  OPEN c_Adj_New_Line;

  FETCH c_Adj_New_Line INTO l_OFFER_ADJ_NEW_LINE_ID;

  IF (c_Adj_New_Line%NOTFOUND) THEN
    CLOSE c_Adj_New_Line;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Adj_New_Line;

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
     ROLLBACK TO LOCK_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Adj_New_Line_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Adj_New_Line_PVT;
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
End Lock_Adj_New_Line;


PROCEDURE check_adj_new_line_uk_items(
    p_adj_new_line_rec               IN   adj_new_line_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_UTILITY_PVT.check_uniqueness(
         'OZF_OFFER_ADJ_NEW_LINES',
         'OFFER_ADJ_NEW_LINE_ID = ''' || p_adj_new_line_rec.OFFER_ADJ_NEW_LINE_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_UTILITY_PVT.check_uniqueness(
         'OZF_OFFER_ADJ_NEW_LINES',
         'OFFER_ADJ_NEW_LINE_ID = ''' || p_adj_new_line_rec.OFFER_ADJ_NEW_LINE_ID ||
         ''' AND OFFER_ADJ_NEW_LINE_ID <> ' || p_adj_new_line_rec.OFFER_ADJ_NEW_LINE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_OFFER_ADJ_NEW_LINE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_adj_new_line_uk_items;


PROCEDURE check_adj_pg_req_items(
                                p_adj_new_line_rec               IN  adj_new_line_rec_type,
                                p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
                                x_return_status	         OUT NOCOPY  VARCHAR2
                            )
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_adj_new_line_rec.discount = FND_API.g_miss_num OR p_adj_new_line_rec.discount IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'discount' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.discount_type = FND_API.g_miss_char OR p_adj_new_line_rec.discount_type IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'discount_type' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
    ELSE
        IF p_adj_new_line_rec.discount = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'discount' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.discount_type = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'discount_type' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
    END IF;
END check_adj_pg_req_items;

PROCEDURE check_adj_new_line_req_items(
    p_adj_new_line_rec               IN  adj_new_line_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_adj_new_line_rec.offer_adjustment_id = FND_API.g_miss_num OR p_adj_new_line_rec.offer_adjustment_id IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adjustment_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.tier_type = FND_API.g_miss_char OR p_adj_new_line_rec.tier_type IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'tier_type' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
      IF p_adj_new_line_rec.offer_adj_new_line_id IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adj_new_line_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.offer_adjustment_id IS NULL THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'offer_adjustment_id' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.tier_type = FND_API.G_MISS_CHAR THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'tier_type' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_adj_new_line_rec.object_version_number = FND_API.G_MISS_NUM THEN
        OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'object_version_number' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

IF p_adj_new_line_rec.tier_type = 'DIS' THEN
    check_adj_pg_req_items(
                                    p_adj_new_line_rec  => p_adj_new_line_rec
                                    , p_validation_mode   => p_validation_mode
                                    , x_return_status     => x_return_status
                                );
    IF x_return_status <>FND_API.g_ret_sts_success THEN
        return;
    END IF;
END IF;

END check_adj_new_line_req_items;


PROCEDURE   check_adj_new_line_attr(
    p_adj_new_line_rec IN adj_new_line_rec_type
    , p_validation_mode  IN    VARCHAR2
    , x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
CURSOR c_modifierLevelCode(cp_offerAdjustmentId NUMBER) IS
SELECT modifier_level_code FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;
l_modifierLevelCode c_modifierLevelCode%ROWTYPE;
CURSOR c_dates (cp_offerAdjustmentId NUMBER) IS
SELECT a.effective_date , b.end_date_active
FROM ozf_offer_adjustments_b a, qp_list_headers_b b
WHERE a.list_header_id = b.list_header_id
AND a.offer_adjustment_id = cp_offerAdjustmentId;
l_dates c_dates%ROWTYPE;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_adj_new_line_rec.volume_from < 0 THEN
            OZF_Utility_PVT.Error_Message('OZF_NEGATIVE_QTY' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
    IF p_adj_new_line_rec.volume_to < 0 THEN
            OZF_Utility_PVT.Error_Message('OZF_NEGATIVE_QTY' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;

OPEN c_modifierLevelCode(p_adj_new_line_rec.offer_adjustment_id);
FETCH c_modifierLevelCode INTO l_modifierLevelCode;
CLOSE c_modifierLevelCode;

    IF l_modifierLevelCode.modifier_level_code = 'LINEGROUP' THEN
        IF p_validation_mode = JTF_PLSQL_API.g_create THEN
              IF (p_adj_new_line_rec.volume_from = FND_API.G_MISS_NUM OR p_adj_new_line_rec.volume_from IS NULL)
                  OR
                  (p_adj_new_line_rec.volume_type = FND_API.G_MISS_CHAR OR p_adj_new_line_rec.volume_type IS NULL)
              THEN
                OZF_Utility_PVT.Error_Message('OZF_LINE_GRP_QTY_REQD' );
                x_return_status := FND_API.g_ret_sts_error;
                return;
              END IF;
        ELSE
              IF (p_adj_new_line_rec.volume_from = FND_API.G_MISS_NUM )
                  OR
                  (p_adj_new_line_rec.volume_type = FND_API.G_MISS_CHAR)
              THEN
                OZF_Utility_PVT.Error_Message('OZF_LINE_GRP_QTY_REQD' );
                x_return_status := FND_API.g_ret_sts_error;
                return;
              END IF;
        END IF;
    END IF;

OPEN c_dates(cp_offerAdjustmentId => p_adj_new_line_rec.offer_adjustment_id);
FETCH c_dates INTO l_dates;
CLOSE c_dates;
IF p_adj_new_line_rec.start_date_active IS NOT NULL AND p_adj_new_line_rec.start_date_active <> FND_API.G_MISS_DATE THEN
IF p_adj_new_line_rec.start_date_active < l_dates.effective_date THEN
    OZF_Utility_PVT.Error_Message('OZF_DATE_OUT_OF_RANGE' );
    x_return_status := FND_API.g_ret_sts_error;
    return;
END IF;
END IF;
IF p_adj_new_line_rec.end_date_active IS NOT NULL AND p_adj_new_line_rec.end_date_active <> FND_API.G_MISS_DATE THEN
    IF p_adj_new_line_rec.end_date_active > l_dates.end_date_active THEN
    ozf_utility_pvt.debug_message('End Date is :'||l_dates.end_date_active||' : '||p_adj_new_line_rec.end_date_active);
        OZF_Utility_PVT.Error_Message('OZF_DATE_OUT_OF_RANGE' );
        x_return_status := FND_API.g_ret_sts_error;
        return;
    END IF;
END IF;

END check_adj_new_line_attr;

PROCEDURE check_adj_new_line_FK_items(
    p_adj_new_line_rec IN adj_new_line_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
        IF ozf_utility_pvt.check_fk_exists('OZF_OFFER_ADJUSTMENTS_B','OFFER_ADJUSTMENT_ID',to_char(p_adj_new_line_rec.offer_adjustment_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_OFFER_ADJ_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
IF p_adj_new_line_rec.benefit_price_list_line_id IS NOT NULL AND p_adj_new_line_rec.benefit_price_list_line_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('qp_list_lines','list_line_type_code = ''PLL'' AND list_line_id ', to_char(p_adj_new_line_rec.benefit_price_list_line_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_PLL_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
END IF;

IF p_adj_new_line_rec.parent_adj_line_id IS NOT NULL AND p_adj_new_line_rec.parent_adj_line_id <> FND_API.G_MISS_NUM THEN
        IF ozf_utility_pvt.check_fk_exists('ozf_offer_adj_new_lines','tier_type = ''PBH'' AND offer_adj_new_line_id ', to_char(p_adj_new_line_rec.parent_adj_line_id)) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INV_PARENT_ID' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
END IF;

   -- Enter custom code here

END check_adj_new_line_FK_items;

PROCEDURE check_adj_line_Lkup_items(
    p_adj_new_line_rec IN adj_new_line_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- Enter custom code here
IF p_adj_new_line_rec.volume_type <> FND_API.G_MISS_CHAR AND p_adj_new_line_rec.volume_type IS NOT NULL THEN
   IF OZF_UTILITY_PVT.check_lookup_exists('OZF_LOOKUPS', 'OZF_QP_VOLUME_TYPE', p_adj_new_line_rec.volume_type) = FND_API.g_false THEN
            OZF_Utility_PVT.Error_Message('OZF_INVALID_VOLUME_TYPE' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;

IF p_adj_new_line_rec.discount_type <> FND_API.G_MISS_CHAR AND p_adj_new_line_rec.discount_type IS NOT NULL THEN
    IF OZF_UTILITY_PVT.check_lookup_exists('QP_LOOKUPS', 'ARITHMETIC_OPERATOR', p_adj_new_line_rec.discount_type) = FND_API.g_false THEN
        OZF_Utility_PVT.Error_Message('OZF_INVALID_DISCOUNT_TYPE' );
        x_return_status := FND_API.g_ret_sts_error;
        return;
    END IF;
END IF;
IF p_adj_new_line_rec.tier_type <> FND_API.G_MISS_CHAR AND p_adj_new_line_rec.tier_type IS NOT NULL THEN
    IF OZF_UTILITY_PVT.check_lookup_exists('QP_LOOKUPS', 'LIST_LINE_TYPE_CODE', p_adj_new_line_rec.tier_type) = FND_API.g_false THEN
        OZF_Utility_PVT.Error_Message('OZF_INVALID_TIER_TYPE' );
        x_return_status := FND_API.g_ret_sts_error;
        return;
    END IF;
END IF;

END check_adj_line_Lkup_items;

PROCEDURE   Check_adj_new_line_inter_attr(
    P_adj_new_line_rec     IN    adj_new_line_rec_type
    , p_validation_mode  IN    VARCHAR2
    , x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (p_adj_new_line_rec.volume_from IS NOT NULL AND P_adj_new_line_rec.volume_from <> FND_API.G_MISS_NUM )
    AND
    (p_adj_new_line_rec.volume_to IS NOT NULL AND p_adj_new_line_rec.volume_to <> FND_API.G_MISS_NUM )
THEN
    IF p_adj_new_line_rec.volume_to <  p_adj_new_line_rec.volume_from THEN
            OZF_Utility_PVT.Error_Message('OZF_FROM_GT_TO' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;
END IF;
IF p_adj_new_line_rec.tier_type = 'PBH' THEN
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        IF p_adj_new_line_rec.volume_type IS NULL OR p_adj_new_line_rec.volume_type = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_PBH_VOL_TYPE_REQD' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
        IF p_adj_new_line_rec.volume_type = FND_API.G_MISS_CHAR THEN
            OZF_Utility_PVT.Error_Message('OZF_PBH_VOL_TYPE_REQD' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;
END IF;
END Check_adj_new_line_inter_attr;

PROCEDURE   check_adj_new_line_entity(
    p_adj_new_line_rec     IN    adj_new_line_rec_type,
    x_return_status    OUT NOCOPY   VARCHAR2
      )
IS
l_discount_type OZF_OFFER_DISCOUNT_LINES.DISCOUNT_TYPE%TYPE;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_adj_new_line_rec.tier_type = 'DIS' THEN
    IF p_adj_new_line_rec.discount_type IS NOT NULL AND p_adj_new_line_rec.discount_type <> FND_API.G_MISS_CHAR THEN
    IF p_adj_new_line_rec.discount IS NOT NULL AND p_adj_new_line_rec.discount <> FND_API.G_MISS_NUM THEN
        IF p_adj_new_line_rec.discount_type ='%' AND p_adj_new_line_rec.discount > 100 THEN
            OZF_Utility_PVT.Error_Message('OZF_PER_DISC_INV' );
            x_return_status := FND_API.g_ret_sts_error;
            return;
        END IF;
    END IF;
    END IF;
END IF;
END check_adj_new_line_entity;

PROCEDURE Check_adj_new_line_Items (
    P_adj_new_line_rec     IN    adj_new_line_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
    )
IS
BEGIN
   -- Check Items Uniqueness API calls
x_return_status := FND_API.G_RET_STS_SUCCESS;
   check_adj_new_line_uk_items(
      p_adj_new_line_rec => p_adj_new_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('UK Items:'||x_return_status);

   -- Check Items Required/NOT NULL API calls

   check_adj_new_line_req_items(
      p_adj_new_line_rec => p_adj_new_line_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('Req Items:'||x_return_status);

   -- Check Items Foreign Keys API calls

   check_adj_new_line_FK_items(
      p_adj_new_line_rec => p_adj_new_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('FK Items:'||x_return_status);

   -- Check Items Lookups

   check_adj_line_Lkup_items(
      p_adj_new_line_rec => p_adj_new_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('Lkiup Items:'||x_return_status);

check_adj_new_line_attr(
      p_adj_new_line_rec => p_adj_new_line_rec
      , p_validation_mode => p_validation_mode
      , x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('Attr Items:'||x_return_status);

Check_adj_new_line_inter_attr(
      p_adj_new_line_rec => p_adj_new_line_rec
      , p_validation_mode => p_validation_mode
      , x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('Inter Items:'||x_return_status);
check_adj_new_line_entity
    (
      p_adj_new_line_rec => p_adj_new_line_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
ozf_utility_pvt.debug_message('Entity Items:'||x_return_status);


END Check_adj_new_line_Items;


PROCEDURE Complete_adj_new_line_Rec (
   p_adj_new_line_rec IN adj_new_line_rec_type,
   x_complete_rec OUT NOCOPY  adj_new_line_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adj_new_lines
      WHERE offer_adj_new_line_id = p_adj_new_line_rec.offer_adj_new_line_id;
   l_adj_new_line_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_adj_new_line_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_adj_new_line_rec;
   CLOSE c_complete;

   -- offer_adj_new_line_id
   IF p_adj_new_line_rec.offer_adj_new_line_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_adj_new_line_id := l_adj_new_line_rec.offer_adj_new_line_id;
   END IF;

   -- offer_adjustment_id
   IF p_adj_new_line_rec.offer_adjustment_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_adjustment_id := l_adj_new_line_rec.offer_adjustment_id;
   END IF;

   -- volume_from
   IF p_adj_new_line_rec.volume_from = FND_API.g_miss_num THEN
      x_complete_rec.volume_from := l_adj_new_line_rec.volume_from;
   END IF;

   -- volume_to
   IF p_adj_new_line_rec.volume_to = FND_API.g_miss_num THEN
      x_complete_rec.volume_to := l_adj_new_line_rec.volume_to;
   END IF;

   -- volume_type
   IF p_adj_new_line_rec.volume_type = FND_API.g_miss_char THEN
      x_complete_rec.volume_type := l_adj_new_line_rec.volume_type;
   END IF;

   -- discount
   IF p_adj_new_line_rec.discount = FND_API.g_miss_num THEN
      x_complete_rec.discount := l_adj_new_line_rec.discount;
   END IF;

   -- discount_type
   IF p_adj_new_line_rec.discount_type = FND_API.g_miss_char THEN
      x_complete_rec.discount_type := l_adj_new_line_rec.discount_type;
   END IF;

   -- tier_type
   IF p_adj_new_line_rec.tier_type = FND_API.g_miss_char THEN
      x_complete_rec.tier_type := l_adj_new_line_rec.tier_type;
   END IF;

   -- creation_date
   IF p_adj_new_line_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_adj_new_line_rec.creation_date;
   END IF;

   -- created_by
   IF p_adj_new_line_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_adj_new_line_rec.created_by;
   END IF;

   -- last_update_date
   IF p_adj_new_line_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_adj_new_line_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_adj_new_line_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_adj_new_line_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_adj_new_line_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_adj_new_line_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_adj_new_line_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_adj_new_line_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_adj_new_line_Rec;

PROCEDURE Validate_adj_new_line(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_update,
    p_adj_new_line_rec           IN   adj_new_line_rec_type,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Adj_New_Line';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_adj_new_line_rec  OZF_Adj_New_Line_PVT.adj_new_line_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Adj_New_Line_;

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

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_adj_new_line_Items(
                 p_adj_new_line_rec        => p_adj_new_line_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_adj_new_line_Rec(
         p_adj_new_line_rec        => p_adj_new_line_rec,
         x_complete_rec        => l_adj_new_line_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_adj_new_line_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_adj_new_line_rec           =>    l_adj_new_line_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Adj_New_Line_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Adj_New_Line_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Adj_New_Line_;
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
End Validate_Adj_New_Line;


PROCEDURE Validate_adj_new_line_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    p_adj_new_line_rec               IN    adj_new_line_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_adj_new_line_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_adj_new_line_Rec;


PROCEDURE populate_line_disc_rec
(
    p_adj_new_disc_rec               IN   adj_new_disc_rec_type  := g_miss_adj_new_disc_rec,
    p_adj_new_line_rec               IN OUT NOCOPY   adj_new_line_rec_type
)
IS
BEGIN
       p_adj_new_line_rec.offer_adj_new_line_id           := p_adj_new_disc_rec.offer_adj_new_line_id;
       p_adj_new_line_rec.offer_adjustment_id             := p_adj_new_disc_rec.offer_adjustment_id;
       p_adj_new_line_rec.tier_type                       := p_adj_new_disc_rec.tier_type;
       p_adj_new_line_rec.object_version_number           := p_adj_new_disc_rec.object_version_number;
       p_adj_new_line_rec.volume_type                     := p_adj_new_disc_rec.volume_type;
       p_adj_new_line_rec.start_date_active               := p_adj_new_disc_rec.start_date_active;
       p_adj_new_line_rec.end_date_active                 := p_adj_new_disc_rec.end_date_active;

       IF p_adj_new_disc_rec.tier_type <> 'PBH' THEN
               p_adj_new_line_rec.volume_from                     := p_adj_new_disc_rec.volume_from;
               p_adj_new_line_rec.volume_to                       := p_adj_new_disc_rec.volume_to;
               p_adj_new_line_rec.discount                        := p_adj_new_disc_rec.discount;
               p_adj_new_line_rec.discount_type                   := p_adj_new_disc_rec.discount_type;
               p_adj_new_line_rec.td_discount                     := p_adj_new_disc_rec.td_discount;
               p_adj_new_line_rec.td_discount_type                := p_adj_new_disc_rec.td_discount_type;
               p_adj_new_line_rec.quantity                        := p_adj_new_disc_rec.quantity;
               p_adj_new_line_rec.benefit_price_list_line_id      := p_adj_new_disc_rec.benefit_price_list_line_id;
               p_adj_new_line_rec.parent_adj_line_id              := p_adj_new_disc_rec.parent_adj_line_id;
       END IF;
       IF (p_adj_new_line_rec.volume_from IS NOT NULL AND p_adj_new_line_rec.volume_from <> FND_API.G_MISS_NUM) THEN
           IF ( p_adj_new_line_rec.volume_to IS NULL OR p_adj_new_line_rec.volume_to = FND_API.G_MISS_NUM ) THEN
                p_adj_new_line_rec.volume_to := 999999999;
           END IF;
       END IF;
END populate_line_disc_rec;

PROCEDURE populate_prod_disc_rec
(
    p_adj_new_disc_rec               IN   adj_new_disc_rec_type  := g_miss_adj_new_disc_rec,
    p_adj_new_prod_rec               IN OUT NOCOPY  OZF_Adj_New_Prod_PVT.adj_new_prod_rec_type
)
IS
CURSOR c_modifierLevelCode(cp_offerAdjustmentId NUMBER) IS
SELECT modifier_level_code, a.offer_type FROM ozf_offers a, ozf_offer_adjustments_b b
WHERE a.qp_list_header_id = b.list_header_id
AND b.offer_adjustment_id = cp_offerAdjustmentId;
l_modifierLevelCode c_modifierLevelCode%ROWTYPE;
BEGIN
    p_adj_new_prod_rec.offer_adj_new_product_id        := p_adj_new_disc_rec.offer_adj_new_product_id;
    p_adj_new_prod_rec.offer_adj_new_line_id           := p_adj_new_disc_rec.offer_adj_new_line_id;
    p_adj_new_prod_rec.offer_adjustment_id             := p_adj_new_disc_rec.offer_adjustment_id;
    p_adj_new_prod_rec.product_context                 := 'ITEM';
    p_adj_new_prod_rec.product_attribute               := p_adj_new_disc_rec.product_attribute;
    p_adj_new_prod_rec.product_attr_value              := p_adj_new_disc_rec.product_attr_value;
    p_adj_new_prod_rec.excluder_flag                   := 'N';
    p_adj_new_prod_rec.uom_code                        := p_adj_new_disc_rec.uom_code;
    p_adj_new_prod_rec.object_version_number           := p_adj_new_disc_rec.prod_obj_version_number;
    OPEN c_modifierLevelCode(p_adj_new_disc_rec.offer_adjustment_id);
        fetch c_modifierLevelCode INTO l_modifierLevelCode;
    CLOSE c_modifierLevelCode;
    p_adj_new_prod_rec.offer_type                       := l_modifierLevelCode.offer_type;
    ozf_utility_pvt.debug_message('OfferType populated is :'||p_adj_new_prod_rec.offer_type||' : '||l_modifierLevelCode.offer_type);
END populate_prod_disc_rec ;

PROCEDURE Create_Adj_New_Disc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_disc_rec               IN   adj_new_disc_rec_type  := g_miss_adj_new_disc_rec,
    x_offer_adj_new_line_id                   OUT NOCOPY   NUMBER
    )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Adj_New_Disc';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_adj_new_line_rec adj_new_line_rec_type;
l_adj_new_prod_rec OZF_Adj_New_Prod_PVT.adj_new_prod_rec_type;
l_offer_adj_new_product_id NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Adj_New_Disc_Pvt;
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

    populate_line_disc_rec
    (
        p_adj_new_disc_rec               => p_adj_new_disc_rec
        , p_adj_new_line_rec               => l_adj_new_line_rec
    );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

    Create_Adj_New_Line(
        p_api_version_number         => 1.0
        , p_init_msg_list              => FND_API.G_FALSE
        , p_commit                     => FND_API.G_FALSE
        , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data

        , p_adj_new_line_rec           => l_adj_new_line_rec
        , x_offer_adj_new_line_id      => x_offer_adj_new_line_id
        );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    populate_prod_disc_rec
    (
        p_adj_new_disc_rec               => p_adj_new_disc_rec
        , p_adj_new_prod_rec             => l_adj_new_prod_rec
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_adj_new_prod_rec.offer_adj_new_line_id := x_offer_adj_new_line_id;
    OZF_Adj_New_Prod_PVT.Create_Adj_New_Prod(
        p_api_version_number         => 1.0
        , p_init_msg_list              => FND_API.G_FALSE
        , p_commit                     => FND_API.G_FALSE
        , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data

        , p_adj_new_prod_rec           => l_adj_new_prod_rec
        , x_offer_adj_new_product_id   => l_offer_adj_new_product_id
         );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message

EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Adj_New_Disc_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Adj_New_Disc_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Adj_New_Disc_Pvt;
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

END Create_Adj_New_Disc;


PROCEDURE Update_Adj_New_Disc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY   VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,

    p_adj_new_disc_rec               IN    adj_new_disc_rec_type,
    x_object_version_number      OUT NOCOPY   NUMBER
    )
IS
l_api_name CONSTANT VARCHAR2(30) := 'Update_Adj_New_Disc';
l_api_version_number CONSTANT NUMBER := 1.0;
l_adj_new_line_rec adj_new_line_rec_type;
l_adj_new_prod_rec OZF_Adj_New_Prod_PVT.adj_new_prod_rec_type;
l_object_version_number NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Adj_New_Disc_Pvt;
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

    populate_line_disc_rec
    (
        p_adj_new_disc_rec               => p_adj_new_disc_rec
        , p_adj_new_line_rec               => l_adj_new_line_rec
    );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

Update_Adj_New_Line(
    p_api_version_number         => 1.0
    , p_init_msg_list              => FND_API.G_FALSE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_adj_new_line_rec           => l_adj_new_line_rec
    , x_object_version_number      => x_object_version_number
    );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
    populate_prod_disc_rec
    (
        p_adj_new_disc_rec               => p_adj_new_disc_rec
        , p_adj_new_prod_rec               => l_adj_new_prod_rec
    );

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

OZF_Adj_New_Prod_PVT.Update_Adj_New_Prod(
    p_api_version_number         => 1.0
    , p_init_msg_list              => FND_API.G_FALSE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level           => FND_API.G_VALID_LEVEL_FULL

    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data

    , p_adj_new_prod_rec           => l_adj_new_prod_rec
    , x_object_version_number      => l_object_version_number
    );
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
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
EXCEPTION

   WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Adj_New_Disc_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Adj_New_Disc_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Adj_New_Disc_Pvt;
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

END Update_Adj_New_Disc;
END OZF_Adj_New_Line_PVT;

/
