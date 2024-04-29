--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PERFORMANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PERFORMANCE_PVT" as
/* $Header: ozfvperb.pls 120.1 2005/09/07 19:20:29 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Performance_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Performance_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvperb.pls';

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Offer_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_perf_rec               IN   offer_perf_rec_type  := g_miss_offer_perf_rec,
    x_offer_performance_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Offer_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_OFFER_PERFORMANCE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT OZF_OFFER_PERFORMANCES_S.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_PERFORMANCES
      WHERE OFFER_PERFORMANCE_ID = l_id;

BEGIN
   --dbms_output.put_line('First message');
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Offer_Performance_PVT;

      ozf_utility_pvt.debug_message('inside create');
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
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_offer_perf_rec.OFFER_PERFORMANCE_ID IS NULL OR p_offer_perf_rec.OFFER_PERFORMANCE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_OFFER_PERFORMANCE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_OFFER_PERFORMANCE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
	  END LOOP;
   ELSE
          l_offer_performance_id := p_offer_perf_rec.offer_performance_id;

   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 ozf_utility_pvt.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          ozf_utility_pvt.debug_message('Private API: Validate_Offer_Performance');

          -- Invoke validation procedures
          Validate_offer_performance(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_offer_perf_rec  =>  p_offer_perf_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      ozf_utility_pvt.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(OZF_OFFER_PERFORMANCES_PKG.Insert_Row)
      OZF_OFFER_PERFORMANCES_PKG.Insert_Row(
          px_offer_performance_id  => l_offer_performance_id,
          p_list_header_id  => p_offer_perf_rec.list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_product_attribute_context  => p_offer_perf_rec.product_attribute_context,
          p_product_attribute  => p_offer_perf_rec.product_attribute,
          p_product_attr_value  => p_offer_perf_rec.product_attr_value,
          p_channel_id  => p_offer_perf_rec.channel_id,
          p_start_date  => p_offer_perf_rec.start_date,
          p_end_date  => p_offer_perf_rec.end_date,
          p_estimated_value  => p_offer_perf_rec.estimated_value,
          p_required_flag  => p_offer_perf_rec.required_flag,
          p_attribute_category  => p_offer_perf_rec.attribute_category,
          p_attribute1  => p_offer_perf_rec.attribute1,
          p_attribute2  => p_offer_perf_rec.attribute2,
          p_attribute3  => p_offer_perf_rec.attribute3,
          p_attribute4  => p_offer_perf_rec.attribute4,
          p_attribute5  => p_offer_perf_rec.attribute5,
          p_attribute6  => p_offer_perf_rec.attribute6,
          p_attribute7  => p_offer_perf_rec.attribute7,
          p_attribute8  => p_offer_perf_rec.attribute8,
          p_attribute9  => p_offer_perf_rec.attribute9,
          p_attribute10  => p_offer_perf_rec.attribute10,
          p_attribute11  => p_offer_perf_rec.attribute11,
          p_attribute12  => p_offer_perf_rec.attribute12,
          p_attribute13  => p_offer_perf_rec.attribute13,
          p_attribute14  => p_offer_perf_rec.attribute14,
          p_attribute15  => p_offer_perf_rec.attribute15,
          p_security_group_id  => p_offer_perf_rec.security_group_id,
          p_requirement_type => p_offer_perf_rec.requirement_type,
          p_uom_code     => p_offer_perf_rec.uom_code,
          p_description  => p_offer_perf_rec.description);

          x_offer_performance_id := l_offer_performance_id;
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
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN ozf_utility_pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 ozf_utility_pvt.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offer_Performance_PVT;
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
End Create_Offer_Performance;


PROCEDURE Update_Offer_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_perf_rec               IN    offer_perf_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_offer_performance(l_offer_performance_id NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_PERFORMANCES
    where offer_performance_id = l_offer_performance_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offer_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_OFFER_PERFORMANCE_ID    NUMBER;
l_ref_offer_perf_rec  c_get_Offer_Performance%ROWTYPE ;
l_tar_offer_perf_rec  OZF_Offer_Performance_PVT.offer_perf_rec_type := P_offer_perf_rec;
l_rowid  ROWID;

 BEGIN
    --dbms_output.put_line('second message');
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Offer_Performance_PVT;
       ozf_utility_pvt.debug_message('Inside update Private API: - Open Cursor to Select');
       ozf_utility_pvt.debug_message('Inside update Private API: - Open Cursor to Select');
      -- Standard call to check for call compatibility.
        --  RAISE FND_API.G_EXC_ERROR;
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
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: - Open Cursor to Select');


      OPEN c_get_Offer_Performance( l_tar_offer_perf_rec.offer_performance_id);

      FETCH c_get_Offer_Performance INTO l_ref_offer_perf_rec  ;

       If ( c_get_Offer_Performance%NOTFOUND) THEN
  ozf_utility_pvt.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Performance') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       ozf_utility_pvt.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Offer_Performance;



      If (l_tar_offer_perf_rec.object_version_number is NULL or
          l_tar_offer_perf_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  ozf_utility_pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_offer_perf_rec.object_version_number <> l_ref_offer_perf_rec.object_version_number) Then
  ozf_utility_pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Performance') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          ozf_utility_pvt.debug_message('Private API: Validate_Offer_Performance');

          -- Invoke validation procedures
          Validate_offer_performance(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_offer_perf_rec  =>  p_offer_perf_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;
ozf_utility_pvt.debug_message('out of validate');

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

ozf_utility_pvt.debug_message('out OUT NOCOPY out of validate');
      -- Debug Message
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW||'Private API: Calling update table handler');
      l_object_version_number := l_tar_offer_perf_rec.object_version_number + 1;
      -- Invoke table handler(OZF_OFFER_PERFORMANCES_PKG.Update_Row)
      OZF_OFFER_PERFORMANCES_PKG.Update_Row(
          p_offer_performance_id  => p_offer_perf_rec.offer_performance_id,
          p_list_header_id  => p_offer_perf_rec.list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
	  p_creation_date  => p_offer_perf_rec.creation_date,
          p_created_by  => p_offer_perf_rec.created_by,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => l_object_version_number,
          p_product_attribute_context  => p_offer_perf_rec.product_attribute_context,
          p_product_attribute  => p_offer_perf_rec.product_attribute,
          p_product_attr_value  => p_offer_perf_rec.product_attr_value,
          p_channel_id  => p_offer_perf_rec.channel_id,
          p_start_date  => p_offer_perf_rec.start_date,
          p_end_date  => p_offer_perf_rec.end_date,
          p_estimated_value  => p_offer_perf_rec.estimated_value,
         p_required_flag  => p_offer_perf_rec.required_flag,
         p_attribute_category  => p_offer_perf_rec.attribute_category,
          p_attribute1  => p_offer_perf_rec.attribute1,
          p_attribute2  => p_offer_perf_rec.attribute2,
          p_attribute3  => p_offer_perf_rec.attribute3,
          p_attribute4  => p_offer_perf_rec.attribute4,
          p_attribute5  => p_offer_perf_rec.attribute5,
          p_attribute6  => p_offer_perf_rec.attribute6,
          p_attribute7  => p_offer_perf_rec.attribute7,
          p_attribute8  => p_offer_perf_rec.attribute8,
          p_attribute9  => p_offer_perf_rec.attribute9,
          p_attribute10  => p_offer_perf_rec.attribute10,
          p_attribute11  => p_offer_perf_rec.attribute11,
          p_attribute12  => p_offer_perf_rec.attribute12,
          p_attribute13  => p_offer_perf_rec.attribute13,
          p_attribute14  => p_offer_perf_rec.attribute14,
          p_attribute15  => p_offer_perf_rec.attribute15,
          p_security_group_id  => p_offer_perf_rec.security_group_id,
          p_requirement_type => p_offer_perf_rec.requirement_type,
          p_uom_code     => p_offer_perf_rec.uom_code,
          p_description  => p_offer_perf_rec.description);

          x_object_version_number := p_offer_perf_rec.object_version_number + 1;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN ozf_utility_pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 ozf_utility_pvt.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offer_Performance_PVT;
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
End Update_Offer_Performance;


PROCEDURE Delete_Offer_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_performance_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offer_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
    --dbms_output.put_line('Third message');
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Offer_Performance_PVT;

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
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      ozf_utility_pvt.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(OZF_OFFER_PERFORMANCES_PKG.Delete_Row)
      OZF_OFFER_PERFORMANCES_PKG.Delete_Row(
          p_OFFER_PERFORMANCE_ID  => p_OFFER_PERFORMANCE_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN ozf_utility_pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 ozf_utility_pvt.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offer_Performance_PVT;
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
End Delete_Offer_Performance;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Offer_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_performance_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offer_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_OFFER_PERFORMANCE_ID                  NUMBER;

CURSOR c_Offer_Performance IS
   SELECT OFFER_PERFORMANCE_ID
   FROM OZF_OFFER_PERFORMANCES
   WHERE OFFER_PERFORMANCE_ID = p_OFFER_PERFORMANCE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN
    --dbms_output.put_line('Fourth message');
      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'start');

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

  ozf_utility_pvt.debug_message(l_full_name||': start');
  OPEN c_Offer_Performance;

  FETCH c_Offer_Performance INTO l_OFFER_PERFORMANCE_ID;

  IF (c_Offer_Performance%NOTFOUND) THEN
    CLOSE c_Offer_Performance;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Offer_Performance;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  ozf_utility_pvt.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN ozf_utility_pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 ozf_utility_pvt.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offer_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offer_Performance_PVT;
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
End Lock_Offer_Performance;


PROCEDURE check_offer_perf_uk_items(
    p_offer_perf_rec               IN   offer_perf_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);


BEGIN
      x_return_status := FND_API.g_ret_sts_success;

      ozf_utility_pvt.debug_message('inside uk='||p_validation_mode||''||p_offer_perf_rec.OFFER_PERFORMANCE_ID);
      ozf_utility_pvt.debug_message('ins'||p_offer_perf_rec.PRODUCT_ATTRIBUTE);
      ozf_utility_pvt.debug_message('ins'||p_offer_perf_rec.PRODUCT_ATTR_VALUE);
      ozf_utility_pvt.debug_message('ins'||p_offer_perf_rec.CHANNEL_ID);



      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
	 l_valid_flag := ozf_utility_pvt.check_uniqueness(
         'OZF_OFFER_PERFORMANCES',
         ' PRODUCT_ATTRIBUTE  ='||' '||p_offer_perf_rec.PRODUCT_ATTRIBUTE ||''||
	 ' AND PRODUCT_ATTR_VALUE  ='||' '|| p_offer_perf_rec.PRODUCT_ATTR_VALUE||''||
	 ' AND CHANNEL_ID  = '||' '|| p_offer_perf_rec.CHANNEL_ID||' '||
	 ' AND LIST_HEADER_ID = '||' '|| p_offer_perf_rec.LIST_HEADER_ID
	 );

      ELSE
	-- l_valid_flag := ozf_utility_pvt.check_uniqueness('OZF_OFFER_PERFORMANCES','OFFER_PERFORMANCE_ID = '||' '||p_offer_perf_rec.offer_performance_id||' '||
	-- ' AND REQUIRED_FLAG  = '||' '|| p_offer_perf_rec.REQUIRED_FLAG||''||
	-- ' AND ESTIMATED_VALUE  = '||' '|| p_offer_perf_rec.ESTIMATED_VALUE||' '||
	-- ' AND START_DATE  = '||' '|| p_offer_perf_rec.START_DATE||' '||
	-- ' AND END_DATE  = '||' '|| p_offer_perf_rec.END_DATE||' '
	-- );
	l_valid_flag := FND_API.g_true;
      END IF;
     ozf_utility_pvt.debug_message('inside uk middle');
      IF l_valid_flag = FND_API.g_false THEN
        ozf_utility_pvt.Error_Message(p_message_name => 'OZF_PERFORMANCE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
       ozf_utility_pvt.debug_message('inside uk end');
END check_offer_perf_uk_items;

PROCEDURE check_offer_perf_req_items(
    p_offer_perf_rec               IN  offer_perf_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

  -- IF p_validation_mode = JTF_PLSQL_API.g_create THEN
  -- ELSE
   --END IF;
  IF p_offer_perf_rec.channel_id = -1 THEN
    IF p_offer_perf_rec.requirement_type IS NULL OR p_offer_perf_rec.requirement_type = fnd_api.g_miss_char THEN
      ozf_utility_pvt.Error_Message('OZF', 'OZF_PERF_NO_REQ_TYPE');
      x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_offer_perf_rec.estimated_value IS NULL OR p_offer_perf_rec.estimated_value = fnd_api.g_miss_num THEN
      ozf_utility_pvt.Error_Message('OZF', 'OZF_PERF_NO_EST_VALUE');
      x_return_status := FND_API.g_ret_sts_error;
    END IF;
  END IF;

  IF p_offer_perf_rec.requirement_type = 'VOLUME' THEN
    IF p_offer_perf_rec.uom_code IS NULL OR p_offer_perf_rec.uom_code = fnd_api.g_miss_char THEN
      ozf_utility_pvt.Error_Message('OZF', 'OZF_PERF_NO_UOM');
      x_return_status := FND_API.g_ret_sts_error;
    END IF;
  END IF;

END check_offer_perf_req_items;

PROCEDURE check_offer_perf_FK_items(
    p_offer_perf_rec IN offer_perf_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_offer_perf_FK_items;

PROCEDURE check_offer_perf_Lookup_items(
    p_offer_perf_rec IN offer_perf_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_offer_perf_Lookup_items;

PROCEDURE Check_offer_perf_Items (
    P_offer_perf_rec     IN    offer_perf_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
ozf_utility_pvt.debug_message('inside items validation mode='||p_validation_mode);
ozf_utility_pvt.debug_message('inside items validation mode='||p_validation_mode);


   check_offer_perf_uk_items(
      p_offer_perf_rec => p_offer_perf_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_offer_perf_req_items(
      p_offer_perf_rec => p_offer_perf_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_offer_perf_FK_items(
      p_offer_perf_rec => p_offer_perf_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_offer_perf_Lookup_items(
      p_offer_perf_rec => p_offer_perf_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_offer_perf_Items;



PROCEDURE Complete_offer_perf_Rec (
   p_offer_perf_rec IN offer_perf_rec_type,
   x_complete_rec OUT NOCOPY offer_perf_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM OZF_offer_performances
      WHERE offer_performance_id = p_offer_perf_rec.offer_performance_id;
   l_offer_perf_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offer_perf_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_offer_perf_rec;
   CLOSE c_complete;

   -- offer_performance_id
   IF p_offer_perf_rec.offer_performance_id = FND_API.g_miss_num THEN
      x_complete_rec.offer_performance_id := l_offer_perf_rec.offer_performance_id;
   END IF;

   -- list_header_id
   IF p_offer_perf_rec.list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.list_header_id := l_offer_perf_rec.list_header_id;
   END IF;

   -- last_update_date
   IF p_offer_perf_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_offer_perf_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offer_perf_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_offer_perf_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offer_perf_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_offer_perf_rec.creation_date;
   END IF;

   -- created_by
   IF p_offer_perf_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_offer_perf_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offer_perf_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_offer_perf_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offer_perf_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_offer_perf_rec.object_version_number;
   END IF;

   -- product_attribute_context
   IF p_offer_perf_rec.product_attribute_context = FND_API.g_miss_char THEN
      x_complete_rec.product_attribute_context := l_offer_perf_rec.product_attribute_context;
   END IF;

   -- product_attribute
   IF p_offer_perf_rec.product_attribute = FND_API.g_miss_char THEN
      x_complete_rec.product_attribute := l_offer_perf_rec.product_attribute;
   END IF;

   -- product_attr_value
   IF p_offer_perf_rec.product_attr_value = FND_API.g_miss_char THEN
      x_complete_rec.product_attr_value := l_offer_perf_rec.product_attr_value;
   END IF;

   -- channel_id
   IF p_offer_perf_rec.channel_id = FND_API.g_miss_num THEN
      x_complete_rec.channel_id := l_offer_perf_rec.channel_id;
   END IF;

   -- start_date
   IF p_offer_perf_rec.start_date = FND_API.g_miss_date THEN
      x_complete_rec.start_date := l_offer_perf_rec.start_date;
   END IF;

   -- end_date
   IF p_offer_perf_rec.end_date = FND_API.g_miss_date THEN
      x_complete_rec.end_date := l_offer_perf_rec.end_date;
   END IF;

   -- estimated_value
   IF p_offer_perf_rec.estimated_value = FND_API.g_miss_num THEN
      x_complete_rec.estimated_value := l_offer_perf_rec.estimated_value;
   END IF;

   -- required_flag
   IF p_offer_perf_rec.required_flag = FND_API.g_miss_char THEN
      x_complete_rec.required_flag := l_offer_perf_rec.required_flag;
   END IF;

   -- attribute_category
   IF p_offer_perf_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_offer_perf_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_offer_perf_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_offer_perf_rec.attribute1;
   END IF;

   -- attribute2
   IF p_offer_perf_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_offer_perf_rec.attribute2;
   END IF;

   -- attribute3
   IF p_offer_perf_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_offer_perf_rec.attribute3;
   END IF;

   -- attribute4
   IF p_offer_perf_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_offer_perf_rec.attribute4;
   END IF;

   -- attribute5
   IF p_offer_perf_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_offer_perf_rec.attribute5;
   END IF;

   -- attribute6
   IF p_offer_perf_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_offer_perf_rec.attribute6;
   END IF;

   -- attribute7
   IF p_offer_perf_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_offer_perf_rec.attribute7;
   END IF;

   -- attribute8
   IF p_offer_perf_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_offer_perf_rec.attribute8;
   END IF;

   -- attribute9
   IF p_offer_perf_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_offer_perf_rec.attribute9;
   END IF;

   -- attribute10
   IF p_offer_perf_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_offer_perf_rec.attribute10;
   END IF;

   -- attribute11
   IF p_offer_perf_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_offer_perf_rec.attribute11;
   END IF;

   -- attribute12
   IF p_offer_perf_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_offer_perf_rec.attribute12;
   END IF;

   -- attribute13
   IF p_offer_perf_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_offer_perf_rec.attribute13;
   END IF;

   -- attribute14
   IF p_offer_perf_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_offer_perf_rec.attribute14;
   END IF;

   -- attribute15
   IF p_offer_perf_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_offer_perf_rec.attribute15;
   END IF;

   -- security_group_id
   IF p_offer_perf_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_offer_perf_rec.security_group_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_offer_perf_Rec;
PROCEDURE Validate_offer_performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offer_perf_rec               IN   offer_perf_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offer_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offer_perf_rec  OZF_Offer_Performance_PVT.offer_perf_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Offer_Performance_;

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
              Check_offer_perf_Items(
                 p_offer_perf_rec        => p_offer_perf_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_offer_perf_Rec(
         p_offer_perf_rec        => p_offer_perf_rec,
         x_complete_rec        => l_offer_perf_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offer_perf_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offer_perf_rec           =>    l_offer_perf_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN ozf_utility_pvt.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 ozf_utility_pvt.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Performance_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Performance_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offer_Performance_;
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
End Validate_Offer_Performance;


PROCEDURE Validate_offer_perf_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_perf_rec               IN    offer_perf_rec_type
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
      ozf_utility_pvt.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offer_perf_Rec;


END OZF_Offer_Performance_PVT;

/
