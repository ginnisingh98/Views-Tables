--------------------------------------------------------
--  DDL for Package Body PNT_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_ADDR_PKG" AS
  -- $Header: PNTADDRB.pls 120.2 2005/08/02 06:18:06 appldev ship $

/*=============================================================================+
 | PROCEDURE    : INSERT_row
 | DESCRIPTION  : INSERTs a row in pn_addresses_all
 | SCOPE        : PUBLIC
 | INVOKED FROM :
 | ARGUMENTS    : IN  : x_address_id, x_address_line1, x_address_line2,
 |                      x_address_line3, x_address_line4, x_county, x_city,
 |                      x_state, x_province, x_zip_code, x_country
 |                      x_territORy_id, x_lASt_UPDATE_date
 |                      x_lASt_UPDATEd_by, x_creation_date
 |                      x_created_by, x_lASt_UPDATE_login
 |                      x_attribute_categORy, x_attribute1, x_attribute2,
 |                      x_attribute3, x_attribute4 , x_attribute5, x_attribute6
 |                      x_attribute7, x_attribute8,  x_attribute9, x_attribute10
 |                      x_attribute11, x_attribute12, x_attribute13,
 |                      x_attribute14, x_attribute15,x_addr_attribute_categORy,
 |                      x_addr_attribute1,x_addr_attribute2, x_addr_attribute3,
 |                      x_addr_attribute4, x_addr_attribute5, x_addr_attribute6,
 |                      x_addr_attribute7, x_addr_attribute8, x_addr_attribute9,
 |                      x_addr_attribute10, x_addr_attribute11, x_addr_attribute12,
 |                      x_addr_attribute13, x_addr_attribute14, x_addr_attribute15
 |                      AND x_ORg_id
 |                OUT : NONE
 | RETURNS      : NONE
 | HISTORY      :
 | 28-APR-05    : piagrawa  o ModIFied the SELECT statements to retrieve VALUES
 |                            FROM pn_addresses_all instead of pn_addresses
 +=============================================================================*/
PROCEDURE INSERT_row ( x_address_id              IN OUT NOCOPY NUMBER,
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
                       x_territORy_id                   NUMBER,
                       x_lASt_UPDATE_date               DATE,
                       x_lASt_UPDATEd_by                NUMBER,
                       x_creation_date                  DATE,
                       x_created_by                     NUMBER,
                       x_lASt_UPDATE_login              NUMBER,
                       x_attribute_categORy             VARCHAR2,
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
                       x_addr_attribute_categORy        VARCHAR2,
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
                       x_ORg_id                         NUMBER
                     ) IS
  CURSOR ADDR IS
    SELECT address_id
    FROM   pn_addresses_all
    WHERE  address_id = x_address_id;

BEGIN

  -----------------------------------------------------------------
  -- Allocate the sequence to the primary key address_id
  -----------------------------------------------------------------
  SELECT pn_addresses_s.nextval
  INTO   x_address_id
  FROM   dual;

  INSERT INTO pn_addresses_all ( address_id,
                             address_line1,
                             address_line2,
                             address_line3,
                             address_line4,
                             county,
                             city,
                             state,
                             province,
                             zip_code,
                             country,
                             territORy_id,
                             lASt_UPDATE_date,
                             lASt_UPDATEd_by,
                             creation_date,
                             created_by,
                             lASt_UPDATE_login,
                             attribute_categORy,
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
                             addr_attribute_categORy,
                             addr_attribute1,
                             addr_attribute2,
                             addr_attribute3,
                             addr_attribute4,
                             addr_attribute5,
                             addr_attribute6,
                             addr_attribute7,
                             addr_attribute8,
                             addr_attribute9,
                             addr_attribute10,
                             addr_attribute11,
                             addr_attribute12,
                             addr_attribute13,
                             addr_attribute14,
                             addr_attribute15,
                             ORg_id
                           )
  VALUES
                           (
                             x_address_id,
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
                             x_territORy_id,
                             x_lASt_UPDATE_date,
                             x_lASt_UPDATEd_by,
                             x_creation_date,
                             x_created_by,
                             x_lASt_UPDATE_login,
                             x_attribute_categORy,
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
                             x_addr_attribute_categORy,
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
                             x_ORg_id
                           );

  OPEN ADDR;
    FETCH ADDR INTO x_address_id;
    IF (ADDR%NOTFOUND) THEN
      CLOSE ADDR;
      RAISE NO_DATA_FOUND;
    END IF;
  CLOSE ADDR;

END INSERT_row;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_row
-- INVOKED FROM : UPDATE_row procedure
-- PURPOSE      : UPDATEs the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_addresses with _ALL table
-------------------------------------------------------------------------------
PROCEDURE UPDATE_row ( x_address_id                     NUMBER,
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
                       x_territORy_id                   NUMBER,
                       x_lASt_UPDATE_date               DATE,
                       x_lASt_UPDATEd_by                NUMBER,
                       x_lASt_UPDATE_login              NUMBER,
                       x_attribute_categORy             VARCHAR2,
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
                       x_addr_attribute_categORy        VARCHAR2,
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

  UPDATE pn_addresses_all    /* hrodda_MOAC - changed to tablename_all*/
  SET
        address_line1             = x_address_line1,
        address_line2             = x_address_line2,
        address_line3             = x_address_line3,
        address_line4             = x_address_line4,
        county                    = x_county,
        city                      = x_city,
        state                     = x_state,
        province                  = x_province,
        zip_code                  = x_zip_code,
        country                   = x_country,
        territORy_id              = x_territORy_id,
        lASt_UPDATE_date          = x_lASt_UPDATE_date,
        lASt_UPDATEd_by           = x_lASt_UPDATEd_by,
        lASt_UPDATE_login         = x_lASt_UPDATE_login,
        attribute_categORy        = x_attribute_categORy,
        attribute1                = x_attribute1,
        attribute2                = x_attribute2,
        attribute3                = x_attribute3,
        attribute4                = x_attribute4,
        attribute5                = x_attribute5,
        attribute6                = x_attribute6,
        attribute7                = x_attribute7,
        attribute8                = x_attribute8,
        attribute9                = x_attribute9,
        attribute10               = x_attribute10,
        attribute11               = x_attribute11,
        attribute12               = x_attribute12,
        attribute13               = x_attribute13,
        attribute14               = x_attribute14,
        attribute15               = x_attribute15,
        addr_attribute_categORy   = x_addr_attribute_categORy,
        addr_attribute1           = x_addr_attribute1,
        addr_attribute2           = x_addr_attribute2,
        addr_attribute3           = x_addr_attribute3,
        addr_attribute4           = x_addr_attribute4,
        addr_attribute5           = x_addr_attribute5,
        addr_attribute6           = x_addr_attribute6,
        addr_attribute7           = x_addr_attribute7,
        addr_attribute8           = x_addr_attribute8,
        addr_attribute9           = x_addr_attribute9,
        addr_attribute10          = x_addr_attribute10,
        addr_attribute11          = x_addr_attribute11,
        addr_attribute12          = x_addr_attribute12,
        addr_attribute13          = x_addr_attribute13,
        addr_attribute14          = x_addr_attribute14,
        addr_attribute15          = x_addr_attribute15
  WHERE address_id           = x_address_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_row;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_addresses with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE lock_row   ( x_address_id                     NUMBER,
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
                       x_territORy_id                   NUMBER,
                       x_attribute_categORy             VARCHAR2,
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
                       x_addr_attribute_categORy        VARCHAR2,
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
   CURSOR ADDR IS
     SELECT *
     FROM   pn_addresses_all    /* hrodda_MOAC -changed to tablename_All*/
     WHERE  address_id = x_address_id
     FOR    UPDATE of address_id NOWAIT;

   Recinfo ADDR%ROWTYPE;

BEGIN

    OPEN ADDR;
    FETCH ADDR INTO Recinfo;
    IF (ADDR%NOTFOUND) THEN
      CLOSE ADDR;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RaISe_Exception;
    END IF;
    CLOSE ADDR;

           IF NOT (Recinfo.address_id =  x_Address_Id) THEN
              pn_var_rent_pkg.lock_row_exception('address_id',Recinfo.address_id);
           END IF;
           IF NOT (Recinfo.country =  x_Country) THEN
              pn_var_rent_pkg.lock_row_exception('country',Recinfo.country);
           END IF;
           IF NOT ((Recinfo.address_line1 =  x_address_line1)
                OR ((Recinfo.address_line1 IS null) AND (x_address_line1 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('address_line1',Recinfo.address_line1);
           END IF;
           IF NOT (   (Recinfo.address_line2 =  x_address_line2)
                OR ((Recinfo.address_line2 IS null) AND (x_address_line2 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('address_line2',Recinfo.address_line2);
           END IF;
           IF NOT (   (Recinfo.address_line3 =  x_address_line3)
                OR ((Recinfo.address_line3 IS null) AND (x_address_line3 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('address_line3',Recinfo.address_line3);
           END IF;
           IF NOT (   (Recinfo.address_line4 =  x_address_line4)
                OR ((Recinfo.address_line4 IS null) AND (x_address_line4 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('address_line4',Recinfo.address_line4);
           END IF;
           IF NOT (   (Recinfo.city =  x_City)
                OR ((Recinfo.city IS null) AND (x_City IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('city',Recinfo.city);
           END IF;
           IF NOT (   (Recinfo.zip_code =  x_zip_code)
                OR ((Recinfo.zip_code IS null) AND (x_zip_code IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('zip_code',Recinfo.zip_code);
           END IF;
           IF NOT (   (Recinfo.state =  x_State)
                OR ((Recinfo.state IS null) AND (x_State IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('state',Recinfo.state);
           END IF;
           IF NOT (   (Recinfo.province =  x_Province)
                OR ((Recinfo.province IS null) AND (x_Province IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('province',Recinfo.province);
           END IF;
           IF NOT (   (Recinfo.county =  x_County)
                OR ((Recinfo.county IS null) AND (x_County IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('county',Recinfo.county);
           END IF;
           IF NOT (   (Recinfo.territORy_id =  x_TerritORy_Id)
                OR ((Recinfo.territORy_id IS null) AND (x_TerritORy_Id IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('territORy_id',Recinfo.territORy_id);
           END IF;
           IF NOT (   (Recinfo.attribute_categORy =  x_Attribute_CategORy)
                OR ((Recinfo.attribute_categORy IS null) AND (x_Attribute_CategORy IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute_categORy',Recinfo.attribute_categORy);
           END IF;
           IF NOT (   (Recinfo.attribute1 =  x_Attribute1)
                OR ((Recinfo.attribute1 IS null) AND (x_Attribute1 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute1',Recinfo.attribute1);
           END IF;
           IF NOT (   (Recinfo.attribute2 =  x_Attribute2)
                OR ((Recinfo.attribute2 IS null) AND (x_Attribute2 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute2',Recinfo.attribute2);
           END IF;
           IF NOT (   (Recinfo.attribute3 =  x_Attribute3)
                OR ((Recinfo.attribute3 IS null) AND (x_Attribute3 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute3',Recinfo.attribute3);
           END IF;
           IF NOT (   (Recinfo.attribute4 =  x_Attribute4)
                OR ((Recinfo.attribute4 IS null) AND (x_Attribute4 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute4',Recinfo.attribute4);
           END IF;
           IF NOT (   (Recinfo.attribute5 =  x_Attribute5)
                OR ((Recinfo.attribute5 IS null) AND (x_Attribute5 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute5',Recinfo.attribute5);
           END IF;
           IF NOT (   (Recinfo.attribute6 =  x_Attribute6)
                OR ((Recinfo.attribute6 IS null) AND (x_Attribute6 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute6',Recinfo.attribute6);
           END IF;
           IF NOT (   (Recinfo.attribute7 =  x_Attribute7)
                OR ((Recinfo.attribute7 IS null) AND (x_Attribute7 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute7',Recinfo.attribute7);
           END IF;
           IF NOT (   (Recinfo.attribute8 =  x_Attribute8)
                OR ((Recinfo.attribute8 IS null) AND (x_Attribute8 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute8',Recinfo.attribute8);
           END IF;
           IF NOT (   (Recinfo.attribute9 =  x_Attribute9)
                OR ((Recinfo.attribute9 IS null) AND (x_Attribute9 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute9',Recinfo.attribute9);
           END IF;
           IF NOT (   (Recinfo.attribute10 =  x_Attribute10)
                OR ((Recinfo.attribute10 IS null) AND (x_Attribute10 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute10',Recinfo.attribute10);
           END IF;
           IF NOT (   (Recinfo.attribute11 =  x_Attribute11)
                OR ((Recinfo.attribute11 IS null) AND (x_Attribute11 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute11',Recinfo.attribute11);
           END IF;
           IF NOT (   (Recinfo.attribute12 =  x_Attribute12)
                OR ((Recinfo.attribute12 IS null) AND (x_Attribute12 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute12',Recinfo.attribute12);
           END IF;
           IF NOT (   (Recinfo.attribute13 =  x_Attribute13)
                OR ((Recinfo.attribute13 IS null) AND (x_Attribute13 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute13',Recinfo.attribute13);
           END IF;
           IF NOT (   (Recinfo.attribute14 =  x_Attribute14)
                OR ((Recinfo.attribute14 IS null) AND (x_Attribute14 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute14',Recinfo.attribute14);
           END IF;
           IF NOT (   (Recinfo.attribute15 =  x_Attribute15)
                OR ((Recinfo.attribute15 IS null) AND (x_Attribute15 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('attribute15',Recinfo.attribute15);
           END IF;
           IF NOT (   (Recinfo.addr_attribute_categORy =  x_addr_Attribute_CategORy)
                OR ((Recinfo.addr_attribute_categORy IS null) AND (x_addr_Attribute_CategORy IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute_categORy',Recinfo.addr_attribute_categORy);
           END IF;
           IF NOT (   (Recinfo.addr_attribute1 =  x_addr_Attribute1)
                OR ((Recinfo.addr_attribute1 IS null) AND (x_addr_Attribute1 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute1',Recinfo.addr_attribute1);
           END IF;
           IF NOT (   (Recinfo.addr_attribute2 =  x_addr_Attribute2)
                OR ((Recinfo.addr_attribute2 IS null) AND (x_addr_Attribute2 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute2',Recinfo.addr_attribute2);
           END IF;
           IF NOT (   (Recinfo.addr_attribute3 =  x_addr_Attribute3)
                OR ((Recinfo.addr_attribute3 IS null) AND (x_addr_Attribute3 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute3',Recinfo.addr_attribute3);
           END IF;
           IF NOT (   (Recinfo.addr_attribute4 =  x_addr_Attribute4)
                OR ((Recinfo.addr_attribute4 IS null) AND (x_addr_Attribute4 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute4',Recinfo.addr_attribute4);
           END IF;
           IF NOT (   (Recinfo.addr_attribute5 =  x_addr_Attribute5)
                OR ((Recinfo.addr_attribute5 IS null) AND (x_addr_Attribute5 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute5',Recinfo.addr_attribute5);
           END IF;
           IF NOT (   (Recinfo.addr_attribute6 =  x_addr_Attribute6)
                OR ((Recinfo.addr_attribute6 IS null) AND (x_addr_Attribute6 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute6',Recinfo.addr_attribute6);
           END IF;
           IF NOT (   (Recinfo.addr_attribute7 =  x_addr_Attribute7)
                OR ((Recinfo.addr_attribute7 IS null) AND (x_addr_Attribute7 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute7',Recinfo.addr_attribute7);
           END IF;
           IF NOT (   (Recinfo.addr_attribute8 =  x_addr_Attribute8)
                OR ((Recinfo.addr_attribute8 IS null) AND (x_addr_Attribute8 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute8',Recinfo.addr_attribute8);
           END IF;
           IF NOT (   (Recinfo.addr_attribute9 =  x_addr_Attribute9)
                OR ((Recinfo.addr_attribute9 IS null) AND (x_addr_Attribute9 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute9',Recinfo.addr_attribute9);
           END IF;
           IF NOT (   (Recinfo.addr_attribute10 =  x_addr_Attribute10)
                OR ((Recinfo.addr_attribute10 IS null) AND (x_addr_Attribute10 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute10',Recinfo.addr_attribute10);
           END IF;
           IF NOT (   (Recinfo.addr_attribute11 =  x_addr_Attribute11)
                OR ((Recinfo.addr_attribute11 IS null) AND (x_addr_Attribute11 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute11',Recinfo.addr_attribute11);
           END IF;
           IF NOT (   (Recinfo.addr_attribute12 =  x_addr_Attribute12)
                OR ((Recinfo.addr_attribute12 IS null) AND (x_addr_Attribute12 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute12',Recinfo.addr_attribute12);
           END IF;
           IF NOT (   (Recinfo.addr_attribute13 =  x_addr_Attribute13)
                OR ((Recinfo.addr_attribute13 IS null) AND (x_addr_Attribute13 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute13',Recinfo.addr_attribute13);
           END IF;
           IF NOT (   (Recinfo.addr_attribute14 =  x_addr_Attribute14)
                OR ((Recinfo.addr_attribute14 IS null) AND (x_addr_Attribute14 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute14',Recinfo.addr_attribute14);
           END IF;
           IF NOT (   (Recinfo.addr_attribute15 =  x_addr_Attribute15)
                OR ((Recinfo.addr_attribute15 IS null) AND (x_addr_Attribute15 IS null))) THEN
              pn_var_rent_pkg.lock_row_exception('addr_attribute15',Recinfo.addr_attribute15);
           END IF;

END lock_row;

END PNT_ADDR_PKG;

/
