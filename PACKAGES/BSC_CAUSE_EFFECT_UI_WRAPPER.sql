--------------------------------------------------------
--  DDL for Package BSC_CAUSE_EFFECT_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CAUSE_EFFECT_UI_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCCAEWS.pls 115.5 2003/02/12 14:25:35 adrao ship $ */

--
-- Global Types
--
TYPE t_array_of_number IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(32000)
    INDEX BY BINARY_INTEGER;

TYPE time_parameter_rec_type IS RECORD
(dimension	        VARCHAR2(32000)
,dimension_level        VARCHAR2(32000)
,time_from 		VARCHAR2(32000)
,time_to 		VARCHAR2(32000)

);

TYPE dim_parameter_rec_type IS RECORD
(dimension	        VARCHAR2(32000)
,dimension_level        VARCHAR2(32000)
,dimension_level_value  VARCHAR2(32000)
);

TYPE dim_parameter_tbl_type IS TABLE OF dim_parameter_rec_type INDEX BY
BINARY_INTEGER;


PROCEDURE Apply_Cause_Effect_Rels(
  p_indicator		IN	NUMBER
 ,p_level		IN	VARCHAR2
 ,p_causes_lst		IN	VARCHAR2
 ,p_effects_lst		IN	VARCHAR2
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

FUNCTION Exists_Measure_Dataset(
	p_measure_short_name IN VARCHAR2
	) RETURN BOOLEAN;

FUNCTION Get_Dataset_Id(
	p_measure_short_name IN VARCHAR2
	) RETURN NUMBER;

FUNCTION Decompose_Numeric_List(
	x_string IN VARCHAR2,
	x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
	) RETURN NUMBER;

FUNCTION Decompose_Varchar2_List(
	x_string IN VARCHAR2,
	x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
	) RETURN NUMBER;

FUNCTION Item_Belong_To_Array_Number(
	x_item IN NUMBER,
	x_array IN t_array_of_number,
	x_num_items IN NUMBER
	) RETURN BOOLEAN;

FUNCTION Item_Belong_To_Array_Varchar2(
	x_item IN VARCHAR2,
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER
	) RETURN BOOLEAN;

FUNCTION Get_Indicator_Name(
	p_indicator 	IN VARCHAR2,
	p_level		IN VARCHAR2
) RETURN VARCHAR2;


PROCEDURE Get_Indicator_Link(
  p_user_id		IN 	NUMBER
 ,p_indicator		IN	NUMBER
 ,p_level		IN	VARCHAR2
 ,p_page_id		IN	VARCHAR2 DEFAULT NULL
 ,p_page_dim_params	IN	VARCHAR2 DEFAULT NULL
 ,p_page_time_param	IN	VARCHAR2 DEFAULT NULL
 ,p_view_by_param	IN	VARCHAR2 DEFAULT NULL
 ,x_indicator_link	OUT NOCOPY	VARCHAR2
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

PROCEDURE Decompose_Page_Parameters(
 p_page_dim_params 	 IN	VARCHAR2
 , p_page_time_param 	 IN	VARCHAR2
 , x_page_dim_parameters OUT NOCOPY	dim_parameter_tbl_type
 , x_page_time_param 	 OUT NOCOPY	time_parameter_rec_type
);

FUNCTION Get_Page_Dim_Param_Index(
 p_page_dim_params 	IN dim_parameter_tbl_type
 , p_dimension		IN VARCHAR2
 , p_dimension_level	IN VARCHAR2
) RETURN NUMBER;

FUNCTION has_Function_Access(
  p_user_id	IN NUMBER
  , p_function_name IN VARCHAR2
) RETURN BOOLEAN;

END BSC_CAUSE_EFFECT_UI_WRAPPER;

 

/
