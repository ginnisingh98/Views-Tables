--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_PARAMETERS_PKG" as
/* $Header: INVTTMVB.pls 120.1 2005/06/11 13:03:02 appldev  $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

                       X_Entity_Org_Id                  NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Entity_Branch_Reference        VARCHAR2,
                       X_Conversion_Type                VARCHAR2,
                       X_Conversion_Option              VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Tax_Office_Code                VARCHAR2,
                       X_Tax_Office_Name                VARCHAR2,
                       X_Tax_Office_Location_Id         NUMBER,
                       X_Last_Arrival_Period            VARCHAR2,
                       X_Last_Arrival_Id                NUMBER,
                       X_Last_Arrival_Adj_Period        VARCHAR2,
                       X_Last_Arrival_Adj_Id            NUMBER,
                       X_Last_Dispatch_Period           VARCHAR2,
                       X_Last_Dispatch_Id               NUMBER,
                       X_Last_Dispatch_Adj_Period       VARCHAR2,
                       X_Last_Dispatch_Adj_Id           NUMBER,
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
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM MTL_MOVEMENT_PARAMETERS
                 WHERE entity_org_id = X_Entity_Org_Id;

   BEGIN


       INSERT INTO MTL_MOVEMENT_PARAMETERS(

              entity_org_id,
              period_set_name,
              weight_uom_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              entity_branch_reference,
              conversion_type,
              conversion_option,
              category_set_id,
              tax_office_code,
              tax_office_name,
              tax_office_location_id,
              last_arrival_period,
              last_arrival_id,
              last_arrival_adj_period,
              last_arrival_adj_id,
              last_dispatch_period,
              last_dispatch_id,
              last_dispatch_adj_period,
              last_dispatch_adj_id,
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
              attribute16,
              attribute17,
              attribute18,
              attribute19,
              attribute20,
              attribute21,
              attribute22,
              attribute23,
              attribute24,
              attribute25,
              attribute26,
              attribute27,
              attribute28,
              attribute29,
              attribute30
             ) VALUES (

              X_Entity_Org_Id,
              X_Period_Set_Name,
              X_Weight_Uom_Code,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Entity_Branch_Reference,
              X_Conversion_Type,
              X_Conversion_Option,
              X_Category_Set_Id,
              X_Tax_Office_Code,
              X_Tax_Office_Name,
              X_Tax_Office_Location_Id,
              X_Last_Arrival_Period,
              X_Last_Arrival_Id,
              X_Last_Arrival_Adj_Period,
              X_Last_Arrival_Adj_Id,
              X_Last_Dispatch_Period,
              X_Last_Dispatch_Id,
              X_Last_Dispatch_Adj_Period,
              X_Last_Dispatch_Adj_Id,
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
              X_Attribute16,
              X_Attribute17,
              X_Attribute18,
              X_Attribute19,
              X_Attribute20,
              X_Attribute21,
              X_Attribute22,
              X_Attribute23,
              X_Attribute24,
              X_Attribute25,
              X_Attribute26,
              X_Attribute27,
              X_Attribute28,
              X_Attribute29,
              X_Attribute30

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

                     X_Entity_Org_Id                    NUMBER,
                     X_Period_Set_Name                  VARCHAR2,
                     X_Weight_Uom_Code                  VARCHAR2,
                     X_Entity_Branch_Reference          VARCHAR2,
                     X_Conversion_Type                  VARCHAR2,
                     X_Conversion_Option                VARCHAR2,
                     X_Category_Set_Id                  NUMBER,
                     X_Tax_Office_Code                  VARCHAR2,
                     X_Tax_Office_Name                  VARCHAR2,
                     X_Tax_Office_Location_Id           NUMBER,
                     X_Last_Arrival_Period              VARCHAR2,
                     X_Last_Arrival_Id                  NUMBER,
                     X_Last_Arrival_Adj_Period          VARCHAR2,
                     X_Last_Arrival_Adj_Id              NUMBER,
                     X_Last_Dispatch_Period             VARCHAR2,
                     X_Last_Dispatch_Id                 NUMBER,
                     X_Last_Dispatch_Adj_Period         VARCHAR2,
                     X_Last_Dispatch_Adj_Id             NUMBER,
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
                     X_Attribute15                      VARCHAR2,
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Attribute21                      VARCHAR2,
                     X_Attribute22                      VARCHAR2,
                     X_Attribute23                      VARCHAR2,
                     X_Attribute24                      VARCHAR2,
                     X_Attribute25                      VARCHAR2,
                     X_Attribute26                      VARCHAR2,
                     X_Attribute27                      VARCHAR2,
                     X_Attribute28                      VARCHAR2,
                     X_Attribute29                      VARCHAR2,
                     X_Attribute30                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   MTL_MOVEMENT_PARAMETERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Entity_Org_Id NOWAIT;
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

               (Recinfo.entity_org_id =  X_Entity_Org_Id)
           AND (Recinfo.period_set_name =  X_Period_Set_Name)
           AND (Recinfo.weight_uom_code =  X_Weight_Uom_Code)
           AND (   (Recinfo.entity_branch_reference =  X_Entity_Branch_Reference)
                OR (    (Recinfo.entity_branch_reference IS NULL)
                    AND (X_Entity_Branch_Reference IS NULL)))
           AND (   (Recinfo.conversion_type =  X_Conversion_Type)
                OR (    (Recinfo.conversion_type IS NULL)
                    AND (X_Conversion_Type IS NULL)))
           AND (   (Recinfo.conversion_option =  X_Conversion_Option)
                OR (    (Recinfo.conversion_option IS NULL)
                    AND (X_Conversion_Option IS NULL)))
           AND (   (Recinfo.category_set_id =  X_Category_Set_Id)
                OR (    (Recinfo.category_set_id IS NULL)
                    AND (X_Category_Set_Id IS NULL)))
           AND (   (Recinfo.tax_office_code =  X_Tax_Office_Code)
                OR (    (Recinfo.tax_office_code IS NULL)
                    AND (X_Tax_Office_Code IS NULL)))
           AND (   (Recinfo.tax_office_name =  X_Tax_Office_Name)
                OR (    (Recinfo.tax_office_name IS NULL)
                    AND (X_Tax_Office_Name IS NULL)))
           AND (   (Recinfo.tax_office_location_id =  X_Tax_Office_Location_Id)
                OR (    (Recinfo.tax_office_location_id IS NULL)
                    AND (X_Tax_Office_Location_Id IS NULL)))
           AND (   (Recinfo.last_arrival_period =  X_Last_Arrival_Period)
                OR (    (Recinfo.last_arrival_period IS NULL)
                    AND (X_Last_Arrival_Period IS NULL)))
           AND (   (Recinfo.last_arrival_id =  X_Last_Arrival_Id)
                OR (    (Recinfo.last_arrival_id IS NULL)
                    AND (X_Last_Arrival_Id IS NULL)))
           AND (   (Recinfo.last_arrival_adj_period =  X_Last_Arrival_Adj_Period)
                OR (    (Recinfo.last_arrival_adj_period IS NULL)
                    AND (X_Last_Arrival_Adj_Period IS NULL)))
           AND (   (Recinfo.last_arrival_adj_id =  X_Last_Arrival_Adj_Id)
                OR (    (Recinfo.last_arrival_adj_id IS NULL)
                    AND (X_Last_Arrival_Adj_Id IS NULL)))
           AND (   (Recinfo.last_dispatch_period =  X_Last_Dispatch_Period)
                OR (    (Recinfo.last_dispatch_period IS NULL)
                    AND (X_Last_Dispatch_Period IS NULL)))
           AND (   (Recinfo.last_dispatch_id =  X_Last_Dispatch_Id)
                OR (    (Recinfo.last_dispatch_id IS NULL)
                    AND (X_Last_Dispatch_Id IS NULL)))
           AND (   (Recinfo.last_dispatch_adj_period =  X_Last_Dispatch_Adj_Period)
                OR (    (Recinfo.last_dispatch_adj_period IS NULL)
                    AND (X_Last_Dispatch_Adj_Period IS NULL)))
           AND (   (Recinfo.last_dispatch_adj_id =  X_Last_Dispatch_Adj_Id)
                OR (    (Recinfo.last_dispatch_adj_id IS NULL)
                    AND (X_Last_Dispatch_Adj_Id IS NULL)))
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
           AND (   (Recinfo.attribute16 =  X_Attribute16)
                OR (    (Recinfo.attribute16 IS NULL)
                    AND (X_Attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 =  X_Attribute17)
                OR (    (Recinfo.attribute17 IS NULL)
                    AND (X_Attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 =  X_Attribute18)
                OR (    (Recinfo.attribute18 IS NULL)
                    AND (X_Attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 =  X_Attribute19)
                OR (    (Recinfo.attribute19 IS NULL)
                    AND (X_Attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 =  X_Attribute20)
                OR (    (Recinfo.attribute20 IS NULL)
                    AND (X_Attribute20 IS NULL)))
           AND (   (Recinfo.attribute21 =  X_Attribute21)
                OR (    (Recinfo.attribute21 IS NULL)
                    AND (X_Attribute21 IS NULL)))
           AND (   (Recinfo.attribute22 =  X_Attribute22)
                OR (    (Recinfo.attribute22 IS NULL)
                    AND (X_Attribute22 IS NULL)))
           AND (   (Recinfo.attribute23 =  X_Attribute23)
                OR (    (Recinfo.attribute23 IS NULL)
                    AND (X_Attribute23 IS NULL)))
           AND (   (Recinfo.attribute24 =  X_Attribute24)
                OR (    (Recinfo.attribute24 IS NULL)
                    AND (X_Attribute24 IS NULL)))
           AND (   (Recinfo.attribute25 =  X_Attribute25)
                OR (    (Recinfo.attribute25 IS NULL)
                    AND (X_Attribute25 IS NULL)))
           AND (   (Recinfo.attribute26 =  X_Attribute26)
                OR (    (Recinfo.attribute26 IS NULL)
                    AND (X_Attribute26 IS NULL)))
           AND (   (Recinfo.attribute27 =  X_Attribute27)
                OR (    (Recinfo.attribute27 IS NULL)
                    AND (X_Attribute27 IS NULL)))
           AND (   (Recinfo.attribute28 =  X_Attribute28)
                OR (    (Recinfo.attribute28 IS NULL)
                    AND (X_Attribute28 IS NULL)))
           AND (   (Recinfo.attribute29 =  X_Attribute29)
                OR (    (Recinfo.attribute29 IS NULL)
                    AND (X_Attribute29 IS NULL)))
           AND (   (Recinfo.attribute30 =  X_Attribute30)
                OR (    (Recinfo.attribute30 IS NULL)
                    AND (X_Attribute30 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Entity_Org_Id                  NUMBER,
                       X_Period_Set_Name                VARCHAR2,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Entity_Branch_Reference        VARCHAR2,
                       X_Conversion_Type                VARCHAR2,
                       X_Conversion_Option              VARCHAR2,
                       X_Category_Set_Id                NUMBER,
                       X_Tax_Office_Code                VARCHAR2,
                       X_Tax_Office_Name                VARCHAR2,
                       X_Tax_Office_Location_Id         NUMBER,
                       X_Last_Arrival_Period            VARCHAR2,
                       X_Last_Arrival_Id                NUMBER,
                       X_Last_Arrival_Adj_Period        VARCHAR2,
                       X_Last_Arrival_Adj_Id            NUMBER,
                       X_Last_Dispatch_Period           VARCHAR2,
                       X_Last_Dispatch_Id               NUMBER,
                       X_Last_Dispatch_Adj_Period       VARCHAR2,
                       X_Last_Dispatch_Adj_Id           NUMBER,
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
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Attribute26                    VARCHAR2,
                       X_Attribute27                    VARCHAR2,
                       X_Attribute28                    VARCHAR2,
                       X_Attribute29                    VARCHAR2,
                       X_Attribute30                    VARCHAR2

  ) IS
  BEGIN
    UPDATE MTL_MOVEMENT_PARAMETERS
    SET
       entity_org_id                   =     X_Entity_Org_Id,
       period_set_name                 =     X_Period_Set_Name,
       weight_uom_code                 =     X_Weight_Uom_Code,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       entity_branch_reference         =     X_Entity_Branch_Reference,
       conversion_type                 =     X_Conversion_Type,
       conversion_option               =     X_Conversion_Option,
       category_set_id                 =     X_Category_Set_Id,
       tax_office_code                 =     X_Tax_Office_Code,
       tax_office_name                 =     X_Tax_Office_Name,
       tax_office_location_id          =     X_Tax_Office_Location_Id,
       last_arrival_period             =     X_Last_Arrival_Period,
       last_arrival_id                 =     X_Last_Arrival_Id,
       last_arrival_adj_period         =     X_Last_Arrival_Adj_Period,
       last_arrival_adj_id             =     X_Last_Arrival_Adj_Id,
       last_dispatch_period            =     X_Last_Dispatch_Period,
       last_dispatch_id                =     X_Last_Dispatch_Id,
       last_dispatch_adj_period        =     X_Last_Dispatch_Adj_Period,
       last_dispatch_adj_id            =     X_Last_Dispatch_Adj_Id,
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
       attribute15                     =     X_Attribute15,
       attribute16                     =     X_Attribute16,
       attribute17                     =     X_Attribute17,
       attribute18                     =     X_Attribute18,
       attribute19                     =     X_Attribute19,
       attribute20                     =     X_Attribute20,
       attribute21                     =     X_Attribute21,
       attribute22                     =     X_Attribute22,
       attribute23                     =     X_Attribute23,
       attribute24                     =     X_Attribute24,
       attribute25                     =     X_Attribute25,
       attribute26                     =     X_Attribute26,
       attribute27                     =     X_Attribute27,
       attribute28                     =     X_Attribute28,
       attribute29                     =     X_Attribute29,
       attribute30                     =     X_Attribute30
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM MTL_MOVEMENT_PARAMETERS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_MOVEMENT_PARAMETERS_PKG;

/
