--------------------------------------------------------
--  DDL for Package Body PNT_COMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_COMP_PKG" AS
  -- $Header: PNTCOMPB.pls 120.2 2005/12/01 03:34:19 appldev ship $

/*===========================================================================+
 |
 | PROCEDURE    : check_unique_company_name
 | DESCRIPTION  : This procedure determins if the dame company_name
 |                already_exists
 | SCOPE        : PUBLIC
 | INVOKED FROM :
 | ARGUMENTS    : IN : p_rowid - rowid of row
 |                     p_company_name
 |                     p_org_id
 |                OUT: p_warning_flag  - Tells calling routine that there
 |                     is a non fatal warning on the message stack
 | RETURNS      : null
 | HISTORY
 | 16-JUN-98 NTandon   o Created
 | 13-MAY-02 DThota    o Multi-Org changes- added p_org_id parameter
+===========================================================================*/

PROCEDURE check_unique_company_name ( p_rowid        IN VARCHAR2,
                                                      p_company_name IN VARCHAR2,
                                                      p_warning_flag IN OUT NOCOPY VARCHAR2,
                                                      p_org_id       IN NUMBER
                                    ) IS
  dummy number;

BEGIN

  select 1
  into   dummy
  from   dual
  where  not exists ( select 1
                      from   pn_companies_all
                      where  name = p_company_name
                      and    (( p_rowid is null ) or (rowid <> p_rowid))
                      and    org_id = p_org_id
                     );
  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name ('PN','PN_COMP_NAME_ALREADY_EXISTS');
      p_warning_flag := 'W';

END check_unique_company_name;

/*===========================================================================+
 | PROCEDURE    : check_unique_company_number
 | DESCRIPTION  : Raises fatal error if company number is a duplicate
 | SCOPE        : PUBLIC
 | INVOKED FROM :
 | ARGUMENTS    : IN  : p_rowid - rowid of row
 |                      p_company_number
 |                      p_org_id
 |                OUT : NONE
 | RETURNS      : NONE
 | NOTES        : Use this procedure call in the
 |                PRE-QUERY, POST-QUERY, WHEN-CREATE-RECORD
 |                WHEN-NEW-RECORD-INSTANCE
 |                triggers of the block where OU is exposed
 | HISTORY
 | 16-JUN-98 NTandon  o Created
 | 13-MAY-02 DThota   o Multi-Org changes- added p_org_id parameter
 | 28-NOV-05 pikhar   o removed nvl around org_id
 +===========================================================================*/

PROCEDURE check_unique_company_number  ( p_rowid           IN VARCHAR2,
                                         p_company_number  IN VARCHAR2,
                                         p_org_id          IN NUMBER
                                       ) IS
  dummy number;

BEGIN

  SELECT 1
  INTO   dummy
  FROM   dual
  WHERE  NOT EXISTS ( SELECT 1
                      FROM   pn_companies_all
                      WHERE  company_number = p_company_number
                      AND    (( p_rowid is null ) or (rowid <> p_rowid))
                      AND    org_id = p_org_id
                    );

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name ('PN','PN_COMP_NUMBER_ALREADY_EXISTS');
      APP_EXCEPTION.raise_exception;

END check_unique_company_number;

/*===========================================================================+
| PROCEDURE    : insert_row
| DESCRIPTION  : inserts a row in pn_companies_all
| SCOPE        : PUBLIC
| INVOKED FROM :
| ARGUMENTS    : IN  : x_rowid, x_company_id, x_company_number,
|                      x_last_update_date, x_last_updated_by, x_creation_date
|                      x_created_by, x_last_update_login, x_name,
|                      x_enabled_flag, x_parent_company_id ,
|                      x_attribute_category, x_attribute1, x_attribute2,
|                      x_attribute3, x_attribute4 , x_attribute5, x_attribute6
|                      x_attribute7, x_attribute8,  x_attribute9, x_attribute10
|                      x_attribute11, x_attribute12, x_attribute13,
|                      x_attribute14, x_attribute15, x_org_id
|                OUT : NONE
| RETURNS      : NONE
| HISTORY      :
| 26-APR-05 piagrawa  o Modified the select statements to retrieve values
|                       from pn_companies_all instead of pn_companies_all
| 28-NOV-05 pikhar    o fetched org_id using cursor
+===========================================================================*/
PROCEDURE insert_row ( x_rowid                   IN OUT NOCOPY VARCHAR2,
                       x_company_id              IN OUT NOCOPY NUMBER,
                       x_company_number          IN OUT NOCOPY VARCHAR2,
                       x_last_update_date        DATE,
                       x_last_updated_by         NUMBER,
                       x_creation_date           DATE,
                       x_created_by              NUMBER,
                       x_last_update_login       NUMBER,
                       x_name                    VARCHAR2,
                       x_enabled_flag            VARCHAR2,
                       x_parent_company_id       NUMBER,
                       x_attribute_category      VARCHAR2,
                       x_attribute1              VARCHAR2,
                       x_attribute2              VARCHAR2,
                       x_attribute3              VARCHAR2,
                       x_attribute4              VARCHAR2,
                       x_attribute5              VARCHAR2,
                       x_attribute6              VARCHAR2,
                       x_attribute7              VARCHAR2,
                       x_attribute8              VARCHAR2,
                       x_attribute9              VARCHAR2,
                       x_attribute10             VARCHAR2,
                       x_attribute11             VARCHAR2,
                       x_attribute12             VARCHAR2,
                       x_attribute13             VARCHAR2,
                       x_attribute14             VARCHAR2,
                       x_attribute15             VARCHAR2,
                       x_org_id                  NUMBER
                     ) IS

  CURSOR C is
    SELECT rowid
    FROM   pn_companies_all
    WHERE  company_id = x_company_id;

BEGIN

  check_unique_company_number ( x_rowid,
                                x_company_number,
                                x_org_id
                              );
  -----------------------------------------------------------------
  -- Allocate the sequence to the primary key company_id
  -----------------------------------------------------------------
  select pn_companies_s.nextval
  into   x_company_id
  from   dual;

  IF x_company_number is null then

    select pn_companies_num_s.nextval
    into   x_company_number
    from   dual;

  END IF;

  insert into pn_companies_all (
                                 company_id,
                                 company_number,
                                 last_update_date,
                                 last_updated_by,
                                 creation_date,
                                 created_by,
                                 last_update_login,
                                 name,
                                 enabled_flag,
                                 parent_company_id,
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
  values
                           (
                             x_company_id,
                             x_company_number,
                             x_last_update_date,
                             x_last_updated_by,
                             x_creation_date,
                             x_created_by,
                             x_last_update_login,
                             x_name,
                             x_enabled_flag,
                             x_parent_company_id,
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
                             x_org_id
                           );

  OPEN C;
    FETCH C INTO x_rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
  CLOSE C;

END insert_row;

 -------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_companies with _ALL table.
--                       Also changed the where clause.
-------------------------------------------------------------------------------
PROCEDURE update_row ( x_rowid                          VARCHAR2,
                       x_company_id                     NUMBER,
                       x_company_number                 VARCHAR2,
                       x_last_update_date               DATE,
                       x_last_updated_by                NUMBER,
                       x_last_update_login              NUMBER,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_parent_company_id              NUMBER,
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
                       x_attribute15                    VARCHAR2
                     )
IS
   l_org_id  NUMBER;

BEGIN

  SELECT org_id
  INTO   l_org_id
  FROM   pn_companies_all
  WHERE  company_id            = x_company_id;

  check_unique_company_number ( x_rowid,
                                x_company_number,
                                l_org_id
                              );
  UPDATE pn_companies_all
  SET   company_number        =  x_company_number,
        last_update_date      =  x_last_update_date,
        last_updated_by       =  x_last_updated_by,
        last_update_login     =  x_last_update_login,
        name                  =  x_name,
        enabled_flag          =  x_enabled_flag,
        parent_company_id     =  x_parent_company_id,
        attribute_category    =  x_attribute_category,
        attribute1            =  x_attribute1,
        attribute2            =  x_attribute2,
        attribute3            =  x_attribute3,
        attribute4            =  x_attribute4,
        attribute5            =  x_attribute5,
        attribute6            =  x_attribute6,
        attribute7            =  x_attribute7,
        attribute8            =  x_attribute8,
        attribute9            =  x_attribute9,
        attribute10           =  x_attribute10,
        attribute11           =  x_attribute11,
        attribute12           =  x_attribute12,
        attribute13           =  x_attribute13,
        attribute14           =  x_attribute14,
        attribute15           =  x_attribute15
  WHERE company_id            = x_company_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : loacks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_companies with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE lock_row   ( x_rowid                          VARCHAR2,
                       x_company_id                     NUMBER,
                       x_company_number                 VARCHAR2,
                       x_name                           VARCHAR2,
                       x_enabled_flag                   VARCHAR2,
                       x_parent_company_id              NUMBER,
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
                       x_attribute15                    VARCHAR2
                     ) IS
   CURSOR C IS
     SELECT *
     FROM   pn_companies_all
     WHERE  rowid = x_rowid
     FOR    UPDATE OF company_id NOWAIT;

   Recinfo C%ROWTYPE;


  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

        IF NOT (Recinfo.company_id     = x_company_id) THEN
           pn_var_rent_pkg.lock_row_exception('company_id',Recinfo.company_id);
        END IF;
        IF NOT (Recinfo.company_number = x_company_number) THEN
           pn_var_rent_pkg.lock_row_exception('company_number',Recinfo.company_number);
        END IF;
        IF NOT (Recinfo.name = x_name) THEN
           pn_var_rent_pkg.lock_row_exception('name',Recinfo.name);
        END IF;
        IF NOT (Recinfo.enabled_flag = x_enabled_flag) THEN
           pn_var_rent_pkg.lock_row_exception('enabled_flag',Recinfo.enabled_flag);
        END IF;
        IF NOT ((Recinfo.parent_company_id = x_parent_company_id)
             or ((Recinfo.parent_company_id is null) and (x_parent_company_id is null))) THEN
           pn_var_rent_pkg.lock_row_exception('parent_company_id',Recinfo.parent_company_id);
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

  END lock_row;

END PNT_COMP_PKG;

/
