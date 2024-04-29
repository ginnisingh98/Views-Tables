--------------------------------------------------------
--  DDL for Package Body AMS_SCORERESULT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCORERESULT_PUB" as
/* $Header: amspdrsb.pls 115.4 2002/01/07 18:52:10 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Scoreresult_PUB
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 12-Feb-2001 choang   Removed savepoint and rollback, and changed to use
--                      table handler instead of private api.
-- 16-Sep-2001 choang   Removed tree_node references.
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Scoreresult_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspdrsb.pls';

PROCEDURE Create_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status     OUT  VARCHAR2,
    x_msg_count         OUT  NUMBER,
    x_msg_data          OUT  VARCHAR2,

    p_scoreresult_rec   IN   scoreresult_rec_type  := g_miss_scoreresult_rec,
    x_score_result_id   OUT  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_pvt_scoreresult_rec    AMS_Scoreresult_PVT.scoreresult_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Scoreresult_PUB;

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

      -- Assign public record values to private record for API
      l_pvt_scoreresult_rec.score_result_id := p_scoreresult_rec.score_result_id;
      l_pvt_scoreresult_rec.score_id := p_scoreresult_rec.score_id;
--      l_pvt_scoreresult_rec.tree_node := p_scoreresult_rec.tree_node;
      l_pvt_scoreresult_rec.num_records := p_scoreresult_rec.num_records;
      l_pvt_scoreresult_rec.score := p_scoreresult_rec.response;
      l_pvt_scoreresult_rec.confidence := p_scoreresult_rec.confidence;

      -- Calling Private package: Create_Scoreresult
      AMS_Scoreresult_PVT.Create_Scoreresult(
         p_api_version         => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         p_scoreresult_rec     => l_pvt_scoreresult_rec,
         x_score_result_id     => x_score_result_id
      );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
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
End Create_Scoreresult;


PROCEDURE Update_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status           OUT  VARCHAR2,
    x_msg_count               OUT  NUMBER,
    x_msg_data                OUT  VARCHAR2,

    p_scoreresult_rec         IN    scoreresult_rec_type,
    x_object_version_number   OUT  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number  NUMBER;
   l_pvt_scoreresult_rec  AMS_Scoreresult_PVT.scoreresult_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Scoreresult_PUB;

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

      -- Assign public record values to private record for API
      l_pvt_scoreresult_rec.score_result_id := p_scoreresult_rec.score_result_id;
      l_pvt_scoreresult_rec.object_version_number := p_scoreresult_rec.object_version_number;
      l_pvt_scoreresult_rec.score_id := p_scoreresult_rec.score_id;
--      l_pvt_scoreresult_rec.tree_node := p_scoreresult_rec.tree_node;
      l_pvt_scoreresult_rec.num_records := p_scoreresult_rec.num_records;
      l_pvt_scoreresult_rec.score := p_scoreresult_rec.response;
      l_pvt_scoreresult_rec.confidence := p_scoreresult_rec.confidence;

      AMS_Scoreresult_PVT.Update_Scoreresult(
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => p_commit,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_scoreresult_rec    => l_pvt_scoreresult_rec,
         x_object_version_number => l_object_version_number
      );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Scoreresult_PUB;
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
End Update_Scoreresult;


PROCEDURE Delete_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status           OUT  VARCHAR2,
    x_msg_count               OUT  NUMBER,
    x_msg_data                OUT  VARCHAR2,
    p_score_result_id         IN  NUMBER,
    p_object_version_number   IN   NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Scoreresult_PUB;

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
      AMS_Scoreresult_PVT.Delete_Scoreresult(
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.G_FALSE,
         p_commit            => p_commit,
         p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         p_score_result_id   => p_score_result_id,
         p_object_version_number   => p_object_version_number
      );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Scoreresult_PUB;
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
End Delete_Scoreresult;


PROCEDURE Lock_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status     OUT  VARCHAR2,
    x_msg_count         OUT  NUMBER,
    x_msg_data          OUT  VARCHAR2,

    p_score_result_id   IN  NUMBER,
    p_object_version    IN  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Scoreresult';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
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
    -- Calling Private package: Create_Scoreresult
    -- Hint: Primary key needs to be returned
      AMS_Scoreresult_PVT.Lock_Scoreresult(
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_score_result_id    => p_score_result_id,
         p_object_version     => p_object_version
      );
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Scoreresult_PUB;
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
End Lock_Scoreresult;


PROCEDURE Create_ScoreResult (
   p_score_id           IN NUMBER,
   p_tree_node          IN NUMBER,
   p_num_records        IN NUMBER,
   p_score              IN VARCHAR2,
   p_confidence         IN NUMBER,
   p_positive_score_prob   IN NUMBER,
   x_score_result_id    OUT NUMBER,
   x_return_status      OUT VARCHAR2
)
IS
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Create_ScoreResult';

   l_scoreresult_rec       AMS_ScoreResult_PVT.scoreresult_rec_type;
   l_score_result_id       NUMBER;
   l_object_version_number NUMBER;

   l_msg_count    NUMBER;
   l_msg_data     VARCHAR2(4000);

   l_dummy        NUMBER;

   CURSOR c_result_id IS
      SELECT ams_dm_score_results_s.NEXTVAL
      FROM   dual;

   CURSOR c_id_exists (p_result_id IN NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   ams_dm_score_results
                     WHERE  score_result_id = p_result_id)
      ;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Scoreresult_PUB;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Construct record for private API
   l_scoreresult_rec.score_id := p_score_id;
--   l_scoreresult_rec.tree_node := p_tree_node;
   l_scoreresult_rec.num_records := p_num_records;
   l_scoreresult_rec.score := p_score;
   l_scoreresult_rec.confidence := p_confidence;

   -- validate the values
   AMS_ScoreResult_PVT.validate_scoreresult (
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_TRUE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      p_validation_mode    => JTF_PLSQL_API.G_CREATE,
      p_scoreresult_rec    => l_scoreresult_rec,
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

   -- get a unique id
   LOOP
      l_dummy := NULL;

      OPEN c_result_id;
      FETCH c_result_id INTO l_score_result_id;
      CLOSE c_result_id;

      OPEN c_id_exists (l_score_result_id);
      FETCH c_id_exists INTO l_dummy;
      CLOSE c_id_exists;

      EXIT WHEN l_dummy IS NULL;
   END LOOP;

   -- call the table handler
   ams_dm_score_results_pkg.insert_row (
      PX_SCORE_RESULT_ID         => l_score_result_id,
      P_LAST_UPDATE_DATE         => SYSDATE,
      P_LAST_UPDATED_BY          => FND_GLOBAL.user_id,
      P_CREATION_DATE            => SYSDATE,
      P_CREATED_BY               => FND_GLOBAL.user_id,
      P_LAST_UPDATE_LOGIN        => FND_GLOBAL.conc_login_id,
      PX_OBJECT_VERSION_NUMBER   => l_object_version_number,
      P_SCORE_ID                 => p_score_id,
      P_DECILE                   => NULL, -- need to add when needed
      P_NUM_RECORDS              => p_num_records,
      P_SCORE                    => p_score,
      P_CONFIDENCE               => p_confidence
   );

   x_score_result_id := l_score_result_id;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Scoreresult_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
END Create_ScoreResult;


END AMS_Scoreresult_PUB;

/
