--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_GROUPS_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPDMGS.pls 120.0 2005/06/01 16:36:41 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCPDMGS.pls                                                                |
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
 | 23-FEB-03 PAJOHRI  Added Short_Name to  Bsc_Dim_Group_Rec_Type                       |
 |                    Created Overloaded procedures CREATE_DIMENSION_GROUP              |
 |                                                  UPDATE_DIMENSION_GROUP              |
 | 29-MAY-03   All Enhancement Phase I- short Name column added                         |
 |             Functions added "Retrieve_Sys_Dim_Lvls_Grp_Wrap"                         |
 |                        and "set_dim_lvl_grp_prop_wrap"                               |
 | 13-JUN-03  Adeulgao fixed Bug#2878840 Added function Get_Next_Value to get           |
 |                        the next DIM GROUP ID                                         |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_group procedure                       |
 | 22-JUL-2003 arhegde bug# 3050270 Added dim_properties_default_values and calls       |
 | 29-OCT-2003 mahrao  bug#3209967 Added a column to bsc_sys_dim_levels_by_group        |
 | 14-NOV-2003 mahrao  x_dim_level_where_clause is removed from prcoedure               |
 |                     Retrieve_Sys_Dim_Lvls_Grp_Wrap as PMF 4.0.7 shouldn't            |
 |                     pick up any dependency on 5.1.1                                  |
 | 07-JAN-2004 rpenneru bug#3459443 Modified for getting where clause from BSC data model|
 | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD                      |
 +======================================================================================+
*/

c_comp_flag CONSTANT NUMBER := -1; -- existing VB code defaults to this
c_default_value CONSTANT VARCHAR2(2) := 'T';
c_default_type CONSTANT NUMBER := 0;
c_filter_value CONSTANT NUMBER := 0;
c_no_items CONSTANT NUMBER := 0;
c_parent_in_tot CONSTANT NUMBER := 2;
c_total_flag CONSTANT NUMBER := -1;
C_DEFAULT_DATA CONSTANT VARCHAR2(2) := 'X';

TYPE Bsc_Dim_Group_Rec_Type is RECORD(
  Bsc_Dim_Level_Group_Id          BSC_SYS_DIM_GROUPS_TL.dim_group_id%TYPE
 ,Bsc_Dim_Level_Group_Name        BSC_SYS_DIM_GROUPS_TL.name%TYPE
 ,Bsc_Dim_Level_Group_Short_Name  bsc_sys_dim_groups_tl.short_name%TYPE
 ,Bsc_Dim_Level_Index             number
 ,Bsc_Group_Level_Comp_Flag       number -- group
 ,Bsc_Group_Level_Default_Value   varchar2(2) -- group
 ,Bsc_Group_Level_Default_Type    number -- group
 ,Bsc_Group_Level_Filter_Col      varchar2(30) -- group
 ,Bsc_Group_Level_Filter_Value    number -- group
 ,Bsc_Group_Level_No_Items        number -- group
 ,Bsc_Group_Level_Parent_In_Tot   number -- group
 ,Bsc_Group_Level_Total_Flag      number -- group
 ,Bsc_Group_Level_Where_Clause    bsc_sys_dim_levels_by_group.where_clause%TYPE
 ,Bsc_Language                    varchar2(5)
 ,Bsc_Level_Id                    BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
 ,Bsc_Source_Language             varchar2(5)
 ,Bsc_Created_By                  BSC_SYS_DIM_GROUPS_TL.created_by%TYPE -- PMD: Dim Level WHO columns
 ,Bsc_Creation_Date               BSC_SYS_DIM_GROUPS_TL.creation_date%TYPE   -- For granular locking
 ,Bsc_Last_Updated_By             BSC_SYS_DIM_GROUPS_TL.last_updated_by%TYPE  -- PMD
 ,Bsc_Last_Update_Date            BSC_SYS_DIM_GROUPS_TL.last_update_date%TYPE -- PMD
 ,Bsc_Last_Update_Login           BSC_SYS_DIM_GROUPS_TL.last_update_login%TYPE -- PMD
);


TYPE Bsc_Dim_Tbl_Type IS TABLE OF Bsc_Dim_Group_Rec_Type
  INDEX BY BINARY_INTEGER;

procedure Create_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_create_Dim_Levels   IN      BOOLEAN
 ,x_return_status       OUT  NOCOPY   varchar2
 ,x_msg_count           OUT  NOCOPY   number
 ,x_msg_data            OUT  NOCOPY   varchar2
);

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
 ,p_create_Dim_Levels   IN      BOOLEAN
 ,x_return_status       OUT  NOCOPY   varchar2
 ,x_msg_count           OUT  NOCOPY   number
 ,x_msg_data            OUT  NOCOPY   varchar2
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
-- Code added for ALL starts here
PROCEDURE Retrieve_Sys_Dim_Lvls_Grp_Wrap (
  p_dim_level_shortname IN VARCHAR2
 ,p_dim_shortname   IN VARCHAR2
 ,x_dim_group_id OUT NOCOPY NUMBER
 ,x_dim_level_id OUT NOCOPY NUMBER
 ,x_dim_level_index OUT NOCOPY NUMBER
 ,x_total_flag OUT NOCOPY NUMBER
 ,x_total_disp_name OUT NOCOPY VARCHAR2
 ,x_dim_level_where_clause OUT NOCOPY VARCHAR2
 ,x_comparison_flag OUT NOCOPY NUMBER
 ,x_comp_disp_name OUT NOCOPY VARCHAR2
 ,x_filter_column OUT NOCOPY VARCHAR2
 ,x_filter_value OUT NOCOPY NUMBER
 ,x_default_value OUT NOCOPY VARCHAR2
 ,x_default_type OUT NOCOPY NUMBER
 ,x_parent_in_total OUT NOCOPY NUMBER
 ,x_no_items OUT NOCOPY NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 );

PROCEDURE Set_Dim_lvl_grp_prop_wrap (
  p_dim_level_shortname IN VARCHAR2
 ,p_dim_shortname   IN VARCHAR2
 ,p_all_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 );

FUNCTION Get_Next_Value(
   p_table_name          IN      varchar2
  ,p_column_name         IN      varchar2
)RETURN NUMBER;

PROCEDURE Translate_Dimension_Group
( p_commit IN  VARCHAR2   := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
);
--
PROCEDURE get_unique_dim_group_name(
  p_dim_group_name IN VARCHAR2
 ,p_dim_group_short_name IN VARCHAR2
 ,p_counter IN NUMBER
 ,p_is_insert IN VARCHAR2 := 'Y'
 ,x_dim_group_name OUT NOCOPY VARCHAR2
);
--

PROCEDURE load_dim_levels_in_group(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Pmf_Dim_Rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
);

--
PROCEDURE load_dimension_group (
   p_commit              IN          VARCHAR2 := FND_API.G_FALSE
  ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
  ,x_return_status       OUT NOCOPY  VARCHAR2
  ,x_msg_count           OUT NOCOPY  NUMBER
  ,x_msg_data            OUT NOCOPY  VARCHAR2
  ,p_force_mode          IN BOOLEAN := FALSE
);

--
PROCEDURE ret_dimgrpid_fr_shname (
   p_dim_short_name IN VARCHAR2
  ,x_dim_grp_id OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
);
--
PROCEDURE dim_properties_default_values (
  x_dim_level_index OUT NOCOPY NUMBER
 ,x_total_flag OUT NOCOPY NUMBER
 ,x_comparison_flag OUT NOCOPY NUMBER
 ,x_filter_column OUT NOCOPY VARCHAR2
 ,x_filter_value OUT NOCOPY NUMBER
 ,x_default_value OUT NOCOPY VARCHAR2
 ,x_default_type OUT NOCOPY NUMBER
 ,x_parent_in_total OUT NOCOPY NUMBER
 ,x_no_items OUT NOCOPY NUMBER
 ,x_total_disp_name OUT NOCOPY VARCHAR2
 ,x_comp_disp_name OUT NOCOPY VARCHAR2
);
--
-- ADDED TO SYNC THE LANGUAGE DATA FROM PMF TO BSC

procedure Translate_Dim_By_Given_Lang
( p_commit          IN  VARCHAR2 := FND_API.G_FALSE
, p_Dim_Grp_Rec     IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
);

end BSC_DIMENSION_GROUPS_PUB;

 

/
