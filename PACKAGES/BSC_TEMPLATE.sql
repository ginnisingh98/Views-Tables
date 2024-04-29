--------------------------------------------------------
--  DDL for Package BSC_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: BSCUTMPS.pls 115.6 2003/06/10 07:10:22 pajohri ship $ */

/*=========================================================================+
 |  Copyright (c) 1999 Oracle Corporation Belmont, California, USA         |
 |                       All rights reserved                               |
 +=========================================================================*/
/*-------------------------------------------------------------------------*
 |                                                                         |
 |FILENAME                                                                 |
 |                                                                         |
 |   BSCUTMPS.pls                                                          |
 |                                                                         |
 |DESCRIPTION                                                              |
 |                                                                         |
 |   Package for creating a Baclanced Scorecard layout for a new system.   |
 |                                                                         |
 |Notes:                                                                   |
 |                                                                         |
 |   OBSC only supports 2 layouts, Tab and Cross, while creating a new     |
 |   system from KPI designer in release 1.0. In the later releases,       |
 |   OBSC may have more templates, for example, Tab with 3 tabs, or        |
 |   with 4 tabs.                                                          |
 |                                                                         |
 |HISTORY                                                                  |
 |  02/07/1999    Alex Yang Created.                                       |
 |  12/21/1999    Henry Camacho Modified to Model 4.0                      |
 |  23-FEB-03     PAJOHRI  Added Short_Name to Dfamily_Rec_Type            |
 *-------------------------------------------------------------------------*/
-- Global Variables
--

-- Record type for BSC_TABS_B,BSC_TABS_TL table
-- For Tab system only
Type Tab_Rec_Type Is Record (
    Code        BSC_TABS_B.tab_id%type,
    Name        BSC_TABS_TL.name%type,
    Help        BSC_TABS_TL.help%type,
    N_Groups    number(3)       -- number of groups within tab
);


TYPE Tab_Tbl_Type IS TABLE OF Tab_Rec_Type
 INDEX BY BINARY_INTEGER;


-- Record type for BSC_TAB_CSF_B, BSC_TAB_CSF_TL table
-- For a Cross system only
Type Csf_Rec_Type Is Record (
    Code        BSC_TAB_CSF_B.csf_id%type,
    Type        BSC_TAB_CSF_B.csf_type%type,
    Inter_Flag  BSC_TAB_CSF_B.intermediate_flag%type,
    Name        BSC_TAB_CSF_TL.name%type,
    Help        BSC_TAB_CSF_TL.help%type
);


TYPE Csf_Tbl_Type IS TABLE OF Csf_Rec_Type
 INDEX BY BINARY_INTEGER;


-- record type for BSC_TAB_IND_GROUPS_B, BSC_TAB_IND_GROUPS_TL table
Type Group_Rec_Type Is Record (
    Tab     BSC_TAB_IND_GROUPS_B.tab_id%type,
    Code        BSC_TAB_IND_GROUPS_B.ind_group_id%type,
    Name        BSC_TAB_IND_GROUPS_TL.name%type,
    Help        BSC_TAB_IND_GROUPS_TL.help%type
);

TYPE Group_Tbl_Type IS TABLE OF Group_Rec_Type
 INDEX BY BINARY_INTEGER;


-- record type for BSC_KPIS_B, BSC_KPIS_TL table
--   Options      : the number of records in BSC_KPI_PROPERTIESfor an indicator
--   Detail_Flag  : value  'NO' means only inserting records into BSC_KPI_PERIODICITIES
--                  table for a indicator
--   Period_Shown : the number of records in BSC_KPI_PERIODICITIES,
--                  and BSC_KPI_DATA_TABLES tables
--                  for an indicator
--   System_C     : For Tab system only. The Tab number which the indicator
--                  belong to


Type Ind_Rec_Type Is Record (
    Indicator   BSC_KPIS_B.indicator%type,
    Csf     BSC_KPIS_B.csf_id%type,
    Group_r     BSC_KPIS_B.ind_group_id%type,
    Type        BSC_KPIS_B.indicator_type%type,
    Config      BSC_KPIS_B.config_type%type,
    Periodicity BSC_KPIS_B.periodicity_id%type,
        --
    Name        BSC_KPIS_TL.name%type,
    Help        BSC_KPIS_TL.help%type,
        --
        Options         Number,
    Detail_Flag     Varchar2(3) := 'YES',
    Period_Shown    Number      := 1,
    Tab         Number(5)   := NULL,
    Drills      Number(5)   := 1,  -- Number of dimensions
    ---
    User_Options    Number      -- User Options
);

TYPE Ind_Tbl_Type IS TABLE OF Ind_Rec_Type
 INDEX BY BINARY_INTEGER;

-- record type for BSC_KPI_PROPERTIES table
Type Var_Rec_Type Is Record (
    Code            BSC_KPI_PROPERTIES.property_code%type,
    Value           BSC_KPI_PROPERTIES.property_value%type
);

TYPE Var_Tbl_Type IS TABLE OF Var_Rec_Type
 INDEX BY BINARY_INTEGER;

-- record type for BSC_KPI_CALCULATIONS table
Type Cal_Rec_Type Is Record (
    Calculation BSC_KPI_CALCULATIONS.calculation_id%type,
    EV0     BSC_KPI_CALCULATIONS.user_level0%type
);

TYPE Cal_Tbl_Type IS TABLE OF Cal_Rec_Type
 INDEX BY BINARY_INTEGER;

-- record type for BSC_KPI_PERIODICITIES table
Type Period_Rec_Type Is Record (
    Order_r         BSC_KPI_PERIODICITIES.display_order%type,
    Period_Type     BSC_KPI_PERIODICITIES.periodicity_id%type,
    Prev_Year       BSC_KPI_PERIODICITIES.previous_years%type,
    Num_Years       BSC_KPI_PERIODICITIES.num_of_years%type,
    Viewport_flag       BSC_KPI_PERIODICITIES.viewport_flag%type,
    Viewport_Size       BSC_KPI_PERIODICITIES.viewport_default_size%type
);

Type Period_Tbl_Type IS TABLE OF Period_Rec_Type
  INDEX BY BINARY_INTEGER;


-- record type for BSC_KPI_DIM_LEVELS_B, BSC_KPI_DIM_LEVELS_TL table
Type Drill_Rec_Type Is Record (
    Dim_level_index BSC_KPI_DIM_LEVELS_B.Dim_level_index%type,
    Table_Name  BSC_KPI_DIM_LEVELS_B.level_table_Name%type,
    Filter_Val  BSC_KPI_DIM_LEVELS_B.filter_value%type,
    Default_val BSC_KPI_DIM_LEVELS_B.default_value%type,
    Default_type    BSC_KPI_DIM_LEVELS_B.Default_type%type,
    Value_Order     BSC_KPI_DIM_LEVELS_B.value_order_by%type,
    Comp_Order  BSC_KPI_DIM_LEVELS_B.Comp_order_by%type,
    Level_pk_col    BSC_KPI_DIM_LEVELS_B.Level_pk_col%type,
    Parent      BSC_KPI_DIM_LEVELS_B.parent_level_index%type,
    Parent_Rel  BSC_KPI_DIM_LEVELS_B.parent_level_rel%type,
    Table_Rel   BSC_KPI_DIM_LEVELS_B.table_relation%type,
    Parent2     BSC_KPI_DIM_LEVELS_B.parent_level_index2%type,
    Parent_Rel2     BSC_KPI_DIM_LEVELS_B.parent_level_rel2%type,
    Status      BSC_KPI_DIM_LEVELS_B.status%type,
    Position    BSC_KPI_DIM_LEVELS_B.position%type,
    Total0      BSC_KPI_DIM_LEVELS_B.total0%type,
    Ev0         BSC_KPI_DIM_LEVELS_B.user_level0%type,
    Ev1d        BSC_KPI_DIM_LEVELS_B.user_level1_default%type,
    --
    Name        BSC_KPI_DIM_LEVELS_TL.name%type,
    Help        BSC_KPI_DIM_LEVELS_TL.help%type,
    Total       BSC_KPI_DIM_LEVELS_TL.total_disp_name%type,
    Comp        BSC_KPI_DIM_LEVELS_TL.comp_disp_name%type,

    --
    dim_group_id    BSC_KPI_DIM_GROUPS.dim_group_id%type,
    dim_group_idx   BSC_KPI_DIM_GROUPS.dim_group_index%type,
    --
    dim_level_id    BSC_KPI_DIM_LEVEL_PROPERTIES.dim_level_id%type,
    level_display   BSC_KPI_DIM_LEVEL_PROPERTIES.level_display%type,
    --
    Level_View_Name BSC_SYS_DIM_LEVELS_B.level_view_name%type
);

TYPE Drill_Tbl_Type IS TABLE OF Drill_Rec_Type
 INDEX BY BINARY_INTEGER;


-- record type for BSC_SYS_DIM_LEVELS_B, BSC_SYS_DIM_LEVELS_TL table

Type Project_Rec_Type Is Record (
    Dim_level_id    BSC_SYS_DIM_LEVELS_B.Dim_level_id%type,
    Table_name  BSC_SYS_DIM_LEVELS_B.level_Table_name%type,
    Table_Type  BSC_SYS_DIM_LEVELS_B.table_type%type,
    Level_pk_col    BSC_SYS_DIM_LEVELS_B.Level_pk_col%type,
    Abbreviation    BSC_SYS_DIM_LEVELS_B.abbreviation%type,
    Value_Order     BSC_SYS_DIM_LEVELS_B.value_order_by%type,
    Comp_Order  BSC_SYS_DIM_LEVELS_B.Comp_order_by%type,
    Custom_Group    BSC_SYS_DIM_LEVELS_B.custom_group%type,
    User_size   BSC_SYS_DIM_LEVELS_B.user_key_size%type,
    Disp_size   BSC_SYS_DIM_LEVELS_B.disp_key_size%type,
        --
    Name        BSC_SYS_DIM_LEVELS_TL.name%type,
    Help        BSC_SYS_DIM_LEVELS_TL.help%type,
    Caption_Tot BSC_SYS_DIM_LEVELS_TL.total_disp_name%type,
    Caption_Com BSC_SYS_DIM_LEVELS_TL.comp_disp_name%type,
    --
    parent_level    BSC_SYS_DIM_LEVEL_RELS.parent_dim_level_id%type,
    fk_field        BSC_SYS_DIM_LEVEL_RELS.relation_col%type,
    rel_type        BSC_SYS_DIM_LEVEL_RELS.relation_type%type,
    direct_rel      BSC_SYS_DIM_LEVEL_RELS.direct_relation%type,
    --
    Level_View_Name BSC_SYS_DIM_LEVELS_B.level_view_name%type
);

Type Project_Tbl_Type IS TABLE OF Project_Rec_Type
  INDEX BY BINARY_INTEGER;


-- record type for BSC_SYS_DIM_GROUPS_TL, BSC_SYS_DIM_LEVELS_BY_GROUP table

Type Dfamily_Rec_Type Is Record (
    Dim_group_id    BSC_SYS_DIM_GROUPS_TL.dim_group_id%type,
    Name            BSC_SYS_DIM_GROUPS_TL.name%type,
    Short_Name      BSC_SYS_DIM_GROUPS_TL.short_name%type,
    --
    Dim_level_id    BSC_SYS_DIM_LEVELS_BY_GROUP.Dim_level_id%type,
    Dim_level_idx   BSC_SYS_DIM_LEVELS_BY_GROUP.Dim_level_index%type,
    Total       BSC_SYS_DIM_LEVELS_BY_GROUP.total_flag%type,
    Comparison  BSC_SYS_DIM_LEVELS_BY_GROUP.comparison_flag%type,
    filter_col  BSC_SYS_DIM_LEVELS_BY_GROUP.filter_column%type,
    filter_val  BSC_SYS_DIM_LEVELS_BY_GROUP.filter_value%type,
    default_val BSC_SYS_DIM_LEVELS_BY_GROUP.default_value%type,
    default_type    BSC_SYS_DIM_LEVELS_BY_GROUP.default_type%type,
    Parent_Total    BSC_SYS_DIM_LEVELS_BY_GROUP.parent_in_total%type,
    No_items    BSC_SYS_DIM_LEVELS_BY_GROUP.No_items%type
);

Type Dfamily_Tbl_Type IS TABLE OF Dfamily_Rec_Type
  INDEX BY BINARY_INTEGER;


-- record type for BSC_SYS_MEASURES table

Type Proj_Field_Rec_Type Is Record (
    Measure_id      BSC_SYS_MEASURES.Measure_id%type,
    Measure_col     BSC_SYS_MEASURES.Measure_col%type,
    Operation       BSC_SYS_MEASURES.operation%type,
    Type            BSC_SYS_MEASURES.type%type,
    Min_Actual      BSC_SYS_MEASURES.min_actual_value%type,
    Max_Actual      BSC_SYS_MEASURES.max_actual_value%type,
    Min_Plan        BSC_SYS_MEASURES.min_budget_value%type,
    Max_Plan        BSC_SYS_MEASURES.max_budget_value%type,
    Style           BSC_SYS_MEASURES.random_style%type,
    Insert_Var      Boolean := FALSE
);

Type Proj_Field_Tbl_Type IS TABLE OF Proj_Field_Rec_Type
  INDEX BY BINARY_INTEGER;


-- record type for BSC_SYS_DATASETS_B, BSC_SYS_DATASETS_TL table

Type Proj_Data_Rec_Type Is Record (
    Dataset_id      BSC_SYS_DATASETS_B.Dataset_id%type,
    Measure1        BSC_SYS_DATASETS_B.Measure_id1%type,
    Operation       BSC_SYS_DATASETS_B.operation%type,
    Measure2        BSC_SYS_DATASETS_B.Measure_id2%type,
    Format          BSC_SYS_DATASETS_B.format_id%type,
    Color_Method        BSC_SYS_DATASETS_B.color_method%type,
    Proj_Flag       BSC_SYS_DATASETS_B.projection_flag%type,
    --
    name            BSC_SYS_DATASETS_TL.name%type,
    Help            BSC_SYS_DATASETS_TL.help%type,
    num_of_calc     number(3)
);

Type Proj_Data_Tbl_Type IS TABLE OF Proj_Data_Rec_Type
  INDEX BY BINARY_INTEGER;


-- record type for BSC_SYS_DIM_LEVEL_COLS table

Type Proj_Dim_Cols_Rec_Type Is Record (
    Dim_level_id        BSC_SYS_DIM_LEVEL_COLS.dim_level_id%type,
    Column_Name         BSC_SYS_DIM_LEVEL_COLS.column_name%type,
    Column_Type     BSC_SYS_DIM_LEVEL_COLS.column_type%type
);

Type Proj_Dim_Cols_Tbl_Type IS TABLE OF Proj_Dim_Cols_Rec_Type
  INDEX BY BINARY_INTEGER;


BSC_SYS_ERROR    Exception;
BSC_DEF_ERROR    Exception;

LOOKUP_VALUES_TABLE VARCHAR2(50);


/*===========================================================================+
|
|   Name:          Create_Template
|
|   Description:   Main entry from BSC designer to create BSC default
|                  layout from selected template
|
|   Parameters:
|   x_template_name    template name
|   x_template_type    template type, 6 for Tab and 1 for Cross
|   x_sys_name     OBSC system name
|   x_sys_desc     OBSC system description
|   x_sys_help     Help text
|   x_debug_flag       debug_flag, default is 'NO'
|
+============================================================================*/

Procedure Create_Template (
        x_template_name     IN  Varchar2,
        x_template_type     IN  Number,
        x_sys_name      IN  Varchar2,
        x_sys_desc      IN  Varchar2,
        x_sys_help      IN  Varchar2,
        x_debug_flag        IN  Varchar2 := 'NO'
);


/*===========================================================================+
|
|   Name:          Restore_Init_Layout
|
|   Description:   Rollback changes if error occurs during template creation
|
|   Parameters:
|   x_template_name    template name
|   x_template_type    template type, 6 for Tab and 1 for Cross
|   x_debug_flag       debug_flag, default is 'NO'
|
+============================================================================*/
Procedure  Restore_Init_Layout(
        x_template_name     IN  Varchar2,
        x_template_type     IN  Number,
        x_debug_flag        IN  Varchar2 := 'NO'
);


END BSC_TEMPLATE;

 

/
