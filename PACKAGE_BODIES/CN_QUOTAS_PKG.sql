--------------------------------------------------------
--  DDL for Package Body CN_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTAS_PKG" AS
/* $Header: cnpliqob.pls 120.4.12000000.5 2007/10/10 00:48:56 rnagired ship $ */

   /*
   Date      Name          Description
   ---------------------------------------------------------------------------+
   06-FEB-95 P Cook        Allow plan completion of key-factors do not equal 100.
   15-FEB-95 P Cook  Unit tested
   06-MAR-95 P Cook  Test for schedule presence(get_schedule_id) regardless
         of whether rate_schedule_id is passed in as a
         parameter (bug 268849).
   19-JUL-95 P Cook  Added no data found to check_tiers
   26-JUL-95 P Cook  Fixed quota change range error message name
   27-JUL-95 P Cook  Added cumulative_flag
   12-AUG-95 P Cook  removed recursive loop in check_quota_rules
   08-MAR-99 S Kumar Modified and More Parameters in the Begin Insert
   27-APR-99 S Kumar Modified and More Parameters in the Begin Insert
   17-MAY-99 S Kumar       Calling delete record, insert record for changing the
                           calc formula name
   26-MAY-99 S Kumar       Changes made due to 3i

   25-JUN-99 S Kumar Modified the procedure call to cn_srp_per_rc
                           and cn_srp_per_quota. instead of period id to
                           end date

   03-AUG-99 S Kumar      get_schedule_id procedure go changed due to formulas
                          now we do not have a rate schedule directly assiged
                          to the quotas, it has to go through the formula
                          we need to validate against cn_rt_quota_assigns.

   03-AUG-99 S Kumar      End_record.rate_schedules_pkg call for was made from
                          quota end record, now we are looping through each
                          rate schedule we have at the rt_quota_asgns.
                          it means that validating all the rate schedule and
                          its tiers.

   25-AUG-99 S Kumar     Added more parameter to update the performance goal
             in the srp_quota_assigns.
             update_srp_quota.performance_goal.

   25-AUG-99 S Kumar     Changed the g_temp_Status with nvl in the update
                          added delete call to the rt_quota_asgns

   20-SEP-99 S Kumar     Modified the Package to mark the event.

   Name

   Purpose

   Notes

   */

   -- -------------------------------------------------------------------------+
-- |                      Variables                                         |
----------------------------------------------------------------------------+
   g_temp_status_code            VARCHAR2 (30) := NULL;
   g_program_type                VARCHAR2 (30) := NULL;
   g_quota_name                  VARCHAR2 (80) := NULL;
   g_plan_name                   VARCHAR2 (30) := NULL;
   g_schedule_name               VARCHAR2 (30) := NULL;

----------------------------------------------------------------------------+
-- |                          Private Routines                              |
----------------------------------------------------------------------------+
-- Procedure Name

   -- Purpose
-- cover
   PROCEDURE set_message (
      message_name                        VARCHAR2,
      token_name                          VARCHAR2,
      token_value                         VARCHAR2
   )
   IS
   BEGIN
      cn_message_pkg.set_message (appl_short_name      => 'CN',
                                  message_name         => message_name,
                                  token_name1          => 'QUOTA_NAME',
                                  token_value1         => g_quota_name,
                                  token_name2          => 'PLAN_NAME',
                                  token_value2         => g_plan_name,
                                  token_name3          => token_name,
                                  token_value3         => token_value,
                                  token_name4          => NULL,
                                  token_value4         => NULL,
                                  TRANSLATE            => TRUE
                                 );
      fnd_msg_pub.ADD;
   END set_message;

   -- Purpose

   -- Notes
   PROCEDURE get_uid (
      x_quota_id                 IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      SELECT cn_quotas_s.NEXTVAL
        INTO x_quota_id
        FROM SYS.DUAL;
   END get_uid;

-- Name
-- Purpose
-- Notes
--  You can't delete a quota that is assigned to a rep so there is no need
--  to cascade this delete to the srp tables
   PROCEDURE DELETE_RECORD (
      x_quota_id                          NUMBER,
      x_name                              VARCHAR2
   )
   IS
   BEGIN
      -- delete quota rules
      cn_quota_rules_pkg.DELETE_RECORD (x_quota_id => x_quota_id, x_quota_rule_id => NULL, x_revenue_class_id => NULL);
      -- delete period qutoas
      cn_period_quotas_pkg.DELETE_RECORD (x_quota_id => x_quota_id);
      -- delete rt quota asgns id
      cn_rt_quota_asgns_pkg.DELETE_RECORD (x_quota_id => x_quota_id, x_calc_formula_id => NULL, x_rt_quota_asgn_id => NULL);

      UPDATE cn_quotas_all
         SET delete_flag = 'Y'
       WHERE quota_id = x_quota_id;
   END DELETE_RECORD;

-- Name
-- Purpose
-- Notes
   PROCEDURE INSERT_RECORD (
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_quota_id                 IN OUT NOCOPY NUMBER,
      x_object_version_number    OUT NOCOPY NUMBER,
      x_name                              VARCHAR2,
      x_target                            NUMBER,
      x_quota_type_code                   VARCHAR2,
      x_period_type_code                  VARCHAR2,
      x_usage_code                        VARCHAR2,
      x_payment_amount                    NUMBER,
      x_description                       VARCHAR2,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_quota_status                      VARCHAR2,
      x_start_num                         NUMBER,
      x_end_num                           NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_incentive_type_code               VARCHAR2,
      x_credit_type_id                    NUMBER,
      x_calc_formula_id                   NUMBER,
      x_rt_sched_custom_flag              VARCHAR2,
      x_package_name                      VARCHAR2,
      x_performance_goal                  NUMBER,
      x_interval_type_id                  NUMBER,
      x_payee_assign_flag                 VARCHAR2,
      x_vesting_flag                      VARCHAR2,
      x_quota_unspecified                 NUMBER,
      x_addup_from_rev_class_flag         VARCHAR2,
      x_expense_account_id                NUMBER,
      x_liability_account_id              NUMBER,
      x_quota_group_code                  VARCHAR2,
      --clku, PAYMENT ENHANCEMENT
      x_payment_group_code                VARCHAR2 := 'STANDARD',
      --clku, 2854576
      x_attribute_category                VARCHAR := NULL,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      -- fmburu r12
      x_indirect_credit                   VARCHAR2,
      x_org_id                            NUMBER,
      x_salesrep_end_flag                  VARCHAR2
   )
   IS
      x_incremental_type            VARCHAR2 (1) := 'N';
   BEGIN
      --- pass null so that the primary key is populated by the PKG
      IF x_quota_id IS NULL
      THEN
         get_uid (x_quota_id);
      END IF;

      INSERT INTO cn_quotas
                  (quota_id,
                   NAME,
                   target,
                   quota_type_code,
                   payment_amount,
                   description,
                   start_date,
                   end_date,
                   quota_status,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   incremental_type,
                   calc_formula_id,
                   incentive_type_code,
                   credit_type_id,
                   rt_sched_custom_flag,
                   package_name,
                   performance_goal,
                   interval_type_id,
                   payee_assign_flag,
                   vesting_flag,
                   addup_from_rev_class_flag,
                   expense_account_id,
                   liability_account_id,
                   quota_group_code,
                   --clku, PAYMENT ENHANCEMENT
                   payment_group_code,
                   --clku
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
                   object_version_number,
                   -- fmburu r12
                   indirect_credit,
                   org_id,
                   salesreps_enddated_flag
                  )
           VALUES (x_quota_id,
                   x_name,
                   x_target,
                   x_quota_type_code,
                   x_payment_amount,
                   x_description,
                   x_start_date,
                   x_end_date,
                   x_quota_status,
                   x_last_update_date,
                   x_last_updated_by,
                   x_creation_date,
                   x_created_by,
                   x_last_update_login,
                   x_incremental_type,
                   x_calc_formula_id,
                   x_incentive_type_code,
                   x_credit_type_id,
                   x_rt_sched_custom_flag,
                   x_package_name,
                   x_performance_goal,
                   x_interval_type_id,
                   x_payee_assign_flag,
                   x_vesting_flag,
                   x_addup_from_rev_class_flag,
                   DECODE (x_expense_account_id, cn_api.g_miss_id, NULL, x_expense_account_id),
                   DECODE (x_liability_account_id, cn_api.g_miss_id, NULL, x_liability_account_id),
                   x_quota_group_code,
                   --clku, PAYMENT ENHANCEMENT
                   x_payment_group_code,
                   --clku, 2854578
                   x_attribute_category,
                   x_attribute1,
                   x_attribute2,
                   x_attribute3,
                   x_attribute4,
                   x_attribute5,
                   x_attribute6,
                   x_attribute7,
                   x_attribute8,
                   x_attribute9,
                   x_attribute10,
                   x_attribute11,
                   x_attribute12,
                   x_attribute13,
                   x_attribute14,
                   x_attribute15,
                   1,
                   -- fmburu r12
                   x_indirect_credit,
                   x_org_id,
                   nvl(x_salesrep_end_flag,'N')
                  );

      x_object_version_number := 1;
   END INSERT_RECORD;

   --  temp use
   PROCEDURE UPDATE_RECORD (
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE
   )
   IS
   BEGIN
      UPDATE cn_quotas
         SET start_date = x_start_date,
             end_date = x_end_date
       WHERE quota_id = x_quota_id;
   END;

   -- Name
   -- Purpose
   -- Notes
   PROCEDURE UPDATE_RECORD (
      x_quota_id                          NUMBER,
      x_object_version_number    OUT NOCOPY NUMBER,
      x_name                              VARCHAR2,
      x_target                            NUMBER,
      x_quota_type_code                   VARCHAR2,
      x_period_type_code                  VARCHAR2,
      x_usage_code                        VARCHAR2,
      x_payment_amount                    NUMBER,
      x_description                       VARCHAR2,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_quota_status                      VARCHAR2,
      x_start_num                         NUMBER,
      x_end_num                           NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_incentive_type_code               VARCHAR2,
      x_credit_type_id                    NUMBER,
      x_calc_formula_id                   NUMBER,
      x_rt_sched_custom_flag              VARCHAR2,
      x_package_name                      VARCHAR2,
      x_performance_goal                  NUMBER,
      x_interval_type_id                  NUMBER,
      x_payee_assign_flag                 VARCHAR2,
      x_vesting_flag                      VARCHAR2,
      x_quota_unspecified                 NUMBER,
      x_addup_from_rev_class_flag         VARCHAR2,
      x_expense_account_id                NUMBER,
      x_liability_account_id              NUMBER,
      x_quota_group_code                  VARCHAR2,
      x_payment_group_code                VARCHAR2 := 'STANDARD',
      x_attribute_category                VARCHAR := NULL,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_indirect_credit                   VARCHAR2,
  	  x_salesrep_end_flag                 VARCHAR2
   )
   IS
      l_modified                    BOOLEAN := FALSE;
      x_incremental_type            VARCHAR2 (1) := 'N';
      x_rate_schedule_id            NUMBER;
      x_discount_option_code        VARCHAR2 (100);
      x_disc_rate_schedule_id       NUMBER;
      x_trx_group_code              VARCHAR2 (100);
      x_cumulative_flag             VARCHAR2 (100);
      x_split_flag                  VARCHAR2 (100);
      x_itd_flag                    VARCHAR2 (100);
      x_payment_type_code           VARCHAR2 (100);
      l_return_status               VARCHAR2 (100);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (100);
      l_role_id                     NUMBER;
      l_comp_plan_id                NUMBER;
      l_salesrep_id                 NUMBER;
      l_start_date                  DATE;
      l_end_date                    DATE;
      l_loading_status              VARCHAR2 (100);
      l_next_status                 NUMBER;
      l_ovn                         NUMBER;

      CURSOR c
      IS
         SELECT *
           FROM cn_quotas
          WHERE quota_id = x_quota_id;

      -- clku
      CURSOR srp_quota_assigns_curs
      IS
         SELECT *
           FROM cn_srp_quota_assigns
          WHERE quota_id = x_quota_id;

      recinfo                       c%ROWTYPE;
      srp_quota_assigns_info        srp_quota_assigns_curs%ROWTYPE;
      l_old_ovn                     NUMBER;
   BEGIN
      IF g_temp_status_code <> 'FAILED'
      THEN
         OPEN c;

         FETCH c
          INTO recinfo;

         IF c%NOTFOUND
         THEN
            CLOSE c;
         END IF;

         CLOSE c;

         SELECT object_version_number
           INTO l_old_ovn
           FROM cn_quotas
          WHERE quota_id = x_quota_id;

         l_ovn := (NVL (l_old_ovn, 1) + 1);

         UPDATE cn_quotas
            SET quota_id = x_quota_id,
                NAME = x_name,
                target = x_target,
                quota_type_code = x_quota_type_code,
                payment_amount = x_payment_amount,
                description = x_description,
                start_date = x_start_date,
                end_date = x_end_date,
                quota_status = x_quota_status,
                last_update_date = x_last_update_date,
                last_updated_by = x_last_updated_by,
                last_update_login = x_last_update_login,
                incremental_type = x_incremental_type,
                calc_formula_id = x_calc_formula_id,
                incentive_type_code = x_incentive_type_code,
                credit_type_id = x_credit_type_id,
                performance_goal = x_performance_goal,
                rt_sched_custom_flag = x_rt_sched_custom_flag,
                package_name = x_package_name,
                interval_type_id = x_interval_type_id,
                payee_assign_flag = x_payee_assign_flag,
                vesting_flag = x_vesting_flag,
                addup_from_rev_class_flag = x_addup_from_rev_class_flag,
                expense_account_id = DECODE (x_expense_account_id, cn_api.g_miss_id, recinfo.expense_account_id, x_expense_account_id),
                liability_account_id = DECODE (x_liability_account_id, cn_api.g_miss_id, recinfo.liability_account_id, x_liability_account_id),
                quota_group_code = x_quota_group_code,
                --clku, PAYMENT ENHANCEMENT
                payment_group_code = x_payment_group_code,
                -- clku, 2854576
                attribute_category = x_attribute_category,
                attribute1 = x_attribute1,
                attribute2 = x_attribute2,
                attribute3 = x_attribute3,
                attribute4 = x_attribute4,
                attribute5 = x_attribute5,
                attribute6 = x_attribute6,
                attribute7 = x_attribute7,
                attribute8 = x_attribute8,
                attribute9 = x_attribute9,
                attribute10 = x_attribute10,
                attribute11 = x_attribute11,
                attribute12 = x_attribute12,
                attribute13 = x_attribute13,
                attribute14 = x_attribute14,
                attribute15 = x_attribute15,
                object_version_number = l_ovn,
                -- release 12
                indirect_credit = x_indirect_credit,
                salesreps_enddated_flag=x_salesrep_end_flag
          WHERE quota_id = x_quota_id;

         x_object_version_number := l_ovn;

         IF (SQL%NOTFOUND)
         THEN
            RAISE NO_DATA_FOUND;
         ELSE
            l_modified := TRUE;
            cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                          x_quota_id              => x_quota_id,
                                          x_rate_schedule_id      => NULL,
                                          x_status_code           => 'INCOMPLETE',
                                          x_event                 => 'CHANGE_TIERS'
                                         );
         END IF;

         -- To simplify things we no longer discriminate between changes
         -- to the rate schedule over other attributes.
         IF l_modified
         THEN
            IF (x_indirect_credit <> recinfo.indirect_credit) THEN
                  cn_mark_events_pkg.mark_event_quota
        		    (p_event_name          => 'CHANGE_PE_DIRECT_INDIRECT',
	   	             p_object_name         => x_name,
		             p_object_id           => x_quota_id,
 		             p_start_date          => x_start_date,
        		     p_end_date            => x_end_date,
		             p_start_date_old      => recinfo.start_date,
        		     p_end_date_old        => recinfo.end_date,
        		     p_org_id              => recinfo.org_id
        		    );

            END IF;

            -- Delete the Quota rules if there is a change in the Quota Type
            -- Quota Type none cannot have a revenue class
            IF (x_quota_type_code IN ('NONE') AND recinfo.quota_type_code IN ('FORMULA', 'EXTERNAL'))
            THEN
               cn_quota_rules_pkg.DELETE_RECORD (x_quota_id => x_quota_id, x_quota_rule_id => NULL, x_revenue_class_id => NULL);
            END IF;

            -- update the srp quota assigns
            -- delete the srp_rt_quota_assigns if the formula changes
            cn_srp_quota_assigns_pkg.update_srp_quota (x_quota_id                       => x_quota_id,
                                                       x_target                         => x_target,
                                                       x_payment_amount                 => x_payment_amount,
                                                       x_performance_goal               => x_performance_goal,
                                                       x_rate_schedule_id               => NULL
                                                                                               -- obsolete
            ,
                                                       x_rate_schedule_id_old           => NULL
                                                                                               -- obsolete
            ,
                                                       x_disc_rate_schedule_id          => NULL
                                                                                               -- obsolete
            ,
                                                       x_disc_rate_schedule_id_old      => NULL
                                                                                               -- obsolete
            ,
                                                       x_payment_type_code              => NULL
                                                                                               -- obsolete
            ,
                                                       x_payment_type_code_old          => NULL
                                                                                               -- obsolete
            ,
                                                       x_quota_type_code                => x_quota_type_code,
                                                       x_quota_type_code_old            => recinfo.quota_type_code,
                                                       x_period_type_code               => x_period_type_code
                                                                                                             -- pening, how to handle the new
            ,
                                                       x_calc_formula_id                => x_calc_formula_id
                                                                                                            -- not used.
            ,
                                                       x_calc_formula_id_old            => recinfo.calc_formula_id
                                                      );

            --clku
            IF (x_credit_type_id <> recinfo.credit_type_id)
            THEN
               FOR srp_quota_assigns_info IN srp_quota_assigns_curs
               LOOP
                  SELECT role_id,
                         comp_plan_id,
                         salesrep_id,
                         start_date,
                         end_date
                    INTO l_role_id,
                         l_comp_plan_id,
                         l_salesrep_id,
                         l_start_date,
                         l_end_date
                    FROM cn_srp_plan_assigns
                   WHERE srp_plan_assign_id = srp_quota_assigns_info.srp_plan_assign_id;

                  -- Create entry in cn_srp_periods
                  cn_srp_periods_pvt.create_srp_periods (p_api_version         => 1.0,
                                                         x_return_status       => l_return_status,
                                                         x_msg_count           => l_msg_count,
                                                         x_msg_data            => l_msg_data,
                                                         p_role_id             => l_role_id,
                                                         p_comp_plan_id        => l_comp_plan_id,
                                                         p_salesrep_id         => l_salesrep_id,
                                                         p_start_date          => l_start_date,
                                                         p_end_date            => l_end_date,
                                                         x_loading_status      => l_loading_status
                                                        );

                  IF (l_return_status <> fnd_api.g_ret_sts_success)
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END LOOP;
            END IF;

            --clku, we need to sync up the ITD values whenever interval type is updated
            IF (x_interval_type_id <> recinfo.interval_type_id)
            THEN
               cn_period_quotas_pkg.sync_itd_values (x_quota_id);
               cn_srp_period_quotas_pkg.sync_itd_values (x_quota_id);
            END IF;
         END IF;

         IF    (TRUNC (x_start_date) <> TRUNC (recinfo.start_date))
            OR (NVL (x_end_date, fnd_api.g_miss_date) <> NVL (recinfo.end_date, fnd_api.g_miss_date))
         THEN
            -- start_date remanin unchanged
            IF TRUNC (x_start_date) = TRUNC (recinfo.start_date)
	      THEN
               IF x_end_date IS NULL
		 THEN
                  -- recinfo.end_date is not null and greater end_date
                  cn_srp_period_quotas_pkg.insert_record
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_start_period_id         => NULL                                                -- obsolete
		     ,
		     x_end_period_id           => NULL                                                -- obsolete
		     ,
		     x_start_date              => cn_api.next_period (recinfo.end_date, recinfo.org_id),
		     x_end_date                => x_end_date
		     );
                  -- mark the Event only mark the new period records
		  -- bug 3646625, fix the passed in p_start_end
                  cn_mark_events_pkg.mark_event_quota
		    (p_event_name          => 'CHANGE_QUOTA_DATE',
		     p_object_name         => x_name,
		     p_object_id           => x_quota_id,
		     p_start_date          => x_start_date,
		     p_end_date            => x_end_date,
		     p_start_date_old      => recinfo.start_date,
		     p_end_date_old        => recinfo.end_date,
		     p_org_id              => recinfo.org_id
		     );
                  -- recinfo end date is not null and greater end date
                  -- RC 2
                  cn_srp_per_quota_rc_pkg.INSERT_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_revenue_class_id        => NULL,
		     x_start_period_id         => NULL,
		     x_end_period_id           => NULL,
		     x_start_date              => cn_api.next_period (recinfo.end_date, recinfo.org_id),
		     x_end_date                => x_end_date
		     );
		ELSIF recinfo.end_date IS NULL
		  THEN
                  -- mark the Event only mark the delete period records
		  -- bug 3646625, fix the passed in p_start_end
                  cn_mark_events_pkg.mark_event_quota
		    (p_event_name          => 'CHANGE_QUOTA_DATE',
		     p_object_name         => x_name,
		     p_object_id           => x_quota_id,
		     p_start_date          => x_start_date,
		     p_end_date            => x_end_date,
		     p_start_date_old      => recinfo.start_date,
		     p_end_date_old        => recinfo.end_date,
		     p_org_id              => recinfo.org_id
		     );
                  -- x_end_date is not null and less end_date
                  cn_srp_period_quotas_pkg.DELETE_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_start_period_id         => NULL                                                -- obsolete
		     ,
		     x_end_period_id           => NULL                                                -- obsolete
		     ,
		     x_start_date              => cn_api.next_period (x_end_date, recinfo.org_id),
		     x_end_date                => recinfo.end_date
		     );
                  -- x_end_date is not null and less end_date
		  -- RC 1
                  cn_srp_per_quota_rc_pkg.DELETE_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_revenue_class_id        => NULL,
		     x_start_period_id         => NULL,
		     x_end_period_id           => NULL,
		     x_start_date              => cn_api.next_period (x_end_date, recinfo.org_id),
		     x_end_date                => recinfo.end_date
		     );
		ELSIF TRUNC (x_end_date) > TRUNC (recinfo.end_date)
		  THEN
                  -- Greater end_date
                  cn_srp_period_quotas_pkg.INSERT_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_start_period_id         => NULL                                                -- obsolete
		     ,
		     x_end_period_id           => NULL                                                -- obsolete
		     ,
		     x_start_date              => cn_api.next_period (recinfo.end_date, recinfo.org_id),
		     x_end_date                => x_end_date
		     );
                  -- mark the Event only mark the new period records
		  -- bug 3646625, fix the passed in p_start_end
                  cn_mark_events_pkg.mark_event_quota
		    (p_event_name          => 'CHANGE_QUOTA_DATE',
		     p_object_name         => x_name,
		     p_object_id           => x_quota_id,
		     p_start_date          => x_start_date,
		     p_end_date            => x_end_date,
		     p_start_date_old      => recinfo.start_date,
		     p_end_date_old        => recinfo.end_date,
		     p_org_id              => recinfo.org_id
		     );
                  -- Greater end_date
                  -- RC 0
                  cn_srp_per_quota_rc_pkg.INSERT_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_revenue_class_id        => NULL,
		     x_start_period_id         => NULL,
		     x_end_period_id           => NULL,
		     x_start_date              => cn_api.next_period (recinfo.end_date, recinfo.org_id),
		     x_end_date                => x_end_date
		     );
		ELSE
                  -- shorten end_date

                  -- mark the Event only mark the deleted records records
		  -- bug 3646625, fix the passed in p_start_end
                  cn_mark_events_pkg.mark_event_quota
		    (p_event_name          => 'CHANGE_QUOTA_DATE',
		     p_object_name         => x_name,
		     p_object_id           => x_quota_id,
		     p_start_date          => x_start_date,
		     p_end_date            => x_end_date,
		     p_start_date_old      => recinfo.start_date,
		     p_end_date_old        => recinfo.end_date,
		     p_org_id              => recinfo.org_id
		     );
                  cn_srp_period_quotas_pkg.DELETE_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_start_period_id         => NULL                                                -- obsolete
		     ,
		     x_end_period_id           => NULL                                                -- obsolete
		     ,
		     x_start_date              => cn_api.next_period (x_end_date, recinfo.org_id),
		     x_end_date                => cn_api.next_period (recinfo.end_date, recinfo.org_id) -- bugfix 4042235
		     );
                  cn_srp_per_quota_rc_pkg.DELETE_RECORD
		    (x_srp_plan_assign_id      => NULL,
		     x_quota_id                => x_quota_id,
		     x_revenue_class_id        => NULL,
		     x_start_period_id         => NULL,
		     x_end_period_id           => NULL,
		     x_start_date              => cn_api.next_period (x_end_date, recinfo.org_id),
		     x_end_date                => cn_api.next_period (recinfo.end_date, recinfo.org_id) -- bugfix 4042235
		     );
               END IF;
	     ELSE
               -- mark the Event only mark the delete period records
               cn_mark_events_pkg.mark_event_quota
		 (p_event_name          => 'CHANGE_QUOTA_DATE',
		  p_object_name         => x_name,
		  p_object_id           => x_quota_id,
		  p_start_date          => x_start_date,
		  p_end_date            => x_end_date,
		  p_start_date_old      => recinfo.start_date,
		  p_end_date_old        => recinfo.end_date,
		  p_org_id              => recinfo.org_id
		  );
               -- Remove all assignments for this quota
               cn_srp_per_quota_rc_pkg.DELETE_RECORD
		 (x_srp_plan_assign_id      => NULL,
		  x_quota_id                => x_quota_id,
		  x_revenue_class_id        => NULL,
		  x_start_period_id         => NULL,
		  x_end_period_id           => NULL,
		  x_start_date              => recinfo.start_date,
		  x_end_date                => recinfo.end_date
		  );
               cn_srp_period_quotas_pkg.DELETE_RECORD
		 (x_srp_plan_assign_id      => NULL,
		  x_quota_id                => x_quota_id,
		  x_start_period_id         => NULL
		  -- obsolete
		  ,
		  x_end_period_id           => NULL
		  -- obsolete
		  ,
		  x_start_date              => recinfo.start_date,
		  x_end_date                => recinfo.end_date
		  );
               cn_srp_period_quotas_pkg.INSERT_RECORD
		 (x_srp_plan_assign_id      => NULL,
		  x_quota_id                => x_quota_id,
		  x_start_period_id         => NULL
		  -- obsolete
		  ,
		  x_end_period_id           => NULL
		  -- obsolete
		  ,
		  x_start_date              => x_start_date,
		  x_end_date                => x_end_date
		  );
               cn_mark_events_pkg.mark_event_quota
		 (p_event_name          => 'CHANGE_QUOTA_DATE',
		  p_object_name         => x_name,
		  p_object_id           => x_quota_id,
		  p_start_date          => x_start_date,
		  p_end_date            => x_end_date,
		  p_start_date_old      => recinfo.start_date,
		  p_end_date_old        => recinfo.end_date,
		  p_org_id              => recinfo.org_id
		  );
               cn_srp_per_quota_rc_pkg.INSERT_RECORD
		 (x_srp_plan_assign_id      => NULL,
		  x_quota_id                => x_quota_id,
		  x_revenue_class_id        => NULL,
		  x_start_period_id         => NULL,
		  x_end_period_id           => NULL,
		  x_start_date              => x_start_date,
		  x_end_date                => x_end_date
		  );
	       -- mark the newly inserted record as calc, because of the
	       -- newly inserted srp_period_quotas
               -- clku, bug 3646625
               cn_mark_events_pkg.mark_event_quota
		 (p_event_name          => 'CHANGE_QUOTA_CALC',
		  p_object_name         => x_name,
		  p_object_id           => x_quota_id,
		  p_start_date          => x_start_date,
		  p_end_date            => x_end_date,
		  p_start_date_old      => NULL,
		  p_end_date_old        => NULL,
		  p_org_id              => recinfo.org_id
		  );
            END IF;
	  ELSE
            IF    x_performance_goal <> recinfo.performance_goal
	      OR NVL (x_target, 0) <> recinfo.target
               OR NVL (x_payment_amount, 0) <> recinfo.payment_amount
               OR x_credit_type_id <> recinfo.credit_type_id
               OR x_interval_type_id <> recinfo.interval_type_id
               OR x_vesting_flag <> recinfo.vesting_flag
               OR NVL (x_calc_formula_id, -99) <> NVL (recinfo.calc_formula_id, -99)
            THEN
               cn_mark_events_pkg.mark_event_quota
		 (p_event_name          => 'CHANGE_QUOTA_CALC',
		  p_object_name         => x_name,
		  p_object_id           => x_quota_id,
		  p_start_date          => NULL,
		  p_end_date            => NULL,
		  p_start_date_old      => NULL,
		  p_end_date_old        => NULL,
		  p_org_id              => recinfo.org_id
		  );
            END IF;
         END IF;
	 -- delete the associated rows from cn_period_quots table and
      -- insert the new one.  Can not use only difference since
      -- have to reselect the whole thing.

      -- clku, 1/9/2002, commented out this part because we want to prevent inserting
      -- records in cn_period_quotas with checking the formula's ytd flag. The insert of rows
      -- will be taken care of in CN_PLAN_ELEMENT_PUB.Update_Period_Quota right after
      -- the call of cn_period_quotas.begin_record
      /*cn_period_quotas_pkg.delete_record (
            x_quota_id      => x_quota_id);
      cn_period_quotas_pkg.insert_record (
            x_quota_id      => x_quota_id);*/
      END IF;
   -- The period_type_code has changed.  Delete rows from
   -- cn_period_quotas associated with x_quota_id and add the
   -- new rows according to the new period_type_code.

   /*IF (   recinfo.period_type_code  <> x_period_type_code ) THEN

      cn_period_quotas_pkg.delete_record (
            x_quota_id      => x_quota_id);

      cn_period_quotas_pkg.insert_record (
            x_quota_id      => x_quota_id);

   END IF;*/
   END UPDATE_RECORD;

-- Name

   -- Purpose

   -- Notes
   PROCEDURE LOCK_RECORD (
      x_rowid                             VARCHAR2,
      x_quota_id                          NUMBER,
      x_object_version_number             NUMBER,
      x_name                              VARCHAR2,
      x_target                            NUMBER,
      x_description                       VARCHAR2,
      x_quota_type_code                   VARCHAR2,
      x_period_type_code                  VARCHAR2,
      x_usage_code                        VARCHAR2,
      x_payment_amount                    NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_quota_status                      VARCHAR2,
      x_start_num                         NUMBER,
      x_end_num                           NUMBER,
      x_incentive_type_code               VARCHAR2,
      x_credit_type_id                    NUMBER,
      x_calc_formula_id                   NUMBER,
      x_rt_sched_custom_flag              VARCHAR2,
      x_package_name                      VARCHAR2,
      x_performance_goal                  NUMBER,
      x_interval_type_id                  NUMBER,
      x_payee_assign_flag                 VARCHAR2,
      x_vesting_flag                      VARCHAR2,
      x_quota_group_code                  VARCHAR2,
      x_quota_unspecified                 NUMBER,
      x_addup_from_rev_class_flag         VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      -- fmburu r12
      x_indirect_credit                   VARCHAR2
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_quotas
                 WHERE quota_id = x_quota_id
         FOR UPDATE OF quota_id NOWAIT;

      recinfo                       c%ROWTYPE;
      temp                          DATE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF c%NOTFOUND
      THEN
         CLOSE c;

         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF (    (recinfo.quota_id = x_quota_id)
          AND (recinfo.NAME = x_name OR (recinfo.NAME IS NULL AND x_name IS NULL))
          AND (recinfo.quota_type_code = x_quota_type_code OR (recinfo.quota_type_code IS NULL AND x_quota_type_code IS NULL))
          AND (recinfo.description = x_description OR (recinfo.description IS NULL AND x_description IS NULL))
          AND (TRUNC (recinfo.start_date) = TRUNC (x_start_date) OR (recinfo.start_date IS NULL AND x_start_date IS NULL))
          AND (TRUNC (recinfo.end_date) = TRUNC (x_end_date) OR (recinfo.end_date IS NULL AND x_end_date IS NULL))
          AND (recinfo.payee_assign_flag = x_payee_assign_flag OR (recinfo.payee_assign_flag IS NULL AND x_payee_assign_flag IS NULL))
          AND (recinfo.vesting_flag = x_vesting_flag OR (recinfo.vesting_flag IS NULL AND x_vesting_flag IS NULL))
          AND (recinfo.calc_formula_id = x_calc_formula_id OR (recinfo.calc_formula_id IS NULL AND x_calc_formula_id IS NULL))
          AND (recinfo.credit_type_id = x_credit_type_id OR (recinfo.credit_type_id IS NULL AND x_credit_type_id IS NULL))
          AND (recinfo.package_name = x_package_name OR (recinfo.package_name IS NULL AND x_package_name IS NULL))
          AND (recinfo.interval_type_id = x_interval_type_id OR (recinfo.interval_type_id IS NULL AND x_interval_type_id IS NULL))
          AND (   recinfo.addup_from_rev_class_flag = x_addup_from_rev_class_flag
               OR (recinfo.addup_from_rev_class_flag IS NULL AND x_addup_from_rev_class_flag IS NULL)
              )
         )
      THEN
         RETURN;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END LOCK_RECORD;

-----------------------------------------------------------------------------+
--|                            Public Routine Bodies                         |
-----------------------------------------------------------------------------+
-- Name

   -- Purpose

   -- Notes
   PROCEDURE begin_record (
      x_operation                         VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_quota_id                 IN OUT NOCOPY NUMBER,
      x_object_version_number    OUT NOCOPY NUMBER,
      x_name                              VARCHAR2,
      x_target                            NUMBER,
      x_quota_type_code                   VARCHAR2,
      x_period_type_code                  VARCHAR2,
      x_usage_code                        VARCHAR2,
      x_payment_amount                    NUMBER,
      x_description                       VARCHAR2,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_quota_status                      VARCHAR2,
      x_start_num                         NUMBER,
      x_end_num                           NUMBER,
      x_program_type                      VARCHAR2,
      --x_status_code                       VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_incentive_type_code               VARCHAR2,
      x_credit_type_id                    NUMBER,
      x_calc_formula_id                   NUMBER,
      x_rt_sched_custom_flag              VARCHAR2,
      x_package_name                      VARCHAR2,
      x_performance_goal                  NUMBER,
      x_interval_type_id                  NUMBER,
      x_payee_assign_flag                 VARCHAR2,
      x_vesting_flag                      VARCHAR2,
      x_quota_unspecified                 NUMBER,
      x_addup_from_rev_class_flag         VARCHAR2,
      x_expense_account_id                NUMBER,
      x_liability_account_id              NUMBER,
      x_quota_group_code                  VARCHAR2,
      --clku PAYMENT ENHANCEMENT
      x_payment_group_code                VARCHAR2 := 'STANDARD',
      --clku, bug 2854576
      x_attribute_category                VARCHAR2 := NULL,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      -- fmburu r12
      x_indirect_credit                   VARCHAR2,
      x_org_id                            NUMBER,
      x_salesrep_end_flag                  VARCHAR2
   )
   IS
   BEGIN
      -- Saves passing it around
      g_program_type := x_program_type;
      g_temp_status_code := 'COMPLETE';

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD (x_rowid,
                        x_quota_id,
                        x_object_version_number,
                        x_name,
                        x_target,
                        x_quota_type_code,
                        x_period_type_code,
                        x_usage_code,
                        x_payment_amount,
                        x_description,
                        x_start_date,
                        x_end_date,
                        x_quota_status,
                        x_start_num,
                        x_end_num,
                        x_last_update_date,
                        x_last_updated_by,
                        x_creation_date,
                        x_created_by,
                        x_last_update_login,
                        x_incentive_type_code,
                        x_credit_type_id,
                        x_calc_formula_id,
                        x_rt_sched_custom_flag,
                        x_package_name,
                        x_performance_goal,
                        x_interval_type_id,
                        x_payee_assign_flag,
                        x_vesting_flag,
                        x_quota_unspecified,
                        x_addup_from_rev_class_flag,
                        x_expense_account_id,
                        x_liability_account_id,
                        x_quota_group_code,
                        --clku, PAYMENT ENHANCEMENT
                        x_payment_group_code,
                        --clku, 2854576
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        -- fmburu r12
                        x_indirect_credit,
                        x_org_id,
			nvl(x_salesrep_end_flag,'N')
                       );
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD (x_quota_id,
                        x_object_version_number,
                        x_name,
                        x_target,
                        x_quota_type_code,
                        x_period_type_code,
                        x_usage_code,
                        x_payment_amount,
                        x_description,
                        x_start_date,
                        x_end_date,
                        x_quota_status,
                        x_start_num,
                        x_end_num,
                        x_last_update_date,
                        x_last_updated_by,
                        x_last_update_login,
                        x_incentive_type_code,
                        x_credit_type_id,
                        x_calc_formula_id,
                        x_rt_sched_custom_flag,
                        x_package_name,
                        x_performance_goal,
                        x_interval_type_id,
                        x_payee_assign_flag,
                        x_vesting_flag,
                        x_quota_unspecified,
                        x_addup_from_rev_class_flag,
                        x_expense_account_id,
                        x_liability_account_id,
                        x_quota_group_code,
                        --clku, PAYMENT ENHANCEMENT
                        x_payment_group_code,
                        --clku, 2854576
                        x_attribute_category,
                        x_attribute1,
                        x_attribute2,
                        x_attribute3,
                        x_attribute4,
                        x_attribute5,
                        x_attribute6,
                        x_attribute7,
                        x_attribute8,
                        x_attribute9,
                        x_attribute10,
                        x_attribute11,
                        x_attribute12,
                        x_attribute13,
                        x_attribute14,
                        x_attribute15,
                        -- fmburu r12
                        x_indirect_credit,
                        x_salesrep_end_flag
                       );
         NULL;
      ELSIF x_operation = 'LOCK'
      THEN
         LOCK_RECORD (x_rowid,
                      x_quota_id,
                      x_object_version_number,
                      x_name,
                      x_target,
                      x_description,
                      x_quota_type_code,
                      x_period_type_code,
                      x_usage_code,
                      x_payment_amount,
                      x_start_date,
                      x_end_date,
                      x_quota_status,
                      x_start_num,
                      x_end_num,
                      x_incentive_type_code,
                      x_credit_type_id,
                      x_calc_formula_id,
                      x_rt_sched_custom_flag,
                      x_package_name,
                      x_performance_goal,
                      x_interval_type_id,
                      x_payee_assign_flag,
                      x_vesting_flag,
                      x_quota_group_code,
                      x_quota_unspecified,
                      x_addup_from_rev_class_flag,
                      x_attribute1,
                      x_attribute2,
                      x_attribute3,
                      x_attribute4,
                      x_attribute5,
                      x_attribute6,
                      x_attribute7,
                      x_attribute8,
                      x_attribute9,
                      x_attribute10,
                      x_attribute11,
                      x_attribute12,
                      x_attribute13,
                      x_attribute14,
                      x_attribute15,
                      -- fmburu r12
                      x_indirect_credit
                     );
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD (x_quota_id, x_name);
      END IF;
   END begin_record;
END cn_quotas_pkg;

/
