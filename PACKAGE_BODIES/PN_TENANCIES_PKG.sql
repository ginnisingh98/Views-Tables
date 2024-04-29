--------------------------------------------------------
--  DDL for Package Body PN_TENANCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_TENANCIES_PKG" AS
-- $Header: PNTTENTB.pls 120.9 2007/07/06 07:34:05 rdonthul ship $

TYPE loc_info_rec IS
   RECORD (active_start_date               pn_locations.active_start_date%TYPE,
           active_end_date                 pn_locations.active_end_date%TYPE,
           assignable_area                 pn_locations.assignable_area%TYPE);

TYPE loc_info_type IS
   TABLE OF loc_info_rec
   INDEX BY BINARY_INTEGER;

loc_info_tbl loc_info_type;

------------------------------------------------------------------------------------
-- 22-AUG-2003 Satish Tripathi o Fixed for BUG# 3085758, Added fin_oblig_end_date.
------------------------------------------------------------------------------------
TYPE space_assign_info_rec IS
   RECORD (cust_assign_start_date          pn_space_assign_cust.cust_assign_start_date%TYPE,
           cust_assign_end_date            pn_space_assign_cust.cust_assign_end_date%TYPE,
           fin_oblig_end_date              pn_space_assign_cust.fin_oblig_end_date%TYPE,
           allocated_area                  pn_space_assign_cust.allocated_area%TYPE,
           allocated_area_pct              pn_space_assign_cust_all.allocated_area_pct%TYPE);

TYPE space_assign_info_type IS
   TABLE OF space_assign_info_rec
   INDEX BY BINARY_INTEGER;

space_assign_info_tbl space_assign_info_type;

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 11-SEP-02  STripathi o If returnStatus = 'W', return parameter
--                        x_tenancy_ovelap_wrn 'Y' for Multi-Tenancy-Lease changes.
-- 16-JAN-02  PSidhu    o bug#2730279 - Removed call to
--                        pn_tenancies_pkg.check_unique_primary_location.
-- 04-DEC-04  ftanudja  o Added 8 parameters for lease rentable area. 3257508.
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_tenancies with _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row
(
   X_ROWID                         IN OUT NOCOPY VARCHAR2,
   X_TENANCY_ID                    IN OUT NOCOPY NUMBER,
   X_LOCATION_ID                   IN            NUMBER,
   X_LEASE_ID                      IN            NUMBER,
   X_LEASE_CHANGE_ID               IN            NUMBER,
   X_TENANCY_USAGE_LOOKUP_CODE     IN            VARCHAR2,
   X_PRIMARY_FLAG                  IN            VARCHAR2,
   X_ESTIMATED_OCCUPANCY_DATE      IN            DATE,
   X_OCCUPANCY_DATE                IN            DATE,
   X_EXPIRATION_DATE               IN            DATE,
   X_ASSIGNABLE_FLAG               IN            VARCHAR2,
   X_SUBLEASEABLE_FLAG             IN            VARCHAR2,
   X_TENANTS_PROPORTIONATE_SHARE   IN            NUMBER,
   X_ALLOCATED_AREA_PCT            IN            NUMBER,
   X_ALLOCATED_AREA                IN            NUMBER,
   X_STATUS                        IN            VARCHAR2,
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
   X_CREATION_DATE                 IN            DATE,
   X_CREATED_BY                    IN            NUMBER,
   X_LAST_UPDATE_DATE              IN            DATE,
   X_LAST_UPDATED_BY               IN            NUMBER,
   X_LAST_UPDATE_LOGIN             IN            NUMBER,
   X_ORG_ID                        IN            NUMBER,
   X_TENANCY_OVELAP_WRN            OUT NOCOPY    VARCHAR2,
   X_RECOVERY_TYPE_CODE            IN            VARCHAR2,
   X_RECOVERY_SPACE_STD_CODE       IN            VARCHAR2,
   X_FIN_OBLIG_END_DATE            IN            DATE,
   X_CUSTOMER_ID                   IN            NUMBER,
   X_CUSTOMER_SITE_USE_ID          IN            NUMBER,
   X_LEASE_RENTABLE_AREA           IN            NUMBER,
   X_LEASE_USABLE_AREA             IN            NUMBER,
   X_LEASE_ASSIGNABLE_AREA         IN            NUMBER,
   X_LEASE_LOAD_FACTOR             IN            NUMBER,
   X_LOCATION_RENTABLE_AREA        IN            NUMBER,
   X_LOCATION_USABLE_AREA          IN            NUMBER,
   X_LOCATION_ASSIGNABLE_AREA      IN            NUMBER,
   X_LOCATION_LOAD_FACTOR          IN            NUMBER
)
IS
   CURSOR C IS
     SELECT ROWID
     FROM   pn_tenancies_all
     WHERE  tenancy_id = x_tenancy_id;

   l_returnStatus  VARCHAR2(30)  := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all
    WHERE  lease_id = x_lease_id;

   l_org_id NUMBER;



BEGIN

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.INSERT_ROW (+)');


   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   x_tenancy_ovelap_wrn := NULL;

   ---------------------------------------------------
   -- Check tenancy dates
   ---------------------------------------------------
   l_returnStatus        := NULL;
   PN_TENANCIES_PKG.CHECK_TENANCY_DATES
   (
       l_returnStatus
      ,X_ESTIMATED_OCCUPANCY_DATE
      ,X_OCCUPANCY_DATE
      ,X_EXPIRATION_DATE
   );
   IF (l_returnStatus IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;

   ---------------------------------------------------
   -- Check IF the tenancy dates overlap
   ---------------------------------------------------
   l_returnStatus        := NULL;
   PN_TENANCIES_PKG.CHECK_FOR_OVELAP_OF_TENANCY
   (
       l_returnStatus
      ,X_TENANCY_ID
      ,X_LOCATION_ID
      ,X_LEASE_ID
      ,X_ESTIMATED_OCCUPANCY_DATE
      ,X_OCCUPANCY_DATE
      ,X_EXPIRATION_DATE
   );
   IF (l_returnStatus = 'W') THEN
      x_tenancy_ovelap_wrn := 'Y';
   ELSIF (l_returnStatus IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;


   ---------------------------------------------------
   -- Assign Nextval WHEN argument value IS passed
   -- as NULL
   ---------------------------------------------------
   IF x_tenancy_ID IS NULL THEN

      SELECT  pn_tenancies_s.NEXTVAL
      INTO    x_tenancy_id
      FROM    DUAL;

   END IF;

   INSERT INTO pn_tenancies_all
   (
       TENANCY_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LOCATION_ID,
       LEASE_ID,
       LEASE_CHANGE_ID,
       TENANCY_USAGE_LOOKUP_CODE,
       PRIMARY_FLAG,
       ESTIMATED_OCCUPANCY_DATE,
       OCCUPANCY_DATE,
       EXPIRATION_DATE,
       ASSIGNABLE_FLAG,
       SUBLEASEABLE_FLAG,
       TENANTS_PROPORTIONATE_SHARE,
       ALLOCATED_AREA_PCT,
       ALLOCATED_AREA,
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
       ORG_ID,
       RECOVERY_TYPE_CODE,
       RECOVERY_SPACE_STD_CODE,
       FIN_OBLIG_END_DATE,
       CUSTOMER_ID,
       CUSTOMER_SITE_USE_ID,
       LEASE_RENTABLE_AREA,
       LEASE_USABLE_AREA,
       LEASE_ASSIGNABLE_AREA,
       LEASE_LOAD_FACTOR,
       LOCATION_RENTABLE_AREA,
       LOCATION_USABLE_AREA,
       LOCATION_ASSIGNABLE_AREA,
       LOCATION_LOAD_FACTOR
   )
   VALUES
   (
       X_TENANCY_ID,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_LOCATION_ID,
       X_LEASE_ID,
       X_LEASE_CHANGE_ID,
       X_TENANCY_USAGE_LOOKUP_CODE,
       X_PRIMARY_FLAG,
       X_ESTIMATED_OCCUPANCY_DATE,
       X_OCCUPANCY_DATE,
       X_EXPIRATION_DATE,
       X_ASSIGNABLE_FLAG,
       X_SUBLEASEABLE_FLAG,
       X_TENANTS_PROPORTIONATE_SHARE,
       X_ALLOCATED_AREA_PCT,
       X_ALLOCATED_AREA,
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
       l_ORG_ID,
       X_RECOVERY_TYPE_CODE,
       X_RECOVERY_SPACE_STD_CODE,
       X_FIN_OBLIG_END_DATE,
       X_CUSTOMER_ID,
       X_CUSTOMER_SITE_USE_ID,
       X_LEASE_RENTABLE_AREA,
       X_LEASE_USABLE_AREA,
       X_LEASE_ASSIGNABLE_AREA,
       X_LEASE_LOAD_FACTOR,
       X_LOCATION_RENTABLE_AREA,
       X_LOCATION_USABLE_AREA,
       X_LOCATION_ASSIGNABLE_AREA,
       X_LOCATION_LOAD_FACTOR
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.INSERT_ROW (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-DEC-04 ftanudja o Added 8 parameters for lease rentable area. 3257508.
-- 10-FEB-04 ftanudja o Removed locn areas (4 params).
-- 05-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_tenancies with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row
(
   X_TENANCY_ID                    IN     NUMBER,
   X_LOCATION_ID                   IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_TENANCY_USAGE_LOOKUP_CODE     IN     VARCHAR2,
   X_PRIMARY_FLAG                  IN     VARCHAR2,
   X_ESTIMATED_OCCUPANCY_DATE      IN     DATE,
   X_OCCUPANCY_DATE                IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_ASSIGNABLE_FLAG               IN     VARCHAR2,
   X_SUBLEASEABLE_FLAG             IN     VARCHAR2,
   X_TENANTS_PROPORTIONATE_SHARE   IN     NUMBER,
   X_ALLOCATED_AREA_PCT            IN     NUMBER,
   X_ALLOCATED_AREA                IN     NUMBER,
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
   X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
   X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
   X_FIN_OBLIG_END_DATE            IN     DATE,
   X_CUSTOMER_ID                   IN     NUMBER,
   X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
   X_LEASE_RENTABLE_AREA           IN     NUMBER,
   X_LEASE_USABLE_AREA             IN     NUMBER,
   X_LEASE_ASSIGNABLE_AREA         IN     NUMBER,
   X_LEASE_LOAD_FACTOR             IN     NUMBER
)
IS
   CURSOR c1 IS
      SELECT *
      FROM   pn_tenancies_all
      WHERE  tenancy_id = x_tenancy_id
      FOR    UPDATE OF tenancy_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.LOCK_ROW (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.TENANCY_ID = X_TENANCY_ID) THEN
      pn_var_rent_pkg.lock_row_exception('TENANCY_ID',tlinfo.TENANCY_ID);
   END IF;

   IF NOT (tlinfo.LOCATION_ID = X_LOCATION_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.LOCATION_ID);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.TENANCY_USAGE_LOOKUP_CODE = X_TENANCY_USAGE_LOOKUP_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('TENANCY_USAGE_LOOKUP_CODE',tlinfo.TENANCY_USAGE_LOOKUP_CODE);
   END IF;

   IF NOT (tlinfo.PRIMARY_FLAG = X_PRIMARY_FLAG) THEN
      pn_var_rent_pkg.lock_row_exception('PRIMARY_FLAG',tlinfo.PRIMARY_FLAG);
   END IF;

   IF NOT ((tlinfo.ESTIMATED_OCCUPANCY_DATE = X_ESTIMATED_OCCUPANCY_DATE)
       OR ((tlinfo.ESTIMATED_OCCUPANCY_DATE IS NULL) AND (X_ESTIMATED_OCCUPANCY_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ESTIMATED_OCCUPANCY_DATE',tlinfo.ESTIMATED_OCCUPANCY_DATE);
   END IF;

   IF NOT ((tlinfo.OCCUPANCY_DATE = X_OCCUPANCY_DATE)
       OR ((tlinfo.OCCUPANCY_DATE IS NULL) AND (X_OCCUPANCY_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OCCUPANCY_DATE',tlinfo.OCCUPANCY_DATE);
   END IF;

   IF NOT ((tlinfo.EXPIRATION_DATE = X_EXPIRATION_DATE)
       OR ((tlinfo.EXPIRATION_DATE IS NULL) AND (X_EXPIRATION_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPIRATION_DATE',tlinfo.EXPIRATION_DATE);
   END IF;

   IF NOT ((tlinfo.ASSIGNABLE_FLAG = X_ASSIGNABLE_FLAG)
       OR ((tlinfo.ASSIGNABLE_FLAG IS NULL) AND (X_ASSIGNABLE_FLAG IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ASSIGNABLE_FLAG',tlinfo.ASSIGNABLE_FLAG);
   END IF;

   IF NOT ((tlinfo.SUBLEASEABLE_FLAG = X_SUBLEASEABLE_FLAG)
       OR ((tlinfo.SUBLEASEABLE_FLAG IS NULL) AND (X_SUBLEASEABLE_FLAG IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('SUBLEASEABLE_FLAG',tlinfo.SUBLEASEABLE_FLAG);
   END IF;

   IF NOT ((tlinfo.TENANTS_PROPORTIONATE_SHARE = X_TENANTS_PROPORTIONATE_SHARE)
       OR ((tlinfo.TENANTS_PROPORTIONATE_SHARE IS NULL) AND (X_TENANTS_PROPORTIONATE_SHARE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TENANTS_PROPORTIONATE_SHARE',tlinfo.TENANTS_PROPORTIONATE_SHARE);
   END IF;

   IF NOT ((tlinfo.STATUS = X_STATUS)
       OR ((tlinfo.STATUS IS NULL) AND (X_STATUS IS NULL))) THEN
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

   IF NOT ((tlinfo.RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE)
       OR ((tlinfo.RECOVERY_TYPE_CODE IS NULL) AND (X_RECOVERY_TYPE_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECOVERY_TYPE_CODE',tlinfo.RECOVERY_TYPE_CODE);
   END IF;

   IF NOT ((tlinfo.RECOVERY_SPACE_STD_CODE = X_RECOVERY_SPACE_STD_CODE)
       OR ((tlinfo.RECOVERY_SPACE_STD_CODE IS NULL) AND (X_RECOVERY_SPACE_STD_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECOVERY_SPACE_STD_CODE',tlinfo.RECOVERY_SPACE_STD_CODE);
   END IF;

   IF NOT ((tlinfo.FIN_OBLIG_END_DATE = X_FIN_OBLIG_END_DATE)
       OR ((tlinfo.FIN_OBLIG_END_DATE IS NULL) AND (X_FIN_OBLIG_END_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('FIN_OBLIG_END_DATE',tlinfo.FIN_OBLIG_END_DATE);
   END IF;

   IF NOT ((tlinfo.CUSTOMER_ID = X_CUSTOMER_ID)
       OR ((tlinfo.CUSTOMER_ID IS NULL) AND (X_CUSTOMER_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_ID',tlinfo.CUSTOMER_ID);
   END IF;

   IF NOT ((tlinfo.CUSTOMER_SITE_USE_ID = X_CUSTOMER_SITE_USE_ID)
       OR ((tlinfo.CUSTOMER_SITE_USE_ID IS NULL) AND (X_CUSTOMER_SITE_USE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_SITE_USE_ID',tlinfo.CUSTOMER_SITE_USE_ID);
   END IF;

   IF NOT ((tlinfo.LEASE_RENTABLE_AREA = X_LEASE_RENTABLE_AREA)
       OR ((tlinfo.LEASE_RENTABLE_AREA IS NULL) AND (X_LEASE_RENTABLE_AREA IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_RENTABLE_AREA',tlinfo.LEASE_RENTABLE_AREA);
   END IF;

   IF NOT ((tlinfo.LEASE_USABLE_AREA = X_LEASE_USABLE_AREA)
       OR ((tlinfo.LEASE_USABLE_AREA IS NULL) AND (X_LEASE_USABLE_AREA IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_USABLE_AREA',tlinfo.LEASE_USABLE_AREA);
   END IF;

   IF NOT ((tlinfo.LEASE_ASSIGNABLE_AREA = X_LEASE_ASSIGNABLE_AREA)
       OR ((tlinfo.LEASE_ASSIGNABLE_AREA IS NULL) AND (X_LEASE_ASSIGNABLE_AREA IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ASSIGNABLE_AREA',tlinfo.LEASE_ASSIGNABLE_AREA);
   END IF;

   IF NOT ((tlinfo.LEASE_LOAD_FACTOR = X_LEASE_LOAD_FACTOR)
       OR ((tlinfo.LEASE_LOAD_FACTOR IS NULL) AND (X_LEASE_LOAD_FACTOR IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_LOAD_FACTOR',tlinfo.LEASE_LOAD_FACTOR);
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.LOCK_ROW (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 11-SEP-02  STripathi   o If returnStatus = 'W', return parameter
--                          x_tenancy_ovelap_wrn 'Y' for Multi-Tenancy-Lease changes.
-- 16-JAN-02  Pooja Sidhu o bug#2730279 - Removed call to
--                          pn_tenancies_pkg.check_unique_primary_location.
-- 04-DEC-04  ftanudja    o Added 8 parameters for lease rentable area. 3257508.
-- 05-JUL-05  sdmahesh    o Bug 4284035 - Replaced pn_tenancies with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row
(
   X_TENANCY_ID                    IN     NUMBER,
   X_LOCATION_ID                   IN     NUMBER,
   X_LEASE_ID                      IN     NUMBER,
   X_LEASE_CHANGE_ID               IN     NUMBER,
   X_TENANCY_USAGE_LOOKUP_CODE     IN     VARCHAR2,
   X_PRIMARY_FLAG                  IN     VARCHAR2,
   X_ESTIMATED_OCCUPANCY_DATE      IN     DATE,
   X_OCCUPANCY_DATE                IN     DATE,
   X_EXPIRATION_DATE               IN     DATE,
   X_ASSIGNABLE_FLAG               IN     VARCHAR2,
   X_SUBLEASEABLE_FLAG             IN     VARCHAR2,
   X_TENANTS_PROPORTIONATE_SHARE   IN     NUMBER,
   X_ALLOCATED_AREA_PCT            IN     NUMBER,
   X_ALLOCATED_AREA                IN     NUMBER,
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
   X_TENANCY_OVELAP_WRN            OUT NOCOPY VARCHAR2,
   X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
   X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
   X_FIN_OBLIG_END_DATE            IN     DATE,
   X_CUSTOMER_ID                   IN     NUMBER,
   X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
   X_LEASE_RENTABLE_AREA           IN     NUMBER,
   X_LEASE_USABLE_AREA             IN     NUMBER,
   X_LEASE_ASSIGNABLE_AREA         IN     NUMBER,
   X_LEASE_LOAD_FACTOR             IN     NUMBER,
   X_LOCATION_RENTABLE_AREA        IN     NUMBER,
   X_LOCATION_USABLE_AREA          IN     NUMBER,
   X_LOCATION_ASSIGNABLE_AREA      IN     NUMBER,
   X_LOCATION_LOAD_FACTOR          IN     NUMBER
)
IS

   CURSOR c2 IS
      SELECT  *
      FROM    pn_tenancies_all
      WHERE   tenancy_id = x_tenancy_id;

   recInfoForHist c2%ROWTYPE;

   l_leaseStatus           VARCHAR2(30)    := NULL;
   l_returnStatus          VARCHAR2(30)        := NULL;
BEGIN

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_ROW (+)');

   x_tenancy_ovelap_wrn := NULL;

   ---------------------------------------------------
   -- Check tenancy dates
   ---------------------------------------------------
   l_returnStatus        := NULL;
   PN_TENANCIES_PKG.CHECK_TENANCY_DATES
   (
        l_returnStatus
       ,X_ESTIMATED_OCCUPANCY_DATE
       ,X_OCCUPANCY_DATE
       ,X_EXPIRATION_DATE
   );
   IF (l_returnStatus IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;

   ---------------------------------------------------
   -- Check IF the tenancy dates overlap
   ---------------------------------------------------
   l_returnStatus        := NULL;
   PN_TENANCIES_PKG.CHECK_FOR_OVELAP_OF_TENANCY
   (
        l_returnStatus
       ,X_TENANCY_ID
       ,X_LOCATION_ID
       ,X_LEASE_ID
       ,X_ESTIMATED_OCCUPANCY_DATE
       ,X_OCCUPANCY_DATE
       ,X_EXPIRATION_DATE
   );
   IF (l_returnStatus = 'W') THEN
      x_tenancy_ovelap_wrn := 'Y';
   ELSIF (l_returnStatus IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;

   ----------------------------------------------------
   -- get the lease status
   ----------------------------------------------------
   l_leaseStatus := PNP_UTIL_FUNC.GET_LEASE_STATUS (X_LEASE_ID);

   ---------------------------------------------------------------
   -- We need to INsert the history row IF the lease IS finalised
   ---------------------------------------------------------------
   IF (l_leaseStatus = 'F')  THEN

      OPEN c2;
         FETCH c2 INTO recInfoForHist;
         IF (c2%NOTFOUND) THEN
            CLOSE c2;
            RAISE NO_DATA_FOUND;
         END IF;
      CLOSE c2;

      IF (recInfoForHist.lease_change_id <> x_lease_change_id) THEN

         INSERT INTO PN_TENANCIES_HISTORY
         (
             TENANCY_HISTORY_ID,
             TENANCY_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             LOCATION_ID,
             LEASE_ID,
             LEASE_CHANGE_ID,
             NEW_LEASE_CHANGE_ID,
             TENANCY_USAGE_LOOKUP_CODE,
             PRIMARY_FLAG,
             ESTIMATED_OCCUPANCY_DATE,
             OCCUPANCY_DATE,
             EXPIRATION_DATE,
             ASSIGNABLE_FLAG,
             SUBLEASEABLE_FLAG,
             TENANTS_PROPORTIONATE_SHARE,
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
             ORG_ID,
             RECOVERY_TYPE_CODE,
             RECOVERY_SPACE_STD_CODE,
             FIN_OBLIG_END_DATE,
             CUSTOMER_ID,
             CUSTOMER_SITE_USE_ID,
             LEASE_RENTABLE_AREA,
             LEASE_USABLE_AREA,
             LEASE_ASSIGNABLE_AREA,
             LEASE_LOAD_FACTOR,
             LOCATION_RENTABLE_AREA,
             LOCATION_USABLE_AREA,
             LOCATION_ASSIGNABLE_AREA,
             LOCATION_LOAD_FACTOR
         )
         VALUES
         (
            pn_tenancies_history_s.NEXTVAL,
            recInfoForHist.TENANCY_ID,
            recInfoForHist.LAST_UPDATE_DATE,
            recInfoForHist.LAST_UPDATED_BY,
            recInfoForHist.CREATION_DATE,
            recInfoForHist.CREATED_BY,
            recInfoForHist.LAST_UPDATE_LOGIN,
            recInfoForHist.LOCATION_ID,
            recInfoForHist.LEASE_ID,
            recInfoForHist.LEASE_CHANGE_ID,
            X_LEASE_CHANGE_ID,
            recInfoForHist.TENANCY_USAGE_LOOKUP_CODE,
            recInfoForHist.PRIMARY_FLAG,
            recInfoForHist.ESTIMATED_OCCUPANCY_DATE,
            recInfoForHist.OCCUPANCY_DATE,
            recInfoForHist.EXPIRATION_DATE,
            recInfoForHist.ASSIGNABLE_FLAG,
            recInfoForHist.SUBLEASEABLE_FLAG,
            recInfoForHist.TENANTS_PROPORTIONATE_SHARE,
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
            recInfoForHist.ORG_ID,
            recInfoForHist.RECOVERY_TYPE_CODE,
            recInfoForHist.RECOVERY_SPACE_STD_CODE,
            recInfoForHist.FIN_OBLIG_END_DATE,
            recInfoForHist.CUSTOMER_ID,
            recInfoForHist.CUSTOMER_SITE_USE_ID,
            recInfoForHist.LEASE_RENTABLE_AREA,
            recInfoForHist.LEASE_USABLE_AREA,
            recInfoForHist.LEASE_ASSIGNABLE_AREA,
            recInfoForHist.LEASE_LOAD_FACTOR,
            recInfoForHist.LOCATION_RENTABLE_AREA,
            recInfoForHist.LOCATION_USABLE_AREA,
            recInfoForHist.LOCATION_ASSIGNABLE_AREA,
            recInfoForHist.LOCATION_LOAD_FACTOR
         );
      END IF;
   END IF;

   UPDATE pn_tenancies_all
   SET    LOCATION_ID                     = X_LOCATION_ID,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          TENANCY_USAGE_LOOKUP_CODE       = X_TENANCY_USAGE_LOOKUP_CODE,
          PRIMARY_FLAG                    = X_PRIMARY_FLAG,
          ESTIMATED_OCCUPANCY_DATE        = X_ESTIMATED_OCCUPANCY_DATE,
          OCCUPANCY_DATE                  = X_OCCUPANCY_DATE,
          EXPIRATION_DATE                 = X_EXPIRATION_DATE,
          ASSIGNABLE_FLAG                 = X_ASSIGNABLE_FLAG,
          SUBLEASEABLE_FLAG               = X_SUBLEASEABLE_FLAG,
          TENANTS_PROPORTIONATE_SHARE     = X_TENANTS_PROPORTIONATE_SHARE,
          ALLOCATED_AREA_PCT              = X_ALLOCATED_AREA_PCT,
          ALLOCATED_AREA                  = X_ALLOCATED_AREA,
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
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          RECOVERY_TYPE_CODE              = X_RECOVERY_TYPE_CODE,
          RECOVERY_SPACE_STD_CODE         = X_RECOVERY_SPACE_STD_CODE,
          FIN_OBLIG_END_DATE              = X_FIN_OBLIG_END_DATE,
          CUSTOMER_ID                     = X_CUSTOMER_ID,
          CUSTOMER_SITE_USE_ID            = X_CUSTOMER_SITE_USE_ID,
          LEASE_RENTABLE_AREA             = X_LEASE_RENTABLE_AREA,
          LEASE_USABLE_AREA               = X_LEASE_USABLE_AREA,
          LEASE_ASSIGNABLE_AREA           = X_LEASE_ASSIGNABLE_AREA,
          LEASE_LOAD_FACTOR               = X_LEASE_LOAD_FACTOR,
          LOCATION_RENTABLE_AREA          = X_LOCATION_RENTABLE_AREA,
          LOCATION_USABLE_AREA            = X_LOCATION_USABLE_AREA,
          LOCATION_ASSIGNABLE_AREA        = X_LOCATION_ASSIGNABLE_AREA,
          LOCATION_LOAD_FACTOR            = X_LOCATION_LOAD_FACTOR
   WHERE  TENANCY_ID                      = X_TENANCY_ID ;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_ROW (-)');
END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE Delete_Row
(
   X_TENANCY_ID  IN     NUMBER
)
IS
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.DELETE_ROW (+)');

   DELETE FROM pn_tenancies_all
   WHERE tenancy_id = x_tenancy_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.DELETE_ROW (-)');
END Delete_Row;


-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_UNIQUE_PRIMARY_LOCATION
-- INVOKED FROM :
-- PURPOSE      : checks unique primary location
-- HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE_PRIMARY_LOCATION (
                 X_RETURN_STATUS                 IN OUT NOCOPY VARCHAR2
                ,X_LEASE_ID                      IN     NUMBER
                ,X_TENANCY_ID                    IN     NUMBER
        )
IS
   l_dummy             NUMBER;
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_UNIQUE_PRIMARY_LOCATION (+)');
   BEGIN
      SELECT 1
      INTO   l_dummy
      FROM   DUAL
      WHERE  NOT EXISTS
             (SELECT 1
              FROM   pn_tenancies_all   pnt
              WHERE  pnt.lease_id = x_lease_id
              AND    pnt.status = 'A'
              AND    pnt.primary_flag = 'Y'
              AND    ((x_tenancy_id IS NULL) or (pnt.tenancy_id  <> x_tenancy_id))
             );

   EXCEPTION
      WHEN NO_DATA_FOUND  THEN
         fnd_message.set_name ('PN', 'PN_DUPLEASE_PRIMARY_TENANCY');
         x_return_status := 'E';
   END;

        pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_UNIQUE_PRIMARY_LOCATION (-)');
END CHECK_UNIQUE_PRIMARY_LOCATION;

-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_FOR_OVELAP_OF_TENANCY
-- INVOKED FROM :
-- PURPOSE      : checks for overlap of tenancy
-- HISTORY      :
-- 11-SEP-02 STripathi o If profile option PN_MULTIPLE_LEASE_FOR_LOCATION
--                       is true, return_status should be W (warn) else
--                       return_status is E (error) in Overlap exception
--                       for Multi-Tenancy-Lease changes.
-- 30 OCT-02 graghuna  o added group by to location code select.
-- 08-JUL-03 AKumar    o Replaced calls to fnd_profile.get_value with
--                       pn_mo_cache_utils.get_profile_value
-- 28-nov-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------------------
PROCEDURE CHECK_FOR_OVELAP_OF_TENANCY
(
    X_RETURN_STATUS                 IN OUT NOCOPY VARCHAR2
   ,X_TENANCY_ID                    IN            NUMBER
   ,X_LOCATION_ID                   IN            NUMBER
   ,X_LEASE_ID                      IN            NUMBER
   ,X_ESTIMATED_OCCUPANCY_DATE      IN            DATE
   ,X_OCCUPANCY_DATE                IN            DATE
   ,X_EXPIRATION_DATE               IN            DATE
)
IS

   l_dummy                         NUMBER;
   l_locationCode                  VARCHAR2(255) := NULL;
   l_leaseNumber                   VARCHAR2(30)  := NULL;
   l_parentLeaseId                 NUMBER        := NULL;
   l_LeaseId                       NUMBER        := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all pnl
    WHERE  pnl.lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_FOR_OVELAP_OF_TENANCY (+)');

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   -- we are selecting the location code for err condition
   SELECT location_code
   INTO   l_locationCode
   FROM   pn_locations_all
   WHERE  location_id = x_location_id
   AND    ROWNUM < 2;

   -- we need to find IF the lease has a master lease defined
   SELECT pnl.parent_lease_id
   INTO   l_parentLeaseId
   FROM   pn_leases_all pnl
   WHERE  pnl.lease_id = x_lease_id;

   ----------------------------------------------------------------
   -- i.e. no master lease has been defined THEN it's a vanilla lease
   ----------------------------------------------------------------

   IF (l_parentLeaseId IS NULL) THEN

      --------------------------------------------------------------
      -- Check IF a parent location IS already tied to the lease IN
      -- question AND the user tries to hookup a child location to the
      -- same lease for the same time period. Issue an error. Bug: 920404
      ---------------------------------------------------------------
      BEGIN

         SELECT pnt.lease_id
         INTO   l_LeaseId
         FROM   pn_tenancies_all pnt
         WHERE  pnt.status = 'A'
         AND    pnt.lease_id = x_lease_id
         AND    pnt.location_id IN
                (SELECT b.parent_location_id
                 FROM   pn_locations_all b
                 CONNECT BY b.location_id = PRIOR parent_location_id
                 START WITH b.location_id = x_location_id
                )
         AND    (TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                 BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                         AND TRUNC (x_expiration_date)
                 OR TRUNC(pnt.expiration_date)
                    BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                            AND TRUNC (x_expiration_date)
                )
         AND    ((x_tenancy_id IS NULL) OR (pnt.tenancy_id <> x_tenancy_id)
                )
         AND   ROWNUM < 2;

         fnd_message.set_name ('PN', 'PN_PARENT_LOC_IN_LEASE');
         x_return_status := 'E';

      EXCEPTION
         WHEN NO_DATA_FOUND  THEN -- IF no data was found THEN we don't worry
            NULL;

      END;

      ------------------------------------------------------------
      -- now check IF the dates clash for the location under any
      -- other lease other than this lease's sub-leases
      ------------------------------------------------------------
      BEGIN

         SELECT lease_num
         INTO   l_leaseNumber
         FROM   pn_leases_all
         WHERE  lease_id <> x_lease_id
         AND    parent_lease_id IS NULL
         AND    lease_id =
                (SELECT lease_id
                 FROM   pn_tenancies_all pnt
                 WHERE  pnt.status = 'A'
                 AND    pnt.location_id IN
                        (SELECT a.location_id
                         FROM   pn_locations_all a
                         CONNECT BY PRIOR a.parent_location_id = a.location_id
                         START WITH a.location_id  = x_location_id
                         UNION ALL
                         SELECT  b.location_id
                         FROM    pn_locations_all b
                         CONNECT BY PRIOR b.location_id = b.parent_location_id
                         START WITH b.location_id = x_location_id
                        )
                 AND    (TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                         BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                                 AND TRUNC (x_expiration_date)
                         OR TRUNC(pnt.expiration_date)
                            BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                                    AND TRUNC (x_expiration_date)
                        )
                 AND    ((x_tenancy_id IS NULL) OR (pnt.tenancy_id <> x_tenancy_id))
                 AND    ROWNUM < 2
                );


         IF nvl(pn_mo_cache_utils.get_profile_value('PN_MULTIPLE_LEASE_FOR_LOCATION',l_org_id),'N') <> 'Y' THEN
            fnd_message.set_name ('PN', 'PN_LEASE_TENANCY_OVERLAP');
            fnd_message.set_token ('LOCATION_CODE', l_locationCode);
            fnd_message.set_token ('LEASE_NUMBER',  l_leaseNumber);
            x_return_status := 'E';
         ELSE
            x_return_status := 'W';
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND  THEN
            -- IF no data was found THEN we don't worry
            NULL;
      END;

      IF (x_return_status IS NULL) THEN
         BEGIN
            -- now check IF the new dates will create problem
            -- with dates     IN su-leases for this lease

            SELECT lease_num
            INTO   l_leaseNumber
            FROM   pn_leases_all
            WHERE  parent_lease_id = x_lease_id
            AND    lease_id =
                   (SELECT lease_id
                    FROM   pn_tenancies_all pnt
                    WHERE  pnt.status = 'A'
                    AND    pnt.location_id IN
                           (SELECT  b.location_id
                            FROM    pn_locations_all    b
                            CONNECT BY PRIOR b.location_id = b.parent_location_id
                            START WITH b.location_id  = x_location_id
                           )
                    AND    (TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                            < TRUNC(NVL(x_occupancy_date, x_estimated_occupancy_date))
                            OR TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                               > TRUNC (x_expiration_date)
                            OR TRUNC(pnt.expiration_date)
                               < TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                            OR TRUNC(pnt.expiration_date)
                               > TRUNC (x_expiration_date)
                           )
                    AND    ((x_tenancy_id IS NULL) OR (pnt.tenancy_id <> x_tenancy_id)
                           )
                    AND    ROWNUM        < 2
                   );


            fnd_message.set_name ('PN', 'PN_LEASE_TENANCY_SUBLEASE_DT');
            fnd_message.set_token ('LOCATION_CODE', l_locationCode);
            fnd_message.set_token ('LEASE_NUMBER',  l_leaseNumber);
            x_return_status := 'E';

         EXCEPTION
            WHEN NO_DATA_FOUND  THEN
               -- IF no data was found THEN we don't worry
               NULL;
         END;
      END IF;

      -- i.e. master lease IS defined
   ELSE
      -- this SELECT will verify that the location EXISTS IN the
      -- parent lease AND the dates are within range
      BEGIN
         SELECT location_id
         INTO   l_leaseNumber
         FROM   pn_locations_all
         WHERE  location_id = x_location_id
         AND    location_id IN
                (SELECT  b.location_id
                 FROM    pn_locations_all b
                 CONNECT BY PRIOR b.location_id = b.parent_location_id
                 START WITH b.location_id IN
                            (SELECT pnt.location_id
                             FROM   pn_tenancies_all pnt
                             WHERE  pnt.status = 'A'
                             AND    pnt.lease_id = l_parentLeaseId
                             AND    (TRUNC(NVL(x_occupancy_date, x_estimated_occupancy_date))
                                     BETWEEN TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                                             AND TRUNC(pnt.expiration_date)
                                     AND TRUNC (x_expiration_date)
                                         BETWEEN TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                                                 AND TRUNC(pnt.expiration_date)
                                    )
                            )
                )
         AND ROWNUM < 2;

         -- IF  data was found THEN we don't worry

      EXCEPTION
         WHEN NO_DATA_FOUND  THEN
            fnd_message.set_name('PN', 'PN_LEASE_TENANCY_MASTER_NEXIST');
            fnd_message.set_token('LOCATION_CODE', l_locationCode);
            x_return_status := 'E';
      END;

      -- only IF the location EXISTS IN the master and dates are
      -- perfect, now we need to check that it shouldn't overlap
      -- with any other lease or sublease
      IF (x_return_status IS NULL) THEN

         BEGIN
            SELECT lease_num
            INTO   l_leaseNumber
            FROM   pn_leases_all
            WHERE  lease_id =
                   (SELECT lease_id
                    FROM   pn_tenancies_all pnt
                    WHERE  pnt.status = 'A'
                    AND    pnt.lease_id <> l_parentLeaseId
                    AND    pnt.location_id IN
                           (SELECT  a.location_id
                            FROM    pn_locations_all a
                            CONNECT BY PRIOR a.parent_location_id = a.location_id
                            START WITH a.location_id = x_location_id
                            UNION ALL
                            SELECT  b.location_id
                            FROM    pn_locations_all b
                            CONNECT BY PRIOR b.location_id = b.parent_location_id
                            START WITH b.location_id = x_location_id
                           )
                    AND    (TRUNC(NVL(pnt.occupancy_date, pnt.estimated_occupancy_date))
                            BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                                    AND TRUNC (x_expiration_date)
                            OR TRUNC(pnt.expiration_date)
                               BETWEEN TRUNC (NVL(x_occupancy_date, x_estimated_occupancy_date))
                                       AND TRUNC (x_expiration_date)
                           )
                    AND    ((x_tenancy_id IS NULL) OR (pnt.tenancy_id <> x_tenancy_id))
                    AND    ROWNUM        < 2
                   );


            IF nvl(pn_mo_cache_utils.get_profile_value('PN_MULTIPLE_LEASE_FOR_LOCATION',l_org_id),'N') <> 'Y' THEN
               fnd_message.set_name ('PN', 'PN_LEASE_TENANCY_OVERLAP');
               fnd_message.set_token ('LOCATION_CODE', l_locationCode);
               fnd_message.set_token ('LEASE_NUMBER',  l_leaseNumber);
               x_return_status := 'E';
            ELSE
               x_return_status := 'W';
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND  THEN
               -- IF no data was found THEN we don't worry
               NULL;
         END;
      END IF;

   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_FOR_OVELAP_OF_TENANCY (-) X_RETURN_STATUS: '||X_RETURN_STATUS);

END check_for_ovelap_of_tenancy;

-------------------------------------------------------------------------------
-- PROCDURE     : check_tenancy_dates
-- INVOKED FROM :
-- PURPOSE      : checks the tenancy dates
-- HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE check_tenancy_dates
(
   X_RETURN_STATUS                     IN OUT NOCOPY VARCHAR2
   ,X_ESTIMATED_OCCUPANCY_DATE         IN            DATE
   ,X_OCCUPANCY_DATE                   IN            DATE
   ,X_EXPIRATION_DATE                  IN            DATE
)
IS
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_TENANCY_DATES (+)');

   IF (X_ESTIMATED_OCCUPANCY_DATE IS NULL) THEN
      fnd_message.set_name('PN', 'PN_LEASE_TENANCY_EST_DT_NULL');
      x_return_status := 'E';

   ELSIF (X_EXPIRATION_DATE IS NULL) THEN
      fnd_message.set_name ('PN', 'PN_LEASE_TENANCY_EXP_DT_NULL');
      x_return_status := 'E';

   ELSIF (TRUNC(NVL(x_occupancy_date, x_expiration_date)) > TRUNC(x_expiration_date)) THEN

      fnd_message.set_name ('PN', 'PN_LEASE_TENANCY_EXP_GT_OCP_DT');
      x_return_status := 'E';
   END IF;


   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHECK_TENANCY_DATES (-)');
END check_tenancy_dates;

-------------------------------------------------------------------------------
-- FUNCTION     : get_loc_type_code
-- INVOKED FROM :
-- PURPOSE      : Retrieves location code type
-- HISTORY      :
-- 05-DEC-2003 Satish Tripathi o Created for BUG# 3300697.
-------------------------------------------------------------------
FUNCTION get_loc_type_code
(
    p_location_id                   IN      NUMBER
   ,p_start_date                    IN      DATE
)
RETURN VARCHAR2
IS
   CURSOR get_location_type_csr IS
      SELECT location_code,
             location_type_lookup_code
      FROM   pn_locations_all pnl
      WHERE  pnl.location_id = p_location_id
      AND    p_start_date BETWEEN pnl.active_start_date AND pnl.active_end_date;

   l_location_code                 pn_locations_all.location_code%TYPE;
   l_loc_type_code                 pn_locations_all.location_type_lookup_code%TYPE;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_LOC_TYPE_CODE (+)');

   OPEN get_location_type_csr;
   FETCH get_location_type_csr INTO l_location_code, l_loc_type_code;
   CLOSE get_location_type_csr;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_LOC_TYPE_CODE (-) Loc_Type_Code: '||l_loc_type_code);

   RETURN l_loc_type_code;

END get_loc_type_code;

-------------------------------------------------------------------
-- FUNCTION: cust_assign_assoc_exp_area_dt
-- 08-APR-2004 Satish Tripathi o Fixed for BUG# 3284799, Modified CURSOR chk_locked_area_exp_det
--                               where clause of pn_space_assign_cust_all to select all space
--                               assignments between the p_start/end date to check if its locked.
-------------------------------------------------------------------
FUNCTION cust_assign_assoc_exp_area_dt(
                 p_tenancy_id                    IN      NUMBER
                ,p_chk_locked                    IN      BOOLEAN
                ,p_cust_assign_start_dt          IN      DATE DEFAULT NULL
                ,p_cust_assign_end_dt            IN      DATE DEFAULT NULL
                )
RETURN BOOLEAN
IS
   CURSOR chk_assoc_exp_area_dtl IS
      SELECT 'Y'
      FROM   DUAL
      WHERE  EXISTS (SELECT NULL
                     FROM   pn_space_assign_cust_all spc
                     WHERE  spc.tenancy_id = p_tenancy_id
                     AND    (EXISTS (SELECT NULL
                                     FROM   pn_rec_arcl_dtl_all   mst,
                                            pn_rec_arcl_dtlln_all dtl
                                     WHERE  mst.area_class_dtl_id = dtl.area_class_dtl_id
                                     AND    dtl.cust_space_assign_id = spc.cust_space_assign_id) OR
                             EXISTS (SELECT NULL
                                     FROM   pn_rec_expcl_dtl_all   mst,
                                            pn_rec_expcl_dtlln_all dtl
                                     WHERE  mst.expense_class_dtl_id = dtl.expense_class_dtl_id
                                     AND    dtl.cust_space_assign_id = spc.cust_space_assign_id))
                    );

   CURSOR chk_locked_area_exp_det IS
      SELECT 'Y'
      FROM   DUAL
      WHERE  EXISTS (SELECT NULL
                     FROM  pn_space_assign_cust_all spc
                     WHERE spc.tenancy_id = p_tenancy_id
                     AND  (NVL(spc.cust_assign_end_date,p_cust_assign_end_dt) >= p_cust_assign_start_dt OR
                           spc.cust_assign_start_date <= p_cust_assign_end_dt)
                     AND  (EXISTS (SELECT NULL
                                   FROM   pn_rec_arcl_dtl_all   mst,
                                          pn_rec_arcl_dtlln_all dtl
                                   WHERE  mst.area_class_dtl_id = dtl.area_class_dtl_id
                                   AND    mst.status = 'LOCKED'
                                   AND    dtl.cust_space_assign_id = spc.cust_space_assign_id) OR
                           EXISTS (SELECT NULL
                                   FROM   pn_rec_expcl_dtl_all   mst,
                                          pn_rec_expcl_dtlln_all dtl
                                   WHERE  mst.expense_class_dtl_id = dtl.expense_class_dtl_id
                                   AND    mst.status = 'LOCKED'
                                   AND    dtl.cust_space_assign_id = spc.cust_space_assign_id))
                    );

   l_exists VARCHAR2(1) :='N';
   l_return BOOLEAN := FALSE;

BEGIN
   IF p_chk_locked THEN
      OPEN chk_locked_area_exp_det;
      FETCH chk_locked_area_exp_det INTO l_exists;
      CLOSE chk_locked_area_exp_det;
   ELSE
      OPEN chk_assoc_exp_area_dtl;
      FETCH chk_assoc_exp_area_dtl INTO l_exists;
      CLOSE chk_assoc_exp_area_dtl;
   END IF;

   IF l_exists = 'Y' THEN
      l_return := TRUE;
   END IF;
   RETURN l_return;

END cust_assign_assoc_exp_area_dt;

-------------------------------------------------------------------
-- PROCEDURE  : GET_LOC_INFO
-- DESCRIPTION: o populate loc_info_tbl with rows from pn_locations_all for a given location
--              o if the assignable area for a location has not changed but the location
--                was split the location records would be treated as a single record.
--                Example:
--                Rows in pn_locations_all
--                active_st_dt     active_end_dt       assignable_area
--                01-JAN-00        31-DEC-00           1000
--                01-JAN-01        30-JUN-01           1000
--                01-JUL-00        31-DEC-01           2000
--
--                The following rows will be inserted in loc_info_tbl
--                active_st_dt     active_end_dt       assignable_area
--                01-JAN-00        30-JUN-01           1000
--                01-JUL-00        31-DEC-01           2000
--
-- 10-JUN-2003 Pooja Sidhu     o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 26-AUG-2003 Satish Tripathi o Fixed for BUG# 3085758, Modified Where clause of CURSOR csr_loc_info
--                               with <= and >= instead of < and > to pick all locations within
--                               p_from_date and p_to_date.
-------------------------------------------------------------------

PROCEDURE get_loc_info(
                 p_location_id                   IN     NUMBER
                ,p_from_date                     IN     DATE
                ,p_to_date                       IN     DATE
                ,p_loc_type_code                    OUT NOCOPY VARCHAR2
                )
IS
   CURSOR csr_loc_info IS
      SELECT active_start_date,
             NVL(active_end_date, p_to_date) active_end_date,
             assignable_area,
             location_type_lookup_code
      FROM   pn_locations_all
      WHERE  location_id = p_location_id
      AND    active_start_date <= p_to_date
      AND    NVL(active_end_date, p_to_date) >= p_from_date
      ORDER BY active_start_date;

   l_prior_assignable_area        pn_locations_all.assignable_area%TYPE:=0;
   i                              NUMBER := 0;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_LOC_INFO (+)');

   loc_info_tbl.delete;

   FOR rec_loc_info IN csr_loc_info
   LOOP
      p_loc_type_code := rec_loc_info.location_type_lookup_code;

      IF csr_loc_info%ROWCOUNT = 1 THEN
         loc_info_tbl(i).active_start_date := rec_loc_info.active_start_date;
         loc_info_tbl(i).active_end_date := rec_loc_info.active_end_date;
         loc_info_tbl(i).assignable_area := rec_loc_info.assignable_area;
      ELSE
         IF rec_loc_info.assignable_area = l_prior_assignable_area THEN
            loc_info_tbl(i).active_end_date := rec_loc_info.active_end_date;
         ELSE
            i := i + 1;
            loc_info_tbl(i).active_start_date := rec_loc_info.active_start_date;
            loc_info_tbl(i).active_end_date := rec_loc_info.active_end_date;
            loc_info_tbl(i).assignable_area := rec_loc_info.assignable_area;
         END IF;
      END IF;
      l_prior_assignable_area := rec_loc_info.assignable_area;

   END LOOP;
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_LOC_INFO (-)');

EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Get_loc_info - Errmsg: ' || sqlerrm);
      RAISE;

END get_loc_info;

-------------------------------------------------------------------
-- PROCEDURE  : GET_ALLOCATED_AREA_PCT
-- DESCRIPTION:
--
-- 10-JUN-2003 Pooja Sidhu     o Created for Recovery (CAM) impact on Leases and Space Assignments.
-------------------------------------------------------------------
PROCEDURE get_allocated_area_pct(
                 p_cust_assign_start_date        IN     DATE
                ,p_cust_assign_end_date          IN     DATE
                ,p_allocated_area                IN     NUMBER
                ,p_alloc_area_pct                   OUT NOCOPY NUMBER
                )
IS
   i     NUMBER := 0;
   l_min_area NUMBER := -1;
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_ALLOCATED_AREA_PCT (+)');

   p_alloc_area_pct := -1;
   FOR i IN 0 .. loc_info_tbl.count-1
   LOOP
      IF (p_cust_assign_start_date >= loc_info_tbl(i).active_start_date AND
          p_cust_assign_end_date <= loc_info_tbl(i).active_end_date)
	  OR
         (p_cust_assign_start_date <= loc_info_tbl(i).active_end_date AND
          p_cust_assign_end_date >= loc_info_tbl(i).active_start_date)
      THEN
        IF p_allocated_area = 0 and loc_info_tbl(i).assignable_area = 0 THEN
           p_alloc_area_pct:= 100;
        ELSE

          IF i = 0 OR loc_info_tbl(i).assignable_area <  l_min_area THEN
	    l_min_area := loc_info_tbl(i).assignable_area;
          END IF;
        END IF;
      END IF;
   END LOOP;

   IF p_alloc_area_pct < 0 THEN
      p_alloc_area_pct := ROUND(((p_allocated_area * 100 )/l_min_area),2);
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_ALLOCATED_AREA_PCT (-)');
END get_allocated_area_pct;

-------------------------------------------------------------------
-- PROCEDURE  : POPULATE_SPACE_ASSIGN_INFO
-- DESCRIPTION: o Calls procedure pn_recovery_extract_pkg.process_vacancy to
--                get available allocable area. The assignment record could be split
--                based on the number of space and emp assignments existing for
--                the location and if the assignable area has changed.
--              o Populates space_assign_info_tbl with the start date, end date and
--                allocated area that will be used to create space assignment record.
--
-- 10-JUN-2003 Pooja Sidhu     o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 05-AUG-2003 Satish Tripathi o Fixed for BUG# 3082056. Populate
--                               populate_space_assign_info for SECTION also.
-- 22-AUG-2003 Satish Tripathi o Fixed for BUG# 3085758, Added parameter p_fin_oblig_end_date.
--                               For last space assignment record fin_oblig_end_date is
--                               p_fin_oblig_end_date, for others it will be cust_assign_end_date.
-- 07-NOV-2003 Daniel Thota    o Fix for bug # 3242535
--                               assigned l_loc_type_code to p_loc_type_code
-------------------------------------------------------------------
PROCEDURE populate_space_assign_info(
                 p_location_id                   IN NUMBER
                ,p_from_date                     IN DATE
                ,p_to_date                       IN DATE
                ,p_fin_oblig_end_date            IN DATE
                ,p_loc_type_code                    OUT NOCOPY VARCHAR2
                )
IS
   CURSOR csr_cust_info IS
      SELECT cust_assign_start_date,
             NVL(cust_assign_end_date, p_to_date) cust_assign_end_date,
             allocated_area
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
      AND    cust_assign_start_date <= p_to_date
      AND    NVL(cust_assign_end_date, p_to_date) >= p_from_date;

   CURSOR csr_emp_info IS
      SELECT emp_assign_start_date,
             NVL(emp_assign_end_date, p_to_date) emp_assign_end_date,
             allocated_area
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
      AND    emp_assign_start_date <= p_to_date
      AND    NVL(emp_assign_end_date, p_to_date) >= p_from_date;

   l_loc_type_code   pn_locations_all.location_type_lookup_code%TYPE;
   l_num_table       pn_recovery_extract_pkg.number_table_TYPE;
   l_date_table      pn_recovery_extract_pkg.date_table_TYPE;
   l_start_date      DATE := NULL;
   l_end_date        DATE := NULL;
   i                 NUMBER := 0;
   j                 NUMBER := 0;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.POPULATE_SPACE_ASSIGN_INFO (+)');

   get_loc_info(p_location_id   => p_location_id,
                p_from_date     => p_from_date,
                p_to_date       => p_to_date,
                p_loc_type_code => l_loc_type_code);

   IF l_loc_type_code IN ('OFFICE', 'SECTION') THEN

      FOR i IN 0 .. loc_info_tbl.count-1
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => loc_info_tbl(i).active_start_date,
                 p_end_date     => loc_info_tbl(i).active_end_date,
                 p_area         => loc_info_tbl(i).assignable_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => TRUE);
      END LOOP;

      FOR rec_cust_info IN csr_cust_info
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => rec_cust_info.cust_assign_start_date,
                 p_end_date     => rec_cust_info.cust_assign_end_date,
                 p_area         => rec_cust_info.allocated_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => FALSE);
      END LOOP;

      FOR rec_emp_info IN csr_emp_info
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => rec_emp_info.emp_assign_start_date,
                 p_end_date     => rec_emp_info.emp_assign_end_date,
                 p_area         => rec_emp_info.allocated_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => FALSE);
      END LOOP;

      i := 0;
      space_assign_info_tbl.delete;

      FOR i IN 0 .. l_date_table.count-1
      LOOP
         IF i = 0 THEN
            l_start_date := l_date_table(i);
         ELSE
            l_end_date := l_date_table(i)-1;
            IF l_end_date >= p_from_date and l_start_date <= p_to_date THEN
               space_assign_info_tbl(j).cust_assign_start_date := GREATEST(p_from_date, l_start_date);
               space_assign_info_tbl(j).cust_assign_end_date := LEAST(p_to_date, l_end_date);

               IF i = l_date_table.count-1 THEN
                  space_assign_info_tbl(j).fin_oblig_end_date := p_fin_oblig_end_date;
               ELSE
                  space_assign_info_tbl(j).fin_oblig_end_date := LEAST(p_to_date, l_end_date);
               END IF;

               space_assign_info_tbl(j).allocated_area := l_num_table(i-1);
               get_allocated_area_pct(
                        p_cust_assign_start_date => space_assign_info_tbl(j).cust_assign_start_date,
                        p_cust_assign_end_date   => space_assign_info_tbl(j).cust_assign_end_date,
                        p_allocated_area         => space_assign_info_tbl(j).allocated_area,
                        p_alloc_area_pct         => space_assign_info_tbl(j).allocated_area_pct);
               l_start_date := l_date_table(i);
               j := j + 1;
            END IF;
         END IF;
      END LOOP;

   ELSE
      space_assign_info_tbl(j).cust_assign_start_date := p_from_date;
      space_assign_info_tbl(j).cust_assign_end_date := p_to_date;
      space_assign_info_tbl(j).fin_oblig_end_date := p_fin_oblig_end_date;
      space_assign_info_tbl(j).allocated_area := NULL;
      space_assign_info_tbl(j).allocated_area_pct := NULL;
   END IF;
   p_loc_type_code := l_loc_type_code; -- 3242535

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.POPULATE_SPACE_ASSIGN_INFO (-)');
EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Populate_space_assign_info - Errmsg: ' || sqlerrm);
      RAISE;

END populate_space_assign_info;

--------------------------------------------------------------------------------
-- PROCEDURE  : INSERT_SPACE_ASSIGN_ROW
-- DESCRIPTION:
--
-- 10-JUN-03 PSidhu    o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 18-AUG-03 STripathi o Fixed for BUG# 3083849. Populate X_UTILIZED_AREA
--                       with default value 1.
-- 22-AUG-03 STripathi o Fixed for BUG# 3085758, pass fin_oblig_end_date of PL/SQL
--                       table to x_fin_oblig_end_date.
-- 08-NOV-03 STripathi o Fixed for BUG# 3242651. Call chk_dup_cust_assign to check
--                       duplicate assignment before insert_row pass DUP_ASSIGN in p_action.
-- 05-MAR-04 ftanudja  o Replaced call to chk_dup_cust_assign w/ exception handling.
-- 28-Apr-04 vmmehta   o BUG#3197182. Changed call to pn_space_assign_cust_pkg.insert_row
--                       Added parameter x_return_status and checking
--                       return_status rather than duplicate_exception.
-------------------------------------------------------------------------------
PROCEDURE insert_space_assign_row(
                 p_location_id                   IN NUMBER
                ,p_lease_id                      IN NUMBER
                ,p_customer_id                   IN NUMBER
                ,p_cust_site_use_id              IN NUMBER
                ,p_recovery_space_std_code       IN VARCHAR2
                ,p_recovery_type_code            IN VARCHAR2
                ,p_fin_oblig_end_date            IN DATE
                ,p_tenancy_id                    IN NUMBER
                ,p_org_id                        IN NUMBER
                ,p_space_assign_info_tbl         IN space_assign_info_type
                ,p_return_status                  OUT NOCOPY VARCHAR2
                )
IS
   l_rowid                ROWID  := NULL;
   l_cust_space_assign_id NUMBER := NULL;
   i                      NUMBER := 0;
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.INSERT_SPACE_ASSIGN_ROW (+)');

   i := 0;
   FOR i IN 0 .. p_space_assign_info_tbl.count-1
   LOOP

         pn_space_assign_cust_pkg.insert_row(
            x_rowid                         => l_rowId,
            x_cust_space_assign_id          => l_cust_space_assign_id,
            x_location_id                   => p_location_id,
            x_cust_account_id               => p_customer_id,
            x_site_use_id                   => p_cust_site_use_id,
            x_expense_account_id            => NULL,
            x_project_id                    => NULL,
            x_task_id                       => NULL,
            x_cust_assign_start_date        => p_space_assign_info_tbl(i).cust_assign_start_date,
            x_cust_assign_end_date          => p_space_assign_info_tbl(i).cust_assign_end_date,
            x_allocated_area_pct            => p_space_assign_info_tbl(i).allocated_area_pct,
            x_allocated_area                => p_space_assign_info_tbl(i).allocated_area,
            x_utilized_area                 => 1,
            x_fin_oblig_end_date            => p_space_assign_info_tbl(i).fin_oblig_end_date,
            x_cust_space_comments           => NULL,
            x_attribute_category            => NULL,
            x_attribute1                    => NULL,
            x_attribute2                    => NULL,
            x_attribute3                    => NULL,
            x_attribute4                    => NULL,
            x_attribute5                    => NULL,
            x_attribute6                    => NULL,
            x_attribute7                    => NULL,
            x_attribute8                    => NULL,
            x_attribute9                    => NULL,
            x_attribute10                   => NULL,
            x_attribute11                   => NULL,
            x_attribute12                   => NULL,
            x_attribute13                   => NULL,
            x_attribute14                   => NULL,
            x_attribute15                   => NULL,
            x_creation_date                 => SYSDATE,
            x_created_by                    => NVL(fnd_profile.value('USER_ID'),-1),
            x_last_update_date              => SYSDATE,
            x_last_updated_by               => NVL(fnd_profile.value('USER_ID'),-1),
            x_last_update_login             => NVL(fnd_profile.value('USER_ID'),-1),
            x_org_id                        => p_org_id,
            x_lease_id                      => p_lease_id,
            x_recovery_space_std_code       => p_recovery_space_std_code,
            x_recovery_type_code            => p_recovery_type_code,
            x_tenancy_id                    => p_tenancy_id,
            x_return_status                 => p_return_status);

      IF p_return_status = 'DUP_ASSIGN' THEN
            EXIT;
      END IF;

      l_rowid                := NULL;
      l_cust_space_assign_id := NULL;
   END LOOP;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.INSERT_SPACE_ASSIGN_ROW (-)');
END insert_space_assign_row;

-------------------------------------------------------------------
-- PROCEDURE  : GET_ALLOCATED_AREA
-- DESCRIPTION:
--
-- 12-DEC-2006 Ram kumar     o Created
-------------------------------------------------------------------
PROCEDURE get_allocated_area(
                 p_cust_assign_start_date        IN     DATE
                ,p_cust_assign_end_date          IN     DATE
                ,p_allocated_area_pct            IN     NUMBER
                ,p_allocated_area                OUT NOCOPY NUMBER
                )
IS
   i     NUMBER := 0;
   l_min_area NUMBER := -1;
BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_ALLOCATED_AREA (+)');

   p_allocated_area := -1;
   FOR i IN 0 .. loc_info_tbl.count-1
   LOOP
      IF p_cust_assign_start_date >= loc_info_tbl(i).active_start_date AND
         p_cust_assign_end_date <= loc_info_tbl(i).active_end_date
      THEN
          p_allocated_area:= ROUND(((p_allocated_area_pct * loc_info_tbl(i).assignable_area)/100),2);
      ELSIF (p_cust_assign_start_date <= loc_info_tbl(i).active_end_date AND
               p_cust_assign_end_date >= loc_info_tbl(i).active_start_date) THEN

	  IF i = 0 OR loc_info_tbl(i).assignable_area <  l_min_area THEN
	    l_min_area := loc_info_tbl(i).assignable_area;
          END IF;
      END IF;
   END LOOP;
   IF p_allocated_area < 0 THEN
      p_allocated_area := ROUND(((p_allocated_area_pct * l_min_area)/100),2);
   END IF;
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.GET_ALLOCATED_AREA (-)');
END get_allocated_area;

-------------------------------------------------------------------
-- PROCEDURE  : Manual_space_assign
-- DESCRIPTION:
--
-- 12-DEC-03 Ram kumar    o Created
-------------------------------------------------------------------

PROCEDURE manual_space_assign(
                 p_location_id                   IN NUMBER
                ,p_from_date                     IN DATE
                ,p_to_date                       IN DATE
                ,p_fin_oblig_end_date            IN DATE
		,p_allocated_pct                 IN NUMBER
                ,p_loc_type_code                    OUT NOCOPY VARCHAR2
                )
IS

   l_loc_type_code   pn_locations_all.location_type_lookup_code%TYPE;
   l_num_table       pn_recovery_extract_pkg.number_table_TYPE;
   l_date_table      pn_recovery_extract_pkg.date_table_TYPE;
   l_start_date      DATE := NULL;
   l_end_date        DATE := NULL;
   i                 NUMBER := 0;
   j                 NUMBER := 0;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.MANUAL_SPACE_ASSIGN (+)');

   get_loc_info(p_location_id   => p_location_id,
                p_from_date     => p_from_date,
                p_to_date       => p_to_date,
                p_loc_type_code => l_loc_type_code);

   IF l_loc_type_code IN ('OFFICE', 'SECTION') THEN

      FOR i IN 0 .. loc_info_tbl.count-1
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => loc_info_tbl(i).active_start_date,
                 p_end_date     => loc_info_tbl(i).active_end_date,
                 p_area         => loc_info_tbl(i).assignable_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => TRUE);
      END LOOP;

      i := 0;
      space_assign_info_tbl.delete;

      FOR i IN 0 .. l_date_table.count-1
      LOOP
         IF i = 0 THEN
            l_start_date := l_date_table(i);

         ELSE
            l_end_date := l_date_table(i)-1;
            IF l_end_date >= p_from_date and l_start_date <= p_to_date THEN
               space_assign_info_tbl(j).cust_assign_start_date := GREATEST(p_from_date, l_start_date);
               space_assign_info_tbl(j).cust_assign_end_date := LEAST(p_to_date, l_end_date);

               IF i = l_date_table.count-1 THEN
                  space_assign_info_tbl(j).fin_oblig_end_date := p_fin_oblig_end_date;
               ELSE
                  space_assign_info_tbl(j).fin_oblig_end_date := LEAST(p_to_date, l_end_date);
               END IF;
	       space_assign_info_tbl(j).allocated_area_pct := p_allocated_pct;
	       get_allocated_area(
                        p_cust_assign_start_date => space_assign_info_tbl(j).cust_assign_start_date,
                        p_cust_assign_end_date   => space_assign_info_tbl(j).cust_assign_end_date,
                        p_allocated_area_pct     => space_assign_info_tbl(j).allocated_area_pct,
                        p_allocated_area         => space_assign_info_tbl(j).allocated_area);
	       j := j + 1;
               l_start_date := l_date_table(i);
            END IF;
         END IF;
      END LOOP;

   ELSE
      space_assign_info_tbl(j).cust_assign_start_date := p_from_date;
      space_assign_info_tbl(j).cust_assign_end_date := p_to_date;
      space_assign_info_tbl(j).fin_oblig_end_date := p_fin_oblig_end_date;
      space_assign_info_tbl(j).allocated_area := NULL;
      space_assign_info_tbl(j).allocated_area_pct := NULL;
   END IF;
   p_loc_type_code := l_loc_type_code;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.MANUAL_SPACE_ASSIGN (-)');
EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Manual_space_assign - Errmsg: ' || sqlerrm);
      RAISE;

END manual_space_assign;

-------------------------------------------------------------------
-- PROCEDURE  : CHK_MULTI_TENANCY_PROFILE
-- DESCRIPTION:
--
-- 10-JUN-03 PSidhu    o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 05-AUG-03 STripathi o Fixed for BUG# 3082056. Populate
--                       populate_space_assign_info for SECTION also.
-- 22-AUG-03 STripathi o Fixed for BUG# 3085758, Added parameter p_fin_oblig_end_date.
-- 04-NOV-03 DThota    o Checking for profile option PN_AUTOMATIC_SPACE_DISTRIBUTION
--                       for split and redistribute of assignment records
-- 05-NOV-03 STripathi o Modified CURSOR csr_assign_exists to check for any
--                       tenancy for the same location in other non-Direct lease
-- 07-NOV-03 DThota    o Fix for bug # 3242535
--                       assigned l_loc_type_code to p_loc_type_code
-- 10-NOV-03 DThota    o Fix for bug # 3194380
--                       New cusrsor csr_space_exists checks to see if assignable area
--                       in pn_locations_all is non-zero for a given assignment time period
--                       Returning if there is no vacancy, overlap or assignable_area in locations is
--                       non-zero regardless of PN_AUTOMATIC_SPACE_DISTRIBUTION setting.
-- 21-NOV-03 STripathi o Fixed BUG# 3263503, Removed return; CLOSE csr_space_exists; in
--                       csr_space_exists and EXIT; in space_assign_info_tbl for NOVACANT.
-- 14-JAN-04 STripathi o Fixed BUG# 3359371, Call pnp_util_func.Get_Location_Type_Lookup_Code
--                       with p_cust_assign_start_dt as as_of_date.
-- 08-APR-04 STripathi o Fixed for BUG# 3533405, Modified CURSOR csr_assign_exists
--                       added ten.str_dt <= p_assgn_end_dt and ten.end_dt >= p_assgn_str_dt
--                       to check tenancy other exist betn assgn str and end dt.
-- 28-NOV-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------
PROCEDURE chk_multi_tenancy_profile(
                 p_location_id                   IN     NUMBER
                ,p_lease_id                      IN     NUMBER
                ,p_cust_assign_start_dt          IN     DATE
                ,p_cust_assign_end_dt            IN     DATE
                ,p_old_cust_assign_start_dt      IN     DATE
                ,p_old_cust_assign_end_dt        IN     DATE
                ,p_fin_oblig_end_date            IN     DATE
                ,p_chk_vacancy                   IN     BOOLEAN
                ,p_count                         IN     NUMBER
                ,p_action                        OUT NOCOPY VARCHAR2
                ,p_loc_type_code                 OUT NOCOPY VARCHAR2
                )
IS
   CURSOR csr_assign_exists IS
      SELECT 'Y'
      FROM   DUAl
      WHERE  EXISTS (SELECT NULL
                     FROM   pn_leases_all pnl,
                            pn_tenancies_all ten
                     WHERE  pnl.lease_id <> p_lease_id
                     AND    pnl.lease_class_code <> 'DIRECT'
                     AND    pnl.lease_id = ten.lease_id
                     AND    ten.location_id = p_location_id
                     AND    NVL(ten.estimated_occupancy_date, ten.occupancy_date)
                            <= p_cust_assign_end_dt
                     AND    ten.expiration_date >= p_cust_assign_start_dt
                    );

   CURSOR csr_space_exists IS
      SELECT 'Y'
      FROM   DUAl
      WHERE  EXISTS (SELECT NULL
                     from pn_locations_all pl
                     where pl.location_id = p_location_id
                     and   pl.assignable_area = 0
                     and   pl.active_start_date <= nvl(p_cust_assign_end_dt,to_date('12/31/4712','MM/DD/YYYY'))
                     and   pl.active_end_date >= p_cust_assign_start_dt);

   l_multi_tenancy_profile VARCHAR2(100);
   l_exists                VARCHAR2(1) := 'N';
   l_loc_type_lookup_code  VARCHAR2(30) := pnp_util_func.Get_Location_Type_Lookup_Code(p_location_id, p_cust_assign_start_dt);
   i                       NUMBER := 0;
   l_loc_type_code         pn_locations_all.location_type_lookup_code%TYPE;
   l_auto_space_assign   VARCHAR2(30);

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all pnl
    WHERE  pnl.lease_id = p_lease_id;

   l_org_id NUMBER;


BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHK_MULTI_TENANCY_PROFILE (+)');

   FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
   END LOOP;

   l_multi_tenancy_profile := NVL( pn_mo_cache_utils.get_profile_value('PN_MULTIPLE_LEASE_FOR_LOCATION',l_org_id),'N');
   l_auto_space_assign     := NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N');

   p_action := NULL;
   space_assign_info_tbl.delete;

   IF l_multi_tenancy_profile = 'N' THEN
      OPEN csr_assign_exists;
      FETCH csr_assign_exists INTO l_exists;
      CLOSE csr_assign_exists;
      IF l_exists = 'Y' THEN
         p_action := 'OVERLAP';
         return;
      END IF;
   END IF;

   /* Check to see whether location assignable area is zero for the duration of the space assignment */

   OPEN csr_space_exists;
   FETCH csr_space_exists INTO l_exists;
   IF csr_space_exists%FOUND  THEN
      p_action := 'NOVACANT';
   END IF;
   CLOSE csr_space_exists;

   IF l_auto_space_assign = 'N' AND p_chk_vacancy AND
         l_loc_type_lookup_code IN ('OFFICE', 'SECTION')
   THEN
      populate_space_assign_info(
                 p_location_id                   => p_location_id
                ,p_from_date                     => p_cust_assign_start_dt
                ,p_to_date                       => p_cust_assign_end_dt
                ,p_fin_oblig_end_date            => p_fin_oblig_end_date
                ,p_loc_type_code                 => l_loc_type_code
                );

      FOR i IN 0..space_assign_info_tbl.count-1
      LOOP
         IF space_assign_info_tbl(i).allocated_area = 0 THEN
            IF p_count = 0 THEN
               p_action := 'NOVACANT';
            ELSIF (p_old_cust_assign_start_dt > space_assign_info_tbl(i).cust_assign_start_date AND
               p_old_cust_assign_end_dt > space_assign_info_tbl(i).cust_assign_end_date)   OR
              (p_old_cust_assign_end_dt < space_assign_info_tbl(i).cust_assign_end_date AND
               p_old_cust_assign_start_dt < space_assign_info_tbl(i).cust_assign_start_date)  THEN --???
               p_action := 'NOVACANT';
            END IF;
         END IF;
      END LOOP;

   END IF;
   p_loc_type_code := l_loc_type_code; -- 3242535

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CHK_MULTI_TENANCY_PROFILE (-)');
END chk_multi_tenancy_profile;

-------------------------------------------------------------------------------
-- PROCEDURE  : CREATE_AUTO_SPACE_ASSIGN
-- DESCRIPTION:
--
-- 10-JUN-03 PSidhu    o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 22-AUG-03 STripathi o Fixed for BUG# 3085758, Added parameter p_fin_oblig_end_date
--                       when calling chk_multi_tenancy_profile and populate_space_assign_info.
-- 04-NOV-03 DThota    o Checking for profile option PN_AUTOMATIC_SPACE_DISTRIBUTION
--                       for split and redistribute of assignment records
-- 06-NOV-03 STripathi o Call assignment_split only for OFFICE and SECTION.
-- 08-NOV-03 STripathi o Fixed for BUG# 3242651. Pass DUP_ASSIGN for dup assign in p_action.
-- 21-NOV-03 STripathi o Fixed BUG# 3263503, IN IF clause, Removed NOVACANT to return;
--                       Now return only for OVERLAP instead of OVERLAP and NOVACANT.
-- 09-MAR-05 ftanudja  o Added start and end date for assignment_split. #4199297
-- 28-NOV-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------------------
PROCEDURE create_auto_space_assign(
                 p_location_id                   IN     NUMBER
                ,p_lease_id                      IN     NUMBER
                ,p_customer_id                   IN     NUMBER
                ,p_cust_site_use_id              IN     NUMBER
                ,p_cust_assign_start_dt          IN     DATE
                ,p_cust_assign_end_dt            IN     DATE
                ,p_recovery_space_std_code       IN     VARCHAR2
                ,p_recovery_type_code            IN     VARCHAR2
                ,p_fin_oblig_end_date            IN     DATE
		,p_allocated_pct                 IN     NUMBER
                ,p_tenancy_id                    IN     NUMBER
                ,p_org_id                        IN     NUMBER
                ,p_action                           OUT NOCOPY VARCHAR2
                ,p_msg                              OUT NOCOPY VARCHAR2
                )
IS

   i                      NUMBER :=0;
   l_rowid                ROWID  := NULL;
   l_cust_space_assign_id NUMBER := NULL;
   space_assign_tbl       space_assign_info_type;
   l_loc_type_code        pn_locations_all.location_type_lookup_code%TYPE;
   l_return_status        VARCHAR2(20) := NULL;
   l_auto_space_dist      VARCHAR2(20) := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_leases_all pnl
    WHERE  pnl.lease_id = p_lease_id;

   l_org_id NUMBER;

BEGIN

   FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
   END LOOP;

   l_auto_space_dist := NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N');
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CREATE_AUTO_SPACE_ASSIGN (+) Auto_Space_Dist: '
                       ||l_auto_space_dist);

   IF p_customer_id IS NULL THEN
      RETURN;
   END IF;

   chk_multi_tenancy_profile(
                                       p_location_id              => p_location_id
                                      ,p_lease_id                 => p_lease_id
                                      ,p_cust_assign_start_dt     => p_cust_assign_start_dt
                                      ,p_cust_assign_end_dt       => p_cust_assign_end_dt
                                      ,p_old_cust_assign_start_dt => p_cust_assign_start_dt
                                      ,p_old_cust_assign_end_dt   => p_cust_assign_end_dt
                                      ,p_fin_oblig_end_date       => p_fin_oblig_end_date
                                      ,p_chk_vacancy              => TRUE
                                      ,p_count                    => 0
                                      ,p_action                   => p_action
                                      ,p_loc_type_code            => l_loc_type_code
                                      );

   IF p_action IN ('OVERLAP') THEN
      RETURN;
   END IF;

   IF space_assign_info_tbl.count = 0 THEN
      populate_space_assign_info(
                 p_location_id                   => p_location_id
                ,p_from_date                     => p_cust_assign_start_dt
                ,p_to_date                       => p_cust_assign_end_dt
                ,p_fin_oblig_end_date            => p_fin_oblig_end_date
                ,p_loc_type_code                 => l_loc_type_code
                );
   END IF;

   space_assign_tbl := space_assign_info_tbl;

   IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N') = 'N' THEN

	manual_space_assign (
	         p_location_id                   => p_location_id
                ,p_from_date                     => p_cust_assign_start_dt
                ,p_to_date                       => p_cust_assign_end_dt
                ,p_fin_oblig_end_date            => p_fin_oblig_end_date
		,p_allocated_pct                 => p_allocated_pct
                ,p_loc_type_code                 => l_loc_type_code
                );
	space_assign_tbl := space_assign_info_tbl;

   END IF;

	insert_space_assign_row (
                 p_location_id             => p_location_id
                ,p_lease_id                => p_lease_id
                ,p_customer_id             => p_customer_id
                ,p_cust_site_use_id        => p_cust_site_use_id
                ,p_recovery_space_std_code => p_recovery_space_std_code
                ,p_recovery_type_code      => p_recovery_type_code
                ,p_fin_oblig_end_date      => p_fin_oblig_end_date
                ,p_tenancy_id              => p_tenancy_id
                ,p_org_id                  => p_org_id
                ,p_space_assign_info_tbl   => space_assign_info_tbl
                ,p_return_status           => l_return_status
                );

   IF l_return_status IS NOT NULL THEN
      p_action := l_return_status;
      RETURN;
   END IF;

   -- 110403
   IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N') = 'Y' AND
      l_loc_type_code IN ('OFFICE', 'SECTION')
   THEN

     PN_SPACE_ASSIGN_CUST_PKG.assignment_split(
        p_location_id => p_location_id,
        p_start_date  => p_cust_assign_start_dt,
        p_end_date    => p_cust_assign_end_dt);

   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.CREATE_AUTO_SPACE_ASSIGN (-)');
EXCEPTION
   WHEN OTHERS THEN
      p_msg := sqlerrm;
      pnp_debug_pkg.log('Create_auto_space_assign - Errmsg: ' || p_msg);
      RAISE;

END create_auto_space_assign;

-------------------------------------------------------------------------------
-- PROCEDURE  : DELETE_AUTO_SPACE_ASSIGN
-- DESCRIPTION:
--
-- 10-JUN-03 PSidhu    o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 25-Nov-03 DThota    o Added 2 parameters p_location_id and p_loc_type_code to
--                       delete_auto_space_assign. Added call to
--                       PN_SPACE_ASSIGN_CUST_PKG.assignment_split
--                       Fix for bug # 3282064
-- 23-FEB-04 STripathi o Fixed for BUG# 3425167. Removed code for IF p_cust_assign_start_date
--                       IS NOT NULL AND p_cust_assign_end_date IS NOT NULL THEN.
--                       For a tenancy id, delete all space assgn records.
-- 09-MAR-05 ftanudja  o Added start and end date for assignment_split.#4199297
-- 28-NOV-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------------------
PROCEDURE delete_auto_space_assign (
                 p_tenancy_id             IN  NUMBER
                ,p_cust_assign_start_date IN  DATE
                ,p_cust_assign_end_date   IN  DATE
                ,p_action                 OUT NOCOPY VARCHAR2
                ,p_location_id            IN  pn_locations_all.location_id%TYPE DEFAULT NULL
                ,p_loc_type_code          IN  pn_locations_all.location_type_lookup_code%TYPE DEFAULT NULL
                )
IS
   l_count           NUMBER := 0;
   l_del_count       NUMBER := 0;
   l_auto_space_dist VARCHAR2(20) := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_tenancies_all
    WHERE  tenancy_id = p_tenancy_id;

   l_org_id NUMBER;

BEGIN

   FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
   END LOOP;

   l_auto_space_dist := NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N');
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.DELETE_AUTO_SPACE_ASSIGN (+) Auto_Space_Dist: '
                       ||l_auto_space_dist||', TenancyId: '||p_tenancy_id);

   DELETE FROM pn_rec_expcl_dtlln_all
   WHERE  cust_space_assign_id IN (SELECT cust_space_assign_id
                                   FROM   pn_space_assign_cust_all
                                   WHERE  tenancy_id = p_tenancy_id);
   l_count := SQL%ROWCOUNT;

   DELETE FROM pn_rec_arcl_dtlln_all
   WHERE  cust_space_assign_id IN (SELECT cust_space_assign_id
                                   FROM   pn_space_assign_cust_all
                                   WHERE  tenancy_id = p_tenancy_id);
   l_count := SQL%ROWCOUNT + l_count;

   DELETE FROM pn_space_assign_cust_all
   WHERE  tenancy_id = p_tenancy_id;
   l_del_count := SQL%ROWCOUNT;

   -- 3282064
   IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N') = 'Y' AND
      p_loc_type_code IN ('OFFICE', 'SECTION')
   THEN

     PN_SPACE_ASSIGN_CUST_PKG.assignment_split(
        p_location_id => p_location_id,
        p_start_date  => p_cust_assign_start_date,
        p_end_date    => p_cust_assign_end_date);

   END IF;

   IF l_count > 0 THEN
      p_action := 'R';
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.DELETE_AUTO_SPACE_ASSIGN (-) Deleted '||l_del_count||
                       ' Space Assgn Rows');
EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Delete_auto_space_assign - Errmsg: ' || sqlerrm);
      RAISE;
END delete_auto_space_assign;

--------------------------------------------------------------------------------
-- PROCEDURE  : UPDATE_AUTO_SPACE_ASSIGN
-- DESCRIPTION:
--
-- 10-JUN-03 PSidhu     o Created for Recovery (CAM) impact on Leases and Space Assignments.
-- 22-AUG-03 STripathi o Rewritten procedure to fix BUG# 3085758. Added 5 parameters.
-- 04-NOV-03 DThota    o Checking for profile option PN_AUTOMATIC_SPACE_DISTRIBUTION
--                       for split and redistribute of assignment records
-- 05-NOV-03 STripathi o Added check# 0, if no space assignment exists for the
--                       tenancy then Create new Space Assignment for that tenancy.
-- 06-NOV-03 STripathi o Call assignment_split only for OFFICE and SECTION.
-- 08-NOV-03 STripathi o Fixed for BUG# 3242617. Use NVL for the _old items
--                       in Check# 3,4. Fix for BUG# 3242651, added return_status
--                       for passing back DUP_ASSIGN for dup assign in p_action.
-- 21-NOV-03 STripathi o Fixed BUG# 3263503, IN IF clause, Removed NOVACANT to return;
--                       Now return only for OVERLAP instead of OVERLAP and NOVACANT.
-- 25-NOV-03 STripathi o Fix BUG# 3282064, Check chk_dup_cust_assign if customer is
--                       changed when updating space_assign (Check# 4).
-- 25-NOV-03 STripathi o Fix BUG# 3300697, if loc_type_code is null, call get_loc_type_code.
-- 09-MAR-05 ftanudja  o Added start and end date for assignment_split. #4199297
-- 28-NOV-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
--------------------------------------------------------------------------------
PROCEDURE update_auto_space_assign(
                 p_location_id                      IN     NUMBER
                ,p_lease_id                         IN     NUMBER
                ,p_customer_id                      IN     NUMBER
                ,p_cust_site_use_id                 IN     NUMBER
                ,p_cust_assign_start_dt             IN     DATE
                ,p_cust_assign_end_dt               IN     DATE
                ,p_recovery_space_std_code          IN     VARCHAR2
                ,p_recovery_type_code               IN     VARCHAR2
                ,p_fin_oblig_end_date               IN     DATE
		,p_allocated_pct                    IN     NUMBER
                ,p_tenancy_id                       IN     NUMBER
                ,p_org_id                           IN     NUMBER
                ,p_location_id_old                  IN     NUMBER
                ,p_customer_id_old                  IN     NUMBER
                ,p_cust_site_use_id_old             IN     NUMBER
                ,p_cust_assign_start_dt_old         IN     DATE
                ,p_cust_assign_end_dt_old           IN     DATE
                ,p_recovery_space_std_code_old      IN     VARCHAR2
                ,p_recovery_type_code_old           IN     VARCHAR2
                ,p_fin_oblig_end_date_old           IN     DATE
		,p_allocated_pct_old                IN     NUMBER
                ,p_action                              OUT NOCOPY VARCHAR2
                ,p_msg                                 OUT NOCOPY VARCHAR2
                )
IS
   CURSOR csr_min_cust_assign IS
      SELECT cust_space_assign_id,
             cust_assign_start_date,
             cust_assign_end_date,
             allocated_area
      FROM   pn_space_assign_cust_all
      WHERE  tenancy_id = p_tenancy_id
      AND    cust_assign_start_date = (SELECT MIN(cust_assign_start_date)
                                       FROM   pn_space_assign_cust_all
                                       WHERE  tenancy_id = p_tenancy_id);

   CURSOR csr_max_cust_assign IS
      SELECT cust_space_assign_id,
             cust_assign_start_date,
             cust_assign_end_date,
             allocated_area
      FROM   pn_space_assign_cust_all
      WHERE  tenancy_id = p_tenancy_id
      AND    cust_assign_end_date = (SELECT MAX(cust_assign_end_date)
                                     FROM   pn_space_assign_cust_all
                                     WHERE  tenancy_id = p_tenancy_id);

   CURSOR csr_spc_assign_exists IS
      SELECT 'Y'
      FROM   DUAL
      WHERE  EXISTS (SELECT NULL
                     FROM   pn_space_assign_cust_all
                     WHERE  tenancy_id = p_tenancy_id);

   i                               NUMBER := 0;
   j                               NUMBER := 0;
   l_count                         NUMBER := 0;
   l_extend_assgn                  BOOLEAN := FALSE;
   l_allocated_area                NUMBER := NULL;
   l_fin_oblig_end_date            DATE := NULL;
   l_min_cust_start_date           DATE := NULL;
   l_min_cust_end_date             DATE := NULL;
   l_min_cust_assign_id            NUMBER := NULL;
   l_max_cust_start_date           DATE := NULL;
   l_max_cust_end_date             DATE := NULL;
   l_max_cust_assign_id            NUMBER := NULL;
   space_assign_tbl                space_assign_info_type;
   l_exists                        VARCHAR2(1) := 'N';
   l_loc_type_code                 pn_locations_all.location_type_lookup_code%TYPE;
   l_StartOfTime                   DATE := TO_DATE('01010001','MMDDYYYY');
   l_return_status                 VARCHAR2(20) := NULL;
   l_auto_space_dist               VARCHAR2(20) := NULL;
   l_cust_assign_start_date	   DATE := NULL;
   l_cust_assign_end_date          DATE := NULL;


   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_tenancies_all
    WHERE  tenancy_id = p_tenancy_id;

   CURSOR cur_alloc_area IS
    SELECT cust_assign_start_date,
           cust_assign_end_date
    FROM   pn_space_assign_cust_all
    WHERE  tenancy_id = p_tenancy_id;

   l_org_id NUMBER;

BEGIN

   FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
   END LOOP;

   l_auto_space_dist := NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N');
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_AUTO_SPACE_ASSIGN (+) Auto_Space_Dist: '
                       ||l_auto_space_dist);
   p_action := NULL;

   OPEN csr_spc_assign_exists;
   FETCH csr_spc_assign_exists INTO l_exists;
   CLOSE csr_spc_assign_exists;

   ----------------------------------------------------------------------------------------
   -- Check# 0. If Space Assignment for the tenancy do not exists,
   --           Create new Space Assignment for that tenancy.
   ----------------------------------------------------------------------------------------
   IF NVL(l_exists, 'N') = 'N' THEN
      create_auto_space_assign(
                                       p_location_id             => p_location_id
                                      ,p_lease_id                => p_lease_id
                                      ,p_customer_id             => p_customer_id
                                      ,p_cust_site_use_id        => p_cust_site_use_id
                                      ,p_cust_assign_start_dt    => p_cust_assign_start_dt
                                      ,p_cust_assign_end_dt      => p_cust_assign_end_dt
                                      ,p_recovery_space_std_code => p_recovery_space_std_code
                                      ,p_recovery_type_code      => p_recovery_type_code
                                      ,p_fin_oblig_end_date      => p_fin_oblig_end_date
				      ,p_allocated_pct           => p_allocated_pct
                                      ,p_tenancy_id              => p_tenancy_id
                                      ,p_org_id                  => p_org_id
                                      ,p_action                  => p_action
                                      ,p_msg                     => p_msg
                                      );

   ----------------------------------------------------------------------------------------
   -- Check# 1. If Location is changed, check if assignment is associated with a locked
   --           Area or Expense Class in Recoveries. If yes then Stop.
   --           If not delete the assignment with old location and create a new assignment
   --           with the new location.
   ----------------------------------------------------------------------------------------
   ELSIF (p_location_id <> p_location_id_old) THEN

      pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 1: Location is changed.');
      ---------------------------------------------------------------------------------
      -- Check if the assignment is associated with a locked Area or Expense Class in
      -- Recoveries. If yes then Stop.
      ---------------------------------------------------------------------------------
      IF cust_assign_assoc_exp_area_dt(
                                       p_tenancy_id              => p_tenancy_id
                                      ,p_chk_locked              => TRUE
                                      ,p_cust_assign_start_dt    => p_cust_assign_start_dt_old
                                      ,p_cust_assign_end_dt      => p_cust_assign_end_dt_old
                                      )
      THEN
         p_action := 'S';
         RETURN;
      ELSE

         ---------------------------------------------------------------------------------
         -- Check if the assignment is associated with a any Area or Expense Class in
         -- Recoveries. If yes then need to show message to regenerate Area/Expense class.
         ---------------------------------------------------------------------------------
         IF cust_assign_assoc_exp_area_dt(
                                       p_tenancy_id => p_tenancy_id
                                      ,p_chk_locked => FALSE
                                      )
         THEN
            p_action :='R';
         END IF;

         ------------------------------------------------------------------------
         -- Delete the assignment with old location and create a new assignment.
         ------------------------------------------------------------------------
         delete_auto_space_assign(
                                       p_tenancy_id              => p_tenancy_id
                                      ,p_cust_assign_start_date  => p_cust_assign_start_dt_old
                                      ,p_cust_assign_end_date    => p_cust_assign_end_dt_old
                                      ,p_action                  => p_action
                                      );

         ------------------------------------------------------------------------
         -- Create a new assignment with the new location.
         ------------------------------------------------------------------------
         create_auto_space_assign(
                                       p_location_id             => p_location_id
                                      ,p_lease_id                => p_lease_id
                                      ,p_customer_id             => p_customer_id
                                      ,p_cust_site_use_id        => p_cust_site_use_id
                                      ,p_cust_assign_start_dt    => p_cust_assign_start_dt
                                      ,p_cust_assign_end_dt      => p_cust_assign_end_dt
                                      ,p_recovery_space_std_code => p_recovery_space_std_code
                                      ,p_recovery_type_code      => p_recovery_type_code
                                      ,p_fin_oblig_end_date      => p_fin_oblig_end_date
				      ,p_allocated_pct           => p_allocated_pct
                                      ,p_tenancy_id              => p_tenancy_id
                                      ,p_org_id                  => p_org_id
                                      ,p_action                  => p_action
                                      ,p_msg                     => p_msg
                                      );
      END IF;

   ELSE
      ----------------------------------------------------------------------------------------
      -- Location is not changed.
      -- Check# 2. Are the tenancy start and end dates are changed. Following 4 case apply:
      --           1. Tenancy Start date brought in.
      --           2. Tenancy Start date expanded out.
      --           3. Tenancy End   date brought in.
      --           4. Tenancy End   date expanded out.
      ----------------------------------------------------------------------------------------
      IF (p_cust_assign_start_dt <> p_cust_assign_start_dt_old) OR
         (p_cust_assign_end_dt <> p_cust_assign_end_dt_old)
      THEN

         pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: Tenancy start/end dates are changed.');
         ---------------------------------------------------------------------------------
         -- Check if the assignment is associated with a any Area or Expense Class in
         -- Recoveries. If yes then need to show message to regenerate Area/Expense class.
         ---------------------------------------------------------------------------------
         IF cust_assign_assoc_exp_area_dt(
                                       p_tenancy_id => p_tenancy_id
                                      ,p_chk_locked => FALSE
                                      )
         THEN
            p_action :='R';
         END IF;

         ---------------------------------------------------------------------------------
         -- 1. Tenancy Start date brought in.
         --    If the assignment is NOT associated with a any Area or Expense Class in
         --    Recoveries, remove all the assignments prior to new tenancy start date.
         ---------------------------------------------------------------------------------
         IF p_cust_assign_start_dt > p_cust_assign_start_dt_old THEN

            pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 1. Tenancy Start date brought in.');

            IF cust_assign_assoc_exp_area_dt(
                                       p_tenancy_id              => p_tenancy_id
                                      ,p_chk_locked              => TRUE
                                      ,p_cust_assign_start_dt    => p_cust_assign_start_dt_old
                                      ,p_cust_assign_end_dt      => p_cust_assign_end_dt_old
                                      )
            THEN
               p_action := 'S';
               RETURN;
            ELSE

               DELETE FROM pn_space_assign_cust_all
               WHERE  tenancy_id = p_tenancy_id
               AND    cust_assign_end_date < p_cust_assign_start_dt;
               l_count := 0;
               l_count := SQL%ROWCOUNT;
               pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 1. Rows Deleted: '||l_count);

               UPDATE pn_space_assign_cust_all
                  SET cust_assign_start_date = p_cust_assign_start_dt
                     ,last_update_date       = SYSDATE
                     ,last_updated_by        = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
               WHERE  tenancy_id = p_tenancy_id
               AND    cust_assign_start_date < p_cust_assign_start_dt
               AND    cust_assign_end_date >= p_cust_assign_start_dt;
               l_count := 0;
               l_count := SQL%ROWCOUNT;
               pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 1. Rows Updated: '||l_count);

            END IF;

         ---------------------------------------------------------------------------------
         -- 2. Tenancy Start date expanded out.
         --    Need to extend the 1st assignment.
         ---------------------------------------------------------------------------------
         ELSIF p_cust_assign_start_dt < p_cust_assign_start_dt_old THEN
            l_extend_assgn := TRUE;
         END IF;

         ---------------------------------------------------------------------------------
         -- 3. Tenancy End date brought in.
         --    If the assignment is NOT associated with a any Area or Expense Class in
         --    Recoveries, remove all the assignments after the new tenancy end date.
         --    Note: Update the fin_oblig_end_date for the last assignment.
         ---------------------------------------------------------------------------------
         IF p_cust_assign_end_dt < p_cust_assign_end_dt_old THEN

            pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 3. Tenancy End date brought in.');

            IF cust_assign_assoc_exp_area_dt(
                                       p_tenancy_id              => p_tenancy_id
                                      ,p_chk_locked              => TRUE
                                      ,p_cust_assign_start_dt    => p_cust_assign_start_dt_old
                                      ,p_cust_assign_end_dt      => p_cust_assign_end_dt_old
                                      )
            THEN
               p_action := 'S';
               RETURN;
            ELSE

               DELETE FROM pn_space_assign_cust_all
               WHERE  tenancy_id = p_tenancy_id
               AND    cust_assign_start_date > p_cust_assign_end_dt;
               l_count := 0;
               l_count := SQL%ROWCOUNT;
               pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 3. Rows Deleted: '||l_count);

               UPDATE pn_space_assign_cust_all
                  SET cust_assign_end_date   = p_cust_assign_end_dt
                     ,fin_oblig_end_date     = p_fin_oblig_end_date
                     ,last_update_date       = SYSDATE
                     ,last_updated_by        = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
               WHERE  tenancy_id = p_tenancy_id
               AND    cust_assign_start_date <= p_cust_assign_end_dt
               AND    cust_assign_end_date > p_cust_assign_end_dt;
               l_count := 0;
               l_count := SQL%ROWCOUNT;
               pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 3. Rows Updated: '||l_count);

            END IF;

         ---------------------------------------------------------------------------------
         -- 4. Tenancy End date expanded out.
         --    Need to extend the last assignment.
         ---------------------------------------------------------------------------------
         ELSIF p_cust_assign_end_dt > p_cust_assign_end_dt_old THEN
            l_extend_assgn := TRUE;
         END IF;

         ---------------------------------------------------------------------------------
         -- 2. Tenancy Start date expanded out: Need to extend the 1st assignment.
         -- 4. Tenancy End   date expanded out: Need to extend the last assignment.
         ---------------------------------------------------------------------------------
         IF l_extend_assgn THEN

            pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 2: 2/4. Tenancy Start/End'
                                ||' expanded out.');
            ---------------------------------------------------------------------------------
            -- Initialize the PL/SQL table space_assign_tbl.
            ---------------------------------------------------------------------------------
            space_assign_tbl.delete;

            ---------------------------------------------------------------------------------
            -- Check the Multi-Tenancy-Profile, and space the available.
            ---------------------------------------------------------------------------------
            chk_multi_tenancy_profile(
                                       p_location_id              => p_location_id
                                      ,p_lease_id                 => p_lease_id
                                      ,p_cust_assign_start_dt     => p_cust_assign_start_dt
                                      ,p_cust_assign_end_dt       => p_cust_assign_end_dt
                                      ,p_old_cust_assign_start_dt => p_cust_assign_start_dt_old
                                      ,p_old_cust_assign_end_dt   => p_cust_assign_end_dt_old
                                      ,p_fin_oblig_end_date       => p_fin_oblig_end_date
                                      ,p_chk_vacancy              => TRUE
                                      ,p_count                    => 1
                                      ,p_action                   => p_action
                                      ,p_loc_type_code            => l_loc_type_code
                                      );

            IF p_action IN ('OVERLAP') THEN
               RETURN;
            ELSE

               ---------------------------------------------------------------------------------
               -- If PL/SQL table space_assign_info_tbl is not populated, populate it.
               ---------------------------------------------------------------------------------
               IF space_assign_info_tbl.count = 0 THEN
                  populate_space_assign_info(
                                       p_location_id                   => p_location_id
                                      ,p_from_date                     => p_cust_assign_start_dt
                                      ,p_to_date                       => p_cust_assign_end_dt
                                      ,p_fin_oblig_end_date            => p_fin_oblig_end_date
                                      ,p_loc_type_code                 => l_loc_type_code
                                      );
               END IF;

               ---------------------------------------------------------------------------------
               -- 2. Tenancy Start date expanded out: Need to extend the 1st assignment.
               ---------------------------------------------------------------------------------
               IF p_cust_assign_start_dt < p_cust_assign_start_dt_old THEN

                  OPEN csr_min_cust_assign;
                  FETCH csr_min_cust_assign
                  INTO  l_min_cust_assign_id,
                        l_min_cust_start_date,
                        l_min_cust_end_date,
                        l_allocated_area;
                  CLOSE csr_min_cust_assign;

                  FOR i IN 0..space_assign_info_tbl.count-1
                  LOOP
                     IF l_min_cust_start_date > space_assign_info_tbl(i).cust_assign_start_date THEN

                        IF l_min_cust_start_date = space_assign_info_tbl(i).cust_assign_end_date+1 AND
                           l_allocated_area = space_assign_info_tbl(i).allocated_area
                        THEN

                           pnp_debug_pkg.debug('   Case: 2. Update Space Assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                           UPDATE pn_space_assign_cust_all
                              SET cust_assign_start_date = space_assign_info_tbl(i).cust_assign_start_date
                           WHERE  cust_space_assign_id = l_min_cust_assign_id;
                        ELSE

                           pnp_debug_pkg.debug('   Case: 2. Create Space Assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                           space_assign_tbl(j).cust_assign_start_date :=
                              space_assign_info_tbl(i).cust_assign_start_date;
                           space_assign_tbl(j).cust_assign_end_date :=
                              space_assign_info_tbl(i).cust_assign_end_date;
                           space_assign_tbl(j).fin_oblig_end_date :=
                              space_assign_info_tbl(i).fin_oblig_end_date;
                           space_assign_tbl(j).allocated_area :=
                              space_assign_info_tbl(i).allocated_area;
                           space_assign_tbl(j).allocated_area_pct :=
                              space_assign_info_tbl(i).allocated_area_pct;
                           j := j + 1;
                        END IF;

                     ELSE
                        pnp_debug_pkg.debug('   Case: 2. no space assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                     END IF;
                  END LOOP;
               END IF;

               ---------------------------------------------------------------------------------
               -- 4. Tenancy End   date expanded out: Need to extend the last assignment.
               --    Note: Update the fin_oblig_end_date for the last assignment.
               ---------------------------------------------------------------------------------
               IF p_cust_assign_end_dt > p_cust_assign_end_dt_old THEN
                  OPEN csr_max_cust_assign;
                  FETCH csr_max_cust_assign
                  INTO  l_max_cust_assign_id,
                        l_max_cust_start_date,
                        l_max_cust_end_date,
                        l_allocated_area;
                  CLOSE csr_max_cust_assign;

                  pnp_debug_pkg.debug('Case: 4. Tenancy End expanded out. '
                           ||', l_max_assign_id: '||l_max_cust_assign_id
                           ||', l_max_start_date: '||l_max_cust_start_date
                           ||', l_max_end_date: '||l_max_cust_end_date
                           ||', l_area: '||l_allocated_area
                           ||',');

                  FOR i IN 0 .. space_assign_info_tbl.count-1
                  LOOP

                     IF NVL(l_max_cust_end_date, space_assign_info_tbl(i).cust_assign_end_date) <
                        space_assign_info_tbl(i).cust_assign_end_date
                     THEN

                        IF NVL(l_max_cust_end_date+1, space_assign_info_tbl(i).cust_assign_start_date) =
                           space_assign_info_tbl(i).cust_assign_start_date AND
                           l_allocated_area = space_assign_info_tbl(i).allocated_area
                        THEN

                           pnp_debug_pkg.debug('   Case: 4. Update Space Assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                           -----------------------------------------------------------------------
                           -- Determine the correct fin_oblig_end_date.
                           -----------------------------------------------------------------------
                           IF i = space_assign_info_tbl.count-1 THEN
                              l_fin_oblig_end_date := p_fin_oblig_end_date;
                           ELSE
                              l_fin_oblig_end_date := space_assign_info_tbl(i).cust_assign_end_date;
                           END IF;

                           UPDATE pn_space_assign_cust_all
                              SET cust_assign_end_date = space_assign_info_tbl(i).cust_assign_end_date
                                 ,fin_oblig_end_date   = l_fin_oblig_end_date
                           WHERE  cust_space_assign_id = l_max_cust_assign_id;

                        ELSE

                           pnp_debug_pkg.debug('   Case: 4. Create Space Assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                           -----------------------------------------------------------------------
                           -- Determine and update the correct fin_oblig_end_date.
                           -----------------------------------------------------------------------
                           IF NVL(l_max_cust_end_date+1, space_assign_info_tbl(i).cust_assign_start_date) =
                              space_assign_info_tbl(i).cust_assign_start_date
                           THEN
                              UPDATE pn_space_assign_cust_all
                                 SET fin_oblig_end_date   = cust_assign_end_date
                              WHERE  cust_space_assign_id = l_max_cust_assign_id;
                           END IF;

                           space_assign_tbl(j).cust_assign_start_date :=
                              space_assign_info_tbl(i).cust_assign_start_date;
                           space_assign_tbl(j).cust_assign_end_date :=
                              space_assign_info_tbl(i).cust_assign_end_date;
                           space_assign_tbl(j).fin_oblig_end_date :=
                              space_assign_info_tbl(i).fin_oblig_end_date;
                           space_assign_tbl(j).allocated_area :=
                              space_assign_info_tbl(i).allocated_area;
                           space_assign_tbl(j).allocated_area_pct :=
                              space_assign_info_tbl(i).allocated_area_pct;
                           j := j + 1;

                        END IF;

                     ELSE
                        pnp_debug_pkg.debug('   Case: 4. no space assgn... i: '||i
                           ||', start_date: '||space_assign_info_tbl(i).cust_assign_start_date
                           ||', end_date: '||space_assign_info_tbl(i).cust_assign_end_date
                           ||', area: '||space_assign_info_tbl(i).allocated_area
                           ||',');

                     END IF;
                  END LOOP;
               END IF;

               ---------------------------------------------------------------------------------
               -- If required insert new space assignment rows to Expand Out tenancy dates.
               ---------------------------------------------------------------------------------
               IF space_assign_tbl.count > 0 THEN
                  insert_space_assign_row(
                                       p_location_id             => p_location_id
                                      ,p_lease_id                => p_lease_id
                                      ,p_customer_id             => p_customer_id
                                      ,p_cust_site_use_id        => p_cust_site_use_id
                                      ,p_recovery_space_std_code => p_recovery_space_std_code
                                      ,p_recovery_type_code      => p_recovery_type_code
                                      ,p_fin_oblig_end_date      => p_fin_oblig_end_date
                                      ,p_tenancy_id              => p_tenancy_id
                                      ,p_org_id                  => p_org_id
                                      ,p_space_assign_info_tbl   => space_assign_tbl
                                      ,p_return_status           => l_return_status
                                      );

               END IF;

               IF l_return_status IS NOT NULL THEN
                  p_action := l_return_status;
                  RETURN;
               END IF;

            END IF;

         ---------------------------------------------------------------------------------
         -- End expanding out Tenancy Dates.
         ---------------------------------------------------------------------------------
         END IF;
      END IF;

      ----------------------------------------------------------------------------------------
      -- Location is not changed.
      -- Check# 3. Is the fin_oblig_end_date changed.
      --           Update the fin_oblig_end_date for the last assignment.
      ----------------------------------------------------------------------------------------
      IF (NVL(p_fin_oblig_end_date, l_StartOfTime) <>
          NVL(p_fin_oblig_end_date_old, l_StartOfTime)) THEN

         pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 3: fin_oblig_end_date is changed.');

         IF p_fin_oblig_end_date_old IS NOT NULL THEN
            UPDATE pn_space_assign_cust_all
               SET fin_oblig_end_date              = p_fin_oblig_end_date
                  ,last_update_date                = SYSDATE
                  ,last_updated_by                 = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
            WHERE  tenancy_id = p_tenancy_id
            AND    fin_oblig_end_date = p_fin_oblig_end_date_old;
         ELSE
            UPDATE pn_space_assign_cust_all
               SET fin_oblig_end_date              = p_fin_oblig_end_date
                  ,last_update_date                = SYSDATE
                  ,last_updated_by                 = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
            WHERE  tenancy_id = p_tenancy_id
            AND    cust_assign_end_date = p_cust_assign_end_dt;
         END IF;

      END IF;

      ----------------------------------------------------------------------------------------
      -- Location is not changed.
      -- Check# 4. Is any of customer_id, cust_site_use_id, recovery_space_std_code OR
      --              recovery_type_code changed:
      --           Update all space assignment records with new values.
      ----------------------------------------------------------------------------------------
      IF (NVL(p_customer_id, -99) <>
          NVL(p_customer_id_old, -99)) OR
         (NVL(p_cust_site_use_id, -99) <>
          NVL(p_cust_site_use_id_old, -99)) OR
         (NVL(p_recovery_space_std_code, '   ') <>
          NVL(p_recovery_space_std_code_old, '   ')) OR
         (NVL(p_recovery_type_code, '   ') <>
          NVL(p_recovery_type_code_old, '   '))
      THEN

         pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 4: customer_id/cust_site_use_id/'
                             ||'space_std/recovery_type is changed.');

         /*IF (NVL(p_customer_id, -99) <> NVL(p_customer_id_old, -99)) THEN

            pn_space_assign_cust_pkg.chk_dup_cust_assign(
                       p_cust_acnt_id  => p_customer_id
                      ,p_loc_id        => p_location_id
                      ,p_assgn_str_dt  => p_cust_assign_start_dt
                      ,p_assgn_end_dt  => p_cust_assign_end_dt
                      ,p_return_status => l_return_status
                      );

            IF l_return_status IS NOT NULL THEN
               p_action := l_return_status;
               RETURN;
            END IF;
         END IF;*/

         UPDATE pn_space_assign_cust_all
            SET cust_account_id                 = p_customer_id
               ,site_use_id                     = p_cust_site_use_id
               ,recovery_space_std_code         = p_recovery_space_std_code
               ,recovery_type_code              = p_recovery_type_code
               ,last_update_date                = SYSDATE
               ,last_updated_by                 = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
         WHERE  tenancy_id = p_tenancy_id;

      END IF;

      ----------------------------------------------------------------------------------------
      -- Location is not changed.
      -- Check# 5. Is Allocated_area_pct is changed
      --           Update all space assignment records with new value for that tenanct_id.
      ----------------------------------------------------------------------------------------
      IF (nvl(p_allocated_pct,-1) <> nvl(p_allocated_pct_old,-1)) THEN

         pnp_debug_pkg.debug('Update_Auto_Space_Assign : Check# 5: allocated_area_pct is changed.');

	 IF p_allocated_pct IS NOT NULL THEN
	   FOR rec_alloc_area IN cur_alloc_area LOOP
	   l_cust_assign_start_date := rec_alloc_area.cust_assign_start_date;
	   l_cust_assign_end_date := rec_alloc_area.cust_assign_end_date;

	    get_allocated_area(
                        p_cust_assign_start_date => l_cust_assign_start_date,
                        p_cust_assign_end_date   => l_cust_assign_end_date,
                        p_allocated_area_pct     => p_allocated_pct,
                        p_allocated_area         => l_allocated_area);

            UPDATE pn_space_assign_cust_all
               SET allocated_area_pct              = p_allocated_pct
	           ,allocated_area                 = l_allocated_area
            WHERE  tenancy_id = p_tenancy_id
	    AND cust_assign_start_date = l_cust_assign_start_date;

    	   END LOOP;
         END IF;

      END IF;

   END IF;

   pnp_debug_pkg.debug('l_auto_space_dist: '||l_auto_space_dist||', l_loc_type_code: '||l_loc_type_code);
   IF l_loc_type_code IS NULL THEN
      l_loc_type_code := get_loc_type_code(p_location_id, p_cust_assign_start_dt);
   END IF;

   -- 110403
   IF NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N') = 'Y' AND
      l_loc_type_code IN ('OFFICE', 'SECTION')
   THEN

     PN_SPACE_ASSIGN_CUST_PKG.assignment_split(
        p_location_id => p_location_id,
        p_start_date  => p_cust_assign_start_dt,
        p_end_date    => p_cust_assign_end_dt);

   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_AUTO_SPACE_ASSIGN (-)');
EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Update_auto_space_assign - Errmsg: ' || sqlerrm);
      RAISE;
END update_auto_space_assign;


--------------------------------------------------------------------------------
-- PROCEDURE  : UPDATE_DUP_SPACE_ASSIGN
-- DESCRIPTION:
--
-- 05-MAR-04 STripathi o Created for ENH# 3485730. If Only one duplicate
--                       assign exist, update that assign with lease and
--                       tenancy details.
-- 08-MAR-04 STripathi o Do not update start and end date while updating
--                       the assign. Call update_auto_space_assign to
--                       update start date, end date and fin_oblog_end_dt.
-- 10-MAR-04 STripathi o Added NVL to cust_assign_end_date and start date
--                       since it can have null value from PNTSPACE.
-- 28-NOV-05 pikhar    o passed org_id in pn_mo_cache_utils.get_profile_value
--------------------------------------------------------------------------------
PROCEDURE Update_Dup_Space_Assign(
                 p_location_id                      IN     NUMBER
                ,p_customer_id                      IN     NUMBER
                ,p_lease_id                         IN     NUMBER
                ,p_tenancy_id                       IN     NUMBER
                ,p_cust_site_use_id                 IN     NUMBER
                ,p_cust_assign_start_dt             IN     DATE
                ,p_cust_assign_end_dt               IN     DATE
                ,p_recovery_space_std_code          IN     VARCHAR2
                ,p_recovery_type_code               IN     VARCHAR2
                ,p_fin_oblig_end_date               IN     DATE
		,p_allocated_pct                    IN     NUMBER
                ,p_org_id                           IN     NUMBER
                ,p_action                              OUT NOCOPY VARCHAR2
                ,p_msg                                 OUT NOCOPY VARCHAR2
                )
IS
   CURSOR get_cust_space_assign_id IS
      SELECT cust_space_assign_id,
             NVL(cust_assign_start_date, pnt_locations_pkg.g_start_of_time) cust_assign_start_date,
             NVL(cust_assign_end_date, pnt_locations_pkg.g_end_of_time) cust_assign_end_date
      FROM   pn_space_assign_cust_all
      WHERE  cust_account_id = p_customer_id
      AND    location_id = p_location_id
      AND    cust_assign_start_date <= p_cust_assign_end_dt
      AND    NVL(cust_assign_end_date, TO_DATE('12/31/4712', 'MM/DD/YYYY'))
             >= p_cust_assign_start_dt;


   l_cust_space_assign_id          NUMBER;
   l_cust_assign_start_date        DATE;
   l_cust_assign_end_date          DATE;
   l_auto_space_dist               VARCHAR2(20) := NULL;

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_locations_all pnl
    WHERE  pnl.location_id = p_location_id
    AND    ROWNUM < 2;

   l_org_id NUMBER;


BEGIN

   FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
   END LOOP;

   l_auto_space_dist := NVL(pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id),'N');
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_DUP_SPACE_ASSIGN (+) Auto_Space_Dist: '
                       ||l_auto_space_dist);
   p_action := NULL;

   OPEN get_cust_space_assign_id;
   FETCH get_cust_space_assign_id
   INTO l_cust_space_assign_id,
        l_cust_assign_start_date,
        l_cust_assign_end_date;
   CLOSE get_cust_space_assign_id;

   IF l_cust_space_assign_id IS NOT NULL THEN

      UPDATE pn_space_assign_cust_all
         SET lease_id                = p_lease_id
            ,tenancy_id              = p_tenancy_id
            ,cust_assign_start_date  = NVL(cust_assign_start_date, pnt_locations_pkg.g_start_of_time)
            ,cust_assign_end_date    = NVL(cust_assign_end_date, pnt_locations_pkg.g_end_of_time)
            ,site_use_id             = p_cust_site_use_id
            ,recovery_space_std_code = p_recovery_space_std_code
            ,recovery_type_code      = p_recovery_type_code
            ,fin_oblig_end_date      = NVL(cust_assign_end_date, pnt_locations_pkg.g_end_of_time)
            ,last_update_date        = SYSDATE
            ,last_updated_by         = NVL(FND_PROFILE.VALUE('USER_ID'),-1)
      WHERE  cust_space_assign_id = l_cust_space_assign_id;


      pn_tenancies_pkg.update_auto_space_assign
      (
         p_location_id                   => p_location_id
        ,p_lease_id                      => p_lease_id
        ,p_customer_id                   => p_customer_id
        ,p_cust_site_use_id              => p_cust_site_use_id
        ,p_cust_assign_start_dt          => p_cust_assign_start_dt
        ,p_cust_assign_end_dt            => p_cust_assign_end_dt
        ,p_recovery_space_std_code       => p_recovery_space_std_code
        ,p_recovery_type_code            => p_recovery_type_code
        ,p_fin_oblig_end_date            => p_fin_oblig_end_date
	,p_allocated_pct                 => p_allocated_pct
        ,p_tenancy_id                    => p_tenancy_id
        ,p_org_id                        => p_org_id
        ,p_location_id_old               => p_location_id
        ,p_customer_id_old               => p_customer_id
        ,p_cust_site_use_id_old          => p_cust_site_use_id
        ,p_cust_assign_start_dt_old      => l_cust_assign_start_date
        ,p_cust_assign_end_dt_old        => l_cust_assign_end_date
        ,p_recovery_space_std_code_old   => p_recovery_space_std_code
        ,p_recovery_type_code_old        => p_recovery_type_code
        ,p_fin_oblig_end_date_old        => p_fin_oblig_end_date
	,p_allocated_pct_old             => p_allocated_pct
        ,p_action                        => p_action
        ,p_msg                           => p_msg
      );


   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.UPDATE_DUP_SPACE_ASSIGN (-)');

END Update_Dup_Space_Assign;

-------------------------------------------------------------------------------
-- FUNCTION     : Auto_Allocated_Area_Pct
-- INVOKED FROM :
-- PURPOSE      : Retrieves allocated area % for the particular Tenancy_id
-- HISTORY      :
-- 07-DEC-2006  Ram Kumar o created
-------------------------------------------------------------------
FUNCTION Auto_Allocated_Area_Pct
(
    p_tenancy_id                   IN      NUMBER
)
RETURN NUMBER
IS
   l_allocated_area_pct            NUMBER;
   l_lease_class_code              VARCHAR2(30);

   CURSOR cur_allocated_area_pct IS
      SELECT min(allocated_area_pct) min_area_pct
      FROM   pn_space_assign_cust_all
      WHERE  tenancy_id = p_tenancy_id;

  CURSOR cur_lease_code IS
     SELECT  leases.lease_class_code lease_code,
             allocated_area_pct
     FROM    pn_leases_all leases,
             pn_tenancies_all tenant
     WHERE   leases.lease_id = tenant.lease_id
     AND tenant.tenancy_id = p_tenancy_id;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Auto_Allocated_Area_Pct (+)');

   --
   FOR rec_allocated_area_pct IN cur_allocated_area_pct LOOP
   l_allocated_area_pct := rec_allocated_area_pct.min_area_pct;
   END LOOP;

   FOR rec_lease_code IN cur_lease_code LOOP
     l_lease_class_code   := rec_lease_code.lease_code;
     l_allocated_area_pct := nvl(l_allocated_area_pct,rec_lease_code.allocated_area_pct);
   END LOOP;

   IF l_lease_class_code = 'DIRECT' THEN
     l_allocated_area_pct := NULL;
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Auto_Allocated_Area_Pct (-)');

   RETURN l_allocated_area_pct;

END Auto_Allocated_Area_Pct;

-------------------------------------------------------------------------------
-- FUNCTION     : Auto_Allocated_Area
-- INVOKED FROM :
-- PURPOSE      : Retrieves allocated area for the particular Tenancy_id
-- HISTORY      :
-- 07-DEC-2006  Ram Kumar o created
-------------------------------------------------------------------
FUNCTION Auto_Allocated_Area
(
    p_tenancy_id                   IN      NUMBER
)
RETURN NUMBER
IS
   l_allocated_area            NUMBER := NULL;
   l_lease_class_code          VARCHAR2(30);

   CURSOR cur_allocated_area IS
      SELECT min(allocated_area) min_area
      FROM   pn_space_assign_cust_all
      WHERE  tenancy_id = p_tenancy_id;

   CURSOR get_lease_class IS
     SELECT  leases.lease_class_code lease_code,
             allocated_area
     FROM    pn_leases_all leases,
             pn_tenancies_all tenant
     WHERE   leases.lease_id = tenant.lease_id
     AND tenant.tenancy_id = p_tenancy_id;


BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Auto_Allocated_Area (+)');

   --
   FOR rec_allocated_area IN cur_allocated_area LOOP
   l_allocated_area := rec_allocated_area.min_area;
   END LOOP;

   FOR rec_lease_code IN get_lease_class LOOP
     l_lease_class_code := rec_lease_code.lease_code;
     l_allocated_area   := nvl(l_allocated_area,rec_lease_code.allocated_area);
   END LOOP;

   IF l_lease_class_code = 'DIRECT' THEN
      l_allocated_area := NULL;
   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Auto_Allocated_Area (-)');

   RETURN l_allocated_area;

END Auto_Allocated_Area;

-------------------------------------------------------------------------------
-- FUNCTION     : Availaible_Space
-- INVOKED FROM :
-- PURPOSE      : Retrieves minimum allowable area % for the particular Tenancy_id
-- HISTORY      :
-- 07-DEC-2006  Ram Kumar o created
-------------------------------------------------------------------
PROCEDURE Availaible_Space(
                 p_location_id                   IN NUMBER
                ,p_from_date                     IN DATE
                ,p_to_date                       IN DATE
                ,p_min_pct                       OUT NOCOPY NUMBER
                )
IS
   p_min_area           NUMBER;
   CURSOR csr_cust_info IS
      SELECT cust_assign_start_date,
             NVL(cust_assign_end_date, p_to_date) cust_assign_end_date,
             nvl(allocated_area,0) allocated_area
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
      AND    cust_assign_start_date <= p_to_date
      AND    NVL(cust_assign_end_date, p_to_date) >= p_from_date;

   CURSOR csr_emp_info IS
      SELECT emp_assign_start_date,
             NVL(emp_assign_end_date, p_to_date) emp_assign_end_date,
             nvl(allocated_area,0) allocated_area
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
      AND    emp_assign_start_date <= p_to_date
      AND    NVL(emp_assign_end_date, p_to_date) >= p_from_date;

   l_loc_type_code   pn_locations_all.location_type_lookup_code%TYPE;
   l_num_table       pn_recovery_extract_pkg.number_table_TYPE;
   l_date_table      pn_recovery_extract_pkg.date_table_TYPE;
   i                 NUMBER := 0;
   j                 NUMBER := 0;

BEGIN
   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Availaible_Space (+)');

   get_loc_info(p_location_id   => p_location_id,
                p_from_date     => p_from_date,
                p_to_date       => p_to_date,
                p_loc_type_code => l_loc_type_code);

   IF l_loc_type_code IN ('OFFICE', 'SECTION') THEN

      FOR i IN 0 .. loc_info_tbl.count-1
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => loc_info_tbl(i).active_start_date,
                 p_end_date     => loc_info_tbl(i).active_end_date,
                 p_area         => loc_info_tbl(i).assignable_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => TRUE);
      END LOOP;

      FOR rec_cust_info IN csr_cust_info
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => rec_cust_info.cust_assign_start_date,
                 p_end_date     => rec_cust_info.cust_assign_end_date,
                 p_area         => rec_cust_info.allocated_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => FALSE);
      END LOOP;

      FOR rec_emp_info IN csr_emp_info
      LOOP
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => rec_emp_info.emp_assign_start_date,
                 p_end_date     => rec_emp_info.emp_assign_end_date,
                 p_area         => rec_emp_info.allocated_area,
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => FALSE);
      END LOOP;

      p_min_area := l_num_table(0);
     FOR i IN 0 .. l_num_table.count-1
      LOOP
	IF(p_min_area >  l_num_table(i)) THEN
                p_min_area := l_num_table(i);
        END IF;
      END LOOP;

        get_allocated_area_pct(
                        p_cust_assign_start_date => p_from_date,
                        p_cust_assign_end_date   => p_to_date,
                        p_allocated_area         => p_min_area,
                        p_alloc_area_pct         => p_min_pct);

   END IF;

   pnp_debug_pkg.debug('PN_TENANCIES_PKG.Availaible_Space (-)');
EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.log('Availaible_Space - Errmsg: ' || sqlerrm);
      RAISE;

END Availaible_Space;

END pn_tenancies_pkg;

/
