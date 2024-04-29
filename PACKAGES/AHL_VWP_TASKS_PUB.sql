--------------------------------------------------------
--  DDL for Package AHL_VWP_TASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TASKS_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPTSKS.pls 120.1 2008/06/23 23:08:10 jaramana noship $ */
/*#
 * Package containing public API to add planned tasks to a visit.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname VWP Tasks
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_VISIT
 */

-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Planned_Tasks
--  Type              : Public
--  Function          : Creates planned tasks and adds them to an existing visit.
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Planned_Tasks Parameters:
--       p_visit_id         IN            NUMBER   := null Not needed if p_visit_number is given
--       p_visit_number     IN            NUMBER   := null Ignored if p_visit_id is given
--       p_department_id    IN            NUMBER   := null Not needed if p_department_code is given
--       p_department_code  IN            VARCHAR2 := null Ignored if p_department_id is given
--       p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type
--                          UNIT_EFFECTIVITY_ID is Mandatory
--                          ATTRIBUTE_CATEGORY  is Optional
--                          ATTRIBUTE1..ATTRIBUTE15 are Optional
--                          All others input attributes are ignored
--                          VISIT_TASK_ID has the return value: Id of the task created for the UE.
--
--  End of Comments
-------------------------------------------------------------------------------------------
/*#
 * Procedure for adding planned tasks to an existing visit.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_visit_id Id of the visit to which tasks are to be added. Not needed if p_visit_number is given.
 * @param p_visit_number Number of the visit to which tasks are to be added. Ignored if p_visit_id is given.
 * @param p_department_id Id of the department to which tasks are to be added. Not needed if p_department_code is given.
 * @param p_department_code Code of the department to which tasks are to be added. Ignored if p_department_id is given.
 * @param p_x_tasks_tbl Table of type AHL_VWP_RULES_PVT.Task_Tbl_Type. Input UNIT_EFFECTIVITY_ID, returns VISIT_TASK_ID.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Planned Tasks
 */
PROCEDURE Create_Planned_Tasks (
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_visit_id         IN            NUMBER   := null, -- Not needed if p_visit_number is given
    p_visit_number     IN            NUMBER   := null, -- Ignored if p_visit_id is given
    p_department_id    IN            NUMBER   := null, -- Not needed if p_department_code is given
    p_department_code  IN            VARCHAR2 := null, -- Ignored if p_department_id is given
    p_x_tasks_tbl      IN OUT NOCOPY AHL_VWP_RULES_PVT.Task_Tbl_Type,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2
);

End AHL_VWP_TASKS_PUB;

/
