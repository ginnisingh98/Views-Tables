--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULES_GRP" AS
/* $Header: cnxgqrb.pls 120.4 2005/10/18 07:26:19 chanthon noship $ */
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_QUOTA_RULES_GRP';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnxgqrb.pls';
   g_last_update_date            DATE := SYSDATE;
   g_last_updated_by             NUMBER := fnd_global.user_id;
   g_creation_date               DATE := SYSDATE;
   g_created_by                  NUMBER := fnd_global.user_id;
   g_last_update_login           NUMBER := fnd_global.login_id;
   g_rowid                       VARCHAR2 (30);
   g_program_type                VARCHAR2 (30);

-- ----------------------------------------------------------------------------+
-- Function : convert_pe_user_input
-- Desc     : function to trim all blank spaces of user input
--            Assign defalut value if input is missing
-- ----------------------------------------------------------------------------+
   FUNCTION convert_rev_class_user_input (
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec        IN       cn_plan_element_pub.revenue_class_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN cn_chk_plan_element_pkg.pe_rec_type
   IS
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      l_pe_rec.NAME := LTRIM (RTRIM (p_quota_name));
      l_pe_rec.org_id := p_revenue_class_rec.org_id;
      l_pe_rec.rev_class_name := LTRIM (RTRIM (p_revenue_class_rec.rev_class_name));
      l_pe_rec.rev_class_id := cn_api.get_rev_class_id (l_pe_rec.rev_class_name,p_revenue_class_rec.org_id);

      -- Get the Plan Information for further use.
      BEGIN
         SELECT quota_id, quota_type_code, incentive_type_code, credit_type_id
           INTO l_pe_rec.quota_id, l_pe_rec.quota_type_code, l_pe_rec.incentive_type_code, l_pe_rec.credit_type_id
           FROM cn_quotas_v
          WHERE NAME = l_pe_rec.NAME and org_id = p_revenue_class_rec.org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', l_pe_rec.NAME);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
      END;

      -- Set the Default Rev Class Target
      SELECT DECODE (p_revenue_class_rec.rev_class_target, fnd_api.g_miss_num, 0, NULL, 0, p_revenue_class_rec.rev_class_target)
        INTO l_pe_rec.rev_class_target
        FROM SYS.DUAL;

      -- Set the Default value for Payment Amount
      SELECT DECODE (p_revenue_class_rec.rev_class_payment_amount, fnd_api.g_miss_num, 0, NULL, 0, p_revenue_class_rec.rev_class_payment_amount)
        INTO l_pe_rec.rev_class_payment_amount
        FROM SYS.DUAL;

      -- Set the Default Value for Performance Goal
      SELECT DECODE (p_revenue_class_rec.rev_class_performance_goal, fnd_api.g_miss_num, 0, NULL, 0, p_revenue_class_rec.rev_class_performance_goal)
        INTO l_pe_rec.rev_class_performance_goal
        FROM SYS.DUAL;

      RETURN l_pe_rec;
   END convert_rev_class_user_input;

-- ----------------------------------------------------------------------------+
-- Procedure: valid_quota_element
-- Desc     : Validate the Quto Rules Input Parameters like Revenue Class Name,
--            Plan Element Name.
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_quota_rules (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_rev_class_name_old       IN       VARCHAR2 := NULL,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Valid_Quota_Rules';
      l_same_pe                     NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- API body
      -- check for required data in Quotas.
      -- Check MISS and NULL  ( Revenue class Name, Quota Name )
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.NAME,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.NAME,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check rev class name is not miss, not null
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.rev_class_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_rev_cls_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.rev_class_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_rev_cls_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check wheather revenue class allowed for this Quota Type.
      --+
      IF (p_pe_rec.incentive_type_code NOT IN ('COMMISSION', 'BONUS'))
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CANNOT_HAVE_REV_CLASS');
            fnd_message.set_token ('OBJ_VALUE', 'MANUAL');
            fnd_message.set_token ('PLAN_TYPE', cn_api.get_lkup_meaning (p_pe_rec.quota_type_code, 'QUOTA_TYPE'));
            fnd_message.set_token ('TOKEN1', NULL);
            fnd_message.set_token ('TOKEN2', NULL);
            fnd_message.set_token ('TOKEN3', NULL);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_CANNOT_HAVE_REV_CLASS';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check the revenue class name is exists in the Database.
      --+
      IF p_pe_rec.rev_class_id IS NULL AND p_pe_rec.rev_class_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check for Duplicate Record for the Same Quota.
      --  only checks if the old value is null ( always nuill except UPDATE )
      --+
      IF p_rev_class_name_old IS NULL
      THEN
         SELECT COUNT (*)
           INTO l_same_pe
           FROM cn_quota_rules qr
          WHERE qr.revenue_class_id = (SELECT revenue_class_id
                                         FROM cn_revenue_classes
                                        WHERE NAME = p_pe_rec.rev_class_name
                                        AND org_id = p_pe_rec.org_id) AND qr.quota_id = p_pe_rec.quota_id;

         IF l_same_pe <> 0
         THEN
            -- Error, check the msg level and add an error message to the
            -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_REV_EXISTS');
               fnd_message.set_token ('PLAN_NAME', p_pe_rec.NAME);
               fnd_message.set_token ('REVENUE_CLASS_NAME', p_pe_rec.rev_class_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PLN_QUOTA_REV_EXISTS';
         END IF;
      END IF;
-- end of valid quota rules
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
   END valid_quota_rules;

-- ----------------------------------------------------------------------------+
-- Procedure: Check Valid Update
-- Desc     :This procedure is called from update Quota Rules.
-- ----------------------------------------------------------------------------+
   PROCEDURE check_valid_update (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_rev_class_name_old       IN       VARCHAR2,
      x_rev_class_id_old         OUT NOCOPY NUMBER,
      x_quota_rule_id_old        OUT NOCOPY NUMBER,
      p_new_pe_rec               IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Valid_Update';
      l_same_pe                     NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- get old revenue class id using old revenue class name
      x_rev_class_id_old := cn_api.get_rev_class_id (p_rev_class_name_old,p_new_pe_rec.org_id);

      -- Old revenue class exists and valid in the database
      IF p_rev_class_name_old IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_ASSIGNED');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'REV_CLASS_NOT_ASSIGNED';
         RAISE fnd_api.g_exc_error;
      END IF;

      IF x_rev_class_id_old IS NULL AND p_rev_class_name_old IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      SELECT COUNT (*)
        INTO l_same_pe
        FROM cn_quota_rules qr
       WHERE qr.revenue_class_id = (SELECT revenue_class_id
                                      FROM cn_revenue_classes
                                     WHERE revenue_class_id = x_rev_class_id_old) AND qr.quota_id = p_new_pe_rec.quota_id;

      IF l_same_pe = 0
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_ASSIGNED');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'REV_CLASS_NOT_ASSIGNED';
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_new_pe_rec.rev_class_id <> NVL (x_rev_class_id_old, 0)
      THEN
         SELECT COUNT (*)
           INTO l_same_pe
           FROM cn_quota_rules qr
          WHERE qr.revenue_class_id = (SELECT revenue_class_id
                                         FROM cn_revenue_classes
                                        WHERE revenue_class_id = p_new_pe_rec.rev_class_id) AND qr.quota_id = p_new_pe_rec.quota_id;

         IF l_same_pe > 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_REV_EXIST');
               fnd_message.set_token ('PLAN_NAME', p_new_pe_rec.NAME);
               fnd_message.set_token ('REVENUE_CLASS_NAME', p_new_pe_rec.rev_class_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'PLN_QUOTA_REV_EXISTS';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --+
      -- get the Old quota Rule ID, Used for Update or Delete
      --+
      x_quota_rule_id_old := cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id => p_new_pe_rec.quota_id, p_rev_class_id => x_rev_class_id_old);

      IF x_quota_rule_id_old IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
            fnd_message.set_token ('PLAN_NAME', p_new_pe_rec.NAME);
            fnd_message.set_token ('REVENUE_CLASS_NAME', p_new_pe_rec.rev_class_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_RULE_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Default Validations
      valid_quota_rules (x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_rev_class_name_old      => p_rev_class_name_old,
                         p_pe_rec                  => p_new_pe_rec,
                         p_loading_status          => x_loading_status,
                         x_loading_status          => l_loading_status
                        );
      x_loading_status := l_loading_status;

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
         l_loading_status := 'UNEXPECTED_ERR';
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

--|/*-----------------------------------------------------------------------+
--|  Procedure Name: Create_Quota_Rules
--| Descr: Create a Quota Rules
--|----------------------------------------------------------------------- */
   PROCEDURE create_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type := cn_plan_element_pub.g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Quota_Rules';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec;
      l_revenue_class_rec           cn_plan_element_pub.revenue_class_rec_type;
      l_trx_factor_rec              cn_plan_element_pub.trx_factor_rec_type;
      l_quota_rule_id               NUMBER;
      l_meaning                     cn_lookups.meaning%TYPE;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT create_plan_element;

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
      IF (p_revenue_class_rec_tbl.COUNT <> 0)
      THEN
         -- Loop through each record and check go through the normal validations
         -- and etc.
         FOR i IN p_revenue_class_rec_tbl.FIRST .. p_revenue_class_rec_tbl.LAST
         LOOP
            -- convert the user input into the local record
            l_pe_rec :=
               convert_rev_class_user_input (p_quota_name             => p_quota_name,
                                             p_revenue_class_rec      => p_revenue_class_rec_tbl (i),
                                             x_return_status          => x_return_status,
                                             p_loading_status         => x_loading_status,
                                             x_loading_status         => l_loading_status
                                            );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Validate Quota Rules
            valid_quota_rules (x_return_status       => x_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data,
                               p_pe_rec              => l_pe_rec,
                               p_loading_status      => x_loading_status,
                               x_loading_status      => l_loading_status
                              );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Check not required if already exists in the database
            -- Already passed the validation while insert the record
            -- Now it is thinking that there is possibility for the
            -- trx factor update( no insert allowed for trx)
            -- or uplift insert
            IF x_loading_status <> 'QUOTA_RULE_NOT_EXIST'
            THEN
               cn_chk_plan_element_pkg.valid_revenue_class (x_return_status       => x_return_status,
                                                            p_pe_rec              => l_pe_rec,
                                                            p_loading_status      => x_loading_status,
                                                            x_loading_status      => l_loading_status
                                                           );
               x_loading_status := l_loading_status;
            END IF;

            -- Check return status and insert if the status is CN_INSERTED
            -- then inser the Quota Rules, Insert the trx
            --ELSE Record Already exists, but Trx count > 0
            -- Update trx factors
            -- EXLSE Record Already Exists
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_success) AND (x_loading_status = 'CN_INSERTED')
            THEN
               IF l_pe_rec.incentive_type_code IN ('COMMISSION', 'BONUS')
               THEN
                  cn_quota_rules_pkg.begin_record (x_operation                 => 'INSERT',
                                                   x_object_version_number     => l_pe_rec.object_version_number,
                                                   x_org_id                    => l_pe_rec.org_id,
                                                   x_quota_rule_id             => l_pe_rec.quota_rule_id,
                                                   x_quota_id                  => l_pe_rec.quota_id,
                                                   x_revenue_class_id          => l_pe_rec.rev_class_id,
                                                   x_revenue_class_name        => l_pe_rec.rev_class_name,
                                                   x_target                    => l_pe_rec.rev_class_target,
                                                   x_revenue_class_id_old      => l_pe_rec.rev_class_id,
                                                   x_target_old                => l_pe_rec.rev_class_target,
                                                   x_payment_amount            => l_pe_rec.rev_class_payment_amount,
                                                   x_performance_goal          => l_pe_rec.rev_class_performance_goal,
                                                   x_last_update_date          => g_last_update_date,
                                                   x_last_updated_by           => g_last_updated_by,
                                                   x_creation_date             => g_creation_date,
                                                   x_created_by                => g_created_by,
                                                   x_last_update_login         => g_last_update_login,
                                                   x_program_type              => g_program_type,
                                                   x_status_code               => NULL,
                                                   x_payment_amount_old        => NULL,
                                                   x_performance_goal_old      => NULL
                                                  );

                  -- Insert the trx Factor fix each revenue Class you insert only if pass the
                  -- trx factor record otherwise it default.
                  -- Trx Factor data should be loaded from p_trx_factor_rec_tbl,
                  -- Since we insert data with default value already, so need to
                  -- delete then insert it again
                  IF (p_trx_factor_rec_tbl.COUNT <> 0)
                  THEN
                     FOR i IN p_trx_factor_rec_tbl.FIRST .. p_trx_factor_rec_tbl.LAST
                     LOOP
                        IF (p_trx_factor_rec_tbl.EXISTS (i)) AND (p_trx_factor_rec_tbl (i).rev_class_name = l_pe_rec.rev_class_name)
                        THEN
                           l_meaning := cn_api.get_lkup_meaning (p_trx_factor_rec_tbl (i).trx_type, 'TRX TYPES');

                           IF l_meaning IS NULL
                           THEN
                              IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                              THEN
                                 fnd_message.set_name ('CN', 'CN_TRX_TYPE_NOT_EXISTS');
                                 fnd_msg_pub.ADD;
                              END IF;

                              x_loading_status := 'CN_TRX_TYPE_NOT_EXISTS';
                              RAISE fnd_api.g_exc_error;
                           END IF;

                           UPDATE cn_trx_factors
                              SET event_factor = p_trx_factor_rec_tbl (i).event_factor
                            WHERE quota_rule_id = l_pe_rec.quota_rule_id
                              AND quota_id = l_pe_rec.quota_id
                              AND trx_type = p_trx_factor_rec_tbl (i).trx_type;
                        END IF;                                                                                                   -- trx Factor Exists
                     END LOOP;                                                                                                             -- Trx Loop

                     --+
                     -- validate Rule :
                     --  Check TRX_FACTORS
                     --  1. Key Factor's total = 100
                     --  2. Must have Trx_Factors
                     --+
                     cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                             p_quota_rule_id       => l_pe_rec.quota_rule_id,
                                                             p_rev_class_name      => l_pe_rec.rev_class_name,
                                                             p_loading_status      => x_loading_status,
                                                             x_loading_status      => l_loading_status
                                                            );
                     x_loading_status := l_loading_status;

                     IF (x_return_status <> fnd_api.g_ret_sts_success) OR x_loading_status <> 'CN_INSERTED'
                     THEN
                        RAISE fnd_api.g_exc_error;
                     END IF;
                  END IF;                                                                                     -- end (p_trx_factor_rec_tbl.COUNT <> 0)
               END IF;                                                                                             -- Element_type  COMMISSION, BONUES
            ELSIF (x_loading_status = 'PLN_QUOTA_REV_EXISTS')
            THEN
               IF (p_trx_factor_rec_tbl.COUNT = 0 AND p_rev_uplift_rec_tbl.COUNT = 0)
               THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF p_trx_factor_rec_tbl.COUNT <> 0
               THEN
                  -- Custom trx factors it means we need to update
                  -- exisiting trx factors.
                  NULL;
               -- Taken care in the calling Place.
               ELSIF p_rev_uplift_rec_tbl.COUNT > 0
               THEN
                  x_loading_status := 'CN_INSERTED';                                                                -- Calling Place will handle this
               END IF;                                                                                                                         -- Case
            END IF;                                                                                                                    -- CN_INSERTED.
         END LOOP;                                                                                                                    -- Revenue Class
      END IF;                                                                                                               -- Table Count is Not Zero

      -- End of API body.
      -- Standard check of p_commit.
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
         ROLLBACK TO create_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_quota_rules;

--|-------------------------------------------------------------------------+
--|  Procedure Name: Update_Quota_Rules
--| Descr: Update a Quota Rules
--|-------------------------------------------------------------------------+
   PROCEDURE update_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Quota_Rules';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec;
      l_revenue_class_rec           cn_plan_element_pub.revenue_class_rec_type;
      l_trx_factor_rec              cn_plan_element_pub.trx_factor_rec_type;
      l_quota_rule_id               NUMBER;
      l_rev_class_id_old            NUMBER;
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
      IF (p_revenue_class_rec_tbl.COUNT <> 0)
      THEN
         FOR i IN p_revenue_class_rec_tbl.FIRST .. p_revenue_class_rec_tbl.LAST
         LOOP
            -- Convert the User input into the local variable.
            l_pe_rec :=
               convert_rev_class_user_input (p_quota_name             => p_quota_name,
                                             p_revenue_class_rec      => p_revenue_class_rec_tbl (i),
                                             x_return_status          => x_return_status,
                                             p_loading_status         => x_loading_status,
                                             x_loading_status         => l_loading_status
                                            );
            x_loading_status := l_loading_status;

            -- if Any Error Raise an Error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Check for valid Update
            check_valid_update (x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data,
                                p_rev_class_name_old      => p_revenue_class_rec_tbl (i).rev_class_name_old,
                                x_rev_class_id_old        => l_rev_class_id_old,
                                x_quota_rule_id_old       => l_quota_rule_id,
                                p_new_pe_rec              => l_pe_rec,
                                p_loading_status          => x_loading_status,
                                x_loading_status          => l_loading_status
                               );
            x_loading_status := l_loading_status;

            -- If not success then Raise an Error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

                 --+
            -- IF you change the Revenue Class check for nested child
            --+
            IF l_pe_rec.rev_class_id <> l_rev_class_id_old
            THEN
               cn_chk_plan_element_pkg.valid_revenue_class (x_return_status             => x_return_status,
                                                            p_pe_rec                    => l_pe_rec,
                                                            p_revenue_class_id_old      => l_rev_class_id_old,
                                                            p_loading_status            => x_loading_status,
                                                            x_loading_status            => l_loading_status
                                                           );
               x_loading_status := l_loading_status;
            END IF;

            -- if faliure raise an error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_success) AND (x_loading_status = 'CN_UPDATED')
            THEN
               IF l_pe_rec.incentive_type_code IN ('COMMISSION', 'BONUS')
               THEN
                  cn_quota_rules_pkg.begin_record (x_operation                 => 'UPDATE',
                                                   x_quota_rule_id             => l_quota_rule_id,
                                                   x_object_version_number     => l_pe_rec.object_version_number,
                                                   x_org_id                  => l_pe_rec.org_id,
                                                   x_quota_id                  => l_pe_rec.quota_id,
                                                   x_revenue_class_id          => l_pe_rec.rev_class_id,
                                                   x_revenue_class_name        => l_pe_rec.rev_class_name,
                                                   x_target                    => l_pe_rec.rev_class_target,
                                                   x_payment_amount            => l_pe_rec.rev_class_payment_amount,
                                                   x_performance_goal          => l_pe_rec.rev_class_performance_goal,
                                                   x_revenue_class_id_old      => l_rev_class_id_old,
                                                   x_target_old                => l_pe_rec.rev_class_target,
                                                   x_last_update_date          => g_last_update_date,
                                                   x_last_updated_by           => g_last_updated_by,
                                                   x_creation_date             => g_creation_date,
                                                   x_created_by                => g_created_by,
                                                   x_last_update_login         => g_last_update_login,
                                                   x_program_type              => g_program_type,
                                                   x_status_code               => NULL,
                                                   x_payment_amount_old        => NULL,
                                                   x_performance_goal_old      => NULL
                                                  );

                  -- Insert the trx Factor fix each revenue Class you insert only if pass the
                  -- trx factor record otherwise it default.
                  IF (p_trx_factor_rec_tbl.COUNT <> 0)
                  THEN
                     FOR i IN p_trx_factor_rec_tbl.FIRST .. p_trx_factor_rec_tbl.LAST
                     LOOP
                        IF (p_trx_factor_rec_tbl.EXISTS (i)) AND (p_trx_factor_rec_tbl (i).rev_class_name = l_pe_rec.rev_class_name)
                        THEN
                           UPDATE cn_trx_factors
                              SET event_factor = p_trx_factor_rec_tbl (i).event_factor
                            WHERE quota_rule_id = l_quota_rule_id AND trx_type = p_trx_factor_rec_tbl (i).trx_type;
                        END IF;                                                                                                   -- trx Factor Exists
                     END LOOP;                                                                                                             -- Trx Loop

                     --+
                     -- validate Rule :
                     --  Check TRX_FACTORS
                     --  1. Key Factor's total = 100
                     --  2. Must have Trx_Factors
                     --+
                     cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                             p_quota_rule_id       => l_quota_rule_id,
                                                             p_rev_class_name      => l_pe_rec.rev_class_name,
                                                             p_loading_status      => x_loading_status,
                                                             x_loading_status      => l_loading_status
                                                            );
                     x_loading_status := l_loading_status;

                               -- If the status is <> S or if the loading status is changed THEN
                     -- Raise an Error
                     IF (x_return_status <> fnd_api.g_ret_sts_success) OR x_loading_status <> 'CN_UPDATED'
                     THEN
                        RAISE fnd_api.g_exc_error;
                     END IF;
                  END IF;                                                                                  -- End if (p_trx_factor_rec_tbl.COUNT <> 0)
               END IF;                                                                                 -- end if for Element_type = COMMISSION, BONUES
            ELSIF (x_loading_status = 'PLN_QUOTA_REV_EXISTS')
            THEN
               IF (p_trx_factor_rec_tbl.COUNT = 0 AND p_revenue_class_rec_tbl.COUNT = 0)
               THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF p_trx_factor_rec_tbl.COUNT <> 0
               THEN
                  -- insert into the trx_factors
                  NULL;
               END IF;
            END IF;                                                                                                                     -- Not success
         END LOOP;                                                                                                                    -- Revenue Class
      END IF;                                                                                                               -- Table Count is Not Zero

      -- End of API body.
      -- Standard check of p_commit.
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
   END update_quota_rules;

--|-------------------------------------------------------------------------+
--|  Procedure Name: Delete_Quota_Rules
--| Descr: Delete a Quota Rules
--|-------------------------------------------------------------------------+
   PROCEDURE delete_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_rev_rec                     cn_quota_rules%ROWTYPE;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_plan_element;

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
      x_loading_status := 'CN_DELETED';

      -- API body
      -- Store the User Input Value into The Local Variable.
      -- Standard check of p_commit.
      --+
      -- Check if plan element name is missing or null even for Delete the Q Rule
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

      -- Get the Quota ID
      l_rev_rec.quota_id := cn_chk_plan_element_pkg.get_quota_id (LTRIM (RTRIM (p_quota_name)),p_revenue_class_rec_tbl(1).org_id);

      -- Raise an Error If quota id is null but name is not null
      IF l_rev_rec.quota_id IS NULL AND p_quota_name IS NOT NULL
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

      -- Loop Through Each Record and Delete IT
      IF p_revenue_class_rec_tbl.COUNT > 0
      THEN
         FOR i IN 1 .. p_revenue_class_rec_tbl.COUNT
         LOOP
            -- Get Revenue Class ID
            l_rev_rec.revenue_class_id := cn_api.get_rev_class_id (p_revenue_class_rec_tbl (i).rev_class_name,p_revenue_class_rec_tbl (i).org_id);

            -- Raise an Error if the Revenue Class iD is Null and Name IS not NUll
            IF l_rev_rec.revenue_class_id IS NULL AND p_revenue_class_rec_tbl (i).rev_class_name IS NOT NULL
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Get the Quota Rule ID
            l_rev_rec.quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id (l_rev_rec.quota_id, l_rev_rec.revenue_class_id);

            IF l_rev_rec.quota_rule_id IS NULL
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
                  fnd_message.set_token ('PLAN_NAME', p_quota_name);
                  fnd_message.set_token ('REVENUE_CLASS_NAME', p_revenue_class_rec_tbl (i).rev_class_name);
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'QUOTA_RULE_NOT_EXIST';
               RAISE fnd_api.g_exc_error;
            END IF;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_success AND x_loading_status = 'CN_DELETED')
            THEN
               -- Delete Record;
               cn_quota_rules_pkg.DELETE_RECORD (x_quota_id              => l_rev_rec.quota_id,
                                                 x_quota_rule_id         => l_rev_rec.quota_rule_id,
                                                 x_revenue_class_id      => l_rev_rec.revenue_class_id
                                                );
            END IF;
         END LOOP;
      END IF;

      -- standard Commit
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
         ROLLBACK TO delete_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_quota_rules;
END cn_quota_rules_grp;

/
