--------------------------------------------------------
--  DDL for Package Body AMS_CT_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CT_RULE_PVT" as
/* $Header: amsvctrb.pls 120.3 2006/05/30 11:09:34 prageorg noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ct_Rule_PVT
--
-- Purpose
--          Private api created to Update/insert/Delete general
--          and object-specific content rules
--
-- History
--    21-mar-2002    jieli       Created.
--    10-apr-2002    soagrawa    Added all the comments
--    10-apr-2002    soagrawa    Added check_Content_Rules
--    29-apr-2002    soagrawa    Modified last_updated_date to last_update_date
--    15-jul-2002    soagrawa    Modified check_content_rule to pass source codes to the FFM API.
--    29-May-2006    prageorg    Added delivery_mode column. Bug 4896511
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ct_Rule_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvctrb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


--===================================================================
-- NAME
--    Create_Ct_Rule
--
-- PURPOSE
--    Creates the Content Rule.
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec                IN   ct_rule_rec_type  := g_miss_ct_rule_rec,
    x_content_rule_id            OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ct_Rule';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CONTENT_RULE_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_CONTENT_RULES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_CONTENT_RULES_B
      WHERE CONTENT_RULE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ct_Rule_PVT;

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

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_ct_rule_rec.CONTENT_RULE_ID IS NULL OR p_ct_rule_rec.CONTENT_RULE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_CONTENT_RULE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_CONTENT_RULE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;

      END LOOP;
   END IF;

      -- Validate Environment
      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: ' || l_api_name || ' Validate_Ct_Rule');
          END IF;

          -- Invoke validation procedures
          Validate_ct_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_ct_rule_rec  =>  p_ct_rule_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: ' || l_api_name || ' Calling create table handler');
      END IF;

      -- Invoke table handler(AMS_CONTENT_RULES_B_PKG.Insert_Row)
      AMS_CONTENT_RULES_B_PKG.Insert_Row(
          px_content_rule_id  => l_content_rule_id,
          p_created_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_updated_date  => p_ct_rule_rec.last_updated_date,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_object_type  => p_ct_rule_rec.object_type,
          p_object_id  => p_ct_rule_rec.object_id,
          p_sender  => p_ct_rule_rec.sender,
          p_reply_to  => p_ct_rule_rec.reply_to,
          p_cover_letter_id  => p_ct_rule_rec.cover_letter_id,
          p_table_of_content_flag  => p_ct_rule_rec.table_of_content_flag,
          p_trigger_code  => p_ct_rule_rec.trigger_code,
          p_enabled_flag  => p_ct_rule_rec.enabled_flag,
          p_subject => p_ct_rule_rec.subject,
          p_sender_display_name  => p_ct_rule_rec.sender_display_name, -- anchaudh
	  --prageorg 5/29/2006
          p_delivery_mode => p_ct_rule_rec.delivery_mode
	  );

          x_content_rule_id := l_content_rule_id;
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

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: ' || l_api_name || 'end');
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
     ROLLBACK TO CREATE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ct_Rule_PVT;
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
End Create_Ct_Rule;



--===================================================================
-- NAME
--    Update_Ct_Rule
--
-- PURPOSE
--    Updates the Content Rule.
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE Update_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ct_rule_rec               IN    ct_rule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_ct_rule(content_rule_id NUMBER) IS
    SELECT *
    FROM  AMS_CONTENT_RULES_B;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ct_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_CONTENT_RULE_ID    NUMBER;
l_ref_ct_rule_rec  c_get_Ct_Rule%ROWTYPE ;
l_tar_ct_rule_rec  AMS_Ct_Rule_PVT.ct_rule_rec_type := P_ct_rule_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ct_Rule_PVT;

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
      OPEN c_get_Ct_Rule( l_tar_ct_rule_rec.content_rule_id);

      FETCH c_get_Ct_Rule INTO l_ref_ct_rule_rec  ;

       If ( c_get_Ct_Rule%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ct_Rule') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ct_Rule;
*/


      If (l_tar_ct_rule_rec.object_version_number is NULL or
          l_tar_ct_rule_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ct_rule_rec.object_version_number <> l_ref_ct_rule_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ct_Rule') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Ct_Rule');
          END IF;

          -- Invoke validation procedures
          Validate_ct_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_ct_rule_rec  =>  p_ct_rule_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      --IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_CONTENT_RULES_B_PKG.Update_Row)
      AMS_CONTENT_RULES_B_PKG.Update_Row(
          p_content_rule_id  => p_ct_rule_rec.content_rule_id,
          p_created_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_updated_date  => p_ct_rule_rec.last_updated_date,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_ct_rule_rec.object_version_number,
          p_object_type  => p_ct_rule_rec.object_type,
          p_object_id  => p_ct_rule_rec.object_id,
          p_sender  => p_ct_rule_rec.sender,
          p_reply_to  => p_ct_rule_rec.reply_to,
          p_cover_letter_id  => p_ct_rule_rec.cover_letter_id,
          p_table_of_content_flag  => p_ct_rule_rec.table_of_content_flag,
          p_trigger_code  => p_ct_rule_rec.trigger_code,
          p_enabled_flag  => p_ct_rule_rec.enabled_flag,
          p_subject => p_ct_rule_rec.subject,
          p_sender_display_name  => p_ct_rule_rec.sender_display_name, --anchaudh
	  --prageorg 5/29/2006
          p_delivery_mode => p_ct_rule_rec.delivery_mode
	  );

          x_object_version_number := p_ct_rule_rec.object_version_number + 1;

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
     ROLLBACK TO UPDATE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ct_Rule_PVT;
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
End Update_Ct_Rule;


--===================================================================
-- NAME
--    Delete_Ct_Rule
--
-- PURPOSE
--    Deletes the Content Rule.
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE Delete_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_content_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ct_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ct_Rule_PVT;

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

      -- Invoke table handler(AMS_CONTENT_RULES_B_PKG.Delete_Row)
      AMS_CONTENT_RULES_B_PKG.Delete_Row(
          p_CONTENT_RULE_ID  => p_CONTENT_RULE_ID);
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
     ROLLBACK TO DELETE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ct_Rule_PVT;
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
End Delete_Ct_Rule;



--===================================================================
-- NAME
--    Lock_Ct_Rule
--
-- PURPOSE
--    Locks the Content Rule.
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE Lock_Ct_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_content_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ct_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_CONTENT_RULE_ID                  NUMBER;

CURSOR c_Ct_Rule IS
   SELECT CONTENT_RULE_ID
   FROM AMS_CONTENT_RULES_B
   WHERE CONTENT_RULE_ID = p_CONTENT_RULE_ID
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
  OPEN c_Ct_Rule;

  FETCH c_Ct_Rule INTO l_CONTENT_RULE_ID;

  IF (c_Ct_Rule%NOTFOUND) THEN
    CLOSE c_Ct_Rule;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ct_Rule;

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
     ROLLBACK TO LOCK_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ct_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ct_Rule_PVT;
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
End Lock_Ct_Rule;


--===================================================================
-- NAME
--    check_rule_unique
--
-- PURPOSE
--    Checks the uniqueness of combination of object type, trigger type. object id
--
-- NOTES
--
-- HISTORY
--   10-APR-2001  SOAGRAWA   Created
--===================================================================



FUNCTION check_rule_unique(
      p_object_type  IN    VARCHAR2
    , p_trigger_code IN    VARCHAR2
    , p_object_id    IN    NUMBER
    , p_enabled_flag IN    VARCHAR2)
RETURN VARCHAR2
IS
   CURSOR c_rule_det
   IS SELECT 1
      FROM   ams_content_rules_vl
      WHERE  object_type = p_object_type
      AND    trigger_code = p_trigger_code
      AND    object_id = p_object_id
      AND    enabled_flag = p_enabled_flag;

   CURSOR c_rule_det_null
   IS SELECT 1
      FROM   ams_content_rules_vl
      WHERE  object_type = p_object_type
      AND    trigger_code = p_trigger_code
      AND    object_id IS null;

   l_dummy  NUMBER ;
BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_rule_unique start');

   END IF;

   IF p_object_id IS null
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_rule_unique : is null');
      END IF;
      OPEN c_rule_det_null ;
      FETCH c_rule_det_null INTO l_dummy ;
      CLOSE c_rule_det_null ;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_rule_unique : is not null');
      END IF;
      OPEN c_rule_det ;
      FETCH c_rule_det INTO l_dummy ;
      CLOSE c_rule_det ;
   END IF;

   IF l_dummy IS NULL THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_rule_unique : did not find anything');
      END IF;
      RETURN FND_API.g_true ;
   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_rule_unique : found something');
      END IF;
      RETURN FND_API.g_false;
   END IF;

END check_rule_unique ;


--===================================================================
-- NAME
--    check_ct_rule_uk_items
--
-- PURPOSE
--    Checks the unique items for their uniqueness
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================



PROCEDURE check_ct_rule_uk_items(
    p_ct_rule_rec               IN   ct_rule_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
l_sql         VARCHAR2(400);
BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_ct_rule_uk_items start');
      END IF;

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CONTENT_RULES_B',
         'CONTENT_RULE_ID = ''' || p_ct_rule_rec.CONTENT_RULE_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CONTENT_RULES_B',
         'CONTENT_RULE_ID = ''' || p_ct_rule_rec.CONTENT_RULE_ID ||
         ''' AND CONTENT_RULE_ID <> ' || p_ct_rule_rec.CONTENT_RULE_ID
         );
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_ct_rule_uk_items before unique check');
         END IF;
         l_sql :=  ' WHERE OBJECT_TYPE <> ''' || p_ct_rule_rec.OBJECT_TYPE || '''';
         l_sql := l_sql ||   ' AND TRIGGER_CODE <>''' || p_ct_rule_rec.TRIGGER_CODE || '''';
         IF p_ct_rule_rec.object_id IS null
         THEN l_sql := l_sql || ' AND OBJECT_ID IS NULL';
         ELSE l_sql := l_sql || ' AND OBJECT_ID <> '||p_ct_rule_rec.object_id;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_UTILITY_PVT.debug_message(l_sql);

         END IF;

         /*
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_CONTENT_RULES_B',
         l_sql
         );

         IF l_valid_flag = FND_API.g_false
         */
         IF FND_API.G_FALSE = check_rule_unique(
                                           p_ct_rule_rec.object_type
                                           , p_ct_rule_rec.trigger_code
                                           , p_ct_rule_rec.object_id
                                           , p_ct_rule_rec.enabled_flag
                                           )
         THEN
            AMS_Utility_PVT.Error_Message('AMS_CONR_ONLY_ONE');
            x_return_status := FND_API.g_ret_sts_error;
            RAISE FND_API.g_exc_error;
         END IF ;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_ct_rule_uk_items after unique check');
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CONTENT_RULE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_ct_rule_uk_items;






--===================================================================
-- NAME
--    check_ct_rule_req_items
--
-- PURPOSE
--    Checks the required items for their existence
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================

PROCEDURE check_ct_rule_req_items(
    p_ct_rule_rec               IN  ct_rule_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status            OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ct_rule_rec.object_type = FND_API.g_miss_char OR p_ct_rule_rec.object_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_OBJECT_TYPE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ct_rule_rec.trigger_code = FND_API.g_miss_char OR p_ct_rule_rec.trigger_code IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_TRIGGER_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ct_rule_rec.cover_letter_id = FND_API.g_miss_num OR p_ct_rule_rec.cover_letter_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_COVER_LETTER_ID');
         FND_MSG_PUB.Add;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE


      IF p_ct_rule_rec.object_type IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_OBJECT_TYPE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ct_rule_rec.trigger_code IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_TRIGGER_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ct_rule_rec.cover_letter_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_COVER_LETTER_ID');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

END check_ct_rule_req_items;



--===================================================================
-- NAME
--    check_ct_rule_FK_items
--
-- PURPOSE
--    Checks the foreign key items for their correctness
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE check_ct_rule_FK_items(
    p_ct_rule_rec IN ct_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ct_rule_FK_items;

PROCEDURE check_ct_rule_Lookup_items(
    p_ct_rule_rec IN ct_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ct_rule_Lookup_items;


--===================================================================
-- NAME
--    Check_ct_rule_Items
--
-- PURPOSE
--    Checks the items of the content rule record
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================

PROCEDURE Check_ct_rule_Items (
    P_ct_rule_rec     IN    ct_rule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_ct_rule_uk_items(
      p_ct_rule_rec => p_ct_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ct_rule_req_items(
      p_ct_rule_rec => p_ct_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ct_rule_FK_items(
      p_ct_rule_rec => p_ct_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_ct_rule_Lookup_items(
      p_ct_rule_rec => p_ct_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_ct_rule_Items;



--===================================================================
-- NAME
--    Complete_ct_rule_Rec
--
-- PURPOSE
--    Completes the content rule record
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE Complete_ct_rule_Rec (
   p_ct_rule_rec IN ct_rule_rec_type,
   x_complete_rec OUT NOCOPY ct_rule_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_content_rules_b
      WHERE content_rule_id = p_ct_rule_rec.content_rule_id;
   l_ct_rule_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ct_rule_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ct_rule_rec;
   CLOSE c_complete;

   -- content_rule_id
   IF p_ct_rule_rec.content_rule_id = FND_API.g_miss_num THEN
      x_complete_rec.content_rule_id := l_ct_rule_rec.content_rule_id;
   END IF;

   -- created_by
   IF p_ct_rule_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ct_rule_rec.created_by;
   END IF;

   -- creation_date
   IF p_ct_rule_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ct_rule_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ct_rule_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ct_rule_rec.last_updated_by;
   END IF;

   -- last_updated_date
   IF p_ct_rule_rec.last_updated_date = FND_API.g_miss_date THEN
      x_complete_rec.last_updated_date := l_ct_rule_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ct_rule_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ct_rule_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ct_rule_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ct_rule_rec.object_version_number;
   END IF;

   -- object_type
   IF p_ct_rule_rec.object_type = FND_API.g_miss_char THEN
      x_complete_rec.object_type := l_ct_rule_rec.object_type;
   END IF;

   -- object_id
   IF p_ct_rule_rec.object_id = FND_API.g_miss_num THEN
      x_complete_rec.object_id := l_ct_rule_rec.object_id;
   END IF;

   -- sender
   IF p_ct_rule_rec.sender = FND_API.g_miss_char THEN
      x_complete_rec.sender := l_ct_rule_rec.sender;
   END IF;

   -- reply_to
   IF p_ct_rule_rec.reply_to = FND_API.g_miss_char THEN
      x_complete_rec.reply_to := l_ct_rule_rec.reply_to;
   END IF;

   -- cover_letter_id
   IF p_ct_rule_rec.cover_letter_id = FND_API.g_miss_num THEN
      x_complete_rec.cover_letter_id := l_ct_rule_rec.cover_letter_id;
   END IF;

   -- table_of_content_flag
   IF p_ct_rule_rec.table_of_content_flag = FND_API.g_miss_char THEN
      x_complete_rec.table_of_content_flag := l_ct_rule_rec.table_of_content_flag;
   END IF;

   -- trigger_code
   IF p_ct_rule_rec.trigger_code = FND_API.g_miss_char THEN
      x_complete_rec.trigger_code := l_ct_rule_rec.trigger_code;
   END IF;

   -- enabled_flag
   IF p_ct_rule_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_ct_rule_rec.enabled_flag;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.

    -- sender_display_name : anchaudh
   IF p_ct_rule_rec.sender_display_name = FND_API.g_miss_char THEN
      x_complete_rec.sender_display_name := l_ct_rule_rec.sender_display_name;
   END IF;

   -- delivery_mode prageorg 5/29/2006
   IF p_ct_rule_rec.delivery_mode = FND_API.g_miss_char THEN
      x_complete_rec.delivery_mode := l_ct_rule_rec.delivery_mode;
   END IF;

END Complete_ct_rule_Rec;



--===================================================================
-- NAME
--    Validate_ct_rule
--
-- PURPOSE
--    Validates the content rule record
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================


PROCEDURE Validate_ct_rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ct_rule_rec               IN   ct_rule_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ct_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ct_rule_rec  AMS_Ct_Rule_PVT.ct_rule_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ct_Rule_;

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
              Check_ct_rule_Items(
                 p_ct_rule_rec        => p_ct_rule_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_ct_rule_Rec(
         p_ct_rule_rec        => p_ct_rule_rec,
         x_complete_rec        => l_ct_rule_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ct_rule_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ct_rule_rec           =>    l_ct_rule_rec);

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
     ROLLBACK TO VALIDATE_Ct_Rule_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ct_Rule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ct_Rule_;
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
End Validate_Ct_Rule;


--===================================================================
-- NAME
--    Validate_ct_rule_rec
--
-- PURPOSE
--    Validates the content rule record
--
-- NOTES
--
-- HISTORY
--   21-MAR-2001  JIELI      Created
--===================================================================

PROCEDURE Validate_ct_rule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ct_rule_rec               IN    ct_rule_rec_type
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
END Validate_ct_rule_Rec;


--===================================================================
-- NAME
--    check_content_rule
--
-- PURPOSE
--    sees if there are any content rules for given object
--    and submits a request to Fulfillment
--
-- NOTES
--
--
-- ALGORITHM
--    see if there is any object specific rule for this obj type -- trig code -- object id (1)
--    if  yes use this to get template id
--    if  no
--            see if there is any general rule for this obj type -- trig code (2)
--            if  no  => dont send any request
--            if  yes =>
--                       see if it has been disabled for this particular obj id (3)
--                       if yes => (has been disabled) dont send any request
--                       if no  => (has not been disabled) send this template id
--
--
-- HISTORY
--   10-apr-2002   soagrawa   Created
--   15-jul-2002   soagrawa   Modified call to submit batch request to pass it source code
--                            and source code id of the object. Added cursors for that.
--   30-sep-2003   soagrawa   Modified for 11.5.10 JTO integration
--   14-dec-2004   anchaudh   Modified call to pass extended information to fulfillment server
--   29-May-2006   prageorg   Added handling of delivery_mode for Multipart bug fix
--===================================================================

PROCEDURE check_content_rule(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_object_type        IN  VARCHAR2,
   p_object_id          IN  NUMBER,
   p_trigger_type       IN  VARCHAR2,
   p_requestor_type     IN  VARCHAR2  := NULL,
   p_requestor_id       IN  NUMBER,
   p_server_group       IN  NUMBER := NULL,
   p_scheduled_date     IN  DATE  := SYSDATE,
   p_media_types        IN  VARCHAR2 := 'E',
   p_archive            IN  VARCHAR2 := 'N',
   p_log_user_ih        IN  VARCHAR2 := 'Y', --anchaudh: fixed to be able to log interactions for fulfillment rules related to Events.
   p_request_type       IN  VARCHAR2 := 'E',
   p_language_code      IN  VARCHAR2 := NULL,
   p_profile_id         IN  NUMBER   := NULL,
   p_order_id           IN  NUMBER   := NULL,
   p_collateral_id      IN  NUMBER   := NULL,
   p_party_id           IN  JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   p_email              IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_fax                IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_names         IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_values        IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   x_request_history_id OUT NOCOPY NUMBER
    )
IS

   CURSOR c_rules_generic IS
      SELECT cover_letter_id, email_subject,sender, reply_to,sender_display_name, delivery_mode
      FROM   ams_content_rules_vl
      WHERE  object_type  =  p_object_type
      AND    trigger_code =  p_trigger_type
      AND    object_id    IS NULL;


   CURSOR c_rules_for_object_enabled IS
      SELECT cover_letter_id, email_subject,sender, reply_to,sender_display_name, delivery_mode
      FROM   ams_content_rules_vl
      WHERE  object_type  = p_object_type
      AND    trigger_code = p_trigger_type
      AND    object_id    = p_object_id
      AND    enabled_flag = 'Y';  -- 'Y' for (1)  ; 'N' for (3)

   CURSOR c_rules_for_object_disabled IS
      SELECT cover_letter_id, email_subject,sender, reply_to,sender_display_name, delivery_mode
      FROM   ams_content_rules_vl
      WHERE  object_type  = p_object_type
      AND    trigger_code = p_trigger_type
      AND    object_id    = p_object_id
      AND    enabled_flag = 'N';  -- 'Y' for (1)  ; 'N' for (3)

   -- cursor for source codes added by soagrawa on 15-jul-2002
   CURSOR c_source_code IS
      SELECT source_code, source_code_id
      FROM   ams_source_codes
      WHERE  arc_source_code_for = p_object_type
      AND    source_code_for_id  = p_object_id
      AND    active_flag         = 'Y';


   l_send_request   NUMBER;

   l_template_id            NUMBER;
   l_dummy_template_id      NUMBER;
   l_email_subject          VARCHAR2(240);
   l_dummy_email_subject    VARCHAR2(240);

   -- start dhsingh on 02-sep-2004
   l_sender			VARCHAR2(2000);
   l_sender_display_name        VARCHAR2(2000);
   l_dummy_sender_display_name  VARCHAR2(2000);
   l_dummy_sender		VARCHAR2(2000);
   l_reply_to			VARCHAR2(2000);
   l_dummy_reply_to	VARCHAR2(2000);
   -- end dhsingh 0n 02-sep-2004

   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

   l_source_code        VARCHAR2(30);
   l_source_code_id     NUMBER;
   l_delivery_mode VARCHAR2(30); -- prageorg 29-May-2006 for Multipart fix
   l_dummy_delivery_mode	VARCHAR2(30); -- prageorg 29-May-2006 for Multipart fix

   -- soagrawa added these definitions for integrating with 1159 1-to-1 FFM
   -- 12-dec-2002
   l_order_header_rec        JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE;
   l_order_line_tbl          JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE;
   l_fulfill_electronic_rec  JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE;
   y_order_header_rec        ASO_ORDER_INT.ORDER_HEADER_REC_TYPE;
   l_extended_header         VARCHAR2(32767) ;


BEGIN

   x_request_history_id := -1;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_send_request := 0;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : start');

   END IF;
   -- (1)
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : before check for object level trigger');
   END IF;
   OPEN  c_rules_for_object_enabled;
   FETCH c_rules_for_object_enabled INTO l_dummy_template_id, l_dummy_email_subject, l_dummy_sender, l_dummy_reply_to,l_dummy_sender_display_name, l_dummy_delivery_mode;--  dhsingh on 02-sep-2004
         IF c_rules_for_object_enabled%NOTFOUND
         THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : NOT FOUND object level trigger');
               END IF;
               -- (2)
               IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : before check for generic level trigger');
               END IF;
               OPEN  c_rules_generic;
               FETCH c_rules_generic INTO l_dummy_template_id, l_dummy_email_subject,l_dummy_sender, l_dummy_reply_to,l_dummy_sender_display_name, l_dummy_delivery_mode;-- dhsingh on 02-sep-2004
                     IF c_rules_generic%NOTFOUND
                     THEN
                           -- not found
                           IF (AMS_DEBUG_HIGH_ON) THEN

                           AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : NOT FOUND generic level trigger');
                           END IF;
                           NULL;
                     ELSE
                           -- found
                           IF (AMS_DEBUG_HIGH_ON) THEN

                           AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : FOUND generic level trigger');
                           END IF;
                           l_template_id  := l_dummy_template_id;
                           l_email_subject  := l_dummy_email_subject;
			   -- start dhsingh on 02-sep-2004
			   l_sender := l_dummy_sender;
			   l_reply_to := l_dummy_reply_to;
			   l_sender_display_name := l_dummy_sender_display_name;
			   -- end dhsingh on 02-sep-2004
                           -- (3)
			   l_delivery_mode := l_dummy_delivery_mode;
                           IF (AMS_DEBUG_HIGH_ON) THEN

                           AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : before check for is generic level trigger disabled');
                           END IF;
                           OPEN  c_rules_for_object_disabled;
                           FETCH c_rules_for_object_disabled INTO l_dummy_template_id, l_dummy_email_subject, l_dummy_sender, l_dummy_reply_to,l_dummy_sender_display_name, l_dummy_delivery_mode;-- dhsingh on 02-sep-2004
                                 IF c_rules_for_object_disabled%NOTFOUND
                                 THEN
                                     -- not found
                                     IF (AMS_DEBUG_HIGH_ON) THEN

                                     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : generic level trigger NOT disabled');
                                     END IF;
                                     l_send_request := 1;
                                     IF (AMS_DEBUG_HIGH_ON) THEN

                                     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : template id is '||l_template_id);
                                     END IF;
                                     IF (AMS_DEBUG_HIGH_ON) THEN

                                     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : subject is '||l_email_subject);
                                     END IF;
                                      -- start dhsingh on 02-sep-2004
				     IF (AMS_DEBUG_HIGH_ON) THEN
					     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : sender is '||l_sender);
					     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : reply-to is '||l_reply_to);
				     END IF;
				     -- end dhsingh on 02-sep-2004

                                 ELSE
                                     -- found
                                     IF (AMS_DEBUG_HIGH_ON) THEN

                                     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : generic level trigger IS disabled');
                                     END IF;
                                     NULL;
                                 END IF;
                           CLOSE c_rules_for_object_disabled;

                     END IF;
               CLOSE c_rules_generic;

         ELSE
             IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : FOUND object level trigger');
             END IF;
             -- found
             l_send_request := 1;
             l_template_id  := l_dummy_template_id;
             l_email_subject  := l_dummy_email_subject;
	     -- start dhsingh on 02-sep-2004
	     l_sender := l_dummy_sender;
	     l_reply_to := l_dummy_reply_to;
	     l_sender_display_name := l_dummy_sender_display_name;
	     -- end dhsingh on 02-sep-2004
	     -- prageorg 29-May-2006
	     l_delivery_mode := l_dummy_delivery_mode;
             IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : FOUND object level trigger id is '||l_template_id);
             END IF;
             IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : FOUND object level trigger subject is '||l_email_subject);
             END IF;
         END IF;
	 -- start dhsingh on 02-sep-2004
	     IF (AMS_DEBUG_HIGH_ON) THEN
		     begin
		     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : sender is '||l_sender);
		     AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : reply-to is '||l_reply_to);
		     end;
	     END IF;
	     -- end dhsingh on 02-sep-2004
   CLOSE c_rules_for_object_enabled;


   IF l_send_request = 1
   THEN


         -- soagrawa added 15-jul-2002
         -- get source_code info for the object
         OPEN  c_source_code;
         FETCH c_source_code INTO l_source_code, l_source_code_id;
         CLOSE c_source_code ;

         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : BEFORE sending REQUEST ');
         END IF;

         -- soagrawa 12-dec-2002 replaced AMF callout with JTF 1-to-1 call for 11.5.9

         l_fulfill_electronic_rec.template_id     := l_template_id;
         l_fulfill_electronic_rec.object_type     := 'AMS_'||p_object_type;-- modified for 11.5.10
         l_fulfill_electronic_rec.object_id       := p_object_id;
         l_fulfill_electronic_rec.source_code     := l_source_code;
         l_fulfill_electronic_rec.source_code_id  := l_source_code_id;
--         l_fulfill_electronic_rec.requestor_type  := p_requestor_type;
         l_fulfill_electronic_rec.requestor_id    := p_requestor_id; --l_resource_id;
--         l_fulfill_electronic_rec.server_group    := p_server_group;
--         l_fulfill_electronic_rec.schedule_date   := p_scheduled_date;
         l_fulfill_electronic_rec.media_types     := p_media_types;
         --l_fulfill_electronic_rec.archive       := 'N'; -- thts the default
         l_fulfill_electronic_rec.log_user_ih     := p_log_user_ih;
         l_fulfill_electronic_rec.request_type    := p_request_type;
         --l_fulfill_electronic_rec.profile_id      := p_profile_id;
         --l_fulfill_electronic_rec.order_id      := order_id;
         --l_fulfill_electronic_rec.collateral_id := collateral_id;
         l_fulfill_electronic_rec.subject         := l_email_subject;
         --l_fulfill_electronic_rec.party_id      := party_id;
         --l_fulfill_electronic_rec.email         := email;
         --l_fulfill_electronic_rec.fax           := fax;
         l_fulfill_electronic_rec.bind_values     := p_bind_values;
         l_fulfill_electronic_rec.bind_names      := p_bind_names;
         --l_fulfill_electronic_rec.email_text    := email_text;
         --l_fulfill_electronic_rec.content_name  := content_name;
         --l_fulfill_electronic_rec.content_type  := content_type;
         l_fulfill_electronic_rec.stop_list_bypass := 'B'; -- added for 11.5.10
	 l_fulfill_electronic_rec.email_format  := nvl(l_delivery_mode, 'BOTH');

          --start. dhsingh added extended information to pass it to fulfillment server on 02-sep-2004
	 IF (l_sender IS NOT NULL ) OR (l_reply_to IS NOT null) OR (l_sender_display_name IS NOT null)
	 THEN
		l_extended_header :=  '<extended_header>';

		IF  l_sender IS NOT NULL THEN
			 l_extended_header :=   l_extended_header || '<header_name>email_from_address</header_name><header_value>' ||l_sender|| '</header_value>';
		END IF;
		IF  l_reply_to IS NOT NULL THEN
			 l_extended_header :=   l_extended_header || '<header_name>email_reply_to_address</header_name><header_value>' ||l_reply_to|| '</header_value>';
		END IF;
                IF  l_sender_display_name IS NOT NULL THEN
			 l_extended_header :=   l_extended_header || '<header_name>sender_display_name</header_name><header_value>' ||l_sender_display_name|| '</header_value>';
		END IF;

		 l_extended_header :=   l_extended_header || '</extended_header>';
	 /*
	       l_extended_header :=  '<extended_header>
		    <header_name>email_from_address</header_name>
		    <header_value>' ||l_sender|| '</header_value>
		    <header_name>email_reply_to_address</header_name>
		    <header_value>' ||l_reply_to|| '</header_value>
		    </extended_header>';
	   */
	      l_fulfill_electronic_rec.extended_header := l_extended_header;
	  END IF;
	  -- end dhsingh on 02-sep-2004

         -- soagrawa modified for 11.5.10
         --JTF_FM_OCM_REQUEST_GRP.create_fulfillment
         JTF_FM_OCM_REND_REQ.create_fulfillment_rendition
            (
               p_init_msg_list           => p_init_msg_list,
               p_api_version             => p_api_version,
               p_commit                  => p_commit,
               p_order_header_rec        => l_order_header_rec,
               p_order_line_tbl          => l_order_line_tbl,
               p_fulfill_electronic_rec  => l_fulfill_electronic_rec,
               p_request_type            => p_request_type,
               x_return_status           => x_return_status,
               x_msg_count               => x_msg_count,
               x_msg_data                => x_msg_data,
               x_order_header_rec        => y_order_header_rec,
               x_request_history_id      => x_request_history_id
            );

         IF (AMS_DEBUG_HIGH_ON) THEN
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.template_id     := '||l_template_id);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.version_id      := '||'1');
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.object_type     := '||p_object_type);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.object_id       := '||p_object_id);
            ams_utility_pvt.debug_message(' l_fulfill_electronic_rec.source_code     := '||l_source_code);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.source_code_id  := '||l_source_code_id);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.requestor_type  := '||p_requestor_type);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.requestor_id    := '||p_requestor_id); --l_resource_id;
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.server_group    := '||p_server_group);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.schedule_date   := '||p_scheduled_date);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.media_types     := '||p_media_types); --??
            --l_fulfill_electronic_rec.archive       := 'N'; -- thts the default
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.log_user_ih     := '||p_log_user_ih);
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.request_type    := '||p_request_type);
            --l_fulfill_electronic_rec.profile_id      := p_profile_id;
            --l_fulfill_electronic_rec.order_id      := order_id;
            --l_fulfill_electronic_rec.collateral_id := collateral_id;
            ams_utility_pvt.debug_message('l_fulfill_electronic_rec.subject         := '||l_email_subject);
            -- start dhsingh on 02-sep-2004
	    ams_utility_pvt.debug_message('l_fulfill_electronic_rec.extended_header := '||l_extended_header);
	    -- end dhsingh on 02-sep-2004
            ams_utility_pvt.debug_message('Length of bind variables names '|| p_bind_names.count);
            ams_utility_pvt.debug_message('Length of bind variables values '|| p_bind_values.count);
	    ams_utility_pvt.debug_message('Delivery mode '|| l_delivery_mode);

           for i IN 1..p_bind_values.count LOOP
             ams_utility_pvt.debug_message(i||': bind name '  ||p_bind_names(i));
             ams_utility_pvt.debug_message(i||': bind value ' ||p_bind_values(i));
           end loop;



            AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : AFTER sending REQUEST ');
            AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : AFTER sending REQUEST template id sent was '||l_template_id);
            AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : sending REQUEST was '||x_return_status);
            AMS_UTILITY_PVT.debug_message(G_PKG_NAME||' Private API: check_content_rule : AFTER sending REQUEST req_his_id is '||x_request_history_id);
         END IF;
   END IF;


   --    see if there is any object specific rule for this obj type -- trig code -- object id (1)
   --    if  yes use this to get template id
   --    if  no
   --            see if there is any general rule for this obj type -- trig code (2)
   --            if  no  => dont send any request
   --            if  yes =>
   --                       see if it has been disabled for this particular obj id (3)
   --                       if yes => (has been disabled) dont send any request
   --                       if no  => (has not been disabled) send this template id

END check_content_rule;


END AMS_Ct_Rule_PVT;

/
