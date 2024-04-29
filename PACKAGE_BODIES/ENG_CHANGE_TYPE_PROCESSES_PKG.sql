--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_TYPE_PROCESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_TYPE_PROCESSES_PKG" as
/* $Header: engpectb.pls 120.0 2005/05/26 18:40:44 appldev noship $ */

  PROCEDURE Check_Unique(X_Rowid varchar2,
 			 X_change_order_type_id number,
			 X_Eng_Change_Priority_Code varchar2,
			 X_Organization_Id number) IS
    Dummy	NUMBER;
  BEGIN
   select count(1)
   into	  dummy
   from   eng_change_order_types ecot,
   	  eng_change_type_processes ectp,
	  eng_change_priorities ecp
   where  ecot.change_order_type_id = X_change_order_type_id
   and    ecot.change_order_type_id = ectp.change_order_type_id
   and    ectp.organization_id = X_Organization_Id
   and    ecp.eng_change_priority_code = X_Eng_Change_Priority_Code
   and    ectp.eng_change_priority_code = ecp.eng_change_priority_code
   and    ectp.organization_id = ecp.organization_id
   and    ((X_rowid is null) or (ecp.rowid <> X_rowid));

   if (dummy >=1) then
        FND_MESSAGE.SET_NAME('INV', 'INV_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ENTITY', X_Eng_Change_Priority_Code);
        APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
  END Check_Unique;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT  NOCOPY  VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Eng_Change_Priority_Code       VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Process_Name                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
    CURSOR C IS SELECT rowid FROM ENG_CHANGE_TYPE_PROCESSES
                 WHERE change_order_type_id = X_Change_Order_Type_Id
                 AND   (    (eng_change_priority_code = X_Eng_Change_Priority_Code)
                        or (eng_change_priority_code is NULL and X_Eng_Change_Priority_Code is NULL))
                 AND   (    (organization_id = X_Organization_Id)
                        or (organization_id is NULL and X_Organization_Id is NULL));

   BEGIN


       INSERT INTO ENG_CHANGE_TYPE_PROCESSES(
              change_order_type_id,
              eng_change_priority_code,
              organization_id,
              process_name,
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
              X_Change_Order_Type_Id,
              X_Eng_Change_Priority_Code,
              X_Organization_Id,
              X_Process_Name,
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
                     X_Change_Order_Type_Id             NUMBER,
                     X_Eng_Change_Priority_Code         VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Process_Name                     VARCHAR2,
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
        FROM   ENG_CHANGE_TYPE_PROCESSES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Change_Order_Type_Id NOWAIT;
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

               (   (Recinfo.change_order_type_id =  X_Change_Order_Type_Id)
                OR (    (Recinfo.change_order_type_id IS NULL)
                    AND (X_Change_Order_Type_Id IS NULL)))
           AND (   (Recinfo.eng_change_priority_code =  X_Eng_Change_Priority_Code)
                OR (    (Recinfo.eng_change_priority_code IS NULL)
                    AND (X_Eng_Change_Priority_Code IS NULL)))
           AND (   (Recinfo.organization_id =  X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (Recinfo.process_name =  X_Process_Name)
                OR (    (Recinfo.process_name IS NULL)
                    AND (X_Process_Name IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Change_Order_Type_Id           NUMBER,
                       X_Eng_Change_Priority_Code       VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Process_Name                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
  BEGIN
    UPDATE ENG_CHANGE_TYPE_PROCESSES
    SET
       change_order_type_id            =     X_Change_Order_Type_Id,
       eng_change_priority_code        =     X_Eng_Change_Priority_Code,
       organization_id                 =     X_Organization_Id,
       process_name                    =     X_Process_Name,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
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
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM ENG_CHANGE_TYPE_PROCESSES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END ENG_CHANGE_TYPE_PROCESSES_PKG;

/
