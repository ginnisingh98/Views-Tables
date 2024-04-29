--------------------------------------------------------
--  DDL for Package BSC_PORTLET_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PORTLET_UI_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: BSCPORWS.pls 120.4 2007/02/08 14:29:20 ppandey ship $ */


/************************************************************************************
************************************************************************************/

FUNCTION Encode_String(
  p_string IN VARCHAR2
 ,p_escape IN VARCHAR2 := '%'
 ,p_reserved IN VARCHAR2 := '%=&;'
 ,p_encoded IN VARCHAR2 := 'PEAS'
) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/

FUNCTION Clean_String(
  p_string	IN VARCHAR2
) RETURN VARCHAR2;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Params(
  p_user_id		IN NUMBER
 ,p_page_id         	IN VARCHAR2
 ,x_page_params		OUT NOCOPY VARCHAR2
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Ranking_Parameter (
 p_page_id            IN    VARCHAR2
,p_user_id	      IN    NUMBER
,x_ranking_param      OUT NOCOPY   VARCHAR2
,x_return_status      OUT NOCOPY   VARCHAR2
,x_msg_count          OUT NOCOPY   NUMBER
,x_msg_data           OUT NOCOPY   VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Validate_Responsibility(
 p_user_id 		IN NUMBER
,p_resp_id 		IN NUMBER
,x_valid   		OUT NOCOPY VARCHAR2
,x_return_status 	OUT NOCOPY VARCHAR2
,x_msg_count	 	OUT NOCOPY NUMBER
,x_msg_data      	OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Show_Info_Page(
 p_info_key IN VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Show_Custom_View_Image(
 p_tab_code IN VARCHAR2,
 p_tab_view IN VARCHAR2,
 p_resp_id  IN VARCHAR2,
 p_mime_type IN VARCHAR2 := 'image/gif'
);


/************************************************************************************
************************************************************************************/

PROCEDURE Apply_CustomView_Parameters (
  p_user_id IN VARCHAR2,
  p_reference_path IN VARCHAR2,
  p_resp_id IN VARCHAR2,
  p_tab_id IN VARCHAR2,
  p_view_id IN VARCHAR2,
  p_portlet_name IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Apply_Graph_Parameters (
  p_user_id IN VARCHAR2,
  p_reference_path IN VARCHAR2,
  p_resp_id IN VARCHAR2,
  p_tab_id IN VARCHAR2,
  p_kpi_code IN VARCHAR2,
  p_view_id IN VARCHAR2,
  p_portlet_name IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);

/************************************************************************************
************************************************************************************/

PROCEDURE Apply_Kpi_List_Parameters(
 p_user_id IN NUMBER,
 p_plug_id IN NUMBER,
 p_reference_path IN VARCHAR2,
 p_resp_id IN NUMBER,
 p_details_flag IN NUMBER,
 p_group_flag IN NUMBER,
 p_kpi_measure_details_flag IN NUMBER,
 p_createy_by IN NUMBER,
 p_last_updated_by IN NUMBER,
 p_porlet_name IN VARCHAR2,
 p_number_array IN BSC_NUM_LIST,
 p_o_ret_status OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2,
 x_msg_count OUT NOCOPY NUMBER,
 x_msg_data OUT NOCOPY VARCHAR2
);
/************************************************************************************
************************************************************************************/

PROCEDURE checkUpdateCustView(
  p_commit	IN	VARCHAR2,
  p_user_id	IN	VARCHAR2,
  p_reference_path IN	VARCHAR2,
  p_tab_id	IN	VARCHAR2,
  p_view_id	IN	VARCHAR2,
  p_resp_id 	IN 	VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
 );
/************************************************************************************
************************************************************************************/

FUNCTION Get_CustView_Measure_Name(
    p_region_code       IN          VARCHAR
    ,p_dataset_id        IN          NUMBER
) RETURN VARCHAR2;

END BSC_PORTLET_UI_WRAPPER;

/
