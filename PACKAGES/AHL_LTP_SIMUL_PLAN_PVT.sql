--------------------------------------------------------
--  DDL for Package AHL_LTP_SIMUL_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SIMUL_PLAN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSPNS.pls 115.8 2003/09/08 21:32:07 ssurapan noship $*/
--
-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_SIMUL_PLAN_PVT
--
-- PURPOSE
--    This package is a Private API for managing Simulation plan information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SPACE_UNAVIALABLE_VL:
--    Create_Simulation_plan (see below for specification)
--    Update_Simulation_plan (see below for specification)
--    Delete_Simulation_plan (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 23-Apr-2002    ssurapan      Created.
-----------------------------------------------------------

-------------------------------------
-----          SIMULATION PLANS            ----------------
-------------------------------------
TYPE Simulation_Plan_Rec IS RECORD (
   simulation_plan_id           NUMBER,
   last_update_date             DATE,
   last_updated_by              NUMBER,
   creation_date                DATE,
   created_by                   NUMBER,
   last_update_login            NUMBER,
   object_version_number        NUMBER,
   simulation_plan_name         VARCHAR2(80),
   primary_plan_flag            VARCHAR2(1),
   description                  VARCHAR2(250),
   attribute_category           VARCHAR2(30),
   attribute1                   VARCHAR2(150),
   attribute2                   VARCHAR2(150),
   attribute3                   VARCHAR2(150),
   attribute4                   VARCHAR2(150),
   attribute5                   VARCHAR2(150),
   attribute6                   VARCHAR2(150),
   attribute7                   VARCHAR2(150),
   attribute8                   VARCHAR2(150),
   attribute9                   VARCHAR2(150),
   attribute10                  VARCHAR2(150),
   attribute11                  VARCHAR2(150),
   attribute12                  VARCHAR2(150),
   attribute13                  VARCHAR2(150),
   attribute14                  VARCHAR2(150),
   attribute15                  VARCHAR2(150),
   operation_flag               VARCHAR2(1)
);

--Declare table type
TYPE simulation_plan_tbl IS TABLE OF Simulation_Plan_Rec
INDEX BY BINARY_INTEGER;

-----------------------------------------------------------
-- SIMULATION VISIT
-----------------------------------------------------------

-- Record for AHL_SIMULATION_VISIT
TYPE Simulation_Visit_Rec IS RECORD (
   visit_id                     NUMBER,
   visit_number                 NUMBER,
   plan_id                      NUMBER,
   last_update_date             DATE,
   last_updated_by              NUMBER,
   creation_date                DATE,
   created_by                   NUMBER,
   last_update_login            NUMBER,
   organization_id              NUMBER,
   department_id                NUMBER,
   start_date_time              DATE,
   item_instance_id             NUMBER,
   inventory_item_id            NUMBER,
   asso_primary_visit_id        NUMBER,
   primary_visit_number         NUMBER,
   object_version_number        NUMBER,
   attribute_category           VARCHAR2(30),
   attribute1                   VARCHAR2(150),
   attribute2                   VARCHAR2(150),
   attribute3                   VARCHAR2(150),
   attribute4                   VARCHAR2(150),
   attribute5                   VARCHAR2(150),
   attribute6                   VARCHAR2(150),
   attribute7                   VARCHAR2(150),
   attribute8                   VARCHAR2(150),
   attribute9                   VARCHAR2(150),
   attribute10                  VARCHAR2(150),
   attribute11                  VARCHAR2(150),
   attribute12                  VARCHAR2(150),
   attribute13                  VARCHAR2(150),
   attribute14                  VARCHAR2(150),
   attribute15                  VARCHAR2(150)
);

--Declare table type
TYPE Simulation_Visit_Tbl IS TABLE OF Simulation_Visit_Rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Simulation_plan
--
-- PURPOSE
--    Create Simulation plan Record
--
-- PARAMETERS
--    p_simulation_plan_rec: the record representing AHL_SIMULATION_PLANS_VL view..
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Create_Simulation_plan (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_simulation_plan_rec   IN   OUT NOCOPY ahl_ltp_simul_plan_pub.Simulation_Plan_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Simulation_plan
--
-- PURPOSE
--    Update Simulation plan Record.
--
-- PARAMETERS
--    p_simulation_plan_rec: the record representing AHL_SIMULATION_PLAN_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Update_Simulation_plan (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_simulation_plan_rec     IN  ahl_ltp_simul_plan_pub.Simulation_Plan_Rec,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Simulation_plan
--
-- PURPOSE
--    Delete  Simulation plan Record.
--
-- PARAMETERS
--    p_simulation_plan_rec: the record representing AHL_SIMULATION_PLAN_VL
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Simulation_plan (
   p_api_version                IN    NUMBER,
   p_init_msg_list              IN    VARCHAR2  := FND_API.g_false,
   p_commit                     IN    VARCHAR2  := FND_API.g_false,
   p_validation_level           IN    NUMBER    := FND_API.g_valid_level_full,
   p_simulation_plan_rec        IN    ahl_ltp_simul_plan_pub.Simulation_plan_Rec,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2

);



--------------------------------------------------------------------
-- PROCEDURE
--    Copy_Visits_To_Plan
--
-- PURPOSE
--    Copy Visits from primary plan to  Simulation Plan and one simulation plan
--    to another
--
--
-- PARAMETERS
-- p_visit_rec     Record representing AHL_VISITS_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Copy_Visits_To_Plan (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER    ,
   p_visit_number            IN      NUMBER    ,
   p_plan_id                 IN      NUMBER,
   p_v_ovn                   IN      NUMBER,
   p_p_ovn                   IN      NUMBER,
   x_visit_id                      OUT NOCOPY NUMBER,
   x_return_status                 OUT NOCOPY VARCHAR2,
   x_msg_count                     OUT NOCOPY NUMBER,
   x_msg_data                      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Remove_Visits_FR_Plan
--
-- PURPOSE
--    Remove  Visits from  Simulation Plan
--
--
-- PARAMETERS
-- p_visit_rec     Record representing AHL_VISITS_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Remove_Visits_FR_Plan (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_plan_id                 IN      NUMBER,
   p_v_ovn                   IN      NUMBER,
   x_return_status                 OUT NOCOPY     VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY     VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Toggle_Simulation_Delete
--
-- PURPOSE
--    Toggle Simulation Delete/Undelete
--
-- PARAMETERS
--    p_visit_id                    : Visit Id
--    p_visit_object_version_number : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Toggle_Simulation_Delete (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                      IN      NUMBER,
   p_visit_object_version_number   IN      NUMBER,
   x_return_status                 OUT NOCOPY     VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY     VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Set_Plan_As_Primary
--
-- PURPOSE
--    Set Plan As Primary
--
-- PARAMETERS
--    p_plan_id                     : Simulation Plan Id
--    p_object_version_number       : Plan Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Plan_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Set_Visit_As_Primary
--
-- PURPOSE
--    Set Visit As Primary
--
-- PARAMETERS
--    p_visit_id                    : Simulation Visit Id
--    p_object_version_number       : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Visit_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);
--
--------------------------------------------------------------------
-- PROCEDURE
--    Delet_Simul_Visits
--
-- PURPOSE
--    Procedure will be used to remove all the simulated visits. Will be
--    Called from VWP beofre visit has been pushed to production
--
-- PARAMETERS
--    p_visit_id                    : Primary Visit Id
--
-- NOTES
--------------------------------------------------------------------

PROCEDURE Delete_Simul_Visits (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_visit_id                IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
);

END AHL_LTP_SIMUL_PLAN_PVT;

 

/
