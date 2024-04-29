--------------------------------------------------------
--  DDL for Package Body PN_INSURANCE_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INSURANCE_REQUIREMENTS_PKG" AS
  -- $Header: PNTINRQB.pls 120.2 2005/12/01 07:39:58 appldev ship $
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_insurance_requirements with
--                       _ALL table.
-- 28-Nov-05  pikhar   o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
    X_ROWID                         IN OUT NOCOPY VARCHAR2,
    X_INSURANCE_REQUIREMENT_ID      IN OUT NOCOPY NUMBER,
    X_INSURANCE_TYPE_LOOKUP_CODE    IN     VARCHAR2,
    X_LEASE_ID                      IN     NUMBER,
    X_LEASE_CHANGE_ID               IN     NUMBER,
    X_POLICY_START_DATE             IN     DATE,
    X_POLICY_EXPIRATION_DATE        IN     DATE,
    X_INSURER_NAME                  IN     VARCHAR2,
    X_POLICY_NUMBER                 IN     VARCHAR2,
    X_INSURED_AMOUNT                IN     NUMBER,
    X_REQUIRED_AMOUNT               IN     NUMBER,
    X_STATUS                        IN     VARCHAR2,
    X_INSURANCE_COMMENTS            IN     VARCHAR2,
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
    X_CREATION_DATE                 IN     DATE,
    X_CREATED_BY                    IN     NUMBER,
    X_LAST_UPDATE_DATE              IN     DATE,
    X_LAST_UPDATED_BY               IN     NUMBER,
    X_LAST_UPDATE_LOGIN             IN     NUMBER,
    x_org_id                        IN     NUMBER
)
IS
   CURSOR C IS
      SELECT ROWID
      FROM   pn_insurance_requirements_all
      WHERE  insurance_requirement_id = x_insurance_requirement_id;

  CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all
    WHERE  lease_id = X_LEASE_ID ;

    l_org_id NUMBER;

BEGIN

   IF x_insurance_requirement_id IS NULL THEN

   SELECT pn_insurance_requirements_s.NEXTVAL
   INTO   x_insurance_requirement_id
   FROM   DUAL;

   END IF;

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   INSERT INTO PN_INSURANCE_REQUIREMENTS_ALL
   (
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      INSURANCE_TYPE_LOOKUP_CODE,
      LEASE_ID,
      LEASE_CHANGE_ID,
      POLICY_START_DATE,
      POLICY_EXPIRATION_DATE,
      INSURER_NAME,
      POLICY_NUMBER,
      INSURED_AMOUNT,
      REQUIRED_AMOUNT,
      STATUS,
      INSURANCE_COMMENTS,
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
      INSURANCE_REQUIREMENT_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      org_id
   )
   VALUES
   (
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_INSURANCE_TYPE_LOOKUP_CODE,
      X_LEASE_ID,
      X_LEASE_CHANGE_ID,
      X_POLICY_START_DATE,
      X_POLICY_EXPIRATION_DATE,
      X_INSURER_NAME,
      X_POLICY_NUMBER,
      X_INSURED_AMOUNT,
      X_REQUIRED_AMOUNT,
      X_STATUS,
      X_INSURANCE_COMMENTS,
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
      X_INSURANCE_REQUIREMENT_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
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
-- PROCDURE     : Lock_row
-- INVOKED FROM : Lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_insurance_requirements with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
    X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
    X_INSURANCE_TYPE_LOOKUP_CODE    IN     VARCHAR2,
    X_LEASE_ID                      IN     NUMBER,
    X_LEASE_CHANGE_ID               IN     NUMBER,
    X_POLICY_START_DATE             IN     DATE,
    X_POLICY_EXPIRATION_DATE        IN     DATE,
    X_INSURER_NAME                  IN     VARCHAR2,
    X_POLICY_NUMBER                 IN     VARCHAR2,
    X_INSURED_AMOUNT                IN     NUMBER,
    X_REQUIRED_AMOUNT               IN     NUMBER,
    X_STATUS                        IN     VARCHAR2,
    X_INSURANCE_COMMENTS            IN     VARCHAR2,
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
    X_ATTRIBUTE15                   IN     VARCHAR2
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   PN_INSURANCE_REQUIREMENTS_ALL
      WHERE  INSURANCE_REQUIREMENT_ID = X_INSURANCE_REQUIREMENT_ID
      FOR    UPDATE OF INSURANCE_REQUIREMENT_ID NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.INSURANCE_REQUIREMENT_ID = X_INSURANCE_REQUIREMENT_ID) THEN
      pn_var_rent_pkg.lock_row_exception('INSURANCE_REQUIREMENT_ID',tlinfo.INSURANCE_REQUIREMENT_ID);
   END IF;

   IF NOT (tlinfo.INSURANCE_TYPE_LOOKUP_CODE = X_INSURANCE_TYPE_LOOKUP_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('INSURANCE_TYPE_LOOKUP_CODE',tlinfo.INSURANCE_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.STATUS = X_STATUS) THEN
      pn_var_rent_pkg.lock_row_exception('STATUS',tlinfo.STATUS);
   END IF;

   IF NOT ((tlinfo.INSURANCE_COMMENTS = X_INSURANCE_COMMENTS)
       OR ((tlinfo.INSURANCE_COMMENTS IS NULL) AND (X_INSURANCE_COMMENTS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INSURANCE_COMMENTS',tlinfo.INSURANCE_COMMENTS);
   END IF;

   IF NOT ((tlinfo.POLICY_START_DATE = X_POLICY_START_DATE)
           OR ((tlinfo.POLICY_START_DATE IS NULL) AND (X_POLICY_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('POLICY_START_DATE',tlinfo.POLICY_START_DATE);
   END IF;

   IF NOT ((tlinfo.POLICY_EXPIRATION_DATE = X_POLICY_EXPIRATION_DATE)
           OR ((tlinfo.POLICY_EXPIRATION_DATE IS NULL) AND (X_POLICY_EXPIRATION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('POLICY_EXPIRATION_DATE',tlinfo.POLICY_EXPIRATION_DATE);
   END IF;

   IF NOT ((tlinfo.INSURER_NAME = X_INSURER_NAME)
           OR ((tlinfo.INSURER_NAME IS NULL) AND (X_INSURER_NAME IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INSURER_NAME',tlinfo.INSURER_NAME);
   END IF;

   IF NOT ((tlinfo.POLICY_NUMBER = X_POLICY_NUMBER)
       OR ((tlinfo.POLICY_NUMBER IS NULL) AND (X_POLICY_NUMBER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('POLICY_NUMBER',tlinfo.POLICY_NUMBER);
   END IF;

   IF NOT ((tlinfo.INSURED_AMOUNT = X_INSURED_AMOUNT)
       OR ((tlinfo.INSURED_AMOUNT IS NULL) AND (X_INSURED_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INSURED_AMOUNT',tlinfo.INSURED_AMOUNT);
   END IF;

   IF NOT ((tlinfo.REQUIRED_AMOUNT = X_REQUIRED_AMOUNT)
       OR ((tlinfo.REQUIRED_AMOUNT IS NULL) AND (X_REQUIRED_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('REQUIRED_AMOUNT',tlinfo.REQUIRED_AMOUNT);
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

   RETURN;

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_insurance_requirements with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
    X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
    X_INSURANCE_TYPE_LOOKUP_CODE    IN     VARCHAR2,
    X_LEASE_ID                      IN     NUMBER,
    X_LEASE_CHANGE_ID               IN     NUMBER,
    X_POLICY_START_DATE             IN     DATE,
    X_POLICY_EXPIRATION_DATE        IN     DATE,
    X_INSURER_NAME                  IN     VARCHAR2,
    X_POLICY_NUMBER                 IN     VARCHAR2,
    X_INSURED_AMOUNT                IN     NUMBER,
    X_REQUIRED_AMOUNT               IN     NUMBER,
    X_STATUS                        IN     VARCHAR2,
    X_INSURANCE_COMMENTS            IN     VARCHAR2,
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
    X_LAST_UPDATE_DATE              IN     DATE,
    X_LAST_UPDATED_BY               IN     NUMBER,
    X_LAST_UPDATE_LOGIN             IN     NUMBER
)
IS
   CURSOR c2 IS
      SELECT *
      FROM   pn_insurance_requirements_all
      WHERE  insurance_requirement_id = x_insurance_requirement_id;

   recInfoForHist c2%ROWTYPE;

   l_insuranceHistoryId    NUMBER          := NULL;
   l_leaseStatus           VARCHAR2(30)    := NULL;

BEGIN
   ---------------------------------------------------------------
   -- get the lease status
   ---------------------------------------------------------------
   l_leaseStatus := PNP_UTIL_FUNC.GET_LEASE_STATUS (X_LEASE_ID);

   ---------------------------------------------------------------
   -- We need to INSERT the history row IF the lease IS finalised
   ---------------------------------------------------------------
   IF (l_leaseStatus = 'F')  THEN

      OPEN c2;
         FETCH c2 INTO recInfoForHist;
         IF (c2%NOTFOUND) THEN
            CLOSE c2;
            RAISE NO_DATA_FOUND;
         END IF;
      CLOSE c2;

      IF (recInfoForHist.LEASE_CHANGE_ID <> X_LEASE_CHANGE_ID) THEN

         SELECT pn_insur_require_history_s.NEXTVAL
         INTO   l_insuranceHistoryId
         FROM   DUAL;

         INSERT INTO PN_INSUR_REQUIRE_HISTORY
         (
            INSURANCE_HISTORY_ID,
            INSURANCE_TYPE_LOOKUP_CODE,
            LEASE_ID,
            LEASE_CHANGE_ID,
            NEW_LEASE_CHANGE_ID,
            POLICY_START_DATE,
            POLICY_EXPIRATION_DATE,
            INSURER_NAME,
            POLICY_NUMBER,
            INSURED_AMOUNT,
            REQUIRED_AMOUNT,
            STATUS,
            INSURANCE_COMMENTS,
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
            INSURANCE_REQUIREMENT_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
         )
         VALUES
         (
            l_insuranceHistoryId,
            recInfoForHist.INSURANCE_TYPE_LOOKUP_CODE,
            recInfoForHist.LEASE_ID,
            recInfoForHist.LEASE_CHANGE_ID,
            X_LEASE_CHANGE_ID,
            recInfoForHist.POLICY_START_DATE,
            recInfoForHist.POLICY_EXPIRATION_DATE,
            recInfoForHist.INSURER_NAME,
            recInfoForHist.POLICY_NUMBER,
            recInfoForHist.INSURED_AMOUNT,
            recInfoForHist.REQUIRED_AMOUNT,
            recInfoForHist.STATUS,
            recInfoForHist.INSURANCE_COMMENTS,
            recInfoForHist.ATTRIBUTE_CATEGORY,
            recInfoForHist.ATTRIBUTE1,
            recInfoForHist.ATTRIBUTE2,
            recInfoForHist.ATTRIBUTE3,
            recInfoForHist.ATTRIBUTE4,
            recInfoForHist.ATTRIBUTE5,
            recInfoForHist.ATTRIBUTE6,
            recInfoForHist.ATTRIBUTE7,
            recInfoForHist.ATTRIBUTE8,
            recInfoForHist.ATTRIBUTE9,
            recInfoForHist.ATTRIBUTE10,
            recInfoForHist.ATTRIBUTE11,
            recInfoForHist.ATTRIBUTE12,
            recInfoForHist.ATTRIBUTE13,
            recInfoForHist.ATTRIBUTE14,
            recInfoForHist.ATTRIBUTE15,
            recInfoForHist.INSURANCE_REQUIREMENT_ID,
            recInfoForHist.CREATION_DATE,
            recInfoForHist.CREATED_BY,
            recInfoForHist.LAST_UPDATE_DATE,
            recInfoForHist.LAST_UPDATED_BY,
            recInfoForHist.LAST_UPDATE_LOGIN
         );
      END IF;
   END IF;

   UPDATE pn_insurance_requirements_all
   SET    INSURANCE_TYPE_LOOKUP_CODE      = X_INSURANCE_TYPE_LOOKUP_CODE,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          POLICY_START_DATE               = X_POLICY_START_DATE,
          POLICY_EXPIRATION_DATE          = X_POLICY_EXPIRATION_DATE,
          INSURER_NAME                    = X_INSURER_NAME,
          POLICY_NUMBER                   = X_POLICY_NUMBER,
          INSURED_AMOUNT                  = X_INSURED_AMOUNT,
          REQUIRED_AMOUNT                 = X_REQUIRED_AMOUNT,
          STATUS                          = X_STATUS,
          INSURANCE_COMMENTS              = X_INSURANCE_COMMENTS,
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
          INSURANCE_REQUIREMENT_ID        = X_INSURANCE_REQUIREMENT_ID,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
   WHERE  INSURANCE_REQUIREMENT_ID = X_INSURANCE_REQUIREMENT_ID ;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_insurance_requirements with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_INSURANCE_REQUIREMENT_ID      IN     NUMBER
)
IS
BEGIN
   DELETE FROM pn_insurance_requirements_all
   WHERE  insurance_requirement_id = x_insurance_requirement_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END Delete_Row;

END pn_insurance_requirements_pkg;

/
