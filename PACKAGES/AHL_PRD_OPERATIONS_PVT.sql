--------------------------------------------------------
--  DDL for Package AHL_PRD_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_OPERATIONS_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVPROS.pls 120.1 2006/02/08 06:03:05 bachandr noship $ */
TYPE PRD_WORKOPERATION_REC IS RECORD
 (
 WORKORDER_OPERATION_ID                             NUMBER,
 ORGANIZATION_ID                                    NUMBER,
 OPERATION_SEQUENCE_NUM                             NUMBER,
 OPERATION_DESCRIPTION                              VARCHAR2(500),
 WORKORDER_ID                                       NUMBER,
 WIP_ENTITY_ID                                      NUMBER,
 ROUTE_ID                                           NUMBER,
 OBJECT_VERSION_NUMBER                              NUMBER,
 LAST_UPDATE_DATE                                   DATE,
 LAST_UPDATED_BY                                    NUMBER,
 CREATION_DATE                                      DATE,
 CREATED_BY                                         NUMBER,
 LAST_UPDATE_LOGIN                                  NUMBER,
 DEPARTMENT_ID                                      NUMBER,
 DEPARTMENT_NAME                                    VARCHAR2(240),
 STATUS_CODE                                        VARCHAR2(30),
 STATUS_MEANING                                     VARCHAR2(80),
 OPERATION_ID                                       NUMBER,
 OPERATION_CODE                                     VARCHAR2(500),
 OPERATION_TYPE_CODE                                VARCHAR2(40),
 OPERATION_TYPE                                     VARCHAR2(80),
 REPLENISH                                          VARCHAR2(1),
 MINIMUM_TRANSFER_QUANTITY                          NUMBER,
 COUNT_POINT_TYPE                                   NUMBER,
 SCHEDULED_START_DATE                               DATE,
 SCHEDULED_START_HR                                 NUMBER,
 SCHEDULED_START_MI                                 NUMBER,
 SCHEDULED_END_DATE                                 DATE,
 SCHEDULED_END_HR                                   NUMBER,
 SCHEDULED_END_MI                                   NUMBER,
 ACTUAL_START_DATE                                  DATE,
 ACTUAL_START_HR                                    NUMBER,
 ACTUAL_START_MI                                    NUMBER,
 ACTUAL_END_DATE                                    DATE,
 ACTUAL_END_HR                                      NUMBER,
 ACTUAL_END_MI                                      NUMBER,
 PLAN_ID                                            NUMBER,
 COLLECTION_ID                                      NUMBER,
 PROPAGATE_FLAG                                     VARCHAR2(1),
 SECURITY_GROUP_ID                                  NUMBER,
 ATTRIBUTE_CATEGORY                                 VARCHAR2(30),
 ATTRIBUTE1                                         VARCHAR2(150),
 ATTRIBUTE2                                         VARCHAR2(150),
 ATTRIBUTE3                                         VARCHAR2(150),
 ATTRIBUTE4                                         VARCHAR2(150),
 ATTRIBUTE5                                         VARCHAR2(150),
 ATTRIBUTE6                                         VARCHAR2(150),
 ATTRIBUTE7                                         VARCHAR2(150),
 ATTRIBUTE8                                         VARCHAR2(150),
 ATTRIBUTE9                                         VARCHAR2(150),
 ATTRIBUTE10                                        VARCHAR2(150),
 ATTRIBUTE11                                        VARCHAR2(150),
 ATTRIBUTE12                                        VARCHAR2(150),
 ATTRIBUTE13                                        VARCHAR2(150),
 ATTRIBUTE14                                        VARCHAR2(150),
 ATTRIBUTE15                                        VARCHAR2(150),
 DML_OPERATION                                      VARCHAR2(1)
 );

TYPE PRD_OPERATION_TBL IS TABLE OF PRD_WORKOPERATION_REC INDEX BY BINARY_INTEGER;


PROCEDURE PROCESS_OPERATIONS
 (
 p_api_version                  IN  		NUMBER     := 1.0,
 p_init_msg_list                IN  		VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN              VARCHAR2,
 p_wip_mass_load_flag           IN              VARCHAR2,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_prd_operation_tbl          IN OUT NOCOPY   PRD_OPERATION_TBL
 );

END  AHL_PRD_OPERATIONS_PVT;

 

/
