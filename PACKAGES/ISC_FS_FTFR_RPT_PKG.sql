--------------------------------------------------------
--  DDL for Package ISC_FS_FTFR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_FTFR_RPT_PKG" 
/* $Header: iscfsftfrrpts.pls 120.0 2005/08/28 14:57:21 kreardon noship $ */
AUTHID CURRENT_USER as

procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

procedure get_dtl_rpt_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

end  isc_fs_ftfr_rpt_pkg;

 

/
