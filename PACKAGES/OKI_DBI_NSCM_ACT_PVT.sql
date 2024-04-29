--------------------------------------------------------
--  DDL for Package OKI_DBI_NSCM_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_NSCM_ACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIPNACS.pls 120.1 2006/03/28 23:31:46 asparama noship $ */

    PROCEDURE get_activations_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  FUNCTION get_activations_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

     PROCEDURE get_activations_trend_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

   FUNCTION get_act_trend_sel_clause
    RETURN VARCHAR2;

    PROCEDURE get_activations_detail_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

 FUNCTION get_act_dtl_sel_clause (
    p_cur_suffix                IN       VARCHAR2
   , p_period_type_code          IN       VARCHAR2
   , p_status_id in VARCHAR2)
    RETURN VARCHAR2;

 Function new_ren_detail( p_type                   IN VARCHAR2
                         , p_new                   IN NUMBER
                         , p_ren                   IN NUMBER ) RETURN NUMBER;

    END OKI_DBI_NSCM_ACT_PVT;

 

/
