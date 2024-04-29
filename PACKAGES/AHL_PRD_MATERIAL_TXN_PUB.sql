--------------------------------------------------------
--  DDL for Package AHL_PRD_MATERIAL_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_MATERIAL_TXN_PUB" AUTHID CURRENT_USER AS
 /* $Header: AHLPMTXS.pls 120.3.12010000.3 2009/01/06 01:19:46 sracha ship $ */
/*#
 * Package containing API to perform material issue and return
 * transactions against cMRO workorders.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Workorder Material Transactions
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_WORKORDER
 */

-- Material Transaction record structure.
Type Ahl_Material_Txn_Rec_Type Is Record (

         Ahl_mtltxn_Id            NUMBER,  -- returned by the API.

         -- either workorder Id or workorder Name are mandatory.
         Workorder_Id             NUMBER,
         Workorder_Name           VARCHAR2(80),

         -- Operation sequence is mandatory.
         Operation_Seq_Num        NUMBER,

         -- Either of Transaction_Type_Id or Transaction_Type_Name is mandatory.
         -- Transaction_Type_Id = 35 for WIP Issue.
         -- Transaction_Type_Id = 43 for WIP Return.
         Transaction_Type_Id      NUMBER,
         Transaction_Type_Name    VARCHAR2(240),

         -- Either of Inventory_Item_Id or Inventory_Item_Segments is mandatory.
         Inventory_Item_Id        NUMBER,
         Inventory_Item_Segments  VARCHAR2(240),

         -- Either of UOM Code or Unit_Of_Measure is mandatory.
         Uom_Code                 VARCHAR2(3),
         Unit_Of_Measure          VARCHAR2(25),

         -- Quantity is mandatory.
         Quantity                 NUMBER,

         -- Serial_Number is mandatory for serial controlled items.
         Serial_Number            VARCHAR2(30),

         -- Lot_Number is mandatory for lot controlled items.
         Lot_Number               VARCHAR2(30),

         -- Revision is mandatory for revision controlled item.
         Revision                 VARCHAR2(3),

         -- Subinventory defaults from WIP Paramaters if not provided.
         Subinventory_Name        VARCHAR2(10),

         -- Locator defaults from WIP Parameters if not provided.
         -- Input Locator_Segments as segment values.
         -- Locator will be created if locator segment does not exist and
         -- dynamic locator creation is enabled.
         Locator_Id               NUMBER,
         Locator_Segments         VARCHAR2(240),
         --
         Transaction_Date         DATE,
         Transaction_Reference    VARCHAR2(240),

         -- Either of recepient_id or recepient_name is mandatory if profile
         -- 'AHL:Receipient required when transacting Materials' is set to 'Yes'. When it is not
         -- mandatory, this defaults to logged in user.
         recepient_id             NUMBER,
         recepient_name           VARCHAR2(60),

         -- disposition information if transaction is to be associated to one.
         disposition_id           NUMBER,

         -- Following attributes are used only during material returns.
         -- Either Condition or Condition_desc is mandatory.
         -- Qa_Collection_Id is mandatory if QA plan is associated when
         -- returning material to MRB.
         -- Sr_Summary is mandatory when returning material in unservicable or
         -- MRB condition to inventory.
         Item_Instance_Number     VARCHAR2(80),
         Item_Instance_ID         NUMBER,
         Condition                NUMBER,
         Condition_desc           VARCHAR2(80),
         Reason_Id                NUMBER,
         Reason_Name              VARCHAR2(240),
         Problem_Code             VARCHAR2(30),
         Problem_Code_Meaning     VARCHAR2(80),
         Sr_Summary               VARCHAR2(80),
         Qa_Collection_Id         NUMBER,

         -- 5/15/07: Added for ER# 6086051.
         -- Option for creating workorder for the non-routine. Valid values based on
         -- lookup type AHL_SR_WO_CREATE_OPTIONS. See details below:
         --
         -- Lookup Code                         Meaning
         -------------------------------------------------------------------
         -- CREATE_RELEASE_WO             	Create and Release Workorder
         -- CREATE_SR_NO                  	Do not create Non-Routine
         -- CREATE_WO                     	Create Unreleased Workorder
         -- CREATE_WO_NO                  	Do not create Workorder

         -- For serialized items, default is to create non-routine and no workorder.
         -- For non-serialized items, default is not to create a non-routine and workorder.
         create_wo_option         VARCHAR2(30),

         -- Target_Visit_Id and Target_Visit_Num are currently not used.
         Target_Visit_Id          NUMBER,
         Target_Visit_Num         NUMBER,

         -- Material txns DFF attributes.
         ATTRIBUTE_CATEGORY       VARCHAR2(30),
         ATTRIBUTE1               VARCHAR2(150),
         ATTRIBUTE2               VARCHAR2(150),
         ATTRIBUTE3               VARCHAR2(150),
         ATTRIBUTE4               VARCHAR2(150),
         ATTRIBUTE5               VARCHAR2(150),
         ATTRIBUTE6               VARCHAR2(150),
         ATTRIBUTE7               VARCHAR2(150),
         ATTRIBUTE8               VARCHAR2(150),
         ATTRIBUTE9               VARCHAR2(150),
         ATTRIBUTE10              VARCHAR2(150),
         ATTRIBUTE11              VARCHAR2(150),
         ATTRIBUTE12              VARCHAR2(150),
         ATTRIBUTE13              VARCHAR2(150),
         ATTRIBUTE14              VARCHAR2(150),
         ATTRIBUTE15              VARCHAR2(150)
         );

--  Declare Table record structure.
TYPE Ahl_Material_Txn_Tbl_Type IS TABLE OF Ahl_Material_Txn_Rec_Type INDEX BY BINARY_INTEGER;

/*#
 * Use this procedure to perform material issues from a SubInventory to a
 * Workorder OR return material from a Workorder to a SubInventory.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_default - currently not used. Pass FND_API.G_FALSE;default value FND_API.G_FALSE
 * @param p_x_material_txn_tbl - Table of type AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type to
 * contain material transaction details to be processed. Review record structure Ahl_Material_Txn_Rec_Type
 * for transaction attribute details.
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Perform material issue and return transactions
 */

PROCEDURE PERFORM_MATERIAL_TXN (
   p_api_version            IN            NUMBER,
   p_init_msg_list          IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                 IN            VARCHAR2   := FND_API.G_FALSE,
   p_default                IN            VARCHAR2   := FND_API.G_FALSE,
   p_x_material_txn_tbl     IN OUT NOCOPY AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
);


END AHL_PRD_MATERIAL_TXN_PUB;

/
