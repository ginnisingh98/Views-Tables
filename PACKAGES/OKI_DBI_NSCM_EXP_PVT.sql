--------------------------------------------------------
--  DDL for Package OKI_DBI_NSCM_EXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_NSCM_EXP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIPNEXS.pls 120.1 2006/03/28 23:32:04 asparama noship $ */

    PROCEDURE get_expirations_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_period_expiring_sql  (
    p_param                     IN  bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    PROCEDURE get_expirations_detail_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

    FUNCTION exptype_detail(
    p_type                      IN VARCHAR2
  , p_renewed                   IN NUMBER
  , p_open                      IN NUMBER
  , p_cancelled                 IN NUMBER
  , p_norenewal                 IN NUMBER ) RETURN NUMBER;

   PROCEDURE get_exp_dist_sql  (
    p_param                     IN  bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  FUNCTION get_expdist_sel_clause RETURN VARCHAR2 ;

    PROCEDURE get_prd_exp_cont_dtl_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);


END OKI_DBI_NSCM_EXP_PVT ;

 

/
