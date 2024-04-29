--------------------------------------------------------
--  DDL for Package Body PN_LEASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LEASES_PKG" AS
-- $Header: PNTLEASB.pls 120.2.12010000.3 2010/02/18 08:11:41 vgovvala ship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 19-MAR-02 lkatputu o Added Send_Entries into the table handler
--                       as per the 'DO NOT SEND' enhancement requirement.
-- 05-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_leases with
--                      _ALL table.
-- 01-DEC-05 kiran    o passed org_id in pn_leases_pkg.check_unique_lease_number
-------------------------------------------------------------------------------
PROCEDURE Insert_Row
(
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_LEASE_ID                      IN OUT NOCOPY NUMBER,
   X_LEASE_CHANGE_ID               IN OUT NOCOPY NUMBER,
   X_LEASE_DETAIL_ID               IN OUT NOCOPY NUMBER,
   X_NAME                          IN     VARCHAR2,
   X_LEASE_NUM                     IN OUT NOCOPY VARCHAR2,
   X_PARENT_LEASE_ID               IN     NUMBER,
   X_LEASE_TYPE_CODE               IN     VARCHAR2,
   X_LEASE_CLASS_CODE              IN     VARCHAR2,
   X_PAYMENT_TERM_PRORATION_RULE   IN     NUMBER,
   X_ABSTRACTED_BY_USER            IN     NUMBER,
   X_STATUS                        IN     VARCHAR2,
   X_LEASE_STATUS                  IN     VARCHAR2,
   X_CREATION_DATE                 IN     DATE,
   X_CREATED_BY                    IN     NUMBER,
   X_LAST_UPDATE_DATE              IN     DATE,
   X_LAST_UPDATED_BY               IN     NUMBER,
   X_LAST_UPDATE_LOGIN             IN     NUMBER,
   X_RESPONSIBLE_USER              IN     NUMBER,
   X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
   X_ACCRUAL_ACCOUNT_ID            IN     NUMBER,
   X_RECEIVABLE_ACCOUNT_ID         IN     NUMBER,
   X_TERM_TEMPLATE_ID              IN     NUMBER ,
   X_LEASE_COMMENCEMENT_DATE       IN     DATE,
   X_LEASE_TERMINATION_DATE        IN     DATE,
   X_LEASE_EXECUTION_DATE          IN     DATE,
   X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
   X_ATTRIBUTE1                    IN     VARCHAR2,
   X_ATTRIBUTE2                    IN     VARCHAR2,
   X_ATTRIBUTE3                    IN     VARCHAR2,
   X_ATTRIBUTE4                    IN     VARCHAR2,
   X_ATTRIBUTE5                    IN     VARCHAR2,
   X_ATTRIBUTE6                    IN     VARCHAR2,
   X_ATTRIBUTE7                    IN     VARCHAR2,
   X_ATTRIBUTE8                    IN     VARCHAR2,
   X_ATTRIBUTE9                    IN     VARCHAR2,
   X_ATTRIBUTE10                   IN     VARCHAR2,
   X_ATTRIBUTE11                   IN     VARCHAR2,
   X_ATTRIBUTE12                   IN     VARCHAR2,
   X_ATTRIBUTE13                   IN     VARCHAR2,
   X_ATTRIBUTE14                   IN     VARCHAR2,
   X_ATTRIBUTE15                   IN     VARCHAR2,
   x_org_id                        IN     NUMBER,
   x_location_id                   IN     NUMBER,
   x_customer_id                   IN     NUMBER,
   x_grouping_rule_id              IN     NUMBER,
   x_calendar_year_start_date      IN     VARCHAR2
)
IS

   CURSOR c IS
      SELECT ROWID
      FROM   pn_leases_all
      WHERE  lease_id = x_lease_id;

   l_return_status                 VARCHAR2(30) := NULL;
   l_rowId                         VARCHAR2(18) := NULL;
   l_leaseDetailId                 NUMBER       := NULL;
   l_leaseChangeNumber             NUMBER       := NULL;

BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.Insert_Row (+)');

   -- Check IF lease NUMBER IS unique
   l_return_status                := NULL;
   pn_leases_pkg.check_unique_lease_number(l_return_status,
                                           x_lease_id,
                                           x_lease_num,
                                           x_org_id);

   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   INSERT INTO pn_leases_all
   (
      LEASE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      NAME,
      LEASE_NUM,
      PARENT_LEASE_ID,
      LEASE_TYPE_CODE,
      LEASE_CLASS_CODE,
      PAYMENT_TERM_PRORATION_RULE,
      ABSTRACTED_BY_USER,
      STATUS,
      LEASE_STATUS,
      org_id,
      location_id,
      customer_id,
      cal_start
   )
   VALUES
   (
      NVL(X_LEASE_ID,pn_leases_s.NEXTVAL),
      sysdate,
      X_LAST_UPDATED_BY,
      sysdate,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_NAME,
      NVL(X_LEASE_NUM,pn_leases_s.CURRVAL),
      X_PARENT_LEASE_ID,
      X_LEASE_TYPE_CODE,
      X_LEASE_CLASS_CODE,
      X_PAYMENT_TERM_PRORATION_RULE,
      X_ABSTRACTED_BY_USER,
      X_STATUS,
      X_LEASE_STATUS,
      x_org_id,
      x_location_id,
      x_customer_id,
      x_calendar_year_start_date
   )
   RETURNING lease_id, lease_num INTO x_lease_id, x_lease_num;

   OPEN c;
      FETCH C INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   ------------------------------------------------------
   -- We need to insert a record in PN_LEASE_CHANGES
   ------------------------------------------------------
   l_rowId                := NULL;
   pn_lease_changes_pkg.Insert_Row
   (
       X_ROWID                         => l_rowId
      ,X_LEASE_CHANGE_ID               => X_LEASE_CHANGE_ID
      ,X_LEASE_ID                      => X_LEASE_ID
      ,X_LEASE_CHANGE_NUMBER           => l_leaseChangeNumber
      ,X_LEASE_CHANGE_NAME             => NULL
      ,X_RESPONSIBLE_USER              => NULL
      ,X_CHANGE_COMMENCEMENT_DATE      => NULL
      ,X_CHANGE_TERMINATION_DATE       => NULL
      ,X_CHANGE_TYPE_LOOKUP_CODE       => 'ABSTRACT'
      ,X_CHANGE_EXECUTION_DATE         => NULL
      ,X_ATTRIBUTE_CATEGORY            => NULL
      ,X_ATTRIBUTE1                    => NULL
      ,X_ATTRIBUTE2                    => NULL
      ,X_ATTRIBUTE3                    => NULL
      ,X_ATTRIBUTE4                    => NULL
      ,X_ATTRIBUTE5                    => NULL
      ,X_ATTRIBUTE6                    => NULL
      ,X_ATTRIBUTE7                    => NULL
      ,X_ATTRIBUTE8                    => NULL
      ,X_ATTRIBUTE9                    => NULL
      ,X_ATTRIBUTE10                   => NULL
      ,X_ATTRIBUTE11                   => NULL
      ,X_ATTRIBUTE12                   => NULL
      ,X_ATTRIBUTE13                   => NULL
      ,X_ATTRIBUTE14                   => NULL
      ,X_ATTRIBUTE15                   => NULL
      ,X_ABSTRACTED_BY_USER            => NULL
      ,X_CREATION_DATE                 => sysdate
      ,X_CREATED_BY                    => X_CREATED_BY
      ,X_LAST_UPDATE_DATE              => sysdate
      ,X_LAST_UPDATED_BY               => X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN             => X_LAST_UPDATE_LOGIN
      ,x_org_id                        => x_org_id
   );

   ------------------------------------------------------
   -- We need to insert a record in PN_LEASE_DETAILS
   ------------------------------------------------------
   l_rowId                := NULL;
   pn_lease_details_pkg.Insert_Row
   (
       X_ROWID                         => l_rowId
      ,X_LEASE_DETAIL_ID               => X_LEASE_DETAIL_ID
      ,X_LEASE_CHANGE_ID               => X_LEASE_CHANGE_ID
      ,X_LEASE_ID                      => X_LEASE_ID
      ,X_RESPONSIBLE_USER              => X_RESPONSIBLE_USER
      ,X_EXPENSE_ACCOUNT_ID            => X_EXPENSE_ACCOUNT_ID
      ,X_LEASE_COMMENCEMENT_DATE       => X_LEASE_COMMENCEMENT_DATE
      ,X_LEASE_TERMINATION_DATE        => X_LEASE_TERMINATION_DATE
      ,X_LEASE_EXECUTION_DATE          => X_LEASE_EXECUTION_DATE
      ,X_CREATION_DATE                 => sysdate
      ,X_CREATED_BY                    => X_CREATED_BY
      ,X_LAST_UPDATE_DATE              => sysdate
      ,X_LAST_UPDATED_BY               => X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN             => X_LAST_UPDATE_LOGIN
      ,X_ACCRUAL_ACCOUNT_ID            => X_ACCRUAL_ACCOUNT_ID
      ,X_RECEIVABLE_ACCOUNT_ID         => X_RECEIVABLE_ACCOUNT_ID
      ,X_TERM_TEMPLATE_ID              => X_TERM_TEMPLATE_ID
      ,X_GROUPING_RULE_ID              => X_GROUPING_RULE_ID
      ,X_ATTRIBUTE_CATEGORY            => X_ATTRIBUTE_CATEGORY
      ,x_ATTRIBUTE1                    => x_ATTRIBUTE1
      ,x_ATTRIBUTE2                    => x_ATTRIBUTE2
      ,x_ATTRIBUTE3                    => x_ATTRIBUTE3
      ,x_ATTRIBUTE4                    => x_ATTRIBUTE4
      ,x_ATTRIBUTE5                    => x_ATTRIBUTE5
      ,x_ATTRIBUTE6                    => x_ATTRIBUTE6
      ,x_ATTRIBUTE7                    => x_ATTRIBUTE7
      ,x_ATTRIBUTE8                    => x_ATTRIBUTE8
      ,x_ATTRIBUTE9                    => x_ATTRIBUTE9
      ,x_ATTRIBUTE10                   => x_ATTRIBUTE10
      ,x_ATTRIBUTE11                   => x_ATTRIBUTE11
      ,x_ATTRIBUTE12                   => x_ATTRIBUTE12
      ,x_ATTRIBUTE13                   => x_ATTRIBUTE13
      ,x_ATTRIBUTE14                   => x_ATTRIBUTE14
      ,x_ATTRIBUTE15                   => x_ATTRIBUTE15
      ,x_org_id                        => x_org_id
   );

   pnp_debug_pkg.debug ('PN_LEASES_PKG.Insert_Row (-)');

END Insert_Row;


-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 19-MAR-02  lkatputu o Added Send_Entries into the table handler
--                       as per the 'DO NOT SEND' enhancement requirement.
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_leases with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_DETAIL_ID               IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_NAME                          IN     VARCHAR2,
   X_LEASE_NUM                     IN     VARCHAR2,
   X_PARENT_LEASE_ID               IN     NUMBER,
   X_LEASE_TYPE_CODE               IN     VARCHAR2,
   X_LEASE_CLASS_CODE              IN     VARCHAR2,
   X_PAYMENT_TERM_PRORATION_RULE   IN     NUMBER,
   X_ABSTRACTED_BY_USER            IN     NUMBER,
   X_STATUS                        IN     VARCHAR2,
   X_LEASE_STATUS                  IN     VARCHAR2,
   X_RESPONSIBLE_USER              IN     NUMBER,
   X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
   X_ACCRUAL_ACCOUNT_ID            IN     NUMBER,
   X_RECEIVABLE_ACCOUNT_ID         IN     NUMBER,
   X_TERM_TEMPLATE_ID              IN     NUMBER,
   X_LEASE_COMMENCEMENT_DATE       IN     DATE,
   X_LEASE_TERMINATION_DATE        IN     DATE,
   X_LEASE_EXECUTION_DATE          IN     DATE,
   X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
   X_ATTRIBUTE1                    IN     VARCHAR2,
   X_ATTRIBUTE2                    IN     VARCHAR2,
   X_ATTRIBUTE3                    IN     VARCHAR2,
   X_ATTRIBUTE4                    IN     VARCHAR2,
   X_ATTRIBUTE5                    IN     VARCHAR2,
   X_ATTRIBUTE6                    IN     VARCHAR2,
   X_ATTRIBUTE7                    IN     VARCHAR2,
   X_ATTRIBUTE8                    IN     VARCHAR2,
   X_ATTRIBUTE9                    IN     VARCHAR2,
   X_ATTRIBUTE10                   IN     VARCHAR2,
   X_ATTRIBUTE11                   IN     VARCHAR2,
   X_ATTRIBUTE12                   IN     VARCHAR2,
   X_ATTRIBUTE13                   IN     VARCHAR2,
   X_ATTRIBUTE14                   IN     VARCHAR2,
   X_ATTRIBUTE15                   IN     VARCHAR2,
   x_location_id                   IN     NUMBER,
   x_customer_id                   IN     NUMBER,
   x_grouping_rule_id              IN     NUMBER,
   x_calendar_year_start_date      IN     VARCHAR2
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_leases_all                                              --sdm_MOAC
      WHERE  lease_id = x_lease_id
      FOR UPDATE OF lease_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.Lock_Row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.NAME = X_NAME) THEN
      pn_var_rent_pkg.lock_row_exception('NAME',tlinfo.NAME);
   END IF;

   IF NOT (tlinfo.LEASE_NUM = X_LEASE_NUM) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_NUM',tlinfo.LEASE_NUM);
   END IF;

   IF NOT ((tlinfo.PARENT_LEASE_ID = X_PARENT_LEASE_ID)
       OR ((tlinfo.PARENT_LEASE_ID IS NULL) AND (X_PARENT_LEASE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PARENT_LEASE_ID',tlinfo.PARENT_LEASE_ID);
   END IF;

   IF NOT ((tlinfo.LEASE_TYPE_CODE = X_LEASE_TYPE_CODE)
       OR ((tlinfo.LEASE_TYPE_CODE IS NULL) AND (X_LEASE_TYPE_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_TYPE_CODE',tlinfo.LEASE_TYPE_CODE);
   END IF;

   IF NOT ((tlinfo.LEASE_CLASS_CODE = X_LEASE_CLASS_CODE)
       OR ((tlinfo.LEASE_CLASS_CODE IS NULL) AND (X_LEASE_CLASS_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CLASS_CODE',tlinfo.LEASE_CLASS_CODE);
   END IF;

   IF NOT ((tlinfo.LEASE_STATUS = X_LEASE_STATUS)
       OR ((tlinfo.LEASE_STATUS IS NULL) AND (X_LEASE_STATUS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_STATUS',tlinfo.LEASE_STATUS);
   END IF;

   IF NOT ((tlinfo.STATUS = X_STATUS)
       OR ((tlinfo.STATUS IS NULL) AND (X_STATUS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('STATUS',tlinfo.STATUS);
   END IF;

   IF NOT ((tlinfo.PAYMENT_TERM_PRORATION_RULE = X_PAYMENT_TERM_PRORATION_RULE)
       OR ((tlinfo.PAYMENT_TERM_PRORATION_RULE IS NULL) AND
           (X_PAYMENT_TERM_PRORATION_RULE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_PRORATION_RULE',tlinfo.PAYMENT_TERM_PRORATION_RULE);
   END IF;

   IF NOT ((tlinfo.ABSTRACTED_BY_USER = X_ABSTRACTED_BY_USER)
       OR ((tlinfo.ABSTRACTED_BY_USER IS NULL) AND (X_ABSTRACTED_BY_USER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ABSTRACTED_BY_USER',tlinfo.ABSTRACTED_BY_USER);
   END IF;

   IF NOT ((tlinfo.location_id = x_location_id)
       OR ((tlinfo.location_id IS NULL) AND (x_location_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.location_id);
   END IF;

   IF NOT ((tlinfo.customer_id = x_customer_id)
       OR ((tlinfo.customer_id IS NULL) AND (x_customer_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_ID',tlinfo.customer_id);
   END IF;

    IF NOT ((tlinfo.cal_start = x_calendar_year_start_date)
       OR ((tlinfo.cal_start IS NULL) AND (x_calendar_year_start_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CALENDAR_YEAR_START_DATE',tlinfo.cal_start);
   END IF;

   ------------------------------------------------------
   -- We need to lock records in pn_lease_details
   ------------------------------------------------------

   pn_lease_details_pkg.Lock_Row
   (
       X_LEASE_DETAIL_ID               =>X_LEASE_DETAIL_ID
      ,X_LEASE_CHANGE_ID               =>X_LEASE_CHANGE_ID
      ,X_LEASE_ID                      =>X_LEASE_ID
      ,X_RESPONSIBLE_USER              =>X_RESPONSIBLE_USER
      ,X_EXPENSE_ACCOUNT_ID            =>X_EXPENSE_ACCOUNT_ID
      ,X_LEASE_COMMENCEMENT_DATE       =>X_LEASE_COMMENCEMENT_DATE
      ,X_LEASE_TERMINATION_DATE        =>X_LEASE_TERMINATION_DATE
      ,X_LEASE_EXECUTION_DATE          =>X_LEASE_EXECUTION_DATE
      ,X_ACCRUAL_ACCOUNT_ID            =>X_ACCRUAL_ACCOUNT_ID
      ,X_RECEIVABLE_ACCOUNT_ID         =>X_RECEIVABLE_ACCOUNT_ID
      ,X_TERM_TEMPLATE_ID              =>X_TERM_TEMPLATE_ID
      ,X_GROUPING_RULE_ID              =>X_GROUPING_RULE_ID
      ,X_ATTRIBUTE_CATEGORY            =>X_ATTRIBUTE_CATEGORY
      ,x_ATTRIBUTE1                    =>X_ATTRIBUTE1
      ,x_ATTRIBUTE2                    =>X_ATTRIBUTE2
      ,x_ATTRIBUTE3                    =>X_ATTRIBUTE3
      ,x_ATTRIBUTE4                    =>X_ATTRIBUTE4
      ,x_ATTRIBUTE5                    =>X_ATTRIBUTE5
      ,x_ATTRIBUTE6                    =>X_ATTRIBUTE6
      ,x_ATTRIBUTE7                    =>X_ATTRIBUTE7
      ,x_ATTRIBUTE8                    =>X_ATTRIBUTE8
      ,x_ATTRIBUTE9                    =>X_ATTRIBUTE9
      ,x_ATTRIBUTE10                   =>X_ATTRIBUTE10
      ,x_ATTRIBUTE11                   =>X_ATTRIBUTE11
      ,x_ATTRIBUTE12                   =>X_ATTRIBUTE12
      ,x_ATTRIBUTE13                   =>X_ATTRIBUTE13
      ,x_ATTRIBUTE14                   =>X_ATTRIBUTE14
      ,x_ATTRIBUTE15                   =>X_ATTRIBUTE15
   );

   -- NOTE: We will not check for the lease PN_LEASE_CHANGES table

   pnp_debug_pkg.debug ('PN_LEASES_PKG.Lock_Row (-)');

END Lock_Row;


-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 19-MAR-02  lkatputu o Added Send_Entries into the table handler
--                       as per the 'DO NOT SEND' enhancement requirement.
-- 25-OCT-02  STRIPATH o Modified Update_Row for Lease Number/Name and MTM.
--                       Now first call pn_lease_details_pkg.Update_row and then
--                       Update pn_leases_all, for history creation of 3 columns
--                       of pn_leases_all (name, lease_num, lease_status) in
--                       table pn_lease_details_history.
-- 02-FEB-05  VIVESHAR o Added lease extension end date as input parameter in
--                       pn_leases_pkg.Update_row and pn_lease_details_pkg.
--                       Update_Row. Fix for bug# 4142423
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_leases with
--                       _ALL table.
-- 01-DEC-05  kiran    o passed org_id in pn_leases_pkg.check_unique_lease_number
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_DETAIL_ID               IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_NAME                          IN     VARCHAR2,
   X_LEASE_NUM                     IN     VARCHAR2,
   X_PARENT_LEASE_ID               IN     NUMBER,
   X_LEASE_TYPE_CODE               IN     VARCHAR2,
   X_LEASE_CLASS_CODE              IN     VARCHAR2,
   X_PAYMENT_TERM_PRORATION_RULE   IN     NUMBER,
   X_ABSTRACTED_BY_USER            IN     NUMBER,
   X_STATUS                        IN     VARCHAR2,
   X_LEASE_STATUS                  IN     VARCHAR2,
   X_LAST_UPDATE_DATE              IN     DATE,
   X_LAST_UPDATED_BY               IN     NUMBER,
   X_LAST_UPDATE_LOGIN             IN     NUMBER,
   X_RESPONSIBLE_USER              IN     NUMBER,
   X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
   X_ACCRUAL_ACCOUNT_ID            IN     NUMBER,
   X_RECEIVABLE_ACCOUNT_ID         IN     NUMBER,
   X_TERM_TEMPLATE_ID              IN     NUMBER,
   X_LEASE_COMMENCEMENT_DATE       IN     DATE,
   X_LEASE_TERMINATION_DATE        IN     DATE,
   X_LEASE_EXECUTION_DATE          IN     DATE,
   X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
   X_ATTRIBUTE1                    IN     VARCHAR2,
   X_ATTRIBUTE2                    IN     VARCHAR2,
   X_ATTRIBUTE3                    IN     VARCHAR2,
   X_ATTRIBUTE4                    IN     VARCHAR2,
   X_ATTRIBUTE5                    IN     VARCHAR2,
   X_ATTRIBUTE6                    IN     VARCHAR2,
   X_ATTRIBUTE7                    IN     VARCHAR2,
   X_ATTRIBUTE8                    IN     VARCHAR2,
   X_ATTRIBUTE9                    IN     VARCHAR2,
   X_ATTRIBUTE10                   IN     VARCHAR2,
   X_ATTRIBUTE11                   IN     VARCHAR2,
   X_ATTRIBUTE12                   IN     VARCHAR2,
   X_ATTRIBUTE13                   IN     VARCHAR2,
   X_ATTRIBUTE14                   IN     VARCHAR2,
   X_ATTRIBUTE15                   IN     VARCHAR2,
   x_location_id                   IN     NUMBER,
   x_customer_id                   IN     NUMBER,
   x_grouping_rule_id              IN     NUMBER,
   x_lease_extension_end_date      IN     DATE,
   x_calendar_year_start_date      IN     VARCHAR2
)
IS
   l_return_status VARCHAR2(30) := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_leases_all WHERE lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.Update_Row (+)');

   /* Check IF lease NUMBER IS unique */
   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   l_return_status := NULL;
   pn_leases_pkg.check_unique_lease_number
   (
      l_return_status,
      x_lease_id,
      x_lease_num,
      l_org_id
   );
   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   ------------------------------------------------------
   -- We need to update records in pn_lease_details
   ------------------------------------------------------
   pn_lease_details_pkg.Update_Row
   (
       X_LEASE_DETAIL_ID               => X_LEASE_DETAIL_ID
      ,X_LEASE_CHANGE_ID               => X_LEASE_CHANGE_ID
      ,X_LEASE_ID                      => X_LEASE_ID
      ,X_RESPONSIBLE_USER              => X_RESPONSIBLE_USER
      ,X_EXPENSE_ACCOUNT_ID            => X_EXPENSE_ACCOUNT_ID
      ,X_LEASE_COMMENCEMENT_DATE       => X_LEASE_COMMENCEMENT_DATE
      ,X_LEASE_TERMINATION_DATE        => X_LEASE_TERMINATION_DATE
      ,X_LEASE_EXECUTION_DATE          => X_LEASE_EXECUTION_DATE
      ,X_LAST_UPDATE_DATE              => sysdate
      ,X_LAST_UPDATED_BY               => X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN             => X_LAST_UPDATE_LOGIN
      ,X_ACCRUAL_ACCOUNT_ID            => X_ACCRUAL_ACCOUNT_ID
      ,X_RECEIVABLE_ACCOUNT_ID         => X_RECEIVABLE_ACCOUNT_ID
      ,X_TERM_TEMPLATE_ID              => X_TERM_TEMPLATE_ID
      ,X_GROUPING_RULE_ID              => X_GROUPING_RULE_ID
      ,X_ATTRIBUTE_CATEGORY            => X_ATTRIBUTE_CATEGORY
      ,X_ATTRIBUTE1                    => X_ATTRIBUTE1
      ,X_ATTRIBUTE2                    => X_ATTRIBUTE2
      ,X_ATTRIBUTE3                    => X_ATTRIBUTE3
      ,X_ATTRIBUTE4                    => X_ATTRIBUTE4
      ,X_ATTRIBUTE5                    => X_ATTRIBUTE5
      ,X_ATTRIBUTE6                    => X_ATTRIBUTE6
      ,X_ATTRIBUTE7                    => X_ATTRIBUTE7
      ,X_ATTRIBUTE8                    => X_ATTRIBUTE8
      ,X_ATTRIBUTE9                    => X_ATTRIBUTE9
      ,X_ATTRIBUTE10                   => X_ATTRIBUTE10
      ,X_ATTRIBUTE11                   => X_ATTRIBUTE11
      ,X_ATTRIBUTE12                   => X_ATTRIBUTE12
      ,X_ATTRIBUTE13                   => X_ATTRIBUTE13
      ,X_ATTRIBUTE14                   => X_ATTRIBUTE14
      ,X_ATTRIBUTE15                   => X_ATTRIBUTE15
      ,x_lease_extension_end_date      => x_lease_extension_end_date
   );

   UPDATE pn_leases_all
   SET    NAME                            = X_NAME,
          LEASE_NUM                       = X_LEASE_NUM,
          PARENT_LEASE_ID                 = X_PARENT_LEASE_ID,
          LEASE_TYPE_CODE                 = X_LEASE_TYPE_CODE,
          LEASE_CLASS_CODE                = X_LEASE_CLASS_CODE,
          PAYMENT_TERM_PRORATION_RULE     = X_PAYMENT_TERM_PRORATION_RULE,
          ABSTRACTED_BY_USER              = X_ABSTRACTED_BY_USER,
          LAST_UPDATE_DATE                = sysdate,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          STATUS                          = X_STATUS,
          LEASE_STATUS                    = X_LEASE_STATUS,
          location_id                     = x_location_id,
          customer_id                     = x_customer_id,
	  cal_start                       = x_calendar_year_start_date
   WHERE  LEASE_ID = X_LEASE_ID;

   pnp_debug_pkg.debug ('PN_LEASES_PKG.Update_Row (-)');

END Update_Row;


-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : Deletes the row
-- HISTORY      :
-- 10-SEP-02  dthota   o Replaced the predicate in PN_LEASES_PKG.delete_row
--                       SELECT clause for performance issues
--                       Fix for bug # 2558646
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_leases, pn_lease_details,
--                       pn_lease_transactions, pn_lease_changes with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_LEASE_ID in NUMBER
)
IS
   l_leaseDetailId                 NUMBER                  := NULL;
   l_leaseTransactionId            NUMBER                  := NULL;
   l_leaseChangeId                 NUMBER                  := NULL;
BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.Delete_Row (+)');

   SELECT pd.lease_detail_id,
          pt.lease_transaction_id,
          pc.lease_change_id
   INTO   l_leaseDetailId,l_leaseTransactionId,l_leaseChangeId
   FROM   pn_lease_details_all        pd
         ,pn_lease_transactions_all   pt
         ,pn_lease_changes_all        pc
   WHERE  pd.lease_id                  = x_lease_id
   AND    pc.lease_change_id           = pd.lease_change_id
   AND    pt.lease_transaction_id      = pc.lease_transaction_id
   FOR UPDATE OF lease_detail_id NOWAIT;

   -- first we need to  DELETE the lease detail rows.
   pn_lease_details_pkg.Delete_Row (X_LEASE_DETAIL_ID =>l_leaseDetailId);


   -- we need to  DELETE the transactions rows.
   pn_lease_changes_pkg.Delete_Row_transactions (X_LEASE_TRANSACTION_ID =>l_leaseTransactionId);


   -- we need to  DELETE the lease changes rows.
   pn_lease_changes_pkg.Delete_Row (X_LEASE_CHANGE_ID =>l_leaseChangeId);

   DELETE FROM pn_leases_all
   WHERE lease_id = x_lease_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LEASES_PKG.Delete_Row (-)');

END Delete_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : check_unique_lease_number
-- INVOKED FROM : insert_row and update_row procedure
-- PURPOSE      : checks unique lease number
-- HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE check_unique_lease_number
(
   x_return_status                 IN OUT NOCOPY VARCHAR2,
   x_lease_id                      IN     NUMBER,
   x_lease_number                  IN     VARCHAR2
)
IS
   l_dummy     NUMBER;
BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.check_UNIQUE_lease_number (+)');

   SELECT 1
   INTO   l_dummy
   FROM   DUAL
   WHERE  NOT EXISTS (SELECT 1
                      FROM   pn_leases pnl
                      WHERE  pnl.lease_num = x_lease_number
                      AND    ((x_lease_id IS NULL) OR (pnl.lease_id <> x_lease_id))
                     );

   pnp_debug_pkg.debug ('PN_LEASES_PKG.check_UNIQUE_lease_number (-)');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fnd_message.set_name ('PN','PN_DUP_LEASE_NUMBER');
      fnd_message.set_token('LEASE_NUMBER', x_lease_number);
      x_return_status        := 'E';
END check_unique_lease_number;

/* --- OVERLOADED functions and procedures for MOAC START --- */
-------------------------------------------------------------------------------
-- PROCDURE     : check_unique_lease_number
-- INVOKED FROM : insert_row and update_row procedure
-- PURPOSE      : checks unique lease number
--  IMPORTANT   - Use this function once MOAC is enabled. All form libraries
--                must call this.
-- HISTORY      :
-- 05-JUL-05  piagrawa o Bug 4284035 - Created
-------------------------------------------------------------------------------
PROCEDURE check_unique_lease_number
(
   x_return_status                 IN OUT NOCOPY VARCHAR2,
   x_lease_id                      IN     NUMBER,
   x_lease_number                  IN     VARCHAR2,
   x_org_id                        IN     NUMBER
)
IS
   l_dummy     NUMBER;
BEGIN
   pnp_debug_pkg.debug ('PN_LEASES_PKG.check_UNIQUE_lease_number (+)');

   SELECT 1
   INTO   l_dummy
   FROM   DUAL
   WHERE  NOT EXISTS (SELECT 1
                      FROM   pn_leases_all pnl
                      WHERE  pnl.lease_num = x_lease_number
                      AND    ((x_lease_id IS NULL) OR (pnl.lease_id <> x_lease_id))
                      AND    org_id = x_org_id
                     );

   pnp_debug_pkg.debug ('PN_LEASES_PKG.check_UNIQUE_lease_number (-)');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fnd_message.set_name ('PN','PN_DUP_LEASE_NUMBER');
      fnd_message.set_token('LEASE_NUMBER', x_lease_number);
      x_return_status        := 'E';
END check_unique_lease_number;
/* --- OVERLOADED functions and procedures for MOAC END --- */

END pn_leases_pkg;

/
