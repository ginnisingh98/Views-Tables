--------------------------------------------------------
--  DDL for Package Body PN_CONTACT_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_CONTACT_ASSIGNMENTS_PKG" AS
-- $Header: PNTCOASB.pls 120.2 2005/12/01 03:33:13 appldev ship $
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_CONTACT_ASSIGNMENTS
--                       with _ALL table.
-- 28-NOV-05  pikhar   o get org_id using cursor.
-------------------------------------------------------------------------------
PROCEDURE Insert_Row
(
    X_ROWID                         IN OUT NOCOPY VARCHAR2
   ,X_CONTACT_ASSIGNMENT_ID         IN OUT NOCOPY NUMBER
   ,X_LAST_UPDATE_DATE              IN            DATE
   ,X_LAST_UPDATED_BY               IN            NUMBER
   ,X_CREATION_DATE                 IN            DATE
   ,X_CREATED_BY                    IN            NUMBER
   ,X_LAST_UPDATE_LOGIN             IN            NUMBER
   ,X_COMPANY_ID                    IN            NUMBER
   ,X_COMPANY_SITE_ID               IN            NUMBER
   ,X_LEASE_ID                      IN            NUMBER
   ,X_LEASE_CHANGE_ID               IN            NUMBER
   ,X_LOCATION_ID                   IN            NUMBER
   ,X_STATUS                        IN            VARCHAR2
   ,X_ATTRIBUTE_CATEGORY            IN            VARCHAR2
   ,X_ATTRIBUTE1                    IN            VARCHAR2
   ,X_ATTRIBUTE2                    IN            VARCHAR2
   ,X_ATTRIBUTE3                    IN            VARCHAR2
   ,X_ATTRIBUTE4                    IN            VARCHAR2
   ,X_ATTRIBUTE5                    IN            VARCHAR2
   ,X_ATTRIBUTE6                    IN            VARCHAR2
   ,X_ATTRIBUTE7                    IN            VARCHAR2
   ,X_ATTRIBUTE8                    IN            VARCHAR2
   ,X_ATTRIBUTE9                    IN            VARCHAR2
   ,X_ATTRIBUTE10                   IN            VARCHAR2
   ,X_ATTRIBUTE11                   IN            VARCHAR2
   ,X_ATTRIBUTE12                   IN            VARCHAR2
   ,X_ATTRIBUTE13                   IN            VARCHAR2
   ,X_ATTRIBUTE14                   IN            VARCHAR2
   ,X_ATTRIBUTE15                   IN            VARCHAR2
   ,x_org_id                        IN            NUMBER
)
IS
   CURSOR c IS
      SELECT ROWID
      FROM   PN_CONTACT_ASSIGNMENTS_ALL
      WHERE  CONTACT_ASSIGNMENT_ID = X_CONTACT_ASSIGNMENT_ID;

   CURSOR org_cur IS
     SELECT org_id
     FROM   PN_COMPANIES_ALL
     WHERE  COMPANY_ID = X_COMPANY_ID;

   l_org_id NUMBER;


BEGIN

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   IF (X_CONTACT_ASSIGNMENT_ID IS NULL) THEN
      SELECT PN_CONTACT_ASSIGNMENTS_S.NEXTVAL
      INTO   X_CONTACT_ASSIGNMENT_ID
      FROM   DUAL;
   END IF;


   INSERT INTO PN_CONTACT_ASSIGNMENTS_ALL
   (
       CONTACT_ASSIGNMENT_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,COMPANY_ID
      ,COMPANY_SITE_ID
      ,LEASE_ID
      ,LEASE_CHANGE_ID
      ,LOCATION_ID
      ,STATUS
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
      ,org_id
   )
   VALUES
   (
       X_CONTACT_ASSIGNMENT_ID
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_CREATION_DATE
      ,X_CREATED_BY
      ,X_LAST_UPDATE_LOGIN
      ,X_COMPANY_ID
      ,X_COMPANY_SITE_ID
      ,X_LEASE_ID
      ,X_LEASE_CHANGE_ID
      ,X_LOCATION_ID
      ,X_STATUS
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
      ,l_org_id
   );

   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_CONTACT_ASSIGNMENTS
--                       with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
    X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
   ,X_COMPANY_ID                    IN     NUMBER
   ,X_COMPANY_SITE_ID               IN     NUMBER
   ,X_LEASE_ID                      IN     NUMBER
   ,X_LEASE_CHANGE_ID               IN     NUMBER
   ,X_LOCATION_ID                   IN     NUMBER
   ,X_STATUS                        IN     VARCHAR2
   ,X_ATTRIBUTE_CATEGORY            IN     VARCHAR2
   ,X_ATTRIBUTE1                    IN     VARCHAR2
   ,X_ATTRIBUTE2                    IN     VARCHAR2
   ,X_ATTRIBUTE3                    IN     VARCHAR2
   ,X_ATTRIBUTE4                    IN     VARCHAR2
   ,X_ATTRIBUTE5                    IN     VARCHAR2
   ,X_ATTRIBUTE6                    IN     VARCHAR2
   ,X_ATTRIBUTE7                    IN     VARCHAR2
   ,X_ATTRIBUTE8                    IN     VARCHAR2
   ,X_ATTRIBUTE9                    IN     VARCHAR2
   ,X_ATTRIBUTE10                   IN     VARCHAR2
   ,X_ATTRIBUTE11                   IN     VARCHAR2
   ,X_ATTRIBUTE12                   IN     VARCHAR2
   ,X_ATTRIBUTE13                   IN     VARCHAR2
   ,X_ATTRIBUTE14                   IN     VARCHAR2
   ,X_ATTRIBUTE15                   IN     VARCHAR2
)
IS
   CURSOR c IS
      SELECT *
      FROM   pn_contact_assignments_all
      WHERE  contact_assignment_id = x_contact_assignment_id
      FOR UPDATE OF contact_assignment_id NOWAIT;

   tlinfo c%ROWTYPE;

BEGIN

   OPEN c;
      FETCH c INTO tlinfo;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RETURN;
      END IF;
   CLOSE c;

   IF NOT (tlinfo.COMPANY_ID = X_COMPANY_ID) THEN
      pn_var_rent_pkg.lock_row_exception('COMPANY_ID',tlinfo.COMPANY_ID);
   END IF;

   IF NOT (tlinfo.COMPANY_SITE_ID = X_COMPANY_SITE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('COMPANY_SITE_ID',tlinfo.COMPANY_SITE_ID);
   END IF;

   IF NOT ((tlinfo.LEASE_ID = X_LEASE_ID)
       OR ((tlinfo.LEASE_ID IS NULL) AND (X_LEASE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT ((tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID)
       OR ((tlinfo.LEASE_CHANGE_ID IS NULL) AND (X_LEASE_CHANGE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT ((tlinfo.LOCATION_ID = X_LOCATION_ID)
       OR ((tlinfo.LOCATION_ID IS NULL) AND (X_LOCATION_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.LOCATION_ID);
   END IF;

   IF NOT (tlinfo.STATUS = X_STATUS) THEN
      pn_var_rent_pkg.lock_row_exception('STATUS',tlinfo.STATUS);
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
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_CONTACT_ASSIGNMENTS
--                       with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
    X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
   ,X_LAST_UPDATE_DATE              IN     DATE
   ,X_LAST_UPDATED_BY               IN     NUMBER
   ,X_LAST_UPDATE_LOGIN             IN     NUMBER
   ,X_COMPANY_ID                    IN     NUMBER
   ,X_COMPANY_SITE_ID               IN     NUMBER
   ,X_LEASE_ID                      IN     NUMBER
   ,X_LEASE_CHANGE_ID               IN     NUMBER
   ,X_LOCATION_ID                   IN     NUMBER
   ,X_STATUS                        IN     VARCHAR2
   ,X_ATTRIBUTE_CATEGORY            IN     VARCHAR2
   ,X_ATTRIBUTE1                    IN     VARCHAR2
   ,X_ATTRIBUTE2                    IN     VARCHAR2
   ,X_ATTRIBUTE3                    IN     VARCHAR2
   ,X_ATTRIBUTE4                    IN     VARCHAR2
   ,X_ATTRIBUTE5                    IN     VARCHAR2
   ,X_ATTRIBUTE6                    IN     VARCHAR2
   ,X_ATTRIBUTE7                    IN     VARCHAR2
   ,X_ATTRIBUTE8                    IN     VARCHAR2
   ,X_ATTRIBUTE9                    IN     VARCHAR2
   ,X_ATTRIBUTE10                   IN     VARCHAR2
   ,X_ATTRIBUTE11                   IN     VARCHAR2
   ,X_ATTRIBUTE12                   IN     VARCHAR2
   ,X_ATTRIBUTE13                   IN     VARCHAR2
   ,X_ATTRIBUTE14                   IN     VARCHAR2
   ,X_ATTRIBUTE15                   IN     VARCHAR2
)
IS
   l_leaseStatus           VARCHAR2(2);
   l_contactHIStoryId      NUMBER          := NULL;

   CURSOR c IS
      SELECT *
      FROM   PN_CONTACT_ASSIGNMENTS_ALL
      WHERE  CONTACT_ASSIGNMENT_ID = X_CONTACT_ASSIGNMENT_ID;

   recInfoForHist c%ROWTYPE;

BEGIN

   -- we want to create hIStory recs for lease records only
   IF (X_LEASE_ID IS NOT NULL) THEN
      -- get the lease status
      l_leaseStatus := PNP_UTIL_FUNC.GET_LEASE_STATUS (X_LEASE_ID);

      -- We need to INSERT the hIStory row IF the lease IS finalISed
      IF (l_leaseStatus = 'F')  THEN

         OPEN c;
            FETCH c INTO recInfoForHist;
            IF (c%NOTFOUND) THEN
               CLOSE c;
               RAISE NO_DATA_FOUND;
            END IF;
         CLOSE c;

         IF (recInfoForHist.LEASE_CHANGE_ID <> X_LEASE_CHANGE_ID) THEN

            SELECT pn_contact_assign_hIStory_s.nextval
            INTO   l_contactHIStoryId
            FROM   DUAL;

            INSERT INTO PN_CONTACT_ASSIGN_HISTORY
            (
                CONTACT_ASSIGN_HISTORY_ID
               ,CONTACT_ASSIGNMENT_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,COMPANY_ID
               ,COMPANY_SITE_ID
               ,LEASE_ID
               ,LEASE_CHANGE_ID
               ,NEW_LEASE_CHANGE_ID
               ,LOCATION_ID
               ,STATUS
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
            )
            VALUES
            (
                l_contactHIStoryId
               ,recInfoForHist.CONTACT_ASSIGNMENT_ID
               ,recInfoForHist.LAST_UPDATE_DATE
               ,recInfoForHist.LAST_UPDATED_BY
               ,recInfoForHist.CREATION_DATE
               ,recInfoForHist.CREATED_BY
               ,recInfoForHist.LAST_UPDATE_LOGIN
               ,recInfoForHist.COMPANY_ID
               ,recInfoForHist.COMPANY_SITE_ID
               ,recInfoForHist.LEASE_ID
               ,recInfoForHist.LEASE_CHANGE_ID
               ,X_LEASE_CHANGE_ID
               ,recInfoForHist.LOCATION_ID
               ,recInfoForHist.STATUS
               ,recInfoForHist.ATTRIBUTE_CATEGORY
               ,recInfoForHist.ATTRIBUTE1
               ,recInfoForHist.ATTRIBUTE2
               ,recInfoForHist.ATTRIBUTE3
               ,recInfoForHist.ATTRIBUTE4
               ,recInfoForHist.ATTRIBUTE5
               ,recInfoForHist.ATTRIBUTE6
               ,recInfoForHist.ATTRIBUTE7
               ,recInfoForHist.ATTRIBUTE8
               ,recInfoForHist.ATTRIBUTE9
               ,recInfoForHist.ATTRIBUTE10
               ,recInfoForHist.ATTRIBUTE11
               ,recInfoForHist.ATTRIBUTE12
               ,recInfoForHist.ATTRIBUTE13
               ,recInfoForHist.ATTRIBUTE14
               ,recInfoForHist.ATTRIBUTE15
            );
         END IF;
      END IF;
   END IF;

   UPDATE PN_CONTACT_ASSIGNMENTS_ALL
      SET LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE
         ,LAST_UPDATED_BY                 = X_LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
         ,COMPANY_ID                      = X_COMPANY_ID
         ,COMPANY_SITE_ID                 = X_COMPANY_SITE_ID
         ,LEASE_ID                        = X_LEASE_ID
         ,LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID
         ,LOCATION_ID                     = X_LOCATION_ID
         ,STATUS                          = X_STATUS
         ,ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1                      = X_ATTRIBUTE1
         ,ATTRIBUTE2                      = X_ATTRIBUTE2
         ,ATTRIBUTE3                      = X_ATTRIBUTE3
         ,ATTRIBUTE4                      = X_ATTRIBUTE4
         ,ATTRIBUTE5                      = X_ATTRIBUTE5
         ,ATTRIBUTE6                      = X_ATTRIBUTE6
         ,ATTRIBUTE7                      = X_ATTRIBUTE7
         ,ATTRIBUTE8                      = X_ATTRIBUTE8
         ,ATTRIBUTE9                      = X_ATTRIBUTE9
         ,ATTRIBUTE10                     = X_ATTRIBUTE10
         ,ATTRIBUTE11                     = X_ATTRIBUTE11
         ,ATTRIBUTE12                     = X_ATTRIBUTE12
         ,ATTRIBUTE13                     = X_ATTRIBUTE13
         ,ATTRIBUTE14                     = X_ATTRIBUTE14
         ,ATTRIBUTE15                     = X_ATTRIBUTE15
   WHERE  CONTACT_ASSIGNMENT_ID           = X_CONTACT_ASSIGNMENT_ID;

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_CONTACT_ASSIGNMENTS
--                       with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
)
IS
BEGIN
   DELETE
   FROM   PN_CONTACT_ASSIGNMENTS_ALL
   WHERE  CONTACT_ASSIGNMENT_ID  = X_CONTACT_ASSIGNMENT_ID
   AND    STATUS <> 'F';

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END Delete_Row;


END pn_contact_assignments_pkg;

/
