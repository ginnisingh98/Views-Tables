--------------------------------------------------------
--  DDL for Package Body AMW_RISK_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_RISK_TYPE_PVT" AS
/* $Header: amwvmrtb.pls 120.0 2005/05/31 21:25:10 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_RISK_TYPE_PVT
-- End of Comments
-- ===============================================================
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_RISK_TYPE_PVT';
   g_file_name   CONSTANT VARCHAR2 (12) := 'amwvrtpb.pls';
   g_user_id              NUMBER        := fnd_global.user_id;
   g_login_id             NUMBER        := fnd_global.conc_login_id;
   --------------------- BEGIN: Declaring internal Procedures ----------------------
   --   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Insert_Delete_Risk_Type
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_riskrev_id              IN   NUMBER     Optional  Default = null
--       p_risk_type_code          IN   VARCHAR2   Required
--       p_select_flag             IN   VARCHAR2   Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--
   PROCEDURE insert_delete_risk_type (
      p_risk_rev_id               IN              NUMBER := NULL,
	  p_risk_type_code            IN              VARCHAR2 := NULL,
	  p_select_flag               IN			  VARCHAR2 := NULL,
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level          IN              NUMBER := fnd_api.g_valid_level_full,
      p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
	  p_api_version_number        IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   ) IS

      l_api_name             CONSTANT VARCHAR2 (30) := 'increase_delete_risk_type';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
	  l_risk_type_id   NUMBER := 0;
	  l_risk_type_row_count NUMBER := 0;
	  l_creation_date         date;
      l_created_by            number;
      l_last_update_date      date;
      l_last_updated_by       number;
      l_last_update_login     number;

      --- for risk association to a process, we are passed risk_id and process_id
      --- foll. cursor traverses the process hierarchy tree to get all parent processes
      --- for this process_id
     CURSOR C1 is
	     (select count(*) from amw_risk_type
		 where risk_rev_id = p_risk_rev_id
		 and risk_type_code = p_risk_type_code);

   BEGIN

      SAVEPOINT amw_risk_type_pvt;
      x_return_status            := fnd_api.g_ret_sts_success;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
/* Temporarily commenting out the validata session code ..... */
-- =========================================================================
-- Validate Environment
-- =========================================================================
      IF fnd_global.user_id IS NULL THEN
         amw_utility_pvt.error_message
                                      (p_message_name      => 'USER_PROFILE_MISSING');
         RAISE fnd_api.g_exc_error;
      END IF;


	  IF (p_select_flag = 'N') then
	    OPEN C1;
		FETCH C1 into l_risk_type_row_count;
		  IF (l_risk_type_row_count  = 1) then
			  delete from amw_risk_type
			      where risk_rev_id = p_risk_rev_id
		          and risk_type_code = p_risk_type_code;
		  END IF;
		CLOSE C1;
	  END IF;


	  IF (p_select_flag = 'Y') then
	     OPEN C1;
	     FETCH C1 into l_risk_type_row_count;

		  IF (l_risk_type_row_count  = 0) then
				select amw_risk_type_s.nextval into l_risk_type_id from dual;
				l_creation_date := SYSDATE;
                l_created_by := FND_GLOBAL.USER_ID;
                l_last_update_date := SYSDATE;
                l_last_updated_by := FND_GLOBAL.USER_ID;
                l_last_update_login := FND_GLOBAL.USER_ID;

	            insert into amw_risk_type    (risk_type_id,
                                              risk_rev_id,
                                              risk_type_code,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
											  object_version_number)

                                   values     (l_risk_type_id,
                                               p_risk_rev_id,
                                               p_risk_type_code,
                                               l_creation_date,
                                               l_created_by,
                                               l_last_update_date,
                                               l_last_updated_by,
                                               l_last_update_login,
											   1);
              END IF;
	 END IF;


-- =========================================================================
-- End Validate Environment
-- =========================================================================
-- End commenting the session validation code ....
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      --Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO amw_risk_type_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO amw_risk_type_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO amw_risk_type_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END insert_delete_risk_type;


-- ===============================================================
-- Procedure name
--          Revise_Risk_Type
-- Purpose
-- 		  	revise risk type from old RiskRevId to new RiskRevId
-- ===============================================================
PROCEDURE Revise_Risk_Type(
    p_old_risk_rev_id           IN   NUMBER,
    p_risk_rev_id               IN   NUMBER,
    p_commit                    IN              VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN              NUMBER := fnd_api.g_valid_level_full,
    p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
    p_api_version_number        IN              NUMBER,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2
) IS
      l_api_name             CONSTANT VARCHAR2 (30) := 'Revise_Risk_Type';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
BEGIN
      SAVEPOINT amw_risk_type_revise;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      IF fnd_global.user_id IS NULL THEN
         amw_utility_pvt.error_message
                                      (p_message_name      => 'USER_PROFILE_MISSING');
         RAISE fnd_api.g_exc_error;
      END IF;

      -- carry over Risk Type Associations when Revising the Risk
      IF p_old_risk_rev_id is not null AND p_risk_rev_id is not null THEN
        insert into AMW_RISK_TYPE (
            risk_type_id
           ,risk_rev_id
           ,risk_type_code
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,object_version_number
        )
        select
            amw_risk_type_s.nextval
           ,p_risk_rev_id
           ,old.RISK_TYPE_CODE
           ,sysdate
           ,FND_GLOBAL.USER_ID
           ,sysdate
           ,FND_GLOBAL.USER_ID
           ,FND_GLOBAL.USER_ID
           ,1
          from AMW_RISK_TYPE old
         where old.RISK_REV_ID = p_old_risk_rev_id;
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      --Debug Message
      amw_utility_pvt.debug_message ('API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO amw_risk_type_revise;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO amw_risk_type_revise;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO amw_risk_type_revise;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );

END Revise_Risk_Type;


END amw_risk_type_pvt;

/
