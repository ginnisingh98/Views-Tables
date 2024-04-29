--------------------------------------------------------
--  DDL for Package BOM_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BO_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMBBOMS.pls 120.1 2006/07/14 04:21:28 bbpatel noship $ */
/*#
 * APIs in this package are used to create, update or delete single or multiple components of a Structure/BOM.First, the user creates the structure header for an Item.After creating
 * the Header the user adds or updates or deletes components(Items) and their child entities such as reference designators,substitute components etc.
 * Implementation of each of these entites are described below.
 * This API can be used for processing of a single or multiple business entities(Structure/BOM and its child entities) per call. The entities that needs to be processed
 * should belong to the same Structure/BOM.How to use this is explained below through examples.<BR>
 * Example 1 : To Create a new Bom entity.(Bom Header,Component,Reference Designator etc).
 *<li>1.The User should Initialize the Error_Handler so that errors can be logged and retireved.</li>
 *<li>2.The user populates the Record Type for each entity like Bill Header that needs to be processed.</li>
 *<li>3.The record should be created with attribute values as explained in the record type description below</li>
 *<li>For example populate the Bom Header by giving values as follows Bom_Header.assembly_type = 1</li>
 *<li>4.Then Process_Bom procedure in this package is called with already created record types as paramters</li>
 *<li>The Process_Bom method processes the records and registers errors in the pl/sql error table which can be
 * extracted using Error_Hanlder.get_messge</li>
 *<li>5.If the Return Status is S then the process completed sucessfully else The error is logges in the Error_Handler</li>
 *<li>6.If Suucessful the user should commit the data.</li>
 *
 * Example-2 To Update the value of an attribute.
 *<li>1.If the user wants to update the user unique index attributes like Operation Sequence Number
 * he should give the existing value to pick up the corrrect record and the new value to change.</li>
 *<li>bom_component.old_operation_sequence_number = 1</li>
 *<li>bom_component.new_operation_sequence_number = 2</li>
 *<li>2.If the user wants tp update non user unique indexes then he needs to give only the new value</li>
 *<li>bom_component.quantity = 30</li><BR>
 *
 *
 * -------------------------
 *  Strucure Header Record
 * -------------------------
 *<code><pre>
 * TYPE Bom_Head_Rec_Type IS RECORD
 * (  Assembly_item_name           VARCHAR2(240)
 *  , Organization_Code            VARCHAR2(3)
 *  , Alternate_Bom_Code           VARCHAR2(10)
 *  , Common_Assembly_Item_Name    VARCHAR2(240)
 *  , Common_Organization_Code     VARCHAR2(3)
 *  , Assembly_Comment             VARCHAR2(240)
 *  , Assembly_Type                NUMBER
 *  , Transaction_Type             VARCHAR2(30)
 *  , Return_Status                VARCHAR2(1)
 *  , Attribute_category           VARCHAR2(30)
 *  , Attribute1                   VARCHAR2(150)
 *  , Attribute2                   VARCHAR2(150)
 *  , Attribute3                   VARCHAR2(150)
 *  , Attribute4                   VARCHAR2(150)
 *  , Attribute5                   VARCHAR2(150)
 *  , Attribute6                   VARCHAR2(150)
 *  , Attribute7                   VARCHAR2(150)
 *  , Attribute8                   VARCHAR2(150)
 *  , Attribute9                   VARCHAR2(150)
 *  , Attribute10                  VARCHAR2(150)
 *  , Attribute11                  VARCHAR2(150)
 *  , Attribute12                  VARCHAR2(150)
 *  , Attribute13                  VARCHAR2(150)
 *  , Attribute14                  VARCHAR2(150)
 *  , Attribute15                  VARCHAR2(150)
 *  , Original_System_Reference    VARCHAR2(50)
 *  , Delete_Group_Name            VARCHAR2(10)
 *  , DG_Description               VARCHAR2(240)
 *  , Row_Identifier      NUMBER          := null
 *  , BOM_Implementation_Date      DATE
 *  , Enable_Attrs_Update          VARCHAR2(1)
 *  , Structure_Type_Name          VARCHAR2(80)
 * )
 *</pre></code>
 *
 * ------------------------------
 *       Parameteres
 * ------------------------------
 *
 *<pre>
 * Assembly_item_name        -- User friendly name of the Item for which the Structure Header is created.
 * Organization_Code         -- Organization Code in which the Item is defined.
 * Alternate_Bom_Code        -- Structure name to be given,if this is null then the BOM is primary
 * Common_Assembly_Item_Name -- Assembly Item name of common bill
 * Common_Organization_Code  -- Organization code for the common bill
 * Assembly_Comment          -- Comment describing the Assembly or Bill
 * Assembly_Type             -- 1 = Manufacturing Bill, 2 = Engineering Bill
 * Transaction_Type          -- Defined below
 * Return_Status             -- The Structure Header creation status,whether successful or error
 * Attribute_category        -- Descriptive flexfield structure defining column
 * Attribute 1 to 15         -- Descriptive flexfield segment
 * Original_System_Reference -- Original system that data for the current record has come from.
 * Delete_Group_Name         -- Delete group name for the entity type you are deleting
 * DG_Description            -- A meaningful description of the delete group
 * Row_Identifier            -- A unique identifier value for the entity record.
 * BOM_Implementation_Date   -- The date on which the Bill will be implemented
 * Enable_Attrs_Update       -- Flag to indicate whether common attributes are updateable
 *</pre>
 *
 * ----------------------------------
 *   Inventory Components Record
 * ----------------------------------
 *
 *<code><pre>
 * TYPE Bom_Comps_Rec_Type IS RECORD
 * (  Organization_Code              VARCHAR2(3)
 *  , Assembly_Item_Name             VARCHAR2(240)
 *  , Start_Effective_Date           DATE
 *  , Disable_Date                   DATE
 *  , Operation_Sequence_Number      NUMBER
 *  , Component_Item_Name            VARCHAR2(240)
 *  , Alternate_BOM_Code             VARCHAR2(10)
 *  , New_Effectivity_Date           DATE
 *  , New_Operation_Sequence_Number  NUMBER
 *  , Item_Sequence_Number           NUMBER
 *  , Basis_type		     NUMBER
 *  , Quantity_Per_Assembly          NUMBER
 *  , Inverse_Quantity               NUMBER
 *  , Planning_Percent               NUMBER
 *  , Projected_Yield                NUMBER
 *  , Include_In_Cost_Rollup         NUMBER
 *  , Wip_Supply_Type                NUMBER
 *  , So_Basis                       NUMBER
 *  , Optional                       NUMBER
 *  , Mutually_Exclusive             NUMBER
 *  , Check_Atp                      NUMBER
 *  , Shipping_Allowed               NUMBER
 *  , Required_To_Ship               NUMBER
 *  , Required_For_Revenue           NUMBER
 *  , Include_On_Ship_Docs           NUMBER
 *  , Quantity_Related               NUMBER
 *  , Supply_Subinventory            VARCHAR2(10)
 *  , Location_Name                  VARCHAR2(81)
 *  , Minimum_Allowed_Quantity       NUMBER
 *  , Maximum_Allowed_Quantity       NUMBER
 *  , Comments                       VARCHAR2(240)
 *  , Attribute_category             VARCHAR2(30)
 *  , Attribute1                     VARCHAR2(150)
 *  , Attribute2                     VARCHAR2(150)
 *  , Attribute3                     VARCHAR2(150)
 *  , Attribute4                     VARCHAR2(150)
 *  , Attribute5                     VARCHAR2(150)
 *  , Attribute6                     VARCHAR2(150)
 *  , Attribute7                     VARCHAR2(150)
 *  , Attribute8                     VARCHAR2(150)
 *  , Attribute9                     VARCHAR2(150)
 *  , Attribute10                    VARCHAR2(150)
 *  , Attribute11                    VARCHAR2(150)
 *  , Attribute12                    VARCHAR2(150)
 *  , Attribute13                    VARCHAR2(150)
 *  , Attribute14                    VARCHAR2(150)
 *  , Attribute15                    VARCHAR2(150)
 *  , From_End_Item_Unit_Number      VARCHAR2(30)
 *  , New_From_End_Item_Unit_Number  VARCHAR2(30)
 *  , To_End_Item_Unit_Number        VARCHAR2(30)
 *  , Return_Status                  VARCHAR2(1)
 *  , Transaction_Type               VARCHAR2(30)
 *  , Original_System_Reference      VARCHAR2(50)
 *  , Delete_Group_Name              VARCHAR2(10)
 *  , DG_Description                 VARCHAR2(240)
 *  , Enforce_Int_Requirements       VARCHAR2(80)
 *  , Auto_Request_Material          VARCHAR2(1)
 *  , Row_Identifier                 NUMBER          := null
 *	, Suggested_Vendor_Name          VARCHAR2(240)
 *	, Unit_Price	                   NUMBER
 * )
 *</pre></code>
 *
 * -----------------------------
 *       Parameters
 * -----------------------------
 *
 *<pre>
 * Organization_Code              -- The Organization Code where the Component Item is defined
 * Assembly_Item_Name             -- The User friendly Item Name of the Component
 * Start_Effective_Date           -- The date from which the component will be effective in the Bill
 * Disable_Date                   -- The date on which the component will be disabled from the Bill
 * Operation_Sequence_Number      -- Operation sequence number
 * Component_Item_Name            -- Name of the component in the Item
 * Alternate_BOM_Code             -- Structure name,if null then primary
 * New_Effectivity_Date           -- The new Effectivity Date when the user want to update the existing Effectivity Date
 * New_Operation_Sequence_Number  -- The new Operation Sequence Number when the user want to update an already existing Operation Sequence Number.
 * Item_Sequence_Number           -- Item sequence within bill of material structure
 * Basis_type 			  -- Basis Type for the quantity. 1-Item , 2-Lot
 * Quantity_Per_Assembly          -- Quantity of component in bill of material
 * Inverse_Quantity               -- Inverse of the Quantity(Quantity 10 then Inverse Quanity = 1/10)
 * Planning_Percent               -- Factor used to multiply component quantity with to obtain planning quantity
 * Projected_Yield                -- The yield is the percentage of the component that survives the manufacturing process. A yield factor of 0.90 means that only 90% of
                                     the usage quantity of the component on a bill actually survives to be incorporated into the finished assembly.
 * Include_In_Cost_Rollup         -- Flag indicating if this component is to be used when rolling up costs
 * Wip_Supply_Type                -- WIP supply type code
 * So_Basis                       -- Quantity basis used by Oracle Order Management to determine how many units of component to put on an order
 * Optional                       -- Flag indicating if component is optional in bill
 * Mutually_Exclusive             -- Flag indicating if one or more children of component can be picked when taking an order
 * Check_Atp                      -- Flag indicating if ATP check is required
 * Shipping_Allowed               -- Flag indicating if component is allowed to ship
 * Required_To_Ship               -- Flag indicating if component is required to ship
 * Required_For_Revenue           -- Flag indicating if component is required for revenue
 * Include_On_Ship_Docs           -- Flag indicating if component is displayed on shipping documents
 * Quantity_Related               -- Identifier to indicate if this component has quantity related reference designators
 * Supply_Subinventory            -- Supply subinventory
 * Location_Name                  -- Supply locator name
 * Minimum_Allowed_Quantity       -- Minimum quantity allowed on an order
 * Maximum_Allowed_Quantity       -- Maximum quantity allowed on an order
 * Comments                       -- Component comment
 * Attribute_category             -- Descriptive flexfield structure defining column
 * Attribute 1 to 15              -- Descriptive flexfield segments
 * From_End_Item_Unit_Number      -- From End Item Unit Number if th component is unit effective
 * New_From_End_Item_Unit_Number  -- The new From End Item Unit Number when the user want to update an existing From End Item Unit Number
 * To_End_Item_Unit_Number        -- To End Item Unit Number if th component is unit effective
 * Return_Status                  -- The component creation status,whether successful or error
 * Transaction_Type               -- Defined below
 * Original_System_Reference      -- Original system that data for the current record has come from.
 * Delete_Group_Name              -- Delete group name for the entity type you are deleting
 * DG_Description                 -- Description of the delete group
 * Enforce_Int_Requirements       -- Enforce Integer Requirements
 * Auto_Request_Material          --
 * Row_Identifier                 -- A unique identifier value for the entity record.
 * Suggested_Vendor_Name          -- Suggested vendor name will be used for direct items for EAM BOMs
 * Unit_Price	                    -- Unit Price for direct items used by EAM BOMs
 *</pre>
 *
 * ---------------------------------
 *   Reference Designators Record
 * ---------------------------------
 *
 *<code><pre>
 * TYPE Bom_Ref_Designator_Rec_Type IS RECORD
 * (  Organization_Code            VARCHAR2(3)
 *  , Assembly_Item_Name           VARCHAR2(240)
 *  , Start_Effective_Date         DATE
 *  , Operation_Sequence_Number    NUMBER
 *  , Component_Item_Name          VARCHAR2(240)
 *  , Alternate_Bom_Code           VARCHAR2(10)
 *  , Reference_Designator_Name    VARCHAR2(15)
 *  , Ref_Designator_Comment       VARCHAR2(240)
 *  , Attribute_category           VARCHAR2(30)
 *  , Attribute1                   VARCHAR2(150)
 *  , Attribute2                   VARCHAR2(150)
 *  , Attribute3                   VARCHAR2(150)
 *  , Attribute4                   VARCHAR2(150)
 *  , Attribute5                   VARCHAR2(150)
 *  , Attribute6                   VARCHAR2(150)
 *  , Attribute7                   VARCHAR2(150)
 *  , Attribute8                   VARCHAR2(150)
 *  , Attribute9                   VARCHAR2(150)
 *  , Attribute10                  VARCHAR2(150)
 *  , Attribute11                  VARCHAR2(150)
 *  , Attribute12                  VARCHAR2(150)
 *  , Attribute13                  VARCHAR2(150)
 *  , Attribute14                  VARCHAR2(150)
 *  , Attribute15                  VARCHAR2(150)
 *  , From_End_Item_Unit_Number    VARCHAR2(30)
 *  , Original_System_Reference    VARCHAR2(50)
 *  , New_Reference_Designator     VARCHAR2(15)
 *  , Return_Status                VARCHAR2(1)
 *  , Transaction_Type             VARCHAR2(30)
 *  , Row_Identifier               NUMBER          := null
 *)
 *</pre></code>
 *
 * -----------------------
 *      Parameters
 * -----------------------
 *
 *<pre>
 * Organization_Code                 -- Organization Code
 * Assembly_Item_Name                -- Item name for which the Reference Designator is defined
 * Start_Effective_Date              -- Date from which Reference Designator is effective
 * Operation_Sequence_Number         -- Operation Sequence Number
 * Component_Item_Name               -- Component Name in the Bill
 * Alternate_Bom_Code                -- Structure Name
 * Reference_Designator_Name         -- Reference Desigantor Name
 * Ref_Designator_Comment            -- Comment for defining the Reference Designator
 * Attribute_category                -- Descriptive flexfield structure defining column
 * Attribute 1 to 15                 -- Descriptive flexfield segments
 * From_End_Item_Unit_Number         -- From End Item Unti Number
 * Original_System_Reference         -- Original system that data for the current record has come from.
 * New_Reference_Designator          -- The new Reference Designator name when an already existing one needs to be changed.
 * Return_Status                     -- Parocess Status ,whether successful or error
 * Transaction_Type                  -- Defined Below
 * Row_Identifier                    -- A unique identifier value for the entity record.
 *</pre>
 *
 * --------------------------------------
 *    Substitute Components Record
 * --------------------------------------
 *
 *<code><pre>
 * TYPE Sub_Component_Rec_Type IS RECORD
 * (   Eco_Name                      VARCHAR2(10)
 * ,   Organization_Code             VARCHAR2(3)
 * ,   Revised_Item_Name             VARCHAR2(240)
 * ,   Start_Effective_Date          DATE
 * ,   New_Revised_Item_Revision     VARCHAR2(3)
 * ,   Operation_Sequence_Number     NUMBER
 * ,   Component_Item_Name           VARCHAR2(240)
 * ,   Alternate_BOM_Code            VARCHAR2(10)
 * ,   Substitute_Component_Name     VARCHAR2(240)
 * ,   New_Substitute_Component_Name VARCHAR2(240)
 * ,   Acd_Type                      NUMBER
 * ,   Substitute_Item_Quantity      NUMBER
 * ,   Attribute_category            VARCHAR2(30)
 * ,   Attribute1                    VARCHAR2(150)
 * ,   Attribute2                    VARCHAR2(150)
 * ,   Attribute4                    VARCHAR2(150)
 * ,   Attribute5                    VARCHAR2(150)
 * ,   Attribute6                    VARCHAR2(150)
 * ,   Attribute8                    VARCHAR2(150)
 * ,   Attribute9                    VARCHAR2(150)
 * ,   Attribute10                   VARCHAR2(150)
 * ,   Attribute12                   VARCHAR2(150)
 * ,   Attribute13                   VARCHAR2(150)
 * ,   Attribute14                   VARCHAR2(150)
 * ,   Attribute15                   VARCHAR2(150)
 * ,   program_id                    NUMBER
 * ,   Attribute3                    VARCHAR2(150)
 * ,   Attribute7                    VARCHAR2(150)
 * ,   Attribute11                   VARCHAR2(150)
 * ,   Original_System_Reference     VARCHAR2(50)
 * ,   From_End_Item_Unit_Number     VARCHAR2(30)
 * ,   New_Routing_Revision          VARCHAR2(3)
 * ,   Enforce_Int_Requirements      VARCHAR2(80)
 * ,   Return_Status                 VARCHAR2(1)
 * ,   Transaction_Type              VARCHAR2(30)
 * ,   Row_Identifier                NUMBER          := null
 * )
 *</pre></code>
 *
 * -----------------------
 *     Parameters
 * -----------------------
 *
 *<pre>
 * Most of the parameters hold the same meaning as explained in other record types.Those which are specific to
 * this record type are
 * Revised_Item_Name                  -- Name of the Revised Item
 * Substitute_Component_Name          -- Name of the Substitute Component
 * Acd_Type                           -- Add or delete code from an engineering change order
 * Substitute_Item_Quantity           -- Quanitity of the Substitute Component
 * </pre>
 * Every process must have 'Transaction Type' at the Component level or Structure Header level as the case might be.
 * Valid Transaction Types are Create,Update Delete or Sync.
 * The Sync Transaction Type can be used when when it is required by the calling application to:
 * 1.Create a Structure/BOM or child entities, if it does not exist.
 * 2.Update the entities with the passed in values
 * For eg. A oracle.apps.bom.structure.create event will be raised when a new Structure/BOM is created.
 * @see Bom_Business_Event_PKG.G_COMPONENT_ADDED_EVENT
 * @see Bom_Business_Event_PKG.G_COMPONENT_MODIFIED_EVENT
 * @see Bom_Business_Event_PKG.G_COMPONENT_DEL_SUCCESS_EVENT
 * @see Bom_Business_Event_PKG.G_ITEM_DEL_ERROR_EVENT
 * @rep:scope public
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Create,Add or Update Bill of Material Business Entities
 * @rep:compatibility S
 */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBBOMS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_BO_Pub
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-99 Rahul Chitko  Initial Creation
--
--  20-AUG-01 Refai Farook  One To Many support changes
--
--  25-SEP-01 Refai Farook    Changes to the REV_COMP and BOM_COMP record structures(mass changes support for unit effctivity)
--  15-NOV-02   Anirban Dey     Added AUTO_REQUEST_METERIAL in the components structure(Bom_Comps_ Rec_Type)
-- 22-NOV-02   Vani Hymavathi   Added new column ROW_IDENTIFIER to all bo records
-- 28-JAN-03   Vani Hymavathi   Added new columns New_Substitute_Component_Name,New_Substitute_Component_Id--				   New_Additional_Op_Seq_Num, New_Additional_Op_Seq_Id to bo records
-- 23-APR-03    Refai Farook    Support for creating unimplemented BOMS (PLM)
-- 01-May-03    Sreejith Nell   Overloaded Method for PLM OA Pages Create Component
-- 16-Feb-04    Vani Hymavathi  added revision_label, revision_reason to revision record.
--
-- 26-APR-05   Abhishek Rudresh     Common BOM Attr Updates
-- 28-APR-05   Vani Hymavathi  Added basis_type to BOM_COMPS_TBL_TYPE and  Rev_Component_Rec_Type
-- 13-JUL-06   Bhavnesh Patel  Added support for Structure Type
***************************************************************************/
  --
  -- Bill of Materials Header exposed record definition
  --
  TYPE Bom_Head_Rec_Type IS RECORD
  (  Assembly_item_name           VARCHAR2(240) -- bug 2947642
   , Organization_Code            VARCHAR2(3)
   , Alternate_Bom_Code           VARCHAR2(10)
   , Common_Assembly_Item_Name    VARCHAR2(240) -- bug 2947642
   , Common_Organization_Code     VARCHAR2(3)
   , Assembly_Comment             VARCHAR2(240)
   , Assembly_Type                NUMBER
   , Transaction_Type             VARCHAR2(30)
   , Return_Status                VARCHAR2(1)
   , Attribute_category           VARCHAR2(30)
   , Attribute1                   VARCHAR2(150)
   , Attribute2                   VARCHAR2(150)
   , Attribute3                   VARCHAR2(150)
   , Attribute4                   VARCHAR2(150)
   , Attribute5                   VARCHAR2(150)
   , Attribute6                   VARCHAR2(150)
   , Attribute7                   VARCHAR2(150)
   , Attribute8                   VARCHAR2(150)
   , Attribute9                   VARCHAR2(150)
   , Attribute10                  VARCHAR2(150)
   , Attribute11                  VARCHAR2(150)
   , Attribute12                  VARCHAR2(150)
   , Attribute13                  VARCHAR2(150)
   , Attribute14                  VARCHAR2(150)
   , Attribute15                  VARCHAR2(150)
   , Original_System_Reference    VARCHAR2(50)
   , Delete_Group_Name            VARCHAR2(10)
   , DG_Description               VARCHAR2(240)
   , Row_Identifier               NUMBER          := null
   , BOM_Implementation_Date      DATE
   , Enable_Attrs_Update          VARCHAR2(1)  --Indicates whether common bom attribute are updateable.
   , Structure_Type_Name          VARCHAR2(80)
  );


  TYPE Bom_Header_Tbl_Type IS TABLE OF Bom_Head_Rec_Type
    INDEX BY BINARY_INTEGER;


  --
  -- Bill of Material Unexposed Record definition
  --
  TYPE Bom_Head_Unexposed_Rec_Type IS RECORD
  (  Assembly_item_id   NUMBER
   , Organization_id    NUMBER
   , Common_Assembly_item_id  NUMBER
   , Common_Organization_id NUMBER
   , Assembly_Type    NUMBER
   , Common_Bill_Sequence_Id  NUMBER
   , Bill_Sequence_Id   NUMBER
   , DG_Sequence_Id   NUMBER
   , DG_Description   VARCHAR2(240)
   , DG_New     BOOLEAN   := FALSE
   , Structure_Type_Id    NUMBER
   , Enable_Unimplemented_Boms  VARCHAR2(1)
   , Source_Bill_Sequence_Id NUMBER
   );

  TYPE Bom_Revision_Rec_Type IS RECORD
  (  Assembly_Item_Name   VARCHAR2(240) -- bug 2947642
   , Organization_Code    VARCHAR2(3)
   , Revision                       VARCHAR2(3)
   , Revision_Label                 VARCHAR2(80)
   , Revision_Reason                VARCHAR2(30)
   , Alternate_Bom_Code             VARCHAR2(10)
   , Description                    VARCHAR2(240)
   , Start_Effective_Date           DATE
         , Transaction_Type         VARCHAR2(30)
         , Return_Status            VARCHAR2(1)
         , Attribute_category       VARCHAR2(30)
         , Attribute1               VARCHAR2(150)
         , Attribute2               VARCHAR2(150)
         , Attribute3               VARCHAR2(150)
         , Attribute4               VARCHAR2(150)
         , Attribute5               VARCHAR2(150)
         , Attribute6               VARCHAR2(150)
         , Attribute7               VARCHAR2(150)
         , Attribute8               VARCHAR2(150)
         , Attribute9               VARCHAR2(150)
         , Attribute10              VARCHAR2(150)
         , Attribute11              VARCHAR2(150)
         , Attribute12              VARCHAR2(150)
         , Attribute13              VARCHAR2(150)
         , Attribute14              VARCHAR2(150)
         , Attribute15              VARCHAR2(150)
         , Original_System_Reference    VARCHAR2(50)
         , Row_Identifier            NUMBER          := null
   );

  TYPE Bom_Revision_Tbl_Type IS TABLE OF Bom_Revision_Rec_Type
    INDEX BY BINARY_INTEGER;

  TYPE Bom_Rev_Unexposed_Rec_Type IS RECORD
  (  Assembly_Item_Id   NUMBER
   , Organization_Id    NUMBER
   );

-- ECO Uses a different record structure for inventory components, Reference
-- Designator and substitute components than what BOM uses. So their are 2
-- ontrol record definition

  TYPE Control_Rec_Type IS RECORD
  ( controlled_operation  BOOLEAN := FALSE
  , check_existence       BOOLEAN := FALSE
  , attribute_defaulting  BOOLEAN := FALSE
  , entity_defaulting     BOOLEAN := FALSE
  , entity_validation     BOOLEAN := FALSE
  , process_entity        VARCHAR2(30) := 'ECO'
  , write_to_db           BOOLEAN := FALSE
  , last_updated_by       NUMBER  := NULL
  , last_update_login     NUMBER  := NULL
  , caller_type           VARCHAR2(10) := 'OI'
                        -- Set to 'FORM' if a FORM calls the program
  , validation_controller VARCHAR2(30) := 'NONE'
                        -- The name a field that requires specific validation
  , require_item_rev  NUMBER  := NULL
  , unit_controlled_item  BOOLEAN := FALSE
        , eco_assembly_type     NUMBER  := 1   -- Added by MK on 11/01/00
  );

  G_DEFAULT_CONTROL_REC   Control_Rec_Type;

  TYPE Rev_Component_Rec_Type IS RECORD
  (   Eco_Name          VARCHAR2(10)
  ,   Organization_Code       VARCHAR2(3)
  ,   Revised_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   New_revised_Item_Revision     VARCHAR2(3)
  ,   Start_Effective_Date      DATE
  ,   New_Effectivity_Date            DATE
  ,   Disable_Date        DATE
  ,   Operation_Sequence_Number     NUMBER
  ,   Component_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   Alternate_BOM_Code        VARCHAR2(10)
  ,   ACD_Type          NUMBER
  ,   Old_Effectivity_Date      DATE
  ,   Old_Operation_Sequence_Number   NUMBER
  ,   New_Operation_Sequence_Number   NUMBER
  ,   Item_Sequence_Number      NUMBER
  ,   Basis_Type		NUMBER
  ,   Quantity_Per_Assembly     NUMBER
  ,   Inverse_Quantity		NUMBER
  ,   Planning_Percent        NUMBER
  ,   Projected_Yield       NUMBER
  ,   Include_In_Cost_Rollup          NUMBER
  ,   Wip_Supply_Type                 NUMBER
  ,   So_Basis                        NUMBER
  ,   Optional                        NUMBER
  ,   Mutually_Exclusive              NUMBER
  ,   Check_Atp                       NUMBER
  ,   Shipping_Allowed                NUMBER
  ,   Required_To_Ship                NUMBER
  ,   Required_For_Revenue            NUMBER
  ,   Include_On_Ship_Docs            NUMBER
  ,   Quantity_Related                NUMBER
  ,   Supply_Subinventory             VARCHAR2(10)
  ,   Location_Name           VARCHAR2(81)
  ,   Minimum_Allowed_Quantity      NUMBER
  ,   Maximum_Allowed_Quantity      NUMBER
  ,   comments          VARCHAR2(240)
  ,   cancel_comments       VARCHAR2(240)
  ,   Attribute_category              VARCHAR2(30)
  ,   Attribute1                      VARCHAR2(150)
  ,   Attribute2                      VARCHAR2(150)
  ,   Attribute3                      VARCHAR2(150)
  ,   Attribute4                      VARCHAR2(150)
  ,   Attribute5                      VARCHAR2(150)
  ,   Attribute6                      VARCHAR2(150)
  ,   Attribute7                      VARCHAR2(150)
  ,   Attribute8                      VARCHAR2(150)
  ,   Attribute9                      VARCHAR2(150)
  ,   Attribute10                     VARCHAR2(150)
  ,   Attribute11                     VARCHAR2(150)
  ,   Attribute12                     VARCHAR2(150)
  ,   Attribute13                     VARCHAR2(150)
  ,   Attribute14                     VARCHAR2(150)
  ,   Attribute15                     VARCHAR2(150)
  ,   From_End_Item_Unit_Number       VARCHAR2(30)
        ,   Old_From_End_Item_Unit_Number   VARCHAR2(30)
        ,   New_From_End_Item_Unit_Number   VARCHAR2(30)
  ,   To_End_Item_Unit_Number         VARCHAR2(30)
  ,   New_Routing_Revision      VARCHAR2(3)    -- Added by MK on 11/02/00
        , Enforce_Int_Requirements           VARCHAR2(80)    -- 11.5.7 Enhancement 2101381
        ,  Auto_Request_Material            VARCHAR2(1)    -- Added in 11.5.9 by ADEY
	,  Suggested_Vendor_Name	VARCHAR2(240) --- Deepu
--	,  Purchasing_Category  VARCHAR2() --- Deepu
--	,  Purchasing_Category_Id  NUMBER --- Deepu --- move to unexposed??
	,  Unit_Price		NUMBER --- Deepu
  ,   Original_System_Reference     VARCHAR2(50)
  ,   Return_Status                   VARCHAR2(1)
  ,   Transaction_Type        VARCHAR2(30)
        , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
);

  TYPE Rev_Component_Tbl_Type IS TABLE OF Rev_Component_Rec_Type
      INDEX BY BINARY_INTEGER;

  -- Revised Component Unexposed Column Record
  TYPE Rev_Comp_Unexposed_Rec_Type IS RECORD
  (   Organization_Id       NUMBER
  ,   Component_Item_Id       NUMBER
  ,   Old_Component_Sequence_Id       NUMBER
  ,   Component_Sequence_Id     NUMBER
  ,   Bill_Sequence_Id        NUMBER
  ,   Pick_Components       NUMBER
  ,   Supply_Locator_Id       NUMBER
  ,   Revised_Item_Sequence_Id      NUMBER
  ,   Bom_Item_Type       NUMBER
  ,   Revised_Item_Id       NUMBER
  ,   Include_On_Bill_Docs      NUMBER
        ,   Delete_Group_Name               VARCHAR2(10)    -- Added in 1155
        ,   DG_Description                  VARCHAR2(240)   -- Added in 1155
        ,   DG_Sequence_Id                  NUMBER           -- Added in 1155
        ,   Enforce_Int_Requirements_Code   NUMBER        -- 11.5.7 Enhancement 2101381
        ,   Rowid                           VARCHAR2(50)
  ,   BOM_Implementation_Date     DATE
  ,   Vendor_Id		NUMBER --- Deepu
  ,   Common_Component_Sequence_Id NUMBER
  );

  --  Ref_Designator record type

  TYPE Ref_Designator_Rec_Type IS RECORD
  (   Eco_Name          VARCHAR2(10)
  ,   Organization_Code       VARCHAR2(3)
  ,   Revised_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   Start_Effective_Date      DATE
  ,   New_Revised_Item_Revision     VARCHAR2(3)
  ,   Operation_Sequence_Number     NUMBER
  ,   Component_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   Alternate_Bom_Code        VARCHAR2(10)
  ,   Reference_Designator_Name     VARCHAR2(15)
  ,   ACD_Type          NUMBER
  ,   Ref_Designator_Comment      VARCHAR2(240)
  ,   Attribute_category            VARCHAR2(30)
  ,   Attribute1                    VARCHAR2(150)
  ,   Attribute2                    VARCHAR2(150)
  ,   Attribute3                    VARCHAR2(150)
  ,   Attribute4                    VARCHAR2(150)
  ,   Attribute5                    VARCHAR2(150)
  ,   Attribute6                    VARCHAR2(150)
  ,   Attribute7                    VARCHAR2(150)
  ,   Attribute8                    VARCHAR2(150)
  ,   Attribute9                    VARCHAR2(150)
  ,   Attribute10                   VARCHAR2(150)
  ,   Attribute11                   VARCHAR2(150)
  ,   Attribute12                   VARCHAR2(150)
  ,   Attribute13                   VARCHAR2(150)
  ,   Attribute14                   VARCHAR2(150)
  ,   Attribute15                   VARCHAR2(150)
  ,   Original_System_Reference   VARCHAR2(50)
  ,   New_Reference_Designator      VARCHAR2(15)
  ,   From_End_Item_Unit_Number     VARCHAR2(30)     -- Added by MK on 11/02/00
  ,   New_Routing_Revision          VARCHAR2(3)    -- Added by MK on 11/02/00
  ,   Return_Status                 VARCHAR2(1)
  ,   Transaction_Type      VARCHAR2(30)
         , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9

 );

  TYPE Ref_Designator_Tbl_Type IS TABLE OF Ref_Designator_Rec_Type
      INDEX BY BINARY_INTEGER;

  -- Reference Designator Unexposed Column Record
  TYPE Ref_Desg_Unexposed_Rec_Type IS RECORD
  (   Organization_Id       NUMBER
  ,   Component_Item_Id       NUMBER
  ,   Component_Sequence_Id     NUMBER
  ,   Revised_Item_Id       NUMBER
  ,   Bill_Sequence_Id        NUMBER
  ,   Revised_Item_Sequence_Id      NUMBER
  );

  --  Sub_Component record type

  TYPE Sub_Component_Rec_Type IS RECORD
  (   Eco_Name              VARCHAR2(10)
  ,   Organization_Code       VARCHAR2(3)
  ,   Revised_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   Start_Effective_Date      DATE
  ,   New_Revised_Item_Revision     VARCHAR2(3)
  ,   Operation_Sequence_Number     NUMBER
  ,   Component_Item_Name       VARCHAR2(240) -- bug 2947642
  ,   Alternate_BOM_Code        VARCHAR2(10)
--  ,   Substitute_Component_Name     VARCHAR2(81)
--  ,   New_Substitute_Component_Name   VARCHAR2(81)   --Added by vhymavat for 11.5.9 enh, 2762683
  ,   Substitute_Component_Name     VARCHAR2(240) -- bug 2947642
  ,   New_Substitute_Component_Name   VARCHAR2(240) -- bug 2947642
  ,   Acd_Type                      NUMBER
  ,   Substitute_Item_Quantity      NUMBER
  ,   Attribute_category            VARCHAR2(30)
  ,   Attribute1                    VARCHAR2(150)
  ,   Attribute2                    VARCHAR2(150)
  ,   Attribute4                    VARCHAR2(150)
  ,   Attribute5                    VARCHAR2(150)
  ,   Attribute6                    VARCHAR2(150)
  ,   Attribute8                    VARCHAR2(150)
  ,   Attribute9                    VARCHAR2(150)
  ,   Attribute10                   VARCHAR2(150)
  ,   Attribute12                   VARCHAR2(150)
  ,   Attribute13                   VARCHAR2(150)
  ,   Attribute14                   VARCHAR2(150)
  ,   Attribute15                   VARCHAR2(150)
  ,   program_id                    NUMBER
  ,   Attribute3                    VARCHAR2(150)
  ,   Attribute7                    VARCHAR2(150)
  ,   Attribute11                   VARCHAR2(150)
  ,   Original_System_Reference   VARCHAR2(50)
        ,   From_End_Item_Unit_Number     VARCHAR2(30)     -- Added by MK on 11/02/00
        ,   New_Routing_Revision          VARCHAR2(3)      -- Added by MK on 11/02/00
        , Enforce_Int_Requirements           VARCHAR2(80)    -- 11.5.7 Enhancement 2101381
  ,   Return_Status                 VARCHAR2(1)
  ,   Transaction_Type        VARCHAR2(30)
  , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
 , Inverse_Quantity            NUMBER

 );


  TYPE Sub_Component_Tbl_Type IS TABLE OF Sub_Component_Rec_Type
      INDEX BY BINARY_INTEGER;

  TYPE Sub_Comp_Unexposed_Rec_Type IS RECORD
  (   Organization_Id      NUMBER
  ,   Component_Item_Id      NUMBER
  ,   Component_Sequence_Id    NUMBER
  ,   Revised_Item_Id      NUMBER
  ,   Substitute_Component_Id    NUMBER
  ,   New_Substitute_Component_Id    NUMBER   --Added by vhymavat for 11.5.9 enh, 2762683
  ,   Bill_Sequence_Id       NUMBER
  ,   Revised_Item_Sequence_Id     NUMBER
        , Enforce_Int_Requirements_Code  NUMBER            -- 11.5.7 Enhancement 2101381
  );


  --
  -- Inventory Components Exposed Record definition
  --
  TYPE Bom_Comps_Rec_Type IS RECORD
  (  Organization_Code    VARCHAR2(3)
   , Assembly_Item_Name   VARCHAR2(240) -- bug 2947642
   , Start_Effective_Date   DATE
   , Disable_Date     DATE
   , Operation_Sequence_Number  NUMBER
   , Component_Item_Name    VARCHAR2(240) -- bug 2947642
   , Alternate_BOM_Code   VARCHAR2(10)
   , New_Effectivity_Date   DATE
   , New_Operation_Sequence_Number NUMBER
   , Item_Sequence_Number   NUMBER
   , Basis_Type     	    NUMBER
   , Quantity_Per_Assembly  NUMBER
   , Inverse_Quantity          NUMBER
   , Planning_Percent   NUMBER
   , Projected_Yield    NUMBER
   , Include_In_Cost_Rollup NUMBER
   , Wip_Supply_Type    NUMBER
   , So_Basis     NUMBER
   , Optional     NUMBER
   , Mutually_Exclusive   NUMBER
   , Check_Atp      NUMBER
   , Shipping_Allowed   NUMBER
   , Required_To_Ship   NUMBER
   , Required_For_Revenue   NUMBER
   , Include_On_Ship_Docs   NUMBER
   , Quantity_Related   NUMBER
   , Supply_Subinventory    VARCHAR2(10)
   , Location_Name        VARCHAR2(81)
   , Minimum_Allowed_Quantity NUMBER
   , Maximum_Allowed_Quantity NUMBER
   , Comments     VARCHAR2(240)
   , Attribute_category   VARCHAR2(30)
   , Attribute1           VARCHAR2(150)
   , Attribute2           VARCHAR2(150)
   , Attribute3           VARCHAR2(150)
   , Attribute4           VARCHAR2(150)
   , Attribute5           VARCHAR2(150)
   , Attribute6           VARCHAR2(150)
   , Attribute7           VARCHAR2(150)
   , Attribute8           VARCHAR2(150)
   , Attribute9           VARCHAR2(150)
   , Attribute10          VARCHAR2(150)
   , Attribute11          VARCHAR2(150)
   , Attribute12          VARCHAR2(150)
   , Attribute13          VARCHAR2(150)
   , Attribute14          VARCHAR2(150)
   , Attribute15          VARCHAR2(150)
         , From_End_Item_Unit_Number    VARCHAR2(30)
         , New_From_End_Item_Unit_Number   VARCHAR2(30)
         , To_End_Item_Unit_Number      VARCHAR2(30)
   , Return_Status        VARCHAR2(1)
   , Transaction_Type   VARCHAR2(30)
   , Original_System_Reference  VARCHAR2(50)
         , Delete_Group_Name            VARCHAR2(10)      -- Added in 1155
         , DG_Description               VARCHAR2(240)     -- Added in 1155
        , Enforce_Int_Requirements       VARCHAR2(80)       -- 11.5.7 Enhancement 2101381
        , Auto_Request_Material        VARCHAR2(1)      -- Added in 11.5.9 by ADEY
        , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
	,  Suggested_Vendor_Name VARCHAR2(240) --- Deepu
--	,  Purchasing_Category  VARCHAR2(50) --- Deepu
--	,  Purchasing_Category_Id  NUMBER --- Deepu --- move to unexposed??
	,  Unit_Price		NUMBER --- Deepu
  );

        TYPE Bom_Comps_Tbl_Type IS TABLE OF Bom_Comps_Rec_Type
            INDEX BY BINARY_INTEGER;

  --
  -- Inventory Components Unexposed Record Definition
  --
  TYPE Bom_Comps_Unexposed_Rec_Type IS RECORD
  (  Assembly_Item_Id   NUMBER
   , Organization_Id    NUMBER
   , Supply_Locator_Id    NUMBER
   , Component_Item_Id    NUMBER
   , Component_Sequence_Id  NUMBER
   , Pick_Components    NUMBER
   , Bill_Sequence_Id   NUMBER
   , Include_On_Bill_Docs   NUMBER
   , Bom_Item_Type    NUMBER
         , DG_Sequence_Id               NUMBER            -- Added in 1155
         , Enforce_Int_Requirements_Code  NUMBER            -- 11.5.7 Enhancement 2101381
         , Rowid                        VARCHAR2(50)
   , BOM_Implementation_Date  DATE
   , Vendor_Id	NUMBER --- Deepu
   , Common_Component_Sequence_Id  NUMBER
   );

  --
  -- Reference Designator Exposed Record Definition
  --
  TYPE Bom_Ref_Designator_Rec_Type IS RECORD
  (  Organization_Code            VARCHAR2(3)
   , Assembly_Item_Name           VARCHAR2(240) -- bug 2947642
   , Start_Effective_Date         DATE
   , Operation_Sequence_Number    NUMBER
   , Component_Item_Name          VARCHAR2(240) -- bug 2947642
   , Alternate_Bom_Code           VARCHAR2(10)
   , Reference_Designator_Name    VARCHAR2(15)
   , Ref_Designator_Comment       VARCHAR2(240)
   , Attribute_category           VARCHAR2(30)
   , Attribute1                   VARCHAR2(150)
   , Attribute2                   VARCHAR2(150)
   , Attribute3                   VARCHAR2(150)
   , Attribute4                   VARCHAR2(150)
   , Attribute5                   VARCHAR2(150)
   , Attribute6                   VARCHAR2(150)
   , Attribute7                   VARCHAR2(150)
   , Attribute8                   VARCHAR2(150)
   , Attribute9                   VARCHAR2(150)
   , Attribute10                  VARCHAR2(150)
   , Attribute11                  VARCHAR2(150)
   , Attribute12                  VARCHAR2(150)
   , Attribute13                  VARCHAR2(150)
   , Attribute14                  VARCHAR2(150)
   , Attribute15                  VARCHAR2(150)
   , From_End_Item_Unit_Number    VARCHAR2(30)
   , Original_System_Reference    VARCHAR2(50)
   , New_Reference_Designator     VARCHAR2(15)
   , Return_Status                VARCHAR2(1)
   , Transaction_Type             VARCHAR2(30)
        , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
  );

  TYPE Bom_Ref_Desg_Unexp_Rec_Type IS RECORD
  (  Organization_Id    NUMBER
   , Assembly_Item_Id   NUMBER
   , Component_Item_Id    NUMBER
   , Component_Sequence_Id  NUMBER
   , Bill_Sequence_Id   NUMBER
   );

  TYPE Bom_Ref_Designator_Tbl_Type IS TABLE OF Bom_Ref_Designator_Rec_Type
      INDEX BY BINARY_INTEGER;

        --  Sub_Component record type

        TYPE Bom_Sub_Component_Rec_Type IS RECORD
  (   Organization_Code             VARCHAR2(3)
        ,   Assembly_Item_Name            VARCHAR2(240) -- bug 2947642
        ,   Start_Effective_Date          DATE
        ,   Operation_Sequence_Number     NUMBER
        ,   Component_Item_Name           VARCHAR2(240) -- bug 2947642
        ,   Alternate_BOM_Code            VARCHAR2(10)
--        ,   Substitute_Component_Name     VARCHAR2(81)
--        ,   New_Substitute_Component_Name     VARCHAR2(81) --Added by vhymavat for 11.5.9 enh, 2762683
        ,   Substitute_Component_Name     VARCHAR2(240) -- bug 2947642
        ,   New_Substitute_Component_Name     VARCHAR2(240) -- bug 2947642
        ,   Substitute_Item_Quantity      NUMBER
  ,   Attribute_category            VARCHAR2(30)
        ,   Attribute1                    VARCHAR2(150)
        ,   Attribute2                    VARCHAR2(150)
        ,   Attribute4                    VARCHAR2(150)
        ,   Attribute5                    VARCHAR2(150)
        ,   Attribute6                    VARCHAR2(150)
        ,   Attribute8                    VARCHAR2(150)
        ,   Attribute9                    VARCHAR2(150)
        ,   Attribute10                   VARCHAR2(150)
        ,   Attribute12                   VARCHAR2(150)
        ,   Attribute13                   VARCHAR2(150)
        ,   Attribute14                   VARCHAR2(150)
        ,   Attribute15                   VARCHAR2(150)
        ,   program_id                    NUMBER
        ,   Attribute3                    VARCHAR2(150)
        ,   Attribute7                    VARCHAR2(150)
        ,   Attribute11                   VARCHAR2(150)
  , From_End_Item_Unit_Number       VARCHAR2(30)
        , Enforce_Int_Requirements           VARCHAR2(80)    -- 11.5.7 Enhancement 2101381
        ,   Original_System_Reference     VARCHAR2(50)
        ,   Return_Status                 VARCHAR2(1)
        ,   Transaction_Type              VARCHAR2(30)
  , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
         ,   Inverse_Quantity              NUMBER             --  Added by hgelli for R12
  );

  TYPE Bom_Sub_Component_Tbl_Type  IS TABLE OF Bom_Sub_Component_Rec_Type
            INDEX BY BINARY_INTEGER;

        TYPE Bom_Sub_Comp_Unexp_Rec_Type IS RECORD
        (   Organization_Id                NUMBER
        ,   Component_Item_Id              NUMBER
        ,   Component_Sequence_Id          NUMBER
        ,   Substitute_Component_Id        NUMBER
        ,   New_Substitute_Component_Id        NUMBER        --Added by vhymavat for 11.5.9 enh, 2762683
        ,   Bill_Sequence_Id               NUMBER
  ,   Assembly_Item_Id       NUMBER
        , Enforce_Int_Requirements_Code  NUMBER            -- 11.5.7 Enhancement 2101381
        );

  --
  -- Component Operations Exposed Record definition (One to Many changes)
  --
  TYPE Bom_Comp_Ops_Rec_Type IS RECORD
  (  Organization_Code    VARCHAR2(3)
   , Assembly_Item_Name   VARCHAR2(240) -- bug 2947642
   , Start_Effective_Date   DATE
         , From_End_Item_Unit_Number    VARCHAR2(30)
         , To_End_Item_Unit_Number      VARCHAR2(30)
   , Operation_Sequence_Number  NUMBER
   , Additional_Operation_Seq_Num NUMBER
   , New_Additional_Op_Seq_Num  NUMBER    --Added by vhymavat for 11.5.9 enh, 2762683
   , Component_Item_Name    VARCHAR2(240) -- bug 2947642
   , Alternate_BOM_Code   VARCHAR2(10)
   , Attribute_category   VARCHAR2(30)
   , Attribute1           VARCHAR2(150)
   , Attribute2           VARCHAR2(150)
   , Attribute3           VARCHAR2(150)
   , Attribute4           VARCHAR2(150)
   , Attribute5           VARCHAR2(150)
   , Attribute6           VARCHAR2(150)
   , Attribute7           VARCHAR2(150)
   , Attribute8           VARCHAR2(150)
   , Attribute9           VARCHAR2(150)
   , Attribute10          VARCHAR2(150)
   , Attribute11          VARCHAR2(150)
   , Attribute12          VARCHAR2(150)
   , Attribute13          VARCHAR2(150)
   , Attribute14          VARCHAR2(150)
   , Attribute15          VARCHAR2(150)
   , Return_Status        VARCHAR2(1)
   , Transaction_Type   VARCHAR2(30)
  , Row_Identifier              NUMBER          := null --Added by vhymavat for 11.5.9
  );

        TYPE Bom_Comp_Ops_Tbl_Type  IS TABLE OF Bom_Comp_Ops_Rec_Type
            INDEX BY BINARY_INTEGER;

  --
  -- Component Opeeations Unexposed Record Definition
  --
  TYPE Bom_Comp_Ops_Unexp_Rec_Type IS RECORD
  (  Assembly_Item_Id   NUMBER
   , Organization_Id    NUMBER
   , Component_Item_Id    NUMBER
   , Component_Sequence_Id  NUMBER
   , Bill_Sequence_Id   NUMBER
   , Additional_Operation_Seq_Id  NUMBER
   , New_Additional_Op_Seq_Id NUMBER     --Added by vhymavat for 11.5.9 enh, 2762683
   , Comp_Operation_Seq_Id  NUMBER
   , Disable_Date     DATE
         , Rowid                        VARCHAR2(50)
   );

        -- Product Family header rec type
        --

        TYPE Bom_Product_Rec_Type IS RECORD
        (  Assembly_item_name           VARCHAR2(240)
         , Organization_code            VARCHAR2(3)
         , Attribute_Category           VARCHAR2(30)
         , Attribute1                   VARCHAR2(150)
         , Attribute2                   VARCHAR2(150)
         , Attribute3                   VARCHAR2(150)
         , Attribute4                   VARCHAR2(150)
         , Attribute5                   VARCHAR2(150)
         , Attribute6                   VARCHAR2(150)
         , Attribute7                   VARCHAR2(150)
         , Attribute8                   VARCHAR2(150)
         , Attribute9                   VARCHAR2(150)
         , Attribute10                  VARCHAR2(150)
         , Attribute11                  VARCHAR2(150)
         , Attribute12                  VARCHAR2(150)
         , Attribute13                  VARCHAR2(150)
         , Attribute14                  VARCHAR2(150)
         , Attribute15                  VARCHAR2(150)
         , Delete_Group_Name            VARCHAR2(10)
         , DG_Description               VARCHAR2(240)
         , Row_Identifier               NUMBER := null
         , Transaction_Type             VARCHAR2(30)
         , Return_Status                VARCHAR2(1));


	TYPE Bom_Product_Tab_Type IS TABLE OF Bom_Product_Rec_Type
              INDEX BY BINARY_INTEGER;

        --
        -- Product Family Members rec type
        --

        Type Bom_Product_Member_Rec_Type is RECORD
        (  Assembly_item_name           VARCHAR2(240)
         , Organization_code            VARCHAR2(3)
         , Component_item_name          VARCHAR2(240)
         , Planning_percent             NUMBER
         , Old_effectivity_date         DATE
         , Start_effective_date         DATE
         , New_effectivity_date         DATE
         , Disable_date                 DATE
         , Comments                     VARCHAR2(240)
         , Attribute_category           VARCHAR2(30)
         , Attribute1                   VARCHAR2(150)
         , Attribute2                   VARCHAR2(150)
         , Attribute3                   VARCHAR2(150)
         , Attribute4                   VARCHAR2(150)
         , Attribute5                   VARCHAR2(150)
         , Attribute6                   VARCHAR2(150)
         , Attribute7                   VARCHAR2(150)
         , Attribute8                   VARCHAR2(150)
         , Attribute9                   VARCHAR2(150)
	 , Attribute10                  VARCHAR2(150)
         , Attribute11                  VARCHAR2(150)
         , Attribute12                  VARCHAR2(150)
         , Attribute13                  VARCHAR2(150)
         , Attribute14                  VARCHAR2(150)
         , Attribute15                  VARCHAR2(150)
         , Delete_group_name            VARCHAR2(10)
         , Dg_description               VARCHAR2(240)
         , Return_status                VARCHAR2(1)
         , Transaction_type             VARCHAR2(30));

        TYPE Bom_Product_Mem_Tab_Type IS TABLE OF Bom_Product_Member_Rec_Type
         INDEX BY BINARY_INTEGER;
  --
  --
  -- Missing Records for BOM BO
  --
  G_MISS_BOM_HEADER_REC   Bom_Bo_Pub.Bom_Head_Rec_Type;
  G_MISS_BOM_HEADER_TBL   Bom_Bo_Pub.Bom_Header_Tbl_Type;
  G_MISS_BOM_COMPONENT_REC  Bom_Bo_Pub.Bom_Comps_Rec_Type;
  G_MISS_BOM_COMP_UNEXP_REC Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_type;
  G_MISS_BOM_COMPONENT_TBL  Bom_Bo_Pub.Bom_Comps_Tbl_Type;
  G_MISS_BOM_REF_DESIGNATOR_REC Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
  G_MISS_BOM_REF_DESG_UNEXP_REC Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type;
  G_MISS_BOM_REF_DESIGNATOR_TBL Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
  G_MISS_BOM_SUB_COMPONENT_REC  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
  G_MISS_BOM_SUB_COMP_UNEXP_REC Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type;
  G_MISS_BOM_SUB_COMPONENT_TBL  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
  G_MISS_BOM_REVISION_REC   Bom_Bo_Pub.Bom_Revision_Rec_Type;
  G_MISS_BOM_REV_UNEXP_REC  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type;
  G_MISS_BOM_REVISION_TBL   Bom_Bo_Pub.Bom_Revision_Tbl_Type;

        /* One to Many changes */
  G_MISS_BOM_COMP_OPS_REC   Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
  G_MISS_BOM_COMP_OPS_UNEXP_REC Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_type;
  G_MISS_BOM_COMP_OPS_TBL   Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;

	/* Product Family changes */
  G_MISS_BOM_PRD_REC		Bom_Bo_Pub.Bom_Product_Rec_Type;
  G_MISS_BOM_PRD_CMP_TBL		Bom_Bo_Pub.Bom_Product_Mem_Tab_Type;

  --
  -- Missing Records for ENG BO
  --
  G_MISS_REF_DESIGNATOR_REC Bom_Bo_Pub.Ref_Designator_Rec_Type;
  G_MISS_REF_DESG_UNEXP_REC Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
  G_MISS_REV_COMPONENT_REC  Bom_Bo_Pub.Rev_Component_Rec_Type;
  G_MISS_REV_COMP_UNEXP_REC Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
  G_MISS_SUB_COMPONENT_REC  Bom_Bo_Pub.Sub_Component_Rec_Type;
  G_MISS_SUB_COMP_UNEXP_REC Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
  G_MISS_REV_COMPONENT_TBL  Bom_Bo_Pub.Rev_Component_Tbl_Type;
  G_MISS_REF_DESIGNATOR_TBL Bom_Bo_Pub.Ref_Designator_Tbl_Type;
  G_MISS_SUB_COMPONENT_TBL  Bom_Bo_Pub.Sub_Component_Tbl_Type;


  PROCEDURE Convert_BomComp_To_EcoComp
  (  p_bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMPONENT_REC
   , p_bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMP_UNEXP_REC
   , x_rev_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
   , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
   );

  PROCEDURE Convert_EcoComp_To_BomComp
  (  p_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
            Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
         , p_rev_comp_unexp_rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
            Bom_Bo_Pub.G_MISS_REV_COMP_UNEXP_REC
   , x_bom_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
         , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         );


  PROCEDURE Convert_BomDesg_To_EcoDesg
  (  p_bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
            := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_REC
   , p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
            := Bom_Bo_Pub.G_MISS_BOM_REF_DESG_UNEXP_REC
   , x_ref_designator_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
   , x_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
   );

        PROCEDURE Convert_EcoDesg_To_BomDesg
        (  p_ref_designator_rec     IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
            := Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
         , p_ref_desg_unexp_rec     IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
            := Bom_Bo_Pub.G_MISS_REF_DESG_UNEXP_REC
   , x_bom_ref_designator_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
         , x_bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
         );

  PROCEDURE Convert_BomSComp_To_EcoSComp
  (  p_bom_sub_component_rec  IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
            := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_REC
   , p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
            := Bom_Bo_Pub.G_MISS_BOM_SUB_COMP_UNEXP_REC
   , x_sub_component_rec      IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
   , x_sub_comp_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
   );

  PROCEDURE Convert_EcoSComp_To_BomSComp
  (  p_sub_component_rec      IN  Bom_Bo_Pub.Sub_Component_Rec_Type
            := Bom_Bo_Pub.G_MISS_SUB_COMPONENT_REC
         , p_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
            := Bom_bo_Pub.G_MISS_SUB_COMP_UNEXP_REC
   , x_bom_sub_component_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
         , x_bom_sub_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
  );

 /*#
	* You can call this called for creating,updating or deleting of entities of single Structure/BOM all its Component and its child entities like
	* Reference Designators,Substitute Components and Component Operations. This method can be used when there are routings defined on	the Structure/BOM.
  * Every entity that needs to be processed must have a transaction type of either create,update,delete or sync.
  * If the transaction type is create and if a component is added then a
	* oracle.apps.bom.component.created event is raised.
  * If the transaction type is update and if the  component is updated  then a oracle.apps.bom.component.modified event is raised.
  * if the transaction type is delete and if the component is deleted then a oracle.apps.bom.component.deleteSuccess
	* event is reaised.
	* @param p_bo_identifier IN Business Object Identifier.The possible values are BOM and ECO.
	* @param p_api_version_number IN API Version Number
	* @param p_init_msg_list IN Message List Initializer
	* @param p_bom_header_rec IN Bom Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param p_bom_revision_tbl IN Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param p_bom_component_tbl IN Bom Inventorty Component exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param p_bom_ref_designator_tbl IN Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type}
	* @param p_bom_sub_component_tbl IN Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param p_bom_comp_ops_tbl  IN Component Operations Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type}
	* @param x_bom_header_rec IN OUT NOCOPY  processed Bom Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.bom_Head_Rec_Type}
	* @param x_bom_revision_tbl IN OUT NOCOPY  processed Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_bom_component_tbl IN OUT NOCOPY procesed Bom Inventory Components exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param x_bom_ref_designator_tbl IN OUT NOCOPY processed Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type}
	* @param x_bom_sub_component_tbl IN OUT NOCOPY processed Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param x_bom_comp_ops_tbl IN OUT NOCOPY processed Component Operations Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type}
	* @param x_return_status IN OUT NOCOPY End Result Status of the process being done on the passed entites.
	* @param x_msg_count IN OUT NOCOPY Message Count
	* @param p_debug IN Debug Flag
	* @param p_output_dir IN Output Directory
	* @param p_debug_filename IN Debug File Name
	* @param p_write_err_to_inttable IN Write Error to Interface Table flag
	* @param p_write_err_to_conclog IN Write Error to Concurrent Log Flag
	* @param p_write_err_to_debugfile IN Write Error to Debug File Flag
	* @rep:scope public
	* @rep:compatibility S
	* @rep:displayname Process Single Structure/BOM
	* @rep:lifecycle active
	* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
       */
        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
         , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
         , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type :=
        Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
         , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
         , p_bom_comp_ops_tbl        IN Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type :=
          Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
         , x_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
         , x_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , x_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_msg_count               IN OUT NOCOPY NUMBER
   , p_debug                   IN  VARCHAR2 := 'N'
   , p_output_dir              IN  VARCHAR2 := NULL
   , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
   , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
   , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
   , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
         );

 /*#
  * You can call this method for creating,updating or deleting entities of a single Structure/BOM.The method takes
	* in a single Structure/BOM header,all its Components,Revisions,Reference Designators and Substitute Components.
	* Every entity that needs to be processed must have a transaction type of either create,update,delete or sync.
  * If the transaction type is create and if a component is added then a oracle.apps.bom.component.created event is raised.
  * If the transaction type is update and if the  component is updated  then a oracle.apps.bom.component.modified event is raised
  * if the transaction type is delete and if the component is deleted  then a oracle.apps.bom.component.deleteSuccess event  is reaised.
	* @param p_bo_identifier IN Business Object Identifier.Possible values are BOM and ECO
	* @param p_api_version_number IN API Version Number
	* @param p_init_msg_list IN Message List Initializer
	* @param p_bom_header_rec IN Bom Header exposed column record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param p_bom_revision_tbl IN Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param p_bom_component_tbl IN Bom Inventorty Component exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param p_bom_ref_designator_tbl IN Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type}
	* @param p_bom_sub_component_tbl IN Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param x_bom_header_rec IN OUT NOCOPY processed Bom Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param x_bom_revision_tbl IN OUT NOCOPY processed Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_bom_component_tbl IN OUT NOCOPY processed Bom Inventory Components exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param x_bom_ref_designator_tbl IN OUT NOCOPY processed Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type}
	* @param x_bom_sub_component_tbl IN OUT NOCOPY processed Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param x_return_status IN OUT NOCOPY End Result Status for the process being done.
	* @param x_msg_count IN OUT NOCOPY  Message Count
	* @param p_debug IN Debug Flag
	* @param p_output_dir IN Output Directory
	* @param p_debug_filename IN Debug File Name
	* @param p_write_err_to_inttable IN Write Error to inttable flag
	* @param p_write_err_to_conclog IN Write Error to Concurrent Log Flag
	* @param p_write_err_to_debugfile IN Write Error to Debug File Flag
	* @rep:scope public
	* @rep:compatibility S
	* @rep:displayname Process Single Structure/BOM
	* @rep:lifecycle active
	* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */
        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
         , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
         , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type
                                    := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
         , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
         , x_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
         , x_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_msg_count               IN OUT NOCOPY NUMBER
   , p_debug                   IN  VARCHAR2 := 'N'
   , p_output_dir              IN  VARCHAR2 := NULL
   , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
   , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
   , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
   , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
         );

  /*

        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'EBOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bomheaders_tbl          IN  BOMHeadersTable
         , p_bomrevisions_tbl        IN  BOMRevisionsTable
         , p_bomcomponents_tbl       IN  BOMComponentsTable
         , p_bomrefdesignators_tbl   IN  BOMRefDesignatorsTable
         , p_bomsubcomponents_tbl    IN  BOMSubComponentsTable
         , p_bomcompoperations_tbl   IN  BOMCompOperationsTable
         , x_bomheaders_tbl          IN OUT NOCOPY BOMHeadersTable
         , x_bomrevisions_tbl        IN OUT NOCOPY BOMRevisionsTable
         , x_bomcomponents_tbl       IN OUT NOCOPY BOMComponentsTable
         , x_bomrefdesignators_tbl   IN OUT NOCOPY BOMRefDesignatorsTable
         , x_bomsubcomponents_tbl    IN OUT NOCOPY BOMSubComponentsTable
         , x_bomcompoperations_tbl   IN OUT NOCOPY BOMCompOperationsTable
         , x_process_return_status   IN OUT NOCOPY VARCHAR2
         , x_process_error_msg       IN OUT NOCOPY VARCHAR2
         , x_bo_return_status        IN OUT NOCOPY VARCHAR2
         , x_bo_msg_count            IN OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
   , p_write_err_to_inttable   IN  VARCHAR2 := 'N'
   , p_write_err_to_conclog    IN  VARCHAR2 := 'N'
   , p_write_err_to_debugfile  IN  VARCHAR2 := 'N'
         );

  */

  -- New Process_BOM wrapper for supporting multiple bom_header records

  /*#
  * You can call this method for creating,updating or deleting
	* multiple Structure/BOM and use it to manipulate more than one Structure
	* and its child entites in a single transaction.
  * It accepts a table of Strucure/Bom Headers,Components and the child entities for each of
	* the component such as substitute components,reference designators.
	* Every entity that needs to be processed must  have a
	* transaction type of either create,update,delete or sync .
	* Business Events for the successful processes are raised per entities.
	* If the transaction type is create and if a component is added then an
	* oracle.apps.bom.component.created event is raised.
  * If the transaction type is update and if the  component is updated
	* then a oracle.apps.bom.component.modified event is raised.
  * if the transaction type is delete and if the component is deleted  then a
	* oracle.apps.bom.component.deleteSuccess event is reaised.
	* @param p_bo_identifier IN Business Object Identifier.Possible values are BOM and ECO.
	* @param p_api_version_number IN API Version Number
	* @param p_init_msg_list IN Message List Initializer
	* @param p_bom_header_tbl IN Bom Header exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Header_Tbl_Type}
	* @param p_bom_revision_tbl IN Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param p_bom_component_tbl IN Bom Inventorty Component exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param p_bom_ref_designator_tbl IN Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type}
	* @param p_bom_sub_component_tbl IN Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param p_bom_comp_ops_tbl IN Component Operations Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type}
	* @param x_bom_header_tbl IN OUT NOCOPY processed Bom Header Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Header_Tbl_Type}
	* @param x_bom_revision_tbl IN OUT NOCOPY processed Bom Item Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_bom_component_tbl IN OUT NOCOPY processed Bom Inventory Components exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param x_bom_ref_designator_tbl IN OUT NOCOPY processed Reference Designator Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type}
	* @param x_bom_sub_component_tbl IN OUT NOCOPY processed Substitute Component Exposed Column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param x_bom_comp_ops_tbl IN OUT NOCOPY processed Component Operations Exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type}
	* @param x_return_status IN OUT NOCOPY End Result Status of the process being done.
	* @param x_msg_count IN OUT NOCOPY Message Count
	* @param p_debug IN Debug Flag
	* @param p_output_dir IN Output Directory
	* @param p_debug_filename IN Debug File Name
	* @rep:scope public
	* @rep:compatibility S
	* @rep:displayname Process Multiple Structures/BOM
	* @rep:lifecycle active
        * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	 */
        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_tbl          IN  Bom_Bo_Pub.Bom_Header_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_HEADER_TBL
         , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
         , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type
                                    := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
         , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
                                     := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
         , p_bom_comp_ops_tbl        IN Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
                                    := Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
         , x_bom_header_tbl          IN OUT NOCOPY Bom_Bo_Pub.bom_Header_Tbl_Type
         , x_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_bom_ref_designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , x_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_msg_count               IN OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
         );

	/*#
       * You can call this method for creating,updating or deleting a single component in Structure/BOM
       * Header.Use this method to add a single item as a component.
       * You need to have all the necessary attributes for adding the component and must
       * specify the attributes to be added as parameters.
       * The transaction type should be either create,update or delete.
       * If the transaction type is create and if a component is added then a oracle.apps.bom.components.created event is raised
       * If the transaction type is update and if the component is  updated  then a oracle.apps.bom.component.modified event is raised
       * if the transaction type is delete and if the component is successfully then a oracle.apps.bom.component.deleteSuccess event is raised
       * @param p_Component_Item_Name IN Component Item Name
       * @rep:paraminfo {@rep:required}
       * @param p_Organization_Code IN Organization Identifier
       * @rep:paraminfo {@rep:required}
       * @param p_Assembly_Item_Name IN Inventory item identifier of manufactured assembly
       * @rep:paraminfo {@rep:required}
       * @param p_Alternate_Bom_Code IN Alternate Bom Designator Code
       * @rep:paraminfo {@rep:required}
       * @param p_Quantity_Per_Assembly IN Quantity of Component per Assembly
       * @param p_Start_Effective_Date IN Effectivity Start Date
       * @param p_Disable_Date IN Component Disable Date
       * @param p_Implementation_Date IN Component Implementation Date
       * @param p_Debug IN Debug Flag
       * @param p_Debug_FileName IN Debug File Name
       * @param p_Output_Dir IN Output Directory for Debug File
       * @param x_error_message IN OUT NOCOPY Error Message
       * @rep:scope public
       * @rep:lifecycle active
       * @rep:displayname Process Single Component in Structure/BOM
       * @rep:compatibility S
       * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	*/
        PROCEDURE Process_BOM
        (
           p_Component_Item_Name        IN  VARCHAR2
         , p_Organization_Code          IN  VARCHAR2
         , p_Assembly_Item_Name         IN  VARCHAR2
         , p_Alternate_Bom_Code         IN  VARCHAR2
         , p_Quantity_Per_Assembly      IN  NUMBER := 1
         , p_Start_Effective_Date       IN  DATE := SYSDATE
         , p_Disable_Date               IN  DATE := NULL
         , p_Implementation_Date        IN  DATE := SYSDATE
         , p_Debug      IN  VARCHAR2 := 'N'
         , p_Debug_FileName   IN  VARCHAR2 := NULL
         , p_Output_Dir     IN  VARCHAR2 := NULL
         , x_error_message    OUT NOCOPY VARCHAR2
         );

	-- New Process_BOM wrapper for supporting product family Bills

 /*#
  * You can call this method for the  creating,updating or deleting Product Families.A Product Family
	* constitutes of a Product Family Header,the product family members and the allocation percentages of each of the members.
	* This method therefore accepts a header,the members and the allocations of the components .
	* Every entity that needs to be processed should have a transaction type of either create,update or delete.
	* If the transaction type is create and if a component is added then a oracle.apps.bom.component.created event is raised.
  * If the transaction type is update and if the  component is updated  then a
	* oracle.apps.bom.component.modified event is raised
  * if the transaction type is delete and if the component is deleted then
	* oracle.apps.bom.comopnent.deleteSuccess event is reaised.
  * @param p_bo_identifier IN Business Object Identifier.Possible values are BOM and ECO.
	* @param p_api_version_number IN API Version Number
	* @param p_init_msg_list IN Message List Initializer
	* @param p_bom_header_rec IN Bom Header exposed column record for product family
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Product_Rec_Type}
  * @param p_bom_component_tbl IN Bom Inventorty Component exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_bom_header_rec OUT NOCOPY processed Bom Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param x_bom_component_tbl OUT NOCOPY processed Bom Inventory Components exposed column table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_return_status OUT NOCOPY End Result status of the process being done.
	* @param x_msg_count OUT NOCOPY Message Count
	* @param p_debug IN Debug Flag
	* @param p_output_dir IN Output Directory
	* @param p_debug_filename IN Debug File Name
	* @rep:scope public
	* @rep:compatibility S
	* @rep:displayname Process Product Family
	* @rep:lifecycle active
	* @rep:category BUSINESS_ENTITY BOM_PRODUCT_FAMILY
  */
        PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Product_Rec_Type
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Product_Mem_Tab_Type
	 , x_bom_header_rec          OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
	 , x_bom_component_tbl       OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
        );

END Bom_Bo_Pub;

 

/
