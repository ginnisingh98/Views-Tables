--------------------------------------------------------
--  DDL for Package AHL_PRD_WORKORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WORKORDER_PVT" AUTHID CURRENT_USER AS
 /* $Header: AHLVPRJS.pls 120.2.12010000.3 2009/05/07 10:43:14 bachandr ship $ */
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
 LAST_UPDATE_DATE                                   DATE  ,
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
 OPERATION_TYPE_CODE                                VARCHAR2(30),
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

TYPE PRD_WORKOPER_TBL IS TABLE OF PRD_WORKOPERATION_REC INDEX BY BINARY_INTEGER;

TYPE PRD_WORKORDER_REC IS RECORD
(
BATCH_ID                                           NUMBER,
HEADER_ID                                          NUMBER,
WORKORDER_ID                                       NUMBER,
WIP_ENTITY_ID                                      NUMBER,
OBJECT_VERSION_NUMBER                              NUMBER,
JOB_NUMBER                                         VARCHAR2(80),
JOB_DESCRIPTION                                    VARCHAR2(240),
ORGANIZATION_ID                                    NUMBER,
ORGANIZATION_NAME                                  VARCHAR2(60),
ORGANIZATION_CODE                                  VARCHAR2(10),
DEPARTMENT_NAME                                    VARCHAR2(240),
DEPARTMENT_ID                                      NUMBER,
DEPARTMENT_CLASS_CODE                              VARCHAR2(10),
STATUS_CODE                                        VARCHAR2(30),
STATUS_MEANING                                     VARCHAR2(80),
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
INVENTORY_ITEM_ID                                  NUMBER,
ITEM_INSTANCE_ID                                   NUMBER,
UNIT_NAME                                          VARCHAR2(80),
ITEM_INSTANCE_NUMBER                               VARCHAR2(30),
WO_PART_NUMBER                                     VARCHAR2(40),
ITEM_DESCRIPTION                                   VARCHAR2(240),
SERIAL_NUMBER                                      VARCHAR2(30),
ITEM_INSTANCE_UOM                                  VARCHAR2(3),
COMPLETION_SUBINVENTORY                            VARCHAR2(10),
COMPLETION_LOCATOR_ID                              NUMBER,
COMPLETION_LOCATOR_NAME                            VARCHAR2(204),
WIP_SUPPLY_TYPE                                    NUMBER,
WIP_SUPPLY_MEANING                                 VARCHAR2(80),
FIRM_PLANNED_FLAG                                  NUMBER,
MASTER_WORKORDER_FLAG                              VARCHAR2(1),
VISIT_ID                                           NUMBER,
VISIT_NUMBER                                       NUMBER,
VISIT_NAME                                         VARCHAR2(80),
VISIT_TASK_ID                                      NUMBER,
MR_HEADER_ID                                       NUMBER,
VISIT_TASK_NUMBER                                  NUMBER,
MR_TITLE                                           VARCHAR2(80),
MR_ROUTE_ID                                        NUMBER,
ROUTE_ID                                           NUMBER,
CONFIRM_FAILURE_FLAG                               VARCHAR2(1),
PROPAGATE_FLAG                                     VARCHAR2(1),
SERVICE_ITEM_ID                                    NUMBER,
SERVICE_ITEM_ORG_ID                                NUMBER,
SERVICE_ITEM_DESCRIPTION                           VARCHAR2(240),
SERVICE_ITEM_NUMBER                                VARCHAR2(40),
SERVICE_ITEM_UOM                                   VARCHAR2(3),
PROJECT_ID                                         NUMBER,
PROJECT_TASK_ID                                    NUMBER,
QUANTITY                                           NUMBER,
MRP_QUANTITY                                       NUMBER,
INCIDENT_ID                                        NUMBER,
ORIGINATION_TASK_ID                                NUMBER,
PARENT_ID                                          NUMBER,
TASK_MOTIVE_STATUS_ID                              NUMBER,
ALLOW_EXPLOSION                                    VARCHAR2(1),
CLASS_CODE                                         VARCHAR2(10),
JOB_PRIORITY                                       NUMBER,
JOB_PRIORITY_MEANING                               VARCHAR2(30),
CONFIRMED_FAILURE_FLAG                             NUMBER,
UNIT_EFFECTIVITY_ID                                NUMBER,
PLAN_ID                                            NUMBER,
COLLECTION_ID                                      NUMBER,
SUB_INVENTORY                                      VARCHAR2(10),
LOCATOR_ID                                         NUMBER,
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
LAST_UPDATE_DATE                                   DATE,
LAST_UPDATED_BY                                    NUMBER,
CREATION_DATE                                      DATE,
CREATED_BY                                         NUMBER,
LAST_UPDATE_LOGIN                                  NUMBER,
DML_OPERATION                                      VARCHAR2(1),
HOLD_REASON_CODE                                   VARCHAR2(30),
HOLD_REASON                                        VARCHAR2(80)
);

TYPE PRD_WORKORDER_TBL IS TABLE OF PRD_WORKORDER_REC INDEX BY BINARY_INTEGER;

TYPE PRD_WORKORDER_REL_REC IS RECORD
(
  batch_id             NUMBER,
  wo_relationship_id   NUMBER,
  parent_header_id     NUMBER,
  parent_wip_entity_id NUMBER,
  child_header_id      NUMBER,
  child_wip_entity_id  NUMBER,
  relationship_type    NUMBER,
  dml_operation        VARCHAR2(1)
);

TYPE PRD_WORKORDER_REL_TBL IS TABLE OF PRD_WORKORDER_REL_REC INDEX BY BINARY_INTEGER;

PROCEDURE process_jobs
(
 p_api_version           IN            NUMBER     := 1.0,
 p_init_msg_list         IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default               IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type           IN            VARCHAR2,
 x_return_status         OUT NOCOPY    VARCHAR2,
 x_msg_count             OUT NOCOPY    NUMBER,
 x_msg_data              OUT NOCOPY    VARCHAR2,
 p_x_prd_workorder_tbl   IN OUT NOCOPY PRD_WORKORDER_TBL,
 p_prd_workorder_rel_tbl IN            PRD_WORKORDER_REL_TBL
);

PROCEDURE update_job
(
 p_api_version         IN             NUMBER     := 1.0,
 p_init_msg_list       IN             VARCHAR2   := FND_API.G_TRUE,
 p_commit              IN             VARCHAR2   := FND_API.G_FALSE,
 p_validation_level    IN             NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default             IN             VARCHAR2   := FND_API.G_FALSE,
 p_module_type         IN             VARCHAR2,
 x_return_status       OUT NOCOPY     VARCHAR2,
 x_msg_count           OUT NOCOPY     NUMBER,
 x_msg_data            OUT NOCOPY     VARCHAR2,
 p_wip_load_flag       IN             VARCHAR2   := 'Y',
 p_x_prd_workorder_rec IN OUT NOCOPY  PRD_WORKORDER_REC,
 p_x_prd_workoper_tbl  IN OUT NOCOPY  PRD_WORKOPER_TBL
);

PROCEDURE release_visit_jobs
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT  NOCOPY VARCHAR2,
  x_msg_count           OUT  NOCOPY NUMBER,
  x_msg_data            OUT  NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
);

PROCEDURE cancel_visit_jobs
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT  NOCOPY VARCHAR2,
  x_msg_count           OUT  NOCOPY NUMBER,
  x_msg_data            OUT  NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
);

PROCEDURE validate_dependencies
(
  p_api_version         IN   NUMBER    := 1.0,
  p_init_msg_list       IN   VARCHAR2  := FND_API.G_TRUE,
  p_commit              IN   VARCHAR2  := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  p_default             IN   VARCHAR2  := FND_API.G_FALSE,
  p_module_type         IN   VARCHAR2  := NULL,
  x_return_status       OUT  NOCOPY VARCHAR2,
  x_msg_count           OUT  NOCOPY NUMBER,
  x_msg_data            OUT  NOCOPY VARCHAR2,
  p_visit_id            IN   NUMBER,
  p_unit_effectivity_id IN   NUMBER,
  p_workorder_id        IN   NUMBER
);

PROCEDURE reschedule_visit_jobs
(
  p_api_version          IN  NUMBER    := 1.0 ,
  p_init_msg_list        IN  VARCHAR2  :=  FND_API.G_TRUE,
  p_commit               IN  VARCHAR2  :=  FND_API.G_FALSE,
  p_validation_level     IN  NUMBER    :=  FND_API.G_VALID_LEVEL_FULL,
  p_default              IN  VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN  VARCHAR2  := Null,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_visit_id             IN  NUMBER,
  p_x_scheduled_start_date  IN OUT NOCOPY DATE,
  p_x_scheduled_end_date   IN OUT NOCOPY DATE
);

TYPE TURNOVER_NOTES_REC_TYPE IS RECORD
(
  jtf_note_id           NUMBER,
  source_object_id      NUMBER,
  source_object_code    VARCHAR2(30),
  notes                 VARCHAR2(2000),
  employee_id           NUMBER,--PERSON ID in PER_PEOPLE_F
  employee_name         VARCHAR2(240),--FULL_NAME in PER_PEOPLE_F
  entered_date          DATE,
  org_id                NUMBER
);

TYPE TURNOVER_NOTES_TBL_TYPE IS TABLE OF TURNOVER_NOTES_REC_TYPE INDEX BY BINARY_INTEGER;

PROCEDURE INSERT_TURNOVER_NOTES
(
  p_api_version          IN  NUMBER    := 1.0 ,
  p_init_msg_list        IN  VARCHAR2  :=  FND_API.G_TRUE,
  p_commit               IN  VARCHAR2  :=  FND_API.G_FALSE,
  p_validation_level     IN  NUMBER    :=  FND_API.G_VALID_LEVEL_FULL,
  p_default              IN  VARCHAR2   := FND_API.G_FALSE,
  p_module_type          IN  VARCHAR2  := Null,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_trunover_notes_tbl	 IN OUT NOCOPY	AHL_PRD_WORKORDER_PVT.turnover_notes_tbl_type

);

-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
--------------------------------------------------------------------------------------------------
-- Procedure added for Bug # 8329755 (FP for Bug # 7697909)
-- This procedure updates master work order scheduled dates by deriving
-- it from underlying child work orders. This procedure does this logic
-- by only looking at immediate children of any MWO instead of drilling
-- down the entire hierarchy of children as done by update_job API.
--
-- Parameters
--    p_workorder_id IN NUMBER  -- child work order id. The parent of this child work order will be
--                                 updated with derived scheduled dates.
--------------------------------------------------------------------------------------------------
PROCEDURE Update_Master_Wo_Dates(

   p_workorder_id IN NUMBER
);
-- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

END AHL_PRD_WORKORDER_PVT;

/
