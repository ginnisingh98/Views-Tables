--------------------------------------------------------
--  DDL for Package BIS_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVTARS.pls 115.40 2003/11/15 08:39:20 gbhaloti ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTARS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for creating and managing Targets for the
REM |     Key Performance Framework.
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 02-DEC-98 irchen Creation                                             |
REM | 20-JAN-02 sashaik Added Retrieve_Org_level_value for 1740789	    |
REM | 10-JAN-2003 rchandra for bug 2715432 , changed OUT parameter          |
REM |                       x_Target_Level_Rec , x_Target_Rec to IN OUT     |
REM |                       in API RETRIEVE_TARGET_FROM_SHNMS               |
REM |                       and x_Target_Rec in API Value_ID_Conversion     |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_TARGET_PVT';
G_SET_OF_BOOK_ID NUMBER := NULL;
--
--
TYPE Target_Table_Rec_Type IS RECORD
( Target_ID                     NUMBER
, Target_Level_ID               NUMBER
, Target_Level_Short_Name       VARCHAR2(80)
, Target_Level_Name             VARCHAR2(100)
, Plan_ID                       NUMBER
, Plan_Short_Name               VARCHAR2(80)
, Plan_Name                     VARCHAR2(80)
, Org_Level_Value_ID            VARCHAR2(250)
, Org_Level_Value_Name          VARCHAR2(250)
, Time_Level_Value_ID           VARCHAR2(250)
, Time_Level_Value_Name         VARCHAR2(250)
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
);
--
TYPE Target_Table_Type IS TABLE of Target_Table_Rec_Type
        INDEX BY BINARY_INTEGER;
--
--
--   Defines one target for a specific set of dimension values for
--   one target level
PROCEDURE Create_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --added by gbhaloti #3148615
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
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
--
-- retrieves the owners for one target
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Target_Owners
( p_api_version       IN  NUMBER
, p_Target_Rec        IN  BIS_TARGET_PUB.Target_Rec_Type
, p_all_info          IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Owners_Rec OUT NOCOPY BIS_TARGET_PUB.Target_Owners_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Modifies one target for a specific set of dimension values for
-- one target level
PROCEDURE Update_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --gbhaloti #3148615
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
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
--
-- Validates target record
PROCEDURE Validate_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --added by gbhaloti #3148615
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    IN  OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


PROCEDURE GetID
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_result        OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Retrieve_Measure_Dim_Values
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_User_ID             IN  NUMBER    := NULL
, p_User_Name           IN  VARCHAR2  := NULL
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE GetQueryStatement
( p_select_clause   IN  VARCHAR2
, p_from_clause     IN  VARCHAR2
, p_where_clause    IN  VARCHAR2
, p_order_by_clause IN  VARCHAR2
, x_query_statement OUT NOCOPY VARCHAR2
);
--
--
--
PROCEDURE GetViewNames
( p_target_level_id IN  VARCHAR2
, x_org_view_name  OUT NOCOPY VARCHAR2
, x_time_view_name  OUT NOCOPY VARCHAR2
, x_dim1_view_name  OUT NOCOPY VARCHAR2
, x_dim2_view_name  OUT NOCOPY VARCHAR2
, x_dim3_view_name  OUT NOCOPY VARCHAR2
, x_dim4_view_name  OUT NOCOPY VARCHAR2
, x_dim5_view_name  OUT NOCOPY VARCHAR2
, x_dim6_view_name  OUT NOCOPY VARCHAR2
, x_dim7_view_name  OUT NOCOPY VARCHAR2
);
--
--
--
FUNCTION GetComputingUserFunctionName
( p_computing_function_id IN NUMBER
)
RETURN VARCHAR2;
--
--
FUNCTION GetNotifyResponsibilityName
( p_responsibility_short_name IN VARCHAR2
)
RETURN VARCHAR2;
--
--
FUNCTION GetSetOfBookID
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetSetOfBookID, WNDS);
--
--
FUNCTION Get_Target
( p_computing_function_id  IN NUMBER
, p_target_rec             IN BIS_TARGET_PUB.Target_Rec_Type
)
RETURN NUMBER;
--
--
FUNCTION Get_Target
( p_computing_function_id  IN NUMBER
, p_target_level_id        IN NUMBER
)
RETURN NUMBER;

-- Retrieves the time level values for the given target
--
PROCEDURE Retrieve_Time_level_value
( p_api_version         IN  NUMBER
, p_Target_Rec          IN  BIS_Target_PUB.Target_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level_value
( p_api_version            IN  NUMBER
, p_Target_id              IN  NUMBER
, x_Dim_Level_Value_ID     OUT NOCOPY VARCHAR2
, x_Dim_Level_Value_name   OUT NOCOPY VARCHAR2
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
);

-- Retrieves the Org level values for the given target
--
PROCEDURE Retrieve_Org_level_value
( p_api_version         IN  NUMBER
, p_Target_Rec          IN  BIS_Target_PUB.Target_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

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
--
END BIS_TARGET_PVT;

 

/
