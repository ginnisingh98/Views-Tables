--------------------------------------------------------
--  DDL for Package AHL_VWP_VISITS_STAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISITS_STAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSTGS.pls 120.0 2005/05/26 00:01:23 appldev noship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_VISITS_STAGES_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> VISITS --> STAGES
--    related procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
--    Process_Visit              (see below for specification)
--    Get_Visit_Details          (see below for specification)
--    Create_Visit               (see below for specification)
--    Copy_Visit                 (see below for specification)
--    Update_Visit               (see below for specification)
--    Delete_Visit               (see below for specification)
--    UMP_Visit_Info             (see below for specification)
--    Close_Visit                (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 04-FEB-2004    ADHARIA       POST 11.5.10 Created.
-----------------------------------------------------------

---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------

-- Record type for visit stages
TYPE Visit_Stages_Rec_Type IS RECORD (
  Stage_Id			NUMBER,
  Stage_Num			NUMBER,
  Stage_Name			VARCHAR2(80):= NULL,
  Duration			NUMBER:= NULL,
  Stage_Planned_Start_Time	DATE:= NULL,
  Stage_Planned_End_Time		DATE:= NULL,
  Stage_Actual_End_Time		DATE:= NULL,
  OBJECT_VERSION_NUMBER      NUMBER         := NULL,

  ATTRIBUTE_CATEGORY         VARCHAR2(30)   := NULL,
  ATTRIBUTE1                 VARCHAR2(150)  := NULL,
  ATTRIBUTE2                 VARCHAR2(150)  := NULL,
  ATTRIBUTE3                 VARCHAR2(150)  := NULL,
  ATTRIBUTE4                 VARCHAR2(150)  := NULL,
  ATTRIBUTE5                 VARCHAR2(150)  := NULL,
  ATTRIBUTE6                 VARCHAR2(150)  := NULL,
  ATTRIBUTE7                 VARCHAR2(150)  := NULL,
  ATTRIBUTE8                 VARCHAR2(150)  := NULL,
  ATTRIBUTE9                 VARCHAR2(150)  := NULL,
  ATTRIBUTE10                VARCHAR2(150)  := NULL,
  ATTRIBUTE11                VARCHAR2(150)  := NULL,
  ATTRIBUTE12                VARCHAR2(150)  := NULL,
  ATTRIBUTE13                VARCHAR2(150)  := NULL,
  ATTRIBUTE14                VARCHAR2(150)  := NULL,
  ATTRIBUTE15                VARCHAR2(150)  := NULL
);

TYPE Visit_Stages_Times_Rec_Type IS RECORD (
  STAGE_ID                      NUMBER           := NULL,  -- Id of the visit's task stage
  Stage_Num			NUMBER,
  Stage_Name			VARCHAR2(80):= NULL,
  Duration			NUMBER:= NULL,

  stage_START_HOUR              NUMBER  := NULL,  -- Normalized start hour for this stage (w.r.t visit)
  stage_END_HOUR                NUMBER  := NULL,  -- Normalized end hour for this stage
  PLANNED_START_TIME		DATE:= NULL,
  Planned_End_Time		DATE:= NULL,
  Actual_End_Time		DATE:= NULL
);


---------------------------------------------
-- Define Table Type for Rwecords Structures --
----------------------------------------------

-- Declare Visit table type for record
TYPE Visit_Stages_Tbl_Type IS TABLE OF Visit_Stages_Rec_Type
INDEX BY BINARY_INTEGER;


TYPE Visit_Stages_Times_Tbl_Type IS TABLE OF Visit_Stages_Times_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------
-- Declare Procedures --
-------------------------------------------------------------------

--------------------------------------------------------------------
--  Procedure Name    : Update_Stages
--  Type              : Public
--  Function          : To update a visit stages related attributes to update the visit
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
--  Process_Visit Parameters:
--      p_visit_id                      IN      NUMBER       Required
--      p_x_Visit_Stages_tbl            IN OUT  AHL_VWP_VISITS_STAGES_PVT.Visit_Tbl_Type  Required
--         The table of visit records type for which Update operation is to be performed.
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Update_Stages (
   p_api_version             IN      NUMBER    :=1.0,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_x_stages_tbl            IN  OUT NOCOPY Visit_Stages_Tbl_Type,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
--  Procedure name    : Get_Stages_Details
--  Type              : Public
--  Function          : To get a visit stage details
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
--  Get_Visit_Details Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The visit id whose details are to be displayed
--      x_Visit_rec                     OUT  AHL_VWP_VISITS_PVT.Visit_Rec_Type  Required
--         The record of visit attributes whose details are to be displayed
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Get_Stages_Details (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_start_row               IN      NUMBER,
   p_rows_per_page           IN	     NUMBER,

   x_Stages_Tbl              OUT NOCOPY Visit_Stages_Tbl_Type,
   x_row_count               OUT NOCOPY NUMBER,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
--  Procedure Name    : Create_Stages
--  Type              : Public
--  Function          : To create a visit stages related attributes to update the visit
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
--  Process_Visit Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The visit id for which to create the stages
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Create_Stages (
   p_api_version             IN      NUMBER    :=1.0,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Stages
--
-- PURPOSE
--    To delete a Stage for visit.
--    will be called from delete visit and requires only visit_id
--------------------------------------------------------------------
PROCEDURE Delete_Stages (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN     VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN     NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',

   p_visit_id                IN     NUMBER,

   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
);

--------------------------------------------------------------------
--  Procedure Name    : Validate_stage_update
--  Type              : Public
--  Function          : To validate the update of task stages.
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
--  Process_Visit Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The visit id for which to create the stages
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE VALIDATE_STAGE_UPDATES(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,

    p_visit_id              IN            NUMBER,
    p_visit_task_id         IN            NUMBER,
    p_stage_name            IN            VARCHAR2   := NULL, -- defaulted as u may pass id or num

    x_stage_id              OUT NOCOPY    NUMBER            ,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

--------------------------------------------------------------------
--  Procedure name    : Check_Stage_Name_Or_Id
--  Type              : Private
--  Function          : Stage Number to ID conversion
--  Parameters  :
--
--  IN  Parameters :
--  p_visit_id          IN NUMBER
--  p_Stage_Num         IN NUMBER


--   OUT Parameters :
--    x_Stage_id                      OUT NOCOPY NUMBER
--    x_return_status                 OUT NOCOPY VARCHAR2
--   x_error_msg_code			OUT NOCOPY VARCHAR2

--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Check_Stage_Name_Or_Id
    (p_visit_id          IN NUMBER,
     p_Stage_Name         IN VARCHAR2,
     x_Stage_id          OUT NOCOPY NUMBER,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_error_msg_code    OUT NOCOPY VARCHAR2
     );


END AHL_VWP_VISITS_STAGES_PVT;


 

/
