--------------------------------------------------------
--  DDL for Package AHL_PP_MATERIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PP_MATERIALS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPPMS.pls 120.1.12010000.3 2008/11/19 06:00:59 jkjain ship $*/
--
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Req_Material_Rec_Type IS RECORD (
        SCHEDULE_MATERIAL_ID      NUMBER          ,
        OBJECT_VERSION_NUMBER     NUMBER          ,
        INVENTORY_ITEM_ID         NUMBER          ,
        SCHEDULE_DESIGNATOR       VARCHAR2(30)    ,
        VISIT_ID                  NUMBER          ,
        VISIT_START_DATE          DATE            ,
        VISIT_TASK_ID             NUMBER          ,
        ORGANIZATION_ID           NUMBER          ,
        SCHEDULED_DATE            DATE            ,
        REQUEST_ID                NUMBER          ,
        PROCESS_STATUS            NUMBER          ,
        ERROR_MESSAGE             VARCHAR2(120)   ,
        TRANSACTION_ID            NUMBER          ,
        CONCATENATED_SEGMENTS     VARCHAR2(40)    ,
        ITEM_DESCRIPTION          VARCHAR2(240)   ,
        RT_OPER_MATERIAL_ID       NUMBER          ,
        REQUESTED_QUANTITY        NUMBER          ,
        REQUESTED_DATE            DATE            ,
        UOM_CODE                  VARCHAR2(30)    ,
        UOM_MEANING               VARCHAR2(30)    ,
        SCHEDULED_QUANTITY        NUMBER          ,
        JOB_NUMBER                VARCHAR2(80)    ,
        REQUIRED_QUANTITY         NUMBER          ,
        QUANTITY_PER_ASSEMBLY     NUMBER          ,
        WORKORDER_ID              NUMBER          ,
        WIP_ENTITY_ID             NUMBER          ,
        OPERATION_SEQUENCE        NUMBER          ,
        OPERATION_CODE            VARCHAR2(80)    ,
        ITEM_GROUP_ID             NUMBER          ,
        SERIAL_NUMBER             NUMBER          ,
        INSTANCE_ID               NUMBER          ,
        SUPPLY_TYPE               NUMBER          ,
        SUB_INVENTORY             VARCHAR2(10)    ,
        LOCATION                  NUMBER          ,
        PROGRAM_ID                NUMBER          ,
        PROGRAM_UPDATE_DATE       DATE            ,
        LAST_UPDATED_DATE         DATE            ,
        DESCRIPTION               VARCHAR2(80)    ,
        DEPARTMENT_ID             NUMBER          ,
        PROJECT_TASK_ID           NUMBER          ,
        PROJECT_ID                NUMBER          ,
        WORKORDER_OPERATION_ID    NUMBER          ,
        STATUS                    VARCHAR2(30)    ,
	    ATTRIBUTE_CATEGORY        VARCHAR2(30)    ,
        ATTRIBUTE1                VARCHAR2(150)   ,
        ATTRIBUTE2                VARCHAR2(150)   ,
        ATTRIBUTE3                VARCHAR2(150)   ,
        ATTRIBUTE4                VARCHAR2(150)   ,
        ATTRIBUTE5                VARCHAR2(150)   ,
        ATTRIBUTE6                VARCHAR2(150)   ,
        ATTRIBUTE7                VARCHAR2(150)   ,
        ATTRIBUTE8                VARCHAR2(150)   ,
        ATTRIBUTE9                VARCHAR2(150)   ,
        ATTRIBUTE10               VARCHAR2(150)   ,
        ATTRIBUTE11               VARCHAR2(150)   ,
        ATTRIBUTE12               VARCHAR2(150)   ,
        ATTRIBUTE13               VARCHAR2(150)   ,
        ATTRIBUTE14               VARCHAR2(150)   ,
        ATTRIBUTE15               VARCHAR2(150)   ,
        MRP_NET_FLAG              NUMBER,
        NOTIFY_TEXT               VARCHAR2(3000)  ,
	OPERATION_FLAG            VARCHAR2(1)     ,
        REPAIR_ITEM		  VARCHAR2(1)
        );

TYPE Sch_Material_Rec_Type IS RECORD (
        SCHEDULE_MATERIAL_ID      NUMBER          ,
        OBJECT_VERSION_NUMBER     NUMBER          ,
        INVENTORY_ITEM_ID         NUMBER          ,
        CONCATENATED_SEGMENTS     VARCHAR2(40)    ,
        ITEM_DESCRIPTION          VARCHAR2(240)   ,
        RT_OPER_MATERIAL_ID       NUMBER          ,
        REQUESTED_QUANTITY        NUMBER          ,
        REQUEST_ID                NUMBER          ,
        VISIT_ID                  NUMBER          ,
        VISIT_TASK_ID             NUMBER          ,
        ORGANIZATION_ID           NUMBER          ,
        REQUESTED_DATE            DATE            ,
        UOM                       VARCHAR2(30)    ,
        SCHEDULED_QUANTITY        NUMBER          ,
        SCHEDULED_DATE            DATE            ,
        PROCESS_STATUS            NUMBER          ,
        JOB_NUMBER                VARCHAR2(30)    ,
        WORKORDER_ID              NUMBER          ,
        OPERATION_SEQUENCE        NUMBER          ,
        ITEM_GROUP_ID             NUMBER          ,
        SERIAL_NUMBER             NUMBER          ,
        SUB_INVENTORY             VARCHAR2(10)    ,
        LOCATION                  NUMBER          ,
        LOCATION_DESC             VARCHAR2(50)
        );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Req_Material_Tbl_Type IS TABLE OF Req_Material_Rec_Type INDEX BY BINARY_INTEGER;
TYPE Sch_Material_Tbl_Type IS TABLE OF Sch_Material_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Create_Material_Reqst
--  Type              : Private(Called from Material transactions API or intrenally
--                      called from process material request
--  Function          : Validates Material Information and inserts records into
--                      Schedule Material table for non routine jobs and loads record
--                      into MRP_SCHEDULE_INTERFACE table to Launche Concurrent Program to
--                      initiate material reservation
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_interface_flag                IN      VARCHAR2     Required
--      p_called_module                 IN      VARCHAR2     Default Null.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create Material Request Parameters:
--       p_x_req_material_tbl     IN OUT NOCOPY Req_Material_Tbl_Type,
--         Contains item information to perform material reservation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Material_Reqst (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_interface_flag         IN            VARCHAR2      ,
    p_x_req_material_tbl     IN OUT NOCOPY Req_Material_Tbl_Type,
    x_job_return_status         OUT NOCOPY        VARCHAR2,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  );


-- Start of Comments --
--  Procedure name    : Process_Material_Request
--  Type        : Private
--  Function    : Manages Create/Modify/Delete material requirements for routine and
--                non routine operations associated to a job.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Material Parameters :
--  p_x_req_material_tbl     IN OUT        Ahl_Pp_Material_Pvt.Req_Material_Tbl_Type,Required
--         List of Required materials for a job
--

PROCEDURE Process_Material_Request (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_req_material_tbl     IN OUT NOCOPY AHL_PP_MATERIALS_PVT.Req_Material_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2

);
-- Start of Comments --
--  Procedure name    : Process_Wo_Op_Materials
--  Type        : Private
--  Function    : Procedure to Process Requested materials defined at Route/Operation/Dispostion
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Material Parameters :
--  p_prd_wooperation_tbl    IN       AHL_PRD_WORKORDER_PVT.Prd_Workoper_Tbl,
--  x_req_material_tbl     OUT        Ahl_Pp_Material_Pvt.Req_Material_Tbl_Type,Required
--         List of Required materials for a job
--

PROCEDURE Process_Wo_Op_Materials (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_operation_flag         IN            VARCHAR2,
    p_prd_wooperation_tbl    IN  AHL_PRD_OPERATIONS_PVT.Prd_Operation_Tbl,
    x_req_material_tbl       OUT NOCOPY Req_Material_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   );

-- Function to get mrp net value
FUNCTION Get_Mrp_Net
 (p_schedule_material_id IN NUMBER,
  p_item_desc  IN VARCHAR2)  RETURN VARCHAR2;
--
FUNCTION GET_QTY_PER_ASBLY
    (p_schedule_material_id IN NUMBER,
     p_item_desc    IN VARCHAR2 ) RETURN NUMBER;
--
-- Start of Comments --
--  Procedure name    : Log_Transaction_Record
--  Type              : Private
--  Function          : Writes the details about a transaction in the Log Table
--                 AHL_WO_OPERATION_TXNS
--  Pre-reqs    :
--  Parameters  :
--
--  Log_Transaction Parameters:
--      p_trans_type_code               IN      VARCHAR2     Required
--      p_load_type_code                IN      NUMBER       Required
--      p_transaction_type_code         IN      NUMBER       Required
--      p_workorder_operation_id        IN      NUMBER       Default  NULL,
--      p_operation_resource_id         IN      NUMBER       Default  NULL,
--      p_schedule_material_id          IN      NUMBER       Default  NULL,
--      p_bom_resource_id               IN      NUMBER       Default  NULL,
--      p_cost_basis_code               IN      NUMBER       Default  NULL,
--      p_total_required                IN      NUMBER       Default  NULL,
--      p_assigned_units                IN      NUMBER       Default  NULL,
--      p_autocharge_type_code          IN      NUMBER       Default  NULL,
--      p_standard_rate_flag_code       IN      NUMBER       Default  NULL,
--      p_applied_resource_units        IN      NUMBER       Default  NULL,
--      p_applied_resource_value        IN      NUMBER       Default  NULL,
--      p_inventory_item_id             IN      NUMBER       Default  NULL,
--      p_scheduled_quantity            IN      NUMBER       Default  NULL,
--      p_scheduled_date                IN      DATE         Default  NULL,
--      p_mrp_net_flag                  IN      NUMBER       Default  NULL,
--      p_quantity_per_assembly         IN      NUMBER       Default  NULL,
--      p_required_quantity             IN      NUMBER       Default  NULL,
--      p_supply_locator_id             IN      NUMBER       Default  NULL,
--      p_supply_subinventory           IN      NUMBER       Default  NULL,
--      p_date_required                 IN      DATE         Default  NULL,
--      p_operation_type_code           IN      VARCHAR2     Default  NULL,
--      p_sched_start_date              IN      DATE         Default  NULL,
--      p_res_sched_end_date            IN      DATE         Default  NULL,
--      p_op_scheduled_start_date       IN      DATE         Default  NULL,
--      p_op_scheduled_end_date         IN      DATE         Default  NULL,
--      p_op_actual_start_date          IN      DATE         Default  NULL,
--      p_op_actual_end_date            IN      DATE         Default  NULL,
--      p_attribute_category            IN      VARCHAR2     Default  NULL,
--      p_attribute1                    IN      VARCHAR2     Default  NULL
--      p_attribute2                    IN      VARCHAR2     Default  NULL
--      p_attribute3                    IN      VARCHAR2     Default  NULL
--      p_attribute4                    IN      VARCHAR2     Default  NULL
--      p_attribute5                    IN      VARCHAR2     Default  NULL
--      p_attribute6                    IN      VARCHAR2     Default  NULL
--      p_attribute7                    IN      VARCHAR2     Default  NULL
--      p_attribute8                    IN      VARCHAR2     Default  NULL
--      p_attribute9                    IN      VARCHAR2     Default  NULL
--      p_attribute10                   IN      VARCHAR2     Default  NULL
--      p_attribute11                   IN      VARCHAR2     Default  NULL
--      p_attribute12                   IN      VARCHAR2     Default  NULL
--      p_attribute13                   IN      VARCHAR2     Default  NULL
--      p_attribute14                   IN      VARCHAR2     Default  NULL
--      p_attribute15                   IN      VARCHAR2     Default  NULL
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Log_Transaction_Record
    ( p_wo_operation_txn_id      IN   NUMBER,
      p_object_version_number    IN   NUMBER,
      p_last_update_date         IN   DATE,
      p_last_updated_by          IN   NUMBER,
      p_creation_date            IN   DATE,
      p_created_by               IN   NUMBER,
      p_last_update_login        IN   NUMBER,
      p_load_type_code           IN   NUMBER,
      p_transaction_type_code    IN   NUMBER,
      p_workorder_operation_id   IN   NUMBER   := NULL,
      p_operation_resource_id    IN   NUMBER   := NULL,
      p_schedule_material_id     IN   NUMBER   := NULL,
      p_bom_resource_id          IN   NUMBER   := NULL,
      p_cost_basis_code          IN   NUMBER   := NULL,
      p_total_required           IN   NUMBER   := NULL,
      p_assigned_units           IN   NUMBER   := NULL,
      p_autocharge_type_code     IN   NUMBER   := NULL,
      p_standard_rate_flag_code  IN   NUMBER   := NULL,
      p_applied_resource_units   IN   NUMBER   := NULL,
      p_applied_resource_value   IN   NUMBER   := NULL,
      p_inventory_item_id        IN   NUMBER   := NULL,
      p_scheduled_quantity       IN   NUMBER   := NULL,
      p_scheduled_date           IN   DATE     := NULL,
      p_mrp_net_flag             IN   NUMBER   := NULL,
      p_quantity_per_assembly    IN   NUMBER   := NULL,
      p_required_quantity        IN   NUMBER   := NULL,
      p_supply_locator_id        IN   NUMBER   := NULL,
      p_supply_subinventory      IN   NUMBER   := NULL,
      p_date_required            IN   DATE     := NULL,
      p_operation_type_code      IN   VARCHAR2 := NULL,
      p_res_sched_start_date     IN   DATE     := NULL,
      p_res_sched_end_date       IN   DATE     := NULL,
      p_op_scheduled_start_date  IN   DATE     := NULL,
      p_op_scheduled_end_date    IN   DATE     := NULL,
      p_op_actual_start_date     IN   DATE     := NULL,
      p_op_actual_end_date       IN   DATE     := NULL,
      p_attribute_category       IN   VARCHAR2 := NULL,
      p_attribute1               IN   VARCHAR2 := NULL,
      p_attribute2               IN   VARCHAR2 := NULL,
      p_attribute3               IN   VARCHAR2 := NULL,
      p_attribute4               IN   VARCHAR2 := NULL,
      p_attribute5               IN   VARCHAR2 := NULL,
      p_attribute6               IN   VARCHAR2 := NULL,
      p_attribute7               IN   VARCHAR2 := NULL,
      p_attribute8               IN   VARCHAR2 := NULL,
      p_attribute9               IN   VARCHAR2 := NULL,
      p_attribute10              IN   VARCHAR2 := NULL,
      p_attribute11              IN   VARCHAR2 := NULL,
      p_attribute12              IN   VARCHAR2 := NULL,
      p_attribute13              IN   VARCHAR2 := NULL,
      p_attribute14              IN   VARCHAR2 := NULL,
      p_attribute15              IN   VARCHAR2 := NULL);
--
FUNCTION GET_ISSUED_QTY(P_ORG_ID IN NUMBER, P_ITEM_ID IN NUMBER,
                        P_WORKORDER_OP_ID IN NUMBER) RETURN NUMBER;
 ---JKJAIN FP ER # 6436303------------------------------------------------------------
 	 -- Function for returning net quantity of material available with
 	 -- a workorder.
 	 -- Net Total Quantity = Total Quantity Issued - Total quantity returned
 	 -- Balaji added this function for OGMA ER # 5948868.
 --------------------------------------------------------------------------------------
 	 FUNCTION GET_NET_QTY(
 	            P_ORG_ID IN NUMBER,
 	            P_ITEM_ID IN NUMBER,
 	            P_WORKORDER_OP_ID IN NUMBER
 	          )
 	 RETURN NUMBER;

-- Start of Comments --
--  Procedure name    : Material_Notification
--  Type        : Private
--  Function    : Procedure to send material Notification when new item has been added
--                or quantity has been changed.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Material Notification Parameters :
--  p_Req_Material_Tbl          IN         Req_Material_Tbl_Type,
--

PROCEDURE  Material_Notification
(
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_Req_Material_Tbl          IN         Req_Material_Tbl_Type,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2
 );

--
END AHL_PP_MATERIALS_PVT;

/
