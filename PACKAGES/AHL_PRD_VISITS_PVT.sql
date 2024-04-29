--------------------------------------------------------
--  DDL for Package AHL_PRD_VISITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_VISITS_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVPSVS.pls 120.0 2005/05/26 10:59:10 appldev noship $*/
-----------------------------------------------------------
-- PACKAGE
--    Ahl_PRD_Visits_Pvt
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Execution --> Production --> VISITS
--    related procedures in Complex Maintenance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
-- NOTES
--
--
-- HISTORY
-- 29-APR-2004    RROY      11.5.10 Created.
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

  PLAN_END_DATE              DATE           := NULL,
  PLAN_END_HOUR              NUMBER         := NULL,

  END_DATE		             DATE           := NULL,
  DUE_BY_DATE		         DATE           := NULL,

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
  PROJECT_FLAG_CODE	         VARCHAR2(30)   := NULL,

  PROJECT_ID                 NUMBER         := NULL,
  PROJECT_NUMBER             NUMBER         := NULL,

  DESCRIPTION                VARCHAR2(4000) := NULL,
  DURATION	 	     NUMBER         := NULL,

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
  OUTSIDE_PARTY_FLAG	     VARCHAR2(1)    := NULL,
  JOB_NUMBER	             VARCHAR2(255)  := NULL,

  -- Post 11.5.10 Enhancements
  -- Added Priority and Project Template
  PROJ_TEMPLATE_NAME         VARCHAR2(30)   := NULL,
  PROJ_TEMPLATE_ID           NUMBER         := NULL,
  PRIORITY_VALUE             VARCHAR2(80)   := NULL,
  PRIORITY_CODE              VARCHAR2(30)   := NULL
);


---------------------------------------------
-- Define Table Type for Records Structures --
----------------------------------------------

-- Declare Visit table type for record
TYPE Visit_Tbl_Type IS TABLE OF Visit_Rec_Type
INDEX BY BINARY_INTEGER;


-------------------------------------------------------------------
-- Declare Procedures --
-------------------------------------------------------------------

--  To find unit configuration name for a given item instance.
FUNCTION get_unitName (p_csi_item_instance_id  IN  NUMBER)
RETURN VARCHAR2;


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

END AHL_PRD_VISITS_PVT;

 

/
