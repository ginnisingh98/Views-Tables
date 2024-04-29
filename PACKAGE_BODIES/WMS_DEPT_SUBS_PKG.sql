--------------------------------------------------------
--  DDL for Package Body WMS_DEPT_SUBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEPT_SUBS_PKG" AS
/* $Header: WMSDPZNB.pls 120.1 2005/06/20 06:10:17 appldev ship $ */
--
 PROCEDURE insert_row
   (X_Rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute15                    VARCHAR2 DEFAULT NULL,
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  ) IS
     CURSOR C IS
	SELECT rowid FROM WMS_DEPARTMENT_SUBINVENTORIES
         WHERE organization_id		= X_Organization_Id
         AND   subinventory_code        = X_subinventory_code
         AND   department_id            = X_department_Id
	 AND   NVL(effective_from_date,TO_DATE('01011900','DDMMYYYY'))
		= NVL(X_Effective_From_date,TO_DATE('01011900','DDMMYYYY'))
	 AND   NVL(effective_to_date, TO_DATE('31124000','DDMMYYYY'))
                     = NVL(X_Effective_To_date, TO_DATE('31124000','DDMMYYYY'));

   BEGIN

       INSERT INTO WMS_DEPARTMENT_SUBINVENTORIES(
 	      Organization_Id,
              subinventory_Code,
              department_Id,
              Effective_From_date,
	      Effective_To_date,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
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
              attribute_category
             ) VALUES (
	      X_Organization_Id,
              X_subinventory_Code,
              X_department_Id,
              X_Effective_From_date,
	      X_Effective_To_date,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
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
              X_Attribute_Category
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE lock_row
   (X_Rowid                          IN VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute15                    VARCHAR2 DEFAULT NULL,
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS SELECT *
                FROM   WMS_DEPARTMENT_SUBINVENTORIES
                WHERE  rowid = X_Rowid
                FOR UPDATE of department_Id NOWAIT;
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
    if (       (Recinfo.organization_id =  X_Organization_Id)
	   AND (Recinfo.subinventory_code =  X_subinventory_Code)
           AND (Recinfo.department_id =  X_department_Id)
	   AND (   (Recinfo.effective_from_date =  X_Effective_From_date)
                OR (    (Recinfo.effective_from_date IS NULL)
                    AND (X_Effective_From_date IS NULL)))
	   AND (   (Recinfo.effective_to_date =  X_Effective_To_date)
                OR (    (Recinfo.effective_to_date IS NULL)
                    AND (X_Effective_To_date IS NULL)))
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
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE update_row
   (X_Rowid                          IN VARCHAR2,
    X_Organization_Id		     NUMBER,
    X_subinventory_code              VARCHAR2 ,
    X_department_Id		     NUMBER,
    X_Effective_From_date            DATE DEFAULT NULL,
    X_Effective_To_date              DATE DEFAULT NULL,
    X_Created_By                     NUMBER,
    X_Creation_Date                  DATE,
    X_Last_Updated_By                NUMBER,
    X_Last_Update_Date               DATE,
    X_Last_Update_Login              NUMBER DEFAULT NULL,
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
    X_Attribute15                    VARCHAR2 DEFAULT NULL,
    X_Attribute_Category             VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    UPDATE WMS_DEPARTMENT_SUBINVENTORIES
    SET
       organization_id		       =     X_Organization_Id,
       subinventory_code               =     X_subinventory_Code,
       department_id		       =     X_department_Id,
       effective_from_date             =     X_Effective_From_date,
       effective_to_date               =     X_Effective_To_date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       last_update_login               =     X_Last_Update_Login,
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
       attribute15                     =     X_Attribute15,
       attribute_category              =     X_Attribute_Category
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM WMS_DEPARTMENT_SUBINVENTORIES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
END WMS_DEPT_SUBS_PKG;

/
