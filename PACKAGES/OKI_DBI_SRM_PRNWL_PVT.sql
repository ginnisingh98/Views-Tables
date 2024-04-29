--------------------------------------------------------
--  DDL for Package OKI_DBI_SRM_PRNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SRM_PRNWL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIIPRNS.pls 120.1 2006/03/28 23:28:06 asparama noship $ */

    PROCEDURE get_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_bookings_sql(
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_rrate_sql(
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

   PROCEDURE get_pr_trend_sql(
   p_param 			IN BIS_PMV_PAGE_PARAMETER_TBL
 , x_custom_sql  		OUT NOCOPY VARCHAR2
 , x_custom_output 		OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   FUNCTION get_trend_sel_clause
   RETURN VARCHAR2;

   PROCEDURE get_bkngs_by_cust_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

END oki_dbi_srm_prnwl_pvt ;

 

/
