--------------------------------------------------------
--  DDL for Package AHL_VWP_PLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_PLAN_TASKS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPLNS.pls 115.1 2003/08/21 18:37:01 shbhanda noship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_PLAN_TASKS_PVT
--
-- PURPOSE
--    This package is a Private API for Creating VWP Visit Planned Tasks in
--    CMRO.  It contains specification for pl/sql records and tables
--
--    Create_Planned_Task       (see below for specification)
--    Update_Planned_Task       (see below for specification)
--    Delete_Planned_Task       (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 12-MAY_2002    Shbhanda      Created.
-- 21-FEB-2003    YAZHOU        Separated from Task package
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.
-----------------------------------------------------------

------------------------------------------------------------------
--  Procedure name    : Create_Planned_Task
--  Type              : Private
--  Function          : To create planned task for selected MR/Routes
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
--  Create_Planned_Task Parameters:
--   p_x_task_Rec           IN OUT AHL_VWP_RULES_PVT.Task_Rec_Type        Required,
--     The record with AHL_VWP_RULES_PVT.Task_Rec_Type
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Create_Planned_Task (
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
--  Procedure name    : Update_Planned_Task
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

PROCEDURE Update_Planned_Task (
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
--  Procedure name    : Delete_Planned_Task
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

PROCEDURE Delete_Planned_Task (
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


END AHL_VWP_PLAN_TASKS_PVT;

 

/
