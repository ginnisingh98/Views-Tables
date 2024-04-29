--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_GROUPS_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVDMGS.pls 120.0 2005/06/01 15:54:32 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCVDMGS.pls                                                                |
 |                                                                                      |
 | Creation Date:                                                                       |
 |          October 9, 2001                                                             |
 |                                                                                      |
 | Creator:                                                                             |
 |          Mario-Jair Campos                                                           |
 |                                                                                      |
 | Description:                                                                         |
 |          Public specs version.                                                       |
 |          This package creates a Dimension Group in BSC.                              |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_group procedure                       |
 |                                                                                      |
 +======================================================================================+
*/

procedure Create_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Create_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

FUNCTION get_Dim_Group_Id(
   p_Short_Name IN varchar2
) RETURN number;

--
PROCEDURE Translate_Dimension_Group
( p_commit IN  VARCHAR2   := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
);

-- ADDED TO SYNC THE LANGUAGE DATA FROM PMF TO BSC

procedure Translate_Dim_By_Given_Lang
( p_commit          IN  VARCHAR2  := FND_API.G_FALSE
, p_Dim_Grp_Rec     IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
);


end BSC_DIMENSION_GROUPS_PVT;

 

/
