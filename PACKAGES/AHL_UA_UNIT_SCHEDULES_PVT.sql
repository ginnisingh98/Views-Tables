--------------------------------------------------------
--  DDL for Package AHL_UA_UNIT_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_UNIT_SCHEDULES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUUSS.pls 120.0 2005/05/26 01:05:03 appldev noship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_UA_UNIT_SCHEDULES_PVT';

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Unit_Schedules_Search_Rec_Type IS RECORD
(
	UNIT_NAME	VARCHAR2(30),
	ITEM_NUMBER	VARCHAR2(40),
	SERIAL_NUMBER	VARCHAR2(30),
	START_DATE_TIME	DATE,
	TIME_INCREMENT	NUMBER,
	TIME_UOM	VARCHAR2(30)
);

TYPE Unit_Schedules_Result_Rec_Type IS RECORD
(
	RESULT_ROW_NUM		NUMBER,
	RESULT_COL_NUM		NUMBER,
	UNIT_CONFIG_HEADER_ID	NUMBER,
	UNIT_NAME		VARCHAR2(80),
	SCHEDULE_ID		NUMBER,
	SCHEDULE_TYPE		VARCHAR2(2)
);

TYPE Unit_Schedules_Result_Tbl_Type IS TABLE OF Unit_Schedules_Result_Rec_Type INDEX BY BINARY_INTEGER;

TYPE MEvent_Header_Rec_Type IS RECORD
(
	UNIT_CONFIG_HEADER_ID	NUMBER,
	UNIT_NAME		VARCHAR2(30),
	START_TIME		DATE,
	END_TIME		DATE,
	ITEM_NUMBER		VARCHAR2(30),
	SERIAL_NUMBER		VARCHAR2(240),
	EVENT_COUNT		NUMBER,
	HAS_CONFLICT		VARCHAR2(1),
	HAS_MOPPORTUNITY	VARCHAR2(1)
);

TYPE Unit_Schedule_Rec_type IS RECORD
(
	EVENT_SEQ		NUMBER,
	UNIT_SCHEDULE_ID	NUMBER,
	FLIGHT_NUMBER	        VARCHAR2(30),
	SEGMENT	                VARCHAR2(30),
	DEPARTURE_ORG_ID	NUMBER,
	DEPARTURE_ORG_NAME	VARCHAR2(240),
	DEPARTURE_DEP_ID	NUMBER,
	DEPARTURE_DEP_NAME	VARCHAR2(240),
	ARRIVAL_ORG_ID	        NUMBER,
	ARRIVAL_ORG_NAME	VARCHAR2(240),
	ARRIVAL_DEP_ID	        NUMBER,
	ARRIVAL_DEP_NAME	VARCHAR2(240),
	DEPARTURE_TIME	        DATE,
	ARRIVAL_TIME	        DATE,
	PREV_EVENT_TYPE	        VARCHAR2(12),
	PREV_EVENT_ID	        NUMBER,
	PREV_EVENT_ORG_ID	NUMBER,
	IS_PREV_ORG_VALID	VARCHAR2(1),
	PREV_EVENT_ORG_NAME	VARCHAR2(240),
	PREV_EVENT_DEP_ID	NUMBER,
	PRVE_EVENT_DEP_NAME	VARCHAR2(240),
	PREV_EVENT_END_TIME	DATE,
	PREV_UNIT_SCHEDULE_ID	NUMBER,
	PREV_FLIGHT_NUMBER	VARCHAR2(30),
	HAS_MOPPORTUNITY	VARCHAR2(1),
	HAS_CONFLICT	        VARCHAR2(1),
	CONFLICT_MESSAGE	VARCHAR2(2000),
	IS_ORG_VALID	        VARCHAR2(1)
);

TYPE Unit_Schedule_Tbl_Type IS TABLE OF Unit_Schedule_Rec_type INDEX BY BINARY_INTEGER;

TYPE Visit_Schedule_Rec_Type IS RECORD
(
	EVENT_SEQ		NUMBER,
	VISIT_ID		NUMBER,
	VISIT_NUMBER	        VARCHAR2(30),
	VISIT_TYPE		VARCHAR2(30),
	VISIT_NAME		VARCHAR2(80),
	VISIT_STATUS_CODE	VARCHAR2(30),
	VISIT_STATUS	        VARCHAR2(80),
	VISIT_ORG_ID	        NUMBER,
	VISIT_ORG_NAME	        VARCHAR2(240),
	VISIT_DEP_ID	        NUMBER,
	VISIT_DEP_NAME	        VARCHAR2(240),
	START_TIME		DATE,
	END_TIME		DATE,
	PREV_EVENT_TYPE	        VARCHAR2(12),
	PREV_EVENT_ID	        NUMBER,
	PREV_EVENT_ORG_ID	NUMBER,
	IS_PREV_ORG_VALID	VARCHAR2(1),
	PREV_EVENT_ORG_NAME	VARCHAR2(240),
	PREV_EVENT_DEP_ID	NUMBER,
	PRVE_EVENT_DEP_NAME	VARCHAR2(240),
	PREV_EVENT_END_TIME	DATE,
	PREV_UNIT_SCHEDULE_ID	NUMBER,
	PREV_FLIGHT_NUMBER	VARCHAR2(30),
	HAS_MOPPORTUNITY	VARCHAR2(1),
	HAS_CONFLICT	        VARCHAR2(1),
	CONFLICT_MESSAGE	VARCHAR2(2000),
	CAN_CANCEL		VARCHAR2(1),
	IS_ORG_VALID	        VARCHAR2(1)
);

TYPE Visit_Schedule_Tbl_Type IS TABLE OF Visit_Schedule_Rec_type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Search_Unit_Schedules
--  Type        	: Private
--  Function    	: API to perform search on unit schedules and store detailed and return
--			  summary search results. Search results are stored in global temporary
--			  table AHL_SRCH_UNIT_SCHEDULES that can be queried later to retrieve other
--			  relevant details.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Search_Unit_Schedules Parameters :
--	p_unit_schedules_search	IN	Unit_Schedules_Search_Rec_Type 	Required
--	x_unit_schedules_results OUT 	Unit_Schedules_Result_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Search_Unit_Schedules
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_schedules_search	IN		Unit_Schedules_Search_Rec_Type,
	x_unit_schedules_results OUT 	NOCOPY  Unit_Schedules_Result_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name  	: Get_MEvent_Details
--  Type        	: Private
--  Function    	: API to get context information, list of visits, list of flights,
--                    	  conflict and Maintenance Oppurtunity information, conflict messages
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--      p_init_msg_list		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_module_type       	IN      VARCHAR2
--      p_commit		IN      VARCHAR2     	Default FND_API.G_FALSE
--      p_validation_level	IN      NUMBER       	Default FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Get_MEvent_Details Parameters :
--	p_x_ MEvent_header_rec	IN OUT	MEvent_Rec_Type 	Required
--	x_Unit_Schedule_tbl    	OUT 	Unit_Schedules_Tbl_Type
--	x_Visit_Schedule_tbl    OUT 	Visit_Schedules_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_MEvent_Details
(
	p_api_version		IN 		NUMBER,
    	p_module_type		IN      	VARCHAR2,
	x_return_status		OUT	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_x_MEvent_Header_Rec	IN OUT  NOCOPY	MEvent_Header_Rec_Type,
	x_Unit_Schedule_tbl	OUT     NOCOPY 	Unit_Schedule_Tbl_Type,
    	x_Visit_Schedule_tbl	OUT     NOCOPY	Visit_Schedule_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name  	: Get_Prec_Succ_Event_Info
--  Type        	: Private
--  Function    	: API to retrieve previous and next event (flight / visit) information, for a
--			  particular unit configuration for a time period from start time to end time
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Get_MEvent_Details Parameters :
--	p_unit_config_id        IN      NUMBER		Required
--	p_start_date_time       IN      DATE		Required
--	p_end_date_time		IN      DATE		Required
--	p_use_actuals	        IN	VARCHAR2
--	x_prec_visit		OUT     AHL_VWP_VISITS_PVT.Visit_Rec_Type
--	x_prec_flight_schedule	OUT     AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type
--	x_is_prec_conflict    	OUT     VARCHAR2
--	x_succ_visit		OUT     AHL_VWP_VISITS_PVT.Visit_Rec_Type
--	x_succ_flight_schedule	OUT     AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type
--	x_is_succ_conflict	OUT     VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Prec_Succ_Event_Info
(
	p_api_version		IN 		NUMBER,
    	x_return_status		OUT	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id        IN      	NUMBER,
	p_start_date_time	IN      	DATE,
        p_end_date_time		IN      	DATE,
        x_prec_visit		OUT     NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
        x_prec_flight_schedule	OUT     NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
        x_is_prec_conflict    	OUT     NOCOPY  VARCHAR2,
        x_is_prec_org_in_ou	OUT	NOCOPY	VARCHAR2,
        x_succ_visit		OUT     NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
        x_succ_flight_schedule	OUT     NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
        x_is_succ_conflict	OUT     NOCOPY  VARCHAR2,
        x_is_succ_org_in_ou	OUT	NOCOPY	VARCHAR2
);

End AHL_UA_UNIT_SCHEDULES_PVT;

 

/
