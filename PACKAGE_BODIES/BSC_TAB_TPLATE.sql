--------------------------------------------------------
--  DDL for Package Body BSC_TAB_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TAB_TPLATE" AS
/* $Header: BSCUTABB.pls 120.5 2007/06/29 08:30:01 ankgoel ship $ */


--
-- Global Variables
--
G_Tab_Tbl   BSC_TEMPLATE.Tab_Tbl_Type;
G_Csf_Tbl   BSC_TEMPLATE.Csf_Tbl_Type;
G_Group_Tbl   BSC_TEMPLATE.Group_Tbl_Type;
G_Ind_Tbl   BSC_TEMPLATE.Ind_Tbl_Type;
G_Var_Tbl   BSC_TEMPLATE.Var_Tbl_Type;
G_Cal_Tbl   BSC_TEMPLATE.Cal_Tbl_Type;
G_Period_Tbl    BSC_TEMPLATE.Period_Tbl_Type;
G_Drill_Tbl   BSC_TEMPLATE.Drill_Tbl_Type;

-- Assign default value to global variable

G_num_of_tabs     Number(3) := 3;
G_num_of_indicators   Number(3) := 13;
G_num_of_variables  Number(3) := 9;
G_num_of_Calculations   Number(3) := 12;

BSC_ERROR   Exception;

l_option_r    number(3) := 0;
l_drill_ind   number(3) := 0;
l_panel0_count    number(3) := 0;
l_panel1_count    number(3) := 0;
l_panel2_count    number(3) := 0;
l_debug_stmt    varchar2(2000) := 'Debug: ';

-- User Options
TYPE t_array_of_number IS TABLE OF Number(3)
   INDEX BY BINARY_INTEGER;
l_user_options  t_array_of_number;

/*===========================================================================+
|
|   Name:          Create_Tab_Template
|
|   Description:   To create a tab system layout.
|                  The following are the insertion order of tables:
|
|     1.  MNAV_SYSTEMS
|     2.  MNAV_INTERMEDIATE_GROUPS
|     3.  MNAV_INTERMEDIATE_GROUPS_L
|     4.  MATRIX
|     5.  MATRIX_INFO
|     6.  MATRIX_LANGUAGE
|     7.  MIND_ANALYSIS
|     8.  MIND_CALCULATIONS
|     9.  MIND_FIELDS
|     40. MIND_DATA
|     11. MIND_DATA_SERIE
|     12. MIND_DRILLS_CONFIG
|     13. MIND_DRILLS
|     14. MIND_DRILLS_LANGUAGE
|     15. MIND_OPTIONS
|     16. MIND_PERIODS
|     17. MIND_PERIODS_LANGUAGE
|     18. MIND_TABLES_NEW
|     19. MNAV_INDICATORS_BY_SYSTEM
|
+============================================================================*/


Function Create_Tab_Template
Return Boolean
Is
  l_top_c   BSC_TAB_IND_GROUPS_B.top_position%type;
  l_left_r  BSC_TAB_IND_GROUPS_B.left_position%type;
  l_height  BSC_TAB_IND_GROUPS_B.height%type;
  l_width   BSC_TAB_IND_GROUPS_B.width%type;
  l_group_ind number;

  l_gl_type BSC_SYS_LINES.line_type%type;
  l_gl_index_r  BSC_SYS_LINES.line_id%type;
  l_gl_top_c  BSC_SYS_LINES.top_position%type;
  l_gl_left_r BSC_SYS_LINES.left_position%type;
  l_gl_length BSC_SYS_LINES.length%type;
  l_gl_arrow  BSC_SYS_LINES.arrow%type;

  l_data_code   BSC_KPI_ANALYSIS_MEASURES_B.dataset_id%type;
  l_opt_caption BSC_KPI_ANALYSIS_OPTIONS_TL.name%type;
  l_opt_lookup  BSC_KPI_ANALYSIS_OPTIONS_B.option_id%type;

  l_cursor  number;
  l_ignore  number;
  l_sql_stmt  varchar2(32700);

  l_kpidefaults varchar2(2000);
  level_per   number;
  l_count   number := 0;
  -- 2828685 enhancement
  h_max_id  NUMBER;
  h_cursor  INTEGER;
  h_ret   INTEGER;
  l_sql   VARCHAR2(32000);
  l_sql_defaults_b VARCHAR2(32000);
  l_kpi_measure_id NUMBER;
  x_return_status  VARCHAR2(1);
  x_msg_count      NUMBER;
  x_msg_data       VARCHAR2(4000);

begin

  -- Define tabs

  G_Tab_Tbl(0).Code   := 0;
  G_Tab_Tbl(0).Name   := 'Tab 1';
  G_Tab_Tbl(0).Help   := 'Tab 1 Description';
  G_Tab_Tbl(0).N_groups := 4;


  G_Tab_Tbl(1).Code   := 1;
  G_Tab_Tbl(1).Name   := 'Tab 2';
  G_Tab_Tbl(1).Help   := 'Tab 2 Description';
  G_Tab_Tbl(1).N_groups := 4;

  G_Tab_Tbl(2).Code   := 2;
  G_Tab_Tbl(2).Name   := 'Tab 3';
  G_Tab_Tbl(2).Help   := 'Tab 3 Description';
  G_Tab_Tbl(2).N_groups := 1;

 -- Define CSF
  G_Csf_Tbl(0).Code   := 0;
  G_Csf_Tbl(0).Type   := 0;
  G_Csf_Tbl(0).Inter_Flag:= 0;
  G_Csf_Tbl(0).Name   := 'CSF Default';
  G_Csf_Tbl(0).Help   := 'CSF Default';



  -- Define groups

  G_Group_Tbl(0).Tab    := 0;
  G_Group_Tbl(0).Code   := 0;
  G_Group_Tbl(0).Name   := 'Customer Perspective';
  G_Group_Tbl(0).Help   := 'Customer Perspective';

  G_Group_Tbl(1).Tab     := 0;
  G_Group_Tbl(1).Code   := 1;
  G_Group_Tbl(1).Name   := 'Internal Process Perspective';
  G_Group_Tbl(1).Help   := 'Internal Process Perspective';

  G_Group_Tbl(2).Tab    := 0;
  G_Group_Tbl(2).Code   := 2;
  G_Group_Tbl(2).Name   := 'Learning and Growth Perspective';
  G_Group_Tbl(2).Help   := 'Learning and Growth Perspective';

  G_Group_Tbl(3).Tab    := 0;
  G_Group_Tbl(3).Code   := 3;
  G_Group_Tbl(3).Name   := 'Financial Perspective';
  G_Group_Tbl(3).Help   := 'Financial Perspective';

  -- Define indicator

  G_Ind_Tbl(0).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(0).Csf    := 0;
  G_Ind_Tbl(0).Group_r    := 0;
  G_Ind_Tbl(0).Type   := 1;
  G_Ind_Tbl(0).Config   := 1;
  G_Ind_Tbl(0).Periodicity      := 5;
  G_Ind_Tbl(0).Name   := 'KPI 1 Customer Perspective';
  G_Ind_Tbl(0).Help   := 'Indicator Help';
  G_Ind_Tbl(0).Options    := 9;
  G_Ind_Tbl(0).Detail_Flag      := 'YES';
  G_Ind_Tbl(0).Period_Shown     := 1;
  G_Ind_Tbl(0).Tab          := 0;
  G_Ind_Tbl(0).Drills   := 1;
  G_Ind_Tbl(0).User_Options   := 5;



  G_Ind_Tbl(1).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(1).Csf    := 0;
  G_Ind_Tbl(1).Group_R    := 1;
  G_Ind_Tbl(1).Type   := 1;
  G_Ind_Tbl(1).Config   := 1;
  G_Ind_Tbl(1).Periodicity      := 5;
  G_Ind_Tbl(1).Name   := 'KPI 1 Internal Process';
  G_Ind_Tbl(1).Help   := 'Indicator Help';
  G_Ind_Tbl(1).Options    := 9;
  G_Ind_Tbl(1).Detail_Flag      := 'YES';
  G_Ind_Tbl(1).Period_Shown     := 1;
  G_Ind_Tbl(1).Tab          := 0;
  G_Ind_Tbl(1).Drills   := 1;
  G_Ind_Tbl(1).User_Options   := 5;

  G_Ind_Tbl(2).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(2).Csf    := 0;
  G_Ind_Tbl(2).Group_R    := 2;
  G_Ind_Tbl(2).Type   := 1;
  G_Ind_Tbl(2).Config   := 1;
  G_Ind_Tbl(2).Periodicity      := 5;
  G_Ind_Tbl(2).Name   := 'KPI 1 Learning';
  G_Ind_Tbl(2).Help   := 'Indicator Help';
  G_Ind_Tbl(2).Options    := 9;
  G_Ind_Tbl(2).Detail_Flag      := 'YES';
  G_Ind_Tbl(2).Period_Shown     := 1;
  G_Ind_Tbl(2).Tab          := 0;
  G_Ind_Tbl(2).Drills   := 1;
  G_Ind_Tbl(2).User_Options   := 0;

  G_Ind_Tbl(3).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(3).Csf    := 0;
  G_Ind_Tbl(3).Group_R    := 3;
  G_Ind_Tbl(3).Type   := 1;
  G_Ind_Tbl(3).Config   := 1;
  G_Ind_Tbl(3).Periodicity      := 5;
  G_Ind_Tbl(3).Name   := 'KPI 1 Financial';
  G_Ind_Tbl(3).Help   := 'Indicator Help';
  G_Ind_Tbl(3).Options    := 9;
  G_Ind_Tbl(3).Detail_Flag      := 'YES';
  G_Ind_Tbl(3).Period_Shown     := 1;
  G_Ind_Tbl(3).Tab           := 0;
  G_Ind_Tbl(3).Drills   := 1;
  G_Ind_Tbl(3).User_Options   := 0;

  G_Ind_Tbl(4).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(4).Csf    := 0;
  G_Ind_Tbl(4).Group_R    := 1;
  G_Ind_Tbl(4).Type   := 1;
  G_Ind_Tbl(4).Config   := 1;
  G_Ind_Tbl(4).Periodicity      := 5;
  G_Ind_Tbl(4).Name   := 'KPI 2 Internal Process';
  G_Ind_Tbl(4).Help   := 'Indicator Help';
  G_Ind_Tbl(4).Options    := 9;
  G_Ind_Tbl(4).Detail_Flag      := 'YES';
  G_Ind_Tbl(4).Period_Shown     := 1;
  G_Ind_Tbl(4).Tab          := 0;
  G_Ind_Tbl(4).Drills   := 1;
  G_Ind_Tbl(4).User_Options   := 5;

  G_Ind_Tbl(5).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(5).Csf    := 0;
  G_Ind_Tbl(5).Group_R    := 1;
  G_Ind_Tbl(5).Type   := 1;
  G_Ind_Tbl(5).Config   := 1;
  G_Ind_Tbl(5).Periodicity      := 5;
  G_Ind_Tbl(5).Name   := 'KPI 3 Internal Process';
  G_Ind_Tbl(5).Help   := 'Indicator Help';
  G_Ind_Tbl(5).Options    := 9;
  G_Ind_Tbl(5).Detail_Flag      := 'YES';
  G_Ind_Tbl(5).Period_Shown     := 1;
  G_Ind_Tbl(5).Tab          := 1;
  G_Ind_Tbl(5).Drills   := 1;
  G_Ind_Tbl(5).User_Options   := 0;

  G_Ind_Tbl(6).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(6).Csf    := 0;
  G_Ind_Tbl(6).Group_R    := 0;
  G_Ind_Tbl(6).Type   := 1;
  G_Ind_Tbl(6).Config   := 1;
  G_Ind_Tbl(6).Periodicity      := 1;
  G_Ind_Tbl(6).Name   := 'KPI 2 Customer Perspective';
  G_Ind_Tbl(6).Help   := 'Indicator Help';
  G_Ind_Tbl(6).Options    := 9;
  G_Ind_Tbl(6).Detail_Flag      := 'YES';
  G_Ind_Tbl(6).Period_Shown     := 2;
  G_Ind_Tbl(6).Tab          := 0;
  G_Ind_Tbl(6).Drills   := 1;
  G_Ind_Tbl(6).User_Options   := 0;

  G_Ind_Tbl(7).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(7).Csf    := 0;
  G_Ind_Tbl(7).Group_R    := 0;
  G_Ind_Tbl(7).Type   := 1;
  G_Ind_Tbl(7).Config   := 1;
  G_Ind_Tbl(7).Periodicity      := 5;
  G_Ind_Tbl(7).Name   := 'KPI 3 Customer Perspective';
  G_Ind_Tbl(7).Help   := 'Indicator Help';
  G_Ind_Tbl(7).Options    := 9;
  G_Ind_Tbl(7).Detail_Flag      := 'YES';
  G_Ind_Tbl(7).Period_Shown     := 1;
  G_Ind_Tbl(7).Tab          := 1;
  G_Ind_Tbl(7).Drills   := 1;
  G_Ind_Tbl(7).User_Options   := 0;

  G_Ind_Tbl(8).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(8).Csf    := 0;
  G_Ind_Tbl(8).Group_R    := 2;
  G_Ind_Tbl(8).Type   := 1;
  G_Ind_Tbl(8).Config   := 1;
  G_Ind_Tbl(8).Periodicity      := 5;
  G_Ind_Tbl(8).Name   := 'KPI 2 Learning';
  G_Ind_Tbl(8).Help   := 'Indicator Help';
  G_Ind_Tbl(8).Options    := 9;
  G_Ind_Tbl(8).Detail_Flag      := 'YES';
  G_Ind_Tbl(8).Period_Shown     := 1;
  G_Ind_Tbl(8).Tab          := 0;
  G_Ind_Tbl(8).Drills   := 1;
  G_Ind_Tbl(8).User_Options   := 0;

  G_Ind_Tbl(9).Indicator  := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(9).Csf    := 0;
  G_Ind_Tbl(9).Group_R    := 2;
  G_Ind_Tbl(9).Type   := 1;
  G_Ind_Tbl(9).Config   := 1;
  G_Ind_Tbl(9).Periodicity      := 5;
  G_Ind_Tbl(9).Name   := 'KPI 3 Learning';
  G_Ind_Tbl(9).Help   := 'Indicator Help';
  G_Ind_Tbl(9).Options    := 9;
  G_Ind_Tbl(9).Detail_Flag      := 'YES';
  G_Ind_Tbl(9).Period_Shown     := 1;
  G_Ind_Tbl(9).Tab          := 1;
  G_Ind_Tbl(9).Drills   := 1;
  G_Ind_Tbl(9).User_Options   := 0;

  G_Ind_Tbl(10).Indicator := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(10).Csf   := 0;
  G_Ind_Tbl(10).Group_R   := 3;
  G_Ind_Tbl(10).Type    := 1;
  G_Ind_Tbl(10).Config    := 1;
  G_Ind_Tbl(10).Periodicity     := 5;
  G_Ind_Tbl(10).Name    := 'KPI 2 Financial';
  G_Ind_Tbl(10).Help    := 'Indicator Help';
  G_Ind_Tbl(10).Options   := 9;
  G_Ind_Tbl(10).Detail_Flag     := 'YES';
  G_Ind_Tbl(10).Period_Shown    := 1;
  G_Ind_Tbl(10).Tab         := 0;
  G_Ind_Tbl(10).Drills    := 1;
  G_Ind_Tbl(10).User_Options  := 0;

  G_Ind_Tbl(11).Indicator := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(11).Csf   := 0;
  G_Ind_Tbl(11).Group_R   := 3;
  G_Ind_Tbl(11).Type    := 1;
  G_Ind_Tbl(11).Config    := 1;
  G_Ind_Tbl(11).Periodicity     := 5;
  G_Ind_Tbl(11).Name    := 'KPI 3 Financial';
  G_Ind_Tbl(11).Help    := 'Indicator Help';
  G_Ind_Tbl(11).Options   := 9;
  G_Ind_Tbl(11).Detail_Flag     := 'YES';
  G_Ind_Tbl(11).Period_Shown    := 1;
  G_Ind_Tbl(11).Tab         := 1;
  G_Ind_Tbl(11).Drills    := 1;
  G_Ind_Tbl(11).User_Options  := 0;

  G_Ind_Tbl(12).Indicator := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_KPIS_B','INDICATOR');
  G_Ind_Tbl(12).Csf   := 0;
  G_Ind_Tbl(12).Group_R   := 3;
  G_Ind_Tbl(12).Type    := 1;
  G_Ind_Tbl(12).Config    := 3;
  G_Ind_Tbl(12).Periodicity     := 5;
  G_Ind_Tbl(12).Name    := 'Profit and Loss Statement';
  G_Ind_Tbl(12).Help    := 'Indicator Help';
  G_Ind_Tbl(12).Options   := 9;
  G_Ind_Tbl(12).Detail_Flag     := 'YES';
  G_Ind_Tbl(12).Period_Shown    := 1;
  G_Ind_Tbl(12).Tab         := 2;
  G_Ind_Tbl(12).Drills    := 3;
  G_Ind_Tbl(12).User_Options  := 5;

  -- Define variables

  --G_Var_Tbl(8).Code := 'LOCK_INDICATOR';  G_Var_Tbl(8).Value := 1;
  G_Var_Tbl(0).Code := 'LOCK_INDICATOR';  G_Var_Tbl(0).Value := 1;

  -- Define Calculation options

  G_Cal_Tbl(0).Calculation   := 0;    G_Cal_Tbl(0).EV0     := 2;
  G_Cal_Tbl(1).Calculation   := 1;    G_Cal_Tbl(1).EV0     := 2;
  G_Cal_Tbl(2).Calculation   := 2;    G_Cal_Tbl(2).EV0     := 2;
  G_Cal_Tbl(3).Calculation   := 3;    G_Cal_Tbl(3).EV0     := 0;
  G_Cal_Tbl(4).Calculation   := 4;    G_Cal_Tbl(4).EV0     := 0;
  G_Cal_Tbl(5).Calculation   := 5;    G_Cal_Tbl(5).EV0     := 2;
  G_Cal_Tbl(6).Calculation   := 6;    G_Cal_Tbl(6).EV0     := 0;
  G_Cal_Tbl(7).Calculation   := 7;    G_Cal_Tbl(7).EV0     := 0;
  G_Cal_Tbl(8).Calculation   := 8;    G_Cal_Tbl(8).EV0     := 0;
  G_Cal_Tbl(9).Calculation   := 9;    G_Cal_Tbl(9).EV0     := 0;
  G_Cal_Tbl(10).Calculation  := 10;   G_Cal_Tbl(10).EV0    := 0;
  G_Cal_Tbl(11).Calculation  := 20;   G_Cal_Tbl(11).EV0    := 0;

  G_Period_Tbl(0).Order_r        := 0;
  G_Period_Tbl(0).Period_Type    := 5;
  G_Period_Tbl(0).Prev_Year      := 0;
  G_Period_Tbl(0).Num_Years      := 0;
  G_Period_Tbl(0).Viewport_flag  := 0;
  G_Period_Tbl(0).Viewport_Size  := 0;

  G_Period_Tbl(1).Order_r          := 0;
  G_Period_Tbl(1).Period_Type      := 1;
  G_Period_Tbl(1).Prev_Year        := 1;
  G_Period_Tbl(1).Num_Years        := 2;
  G_Period_Tbl(1).Viewport_flag    := 1;
  G_Period_Tbl(1).Viewport_Size    := 2;

  -- define Drill relation

  G_Drill_Tbl(0).Dim_level_index:= 0;
  G_Drill_Tbl(0).Table_Name   := 'XXX';
  G_Drill_Tbl(0).Filter_Val := NULL;
  G_Drill_Tbl(0).Default_val  := 'T';
  G_Drill_Tbl(0).Default_Type := 0;
  G_Drill_Tbl(0).Value_Order  := 0;
  G_Drill_Tbl(0).Comp_Order   := 0;
  G_Drill_Tbl(0).Level_pk_col := 'XXX';
  G_Drill_Tbl(0).Parent   := NULL;
  G_Drill_Tbl(0).Parent_Rel := 'XXX';
  G_Drill_Tbl(0).Table_Rel  := NULL;
  G_Drill_Tbl(0).Parent2  := NULL;
  G_Drill_Tbl(0).Parent_Rel2    := 'REL';
  G_Drill_Tbl(0).Status   := 0;
  G_Drill_Tbl(0).Position   := 0;
  G_Drill_Tbl(0).Total0   := NULL;
  G_Drill_Tbl(0).Ev0    := 0;
  G_Drill_Tbl(0).Ev1d   := 0;
  G_Drill_Tbl(0).Total    := 'T';
  G_Drill_Tbl(0).Comp         := 'C';
  G_Drill_Tbl(0).name   := 'XXX';
  G_Drill_Tbl(0).Help   := 'XXX';
  G_Drill_Tbl(0).dim_group_id   := 0;
  G_Drill_Tbl(0).dim_group_idx  := 0;
  G_Drill_Tbl(0).dim_level_id := 0;
  G_Drill_Tbl(0).level_display  := 0;
  G_Drill_Tbl(0).Level_View_Name := 'XXX';

  G_Drill_Tbl(1).Dim_level_index:= 0;
  G_Drill_Tbl(1).Table_Name   := 'BSC_D_TYPE_OF_ACCOUNT';
  G_Drill_Tbl(1).Filter_Val := 0;
  G_Drill_Tbl(1).Default_val  := 'T';
  G_Drill_Tbl(1).Default_Type := 0;
  G_Drill_Tbl(1).Value_Order  := 2;
  G_Drill_Tbl(1).Comp_Order   := 0;
  G_Drill_Tbl(1).Level_pk_col := 'TYP_OF_ACC_CODE';
  G_Drill_Tbl(1).Parent   := NULL;
  G_Drill_Tbl(1).Parent_Rel := NULL;
  G_Drill_Tbl(1).Table_Rel  := NULL;
  G_Drill_Tbl(1).Parent2  := NULL;
  G_Drill_Tbl(1).Parent_Rel2    := NULL;
  G_Drill_Tbl(1).Status   := 2;
  G_Drill_Tbl(1).Position   := 2;
  G_Drill_Tbl(1).Total0   := 0;
  G_Drill_Tbl(1).Ev0    := 2;
  G_Drill_Tbl(1).Ev1d   := 2;
  G_Drill_Tbl(1).Total    := 'ALL';
  G_Drill_Tbl(1).Comp         := 'C';
  G_Drill_Tbl(1).name   := 'Account Type';
  G_Drill_Tbl(1).Help   := 'Account Types';
  G_Drill_Tbl(1).dim_group_id   := 3;
  G_Drill_Tbl(1).dim_group_idx  := 1;
  G_Drill_Tbl(1).dim_level_id   := 2;
  G_Drill_Tbl(1).level_display  := 0;
  G_Drill_Tbl(1).Level_View_Name := 'BSC_D_2_VL';

  G_Drill_Tbl(2).Dim_level_index:= 1;
  G_Drill_Tbl(2).Table_Name   := 'BSC_D_ACCOUNT';
  G_Drill_Tbl(2).Filter_Val := 0;
  G_Drill_Tbl(2).Default_val  := 'C';
  G_Drill_Tbl(2).Default_Type := 0;
  G_Drill_Tbl(2).Value_Order  := 1;
  G_Drill_Tbl(2).Comp_Order   := 0;
  G_Drill_Tbl(2).Level_pk_col := 'ACCOUNT_CODE';
  G_Drill_Tbl(2).Parent   := 0;
  G_Drill_Tbl(2).Parent_Rel := 'TYP_OF_ACC_CODE';
  G_Drill_Tbl(2).Table_Rel  := NULL;
  G_Drill_Tbl(2).Parent2  := NULL;
  G_Drill_Tbl(2).Parent_Rel2    := NULL;
  G_Drill_Tbl(2).Status   := 2;
  G_Drill_Tbl(2).Position   := 2;
  G_Drill_Tbl(2).Total0   := 0;
  G_Drill_Tbl(2).Ev0    := 2;
  G_Drill_Tbl(2).Ev1d   := 2;
  G_Drill_Tbl(2).Total    := 'ALL';
  G_Drill_Tbl(2).Comp         := 'COMPARISON';
  G_Drill_Tbl(2).name   := 'Account';
  G_Drill_Tbl(2).Help   := 'Accounts';
  G_Drill_Tbl(2).dim_group_id   := 1;
  G_Drill_Tbl(2).dim_group_idx  := 2;
  G_Drill_Tbl(2).dim_level_id   := 0;
  G_Drill_Tbl(2).level_display  := 2;
  G_Drill_Tbl(2).Level_View_Name := 'BSC_D_0_VL';

  G_Drill_Tbl(3).Dim_level_index:= 2;
  G_Drill_Tbl(3).Table_Name   := 'BSC_D_SUBACCOUNT';
  G_Drill_Tbl(3).Filter_Val := 0;
  G_Drill_Tbl(3).Default_val  := 'T';
  G_Drill_Tbl(3).Default_Type := 0;
  G_Drill_Tbl(3).Value_Order  := 0;
  G_Drill_Tbl(3).Comp_Order   := 0;
  G_Drill_Tbl(3).Level_pk_col := 'SUBACCOUNT_CODE';
  G_Drill_Tbl(3).Parent   := 1;
  G_Drill_Tbl(3).Parent_Rel := 'ACCOUNT_CODE';
  G_Drill_Tbl(3).Table_Rel  := NULL;
  G_Drill_Tbl(3).Parent2  := NULL;
  G_Drill_Tbl(3).Parent_Rel2    := NULL;
  G_Drill_Tbl(3).Status   := 2;
  G_Drill_Tbl(3).Position   := 0;
  G_Drill_Tbl(3).Total0   := 0;
  G_Drill_Tbl(3).Ev0    := 2;
  G_Drill_Tbl(3).Ev1d   := 2;
  G_Drill_Tbl(3).Total    := 'ALL';
  G_Drill_Tbl(3).Comp         := 'COMPARISON';
  G_Drill_Tbl(3).name   := 'SubAccount';
  G_Drill_Tbl(3).Help   := 'SubAccount';
  G_Drill_Tbl(3).dim_group_id   := 2;
  G_Drill_Tbl(3).dim_group_idx  := 3;
  G_Drill_Tbl(3).dim_level_id   := 1;
  G_Drill_Tbl(3).level_display  := 0;
  G_Drill_Tbl(3).Level_View_Name := 'BSC_D_1_VL';

  -- Define User Options
  l_user_options(0) :=3;
  l_user_options(1) :=4;
  l_user_options(2) :=5;
  l_user_options(3) :=6;
  l_user_options(4) :=7;


  -- Check records in BSC_SYS_PERIODS_TL for apps
  Select count(*)
  Into   l_count
  From   BSC_SYS_PERIODS_TL;
  if (l_count = 0) then
  INSERT INTO BSC_SYS_PERIODS_TL
  ( YEAR,
    PERIODICITY_ID,
    PERIOD_ID,
    MONTH,
    LANGUAGE,
    SOURCE_LANG,
    NAME,
    SHORT_NAME)
  ( SELECT
    CA.YEAR,
    CA.PERIODICITY_ID,
    CA.PERIOD_ID,
    1 AS MONTH,
    L.LANGUAGE_CODE AS LANGUAGE,
    L.LANGUAGE_CODE AS SOURCE_LANG,
    CA.NAME,
    NULL AS SHORT_NAME
  FROM
  (SELECT
    C.YEAR AS YEAR,
    2 AS PERIODICITY_ID,
    C.SEMESTER AS PERIOD_ID,
    C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
  FROM
    BSC_DB_CALENDAR C,
    BSC_DB_CALENDAR C2
  WHERE
    C.YEAR = C2.YEAR AND
    C.SEMESTER = C2.SEMESTER AND
    TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
       MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
     FROM
       BSC_DB_CALENDAR C1
     WHERE
       C1.YEAR = C.YEAR AND
       C1.SEMESTER = C.SEMESTER
     ) AND
    TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
      MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
    FROM
      BSC_DB_CALENDAR C1
    WHERE
      C1.YEAR = C2.YEAR AND
      C1.SEMESTER = C2.SEMESTER)
    UNION
  SELECT
    C.YEAR AS YEAR,
    3 AS PERIODICITY_ID,
    C.QUARTER AS PERIOD_ID,
    C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
  FROM
    BSC_DB_CALENDAR C,
    BSC_DB_CALENDAR C2
  WHERE
    C.YEAR = C2.YEAR AND
    C.QUARTER = C2.QUARTER AND
    TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
    MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
  FROM
    BSC_DB_CALENDAR C1
  WHERE
    C1.YEAR = C.YEAR AND
    C1.QUARTER = C.QUARTER
  ) AND
    TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
      MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
    FROM
      BSC_DB_CALENDAR C1
    WHERE
      C1.YEAR = C2.YEAR AND
      C1.QUARTER = C2.QUARTER)
    UNION
    SELECT
    C.YEAR AS YEAR,
    4 AS PERIODICITY_ID,
    C.BIMESTER AS PERIOD_ID,
    C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
  FROM
    BSC_DB_CALENDAR C,
    BSC_DB_CALENDAR C2
  WHERE
    C.YEAR = C2.YEAR AND
    C.BIMESTER = C2.BIMESTER AND
    TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
      MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
    FROM
      BSC_DB_CALENDAR C1
    WHERE
      C1.YEAR = C.YEAR AND
      C1.BIMESTER = C.BIMESTER
    ) AND
    TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
    (SELECT
      MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
    FROM
      BSC_DB_CALENDAR C1
    WHERE
      C1.YEAR = C2.YEAR AND
      C1.BIMESTER = C2.BIMESTER)
    UNION
    SELECT
      C.YEAR AS YEAR,
      5 AS PERIODICITY_ID,
      C.MONTH AS PERIOD_ID,
      TO_CHAR(C.CALENDAR_MONTH) AS NAME
    FROM
      BSC_DB_CALENDAR C
    GROUP BY
        C.YEAR,
        C.MONTH,
        C.CALENDAR_MONTH
  UNION
  SELECT
    C.YEAR AS YEAR,
    7 AS PERIODICITY_ID,
    C.WEEK52 AS PERIOD_ID,
    C.CALENDAR_MONTH||';'||C.CALENDAR_DAY AS NAME
  FROM
    BSC_DB_CALENDAR C
    WHERE
      TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
      (SELECT
        MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
      FROM
        BSC_DB_CALENDAR C1
      WHERE
        C1.YEAR = C.YEAR AND
        C1.WEEK52 = C.WEEK52)
  UNION
  SELECT
    C.YEAR AS YEAR,
    9 AS PERIODICITY_ID,
    C.DAY365 AS PERIOD_ID,
    C.CALENDAR_MONTH||';'||C.CALENDAR_DAY AS NAME
  FROM
    BSC_DB_CALENDAR C) CA,
    FND_LANGUAGES L
  WHERE
  L.INSTALLED_FLAG <> 'D');
  end if;
  -- finish inserting BSC_SYS_PERIODS_TL

  -- create dimensions
--DBMS_OUTPUT.PUT_LINE('create dimensions------------------------------');
  if (NOT BSC_DIM_TPLATE.Create_Dimensions) then
  l_debug_stmt :=  bsc_apps.get_message('BSC_ERROR_CREATE_DIM');
  Raise BSC_ERROR;
  end if;

  -- create analysis options
  --DBMS_OUTPUT.PUT_LINE('create analysis options------------------------------');

  if (NOT BSC_AOP_TPLATE.Create_Analysis_Options) then
  l_debug_stmt :=  bsc_apps.get_message('BSC_ERROR_CREATE_AO');
  Raise BSC_ERROR;
  end if;

--DBMS_OUTPUT.PUT_LINE('end create analysis options------------------------------');
  --UPDATE BSC_SYS_INIT

  Update BSC_SYS_INIT
  Set    PROPERTY_VALUE = '1',LAST_UPDATED_BY =2,LAST_UPDATE_DATE=SYSDATE
  Where  PROPERTY_CODE = 'SHOW_TABS';

 -- Defining TAB ....

  For i_system In 0 .. (G_num_of_tabs -1)
  Loop

    l_debug_stmt := 'Inserting BSC_TABS_B, i_system = ' ||
      to_char(i_system);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    Insert Into BSC_TABS_B(
  TAB_ID,KPI_MODEL,BSC_MODEL,
  CROSS_MODEL,DEFAULT_MODEL,
  ZOOM_FACTOR,
  CREATED_BY,CREATION_DATE,
  LAST_UPDATED_BY,LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN
  )
    Values (
  G_Tab_Tbl(i_system).code,
  1,
  0,
  0,
  0,
  0.8227025,
  0,SYSDATE,
  0,SYSDATE,
  0
  );

    l_debug_stmt := 'Inserting BSC_TABS_TL, i_system = ' ||
      to_char(i_system);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    l_sql_stmt := 'INSERT INTO BSC_TABS_TL '||
      ' (TAB_ID,LANGUAGE,SOURCE_LANG,NAME,HELP) ' ||
      'SELECT '||
        G_Tab_Tbl(i_system).Code||' AS TAB_ID, '||
        'FEM.LANGUAGE AS LANGUAGE, '||
        'FEM.SOURCE_LANG AS SOURCE_LANG, '||
        'SUBSTR(FEM.MEANING,1,35) AS NAME, '||
        'SUBSTR(FEM.MEANING,1,40)||'' ''||SUBSTR(FEM_DESC.MEANING,1,40) AS HELP '||
      'FROM '||
        BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM, '||
              BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_DESC '||
      'WHERE '||
        'FEM.LOOKUP_TYPE = ''BSC_TPLATE_TAB_NAME'' AND '||
              'FEM.LOOKUP_CODE = :1 AND '||
              'FEM_DESC.LOOKUP_TYPE = ''BSC_UI_COMMON'' AND '||
              'FEM_DESC.LOOKUP_CODE = ''DESCRIPTION'' AND '||
                    'FEM.LANGUAGE = FEM_DESC.LANGUAGE';

    EXECUTE IMMEDIATE l_sql_stmt USING G_Tab_Tbl(i_system).Code; --literals bug fix

    l_debug_stmt := 'Inserting BSC_TAB_CSF_B, i_system = ' ||
      to_char(i_system);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);


    Insert Into BSC_TAB_CSF_B(
  TAB_ID,
  CSF_ID,
  CSF_TYPE,
  INTERMEDIATE_FLAG
  )
    Values (
  G_Tab_Tbl(i_system).Code,
  G_Csf_Tbl(0).Code,
  G_Csf_Tbl(0).Type,
  G_Csf_Tbl(0).Inter_Flag
  );

    l_debug_stmt := 'Inserting BSC_TAB_CSF_TL, i_system = ' ||
      to_char(i_system);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    l_sql_stmt := 'INSERT INTO BSC_TAB_CSF_TL '||
      ' (TAB_ID,CSF_ID,LANGUAGE,SOURCE_LANG,NAME,HELP) ' ||
      'SELECT '||
        G_Tab_Tbl(i_system).Code||' AS TAB_ID, '||
        G_Csf_Tbl(0).Code||' AS CSF_ID, '||
        'FEM.LANGUAGE AS LANGUAGE, '||
        'FEM.SOURCE_LANG AS SOURCE_LANG, '||
        'SUBSTR(FEM.MEANING,1,30) AS NAME, '||
        'SUBSTR(FEM.MEANING,1,80) AS HELP '||
      'FROM '||
        BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM '||
      'WHERE '||
        'FEM.LOOKUP_TYPE = ''BSC_TPLATE_TAB_CSF'' AND '||
            'FEM.LOOKUP_CODE = :1 ';

    EXECUTE IMMEDIATE l_sql_stmt USING G_Csf_Tbl(0).Code; --literals bug fix

    --DBMS_OUTPUT.PUT_LINE('Looping j_group  ...');

    For j_group In 0 .. (G_Tab_Tbl(i_system).n_groups -1)
    Loop

  if (i_system = 0) then
      if (j_group = 0) then
    l_top_c   := 1037;  l_left_r  := 2001;
    l_height  := 528; l_width   := 2283;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 0;
    l_gl_top_c    := 2563;  l_gl_left_r   := 3858;
    l_gl_length   := 1378;
            elsif (j_group = 1) then
    l_top_c   := 2308;  l_left_r  := 1978;
    l_height  := 528; l_width   := 2283;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 1;
    l_gl_top_c    := 1270;  l_gl_left_r   := 3656;
    l_gl_length   := 1063;
            elsif (j_group = 2) then
    l_top_c   := 3694;  l_left_r  := 1981;
    l_height  := 512; l_width   := 2283;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 2;
    l_gl_top_c    := 3956;  l_gl_left_r   := 3553;
    l_gl_length   := 1168;
            elsif (j_group = 3) then
    l_top_c   := 2328;  l_left_r  := 6886;
    l_height  := 546; l_width   := 2088;
    --
    l_gl_type     := 'V'; l_gl_index_r  := 0;
    l_gl_top_c    := 1280;  l_gl_left_r   := 4696;
    l_gl_length   := 2692;
            end if;
        elsif (i_system = 1) then
      if (j_group = 0) then
    l_top_c   := 798; l_left_r  := 2006;
    l_height  := 516; l_width   := 2408;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 0;
    l_gl_top_c    := 978; l_gl_left_r   := 3923;
    l_gl_length   := 838;
            elsif (j_group = 1) then
    l_top_c   := 3531;  l_left_r  := 1981;
    l_height  := 546; l_width   := 2418;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 1;
    l_gl_top_c    := 2488;  l_gl_left_r   := 4038;
    l_gl_length   := 1228;
            elsif (j_group = 2) then
    l_top_c   := 2164;  l_left_r  := 2008;
    l_height  := 531; l_width   := 2418;
    --
    l_gl_type     := 'H'; l_gl_index_r  := 2;
    l_gl_top_c    := 3813;  l_gl_left_r   := 3941;
    l_gl_length   := 808;
            elsif (j_group = 3) then
    l_top_c   := 2163;  l_left_r  := 6858;
    l_height  := 546; l_width   := 2223;
    --
    l_gl_type     := 'V'; l_gl_index_r  := 0;
    l_gl_top_c    := 978; l_gl_left_r   := 4728;
    l_gl_length   := 2861;
            end if;
        elsif (i_system = 2) then
      if (j_group = 0) then
    l_top_c   := 827; l_left_r  := 1871;
    l_height  := 909; l_width   := 2088;
    --
    l_gl_type     := NULL;  l_gl_index_r  := 0;
    l_gl_top_c    := 0; l_gl_left_r   := 0;
    l_gl_length   := 0;
            end if;
        end if;

        if (i_system = 2) and (j_group = 0) then
            l_group_ind := 3;
        else
            l_group_ind := j_group;
        end if;

        l_debug_stmt := 'Inserting BSC_TAB_IND_GROUPS_B, i_system=' ||
    to_char(i_system) || ', j_group=' || to_char(j_group) ||
                ', l_group_ind=' || to_char(l_group_ind);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

        Insert Into BSC_TAB_IND_GROUPS_B(
    TAB_ID,
    CSF_ID,
    IND_GROUP_ID,
    GROUP_TYPE,
    NAME_POSITION,
    NAME_JUSTIFICATION,
    LEFT_POSITION,
    TOP_POSITION,
    WIDTH,
    HEIGHT)
  Values (
    i_system,     -- system_c
    0,
      G_Group_Tbl(l_group_ind).Code,  -- code
    0,
    1,
    0,
    l_left_r,     -- left_r
    l_top_c,      -- top_c
    l_width,      -- width
    l_height      -- height
    );

        l_debug_stmt := 'Inserting BSC_TAB_IND_GROUPS_TL, i_system=' ||
    to_char(i_system) || ', j_group=' || to_char(j_group) ||
                ', l_group_ind=' || to_char(l_group_ind);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);


        l_sql_stmt := 'INSERT INTO BSC_TAB_IND_GROUPS_TL '||
      ' (TAB_ID,CSF_ID,IND_GROUP_ID,LANGUAGE,SOURCE_LANG,NAME,HELP) ' ||
      'SELECT '||
        i_system||' AS TAB_ID, '||
        '0 AS CSF_ID, '||
        G_Group_Tbl(l_group_ind).Code||' AS IND_GROUP_ID, '||
        'FEM.LANGUAGE AS LANGUAGE, '||
        'FEM.SOURCE_LANG AS SOURCE_LANG, '||
        'SUBSTR(FEM.MEANING,1,50) AS NAME, '||
        'SUBSTR(FEM.MEANING,1,80) AS HELP '||
      'FROM '||
        BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM '||
      'WHERE '||
        'FEM.LOOKUP_TYPE = ''BSC_TPLATE_TAB_IND_GROUPS'' AND '||
              'FEM.LOOKUP_CODE = :1 ';

      EXECUTE IMMEDIATE l_sql_stmt USING G_Group_Tbl(l_group_ind).Code; --literals bug fix

           -- insert lines among groups, if tab has only one group then
        -- there is no line.

  if (G_Tab_Tbl(i_system).n_groups <> 1) then

            l_debug_stmt := 'Inserting BSC_SYS_LINES, i_system=' ||
    to_char(i_system) || ', j_group=' || to_char(j_group);
      --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

      Insert Into BSC_SYS_LINES (
    SOURCE_TYPE,
    SOURCE_CODE,
    LINE_TYPE,
    LINE_ID,
    LEFT_POSITION,
    TOP_POSITION,
    LENGTH,
    ARROW)
      Values (
    1,
    i_system,   -- system_c
    l_gl_type,    -- type
    l_gl_index_r,   -- index_r
    l_gl_left_r,    -- left_r
    l_gl_top_c,   -- top_c
    l_gl_length,    -- length
    NULL      -- arrow
    );

        end if;
    End loop; -- group loop

  End Loop; -- system loop

  --DBMS_OUTPUT.PUT_LINE('Looping k_indicator  ...');

  For k_indicator In 0 .. (G_num_of_indicators -1)
  Loop

    l_debug_stmt := 'Inserting BSC_KPIS_B, indicator=' ||
    to_char(G_Ind_Tbl(k_indicator).Indicator) ||
    ', k_indicator=' || to_char(k_indicator);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    Insert Into BSC_KPIS_B (
  INDICATOR,
  CSF_ID,
  IND_GROUP_ID,
  DISP_ORDER,
  PROTOTYPE_FLAG ,
  INDICATOR_TYPE ,
  CONFIG_TYPE ,
  PERIODICITY_ID,
  BM_GROUP_ID,
  APPLY_COLOR_FLAG,
  PROTOTYPE_COLOR,
  SHARE_FLAG,
  PUBLISH_FLAG,
  CREATED_BY,CREATION_DATE,
  LAST_UPDATED_BY,LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  EDW_FLAG,
  CALENDAR_ID,
  COLOR_ROLLUP_TYPE,
  PROTOTYPE_COLOR_ID,
  WEIGHTED_COLOR_METHOD
  )
    Values (
  G_Ind_Tbl(k_indicator).Indicator, -- indicator
  G_Ind_Tbl(k_indicator).Csf,   -- intermediate_r
  G_Ind_Tbl(k_indicator).Group_r,   -- group_r
  0,          -- position
  1,          -- prototype
  G_Ind_Tbl(k_indicator).type,    -- indicator_type
  G_Ind_Tbl(k_indicator).config,    -- configuration
  G_Ind_Tbl(k_indicator).Periodicity,   -- panel_periodicity
  1,
  1,
  'G',
  1,
  1,
  0,SYSDATE,
  0,SYSDATE,
  0,
  0,
  1,
  'DEFAULT_KPI',
  24865,
  NULL
  );

    l_debug_stmt := 'Inserting BSC_KPI_DEFAULTS_B, indicator=' ||
    to_char(G_Ind_Tbl(k_indicator).Indicator) ||
    ', k_indicator=' || to_char(k_indicator);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

      if (G_Ind_Tbl(k_indicator).Indicator = 3013) then
      l_opt_caption := 'Amount';
      else
      l_opt_caption := 'Option 0';
      end if;

    l_sql_defaults_b:= 'Insert Into BSC_KPI_DEFAULTS_B ('||
        'TAB_ID,INDICATOR,FORMAT_MASK,COLOR_METHOD,'||
        'DIM_SET_ID,DIM_LEVEL1_VALUE,DIM_LEVEL2_VALUE,DIM_LEVEL3_VALUE,DIM_LEVEL4_VALUE,'||
        'DIM_LEVEL5_VALUE,DIM_LEVEL6_VALUE,DIM_LEVEL7_VALUE,DIM_LEVEL8_VALUE,'||
        'LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)'||
        'Values (:1,:2,'||
        '''#,###,##0'''||
        ',1,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,0,SYSDATE,0,NULL)';
    EXECUTE IMMEDIATE l_sql_defaults_b USING G_Ind_Tbl(k_indicator).Tab,G_Ind_Tbl(k_indicator).Indicator;

    l_debug_stmt := 'Inserting BSC_KPI_DEFAULTS_TL, indicator=' ||
    to_char(G_Ind_Tbl(k_indicator).Indicator) ||
    ', k_indicator=' || to_char(k_indicator);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    if (G_Ind_Tbl(k_indicator).Indicator <> 3013) then

   l_sql_stmt := 'INSERT INTO BSC_KPI_DEFAULTS_TL
  (TAB_ID,INDICATOR,LANGUAGE,SOURCE_LANG, ANALYSIS_OPTION0_NAME, ANALYSIS_OPTION1_NAME,
           ANALYSIS_OPTION2_NAME,PERIOD_NAME,SERIES_NAME,
     DIM_LEVEL1_NAME,DIM_LEVEL2_NAME,DIM_LEVEL3_NAME,DIM_LEVEL4_NAME,
     DIM_LEVEL5_NAME,DIM_LEVEL6_NAME,DIM_LEVEL7_NAME,DIM_LEVEL8_NAME,
     DIM_LEVEL1_TEXT,DIM_LEVEL2_TEXT,DIM_LEVEL3_TEXT,DIM_LEVEL4_TEXT,
     DIM_LEVEL5_TEXT,DIM_LEVEL6_TEXT,DIM_LEVEL7_TEXT,DIM_LEVEL8_TEXT)
  SELECT '||G_Ind_Tbl(k_indicator).Tab||' AS TAB_ID,'
    ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
    FEM.LANGUAGE AS LANGUAGE,
    FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,30) AS ANALYSIS_OPTION0_NAME,
    NULL AS ANALYSIS_OPTION1_NAME,
    NULL AS ANALYSIS_OPTION2_NAME,
    NULL AS PERIOD_NAME,
    SUBSTR(FEM_DS.MEANING,1,30) AS SERIES_NAME,
    NULL AS DIM_LEVEL1_NAME,NULL AS DIM_LEVEL2_NAME,NULL AS DIM_LEVEL3_NAME,NULL AS DIM_LEVEL4_NAME,
    NULL AS DIM_LEVEL5_NAME,NULL AS DIM_LEVEL6_NAME,NULL AS DIM_LEVEL7_NAME,NULL AS DIM_LEVEL8_NAME,
    NULL AS DIM_LEVEL1_TEXT,NULL AS DIM_LEVEL2_TEXT,NULL AS DIM_LEVEL3_TEXT,NULL AS DIM_LEVEL4_TEXT,
    NULL AS DIM_LEVEL5_TEXT,NULL AS DIM_LEVEL6_TEXT,NULL AS DIM_LEVEL7_TEXT,NULL AS DIM_LEVEL8_TEXT
  FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM, '
        ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_DS
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_AO_NAMES'' AND
        FEM.LOOKUP_CODE = ''0'' AND
        FEM_DS.LOOKUP_TYPE =''BSC_TPLATE_TAB_DSERIES_NAME'' AND
        FEM_DS.LOOKUP_CODE = ''0'' AND
              FEM.LANGUAGE = FEM_DS.LANGUAGE';

  l_debug_stmt := SUBSTR(l_sql_stmt,1,2000);
  l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);

    else

  l_sql_stmt := ' INSERT INTO BSC_KPI_DEFAULTS_TL
    (TAB_ID,INDICATOR,LANGUAGE,SOURCE_LANG,
     ANALYSIS_OPTION0_NAME,ANALYSIS_OPTION1_NAME,
           ANALYSIS_OPTION2_NAME,
                 PERIOD_NAME,SERIES_NAME,
     DIM_LEVEL1_NAME,DIM_LEVEL2_NAME,DIM_LEVEL3_NAME,DIM_LEVEL4_NAME,
     DIM_LEVEL5_NAME,DIM_LEVEL6_NAME,DIM_LEVEL7_NAME,DIM_LEVEL8_NAME,
     DIM_LEVEL1_TEXT,DIM_LEVEL2_TEXT,DIM_LEVEL3_TEXT,DIM_LEVEL4_TEXT,
     DIM_LEVEL5_TEXT,DIM_LEVEL6_TEXT,DIM_LEVEL7_TEXT,DIM_LEVEL8_TEXT)
  SELECT '
    ||G_Ind_Tbl(k_indicator).Tab||' AS TAB_ID,'
    ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
    FEM.LANGUAGE AS LANGUAGE,
    FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,30) AS ANALYSIS_OPTION0_NAME,
    NULL AS ANALYSIS_OPTION1_NAME,
    NULL AS ANALYSIS_OPTION2_NAME,
    NULL AS PERIOD_NAME,
    SUBSTR(FEM_DS.MEANING,1,30) AS SERIES_NAME,
    SUBSTR(FEM_ATYPE.MEANING,1,80) AS DIM_LEVEL1_NAME,
    SUBSTR(FEM_ACCOUNT.MEANING,1,80) AS DIM_LEVEL2_NAME,
    SUBSTR(FEM_SUBACCOUNT.MEANING,1,80) AS DIM_LEVEL3_NAME,NULL AS DIM_LEVEL4_NAME,
    NULL AS DIM_LEVEL5_NAME,NULL AS DIM_LEVEL6_NAME,NULL AS DIM_LEVEL7_NAME,NULL AS DIM_LEVEL8_NAME,
    NULL AS DIM_LEVEL1_TEXT,NULL AS DIM_LEVEL2_TEXT,NULL AS DIM_LEVEL3_TEXT,NULL AS DIM_LEVEL4_TEXT,
    NULL AS DIM_LEVEL5_TEXT,NULL AS DIM_LEVEL6_TEXT,NULL AS DIM_LEVEL7_TEXT,NULL AS DIM_LEVEL8_TEXT
  FROM    '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM, '
       ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_DS, '
     ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ATYPE, '
     ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ACCOUNT, '
     ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_SUBACCOUNT
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_AO_NAMES'' AND
        FEM.LOOKUP_CODE = ''1'' AND
        FEM_DS.LOOKUP_TYPE =''BSC_TPLATE_TAB_DSERIES_NAME'' AND
        FEM_DS.LOOKUP_CODE = ''0'' AND
        FEM_ATYPE.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_LEVEL_NAME'' AND
        FEM_ATYPE.LOOKUP_CODE = ''2'' AND
        FEM_ACCOUNT.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_LEVEL_NAME'' AND
        FEM_ACCOUNT.LOOKUP_CODE = ''0'' AND
        FEM_SUBACCOUNT.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_LEVEL_NAME'' AND
        FEM_SUBACCOUNT.LOOKUP_CODE = ''1'' AND
              FEM.LANGUAGE = FEM_DS.LANGUAGE AND
              FEM_DS.LANGUAGE = FEM_ATYPE.LANGUAGE AND
              FEM_ATYPE.LANGUAGE = FEM_ACCOUNT.LANGUAGE AND
              FEM_SUBACCOUNT.LANGUAGE = FEM_ACCOUNT.LANGUAGE';

  l_debug_stmt := SUBSTR(l_sql_stmt,1,2000);
  l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);

    end if;



    --DBMS_OUTPUT.PUT_LINE('Looping l_variable  ...');

    For l_variable In 0 .. (G_Ind_Tbl(k_indicator).Options -1)
    Loop

  l_debug_stmt := 'Inserting BSC_KPI_PROPERTIES, k_indicator=' ||
    to_char(k_indicator) ||
    ', l_variable=' || to_char(l_variable) ||
    ', PROPERTY_CODE=' || G_Var_Tbl(l_variable).Code ||
    ', PROPERTY_VALUE=' || to_char(G_Var_Tbl(l_variable).Value);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

  Insert Into BSC_KPI_PROPERTIES (
    INDICATOR,
    PROPERTY_CODE,
    PROPERTY_VALUE,
    SECONDARY_VALUE )
  Values (
    G_Ind_Tbl(k_indicator).Indicator,
    G_Var_Tbl(l_variable).code,   -- variable
      G_Var_Tbl(l_variable).Value,    -- value_r
    NULL          -- secondary_value
    );
    End loop;

    -- the Detail_Flag should be always set to 'YES'

    if (G_Ind_Tbl(k_indicator).Detail_Flag ='YES') then

  l_debug_stmt := 'Inserting BSC_KPIS_TL, k_indicator=' ||
    to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);


  l_sql_stmt := 'INSERT INTO BSC_KPIS_TL
    (INDICATOR,LANGUAGE,SOURCE_LANG,NAME,HELP)
  SELECT '||G_Ind_Tbl(k_indicator).Indicator|| ' AS INDICATOR,
    FEM.LANGUAGE AS LANGUAGE,FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,50) AS NAME,
    SUBSTR(FEM.MEANING,1,25)|| '' '' ||SUBSTR(FEM_DESC.MEANING,1,25) AS HELP
  FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM, '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_DESC
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_KPIS'' AND
        FEM.LOOKUP_CODE = :1 AND
        FEM_DESC.LOOKUP_TYPE = :2 AND
        FEM_DESC.LOOKUP_CODE = :3  AND
          FEM.LANGUAGE = FEM_DESC.LANGUAGE';

  l_debug_stmt := l_sql_stmt;

    EXECUTE IMMEDIATE l_sql_stmt USING to_char(G_Ind_Tbl(k_indicator).Indicator) ,'BSC_UI_COMMON', 'DESCRIPTION';

  l_debug_stmt := 'Inserting BSC_KPI_ANALYSIS_GROUPS, Indicator=' ||
      to_char(G_Ind_Tbl(k_indicator).Indicator) ||
      ', k_indicator=' || to_char(k_indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

        Insert Into BSC_KPI_ANALYSIS_GROUPS (
    INDICATOR,
    ANALYSIS_GROUP_ID,
    NUM_OF_OPTIONS,
    DEPENDENCY_FLAG,
    PARENT_ANALYSIS_ID,
    CHANGE_DIM_SET,
    DEFAULT_VALUE )
  Values (
    G_Ind_Tbl(k_indicator).Indicator,
    0,      -- analysis
    1,      -- number_of_options
    0,      -- dependency
    0,      -- parent
      NULL,     -- changes_drill
    0     -- default_value
    );

    l_sql := 'Insert Into BSC_KPI_CALCULATIONS '||
             '(INDICATOR, CALCULATION_ID, USER_LEVEL0,'||
             'USER_LEVEL1,USER_LEVEL1_DEFAULT, USER_LEVEL2,'||
             'USER_LEVEL2_DEFAULT, DEFAULT_VALUE ) values('||
             ':1,:2,:3,:4,null,null,null,0 )';

  For m_calculation In 0 .. (G_num_of_calculations - 1) Loop

      l_debug_stmt := 'Inserting BSC_KPI_CALCULATIONS' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', m_calculation=' || to_char(m_calculation) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
            --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);
        EXECUTE IMMEDIATE l_sql USING G_Ind_Tbl(k_indicator).Indicator,G_Cal_Tbl(m_calculation).Calculation,G_Cal_Tbl(m_calculation).EV0,G_Cal_Tbl(m_calculation).EV0;

  End loop; -- calculation loop
  -- Vertical Analysis for PL
        if (G_Ind_Tbl(k_indicator).Indicator = 3013) then
      Insert Into BSC_KPI_CALCULATIONS (
    INDICATOR,
    CALCULATION_ID,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT,
    DEFAULT_VALUE )
      Values (
    G_Ind_Tbl(k_indicator).Indicator,
    11, -- calculation
    2,    -- ev0
    2,    -- ev1
    NULL,         -- ev1d
    NULL,         -- ev2
    NULL,         -- ev2d
    0         -- value_r
    );
  end if;

        if (G_Ind_Tbl(k_indicator).Indicator = 3013) then
      l_data_code := 1;
        else
      l_data_code := -1;
        end if;

  SELECT bsc_kpi_measure_s.NEXTVAL INTO l_kpi_measure_id from dual;

  l_debug_stmt := 'Inserting BSC_KPI_ANALYSIS_MEASURES_B' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

  Insert Into BSC_KPI_ANALYSIS_MEASURES_B (
    INDICATOR,
    ANALYSIS_OPTION0,
    ANALYSIS_OPTION1,
    ANALYSIS_OPTION2,
    SERIES_ID,
    DATASET_ID,
    AXIS,
    SERIES_TYPE,
    STACK_SERIES_ID,
    BM_FLAG,
    BUDGET_FLAG,
    DEFAULT_VALUE,
    SERIES_COLOR,
    BM_COLOR,
    KPI_MEASURE_ID)
  Values (
    G_Ind_Tbl(k_indicator).Indicator,
    0,        -- analysis_option0
    0,    -- analysis_option1
    0,    -- analysis_option2
    0,    -- serie
    l_data_code,  -- data_code
    1,    -- axis
    1,    -- series_type
    NULL,   -- stack
    1,    -- reference
    1,    -- plan_series
    1,    -- default_r,
    10053171,
    10053171,
    l_kpi_measure_id
    );

  l_debug_stmt := 'Inserting BSC_KPI_ANALYSIS_MEASURES_TL' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

  l_sql_stmt := 'INSERT INTO  BSC_KPI_ANALYSIS_MEASURES_TL
   (INDICATOR,ANALYSIS_OPTION0,ANALYSIS_OPTION1,ANALYSIS_OPTION2,
    SERIES_ID,LANGUAGE,SOURCE_LANG,NAME,HELP)
  SELECT '
    ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
    0 AS ANALYSIS_OPTION0,
    0 AS ANALYSIS_OPTION1,
    0 AS ANALYSIS_OPTION2,
    0 AS SERIES_ID,
    FEM.LANGUAGE AS LANGUAGE,
    FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,20) AS NAME,
    SUBSTR(FEM.MEANING,1,80) AS HELP
  FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_DSERIES_NAME'' AND
        FEM.LOOKUP_CODE = ''0''';

    l_debug_stmt := l_sql_stmt;
    l_cursor := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
    l_ignore := DBMS_SQL.Execute(l_cursor);
    DBMS_SQL.Close_Cursor(l_cursor);

  l_debug_stmt := 'Inserting BSC_KPI_MEASURE_PROPS' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);

  -- Insert KPI Measure Properties
  BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props (
    p_commit          => FND_API.G_FALSE
  , p_objective_id    => G_Ind_Tbl(k_indicator).Indicator
  , p_kpi_measure_id  => l_kpi_measure_id
  , p_cascade_shared  => FALSE
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_debug_stmt := 'Inserting BSC_COLOR_TYPE_PROPS and BSC_COLOR_RANGES' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);

  -- Insert KPI Measure Thresholds
  IF (G_Ind_Tbl(k_indicator).config = 3) THEN
    BSC_COLOR_RANGES_PUB.create_pl_def_clr_prop_ranges (
      p_commit          => FND_API.G_FALSE
    , p_objective_id    => G_Ind_Tbl(k_indicator).Indicator
    , p_kpi_measure_id  => l_kpi_measure_id
    , p_cascade_shared  => FALSE
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
    );
  ELSE
    BSC_COLOR_RANGES_PUB.create_def_color_prop_ranges (
      p_commit          => FND_API.G_FALSE
    , p_objective_id    => G_Ind_Tbl(k_indicator).Indicator
    , p_kpi_measure_id  => l_kpi_measure_id
    , p_cascade_shared  => FALSE
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );
  END IF;
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_debug_stmt := 'Inserting BSC_KPI_DIM_SETS_TL' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);


--2828685 ADD WHO COLUMNS
        l_sql_stmt := 'INSERT INTO BSC_KPI_DIM_SETS_TL
  (INDICATOR,DIM_SET_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE)
  SELECT '||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
    0 AS DIM_SET_ID,
    FEM.LANGUAGE AS LANGUAGE,
    FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,20) AS NAME,
    1,SYSDATE,1,SYSDATE
  FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_SET_NAME'' AND
        FEM.LOOKUP_CODE = ''0''';

      l_debug_stmt := l_sql_stmt;
      l_cursor := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
      l_ignore := DBMS_SQL.Execute(l_cursor);
      DBMS_SQL.Close_Cursor(l_cursor);

  For i_drill In 0 .. (G_Ind_Tbl(k_indicator).drills - 1)
      Loop
          if (G_Ind_Tbl(k_indicator).Indicator = 3013) then
        l_drill_ind := i_drill + 1;
          else
        l_drill_ind := 0;
          end if;

    l_debug_stmt :=  'Inserting BSC_KPI_DIM_LEVELS_B' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

          Insert Into BSC_KPI_DIM_LEVELS_B (
    INDICATOR,
    DIM_SET_ID,
    DIM_LEVEL_INDEX,
    LEVEL_TABLE_NAME,
    LEVEL_VIEW_NAME,
    FILTER_COLUMN,
    FILTER_VALUE,
    DEFAULT_VALUE,
    DEFAULT_TYPE,
    VALUE_ORDER_BY,
    COMP_ORDER_BY,
    LEVEL_PK_COL,
    PARENT_LEVEL_INDEX,
    PARENT_LEVEL_REL,
    TABLE_RELATION,
    PARENT_LEVEL_INDEX2,
    PARENT_LEVEL_REL2,
    STATUS,
    PARENT_IN_TOTAL,
    POSITION,
    TOTAL0,
    LEVEL_DISPLAY,
    NO_ITEMS,
    DEFAULT_KEY_VALUE,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT
    )
    Values (
    G_Ind_Tbl(k_indicator).Indicator,
    0,          -- configuration
    G_Drill_Tbl(l_drill_ind).Dim_level_index,   -- drill
    G_Drill_Tbl(l_drill_ind).Table_Name,  -- master_T
    G_Drill_Tbl(l_drill_ind).Level_View_Name,-- Level View Name
    NULL,         -- condition_field
    G_Drill_Tbl(l_drill_ind).Filter_Val,  -- condition_value
    G_Drill_Tbl(l_drill_ind).Default_val, -- init
    G_Drill_Tbl(l_drill_ind).Default_type,  -- init_type
    G_Drill_Tbl(l_drill_ind).Value_Order, -- order_r
    G_Drill_Tbl(l_drill_ind).Comp_Order,  -- order_r
    G_Drill_Tbl(l_drill_ind).Level_pk_col,  -- field_n
    G_Drill_Tbl(l_drill_ind).Parent,  -- parent
    G_Drill_Tbl(l_drill_ind).Parent_Rel,  -- parent_relation
    G_Drill_Tbl(l_drill_ind).Table_Rel, -- table_relation
    G_Drill_Tbl(l_drill_ind).Parent2, -- parent2
    G_Drill_Tbl(l_drill_ind).Parent_Rel2, -- parent_relation2
    G_Drill_Tbl(l_drill_ind).Status,  -- status
    2,          -- status_whn_parnt_is_total
    G_Drill_Tbl(l_drill_ind).Position,  -- position
    G_Drill_Tbl(l_drill_ind).Total0,  -- total0
    0,          -- LEVEL_DISPLAY
    0,          -- No items
    NULL,         -- Key Value
    G_Drill_Tbl(l_drill_ind).Ev0,   -- ev0
    G_Drill_Tbl(l_drill_ind).Ev0,   -- ev1
    G_Drill_Tbl(l_drill_ind).Ev1d,    -- ev1d
    0,          -- ev2
    0   -- ev2d
    );


    l_debug_stmt := 'Inserting BSC_KPI_DIM_LEVELS_TL' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
    --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

  -- Create dummy
  IF l_drill_ind = 0 THEN
          l_sql_stmt := 'INSERT INTO BSC_KPI_DIM_LEVELS_TL
    (INDICATOR,DIM_SET_ID,DIM_LEVEL_INDEX,LANGUAGE,SOURCE_LANG,NAME,
      HELP,TOTAL_DISP_NAME,COMP_DISP_NAME)
    SELECT '
      ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
      0 AS DIM_SET_ID,'
      ||G_Drill_Tbl(l_drill_ind).Dim_level_index||' AS DIM_LEVEL_INDEX,
      FEM_ALL.LANGUAGE AS LANGUAGE,
      FEM_ALL.SOURCE_LANG AS SOURCE_LANG,
      ''XXX'' AS NAME,
      ''XXX'' AS HELP,
      SUBSTR(FEM_ALL.MEANING,1,15) AS TOTAL_DISP_NAME,
      SUBSTR(FEM_COMP.MEANING,1,15) AS COMP_DISP_NAME
    FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALL, '
          ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_COMP
    WHERE FEM_ALL.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
          FEM_ALL.LOOKUP_CODE = ''ALL'' AND
          FEM_COMP.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
          FEM_COMP.LOOKUP_CODE = ''COMPARISON'' AND
          FEM_COMP.LANGUAGE = FEM_ALL.LANGUAGE';

    l_debug_stmt := l_sql_stmt;
    l_cursor := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
    l_ignore := DBMS_SQL.Execute(l_cursor);
    DBMS_SQL.Close_Cursor(l_cursor);
  else
          l_sql_stmt := 'INSERT INTO BSC_KPI_DIM_LEVELS_TL
    (INDICATOR,DIM_SET_ID,DIM_LEVEL_INDEX,LANGUAGE,SOURCE_LANG,NAME,
      HELP,TOTAL_DISP_NAME,COMP_DISP_NAME)
    SELECT '
      ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
      0 AS DIM_SET_ID,'
      ||G_Drill_Tbl(l_drill_ind).Dim_level_index||' AS DIM_LEVEL_INDEX,
      FEM.LANGUAGE AS LANGUAGE,
      FEM.SOURCE_LANG AS SOURCE_LANG,
      SUBSTR(FEM.MEANING,1,30) AS NAME,
      SUBSTR(FEM.MEANING,1,80) AS HELP,
      SUBSTR(FEM_ALL.MEANING,1,15) AS TOTAL_DISP_NAME,
      SUBSTR(FEM_COMP.MEANING,1,15) AS COMP_DISP_NAME
    FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM, '
          ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALL, '
          ||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_COMP
    WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_LEVEL_NAME'' AND
          FEM.LOOKUP_CODE = '''||G_Drill_Tbl(l_drill_ind).dim_level_id||''' AND
                FEM_ALL.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
          FEM_ALL.LOOKUP_CODE = ''ALL'' AND
          FEM_COMP.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
          FEM_COMP.LOOKUP_CODE = ''COMPARISON'' AND
          FEM.LANGUAGE = FEM_ALL.LANGUAGE AND
          FEM_COMP.LANGUAGE = FEM_ALL.LANGUAGE';

    l_debug_stmt := l_sql_stmt;
        l_cursor := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
        l_ignore := DBMS_SQL.Execute(l_cursor);
        DBMS_SQL.Close_Cursor(l_cursor);
  end if;

          if (G_Ind_Tbl(k_indicator).Indicator = 3013) then

      l_debug_stmt := 'Inserting BSC_KPI_DIM_GROUPS' ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator) ||
                ', Family_Code= ' || to_char(G_Drill_Tbl(l_drill_ind).dim_group_id);

        Insert Into BSC_KPI_DIM_GROUPS (
    INDICATOR,
    DIM_SET_ID,
    DIM_GROUP_ID,
    DIM_GROUP_INDEX )
      Values (
    G_Ind_Tbl(k_indicator).Indicator,
          0,
    G_Drill_Tbl(l_drill_ind).dim_group_id,
      G_Drill_Tbl(l_drill_ind).dim_group_idx
      );

      l_debug_stmt := 'Inserting BSC_KPI_DIM_LEVEL_PROPERTIES' ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator) ||
                ', Entity_Code= ' || to_char(G_Drill_Tbl(l_drill_ind).dim_level_id);

        Insert Into BSC_KPI_DIM_LEVEL_PROPERTIES (
    INDICATOR,
    DIM_SET_ID,
    DIM_LEVEL_ID,
    POSITION,
    TOTAL0,
    LEVEL_DISPLAY,
    DEFAULT_KEY_VALUE,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT
    )
        Values (
    G_Ind_Tbl(k_indicator).Indicator,
    0,
    G_Drill_Tbl(l_drill_ind).dim_level_id,
    G_Drill_Tbl(l_drill_ind).Position,
    G_Drill_Tbl(l_drill_ind).Total0,
    G_Drill_Tbl(l_drill_ind).level_display,
    NULL,
    G_Drill_Tbl(l_drill_ind).Ev0,   -- ev0
    G_Drill_Tbl(l_drill_ind).Ev0,   -- ev1
    G_Drill_Tbl(l_drill_ind).Ev1d,    -- ev1d
    NULL, -- ev2
    NULL  -- ev2d
        );

          end if;

        End Loop; -- i_drill

        if (G_Ind_Tbl(k_indicator).Indicator = 3013) then
      l_opt_caption := 'Amount';
      l_opt_lookup := 1;
        else
      l_opt_caption := 'Option 0';
      l_opt_lookup := 0;
        end if;

  l_debug_stmt := 'Inserting BSC_KPI_ANALYSIS_OPTIONS_B' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    l_sql_defaults_b := 'Insert Into BSC_KPI_ANALYSIS_OPTIONS_B (INDICATOR,'||
                        'ANALYSIS_GROUP_ID,OPTION_ID,PARENT_OPTION_ID,GRANDPARENT_OPTION_ID,'||
                        'DIM_SET_ID,USER_LEVEL0,USER_LEVEL1,USER_LEVEL1_DEFAULT,USER_LEVEL2,'||
                        'USER_LEVEL2_DEFAULT )Values (:1,0,0,0,0,0,1,1,NULL,NULL,NULL)';
    EXECUTE IMMEDIATE l_sql_defaults_b USING G_Ind_Tbl(k_indicator).Indicator;

  l_debug_stmt := 'Inserting BSC_KPI_ANALYSIS_OPTIONS_TL' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

    l_sql_stmt := 'INSERT INTO BSC_KPI_ANALYSIS_OPTIONS_TL
    (INDICATOR,ANALYSIS_GROUP_ID,OPTION_ID,PARENT_OPTION_ID,GRANDPARENT_OPTION_ID,
    LANGUAGE,SOURCE_LANG,NAME,HELP)
  SELECT '
    ||G_Ind_Tbl(k_indicator).Indicator||' AS INDICATOR,
    0 AS  ANALYSIS_GROUP_ID,
    0 AS OPTION_ID,
    0 AS PARENT_OPTION_ID,
    0 AS GRANDPARENT_OPTION_ID,
    FEM.LANGUAGE AS LANGUAGE,
    FEM.SOURCE_LANG AS SOURCE_LANG,
    SUBSTR(FEM.MEANING,1,25) AS NAME,
    SUBSTR(FEM.MEANING,1,80) AS HELP
  FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM
  WHERE FEM.LOOKUP_TYPE =''BSC_TPLATE_TAB_AO_NAMES'' AND
        FEM.LOOKUP_CODE =:1';


    l_debug_stmt := l_sql_stmt;
    EXECUTE IMMEDIATE l_sql_stmt using l_opt_lookup;

  For p_period In 0 .. (G_Ind_Tbl(k_indicator).period_shown - 1)
      Loop

      if (G_Ind_Tbl(k_indicator).Indicator = 3007) and
               (G_Period_Tbl(p_period).Period_Type = 5) then
      l_option_r := 1;
      level_per :=2;
      else
      l_option_r := 0;
      level_per :=1;
            end if;

      l_debug_stmt := 'Inserting BSC_KPI_PERIODICITIES' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
      --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);


            Insert Into BSC_KPI_PERIODICITIES (
    INDICATOR,
    PERIODICITY_ID,
    DISPLAY_ORDER,
    PREVIOUS_YEARS,
    NUM_OF_YEARS,
    VIEWPORT_FLAG,
    VIEWPORT_DEFAULT_SIZE,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT,
    CURRENT_PERIOD,
    LAST_UPDATE_DATE)
      Values (
    G_Ind_Tbl(k_indicator).Indicator,
    G_Period_Tbl(p_period).Period_Type, -- periodicity_type
    l_option_r,       -- option_r
    G_Period_Tbl(p_period).Prev_Year, -- previous_years
    G_Period_Tbl(p_period).Num_Years, -- number_of_years
    G_Period_Tbl(p_period).Viewport_flag, -- viewport
    G_Period_Tbl(p_period).Viewport_Size, -- viewport_default_size
    level_per,          -- ev0
    level_per,          -- ev1
    NULL,         -- ev1d
    NULL,         -- ev2
    NULL,         -- ev2d
    1,
    SYSDATE
    );


      l_debug_stmt := 'Inserting BSC_KPI_DATA_TABLES' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
      --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

        l_sql_defaults_b := 'Insert Into BSC_KPI_DATA_TABLES (INDICATOR,PERIODICITY_ID,'||
                            'DIM_SET_ID,LEVEL_COMB,TABLE_NAME,FILTER_CONDITION )Values ('||
                            ':1,:2,0,'||
                            '''?'''||
                            ',NULL,NULL)';

        EXECUTE IMMEDIATE l_sql_defaults_b USING G_Ind_Tbl(k_indicator).Indicator,G_Period_Tbl(p_period).Period_Type;

    End Loop;  -- p_period loop


        -- Config Indicator to Tabs system

  l_debug_stmt := 'Inserting BSC_TAB_INDICATORS' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

  Insert Into BSC_TAB_INDICATORS (
    TAB_ID,
    INDICATOR,
    BSC_MODEL_FLAG,
    LEFT_POSITION,
    TOP_POSITION,
    WIDTH,
    HEIGHT,
    BACKCOLOR )
  Values (
    G_Ind_Tbl(k_indicator).Tab,
    G_Ind_Tbl(k_indicator).Indicator,
    0, 0, 0, 0, 0, 0
    );


     else  -- Indicator.Detail_Flag = 'NO'

        -- the following codes should not be used

  l_debug_stmt := 'Inserting BSC_KPI_PERIODICITIES' ||
    ', k_indicator=' || to_char(k_indicator) ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);

        Insert Into BSC_KPI_PERIODICITIES (
    INDICATOR,
    PERIODICITY_ID,
    DISPLAY_ORDER,
    PREVIOUS_YEARS,
    NUM_OF_YEARS,
    VIEWPORT_FLAG,
    VIEWPORT_DEFAULT_SIZE,
    USER_LEVEL0,
    USER_LEVEL1,
    USER_LEVEL1_DEFAULT,
    USER_LEVEL2,
    USER_LEVEL2_DEFAULT,
    CURRENT_PERIOD,
    LAST_UPDATE_DATE
    )
  Values (
    G_Ind_Tbl(k_indicator).Indicator,
    5,    -- periodicity_type
    0,    -- option_r
    0,    -- previous_years
    0,    -- number_of_years
    0,    -- viewport
    0,    -- viewport_default_size
    2,    -- ev0
    2,    -- ev1
    NULL,   -- ev1d
    NULL,   -- ev2
    NULL,   -- ev2d
    1,
    SYSDATE
    );
     end if;  -- Indicator.Detail_Flag

       -- User Options
  l_debug_stmt := 'Inserting BSC_SYS_USER_OPTIONS at System Level' ||
    ', Indicator= ' || to_char(G_Ind_Tbl(k_indicator).Indicator);

  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);
  For l_variable In 0 .. (G_Ind_Tbl(k_indicator).User_Options -1)  Loop

    Insert Into BSC_SYS_USER_OPTIONS(
      SOURCE_TYPE,
      SOURCE_CODE,
      USER_OPT_ID,
      ENABLED_FLAG,
      DISPLAY_FLAG)
    Values  (2,
      G_Ind_Tbl(k_indicator).Indicator,
      l_user_options (l_variable),
      0,
      1);
       end Loop;

  End loop;  -- indicator loop

  -- Fix BSC_KPI_PERIODICITIES. Current period for annual periodicities MUST be the current year.
  -- BUG 1949762
  update BSC_KPI_PERIODICITIES
  set CURRENT_PERIOD = (
  SELECT CURRENT_YEAR
  FROM BSC_SYS_CALENDARS_B
  WHERE CALENDAR_ID=1
  )
  where PERIODICITY_ID = 1;

   -- General
    l_debug_stmt := 'Inserting BSC_SYS_USER_OPTIONS at System Level';
  --DBMS_OUTPUT.PUT_LINE(l_debug_stmt);
  Insert Into BSC_SYS_USER_OPTIONS(
    SOURCE_TYPE,SOURCE_CODE,USER_OPT_ID,ENABLED_FLAG,DISPLAY_FLAG)
  Values  (0,0,1,0,1);
  Insert Into BSC_SYS_USER_OPTIONS(
    SOURCE_TYPE,SOURCE_CODE,USER_OPT_ID,ENABLED_FLAG,DISPLAY_FLAG)
  Values  (0,0,2,0,1);

/* -- ---------------------------------------------------------
  -- Reser sequences:
  --     BSC_SYS_DIM_LEVEL_ID_S :Get the DIM_LEVEL_ID for new Dimensions.TABLE= BSC_SYS_DIM_LEVELS_B
  --     BSC_SYS_DIM_GROUP_ID_S: Get the GROUP_ID for new Dimension Groups.TABLE =BSC_SYS_DIM_GROUPS_TL
        --     BSC_SYS_DATASET_ID_S
        --     BSC_SYS_MEASURE_ID_S
    -- ---------------------------------------------------------*/
      -- Reset sequence BSC_SYS_DIM_LEVEL_ID_S
    l_sql_stmt := 'SELECT NVL(MAX(DIM_LEVEL_ID),0) FROM BSC_SYS_DIM_LEVELS_B';
    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, l_sql_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_max_id);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_max_id);
    ELSE
        h_max_id := 0;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);
    h_max_id := h_max_id + 1;

    l_sql_stmt := 'DROP SEQUENCE BSC_SYS_DIM_LEVEL_ID_S';
    BEGIN BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.DROP_SEQUENCE, 'BSC_SYS_DIM_LEVEL_ID_S'); EXCEPTION WHEN OTHERS THEN NULL; END;
    l_sql_stmt := 'CREATE SEQUENCE BSC_SYS_DIM_LEVEL_ID_S START WITH '||h_max_id;
    BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.CREATE_SEQUENCE, 'BSC_SYS_DIM_LEVEL_ID_S');

   -- Reset sequence BSC_SYS_DIM_GROUP_ID_S
    l_sql_stmt := 'SELECT NVL(MAX(DIM_GROUP_ID),0) FROM BSC_SYS_DIM_GROUPS_TL';
    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, l_sql_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_max_id);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_max_id);
    ELSE
        h_max_id := 0;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);
    h_max_id := h_max_id + 1;

    l_sql_stmt := 'DROP SEQUENCE BSC_SYS_DIM_GROUP_ID_S';
    BEGIN BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.DROP_SEQUENCE, 'BSC_SYS_DIM_GROUP_ID_S'); EXCEPTION WHEN OTHERS THEN NULL; END;
    l_sql_stmt := 'CREATE SEQUENCE BSC_SYS_DIM_GROUP_ID_S START WITH '||h_max_id;
    BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.CREATE_SEQUENCE, 'BSC_SYS_DIM_GROUP_ID_S');


   -- Reset sequence BSC_SYS_DATASET_ID_S
    l_sql_stmt := 'SELECT NVL(MAX(DATASET_ID),0) FROM BSC_SYS_DATASETS_B';
    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, l_sql_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_max_id);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_max_id);
    ELSE
        h_max_id := 0;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);
    h_max_id := h_max_id + 1;

    l_sql_stmt := 'DROP SEQUENCE BSC_SYS_DATASET_ID_S';
    BEGIN BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.DROP_SEQUENCE, 'BSC_SYS_DATASET_ID_S'); EXCEPTION WHEN OTHERS THEN NULL; END;
    l_sql_stmt := 'CREATE SEQUENCE BSC_SYS_DATASET_ID_S START WITH '||h_max_id;
    BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.CREATE_SEQUENCE, 'BSC_SYS_DATASET_ID_S');

   -- Reset sequence BSC_SYS_MEASURE_ID_S
    l_sql_stmt := 'SELECT NVL(MAX(MEASURE_ID),0) FROM BSC_SYS_MEASURES';
    h_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(h_cursor, l_sql_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_max_id);
    h_ret := DBMS_SQL.EXECUTE(h_cursor);

    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_max_id);
    ELSE
        h_max_id := 0;
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);
    h_max_id := h_max_id + 1;

    l_sql_stmt := 'DROP SEQUENCE BSC_SYS_MEASURE_ID_S';
    BEGIN BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.DROP_SEQUENCE, 'BSC_SYS_MEASURE_ID_S'); EXCEPTION WHEN OTHERS THEN NULL; END;
    l_sql_stmt := 'CREATE SEQUENCE BSC_SYS_MEASURE_ID_S START WITH '||h_max_id;
    BSC_APPS.Do_DDL(l_sql_stmt, AD_DDL.CREATE_SEQUENCE, 'BSC_SYS_MEASURE_ID_S');


/* --END  2828685 SYNCH SEQUENCES */

  Return(TRUE);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
        );
      END IF;
      BSC_MESSAGE.Add(
        X_Message => x_msg_data,
        X_Source  => 'bsc_template.create_tab_template',
        X_Mode    => 'I');
      BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_template.create_tab_template',
        x_type    => 3,
        X_Mode    => 'I');
      RETURN FALSE;

    WHEN BSC_ERROR THEN
      BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_template.create_tab_template',
        X_Mode    => 'I');

      RETURN(FALSE);

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(
        X_Message => SQLERRM,
        X_Source  => 'bsc_template.create_tab_template',
        X_Mode    => 'I');

      BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_template.create_tab_template',
        x_type    => 3,
        X_Mode    => 'I');

      IF (DBMS_SQL.IS_OPEN(l_cursor)) then
        DBMS_SQL.CLOSE_CURSOR(l_cursor);
      END IF;

      RETURN(FALSE);

End Create_Tab_Template;


END BSC_TAB_TPLATE;

/
