--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULES_PKG" AS
/* $Header: cnpliqrb.pls 120.5.12000000.2 2007/10/09 22:19:24 rnagired ship $ */

   /*
   Date      Name          Description
   ---------------------------------------------------------------------------+
   15-FEB-95 P Cook  Unit tested
   14-APR-95 P Cook  Moved %notfound in delete_record in front of srp
            deletes to prevent no recs found error on plan
            no assigned to salesreps.
   07-AUG-95 P Cook  Pass CHANGE_RULE to mark_event instead of NEW_RULE
   17-MAR-99 S Kumar Added the Start Date and End Date Column
                           Commented the code for checking the Active Hierarchy.
                           under discussion on 05/12/99
                           Update the Revenue Class column in trx factor is
                           included
                           Modified more during 3i Changes.
   Name

   Purpose

   Notes


   */

   ---------------------------------------------------------------------------+
--                       Variables
---------------------------------------------------------------------------+
   g_program_type                VARCHAR2 (30) := NULL;

---------------------------------------------------------------------------+
--                            Private Routines
---------------------------------------------------------------------------+
-- Name

   -- Purpose

   -- Notes

   ---------------------------------------------------------------------------+
-- Get UID
---------------------------------------------------------------------------+
   PROCEDURE get_uid (
      x_quota_rule_id            IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      SELECT cn_quota_rules_s.NEXTVAL
        INTO x_quota_rule_id
        FROM SYS.DUAL;
   END get_uid;

-- Name

   -- Purpose

   -- Notes

   ---------------------------------------------------------------------------+
-- Update_quota
---------------------------------------------------------------------------+
   PROCEDURE update_quota (
      p_quota_id                          NUMBER
   )
   IS
      l_target                      NUMBER;
      l_payment_amount              NUMBER;
      l_performance_goal            NUMBER;
      g_last_update_date            DATE := SYSDATE;
      g_last_updated_by             NUMBER := fnd_global.user_id;
      g_creation_date               DATE := SYSDATE;
      g_created_by                  NUMBER := fnd_global.user_id;
      g_last_update_login           NUMBER := fnd_global.login_id;
      g_rowid                       VARCHAR2 (30);
      g_program_type                VARCHAR2 (30);
      l_pe_rec                      cn_quotas%ROWTYPE;
   BEGIN
      SELECT *
        INTO l_pe_rec
        FROM cn_quotas
       WHERE quota_id = p_quota_id;

      IF l_pe_rec.addup_from_rev_class_flag = 'Y'
      THEN
         SELECT SUM (NVL (target, 0)),
                SUM (NVL (payment_amount, 0)),
                SUM (NVL (performance_goal, 0))
           INTO l_target,
                l_payment_amount,
                l_performance_goal
           FROM cn_quota_rules
          WHERE quota_id = p_quota_id;

         cn_quotas_pkg.begin_record (x_operation                      => 'UPDATE',
                                     x_rowid                          => g_rowid,
                                     x_quota_id                       => l_pe_rec.quota_id,
                                     x_object_version_number          => l_pe_rec.object_version_number,
                                     x_name                           => l_pe_rec.NAME,
                                     x_target                         => NVL (l_target, 0),
                                     x_quota_type_code                => l_pe_rec.quota_type_code,
                                     x_usage_code                     => NULL,
                                     x_payment_amount                 => NVL (l_payment_amount, 0),
                                     x_description                    => l_pe_rec.description,
                                     x_start_date                     => l_pe_rec.start_date,
                                     x_end_date                       => l_pe_rec.end_date,
                                     x_quota_status                   => l_pe_rec.quota_status,
                                     x_calc_formula_id                => l_pe_rec.calc_formula_id,
                                     x_incentive_type_code            => l_pe_rec.incentive_type_code,
                                     x_credit_type_id                 => l_pe_rec.credit_type_id,
                                     x_rt_sched_custom_flag           => l_pe_rec.rt_sched_custom_flag,
                                     x_package_name                   => l_pe_rec.package_name,
                                     x_performance_goal               => NVL (l_performance_goal, 0),
                                     x_interval_type_id               => l_pe_rec.interval_type_id,
                                     x_payee_assign_flag              => l_pe_rec.payee_assign_flag,
                                     x_vesting_flag                   => l_pe_rec.vesting_flag,
                                     x_expense_account_id             => l_pe_rec.expense_account_id,
                                     x_liability_account_id           => l_pe_rec.liability_account_id,
                                     x_quota_group_code               => l_pe_rec.quota_group_code,
                                     x_payment_group_code             => l_pe_rec.payment_group_code,
                                     x_quota_unspecified              => NULL,
                                     x_last_update_date               => g_last_update_date,
                                     x_last_updated_by                => g_last_updated_by,
                                     x_creation_date                  => g_creation_date,
                                     x_created_by                     => g_created_by,
                                     x_last_update_login              => g_last_update_login,
                                     x_program_type                   => g_program_type,
                                     --x_status_code                    => NULL,
                                     x_period_type_code               => NULL,
                                     x_start_num                      => NULL,
                                     x_end_num                        => NULL,
                                     x_addup_from_rev_class_flag      => l_pe_rec.addup_from_rev_class_flag,
                                     x_attribute_category             => l_pe_rec.attribute_category,
                                     x_attribute1                     => l_pe_rec.attribute1,
                                     x_attribute2                     => l_pe_rec.attribute2,
                                     x_attribute3                     => l_pe_rec.attribute3,
                                     x_attribute4                     => l_pe_rec.attribute4,
                                     x_attribute5                     => l_pe_rec.attribute5,
                                     x_attribute6                     => l_pe_rec.attribute6,
                                     x_attribute7                     => l_pe_rec.attribute7,
                                     x_attribute8                     => l_pe_rec.attribute8,
                                     x_attribute9                     => l_pe_rec.attribute9,
                                     x_attribute10                    => l_pe_rec.attribute10,
                                     x_attribute11                    => l_pe_rec.attribute11,
                                     x_attribute12                    => l_pe_rec.attribute12,
                                     x_attribute13                    => l_pe_rec.attribute13,
                                     x_attribute14                    => l_pe_rec.attribute14,
                                     x_attribute15                    => l_pe_rec.attribute15,
                                     x_indirect_credit                => l_pe_rec.indirect_credit,
                                     x_org_id                         => l_pe_rec.org_id,
                                     x_salesrep_end_flag              => l_pe_rec.salesreps_enddated_flag
                                    );
      END IF;
   END update_quota;

   -- Name

   -- Purpose

   -- Notes

   -------------------------------------------------------------------------+
-- Insert_record
---------------------------------------------------------------------------+
   PROCEDURE INSERT_RECORD (
      x_org_id                            NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_target                            NUMBER,
      x_payment_amount                    NUMBER,
      x_performance_goal                  NUMBER,
      x_quota_rule_id            IN OUT NOCOPY NUMBER,
      x_revenue_class_name                VARCHAR2,
      x_object_version_number    IN OUT NOCOPY NUMBER
   )
   IS
      l_name                        cn_quotas_all.NAME%TYPE;
   BEGIN
      -- Change the comp Status
      cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                    x_quota_id              => x_quota_id,
                                    x_rate_schedule_id      => NULL,
                                    x_status_code           => 'INCOMPLETE',
                                    x_event                 => 'CHANGE_RULE'
                                   );

      x_object_version_number := 1 ;
      IF x_quota_rule_id IS NULL THEN
      select cn_quota_rules_s.nextval into x_quota_rule_id from dual;
      END IF;
      -- Insert Quota Rules
      -- object version number insert added, clku
      INSERT INTO cn_quota_rules
                  (quota_rule_id,
                   quota_id,
                   revenue_class_id,
                   org_id,
                   target,
                   payment_amount,
                   performance_goal,
                   NAME,                                                                                                -- unmaintained should drop it
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   object_version_number
                  )
           VALUES (x_quota_rule_id,
                   x_quota_id,
                   x_revenue_class_id,
                   x_org_id,
                   x_target,
                   x_payment_amount,
                   x_performance_goal,
                   'QUOTA RULE NAME',
                   x_last_update_date,
                   x_last_updated_by,
                   x_creation_date,
                   x_created_by,
                   x_last_update_login,
                   x_object_version_number
                  );

----------------------------------------------------------------------------------
-- Code from the trigger CN_QUOTA_RULE_TL
----------------------------------------------------------------------------------
      SELECT NAME
        INTO l_name
        FROM cn_quotas_all
       WHERE quota_id = x_quota_id;

      cn_mark_events_pkg.mark_event_quota (p_event_name          => 'CHANGE_QUOTA_ROLL',
                                           p_object_name         => l_name,
                                           p_object_id           => x_quota_id,
                                           p_start_date          => NULL,
                                           p_start_date_old      => NULL,
                                           p_end_date            => NULL,
                                           p_end_date_old        => NULL,
                                           p_org_id              => x_org_id
                                          );
----------------------------------------------------------------------------------
-- End of trigger code
----------------------------------------------------------------------------------

      -- update the target , payment, performance goal to quota.
      update_quota (x_quota_id);
      -- Create trx factors
      cn_trx_factors_pkg.INSERT_RECORD (x_quota_id, x_quota_rule_id, x_revenue_class_id);
      -- Create Srp quota Rules
      cn_srp_quota_rules_pkg.INSERT_RECORD (x_srp_plan_assign_id      => NULL,
                                            x_quota_id                => x_quota_id,
                                            x_quota_rule_id           => x_quota_rule_id,
                                            x_revenue_class_id        => x_revenue_class_id
                                           );
   END INSERT_RECORD;

-- Name

   -- Purpose

   -- Notes

   ---------------------------------------------------------------------------+
-- Update_record
---------------------------------------------------------------------------+
   PROCEDURE UPDATE_RECORD (
      x_quota_rule_id                     NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_object_version_number    OUT NOCOPY  NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_target                            NUMBER,
      x_target_old                        NUMBER,
      x_payment_amount                    NUMBER,
      x_payment_amount_old                NUMBER,
      x_performance_goal                  NUMBER,
      x_performance_goal_old              NUMBER,
      x_revenue_class_name                VARCHAR2,
      x_status_code                       VARCHAR2,
      x_revenue_class_id_old              NUMBER
   )
   IS
      l_name                        cn_quotas.NAME%TYPE;
      l_org_id                      cn_quotas.org_id%TYPE;
   BEGIN
      IF g_program_type = 'FORM'
      THEN
         IF (x_revenue_class_id_old <> x_revenue_class_id)
         THEN
            -- If the key values have changed update the status
            cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                          x_quota_id              => x_quota_id,
                                          x_rate_schedule_id      => NULL,
                                          x_status_code           => 'INCOMPLETE',
                                          x_event                 => 'CHANGE_RULE'
                                         );
         ELSIF (   NVL (x_target_old, 0) <> x_target
                OR NVL (x_payment_amount_old, 0) <> x_payment_amount
                OR NVL (x_performance_goal_old, 0) <> x_performance_goal
               )
         THEN
            -- if the key values have changed update the status
            cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                          x_quota_id              => x_quota_id,
                                          x_rate_schedule_id      => NULL,
                                          x_status_code           => 'INCOMPLETE',
                                          x_event                 => 'CHANGE_FACTORS'
                                         );
         END IF;
      ELSIF g_program_type = 'BATCH'
      THEN
         NULL;                                                                                       -- need procedure to check db against new values
      END IF;

      SELECT (NVL (object_version_number, 1) + 1)
        INTO x_object_version_number
        FROM cn_quota_rules
       WHERE quota_rule_id = x_quota_rule_id;

      UPDATE cn_quota_rules
         SET revenue_class_id = x_revenue_class_id,
             quota_id = x_quota_id,
             target = x_target,
             payment_amount = x_payment_amount,
             performance_goal = x_performance_goal,
             quota_rule_id = x_quota_rule_id,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             object_version_number = x_object_version_number,
             NAME = 'QUOTA RULE NAME'
       WHERE quota_rule_id = x_quota_rule_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF NVL (x_revenue_class_id_old, x_revenue_class_id) <> x_revenue_class_id
      THEN
         cn_srp_quota_rules_pkg.DELETE_RECORD (x_srp_plan_assign_id       => NULL,
                                               x_srp_quota_assign_id      => NULL,
                                               x_quota_id                 => x_quota_id,
                                               x_quota_rule_id            => x_quota_rule_id,
                                               x_revenue_class_id         => x_revenue_class_id_old
                                              );
         cn_srp_quota_rules_pkg.INSERT_RECORD (x_srp_plan_assign_id      => NULL,
                                               x_quota_id                => x_quota_id,
                                               x_quota_rule_id           => x_quota_rule_id,
                                               x_revenue_class_id        => x_revenue_class_id
                                              );

         -- Added recently
         UPDATE cn_trx_factors
            SET revenue_class_id = x_revenue_class_id
          WHERE quota_rule_id = x_quota_rule_id;
      ELSIF    NVL (x_target, 0) <> NVL (x_target_old, 0)
            OR NVL (x_payment_amount, 0) <> NVL (x_payment_amount_old, 0)
            OR NVL (x_performance_goal, 0) <> NVL (x_performance_goal_old, 0)
      THEN
         cn_srp_quota_rules_pkg.UPDATE_RECORD (x_quota_rule_id         => x_quota_rule_id,
                                               x_target                => x_target,
                                               x_payment_amount        => x_payment_amount,
                                               x_performance_goal      => x_performance_goal
                                              );
      END IF;

      update_quota (x_quota_id);

----------------------------------------------------------------------------------
-- Code from the trigger CN_QUOTA_RULE_TL
----------------------------------------------------------------------------------
      SELECT NAME,
             org_id
        INTO l_name,
             l_org_id
        FROM cn_quotas_all
       WHERE quota_id = x_quota_id;

      cn_mark_events_pkg.mark_event_quota (p_event_name          => 'CHANGE_QUOTA_ROLL',
                                           p_object_name         => l_name,
                                           p_object_id           => x_quota_id,
                                           p_start_date          => NULL,
                                           p_start_date_old      => NULL,
                                           p_end_date            => NULL,
                                           p_end_date_old        => NULL,
                                           p_org_id              => l_org_id
                                          );
----------------------------------------------------------------------------------
-- End of code from CN_QUOTA_RULE_TL
----------------------------------------------------------------------------------
   END UPDATE_RECORD;

-- Name

   -- Purpose

   -- Notes

   ---------------------------------------------------------------------------+
-- Lock_record
---------------------------------------------------------------------------+
   PROCEDURE LOCK_RECORD (
      x_org_id                            NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_target                            NUMBER,
      x_payment_amount                    NUMBER,
      x_performance_goal                  NUMBER,
      x_quota_rule_id                     NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_quota_rules
                 WHERE quota_rule_id = x_quota_rule_id
         FOR UPDATE OF quota_rule_id NOWAIT;

      recinfo                       c%ROWTYPE;
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

      IF (    (recinfo.revenue_class_id = x_revenue_class_id)
          AND (recinfo.quota_id = x_quota_id)
          AND (recinfo.quota_rule_id = x_quota_rule_id)
          AND ((recinfo.target = x_target) OR (recinfo.target IS NULL AND x_target IS NULL))
          AND ((recinfo.payment_amount = x_payment_amount) OR (recinfo.payment_amount IS NULL AND x_payment_amount IS NULL))
          AND ((recinfo.performance_goal = x_performance_goal) OR (recinfo.performance_goal IS NULL AND x_performance_goal IS NULL))
         )
      THEN
         RETURN;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END LOCK_RECORD;

-- Name

   -- Purpose

   -- Notes
---------------------------------------------------------------------------+
-- Delete_record
---------------------------------------------------------------------------+
   PROCEDURE DELETE_RECORD (
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_revenue_class_id                  NUMBER
   )
   IS
      l_name                        cn_quotas.NAME%TYPE;
      l_org_id                      cn_quotas.org_id%TYPE;
   BEGIN
      IF x_quota_id IS NOT NULL
      THEN
         IF x_quota_rule_id IS NOT NULL
         THEN
            -- We are deleting an individual quota rule
            cn_comp_plans_pkg.set_status (x_comp_plan_id          => NULL,
                                          x_quota_id              => x_quota_id,
                                          x_rate_schedule_id      => NULL,
                                          x_status_code           => 'INCOMPLETE',
                                          x_event                 => 'CHANGE_RULE'
                                         );
            --delete the quota rule uplifts if there is delete in the
            -- quota rules, and we should take care all the quota rule uplifts
            -- must be deleted if there is a full delete in quota rules using
            --quota id
            cn_quota_rule_uplifts_pkg.DELETE_RECORD (x_quota_rule_uplift_id => NULL, x_quota_rule_id => x_quota_rule_id, x_quota_id => x_quota_id);
            cn_srp_quota_rules_pkg.DELETE_RECORD (x_srp_plan_assign_id       => NULL,
                                                  x_srp_quota_assign_id      => NULL,
                                                  x_quota_id                 => x_quota_id,
                                                  x_quota_rule_id            => x_quota_rule_id,
                                                  x_revenue_class_id         => x_revenue_class_id
                                                 );

            DELETE FROM cn_quota_rules
                  WHERE quota_rule_id = x_quota_rule_id;

            IF (SQL%NOTFOUND)
            THEN
               RAISE NO_DATA_FOUND;
            END IF;
         ELSE
            --delete the quota rule uplifts if there is delete in the
            -- quota rules, and we should take care all the quota rule uplifts
            -- must be deleted if there is a full delete in quota rules using
            --quota id
            cn_quota_rule_uplifts_pkg.DELETE_RECORD (x_quota_rule_uplift_id => NULL, x_quota_rule_id => x_quota_rule_id, x_quota_id => x_quota_id);
            -- Deleting an entire quota OR changing its type to one that does not
            -- support revenue classes and therefore trx factors
            -- If we are deleting a quota there is no need to maintain the srp
            -- tables because you can't delete a quota that is assigned to a rep.
            -- However we don't discriminate between deletinga quota and changing
            -- its type so we must maintain the srp tables in this statement.
            cn_srp_quota_rules_pkg.DELETE_RECORD (x_srp_plan_assign_id       => NULL,
                                                  x_srp_quota_assign_id      => NULL,
                                                  x_quota_id                 => x_quota_id,
                                                  x_quota_rule_id            => x_quota_rule_id,
                                                  x_revenue_class_id         => x_revenue_class_id
                                                 );

            DELETE FROM cn_quota_rules
                  WHERE quota_id = x_quota_id;
         END IF;

         update_quota (x_quota_id);
         -- quota rule id and revenue class id will be null if deleting an
         -- entire quota or changing the type
         cn_trx_factors_pkg.DELETE_RECORD (x_trx_factor_id => NULL, x_quota_rule_id => x_quota_rule_id, x_quota_id => x_quota_id);
      END IF;

----------------------------------------------------------------------------------
-- Code from the trigger CN_QUOTA_RULE_TL
----------------------------------------------------------------------------------
      SELECT NAME,
             org_id
        INTO l_name,
             l_org_id
        FROM cn_quotas_all
       WHERE quota_id = x_quota_id;

      cn_mark_events_pkg.mark_event_quota (p_event_name          => 'CHANGE_QUOTA_ROLL',
                                           p_object_name         => l_name,
                                           p_object_id           => x_quota_id,
                                           p_start_date          => NULL,
                                           p_start_date_old      => NULL,
                                           p_end_date            => NULL,
                                           p_end_date_old        => NULL,
                                           p_org_id              => l_org_id
                                          );
-------------------------------------
-- End of code from CN_QUOTA_RULE_TL
-------------------------------------
   END DELETE_RECORD;

---------------------------------------------------------------------------+
--  Public Routine Bodies
---------------------------------------------------------------------------+

   -- Purpose
---------------------------------------------------------------------------+
-- get_rev_class_name
---------------------------------------------------------------------------+
   PROCEDURE get_rev_class_name (
      x_revenue_class_id                  NUMBER,
      x_revenue_class_name       IN OUT NOCOPY VARCHAR2
   )
   IS
   BEGIN
      IF x_revenue_class_id IS NOT NULL
      THEN
         SELECT NAME
           INTO x_revenue_class_name
           FROM cn_revenue_classes
          WHERE revenue_class_id = x_revenue_class_id;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE NO_DATA_FOUND;
   END get_rev_class_name;

-- Name

   -- Purpose

   -- Notes

   ---------------------------------------------------------------------------+
-- Begin_Record
---------------------------------------------------------------------------+
   PROCEDURE begin_record (
      x_quota_rule_id            IN OUT NOCOPY NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER,
      x_org_id                            NUMBER,
      x_operation                         VARCHAR2,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_target                            NUMBER,
      x_target_old                        NUMBER,
      x_payment_amount                    NUMBER,
      x_payment_amount_old                NUMBER,
      x_performance_goal                  NUMBER,
      x_performance_goal_old              NUMBER,
      x_revenue_class_name                VARCHAR2,
      x_program_type                      VARCHAR2,
      x_status_code                       VARCHAR2,
      x_revenue_class_id_old              NUMBER
   )
   IS
   BEGIN
      g_program_type := x_program_type;

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD (x_org_id,
                        x_revenue_class_id,
                        x_quota_id,
                        x_last_update_date,
                        x_last_updated_by,
                        x_creation_date,
                        x_created_by,
                        x_last_update_login,
                        x_target,
                        x_payment_amount,
                        x_performance_goal,
                        x_quota_rule_id,
                        x_revenue_class_name,
                        x_object_version_number
                       );
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD (x_quota_rule_id,
                        x_revenue_class_id,
                        x_quota_id,
                        x_object_version_number,
                        x_last_update_date,
                        x_last_updated_by,
                        x_last_update_login,
                        x_target,
                        x_target_old,
                        x_payment_amount,
                        x_payment_amount_old,
                        x_performance_goal,
                        x_performance_goal_old,
                        x_revenue_class_name,
                        x_status_code,
                        x_revenue_class_id_old
                       );
      ELSIF x_operation = 'LOCK'
      THEN
         LOCK_RECORD (x_org_id, x_revenue_class_id, x_quota_id, x_target, x_payment_amount, x_performance_goal, x_quota_rule_id);
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD (x_quota_id, x_quota_rule_id, x_revenue_class_id);
      END IF;
   END begin_record;

-- Name

   -- Purpose

   -- Notes
---------------------------------------------------------------------------+
-- End Record
---------------------------------------------------------------------------+
   PROCEDURE end_record (
      x_rowid                             VARCHAR2,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_target                            NUMBER,
      x_payment_amount                    NUMBER,
      x_performance_goal                  NUMBER,
      x_quota_rule_id                     NUMBER,
      x_program_type                      VARCHAR2
   )
   IS
   BEGIN
      -- Saves passing it around
      g_program_type := x_program_type;
      -- no validation perfromed here. All validation aimed at changing the
      -- status of the quota is performed in the quota package.
      NULL;
   END end_record;

-- Purpose :
--   Checks if X_revenue_class_id is a parent in a hierarchy
--   for any other revenue_class_id already saved in the database
--   for the X_quota_id

   -- Most of the Period check is commented and the logic is yet
-- to be derived.

   ---------------------------------------------------------------------------+
-- Check_rev_class_hier
---------------------------------------------------------------------------+
   FUNCTION check_rev_class_hier (
      x_revenue_class_id                  NUMBER,
      x_revenue_class_id_old              NUMBER,
      x_quota_id                          NUMBER,
      x_start_period_id                   NUMBER,
      x_end_period_id                     NUMBER
   )
      RETURN BOOLEAN
   IS
      CURSOR c1_cur
      IS
         SELECT a.dim_hierarchy_id
           FROM cn_dim_hierarchies a,
                cn_head_hierarchies b,
                cn_repositories c
          WHERE b.dimension_id = -1001                                                                                           /* Revenue Classes */
            AND a.header_dim_hierarchy_id = b.head_hierarchy_id
            AND b.head_hierarchy_id = c.rev_class_hierarchy_id;                                                                       /* Active hierar
                                                                                 chy */

      --         and ((X_start_period_id between a.start_period_id and a.end_perio
      --d_id)
      --                  OR(X_end_period_id between a.start_period_id and a.end_period_
      --id)
      --                  OR(a.start_period_id between X_start_period_id and X_end_perio
      --     d_id));
      CURSOR c2_csr (
         l_dim_hierarchy_id                  NUMBER
      )
      IS
         SELECT rv.NAME
           FROM cn_dim_explosion de1,
                cn_dim_explosion de2,
                cn_quota_rules qr,
                cn_revenue_classes rv
          WHERE de1.dim_hierarchy_id = l_dim_hierarchy_id
            AND de2.dim_hierarchy_id = l_dim_hierarchy_id
            AND de1.value_external_id = de2.value_external_id
            AND de1.ancestor_external_id = x_revenue_class_id
            AND qr.quota_id = x_quota_id
            AND de2.ancestor_external_id = qr.revenue_class_id
            AND rv.revenue_class_id = qr.revenue_class_id
            AND qr.revenue_class_id <> NVL (x_revenue_class_id_old, -999);

      l_count                       NUMBER;
      l_flag                        BOOLEAN;
      l_periods                     VARCHAR2 (30);
      l_rev_class_name_parent       VARCHAR2 (30);
      l_rev_class_name_child        VARCHAR2 (30);
   BEGIN
      l_flag := TRUE;

      FOR c1_row IN c1_cur
      LOOP
         SELECT COUNT (*)
           INTO l_count
           FROM cn_dim_explosion a,
                cn_quota_rules b
          WHERE a.dim_hierarchy_id = c1_row.dim_hierarchy_id
            AND a.hierarchy_level <> 0                                                                                      /*Do not self reference */
            AND b.quota_id = x_quota_id
            AND b.revenue_class_id <> NVL (x_revenue_class_id_old, -999)
            AND (   (b.revenue_class_id = a.value_external_id AND a.ancestor_external_id = x_revenue_class_id)
                 OR (b.revenue_class_id = a.ancestor_external_id AND a.value_external_id = x_revenue_class_id)
                );

         IF (l_count > 0)
         THEN                                                                                                                    /* error condition */
            --   select a.period_name||' to '||b.period_name into l_periods
            --     from cn_periods a, cn_periods b
            --    where a.period_id = X_start_period_id
            --      and b.period_id = X_end_period_id;
            SELECT a.NAME,
                   b.NAME
              INTO l_rev_class_name_parent,
                   l_rev_class_name_child
              FROM cn_revenue_classes a,
                   cn_revenue_classes b,
                   cn_quota_rules c,
                   cn_dim_explosion d
             WHERE d.hierarchy_level <> 0
               AND d.dim_hierarchy_id = c1_row.dim_hierarchy_id
               AND c.revenue_class_id <> NVL (x_revenue_class_id_old, -999)
               AND b.revenue_class_id = c.revenue_class_id
               AND a.revenue_class_id = x_revenue_class_id
               AND c.quota_id = x_quota_id
               AND (   (d.ancestor_external_id = x_revenue_class_id AND d.value_external_id = c.revenue_class_id)
                    OR (c.revenue_class_id = d.ancestor_external_id AND d.value_external_id = x_revenue_class_id)
                   )
               AND ROWNUM = 1;

            l_flag := FALSE;
            fnd_message.set_name ('CN', 'CN_REV_CLASS_HIER_CHECK');
            --fnd_message.set_token ('PERIODS', l_periods);
            fnd_message.set_token ('REV_CLASS_NAME_PARENT', l_rev_class_name_parent);
            fnd_message.set_token ('REV_CLASS_NAME_CHILD', l_rev_class_name_child);
            RETURN (l_flag);                                                                                                       /* return - error*/
         END IF;

         OPEN c2_csr (c1_row.dim_hierarchy_id);

         FETCH c2_csr
          INTO l_rev_class_name_child;

         IF c2_csr%ROWCOUNT <> 0
         THEN                                                                                                                    /* error condition */
            l_flag := FALSE;

            --           select a.period_name||' to '||b.period_name into l_periods
            --             from cn_periods a, cn_periods b
            --             where a.period_id = X_start_period_id
            --             and   b.period_id = X_end_period_id;
            SELECT a.NAME
              INTO l_rev_class_name_parent
              FROM cn_revenue_classes a
             WHERE a.revenue_class_id = x_revenue_class_id;

            fnd_message.set_name ('CN', 'REV_CLASS_COMMON_CHILD');
            fnd_message.set_token ('PERIODS', l_periods);
            fnd_message.set_token ('REV_CLASS_PARENT1', l_rev_class_name_parent);
            fnd_message.set_token ('REV_CLASS_PARENT2', l_rev_class_name_child);

            CLOSE c2_csr;

            RETURN (l_flag);                                                                                                       /* return - error*/
         END IF;

         CLOSE c2_csr;
      END LOOP;

      RETURN (l_flag);                                                                                                          /* return - success */
   END check_rev_class_hier;
END cn_quota_rules_pkg;

/
