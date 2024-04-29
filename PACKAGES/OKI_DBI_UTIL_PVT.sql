--------------------------------------------------------
--  DDL for Package OKI_DBI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRDBIS.pls 120.0 2005/05/30 03:43:08 appldev noship $ */

  g_oper_unit_bmap     CONSTANT INTEGER        := 1;
  g_sales_grp_bmap     CONSTANT INTEGER        := 2;
  g_sales_rep_bmap     CONSTANT INTEGER        := 4;
  g_sitem_bmap         CONSTANT INTEGER        := 8;
  g_prd_ctgy_bmap      CONSTANT INTEGER        := 16;
  g_cncl_reason_bmap   CONSTANT INTEGER        := 32;
  g_customer_bmap      CONSTANT INTEGER        := 64;
  g_trm_reason_bmap    CONSTANT INTEGER        := 128;
  g_cust_class_bmap    CONSTANT INTEGER        := 256;

  g_sales_grp_dim               VARCHAR2 (100) := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  g_sales_rep_dim               VARCHAR2 (100) := 'OKI_RESOURCE+SALESREP';
  g_oper_unit_dim               VARCHAR2 (100) := 'ORGANIZATION+FII_OPERATING_UNITS';
  g_sitem_dim                   VARCHAR2 (100) := 'ITEM+ENI_ITEM';
  g_prod_ctgy_dim               VARCHAR2 (100) := 'ITEM+ENI_ITEM_PROD_LEAF_CAT';
  g_cncl_reason_dim             VARCHAR2 (100) := 'OKI_STATUS+CNCL_REASON';
  g_time_mth_dim                VARCHAR2 (100) := 'TIME+FII_TIME_ENT_PERIOD';
  g_time_qtr_dim                VARCHAR2 (100) := 'TIME+FII_TIME_ENT_QTR';
  g_time_year_dim               VARCHAR2 (100) := 'TIME+FII_TIME_ENT_YEAR';
  g_customer_dim                VARCHAR2 (100) := 'CUSTOMER+FII_CUSTOMERS';
  g_trm_reason_dim              VARCHAR2 (100) := 'OKI_STATUS+TERM_REASON';
  g_cust_class_dim              VARCHAR2 (100) := 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS';

  g_sales_group_context         NUMBER (1);

  g_param                       bis_pmv_page_parameter_tbl;
  g_trend                       VARCHAR2 (100);
  g_view_by                     VARCHAR2 (100);
  g_mv_set                      VARCHAR2 (100);


  g_rs_group_id                 NUMBER;
  g_resource_id                 NUMBER;
  g_itemid                      NUMBER;
  g_invorgid                    NUMBER;

  TYPE oki_dbi_mv_bmap_rec IS RECORD (
    mv_name   VARCHAR2 (2000)
  , mv_bmap   NUMBER
  );

  TYPE oki_dbi_mv_bmap_tbl IS TABLE OF oki_dbi_mv_bmap_rec;

  FUNCTION current_period_start_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2)
    RETURN DATE;

  FUNCTION current_period_end_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2)
    RETURN DATE;

  FUNCTION previous_period_start_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2
  , comparison_type             IN       VARCHAR2)
    RETURN DATE;

  FUNCTION current_report_start_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2)
    RETURN DATE;

  FUNCTION previous_report_start_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2
  , comparison_type             IN       VARCHAR2)
    RETURN DATE;

  FUNCTION previous_period_asof_date (
    as_of_date                  IN       DATE
  , period_type                 IN       VARCHAR2
  , comparison_type             IN       VARCHAR2)
    RETURN DATE;

  FUNCTION get_dbi_params (
    region_id                   IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_sec_profile
    RETURN NUMBER;

  FUNCTION get_org_where (
    p_name                      IN       VARCHAR2
  , p_org                       IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_global_currency
    RETURN VARCHAR2;

  FUNCTION get_display_currency (
    p_currency_code             IN       VARCHAR2
  , p_selected_operating_unit   IN       VARCHAR2)
    RETURN VARCHAR2;

  PROCEDURE get_parameter_values (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , p_view_by                   OUT NOCOPY VARCHAR2
  , p_period_type               OUT NOCOPY VARCHAR2
  , p_org                       OUT NOCOPY VARCHAR2
  , p_comparison_type           OUT NOCOPY VARCHAR2
  , p_xtd                       OUT NOCOPY VARCHAR2
  , p_as_of_date                OUT NOCOPY DATE
  , p_cur_suffix                OUT NOCOPY VARCHAR2
  , p_pattern                   OUT NOCOPY NUMBER
  , p_period_type_id            OUT NOCOPY NUMBER
  , p_period_type_code          OUT NOCOPY VARCHAR2);

  PROCEDURE get_drill_across_param_val (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , p_attribute_code_num1       OUT NOCOPY NUMBER
  , p_attribute_code_num2       OUT NOCOPY NUMBER
  , p_attribute_code_num3       OUT NOCOPY NUMBER
  , p_attribute_code_num4       OUT NOCOPY NUMBER
  , p_attribute_code_num5       OUT NOCOPY NUMBER
  , p_attribute_code_char1      OUT NOCOPY VARCHAR2
  , p_attribute_code_char2      OUT NOCOPY VARCHAR2
  , p_attribute_code_char3      OUT NOCOPY VARCHAR2
  , p_attribute_code_char4      OUT NOCOPY VARCHAR2
  , p_attribute_code_char5      OUT NOCOPY VARCHAR2);

  PROCEDURE process_parameters (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , p_view_by                   OUT NOCOPY VARCHAR2
  , p_view_by_col_name          OUT NOCOPY VARCHAR2
  , p_comparison_type           OUT NOCOPY VARCHAR2
  , p_xtd                       OUT NOCOPY VARCHAR2
  , p_as_of_date                OUT NOCOPY DATE
  , p_prev_as_of_date           OUT NOCOPY DATE
  , p_cur_suffix                OUT NOCOPY VARCHAR2
  , p_nested_pattern            OUT NOCOPY NUMBER
  , p_where_clause              OUT NOCOPY VARCHAR2
  , p_mv                        OUT NOCOPY VARCHAR2
  , p_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_period_type               OUT NOCOPY VARCHAR2
  , p_trend                     IN       VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_role                      IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2
--  , p_rpt_type                  IN       VARCHAR2
  , p_rg_where                  IN       VARCHAR2);

  PROCEDURE init_dim_map (
    p_dim_map                   OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2);

  FUNCTION get_mv (
    p_dim_bmap                  IN       NUMBER
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_col_name (
    dim_name                             VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_prodcat_where
    RETURN VARCHAR2;

  FUNCTION get_rg_sec_where (
    p_rg_value                  IN       VARCHAR2
  , p_rg_col                    IN       VARCHAR2
  , p_view_by                   IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_where_clauses(
    p_dim_map poa_dbi_util_pkg.poa_dbi_dim_map
  , p_trend in VARCHAR2
  , p_view_by in VARCHAR2
  , p_mv_set in VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_security_where_clauses (
    p_dim_map                            poa_dbi_util_pkg.poa_dbi_dim_map
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_role                      IN       VARCHAR2
  , p_view_by                   IN       VARCHAR2
  , p_rg_where                  IN       VARCHAR2
  , p_param                     IN       bis_pmv_page_parameter_tbl)
    RETURN VARCHAR2;

  PROCEDURE get_join_info (
    p_view_by                   IN       VARCHAR2
  , p_dim_map                   IN       poa_dbi_util_pkg.poa_dbi_dim_map
  , x_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2);

  FUNCTION get_table (
    dim_name                             VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_viewby_select_clause (
    p_viewby                    IN       VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_cur_suffix (
    p_cur_suffix                IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_period_type_code (
    p_xtd                       IN       VARCHAR2)
    RETURN VARCHAR2;

  PROCEDURE add_join_table (
    p_join_tbl                  IN OUT NOCOPY   poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_column_name               IN       VARCHAR2
  , p_table_name                IN       VARCHAR2
  , p_table_alias               IN       VARCHAR2
  , p_fact_column               IN       VARCHAR2
  , p_dim_outer_join            IN       VARCHAR2 := 'N'
  , p_additional_where_clause   IN       VARCHAR2);

  PROCEDURE join_rpt_where (
    p_join_tbl                  IN OUT NOCOPY  poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_role                      IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2);

  FUNCTION add_measures (
    measure1                    IN       VARCHAR2
  , measure2                    IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION subtract_measures (
    measure1                    IN       VARCHAR2
  , measure2                    IN       VARCHAR2)
    RETURN VARCHAR2;

  PROCEDURE get_custom_trend_binds (
    p_xtd                       IN       VARCHAR2
  , p_comparison_type           IN       VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_custom_status_binds (
    x_custom_output             OUT NOCOPY bis_query_attributes_tbl);

  PROCEDURE get_bis_bucket_binds (
    x_custom_output             IN OUT NOCOPY bis_query_attributes_tbl,
    x_bis_bucket                IN bis_bucket_pub.BIS_BUCKET_REC_TYPE);

  FUNCTION get_default_portlet_param (
    p_region_code               IN       VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION get_view_by (
    p_param in BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN VARCHAR2;

  FUNCTION get_param_id (
    p_param                     IN       bis_pmv_page_parameter_tbl,
    p_param_name                IN       VARCHAR2 )
    RETURN VARCHAR2;

   FUNCTION  two_way_join ( sel_clause VARCHAR2,
                            query1 VARCHAR2,
                            query2 varchar2,
                            join_column1 varchar2,
                            join_column2 varchar2)
   return varchar2;

  FUNCTION get_sg_id RETURN VARCHAR2;

  FUNCTION change_clause(cur_col IN VARCHAR2, prior_col IN VARCHAR2, change_type IN VARCHAR2 := 'NP', prod in VARCHAR2 := 'OKI') RETURN VARCHAR2;


  FUNCTION get_nested_cols (
    p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
    ,period_type                 IN VARCHAR2
    ,P_TREND                     in varchar2 )    RETURN VARCHAR2;

  FUNCTION get_itd_where (
    p_mv_name                      IN       VARCHAR2
  , p_trend                   IN   VARCHAR2 )
    RETURN VARCHAR2;

  FUNCTION get_xtd_where (
    p_mv_name                      IN       VARCHAR2
  , p_trend                   IN   VARCHAR2
   , p_type                   IN VARCHAR2
   ,p_pattern     in VARCHAR2 := NULL)    RETURN VARCHAR2 ;

FUNCTION get_dtl_param_where(  p_param			IN	 bis_pmv_page_parameter_tbl)
  RETURN VARCHAR2;

END oki_dbi_util_pvt ;

 

/
