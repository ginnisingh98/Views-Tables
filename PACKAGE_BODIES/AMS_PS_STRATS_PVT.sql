--------------------------------------------------------
--  DDL for Package Body AMS_PS_STRATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_STRATS_PVT" as
/* $Header: amsvstrb.pls 120.0 2005/05/31 16:56:16 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Strats_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ps_Strats_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvstrb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ps_Strats(
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,

    p_ps_strats_rec      IN  ps_strats_rec_type := g_miss_ps_strats_rec,
    x_strategy_id        OUT NOCOPY NUMBER
  )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ps_Strats';
L_API_VERSION_NUMBER        CONSTANT NUMBER := 1.0;
   l_return_status_full     VARCHAR2(1);
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER := FND_API.G_MISS_NUM;
   l_STRATEGY_ID            NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_IBA_PS_STRATS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_STRATS_B
      WHERE STRATEGY_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ps_Strats_PVT;

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

   IF p_ps_strats_rec.STRATEGY_ID IS NULL OR p_ps_strats_rec.STRATEGY_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_STRATEGY_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_STRATEGY_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- ====================================================================
      -- Validate Environment
      -- ====================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Strats');
          END IF;

          -- Invoke validation procedures
          Validate_ps_strats(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_strats_rec  =>  p_ps_strats_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_IBA_PS_STRATS_B_PKG.Insert_Row)
      AMS_IBA_PS_STRATS_B_PKG.Insert_Row(
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          px_strategy_id  => l_strategy_id,
          p_max_returned  => p_ps_strats_rec.max_returned,
          p_strategy_type  => p_ps_strats_rec.strategy_type,
          p_content_type  => p_ps_strats_rec.content_type,
          p_strategy_ref_code  => p_ps_strats_rec.strategy_ref_code,
          p_selector_class  => p_ps_strats_rec.selector_class,
	  p_strategy_name => p_ps_strats_rec.strategy_name,
	  p_strategy_description => p_ps_strats_rec.strategy_description);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
      x_strategy_id := l_strategy_id;

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
     ROLLBACK TO CREATE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ps_Strats_PVT;
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
End Create_Ps_Strats;


PROCEDURE Update_Ps_Strats(
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,

    p_ps_strats_rec          IN  ps_strats_rec_type,
    x_object_version_number  OUT NOCOPY NUMBER
    )

 IS


--/*
--CURSOR c_get_ps_strats(created_by NUMBER) IS
CURSOR c_get_ps_strats(p_strategy_id NUMBER) IS
    SELECT object_version_number
    FROM  AMS_IBA_PS_STRATS_B
    WHERE strategy_id = p_strategy_id;
    -- Hint: Developer need to provide Where clause
--*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ps_Strats';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_STRATEGY_ID    NUMBER;
l_ref_ps_strats_rec  c_get_Ps_Strats%ROWTYPE ;
l_tar_ps_strats_rec  AMS_Ps_Strats_PVT.ps_strats_rec_type := P_ps_strats_rec;
l_rowid  ROWID;
l_object_version 	NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ps_Strats_PVT;

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

--/*
      OPEN c_get_Ps_Strats( l_tar_ps_strats_rec.strategy_id);

      FETCH c_get_Ps_Strats INTO l_ref_ps_strats_rec  ;
--      FETCH c_get_Ps_Strats INTO l_object_version  ;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('l_object_version '|| l_object_version);

      END IF;

       If ( c_get_Ps_Strats%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ps_Strats') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ps_Strats;
--*/

      If (l_tar_ps_strats_rec.object_version_number is NULL or
          l_tar_ps_strats_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ps_strats_rec.object_version_number <> l_ref_ps_strats_rec.object_version_number) Then
      --If (l_tar_ps_strats_rec.object_version_number <> l_object_version) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ps_Strats') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Strats');
          END IF;

          -- Invoke validation procedures
          Validate_ps_strats(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_strats_rec  =>  p_ps_strats_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Exception: Return Status: '|| x_return_status);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      -- IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler'); END IF;

      -- Invoke table handler(AMS_IBA_PS_STRATS_B_PKG.Update_Row)
      AMS_IBA_PS_STRATS_B_PKG.Update_Row(
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_ps_strats_rec.object_version_number,
          p_strategy_id  => p_ps_strats_rec.strategy_id,
          p_max_returned  => p_ps_strats_rec.max_returned,
          p_strategy_type  => p_ps_strats_rec.strategy_type,
          p_content_type  => p_ps_strats_rec.content_type,
          p_strategy_ref_code  => p_ps_strats_rec.strategy_ref_code,
          p_selector_class  => p_ps_strats_rec.selector_class,
          p_strategy_name => p_ps_strats_rec.strategy_name,
          p_strategy_description => p_ps_strats_rec.strategy_description);

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
     ROLLBACK TO UPDATE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ps_Strats_PVT;
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
End Update_Ps_Strats;

PROCEDURE Update_Ps_Strats_Seg(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_ps_strats_rec          IN   ps_strats_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER,
    p_strat_type		    IN   VARCHAR2
    )
 IS

BEGIN
    -- Standard Start of API savepoint
    --SAVEPOINT UPDATE_Ps_Strats_Seg_PVT;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- PREDEFINED is same as PRODUCT_RELATIONSHIP
    IF p_strat_type = 'PREDEFINED' THEN

      UPDATE ams_iba_ps_strats_b
      SET
         max_returned = p_ps_strats_rec.max_returned
      WHERE strategy_type = 'PRODUCT_RELATIONSHIP';

    ELSE

      UPDATE ams_iba_ps_strats_b
      SET
         max_returned = p_ps_strats_rec.max_returned
      WHERE strategy_type = 'INFERRED_OP';

    END IF;

END Update_Ps_Strats_Seg;

PROCEDURE Delete_Ps_Strats(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_strategy_id           IN  NUMBER,
    p_object_version_number IN   NUMBER
    )

 IS
L_API_NAME               CONSTANT VARCHAR2(30) := 'Delete_Ps_Strats';
L_API_VERSION_NUMBER     CONSTANT NUMBER  := 1.0;
l_object_version_number  NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Strats_PVT;

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

     AMS_UTILITY_PVT.debug_message('Private API: Calling delete table handler');
     END IF;

      -- Invoke table handler(AMS_IBA_PS_STRATS_B_PKG.Delete_Row)
     AMS_IBA_PS_STRATS_B_PKG.Delete_Row(
          p_STRATEGY_ID  => p_STRATEGY_ID);
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
     ROLLBACK TO DELETE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Strats_PVT;
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
End Delete_Ps_Strats;


-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ps_Strats(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,

    p_strategy_id        IN  NUMBER,
    p_object_version     IN  NUMBER
    )

 IS
L_API_NAME             CONSTANT VARCHAR2(30) := 'Lock_Ps_Strats';
L_API_VERSION_NUMBER   CONSTANT NUMBER   := 1.0;
L_FULL_NAME            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_STRATEGY_ID          NUMBER;

CURSOR c_Ps_Strats IS
   SELECT STRATEGY_ID
   FROM AMS_IBA_PS_STRATS_B
   WHERE STRATEGY_ID = p_STRATEGY_ID
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
  OPEN c_Ps_Strats;

  FETCH c_Ps_Strats INTO l_STRATEGY_ID;

  IF (c_Ps_Strats%NOTFOUND) THEN
    CLOSE c_Ps_Strats;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ps_Strats;

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
     ROLLBACK TO LOCK_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ps_Strats_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ps_Strats_PVT;
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
End Lock_Ps_Strats;


PROCEDURE check_ps_strats_uk_items(
    p_ps_strats_rec    IN   ps_strats_rec_type,
    p_validation_mode  IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status    OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_STRATS_B',
         'STRATEGY_ID = ''' || p_ps_strats_rec.STRATEGY_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IBA_PS_STRATS_B',
         'STRATEGY_ID = ''' || p_ps_strats_rec.STRATEGY_ID ||
         ''' AND STRATEGY_ID <> ' || p_ps_strats_rec.STRATEGY_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_STRATEGY_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ps_strats_uk_items;

PROCEDURE check_ps_strats_req_items(
    p_ps_strats_rec               IN  ps_strats_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
/*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ps_strats_rec.created_by = FND_API.g_miss_num OR p_ps_strats_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.creation_date = FND_API.g_miss_date OR p_ps_strats_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.last_updated_by = FND_API.g_miss_num OR p_ps_strats_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.last_update_date = FND_API.g_miss_date OR p_ps_strats_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.strategy_id = FND_API.g_miss_num OR p_ps_strats_rec.strategy_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_strategy_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.strategy_type = FND_API.g_miss_char OR p_ps_strats_rec.strategy_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_strategy_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ps_strats_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.strategy_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_strategy_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ps_strats_rec.strategy_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ps_strats_NO_strategy_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
END check_ps_strats_req_items;

PROCEDURE check_ps_strats_FK_items(
    p_ps_strats_rec IN ps_strats_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_strats_FK_items;

PROCEDURE check_ps_strats_Lookup_items(
    p_ps_strats_rec IN ps_strats_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ps_strats_Lookup_items;

PROCEDURE Check_ps_strats_Items (
    P_ps_strats_rec     IN    ps_strats_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_ps_strats_uk_items(
      p_ps_strats_rec => p_ps_strats_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ps_strats_req_items(
      p_ps_strats_rec => p_ps_strats_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ps_strats_FK_items(
      p_ps_strats_rec => p_ps_strats_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_ps_strats_Lookup_items(
      p_ps_strats_rec => p_ps_strats_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_ps_strats_Items;

/*
PROCEDURE Complete_ps_strats_Rec (
    P_ps_strats_rec     IN    ps_strats_rec_type,
     x_complete_rec        OUT NOCOPY    ps_strats_rec_type
    )
*/

PROCEDURE Complete_ps_strats_Rec (
   p_ps_strats_rec IN ps_strats_rec_type,
   x_complete_rec OUT NOCOPY ps_strats_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_ps_strats_b
      WHERE strategy_id = p_ps_strats_rec.strategy_id;
   l_ps_strats_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ps_strats_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ps_strats_rec;
   CLOSE c_complete;

   -- created_by
   IF p_ps_strats_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ps_strats_rec.created_by;
   END IF;

   -- creation_date
   IF p_ps_strats_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ps_strats_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ps_strats_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ps_strats_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ps_strats_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ps_strats_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ps_strats_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ps_strats_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ps_strats_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ps_strats_rec.object_version_number;
   END IF;

   -- strategy_id
   IF p_ps_strats_rec.strategy_id = FND_API.g_miss_num THEN
      x_complete_rec.strategy_id := l_ps_strats_rec.strategy_id;
   END IF;

   -- max_returned
   IF p_ps_strats_rec.max_returned = FND_API.g_miss_num THEN
      x_complete_rec.max_returned := l_ps_strats_rec.max_returned;
   END IF;

   -- strategy_type
   IF p_ps_strats_rec.strategy_type = FND_API.g_miss_char THEN
      x_complete_rec.strategy_type := l_ps_strats_rec.strategy_type;
   END IF;

   -- content_type
   IF p_ps_strats_rec.content_type = FND_API.g_miss_char THEN
      x_complete_rec.content_type := l_ps_strats_rec.content_type;
   END IF;

   -- strategy_ref_code
   IF p_ps_strats_rec.strategy_ref_code = FND_API.g_miss_char THEN
      x_complete_rec.strategy_ref_code := l_ps_strats_rec.strategy_ref_code;
   END IF;

   -- selector_class
   IF p_ps_strats_rec.selector_class = FND_API.g_miss_char THEN
      x_complete_rec.selector_class := l_ps_strats_rec.selector_class;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ps_strats_Rec;
PROCEDURE Validate_ps_strats(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_strats_rec               IN   ps_strats_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ps_Strats';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ps_strats_rec  AMS_Ps_Strats_PVT.ps_strats_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ps_Strats_;

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
              Check_ps_strats_Items(
                 p_ps_strats_rec        => p_ps_strats_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
/*
      Complete_ps_strats_Rec(
         p_ps_strats_rec        => p_ps_strats_rec,
         x_complete_rec        => l_ps_strats_rec
      );

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'Inside Comment');
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ps_strats_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ps_strats_rec           =>    l_ps_strats_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
*/

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
     ROLLBACK TO VALIDATE_Ps_Strats_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Strats_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ps_Strats_;
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
End Validate_Ps_Strats;


PROCEDURE Validate_ps_strats_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ps_strats_rec               IN    ps_strats_rec_type
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
END Validate_ps_strats_Rec;

END AMS_Ps_Strats_PVT;

/
