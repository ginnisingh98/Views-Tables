--------------------------------------------------------
--  DDL for Package Body PN_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_OPTIONS_PKG" AS
-- $Header: PNTOPTNB.pls 120.2 2005/12/01 08:25:59 appldev ship $
-------------------------------------------------------------------------------
-- PROCDURE : Insert_Row
-- HISTORY      :
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_OPTION_ID                     IN OUT NOCOPY NUMBER,
   X_OPTION_NUM                    IN OUT NOCOPY VARCHAR2,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_OPTION_TYPE_CODE              IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_OPTION_SIZE                   IN     NUMBER,
   X_UOM_CODE                      IN     VARCHAR2,
   X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
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
   X_OPTION_EXER_START_DATE        IN     DATE,
   X_OPTION_EXER_END_DATE          IN     DATE,
   X_OPTION_ACTION_DATE            IN     DATE,
   X_OPTION_COST                   IN     VARCHAR2,
   X_OPTION_AREA_CHANGE            IN     NUMBER,
   X_OPTION_REFERENCE              IN     VARCHAR2,
   X_OPTION_NOTICE_REQD            IN     VARCHAR2,
   X_OPTION_COMMENTS               IN     VARCHAR2,
   x_org_id                        IN     NUMBER
)
IS

   CURSOR c IS
    SELECT ROWID
    FROM   pn_options_all
    WHERE  option_id = x_option_id ;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all
    WHERE  lease_id = x_lease_id ;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the lease change number
   -------------------------------------------------------
   SELECT NVL(MAX(TO_NUMBER(pno.option_num)), 0)+1
   INTO   x_option_num
   FROM   pn_options_all        PNO
   WHERE  pno.lease_id = x_lease_id;

   -------------------------------------------------------
   -- SELECT the NEXTVAL for option id
   -------------------------------------------------------

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;

   IF ( X_OPTION_ID IS NULL) THEN
   SELECT pn_options_s.NEXTVAL
   INTO   x_option_id
   FROM   DUAL;
   END IF;

   INSERT INTO pn_options_all
   (
      OPTION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LEASE_ID,
      LEASE_CHANGE_ID,
      OPTION_NUM,
      OPTION_TYPE_CODE,
      START_DATE,
      EXPIRATION_DATE,
      OPTION_SIZE,
      UOM_CODE,
      OPTION_STATUS_LOOKUP_CODE,
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
      OPTION_EXER_START_DATE,
      OPTION_EXER_END_DATE,
      OPTION_ACTION_DATE,
      OPTION_COST,
      OPTION_AREA_CHANGE,
      OPTION_REFERENCE,
      OPTION_NOTICE_REQD,
      OPTION_COMMENTS,
      org_id
   )
   VALUES
   (
      X_OPTION_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LEASE_ID,
      X_LEASE_CHANGE_ID,
      X_OPTION_NUM,
      X_OPTION_TYPE_CODE,
      X_START_DATE,
      X_EXPIRATION_DATE,
      X_OPTION_SIZE,
      X_UOM_CODE,
      X_OPTION_STATUS_LOOKUP_CODE,
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
      X_OPTION_EXER_START_DATE,
      X_OPTION_EXER_END_DATE,
      X_OPTION_ACTION_DATE,
      X_OPTION_COST,
      X_OPTION_AREA_CHANGE,
      X_OPTION_REFERENCE,
      X_OPTION_NOTICE_REQD,
      X_OPTION_COMMENTS,
      l_org_id
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.INSERT_ROW (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_options with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row (
   X_OPTION_ID                     IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_OPTION_NUM                    IN     VARCHAR2,
   X_OPTION_TYPE_CODE              IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_OPTION_SIZE                   IN     NUMBER,
   X_UOM_CODE                      IN     VARCHAR2,
   X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
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
   X_OPTION_EXER_START_DATE        IN     DATE,
   X_OPTION_EXER_END_DATE          IN     DATE,
   X_OPTION_ACTION_DATE            IN     DATE,
   X_OPTION_COST                   IN     VARCHAR2,
   X_OPTION_AREA_CHANGE            IN     NUMBER,
   X_OPTION_REFERENCE              IN     VARCHAR2,
   X_OPTION_NOTICE_REQD            IN     VARCHAR2,
   X_OPTION_COMMENTS               IN     VARCHAR2
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_options_all
      WHERE  option_id = x_option_id
      FOR UPDATE OF option_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.LOCK_ROW (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.OPTION_ID = X_OPTION_ID) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_ID',tlinfo.OPTION_ID);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.OPTION_NUM = X_OPTION_NUM) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_NUM',tlinfo.OPTION_NUM);
   END IF;

   IF NOT (tlinfo.OPTION_TYPE_CODE = X_OPTION_TYPE_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_TYPE_CODE',tlinfo.OPTION_TYPE_CODE);
   END IF;

   IF NOT ((tlinfo.START_DATE = X_START_DATE)
       OR ((tlinfo.START_DATE IS NULL) AND (X_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('START_DATE',tlinfo.START_DATE);
   END IF;

   IF NOT ((tlinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
       OR ((tlinfo.EXPIRATION_DATE IS NULL) AND (X_EXPIRATION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPIRATION_DATE',tlinfo.EXPIRATION_DATE);
   END IF;

   IF NOT ((tlinfo.OPTION_SIZE = X_OPTION_SIZE)
       OR ((tlinfo.OPTION_SIZE IS NULL) AND (X_OPTION_SIZE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_SIZE',tlinfo.OPTION_SIZE);
   END IF;

   IF NOT ((tlinfo.UOM_CODE = X_UOM_CODE)
       OR ((tlinfo.UOM_CODE IS NULL) AND (X_UOM_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('UOM_CODE',tlinfo.UOM_CODE);
   END IF;

   IF NOT ((tlinfo.OPTION_STATUS_LOOKUP_CODE = X_OPTION_STATUS_LOOKUP_CODE)
       OR ((tlinfo.OPTION_STATUS_LOOKUP_CODE IS NULL) AND (X_OPTION_STATUS_LOOKUP_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_STATUS_LOOKUP_CODE',tlinfo.OPTION_STATUS_LOOKUP_CODE);
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

   IF NOT ((tlinfo.OPTION_EXER_START_DATE = X_OPTION_EXER_START_DATE)
       OR ((tlinfo.OPTION_EXER_START_DATE IS NULL) AND (X_OPTION_EXER_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_EXER_START_DATE',tlinfo.OPTION_EXER_START_DATE);
   END IF;

   IF NOT ((tlinfo.OPTION_EXER_END_DATE = X_OPTION_EXER_END_DATE)
       OR ((tlinfo.OPTION_EXER_END_DATE IS NULL) AND (X_OPTION_EXER_END_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_EXER_END_DATE',tlinfo.OPTION_EXER_END_DATE);
   END IF;

   IF NOT ((tlinfo.OPTION_ACTION_DATE = X_OPTION_ACTION_DATE)
       OR ((tlinfo.OPTION_ACTION_DATE IS NULL) AND (X_OPTION_ACTION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_ACTION_DATE',tlinfo.OPTION_ACTION_DATE);
   END IF;

   IF NOT ((tlinfo.OPTION_COST = X_OPTION_COST)
       OR ((tlinfo.OPTION_COST IS NULL) AND (X_OPTION_COST IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_COST',tlinfo.OPTION_COST);
   END IF;

   IF NOT ((tlinfo.OPTION_AREA_CHANGE = X_OPTION_AREA_CHANGE)
       OR ((tlinfo.OPTION_AREA_CHANGE IS NULL) AND (X_OPTION_AREA_CHANGE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_AREA_CHANGE',tlinfo.OPTION_AREA_CHANGE);
   END IF;

   IF NOT ((tlinfo.OPTION_REFERENCE = X_OPTION_REFERENCE)
       OR ((tlinfo.OPTION_REFERENCE IS NULL) AND (X_OPTION_REFERENCE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_REFERENCE',tlinfo.OPTION_REFERENCE);
   END IF;

   IF NOT ((tlinfo.OPTION_NOTICE_REQD = X_OPTION_NOTICE_REQD)
       OR ((tlinfo.OPTION_NOTICE_REQD IS NULL) AND (X_OPTION_NOTICE_REQD IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_NOTICE_REQD',tlinfo.OPTION_NOTICE_REQD);
   END IF;

   IF NOT ((tlinfo.OPTION_COMMENTS = X_OPTION_COMMENTS)
       OR ((tlinfo.OPTION_COMMENTS IS NULL) AND (X_OPTION_COMMENTS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPTION_COMMENTS',tlinfo.OPTION_COMMENTS);
   END IF;

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.LOCK_ROW (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_options with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row (
   X_OPTION_ID                     IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_OPTION_NUM                    IN     VARCHAR2,
   X_OPTION_TYPE_CODE              IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_OPTION_SIZE                   IN     NUMBER,
   X_UOM_CODE                      IN     VARCHAR2,
   X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
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
   X_LAST_UPDATE_LOGIN             IN     NUMBER,
   X_OPTION_EXER_START_DATE        IN     DATE,
   X_OPTION_EXER_END_DATE          IN     DATE,
   X_OPTION_ACTION_DATE            IN     DATE,
   X_OPTION_COST                   IN     VARCHAR2,
   X_OPTION_AREA_CHANGE            IN     NUMBER,
   X_OPTION_REFERENCE              IN     VARCHAR2,
   X_OPTION_NOTICE_REQD            IN     VARCHAR2,
   X_OPTION_COMMENTS               IN     VARCHAR2
)
IS

   CURSOR c2 IS
      SELECT *
      FROM   pn_options_all
      WHERE  option_id = x_option_id;

   recInfoForHist                  c2%ROWTYPE;
   l_optionHistoryId               NUMBER          := NULL;
   l_leaseStatus                   VARCHAR2(30)    := NULL;

BEGIN
   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.UPDATE_ROW (+)');

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

         SELECT pn_options_history_s.NEXTVAL
         INTO   l_optionHistoryId
         FROM   DUAL;

         INSERT INTO pn_options_history
         (
            option_history_id,
            option_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            lease_id,
            lease_change_id,
            new_lease_change_id,
            option_num,
            option_type_code,
            start_date,
            expiration_date,
            option_size,
            uom_code,
            option_status_lookup_code,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            option_exer_start_date,
            option_exer_end_date,
            option_action_date,
            option_cost,
            option_area_change,
            option_reference,
            option_notice_reqd,
            option_comments
         )
         VALUES
         (
            l_optionHistoryId,
            recInfoForHist.option_id,
            recInfoForHist.last_update_date,
            recInfoForHist.last_updated_by,
            recInfoForHist.creation_date,
            recInfoForHist.created_by,
            recInfoForHist.last_update_login,
            recInfoForHist.lease_id,
            recInfoForHist.lease_change_id,
            x_lease_change_id,
            recInfoForHist.option_num,
            recInfoForHist.option_type_code,
            recInfoForHist.start_date,
            recInfoForHist.expiration_date,
            recInfoForHist.option_size,
            recInfoForHist.uom_code,
            recInfoForHist.option_status_lookup_code,
            recInfoForHist.attribute_category,
            recInfoForHist.attribute1,
            recInfoForHist.attribute2,
            recInfoForHist.attribute3,
            recInfoForHist.attribute4,
            recInfoForHist.attribute5,
            recInfoForHist.attribute6,
            recInfoForHist.attribute7,
            recInfoForHist.attribute8,
            recInfoForHist.attribute9,
            recInfoForHist.attribute10,
            recInfoForHist.attribute11,
            recInfoForHist.attribute12,
            recInfoForHist.attribute13,
            recInfoForHist.attribute14,
            recInfoForHist.attribute15,
            recInfoForHist.option_exer_start_date,
            recInfoForHist.option_exer_end_date,
            recInfoForHist.option_action_date,
            recInfoForHist.option_cost,
            recInfoForHist.option_area_change,
            recInfoForHist.option_reference,
            recInfoForHist.option_notice_reqd,
            recInfoForHist.option_comments
         );
      END IF;
   END IF;

   UPDATE pn_options_all
   SET    lease_id                        = x_lease_id,
          lease_change_id                 = x_lease_change_id,
          option_num                      = x_option_num,
          option_type_code                = x_option_type_code,
          start_date                      = x_start_date,
          expiration_date                 = x_expiration_date,
          option_size                     = x_option_size,
          uom_code                        = x_uom_code,
          option_status_lookup_code       = x_option_status_lookup_code,
          attribute_category              = x_attribute_category,
          attribute1                      = x_attribute1,
          attribute2                      = x_attribute2,
          attribute3                      = x_attribute3,
          attribute4                      = x_attribute4,
          attribute5                      = x_attribute5,
          attribute6                      = x_attribute6,
          attribute7                      = x_attribute7,
          attribute8                      = x_attribute8,
          attribute9                      = x_attribute9,
          attribute10                     = x_attribute10,
          attribute11                     = x_attribute11,
          attribute12                     = x_attribute12,
          attribute13                     = x_attribute13,
          attribute14                     = x_attribute14,
          attribute15                     = x_attribute15,
          option_id                       = x_option_id,
          last_update_date                = x_last_update_date,
          last_updated_by                 = x_last_updated_by,
          last_update_login               = x_last_update_login,
          option_exer_start_date          = x_option_exer_start_date,
          option_exer_end_date            = x_option_exer_end_date,
          option_action_date              = x_option_action_date,
          option_cost                     = x_option_cost,
          option_area_change              = x_option_area_change,
          option_reference                = x_option_reference,
          option_notice_reqd              = x_option_notice_reqd,
          option_comments                 = x_option_comments
   WHERE  option_id                       = x_option_id ;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.UPDATE_ROW (-)');

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_options with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   x_option_id  IN     NUMBER
)
IS
BEGIN

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.DELETE_ROW (+)');

   DELETE FROM pn_options_all
   WHERE option_id = x_option_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_OPTIONS_PKG.DELETE_ROW (-)');

END Delete_Row;

END pn_options_pkg;

/
