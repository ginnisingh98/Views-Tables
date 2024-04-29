--------------------------------------------------------
--  DDL for Package Body CN_PRD_QUOTA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PRD_QUOTA_PVT" AS
   /*$Header: cnvpedqb.pls 120.3 2005/08/05 00:32:44 fmburu ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PRD_QUOTA_PVT';

-- Start of comments
--      API name        : Update_PRD_QUOTA
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_prd_quota         IN prd_quota_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_period_quota (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_prd_quota                IN OUT NOCOPY prd_quota_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'update_period_quota';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_old_prd_quota_cr
      IS
         SELECT *
           FROM cn_period_quotas cpq
          WHERE cpq.period_quota_id = p_prd_quota.period_quota_id;

      l_old_prd_quota               l_old_prd_quota_cr%ROWTYPE;
      l_prd_quota                   prd_quota_rec_type;
      l_temp_count                  NUMBER;
      l_period_target               NUMBER;
      l_period_payment              NUMBER;
      l_performance_goal            NUMBER;
      p_period_quota_id             cn_period_quotas.period_quota_id%TYPE;
      p_period_id                   cn_period_quotas.period_id%TYPE;
      p_quota_id                    cn_period_quotas.quota_id%TYPE;
      p_itd_target                  NUMBER;
      p_itd_payment                 NUMBER;
      p_quarter_num                 NUMBER;
      p_period_year                 cn_period_quotas.period_year%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_prd_quota;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      SELECT COUNT (*)
        INTO l_temp_count
        FROM cn_period_quotas
       WHERE period_quota_id = p_prd_quota.period_quota_id
         AND quota_id = p_prd_quota.quota_id
         AND period_id = p_prd_quota.period_id
         AND org_id = p_prd_quota.org_id;

      IF l_temp_count < 1
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INCONSISTENT_DATA');
            fnd_message.set_token ('INPUT1', cn_api.get_lkup_meaning ('ORGANIZATION', 'PE_OBJECT_TYPE'));
            fnd_message.set_token ('INPUT2', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
            fnd_message.set_token ('INPUT3', cn_api.get_lkup_meaning ('PERIOD', 'PERIOD_TYPE_CODE'));
            fnd_message.set_token ('INPUT4', cn_api.get_lkup_meaning (' ', 'INPUT_TOKEN'));
            fnd_message.set_token ('INPUT5', ' ');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- API body
      OPEN l_old_prd_quota_cr;

      FETCH l_old_prd_quota_cr
       INTO l_old_prd_quota;

      CLOSE l_old_prd_quota_cr;

      IF p_prd_quota.object_version_number IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('ORGANIZATION', 'PE_OBJECT_TYPE'));
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- 3. check object version number
      IF l_old_prd_quota.object_version_number <> p_prd_quota.object_version_number
      THEN
         fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      p_prd_quota.last_update_date := SYSDATE;
      p_prd_quota.last_update_login := fnd_global.login_id;
      p_prd_quota.last_updated_by := fnd_global.user_id;
      -- update the table
      cn_period_quotas_pkg.UPDATE_RECORD (p_period_quota_id             => p_prd_quota.period_quota_id,
                                          p_quota_id                    => p_prd_quota.quota_id,
                                          p_period_id                   => p_prd_quota.period_id,
                                          p_period_target               => p_prd_quota.period_target,
                                          p_period_payment              => p_prd_quota.period_payment,
                                          p_performance_goal            => p_prd_quota.performance_goal,
                                          p_last_update_date            => p_prd_quota.last_update_date,
                                          p_last_update_login           => p_prd_quota.last_update_login,
                                          p_last_updated_by             => p_prd_quota.last_updated_by,
                                          x_itd_target                  => p_prd_quota.itd_target,
                                          x_itd_payment_amount          => p_prd_quota.itd_payment,
                                          x_itd_performance_amount      => p_prd_quota.performance_goal_itd,
                                          x_object_version_number       => p_prd_quota.object_version_number
                                         );

      -- sync balances
      cn_period_quotas_pkg.sync_ITD_values (x_quota_id => p_prd_quota.quota_id);

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_prd_quota;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_prd_quota;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_prd_quota;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_period_quota;

END cn_prd_quota_pvt;

/
