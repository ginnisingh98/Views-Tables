--------------------------------------------------------
--  DDL for Package Body PNT_COMP_SITE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_COMP_SITE_PKG" AS
  -- $Header: PNTCSITB.pls 120.3 2005/12/01 03:37:00 appldev ship $

-------------------------------------------------------------------------------
--  NAME         : check_unique_company_role
--  DESCRIPTION  : Raises fatal error if role already exists for a company
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_lease_role_type, p_company_id, p_company_site_id,
--                 p_org_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
-- 22-JUN-98  Neeraj Tandon o Created
-- 14-MAY-02  Daniel Thota  o Added parameter p_org_id as part of Multi-Org changes
-- 21-JUN-05  piagrawa      o Bug 4284035 - Removed NVL
-------------------------------------------------------------------------------
PROCEDURE check_unique_company_role (
                                      p_lease_role_type   IN VARCHAR2,
                                      p_company_id        IN NUMBER,
                                      p_company_site_id   IN NUMBER,
                                      p_org_id            IN NUMBER
                                    ) IS
  dummy VARCHAR2(30);

BEGIN

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.check_unique_company_role (+)');

  SELECT count(1)
  INTO   dummy
  FROM   pn_company_sites_all cs
  WHERE  cs.company_id       = p_company_id
  AND    cs.lease_role_type  = p_lease_role_type
  AND    ((p_company_site_id is null) or cs.company_site_id <> p_company_site_id )
  AND    org_id  = p_org_id;

  IF dummy >= 1 THEN

    FND_MESSAGE.set_name ('PN','PN_COMP_LEASE_ROLE_EXISTS');
    APP_EXCEPTION.raise_exception;

  END IF;

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.check_unique_company_role (-)');

END check_unique_company_role;

-------------------------------------------------------------------------------
--  NAME         : defined_address_format
--  DESCRIPTION  : Checks if address format is defined in the descriptive
--                 flexfield definition
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_addr_code
--  RETURNS      : boolean
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
-- 06-JUN-05 piagrawa   o Bug #4331843 Created
-------------------------------------------------------------------------------
FUNCTION defined_address_format(p_addr_code IN VARCHAR2) RETURN BOOLEAN IS

CURSOR address_format IS
   SELECT descr.descriptive_flex_context_code
   FROM  fnd_lookups f
        ,fnd_descr_flex_contexts descr
   WHERE f.lookup_type = 'ADDRESS_STYLE'
   AND   descr.descriptive_flexfield_name = 'Flexible Address Format'
   AND   descr.application_ID = 240
   AND   descr.descriptive_flex_context_code = f.lookup_code
   AND   f.lookup_code = p_addr_code;

l_addr_forms_def BOOLEAN;

BEGIN

   l_addr_forms_def := FALSE;
   FOR i IN address_format LOOP
      l_addr_forms_def := TRUE;
   END LOOP;

   RETURN l_addr_forms_def;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END defined_address_format;

-------------------------------------------------------------------------------
--  NAME         : insert_row
--  DESCRIPTION  : insert row
--  INVOKED FROM :
--  ARGUMENTS    :
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
-- 13-Jun-05 Kiran     o Use _ALL tables - MOAC
-- 28-NOV-05 pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE insert_row ( x_rowid                   IN OUT NOCOPY VARCHAR2,
                       x_company_site_id         IN OUT NOCOPY NUMBER,
                       x_last_update_date               DATE,
                       x_last_updated_by                NUMBER,
                       x_creation_date                  DATE,
                       x_created_by                     NUMBER,
                       x_last_update_login              NUMBER,
                       x_name                           VARCHAR2,
                       x_company_id                     NUMBER,
                       x_enabled_flag                   VARCHAR2,
                       x_company_site_code              VARCHAR2,
                       x_address_id              IN OUT NOCOPY NUMBER,
                       x_lease_role_type                VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2,
                       x_address_line1                  VARCHAR2,
                       x_address_line2                  VARCHAR2,
                       x_address_line3                  VARCHAR2,
                       x_address_line4                  VARCHAR2,
                       x_county                         VARCHAR2,
                       x_city                           VARCHAR2,
                       x_state                          VARCHAR2,
                       x_province                       VARCHAR2,
                       x_zip_code                       VARCHAR2,
                       x_country                        VARCHAR2,
                       x_territory_id                   NUMBER,
                       x_addr_last_update_date          DATE,
                       x_addr_last_updated_by           NUMBER,
                       x_addr_creation_date             DATE,
                       x_addr_created_by                NUMBER,
                       x_addr_last_update_login         NUMBER,
                       x_addr_attribute_category        VARCHAR2,
                       x_addr_attribute1                VARCHAR2,
                       x_addr_attribute2                VARCHAR2,
                       x_addr_attribute3                VARCHAR2,
                       x_addr_attribute4                VARCHAR2,
                       x_addr_attribute5                VARCHAR2,
                       x_addr_attribute6                VARCHAR2,
                       x_addr_attribute7                VARCHAR2,
                       x_addr_attribute8                VARCHAR2,
                       x_addr_attribute9                VARCHAR2,
                       x_addr_attribute10               VARCHAR2,
                       x_addr_attribute11               VARCHAR2,
                       x_addr_attribute12               VARCHAR2,
                       x_addr_attribute13               VARCHAR2,
                       x_addr_attribute14               VARCHAR2,
                       x_addr_attribute15               VARCHAR2,
                       x_org_id                         NUMBER
                     ) IS
  CURSOR C IS
    SELECT rowid
    FROM   pn_company_sites_all
    WHERE  company_site_id = x_company_site_id;

  CURSOR org_cur IS
    SELECT org_id
    FROM   pn_companies_all
    WHERE  company_id = x_company_id;

  l_org_id NUMBER;

BEGIN

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.insert_row (+)');

  IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
  ELSE
    l_org_id := x_org_id;
  END IF;

  -----------------------------------------------------------------
  -- Call the PN_ADDRESSES insert table handler to create an address
  -- row and also return the address_id (OUT parameter) for
  -- PN_COMPANY_SITES table
  -----------------------------------------------------------------
  PNT_ADDR_PKG.insert_row ( x_address_id,
                            x_address_line1,
                            x_address_line2,
                            x_address_line3,
                            x_address_line4,
                            x_county,
                            x_city,
                            x_state,
                            x_province,
                            x_zip_code,
                            x_country,
                            x_territory_id,
                            x_last_update_date,
                            x_last_updated_by,
                            x_creation_date,
                            x_created_by,
                            x_last_update_login,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            x_addr_attribute_category,
                            x_addr_attribute1,
                            x_addr_attribute2,
                            x_addr_attribute3,
                            x_addr_attribute4,
                            x_addr_attribute5,
                            x_addr_attribute6,
                            x_addr_attribute7,
                            x_addr_attribute8,
                            x_addr_attribute9,
                            x_addr_attribute10,
                            x_addr_attribute11,
                            x_addr_attribute12,
                            x_addr_attribute13,
                            x_addr_attribute14,
                            x_addr_attribute15,
                            l_org_id
                          );

  -----------------------------------------------------------------
  -- Allocate the sequence to the primary key company_site_id
  -----------------------------------------------------------------

  SELECT pn_company_sites_s.nextval
  INTO   x_company_site_id
  FROM   dual;

  INSERT INTO pn_company_sites_all (
                                 company_site_id,
                                 last_update_date,
                                 last_updated_by,
                                 creation_date,
                                 created_by,
                                 last_update_login,
                                 name,
                                 company_id,
                                 enabled_flag,
                                 company_site_code,
                                 address_id,
                                 lease_role_type,
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
                                 org_id
                               )
  VALUES
                               (
                                 x_company_site_id,
                                 x_last_update_date,
                                 x_last_updated_by,
                                 x_creation_date,
                                 x_created_by,
                                 x_last_update_login,
                                 x_name,
                                 x_company_id,
                                 x_enabled_flag,
                                 x_company_site_code,
                                 x_address_id,
                                 x_lease_role_type,
                                 x_attribute_category,
                                 x_attribute1,
                                 x_attribute2,
                                 x_attribute3,
                                 x_attribute4,
                                 x_attribute5,
                                 x_attribute6,
                                 x_attribute7,
                                 x_attribute8,
                                 x_attribute9,
                                 x_attribute10,
                                 x_attribute11,
                                 x_attribute12,
                                 x_attribute13,
                                 x_attribute14,
                                 x_attribute15,
                                 l_org_id
                               );
  OPEN C;
    FETCH C INTO x_rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
  CLOSE C;

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.insert_row (-)');

END insert_row;

-------------------------------------------------------------------------------
--  NAME         : update_row
--  DESCRIPTION  : update_row
--  INVOKED FROM :
--  ARGUMENTS    :
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE update_row ( x_rowid                          VARCHAR2,
                       x_company_id                     NUMBER,
                       x_company_site_id                NUMBER,
                       x_last_update_date               DATE,
                       x_last_updated_by                NUMBER,
                       x_last_update_login              NUMBER,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_company_site_code              VARCHAR2,
                       x_lease_role_type                VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2,
                       x_address_id                     NUMBER,
                       x_address_line1                  VARCHAR2,
                       x_address_line2                  VARCHAR2,
                       x_address_line3                  VARCHAR2,
                       x_address_line4                  VARCHAR2,
                       x_county                         VARCHAR2,
                       x_city                           VARCHAR2,
                       x_state                          VARCHAR2,
                       x_province                       VARCHAR2,
                       x_zip_code                       VARCHAR2,
                       x_country                        VARCHAR2,
                       x_territory_id                   NUMBER,
                       x_addr_last_update_date          DATE,
                       x_addr_last_updated_by           NUMBER,
                       x_addr_last_update_login         NUMBER,
                       x_addr_attribute_category        VARCHAR2,
                       x_addr_attribute1                VARCHAR2,
                       x_addr_attribute2                VARCHAR2,
                       x_addr_attribute3                VARCHAR2,
                       x_addr_attribute4                VARCHAR2,
                       x_addr_attribute5                VARCHAR2,
                       x_addr_attribute6                VARCHAR2,
                       x_addr_attribute7                VARCHAR2,
                       x_addr_attribute8                VARCHAR2,
                       x_addr_attribute9                VARCHAR2,
                       x_addr_attribute10               VARCHAR2,
                       x_addr_attribute11               VARCHAR2,
                       x_addr_attribute12               VARCHAR2,
                       x_addr_attribute13               VARCHAR2,
                       x_addr_attribute14               VARCHAR2,
                       x_addr_attribute15               VARCHAR2
                     ) IS
BEGIN

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.update_row (+)');

  UPDATE pn_company_sites_all
  SET
        last_update_date      = x_last_update_date,
        last_updated_by       = x_last_updated_by,
        last_update_login     = x_last_update_login,
        name                  = x_name,
        enabled_flag          = x_enabled_flag,
        company_site_code     = x_company_site_code,
        lease_role_type       = x_lease_role_type,
        attribute_category    = x_attribute_category,
        attribute1            = x_attribute1,
        attribute2            = x_attribute2,
        attribute3            = x_attribute3,
        attribute4            = x_attribute4,
        attribute5            = x_attribute5,
        attribute6            = x_attribute6,
        attribute7            = x_attribute7,
        attribute8            = x_attribute8,
        attribute9            = x_attribute9,
        attribute10           = x_attribute10,
        attribute11           = x_attribute11,
        attribute12           = x_attribute12,
        attribute13           = x_attribute13,
        attribute14           = x_attribute14,
        attribute15           = x_attribute15
  WHERE company_site_id = x_company_site_id
  AND   rowid           = x_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  -----------------------------------------------------------------
  -- Call the PN_ADDRESSES update table handler to update address
  -- elements.
  -----------------------------------------------------------------
  PNT_ADDR_PKG.update_row ( x_address_id,
                            x_address_line1,
                            x_address_line2,
                            x_address_line3,
                            x_address_line4,
                            x_county,
                            x_city,
                            x_state,
                            x_province,
                            x_zip_code,
                            x_country,
                            x_territory_id,
                            x_last_update_date,
                            x_last_updated_by,
                            x_last_update_login,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            x_addr_attribute_category,
                            x_addr_attribute1,
                            x_addr_attribute2,
                            x_addr_attribute3,
                            x_addr_attribute4,
                            x_addr_attribute5,
                            x_addr_attribute6,
                            x_addr_attribute7,
                            x_addr_attribute8,
                            x_addr_attribute9,
                            x_addr_attribute10,
                            x_addr_attribute11,
                            x_addr_attribute12,
                            x_addr_attribute13,
                            x_addr_attribute14,
                            x_addr_attribute15
                          );

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.update_row (-)');

END update_row;

-------------------------------------------------------------------------------
--  NAME         : lock_row
--  DESCRIPTION  : lock_row
--  INVOKED FROM :
--  ARGUMENTS    :
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
-------------------------------------------------------------------------------
PROCEDURE lock_row   ( x_rowid                          VARCHAR2,
                       x_company_site_id                NUMBER,
                       x_name                           VARCHAR2,
                       x_company_id                     NUMBER,
                       x_enabled_flag                   VARCHAR2,
                       x_company_site_code              VARCHAR2,
                       x_address_id                     NUMBER,
                       x_lease_role_type                VARCHAR2,
                       x_attribute_category             VARCHAR2,
                       x_attribute1                     VARCHAR2,
                       x_attribute2                     VARCHAR2,
                       x_attribute3                     VARCHAR2,
                       x_attribute4                     VARCHAR2,
                       x_attribute5                     VARCHAR2,
                       x_attribute6                     VARCHAR2,
                       x_attribute7                     VARCHAR2,
                       x_attribute8                     VARCHAR2,
                       x_attribute9                     VARCHAR2,
                       x_attribute10                    VARCHAR2,
                       x_attribute11                    VARCHAR2,
                       x_attribute12                    VARCHAR2,
                       x_attribute13                    VARCHAR2,
                       x_attribute14                    VARCHAR2,
                       x_attribute15                    VARCHAR2,
                       x_address_line1                  VARCHAR2,
                       x_address_line2                  VARCHAR2,
                       x_address_line3                  VARCHAR2,
                       x_address_line4                  VARCHAR2,
                       x_county                         VARCHAR2,
                       x_city                           VARCHAR2,
                       x_state                          VARCHAR2,
                       x_province                       VARCHAR2,
                       x_zip_code                       VARCHAR2,
                       x_country                        VARCHAR2,
                       x_territory_id                   NUMBER,
                       x_addr_attribute_category        VARCHAR2,
                       x_addr_attribute1                VARCHAR2,
                       x_addr_attribute2                VARCHAR2,
                       x_addr_attribute3                VARCHAR2,
                       x_addr_attribute4                VARCHAR2,
                       x_addr_attribute5                VARCHAR2,
                       x_addr_attribute6                VARCHAR2,
                       x_addr_attribute7                VARCHAR2,
                       x_addr_attribute8                VARCHAR2,
                       x_addr_attribute9                VARCHAR2,
                       x_addr_attribute10               VARCHAR2,
                       x_addr_attribute11               VARCHAR2,
                       x_addr_attribute12               VARCHAR2,
                       x_addr_attribute13               VARCHAR2,
                       x_addr_attribute14               VARCHAR2,
                       x_addr_attribute15               VARCHAR2
                     ) IS
   CURSOR C IS
     SELECT *
     FROM   pn_company_sites_all
     WHERE  rowid = x_rowid
     FOR    update of company_site_id NOWAIT;

   Recinfo C%ROWTYPE;


BEGIN

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.lock_row (+)');

    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

        IF NOT (Recinfo.company_site_id     = x_company_site_id) THEN
           pn_var_rent_pkg.lock_row_exception('company_site_id',Recinfo.company_site_id);
        END IF;
        IF NOT (Recinfo.name = x_name) THEN
           pn_var_rent_pkg.lock_row_exception('name',Recinfo.name);
        END IF;
        IF NOT (Recinfo.enabled_flag = x_enabled_flag) THEN
           pn_var_rent_pkg.lock_row_exception('enabled_flag',Recinfo.enabled_flag);
        END IF;
        IF NOT ((Recinfo.company_id = x_company_id)
             or ((Recinfo.company_id is null) and (x_company_id is null))) THEN
           pn_var_rent_pkg.lock_row_exception('company_id',Recinfo.company_id);
        END IF;
        IF NOT ((Recinfo.lease_role_type = x_lease_role_type)
             or ((Recinfo.lease_role_type is null) and (x_lease_role_type is null))) THEN
           pn_var_rent_pkg.lock_row_exception('lease_role_type',Recinfo.lease_role_type);
        END IF;
        IF NOT ((Recinfo.company_site_code = x_company_site_code)
             or ((Recinfo.company_site_code is null) and (x_company_site_code is null))) THEN
           pn_var_rent_pkg.lock_row_exception('company_site_code',Recinfo.company_site_code);
        END IF;
        IF NOT ((Recinfo.address_id = x_address_id)
             or ((Recinfo.address_id is null) and (x_address_id is null))) THEN
           pn_var_rent_pkg.lock_row_exception('address_id',Recinfo.address_id);
        END IF;
        IF NOT ((Recinfo.attribute11 = x_attribute11)
             or ((Recinfo.attribute11 is null) and (x_attribute11 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute11',Recinfo.attribute11);
        END IF;
        IF NOT ((Recinfo.attribute12 = x_attribute12)
             or ((Recinfo.attribute12 is null) and (x_attribute12 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute12',Recinfo.attribute12);
        END IF;
        IF NOT ((Recinfo.attribute13 = x_attribute13)
             or ((Recinfo.attribute13 is null) and (x_attribute13 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute13',Recinfo.attribute13);
        END IF;
        IF NOT ((Recinfo.attribute14 = x_attribute14)
             or ((Recinfo.attribute14 is null) and (x_attribute14 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute14',Recinfo.attribute14);
        END IF;
        IF NOT ((Recinfo.attribute15 = x_attribute15)
             or ((Recinfo.attribute15 is null) and (x_attribute15 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute15',Recinfo.attribute15);
        END IF;
        IF NOT ((Recinfo.attribute_category = x_attribute_category)
             or ((Recinfo.attribute_category is null) and (x_attribute_category is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute_category',Recinfo.attribute_category);
        END IF;
        IF NOT ((Recinfo.attribute1 = x_attribute1)
             or ((Recinfo.attribute1 is null) and (x_attribute1 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute1',Recinfo.attribute1);
        END IF;
        IF NOT ((Recinfo.attribute2 = x_attribute2)
             or ((Recinfo.attribute2 is null) and (x_attribute2 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute2',Recinfo.attribute2);
        END IF;
        IF NOT ((Recinfo.attribute3 = x_attribute3)
             or ((Recinfo.attribute3 is null) and (x_attribute3 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute3',Recinfo.attribute3);
        END IF;
        IF NOT ((Recinfo.attribute4 = x_attribute4)
             or ((Recinfo.attribute4 is null) and (x_attribute4 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute4',Recinfo.attribute4);
        END IF;
        IF NOT ((Recinfo.attribute5 = x_attribute5)
             or ((Recinfo.attribute5 is null) and (x_attribute5 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute5',Recinfo.attribute5);
        END IF;
        IF NOT ((Recinfo.attribute6 = x_attribute6)
             or ((Recinfo.attribute6 is null) and (x_attribute6 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute6',Recinfo.attribute6);
        END IF;
        IF NOT ((Recinfo.attribute7 = x_attribute7)
             or ((Recinfo.attribute7 is null) and (x_attribute7 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute7',Recinfo.attribute7);
        END IF;
        IF NOT ((Recinfo.attribute8 = x_attribute8)
             or ((Recinfo.attribute8 is null) and (x_attribute8 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute8',Recinfo.attribute8);
        END IF;
        IF NOT ((Recinfo.attribute9 = x_attribute9)
             or ((Recinfo.attribute9 is null) and (x_attribute9 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute9',Recinfo.attribute9);
        END IF;
        IF NOT ((Recinfo.attribute10 = x_attribute10)
             or ((Recinfo.attribute10 is null) and (x_attribute10 is null))) THEN
           pn_var_rent_pkg.lock_row_exception('attribute10',Recinfo.attribute10);
        END IF;

    -----------------------------------------------------------------
    -- Call the PN_ADDRESSES lock table handler to lock the address
    -- row for update
    -----------------------------------------------------------------
    PNT_ADDR_PKG.lock_row   ( x_address_id,
                              x_address_line1,
                              x_address_line2,
                              x_address_line3,
                              x_address_line4,
                              x_county,
                              x_city,
                              x_state,
                              x_province,
                              x_zip_code,
                              x_country,
                              x_territory_id,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              x_addr_attribute_category,
                              x_addr_attribute1,
                              x_addr_attribute2,
                              x_addr_attribute3,
                              x_addr_attribute4,
                              x_addr_attribute5,
                              x_addr_attribute6,
                              x_addr_attribute7,
                              x_addr_attribute8,
                              x_addr_attribute9,
                              x_addr_attribute10,
                              x_addr_attribute11,
                              x_addr_attribute12,
                              x_addr_attribute13,
                              x_addr_attribute14,
                              x_addr_attribute15
                            );

  PNP_DEBUG_PKG.debug ('PNT_COMP_SITE_PKG.lock_row (-)');

END lock_row;

END PNT_COMP_SITE_PKG;

/
