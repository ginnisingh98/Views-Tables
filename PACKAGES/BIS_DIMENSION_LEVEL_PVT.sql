--------------------------------------------------------
--  DDL for Package BIS_DIMENSION_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMENSION_LEVEL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDMLS.pls 120.1 2005/11/08 02:40:54 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDMLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | 21-OCT-02 arhegde Added retrieve_mult_dim_levels                      |
REM | 23-FEB-2003  PAJOHRI ,    Added procedures    DELETE_DIMENSION_LEVEL  |
REM | 07-NOV-2005  akoduri    Bug#4696105,Added overloaded API              |
REM |                         get_customized_enabled                        |
REM +=======================================================================+
*/
--
--
Procedure Retrieve_Dimension_Levels
( p_api_version         IN  NUMBER
, p_Dimension_Rec       IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Level_Tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Dimension_Level
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec IN OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE retrieve_mult_dim_levels(
  p_api_version        IN NUMBER
 ,p_all_dim_levels_tbl IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_all_dim_levels_tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension_Level
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Dimension_Level_Short_Name IN  VARCHAR2
, p_Dimension_Level_Name       IN  VARCHAR2
, x_Dimension_Level_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Delete_Dimension_Level
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Level_Rec   IN          BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--

PROCEDURE Trans_DimObj_By_Given_Lang
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
,   p_Dimension_Level_Rec   IN          BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- get customized values for name , description and enabled
FUNCTION get_customized_name( p_dim_level_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_customized_description( p_dim_level_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_customized_enabled( p_dim_level_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_customized_enabled( p_dim_level_sht_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE validate_disabling (p_dim_level_id IN NUMBER);

END BIS_DIMENSION_LEVEL_PVT;

 

/
