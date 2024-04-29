--------------------------------------------------------
--  DDL for Package ISC_MAINT_ASSET_DT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_ASSET_DT_RPT_PKG" AUTHID CURRENT_USER as
/*$Header: iscmaintadtrpts.pls 120.0 2005/05/25 17:19:39 appldev noship $ */
procedure get_tbl_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_asset_dt_dtl_sql
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
end  isc_maint_asset_dt_rpt_pkg;

 

/
