--------------------------------------------------------
--  DDL for Package Body AMS_PS_POSTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_POSTING_PVT" as
/* $Header: amsvpstb.pls 115.10 2003/02/12 03:49:56 ryedator ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ps_Posting_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvpstb.pls';

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ps_Posting(
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,

    p_ps_posting_rec     IN  ps_posting_rec_type := g_miss_ps_posting_rec,
    x_posting_id         OUT NOCOPY NUMBER
     )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Ps_Posting';
l_api_version_number        CONSTANT NUMBER := 1.0;
   l_return_status_full     VARCHAR2(1);
   l_object_version_number  NUMBER := 1;
   l_org_id                 NUMBER := FND_API.G_MISS_NUM;
   l_posting_id             NUMBER;
   l_dummy       NUMBER;
   l_tempchar    VARCHAR2(1);

   CURSOR c_id IS
      SELECT AMS_IBA_PS_POSTINGS_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IBA_PS_POSTINGS_B
      WHERE POSTING_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ps_Posting_PVT;

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

   IF p_ps_posting_rec.POSTING_ID IS NULL OR p_ps_posting_rec.POSTING_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_posting_id;
         CLOSE c_id;

         OPEN c_id_exists(l_posting_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- ==============================================================
      -- Validate Environment
      -- ==============================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
        IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: Calling Validate_Ps_Posting');
        END IF;

          -- Invoke validation procedures
        Validate_ps_posting(
            p_api_version_number => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_posting_rec  =>  p_ps_posting_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Private API: Calling create table handler');
      END IF;

   BEGIN
    select 'X' into l_tempchar
    from AMS_IBA_PS_POSTINGS_TL ptl
    where ptl.posting_name = p_ps_posting_rec.posting_name
    and ptl.language = userenv('LANG');

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
          l_tempchar := null;
  END;

  IF (l_tempchar = 'X') THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   THEN
        FND_MESSAGE.set_name('AMS','AMS_POST_NAME_NOT_UNIQUE');
        FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
  END IF;


      -- Invoke table handler(AMS_IBA_PS_POSTINGS_B_PKG.Insert_Row)
      AMS_IBA_PS_POSTINGS_B_PKG.Insert_Row(
          p_created_by  => FND_GLOBAL.user_id,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.user_id,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          px_posting_id  => l_posting_id,
          p_max_no_contents  => p_ps_posting_rec.max_no_contents,
          p_posting_type  => p_ps_posting_rec.posting_type,
          p_content_type  => p_ps_posting_rec.content_type,
          p_default_content_id  => p_ps_posting_rec.default_content_id,
          p_status_code  => p_ps_posting_rec.status_code,
          p_posting_name  => p_ps_posting_rec.posting_name,
          p_display_name  => p_ps_posting_rec.display_name,
          p_posting_description  => p_ps_posting_rec.posting_description,
          p_attribute_category  => p_ps_posting_rec.attribute_category,
          p_attribute1  => p_ps_posting_rec.attribute1,
          p_attribute2  => p_ps_posting_rec.attribute2,
          p_attribute3  => p_ps_posting_rec.attribute3,
          p_attribute4  => p_ps_posting_rec.attribute4,
          p_attribute5  => p_ps_posting_rec.attribute5,
          p_attribute6  => p_ps_posting_rec.attribute6,
          p_attribute7  => p_ps_posting_rec.attribute7,
          p_attribute8  => p_ps_posting_rec.attribute8,
          p_attribute9  => p_ps_posting_rec.attribute9,
          p_attribute10  => p_ps_posting_rec.attribute10,
          p_attribute11  => p_ps_posting_rec.attribute11,
          p_attribute12  => p_ps_posting_rec.attribute12,
          p_attribute13  => p_ps_posting_rec.attribute13,
          p_attribute14  => p_ps_posting_rec.attribute14,
          p_attribute15  => p_ps_posting_rec.attribute15);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
      x_posting_id := l_posting_id;

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
        (p_count => x_msg_count,
         p_data  => x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ps_Posting_PVT;
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
End Create_Ps_Posting;


PROCEDURE Update_Ps_Posting(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_ps_posting_rec        IN   ps_posting_rec_type,
    x_object_version_number OUT NOCOPY  NUMBER
    )
 IS
l_api_name            CONSTANT VARCHAR2(30) := 'Update_Ps_Posting';
l_api_version_number  CONSTANT NUMBER := 1.0;
l_object_version      NUMBER;
l_tempchar	      VARCHAR2(1);

CURSOR c_object_version(post_id IN NUMBER) IS
    SELECT object_version_number
    FROM  AMS_IBA_PS_POSTINGS_B
    WHERE posting_id = post_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ps_Posting_PVT;

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

      OPEN c_object_version(p_ps_posting_rec.posting_id);

      FETCH c_object_version INTO l_object_version;

       If ( c_object_version%NOTFOUND) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
          p_token_name   => 'INFO',
          p_token_value  => 'Ps_Posting') ;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE  c_object_version;


      IF (p_ps_posting_rec.object_version_number is NULL or
          p_ps_posting_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
          p_token_name   => 'COLUMN',
          p_token_value  => 'object_version_number') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (p_ps_posting_rec.object_version_number <> l_object_version) THEN
        AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
          p_token_name   => 'INFO',
          p_token_value  => 'Ps_Posting') ;
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: Validate_Ps_Posting');
          END IF;

          -- Invoke validation procedures
          Validate_ps_posting(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ps_posting_rec  =>  p_ps_posting_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Private API: Updating B and TL Tables');
      END IF;

       Update AMS_IBA_PS_POSTINGS_B
       SET
         last_updated_by = FND_GLOBAL.user_id,
         last_update_date = SYSDATE,
         last_update_login = FND_GLOBAL.conc_login_id,
         object_version_number = p_ps_posting_rec.object_version_number+1,
         max_no_contents = DECODE( p_ps_posting_rec.max_no_contents, FND_API.g_miss_num, max_no_contents, p_ps_posting_rec.max_no_contents),
         posting_type = DECODE( p_ps_posting_rec.posting_type, FND_API.g_miss_char, posting_type, p_ps_posting_rec.posting_type),
         content_type = DECODE( p_ps_posting_rec.content_type, FND_API.g_miss_char, content_type, p_ps_posting_rec.content_type),
         default_content_id = DECODE( p_ps_posting_rec.default_content_id, FND_API.g_miss_num, default_content_id, p_ps_posting_rec.default_content_id),
         status_code = DECODE( p_ps_posting_rec.status_code, FND_API.g_miss_char, status_code, p_ps_posting_rec.status_code),
       attribute_category = DECODE( p_ps_posting_rec.attribute_category, FND_API.g_miss_char, attribute_category, p_ps_posting_rec.attribute_category),
       attribute1 = DECODE( p_ps_posting_rec.attribute1, FND_API.g_miss_char, attribute1, p_ps_posting_rec.attribute1),
       attribute2 = DECODE( p_ps_posting_rec.attribute2, FND_API.g_miss_char, attribute2, p_ps_posting_rec.attribute2),
       attribute3 = DECODE( p_ps_posting_rec.attribute3, FND_API.g_miss_char, attribute3, p_ps_posting_rec.attribute3),
       attribute4 = DECODE( p_ps_posting_rec.attribute4, FND_API.g_miss_char, attribute4, p_ps_posting_rec.attribute4),
       attribute5 = DECODE( p_ps_posting_rec.attribute5, FND_API.g_miss_char, attribute5, p_ps_posting_rec.attribute5),
       attribute6 = DECODE( p_ps_posting_rec.attribute6, FND_API.g_miss_char, attribute6, p_ps_posting_rec.attribute6),
       attribute7 = DECODE( p_ps_posting_rec.attribute7, FND_API.g_miss_char, attribute7, p_ps_posting_rec.attribute7),
       attribute8 = DECODE( p_ps_posting_rec.attribute8, FND_API.g_miss_char, attribute8, p_ps_posting_rec.attribute8),
       attribute9 = DECODE( p_ps_posting_rec.attribute9, FND_API.g_miss_char, attribute9, p_ps_posting_rec.attribute9),
       attribute10 = DECODE( p_ps_posting_rec.attribute10, FND_API.g_miss_char, attribute10, p_ps_posting_rec.attribute10),
       attribute11 = DECODE( p_ps_posting_rec.attribute11, FND_API.g_miss_char, attribute11, p_ps_posting_rec.attribute11),
       attribute12 = DECODE( p_ps_posting_rec.attribute12, FND_API.g_miss_char, attribute12, p_ps_posting_rec.attribute12),
       attribute13 = DECODE( p_ps_posting_rec.attribute13, FND_API.g_miss_char, attribute13, p_ps_posting_rec.attribute13),
       attribute14 = DECODE( p_ps_posting_rec.attribute14, FND_API.g_miss_char, attribute14, p_ps_posting_rec.attribute14),
       attribute15 = DECODE( p_ps_posting_rec.attribute15, FND_API.g_miss_char, attribute15, p_ps_posting_rec.attribute15)

      WHERE posting_id = p_ps_posting_rec.posting_id
      AND object_version_number = p_ps_posting_rec.object_version_number;

      IF (SQL%NOTFOUND) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.debug_message('Private API: Updated B');
      END IF;

  BEGIN
    select 'X' into l_tempchar
    from AMS_IBA_PS_POSTINGS_TL ptl
    where ptl.posting_name = p_ps_posting_rec.posting_name
    and ptl.language = userenv('LANG')
    and p_ps_posting_rec.posting_id <> ptl.posting_id;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
          l_tempchar := null;
  END;

  IF (l_tempchar = 'X') THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   THEN
        FND_MESSAGE.set_name('AMS','AMS_POST_NAME_NOT_UNIQUE');
        FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
  END IF;

     UPDATE AMS_IBA_PS_POSTINGS_TL SET
       posting_name = decode( p_ps_posting_rec.posting_name, FND_API.G_MISS_CHAR, posting_name, p_ps_posting_rec.posting_name),
       display_name = decode( p_ps_posting_rec.display_name, FND_API.G_MISS_CHAR, display_name, p_ps_posting_rec.display_name),
       posting_description = decode( p_ps_posting_rec.posting_description, FND_API.G_MISS_CHAR, posting_description, p_ps_posting_rec.posting_description),
       last_update_date = SYSDATE,
       last_updated_by = FND_GLOBAL.user_id,
       last_update_login = FND_GLOBAL.conc_login_id,
       source_lang = USERENV('LANG')
     WHERE posting_id = p_ps_posting_rec.posting_id
     AND USERENV('LANG') IN (language, source_lang);

     IF (SQL%NOTFOUND) THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Private API: Updated TL');
     END IF;

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
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ps_Posting_PVT;
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
End Update_Ps_Posting;


PROCEDURE Delete_Ps_Posting(
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_posting_id             IN  NUMBER,
    p_object_version_number  IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ps_Posting';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_is_used_count             NUMBER;
l_rulegroup_id              NUMBER;
l_object_version_number     NUMBER;


CURSOR c_is_used_count(post_id IN NUMBER) IS
	SELECT COUNT(*)
	FROM AMS_IBA_PL_PLACEMENTS_B
	where posting_id = post_id;

CURSOR c_object_version_number(post_id IN NUMBER) IS
	SELECT object_version_number
	FROM AMS_IBA_PS_POSTINGS_B
	where posting_id = post_id;

CURSOR c_rulegroup_id(post_id IN NUMBER) IS
	SELECT rulegroup_id
	FROM AMS_IBA_PS_RULEGRPS_B
	where posting_id = post_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Posting_PVT;

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

      OPEN c_is_used_count(p_posting_id);
      FETCH c_is_used_count INTO l_is_used_count;
      CLOSE c_is_used_count;

      OPEN c_object_version_number(p_posting_id);
      FETCH c_object_version_number INTO l_object_version_number;
      CLOSE c_object_version_number;

      IF l_is_used_count = 0 THEN                             -- IS NOT USED
        IF l_object_version_number = p_object_version_number  THEN -- VERSIONS MATCH
          DELETE FROM AMS_IBA_PS_POSTINGS_B
          WHERE posting_id = p_posting_id;

          IF (SQL%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS','AMS_API_RECORD_NOT_FOUND');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
          END IF;

          DELETE FROM AMS_IBA_PS_POSTINGS_TL
          WHERE posting_id = p_posting_id;

          IF (SQL%NOTFOUND) THEN
            RAISE FND_API.g_exc_error;
          END IF;

          FOR c_rulegroup_id_rec IN c_rulegroup_id(p_posting_id) LOOP
            l_rulegroup_id := c_rulegroup_id_rec.rulegroup_id;

            DELETE FROM AMS_IBA_PS_RULES
            WHERE rulegroup_id = l_rulegroup_id;

            DELETE FROM AMS_IBA_PS_RULEGRPS_TL
            WHERE rulegroup_id = l_rulegroup_id;

            DELETE FROM AMS_IBA_PS_RL_ST_PARAMS
            WHERE rulegroup_id = l_rulegroup_id;

            DELETE FROM AMS_IBA_PS_RL_ST_FLTRS
            WHERE rulegroup_id = l_rulegroup_id;

          END LOOP;

          DELETE FROM AMS_IBA_PS_RULEGRPS_B
          WHERE posting_id = p_posting_id;

        ELSE             -- VERSIONS DON'T MATCH
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS','AMS_API_VERS_DONT_MATCH');
              FND_MSG_PUB.add;
            END IF;
          RAISE FND_API.g_exc_error;
        END IF;
      ELSE                                   -- IS USED
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS','AMS_POSTING_IN_USE');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT;
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
     ROLLBACK TO DELETE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Posting_PVT;
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
End Delete_Ps_Posting;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Ps_Posting(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_posting_id          IN  NUMBER,
    p_object_version      IN  NUMBER
    )

 IS
L_API_NAME             CONSTANT VARCHAR2(30) := 'Lock_Ps_Posting';
L_API_VERSION_NUMBER   CONSTANT NUMBER   := 1.0;
L_FULL_NAME            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_POSTING_ID           NUMBER;

CURSOR c_Ps_Posting IS
   SELECT POSTING_ID
   FROM AMS_IBA_PS_POSTINGS_B
   WHERE POSTING_ID = p_POSTING_ID
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
  OPEN c_Ps_Posting;

  FETCH c_Ps_Posting INTO l_POSTING_ID;

  IF (c_Ps_Posting%NOTFOUND) THEN
    CLOSE c_Ps_Posting;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Ps_Posting;

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
     ROLLBACK TO LOCK_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ps_Posting_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ps_Posting_PVT;
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
End Lock_Ps_Posting;


PROCEDURE Complete_ps_posting_Rec (
   p_ps_posting_rec IN ps_posting_rec_type,
   x_complete_rec OUT NOCOPY ps_posting_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_iba_ps_postings_b
      WHERE posting_id = p_ps_posting_rec.posting_id;
   l_ps_posting_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ps_posting_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ps_posting_rec;
   CLOSE c_complete;

   -- created_by
   IF p_ps_posting_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ps_posting_rec.created_by;
   END IF;

   -- creation_date
   IF p_ps_posting_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ps_posting_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ps_posting_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ps_posting_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ps_posting_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ps_posting_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ps_posting_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ps_posting_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ps_posting_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ps_posting_rec.object_version_number;
   END IF;

   -- posting_id
   IF p_ps_posting_rec.posting_id = FND_API.g_miss_num THEN
      x_complete_rec.posting_id := l_ps_posting_rec.posting_id;
   END IF;

   -- max_no_contents
   IF p_ps_posting_rec.max_no_contents = FND_API.g_miss_num THEN
      x_complete_rec.max_no_contents := l_ps_posting_rec.max_no_contents;
   END IF;

   -- posting_type
   IF p_ps_posting_rec.posting_type = FND_API.g_miss_char THEN
      x_complete_rec.posting_type := l_ps_posting_rec.posting_type;
   END IF;

   -- content_type
   IF p_ps_posting_rec.content_type = FND_API.g_miss_char THEN
      x_complete_rec.content_type := l_ps_posting_rec.content_type;
   END IF;

   -- default_content_id
   IF p_ps_posting_rec.default_content_id = FND_API.g_miss_num THEN
      x_complete_rec.default_content_id := l_ps_posting_rec.default_content_id;
   END IF;

   -- status_code
   IF p_ps_posting_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := l_ps_posting_rec.status_code;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ps_posting_Rec;

PROCEDURE Validate_ps_posting(
    p_api_version_number IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ps_posting_rec     IN   ps_posting_rec_type,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME               CONSTANT VARCHAR2(30) := 'Validate_Ps_Posting';
L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_ps_posting_rec  AMS_Ps_Posting_PVT.ps_posting_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Ps_Posting_;

     IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_Utility_PVT.debug_message('In '||L_API_NAME);

     END IF;

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

      ---------------------- validate ------------------------
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
        Check_ps_posting_Items
        (
           p_ps_posting_rec  => p_ps_posting_rec,
           p_validation_mode => JTF_PLSQL_API.g_create,
           x_return_status   => x_return_status
        );

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        END IF;
      END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message(L_API_NAME || ': validation done');
     END IF;

     -------------------- finish --------------------------
     FND_MSG_PUB.count_and_get
     (
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Posting_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ps_Posting_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ps_Posting_;
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
End Validate_Ps_Posting;

PROCEDURE Validate_ps_posting_rec(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_ps_posting_rec      IN   ps_posting_rec_type
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

      AMS_UTILITY_PVT.debug_message('Private API: Validate_ps_Posting_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ps_posting_Rec;

/***********************************************************************/
-- Procedure: Check_ps_posting_Items
--
-- History
--   05/07/2001    asaha    created
-------------------------------------------------------------------------
PROCEDURE Check_ps_posting_Items
(
    p_ps_posting_rec     IN  ps_posting_rec_type,
    p_validation_mode    IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2
)
IS
  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check_ps_posting_items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN
-- initialize
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': start');
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

-- check required items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check required items');
  END IF;
  check_ps_posting_req_items
  (
    p_validation_mode => p_validation_mode,
    p_ps_posting_rec  => p_ps_posting_rec,
    x_return_status   => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

-- check foreign key items
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name || ': check fk items');
  END IF;
  check_ps_posting_fk_items
  (
    p_ps_posting_rec  => p_ps_posting_rec,
    x_return_status   => x_return_status
  );

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name || ': done with checking items');

  END IF;

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END Check_ps_posting_Items;


/*****************************************************************************/
-- Procedure: check_ps_posting_req_items
--
-- History
--   05/07/2001    asaha    created
-------------------------------------------------------------------------------
PROCEDURE check_ps_posting_req_items
(
  p_validation_mode  IN  VARCHAR2,
  p_ps_posting_rec   IN  ps_posting_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2
)
IS
  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check_ps_posting_req_items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN

  x_return_status := FND_API.g_ret_sts_success;

END check_ps_posting_req_items;


/*****************************************************************************/
-- Procedure: check_ps_posting_fk_items
--
-- History
--   05/07/2001    asaha    created
-------------------------------------------------------------------------------
PROCEDURE check_ps_posting_fk_items
(
  p_ps_posting_rec  IN  ps_posting_rec_type,
  x_return_status   OUT NOCOPY  VARCHAR2
)
IS
  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'check_ps_posting_fk_items';
  l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN

  x_return_status := FND_API.g_ret_sts_success;

END check_ps_posting_fk_items;

END AMS_Ps_Posting_PVT;

/
