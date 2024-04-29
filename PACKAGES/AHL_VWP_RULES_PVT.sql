--------------------------------------------------------
--  DDL for Package AHL_VWP_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRULS.pls 120.1.12010000.4 2010/03/28 10:30:23 manesing ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_RULES_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> VISIT, TASKS, PROJECT, PRODUCTION, PRICING, COSTING
--    related RULES as procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
--      Check_Serial_No_by_UConfig       (see below for specification)
--      Check_Item_name_Or_Id            (see below for specification)
--      Check_Serial_name_Or_Id          (see below for specification)
--      Check_SR_request_number_Or_Id    (see below for specification)
--      Check_Visit_Task_Number_Or_Id    (see below for specification)
--      Check_Lookup_name_Or_Id          (see below for specification)
--      Check_Org_Name_Or_Id             (see below for specification)
--      Check_Dept_Desc_Or_Id            (see below for specification)
--      Check_Visit_is_Simulated         (see below for specification)
--      Check_Project_Template_Or_Id     (see below for specification)
--      Check_Proj_Responsibility        (see below for specification)
--      Check_Cost_Parent_Loop           (see below for specification)
--      Check_Origin_Task_Loop           (see below for specification)

--      Create_Tasks_for_MR              (see below for specification)
--      Get_Serial_Item_by_Unit          (see below for specification)
--      Tech_Dependency                  (see below for specification)
--      Insert_Tasks                     (see below for specification)

--  FUNCTION
--      Get_Cost_Originating_Id          (see below for specification)
--      Get_Visit_Task_Id                (see below for specification)
--      Get_Visit_Task_Number            (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 03-MAY-2003    shbhanda      Created.
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.
-- 17-FEB-2010    manisaga	added route_id to Task_rec_type for navigation to route page
--------------------------------------------------------------------

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
-- Record for Visit Task
TYPE Task_Rec_Type IS RECORD (
  VISIT_TASK_ID           NUMBER         := NULL,
  VISIT_TASK_NUMBER       NUMBER         := NULL,
  VISIT_ID                NUMBER         := NULL,
  TEMPLATE_FLAG           VARCHAR2(1)    := 'N',
  INVENTORY_ITEM_ID       NUMBER         := NULL,
  ITEM_ORGANIZATION_ID    NUMBER         := NULL,
  ITEM_NAME               VARCHAR2(40)   := NULL,
  COST_PARENT_ID          NUMBER         := NULL,
  COST_PARENT_NUMBER      NUMBER         := NULL,
  MR_ROUTE_ID             NUMBER         := NULL,
  ROUTE_NUMBER            VARCHAR2(30)   := NULL,
  MR_ID                   NUMBER         := NULL,
  MR_TITLE                VARCHAR2(80)   := NULL,
  UNIT_EFFECTIVITY_ID     NUMBER         := NULL,
  DEPARTMENT_ID           NUMBER         := NULL,
  DEPT_NAME               VARCHAR2(240)  := NULL,
  SERVICE_REQUEST_ID      NUMBER         := NULL,
  SERVICE_REQUEST_NUMBER  VARCHAR2(30)   := NULL,
  ORIGINATING_TASK_ID     NUMBER         := NULL,
  ORGINATING_TASK_NUMBER  NUMBER         := NULL,
  INSTANCE_ID             NUMBER         := NULL,
  SERIAL_NUMBER           VARCHAR2(30)   := NULL,
  PROJECT_TASK_ID         NUMBER         := NULL,
  PROJECT_TASK_NUMBER     NUMBER         := NULL,
  PRIMARY_VISIT_TASK_ID   NUMBER         := NULL,
  START_FROM_HOUR         NUMBER         := NULL,
  DURATION                NUMBER         := NULL,
  TASK_TYPE_CODE          VARCHAR2(30)   := 'UNASSOCIATED',
  TASK_TYPE_VALUE         VARCHAR2(80)   := NULL,
  VISIT_TASK_NAME         VARCHAR2(80)   := NULL,
  DESCRIPTION             VARCHAR2(4000) := NULL,
  TASK_STATUS_CODE        VARCHAR2(30)   := NULL,
  TASK_STATUS_VALUE       VARCHAR2(80)   := NULL,
  OBJECT_VERSION_NUMBER   NUMBER         := NULL,
  LAST_UPDATE_DATE        DATE           := NULL,
  LAST_UPDATED_BY         NUMBER         := NULL,
  CREATION_DATE           DATE           := NULL,
  CREATED_BY              NUMBER         := NULL,
  LAST_UPDATE_LOGIN       NUMBER         := NULL,
  ATTRIBUTE_CATEGORY      VARCHAR2(30)   := NULL,
  ATTRIBUTE1              VARCHAR2(150)  := NULL,
  ATTRIBUTE2              VARCHAR2(150)  := NULL,
  ATTRIBUTE3              VARCHAR2(150)  := NULL,
  ATTRIBUTE4              VARCHAR2(150)  := NULL,
  ATTRIBUTE5              VARCHAR2(150)  := NULL,
  ATTRIBUTE6              VARCHAR2(150)  := NULL,
  ATTRIBUTE7              VARCHAR2(150)  := NULL,
  ATTRIBUTE8              VARCHAR2(150)  := NULL,
  ATTRIBUTE9              VARCHAR2(150)  := NULL,
  ATTRIBUTE10             VARCHAR2(150)  := NULL,
  ATTRIBUTE11             VARCHAR2(150)  := NULL,
  ATTRIBUTE12             VARCHAR2(150)  := NULL,
  ATTRIBUTE13             VARCHAR2(150)  := NULL,
  ATTRIBUTE14             VARCHAR2(150)  := NULL,
  ATTRIBUTE15             VARCHAR2(150)  := NULL,
  TASK_START_DATE         DATE           := NULL,
  TASK_END_DATE           DATE           := NULL,
  DUE_BY_DATE             DATE           := NULL,
  ZONE_NAME               VARCHAR2(30)   := NULL,
  SUB_ZONE_NAME           VARCHAR2(30)   := NULL,
  TOLERANCE_AFTER         NUMBER         := NULL,
  TOLERANCE_BEFORE        NUMBER         := NULL,
  TOLERANCE_UOM           VARCHAR2(50)   := NULL,
  WORKORDER_ID            NUMBER         := NULL,
  WO_NAME                 VARCHAR2(255)  := NULL,
  WO_STATUS               VARCHAR2(30)   := NULL,
  WO_START_DATE           DATE           := NULL,
  WO_END_DATE             DATE           := NULL,
  OPERATION_FLAG          VARCHAR2(2)    := NULL,
  IS_PRODUCTION_FLAG      VARCHAR2(1)    := NULL,
  CREATE_JOB_FLAG         VARCHAR2(1)    := NULL,
  STAGE_ID                NUMBER         := NULL,
  STAGE_NAME              VARCHAR2(80)   := NULL,
  --Begin changes by rnahata for Issue 105
  QUANTITY                NUMBER         := NULL,
  UOM                     CSI_ITEM_INSTANCES.UNIT_OF_MEASURE%TYPE    := NULL,
  INSTANCE_NUMBER         CSI_ITEM_INSTANCES.INSTANCE_NUMBER%TYPE    := NULL,
  --End changes by rnahata for Issue 105
  -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two new attributes for past dates
  PAST_TASK_START_DATE         DATE           := NULL,
  PAST_TASK_END_DATE           DATE           := NULL,
  --Begin changes by manisaga as part of DFF Enablement 0n 17-Feb-2010
  ROUTE_ID                NUMBER         := NULL
  --End changes by manisaga as part of DFF Enablement 0n 17-Feb-2010
);

-- Record of Maintainance Requirements Id and Serial Id
-- while importing technical dependency
TYPE MR_Serial_Rec_Type IS RECORD (
  MR_ID                   NUMBER       := NULL,
  SERIAL_ID               NUMBER       := NULL
  );

-- Record of Items which are filtered to only unique item among all items
TYPE Item_Rec_Type IS RECORD (
  Item_Id          NUMBER      := NULL,
  Visit_Task_Id    NUMBER      := NULL,
  Quantity         NUMBER      := NULL,
  Duration         NUMBER      := NULL,
  Effective_Date   DATE        := NULL,
  UOM_Code         VARCHAR2(3) := NULL
  );
---------------------------------------------------------------------
-- Define Table Types for table structures of records needed by the APIs --
---------------------------------------------------------------------
--  Table type for storing 'MR_Serial_Rec_Type' record datatype
TYPE MR_Serial_Tbl_Type IS TABLE OF MR_Serial_Rec_Type
   INDEX BY BINARY_INTEGER;

--  Table type for storing 'Item_Rec_Type' record datatype
TYPE Item_Tbl_Type IS TABLE OF Item_Rec_Type
   INDEX BY BINARY_INTEGER;

 TYPE Task_Tbl_Type  IS TABLE OF Task_Rec_Type
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
--  Procedure name    : Check_Item_Name_Or_Id
--  Type              : Private
--  Purpose           : To check if Item Name,Item Id and Item Organization Id exits.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Item_Name_Or_Id IN Parameters:
--   p_item_id              IN  NUMBER     Required,
--   p_org_id               IN  NUMBER     Required,
--   p_item_name            IN  VARCHAR2   Required,
--
--  Check_Item_Name_Or_Id OUT Parameters:
--   x_item_id              OUT  NUMBER     Required,
--   x_org_id               OUT  NUMBER     Required,
--   x_item_name            OUT  VARCHAR2   Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Item_Name_Or_Id
    (p_item_id         IN NUMBER,
     p_org_id          IN NUMBER,
     p_item_name       IN VARCHAR2,

     x_item_id         OUT NOCOPY NUMBER,
     x_org_id          OUT NOCOPY NUMBER,
     x_item_name       OUT NOCOPY VARCHAR2,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Serial_Name_Or_Id
--  Type              : Private
--  Purpose           : Converts Serial Number to Instance Id.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Serial_Name_Or_Id IN Parameters:
--   p_item_id              IN  NUMBER     Required,
--   p_org_id               IN  NUMBER     Required,
--   p_serial_id            IN  NUMBER     Required,
--   p_serial_number        IN  VARCHAR2   Required,
--
--  Check_Serial_Name_Or_Id OUT Parameters:
--   x_serial_id            OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--
-------------------------------------------------------------------
PROCEDURE Check_Serial_Name_Or_Id
    (p_item_id        IN NUMBER,
     p_org_id         IN NUMBER,
     p_serial_id      IN NUMBER,
     p_serial_number  IN VARCHAR2,

     x_serial_id      OUT NOCOPY NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_error_msg_code OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Org_Name_Or_Id
--  Type              : Private
--  Purpose           : To Converts Organization Name to Organization ID.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Org_Name_Or_Id IN Parameters:
--   p_organization_id      IN  NUMBER     Required,
--   p_org_name             IN  VARCHAR2   Required,
--
--  Check_Org_Name_Or_Id OUT Parameters:
--   x_organization_id      OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Org_Name_Or_Id
    (p_organization_id IN NUMBER,
     p_org_name        IN VARCHAR2,

     x_organization_id OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Dept_Desc_Or_Id
--  Type              : Private
--  Purpose           : Converts Department Description to Department ID
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Dept_Desc_Or_Id IN Parameters:
--   p_organization_id      IN  NUMBER     Required,
--   p_department_id        IN  NUMBER     Required,
--   p_dept_name            IN  NUMBER     Required,
--
--  Check_Dept_Desc_Or_Id OUT Parameters:
--   x_department_id        OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Dept_Desc_Or_Id
    (p_organization_id  IN NUMBER,
     p_department_id    IN NUMBER,
     p_dept_name        IN VARCHAR2,

     x_department_id    OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_SR_Request_Number_Or_Id
--  Type              : Private
--  Purpose           : To Converts Servie request Number to ID or Vice versa.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_SR_Request_Number_Or_Id IN Parameters:
--   p_service_id           IN  NUMBER     Required,
--   p_service_number       IN  NUMBER     Required,
--
--  Check_SR_Request_Number_Or_Id OUT Parameters:
--   x_service_id          OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_SR_Request_Number_Or_Id
    (p_service_id      IN NUMBER,
     p_service_number  IN VARCHAR2,

     x_service_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Visit_is_Simulated
--  Type              : Private
--  Purpose           : To check if the visit is simulated or not.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Visit_is_Simulated IN Parameters:
--   p_Visit_id             IN  NUMBER     Required,
--
--  Check_Visit_is_Simulated OUT Parameters:
--   x_bln_flag             OUT VARCHAR2   Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Visit_is_Simulated
    (p_Visit_id       IN NUMBER,

     x_bln_flag       OUT NOCOPY VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_error_msg_code OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Project_Template_Or_Id
--  Type              : Private
--  Purpose           : To check project template name and retrieve project id
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Project_Template_Or_Id IN Parameters:
--   p_proj_temp_name             IN  VARCHAR2     Required,
--
--  Check_Project_Template_Or_Id OUT Parameters:
--   x_project_id                 OUT NUMBER       Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE  Check_Project_Template_Or_Id
    (p_proj_temp_name  IN VARCHAR2,
     x_project_id      OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Serial_No_by_UConfig
--  Type              : DEPRECATED-- Code removed in POST11510
--  Purpose           : To derive the serial numbers that are part
--                      of unit configuration of the item
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Serial_No_by_UConfig IN Parameters:
--   p_visit_id    IN  NUMBER     Required,
--   p_item_id     IN  NUMBER     Required,
--   p_serial_id   IN  NUMBER     Required,
--   p_org_id      IN  NUMBER     Required,
--
--  Check_Serial_No_by_UConfig OUT Parameters:
--   x_check_flag      OUT VARCHAR2   Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
/*PROCEDURE Check_Serial_No_by_UConfig
    (p_visit_id        IN NUMBER,
     p_item_id         IN NUMBER,
     p_org_id          IN NUMBER,
     p_serial_id       IN NUMBER,
     x_check_flag      OUT NOCOPY VARCHAR2,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     );*/
-----------------------------------------------------------------------
-- FUNCTION
--    instance_in_config_tree
--
-- PURPOSE
--    Check whether p_instance_id belongs to the instance of p_visit_id
--    Return 'Y' for the following cases:
--      1. p_visit_id doesn't have instance_id associated at all
--      2. The instance_id of p_visit_id = p_instance_id regardless whether
--         the instance of p_visit_id has components or not
--      3. p_instance_id is a component of the instance of p_visit_id regardless
--         whether it is a UC tree or IB tree
--    Return 'N' otherwise
-----------------------------------------------------------------------
FUNCTION instance_in_config_tree(p_visit_id NUMBER, p_instance_id NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------
--  Procedure name    : Check_Visit_Task_Number_OR_Id
--  Type              : Private
--  Purpose           : To convert Visit Task Number to Id or Vice versa
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Visit_Task_Number_OR_Id IN Parameters:
--   p_visit_task_id       IN  NUMBER     Required,
--   p_visit_task_number   IN  NUMBER     Required,
--   p_visit_id            IN  NUMBER     Required

--  Check_Visit_Task_Number_OR_Id OUT Parameters:
--   x_visit_task_id      OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Visit_Task_Number_Or_Id
    (p_visit_task_id     IN NUMBER,
     p_visit_task_number IN NUMBER,
     p_visit_id          IN NUMBER,

     x_visit_task_id     OUT NOCOPY NUMBER,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_error_msg_code    OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure name    : Check_Lookup_Name_Or_Id
--  Type              : Private
--  Purpose           : To derive the lookup code and values
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status       OUT     VARCHAR2     Required
--   x_error_msg_code      OUT     VARCHAR2     Required
--
--  Check_Lookup_Name_Or_Id IN Parameters:
--   p_lookup_type         IN  VARCHAR2     Required,
--   p_lookup_code         IN  VARCHAR2     Required,
--   p_meaning             IN  VARCHAR2     Required,
--   p_check_id_flag       IN  VARCHAR2     Required
--
--  Check_Lookup_Name_Or_Id OUT Parameters:
--   x_lookup_code      OUT  VARCHAR2     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Lookup_Name_Or_Id
 ( p_lookup_type    IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code    IN FND_LOOKUPS.lookup_code%TYPE,
   p_meaning        IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag  IN VARCHAR2,
   x_lookup_code    OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------
--  Procedure name    : Check_Project_Responsibilities
--  Type              : Private
--  Purpose           : To verify project superuser reponsibilities
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Check_Project_Responsibilities OUT Parameters:
--   x_check_project       OUT  VARCHAR2     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Proj_Responsibility
 ( x_check_project    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------
--  Procedure name    : Get_Serial_Item_by_Unit
--  Type              : Private
--  Purpose           : To derive the Serial Id and Inventory Item Id from Unit Name
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--   x_error_msg_code       OUT     VARCHAR2     Required
--
--  Get_Serial_Item_by_Unit IN Parameters:
--   p_unit_name            IN  VARCHAR2     Required,
--
--  Get_Serial_Item_by_Unit OUT Parameters:
--   x_instance_id         OUT  NUMBER     Required,
--   x_item_id             OUT  NUMBER     Required,
--   x_item_org_id         OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Get_Serial_Item_by_Unit
 ( p_unit_name      IN         VARCHAR2,
   x_instance_id    OUT NOCOPY NUMBER,
   x_item_id        OUT NOCOPY NUMBER,
   x_item_org_id    OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_error_msg_code OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------
--  Procedure name    : Get_Cost_Originating_Id
--  Type              : Private
--  Purpose           : To derive the parent MR from the current MR and root MR.
--    for deriving cost parent and originating task ID's while creating
--    planned/unplanned tasks..
--  Parameters  :
--
--  Get_Cost_Originating_Id IN Parameters:
--   p_mr_main_id           IN  NUMBER     Required,
--   p_mr_header_id         IN  NUMBER     Required,
--
--  Get_Cost_Originating_Id OUT Parameters:
--   x_parent_id            OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
FUNCTION Get_Cost_Originating_Id (p_mr_main_id IN NUMBER, p_mr_header_id IN NUMBER)
  RETURN NUMBER;

--------------------------------------------------------------------
--  Procedure name    : Get_Visit_Task_Id
--  Type              : Private
--  Purpose           : To derive the primary attribute visit_task_id
--                      from the task entity
--  Parameters  :
--
--  Get_Visit_Task_Id OUT Parameters:
--   x_Visit_Task_Id      OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
FUNCTION Get_Visit_Task_Id
    RETURN NUMBER;

--------------------------------------------------------------------
--  Procedure name    : Get_Visit_Task_Number
--  Type              : Private
--  Purpose           : To derive the attribute visit_task_number from the task entity.
--  Parameters  :
--
--  Get_Cost_Originating_Id IN Parameters:
--   p_visit_id               IN  NUMBER   Required,
--
--  Get_Visit_Task_Number OUT Parameters:
--   x_Visit_Task_Number      OUT  NUMBER  Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
FUNCTION Get_Visit_Task_Number (p_visit_id IN NUMBER)
    RETURN NUMBER;

--------------------------------------------------------------------
--  Procedure name    : Insert_Tasks
--  Type              : Private
--  Purpose           : Called from Creation of Planned/Unplanned tasks
--                      under various other circumstances
--  Parameters        :
--
--  Standard OUT Parameters :
--   x_return_status   OUT VARCHAR2  Required
--   x_msg_count       OUT VARCHAR2  Required
--   x_msg_data        OUT VARCHAR2  Required
--
--  Insert_Tasks IN Parameters:
--   p_visit_id        IN  NUMBER    Required,
--   p_unit_id         IN  NUMBER    Required,
--   p_serial_id       IN  NUMBER    Required,
--   p_service_id      IN  NUMBER    Required,
--   p_dept_id         IN  NUMBER    Required,
--   p_item_id         IN  NUMBER    Required,
--   p_item_org_id     IN  NUMBER    Required,
--   p_mr_id           IN  NUMBER    Required,
--   p_mr_route_id     IN  NUMBER    Not Required,
--   p_parent_id       IN  NUMBER    Required,
--   p_flag            IN  VARHCAR2  Required,
--
--  Insert_Tasks OUT Parameters:
--   x_task_id         OUT  NUMBER     Required,
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Insert_Tasks (
   p_visit_id      IN         NUMBER,
   p_unit_id       IN         NUMBER,
   p_serial_id     IN         NUMBER,
   p_service_id    IN         NUMBER,
   p_dept_id       IN         NUMBER,
   p_item_id       IN         NUMBER,
   p_item_org_id   IN         NUMBER,
   p_mr_id         IN         NUMBER,
   p_mr_route_id   IN         NUMBER,
   p_parent_id     IN         NUMBER,
   p_flag          IN         VARCHAR2,
   p_stage_id      IN         NUMBER := NULL,
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added past start and end dates
   p_past_task_start_date IN DATE := NULL,
   p_past_task_end_date IN DATE := NULL,
   p_quantity      IN         NUMBER := NULL, -- Added by rnahata for Issue 105
   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
   p_task_start_date IN    DATE := NULL,
   x_task_id       OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count     OUT NOCOPY NUMBER,
   x_msg_data      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
--  Procedure name    : Tech_Dependency
--  Type              : Private
--  Purpose           : To associated Technical dependency while creating Planned/Unplanned Tasks.
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Tech_Dependency Parameters:
--   p_visit_id             IN  NUMBER     Required,
--   p_MR_Serial_Tbl        OUT  MR_Serial_Tbl_Type Required,
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
 PROCEDURE Tech_Dependency (
   p_visit_id      IN  NUMBER,
   p_task_type     IN  VARCHAR2,
   p_MR_Serial_Tbl IN  MR_Serial_Tbl_Type,
   x_return_status OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------
--  Procedure name    : Create_Tasks_for_MR
--  Type              : Private
--  Purpose           : To create Tasks for MR.
--  Parameters  :
--
--  Standard OUT Parameters :
--    x_return_status      OUT     VARCHAR2     Required
--  Create_Tasks_for_MR Parameters:
--    p_department_id   IN     NUMBER   Required,
--    p_visit_id        IN     NUMBER   Required,
--    p_serial_id       IN     NUMBER   Required,
--    p_mr_id           IN     NUMBER   Required,
--    p_unit_id         IN     NUMBER   Required,
--    p_service_req_id  IN     NUMBER   Required,
--    p_x_parent_MR_Id  IN OUT NUMBER   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Create_Tasks_for_MR  (
    p_visit_id         IN NUMBER,
    p_unit_id          IN NUMBER,
    p_item_id          IN NUMBER,
    p_org_id           IN NUMBER,
    p_serial_id        IN NUMBER,
    p_mr_id            IN NUMBER,
    p_department_id    IN NUMBER,
    p_service_req_id   IN NUMBER,
    -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added past start and end dates too
    p_past_task_start_date  IN DATE := NULL,
    p_past_task_end_date    IN DATE := NULL,
    -- Added by rnahata for Issue 105
    p_quantity         IN  NUMBER,
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
    p_task_start_date IN    DATE := NULL,
    p_x_parent_MR_Id   IN OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
--  Procedure name    : Check_Cost_Parent_Loop
--  Type              : Private
--  Purpose           : To check if the cost parent task not forming loop among other tasks
--  Parameters  :
--
--  Check_Cost_Parent_Loop IN Parameters :
--  p_visit_id             IN  NUMBER     Required
--  p_visit_task_id        IN  NUMBER     Required
--  p_cost_parent_id       IN  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Check_Cost_Parent_Loop
 ( p_visit_id       IN NUMBER,
   p_visit_task_id  IN NUMBER,
   p_cost_parent_id IN NUMBER
 );

--------------------------------------------------------------------
--  Procedure name    : Check_Origin_Task_Loop
--  Type              : Private
--  Purpose           : To check if the originating task not forming loop among other tasks
--  Parameters  :
--
--  Check_Origin_Task_Loop IN Parameters :
--  p_visit_id             IN  NUMBER     Required
--  p_visit_task_id        IN  NUMBER     Required
--  p_originating_task_id  IN  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Check_Origin_Task_Loop
 ( p_visit_id            IN NUMBER,
   p_visit_task_id       IN NUMBER,
   p_originating_task_id IN NUMBER);

--------------------------------------------------------------------
-- PROCEDURE          : Update_Visit_Task_Flag
--  Type              : Private
--  Purpose           : To update visit entity any_task_chg_flag attribute whenever there
--                      are changes in visit task - either addition or deletion or change
--                      in cost parent of any task
--  Parameters  :
--
--  Update_Visit_Task_Flag IN Parameters :
--  p_visit_id             IN  NUMBER     Required
--  p_flag_id              IN  NUMBER     Required
--
--  Update_Visit_Task_Flag OUT Parameters :
--  x_return_status        OUT VARCAHR2   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Update_Visit_Task_Flag
    (p_visit_id       IN NUMBER,
     p_flag           IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Price_List_Name_Or_Id
--
-- PURPOSE
--    To find out price list id for price list name for a visit or tasks
-- PROCEDURE          : Update_Visit_Task_Flag
--  Type              : Private
--  Purpose           : To update visit entity any_task_chg_flag attribute whenever there
--                      are changes in visit task - either addition or deletion or change
--                      in cost parent of any task
--  Parameters  :
--
--  Check_Price_List_Name_Or_Id IN Parameters :
--  p_visit_id             IN  NUMBER     Required
--  p_flag_id              IN  NUMBER     Required
--
--  Check_Price_List_Name_Or_Id OUT Parameters :
--  x_return_status        OUT VARCAHR2   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Check_Price_List_Name_Or_Id(
     p_visit_id         IN NUMBER,
     p_price_list_name  IN VARCHAR2,
     x_price_list_id    OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
-- Procedure         :  Update_Cost_Origin_Task
--  Type              : Private
--  Purpose           : To update all tasks which have the deleting task as cost or originating task
--  Parameters  :
--
--  Update_Cost_Origin_Task IN Parameters :
--  p_visit_task_id        IN  NUMBER     Required
--
--  Update_Cost_Origin_Task OUT Parameters :
--  x_return_status        OUT VARCHAR2   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Update_Cost_Origin_Task
    (p_visit_task_id    IN NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  Procedure         : Update_Visit_Task_Flag
--  Type              : Private
--  Purpose           : To merge two item tables and remove the redundant items
--                      in table for which no price is defined
--  Parameters  :
--
--  Merge_for_Unique_Items IN Parameters :
--  p_item_tbl1        IN  Item_Tbl_Type     Required
--  p_item_tbl2        IN  Item_Tbl_Type     Required
--
--  Merge_for_Unique_Items OUT Parameters :
--  x_item_tbl        OUT  Item_Tbl_Type     Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Merge_for_Unique_Items
    (p_item_tbl1 IN         Item_Tbl_Type,
     p_item_tbl2 IN         Item_Tbl_Type,
     x_item_tbl  OUT NOCOPY Item_Tbl_Type
     );

--------------------------------------------------------------------
--  Procedure         : Check_Item_in_Price_List
--  Type              : Private
--  Purpose           : To check if item of MR is defined in price list.
--  Parameters  :
--
--  Check_Item_in_Price_List IN Parameters :
--  p_price_list  IN  NUMBER     Required
--  p_item_id     IN  NUMBER     Required
--
--  Check_Item_in_Price_List OUT Parameters :
--  x_item_chk_flag        OUT NUMBER   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
/*PROCEDURE Check_Item_in_Price_List
    (p_price_list    IN  NUMBER,
     p_item_id       IN  NUMBER,
     x_item_chk_flag OUT NOCOPY NUMBER
     );
*/
--------------------------------------------------------------------
-- PROCEDURE          : Check_Currency_for_Costing
--  Type              : Private
--  Purpose           : To retrieve currency code and pass as input parameter to Pricing API
--  Parameters  :
--
--  Check_Currency_for_Costing IN Parameters :
--  p_visit_id             IN  NUMBER     Required
--
--  Check_Currency_for_Costing OUT Parameters :
--  x_currency_code        OUT VARCHAR2   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Check_Currency_for_Costing
    (p_visit_id      IN  NUMBER,
     x_currency_code OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  PROCEDURE         : Check_Job_Status
--  Type              : Private
--  Purpose           : To find out valid job status on shop floor for a Visit/MR/Task
--  Parameters  :
--
--  Check_Job_Status IN Parameters :
--  p_id             IN  NUMBER       Required
--  p_is_task_flag   IN  VARCHAR2     Required
--                     - 'Y' for MR and Task
--                     - 'N' for Visit
--  Check_Job_Status OUT Parameters :
--  x_status_code    OUT NUMBER   Required
--  x_status_meaning OUT VARCAHR2   Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Check_Job_Status
    (p_id             IN         NUMBER,
     p_is_task_flag   IN         VARCHAR2,
     x_status_code    OUT NOCOPY NUMBER,
     x_status_meaning OUT NOCOPY VARCHAR2
     );

--------------------------------------------------------------------
--  PROCEDURE         : CHECK_DEPARTMENT_SHIFT
--  Type              : Private
--  Purpose           : To find out if the respective dept has shifts defined in ahl_dept_shifts
--  Parameters  :
--
--  CHECK_DEPARTMENT_SHIFT IN Parameters :
--  p_dept_id       IN  NUMBER       Required

--  CHECK_DEPARTMENT_SHIFT OUT Parameters :
--  x_return_status    OUT varchar2 Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE CHECK_DEPARTMENT_SHIFT(
    p_dept_id       IN         NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
);

-- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
-- Added this new procedure
--------------------------------------------------------------------
--  PROCEDURE         : Validate_Past_Task_Dates
--  Type              : Private
--  Purpose           : To validate the past task start and end dates against cost parent/task stages
--  Parameters  :
--
--  Validate_Past_Task_Dates IN Parameters :
--  p_task_rec       IN OUT NOCOPY Task_Rec_Type Required

--  Validate_Past_Task_Dates OUT Parameters :
--  x_return_status    OUT varchar2 Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------

PROCEDURE Validate_Past_Task_Dates (
    p_task_rec       IN OUT NOCOPY Task_Rec_Type,
    x_return_status  OUT NOCOPY VARCHAR2
);


END AHL_VWP_RULES_PVT;

/
