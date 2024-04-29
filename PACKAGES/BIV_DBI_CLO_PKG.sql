--------------------------------------------------------
--  DDL for Package BIV_DBI_CLO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_CLO_PKG" 
/* $Header: bivsrvrclos.pls 115.1 2004/01/16 02:55:59 kreardon noship $ */
AUTHID CURRENT_USER as

procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_distribution    in varchar2 := 'N'
);

procedure get_dbn_tbl_sql
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

procedure get_detail_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
);


end  biv_dbi_clo_pkg;

 

/
