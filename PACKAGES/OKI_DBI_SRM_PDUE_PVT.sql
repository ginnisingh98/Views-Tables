--------------------------------------------------------
--  DDL for Package OKI_DBI_SRM_PDUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SRM_PDUE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIIPDUS.pls 120.1 2006/03/28 23:27:38 asparama noship $ */

  PROCEDURE get_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_pastdue_percent_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_pduernwldetail_sql (
     p_param                     IN       bis_pmv_page_parameter_tbl
   , x_custom_sql                OUT NOCOPY VARCHAR2
   , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_trend_sql(
      p_param                     IN       bis_pmv_page_parameter_tbl
    , x_custom_sql                OUT NOCOPY VARCHAR2
    , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_pdueval_cust_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

END OKI_DBI_SRM_PDUE_PVT ;

 

/
