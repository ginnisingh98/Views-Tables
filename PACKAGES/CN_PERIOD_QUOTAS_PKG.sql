--------------------------------------------------------
--  DDL for Package CN_PERIOD_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PERIOD_QUOTAS_PKG" AUTHID CURRENT_USER AS
/* $Header: cnprdqos.pls 120.2 2005/07/20 19:08:18 fmburu ship $ */

   /*
   Date      Name          Description
   ----------------------------------------------------------------------------+
   20-JUL-99 S Kumar       Modified with the new design
   Name

   Purpose

   Notes

   */
   PROCEDURE begin_record (
      x_operation                         VARCHAR2,
      x_period_quota_id          IN OUT NOCOPY NUMBER,
      x_period_id                         NUMBER,
      x_quota_id                          NUMBER,
      x_period_target                     NUMBER,
      x_itd_target                        NUMBER,
      x_period_payment                    NUMBER,
      x_itd_payment                       NUMBER,
      x_quarter_num                       NUMBER,
      x_period_year                       NUMBER,
      x_creation_date                     DATE,
      x_last_update_date                  DATE,
      x_last_update_login                 NUMBER,
      x_last_updated_by                   NUMBER,
      x_created_by                        NUMBER,
      x_period_type_code                  VARCHAR2,
      x_performance_goal                  NUMBER
   );

   PROCEDURE INSERT_RECORD (
      x_quota_id                          NUMBER
   );

   PROCEDURE INSERT_RECORD (
      x_period_quota_id          IN OUT NOCOPY NUMBER,
      p_period_id                         NUMBER,
      p_quota_id                          NUMBER,
      p_period_target                     NUMBER,
      p_itd_target                        NUMBER,
      p_period_payment                    NUMBER,
      p_itd_payment                       NUMBER,
      p_quarter_num                       NUMBER,
      p_period_year                       NUMBER,
      p_creation_date                     DATE,
      p_last_update_date                  DATE,
      p_last_update_login                 NUMBER,
      p_last_updated_by                   NUMBER,
      p_created_by                        NUMBER,
      p_period_type_code                  VARCHAR2,
      p_performance_goal                  NUMBER
   );

   PROCEDURE UPDATE_RECORD (
      p_period_quota_id                   NUMBER,
      p_quota_id                          NUMBER,
      p_period_id                         NUMBER,
      p_period_target                     NUMBER,
      p_period_payment                    NUMBER,
      p_performance_goal                  NUMBER,
      p_last_update_date                  DATE,
      p_last_update_login                 NUMBER,
      p_last_updated_by                   NUMBER,
      x_itd_target            OUT NOCOPY  NUMBER,
      x_itd_payment_amount    OUT NOCOPY  NUMBER,
      x_itd_performance_amount OUT NOCOPY  NUMBER,
      x_object_version_number OUT NOCOPY  NUMBER
   );

   PROCEDURE DELETE_RECORD (
      x_quota_id                          NUMBER
   );

   PROCEDURE distribute_target (
      x_quota_id                          NUMBER
   );

   PROCEDURE sync_itd_values (
      x_quota_id                          NUMBER
   );

   PROCEDURE populate_itd_values (
      x_start_period_quota_id             NUMBER,
      x_quota_id                          NUMBER
   );

   FUNCTION previous_period (
      p_start_date                        DATE,
      p_org_id                            NUMBER
   )
      RETURN cn_acc_period_statuses_v.start_date%TYPE;
END cn_period_quotas_pkg;
 

/
