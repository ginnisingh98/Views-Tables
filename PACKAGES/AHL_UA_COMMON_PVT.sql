--------------------------------------------------------
--  DDL for Package AHL_UA_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UA_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUACS.pls 120.0 2005/05/26 02:00:11 appldev noship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_UA_COMMON_PVT';

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Event_Schedule_Rec_Type IS RECORD
(
	EVENT_ID		NUMBER,
	EVENT_TYPE		VARCHAR2 (10),
	EVENT_START_TIME	DATE,
	EVENT_END_TIME		DATE
);

TYPE Event_Schedule_Tbl_Type IS TABLE OF Event_Schedule_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Get_All_Events
--  Type        	: Private
--  Function    	: API to retrieve all sorted events (sorted on start times) for a particular
--			  unit configuration for a time period from start time to end time.
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
--  Get_All_Events Parameters :
--	p_unit_config_id	IN	NUMBER 		Required
--	p_start_date_time 	IN 	DATE		Required
--	p_end_date_time		IN	DATE		Required
--	p_use_actuals		IN	VARCHAR2
--	x_event_schedules	OUT	Event_Schedule_Tbl_Type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_All_Events
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_event_schedules 	OUT 	NOCOPY  Event_Schedule_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name    	: Get_Prec_Flight_Info
--  Type        	: Private
--  Function    	: API to retrieve previous flight schedule, for a particular unit configuration for
--			  a time period from start time to end time.
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
--  Get_Prec_Flight_Info Parameters :
--	p_unit_config_id	IN	NUMBER 		Required
--	p_start_date_time 	IN 	DATE		Required
--	p_use_actuals		IN	VARCHAR2
--	x_prec_flight_schedule	OUT	AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type
--	x_is_conflict		OUT	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Prec_Flight_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_prec_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name    	: Get_Prec_Visit_Info
--  Type        	: Private
--  Function    	: API to retrieve a previous visit,for a particular unit configuration for
--			  a given start time.
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
--  Get_Prec_Visit_Info Parameters :
--	p_unit_config_id	IN		NUMBER
--      p_start_date_time	IN  		DATE,
--      x_prec_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--	x_is_conflict		OUT 	NOCOPY	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Prec_Visit_Info
(
        p_api_version		IN 		NUMBER,
	x_return_status		OUT 	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
        p_start_date_time	IN  		DATE,
        x_prec_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_is_conflict		OUT 	NOCOPY	VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name    	: Get_Succ_Flight_Info
--  Type        	: Private
--  Function    	: API to retrieve previous flight schedule, for a particular unit configuration for
--			  a time period from start time to end time.
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
--  Get_Succ_Flight_Info Parameters :
--	p_unit_config_id	IN	NUMBER 		Required
--	p_start_date_time 	IN 	DATE		Required
--	p_use_actuals		IN	VARCHAR2
--	x_Succ_flight_schedule	OUT	AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type
--	x_is_conflict		OUT	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Succ_Flight_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_succ_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name    	: Get_Succ_Visit_Info
--  Type        	: Private
--  Function    	: API to retrieve a succeeding visit,for a particular unit configuration for
--			  a given end time.
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
--  Get_Prec_Visit_Info Parameters :
--	p_unit_config_id	IN		NUMBER
--      p_end_date_time  	IN  		DATE,
--      x_succ_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--	x_is_conflict		OUT 	NOCOPY	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Succ_Visit_Info
(
        p_api_version		IN 		NUMBER,
	x_return_status		OUT 	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN  		DATE,
	x_succ_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_is_conflict		OUT 	NOCOPY	VARCHAR2
);
--  Start of Comments  --
--
--  Procedure name    	: Get_Prec_Event_Info
--  Type        	: Private
--  Function    	: API to retrieve the preceding visit or flight schedule, for a particular unit
--			  configuration for a given start time. If there are more than one flight schedule
--			  or visit ending at the same time then a conflict is shown.
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
--  Get_Prec_Event_Info Parameters :
--	p_unit_config_id	IN		NUMBER,
--	p_start_date_time	IN		DATE,
--	p_use_actuals		IN		VARCHAR2,
--	x_prec_visit	 	OUT 	NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--	x_prec_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
--	x_is_conflict		OUT	NOCOPY	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
PROCEDURE Get_Prec_Event_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_prec_visit	 	OUT 	NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_prec_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2,
	x_is_org_in_user_ou     OUT	NOCOPY	VARCHAR2
);

--  Start of Comments  --
--
--  Procedure name    	: Get_Succ_Event_Info
--  Type        	: Private
--  Function    	: API to retrieve the succeeding visit or flight schedule, for a particular unit
--			  configuration for a given end time. If there are more than one flight schedule
--			  or visit ending at the same time then a conflict is shown.
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
--  Get_Prec_Event_Info Parameters :
--	p_unit_config_id	IN		NUMBER,
--	p_end_date_time	IN		DATE,
--	p_use_actuals		IN		VARCHAR2,
--	x_succ_visit	 	OUT 	NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
--	x_succ_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
--	x_is_conflict		OUT	NOCOPY	VARCHAR2
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --

PROCEDURE Get_Succ_Event_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_succ_visit	 	OUT 	NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_succ_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2,
	x_is_org_in_user_ou     OUT	NOCOPY	VARCHAR2
);

End AHL_UA_COMMON_PVT;

 

/
