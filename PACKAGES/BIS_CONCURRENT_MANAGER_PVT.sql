--------------------------------------------------------
--  DDL for Package BIS_CONCURRENT_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CONCURRENT_MANAGER_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCONS.pls 115.19 2003/12/15 14:15:39 arhegde ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCONS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing concurrent requests			    |
REM |									    |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | Jun-2000  irchen  creation					    |
REM | 30-JAN-03 mdamle  SONAR Conversion to Java (APIs called from Java)    |
REM | 21-MAR-2003 sugopal    It should not be able to schedule an alert again
REM |                        when it is running. Added condition to check for
REM |                        the same - bug#2834155
REM | 30-JAN-2003 rchandra refer the new concurrent program                  |
REM |                     BIS_ALERT_SERVICE_PVT_JAVA1 which takes in         |
REM |                     parameters for dimension levels 6 and 7            |
REM |                     though it is being passed from BISVCONB.pls        |
REM | 01-AUG-2003 rchandra refer the old concurrent program                  |
REM |                     BIS_ALERT_SERVICE_PVT_JAVA for bug 2891945         |
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM +=======================================================================+
*/

--
-- Constants
--

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_CONCURRENT_MANAGER_PVT';

G_ALERT_PROGRAM     CONSTANT VARCHAR2(100) := 'BIS_ALERT_SERVICE';
-- mdamle 01/20/2003 - SONAR Conversion to Java - APIs called from Java
G_ALERT_PROGRAM_PVT CONSTANT VARCHAR2(100) := 'BIS_ALERT_SERVICE_PVT_JAVA';

G_CONC_REQUEST_RUNNING CONSTANT VARCHAR2(30) := 'RUNNING';
G_CONC_REQUEST_COMPLETE CONSTANT VARCHAR2(30) := 'COMPLETE';
G_CONC_REQUEST_SCHEDULED CONSTANT VARCHAR2(30) := 'SCHEDULED';
G_CONC_REQUEST_PENDING CONSTANT VARCHAR2(30) := 'PENDING';
G_CONC_REQUEST_NORMAL CONSTANT VARCHAR2(30) := 'NORMAL';
C_ALERT_BASED_ON_TARGET CONSTANT VARCHAR2(10) := '0';
C_ALERT_BASED_ON_CHANGE CONSTANT VARCHAR2(10) := '1';

TYPE PMF_Request_Rec_Type IS RECORD
( application_short_name VARCHAR2(240)
, program	VARCHAR2(240)
, description	VARCHAR2(240)
, start_time	VARCHAR2(240)
, argument1	NUMBER             -- measure_id
, argument2	VARCHAR2(240) 	  -- measure_short_name
, argument3	NUMBER             -- target_level_id
, argument4	VARCHAR2(240)      -- target_level_short_name
, argument5	NUMBER        	  -- plan_id
, argument6	NUMBER        	  -- org_level_id
, argument7	VARCHAR2(240) 	  -- org_level_short_name
, argument8	VARCHAR2(240) 	  -- organization_id
, argument9	NUMBER        	  -- time_level_id
, argument10	VARCHAR2(240) 	  -- time_level_short_name
, argument11	VARCHAR2(240) 	  -- time_level_value_id
, argument12	NUMBER        	  -- dim1_level_id
, argument13	VARCHAR2(240) 	  -- dim1_level_short_name
, argument14	VARCHAR2(240) 	  -- dim1_level_value_id
, argument15	NUMBER        	  -- dim2_level_id
, argument16	VARCHAR2(240) 	  -- dim2_level_short_name
, argument17	VARCHAR2(240) 	  -- dim2_level_value_id
, argument18	NUMBER        	  -- dim3_level_id
, argument19	VARCHAR2(240) 	  -- dim3_level_short_name
, argument20	VARCHAR2(240) 	  -- dim3_level_value_id
, argument21	NUMBER        	  -- dim4_level_id
, argument22	VARCHAR2(240) 	  -- dim4_level_short_name
, argument23	VARCHAR2(240) 	  -- dim4_level_value_id
, argument24	NUMBER        	  -- dim5_level_id
, argument25	VARCHAR2(240) 	  -- dim5_level_short_name
, argument26	VARCHAR2(240) 	  -- dim5_level_value_id
, argument27	NUMBER             -- dim6_level_id
, argument28	VARCHAR2(240)      -- dim6_level_short_name
, argument29	VARCHAR2(240)      -- dim6_level_value_id
, argument30	NUMBER             -- dim7_level_id
, argument31	VARCHAR2(240) 	  -- dim7_level_short_name
, argument32	VARCHAR2(240) 	  -- dim7_level_value_id
, argument33	NUMBER         	  -- target_id
, argument34	NUMBER        	  -- target
, argument35	NUMBER        	  -- actual_id
, argument36	NUMBER        	  -- actual
, argument37	NUMBER        	  -- primary_dim_level_id
, argument38	VARCHAR2(240) 	  -- primary_dim_level_short_name
, argument39	VARCHAR2(240) 	  -- notify_set
, argument40	VARCHAR2(240) 	  -- alert_type
, argument41	VARCHAR2(240) 	  -- alert_level
, argument42	VARCHAR2(240) 	  -- p_current_row
, argument43	VARCHAR2(240)
, argument44	VARCHAR2(240)
, argument45	VARCHAR2(240)
, argument46	VARCHAR2(240)
, argument47	VARCHAR2(240)
, argument48	VARCHAR2(240)
, argument49	VARCHAR2(240)
, argument50	VARCHAR2(240)
, argument51	VARCHAR2(240)
, argument52	VARCHAR2(240)
, argument53	VARCHAR2(240)
, argument54	VARCHAR2(240)
, argument55	VARCHAR2(240)
, argument56	VARCHAR2(240)
, argument57	VARCHAR2(240)
, argument58	VARCHAR2(240)
, argument59	VARCHAR2(240)
, argument60	VARCHAR2(240)
);

TYPE PMF_Request_Tbl_Type IS TABLE OF
  PMF_Request_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Fnd_Concurrent_Requests_Tbl IS TABLE OF Fnd_Concurrent_Requests%ROWTYPE
  INDEX BY BINARY_INTEGER;

--
-- FUNCTIONS
--

FUNCTION Get_Freq_Display_Unit(p_freq_unit_code IN VARCHAR2) RETURN VARCHAR2;

--
-- PROCEDURES
--

--
-- Checks if request is scheduled to run again.  If not, the request
-- is deleted from the Registration table and the ad hoc workflow role
-- is removed.
--
PROCEDURE Manage_Alert_Registrations
( p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Submits the PMF concurrent requests
--
Procedure Submit_Concurrent_Request
( p_Concurrent_Request_Tbl	IN PMF_Request_Tbl_Type
, x_request_id_tbl              OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_errbuf                      OUT NOCOPY VARCHAR2
, x_retcode                     OUT NOCOPY VARCHAR2
);

Procedure Submit_Concurrent_Request
( p_Concurrent_Request_rec IN PMF_Request_rec_Type
, x_request_id             OUT NOCOPY VARCHAR2
, x_errbuf                 OUT NOCOPY VARCHAR2
, x_retcode                OUT NOCOPY VARCHAR2
);

--
-- Retrieves the concurrent requests for this parameter set
--
PROCEDURE Get_All_Requests
( p_Param_Set_rec             IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_Concurrent_Request_tbl    OUT NOCOPY Fnd_Concurrent_Requests_Tbl
, x_return_status             OUT NOCOPY VARCHAR2
);

--
-- Retrieves the scheduling information for this alert
--
Procedure Get_Request_Schedule_Info
( p_Param_Set_rec         IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_schedule_freq_unit    OUT NOCOPY VARCHAR2
, x_schedule_end_date     OUT NOCOPY VARCHAR2
, x_schedule_end_time     OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
);

Procedure Get_Request_Schedule_Info
( p_measure_id            IN VARCHAR2 := NULL
, p_target_level_id       IN VARCHAR2 := NULL
, p_time_level_id         IN VARCHAR2 := NULL
, p_plan_id               IN VARCHAR2 := NULL
, p_parameter1_value      IN VARCHAR2 := NULL
, p_parameter2_value      IN VARCHAR2 := NULL
, p_parameter3_value      IN VARCHAR2 := NULL
, p_parameter4_value      IN VARCHAR2 := NULL
, p_parameter5_value      IN VARCHAR2 := NULL
, p_parameter6_value      IN VARCHAR2 := NULL
, p_parameter7_value      IN VARCHAR2 := NULL
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_schedule_freq_unit    OUT NOCOPY VARCHAR2
, x_schedule_end_date     OUT NOCOPY VARCHAR2
, x_schedule_end_time     OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
);

Procedure Format_Schedule_Freq_Unit
( p_schedule_unit     IN VARCHAR2
, p_schedule_freq     IN VARCHAR2
, x_schedule_freq_unit OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Repeat_Options
( p_repeat_interval    IN VARCHAR2
, p_repeat_units       IN VARCHAR2
, P_Start_time         IN VARCHAR2
, P_end_time           IN VARCHAR2
, x_result             OUT NOCOPY VARCHAR2
);

Procedure Get_PMF_Concurrent_Program_ID
( p_main_request_flag      IN VARCHAR2 := FND_API.G_FALSE
, x_Concurrent_Program_ID  OUT NOCOPY NUMBER
, x_Application_ID         OUT NOCOPY NUMBER
);


END BIS_CONCURRENT_MANAGER_PVT;

 

/
