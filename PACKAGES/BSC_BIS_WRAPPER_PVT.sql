--------------------------------------------------------
--  DDL for Package BSC_BIS_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVBISS.pls 120.0 2005/06/01 17:11:21 appldev noship $ */

/************************************************************************************
************************************************************************************/

FUNCTION is_measure_dbi(
  l_measure_shortname IN VARCHAR2
) RETURN BOOLEAN;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Actual_Value(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Actual_Value, WNDS);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Actual_Value_From_PMV(
    p_kpi_info_rec 		IN BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type,
    p_user_id 			IN VARCHAR2,
    p_responsibility_id		IN VARCHAR2,
    p_dimension_levels		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    p_time_level_from		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    p_time_level_to           	IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    p_time_comparison_type	IN VARCHAR2,
    p_viewby_level      	IN VARCHAR2,
    x_actual_value		OUT NOCOPY VARCHAR2,
    x_compareto_value  		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
);

/************************************************************************************
***********************************************************************************/

PROCEDURE Get_AO_Defaults(
    p_kpi_code 		IN NUMBER,
    x_analysis_option0	OUT NOCOPY NUMBER,
    x_analysis_option1	OUT NOCOPY NUMBER,
    x_analysis_option2	OUT NOCOPY NUMBER,
    x_series_id		OUT NOCOPY NUMBER
);
PRAGMA RESTRICT_REFERENCES(Get_AO_Defaults, WNDS);

/************************************************************************************
************************************************************************************/

FUNCTION Get_Current_Period(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER
) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_DataSet_Id (
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_dataset_id	OUT NOCOPY NUMBER
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_DataSet_Info (
    p_dataset_id		IN NUMBER,
    x_source			OUT NOCOPY VARCHAR2,
    x_measure_id1		OUT NOCOPY NUMBER,
    x_operation			OUT NOCOPY VARCHAR2,
    x_measure_id2		OUT NOCOPY NUMBER,
    x_color_method      	OUT NOCOPY NUMBER,
    x_measure_col1		OUT NOCOPY VARCHAR2,
    x_measure_operation1	OUT NOCOPY VARCHAR2,
    x_measure_short_name 	OUT NOCOPY VARCHAR2,
    x_measure_col2		OUT NOCOPY VARCHAR2,
    x_measure_operation2	OUT NOCOPY VARCHAR2,
    x_format_id			OUT NOCOPY NUMBER
);

/************************************************************************************
************************************************************************************/

FUNCTION Get_DBI_Current_Period(
      p_time_dimension_level      IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
      p_as_of_date                IN VARCHAR2

) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/


FUNCTION Get_Dimension_Short_Name(
    p_dimension_id IN NUMBER
) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_DimensionSet_Id (
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_dimset_id		OUT NOCOPY NUMBER
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Period_Info(
    p_time_dim_level_short_name IN VARCHAR2,
    p_source 			IN VARCHAR2,
    p_org_dim_level_short_name	IN VARCHAR2,
    p_org_dim_level_value_id	IN VARCHAR2,
    p_period_date		IN DATE DEFAULT SYSDATE,
    x_period_id 		OUT NOCOPY VARCHAR2,
    x_period_name		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpi_Info(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_kpi_info_rec 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Pmf_Measure_Info (
    p_Measure_ShortName      	IN   VARCHAR2,
    x_measure_id 	     	OUT NOCOPY  NUMBER,
    x_function_name          	OUT NOCOPY  VARCHAR2,
    x_region_code            	OUT NOCOPY  VARCHAR2,
    x_attribute_code	     	OUT NOCOPY  VARCHAR2,
    x_compareto_attribute_code 	OUT NOCOPY  VARCHAR2,
    x_dimension1_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension2_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension3_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension4_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension5_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension6_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension7_short_name  	OUT NOCOPY  VARCHAR2
);

/************************************************************************************
************************************************************************************/

FUNCTION Get_Target_Value(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Target_Value, WNDS);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Target_Value_From_PMF(
    p_kpi_info_rec 		IN BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type,
    p_user_id 			IN VARCHAR2,
    p_responsibility_id		IN VARCHAR2,
    p_dimension_levels		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    p_time_level		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    x_target_value		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Total_DimLevel_Info(
    p_dimension_short_name IN VARCHAR2,
    x_total_dimlevel_short_name OUT NOCOPY VARCHAR2,
    x_total_dimlevel_value_id OUT NOCOPY NUMBER,
    x_total_dimlevel_value_name OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

FUNCTION Get_Dimension_Level_Index(
    p_dimension_short_name IN VARCHAR2
    ,p_dimension_levels    IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type
) RETURN NUMBER;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Default_Time_Level(
    p_kpi_code 			IN NUMBER
    ,p_dimset_id 		IN NUMBER
    ,x_time_dimension_level 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Default_Dimension_Levels(
    p_kpi_code 			IN NUMBER,
    p_dimset_id 		IN NUMBER,
    p_page_parameters		IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_default_dimension_levels 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    x_default_time_level_from 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    x_default_time_level_to 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type
);

/************************************************************************************
************************************************************************************/

FUNCTION Is_Time_Dimension(
    p_dimension_short_name IN VARCHAR2
) RETURN BOOLEAN;

/************************************************************************************
************************************************************************************/

PROCEDURE Populate_Measure_Data(
    p_tab_id		IN NUMBER,
    p_page_id		IN VARCHAR2,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_caching_key	IN VARCHAR2,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Populate_Measure_Data(
    p_user_id 		    IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_caching_key	    IN VARCHAR2,
    p_kpi_code 			IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id			IN NUMBER,
    p_actual_value      IN VARCHAR2,
    p_target_value      IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Parameters(
    p_user_id 		IN VARCHAR2,
    p_page_id 		IN VARCHAR2,
    x_page_parameters 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Parameter(
    p_page_parameters 	  IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    p_page_parameter_name IN VARCHAR2,
    x_page_parameter      OUT NOCOPY BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Type
);

/************************************************************************************
************************************************************************************/

FUNCTION Get_Time_Comparison_Parameter(
    p_page_parameters IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type
) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpis_Data_From_PMF_PMV(
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_page_parameters   IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    p_page_id		IN VARCHAR2,
    p_kpi_info_tbl      IN OUT NOCOPY BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Tbl_Type,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpi_view_by(
    p_kpi_code 			IN NUMBER,
    p_dimset_id  		IN VARCHAR2,
    p_page_parameters		IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_viewby_level      	OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE get_bsc_format_id(
  p_measure_shortname IN VARCHAR2
 ,x_bsc_format_id     OUT NOCOPY NUMBER
);

/************************************************************************************
************************************************************************************/

PROCEDURE get_bsc_format_id(
  p_display_type    IN VARCHAR2
 ,p_display_format  IN VARCHAR2
 ,x_bsc_format_id   OUT NOCOPY NUMBER
);

/************************************************************************************
************************************************************************************/

FUNCTION get_num_decimal_places(
  p_display_format  IN VARCHAR2
) RETURN NUMBER;

/************************************************************************************
***********************************************************************************/

FUNCTION Item_Belong_To_Array_Varchar2(
    p_item IN VARCHAR2,
    p_array IN BSC_BIS_WRAPPER_PUB.t_array_of_varchar2,
    p_num_items IN NUMBER
) RETURN BOOLEAN;

/************************************************************************************
***********************************************************************************/

END BSC_BIS_WRAPPER_PVT;

 

/
