--------------------------------------------------------
--  DDL for Package AHL_VWP_VISITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISITS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVVSTS.pls 120.1.12010000.4 2009/12/23 20:51:43 jaramana ship $ */
-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_Visit_Pvt
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> VISITS
--    related procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
--    Process_Visit              (see below for specification)
--    Get_Visit_Details          (see below for specification)
--    Create_Visit               (see below for specification)
--    Update_Visit               (see below for specification)
--    Delete_Visit               (see below for specification)
--    Close_Visit                (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 29-APR-2002    SHBHANDA      11.5.9 Created.
-- 06-AUG-2003    SHBHANDA      11.5.10 Changes.
-----------------------------------------------------------

---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------

-- Record type for visits
TYPE Visit_Rec_Type IS RECORD (
  VISIT_ID                   NUMBER         := NULL,
  VISIT_NAME                 VARCHAR2(80)   := NULL,
  VISIT_NUMBER               NUMBER         := NULL,

  OBJECT_VERSION_NUMBER      NUMBER         := NULL,
  LAST_UPDATE_DATE           DATE           := NULL,
  LAST_UPDATED_BY            NUMBER         := NULL,
  CREATION_DATE              DATE           := NULL,
  CREATED_BY                 NUMBER         := NULL,
  LAST_UPDATE_LOGIN          NUMBER         := NULL,

  ORGANIZATION_ID            NUMBER         := NULL,
  ORG_NAME                   VARCHAR2(240)  := NULL,

  DEPARTMENT_ID              NUMBER         := NULL,
  DEPT_NAME                  VARCHAR2(240)  := NULL,

  SERVICE_REQUEST_ID         NUMBER         := NULL,
  SERVICE_REQUEST_NUMBER     VARCHAR2(80)   := NULL,

  SPACE_CATEGORY_CODE        VARCHAR2(30)   := NULL,
  SPACE_CATEGORY_NAME        VARCHAR2(80)   := NULL,

  START_DATE                 DATE           := NULL,
  START_HOUR                 NUMBER         := NULL,
  START_MIN                  NUMBER         := NULL,

  PLAN_END_DATE              DATE           := NULL,
  PLAN_END_HOUR              NUMBER         := NULL,
  PLAN_END_MIN               NUMBER         := NULL,

  END_DATE                 DATE           := NULL,
  DUE_BY_DATE              DATE           := NULL,

  VISIT_TYPE_CODE            VARCHAR2(30)   := NULL,
  VISIT_TYPE_NAME            VARCHAR2(80)   := NULL,

  STATUS_CODE                VARCHAR2(30)   := NULL,
  STATUS_NAME                VARCHAR2(80)   := NULL,

  SIMULATION_PLAN_ID         NUMBER         := NULL,
  SIMULATION_PLAN_NAME       VARCHAR2(80)   := NULL,

  ASSO_PRIMARY_VISIT_ID      NUMBER         := NULL,

  UNIT_NAME                  VARCHAR2(80)   := NULL,
  ITEM_INSTANCE_ID           NUMBER         := NULL,
  SERIAL_NUMBER              VARCHAR2(30)   := NULL,

  INVENTORY_ITEM_ID          NUMBER         := NULL,
  ITEM_ORGANIZATION_ID       NUMBER         := NULL,
  ITEM_NAME                  VARCHAR2(40)   := NULL,

  SIMULATION_DELETE_FLAG     VARCHAR2(1)    := NULL,
  TEMPLATE_FLAG              VARCHAR2(1)    := NULL,
  OUT_OF_SYNC_FLAG           VARCHAR2(1)    := NULL,

  PROJECT_FLAG               VARCHAR2(30)   := NULL,
  PROJECT_FLAG_CODE          VARCHAR2(30)   := NULL,

  PROJECT_ID                 NUMBER         := NULL,
  PROJECT_NUMBER             NUMBER         := NULL,

  DESCRIPTION                VARCHAR2(4000) := NULL,
  DURATION         NUMBER         := NULL,

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
  ATTRIBUTE15                VARCHAR2(150)  := NULL,
  OPERATION_FLAG             VARCHAR2(1)    := NULL,
  OUTSIDE_PARTY_FLAG       VARCHAR2(1)    := NULL,
  JOB_NUMBER               VARCHAR2(255)  := NULL,

  -- Post 11.5.10 Enhancements
  -- Added Priority and Project Template
  PROJ_TEMPLATE_NAME         VARCHAR2(30)   := NULL,
  PROJ_TEMPLATE_ID           NUMBER         := NULL,
  PRIORITY_VALUE             VARCHAR2(80)   := NULL,
  PRIORITY_CODE              VARCHAR2(30)   := NULL,
  -- For Transit Check
  UNIT_SCHEDULE_ID           NUMBER         := NULL,
  VISIT_CREATE_TYPE          VARCHAR2(30)   := NULL,
  VISIT_CREATE_MEANING       VARCHAR2(80)   := NULL,
  UNIT_HEADER_ID             NUMBER         := NULL,

  --Arvind Rupakula - Flight Number changes
    FLIGHT_NUMBER              VARCHAR2(30)   := NULL,
  --End

  /*Added by sowsubra */
  SUBINVENTORY               VARCHAR2(10)   := NULL,
  LOCATOR_SEGMENT            VARCHAR2(240)  := NULL,
  INV_LOCATOR_ID             NUMBER         := NULL,

  --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
  --Added four columns
  CP_REQUEST_ID                 NUMBER         :=NULL,
  CP_PHASE_CODE                 VARCHAR2(80)   :=NULL,
  CP_STATUS_CODE                VARCHAR2(80)   :=NULL,
  CP_REQUEST_DATE               DATE           :=NULL
);

-- Record for UMP Requirement
TYPE Srch_UMP_Rec_Type IS RECORD (
  ASSIGN_STATUS_MEANING       VARCHAR2(80)  := NULL,
  ASSIGN_STATUS_CODE          VARCHAR2(30)  := NULL,
  VISIT_NUMBER_MEANING        VARCHAR2(80)  := NULL,
  VISIT_NUMBER_CODE           VARCHAR2(30)  := NULL,
  VISIT_STATUS_MEANING        VARCHAR2(80)  := NULL,
  VISIT_STATUS_CODE           VARCHAR2(30)  := NULL,
  VISIT_START_DATE            DATE          := NULL,
  VISIT_END_DATE              DATE          := NULL
);

-- Record for Error while Validating before cancelling the Visit.
-- Post 11.5.10
-- Reema Start
TYPE Error_Rec_Type IS RECORD (
    JOB_ID                    NUMBER        := NULL,
    JOB_NUMBER                VARCHAR2(40)  := NULL,
    SERVICE_REQUEST           VARCHAR2(64)  := NULL,
    TASK_NUMBER               VARCHAR2(80)  := NULL,
    PRIORITY                  VARCHAR2(80)  := NULL,
    SCHEDULED_START_DATE      DATE          := NULL,
    SCHEDULED_END_DATE        DATE          := NULL,
    JOB_STATUS                VARCHAR2(80)  := NULL
);
-- Reema End

---------------------------------------------
-- Define Table Type for Records Structures --
----------------------------------------------

-- Declare Visit table type for record
TYPE Visit_Tbl_Type IS TABLE OF Visit_Rec_Type
INDEX BY BINARY_INTEGER;

-- Declare Error table type for record
TYPE Error_Tbl_Type IS TABLE OF Error_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------
-- Declare Procedures --
-------------------------------------------------------------------

/*

Commented out Jul-28-04 by yazhou
using AHL_UTIL_UC_PKG API instead

--  To find unit configuration name for a given item instance.
FUNCTION get_unitName (p_csi_item_instance_id  IN  NUMBER)
RETURN VARCHAR2;

*/
--------------------------------------------------------------------
--  Procedure Name    : Process_Visit
--  Type              : Private
--  Function          : To process a visit related attributes to create/update/delete the visit
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
--      p_x_Visit_tbl                   IN OUT  AHL_VWP_VISITS_PVT.Visit_Tbl_Type  Required
--         The table of visit records type for which DML operation is to be performed.
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Process_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_Visit_tbl             IN  OUT NOCOPY Visit_Tbl_Type,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
--  Procedure name    : Get_Visit_Details
--  Type              : Private
--  Function          : To get a visit details
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
PROCEDURE Get_Visit_Details (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   x_Visit_rec               OUT NOCOPY Visit_Rec_Type,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2
);

/*
-------------------------------------------------------------------
--  Procedure name    : UMP_Visit_Info (OBSOLETED)
--  Type              : Private
--  Function          : To derive UMP Visit Information
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
--  UMP_Visit_Info Parameters:
--      p_unit_effectivity              IN      NUMBER  Required
--         The unit effectivity for which all visits and task displayed.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
 PROCEDURE UMP_Visit_Info (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := Null,
   p_unit_effectivity_id  IN  NUMBER,

   x_ump_visit_rec        OUT NOCOPY Srch_UMP_Rec_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
  );
*/
-------------------------------------------------------------------
--  Procedure name    : Close_Visit
--  Type              : Private
--  Function          : To close a particular visit
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
--  Close_Visit Parameters:
--      p_visit_id                      IN      NUMBER  Required
--         The visit id which is going to be Closed.
--
--  Version :
--      Initial Version   1.0
-- Added by Srini p_x_cost_session, p_x_mr_session to support costing functionality
-------------------------------------------------------------------
PROCEDURE Close_Visit(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,
   p_x_cost_session_id IN OUT NOCOPY NUMBER,
   p_x_mr_session_id   IN OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
  );

-- Post 11.5.10
-- Reema Start
-------------------------------------------------------------------
--  Procedure name    : Cancel_Visit
--  Type              : Private
--  Function          : To cancel a particular visit
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
--  Cancel_Visit Parameters:
--      p_visit_id                      IN      NUMBER  Required
--         The visit id which is going to be cancelled.
--      x_error_flag                    OUT     VARCHAR2 Required
--         The boolean flag keeps track of Unreleased jobs.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Cancel_Visit(
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,
   p_obj_ver_num       IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
   );
-- Reema End

-- pbarman begin
-------------------------------------------------------------------
--  Procedure name    : DELETE_FLIGHT_ASSOC
--  Type              : Private
--  Function          : to delete the Unit Schedule Id from Visits records
--                      when the Flight schedule is deleted.
--  Parameters  :
--
--  Standard IN  Parameters :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--
--  UMP_Visit_Info Parameters:
--      p_unit_effectivity              IN      NUMBER  Required
--         The unit effectivity for which all visits and task displayed.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
-- procedure to delete the Unit Schedule Id from Visits records
--when the Flight schedule is deleted.

PROCEDURE DELETE_FLIGHT_ASSOC(
 p_unit_schedule_id      IN NUMBER,
 x_return_status     OUT NOCOPY VARCHAR2
);
-- pbarman end

END AHL_VWP_VISITS_PVT;


/
