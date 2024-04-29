--------------------------------------------------------
--  DDL for Package ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG" AUTHID CURRENT_USER as
/*$Header: iscfstrvvarrpts.pls 120.0 2005/08/28 15:01:53 kreardon noship $ */

procedure get_time_var_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);


procedure get_dist_var_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);



procedure get_time_var_dtr_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_dist_var_dtr_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);


end  ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG;

 

/
