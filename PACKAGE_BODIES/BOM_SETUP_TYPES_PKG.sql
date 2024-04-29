--------------------------------------------------------
--  DDL for Package Body BOM_SETUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SETUP_TYPES_PKG" as
/* $Header: bompstpb.pls 120.1 2005/06/21 03:25:56 appldev ship $ */

PROCEDURE Insert_Row(X_Rowid			      IN OUT NOCOPY VARCHAR2,
                     X_Setup_ID		 	      IN OUT NOCOPY NUMBER,
                     X_Setup_Code		      VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL
   ) IS

  CURSOR C IS SELECT rowid FROM BOM_SETUP_TYPES
              WHERE setup_id = x_setup_id;
  CURSOR C2 IS SELECT bom_setup_types_s.nextval FROM sys.dual;

BEGIN
  if (x_setup_id is NULL) then
    OPEN C2;
    FETCH C2 INTO x_setup_id;
    CLOSE C2;
  end if;
  INSERT INTO BOM_SETUP_TYPES(
               setup_id,
               setup_code,
               organization_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               description,
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
               attribute15
             ) VALUES (
               X_Setup_Id,
               X_Setup_Code,
               X_Organization_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Description,
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
               X_Attribute15
             );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    Raise NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;



PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                   X_Setup_Id		 	      NUMBER,
                   X_Setup_Code		              VARCHAR2,
                   X_Organization_Id                  NUMBER,
                   X_Description                      VARCHAR2 DEFAULT NULL,
                   X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                   X_Attribute1                       VARCHAR2 DEFAULT NULL,
                   X_Attribute2                       VARCHAR2 DEFAULT NULL,
                   X_Attribute3                       VARCHAR2 DEFAULT NULL,
                   X_Attribute4                       VARCHAR2 DEFAULT NULL,
                   X_Attribute5                       VARCHAR2 DEFAULT NULL,
                   X_Attribute6                       VARCHAR2 DEFAULT NULL,
                   X_Attribute7                       VARCHAR2 DEFAULT NULL,
                   X_Attribute8                       VARCHAR2 DEFAULT NULL,
                   X_Attribute9                       VARCHAR2 DEFAULT NULL,
                   X_Attribute10                      VARCHAR2 DEFAULT NULL,
                   X_Attribute11                      VARCHAR2 DEFAULT NULL,
                   X_Attribute12                      VARCHAR2 DEFAULT NULL,
                   X_Attribute13                      VARCHAR2 DEFAULT NULL,
                   X_Attribute14                      VARCHAR2 DEFAULT NULL,
                   X_Attribute15                      VARCHAR2 DEFAULT NULL
  ) IS
  CURSOR C IS SELECT * FROM BOM_SETUP_TYPES
              WHERE  rowid = X_Rowid FOR UPDATE of Setup_Id NOWAIT;
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

  if (
           (Recinfo.setup_id = X_Setup_Id)
       AND (Recinfo.setup_code = X_Setup_Code)
       AND (Recinfo.organization_id = X_Organization_Id)
       AND (   (Recinfo.description = X_Description)
            OR (    (Recinfo.description IS NULL)
                AND (X_Description IS NULL)))
       AND (   (Recinfo.attribute_category = X_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (X_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 = X_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (X_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 = X_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (X_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 = X_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (X_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 = X_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (X_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 = X_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (X_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 = X_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (X_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 = X_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (X_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 = X_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (X_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 = X_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (X_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 = X_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (X_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 = X_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (X_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 = X_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (X_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 = X_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (X_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 = X_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 = X_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
        ) then
  return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Setup_ID		 	      NUMBER,
                     X_Setup_Code		      VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER   DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL
 ) IS
BEGIN
  UPDATE BOM_SETUP_TYPES
  SET
     setup_id		               =     X_Setup_Id,
     setup_code                        =     X_Setup_Code,
     organization_id                   =     X_Organization_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     description                       =     X_Description,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
  end if;
END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM BOM_SETUP_TYPES
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;


PROCEDURE Check_Unique(X_Organization_Id NUMBER,
		       X_Setup_Code 	 VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_SETUP_TYPES
     WHERE Organization_Id = X_Organization_Id
       AND Setup_Code = X_Setup_Code
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('ENTITY1', to_char(x_organization_id), TRUE);
      FND_MESSAGE.SET_TOKEN('ENTITY2', x_setup_code, TRUE);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;



/* GRANT EXECUTE ON BOM_SETUP_TYPES_PKG TO MFG; */



END BOM_SETUP_TYPES_PKG;

/
