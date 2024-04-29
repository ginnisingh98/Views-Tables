--------------------------------------------------------
--  DDL for Package Body AMS_DMMODEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMMODEL_PUB" as
/* $Header: amspdmmb.pls 115.11 2002/12/17 04:11:48 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMModel_PUB
-- Purpose
--
-- History
-- 02-Feb-2001 choang   Added new columns.
-- 08-Feb-2001 choang   Create_Model for ODM Accelerator changed to use
--                      table handler to avoid using savepoint and rollback
--                      due to distributed transaction restrictions.
-- 16-Feb-2001 choang   Replaced top_down_flag with row_selection_type.
-- 26-Feb-2001 choang   Added custom_setup_id, country_id, and best_subtree.
-- 01-May-2001 choang   Added wf_itemkey to create_model.
-- 16-Sep-2001 choang   Added custom_setup_id in pvt create api call.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DMModel_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspdmmb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Model(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,

    p_model_rec            IN   model_rec_type := g_miss_model_rec,
    x_model_id             OUT NOCOPY  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Model';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_model_rec    AMS_DM_Model_PVT.dm_model_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Model_PUB;

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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- construct private record using public record
      l_pvt_model_rec.model_id := p_model_rec.model_id;
      l_pvt_model_rec.model_type := p_model_rec.model_type;
      l_pvt_model_rec.user_status_id := p_model_rec.user_status_id;
      l_pvt_model_rec.status_code := p_model_rec.status_code;
      l_pvt_model_rec.status_date := p_model_rec.status_date;
      l_pvt_model_rec.last_build_date := p_model_rec.last_build_date;
      l_pvt_model_rec.owner_user_id := p_model_rec.owner_user_id;
      l_pvt_model_rec.scheduled_date := p_model_rec.scheduled_date;
      l_pvt_model_rec.scheduled_timezone_id := p_model_rec.scheduled_timezone_id;
      l_pvt_model_rec.expiration_date := p_model_rec.expiration_date;
      l_pvt_model_rec.custom_setup_id := p_model_rec.custom_setup_id;
      l_pvt_model_rec.country_id := p_model_rec.country_id;
      l_pvt_model_rec.best_subtree := p_model_rec.best_subtree;
      l_pvt_model_rec.results_flag := p_model_rec.results_flag;
      l_pvt_model_rec.logs_flag := p_model_rec.logs_flag;
      l_pvt_model_rec.target_field := p_model_rec.target_field;
      l_pvt_model_rec.target_type := p_model_rec.target_type;
      l_pvt_model_rec.target_positive_value := p_model_rec.target_positive_value;
      l_pvt_model_rec.min_records := p_model_rec.min_records;
      l_pvt_model_rec.max_records := p_model_rec.max_records;
      l_pvt_model_rec.row_selection_type := p_model_rec.row_selection_type;
      l_pvt_model_rec.every_nth_row := p_model_rec.every_nth_row;
      l_pvt_model_rec.pct_random := p_model_rec.pct_random;
      l_pvt_model_rec.performance := p_model_rec.performance;
      l_pvt_model_rec.target_group_type := p_model_rec.target_group_type;
      l_pvt_model_rec.darwin_model_ref := p_model_rec.darwin_model_ref;
      l_pvt_model_rec.attribute_category := p_model_rec.attribute_category;
      l_pvt_model_rec.attribute1 := p_model_rec.attribute1;
      l_pvt_model_rec.attribute2 := p_model_rec.attribute2;
      l_pvt_model_rec.attribute3 := p_model_rec.attribute3;
      l_pvt_model_rec.attribute4 := p_model_rec.attribute4;
      l_pvt_model_rec.attribute5 := p_model_rec.attribute5;
      l_pvt_model_rec.attribute6 := p_model_rec.attribute6;
      l_pvt_model_rec.attribute7 := p_model_rec.attribute7;
      l_pvt_model_rec.attribute8 := p_model_rec.attribute8;
      l_pvt_model_rec.attribute9 := p_model_rec.attribute9;
      l_pvt_model_rec.attribute10 := p_model_rec.attribute10;
      l_pvt_model_rec.attribute11 := p_model_rec.attribute11;
      l_pvt_model_rec.attribute12 := p_model_rec.attribute12;
      l_pvt_model_rec.attribute13 := p_model_rec.attribute13;
      l_pvt_model_rec.attribute14 := p_model_rec.attribute14;
      l_pvt_model_rec.attribute15 := p_model_rec.attribute15;
      l_pvt_model_rec.model_name := p_model_rec.model_name;
      l_pvt_model_rec.description := p_model_rec.description;

      -- Calling Private package: Create_Model
      AMS_Dm_model_PVT.Create_DM_Model(
         p_api_version_number => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => FND_API.G_FALSE,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_dm_model_rec       => l_pvt_model_rec,
         x_custom_setup_id    => l_pvt_model_rec.custom_setup_id,
         x_model_id           => x_model_id
     );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Model_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Model_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Model_PUB;
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
End Create_Model;


PROCEDURE Update_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_model_rec               IN    model_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Model';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number  NUMBER;
   l_pvt_model_rec  AMS_DM_Model_PVT.dm_model_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Model_PUB;

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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- construct private record using public record
      l_pvt_model_rec.model_id := p_model_rec.model_id;
      l_pvt_model_rec.object_version_number := p_model_rec.object_version_number;
      l_pvt_model_rec.model_type := p_model_rec.model_type;
      l_pvt_model_rec.user_status_id := p_model_rec.user_status_id;
      l_pvt_model_rec.status_code := p_model_rec.status_code;
      l_pvt_model_rec.status_date := p_model_rec.status_date;
      l_pvt_model_rec.last_build_date := p_model_rec.last_build_date;
      l_pvt_model_rec.owner_user_id := p_model_rec.owner_user_id;
      l_pvt_model_rec.scheduled_date := p_model_rec.scheduled_date;
      l_pvt_model_rec.scheduled_timezone_id := p_model_rec.scheduled_timezone_id;
      l_pvt_model_rec.expiration_date := p_model_rec.expiration_date;
      l_pvt_model_rec.custom_setup_id := p_model_rec.custom_setup_id;
      l_pvt_model_rec.country_id := p_model_rec.country_id;
      l_pvt_model_rec.best_subtree := p_model_rec.best_subtree;
      l_pvt_model_rec.results_flag := p_model_rec.results_flag;
      l_pvt_model_rec.logs_flag := p_model_rec.logs_flag;
      l_pvt_model_rec.target_field := p_model_rec.target_field;
      l_pvt_model_rec.target_type := p_model_rec.target_type;
      l_pvt_model_rec.target_positive_value := p_model_rec.target_positive_value;
      l_pvt_model_rec.min_records := p_model_rec.min_records;
      l_pvt_model_rec.max_records := p_model_rec.max_records;
      l_pvt_model_rec.row_selection_type := p_model_rec.row_selection_type;
      l_pvt_model_rec.every_nth_row := p_model_rec.every_nth_row;
      l_pvt_model_rec.pct_random := p_model_rec.pct_random;
      l_pvt_model_rec.performance := p_model_rec.performance;
      l_pvt_model_rec.target_group_type := p_model_rec.target_group_type;
      l_pvt_model_rec.darwin_model_ref := p_model_rec.darwin_model_ref;
      l_pvt_model_rec.attribute_category := p_model_rec.attribute_category;
      l_pvt_model_rec.attribute1 := p_model_rec.attribute1;
      l_pvt_model_rec.attribute2 := p_model_rec.attribute2;
      l_pvt_model_rec.attribute3 := p_model_rec.attribute3;
      l_pvt_model_rec.attribute4 := p_model_rec.attribute4;
      l_pvt_model_rec.attribute5 := p_model_rec.attribute5;
      l_pvt_model_rec.attribute6 := p_model_rec.attribute6;
      l_pvt_model_rec.attribute7 := p_model_rec.attribute7;
      l_pvt_model_rec.attribute8 := p_model_rec.attribute8;
      l_pvt_model_rec.attribute9 := p_model_rec.attribute9;
      l_pvt_model_rec.attribute10 := p_model_rec.attribute10;
      l_pvt_model_rec.attribute11 := p_model_rec.attribute11;
      l_pvt_model_rec.attribute12 := p_model_rec.attribute12;
      l_pvt_model_rec.attribute13 := p_model_rec.attribute13;
      l_pvt_model_rec.attribute14 := p_model_rec.attribute14;
      l_pvt_model_rec.attribute15 := p_model_rec.attribute15;
      l_pvt_model_rec.model_name := p_model_rec.model_name;
      l_pvt_model_rec.description := p_model_rec.description;

      AMS_DM_Model_PVT.Update_DM_Model(
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => p_commit,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_dm_model_rec  =>      l_pvt_model_rec,
         x_object_version_number => l_object_version_number
      );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Model_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Model_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Model_PUB;
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
End Update_Model;


PROCEDURE Delete_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_model_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Model';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_MODEL_ID  NUMBER := p_MODEL_ID;
   l_object_version_number  NUMBER := p_object_version_number;
   l_pvt_model_rec  AMS_DM_Model_PVT.dm_model_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Model_PUB;

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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      AMS_DM_Model_PVT.Delete_DM_Model(
         p_api_version_number => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => p_commit,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_model_id           => l_model_id,
         p_object_version_number => l_object_version_number );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Model_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Model_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Model_PUB;
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
End Delete_Model;


PROCEDURE Lock_Model(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_model_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Model';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_model_rec    AMS_DM_Model_PVT.dm_model_rec_type;
 BEGIN

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

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Model
    -- Hint: Primary key needs to be returned
     AMS_DM_Model_PVT.Lock_DM_Model(
     p_api_version_number         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_model_id     => p_model_id,
     p_object_version             => p_object_version);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Model_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Model_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Model_PUB;
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
End Lock_Model;


PROCEDURE Create_Model (
   p_model_type      IN VARCHAR2,
   p_model_name      IN VARCHAR2,
   p_target_group_type  IN VARCHAR2 := 'CONSUMER',
   p_target_type     IN VARCHAR2 := 'BINARY',
   p_target_field    IN VARCHAR2,
   p_target_value    IN VARCHAR2,
   p_darwin_model_ref   IN VARCHAR2 := NULL,
   p_description     IN VARCHAR2,
   x_model_id        OUT NOCOPY NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Create_Model';
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_MODEL_STATUS_TYPE     CONSTANT VARCHAR2(30) := 'AMS_DM_MODEL_STATUS';
   L_CUSTOM_MODEL_STATUS   CONSTANT VARCHAR2(30) := 'CUSTOM';
   L_STANDARD_ROW_SELECTION   CONSTANT VARCHAR2(30) := 'STANDARD';
   L_OBJECT_TYPE_MODEL     CONSTANT VARCHAR2(30) := 'MODL';

   l_model_rec          AMS_DM_Model_PVT.dm_model_rec_type;

   l_dummy              NUMBER;

   l_msg_count    NUMBER;
   l_msg_data     VARCHAR2(4000);

   CURSOR c_user_status_id (p_type IN VARCHAR2, p_code IN VARCHAR2) IS
      SELECT user_status_id
      FROM   ams_user_statuses_vl
      WHERE  system_status_type = p_type
      AND    system_status_code = p_code;

   CURSOR c_custom_setup_id IS
      SELECT custom_setup_id
      FROM   ams_custom_setups_b
      WHERE  object_type = L_OBJECT_TYPE_MODEL
      AND    enabled_flag = 'Y'
      ;

   CURSOR c_model_id IS
      SELECT ams_dm_models_all_b_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (p_model_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_dm_models_all_b
                    WHERE  model_id = p_model_id)
      ;
BEGIN
   -- Initialize return status
   x_return_status := FND_API.g_ret_sts_success;

   -- Initialize message buffer
   FND_MSG_PUB.initialize;


   -- construct record for validation
   -- get a unique model id
   LOOP
      OPEN c_model_id;
      FETCH c_model_id INTO l_model_rec.model_id;
      CLOSE c_model_id;

      OPEN c_id_exists (l_model_rec.model_id);
      FETCH c_id_exists INTO l_dummy;
      CLOSE c_id_exists;

      EXIT WHEN l_dummy IS NULL;
   END LOOP;

   -- Since this API is exposed for creation of custom
   -- models created outside of OMO, the status is CUSTOM
   -- to handle metadata driven locking rules.
   OPEN c_user_status_id (L_MODEL_STATUS_TYPE, L_CUSTOM_MODEL_STATUS);
   FETCH c_user_status_id INTO l_model_rec.user_status_id;
   CLOSE c_user_status_id;

   OPEN c_custom_setup_id;
   FETCH c_custom_setup_id INTO l_model_rec.custom_setup_id;
   CLOSE c_custom_setup_id;

   l_model_rec.model_type := 'CUSTOM';
   l_model_rec.status_code := L_CUSTOM_MODEL_STATUS;
   l_model_rec.status_date := SYSDATE;
   l_model_rec.owner_user_id := AMS_Utility_PVT.get_resource_id (FND_GLOBAL.user_id);
   l_model_rec.target_group_type := p_target_group_type;
   l_model_rec.darwin_model_ref := p_darwin_model_ref;
   l_model_rec.model_name := p_model_name;
   l_model_rec.description := p_description;
   l_model_rec.results_flag := 'Y';
   l_model_rec.logs_flag := 'N';
   l_model_rec.target_type := p_target_type;
   l_model_rec.target_positive_value := p_target_value;
   l_model_rec.row_selection_type := L_STANDARD_ROW_SELECTION;
   l_model_rec.country_id := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');

   -- validate input
   AMS_DM_Model_PVT.Validate_dm_model(
      p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_validation_mode    => JTF_PLSQL_API.g_create,
      p_dm_model_rec       => l_model_rec,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- call the table handler
   --AMS_dm_models_b_pkg.insert_row (
   --   p_model_id           => l_model_rec.model_id,
   --   p_last_update_date   => SYSDATE,
   --   p_last_updated_by    => FND_GLOBAL.user_id,
   --   p_creation_date      => SYSDATE,
   --   p_created_by         => FND_GLOBAL.user_id,
   --   p_last_update_login  => FND_GLOBAL.conc_login_id,
   --   p_object_version_number => 1,
   --   p_model_type         => l_model_rec.model_type,
   --   p_user_status_id     => l_model_rec.user_status_id,
   --   p_status_code        => l_model_rec.status_code,
   --   p_status_date        => l_model_rec.status_date,
   --   p_last_build_date    => NULL,
   --   p_owner_user_id      => l_model_rec.owner_user_id,
   --   p_performance        => NULL,
   --   p_target_group_type  => l_model_rec.target_group_type,
   --   p_darwin_model_ref   => l_model_rec.darwin_model_ref,
   --   p_model_name         => l_model_rec.model_name,
   --   p_description        => l_model_rec.description,
   --   p_scheduled_date     => NULL,
   --   p_scheduled_timezone_id => NULL,
   --   p_expiration_date    => NULL,
   --   p_results_flag       => l_model_rec.results_flag,
   --   p_logs_flag          => l_model_rec.logs_flag,
   --   p_target_field       => NULL,
   --   p_target_type        => l_model_rec.target_type,
   --   p_target_positive_value => l_model_rec.target_positive_value,
   --   p_total_records      => NULL,
   --   p_total_positives    => NULL,
   --   p_min_records        => NULL,
   --   p_max_records        => NULL,
   --   p_row_selection_type => l_model_rec.row_selection_type,
   --   p_every_nth_row      => NULL,
   --   p_pct_random         => NULL,
   --   p_custom_setup_id    => l_model_rec.custom_setup_id,
   --   p_country_id         => l_model_rec.country_id,
   --   p_best_subtree       => NULL,
   --   p_wf_itemkey         => NULL,
   --   p_attribute_category => NULL,
   --   p_attribute1         => NULL,
   --   p_attribute2         => NULL,
   --   p_attribute3         => NULL,
   --   p_attribute4         => NULL,
   --  p_attribute5         => NULL,
   --   p_attribute6         => NULL,
   --   p_attribute7         => NULL,
   --   p_attribute8         => NULL,
   --   p_attribute9         => NULL,
   --   p_attribute10        => NULL,
   --   p_attribute11        => NULL,
   --   p_attribute12        => NULL,
   --   p_attribute13        => NULL,
   --   p_attribute14        => NULL,
   --   p_attribute15        => NULL
   --);

   x_model_id := l_model_rec.model_id;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
END Create_Model;


END AMS_DMModel_PUB;

/
