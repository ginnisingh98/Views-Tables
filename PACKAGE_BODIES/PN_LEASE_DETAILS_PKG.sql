--------------------------------------------------------
--  DDL for Package Body PN_LEASE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LEASE_DETAILS_PKG" AS
-- $Header: PNTLSDTB.pls 120.2 2005/12/01 08:23:04 appldev ship $
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 19-MAR-02 lkatputu o Added Send_Entries into the table handler
--                      as per the 'DO NOT SEND' enhancement requirement.
-- 05-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_lease_details with _ALL table
-- 28-NOV-05  pikhar  o Fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
    x_rowid                         IN OUT NOCOPY VARCHAR2
   ,x_lease_detail_id               IN OUT NOCOPY NUMBER
   ,x_lease_change_id               IN     NUMBER
   ,x_lease_id                      IN     NUMBER
   ,x_responsible_user              IN     NUMBER
   ,x_expense_account_id            IN     NUMBER
   ,x_lease_commencement_date       IN     DATE
   ,x_lease_termination_date        IN     DATE
   ,x_lease_execution_date          IN     DATE
   ,x_creation_date                 IN     DATE
   ,x_created_by                    IN     NUMBER
   ,x_last_update_date              IN     DATE
   ,x_last_updated_by               IN     NUMBER
   ,x_last_update_login             IN     NUMBER
   ,x_accrual_account_id            IN     NUMBER
   ,x_receivable_account_id         IN     NUMBER
   ,x_term_template_id              IN     NUMBER
   ,x_grouping_rule_id              IN     NUMBER
   ,x_attribute_category            IN     VARCHAR2
   ,x_attribute1                    IN     VARCHAR2
   ,x_attribute2                    IN     VARCHAR2
   ,x_attribute3                    IN     VARCHAR2
   ,x_attribute4                    IN     VARCHAR2
   ,x_attribute5                    IN     VARCHAR2
   ,x_attribute6                    IN     VARCHAR2
   ,x_attribute7                    IN     VARCHAR2
   ,x_attribute8                    IN     VARCHAR2
   ,x_attribute9                    IN     VARCHAR2
   ,x_attribute10                   IN     VARCHAR2
   ,x_attribute11                   IN     VARCHAR2
   ,x_attribute12                   IN     VARCHAR2
   ,x_attribute13                   IN     VARCHAR2
   ,x_attribute14                   IN     VARCHAR2
   ,x_attribute15                   IN     VARCHAR2
   ,x_org_id                        IN     NUMBER
)
IS
   CURSOR c IS
      SELECT ROWID
      FROM   pn_lease_details_all
      WHERE  lease_detail_id = x_lease_detail_id;


   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all
    WHERE  lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Insert_Row (+)');

  IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
  ELSE
    l_org_id := x_org_id;
  END IF;

   INSERT INTO pn_lease_details_all
   (
       lease_detail_id
      ,lease_change_id
      ,lease_id
      ,responsible_user
      ,expense_account_id
      ,lease_commencement_date
      ,lease_termination_date
      ,lease_execution_date
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,accrual_account_id
      ,receivable_account_id
      ,term_template_id
      ,grouping_rule_id
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,org_id
   )
   VALUES
   (
       NVL(x_lease_detail_id, pn_lease_details_s.NEXTVAL)
      ,x_lease_change_id
      ,x_lease_id
      ,x_responsible_user
      ,x_expense_account_id
      ,x_lease_commencement_date
      ,x_lease_termination_date
      ,x_lease_execution_date
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_accrual_account_id
      ,x_receivable_account_id
      ,x_term_template_id
      ,x_grouping_rule_id
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
      ,l_org_id)

   RETURNING lease_detail_id INTO x_lease_detail_id;

   OPEN c;
      FETCH c INTO x_rowid;
      IF(c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Insert_Row (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 19-MAR-02  lkatputu  o Added Send_Entries into the table handler
--                        as per the 'DO NOT SEND' enhancement requirement.
-- 16-AUG-02  STripathi o Added parameters x_name, x_lease_num. Modified
--                        cursor c1 to include name, lease_num from pn_leases.
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_lease_details, pn_leases
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row (
   x_lease_detail_id               IN     NUMBER
   ,x_lease_change_id               IN     NUMBER
   ,x_lease_id                      IN     NUMBER
   ,x_responsible_user              IN     NUMBER
   ,x_expense_account_id            IN     NUMBER
   ,x_lease_commencement_date       IN     DATE
   ,x_lease_termination_date        IN     DATE
   ,x_lease_execution_date          IN     DATE
   ,x_accrual_account_id            IN     NUMBER
   ,x_receivable_account_id         IN     NUMBER
   ,x_term_template_id              IN     NUMBER
   ,x_grouping_rule_id              IN     NUMBER
   ,x_attribute_category            IN     VARCHAR2
   ,x_attribute1                    IN     VARCHAR2
   ,x_attribute2                    IN     VARCHAR2
   ,x_attribute3                    IN     VARCHAR2
   ,x_attribute4                    IN     VARCHAR2
   ,x_attribute5                    IN     VARCHAR2
   ,x_attribute6                    IN     VARCHAR2
   ,x_attribute7                    IN     VARCHAR2
   ,x_attribute8                    IN     VARCHAR2
   ,x_attribute9                    IN     VARCHAR2
   ,x_attribute10                   IN     VARCHAR2
   ,x_attribute11                   IN     VARCHAR2
   ,x_attribute12                   IN     VARCHAR2
   ,x_attribute13                   IN     VARCHAR2
   ,x_attribute14                   IN     VARCHAR2
   ,x_attribute15                   IN     VARCHAR2
   ,x_name                          IN     VARCHAR2
   ,x_lease_num                     IN     VARCHAR2
   ,x_lease_status                  IN     VARCHAR2
   ,x_lease_extension_end_date      IN     DATE
)
IS
   CURSOR c1 IS
      SELECT pld.*,
             pll.name,
             pll.lease_num,
             pll.lease_status
      FROM   pn_lease_details_all pld,
             pn_leases_all        pll
      WHERE  pld.lease_detail_id = x_lease_detail_id
      AND    pld.lease_id = pll.lease_id
      FOR UPDATE OF pld.lease_detail_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Lock_Row (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF(c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.lease_change_id = x_lease_change_id) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.lease_change_id);
   END IF;

   IF NOT (tlinfo.lease_id = x_lease_id) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.lease_id);
   END IF;

   IF NOT ((tlinfo.responsible_user = x_responsible_user)
       OR ((tlinfo.responsible_user IS NULL) AND (x_responsible_user IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RESPONSIBLE_USER',tlinfo.responsible_user);
   END IF;

   IF NOT ((tlinfo.expense_account_id = x_expense_account_id)
       OR ((tlinfo.expense_account_id IS NULL) AND (x_expense_account_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPENSE_ACCOUNT_ID',tlinfo.expense_account_id);
   END IF;

   IF NOT ((tlinfo.lease_commencement_date = x_lease_commencement_date)
       OR ((tlinfo.lease_commencement_date IS NULL) AND (x_lease_commencement_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_COMMENCEMENT_DATE',tlinfo.lease_commencement_date);
   END IF;

   IF NOT ((tlinfo.lease_termination_date = x_lease_termination_date)
       OR ((tlinfo.lease_termination_date IS NULL) AND (x_lease_termination_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_TERMINATION_DATE',tlinfo.lease_termination_date);
   END IF;

   IF NOT ((tlinfo.lease_execution_date = x_lease_execution_date)
       OR ((tlinfo.lease_execution_date IS NULL) AND (x_lease_execution_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_EXECUTION_DATE',tlinfo.lease_execution_date);
   END IF;

   IF NOT ((tlinfo.accrual_account_id = x_accrual_account_id)
       OR ((tlinfo.accrual_account_id IS NULL) AND (x_accrual_account_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACCRUAL_ACCOUNT_ID',tlinfo.accrual_account_id);
   END IF;

   IF NOT ((tlinfo.receivable_account_id = x_receivable_account_id)
       OR ((tlinfo.receivable_account_id IS NULL) AND (x_receivable_account_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECEIVABLE_ACCOUNT_ID',tlinfo.receivable_account_id);
   END IF;

   IF NOT ((tlinfo.term_template_id = x_term_template_id)
       OR ((tlinfo.term_template_id IS NULL) AND (x_term_template_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TERM_TEMPLATE_ID',tlinfo.term_template_id);
   END IF;

   IF NOT ((tlinfo.lease_extension_end_date = x_lease_extension_end_date)
       OR ((tlinfo.lease_extension_end_date IS NULL) AND (x_lease_extension_end_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_EXTENSION_END_DATE',tlinfo.lease_extension_end_date);
   END IF;

   IF NOT ((tlinfo.attribute_category = x_attribute_category)
       OR ((tlinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.attribute_category);
   END IF;

   IF NOT ((tlinfo.attribute1 = x_attribute1)
       OR ((tlinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.attribute1);
   END IF;

   IF NOT ((tlinfo.attribute2 = x_attribute2)
       OR ((tlinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.attribute2);
   END IF;

   IF NOT ((tlinfo.attribute3 = x_attribute3)
       OR ((tlinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.attribute3);
   END IF;

   IF NOT ((tlinfo.attribute4 = x_attribute4)
       OR ((tlinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.attribute4);
   END IF;

   IF NOT ((tlinfo.attribute5 = x_attribute5)
       OR ((tlinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.attribute5);
   END IF;

   IF NOT ((tlinfo.attribute6 = x_attribute6)
       OR ((tlinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.attribute6);
   END IF;

   IF NOT ((tlinfo.attribute7 = x_attribute7)
       OR ((tlinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.attribute7);
   END IF;

   IF NOT ((tlinfo.attribute8 = x_attribute8)
       OR ((tlinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.attribute8);
   END IF;

   IF NOT ((tlinfo.attribute9 = x_attribute9)
       OR ((tlinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.attribute9);
   END IF;

   IF NOT ((tlinfo.attribute10 = x_attribute10)
       OR ((tlinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.attribute10);
   END IF;

   IF NOT ((tlinfo.attribute11 = x_attribute11)
       OR ((tlinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.attribute11);
   END IF;

   IF NOT ((tlinfo.attribute12 = x_attribute12)
       OR ((tlinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.attribute12);
   END IF;

   IF NOT ((tlinfo.attribute13 = x_attribute13)
       OR ((tlinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.attribute13);
   END IF;

   IF NOT ((tlinfo.attribute14 = x_attribute14)
       OR ((tlinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.attribute14);
   END IF;

   IF NOT ((tlinfo.attribute15 = x_attribute15)
       OR ((tlinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.attribute15);
   END IF;

   IF NOT ((tlinfo.name = x_name)
       OR ((tlinfo.name IS NULL) AND (x_name IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('NAME',tlinfo.name);
   END IF;

   IF NOT ((tlinfo.lease_num = x_lease_num)
       OR ((tlinfo.lease_num IS NULL) AND (x_lease_num IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_NUM',tlinfo.lease_num);
   END IF;

   IF NOT ((tlinfo.lease_status = x_lease_status)
       OR ((tlinfo.lease_status IS NULL) AND (x_lease_status IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_STATUS',tlinfo.lease_status);
   END IF;

   IF NOT ((tlinfo.grouping_rule_id = x_grouping_rule_id)
       OR ((tlinfo.grouping_rule_id IS NULL) AND (x_grouping_rule_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('GROUPING_RULE_ID',tlinfo.grouping_rule_id);
   END IF;

   RETURN;

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Lock_Row (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 19-MAR-02  lkatputu  o Added Send_Entries into the table handler
--                        as per the 'DO NOT SEND' enhancement requirement.
-- 11-APR-02  lkatputu  o Bug Fix for the ID#2300965.
--                        Added the sEND_entries column IN the
--                        PN_LEASE_DETAILS_HISTORY update
--                        to get a before and after picture for the sEND_entries.
-- 25-SEP-02  graghuna  o Added parameter x_lease_status_old.
-- 25-OCT-02  STripathi o Removed parametes x_name_old, x_lease_num_old and
--                        x_lease_status_old. Added columns name, lease_num,
--                        lease_status in CURSOR c2.
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_lease_details, pn_leases
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
    x_lease_detail_id               IN     NUMBER
   ,x_lease_change_id               IN     NUMBER
   ,x_lease_id                      IN     NUMBER
   ,x_responsible_user              IN     NUMBER
   ,x_expense_account_id            IN     NUMBER
   ,x_lease_commencement_date       IN     DATE
   ,x_lease_termination_date        IN     DATE
   ,x_lease_execution_date          IN     DATE
   ,x_last_update_date              IN     DATE
   ,x_last_updated_by               IN     NUMBER
   ,x_last_update_login             IN     NUMBER
   ,x_accrual_account_id            IN     NUMBER
   ,x_receivable_account_id         IN     NUMBER
   ,x_term_template_id              IN     NUMBER
   ,x_grouping_rule_id              IN     NUMBER
   ,x_attribute_category            IN     VARCHAR2
   ,x_attribute1                    IN     VARCHAR2
   ,x_attribute2                    IN     VARCHAR2
   ,x_attribute3                    IN     VARCHAR2
   ,x_attribute4                    IN     VARCHAR2
   ,x_attribute5                    IN     VARCHAR2
   ,x_attribute6                    IN     VARCHAR2
   ,x_attribute7                    IN     VARCHAR2
   ,x_attribute8                    IN     VARCHAR2
   ,x_attribute9                    IN     VARCHAR2
   ,x_attribute10                   IN     VARCHAR2
   ,x_attribute11                   IN     VARCHAR2
   ,x_attribute12                   IN     VARCHAR2
   ,x_attribute13                   IN     VARCHAR2
   ,x_attribute14                   IN     VARCHAR2
   ,x_attribute15                   IN     VARCHAR2
   ,x_lease_extension_end_date      IN     DATE
)
IS
   CURSOR c2 IS
      SELECT ldt.*, pnl.name, pnl.lease_num, pnl.lease_status
      FROM   pn_lease_details_all ldt,
             pn_leases_all        pnl
      WHERE  lease_detail_id = x_lease_detail_id
      AND    ldt.lease_id = pnl.lease_id;

   recInfoForHist c2%ROWTYPE;
   l_leaseStatus                   VARCHAR2(30):= NULL;

BEGIN

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Update_Row (+)');

   -- get the lease status
   l_leaseStatus := PNP_UTIL_FUNC.get_lease_status(x_lease_id);

   -- We need to INSERT the history row IFthe lease IS finalised
   IF(l_leaseStatus = 'F')  THEN

      OPEN c2;
         FETCH c2 INTO recInfoForHist;
         IF(c2%NOTFOUND) THEN
            CLOSE c2;
            RAISE NO_DATA_FOUND;
         END IF;
      CLOSE c2;

      IF(recInfoForHist.lease_change_id <> x_lease_change_id) THEN

         INSERT INTO pn_lease_details_history
         (
            detail_history_id
           ,lease_detail_id
           ,lease_change_id
           ,new_lease_change_id
           ,lease_id
           ,responsible_user
           ,expense_account_id
           ,lease_commencement_date
           ,lease_termination_date
           ,lease_execution_date
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,name
           ,lease_num
           ,lease_status
           ,lease_extension_end_date
         )
         VALUES
         (
            pn_lease_details_history_s.NEXTVAL
           ,recInfoForHist.lease_detail_id
           ,recInfoForHist.lease_change_id
           ,x_lease_change_id
           ,recInfoForHist.lease_id
           ,recInfoForHist.responsible_user
           ,recInfoForHist.expense_account_id
           ,recInfoForHist.lease_commencement_date
           ,recInfoForHist.lease_termination_date
           ,recInfoForHist.lease_execution_date
           ,recInfoForHist.creation_date
           ,recInfoForHist.created_by
           ,recInfoForHist.last_update_date
           ,recInfoForHist.last_updated_by
           ,recInfoForHist.last_update_login
           ,recInfoForHist.attribute_category
           ,recInfoForHist.attribute1
           ,recInfoForHist.attribute2
           ,recInfoForHist.attribute3
           ,recInfoForHist.attribute4
           ,recInfoForHist.attribute5
           ,recInfoForHist.attribute6
           ,recInfoForHist.attribute7
           ,recInfoForHist.attribute8
           ,recInfoForHist.attribute9
           ,recInfoForHist.attribute10
           ,recInfoForHist.attribute11
           ,recInfoForHist.attribute12
           ,recInfoForHist.attribute13
           ,recInfoForHist.attribute14
           ,recInfoForHist.attribute15
           ,recInfoForHist.name
           ,recInfoForHist.lease_num
           ,recInfoForHist.lease_status
           ,recInfoForHist.lease_extension_end_date
         );
      END IF;
   END IF;

   UPDATE pn_lease_details_all
   SET    lease_change_id                 = x_lease_change_id
         ,responsible_user                = x_responsible_user
         ,expense_account_id              = x_expense_account_id
         ,lease_commencement_date         = x_lease_commencement_date
         ,lease_termination_date          = x_lease_termination_date
         ,lease_execution_date            = x_lease_execution_date
         ,last_update_date                = x_last_update_date
         ,last_updated_by                 = x_last_updated_by
         ,last_update_login               = x_last_update_login
         ,accrual_account_id              = x_accrual_account_id
         ,receivable_account_id           = x_receivable_account_id
         ,term_template_id                = x_term_template_id
         ,grouping_rule_id                = x_grouping_rule_id
         ,lease_extension_end_date        = x_lease_extension_end_date
         ,attribute_category              = x_attribute_category
         ,attribute1                      = x_attribute1
         ,attribute2                      = x_attribute2
         ,attribute3                      = x_attribute3
         ,attribute4                      = x_attribute4
         ,attribute5                      = x_attribute5
         ,attribute6                      = x_attribute6
         ,attribute7                      = x_attribute7
         ,attribute8                      = x_attribute8
         ,attribute9                      = x_attribute9
         ,attribute10                     = x_attribute10
         ,attribute11                     = x_attribute11
         ,attribute12                     = x_attribute12
         ,attribute13                     = x_attribute13
         ,attribute14                     = x_attribute14
         ,attribute15                     = x_attribute15
   WHERE  lease_detail_id                 = x_lease_detail_id;

   IF(SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Update_Row (-)');

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_lease_details with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   x_lease_detail_id               IN     NUMBER
)
IS
BEGIN

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Delete_Row (+)');

   DELETE FROM pn_lease_details_all
   WHERE lease_detail_id = x_lease_detail_id;

   IF(SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug('PN_LEASE_DETAILS_PKG.Delete_Row (-)');

END Delete_Row;

END pn_lease_details_pkg;

/
