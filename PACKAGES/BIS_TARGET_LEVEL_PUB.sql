--------------------------------------------------------
--  DDL for Package BIS_TARGET_LEVEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_LEVEL_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPTALS.pls 120.0 2005/06/01 18:08:13 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVINLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for creating and managing Indicator Levels
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM |
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for bug 2910316                      |
REM |                      for dimension and dimension levels               |
REM | 30-JUN-03 rchandra Added DATASET_ID as an attribute to                |
REM |                    Target_Level_Rec_Typefor bug 3004651               |
REM | 28-JUN-04 ankgoel  Removed Retrieve_Measure_Notify_Resps for          |
REM |                    bug#3634587                                        |
REM | 21-FEB-2005 ankagarw  modified measure name  and description	    |
REM |			     column length for enh. 3862703                 |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Target_Level_Rec_Type IS RECORD
( Measure_ID                     NUMBER
, Measure_Short_Name             VARCHAR2(30)
, Measure_Name                   bis_indicators_tl.name%TYPE
, Dataset_ID                     bis_indicators.dataset_id%TYPE
, Target_Level_ID             NUMBER
, Target_Level_Short_Name     VARCHAR2(80)
, Target_Level_Name           VARCHAR2(80)
, Description                    VARCHAR2(240)
, Org_Level_ID                   NUMBER
, Org_Level_Short_Name           VARCHAR2(30)
, Org_Level_Name                 bis_levels_tl.name%TYPE
, Time_Level_ID                  NUMBER
, Time_Level_Short_Name          VARCHAR2(30)
, Time_Level_Name                bis_levels_tl.name%TYPE
, Dimension1_Level_ID            NUMBER
, Dimension1_Level_Short_Name    VARCHAR2(30)
, Dimension1_Level_Name          bis_levels_tl.name%TYPE
, Dimension2_Level_ID            NUMBER
, Dimension2_Level_Short_Name    VARCHAR2(30)
, Dimension2_Level_Name          bis_levels_tl.name%TYPE
, Dimension3_Level_ID            NUMBER
, Dimension3_Level_Short_Name    VARCHAR2(30)
, Dimension3_Level_Name          bis_levels_tl.name%TYPE
, Dimension4_Level_ID            NUMBER
, Dimension4_Level_Short_Name    VARCHAR2(30)
, Dimension4_Level_Name          bis_levels_tl.name%TYPE
, Dimension5_Level_ID            NUMBER
, Dimension5_Level_Short_Name    VARCHAR2(30)
, Dimension5_Level_Name          bis_levels_tl.name%TYPE
, Dimension6_Level_ID            NUMBER
, Dimension6_Level_Short_Name    VARCHAR2(30)
, Dimension6_Level_Name          bis_levels_tl.name%TYPE
, Dimension7_Level_ID            NUMBER
, Dimension7_Level_Short_Name    VARCHAR2(30)
, Dimension7_Level_Name          bis_levels_tl.name%TYPE
, Workflow_Process_Short_Name    VARCHAR2(30)
, Workflow_Process_Name          VARCHAR2(4000)
, Workflow_Item_Type             VARCHAR2(8)
, Default_Notify_Resp_ID         NUMBER
, Default_Notify_Resp_short_name VARCHAR2(100)
, Default_Notify_Resp_Name       VARCHAR2(4000)
, Computing_Function_ID          NUMBER
, Computing_Function_Name        VARCHAR2(4000)
, Computing_User_Function_Name   VARCHAR2(4000)
, Report_Function_ID             NUMBER
, Report_Function_Name           VARCHAR2(4000)
, Report_User_Function_Name      VARCHAR2(4000)
, Unit_Of_Measure                VARCHAR(30)
, System_Flag                    VARCHAR2(1)   := 'N'
, Source                         VARCHAR2(30)
, IS_WF_INFO_NEEDED              BOOLEAN       := TRUE -- 2528450
);
--
-- Data Types: Tables
--
TYPE Target_Level_Tbl_Type IS TABLE of Target_Level_Rec_Type
INDEX BY BINARY_INTEGER;
--
-- Global Missing Composite Types
--
G_MISS_IND_LEVEL_REC         Target_Level_Rec_Type;
--
G_MISS_IND_LEVEL_TBL         Target_Level_Tbl_Type;
--
--
-- PROCEDUREs
--
-- creates one Indicator Level
PROCEDURE Create_Target_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Gets All Indicator Levels
-- If information about the dimensions are not required, set all_info to
-- FALSE
PROCEDURE Retrieve_Target_Levels
( p_api_version         IN  NUMBER
, p_all_info            IN  VARCHAR2   := FND_API.G_TRUE
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Target_Level_tbl OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Gets Information for one Indicator Level
-- If information about the dimension are not required, set all_info to FALSE.
PROCEDURE Retrieve_Target_Level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_all_info            IN  VARCHAR2   := FND_API.G_TRUE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Update_Target_Levels
PROCEDURE Update_Target_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- deletes one Target_Level
PROCEDURE Delete_Target_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Target_Level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_User_Target_Levels
( p_api_version      IN NUMBER
, p_user_id          IN NUMBER
, p_user_name        IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR
, p_all_info         IN VARCHAR2 Default FND_API.G_TRUE
, x_Target_Level_Tbl OUT NOCOPY BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
Procedure Translate_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_OWNER             IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Load_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_OWNER             IN  VARCHAR2
, p_up_loaded         IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
FUNCTION Get_Id_From_DimLevelShortNames
( p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER;

-- New Procedure to return TargetLevel given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name

PROCEDURE Retrieve_TL_From_DimLvlShNms
(p_api_version   IN  NUMBER
,p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Given a target level short name update the
--  bis_target_levels, bis_target_levels_tl
-- for last_updated_by , created_by as 1
PROCEDURE updt_tl_attributes(p_tl_short_name  IN VARCHAR2
                       ,p_tl_new_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2);


END BIS_Target_Level_PUB;

 

/
