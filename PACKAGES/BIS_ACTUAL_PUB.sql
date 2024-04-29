--------------------------------------------------------
--  DDL for Package BIS_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ACTUAL_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPACVS.pls 115.19 2002/12/20 11:25:53 mahrao ship $ */


TYPE Actual_Rec_Type IS RECORD
(  Actual_ID                        NUMBER
  ,Target_Level_ID                  NUMBER
  ,Target_Level_Name                VARCHAR2(100)
  ,Target_Level_Short_Name          VARCHAR2(80)
  ,Org_Level_value_ID               VARCHAR2(250)
  ,Org_Level_value_Name             VARCHAR2(250)
  ,Time_Level_Value_ID              VARCHAR2(250)
  ,Time_Level_Value_Name            VARCHAR2(250)
  ,Dim1_Level_Value_ID              VARCHAR2(250)
  ,Dim1_Level_Value_Name            VARCHAR2(250)
  ,Dim2_Level_Value_ID              VARCHAR2(250)
  ,Dim2_Level_Value_Name            VARCHAR2(250)
  ,Dim3_Level_Value_ID              VARCHAR2(250)
  ,Dim3_Level_Value_Name            VARCHAR2(250)
  ,Dim4_Level_Value_ID              VARCHAR2(250)
  ,Dim4_Level_Value_Name            VARCHAR2(250)
  ,Dim5_Level_Value_ID              VARCHAR2(250)
  ,Dim5_Level_Value_Name            VARCHAR2(250)
  ,Dim6_level_Value_id		    VARCHAR2(250)
  ,Dim6_Level_Value_Name	    VARCHAR2(250)
  ,Dim7_Level_Value_ID              VARCHAR2(250)
  ,Dim7_Level_Value_Name	    VARCHAR2(250)
  ,Responsibility_ID                NUMBER
  ,Responsibility_Short_Name        VARCHAR2(100)
  ,Responsibility_Name              VARCHAR2(240)
  ,Actual                           NUMBER
  ,Report_Url                       VARCHAR2(2000) -- 1-1enh
  ,Comparison_actual_value          NUMBER         -- 1-1enh
);

/*
TYPE Actual_Rec_Type IS RECORD
(  Target_Level_ID               NUMBER        := FND_API.G_MISS_NUM
  ,Target_Level_Name             VARCHAR2(100) := FND_API.G_MISS_CHAR
  ,Target_Level_Short_Name       VARCHAR2(80)  := FND_API.G_MISS_CHAR
  ,Dim1_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim1_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim2_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim2_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim3_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim3_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim4_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim4_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim5_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim5_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim6_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim6_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim7_Level_Value_ID              VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Dim7_Level_Value_Name            VARCHAR2(250) := FND_API.G_MISS_CHAR
  ,Responsibility_ID                NUMBER        := FND_API.G_MISS_NUM
  ,Responsibility_Short_Name        VARCHAR2(100) := FND_API.G_MISS_CHAR
  ,Responsibility_Name              VARCHAR2(240) := FND_API.G_MISS_CHAR
  ,Actual                           NUMBER        := FND_API.G_MISS_NUM
);
*/

TYPE Actual_Tbl_Type IS TABLE OF Actual_Rec_Type
  INDEX BY BINARY_INTEGER;


-- Retrieves the KPIs users have selected to monitor on the personal homepage
-- or in the summary report.  This should be called before calling Post_Actual.
PROCEDURE Retrieve_User_Selections
(  p_api_version                  IN NUMBER
  ,p_Target_Level_Rec
     IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
     OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Posts actual value into BIS table.
PROCEDURE Post_Actual
(  p_api_version       IN NUMBER
  ,p_init_msg_list     IN VARCHAR2   Default FND_API.G_FALSE
  ,p_commit            IN VARCHAR2   Default FND_API.G_FALSE
  ,p_validation_level  IN NUMBER     Default FND_API.G_VALID_LEVEL_FULL
  ,p_Actual_Rec        IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- Retrieves actual value for the specified set of dimension values
-- i.e. for a specific organization, time period, etc.
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Actual
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER  Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Retrieves all actual values for the specified Indicator Level
-- i.e. all organizations, all time periods, etc.
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Actuals
(  p_api_version         IN NUMBER
  ,p_init_msg_list       IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level    IN NUMBER  Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info            IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl          OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Retrieves the most current actual value for the specified set
-- of dimension values. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actual
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


-- Retrieves the most current actual values for the specified Indicator Level
-- i.e. for all organizations, etc. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actuals
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


PROCEDURE Validate_Actual
(  p_api_version          IN NUMBER
 , p_init_msg_list        IN VARCHAR2 Default FND_API.G_FALSE
 , p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
 , p_event                IN VARCHAR2
 , p_user_id              IN NUMBER
 , p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
 , x_return_status        OUT NOCOPY VARCHAR2
 , x_msg_count            OUT NOCOPY NUMBER
 , x_msg_data             OUT NOCOPY VARCHAR2
 ,x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


END BIS_ACTUAL_PUB;

 

/
