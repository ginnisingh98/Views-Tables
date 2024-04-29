--------------------------------------------------------
--  DDL for Package BIV_DBI_BAK_AGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_BAK_AGE_PKG" 
/* $Header: bivsrvrbags.pls 120.0 2005/05/25 10:58:41 appldev noship $ */
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

FUNCTION get_last_refresh_date
(p_object_name IN varchar2
)
RETURN varchar2;

FUNCTION current_report_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2
)
RETURN DATE;

end  biv_dbi_bak_age_pkg;

 

/
