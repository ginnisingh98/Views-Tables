--------------------------------------------------------
--  DDL for Package BIS_TARGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPTARS.pls 115.30 2003/12/15 14:14:36 arhegde ship $ */
--
/*
REM dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
REM dbdrv: checkfile:~PROD:~PATH:~FILE
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPTARS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Targets for the
REM |     Key Performance Framework.
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 02-DEC-98 irchen Creation
REM | 10-JAN-2003 rchandra for bug 2715432 , changed OUT parameter          |
REM |                       x_Target_Level_Rec , x_Target_Rec to IN OUT     |
REM |                       in API RETRIEVE_TARGET_FROM_SHNMS               |
REM |
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_TARGET_PUB';
G_IS_PM_REGION CONSTANT VARCHAR2(10) := '1';
--
TYPE Target_Rec_Type IS RECORD
( Target_ID                     NUMBER
, Target_Level_ID               NUMBER
, Target_Level_Short_Name       VARCHAR2(80)
, Target_Level_Name             VARCHAR2(100)
, Plan_ID                       NUMBER
, Plan_Short_Name               VARCHAR2(80)
, Plan_Name                     VARCHAR2(80)
, Org_level_value_id            VARCHAR2(250)
, Org_level_value_name          VARCHAR2(250)
, Time_level_Value_id           VARCHAR2(250)
, Time_level_Value_name         VARCHAR2(250)
, Dim1_Level_Value_ID           VARCHAR2(250)
, Dim1_Level_Value_Name         VARCHAR2(250)
, Dim2_Level_Value_ID           VARCHAR2(250)
, Dim2_Level_Value_Name         VARCHAR2(250)
, Dim3_Level_Value_ID           VARCHAR2(250)
, Dim3_Level_Value_Name         VARCHAR2(250)
, Dim4_Level_Value_ID           VARCHAR2(250)
, Dim4_Level_Value_Name         VARCHAR2(250)
, Dim5_Level_Value_ID           VARCHAR2(250)
, Dim5_Level_Value_Name         VARCHAR2(250)
, Dim6_Level_Value_ID           VARCHAR2(250)
, Dim6_Level_Value_Name         VARCHAR2(250)
, Dim7_Level_Value_ID           VARCHAR2(250)
, Dim7_Level_Value_Name         VARCHAR2(250)
, Target                        NUMBER
, Range1_low                    NUMBER
, Range1_high                   NUMBER
, Range2_low                    NUMBER
, Range2_high                   NUMBER
, Range3_low                    NUMBER
, Range3_high                   NUMBER
, Notify_Resp1_ID               NUMBER
, Notify_Resp1_Short_Name       VARCHAR2(100)
, Notify_Resp1_Name             VARCHAR2(240)
, Notify_Resp2_ID               NUMBER
, Notify_Resp2_Short_Name       VARCHAR2(100)
, Notify_Resp2_Name             VARCHAR2(240)
, Notify_Resp3_ID               NUMBER
, Notify_Resp3_Short_Name       VARCHAR2(100)
, Notify_Resp3_Name             VARCHAR2(240)
, Is_Pm_Region                  VARCHAR2(10)
);
--

TYPE Target_Owners_Rec_Type IS RECORD
( Range1_Owner_ID               NUMBER
, Range1_Owner_Short_Name       VARCHAR2(100)
, Range1_Owner_Name             VARCHAR2(240)
, Range2_Owner_ID               NUMBER
, Range2_Owner_Short_Name       VARCHAR2(100)
, Range2_Owner_Name             VARCHAR2(240)
, Range3_Owner_ID               NUMBER
, Range3_Owner_Short_Name       VARCHAR2(100)
, Range3_Owner_Name             VARCHAR2(240)
);

TYPE Target_Tbl_Type IS TABLE of Target_Rec_Type
        INDEX BY BINARY_INTEGER;
--
-- VALID RANGES FOR TARGETS
G_EXCEPTION_RANGE1        NUMBER := 1;
G_EXCEPTION_RANGE2        NUMBER := 2;
G_EXCEPTION_RANGE3        NUMBER := 3;
--
G_MISS_TARGET_REC         Target_Rec_Type;
--
G_MISS_TARGET_TBL         Target_Tbl_Type;
--
--
--   Defines one target for a specific set of dimension values for
--   one target level
PROCEDURE Create_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- retrieve information for all targets of the given target level
-- if information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Targets
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_all_info         IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Tbl       OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- retrieve information for one target
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Target
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, p_all_info      IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Modifies one target for a specific set of dimension values for
-- one target level
PROCEDURE Update_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Deletes one target for a specific set of dimension values for
-- one target level
PROCEDURE Delete_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates target record
PROCEDURE Validate_Target
( p_api_version     IN  NUMBER
, p_Target_Rec      IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--

-- New Procedure to return TargetLevel and Target given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name
PROCEDURE Retrieve_Target_From_ShNms
( p_api_version      IN  NUMBER
, p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_Target_Rec      IN BIS_TARGET_PUB.TARGET_REC_TYPE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Rec       IN OUT NOCOPY BIS_TARGET_PUB.TARGET_REC_TYPE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) ;
--
END BIS_TARGET_PUB;

 

/
