--------------------------------------------------------
--  DDL for Package AHL_LTP_MATRL_AVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_MATRL_AVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVMTAS.pls 120.1 2008/02/25 11:32:42 rnahata ship $*/
--
--
-- Start of Comments --
--  Procedure name    : Check_Availability
--  Type        : Private
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Check_Material_Aval Parameters :
--        p_calling_module             IN         NUMBER default null
--        p_inventory_item_id          IN         NUMBER , Required
--        p_quantity_required          IN         NUMBER,   Required
--        p_organization_id            IN         NUMBER,   Required
--        p_uom                        IN         VARCHAR2, Required
--        p_requested_date             IN         VARCHAR2, Required
--
PROCEDURE Check_Availability (
   p_calling_module             IN          NUMBER ,
   p_inventory_item_id          IN          NUMBER ,
   p_item_description           IN          VARCHAR2 ,
   p_quantity_required          IN          NUMBER,
   p_organization_id            IN          NUMBER,
   p_uom                        IN          VARCHAR2,
   p_requested_date             IN          DATE, --Modified by rnahata for Issue 105
   p_schedule_material_id       IN          NUMBER,
   x_available_qty              OUT NOCOPY  NUMBER,
   x_available_date             OUT NOCOPY  DATE,
   x_error_code                 OUT NOCOPY  NUMBER,
   x_error_message              OUT NOCOPY  VARCHAR2,
   x_return_status              OUT NOCOPY  VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Check_Material_Aval
--  Type        : Private
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
   p_x_material_avl_tbl      IN  OUT NOCOPY ahl_ltp_matrl_aval_pub.Material_Availability_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Get_Visit_Task_Materials
--  Type        : Private
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
--           x_task_req_matrl_tbl       OUT NOCOPY Task_Req_Matrl_Tbl,
--

PROCEDURE Get_Visit_Task_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN    NUMBER,
   x_task_req_matrl_tbl      OUT  NOCOPY ahl_ltp_matrl_aval_pub.task_req_matrl_tbl,
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
   p_x_planned_matrl_tbl     IN  OUT NOCOPY AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Schedule_All_Materials
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials for a visit
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
--        p_visit_id                    IN       Number,Required
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_All_Materials (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN      NUMBER,
   x_planned_matrl_tbl           OUT NOCOPY AHL_LTP_MATRL_AVAL_PUB.Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

END AHL_LTP_MATRL_AVAL_PVT;

/
