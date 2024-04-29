--------------------------------------------------------
--  DDL for Package AHL_VWP_TASKS_LINKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TASKS_LINKS_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVTLNS.pls 115.5 2003/08/21 18:29:37 shbhanda noship $ */
TYPE TASK_LINK_REC IS RECORD
(
TASK_LINK_ID                            NUMBER,
OBJECT_VERSION_NUMBER                   NUMBER,
LAST_UPDATE_DATE                        DATE,
LAST_UPDATED_BY                         NUMBER,
CREATION_DATE                           DATE,
CREATED_BY                              NUMBER,
LAST_UPDATE_LOGIN                       NUMBER,
VISIT_TASK_ID                           NUMBER,
PARENT_TASK_ID                          NUMBER,
START_FROM_HOUR                         NUMBER,
VISIT_TASK_NUMBER                       VARCHAR2(30),
VISIT_TASK_NAME                         VARCHAR2(80),
HIERARCHY_INDICATOR                     VARCHAR2(30),
ATTRIBUTE_CATEGORY                      VARCHAR2(30),
ATTRIBUTE1                              VARCHAR2(150),
ATTRIBUTE2                              VARCHAR2(150),
ATTRIBUTE3                              VARCHAR2(150),
ATTRIBUTE4                              VARCHAR2(150),
ATTRIBUTE5                              VARCHAR2(150),
ATTRIBUTE6                              VARCHAR2(150),
ATTRIBUTE7                              VARCHAR2(150),
ATTRIBUTE8                              VARCHAR2(150),
ATTRIBUTE9                              VARCHAR2(150),
ATTRIBUTE10                             VARCHAR2(150),
ATTRIBUTE11                             VARCHAR2(150),
ATTRIBUTE12                             VARCHAR2(150),
ATTRIBUTE13                             VARCHAR2(150),
ATTRIBUTE14                             VARCHAR2(150),
ATTRIBUTE15                             VARCHAR2(150),
DML_OPERATION                           VARCHAR2(1)
);

TYPE TASK_LINK_TBL IS TABLE OF TASK_LINK_REC INDEX BY BINARY_INTEGER;

PROCEDURE PROCESS_TASK_LINKS
 (
 p_api_version                  IN          NUMBER     := 1.0,
 p_init_msg_list                IN          VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN          VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN          VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN          VARCHAR2   := NULL,
 x_return_status                    OUT  NOCOPY    VARCHAR2,
 x_msg_count                        OUT  NOCOPY    NUMBER,
 x_msg_data                         OUT  NOCOPY    VARCHAR2,
 p_x_task_link_tbl              IN  OUT NOCOPY TASK_LINK_TBL
 );

END  AHL_VWP_TASKS_LINKS_PVT;

 

/
