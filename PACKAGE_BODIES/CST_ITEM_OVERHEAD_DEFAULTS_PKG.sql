--------------------------------------------------------
--  DDL for Package Body CST_ITEM_OVERHEAD_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ITEM_OVERHEAD_DEFAULTS_PKG" as
/* $Header: CSTPOVDB.pls 115.2 2002/11/11 19:20:13 awwang ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Category_Set_Id                NUMBER DEFAULT NULL,
                       X_Category_Id                    NUMBER DEFAULT NULL,
                       X_Material_Overhead_Id           NUMBER,
                       X_Item_Type                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Activity_Id                    NUMBER DEFAULT NULL,
                       X_Basis_Type                     NUMBER DEFAULT NULL,
                       X_Item_Units                     NUMBER DEFAULT NULL,
                       X_Activity_Units                 NUMBER DEFAULT NULL,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Activity_Context               VARCHAR2 DEFAULT NULL,
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
     CURSOR C IS SELECT rowid FROM cst_item_overhead_defaults
                 WHERE organization_id = X_Organization_Id
                 AND   (    (item_type = X_Item_Type)
                        or (item_type is NULL and X_Item_Type is NULL))
                 AND   (    (category_id = X_Category_Id)
                        or (category_id is NULL and X_Category_Id is NULL))
                 AND   (    (material_overhead_id = X_Material_Overhead_Id)
                        or (material_overhead_id is NULL and X_Material_Overhead_Id  is NULL))
                 AND   (    (activity_id = X_Activity_Id)
                        or (activity_id is NULL and X_Activity_Id is NULL));


    BEGIN


       INSERT INTO cst_item_overhead_defaults(
               organization_id,
               category_set_id,
               category_id,
               material_overhead_id,
               item_type,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               activity_id,
               basis_type,
               item_units,
               activity_units,
               usage_rate_or_amount,
               attribute_category,
               activity_context,
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
               X_Organization_Id,
               X_Category_Set_Id,
               X_Category_Id,
               X_Material_Overhead_Id,
               X_Item_Type,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Activity_Id,
               X_Basis_Type,
               X_Item_Units,
               X_Activity_Units,
               X_Usage_Rate_Or_Amount,
               X_Attribute_Category,
               X_Activity_Context,
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
                     X_Organization_Id                  NUMBER,
                     X_Category_Set_Id                  NUMBER DEFAULT NULL,
                     X_Category_Id                      NUMBER DEFAULT NULL,
                     X_Material_Overhead_Id             NUMBER ,
                     X_Item_Type                        NUMBER ,
                     X_Activity_Id                      NUMBER DEFAULT NULL,
                     X_Basis_Type                       NUMBER DEFAULT NULL,
                     X_Item_Units                       NUMBER DEFAULT NULL,
                     X_Activity_Units                   NUMBER DEFAULT NULL,
                     X_Usage_Rate_Or_Amount             NUMBER,
                     X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                     X_Activity_Context                 VARCHAR2 DEFAULT NULL,
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
    CURSOR C IS
        SELECT *
        FROM   cst_item_overhead_defaults
        WHERE  rowid = X_Rowid
        FOR UPDATE of Organization_Id,Item_Type,Category_Id,Material_Overhead_Id,
                      Activity_Id NOWAIT;
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

               (Recinfo.organization_id = X_Organization_Id)
           AND (   (Recinfo.category_set_id = X_Category_Set_Id)
                OR (    (Recinfo.category_set_id IS NULL)
                    AND (X_Category_Set_Id IS NULL)))
           AND (   (Recinfo.category_id = X_Category_Id)
                OR (    (Recinfo.category_id IS NULL)
                    AND (X_Category_Id IS NULL)))
           AND (   (Recinfo.material_overhead_id = X_Material_Overhead_Id)
                OR (    (Recinfo.material_overhead_id IS NULL)
                    AND (X_Material_Overhead_Id IS NULL)))
           AND (   (Recinfo.item_type = X_Item_Type)
                OR (    (Recinfo.item_type IS NULL)
                    AND (X_Item_Type IS NULL)))
           AND (   (Recinfo.activity_id = X_Activity_Id)
                OR (    (Recinfo.activity_id IS NULL)
                    AND (X_Activity_Id IS NULL)))
           AND (   (Recinfo.basis_type = X_Basis_Type)
                OR (    (Recinfo.basis_type IS NULL)
                    AND (X_Basis_Type IS NULL)))
           AND (   (Recinfo.item_units = X_Item_Units)
                OR (    (Recinfo.item_units IS NULL)
                    AND (X_Item_Units IS NULL)))
           AND (   (Recinfo.activity_units = X_Activity_Units)
                OR (    (Recinfo.activity_units IS NULL)
                    AND (X_Activity_Units IS NULL)))
           AND (Recinfo.usage_rate_or_amount = X_Usage_Rate_Or_Amount)
           AND (   (Recinfo.attribute_category = X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.activity_context = X_Activity_Context)
                OR (    (Recinfo.activity_context IS NULL)
                    AND (X_Activity_Context IS NULL)))
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
                       X_Organization_Id                NUMBER,
                       X_Category_Set_Id                NUMBER DEFAULT NULL,
                       X_Category_Id                    NUMBER DEFAULT NULL,
                       X_Material_Overhead_Id           NUMBER ,
                       X_Item_Type                      NUMBER ,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Activity_Id                    NUMBER DEFAULT NULL,
                       X_Basis_Type                     NUMBER DEFAULT NULL,
                       X_Item_Units                     NUMBER DEFAULT NULL,
                       X_Activity_Units                 NUMBER DEFAULT NULL,
                       X_Usage_Rate_Or_Amount           NUMBER,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Activity_Context               VARCHAR2 DEFAULT NULL,
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
   UPDATE cst_item_overhead_defaults
   SET
     organization_id                   =     X_Organization_Id,
     category_set_id                   =     X_Category_Set_Id,
     category_id                       =     X_Category_Id,
     material_overhead_id              =     X_Material_Overhead_Id,
     item_type                         =     X_Item_Type,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     activity_id                       =     X_Activity_Id,
     basis_type                        =     X_Basis_Type,
     item_units                        =     X_Item_Units,
     activity_units                    =     X_Activity_Units,
     usage_rate_or_amount              =     X_Usage_Rate_Or_Amount,
     attribute_category                =     X_Attribute_Category,
     activity_context                  =     X_Activity_Context,
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
    DELETE FROM cst_item_overhead_defaults
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END CST_ITEM_OVERHEAD_DEFAULTS_PKG;

/
