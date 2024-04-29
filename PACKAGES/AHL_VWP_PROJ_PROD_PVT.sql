--------------------------------------------------------
--  DDL for Package AHL_VWP_PROJ_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_PROJ_PROD_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPRDS.pls 120.2.12010000.4 2009/12/23 07:07:17 tchimira ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_PROJ_PROD_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> Visit's PROJECTS and Pushing to PRODUCTION
--    related procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It contains specification for pl/sql records and tables
--
--    Integrate_to_Project       (see below for specification)
--    Add_Task_to_Project        (see below for specification)
--    Delete_Task_to_Project     (see below for specification)
--    Create_Project             (see below for specification)
--    Update_Project             (see below for specification)
--    Delete_Project             (see below for specification)
--
--
--    Validate_Before_Production (see below for specification)
--    Push_to_Production         (see below for specification)
--    Create_Job_Tasks           (see below for specification)
--    Release_Visit              (see below for specification)
--    Release_MR                 (see below for specification)
--    Release_Tasks              (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 14-JAN-2003    SHBHANDA      Created.
-----------------------------------------------------------

---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------

-- Record for Error while Validating before pushing to Production
TYPE Error_Rec_Type IS RECORD (
    Msg_Index      NUMBER          := NULL,
    Msg_Data       VARCHAR2(2000)  := NULL
);

---------------------------------------------
-- Define Table Type for Records Structures --
----------------------------------------------

-- Declare Error table type for record record type
TYPE Error_Tbl_Type IS TABLE OF Error_Rec_Type
INDEX BY BINARY_INTEGER;

--Declare Task table type for task record type for create job tasks API
TYPE Task_Tbl_Type IS TABLE OF AHL_VWP_RULES_PVT.Task_Rec_Type
INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------
-- Declare Procedures --
-------------------------------------------------------------------

-------------------------------------------------------------------
--  Procedure name    : Integrate_to_Projects
--  Type              : Private
--  Function          : To create/update a project and its project tasks
--                      for a Visit and its tasks in VWP
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
--  Integrate_to_Projects Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The visit id which is to be integrated for Projects
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Integrate_to_Projects(
   p_api_version      IN           NUMBER,
   p_init_msg_list    IN           VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN           VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN           NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN           VARCHAR2  := Null,
   p_visit_id         IN           NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
  );

-------------------------------------------------------------------
--  Procedure name : Add_Task_to_Project
--  Type           : Private
--  Function       : To add Project Task for non_routines jobs when task is created in VWP
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Add_Task_to_Project Parameters:
--      p_visit_task_id    IN  NUMBER   Required
--         The visit task id which is integrated to Add tasks to  Projects
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Add_Task_to_Project(
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2 := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2 := Fnd_Api.g_false,
   p_validation_level IN            NUMBER   := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2 := Null,
   p_visit_task_id    IN            NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

-------------------------------------------------------------------
--  Procedure name : Delete_Task_to_Project
--  Type           : Private
--  Function       : To Delete Project Tasks when tasks in VWP is created
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Delete_Task_to_Project Parameters:
--      p_visit_task_id    IN  NUMBER   Required
--         The visit task id which is integrated to Delete tasks to Projects
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Delete_Task_to_Project(
   p_visit_task_id IN            NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
  );

-------------------------------------------------------------------
--  Procedure name    : Update_Project
--  Type              : Private
--  Function          : To update Project status to CLOSED when visit is set as Closed/Canceled OR
--                      To call update when the project created is again pushed to projects.
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Update_Project Parameters:
--      p_visit_id         IN  NUMBER   Required
--         The visit id which is integrated to Update Projects
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------

PROCEDURE Update_Project(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------
--  Procedure name : Delete_Project
--  Type           : Private
--  Function       : To delete a Project when a Visit is deleted
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Delete_Project Parameters:
--      p_visit_id         IN  NUMBER   Required
--         The visit id which is to be integrated to Delete Projects
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Delete_Project(
   p_api_version       IN            NUMBER,
   p_init_msg_list     IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN            VARCHAR2  := Null,
   p_visit_id          IN            NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

--------------------------------------------------------
--  Procedure name : Validate_Before_Production
--  Type           : Private
--  Function       : To create unassociated task for a visit
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Validate_Before_Production Parameters:
--      x_visit_id         IN  NUMBER   Required
--         The visit id which is to be validated before pushing to production.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Validate_Before_Production
    (p_api_version      IN            NUMBER,
     p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
     p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
     p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
     p_module_type      IN            VARCHAR2  := 'JSP',
     p_visit_id         IN            NUMBER,
     x_error_tbl           OUT NOCOPY error_tbl_type,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2
     );


-------------------------------------------------------------------
--  Procedure name : Create_Job_Tasks
--  Type           : Private
--  Function       : To Add Tasks for non_routines jobs
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Create_Job_Tasks Parameters:
--      p_x_task_Tbl                    IN OUT Task_Tbl_Type Required,
--         The table of task records for which non-routine jobs are created.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Create_Job_Tasks(
   p_api_version      IN            NUMBER   :=1.0,
   p_init_msg_list    IN            VARCHAR2 := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2 := Fnd_Api.g_false,
   p_validation_level IN            NUMBER   := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2 := Null,
   p_x_task_Tbl       IN OUT NOCOPY Task_Tbl_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

-- Start of Comments --
--  Procedure name : Release_Visit
--  Type           : Private
--  Function       :To Validate before pushing visit and its tasks to production
--  Pre-reqs       :
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Release visit Parameters:
--       p_visit_id        IN  NUMBER   Required
--       p_release_flag    IN  VARCHAR2 Required
--
--  Version :
--    09/09/2003     SSURAPAN   Initial  Creation
--
--  End of Comments.
--
PROCEDURE Release_Visit (
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit           IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type      IN            VARCHAR2  := NULL,
    p_visit_id         IN            NUMBER,
    p_release_flag     IN            VARCHAR2  := 'N',
    p_orig_visit_id    IN            NUMBER    := NULL, -- By yazhou   08/06/04 for TC changes
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  );

--TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::BEGIN
-------------------------------------------------------------------
--  Procedure name    : BG_Release_visit
--  Type              : Private
--  Function          : To launch background p2p
--  Parameters :

--  Standard IN Parameters :
--      p_commit      IN    VARCHAR2  Fnd_Api.G_FALSE
--
--  Standard OUT Parameters :
--      x_return_status    OUT   VARCHAR2   Required
--      x_msg_count        OUT   NUMBER     Required
--      x_msg_data         OUT   VARCHAR2   Required

--  BG_Release_visit Parameters  :
--      p_visit_id         IN    NUMBER      Required
--         visit id is required to get visit number and passed to concurrent program
--      p_release_flag     IN    VARCHAR2    Required
--         This is passed to concurrent program as an argument
--      x_request_id       OUT   NUMBER     Required
--         Stores request id that is passed from concurrent program

--  Version :
--      02 Dec, 2009    P2P CP ER 9151144 TCHIMIRA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE BG_Release_visit(
    p_api_version       IN            NUMBER,
    p_init_msg_list     IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit            IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level  IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type       IN            VARCHAR2  := NULL,
    p_visit_id          IN            NUMBER,
    p_release_flag      IN            VARCHAR2 := 'U',
    x_request_id        OUT NOCOPY    NUMBER,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2
) ;

-------------------------------------------------------------------
--  Procedure name    : BG_Push_to_Production
--  Type              : Private
--  Function          : Made as an executable for the P2P CP
--  BG_Push_to_Production Parameters :
--      p_visit_number      IN    NUMBER
--      errbuf              OUT   VARCHAR2   Required
--         Defines in pl/sql to store procedure to get error messages into log file
--      retcode             OUT   NUMBER     Required
--         To get the status of the concurrent program

--  Version :
--      02 Dec, 2009    P2P CP ER 9151144 TCHIMIRA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE BG_Push_to_Production(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY NUMBER,
    p_api_version     IN  NUMBER,
    p_visit_number    IN  NUMBER,
    p_release_flag    IN  VARCHAR2 := 'U'
 );

--TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::END

-- Start of Comments --
--  Procedure name : Release_MR
--  Type           : Private
--  Function       :To release all MRs associated to a given UE and return
--                  workorder ID for the root task. Requested by MEL/CDL.
--  Pre-reqs       :
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version         IN  NUMBER   Required
--      p_init_msg_list       IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit              IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level    IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status       OUT VARCHAR2 Required
--      x_msg_count           OUT NUMBER   Required
--      x_msg_data            OUT VARCHAR2 Required
--      x_workorder_id        OUT NUMBER   Required
--
--  Release visit Parameters:
--      p_visit_id            IN  NUMBER   Required
--      p_unit_effectivity_id IN  NUMBER   Required
--      p_release_flag        IN  VARCHAR2 optional
--      p_recalculate_dates   IN  VARCHAR2 Optional (default 'Y', Added for bug 8343599)
--
--  Version :
--    07/21/2005     YAZHOU   Initial  Creation
--
--  End of Comments.
--
PROCEDURE Release_MR (
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit              IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level    IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type         IN            VARCHAR2  := NULL,
    p_visit_id            IN            NUMBER,
    p_unit_effectivity_id IN            NUMBER,
    p_release_flag        IN            VARCHAR2  := 'N',
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
    -- Added an optional parameter to prevent date recalculation
    p_recalculate_dates      IN            VARCHAR2  := 'Y',
    x_workorder_id           OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  );

-- Start of Comments --
--  Procedure name : Release_Tasks
--  Type           : Private
--  Function       : Validate the tasks and then prush tasks to production
--  Pre-reqs       :
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER        Required
--      p_init_msg_list    IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER        Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type      IN  VARCHAR2      Default  Null
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2      Required
--      x_msg_count        OUT NUMBER        Required
--      x_msg_data         OUT VARCHAR2      Required
--
--  Release_Tasks Parameters:
--      p_visit_id         IN  NUMBER        Required
--      p_release_flag     IN  VARCHAR2      Default   'N'
--      p_tasks_tbl        IN  Task_Tbl_Type Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial  Creation
--  End of Comments.
--
PROCEDURE Release_Tasks(
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit           IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type      IN            VARCHAR2  := Null,
    p_visit_id         IN            NUMBER,
    p_tasks_tbl        IN            Task_Tbl_Type,
    p_release_flag     IN            VARCHAR2  := 'N',
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);

END AHL_VWP_PROJ_PROD_PVT;

/
