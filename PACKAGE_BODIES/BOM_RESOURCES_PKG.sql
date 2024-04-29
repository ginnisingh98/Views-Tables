--------------------------------------------------------
--  DDL for Package Body BOM_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RESOURCES_PKG" as
/* $Header: bomporsb.pls 120.0 2005/05/25 03:53:57 appldev noship $ */

  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Resource_Id                    IN OUT NOCOPY NUMBER,
                       X_Resource_Code                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Disable_Date                   DATE,
                       X_Cost_Element_Id                NUMBER,
                       X_Purchase_Item_Id               NUMBER,
                       X_Cost_Code_Type                 NUMBER,
                       X_Functional_Currency_Flag       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Default_Activity_Id            NUMBER,
                       X_Resource_Type                  NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Default_Basis_Type             NUMBER,
                       X_Absorption_Account             NUMBER,
                       X_Allow_Costs_Flag               NUMBER,
                       X_Rate_Variance_Account          NUMBER,
                       X_Expenditure_Type               VARCHAR2,
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
                       X_REQUEST_ID                     NUMBER := NULL,
                       X_PROGRAM_APPLICATION_ID         NUMBER := NULL,
                       X_PROGRAM_ID                     NUMBER := NULL,
                       X_PROGRAM_UPDATE_DATE            DATE   := NULL
                      )
  IS
  BEGIN
            Insert_Row(X_Rowid              => X_Rowid,
                       X_Resource_Id        => X_Resource_Id,
                       X_Resource_Code      => X_Resource_Code,
                       X_Organization_Id    => X_Organization_Id,
                       X_Last_Update_Date   => X_Last_Update_Date,
                       X_Last_Updated_By    => X_Last_Updated_By,
                       X_Creation_Date      => X_Creation_Date,
                       X_Created_By         => X_Created_By,
                       X_Last_Update_Login  => X_Last_Update_Login,
                       X_Description        => X_Description,
                       X_Disable_Date       => X_Disable_Date,
                       X_Cost_Element_Id    => X_Cost_Element_Id,
                       X_Purchase_Item_Id  => X_Purchase_Item_Id,
                       X_Cost_Code_Type    => X_Cost_Code_Type,
                       X_Functional_Currency_Flag  => X_Functional_Currency_Flag,
                       X_Unit_Of_Measure       => X_Unit_Of_Measure,
                       X_Default_Activity_Id   => X_Default_Activity_Id,
                       X_Resource_Type         => X_Resource_Type,
                       X_Autocharge_Type       => X_Autocharge_Type,
                       X_Standard_Rate_Flag    => X_Standard_Rate_Flag,
                       X_Default_Basis_Type    => X_Default_Basis_Type,
                       X_Absorption_Account    => X_Absorption_Account,
                       X_Allow_Costs_Flag      => X_Allow_Costs_Flag,
                       X_Rate_Variance_Account => X_Rate_Variance_Account,
                       X_Expenditure_Type      => X_Expenditure_Type,
                       X_Attribute_Category    => X_Attribute_Category,
                       X_Attribute1     => X_Attribute1,
                       X_Attribute2     => X_Attribute2,
                       X_Attribute3     => X_Attribute3,
                       X_Attribute4     => X_Attribute4,
                       X_Attribute5     => X_Attribute5,
                       X_Attribute6     => X_Attribute6,
                       X_Attribute7     => X_Attribute7,
                       X_Attribute8     => X_Attribute8,
                       X_Attribute9     => X_Attribute9,
                       X_Attribute10    => X_Attribute10,
                       X_Attribute11    => X_Attribute11,
                       X_Attribute12    => X_Attribute12,
                       X_Attribute13    => X_Attribute13,
                       X_Attribute14    => X_Attribute14,
                       X_Attribute15    => X_Attribute15,
                       X_REQUEST_ID     =>X_REQUEST_ID,
                       X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                       X_PROGRAM_ID          => X_PROGRAM_ID,
                       X_PROGRAM_UPDATE_DATE =>X_PROGRAM_UPDATE_DATE,
                       X_BATCHABLE           =>NULL,
                       X_MIN_BATCH_CAPACITY  =>NULL,
                       X_MAX_BATCH_CAPACITY  =>NULL,
                       X_BATCH_CAPACITY_UOM  =>NULL,
                       X_BATCH_WINDOW        =>NULL,
                       X_BATCH_WINDOW_UOM    =>NULL,
                       X_COMPETENCE_ID       =>NULL,
                       X_RATING_LEVEL_ID     =>NULL,
                       X_QUALIFICATION_TYPE_ID => NULL,
                       X_BILLABLE_ITEM_ID  => NULL,
                       X_SUPPLY_SUBINVENTORY => NULL,
                       X_SUPPLY_LOCATOR_ID   => NULL,
		       X_BATCHING_PENALTY    => NULL);                             --APS Enhancement for Routings
END;
  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Resource_Id                    IN OUT NOCOPY NUMBER,
                       X_Resource_Code                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Disable_Date                   DATE,
                       X_Cost_Element_Id                NUMBER,
                       X_Purchase_Item_Id               NUMBER,
                       X_Cost_Code_Type                 NUMBER,
                       X_Functional_Currency_Flag       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Default_Activity_Id            NUMBER,
                       X_Resource_Type                  NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Default_Basis_Type             NUMBER,
                       X_Absorption_Account             NUMBER,
                       X_Allow_Costs_Flag               NUMBER,
                       X_Rate_Variance_Account          NUMBER,
                       X_Expenditure_Type               VARCHAR2,
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
                       X_REQUEST_ID                     NUMBER := NULL,
                       X_PROGRAM_APPLICATION_ID         NUMBER := NULL,
                       X_PROGRAM_ID                     NUMBER := NULL,
                       X_PROGRAM_UPDATE_DATE            DATE   := NULL,
                       X_BATCHABLE                      NUMBER ,
                       X_MIN_BATCH_CAPACITY             NUMBER ,
                       X_MAX_BATCH_CAPACITY             NUMBER ,
                       X_BATCH_CAPACITY_UOM             VARCHAR2 ,
                       X_BATCH_WINDOW                   NUMBER ,
                       X_BATCH_WINDOW_UOM               VARCHAR2,
                       X_COMPETENCE_ID                  NUMBER := NULL,
                       X_RATING_LEVEL_ID                NUMBER := NULL,
                       X_QUALIFICATION_TYPE_ID          NUMBER := NULL,
                       X_BILLABLE_ITEM_ID		NUMBER := NULL,
                       X_SUPPLY_SUBINVENTORY            VARCHAR2,
                       X_SUPPLY_LOCATOR_ID             NUMBER :=NULL,
		       X_BATCHING_PENALTY              NUMBER :=NULL               --APS Enhancement for Routings
  ) IS
    CURSOR C IS SELECT rowid FROM BOM_RESOURCES
                 WHERE resource_id = X_Resource_Id;
      CURSOR C2 IS SELECT bom_resources_s.nextval FROM sys.dual;
   BEGIN
      if (X_Resource_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Resource_Id;
        CLOSE C2;
      end if;

       INSERT INTO BOM_RESOURCES(
              resource_id,
              resource_code,
              organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              description,
              disable_date,
              cost_element_id,
              purchase_item_id,
              cost_code_type,
              functional_currency_flag,
              unit_of_measure,
              default_activity_id,
              resource_type,
              autocharge_type,
              standard_rate_flag,
              default_basis_type,
              absorption_account,
              allow_costs_flag,
              rate_variance_account,
              expenditure_type,
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
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              BATCHABLE,
              MIN_BATCH_CAPACITY,
              MAX_BATCH_CAPACITY,
              BATCH_CAPACITY_UOM,
              BATCH_WINDOW,
              BATCH_WINDOW_UOM,
              COMPETENCE_ID,
              RATING_LEVEL_ID,
              QUALIFICATION_TYPE_ID,
              BILLABLE_ITEM_ID,
              SUPPLY_SUBINVENTORY,
              SUPPLY_LOCATOR_ID,
	      BATCHING_PENALTY                   --APS Enhancement for Routings
             ) VALUES (
              X_Resource_Id,
              X_Resource_Code,
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Description,
              X_Disable_Date,
              X_Cost_Element_Id,
              X_Purchase_Item_Id,
              X_Cost_Code_Type,
              X_Functional_Currency_Flag,
              X_Unit_Of_Measure,
              X_Default_Activity_Id,
              X_Resource_Type,
              X_Autocharge_Type,
              X_Standard_Rate_Flag,
              X_Default_Basis_Type,
              X_Absorption_Account,
              X_Allow_Costs_Flag,
              X_Rate_Variance_Account,
              X_Expenditure_Type,
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
              X_REQUEST_ID,
              X_PROGRAM_APPLICATION_ID,
              X_PROGRAM_ID,
              X_PROGRAM_UPDATE_DATE,
              X_BATCHABLE,
              X_MIN_BATCH_CAPACITY,
              X_MAX_BATCH_CAPACITY,
              X_BATCH_CAPACITY_UOM,
              X_BATCH_WINDOW,
              X_BATCH_WINDOW_UOM,
              X_COMPETENCE_ID,
              X_RATING_LEVEL_ID,
              X_QUALIFICATION_TYPE_ID,
              X_BILLABLE_ITEM_ID,
              X_SUPPLY_SUBINVENTORY,
              X_SUPPLY_LOCATOR_ID,
	      X_BATCHING_PENALTY                      --APS Enhancement for Routings
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
                     X_Resource_Id                      NUMBER,
                     X_Resource_Code                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
                     X_Disable_Date                     DATE,
                     X_Cost_Element_Id                  NUMBER,
                     X_Purchase_Item_Id                 NUMBER,
                     X_Cost_Code_Type                   NUMBER,
                     X_Functional_Currency_Flag         NUMBER,
                     X_Unit_Of_Measure                  VARCHAR2,
                     X_Default_Activity_Id              NUMBER,
                     X_Resource_Type                    NUMBER,
                     X_Autocharge_Type                  NUMBER,
                     X_Standard_Rate_Flag               NUMBER,
                     X_Default_Basis_Type               NUMBER,
                     X_Absorption_Account               NUMBER,
                     X_Allow_Costs_Flag                 NUMBER,
                     X_Rate_Variance_Account            NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
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
                     X_REQUEST_ID                       NUMBER := NULL,
                     X_PROGRAM_APPLICATION_ID           NUMBER := NULL,
                     X_PROGRAM_ID                       NUMBER := NULL,
                     X_PROGRAM_UPDATE_DATE              DATE   := NULL
                    )
  IS BEGIN
            Lock_Row(X_Rowid              => X_Rowid,
                       X_Resource_Id        => X_Resource_Id,
                       X_Resource_Code      => X_Resource_Code,
                       X_Organization_Id    => X_Organization_Id,
                       X_Description        => X_Description,
                       X_Disable_Date       => X_Disable_Date,
                       X_Cost_Element_Id    => X_Cost_Element_Id,
                       X_Purchase_Item_Id  => X_Purchase_Item_Id,
                       X_Cost_Code_Type    => X_Cost_Code_Type,
                       X_Functional_Currency_Flag  => X_Functional_Currency_Flag,
                       X_Unit_Of_Measure       => X_Unit_Of_Measure,
                       X_Default_Activity_Id   => X_Default_Activity_Id,
                       X_Resource_Type         => X_Resource_Type,
                       X_Autocharge_Type       => X_Autocharge_Type,
                       X_Standard_Rate_Flag    => X_Standard_Rate_Flag,
                       X_Default_Basis_Type    => X_Default_Basis_Type,
                       X_Absorption_Account    => X_Absorption_Account,
                       X_Allow_Costs_Flag      => X_Allow_Costs_Flag,
                       X_Rate_Variance_Account => X_Rate_Variance_Account,
                       X_Expenditure_Type      => X_Expenditure_Type,
                       X_Attribute_Category    => X_Attribute_Category,
                       X_Attribute1     => X_Attribute1,
                       X_Attribute2     => X_Attribute2,
                       X_Attribute3     => X_Attribute3,
                       X_Attribute4     => X_Attribute4,
                       X_Attribute5     => X_Attribute5,
                       X_Attribute6     => X_Attribute6,
                       X_Attribute7     => X_Attribute7,
                       X_Attribute8     => X_Attribute8,
                       X_Attribute9     => X_Attribute9,
                       X_Attribute10    => X_Attribute10,
                       X_Attribute11    => X_Attribute11,
                       X_Attribute12    => X_Attribute12,
                       X_Attribute13    => X_Attribute13,
                       X_Attribute14    => X_Attribute14,
                       X_Attribute15    => X_Attribute15,
                       X_REQUEST_ID     =>X_REQUEST_ID,
                       X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                       X_PROGRAM_ID             => X_PROGRAM_ID,
                       X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE,
                       X_BATCHABLE           =>NULL,
                       X_MIN_BATCH_CAPACITY  =>NULL,
                       X_MAX_BATCH_CAPACITY  =>NULL,
                       X_BATCH_CAPACITY_UOM  =>NULL,
                       X_BATCH_WINDOW        =>NULL,
                       X_BATCH_WINDOW_UOM    =>NULL,
                       X_COMPETENCE_ID       =>NULL,
                       X_RATING_LEVEL_ID     =>NULL,
                       X_QUALIFICATION_TYPE_ID => NULL,
                       X_BILLABLE_ITEM_ID  => NULL,
                       X_SUPPLY_SUBINVENTORY => NULL,
                       X_SUPPLY_LOCATOR_ID   => NULL,
		       X_BATCHING_PENALTY    => NULL);                    --APS Enhancement for Routings

  END;
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Resource_Id                      NUMBER,
                     X_Resource_Code                    VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
                     X_Disable_Date                     DATE,
                     X_Cost_Element_Id                  NUMBER,
                     X_Purchase_Item_Id                 NUMBER,
                     X_Cost_Code_Type                   NUMBER,
                     X_Functional_Currency_Flag         NUMBER,
                     X_Unit_Of_Measure                  VARCHAR2,
                     X_Default_Activity_Id              NUMBER,
                     X_Resource_Type                    NUMBER,
                     X_Autocharge_Type                  NUMBER,
                     X_Standard_Rate_Flag               NUMBER,
                     X_Default_Basis_Type               NUMBER,
                     X_Absorption_Account               NUMBER,
                     X_Allow_Costs_Flag                 NUMBER,
                     X_Rate_Variance_Account            NUMBER,
                     X_Expenditure_Type                 VARCHAR2,
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
                     X_REQUEST_ID                       NUMBER := NULL,
                     X_PROGRAM_APPLICATION_ID           NUMBER := NULL,
                     X_PROGRAM_ID                       NUMBER := NULL,
                     X_PROGRAM_UPDATE_DATE              DATE   := NULL,
                     X_BATCHABLE                        NUMBER ,
                     X_MIN_BATCH_CAPACITY               NUMBER ,
                     X_MAX_BATCH_CAPACITY               NUMBER ,
                     X_BATCH_CAPACITY_UOM               VARCHAR2 ,
                     X_BATCH_WINDOW                     NUMBER ,
                     X_BATCH_WINDOW_UOM                 VARCHAR2,
                     X_COMPETENCE_ID                    NUMBER := NULL,
                     X_RATING_LEVEL_ID                  NUMBER := NULL,
                     X_QUALIFICATION_TYPE_ID            NUMBER := NULL,
                     X_BILLABLE_ITEM_ID			NUMBER := NULL,
                     X_SUPPLY_SUBINVENTORY            VARCHAR2,
                     X_SUPPLY_LOCATOR_ID             NUMBER :=NULL,
		     X_BATCHING_PENALTY              NUMBER :=NULL                 --APS Enhancement for Routings

  ) IS
    CURSOR C IS
        SELECT *
        FROM   BOM_RESOURCES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Resource_Id NOWAIT;
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
               (Recinfo.resource_id =  X_Resource_Id)
           AND (Recinfo.resource_code =  X_Resource_Code)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.disable_date =  X_Disable_Date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_Disable_Date IS NULL)))
           AND (Recinfo.cost_element_id =  X_Cost_Element_Id)
           AND (   (Recinfo.purchase_item_id =  X_Purchase_Item_Id)
                OR (    (Recinfo.purchase_item_id IS NULL)
                    AND (X_Purchase_Item_Id IS NULL)))
           AND (Recinfo.cost_code_type =  X_Cost_Code_Type)
           AND (Recinfo.functional_currency_flag =  X_Functional_Currency_Flag)
           AND (   (Recinfo.unit_of_measure =  X_Unit_Of_Measure)
                OR (    (Recinfo.unit_of_measure IS NULL)
                    AND (X_Unit_Of_Measure IS NULL)))
           AND (   (Recinfo.default_activity_id =  X_Default_Activity_Id)
                OR (    (Recinfo.default_activity_id IS NULL)
                    AND (X_Default_Activity_Id IS NULL)))
           AND ( X_Resource_Type = 6 OR
                 (X_Resource_Type <> 6 AND
                  ((Recinfo.resource_type =  X_Resource_Type)
                   OR ((Recinfo.resource_type IS NULL)
                       AND (X_Resource_Type IS NULL)))) OR
                 ((Recinfo.resource_type IS NULL) AND
                  (X_Resource_Type IS NULL)))
           AND (   (Recinfo.autocharge_type =  X_Autocharge_Type)
                OR (    (Recinfo.autocharge_type IS NULL)
                    AND (X_Autocharge_Type IS NULL)))
           AND (   (Recinfo.standard_rate_flag =  X_Standard_Rate_Flag)
                OR (    (Recinfo.standard_rate_flag IS NULL)
                    AND (X_Standard_Rate_Flag IS NULL)))
           AND (   (Recinfo.default_basis_type =  X_Default_Basis_Type)
                OR (    (Recinfo.default_basis_type IS NULL)
                    AND (X_Default_Basis_Type IS NULL)))
           AND (   (Recinfo.absorption_account =  X_Absorption_Account)
                OR (    (Recinfo.absorption_account IS NULL)
                    AND (X_Absorption_Account IS NULL)))
           AND (Recinfo.allow_costs_flag =  X_Allow_Costs_Flag)
           AND (   (Recinfo.rate_variance_account =  X_Rate_Variance_Account)
                OR (    (Recinfo.rate_variance_account IS NULL)
                    AND (X_Rate_Variance_Account IS NULL)))
           AND (   (Recinfo.expenditure_type =  X_Expenditure_Type)
                OR (    (Recinfo.expenditure_type IS NULL)
                    AND (X_Expenditure_Type IS NULL)))
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
           AND (   (Recinfo.REQUEST_ID = X_REQUEST_ID)
                OR (    (Recinfo.REQUEST_ID IS NULL)
                    AND (X_REQUEST_ID IS NULL)))
           AND (   (Recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
                OR (    (Recinfo.PROGRAM_APPLICATION_ID IS NULL)
                    AND (X_PROGRAM_APPLICATION_ID IS NULL)))
           AND (   (Recinfo.PROGRAM_ID = X_PROGRAM_ID)
                OR (    (Recinfo.PROGRAM_ID IS NULL)
                    AND (X_PROGRAM_ID IS NULL)))
           AND (   (Recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE)
                OR (    (Recinfo.PROGRAM_UPDATE_DATE IS NULL)
                    AND (X_PROGRAM_UPDATE_DATE IS NULL)))
           AND (   (Recinfo.BATCHABLE = X_BATCHABLE)
                OR (    (Recinfo.BATCHABLE IS NULL)
                    AND (X_BATCHABLE IS NULL)))
           AND (   (Recinfo.MIN_BATCH_CAPACITY = X_MIN_BATCH_CAPACITY)
                OR (    (Recinfo.MIN_BATCH_CAPACITY IS NULL)
                    AND (X_MIN_BATCH_CAPACITY IS NULL)))
           AND (   (Recinfo.MAX_BATCH_CAPACITY = X_MAX_BATCH_CAPACITY)
                OR (    (Recinfo.MAX_BATCH_CAPACITY IS NULL)
                    AND (X_MAX_BATCH_CAPACITY IS NULL)))
           AND (   (Recinfo.BATCH_CAPACITY_UOM = X_BATCH_CAPACITY_UOM)
                OR (    (Recinfo.BATCH_CAPACITY_UOM IS NULL)
                    AND (X_BATCH_CAPACITY_UOM IS NULL)))
           AND (   (Recinfo.BATCH_WINDOW = X_BATCH_WINDOW)
                OR (    (Recinfo.BATCH_WINDOW IS NULL)
                    AND (X_BATCH_WINDOW IS NULL)))
           AND (   (Recinfo.BATCH_WINDOW_UOM = X_BATCH_WINDOW_UOM)
                OR (    (Recinfo.BATCH_WINDOW_UOM IS NULL)
                    AND (X_BATCH_WINDOW_UOM IS NULL)))
           AND (   (Recinfo.COMPETENCE_ID = X_COMPETENCE_ID)
                OR (    (Recinfo.COMPETENCE_ID IS NULL)
                    AND (X_COMPETENCE_ID IS NULL)))
           AND (   (Recinfo.RATING_LEVEL_ID = X_RATING_LEVEL_ID)
                OR (    (Recinfo.RATING_LEVEL_ID IS NULL)
                    AND (X_RATING_LEVEL_ID IS NULL)))
           AND (   (Recinfo.QUALIFICATION_TYPE_ID = X_QUALIFICATION_TYPE_ID)
                OR (    (Recinfo.QUALIFICATION_TYPE_ID IS NULL)
                    AND (X_QUALIFICATION_TYPE_ID IS NULL)))
           AND (   (Recinfo.BILLABLE_ITEM_ID = X_BILLABLE_ITEM_ID)
                OR (    (Recinfo.BILLABLE_ITEM_ID IS NULL)
                    AND (X_BILLABLE_ITEM_ID IS NULL)))
          AND (   (Recinfo.SUPPLY_SUBINVENTORY = X_SUPPLY_SUBINVENTORY)
                OR (    (Recinfo.SUPPLY_SUBINVENTORY IS NULL)
                    AND (X_SUPPLY_SUBINVENTORY IS NULL)))
         AND (   (Recinfo.SUPPLY_LOCATOR_ID = X_SUPPLY_LOCATOR_ID)
                OR (    (Recinfo.SUPPLY_LOCATOR_ID IS NULL)
                    AND (X_SUPPLY_LOCATOR_ID IS NULL)))
         AND (    (Recinfo.BATCHING_PENALTY = X_BATCHING_PENALTY)                  --APS Enhancement for Routings
	        OR(    (Recinfo.BATCHING_PENALTY IS NULL)
		    AND(X_BATCHING_PENALTY IS NULL)))



      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Id                    NUMBER,
                       X_Resource_Code                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Disable_Date                   DATE,
                       X_Cost_Element_Id                NUMBER,
                       X_Purchase_Item_Id               NUMBER,
                       X_Cost_Code_Type                 NUMBER,
                       X_Functional_Currency_Flag       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Default_Activity_Id            NUMBER,
                       X_Resource_Type                  NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Default_Basis_Type             NUMBER,
                       X_Absorption_Account             NUMBER,
                       X_Allow_Costs_Flag               NUMBER,
                       X_Rate_Variance_Account          NUMBER,
                       X_Expenditure_Type               VARCHAR2,
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
                       X_REQUEST_ID                     NUMBER := NULL,
                       X_PROGRAM_APPLICATION_ID         NUMBER := NULL,
                       X_PROGRAM_ID                     NUMBER := NULL,
                       X_PROGRAM_UPDATE_DATE            DATE   := NULL
                      )
  IS
  BEGIN
           Update_Row(X_Rowid               => X_Rowid,
                       X_Resource_Id        => X_Resource_Id,
                       X_Resource_Code      => X_Resource_Code,
                       X_Organization_Id    => X_Organization_Id,
                       X_Last_Update_Date   => X_Last_Update_Date,
                       X_Last_Updated_By    => X_Last_Updated_By,
                       X_Last_Update_Login  => X_Last_Update_Login,
                       X_Description        => X_Description,
                       X_Disable_Date       => X_Disable_Date,
                       X_Cost_Element_Id    => X_Cost_Element_Id,
                       X_Purchase_Item_Id   => X_Purchase_Item_Id,
                       X_Cost_Code_Type     => X_Cost_Code_Type,
                       X_Functional_Currency_Flag  => X_Functional_Currency_Flag,
                       X_Unit_Of_Measure       => X_Unit_Of_Measure,
                       X_Default_Activity_Id   => X_Default_Activity_Id,
                       X_Resource_Type         => X_Resource_Type,
                       X_Autocharge_Type       => X_Autocharge_Type,
                       X_Standard_Rate_Flag    => X_Standard_Rate_Flag,
                       X_Default_Basis_Type    => X_Default_Basis_Type,
                       X_Absorption_Account    => X_Absorption_Account,
                       X_Allow_Costs_Flag      => X_Allow_Costs_Flag,
                       X_Rate_Variance_Account => X_Rate_Variance_Account,
                       X_Expenditure_Type      => X_Expenditure_Type,
                       X_Attribute_Category    => X_Attribute_Category,
                       X_Attribute1     => X_Attribute1,
                       X_Attribute2     => X_Attribute2,
                       X_Attribute3     => X_Attribute3,
                       X_Attribute4     => X_Attribute4,
                       X_Attribute5     => X_Attribute5,
                       X_Attribute6     => X_Attribute6,
                       X_Attribute7     => X_Attribute7,
                       X_Attribute8     => X_Attribute8,
                       X_Attribute9     => X_Attribute9,
                       X_Attribute10    => X_Attribute10,
                       X_Attribute11    => X_Attribute11,
                       X_Attribute12    => X_Attribute12,
                       X_Attribute13    => X_Attribute13,
                       X_Attribute14    => X_Attribute14,
                       X_Attribute15    => X_Attribute15,
                       X_REQUEST_ID     =>X_REQUEST_ID,
                       X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                       X_PROGRAM_ID          => X_PROGRAM_ID,
                       X_PROGRAM_UPDATE_DATE =>X_PROGRAM_UPDATE_DATE,
                       X_BATCHABLE           =>NULL,
                       X_MIN_BATCH_CAPACITY  =>NULL,
                       X_MAX_BATCH_CAPACITY  =>NULL,
                       X_BATCH_CAPACITY_UOM  =>NULL,
                       X_BATCH_WINDOW        =>NULL,
                       X_BATCH_WINDOW_UOM    =>NULL,
                       X_COMPETENCE_ID       =>NULL,
                       X_RATING_LEVEL_ID     =>NULL,
                       X_QUALIFICATION_TYPE_ID => NULL,
                       X_BILLABLE_ITEM_ID => NULL,
                       X_SUPPLY_SUBINVENTORY => NULL,
                       X_SUPPLY_LOCATOR_ID   => NULL,
		       X_BATCHING_PENALTY   => NULL);                       --APS Enhancement for Routings

  END;
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Id                    NUMBER,
                       X_Resource_Code                  VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Disable_Date                   DATE,
                       X_Cost_Element_Id                NUMBER,
                       X_Purchase_Item_Id               NUMBER,
                       X_Cost_Code_Type                 NUMBER,
                       X_Functional_Currency_Flag       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Default_Activity_Id            NUMBER,
                       X_Resource_Type                  NUMBER,
                       X_Autocharge_Type                NUMBER,
                       X_Standard_Rate_Flag             NUMBER,
                       X_Default_Basis_Type             NUMBER,
                       X_Absorption_Account             NUMBER,
                       X_Allow_Costs_Flag               NUMBER,
                       X_Rate_Variance_Account          NUMBER,
                       X_Expenditure_Type               VARCHAR2,
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
                       X_REQUEST_ID                     NUMBER := NULL,
                       X_PROGRAM_APPLICATION_ID         NUMBER := NULL,
                       X_PROGRAM_ID                     NUMBER := NULL,
                       X_PROGRAM_UPDATE_DATE            DATE   := NULL,
                       X_BATCHABLE                      NUMBER ,
                       X_MIN_BATCH_CAPACITY             NUMBER ,
                       X_MAX_BATCH_CAPACITY             NUMBER ,
                       X_BATCH_CAPACITY_UOM             VARCHAR2 ,
                       X_BATCH_WINDOW                   NUMBER ,
                       X_BATCH_WINDOW_UOM               VARCHAR2,
                       X_COMPETENCE_ID                  NUMBER := NULL,
                       X_RATING_LEVEL_ID                NUMBER := NULL,
                       X_QUALIFICATION_TYPE_ID          NUMBER := NULL,
                       X_BILLABLE_ITEM_ID		NUMBER := NULL,
                       X_SUPPLY_SUBINVENTORY            VARCHAR2,
                       X_SUPPLY_LOCATOR_ID             NUMBER :=NULL,
		       X_BATCHING_PENALTY               NUMBER := NULL          --APS Enhancement for Routings
  ) IS
  BEGIN
    UPDATE BOM_RESOURCES
    SET
       resource_id                     =     X_Resource_Id,
       resource_code                   =     X_Resource_Code,
       organization_id                 =     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       description                     =     X_Description,
       disable_date                    =     X_Disable_Date,
       cost_element_id                 =     X_Cost_Element_Id,
       purchase_item_id                =     X_Purchase_Item_Id,
       cost_code_type                  =     X_Cost_Code_Type,
       functional_currency_flag        =     X_Functional_Currency_Flag,
       unit_of_measure                 =     X_Unit_Of_Measure,
       default_activity_id             =     X_Default_Activity_Id,
       resource_type                   =     X_Resource_Type,
       autocharge_type                 =     X_Autocharge_Type,
       standard_rate_flag              =     X_Standard_Rate_Flag,
       default_basis_type              =     X_Default_Basis_Type,
       absorption_account              =     X_Absorption_Account,
       allow_costs_flag                =     X_Allow_Costs_Flag,
       rate_variance_account           =     X_Rate_Variance_Account,
       expenditure_type	               =     X_Expenditure_Type,
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
       request_id                      =     x_request_id,
       program_application_id	       =     x_program_application_id,
       program_id                      =     x_program_id,
       program_update_date             =     x_program_update_date,
       batchable                       =     x_batchable,
       min_batch_capacity              =     x_min_batch_capacity,
       max_batch_capacity              =     x_max_batch_capacity,
       batch_capacity_uom              =     x_batch_capacity_uom,
       batch_window                    =     x_batch_window,
       batch_window_uom                =     x_batch_window_uom,
       competence_id                   =     x_competence_id,
       rating_level_id                 =     x_rating_level_id,
       qualification_type_id           =     x_qualification_type_id,
       billable_item_id                =     x_billable_item_id,
       supply_subinventory     =   x_supply_subinventory,
       supply_locator_id  = x_supply_locator_id,
       batching_penalty                = x_batching_penalty                  --APS Enhancement for Routings

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Check_Unique(X_Rowid VARCHAR2,
                        X_Resource_Code VARCHAR2,
                        X_Organization_Id NUMBER,
                        X_unique_flag IN OUT NOCOPY NUMBER) IS
  dummy NUMBER;
  BEGIN
    SELECT 1 INTO dummy FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM BOM_RESOURCES
       WHERE Organization_Id = X_Organization_Id
       AND Resource_Code  = X_Resource_Code
       AND ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
      );
    X_unique_flag := 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_unique_flag := 0;
END Check_Unique;

FUNCTION Get_UOM_From_GL_Sets_Of_Books(X_Organization_Id NUMBER) RETURN VARCHAR2 IS
  currency_code VARCHAR2(3);
  book_id NUMBER;
BEGIN
  SELECT SET_OF_BOOKS_ID INTO book_id FROM ORG_ORGANIZATION_DEFINITIONS
     WHERE ORGANIZATION_ID = X_Organization_Id;
  SELECT SUBSTR(CURRENCY_CODE,1,3) INTO currency_code FROM GL_SETS_OF_BOOKS
     WHERE SET_OF_BOOKS_ID = book_id;
  RETURN(currency_code);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('BOM', 'MFG_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'CURRENCY CODE-CAP', TRUE);
      APP_EXCEPTION.RAISE_EXCEPTION;
END Get_UOM_From_GL_Sets_Of_Books;

FUNCTION Check_Valid_UOM(X_Unit_Of_Measure VARCHAR2) RETURN NUMBER IS
  uom_value NUMBER;
BEGIN
  SELECT COUNT(*) INTO uom_value FROM MTL_UNITS_OF_MEASURE
    WHERE UOM_CODE = SUBSTR(X_Unit_Of_Measure, 1, 3)
      AND NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE;
  RETURN(uom_value);
END Check_Valid_UOM;

END BOM_RESOURCES_PKG;

/
