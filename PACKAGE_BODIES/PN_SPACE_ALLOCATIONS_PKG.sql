--------------------------------------------------------
--  DDL for Package Body PN_SPACE_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SPACE_ALLOCATIONS_PKG" as
  -- $Header: PNTSPALB.pls 120.1 2005/07/26 06:52:58 appldev ship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
   X_ROWID in out NOCOPY VARCHAR2,
   X_SPACE_ALLOCATION_ID in out NOCOPY NUMBER,
   X_LOCATION_ID in NUMBER,
   X_EMPLOYEE_ID in NUMBER,
   X_COST_CENTER_CODE in VARCHAR2,
   X_ALLOCATED_AREA_PCT in NUMBER,
   X_ALLOCATED_AREA in NUMBER,
   X_ATTRIBUTE_CATEGORY in VARCHAR2,
   X_ATTRIBUTE1 in VARCHAR2,
   X_ATTRIBUTE2 in VARCHAR2,
   X_ATTRIBUTE3 in VARCHAR2,
   X_ATTRIBUTE4 in VARCHAR2,
   X_ATTRIBUTE5 in VARCHAR2,
   X_ATTRIBUTE6 in VARCHAR2,
   X_ATTRIBUTE7 in VARCHAR2,
   X_ATTRIBUTE8 in VARCHAR2,
   X_ATTRIBUTE9 in VARCHAR2,
   X_ATTRIBUTE10 in VARCHAR2,
   X_ATTRIBUTE11 in VARCHAR2,
   X_ATTRIBUTE12 in VARCHAR2,
   X_ATTRIBUTE13 in VARCHAR2,
   X_ATTRIBUTE14 in VARCHAR2,
   X_ATTRIBUTE15 in VARCHAR2,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
   )
IS
   CURSOR C IS
      SELECT ROWID
      FROM PN_SPACE_ALLOCATIONS_ALL       --sdm_MOAC
      WHERE SPACE_ALLOCATION_ID = X_SPACE_ALLOCATION_ID ;

BEGIN
   SELECT PN_SPACE_ALLOCATIONS_S.nextval
   INTO X_SPACE_ALLOCATION_ID
   FROM DUAL;

   INSERT INTO PN_SPACE_ALLOCATIONS_ALL
   (                 --sdm_MOAC
       SPACE_ALLOCATION_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LOCATION_ID,
       EMPLOYEE_ID,
       COST_CENTER_CODE,
       ALLOCATED_AREA_PCT,
       ALLOCATED_AREA,
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
       X_SPACE_ALLOCATION_ID,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_LOCATION_ID,
       X_EMPLOYEE_ID,
       X_COST_CENTER_CODE,
       X_ALLOCATED_AREA_PCT,
       X_ALLOCATED_AREA,
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
       X_ATTRIBUTE15
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   -- dbms_output.put_line('row line number:'||x_rowid);
   IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
procedure LOCK_ROW
(
  X_SPACE_ALLOCATION_ID in NUMBER,
  X_LOCATION_ID in NUMBER,
  X_EMPLOYEE_ID in NUMBER,
  X_COST_CENTER_CODE in VARCHAR2,
  X_ALLOCATED_AREA_PCT in NUMBER,
  X_ALLOCATED_AREA in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
)
IS
   CURSOR c1 IS SELECT
      LOCATION_ID,
      EMPLOYEE_ID,
      COST_CENTER_CODE,
      ALLOCATED_AREA_PCT,
      ALLOCATED_AREA,
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
      SPACE_ALLOCATION_ID
      FROM PN_SPACE_ALLOCATIONS_ALL          --sdm_MOAC
      WHERE SPACE_ALLOCATION_ID = X_SPACE_ALLOCATION_ID
      FOR UPDATE OF SPACE_ALLOCATION_ID nowait;
   tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 into tlinfo;
  IF (c1%notfound) THEN
    CLOSE c1;
    RETURN;
  END IF;
  CLOSE c1;

  IF ((tlinfo.SPACE_ALLOCATION_ID = X_SPACE_ALLOCATION_ID)
      AND (tlinfo.LOCATION_ID = X_LOCATION_ID)
      AND ((tlinfo.EMPLOYEE_ID = X_EMPLOYEE_ID)
           OR ((tlinfo.EMPLOYEE_ID is null) AND (X_EMPLOYEE_ID is null)))
      AND ((tlinfo.COST_CENTER_CODE = X_COST_CENTER_CODE)
           OR ((tlinfo.COST_CENTER_CODE is null) AND (X_COST_CENTER_CODE is null)))
      AND ((tlinfo.ALLOCATED_AREA_PCT = X_ALLOCATED_AREA_PCT)
           OR ((tlinfo.ALLOCATED_AREA_PCT is null) AND (X_ALLOCATED_AREA_PCT is null)))
      AND ((tlinfo.ALLOCATED_AREA = X_ALLOCATED_AREA)
           OR ((tlinfo.ALLOCATED_AREA is null) AND (X_ALLOCATED_AREA is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
   X_SPACE_ALLOCATION_ID   IN NUMBER,
   X_LOCATION_ID           IN NUMBER,
   X_EMPLOYEE_ID           IN NUMBER,
   X_COST_CENTER_CODE      IN VARCHAR2,
   X_ALLOCATED_AREA_PCT    IN NUMBER,
   X_ALLOCATED_AREA        IN NUMBER,
   X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
   X_ATTRIBUTE1            IN VARCHAR2,
   X_ATTRIBUTE2            IN VARCHAR2,
   X_ATTRIBUTE3            IN VARCHAR2,
   X_ATTRIBUTE4            IN VARCHAR2,
   X_ATTRIBUTE5            IN VARCHAR2,
   X_ATTRIBUTE6            IN VARCHAR2,
   X_ATTRIBUTE7            IN VARCHAR2,
   X_ATTRIBUTE8            IN VARCHAR2,
   X_ATTRIBUTE9            IN VARCHAR2,
   X_ATTRIBUTE10           IN VARCHAR2,
   X_ATTRIBUTE11           IN VARCHAR2,
   X_ATTRIBUTE12           IN VARCHAR2,
   X_ATTRIBUTE13           IN VARCHAR2,
   X_ATTRIBUTE14           IN VARCHAR2,
   X_ATTRIBUTE15           IN VARCHAR2,
   X_LAST_UPDATE_DATE      IN DATE,
   X_LAST_UPDATED_BY       IN NUMBER,
   X_LAST_UPDATE_LOGIN     IN NUMBER
) IS
BEGIN
  UPDATE PN_SPACE_ALLOCATIONS_ALL SET              --sdm_MOAC
    LOCATION_ID = X_LOCATION_ID,
    EMPLOYEE_ID = X_EMPLOYEE_ID,
    COST_CENTER_CODE = X_COST_CENTER_CODE,
    ALLOCATED_AREA_PCT = X_ALLOCATED_AREA_PCT,
    ALLOCATED_AREA = X_ALLOCATED_AREA,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE SPACE_ALLOCATION_ID = X_SPACE_ALLOCATION_ID;

  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
procedure DELETE_ROW
(
  X_SPACE_ALLOCATION_ID in NUMBER
)
IS
BEGIN
  DELETE FROM PN_SPACE_ALLOCATIONS_ALL          --sdm_MOAC
  WHERE SPACE_ALLOCATION_ID = X_SPACE_ALLOCATION_ID;

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_ROW;


/*-------------------------------------------------------------------------------
-- ASSIGNED Function --
-------------------------------------------------------------------------------*/
FUNCTION ASSIGNED ( X_EMPLOYEE_ID in NUMBER,
                    X_ORG_ID      in NUMBER)       --sdm_MOAC
RETURN Boolean IS
   l_dummy VARCHAR2(1);
BEGIN

  SELECT 'x'
  INTO   l_dummy
  FROM   dual
  WHERE  EXISTS
               ( SELECT '1'
                 FROM   PN_SPACE_ALLOCATIONS_ALL      --sdm_MOAC
                 WHERE  EMPLOYEE_ID = X_EMPLOYEE_ID
                 AND    ORG_ID = X_ORG_ID);        --sdm_MOAC

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;

END ASSIGNED;


/*-------------------------------------------------------------------------------
-- DELETE_OTHER_ASSIGNMENTS Procedure --
-------------------------------------------------------------------------------*/
PROCEDURE DELETE_OTHER_ASSIGNMENTS (
  X_EMPLOYEE_ID in NUMBER,
  X_ORG_ID  in NUMBER               --sdm_MOAC
   ) IS

BEGIN

  DELETE FROM PN_SPACE_ALLOCATIONS_ALL          --sdm_MOAC
  WHERE  EMPLOYEE_ID = X_EMPLOYEE_ID
  AND   ORG_ID = X_ORG_ID;             --sdm_MOAC

  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_OTHER_ASSIGNMENTS;


-------------------------------------------------------------------------------
-- PROCDURE     : VACANT_AREA_SUMMARY
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
PROCEDURE VACANT_AREA_SUMMARY
(
  x_location_id                    number,
  x_vacant_area            in out NOCOPY  number,
  x_vacant_area_rtot_db    in out NOCOPY  number
) IS

BEGIN

   SELECT sum(PNP_UTIL_FUNC.get_vacant_area(location_id))
   INTO x_vacant_area
   FROM PN_SPACE_ALLOCATIONS_ALL          --sdm_MOAC
   WHERE location_id = x_location_id;

   x_vacant_area_rtot_db := x_vacant_area ;

END VACANT_AREA_SUMMARY;


-------------------------------------------------------------------------------
-- PROCDURE     : UTILIZED_CAPACITY_SUMMARY
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
PROCEDURE UTILIZED_CAPACITY_SUMMARY (
  x_location_id                          NUMBER,
  x_utilized_capacity            in OUT NOCOPY  NUMBER,
  x_utilized_capacity_rtot_db    IN OUT NOCOPY  NUMBER
) IS

BEGIN

   SELECT sum(PNP_UTIL_FUNC.get_utilized_capacity(location_id))
   INTO x_utilized_capacity
   FROM PN_SPACE_ALLOCATIONS_ALL
   WHERE location_id = x_location_id ;

   x_utilized_capacity_rtot_db := x_utilized_capacity ;

END UTILIZED_CAPACITY_SUMMARY;


-------------------------------------------------------------------------------
-- PROCDURE     : AREA_PCT_AND_AREA
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced PN_SPACE_ALLOCATIONS with _ALL
--                      table.
-------------------------------------------------------------------------------
PROCEDURE AREA_PCT_AND_AREA (
  x_usable_area    number,
  x_location_id    number
) IS

  l_utilized       number;

BEGIN

  SELECT count(*)
  INTO   l_utilized
  FROM   pn_space_allocations_all         --sdm_MOAC
  WHERE  location_id = x_location_id;


  UPDATE PN_SPACE_ALLOCATIONS_ALL         --sdm_MOAC
  SET    allocated_area_pct = round(100 / l_utilized, 2),
         allocated_area     = round(x_usable_area / l_utilized, 2)
  WHERE  location_id        = x_location_id;


END AREA_PCT_AND_AREA;


/*-------------------------------------------------------------------------------
-- End of Pkg -- PN_SPACE_ALLOCATIONS_PKG
-------------------------------------------------------------------------------*/
END PN_SPACE_ALLOCATIONS_PKG;

/
