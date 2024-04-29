--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: cnpliqrs.pls 120.1 2005/07/11 19:59:25 appldev ship $ */

   /*
   Date      Name          Description
   ----------------------------------------------------------------------------+
   15-FEB-95 P Cook  Unit tested

   Name

   Purpose

   Notes

   */

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
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
   );

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
   PROCEDURE end_record (
      x_rowid                             VARCHAR2,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_target                            NUMBER,
      x_payment_amount                    NUMBER,
      x_performance_goal                  NUMBER,
      x_quota_rule_id                     NUMBER,
      x_program_type                      VARCHAR2
   );

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
   PROCEDURE get_rev_class_name (
      x_revenue_class_id                  NUMBER,
      x_revenue_class_name       IN OUT NOCOPY VARCHAR2
   );

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
   PROCEDURE DELETE_RECORD (
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_revenue_class_id                  NUMBER
   );

   FUNCTION check_rev_class_hier (
      x_revenue_class_id                  NUMBER,
      x_revenue_class_id_old              NUMBER,
      x_quota_id                          NUMBER,
      x_start_period_id                   NUMBER,
      x_end_period_id                     NUMBER
   )
      RETURN BOOLEAN;
END cn_quota_rules_pkg;
 

/
