--------------------------------------------------------
--  DDL for Package AHL_VWP_VISITS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISITS_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPVSTS.pls 120.1.12010000.2 2008/10/27 10:17:40 skpathak noship $ */
/*#
 * Package containing public APIs to manage CMRO visits.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname VWP Visits
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_VISIT
 */

-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Visit
--  Type              : Public
--  Function          : Creates a visit.
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Visit Parameters:
--       p_x_visit_rec      IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type
--          Description of some key attributes in p_x_visit_rec:
--                          VISIT_NAME             VARCHAR2(80)   Mandatory
--                          DESCRIPTION            VARCHAR2(4000) Optional
--                          ORGANIZATION_ID        NUMBER         Optional
--                          ORG_NAME               VARCHAR2(240)  Optional
--                          DEPARTMENT_ID          NUMBER         Optional
--                          DEPT_NAME              VARCHAR2(240)  Optional
--                          SERVICE_REQUEST_ID     NUMBER         Optional
--                          SERVICE_REQUEST_NUMBER VARCHAR2(240)  Optional
--                          START_DATE             DATE           Mandatory for transit visits.
--                          START_HOUR             NUMBER         Optional
--                          START_MIN              NUMBER         Optional
--                          PLAN_END_DATE          DATE           Optional
--                          PLAN_END_HOUR          NUMBER         Optional
--                          PLAN_END_MIN           NUMBER         Optional
--                          VISIT_TYPE_CODE        VARCHAR2(30)   Optional
--                          VISIT_TYPE_NAME        VARCHAR2(80)   Optional
--                          UNIT_HEADER_ID         NUMBER         Optional
--                          UNIT_NAME              VARCHAR2(80)   Optional
--                          PROJ_TEMPLATE_ID       NUMBER         Optional
--                          PROJ_TEMPLATE_NAME     VARCHAR2(30)   Optional
--                          PRIORITY_CODE          VARCHAR2(30)   Optional
--                          PRIORITY_VALUE         VARCHAR2(80)   Optional
--                          UNIT_SCHEDULE_ID       NUMBER         Mandatory for transit visits.
--                          VISIT_CREATE_TYPE      VARCHAR2(30)   Can be null, PRODUCTION_UNRELEASED or PRODUCTION_RELEASED
--                          ATTRIBUTE_CATEGORY     VARCHAR2(240)  Optional
--                          ATTRIBUTE1..ATTRIBUTE15 are Optional
--                          Most other input attributes are ignored
--                          VISIT_ID has the return value: Id of the visit created.
--
--  End of Comments
-------------------------------------------------------------------------------------------
/*#
 * Procedure for creating a new visit.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_x_visit_rec Record of type AHL_VWP_VISITS_PVT.Visit_Rec_Type.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Visit
 */
PROCEDURE Create_Visit (
    p_api_version      IN            NUMBER,
    p_init_msg_list    IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_x_visit_rec      IN OUT NOCOPY AHL_VWP_VISITS_PVT.Visit_Rec_Type,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2
);

End AHL_VWP_VISITS_PUB;

/
