--------------------------------------------------------
--  DDL for Package CN_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTAS_PKG" AUTHID CURRENT_USER AS
/* $Header: cnpliqos.pls 120.1.12000000.3 2007/10/09 20:17:54 rnagired ship $ */
     --
     --+
     -- Purpose
     --+
     -- Notes
     -- Called  for Insert/Update/delete
     --+
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
      --x_status_code   varchar2 ,
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
      --clku payment enhancement
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
      x_salesrep_end_flag                 VARCHAR2
   );

   --  temp use
   PROCEDURE UPDATE_RECORD (
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE
   );

   --  Must be public as called by cn_comp_plans_pkg
   PROCEDURE DELETE_RECORD (
      x_quota_id                          NUMBER,
      x_name                              VARCHAR2
   );


END cn_quotas_pkg;
 

/
