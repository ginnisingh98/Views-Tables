--------------------------------------------------------
--  DDL for Package BSC_SIMULATION_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SIMULATION_VIEW_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCSIMVS.pls 120.3.12000000.1 2007/07/17 07:44:31 appldev noship $ */

/*REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCSIMPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper API for SIMULATION                                |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     22-NOV-06    ashankar   Created.                                  |
REM |     29/03/07   ashankar Bug#5932973 Supporting filters and key items  |
REM |                         for SM tree                                   |
REM |     02-ARR-07    akoduri    Copy Indicator Enh#5943238                |
REM |     06-Jul-07    ashankar   Bug#6166829 Fix the prototype_flag issues |
REM | +=====================================================================+*/


C_SOURCE_CODE        CONSTANT VARCHAR2(30) := 'SOURCE_CODE';
C_SYSTEM_TABLE       CONSTANT VARCHAR2(30) := 'SYSTEM_TABLE';
C_TAB_VIEW_TABLE     CONSTANT VARCHAR2(50) := 'TAB_VIEW';
C_TAB_VIEW           CONSTANT VARCHAR2(50) := 'TAB_VIEW_ID';
C_INDICATOR          CONSTANT VARCHAR2(30) := 'INDICATOR';
C_KPI_TABLE          CONSTANT VARCHAR2(30) := 'KPI_TABLE';
C_IMAGE_ID           CONSTANT VARCHAR2(30) := 'IMAGE_ID';
C_AK_TABLE           CONSTANT VARCHAR2(30) := 'AK_REGION';
C_AK_COLUMN          CONSTANT VARCHAR2(30) := 'REGION_CODE';
C_SHOW_COLOR         CONSTANT VARCHAR2(1)  := 'F';
C_DISABLE_COLOR      CONSTANT VARCHAR2(1)  := 'T';
C_FORM_TABLE         CONSTANT VARCHAR2(30) := 'FND_FORM';
C_FORM_COLUMN        CONSTANT VARCHAR2(30) := 'FUNCTION_NAME';
C_FORM_FUNCTION_ID   CONSTANT VARCHAR2(30) := 'FUNCTION_ID';
C_COMMA              CONSTANT VARCHAR2(2)  := ',';
C_MEASURE_NOTARGET   CONSTANT VARCHAR2(50) := 'MEASURE_NOTARGET';
C_DEFAULT_ANA_OPTION CONSTANT NUMBER       := 0;
C_DOT                CONSTANT VARCHAR2(2)  := '.';


TYPE Bsc_Shared_Obj_Rec is  RECORD
(
    region_code      bsc_kpis_b.short_name%TYPE
   ,target_kpi       bsc_kpis_b.indicator%TYPE
   ,function_id      fnd_form_functions_vl.function_id%TYPE
);

TYPE Bsc_Shared_Obj_Tbl_Type IS TABLE OF Bsc_Shared_Obj_Rec INDEX BY BINARY_INTEGER;


PROCEDURE Duplicate_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);

PROCEDURE Add_Or_Update_YTD
(
   p_indicator            IN      NUMBER
  ,p_YTD                  IN      VARCHAR2
  ,p_prev_YTD             IN      VARCHAR2
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);

PROCEDURE Set_Kpi_Color_Flag
(
   p_indicator            IN      NUMBER
  ,p_dataset_id           IN      NUMBER
  ,p_color_flag           IN      VARCHAR2
  ,p_color_by_total       IN      NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);

PROCEDURE Set_Kpi_Color_Method
(
   p_indicator            IN      NUMBER
  ,p_dataset_id           IN      NUMBER
  ,p_color_method         IN      NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);


PROCEDURE set_default_node
(
  p_indicator          IN         NUMBER
 ,p_default_node       IN         NUMBER
 ,p_dataset_id         IN         NUMBER
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE copy_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);


PROCEDURE Set_Ak_Format_Id
(
  p_indicator      IN          BSC_KPIS_B.indicator%TYPE
 ,p_dataset_Id     IN          BSC_SYS_DATASETS_VL.dataset_id%TYPE
 ,p_format_Id      IN          BSC_KPI_TREE_NODES_VL.format_id%TYPE
 ,x_return_status  OUT NOCOPY  VARCHAR2
 ,x_msg_count      OUT NOCOPY  NUMBER
 ,x_msg_data       OUT NOCOPY  VARCHAR2
);

PROCEDURE Handle_Shared_Objectives
(
   p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
);

FUNCTION Get_Format
(
  p_format_Id    IN    VARCHAR2
) RETURN VARCHAR2;


PROCEDURE Init_Sim_Tables_Array
(
   p_copy_Ak_Tables          IN          VARCHAR
  ,x_Table_Number            OUT NOCOPY  NUMBER
  ,x_kpi_metadata_tables     OUT NOCOPY  BSC_DESIGNER_PVT.t_kpi_metadata_tables
);

PROCEDURE Copy_Ak_Record_Table
( p_table_name        IN  VARCHAR2
, p_table_type        IN  VARCHAR2
, p_table_column      IN  VARCHAR2
, p_Src_kpi           IN  NUMBER
, p_Trg_kpi           IN  NUMBER
, p_new_region_code   IN  VARCHAR2
, p_new_form_function IN VARCHAR2
, p_DbLink_Name       IN VARCHAR2 := NULL
);

PROCEDURE Copy_Dimension_Group (
  p_commit           IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator        IN    NUMBER
, p_Region_Code      IN    VARCHAR2
, p_Old_Region_Code  IN    VARCHAR2
, p_New_Dim_Levels   IN    FND_TABLE_OF_NUMBER
, p_DbLink_Name      IN    VARCHAR2
, x_return_status    OUT   NOCOPY  VARCHAR2
, x_msg_count        OUT   NOCOPY  NUMBER
, x_msg_data         OUT   NOCOPY  VARCHAR2
);

PROCEDURE Set_Sim_Key_Values
(
   p_ind_Sht_Name   IN          BSC_KPIS_B.short_name%TYPE
  ,p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
);

END BSC_SIMULATION_VIEW_PVT;

 

/
