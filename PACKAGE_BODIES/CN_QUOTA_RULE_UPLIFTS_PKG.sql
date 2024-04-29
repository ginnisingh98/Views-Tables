--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_UPLIFTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_UPLIFTS_PKG" AS
/* $Header: cnpliqrub.pls 120.2 2005/08/05 00:32:02 fmburu ship $ */
/*
Date      Name          Description
------------------------------------------------------------------------------+
  29-APR-99 S Kumar  Create/Update/Delete/Lock
  APR-2005  Fred mburu refactor
*/
------------------------------------------------------------------------------+
--                      Variables
------------------------------------------------------------------------------+
   g_program_type                VARCHAR2 (30) := NULL;

------------------------------------------------------------------------------+
--                            Private Routines
------------------------------------------------------------------------------+
-- Name
--
-- Purpose
--
-- Notes
--
--
   PROCEDURE get_uid (
      x_quota_rule_uplift_id     IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      SELECT cn_quota_rule_uplifts_s.NEXTVAL
        INTO x_quota_rule_uplift_id
        FROM SYS.DUAL;
   END get_uid;

-- Name
--
-- Purpose
--
-- Notes
--
------------------------------------------------------------------------------+
-- Insert_record
------------------------------------------------------------------------------+
   PROCEDURE INSERT_RECORD (
      x_org_id                            NUMBER,
      x_quota_rule_uplift_id     IN OUT NOCOPY NUMBER,
      x_quota_rule_id                     NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_payment_factor                    NUMBER,
      x_quota_factor                      NUMBER,
      x_start_date_old                    DATE,
      x_end_date_old                      DATE,
      x_object_version_number  OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      get_uid (x_quota_rule_uplift_id);
      x_object_version_number := 1;

      INSERT INTO cn_quota_rule_uplifts
                  (org_id,
                   quota_rule_uplift_id,
                   quota_rule_id,
                   payment_factor,
                   quota_factor,
                   start_date,
                   end_date,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   object_version_number
                  )
           VALUES (x_org_id,
                   x_quota_rule_uplift_id,
                   x_quota_rule_id,
                   x_payment_factor,
                   x_quota_factor,
                   x_start_date,
                   x_end_date,
                   x_last_update_date,
                   x_last_updated_by,
                   x_creation_date,
                   x_created_by,
                   x_last_update_login,
                   x_object_version_number
                  );

      -- create the srp quota rule uplifts
      cn_srp_rule_uplifts_pkg.INSERT_RECORD (p_srp_plan_assign_id        => NULL,
                                             p_quota_id                  => NULL,
                                             p_quota_rule_id             => x_quota_rule_id,
                                             p_quota_rule_uplift_id      => x_quota_rule_uplift_id
                                            );
   END INSERT_RECORD;

-- Name
--
-- Purpose
--
-- Notes
--
--
------------------------------------------------------------------------------+
-- Update_Record
------------------------------------------------------------------------------+
   PROCEDURE UPDATE_RECORD (
      x_org_id                            NUMBER,
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_start_date                        DATE,
      x_start_date_old                    DATE,
      x_payment_factor                    NUMBER,
      x_payment_factor_old                NUMBER,
      x_quota_factor                      NUMBER,
      x_quota_factor_old                  NUMBER,
      x_end_date                          DATE,
      x_end_date_old                      DATE,
      x_object_version_number OUT NOCOPY  NUMBER
   )
   IS
      CURSOR c  IS
         SELECT        *
         FROM cn_quota_rule_uplifts
         WHERE quota_rule_uplift_id = x_quota_rule_uplift_id;

      recinfo                       c%ROWTYPE;
   BEGIN

      OPEN c;
      FETCH c INTO recinfo;
      CLOSE c;

      x_object_version_number := NVL (recinfo.object_version_number, 1) + 1;

      UPDATE cn_quota_rule_uplifts
         SET payment_factor = x_payment_factor,
             quota_factor = x_quota_factor,
             start_date = x_start_date,
             end_date = x_end_date,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             object_version_number = x_object_version_number
      WHERE quota_rule_uplift_id = x_quota_rule_uplift_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      cn_srp_rule_uplifts_pkg.UPDATE_RECORD (p_quota_rule_uplift_id      => x_quota_rule_uplift_id,
                                             p_quota_factor              => x_quota_factor,
                                             p_payment_factor            => x_payment_factor
                                            );
   END UPDATE_RECORD;

------------------------------------------------------------------------------+
-- Lock Record
------------------------------------------------------------------------------+
   PROCEDURE LOCK_RECORD (
      x_org_id                            NUMBER,
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_payment_factor                    NUMBER,
      x_quota_factor                      NUMBER
   )
   IS
   BEGIN
      NULL;
   END LOCK_RECORD;

-- Name
--
-- Purpose
--
-- Notes
-- Delete the quota rule uplift can be done in three ways
-- 1. delete the given quota rule uplift only
-- 2. delete  all uplift  factor for given quota rule
-- 3. delete  all uplift  factor including all quota rules for a quota
------------------------------------------------------------------------------+
-- Delete_record
------------------------------------------------------------------------------+
   PROCEDURE DELETE_RECORD (
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_quota_id                          NUMBER
   )
   IS
   BEGIN
      --clku, bug 2257692
      IF x_quota_rule_uplift_id IS NOT NULL
      THEN
         -- delete with id
         DELETE FROM cn_quota_rule_uplifts
               WHERE quota_rule_uplift_id = x_quota_rule_uplift_id;

         IF (SQL%NOTFOUND)
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
      ELSIF x_quota_rule_id IS NOT NULL
      THEN
         -- Deleting an entire quota rule Uplifts
         DELETE FROM cn_quota_rule_uplifts
               WHERE quota_rule_id = x_quota_rule_id;
      ELSIF x_quota_id IS NOT NULL
      THEN
         DELETE FROM cn_quota_rule_uplifts cqru
               WHERE EXISTS (SELECT 1
                               FROM cn_quota_rules crq
                              WHERE crq.quota_rule_id = cqru.quota_rule_id AND crq.quota_id = x_quota_id);
      END IF;

      cn_srp_rule_uplifts_pkg.DELETE_RECORD (p_srp_plan_assign_id        => NULL,
                                             p_quota_id                  => x_quota_id,
                                             p_quota_rule_id             => x_quota_rule_id,
                                             p_quota_rule_uplift_id      => x_quota_rule_uplift_id
                                            );
   END DELETE_RECORD;

------------------------------------------------------------------------------+
--                            Public Routine Bodies
------------------------------------------------------------------------------+

   -- Procedure Name
--
-- Purpose
--
--
-- Notes
--
--
   PROCEDURE begin_record (
      x_operation                         VARCHAR2,
      x_org_id                            NUMBER,
      x_quota_rule_uplift_id     IN OUT NOCOPY NUMBER,
      x_quota_rule_id                     NUMBER,
      x_quota_rule_id_old                 NUMBER,
      x_start_date                        DATE,
      x_start_date_old                    DATE,
      x_end_date                          DATE,
      x_end_date_old                      DATE,
      x_payment_factor                    NUMBER,
      x_payment_factor_old                NUMBER,
      x_quota_factor                      NUMBER,
      x_quota_factor_old                  NUMBER,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_last_update_date                  DATE,
      x_program_type                      VARCHAR2,
      x_status_code                       VARCHAR2,
      x_object_version_number OUT NOCOPY  NUMBER
   )
   IS
   BEGIN
      g_program_type := x_program_type;

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD (x_org_id,
                        x_quota_rule_uplift_id,
                        x_quota_rule_id,
                        x_last_update_date,
                        x_last_updated_by,
                        x_creation_date,
                        x_created_by,
                        x_last_update_login,
                        x_start_date,
                        x_end_date,
                        x_payment_factor,
                        x_quota_factor,
                        x_start_date_old,
                        x_end_date_old,
                        x_object_version_number
                       );
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD (x_org_id,
                        x_quota_rule_uplift_id,
                        x_quota_rule_id,
                        x_last_update_date,
                        x_last_updated_by,
                        x_last_update_login,
                        x_start_date,
                        x_start_date_old,
                        x_payment_factor,
                        x_payment_factor_old,
                        x_quota_factor,
                        x_quota_factor_old,
                        x_end_date,
                        x_end_date_old,
                        x_object_version_number
                       );
      ELSIF x_operation = 'LOCK'
      THEN
         LOCK_RECORD (x_org_id, x_quota_rule_uplift_id, x_quota_rule_id, x_start_date, x_end_date, x_payment_factor, x_quota_factor);
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD (x_quota_rule_uplift_id => x_quota_rule_uplift_id, x_quota_rule_id => NULL, x_quota_id => NULL);
      END IF;
   END begin_record;

-- Name
--
-- Purpose
--
-- Notes
--
--
   PROCEDURE end_record (
      x_rowid                             VARCHAR2,
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_payment_factor                    NUMBER,
      x_quota_factor                      NUMBER,
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
END cn_quota_rule_uplifts_pkg;

/
