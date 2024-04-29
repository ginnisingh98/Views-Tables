--------------------------------------------------------
--  DDL for Package BIS_CORRECTIVE_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CORRECTIVE_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCACS.pls 115.26 2004/01/15 22:36:46 jxyu ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCACS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Data Source Connector
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM |     NOV-15   sashaik  Unsubscribe alerts 1898436
REM |     09-APR-2003 smuruges Bug# 2871017.                                |
REM |                          Created a new procedure GenerateAlerts       |
REM |                          This API would be invoked by the workflow    |
REM |                          NOTIFICATION engine to generate html/text    |
REM |                          documents for sending alerts.                |
REM |     05-JUL-2003  rchandra removed proc isTargetOwner for bug 2929282  |
REM |	  14-NOV-2003  ankgoel	Modified for bug# 3153918		    |
REM |     14-Jan-2004  jxyu     Modified for bug#3374352                    |
REM +=======================================================================+
*/

--
-- Procedures
--

-- Starts the corrective action workflow
--
Procedure Start_Corrective_Action
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result    IN VARCHAR2
);

Procedure Send_Alert
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_comparison_result     IN VARCHAR2
);


-- Used by generate the notification text
--
Procedure Generate_Alert_Message
( document_id    IN VARCHAR2
, display_type   IN VARCHAR2
, document       IN OUT NOCOPY VARCHAR2
, document_type  IN OUT NOCOPY VARCHAR2
);

-- Retrieves the alert request information for this notification
--
Procedure Get_Request_Info
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
);


PROCEDURE unsub_launch_jsp -- 1898436
( pMeasureId        IN VARCHAR2 := NULL
, pTargetLevelId    IN VARCHAR2 := NULL
, pTargetId         IN VARCHAR2 := NULL
, pTimeDimensionLevelId IN VARCHAR2 := NULL
, pPlanId           IN VARCHAR2 := NULL
, pNotifiersCode    IN VARCHAR2 := NULL
, pParameter1Value  IN VARCHAR2 := NULL
, pParameter2Value  IN VARCHAR2 := NULL
, pParameter3Value  IN VARCHAR2 := NULL
, pParameter4Value  IN VARCHAR2 := NULL
, pParameter5Value  IN VARCHAR2 := NULL
, pParameter6Value  IN VARCHAR2 := NULL
, pParameter7Value  IN VARCHAR2 := NULL
);


PROCEDURE unSubscribeFromAlerts  -- 1898436
    (p_measure_Id              IN  VARCHAR2 := NULL
    ,p_target_Level_Id         IN  VARCHAR2 := NULL
    ,p_time_Dimension_Level_Id IN  VARCHAR2 := NULL
    ,p_plan_Id                 IN  VARCHAR2 := NULL
    ,p_notifiers_Code          IN  VARCHAR2 := NULL
    ,p_parameter1_Value        IN  VARCHAR2 := NULL
    ,p_parameter2_Value        IN  VARCHAR2 := NULL
    ,p_parameter3_Value        IN  VARCHAR2 := NULL
    ,p_parameter4_Value        IN  VARCHAR2 := NULL
    ,p_parameter5_Value        IN  VARCHAR2 := NULL
    ,p_parameter6_Value        IN  VARCHAR2 := NULL
    ,p_parameter7_Value        IN  VARCHAR2 := NULL
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
);

PROCEDURE GenerateAlerts
   ( document_id    IN  VARCHAR2,
     content_type   IN  VARCHAR2,
     document       IN OUT NOCOPY CLOB,
     document_type  IN OUT NOCOPY VARCHAR2);

PROCEDURE Generate_Report
   ( document_id    IN  VARCHAR2,
     content_type   IN  VARCHAR2,
     document       IN OUT NOCOPY CLOB,
     document_type  IN OUT NOCOPY VARCHAR2);

FUNCTION Adjust_Datetime
( p_date_time     IN  DATE
, p_from_tz       IN VARCHAR2
, p_to_tz         IN VARCHAR2
) RETURN DATE;

END BIS_CORRECTIVE_ACTION_PVT;

 

/
