--------------------------------------------------------
--  DDL for Package Body CN_PERIOD_QUOTAS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PERIOD_QUOTAS_GRP" AS
/* $Header: cnxgprdb.pls 120.4 2005/10/19 06:08:07 chanthon ship $ */
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PERIOD_QUOTAS_GRP';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnxgprdb.pls';
   g_last_update_date            DATE := SYSDATE;
   g_last_updated_by             NUMBER := fnd_global.user_id;
   g_creation_date               DATE := SYSDATE;
   g_created_by                  NUMBER := fnd_global.user_id;
   g_last_update_login           NUMBER := fnd_global.login_id;
   g_rowid                       VARCHAR2 (30);
   g_program_type                VARCHAR2 (30);

-- ----------------------------------------------------------------------------+
-- Procedure: Valid_Period_Quotas
-- Desc     : Validate the Period Quotas Input Parameters like Period Name,
--            Plan Element Name.
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_period_quotas (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_period_quotas_rec        IN       cn_plan_element_pub.period_quotas_rec_type,
      x_quota_id                 OUT NOCOPY NUMBER,
      x_period_id                OUT NOCOPY NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_is_duplicate             IN VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Valid_Period_Quotas';
      l_same_pe                     NUMBER;
      l_calc_formula_id             NUMBER;
      l_quota_start_date            DATE;
      l_quota_end_date              DATE;
      l_period_start_date           DATE;
      l_period_end_date             DATE;
      l_loading_status              VARCHAR2 (80);
      l_quota_type_code             cn_quotas.quota_type_code%TYPE;
      l_org_id                      NUMBER;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- API body
      -- check for required data for Period_quotas
      -- Check MISS and NULL  ( Quota Name, Period_name )
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_quota_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_quota_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check Period name is not miss, not null
      --+
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_period_quotas_rec.period_name,
                                      p_para_name           => 'Period Name',
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_period_quotas_rec.period_name,
                                         p_obj_name            => 'Period Name',
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;


    l_org_id := p_period_quotas_rec.org_id ;

      --+
      -- Get quota id, calc_formula_id
      --+
      BEGIN
         SELECT quota_id,
                calc_formula_id,
                start_date,
                end_date,
                quota_type_code
           INTO x_quota_id,
                l_calc_formula_id,
                l_quota_start_date,
                l_quota_end_date,
                l_quota_type_code
           FROM cn_quotas_v
          WHERE NAME = p_quota_name AND org_id = l_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_quota_id := NULL;
            l_calc_formula_id := NULL;
      END;

      --+
      -- Check Quota ID is Not Null
      --+
      IF x_quota_id IS NULL AND p_quota_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check Formula is Assiged to the Quota
      --+
--Change made for duplicate.. added the quota status
      IF (l_calc_formula_id IS NULL AND l_quota_type_code <> 'EXTERNAL'
        AND p_is_duplicate = 'N')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_FORMULA_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_FORMULA_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Disable this checking since we can have period quotas for BOTH ITD
      -- AND NON-ITD FORMULA, bug 2422752
      --+
      -- Check Itd Flag is Y
      --+

      /*IF Nvl(cn_api.get_itd_flag(l_calc_formula_id),'N')  <> 'Y' THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
       FND_MESSAGE.SET_NAME('CN' , 'CN_QUOTA_CANNOT_HAVE_PERIODS');
       FND_MESSAGE.SET_TOKEN('PE_NAME',p_quota_name );
       FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'QUOTA_CANNOT_HAVE_PERIODS';
         RAISE FND_API.G_EXC_ERROR ;
      END IF;*/

      --+
      -- get period id
      --+
      x_period_id := cn_api.get_acc_period_id (p_period_quotas_rec.period_name, l_org_id);

      --+
      -- Check Period ID is Not Null
      --+
      IF x_period_id IS NULL AND p_period_quotas_rec.period_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PERIOD_NOT_EXIST');
            fnd_message.set_token ('PERIOD_NAME', p_period_quotas_rec.period_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PERIOD_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check period start date and end date is falling with the quota
      -- Start date and end Date
      --+
      BEGIN
         SELECT start_date,
                end_date
           INTO l_period_start_date,
                l_period_end_date
           FROM cn_acc_period_statuses_v
          WHERE period_id = x_period_id AND org_id = l_org_id;

         IF    TRUNC (l_period_start_date) < TRUNC (cn_period_quotas_pkg.previous_period (l_quota_start_date,l_org_id))
            OR TRUNC (l_period_end_date) > TRUNC (cn_api.next_period (NVL (l_quota_end_date, l_period_end_date), l_org_id))
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PRD_DT_NOT_WIN_QUOTA_DT');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PRD_DT_NOT_WIN_QUOTA_DT';
            RAISE fnd_api.g_exc_error;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      --+
      -- Check for Duplicate Record for the Same Quota.
      --+
      IF p_period_quotas_rec.period_name_old IS NULL
      THEN
         SELECT COUNT (*)
           INTO l_same_pe
           FROM cn_period_quotas pq
          WHERE pq.period_id = x_period_id AND pq.quota_id = x_quota_id;

         IF l_same_pe <> 0
         THEN
            -- Error, check the msg level and add an error message to the
            -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PERIOD_QUOTA_EXISTS');
               fnd_message.set_token ('PERIOD_NAME', p_period_quotas_rec.period_name);
               fnd_message.set_token ('PE_NAME', p_quota_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PERIOD_QUOTA_EXISTS';
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END valid_period_quotas;

-- ----------------------------------------------------------------------------+
-- Procedure: Check Valid Update
-- Desc     :This procedure is called from update Quota Rules.
-- ----------------------------------------------------------------------------+
   PROCEDURE check_valid_update (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_period_quotas_rec        IN       cn_plan_element_pub.period_quotas_rec_type,
      x_period_quota_id_old      OUT NOCOPY NUMBER,
      x_period_id_old            OUT NOCOPY NUMBER,
      x_quota_id_old             OUT NOCOPY NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Valid_Update';
      l_same_pe                     NUMBER;
      l_quota_id                    NUMBER;
      l_period_id                   NUMBER;
      l_period_quotas_rec           cn_period_quotas%ROWTYPE;
      l_meaning                     cn_lookups.meaning%TYPE;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      --+
      -- Check quota name is not null
      --+
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_quota_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_quota_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Get old Quota id
      --+
      x_quota_id_old := cn_chk_plan_element_pkg.get_quota_id (p_quota_name, p_period_quotas_rec.org_id);

      --+
      -- Raise an error if quota not exists in the database
      --+
      IF x_quota_id_old IS NULL AND p_quota_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- +
      -- Check period name is not null or missing
      --+
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_period_quotas_rec.period_name_old,
                                      p_para_name           => 'Period Name',
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_period_quotas_rec.period_name_old,
                                         p_obj_name            => 'Period Name',
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- get period id
      --+
      x_period_id_old := cn_api.get_acc_period_id (p_period_quotas_rec.period_name_old,p_period_quotas_rec.org_id);

      --+
      -- Check Period ID is Not Null
      --+
      IF x_period_id_old IS NULL AND p_period_quotas_rec.period_name_old IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PERIOD_NOT_EXIST');
            fnd_message.set_token ('PERIOD_NAME', p_period_quotas_rec.period_name_old);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PERIOD_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Get quota period id to update the record
      --+
      BEGIN
         SELECT *
           INTO l_period_quotas_rec
           FROM cn_period_quotas
          WHERE period_id = x_period_id_old AND quota_id = x_quota_id_old;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_period_quotas_rec.period_quota_id := NULL;
      END;

      --+
      -- Check record exists in the database for the period_quota_id.
      --+
      IF l_period_quotas_rec.period_quota_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PERIOD_QUOTA_NOT_EXIST');
            fnd_message.set_token ('QUOTA_NAME', p_quota_name);
            fnd_message.set_token ('PERIOD_NAME', p_period_quotas_rec.period_name_old);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PERIOD_QUOTA_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Assign it to the out variable.
      --+
      x_period_quota_id_old := l_period_quotas_rec.period_quota_id;

      --+
      -- You cannot update columns other than amount columns.
      --+
      IF (l_period_quotas_rec.period_id <> x_period_id_old)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         l_meaning := cn_api.get_lkup_meaning ('PERIOD_ID', 'PERIOD_OBJECT_TYPE');

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PERIOD_NOT_CONSISTENT');
            fnd_message.set_token ('QUOTA_NAME', p_quota_name);
            fnd_message.set_token ('PERIOD_NAME', p_period_quotas_rec.period_name);
            fnd_message.set_token ('OBJ_NAME', l_meaning);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PERIOD_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Validate the period quotas
      --+
      valid_period_quotas (x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
                           p_quota_name             => p_quota_name,
                           p_period_quotas_rec      => p_period_quotas_rec,
                           x_quota_id               => l_quota_id,
                           x_period_id              => l_period_id,
                           p_loading_status         => x_loading_status,
                           x_loading_status         => l_loading_status,
                           p_is_duplicate           => 'N'
                          );                                                                                                    -- Default Validations
      x_loading_status := l_loading_status;

      -- Raise an error if the status is not success
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END check_valid_update;

--|-----------------------------------------------------------------------+
--|  Procedure Name: Create_Period_Quotas
--| Descr: Create a Period Quotas
--|-----------------------------------------------------------------------+
   PROCEDURE create_period_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_period_quotas_rec_tbl    IN       cn_plan_element_pub.period_quotas_rec_tbl_type := cn_plan_element_pub.g_miss_period_quotas_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_is_duplicate             IN VARCHAR2 DEFAULT 'N'
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Period_Quotas';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_period_id                   NUMBER;
      l_quota_id                    NUMBER;
      l_period_quota_id             NUMBER;
      l_tmp                         NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT create_period_quotas;

      --+
      -- Standard call to check for call compatibility.
      --+
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --+
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- +
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- +
      --  Initialize API return status to success
      --+
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := 'CN_INSERTED';

      -- +
      -- API body
      -- +
      IF (p_period_quotas_rec_tbl.COUNT <> 0)
      THEN
         -- Loop through each record and check go through the normal validations
         -- and etc.
         FOR i IN p_period_quotas_rec_tbl.FIRST .. p_period_quotas_rec_tbl.LAST
         LOOP
            valid_period_quotas (x_return_status          => x_return_status,
                                 x_msg_count              => x_msg_count,
                                 x_msg_data               => x_msg_data,
                                 p_quota_name             => p_quota_name,
                                 p_period_quotas_rec      => p_period_quotas_rec_tbl (i),
                                 x_quota_id               => l_quota_id,
                                 x_period_id              => l_period_id,
                                 p_loading_status         => x_loading_status,
                                 x_loading_status         => l_loading_status,
                                 p_is_duplicate         => p_is_duplicate
                                );
            x_loading_status := l_loading_status;
            -- Check return status and insert if the status is CN_INSERTED
            --ELSE Record Already exists
            l_tmp := p_period_quotas_rec_tbl.COUNT;

            --+
            -- Raise an error if the return status is not success
            --+
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_success) AND (x_loading_status = 'CN_INSERTED')
            THEN
               cn_period_quotas_pkg.begin_record (x_operation              => 'INSERT',
                                                  x_period_quota_id        => l_period_quota_id,
                                                  x_period_id              => l_period_id,
                                                  x_quota_id               => l_quota_id,
                                                  x_period_target          => p_period_quotas_rec_tbl (i).period_target,
                                                  x_itd_target             => NULL,
                                                  x_period_payment         => p_period_quotas_rec_tbl (i).period_payment,
                                                  x_itd_payment            => NULL,
                                                  x_quarter_num            => NULL,
                                                  x_period_year            => NULL,
                                                  x_performance_goal       => p_period_quotas_rec_tbl (i).performance_goal,
                                                  x_creation_date          => g_creation_date,
                                                  x_last_update_date       => g_last_update_date,
                                                  x_last_update_login      => g_last_update_login,
                                                  x_last_updated_by        => g_last_updated_by,
                                                  x_created_by             => g_created_by,
                                                  x_period_type_code       => NULL
                                                 );
            END IF;                                                                                                                    -- CN_INSERTED.
         END LOOP;                                                                                                                    -- Period Quotas

         -- clku, bug 3637221 , we need to sync the itd values in case of inserting
         -- non-zero period target, payment_amount or goal, particularly in
         -- duplicating Plan Element
         cn_period_quotas_pkg.sync_itd_values (x_quota_id => l_quota_id);
      END IF;                                                                                                               -- Table Count is Not Zero

      --+
      -- End of API body.
      -- Standard check of p_commit.
      --+
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      --+
      -- Standard call to get message count and if count is 1, get message info.
      --+
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_period_quotas;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_period_quotas;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_period_quotas;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_period_quotas;

--|-----------------------------------------------------------------------+
--|  Procedure Name: Update_Period_Quotas
--| Descr: Update a Period Quotas
--|----------------------------------------------------------------------- +
   PROCEDURE update_period_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_period_quotas_rec_tbl    IN       cn_plan_element_pub.period_quotas_rec_tbl_type := cn_plan_element_pub.g_miss_period_quotas_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Period_Quotas';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_period_id                   NUMBER;
      l_quota_id                    NUMBER;
      l_period_quota_id             NUMBER;
      l_tmp                         NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT update_plan_element;

      --+
      -- Standard call to check for call compatibility.
      --+
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --+
      -- Initialize message list if p_init_msg_list is set to TRUE.
      -- +
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- +
      --  Initialize API return status to success
      --+
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := 'CN_UPDATED';

      -- +
      -- API body
      -- +
      IF (p_period_quotas_rec_tbl.COUNT <> 0)
      THEN
         -- Loop through each record and check go through the normal validations
         -- and etc.
         FOR i IN p_period_quotas_rec_tbl.FIRST .. p_period_quotas_rec_tbl.LAST
         LOOP
            check_valid_update (x_return_status            => x_return_status,
                                x_msg_count                => x_msg_count,
                                x_msg_data                 => x_msg_data,
                                p_quota_name               => p_quota_name,
                                p_period_quotas_rec        => p_period_quotas_rec_tbl (i),
                                x_quota_id_old             => l_quota_id,
                                x_period_id_old            => l_period_id,
                                x_period_quota_id_old      => l_period_quota_id,
                                p_loading_status           => x_loading_status,
                                x_loading_status           => l_loading_status
                               );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_success) AND (x_loading_status = 'CN_UPDATED')
            THEN
               cn_period_quotas_pkg.begin_record (x_operation              => 'UPDATE',
                                                  x_period_quota_id        => l_period_quota_id,
                                                  x_period_id              => l_period_id,
                                                  x_quota_id               => l_quota_id,
                                                  x_period_target          => p_period_quotas_rec_tbl (i).period_target,
                                                  x_itd_target             => NULL,
                                                  x_period_payment         => p_period_quotas_rec_tbl (i).period_payment,
                                                  x_itd_payment            => NULL,
                                                  x_quarter_num            => NULL,
                                                  x_period_year            => NULL,
                                                  x_performance_goal       => p_period_quotas_rec_tbl (i).performance_goal,
                                                  x_creation_date          => g_creation_date,
                                                  x_last_update_date       => g_last_update_date,
                                                  x_last_update_login      => g_last_update_login,
                                                  x_last_updated_by        => g_last_updated_by,
                                                  x_created_by             => g_created_by,
                                                  x_period_type_code       => NULL
                                                 );
            END IF;                                                                                                                     -- CN_UPDATED.
         END LOOP;                                                                                                                    -- Period Quotas
      END IF;                                                                                                               -- Table Count is Not Zero

      --+
      -- End of API body.
      -- Standard check of p_commit.
      --+
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      --+
      -- Standard call to get message count and if count is 1, get message info.
      --+
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_period_quotas;
END cn_period_quotas_grp;

/
