--------------------------------------------------------
--  DDL for Package BSC_KPI_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_GROUP_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVKGPS.pls 120.0 2005/06/01 15:08:15 appldev noship $ */

procedure Create_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec	IN	BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec	IN OUT NOCOPY      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

end BSC_KPI_GROUP_PVT;

 

/
