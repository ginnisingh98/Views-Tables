--------------------------------------------------------
--  DDL for Package BIS_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ACTUAL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVACVS.pls 115.14 2002/12/16 10:24:16 rchandra ship $ */

-- Retrieves the KPIs users have selected to monitor on the personal homepage
-- or in the summary report.  This should be called before calling Post_Actual.
PROCEDURE Retrieve_User_Selections
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN  VARCHAR2   := FND_API.G_TRUE
  ,p_Target_Level_Rec
     IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
     OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves all the records in bis_user_ind_selections for the
-- given target_level

PROCEDURE Retrieve_tl_selections
(  p_Target_Level_Rec
            IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
            OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Posts actual value into BIS table.
PROCEDURE Post_Actual
(  p_api_version       IN NUMBER
  ,p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
  ,p_commit            IN VARCHAR2   Default FND_API.G_FALSE
  ,p_Actual_Rec        IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves actual value for the specified set of dimension values
-- i.e. for a specific organization, time period, etc.
--
-- If information about dimension values are not required, set all_info
-- to FALSE.
--
PROCEDURE Retrieve_Actual
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves all actual values for the specified Indicator Level
-- i.e. all organizations, all time periods, etc.
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Actuals
(  p_api_version         IN NUMBER
  ,p_all_info            IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl          OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Retrieves the most current actual value for the specified set
-- of dimension values. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actual
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Retrieves the most current actual values for the specified Indicator Level
-- i.e. for all organizations, etc. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actuals
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec             IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Validate_Actual
(  p_api_version          IN NUMBER
 , p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
 , p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
 , x_return_status        OUT NOCOPY VARCHAR2
 , x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Validate_Required_Fields
( p_api_version          IN NUMBER
, p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
, p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


PROCEDURE Validate_Dimension_Values
( p_api_version          IN NUMBER
, p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
, p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Actual_Rec IN   BIS_ACTUAL_PUB.Actual_Rec_Type
, x_Actual_Rec OUT NOCOPY  BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

END BIS_ACTUAL_PVT;

 

/
