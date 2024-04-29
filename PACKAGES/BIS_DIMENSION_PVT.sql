--------------------------------------------------------
--  DDL for Package BIS_DIMENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMENSION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDIMS.pls 120.0 2005/06/01 14:46:54 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDIMS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Dimensions and dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 05-DEC-98 irchen   Creation
REM | 01-FEB-99 ansingha added required dimension api
REM | 04-JAN-03 mahrao   Changed OUT parameter to IN OUT in Valu_Id_Conevrsion
REM |                    as fix for bug 2735908
REM | 23-FEB-2003  PAJOHRI ,    Added procedures    DELETE_DIMENSION        |
REM | 07-JUL-2003 arhegde bug#3028436 Added get_unique_dim_group_name()     |
REM | 09-JUL-2003 arhegde bug#3028436 Moved logic to BSC API from here      |
REM |            Removed get_unique_dim_group_name()                        |
REM | 09-FEB-05   ankgoel Bug#4172055 Dimension name validations            |
REM +=======================================================================+
*/
--
--
Procedure Retrieve_Dimensions
( p_api_version   IN  NUMBER
, x_Dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Dimension
( p_api_version   IN  NUMBER
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Create_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Create_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Update_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Update_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version   IN  NUMBER
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec IN OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version          IN  NUMBER
, p_Dimension_Short_Name IN  VARCHAR2
, p_Dimension_Name       IN  VARCHAR2
, x_Dimension_ID         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
/* modified from ansingha's function */
FUNCTION DuplicateDimension
( p_dimension_rec    BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_dimensions_tbl   BIS_DIMENSION_PUB.Dimension_Tbl_Type
) return BOOLEAN;
--
-- removes the dimensions from p_all_dimension_table
-- which are in p_dimension_table
PROCEDURE RemoveDuplicates
( p_dimension_table     in  BIS_DIMENSION_PUB.Dimension_tbl_type
, p_all_dimension_table in  BIS_DIMENSION_PUB.Dimension_tbl_type
, x_all_dimension_table out NOCOPY BIS_DIMENSION_PUB.Dimension_tbl_type
);
--
PROCEDURE Delete_Dimension
(
        p_commit                IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,   p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--

PROCEDURE Translate_Dim_By_Given_Lang
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);

--

PROCEDURE Validate_PMF_Unique_Name
( p_Dimension_Short_Name  IN  VARCHAR2
, p_Dimension_Name        IN  VARCHAR2
, x_return_status         OUT NOCOPY  VARCHAR2
);

--


END BIS_DIMENSION_PVT;

 

/
