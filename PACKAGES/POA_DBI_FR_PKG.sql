--------------------------------------------------------
--  DDL for Package POA_DBI_FR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_FR_PKG" AUTHID CURRENT_USER as
/* $Header: poadbifrs.pls 120.0 2005/06/01 15:10:04 appldev noship $ */
  procedure status_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure status_summary_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure amt_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure req_lines_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure req_age_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure trend_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure amt_trend_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure ped_trend_sql(p_param in bis_pmv_page_parameter_tbl
                      ,x_custom_sql out nocopy varchar2
                      ,x_custom_output out nocopy bis_query_attributes_tbl);
end poa_dbi_fr_pkg;

 

/
