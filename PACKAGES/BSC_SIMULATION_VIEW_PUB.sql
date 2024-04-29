--------------------------------------------------------
--  DDL for Package BSC_SIMULATION_VIEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SIMULATION_VIEW_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCSIMPS.pls 120.3.12000000.1 2007/07/17 07:44:27 appldev noship $ */

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
REM |     22-NOV-06  ashankar  Created.                                     |
REM |     15-MAR-07  ankgoel   Bug#5933448 - Get correct measure formula for|
REM |                          non calculated KPIs in Simulation objectives |
REM |     29/03/07   ashankar Bug#5932973 Supporting filters and key items  |
REM |                         for SM tree                                   |
REM |     06-Jul-07    ashankar   Bug#6166829 Fix the prototype_flag issues |
REM | +=====================================================================+*/


--////////////////////Node Specific Properties ////////////
c_EXISTS                CONSTANT VARCHAR(2)  := 'Y';
c_NOT_EXISTS            CONSTANT VARCHAR(2)  := 'N';
c_INDICATOR_TYPE        CONSTANT NUMBER      := 2;
c_TYPE                  CONSTANT NUMBER      := 7;
c_NON_SIM_NODE          CONSTANT NUMBER      := 0;
c_SIM_NODE              CONSTANT NUMBER      := 1;
c_SIM_NODE_ID           CONSTANT VARCHAR(10) := 'S_NODE_ID';
c_SIM_COLOR_FORMULA     CONSTANT VARCHAR(20) := 'S_COLOR_FORMULA';
c_DEFAULT_SIM_NODE_ID   CONSTANT NUMBER      := -1;
c_TAB_ID                CONSTANT NUMBER      := -999;
c_CALCULATED_KPI        CONSTANT VARCHAR2(10):='CDS_CALC';
c_YEAR_TO_DATE_ENABLED  CONSTANT VARCHAR2(2) := 'Y';
c_YEAR_TO_DATE_DISABLED CONSTANT VARCHAR2(2) := 'N';
c_VISIBLE               CONSTANT NUMBER      :=2;
c_HIDE                  CONSTANT NUMBER      :=0;
c_YTD_CALC              CONSTANT NUMBER      :=2;
c_SEMI_COLON_DELIM      CONSTANT VARCHAR2(1) := ';';
c_DEFAULT_DATASET_ID    CONSTANT NUMBER      := -1;
c_CALC_KPI              CONSTANT VARCHAR2(10):='CDS';
C_EMPTY                 CONSTANT VARCHAR2(10):='';



--////////////Color Specific Properties ////////////
c_TYPE_MEASURE_COLOR CONSTANT NUMBER := 13;
c_MEASURE_COLOR      CONSTANT VARCHAR(16) := '<measure:color>';
c_PERCENT_OF_TARGET  CONSTANT VARCHAR(30) := 'PERCENT_OF_TARGET';

--////////////////Ak Region Specific //////////////

c_MEASURE_NO_TARGET  CONSTANT VARCHAR2(30) :='MEASURE_NOTARGET';

--//////////Dimension specific ///////////////
c_SIM_DIM_SET        CONSTANT NUMBER :=0;



TYPE Bsc_Ak_Region_Items_Rec is  RECORD
(
      Attribute_Code        ak_region_items_vl.attribute_code%TYPE
    , shortName             ak_region_items_vl.Attribute2%TYPE
    , Formula               VARCHAR2(32000)
    , Measure_Col           bsc_sys_measures.measure_col%TYPE
    , Acutual_Formula       ak_region_items_vl.Attribute3%TYPE
);

TYPE Bsc_Ak_Region_Items_Tbl_Type IS TABLE OF Bsc_Ak_Region_Items_Rec INDEX BY BINARY_INTEGER;



PROCEDURE Add_Or_Update_Sim_Tree_Bg (
  p_obj_id            IN NUMBER
 ,p_image_id          IN NUMBER
 ,p_file_name         IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_mime_type         IN VARCHAR2
 ,x_image_id          OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE Get_Objective_Details
(
    p_Region_Code       IN   AK_REGIONS.REGION_CODE%TYPE
   ,x_indicator         OUT NOCOPY VARCHAR2
   ,x_ind_group_id      OUT NOCOPY VARCHAR2
   ,x_tab_id            OUT NOCOPY VARCHAR2
   ,x_prototype_flag    OUT NOCOPY VARCHAR2
   ,x_ind_name          OUT NOCOPY VARCHAR2
   ,x_ytd_enabled       OUT NOCOPY VARCHAR2
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE add_or_update_measure
(
   p_tab_id               IN    NUMBER
  ,p_tab_view_id          IN    NUMBER
  ,p_text_object_id       IN    NUMBER
  ,p_text_flag            IN    NUMBER
  ,p_font_size            IN    NUMBER
  ,p_font_style           IN    NUMBER
  ,p_font_color           IN    NUMBER
  ,p_text_left            IN    NUMBER
  ,p_text_top             IN    NUMBER
  ,p_text_width           IN    NUMBER
  ,p_text_height          IN    NUMBER
  ,p_slider_object_id     IN    NUMBER
  ,p_slider_flag          IN    NUMBER
  ,p_slider_left          IN    NUMBER
  ,p_slider_top           IN    NUMBER
  ,p_slider_width         IN    NUMBER
  ,p_slider_height        IN    NUMBER
  ,p_actual_object_id     IN    NUMBER
  ,p_actual_flag          IN    NUMBER
  ,p_actual_left          IN    NUMBER
  ,p_actual_top           IN    NUMBER
  ,p_actual_width         IN    NUMBER
  ,p_actual_height        IN    NUMBER
  ,p_change_object_id     IN    NUMBER
  ,p_change_flag          IN    NUMBER
  ,p_change_left          IN    NUMBER
  ,p_change_top           IN    NUMBER
  ,p_change_width         IN    NUMBER
  ,p_change_height        IN    NUMBER
  ,p_color_object_id      IN    NUMBER
  ,p_color_flag           IN    NUMBER
  ,p_color_left           IN    NUMBER
  ,p_color_top            IN    NUMBER
  ,p_color_width          IN    NUMBER
  ,p_color_height         IN    NUMBER
  ,p_indicator_id         IN    NUMBER
  ,p_function_id          IN    NUMBER
  ,p_Node_Id              IN    NUMBER
  ,p_Node_Name            IN    VARCHAR2
  ,p_Node_Help            IN    VARCHAR2
  ,p_SimulateFlag         IN    NUMBER
  ,p_Format_id            IN    NUMBER
  ,p_Node_Color_flag      IN    NUMBER
  ,p_Node_Color_method    IN    NUMBER
  ,p_Navigates_to_trend   IN    NUMBER
  ,p_Top_position         IN    NUMBER
  ,p_Left_position        IN    NUMBER
  ,p_Width                IN    NUMBER
  ,p_Height               IN    NUMBER
  ,p_Autoscale_flag       IN    NUMBER
  ,p_Y_axis_title         IN    VARCHAR2
  ,p_Node_Attr_Code       IN    VARCHAR2
  ,p_Node_Short_Name      IN    VARCHAR2
  ,p_default_node         IN    NUMBER
  ,p_color_thresholds     IN    VARCHAR2
  ,p_color_by_total       IN    NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE add_or_update_sim_node_props
(
    p_indicator          IN     NUMBER
   ,p_Node_Id            IN     NUMBER
   ,p_Node_Name          IN     VARCHAR2
   ,p_Node_Help          IN     VARCHAR2
   ,p_SimulateFlag       IN     NUMBER
   ,p_Format_id          IN     NUMBER
   ,p_Color_flag         IN     NUMBER
   ,p_Color_method       IN     NUMBER
   ,p_Navigates_to_trend IN     NUMBER
   ,p_Top_position       IN     NUMBER
   ,p_Left_position      IN     NUMBER
   ,p_Width              IN     NUMBER
   ,p_Height             IN     NUMBER
   ,p_Autoscale_flag     IN     NUMBER
   ,p_Y_axis_title       IN     VARCHAR2
   ,p_Node_Attr_Code     IN     VARCHAR2
   ,p_Node_Short_Name    IN     VARCHAR2
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
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


PROCEDURE remove_simulation_view_items
(
  p_tab_id           IN         NUMBER
 ,p_obj_Id           IN         NUMBER
 ,p_labels           IN         VARCHAR2
 ,x_return_status    OUT NOCOPY VARCHAR2
 ,x_msg_count        OUT NOCOPY NUMBER
 ,x_msg_data         OUT NOCOPY VARCHAR2
);


PROCEDURE Duplicate_kpi_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Name_In_Tab
(
   p_name             IN          VARCHAR2
  ,p_tabId            IN          NUMBER
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

PROCEDURE Save_Color_Ranges
(
   p_indicator       IN          NUMBER
  ,p_dataset_id      IN          NUMBER
  ,p_color_ranges    IN          VARCHAR2
  ,x_return_status   OUT NOCOPY  VARCHAR2
  ,x_msg_count       OUT NOCOPY  NUMBER
  ,x_msg_data        OUT NOCOPY  VARCHAR2
);


FUNCTION Get_Kpi_Measure_Id
(
   p_indicator       IN          NUMBER
  ,p_dataset_id      IN          NUMBER
) RETURN NUMBER;


FUNCTION Get_Formula_Base_Columns
(
   p_indicator     IN    bsc_kpis_b.indicator%TYPE
  ,p_Dataset_Id    IN    bsc_sys_datasets_b.dataset_id%TYPE
  ,p_Meas_Col      IN    bsc_sys_measures.measure_col%TYPE
)RETURN VARCHAR2;

PROCEDURE copy_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
);

FUNCTION Get_Kpi_MeasureCol
(
  p_DatasetId    IN   bsc_sys_datasets_b.dataset_id%TYPE
) RETURN VARCHAR2;


PROCEDURE Set_Sim_Key_Values
(
   p_ind_Sht_Name   IN          BSC_KPIS_B.short_name%TYPE
  ,p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
);

END BSC_SIMULATION_VIEW_PUB;

 

/
