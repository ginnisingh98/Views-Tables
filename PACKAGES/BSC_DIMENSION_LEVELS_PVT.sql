--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_LEVELS_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVDMLS.pls 120.0 2005/06/01 16:11:30 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCVDMLS.pls                                                                |
 |                                                                                      |
 | Creation Date:                                   |
 |          October 9, 2001                         |
 |                                          |
 | Creator:                                     |
 |          Mario-Jair Campos                       |
 |                                          |
 | Description:                                     |
 |              Public spec version.                        |
 |                      This package creates a BSC Dimension (Level).           |
 | 07-MAY-2003  Retrieve_Relationship() Added by ADRAO for change Enh#2901823           |
 |                                          |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_level procedure for enh# 2842894      |
 | 17-NOV-2003 PAJOHRI  Bug #3232366                                                    |
 +======================================================================================+
*/

TYPE Dim_Level_Rec_Type is Record(
  Level_Short_Name      varchar2(30)
 ,Level_Long_Name       varchar2(255)
);

TYPE Dim_Level_Tbl_Type is TABLE OF Dim_Level_Rec_Type
  INDEX BY BINARY_INTEGER;

-- Procedure to Create all pertaining information for a given Dimension Level.
-- Though all procedures in this package may be called individually, this
-- procedure is the entry point to populate all meta data for dimension levels.
procedure Create_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY     BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- Procedure to Delete all pertaining information for a given Dimension Level.
-- Though all procedures in this package may be called individually, this
-- procedure is the entry point to delete all meta data for dimension levels.
procedure Delete_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- Procedure to Populate the necessary meta data in BSC for a dimension level.
procedure Create_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY     BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- Procedure to Delete the necessary meta data in BSC for a dimension level.
procedure Delete_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- Procedure to Populate information on the columns for the dimension level
-- view or table.
procedure Create_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY     BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- Procedure to Delete information on the columns for the dimension level
-- view or table.
procedure Delete_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

function Get_Next_Value(
  p_table_name          IN      varchar2
 ,p_column_name         IN      varchar2
)return number;

function Get_Id(
  p_table_name          IN      varchar2
 ,p_column_name         IN      varchar2
 ,p_column_value        IN      varchar2
 ,p_column_ID_name      IN      varchar2
) return number;

function Validate_Dim_Level(
  p_level_name          IN      varchar2
) return varchar2;

function Validate_Dim_Group(
  p_group_name                  varchar2
) return number;

function get_dim_levels(
  p_meas_short_name             varchar2
 ,p_dim_short_name              varchar2
) return Dim_Level_Tbl_Type;

function Validate_Value(
  p_Table_Name                  varchar2
 ,p_Table_Column_Name           varchar2
 ,p_Column_Value                number
) return number;

function Get_Object_Name(
  p_Table_Name                  varchar2
 ,p_Table_Name_Column           varchar2
 ,p_Table_Id_Column             varchar2
 ,p_Id_Value                    number
) return varchar2;

/*********************************************************************************
-- Procedures to Handle Relationships between Dimension Levels
**********************************************************************************/
---------
PROCEDURE Create_Dim_Level_Relation(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);
----------
PROCEDURE Delete_Dim_Level_Relation(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 );
-----------
FUNCTION Evaluate_Circular_Relationship(
             p_Child_level_Id IN number
            ,p_Parent_Dim_Level_Id IN number
            ,p_Relation_Type IN number := 1
            ,p_Output_Flag IN boolean := TRUE
        ,x_Parents OUT NOCOPY varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 ) RETURN boolean;
-----------
FUNCTION get_Dim_Level_Name(
   p_Child_level_Id IN number
) RETURN varchar2;
-----------
FUNCTION get_Dim_Level_Id(
   p_Short_Name IN varchar2
) RETURN number;
----------
PROCEDURE Create_BSC_Dim_Level_View (
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 );

----------
procedure Retrieve_Relationship
(
     p_Dim_Level_Rec         IN          BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,   x_Dim_Level_Rec         OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,   x_return_status         OUT NOCOPY  VARCHAR2
 ,   x_msg_count             OUT NOCOPY  NUMBER
 ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
**********************************************************************************/
FUNCTION get_Relation_Column(
     p_Child_level_Id  IN NUMBER
   , p_Parent_level_Id IN NUMBER
   , p_Relation_Type   IN NUMBER
   , x_return_status   OUT NOCOPY VARCHAR2
   , x_msg_count       OUT NOCOPY NUMBER
   , x_msg_data        OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;
/*********************************************************************************
**********************************************************************************/

PROCEDURE Translate_Dimension_Level (
  p_Commit IN VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Pmf_Dim_Rec IN BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec IN BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
);
--

procedure Trans_DimObj_By_Given_Lang
(     p_commit          IN  VARCHAR2 := FND_API.G_FALSE
    , p_dim_level_rec   IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_msg_count       OUT NOCOPY NUMBER
    , x_msg_data        OUT NOCOPY VARCHAR2
);
--=============================================================================
FUNCTION Validate_Dim_Level_Id (
 p_dim_level_id IN NUMBER
) RETURN NUMBER ;
--=============================================================================
end BSC_DIMENSION_LEVELS_PVT;

 

/
