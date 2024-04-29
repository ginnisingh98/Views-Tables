--------------------------------------------------------
--  DDL for Package BIS_PMF_DATA_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_DATA_SOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDSCS.pls 115.15 2003/01/30 09:10:22 sugopal ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDSCS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Data Source Connector
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM +=======================================================================+
*/
--
-- Procedures
--
Procedure Form_Target_Level_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_target_level_rec OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
);

Procedure Form_Target_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_target_rec      OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
);

Procedure Form_Actual_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_actual_rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
);

Procedure Form_Measure_Instance
( p_Measure_ID              IN NUMBER := NULL
, p_Target_Level_ID         IN NUMBER := NULL
, p_Plan_ID                 IN NUMBER := NULL
, p_Actual_ID               IN NUMBER := NULL
, p_Target_ID               IN NUMBER := NULL
, x_Measure_instance        OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
);

Procedure Form_dim_level_value_tbl
( p_Dimension1_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension1_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension2_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension2_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension3_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension3_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension4_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension4_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension5_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension5_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension6_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension6_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension7_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension7_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, x_dim_level_value_tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
);

-- For enhencement #1270297, 1270301.
--
/*
Procedure Form_Notifier_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, P_notify_set	   IN VARCHAR2 := NULL
, p_alert_type	   IN VARCHAR2 := BIS_ALERT_SERVICE_PUB.G_ALERT_TYPE_EXCEPTION
, p_alert_level	   IN VARCHAR2 := BIS_ALERT_SERVICE_PUB.G_ALERT_LEVEL_PUBLIC
, x_notifier_rec   OUT NOCOPY BIS_NOTIFICATION_PUB.Notifier_Rec_Type
);
*/

Procedure Sync_Target_Measure_Owners
( p_measure_instance     IN BIS_MEASURE_PUB.Measure_Instance_type
, p_Target_owners_rec    IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, x_measure_instance     IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
);

END BIS_PMF_DATA_SOURCE_PVT;

 

/
