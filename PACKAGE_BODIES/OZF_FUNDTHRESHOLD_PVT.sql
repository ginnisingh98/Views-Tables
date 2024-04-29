--------------------------------------------------------
--  DDL for Package Body OZF_FUNDTHRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDTHRESHOLD_PVT" as
/* $Header: ozfvthrb.pls 120.0 2005/06/01 01:17:00 appldev noship $ */
-- ===============================================================

-- Start of Comments
-- Package name
--          OZF_Fundthreshold_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Fundthreshold_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvthrb.pls';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    check_threshold_calendar
   --
   -- HISTORY

   -----------------------------------------------------------------------

PROCEDURE check_threshold_calendar(
      p_threshold_id       IN     NUMBER
     , p_threshold_calendar       IN       VARCHAR2
     ,p_start_period_name   IN       VARCHAR2
     ,p_end_period_name     IN       VARCHAR2
     ,p_start_date          IN       DATE
     ,p_end_date            IN       DATE
     ,x_return_status       OUT   NOCOPY   VARCHAR2)
   IS
      l_start_start    DATE;
      l_start_end      DATE;
      l_end_start      DATE;
      l_end_end        DATE;
      l_local          NUMBER;

      CURSOR c_threshold_calendar
      IS
         SELECT   1
         FROM     dual
         WHERE  EXISTS(SELECT   1
                       FROM     gl_periods_v
                       WHERE  period_set_name = p_threshold_calendar);

      CURSOR c_start_period
      IS
         SELECT   start_date, end_date
         FROM     gl_periods_v
         WHERE  period_set_name = p_threshold_calendar
            AND period_name = p_start_period_name;

      CURSOR c_end_period
      IS
         SELECT   start_date, end_date
         FROM     gl_periods_v
         WHERE  period_set_name = p_threshold_calendar
            AND period_name = p_end_period_name;

      CURSOR c_rule_date(p_threshold_id NUMBER)
      IS
         SELECT start_date, end_date
	 FROM ozf_threshold_rules_all
	 WHERE threshold_id = p_threshold_id;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Check Date: start');
      END IF;

      -- compare the start date and the end date
      IF p_start_date > p_end_date THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_STARTDATE_OUT_ENDDATE');
	 RETURN;
      END IF;

      -- compare start date and end date with threshold rule's start date and end date
      -- only for update.
      IF p_threshold_id IS NOT NULL THEN
         FOR rule IN c_rule_date(p_threshold_id)
           LOOP
             --BEGIN
               IF p_start_date > rule.start_date
	          OR p_end_date < rule.end_date THEN
                  x_return_status := fnd_api.g_ret_sts_error;
                  ozf_utility_pvt.error_message('OZF_TRSH_OUT_THRESHOLD_RULE');
		  RETURN;
               END IF;
            -- END;
           END LOOP;
      END IF;

      -- check if p_threshold_calendar is null
      IF     p_threshold_calendar IS NULL
         AND p_start_period_name IS NULL
         AND p_end_period_name IS NULL THEN
         RETURN;
      ELSIF p_threshold_calendar IS NULL THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_FUND_NO_CALENDAR');
         RETURN;
      END IF;

      -- check if p_threshold_calendar is valid
      OPEN c_threshold_calendar;
      FETCH c_threshold_calendar INTO l_local;
      CLOSE c_threshold_calendar;

      IF l_local IS NULL THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_FUND_BAD_CALENDAR');
         RETURN;
      END IF;

      -- check p_start_period_name
      IF p_start_period_name IS NOT NULL THEN
         OPEN c_start_period;
         FETCH c_start_period INTO l_start_start, l_start_end;
         CLOSE c_start_period;

         IF l_start_start IS NULL THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_FUND_BAD_START_PERIOD');
            RETURN;
         ELSIF    p_start_date < l_start_start
               OR p_start_date > l_start_end THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_THRESHOLD_OUT_START_PERIOD');
            RETURN;
         END IF;
      END IF;

      -- check p_end_period_name
      IF p_end_period_name IS NOT NULL THEN
         OPEN c_end_period;
         FETCH c_end_period INTO l_end_start, l_end_end;
         CLOSE c_end_period;

         IF l_end_end IS NULL THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_FUND_BAD_END_PERIOD');
            RETURN;
         ELSIF    p_end_date < l_end_start
               OR p_end_date > l_end_end THEN
            x_return_status := fnd_api.g_ret_sts_error;
            ozf_utility_pvt.error_message('OZF_THRESHOLD_OUT_END_PERIOD');
            RETURN;
         END IF;
      END IF;



   END check_threshold_calendar;

   ---------------------------------------------------------------------



-- Hint: Primary key needs to be returned.
PROCEDURE Create_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_rec               IN   threshold_rec_type  := g_miss_threshold_rec,
    x_threshold_id                   OUT NOCOPY NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Thresholdb';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_THRESHOLD_ID                  NUMBER;
   l_dummy       NUMBER;
   l_threshold_calendar        VARCHAR2(30);
   l_return_status             VARCHAR2(30);

   CURSOR c_id IS
      SELECT OZF_THRESHOLDS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM OZF_THRESHOLDS_ALL_B
                    WHERE THRESHOLD_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Threshold_PVT;

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
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_threshold_rec.THRESHOLD_ID IS NULL OR p_threshold_rec.THRESHOLD_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_THRESHOLD_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_THRESHOLD_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

    -- default threshold calendar
    IF     (p_threshold_rec.threshold_calendar IS NULL
      OR p_threshold_rec.threshold_calendar = fnd_api.g_miss_char)
         AND (   p_threshold_rec.start_period_name IS NOT NULL
              OR p_threshold_rec.end_period_name IS NOT NULL) THEN
	      l_threshold_calendar := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
       END IF;

      ------------------- check calendar ----------------------
      IF    p_threshold_rec.threshold_calendar <> fnd_api.g_miss_char
         OR p_threshold_rec.start_period_name <> fnd_api.g_miss_char
         OR p_threshold_rec.end_period_name <> fnd_api.g_miss_char
         OR p_threshold_rec.start_date_active <> fnd_api.g_miss_date
         OR p_threshold_rec.end_date_active <> fnd_api.g_miss_date THEN
         check_threshold_calendar(
	    null
           ,l_threshold_calendar
           ,p_threshold_rec.start_period_name
           ,p_threshold_rec.end_period_name
           ,p_threshold_rec.start_date_active
           ,p_threshold_rec.end_date_active
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            --x_return_status := l_return_status;
	     RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;


      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF G_DEBUG THEN
             OZF_UTILITY_PVT.debug_message('Private API: Validate_Threshold ');
          END IF;

          -- Invoke validation procedures
          Validate_threshold(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_threshold_rec  =>  p_threshold_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler ' || l_threshold_id );
      END IF;

     OZF_FUNDTHRESHOLDS_ALL_B_PKG.Insert_Row(
          px_threshold_id  => l_threshold_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  =>NVL(fnd_global.user_id, -1),
          p_last_update_login  => NVL(fnd_global.conc_login_id, -1),
          p_creation_date  => SYSDATE,
          p_created_by  => NVL(fnd_global.user_id, -1),
          p_created_from  => p_threshold_rec.created_from,
          p_request_id  => fnd_global.conc_request_id,
          p_program_application_id  => fnd_global.prog_appl_id,
          p_program_id  => fnd_global.conc_program_id,
          p_program_update_date  => SYSDATE,
          p_threshold_calendar  =>l_threshold_calendar,
          p_start_period_name  => p_threshold_rec.start_period_name,
          p_end_period_name  => p_threshold_rec.end_period_name,
          p_start_date_active  => p_threshold_rec.start_date_active,
          p_end_date_active  => p_threshold_rec.end_date_active,
          p_owner  => NVL(p_threshold_rec.owner, NVL(fnd_global.user_id, -1)),
          p_enable_flag  => p_threshold_rec.enable_flag,
          p_attribute_category  => p_threshold_rec.attribute_category,
          p_attribute1  => p_threshold_rec.attribute1,
          p_attribute2  => p_threshold_rec.attribute2,
          p_attribute3  => p_threshold_rec.attribute3,
          p_attribute4  => p_threshold_rec.attribute4,
          p_attribute5  => p_threshold_rec.attribute5,
          p_attribute6  => p_threshold_rec.attribute6,
          p_attribute7  => p_threshold_rec.attribute7,
          p_attribute8  => p_threshold_rec.attribute8,
          p_attribute9  => p_threshold_rec.attribute9,
          p_attribute10  => p_threshold_rec.attribute10,
          p_attribute11  => p_threshold_rec.attribute11,
          p_attribute12  => p_threshold_rec.attribute12,
          p_attribute13  => p_threshold_rec.attribute13,
          p_attribute14  => p_threshold_rec.attribute14,
          p_attribute15  => p_threshold_rec.attribute15,
          p_org_id  => TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)),
          p_security_group_id  => p_threshold_rec.security_group_id,
          px_object_version_number  => l_object_version_number,
          p_name  => p_threshold_rec.name,
          p_description  => p_threshold_rec.description,
          p_language  => USERENV('LANG'),
          p_source_lang  => p_threshold_rec.source_lang,
          p_threshold_type  => p_threshold_rec.threshold_type
          );

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

      x_threshold_id := l_threshold_id;
      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end' || x_threshold_id);
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Threshold_PVT;
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
End Create_Threshold;


PROCEDURE Update_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_rec               IN    threshold_rec_type,
    x_object_version_number      OUT NOCOPY NUMBER
    )

 IS

CURSOR c_get_threshold(threshold_id NUMBER) IS
    SELECT *
    FROM  OZF_THRESHOLDS_ALL_B
    WHERE THRESHOLD_ID = threshold_id
    AND   object_version_number = p_threshold_rec.object_version_number;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Threshold';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER := p_threshold_rec.object_version_number ;
l_THRESHOLD_ID    NUMBER;
l_ref_threshold_rec  c_get_Threshold%ROWTYPE ;
l_tar_threshold_rec  OZF_Fundthreshold_PVT.threshold_rec_type := P_threshold_rec;
l_threshold_rec  OZF_Fundthreshold_PVT.threshold_rec_type;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Threshold_PVT;

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
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start' || p_threshold_rec.THRESHOLD_ID);
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select '|| p_threshold_rec.THRESHOLD_ID);
      END IF;


      OPEN c_get_Threshold( l_tar_threshold_rec.threshold_id);

      FETCH c_get_Threshold INTO l_ref_threshold_rec  ;

       If ( c_get_Threshold%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Threshold') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF G_DEBUG THEN
          OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Threshold;


      If (l_tar_threshold_rec.object_version_number is NULL or
          l_tar_threshold_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_threshold_rec.object_version_number <> l_ref_threshold_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Threshold') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      Complete_threshold_Rec(
         p_threshold_rec        => p_threshold_rec,
         x_complete_rec        => l_threshold_rec
      );

      -- default threshold_calendar
      IF     l_threshold_rec.start_period_name IS NULL
         AND l_threshold_rec.end_period_name IS NULL THEN
         l_threshold_rec.threshold_calendar := NULL;
      ELSE
         l_threshold_rec.threshold_calendar := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
      END IF;

      IF l_threshold_rec.language IS NULL THEN
         l_threshold_rec.language := USERENV('LANG');
      END IF;
      IF l_threshold_rec.source_lang IS NULL THEN
         l_threshold_rec.source_lang := USERENV('LANG');
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_threshold_Items(
                 p_threshold_rec        => l_threshold_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_threshold_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_threshold_rec           =>    l_threshold_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(OZF_THRESHOLDS_ALL_B_PKG.Update_Row)
      OZF_FUNDTHRESHOLDS_ALL_B_PKG.Update_Row(
          p_threshold_id  => l_threshold_rec.threshold_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => NVL(fnd_global.user_id, -1),
          p_last_update_login  => NVL(fnd_global.conc_login_id, -1),
          p_created_from  => l_threshold_rec.created_from,
          p_request_id  => fnd_global.conc_request_id,
          p_program_application_id  => fnd_global.prog_appl_id,
          p_program_id  => fnd_global.conc_program_id,
          p_program_update_date  => SYSDATE,
          p_threshold_calendar  =>p_threshold_rec.threshold_calendar,
          p_start_period_name  => l_threshold_rec.start_period_name,
          p_end_period_name  => l_threshold_rec.end_period_name,
          p_start_date_active  => l_threshold_rec.start_date_active,
          p_end_date_active  => l_threshold_rec.end_date_active,
          p_owner  => l_threshold_rec.owner,
          p_enable_flag  => l_threshold_rec.enable_flag,
          p_attribute_category  => l_threshold_rec.attribute_category,
          p_attribute1  => l_threshold_rec.attribute1,
          p_attribute2  => l_threshold_rec.attribute2,
          p_attribute3  => l_threshold_rec.attribute3,
          p_attribute4  => l_threshold_rec.attribute4,
          p_attribute5  => l_threshold_rec.attribute5,
          p_attribute6  => l_threshold_rec.attribute6,
          p_attribute7  => l_threshold_rec.attribute7,
          p_attribute8  => l_threshold_rec.attribute8,
          p_attribute9  => l_threshold_rec.attribute9,
          p_attribute10  => l_threshold_rec.attribute10,
          p_attribute11  => l_threshold_rec.attribute11,
          p_attribute12  => l_threshold_rec.attribute12,
          p_attribute13  => l_threshold_rec.attribute13,
          p_attribute14  => l_threshold_rec.attribute14,
          p_attribute15  => l_threshold_rec.attribute15,
          p_org_id  => l_threshold_rec.org_id,
          p_security_group_id  => l_threshold_rec.security_group_id,
          px_object_version_number  => l_object_version_number,
          p_name  => l_threshold_rec.name,
          p_description  => l_threshold_rec.description,
          p_language  => l_threshold_rec.language,
          p_source_lang  => l_threshold_rec.source_lang,
          p_threshold_type  => p_threshold_rec.threshold_type
          );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

      x_object_version_number := l_object_version_number;

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Threshold_PVT;
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
End Update_Threshold;


PROCEDURE Delete_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_threshold_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Threshold';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Threshold_PVT;

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
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(OZF_THRESHOLDS_ALL_B_PKG.Delete_Row)
      OZF_FUNDTHRESHOLDS_ALL_B_PKG.Delete_Row(
          p_THRESHOLD_ID  => p_THRESHOLD_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Threshold_PVT;
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
End Delete_Threshold;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_threshold_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Threshold';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_THRESHOLD_ID                  NUMBER;

CURSOR c_Threshold IS
   SELECT THRESHOLD_ID
   FROM OZF_THRESHOLDS_ALL_B
   WHERE THRESHOLD_ID = p_THRESHOLD_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
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

  IF G_DEBUG THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;
  OPEN c_Threshold;

  FETCH c_Threshold INTO l_THRESHOLD_ID;

  IF (c_Threshold%NOTFOUND) THEN
    CLOSE c_Threshold;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Threshold;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF G_DEBUG THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Threshold_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Threshold_PVT;
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
End Lock_Threshold;


PROCEDURE check_threshold_uk_items(
    p_threshold_rec               IN   threshold_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_THRESHOLDS_ALL_B',
         'THRESHOLD_ID = ''' || p_threshold_rec.THRESHOLD_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_THRESHOLDS_ALL_B',
         'THRESHOLD_ID = ''' || p_threshold_rec.THRESHOLD_ID ||
         ''' AND THRESHOLD_ID <> ' || p_threshold_rec.THRESHOLD_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_THRESHOLD_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_threshold_uk_items;

PROCEDURE check_threshold_req_items(
    p_threshold_rec               IN  threshold_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
/*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_threshold_rec.threshold_id = FND_API.g_miss_num OR p_threshold_rec.threshold_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_threshold_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.last_update_date = FND_API.g_miss_date OR p_threshold_rec.last_update_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_last_upd_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.last_updated_by = FND_API.g_miss_num OR p_threshold_rec.last_updated_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_last_upd_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.creation_date = FND_API.g_miss_date OR p_threshold_rec.creation_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.created_by = FND_API.g_miss_num OR p_threshold_rec.created_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.owner = FND_API.g_miss_num OR p_threshold_rec.owner IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_owner');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_threshold_rec.threshold_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_threshold_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.last_update_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_last_upd_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.last_updated_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_last_upd_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.creation_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.created_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rec.owner IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_NO_owner');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

     END IF;
    END IF;
*/
END check_threshold_req_items;

PROCEDURE check_threshold_FK_items(
    p_threshold_rec IN threshold_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_threshold_FK_items;

PROCEDURE check_threshold_Lookup_items(
    p_threshold_rec IN threshold_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_threshold_Lookup_items;

PROCEDURE Check_threshold_Items (
    P_threshold_rec     IN    threshold_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_threshold_uk_items(
      p_threshold_rec => p_threshold_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_threshold_req_items(
      p_threshold_rec => p_threshold_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_threshold_FK_items(
      p_threshold_rec => p_threshold_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_threshold_Lookup_items(
      p_threshold_rec => p_threshold_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_threshold_Items;


/*PROCEDURE Complete_threshold_Rec (
    P_threshold_rec     IN    threshold_rec_type,
     x_complete_rec        OUT NOCOPY   threshold_rec_type
    )
*/

PROCEDURE Complete_threshold_Rec (
   p_threshold_rec IN threshold_rec_type,
   x_complete_rec OUT NOCOPY threshold_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_thresholds_all_b
      WHERE threshold_id = p_threshold_rec.threshold_id;
   l_threshold_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_threshold_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_threshold_rec;
   CLOSE c_complete;

   -- threshold_id
   IF p_threshold_rec.threshold_id = FND_API.g_miss_num THEN
      x_complete_rec.threshold_id := NULL;
   END IF;
   IF p_threshold_rec.threshold_id IS NULL THEN
      x_complete_rec.threshold_id := l_threshold_rec.threshold_id;
   END IF;

   -- last_update_date
   IF p_threshold_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_threshold_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_threshold_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_threshold_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_threshold_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_threshold_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_threshold_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_threshold_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_threshold_rec.last_update_login;
   END IF;

   -- creation_date
   IF p_threshold_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_threshold_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_threshold_rec.creation_date;
   END IF;

   -- created_by
   IF p_threshold_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_threshold_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_threshold_rec.created_by;
   END IF;

   -- created_from
   IF p_threshold_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := NULL;
   END IF;
   IF p_threshold_rec.created_from IS NULL THEN
      x_complete_rec.created_from := l_threshold_rec.created_from;
   END IF;

   -- request_id
   IF p_threshold_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := NULL;
   END IF;
   IF p_threshold_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_threshold_rec.request_id;
   END IF;

   -- program_application_id
   IF p_threshold_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := NULL;
   END IF;
   IF p_threshold_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_threshold_rec.program_application_id;
   END IF;

   -- program_id
   IF p_threshold_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := NULL;
   END IF;
   IF p_threshold_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_threshold_rec.program_id;
   END IF;

   -- program_update_date
   IF p_threshold_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := NULL;
   END IF;
   IF p_threshold_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_threshold_rec.program_update_date;
   END IF;

   -- threshold_calendar
   IF p_threshold_rec.threshold_calendar = FND_API.g_miss_char THEN
      x_complete_rec.threshold_calendar := NULL;
   END IF;
   IF p_threshold_rec.threshold_calendar IS NULL THEN
      x_complete_rec.threshold_calendar := l_threshold_rec.threshold_calendar;
   END IF;

   -- start_period_name
   IF p_threshold_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := NULL;
   END IF;
   IF p_threshold_rec.start_period_name IS NULL THEN
      x_complete_rec.start_period_name := l_threshold_rec.start_period_name;
   END IF;

   -- end_period_name
   IF p_threshold_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := NULL;
   END IF;
   IF p_threshold_rec.end_period_name IS NULL THEN
      x_complete_rec.end_period_name := l_threshold_rec.end_period_name;
   END IF;

   -- start_date_active
   IF p_threshold_rec.start_date_active = FND_API.g_miss_date THEN
      x_complete_rec.start_date_active := NULL;
   END IF;
   IF p_threshold_rec.start_date_active IS NULL THEN
      x_complete_rec.start_date_active := l_threshold_rec.start_date_active;
   END IF;

   -- end_date_active
   IF p_threshold_rec.end_date_active = FND_API.g_miss_date THEN
      x_complete_rec.end_date_active := NULL;
   END IF;
   IF p_threshold_rec.end_date_active IS NULL THEN
      x_complete_rec.end_date_active := l_threshold_rec.end_date_active;
   END IF;

   -- owner
   IF p_threshold_rec.owner = FND_API.g_miss_num THEN
      x_complete_rec.owner := NULL;
   END IF;
   IF p_threshold_rec.owner IS NULL THEN
      x_complete_rec.owner := l_threshold_rec.owner;
   END IF;

   -- enable_flag
   IF p_threshold_rec.enable_flag = FND_API.g_miss_char THEN
      x_complete_rec.enable_flag := NULL;
   END IF;
   IF p_threshold_rec.enable_flag IS NULL THEN
      x_complete_rec.enable_flag := l_threshold_rec.enable_flag;
   END IF;

   -- attribute1
   IF p_threshold_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_threshold_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_threshold_rec.attribute1;
   END IF;

   -- attribute2
   IF p_threshold_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_threshold_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_threshold_rec.attribute2;
   END IF;

   -- attribute3
   IF p_threshold_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_threshold_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_threshold_rec.attribute3;
   END IF;

   -- attribute4
   IF p_threshold_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_threshold_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_threshold_rec.attribute4;
   END IF;

   -- attribute5
   IF p_threshold_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_threshold_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_threshold_rec.attribute5;
   END IF;

   -- attribute6
   IF p_threshold_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_threshold_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_threshold_rec.attribute6;
   END IF;

   -- attribute7
   IF p_threshold_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_threshold_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_threshold_rec.attribute7;
   END IF;

   -- attribute8
   IF p_threshold_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_threshold_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_threshold_rec.attribute8;
   END IF;

   -- attribute9
   IF p_threshold_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_threshold_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_threshold_rec.attribute9;
   END IF;

   -- attribute10
   IF p_threshold_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_threshold_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_threshold_rec.attribute10;
   END IF;

   -- attribute11
   IF p_threshold_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_threshold_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_threshold_rec.attribute11;
   END IF;

   -- attribute12
   IF p_threshold_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_threshold_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_threshold_rec.attribute12;
   END IF;

   -- attribute13
   IF p_threshold_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_threshold_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_threshold_rec.attribute13;
   END IF;

   -- attribute14
   IF p_threshold_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_threshold_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_threshold_rec.attribute14;
   END IF;

   -- attribute15
   IF p_threshold_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_threshold_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_threshold_rec.attribute15;
   END IF;

   -- org_id
   IF p_threshold_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := NULL;
   END IF;
   IF p_threshold_rec.org_id IS NULL THEN
      x_complete_rec.org_id := l_threshold_rec.org_id;
   END IF;

   -- security_group_id
   IF p_threshold_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := NULL;
   END IF;
   IF p_threshold_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_threshold_rec.security_group_id;
   END IF;

   -- object_version_number
   IF p_threshold_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_threshold_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_threshold_rec.object_version_number;
   END IF;

   -- threshold_type
   IF p_threshold_rec.threshold_type = FND_API.g_miss_char THEN
      x_complete_rec.threshold_type := NULL;
   END IF;
   IF p_threshold_rec.threshold_type IS NULL THEN
      x_complete_rec.threshold_type := l_threshold_rec.threshold_type;
   END IF;

   IF p_threshold_rec.language = FND_API.g_miss_char THEN
      x_complete_rec.language := NULL;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_threshold_Rec;
PROCEDURE Validate_threshold(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_threshold_rec               IN   threshold_rec_type,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Threshold';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_threshold_rec  OZF_Fundthreshold_PVT.threshold_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Threshold_;

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
              Check_threshold_Items(
                 p_threshold_rec        => p_threshold_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_create,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_threshold_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_threshold_rec           =>    l_threshold_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Threshold_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Threshold_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Threshold_;
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
End Validate_Threshold;


PROCEDURE Validate_threshold_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_threshold_rec               IN    threshold_rec_type
    )
IS
  l_return_status  VARCHAR2(30);
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      ------------------- check calendar ----------------------
      IF    p_threshold_rec.threshold_calendar <> fnd_api.g_miss_char
         OR p_threshold_rec.start_period_name <> fnd_api.g_miss_char
         OR p_threshold_rec.end_period_name <> fnd_api.g_miss_char
         OR p_threshold_rec.start_date_active <> fnd_api.g_miss_date
         OR p_threshold_rec.end_date_active <> fnd_api.g_miss_date THEN
         check_threshold_calendar(
            p_threshold_rec.threshold_id
           ,p_threshold_rec.threshold_calendar
           ,p_threshold_rec.start_period_name
           ,p_threshold_rec.end_period_name
           ,p_threshold_rec.start_date_active
           ,p_threshold_rec.end_date_active
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;
      END IF;


      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_threshold_Rec;

END OZF_Fundthreshold_PVT;

/
