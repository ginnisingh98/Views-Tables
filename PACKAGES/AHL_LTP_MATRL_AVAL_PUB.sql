--------------------------------------------------------
--  DDL for Package AHL_LTP_MATRL_AVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_MATRL_AVAL_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPMTAS.pls 120.1 2007/12/31 11:40:35 rnahata ship $ */
--
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
-- anraj : added columns TASK_STATUS_CODE and TASK_STATUS_MEANING , for Material Availabilty UI
TYPE Material_Availability_Rec IS RECORD (
          SCHEDULE_MATERIAL_ID         NUMBER         ,
          OBJECT_VERSION_NUMBER        NUMBER         ,
          INVENTORY_ITEM_ID            NUMBER         ,
          ITEM                         VARCHAR2(80)   ,
          MR_ROUTE_ID                  NUMBER         ,
          VISIT_ID                     NUMBER         ,
          VISIT_TASK_ID                NUMBER         ,
          ORGANIZATION_ID              NUMBER         ,
          TASK_NAME                    VARCHAR2(80)   ,
          TASK_STATUS_CODE             VARCHAR2(30) ,
          TASK_STATUS_MEANING          VARCHAR2(80)  ,
          REQ_ARRIVAL_DATE             DATE           ,
          QUANTITY_AVAILABLE           NUMBER         ,
          QUANTITY                     NUMBER         ,
          SCHEDULED_DATE               DATE           ,
          UOM                          VARCHAR2(30)   ,
          ERROR_CODE                   NUMBER         ,
          ERROR_MESSAGE                VARCHAR2(2000) ,
          PLAN_NAME                    VARCHAR2(30)
          );
-- anraj : added columns TASK_STATUS_CODE and TASK_STATUS_MEANING , for Material Availabilty UI
TYPE Task_Req_Matrl_Rec IS RECORD (
          SCHEDULE_MATERIAL_ID         NUMBER         ,
          OBJECT_VERSION_NUMBER        NUMBER         ,
          VISIT_TASK_ID                NUMBER         ,
          TASK_NAME                    VARCHAR2(80)   ,
          TASK_STATUS_CODE            VARCHAR2(30)    ,
          TASK_STATUS_MEANING         VARCHAR2(80)    ,
          MR_ROUTE_ID                  NUMBER         ,
          INVENTORY_ITEM_ID            NUMBER         ,
          ITEM_GROUP_ID                NUMBER         ,
          ITEM                         VARCHAR2(80)   ,
          REQ_ARRIVAL_DATE             DATE           ,
          UOM_CODE                     VARCHAR2(30)   ,
          QUANTITY_AVAILABLE           NUMBER         ,
          SCHEDULED_DATE               DATE           ,
          PLANNED_ORDER                VARCHAR2(240)  ,
          QUANTITY                     NUMBER
          );

TYPE Planned_Matrl_Rec IS RECORD (
          SCHEDULE_MATERIAL_ID         NUMBER         ,
          OBJECT_VERSION_NUMBER        NUMBER         ,
          INVENTORY_ITEM_ID            NUMBER         ,
          ITEM_DESCRIPTION             VARCHAR2(80)   ,
          VISIT_ID                     NUMBER         ,
          VISIT_TASK_ID                NUMBER         ,
          ORGANIZATION_ID              NUMBER         ,
          PLANNED_ORDER                VARCHAR2(240)  ,
          TASK_NAME                    VARCHAR2(80)   ,
          TASK_STATUS_CODE             VARCHAR2(30)   ,
          TASK_STATUS_MEANING          VARCHAR2(80)   ,
          REQUESTED_DATE               DATE           ,
          REQUIRED_QUANTITY            NUMBER         ,
          QUANTITY_AVAILABLE           NUMBER         ,
          SCHEDULED_DATE               DATE           ,
          PRIMARY_UOM_CODE             VARCHAR2(3)    ,
          PRIMARY_UOM                  VARCHAR2(25)   ,
          -- Added by sowsubra
          MAT_STATUS                   AHL_SCHEDULE_MATERIALS.STATUS%TYPE,
          ERROR_CODE                   NUMBER         ,
          ERROR_MESSAGE                VARCHAR2(2000)
          );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Material_Availability_Tbl IS TABLE OF Material_Availability_Rec
          INDEX BY BINARY_INTEGER;
 TYPE Task_Req_Matrl_Tbl IS TABLE OF Task_Req_Matrl_Rec
          INDEX BY BINARY_INTEGER;
 TYPE Planned_Matrl_Tbl IS TABLE OF Planned_Matrl_Rec
          INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Check_Material_Aval
--  Type        : Public
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs derived requested quantity and task start date
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
--  Check_Material_Aval Parameters :
--        p_x_material_avl_tbl      IN  OUT NOCOPY Material_Availability_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Check_Material_Aval (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_material_avl_tbl      IN  OUT NOCOPY Material_Availability_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Get_Visit_Task_Materials
--  Type        : Public
--  Function    : This procedure derives material information associated to scheduled
--                visit, which are defined at Route Operation level
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
--  Get_Visit_Task_Materials :
--           p_visit_id                 IN   NUMBER,Required
--           x_task_req_matrl_tbl       OUT NOCOPY  Task_Req_Matrl_Tbl,
--
PROCEDURE Get_Visit_Task_Materials (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,
   x_task_req_matrl_tbl      OUT  NOCOPY Task_Req_Matrl_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Check_Materials_For_All
--  Type        : Public
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs associated to a visit
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
--  Check_Materials_For_All Parameters :
--        p_visit_id              IN   NUMBER, Required
--        x_material_avl_tbl      OUT NOCOPY  Material_Availability_Tbl,
--         List of item attributes associated to visit task
--
PROCEDURE Check_Materials_For_All (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,
   x_task_matrl_aval_tbl     OUT NOCOPY Material_Availability_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Schedule_Planned_Mtrls
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
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
--  Schedule_Planned_Matrls Parameters :
--        p_x_planned_matrls_tbl      IN  OUT NOCOPY Planned_Matrls_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_Planned_Matrls (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_planned_matrl_tbl     IN  OUT NOCOPY Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Schedule_All_Materials
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
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
--  Schedule_All_Materials Parameters :
--          p_visit_id               IN       NUMBER       Required,
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_All_Materials (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   x_planned_matrl_tbl           OUT NOCOPY Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

END AHL_LTP_MATRL_AVAL_PUB;

/
