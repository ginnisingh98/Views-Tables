--------------------------------------------------------
--  DDL for Package AHL_LTP_REQST_MATRL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_REQST_MATRL_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPRMTS.pls 115.9 2003/10/29 22:28:12 ssurapan noship $ */
--
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

TYPE Schedule_Mr_Rec IS RECORD (
     SCHEDULE_MATERIALS_ID       NUMBER        ,
     OBJECT_VERSION_NUMBER       NUMBER        ,
     VISIT_ID                    NUMBER        ,
     ITEM_ID                     NUMBER        ,
     ITEM                        VARCHAR2(80)  ,
     ORG_ID                      NUMBER        ,
     VISIT_TASK_ID               NUMBER        ,
     TASK_NAME                   VARCHAR2(30)  ,
     MR_ROUTE_ID                 NUMBER        ,
     REQ_ARRIVAL_DATE            DATE          ,
     QUANTITY                    NUMBER        ,
     REQUEST_ID                  NUMBER        ,
     TRANSACTION_ID              NUMBER        ,
     SCHEDULE_MAT_ID             NUMBER        ,
     MRP_STATUS_CODE             NUMBER        ,
     MRP_STATUS_MEAN             VARCHAR2(30)  ,
     SCHEDULED_DATE              DATE          ,
     SCHEDULED_QUANTITY          NUMBER        ,
     PLAN_NAME                   VARCHAR2(30)  ,
     ITEM_GROUP_ID               NUMBER        ,
     UOM_CODE                    VARCHAR2(30)  ,
     RT_OPER_MAT_ID              NUMBER        ,
     POSITION_PATH_ID            NUMBER        ,
     POSITION_PATH               VARCHAR2(4000),
     ITEM_COMP_DETAIL_ID          NUMBER       ,
     RELATIONSHIP_ID             NUMBER        ,
     RELATIONSHIP_NAME           VARCHAR2(80)  ,
     REWORK_PERCENT              NUMBER        ,
     REPLACE_PERCENT             NUMBER        ,
     OPERATION_FLAG              VARCHAR2(1)
     );

TYPE Task_Details_Rec IS RECORD (
     VISIT_ID                     NUMBER       ,
     ORG_ID                       NUMBER       ,
     VISIT_TASK_ID                NUMBER       ,
     TASK_NAME                    VARCHAR2(30) ,
     VISIT_TASK_NUMBER            NUMBER       ,
     MR_ROUTE_ID                  NUMBER       ,
     INVENTORY_ITEM_ID            NUMBER       ,
     ITEM                         VARCHAR2(80) ,
     REQ_ARRIVAL_DATE             DATE         ,
     QUANTITY                     NUMBER       ,
     REQUEST_ID                   NUMBER       ,
     MRP_STATUS_CODE              NUMBER       ,
     MRP_STATUS_MEAN              VARCHAR2(30) ,
     SCHEDULED_DATE               DATE         ,
     SCHEDULED_FLAG               NUMBER
     );

TYPE Planned_Materials_Rec IS RECORD (
        SCHEDULE_MATERIAL_ID    NUMBER         ,
		OBJECT_VERSION_NUMBER   NUMBER         ,
        VISIT_ID                NUMBER         ,
        VISIT_TASK_ID           NUMBER         ,
        TASK_NAME               VARCHAR2(30)   ,
        INVENTORY_ITEM_ID       NUMBER         ,
        ITEM_DESCRIPTION        VARCHAR2(80)   ,
        REQUESTED_DATE          DATE           ,
        QUANTITY                NUMBER         ,
		POSITION_PATH_ID        NUMBER         ,
		RELATIONSHIP_ID         NUMBER
        );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
 TYPE Schedule_Mr_Tbl IS TABLE OF Schedule_Mr_Rec INDEX BY BINARY_INTEGER;
 TYPE Task_Details_Tbl IS TABLE OF Task_Details_Rec INDEX BY BINARY_INTEGER;
 TYPE Planned_Materials_Tbl IS TABLE OF Planned_Materials_Rec
         INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Update_Planned_Materials
--  Type        : Private
--  Function    : This procedure Updates Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
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
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Planned_Materials Parameters :
--       p_planned_materials_tbl          IN   Planned_Materials_Tbl,Required
--
--
PROCEDURE Update_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN    VARCHAR2  := 'JSP',
   p_planned_Materials_tbl   IN    Planned_Materials_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);
--
END AHL_LTP_REQST_MATRL_PUB;

 

/
