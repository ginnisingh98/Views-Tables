--------------------------------------------------------
--  DDL for Package Body CST_COST_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_COST_TYPES_PKG" as
/* $Header: cstpcctb.pls 115.2 2002/11/11 23:05:48 awwang ship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Cost_Type_Id                 IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER DEFAULT NULL,
                     X_Cost_Type                           VARCHAR2,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Costing_Method_Type                 NUMBER,
                     X_Frozen_Standard_Flag                NUMBER DEFAULT NULL,
                     X_Default_Cost_Type_Id         IN OUT NOCOPY NUMBER,
                     X_Bom_Snapshot_Flag                   NUMBER,
                     X_Allow_Updates_Flag                  NUMBER DEFAULT NULL,
                     X_Pl_Element_Flag                     NUMBER,
                     X_Pl_Resource_Flag                    NUMBER,
                     X_Pl_Operation_Flag                   NUMBER,
                     X_Pl_Activity_Flag                    NUMBER,
                     X_Disable_Date                        DATE DEFAULT NULL,
                     X_Available_To_Eng_Flag               NUMBER DEFAULT NULL,
                     X_Component_Yield_Flag                NUMBER,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Alternate_Bom_Designator            VARCHAR2 DEFAULT NULL
 ) IS
   CURSOR C IS SELECT rowid FROM cst_cost_types

             WHERE cost_type_id = X_Cost_Type_Id;





    CURSOR C2 IS SELECT cst_cost_types_s.nextval FROM sys.dual;
BEGIN

   if (X_Cost_Type_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Cost_Type_Id;
     CLOSE C2;
   end if;
   if (X_Default_Cost_Type_Id is NULL) then
     X_Default_Cost_Type_Id := X_Cost_Type_Id;
   end if;
  INSERT INTO cst_cost_types(
          cost_type_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          organization_id,
          cost_type,
          description,
          costing_method_type,
          frozen_standard_flag,
          default_cost_type_id,
          bom_snapshot_flag,
          allow_updates_flag,
          pl_element_flag,
          pl_resource_flag,
          pl_operation_flag,
          pl_activity_flag,
          disable_date,
          available_to_eng_flag,
          component_yield_flag,
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
          alternate_bom_designator
         ) VALUES (
          X_Cost_Type_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Organization_Id,
          X_Cost_Type,
          X_Description,
          X_Costing_Method_Type,
          X_Frozen_Standard_Flag,
          nvl(X_Default_Cost_Type_Id, X_Cost_Type_Id),
          X_Bom_Snapshot_Flag,
          X_Allow_Updates_Flag,
          X_Pl_Element_Flag,
          X_Pl_Resource_Flag,
          X_Pl_Operation_Flag,
          X_Pl_Activity_Flag,
          X_Disable_Date,
          X_Available_To_Eng_Flag,
          X_Component_Yield_Flag,
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
          X_Alternate_Bom_Designator

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Cost_Type_Id                          NUMBER,
                   X_Organization_Id                       NUMBER DEFAULT NULL,
                   X_Cost_Type                             VARCHAR2,
                   X_Description                           VARCHAR2 DEFAULT NULL,
                   X_Costing_Method_Type                   NUMBER,
                   X_Frozen_Standard_Flag                  NUMBER DEFAULT NULL,
                   X_Default_Cost_Type_Id                  NUMBER,
                   X_Bom_Snapshot_Flag                     NUMBER,
                   X_Allow_Updates_Flag                    NUMBER DEFAULT NULL,
                   X_Pl_Element_Flag                       NUMBER,
                   X_Pl_Resource_Flag                      NUMBER,
                   X_Pl_Operation_Flag                     NUMBER,
                   X_Pl_Activity_Flag                      NUMBER,
                   X_Disable_Date                          DATE DEFAULT NULL,
                   X_Available_To_Eng_Flag                 NUMBER DEFAULT NULL,
                   X_Component_Yield_Flag                  NUMBER,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL,
                   X_Alternate_Bom_Designator              VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   cst_cost_types
      WHERE  rowid = X_Rowid
      FOR UPDATE of Cost_Type_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.cost_type_id = X_Cost_Type_Id)
           OR (    (Recinfo.cost_type_id IS NULL)
               AND (X_Cost_Type_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.cost_type = X_Cost_Type)
           OR (    (Recinfo.cost_type IS NULL)
               AND (X_Cost_Type IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.costing_method_type = X_Costing_Method_Type)
           OR (    (Recinfo.costing_method_type IS NULL)
               AND (X_Costing_Method_Type IS NULL)))
      AND (   (Recinfo.frozen_standard_flag = X_Frozen_Standard_Flag)
           OR (    (Recinfo.frozen_standard_flag IS NULL)
               AND (X_Frozen_Standard_Flag IS NULL)))
      AND (   (Recinfo.default_cost_type_id = X_Default_Cost_Type_Id)
           OR (    (Recinfo.default_cost_type_id IS NULL)
               AND (X_Default_Cost_Type_Id IS NULL)))
      AND (   (Recinfo.bom_snapshot_flag = X_Bom_Snapshot_Flag)
           OR (    (Recinfo.bom_snapshot_flag IS NULL)
               AND (X_Bom_Snapshot_Flag IS NULL)))
      AND (   (Recinfo.allow_updates_flag = X_Allow_Updates_Flag)
           OR (    (Recinfo.allow_updates_flag IS NULL)
               AND (X_Allow_Updates_Flag IS NULL)))
      AND (   (Recinfo.pl_element_flag = X_Pl_Element_Flag)
           OR (    (Recinfo.pl_element_flag IS NULL)
               AND (X_Pl_Element_Flag IS NULL)))
      AND (   (Recinfo.pl_resource_flag = X_Pl_Resource_Flag)
           OR (    (Recinfo.pl_resource_flag IS NULL)
               AND (X_Pl_Resource_Flag IS NULL)))
      AND (   (Recinfo.pl_operation_flag = X_Pl_Operation_Flag)
           OR (    (Recinfo.pl_operation_flag IS NULL)
               AND (X_Pl_Operation_Flag IS NULL)))
      AND (   (Recinfo.pl_activity_flag = X_Pl_Activity_Flag)
           OR (    (Recinfo.pl_activity_flag IS NULL)
               AND (X_Pl_Activity_Flag IS NULL)))
      AND (   (Recinfo.disable_date = X_Disable_Date)
           OR (    (Recinfo.disable_date IS NULL)
               AND (X_Disable_Date IS NULL)))
      AND (   (Recinfo.available_to_eng_flag = X_Available_To_Eng_Flag)
           OR (    (Recinfo.available_to_eng_flag IS NULL)
               AND (X_Available_To_Eng_Flag IS NULL)))
      AND (   (Recinfo.component_yield_flag = X_Component_Yield_Flag)
           OR (    (Recinfo.component_yield_flag IS NULL)
               AND (X_Component_Yield_Flag IS NULL)))
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
      AND (   (Recinfo.alternate_bom_designator = X_Alternate_Bom_Designator)
           OR (    (Recinfo.alternate_bom_designator IS NULL)
               AND (X_Alternate_Bom_Designator IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Cost_Type_Id                        NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Organization_Id                     NUMBER DEFAULT NULL,
                     X_Cost_Type                           VARCHAR2,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Costing_Method_Type                 NUMBER,
                     X_Frozen_Standard_Flag                NUMBER DEFAULT NULL,
                     X_Default_Cost_Type_Id                NUMBER,
                     X_Bom_Snapshot_Flag                   NUMBER,
                     X_Allow_Updates_Flag                  NUMBER DEFAULT NULL,
                     X_Pl_Element_Flag                     NUMBER,
                     X_Pl_Resource_Flag                    NUMBER,
                     X_Pl_Operation_Flag                   NUMBER,
                     X_Pl_Activity_Flag                    NUMBER,
                     X_Disable_Date                        DATE DEFAULT NULL,
                     X_Available_To_Eng_Flag               NUMBER DEFAULT NULL,
                     X_Component_Yield_Flag                NUMBER,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
                     X_Alternate_Bom_Designator            VARCHAR2 DEFAULT NULL
) IS
BEGIN
  UPDATE cst_cost_types
  SET

    cost_type_id                              =    X_Cost_Type_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    organization_id                           =    X_Organization_Id,
    cost_type                                 =    X_Cost_Type,
    description                               =    X_Description,
    costing_method_type                       =    X_Costing_Method_Type,
    frozen_standard_flag                      =    X_Frozen_Standard_Flag,
    default_cost_type_id                      =    X_Default_Cost_Type_Id,
    bom_snapshot_flag                         =    X_Bom_Snapshot_Flag,
    allow_updates_flag                        =    X_Allow_Updates_Flag,
    pl_element_flag                           =    X_Pl_Element_Flag,
    pl_resource_flag                          =    X_Pl_Resource_Flag,
    pl_operation_flag                         =    X_Pl_Operation_Flag,
    pl_activity_flag                          =    X_Pl_Activity_Flag,
    disable_date                              =    X_Disable_Date,
    available_to_eng_flag                     =    X_Available_To_Eng_Flag,
    component_yield_flag                      =    X_Component_Yield_Flag,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    alternate_bom_designator                  =    X_Alternate_Bom_Designator
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM cst_cost_types
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END CST_COST_TYPES_PKG;

/
