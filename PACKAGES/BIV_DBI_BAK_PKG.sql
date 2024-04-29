--------------------------------------------------------
--  DDL for Package BIV_DBI_BAK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_BAK_PKG" 
/* $Header: bivsrvrbaks.pls 120.0 2005/05/25 10:48:55 appldev noship $ */
AUTHID CURRENT_USER as

procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

procedure get_dbn_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

procedure get_unr_dbn_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_distribution    in varchar2 := 'N'
);

procedure get_dbn_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);

end  biv_dbi_bak_pkg;

 

/
