--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_UPLIFTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_UPLIFTS_GRP" AS
/* $Header: cnxgqrub.pls 120.5 2007/08/10 20:40:34 rnagired ship $ */
   g_pkg_name           CONSTANT VARCHAR2 (50) := 'CN_QUOTA_RULES_UPLIFTS_GRP';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnxgqrub.pls';
   g_program_type                VARCHAR2 (30);

/* ****************** */
/* ADDED - SBADAMI    */
/* ****************** */
-- API name    : check_status
-- Type        : Private
-- Pre-reqs    : None.
-- Function    : Raises error based on different statuses
-- Parameters  :
-- IN          :  p_return_status IN VARCHAR2   Required
-- Version     :  Initial version   1.0
-- End of comments
   PROCEDURE check_status (
      p_return_status            IN       VARCHAR2
   )
   IS
   BEGIN
      IF p_return_status = fnd_api.g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF p_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END;

-- ----------------------------------------------------------------------------+
-- Function : convert_pe_user_input
-- Desc     : function to trim all blank spaces of user input
--            Assign defalut value if input is missing
-- ----------------------------------------------------------------------------+
   FUNCTION convert_rev_uplift_user_input (
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec           IN       cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN cn_chk_plan_element_pkg.pe_rec_type
   IS
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec;
      l_name                        VARCHAR2 (2000);
      l_ret_val boolean := false;
   BEGIN

      -- Check if Org Id given correctly or not
      l_ret_val := CN_OU_UTIL_PVT.is_valid_org(p_org_id => p_rev_uplift_rec.org_id);

      -- First make sure you have an org_id to drive all searches
      cn_chk_plan_element_pkg.validate_org_id (p_rev_uplift_rec.org_id);
      l_pe_rec.org_id := p_rev_uplift_rec.org_id;
      -- Convert the User Input.
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- Removing leading and trailing blanks
      l_pe_rec.NAME := LTRIM (RTRIM (p_quota_name));
      l_pe_rec.rev_class_name := LTRIM (RTRIM (p_rev_uplift_rec.rev_class_name));
      l_pe_rec.rev_uplift_start_date := p_rev_uplift_rec.start_date;
      l_pe_rec.rev_uplift_end_date := p_rev_uplift_rec.end_date;
      -- Get the Revenue Class Id
      l_pe_rec.rev_class_id := cn_api.get_rev_class_id (l_pe_rec.rev_class_name, p_rev_uplift_rec.org_id);
      -- Get the Quota Id
      l_pe_rec.quota_id := cn_chk_plan_element_pkg.get_quota_id (l_pe_rec.NAME, l_pe_rec.org_id);
      -- Get the Quota Rule Id
      l_pe_rec.quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id => l_pe_rec.quota_id, p_rev_class_id => l_pe_rec.rev_class_id);

      -- Set the Payment Uplift Factor if the Input value is Null or G_MISS_NUM
      -- Set the Quota Uplift Factor if the Input value is Null or G_MISS_NUM
      -- Combined the two queries
      SELECT DECODE (p_rev_uplift_rec.payment_factor, fnd_api.g_miss_num, 100, NULL, 100, p_rev_uplift_rec.payment_factor),
             DECODE (p_rev_uplift_rec.quota_factor, fnd_api.g_miss_num, 100, NULL, 100, p_rev_uplift_rec.quota_factor)
        INTO l_pe_rec.rev_class_payment_uplift,
             l_pe_rec.rev_class_quota_uplift
        FROM SYS.DUAL;

      RETURN l_pe_rec;
   END convert_rev_uplift_user_input;

-- ----------------------------------------------------------------------------+
-- Procedure: valid_quota_rule_uplifts
-- Desc     : Validate the Quto Rules uplift  Input Parameters like
-- Revenue Class Name,
-- Plan Element Name.
-- ----------------------------------------------------------------------------+
   PROCEDURE valid_quota_rule_uplift (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_quota_rule_uplift_id     IN       NUMBER,
      p_rev_class_name_old       IN       VARCHAR2,
      p_start_date_old           IN       DATE,
      p_end_date_old             IN       DATE,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'valid_quota_Rule_uplifts';
      l_same_pe                     NUMBER;
      l_end_date                    DATE;

      CURSOR quota_rule_uplifts_seq_curs (
         p_quota_rule_id                     NUMBER
      )
      IS
         SELECT   end_date
             FROM cn_quota_rule_uplifts
            WHERE quota_rule_id = p_quota_rule_id
         ORDER BY start_date DESC;

      l_date_msg                    VARCHAR2 (100);
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- API body
      -- check for required data in Plan Element Name
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

      --+
      -- Check Valid Plan Element Name
      --+
      IF p_pe_rec.NAME IS NOT NULL AND p_pe_rec.quota_id IS NULL
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', p_pe_rec.NAME);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'PLN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check Revenue Class name is null or miss char
      --+
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
      -- Check Valid Revenue Class Name
      --+
      IF p_pe_rec.rev_class_name IS NOT NULL AND p_pe_rec.rev_class_id IS NULL
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'REV_CLASS_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check Start Date  can not be missing or NULL
      --+
      IF ((cn_chk_plan_element_pkg.chk_miss_date_para (p_date_para           => p_pe_rec.rev_uplift_start_date,
                                                       p_para_name           => cn_chk_plan_element_pkg.g_uplift_start_date,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_chk_plan_element_pkg.chk_null_date_para (p_date_para           => p_pe_rec.rev_uplift_start_date,
                                                          p_obj_name            => cn_chk_plan_element_pkg.g_uplift_start_date,
                                                          p_loading_status      => x_loading_status,
                                                          x_loading_status      => l_loading_status
                                                         )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check End Date must be Grater than Start Date
      --+
      IF p_pe_rec.rev_uplift_end_date IS NOT NULL
      THEN
         IF (TRUNC (p_pe_rec.rev_uplift_end_date) < TRUNC (p_pe_rec.rev_uplift_start_date))
         THEN
            -- Error, check the msg level and add an error message to the
            -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_DATE_RANGE');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'INVALID_DATE_RANGE';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --+
      -- Check payment Uplift
      --+
      IF (cn_api.chk_miss_num_para (p_num_para            => p_pe_rec.rev_class_payment_uplift,
                                    p_para_name           => cn_chk_plan_element_pkg.g_uplift_payment_factor,
                                    p_loading_status      => x_loading_status,
                                    x_loading_status      => l_loading_status
                                   ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_num_para (p_num_para            => p_pe_rec.rev_class_payment_uplift,
                                        p_obj_name            => cn_chk_plan_element_pkg.g_uplift_payment_factor,
                                        p_loading_status      => x_loading_status,
                                        x_loading_status      => l_loading_status
                                       )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check Quota Uplift
      --+
      IF (cn_api.chk_miss_num_para (p_num_para            => p_pe_rec.rev_class_quota_uplift,
                                    p_para_name           => cn_chk_plan_element_pkg.g_uplift_quota_factor,
                                    p_loading_status      => x_loading_status,
                                    x_loading_status      => l_loading_status
                                   ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_num_para (p_num_para            => p_pe_rec.rev_class_quota_uplift,
                                        p_obj_name            => cn_chk_plan_element_pkg.g_uplift_quota_factor,
                                        p_loading_status      => x_loading_status,
                                        x_loading_status      => l_loading_status
                                       )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check for Duplicate Record for the Same Quota Rule with the same start date and end Date.
      -- Duplicate check in update has been taken care in the other place .
      IF p_rev_class_name_old IS NULL AND p_start_date_old IS NULL
      THEN
         SELECT COUNT (*)
           INTO l_same_pe
           FROM cn_quota_rule_uplifts qru
          WHERE qru.quota_rule_id = p_pe_rec.quota_rule_id
            AND TRUNC (qru.start_date) = TRUNC (p_pe_rec.rev_uplift_start_date)
            AND qru.quota_rule_uplift_id <> NVL (p_quota_rule_uplift_id, 0);

         IF l_same_pe <> 0
         THEN
            IF p_pe_rec.rev_uplift_end_date IS NOT NULL
            THEN
               l_date_msg := p_pe_rec.rev_uplift_start_date || '; End Date: ' || p_pe_rec.rev_uplift_end_date;
            ELSE
               l_date_msg := p_pe_rec.rev_uplift_start_date;
            END IF;

            -- Error, check the msg level and add an error message to the
            -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_QUOTA_UPLIFT_EXISTS');
               fnd_message.set_token ('PLAN_NAME', p_pe_rec.NAME);
               fnd_message.set_token ('REVENUE_CLASS_NAME', p_pe_rec.rev_class_name);
               fnd_message.set_token ('START_DATE', l_date_msg);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'QUOTA_UPLIFT_EXISTS';
            RETURN;
         END IF;
      END IF;

      --+
      -- Check date Effectivity
      --+
      cn_chk_plan_element_pkg.chk_date_effective (x_return_status       => x_return_status,
                                                  p_start_date          => p_pe_rec.rev_uplift_start_date,
                                                  p_end_date            => p_pe_rec.rev_uplift_end_date,
                                                  p_quota_id            => p_pe_rec.quota_id,
                                                  p_object_type         => 'UPLIFT',
                                                  p_loading_status      => x_loading_status,
                                                  x_loading_status      => l_loading_status
                                                 );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
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
   END valid_quota_rule_uplift;

-- ----------------------------------------------------------------------------+
-- Procedure: Check Valid Update
-- Desc     :This procedure is called from update Quota Rule Uplifts.
--          Additional validation During Update
--          Called from UPDATE_QUOTA_RULE_UPLIFTS
-- ----------------------------------------------------------------------------+
   PROCEDURE check_valid_update (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_class_name_old       IN       VARCHAR2,
      p_start_date_old           IN       DATE,
      p_end_date_old             IN       DATE,
      p_new_pe_rec               IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      x_quota_rule_uplift_id     OUT NOCOPY NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Valid_Update';
      l_same_pe                     NUMBER;
      l_rev_class_id_old            NUMBER;
      l_quota_rule_id_old           NUMBER;
      l_quota_rule_uplift_id_old    NUMBER;
      l_date_msg                    VARCHAR2 (100);
      l_loading_status              VARCHAR2 (80);
      l_org_id                      NUMBER;
   BEGIN
      --+
      --  Initialize API return status to success
      --+
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      --+
      -- Get revenue Class ID
      --+
      l_rev_class_id_old := cn_api.get_rev_class_id (p_rev_class_name_old, p_new_pe_rec.org_id);
      --+
      -- Get quota rule ID
      -- +
      l_quota_rule_id_old := cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id => p_new_pe_rec.quota_id, p_rev_class_id => l_rev_class_id_old);

      --   +
      -- Check the old revenue class name is not null or miss char
      --+
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_rev_class_name_old,
                                      p_para_name           => cn_chk_plan_element_pkg.g_rev_cls_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_rev_class_name_old,
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
      -- Check Old Start Date  cannot be missing or NULL
      --+
      IF ((cn_chk_plan_element_pkg.chk_miss_date_para (p_date_para           => p_start_date_old,
                                                       p_para_name           => cn_chk_plan_element_pkg.g_uplift_start_date,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_chk_plan_element_pkg.chk_null_date_para (p_date_para           => p_start_date_old,
                                                          p_obj_name            => cn_chk_plan_element_pkg.g_uplift_start_date,
                                                          p_loading_status      => x_loading_status,
                                                          x_loading_status      => l_loading_status
                                                         )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check the passed revenue class name is exists in the database
      --+
      IF p_rev_class_name_old IS NOT NULL AND l_rev_class_id_old IS NULL
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'REV_CLASS_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      --+
      -- Check the quota rule uplift id  if the New Quota rule is exists.
      --+
      x_quota_rule_uplift_id :=
         cn_chk_plan_element_pkg.get_quota_rule_uplift_id (p_new_pe_rec.quota_rule_id,
                                                           p_new_pe_rec.rev_uplift_start_date,
                                                           p_new_pe_rec.rev_uplift_end_date
                                                          );
      --+
      -- get the Quota Rule Uplift id using the Old values
      --+
      l_quota_rule_uplift_id_old := cn_chk_plan_element_pkg.get_quota_rule_uplift_id (l_quota_rule_id_old, p_start_date_old, p_end_date_old);

      -- Error message if the Quota Rule Uplift Does Not exists in the Database
      IF l_quota_rule_uplift_id_old IS NULL
      THEN
         IF p_end_date_old IS NOT NULL
         THEN
            l_date_msg := p_start_date_old || ' and end date ' || p_end_date_old;
         ELSE
            l_date_msg := p_start_date_old;
         END IF;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_UPLIFT_NOT_EXIST');
            fnd_message.set_token ('PLAN_NAME', p_quota_name);
            fnd_message.set_token ('REVENUE_CLASS_NAME', p_rev_class_name_old);
            fnd_message.set_token ('START_DATE', l_date_msg);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_RULE_UPLIFT_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Chances for duplicate record in the database is
      -- case 1 if the old quota rule id
      IF x_quota_rule_uplift_id IS NOT NULL AND x_quota_rule_uplift_id <> l_quota_rule_uplift_id_old
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_UPLIFT_EXISTS');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_UPLIFT_EXISTS';
         RAISE fnd_api.g_exc_error;
      ELSE
         x_quota_rule_uplift_id := l_quota_rule_uplift_id_old;
      END IF;

      --+
      -- Call the Default validation, it has to pass all the rules
      --+
      valid_quota_rule_uplift (x_return_status             => x_return_status,
                               x_msg_count                 => x_msg_count,
                               x_msg_data                  => x_msg_data,
                               p_pe_rec                    => p_new_pe_rec,
                               p_quota_rule_uplift_id      => l_quota_rule_uplift_id_old,
                               p_rev_class_name_old        => p_rev_class_name_old,
                               p_start_date_old            => p_start_date_old,
                               p_end_date_old              => p_end_date_old,
                               p_loading_status            => x_loading_status,
                               x_loading_status            => l_loading_status
                              );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body.
      -- Standard call to get message count and if count is 1, get message info.
      --+
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

-- ----------------------------------------------------------------------------+
--
--  Procedure Name: Create_Quota_Rule_uplift
--
-- ----------------------------------------------------------------------------+
   PROCEDURE create_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Quota_Rule_uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type;
      --l_quota_rule_uplift_id        NUMBER;
      l_uplift_date_seq_rec_tbl     uplift_date_seq_rec_tbl_type;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT create_quota_rule_uplift;

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
      IF (p_rev_uplift_rec_tbl.COUNT <> 0)
      THEN
         FOR i IN p_rev_uplift_rec_tbl.FIRST .. p_rev_uplift_rec_tbl.LAST
         LOOP
            l_pe_rec :=
               convert_rev_uplift_user_input (p_quota_name          => p_quota_name,
                                              p_rev_uplift_rec      => p_rev_uplift_rec_tbl (i),
                                              x_return_status       => x_return_status,
                                              p_loading_status      => x_loading_status,
                                              x_loading_status      => l_loading_status
                                             );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            --+
            -- Validate the quota rule uplifts.
            --+
            valid_quota_rule_uplift (x_return_status             => x_return_status,
                                     x_msg_count                 => x_msg_count,
                                     x_msg_data                  => x_msg_data,
                                     p_pe_rec                    => l_pe_rec,
                                     p_quota_rule_uplift_id      => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
                                     p_rev_class_name_old        => NULL,
                                     p_start_date_old            => NULL,
                                     p_end_date_old              => NULL,
                                     p_loading_status            => x_loading_status,
                                     x_loading_status            => l_loading_status
                                    );
            x_loading_status := l_loading_status;

            -- raise error is status <> success
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_loading_status <> 'QUOTA_UPLIFT_EXISTS'
            THEN
               cn_quota_rule_uplifts_pkg.begin_record (x_operation                  => 'INSERT',
                                                       x_org_id                     => l_pe_rec.org_id,
                                                       x_quota_rule_uplift_id       => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
                                                       x_quota_rule_id              => l_pe_rec.quota_rule_id,
                                                       x_quota_rule_id_old          => l_pe_rec.quota_rule_id,
                                                       x_start_date                 => l_pe_rec.rev_uplift_start_date,
                                                       x_start_date_old             => l_pe_rec.rev_uplift_start_date,
                                                       x_end_date                   => l_pe_rec.rev_uplift_end_date,
                                                       x_end_date_old               => l_pe_rec.rev_uplift_end_date,
                                                       x_payment_factor             => l_pe_rec.rev_class_payment_uplift,
                                                       x_payment_factor_old         => l_pe_rec.rev_class_payment_uplift,
                                                       x_quota_factor               => l_pe_rec.rev_class_quota_uplift,
                                                       x_quota_factor_old           => l_pe_rec.rev_class_quota_uplift,
                                                       x_last_updated_by            => fnd_global.user_id,
                                                       x_creation_date              => SYSDATE,
                                                       x_created_by                 => fnd_global.user_id,
                                                       x_last_update_login          => fnd_global.login_id,
                                                       x_last_update_date           => SYSDATE,
                                                       x_program_type               => g_program_type,
                                                       x_status_code                => NULL,
                                                       x_object_version_number      => p_rev_uplift_rec_tbl (i).object_version_number
                                                      );
               l_uplift_date_seq_rec_tbl (i).start_date := l_pe_rec.rev_uplift_start_date;
               l_uplift_date_seq_rec_tbl (i).start_date_old := p_rev_uplift_rec_tbl (i).start_date_old;
               l_uplift_date_seq_rec_tbl (i).end_date := l_pe_rec.rev_uplift_end_date;
               l_uplift_date_seq_rec_tbl (i).end_date_old := p_rev_uplift_rec_tbl (i).end_date_old;
               l_uplift_date_seq_rec_tbl (i).quota_rule_id := l_pe_rec.quota_rule_id;
               l_uplift_date_seq_rec_tbl (i).quota_rule_uplift_id := p_rev_uplift_rec_tbl (i).quota_rule_uplift_id;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;

         -- We need to check one level After than
         --   +
         -- Check the Sequence, are there any records exists before this
         -- record, if exists it should be
         --+
       --  FOR i IN 1 .. l_uplift_date_seq_rec_tbl.COUNT
       --  LOOP
       FOR i IN l_uplift_date_seq_rec_tbl.FIRST..l_uplift_date_seq_rec_tbl.LAST LOOP
            IF ((   TRUNC (l_uplift_date_seq_rec_tbl (i).start_date_old) <> TRUNC (l_uplift_date_seq_rec_tbl (i).start_date)
                 OR NVL (TRUNC (l_uplift_date_seq_rec_tbl (i).end_date_old), fnd_api.g_miss_date) <>
                                                                             NVL (TRUNC (l_uplift_date_seq_rec_tbl (i).end_date), fnd_api.g_miss_date)
                )
               )
            THEN
               cn_chk_plan_element_pkg.chk_uplift_iud (x_return_status             => x_return_status,
                                                       p_start_date                => l_uplift_date_seq_rec_tbl (i).start_date,
                                                       p_end_date                  => l_uplift_date_seq_rec_tbl (i).end_date,
                                                       p_iud_flag                  => 'I',
                                                       p_quota_rule_id             => l_pe_rec.quota_rule_id,
                                                       p_quota_rule_uplift_id      => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
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

                  x_loading_status := 'CN_UPLIFT_UPDATE_NOT_ALLOWED';
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
         END LOOP;
      END IF;                                                                                                               -- Table Count is Not Zero

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      <<end_api_body>>
      NULL;
      --+
      -- Standard call to get message count and if count is 1, get message info.
      --+
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_quota_rule_uplift;

-- ----------------------------------------------------------------------------+
--
--  Procedure Name: Update_Quota_Rule_uplift
--
-- ----------------------------------------------------------------------------+
   PROCEDURE update_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Quota_Rule_uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type;
      --l_quota_rule_uplift_id        NUMBER;
      l_uplift_date_seq_rec_tbl     uplift_date_seq_rec_tbl_type;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --
      -- Standard Start of API savepoint
      -- +
      SAVEPOINT update_quota_rule_uplift;

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
      IF (p_rev_uplift_rec_tbl.COUNT <> 0)
      THEN
         -- Loop through each record
         FOR i IN p_rev_uplift_rec_tbl.FIRST .. p_rev_uplift_rec_tbl.LAST
         LOOP
            -- Convert each record in the local variable
            l_pe_rec :=
               convert_rev_uplift_user_input (p_quota_name          => p_quota_name,
                                              p_rev_uplift_rec      => p_rev_uplift_rec_tbl (i),
                                              x_return_status       => x_return_status,
                                              p_loading_status      => x_loading_status,
                                              x_loading_status      => l_loading_status
                                             );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            --validate
            check_valid_update (x_return_status             => x_return_status,
                                x_msg_count                 => x_msg_count,
                                x_msg_data                  => x_msg_data,
                                p_quota_name                => p_quota_name,
                                p_rev_class_name_old        => p_rev_uplift_rec_tbl (i).rev_class_name_old,
                                p_start_date_old            => p_rev_uplift_rec_tbl (i).start_date_old,
                                p_end_date_old              => p_rev_uplift_rec_tbl (i).end_date_old,
                                p_new_pe_rec                => l_pe_rec,
                                x_quota_rule_uplift_id      => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
                                p_loading_status            => x_loading_status,
                                x_loading_status            => l_loading_status
                               );
            x_loading_status := l_loading_status;

                 -- If not success the Raise error
            -- if PLN_QUOTA_UPLIFT_EXISTS
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_loading_status = 'CN_UPDATED'
            THEN
               cn_quota_rule_uplifts_pkg.begin_record (x_operation                  => 'UPDATE',
                                                       x_org_id                     => l_pe_rec.org_id,
                                                       x_quota_rule_uplift_id       => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
                                                       x_quota_rule_id              => l_pe_rec.quota_rule_id,
                                                       x_quota_rule_id_old          => l_pe_rec.quota_rule_id,
                                                       x_start_date                 => l_pe_rec.rev_uplift_start_date,
                                                       x_start_date_old             => l_pe_rec.rev_uplift_start_date,
                                                       x_end_date                   => l_pe_rec.rev_uplift_end_date,
                                                       x_end_date_old               => l_pe_rec.rev_uplift_end_date,
                                                       x_payment_factor             => l_pe_rec.rev_class_payment_uplift,
                                                       x_payment_factor_old         => l_pe_rec.rev_class_payment_uplift,
                                                       x_quota_factor               => l_pe_rec.rev_class_quota_uplift,
                                                       x_quota_factor_old           => l_pe_rec.rev_class_quota_uplift,
                                                       x_last_updated_by            => fnd_global.user_id,
                                                       x_creation_date              => SYSDATE,
                                                       x_created_by                 => fnd_global.user_id,
                                                       x_last_update_login          => fnd_global.login_id,
                                                       x_last_update_date           => SYSDATE,
                                                       x_program_type               => g_program_type,
                                                       x_status_code                => NULL,
                                                       x_object_version_number      => p_rev_uplift_rec_tbl (i).object_version_number
                                                      );
               l_uplift_date_seq_rec_tbl (i).start_date := l_pe_rec.rev_uplift_start_date;
               l_uplift_date_seq_rec_tbl (i).start_date_old := p_rev_uplift_rec_tbl (i).start_date_old;
               l_uplift_date_seq_rec_tbl (i).end_date := l_pe_rec.rev_uplift_end_date;
               l_uplift_date_seq_rec_tbl (i).end_date_old := p_rev_uplift_rec_tbl (i).end_date_old;
               l_uplift_date_seq_rec_tbl (i).quota_rule_id := l_pe_rec.quota_rule_id;
               l_uplift_date_seq_rec_tbl (i).quota_rule_uplift_id := p_rev_uplift_rec_tbl (i).quota_rule_uplift_id;
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;

         FOR i IN 1 .. l_uplift_date_seq_rec_tbl.COUNT
         LOOP
            IF ((   TRUNC (l_uplift_date_seq_rec_tbl (i).start_date_old) <> TRUNC (l_uplift_date_seq_rec_tbl (i).start_date)
                 OR NVL (TRUNC (l_uplift_date_seq_rec_tbl (i).end_date_old), fnd_api.g_miss_date) <>
                                                                             NVL (TRUNC (l_uplift_date_seq_rec_tbl (i).end_date), fnd_api.g_miss_date)
                )
               )
            THEN
               /*
                cn_chk_plan_element_pkg.chk_uplift_iud (x_return_status             => x_return_status,
                                                        p_start_date                => l_uplift_date_seq_rec_tbl (i).start_date,
                                                        p_end_date                  => l_uplift_date_seq_rec_tbl (i).end_date,
                                                        p_iud_flag                  => 'U',
                                                        p_quota_rule_id             => l_pe_rec.quota_rule_id,
                                                        p_quota_rule_uplift_id      => p_rev_uplift_rec_tbl (i).quota_rule_uplift_id,
                                                        p_loading_status            => x_loading_status,
                                                        x_loading_status            => l_loading_status
                                                       );
                x_loading_status := l_loading_status;
               */
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
            END IF;
         END LOOP;
      END IF;                                                                                                               -- Table Count is Not Zero

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
         ROLLBACK TO update_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_quota_rule_uplift;

-- ----------------------------------------------------------------------------+
--
--  Procedure Name: Delete_Quota_Rule_uplift
--
-- ----------------------------------------------------------------------------+
   PROCEDURE delete_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Quota_rule_uplift';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_quota_rule_uplift_id        NUMBER;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type;
      l_date_msg                    VARCHAR2 (100);
      l_loading_status              VARCHAR2 (80);
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_quota_rule_uplift;

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
      IF (p_rev_uplift_rec_tbl.COUNT <> 0)
      THEN
         -- Loop through each record we get from the Procedure call
         FOR i IN p_rev_uplift_rec_tbl.FIRST .. p_rev_uplift_rec_tbl.LAST
         LOOP
            -- Convert each record in the local variable with more necessary things.
            l_pe_rec :=
               convert_rev_uplift_user_input (p_quota_name          => p_quota_name,
                                              p_rev_uplift_rec      => p_rev_uplift_rec_tbl (i),
                                              x_return_status       => x_return_status,
                                              p_loading_status      => x_loading_status,
                                              x_loading_status      => l_loading_status
                                             );
            x_loading_status := l_loading_status;
            -- get Quota Rule Uplift ID
            l_quota_rule_uplift_id :=
               cn_chk_plan_element_pkg.get_quota_rule_uplift_id (l_pe_rec.quota_rule_id, l_pe_rec.rev_uplift_start_date, l_pe_rec.rev_uplift_end_date);

            -- if the Quota Rule uplift iD is null then Error message
            IF l_quota_rule_uplift_id IS NULL
            THEN
               -- The following if has been commented during R12 development
               -- as it is not needed.
               -- There were hard coded strings and also the if with start_date is
               -- not null is incorrect
               /*
               IF l_pe_rec.rev_uplift_start_date IS NOT NULL
               THEN
                  l_date_msg := l_pe_rec.rev_uplift_start_date || ' and end date ' || l_pe_rec.rev_uplift_end_date;
               ELSE
                  l_date_msg := l_pe_rec.rev_uplift_start_date;
               END IF;
               */
               l_date_msg := l_pe_rec.rev_uplift_start_date;

               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_QUOTA_UPLIFT_NOT_EXIST');
                  fnd_message.set_token ('PLAN_NAME', l_pe_rec.NAME);
                  fnd_message.set_token ('REVENUE_CLASS_NAME', l_pe_rec.rev_class_name);
                  fnd_message.set_token ('START_DATE', l_date_msg);
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'QUOTA_UPLIFT_NOT_EXIST';
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Check whether delete is Allowed, this only first and last record can
            -- be deleted
            cn_chk_plan_element_pkg.chk_uplift_iud (x_return_status             => x_return_status,
                                                    p_start_date                => l_pe_rec.rev_uplift_start_date,
                                                    p_end_date                  => l_pe_rec.rev_uplift_end_date,
                                                    p_iud_flag                  => 'D',                                          --D Stands for delete
                                                    p_quota_rule_id             => l_pe_rec.quota_rule_id,
                                                    p_quota_rule_uplift_id      => l_quota_rule_uplift_id,
                                                    p_loading_status            => x_loading_status,
                                                    x_loading_status            => l_loading_status
                                                   );
            x_loading_status := l_loading_status;

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_UPLIFT_DELETE_NOT_ALLOWED');
                  fnd_msg_pub.ADD;
               END IF;

               x_loading_status := 'CN_UPLIFT_DELETE_NOT_ALLOWED';
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Check the Return status and the status is same as CN_DELETED.
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF x_loading_status = 'CN_DELETED'
            THEN
               cn_quota_rule_uplifts_pkg.begin_record (x_operation                  => 'DELETE',
                                                       x_org_id                     => l_pe_rec.org_id,
                                                       x_quota_rule_uplift_id       => l_quota_rule_uplift_id,
                                                       x_quota_rule_id              => NULL,
                                                       x_quota_rule_id_old          => NULL,
                                                       x_start_date                 => NULL,
                                                       x_start_date_old             => NULL,
                                                       x_end_date                   => NULL,
                                                       x_end_date_old               => NULL,
                                                       x_payment_factor             => NULL,
                                                       x_payment_factor_old         => NULL,
                                                       x_quota_factor               => NULL,
                                                       x_quota_factor_old           => NULL,
                                                       x_last_updated_by            => NULL,
                                                       x_creation_date              => NULL,
                                                       x_created_by                 => NULL,
                                                       x_last_update_login          => NULL,
                                                       x_last_update_date           => NULL,
                                                       x_program_type               => g_program_type,
                                                       x_status_code                => NULL,
                                                       x_object_version_number      => p_rev_uplift_rec_tbl (i).object_version_number
                                                      );
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;                                                                                                               -- Table Count is Not Zero

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
         ROLLBACK TO delete_quota_rule_uplift;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_quota_rule_uplift;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_quota_rule_uplift;
END cn_quota_rule_uplifts_grp;

/
