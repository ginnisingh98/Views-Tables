--------------------------------------------------------
--  DDL for Package ISC_MAINT_LAB_BLG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_LAB_BLG_RPT_PKG" AUTHID CURRENT_USER as
/*$Header: iscmaintlblgrpts.pls 120.0 2005/05/25 17:19:29 appldev noship $ */
procedure get_tab_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);

procedure get_lab_blg_dtl
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
);


end  ISC_MAINT_LAB_BLG_RPT_PKG;

 

/
