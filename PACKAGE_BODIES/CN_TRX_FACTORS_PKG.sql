--------------------------------------------------------
--  DDL for Package Body CN_TRX_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRX_FACTORS_PKG" AS
/* $Header: cnplitfb.pls 120.1 2005/08/05 00:32:13 fmburu noship $ */

/*
Date      Name          Description
----------------------------------------------------------------------------+
15-FEB-95 P Cook  Unit tested
21-FEB-95 P Cook  Default trx factors.event_factor to 100%
27-FEB-95 P Cook  Of the Key Factors: invoice, payment and order only
         invoice is created with a 100% default.
APR-2005 Refactor fmburu
*/

   g_temp_status_code  VARCHAR2(10) := NULL;
   g_program_type      VARCHAR2(30) := NULL;

  --
  -- Purpose
  --   Insert a factor for each trx type. Called on quota rule commit.
  -- Notes
  --   cn_trx_types will be removed before production. modify this statement
  --   to run against cn_lookups for the trx type lookup

   PROCEDURE INSERT_RECORD(x_quota_id NUMBER, x_quota_rule_id NUMBER, x_revenue_class_id NUMBER)
   IS
      x_user_id           NUMBER := fnd_global.user_id;
      l_org_id            NUMBER := NULL;
   BEGIN
      SELECT ORG_ID
      INTO l_org_id
      FROM CN_QUOTAS_ALL
      WHERE QUOTA_ID = x_quota_id ;

     INSERT INTO cn_trx_factors
              (trx_factor_id,
               quota_id,
               quota_rule_id,
               revenue_class_id,
               trx_type,
               event_factor,
               created_by,
               creation_date,
               org_id,
               object_version_number)
        SELECT   cn_trx_factors_s.NEXTVAL,
                 x_quota_id,
                 x_quota_rule_id,
                 x_revenue_class_id,
                 lookup_code,
                 DECODE(lookup_code,
                        'ORD', 0,
                        'PMT', 0,
                        100),
                 x_user_id,
                 SYSDATE,
                 l_org_id,
                 1
        FROM     cn_lookups
        WHERE    lookup_type = 'TRX TYPES'
        AND lookup_code NOT IN ('BALANCE UPGRADE', 'UPGRADE');

   END INSERT_RECORD;

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE UPDATE_RECORD(
      x_trx_factor_id                     NUMBER,
      x_event_factor                      NUMBER,
      x_event_factor_old                  NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER,
      x_revenue_class_id                  NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type                          VARCHAR2,
      x_trx_type_name                     VARCHAR2,
      x_status_code                       VARCHAR2)
   IS
      l_ovn NUMBER := 1 ;
   BEGIN

     IF nvl(x_event_factor_old,-99) <> x_event_factor
     THEN
        cn_comp_plans_pkg.set_status(x_comp_plan_id         => NULL,
                                     x_quota_id             => x_quota_id,
                                     x_rate_schedule_id     => NULL,
                                     x_status_code          => 'INCOMPLETE',
                                     x_event                => 'CHANGE_FACTORS');
     END IF ;

      SELECT NVL(OBJECT_VERSION_NUMBER,1)
      INTO l_ovn
      FROM CN_TRX_FACTORS
      WHERE TRX_FACTOR_ID = x_trx_factor_id ;

      l_ovn := l_ovn + 1 ;

       UPDATE cn_trx_factors
          SET trx_factor_id = x_trx_factor_id,
              event_factor = x_event_factor,
              last_update_date = x_last_update_date,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              object_version_number = l_ovn
        WHERE trx_factor_id = x_trx_factor_id;

      x_object_version_number := l_ovn ;

   END UPDATE_RECORD;

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE LOCK_RECORD(
      x_rowid                             VARCHAR2,
      x_trx_factor_id                     NUMBER,
      x_event_factor                      NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type                          VARCHAR2)
   IS
   BEGIN
      NULL;
   END LOCK_RECORD;

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE DELETE_RECORD(x_trx_factor_id NUMBER, x_quota_rule_id NUMBER, x_quota_id NUMBER)
   IS
   BEGIN
      IF NVL(g_temp_status_code, 'COMPLETE') <> 'FAILED'
      THEN
         IF x_quota_rule_id IS NOT NULL
         THEN
            -- called when deleting a quota rule
            DELETE FROM cn_trx_factors
               WHERE quota_rule_id = x_quota_rule_id;
         ELSE
            -- called when deleting an entire  quota
            DELETE FROM cn_trx_factors
               WHERE quota_id = x_quota_id;
         END IF;
      END IF;
   END DELETE_RECORD;

/* -------------------------------------------------------------------------+
 |                            Public Routine Bodies                         |
  --------------------------------------------------------------------------*/

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE begin_record(
      x_operation                         VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_trx_factor_id            IN OUT NOCOPY NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER,
      x_event_factor                      NUMBER,
      x_event_factor_old                  NUMBER,
      x_revenue_class_id                  NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type                          VARCHAR2,
      x_trx_type_name                     VARCHAR2,
      x_program_type                      VARCHAR2,
      x_status_code                       VARCHAR2,
      x_org_id                            NUMBER)
   IS
   BEGIN
      g_program_type := x_program_type;
      g_temp_status_code := 'COMPLETE';

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD(x_quota_id,
                       x_quota_rule_id,
                       x_revenue_class_id);
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD(x_trx_factor_id,
                       x_event_factor,
                       x_event_factor_old,
                       x_object_version_number,
                       x_revenue_class_id,
                       x_last_update_date,
                       x_last_updated_by,
                       x_last_update_login,
                       x_quota_id,
                       x_quota_rule_id,
                       x_trx_type,
                       x_trx_type_name,
                       x_status_code);
      ELSIF x_operation = 'LOCK'
      THEN
         LOCK_RECORD(x_rowid,
                     x_trx_factor_id,
                     x_event_factor,
                     x_revenue_class_id,
                     x_quota_id,
                     x_quota_rule_id,
                     x_trx_type);
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD(x_trx_factor_id,
                       x_quota_rule_id,
                       x_quota_id);
      END IF;
   END begin_record;

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE end_record(
      x_rowid                             VARCHAR2,
      x_trx_factor_id                     NUMBER,
      x_event_factor                      NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type_name                     VARCHAR2,
      x_program_type                      VARCHAR2)
   IS
   BEGIN
      -- Saves passing it around
      g_program_type := x_program_type;
   END end_record;
END cn_trx_factors_pkg;

/
