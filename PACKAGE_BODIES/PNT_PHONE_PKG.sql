--------------------------------------------------------
--  DDL for Package Body PNT_PHONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_PHONE_PKG" as
  -- $Header: PNTPHONB.pls 120.2 2005/12/01 08:27:13 appldev ship $


-------------------------------------------------------------------------------
--  NAME         : check_primary
--  DESCRIPTION  : This procedure ensures that there is only one primary phone
--                 for the contact.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:     p_phone_id, p_contact_id, p_org_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  16-JUN-98  Neeraj Tandon o Created
--  14-MAY-02  Daniel Thota  o added parameter p_org_id for multi-org
--  21-JUN-05  piagrawa      o Bug 4284035 - Removed nvl for org id.
-------------------------------------------------------------------------------
PROCEDURE check_primary ( p_phone_id     IN NUMBER,
                          p_contact_id  IN NUMBER,
                          p_org_id      IN NUMBER default NULL
                        )
IS
  primary_count number;
BEGIN

  SELECT  count(1)
  INTO    primary_count
  FROM    pn_phones_all ph
  WHERE   ph.contact_id    = p_contact_id
  AND     ph.primary_flag  = 'Y'
  AND     ((p_phone_id is null) or ph.phone_id <> p_phone_id )
  AND     org_id = p_org_id;

  IF ( primary_count >= 1 ) THEN
    fnd_message.set_name('PN','PN_CONT_ONE_PRIMARY_PHONE');
    APP_EXCEPTION.raise_exception;
  END IF;

END check_primary;


-------------------------------------------------------------------------------
-- PROCDURE     : Insert_Row
-- INVOKED FROM : Insert_Row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_phones with _ALL table.
--                       Also changed the where clause
-- 01-DEC-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE Insert_Row ( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Org_id                         NUMBER default NULL
                     )
IS
   CURSOR C IS
   SELECT rowid
   FROM   pn_phones_all
   WHERE  phone_id = X_Phone_Id;

   l_id   number;

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_contacts_all
    WHERE contact_id = x_contact_id;

   l_org_id NUMBER;


 BEGIN

   IF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   ELSE
     l_org_id := x_org_id;
   END IF;


   SELECT pn_phones_s.nextval
   INTO   x_phone_id
   FROM  dual;

   INSERT INTO pn_phones_all
   (
      phone_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      phone_number,
      status,
      phone_type,
      last_update_login,
      contact_id,
      area_code,
      extension,
      primary_flag,
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
      X_Phone_Id,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Phone_Number,
      X_Status,
      X_Phone_Type,
      X_Last_Update_Login,
      X_Contact_Id,
      X_Area_Code,
      X_Extension,
      X_Primary_Flag,
      X_Attribute_Category,
      X_Attribute1,
      X_Attribute2,
      X_Attribute3,
      X_Attribute4,
      X_Attribute5,
      X_Attribute6,
      X_Attribute7,
      X_Attribute8,
      X_Attribute9,
      X_Attribute10,
      X_Attribute11,
      X_Attribute12,
      X_Attribute13,
      X_Attribute14,
      X_Attribute15,
      l_Org_id
    );

   OPEN C;
   FETCH C INTO X_Rowid;
   IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE C;

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_phones with _ALL table.
--                       Also changed the where clause
-------------------------------------------------------------------------------
PROCEDURE Lock_Row ( X_Rowid                            VARCHAR2,
                     X_Phone_Number                     VARCHAR2,
                     X_Status                           VARCHAR2,
                     X_Phone_Type                       VARCHAR2,
                     X_Area_Code                        VARCHAR2,
                     X_Extension                        VARCHAR2,
                     X_Primary_Flag                     VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                   ) IS
  CURSOR C IS
      SELECT *
      FROM   pn_phones_all
      WHERE  rowid = X_Rowid
      FOR UPDATE of Phone_Id NOWAIT;
  Recinfo C%ROWTYPE;


BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  end if;
  CLOSE C;

         IF NOT   (Recinfo.phone_number =  X_Phone_Number) THEN
            pn_var_rent_pkg.lock_row_exception('phone_number',Recinfo.phone_number);
         END IF;
         IF NOT (Recinfo.status =  X_Status) THEN
            pn_var_rent_pkg.lock_row_exception('status',Recinfo.status);
         END IF;
         IF NOT (Recinfo.phone_type =  X_Phone_Type) THEN
            pn_var_rent_pkg.lock_row_exception('phone_type',Recinfo.phone_type);
         END IF;
         IF NOT (   (Recinfo.area_code =  X_Area_Code)
              OR ((Recinfo.area_code IS NULL) AND (X_Area_Code IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('area_code',Recinfo.area_code);
         END IF;
         IF NOT (   (Recinfo.extension =  X_Extension)
              OR ((Recinfo.extension IS NULL) AND (X_Extension IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('extension',Recinfo.extension);
         END IF;
         IF NOT (   (Recinfo.primary_flag =  X_Primary_Flag)
              OR ((Recinfo.primary_flag IS NULL) AND (X_Primary_Flag IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('primary_flag',Recinfo.primary_flag);
         END IF;
         IF NOT (   (Recinfo.attribute_category =  X_Attribute_Category)
              OR ((Recinfo.attribute_category IS NULL) AND (X_Attribute_Category IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute_category',Recinfo.attribute_category);
         END IF;
         IF NOT (   (Recinfo.attribute1 =  X_Attribute1)
              OR ((Recinfo.attribute1 IS NULL) AND (X_Attribute1 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute1',Recinfo.attribute1);
         END IF;
         IF NOT (   (Recinfo.attribute2 =  X_Attribute2)
              OR ((Recinfo.attribute2 IS NULL) AND (X_Attribute2 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute2',Recinfo.attribute2);
         END IF;
         IF NOT (   (Recinfo.attribute3 =  X_Attribute3)
              OR ((Recinfo.attribute3 IS NULL) AND (X_Attribute3 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute3',Recinfo.attribute3);
         END IF;
         IF NOT (   (Recinfo.attribute4 =  X_Attribute4)
              OR ((Recinfo.attribute4 IS NULL) AND (X_Attribute4 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute4',Recinfo.attribute4);
         END IF;
         IF NOT (   (Recinfo.attribute5 =  X_Attribute5)
              OR ((Recinfo.attribute5 IS NULL) AND (X_Attribute5 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute5',Recinfo.attribute5);
         END IF;
         IF NOT (   (Recinfo.attribute6 =  X_Attribute6)
              OR ((Recinfo.attribute6 IS NULL) AND (X_Attribute6 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute6',Recinfo.attribute6);
         END IF;
         IF NOT (   (Recinfo.attribute7 =  X_Attribute7)
              OR ((Recinfo.attribute7 IS NULL) AND (X_Attribute7 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute7',Recinfo.attribute7);
         END IF;
         IF NOT (   (Recinfo.attribute8 =  X_Attribute8)
              OR ((Recinfo.attribute8 IS NULL) AND (X_Attribute8 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute8',Recinfo.attribute8);
         END IF;
         IF NOT (   (Recinfo.attribute9 =  X_Attribute9)
              OR ((Recinfo.attribute9 IS NULL) AND (X_Attribute9 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute9',Recinfo.attribute9);
         END IF;
         IF NOT (   (Recinfo.attribute10 =  X_Attribute10)
              OR ((Recinfo.attribute10 IS NULL) AND (X_Attribute10 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute10',Recinfo.attribute10);
         END IF;
         IF NOT (   (Recinfo.attribute11 =  X_Attribute11)
              OR ((Recinfo.attribute11 IS NULL) AND (X_Attribute11 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute11',Recinfo.attribute11);
         END IF;
         IF NOT (   (Recinfo.attribute12 =  X_Attribute12)
              OR ((Recinfo.attribute12 IS NULL) AND (X_Attribute12 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute12',Recinfo.attribute12);
         END IF;
         IF NOT (   (Recinfo.attribute13 =  X_Attribute13)
              OR ((Recinfo.attribute13 IS NULL) AND (X_Attribute13 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute13',Recinfo.attribute13);
         END IF;
         IF NOT (   (Recinfo.attribute14 =  X_Attribute14)
              OR ((Recinfo.attribute14 IS NULL) AND (X_Attribute14 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute14',Recinfo.attribute14);
         END IF;
         IF NOT (   (Recinfo.attribute15 =  X_Attribute15)
              OR ((Recinfo.attribute15 IS NULL) AND (X_Attribute15 IS NULL))) THEN
            pn_var_rent_pkg.lock_row_exception('attribute15',Recinfo.attribute15);
         END IF;

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_phones with _ALL table.
--                       Also changed the where clause
-------------------------------------------------------------------------------
PROCEDURE Update_Row ( X_Rowid                          VARCHAR2,
                            X_phone_id                                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Contact_Id                     NUMBER,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                     ) IS
  l_id NUMBER;

BEGIN
  --
  --
  UPDATE pn_phones_all
  SET
     last_update_date                =     X_Last_Update_Date,
     last_updated_by                 =     X_Last_Updated_By,
     phone_number                    =     X_Phone_Number,
     status                          =     X_Status,
     phone_type                      =     X_Phone_Type,
     last_update_login               =     X_Last_Update_Login,
     area_code                       =     X_Area_Code,
     extension                       =     X_Extension,
     primary_flag                    =     X_Primary_Flag,
     attribute_category              =     X_Attribute_Category,
     attribute1                      =     X_Attribute1,
     attribute2                      =     X_Attribute2,
     attribute3                      =     X_Attribute3,
     attribute4                      =     X_Attribute4,
     attribute5                      =     X_Attribute5,
     attribute6                      =     X_Attribute6,
     attribute7                      =     X_Attribute7,
     attribute8                      =     X_Attribute8,
     attribute9                      =     X_Attribute9,
     attribute10                     =     X_Attribute10,
     attribute11                     =     X_Attribute11,
     attribute12                     =     X_Attribute12,
     attribute13                     =     X_Attribute13,
     attribute14                     =     X_Attribute14,
     attribute15                     =     X_Attribute15
  WHERE phone_id = X_phone_id;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Update_Row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced pn_phones with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row ( x_rowid   VARCHAR2)
IS
BEGIN

   DELETE FROM pn_phones_all
   WHERE  rowid = x_rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overloaded this procedure to take PK as In parameter
-- HISTORY      :
-- 04-JUL-05  piagrawa   o Bug 4284035 - Created
-------------------------------------------------------------------------------
PROCEDURE delete_row (x_phone_id IN NUMBER)
IS
BEGIN

   DELETE FROM pn_phones_all
   WHERE phone_id = x_phone_id;

   IF (SQL%NOTFOUND)
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

END delete_row;

END PNT_PHONE_PKG;

/
