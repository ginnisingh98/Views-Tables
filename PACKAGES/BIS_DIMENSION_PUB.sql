--------------------------------------------------------
--  DDL for Package BIS_DIMENSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMENSION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPDIMS.pls 120.1 2006/01/06 03:20:44 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDIMS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing Dimensions and dimension levels for the
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
REM | 20-FEB-03 PAJOHRI  Added Procedure  UPDATE_DIMENSION                  |
REM | 23-FEB-03 PAJOHRI  Added Procedures DELETE_DIMENSION                  |
REM |                                     CREATE_DIMENSION                  |
REM | 13-JUN-03 MAHRAO  Added Procedure   Load_Dimension_Group              |
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for enh 2910316                      |
REM |                      for dimension and dimension levels               |
REM | 11-JUL-03 MAHRAO Modified the record type, to handle dim_grp_ID       |
REM |                         which is added into the bis_dimensions        |
REM | 29-SEP-04 ankgoel Added WHO columns in Rec for Bug#3891748            |
REM | 21-DEC-04 vtulasi   Modified for bug#4045278 - Addtion of LUD         |
REM | 08-Feb-05 ankgoel   Enh#4172034 DD Seeding by Product Teams           |
REM | 06-Jan-06 akoduri   Enh#4739401 - Hide Dimensions/Dim Objects         |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Dimension_Rec_Type IS RECORD
( Dimension_ID         NUMBER
, Dimension_Short_Name VARCHAR2(30)
, Dimension_Name       bis_dimensions_tl.name%TYPE
, Description          bis_dimensions_tl.description%TYPE
, Application_ID       BIS_DIMENSIONS.Application_Id%TYPE
, Dim_Grp_Id           BIS_DIMENSIONS.Dim_Grp_Id%TYPE
, Language             bis_dimensions_tl.Language%TYPE
, Source_Lang          bis_dimensions_tl.Source_Lang%TYPE
-- ankgoel: bug#3891748
, Created_By            BIS_DIMENSIONS.CREATED_BY%TYPE
, Creation_Date         BIS_DIMENSIONS.CREATION_DATE%TYPE
, Last_Updated_By       BIS_DIMENSIONS.LAST_UPDATED_BY%TYPE
, Last_Update_Date      BIS_DIMENSIONS.LAST_UPDATE_DATE%TYPE
, Last_Update_Login     BIS_DIMENSIONS.LAST_UPDATE_LOGIN%TYPE
, Hide                  BIS_DIMENSIONS.HIDE_IN_DESIGN%TYPE := FND_API.G_FALSE
);
--
-- Data Types: Tables
--
TYPE Dimension_Tbl_Type IS TABLE OF Dimension_Rec_Type
INDEX BY BINARY_INTEGER;
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
-- API to retrieve the first and the second required dimension
-- this p_num can be either 1 or 2
-- I wish I had enumerated types :-(
Procedure Retrieve_Required_Dimension
( p_api_version   IN  NUMBER
, p_num           IN  NUMBER
, x_dimension_rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Load_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
, p_force_mode        IN  BOOLEAN := FALSE
);
--
PROCEDURE Update_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY  VARCHAR2
, x_error_Tbl        OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_Dimension
(
    p_api_version       IN          NUMBER
  , p_commit            IN          VARCHAR2   := FND_API.G_FALSE
  , p_validation_level  IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Rec     IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  , x_return_status     OUT NOCOPY  VARCHAR2
  , x_error_Tbl         OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Delete_Dimension
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Load_Dimension_Group (
  p_commit IN VARCHAR2   := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_force_mode IN BOOLEAN := FALSE
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
Procedure Load_Dimension_Wrapper
( p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_Dim_Grp_Rec       IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_force_mode        IN  BOOLEAN := FALSE
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
);
--
Procedure Translate_Dimension_Wrapper
( p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_Dim_Grp_Rec       IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
);

--
PROCEDURE Update_Dimension_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_dim_short_name              IN VARCHAR2,
    p_hide                        IN VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
);

END BIS_DIMENSION_PUB;

 

/
