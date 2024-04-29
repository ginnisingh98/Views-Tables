--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_SETS_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVDMSS.pls 120.0 2005/06/01 15:36:21 appldev noship $ */

procedure Create_Dim_Group_In_Dset(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Retrieve_Dim_Group_In_Dset(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Update_Dim_Group_In_Dset(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Delete_Dim_Group_In_Dset(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Create_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Retrieve_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Update_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Delete_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Create_Dim_Level_Properties(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Retrieve_Dim_Level_Properties(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Update_Dim_Level_Properties(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Delete_Dim_Level_Properties(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Create_Dim_Levels(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Retrieve_Dim_Levels(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Update_Dim_Levels(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Delete_Dim_Levels(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

procedure Update_Kpi_Analysis_Options_B(
  p_commit              IN	varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN	BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY	varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

end BSC_DIMENSION_SETS_PVT;

 

/
