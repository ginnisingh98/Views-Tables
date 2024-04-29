--------------------------------------------------------
--  DDL for Package OKI_DBI_NSCM_BAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_NSCM_BAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIPNKPS.pls 120.1 2006/03/28 23:32:22 asparama noship $ */

    PROCEDURE get_balance_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_balance_detail_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

   PROCEDURE get_balance_trend_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

END OKI_DBI_NSCM_BAL_PVT ;

 

/
