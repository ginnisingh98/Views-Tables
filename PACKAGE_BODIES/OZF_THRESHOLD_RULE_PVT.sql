--------------------------------------------------------
--  DDL for Package Body OZF_THRESHOLD_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_THRESHOLD_RULE_PVT" as
/* $Header: ozfvtrub.pls 120.2 2005/12/19 10:10:36 mkothari ship $ */
-- ===============================================================

-- Start of Comments
-- Package name
--          OZF_Threshold_Rule_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Threshold_Rule_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvtrub.pls';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

   -----------------------------------------------------------------------
   -- PROCEDURE
   --    calculate_converted_day
   --
   -- HISTORY
   -----------------------------------------------------------------------


PROCEDURE calculate_converted_day(
             p_repeat_frequency    IN    NUMBER
            ,p_frequency_period    IN    VARCHAR2
        ,p_start_date          IN    DATE
        ,p_end_date            IN    DATE
        ,x_converted_days      OUT NOCOPY   NUMBER
        ,x_return_status       OUT NOCOPY   VARCHAR2)
   IS

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

   IF p_repeat_frequency IS NOT NULL
      AND p_frequency_period IS NOT NULL THEN

      IF p_frequency_period = 'WEEKLY' THEN
         x_converted_days := 7 * p_repeat_frequency;
      ELSIF p_frequency_period = 'MONTHLY' THEN
         x_converted_days := 30 * p_repeat_frequency;
      ELSIF p_frequency_period = 'QUARTERLY' THEN
         x_converted_days := 90 * p_repeat_frequency;
      ELSIF p_frequency_period = 'YEARLY' THEN
         x_converted_days := 365 * p_repeat_frequency;
      ELSE
	 x_converted_days := p_repeat_frequency;
      END IF;

   END IF;

   END calculate_converted_day;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    check_threshold_calendar
   --
   -- HISTORY

   -----------------------------------------------------------------------
   PROCEDURE check_threshold_calendar(
      p_threshold_calendar       IN       VARCHAR2
     ,p_start_period_name   IN       VARCHAR2
     ,p_end_period_name     IN       VARCHAR2
     ,p_start_date          IN       DATE
     ,p_end_date            IN       DATE
     ,p_threshold_id        IN       NUMBER
     ,x_return_status       OUT NOCOPY      VARCHAR2)
   IS
      l_start_start    DATE;
      l_start_end      DATE;
      l_end_start      DATE;
      l_end_end        DATE;
      l_threshold_start_date   DATE;
      l_threshold_end_date   DATE;
      l_local          NUMBER;


      CURSOR c_threshold_date
      IS
         SELECT   start_date_active, end_date_active
         FROM     ozf_thresholds_vl
         WHERE  threshold_id = p_threshold_id;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      -- compare the start date and the end date
      IF p_start_date > p_end_date THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ozf_utility_pvt.error_message('OZF_STARTDATE_OUT_ENDDATE');
	 RETURN;
      END IF;

      --compare the start date and the end date of both threshold and threshold_rule
      IF p_threshold_id IS NOT NULL THEN
         OPEN c_threshold_date;
         FETCH c_threshold_date INTO l_threshold_start_date,l_threshold_end_date;
         CLOSE c_threshold_date;

         IF p_start_date < l_threshold_start_date
           OR p_end_date > l_threshold_end_date   THEN
               x_return_status := fnd_api.g_ret_sts_error;
               ozf_utility_pvt.error_message('OZF_TRSH_RULE_OUT_THRESHOLD');
           RETURN;
         END IF;

      END IF;


   END check_threshold_calendar;

   ---------------------------------------------------------------------


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_rec               IN   threshold_rule_rec_type  := g_miss_threshold_rule_rec,
    x_threshold_rule_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Threshold_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_THRESHOLD_RULE_ID                  NUMBER;
   l_dummy       NUMBER;
   l_threshold_calendar        VARCHAR2(30);
   l_converted_days            NUMBER;
   l_return_status             VARCHAR2(30);

   CURSOR c_id IS
      SELECT OZF_THRESHOLD_RULES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1 FROM dual
      WHERE EXISTS (SELECT 1 FROM OZF_THRESHOLD_RULES_ALL
                    WHERE THRESHOLD_RULE_ID = l_id);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Threshold_Rule_PVT;

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

   IF p_threshold_rule_rec.THRESHOLD_RULE_ID IS NULL OR p_threshold_rule_rec.THRESHOLD_RULE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_THRESHOLD_RULE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_THRESHOLD_RULE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- default threshold calendar
      IF     p_threshold_rule_rec.threshold_calendar IS NULL
         AND (   p_threshold_rule_rec.start_period_name IS NOT NULL
              OR p_threshold_rule_rec.end_period_name IS NOT NULL) THEN
         l_threshold_calendar := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
      END IF;

      ------------------- check calendar ----------------------
      IF    p_threshold_rule_rec.threshold_calendar <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.start_period_name <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.end_period_name <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.start_date <> fnd_api.g_miss_date
         OR p_threshold_rule_rec.end_date <> fnd_api.g_miss_date THEN
         check_threshold_calendar(
            l_threshold_calendar
           ,p_threshold_rule_rec.start_period_name
           ,p_threshold_rule_rec.end_period_name
           ,p_threshold_rule_rec.start_date
           ,p_threshold_rule_rec.end_date
       ,p_threshold_rule_rec.threshold_id
           ,l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
	     RAISE FND_API.G_EXC_ERROR;

	    --x_return_status := l_return_status;
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
             OZF_UTILITY_PVT.debug_message('Private API: Validate_Threshold_Rule');
          END IF;

          -- Invoke validation procedures
          Validate_threshold_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_threshold_rule_rec  =>  p_threshold_rule_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

--    Calculate converted days.
      IF p_threshold_rule_rec.repeat_frequency IS NOT NULL
         AND  p_threshold_rule_rec.frequency_period IS NOT NULL THEN
     Calculate_converted_day(
            p_threshold_rule_rec.repeat_frequency
            ,p_threshold_rule_rec.frequency_period
        ,p_threshold_rule_rec.start_date
        ,p_threshold_rule_rec.end_date
        ,l_converted_days
        ,l_return_status);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;

      END IF;

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(OZF_THRESHOLD_RULES_PKG.Insert_Row)
      OZF_THRESHOLD_RULES_PKG.Insert_Row(
          px_threshold_rule_id  => l_threshold_rule_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => NVL(fnd_global.user_id, -1),
          p_last_update_login  => NVL(fnd_global.conc_login_id, -1),
          p_creation_date  => SYSDATE,
          p_created_by  => NVL(fnd_global.user_id, -1),
          p_created_from  => NULL,
          p_request_id  => fnd_global.conc_request_id,
          p_program_application_id  => fnd_global.prog_appl_id,
          p_program_id  => fnd_global.conc_program_id,
          p_program_update_date  => SYSDATE,
          p_period_type  => p_threshold_rule_rec.period_type,
          p_enabled_flag  => p_threshold_rule_rec.enabled_flag,
          p_threshold_calendar  =>l_threshold_calendar,
          p_start_period_name  => p_threshold_rule_rec.start_period_name,
          p_end_period_name  => p_threshold_rule_rec.end_period_name,
          p_threshold_id  => p_threshold_rule_rec.threshold_id,
          p_start_date  => p_threshold_rule_rec.start_date,
          p_end_date  => p_threshold_rule_rec.end_date,
          p_value_limit  => p_threshold_rule_rec.value_limit,
          p_operator_code  => p_threshold_rule_rec.operator_code,
          p_percent_amount  => p_threshold_rule_rec.percent_amount,
          p_base_line  => p_threshold_rule_rec.base_line,
          p_error_mode  => p_threshold_rule_rec.error_mode,
          p_repeat_frequency  => p_threshold_rule_rec.repeat_frequency,
          p_frequency_period  => p_threshold_rule_rec.frequency_period,
          p_attribute_category  => p_threshold_rule_rec.attribute_category,
          p_attribute1  => p_threshold_rule_rec.attribute1,
          p_attribute2  => p_threshold_rule_rec.attribute2,
          p_attribute3  => p_threshold_rule_rec.attribute3,
          p_attribute4  => p_threshold_rule_rec.attribute4,
          p_attribute5  => p_threshold_rule_rec.attribute5,
          p_attribute6  => p_threshold_rule_rec.attribute6,
          p_attribute7  => p_threshold_rule_rec.attribute7,
          p_attribute8  => p_threshold_rule_rec.attribute8,
          p_attribute9  => p_threshold_rule_rec.attribute9,
          p_attribute10  => p_threshold_rule_rec.attribute10,
          p_attribute11  => p_threshold_rule_rec.attribute11,
          p_attribute12  => p_threshold_rule_rec.attribute12,
          p_attribute13  => p_threshold_rule_rec.attribute13,
          p_attribute14  => p_threshold_rule_rec.attribute14,
          p_attribute15  => p_threshold_rule_rec.attribute15,
          p_org_id  => TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)),
          p_security_group_id  => p_threshold_rule_rec.security_group_id,
          p_converted_days  => l_converted_days,
          px_object_version_number  => l_object_version_number,
          p_comparison_type  => p_threshold_rule_rec.comparison_type,
          p_alert_type  => p_threshold_rule_rec.alert_type
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

      x_threshold_rule_id := l_threshold_rule_id;

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
     ROLLBACK TO CREATE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Threshold_Rule_PVT;
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
End Create_Threshold_Rule;


PROCEDURE Update_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_rec               IN    threshold_rule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_threshold_rule(threshold_rule_id NUMBER) IS
    SELECT *
    FROM  OZF_THRESHOLD_RULES_ALL
    WHERE THRESHOLD_RULE_ID = threshold_rule_id
    AND OBJECT_VERSION_NUMBER =p_threshold_rule_rec.object_version_number ;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Threshold_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER := p_threshold_rule_rec.object_version_number;
l_THRESHOLD_RULE_ID    NUMBER ;
l_ref_threshold_rule_rec  c_get_Threshold_Rule%ROWTYPE ;
l_tar_threshold_rule_rec  OZF_Threshold_Rule_PVT.threshold_rule_rec_type := P_threshold_rule_rec;
l_threshold_rule_rec  OZF_Threshold_Rule_PVT.threshold_rule_rec_type;
l_rowid  ROWID;
l_converted_days    NUMBER;
l_return_status     VARCHAR2(30);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Threshold_Rule_PVT;

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

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select ' || l_tar_threshold_rule_rec.threshold_rule_id);
      END IF;


      OPEN c_get_Threshold_Rule( l_tar_threshold_rule_rec.threshold_rule_id);

      FETCH c_get_Threshold_Rule INTO l_ref_threshold_rule_rec  ;

       If ( c_get_Threshold_Rule%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Threshold_Rule') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF G_DEBUG THEN
          OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Threshold_Rule;


      If (l_tar_threshold_rule_rec.object_version_number is NULL or
          l_tar_threshold_rule_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_threshold_rule_rec.object_version_number <> l_ref_threshold_rule_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Threshold_Rule') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      Complete_threshold_rule_Rec(
         p_threshold_rule_rec        => p_threshold_rule_rec,
         x_complete_rec        => l_threshold_rule_rec
      );


--    Calculate converted days.
      IF l_threshold_rule_rec.repeat_frequency IS NOT NULL
         AND  l_threshold_rule_rec.frequency_period IS NOT NULL THEN
     Calculate_converted_day(
            l_threshold_rule_rec.repeat_frequency
            ,l_threshold_rule_rec.frequency_period
        ,l_threshold_rule_rec.start_date
        ,l_threshold_rule_rec.end_date
        ,l_converted_days
        ,l_return_status);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_return_status := l_return_status;
         END IF;

      END IF;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_threshold_rule_Items(
                 p_threshold_rule_rec        => l_threshold_rule_rec,
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
         Validate_threshold_rule_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_threshold_rule_rec           =>    l_threshold_rule_rec);

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

      -- Invoke table handler(OZF_THRESHOLD_RULES_PKG.Update_Row)
      OZF_THRESHOLD_RULES_PKG.Update_Row(
          p_threshold_rule_id  => l_threshold_rule_rec.threshold_rule_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => NVL(fnd_global.user_id, -1),
          p_last_update_login  => NVL(fnd_global.conc_login_id, -1),
          p_created_from  => l_threshold_rule_rec.created_from,
          p_request_id  => fnd_global.conc_request_id,
          p_program_application_id  => fnd_global.prog_appl_id,
          p_program_id  => fnd_global.conc_program_id,
          p_program_update_date  => SYSDATE,
          p_period_type  => l_threshold_rule_rec.period_type,
          p_enabled_flag  => l_threshold_rule_rec.enabled_flag,
          p_start_period_name  => l_threshold_rule_rec.start_period_name,
          p_threshold_calendar  =>l_threshold_rule_rec.threshold_calendar,
          p_end_period_name  => l_threshold_rule_rec.end_period_name,
          p_threshold_id  => l_threshold_rule_rec.threshold_id,
          p_start_date  => l_threshold_rule_rec.start_date,
          p_end_date  => l_threshold_rule_rec.end_date,
          p_value_limit  => l_threshold_rule_rec.value_limit,
          p_operator_code  => l_threshold_rule_rec.operator_code,
          p_percent_amount  => l_threshold_rule_rec.percent_amount,
          p_base_line  => l_threshold_rule_rec.base_line,
          p_error_mode  => l_threshold_rule_rec.error_mode,
          p_repeat_frequency  => l_threshold_rule_rec.repeat_frequency,
          p_frequency_period  => l_threshold_rule_rec.frequency_period,
          p_attribute_category  => l_threshold_rule_rec.attribute_category,
          p_attribute1  => l_threshold_rule_rec.attribute1,
          p_attribute2  => l_threshold_rule_rec.attribute2,
          p_attribute3  => l_threshold_rule_rec.attribute3,
          p_attribute4  => l_threshold_rule_rec.attribute4,
          p_attribute5  => l_threshold_rule_rec.attribute5,
          p_attribute6  => l_threshold_rule_rec.attribute6,
          p_attribute7  => l_threshold_rule_rec.attribute7,
          p_attribute8  => l_threshold_rule_rec.attribute8,
          p_attribute9  => l_threshold_rule_rec.attribute9,
          p_attribute10  => l_threshold_rule_rec.attribute10,
          p_attribute11  => l_threshold_rule_rec.attribute11,
          p_attribute12  => l_threshold_rule_rec.attribute12,
          p_attribute13  => l_threshold_rule_rec.attribute13,
          p_attribute14  => l_threshold_rule_rec.attribute14,
          p_attribute15  => l_threshold_rule_rec.attribute15,
          p_org_id  => l_threshold_rule_rec.org_id,
          p_security_group_id  => l_threshold_rule_rec.security_group_id,
          p_converted_days  => l_converted_days,
          px_object_version_number  => l_object_version_number,
          p_comparison_type  => l_threshold_rule_rec.comparison_type,
          p_alert_type  => l_threshold_rule_rec.alert_type
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
     ROLLBACK TO UPDATE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Threshold_Rule_PVT;
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
End Update_Threshold_Rule;


PROCEDURE Delete_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_threshold_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Threshold_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Threshold_Rule_PVT;

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

      -- Invoke table handler(OZF_THRESHOLD_RULES_PKG.Delete_Row)
      OZF_THRESHOLD_RULES_PKG.Delete_Row(
          p_THRESHOLD_RULE_ID  => p_THRESHOLD_RULE_ID);
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
     ROLLBACK TO DELETE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Threshold_Rule_PVT;
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
End Delete_Threshold_Rule;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Threshold_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_threshold_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Threshold_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_THRESHOLD_RULE_ID                  NUMBER;

CURSOR c_Threshold_Rule IS
   SELECT THRESHOLD_RULE_ID
   FROM OZF_THRESHOLD_RULES_ALL
   WHERE THRESHOLD_RULE_ID = p_THRESHOLD_RULE_ID
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
  OPEN c_Threshold_Rule;

  FETCH c_Threshold_Rule INTO l_THRESHOLD_RULE_ID;

  IF (c_Threshold_Rule%NOTFOUND) THEN
    CLOSE c_Threshold_Rule;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Threshold_Rule;

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
     ROLLBACK TO LOCK_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Threshold_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Threshold_Rule_PVT;
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
End Lock_Threshold_Rule;


PROCEDURE check_threshold_rule_uk_items(
    p_threshold_rule_rec               IN   threshold_rule_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_THRESHOLD_RULES_ALL',
         'THRESHOLD_RULE_ID = ''' || p_threshold_rule_rec.THRESHOLD_RULE_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_THRESHOLD_RULES_ALL',
         'THRESHOLD_RULE_ID = ''' || p_threshold_rule_rec.THRESHOLD_RULE_ID ||
         ''' AND THRESHOLD_RULE_ID <> ' || p_threshold_rule_rec.THRESHOLD_RULE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_THRESHD_RULE_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_threshold_rule_uk_items;

PROCEDURE check_threshold_rule_req_items(
    p_threshold_rule_rec               IN  threshold_rule_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
CURSOR c_threshold_type (p_thres_id NUMBER) IS
SELECT threshold_type
FROM ozf_thresholds_all_b
WHERE threshold_id = p_thres_id;

l_threshold_type VARCHAR2(30);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_threshold_rule_rec.start_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'Start Date');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_threshold_rule_rec.end_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'End Date');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_threshold_rule_rec.value_limit IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'Value Limit');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_threshold_rule_rec.operator_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'Operator');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_threshold_rule_rec.threshold_id IS NOT NULL THEN
      OPEN c_threshold_type(p_threshold_rule_rec.threshold_id);
      FETCH c_threshold_type INTO l_threshold_type;
      CLOSE c_threshold_type;

      IF l_threshold_type IS NOT NULL THEN
         IF l_threshold_type = 'QUOTA' THEN
           IF p_threshold_rule_rec.comparison_type IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Comparision Type');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.percent_amount IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Comparision Value');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.comparison_type = 'PERCENT' THEN
               IF p_threshold_rule_rec.base_line IS NULL THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                     FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                     FND_MESSAGE.set_token('COLUMN', 'OfBaseline');
                     FND_MSG_PUB.add;
                  END IF;
                  x_return_status := FND_API.g_ret_sts_error;
                  RETURN;
               END IF;
           END IF;
           IF p_threshold_rule_rec.repeat_frequency IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Frequency');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.frequency_period IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Period Type');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.alert_type IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Alert Type');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
         ELSIF l_threshold_type = 'BUDGET' THEN
           IF p_threshold_rule_rec.percent_amount IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Percent');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.base_line IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'OfBaseline');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.repeat_frequency IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Frequency');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
           IF p_threshold_rule_rec.frequency_period IS NULL THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_FUND_MISSING_COLUMN');
                 FND_MESSAGE.set_token('COLUMN', 'Period Type');
                 FND_MSG_PUB.add;
              END IF;
              x_return_status := FND_API.g_ret_sts_error;
              RETURN;
           END IF;
         END IF;
      END IF;
   END IF;

/*
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_threshold_rule_rec.threshold_rule_id = FND_API.g_miss_num OR p_threshold_rule_rec.threshold_rule_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_threshold_rule_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.last_update_date = FND_API.g_miss_date OR p_threshold_rule_rec.last_update_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.last_updated_by = FND_API.g_miss_num OR p_threshold_rule_rec.last_updated_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.creation_date = FND_API.g_miss_date OR p_threshold_rule_rec.creation_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.created_by = FND_API.g_miss_num OR p_threshold_rule_rec.created_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.threshold_id = FND_API.g_miss_num OR p_threshold_rule_rec.threshold_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_threshold_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_threshold_rule_rec.threshold_rule_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_threshold_rule_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.last_update_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.last_updated_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.creation_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.created_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_threshold_rule_rec.threshold_id IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_threshold_rule_NO_threshold_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
END check_threshold_rule_req_items;

PROCEDURE check_threshold_rule_FK_items(
    p_threshold_rule_rec IN threshold_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_threshold_rule_FK_items;

PROCEDURE check_Lookup_items(
    p_threshold_rule_rec IN threshold_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Lookup_items;

PROCEDURE Check_threshold_rule_Items (
    P_threshold_rule_rec     IN    threshold_rule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_threshold_rule_uk_items(
      p_threshold_rule_rec => p_threshold_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_threshold_rule_req_items(
      p_threshold_rule_rec => p_threshold_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_threshold_rule_FK_items(
      p_threshold_rule_rec => p_threshold_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_Lookup_items(
      p_threshold_rule_rec => p_threshold_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_threshold_rule_Items;

PROCEDURE Complete_threshold_rule_Rec (
   p_threshold_rule_rec IN threshold_rule_rec_type,
   x_complete_rec OUT NOCOPY threshold_rule_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_threshold_rules_all
      WHERE threshold_rule_id = p_threshold_rule_rec.threshold_rule_id;
   l_threshold_rule_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_threshold_rule_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_threshold_rule_rec;
   CLOSE c_complete;

   -- threshold_rule_id
   IF p_threshold_rule_rec.threshold_rule_id = FND_API.g_miss_num THEN
      x_complete_rec.threshold_rule_id := NULL;
   END IF;
   IF p_threshold_rule_rec.threshold_rule_id IS NULL THEN
      x_complete_rec.threshold_rule_id := l_threshold_rule_rec.threshold_rule_id;
   END IF;

   -- last_update_date
   IF p_threshold_rule_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_threshold_rule_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_threshold_rule_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_threshold_rule_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_threshold_rule_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_threshold_rule_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_threshold_rule_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_threshold_rule_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_threshold_rule_rec.last_update_login;
   END IF;

   -- creation_date
   IF p_threshold_rule_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_threshold_rule_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_threshold_rule_rec.creation_date;
   END IF;

   -- created_by
   IF p_threshold_rule_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_threshold_rule_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_threshold_rule_rec.created_by;
   END IF;

   -- created_from
   IF p_threshold_rule_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := NULL;
   END IF;
   IF p_threshold_rule_rec.created_from IS NULL THEN
      x_complete_rec.created_from := l_threshold_rule_rec.created_from;
   END IF;

   -- request_id
   IF p_threshold_rule_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := NULL;
   END IF;
   IF p_threshold_rule_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_threshold_rule_rec.request_id;
   END IF;

   -- program_application_id
   IF p_threshold_rule_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := NULL;
   END IF;
   IF p_threshold_rule_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_threshold_rule_rec.program_application_id;
   END IF;

   -- program_id
   IF p_threshold_rule_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := NULL;
   END IF;
   IF p_threshold_rule_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_threshold_rule_rec.program_id;
   END IF;

   -- program_update_date
   IF p_threshold_rule_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := NULL;
   END IF;
   IF p_threshold_rule_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_threshold_rule_rec.program_update_date;
   END IF;

   -- period_type
   IF p_threshold_rule_rec.period_type = FND_API.g_miss_char THEN
      x_complete_rec.period_type := NULL;
   END IF;
   IF p_threshold_rule_rec.period_type IS NULL THEN
      x_complete_rec.period_type := l_threshold_rule_rec.period_type;
   END IF;

   -- enabled_flag
   IF p_threshold_rule_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := NULL;
   END IF;
   IF p_threshold_rule_rec.enabled_flag IS NULL THEN
      x_complete_rec.enabled_flag := l_threshold_rule_rec.enabled_flag;
   END IF;

   -- threshold_calendar
   IF p_threshold_rule_rec.threshold_calendar = FND_API.g_miss_char THEN
      x_complete_rec.threshold_calendar := NULL;
   END IF;
   IF p_threshold_rule_rec.threshold_calendar IS NULL THEN
      x_complete_rec.threshold_calendar := l_threshold_rule_rec.threshold_calendar;
   END IF;

   -- start_period_name
   IF p_threshold_rule_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := NULL;
   END IF;
   IF p_threshold_rule_rec.start_period_name IS NULL THEN
      x_complete_rec.start_period_name := l_threshold_rule_rec.start_period_name;
   END IF;

   -- end_period_name
   IF p_threshold_rule_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := NULL;
   END IF;
   IF p_threshold_rule_rec.end_period_name IS NULL THEN
      x_complete_rec.end_period_name := l_threshold_rule_rec.end_period_name;
   END IF;

   -- threshold_id
   IF p_threshold_rule_rec.threshold_id = FND_API.g_miss_num THEN
      x_complete_rec.threshold_id := NULL;
   END IF;
   IF p_threshold_rule_rec.threshold_id IS NULL THEN
      x_complete_rec.threshold_id := l_threshold_rule_rec.threshold_id;
   END IF;

   -- start_date
   IF p_threshold_rule_rec.start_date = FND_API.g_miss_date THEN
      x_complete_rec.start_date := NULL;
   END IF;
   IF p_threshold_rule_rec.start_date IS NULL THEN
      x_complete_rec.start_date := l_threshold_rule_rec.start_date;
   END IF;

   -- end_date
   IF p_threshold_rule_rec.end_date = FND_API.g_miss_date THEN
      x_complete_rec.end_date := NULL;
   END IF;
   IF p_threshold_rule_rec.end_date IS NULL THEN
      x_complete_rec.end_date := l_threshold_rule_rec.end_date;
   END IF;

   -- value_limit
   IF p_threshold_rule_rec.value_limit = FND_API.g_miss_char THEN
      x_complete_rec.value_limit := NULL;
   END IF;
   IF p_threshold_rule_rec.value_limit IS NULL THEN
      x_complete_rec.value_limit := l_threshold_rule_rec.value_limit;
   END IF;

   -- operator_code
   IF p_threshold_rule_rec.operator_code = FND_API.g_miss_char THEN
      x_complete_rec.operator_code := NULL;
   END IF;
   IF p_threshold_rule_rec.operator_code IS NULL THEN
      x_complete_rec.operator_code := l_threshold_rule_rec.operator_code;
   END IF;

   -- percent_amount
   IF p_threshold_rule_rec.percent_amount = FND_API.g_miss_num THEN
      x_complete_rec.percent_amount := NULL;
   END IF;
   IF p_threshold_rule_rec.percent_amount IS NULL THEN
      x_complete_rec.percent_amount := l_threshold_rule_rec.percent_amount;
   END IF;

   -- base_line
   IF p_threshold_rule_rec.base_line = FND_API.g_miss_char THEN
      x_complete_rec.base_line := NULL;
   END IF;
   IF p_threshold_rule_rec.base_line IS NULL THEN
      x_complete_rec.base_line := l_threshold_rule_rec.base_line;
   END IF;

   -- error_mode
   IF p_threshold_rule_rec.error_mode = FND_API.g_miss_char THEN
      x_complete_rec.error_mode := NULL;
   END IF;
   IF p_threshold_rule_rec.error_mode IS NULL THEN
      x_complete_rec.error_mode := l_threshold_rule_rec.error_mode;
   END IF;

   -- repeat_frequency
   IF p_threshold_rule_rec.repeat_frequency = FND_API.g_miss_num THEN
      x_complete_rec.repeat_frequency := NULL;
   END IF;
   IF p_threshold_rule_rec.repeat_frequency IS NULL THEN
      x_complete_rec.repeat_frequency := l_threshold_rule_rec.repeat_frequency;
   END IF;

   -- frequency_period
   IF p_threshold_rule_rec.frequency_period = FND_API.g_miss_char THEN
      x_complete_rec.frequency_period := NULL;
   END IF;
   IF p_threshold_rule_rec.frequency_period IS NULL THEN
      x_complete_rec.frequency_period := l_threshold_rule_rec.frequency_period;
   END IF;

   -- attribute_category
   IF p_threshold_rule_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_threshold_rule_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_threshold_rule_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_threshold_rule_rec.attribute1;
   END IF;

   -- attribute2
   IF p_threshold_rule_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_threshold_rule_rec.attribute2;
   END IF;

   -- attribute3
   IF p_threshold_rule_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_threshold_rule_rec.attribute3;
   END IF;

   -- attribute4
   IF p_threshold_rule_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_threshold_rule_rec.attribute4;
   END IF;

   -- attribute5
   IF p_threshold_rule_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_threshold_rule_rec.attribute5;
   END IF;

   -- attribute6
   IF p_threshold_rule_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_threshold_rule_rec.attribute6;
   END IF;

   -- attribute7
   IF p_threshold_rule_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_threshold_rule_rec.attribute7;
   END IF;

   -- attribute8
   IF p_threshold_rule_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_threshold_rule_rec.attribute8;
   END IF;

   -- attribute9
   IF p_threshold_rule_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_threshold_rule_rec.attribute9;
   END IF;

   -- attribute10
   IF p_threshold_rule_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_threshold_rule_rec.attribute10;
   END IF;

   -- attribute11
   IF p_threshold_rule_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_threshold_rule_rec.attribute11;
   END IF;

   -- attribute12
   IF p_threshold_rule_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_threshold_rule_rec.attribute12;
   END IF;

   -- attribute13
   IF p_threshold_rule_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_threshold_rule_rec.attribute13;
   END IF;

   -- attribute14
   IF p_threshold_rule_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_threshold_rule_rec.attribute14;
   END IF;

   -- attribute15
   IF p_threshold_rule_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := NULL;
   END IF;
   IF p_threshold_rule_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_threshold_rule_rec.attribute15;
   END IF;

   -- org_id
   IF p_threshold_rule_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := NULL;
   END IF;
   IF p_threshold_rule_rec.org_id IS NULL THEN
      x_complete_rec.org_id := l_threshold_rule_rec.org_id;
   END IF;

   -- security_group_id
   IF p_threshold_rule_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := NULL;
   END IF;
   IF p_threshold_rule_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_threshold_rule_rec.security_group_id;
   END IF;

   -- converted_days
   IF p_threshold_rule_rec.converted_days = FND_API.g_miss_num THEN
      x_complete_rec.converted_days := NULL;
   END IF;
   IF p_threshold_rule_rec.converted_days IS NULL THEN
      x_complete_rec.converted_days := l_threshold_rule_rec.converted_days;
   END IF;

   -- object_version_number
   IF p_threshold_rule_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_threshold_rule_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_threshold_rule_rec.object_version_number;
   END IF;

   -- comparison_type
   IF p_threshold_rule_rec.comparison_type = FND_API.g_miss_char THEN
      x_complete_rec.comparison_type := NULL;
   END IF;
   IF p_threshold_rule_rec.comparison_type IS NULL THEN
      x_complete_rec.comparison_type := l_threshold_rule_rec.comparison_type;
   END IF;

   -- alert_type
   IF p_threshold_rule_rec.alert_type = FND_API.g_miss_char THEN
      x_complete_rec.alert_type := NULL;
   END IF;
   IF p_threshold_rule_rec.alert_type IS NULL THEN
      x_complete_rec.alert_type := l_threshold_rule_rec.alert_type;
   END IF;

   --This condition is needed for QUOTA type threshold rules.
   IF p_threshold_rule_rec.comparison_type = 'CONSTANT' THEN
      x_complete_rec.base_line := NULL;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_threshold_rule_Rec;

PROCEDURE Validate_threshold_rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_threshold_rule_rec               IN   threshold_rule_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Threshold_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_threshold_rule_rec  OZF_Threshold_Rule_PVT.threshold_rule_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Threshold_Rule_;

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
              Check_threshold_rule_Items(
                 p_threshold_rule_rec        => p_threshold_rule_rec,
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
         Validate_threshold_rule_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_threshold_rule_rec           =>    l_threshold_rule_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
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
     ROLLBACK TO VALIDATE_Threshold_Rule_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Threshold_Rule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Threshold_Rule_;
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
End Validate_Threshold_Rule;


PROCEDURE Validate_threshold_rule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_threshold_rule_rec               IN    threshold_rule_rec_type
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
      IF    p_threshold_rule_rec.threshold_calendar <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.start_period_name <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.end_period_name <> fnd_api.g_miss_char
         OR p_threshold_rule_rec.start_date <> fnd_api.g_miss_date
         OR p_threshold_rule_rec.end_date <> fnd_api.g_miss_date THEN
         check_threshold_calendar(
            p_threshold_rule_rec.threshold_calendar
           ,p_threshold_rule_rec.start_period_name
           ,p_threshold_rule_rec.end_period_name
           ,p_threshold_rule_rec.start_date
           ,p_threshold_rule_rec.end_date
       ,p_threshold_rule_rec.threshold_id
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
END Validate_threshold_rule_Rec;

END OZF_Threshold_Rule_PVT;

/
