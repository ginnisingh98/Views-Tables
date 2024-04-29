--------------------------------------------------------
--  DDL for Package AHL_LTP_RESRC_LEVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_RESRC_LEVL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRLGS.pls 115.15 2003/11/06 00:55:31 ssurapan noship $ */
--
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
-- Record of task hours and times
TYPE Visit_Task_Times_Rec_Type IS RECORD (
        VISIT_TASK_ID           NUMBER           := NULL,  -- Id of the visit task
        MR_ROUTE_ID             NUMBER           := NULL,  -- Id of the associated route
        PARENT_TASK_ID          NUMBER           := NULL,  -- Id of the latest ending parent (can be null)
        TASK_START_HOUR         NUMBER           := NULL,  -- Normalized start hour for this task (w.r.t visit)
        TASK_DURATION           NUMBER           := NULL,  -- Duration of the visit
        TASK_END_HOUR           NUMBER           := NULL,  -- Normalized end hour for this task
        TASK_START_TIME         DATE             := NULL,  -- Actual start time of this task
        TASK_END_TIME           DATE             := NULL   -- Actual end time of this task
        );

-- Record of Plan resources
TYPE Plan_Rsrc_Rec_Type IS RECORD (
        ASO_BOM_TYPE            VARCHAR2(30)     := NULL,  -- ASO or BOM type of Resource
        RESOURCE_ID             NUMBER           := NULL,  -- ASO resource id or BOM resource id
        RESOURCE_TYPE           NUMBER           := NULL,  -- Resource type code
        RESOURCE_TYPE_MEANING   VARCHAR2(30)     := NULL,  -- Meaning of Resource type code
        RESOURCE_NAME           VARCHAR2(30)     := NULL,  -- Name of the resource
        RESOURCE_DESCRIPTION    VARCHAR2(240)    := NULL,  -- Description of the resource
     	CAPACITY_UNITS          NUMBER,
        REQUIRED_UNITS          NUMBER           := NULL,  ------- Required Units of Resource
        AVAILABLE_UNITS         NUMBER           := NULL,------  -- Available Units of Resource
    	DEPT_DESCRIPTION        VARCHAR2(240)    := NULL,
        PERIOD_STRING           VARCHAR2(80)     := NULL,  -- Display String of Period --new
        PERIOD_START            DATE             := NULL,  -- Period Start Date/Time  -- new
        PERIOD_END              DATE             := NULL,  -- Period End Date/Time   -- new
        DEPT_ID                 NUMBER           := null
        );

-- Record of Resource Requirement and Availability over a Period
TYPE Period_Rsrc_Req_Rec_Type IS RECORD (
        PERIOD_STRING           VARCHAR2(80)     := NULL,  -- Display String of Period
        PERIOD_START            DATE             := NULL,  -- Period Start Date/Time
        PERIOD_END              DATE             := NULL,  -- Period End Date/Time
        RESOURCE_ID             NUMBER           := NULL,  -- ASO resource id or BOM resource id
	RESOURCE_TYPE           NUMBER           := NULL,
    	DEPARTMENT_ID           NUMBER           := NULL,
    	DEPT_DESCRIPTION        VARCHAR2(240)    := NULL,
    	RESOURCE_TYPE_MEANING   VARCHAR2(30)     := NULL,
    	RESOURCE_NAME           VARCHAR2(30)     := NULL,
    	RESOURCE_DESCRIPTION    VARCHAR2(240)    := NULL,
    	CAPACITY_UNITS          NUMBER           := NULL,
        REQUIRED_UNITS          NUMBER           := NULL,  -- Required Units of Resource
        AVAILABLE_UNITS         NUMBER           := NULL  -- Available Units of Resource
        );

-- Record of Plan resources
TYPE Task_Requirement_Rec_Type IS RECORD (
        VISIT_ID                NUMBER           := NULL,  -- Visit Id
        TASK_ID                 NUMBER           := NULL,  -- Task Id
        VISIT_NAME              VARCHAR2(80)     := NULL,  -- Visit Name
        VISIT_NUMBER            NUMBER           := NULL,  -- Visit Number
        VISIT_TASK_NAME         VARCHAR2(80)     := NULL,  -- Task Name
        TASK_TYPE_CODE          VARCHAR2(30)            ,
        DEPT_NAME               VARCHAR2(80)            ,
        REQUIRED_UNITS          NUMBER           := NULL,  -- Required Units of Resource
        AVAILABLE_UNITS         NUMBER           := NULL,  -- Available Units of Resource
        QUANTITY                NUMBER           := NULL   -- Quantity Required
        );

-- Record of Resource details
TYPE Task_Resource_Rec_Type IS RECORD (
        TASK_ID                 NUMBER           := NULL,  -- Id of the visit task
        PER_COMPETENCE_ID       NUMBER           := NULL,  -- Id of the resource's competence
        PERRATING_LEVEL_ID      NUMBER           := NULL,  -- Id of the Resource's rating level
        PER_QUALIFICATION_ID    NUMBER           := NULL,  -- Id of the Resource's qualification
        BOM_RESOURCE_ID         NUMBER           := NULL,  -- The resource's BOM id
        TIMESPAN                NUMBER           := NULL  -- The resource's duration/timespan
        );

-- Record of skillset
TYPE Skillset_Rec_Type IS RECORD (
        PER_COMPETENCE_ID       NUMBER           := NULL,  -- Id of the resource's competence
        PER_COMPETENCE_NAME     VARCHAR2(240)    := NULL,  -- Name of the competence
        PERRATING_LEVEL_ID      NUMBER           := NULL,  -- Id of the Resource's rating level
        PER_RATING_LEVEL_NAME   VARCHAR2(80)     := NULL,  -- Name of the rating level
        PER_QUALIFICATION_ID    NUMBER           := NULL,  -- Id of the Resource's qualification
        PER_QUALIFICATION_NAME  VARCHAR2(100)    := NULL   -- Name of the qualification
        );


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Visit_Task_Times_Tbl_Type IS TABLE OF Visit_Task_Times_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Plan_Rsrc_Tbl_Type IS TABLE OF Plan_Rsrc_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Period_Rsrc_Req_Tbl_Type IS TABLE OF Period_Rsrc_Req_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Task_Requirement_Tbl_Type IS TABLE OF Task_Requirement_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Task_Resource_Tbl_Type IS TABLE OF Task_Resource_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Skillset_Tbl_Type IS TABLE OF Skillset_Rec_Type INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Derive_Visit_Task_Times
--  Type              : Private
--  Function          : Derive the start and end times/hours of tasks associated with a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Derive_Visit_Task_Times Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The id of the visit whose associated tasks' start and end times or hours
--         need to be derived
--      p_start_time                    IN      DATE         DEFAULT NULL
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--         If null, no filtering will be done
--      p_end_time                      IN      DATE         DEFAULT NULL
--         End time filter for tasks. Only tasks that are in progress at or before this
--         time will be considered. Tasks that start after this time will be ignored.
--         If null, no filtering will be done
--      x_visit_start_time              OUT     DATE
--         The start time of the visit
--      x_visit_end_time                OUT     DATE
--         The derived end time of the visit
--      x_visit_end_hour                OUT     NUMBER
--         The derived end hour (normalized) of the visit
--      x_visit_task_times_tbl          OUT     AHL_LTP_RESRC_LEVL_PVT.Visit_Task_Times_Tbl_Type
--         The table containing details about the tasks associated with this visit
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Derive_Visit_Task_Times
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_visit_id              IN            NUMBER,
    p_start_time            IN            DATE      := NULL,
    p_end_time              IN            DATE      := NULL,
    x_visit_start_time      OUT NOCOPY           DATE,
    x_visit_end_time        OUT NOCOPY           DATE,
    x_visit_end_hour        OUT NOCOPY           NUMBER,
    x_visit_task_times_tbl  OUT NOCOPY    Ahl_Ltp_Resrc_Levl_Pvt.Visit_Task_Times_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Get_Plan_Resources
--  Type              : Private
--  Function          : Gets the distinct Resources (Name, Type, Code) required by a given
--                      department during a given period for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress at or before this
--         time will be considered. Tasks that start after this time will be ignored.
--      x_plan_rsrc_tbl                 OUT  AHL_LTP_RESRC_LEVL_PVT.Plan_Rsrc_Tbl_Type
--         The table containing the distinct resources required.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Get_Plan_Resources
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    x_plan_rsrc_tbl         OUT NOCOPY    Ahl_Ltp_Resrc_Levl_Pvt.Plan_Rsrc_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Get_Rsrc_Req_By_Period
--  Type              : Private
--  Function          : Gets the Requirements and Availability of a Resource
--                      by periods for a given department, during a given period,
--                      for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress before this
--         time will be considered. Tasks that start at or after this time will be ignored.
--      p_UOM_id                        IN      NUMBER     REQUIRED
--         The id of the Period's unit of Measure (Days, Weeks, Months etc.)
--      p_resource_id                   IN      NUMBER     REQUIRED
--         The id of the Resource whose requirements/Availabilities are to be derived
--      p_aso_bom_rsrc_type             IN      VARCHAR2    REQUIRED
--         The type of the resource (ASORESOURCE or BOMRESOURCE)
--      x_per_rsrc_tbl                  OUT  AHL_LTP_RESRC_LEVL_PVT.Period_Rsrc_Req_Tbl_Type
--         The table containing the distinct resources required.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Get_Rsrc_Req_By_Period
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_UOM_code              IN            VARCHAR2,
    p_required_capacity     IN            NUMBER,
    x_per_rsrc_tbl          OUT NOCOPY    Ahl_Ltp_Resrc_Levl_Pvt.Period_Rsrc_Req_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Get_Task_Requirements
--  Type              : Private
--  Function          : Gets the Requirements of a Resource by Visit/Task
--                      for a given department, during a given period,
--                      for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress before this
--         time will be considered. Tasks that start at or after this time will be ignored.
--      p_resource_id                   IN      NUMBER     REQUIRED
--         The id of the Resource whose requirements/Availabilities are to be derived
--      p_aso_bom_rsrc_type             IN      VARCHAR2    REQUIRED
--         The type of the resource (ASORESOURCE or BOMRESOURCE)
--      x_task_req_tbl                  OUT     AHL_LTP_RESRC_LEVL_PVT.Task_Requirement_Tbl_Type
--         The table containing the resource requirements.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Get_Task_Requirements
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_dstart_time           IN            DATE,
    p_dend_time             IN            DATE,
    p_resource_id           IN            NUMBER,
    p_aso_bom_rsrc_type     IN            VARCHAR2,
    x_task_req_tbl          OUT NOCOPY    Ahl_Ltp_Resrc_Levl_Pvt.Task_Requirement_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
);

/*
--//@@@@@ TO BE REMOVED
PROCEDURE Dump_Working_dates_tbl
(
  p_start_date IN DATE := TO_DATE('15-May-2002'),
  p_dept_id IN NUMBER := 1,
  p_num_days IN NUMBER := 100
);
*/

END Ahl_Ltp_Resrc_Levl_Pvt;

 

/
