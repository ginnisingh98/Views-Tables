--------------------------------------------------------
--  DDL for Package BIS_TARGET_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_LEVEL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVTALS.pls 120.0 2005/06/01 17:29:07 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTALS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for creating and managing Indicator Levels
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 20-MAY-00 jradhakr Added the Function Get_Level_Id_From_Dimlevels
REM |                    to the specifications
REM | 23-JAN-02 sashaik Added Retrieve_Org_level procedure for 1740789
REM | 29-SEP-02 arhegde bug#2528442 - added retrieve_mult_targ_levels()     |
REM | 09-OCT-02 arhegde Modified for bug#2616667			    |
REM | 21-OCT-04 arhegde bug# 3634587 The SQL used shows up on performance   |
REM | repository top-20, Removed Retrieve_Measure_Notify_Resps()            |
REM |
REM +=======================================================================+
*/

--
-- PROCEDUREs
--
-- creates one Indicator Level
PROCEDURE Create_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- creates one Indicator Level for the given owner
PROCEDURE Create_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Gets All Indicator Levels
-- If information about the dimensions are not required, set all_info to
-- FALSE
PROCEDURE Count_Target_Levels
( p_api_version         IN  NUMBER
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_count               OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
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
-- Retrieves target level records into table given
-- multiple target level short names.
-- This is used in KPI portlet as of now to retrieve
-- details of all required target level short names with one call.
--
PROCEDURE retrieve_mult_targ_levels(
  p_api_version IN NUMBER
 ,p_target_level_tbl IN BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type
 ,p_all_info IN VARCHAR2 := FND_API.G_TRUE
 ,x_target_level_tbl OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
--
-- Update_Target_Levels
PROCEDURE Update_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Update_Target_Levels for the given owner
PROCEDURE Update_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_owner            IN  VARCHAR2
, p_up_loaded        IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- deletes one Target_Level
PROCEDURE Delete_Target_Level
( p_api_version         IN  NUMBER
, p_force_delete        IN  NUMBER := 0--gbhaloti #3148615
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
Procedure Translate_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_owner             IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Target_Level
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version         IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Target_Level_Short_Name IN  VARCHAR2
, p_Target_Level_Name       IN  VARCHAR2
, x_Target_Level_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_User_Target_Levels
( p_api_version      IN NUMBER
, p_user_id          IN NUMBER
, p_all_info         IN VARCHAR2 Default FND_API.G_TRUE
, x_Target_Level_Tbl OUT NOCOPY BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

/* Retrive available notification responsibilities for this user */
/* The SQL used shows up on performance repository top-20
 bug# 3634587 - This API is not used anymore. Procedure Retrieve_Measure_Notify_Resps
( p_api_version       IN NUMBER
, p_user_id           IN NUMBER
, p_Target_Level_Rec  IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_notify_resp_tbl   OUT NOCOPY BIS_RESPONSIBILITY_PVT.Notify_Responsibility_Tbl_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
*/
--
--
PROCEDURE Lock_Record
( p_api_version        IN  NUMBER
, p_Target_Level_Rec   IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_timestamp          IN  VARCHAR  := NULL
, x_return_status      OUT NOCOPY VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
FUNCTION Get_Level_Id_From_Dimlevels
( p_tl_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER;


-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level
( p_api_version                IN  NUMBER
, p_Target_Level_id            IN  NUMBER
, x_Dimension_Level_id         OUT NOCOPY NUMBER
, x_Dimension_Level_short_Name OUT NOCOPY NUMBER
, x_Dimension_Level_name       OUT NOCOPY NUMBER
, x_dimension_level_number     OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
);


--
-- Retrieves the Org level for the given target level
--
PROCEDURE Retrieve_Org_level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- New Function to return TargetLevelId given the DimensionLevel ShortNames
-- and the Measure Short Name
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

PROCEDURE Validate_Dimensions -- 2486702
(
  p_target_level_rec 	IN  BIS_Target_Level_PUB.Target_Level_Rec_Type,
  x_return_status 	OUT NOCOPY VARCHAR2,
  x_return_msg 		OUT NOCOPY VARCHAR2
);

END BIS_Target_Level_PVT;

 

/
