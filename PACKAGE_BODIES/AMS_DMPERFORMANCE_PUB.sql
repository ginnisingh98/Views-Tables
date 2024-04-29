--------------------------------------------------------
--  DDL for Package Body AMS_DMPERFORMANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMPERFORMANCE_PUB" as
/* $Header: amspdpfb.pls 115.5 2002/01/07 18:52:07 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMPerformance_PUB
-- Purpose
--
-- History
-- 01-Feb-2001 choang   Changed create_performance for accelerator api
--                      to reset message and perform commit.
-- 08-Feb-2001 choang   Changed create_performance for accelerator api
--                      to call table handler instead of private api
--                      and remove savepoint and rollback.
-- 12-Feb-2001 choang   Added call to validate in create_performance
--                      for odm.
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DMPerformance_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspdpfb.pls';

PROCEDURE Create_Performance (
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status        OUT  VARCHAR2,
    x_msg_count            OUT  NUMBER,
    x_msg_data             OUT  VARCHAR2,

    p_performance_rec      IN   performance_rec_type  := g_miss_performance_rec,
    x_performance_id       OUT  NUMBER
)

IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Create_Performance';
   L_API_VERSION_NUMBER    CONSTANT NUMBER   := 1.0;
   l_pvt_performance_rec   AMS_DMPerformance_PVT.performance_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Performance_PUB;

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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Assign public record values to private record for API
      l_pvt_performance_rec.performance_id := p_performance_rec.performance_id;
      l_pvt_performance_rec.predicted_value := p_performance_rec.predicted_value;
      l_pvt_performance_rec.actual_value := p_performance_rec.actual_value;
      l_pvt_performance_rec.evaluated_records := p_performance_rec.evaluated_records;
      l_pvt_performance_rec.total_records_predicted := p_performance_rec.total_records_predicted;
      l_pvt_performance_rec.model_id := p_performance_rec.model_id;

    -- Calling Private package: Create_Performance
    -- Hint: Primary key needs to be returned
     AMS_DMPerformance_PVT.Create_Performance(
        p_api_version_number  => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_performance_rec     => l_pvt_performance_rec,
        x_performance_id      => x_performance_id
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
     ROLLBACK TO Create_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Performance_PUB;
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
End Create_Performance;


PROCEDURE Update_Performance(
    p_api_version_number      IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status           OUT  VARCHAR2,
    x_msg_count               OUT  NUMBER,
    x_msg_data                OUT  VARCHAR2,

    p_performance_rec         IN    performance_rec_type,
    x_object_version_number   OUT  NUMBER
)
IS
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Update_Performance';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
   l_object_version_number    NUMBER;
   l_pvt_performance_rec      AMS_DMPerformance_PVT.performance_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Performance_PUB;

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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Assign public record values to private record for API
      l_pvt_performance_rec.performance_id := p_performance_rec.performance_id;
      l_pvt_performance_rec.object_version_number := p_performance_rec.object_version_number;
      l_pvt_performance_rec.predicted_value := p_performance_rec.predicted_value;
      l_pvt_performance_rec.actual_value := p_performance_rec.actual_value;
      l_pvt_performance_rec.evaluated_records := p_performance_rec.evaluated_records;
      l_pvt_performance_rec.total_records_predicted := p_performance_rec.total_records_predicted;
      l_pvt_performance_rec.model_id := p_performance_rec.model_id;

    AMS_DMPerformance_PVT.Update_Performance (
       p_api_version_number      => 1.0,
       p_init_msg_list           => FND_API.G_FALSE,
       p_commit                  => p_commit,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_performance_rec         =>  l_pvt_performance_rec,
       x_object_version_number   => l_object_version_number
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
     ROLLBACK TO Update_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Performance_PUB;
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
End Update_Performance;


PROCEDURE Delete_Performance (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    p_performance_id             IN  NUMBER,
    p_object_version_number      IN   NUMBER
)

IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Performance';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Performance_PUB;

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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    AMS_DMPerformance_PVT.Delete_Performance(
       p_api_version_number      => 1.0,
       p_init_msg_list           => FND_API.G_FALSE,
       p_commit                  => p_commit,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_performance_id          => p_performance_id,
       p_object_version_number   => p_object_version_number
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
     ROLLBACK TO Delete_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Performance_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Performance_PUB;
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
End Delete_Performance;


PROCEDURE Lock_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_performance_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Performance';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
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
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Performance
    -- Hint: Primary key needs to be returned
     AMS_DMPerformance_PVT.Lock_Performance(
        p_api_version_number  => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_performance_id      => p_performance_id,
        p_object_version      => p_object_version
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
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
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
End Lock_Performance;


PROCEDURE Create_Performance (
   p_model_id           IN NUMBER,
   p_predicted_value    IN VARCHAR2,
   p_actual_value       IN VARCHAR2,
   p_evaluated_records  IN NUMBER,
   p_total_records_predicted  IN NUMBER,
   x_performance_id     OUT NUMBER,
   x_return_status      OUT VARCHAR2
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Create_Performance';
   L_API_VERSION        CONSTANT NUMBER := 1.0;

   l_performance_rec    AMS_DMPerformance_PVT.performance_rec_type;
   l_performance_id        NUMBER;
   l_object_version_number NUMBER := 1;

   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(4000);

   l_dummy                 NUMBER;

   CURSOR c_perf_id IS
      SELECT ams_dm_performance_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (p_performance_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE EXISTS (SELECT 1
                    FROM   ams_dm_performance
                    WHERE  performance_id = p_performance_id)
      ;
BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Construct the private record for the API call
   l_performance_rec.predicted_value := p_predicted_value;
   l_performance_rec.actual_value := p_actual_value;
   l_performance_rec.evaluated_records := p_evaluated_records;
   l_performance_rec.total_records_predicted := p_total_records_predicted;
   l_performance_rec.model_id := p_model_id;

   -- validate the input
   AMS_DMPerformance_PVT.validate_performance (
      p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      p_validation_mode    => JTF_PLSQL_API.G_CREATE,
      p_performance_rec    => l_performance_rec,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
   );

   -- get a unique id
   LOOP
      l_dummy := NULL;

      OPEN c_perf_id;
      FETCH c_perf_id INTO l_performance_id;
      CLOSE c_perf_id;

      OPEN c_id_exists (l_performance_id);
      FETCH c_id_exists INTO l_dummy;
      CLOSE c_id_exists;

      EXIT WHEN l_dummy IS NULL;
   END LOOP;

   -- call the table handler
   -- note: the private api contains
   -- savepoint and rollbacks, which
   -- cannot be used in a distributed
   -- transaction.
   ams_dm_performance_pkg.insert_row (
      px_performance_id       => l_performance_id,
      p_last_update_date      => SYSDATE,
      p_last_updated_by       => FND_GLOBAL.user_id,
      p_creation_date         => SYSDATE,
      p_created_by            => FND_GLOBAL.user_id,
      p_last_update_login     => FND_GLOBAL.conc_login_id,
      px_object_version_number   => l_object_version_number,
      p_predicted_value       => p_predicted_value,
      p_actual_value          => p_actual_value,
      p_evaluated_records     => p_evaluated_records,
      p_total_records_predicted  => p_total_records_predicted,
      p_model_id              => p_model_id
   );

   x_performance_id := l_performance_id;
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
END Create_Performance;


END AMS_DMPerformance_PUB;

/
