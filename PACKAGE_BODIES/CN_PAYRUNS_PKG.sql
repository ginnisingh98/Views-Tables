--------------------------------------------------------
--  DDL for Package Body CN_PAYRUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYRUNS_PKG" AS
-- $Header: cnpruntb.pls 120.3 2005/09/22 13:01:26 rnagired ship $

   -- ===========================================================================
-- Procedure Name : Insert_Record
-- Purpose        : Main insert procedure
-- ===========================================================================
   PROCEDURE INSERT_RECORD (
      x_payrun_id                IN       NUMBER,
      x_name                              cn_payruns.NAME%TYPE,
      x_pay_period_id                     cn_payruns.pay_period_id%TYPE,
      x_incentive_type_code               cn_payruns.incentive_type_code%TYPE,
      x_pay_group_id                      cn_payruns.pay_group_id%TYPE,
      x_pay_date                          cn_payruns.pay_date%TYPE,
      x_accounting_period_id              cn_payruns.accounting_period_id%TYPE,
      x_batch_id                          cn_payruns.batch_id%TYPE,
      x_status                            cn_payruns.status%TYPE,
      x_created_by                        cn_payruns.created_by%TYPE,
      x_creation_date                     cn_payruns.creation_date%TYPE,
      x_object_version_number             cn_payruns.object_version_number%TYPE,
      x_org_id                            cn_payruns.org_id%TYPE,
	x_payrun_mode                  	cn_payruns.payrun_mode%TYPE
   )
   IS
   BEGIN
      INSERT INTO cn_payruns
                  (payrun_id,
                   NAME,
                   pay_period_id,
                   incentive_type_code,
                   pay_group_id,
                   pay_date,
                   accounting_period_id,
                   batch_id,
                   status,
                   created_by,
                   creation_date,
                   object_version_number,
                   org_id,
			 payrun_mode

                  )
           VALUES (NVL (x_payrun_id, cn_payruns_s.NEXTVAL),
                   x_name,
                   x_pay_period_id,
                   x_incentive_type_code,
                   x_pay_group_id,
                   x_pay_date,
                   x_accounting_period_id,
                   x_batch_id,
                   x_status,
                   x_created_by,
                   x_creation_date,
                   x_object_version_number,
                   x_org_id,
			 x_payrun_mode
                  );
   END INSERT_RECORD;

-- ===========================================================================
-- Procedure Name : Lock_Record
-- Purpose        : Lock db row after form record is changed
-- Notes          : Only called from the form
-- ===========================================================================
   PROCEDURE LOCK_RECORD (
      x_rowid                             VARCHAR2,
      x_payrun_id                         NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_payruns
                 WHERE payrun_id = x_payrun_id
         FOR UPDATE OF payrun_id NOWAIT;

      recinfo                       c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF recinfo.payrun_id = x_payrun_id
      THEN
         RETURN;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END LOCK_RECORD;

-- ===========================================================================
-- Procedure Name : Update Record
-- Purpose        : To Update the Payment Plans
-- ===========================================================================
   PROCEDURE UPDATE_RECORD (
      x_payrun_id                         cn_payruns.payrun_id%TYPE,
      x_name                              cn_payruns.NAME%TYPE := fnd_api.g_miss_char,
      x_pay_period_id                     cn_payruns.pay_period_id%TYPE := cn_api.g_miss_id,
      x_incentive_type_code               cn_payruns.incentive_type_code%TYPE := cn_api.g_miss_char,
      x_pay_group_id                      cn_payruns.pay_group_id%TYPE := cn_api.g_miss_id,
      x_pay_date                          cn_payruns.pay_date%TYPE := fnd_api.g_miss_date,
      x_accounting_period_id              cn_payruns.accounting_period_id%TYPE := cn_api.g_miss_id,
      x_batch_id                          cn_payruns.batch_id%TYPE := cn_api.g_miss_id,
      x_status                            cn_payruns.status%TYPE := fnd_api.g_miss_char,
      x_last_updated_by                   cn_payruns.last_updated_by%TYPE,
      x_last_update_date                  cn_payruns.last_update_date%TYPE,
      x_last_update_login                 cn_payruns.last_update_login%TYPE,
      x_object_version_number             cn_payruns.object_version_number%TYPE
   )
   IS
      l_name                        cn_payruns.NAME%TYPE;
      l_pay_period_id               cn_payruns.pay_period_id%TYPE;
      l_incentive_type_code         cn_payruns.incentive_type_code%TYPE;
      l_pay_group_id                cn_payruns.pay_group_id%TYPE;
      l_pay_date                    cn_payruns.pay_date%TYPE;
      l_accounting_period_id        cn_payruns.accounting_period_id%TYPE;
      l_batch_id                    cn_payruns.batch_id%TYPE;
      l_status                      cn_payruns.status%TYPE;

      CURSOR payrun_cur
      IS
         SELECT *
           FROM cn_payruns
          WHERE payrun_id = x_payrun_id;

      l_payrun_rec                  payrun_cur%ROWTYPE;
   BEGIN
      OPEN payrun_cur;

      FETCH payrun_cur
       INTO l_payrun_rec;

      CLOSE payrun_cur;

      SELECT DECODE (x_name, fnd_api.g_miss_char, l_payrun_rec.NAME, x_name),
             DECODE (x_pay_period_id, cn_api.g_miss_id, l_payrun_rec.pay_period_id, x_pay_period_id),
             DECODE (x_incentive_type_code, cn_api.g_miss_char, l_payrun_rec.incentive_type_code, x_incentive_type_code),
             DECODE (x_pay_group_id, cn_api.g_miss_id, l_payrun_rec.pay_group_id, x_pay_group_id),
             DECODE (x_pay_date, fnd_api.g_miss_date, l_payrun_rec.pay_date, x_pay_date),
             DECODE (x_accounting_period_id, cn_api.g_miss_id, l_payrun_rec.accounting_period_id, x_accounting_period_id),
             DECODE (x_batch_id, cn_api.g_miss_id, l_payrun_rec.batch_id, x_batch_id),
             DECODE (x_status, fnd_api.g_miss_char, l_payrun_rec.status, x_status)
        INTO l_name,
             l_pay_period_id,
             l_incentive_type_code,
             l_pay_group_id,
             l_pay_date,
             l_accounting_period_id,
             l_batch_id,
             l_status
        FROM DUAL;

      UPDATE cn_payruns
         SET NAME = l_name,
             pay_period_id = l_pay_period_id,
             incentive_type_code = l_incentive_type_code,
             pay_group_id = l_pay_group_id,
             pay_date = l_pay_date,
             accounting_period_id = l_accounting_period_id,
             batch_id = l_batch_id,
             status = l_status,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             object_version_number = x_object_version_number + 1
       WHERE payrun_id = x_payrun_id AND object_version_number = x_object_version_number;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END UPDATE_RECORD;

-- ===========================================================================
-- Procedure Name : Delete_Record
-- Purpose        : Delete the Payment Plan if it has not been assigned
--                  to a salesrep
-- ===========================================================================
   PROCEDURE DELETE_RECORD (
      x_payrun_id                         NUMBER
   )
   IS
   BEGIN
      DELETE FROM cn_payruns
            WHERE payrun_id = x_payrun_id;
   END DELETE_RECORD;
END cn_payruns_pkg;

/
