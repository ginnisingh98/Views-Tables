--------------------------------------------------------
--  DDL for Package AHL_UA_FLIGHT_SCHEDULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_FLIGHT_SCHEDULES_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUFSS.pls 120.2 2005/09/14 02:11:12 tamdas noship $ */
/*#
 * Package containing APIs to process flight schedules and following transit visits. It allows users to create, update
 * and delete flight schedules for active units. It also allows users to create a transit visit following a flight schedule.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Unit Flight Schedules
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_SCHEDULES
 */

-- Flag to indicate that search criteria dates must be applied only to the flight arrival dates
G_APPLY_TO_ARRIVAL          CONSTANT VARCHAR2(1) := 'A';

-- Flag to indicate that search criteria dates must be applied only to the flight departure dates
G_APPLY_TO_DEPARTURE        CONSTANT VARCHAR2(1) := 'D';

TYPE FLIGHT_SEARCH_REC_TYPE IS RECORD
(
    UNIT_SCHEDULE_ID    NUMBER,
    UNIT_NAME           VARCHAR2(30),
    FLIGHT_NUMBER       VARCHAR2(80),
    ITEM_NUMBER         VARCHAR2(40),
    SERIAL_NUMBER       VARCHAR2(30),
    ARRIVAL_ORG_CODE    VARCHAR2(3),
    ARRIVAL_DEPT_CODE   VARCHAR2(10),
    DEPARTURE_ORG_CODE  VARCHAR2(3),
    DEPARTURE_DEPT_CODE VARCHAR2(10),
    START_DATE          DATE,
    END_DATE            DATE,
    DATE_APPLY_TO_FLAG  VARCHAR2(1)
);

TYPE FLIGHT_VISIT_SCH_REC_TYPE IS RECORD
(
    UNIT_SCHEDULE_ID        NUMBER,
    FLIGHT_NUMBER                   VARCHAR2(30),
    SEGMENT                         VARCHAR2(30),
    EST_DEPARTURE_TIME              DATE,
    ACTUAL_DEPARTURE_TIME           DATE,
    DEPARTURE_DEPT_ID               NUMBER,
    DEPARTURE_DEPT_CODE     VARCHAR2(10),
    DEPARTURE_ORG_ID                NUMBER,
    DEPARTURE_ORG_CODE              VARCHAR2(3),
    EST_ARRIVAL_TIME                DATE,
    ACTUAL_ARRIVAL_TIME             DATE,
    ARRIVAL_DEPT_ID                 NUMBER,
    ARRIVAL_DEPT_CODE               VARCHAR2(10),
    ARRIVAL_ORG_ID                  NUMBER,
    ARRIVAL_ORG_CODE                VARCHAR2(3),
    PRECEDING_US_ID                 NUMBER,
    UNIT_CONFIG_HEADER_ID           NUMBER,
    UNIT_CONFIG_NAME                VARCHAR2(80),
    CSI_INSTANCE_ID                 NUMBER,
    INSTANCE_NUMBER                 VARCHAR2(30),
    ITEM_NUMBER                     VARCHAR2(40),
    SERIAL_NUMBER                   VARCHAR2(30),
    VISIT_RESCHEDULE_MODE       VARCHAR2(30),
    VISIT_RESCHEDULE_MEANING    VARCHAR2(80),
    OBJECT_VERSION_NUMBER           NUMBER,
    IS_UPDATE_ALLOWED       VARCHAR2(1),
    IS_DELETE_ALLOWED       VARCHAR2(1),
    VISIT_ID            NUMBER,
    VISIT_TYPE_CODE         VARCHAR2(30),
    VISIT_TYPE_MEANING      VARCHAR2(80),
    VISIT_CREATE_TYPE       VARCHAR2(30),
    VISIT_CREATE_MEANING        VARCHAR2(80),
    ATTRIBUTE_CATEGORY              VARCHAR2(30),
    ATTRIBUTE1                      VARCHAR2(150),
    ATTRIBUTE2                      VARCHAR2(150),
    ATTRIBUTE3                      VARCHAR2(150),
    ATTRIBUTE4                      VARCHAR2(150),
    ATTRIBUTE5                      VARCHAR2(150),
    ATTRIBUTE6                      VARCHAR2(150),
    ATTRIBUTE7                      VARCHAR2(150),
    ATTRIBUTE8                      VARCHAR2(150),
    ATTRIBUTE9                      VARCHAR2(150),
    ATTRIBUTE10                     VARCHAR2(150),
    ATTRIBUTE11                     VARCHAR2(150),
    ATTRIBUTE12                     VARCHAR2(150),
    ATTRIBUTE13                     VARCHAR2(150),
    ATTRIBUTE14                     VARCHAR2(150),
    ATTRIBUTE15                     VARCHAR2(150),
    DML_OPERATION           VARCHAR2(1)
);

-- Table of flight schedule recs
TYPE FLIGHT_VISIT_SCH_TBL_TYPE IS TABLE OF FLIGHT_VISIT_SCH_REC_TYPE INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name      : Get_Flight_Schedule_Details
--  Type            : Private
--  Function        : API to retrieve flight schedule details for the given search criteria.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version       IN  NUMBER      Required
--  p_init_msg_list     IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_commit        IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_validation_level  IN  NUMBER      Required, default FND_API.G_VALID_LEVEL_FULL
--  p_default       IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_module_type       IN  VARCHAR2    Required, default NULL

--  Standard OUT Parameters :
--      x_return_status     OUT     VARCHAR2    Required
--      x_msg_count     OUT     NUMBER      Required
--      x_msg_data      OUT     VARCHAR2    Required
--
--  Procedure Parameters :
--      p_flight_search_rec IN  FLIGHT_SEARCH_REC       Required
--      x_flight_schedule_tbl   OUT AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
/*#
 * Use this procedure to retrieve flight schedule details for the given search criteria.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_flight_search_rec Search criteria record of type FLIGHT_SEARCH_REC_TYPE
 * @param x_flight_schedules_tbl Flight schedules details table of type AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Flight Schedule Details
 */
PROCEDURE Get_Flight_Schedule_Details
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_flight_search_rec     IN      FLIGHT_SEARCH_REC_TYPE,
    x_flight_schedules_tbl      OUT  NOCOPY     AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
);

--  Start of Comments  --
--
--  Procedure name      : Process_Flight_Schedules
--  Type            : Private
--  Function        : API to retrieve flight schedule details for the given search criteria.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version       IN  NUMBER      Required
--  p_init_msg_list     IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_commit        IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_validation_level  IN  NUMBER      Required, default FND_API.G_VALID_LEVEL_FULL
--  p_default       IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_module_type       IN  VARCHAR2    Required, default NULL

--  Standard OUT Parameters :
--      x_return_status     OUT     VARCHAR2    Required
--      x_msg_count     OUT     NUMBER      Required
--      x_msg_data      OUT     VARCHAR2    Required
--
--  Procedure Parameters :
--      p_x_flight_schedules_tbl    IN OUT      AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE   Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create, update and delete flight schedules.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_flight_schedules_tbl Flight schedules table of type AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Flight Schedules
 */
PROCEDURE Process_Flight_Schedules
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_x_flight_schedules_tbl        IN OUT  NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
);

--  Start of Comments  --
--
--  Procedure name      : Process_Flight_Schedules
--  Type            : Private
--  Function        : API to retrieve flight schedule details for the given search criteria.
--  Pre-reqs        :
--
--  Standard IN  Parameters :
--      p_api_version       IN  NUMBER      Required
--  p_init_msg_list     IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_commit        IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_validation_level  IN  NUMBER      Required, default FND_API.G_VALID_LEVEL_FULL
--  p_default       IN  VARCHAR2    Required, default FND_API.G_FALSE
--  p_module_type       IN  VARCHAR2    Required, default NULL

--  Standard OUT Parameters :
--      x_return_status     OUT     VARCHAR2    Required
--      x_msg_count     OUT     NUMBER      Required
--      x_msg_data      OUT     VARCHAR2    Required
--
--  Procedure Parameters :
--      p_x_flight_visit_sch_tbl    IN OUT      FLIGHT_VISIT_SCH_TBL_TYPE   Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create flight schedules with following transit visits, using parameters from the created flight schedules. It can also be used to update and delete flight schedules.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_flight_visit_sch_tbl Flight and Visit schedules table of type FLIGHT_VISIT_SCH_TBL_TYPE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Flight and Visit Schedules
 */
PROCEDURE Process_FlightVisit_Sch
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_x_flight_visit_sch_tbl    IN OUT  NOCOPY  FLIGHT_VISIT_SCH_TBL_TYPE
);

END AHL_UA_FLIGHT_SCHEDULES_PUB;


 

/
