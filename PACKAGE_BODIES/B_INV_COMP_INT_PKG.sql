--------------------------------------------------------
--  DDL for Package Body B_INV_COMP_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."B_INV_COMP_INT_PKG" as
/* $Header: bompicib.pls 120.2.12010000.2 2009/11/06 10:42:26 ybabulal ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Operation_Seq_Num              NUMBER,
                       X_Component_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Num                       NUMBER,
                       X_Basis_Type			NUMBER,
                       X_Component_Quantity             NUMBER,
                       X_Component_Yield_Factor         NUMBER,
                       X_Disable_Date                   DATE,
                       X_To_End_Item_Unit_Number        VARCHAR2,
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
                       X_Planning_Factor                NUMBER,
                       X_Quantity_Related               NUMBER,
                       X_So_Basis                       NUMBER,
                       X_Optional                       NUMBER,
                       X_Mutually_Exclusive_Options     NUMBER,
                       X_Include_In_Cost_Rollup         NUMBER,
                       X_Check_Atp                      NUMBER,
                       X_Shipping_Allowed               NUMBER,
                       X_Required_To_Ship               NUMBER,
                       X_Required_For_Revenue           NUMBER,
                       X_Include_On_Ship_Docs           NUMBER,
                       X_Include_On_Bill_Docs           NUMBER,
                       X_Low_Quantity                   NUMBER,
                       X_High_Quantity                  NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Old_Component_Sequence_Id      NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Wip_Supply_Type                NUMBER,
                       X_Supply_Subinventory            VARCHAR2,
                       X_Supply_Locator_Id              NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Cost_Factor                    NUMBER
  ) IS

-- This table has no primary key

l_Basis_Type NUMBER;        -- 5214239

    CURSOR C IS SELECT rowid FROM BOM_INVENTORY_COMPS_INTERFACE
                 WHERE component_sequence_id = X_Component_Sequence_Id;

   BEGIN

      IF  (X_Basis_Type <> 2) THEN                -- 5214239
           l_Basis_Type := FND_API.G_MISS_NUM;
       ELSE l_Basis_Type := X_Basis_Type;
     END IF;

       INSERT INTO BOM_INVENTORY_COMPS_INTERFACE(
              operation_seq_num,
              component_item_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              item_num,
              basis_type,
              component_quantity,
              component_yield_factor,
              disable_date,
              to_end_item_unit_number,
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
              planning_factor,
              quantity_related,
              so_basis,
              optional,
              mutually_exclusive_options,
              include_in_cost_rollup,
              check_atp,
              shipping_allowed,
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              acd_type,
              old_component_sequence_id,
              component_sequence_id,
              wip_supply_type,
              supply_subinventory,
              supply_locator_id,
              revised_item_sequence_id,
              cost_factor
             ) VALUES (
              X_Operation_Seq_Num,
              X_Component_Item_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Item_Num,
              l_Basis_Type,        -- 5214239   X_Basis_Type,
              X_Component_Quantity,
              X_Component_Yield_Factor,
              X_Disable_Date,
              X_To_End_Item_Unit_Number,
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
              X_Planning_Factor,
              X_Quantity_Related,
              X_So_Basis,
              X_Optional,
              X_Mutually_Exclusive_Options,
              X_Include_In_Cost_Rollup,
              X_Check_Atp,
              X_Shipping_Allowed,
              X_Required_To_Ship,
              X_Required_For_Revenue,
              X_Include_On_Ship_Docs,
              X_Include_On_Bill_Docs,
              X_Low_Quantity,
              X_High_Quantity,
              X_Acd_Type,
              X_Old_Component_Sequence_Id,
              X_Component_Sequence_Id,
              X_Wip_Supply_Type,
              X_Supply_Subinventory,
              X_Supply_Locator_Id,
              X_Revised_Item_Sequence_Id,
              X_Cost_Factor
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(  X_Rowid                          VARCHAR2,
                       X_Operation_Seq_Num              NUMBER,
                       X_Component_Item_Id              NUMBER,
                       X_Item_Num                       NUMBER,
                       X_Basis_Type			NUMBER,
                       X_Component_Quantity             NUMBER,
                       X_Component_Yield_Factor         NUMBER,
                       X_Disable_Date                   DATE,
                       X_To_End_Item_Unit_Number        VARCHAR2,
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
                       X_Planning_Factor                NUMBER,
                       X_Quantity_Related               NUMBER,
                       X_So_Basis                       NUMBER,
                       X_Optional                       NUMBER,
                       X_Mutually_Exclusive_Options     NUMBER,
                       X_Include_In_Cost_Rollup         NUMBER,
                       X_Check_Atp                      NUMBER,
                       X_Shipping_Allowed               NUMBER,
                       X_Required_To_Ship               NUMBER,
                       X_Required_For_Revenue           NUMBER,
                       X_Include_On_Ship_Docs           NUMBER,
                       X_Include_On_Bill_Docs           NUMBER,
                       X_Low_Quantity                   NUMBER,
                       X_High_Quantity                  NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Old_Component_Sequence_Id      NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Wip_Supply_Type                NUMBER,
                       X_Supply_Subinventory            VARCHAR2,
                       X_Supply_Locator_Id              NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Cost_Factor                    NUMBER
  ) IS
    CURSOR C IS
        SELECT Operation_Seq_Num,
               Component_Item_Id,
               Item_Num,
               Decode(basis_type,FND_API.G_MISS_NUM,1,basis_type) basis_type,  /* bug 9079784*/
               Component_Quantity,
               Component_Yield_Factor,
               Disable_Date,
               To_End_Item_Unit_Number,
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
               Attribute15,
               Planning_Factor,
               Quantity_Related,
               So_Basis,
               Optional,
               Mutually_Exclusive_Options,
               Include_In_Cost_Rollup,
               Check_Atp,
               Shipping_Allowed,
               Required_To_Ship,
               Required_For_Revenue,
               Include_On_Ship_Docs,
               Include_On_Bill_Docs,
               Low_Quantity,
               High_Quantity,
               Acd_Type,
               Old_Component_Sequence_Id,
               Component_Sequence_Id,
               Wip_Supply_Type,
               Supply_Subinventory,
               Supply_Locator_Id,
               Revised_Item_Sequence_Id,
               Cost_Factor
        FROM   bom_inventory_comps_interface
        WHERE  rowid = X_Rowid
        FOR UPDATE OF Acd_Type NOWAIT;
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
               (   (Recinfo.operation_seq_num =  X_Operation_Seq_Num)
                OR (    (Recinfo.operation_seq_num IS NULL)
                    AND (X_Operation_Seq_Num IS NULL)))
           AND (   (Recinfo.component_item_id =  X_Component_Item_Id)
                OR (    (Recinfo.component_item_id IS NULL)
                    AND (X_Component_Item_Id IS NULL)))
           AND (   (Recinfo.item_num =  X_Item_Num)
                OR (    (Recinfo.item_num IS NULL)
                    AND (X_Item_Num IS NULL)))
           AND (   (Recinfo.basis_type=  X_Basis_Type)
                OR (    (Recinfo.basis_type IS NULL)
                    AND (X_basis_type IS NULL)))
           AND (   (Recinfo.component_quantity =  X_Component_Quantity)
                OR (    (Recinfo.component_quantity IS NULL)
                    AND (X_Component_Quantity IS NULL)))
           AND (   (Recinfo.component_yield_factor =  X_Component_Yield_Factor)
                OR (    (Recinfo.component_yield_factor IS NULL)
                    AND (X_Component_Yield_Factor IS NULL)))
           AND (   (Recinfo.disable_date =  X_Disable_Date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_Disable_Date IS NULL)))
           AND (   (Recinfo.to_end_item_unit_number =  X_To_End_Item_Unit_Number)
                OR (    (Recinfo.to_end_item_unit_number IS NULL)
                    AND (X_To_End_Item_Unit_Number IS NULL)))
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
           AND (   (Recinfo.planning_factor =  X_Planning_Factor)
                OR (    (Recinfo.planning_factor IS NULL)
                    AND (X_Planning_Factor IS NULL)))
           AND (   (Recinfo.quantity_related =  X_Quantity_Related)
                OR (    (Recinfo.quantity_related IS NULL)
                    AND (X_Quantity_Related IS NULL)))
           AND (   (Recinfo.so_basis =  X_So_Basis)
                OR (    (Recinfo.so_basis IS NULL)
                    AND (X_So_Basis IS NULL)))
           AND (   (Recinfo.optional =  X_Optional)
                OR (    (Recinfo.optional IS NULL)
                    AND (X_Optional IS NULL)))
           AND (   (Recinfo.mutually_exclusive_options =  X_Mutually_Exclusive_Options)
                OR (    (Recinfo.mutually_exclusive_options IS NULL)
                    AND (X_Mutually_Exclusive_Options IS NULL)))
           AND (   (Recinfo.include_in_cost_rollup =  X_Include_In_Cost_Rollup)
                OR (    (Recinfo.include_in_cost_rollup IS NULL)
                    AND (X_Include_In_Cost_Rollup IS NULL)))
           AND (   (Recinfo.check_atp =  X_Check_Atp)
                OR (    (Recinfo.check_atp IS NULL)
                    AND (X_Check_Atp IS NULL)))
           AND (   (Recinfo.shipping_allowed =  X_Shipping_Allowed)
                OR (    (Recinfo.shipping_allowed IS NULL)
                    AND (X_Shipping_Allowed IS NULL)))
           AND (   (Recinfo.required_to_ship =  X_Required_To_Ship)
                OR (    (Recinfo.required_to_ship IS NULL)
                    AND (X_Required_To_Ship IS NULL)))
           AND (   (Recinfo.required_for_revenue =  X_Required_For_Revenue)
                OR (    (Recinfo.required_for_revenue IS NULL)
                    AND (X_Required_For_Revenue IS NULL)))
           AND (   (Recinfo.include_on_ship_docs =  X_Include_On_Ship_Docs)
                OR (    (Recinfo.include_on_ship_docs IS NULL)
                    AND (X_Include_On_Ship_Docs IS NULL)))
           AND (   (Recinfo.include_on_bill_docs =  X_Include_On_Bill_Docs)
                OR (    (Recinfo.include_on_bill_docs IS NULL)
                    AND (X_Include_On_Bill_Docs IS NULL)))
           AND (   (Recinfo.low_quantity =  X_Low_Quantity)
                OR (    (Recinfo.low_quantity IS NULL)
                    AND (X_Low_Quantity IS NULL)))
           AND (   (Recinfo.high_quantity =  X_High_Quantity)
                OR (    (Recinfo.high_quantity IS NULL)
                    AND (X_High_Quantity IS NULL)))
           AND (   (Recinfo.acd_type =  X_Acd_Type)
                OR (    (Recinfo.acd_type IS NULL)
                    AND (X_Acd_Type IS NULL)))
           AND (   (Recinfo.old_component_sequence_id =  X_Old_Component_Sequence_Id)
                OR (    (Recinfo.old_component_sequence_id IS NULL)
                    AND (X_Old_Component_Sequence_Id IS NULL)))
           AND (   (Recinfo.component_sequence_id =  X_Component_Sequence_Id)
                OR (    (Recinfo.component_sequence_id IS NULL)
                    AND (X_Component_Sequence_Id IS NULL)))
           AND (   (Recinfo.wip_supply_type =  X_Wip_Supply_Type)
                OR (    (Recinfo.wip_supply_type IS NULL)
                    AND (X_Wip_Supply_Type IS NULL)))
           AND (   (Recinfo.supply_subinventory =  X_Supply_Subinventory)
                OR (    (Recinfo.supply_subinventory IS NULL)
                    AND (X_Supply_Subinventory IS NULL)))
           AND (   (Recinfo.supply_locator_id =  X_Supply_Locator_Id)
                OR (    (Recinfo.supply_locator_id IS NULL)
                    AND (X_Supply_Locator_Id IS NULL)))
           AND (   (Recinfo.revised_item_sequence_id =  X_Revised_Item_Sequence_Id)
                OR (    (Recinfo.revised_item_sequence_id IS NULL)
                    AND (X_Revised_Item_Sequence_Id IS NULL)))
           AND (   (Recinfo.cost_factor =  X_Cost_Factor)
                OR (    (Recinfo.cost_factor IS NULL)
                    AND (X_Cost_Factor IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Operation_Seq_Num              NUMBER,
                       X_Component_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Num                       NUMBER,
                       X_Basis_Type 			NUMBER,
                       X_Component_Quantity             NUMBER,
                       X_Component_Yield_Factor         NUMBER,
                       X_Disable_Date                   DATE,
                       X_To_End_Item_Unit_Number        VARCHAR2,
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
                       X_Planning_Factor                NUMBER,
                       X_Quantity_Related               NUMBER,
                       X_So_Basis                       NUMBER,
                       X_Optional                       NUMBER,
                       X_Mutually_Exclusive_Options     NUMBER,
                       X_Include_In_Cost_Rollup         NUMBER,
                       X_Check_Atp                      NUMBER,
                       X_Shipping_Allowed               NUMBER,
                       X_Required_To_Ship               NUMBER,
                       X_Required_For_Revenue           NUMBER,
                       X_Include_On_Ship_Docs           NUMBER,
                       X_Include_On_Bill_Docs           NUMBER,
                       X_Low_Quantity                   NUMBER,
                       X_High_Quantity                  NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Old_Component_Sequence_Id      NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Wip_Supply_Type                NUMBER,
                       X_Supply_Subinventory            VARCHAR2,
                       X_Supply_Locator_Id              NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Cost_Factor                    NUMBER
  ) IS
  l_Basis_Type NUMBER;    -- 5214239

  BEGIN
        IF  (X_Basis_Type <> 2) THEN                -- 5214239
           l_Basis_Type := FND_API.G_MISS_NUM;
        ELSE l_Basis_Type := X_Basis_Type;
        END IF;

    UPDATE BOM_INVENTORY_COMPS_INTERFACE
    SET
       operation_seq_num               =     X_Operation_Seq_Num,
       component_item_id               =     X_Component_Item_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       item_num                        =     X_Item_Num,
       basis_type  		       =     l_Basis_Type,      --5214239
       component_quantity              =     X_Component_Quantity,
       component_yield_factor          =     X_Component_Yield_Factor,
       disable_date                    =     X_Disable_Date,
       to_end_item_unit_number         =     X_To_End_Item_Unit_Number,
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
       planning_factor                 =     X_Planning_Factor,
       quantity_related                =     X_Quantity_Related,
       so_basis                        =     X_So_Basis,
       optional                        =     X_Optional,
       mutually_exclusive_options      =     X_Mutually_Exclusive_Options,
       include_in_cost_rollup          =     X_Include_In_Cost_Rollup,
       check_atp                       =     X_Check_Atp,
       shipping_allowed                =     X_Shipping_Allowed,
       required_to_ship                =     X_Required_To_Ship,
       required_for_revenue            =     X_Required_For_Revenue,
       include_on_ship_docs            =     X_Include_On_Ship_Docs,
       include_on_bill_docs            =     X_Include_On_Bill_Docs,
       low_quantity                    =     X_Low_Quantity,
       high_quantity                   =     X_High_Quantity,
       acd_type                        =     X_Acd_Type,
       old_component_sequence_id       =     X_Old_Component_Sequence_Id,
       component_sequence_id           =     X_Component_Sequence_Id,
       wip_supply_type                 =     X_Wip_Supply_Type,
       supply_subinventory             =     X_Supply_Subinventory,
       supply_locator_id               =     X_Supply_Locator_Id,
       revised_item_sequence_id        =     X_Revised_Item_Sequence_Id,
       cost_factor                     =     X_Cost_Factor
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM BOM_INVENTORY_COMPS_INTERFACE
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END B_INV_COMP_INT_PKG;

/
