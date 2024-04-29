--------------------------------------------------------
--  DDL for Package OKI_DBI_SRM_RNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SRM_RNWL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIIRNWS.pls 120.1 2006/03/28 23:28:36 asparama noship $ */

    PROCEDURE get_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_bookings_sql(
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

   PROCEDURE get_top_bookings_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_renewal_forecast_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_late_rnwl_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl) ;

    PROCEDURE get_cncl_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_cancellations_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

   PROCEDURE get_bucket_sql(
   p_param 			IN 	 bis_pmv_page_parameter_tbl
 , x_custom_sql  		OUT NOCOPY VARCHAR2
 , x_custom_output 		OUT NOCOPY bis_query_attributes_tbl);

   PROCEDURE get_bkng_trend_sql(

   p_param 			IN BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql  		OUT NOCOPY VARCHAR2,
   x_custom_output 		OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   FUNCTION get_bkng_trend_sel_clause
      RETURN VARCHAR2;


   PROCEDURE get_bkngs_by_cust_sql (
   p_param                     IN       bis_pmv_page_parameter_tbl,
   x_custom_sql                OUT NOCOPY VARCHAR2,
   x_custom_output             OUT NOCOPY bis_query_attributes_tbl);


   PROCEDURE get_exp_bkngs_by_cust_sql (
   p_param                     IN       bis_pmv_page_parameter_tbl,
   x_custom_sql                OUT NOCOPY VARCHAR2,
   x_custom_output             OUT NOCOPY bis_query_attributes_tbl);


   PROCEDURE get_cancln_by_cust_sql (
   p_param                     IN       bis_pmv_page_parameter_tbl,
   x_custom_sql                OUT NOCOPY VARCHAR2,
   x_custom_output             OUT NOCOPY bis_query_attributes_tbl);


END oki_dbi_srm_rnwl_pvt ;

 

/
