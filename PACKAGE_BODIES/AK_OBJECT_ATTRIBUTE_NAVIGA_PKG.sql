--------------------------------------------------------
--  DDL for Package Body AK_OBJECT_ATTRIBUTE_NAVIGA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECT_ATTRIBUTE_NAVIGA_PKG" as
/* $Header: AKDOANAB.pls 115.2 99/07/17 15:16:17 porting s $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,

                       X_Database_Object_Name           VARCHAR2,
                       X_Attribute_Application_Id       NUMBER,
                       X_Attribute_Code                 VARCHAR2,
                       X_Value_Varchar2                 VARCHAR2,
                       X_Value_Date                     DATE,
                       X_Value_Number                   NUMBER,
                       X_To_Region_Appl_Id              NUMBER,
                       X_To_Region_Code                 VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
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
    CURSOR C IS SELECT rowid FROM AK_OBJECT_ATTRIBUTE_NAVIGATION
                 WHERE database_object_name = X_Database_Object_Name
                 AND   attribute_application_id = X_Attribute_Application_Id
                 AND   attribute_code = X_Attribute_Code;

   BEGIN


       INSERT INTO AK_OBJECT_ATTRIBUTE_NAVIGATION(

              database_object_name,
              attribute_application_id,
              attribute_code,
              value_varchar2,
              value_date,
              value_number,
              to_region_appl_id,
              to_region_code,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              Attribute_Category,
              Attribute1,
              Attribute2,
              Attribute3,
              Attribute4,
              Attribute5,
              Attribute6,
              Attribute7,
              Attribute8,
              Attribute9,
              Attribute10,
              Attribute11,
              Attribute12,
              Attribute13,
              Attribute14,
              Attribute15
             ) VALUES (

              X_Database_Object_Name,
              X_Attribute_Application_Id,
              X_Attribute_Code,
              X_Value_Varchar2,
              X_Value_Date,
              X_Value_Number,
              X_To_Region_Appl_Id,
              X_To_Region_Code,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Date,
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

                     X_Database_Object_Name             VARCHAR2,
                     X_Attribute_Application_Id         NUMBER,
                     X_Attribute_Code                   VARCHAR2,
                     X_Value_Varchar2                   VARCHAR2,
                     X_Value_Date                       DATE,
                     X_Value_Number                     NUMBER,
                     X_To_Region_Appl_Id                NUMBER,
                     X_To_Region_Code                   VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AK_OBJECT_ATTRIBUTE_NAVIGATION
        WHERE  rowid = X_Rowid
        FOR UPDATE of Database_Object_Name NOWAIT;
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

               (Recinfo.database_object_name =  X_Database_Object_Name)
           AND (Recinfo.attribute_application_id =  X_Attribute_Application_Id)
           AND (Recinfo.attribute_code =  X_Attribute_Code)
           AND (   (Recinfo.value_varchar2 =  X_Value_Varchar2)
                OR (    (Recinfo.value_varchar2 IS NULL)
                    AND (X_Value_Varchar2 IS NULL)))
           AND (   (Recinfo.value_date =  X_Value_Date)
                OR (    (Recinfo.value_date IS NULL)
                    AND (X_Value_Date IS NULL)))
           AND (   (Recinfo.value_number =  X_Value_Number)
                OR (    (Recinfo.value_number IS NULL)
                    AND (X_Value_Number IS NULL)))
           AND (Recinfo.to_region_appl_id =  X_To_Region_Appl_Id)
           AND (Recinfo.to_region_code =  X_To_Region_Code)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Database_Object_Name           VARCHAR2,
                       X_Attribute_Application_Id       NUMBER,
                       X_Attribute_Code                 VARCHAR2,
                       X_Value_Varchar2                 VARCHAR2,
                       X_Value_Date                     DATE,
                       X_Value_Number                   NUMBER,
                       X_To_Region_Appl_Id              NUMBER,
                       X_To_Region_Code                 VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
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
    UPDATE AK_OBJECT_ATTRIBUTE_NAVIGATION
    SET
       database_object_name            =     X_Database_Object_Name,
       attribute_application_id        =     X_Attribute_Application_Id,
       attribute_code                  =     X_Attribute_Code,
       value_varchar2                  =     X_Value_Varchar2,
       value_date                      =     X_Value_Date,
       value_number                    =     X_Value_Number,
       to_region_appl_id               =     X_To_Region_Appl_Id,
       to_region_code                  =     X_To_Region_Code,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       last_update_login               =     X_Last_Update_Login,
       Attribute_Category	       =     X_Attribute_Category,
       Attribute1		       =     X_Attribute1,
       Attribute2		       =     X_Attribute2,
       Attribute3		       =     X_Attribute3,
       Attribute4		       =     X_Attribute4,
       Attribute5		       =     X_Attribute5,
       Attribute6		       =     X_Attribute6,
       Attribute7		       =     X_Attribute7,
       Attribute8		       =     X_Attribute8,
       Attribute9		       =     X_Attribute9,
       Attribute10		       =     X_Attribute10,
       Attribute11		       =     X_Attribute11,
       Attribute12		       =     X_Attribute12,
       Attribute13		       =     X_Attribute13,
       Attribute14		       =     X_Attribute14,
       Attribute15		       =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM AK_OBJECT_ATTRIBUTE_NAVIGATION
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END AK_OBJECT_ATTRIBUTE_NAVIGA_PKG;

/
