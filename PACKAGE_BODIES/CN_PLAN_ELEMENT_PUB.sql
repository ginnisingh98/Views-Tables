--------------------------------------------------------
--  DDL for Package Body CN_PLAN_ELEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_ELEMENT_PUB" AS
/* $Header: cnppeb.pls 120.12.12010000.2 2009/12/16 06:33:08 rajukum ship $ */
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PLAN_ELEMENT_PUB';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnppeb.pls';


PROCEDURE validate_payment_group_code (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_payment_group_code       IN OUT NOCOPY cn_quotas.payment_group_code%TYPE
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'validate_payment_group_code';
      l_tmp_exist                   NUMBER := 0;

   BEGIN
      -- set the Status
      x_return_status := fnd_api.g_ret_sts_success;


      IF p_payment_group_code is null
      THEN
      	p_payment_group_code := 'STANDARD';

      ELSE

	      -- Check/Valid quota_type_code
	      SELECT COUNT (*)
		INTO l_tmp_exist
		FROM cn_lookups
	       WHERE lookup_type = 'PAYMENT_GROUP_CODE' AND lookup_code = p_payment_group_code;

	      IF (l_tmp_exist = 0)
	      THEN
		 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		 THEN
		    fnd_message.set_name ('CN', 'CN_INVALID_DATA');
		    fnd_message.set_token ('OBJ_NAME', p_payment_group_code);
		    fnd_msg_pub.ADD;
		 END IF;

		 RAISE fnd_api.g_exc_error;
	      END IF;

      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;

      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END validate_payment_group_code;



/* ****************** */
/* ADDED - SBADAMI    */
/* ****************** */

   -- Start of comments
-- API name    : check_org_id
-- Type        : Private
-- Pre-reqs    : None.
-- Function    : Checks whether it is a valid org_id or not
-- Parameters  :
-- IN          :  p_org_id IN NUMBER   Required
--                Item organization id. Part of the unique key
--                that uniquely identifies an item record.
-- Version     :  Initial version   1.0
-- End of comments
   PROCEDURE check_org_id (
      p_org_id                   IN       NUMBER
   )
   IS
   BEGIN
      IF p_org_id IS NULL
      THEN
         fnd_message.set_name ('FND', 'MO_OU_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END;

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

/* ****************** */
/* ADDED - SBADAMI    */
/* ****************** */
-- API name    : handle_User_Hooks
-- Type        : Private
-- Pre-reqs    : None.
-- Function    : Raises error based on different statuses
-- Parameters  :
-- IN          : p_return_status IN VARCHAR2   Required
-- Version     : Initial version   1.0
-- End of comments

   -----------------------------------------------------------------------------+
--| Procedure : convert_to_lkup_code
--| Description  :Convert the lookup meaning to lookup_code if the meaning is
--| valid Otherwise keep the invalid value, it passes the period type element
--| type and incentive type and returns the respective code to the calling
--| place.
--| Note: Before fetch the lookup type code from the lookup table remove the
--| left and right spaces.
--| Called From:  Valid_Plan_Element Procedure
-----------------------------------------------------------------------------+
   PROCEDURE convert_to_lkup_code (
      p_element_type             IN       VARCHAR2,
      p_incentive_type           IN       VARCHAR2,
      p_payee_assign_flag        IN       VARCHAR2,
      p_addup_from_rev_class_flag IN      VARCHAR2,
      p_vesting_flag             IN       VARCHAR2,
      p_rt_sched_custom_flag     IN       VARCHAR2,
      x_quota_type_code          OUT NOCOPY VARCHAR2,
      x_incentive_type_code      OUT NOCOPY VARCHAR2,
      x_payee_assign_flag        OUT NOCOPY VARCHAR2,
      x_vesting_flag             OUT NOCOPY VARCHAR2,
      x_rt_sched_custom_flag     OUT NOCOPY VARCHAR2,
      x_addup_from_rev_class_flag OUT NOCOPY VARCHAR2
   )
   IS
      l_element_type                cn_lookups.meaning%TYPE;
      l_incentive_type              cn_lookups.meaning%TYPE;
      l_flag                        VARCHAR2 (10);
   BEGIN
      -- Trim code, remove all blank spaces at begin/end of the string
      -- Assign NULL value if code = FND_API.G_MISS_CHAR
      l_element_type := RTRIM (LTRIM (p_element_type));
      l_incentive_type := RTRIM (LTRIM (p_incentive_type));

      -- Convert x_quota_type_code
      BEGIN
         SELECT lookup_code
           INTO x_quota_type_code
           FROM cn_lookups
          WHERE lookup_type = 'QUOTA_TYPE' AND UPPER (meaning) = UPPER (l_element_type);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF l_element_type = fnd_api.g_miss_char
            THEN
               x_quota_type_code := fnd_api.g_miss_char;
            ELSE
               x_quota_type_code := SUBSTRB (l_element_type, 1, 30);
            END IF;
      END;

      -- Convert x_incentive_type_code
      BEGIN
         SELECT lookup_code
           INTO x_incentive_type_code
           FROM cn_lookups
          WHERE lookup_type = 'INCENTIVE_TYPE' AND UPPER (meaning) = UPPER (l_incentive_type);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF l_incentive_type = fnd_api.g_miss_char
            THEN
               x_incentive_type_code := fnd_api.g_miss_char;
            ELSE
               x_incentive_type_code := SUBSTRB (l_incentive_type, 1, 30);
            END IF;
      END;

      -- Convert x_payee_assign_flag
      SELECT DECODE (p_payee_assign_flag, fnd_api.g_miss_char, 'No', NULL, 'No', LTRIM (RTRIM (p_payee_assign_flag)))
        INTO l_flag
        FROM SYS.DUAL;

      BEGIN
         SELECT lookup_code
           INTO x_payee_assign_flag
           FROM fnd_lookups
          WHERE lookup_type = 'YES_NO' AND UPPER (meaning) = UPPER (l_flag);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_payee_assign_flag := SUBSTRB (l_flag, 1, 1);
      END;

      -- Convert x_vesting_flag
      SELECT DECODE (p_vesting_flag, fnd_api.g_miss_char, 'No', NULL, 'No', LTRIM (RTRIM (p_vesting_flag)))
        INTO l_flag
        FROM SYS.DUAL;

      BEGIN
         SELECT lookup_code
           INTO x_vesting_flag
           FROM fnd_lookups
          WHERE lookup_type = 'YES_NO' AND UPPER (meaning) = UPPER (l_flag);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_vesting_flag := SUBSTRB (l_flag, 1, 1);
      END;

      -- Convert x_addup_rev_class_flag
      SELECT DECODE (p_addup_from_rev_class_flag, fnd_api.g_miss_char, 'No', NULL, 'No', LTRIM (RTRIM (p_addup_from_rev_class_flag)))
        INTO l_flag
        FROM SYS.DUAL;

      BEGIN
         SELECT lookup_code
           INTO x_addup_from_rev_class_flag
           FROM fnd_lookups
          WHERE lookup_type = 'YES_NO' AND UPPER (meaning) = UPPER (l_flag);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_addup_from_rev_class_flag := SUBSTRB (l_flag, 1, 1);
      END;

      -- Convert x_rate_cust_flag
      SELECT DECODE (p_rt_sched_custom_flag, fnd_api.g_miss_char, 'No', NULL, 'No', LTRIM (RTRIM (p_rt_sched_custom_flag)))
        INTO l_flag
        FROM SYS.DUAL;

      BEGIN
         SELECT lookup_code
           INTO x_rt_sched_custom_flag
           FROM fnd_lookups
          WHERE lookup_type = 'YES_NO' AND UPPER (meaning) = UPPER (l_flag);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_rt_sched_custom_flag := SUBSTRB (l_flag, 1, 1);
      END;
   --
   -- End of convert to lkup code
   --
   END convert_to_lkup_code;

-----------------------------------------------------------------------------+
--| Function    : convert_pe_user_input
--| Description : function to trim all blank spaces of user input convert input
--| to correct lookup code Assign defalut value if input is missing
--| Called From : Create_plan_element. Update_plan_Element
-----------------------------------------------------------------------------+
   FUNCTION convert_pe_user_input (
      p_plan_element_rec         IN       plan_element_rec_type := g_miss_plan_element_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
      RETURN cn_chk_plan_element_pkg.pe_rec_type
   IS
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec;
   BEGIN
      -- Set the Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- Remove the Left and Right Spaces.
      l_pe_rec.NAME := p_plan_element_rec.NAME;
      l_pe_rec.interval_name := p_plan_element_rec.interval_name;
      l_pe_rec.start_date := p_plan_element_rec.start_date;
      l_pe_rec.end_date := p_plan_element_rec.end_date;
      l_pe_rec.vesting_flag := p_plan_element_rec.vesting_flag;
      l_pe_rec.payee_assign_flag := p_plan_element_rec.payee_assign_flag;
      l_pe_rec.addup_from_rev_class_flag := p_plan_element_rec.addup_from_rev_class_flag;
      l_pe_rec.credit_type := p_plan_element_rec.credit_type;
      l_pe_rec.package_name := p_plan_element_rec.package_name;
      l_pe_rec.performance_goal := p_plan_element_rec.performance_goal;
      l_pe_rec.payment_amount := p_plan_element_rec.payment_amount;
      l_pe_rec.rt_sched_custom_flag := p_plan_element_rec.rt_sched_custom_flag;
      l_pe_rec.description := p_plan_element_rec.description;
      l_pe_rec.calc_formula_name := p_plan_element_rec.calc_formula_name;
      l_pe_rec.quota_status := p_plan_element_rec.status;
--CHANTHON: Added this...
      l_pe_rec.org_id := p_plan_element_rec.org_id;
      l_pe_rec.indirect_credit := p_plan_element_rec.indirect_credit;
      -- Get quota_id if this plan element already exist
      BEGIN
         SELECT quota_id
           INTO l_pe_rec.quota_id
           FROM cn_quotas_v
          WHERE NAME = l_pe_rec.NAME
          and org_id = l_pe_rec.ORG_ID;

         x_loading_status := 'PLN_QUOTA_EXISTS';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_pe_rec.quota_id := NULL;
      END;

      -- Get the formula ID
      BEGIN
         IF p_plan_element_rec.calc_formula_name IS NOT NULL
         THEN
            SELECT calc_formula_id
              INTO l_pe_rec.calc_formula_id
              FROM cn_calc_formulas
             WHERE NAME = l_pe_rec.calc_formula_name
             and org_id = l_pe_rec.ORG_ID;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_pe_rec.calc_formula_id := NULL;
      END;

      -- Get Credit Type ID
      BEGIN
         IF p_plan_element_rec.credit_type IS NOT NULL
         THEN
            SELECT credit_type_id
              INTO l_pe_rec.credit_type_id
              FROM cn_credit_types
             WHERE NAME = l_pe_rec.credit_type and org_id = p_plan_element_rec.org_id and rownum=1;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_pe_rec.credit_type_id := NULL;
      END;

      -- Get Interval Type Id
      BEGIN
         IF p_plan_element_rec.interval_name IS NOT NULL
         THEN
            SELECT interval_type_id
              INTO l_pe_rec.interval_type_id
              FROM cn_interval_types
             WHERE NAME = l_pe_rec.interval_name
             and org_id = l_pe_rec.ORG_ID;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_pe_rec.interval_type_id := NULL;
      END;

      -- Convert the Lookup Type to Code
      convert_to_lkup_code (p_element_type                   => p_plan_element_rec.element_type,
                            p_incentive_type                 => p_plan_element_rec.incentive_type,
                            x_quota_type_code                => l_pe_rec.quota_type_code,
                            x_incentive_type_code            => l_pe_rec.incentive_type_code,
                            p_vesting_flag                   => p_plan_element_rec.vesting_flag,
                            p_payee_assign_flag              => p_plan_element_rec.payee_assign_flag,
                            p_rt_sched_custom_flag           => p_plan_element_rec.rt_sched_custom_flag,
                            p_addup_from_rev_class_flag      => p_plan_element_rec.addup_from_rev_class_flag,
                            x_vesting_flag                   => l_pe_rec.vesting_flag,
                            x_payee_assign_flag              => l_pe_rec.payee_assign_flag,
                            x_rt_sched_custom_flag           => l_pe_rec.rt_sched_custom_flag,
                            x_addup_from_rev_class_flag      => l_pe_rec.addup_from_rev_class_flag
                           );

      -- Assign Default value if null or G_MISS_NUM
      SELECT DECODE (p_plan_element_rec.target, fnd_api.g_miss_num, 0, NULL, 0, p_plan_element_rec.target)
        INTO l_pe_rec.target
        FROM SYS.DUAL;

      -- Assign Default value if null or G_MISS_NUM
      SELECT DECODE (p_plan_element_rec.payment_amount, fnd_api.g_miss_num, 0, NULL, 0, p_plan_element_rec.payment_amount)
        INTO l_pe_rec.payment_amount
        FROM SYS.DUAL;

      --  Assign Default value if null or G_MISS_NUM
      SELECT DECODE (p_plan_element_rec.performance_goal, fnd_api.g_miss_num, 0, NULL, 0, p_plan_element_rec.performance_goal)
        INTO l_pe_rec.performance_goal
        FROM SYS.DUAL;

      -- Return the Converted Value
      RETURN l_pe_rec;
   END convert_pe_user_input;

-- -------------------------------------------------------------------------+-+
-- Procedure: chk_pe_required
-- Desc     : Check for necessary parameters for Creating a plan element.
--            Need : Plan Element Name, Valid Start and End period,
--             Can Not Missing/Null   and quota_type_code
-- -------------------------------------------------------------------------+-+
   PROCEDURE chk_pe_required (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Chk_Pe_Required';
      l_loading_status              VARCHAR2 (80);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check if plan element name is missing or null
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

      -- Check quota_type_code can not be missing or NULL
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.quota_type_code,
                                      p_para_name           => cn_chk_plan_element_pkg.g_element_type,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.quota_type_code,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_element_type,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check credit_type  can not be missing or NULL
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.credit_type,
                                      p_para_name           => cn_chk_plan_element_pkg.g_credit_type_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.credit_type,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_credit_type_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check credit_type_id can not be missing or NULL
      IF (p_pe_rec.credit_type IS NOT NULL AND p_pe_rec.credit_type_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_CREDIT_TYPE_NOT_EXIST');
            fnd_message.set_token ('CREDIT_TYPE', p_pe_rec.credit_type);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CREDIT_TYPE_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check interval_type_id can not be missing or NULL
      IF (p_pe_rec.interval_name IS NOT NULL AND p_pe_rec.interval_type_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INTERVAL_TYPE_NOT_EXIST');
            fnd_message.set_token ('INTERVAL_NAME', p_pe_rec.interval_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'INTERVAL_TYPE_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check incentive_type_code can not be missing or NULL
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.incentive_type_code,
                                      p_para_name           => cn_chk_plan_element_pkg.g_incentive_type_code,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.incentive_type_code,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_incentive_type_code,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Start Date  can not be missing or NULL
      IF ((cn_chk_plan_element_pkg.chk_miss_date_para (p_date_para           => p_pe_rec.start_date,
                                                       p_para_name           => cn_chk_plan_element_pkg.g_start_date,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_chk_plan_element_pkg.chk_null_date_para (p_date_para           => p_pe_rec.start_date,
                                                          p_obj_name            => cn_chk_plan_element_pkg.g_start_date,
                                                          p_loading_status      => x_loading_status,
                                                          x_loading_status      => l_loading_status
                                                         )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check interval name  can not be missing or NULL
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_pe_rec.interval_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_interval_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_pe_rec.interval_name,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_interval_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   -- end of chk_pe_required
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_pe_required;

-- -------------------------------------------------------------------------+-+
-- Procedure: chk_pe_consistent
-- Desc     : The same plan element already exist in the database, this
--            procedure will check if all input for this plan element is as
--            the same as those exists in the database
-- -------------------------------------------------------------------------+-+
   PROCEDURE chk_pe_consistent (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR c_pe_csr
      IS
         SELECT NAME,
                description,
                quota_type_code,
                calc_formula_id,
                target
           FROM cn_quotas_v
          WHERE NAME = p_pe_rec.NAME;

      l_pe_csr                      c_pe_csr%ROWTYPE;
      l_api_name           CONSTANT VARCHAR2 (30) := 'chk_pe_consistent';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      OPEN c_pe_csr;

      FETCH c_pe_csr
       INTO l_pe_csr;

      IF c_pe_csr%NOTFOUND
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Check description consistent
      IF (l_pe_csr.description <> p_pe_rec.description)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_CONSISTENT');
            fnd_message.set_token ('PLAN_NAME', p_pe_rec.NAME);
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_desc);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check quota_type_code consistent
      IF (l_pe_csr.quota_type_code <> p_pe_rec.quota_type_code)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_CONSISTENT');
            fnd_message.set_token ('PLAN_NAME', p_pe_rec.NAME);
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_element_type);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check target consistent
      IF (l_pe_csr.target <> p_pe_rec.target)
      THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_CONSISTENT');
            fnd_message.set_token ('PLAN_NAME', p_pe_rec.NAME);
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_target);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_CONSISTENT';
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_pe_csr;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END chk_pe_consistent;

-- -------------------------------------------------------------------------+-+
--| Procedure   : chg_exprs
--| Description : Syncs expressions that are using a particular plan element
--| if the name is changed
-- -------------------------------------------------------------------------+-+
   PROCEDURE chg_exprs (
      p_quota_id                          NUMBER,
      p_old_name                          VARCHAR2,
      p_new_name                          VARCHAR2
   )
   IS
      CURSOR get_exps
      IS
         SELECT calc_sql_exp_id,
                DBMS_LOB.SUBSTR (piped_sql_select) sql_select,
                DBMS_LOB.SUBSTR (piped_expression_disp) expr_disp
           FROM cn_calc_sql_exps
          WHERE '|' || DBMS_LOB.SUBSTR (piped_sql_select) LIKE '%|(' || p_quota_id || 'PE.%';

      l_ss_start                    NUMBER;
      l_ss_end                      NUMBER;
      l_ed_start                    NUMBER;
      l_ed_end                      NUMBER;
      l_quota_id_len                NUMBER := LENGTH ('' || p_quota_id);
      l_quota_name_len              NUMBER := LENGTH (p_old_name);
      CONTINUE                      BOOLEAN;
      l_ss_seg                      VARCHAR2 (4000);
      l_ed_seg                      VARCHAR2 (80);
      l_new_expr_disp               VARCHAR2 (4000);
      l_new_pexpr_disp              VARCHAR2 (4000);
   BEGIN
      -- get all expressions using p_quota_id
      FOR e IN get_exps
      LOOP
         l_ss_start := 1;
         l_ed_start := 1;
         l_new_expr_disp := NULL;
         l_new_pexpr_disp := NULL;
         CONTINUE := TRUE;

         WHILE CONTINUE
         LOOP
            l_ss_end := INSTR (e.sql_select, '|', l_ss_start + 1);
            l_ed_end := INSTR (e.expr_disp, '|', l_ed_start + 1);

            IF l_ss_end = 0
            THEN
               CONTINUE := FALSE;
            ELSE
               l_ss_seg := SUBSTR (e.sql_select, l_ss_start, l_ss_end - l_ss_start);
               l_ed_seg := SUBSTR (e.expr_disp, l_ed_start, l_ed_end - l_ed_start);

               IF     SUBSTR (l_ss_seg, 1, l_quota_id_len + 4) = '(' || p_quota_id || 'PE.'
                  AND SUBSTR (l_ed_seg, 1, l_quota_name_len + 1) = p_old_name || '.'
               THEN
                  l_new_expr_disp := l_new_expr_disp || p_new_name || SUBSTR (l_ed_seg, l_quota_name_len + 1);
                  l_new_pexpr_disp := l_new_pexpr_disp || p_new_name || SUBSTR (l_ed_seg, l_quota_name_len + 1) || '|';
               ELSE
                  l_new_expr_disp := l_new_expr_disp || l_ed_seg;
                  l_new_pexpr_disp := l_new_pexpr_disp || l_ed_seg || '|';
               END IF;
            END IF;

            l_ss_start := l_ss_end + 1;
            l_ed_start := l_ed_end + 1;
         END LOOP;

         -- update table
         UPDATE cn_calc_sql_exps
            SET expression_disp = l_new_expr_disp,
                piped_expression_disp = l_new_pexpr_disp
          WHERE calc_sql_exp_id = e.calc_sql_exp_id;
      END LOOP;
   END chg_exprs;

-- -------------------------------------------------------------------------+-+
--| Procedure   : valid_lookup_code
--| Description : Valid lookup code for plan element. Just make sure the lookup
--| code is valid  in cn_lookups or not null/not missing but not checking
--| correct setting for different plan element type
-- -------------------------------------------------------------------------+-+
   PROCEDURE valid_lookup_code (
      x_return_status            OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Valid_Lookup_Code';
      l_tmp_exist                   NUMBER := 0;
   BEGIN
      -- set the Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check/Valid quota_type_code
      SELECT COUNT (*)
        INTO l_tmp_exist
        FROM cn_lookups
       WHERE lookup_type = 'QUOTA_TYPE' AND lookup_code = p_pe_rec.quota_type_code;

      IF (l_tmp_exist = 0)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_element_type);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_DATA';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check/Valid Incentive Type
      SELECT COUNT (*)
        INTO l_tmp_exist
        FROM cn_lookups
       WHERE lookup_type = 'INCENTIVE_TYPE' AND lookup_code = p_pe_rec.incentive_type_code;

      IF (l_tmp_exist = 0)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATA');
            fnd_message.set_token ('OBJ_NAME', cn_chk_plan_element_pkg.g_incentive_type_code);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_DATA';
         RAISE fnd_api.g_exc_error;
      END IF;
-- End valid lookup code
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END valid_lookup_code;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Insert_rate_quotas
--| Description: Rate_quotas is a local procedure to create the Default rate
--| Quota Assigns if the quota type is formula and the formula has the rates in
--| formula rate Assigns. Another important thing is if you pass the custom
--| Quota Rate it will ignore the default create. it will use the custom one you
--| Pass through your API.
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE update_rate_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_pe_rec_old               IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Rate_Quotas';
      l_object_version_number NUMBER;
   BEGIN
      -- Record inserted successfully, check for rt_quota_assigns
      -- Insert Rate Quota Assigs
      -- first table count is 0

      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check if the Count is O and the QUOTA TYPE IS FORMULA
      -- Call the Chk_formula_rate_date Procedure to check all the Start
      -- Date and End date of Rate QUota assigns falls user the Quota Start
      -- and end Date then insert through a batch by calling the Table Handler
      IF NVL (p_pe_rec_old.calc_formula_id, 0) <> NVL (p_pe_rec.calc_formula_id, 0)
      THEN
         -- Call the Table Handler to Delete the Old Period quotas
         cn_rt_quota_asgns_pkg.DELETE_RECORD (x_quota_id => p_pe_rec_old.quota_id, x_calc_formula_id => NULL, x_rt_quota_asgn_id => NULL);
      END IF;

      IF p_rt_quota_asgns_rec_tbl.COUNT = 0 AND p_pe_rec.quota_type_code <> 'NONE'
      THEN
         -- check all the formula rate start date fall under the quota date
          -- clku, we do not check the date range of the formula rates against the PE date range anymore,
          -- bug 1949943
         /*cn_chk_plan_element_pkg.chk_formula_rate_date
           (
            x_return_status      => x_return_status,
            p_start_date         => p_pe_rec.start_date,
            p_end_date           => p_pe_rec.end_date,
            p_quota_name         => p_pe_rec.name ,
            p_calc_formula_id    => p_pe_rec.calc_formula_id,
            p_calc_formula_name  => p_pe_rec.calc_formula_name,
            p_loading_status     => x_loading_status,
            x_loading_status     => x_loading_status ) ;
              -- error if the status is not success
         IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
            RAISE FND_API.G_EXC_ERROR ;
         END IF;*/
         IF p_pe_rec.calc_formula_id IS NOT NULL AND NVL (p_pe_rec_old.calc_formula_id, 0) <> NVL (p_pe_rec.calc_formula_id, 0)
         THEN
            -- check all the formula rate start date fall under the quota date
             -- clku, we do not check the date range of the formula rates against the PE date range anymore,
             -- bug 1949943
            /*cn_chk_plan_element_pkg.chk_formula_rate_date
              (
               x_return_status      => x_return_status,
               p_start_date         => p_pe_rec.start_date,
               p_end_date           => p_pe_rec.end_date,
               p_quota_name         => p_pe_rec.name ,
               p_calc_formula_id    => p_pe_rec.calc_formula_id,
               p_calc_formula_name  => p_pe_rec.calc_formula_name,
               p_loading_status     => x_loading_status,
               x_loading_status     => x_loading_status ) ;
                 -- error if the status is not success
            IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
               RAISE FND_API.G_EXC_ERROR ;
            END IF;*/

            -- call the Table handler for batch insert. we betten
            -- DO IN TABLE handler itself
            cn_rt_quota_asgns_pkg.INSERT_RECORD (x_quota_id => p_pe_rec.quota_id, x_calc_formula_id => p_pe_rec.calc_formula_id);
         END IF;
      -- if the rt_table_count is > 0 and the quota type  is FORMULA
      ELSIF p_pe_rec.quota_type_code <> 'NONE' AND p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         -- call create_rt_quota_asgns_pvt package to validate and create
         -- the rate Quota Assigns
         cn_rt_quota_asgns_pvt.update_rt_quota_asgns (p_api_version                 => p_api_version,
                                                      p_init_msg_list               => 'T',
                                                      p_commit                      => p_commit,
                                                      p_validation_level            => p_validation_level,
                                                      x_return_status               => x_return_status,
                                                      x_msg_count                   => x_msg_count,
                                                      x_msg_data                    => x_msg_data,
                                                      p_quota_name                  => p_quota_name,
                                                      p_org_id						=> p_pe_rec.org_id,
                                                      p_rt_quota_asgns_rec_tbl      => p_rt_quota_asgns_rec_tbl,
                                                      x_loading_status              => x_loading_status,
                                                      x_object_version_number       => l_object_version_number
                                                     );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      -- if table count is > 0 but the quota type code is NONE
      -- then raise an error
      ELSIF p_pe_rec.quota_type_code = 'NONE' AND p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         -- Error you cannot have rates for quota type is NONE
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_CANNOT_HAVE_RATES');
            fnd_message.set_token ('PLAN_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_CANNOT_HAVE_RATES';
         RAISE fnd_api.g_exc_error;
      END IF;
-- End of rate_quotas
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END update_rate_quotas;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Insert_rate_quotas
--| Description: Rate_quotas is a local procedure to create the Default rate
--| Quota Assigns if the quota type is formula and the formula has the rates in
--| formula rate Assigns. Another important thing is if you pass the custom
--| Quota Rate it will ignore the default create. it will use the custom one you
--| Pass through your API.
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE insert_rate_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Insert_Rate_Quotas';
      l_object_version_number NUMBER;
   BEGIN
      -- Record inserted successfully, check for rt_quota_assigns
      -- Insert Rate Quota Assigs
      -- first table count is 0

      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check if the Count is O and the QUOTA TYPE IS FORMULA
      -- Call the Chk_formula_rate_date Procedure to check all the Start
      -- Date and End date of Rate QUota assigns falls user the Quota Start
      -- and end Date then insert through a batch by calling the Table Handler

      -- Check the ITD flag
      IF p_rt_quota_asgns_rec_tbl.COUNT = 0 AND p_pe_rec.quota_type_code <> 'NONE'
      THEN
         IF p_pe_rec.calc_formula_id IS NOT NULL
         THEN
            -- check all the formula rate start date fall under the quota date
              -- clku, we do not check the date range of the formula rates against the PE date range anymore,
             -- bug 1949943
             /*cn_chk_plan_element_pkg.chk_formula_rate_date
              (
               x_return_status      => x_return_status,
               p_start_date         => p_pe_rec.start_date,
               p_end_date           => p_pe_rec.end_date,
               p_quota_name         => p_pe_rec.name ,
               p_calc_formula_id    => p_pe_rec.calc_formula_id,
               p_calc_formula_name  => p_pe_rec.calc_formula_name,
               p_loading_status     => x_loading_status,
               x_loading_status     => x_loading_status ) ;
                 -- error if the status is not success
            IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS ) THEN
               RAISE FND_API.G_EXC_ERROR ;
            END IF;*/
            -- call the Table handler for batch insert.
            cn_rt_quota_asgns_pkg.INSERT_RECORD (x_quota_id => p_pe_rec.quota_id, x_calc_formula_id => p_pe_rec.calc_formula_id);
         END IF;
      -- if the rt_table_count is > 0 and the quota type  is FORMULA
      ELSIF p_pe_rec.quota_type_code <> 'NONE' AND p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         -- call create_rt_quota_asgns_pvt package to validate and create
         -- the rate Quota Assigns
         cn_rt_quota_asgns_pvt.create_rt_quota_asgns (p_api_version                 => p_api_version,
                                                      p_init_msg_list               => 'T',
                                                      p_commit                      => p_commit,
                                                      p_validation_level            => p_validation_level,
                                                      x_return_status               => x_return_status,
                                                      x_msg_count                   => x_msg_count,
                                                      x_msg_data                    => x_msg_data,
                                                      p_quota_name                  => p_quota_name,
                                                      p_org_id											=> p_pe_rec.org_id,
                                                      p_rt_quota_asgns_rec_tbl      => p_rt_quota_asgns_rec_tbl,
                                                      x_loading_status              => x_loading_status,
                                                      x_object_version_number       => l_object_version_number
                                                     );

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      -- if table count is > 0 but the quota type code is NONE
      -- then raise an error
      ELSIF p_pe_rec.quota_type_code = 'NONE' AND p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         -- Error you cannot have rates for quota type is NONE
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_CANNOT_HAVE_RATES');
            fnd_message.set_token ('PLAN_NAME', p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'QUOTA_CANNOT_HAVE_RATES';
         RAISE fnd_api.g_exc_error;
      END IF;
-- End of rate_quotas
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END insert_rate_quotas;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Create_Period_quotas
--| Description: Period_quotas is a localprocedure to create the Default period
--| Quota if the quota type is formula and the formula has the a ITD  flag is
--| set to Y then Create or Customize the Period Quotas
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE update_period_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_pe_rec_old               IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Period_quotas';
   BEGIN
      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check if the formula id is not null and has ITD flag is Y
      -- and check if table.COUNT is zero the call the table handler
      -- to create the Period Quotas.
      -- if the count is > 0 then Call the Group Package procedure
      -- to Create the Custom Period Quotas
      IF    p_pe_rec_old.start_date <> p_pe_rec.start_date
         OR NVL (p_pe_rec.end_date, fnd_api.g_miss_date) <> NVL (p_pe_rec_old.end_date, fnd_api.g_miss_date)
      --clku, bug 3058608
      /*OR
      Nvl(p_pe_rec_old.calc_formula_id,0) <> Nvl(p_pe_rec.calc_formula_id,0)*/
      THEN
         -- Call the Table Handler to Delete the Old Period quotas
         cn_period_quotas_pkg.DELETE_RECORD (p_pe_rec_old.quota_id);
          -- Check the ITD flag
            -- 2462767, we do not check for formula ID anymore,IF  p_pe_rec.calc_formula_id IS NOT NULL THEN
              -- clku, enhancement 2380234
              --IF Nvl(cn_api.get_itd_flag(p_pe_rec.calc_formula_id),'N') = 'Y'
         --  THEN
         cn_period_quotas_pkg.distribute_target (p_pe_rec.quota_id);

         -- if count is zero create the default period quotas.
         IF p_period_quotas_rec_tbl.COUNT > 0
         THEN
            -- if count is > 0 then create the period quotas with the
            -- customised values.
            -- Call the Group package to create the Period Quotas
            cn_period_quotas_grp.update_period_quotas (p_api_version                => p_api_version,
                                                       p_init_msg_list              => 'T',
                                                       p_commit                     => p_commit,
                                                       p_validation_level           => p_validation_level,
                                                       x_return_status              => x_return_status,
                                                       x_msg_count                  => x_msg_count,
                                                       x_msg_data                   => x_msg_data,
                                                       p_quota_name                 => p_quota_name,
                                                       p_period_quotas_rec_tbl      => p_period_quotas_rec_tbl,
                                                       x_loading_status             => x_loading_status
                                                      );
         -- if the return status is not success then  raise an Error
         END IF;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      -- END IF; -- clku, enhancement 2380234
       ELSE
             --fix for the Bug 6193694
             IF p_period_quotas_rec_tbl.COUNT > 0
               THEN
              cn_period_quotas_grp.update_period_quotas (p_api_version                    => p_api_version,
                                                             p_init_msg_list              => 'T',
                                                             p_commit                     => p_commit,
                                                             p_validation_level           =>p_validation_level,
                                                             x_return_status              => x_return_status,
                                                             x_msg_count                  => x_msg_count,
                                                             x_msg_data                   => x_msg_data,
                                                             p_quota_name                 => p_quota_name,
                                                             p_period_quotas_rec_tbl     =>p_period_quotas_rec_tbl,
                                                             x_loading_status             => x_loading_status
                                                            );
              END IF;

      -- 2462767, we do not check for formula ID anymore,END IF; -- formula id is NOT NULL
      END IF;
   -- End Period_Quotas
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END update_period_quotas;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Create_Period_quotas
--| Description: Period_quotas is a localprocedure to create the Default period
--| Quota if the quota type is formula and the formula has the a ITD  flag is
--| set to Y then Create or Customize the Period Quotas
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE create_period_quotas (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_is_duplicate             IN VARCHAR2
   )
   IS
      l_tmp                         NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Period_quotas';
   BEGIN
      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Check if the formula id is not null and has ITD flag is Y
      -- and check if table.COUNT is zero the call the table handler
      -- to create the Period Quotas.
      -- if the count is > 0 then Call the Group Package procedure
      -- to Create the Custom Period Quotas
      -- 2462767, we do not check for formula ID anymore,IF p_pe_rec.calc_formula_id IS NOT NULL THEN
         -- Check the ITD flag
         -- clku, enhancement 2380234, we do not check for the itd flag anymore
         --IF Nvl(cn_api.get_itd_flag(p_pe_rec.calc_formula_id),'N') = 'Y' THEN
      -- if count is zero create the default period quotas.
      IF p_period_quotas_rec_tbl.COUNT = 0
      THEN
         cn_period_quotas_pkg.distribute_target (p_pe_rec.quota_id);
      ELSE
         -- if count is > 0 then create the period quotas with the
         -- customised values.
         l_tmp := p_period_quotas_rec_tbl.COUNT;
         -- Call the Group package to create the Period Quotas
         cn_period_quotas_grp.create_period_quotas (p_api_version                => p_api_version,
                                                    p_init_msg_list              => 'T',
                                                    p_commit                     => p_commit,
                                                    p_validation_level           => p_validation_level,
                                                    x_return_status              => x_return_status,
                                                    x_msg_count                  => x_msg_count,
                                                    x_msg_data                   => x_msg_data,
                                                    p_quota_name                 => p_quota_name,
                                                    p_period_quotas_rec_tbl      => p_period_quotas_rec_tbl,
                                                    x_loading_status             => x_loading_status,
                                                    p_is_duplicate               => p_is_duplicate
                                                   );

         -- if the return status is not success then  raise an Error
         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;                                                                                                                -- period table count = 0
    -- ITD falg is N but they are passing the period quotas info its
    -- an error
       /*ELSIF  Nvl(cn_api.get_itd_flag(p_pe_rec.calc_formula_id),'N') = 'N'
    AND   p_period_quotas_rec_tbl.COUNT > 0 THEN

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_CANNOT_HAVE_PERIODS');
       FND_MSG_PUB.Add;
    END IF;
    x_loading_status := 'QUOTA_CANNOT_HAVE_PERIODS';
    RAISE FND_API.G_EXC_ERROR ;
      --END IF;  -- clku, enhancement 2380234*/
   -- 2462767, we do not check for formula ID anymore,END IF; -- formula id is NOT NULL
-- End Period_Quotas
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END create_period_quotas;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Trx_factors
--| Description: Trx_factors  is a local procedure to create the Default trx
--| factors and you customize the trx factors.
-- -------------------------------------------------------------------------+-+
   PROCEDURE trx_factors (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_trx_factor_rec_tbl       IN       trx_factor_rec_tbl_type,
      p_quota_id                 IN       NUMBER,
      p_quota_name               IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_tmp                         NUMBER;
      OUTER                         NUMBER;
      INNER                         NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'Trx_Factors';
      l_trx_factor_rec_tbl          trx_factor_rec_tbl_type;
      l_rev_class_id                NUMBER;
      l_quota_rule_id               NUMBER;
      l_meaning                     cn_lookups.meaning%TYPE;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      -- Set Status
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Trx Factor data should be loaded from p_trx_factor_rec_tbl,
      -- Since we insert data with default value already, so need to
      -- Update with the new Factors

      -- Sequence the trx factor passed
      FOR OUTER IN p_trx_factor_rec_tbl.FIRST .. p_trx_factor_rec_tbl.LAST
      LOOP
         l_tmp := 0;

         IF l_trx_factor_rec_tbl.COUNT > 0
         THEN
            FOR INNER IN l_trx_factor_rec_tbl.FIRST .. l_trx_factor_rec_tbl.LAST
            LOOP
               IF (p_trx_factor_rec_tbl (OUTER).rev_class_name = l_trx_factor_rec_tbl (INNER).rev_class_name)
               THEN
                  l_tmp := 1;
               END IF;
            END LOOP;
         END IF;

         IF l_tmp = 0
         THEN
            l_trx_factor_rec_tbl (l_trx_factor_rec_tbl.COUNT + 1) := p_trx_factor_rec_tbl (OUTER);
         END IF;
      END LOOP;

      --  Start update the Process
      -- here we avoid the duplicate fetch of revenue class for multiple trx
      FOR OUTER IN l_trx_factor_rec_tbl.FIRST .. l_trx_factor_rec_tbl.LAST
      LOOP
         -- Get revenue class ID from the Database
         l_rev_class_id := cn_api.get_rev_class_id (RTRIM (LTRIM (l_trx_factor_rec_tbl (OUTER).rev_class_name)),l_trx_factor_rec_tbl (OUTER).org_id);

         -- Check the revenue class name is assigned.
         IF l_trx_factor_rec_tbl (OUTER).rev_class_name IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_ASSIGNED');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'REV_CLASS_NOT_ASSIGNED';
            RAISE fnd_api.g_exc_error;
         END IF;

         -- check the revenue class exists
         IF l_rev_class_id IS NULL AND l_trx_factor_rec_tbl (OUTER).rev_class_name IS NOT NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_REV_CLASS_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;

         -- get the quota rule id using the quota id and revenue class id
         l_quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id => p_quota_id, p_rev_class_id => l_rev_class_id);

         -- Quota rule_id is null raise an error
         IF l_quota_rule_id IS NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_QUOTA_RULE_NOT_EXIST');
               fnd_message.set_token ('PLAN_NAME', p_quota_name);
               fnd_message.set_token ('REVENUE_CLASS_NAME', l_trx_factor_rec_tbl (OUTER).rev_class_name);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'QUOTA_RULE_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;

         FOR INNER IN p_trx_factor_rec_tbl.FIRST .. p_trx_factor_rec_tbl.LAST
         LOOP
            IF (p_trx_factor_rec_tbl (INNER).rev_class_name = l_trx_factor_rec_tbl (OUTER).rev_class_name)
            THEN
               -- More validation to be done. Update the Event Column
               l_meaning := cn_api.get_lkup_meaning (p_trx_factor_rec_tbl (INNER).trx_type, 'TRX TYPES');

               IF l_meaning IS NULL
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_TRX_TYPE_NOT_EXIST');
                     fnd_message.set_token ('TRANSACTION_TYPE', p_trx_factor_rec_tbl (INNER).trx_type);
                     fnd_msg_pub.ADD;
                  END IF;

                  x_loading_status := 'CN_TRX_TYPE_NOT_EXISTS';
                  RAISE fnd_api.g_exc_error;
               END IF;

               UPDATE cn_trx_factors
                  SET event_factor = p_trx_factor_rec_tbl (OUTER).event_factor
                WHERE quota_rule_id = l_quota_rule_id AND quota_id = p_quota_id AND trx_type = p_trx_factor_rec_tbl (INNER).trx_type;
            END IF;                                                                                                               -- trx Factor Exists
         END LOOP;                                                                                                                         -- Trx Loop

         -- validate Rule :
         --  Check TRX_FACTORS
         --  1. Key Factor's total = 100
         --  2. Must have Trx_Factors
         cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                 p_quota_rule_id       => l_quota_rule_id,
                                                 p_rev_class_name      => l_trx_factor_rec_tbl (OUTER).rev_class_name,
                                                 p_loading_status      => x_loading_status,
                                                 x_loading_status      => l_loading_status
                                                );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success) OR x_loading_status NOT IN ('CN_UPDATED', 'CN_INSERTED')
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;                                                                                                                      -- Outer trx Loop
   -- End Trx Factors
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_loading_status := 'UNEXPECTED_ERR';

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END trx_factors;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Check_quota_exists
--| Description: Check_quota_exists is a local procedure to check the quota is
--| is exists
--| Called From: Check_valid_Update
-- -------------------------------------------------------------------------+-+
   PROCEDURE check_quota_exists (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name_old           IN       VARCHAR2,
      x_quota_id                 OUT NOCOPY NUMBER,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Quota_Exists';
      l_same_pe                     NUMBER;
      l_loading_status              VARCHAR2 (80);

      CURSOR c_pe_rec_old_csr (
         pe_name                             cn_quotas.NAME%TYPE
      )
      IS
         SELECT q.quota_id
           FROM cn_quotas_v q
          WHERE q.NAME = pe_name;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Get the Old record quota id and Formula id to update and
      -- delete the rate Quota assigns, in the table handler
      -- Check if old plan element name is missing or null
      IF ((cn_api.chk_miss_char_para (p_char_para           => p_quota_name_old,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF ((cn_api.chk_null_char_para (p_char_para           => p_quota_name_old,
                                         p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                         p_loading_status      => x_loading_status,
                                         x_loading_status      => l_loading_status
                                        )
             ) = fnd_api.g_true
            )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- get the old plan element record
      OPEN c_pe_rec_old_csr (p_quota_name_old);

      FETCH c_pe_rec_old_csr
       INTO x_quota_id;

      CLOSE c_pe_rec_old_csr;

      -- Check the Old Plan Element Exists in the Database
      IF x_quota_id IS NULL
      THEN
         IF p_quota_name_old IS NOT NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', p_quota_name_old);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Standard message count
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   -- end check_quota_exists
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
   END check_quota_exists;

-- -------------------------------------------------------------------------+-+
--| Procedure:   Valid_plan_Element
--| Description: Validate plan Element is a local procedure to Validate the Plan
--| Element.
--| Called From: Create_plan_Element and Update_Plan_Element
-- -------------------------------------------------------------------------+-+
   PROCEDURE valid_plan_element (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_pe_rec                   IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      p_quota_name_old           IN       VARCHAR2,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Valid_Plan_Element';
      l_same_pe                     NUMBER;
      l_loading_status              VARCHAR2 (80);
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;
      -- API body
      -- check for required data in Plan Element
      -- Check MISS and NULL parameters
      chk_pe_required (x_return_status       => x_return_status,
                       p_pe_rec              => p_pe_rec,
                       p_loading_status      => x_loading_status,
                       x_loading_status      => l_loading_status
                      );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- If Plan already exist, check for consistentent
      IF p_pe_rec.quota_id IS NOT NULL AND p_quota_name_old IS NULL
      THEN                                                                                                                      -- Plan Element Exists
         chk_pe_consistent (x_return_status       => x_return_status,
                            p_pe_rec              => p_pe_rec,
                            p_loading_status      => x_loading_status,
                            x_loading_status      => l_loading_status
                           );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         x_loading_status := 'PLN_QUOTA_EXISTS';
         GOTO end_api_body;
      END IF;

      -- Validate Rule : End period must be greater than Start period
      IF (p_pe_rec.end_date IS NOT NULL AND TRUNC (p_pe_rec.end_date) < TRUNC (p_pe_rec.start_date))
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_DATE_RANGE');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'INVALID_END_DATE';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Formula name is not null but the ID is not in the Database
      -- Raise an Error
      IF (p_pe_rec.calc_formula_name IS NOT NULL AND p_pe_rec.calc_formula_id IS NULL)
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_FORMULA_NOT_EXIST');
            fnd_message.set_token ('FORMULA_NAME', p_pe_rec.calc_formula_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'FORMULA_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate All lookup codes, must have valid value
      valid_lookup_code (x_return_status       => x_return_status,
                         p_pe_rec              => p_pe_rec,
                         p_loading_status      => x_loading_status,
                         x_loading_status      => l_loading_status
                        );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate the Quota Type with the Respective Column
      -- Check if the quota type is formula then the formula name must be not null
      -- Check if the quota type is formula the package name must be null
      IF (p_pe_rec.quota_type_code = 'FORMULA')
      THEN
         -- if Quota type is Formula, then Formula is Mandatory and
         -- Package name must be null
         cn_chk_plan_element_pkg.chk_formula_quota_pe (x_return_status       => x_return_status,
                                                       p_pe_rec              => p_pe_rec,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            x_loading_status := 'INVALID_DATA';
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (p_pe_rec.quota_type_code = 'EXTERNAL')
      THEN
         -- if Quota type is External Package name is Mandatory and
         -- formula must be null
         cn_chk_plan_element_pkg.chk_external_quota_pe (x_return_status       => x_return_status,
                                                        p_pe_rec              => p_pe_rec,
                                                        p_loading_status      => x_loading_status,
                                                        x_loading_status      => l_loading_status
                                                       );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            x_loading_status := 'INVALID_DATA';
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF (p_pe_rec.quota_type_code = 'NONE')
      THEN
         -- If quota type is NONE, both Formula and package must be null
         cn_chk_plan_element_pkg.chk_other_quota_pe (x_return_status       => x_return_status,
                                                     p_pe_rec              => p_pe_rec,
                                                     p_loading_status      => x_loading_status,
                                                     x_loading_status      => l_loading_status
                                                    );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            x_loading_status := 'INVALID_DATA';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body.
      <<end_api_body>>
      NULL;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
-- end valid_plan_element
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
   END valid_plan_element;

--|--------------------------------------------------------------------------+
--|Procedure: Check Valid Update
--|Description:This procedure is called from update plan element and it will be
--|called only if there is a old plan element name passed. first to check the
--| new plan element name is unique and it should pass all the validations.
--|secondly if there is calc formula assigns before that we need to delete the
--|old rate quota assigns. that will cacade if there is srp rate quota assigs.
--|rate quota assigs, we would take care at the table handler level
-- --------------------------------------------------------------------------+
   PROCEDURE check_valid_update (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name_old           IN       VARCHAR2,
      p_new_pe_rec               IN       cn_chk_plan_element_pkg.pe_rec_type := cn_chk_plan_element_pkg.g_miss_pe_rec,
      x_old_pe_rec               OUT NOCOPY cn_chk_plan_element_pkg.pe_rec_type,
      p_loading_status           IN       VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Check_Valid_Update';
      l_same_pe                     NUMBER;
      l_loading_status              VARCHAR2 (80);

      CURSOR c_pe_rec_old_csr (
         pe_name                             cn_quotas.NAME%TYPE
      )
      IS
         SELECT q.quota_id,
                q.calc_formula_id,
                cn_chk_plan_element_pkg.get_calc_formula_name (q.calc_formula_id),
                -- clku, 5/9/2002
                q.quota_type_code,
                q.start_date,
                q.end_date
           FROM cn_quotas_v q
          WHERE q.NAME = pe_name;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := p_loading_status;

      -- Get the Old record quota id and Formula id to update and
      -- delete the rate Quota assigns, in the table handler
      OPEN c_pe_rec_old_csr (p_quota_name_old);

      FETCH c_pe_rec_old_csr
       INTO x_old_pe_rec.quota_id,
            x_old_pe_rec.calc_formula_id,
            x_old_pe_rec.calc_formula_name,
            --clku, 5/9/2002
            x_old_pe_rec.quota_type_code,
            x_old_pe_rec.start_date,
            x_old_pe_rec.end_date;

      CLOSE c_pe_rec_old_csr;

      -- Check the Old Plan Element Exists in the Database
      -- Update case 1
      -- if the old quota id is null you cannot update main plan element
      -- if the old quota is null but the you pass a bad pe name it is an error
      -- if old quota id is null then there is child update but ther should be
      -- new quota id  there has to be a quota id for child update
      IF x_old_pe_rec.quota_id IS NULL
      THEN
         IF p_quota_name_old IS NOT NULL
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
               fnd_message.set_token ('PE_NAME', p_quota_name_old);
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_NOT_EXIST';
            RAISE fnd_api.g_exc_error;
         ELSIF p_new_pe_rec.quota_id IS NOT NULL
         THEN
            x_loading_status := 'PLN_QUOTA_EXISTS';
         END IF;
      ELSE
         -- Update case 2 ( else )
         -- if the old quota  is not null then chances of update on both parent and child
         -- or just parent.
         -- Check the New Quota name, must be unique
         IF p_new_pe_rec.quota_id IS NOT NULL AND p_new_pe_rec.quota_id <> x_old_pe_rec.quota_id
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_EXISTS');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_PLN_EXISTS';
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Assiged quota to comp plan check if the start date and the end date changes.
      IF    TRUNC (p_new_pe_rec.start_date) <> TRUNC (x_old_pe_rec.start_date)
         OR TRUNC (NVL (p_new_pe_rec.end_date, fnd_api.g_miss_date)) <> TRUNC (NVL (x_old_pe_rec.end_date, fnd_api.g_miss_date))
      THEN
         cn_chk_plan_element_pkg.chk_comp_plan_date (x_return_status       => x_return_status,
                                                     p_start_date          => p_new_pe_rec.start_date,
                                                     p_end_date            => p_new_pe_rec.end_date,
                                                     p_quota_id            => x_old_pe_rec.quota_id,
                                                     p_quota_name          => p_quota_name_old,
                                                     p_loading_status      => x_loading_status,
                                                     x_loading_status      => l_loading_status
                                                    );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Check the Plan Element start date and end date fall with in the rt_formula_asgns
         IF p_new_pe_rec.calc_formula_id IS NOT NULL
         THEN
            IF p_new_pe_rec.calc_formula_id = x_old_pe_rec.calc_formula_id
            THEN
               cn_chk_plan_element_pkg.chk_rate_quota_date (x_return_status       => x_return_status,
                                                            p_start_date          => p_new_pe_rec.start_date,
                                                            p_end_date            => p_new_pe_rec.end_date,
                                                            p_quota_name          => p_new_pe_rec.NAME,
                                                            p_quota_id            => p_new_pe_rec.quota_id,
                                                            p_loading_status      => x_loading_status,
                                                            x_loading_status      => l_loading_status
                                                           );
               x_loading_status := l_loading_status;
            END IF;

            -- error if the status is not success
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- Check the Plan Element start date and end date fall with in the uplift start date
         -- and end date
         IF p_new_pe_rec.quota_id IS NOT NULL
         THEN
            cn_chk_plan_element_pkg.chk_uplift_date (x_return_status       => x_return_status,
                                                     p_start_date          => p_new_pe_rec.start_date,
                                                     p_end_date            => p_new_pe_rec.end_date,
                                                     p_quota_name          => p_new_pe_rec.NAME,
                                                     p_quota_id            => p_new_pe_rec.quota_id,
                                                     p_loading_status      => x_loading_status,
                                                     x_loading_status      => l_loading_status
                                                    );
            x_loading_status := l_loading_status;

            -- error if the status is not success
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;

      -- Go through the normal validation for update
      valid_plan_element (x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_pe_rec              => p_new_pe_rec,
                          p_quota_name_old      => p_quota_name_old,
                          p_loading_status      => x_loading_status,
                          x_loading_status      => l_loading_status
                         );
      x_loading_status := l_loading_status;

      -- Raise an Error if the Status is not success
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   -- End of Check_valid_update
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

--|--------------------------------------------------------------------------+
--|Procedure: Create_plan_element
--|Description:This is a Public procedure is used to create the Plan Element
--|and create their respective child records
-- --------------------------------------------------------------------------+
   PROCEDURE create_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_rec         IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       trx_factor_rec_tbl_type := g_miss_trx_factor_rec_tbl,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_is_duplicate             IN VARCHAR2 DEFAULT 'N'
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type;
      l_trx_factor_rec_tbl          trx_factor_rec_tbl_type;
      l_quota_rule_id               cn_quota_rules.quota_rule_id%TYPE;
      l_per_quota_id                cn_period_quotas.period_quota_id%TYPE;
      l_tmp                         NUMBER;
      l_meaning                     cn_lookups.meaning%TYPE;
      l_p_plan_element_rec          plan_element_rec_type;
      l_p_revenue_class_rec_tbl     revenue_class_rec_tbl_type;
      l_p_rev_uplift_rec_tbl        rev_uplift_rec_tbl_type;

      l_p_rev_uplift_rec_tbl1        cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type;

      l_p_trx_factor_rec_tbl        trx_factor_rec_tbl_type;
      l_p_period_quotas_rec_tbl     period_quotas_rec_tbl_type;
      l_p_rt_quota_asgns_rec_tbl    rt_quota_asgns_rec_tbl_type;
      l_oai_array                   jtf_usr_hks.oai_data_array_type;
      l_bind_data_id                NUMBER;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      l_loading_status              VARCHAR2 (80);
      l_org_id                      NUMBER;
      l_status                      VARCHAR2(1);
      p_payment_group_code          l_p_plan_element_rec.payment_group_code%type;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_plan_element;

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
      x_loading_status := 'CN_INSERTED';

      -- START OF MOAC ORG_ID VALIDATION
      l_org_id := p_plan_element_rec.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                       status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_plan_element_pub.create_plan_element.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- API body
      l_p_plan_element_rec := p_plan_element_rec;
      l_p_revenue_class_rec_tbl := p_revenue_class_rec_tbl;
      l_p_rev_uplift_rec_tbl := p_rev_uplift_rec_tbl;
      l_p_trx_factor_rec_tbl := p_trx_factor_rec_tbl;
      l_p_period_quotas_rec_tbl := p_period_quotas_rec_tbl;
      l_p_rt_quota_asgns_rec_tbl := p_rt_quota_asgns_rec_tbl;
      p_payment_group_code := l_p_plan_element_rec.payment_group_code;
      -- Validate Payment group code
      validate_payment_group_code(x_return_status       => x_return_status,
                                  p_payment_group_code  => p_payment_group_code);

        IF (x_return_status <> fnd_api.g_ret_sts_success)
        THEN
             RAISE fnd_api.g_exc_error;
        ELSE
             l_p_plan_element_rec.payment_group_code := p_payment_group_code;
        END IF;



      /*  pre processing call  */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'CREATE_PLAN_ELEMENT', 'B', 'C')
      THEN
         cn_plan_element_cuhk.create_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_plan_element_rec            => l_p_plan_element_rec,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                       p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'CREATE_PLAN_ELEMENT', 'B', 'V')
      THEN
         cn_plan_element_vuhk.create_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_plan_element_rec            => l_p_plan_element_rec,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                       p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Store the User Input Value into The Local Variable.
      l_pe_rec :=
         convert_pe_user_input (x_return_status         => x_return_status,
                                p_plan_element_rec      => l_p_plan_element_rec,
                                p_loading_status        => x_loading_status,
                                x_loading_status        => l_loading_status
                               );
      x_loading_status := l_loading_status;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      -- Validate Plan Element
      -- if the Quota id is null then there must be change of insert
      -- in the revenue class, accelerator or trx factors.
      --
      IF l_pe_rec.quota_id IS NULL AND l_pe_rec.quota_status = 'COMPLETE'
      THEN
         valid_plan_element (x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_pe_rec              => l_pe_rec,
                             p_quota_name_old      => NULL,
                             p_loading_status      => x_loading_status,
                             x_loading_status      => l_loading_status
                            );
         x_loading_status := l_loading_status;
      -- returns status false in any failure but return success status with
      -- record exists
      -- these are the two possibilities.
      END IF;

      -- Case 1 Plan Element Does not exists then you can create the Plan Element
      --        and create the respective child records if the record passes thru
      --        RECORD variables. Possible child records are
      --        1 Quota Rules, Rule Uplifts, Trx Factors, periods.

      -- Case 2 Plan Element exists and adding new child records like quota rules,
      --       uplifts, trx factors, period quotas ( if no child record is passed
      --       then it is an error saying duplicate Plan element
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (x_loading_status <> 'PLN_QUOTA_EXISTS')
      THEN
      --x_status_code                       VARCHAR2,
      --clku PAYMENT ENHANCEMENT
      --clku, bug 2854576
      -- fmburu r12

         -- Plan Element does not exits, Create the New Plan Element
         cn_quotas_pkg.begin_record (x_operation                      => 'INSERT',
                                     x_org_id                         => l_pe_rec.org_id,
                                     x_object_version_number          => l_pe_rec.object_version_number,
                                     x_rowid                          => g_rowid,
                                     x_indirect_credit                => l_pe_rec.indirect_credit,
                                     x_quota_id                       => l_pe_rec.quota_id,
                                     x_name                           => l_pe_rec.NAME,
                                     x_target                         => l_pe_rec.target,
                                     x_quota_type_code                => l_pe_rec.quota_type_code,
                                     x_usage_code                     => NULL,
                                     x_payment_amount                 => l_pe_rec.payment_amount,
                                     x_description                    => l_pe_rec.description,
                                     x_start_date                     => l_pe_rec.start_date,
                                     x_end_date                       => l_pe_rec.end_date,
                                     x_quota_status                   => l_pe_rec.quota_status,
                                     x_calc_formula_id                => l_pe_rec.calc_formula_id,
                                     x_incentive_type_code            => l_pe_rec.incentive_type_code,
                                     x_credit_type_id                 => l_pe_rec.credit_type_id,
                                     x_rt_sched_custom_flag           => l_pe_rec.rt_sched_custom_flag,
                                     x_package_name                   => l_pe_rec.package_name,
                                     x_performance_goal               => l_pe_rec.performance_goal,
                                     x_interval_type_id               => l_pe_rec.interval_type_id,
                                     x_payee_assign_flag              => l_pe_rec.payee_assign_flag,
                                     x_vesting_flag                   => l_pe_rec.vesting_flag,
                                     x_expense_account_id             => l_p_plan_element_rec.expense_account_id,
                                     x_liability_account_id           => l_p_plan_element_rec.liability_account_id,
                                     x_quota_group_code               => l_p_plan_element_rec.quota_group_code,                                                                                                            --clku PAYMENT ENHANCEMENT,
                                     x_payment_group_code             => l_p_plan_element_rec.payment_group_code,
                                     x_quota_unspecified              => NULL,
                                     x_last_update_date               => g_last_update_date,
                                     x_last_updated_by                => g_last_updated_by,
                                     x_creation_date                  => g_creation_date,
                                     x_created_by                     => g_created_by,
                                     x_last_update_login              => g_last_update_login,
                                     x_program_type                   => g_program_type,
                                     x_period_type_code               => NULL,
                                     x_start_num                      => NULL,
                                     x_end_num                        => NULL,
                                     x_addup_from_rev_class_flag      => l_pe_rec.addup_from_rev_class_flag
                                                                                                           --clku, bug 2854576
         ,
                                     x_attribute_category             => l_p_plan_element_rec.attribute_category,
                                     x_attribute1                     => l_p_plan_element_rec.attribute1,
                                     x_attribute2                     => l_p_plan_element_rec.attribute2,
                                     x_attribute3                     => l_p_plan_element_rec.attribute3,
                                     x_attribute4                     => l_p_plan_element_rec.attribute4,
                                     x_attribute5                     => l_p_plan_element_rec.attribute5,
                                     x_attribute6                     => l_p_plan_element_rec.attribute6,
                                     x_attribute7                     => l_p_plan_element_rec.attribute7,
                                     x_attribute8                     => l_p_plan_element_rec.attribute8,
                                     x_attribute9                     => l_p_plan_element_rec.attribute9,
                                     x_attribute10                    => l_p_plan_element_rec.attribute10,
                                     x_attribute11                    => l_p_plan_element_rec.attribute11,
                                     x_attribute12                    => l_p_plan_element_rec.attribute12,
                                     x_attribute13                    => l_p_plan_element_rec.attribute13,
                                     x_attribute14                    => l_p_plan_element_rec.attribute14,
                                     x_attribute15                    => l_p_plan_element_rec.attribute15,
                                     x_salesrep_end_flag              =>  l_p_plan_element_rec.sreps_enddated_flag
                                    );
         -- Record succefully inserted..

         -- Call the Period Quotas local procedure to create Period Quotas
         create_period_quotas (p_api_version                => p_api_version,
                               p_init_msg_list              => p_init_msg_list,
                               p_commit                     => p_commit,
                               p_validation_level           => p_validation_level,
                               x_return_status              => x_return_status,
                               x_msg_count                  => x_msg_count,
                               x_msg_data                   => x_msg_data,
                               p_pe_rec                     => l_pe_rec,
                               p_period_quotas_rec_tbl      => l_p_period_quotas_rec_tbl,
                               p_quota_name                 => l_p_plan_element_rec.NAME,
                               p_loading_status             => x_loading_status,
                               x_loading_status             => l_loading_status,
                               p_is_duplicate               => p_is_duplicate
                              );
         x_loading_status := l_loading_status;

         -- Raise an Error if Fail Status
         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSE
            x_loading_status := 'CN_INSERTED';
         END IF;

         -- Record inserted successfully

         -- Call the Rate_quotas Procedure to create rate quota Assigns
         insert_rate_quotas (p_api_version                 => p_api_version,
                             p_init_msg_list               => p_init_msg_list,
                             p_commit                      => p_commit,
                             p_validation_level            => p_validation_level,
                             x_return_status               => x_return_status,
                             x_msg_count                   => x_msg_count,
                             x_msg_data                    => x_msg_data,
                             p_pe_rec                      => l_pe_rec,
                             p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                             p_quota_name                  => l_p_plan_element_rec.NAME,
                             p_loading_status              => x_loading_status,
                             x_loading_status              => l_loading_status
                            );
         x_loading_status := l_loading_status;

         -- Raise an Error if the Status is Failedx
         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSE
            x_loading_status := 'CN_INSERTED';
         END IF;
      -- Plan Quota exists then check for period quotas in passed then
      -- period quota customization.
      -- plan quota exists then check for the rt quota assigns if passed
      -- then insert the rt quota assigs into the table.
      ELSIF (x_loading_status = 'PLN_QUOTA_EXISTS') AND (l_p_period_quotas_rec_tbl.COUNT > 0 OR l_p_rt_quota_asgns_rec_tbl.COUNT > 0)
      THEN
         IF l_p_period_quotas_rec_tbl.COUNT > 0
         THEN
            x_loading_status := 'CN_INSERTED';
            -- Call the Period Quotas local procedure to create Period Quotas
            create_period_quotas (p_api_version                => p_api_version,
                                  p_init_msg_list              => p_init_msg_list,
                                  p_commit                     => p_commit,
                                  p_validation_level           => p_validation_level,
                                  x_return_status              => x_return_status,
                                  x_msg_count                  => x_msg_count,
                                  x_msg_data                   => x_msg_data,
                                  p_pe_rec                     => l_pe_rec,
                                  p_period_quotas_rec_tbl      => l_p_period_quotas_rec_tbl,
                                  p_quota_name                 => l_p_plan_element_rec.NAME,
                                  p_loading_status             => x_loading_status,
                                  x_loading_status             => l_loading_status,
                                  p_is_duplicate               => p_is_duplicate
                                 );
            x_loading_status := l_loading_status;

            -- Raise an error if the Return status is not success
            IF (x_return_status = fnd_api.g_ret_sts_success)
            THEN
               x_loading_status := 'CN_INSERTED';
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- Check for the Rate Quota Assigns
         IF (l_p_rt_quota_asgns_rec_tbl.COUNT > 0)
         THEN
            -- set the loading Status
            x_loading_status := 'CN_INSERTED';
            -- Call the Rate_quotas Procedure to create rate quota Assigns
            insert_rate_quotas (p_api_version                 => p_api_version,
                                p_init_msg_list               => p_init_msg_list,
                                p_commit                      => p_commit,
                                p_validation_level            => p_validation_level,
                                x_return_status               => x_return_status,
                                x_msg_count                   => x_msg_count,
                                x_msg_data                    => x_msg_data,
                                p_pe_rec                      => l_pe_rec,
                                p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                p_quota_name                  => l_p_plan_element_rec.NAME,
                                p_loading_status              => x_loading_status,
                                x_loading_status              => l_loading_status
                               );
            x_loading_status := l_loading_status;

            -- Raise an Error, if the Return status is not success
            IF (x_return_status = fnd_api.g_ret_sts_success)
            THEN
               x_loading_status := 'CN_INSERTED';
            ELSE
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      -- Check if all the children is not passed then there is a duplicate
      -- Quotas
      ELSIF (x_loading_status = 'PLN_QUOTA_EXISTS')
      THEN
         -- Here the Quota exists but there is no child passed no revenue class,
         -- trx factors, accelarator, period quotas, rate quotas
         -- Raise an error saying duplicate record
         IF (    l_p_revenue_class_rec_tbl.COUNT = 0
             AND l_p_rev_uplift_rec_tbl.COUNT = 0
             AND l_p_trx_factor_rec_tbl.COUNT = 0
             AND l_p_period_quotas_rec_tbl.COUNT = 0
             AND l_p_rt_quota_asgns_rec_tbl.COUNT = 0
            )
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'PLN_QUOTA_EXISTS');
               fnd_msg_pub.ADD;
            END IF;

            GOTO end_api_body;
         ELSE
            -- If Children record passed, set the status as CN_INSERTED
            x_loading_status := 'CN_INSERTED';
         END IF;
      ELSE
         -- Un known loading status
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Issue the Commit and recreate the Save Point.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Create new save point Revenue Class if it success all the PLAN_ELEMENT Validation
      -- and the status is CN_INSERTED and the table count for revenue class is > 0
      SAVEPOINT create_plan_element;

      IF (x_loading_status = 'CN_INSERTED')
      THEN
         -- Check the Table count is > 0 then Call the Group Package with
         -- table record and the Quota Type.
         IF l_p_revenue_class_rec_tbl.COUNT > 0
         THEN
            -- call the group api to insert the quota rules and  the trx factors.
            cn_quota_rules_grp.create_quota_rules (p_api_version                => p_api_version,
                                                   p_init_msg_list              => 'T',
                                                   p_commit                     => p_commit,
                                                   p_validation_level           => p_validation_level,
                                                   x_return_status              => x_return_status,
                                                   x_msg_count                  => x_msg_count,
                                                   x_msg_data                   => x_msg_data,
                                                   p_quota_name                 => l_p_plan_element_rec.NAME,
                                                   p_revenue_class_rec_tbl      => l_p_revenue_class_rec_tbl,
                                                   p_rev_uplift_rec_tbl         => l_p_rev_uplift_rec_tbl,
                                                   p_trx_factor_rec_tbl         => l_p_trx_factor_rec_tbl,
                                                   x_loading_status             => x_loading_status
                                                  );

                 -- standard check to insert status if the return status is not succes
            -- raise an error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         -- case 3:
         -- Plan Element Exists, Revenue Class record is not passed but
         -- cusomizing the trx factors.
         ELSIF (l_p_revenue_class_rec_tbl.COUNT = 0 AND l_p_trx_factor_rec_tbl.COUNT > 0)
         THEN
            -- Trx Factor data should be loaded from p_trx_factor_rec_tbl,
            -- Since we insert data with default value already, so need to
            -- Update with the new Factors
            -- Call the trx factors procedure
            trx_factors (x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_trx_factor_rec_tbl      => l_p_trx_factor_rec_tbl,
                         p_quota_id                => l_pe_rec.quota_id,
                         p_quota_name              => l_p_plan_element_rec.NAME,
                         p_loading_status          => x_loading_status,
                         x_loading_status          => l_loading_status
                        );
            x_loading_status := l_loading_status;

            -- Raise an Error if the return status not success
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;                                                                                              -- end if  x_loading_status = 'CN_INSERTED'

      -- If Quota Exists, Quota Rule Exists or not  then the quota Rule uplift
      -- Counter is > 0 then insert the Uplift Record.
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_p_rev_uplift_rec_tbl.COUNT > 0 AND x_loading_status = 'CN_INSERTED'
      THEN
         -- call the group API to create the quota rule uplifts
      FOR i IN l_p_rev_uplift_rec_tbl.FIRST .. l_p_rev_uplift_rec_tbl.LAST LOOP
      l_p_rev_uplift_rec_tbl1(i).org_id                        := l_p_rev_uplift_rec_tbl(i).org_id;
      l_p_rev_uplift_rec_tbl1(i).quota_rule_uplift_id          := NULL;
      l_p_rev_uplift_rec_tbl1(i).quota_rule_id                  :=NULL;
      l_p_rev_uplift_rec_tbl1(i).start_date                     :=l_p_rev_uplift_rec_tbl(i).start_date;
      l_p_rev_uplift_rec_tbl1(i).end_date                      := l_p_rev_uplift_rec_tbl(i).end_date;
      l_p_rev_uplift_rec_tbl1(i).payment_factor                 :=l_p_rev_uplift_rec_tbl(i).rev_class_payment_uplift;
      l_p_rev_uplift_rec_tbl1(i).quota_factor                   :=l_p_rev_uplift_rec_tbl(i).rev_class_quota_uplift;
      l_p_rev_uplift_rec_tbl1(i).object_version_number          := l_p_rev_uplift_rec_tbl(i).object_version_number;
      l_p_rev_uplift_rec_tbl1(i).rev_class_name                 := l_p_rev_uplift_rec_tbl(i).rev_class_name;
      l_p_rev_uplift_rec_tbl1(i).rev_class_name_old             :=l_p_rev_uplift_rec_tbl(i).rev_class_name_old;
      l_p_rev_uplift_rec_tbl1(i).start_date_old                 :=l_p_rev_uplift_rec_tbl(i).start_date;
      l_p_rev_uplift_rec_tbl1(i).end_date_old                   := l_p_rev_uplift_rec_tbl(i).start_date_old;
      END LOOP;
         cn_quota_rule_uplifts_grp.create_quota_rule_uplift (p_api_version             => p_api_version,
                                                             p_init_msg_list           => 'T',
                                                             p_commit                  => p_commit,
                                                             p_validation_level        => p_validation_level,
                                                             x_return_status           => x_return_status,
                                                             x_msg_count               => x_msg_count,
                                                             x_msg_data                => x_msg_data,
                                                             p_quota_name              => l_p_plan_element_rec.NAME,
                                                             p_rev_uplift_rec_tbl      => l_p_rev_uplift_rec_tbl1,--cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type
                                                             x_loading_status          => x_loading_status
                                                            );

         -- Raise an Error if the Status is not success
         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_loading_status <> 'CN_INSERTED')
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

/*  Post processing     */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'CREATE_PLAN_ELEMENT', 'A', 'V')
      THEN
         cn_plan_element_vuhk.create_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_plan_element_rec            => l_p_plan_element_rec,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                        p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'CREATE_PLAN_ELEMENT', 'A', 'C')
      THEN
         cn_plan_element_cuhk.create_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_plan_element_rec            => l_p_plan_element_rec,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                        p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      /* Following code is for message generation */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'CREATE_PLAN_ELEMENT', 'M', 'M')
      THEN
         IF (cn_plan_element_cuhk.ok_to_generate_msg (p_plan_element_rec            => l_p_plan_element_rec,
                                                      p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                      p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                      p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                      p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                      p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl
                                                     )
            )
         THEN
            -- XMLGEN.clearBindValues;
            -- XMLGEN.setBindValue( 'QUOTA_NAME', l_p_plan_element_rec.name);
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            jtf_usr_hks.load_bind_data (l_bind_data_id, 'QUOTA_NAME', l_p_plan_element_rec.NAME, 'S', 'T');
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'PL',
                                          p_bus_obj_name      => 'PLAN_ELEMENT',
                                          p_action_code       => 'I',                                                                /* I - Insert  */
                                          p_bind_data_id      => l_bind_data_id,
                                          p_oai_param         => NULL,
                                          p_oai_array         => l_oai_array,
                                          x_return_code       => x_return_status
                                         );

            IF (x_return_status = fnd_api.g_ret_sts_error)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- End of API body
      <<end_api_body>>
      NULL;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      --
      -- Standard call to get message count and if count is 1, get message info.
      --
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
      WHEN COLLECTION_IS_NULL
      THEN
         ROLLBACK TO create_plan_element;
         x_loading_status := 'COLLECTION_IS_NULL';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_BEYOND_COUNT
      THEN
         ROLLBACK TO create_plan_element;
         x_loading_status := 'SUBSCRIPT_BEYOND_COUNT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_OUTSIDE_LIMIT
      THEN
         ROLLBACK TO create_plan_element;
         x_loading_status := 'SUBSCRIPT_OUTSIDE_LIMIT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

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
   END create_plan_element;

--***********************Very Important Please Read**************************
-- 1. You Must the pass the full new record for update and the Unique key
--    on the _old column for indentifying the exact record.
--    Here is an Simple Example to Update the QUotas
--    You want to update the start date only on the Plan Element , but still
--    you need to pass all the new values on your input parameter. I mean
--    Plan Element Name, start_date, end date and other columns but you are only
--    passing the new value on the start date others are still carring the old
--    values, Because we need to validate the record again for certain business
--    rule. with your old Plan Element Name in p_quota_name_old
--   Detail Example
--   Old Record in the Database
--   Plan Element Name = 'Advanced Tec'
--   Start Date        = '01-JAN-99'
--   End Date          = '31-DEC-99'

   -- Now your Input parameter will be as follows for just changing the Start date
-- Assume you New Start Date will be 01-MAR-99

   -- P_plan_element_rec.name := 'Advanced Tec';
-- p_plan_element_rec.start_date := '01-MAR-99'
-- p_plan_element_rec.end_date   := '31-DEC-99'
-- for other colums pass the old values
-- p_quota_name_old        := 'Advanced Tec';

   -- For UPDATING THE CHILD RECORDS

   -- 2. If you want to just update the Child records,  Here also same as above
--    but you will be passing the old value as a part of your pl/sql table
--    still remenber you need to pass the P_quota_name_old to update the
--    child records. This program is always quota driven

   --    Example for Updating the Quota Rules

   --    You Want to Modify you rules Target
--    You Input Paramter is as follows

   --    p_quota_name_old is Mandatory
--    p_rev_class_rec_tbl.rev_class_name := 'All Hardware';
--    p_rev_class_rec_tbl.rev_class_target : = New_value
--    p_rev_class_rec_tbl.others_columns   := Old values
--    p_rev_class_rec_tbl.rev_class_name_old := 'All Hardware';

   --***************************************************************************
-- -------------------------------------------------------------------------+
-- | Procedure: Update_Plan_Element
-- | Description: This program will try to update the Plan Element.
-- | Note: ** Important **
-- | Update Plan Element with handled in different than the way you expect.
-- -------------------------------------------------------------------------+
   PROCEDURE update_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_new_plan_element_rec     IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_quota_name_old           IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       trx_factor_rec_tbl_type := g_miss_trx_factor_rec_tbl,
      p_period_quotas_rec_tbl    IN       period_quotas_rec_tbl_type := g_miss_period_quotas_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_pe_rec                      cn_chk_plan_element_pkg.pe_rec_type;
      l_pe_rec_old                  cn_chk_plan_element_pkg.pe_rec_type;
      l_trx_factor_rec_tbl          trx_factor_rec_tbl_type;
      l_quota_rule_id               NUMBER;
      l_quota_id                    NUMBER;
      l_rev_class_id                NUMBER;
      l_tmp                         NUMBER;
      l_p_new_plan_element_rec      plan_element_rec_type;
      l_p_quota_name_old            VARCHAR2 (80);
      l_p_revenue_class_rec_tbl     revenue_class_rec_tbl_type;
      l_p_rev_uplift_rec_tbl        rev_uplift_rec_tbl_type;

      l_p_rev_uplift_rec_tbl1       cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type;

      l_p_trx_factor_rec_tbl        trx_factor_rec_tbl_type;
      l_p_period_quotas_rec_tbl     period_quotas_rec_tbl_type;
      l_p_rt_quota_asgns_rec_tbl    rt_quota_asgns_rec_tbl_type;
      l_oai_array                   jtf_usr_hks.oai_data_array_type;
      l_bind_data_id                NUMBER;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      l_loading_status              VARCHAR (80);
      l_org_id                      NUMBER;
      l_status                      VARCHAR2(1);
      p_payment_group_code          l_p_new_plan_element_rec.payment_group_code%type;

      CURSOR c_srp_period_quota_csr (
         pe_quota_id                         cn_quotas.quota_id%TYPE
      )
      IS
         SELECT srp_period_quota_id,org_id
           FROM cn_srp_period_quotas
          WHERE quota_id = pe_quota_id;

      l_number_dim_old              NUMBER;
      l_number_dim_new              NUMBER;
      l_number_dim                  NUMBER;

      CURSOR get_number_dim (
         l_quota_id                          NUMBER
      )
      IS
         SELECT ccf.number_dim
           FROM cn_quotas_v cq,
                cn_calc_formulas ccf
          WHERE cq.quota_id = l_quota_id AND cq.calc_formula_id = ccf.calc_formula_id;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_plan_element;

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
      x_loading_status := 'CN_UPDATED';

      -- START OF MOAC ORG_ID VALIDATION
      l_org_id := p_new_plan_element_rec.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                       status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_plan_element_pub.update_plan_element.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- API body
      l_p_new_plan_element_rec := p_new_plan_element_rec;
      l_p_quota_name_old := p_quota_name_old;
      l_p_revenue_class_rec_tbl := p_revenue_class_rec_tbl;
      l_p_rev_uplift_rec_tbl := p_rev_uplift_rec_tbl;
      l_p_trx_factor_rec_tbl := p_trx_factor_rec_tbl;
      l_p_period_quotas_rec_tbl := p_period_quotas_rec_tbl;
      l_p_rt_quota_asgns_rec_tbl := p_rt_quota_asgns_rec_tbl;

      -- Validate Payment Group code

        validate_payment_group_code(x_return_status       => x_return_status,
                                  p_payment_group_code  => l_p_new_plan_element_rec.payment_group_code);

        IF (x_return_status <> fnd_api.g_ret_sts_success)
        THEN
             RAISE fnd_api.g_exc_error;
        END IF;

      /*  pre processing call  */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'UPDATE_PLAN_ELEMENT', 'B', 'C')
      THEN
         cn_plan_element_cuhk.update_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_new_plan_element_rec        => l_p_new_plan_element_rec,
                                                       p_quota_name_old              => l_p_quota_name_old,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                       p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'UPDATE_PLAN_ELEMENT', 'B', 'V')
      THEN
         cn_plan_element_vuhk.update_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_new_plan_element_rec        => l_p_new_plan_element_rec,
                                                       p_quota_name_old              => l_p_quota_name_old,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                       p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Store the User Input Value into The Local Variable.
      l_pe_rec :=
         convert_pe_user_input (x_return_status         => x_return_status,
                                p_plan_element_rec      => l_p_new_plan_element_rec,
                                p_loading_status        => x_loading_status,
                                x_loading_status        => l_loading_status
                               );
      x_loading_status := l_loading_status;
      x_loading_status := 'CN_UPDATED';

      -- Validate the Plan Element to Update
      -- Don't Validate the Plan Element if the i all the new value is Null
      -- ie the only way to by pass the validaion and insert the child record.

      -- Case 1:
      --        Update Plan Element Only
      -- Pass the Old Plan Element Name and New Plan Element Record with the
      -- full record even if you are not updating that column
      --
      IF (    l_p_new_plan_element_rec.NAME IS NULL
          AND l_p_new_plan_element_rec.description IS NULL
          AND l_p_new_plan_element_rec.element_type IS NULL
          AND l_p_new_plan_element_rec.incentive_type IS NULL
          AND l_p_new_plan_element_rec.credit_type IS NULL
          AND l_p_new_plan_element_rec.calc_formula_name IS NULL
          AND l_p_new_plan_element_rec.package_name IS NULL
          AND l_p_new_plan_element_rec.start_date IS NULL
          AND l_p_new_plan_element_rec.end_date IS NULL
          AND l_p_new_plan_element_rec.interval_name IS NULL
          AND l_p_quota_name_old IS NOT NULL
          AND (   l_p_revenue_class_rec_tbl.COUNT > 0
               OR l_p_rev_uplift_rec_tbl.COUNT > 0
               OR l_p_trx_factor_rec_tbl.COUNT > 0
               OR l_p_period_quotas_rec_tbl.COUNT > 0
               OR l_p_rt_quota_asgns_rec_tbl.COUNT > 0
              )
         )
      THEN
         x_loading_status := 'CN_CHILD';
         -- Check quota exists
         check_quota_exists (x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_quota_name_old      => l_p_quota_name_old,
                             x_quota_id            => l_pe_rec.quota_id,
                             p_loading_status      => x_loading_status,
                             x_loading_status      => l_loading_status
                            );
         x_loading_status := l_loading_status;
      ELSE
         -- Check Valid Update x
         check_valid_update (x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_quota_name_old      => l_p_quota_name_old,
                             p_new_pe_rec          => l_pe_rec,
                             x_old_pe_rec          => l_pe_rec_old,
                             p_loading_status      => x_loading_status,
                             x_loading_status      => l_loading_status
                            );
         x_loading_status := l_loading_status;
      END IF;

      -- Raise an Error
      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      ELSIF (x_loading_status = 'CN_UPDATED')
      THEN
         l_pe_rec.quota_id := l_pe_rec_old.quota_id;
         -- Table Handler
         cn_quotas_pkg.begin_record (x_operation                      => 'UPDATE',
                                     x_org_id                         => l_pe_rec.org_id,
                                     x_object_version_number          => l_pe_rec.object_version_number,
                                     x_indirect_credit                => l_pe_rec.indirect_credit,
                                     x_rowid                          => g_rowid,
                                     x_quota_id                       => l_pe_rec_old.quota_id,
                                     x_name                           => l_pe_rec.NAME,
                                     x_target                         => l_pe_rec.target,
                                     x_quota_type_code                => l_pe_rec.quota_type_code,
                                     x_usage_code                     => NULL,
                                     x_payment_amount                 => l_pe_rec.payment_amount,
                                     x_description                    => l_pe_rec.description,
                                     x_start_date                     => l_pe_rec.start_date,
                                     x_end_date                       => l_pe_rec.end_date,
                                     x_quota_status                         => l_pe_rec.quota_status,
                                     x_calc_formula_id                => l_pe_rec.calc_formula_id,
                                     x_incentive_type_code            => l_pe_rec.incentive_type_code,
                                     x_credit_type_id                 => l_pe_rec.credit_type_id,
                                     x_rt_sched_custom_flag           => l_pe_rec.rt_sched_custom_flag,
                                     x_package_name                   => l_pe_rec.package_name,
                                     x_performance_goal               => l_pe_rec.performance_goal,
                                     x_interval_type_id               => l_pe_rec.interval_type_id,
                                     x_payee_assign_flag              => l_pe_rec.payee_assign_flag,
                                     x_vesting_flag                   => l_pe_rec.vesting_flag,
                                     x_expense_account_id             => l_p_new_plan_element_rec.expense_account_id,
                                     x_liability_account_id           => l_p_new_plan_element_rec.liability_account_id,
                                     x_quota_group_code               => l_p_new_plan_element_rec.quota_group_code
                                                                                                                  --clku PAYMENT ENHANCEMENT,
         ,
                                     x_payment_group_code             => l_p_new_plan_element_rec.payment_group_code,
                                     x_quota_unspecified              => NULL,
                                     x_last_update_date               => g_last_update_date,
                                     x_last_updated_by                => g_last_updated_by,
                                     x_creation_date                  => g_creation_date,
                                     x_created_by                     => g_created_by,
                                     x_last_update_login              => g_last_update_login,
                                     x_program_type                   => g_program_type,
                                     x_period_type_code               => NULL,
                                     x_start_num                      => NULL,
                                     x_end_num                        => NULL,
                                     x_addup_from_rev_class_flag      => l_pe_rec.addup_from_rev_class_flag
                                                                                                           --clku, bug 2854576
         ,
                                     x_attribute_category             => l_p_new_plan_element_rec.attribute_category,
                                     x_attribute1                     => l_p_new_plan_element_rec.attribute1,
                                     x_attribute2                     => l_p_new_plan_element_rec.attribute2,
                                     x_attribute3                     => l_p_new_plan_element_rec.attribute3,
                                     x_attribute4                     => l_p_new_plan_element_rec.attribute4,
                                     x_attribute5                     => l_p_new_plan_element_rec.attribute5,
                                     x_attribute6                     => l_p_new_plan_element_rec.attribute6,
                                     x_attribute7                     => l_p_new_plan_element_rec.attribute7,
                                     x_attribute8                     => l_p_new_plan_element_rec.attribute8,
                                     x_attribute9                     => l_p_new_plan_element_rec.attribute9,
                                     x_attribute10                    => l_p_new_plan_element_rec.attribute10,
                                     x_attribute11                    => l_p_new_plan_element_rec.attribute11,
                                     x_attribute12                    => l_p_new_plan_element_rec.attribute12,
                                     x_attribute13                    => l_p_new_plan_element_rec.attribute13,
                                     x_attribute14                    => l_p_new_plan_element_rec.attribute14,
                                     x_attribute15                    => l_p_new_plan_element_rec.attribute15,
				     x_salesrep_end_flag              => l_p_new_plan_element_rec.sreps_enddated_flag
                                    );

         -- update expressions using this plan element
         IF (l_p_quota_name_old <> l_pe_rec.NAME)
         THEN
            chg_exprs (l_pe_rec_old.quota_id, l_p_quota_name_old, l_pe_rec.NAME);
         END IF;

         l_pe_rec.quota_id := l_pe_rec_old.quota_id;
         -- IF formula is changed and the ITD flag is Y then
         -- Call the Period Quotas to Insert or customise the
         -- New Period Quotas
         update_period_quotas (p_api_version           => p_api_version,
                               p_init_msg_list         => p_init_msg_list,
                               p_commit                => p_commit,
                               p_validation_level      => p_validation_level,
                               x_return_status         => x_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data,
                               p_pe_rec                => l_pe_rec,
                               p_pe_rec_old            => l_pe_rec_old,
                               p_period_quotas_rec_tbl =>l_p_period_quotas_rec_tbl,
                               p_quota_name            => l_p_quota_name_old,
                               p_loading_status        => x_loading_status,
                               x_loading_status        => l_loading_status
                              );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- check if we need to update the cn_srp_period_quotas ext table. If yes, update the table

         -- if the new assignement is external package, we do not do anything
         IF l_pe_rec.quota_type_code <> 'EXTERNAL'
         THEN
            -- if the old assignement is external package, we wipe out the ext table and re-insert the record
            IF l_pe_rec_old.quota_type_code = 'EXTERNAL'
            THEN
               OPEN get_number_dim (l_pe_rec_old.quota_id);

               FETCH get_number_dim
                INTO l_number_dim;

               CLOSE get_number_dim;

               IF l_number_dim > 1
               THEN
                  FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_pe_rec_old.quota_id)
                  LOOP
                     cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('DELETE', l_srp_period_quota_id.srp_period_quota_id,l_srp_period_quota_id.org_id);
                  END LOOP;

                  FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_pe_rec_old.quota_id)
                  LOOP
                     cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('INSERT', l_srp_period_quota_id.srp_period_quota_id,l_srp_period_quota_id.org_id, l_number_dim);
                  END LOOP;
               END IF;
            ELSIF l_pe_rec.calc_formula_id <> l_pe_rec_old.calc_formula_id
            THEN
               SELECT number_dim
                 INTO l_number_dim_old
                 FROM cn_calc_formulas
                WHERE calc_formula_id = l_pe_rec_old.calc_formula_id;

               SELECT number_dim
                 INTO l_number_dim_new
                 FROM cn_calc_formulas
                WHERE calc_formula_id = l_pe_rec.calc_formula_id;

               IF l_number_dim_new <> l_number_dim_old
               THEN
                  IF l_number_dim_new < l_number_dim_old
                  THEN
                     FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_pe_rec_old.quota_id)
                     LOOP
                        cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('DELETE', l_srp_period_quota_id.srp_period_quota_id,l_srp_period_quota_id.org_id);
                     END LOOP;
                  END IF;

                  -- if reduce # dims to 1, then no longer need _ext records
                  IF l_number_dim_new > 1
                  THEN
                     FOR l_srp_period_quota_id IN c_srp_period_quota_csr (l_pe_rec_old.quota_id)
                     LOOP
                        cn_srp_period_quotas_pkg.populate_srp_period_quotas_ext ('INSERT',
                                                                                 l_srp_period_quota_id.srp_period_quota_id,
                                                                                 l_number_dim_new
                                                                                );
                     END LOOP;
                  END IF;
               END IF;
            END IF;
         END IF;

         update_rate_quotas (p_api_version                 => p_api_version,
                             p_init_msg_list               => p_init_msg_list,
                             p_commit                      => p_commit,
                             p_validation_level            => p_validation_level,
                             x_return_status               => x_return_status,
                             x_msg_count                   => x_msg_count,
                             x_msg_data                    => x_msg_data,
                             p_pe_rec                      => l_pe_rec,
                             p_pe_rec_old                  => l_pe_rec_old,
                             p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                             p_quota_name                  => l_pe_rec.NAME,
                             p_loading_status              => x_loading_status,
                             x_loading_status              => l_loading_status
                            );
         x_loading_status := l_loading_status;

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         -- IF the aboce return Status IS success and one of  COUNT is
         -- Greater than 0 Then set the status as CN_CHILD and
         -- Call the Respective child Procedures
         IF     (x_return_status = fnd_api.g_ret_sts_success)
            AND (l_p_revenue_class_rec_tbl.COUNT > 0 OR l_p_trx_factor_rec_tbl.COUNT > 0 OR l_p_rev_uplift_rec_tbl.COUNT > 0)
         THEN
            x_loading_status := 'CN_CHILD';
         END IF;
      END IF;

      -- Issue the Commit Before start the Child Process
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Create new save point
      SAVEPOINT update_plan_element;

      -- Check for the Child Update
      IF x_loading_status = 'CN_CHILD'
      THEN
         IF l_p_revenue_class_rec_tbl.COUNT > 0
         THEN
            -- Call the Quota Rules Update Procedure if the Count IS > 0
            cn_quota_rules_grp.update_quota_rules (p_api_version                => p_api_version,
                                                   p_init_msg_list              => 'T',
                                                   p_commit                     => p_commit,
                                                   p_validation_level           => p_validation_level,
                                                   x_return_status              => x_return_status,
                                                   x_msg_count                  => x_msg_count,
                                                   x_msg_data                   => x_msg_data,
                                                   p_quota_name                 => NVL (l_pe_rec.NAME, l_p_quota_name_old),
                                                   p_revenue_class_rec_tbl      => l_p_revenue_class_rec_tbl,
                                                   p_trx_factor_rec_tbl         => l_p_trx_factor_rec_tbl,
                                                   x_loading_status             => x_loading_status
                                                  );

            -- if the Status is not success or the Loading Status is <> CN_UPDATED
            -- then Raise an Error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_loading_status <> 'CN_UPDATED')
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF (l_p_revenue_class_rec_tbl.COUNT = 0 AND l_p_trx_factor_rec_tbl.COUNT > 0)
         THEN
            -- Trx Factor data should be loaded from p_trx_factor_rec_tbl,
            -- Since we insert data with default value already, so need to
            -- Update with the new Factors
            FOR i IN l_p_trx_factor_rec_tbl.FIRST .. l_p_trx_factor_rec_tbl.LAST
            LOOP
               l_tmp := 0;

               IF l_trx_factor_rec_tbl.COUNT > 0
               THEN
                  FOR j IN l_trx_factor_rec_tbl.FIRST .. l_trx_factor_rec_tbl.LAST
                  LOOP
                     IF (l_p_trx_factor_rec_tbl (i).rev_class_name = l_trx_factor_rec_tbl (j).rev_class_name)
                     THEN
                        l_tmp := 1;
                     END IF;
                  END LOOP;
               END IF;

               IF l_tmp = 0
               THEN
                  l_trx_factor_rec_tbl (l_trx_factor_rec_tbl.COUNT + 1) := l_p_trx_factor_rec_tbl (i);
               END IF;
            END LOOP;

            -- Process the Actual Trx factors Record
            FOR i IN l_trx_factor_rec_tbl.FIRST .. l_trx_factor_rec_tbl.LAST
            LOOP
               -- Get revenue Class ID
               l_rev_class_id := cn_api.get_rev_class_id (RTRIM (LTRIM (l_trx_factor_rec_tbl (i).rev_class_name)),l_trx_factor_rec_tbl (i).org_id);
               -- Get Quota Rule ID, you need it to update the Trx Factors
               l_quota_rule_id :=
                  cn_chk_plan_element_pkg.get_quota_rule_id (p_quota_id          => NVL (l_pe_rec.quota_id, l_pe_rec_old.quota_id),
                                                             p_rev_class_id      => l_rev_class_id
                                                            );

               -- Loop through each record and update the mached one only
               FOR j IN l_p_trx_factor_rec_tbl.FIRST .. l_p_trx_factor_rec_tbl.LAST
               LOOP
                  -- If the Revenue class name of the Outer and the inner is same then
                  -- Update the Trx factors
                  IF (l_p_trx_factor_rec_tbl (j).rev_class_name = l_trx_factor_rec_tbl (i).rev_class_name)
                  THEN
                     -- Update the trx Factors
                     UPDATE cn_trx_factors
                        SET event_factor = l_p_trx_factor_rec_tbl (j).event_factor
                      WHERE quota_rule_id = l_quota_rule_id
                        AND quota_id = NVL (l_pe_rec.quota_id, l_pe_rec_old.quota_id)
                        AND trx_type = l_p_trx_factor_rec_tbl (j).trx_type;
                  END IF;                                                                                                         -- trx Factor Exists
               END LOOP;                                                                                                                   -- Trx Loop

               -- validate Rule :
               --  Check TRX_FACTORS
               --  1. Key Factor's total = 100
               --  2. Must have Trx_Factors
               cn_chk_plan_element_pkg.chk_trx_factor (x_return_status       => x_return_status,
                                                       p_quota_rule_id       => l_quota_rule_id,
                                                       p_rev_class_name      => l_trx_factor_rec_tbl (i).rev_class_name,
                                                       p_loading_status      => x_loading_status,
                                                       x_loading_status      => l_loading_status
                                                      );
               x_loading_status := l_loading_status;

               -- Raise an Error if the Status Is not success
               IF (x_return_status <> fnd_api.g_ret_sts_success) OR x_loading_status NOT IN ('CN_UPDATED', 'CN_INSERTED')
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END LOOP;                                                                                                                -- Outer trx Loop
         END IF;

         -- Check the Rev Uplift Count, if > 0 then Process the Records
         IF l_p_rev_uplift_rec_tbl.COUNT > 0
         THEN
           FOR i IN l_p_rev_uplift_rec_tbl.FIRST .. l_p_rev_uplift_rec_tbl.LAST LOOP
              l_p_rev_uplift_rec_tbl1(i).org_id                        := l_p_rev_uplift_rec_tbl(i).org_id;
              l_p_rev_uplift_rec_tbl1(i).quota_rule_uplift_id          := NULL;
              l_p_rev_uplift_rec_tbl1(i).quota_rule_id                  :=NULL;
              l_p_rev_uplift_rec_tbl1(i).start_date                     :=l_p_rev_uplift_rec_tbl(i).start_date;
              l_p_rev_uplift_rec_tbl1(i).end_date                      := l_p_rev_uplift_rec_tbl(i).end_date;
              l_p_rev_uplift_rec_tbl1(i).payment_factor                 :=l_p_rev_uplift_rec_tbl(i).rev_class_payment_uplift;
              l_p_rev_uplift_rec_tbl1(i).quota_factor                   :=l_p_rev_uplift_rec_tbl(i).rev_class_quota_uplift;
              l_p_rev_uplift_rec_tbl1(i).object_version_number          := l_p_rev_uplift_rec_tbl(i).object_version_number;
              l_p_rev_uplift_rec_tbl1(i).rev_class_name                 := l_p_rev_uplift_rec_tbl(i).rev_class_name;
              l_p_rev_uplift_rec_tbl1(i).rev_class_name_old             :=l_p_rev_uplift_rec_tbl(i).rev_class_name_old;
              l_p_rev_uplift_rec_tbl1(i).start_date_old                 :=l_p_rev_uplift_rec_tbl(i).start_date;
              l_p_rev_uplift_rec_tbl1(i).end_date_old                   := l_p_rev_uplift_rec_tbl(i).start_date_old;
          END LOOP;

            -- call the group API to create the quota rule uplifts
            cn_quota_rule_uplifts_grp.update_quota_rule_uplift (p_api_version             => p_api_version,
                                                                p_init_msg_list           => 'T',
                                                                p_commit                  => p_commit,
                                                                p_validation_level        => p_validation_level,
                                                                x_return_status           => x_return_status,
                                                                x_msg_count               => x_msg_count,
                                                                x_msg_data                => x_msg_data,
                                                                p_quota_name              => NVL (l_pe_rec.NAME, l_p_quota_name_old),
                                                                p_rev_uplift_rec_tbl      => l_p_rev_uplift_rec_tbl1,
                                                                x_loading_status          => x_loading_status
                                                               );

            -- Raise an Error if the Status is not SUCCESS or NOT CN_UPDATED
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_loading_status <> 'CN_UPDATED')
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- Check the Period Quotas counter Parameter if it is > 0 THEN
         -- Update the Period QUotas records by calling the
         -- Group API's
         IF l_p_period_quotas_rec_tbl.COUNT > 0
         THEN
            -- Call Period Quotas rec Procedure
            cn_period_quotas_grp.update_period_quotas (p_api_version                => p_api_version,
                                                       p_init_msg_list              => 'T',
                                                       p_commit                     => p_commit,
                                                       p_validation_level           => p_validation_level,
                                                       x_return_status              => x_return_status,
                                                       x_msg_count                  => x_msg_count,
                                                       x_msg_data                   => x_msg_data,
                                                       p_quota_name                 => NVL (l_pe_rec.NAME, l_p_quota_name_old),
                                                       p_period_quotas_rec_tbl      => l_p_period_quotas_rec_tbl,
                                                       x_loading_status             => x_loading_status
                                                      );

                 -- If the Return status is not success or not CN_UPDATED then
            -- Raise an Error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_loading_status <> 'CN_UPDATED')
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- Check the Rate QUota assigns table Parameter count if > 0
         -- Then Call the Update_rate_quota_assigns Private Package
         -- Procedure to Update the rate Quota assigns
         IF l_p_rt_quota_asgns_rec_tbl.COUNT > 0
         THEN
            -- Call Update the Rate Quota Assisns procedure
            cn_rt_quota_asgns_pvt.update_rt_quota_asgns (p_api_version                 => p_api_version,
                                                         p_init_msg_list               => 'T',
                                                         p_commit                      => p_commit,
                                                         p_validation_level            => p_validation_level,
                                                         x_return_status               => x_return_status,
                                                         x_msg_count                   => x_msg_count,
                                                         x_msg_data                    => x_msg_data,
                                                         p_quota_name                  => NVL (l_pe_rec.NAME, l_p_quota_name_old),
                                                         p_org_id                      => l_pe_rec.org_id,
                                                         p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                         x_loading_status              => x_loading_status,
                                                         x_object_version_number       => l_pe_rec.object_version_number
                                                        );

                 -- Raise an Error if the return status is not success or
            -- return loading status is NOT CN_UPDATED
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_loading_status <> 'CN_UPDATED')
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;                                                                                                 -- end if  x_loading_status = 'CN_CHILD'

/*  Post processing     */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'UPDATE_PLAN_ELEMENT', 'A', 'V')
      THEN
         cn_plan_element_vuhk.update_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_new_plan_element_rec        => l_p_new_plan_element_rec,
                                                        p_quota_name_old              => l_p_quota_name_old,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                        p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'UPDATE_PLAN_ELEMENT', 'A', 'C')
      THEN
         cn_plan_element_cuhk.update_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_new_plan_element_rec        => l_p_new_plan_element_rec,
                                                        p_quota_name_old              => l_p_quota_name_old,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                        p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      /* Following code is for message generation */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'UPDATE_PLAN_ELEMENT', 'M', 'M')
      THEN
         IF (cn_plan_element_cuhk.ok_to_generate_msg (p_plan_element_rec            => l_p_new_plan_element_rec,
                                                      p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                      p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                      p_trx_factor_rec_tbl          => l_p_trx_factor_rec_tbl,
                                                      p_period_quotas_rec_tbl       => l_p_period_quotas_rec_tbl,
                                                      p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                      p_plan_element_name           => l_p_quota_name_old
                                                     )
            )
         THEN
            -- XMLGEN.clearBindValues;
            -- XMLGEN.setBindValue( 'QUOTA_NAME', l_p_new_plan_element_rec.name);
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            jtf_usr_hks.load_bind_data (l_bind_data_id, 'QUOTA_NAME', l_p_new_plan_element_rec.NAME, 'S', 'T');
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'PL',
                                          p_bus_obj_name      => 'PLAN_ELEMENT',
                                          p_action_code       => 'U',                                                                /* U - Update  */
                                          p_bind_data_id      => l_bind_data_id,
                                          p_oai_param         => NULL,
                                          p_oai_array         => l_oai_array,
                                          x_return_code       => x_return_status
                                         );

            IF (x_return_status = fnd_api.g_ret_sts_error)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   -- End of Update Plan Element
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
      WHEN COLLECTION_IS_NULL
      THEN
         ROLLBACK TO update_plan_element;
         x_loading_status := 'COLLECTION_IS_NULL';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_BEYOND_COUNT
      THEN
         ROLLBACK TO update_plan_element;
         x_loading_status := 'SUBSCRIPT_BEYOND_COUNT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_OUTSIDE_LIMIT
      THEN
         ROLLBACK TO update_plan_element;
         x_loading_status := 'SUBSCRIPT_OUTSIDE_LIMIT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

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
   END update_plan_element;

-- End Update Plan Element

   /* ****************** */
/* MODIFIED - SBADAMI */
/* ****************** */

   -- Start of comments
-- API name    : delete_plan_element
-- Type        : Public
-- Pre-reqs    : None.
-- Purpose     : The following API performs the following
--               1. Deletes the Plan Element and it's associated records in
--               CN_QUOTAS, CN_QUOTA_RULES, CN_RT_QUOTA_ASGNS
--               2.
--               3.
-- Parameters  :
-- IN          :  p_api_version IN NUMBER API version
--                p_init_msg_list IN VARCHAR2 Initialize message list (default F)
--                p_commit IN VARCHAR2 Commit flag (default F).
--                p_validation_level IN NUMBER Validation level (default 100).
--                x_return_status IN VARCHAR2 Return Status
--                x_msg_count IN NUMBER Number of messages returned
--                x_msg_data IN VARCHAR2 Contents of message if x_msg_count = 1
--                x_loading_status IN VARCHAR2 Loading Status
--                p_quota_name IN VARCHAR2 Plan element details
--                p_revenue_class_rec_tbl  Revenue class details
--                p_rev_uplift_rec_tbl     Revenue class uplift factor details
--                p_rt_quota_asgns_rec_tbl Rate quota assigns details
-- Version     :  Initial version   1.0
-- End of comments

   -- -------------------------------------------------------------------------+
-- | Procedure: Delete_Plan_Element
-- | Description: This program will  Delete the Whole Plan Element if
-- | you are not passing any Child records. IF you want to delete the Plan
-- | Element just pass the Plan Element, don't pass any child records.
-- -------------------------------------------------------------------------+
   PROCEDURE process_input_records (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      p_quota_rec                IN OUT NOCOPY plan_element_rec_type ,
      p_revenue_class_rec_tbl    IN OUT NOCOPY revenue_class_rec_tbl_type ,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY rev_uplift_rec_tbl_type ,
      p_rt_quota_asgns_rec_tbl   IN OUT NOCOPY rt_quota_asgns_rec_tbl_type ,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'process_input_records';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_p_quota_name                cn_quotas.NAME%TYPE;
      l_loading_status              VARCHAR2 (80);
      l_org_id                      cn_quotas.org_id%TYPE;
      l_quota_id                    cn_quotas.quota_id%TYPE;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT process_input_records;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      l_p_quota_name := p_quota_rec.NAME;
      x_loading_status := 'CN_DELETED';

      /*  Resolve the quota_id and quota_name from */
      /*  1. If checks if quota_name passed is g_miss_char */
      IF ((cn_api.chk_miss_char_para (p_char_para           => l_p_quota_name,
                                      p_para_name           => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /*  2. if it is null character */
      IF ((cn_api.chk_null_char_para (p_char_para           => l_p_quota_name,
                                      p_obj_name            => cn_chk_plan_element_pkg.g_pe_name,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => l_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* 3. Org Id Validations to begin */
      l_org_id := p_quota_rec.org_id;

      IF l_org_id IS NULL
      THEN
         -- Need to get from MOAC Team some utility to default the OU
         NULL;
      END IF;

      -- l_org_id is still null we need to raise error
      check_org_id (l_org_id);
      -- Set the Plan Element Record Type to have the org_id
      p_quota_rec.org_id := l_org_id;
      /* 4. Get the Quota ID */
      l_quota_id := cn_chk_plan_element_pkg.get_quota_id (LTRIM (RTRIM (l_p_quota_name)), l_org_id);

      -- check the Quota id if the Quota ID is Null and the Quota name is Not null
      -- Raise an Error
      IF l_quota_id IS NULL AND l_p_quota_name IS NOT NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', l_p_quota_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_EXIST';
         RAISE fnd_api.g_exc_error;
      END IF;

      p_quota_rec.quota_id := l_quota_id;

      /* 5. Set all the child records org_id to be of the masters */
      IF p_revenue_class_rec_tbl.COUNT > 0
      THEN
         FOR i IN p_revenue_class_rec_tbl.FIRST .. p_revenue_class_rec_tbl.LAST
         LOOP
            p_revenue_class_rec_tbl (i).org_id := l_org_id;
         END LOOP;
      END IF;

      IF p_rev_uplift_rec_tbl.COUNT > 0
      THEN
         FOR i IN p_rev_uplift_rec_tbl.FIRST .. p_revenue_class_rec_tbl.LAST
         LOOP
            p_rev_uplift_rec_tbl (i).org_id := l_org_id;
         END LOOP;
      END IF;

      IF p_rt_quota_asgns_rec_tbl.COUNT > 0
      THEN
         FOR i IN p_rt_quota_asgns_rec_tbl.FIRST .. p_revenue_class_rec_tbl.LAST
         LOOP
            p_rt_quota_asgns_rec_tbl (i).org_id := l_org_id;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO process_input_records;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO process_input_records;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO process_input_records;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END process_input_records;

   PROCEDURE delete_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_rec                IN       plan_element_rec_type := g_miss_plan_element_rec,
      p_revenue_class_rec_tbl    IN       revenue_class_rec_tbl_type := g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       rev_uplift_rec_tbl_type := g_miss_rev_uplift_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       rt_quota_asgns_rec_tbl_type := g_miss_rt_quota_asgns_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_quota_id                    NUMBER;
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_p_quota_name                cn_quotas.NAME%TYPE;
      l_p_revenue_class_rec_tbl     revenue_class_rec_tbl_type;
      l_p_rev_uplift_rec_tbl        rev_uplift_rec_tbl_type;

      l_p_rev_uplift_rec_tbl1       cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type;

      l_p_rt_quota_asgns_rec_tbl    rt_quota_asgns_rec_tbl_type;
      l_oai_array                   jtf_usr_hks.oai_data_array_type;
      l_bind_data_id                NUMBER;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      l_loading_status              VARCHAR2 (80);
      l_org_id                      cn_quotas.org_id%TYPE;
      l_pvt_rec                     cn_plan_element_pvt.plan_element_rec_type;
      l_quota_rec                   plan_element_rec_type;
      l_return_status               VARCHAR2 (1000);
      l_msg_data                    VARCHAR2 (2000);
      l_msg_count                   NUMBER;
      l_load_status                 VARCHAR2 (1000);
      l_val_org_id                  NUMBER;
      l_status                      VARCHAR2(1);

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

      -- START OF MOAC ORG_ID VALIDATION
      l_val_org_id := p_quota_rec.org_id;
      mo_global.validate_orgid_pub_api(org_id => l_val_org_id,
                                       status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_plan_element_pub.delete_plan_element.org_validate',
	      		    'Validated org_id = ' || l_val_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- API body
      l_quota_rec := p_quota_rec;
      l_p_quota_name := p_quota_rec.NAME;
      l_p_revenue_class_rec_tbl := p_revenue_class_rec_tbl;
      l_p_rev_uplift_rec_tbl := p_rev_uplift_rec_tbl;
      l_p_rt_quota_asgns_rec_tbl := p_rt_quota_asgns_rec_tbl;

      --  ***TBD *** Need to call Process Records here
      process_input_records (p_quota_rec                   => l_quota_rec,
                             p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                             p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                             p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                             x_return_status               => l_return_status,
                             x_msg_count                   => l_msg_count,
                             x_msg_data                    => l_msg_data,
                             x_loading_status              => l_load_status
                            );
      x_loading_status := l_load_status;



      /* 1. Calling BEFORE-CUSTOM Hook */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DELETE_PLAN_ELEMENT', 'B', 'C')
      THEN
         cn_plan_element_cuhk.delete_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_quota_name                  => l_p_quota_name,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );
         check_status (p_return_status => x_return_status);
      END IF;

      /* 2. Calling BEFORE-VERTICAL Hook */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DELETE_PLAN_ELEMENT', 'B', 'V')
      THEN
         cn_plan_element_vuhk.delete_plan_element_pre (p_api_version                 => p_api_version,
                                                       p_init_msg_list               => p_init_msg_list,
                                                       p_commit                      => fnd_api.g_false,
                                                       p_validation_level            => p_validation_level,
                                                       x_return_status               => x_return_status,
                                                       x_msg_count                   => x_msg_count,
                                                       x_msg_data                    => x_msg_data,
                                                       p_quota_name                  => l_p_quota_name,
                                                       p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                       p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                       p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                       x_loading_status              => x_loading_status
                                                      );
         check_status (p_return_status => x_return_status);
      END IF;

      /* ## MAIN IF BEGINS ## */
      IF (x_return_status = fnd_api.g_ret_sts_success AND x_loading_status = 'CN_DELETED')
      THEN
         -- This is calling the group API (cnxgqrub.pls)
         -- Needs refactoring
         -- Check if the Uplift Rec table count is > 0
         IF l_p_rev_uplift_rec_tbl.COUNT > 0
         THEN
           FOR i IN l_p_rev_uplift_rec_tbl.FIRST .. l_p_rev_uplift_rec_tbl.LAST LOOP
              l_p_rev_uplift_rec_tbl1(i).org_id                        := l_p_rev_uplift_rec_tbl(i).org_id;
              l_p_rev_uplift_rec_tbl1(i).quota_rule_uplift_id          := NULL;
              l_p_rev_uplift_rec_tbl1(i).quota_rule_id                  :=NULL;
              l_p_rev_uplift_rec_tbl1(i).start_date                     :=l_p_rev_uplift_rec_tbl(i).start_date;
              l_p_rev_uplift_rec_tbl1(i).end_date                      := l_p_rev_uplift_rec_tbl(i).end_date;
              l_p_rev_uplift_rec_tbl1(i).payment_factor                 :=l_p_rev_uplift_rec_tbl(i).rev_class_payment_uplift;
              l_p_rev_uplift_rec_tbl1(i).quota_factor                   :=l_p_rev_uplift_rec_tbl(i).rev_class_quota_uplift;
              l_p_rev_uplift_rec_tbl1(i).object_version_number          := l_p_rev_uplift_rec_tbl(i).object_version_number;
              l_p_rev_uplift_rec_tbl1(i).rev_class_name                 := l_p_rev_uplift_rec_tbl(i).rev_class_name;
              l_p_rev_uplift_rec_tbl1(i).rev_class_name_old             :=l_p_rev_uplift_rec_tbl(i).rev_class_name_old;
              l_p_rev_uplift_rec_tbl1(i).start_date_old                 :=l_p_rev_uplift_rec_tbl(i).start_date;
              l_p_rev_uplift_rec_tbl1(i).end_date_old                   := l_p_rev_uplift_rec_tbl(i).start_date_old;
          END LOOP;

            -- Call the Delete Quota Rule Uplifts Group Package Procedure
            cn_quota_rule_uplifts_grp.delete_quota_rule_uplift (p_api_version             => p_api_version,
                                                                p_init_msg_list           => 'T',
                                                                p_commit                  => p_commit,
                                                                p_validation_level        => p_validation_level,
                                                                x_return_status           => x_return_status,
                                                                x_msg_count               => x_msg_count,
                                                                x_msg_data                => x_msg_data,
                                                                p_quota_name              => l_p_quota_name,
                                                                p_rev_uplift_rec_tbl      => l_p_rev_uplift_rec_tbl1,
                                                                x_loading_status          => x_loading_status
                                                               );
            -- if the Return status is not success then Raise an Error
            check_status (p_return_status => x_return_status);
         END IF;

         -- This is calling the group API (cnxvrqab.pls)
         -- Needs refactoring
         -- Check if the Rate Quota Assigns Table count is > 0
         IF l_p_rt_quota_asgns_rec_tbl.COUNT > 0
         THEN
            -- Call the rate_quota_assigns delete package procedure to delete the
            -- rate quota Assigns
            cn_rt_quota_asgns_pvt.delete_rt_quota_asgns (p_api_version                 => p_api_version,
                                                         p_init_msg_list               => 'T',
                                                         p_commit                      => p_commit,
                                                         p_validation_level            => p_validation_level,
                                                         x_return_status               => x_return_status,
                                                         x_msg_count                   => x_msg_count,
                                                         x_msg_data                    => x_msg_data,
                                                         p_quota_name                  => l_p_quota_name,
                                                         p_org_id                      => p_quota_rec.org_id,
                                                         p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                         x_loading_status              => x_loading_status
                                                        );
            -- if the Return status is not success then Raise an Error
            check_status (p_return_status => x_return_status);
         END IF;

         -- Check if the Revenue class table Count is Greater than 0 then
         -- Delete the revenue class by calling the Quota Rules Package
         IF l_p_revenue_class_rec_tbl.COUNT > 0
         THEN
            -- Call the Quota Rules group Package to Delete the Quota Rules
            -- It will cascade the Child records as well.
            -- Previously this used to call the group API. During the
            -- rewrite in R12 the group api for quota rules was eliminated and
            -- the code was added in cn_quota_rules_pvt itself.
            cn_quota_rule_pvt.delete_quota_rules (p_api_version                => p_api_version,
                                                  p_init_msg_list              => p_init_msg_list,
                                                  p_commit                     => p_commit,
                                                  p_validation_level           => p_validation_level,
                                                  x_return_status              => x_return_status,
                                                  x_msg_count                  => x_msg_count,
                                                  x_msg_data                   => x_msg_data,
                                                  p_quota_name                 => l_p_quota_name,
                                                  p_revenue_class_rec_tbl      => l_p_revenue_class_rec_tbl,
                                                  x_loading_status             => x_loading_status
                                                 );

            -- if the Return status is not success then Raise an Error
            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         /* If no Child record is Passed then Delete the Parent Record
            The Plan Element. It will cascade the Rest of the Child
            Records */
         IF l_p_revenue_class_rec_tbl.COUNT = 0 AND l_p_rt_quota_asgns_rec_tbl.COUNT = 0 AND l_p_rev_uplift_rec_tbl.COUNT = 0
         THEN
            --l_pvt_rec.quota_id := l_quota_id;
              l_pvt_rec.quota_id := p_quota_rec.quota_id;
	      l_pvt_rec.name := p_quota_rec.name;
	      l_pvt_rec.org_id := p_quota_rec.org_id;


            -- Delete the Plan Element. Calls the private API rather than calling the PKG or TH
            cn_plan_element_pvt.delete_plan_element (p_api_version           => p_api_version,
                                                     p_init_msg_list         => p_init_msg_list,
                                                     p_commit                => p_commit,
                                                     p_validation_level      => p_validation_level,
                                                     p_plan_element          => l_pvt_rec,
                                                     x_return_status         => x_return_status,
                                                     x_msg_count             => x_msg_count,
                                                     x_msg_data              => x_msg_data
                                                    );
            check_status (p_return_status => x_return_status);
         END IF;
      END IF;                                                                                                                 /* ## MAIN IF ENDS ## */

      /*  Post processing     */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DELETE_PLAN_ELEMENT', 'A', 'V')
      THEN
         cn_plan_element_vuhk.delete_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_quota_name                  => l_p_quota_name,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );
         check_status (p_return_status => x_return_status);
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DELETE_PLAN_ELEMENT', 'A', 'C')
      THEN
         cn_plan_element_cuhk.delete_plan_element_post (p_api_version                 => p_api_version,
                                                        p_init_msg_list               => p_init_msg_list,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_validation_level            => p_validation_level,
                                                        x_return_status               => x_return_status,
                                                        x_msg_count                   => x_msg_count,
                                                        x_msg_data                    => x_msg_data,
                                                        p_quota_name                  => l_p_quota_name,
                                                        p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                        p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                        p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl,
                                                        x_loading_status              => x_loading_status
                                                       );
         check_status (p_return_status => x_return_status);
      END IF;

      /* Following code is for message generation */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DELETE_PLAN_ELEMENT', 'M', 'M')
      THEN
         IF (cn_plan_element_cuhk.ok_to_generate_msg (p_plan_element_name           => l_p_quota_name,
                                                      p_revenue_class_rec_tbl       => l_p_revenue_class_rec_tbl,
                                                      p_rev_uplift_rec_tbl          => l_p_rev_uplift_rec_tbl,
                                                      p_rt_quota_asgns_rec_tbl      => l_p_rt_quota_asgns_rec_tbl
                                                     )
            )
         THEN
            -- XMLGEN.clearBindValues;
            -- XMLGEN.setBindValue('QUOTA_NAME', l_p_quota_name);
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            jtf_usr_hks.load_bind_data (l_bind_data_id, 'QUOTA_NAME', l_p_quota_name, 'S', 'T');
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'PL',
                                          p_bus_obj_name      => 'PLAN_ELEMENT',
                                          p_action_code       => 'D',                                                                /* D - Delete  */
                                          p_bind_data_id      => l_bind_data_id,
                                          p_oai_param         => NULL,
                                          p_oai_array         => l_oai_array,
                                          x_return_code       => x_return_status
                                         );
            check_status (p_return_status => x_return_status);
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Standard Commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      --
      -- Standard call to get message count and if count is 1, get message info.
      --
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   -- End of Delete Plan Element
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
   END delete_plan_element;

-- -------------------------------------------------------------------------+
-- | Procedure: Get_Plan_Element
-- | Description: This is a local procedure, will be called from when you dup
-- | Duplicate the Plan ELement.
-- | It will populate all the PL/SQL Table ( Child records for the Given
-- | Quota name and Pass it back to the calling Place.
-- -------------------------------------------------------------------------+
   PROCEDURE get_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_name        IN       cn_quotas.NAME%TYPE,
      p_org_id                   IN  cn_quotas.org_id%TYPE,
      x_plan_element_rec         OUT NOCOPY plan_element_rec_type,
      x_revenue_class_rec_tbl    OUT NOCOPY revenue_class_rec_tbl_type,
      x_rev_uplift_rec_tbl       OUT NOCOPY rev_uplift_rec_tbl_type,
      x_trx_factor_rec_tbl       OUT NOCOPY trx_factor_rec_tbl_type,
      x_period_quotas_rec_tbl    OUT NOCOPY period_quotas_rec_tbl_type,
      x_rt_quota_asgns_rec_tbl   OUT NOCOPY rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Get Plan Element';
      l_rule_index                  NUMBER;
      l_lift_index                  NUMBER;
      l_trx_index                   NUMBER;
      l_rt_index                    NUMBER;
      l_quota_rule_id               NUMBER;
      l_period_index                NUMBER;
      l_pe_name                     cn_quotas.NAME%TYPE;
      l_quota_id                    cn_quotas.quota_id%TYPE;
      l_revenue_class_id            cn_quota_rules.revenue_class_id%TYPE;

      -- Quotas Cursor
      CURSOR c_plan_element_rec_csr (
         pe_name                             cn_quotas.NAME%TYPE
      )
      IS
         SELECT q.quota_id quota_id,
                q.NAME,
                q.description,
                NULL period_type,
                cn_api.get_lkup_meaning (q.quota_type_code, 'QUOTA_TYPE') element_type,
                q.target,
                cn_api.get_lkup_meaning (q.incentive_type_code, 'INCENTIVE_TYPE') incentive_type,
                ct.NAME credit_type,
                cf.NAME calc_formula_name,
                q.rt_sched_custom_flag,
                q.package_name,
                q.performance_goal,
                q.payment_amount,
                q.start_date,
                q.end_date,
                q.quota_status,
                cit.NAME interval_name,
                q.payee_assign_flag,
                q.vesting_flag,
                q.addup_from_rev_class_flag,
                q.expense_account_id,
                q.liability_account_id,
                q.quota_group_code,
                q.attribute_category,
                q.attribute1,
                q.attribute2,
                q.attribute3,
                q.attribute4,
                q.attribute5,
                q.attribute6,
                q.attribute7,
                q.attribute8,
                q.attribute9,
                q.attribute10,
                q.attribute11,
                q.attribute12,
                q.attribute13,
                q.attribute14,
                q.attribute15,
                -- Bug 2531254
                q.payment_group_code,
                --CHANTHON:ADding org_id
                q.org_id,
                q.indirect_credit,
                q.salesreps_enddated_flag
           FROM cn_quotas q,
                cn_credit_types ct,
                cn_calc_formulas cf,
                cn_interval_types cit
          WHERE q.NAME = pe_name
                AND q.org_id = p_org_id
                --AND q.credit_type_id = ct.credit_type_id(+)
                --AND q.calc_formula_id = cf.calc_formula_id(+)
                --AND q.interval_type_id = cit.interval_type_id(+)
                AND q.credit_type_id = ct.credit_type_id(+)
                AND ct.org_id(+) = q.org_id
                AND q.calc_formula_id = cf.calc_formula_id(+)
                AND cf.org_id(+) = q.org_id
                AND q.interval_type_id = cit.interval_type_id(+)
                AND cit.org_id(+) = q.org_id
                AND delete_flag='N';

      -- Quota Rules Cursor
      CURSOR c_quota_rules_rec_csr (
         pe_id                               cn_quotas.quota_id%TYPE
      )
      IS
         SELECT qr.quota_rule_id,
                rc.NAME rev_class_name,
                qr.target rev_class_target,
                qr.payment_amount rev_class_payment_amount,
                qr.performance_goal rev_class_performance_goal,
                qr.description,
                qr.attribute_category,
                qr.attribute1,
                qr.attribute2,
                qr.attribute3,
                qr.attribute4,
                qr.attribute5,
                qr.attribute6,
                qr.attribute7,
                qr.attribute8,
                qr.attribute9,
                qr.attribute10,
                qr.attribute11,
                qr.attribute12,
                qr.attribute13,
                qr.attribute14,
                qr.attribute15,
                qr.org_id
           FROM cn_revenue_classes rc,
                cn_quota_rules qr
          WHERE qr.revenue_class_id = rc.revenue_class_id AND quota_id = pe_id;

      -- Quota rule uplifts
      CURSOR c_rule_uplift_rec_csr (
         p_quota_rule_id                     cn_quota_rules.quota_rule_id%TYPE
      )
      IS
         SELECT   NULL rev_class_name,
                  qru.start_date,
                  qru.end_date,
                  qru.payment_factor rev_class_payment_uplift,
                  qru.quota_factor rev_class_quota_uplift,
                  qru.attribute_category,
                  qru.attribute1,
                  qru.attribute2,
                  qru.attribute3,
                  qru.attribute4,
                  qru.attribute5,
                  qru.attribute6,
                  qru.attribute7,
                  qru.attribute8,
                  qru.attribute9,
                  qru.attribute10,
                  qru.attribute11,
                  qru.attribute12,
                  qru.attribute13,
                  qru.attribute14,
                  qru.attribute15,
                  NULL rev_class_name_old,
                  NULL start_date1,
                  NULL start_date2,
                  qru.org_id org_id,
                  qru.object_version_number object_version_number
             FROM cn_quota_rule_uplifts qru
            WHERE qru.quota_rule_id = p_quota_rule_id
         ORDER BY start_date;

      -- Trx Factors Cursor
      CURSOR c_trx_factor_rec_csr (
         pe_id                               cn_quotas.quota_id%TYPE,
         p_quota_rule_id                     cn_quota_rules.quota_rule_id%TYPE
      )
      IS
         SELECT tf.trx_type,
                tf.event_factor,
                tf.org_id
           -- rev_class_name get it from previous cursor
         FROM   cn_trx_factors tf
          WHERE tf.quota_id = pe_id AND tf.quota_rule_id = p_quota_rule_id;

      -- Period Quotas Cursor
      CURSOR c_period_quotas_rec_csr (
         pe_id                               cn_quotas.quota_id%TYPE
      )
      IS
         SELECT cn_api.get_acc_period_name (period_id,org_id) period_name,
                period_target,
                period_payment,
                performance_goal,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                NULL period_name_old,
                org_id
           FROM cn_period_quotas
          WHERE quota_id = pe_id;

      -- Rate Quota Assigns Cursor
      CURSOR c_rt_quota_asgns_rec_csr (
         pe_id                               cn_quotas.quota_id%TYPE
      )
      IS
         SELECT   cn_api.get_rate_table_name (rate_schedule_id) rate_schedule_name,
                  cn_chk_plan_element_pkg.get_calc_formula_name (calc_formula_id) calc_formula_name,
                  start_date,
                  end_date,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13,
                  attribute14,
                  attribute15,
                  NULL rate_schedule_name_old,
                  NULL start_date1,
                  NULL start_date2,
                  org_id
             FROM cn_rt_quota_asgns
            WHERE quota_id = pe_id
         ORDER BY start_date;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT get_plan_element;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (p_api_version, p_api_version, l_api_name, g_pkg_name)
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
      x_loading_status := 'CN_RETURNED';
      -- API body
      -- Remove the spaces in the Quota name
      l_pe_name := LTRIM (RTRIM (p_plan_element_name));

      -- Open the Plan ELement Cursor
      OPEN c_plan_element_rec_csr (l_pe_name);

      FETCH c_plan_element_rec_csr
       INTO l_quota_id,
            x_plan_element_rec.NAME,
            x_plan_element_rec.description,
            x_plan_element_rec.period_type,
            x_plan_element_rec.element_type,
            x_plan_element_rec.target,
            x_plan_element_rec.incentive_type,
            x_plan_element_rec.credit_type,
            x_plan_element_rec.calc_formula_name,
            x_plan_element_rec.rt_sched_custom_flag,
            x_plan_element_rec.package_name,
            x_plan_element_rec.performance_goal,
            x_plan_element_rec.payment_amount,
            x_plan_element_rec.start_date,
            x_plan_element_rec.end_date,
            x_plan_element_rec.status,
            x_plan_element_rec.interval_name,
            x_plan_element_rec.payee_assign_flag,
            x_plan_element_rec.vesting_flag,
            x_plan_element_rec.addup_from_rev_class_flag,
            x_plan_element_rec.expense_account_id,
            x_plan_element_rec.liability_account_id,
            x_plan_element_rec.quota_group_code,
            x_plan_element_rec.attribute_category,
            x_plan_element_rec.attribute1,
            x_plan_element_rec.attribute2,
            x_plan_element_rec.attribute3,
            x_plan_element_rec.attribute4,
            x_plan_element_rec.attribute5,
            x_plan_element_rec.attribute6,
            x_plan_element_rec.attribute7,
            x_plan_element_rec.attribute8,
            x_plan_element_rec.attribute9,
            x_plan_element_rec.attribute10,
            x_plan_element_rec.attribute11,
            x_plan_element_rec.attribute12,
            x_plan_element_rec.attribute13,
            x_plan_element_rec.attribute14,
            x_plan_element_rec.attribute15,
            -- bug 2531254
            x_plan_element_rec.payment_group_code,
            --chanthon:org_id
            x_plan_element_rec.org_id,
            x_plan_element_rec.indirect_credit,
            x_plan_element_rec.sreps_enddated_flag;

      CLOSE c_plan_element_rec_csr;

      -- Check the Quota ID for for the Quota Name you Passed
      -- if the Quota ID id null then raise an Error
      IF l_quota_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PLN_NOT_EXIST');
            fnd_message.set_token ('PE_NAME', l_pe_name);
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_NOT_EXIST';
         GOTO end_api;
      END IF;

      -- initilize the index values.
      l_rule_index := 1;
      l_trx_index := 1;
      l_period_index := 1;
      l_lift_index := 1;
      l_rt_index := 1;

      -- Open the Quota Rules Cursor and Populate the corresponding
      -- Pl/SQL table for the Quota Rules
      FOR l_quota_rule IN c_quota_rules_rec_csr (l_quota_id)
      LOOP
         l_quota_rule_id := l_quota_rule.quota_rule_id;
         x_revenue_class_rec_tbl (l_rule_index).rev_class_name := l_quota_rule.rev_class_name;
         x_revenue_class_rec_tbl (l_rule_index).rev_class_target := l_quota_rule.rev_class_target;
         x_revenue_class_rec_tbl (l_rule_index).rev_class_payment_amount := l_quota_rule.rev_class_payment_amount;
         x_revenue_class_rec_tbl (l_rule_index).rev_class_performance_goal := l_quota_rule.rev_class_performance_goal;
         x_revenue_class_rec_tbl (l_rule_index).description := l_quota_rule.description;
         x_revenue_class_rec_tbl (l_rule_index).attribute_category := l_quota_rule.attribute_category;
         x_revenue_class_rec_tbl (l_rule_index).attribute1 := l_quota_rule.attribute1;
         x_revenue_class_rec_tbl (l_rule_index).attribute2 := l_quota_rule.attribute2;
         x_revenue_class_rec_tbl (l_rule_index).attribute3 := l_quota_rule.attribute3;
         x_revenue_class_rec_tbl (l_rule_index).attribute4 := l_quota_rule.attribute4;
         x_revenue_class_rec_tbl (l_rule_index).attribute5 := l_quota_rule.attribute5;
         x_revenue_class_rec_tbl (l_rule_index).attribute6 := l_quota_rule.attribute6;
         x_revenue_class_rec_tbl (l_rule_index).attribute7 := l_quota_rule.attribute7;
         x_revenue_class_rec_tbl (l_rule_index).attribute8 := l_quota_rule.attribute8;
         x_revenue_class_rec_tbl (l_rule_index).attribute9 := l_quota_rule.attribute9;
         x_revenue_class_rec_tbl (l_rule_index).attribute10 := l_quota_rule.attribute10;
         x_revenue_class_rec_tbl (l_rule_index).attribute11 := l_quota_rule.attribute11;
         x_revenue_class_rec_tbl (l_rule_index).attribute12 := l_quota_rule.attribute12;
         x_revenue_class_rec_tbl (l_rule_index).attribute13 := l_quota_rule.attribute13;
         x_revenue_class_rec_tbl (l_rule_index).attribute14 := l_quota_rule.attribute14;
         x_revenue_class_rec_tbl (l_rule_index).attribute15 := l_quota_rule.attribute15;
         x_revenue_class_rec_tbl (l_rule_index).org_id := l_quota_rule.org_id;

         -- looping the Trx factors for the Given quota and Quota Rules
         -- Populate the PL/SQL Table
         OPEN c_trx_factor_rec_csr (l_quota_id, l_quota_rule_id);

         LOOP
            FETCH c_trx_factor_rec_csr
             INTO x_trx_factor_rec_tbl (l_trx_index).trx_type,
                  x_trx_factor_rec_tbl (l_trx_index).event_factor,
                  x_trx_factor_rec_tbl (l_trx_index).org_id;

            EXIT WHEN c_trx_factor_rec_csr%NOTFOUND;
            x_trx_factor_rec_tbl (l_trx_index).rev_class_name := x_revenue_class_rec_tbl (l_rule_index).rev_class_name;
            l_trx_index := l_trx_index + 1;
         END LOOP;

         CLOSE c_trx_factor_rec_csr;

         -- Looping the rule uplifs for the Given Quota ans Quota Rules
         -- Populate the PL/SQl Table
         OPEN c_rule_uplift_rec_csr (l_quota_rule_id);

         LOOP
            FETCH c_rule_uplift_rec_csr
             INTO x_rev_uplift_rec_tbl (l_lift_index);

            EXIT WHEN c_rule_uplift_rec_csr%NOTFOUND;
            x_rev_uplift_rec_tbl (l_lift_index).rev_class_name := x_revenue_class_rec_tbl (l_rule_index).rev_class_name;
            l_lift_index := l_lift_index + 1;
         END LOOP;

         CLOSE c_rule_uplift_rec_csr;

         l_rule_index := l_rule_index + 1;
      END LOOP;

      -- Open the period Quotas Cursor to Populate the Periods Quotas
      -- PL/SQL table
      OPEN c_period_quotas_rec_csr (l_quota_id);

      LOOP
         FETCH c_period_quotas_rec_csr
          INTO x_period_quotas_rec_tbl (l_period_index);

         EXIT WHEN c_period_quotas_rec_csr%NOTFOUND;
         l_period_index := l_period_index + 1;
      END LOOP;

      CLOSE c_period_quotas_rec_csr;

      -- Open the Rate quota asgns Cursor to Populate the PL/SQL table
      OPEN c_rt_quota_asgns_rec_csr (l_quota_id);

      LOOP
         FETCH c_rt_quota_asgns_rec_csr
          INTO x_rt_quota_asgns_rec_tbl (l_rt_index);

         EXIT WHEN c_rt_quota_asgns_rec_csr%NOTFOUND;
         l_rt_index := l_rt_index + 1;
      END LOOP;

      CLOSE c_rt_quota_asgns_rec_csr;

      --  End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      <<end_api>>
      NULL;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
-- END get plan element
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO get_plan_element;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN COLLECTION_IS_NULL
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'COLLECTION_IS_NULL';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN NO_DATA_FOUND
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'NO_DATA_FOUND';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_BEYOND_COUNT
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'SUBSCRIPT_BEYOND_COUNT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN SUBSCRIPT_OUTSIDE_LIMIT
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'SUBSCRIPT_OUTSIDE_LIMIT';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO get_plan_element;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END get_plan_element;

-- -------------------------------------------------------------------------+
-- | Procedure: Duplicate_Plan_Element
-- | Description: This is a Public API to help the USer to Duplicate the
-- | Existing Plan Element with just changing the Plan Element Name_2
-- | Note: ** Important **
-- | It creates all the Respective Child records for that Plan Element
----------------------------------------------------------------------------+
   PROCEDURE duplicate_plan_element (
      p_api_version              IN       NUMBER := 0,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_name        IN       cn_quotas.NAME%TYPE := cn_api.g_miss_char,
      p_org_id                   IN NUMBER,
      x_plan_element_name        OUT NOCOPY cn_quotas.NAME%TYPE,
      x_loading_status           OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Duplicate_Plan_Element';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_plan_element_rec            cn_plan_element_pub.plan_element_rec_type;
      l_revenue_class_rec_tbl       cn_plan_element_pub.revenue_class_rec_tbl_type;
      l_rev_uplift_rec_tbl          cn_plan_element_pub.rev_uplift_rec_tbl_type;
      l_pe_rec_tbl                  cn_chk_plan_element_pkg.pe_rec_tbl_type;
      l_trx_factor_rec_tbl          cn_plan_element_pub.trx_factor_rec_tbl_type;
      l_period_quotas_rec_tbl       cn_plan_element_pub.period_quotas_rec_tbl_type;
      l_rt_quota_asgns_rec_tbl      cn_plan_element_pub.rt_quota_asgns_rec_tbl_type;
      l_length                      INTEGER := 30 - LENGTHB ('_2');
      l_name_too_long               VARCHAR2 (1) := 'F';
      l_quota_id                    NUMBER;
      l_warning_flag                VARCHAR2 (1) := 'F';
      l_p_plan_element_name         cn_quotas.NAME%TYPE;
      l_x_plan_element_name         cn_quotas.NAME%TYPE;
      l_oai_array                   jtf_usr_hks.oai_data_array_type;
      l_bind_data_id                NUMBER;
      l_org_id                      NUMBER;
      l_status                      VARCHAR2(1);
      l_suffix varchar2(10) := null;
      l_prefix varchar2(10) := null;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT duplicate_pe;

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
      x_loading_status := 'CN_INSERTED';

      -- START OF MOAC ORG_ID VALIDATION
      l_org_id := p_org_id;
      mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                       status => l_status);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_plan_element_pub.duplicate_plan_element.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
      end if;
      -- END OF MOAC ORG_ID VALIDATION

      -- API body
      l_p_plan_element_name := p_plan_element_name;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DUPLICATE_PLAN_ELEMENT', 'B', 'C')
      THEN
         cn_plan_element_cuhk.duplicate_plan_element_pre (p_api_version            => p_api_version,
                                                          p_init_msg_list          => p_init_msg_list,
                                                          p_commit                 => fnd_api.g_false,
                                                          p_validation_level       => p_validation_level,
                                                          x_return_status          => x_return_status,
                                                          x_msg_count              => x_msg_count,
                                                          x_msg_data               => x_msg_data,
                                                          p_plan_element_name      => l_p_plan_element_name,
                                                          x_plan_element_name      => l_x_plan_element_name,
                                                          x_loading_status         => x_loading_status
                                                         );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DUPLICATE_PLAN_ELEMENT', 'B', 'V')
      THEN
         cn_plan_element_vuhk.duplicate_plan_element_pre (p_api_version            => p_api_version,
                                                          p_init_msg_list          => p_init_msg_list,
                                                          p_commit                 => fnd_api.g_false,
                                                          p_validation_level       => p_validation_level,
                                                          x_return_status          => x_return_status,
                                                          x_msg_count              => x_msg_count,
                                                          x_msg_data               => x_msg_data,
                                                          p_plan_element_name      => l_p_plan_element_name,
                                                          x_plan_element_name      => l_x_plan_element_name,
                                                          x_loading_status         => x_loading_status
                                                         );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- Call the Local Procedure get Plan Element to Populate the old
      -- Plan Element Information into the Record/Pl/SQL table
      get_plan_element (p_api_version                 => 1.0,
                        x_return_status               => x_return_status,
                        x_msg_count                   => x_msg_count,
                        x_msg_data                    => x_msg_data,
                        p_plan_element_name           => l_p_plan_element_name,
                        p_org_id                      => p_org_id,
                        x_plan_element_rec            => l_plan_element_rec,
                        x_revenue_class_rec_tbl       => l_revenue_class_rec_tbl,
                        x_rev_uplift_rec_tbl          => l_rev_uplift_rec_tbl,
                        x_trx_factor_rec_tbl          => l_trx_factor_rec_tbl,
                        x_period_quotas_rec_tbl       => l_period_quotas_rec_tbl,
                        x_rt_quota_asgns_rec_tbl      => l_rt_quota_asgns_rec_tbl,
                        x_loading_status              => x_loading_status
                       );

      -- IF the Return Status is not success or Plan Element name
      IF (x_return_status <> fnd_api.g_ret_sts_success) OR (x_loading_status = 'CN_PLN_NOT_EXIST')
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check if the Plan Element name is > 30 Then Raise an Warning
      -- Commented the code because of inline copy new behavior
      /*
      IF l_plan_element_rec.NAME IS NOT NULL
      THEN
         IF (LENGTHB (l_plan_element_rec.NAME) > l_length)
         THEN
            l_x_plan_element_name := CONCAT (SUBSTRB (l_plan_element_rec.NAME, 1, l_length), '_2');

            -- Add CN_DUP_PLN_NAME_TOO_LONG message
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_DUP_PLN_NAME_TOO_LONG');
               fnd_message.set_token ('FROM_PE', l_p_plan_element_name);
               fnd_message.set_token ('TO_PE', l_x_plan_element_name);
               fnd_msg_pub.ADD;
            END IF;

            l_warning_flag := 'Y';
         ELSE
            l_x_plan_element_name := CONCAT (l_plan_element_rec.NAME, '_2');
         END IF;
      END IF;
      */

      -- Added this because of the enhancement in 12.1 when inline copy was enhanced
      -- Get quota id
      --Added check for delete_flag (bug 6467453) (hanaraya)

      SELECT quota_id into l_quota_id from cn_quotas_all where org_id = l_org_id and name = l_plan_element_rec.NAME and delete_flag = 'N';

      cn_plancopy_util_pvt.get_unique_name_for_component (
       p_id    => l_quota_id,
       p_org_id => l_org_id,
       p_type   => 'PLANELEMENT',
       p_suffix => l_suffix,
       p_prefix => l_prefix,
       x_name   => l_x_plan_element_name,
       x_return_status => x_return_status,
       x_msg_count  => x_msg_count,
       x_msg_data   => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_plan_element_rec.NAME := l_x_plan_element_name;

      -- Check The Created Plan Element Already Exists in Database
      IF cn_chk_plan_element_pkg.get_quota_id (l_x_plan_element_name,p_org_id) IS NOT NULL
      THEN
         -- IF Plan Element Exists Raise an Error
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'PLN_QUOTA_EXISTS');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PLN_EXISTS';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Call the Create_plan_element Procedure to Create the Plan ELement
      create_plan_element (p_api_version                 => 1.0,
                           x_return_status               => x_return_status,
                           x_msg_count                   => x_msg_count,
                           x_msg_data                    => x_msg_data,
                           p_plan_element_rec            => l_plan_element_rec,
                           p_revenue_class_rec_tbl       => l_revenue_class_rec_tbl,
                           p_rev_uplift_rec_tbl          => l_rev_uplift_rec_tbl,
                           p_trx_factor_rec_tbl          => l_trx_factor_rec_tbl,
                           p_period_quotas_rec_tbl       => l_period_quotas_rec_tbl,
                           p_rt_quota_asgns_rec_tbl      => l_rt_quota_asgns_rec_tbl,
                           x_loading_status              => x_loading_status,
                           p_is_duplicate                => 'Y'
                          );

      -- Raise an Error if the Status IS Success
      IF (x_loading_status = 'PLN_QUOTA_RULE_FACTORS_NOT_100') AND (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         l_warning_flag := 'Y';
      ELSIF (x_return_status <> fnd_api.g_ret_sts_success) OR (x_loading_status = 'PLN_QUOTA_EXISTS') OR (x_loading_status = 'PLN_QUOTA_REV_EXISTS')
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check for the Warning Flag
      IF (x_return_status = fnd_api.g_ret_sts_success) AND (x_loading_status = 'CN_INSERTED')
         OR (x_loading_status = 'PLN_QUOTA_RULE_FACTORS_NOT_100')
      THEN
         x_loading_status := 'CN_INSERTED';

         IF l_warning_flag = 'Y'
         THEN
            x_return_status := cn_api.g_ret_sts_warning;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DUPLICATE_PLAN_ELEMENT', 'A', 'V')
      THEN
         cn_plan_element_vuhk.duplicate_plan_element_post (p_api_version            => p_api_version,
                                                           p_init_msg_list          => p_init_msg_list,
                                                           p_commit                 => fnd_api.g_false,
                                                           p_validation_level       => p_validation_level,
                                                           x_return_status          => x_return_status,
                                                           x_msg_count              => x_msg_count,
                                                           x_msg_data               => x_msg_data,
                                                           p_plan_element_name      => l_p_plan_element_name,
                                                           x_plan_element_name      => l_x_plan_element_name,
                                                           x_loading_status         => x_loading_status
                                                          );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DUPLICATE_PLAN_ELEMENT', 'A', 'C')
      THEN
         cn_plan_element_cuhk.duplicate_plan_element_post (p_api_version            => p_api_version,
                                                           p_init_msg_list          => p_init_msg_list,
                                                           p_commit                 => fnd_api.g_false,
                                                           p_validation_level       => p_validation_level,
                                                           x_return_status          => x_return_status,
                                                           x_msg_count              => x_msg_count,
                                                           x_msg_data               => x_msg_data,
                                                           p_plan_element_name      => l_p_plan_element_name,
                                                           x_plan_element_name      => l_x_plan_element_name,
                                                           x_loading_status         => x_loading_status
                                                          );

         IF (x_return_status = fnd_api.g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

--      x_plan_element_name := l_x_plan_element_name;
      x_plan_element_name := cn_chk_plan_element_pkg.get_quota_id (l_x_plan_element_name, p_org_id);

      /* Following code is for message generation */
      IF jtf_usr_hks.ok_to_execute ('CN_PLAN_ELEMENT_PUB', 'DUPLICATE_PLAN_ELEMENT', 'M', 'M')
      THEN
         IF (cn_plan_element_cuhk.ok_to_generate_msg (p_plan_element_name => l_x_plan_element_name))
         THEN
            -- XMLGEN.clearBindValues;
            -- XMLGEN.setBindValue('QUOTA_NAME', l_plan_element_rec.name);
            l_bind_data_id := jtf_usr_hks.get_bind_data_id;
            jtf_usr_hks.load_bind_data (l_bind_data_id, 'QUOTA_NAME', l_plan_element_rec.NAME, 'S', 'T');
            jtf_usr_hks.generate_message (p_prod_code         => 'CN',
                                          p_bus_obj_code      => 'PL',
                                          p_bus_obj_name      => 'PLAN_ELEMENT',
                                          p_action_code       => 'I',                                                                /* I - Insert  */
                                          p_bind_data_id      => l_bind_data_id,
                                          p_oai_param         => NULL,
                                          p_oai_array         => l_oai_array,
                                          x_return_code       => x_return_status
                                         );

            IF (x_return_status = fnd_api.g_ret_sts_error)
            THEN
               RAISE fnd_api.g_exc_error;
            ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      --  End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   -- End of Duplicate Plan ELement
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO duplicate_pe;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO duplicate_pe;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO duplicate_pe;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END duplicate_plan_element;
END cn_plan_element_pub;

/
