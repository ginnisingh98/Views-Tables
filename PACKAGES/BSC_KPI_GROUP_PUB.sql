--------------------------------------------------------
--  DDL for Package BSC_KPI_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_GROUP_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPKGPS.pls 120.0 2005/06/01 16:10:28 appldev noship $ */

TYPE Bsc_Kpi_Group_Rec is RECORD(
  Bsc_Csf_Id                NUMBER
 ,Bsc_Group_Height          NUMBER
 ,Bsc_Group_Width           NUMBER
 ,Bsc_Kpi_Group_Help        BSC_TAB_IND_GROUPS_TL.HELP%TYPE
 ,Bsc_Kpi_Group_Id          NUMBER
 ,Bsc_Kpi_Group_Name        BSC_TAB_IND_GROUPS_TL.NAME%TYPE
 ,Bsc_Kpi_Group_Type        NUMBER
 ,Bsc_Language              BSC_TAB_IND_GROUPS_TL.LANGUAGE%TYPE
 ,Bsc_Left_Position_In_Tab  NUMBER
 ,Bsc_Name_Justif_In_Tab    NUMBER
 ,Bsc_Name_Pos_In_Tab       NUMBER
 ,Bsc_Source_Language       BSC_TAB_IND_GROUPS_TL.SOURCE_LANG%TYPE
 ,Bsc_Tab_Id                NUMBER
 ,Bsc_Top_Position_In_Tab   NUMBER
 ,Bsc_Kpi_Group_Short_Name  BSC_TAB_IND_GROUPS_B.SHORT_NAME%TYPE
);

TYPE Bsc_Kpi_Group_Tbl IS TABLE OF Bsc_Kpi_Group_Rec
  INDEX BY BINARY_INTEGER;

--new procedure. Initializing the kpi group record.
procedure Initialize_Kpi_Group_Rec(
  p_Bsc_Kpi_Group_Rec   IN            BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   OUT NOCOPY    BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
);

procedure Create_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN  BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Group(
  p_commit              IN             varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN             BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   OUT NOCOPY     BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN  BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   IN OUT NOCOPY   BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
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
 ,p_Bsc_Kpi_Group_Rec   IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

end BSC_KPI_GROUP_PUB;

 

/
