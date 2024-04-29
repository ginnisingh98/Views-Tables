--------------------------------------------------------
--  DDL for Package Body BOM_DEPARTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEPARTMENTS_PKG" as
/* $Header: bompodpb.pls 115.9 2002/11/19 03:15:13 lnarveka ship $ */


PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  IN OUT NOCOPY NUMBER,
                     X_Department_Code                VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                   DATE DEFAULT NULL,
                     X_Department_Class_Code          VARCHAR2 DEFAULT NULL,
		     X_Pa_Expenditure_Org_Id	      NUMBER   DEFAULT NULL,
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
                     X_Attribute15                    VARCHAR2 DEFAULT NULL,
                     X_Location_Id                    NUMBER DEFAULT NULL,
                     X_Scrap_Account                  NUMBER DEFAULT NULL,
                     X_Est_Absorption_Account         NUMBER DEFAULT NULL,
                     X_Maint_Cost_Category            VARCHAR2 DEFAULT NULL
   ) IS
  CURSOR C IS SELECT rowid FROM BOM_DEPARTMENTS
              WHERE department_id = X_Department_Id;
  CURSOR C2 IS SELECT bom_departments_s.nextval FROM sys.dual;
BEGIN
  if (X_Department_Id is NULL) then
    OPEN C2;
    FETCH C2 INTO X_Department_Id;
    CLOSE C2;
  end if;
  INSERT INTO BOM_DEPARTMENTS(
               department_id,
               department_code,
               organization_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               description,
               disable_date,
               department_class_code,
	       pa_expenditure_org_id,
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
               location_id,
	       scrap_account,
	       est_absorption_account,
               maint_cost_category
             ) VALUES (
               X_Department_Id,
               X_Department_Code,
               X_Organization_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Description,
               X_Disable_Date,
               X_Department_Class_Code,
	       X_Pa_Expenditure_Org_Id,
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
               X_Location_Id,
	       X_Scrap_Account,
	       X_Est_Absorption_Account,
               X_Maint_Cost_Category
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
                   X_Department_Id                    NUMBER,
                   X_Department_Code                  VARCHAR2,
                   X_Organization_Id                  NUMBER,
                   X_Description                      VARCHAR2 DEFAULT NULL,
                   X_Disable_Date                     DATE DEFAULT NULL,
                   X_Department_Class_Code            VARCHAR2 DEFAULT NULL,
		   X_Pa_Expenditure_Org_Id	      NUMBER   DEFAULT NULL,
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
                   X_Attribute15                      VARCHAR2 DEFAULT NULL,
                   X_Location_Id                      NUMBER DEFAULT NULL,
                   X_Scrap_Account                    NUMBER DEFAULT NULL,
                   X_Est_Absorption_Account           NUMBER DEFAULT NULL,
                   X_Maint_Cost_Category              VARCHAR2 DEFAULT NULL
  ) IS
  CURSOR C IS SELECT * FROM BOM_DEPARTMENTS
              WHERE  rowid = X_Rowid FOR UPDATE of Department_Id NOWAIT;
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
           (Recinfo.department_id = X_Department_Id)
       AND (Recinfo.department_code = X_Department_Code)
       AND (Recinfo.organization_id = X_Organization_Id)
       AND (   (Recinfo.description = X_Description)
            OR (    (Recinfo.description IS NULL)
                AND (X_Description IS NULL)))
       AND (   (Recinfo.disable_date = X_Disable_Date)
            OR (    (Recinfo.disable_date IS NULL)
                AND (X_Disable_Date IS NULL)))
       AND (   (Recinfo.department_class_code = X_Department_Class_Code)
            OR (    (Recinfo.department_class_code IS NULL)
                AND (X_Department_Class_Code IS NULL)))
       AND (   (Recinfo.pa_expenditure_org_id = X_pa_expenditure_org_id)
            OR (    (Recinfo.pa_expenditure_org_id IS NULL)
                AND (X_Pa_Expenditure_Org_Id IS NULL)))
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
       AND (   (Recinfo.location_id = X_Location_Id)
            OR (    (Recinfo.location_id IS NULL)
                AND (X_Location_Id IS NULL)))
       AND (   (Recinfo.Scrap_Account = X_Scrap_Account)
            OR (    (Recinfo.Scrap_Account IS NULL)
                AND (X_Scrap_Account IS NULL)))
       AND (   (Recinfo.Est_Absorption_Account = X_Est_Absorption_Account)
            OR (    (Recinfo.Est_Absorption_Account IS NULL)
                AND (X_Est_Absorption_Account IS NULL)))
       AND (   (Recinfo.Maint_Cost_Category = X_Maint_Cost_Category )
            OR (    (Recinfo.Maint_Cost_Category IS NULL)
                AND (X_Maint_Cost_Category IS NULL)))
        ) then
  return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Department_Code                VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Description                    VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                   DATE DEFAULT NULL,
                     X_Department_Class_Code          VARCHAR2 DEFAULT NULL,
		     X_Pa_Expenditure_Org_Id	      NUMBER   DEFAULT NULL,
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
                     X_Attribute15                    VARCHAR2 DEFAULT NULL,
                     X_Location_Id                    NUMBER DEFAULT NULL,
                     X_Scrap_Account                  NUMBER DEFAULT NULL,
                     X_Est_Absorption_Account         NUMBER DEFAULT NULL,
                     X_Maint_Cost_Category            VARCHAR2 DEFAULT NULL

 ) IS
BEGIN
  UPDATE BOM_DEPARTMENTS
  SET
     department_id                     =     X_Department_Id,
     department_code                   =     X_Department_Code,
     organization_id                   =     X_Organization_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     description                       =     X_Description,
     disable_date                      =     X_Disable_Date,
     department_class_code             =     X_Department_Class_Code,
     pa_expenditure_org_id	       =     X_Pa_Expenditure_Org_Id,
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
     attribute15                       =     X_Attribute15,
     location_id                       =     X_Location_Id,
     scrap_account                     =     X_Scrap_Account,
     est_absorption_account            =     X_Est_Absorption_Account,
     maint_cost_category               =     X_Maint_Cost_Category
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
  end if;
END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM BOM_DEPARTMENTS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;



PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Organization_Id NUMBER,
		       X_Department_Code VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM BOM_DEPARTMENTS
     WHERE Organization_Id = X_Organization_Id
       AND Department_Code = X_Department_Code
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM', 'BOM_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('ENTITY1', 'THIS_CAP', TRUE);
      FND_MESSAGE.SET_TOKEN('ENTITY2', 'DEPARTMENT', TRUE);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;



FUNCTION Resources_OSP_POReceipt(X_Department_Id NUMBER,
                                 X_Organization_Id NUMBER) RETURN NUMBER IS
  resources_exist NUMBER;
BEGIN
  SELECT COUNT(RESOURCE_ID) INTO resources_exist FROM BOM_DEPARTMENT_RESOURCES
    WHERE DEPARTMENT_ID = X_Department_Id
      AND RESOURCE_ID IN
          (SELECT RESOURCE_ID FROM BOM_RESOURCES
           WHERE COST_CODE_TYPE = 4
             AND AUTOCHARGE_TYPE = 3
             AND ORGANIZATION_ID = Organization_Id);
  RETURN(resources_exist);
END Resources_OSP_POReceipt;


/* GRANT EXECUTE ON BOM_DEPARTMENTS_PKG TO MFG; */



END BOM_DEPARTMENTS_PKG;

/
