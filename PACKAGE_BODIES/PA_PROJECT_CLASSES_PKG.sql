--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CLASSES_PKG" as
/* $Header: PAXCLASB.pls 120.2 2005/08/19 17:11:15 mwasowic ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_object_id                      NUMBER,
                       X_object_type                    VARCHAR2,
                       X_Class_Category                 VARCHAR2,
                       X_Class_Code                     VARCHAR2,
                       X_code_percentage                NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_attribute1                     VARCHAR2,
                       X_attribute2                     VARCHAR2,
                       X_attribute3                     VARCHAR2,
                       X_attribute4                     VARCHAR2,
                       X_attribute5                     VARCHAR2,
                       X_attribute6                     VARCHAR2,
                       X_attribute7                     VARCHAR2,
                       X_attribute8                     VARCHAR2,
                       X_attribute9                     VARCHAR2,
                       X_attribute10                    VARCHAR2,
                       X_attribute11                    VARCHAR2,
                       X_attribute12                    VARCHAR2,
                       X_attribute13                    VARCHAR2,
                       X_attribute14                    VARCHAR2,
                       X_attribute15                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM PA_PROJECT_CLASSES
                 WHERE object_id = X_object_Id
                 AND   object_type = X_object_type
                 AND   class_category = X_Class_Category
                 AND   class_code = X_Class_Code;

   BEGIN

       INSERT INTO PA_PROJECT_CLASSES(
              project_id,
              object_id,
              object_type,
              class_category,
              class_code,
              code_percentage,
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
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              record_version_number
             ) VALUES (
              decode(X_object_type, 'PA_PROJECTS', X_object_id, NULL),
              X_object_id,
              X_object_type,
              X_Class_Category,
              X_Class_Code,
              X_code_percentage,
              X_attribute_category,
              X_attribute1,
              X_attribute2,
              X_attribute3,
              X_attribute4,
              X_attribute5,
              X_attribute6,
              X_attribute7,
              X_attribute8,
              X_attribute9,
              X_attribute10,
              X_attribute11,
              X_attribute12,
              X_attribute13,
              X_attribute14,
              X_attribute15,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              0
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
                     X_object_id                        NUMBER,
                     X_object_type                      VARCHAR2,
                     X_Class_Category                   VARCHAR2,
                     X_Class_Code                       VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_PROJECT_CLASSES
        WHERE  rowid = X_Rowid
        FOR UPDATE of object_Id NOWAIT;
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
               (Recinfo.object_id =  X_object_Id)
           AND (Recinfo.object_type =  X_object_type)
           AND (Recinfo.class_category =  X_Class_Category)
           AND (Recinfo.class_code =  X_Class_Code)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_object_id                      NUMBER,
                       X_object_type                    VARCHAR2,
                       X_Class_Category                 VARCHAR2,
                       X_Class_Code                     VARCHAR2,
                       X_code_percentage                NUMBER,
                       X_attribute_category             VARCHAR2,
                       X_attribute1                     VARCHAR2,
                       X_attribute2                     VARCHAR2,
                       X_attribute3                     VARCHAR2,
                       X_attribute4                     VARCHAR2,
                       X_attribute5                     VARCHAR2,
                       X_attribute6                     VARCHAR2,
                       X_attribute7                     VARCHAR2,
                       X_attribute8                     VARCHAR2,
                       X_attribute9                     VARCHAR2,
                       X_attribute10                    VARCHAR2,
                       X_attribute11                    VARCHAR2,
                       X_attribute12                    VARCHAR2,
                       X_attribute13                    VARCHAR2,
                       X_attribute14                    VARCHAR2,
                       X_attribute15                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_record_version_number          NUMBER
  ) IS
  BEGIN
    UPDATE PA_PROJECT_CLASSES
    SET
       project_id                      =     decode(X_object_type, 'PA_PROJECTS', X_object_id, NULL),
       object_id                       =     X_object_id,
       object_type                     =     X_object_type,
       class_category                  =     X_Class_Category,
       class_code                      =     X_Class_Code,
       code_percentage                 =     X_code_percentage,
       attribute_category              =     X_attribute_category,
       attribute1                      =     X_attribute1,
       attribute2                      =     X_attribute2,
       attribute3                      =     X_attribute3,
       attribute4                      =     X_attribute4,
       attribute5                      =     X_attribute5,
       attribute6                      =     X_attribute6,
       attribute7                      =     X_attribute7,
       attribute8                      =     X_attribute8,
       attribute9                      =     X_attribute9,
       attribute10                     =     X_attribute10,
       attribute11                     =     X_attribute11,
       attribute12                     =     X_attribute12,
       attribute13                     =     X_attribute13,
       attribute14                     =     X_attribute14,
       attribute15                     =     X_attribute15,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       record_version_number           =     X_record_version_number + 1
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_PROJECT_CLASSES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJECT_CLASSES_PKG;

/
