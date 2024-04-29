--------------------------------------------------------
--  DDL for Package Body AMS_DMLIFT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMLIFT_PUB" as
/* $Header: amspdlfb.pls 115.4 2002/01/07 18:52:02 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dmlift_PUB
-- Purpose
--
-- History
-- 21-Jan-2001 choang   Added overload procedure create_lift for
--                      ODM Accelerator integration.
-- 12-Feb-2001 choang   Removed rollback and savepoints for create_lift
--                      to be used by ODM Accelerator.
-- 12-Feb-2001 choang   Added call to validate_lift in create_lift for
--                      odm.
-- 07-Jan-2002 choang   removed security_group_id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dmlift_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspdlfb.pls';

PROCEDURE Lock_Dmlift(
    p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status  OUT  VARCHAR2,
    x_msg_count      OUT  NUMBER,
    x_msg_data       OUT  VARCHAR2,

    p_lift_id        IN  NUMBER,
    p_object_version IN  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Dmlift';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_Lift_rec    AMS_DMLift_PVT.Lift_rec_type;
BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Lift
    -- Hint: Primary key needs to be returned
     AMS_DMLift_PVT.Lock_Dmlift(
     p_api_version         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_lift_id     => p_lift_id,
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Dmlift_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Dmlift_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Dmlift_PUB;
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
End Lock_Dmlift;


PROCEDURE Create_Lift(
    p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit         IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status  OUT  VARCHAR2,
    x_msg_count      OUT  NUMBER,
    x_msg_data       OUT  VARCHAR2,

    p_lift_rec       IN   Lift_rec_type  := g_miss_Lift_rec,
    x_lift_id        OUT  NUMBER
     )

IS
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Create_Lift';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
   l_pvt_Lift_rec             AMS_DMLift_PVT.Lift_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Lift_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- l_pvt_lift_rec declared from the private API
      -- rec type and p_lift_rec declared from public
      -- API rec type.
      l_pvt_lift_rec.model_id := p_lift_rec.model_id;
      l_pvt_lift_rec.quantile := p_lift_rec.quantile;
      l_pvt_lift_rec.lift := p_lift_rec.lift;
      l_pvt_lift_rec.targets := p_lift_rec.targets;
      l_pvt_lift_rec.non_targets := p_lift_rec.non_targets;
      l_pvt_lift_rec.targets_cumm := p_lift_rec.targets_cumm;
      l_pvt_lift_rec.target_density := p_lift_rec.target_density;
      l_pvt_lift_rec.target_density_cumm := p_lift_rec.target_density_cumm;
      l_pvt_lift_rec.target_confidence := p_lift_rec.target_confidence;
      l_pvt_lift_rec.non_target_confidence := p_lift_rec.non_target_confidence;

    -- Calling Private package: Create_Lift
    -- Hint: Primary key needs to be returned
     AMS_DMLift_PVT.Create_Lift(
        p_api_version         => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_lift_rec            => l_pvt_lift_rec,
        x_lift_id             => x_lift_id);


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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

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
     ROLLBACK TO Create_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Lift_PUB;
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
End Create_Lift;


PROCEDURE Update_Lift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_lift_rec               IN    lift_rec_type,
    x_object_version_number      OUT  NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Lift';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number  NUMBER;
   l_pvt_Lift_rec  AMS_DMLift_PVT.Lift_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Lift_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    AMS_DMLift_PVT.Update_Lift(
    p_api_version         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_lift_rec  =>  l_pvt_lift_rec,
    x_object_version_number      => l_object_version_number );


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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

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
     ROLLBACK TO Update_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Lift_PUB;
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
End Update_Lift;


PROCEDURE Delete_Lift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    p_lift_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Lift';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_LIFT_ID  NUMBER := p_LIFT_ID;
   l_object_version_number  NUMBER := p_object_version_number;
   l_pvt_Lift_rec  AMS_DMLift_PVT.Lift_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Lift_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    AMS_DMLift_PVT.Delete_Lift(
    p_api_version         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_lift_id     => l_lift_id,
    p_object_version_number      => l_object_version_number );


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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

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
     ROLLBACK TO Delete_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Lift_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Lift_PUB;
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
End Delete_Lift;


PROCEDURE Create_Lift (
   p_model_id        IN NUMBER,
   p_quantile        IN NUMBER,
   p_lift            IN NUMBER,
   p_targets         IN NUMBER,
   p_non_targets     IN NUMBER,
   p_targets_cumm    IN NUMBER,
   p_target_density  IN NUMBER,
   p_target_density_cumm IN NUMBER,
   p_target_confidence  IN NUMBER,
   p_non_target_confidence IN NUMBER,
   x_lift_id         OUT NUMBER,
   x_return_status   OUT VARCHAR2
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Lift';
   L_API_VERSION        CONSTANT NUMBER := 1.0;

   l_lift_rec           AMS_DMLift_PVT.Lift_Rec_Type;
   l_lift_id               NUMBER;
   l_object_version_number NUMBER := 1;

   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);

   l_dummy     NUMBER;

   CURSOR c_lift_id IS
      SELECT ams_dm_lift_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (p_lift_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   ams_dm_lift
                     WHERE  lift_id = p_lift_id)
      ;
BEGIN
   -- Initialize return status
   x_return_status := FND_API.g_ret_sts_success;

   -- Construct the record for the private API
   l_lift_rec.model_id := p_model_id;
   l_lift_rec.quantile := p_quantile;
   l_lift_rec.lift := p_lift;
   l_lift_rec.targets := p_targets;
   l_lift_rec.non_targets := p_non_targets;
   l_lift_rec.targets_cumm := p_targets_cumm;
   l_lift_rec.target_density := p_target_density;
   l_lift_rec.target_density_cumm := p_target_density_cumm;
   l_lift_rec.target_confidence := p_target_confidence;
   l_lift_rec.non_target_confidence := p_non_target_confidence;


   -- validate input
   AMS_DMLift_PVT.validate_lift (
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.g_true,
      p_validation_level   => FND_API.g_valid_level_full,
      p_validation_mode    => JTF_PLSQL_API.G_UPDATE,
      p_lift_rec           => l_lift_rec,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
   );
   -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- get unique id
   LOOP
      l_dummy := NULL;

      OPEN c_lift_id;
      FETCH c_lift_id INTO l_lift_id;
      CLOSE c_lift_id;

      OPEN c_id_exists (l_lift_id);
      FETCH c_id_exists INTO l_dummy;
      CLOSE c_id_exists;

      EXIT WHEN l_dummy IS NULL;
   END LOOP;

   -- Call the table handler.
   -- Note: margin and roi are not used.
   ams_dm_lift_pkg.Insert_Row(
      px_LIFT_ID           => l_lift_id,
      p_LAST_UPDATE_DATE   => SYSDATE,
      p_LAST_UPDATED_BY    => FND_GLOBAL.user_id,
      p_CREATION_DATE      => SYSDATE,
      p_CREATED_BY         => FND_GLOBAL.user_id,
      p_LAST_UPDATE_LOGIN  => FND_GLOBAL.conc_login_id,
      px_OBJECT_VERSION_NUMBER   => l_object_version_number,
      p_MODEL_ID           => p_model_id,
      p_QUANTILE           => p_quantile,
      p_LIFT               =>p_lift,
      p_TARGETS            => p_targets,
      p_NON_TARGETS        => p_non_targets,
      p_TARGETS_CUMM       => p_targets_cumm,
      p_TARGET_DENSITY_CUMM   => p_target_density_cumm,
      p_TARGET_DENSITY     => p_target_density,
      p_MARGIN             => NULL,
      p_ROI                => NULL,
      p_TARGET_CONFIDENCE  => p_target_confidence,
      p_NON_TARGET_CONFIDENCE => p_non_target_confidence
   );
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
END;


END AMS_Dmlift_PUB;

/
