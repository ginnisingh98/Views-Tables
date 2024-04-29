--------------------------------------------------------
--  DDL for Package BSC_KPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVKPPS.pls 120.3 2007/02/09 09:18:28 ashankar ship $ */


c_SIM_TAB_ID   CONSTANT NUMBER := -999;

procedure Create_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Defaults(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Analysis(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Objective_Color_Data(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Periodicity(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Data_Tables(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Calculations(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_User_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Default_Values(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_In_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Kpi_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Shared_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Master_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Move_Tab(
  p_tab_id                      number
 ,p_tab_index                   number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Set_Default_Option(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Set_Default_Option_MG(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

PROCEDURE Set_Default_Value_By_Option_ID
(    p_Kpi_Id                  NUMBER
   , p_group_Id                NUMBER
   , p_parent_option_Id        NUMBER
   , p_grand_parent_option_Id  NUMBER
   , p_option_Id               NUMBER
);

function Validate_Kpi(
  p_Kpi_Name                  IN      varchar2
) return number;


procedure Assign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
);

procedure Unassign_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
);

function Is_Analysis_Option_Selected(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2;

function Is_Leaf_Analysis_Option(
 p_Bsc_kpi_Entity_Rec       IN      BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) return varchar2;

/******************************************************************
                   DELETE APIS FOR OBJECTIVES
/*****************************************************************/

PROCEDURE Delete_Ind_User_Access
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);


PROCEDURE Delete_Ind_Tree_Nodes
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Comments
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Sys_Prop
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Images
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_SeriesColors
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Subtitles
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_MM_Controls
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Shell_Cmds
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Ind_Cause_Effect_Rels(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Sim_Tree_Data
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

END BSC_KPI_PVT;

/
