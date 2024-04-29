--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_SETS_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPDMSS.pls 120.0 2005/06/01 16:14:11 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCPDMSS.pls                                                                |
 |                                                                                      |
 | Creation Date:                                                                       |
 |          October 9, 2001                                                             |
 |                                                                                      |
 | Creator:                                                                             |
 |          Mario-Jair Campos                                                           |
 |                                                                                      |
 | Description:                                                                         |
 |          Public specs for package.                                                   |
 |          This Package creates a Dimension Set in BSC.                                |
 |                                                                                      |
 |          PAJOHRI 21-MAR-2003 Added Bsc_Dim_Set_Rec_Type.Bsc_View_Name                |
 |                              Added Bsc_Dim_Set_Rec_Type.Bsc_Analysis_Id              |
 |                  19-SEP-2003 ADRAO   Added API Reorder_Dim_Level                     |
 |                  18-JUN-2004 ADRAO   Modified Record Bsc_Dim_Set_Rec_Type to         |
 |                                      accomodate BSC_KPI_DIM_SETS_TL.SHORT_NAME       |
 |                  07-DEC-2004 ADRAO   Added constants C_REL_ONE_TO_MANY and           |
 |                                      C_REL_MANY_TO_MANY for Bug4052221               |
 +======================================================================================+
*/

C_REL_ONE_TO_MANY  CONSTANT NUMBER  := 1;
C_REL_MANY_TO_MANY CONSTANT NUMBER  := 2;

TYPE Bsc_Dim_Set_Rec_Type is RECORD
(
       Bsc_Action                    VARCHAR2(10)
    ,  Bsc_Dim_Comp_Disp_Name        BSC_KPI_DIM_LEVELS_TL.Comp_Disp_Name%TYPE
    ,  Bsc_Dim_Level_Group_Id        BSC_KPI_DIM_GROUPS.dim_group_id%TYPE
    ,  Bsc_Dim_Level_Group_Index     BSC_KPI_DIM_GROUPS.dim_group_index%TYPE
    ,  Bsc_Dim_Level_Help            BSC_KPI_DIM_LEVELS_TL.Help%TYPE
    ,  Bsc_Dim_Level_Long_Name       BSC_KPI_DIM_LEVELS_TL.Name%TYPE
    ,  Bsc_Dim_Set_Id                BSC_KPI_DIM_SETS_TL.dim_set_id%TYPE
    ,  Bsc_Dim_Set_Name              BSC_KPI_DIM_SETS_TL.name%TYPE
    ,  Bsc_Dim_Tot_Disp_Name         BSC_KPI_DIM_LEVELS_TL.Comp_Disp_Name%TYPE
    ,  Bsc_Dset_Comp_Order           BSC_KPI_DIM_LEVELS_B.comp_order_by%TYPE
    ,  Bsc_Dset_Default_Key_Value    BSC_KPI_DIM_LEVELS_B.default_key_value%TYPE
    ,  Bsc_Dset_Default_Type         BSC_KPI_DIM_LEVELS_B.default_type%TYPE
    ,  Bsc_Dset_Default_Value        BSC_KPI_DIM_LEVELS_B.default_value%TYPE
    ,  Bsc_Dset_Dim_Level_Index      BSC_KPI_DIM_LEVELS_B.dim_level_index%TYPE
    ,  Bsc_Dset_Filter_Column        BSC_KPI_DIM_LEVELS_B.filter_column%TYPE
    ,  Bsc_Dset_Filter_Value         BSC_KPI_DIM_LEVELS_B.filter_value%TYPE
    ,  Bsc_Dset_Level_Display        BSC_KPI_DIM_LEVELS_B.level_display%TYPE
    ,  Bsc_Dset_No_Items             BSC_KPI_DIM_LEVELS_B.no_items%TYPE
    ,  Bsc_Dset_Parent_In_Total      BSC_KPI_DIM_LEVELS_B.parent_in_total%TYPE
    ,  Bsc_Dset_Parent_Level_Index   BSC_KPI_DIM_LEVELS_B.parent_level_index%TYPE
    ,  Bsc_Dset_Parent_Level_Index2  BSC_KPI_DIM_LEVELS_B.parent_level_index2%TYPE
    ,  Bsc_Dset_Parent_Level_Rel     BSC_KPI_DIM_LEVELS_B.parent_level_rel%TYPE
    ,  Bsc_Dset_Parent_Level_Rel2    BSC_KPI_DIM_LEVELS_B.parent_level_rel2%TYPE
    ,  Bsc_Dset_Position             BSC_KPI_DIM_LEVELS_B.position%TYPE
    ,  Bsc_Dset_Status               BSC_KPI_DIM_LEVELS_B.status%TYPE
    ,  Bsc_Dset_Target_Level         BSC_KPI_DIM_LEVELS_B.target_level%TYPE
    ,  Bsc_Dset_Table_Relation       BSC_KPI_DIM_LEVELS_B.table_relation%TYPE
    ,  Bsc_Dset_Total0               BSC_KPI_DIM_LEVELS_B.total0%TYPE
    ,  Bsc_Dset_User_Level0          BSC_KPI_DIM_LEVELS_B.user_level0%TYPE
    ,  Bsc_Dset_User_Level1          BSC_KPI_DIM_LEVELS_B.user_level1%TYPE
    ,  Bsc_Dset_User_Level1_Default  BSC_KPI_DIM_LEVELS_B.user_level1_default%TYPE
    ,  Bsc_Dset_User_Level2          BSC_KPI_DIM_LEVELS_B.user_level2%TYPE
    ,  Bsc_Dset_User_Level2_Default  BSC_KPI_DIM_LEVELS_B.user_level2_default%TYPE
    ,  Bsc_Dset_Value_Order          BSC_KPI_DIM_LEVELS_B.value_order_by%TYPE
    ,  Bsc_Kpi_Id                    BSC_KPIS_B.Indicator%TYPE
    ,  Bsc_Language                  VARCHAR2(5)
    ,  Bsc_Level_Id                  BSC_KPI_DIM_LEVEL_PROPERTIES.dim_level_id%TYPE
    ,  Bsc_Level_Name                BSC_KPI_DIM_LEVELS_B.level_table_name%TYPE
    ,  Bsc_New_Dset                  VARCHAR2(1)
    ,  Bsc_Option_Id                 BSC_KPI_ANALYSIS_OPTIONS_B.option_id%TYPE
    ,  Bsc_Pk_Col                    BSC_KPI_DIM_LEVELS_B.level_pk_col%TYPE
    ,  Bsc_Source_Language           VARCHAR2(5)
    ,  Bsc_View_Name                 BSC_KPI_DIM_LEVELS_B.level_view_name%TYPE
    ,  Bsc_Analysis_Id               BSC_KPI_ANALYSIS_OPTIONS_B.Analysis_Group_Id%TYPE
    -- PMD
    ,  Bsc_Created_By                NUMBER  -- PMD WHO COLUMN
    ,  Bsc_Creation_Date             DATE    -- PMD WHO COLUMN
    ,  Bsc_Last_Updated_By           NUMBER  -- PMD WHO COLUMN
    ,  Bsc_Last_Update_Date          DATE    -- PMD WHO COLUMN
    ,  Bsc_Last_Update_Login         NUMBER  -- PMD WHO COLUMN
    ,  Bsc_Dim_Set_Short_Name        BSC_KPI_DIM_SETS_TL.SHORT_NAME%TYPE
);

TYPE Bsc_Dim_Set_Tbl_Type IS TABLE OF Bsc_Dim_Set_Rec_Type
  INDEX BY BINARY_INTEGER;


procedure Create_Dim_Group_In_Dset(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dim_Group_In_Dset(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dim_Group_In_Dset(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Dim_Group_In_Dset(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Create_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Create_Dim_Level_Properties(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dim_Level_Properties(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dim_Level_Properties(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Dim_Level_Properties(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Reorder_Dim_Levels
(
        p_commit            IN           VARCHAR2 := FND_API.G_FALSE
    ,   p_Dim_Set_Rec       IN           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
    ,   x_return_status     OUT NOCOPY   VARCHAR2
    ,   x_msg_count         OUT NOCOPY   NUMBER
    ,   x_msg_data          OUT NOCOPY   VARCHAR2
) ;

procedure Create_Dim_Levels(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Dim_Levels(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Dim_Levels(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Delete_Dim_Levels(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Update_Kpi_Analysis_Options_B(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);
procedure Create_Dim_Group_In_Dset(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,p_create_Dim_Lev_Grp  IN         BOOLEAN
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);
procedure Update_Dim_Group_In_Dset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,p_create_Dim_Lev_Grp  IN         BOOLEAN
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);
procedure Delete_Dim_Group_In_Dset(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,p_create_Dim_Lev_Grp  IN         BOOLEAN
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

end BSC_DIMENSION_SETS_PUB;

 

/
