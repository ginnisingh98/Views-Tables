--------------------------------------------------------
--  DDL for Package Body PN_SPACE_ASSIGN_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SPACE_ASSIGN_CUST_PKG" AS
/* $Header: PNSPCUSB.pls 120.12 2007/02/14 12:31:55 rdonthul ship $ */

-------------------------------------------------------------------------------
-- PROCEDURE    : Insert_Row
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 05-MAR-04 ftanudja  o Replaced check_dupcust.. w/ chk_dup_cust..
-- 14-DEC-04 STripath  o Modified for Portfolio Status Enh BUG# 4030816. Added
--                       code to check loc is contigious assignable betn assign
--                       start and end dates.
-- 30-JUN-05  hrodda   o Bug 4284035 - Replaced pn_space_assign_cust
--                       with _ALL table.
-- 08-SEP-o5  hrodda   o Modified insert statement to include org_id.
-- 28-NOV-05  pikhar   o fetched org_id using cursor.
-- 08-Feb-07  rdonthul o Removed the check fro duplicate space assignments
--                       for bug fix 5864468
-------------------------------------------------------------------------------

PROCEDURE Insert_Row (
  X_ROWID                         IN OUT NOCOPY VARCHAR2,
  X_CUST_SPACE_ASSIGN_ID          IN OUT NOCOPY NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
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
  X_ORG_ID                        IN     NUMBER,
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER,
  X_RETURN_STATUS                 OUT NOCOPY VARCHAR2
  )
IS
   CURSOR c IS
      SELECT ROWID
      FROM pn_space_assign_cust_all
      WHERE cust_space_assign_id = x_cust_space_assign_id;

   l_status                        VARCHAR2(100);
   l_err_msg                       VARCHAR2(30);

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_locations_all
    WHERE  location_id = x_location_id;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.INSERT_ROW (+) SpcAsgnId: '
                        ||x_cust_space_assign_id||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_cust_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_cust_assign_end_date, 'MM/DD/YYYY')
                        ||', CustId: '||x_cust_account_id);

   -- Check if location is contigious Customer Assignable betn assign start and end dates.
   pnt_locations_pkg.Check_Location_Gaps(
                          p_loc_id     => x_location_id
                         ,p_str_dt     => x_cust_assign_start_date
                         ,p_end_dt     => NVL(x_cust_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'))
                         ,p_asgn_mode  => 'CUST'
                         ,p_err_msg    => l_err_msg
                          );

   IF l_err_msg IS NOT NULL THEN
      fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
      x_return_status := 'INVALID_LOC_DATE';
      return;
   END IF;

   /* pn_space_assign_cust_pkg.chk_dup_cust_assign(
                 p_cust_acnt_id  => x_cust_account_id
                ,p_loc_id        => x_location_id
                ,p_assgn_str_dt  => x_cust_assign_start_date
                ,p_assgn_end_dt  => x_cust_assign_end_date
                ,p_return_status => l_status);

   IF l_status = 'DUP_ASSIGN' THEN
      fnd_message.set_name('PN', 'PN_SPASGN_CUSTOMER_OVRLAP_MSG');
      x_return_status := 'DUP_ASSIGN';
      return;
   END IF; */

   -------------------------------------------------------
   -- Select the nextval for cust space assign id
   -------------------------------------------------------
   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   IF ( X_CUST_SPACE_ASSIGN_ID IS NULL) THEN
      SELECT  pn_space_assign_cust_s.NEXTVAL
      INTO    x_cust_space_assign_id
      FROM    DUAL;
   END IF;

  INSERT INTO pn_space_assign_cust_all
  (         CUST_SPACE_ASSIGN_ID,
            LOCATION_ID,
            CUST_ACCOUNT_ID,
            SITE_USE_ID,
            EXPENSE_ACCOUNT_ID,
            PROJECT_ID,
            TASK_ID,
            CUST_ASSIGN_START_DATE,
            CUST_ASSIGN_END_DATE,
            ALLOCATED_AREA_PCT,
            ALLOCATED_AREA,
            UTILIZED_AREA,
            CUST_SPACE_COMMENTS,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
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
            LEASE_ID,
            RECOVERY_SPACE_STD_CODE,
            RECOVERY_TYPE_CODE,
            FIN_OBLIG_END_DATE,
            TENANCY_ID,
            ORG_ID
          )
   VALUES
          (
            X_CUST_SPACE_ASSIGN_ID,
            X_LOCATION_ID,
            X_CUST_ACCOUNT_ID,
            X_SITE_USE_ID,
            X_EXPENSE_ACCOUNT_ID,
            X_PROJECT_ID,
            X_TASK_ID,
            X_CUST_ASSIGN_START_DATE,
            X_CUST_ASSIGN_END_DATE,
            X_ALLOCATED_AREA_PCT,
            X_ALLOCATED_AREA,
            X_UTILIZED_AREA,
            X_CUST_SPACE_COMMENTS,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_CREATION_DATE,
            X_CREATED_BY,
            X_LAST_UPDATE_LOGIN,
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
            X_LEASE_ID,
            X_RECOVERY_SPACE_STD_CODE,
            X_RECOVERY_TYPE_CODE,
            X_FIN_OBLIG_END_DATE,
            X_TENANCY_ID,
            l_org_id
   );

   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.INSERT_ROW (-) SpcAsgnId: '
                        ||x_cust_space_assign_id||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_cust_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_cust_assign_end_date, 'MM/DD/YYYY')
                        ||', CustId: '||x_cust_account_id);

END Insert_Row;

-----------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-----------------------------------------------------------------------
PROCEDURE Lock_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
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
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER
  )
IS
   CURSOR c1 IS
      SELECT *
      FROM pn_space_assign_cust_all
      WHERE cust_space_assign_id = x_cust_space_assign_id
      FOR UPDATE OF cust_space_assign_id NOWAIT;

BEGIN

    pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.LOCK_ROW (+) SpcAsgnId: '
                        ||x_cust_space_assign_id);

    OPEN c1;
        FETCH c1 INTO tlcustinfo;
        IF (c1%NOTFOUND) THEN
                CLOSE c1;
                RETURN;
        END IF;
    CLOSE c1;

   IF NOT (tlcustinfo.CUST_SPACE_ASSIGN_ID = X_CUST_SPACE_ASSIGN_ID) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_SPACE_ASSIGN_ID',tlcustinfo.CUST_SPACE_ASSIGN_ID);
   END IF;

   IF NOT ((tlcustinfo.LOCATION_ID = X_LOCATION_ID)
               OR ((tlcustinfo.LOCATION_ID is null) AND (X_LOCATION_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlcustinfo.LOCATION_ID);
   END IF;

   IF NOT (tlcustinfo.CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_ACCOUNT_ID',tlcustinfo.CUST_ACCOUNT_ID);
   END IF;

   IF NOT ((tlcustinfo.SITE_USE_ID = X_SITE_USE_ID)
               OR ((tlcustinfo.SITE_USE_ID is null) AND (X_SITE_USE_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('SITE_USE_ID',tlcustinfo.SITE_USE_ID);
   END IF;

   IF NOT ((tlcustinfo.EXPENSE_ACCOUNT_ID = X_EXPENSE_ACCOUNT_ID)
               OR ((tlcustinfo.EXPENSE_ACCOUNT_ID is null) AND (X_EXPENSE_ACCOUNT_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPENSE_ACCOUNT_ID',tlcustinfo.EXPENSE_ACCOUNT_ID);
   END IF;

   IF NOT ((tlcustinfo.PROJECT_ID = X_PROJECT_ID)
               OR ((tlcustinfo.PROJECT_ID is null) AND (X_PROJECT_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ID',tlcustinfo.PROJECT_ID);
   END IF;

   IF NOT ((tlcustinfo.TASK_ID = X_TASK_ID)
               OR ((tlcustinfo.TASK_ID is null) AND (X_TASK_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('TASK_ID',tlcustinfo.TASK_ID);
   END IF;

   IF NOT ((tlcustinfo.CUST_ASSIGN_START_DATE = X_CUST_ASSIGN_START_DATE)
               OR ((tlcustinfo.CUST_ASSIGN_START_DATE is null) AND (X_CUST_ASSIGN_START_DATE is null))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_ASSIGN_START_DATE',tlcustinfo.CUST_ASSIGN_START_DATE);
   END IF;

   IF NOT ((tlcustinfo.CUST_ASSIGN_END_DATE = X_CUST_ASSIGN_END_DATE)
               OR ((tlcustinfo.CUST_ASSIGN_END_DATE is null) AND (X_CUST_ASSIGN_END_DATE is null))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_ASSIGN_END_DATE',tlcustinfo.CUST_ASSIGN_END_DATE);
   END IF;

   IF NOT ((tlcustinfo.ALLOCATED_AREA_PCT = X_ALLOCATED_AREA_PCT)
               OR ((tlcustinfo.ALLOCATED_AREA_PCT is null) AND (X_ALLOCATED_AREA_PCT is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ALLOCATED_AREA_PCT',tlcustinfo.ALLOCATED_AREA_PCT);
   END IF;

   IF NOT ((tlcustinfo.ALLOCATED_AREA = X_ALLOCATED_AREA)
               OR ((tlcustinfo.ALLOCATED_AREA is null) AND (X_ALLOCATED_AREA is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ALLOCATED_AREA',tlcustinfo.ALLOCATED_AREA);
   END IF;

   IF NOT ((tlcustinfo.UTILIZED_AREA = X_UTILIZED_AREA)
               OR ((tlcustinfo.UTILIZED_AREA is null) AND (X_UTILIZED_AREA is null))) THEN
      pn_var_rent_pkg.lock_row_exception('UTILIZED_AREA',tlcustinfo.UTILIZED_AREA);
   END IF;

   IF NOT ((tlcustinfo.CUST_SPACE_COMMENTS = X_CUST_SPACE_COMMENTS)
               OR ((tlcustinfo.CUST_SPACE_COMMENTS is null) AND (X_CUST_SPACE_COMMENTS is null))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_SPACE_COMMENTS',tlcustinfo.CUST_SPACE_COMMENTS);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlcustinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlcustinfo.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlcustinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlcustinfo.ATTRIBUTE1);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlcustinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlcustinfo.ATTRIBUTE2);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlcustinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlcustinfo.ATTRIBUTE3);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlcustinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlcustinfo.ATTRIBUTE4);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlcustinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlcustinfo.ATTRIBUTE5);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlcustinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlcustinfo.ATTRIBUTE6);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlcustinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlcustinfo.ATTRIBUTE7);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlcustinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlcustinfo.ATTRIBUTE8);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlcustinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlcustinfo.ATTRIBUTE9);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlcustinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlcustinfo.ATTRIBUTE10);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlcustinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlcustinfo.ATTRIBUTE11);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlcustinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlcustinfo.ATTRIBUTE12);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlcustinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlcustinfo.ATTRIBUTE13);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlcustinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlcustinfo.ATTRIBUTE14);
   END IF;

   IF NOT ((tlcustinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlcustinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlcustinfo.ATTRIBUTE15);
   END IF;

   IF NOT ((tlcustinfo.LEASE_ID = X_LEASE_ID)
               OR ((tlcustinfo.LEASE_ID is null) AND (X_LEASE_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlcustinfo.LEASE_ID);
   END IF;

   IF NOT ((tlcustinfo.RECOVERY_SPACE_STD_CODE = X_RECOVERY_SPACE_STD_CODE)
               OR ((tlcustinfo.RECOVERY_SPACE_STD_CODE is null) AND (X_RECOVERY_SPACE_STD_CODE is null))) THEN
      pn_var_rent_pkg.lock_row_exception('RECOVERY_SPACE_STD_CODE',tlcustinfo.RECOVERY_SPACE_STD_CODE);
   END IF;

   IF NOT ((tlcustinfo.RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE)
               OR ((tlcustinfo.RECOVERY_TYPE_CODE is null) AND (X_RECOVERY_TYPE_CODE is null))) THEN
      pn_var_rent_pkg.lock_row_exception('RECOVERY_TYPE_CODE',tlcustinfo.RECOVERY_TYPE_CODE);
   END IF;

   IF NOT ((tlcustinfo.FIN_OBLIG_END_DATE = X_FIN_OBLIG_END_DATE)
               OR ((tlcustinfo.FIN_OBLIG_END_DATE is null) AND (X_FIN_OBLIG_END_DATE is null))) THEN
      pn_var_rent_pkg.lock_row_exception('FIN_OBLIG_END_DATE',tlcustinfo.FIN_OBLIG_END_DATE);
   END IF;

   IF NOT ((tlcustinfo.TENANCY_ID = X_TENANCY_ID)
              OR ((tlcustinfo.TENANCY_ID is null) AND (X_TENANCY_ID is null))) THEN
      pn_var_rent_pkg.lock_row_exception('TENANCY_ID',tlcustinfo.TENANCY_ID);
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.LOCK_ROW (-) SpcAsgnId: '
                        ||x_cust_space_assign_id);

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 05-MAR-04 ftanudja o Replaced check_dupcust.. w/ chk_dup_cust..
-- 14-DEC-04 STripath o Modified for Portfolio Status Enh BUG# 4030816. Added
--                      code to check loc is contigious assignable betn assign
--                      start and end dates.
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_space_assign_cust
--                      with _ALL table.
-- 08-SEP-05 Hareesha o Modified insert statement to include org_id.
-- 08-Feb-07 Ram kumar o Removed the check for duplicate Space assignments
--                       for bug fix 5864468
-------------------------------------------------------------------------------

PROCEDURE Update_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER,
  X_LOCATION_ID                   IN     NUMBER,
  X_CUST_ACCOUNT_ID               IN     NUMBER,
  X_SITE_USE_ID                   IN     NUMBER,
  X_EXPENSE_ACCOUNT_ID            IN     NUMBER,
  X_PROJECT_ID                    IN     NUMBER,
  X_TASK_ID                       IN     NUMBER,
  X_CUST_ASSIGN_START_DATE        IN     DATE,
  X_CUST_ASSIGN_END_DATE          IN     DATE,
  X_ALLOCATED_AREA_PCT            IN     NUMBER,
  X_ALLOCATED_AREA                IN     NUMBER,
  X_UTILIZED_AREA                 IN     NUMBER,
  X_CUST_SPACE_COMMENTS           IN     VARCHAR2,
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
  X_UPDATE_CORRECT_OPTION         IN     VARCHAR2,
  X_CHANGED_START_DATE            OUT    NOCOPY DATE,
  X_LEASE_ID                      IN     NUMBER,
  X_RECOVERY_SPACE_STD_CODE       IN     VARCHAR2,
  X_RECOVERY_TYPE_CODE            IN     VARCHAR2,
  X_FIN_OBLIG_END_DATE            IN     DATE,
  X_TENANCY_ID                    IN     NUMBER,
  X_RETURN_STATUS                 OUT NOCOPY VARCHAR2
  )
IS

   l_cust_space_assign_id          NUMBER;
   l_fin_oblig_end_date            DATE;
   l_status                        VARCHAR2(100);
   l_err_msg                       VARCHAR2(30);

BEGIN
        pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.UPDATE_ROW (+) SpcAsgnId: '
                        ||x_cust_space_assign_id||', Mode: '||x_update_correct_option||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_cust_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_cust_assign_end_date, 'MM/DD/YYYY')
                        ||', CustId: '||x_cust_account_id);

   -- Check if location is contigious Customer Assignable betn assign start and end dates.
   IF (x_location_id <> tlcustinfo.location_id) OR
      (x_cust_assign_start_date <> tlcustinfo.cust_assign_start_date) OR
      (NVL(x_cust_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')) <>
       NVL(tlcustinfo.cust_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')))
   THEN
      pnt_locations_pkg.Check_Location_Gaps(
                          p_loc_id     => x_location_id
                         ,p_str_dt     => x_cust_assign_start_date
                         ,p_end_dt     => NVL(x_cust_assign_end_date, TO_DATE('12/31/4712','MM/DD/YYYY'))
                         ,p_asgn_mode  => 'CUST'
                         ,p_err_msg    => l_err_msg
                          );

      IF l_err_msg IS NOT NULL THEN
         fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
         x_return_status := 'INVALID_LOC_DATE';
         return;
      END IF;
   END IF;

   /*IF  x_cust_account_id <> tlcustinfo.cust_account_id THEN

       pn_space_assign_cust_pkg.chk_dup_cust_assign(
                     p_cust_acnt_id  => x_cust_account_id
                    ,p_loc_id        => x_location_id
                    ,p_assgn_str_dt  => x_cust_assign_start_date
                    ,p_assgn_end_dt  => x_cust_assign_end_date
                    ,p_return_status => l_status);

       IF l_status = 'DUP_ASSIGN' THEN
          fnd_message.set_name('PN', 'PN_SPASGN_CUSTOMER_OVRLAP_MSG');
          x_return_status := 'DUP_ASSIGN';
          return;
       END IF;

   END IF; */

   IF X_UPDATE_CORRECT_OPTION = 'UPDATE' THEN

      SELECT  pn_space_assign_cust_s.NEXTVAL
      INTO    l_cust_space_assign_id
      FROM    DUAL;

      IF X_FIN_OBLIG_END_DATE IS NOT NULL THEN
         l_fin_oblig_end_date := X_CUST_ASSIGN_START_DATE - 1;
      ELSE
         l_fin_oblig_end_date := NULL;
      END IF;


      INSERT INTO pn_space_assign_cust_all
           (CUST_SPACE_ASSIGN_ID,
            LOCATION_ID,
            CUST_ACCOUNT_ID,
            SITE_USE_ID,
            EXPENSE_ACCOUNT_ID,
            PROJECT_ID,
            TASK_ID,
            CUST_ASSIGN_START_DATE,
            CUST_ASSIGN_END_DATE,
            ALLOCATED_AREA_PCT,
            ALLOCATED_AREA,
            UTILIZED_AREA,
            CUST_SPACE_COMMENTS,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
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
            LEASE_ID,
            RECOVERY_SPACE_STD_CODE,
            RECOVERY_TYPE_CODE,
            FIN_OBLIG_END_DATE,
            TENANCY_ID,
            ORG_ID)
      VALUES
           (l_cust_space_assign_id,
            tlcustinfo.LOCATION_ID,
            tlcustinfo.CUST_ACCOUNT_ID,
            tlcustinfo.SITE_USE_ID,
            tlcustinfo.EXPENSE_ACCOUNT_ID,
            tlcustinfo.PROJECT_ID,
            tlcustinfo.TASK_ID,
            tlcustinfo.CUST_ASSIGN_START_DATE,
            X_CUST_ASSIGN_START_DATE - 1,
            tlcustinfo.ALLOCATED_AREA_PCT,
            tlcustinfo.ALLOCATED_AREA,
            tlcustinfo.UTILIZED_AREA,
            tlcustinfo.CUST_SPACE_COMMENTS,
            tlcustinfo.LAST_UPDATE_DATE,
            tlcustinfo.LAST_UPDATED_BY,
            tlcustinfo.CREATION_DATE,
            tlcustinfo.CREATED_BY,
            tlcustinfo.LAST_UPDATE_LOGIN,
            tlcustinfo.ATTRIBUTE_CATEGORY,
            tlcustinfo.ATTRIBUTE1,
            tlcustinfo.ATTRIBUTE2,
            tlcustinfo.ATTRIBUTE3,
            tlcustinfo.ATTRIBUTE4,
            tlcustinfo.ATTRIBUTE5,
            tlcustinfo.ATTRIBUTE6,
            tlcustinfo.ATTRIBUTE7,
            tlcustinfo.ATTRIBUTE8,
            tlcustinfo.ATTRIBUTE9,
            tlcustinfo.ATTRIBUTE10,
            tlcustinfo.ATTRIBUTE11,
            tlcustinfo.ATTRIBUTE12,
            tlcustinfo.ATTRIBUTE13,
            tlcustinfo.ATTRIBUTE14,
            tlcustinfo.ATTRIBUTE15,
            tlcustinfo.LEASE_ID,
            tlcustinfo.RECOVERY_SPACE_STD_CODE,
            tlcustinfo.RECOVERY_TYPE_CODE,
            l_fin_oblig_end_date,
            tlcustinfo.TENANCY_ID,
            tlcustinfo.org_id
      );

   END IF;


   UPDATE PN_SPACE_ASSIGN_CUST_ALL SET
      LOCATION_ID                     = X_LOCATION_ID,
      CUST_ACCOUNT_ID                 = X_CUST_ACCOUNT_ID,
      SITE_USE_ID                     = X_SITE_USE_ID,
      EXPENSE_ACCOUNT_ID              = X_EXPENSE_ACCOUNT_ID,
      PROJECT_ID                      = X_PROJECT_ID,
      TASK_ID                         = X_TASK_ID,
      CUST_ASSIGN_START_DATE          = X_CUST_ASSIGN_START_DATE,
      CUST_ASSIGN_END_DATE            = X_CUST_ASSIGN_END_DATE,
      ALLOCATED_AREA_PCT              = X_ALLOCATED_AREA_PCT,
      ALLOCATED_AREA                  = X_ALLOCATED_AREA,
      UTILIZED_AREA                   = X_UTILIZED_AREA,
      CUST_SPACE_COMMENTS             = X_CUST_SPACE_COMMENTS,
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
      CUST_SPACE_ASSIGN_ID            = X_CUST_SPACE_ASSIGN_ID,
      LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
      LEASE_ID                        = X_LEASE_ID,
      RECOVERY_SPACE_STD_CODE         = X_RECOVERY_SPACE_STD_CODE,
      RECOVERY_TYPE_CODE              = X_RECOVERY_TYPE_CODE,
      FIN_OBLIG_END_DATE              = X_FIN_OBLIG_END_DATE,
      TENANCY_ID                      = X_TENANCY_ID
   WHERE CUST_SPACE_ASSIGN_ID         = X_CUST_SPACE_ASSIGN_ID;

   X_CHANGED_START_DATE := X_CUST_ASSIGN_START_DATE;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.UPDATE_ROW (-) SpcAsgnId: '
                        ||x_cust_space_assign_id||', Mode: '||x_update_correct_option||', LocId: '||x_location_id
                        ||', StrDt: '||TO_CHAR(x_cust_assign_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_cust_assign_end_date, 'MM/DD/YYYY')
                        ||', CustId: '||x_cust_account_id);

END Update_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_space_assign_cust
--                      with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row (
  X_CUST_SPACE_ASSIGN_ID          IN     NUMBER
)
IS

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.DELETE_ROW (+) SpcAsgnId: '
                        ||x_cust_space_assign_id);


   DELETE FROM pn_space_assign_cust_all
   WHERE cust_space_assign_id = x_cust_space_assign_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.DELETE_ROW (-) SpcAsgnId: '
                        ||x_cust_space_assign_id);

END Delete_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : CHK_DUP_CUST_ASSIGN
-- PURPOSE      : The procedure checks to see if there exists another assignment
--                record for the same customer, for the same date range.
--                If there exists one then it stops user from doing the assignment.
-- HISTORY      :
-- 05-MAR-04  ftanudja o Copied from pn_tenancies_pkg v115.50
-- 21-JUN-05  hrodda   o Bug 4284035 - Replaced pn_space_assign_cust
--                       with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE chk_dup_cust_assign(
                 p_cust_acnt_id                     IN     NUMBER
                ,p_loc_id                           IN     NUMBER
                ,p_assgn_str_dt                     IN     DATE
                ,p_assgn_end_dt                     IN     DATE
                ,p_return_status                    OUT NOCOPY VARCHAR2
                )
IS
  l_err_flag       VARCHAR2(1) := 'N';

  CURSOR check_cust_assignment IS
     SELECT 'Y'
     FROM   DUAL
     WHERE  EXISTS (SELECT NULL
                    FROM   pn_space_assign_cust_all
                    WHERE  cust_account_id = p_cust_acnt_id
                    AND    location_id = p_loc_id
                    AND    cust_assign_start_date <= p_assgn_end_dt
                    AND    NVL(cust_assign_end_date, TO_DATE('12/31/4712', 'MM/DD/YYYY'))
                           >= p_assgn_str_dt);
BEGIN
   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.CHK_DUP_CUST_ASSIGN (+)');

   OPEN check_cust_assignment;
   FETCH check_cust_assignment INTO l_err_flag;
   CLOSE check_cust_assignment;

   IF NVL(l_err_flag,'N') = 'Y' THEN
      p_return_status := 'DUP_ASSIGN';
   END IF;

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.CHK_DUP_CUST_ASSIGN (-) '||p_return_status);
END chk_dup_cust_assign;

-------------------------------------------------------------------
-- PROCEDURE  : GET_DUP_CUST_ASSIGN_COUNT
-- DESCRIPTION: Counts number of assignments for a given parameter
--    05-MAR-2004   Satish Tripathi o Created.
--    08-MAR-2004   Satish Tripathi o Added parameter p_dup_assign_count.
-------------------------------------------------------------------
PROCEDURE get_dup_cust_assign_count(
                 p_cust_acnt_id                     IN     NUMBER
                ,p_loc_id                           IN     NUMBER
                ,p_assgn_str_dt                     IN     DATE
                ,p_assgn_end_dt                     IN     DATE
                ,p_assign_count                     OUT NOCOPY NUMBER
                ,p_dup_assign_count                 OUT NOCOPY NUMBER
                )
IS
   l_assign_count       NUMBER := 0;
   l_dup_assign_count   NUMBER := 0;

   CURSOR get_cust_assignment IS
      SELECT cust_space_assign_id, cust_account_id
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_loc_id
      AND    cust_assign_start_date <= p_assgn_end_dt
      AND    NVL(cust_assign_end_date, TO_DATE('12/31/4712', 'MM/DD/YYYY'))
             >= p_assgn_str_dt;
BEGIN
   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.GET_DUP_CUST_ASSIGN_COUNT (+)');

   FOR cust_assign IN get_cust_assignment
   LOOP
      l_assign_count := l_assign_count + 1;
      IF cust_assign.cust_account_id = p_cust_acnt_id THEN
         l_dup_assign_count := l_dup_assign_count + 1;
      END IF;
   END LOOP;

   p_assign_count := l_assign_count;
   p_dup_assign_count := l_dup_assign_count;

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.GET_DUP_CUST_ASSIGN_COUNT (-) '||p_assign_count);
END get_dup_cust_assign_count;

-----------------------------------------------------------------------
-- FUNCTION  : check_assign_arcl_line
-- PURPOSE   : This function checks to see if there exists an area class
--             detail line having customer space assignment id in question.
--
-- IN PARAM  : Customer Space Assignment Id.
-- History   :
--    26-JUN-2003   Mrinal Misra   o Created.
-----------------------------------------------------------------------
FUNCTION check_assign_arcl_line(p_cust_space_assign_id IN NUMBER)
RETURN BOOLEAN IS

  l_exists       VARCHAR2(1);

  CURSOR cust_arcl_cur IS
     SELECT 'Y'
     FROM   DUAL
     WHERE  EXISTS (SELECT NULL
                    FROM   pn_rec_arcl_dtlln_all
                    WHERE  cust_space_assign_id = p_cust_space_assign_id);
BEGIN

   l_exists := 'N';

   OPEN cust_arcl_cur;
   FETCH cust_arcl_cur INTO l_exists;
   CLOSE cust_arcl_cur;

   IF l_exists = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END check_assign_arcl_line;

-------------------------------------------------------------------------------
-- FUNCTION  : assignment_split
-- PURPOSE   : This function splits assignment records based on dates
--             of existing assignments for re-distribution when profile
--             PN_AUTO_SPACE_ASSIGN is set to YES.
--             IF location L1 exists as below with an assignable space of 1200
--             from 1/1/01 to end of time(eot)
--             If space assignment for S1 for customer C1 for location L1 is
--             assigned from 1/1/01 to eot as below
--
--            1200                                   1200.. 100%
--     L1 |--------------------eot     L1,S1,C1 |------------------------eot
--       1/1                                     1/1
--
--             and then another assignment S2 for customer C2 for the same
--             location is made from 2/1/01 to 3/31/01 then the following
--             assignments will be created and area re-distributed
--
--            1200                     1200.. 100%
--     L1 |--------------------eot    L1,S1,C1 |----|
--       1/1                               1/1   1/31
--                                              600..50%
--                                    L1,S2,C2      |------|
--                                                 2/1   3/31
--                                              600..50%
--                                    L1,S2,C1      |------|
--                                                 2/1   3/31
--                                                         1200..100%
--                                    L1,S2,C1             |---------------------eot
--                                                        4/1
--             Now if the location area is changed from 1200 to 1201 as of
--             2/15/01 then the following assignments will be created and area
--             re-distributed
--
--             1200      1201          1200.. 100%
--      L1 |-------|------------eot   L1,S1,C1 |----|
--        1/1     2/15                        1/1   1/31
--                                              600..50%
--                                    L1,S2,C2      |----|
--                                                 2/1   2/14
--                                                   601.5---50%
--                                    L1,S2,C2           |----|
--                                                      2/15  3/31
--                                                   601.5---50%
--                                    L1,S2,C1           |----|
--                                                      2/15  3/31
--                                              600..50%
--                                    L1,S2,C1      |----|
--                                                 2/1   2/14
--                                                               1201..100%
--                                    L1,S2,C1                |---------------------eot
--                                                           4/1
--
--
-- IN PARAM  : Location Id.
-- History   :
-- 20-OCT-03 DThota     o Created. Fix for bug # 3234403
-- 05-NOV-03 DThota     o Initialized  pn_space_assign_emp_pkg.tlempinfo
--                        := emp_split_rec
-- 06-NOV-03 DThota     o Aliased assignable_area to allocated_area
--                        in csr_main.
-- 07-NOV-03 DThota     o Used min on active_start_date and max on
--                        active_end_date and used grouping logic in
--                        cursor csr_main in the last UNION ALL so that
--                        in the event that a location is split without
--                        change in the assignable_area only those start
--                        and end dates will be picked up where the
--                        assignable_area has changed. bug # 3243309.
--                        Changed the WHERE clause of cursor
--                        csr_location_area
-- 02-JUN-04 STripathi  o Call Defrag_Contig_Assign at end.
-- 30-SEP-04 STripathi  o Distribute area_pct_and_area only when Auto
--                        Space Dist= Y.
-- 08-OCT-04 STripathi  o For Auto Space Dist= Y, update area of split records.
-- 22-FEB-05 MMisra     o Fixed Bug # 4194998. Added ORDER BY clause in
--                        csr_main cursor query.
-- 07-MAR-05 ftanudja   o #4199297 - Added start and end date to
--                        assignment_split().
-- 19-MAY-05 ftanudja   o #4349490 - Changed csr_emp and csr_cust to increase
--                        range by +/- 1 day so that split assignments are
--                        included.
-- 21-JUN-05 hareesha   o Bug 4284035 - Replaced pn_space_assign_cust,
--                        pn_space_assign_emp and pn_loactions with _ALL
--                        table.
-- 25-Aug-05 hareesha   o Bug 4551557 - Modified csr_main cursor query to
--                        include space assignments starting after the specified
--                        end_date.
-- 28-NOV-05 pikhar     o passed org_id in pn_mo_cache_utils.get_profile_value
-- 04-APR-06 Hareesha   o Bug #5202023 Fetched org_id from pn_locations_all
--                        instead of pn_space_assign_cust_all because
--                        assignment_split could be called for
--                        employee space assignment too.
-------------------------------------------------------------------------------

-- 102403 -- date track space assignment

PROCEDURE assignment_split(p_location_id IN PN_LOCATIONS_ALL.location_id%TYPE,
                           p_start_date  IN pn_locations_all.active_start_date%TYPE,
                           p_end_date    IN pn_locations_all.active_end_date%TYPE
                           ) IS

   -------------------------------------------------------------------------------------
   -- This cursor is used to get customers and employees assigned to a location and their date info
   -- to get dates for which the assignment records need to be split using the procedure
   -- process vacancy
   -------------------------------------------------------------------------------------
   CURSOR csr_main IS
      SELECT cust_assign_start_date start_date
             ,NVL(cust_assign_end_date , to_date('12/31/4712','MM/DD/YYYY')) end_date
             ,allocated_area
             ,location_id
             ,'CUST: '||cust_space_assign_id assign_type_id
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
        AND  cust_assign_start_date <= p_end_date
        AND  NVL(cust_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= p_start_date
     UNION ALL
     SELECT cust_assign_start_date start_date
            ,NVL(cust_assign_end_date, to_date('12/31/4712','MM/DD/YYYY')) end_date
            ,allocated_area
            ,location_id
            ,'CUST: '||cust_space_assign_id assign_type_id
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
        AND  cust_assign_start_date > p_end_date
      UNION ALL
      SELECT emp_assign_start_date start_date
            ,NVL(emp_assign_end_date, to_date('12/31/4712','MM/DD/YYYY')) end_date
            ,allocated_area
            ,location_id
            ,'EMP: '||emp_space_assign_id assign_type_id
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
        AND  emp_assign_start_date <= p_end_date
        AND  NVL(emp_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= p_start_date
      UNION ALL
      SELECT emp_assign_start_date start_date
            ,NVL(emp_assign_end_date, to_date('12/31/4712','MM/DD/YYYY')) end_date
            ,allocated_area
            ,location_id
            ,'EMP: '||emp_space_assign_id assign_type_id
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
        AND  emp_assign_start_date > p_end_date
      UNION ALL
      SELECT min(active_start_date) start_date
            ,max(NVL(active_end_date, to_date('12/31/4712','MM/DD/YYYY'))) end_date
            ,assignable_area allocated_area
            ,location_id
            ,'LOCN.' assign_type_id
      FROM   pn_locations_all
      WHERE  location_id = p_location_id
        AND  active_start_date <= p_end_date
        AND  active_end_date >= p_start_date
      GROUP BY assignable_area,location_id
      ORDER BY start_date;

   -------------------------------------------------------------------------------------
   -- This cursor is used to get customers assigned to a location and their date info
   -- to get dates for which the assignment records need to be redistributed
   -------------------------------------------------------------------------------------
   CURSOR csr_cust IS
      SELECT cust_assign_start_date
             ,NVL(cust_assign_end_date, to_date('12/31/4712','MM/DD/YYYY')) cust_assign_end_date
             ,allocated_area
             ,allocated_area_pct
             ,location_id
             ,ROWID
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
        AND  cust_assign_start_date <= (p_end_date + 1)
        AND  NVL(cust_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= (p_start_date - 1)
        ;

   -------------------------------------------------------------------------------------
   -- This cursor is used to get employees assigned to a location and their date info
   -- to get dates for which the assignment records need to be redistributed
   -------------------------------------------------------------------------------------
   CURSOR csr_emp IS
      SELECT emp_assign_start_date
             ,NVL(emp_assign_end_date, to_date('12/31/4712','MM/DD/YYYY')) emp_assign_end_date
             ,allocated_area
             ,allocated_area_pct
             ,location_id
             ,ROWID
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
        AND  emp_assign_start_date <= (p_end_date + 1)
        AND  NVL(emp_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= (p_start_date - 1);

   -------------------------------------------------------------------------------------
   -- This cursor is used to get all customer assignment records whose start date is less than
   -- and end date greater than the split date returned by 'process vacancy'.
   -------------------------------------------------------------------------------------
   CURSOR csr_cust_split(p_as_of_date PN_SPACE_ASSIGN_CUST_ALL.cust_assign_start_date%TYPE) IS
      SELECT *
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
      AND    cust_assign_start_date < p_as_of_date
      AND    NVL(cust_assign_end_date,to_date('12/31/4712','MM/DD/YYYY')) >= p_as_of_date
      ORDER BY cust_assign_start_date,cust_assign_end_date;


   -------------------------------------------------------------------------------------
   -- This cursor is used to get all employee assignment records whose start date is less than
   -- and end date greater than the split date returned by 'process vacancy'.
   -------------------------------------------------------------------------------------
   CURSOR csr_emp_split(p_as_of_date PN_SPACE_ASSIGN_EMP_ALL.emp_assign_start_date%TYPE) IS
      SELECT *
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
      AND    emp_assign_start_date < p_as_of_date
      AND    NVL(emp_assign_end_date,to_date('12/31/4712','MM/DD/YYYY')) >= p_as_of_date
      ORDER BY emp_assign_start_date, emp_assign_end_date;

   -------------------------------------------------------------------------------------
   -- This cursor is used to get the latest area for a location based on the assignment dates
   -- after the split to update the assignments with the right area
   -------------------------------------------------------------------------------------
   CURSOR csr_location_area(p_location_id PN_LOCATIONS_ALL.location_id%TYPE
                            ,p_start_date PN_LOCATIONS_ALL.active_start_date%TYPE
                            ,p_end_date   PN_LOCATIONS_ALL.active_end_date%TYPE) IS
      SELECT assignable_area
      FROM   pn_locations_all
      WHERE  location_id = p_location_id
      AND    p_start_date between active_start_date
      AND    NVL(active_end_date,to_date('12/31/4712','MM/DD/YYYY'))
      ;

   l_num_table       pn_recovery_extract_pkg.number_table_TYPE;
   l_date_table      pn_recovery_extract_pkg.date_table_TYPE;
   l_date            DATE := NULL;
   p_date1           DATE := NULL;
   l_start_date      DATE := NULL;
   l_end_date        DATE := NULL;
   i                 NUMBER := 0;
   l_assignable_area PN_LOCATIONS_ALL.assignable_area%TYPE := 0;
   l_allocated_area  NUMBER;
   l_return_status   VARCHAR2(100) := NULL;
   l_profile         VARCHAR2(1);

   CURSOR org_cur IS
    SELECT org_id
    FROM   pn_locations_all
    WHERE  location_id = p_location_id;

/* S.N. Bug 456550 */
   CURSOR office_sec_cur(b_location_id number) IS
     SELECT 1 FROM DUAL
     WHERE  EXISTS
            (SELECT '1'
             FROM   pn_locations_all loc
             WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
             AND    loc.location_id = b_location_id
            );
/* E.N. Bug 456550 */

   l_org_id NUMBER;


BEGIN

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
     EXIT;
   END LOOP;

   l_profile := pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id);

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.Assignment_Split (+)  Loc Id: '||p_location_id
                       ||', l_profile: '||l_profile);

      i := 1;
      FOR main_rec IN csr_main

      LOOP

         pnp_debug_pkg.debug('Csr_Main i: '||i
                             ||', Assign Start Dt: '||main_rec.start_date
                             ||', End Dt: '||main_rec.end_date
                             ||', Area: '||main_rec.allocated_area
                             ||', Type/Id: '||main_rec.assign_type_id
                            );

         -- Populates the date table with the dates needed to spilt the employee assignments
         pn_recovery_extract_pkg.process_vacancy(
                 p_start_date   => main_rec.start_date,
                 p_end_date     => main_rec.end_date,
                 p_area         => NVL(main_rec.allocated_area, 0),
                 p_date_table   => l_date_table,
                 p_number_table => l_num_table,
                 p_add          => TRUE);
         i := i + 1;
      END LOOP;

      i := 1;

      -- do not want any record to be split/created with the 0th date or with
      -- the last date

      FOR i IN 1 .. l_date_table.count-1
      LOOP

         pnp_debug_pkg.debug('counter i= '||i||', date table= '||l_date_table(i));
         IF l_date_table(i) > to_date('12/31/4712','MM/DD/YYYY') THEN
           pnp_debug_pkg.debug('date table.......exit '|| l_date_table(i));
           EXIT;
         END IF;

         p_date1:= l_date_table(i);

         FOR cust_split_rec IN csr_cust_split(l_date_table(i))
         LOOP

            pnp_debug_pkg.debug('Update Cust Row Assign_Id: '|| cust_split_rec.cust_space_assign_id
                                ||', Loc_Id: '|| cust_split_rec.location_id
                                ||', Cust_Id: '|| cust_split_rec.cust_account_id);

            tlcustinfo := NULL;
            tlcustinfo := cust_split_rec;
            ---------------------------------------------------------------------------------------
            -- Splits the existing assignment with the (date-1) passed from the date table returned
            -- by process vacancy and creates a new assignment with the split date
            ---------------------------------------------------------------------------------------
            PN_SPACE_ASSIGN_CUST_PKG.UPDATE_ROW(
              X_CUST_SPACE_ASSIGN_ID     => cust_split_rec.CUST_SPACE_ASSIGN_ID
              ,X_LOCATION_ID             => cust_split_rec.LOCATION_ID
              ,X_CUST_ACCOUNT_ID         => cust_split_rec.CUST_ACCOUNT_ID
              ,X_SITE_USE_ID             => NULL
              ,X_EXPENSE_ACCOUNT_ID      => cust_split_rec.EXPENSE_ACCOUNT_ID
              ,X_PROJECT_ID              => cust_split_rec.PROJECT_ID
              ,X_TASK_ID                 => cust_split_rec.TASK_ID
              ,X_CUST_ASSIGN_START_DATE  => l_date_table(i)
              ,X_CUST_ASSIGN_END_DATE    => cust_split_rec.CUST_ASSIGN_END_DATE
              ,X_ALLOCATED_AREA_PCT      => cust_split_rec.ALLOCATED_AREA_PCT
              ,X_ALLOCATED_AREA          => cust_split_rec.ALLOCATED_AREA
              ,X_UTILIZED_AREA           => cust_split_rec.UTILIZED_AREA
              ,X_CUST_SPACE_COMMENTS     => cust_split_rec.CUST_SPACE_COMMENTS
              ,X_ATTRIBUTE_CATEGORY      => cust_split_rec.ATTRIBUTE_CATEGORY
              ,X_ATTRIBUTE1              => cust_split_rec.ATTRIBUTE1
              ,X_ATTRIBUTE2              => cust_split_rec.ATTRIBUTE2
              ,X_ATTRIBUTE3              => cust_split_rec.ATTRIBUTE3
              ,X_ATTRIBUTE4              => cust_split_rec.ATTRIBUTE4
              ,X_ATTRIBUTE5              => cust_split_rec.ATTRIBUTE5
              ,X_ATTRIBUTE6              => cust_split_rec.ATTRIBUTE6
              ,X_ATTRIBUTE7              => cust_split_rec.ATTRIBUTE7
              ,X_ATTRIBUTE8              => cust_split_rec.ATTRIBUTE8
              ,X_ATTRIBUTE9              => cust_split_rec.ATTRIBUTE9
              ,X_ATTRIBUTE10             => cust_split_rec.ATTRIBUTE10
              ,X_ATTRIBUTE11             => cust_split_rec.ATTRIBUTE11
              ,X_ATTRIBUTE12             => cust_split_rec.ATTRIBUTE12
              ,X_ATTRIBUTE13             => cust_split_rec.ATTRIBUTE13
              ,X_ATTRIBUTE14             => cust_split_rec.ATTRIBUTE14
              ,X_ATTRIBUTE15             => cust_split_rec.ATTRIBUTE15
              ,X_LEASE_ID                => cust_split_rec.LEASE_ID
              ,X_TENANCY_ID              => cust_split_rec.TENANCY_ID
              ,X_RECOVERY_SPACE_STD_CODE => cust_split_rec.RECOVERY_SPACE_STD_CODE
              ,X_RECOVERY_TYPE_CODE      => cust_split_rec.RECOVERY_TYPE_CODE
              ,X_FIN_OBLIG_END_DATE      => cust_split_rec.FIN_OBLIG_END_DATE
              ,X_LAST_UPDATE_DATE        => SYSDATE
              ,X_LAST_UPDATED_BY         => 1
              ,X_LAST_UPDATE_LOGIN       => 1
              ,X_UPDATE_CORRECT_OPTION   => 'UPDATE'
              ,X_CHANGED_START_DATE      => l_date
              ,X_RETURN_STATUS           => l_return_status
              );

         END LOOP;

         FOR emp_split_rec IN csr_emp_split(l_date_table(i))
         LOOP

            pnp_debug_pkg.debug('Update Emp Row Assign_Id: '|| emp_split_rec.emp_space_assign_id
                                ||', Loc_Id: '|| emp_split_rec.location_id
                                ||', Emp_Id: '|| emp_split_rec.person_id);

            pn_space_assign_emp_pkg.tlempinfo := emp_split_rec;
            ---------------------------------------------------------------------------------------
            -- Splits the existing assignment with the (date-1) passed from the date table returned
            -- by process vacancy and creates a new assignment with the split date
            ---------------------------------------------------------------------------------------
            PN_SPACE_ASSIGN_EMP_PKG.UPDATE_ROW(
               X_EMP_SPACE_ASSIGN_ID    => emp_split_rec.EMP_SPACE_ASSIGN_ID
               ,X_ATTRIBUTE1            => emp_split_rec.ATTRIBUTE1
               ,X_ATTRIBUTE2            => emp_split_rec.ATTRIBUTE2
               ,X_ATTRIBUTE3            => emp_split_rec.ATTRIBUTE3
               ,X_ATTRIBUTE4            => emp_split_rec.ATTRIBUTE4
               ,X_ATTRIBUTE5            => emp_split_rec.ATTRIBUTE5
               ,X_ATTRIBUTE6            => emp_split_rec.ATTRIBUTE6
               ,X_ATTRIBUTE7            => emp_split_rec.ATTRIBUTE7
               ,X_ATTRIBUTE8            => emp_split_rec.ATTRIBUTE8
               ,X_ATTRIBUTE9            => emp_split_rec.ATTRIBUTE9
               ,X_ATTRIBUTE10           => emp_split_rec.ATTRIBUTE10
               ,X_ATTRIBUTE11           => emp_split_rec.ATTRIBUTE11
               ,X_ATTRIBUTE12           => emp_split_rec.ATTRIBUTE12
               ,X_ATTRIBUTE13           => emp_split_rec.ATTRIBUTE13
               ,X_ATTRIBUTE14           => emp_split_rec.ATTRIBUTE14
               ,X_ATTRIBUTE15           => emp_split_rec.ATTRIBUTE15
               ,X_LOCATION_ID           => emp_split_rec.LOCATION_ID
               ,X_PERSON_ID             => emp_split_rec.PERSON_ID
               ,X_PROJECT_ID            => emp_split_rec.PROJECT_ID
               ,X_TASK_ID               => emp_split_rec.TASK_ID
               ,X_EMP_ASSIGN_START_DATE => l_date_table(i)
               ,X_EMP_ASSIGN_END_DATE   => emp_split_rec.EMP_ASSIGN_END_DATE
               ,X_COST_CENTER_CODE      => emp_split_rec.COST_CENTER_CODE
               ,X_ALLOCATED_AREA_PCT    => emp_split_rec.ALLOCATED_AREA_PCT
               ,X_ALLOCATED_AREA        => emp_split_rec.ALLOCATED_AREA
               ,X_UTILIZED_AREA         => emp_split_rec.UTILIZED_AREA
               ,X_EMP_SPACE_COMMENTS    => emp_split_rec.EMP_SPACE_COMMENTS
               ,X_ATTRIBUTE_CATEGORY    => emp_split_rec.ATTRIBUTE_CATEGORY
               ,X_LAST_UPDATE_DATE      => SYSDATE
               ,X_LAST_UPDATED_BY       => 1
               ,X_LAST_UPDATE_LOGIN     => 1
               ,X_UPDATE_CORRECT_OPTION => 'UPDATE'
               ,X_CHANGED_START_DATE    => l_date
               );

         END LOOP;

      END LOOP;

      pnp_debug_pkg.debug('To distribute Area_Pct and Area... (+)');
      FOR cust_rec IN csr_cust

      LOOP

         OPEN csr_location_area(p_location_id => cust_rec.location_id
                                ,p_start_date => cust_rec.cust_assign_start_date
                                ,p_end_date   => cust_rec.cust_assign_end_date);
         FETCH csr_location_area INTO l_assignable_area;
         CLOSE csr_location_area;
         IF l_profile = 'Y' THEN
            -- Call to re-distribute area among all customers for the location
           FOR  office_sec_rec IN office_sec_cur(cust_rec.location_id) /*Bug4565550*/
           LOOP

            pn_space_assign_cust_pkg.area_pct_and_area(
                x_usable_area  => l_assignable_area
               ,x_location_id => cust_rec.location_id
               ,x_start_date  => cust_rec.cust_assign_start_date
               ,x_end_date    => cust_rec.cust_assign_end_date
              );

           END LOOP;   /*Bug4565550*/

         ELSE
            l_allocated_area := TRUNC((l_assignable_area * cust_rec.allocated_area_pct)/100, 2); /*4533091*/
            IF l_allocated_area <> cust_rec.allocated_area THEN
               UPDATE pn_space_assign_cust_all
               SET    allocated_area = l_allocated_area
               WHERE  ROWID = cust_rec.ROWID;
            END IF;
         END IF;
      END LOOP;

      FOR emp_rec IN csr_emp

      LOOP

         OPEN csr_location_area(p_location_id => emp_rec.location_id
                                ,p_start_date => emp_rec.emp_assign_start_date
                                ,p_end_date   => emp_rec.emp_assign_end_date);
         FETCH csr_location_area INTO l_assignable_area;
         CLOSE csr_location_area;

         IF l_profile = 'Y' THEN
            -- Call to re-distribute area among all employees for the location
           FOR  office_sec_rec IN office_sec_cur(emp_rec.location_id) /*Bug4565550*/
           LOOP

            PN_SPACE_ASSIGN_CUST_PKG.area_pct_and_area(
                x_usable_area  => l_assignable_area
               ,x_location_id => emp_rec.location_id
               ,x_start_date  => emp_rec.emp_assign_start_date
               ,x_end_date    => emp_rec.emp_assign_end_date
              );

           END LOOP;   /*Bug4565550*/

         ELSE
            l_allocated_area := TRUNC((l_assignable_area * emp_rec.allocated_area_pct)/100, 2); /*4533091*/
            IF l_allocated_area <> emp_rec.allocated_area THEN
               UPDATE pn_space_assign_emp_all
               SET    allocated_area = l_allocated_area
               WHERE  ROWID = emp_rec.ROWID;
            END IF;
         END IF;
      END LOOP;
      pnp_debug_pkg.debug('Done distributing Area_Pct and Area... (-)');

   pn_space_assign_cust_pkg.Defrag_Contig_Assign(p_location_id);

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.Assignment_Split (-)  Loc Id: '||p_location_id);

 END assignment_split;

-------------------------------------------------------------------------------
-- PROCEDURE    : AREA_PCT_AND_AREA
-- INVOKED FROM :
-- PURPOSE      : Added condition to select/update only locations of type
--                office/section.
-- HISTORY
-- 02-JUN-01 dthota   o Fix for bug # 1609377
-- 08-FEB-02 kkhegde  o Bug#2168629 - changed the procedure definition
--                      replaced x_as_of_date_emp and x_as_of_date_cust
--                      with x_start_date and x_end_date
-- 07-NOV-02 dthota   o bug # 2434352 - Modified the procedure to
--                      add/subtract the fractional remainder after space
--                      redistribution to one record.
-- 20-OCT-03 dthota   o bug # 3234403 - Copied this procedure from PNTSPACE.pld
-- 14-DEC-04 STripath o Fixed for bug# 4092157. If l_total_pct <> 100, update
--                      either pn_space_assign_emp or pn_space_assign_cust.
-- 22-FEB-05 MMisra   o Bug # 4198937. Merged IF conditions where area and
--                      percentage differnce was being checked.
-- 21-JUN-05 hrodda   o Bug 4284035 - Replaced pn_space_assign_emp,pn_locations
--                      pn_space_assign_cust with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE area_pct_and_area(x_usable_area     NUMBER,
                            x_location_id     NUMBER,
                            x_start_date      DATE,
                            x_end_date        DATE
                            ) IS

   l_utilized       NUMBER;
   l_total_pct      NUMBER;
   l_total_area     NUMBER;
   l_diff_pct       NUMBER;
   l_diff_area      NUMBER;
   l_emp_updated    NUMBER := 0;
   l_cust_updated   NUMBER := 0;
   l_alloc_area_pct pn_space_assign_emp_all.allocated_area_pct%TYPE;
   l_alloc_area     pn_space_assign_emp_all.allocated_area%TYPE;

BEGIN

   l_utilized       := PN_SPACE_ASSIGN_CUST_PKG.assignment_count(x_location_id,x_start_date,x_end_date);
   l_alloc_area_pct := TRUNC(100 / l_utilized, 2); /*4533091*/
   l_alloc_area     := TRUNC(x_usable_area / l_utilized, 2); /*4533091*/

   pnp_debug_pkg.debug('Area_Pct_And_Area (+)  Loc Id: '||x_location_id
                        ||', Area: '||x_usable_area
                        ||', StrDt: '||TO_CHAR(x_start_date,'MM/DD/YYYY')
                        ||', EndDt: '||TO_CHAR(x_end_date, 'MM/DD/YYYY')
                        ||', lUtil: '||l_utilized
                        ||', lArea: '||l_alloc_area
                        ||', lPct: '||l_alloc_area_pct);

   IF l_utilized <> 0 THEN


      UPDATE pn_space_assign_emp_all emp
      SET    emp.allocated_area_pct = l_alloc_area_pct,
             emp.allocated_area     = l_alloc_area
      WHERE  emp.location_id        = x_location_id
      AND   (emp.emp_assign_start_date                                       <= x_end_date AND
             NVL(emp.emp_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
      AND EXISTS (SELECT '1'
                  FROM   pn_locations_all loc
                  WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
                  AND    loc.location_id = emp.location_id);

      l_emp_updated := SQL%ROWCOUNT;


      UPDATE pn_space_assign_cust_all cust
      SET    cust.allocated_area_pct = l_alloc_area_pct,
             cust.allocated_area     = l_alloc_area
      WHERE  cust.location_id        = x_location_id
      AND   (cust.cust_assign_start_date                                       <= x_end_date AND
             NVL(cust.cust_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
      AND EXISTS (SELECT '1'
                  FROM   pn_locations_all loc
                  WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
                  AND    loc.location_id = cust.location_id);

      l_cust_updated := SQL%ROWCOUNT;

      l_total_pct  := l_alloc_area_pct * l_utilized;
      l_total_area := l_alloc_area * l_utilized;

      IF l_total_pct <> 100 OR l_total_area <> x_usable_area THEN

         l_diff_pct := 100 - l_total_pct;
         l_diff_area := x_usable_area - l_total_area;


         IF NVL(l_emp_updated, 0) > 0 THEN
            UPDATE pn_space_assign_emp_all emp
            SET    emp.allocated_area_pct = (emp.allocated_area_pct + l_diff_pct),
                   emp.allocated_area     = (emp.allocated_area + l_diff_area)
            WHERE  emp.location_id        = x_location_id
            AND   (emp.emp_assign_start_date                                       <= x_end_date AND
                   NVL(emp.emp_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
            AND EXISTS (SELECT '1'
                        FROM   pn_locations_all loc
                        WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
                        AND    loc.location_id = emp.location_id)
            AND ROWNUM < 2;


         ELSIF NVL(l_cust_updated, 0) > 0 THEN
            UPDATE pn_space_assign_cust_all cust
            SET    cust.allocated_area_pct = (cust.allocated_area_pct + l_diff_pct),
                   cust.allocated_area     = (cust.allocated_area + l_diff_area)
            WHERE  cust.location_id        = x_location_id
            AND   (cust.cust_assign_start_date                                       <= x_end_date AND
                   NVL(cust.cust_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
            AND EXISTS (SELECT '1'
                        FROM   pn_locations_all loc
                        WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
                        AND    loc.location_id = cust.location_id)
            AND ROWNUM < 2;

         END IF;
      END IF;
   END IF;

   pnp_debug_pkg.debug('Area_Pct_And_Area (-)  Loc Id: '||x_location_id);
END area_pct_and_area;

/*===========================================================================+
--  NAME         : assignment_count
--  DESCRIPTION  : This function returns the number of assignments for a given
--                 location within the given start date and end date. Earlier
--                 this code was a part of procedure area_pct_and_area, made a
--                 separate function so that it can be called from
--                 INSERT_ROW to get the count of assignments.
--  SCOPE        : PRIVATE
--  INVOKED FROM :
--  ARGUMENTS    : IN : x_location_id,x_start_date,x_end_date.
--                 OUT: l_utilized
--  REFERENCE    : PN_COMMON.debug()
--  RETURNS      : No. of assignments for the location with in start date and
--                 end date.
--  HISTORY      :
--  16-ARP-02  MMisra   o Created
--  20-OCT-03  DThota   o bug 3234403 - Copied this procedure from PNTSPACE.pld
--  07-MAR-05  ftanudja o Used subquery referencing for performance. #4199297.
--  21-JUN-05  hrodda   o Bug 4284035 - Replaced pn_space_assign_emp,
--                        pn_space_assign_cust, pn_locations with _ALL table.
+============================================================================*/

FUNCTION assignment_count(x_location_id IN   NUMBER,
                          x_start_date  IN   DATE,
                          x_end_date    IN   DATE)
RETURN NUMBER IS

   l_utilized       NUMBER;
   l_utilized_emp   NUMBER;
   l_utilized_cust  NUMBER;

BEGIN

   l_utilized_emp   := 0;
   l_utilized_cust  := 0;

   SELECT COUNT(*)
   INTO   l_utilized_emp
   FROM   pn_space_assign_emp_all emp
   WHERE  emp.location_id        = x_location_id
   AND    (emp.emp_assign_start_date <= NVL(x_end_date,to_date('12/31/4712','mm/dd/yyyy')) AND
           NVL(emp.emp_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
   AND EXISTS (SELECT '1'
               FROM   pn_locations_all loc
               WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
               AND    loc.location_id = emp.location_id);

   SELECT COUNT(*)
   INTO   l_utilized_cust
   FROM   pn_space_assign_cust_all cust
   WHERE  cust.location_id        = x_location_id
   AND    (cust.cust_assign_start_date <= NVL(x_end_date,to_date('12/31/4712','mm/dd/yyyy')) AND
           NVL(cust.cust_assign_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
   AND EXISTS (SELECT '1'
               FROM   pn_locations_all loc
               WHERE  loc.location_type_lookup_code in ('OFFICE','SECTION')
               AND    loc.location_id = cust.location_id);

   l_utilized := NVL(l_utilized_emp,0) + NVL(l_utilized_cust,0);

   RETURN l_utilized;

END assignment_count;

/*===========================================================================+
 | FUNCTION
 |   location_count
 |
 | DESCRIPTION
 |   This function returns the number of location splits for a given location within
 |   the given start date and end date.
 |
 | SCOPE - PRIVATE
 |
 | ARGUMENTS:
 |   IN:  x_location_id,x_start_date,x_end_date.
 |   OUT: l_location_count
 |
 | RETURNS: No. of location splits for the location with in start date and end date.
 |
 | MODIFICATION HISTORY
 |   06-Nov-2003  Daniel Thota   o Created Fix for bug # 3240216.
 |                                 Gets a count of split locations for a date range if they exist
 |                                to be used in the event that a location has undergone
 |                                splits as result of location attribute changes before
 |                                an assignment is made for that location
 +===========================================================================*/

FUNCTION location_count(x_location_id IN   NUMBER,
                        x_start_date  IN   DATE,
                        x_end_date    IN   DATE)
RETURN NUMBER IS

   l_location_count NUMBER := 0;

BEGIN

   SELECT COUNT(*)
   INTO   l_location_count
   FROM   pn_locations_all
   WHERE  location_id        = x_location_id
   AND    (active_start_date <= NVL(x_end_date,to_date('12/31/4712','mm/dd/yyyy')) AND
           NVL(active_end_date,to_date('12/31/4712','mm/dd/yyyy')) >= x_start_date)
   ;
   RETURN l_location_count;

END location_count;

-- 102403 -- date track space assignment


-------------------------------------------------------------------------------
-- PROCEDURE : DEFRAG_CONTIG_ASSIGN
-- PURPOSE   : This procedure removes fragments of the similar contiguous assignment
--             record after assignments are split and re-distributed.
--             Consider lease 1803, Tenancy 1985 for location 3045 assigned to Customer 5225
--             from 1/1/00 to 12/31/06....the foll. assignment will be created
--
--             LOC_ID START_DT  END_DATE  ALLOC_PCT ALLOC_AREA   LEASE_ID TENANCY_ID CUST_ID
--             ------ --------- --------- --------- ----------   -------- ---------- -------
--             3045   01-JAN-00 31-DEC-06      100      750       1803       1985     5225
--
--             Consider lease 1804, Tenancy 1986 for location 3045 assigned to Customer 4780
--             from 1/1/02 to 12/31/04....the foll. assignment will be created/redistributed
--
--             LOC_ID START_DT  END_DATE  ALLOC_PCT ALLOC_AREA   LEASE_ID TENANCY_ID CUST_ID
--             ------ --------- --------- --------- ----------   -------- ---------- -------
--             3045   01-JAN-00 31-DEC-01      100      750       1803       1985     5225
--             3045   01-JAN-02 31-DEC-04      50       375       1804       1986     4780
--             3045   01-JAN-02 31-DEC-04      50       375       1803       1985     5225
--             3045   01-JAN-05 31-DEC-06      100      750       1803       1985     5225
--
--             If tenancy is updated to start on 1/1/03 and end on 12/31/03 w/o changing
--             location/customer info the foll assignment was being created/redistributed
--
--             LOC_ID START_DT  END_DATE  ALLOC_PCT ALLOC_AREA   LEASE_ID TENANCY_ID CUST_ID
--             ------ --------- --------- --------- ----------   -------- ---------- -------
--             3045   01-JAN-00 31-DEC-01      100      750       1803       1985     5225
--             3045   01-JAN-02 31-DEC-03      100      750       1803       1985     5225
--             3045   01-JAN-03 31-DEC-03      50       375       1804       1986     4780
--             3045   01-JAN-03 31-DEC-03      50       375       1803       1985     5225
--             3045   01-JAN-04 31-DEC-05      100      750       1803       1985     5225
--             3045   01-JAN-05 31-DEC-06      100      750       1803       1985     5225
--
--             This procedure now merges the similar contiguous assignments as the following
--
--             LOC_ID START_DT  END_DATE  ALLOC_PCT ALLOC_AREA   LEASE_ID TENANCY_ID CUST_ID
--             ------ --------- --------- --------- ----------   -------- ---------- -------
--             3045   01-JAN-00 31-DEC-03      100      750       1803       1985     5225
--             3045   01-JAN-03 31-DEC-03      50       375       1804       1986     4780
--             3045   01-JAN-03 31-DEC-03      50       375       1803       1985     5225
--             3045   01-JAN-04 31-DEC-06      100      750       1803       1985     5225
--             This is done only for those records which have all other attributes of the
--             record to be similar except having contiguity in the end date and start date
--             as in the first and the last 2 records in the example shown above
--
-- IN PARAM  : Location Id.
-- History   :
-- 09-DEC-03 DThota    o Created for BUG# 3308225.
-- 02-JUN-04 STripathi o Changed name from clean_up to Defrag_Contig_Assign.
--                       Changed logic; added comparing attribute1 - 15 of
--                       cintiguous assignments also to check if they are similar
--                       assignments, update the assignment instead of calling
--                       Update_Row in Correct mode, and other changes.
-- 30-SEP-04 STripathi o Modified for Update and Delete for Emp_Tab.
--                       Update i+1 row BUT DELETE i th row.
-- 21-JUN-05 hrodda    o Bug 4284035 - Replaced pn_space_assign_emp,
--                       pn_space_assign_cust with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE Defrag_Contig_Assign (
                 p_location_id            IN     pn_locations_all.location_id%TYPE                )
IS
   -------------------------------------------------------------------------------------
   -- The foll. cursors are used to get customers and employees assigned to a location
   -- after split and redistribution ordered in such a way that records with contiguous
   -- dates are consecutively ordered.
   -------------------------------------------------------------------------------------

   CURSOR csr_cust IS
      SELECT CUST_SPACE_ASSIGN_ID
            ,LOCATION_ID
            ,CUST_ACCOUNT_ID
            ,SITE_USE_ID
            ,EXPENSE_ACCOUNT_ID
            ,PROJECT_ID
            ,TASK_ID
            ,CUST_ASSIGN_START_DATE
            ,CUST_ASSIGN_END_DATE
            ,ALLOCATED_AREA_PCT
            ,ALLOCATED_AREA
            ,UTILIZED_AREA
            ,CUST_SPACE_COMMENTS
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
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
            ,ORG_ID
            ,LEASE_ID
            ,RECOVERY_SPACE_STD_CODE
            ,RECOVERY_TYPE_CODE
            ,FIN_OBLIG_END_DATE
            ,TENANCY_ID
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_location_id
      ORDER BY cust_account_id,tenancy_id,lease_id,cust_assign_start_date,cust_assign_end_date
      ;

   CURSOR csr_emp IS
      SELECT EMP_SPACE_ASSIGN_ID
            ,LOCATION_ID
            ,PERSON_ID
            ,PROJECT_ID
            ,TASK_ID
            ,EMP_ASSIGN_START_DATE
            ,EMP_ASSIGN_END_DATE
            ,COST_CENTER_CODE
            ,ALLOCATED_AREA_PCT
            ,ALLOCATED_AREA
            ,UTILIZED_AREA
            ,EMP_SPACE_COMMENTS
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
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
            ,ORG_ID
            ,SOURCE
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_location_id
      ORDER BY person_id,emp_assign_start_date,emp_assign_end_date
      ;

   --------------------------------------------------------------------------
   -- Define a record of PN_SPACE_CUST_ASSIGN_ALL and PN_SPACE_ASSIGN_EMP_ALL
   --------------------------------------------------------------------------

   TYPE cust_rec_type IS RECORD(
      CUST_SPACE_ASSIGN_ID     pn_space_assign_cust_all.CUST_SPACE_ASSIGN_ID%TYPE
      ,LOCATION_ID             pn_space_assign_cust_all.LOCATION_ID%TYPE
      ,CUST_ACCOUNT_ID         pn_space_assign_cust_all.CUST_ACCOUNT_ID%TYPE
      ,SITE_USE_ID             pn_space_assign_cust_all.SITE_USE_ID%TYPE
      ,EXPENSE_ACCOUNT_ID      pn_space_assign_cust_all.EXPENSE_ACCOUNT_ID%TYPE
      ,PROJECT_ID              pn_space_assign_cust_all.PROJECT_ID%TYPE
      ,TASK_ID                 pn_space_assign_cust_all.TASK_ID%TYPE
      ,CUST_ASSIGN_START_DATE  pn_space_assign_cust_all.CUST_ASSIGN_START_DATE%TYPE
      ,CUST_ASSIGN_END_DATE    pn_space_assign_cust_all.CUST_ASSIGN_END_DATE%TYPE
      ,ALLOCATED_AREA_PCT      pn_space_assign_cust_all.ALLOCATED_AREA_PCT%TYPE
      ,ALLOCATED_AREA          pn_space_assign_cust_all.ALLOCATED_AREA%TYPE
      ,UTILIZED_AREA           pn_space_assign_cust_all.UTILIZED_AREA%TYPE
      ,CUST_SPACE_COMMENTS     pn_space_assign_cust_all.CUST_SPACE_COMMENTS%TYPE
      ,LAST_UPDATE_DATE        pn_space_assign_cust_all.LAST_UPDATE_DATE%TYPE
      ,LAST_UPDATED_BY         pn_space_assign_cust_all.LAST_UPDATED_BY%TYPE
      ,CREATION_DATE           pn_space_assign_cust_all.CREATION_DATE%TYPE
      ,CREATED_BY              pn_space_assign_cust_all.CREATED_BY%TYPE
      ,LAST_UPDATE_LOGIN       pn_space_assign_cust_all.LAST_UPDATE_LOGIN%TYPE
      ,ATTRIBUTE_CATEGORY      pn_space_assign_cust_all.ATTRIBUTE_CATEGORY%TYPE
      ,ATTRIBUTE1              pn_space_assign_cust_all.ATTRIBUTE1%TYPE
      ,ATTRIBUTE2              pn_space_assign_cust_all.ATTRIBUTE2%TYPE
      ,ATTRIBUTE3              pn_space_assign_cust_all.ATTRIBUTE3%TYPE
      ,ATTRIBUTE4              pn_space_assign_cust_all.ATTRIBUTE4%TYPE
      ,ATTRIBUTE5              pn_space_assign_cust_all.ATTRIBUTE5%TYPE
      ,ATTRIBUTE6              pn_space_assign_cust_all.ATTRIBUTE6%TYPE
      ,ATTRIBUTE7              pn_space_assign_cust_all.ATTRIBUTE7%TYPE
      ,ATTRIBUTE8              pn_space_assign_cust_all.ATTRIBUTE8%TYPE
      ,ATTRIBUTE9              pn_space_assign_cust_all.ATTRIBUTE9%TYPE
      ,ATTRIBUTE10             pn_space_assign_cust_all.ATTRIBUTE10%TYPE
      ,ATTRIBUTE11             pn_space_assign_cust_all.ATTRIBUTE11%TYPE
      ,ATTRIBUTE12             pn_space_assign_cust_all.ATTRIBUTE12%TYPE
      ,ATTRIBUTE13             pn_space_assign_cust_all.ATTRIBUTE13%TYPE
      ,ATTRIBUTE14             pn_space_assign_cust_all.ATTRIBUTE14%TYPE
      ,ATTRIBUTE15             pn_space_assign_cust_all.ATTRIBUTE15%TYPE
      ,ORG_ID                  pn_space_assign_cust_all.ORG_ID%TYPE
      ,LEASE_ID                pn_space_assign_cust_all.LEASE_ID%TYPE
      ,RECOVERY_SPACE_STD_CODE pn_space_assign_cust_all.RECOVERY_SPACE_STD_CODE%TYPE
      ,RECOVERY_TYPE_CODE      pn_space_assign_cust_all.RECOVERY_TYPE_CODE%TYPE
      ,FIN_OBLIG_END_DATE      pn_space_assign_cust_all.FIN_OBLIG_END_DATE%TYPE
      ,TENANCY_ID              pn_space_assign_cust_all.TENANCY_ID%TYPE
      );

   TYPE emp_rec_type IS RECORD(
       EMP_SPACE_ASSIGN_ID    pn_space_assign_emp_all.EMP_SPACE_ASSIGN_ID%TYPE
       ,LOCATION_ID           pn_space_assign_emp_all.LOCATION_ID%TYPE
       ,PERSON_ID             pn_space_assign_emp_all.PERSON_ID%TYPE
       ,PROJECT_ID            pn_space_assign_emp_all.PROJECT_ID%TYPE
       ,TASK_ID               pn_space_assign_emp_all.TASK_ID%TYPE
       ,EMP_ASSIGN_START_DATE pn_space_assign_emp_all.EMP_ASSIGN_START_DATE%TYPE
       ,EMP_ASSIGN_END_DATE   pn_space_assign_emp_all.EMP_ASSIGN_END_DATE%TYPE
       ,COST_CENTER_CODE      pn_space_assign_emp_all.COST_CENTER_CODE%TYPE
       ,ALLOCATED_AREA_PCT    pn_space_assign_emp_all.ALLOCATED_AREA_PCT%TYPE
       ,ALLOCATED_AREA        pn_space_assign_emp_all.ALLOCATED_AREA%TYPE
       ,UTILIZED_AREA         pn_space_assign_emp_all.UTILIZED_AREA%TYPE
       ,EMP_SPACE_COMMENTS    pn_space_assign_emp_all.EMP_SPACE_COMMENTS%TYPE
       ,LAST_UPDATE_DATE      pn_space_assign_emp_all.LAST_UPDATE_DATE%TYPE
       ,LAST_UPDATED_BY       pn_space_assign_emp_all.LAST_UPDATED_BY%TYPE
       ,CREATION_DATE         pn_space_assign_emp_all.CREATION_DATE%TYPE
       ,CREATED_BY            pn_space_assign_emp_all.CREATED_BY%TYPE
       ,LAST_UPDATE_LOGIN     pn_space_assign_emp_all.LAST_UPDATE_LOGIN%TYPE
       ,ATTRIBUTE_CATEGORY    pn_space_assign_emp_all.ATTRIBUTE_CATEGORY%TYPE
       ,ATTRIBUTE1            pn_space_assign_emp_all.ATTRIBUTE1%TYPE
       ,ATTRIBUTE2            pn_space_assign_emp_all.ATTRIBUTE2%TYPE
       ,ATTRIBUTE3            pn_space_assign_emp_all.ATTRIBUTE3%TYPE
       ,ATTRIBUTE4            pn_space_assign_emp_all.ATTRIBUTE4%TYPE
       ,ATTRIBUTE5            pn_space_assign_emp_all.ATTRIBUTE5%TYPE
       ,ATTRIBUTE6            pn_space_assign_emp_all.ATTRIBUTE6%TYPE
       ,ATTRIBUTE7            pn_space_assign_emp_all.ATTRIBUTE7%TYPE
       ,ATTRIBUTE8            pn_space_assign_emp_all.ATTRIBUTE8%TYPE
       ,ATTRIBUTE9            pn_space_assign_emp_all.ATTRIBUTE9%TYPE
       ,ATTRIBUTE10           pn_space_assign_emp_all.ATTRIBUTE10%TYPE
       ,ATTRIBUTE11           pn_space_assign_emp_all.ATTRIBUTE11%TYPE
       ,ATTRIBUTE12           pn_space_assign_emp_all.ATTRIBUTE12%TYPE
       ,ATTRIBUTE13           pn_space_assign_emp_all.ATTRIBUTE13%TYPE
       ,ATTRIBUTE14           pn_space_assign_emp_all.ATTRIBUTE14%TYPE
       ,ATTRIBUTE15           pn_space_assign_emp_all.ATTRIBUTE15%TYPE
       ,ORG_ID                pn_space_assign_emp_all.ORG_ID%TYPE
       ,SOURCE                pn_space_assign_emp_all.SOURCE%TYPE
       );

   ----------------------------------------------------------
   -- Define a PL/SQL table for employee and customer records
   ----------------------------------------------------------
   TYPE emp IS
      TABLE OF emp_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE cust IS
      TABLE OF cust_rec_type
      INDEX BY BINARY_INTEGER;

   emp_tab                   emp;
   cust_tab                  cust;
   l_rec_num                 NUMBER;
   l_diff                    NUMBER;
   l_date                    DATE := NULL;
   l_err_flag                VARCHAR2(1);
   l_err_msg                 VARCHAR2(1) := NULL;
   l_return_status           VARCHAR2(100) := NULL;


BEGIN

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.Defrag_Contig_Assign (+)  Loc Id: '||p_location_id);

      cust_tab.delete;
      l_rec_num := 0;

      --------------------------------------
      -- Populate the customer PL/SQL table
      --------------------------------------
      FOR cust_rec IN csr_cust LOOP
         l_rec_num :=  NVL(cust_tab.count,0) + 1;
         cust_tab(l_rec_num) := cust_rec;

         pnp_debug_pkg.debug('Cust_Tab i= '||l_rec_num
                             ||', cust: '||cust_rec.cust_account_id
                             ||', str: '||cust_rec.cust_assign_start_date
                             ||', end: '||cust_rec.cust_assign_end_date
                             ||', Id: '||cust_rec.cust_space_assign_id
                             ||', area= '||cust_rec.allocated_area);
      END LOOP;

      pnp_debug_pkg.debug('Defrag_Contig_Assign Cust_Tab... l_rec_num: '||l_rec_num);

      IF NVL(l_rec_num,0) > 1 THEN
         FOR i in 1..CUST_TAB.count-1 LOOP

            pnp_debug_pkg.debug('Defrag_Contig_Assign Cust_Tab... l_rec_num>1  Start_LOOP  i= '||i
            ||', cust_asgn_id= '||NVL(cust_tab(i).cust_space_assign_id,0));

            IF cust_tab(i+1).location_id                          = cust_tab(i).location_id
               AND cust_tab(i+1).cust_account_id                  = cust_tab(i).cust_account_id
               AND NVL(cust_tab(i+1).site_use_id,0)               = NVL(cust_tab(i).site_use_id,0)
               AND NVL(cust_tab(i+1).expense_account_id,0)        = NVL(cust_tab(i).expense_account_id,0)
               AND NVL(cust_tab(i+1).project_id,0)                = NVL(cust_tab(i).project_id,0)
               AND NVL(cust_tab(i+1).task_id,0)                   = NVL(cust_tab(i).task_id,0)
               AND NVL(cust_tab(i+1).utilized_area,0)             = NVL(cust_tab(i).utilized_area,0)
               AND NVL(cust_tab(i+1).allocated_area,0)            = NVL(cust_tab(i).allocated_area,0)
               AND NVL(cust_tab(i+1).allocated_area_pct,0)        = NVL(cust_tab(i).allocated_area_pct,0)
               AND NVL(cust_tab(i+1).cust_space_comments,'X')      = NVL(cust_tab(i).cust_space_comments,'X')
               AND NVL(cust_tab(i+1).lease_id,0)                  = NVL(cust_tab(i).lease_id,0)
               AND NVL(cust_tab(i+1).tenancy_id,0)                = NVL(cust_tab(i).tenancy_id,0)
               AND NVL(cust_tab(i+1).recovery_space_std_code,'X') = NVL(cust_tab(i).recovery_space_std_code,'X')
               AND NVL(cust_tab(i+1).recovery_type_code,'X')      = NVL(cust_tab(i).recovery_type_code,'X')
               AND NVL(cust_tab(i+1).attribute_category,'X')      = NVL(cust_tab(i).attribute_category,'X')
               AND NVL(cust_tab(i+1).attribute1,'X')              = NVL(cust_tab(i).attribute1,'X')
               AND NVL(cust_tab(i+1).attribute2,'X')              = NVL(cust_tab(i).attribute2,'X')
               AND NVL(cust_tab(i+1).attribute3,'X')              = NVL(cust_tab(i).attribute3,'X')
               AND NVL(cust_tab(i+1).attribute4,'X')              = NVL(cust_tab(i).attribute4,'X')
               AND NVL(cust_tab(i+1).attribute5,'X')              = NVL(cust_tab(i).attribute5,'X')
               AND NVL(cust_tab(i+1).attribute6,'X')              = NVL(cust_tab(i).attribute6,'X')
               AND NVL(cust_tab(i+1).attribute7,'X')              = NVL(cust_tab(i).attribute7,'X')
               AND NVL(cust_tab(i+1).attribute8,'X')              = NVL(cust_tab(i).attribute8,'X')
               AND NVL(cust_tab(i+1).attribute9,'X')              = NVL(cust_tab(i).attribute9,'X')
               AND NVL(cust_tab(i+1).attribute10,'X')             = NVL(cust_tab(i).attribute10,'X')
               AND NVL(cust_tab(i+1).attribute11,'X')             = NVL(cust_tab(i).attribute11,'X')
               AND NVL(cust_tab(i+1).attribute12,'X')             = NVL(cust_tab(i).attribute12,'X')
               AND NVL(cust_tab(i+1).attribute13,'X')             = NVL(cust_tab(i).attribute13,'X')
               AND NVL(cust_tab(i+1).attribute14,'X')             = NVL(cust_tab(i).attribute14,'X')
               AND NVL(cust_tab(i+1).attribute15,'X')             = NVL(cust_tab(i).attribute15,'X')
            THEN

               l_diff := cust_tab(i+1).cust_assign_start_date -
                         cust_tab(i).cust_assign_end_date;

               pnp_debug_pkg.debug('Defrag_Contig_Assign Cust_Tab... l_diff: '||l_diff);

               IF l_diff = 1 THEN

                  ---------------------------------------------------------------------------
                  -- If stepping thru cust PL/SQL table records finds contigous records with
                  -- consecutive dates update the (i+1) record with the start date of the ith
                  -- record and .......
                  ---------------------------------------------------------------------------
                 UPDATE pn_space_assign_cust_all
                     SET cust_assign_start_date  = cust_tab(i).cust_assign_start_date
                        ,last_update_date        = SYSDATE
                        ,last_updated_by         = NVL(FND_GLOBAL.USER_ID,'-1')
                        ,last_update_login       = NVL(FND_GLOBAL.LOGIN_ID,'-1')
                  WHERE  cust_space_assign_id = cust_tab(i+1).cust_space_assign_id;

                  ---------------------------------------------------------------------------
                  -- ....... update the (i+1) record with the start date of the ith record
                  -- in the PL/SQL table as well and delete the ith record from the DB
                  ---------------------------------------------------------------------------
                  cust_tab(i+1).cust_assign_start_date := cust_tab(i).cust_assign_start_date;
                  pn_space_assign_cust_pkg.delete_row(cust_tab(i).cust_space_assign_id);

               END IF;
            END IF;
            pnp_debug_pkg.debug('Defrag_Contig_Assign Cust_Tab... l_rec_num>1  End_LOOP  i= '||i);
         END LOOP;
      END IF;

      emp_tab.delete;
      l_rec_num := 0;

      --------------------------------------
      -- Populate the customer PL/SQL table
      --------------------------------------

      FOR emp_rec IN csr_emp LOOP
         l_rec_num :=  NVL(emp_tab.count,0) + 1;
         emp_tab(l_rec_num) := emp_rec;

         pnp_debug_pkg.debug('Emp_Tab i= '||l_rec_num
                             ||', Emp: '||emp_rec.person_id
                             ||', str: '||emp_rec.emp_assign_start_date
                             ||', end: '||emp_rec.emp_assign_end_date
                             ||', Id: '||emp_rec.emp_space_assign_id
                             ||', area= '||emp_rec.allocated_area);
      END LOOP;

      pnp_debug_pkg.debug('Defrag_Contig_Assign Emp_Tab... l_rec_num: '||l_rec_num);

      IF NVL(l_rec_num,0) > 1 THEN
         FOR i in 1..EMP_TAB.count-1 LOOP

            pnp_debug_pkg.debug('Defrag_Contig_Assign Emp_Tab... l_rec_num>1  Start_LOOP  i= '||i);

            IF emp_tab(i+1).location_id                          = emp_tab(i).location_id
               AND emp_tab(i+1).person_id                        = emp_tab(i).person_id
               AND NVL(emp_tab(i+1).cost_center_code,0)          = NVL(emp_tab(i).cost_center_code,0)
               AND NVL(emp_tab(i+1).project_id,0)                = NVL(emp_tab(i).project_id,0)
               AND NVL(emp_tab(i+1).task_id,0)                   = NVL(emp_tab(i).task_id,0)
               AND NVL(emp_tab(i+1).utilized_area,0)             = NVL(emp_tab(i).utilized_area,0)
               AND NVL(emp_tab(i+1).allocated_area,0)            = NVL(emp_tab(i).allocated_area,0)
               AND NVL(emp_tab(i+1).allocated_area_pct,0)        = NVL(emp_tab(i).allocated_area_pct,0)
               AND NVL(emp_tab(i+1).emp_space_comments,'X')      = NVL(emp_tab(i).emp_space_comments,'X')
               AND NVL(emp_tab(i+1).attribute_category,'X')      = NVL(emp_tab(i).attribute_category,'X')
               AND NVL(emp_tab(i+1).attribute1,'X')              = NVL(emp_tab(i).attribute1,'X')
               AND NVL(emp_tab(i+1).attribute2,'X')              = NVL(emp_tab(i).attribute2,'X')
               AND NVL(emp_tab(i+1).attribute3,'X')              = NVL(emp_tab(i).attribute3,'X')
               AND NVL(emp_tab(i+1).attribute4,'X')              = NVL(emp_tab(i).attribute4,'X')
               AND NVL(emp_tab(i+1).attribute5,'X')              = NVL(emp_tab(i).attribute5,'X')
               AND NVL(emp_tab(i+1).attribute6,'X')              = NVL(emp_tab(i).attribute6,'X')
               AND NVL(emp_tab(i+1).attribute7,'X')              = NVL(emp_tab(i).attribute7,'X')
               AND NVL(emp_tab(i+1).attribute8,'X')              = NVL(emp_tab(i).attribute8,'X')
               AND NVL(emp_tab(i+1).attribute9,'X')              = NVL(emp_tab(i).attribute9,'X')
               AND NVL(emp_tab(i+1).attribute10,'X')             = NVL(emp_tab(i).attribute10,'X')
               AND NVL(emp_tab(i+1).attribute11,'X')             = NVL(emp_tab(i).attribute11,'X')
               AND NVL(emp_tab(i+1).attribute12,'X')             = NVL(emp_tab(i).attribute12,'X')
               AND NVL(emp_tab(i+1).attribute13,'X')             = NVL(emp_tab(i).attribute13,'X')
               AND NVL(emp_tab(i+1).attribute14,'X')             = NVL(emp_tab(i).attribute14,'X')
               AND NVL(emp_tab(i+1).attribute15,'X')             = NVL(emp_tab(i).attribute15,'X')
            THEN

               l_diff := emp_tab(i+1).emp_assign_start_date -
                         emp_tab(i).emp_assign_end_date;

               pnp_debug_pkg.debug('Defrag_Contig_Assign Emp_Tab... l_diff: '||l_diff);

               IF l_diff = 1 THEN
                  ---------------------------------------------------------------------------
                  -- If stepping thru emp PL/SQL table records finds contigous records with
                  -- consecutive dates update the (i+1) record with the start date of the ith
                  -- record and .......
                  ---------------------------------------------------------------------------
                  UPDATE pn_space_assign_emp_all
                     SET emp_assign_start_date   = emp_tab(i).emp_assign_start_date
                        ,last_update_date        = SYSDATE
                        ,last_updated_by         = NVL(FND_GLOBAL.USER_ID,'-1')
                        ,last_update_login       = NVL(FND_GLOBAL.LOGIN_ID,'-1')
                  WHERE  emp_space_assign_id = emp_tab(i+1).emp_space_assign_id;

                  ---------------------------------------------------------------------------
                  -- ....... update the (i+1) record with the start date of the ith record
                  -- in the PL/SQL table as well and delete the ith record from the DB
                  ---------------------------------------------------------------------------
                  emp_tab(i+1).emp_assign_start_date := emp_tab(i).emp_assign_start_date;
                  pn_space_assign_emp_pkg.delete_row(emp_tab(i).emp_space_assign_id);

               END IF;
            END IF;
            pnp_debug_pkg.debug('Defrag_Contig_Assign Emp_Tab... l_rec_num>1  End_LOOP  i= '||i);
         END LOOP;
      END IF;

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.Defrag_Contig_Assign (-)  Loc Id: '||p_location_id);

 END Defrag_Contig_Assign;

-------------------------------------------------------------------------------
-- PROCEDURE   : merge_tables
-- DESCRIPTION : Merges base table with a new table. Extract only new location
--               not already in the base table
-- NOTE        : counting starts from 1, not 0 !
-- HISTORY     :
-- 04-APR-05 ftanudja o Created. #4270051.
-------------------------------------------------------------------------------

PROCEDURE merge_tables(
             p_base_table IN OUT NOCOPY loc_id_tbl,
             p_new_table IN loc_id_tbl
) IS
  l_exists          BOOLEAN;

BEGIN

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.merge_tables (+)');

   -- do simple bubble search to identify new tables.
   FOR i IN 1..p_new_table.COUNT LOOP

      l_exists := FALSE;

      FOR j IN 1..p_base_table.COUNT LOOP
         IF p_base_table(j) = p_new_table(i) THEN l_exists := TRUE; exit; END IF;
      END LOOP;

      IF NOT l_exists THEN
         p_base_table(p_base_table.COUNT + 1) := p_new_table(i);
      END IF;

   END LOOP;

   pnp_debug_pkg.debug('PN_SPACE_ASSIGN_CUST_PKG.merge_tables (-)');

END;

-------------------------------------------------------------------------------
--  NAME         : DELETE_OTHER_ASSIGNMENTS_EMP
--  DESCRIPTION  :
--  INVOKED FROM :
--  ARGUMENTS    : IN : x_person_id, x_cost_center_code, x_emp_assign_start_date
--                      x_emp_space_assign_id, x_loc_id_tbl
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  06-FEB-01 dthota  o bug # 1609377 - Added code to update PN_SPACE_ASSIGN_EMP.
--                      emp_assign_end_date of all employee assignments whose
--                      start date is less than the start date of the assignmemnt
--                      record being entered with (emp_assign_start_date -1) and
--                      all employee assignments whose start date is equal to the
--                      start date of the assignmemnt record being entered with
--                      (emp_assign_start_date)
-- 09-MAR-04 ftanudj  o added parameter x_emp_space_assign_id.
-- 06-APR-05 ftanudja o Moved from PNTSPACE library. #4270051.
--                    o Added parameter x_loc_id_tbl, x_cost_center_code.
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_space_assign_emp
--                      with _ALL table.
-- 30-JUN-05  MMisra  o Removed UPDATE for cost center assignments.
--                    o Removed input param. x_cost_center_code.
-------------------------------------------------------------------------------
PROCEDURE delete_other_assignments_emp(
             x_person_id             IN pn_space_assign_emp.person_id%TYPE,
             x_emp_assign_start_date IN pn_space_assign_emp.emp_assign_start_date%TYPE,
             x_emp_space_assign_id   IN pn_space_assign_emp.emp_space_assign_id%TYPE,
             x_loc_id_tbl            OUT NOCOPY LOC_ID_TBL
) IS
  -- one set of tables for cost center, the other for person

  l_loc_tbl_past_cc loc_id_tbl;
  l_loc_tbl_conc_cc loc_id_tbl;
  l_loc_tbl_past_ps loc_id_tbl;
  l_loc_tbl_conc_ps loc_id_tbl;

  l_result_tbl      loc_id_tbl;

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.delete_other_assignments_emp (+)');

   IF x_emp_space_assign_id IS NULL THEN

     UPDATE pn_space_assign_emp_all
     SET    emp_assign_end_date = (TRUNC(x_emp_assign_start_date) - 1)
     WHERE  person_id = x_person_id
     AND    TRUNC(emp_assign_start_date) < TRUNC(x_emp_assign_start_date)
     AND    NVL(emp_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= TRUNC(x_emp_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_past_ps;

     UPDATE pn_space_assign_emp_all
     SET    emp_assign_end_date = TRUNC(x_emp_assign_start_date)
     WHERE  person_id = x_person_id
     AND    TRUNC(emp_assign_start_date) = TRUNC(x_emp_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_conc_ps;

   ELSE

     UPDATE pn_space_assign_emp_all
     SET    emp_assign_end_date = (TRUNC(x_emp_assign_start_date) - 1)
     WHERE  person_id = x_person_id
     AND    emp_space_assign_id <> x_emp_space_assign_id
     AND    TRUNC(emp_assign_start_date) < TRUNC(x_emp_assign_start_date)
     AND    NVL(emp_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= TRUNC(x_emp_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_past_ps;

     UPDATE pn_space_assign_emp_all
     SET    emp_assign_end_date = TRUNC(x_emp_assign_start_date)
     WHERE  person_id = x_person_id
     AND    emp_space_assign_id <> x_emp_space_assign_id
     AND    TRUNC(emp_assign_start_date) = TRUNC(x_emp_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_conc_ps;

   END IF;

   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_past_ps);
   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_conc_ps);
   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_past_cc);
   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_conc_cc);

   x_loc_id_tbl := l_result_tbl;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.delete_other_assignments_emp (-)');

END delete_other_assignments_emp;


-------------------------------------------------------------------------------
--  NAME         : DELETE_OTHER_ASSIGNMENTS_CUST
--  DESCRIPTION  :
--  INVOKED FROM :
--  ARGUMENTS    : IN : x_cust_account_id, x_cust_assign_start_date,
--                      x_cust_space_assign_id, x_loc_id_tbl
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  06-FEB-01 dthota  o bug # 1609377 - Added code to update PN_SPACE_ASSIGN_CUST.
--                      cust_assign_end_date of all customer assignments whose
--                      start date is less than the start date of the assignmemnt
--                      record being entered with (cust_assign_start_date -1) and
--                      all customer assignments whose start date is equal to the
--                      start date of the assignmemnt record being entered with
--                      (cust_assign_start_date)
-- 09-MAR-04 ftanudj  o added parameter x_cust_space_assign_id.
-- 06-APR-05 ftanudja o Moved from PNTSPACE library. #4270051.
--                    o Added parameter x_loc_id_tbl
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_space_assign_cust
--                      with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE delete_other_assignments_cust(
             x_cust_account_id        IN pn_space_assign_cust.cust_account_id%TYPE,
             x_cust_assign_start_date IN pn_space_assign_cust.cust_assign_start_date%TYPE,
             x_cust_space_assign_id   IN pn_space_assign_cust.cust_space_assign_id%TYPE,
             x_loc_id_tbl             OUT NOCOPY LOC_ID_TBL
) IS

  l_loc_tbl_past loc_id_tbl;
  l_loc_tbl_conc loc_id_tbl;

  l_result_tbl   loc_id_tbl;

BEGIN

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.delete_other_assignments_cust (+)');

   IF x_cust_space_assign_id IS NULL THEN

     UPDATE pn_space_assign_cust_all
     SET    cust_assign_end_date   = (TRUNC(x_cust_assign_start_date) - 1)
     WHERE  cust_account_id        = x_cust_account_id
     AND    cust_assign_start_date < TRUNC(x_cust_assign_start_date)
     AND    NVL(cust_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= TRUNC(x_cust_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_past;

     UPDATE pn_space_assign_cust_all
     SET    cust_assign_end_date   = TRUNC(x_cust_assign_start_date)
     WHERE  cust_account_id        = x_cust_account_id
     AND    cust_assign_start_date = TRUNC(x_cust_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_conc;

   ELSE

     UPDATE pn_space_assign_cust_all
     SET    cust_assign_end_date   = (TRUNC(x_cust_assign_start_date) - 1)
     WHERE  cust_account_id        = x_cust_account_id
     AND    cust_space_assign_id <> x_cust_space_assign_id
     AND    cust_assign_start_date < TRUNC(x_cust_assign_start_date)
     AND    NVL(cust_assign_end_date,TO_DATE('12/31/4712','MM/DD/YYYY')) >= TRUNC(x_cust_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_past;

     UPDATE pn_space_assign_cust_all
     SET    cust_assign_end_date   = TRUNC(x_cust_assign_start_date)
     WHERE  cust_account_id        = x_cust_account_id
     AND    cust_space_assign_id <> x_cust_space_assign_id
     AND    cust_assign_start_date = TRUNC(x_cust_assign_start_date)
     RETURNING location_id BULK COLLECT INTO l_loc_tbl_conc;

   END IF;

   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_past);
   merge_tables(p_base_table => l_result_tbl, p_new_table => l_loc_tbl_conc);

   x_loc_id_tbl := l_result_tbl;

   pnp_debug_pkg.debug ('PN_SPACE_ASSIGN_CUST_PKG.delete_other_assignments_cust (+)');

END delete_other_assignments_cust;


END PN_SPACE_ASSIGN_CUST_PKG;

/
