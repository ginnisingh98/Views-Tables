--------------------------------------------------------
--  DDL for Package POA_DBI_PR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_PR_PKG" AUTHID CURRENT_USER as
/* $Header: poadbiprs.pls 120.0 2005/06/01 13:09:17 appldev noship $ */
  procedure status_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure status_sum_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure amt_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure age_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure amt_trend_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure age_trend_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure au_trend_sql(p_param in bis_pmv_page_parameter_tbl
                        ,x_custom_sql out nocopy varchar2
                        ,x_custom_output out nocopy bis_query_attributes_tbl);
  procedure dtl_sql(
              p_param in bis_pmv_page_parameter_tbl,
              x_custom_sql out nocopy varchar2,
              x_custom_output out nocopy bis_query_attributes_tbl
            );
end poa_dbi_pr_pkg;

 

/
