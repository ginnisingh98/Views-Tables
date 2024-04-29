--------------------------------------------------------
--  DDL for Package Body PN_LEASE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LEASE_CHANGES_PKG" AS
-- $Header: PNTLCHGB.pls 120.3 2006/01/20 03:56:27 appldev ship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_lease_transactions,
--                       pn_lease_changes with _ALL table.
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-- 18-JAN-06  piagrawa o Bug#4931780 - Added parameter x_cutoff_date in
--                       Insert_Row.
-------------------------------------------------------------------------------
PROCEDURE Insert_Row
(
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_LEASE_CHANGE_ID               IN OUT NOCOPY NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_NUMBER           IN OUT NOCOPY NUMBER,
   X_LEASE_CHANGE_NAME             IN     VARCHAR2,
   X_RESPONSIBLE_USER              IN     NUMBER,
   X_CHANGE_COMMENCEMENT_DATE      IN     DATE,
   X_CHANGE_TERMINATION_DATE       IN     DATE,
   X_CHANGE_TYPE_LOOKUP_CODE       IN     VARCHAR2,
   X_CHANGE_EXECUTION_DATE         IN     DATE,
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
   X_ABSTRACTED_BY_USER            IN     NUMBER,
   X_CREATION_DATE                 IN     DATE,
   X_CREATED_BY                    IN     NUMBER,
   X_LAST_UPDATE_DATE              IN     DATE,
   X_LAST_UPDATED_BY               IN     NUMBER,
   X_LAST_UPDATE_LOGIN             IN     NUMBER,
   x_org_id                        IN     NUMBER,
   x_cutoff_date                   IN     DATE
)
IS

   CURSOR C IS
      SELECT ROWID
      FROM   pn_lease_changes_all
      WHERE  lease_change_id = x_lease_change_id;

   l_leaseTransactionId        NUMBER       := NULL;
   l_return_status             VARCHAR2(30) := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_leases_all
    WHERE lease_id = x_lease_id;

   l_org_id NUMBER;


BEGIN

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Insert_Row (+)');
   --------------------------------------------------------
   -- IF the LEASE_CHANGE_NUMBER IS NULL THEN we need to
   -- generate it
   --------------------------------------------------------
   IF (x_change_type_lookup_code IN ('AMEND', 'EDIT'))
   THEN
      IF (x_lease_change_number IS NULL)
      THEN
         SELECT NVL(MAX(pnc.lease_change_number), 0)
         INTO   x_lease_change_number
         FROM   pn_lease_changes_all pnc
         WHERE  pnc.lease_id = x_lease_id
         AND    pnc.change_type_lookup_code = x_change_type_lookup_code;

         x_lease_change_number := x_lease_change_number + 1;

      END IF;
   ELSE
      X_LEASE_CHANGE_NUMBER        := NULL;
   END IF;


   --------------------------------------------------------
   -- We need to check IF the Lease Change Number IS unique
   -- within a lease AND Change Type Lookup Code
   --------------------------------------------------------
   l_return_status        := NULL;
   PN_LEASE_CHANGES_PKG.CHECK_UNIQUE_CHANGE_NUMBER
   (
       x_return_status                 => l_return_status
      ,X_LEASE_ID                      => X_LEASE_ID
      ,X_CHANGE_TYPE_LOOKUP_CODE       => X_CHANGE_TYPE_LOOKUP_CODE
      ,X_LEASE_CHANGE_NUMBER           => X_LEASE_CHANGE_NUMBER
   );
   IF (l_return_status IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;


   --------------------------------------------------------
   -- We need to INSERT a row IN pn_lease_transactions
   --------------------------------------------------------
   SELECT pn_lease_transactions_s.NEXTVAL
   INTO   l_leaseTransactionId
   FROM   DUAL;

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_lease_transactions_all
   (
       LEASE_TRANSACTION_ID
      ,LEASE_ID
      ,LOCATION_ID
      ,TRANSACTION_TYPE
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,DATE_EFFECTIVE
      ,org_id
   )
   VALUES
   (
       l_leaseTransactionId
      ,X_LEASE_ID
      ,NULL
      ,X_CHANGE_TYPE_LOOKUP_CODE
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_CREATION_DATE
      ,X_CREATED_BY
      ,X_LAST_UPDATE_LOGIN
      ,X_CREATION_DATE
      ,l_org_id
   );

   --------------------------------------------------------
   -- We need INSERT row INTO PN_LEASE_CHANGES
   --------------------------------------------------------
   IF (x_lease_change_id IS NULL) THEN
      SELECT pn_lease_changes_s.NEXTVAL
      INTO   x_lease_change_id
      FROM   DUAL;
   END IF;

   INSERT INTO pn_lease_changes_all
   (
       LEASE_CHANGE_ID
      ,LEASE_ID
      ,LEASE_TRANSACTION_ID
      ,LEASE_CHANGE_NUMBER
      ,LEASE_CHANGE_NAME
      ,RESPONSIBLE_USER
      ,CHANGE_COMMENCEMENT_DATE
      ,CHANGE_TERMINATION_DATE
      ,CHANGE_TYPE_LOOKUP_CODE
      ,CHANGE_EXECUTION_DATE
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,ABSTRACTED_BY_USER
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,org_id
      ,CUTOFF_DATE
   )
   VALUES
   (
       X_LEASE_CHANGE_ID
      ,X_LEASE_ID
      ,l_leaseTransactionId
      ,X_LEASE_CHANGE_NUMBER
      ,X_LEASE_CHANGE_NAME
      ,X_RESPONSIBLE_USER
      ,X_CHANGE_COMMENCEMENT_DATE
      ,X_CHANGE_TERMINATION_DATE
      ,X_CHANGE_TYPE_LOOKUP_CODE
      ,X_CHANGE_EXECUTION_DATE
      ,X_ATTRIBUTE_CATEGORY
      ,X_ATTRIBUTE1
      ,X_ATTRIBUTE2
      ,X_ATTRIBUTE3
      ,X_ATTRIBUTE4
      ,X_ATTRIBUTE5
      ,X_ATTRIBUTE6
      ,X_ATTRIBUTE7
      ,X_ATTRIBUTE8
      ,X_ATTRIBUTE9
      ,X_ATTRIBUTE10
      ,X_ATTRIBUTE11
      ,X_ATTRIBUTE12
      ,X_ATTRIBUTE13
      ,X_ATTRIBUTE14
      ,X_ATTRIBUTE15
      ,X_ABSTRACTED_BY_USER
      ,X_CREATION_DATE
      ,X_CREATED_BY
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN
      ,l_org_id
      ,x_cutoff_date
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Insert_Row (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05 sdmahesh o Bug 4284035 - Replaced pn_lease_changes with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
   X_LEASE_CHANGE_ID               IN NUMBER,
   X_RESPONSIBLE_USER              IN NUMBER,
   X_CHANGE_COMMENCEMENT_DATE      IN DATE,
   X_CHANGE_TERMINATION_DATE       IN DATE,
   X_CHANGE_TYPE_LOOKUP_CODE       IN VARCHAR2,
   X_CHANGE_EXECUTION_DATE         IN DATE,
   X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
   X_ATTRIBUTE1                    IN VARCHAR2,
   X_ATTRIBUTE2                    IN VARCHAR2,
   X_ATTRIBUTE3                    IN VARCHAR2,
   X_ATTRIBUTE4                    IN VARCHAR2,
   X_ATTRIBUTE5                    IN VARCHAR2,
   X_ATTRIBUTE6                    IN VARCHAR2,
   X_ATTRIBUTE7                    IN VARCHAR2,
   X_ATTRIBUTE8                    IN VARCHAR2,
   X_ATTRIBUTE9                    IN VARCHAR2,
   X_ATTRIBUTE10                   IN VARCHAR2,
   X_ATTRIBUTE11                   IN VARCHAR2,
   X_ATTRIBUTE12                   IN VARCHAR2,
   X_ATTRIBUTE13                   IN VARCHAR2,
   X_ATTRIBUTE14                   IN VARCHAR2,
   X_ATTRIBUTE15                   IN VARCHAR2,
   X_LEASE_ID                      IN NUMBER,
   X_LEASE_TRANSACTION_ID          IN NUMBER,
   X_LEASE_CHANGE_NUMBER           IN NUMBER,
   X_LEASE_CHANGE_NAME             IN VARCHAR2,
   X_ABSTRACTED_BY_USER            IN NUMBER
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_lease_changes_all
      WHERE  lease_change_id = x_lease_change_id
      FOR UPDATE OF lease_change_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN
   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Lock_Row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT ((tlinfo.RESPONSIBLE_USER = X_RESPONSIBLE_USER)
       OR ((tlinfo.RESPONSIBLE_USER IS NULL) AND (X_RESPONSIBLE_USER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RESPONSIBLE_USER',tlinfo.RESPONSIBLE_USER);
   END IF;

   IF NOT ((tlinfo.CHANGE_COMMENCEMENT_DATE = X_CHANGE_COMMENCEMENT_DATE)
       OR ((tlinfo.CHANGE_COMMENCEMENT_DATE IS NULL) AND (X_CHANGE_COMMENCEMENT_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CHANGE_COMMENCEMENT_DATE',tlinfo.CHANGE_COMMENCEMENT_DATE);
   END IF;

   IF NOT ((tlinfo.CHANGE_TERMINATION_DATE = X_CHANGE_TERMINATION_DATE)
       OR ((tlinfo.CHANGE_TERMINATION_DATE IS NULL) AND (X_CHANGE_TERMINATION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CHANGE_TERMINATION_DATE',tlinfo.CHANGE_TERMINATION_DATE);
   END IF;

   IF NOT ((tlinfo.CHANGE_TYPE_LOOKUP_CODE = X_CHANGE_TYPE_LOOKUP_CODE)
       OR ((tlinfo.CHANGE_TYPE_LOOKUP_CODE IS NULL) AND (X_CHANGE_TYPE_LOOKUP_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CHANGE_TYPE_LOOKUP_CODE',tlinfo.CHANGE_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT ((tlinfo.CHANGE_EXECUTION_DATE = X_CHANGE_EXECUTION_DATE)
       OR ((tlinfo.CHANGE_EXECUTION_DATE IS NULL) AND (X_CHANGE_EXECUTION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CHANGE_EXECUTION_DATE',tlinfo.CHANGE_EXECUTION_DATE);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
       OR ((tlinfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_TRANSACTION_ID = X_LEASE_TRANSACTION_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_TRANSACTION_ID',tlinfo.LEASE_TRANSACTION_ID);
   END IF;

   IF NOT ((tlinfo.LEASE_CHANGE_NUMBER = X_LEASE_CHANGE_NUMBER)
       OR ((tlinfo.LEASE_CHANGE_NUMBER IS NULL) AND (X_LEASE_CHANGE_NUMBER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_NUMBER',tlinfo.LEASE_CHANGE_NUMBER);
   END IF;

   IF NOT ((tlinfo.LEASE_CHANGE_NAME = X_LEASE_CHANGE_NAME)
       OR ((tlinfo.LEASE_CHANGE_NAME IS NULL) AND (X_LEASE_CHANGE_NAME IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_NAME',tlinfo.LEASE_CHANGE_NAME);
   END IF;

   IF NOT ((tlinfo.ABSTRACTED_BY_USER = X_ABSTRACTED_BY_USER)
       OR ((tlinfo.ABSTRACTED_BY_USER IS NULL) AND (X_ABSTRACTED_BY_USER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ABSTRACTED_BY_USER',tlinfo.ABSTRACTED_BY_USER);
   END IF;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Lock_Row (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_lease_changes with _ALL table
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
   X_LEASE_CHANGE_ID               IN NUMBER,
   X_RESPONSIBLE_USER              IN NUMBER,
   X_CHANGE_COMMENCEMENT_DATE      IN DATE,
   X_CHANGE_TERMINATION_DATE       IN DATE,
   X_CHANGE_TYPE_LOOKUP_CODE       IN VARCHAR2,
   X_CHANGE_EXECUTION_DATE         IN DATE,
   X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
   X_ATTRIBUTE1                    IN VARCHAR2,
   X_ATTRIBUTE2                    IN VARCHAR2,
   X_ATTRIBUTE3                    IN VARCHAR2,
   X_ATTRIBUTE4                    IN VARCHAR2,
   X_ATTRIBUTE5                    IN VARCHAR2,
   X_ATTRIBUTE6                    IN VARCHAR2,
   X_ATTRIBUTE7                    IN VARCHAR2,
   X_ATTRIBUTE8                    IN VARCHAR2,
   X_ATTRIBUTE9                    IN VARCHAR2,
   X_ATTRIBUTE10                   IN VARCHAR2,
   X_ATTRIBUTE11                   IN VARCHAR2,
   X_ATTRIBUTE12                   IN VARCHAR2,
   X_ATTRIBUTE13                   IN VARCHAR2,
   X_ATTRIBUTE14                   IN VARCHAR2,
   X_ATTRIBUTE15                   IN VARCHAR2,
   X_LEASE_ID                      IN NUMBER,
   X_LEASE_TRANSACTION_ID          IN NUMBER,
   X_LEASE_CHANGE_NUMBER           IN NUMBER,
   X_LEASE_CHANGE_NAME             IN VARCHAR2,
   X_ABSTRACTED_BY_USER            IN NUMBER,
   X_LAST_UPDATE_DATE              IN DATE,
   X_LAST_UPDATED_BY               IN NUMBER,
   X_LAST_UPDATE_LOGIN             IN NUMBER
)
IS
BEGIN
   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Update_Row (+)');

   UPDATE pn_lease_changes_all
   SET    RESPONSIBLE_USER                = X_RESPONSIBLE_USER,
          CHANGE_COMMENCEMENT_DATE        = X_CHANGE_COMMENCEMENT_DATE,
          CHANGE_TERMINATION_DATE         = X_CHANGE_TERMINATION_DATE,
          CHANGE_TYPE_LOOKUP_CODE         = X_CHANGE_TYPE_LOOKUP_CODE,
          CHANGE_EXECUTION_DATE           = X_CHANGE_EXECUTION_DATE,
          ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                      = X_ATTRIBUTE1,
          ATTRIBUTE2                      = X_ATTRIBUTE2,
          ATTRIBUTE3                      = X_ATTRIBUTE3,
          ATTRIBUTE4                      = X_ATTRIBUTE4,
          ATTRIBUTE5                      = X_ATTRIBUTE5,
          ATTRIBUTE6                      = X_ATTRIBUTE6,
          ATTRIBUTE7                      = X_ATTRIBUTE7,
          ATTRIBUTE8                      = X_ATTRIBUTE8,
          ATTRIBUTE9                      = X_ATTRIBUTE9,
          ATTRIBUTE10                     = X_ATTRIBUTE10,
          ATTRIBUTE11                     = X_ATTRIBUTE11,
          ATTRIBUTE12                     = X_ATTRIBUTE12,
          ATTRIBUTE13                     = X_ATTRIBUTE13,
          ATTRIBUTE14                     = X_ATTRIBUTE14,
          ATTRIBUTE15                     = X_ATTRIBUTE15,
          LEASE_ID                        = X_LEASE_ID,
          LEASE_TRANSACTION_ID            = X_LEASE_TRANSACTION_ID,
          LEASE_CHANGE_NUMBER             = X_LEASE_CHANGE_NUMBER,
          LEASE_CHANGE_NAME               = X_LEASE_CHANGE_NAME,
          ABSTRACTED_BY_USER              = X_ABSTRACTED_BY_USER,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
   WHERE  LEASE_CHANGE_ID = X_LEASE_CHANGE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Update_Row (-)');
END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_lease_changes with _ALL table
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_LEASE_CHANGE_ID IN NUMBER
)
IS
BEGIN
   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Delete_Row (+)');
   DELETE FROM pn_lease_changes_all
   WHERE lease_change_id = x_lease_change_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Delete_Row (-)');
END Delete_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row_Transactions
-- INVOKED FROM :
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_lease_transactions with
--                       _ALL table
-------------------------------------------------------------------------------
PROCEDURE Delete_Row_Transactions
(
   X_LEASE_TRANSACTION_ID IN NUMBER
)
IS
BEGIN
   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Delete_Row_Transactions (+)');
   DELETE FROM pn_lease_transactions_all
   WHERE lease_transaction_id = x_lease_transaction_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.Delete_Row_Transactions (-)');
END Delete_Row_Transactions;

-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_UNIQUE_CHANGE_NUMBER
-- INVOKED FROM : insert_row and update_row
-- PURPOSE      : checks unique change number
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_lease_changes with
--                       _ALL table
-------------------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE_CHANGE_NUMBER
(
    x_return_status                 IN OUT NOCOPY VARCHAR2
   ,X_LEASE_ID                      IN            NUMBER
   ,X_CHANGE_TYPE_LOOKUP_CODE       IN            VARCHAR2
   ,X_LEASE_CHANGE_NUMBER           IN            VARCHAR2
)
IS
   l_leaseName                     VARCHAR2 (50) := NULL;
   l_dummy                         NUMBER        := NULL;
BEGIN
   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.CHECK_UNIQUE_CHANGE_NUMBER (+)');

   IF (X_CHANGE_TYPE_LOOKUP_CODE = 'ABSTRACT') THEN
      BEGIN
         SELECT 1
         INTO   l_dummy
         FROM   DUAL
         WHERE  NOT EXISTS (SELECT 1
                            FROM   pn_lease_changes_all        plc
                            WHERE  plc.change_type_lookup_code = x_change_type_lookup_code
                            AND    plc.lease_id = X_LEASE_ID
                           );

      END;

   ELSIF (X_CHANGE_TYPE_LOOKUP_CODE IN ('AMEND', 'EDIT')) THEN
      BEGIN
         SELECT name
         INTO   l_leaseName
         FROM   pn_leases_all
         WHERE  lease_id = X_LEASE_ID;

         SELECT 1
         INTO   l_dummy
         FROM   DUAL
         WHERE  NOT EXISTS (SELECT 1
                            FROM   pn_lease_changes_all        plc
                            WHERE  plc.change_type_lookup_code = X_CHANGE_TYPE_LOOKUP_CODE
                            AND    plc.lease_change_number = X_LEASE_CHANGE_NUMBER
                            AND    plc.lease_id = X_LEASE_ID
                           );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (X_CHANGE_TYPE_LOOKUP_CODE = 'AMEND') THEN
               fnd_message.set_name('PN', 'PN_DUP_LEASE_CHANGE_NUMBER');
               fnd_message.set_token('LEASE_CHANGE_NUMBER', x_lease_change_number);
               fnd_message.set_token('LEASE_NAME', l_leaseName);
            ELSE
               fnd_message.set_name ('PN', 'PN_DUP_EDIT_NUMBER');
               fnd_message.set_token('EDIT_NUMBER', x_lease_change_number);
               fnd_message.set_token('LEASE_NAME', l_leaseName);
            END IF;
            x_return_status := 'E';
      END;
   ELSE
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LEASE_CHANGES_PKG.CHECK_UNIQUE_CHANGE_NUMBER (-)');
END CHECK_UNIQUE_CHANGE_NUMBER;

END PN_LEASE_CHANGES_PKG;

/
