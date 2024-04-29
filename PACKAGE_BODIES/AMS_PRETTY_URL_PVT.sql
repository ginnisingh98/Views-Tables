--------------------------------------------------------
--  DDL for Package Body AMS_PRETTY_URL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PRETTY_URL_PVT" AS
/* $Header: amsvpurb.pls 120.2 2006/09/06 17:38:19 dbiswas noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_PRETTY_URL_PVT
-- Purpose
--
-- This package contains all the program units for Pretty URLS
--
-- History
--   05/25/05   dbiswas   created
-- NOTE
--
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_PRETTY_URL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvpurb.pls';
g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

--========================================================================
-- PROCEDURE
--    WRITE_LOG
-- Purpose
--   This method will be used to write logs for this api
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================

PROCEDURE WRITE_LOG             ( p_api_name      IN VARCHAR2,
                                  p_log_message   IN VARCHAR2 )
IS

   l_api_name   VARCHAR2(30);
   l_log_mesg   VARCHAR2(2000);
   l_return_status VARCHAR2(1);
BEGIN
      l_api_name := p_api_name;
      l_log_mesg := p_log_message;
      AMS_Utility_PVT.debug_message (
                        p_log_level   => g_log_level,
                        p_module_name => 'ams.plsql.'||'.'|| g_pkg_name||'.'||l_api_name,
                        p_text => p_log_message
                       );

   AMS_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status,
                     p_arc_log_used_by => 'PRETTY_URL',
                     p_log_used_by_id  => 1,
                     p_msg_data        => 'amsvpurb.pls: '||p_log_message,
                     p_msg_type        => 'DEBUG'
                     );
 END WRITE_LOG;


-- ===============================================================
-- Start of Comments
-- Name
-- IS_SYSTEM_URL_UNIQ
--
-- Purpose
-- This procedure
--
--========================================================================

Procedure IS_SYSTEM_URL_UNIQ(
                             p_sys_url                 IN   VARCHAR2,
                             p_current_used_by_id      IN   NUMBER,
                             p_current_used_by_type    IN   VARCHAR2,
                             x_return_status            OUT NOCOPY  VARCHAR2
)
IS

   l_api_name       VARCHAR2(30);
   l_activity_type_code    VARCHAR2(30);
   l_activity_id           NUMBER ;
   l_scheduleName          VARCHAR2(240);
   l_ownerName             VARCHAR2(360);


cursor c_is_prettyUrl_supported  IS
SELECT activity_type_code, activity_id
FROM   ams_campaign_schedules_b
WHERE  schedule_id = p_current_used_by_id;

CURSOR c_is_sysUrl_unique IS
SELECT sched.schedule_name, res.full_name
 FROM ams_pretty_url_assoc assoc,
              ams_system_pretty_url sysUrl,
              ams_campaign_schedules_vl sched,
              ams_jtf_rs_emp_v res
WHERE sysUrl.system_url = p_sys_url
AND   sysUrl.system_url_id = assoc.system_url_id
AND   assoc.used_by_obj_Id <> p_current_used_by_id
AND   sched.SCHEDULE_ID = assoc.used_by_obj_id
AND   res.resource_id = sched.owner_user_id
AND   sched.status_code in ('SUBMITTED_BA', 'AVAILABLE', 'ACTIVE', 'COMPLETED');


PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'IS_SYSTEM_URL_UNIQ';

BEGIN

  x_return_status := FND_API.g_ret_sts_success;
  l_api_name   :='IS_SYSTEM_URL_UNIQ';
   WRITE_LOG(l_api_name, 'Entering AMS_PRETTY_URL_PVT.IS_SYSTEM_URL_UNIQ ');

   IF p_sys_url IS NULL THEN
      WRITE_LOG(l_api_name, 'System Value entered is null ');
      RETURN;
   END IF;

  IF p_current_used_by_type = 'CSCH'
  THEN
      OPEN  c_is_prettyUrl_supported;
      FETCH c_is_prettyUrl_supported  into l_activity_type_code, l_activity_id ;
      IF c_is_prettyUrl_supported%NOTFOUND THEN
          CLOSE c_is_prettyUrl_supported;
          x_return_status := FND_API.g_ret_sts_error;
          WRITE_LOG(l_api_name, 'No schedule found with id '||p_current_used_by_id);
          AMS_Utility_PVT.error_message('AMS_CSCH_NO_MEDIA_TYPE'); -- need to seed message here
      END IF;
      CLOSE c_is_prettyUrl_supported;

      IF l_activity_type_code IS NULL THEN
          WRITE_LOG(l_api_name, 'Activity type code not found for schedule '||p_current_used_by_id);
          AMS_Utility_PVT.error_message('AMS_CSCH_NO_MEDIA_TYPE');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;

      IF l_activity_type_code <>'DIRECT_MARKETING'
      AND l_activity_type_code <> 'BROADCAST'
      AND l_activity_type_code <> 'PUBLIC_RELATIONS'
      THEN
           WRITE_LOG(l_api_name, 'Pretty url is not supported for schedule '||p_current_used_by_id||'. Skipping the rest of the check');
           x_return_status := FND_API.g_ret_sts_success;
           RETURN;
      END IF;

      --  Check if channel not Email, Telemarketing, or if template is Advertising or Public_relations
      IF (l_activity_type_code ='DIRECT_MARKETING'
      AND  ( l_activity_id <> 20 OR l_activity_id <> 460))
      OR   (l_activity_type_code ='BROADCAST')
      OR   (l_activity_type_code ='PUBLIC_RELATIONS')
      THEN
          WRITE_LOG(l_api_name, 'Pretty url is supported for schedule '||p_current_used_by_id);
          OPEN c_is_sysUrl_unique;
          FETCH c_is_sysUrl_unique INTO l_scheduleName, l_ownerName;
          CLOSE c_is_sysUrl_unique;

          IF l_scheduleName is not null
          THEN
              WRITE_LOG(l_api_name,  p_sys_url||' is also used by ' ||p_current_used_by_id);
              x_return_status := FND_API.g_ret_sts_error;
              FND_MESSAGE.set_name('AMS', 'AMS_PRETTY_URL_NOT_UNIQUE_ERR');
              FND_MESSAGE.set_token('SCHEDULENAME', l_scheduleName);
              FND_MESSAGE.set_token('OWNER', l_ownerName);
              FND_MSG_PUB.add;
              RETURN;
          END IF;
      END IF;
    END IF;
    WRITE_LOG(l_api_name, 'Exiting is_SYSTEM_URL_UNIQ');
END IS_SYSTEM_URL_UNIQ;
-- Hint: Primary key needs to be returned.
PROCEDURE Create_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pretty_url_rec               IN   pretty_url_rec_type  := g_miss_pretty_url_rec,
    x_pretty_url_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_PRETTY_URL_ID                  NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMS_PRETTY_URL_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_PRETTY_URL
      WHERE PRETTY_URL_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Pretty_Url_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_pretty_url_rec.PRETTY_URL_ID IS NULL OR p_pretty_url_rec.PRETTY_URL_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_PRETTY_URL_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_PRETTY_URL_ID);
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
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Pretty_Url');

          -- Invoke validation procedures
          Validate_pretty_url(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_pretty_url_rec  =>  p_pretty_url_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_PRETTY_URL_PKG.Insert_Row)
      AMS_PRETTY_URL_PKG.Insert_Row(
          px_pretty_url_id  => l_pretty_url_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_landing_page_url  => p_pretty_url_rec.landing_page_url);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_pretty_url_id := l_pretty_url_id;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO CREATE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Pretty_Url_PVT;
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
End Create_Pretty_Url;


PROCEDURE Update_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pretty_url_rec               IN    pretty_url_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
CURSOR c_get_pretty_url(pretty_url_id NUMBER) IS
    SELECT *
    FROM  AMS_PRETTY_URL;
    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_PRETTY_URL_ID    NUMBER;
l_ref_pretty_url_rec  c_get_Pretty_Url%ROWTYPE ;
l_tar_pretty_url_rec  AMS_Pretty_Url_PVT.pretty_url_rec_type := P_pretty_url_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Pretty_Url_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

/*
      OPEN c_get_Pretty_Url( l_tar_pretty_url_rec.pretty_url_id);

      FETCH c_get_Pretty_Url INTO l_ref_pretty_url_rec  ;

       If ( c_get_Pretty_Url%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Pretty_Url') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Pretty_Url;
*/


      If (l_tar_pretty_url_rec.object_version_number is NULL or
          l_tar_pretty_url_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_pretty_url_rec.object_version_number <> l_ref_pretty_url_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Pretty_Url') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Pretty_Url');

          -- Invoke validation procedures
          Validate_pretty_url(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_pretty_url_rec  =>  p_pretty_url_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMS_PRETTY_URL_PKG.Update_Row)
      AMS_PRETTY_URL_PKG.Update_Row(
          p_pretty_url_id  => p_pretty_url_rec.pretty_url_id,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_pretty_url_rec.object_version_number,
          p_landing_page_url  => p_pretty_url_rec.landing_page_url);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO UPDATE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Pretty_Url_PVT;
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
End Update_Pretty_Url;


PROCEDURE Delete_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_pretty_url_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Pretty_Url_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMS_PRETTY_URL_PKG.Delete_Row)
      AMS_PRETTY_URL_PKG.Delete_Row(
          p_PRETTY_URL_ID  => p_PRETTY_URL_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO DELETE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Pretty_Url_PVT;
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
End Delete_Pretty_Url;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Pretty_Url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pretty_url_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_PRETTY_URL_ID                  NUMBER;

CURSOR c_Pretty_Url IS
   SELECT PRETTY_URL_ID
   FROM AMS_PRETTY_URL
   WHERE PRETTY_URL_ID = p_PRETTY_URL_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Pretty_Url;

  FETCH c_Pretty_Url INTO l_PRETTY_URL_ID;

  IF (c_Pretty_Url%NOTFOUND) THEN
    CLOSE c_Pretty_Url;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Pretty_Url;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Pretty_Url_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Pretty_Url_PVT;
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
End Lock_Pretty_Url;


PROCEDURE check_pretty_url_uk_items(
    p_pretty_url_rec               IN   pretty_url_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PRETTY_URL',
         'PRETTY_URL_ID = ''' || p_pretty_url_rec.PRETTY_URL_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_PRETTY_URL',
         'PRETTY_URL_ID = ''' || p_pretty_url_rec.PRETTY_URL_ID ||
         ''' AND PRETTY_URL_ID <> ' || p_pretty_url_rec.PRETTY_URL_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_PRETTY_URL_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_pretty_url_uk_items;

PROCEDURE check_pretty_url_req_items(
    p_pretty_url_rec               IN  pretty_url_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_pretty_url_rec.pretty_url_id = FND_API.g_miss_num OR p_pretty_url_rec.pretty_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_pretty_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.creation_date = FND_API.g_miss_date OR p_pretty_url_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.created_by = FND_API.g_miss_num OR p_pretty_url_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.last_update_date = FND_API.g_miss_date OR p_pretty_url_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.last_updated_by = FND_API.g_miss_num OR p_pretty_url_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.landing_page_url = FND_API.g_miss_char OR p_pretty_url_rec.landing_page_url IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_landing_page_url');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_pretty_url_rec.pretty_url_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_pretty_url_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_pretty_url_rec.landing_page_url IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_pretty_url_NO_landing_page_url');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_pretty_url_req_items;

PROCEDURE check_pretty_url_FK_items(
    p_pretty_url_rec IN pretty_url_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_pretty_url_FK_items;

PROCEDURE check_pretty_url_Lookup_items(
    p_pretty_url_rec IN pretty_url_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_pretty_url_Lookup_items;

PROCEDURE Check_pretty_url_Items (
    P_pretty_url_rec     IN    pretty_url_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_pretty_url_uk_items(
      p_pretty_url_rec => p_pretty_url_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_pretty_url_req_items(
      p_pretty_url_rec => p_pretty_url_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_pretty_url_FK_items(
      p_pretty_url_rec => p_pretty_url_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_pretty_url_Lookup_items(
      p_pretty_url_rec => p_pretty_url_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_pretty_url_Items;


PROCEDURE Complete_pretty_url_Rec (
   p_pretty_url_rec IN pretty_url_rec_type,
   x_complete_rec OUT NOCOPY pretty_url_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_pretty_url
      WHERE pretty_url_id = p_pretty_url_rec.pretty_url_id;
   l_pretty_url_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_pretty_url_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_pretty_url_rec;
   CLOSE c_complete;

   -- pretty_url_id
   IF p_pretty_url_rec.pretty_url_id = FND_API.g_miss_num THEN
      x_complete_rec.pretty_url_id := l_pretty_url_rec.pretty_url_id;
   END IF;

   -- creation_date
   IF p_pretty_url_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_pretty_url_rec.creation_date;
   END IF;

   -- created_by
   IF p_pretty_url_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_pretty_url_rec.created_by;
   END IF;

   -- last_update_date
   IF p_pretty_url_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_pretty_url_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_pretty_url_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_pretty_url_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_pretty_url_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_pretty_url_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_pretty_url_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_pretty_url_rec.object_version_number;
   END IF;

   -- landing_page_url
   IF p_pretty_url_rec.landing_page_url = FND_API.g_miss_char THEN
      x_complete_rec.landing_page_url := l_pretty_url_rec.landing_page_url;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_pretty_url_Rec;
PROCEDURE Validate_pretty_url(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_pretty_url_rec               IN   pretty_url_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Pretty_Url';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_pretty_url_rec  AMS_Pretty_Url_PVT.pretty_url_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Pretty_Url_;

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
              Check_pretty_url_Items(
                 p_pretty_url_rec        => p_pretty_url_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_pretty_url_Rec(
         p_pretty_url_rec        => p_pretty_url_rec,
         x_complete_rec        => l_pretty_url_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_pretty_url_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_pretty_url_rec           =>    l_pretty_url_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO VALIDATE_Pretty_Url_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Pretty_Url_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Pretty_Url_;
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
End Validate_Pretty_Url;


PROCEDURE Validate_pretty_url_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_pretty_url_rec             IN    pretty_url_rec_type
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
      AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_pretty_url_Rec;

--========================================================================
-- PROCEDURE
--    CHECK_PU_MANDATORY_FIELDS
--
-- PURPOSE
--    This api is created to be used for validating pretty url mandatory fields during
--    schedule status changes.
--
-- HISTORY
--  30-Aug-2006    dbiswas    Created.
--========================================================================

PROCEDURE CHECK_PU_MANDATORY_FIELDS(
    p_pretty_url_rec               IN  pretty_url_rec_type,
    x_return_status	         OUT NOCOPY VARCHAR2
    )

IS
l_api_name       VARCHAR2(30) := 'CHECK_PU_MANDATORY_FIELDS';
BEGIN
      x_return_status := FND_API.g_ret_sts_success;


      IF p_pretty_url_rec.pretty_url_id = FND_API.g_miss_num OR p_pretty_url_rec.pretty_url_id IS NULL THEN
          WRITE_LOG(l_api_name, 'Pretty Url Id not found');
          --AMS_Utility_PVT.error_message('AMS_pretty_url_NO_pretty_url_id'); -- need to seed message here
          x_return_status := FND_API.g_ret_sts_error;
          FND_MESSAGE.set_name('AMS', 'AMS_pretty_url_NO_pretty_url_id');
          FND_MSG_PUB.add;
        RETURN;
      END IF;

      IF p_pretty_url_rec.landing_page_url = FND_API.g_miss_char OR p_pretty_url_rec.landing_page_url IS NULL THEN
         WRITE_LOG(l_api_name, 'Landing page Url not found');
        --AMS_Utility_PVT.Error_Message('AMS_REQ_FIELDS_NOT_MAPPED');
          x_return_status := FND_API.g_ret_sts_error;
          FND_MESSAGE.set_name('AMS', 'AMS_PU_REQ_FIELDS_NOT_MAPPED');
          FND_MSG_PUB.add;
        RETURN;
      END IF;

END CHECK_PU_MANDATORY_FIELDS;


END AMS_PRETTY_URL_PVT;

/
