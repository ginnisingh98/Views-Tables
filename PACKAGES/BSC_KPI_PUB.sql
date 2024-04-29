--------------------------------------------------------
--  DDL for Package BSC_KPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_KPI_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPKPPS.pls 120.10 2007/04/02 18:06:51 akoduri ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPKKPS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public Spec version.                        |
 |          This package Creates, Retrieve, Update, Delete          |
 |          for BSC KPI information.                    |
 | 31-JUl-2003   mahrao  Changed the record Bsc_Kpi_Entity_Rec for bug# 3030788         |
 |                      14-NOV-2003 ADRAO  Modified for  Bug #3248729,                  |
 |   11-MAR-04          jxyu  Modified for enhancement #3493589                         |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   18-JUN-04          adrao Modified PL/SQL record  Bsc_Kpi_Entity_Rec to add         |
 |                      Bsc_Kpi_Ana_Group_Short_Name for BSC_KPI_ANALYSIS_GROUPS        |
 |   15-DEC-04          adrao moved here the API Delete_Kpi_AT to be public to all      |
 |                      fixed for Bug#4064587                                           |
 |   21-FEB-2005        ankagarw  enh#3862703                                           |
 |   21-JUL-2005        ashankar Bug#4314386                                            |
 |   22-AUG-2005        ashankar Bug#4220400 added Bsc_Anal_Opt_Comb_Tbl to             |
 |                      Bsc_Kpi_Entity_Rec                                              |
 |   03-AUG-2006        ashankar bug#5400575 modified move_master_kpi                   |
 |   16-NOV-2006        ankgoel  Color By KPI enh#5244136                               |
 |   16-NOV-2006        vtulasi   Color By KPI enh#5244136                               |
 |   31-Jan-2007        akoduri Enh #5679096 Migration of multibar functionality from   |
 |                      VB to Html                                                      |
 |   21-MAR-2007        akoduri  Copy Indicator Enh#5943238                             |
 +======================================================================================+
*/
-- Added for Bug #3248729
DELETE_KPI_FLAG            CONSTANT NUMBER      :=  2; -- BSC_KPIS_B.PROTOTYPE_FLAG to indicate DELETED KPI

BENCHMARK_KPI_PROPERTY     CONSTANT VARCHAR(20) := 'BENCHMARK_GRAPH_TYPE';
BENCHMARK_KPI_LINE_GRAPH   CONSTANT NUMBER      :=  0; --this is the default graph type
BENCHMARK_KPI_BAR_GRAPH    CONSTANT NUMBER      :=  1;
c_IND_LEVEL                CONSTANT VARCHAR2(3) := 'KPI';
c_IND_TYPE                 CONSTANT NUMBER      :=  2;

/* Record Type for Kpi Entities. */

TYPE Bsc_Kpi_Entity_Rec is RECORD(
  Bsc_Anal_Group_Id             number -- Kpi
 ,Bsc_Calendar_Id               number -- Kpi
 ,Bsc_Change_Dim_Set            number -- Kpi
 ,Bsc_Csf_Id                    number -- Tab, Group
-- ,Bsc_Default_Value             number -- Kpi
 ,Bsc_Dependency_Flag           number -- Kpi
 ,Bsc_gp_Dependency_Flag        number -- Kpi grand parent dependency flag
 ,Bsc_Dim_Set_Id                number
 ,Bsc_Edw_Flag                  number -- Kpi
 ,Bsc_Group_Height              number -- Group
 ,Bsc_Group_Width               number -- Group
 ,Bsc_Kpi_Analysis_Option0      number
 ,Bsc_Kpi_Analysis_Option1      number
 ,Bsc_Kpi_Analysis_Option2      number
 ,Bsc_Kpi_Anal_Disp_Flag        number
 ,Bsc_Kpi_Anal_Opt0_Name        Bsc_kpi_defaults_tl.ANALYSIS_OPTION0_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Anal_Opt1_Name        Bsc_kpi_defaults_tl.ANALYSIS_OPTION1_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Anal_Opt2_Name        Bsc_kpi_defaults_tl.ANALYSIS_OPTION2_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Anal_Opt_Id           number
 ,Bsc_Kpi_Backcolor             number -- Kpi
 ,Bsc_Kpi_Bm_Group_Id           number -- Kpi
 ,Bsc_Kpi_Calculation_Id        number -- Kpi
 ,Bsc_Kpi_Color_Flag            number -- Kpi
 --,Bsc_Kpi_Color_Level1          number  -- Kpi
 --,Bsc_Kpi_Color_Level2          number  -- Kpi
 --,Bsc_Kpi_Color_Level3          number  -- Kpi
 --,Bsc_Kpi_Color_Level4          number  -- Kpi
 ,Bsc_Kpi_Color_Method          number  -- Kpi
 ,Bsc_Kpi_Config_Type           number -- Kpi
 ,Bsc_Kpi_Current_Period        number -- Kpi
 ,Bsc_Kpi_Default_Value         number -- Kpi
 ,Bsc_Kpi_Dim_Level1_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL1_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level2_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL2_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level3_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL3_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level4_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL4_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level5_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL5_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level6_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL6_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level7_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL7_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level8_Name       BSC_KPI_DEFAULTS_TL.DIM_LEVEL8_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Dim_Level1_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level2_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level3_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level4_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level5_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level6_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level7_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level8_Text       varchar2(240) -- Kpi
 ,Bsc_Kpi_Dim_Level1_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level2_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level3_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level4_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level5_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level6_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level7_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Level8_Value      number -- Kpi
 ,Bsc_Kpi_Dim_Set_Id            number -- Kpi
-- ,Bsc_Kpi_Disp_Order      number -- Kpi
 ,Bsc_Kpi_Display_Order         number -- Kpi
 ,Bsc_Kpi_Group_Help            varchar2(150) -- Group
 ,Bsc_Kpi_Group_Id              number -- Tab, Group
 ,Bsc_Kpi_Group_Name            varchar2(150) -- Group
 ,Bsc_Kpi_Group_Type            number -- Group
 ,Bsc_Kpi_Help                  varchar2(150) -- Kpi
 ,Bsc_Kpi_Filter_Condition      varchar2(240) -- Kpi
 ,Bsc_Kpi_Format_Mask           varchar2(20) -- Kpi
 ,Bsc_Kpi_Id                    number -- Kpi
 ,Bsc_Kpi_Indicator_Type        number -- Kpi
 ,Bsc_Kpi_Level_Comb            varchar2(30) -- Kpi
 ,Bsc_Kpi_Model_Flag            number -- Kpi
 ,Bsc_Kpi_Name                  varchar2(150) -- Kpi
 ,Bsc_Kpi_Num_Years             number -- Kpi
 ,Bsc_Kpi_Options_Displayed     varchar2(300)
 ,Bsc_Kpi_Periodicity_Display   number -- Kpi
 ,Bsc_Kpi_Periodicity_Id        number -- Kpi
 ,Bsc_Kpi_Period_Name           varchar2(90) -- Kpi
 ,Bsc_Kpi_Previous_Years        number -- Kpi
 ,Bsc_Kpi_Property_Code         varchar2(20) -- Kpi
 ,Bsc_Kpi_Property_Value        number -- Kpi
 ,Bsc_Kpi_Prototype_Color       varchar2(5) -- Kpi
 ,Bsc_Kpi_Prototype_Flag        number -- Kpi
 ,Bsc_Kpi_Publish_Flag          number -- Kpi
 ,Bsc_Kpi_Secondary_Value       varchar2(200) -- Kpi
 ,Bsc_Kpi_Series_Name           Bsc_kpi_defaults_tl.SERIES_NAME%TYPE -- Kpi
 ,Bsc_Kpi_Share_Flag            number -- Kpi
 ,Bsc_Kpi_Source_Ind            number -- Kpi
 ,Bsc_Kpi_Table_Name            varchar2(30) -- Kpi
 ,Bsc_Kpi_User_Level0           number -- Kpi
 ,Bsc_Kpi_User_Level1           number -- Kpi
 ,Bsc_Kpi_User_Level1_Default   number -- Kpi
 ,Bsc_Kpi_User_Level2           number -- Kpi
 ,Bsc_Kpi_User_Level2_Default   number -- Kpi
 ,Bsc_Kpi_Viewport_Default_Size number -- Kpi
 ,Bsc_Kpi_Viewport_Flag         number -- Kpi
 ,Bsc_Language                  varchar2(5)
 ,Bsc_Left_Position_In_Tab      number -- Group
 ,Bsc_Measure_Source            varchar2(10)
 ,Bsc_Name_Justif_In_Tab        number -- Group
 ,Bsc_Name_Pos_In_Tab           number -- Group
 ,Bsc_Num_Options               number -- Kpi
 ,Bsc_Parent_Anal_Id            number -- Kpi
 ,Bsc_Responsibility_Id         number -- Tab, Kpi
 ,Bsc_Resp_End_Date             date -- Tab
 ,Bsc_Resp_Start_Date           date -- Tab
 ,Bsc_Source_Language           varchar2(5)
 ,Bsc_Tab_Id                    number -- Tab, Group
 ,Bsc_Top_Position_In_Tab       number -- Group
 ,Created_By                    number -- Tab, Kpi
 ,Creation_Date                 date -- Tab, Kpi
 ,Last_Updated_By               number -- Tab, Kpi
 ,Last_Update_Date              date -- Tab, Kpi
 ,Last_Update_Login             number -- Tab, Kpi
 ,Bsc_Kpi_Short_Name            BSC_KPIS_B.SHORT_NAME%TYPE
 ,Bsc_Kpi_Ana_Group_Short_Name  BSC_KPI_ANALYSIS_GROUPS.SHORT_NAME%TYPE
 ,Bsc_Kpi_Dim_Set_Short_Name    BSC_KPI_DIM_SETS_TL.SHORT_NAME%TYPE
 ,Bsc_Anal_Opt_Comb_Tbl         BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
 ,Bsc_Color_Rollup_Type		BSC_KPIS_B.COLOR_ROLLUP_TYPE%TYPE
 ,Bsc_Prototype_Color_Id	BSC_KPIS_B.PROTOTYPE_COLOR_ID%TYPE
 ,Bsc_Weighted_Color_Method	BSC_KPIS_B.WEIGHTED_COLOR_METHOD%TYPE
 ,Bsc_Prototype_Trend_Id	BSC_KPIS_B.PROTOTYPE_TREND_ID%TYPE
);

TYPE Bsc_Kpi_Entity_Tbl IS TABLE OF Bsc_Kpi_Entity_Rec
  INDEX BY BINARY_INTEGER;

procedure Initialize_Kpi_Entity_Rec(
  p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  OUT NOCOPY    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
);

procedure Create_Kpi(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN      BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi(
  p_commit              IN            varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_Bsc_Kpi_Entity_Rec  OUT NOCOPY    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
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

PROCEDURE Create_Kpi_Access_For_Resp(
  p_commit                       IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Comma_Sep_Resposibility_Key  IN          VARCHAR2
 ,p_Bsc_Kpi_Entity_Rec           IN          BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_return_status                OUT NOCOPY  VARCHAR2
 ,x_msg_count                    OUT NOCOPY  NUMBER
 ,x_msg_data                     OUT NOCOPY  VARCHAR2
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

function get_KPI_Time_Stamp(
  p_kpi_id              IN      number
) return date;

procedure move_master_kpi(
  p_master_kpi              IN             NUMBER
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
);

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


PROCEDURE Delete_Ind_Extra_Tables
(
    p_commit              IN            VARCHAR2 := FND_API.G_FALSE
  , p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2

);

PROCEDURE Delete_Sim_Tree_Data
(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Entity_Rec  IN            BSC_KPI_PUB.BSC_KPI_ENTITY_REC
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Get_KPI_Dim_ShortNames (
 p_Bsc_Kpi_Entity_Rec  IN             BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
 ,x_dim_list            OUT NOCOPY    BSC_UTILITY.t_array_of_varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

PROCEDURE Delete_Unused_Imported_Dims(
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_dim_short_names     IN             BSC_UTILITY.t_array_of_varchar2
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

end BSC_KPI_PUB;

/
