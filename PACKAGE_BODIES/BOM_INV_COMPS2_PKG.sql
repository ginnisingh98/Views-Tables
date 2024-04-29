--------------------------------------------------------
--  DDL for Package Body BOM_INV_COMPS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_INV_COMPS2_PKG" as
/* $Header: bompic2b.pls 120.6 2006/06/11 19:30:30 seradhak noship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Operation_Seq_Num                NUMBER,
                     X_Component_Item_Id                NUMBER,
                     X_Item_Num                         NUMBER,
                     X_Component_Quantity               NUMBER,
                     X_Component_Yield_Factor           NUMBER,
                     X_Component_Remarks                VARCHAR2,
                     X_Effectivity_Date                 DATE,
                     X_Change_Notice                    VARCHAR2,
                     X_Implementation_Date              DATE,
                     X_Disable_Date                     DATE,
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
                     X_Planning_Factor                  NUMBER,
                     X_Quantity_Related                 NUMBER,
                     X_So_Basis                         NUMBER,
                     X_Optional                         NUMBER,
                     X_Mutually_Exclusive_Options       NUMBER,
                     X_Include_In_Cost_Rollup           NUMBER,
                     X_Check_Atp                        NUMBER,
                     X_Required_To_Ship                 NUMBER,
                     X_Required_For_Revenue             NUMBER,
                     X_Include_On_Ship_Docs             NUMBER,
                     X_Include_On_Bill_Docs             NUMBER,
                     X_Low_Quantity                     NUMBER,
                     X_High_Quantity                    NUMBER,
                     X_Acd_Type                         NUMBER,
                     X_Old_Component_Sequence_Id        NUMBER,
                     X_Component_Sequence_Id            NUMBER,
                     X_Bill_Sequence_Id                 NUMBER,
                     X_Wip_Supply_Type                  NUMBER,
                     X_Pick_Components                  NUMBER,
                     X_Supply_Subinventory              VARCHAR2,
                     X_Supply_Locator_Id                NUMBER,
                     X_Operation_Lead_Time_Percent      NUMBER,
                     X_Revised_Item_Sequence_Id         NUMBER,
                     X_Cost_Factor                      NUMBER,
                     X_Bom_Item_Type                    NUMBER,
                     X_From_Unit_Number                 VARCHAR2,
                     X_To_Unit_Number                   VARCHAR2,
                     X_Enforce_Int_Requirements         NUMBER DEFAULT NULL,
         X_Auto_Request_Material        VARCHAR2 DEFAULT NULL
         ,X_Suggested_Vendor_Name           VARCHAR2 DEFAULT NULL
         ,X_Vendor_Id                        NUMBER DEFAULT NULL
                     ,X_Unit_Price                       NUMBER DEFAULT NULL
                     , X_basis_type      NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   BOM_INVENTORY_COMPONENTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Component_Sequence_Id NOWAIT;
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
               (Recinfo.operation_seq_num =  X_Operation_Seq_Num)
           AND (Recinfo.component_item_id =  X_Component_Item_Id)
           AND (   (Recinfo.item_num =  X_Item_Num)
                OR (    (Recinfo.item_num IS NULL)
                    AND (X_Item_Num IS NULL)))
           AND (Recinfo.component_quantity =  X_Component_Quantity)
           AND (Recinfo.component_yield_factor =  X_Component_Yield_Factor)
           AND (   (Recinfo.component_remarks =  X_Component_Remarks)
                OR (    (Recinfo.component_remarks IS NULL)
                    AND (X_Component_Remarks IS NULL)))
           AND (Recinfo.effectivity_date =  X_Effectivity_Date)
           AND (   (Recinfo.change_notice =  X_Change_Notice)
                OR (    (Recinfo.change_notice IS NULL)
                    AND (X_Change_Notice IS NULL)))
           AND (   (Recinfo.implementation_date =  X_Implementation_Date)
                OR (    (Recinfo.implementation_date IS NULL)
                    AND (X_Implementation_Date IS NULL)))
           AND (   (Recinfo.disable_date =  X_Disable_Date)
                OR (    (Recinfo.disable_date IS NULL)
                    AND (X_Disable_Date IS NULL)))
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
           AND (Recinfo.planning_factor =  X_Planning_Factor)
           AND (Recinfo.quantity_related =  X_Quantity_Related)
           AND (   (Recinfo.so_basis =  X_So_Basis)
                OR (    (Recinfo.so_basis IS NULL)
                    AND (X_So_Basis IS NULL)))
           AND (   (Recinfo.optional =  X_Optional)
                OR (    (Recinfo.optional IS NULL)
                    AND (X_Optional IS NULL)))
           AND (   (Recinfo.mutually_exclusive_options =  X_Mutually_Exclusive_Options)
                OR (    (Recinfo.mutually_exclusive_options IS NULL)
                    AND (X_Mutually_Exclusive_Options IS NULL)))
           AND (Recinfo.include_in_cost_rollup =  X_Include_In_Cost_Rollup)
           AND (Recinfo.check_atp =  X_Check_Atp)
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
           AND (Recinfo.component_sequence_id =  X_Component_Sequence_Id)
           AND (Recinfo.bill_sequence_id =  X_Bill_Sequence_Id)
           AND (   (Recinfo.wip_supply_type =  X_Wip_Supply_Type)
                OR (    (Recinfo.wip_supply_type IS NULL)
                    AND (X_Wip_Supply_Type IS NULL)))
           AND (   (Recinfo.pick_components =  X_Pick_Components)
                OR (    (Recinfo.pick_components IS NULL)
                    AND (X_Pick_Components IS NULL)))
           AND (   (Recinfo.supply_subinventory =  X_Supply_Subinventory)
                OR (    (Recinfo.supply_subinventory IS NULL)
                    AND (X_Supply_Subinventory IS NULL)))
           AND (   (Recinfo.supply_locator_id =  X_Supply_Locator_Id)
                OR (    (Recinfo.supply_locator_id IS NULL)
                    AND (X_Supply_Locator_Id IS NULL)))
          AND (   (Recinfo.basis_type =  X_basis_type)
                OR (    (Recinfo.basis_type IS NULL)
                    AND (X_basis_type IS NULL)))
/* Fixed bug 666081. Operation_Lead_Time_Percent (OLTP) is not part of the
   view BOM_INVENTORY_COMPONENTS_V and is not selected from the base table in the
   form. So if the user copies a bill which has some values for OLTP, then this
   causes a lock_row error.

           AND (   (Recinfo.operation_lead_time_percent =  X_Operation_Lead_Time_Percent)
                OR (    (Recinfo.operation_lead_time_percent IS NULL)
                    AND (X_Operation_Lead_Time_Percent IS NULL)))
*/
           AND (   (Recinfo.revised_item_sequence_id =  X_Revised_Item_Sequence_Id)
                OR (    (Recinfo.revised_item_sequence_id IS NULL)
                    AND (X_Revised_Item_Sequence_Id IS NULL)))
           AND (   (Recinfo.cost_factor =  X_Cost_Factor)
                OR (    (Recinfo.cost_factor IS NULL)
                    AND (X_Cost_Factor IS NULL)))
           AND (   (Recinfo.bom_item_type =  X_Bom_Item_Type)
                OR (    (Recinfo.bom_item_type IS NULL)
                    AND (X_Bom_Item_Type IS NULL)))
           AND (   (Recinfo.from_end_item_unit_number =  X_From_Unit_Number)
                OR (    (Recinfo.from_end_item_unit_number IS NULL)
                    AND (X_From_Unit_Number IS NULL)))
           AND (   (Recinfo.to_end_item_unit_number =  X_To_Unit_Number)
                OR (    (Recinfo.to_end_item_unit_number IS NULL)
                    AND (X_To_Unit_Number IS NULL)))
           AND (   (Recinfo.enforce_int_requirements =  X_Enforce_Int_Requirements)
                OR (    (Recinfo.Enforce_Int_Requirements IS NULL)
                    AND (X_Enforce_Int_Requirements IS NULL)))
           AND (   (Recinfo.auto_request_material =  X_Auto_Request_Material)
                OR (    (Recinfo.Auto_Request_Material IS NULL)
                    AND (X_Auto_Request_Material IS NULL)))
     AND (   (Recinfo.suggested_vendor_name =  X_Suggested_Vendor_Name)
                OR (    (Recinfo.suggested_vendor_name IS NULL)
                    AND (X_Suggested_Vendor_Name IS NULL)))
           AND (   (Recinfo.vendor_id =  X_Vendor_Id)
                     OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.Unit_Price =  X_Unit_Price)
                     OR (    (Recinfo.Unit_Price IS NULL)
                    AND (X_Unit_Price IS NULL)))

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
                       X_Component_Quantity             NUMBER,
                       X_Component_Yield_Factor         NUMBER,
                       X_Component_Remarks              VARCHAR2,
                       X_Effectivity_Date               DATE,
                       X_Change_Notice                  VARCHAR2,
                       X_Implementation_Date            DATE,
                       X_Disable_Date                   DATE,
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
                       X_Required_To_Ship               NUMBER,
                       X_Required_For_Revenue           NUMBER,
                       X_Include_On_Ship_Docs           NUMBER,
                       X_Include_On_Bill_Docs           NUMBER,
                       X_Low_Quantity                   NUMBER,
                       X_High_Quantity                  NUMBER,
                       X_Acd_Type                       NUMBER,
                       X_Old_Component_Sequence_Id      NUMBER,
                       X_Component_Sequence_Id          NUMBER,
                       X_Bill_Sequence_Id               NUMBER,
                       X_Wip_Supply_Type                NUMBER,
                       X_Pick_Components                NUMBER,
                       X_Supply_Subinventory            VARCHAR2,
                       X_Supply_Locator_Id              NUMBER,
                       X_Operation_Lead_Time_Percent    NUMBER,
                       X_Revised_Item_Sequence_Id       NUMBER,
                       X_Cost_Factor                    NUMBER,
                       X_Bom_Item_Type                  NUMBER,
                       X_From_Unit_Number               VARCHAR2,
                       X_To_Unit_Number                 VARCHAR2,
                       X_Enforce_Int_Requirements       NUMBER DEFAULT NULL,
           X_Auto_Request_Material        VARCHAR2 DEFAULT NULL
           ,X_Suggested_Vendor_Name           VARCHAR2 DEFAULT NULL
           ,X_Vendor_Id                        NUMBER DEFAULT NULL
                       ,X_Unit_Price                       NUMBER DEFAULT NULL
                       ,X_basis_type      NUMBER DEFAULT NULL

  ) IS
      l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
      l_return_status VARCHAR2(10);
      l_organization_id number;         --4306013
      l_component_item_name VARCHAR2(240);     --4306013
      l_bill_sequence_id number;         --4306013

      org_id number;      --4306013
      comp_item_name VARCHAR2(240);   --4306013
      alt_bom_code varchar2(240);   --4306013
      ass_item_id NUMBER;     --4306013
      s_ass_comment varchar2(240);    --4306013
      l_created_by    NUMBER;
      l_creation_date DATE;

  BEGIN
    UPDATE BOM_INVENTORY_COMPONENTS
    SET
       operation_seq_num               =     X_Operation_Seq_Num,
       component_item_id               =     X_Component_Item_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       item_num                        =     X_Item_Num,
       component_quantity              =     X_Component_Quantity,
       component_yield_factor          =     X_Component_Yield_Factor,
       component_remarks               =     X_Component_Remarks,
       effectivity_date                =     X_Effectivity_Date,
       change_notice                   =     X_Change_Notice,
       implementation_date             =     X_Implementation_Date,
       disable_date                    =     X_Disable_Date,
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
       required_to_ship                =     X_Required_To_Ship,
       required_for_revenue            =     X_Required_For_Revenue,
       include_on_ship_docs            =     X_Include_On_Ship_Docs,
       include_on_bill_docs            =     X_Include_On_Bill_Docs,
       low_quantity                    =     X_Low_Quantity,
       high_quantity                   =     X_High_Quantity,
       acd_type                        =     X_Acd_Type,
       old_component_sequence_id       =     X_Old_Component_Sequence_Id,
       component_sequence_id           =     X_Component_Sequence_Id,
       bill_sequence_id                =     X_Bill_Sequence_Id,
       wip_supply_type                 =     X_Wip_Supply_Type,
       pick_components                 =     X_Pick_Components,
       supply_subinventory             =     X_Supply_Subinventory,
       supply_locator_id               =     X_Supply_Locator_Id,
       operation_lead_time_percent     =     X_Operation_Lead_Time_Percent,
       revised_item_sequence_id        =     X_Revised_Item_Sequence_Id,
       cost_factor                     =     X_Cost_Factor,
       bom_item_type                   =     X_Bom_Item_Type,
       from_end_item_unit_number       =     X_from_unit_number,
       to_end_item_unit_number         =     X_to_unit_number,
       enforce_int_requirements        =     X_Enforce_Int_Requirements,
       auto_request_material         =     X_Auto_Request_Material
       ,suggested_vendor_name        =     X_Suggested_Vendor_Name
       ,vendor_id          =     X_Vendor_Id
       ,unit_price           =     X_Unit_Price
       ,basis_type           =     X_basis_type
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    BOMPCMBM.Update_Related_Components( p_src_comp_seq_id => X_Component_Sequence_Id
                                      , x_Mesg_Token_Tbl => l_err_tbl
                                      , x_Return_Status => l_return_status
                                      );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
     app_exception.raise_exception;
   END IF;

    -- Raising Business event

    SELECT bbm.Organization_Id, bbm.alternate_bom_designator, bbm.assembly_item_id,
           bbm.specific_assembly_comment,creation_date,created_by
      INTO org_id, alt_bom_code, ass_item_id, s_ass_comment,l_creation_date,l_created_by
    FROM Bom_Bill_Of_Materials bbm
    WHERE bbm.Bill_Sequence_Id = X_Bill_Sequence_Id;

  Bom_Business_Event_PKG.Raise_Bill_Event
     (p_pk1_value => ass_item_id
      , p_pk2_value          => org_id
      , p_obj_name           => NULL
      , p_structure_name     => alt_bom_code
      , p_organization_id    => org_id
      , p_structure_comment  => s_ass_comment
      , p_Event_Load_Type => 'Single'
      , p_Event_Entity_Name => 'Component'
      , p_Event_Entity_Parent_Id  => X_Bill_Sequence_Id
      , p_Event_Name => Bom_Business_Event_PKG.G_STRUCTURE_MODIFIED_EVENT
      , p_last_update_date => X_Last_Update_Date
      , p_last_updated_by  => X_Last_Updated_By
      , p_creation_date    => l_creation_date
      , p_created_by       => l_created_by
      , p_last_update_login=> X_Last_Update_Login
      , p_component_seq_id => X_Component_Sequence_Id
      );
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM BOM_INVENTORY_COMPONENTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;


  END Delete_Row;

  FUNCTION POPULATE_INV_COMPS (X_Group_Id NUMBER,
                               X_Bill_Sequence_Id NUMBER,
                               X_Err_Text IN OUT NOCOPY VARCHAR2
                               ) RETURN NUMBER
  IS
  BEGIN
   INSERT INTO BOM_INVENTORY_COMPONENTS(
              operation_seq_num,
              component_item_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              item_num,
              component_quantity,
              component_yield_factor,
              effectivity_date,
              implementation_date,
              planning_factor,
              quantity_related,
              so_basis,
              optional,
              mutually_exclusive_options,
              include_in_cost_rollup,
              check_atp,
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              component_sequence_id,
              bill_sequence_id,
              wip_supply_type,
        supply_subinventory,
        supply_locator_id,
              pick_components,
              bom_item_type)
      SELECT  bce.OPERATION_SEQ_NUM,
              bce.COMPONENT_ITEM_ID,
              bce.LAST_UPDATE_DATE,
              bce.LAST_UPDATED_BY,
              bce.CREATION_DATE,
              bce.CREATED_BY,
              decode(bce.PLAN_LEVEL,0,10,bce.ITEM_NUM),
              bce.COMPONENT_QUANTITY,
              1, /* component_yield_factor */
              bce.EFFECTIVITY_DATE,
              sysdate,
              100, /* planning_factor */
              2, /* quantity_related */
              NVL(bce.SO_BASIS,2),
              NVL(bce.OPTIONAL,2),
              NVL(bce.MUTUALLY_EXCLUSIVE_OPTIONS,2),
              decode(msi.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
                     'Y', 1,
                     'N', 2,
                     2), /* include_in_cost_rollup */
              bce.CHECK_ATP,
              NVL(bce.REQUIRED_TO_SHIP,2),
              NVL(bce.REQUIRED_FOR_REVENUE,2),
              NVL(bce.INCLUDE_ON_SHIP_DOCS,2),
              NVL(bce.INCLUDE_ON_BILL_DOCS,2),
              bce.LOW_QUANTITY,
              bce.HIGH_QUANTITY,
              BOM_INVENTORY_COMPONENTS_S.nextval,
              X_BILL_SEQUENCE_ID,
              decode(bce.bom_item_type, 2, 6, 1, 6, 1, nvl(msi.wip_supply_type,1)), /* wip_supply_type */
        decode(bce.bom_item_type, 4, msi.wip_supply_subinventory,null),
        decode(bce.bom_item_type, 4, msi.wip_supply_locator_id,null),
              bce.PICK_COMPONENTS,
              bce.BOM_ITEM_TYPE
      FROM    MTL_SYSTEM_ITEMS msi,
              BOM_CONFIG_EXPLOSIONS bce
      WHERE   bce.group_id = X_group_id
      AND     bce.component_item_id = msi.inventory_item_id
      AND     bce.organization_id = msi.organization_id;

      -- Clean up table after a successful insert
      Delete from BOM_CONFIG_EXPLOSIONS
      where group_id = X_group_id;

      -- Returns success code
      Return 0;

  EXCEPTION
    WHEN OTHERS THEN
       x_err_text := 'BOM_INV_COMPS2_PKG.POPULATE_INV_COMPS():'||substr(SQLERRM,1,60);
       FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
       FND_MESSAGE.SET_TOKEN('ENTITY', x_err_text);
       APP_EXCEPTION.RAISE_EXCEPTION;
      return 1;  -- 1 indicates failure to calling package
  END POPULATE_INV_COMPS;

END BOM_INV_COMPS2_PKG;

/
