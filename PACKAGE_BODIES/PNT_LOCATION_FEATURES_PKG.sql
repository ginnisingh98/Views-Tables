--------------------------------------------------------
--  DDL for Package Body PNT_LOCATION_FEATURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_LOCATION_FEATURES_PKG" AS
  -- $Header: PNTFEATB.pls 120.2 2005/12/01 08:37:45 appldev ship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION_FEATURES with _ALL
--                       table.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
                 x_rowid                   IN OUT NOCOPY VARCHAR2
                ,x_org_id                  IN            NUMBER
                ,x_LOCATION_FEATURE_ID     IN OUT NOCOPY NUMBER
                ,x_LAST_UPDATE_DATE                      DATE
                ,x_LAST_UPDATED_BY                       NUMBER
                ,x_CREATION_DATE                         DATE
                ,x_CREATED_BY                            NUMBER
                ,x_LAST_UPDATE_LOGIN                     NUMBER
                ,x_LOCATION_ID                           NUMBER
                ,x_LOCATION_FEATURE_LOOKUP_CODE          VARCHAR2
                ,x_DESCRIPTION                           VARCHAR2
                ,x_QUANTITY                              NUMBER
                ,x_FEATURE_SIZE                          NUMBER
                ,x_UOM_CODE                              VARCHAR2
                ,x_CONDITION_LOOKUP_CODE                 VARCHAR2
                ,x_ATTRIBUTE_CATEGORY                    VARCHAR2
                ,x_ATTRIBUTE1                            VARCHAR2
                ,x_ATTRIBUTE2                            VARCHAR2
                ,x_ATTRIBUTE3                            VARCHAR2
                ,x_ATTRIBUTE4                            VARCHAR2
                ,x_ATTRIBUTE5                            VARCHAR2
                ,x_ATTRIBUTE6                            VARCHAR2
                ,x_ATTRIBUTE7                            VARCHAR2
                ,x_ATTRIBUTE8                            VARCHAR2
                ,x_ATTRIBUTE9                            VARCHAR2
                ,x_ATTRIBUTE10                           VARCHAR2
                ,x_ATTRIBUTE11                           VARCHAR2
                ,x_ATTRIBUTE12                           VARCHAR2
                ,x_ATTRIBUTE13                           VARCHAR2
                ,x_ATTRIBUTE14                           VARCHAR2
                ,x_ATTRIBUTE15                           VARCHAR2
)
IS
  CURSOR C IS
    SELECT rowid
    FROM   PN_LOCATION_FEATURES_ALL
    WHERE  LOCATION_FEATURE_ID = x_location_feature_id;

   CURSOR org_cur IS
     SELECT org_id FROM pn_locations_all WHERE location_id = x_LOCATION_ID AND ROWNUM = 1;

   l_org_ID NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.insert_row (+)');

   -----------------------------------------------------------------
   -- Allocate the sequence to the primary key loction_id
   -----------------------------------------------------------------
   SELECT pn_location_features_s.nextval
   INTO   x_location_feature_id
   FROM   dual;

    IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
      END LOOP;
    ELSE
      l_org_id := x_org_id;
    END IF;

   INSERT INTO PN_LOCATION_FEATURES_ALL
   (
       LOCATION_FEATURE_ID
      ,org_id
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,LOCATION_ID
      ,LOCATION_FEATURE_LOOKUP_CODE
      ,DESCRIPTION
      ,QUANTITY
      ,FEATURE_SIZE
      ,UOM_CODE
      ,CONDITION_LOOKUP_CODE
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
       x_LOCATION_FEATURE_ID
      ,l_org_id
      ,x_LAST_UPDATE_DATE
      ,x_LAST_UPDATED_BY
      ,x_CREATION_DATE
      ,x_CREATED_BY
      ,x_LAST_UPDATE_LOGIN
      ,x_LOCATION_ID
      ,x_LOCATION_FEATURE_LOOKUP_CODE
      ,x_DESCRIPTION
      ,x_QUANTITY
      ,x_FEATURE_SIZE
      ,x_UOM_CODE
      ,x_CONDITION_LOOKUP_CODE
      ,x_ATTRIBUTE_CATEGORY
      ,x_ATTRIBUTE1
      ,x_ATTRIBUTE2
      ,x_ATTRIBUTE3
      ,x_ATTRIBUTE4
      ,x_ATTRIBUTE5
      ,x_ATTRIBUTE6
      ,x_ATTRIBUTE7
      ,x_ATTRIBUTE8
      ,x_ATTRIBUTE9
      ,x_ATTRIBUTE10
      ,x_ATTRIBUTE11
      ,x_ATTRIBUTE12
      ,x_ATTRIBUTE13
      ,x_ATTRIBUTE14
      ,x_ATTRIBUTE15
   );
   OPEN C;
   FETCH C INTO x_rowid;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      Raise NO_DATA_FOUND;
   END IF;
   CLOSE C;

   PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.insert_row (-)');

END insert_row;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION_FEATURES with _ALL
--                     table and changed the where clause
-------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
                        x_rowid                          VARCHAR2
                       ,x_LOCATION_FEATURE_ID            NUMBER
                       ,x_LAST_UPDATE_DATE               DATE
                       ,x_LAST_UPDATED_BY                NUMBER
                       ,x_CREATION_DATE                  DATE
                       ,x_CREATED_BY                     NUMBER
                       ,x_LAST_UPDATE_LOGIN              NUMBER
                       ,x_LOCATION_ID                    NUMBER
                       ,x_LOCATION_FEATURE_LOOKUP_CODE   VARCHAR2
                       ,x_DESCRIPTION                    VARCHAR2
                       ,x_QUANTITY                       NUMBER
                       ,x_FEATURE_SIZE                   NUMBER
                       ,x_UOM_CODE                       VARCHAR2
                       ,x_CONDITION_LOOKUP_CODE          VARCHAR2
                       ,x_ATTRIBUTE_CATEGORY             VARCHAR2
                       ,x_ATTRIBUTE1                     VARCHAR2
                       ,x_ATTRIBUTE2                     VARCHAR2
                       ,x_ATTRIBUTE3                     VARCHAR2
                       ,x_ATTRIBUTE4                     VARCHAR2
                       ,x_ATTRIBUTE5                     VARCHAR2
                       ,x_ATTRIBUTE6                     VARCHAR2
                       ,x_ATTRIBUTE7                     VARCHAR2
                       ,x_ATTRIBUTE8                     VARCHAR2
                       ,x_ATTRIBUTE9                     VARCHAR2
                       ,x_ATTRIBUTE10                    VARCHAR2
                       ,x_ATTRIBUTE11                    VARCHAR2
                       ,x_ATTRIBUTE12                    VARCHAR2
                       ,x_ATTRIBUTE13                    VARCHAR2
                       ,x_ATTRIBUTE14                    VARCHAR2
                       ,x_ATTRIBUTE15                    VARCHAR2
                     ) IS
BEGIN

  PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.update_row (+)');
  UPDATE PN_LOCATION_FEATURES_ALL
  SET
         LOCATION_FEATURE_ID      =     x_LOCATION_FEATURE_ID
        ,LAST_UPDATE_DATE         =     x_LAST_UPDATE_DATE
        ,LAST_UPDATED_BY          =     x_LAST_UPDATED_BY
        ,CREATION_DATE            =     x_CREATION_DATE
        ,CREATED_BY               =     x_CREATED_BY
        ,LAST_UPDATE_LOGIN        =     x_LAST_UPDATE_LOGIN
        ,LOCATION_ID              =     x_LOCATION_ID
        ,LOCATION_FEATURE_LOOKUP_CODE=  x_LOCATION_FEATURE_LOOKUP_CODE
        ,DESCRIPTION              =     x_DESCRIPTION
        ,QUANTITY                 =     x_QUANTITY
        ,FEATURE_SIZE             =     x_FEATURE_SIZE
        ,UOM_CODE                 =     x_UOM_CODE
        ,CONDITION_LOOKUP_CODE    =     x_CONDITION_LOOKUP_CODE
        ,ATTRIBUTE_CATEGORY       =     x_ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1               =     x_ATTRIBUTE1
        ,ATTRIBUTE2               =     x_ATTRIBUTE2
        ,ATTRIBUTE3               =     x_ATTRIBUTE3
        ,ATTRIBUTE4               =     x_ATTRIBUTE4
        ,ATTRIBUTE5               =     x_ATTRIBUTE5
        ,ATTRIBUTE6               =     x_ATTRIBUTE6
        ,ATTRIBUTE7               =     x_ATTRIBUTE7
        ,ATTRIBUTE8               =     x_ATTRIBUTE8
        ,ATTRIBUTE9               =     x_ATTRIBUTE9
        ,ATTRIBUTE10              =     x_ATTRIBUTE10
        ,ATTRIBUTE11              =     x_ATTRIBUTE11
        ,ATTRIBUTE12              =     x_ATTRIBUTE12
        ,ATTRIBUTE13              =     x_ATTRIBUTE13
        ,ATTRIBUTE14              =     x_ATTRIBUTE14
        ,ATTRIBUTE15              =     x_ATTRIBUTE15
  WHERE LOCATION_FEATURE_ID       =     x_LOCATION_FEATURE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.update_row (-)');
END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION_FEATURES with _ALL
--                     table and changed the where clause
-------------------------------------------------------------------------------
PROCEDURE lock_row   (   x_rowid                          VARCHAR2
                        ,x_LOCATION_FEATURE_ID            NUMBER
                        ,x_LOCATION_ID                    NUMBER
                        ,x_LOCATION_FEATURE_LOOKUP_CODE   VARCHAR2
                        ,x_DESCRIPTION                    VARCHAR2
                        ,x_QUANTITY                       NUMBER
                        ,x_FEATURE_SIZE                   NUMBER
                        ,x_UOM_CODE                       VARCHAR2
                        ,x_CONDITION_LOOKUP_CODE          VARCHAR2
                        ,x_ATTRIBUTE_CATEGORY             VARCHAR2
                        ,x_ATTRIBUTE1                     VARCHAR2
                        ,x_ATTRIBUTE2                     VARCHAR2
                        ,x_ATTRIBUTE3                     VARCHAR2
                        ,x_ATTRIBUTE4                     VARCHAR2
                        ,x_ATTRIBUTE5                     VARCHAR2
                        ,x_ATTRIBUTE6                     VARCHAR2
                        ,x_ATTRIBUTE7                     VARCHAR2
                        ,x_ATTRIBUTE8                     VARCHAR2
                        ,x_ATTRIBUTE9                     VARCHAR2
                        ,x_ATTRIBUTE10                    VARCHAR2
                        ,x_ATTRIBUTE11                    VARCHAR2
                        ,x_ATTRIBUTE12                    VARCHAR2
                        ,x_ATTRIBUTE13                    VARCHAR2
                        ,x_ATTRIBUTE14                    VARCHAR2
                        ,x_ATTRIBUTE15                    VARCHAR2
                     )
IS
   CURSOR C IS
     SELECT *
     FROM   PN_LOCATION_FEATURES_ALL
     WHERE  LOCATION_FEATURE_ID = x_LOCATION_FEATURE_ID
     FOR    UPDATE OF LOCATION_FEATURE_ID NOWAIT;

   Recinfo C%ROWTYPE;

  BEGIN

  PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.lock_row (+)');
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    IF NOT ((Recinfo.LOCATION_FEATURE_ID = X_LOCATION_FEATURE_ID)
           OR ((Recinfo.LOCATION_FEATURE_ID is null) AND (X_LOCATION_FEATURE_ID is null))) THEN
       pn_var_rent_pkg.lock_row_exception('LOCATION_FEATURE_ID',Recinfo.location_feature_id);
    END IF;

    IF NOT ((Recinfo.LOCATION_ID = X_LOCATION_ID)
           OR ((Recinfo.LOCATION_ID is null) AND (X_LOCATION_ID is null))) THEN
       pn_var_rent_pkg.lock_row_exception('LOCATION_ID',Recinfo.location_id);
    END IF;

    IF NOT ((Recinfo.LOCATION_FEATURE_LOOKUP_CODE = X_LOCATION_FEATURE_LOOKUP_CODE)
           OR ((Recinfo.LOCATION_FEATURE_LOOKUP_CODE is null) AND (X_LOCATION_FEATURE_LOOKUP_CODE is null))) THEN
       pn_var_rent_pkg.lock_row_exception('LOCATION_FEATURE_LOOKUP_CODE',Recinfo.LOCATION_FEATURE_LOOKUP_CODE);
    END IF;

    IF NOT ((Recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((Recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null))) THEN
       pn_var_rent_pkg.lock_row_exception('DESCRIPTION',Recinfo.DESCRIPTION);
    END IF;

    IF NOT ((Recinfo.QUANTITY = X_QUANTITY)
           OR ((Recinfo.QUANTITY is null) AND (X_QUANTITY is null))) THEN
       pn_var_rent_pkg.lock_row_exception('QUANTITY',Recinfo.QUANTITY);
    END IF;

    IF NOT ((Recinfo.FEATURE_SIZE = X_FEATURE_SIZE)
           OR ((Recinfo.FEATURE_SIZE is null) AND (X_FEATURE_SIZE is null))) THEN
       pn_var_rent_pkg.lock_row_exception('FEATURE_SIZE',Recinfo.FEATURE_SIZE);
    END IF;

    IF NOT ((Recinfo.UOM_CODE = X_UOM_CODE)
           OR ((Recinfo.UOM_CODE is null) AND (X_UOM_CODE is null))) THEN
       pn_var_rent_pkg.lock_row_exception('UOM_CODE',Recinfo.UOM_CODE);
    END IF;

    IF NOT ((Recinfo.CONDITION_LOOKUP_CODE = X_CONDITION_LOOKUP_CODE)
           OR ((Recinfo.CONDITION_LOOKUP_CODE is null) AND (X_CONDITION_LOOKUP_CODE is null))) THEN
       pn_var_rent_pkg.lock_row_exception('X_CONDITION_LOOKUP_CODE',Recinfo.CONDITION_LOOKUP_CODE);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
            OR ((Recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY', Recinfo.attribute_category);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
            OR ((Recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1', Recinfo.attribute1);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
            OR ((Recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2', Recinfo.attribute2);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
            OR ((Recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3', Recinfo.attribute3);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
            OR ((Recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4', Recinfo.attribute4);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
            OR ((Recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5', Recinfo.attribute5);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
            OR ((Recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6', Recinfo.attribute6);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
            OR ((Recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7', Recinfo.attribute7);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((Recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8', Recinfo.attribute8);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((Recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9', Recinfo.attribute9);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((Recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10', Recinfo.attribute10);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
            OR ((Recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11', Recinfo.attribute11);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
            OR ((Recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12', Recinfo.attribute12);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
            OR ((Recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13', Recinfo.attribute13);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
            OR ((Recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14', Recinfo.attribute14);
    END IF;

    IF NOT ((Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
            OR ((Recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15', Recinfo.attribute15);
    END IF;

    PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.lock_row (-)');
END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 13-JUL-05  hrodda o Bug 4284035 - Replaced PN_LOCATION_FEATURES with _ALL
--                     table.
-------------------------------------------------------------------------------
PROCEDURE delete_row   (
                                        x_location_feature_id                     NUMBER
                                        ) IS
BEGIN

   PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.delete_row (+)');
   DELETE FROM PN_LOCATION_FEATURES_ALL
   WHERE   location_feature_id = x_location_feature_id;

   IF (sql%notfound) THEN
           RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PNT_LOCATION_FEATURES_PKG.delete_row (-)');
END delete_row;

END PNT_LOCATION_FEATURES_PKG ;

/
