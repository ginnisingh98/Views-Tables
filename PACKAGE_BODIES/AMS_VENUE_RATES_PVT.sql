--------------------------------------------------------
--  DDL for Package Body AMS_VENUE_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUE_RATES_PVT" as
/* $Header: amsvvrtb.pls 115.5 2002/12/24 18:59:46 mukumar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Venue_Rates_PVT
-- Purpose
--
-- History
--   10-MAY-2002  GMADANA    Added Rate_code.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Venue_Rates_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvvrtb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_venue_rates_rec               IN   venue_rates_rec_type  := g_miss_venue_rates_rec,
    x_rate_id                   OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Venue_Rates';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_RATE_ID                  NUMBER;
   l_dummy       NUMBER;
   l_venue_rates_rec  AMS_Venue_Rates_PVT.venue_rates_rec_type := p_venue_rates_rec;

   CURSOR c_id IS
      SELECT AMS_VENUE_RATES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_VENUE_RATES_B
      WHERE RATE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Venue_Rates_PVT;

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

   IF p_venue_rates_rec.RATE_ID IS NULL OR p_venue_rates_rec.RATE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RATE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RATE_ID);
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

              AMS_UTILITY_PVT.debug_message('Private API: Validate_Venue_Rates');
          END IF;

          -- Invoke validation procedures
          Validate_venue_rates(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_venue_rates_rec  =>  p_venue_rates_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- the code will convert the transaction currency in to
      -- functional currency.

      IF l_venue_rates_rec.transactional_value IS NOT NULL THEN
      AMS_CampaignRules_PVT.Convert_Camp_Currency(
          p_tc_curr     => p_venue_rates_rec.transactional_currency_code,
          p_tc_amt      => p_venue_rates_rec.transactional_value,
          x_fc_curr     => l_venue_rates_rec.functional_currency_code,
          x_fc_amt      => l_venue_rates_rec.functional_value
          ) ;
      END IF ;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_VENUE_RATES_B_PKG.Insert_Row)
      AMS_VENUE_RATES_B_PKG.Insert_Row(
          px_rate_id  => l_rate_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_active_flag  => p_venue_rates_rec.active_flag,
          p_venue_id  => p_venue_rates_rec.venue_id,
          p_metric_id  => p_venue_rates_rec.metric_id,
          p_transactional_value  => p_venue_rates_rec.transactional_value,
          p_transactional_currency_code  => p_venue_rates_rec.transactional_currency_code,
          p_functional_value  => l_venue_rates_rec.functional_value,
          p_functional_currency_code  => l_venue_rates_rec.functional_currency_code,
          p_uom_code  => p_venue_rates_rec.uom_code,
          p_rate_code => p_venue_rates_rec.rate_code,
          p_attribute_category  => p_venue_rates_rec.attribute_category,
          p_attribute1  => p_venue_rates_rec.attribute1,
          p_attribute2  => p_venue_rates_rec.attribute2,
          p_attribute3  => p_venue_rates_rec.attribute3,
          p_attribute4  => p_venue_rates_rec.attribute4,
          p_attribute5  => p_venue_rates_rec.attribute5,
          p_attribute6  => p_venue_rates_rec.attribute6,
          p_attribute7  => p_venue_rates_rec.attribute7,
          p_attribute8  => p_venue_rates_rec.attribute8,
          p_attribute9  => p_venue_rates_rec.attribute9,
          p_attribute10  => p_venue_rates_rec.attribute10,
          p_attribute11  => p_venue_rates_rec.attribute11,
          p_attribute12  => p_venue_rates_rec.attribute12,
          p_attribute13  => p_venue_rates_rec.attribute13,
          p_attribute14  => p_venue_rates_rec.attribute14,
          p_attribute15  => p_venue_rates_rec.attribute15,
	  p_description  => p_venue_rates_rec.description);

          x_rate_id := l_rate_id;
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
     ROLLBACK TO CREATE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Venue_Rates_PVT;
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
End Create_Venue_Rates;


PROCEDURE Update_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_venue_rates_rec               IN    venue_rates_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_venue_rates(rate_id NUMBER) IS
    SELECT *
    FROM  AMS_VENUE_RATES_B;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Venue_Rates';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_RATE_ID    NUMBER;
l_ref_venue_rates_rec  c_get_Venue_Rates%ROWTYPE ;
l_tar_venue_rates_rec  AMS_Venue_Rates_PVT.venue_rates_rec_type := P_venue_rates_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Venue_Rates_PVT;

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
      OPEN c_get_Venue_Rates( l_tar_venue_rates_rec.rate_id);

      FETCH c_get_Venue_Rates INTO l_ref_venue_rates_rec  ;

       If ( c_get_Venue_Rates%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Venue_Rates') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Venue_Rates;
*/


      If (l_tar_venue_rates_rec.object_version_number is NULL or
          l_tar_venue_rates_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_venue_rates_rec.object_version_number <> l_ref_venue_rates_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Venue_Rates') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_UTILITY_PVT.debug_message('Private API: Validate_Venue_Rates');
          END IF;

          -- Invoke validation procedures
          Validate_venue_rates(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_venue_rates_rec  =>  p_venue_rates_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_VENUE_RATES_B_PKG.Update_Row)
      AMS_VENUE_RATES_B_PKG.Update_Row(
          p_rate_id  => p_venue_rates_rec.rate_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_venue_rates_rec.object_version_number,
          p_active_flag  => p_venue_rates_rec.active_flag,
          p_venue_id  => p_venue_rates_rec.venue_id,
          p_metric_id  => p_venue_rates_rec.metric_id,
          p_transactional_value  => p_venue_rates_rec.transactional_value,
          p_transactional_currency_code  => p_venue_rates_rec.transactional_currency_code,
          p_functional_value  => p_venue_rates_rec.functional_value,
          p_functional_currency_code  => p_venue_rates_rec.functional_currency_code,
          p_uom_code  => p_venue_rates_rec.uom_code,
          p_rate_code => p_venue_rates_rec.rate_code,
          p_attribute_category  => p_venue_rates_rec.attribute_category,
          p_attribute1  => p_venue_rates_rec.attribute1,
          p_attribute2  => p_venue_rates_rec.attribute2,
          p_attribute3  => p_venue_rates_rec.attribute3,
          p_attribute4  => p_venue_rates_rec.attribute4,
          p_attribute5  => p_venue_rates_rec.attribute5,
          p_attribute6  => p_venue_rates_rec.attribute6,
          p_attribute7  => p_venue_rates_rec.attribute7,
          p_attribute8  => p_venue_rates_rec.attribute8,
          p_attribute9  => p_venue_rates_rec.attribute9,
          p_attribute10  => p_venue_rates_rec.attribute10,
          p_attribute11  => p_venue_rates_rec.attribute11,
          p_attribute12  => p_venue_rates_rec.attribute12,
          p_attribute13  => p_venue_rates_rec.attribute13,
          p_attribute14  => p_venue_rates_rec.attribute14,
          p_attribute15  => p_venue_rates_rec.attribute15,
          p_description  => p_venue_rates_rec.description);

          x_object_version_number := p_venue_rates_rec.object_version_number + 1;

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
     ROLLBACK TO UPDATE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Venue_Rates_PVT;
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
End Update_Venue_Rates;


PROCEDURE Delete_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rate_id                    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Venue_Rates';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Venue_Rates_PVT;

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

      -- Invoke table handler(AMS_VENUE_RATES_B_PKG.Delete_Row)
      AMS_VENUE_RATES_B_PKG.Delete_Row(
          p_RATE_ID  => p_RATE_ID);
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
     ROLLBACK TO DELETE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Venue_Rates_PVT;
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
End Delete_Venue_Rates;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_rate_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Venue_Rates';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_RATE_ID                  NUMBER;

CURSOR c_Venue_Rates IS
   SELECT RATE_ID
   FROM AMS_VENUE_RATES_B
   WHERE RATE_ID = p_RATE_ID
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
  OPEN c_Venue_Rates;

  FETCH c_Venue_Rates INTO l_RATE_ID;

  IF (c_Venue_Rates%NOTFOUND) THEN
    CLOSE c_Venue_Rates;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Venue_Rates;

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
     ROLLBACK TO LOCK_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Venue_Rates_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Venue_Rates_PVT;
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
End Lock_Venue_Rates;


PROCEDURE check_venue_rates_uk_items(
    p_venue_rates_rec               IN   venue_rates_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_VENUE_RATES_B',
         'RATE_ID = ''' || p_venue_rates_rec.RATE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_VENUE_RATES_B',
         'RATE_ID = ''' || p_venue_rates_rec.RATE_ID ||
         ''' AND RATE_ID <> ' || p_venue_rates_rec.RATE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_RATE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_venue_rates_uk_items;

PROCEDURE check_venue_rates_req_items(
    p_venue_rates_rec               IN  venue_rates_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

/*
      IF p_venue_rates_rec.rate_id = FND_API.g_miss_num OR p_venue_rates_rec.rate_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','RATE_ID');
         FND_MESSAGE.set_name('AMS', 'AMS_MISS_RATE_ID');
         FND_MSG_PUB.Add;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.last_update_date = FND_API.g_miss_date OR p_venue_rates_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATE_DATE');

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.last_updated_by = FND_API.g_miss_num OR p_venue_rates_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','LAST_UPDATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.creation_date = FND_API.g_miss_date OR p_venue_rates_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CREATION_DATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.created_by = FND_API.g_miss_num OR p_venue_rates_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CREATED_BY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
*/

      IF p_venue_rates_rec.venue_id = FND_API.g_miss_num OR p_venue_rates_rec.venue_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','VENUE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

  -- Following code is commented by GMADANA
  /*
      IF p_venue_rates_rec.metric_id = FND_API.g_miss_num OR p_venue_rates_rec.metric_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','METRIC_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   */


      IF p_venue_rates_rec.transactional_value = FND_API.g_miss_num OR p_venue_rates_rec.transactional_value IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','TRANSACTIONAL_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.transactional_currency_code = FND_API.g_miss_char OR p_venue_rates_rec.transactional_currency_code IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','TRANSACTIONAL_CURRENCY_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

/*
      IF p_venue_rates_rec.functional_value = FND_API.g_miss_num OR p_venue_rates_rec.functional_value IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','FUNCTIONAL_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.functional_currency_code = FND_API.g_miss_char OR p_venue_rates_rec.functional_currency_code IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','FUNCTIONAL_CURRENCY_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
*/

      IF p_venue_rates_rec.uom_code = FND_API.g_miss_char OR p_venue_rates_rec.uom_code IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','UOM_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_venue_rates_rec.rate_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_rate_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

/*
      IF p_venue_rates_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/
      IF p_venue_rates_rec.venue_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_venue_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.metric_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_metric_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.transactional_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_transactional_value');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.transactional_currency_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_transactional_currency_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.functional_value IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_functional_value');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.functional_currency_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_functional_currency_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_venue_rates_rec.uom_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_venue_rates_NO_uom_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_venue_rates_req_items;

PROCEDURE check_venue_rates_FK_items(
    p_venue_rates_rec IN venue_rates_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_venue_rates_FK_items;

PROCEDURE check_venue_rates_Lookup_items(
    p_venue_rates_rec IN venue_rates_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN

IF p_venue_rates_rec.rate_code <> FND_API.g_miss_char
      AND p_venue_rates_rec.rate_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_RATE_CODE',
            p_lookup_code => p_venue_rates_rec.rate_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
           -- FND_MESSAGE.set_name('AMS', 'AMS_BAD_RATE_TYPE');
            FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
            FND_MESSAGE.set_token('MISS_FIELD','RATE_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;



   -- Enter custom code here

END check_venue_rates_Lookup_items;

PROCEDURE Check_venue_rates_Items (
    P_venue_rates_rec     IN    venue_rates_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_venue_rates_uk_items(
      p_venue_rates_rec => p_venue_rates_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_venue_rates_req_items(
      p_venue_rates_rec => p_venue_rates_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_venue_rates_FK_items(
      p_venue_rates_rec => p_venue_rates_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_venue_rates_Lookup_items(
      p_venue_rates_rec => p_venue_rates_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_venue_rates_Items;



PROCEDURE Complete_venue_rates_Rec (
   p_venue_rates_rec IN venue_rates_rec_type,
   x_complete_rec OUT NOCOPY venue_rates_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_venue_rates_b
      WHERE rate_id = p_venue_rates_rec.rate_id;
   l_venue_rates_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_venue_rates_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_venue_rates_rec;
   CLOSE c_complete;

   -- rate_id
   IF p_venue_rates_rec.rate_id = FND_API.g_miss_num THEN
      x_complete_rec.rate_id := l_venue_rates_rec.rate_id;
   END IF;

   -- last_update_date
   IF p_venue_rates_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_venue_rates_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_venue_rates_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_venue_rates_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_venue_rates_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_venue_rates_rec.creation_date;
   END IF;

   -- created_by
   IF p_venue_rates_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_venue_rates_rec.created_by;
   END IF;

   -- last_update_login
   IF p_venue_rates_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_venue_rates_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_venue_rates_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_venue_rates_rec.object_version_number;
   END IF;

   -- active_flag
   IF p_venue_rates_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_venue_rates_rec.active_flag;
   END IF;

   -- venue_id
   IF p_venue_rates_rec.venue_id = FND_API.g_miss_num THEN
      x_complete_rec.venue_id := l_venue_rates_rec.venue_id;
   END IF;

   -- metric_id
   IF p_venue_rates_rec.metric_id = FND_API.g_miss_num THEN
      x_complete_rec.metric_id := l_venue_rates_rec.metric_id;
   END IF;

   -- transactional_value
   IF p_venue_rates_rec.transactional_value = FND_API.g_miss_num THEN
      x_complete_rec.transactional_value := l_venue_rates_rec.transactional_value;
   END IF;

   -- transactional_currency_code
   IF p_venue_rates_rec.transactional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transactional_currency_code := l_venue_rates_rec.transactional_currency_code;
   END IF;



   -- functional_value
   IF p_venue_rates_rec.functional_value = FND_API.g_miss_num THEN
      x_complete_rec.functional_value := l_venue_rates_rec.functional_value;
   END IF;

   -- functional_currency_code
   IF p_venue_rates_rec.functional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_code := l_venue_rates_rec.functional_currency_code;
   END IF;

   -- uom_code
   IF p_venue_rates_rec.uom_code = FND_API.g_miss_char THEN
      x_complete_rec.uom_code := l_venue_rates_rec.uom_code;
   END IF;

 -- rate_code Added by GMADANA
   IF p_venue_rates_rec.rate_code = FND_API.g_miss_char THEN
      x_complete_rec.rate_code := l_venue_rates_rec.rate_code;
   END IF;

   -- attribute_category
   IF p_venue_rates_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_venue_rates_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_venue_rates_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_venue_rates_rec.attribute1;
   END IF;

   -- attribute2
   IF p_venue_rates_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_venue_rates_rec.attribute2;
   END IF;

   -- attribute3
   IF p_venue_rates_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_venue_rates_rec.attribute3;
   END IF;

   -- attribute4
   IF p_venue_rates_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_venue_rates_rec.attribute4;
   END IF;

   -- attribute5
   IF p_venue_rates_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_venue_rates_rec.attribute5;
   END IF;

   -- attribute6
   IF p_venue_rates_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_venue_rates_rec.attribute6;
   END IF;

   -- attribute7
   IF p_venue_rates_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_venue_rates_rec.attribute7;
   END IF;

   -- attribute8
   IF p_venue_rates_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_venue_rates_rec.attribute8;
   END IF;

   -- attribute9
   IF p_venue_rates_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_venue_rates_rec.attribute9;
   END IF;

   -- attribute10
   IF p_venue_rates_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_venue_rates_rec.attribute10;
   END IF;

   -- attribute11
   IF p_venue_rates_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_venue_rates_rec.attribute11;
   END IF;

   -- attribute12
   IF p_venue_rates_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_venue_rates_rec.attribute12;
   END IF;

   -- attribute13
   IF p_venue_rates_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_venue_rates_rec.attribute13;
   END IF;

   -- attribute14
   IF p_venue_rates_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_venue_rates_rec.attribute14;
   END IF;

   -- attribute15
   IF p_venue_rates_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_venue_rates_rec.attribute15;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_venue_rates_Rec;
PROCEDURE Validate_venue_rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_venue_rates_rec               IN   venue_rates_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Venue_Rates';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_venue_rates_rec  AMS_Venue_Rates_PVT.venue_rates_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Venue_Rates_;

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
              Check_venue_rates_Items(
                 p_venue_rates_rec        => p_venue_rates_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_venue_rates_Rec(
         p_venue_rates_rec        => p_venue_rates_rec,
         x_complete_rec        => l_venue_rates_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_venue_rates_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_venue_rates_rec           =>    l_venue_rates_rec);

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
     ROLLBACK TO VALIDATE_Venue_Rates_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Venue_Rates_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Venue_Rates_;
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
End Validate_Venue_Rates;


PROCEDURE Validate_venue_rates_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_venue_rates_rec               IN    venue_rates_rec_type
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
END Validate_venue_rates_Rec;

END AMS_Venue_Rates_PVT;

/
