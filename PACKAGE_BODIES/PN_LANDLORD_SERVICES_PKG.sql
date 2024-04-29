--------------------------------------------------------
--  DDL for Package Body PN_LANDLORD_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LANDLORD_SERVICES_PKG" AS
  -- $Header: PNTLNSRB.pls 120.2 2005/12/01 07:41:40 appldev ship $
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_landlord_services with
--                       _ALL table.
-- 01-DEC-05  pikhar   o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_LANDLORD_SERVICE_ID           IN OUT NOCOPY NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_END_DATE                      IN     DATE,
   X_STATUS                        IN     VARCHAR2,
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
   X_OBLIGATION_NUM                IN OUT NOCOPY VARCHAR2,
   X_RESPONSIBILITY_CODE           IN     VARCHAR2,
   X_COMMON_AREA_RESP              IN     VARCHAR2,
   X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
   X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
   X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
   X_COMPANY_ID                    IN     NUMBER,
   X_OBLIGATION_REFERENCE          IN     VARCHAR2,
   X_OBLIGATION_COMMENTS           IN     VARCHAR2,
   x_org_id                        IN     NUMBER
)
IS

   CURSOR c IS
      SELECT ROWID
      FROM   pn_landlord_services_all
      WHERE  landlord_service_id = x_landlord_service_id;

   CURSOR org_cur IS
     SELECT org_id
     FROM pn_leases_all
     WHERE lease_id = x_lease_id;

   l_org_id NUMBER;


BEGIN

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Insert_Row (+)');

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;


   /*-------------------------------------------------------
   -- We need to generate the obligation number
   -------------------------------------------------------*/
   SELECT NVL(MAX(TO_NUMBER(pls.obligation_num)), 0)+1
   INTO   x_obligation_num
   FROM   pn_landlord_services_all  pls
   WHERE  pls.lease_id = x_lease_id;

   /*-------------------------------------------------------
   -- SELECT the nextval for landlord service id
   -------------------------------------------------------*/
   IF ( x_landlord_service_id IS NULL) THEN
      SELECT pn_landlord_services_s.NEXTVAL
      INTO   x_landlord_service_id
      FROM   DUAL;
   END IF;

   INSERT INTO pn_landlord_services_all
   (
      LANDLORD_SERVICE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LEASE_ID,
      LEASE_CHANGE_ID,
      SERVICE_TYPE_LOOKUP_CODE,
      START_DATE,
      END_DATE,
      STATUS,
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
      OBLIGATION_NUM,
      RESPONSIBILITY_CODE,
      COMMON_AREA_RESP,
      FINANCIAL_RESP_PARTY_CODE,
      FINANCIAL_PCT_RESP,
      RESPONSIBILITY_MAINT,
      COMPANY_ID,
      OBLIGATION_REFERENCE,
      OBLIGATION_COMMENTS,
      org_id
   )
   VALUES
   (
      X_LANDLORD_SERVICE_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LEASE_ID,
      X_LEASE_CHANGE_ID,
      X_SERVICE_TYPE_LOOKUP_CODE,
      X_START_DATE,
      X_END_DATE,
      X_STATUS,
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
      X_OBLIGATION_NUM,
      X_RESPONSIBILITY_CODE,
      X_COMMON_AREA_RESP,
      X_FINANCIAL_RESP_PARTY_CODE,
      X_FINANCIAL_PCT_RESP,
      X_RESPONSIBILITY_MAINT,
      X_COMPANY_ID,
      X_OBLIGATION_REFERENCE,
      X_OBLIGATION_COMMENTS,
      l_org_id
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Insert_Row (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_landlord_services with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
   X_LANDLORD_SERVICE_ID           IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_END_DATE                      IN     DATE,
   X_STATUS                        IN     VARCHAR2,
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
   X_OBLIGATION_NUM                IN     VARCHAR2,
   X_RESPONSIBILITY_CODE           IN     VARCHAR2,
   X_COMMON_AREA_RESP              IN     VARCHAR2,
   X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
   X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
   X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
   X_COMPANY_ID                    IN     NUMBER,
   X_OBLIGATION_REFERENCE          IN     VARCHAR2,
   X_OBLIGATION_COMMENTS           IN     VARCHAR2
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_landlord_services_all
      WHERE  landlord_service_id = x_landlord_service_id
      FOR UPDATE OF landlord_service_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Lock_Row (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.LANDLORD_SERVICE_ID = X_LANDLORD_SERVICE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LANDLORD_SERVICE_ID',tlinfo.LANDLORD_SERVICE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.SERVICE_TYPE_LOOKUP_CODE = X_SERVICE_TYPE_LOOKUP_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('SERVICE_TYPE_LOOKUP_CODE',tlinfo.SERVICE_TYPE_LOOKUP_CODE);
   END IF;

   IF NOT ((tlinfo.START_DATE = X_START_DATE)
       OR ((tlinfo.START_DATE IS NULL) AND (X_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('START_DATE',tlinfo.START_DATE);
   END IF;

   IF NOT ((tlinfo.END_DATE = X_END_DATE)
       OR ((tlinfo.END_DATE IS NULL) AND (X_END_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('END_DATE',tlinfo.END_DATE);
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

   IF NOT ((tlinfo.OBLIGATION_NUM = X_OBLIGATION_NUM)
       OR ((tlinfo.OBLIGATION_NUM IS NULL) AND (X_OBLIGATION_NUM IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OBLIGATION_NUM',tlinfo.OBLIGATION_NUM);
   END IF;

   IF NOT ((tlinfo.RESPONSIBILITY_CODE = X_RESPONSIBILITY_CODE)
       OR ((tlinfo.RESPONSIBILITY_CODE IS NULL) AND (X_RESPONSIBILITY_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RESPONSIBILITY_CODE',tlinfo.RESPONSIBILITY_CODE);
   END IF;

   IF NOT ((tlinfo.COMMON_AREA_RESP = X_COMMON_AREA_RESP)
       OR ((tlinfo.COMMON_AREA_RESP IS NULL) AND (X_COMMON_AREA_RESP IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('COMMON_AREA_RESP',tlinfo.COMMON_AREA_RESP);
   END IF;

   IF NOT ((tlinfo.FINANCIAL_RESP_PARTY_CODE = X_FINANCIAL_RESP_PARTY_CODE)
       OR ((tlinfo.FINANCIAL_RESP_PARTY_CODE IS NULL) AND (X_FINANCIAL_RESP_PARTY_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('FINANCIAL_RESP_PARTY_CODE',tlinfo.FINANCIAL_RESP_PARTY_CODE);
   END IF;

   IF NOT ((tlinfo.FINANCIAL_PCT_RESP = X_FINANCIAL_PCT_RESP)
       OR ((tlinfo.FINANCIAL_PCT_RESP IS NULL) AND (X_FINANCIAL_PCT_RESP IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('FINANCIAL_PCT_RESP',tlinfo.FINANCIAL_PCT_RESP);
   END IF;

   IF NOT ((tlinfo.RESPONSIBILITY_MAINT = X_RESPONSIBILITY_MAINT)
       OR ((tlinfo.RESPONSIBILITY_MAINT IS NULL) AND (X_RESPONSIBILITY_MAINT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RESPONSIBILITY_MAINT',tlinfo.RESPONSIBILITY_MAINT);
   END IF;

   IF NOT ((tlinfo.COMPANY_ID = X_COMPANY_ID)
       OR ((tlinfo.COMPANY_ID IS NULL) AND (X_COMPANY_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('COMPANY_ID',tlinfo.COMPANY_ID);
   END IF;

   IF NOT ((tlinfo.OBLIGATION_REFERENCE = X_OBLIGATION_REFERENCE)
       OR ((tlinfo.OBLIGATION_REFERENCE IS NULL) AND (X_OBLIGATION_REFERENCE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OBLIGATION_REFERENCE',tlinfo.OBLIGATION_REFERENCE);
   END IF;

   IF NOT ((tlinfo.OBLIGATION_COMMENTS = X_OBLIGATION_COMMENTS)
       OR ((tlinfo.OBLIGATION_COMMENTS IS NULL) AND (X_OBLIGATION_COMMENTS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OBLIGATION_COMMENTS',tlinfo.OBLIGATION_COMMENTS);
   END IF;

   RETURN;

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Lock_Row (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_landlord_services with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
   X_LANDLORD_SERVICE_ID           IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
   X_START_DATE                    IN     DATE,
   X_END_DATE                      IN     DATE,
   X_STATUS                        IN     VARCHAR2,
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
   X_OBLIGATION_NUM                IN     VARCHAR2,
   X_RESPONSIBILITY_CODE           IN     VARCHAR2,
   X_COMMON_AREA_RESP              IN     VARCHAR2,
   X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
   X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
   X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
   X_COMPANY_ID                    IN     NUMBER,
   X_OBLIGATION_REFERENCE          IN     VARCHAR2,
   X_OBLIGATION_COMMENTS           IN     VARCHAR2
)
IS
   CURSOR c2 IS
      SELECT  *
      FROM    pn_landlord_services_all
      WHERE   landlord_service_id = x_landlord_service_id;

   recInfoForHist c2%ROWTYPE;

   l_llserviceHistoryId    NUMBER          := NULL;
   l_leaseStatus           VARCHAR2(30)    := NULL;

BEGIN

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Update_Row (+)');
   /*---------------------------------------------------------------
   -- get the lease status
   ---------------------------------------------------------------*/
   l_leaseStatus := PNP_UTIL_FUNC.GET_LEASE_STATUS (X_LEASE_ID);

   /*---------------------------------------------------------------
   -- We need to INSERT the history row IF the lease IS finalised
   ---------------------------------------------------------------*/
   IF (l_leaseStatus = 'F')  THEN

      OPEN c2;
         FETCH c2 INTO recInfoForHist;
         IF (c2%NOTFOUND) THEN
            CLOSE c2;
            RAISE NO_DATA_FOUND;
         END IF;
      CLOSE c2;

      IF (recInfoForHist.LEASE_CHANGE_ID <> X_LEASE_CHANGE_ID) THEN

         SELECT  PN_LANDLORD_SERVICE_HISTORY_S.NEXTVAL
         INTO    l_llserviceHistoryId
         FROM    DUAL;

         INSERT INTO PN_LANDLORD_SERVICE_HISTORY
         (
            LANDLORD_SERVICE_HISTORY_ID,
            LANDLORD_SERVICE_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            LEASE_ID,
            LEASE_CHANGE_ID,
            NEW_LEASE_CHANGE_ID,
            SERVICE_TYPE_LOOKUP_CODE,
            START_DATE,
            END_DATE,
            STATUS,
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
            OBLIGATION_NUM,
            RESPONSIBILITY_CODE,
            COMMON_AREA_RESP,
            FINANCIAL_RESP_PARTY_CODE,
            FINANCIAL_PCT_RESP,
            RESPONSIBILITY_MAINT,
            COMPANY_ID,
            OBLIGATION_REFERENCE,
            OBLIGATION_COMMENTS
         )
         VALUES
         (
            l_llserviceHistoryId,
            recInfoForHist.LANDLORD_SERVICE_ID,
            recInfoForHist.LAST_UPDATE_DATE,
            recInfoForHist.LAST_UPDATED_BY,
            recInfoForHist.CREATION_DATE,
            recInfoForHist.CREATED_BY,
            recInfoForHist.LAST_UPDATE_LOGIN,
            recInfoForHist.LEASE_ID,
            recInfoForHist.LEASE_CHANGE_ID,
            X_LEASE_CHANGE_ID,
            recInfoForHist.SERVICE_TYPE_LOOKUP_CODE,
            recInfoForHist.START_DATE,
            recInfoForHist.END_DATE,
            recInfoForHist.STATUS,
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
            recInfoForHist.OBLIGATION_NUM,
            recInfoForHist.RESPONSIBILITY_CODE,
            recInfoForHist.COMMON_AREA_RESP,
            recInfoForHist.FINANCIAL_RESP_PARTY_CODE,
            recInfoForHist.FINANCIAL_PCT_RESP,
            recInfoForHist.RESPONSIBILITY_MAINT,
            recInfoForHist.COMPANY_ID,
            recInfoForHist.OBLIGATION_REFERENCE,
            recInfoForHist.OBLIGATION_COMMENTS
         );

      END IF;
   END IF;

   UPDATE PN_LANDLORD_SERVICES_ALL
   SET    LEASE_ID                        = X_LEASE_ID,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          SERVICE_TYPE_LOOKUP_CODE        = X_SERVICE_TYPE_LOOKUP_CODE,
          START_DATE                      = X_START_DATE,
          END_DATE                        = X_END_DATE,
          STATUS                          = X_STATUS,
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
          LANDLORD_SERVICE_ID             = X_LANDLORD_SERVICE_ID,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          OBLIGATION_NUM                  = X_OBLIGATION_NUM,
          RESPONSIBILITY_CODE             = X_RESPONSIBILITY_CODE,
          COMMON_AREA_RESP                = X_COMMON_AREA_RESP,
          FINANCIAL_RESP_PARTY_CODE       = X_FINANCIAL_RESP_PARTY_CODE,
          FINANCIAL_PCT_RESP              = X_FINANCIAL_PCT_RESP,
          RESPONSIBILITY_MAINT            = X_RESPONSIBILITY_MAINT,
          COMPANY_ID                      = X_COMPANY_ID,
          OBLIGATION_REFERENCE            = X_OBLIGATION_REFERENCE,
          OBLIGATION_COMMENTS             = X_OBLIGATION_COMMENTS
   WHERE  LANDLORD_SERVICE_ID             = X_LANDLORD_SERVICE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Update_Row (-)');

END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_landlord_services with
--                       _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_LANDLORD_SERVICE_ID   IN     NUMBER
)
IS
BEGIN

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Delete_Row (+)');

   DELETE FROM pn_landlord_services_all
   WHERE  landlord_service_id = x_landlord_service_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_LANDLORD_SERVICES_PKG.Delete_Row (-)');

END Delete_Row;

END pn_landlord_services_pkg;

/
