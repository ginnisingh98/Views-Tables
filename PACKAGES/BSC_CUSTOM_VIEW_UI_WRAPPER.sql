--------------------------------------------------------
--  DDL for Package BSC_CUSTOM_VIEW_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CUSTOM_VIEW_UI_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCCVDPS.pls 120.7 2007/03/15 10:42:03 ashankar ship $ */
c_type_label          CONSTANT NUMBER := 0;
c_type_link           CONSTANT NUMBER := 1;
c_type_launch_pad     CONSTANT NUMBER := 2;
c_type_kpi            CONSTANT NUMBER := 4;
c_type_kpi_actual     CONSTANT NUMBER := 5;
c_type_kpi_change     CONSTANT NUMBER := 6;
c_type_measure        CONSTANT NUMBER := 10;
c_type_measure_actual CONSTANT NUMBER := 11;
c_type_measure_change CONSTANT NUMBER := 12;
c_type_measure_slider CONSTANT NUMBER := 14;
c_type_hotspot        CONSTANT NUMBER := 0;

c_kpi                 CONSTANT VARCHAR(5) := '<kpi>';
c_kpi_actual          CONSTANT VARCHAR(12) := '<kpi:actual>';
c_kpi_change          CONSTANT VARCHAR(12) := '<kpi:change>';

c_measure             CONSTANT VARCHAR(9) := '<measure>';
c_measure_actual      CONSTANT VARCHAR(16) := '<measure:actual>';
c_measure_change      CONSTANT VARCHAR(16) := '<measure:change>';
c_measure_slider      CONSTANT VARCHAR(16) := '<measure:slider>';

C_FUNC_WEB_HTML_CALL          CONSTANT VARCHAR2(100) := 'OA.jsp?akRegionCode=BSC_PORTLET_CUSTOM_VIEW&akRegionApplicationId=271&dispRespCustPg=N';
C_FUNC_REGION_APPLICATION_ID  CONSTANT VARCHAR2(5)   := '271';
C_FUNC_REGION_CODE            CONSTANT VARCHAR2(50)  := 'BSC_PORTLET_CUSTVIEW_CUST';
C_FUNC_TYPE                   CONSTANT VARCHAR2(20)  := 'WEBPORTLET';
C_FUNCTIONAL_AREA             CONSTANT VARCHAR2(3)   := 'FA';
C_FORM_FUNCTION               CONSTANT VARCHAR2(3)   := 'FN';

--/////Added for Trend icon support in custom view
c_type_kpi_trend     CONSTANT NUMBER := 7;
c_kpi_trend          CONSTANT VARCHAR(12) := '<kpi:trend>';


--Compact all label ids in BSC_TAB_VIEW_LABELS_TL and BSC_TAB_VIEW_LABELS_B to be in consecutive order
PROCEDURE compact_custom_view_labels(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Clear BSC_TAB_VIEW_LABELS_TL, BSC_TAB_VIEW_LABELS_B and BSC_TAB_VIEW_KPI_TL with given tab_id and tab_view_id
PROCEDURE clear_custom_view_canvas(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

--Remove all items specified in removedKPIs and removedLabels
--Format of removedKPIs and removedLabels are id1,id2,id3,...,idN
PROCEDURE remove_custom_view_items(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_kpis              IN VARCHAR2
 ,p_labels            IN VARCHAR2
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_kpi_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified kpi to BSC_TAB_VIEW_KPI_TL
PROCEDURE add_or_update_kpi(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_hotspot_left      IN NUMBER
 ,p_hotspot_top       IN NUMBER
 ,p_hotspot_width     IN NUMBER
 ,p_hotspot_height    IN NUMBER
 ,p_alarm_left        IN NUMBER
 ,p_alarm_top         IN NUMBER
 ,p_alarm_width       IN NUMBER
 ,p_alarm_height      IN NUMBER
 ,p_actual_object_id  IN NUMBER
 ,p_actual_flag       IN NUMBER
 ,p_actual_left       IN NUMBER
 ,p_actual_top        IN NUMBER
 ,p_actual_width      IN NUMBER
 ,p_actual_height     IN NUMBER
 ,p_change_object_id  IN NUMBER
 ,p_change_flag       IN NUMBER
 ,p_change_left       IN NUMBER
 ,p_change_top        IN NUMBER
 ,p_change_width      IN NUMBER
 ,p_change_height     IN NUMBER
 ,p_link_function_id  IN NUMBER
 ,p_trend_object_id   IN NUMBER
 ,p_trend_flag        IN NUMBER
 ,p_trend_left        IN NUMBER
 ,p_trend_top         IN NUMBER
 ,p_trend_width       IN NUMBER
 ,p_trend_height      IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified hotspot to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_hotspot(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified custom view link to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_custom_view_link(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_link_tab_view_id  IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified launchpad to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_launch_pad(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_note_text         IN VARCHAR2
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_menu_id           IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Add specified measure (existing kpi) to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_measure(
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
 ,p_text_object_id     IN NUMBER
 ,p_text_flag          IN NUMBER
 ,p_font_size          IN NUMBER
 ,p_font_style         IN NUMBER
 ,p_font_color         IN NUMBER
 ,p_text_left          IN NUMBER
 ,p_text_top           IN NUMBER
 ,p_text_width         IN NUMBER
 ,p_text_height        IN NUMBER
 ,p_slider_object_id   IN NUMBER
 ,p_slider_flag        IN NUMBER
 ,p_slider_left        IN NUMBER
 ,p_slider_top         IN NUMBER
 ,p_slider_width       IN NUMBER
 ,p_slider_height      IN NUMBER
 ,p_actual_object_id   IN NUMBER
 ,p_actual_flag        IN NUMBER
 ,p_actual_left        IN NUMBER
 ,p_actual_top         IN NUMBER
 ,p_actual_width       IN NUMBER
 ,p_actual_height      IN NUMBER
 ,p_change_object_id   IN NUMBER
 ,p_change_flag        IN NUMBER
 ,p_change_left        IN NUMBER
 ,p_change_top         IN NUMBER
 ,p_change_width       IN NUMBER
 ,p_change_height      IN NUMBER
 ,p_indicator_id       IN NUMBER
 ,p_function_id        IN NUMBER
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
);

-- Wrappers for calling BSC_TAB_VIEW_KPI_PKG
PROCEDURE add_or_update_tab_view_kpi(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_hotspot_left      IN NUMBER
 ,p_hotspot_top       IN NUMBER
 ,p_hotspot_width     IN NUMBER
 ,p_hotspot_height    IN NUMBER
 ,p_alarm_left        IN NUMBER
 ,p_alarm_top         IN NUMBER
 ,p_alarm_width       IN NUMBER
 ,p_alarm_height      IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Create or udpate tab view's background in BSC_SYS_IMAGES and BSC_SYS_IMAGES_MAP_PKG
PROCEDURE add_or_update_tab_view_bg (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
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

-- Wrapper for calling BSC_TAB_VIEW_LABELS_PKG procedures
PROCEDURE add_or_update_tab_view_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_object_type       IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_text_flag         IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_note_text         IN VARCHAR2
 ,p_link_id           IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Create or update tab view properties in BSC_TAB_VIEWS_PKG
PROCEDURE add_or_update_tab_view (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_name              IN VARCHAR2
 ,p_func_area_short_name IN VARCHAR2
 ,p_internal_name IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_enable_flag       IN NUMBER
 ,p_create_form_func  IN VARCHAR2
 ,p_last_update_date  IN VARCHAR2
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

-- Create or update tab view properties in BSC_TAB_VIEWS_PKG
-- Called from UI for the extra original Name
PROCEDURE add_or_update_tab_view (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_name              IN VARCHAR2
 ,p_func_area_short_name IN VARCHAR2
 ,p_internal_name     IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_enable_flag           IN NUMBER
 ,p_is_default_int_name   IN VARCHAR2
 ,p_create_form_func  IN VARCHAR2
 ,p_last_update_date  IN VARCHAR2
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);
-- Check if the given tab view exists, return 'Y' if it exists, 'N' otherwise
FUNCTION is_tab_view_exist  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2;

-- Compare given tab view timestamp with that in DB. Return 0 if it is the
-- same, 1 otherwise.
FUNCTION compare_tab_view_timestamp (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
 ,p_last_update_date   IN VARCHAR2
) RETURN NUMBER ;

PROCEDURE add_or_update_function (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_name              IN VARCHAR2
 ,p_internal_name     IN VARCHAR2 := NULL
 ,p_description       IN VARCHAR2
 ,x_function_id       OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

procedure delete_function (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);

FUNCTION get_param_search_string  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 ;

FUNCTION next_custom_view_id (
  p_tab_id             IN NUMBER
 ) RETURN NUMBER ;

PROCEDURE Get_Or_CreateNew_Scorecard
(
    p_report_sht_name   IN          VARCHAR
 ,  p_resp_Id           IN          NUMBER
 ,  p_time_stamp        IN          VARCHAR2
 ,  p_Application_Id    IN          NUMBER
 ,  x_time_stamp        OUT NOCOPY  VARCHAR2
 ,  x_tab_Id            OUT NOCOPY  NUMBER
 ,  x_return_status     OUT NOCOPY  VARCHAR2
 ,  x_msg_count         OUT NOCOPY  NUMBER
 ,  x_msg_data          OUT NOCOPY  VARCHAR2
);

PROCEDURE  Get_Measure_Display_Name
(
    p_region_code       IN          VARCHAR
   ,p_dataset_id        IN          NUMBER
   ,x_meas_disp_name    OUT NOCOPY  VARCHAR
);

PROCEDURE  Get_Measure_Prop
(
    p_region_code       IN          VARCHAR
   ,p_dataset_id        IN          NUMBER
   ,x_meas_disp_name    OUT NOCOPY  AK_REGION_ITEMS_VL.ATTRIBUTE_LABEL_LONG%TYPE
   ,x_measure_type      OUT NOCOPY  BIS_INDICATORS_VL.MEASURE_TYPE%TYPE
   ,x_source            OUT NOCOPY  BSC_SYS_DATASETS_B.SOURCE%TYPE
   ,x_item_type         OUT NOCOPY  AK_REGION_ITEMS_VL.attribute1%TYPE
);


FUNCTION Get_Functional_Area_Code
RETURN VARCHAR2;

FUNCTION Get_Form_Function_Code
RETURN VARCHAR2;

FUNCTION Get_Tab_Fun_Fa_Prop
(
      p_tab_id      IN  NUMBER
    , p_tab_view_id IN  NUMBER
    , p_type        IN  VARCHAR
) RETURN VARCHAR2;

FUNCTION get_function_name_string  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 ;



END BSC_CUSTOM_VIEW_UI_WRAPPER; -- Package spec


/
