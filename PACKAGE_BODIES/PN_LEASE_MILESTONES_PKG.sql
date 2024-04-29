--------------------------------------------------------
--  DDL for Package Body PN_LEASE_MILESTONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LEASE_MILESTONES_PKG" aS
-- $Header: PNTMLSTB.pls 120.2 2005/12/01 08:24:39 appldev ship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_lease_milestones with
--                       _ALL table.
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_LEASE_MILESTONE_ID            IN OUT NOCOPY NUMBER,
   X_LEASE_CHANGE_ID               IN            NUMBER,
   X_MILESTONE_TYPE_CODE           IN            VARCHAR2,
   X_OPTION_ID                     IN            NUMBER,
   X_INSURANCE_REQUIREMENT_ID      IN            NUMBER,
   X_PAYMENT_TERM_ID               IN            NUMBER,
   X_LEAD_DAYS                     IN            NUMBER,
   X_EVERY_DAYS                    IN            NUMBER,
   X_ACTION_TAKEN                  IN            VARCHAR2,
   X_ACTION_DATE                   IN            DATE,
   X_ATTRIBUTE_CATEGORY            IN            VARCHAR2,
   X_ATTRIBUTE1                    IN            VARCHAR2,
   X_ATTRIBUTE2                    IN            VARCHAR2,
   X_ATTRIBUTE3                    IN            VARCHAR2,
   X_ATTRIBUTE4                    IN            VARCHAR2,
   X_ATTRIBUTE5                    IN            VARCHAR2,
   X_ATTRIBUTE6                    IN            VARCHAR2,
   X_ATTRIBUTE7                    IN            VARCHAR2,
   X_ATTRIBUTE8                    IN            VARCHAR2,
   X_ATTRIBUTE9                    IN            VARCHAR2,
   X_ATTRIBUTE10                   IN            VARCHAR2,
   X_ATTRIBUTE11                   IN            VARCHAR2,
   X_ATTRIBUTE12                   IN            VARCHAR2,
   X_ATTRIBUTE13                   IN            VARCHAR2,
   X_ATTRIBUTE14                   IN            VARCHAR2,
   X_ATTRIBUTE15                   IN            VARCHAR2,
   X_MILESTONE_DATE                IN            DATE,
   X_USER_ID                       IN            NUMBER,
   X_LEASE_ID                      IN            NUMBER,
   X_CREATION_DATE                 IN            DATE,
   X_CREATED_BY                    IN            NUMBER,
   X_LAST_UPDATE_DATE              IN            DATE,
   X_LAST_UPDATED_BY               IN            NUMBER,
   X_LAST_UPDATE_LOGIN             IN            NUMBER,
   x_org_id                        IN            NUMBER
)
IS
   CURSOR c IS
      SELECT ROWID
      FROM   pn_lease_milestones_all
      WHERE  lease_milestone_id = x_lease_milestone_id;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all
    WHERE  lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN

   /*--------------------------------------------------------------------------
   -- Assign Nextval when argument value IS passed as NULL
   --------------------------------------------------------------------------*/

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   IF X_LEASE_MILESTONE_ID IS NULL THEN

      SELECT  pn_lease_milestones_s.NEXTVAL
      INTO    x_lease_milestone_id
      FROM    DUAL;

   END IF;

   INSERT INTO pn_lease_milestones_all
   (
      LEASE_CHANGE_ID,
      MILESTONE_TYPE_CODE,
      OPTION_ID,
      INSURANCE_REQUIREMENT_ID,
      PAYMENT_TERM_ID,
      LEAD_DAYS,
      EVERY_DAYS,
      ACTION_TAKEN,
      ACTION_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      LEASE_MILESTONE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      MILESTONE_DATE,
      USER_ID,
      LEASE_ID,
      org_id
   )
   VALUES (
      X_LEASE_CHANGE_ID,
      X_MILESTONE_TYPE_CODE,
      X_OPTION_ID,
      X_INSURANCE_REQUIREMENT_ID,
      X_PAYMENT_TERM_ID,
      X_LEAD_DAYS,
      X_EVERY_DAYS,
      X_ACTION_TAKEN,
      X_ACTION_DATE,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      X_LEASE_MILESTONE_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_MILESTONE_DATE,
      X_USER_ID,
      X_LEASE_ID ,
      l_org_id
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_lease_milestones with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row   (
   X_LEASE_MILESTONE_ID            IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_MILESTONE_TYPE_CODE           IN     VARCHAR2,
   X_OPTION_ID                     IN     NUMBER,
   X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
   X_PAYMENT_TERM_ID               IN     NUMBER,
   X_LEAD_DAYS                     IN     NUMBER,
   X_EVERY_DAYS                    IN     NUMBER,
   X_ACTION_TAKEN                  IN     VARCHAR2,
   X_ACTION_DATE                   IN     DATE,
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
   X_MILESTONE_DATE                IN     DATE,
   X_USER_ID                       IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_lease_milestones_all
      WHERE  lease_milestone_id = x_lease_milestone_id
      FOR    UPDATE OF lease_milestone_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.LEASE_MILESTONE_ID = X_LEASE_MILESTONE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_MILESTONE_ID',tlinfo.LEASE_MILESTONE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.MILESTONE_TYPE_CODE = X_MILESTONE_TYPE_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('MILESTONE_TYPE_CODE',tlinfo.MILESTONE_TYPE_CODE);
   END IF;

   IF NOT ((tlinfo.OPTION_ID = X_OPTION_ID)
       OR ((tlinfo.OPTION_ID IS NULL) AND (X_OPTION_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_ID',tlinfo.OPTION_ID);
   END IF;

   IF NOT ((tlinfo.INSURANCE_REQUIREMENT_ID = X_INSURANCE_REQUIREMENT_ID)
       OR ((tlinfo.INSURANCE_REQUIREMENT_ID IS NULL) AND (X_INSURANCE_REQUIREMENT_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INSURANCE_REQUIREMENT_ID',tlinfo.INSURANCE_REQUIREMENT_ID);
   END IF;

   IF NOT ((tlinfo.PAYMENT_TERM_ID = X_PAYMENT_TERM_ID)
       OR ((tlinfo.PAYMENT_TERM_ID IS NULL) AND (X_PAYMENT_TERM_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_ID',tlinfo.PAYMENT_TERM_ID);
   END IF;

   IF NOT ((tlinfo.LEAD_DAYS = X_LEAD_DAYS)
       OR ((tlinfo.LEAD_DAYS IS NULL) AND (X_LEAD_DAYS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEAD_DAYS',tlinfo.LEAD_DAYS);
   END IF;

   IF NOT ((tlinfo.EVERY_DAYS = X_EVERY_DAYS)
       OR ((tlinfo.EVERY_DAYS IS NULL) AND (X_EVERY_DAYS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EVERY_DAYS',tlinfo.EVERY_DAYS);
   END IF;

   IF NOT ((tlinfo.ACTION_TAKEN = X_ACTION_TAKEN)
       OR ((tlinfo.ACTION_TAKEN IS NULL) AND (X_ACTION_TAKEN IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACTION_TAKEN',tlinfo.ACTION_TAKEN);
   END IF;

   IF NOT ((tlinfo.ACTION_DATE = X_ACTION_DATE)
       OR ((tlinfo.ACTION_DATE IS NULL) AND (X_ACTION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACTION_DATE',tlinfo.ACTION_DATE);
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

   IF NOT (tlinfo.MILESTONE_DATE = X_MILESTONE_DATE) THEN
      pn_var_rent_pkg.lock_row_exception('MILESTONE_DATE',tlinfo.MILESTONE_DATE);
   END IF;

   IF NOT (tlinfo.USER_ID = X_USER_ID) THEN
      pn_var_rent_pkg.lock_row_exception('USER_ID',tlinfo.USER_ID);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

  RETURN;

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_lease_milestones with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
   X_LEASE_MILESTONE_ID            IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_MILESTONE_TYPE_CODE           IN     VARCHAR2,
   X_OPTION_ID                     IN     NUMBER,
   X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
   X_PAYMENT_TERM_ID               IN     NUMBER,
   X_LEAD_DAYS                     IN     NUMBER,
   X_EVERY_DAYS                    IN     NUMBER,
   X_ACTION_TAKEN                  IN     VARCHAR2,
   X_ACTION_DATE                   IN     DATE,
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
   X_MILESTONE_DATE                IN     DATE,
   X_USER_ID                       IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LAST_UPDATE_DATE              IN     DATE,
   X_LAST_UPDATED_BY               IN     NUMBER,
   X_LAST_UPDATE_LOGIN             IN     NUMBER
)
IS
BEGIN

  UPDATE pn_lease_milestones_all
  SET    LEASE_CHANGE_ID            = X_LEASE_CHANGE_ID,
         MILESTONE_TYPE_CODE        = X_MILESTONE_TYPE_CODE,
         OPTION_ID                  = X_OPTION_ID,
         INSURANCE_REQUIREMENT_ID   = X_INSURANCE_REQUIREMENT_ID,
         PAYMENT_TERM_ID            = X_PAYMENT_TERM_ID,
         LEAD_DAYS                  = X_LEAD_DAYS,
         EVERY_DAYS                 = X_EVERY_DAYS,
         ACTION_TAKEN               = X_ACTION_TAKEN,
         ACTION_DATE                = X_ACTION_DATE,
         ATTRIBUTE_CATEGORY         = X_ATTRIBUTE_CATEGORY,
         ATTRIBUTE1                 = X_ATTRIBUTE1,
         ATTRIBUTE2                 = X_ATTRIBUTE2,
         ATTRIBUTE3                 = X_ATTRIBUTE3,
         ATTRIBUTE4                 = X_ATTRIBUTE4,
         ATTRIBUTE5                 = X_ATTRIBUTE5,
         ATTRIBUTE6                 = X_ATTRIBUTE6,
         ATTRIBUTE7                 = X_ATTRIBUTE7,
         ATTRIBUTE8                 = X_ATTRIBUTE8,
         ATTRIBUTE9                 = X_ATTRIBUTE9,
         ATTRIBUTE10                = X_ATTRIBUTE10,
         ATTRIBUTE11                = X_ATTRIBUTE11,
         ATTRIBUTE12                = X_ATTRIBUTE12,
         ATTRIBUTE13                = X_ATTRIBUTE13,
         ATTRIBUTE14                = X_ATTRIBUTE14,
         ATTRIBUTE15                = X_ATTRIBUTE15,
         MILESTONE_DATE             = X_MILESTONE_DATE,
         USER_ID                    = X_USER_ID,
         LEASE_ID                   = X_LEASE_ID,
         LEASE_MILESTONE_ID         = X_LEASE_MILESTONE_ID,
         LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
  WHERE  LEASE_MILESTONE_ID         = X_LEASE_MILESTONE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_lease_milestones with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_LEASE_MILESTONE_ID in NUMBER
)
IS
BEGIN

  DELETE FROM pn_lease_milestones_all
  WHERE lease_milestone_id = x_lease_milestone_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;


END pn_lease_milestones_pkg;

/
