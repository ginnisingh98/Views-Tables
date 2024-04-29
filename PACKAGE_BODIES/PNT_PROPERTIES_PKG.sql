--------------------------------------------------------
--  DDL for Package Body PNT_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_PROPERTIES_PKG" AS
/* $Header: PNTPROPB.pls 120.2 2005/12/01 08:29:15 appldev ship $ */

--------------------------------------------------------------------------------
--  NAME         : check_unique_property_code
--  DESCRIPTION  : checks if property code is UNIQUE in the same OU
--  INVOKED FROM : pld
--  ARGUMENTS    : x_return_status, x_property_id, x_property_code, x_org_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  28-may-05  sdmahesh  o Bug 4284035 - Rewrote for MOAC
--------------------------------------------------------------------------------
PROCEDURE check_unique_property_code (x_return_status IN OUT NOCOPY VARCHAR2,
                                      x_property_id                 NUMBER,
                                      x_property_code               VARCHAR2,
                                      x_org_id                      NUMBER)
IS
   DUP_PROP_CODE EXCEPTION;
   l_prop_ID NUMBER;
   CURSOR dup_prop_code1 IS
      SELECT property_ID
      INTO   l_prop_ID
      FROM   pn_properties_all
      WHERE  property_code = x_property_code
      AND    org_ID = x_org_id;

   CURSOR dup_prop_code2 IS
      SELECT property_ID
      INTO   l_prop_ID
      FROM   pn_properties_all
      WHERE  property_code = x_property_code
      AND    property_id <> x_property_id
      AND    org_ID = x_org_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.check_unique_property_code (+)');

   /* check for duplication */
   IF x_property_id IS NULL THEN
      FOR i IN dup_prop_code1 LOOP
        RAISE DUP_PROP_CODE;
      END LOOP;
   ELSE
      FOR i IN dup_prop_code2 LOOP
        RAISE DUP_PROP_CODE;
      END LOOP;
   END IF;

   PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.check_unique_property_code (-)');

EXCEPTION
   WHEN DUP_PROP_CODE THEN
      fnd_message.set_name ('PN','PN_DUP_PROPERTY_CODE');
      fnd_message.set_token('PROPERTY_CODE', x_property_code);
      x_return_status := 'E';

END check_unique_property_code;

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 22-MAY-02  ftanudja  o added x_org_id for shared serv. enh.
-- 13-Jul-05  sdmahesh  o Replaced PN_PROPERTIES with _ALL tables.Also modified
--                        arguments for check_unique_property_code
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
procedure INSERT_ROW (
                       X_ORG_ID                                NUMBER,
                       X_ROWID                in out NOCOPY    VARCHAR2,
                       X_PROPERTY_ID          in out NOCOPY    NUMBER,
                       X_LAST_UPDATE_DATE                      DATE,
                       X_LAST_UPDATED_BY                       NUMBER,
                       X_CREATION_DATE                         DATE,
                       X_CREATED_BY                            NUMBER,
                       X_LAST_UPDATE_LOGIN                     NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
)
IS

   CURSOR properties IS
      SELECT ROWID
      FROM PN_PROPERTIES_ALL
      WHERE PROPERTY_ID = X_PROPERTY_ID;

   l_return_status VARCHAR2(20) := NULL;

BEGIN

   PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.INSERT_ROW (+)');

   /* Call CHECK_UNIQUE_LOCATION_CODE to check if the property code is unique. */
   l_return_status := NULL;
   check_unique_property_code (
                       l_return_status
                      ,x_property_id
                      ,x_property_code
                      ,x_org_id);
   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   /* Select the nextval for Property Id */
   IF ( X_PROPERTY_ID IS NULL) THEN
      l_return_status := NULL;

      SELECT  pn_properties_s.NEXTVAL
      INTO    X_PROPERTY_ID
      FROM    dual;

      INSERT INTO PN_PROPERTIES_ALL
      (
       ORG_ID,
       PROPERTY_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       PROPERTY_NAME,
       PROPERTY_CODE,
       LOCATION_PARK_ID,
       ZONE,
       DISTRICT,
       COUNTRY,
       DESCRIPTION,
       PORTFOLIO,
       TENURE,
       CLASS,
       PROPERTY_STATUS,
       CONDITION,
       ACTIVE_PROPERTY,
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
       X_ORG_ID,
       X_PROPERTY_ID,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN,
       X_PROPERTY_NAME,
       X_PROPERTY_CODE,
       X_LOCATION_PARK_ID,
       X_ZONE,
       X_DISTRICT,
       X_COUNTRY,
       X_DESCRIPTION,
       X_PORTFOLIO,
       X_TENURE,
       X_CLASS,
       X_PROPERTY_STATUS,
       X_CONDITION,
       X_ACTIVE_PROPERTY,
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

      OPEN properties;
      FETCH properties INTO X_ROWID;
      IF (properties%NOTFOUND) THEN
         CLOSE properties;
         RAISE NO_DATA_FOUND;
      END IF;
      CLOSE properties;

   END IF;

  PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.INSERT_ROW(-)');

END INSERT_ROW;

 -------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 17-JUL-02 ftanudja o modified control logic to follow new standards
-- 21-JUN-05 sdmahesh o Bug 4284035 - Replaced PN_PROPERTIES with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE LOCK_ROW (
                       X_PROPERTY_ID                           NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
) IS

CURSOR c IS
   SELECT *
   FROM PN_PROPERTIES_ALL
   WHERE PROPERTY_ID = X_PROPERTY_ID
   FOR UPDATE OF property_id NOWAIT;

tlinfo c%ROWTYPE;

BEGIN

    PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.LOCK_ROW (+)');

    OPEN c;
    FETCH c INTO tlinfo;
    IF (c%notfound) THEN
       CLOSE c;
       RETURN;
    END IF;
    CLOSE c;

    IF NOT ((tlinfo.PROPERTY_NAME = X_PROPERTY_NAME)
           OR ((tlinfo.PROPERTY_NAME is null) AND (X_PROPERTY_NAME is null))) THEN
       pn_var_rent_pkg.lock_row_exception('PROPERTY_NAME', tlinfo.property_name);
    END IF;

    IF NOT (tlinfo.PROPERTY_CODE = X_PROPERTY_CODE) THEN
       pn_var_rent_pkg.lock_row_exception('PROPERTY_CODE', tlinfo.property_code);
    END IF;

    IF NOT ((tlinfo.LOCATION_PARK_ID = X_LOCATION_PARK_ID)
            OR ((tlinfo.LOCATION_PARK_ID is null) AND (X_LOCATION_PARK_ID is null))) THEN
       pn_var_rent_pkg.lock_row_exception('LOCATION_PARK_ID',tlinfo.location_park_id);
    END IF;

    IF NOT ((tlinfo.ZONE = X_ZONE)
            OR ((tlinfo.ZONE is null) AND (X_ZONE is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ZONE',tlinfo.zone);
    END IF;

    IF NOT ((tlinfo.DISTRICT = X_DISTRICT)
            OR ((tlinfo.DISTRICT is null) AND (X_DISTRICT is null))) THEN
       pn_var_rent_pkg.lock_row_exception('DISTRICT',tlinfo.district);
    END IF;

    IF NOT ((tlinfo.COUNTRY = X_COUNTRY)
            OR ((tlinfo.COUNTRY is null) AND (X_COUNTRY is null))) THEN
       pn_var_rent_pkg.lock_row_exception('COUNTRY',tlinfo.country);
    END IF;

    IF NOT ((tlinfo.DESCRIPTION = X_DESCRIPTION)
            OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null))) THEN
       pn_var_rent_pkg.lock_row_exception('DESCRIPTION',tlinfo.description);
    END IF;

    IF NOT ((tlinfo.PORTFOLIO = X_PORTFOLIO)
           OR ((tlinfo.PORTFOLIO is null) AND (X_PORTFOLIO is null))) THEN
       pn_var_rent_pkg.lock_row_exception('PORTFOLIO',tlinfo.portfolio);
    END IF;

    IF NOT (tlinfo.TENURE = X_TENURE) THEN
       pn_var_rent_pkg.lock_row_exception('TENURE',tlinfo.tenure);
    END IF;

    IF NOT ((tlinfo.CLASS = X_CLASS)
            OR ((tlinfo.CLASS is null) AND (X_CLASS is null))) THEN
       pn_var_rent_pkg.lock_row_exception('CLASS',tlinfo.class);
    END IF;

    IF NOT ((tlinfo.PROPERTY_STATUS = X_PROPERTY_STATUS)
            OR ((tlinfo.PROPERTY_STATUS is null) AND (X_PROPERTY_STATUS is null))) THEN
       pn_var_rent_pkg.lock_row_exception('PROPERTY_STATUS',tlinfo.property_status);
    END IF;

    IF NOT ((tlinfo.CONDITION = X_CONDITION)
           OR ((tlinfo.CONDITION is null) AND (X_CONDITION is null))) THEN
       pn_var_rent_pkg.lock_row_exception('CONDITION',tlinfo.condition);
    END IF;

    IF NOT ((tlinfo.ACTIVE_PROPERTY = X_ACTIVE_PROPERTY)
            OR ((tlinfo.ACTIVE_PROPERTY is null) AND (X_ACTIVE_PROPERTY is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ACTIVE_PROPERTY',tlinfo.active_property);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
            OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY', tlinfo.attribute_category);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
            OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1', tlinfo.attribute1);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
            OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2', tlinfo.attribute2);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
            OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3', tlinfo.attribute3);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
            OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4', tlinfo.attribute4);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
            OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5', tlinfo.attribute5);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
            OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6', tlinfo.attribute6);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
            OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7', tlinfo.attribute7);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8', tlinfo.attribute8);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9', tlinfo.attribute9);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10', tlinfo.attribute10);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
            OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11', tlinfo.attribute11);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
            OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12', tlinfo.attribute12);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
            OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13', tlinfo.attribute13);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
            OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14', tlinfo.attribute14);
    END IF;

    IF NOT ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
            OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) THEN
       pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15', tlinfo.attribute15);
    END IF;


    PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.LOCK_ROW (-)');

END LOCK_ROW;


 -------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : upadtes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_PROPERTIES with _ALL table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
                       X_PROPERTY_ID                           NUMBER,
                       X_LAST_UPDATE_DATE                      DATE,
                       X_LAST_UPDATED_BY                       NUMBER,
                       X_LAST_UPDATE_LOGIN                     NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
)
IS

BEGIN

   PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.UPDATE_ROW (+)');

   UPDATE PN_PROPERTIES_ALL
   SET
      LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN,
      PROPERTY_NAME      = X_PROPERTY_NAME,
      PROPERTY_CODE      = X_PROPERTY_CODE,
      LOCATION_PARK_ID   = X_LOCATION_PARK_ID,
      ZONE               = X_ZONE,
      DISTRICT           = X_DISTRICT,
      COUNTRY            = X_COUNTRY,
      DESCRIPTION        = X_DESCRIPTION,
      PORTFOLIO          = X_PORTFOLIO,
      TENURE             = X_TENURE,
      CLASS              = X_CLASS,
      PROPERTY_STATUS    = X_PROPERTY_STATUS,
      CONDITION          = X_CONDITION,
      ACTIVE_PROPERTY    = X_ACTIVE_PROPERTY,
      ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1         = X_ATTRIBUTE1,
      ATTRIBUTE2         = X_ATTRIBUTE2,
      ATTRIBUTE3         = X_ATTRIBUTE3,
      ATTRIBUTE4         = X_ATTRIBUTE4,
      ATTRIBUTE5         = X_ATTRIBUTE5,
      ATTRIBUTE6         = X_ATTRIBUTE6,
      ATTRIBUTE7         = X_ATTRIBUTE7,
      ATTRIBUTE8         = X_ATTRIBUTE8,
      ATTRIBUTE9         = X_ATTRIBUTE9,
      ATTRIBUTE10        = X_ATTRIBUTE10,
      ATTRIBUTE11        = X_ATTRIBUTE11,
      ATTRIBUTE12        = X_ATTRIBUTE12,
      ATTRIBUTE13        = X_ATTRIBUTE13,
      ATTRIBUTE14        = X_ATTRIBUTE14,
      ATTRIBUTE15        = X_ATTRIBUTE15
   WHERE PROPERTY_ID = X_PROPERTY_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PNT_PROPERTIES_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

END  PNT_PROPERTIES_PKG;

/
