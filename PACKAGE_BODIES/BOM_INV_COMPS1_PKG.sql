--------------------------------------------------------
--  DDL for Package Body BOM_INV_COMPS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_INV_COMPS1_PKG" as
/* $Header: bompic1b.pls 120.6 2006/06/11 19:30:04 seradhak noship $ */

PROCEDURE Check_Overlap(X_Rowid       VARCHAR2,
            X_Bill_Sequence_Id    NUMBER,
            X_Component_Item_Id   NUMBER,
                        X_Operation_Seq_Num     NUMBER,
            X_Disable_Date                  DATE,
                        X_Effectivity_Date    DATE) IS
  dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM sys.dual
   WHERE NOT EXISTS
         (SELECT 1 FROM bom_inventory_components
           WHERE bill_sequence_id = X_Bill_Sequence_Id
             AND component_item_id = X_Component_Item_Id
             AND operation_seq_num = X_Operation_Seq_Num
             AND (X_Disable_Date IS NULL
                 OR (to_char(X_Disable_Date,'YYYY/MM/DD HH24:MI:SS') > to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS')))
             AND ((to_char(X_Effectivity_Date,'YYYY/MM/DD HH24:MI:SS') <  to_char(disable_date,'YYYY/MM/DD HH24:MI:SS'))
                 OR disable_date IS NULL)
             AND implementation_date IS NOT NULL
             AND NVL(ECO_FOR_PRODUCTION,2) = 2
             AND ((rowid <> X_Rowid) OR (X_Rowid IS NULL)));
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('BOM','BOM_COMP_OP_COMBINATION');
    app_exception.raise_exception;
END Check_Overlap;

PROCEDURE Check_Unit_Number_Overlap(X_Rowid     VARCHAR2,
            X_Bill_Sequence_Id    NUMBER,
            X_Component_Item_Id   NUMBER,
                        X_Operation_Seq_Num     NUMBER,
            X_From_Unit_Number              VARCHAR2,
                        X_To_Unit_Number    VARCHAR2) IS
  dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM sys.dual
   WHERE NOT EXISTS
         (SELECT 1 FROM bom_inventory_components
           WHERE bill_sequence_id = X_Bill_Sequence_Id
             AND component_item_id = X_Component_Item_Id
             AND operation_seq_num = X_Operation_Seq_Num
             AND (X_To_Unit_Number IS NULL
                 OR (X_To_Unit_Number >= from_end_item_unit_number))
             AND ((X_From_Unit_Number <=  to_end_item_unit_number)
                 OR to_end_item_unit_number IS NULL)
             AND implementation_date IS NOT NULL
             AND NVL(ECO_FOR_PRODUCTION,2) = 2
             AND disable_date is NULL
             AND ((rowid <> X_Rowid) OR (X_Rowid IS NULL)));
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('BOM','BOM_UNIT_OVERLAP');
    app_exception.raise_exception;
END Check_Unit_Number_Overlap;

PROCEDURE Check_Commons(X_Bill_Sequence_Id    NUMBER,
            X_Organization_Id   NUMBER,
      X_Component_Item_Id   NUMBER,
      X_Bill_or_Eco                   NUMBER DEFAULT 2) IS        --bug1517975
  dummy NUMBER;
  eng_items_allowed   number := 1;                      -- bug 1517975
  eng_items_for_mfg_ecos_flag varchar(3) := 'NO';       -- bug 1517975

BEGIN
-- Check if bill has cross-org commons
-- If so, make sure component exists in those other orgs
-- and the component does not violate the bill/comp matrix

-- bug 1517975
FND_PROFILE.GET('ENG:ALLOW_ENG_COMPS',eng_items_allowed);
if ((eng_items_allowed = 1) and (X_Bill_or_Eco = 2)) then
eng_items_for_mfg_ecos_flag := 'YES';
end if;

  SELECT 1 INTO dummy
    FROM bom_bill_of_materials bbom,
         mtl_system_items msi1
   WHERE bbom.source_bill_sequence_id = X_Bill_Sequence_Id
     AND bbom.organization_id <> X_Organization_Id
     AND msi1.inventory_item_id = bbom.assembly_item_id
     AND msi1.organization_id = bbom.organization_id
     AND NOT EXISTS (SELECT null
                       FROM mtl_system_items msi2
                      WHERE msi2.organization_id = bbom.organization_id
                        AND msi2.inventory_item_id = X_Component_Item_Id
                        --AND msi2.bom_enabled_flag = 'Y'
                        --Not a required condition.
                        AND ((bbom.assembly_type = 1 AND
            msi2.eng_item_flag='N')
                            OR (bbom.assembly_type = 2)
                             OR (eng_items_for_mfg_ecos_flag = 'YES'))      --bug1517975
                        AND msi2.inventory_item_id <> bbom.assembly_item_id
      AND ((msi1.bom_item_type = 1
            AND msi2.bom_item_type <> 3)
          OR (msi1.bom_item_type = 2
            AND msi2.bom_item_type <> 3)
          OR (msi1.bom_item_type = 3)
          OR (msi1.bom_item_type = 4
        AND (msi2.bom_item_type = 4
             OR (msi2.bom_item_type in (1,2)
           AND msi2.replenish_to_order_flag = 'Y'
           AND msi1.base_item_id is NOT NULL
           AND msi1.replenish_to_order_flag = 'Y'
          ))))
      AND (msi1.bom_item_type = 3
           OR msi1.pick_components_flag = 'Y'
           OR msi2.pick_components_flag = 'N')
      AND (msi1.bom_item_type = 3
           OR nvl(msi2.bom_item_type, 4) <> 2
           OR (msi2.bom_item_type = 2
               AND ((msi1.pick_components_flag = 'Y'
               AND msi2.pick_components_flag = 'Y')
             OR (msi1.replenish_to_order_flag = 'Y'
                 AND msi2.replenish_to_order_flag = 'Y'
           ))))
      AND NOT (msi1.bom_item_type = 4
         AND msi1.pick_components_flag = 'Y'
         AND msi2.bom_item_type = 4
         AND msi2.replenish_to_order_flag = 'Y')
      );
  fnd_message.set_name('INV','INV_NOT_VALID');
  fnd_message.set_token('ENTITY','Component item_CAP',TRUE);
  fnd_message.set_name('BOM','BOM_COMMON_OTHER_ORGS');
  app_exception.raise_exception;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN TOO_MANY_ROWS THEN
    fnd_message.set_name('INV','INV_NOT_VALID');
    fnd_message.set_token('ENTITY','Component item_CAP',TRUE);
    fnd_message.set_name('BOM','BOM_COMMON_OTHER_ORGS');
    app_exception.raise_exception;
END Check_Commons;


PROCEDURE Check_ATP(X_Organization_Id   NUMBER,
        X_Component_Item_Id   NUMBER,
                    X_ATP_Comps_Flag    VARCHAR2,
                    X_WIP_Supply_Type           NUMBER,
                    X_Replenish_To_Order_Flag   VARCHAR2,
                    X_Pick_Components_Flag      VARCHAR2) IS
  dummy NUMBER;
  l_atp_comps_flag  VARCHAR2(1);
  l_atp_flag    VARCHAR2(1);
BEGIN

  -- Starting with R11, the ATP_Flag can have additional values R and C
  -- apart from Y and N

  -- Starting with 11i, even ATP Components flag has additional values which are
  -- similar to ATP flag. To incorporate these values for multi-level ATP we also
  -- release the update allowed constraint on Check_ATP

        -- ATP Components flag for an item indicates whether an item's child components should be
        -- ATP checked. A component c1 (ATP Check = Material) can be on a subassembly that does not
        -- need to do atp check for components and hence has ATP Components of subassy is set to No. In
        -- current validation c1 cannot be added onto the subassy because we restrict that.

        -- We will now release the restriction on the ATP Check and ATP Components flag. This will allow the
        -- users to control what can and cannot be structured on a bill. If the item level attribute for a
        -- component is ATP Check = Yes, BOM will allow the user to turn it off at the component level.
        -- The default value will be copied from the item.

  null;
 /*
  SELECT atp_components_flag,
   atp_flag
    INTO l_atp_comps_flag,
   l_atp_flag
    FROM mtl_system_items msi
   WHERE inventory_item_id = X_Component_Item_Id
     AND organization_id = X_Organization_Id;

     IF(( X_Atp_Comps_Flag = 'N' AND
    (  NVL(X_Wip_Supply_Type,1) = 6 OR
       X_Replenish_To_Order_Flag = 'Y' OR
       X_Pick_Components_Flag     = 'Y'
     )
   ) AND
   (  l_atp_comps_flag IN ('Y','C', 'R', 'N') OR l_atp_flag IN ('Y', 'R', 'C','N' )
    )
  ) OR
  X_Atp_Comps_flag IN ('Y','R','C')
      THEN
    -- Do nothing since this is permitted
   -- If the Assembly item is Phantom or an ATO or PTO and has ATP Components as 'N'
   -- Even then we will allow ATP components
   NULL;
      ELSIF (x_atp_comps_flag = 'N' AND
    ( l_atp_comps_flag = 'N' AND l_atp_flag = 'N')
      )
      THEN
    -- Even in this case do nothing since both the flag are N and hence is
    -- is a valid combination

    NULL;
      ELSE
    fnd_message.set_name('BOM','BOM_INVALID_ATP');
    app_exception.raise_exception;
      END IF;
    */

END Check_ATP;


PROCEDURE Check_Unique(X_Rowid            VARCHAR2,
           X_Bill_Sequence_Id NUMBER,
                       X_Component_Item_id  NUMBER,
                       X_Operation_Seq_Num      NUMBER,
                       X_Effectivity_Date       DATE,
           X_bill_or_eco    NUMBER) IS
   dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM dual WHERE NOT EXISTS
    (SELECT 1 from bom_inventory_components
      WHERE bill_sequence_id = X_Bill_Sequence_Id
        AND component_item_id = X_Component_Item_Id
        AND operation_seq_num = X_Operation_Seq_Num
        AND effectivity_date = X_Effectivity_Date
        AND NVL(ECO_FOR_PRODUCTION,2) = 2
        AND ((X_Rowid is null) OR (rowid <> X_Rowid))
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (X_bill_or_eco = 1) THEN
       fnd_message.set_name('BOM','BOM_COMPONENT_DUPLICATE');
    ELSE
       fnd_message.set_name('ENG','ENG_HAS_BEEN_MODIFIED');
    END IF;
    app_exception.raise_exception;
END Check_Unique;


PROCEDURE Check_Unique_From_Unit_Number(X_Rowid VARCHAR2,
           X_Bill_Sequence_Id NUMBER,
                       X_Component_Item_id  NUMBER,
                       X_Operation_Seq_Num      NUMBER,
                       X_From_Unit_Number       VARCHAR2,
           X_bill_or_eco    NUMBER) IS
   dummy NUMBER;
BEGIN
  SELECT 1 INTO dummy FROM dual WHERE NOT EXISTS
    (SELECT 1 from bom_inventory_components
      WHERE bill_sequence_id = X_Bill_Sequence_Id
        AND component_item_id = X_Component_Item_Id
        AND operation_seq_num = X_Operation_Seq_Num
        AND from_end_item_unit_number = X_From_Unit_Number
        AND ((X_Rowid is null) OR (rowid <> X_Rowid))
        AND disable_date is NULL
        AND NVL(ECO_FOR_PRODUCTION,2) = 2
        AND ((X_bill_or_eco = 1) OR (X_bill_or_eco <> 1
      AND implementation_date is null))
    );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (X_bill_or_eco = 1) THEN
       fnd_message.set_name('BOM','BOM_COMP_DUP_UNIT');
    ELSE
       fnd_message.set_name('ENG','ENG_UNIT_NUMBER_MODIFIED');
    END IF;
    app_exception.raise_exception;
END Check_Unique_From_Unit_Number;


PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Operation_Seq_Num              NUMBER,
                       X_Component_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       X_Component_Sequence_Id          IN OUT NOCOPY NUMBER,
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
           X_auto_Request_Material    VARCHAR2 DEFAULT NULL
           ,X_Suggested_Vendor_Name VARCHAR2 DEFAULT NULL
           ,X_Vendor_Id         NUMBER DEFAULT NULL
                     ,X_Unit_Price         NUMBER DEFAULT NULL
         , X_basis_type      NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM BOM_INVENTORY_COMPONENTS
                 WHERE component_sequence_id = X_Component_Sequence_Id;
      CURSOR C2 IS SELECT bom_inventory_components_s.nextval FROM sys.dual;

  l_object_revision_id NUMBER;
  l_minor_revision_id NUMBER;
  l_comp_revision_id NUMBER;
  l_comp_minor_revision_id  NUMBER;
  l_err_tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_return_status VARCHAR2(10);
  org_id number;      --4306013
  alt_bom_code varchar2(240);   --4306013
  ass_item_id NUMBER;     --4306013
  s_ass_comment varchar2(240);    --4306013
   BEGIN
      if (X_Component_Sequence_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Component_Sequence_Id;
        CLOSE C2;
      end if;


  --
  -- With the enhancement to BOM functionality for supporting various PLM
  -- requirements, BOM/Structures can have revisions and the components
  -- can maintain effectivity with respect to these revisions.
  -- We therefore now stamp the component with from_bill_revision_id
  -- and from_structure_revision_code values.
  -- These values are crucial for the explosion of BOM to work correctly for
  -- a particular structure revision.
  --

  --
  -- 1. Based on Component's Effectivity, get the Item Revision
  -- 2. Get the max structure revsion id/code for the current bill
  --    object_revision_id is null or object is 'EGO_ITEM' and
  --    object_revision_id = item_revsion_id
  -- 3. Use the values returned in 2 as the From_Bill_Rev_Id and
  --    From_Structure_Revision_Code values for the component.
  --



  BOM_GLOBALS.GET_DEF_REV_ATTRS
  (     p_bill_sequence_id => x_bill_sequence_id
    ,    p_comp_item_id => x_component_item_id
    ,   p_effectivity_date => x_effectivity_date
    ,   x_object_revision_id => l_object_revision_id
    ,   x_minor_revision_id => l_minor_revision_id
    ,   x_comp_revision_id => l_comp_revision_id
    ,   x_comp_minor_revision_id => l_comp_minor_revision_id
  );


       INSERT INTO BOM_INVENTORY_COMPONENTS(
              operation_seq_num,
              component_item_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              item_num,
              component_quantity,
              component_yield_factor,
              component_remarks,
              effectivity_date,
              change_notice,
              implementation_date,
              disable_date,
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
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              acd_type,
              old_component_sequence_id,
              component_sequence_id,
              bill_sequence_id,
              wip_supply_type,
              pick_components,
              supply_subinventory,
              supply_locator_id,
              operation_lead_time_percent,
              revised_item_sequence_id,
              cost_factor,
              bom_item_type,
        from_end_item_unit_number,
        to_end_item_unit_number,
        enforce_int_requirements,
        auto_request_material
        ,suggested_vendor_name
        ,vendor_id
        ,unit_price
        ,FROM_OBJECT_REVISION_ID
        ,FROM_MINOR_REVISION_ID
        --,COMPONENT_ITEM_REVISION_ID
        --,COMPONENT_MINOR_REVISION_ID
          ,basis_type
             ) VALUES (
              X_Operation_Seq_Num,
              X_Component_Item_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Item_Num,
              X_Component_Quantity,
              X_Component_Yield_Factor,
              X_Component_Remarks,
              X_Effectivity_Date,
              X_Change_Notice,
              X_Implementation_Date,
              X_Disable_Date,
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
              X_Required_To_Ship,
              X_Required_For_Revenue,
              X_Include_On_Ship_Docs,
              X_Include_On_Bill_Docs,
              X_Low_Quantity,
              X_High_Quantity,
              X_Acd_Type,
              X_Old_Component_Sequence_Id,
              X_Component_Sequence_Id,
              X_Bill_Sequence_Id,
              X_Wip_Supply_Type,
              X_Pick_Components,
              X_Supply_Subinventory,
              X_Supply_Locator_Id,
              X_Operation_Lead_Time_Percent,
              X_Revised_Item_Sequence_Id,
              X_Cost_Factor,
              X_Bom_Item_Type,
              X_From_Unit_Number,
              X_To_Unit_Number,
        X_Enforce_Int_Requirements,
        X_Auto_Request_Material
        ,X_Suggested_Vendor_Name
        ,X_Vendor_Id
        ,X_Unit_Price
    ,   l_object_revision_id
    ,   l_minor_revision_id
    --,   l_comp_revision_id
    --,   l_comp_minor_revision_id
          ,X_basis_type
             );
    --Update referencing bills
    BOMPCMBM.Insert_Related_Components(p_src_bill_seq_id  => X_Bill_Sequence_Id
                                    , p_src_comp_seq_id   =>  X_Component_Sequence_Id
                                    , x_Mesg_Token_Tbl => l_err_tbl
                                    , x_Return_Status => l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      app_exception.raise_exception;
    END IF;

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;


  -- Raising Business event

    SELECT bbm.Organization_Id, bbm.alternate_bom_designator, bbm.assembly_item_id, bbm.specific_assembly_comment
      INTO org_id, alt_bom_code, ass_item_id, s_ass_comment
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
      , p_creation_date    => X_Creation_Date
      , p_created_by       => X_Created_By
      , p_last_update_login=> X_Last_Update_Login
      , p_component_seq_id => X_Component_Sequence_Id
      );
  END Insert_Row;

END BOM_INV_COMPS1_PKG;

/
