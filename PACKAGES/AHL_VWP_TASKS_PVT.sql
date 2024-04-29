--------------------------------------------------------
--  DDL for Package AHL_VWP_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TASKS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVTSKS.pls 120.0 2005/05/26 01:12:26 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_Tasks_Pvt
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> Visit's TASKS
--    related procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
--    Create_Task               (see below for specification)
--    Update_Task               (see below for specification)
--    Delete_Task               (see below for specification)
--    Search_Task               (see below for specification)
--    Get_Task_Details          (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 17-MAY-2002    SHBHANDA      Created.
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.
-----------------------------------------------------------

-- Record for Search Tasks
TYPE Srch_Task_Rec_Type IS RECORD (
  Task_ID                    NUMBER,
  Task_Start_Time            DATE,
  Task_End_Time              DATE
);

--Declare Task table type for search task record
TYPE Srch_Task_Tbl_Type IS TABLE OF Srch_Task_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------
-- Declare Procedures --
-------------------------------------------------------------------
--  Procedure name    : Get_Task_Details
--  Type              : Private
--  Function          : To display task details associated with a visit for update UI screen
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
--  Get_Task_Details Parameters:
--      p_task_id                       IN      NUMBER       Required
--         The id of the visit tasks whose details are displayed
--      x_task_rec                      OUT     AHL_VWP_RULES_PVT.Task_Rec_Type
--         The record containing details about the tasks associated with a visit
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------

PROCEDURE Get_Task_Details (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_task_id                 IN      NUMBER,
   x_task_rec                OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,
   x_return_status           OUT NOCOPY     VARCHAR2,
   x_msg_count               OUT NOCOPY     NUMBER,
   x_msg_data                OUT NOCOPY     VARCHAR2
);

-------------------------------------------------------------------
--  Procedure name    : Create_Task
--  Type              : Private
--  Function          : To create Unassociated/Summary/Non-Routine task for a visit
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
--  Create_Task Parameters:
--      p_x_Task_Rec                    IN OUT  AHL_VWP_RULES_PVT.Task_Rec_Type  Required
--         The record of visit's task attributes for which task is created.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Create_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_task_Rec           IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );

-------------------------------------------------------------------
--  Procedure name    : Update_Task
--  Type              : Private
--  Function          : To update various different types of tasks in a visit.
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
--  Update_Task Parameters:
--      p_x_Task_Rec                    IN OUT  AHL_VWP_RULES_PVT.Task_Rec_Type  Required
--         The record of visit's task attributes for which task is updated.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------

PROCEDURE Update_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_Task_Rec           IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Rec_Type,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );

-------------------------------------------------------------------
--  Procedure name    : Delete_Task
--  Type              : Private
--  Function          : To delete various different types of tasks in a visit.
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
--  Delete_Task Parameters:
--      p_Visit_Task_ID                      IN      NUMBER       Required
--         The Id of visit's task which has to be deleted.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------

PROCEDURE Delete_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_Visit_Task_Id        IN  NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );

-------------------------------------------------------------------
--  Procedure name    : Search_Task
--  Type              : Private
--  Function          : To create planned task for all MR/Routes
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
--  Search_Task Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The ID of visit for which tasks are created.
--      x_srch_task_tbl                 OUT     AHL_VWP_TASKS_PVT.Srch_Task_Tbl_Type Required
--         The table with all tasks id and results for search criteria with start datetime and end datetime.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Search_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2:='JSP',
   p_visit_id             IN  NUMBER,
   p_x_srch_task_tbl      IN OUT NOCOPY Srch_Task_Tbl_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Summary_Task (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  :='JSP',
   p_Visit_Task_Id        IN  NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );
-------------------------------------------------------------------
--  Procedure name    : Create_PUP_Tasks
--  Type              : Private
--  Function          : To create Unassociated/Summary/Non-Routine task for a visit
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
--  Create_Task Parameters:
--      p_x_Task_Tbl                    IN OUT  AHL_VWP_RULES_PVT.Task_Tbl_Type  Required
--         The record of visit's task attributes for which task is created.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Create_PUP_Tasks (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_x_task_tbl           IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------
--  Procedure name    : Associate_Default_MRs
--  Type              : Private
--  Function          : To create Unassociated/Summary/Non-Routine task for a visit
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--      p_visit_rec                     IN      AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--    Purpose:
--         To associate default MR's during Transit Check Visit creation.
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------

PROCEDURE associate_default_mrs (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_visit_rec            IN  AHL_VWP_VISITS_PVT.Visit_Rec_Type
);
END AHL_VWP_TASKS_PVT;


 

/
