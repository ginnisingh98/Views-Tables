--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_PVT" AS
   /*$Header: cnvqtrlb.pls 120.6 2006/05/25 11:27:22 chanthon ship $*/
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_QUOTA_RULE_PVT';
   g_last_update_date            DATE := SYSDATE;
   g_last_updated_by             NUMBER := fnd_global.user_id;
   g_creation_date               DATE := SYSDATE;
   g_created_by                  NUMBER := fnd_global.user_id;
   g_last_update_login           NUMBER := fnd_global.login_id;
   g_rowid                       VARCHAR2 (30);
   g_program_type                VARCHAR2 (30);
   g_quota_rule_not_exists       VARCHAR2 (30) := 'QUOTA_RULE_NOT_EXISTS';
   g_quota_rule_exists           VARCHAR2 (30) := 'QUOTA_RULE_EXISTS';

   --- convert the public rec to the private one
   FUNCTION convert_rev_class_user_input (
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec        IN       cn_plan_element_pub.revenue_class_rec_type,
      p_old_revenue_class_name   IN       VARCHAR2 := NULL,
      x_loading_status           IN OUT NOCOPY VARCHAR2
   )
      RETURN quota_rule_rec_type
   IS
      l_quota_rule                  quota_rule_rec_type;
      l_loading_status              VARCHAR2 (2000);
      l_old_name                    cn_revenue_classes.NAME%TYPE;
      l_old_revenue_class_id        NUMBER;
      l_old_quota_rule_id           NUMBER;
   BEGIN
      l_quota_rule.plan_element_name := LTRIM (RTRIM (p_quota_name));
      l_quota_rule.revenue_class_name := LTRIM (RTRIM (p_revenue_class_rec.rev_class_name));
      l_old_name := LTRIM (RTRIM (p_old_revenue_class_name));
      l_quota_rule.revenue_class_id := cn_api.get_rev_class_id (l_quota_rule.revenue_class_name, l_quota_rule.org_id);

      -- API body
      -- Store the User Input Value into The Local Variable.
      -- Standard check of p_commit.
      --+
      -- Check if plan element name is missing or null even for Delete the Q Rule
      IF ((cn_api.chk_miss_char_para (p_char_para           => l_quota_rule.plan_element_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => l_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => l_quota_rule.plan_element_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => l_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check rev class name is not miss, not null
      IF ((cn_api.chk_miss_char_para (p_char_para           => l_quota_rule.revenue_class_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_rev_cls_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => l_quota_rule.revenue_class_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_rev_cls_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Get the Quota ID
      l_quota_rule.quota_id := cn_chk_plan_element_pkg.get_quota_id (l_quota_rule.plan_element_name, l_quota_rule.org_id);

      -- Raise an Error If quota id is null but name is not null
      IF l_quota_rule.quota_id IS NULL AND l_quota_rule.plan_element_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Get Revenue Class ID
      l_quota_rule.revenue_class_id := cn_api.get_rev_class_id (l_quota_rule.revenue_class_name, l_quota_rule.org_id);

      -- Raise an Error if the Revenue Class iD is Null and Name IS not NUll
      IF l_quota_rule.revenue_class_id IS NULL AND l_quota_rule.revenue_class_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Get the Quota Rule ID
      l_quota_rule.quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id (l_quota_rule.quota_id, l_quota_rule.revenue_class_id);

      IF l_old_name IS NOT NULL
      THEN
         l_old_revenue_class_id := cn_api.get_rev_class_id (l_old_name, l_quota_rule.org_id);

         IF l_old_revenue_class_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         l_old_quota_rule_id :=
                             cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id          => l_quota_rule.quota_id,
                                                                        p_rev_class_id      => l_old_revenue_class_id);

         IF l_old_quota_rule_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
               fnd_message.set_token ('PLAN_NAME', l_quota_rule.plan_element_name);
               fnd_message.set_token ('REVENUE_CLASS_NAME', l_old_name);
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- we are updating an existing rev assignment. Use the quota_rule_id
         l_quota_rule.quota_rule_id := l_old_quota_rule_id;
      END IF;

      IF l_quota_rule.quota_rule_id IS NOT NULL
      THEN
         x_loading_status := g_quota_rule_exists;
      ELSE
         x_loading_status := g_quota_rule_not_exists;
      END IF;

      -- Set the Default value for Payment Amount
      l_quota_rule.target := NVL (p_revenue_class_rec.rev_class_target, 0);
      -- Set the Default value for Payment Amount
      l_quota_rule.payment_amount := NVL (p_revenue_class_rec.rev_class_payment_amount, 0);
      -- Set the Default Value for Performance Goal
      l_quota_rule.performance_goal := NVL (p_revenue_class_rec.rev_class_performance_goal, 0);
      x_loading_status := 'CN_UPDATED';
      RETURN l_quota_rule;
   END convert_rev_class_user_input;


-- -------------------------------------------------------------------------+-+
--| Procedure:   add_system_note
--| Description: Insert notes for the create, update and delete
--| operations.
--| Called From: Create_quota_rule, Update_quota_rule
--| Delete_quota_rule
-- -------------------------------------------------------------------------+-+
   PROCEDURE add_system_note(
      p_quota_rule_old           IN OUT NOCOPY quota_rule_rec_type,
      p_quota_rule_new           IN OUT NOCOPY quota_rule_rec_type,
      p_operation                IN VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS

    l_note_msg VARCHAR2 (2000);
    l_plan_element_id NUMBER;
    l_note_id NUMBER;
    l_temp_old VARCHAR2 (200);
    l_temp_new VARCHAR2 (200);
    l_temp_rc_old VARCHAR2 (200);

   BEGIN
     -- Initialize to success
     x_return_status := fnd_api.g_ret_sts_success;
     -- Initialize other fields
     x_msg_data := fnd_api.g_null_char;
     x_msg_count := fnd_api.g_null_num;
     select name into l_temp_old from cn_quotas_v where quota_id = p_quota_rule_new.quota_id;
       IF (p_operation = 'create') THEN
         fnd_message.set_name('CN','CNR12_NOTE_PE_PROD_UPDATE');
         fnd_message.set_token('ELIG_PROD', p_quota_rule_new.revenue_class_name);
         fnd_message.set_token('PE_NAME', l_temp_old);
         l_plan_element_id := p_quota_rule_new.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'delete') THEN
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_ELIGPROD_DELETE');
         fnd_message.set_token('PROD', p_quota_rule_new.revenue_class_name);
         fnd_message.set_token('PE_NAME', l_temp_old);
         l_plan_element_id := p_quota_rule_new.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       IF (p_operation = 'update') THEN
         select NAME into l_temp_rc_old from cn_revenue_classes where
         revenue_class_id = p_quota_rule_old.revenue_class_id
         and org_id = p_quota_rule_old.org_id;
         fnd_message.set_name ('CN', 'CNR12_NOTE_PE_PROD_CHANGE');
         fnd_message.set_token('PROD_OLD', l_temp_rc_old);
         fnd_message.set_token('PROD_NEW', p_quota_rule_new.revenue_class_name);
         l_plan_element_id := p_quota_rule_new.quota_id;
         l_temp_new := 'CN_QUOTAS';
       END IF;
       l_note_msg := fnd_message.get;
       jtf_notes_pub.create_note
                    (p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data,
                     p_source_object_id        => l_plan_element_id,
                     p_source_object_code      => l_temp_new,
                     p_notes                   => l_note_msg,
                     p_notes_detail            => l_note_msg,
                     p_note_type               => 'CN_SYSGEN', -- for system generated
                     x_jtf_note_id             => l_note_id    -- returned
                     );

     EXCEPTION
       WHEN fnd_api.g_exc_error
       THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN fnd_api.g_exc_unexpected_error
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
       WHEN OTHERS
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, 'add_system_note');
         END IF;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);

   END add_system_note;





-- Start of comments
--      API name        : validate_quota_rule
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      p_old_quota_rule           IN       quota_rule_rec_type := g_quota_rule_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR quota_csr (
         c_quota_id                          NUMBER
      )
      IS
         SELECT quota_id,
                NAME,
                incentive_type_code,
                quota_type_code,
                org_id
           FROM cn_quotas
          WHERE quota_id = c_quota_id;

      CURSOR c_uplift_csr
      IS
      SELECT *
      FROM cn_quota_rule_uplifts
      WHERE quota_rule_id = p_quota_rule.quota_rule_id;

      l_rec                         quota_csr%ROWTYPE;
      l_uplift_rec                  c_uplift_csr%ROWTYPE;
      l_temp_count                  NUMBER;
      l_quota_id                    NUMBER;
      l_revenue_class_id            NUMBER;
      l_ret_val                     BOOLEAN;
      l_same_pe                     NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'validate_quota_rule';
      l_api_version        CONSTANT NUMBER := 1.0;
      checkif_parent_revclass       BOOLEAN := TRUE;
      l_loading_status              VARCHAR2 (2000);
      x_loading_status              varchar2(2000) ;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_quota_rule;

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

      -- init the return status
      x_return_status := fnd_api.g_ret_sts_success;

      -- revenue class cannot be null
      IF p_quota_rule.revenue_class_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('RC', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- quota_id cannot be null
      IF p_quota_rule.quota_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
            fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      BEGIN
         SELECT NAME
           INTO p_quota_rule.revenue_class_name
           FROM cn_revenue_classes_all
          WHERE revenue_class_id = p_quota_rule.revenue_class_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
      END;

      -- should only assign revenue class to these types
      OPEN quota_csr (p_quota_rule.quota_id);

      FETCH quota_csr
       INTO l_rec;

      IF quota_csr%NOTFOUND
      THEN
         fnd_message.set_name ('CN', 'CN_INVALID_DATA');
         fnd_message.set_token ('OBJ_NAME', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
         fnd_msg_pub.ADD;

         CLOSE quota_csr;

         RAISE fnd_api.g_exc_error;
      END IF;

      p_quota_rule.org_id := l_rec.org_id;

      CLOSE quota_csr;

      -- only the quota_rule_id is required for delete
      IF p_action = 'DELETE'
      THEN
         BEGIN
            SELECT quota_id,
                   revenue_class_id
              INTO p_quota_rule.quota_id,
                   p_quota_rule.revenue_class_id
              FROM cn_quota_rules
             WHERE quota_rule_id = p_quota_rule.quota_rule_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', '###CN_QUOTA_RULE_NOT_EXIST###');
                  fnd_message.set_token ('PLAN_NAME', p_quota_rule.quota_id);
                  fnd_message.set_token ('REVENUE_CLASS_NAME', p_quota_rule.revenue_class_name);
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
         END;

      ELSE
         -- target, payment_amount and performance_goal cannot be null or less than zero
         IF p_quota_rule.target < 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_TARGET_GT_ZERO');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- 1. name can not be null
         IF (p_quota_rule.target IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLES', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_quota_rule.payment_amount IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLES', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_quota_rule.org_id IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('ORGANIZATION', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_quota_rule.org_id <> l_rec.org_id)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INCONSISTENT_DATA');
               fnd_message.set_token ('INPUT1', cn_api.get_lkup_meaning ('ORGANIZATION', 'PE_OBJECT_TYPE'));
               fnd_message.set_token ('INPUT2', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
               fnd_message.set_token ('INPUT3', ' ');
               fnd_message.set_token ('INPUT4', ' ');
               fnd_message.set_token ('INPUT5', ' ');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF (p_quota_rule.performance_goal IS NULL)
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INPUT_CANT_NULL');
               fnd_message.set_token ('INPUT_NAME', cn_api.get_lkup_meaning ('VARIABLES', 'PE_OBJECT_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         IF l_rec.incentive_type_code NOT IN ('COMMISSION', 'BONUS')
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_CANNOT_HAVE_REV_CLASS');
               fnd_message.set_token ('OBJ_VALUE', 'MANUAL');
               fnd_message.set_token ('PLAN_TYPE', cn_api.get_lkup_meaning (l_rec.incentive_type_code, 'QUOTA_TYPE'));
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- create validations only
         IF p_action = 'CREATE'
         THEN
            -- 2. revenue class must be unique
            SELECT COUNT (1)
              INTO l_temp_count
              FROM cn_quota_rules
             WHERE quota_id = p_quota_rule.quota_id AND revenue_class_id = p_quota_rule.revenue_class_id AND ROWNUM = 1;
         -- update validations only
         ELSIF p_action = 'UPDATE'
         THEN
            -- check the object version number
            IF NVL (p_quota_rule.object_version_number, -1) <> p_old_quota_rule.object_version_number
            THEN
               fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;

            -- cannot change the planelement assignment of a quota_rule_assignment
            SELECT COUNT (*)
              INTO l_same_pe
              FROM cn_quota_rules qr
             WHERE qr.revenue_class_id = p_old_quota_rule.revenue_class_id
               AND qr.quota_id = p_quota_rule.quota_id
               AND qr.quota_rule_id = p_quota_rule.quota_rule_id;

            IF l_same_pe = 0
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_INCONSISTENT_DATA');
                  fnd_message.set_token ('INPUT1', cn_api.get_lkup_meaning ('RC_ASSIGN', 'PE_OBJECT_TYPE'));
                  fnd_message.set_token ('INPUT2', cn_api.get_lkup_meaning ('PE', 'INPUT_TOKEN'));
                  fnd_message.set_token ('INPUT3', cn_api.get_lkup_meaning ('RC', 'INPUT_TOKEN'));
                  fnd_message.set_token ('INPUT4', ' ');
                  fnd_message.set_token ('INPUT5', ' ');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

            -- check that
            OPEN  c_uplift_csr ;
            LOOP
               FETCH c_uplift_csr INTO l_uplift_rec;
               IF c_uplift_csr%NOTFOUND
               THEN
                  EXIT ;
               END IF;

               cn_chk_plan_element_pkg.chk_uplift_iud (x_return_status             => x_return_status,
                                                       p_start_date                => l_uplift_rec.start_date,
                                                       p_end_date                  => l_uplift_rec.end_date,
                                                       p_iud_flag                  => 'U',
                                                       p_quota_rule_id             => p_quota_rule.quota_rule_id,
                                                       p_quota_rule_uplift_id      => l_uplift_rec.quota_rule_uplift_id,
                                                       p_loading_status            => x_loading_status,
                                                       x_loading_status            => l_loading_status
                                                      );

                x_loading_status := l_loading_status;

                IF (x_return_status <> fnd_api.g_ret_sts_success)
                THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_INVALID_DATE_SEQUENCE');
                     fnd_msg_pub.ADD;
                  END IF;

                  x_loading_status := 'INVALID_DATE_SEQUENCE';
                  RAISE fnd_api.g_exc_error;
                END IF;
            END LOOP ;
            CLOSE c_uplift_csr;

            -- ensure that the transaction factors add up to 100
            cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                    p_quota_rule_id       => p_quota_rule.quota_rule_id,
                                                    p_rev_class_name      => p_quota_rule.revenue_class_name,
                                                    p_loading_status      => l_loading_status,
                                                    x_loading_status      => l_loading_status
                                                   );


            -- if updating and revenue class is not updated skip revclass hierarchy check
            checkif_parent_revclass := FALSE;

            -- revenue class must be unique
            SELECT COUNT (1)
              INTO l_temp_count
              FROM cn_quota_rules
             WHERE quota_id = p_quota_rule.quota_id
               AND revenue_class_id = p_quota_rule.revenue_class_id
               AND quota_rule_id <> p_quota_rule.quota_rule_id
               AND ROWNUM = 1;

         END IF;                                                                                                                      -- if update end

         IF l_temp_count <> 0
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_REV_EXIST');
               fnd_message.set_token ('PLAN_NAME', l_rec.NAME);
               fnd_message.set_token ('REVENUE_CLASS_NAME', p_quota_rule.revenue_class_name);
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         -- performance gain: do the hierarchy traversal after everything else is okay
         -- and only if there is a change
         IF checkif_parent_revclass
         THEN
            l_ret_val :=
               cn_quota_rules_pkg.check_rev_class_hier (x_revenue_class_id          => p_quota_rule.revenue_class_id,
                                                        x_revenue_class_id_old      => p_old_quota_rule.revenue_class_id,
                                                        x_quota_id                  => p_quota_rule.quota_id,
                                                        x_start_period_id           => NULL,
                                                        x_end_period_id             => NULL
                                                       );

            -- Validate Rule :
            --   Checks if p_quota_rule.rev_class_id is a parent in a hierarchy
            --   for any other p_quota_rule.rev_class_id already saved in the database
            --   for the p_quota_rule.quota_id
            IF (NOT l_ret_val)
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO validate_quota_rule;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO validate_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO validate_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END validate_quota_rule;

   -- Start of comments
--    API name        : Create_Quota_Rule
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_quota_rule         IN  quota_rule_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Quota_Rule';
      l_api_version        CONSTANT NUMBER := 1.0;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_quota_rule;

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

      -- get the primary key if you dont already have it
      IF p_quota_rule.quota_rule_id IS NULL
      THEN
         SELECT cn_quota_rules_s.NEXTVAL
           INTO p_quota_rule.quota_rule_id
           FROM DUAL;
      END IF;

      -- validate the record before inserting
      validate_quota_rule (p_api_version        => p_api_version,
                           p_quota_rule         => p_quota_rule,
                           p_action             => 'CREATE',
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data
                          );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- call table handler to insert data
      cn_quota_rules_pkg.begin_record (x_operation                  => 'INSERT',
                                       x_object_version_number      => p_quota_rule.object_version_number,
                                       x_quota_rule_id              => p_quota_rule.quota_rule_id,
                                       x_quota_id                   => p_quota_rule.quota_id,
                                       x_org_id                     => p_quota_rule.org_id,
                                       x_revenue_class_id           => p_quota_rule.revenue_class_id,
                                       x_revenue_class_name         => p_quota_rule.revenue_class_name,
                                       x_target                     => p_quota_rule.target,
                                       x_revenue_class_id_old       => NULL,
                                       x_target_old                 => NULL,
                                       x_payment_amount             => p_quota_rule.payment_amount,
                                       x_performance_goal           => p_quota_rule.performance_goal,
                                       x_last_update_date           => g_last_update_date,
                                       x_last_updated_by            => g_last_updated_by,
                                       x_creation_date              => g_creation_date,
                                       x_created_by                 => g_created_by,
                                       x_last_update_login          => g_last_update_login,
                                       x_program_type               => g_program_type,
                                       x_status_code                => NULL,
                                       x_payment_amount_old         => NULL,
                                       x_performance_goal_old       => NULL
                                      );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Calling proc to add system note for create
      add_system_note(
            p_quota_rule,
            p_quota_rule,
            'create',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

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
         ROLLBACK TO create_quota_rule;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_quota_rule;

-- Start of comments
--    API name        : Create_Quota_Rules
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_revenue_class_rec_tbl         IN  cn_plan_element_pub.revenue_class_rec_tbl_typ
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type := cn_plan_element_pub.g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Quota_Rules';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_revclass_rec                quota_rule_rec_type;
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
            l_revclass_rec :=
               convert_rev_class_user_input (p_quota_name             => p_quota_name,
                                             p_revenue_class_rec      => p_revenue_class_rec_tbl (i),
                                             x_loading_status         => x_loading_status
                                            );

            -- Check return status and insert if the status is CN_INSERTED
            -- then inser the Quota Rules, Insert the trx
            --ELSE Record Already exists, but Trx count > 0
            -- Update trx factors
            -- EXLSE Record Already Exists
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            IF (x_loading_status = g_quota_rule_not_exists)
            THEN
               -- call create_quota_rule
               cn_quota_rule_pvt.create_quota_rule (p_api_version           => p_api_version,
                                                    p_init_msg_list         => p_init_msg_list,
                                                    p_commit                => p_commit,
                                                    p_validation_level      => p_validation_level,
                                                    p_quota_rule            => l_revclass_rec,
                                                    x_return_status         => x_return_status,
                                                    x_msg_count             => x_msg_count,
                                                    x_msg_data              => x_msg_data
                                                   );

               IF (x_return_status <> fnd_api.g_ret_sts_success)
               THEN
                  x_loading_status := 'CN_UPDATE_FAILED';
                  RAISE fnd_api.g_exc_error;
               END IF;

               -- call create_trx_factors
               cn_trx_factor_pvt.update_trx_factors (p_api_version             => p_api_version,
                                                     p_init_msg_list           => p_init_msg_list,
                                                     p_commit                  => p_commit,
                                                     p_validation_level        => p_validation_level,
                                                     p_trx_factor_rec_tbl      => p_trx_factor_rec_tbl,
                                                     p_org_id                  => l_revclass_rec.org_id,
                                                     p_quota_name              => l_revclass_rec.plan_element_name,
                                                     p_revenue_class_name      => l_revclass_rec.revenue_class_name,
                                                     x_return_status           => x_return_status,
                                                     x_msg_count               => x_msg_count,
                                                     x_msg_data                => x_msg_data,
                                                     x_loading_status          => l_loading_status
                                                    );
               x_loading_status := l_loading_status;
            ELSIF (x_loading_status = g_quota_rule_exists)
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
               END IF;

               x_loading_status := 'PLN_QUOTA_REV_EXISTS';                                                                                     -- Case
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
         ROLLBACK TO create_quota_rules;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_quota_rules;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_quota_rules;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_quota_rules;

   -- Start of comments
--      API name        : Update_Quota_Rule
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Quota_Rule';
      l_api_version        CONSTANT NUMBER := 1.0;

      CURSOR l_old_quota_rule_cr
      IS
         SELECT *
           FROM cn_quota_rules
          WHERE quota_rule_id = p_quota_rule.quota_rule_id;

      l_old_quota_rule              l_old_quota_rule_cr%ROWTYPE;
      l_old_rec                     quota_rule_rec_type;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_quota_rule;

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

      -- API body
      OPEN l_old_quota_rule_cr;

      FETCH l_old_quota_rule_cr
       INTO l_old_quota_rule;

      CLOSE l_old_quota_rule_cr;

      l_old_rec.quota_rule_id := l_old_quota_rule.quota_rule_id;
      l_old_rec.revenue_class_name := l_old_quota_rule.NAME;
      l_old_rec.revenue_class_id := l_old_quota_rule.revenue_class_id;
      l_old_rec.quota_id := l_old_quota_rule.quota_id;
      l_old_rec.description := l_old_quota_rule.description;
      l_old_rec.target := l_old_quota_rule.target;
      l_old_rec.payment_amount := l_old_quota_rule.payment_amount;
      l_old_rec.performance_goal := l_old_quota_rule.performance_goal;
      l_old_rec.object_version_number := l_old_quota_rule.object_version_number;
      l_old_rec.org_id := l_old_quota_rule.org_id;
      -- validate this update
      validate_quota_rule (p_api_version         => p_api_version,
                           p_quota_rule          => p_quota_rule,
                           p_old_quota_rule      => l_old_rec,
                           p_action              => 'UPDATE',
                           x_return_status       => x_return_status,
                           x_msg_count           => x_msg_count,
                           x_msg_data            => x_msg_data
                          );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- update table using the handler
      cn_quota_rules_pkg.begin_record (x_operation                  => 'UPDATE',
                                       x_object_version_number      => p_quota_rule.object_version_number,
                                       x_quota_rule_id              => p_quota_rule.quota_rule_id,
                                       x_quota_id                   => p_quota_rule.quota_id,
                                       x_org_id                     => p_quota_rule.org_id,
                                       x_revenue_class_id           => p_quota_rule.revenue_class_id,
                                       x_revenue_class_name         => p_quota_rule.revenue_class_name,
                                       x_target                     => p_quota_rule.target,
                                       x_payment_amount             => p_quota_rule.payment_amount,
                                       x_performance_goal           => p_quota_rule.performance_goal,
                                       x_revenue_class_id_old       => l_old_rec.revenue_class_id,
                                       x_target_old                 => l_old_rec.target,
                                       x_last_update_date           => g_last_update_date,
                                       x_last_updated_by            => g_last_updated_by,
                                       x_creation_date              => l_old_quota_rule.creation_date,
                                       x_created_by                 => l_old_quota_rule.created_by,
                                       x_last_update_login          => g_last_update_login,
                                       x_program_type               => g_program_type,
                                       x_status_code                => NULL,
                                       x_payment_amount_old         => NULL,
                                       x_performance_goal_old       => NULL
                                      );

      -- Calling proc to add system note for update
      IF (l_old_rec.revenue_class_id <> p_quota_rule.revenue_class_id) THEN
        add_system_note(
              l_old_rec,
              p_quota_rule,
              'update',
              x_return_status,
              x_msg_count,
              x_msg_data
              );
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;


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
         ROLLBACK TO update_quota_rule;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_quota_rule;

--|-------------------------------------------------------------------------+
--|  Procedure Name: Update_Quota_Rules
--| Descr: Update a Quota Rules
--|-------------------------------------------------------------------------+
   PROCEDURE update_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Quota_Rules';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_revclass_rec                quota_rule_rec_type;
      l_quota_rule_id               NUMBER;
      l_rev_class_id_old            NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT update_quota_rules;

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
            l_revclass_rec :=
               convert_rev_class_user_input (p_quota_name                  => p_quota_name,
                                             p_revenue_class_rec           => p_revenue_class_rec_tbl (i),
                                             p_old_revenue_class_name      => p_revenue_class_rec_tbl (i).rev_class_name_old,
                                             x_loading_status              => l_loading_status
                                            );
            x_loading_status := l_loading_status;

            IF (x_loading_status = g_quota_rule_exists)
            THEN
               cn_quota_rule_pvt.update_quota_rule (p_api_version           => p_api_version,
                                                    p_init_msg_list         => p_init_msg_list,
                                                    p_commit                => p_commit,
                                                    p_validation_level      => p_validation_level,
                                                    p_quota_rule            => l_revclass_rec,
                                                    x_return_status         => x_return_status,
                                                    x_msg_count             => x_msg_count,
                                                    x_msg_data              => x_msg_data
                                                   );
               x_loading_status := 'CN_UPDATED';

               IF (x_return_status <> fnd_api.g_ret_sts_success)
               THEN
                  x_loading_status := 'CN_UPDATE_FAILED';
                  RAISE fnd_api.g_exc_error;
               END IF;

               cn_trx_factor_pvt.update_trx_factors (p_api_version             => p_api_version,
                                                     p_init_msg_list           => p_init_msg_list,
                                                     p_commit                  => p_commit,
                                                     p_validation_level        => p_validation_level,
                                                     p_trx_factor_rec_tbl      => p_trx_factor_rec_tbl,
                                                     p_org_id                  => l_revclass_rec.org_id,
                                                     p_quota_name              => l_revclass_rec.plan_element_name,
                                                     p_revenue_class_name      => l_revclass_rec.revenue_class_name,
                                                     x_return_status           => x_return_status,
                                                     x_msg_count               => x_msg_count,
                                                     x_msg_data                => x_msg_data,
                                                     x_loading_status          => l_loading_status
                                                    );
               x_loading_status := l_loading_status;

               IF (x_return_status <> fnd_api.g_ret_sts_success)
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSIF x_loading_status = g_quota_rule_exists
            THEN
               IF (p_trx_factor_rec_tbl.COUNT = 0 AND p_revenue_class_rec_tbl.COUNT = 0)
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               x_loading_status := 'PLN_QUOTA_REV_EXISTS';
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
         ROLLBACK TO update_quota_rules;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_quota_rules;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_quota_rules;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_quota_rules;

   -- Start of comments
--      API name        : Delete_Quota_Rule
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Quota_Rule';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_quota_id                    NUMBER;
      l_revenue_class_id            NUMBER;
      l_quota_name                  cn_quotas.NAME%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_quota_rule;

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
      -- API body
      validate_quota_rule (p_api_version        => p_api_version,
                           p_quota_rule         => p_quota_rule,
                           p_action             => 'DELETE',
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data
                          );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Delete Record;
      cn_quota_rules_pkg.DELETE_RECORD (x_quota_id              => p_quota_rule.quota_id,
                                        x_quota_rule_id         => p_quota_rule.quota_rule_id,
                                        x_revenue_class_id      => p_quota_rule.revenue_class_id
                                       );

      -- Calling proc to add system note for delete
      add_system_note(
            p_quota_rule,
            p_quota_rule,
            'delete',
            x_return_status,
            x_msg_count,
            x_msg_data
            );
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

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
         ROLLBACK TO delete_quota_rule;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_quota_rule;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_quota_rule;

--|-------------------------------------------------------------------------+
--|  Procedure Name: Delete_Quota_Rules
--| Descr: Delete a Quota Rules
--|-------------------------------------------------------------------------+
   PROCEDURE delete_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_loading_status              VARCHAR2 (80);
      l_rec                         quota_rule_rec_type;
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

      -- Loop Through Each Record and Delete IT
      IF p_revenue_class_rec_tbl.COUNT > 0
      THEN
         FOR i IN 1 .. p_revenue_class_rec_tbl.COUNT
         LOOP
            l_rec :=
               convert_rev_class_user_input (p_quota_name             => p_quota_name,
                                             p_revenue_class_rec      => p_revenue_class_rec_tbl (i),
                                             x_loading_status         => x_loading_status
                                            );
            -- call the private api
            cn_quota_rule_pvt.delete_quota_rule (p_api_version           => p_api_version,
                                                 p_init_msg_list         => p_init_msg_list,
                                                 p_commit                => p_commit,
                                                 p_validation_level      => p_validation_level,
                                                 p_quota_rule            => l_rec,
                                                 x_return_status         => x_return_status,
                                                 x_msg_count             => x_msg_count,
                                                 x_msg_data              => x_msg_data
                                                );

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               x_loading_status := 'QUOTA_RULE_DELETE_FAILED';
               RAISE fnd_api.g_exc_error;
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
END cn_quota_rule_pvt;

/
