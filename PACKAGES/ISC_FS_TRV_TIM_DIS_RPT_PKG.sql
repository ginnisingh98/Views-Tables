--------------------------------------------------------
--  DDL for Package ISC_FS_TRV_TIM_DIS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TRV_TIM_DIS_RPT_PKG" AUTHID CURRENT_USER as
/*$Header: iscfstrvrpts.pls 120.0 2005/08/28 15:01:32 kreardon noship $ */

procedure get_tbl_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_dtl_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_tot_trd_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_trd_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_time_bucket_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);





procedure get_distance_bucket_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);


end  ISC_FS_TRV_TIM_DIS_RPT_PKG;

 

/
