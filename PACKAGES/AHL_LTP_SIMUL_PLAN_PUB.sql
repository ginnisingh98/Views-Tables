--------------------------------------------------------
--  DDL for Package AHL_LTP_SIMUL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SIMUL_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPSPNS.pls 115.6 2002/12/04 19:23:22 ssurapan noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_SIMUL_PLAN_PUB
--
-- PURPOSE
--    This package is a Public API for managing Simulation Plans in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SIMULATION_PLANS
--    Process_Simulation_Plan (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 22-Apr-2002    ssurapan      Created.
-----------------------------------------------------------
-----------------------------------------------------------
-- SIMULATION PLAN
-----------------------------------------------------------

-- Record for AHL_SIMULATION_PLANS
TYPE Simulation_Plan_Rec IS RECORD (
   plan_id                      NUMBER,
   last_update_date             DATE,
   last_updated_by              NUMBER,
   creation_date                DATE,
   created_by                   NUMBER,
   last_update_login            NUMBER,
   primary_plan_flag            VARCHAR2(1),
   plan_name                    VARCHAR2(80),
   description                  VARCHAR2(250),
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
   attribute15                  VARCHAR2(150),
   operation_flag               VARCHAR2(1)
);


--Declare table type
TYPE Simulation_Plan_Tbl IS TABLE OF Simulation_Plan_Rec
INDEX BY BINARY_INTEGER;

-----------------------------------------------------------
-- SIMULATION VISIT
-----------------------------------------------------------

-- Record for AHL_SIMULATION_VISIT
TYPE Simulation_Visit_Rec IS RECORD (
   primary_visit_id             NUMBER,
   primary_ovn                  NUMBER,
   plan_id                      NUMBER,
   plan_name                    VARCHAR2(30),
   plan_ovn                     NUMBER,
   visit_id                     NUMBER,
   primary_visit_number         NUMBER,
   visit_ovn                    NUMBER,
   operation_flag               VARCHAR2(1)
);

--Declare table type
TYPE Simulation_Visit_Tbl IS TABLE OF Simulation_Visit_Rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Simulation_Plan
--
-- PURPOSE
--    Process Simulation Plan Record
--
-- PARAMETERS
--    p_x_simulation_plan_tbl   : Table Representing Simulation_Plan_Tbl
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Process_Simulation_Plan (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_simulation_plan_tbl   IN  OUT NOCOPY Simulation_Plan_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Simulation_Visit
--
-- PURPOSE
--    Process Simulation Visit
--
-- PARAMETERS
--    p_simulation_visit_tbl      : Table Representing Simulation_Visit_Tbl
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Process_Simulation_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_simulation_visit_tbl    IN   OUT NOCOPY Simulation_Visit_Tbl,
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




END AHL_LTP_SIMUL_PLAN_PUB;

 

/
