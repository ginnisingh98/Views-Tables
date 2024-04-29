--------------------------------------------------------
--  DDL for Package Body PN_RIGHTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_RIGHTS_PKG" AS
/* $Header: PNRIGHTB.pls 120.2 2005/12/01 03:27:15 appldev ship $ */
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_rights with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE INSERT_ROW (
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_RIGHT_ID                      IN OUT NOCOPY NUMBER,
                       X_RIGHT_NUM                     IN OUT NOCOPY NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_RIGHT_TYPE_CODE               IN     VARCHAR2,
                       X_RIGHT_STATUS_CODE             IN     VARCHAR2,
                       X_RIGHT_REFERENCE               IN     VARCHAR2,
                       X_START_DATE                    IN     DATE,
                       X_EXPIRATION_DATE               IN     DATE,
                       X_RIGHT_COMMENTS                IN     VARCHAR2,
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

   CURSOR rights IS
      SELECT ROWID
      FROM   pn_rights_all
      WHERE  right_id = x_right_id;

   CURSOR org_cur IS
      SELECT org_id FROM pn_leases_all WHERE lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the right number
   -------------------------------------------------------
   SELECT  NVL(MAX(pnr.right_num),0)
   INTO    x_right_num
   FROM    pn_rights_all pnr
   WHERE   pnr.lease_id = x_lease_id;

   X_RIGHT_NUM    := X_RIGHT_NUM + 1;

   -------------------------------------------------------
   -- SELECT the nextval for right id
   -------------------------------------------------------
   IF ( X_RIGHT_ID IS NULL) THEN

      SELECT  pn_rights_s.NEXTVAL
      INTO    x_right_id
      FROM    DUAL;
   END IF;

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;


   INSERT INTO PN_RIGHTS_ALL
   (
       RIGHT_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LEASE_ID,
       LEASE_CHANGE_ID,
       RIGHT_NUM,
       RIGHT_TYPE_CODE,
       RIGHT_STATUS_CODE,
       RIGHT_REFERENCE,
       START_DATE,
       EXPIRATION_DATE,
       RIGHT_COMMENTS,
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
       org_id
   )
   VALUES
   (
       X_RIGHT_ID,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_LEASE_ID,
       X_LEASE_CHANGE_ID,
       X_RIGHT_NUM,
       X_RIGHT_TYPE_CODE,
       X_RIGHT_STATUS_CODE,
       X_RIGHT_REFERENCE,
       X_START_DATE,
       X_EXPIRATION_DATE,
       X_RIGHT_COMMENTS,
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
       l_org_id
   );

   OPEN rights;
      FETCH rights INTO X_ROWID;
      IF (rights%NOTFOUND) THEN
         CLOSE rights;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE rights;

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_rights with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE LOCK_ROW
(
   X_RIGHT_ID                      IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_RIGHT_NUM                     IN     NUMBER,
   X_RIGHT_TYPE_CODE               IN     VARCHAR2,
   X_RIGHT_STATUS_CODE             IN     VARCHAR2,
   X_RIGHT_REFERENCE               IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_RIGHT_COMMENTS                IN     VARCHAR2,
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
      FROM pn_rights_all
      WHERE right_id = x_right_id
      FOR UPDATE OF right_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.LOCK_ROW (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.RIGHT_ID = X_RIGHT_ID) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_ID',tlinfo.RIGHT_ID);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.RIGHT_NUM = X_RIGHT_NUM) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_NUM',tlinfo.RIGHT_NUM);
   END IF;

   IF NOT (tlinfo.RIGHT_TYPE_CODE = X_RIGHT_TYPE_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_TYPE_CODE',tlinfo.RIGHT_TYPE_CODE);
   END IF;

   IF NOT (tlinfo.RIGHT_STATUS_CODE = X_RIGHT_STATUS_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_STATUS_CODE',tlinfo.RIGHT_STATUS_CODE);
   END IF;

   IF NOT ((tlinfo.RIGHT_REFERENCE = X_RIGHT_REFERENCE)
       OR ((tlinfo.RIGHT_REFERENCE IS NULL) AND (X_RIGHT_REFERENCE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_REFERENCE',tlinfo.RIGHT_REFERENCE);
   END IF;

   IF NOT ((tlinfo.START_DATE = X_START_DATE)
       OR ((tlinfo.START_DATE IS NULL) AND (X_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('START_DATE',tlinfo.START_DATE);
   END IF;

   IF NOT ((tlinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
       OR ((tlinfo.EXPIRATION_DATE IS NULL) AND (X_EXPIRATION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPIRATION_DATE',tlinfo.EXPIRATION_DATE);
   END IF;

   IF NOT ((tlinfo.RIGHT_COMMENTS = X_RIGHT_COMMENTS)
       OR ((tlinfo.RIGHT_COMMENTS IS NULL) AND (X_RIGHT_COMMENTS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RIGHT_COMMENTS',tlinfo.RIGHT_COMMENTS);
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

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_rights with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
          X_RIGHT_ID                      IN     NUMBER,
          X_LEASE_ID                      IN     NUMBER,
          X_LEASE_CHANGE_ID               IN     NUMBER,
          X_RIGHT_NUM                     IN     NUMBER,
          X_RIGHT_TYPE_CODE               IN     VARCHAR2,
          X_RIGHT_STATUS_CODE             IN     VARCHAR2,
          X_RIGHT_REFERENCE               IN     VARCHAR2,
          X_START_DATE                    IN     DATE,
          X_EXPIRATION_DATE               IN     DATE,
          X_RIGHT_COMMENTS                IN     VARCHAR2,
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
      SELECT  *
      FROM    pn_rights_all
      WHERE   right_id = x_right_id;

   recInfoForHist                  c2%ROWTYPE;
   l_rightHistoryId                NUMBER       := NULL;
   l_leaseStatus                   VARCHAR2(30) := NULL;

BEGIN
   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.UPDATE_ROW (+)');

   ----------------------------------------------------
   -- get the lease status
   ----------------------------------------------------
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

         SELECT  PN_RIGHTS_HISTORY_S.NEXTVAL
         INTO    l_rightHistoryId
         FROM    DUAL;

         INSERT INTO PN_RIGHTS_HISTORY
         (
             RIGHT_HISTORY_ID,
             RIGHT_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             LEASE_ID,
             LEASE_CHANGE_ID,
             NEW_LEASE_CHANGE_ID,
             RIGHT_NUM,
             RIGHT_TYPE_CODE,
             RIGHT_STATUS_CODE,
             RIGHT_REFERENCE,
             START_DATE,
             EXPIRATION_DATE,
             RIGHT_COMMENTS,
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
             ATTRIBUTE15
         )
         VALUES
         (
             l_rightHistoryId,
             recInfoForHist.RIGHT_ID,
             recInfoForHist.LAST_UPDATE_DATE,
             recInfoForHist.LAST_UPDATED_BY,
             recInfoForHist.CREATION_DATE,
             recInfoForHist.CREATED_BY,
             recInfoForHist.LAST_UPDATE_LOGIN,
             recInfoForHist.LEASE_ID,
             recInfoForHist.LEASE_CHANGE_ID,
             X_LEASE_CHANGE_ID,
             recInfoForHist.RIGHT_NUM,
             recInfoForHist.RIGHT_TYPE_CODE,
             recInfoForHist.RIGHT_STATUS_CODE,
             recInfoForHist.RIGHT_REFERENCE,
             recInfoForHist.START_DATE,
             recInfoForHist.EXPIRATION_DATE,
             recInfoForHist.RIGHT_COMMENTS,
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
             recInfoForHist.ATTRIBUTE15
         );
      END IF;
   END IF;

   UPDATE PN_RIGHTS_ALL
   SET    LEASE_ID                        = X_LEASE_ID,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          RIGHT_NUM                       = X_RIGHT_NUM,
          RIGHT_TYPE_CODE                 = X_RIGHT_TYPE_CODE,
          RIGHT_STATUS_CODE               = X_RIGHT_STATUS_CODE,
          RIGHT_REFERENCE                 = X_RIGHT_REFERENCE,
          START_DATE                      = X_START_DATE,
          EXPIRATION_DATE                 = X_EXPIRATION_DATE,
          RIGHT_COMMENTS                  = X_RIGHT_COMMENTS,
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
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
   WHERE  RIGHT_ID = X_RIGHT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_rights with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE DELETE_ROW
(
   X_RIGHT_ID   IN    NUMBER
)
IS
BEGIN

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.DELETE_ROW (+)');

   DELETE FROM PN_RIGHTS_ALL              --sdm_MOAC
   WHERE RIGHT_ID = X_RIGHT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_RIGHTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_RIGHTS_PKG;

/
