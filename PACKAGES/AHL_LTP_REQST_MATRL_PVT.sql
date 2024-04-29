--------------------------------------------------------
--  DDL for Package AHL_LTP_REQST_MATRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_REQST_MATRL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRMTS.pls 120.1 2008/03/20 10:28:28 rnahata ship $*/
--
TYPE Visit_Task_Route_Rec_Type IS RECORD (
     VISIT_TASK_ID      NUMBER,
     MR_ROUTE_ID        NUMBER,
     ROUTE_ID           NUMBER,
     INSTANCE_ID        NUMBER,
     TASK_START_DATE    DATE);

TYPE Visit_Task_Route_Tbl_Type IS TABLE OF Visit_Task_Route_Rec_Type
   INDEX BY BINARY_INTEGER;

-- Start of Comments --
--  Procedure name    : Process_Planned_Materials
--  Type        : Private
--  Function    : This procedure Creates, Updates and Removes Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Planned_Materials Parameters :
--
--
PROCEDURE Process_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER   := NULL,
   p_org_id                  IN    NUMBER   := NULL,
   p_start_date              IN    DATE     := NULL,
   p_visit_status            IN    VARCHAR2 := NULL,
   p_operation_flag          IN    VARCHAR2,
   x_planned_order_flag         OUT NOCOPY VARCHAR2 ,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2);

-- Start of Comments --
--  Procedure name    : Update_Planned_Materials
--  Type        : Private
--  Function    : This procedure Updates Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Planned_Materials Parameters :
--       p_planned_materials_tbl          IN   Planned_Materials_Tbl,Required
--
--
PROCEDURE Update_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_planned_materials_tbl   IN    ahl_ltp_reqst_matrl_pub.Planned_Materials_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2);
--
--
-- Start of Comments --
--  Procedure name    : Unschedule_Visit_task_Items
--  Type        : Private
--  Function    : This procedure Checks any items scheduled
--                which are defined at Route Operation and Disposition level
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Unschedule_Visit_Task_Items Parameters :
--       p_visit_id            IN   NUMBER,        Required
--       p_visit_task_id       IN   NUMBER,        Optional
--
PROCEDURE Unschedule_visit_Task_Items
  (p_api_version            IN    NUMBER,
   p_init_msg_list          IN    VARCHAR2  := Fnd_Api.G_FALSE,
   p_commit                 IN    VARCHAR2  := Fnd_Api.G_FALSE,
   p_visit_id               IN    NUMBER,
   p_visit_task_id          IN    NUMBER   := NULL,
   x_return_status             OUT NOCOPY        VARCHAR2,
   x_msg_count                 OUT NOCOPY        NUMBER,
   x_msg_data                  OUT NOCOPY        VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Create_Task_Materials
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create_Planned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Create_Task_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   p_start_time              IN    DATE   := NULL,
   p_org_id                  IN    NUMBER := NULL,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2);

-- Start of Comments --
--  Procedure name    : Modify_Visit_Task_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Modify_Visit_Task_Matrls Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Modify_Visit_Task_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   p_start_time              IN    DATE   := NULL,
   p_org_id                  IN    NUMBER := NULL,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2);

-- Start of Comments --
--  Procedure name    : Remove_Visit_Task_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Remove_Planned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Remove_Visit_Task_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   p_visit_task_id           IN    NUMBER := NULL,
   x_planned_order_flag        OUT NOCOPY VARCHAR2 ,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2);

-- Start of Comments --
--  Procedure name    : Update_Unplanned_Matrls
--  Type        : Private
--  Function    : This procedure Created Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Unplanned_Materials Parameters :
--       p_visit_id                     IN      NUMBER,Required
--
--
PROCEDURE Update_Unplanned_Matrls (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------
--  Procedure name    : Update_Material_Reqrs_status
--  Type              : Private
--
--  Function          : To update all the material requirement status
--                      for the workorder that is being cancelled.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--      x_workorder_id                  OUT     NUMBER                 Required
--
--  Release visit Parameters:
--       p_visit_task_id                IN   NUMBER  Required
--
--  Version :
--    19/03/2008     Richa     Bug#6898408 Initial Creation
-------------------------------------------------------------------

PROCEDURE   Update_Material_Reqrs_status
            (  p_api_version        IN          NUMBER,
               p_init_msg_list      IN          VARCHAR2 := Fnd_Api.G_FALSE,
               p_commit             IN          VARCHAR2 := Fnd_Api.G_FALSE,
               p_validation_level   IN          NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,
               p_module_type        IN          VARCHAR2 := NULL,
               p_visit_task_id      IN          NUMBER,
               x_return_status      OUT NOCOPY  VARCHAR2,
               x_msg_count          OUT NOCOPY  NUMBER,
               x_msg_data           OUT NOCOPY  VARCHAR2
            );

END AHL_LTP_REQST_MATRL_PVT;

/
