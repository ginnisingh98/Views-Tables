--------------------------------------------------------
--  DDL for Package AHL_LTP_RESRC_LEVL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_RESRC_LEVL_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPRLGS.pls 115.12 2003/11/06 00:55:14 ssurapan noship $*/

-----------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

TYPE Req_Resources_rec IS RECORD
    (
     ORG_NAME                     VARCHAR2(240)  ,
     DEPT_NAME                    VARCHAR2(80)  ,
     DEPT_ID                      NUMBER        ,
     PLAN_ID                      NUMBER        ,
     START_DATE                   DATE          ,
     END_DATE                     DATE          ,
     DISPLAY_START_DATE           DATE          ,
     DISPLAY_END_DATE             DATE          ,
     UOM_CODE                     VARCHAR2(10)  ,
     REQUIRED_CAPACITY            NUMBER        ,
     RESOURCE_ID                  NUMBER        ,
     RESOURCE_TYPE                NUMBER        ,
     ASO_BOM_TYPE                 VARCHAR2(30)  ,
     RESOURCE_TYPE_MEANING        VARCHAR2(30)
     );

TYPE Aval_Resources_Rec IS RECORD
     (
        PERIOD_STRING           VARCHAR2(80)     ,
        PERIOD_START            DATE             ,
        PERIOD_END              DATE             ,
        REQUIRED_CAPACITY       NUMBER           ,
        DEPT_NAME               VARCHAR2(80)     ,
        RESOURCE_ID             NUMBER           ,
        RESOURCE_TYPE           NUMBER           ,
        RESOURCE_TYPE_MEANING   VARCHAR2(30)     ,
        RESOURCE_NAME           VARCHAR2(30)     ,
        RESOURCE_DESCRIPTION    VARCHAR2(240)
       );

TYPE Resource_Con_Rec IS RECORD
     (
       VISIT_ID                NUMBER            ,
       TASK_ID                 NUMBER            ,
       VISIT_NAME              VARCHAR2(80)      ,
       VISIT_TASK_NAME         VARCHAR2(80)      ,
       TASK_TYPE_CODE          VARCHAR2(30)      ,
       DEPT_NAME               VARCHAR2(80)      ,
       QUANTITY                NUMBER            ,
       REQUIRED_UNITS          NUMBER            ,
       AVAILABLE_UNITS         NUMBER
      );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Aval_Resources_Tbl IS TABLE OF Aval_Resources_Rec INDEX BY BINARY_INTEGER;
TYPE Resource_Con_Tbl IS TABLE OF Resource_Con_Rec INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Derieve_Resource_Capacity
--  Type        : Public
--  Function    :
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
--  Process_Space_Assignment Parameters :
--   p_req_resources           IN      Req_Resources_Rec  Required,
--   x_aval_resources_tbl          OUT Aval_Resources_Tbl,

PROCEDURE Derive_Resource_Capacity
  (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_req_resources           IN  Req_Resources_Rec,
   x_aval_resources_tbl          OUT NOCOPY Aval_Resources_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
 );

-- Start of Comments --
--  Procedure name    : Derieve_Resource_Consum
--  Type        : Public
--  Function    :
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
--  Process_Space_Assignment Parameters :
--   p_req_resources           IN      Req_Resources_Rec  Required,
--   x_resource_con_tbl            OUT Resource_Con_Tbl,

PROCEDURE Derive_Resource_Consum
 (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_req_resources           IN      Req_Resources_Rec,
   x_resource_con_tbl            OUT NOCOPY Resource_Con_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
 );


END AHL_LTP_RESRC_LEVL_PUB;

 

/
