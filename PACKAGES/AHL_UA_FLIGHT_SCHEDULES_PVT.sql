--------------------------------------------------------
--  DDL for Package AHL_UA_FLIGHT_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_FLIGHT_SCHEDULES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUFSS.pls 120.0 2005/05/26 01:22:15 appldev noship $ */

TYPE FLIGHT_SCHEDULE_REC_TYPE IS RECORD
(
 UNIT_SCHEDULE_ID                          NUMBER,
 FLIGHT_NUMBER                             VARCHAR2(30),
 SEGMENT                                   VARCHAR2(30),
 EST_DEPARTURE_TIME                        DATE,
 ACTUAL_DEPARTURE_TIME                     DATE,
 DEPARTURE_DEPT_ID                         NUMBER,
 DEPARTURE_DEPT_CODE			   VARCHAR2(10),
 DEPARTURE_ORG_ID                          NUMBER,
 DEPARTURE_ORG_CODE                        VARCHAR2(3),
 EST_ARRIVAL_TIME                          DATE,
 ACTUAL_ARRIVAL_TIME                       DATE,
 ARRIVAL_DEPT_ID                           NUMBER,
 ARRIVAL_DEPT_CODE                         VARCHAR2(10),
 ARRIVAL_ORG_ID                            NUMBER,
 ARRIVAL_ORG_CODE                          VARCHAR2(3),
 PRECEDING_US_ID                           NUMBER,
 UNIT_CONFIG_HEADER_ID                     NUMBER,
 UNIT_CONFIG_NAME                          VARCHAR2(80),
 CSI_INSTANCE_ID                           NUMBER,
 INSTANCE_NUMBER                           VARCHAR2(30),
 ITEM_NUMBER                               VARCHAR2(40),
 SERIAL_NUMBER                             VARCHAR2(30),
 VISIT_RESCHEDULE_MODE			   VARCHAR2(30), -- Visit synchronization rule.
 VISIT_RESCHEDULE_MEANING		   VARCHAR2(80),
 OBJECT_VERSION_NUMBER                     NUMBER,
 IS_UPDATE_ALLOWED			   VARCHAR2(1), -- flag to indicate if update is allowed
 IS_DELETE_ALLOWED			   VARCHAR2(1),  -- flag to indicate if update is allowed
 CONFLICT_MESSAGE			   VARCHAR2(2000),
 ATTRIBUTE_CATEGORY                        VARCHAR2(30),
 ATTRIBUTE1                                VARCHAR2(150),
 ATTRIBUTE2                                VARCHAR2(150),
 ATTRIBUTE3                                VARCHAR2(150),
 ATTRIBUTE4                                VARCHAR2(150),
 ATTRIBUTE5                                VARCHAR2(150),
 ATTRIBUTE6                                VARCHAR2(150),
 ATTRIBUTE7                                VARCHAR2(150),
 ATTRIBUTE8                                VARCHAR2(150),
 ATTRIBUTE9                                VARCHAR2(150),
 ATTRIBUTE10                               VARCHAR2(150),
 ATTRIBUTE11                               VARCHAR2(150),
 ATTRIBUTE12                               VARCHAR2(150),
 ATTRIBUTE13                               VARCHAR2(150),
 ATTRIBUTE14                               VARCHAR2(150),
 ATTRIBUTE15                               VARCHAR2(150),
 DML_OPERATION				   VARCHAR2(1)
);

-- Table of flight schedule recs
TYPE FLIGHT_SCHEDULES_TBL_TYPE IS TABLE OF FLIGHT_SCHEDULE_REC_TYPE INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------------------------
-- Procedure to process(Create/Update/Delete) Flight schedule records
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Procedure name              : Process_Flight_Schedules
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- Process_Flight_Schedules IN parameters:
--      None
--
-- Process_Flight_Schedules IN OUT parameters:
--      p_x_flight_schedules_tbl FLIGHT_SCHEDULES_TBL_TYPE Required
--
-- Process_Flight_Schedules OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
PROCEDURE Process_Flight_Schedules(
 p_api_version               IN         	NUMBER		:=1.0,
 p_init_msg_list             IN         	VARCHAR2	:=FND_API.G_FALSE,
 p_commit                    IN         	VARCHAR2	:=FND_API.G_FALSE,
 p_validation_level          IN 		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN         	VARCHAR2	:=FND_API.G_FALSE,
 p_module_type               IN         	VARCHAR2	:=NULL,
 x_return_status             OUT NOCOPY         VARCHAR2,
 x_msg_count                 OUT NOCOPY         NUMBER,
 x_msg_data                  OUT NOCOPY         VARCHAR2,
 p_x_flight_schedules_tbl    IN OUT NOCOPY   	FLIGHT_SCHEDULES_TBL_TYPE
);

------------------------------------------------------------------------------------------------
-- Procedure to validate a Flight Schedule
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Procedure name              : Validate_Flight_Schedule
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- Validate_Flight_Schedule IN parameters:
--       p_unit_config_id	    NUMBER   Required
--	 p_unit_schedule_id	    NUMBER   Required
--
-- Validate_Flight_Schedule IN OUT parameters:
--      None
--
-- Validate_Flight_Schedule OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE Validate_Flight_Schedule(
 p_api_version               IN         	NUMBER		:=1.0,
 x_return_status             OUT NOCOPY         VARCHAR2,
 x_msg_count                 OUT NOCOPY         NUMBER,
 x_msg_data                  OUT NOCOPY         VARCHAR2,
 p_unit_config_id	     IN			NUMBER,
 p_unit_schedule_id	     IN			NUMBER
);


------------------------------------------------------------------------------------------------
-- Function to check if delete is allowed for a Flight schedule record
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name                : is_delete_allowed
-- Type                         : Private
-- Pre-reqs                     :
-- Function                     :
-- Return Value			: VARCHAR2
-- Parameters                   :
--
-- Standard IN  Parameters :
-- 	None
--
-- Standard OUT Parameters :
--      None
--
-- is_delete_allowed IN parameters:
--      p_unit_schedule_id	NUMBER		Required
--	p_is_super_user		VARCHAR2	Required
--
-- is_delete_allowed IN OUT parameters:
--      None
--
-- is_delete_allowed OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION is_delete_allowed
(
 	p_unit_schedule_id 	IN	NUMBER,
   	p_is_super_user		IN 	VARCHAR2
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to check if update is allowed for a Flight schedule record
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name                : is_update_allowed
-- Type                         : Private
-- Pre-reqs                     :
-- Function                     :
-- Return Value			: VARCHAR2
-- Parameters                   :
--
-- Standard IN  Parameters :
-- 	None
--
-- Standard OUT Parameters :
--      None
--
-- is_update_allowed IN parameters:
--      p_unit_schedule_id	NUMBER		Required
--	p_is_super_user		VARCHAR2	Required
--
-- is_update_allowed IN OUT parameters:
--      None
--
-- is_update_allowed OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION is_update_allowed
(
	p_unit_schedule_id 	IN	NUMBER,
	p_is_super_user		IN 	VARCHAR2
)
RETURN VARCHAR2;

------------------------------------------------------------------------------------------------
-- Function to check if the current user is super user or not
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name                : is_super_user
-- Type                         : Private
-- Pre-reqs                     :
-- Function                     :
-- Return Value			: VARCHAR2
-- Parameters                   :
--
-- Standard IN  Parameters :
-- 	None
--
-- Standard OUT Parameters :
--      None
--
-- is_super_user IN parameters:
--      None
--
-- is_super_user IN OUT parameters:
--      None
--
-- is_super_user OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments
FUNCTION is_super_user

RETURN VARCHAR2;

END AHL_UA_FLIGHT_SCHEDULES_PVT;


 

/
