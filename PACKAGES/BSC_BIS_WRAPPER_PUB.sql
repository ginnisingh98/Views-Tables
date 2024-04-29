--------------------------------------------------------
--  DDL for Package BSC_BIS_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_WRAPPER_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPBISS.pls 115.9 2003/02/12 14:26:14 adrao ship $ */


TYPE Dim_level_Rec_Type IS RECORD
( dimension_short_name          VARCHAR2(200) := NULL
 ,level_short_name              VARCHAR2(200) := NULL
 ,level_value_id                VARCHAR2(32000) := NULL
 ,level_value_name		VARCHAR2(32000) := NULL
);

TYPE Dim_level_Rec_Tbl_Type IS TABLE of Dim_level_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE Page_Parameter_Rec_Type IS RECORD
( parameter_name          VARCHAR2(32000) := NULL
 ,value_id                VARCHAR2(32000) := NULL
 ,value_name              VARCHAR2(32000) := NULL
);

TYPE Page_Parameter_Rec_Tbl_Type IS TABLE OF Page_Parameter_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE Kpi_Info_Rec_Type IS RECORD
( kpi_code 			NUMBER := NULL
 ,analysis_option0		NUMBER := NULL
 ,analysis_option1		NUMBER := NULL
 ,analysis_option2		NUMBER := NULL
 ,series_id			NUMBER := NULL
 ,dataset_id			NUMBER := NULL
 ,dataset_source		VARCHAR2(2000) := NULL
 ,measure_short_name 		VARCHAR2(2000) := NULL
 ,measure_dbi_flag      	VARCHAR2(1) := NULL
 ,measure_id 			NUMBER := NULL
 ,region_code			VARCHAR2(2000) := NULL
 ,function_name			VARCHAR2(2000) := NULL
 ,actual_attribute_code 	VARCHAR2(2000) := NULL
 ,compareto_attribute_code 	VARCHAR2(2000) := NULL
 ,format_id 			NUMBER := NULL
 ,dimset_id			NUMBER := NULL
 ,dim1_short_name          	VARCHAR2(200) := NULL
 ,dim2_short_name          	VARCHAR2(200) := NULL
 ,dim3_short_name          	VARCHAR2(200) := NULL
 ,dim4_short_name          	VARCHAR2(200) := NULL
 ,dim5_short_name          	VARCHAR2(200) := NULL
 ,dim6_short_name          	VARCHAR2(200) := NULL
 ,dim7_short_name          	VARCHAR2(200) := NULL
 ,actual_value	        	VARCHAR2(2000) := NULL
 ,target_value			VARCHAR2(2000) := NULL
 ,insert_update_flag		VARCHAR2(1) := NULL
);

TYPE Kpi_Info_Rec_Tbl_Type IS TABLE OF Kpi_Info_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(32000)
    INDEX BY BINARY_INTEGER;

/************************************************************************************
   Get_Actual_Value by KPi
************************************************************************************/
FUNCTION Get_Actual_Value_By_Kpi(
    p_kpi_code 		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Actual_Value_By_Kpi, WNDS);

/************************************************************************************
  Get_Actual_Value by KPi Analysis option Comb
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
   Get_Current_Period by KPi
************************************************************************************/
FUNCTION Get_Current_Period_By_Kpi(
    p_kpi_code 		IN NUMBER
) RETURN VARCHAR2;

/************************************************************************************
  Get_Current_Period by KPi Analysis option Comb
************************************************************************************/
FUNCTION Get_Current_Period(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER
) RETURN VARCHAR2;

/************************************************************************************
   Get_DBI_Current_Period
************************************************************************************/
FUNCTION Get_DBI_Current_Period(
   p_dimension_short_name IN VARCHAR2,
   p_level_short_name IN VARCHAR2,
   p_as_of_date IN VARCHAR2

) RETURN VARCHAR2;

/************************************************************************************
   Get Target Value by KPi
************************************************************************************/
FUNCTION Get_Target_Value_By_Kpi(
    p_kpi_code 		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Target_Value_By_Kpi, WNDS);

/************************************************************************************
   Get Target Value by KPi Analysis option Comb
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
    Populate bsc_bis_measures_data for the given tab
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


END BSC_BIS_WRAPPER_PUB;

 

/
