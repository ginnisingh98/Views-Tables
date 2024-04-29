--------------------------------------------------------
--  DDL for Package Body AMS_DMPERFORMANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMPERFORMANCE_PVT" as
/* $Header: amsvdpfb.pls 115.8 2002/12/09 11:20:59 choang ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMPerformance_PVT
-- Purpose
--
-- History
-- 26-Jan-2001 choang   Added increment of object ver num in update api.
-- 07-Jan-2002 choang   Removed security group id
-- 17-May-2002 choang   bug 2380113: removed g_user_id and g_login_id
-- 11-Jun-2002 choang   Fixed gscc error for bug 2380113.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DMPerformance_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvdpfb.pls';

/***
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
***/

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_performance_rec               IN   performance_rec_type  := g_miss_performance_rec,
    x_performance_id                   OUT NOCOPY  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Performance';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_PERFORMANCE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_DM_PERFORMANCE_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM AMS_DM_PERFORMANCE
                    WHERE PERFORMANCE_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Performance_PVT;

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

   IF p_performance_rec.PERFORMANCE_ID IS NULL OR p_performance_rec.PERFORMANCE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_PERFORMANCE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_PERFORMANCE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate
      -- =========================================================================

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Performance');
          END IF;

          -- Invoke validation procedures
          Validate_Performance(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_create,
            p_performance_rec    =>  p_performance_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_DM_PERFORMANCE_PKG.Insert_Row)
      AMS_DM_PERFORMANCE_PKG.Insert_Row(
          px_performance_id  => l_performance_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_predicted_value  => p_performance_rec.predicted_value,
          p_actual_value  => p_performance_rec.actual_value,
          p_evaluated_records  => p_performance_rec.evaluated_records,
          p_total_records_predicted  => p_performance_rec.total_records_predicted,
          p_model_id  => p_performance_rec.model_id);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_performance_id := l_performance_id;
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
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Performance_PVT;
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
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_performance_rec               IN    performance_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Performance';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   -- Local Variables
   l_object_version_number     NUMBER;
   l_PERFORMANCE_ID    NUMBER;
   l_tar_performance_rec  AMS_DMPerformance_PVT.performance_rec_type := P_performance_rec;

   CURSOR c_get_dmperformance(p_performance_id NUMBER) IS
      SELECT *
      FROM  AMS_DM_PERFORMANCE
      WHERE performance_id = p_performance_id;
   l_ref_performance_rec  c_get_Dmperformance%ROWTYPE ;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Performance_PVT;

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

      OPEN c_get_Dmperformance( l_tar_performance_rec.performance_id);

      FETCH c_get_Dmperformance INTO l_ref_performance_rec  ;

       If ( c_get_Dmperformance%NOTFOUND) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'Dmperformance', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Dmperformance;

      -- Check Whether record has been changed by someone else
      If (l_tar_performance_rec.object_version_number <> l_ref_performance_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'Dmperformance', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Performance');
          END IF;

          -- Invoke validation procedures
          Validate_Performance(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_update,
            p_performance_rec    =>  p_performance_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_DM_PERFORMANCE_PKG.Update_Row)
      AMS_DM_PERFORMANCE_PKG.Update_Row(
          p_performance_id  => p_performance_rec.performance_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => l_ref_performance_rec.created_by,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_performance_rec.object_version_number + 1,
          p_predicted_value  => p_performance_rec.predicted_value,
          p_actual_value  => p_performance_rec.actual_value,
          p_evaluated_records  => p_performance_rec.evaluated_records,
          p_total_records_predicted  => p_performance_rec.total_records_predicted,
          p_model_id  => p_performance_rec.model_id
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
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Performance_PVT;
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


PROCEDURE Delete_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_performance_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Performance_PVT;

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

      -- Invoke table handler(AMS_DM_PERFORMANCE_PKG.Delete_Row)
      AMS_DM_PERFORMANCE_PKG.Delete_Row(
          p_PERFORMANCE_ID  => p_PERFORMANCE_ID);
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
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Performance_PVT;
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



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_performance_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Performance';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_PERFORMANCE_ID                  NUMBER;

CURSOR c_Dmperformance IS
   SELECT PERFORMANCE_ID
   FROM AMS_DM_PERFORMANCE
   WHERE PERFORMANCE_ID = p_PERFORMANCE_ID
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
  OPEN c_Dmperformance;

  FETCH c_Dmperformance INTO l_PERFORMANCE_ID;

  IF (c_Dmperformance%NOTFOUND) THEN
    CLOSE c_Dmperformance;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Dmperformance;

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
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Performance_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Performance_PVT;
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


PROCEDURE check_performance_uk_items(
    p_performance_rec               IN   performance_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_PERFORMANCE',
         'PERFORMANCE_ID = ''' || p_performance_rec.PERFORMANCE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_DM_PERFORMANCE',
         'PERFORMANCE_ID = ''' || p_performance_rec.PERFORMANCE_ID ||
         ''' AND PERFORMANCE_ID <> ' || p_performance_rec.PERFORMANCE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_PERFORMANCE_ID_DUPLICATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_performance_uk_items;

PROCEDURE check_performance_req_items(
    p_performance_rec               IN  performance_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_performance_rec.MODEL_ID = FND_API.g_miss_num OR p_performance_rec.MODEL_ID IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_MODEL_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- predicated value
      IF p_performance_rec.predicted_value = FND_API.g_miss_num OR p_performance_rec.predicted_value IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_PREDICTED_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- actual value
      IF p_performance_rec.actual_value = FND_API.g_miss_num OR p_performance_rec.actual_value IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_ACTUAL_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- evaluated records
      IF p_performance_rec.evaluated_records = FND_API.g_miss_num OR p_performance_rec.evaluated_records IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_EVAL_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- total records
      IF p_performance_rec.total_records_predicted = FND_API.g_miss_num OR p_performance_rec.total_records_predicted IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_TOTAL_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSE  -- need ID when updating
      IF p_performance_rec.performance_id = FND_API.g_miss_num OR p_performance_rec.performance_id IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_PERF_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_performance_rec.MODEL_ID IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_MODEL_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- predicated value
      IF p_performance_rec.predicted_value IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_PREDICTED_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- actual value
      IF p_performance_rec.actual_value IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_ACTUAL_VALUE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- evaluated records
      IF p_performance_rec.evaluated_records IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_EVAL_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- total records
      IF p_performance_rec.total_records_predicted IS NULL THEN
         AMS_Utility_PVT.error_message ('AMS_PERF_NO_TOTAL_RECORDS');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_performance_req_items;

PROCEDURE check_performance_FK_items(
    p_performance_rec IN performance_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_performance_rec.model_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists (
         'AMS_DM_MODELS_ALL_B',
         'MODEL_ID',
         p_performance_rec.model_id
      ) = FND_API.g_false THEN
         AMS_Utility_PVT.error_message ('AMS_DM_PERF_BAD_MODEL_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
END check_performance_FK_items;

PROCEDURE check_performance_Lookup_items(
    p_performance_rec IN performance_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_performance_Lookup_items;

PROCEDURE Check_performance_Items (
    P_performance_rec     IN    performance_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_performance_uk_items(
      p_performance_rec => p_performance_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_performance_req_items(
      p_performance_rec => p_performance_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_performance_FK_items(
      p_performance_rec => p_performance_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_performance_Lookup_items(
      p_performance_rec => p_performance_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_performance_Items;


PROCEDURE Complete_performance_Rec (
    P_performance_rec     IN    performance_rec_type,
     x_complete_rec        OUT NOCOPY    performance_rec_type
    )
IS
BEGIN

      --
      -- Check Items API calls
      NULL;
      --

END Complete_performance_Rec;

PROCEDURE Validate_Performance(
   p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_validation_mode       IN   VARCHAR2,
   p_performance_rec       IN   performance_rec_type,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Performance';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER;
   l_performance_rec  AMS_DMPerformance_PVT.performance_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_Performance_;

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
              Check_performance_Items(
                 p_performance_rec  => p_performance_rec,
                 p_validation_mode  => p_validation_mode,
                 x_return_status    => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_performance_Rec(
         p_performance_rec        => p_performance_rec,
         x_complete_rec        => l_performance_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_performance_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_performance_rec           =>    l_performance_rec);

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
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Validate_Performance_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Performance_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Performance_;
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
End Validate_Performance;


PROCEDURE Validate_performance_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_performance_rec               IN    performance_rec_type
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
END Validate_performance_Rec;

PROCEDURE get_performance_indices(
    p_model_id                   IN   NUMBER,
    x_actlPos_PredPos_Count      OUT NOCOPY  NUMBER,
    x_actlPos_PredNeg_Count      OUT NOCOPY  NUMBER,
    x_actlNeg_PredPos_Count      OUT NOCOPY  NUMBER,
    x_actlNeg_PredNeg_Count      OUT NOCOPY  NUMBER
   ) IS
   CURSOR c_get_perf_rows(p_model_id NUMBER) IS
      SELECT perf.predicted_value
            , perf. actual_value
            , perf.evaluated_records
            , model.target_positive_value
      FROM ams_dm_performance perf
            , ams_dm_models_all_b model
      WHERE model.model_id = p_model_id
         AND perf.model_id = p_model_id;
   l_predicted_value          NUMBER;
   l_actual_value             NUMBER;
   l_evaluated_records        NUMBER;
   l_target_positive_value    NUMBER;

BEGIN
   x_actlPos_PredPos_Count := 0;
   x_actlPos_PredNeg_Count := 0;
   x_actlNeg_PredPos_Count := 0;
   x_actlNeg_PredNeg_Count := 0;

   OPEN c_get_perf_rows(p_model_id);
   LOOP
      FETCH c_get_perf_rows INTO l_predicted_value
                                 , l_actual_value
                                 , l_evaluated_records
                                 , l_target_positive_value;
      EXIT WHEN c_get_perf_rows%NOTFOUND;
      IF NVL(l_predicted_value,-1) = NVL(l_target_positive_value,1)
         AND NVL(l_actual_value,-1) = NVL(l_target_positive_value,1) THEN
            x_actlPos_PredPos_Count := l_evaluated_records;
      ELSIF NVL(l_predicted_value,-1) <> NVL(l_target_positive_value,1)
         AND NVL(l_actual_value,-1) = NVL(l_target_positive_value,1) THEN
            x_actlPos_PredNeg_Count := l_evaluated_records;
      ELSIF NVL(l_predicted_value,-1) = NVL(l_target_positive_value,1)
         AND NVL(l_actual_value,-1) <> NVL(l_target_positive_value,1) THEN
            x_actlNeg_PredPos_Count := l_evaluated_records;
      ELSIF NVL(l_predicted_value,-1) <> NVL(l_target_positive_value,1)
         AND NVL(l_actual_value,-1) <> NVL(l_target_positive_value,1) THEN
            x_actlNeg_PredNeg_Count := l_evaluated_records;
      END IF;
   END LOOP;
   CLOSE c_get_perf_rows;
END get_performance_indices;

END AMS_DMPerformance_PVT;

/
