--------------------------------------------------------
--  DDL for Package BSC_BIS_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_MEASURE_PUB" AUTHID CURRENT_USER AS
  /* $Header: BSCPBMSS.pls 120.7 2006/01/24 01:20:40 ankgoel noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCPBMSS.pls
---
---  DESCRIPTION
---     Package Specification File for Measure transactions
---
---  NOTES
---
---  HISTORY
---
---  23-Apr-2003 mdamle     Created
---  16-JUN-2003 adrao      Added time_stamp params for Update/Delete APIs
---                         for Granular Locking
--   25-AUG-2003 mahrao     Added procedure Ret_Dataset_Fr_Meas_Shrt_Name and
--                          Order_Dimensions_For_Ldt
--   03-Sep-03   mdamle     Fixed Bug #3123734, 3123558 - Get measure col
--   28-NOV-03   adrao      Added constants c_QTD_CODE and c_XTD_CODE for warning messages
--                          for Bug#3238554
--   08-APR-04   ankgoel    Modified for bug#3557236
--   13-APR-04   ppandey    Bug# 3530050- Generating unique measure col if not unique
--   27-JUL-04   sawu       Modified create/update measure api to take p_owner
--   09-AUG-2004 ashankar   Bug#3809014 added the parameter p_ui_flag in Create_measure
--                          and Update_measure procedures.
--                          Added  c_UI_FLAG := 'N'
--   09-AUG-04   sawu       Added create_measure wrapper to handle default internal name
--   26-AUG-04   sawu       Bug#3813603: added Is_Unique_Measure_Display_Name()
--   01-SEP-04   sawu       Bug#3859267: added region, source/compare column app
--                          id to create/update api
--   09-SEP-04   ankgoel    Bug#3874911: Made get_Measure_Name public
--   18-OCT-04   adrao      Modified Create_Measure, Update_Measure signatures by added
--                          p_measure_col_help to the APIs for POSCO Bug#3817894
--   17-Nov-04   sawu       Bug#4015015: added api Is_Numeric_Column api
--   17-Dec-04   sawu       Bug#4045287: added Upload_Test, added p_custom_mode
--                          to Load_Measure() and Translate_Measure(). Overloaded
--                          Create_Measure() and Update_Measure().
--   27-Dec-04   rpenneru   Enh#4080204: Added Func_Area_Short name parameters to
--                          Create_Measue() and Update_Measure().
--   09-FEB-04 skchoudh    Enh#4141738 Added Functiona Area Combobox to MD
--   21-Feb-05   rpenneru Enh#4059160, Add FA as property to Custom KPIs
--   22-MAY-05   akoduri    Enhancement#3865711 -- Obsolete Seeded Objects  --
--   03-MAY-05  akoduri  Enh #4268374 -- Weighted Average Measures        --
--   23-May-05   visuri   Bug#3994115 Added Get_Meas_With_Src_Col() and Get_Sing_Par_Meas_DS()
--   17-JUL-05   sawu       Bug#4482736: Added Get_Primary_Data_Source
--   20-Sep-05   akoduri    Bug#4613172: CDS type measures should not get populated into
--                                       bsc_db_measure_cols_tl
--   22-Sep-05   ashankar Bug#4605142:Modified the API Get_Incr_Truigger
--   17-Nov-05   adrao    added API Is_Formula_Type() Bug#4617140
--   12-JAN-06   ppandey      Bug #4938364 - Color Warning for BIS Measure (AG)
--   24-JAN-06   ankgoel      Bug#4954663 Show Info text for AG to PL/SQL or VB conversion
---===========================================================================

c_PMD CONSTANT VARCHAR2(4) := 'PMD_';
c_BSC CONSTANT VARCHAR2(3) := 'BSC';
c_PMF CONSTANT VARCHAR2(3) := 'PMF';
c_CDS CONSTANT VARCHAR2(3) := 'CDS';
c_LEVEL CONSTANT VARCHAR2(7) := 'DATASET';
c_SEPARATOR CONSTANT VARCHAR2(1) := ';';
c_INTERNAL_COLUMN_NAME CONSTANT varchar2(5) := 'BSCIC';
c_FORMULA_SOURCE CONSTANT   varchar2(15) := 'pFormulaSource';
c_AVGL CONSTANT varchar2(6) := 'pAvgL';
c_SUM CONSTANT  varchar2(3) := 'SUM';
c_AVGL_CODE CONSTANT    varchar2(3) := 'AVL';
c_YTD_CODE constant    number := 2; -- Added for YTD
c_QTD_CODE constant    number := 6; -- Added for QTD
c_XTD_CODE constant    number := 12; -- Added for XTD
c_MAX_MSG_LENGTH constant    number := 4000; -- Added for YTD Disabling
c_UI_FLAG CONSTANT VARCHAR(2) :='N';

--Validates the measure/dataset name
PROCEDURE get_Measure_Name
(  p_dataset_id         IN         NUMBER      -- if NULL it means Create otherwise update
  ,p_ui_flag            IN         VARCHAR2
  ,p_dataset_source     IN         VARCHAR2    -- BSC or PMF
  ,p_dataset_name       IN         VARCHAR2    -- passed measure name
  ,x_measure_name       OUT NOCOPY VARCHAR2    -- trimmed output measure name
);

--Wrapper of Create_Measure that takes in p_default_short_name
-- 18-OCT-2004 ADRAO, changed signature added p_measure_col_help, Bug#3817894
procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_is_default_short_name          IN VARCHAR2
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
);

-- 18-OCT-2004 ADRAO, changed signature added p_measure_col_help, Bug#3817894
procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
);

--Bug#4045278: Wrapper for Create_Measure that takes in last_update_date
procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_last_update_date               IN BIS_INDICATORS.LAST_UPDATE_DATE%TYPE
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
);


-- 18-OCT-2004 ADRAO, changed signature added p_measure_col_help, Bug#3817894
procedure Update_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id                     IN NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_time_stamp                     IN VARCHAR2 := NULL    -- Added for Granular Locking
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
);

--Bug#4045278: Wrapper for Update_Measure that takes in last_update_date
procedure Update_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id                     IN NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_time_stamp                     IN VARCHAR2 := NULL    -- Added for Granular Locking
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_last_update_date               IN BIS_INDICATORS.LAST_UPDATE_DATE%TYPE
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
);


procedure Delete_measure(
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id             IN NUMBER
  ,p_time_stamp                 IN VARCHAR2 := NULL  -- Added for Granular Locking
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
);


procedure Apply_Dataset_Calc(
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id             IN NUMBER
  ,p_Disabled_Calc_table        IN BSC_NUM_LIST
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
);


PROCEDURE Apply_Cause_Effect_Rels(
  p_commit                      IN VARCHAR2 := FND_API.G_FALSE
 ,p_dataset_id              IN NUMBER
 ,p_causes_table            IN BSC_NUM_LIST
 ,p_effects_table           IN BSC_NUM_LIST
 ,x_return_status               OUT NOCOPY VARCHAR2
 ,x_msg_count                   OUT NOCOPY NUMBER
 ,x_msg_data                    OUT NOCOPY VARCHAR2
);

function getColorFormula(
     p_Dataset_Rec  IN  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
    ,p_Measure_Apply_Rollup IN VARCHAR2) return varchar2;

--ASHANKAR added on 09-Jun-2003
FUNCTION GET_AO_NAME
(
        p_indicator     in  NUMBER
    ,   p_a0            in  NUMBER
    ,   p_a1            in  NUMBER
    ,   p_a2            in  NUMBER
    ,   p_group_id      in  NUMBER
) RETURN VARCHAR2;

FUNCTION GET_SERIES_COUNT
(
        p_indicator     IN  NUMBER
    ,   p_a0            IN  NUMBER
    ,   p_a1            IN  NUMBER
    ,   p_a2            IN  NUMBER
) RETURN NUMBER;


--=============================================================================

Procedure Load_Measure
( p_commit IN  VARCHAR2   := FND_API.G_FALSE
 ,p_Measure_Rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
 ,p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_owner IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
 ,p_custom_mode IN VARCHAR2 := NULL
 ,p_application_short_name IN VARCHAR2
 ,p_Org_Dimension_Short_Name  IN  VARCHAR2
 ,p_Time_Dimension_Short_Name IN  VARCHAR2
 ,p_measure_group_name IN VARCHAR2
 ,p_measure_apply_rollup IN VARCHAR2
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
);
--=============================================================================
PROCEDURE Translate_Measure
(p_commit IN VARCHAR2 := FND_API.G_FALSE
,p_owner IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
,p_custom_mode IN VARCHAR2 := NULL
,p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
,p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2
,x_msg_count OUT NOCOPY NUMBER
,x_msg_data OUT NOCOPY VARCHAR2
) ;
--=============================================================================
--=============================================================================
PROCEDURE Ret_Dataset_Fr_Meas_Shrt_Name(
   p_Measure_Short_Name IN VARCHAR2
  ,x_Dataset_Id OUT NOCOPY NUMBER
);
--=============================================================================
PROCEDURE Order_Dimensions_For_Ldt(
  p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
 ,p_Org_Dimension_Short_Name IN VARCHAR2
 ,p_Time_Dimension_Short_Name IN VARCHAR2
 ,x_Measure_Rec OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
);
--=============================================================================


-- mdamle 09/03/03 - Get measure col
function get_measure_col (
   p_dataset_name IN VARCHAR2
  ,p_source       IN VARCHAR2
  ,p_measure_id   IN NUMBER
  ,p_short_name   IN VARCHAR2
) return VARCHAR2;


-- mdamle 09/03/03 - Is Formula
function isFormula
(p_measure_col  IN VARCHAR2) return boolean;

function getMeasureKpis (
      p_dataset_id in number
) return varchar2 ;


function getReturnMessage (
       p_dataset_id in number
     , p_message    in varchar2
)
return varchar2;

procedure Get_Incr_Trigger(
   p_commit                         in varchar2 := fnd_api.g_false
  ,p_dataset_id                     in number
  ,p_measure_projection_id          in number   := -1
  ,p_measure_type                   in number   := -1
  ,p_is_ytd_enabled                 in varchar2 := null
  ,p_is_qtd_enabled                 in varchar2 := null
  ,p_is_xtd_enabled                 in varchar2 := null
  ,p_rollup_calc                    in varchar2 := null
  ,p_formula                        in varchar2 := null
  ,p_Measure_Group_Id               IN VARCHAR2
  ,p_Check_Autogen_Only             IN VARCHAR2 := null
  ,x_return_status                  out nocopy  varchar2
  ,x_msg_count                      out nocopy  number
  ,x_msg_data                       out nocopy  varchar2
) ;


procedure get_Color_Change_Trigger(
  p_kpi_id              IN      varchar2
 ,p_dataset_data        IN      varchar2
 ,p_m1_accept           IN      varchar2
 ,p_m1_marg             IN      varchar2
 ,p_m2_accept           IN      varchar2
 ,p_m2_marg             IN      varchar2
 ,p_m3_upr_accept       IN      varchar2
 ,p_m3_upr_marg         IN      varchar2
 ,p_m3_lwr_accept       IN      varchar2
 ,p_m3_lwr_marg         IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

FUNCTION Is_Unique_Measure_Display_Name(
  p_dataset_id       NUMBER
 ,p_display_name     VARCHAR2
 ,p_source_type      VARCHAR2
) RETURN VARCHAR2;

--Return 'T' if specified column name in table is 'NUMBER', return 'F' otherwise
FUNCTION Is_Numeric_Column(
  p_table_name       VARCHAR2
 ,p_column_name      VARCHAR2
) RETURN VARCHAR2;

-- Wrapper for fnd_load_util.upload_test() that test whether a record should
-- be updated based on Last_Update_Date.
FUNCTION Upload_Test (
   p_measure_short_name   IN VARCHAR2
  ,p_nls_mode             IN VARCHAR2
  ,p_file_lub             IN NUMBER
  ,p_file_lud             IN DATE
  ,p_custom_mode          IN VARCHAR2
) RETURN BOOLEAN;


FUNCTION Get_Meas_With_Src_Col (
  p_measure_col IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION Get_Sing_Par_Meas_DS (
p_measure_id IN VARCHAR2
) RETURN VARCHAR2 ;

--Return primary data source (i.e. region_code portion of actual_data_source) of the indicator
FUNCTION Get_Primary_Data_Source (
  p_indicator_id    IN BIS_INDICATORS.INDICATOR_ID%TYPE
) RETURN BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;

-- added for Bug#4617140
FUNCTION Is_Formula_Type
(p_measure_col  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Report_Objectives (
    p_Dataset_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Is_Src_Col_In_Formulas(
  p_Source_Col IN VARCHAR2
) RETURN BOOLEAN;

end BSC_BIS_MEASURE_PUB;

 

/
