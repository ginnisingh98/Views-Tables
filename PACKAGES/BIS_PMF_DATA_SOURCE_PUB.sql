--------------------------------------------------------
--  DDL for Package BIS_PMF_DATA_SOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_DATA_SOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPDSCS.pls 115.16 2003/02/21 19:18:50 mdamle ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDSCS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for the Data Source Connector			    |
REM |									    |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | APR-2000  irchen  Creation					    |
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 30-JAN-03 mdamle  SONAR Conversion to Java (APIs called from Java)    |
REM +=======================================================================+
*/
--
-- Constants
--


--
-- Procedures
--
Procedure Retrieve_Target_Level
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_target_level_rec OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
);

Procedure Retrieve_Target
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_target_rec      OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
);

Procedure Retrieve_Target_Owners
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	    IN VARCHAR2 := NULL
, p_alert_level	    IN VARCHAR2 := NULL
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_Target_owners_rec OUT NOCOPY BIS_TARGET_PUB.Target_Owners_Rec_Type
);

Procedure Retrieve_Actual
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_actual_rec      OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
);

Procedure Retrieve_Actual
( p_Measure_ID              IN NUMBER := NULL
, p_Target_Level_ID         IN NUMBER := NULL
, p_Plan_ID                 IN NUMBER := NULL
, p_Actual_ID               IN NUMBER := NULL
, p_Target_ID               IN NUMBER := NULL
, p_Dimension1_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
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
, x_actual_value            OUT NOCOPY NUMBER
);

-- mdamle 01/20/2003 - SONAR Conversion to Java
Procedure Retrieve_Target
( p_measure_id				IN NUMBER := NULL
, p_target_level_id			IN NUMBER
, p_plan_id				IN NUMBER := NULL
, p_dim1_level_value_id	 		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, x_target_id				OUT NOCOPY NUMBER
, x_target				OUT NOCOPY NUMBER
, x_range1_low				OUT NOCOPY NUMBER
, x_range1_high				OUT NOCOPY NUMBER
, x_range2_low				OUT NOCOPY NUMBER
, x_range2_high				OUT NOCOPY NUMBER
, x_range3_low				OUT NOCOPY NUMBER
, x_range3_high				OUT NOCOPY NUMBER
, x_notify_resp1_id			OUT NOCOPY NUMBER
, x_notify_resp1_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp1_name             	OUT NOCOPY VARCHAR2
, x_notify_resp2_id			OUT NOCOPY NUMBER
, x_notify_resp2_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp2_name             	OUT NOCOPY VARCHAR2
, x_notify_resp3_id			OUT NOCOPY NUMBER
, x_notify_resp3_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp3_name             	OUT NOCOPY VARCHAR2
, x_return_status    			OUT NOCOPY VARCHAR2
);

-- mdamle 01/20/2003 - SONAR Conversion to Java - APIs called from Java
PROCEDURE Post_Actual
(  p_Target_Level_ID		IN NUMBER
  ,p_Target_Level_Name          IN VARCHAR2
  ,p_Target_Level_Short_Name    IN VARCHAR2
  ,p_Dim1_Level_Value_ID        IN VARCHAR2
  ,p_Dim1_Level_Value_Name      IN VARCHAR2
  ,p_Dim2_Level_Value_ID        IN VARCHAR2
  ,p_Dim2_Level_Value_Name      IN VARCHAR2
  ,p_Dim3_Level_Value_ID        IN VARCHAR2
  ,p_Dim3_Level_Value_Name      IN VARCHAR2
  ,p_Dim4_Level_Value_ID        IN VARCHAR2
  ,p_Dim4_Level_Value_Name      IN VARCHAR2
  ,p_Dim5_Level_Value_ID        IN VARCHAR2
  ,p_Dim5_Level_Value_Name      IN VARCHAR2
  ,p_Dim6_level_Value_id	IN VARCHAR2
  ,p_Dim6_Level_Value_Name	IN VARCHAR2
  ,p_Dim7_Level_Value_ID        IN VARCHAR2
  ,p_Dim7_Level_Value_Name	IN VARCHAR2
  ,p_Actual                     IN NUMBER
  ,p_Report_Url                 IN VARCHAR2
  ,p_Comparison_actual_value    IN NUMBER
  ,x_return_status     		OUT NOCOPY VARCHAR2
);

END BIS_PMF_DATA_SOURCE_PUB;

 

/
