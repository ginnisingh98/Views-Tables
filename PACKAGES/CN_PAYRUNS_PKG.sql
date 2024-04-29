--------------------------------------------------------
--  DDL for Package CN_PAYRUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYRUNS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnprunts.pls 120.3 2005/09/22 13:00:01 rnagired ship $
   PROCEDURE INSERT_RECORD (
      x_payrun_id               IN   NUMBER,
      x_name                         cn_payruns.NAME%TYPE,
      x_pay_period_id                cn_payruns.pay_period_id%TYPE,
      x_incentive_type_code          cn_payruns.incentive_type_code%TYPE,
      x_pay_group_id                 cn_payruns.pay_group_id%TYPE,
      x_pay_date                     cn_payruns.pay_date%TYPE,
      x_accounting_period_id         cn_payruns.accounting_period_id%TYPE,
      x_batch_id                     cn_payruns.batch_id%TYPE,
      x_status                       cn_payruns.status%TYPE,
      x_created_by                   cn_payruns.created_by%TYPE,
      x_creation_date                cn_payruns.creation_date%TYPE,
      x_object_version_number        cn_payruns.object_version_number%TYPE,
      x_org_id                       cn_payruns.org_id%TYPE,
	x_payrun_mode                  cn_payruns.payrun_mode%TYPE
   );

   PROCEDURE LOCK_RECORD (x_rowid VARCHAR2, x_payrun_id NUMBER);

   PROCEDURE UPDATE_RECORD (
      x_payrun_id               cn_payruns.payrun_id%TYPE,
      x_name                    cn_payruns.NAME%TYPE := fnd_api.g_miss_char,
      x_pay_period_id           cn_payruns.pay_period_id%TYPE
            := cn_api.g_miss_id,
      x_incentive_type_code     cn_payruns.incentive_type_code%TYPE
            := cn_api.g_miss_char,
      x_pay_group_id            cn_payruns.pay_group_id%TYPE
            := cn_api.g_miss_id,
      x_pay_date                cn_payruns.pay_date%TYPE
            := fnd_api.g_miss_date,
      x_accounting_period_id    cn_payruns.accounting_period_id%TYPE
            := cn_api.g_miss_id,
      x_batch_id                cn_payruns.batch_id%TYPE := cn_api.g_miss_id,
      x_status                  cn_payruns.status%TYPE := fnd_api.g_miss_char,
      x_last_updated_by         cn_payruns.last_updated_by%TYPE,
      x_last_update_date        cn_payruns.last_update_date%TYPE,
      x_last_update_login       cn_payruns.last_update_login%TYPE,
      x_object_version_number   cn_payruns.object_version_number%TYPE
   );

   PROCEDURE DELETE_RECORD (x_payrun_id NUMBER);
END cn_payruns_pkg;
 

/
