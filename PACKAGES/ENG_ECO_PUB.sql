--------------------------------------------------------
--  DDL for Package ENG_ECO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_PUB" AUTHID CURRENT_USER AS
/* $Header: ENGBECOS.pls 120.2.12010000.4 2013/07/16 18:44:43 umajumde ship $ */
/*#
 * API for processing of a single or multiple business object per call.
 * The entities in a  business object should belong to the same Change.
 * A single change business object is considered as a Change ENG Header
 * and all its child entities such as, revisions, revised items, components,
 * reference designators, substitute components, operations, their resources, etc.
 * Every business object entity must have a transaction type.
 * Valid Transaction Types are Create,Update
 * This package performs integrity check and validation through the Process_Eco procedure.
 * If the validations are successful,it populates the base production-tables.
 * In case of validation failure it populates the interface tables with proper error messages.
 * @rep:scope public
 * @rep:product ENG
 * @rep:lifecycle active
 * @rep:displayname Create or Update Change
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY ENG_CHANGE_ORDER
 */


--  Eco record type

TYPE Eco_Rec_Type IS RECORD
(   Eco_Name                      VARCHAR2(10)
,   Change_Notice_Prefix          VARCHAR2(10)
,   Change_Notice_Number          NUMBER
,   Organization_Code             VARCHAR2(3)
,   Change_Name                   VARCHAR2(240)
,   Description                   VARCHAR2(2000)
,   Cancellation_Comments         VARCHAR2(240)
,   Status_Name                   VARCHAR2(30)
,   Priority_Code                 VARCHAR2(10)
,   Reason_Code                   VARCHAR2(10)
,   Eng_Implementation_Cost       NUMBER
,   Mfg_implementation_Cost       NUMBER
,   Requestor                     VARCHAR2(100)
,   Attribute_category            VARCHAR2(30)
,   Attribute1                    VARCHAR2(150)
,   Attribute2                    VARCHAR2(150)
,   Attribute3                    VARCHAR2(150)
,   Attribute4                    VARCHAR2(150)
,   Attribute5                    VARCHAR2(150)
,   Attribute6                    VARCHAR2(150)
,   Attribute8                    VARCHAR2(150)
,   Attribute7                    VARCHAR2(150)
,   Attribute9                    VARCHAR2(150)
,   Attribute10                   VARCHAR2(150)
,   Attribute11                   VARCHAR2(150)
,   Attribute12                   VARCHAR2(150)
,   Attribute13                   VARCHAR2(150)
,   Attribute14                   VARCHAR2(150)
,   Attribute15                   VARCHAR2(150)
,   Ddf_Context                   VARCHAR2(30)
,   Approval_List_Name            VARCHAR2(10)
,   Approval_Status_Name          VARCHAR2(80)
,   Approval_Date                 DATE
,   Approval_Request_Date         DATE
,   Change_Type_Code              VARCHAR2(80)
,   Change_Management_Type        VARCHAR2(45)
,   Original_System_Reference     VARCHAR2(50)
,   Organization_Hierarchy        VARCHAR2(30)
,   Assignee                      VARCHAR2(360)
,   Project_Name                  VARCHAR2(30)
,   Task_Number                   VARCHAR2(25)
,   Source_Type                   VARCHAR2(80)
,   Source_Name                   VARCHAR2(80)
,   Need_By_Date                  DATE
,   Effort                        NUMBER
,   Eco_Department_Name           VARCHAR2(240)--Bug 2925982
,   Transaction_Id                NUMBER
,   Transaction_Type              VARCHAR2(10)
,   Internal_Use_Only             VARCHAR2(1)
,   Return_Status                 VARCHAR2(1)
,   plm_or_erp_change             VARCHAR2(3) --11.5.10 to differentiate between ERP/PLM records
--11.5.10  subject for header
,   pk1_name            VARCHAR2(240)
,   pk2_name            VARCHAR2(240)
,   pk3_name            VARCHAR2(240)
--11.5.10
,   Employee_Number     per_people_f.EMPLOYEE_NUMBER%type  --* Added for Bug 4402842
);


TYPE Eco_Tbl_Type IS TABLE OF Eco_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Eco Record of unexposed columns
TYPE Eco_Unexposed_Rec_Type IS RECORD
(   Organization_Id              NUMBER
,   Initiation_Date              DATE
,   Implementation_Date          DATE
,   Cancellation_Date            DATE
,   Requestor_Id                 NUMBER
,   Approval_List_Id             NUMBER
,   Change_Order_Type_Id         NUMBER
,   Change_Mgmt_Type_Code        VARCHAR2(30)
,   Assignee_Id                  NUMBER
,   Assignee_Type                VARCHAR2(30) --bug 15871819 change the size from 10 to 30
,   Source_Type_Code             VARCHAR2(30)
,   Source_Id                    NUMBER
,   Status_Type                  NUMBER
,   Approval_Status_Type         NUMBER
,   Project_Id                   NUMBER
,   Task_Id                   NUMBER
,   Responsible_Org_Id           NUMBER
,   Responsible_Org_Code         VARCHAR2(3)
,   Change_Id                    NUMBER
,   Hierarchy_Id                 NUMBER
,  Status_Code                   NUMBER

);

--  Eco_Revision record type

TYPE Eco_Revision_Rec_Type IS RECORD
(   Eco_Name                      VARCHAR2(10)
,   Organization_code             VARCHAR2(3)
,   Revision                      VARCHAR2(10)
,   New_Revision                  VARCHAR2(10)
,   Comments                      VARCHAR2(240)
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
,   Change_Management_Type        VARCHAR2(45)
,   Original_System_Reference     VARCHAR2(50)
,   Return_Status                 VARCHAR2(1)
,   Transaction_Type              VARCHAR2(30)
,   Transaction_Id                NUMBER
);

TYPE Eco_Revision_Tbl_Type IS TABLE OF Eco_Revision_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Eco Revision record of unexposed columns
TYPE Eco_Rev_Unexposed_Rec_Type IS RECORD
(   Organization_Id               NUMBER
,   Revision_Id                   NUMBER
,   Change_Mgmt_Type_Code         VARCHAR2(30)
,   Change_Id                     NUMBER
);

--  Revised_Item record type

TYPE Revised_Item_Rec_Type IS RECORD
(   Eco_Name                      VARCHAR2(10)
,   Organization_Code             VARCHAR2(3)
,   Revised_Item_Name             VARCHAR2(700)
,   New_Revised_Item_Revision     VARCHAR2(3)
,   New_Revised_Item_Rev_Desc     VARCHAR2(240)
,   Updated_Revised_Item_Revision VARCHAR2(3)
,   Start_Effective_Date          DATE
,   New_Effective_Date            DATE
,   Alternate_Bom_Code            VARCHAR2(10)
,   Status_Type                   NUMBER
,   Mrp_Active                    NUMBER
,   Earliest_Effective_Date       DATE
,   Use_Up_Item_Name              VARCHAR2(700)
,   Use_Up_Plan_Name              VARCHAR2(10)
,   Requestor                     VARCHAR2(30)
,   Disposition_Type              NUMBER
,   Update_Wip                    NUMBER
,   Cancel_Comments               VARCHAR2(240)
,   Change_Description            VARCHAR2(240)
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
,   From_End_Item_Unit_Number     VARCHAR2(30)
,   New_From_End_Item_Unit_Number VARCHAR2(30)
,   Original_System_Reference     VARCHAR2(50)
,   Return_Status                 VARCHAR2(1)
,   Transaction_Type              VARCHAR2(30)
,   Transaction_Id                NUMBER
,   From_Work_Order               VARCHAR2(150)
,   To_Work_Order                 VARCHAR2(150)
,   From_Cumulative_Quantity      NUMBER
,   Lot_Number                    VARCHAR2(30)
,   Completion_Subinventory       VARCHAR2(10)
,   Completion_Location_Name      VARCHAR2(81)
,   Priority                      NUMBER
,   Ctp_Flag                      NUMBER
,   New_Routing_Revision          VARCHAR2(3)
,   Updated_Routing_Revision      VARCHAR2(3)
,   Routing_Comment               VARCHAR2(240)
,   Eco_For_Production            NUMBER
,   Change_Management_Type        VARCHAR2(45)
,   Transfer_Or_Copy              VARCHAR2(1)
,   Transfer_OR_Copy_Item         NUMBER
,   Transfer_OR_Copy_Bill         NUMBER
,   Transfer_OR_Copy_Routing      NUMBER
,   Copy_To_Item                  VARCHAR2(2000)
,   Copy_To_Item_Desc             VARCHAR2(240)
,   parent_revised_item_name      VARCHAR2(240)
,   parent_alternate_name         VARCHAR2(240)
,   selection_option              NUMBER
,   selection_date                DATE
,   selection_unit_number         VARCHAR2(30)
,   current_lifecycle_phase_name  VARCHAR2(240)
,   new_lifecycle_phase_name      VARCHAR2(240)
,   from_end_item_revision        VARCHAR2(3)
,   from_end_item_strc_rev        VARCHAR2(80)
,   enable_item_in_local_org      VARCHAR2(1)
,   create_bom_in_local_org       VARCHAR2(1)
,   new_structure_revision        VARCHAR2(80)
,   plan_level                    NUMBER
,   from_end_item_name            VARCHAR2(700)
,   FROM_END_ITEM_ALTERNATE       VARCHAR2(10)
,   current_structure_rev_name    VARCHAR2(80)
,   reschedule_comments           VARCHAR2(240) -- Bug 3589974
,   From_Item_Revision            VARCHAR2(3) -- 11.5.10E
,   New_Revision_Label            VARCHAR2(80)
,   New_Revision_Reason           VARCHAR2(80)
,   Structure_Type_Name           VARCHAR2(80)
,   alternate_selection_code        NUMBER --bug 16340624
);

TYPE Revised_Item_Tbl_Type IS TABLE OF Revised_Item_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Revised Item Record of unexposed columns
TYPE Rev_Item_Unexposed_Rec_Type IS RECORD
(   Organization_Id                 NUMBER
,   Revised_Item_Id                 NUMBER
,   Implementation_Date             DATE
,   Auto_Implement_Date             DATE
,   Cancellation_Date               DATE
,   Bill_Sequence_Id                NUMBER
,   Use_Up_Item_Id                  NUMBER
,   Use_Up                          NUMBER
,   Requestor_id                    NUMBER
,   Revised_Item_Sequence_Id        NUMBER
,   Routing_Sequence_Id             NUMBER
,   From_Wip_Entity_Id              NUMBER
,   To_Wip_Entity_Id                NUMBER
,   CFM_Routing_Flag                NUMBER
,   Completion_Locator_Id           NUMBER
,   Change_Mgmt_Type_Code           VARCHAR2(30)
,   Change_Id                       NUMBER
,   parent_revised_item_seq_id      NUMBER
,   new_item_revision_id            NUMBER
,   current_item_revision_id        NUMBER
,   current_lifecycle_state_id      NUMBER
,   new_lifecycle_state_id          NUMBER
,   from_end_item_revision_id       NUMBER
,   from_end_item_struct_rev_id     NUMBER
,   current_structure_rev_id        NUMBER
,   from_end_item_id                NUMBER
,   status_code                     NUMBER  -- Added for bug 3618676
,   from_item_revision_id           NUMBER -- 11.5.10E
,   new_revision_reason_code        VARCHAR2(30)
,   Structure_Type_Id               NUMBER
);

TYPE Change_Subject_Unexp_Rec_Type IS RECORD
( Change_Id               NUMBER
, Change_Line_Id                NUMBER
, Change_Subject_Id                NUMBER
, Entity_Name                   VARCHAR2(30)
, Pk1_Value                     VARCHAR2(100)
, Pk2_Value                     VARCHAR2(100)
, Pk3_Value                     VARCHAR2(100)
, Pk4_Value                     VARCHAR2(100)
, Pk5_Value                     VARCHAR2(100)
, Subject_Level                   NUMBER
,Lifecycle_state_Id                     NUMBER
);






--  Change Line record type
TYPE Change_Line_Rec_Type IS RECORD
(   Eco_Name                      VARCHAR2(10)
,   Organization_Code             VARCHAR2(3)
,   Change_Management_Type        VARCHAR2(45)
--,   Change_Type_Code              VARCHAR2(10)
--Bug No: 3463472
--Issue: DEF-1694
--Description: Increased the length of the column to 80.
,   Change_Type_Code              VARCHAR2(80)
,   Name                          VARCHAR2(240)
,   Description                   VARCHAR2(2000)
,   Sequence_Number               NUMBER
,   Status_Name                   VARCHAR2(80)
--,   Item_Name                     VARCHAR2(700)
--,   Item_Revision                 VARCHAR2(3)
,   Object_Display_Name           VARCHAR2(240)
,   Pk1_Name                      VARCHAR2(240)
,   Pk2_Name                      VARCHAR2(240)
,   Pk3_Name                      VARCHAR2(240)
,   Pk4_Name                      VARCHAR2(240)
,   Pk5_Name                      VARCHAR2(240)
,   Assignee_Name                 VARCHAR2(360)
,   Scheduled_Date                DATE
,   Need_By_Date                  DATE
,   Implementation_Date           DATE
,   Cancelation_Date              DATE
,   Original_System_Reference     VARCHAR2(50)
,   Return_Status                 VARCHAR2(1)
,   Transaction_Type              VARCHAR2(30)
,   Required_Flag                            VARCHAR2(1)
,   Complete_Before_Status_Code              NUMBER
,   Start_After_Status_Code                  NUMBER
) ;

TYPE Change_Line_Tbl_Type IS TABLE OF Change_Line_Rec_Type
     INDEX BY BINARY_INTEGER;

-- Change Line unexposed record type
TYPE Change_Line_Unexposed_Rec_Type IS RECORD
( Organization_Id               NUMBER
, Change_Line_Id                NUMBER
, Change_Type_Id                NUMBER
, Status_Code                   VARCHAR2(30)
--, Item_Id                       NUMBER
--, Item_Revision_Id              NUMBER
, Object_Id                     NUMBER
, Object_Name                   VARCHAR2(430)--bug no 4146289
, Pk1_Value                     VARCHAR2(100)
, Pk2_Value                     VARCHAR2(100)
, Pk3_Value                     VARCHAR2(100)
, Pk4_Value                     VARCHAR2(100)
, Pk5_Value                     VARCHAR2(100)
, Assignee_Id                   NUMBER
, Change_Id                     NUMBER
, Approval_Status_Type          NUMBER    --Added as it is mandatory
);

--  Variables representing missing records
G_MISS_ECO_REC                Eco_Rec_Type;
G_MISS_ECO_REVISION_REC       Eco_Revision_Rec_Type;
G_MISS_ECO_REVISION_TBL       Eco_Revision_Tbl_Type;
G_MISS_REVISED_ITEM_REC       Revised_Item_Rec_Type;
G_MISS_REVISED_ITEM_TBL       Revised_Item_Tbl_Type;
G_MISS_REV_COMPONENT_REC      Bom_Bo_Pub.Rev_Component_Rec_Type;
G_MISS_REV_COMPONENT_TBL      Bom_Bo_Pub.Rev_Component_Tbl_Type;
G_MISS_REF_DESIGNATOR_REC     Bom_Bo_Pub.Ref_Designator_Rec_Type;
G_MISS_REF_DESIGNATOR_TBL     Bom_Bo_Pub.Ref_Designator_Tbl_Type;
G_MISS_SUB_COMPONENT_REC      Bom_Bo_Pub.Sub_Component_Rec_Type;
G_MISS_SUB_COMPONENT_TBL      Bom_Bo_Pub.Sub_Component_Tbl_Type;
--L1
G_MISS_REV_OPERATION_TBL      Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
G_MISS_REV_OP_RESOURCE_TBL    Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type ;
G_MISS_REV_SUB_RESOURCE_TBL   Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;

G_MISS_REV_OPERATION_REC      Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
G_MISS_REV_OP_RESOURCE_REC    Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type ;
G_MISS_REV_SUB_RESOURCE_REC   Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type ;
G_MISS_REV_OP_UNEXP_REC       Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;
G_MISS_REV_OP_RES_UNEXP_REC   Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type ;
G_MISS_REV_SUB_RES_UNEXP_REC  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type ;
--L1

-- Eng Change
G_MISS_CHANGE_LINE_REC        Change_Line_Rec_Type ;
G_MISS_CHANGE_LINE_TBL        Change_Line_Tbl_Type ;
G_MISS_CHANGE_LINE_UNEXP_REC  Change_Line_Unexposed_Rec_Type ;


--  Start of Comments
--  API name    Process_Eco
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

/*#
* This procedure is used to create,update Engineering Change Order (ECO)
* It verifies the integrity of the
* ECO business object and calls the private API which
* further drives the business object to perform business
* logic validations.
* @param p_api_version_number API Version Number
* @param p_init_msg_list Message List Initializer
* @param x_return_status Status of the Business Object
* @param x_msg_count Number of messages in the API message stack
* @param p_bo_identifier Business Object Identifier
* @param p_ECO_rec ECO Header exposed column record
* @param p_eco_revision_tbl Eco Revision exposed Column Table
* @param p_revised_item_tbl Eng Revised Items exposed column table
* @param p_rev_component_tbl Eng Revised Components exposed column table
* @param p_ref_designator_tbl Reference Designator exposed column table
* @param p_sub_component_tbl Substitute Component exposed Column table
* @param p_rev_operation_tbl Eng Revised Operations exposed column table
* @param p_rev_op_resource_tbl Eng Revised operation resources exposed Column table
* @param p_rev_sub_resource_tbl Eng Revised Sub Resources exposed Column table
* @param x_ECO_rec processed ECO Header exposed column record
* @param x_eco_revision_tbl processed Eco Revision exposed Column Table
* @param x_revised_item_tbl processed Eng Revised Items exposed column table
* @param x_rev_component_tbl processed Eng Revised Components exposed column table
* @param x_ref_designator_tbl processed Reference Designator exposed column table
* @param x_sub_component_tbl processed Substitute Component exposed Column table
* @param x_rev_operation_tbl processed Eng Revised Operations exposed column table
* @param x_rev_op_resource_tbl processed Eng Revised operation resources exposed Column table
* @param x_rev_sub_resource_tbl processed Eng Revised Sub Resources exposed Column table
* @param p_debug Debug Flag
* @param p_output_dir Output Directory
* @param p_debug_filename Debug File Name
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Process Change
*/
PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER  := 1.0
,   p_init_msg_list             IN  BOOLEAN := FALSE
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
,   p_ECO_rec                   IN  Eco_Rec_Type :=
                                    G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  Eco_Revision_Tbl_Type :=
                                    G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl          IN  Revised_Item_Tbl_Type :=
                                    G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  Bom_Bo_Pub.Rev_Component_Tbl_Type :=
                                    G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type :=
                                    G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  Bom_Bo_Pub.Sub_Component_Tbl_Type :=
                                    G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL    --L1
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type:=  --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL  --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY Eco_Revision_Tbl_Type
,   x_revised_item_tbl          IN OUT NOCOPY Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   p_debug                     IN  VARCHAR2 := 'N'
,   p_output_dir                IN  VARCHAR2 := NULL
,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
,   p_skip_nir_expl             IN  VARCHAR2 DEFAULT FND_API.G_FALSE  -- bug 15831337: skip nir explosion flag
);


--  Start of Comments
--  API name    Process_Eco
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--        Eng Change Enhancement: New Process Eco with new entities
--  End of Comments

/*#
* This procedure is used to create, update issues, change request, and Engineering Change Order (ECO) \n\
* in Product Lifecycle Management.It verifies the integrity of the
* ECO business object and calls the private API which
* further drives the business object to perform business
* logic validations.This is overloaded API which processes Change Lines for Change header
* along with other child entities like revisions,revised items, components, reference designators,
* substitute components,operations and their resources,etc.
* @param p_api_version_number API Version Number
* @param p_init_msg_list Message List Initializer
* @param x_return_status Status of the Business Object
* @param x_msg_count Number of messages in the API message stack
* @param p_bo_identifier Business Object Identifier
* @param p_ECO_rec ECO Header exposed column record
* @param p_eco_revision_tbl Eco Revision exposed Column Table
* @param p_change_line_tbl Eng Change Line exposed Column Table
* @param p_revised_item_tbl Eng Revised Items exposed column table
* @param p_rev_component_tbl Eng Revised Components exposed column table
* @param p_ref_designator_tbl Reference Designator exposed column table
* @param p_sub_component_tbl Substitute Component exposed Column table
* @param p_rev_operation_tbl Eng Revised Operations exposed column table
* @param p_rev_op_resource_tbl Eng Revised operation resources exposed Column table
* @param p_rev_sub_resource_tbl Eng Revised Sub Resources exposed Column table
* @param x_ECO_rec processed ECO Header exposed column record
* @param x_eco_revision_tbl processed Eco Revision exposed Column Table
* @param x_change_line_tbl processed Eng Change Line exposed Column Table
* @param x_revised_item_tbl processed Eng Revised Items exposed column table
* @param x_rev_component_tbl processed Eng Revised Components exposed column table
* @param x_ref_designator_tbl processed Reference Designator exposed column table
* @param x_sub_component_tbl processed Substitute Component exposed Column table
* @param x_rev_operation_tbl processed Eng Revised Operations exposed column table
* @param x_rev_op_resource_tbl processed Eng Revised operation resources exposed Column table
* @param x_rev_sub_resource_tbl processed Eng Revised Sub Resources exposed Column table
* @param p_debug Debug Flag
* @param p_output_dir Output Directory
* @param p_debug_filename Debug File Name
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Process Change
*/
PROCEDURE Process_Eco
(   p_api_version_number        IN  NUMBER  := 1.0
,   p_init_msg_list             IN  BOOLEAN := FALSE
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_msg_count                 OUT NOCOPY NUMBER
,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
,   p_ECO_rec                   IN  Eco_Rec_Type :=
                                    G_MISS_ECO_REC
,   p_eco_revision_tbl          IN  Eco_Revision_Tbl_Type :=
                                    G_MISS_ECO_REVISION_TBL
,   p_change_line_tbl           IN  Change_Line_Tbl_Type :=   -- Eng Change
                                    G_MISS_CHANGE_LINE_TBL
,   p_revised_item_tbl          IN  Revised_Item_Tbl_Type :=
                                    G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl         IN  Bom_Bo_Pub.Rev_Component_Tbl_Type :=
                                    G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl        IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type :=
                                    G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl         IN  Bom_Bo_Pub.Sub_Component_Tbl_Type :=
                                    G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=    --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL    --L1
,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type:=  --L1
                                    Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL  --L1
,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:= --L1
                                    Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL --L1
,   x_ECO_rec                   IN OUT NOCOPY Eco_Rec_Type
,   x_eco_revision_tbl          IN OUT NOCOPY Eco_Revision_Tbl_Type
,   x_change_line_tbl           IN OUT NOCOPY Change_Line_Tbl_Type      -- Eng Change
,   x_revised_item_tbl          IN OUT NOCOPY Revised_Item_Tbl_Type
,   x_rev_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
,   x_ref_designator_tbl        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
,   x_sub_component_tbl         IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
,   x_rev_operation_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type    --L1--
,   x_rev_op_resource_tbl       IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type  --L1--
,   x_rev_sub_resource_tbl      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type --L1--
,   p_debug                     IN  VARCHAR2 := 'N'
,   p_output_dir                IN  VARCHAR2 := NULL
,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
,   p_skip_nir_expl             IN  VARCHAR2 DEFAULT FND_API.G_FALSE  -- bug 15831337: skip nir explosion flag
);



END ENG_Eco_PUB;

/
