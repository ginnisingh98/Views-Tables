--------------------------------------------------------
--  DDL for Package Body AK_UNIQUE_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_UNIQUE_KEYS_PKG" as
/* $Header: AKDOBPKB.pls 120.2 2005/09/29 13:59:56 tshort ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Unique_Key_Name               VARCHAR2,
                       X_Database_Object_Name           VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category		VARCHAR2,
		       X_Attribute1			VARCHAR2,
		       X_Attribute2			VARCHAR2,
		       X_Attribute3			VARCHAR2,
		       X_Attribute4			VARCHAR2,
		       X_Attribute5			VARCHAR2,
		       X_Attribute6			VARCHAR2,
		       X_Attribute7			VARCHAR2,
		       X_Attribute8			VARCHAR2,
		       X_Attribute9			VARCHAR2,
		       X_Attribute10			VARCHAR2,
		       X_Attribute11			VARCHAR2,
		       X_Attribute12			VARCHAR2,
		       X_Attribute13			VARCHAR2,
		       X_Attribute14			VARCHAR2,
		       X_Attribute15			VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM AK_UNIQUE_KEYS
                 WHERE unique_key_name = X_Unique_Key_Name;

   BEGIN


       INSERT INTO AK_UNIQUE_KEYS(
              unique_key_name,
              database_object_name,
              application_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
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
              X_Unique_Key_Name,
              X_Database_Object_Name,
              X_Application_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
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
                     X_Unique_Key_Name                 VARCHAR2,
                     X_Database_Object_Name                        VARCHAR2,
                     X_Application_Id                   NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AK_UNIQUE_KEYS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Unique_Key_Name NOWAIT;
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
               (Recinfo.unique_key_name =  X_Unique_Key_Name)
           AND (Recinfo.database_object_name =  X_Database_Object_Name)
           AND (Recinfo.application_id =  X_Application_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Unique_Key_Name               VARCHAR2,
                       X_Database_Object_Name                      VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category		VARCHAR2,
		       X_Attribute1			VARCHAR2,
		       X_Attribute2			VARCHAR2,
		       X_Attribute3			VARCHAR2,
		       X_Attribute4			VARCHAR2,
		       X_Attribute5			VARCHAR2,
		       X_Attribute6			VARCHAR2,
		       X_Attribute7			VARCHAR2,
		       X_Attribute8			VARCHAR2,
		       X_Attribute9			VARCHAR2,
		       X_Attribute10			VARCHAR2,
		       X_Attribute11			VARCHAR2,
		       X_Attribute12			VARCHAR2,
		       X_Attribute13			VARCHAR2,
		       X_Attribute14			VARCHAR2,
		       X_Attribute15			VARCHAR2
  ) IS
  BEGIN
    UPDATE AK_UNIQUE_KEYS
    SET
       unique_key_name                =     X_Unique_Key_Name,
       database_object_name                       =     X_Database_Object_Name,
       application_id                  =     X_Application_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute_category	       =     X_Attribute_Category,
       attribute1		       =     X_Attribute1,
       attribute2		       =     X_Attribute2,
       attribute3		       =     X_Attribute3,
       attribute4		       =     X_Attribute4,
       attribute5		       =     X_Attribute5,
       attribute6		       =     X_Attribute6,
       attribute7		       =     X_Attribute7,
       attribute8		       =     X_Attribute8,
       attribute9		       =     X_Attribute9,
       attribute10		       =     X_Attribute10,
       attribute11		       =     X_Attribute11,
       attribute12		       =     X_Attribute12,
       attribute13		       =     X_Attribute13,
       attribute14		       =     X_Attribute14,
       attribute15		       =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM AK_UNIQUE_KEYS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END AK_UNIQUE_KEYS_PKG;

/
