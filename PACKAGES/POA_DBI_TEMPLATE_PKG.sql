--------------------------------------------------------
--  DDL for Package POA_DBI_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_TEMPLATE_PKG" 
/* $Header: poadbitmpls.pls 120.2 2005/09/08 15:46:54 nnewadka noship $ */

AUTHID CURRENT_USER AS

  g_c_period_start_date   CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_EFFFECTIVE_START_DATE';
  g_c_period_end_date     CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_EFFECTIVE_END_DATE';
  g_p_period_start_date   CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_EFFECTIVE_START_DATE';
  g_p_period_end_date     CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';
  g_c_as_of_date          CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_ASOF_DATE';
  g_p_as_of_date          CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_ASOF_DATE';
  g_pp_date               CONSTANT VARCHAR2 (60) := '&PREV_PREV_DATE';
  -- Two bitmap variables used for the inlist generation
  g_inlist_xed            CONSTANT NUMBER        := 1; -- Bit 0
  g_inlist_xtd            CONSTANT NUMBER        := 2; -- Bit 1
  g_inlist_ytd            CONSTANT NUMBER        := 4; -- Bit 2

  -- for balance
  g_c_as_of_date_balance  constant varchar2(60) := 'least(&BIS_CURRENT_EFFECTIVE_END_DATE,&LAST_COLLECTION)';
  g_p_as_of_date_balance  constant varchar2(60) := 'least(&BIS_PREVIOUS_EFFECTIVE_END_DATE,&LAST_COLLECTION)';
  g_c_as_of_date_o_balance constant varchar2(70) := 'least((&BIS_CURRENT_EFFECTIVE_START_DATE -1),&LAST_COLLECTION)';
  -- for rolling and balance
  g_inlist_rlx            constant number        := 8; -- Bit 3
  g_inlist_bal            constant number        := 16; -- Bit 4

  FUNCTION status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                          VARCHAR2 := 'Y' -- when using rollup, pass: 'R', grouping sets, pass: 'Y'
  , p_paren_count               IN       NUMBER := 3
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_generate_viewby           IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL)
    RETURN VARCHAR2;

FUNCTION union_all_status_sql(
    p_mv                  IN POA_DBI_UTIL_PKG.poa_dbi_mv_tbl
  , p_join_tables         IN POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl
  , p_use_windowing       IN VARCHAR2
  , p_paren_count         IN NUMBER := 3
  , p_filter_where        IN VARCHAR2 := NULL
  , p_generate_viewby 	  IN VARCHAR2 := 'Y'
  , p_diff_measures       in varchar2 := 'Y') RETURN VARCHAR2;


PROCEDURE get_status_col_calc(
			  p_col_names IN poa_dbi_util_pkg.poa_dbi_col_tbl
			, x_col_calc_tbl OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_calc_tbl
			, x_inlist_bmap OUT NOCOPY NUMBER
			, x_compute_prior OUT NOCOPY VARCHAR2
			, x_compute_prev_prev OUT NOCOPY VARCHAR2
			, x_compute_opening_bal OUT NOCOPY VARCHAR2);

PROCEDURE get_trend_col_clauses(
  				p_col_name	  IN  poa_dbi_util_pkg.poa_dbi_col_tbl
				, p_xtd		  IN VARCHAR2
  				, x_inlist_bmap   OUT NOCOPY NUMBER
				, x_col_names	  OUT NOCOPY VARCHAR2
				, x_inner_col_names  OUT NOCOPY VARCHAR2
				, x_compute_opening_bal OUT NOCOPY VARCHAR2
				, x_col_list	  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_list);


  FUNCTION trend_sql (
    p_xtd                       IN       VARCHAR2
  , p_comparison_type           IN       VARCHAR2
  , p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                          VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_in_join_tbl := NULL
  , p_fact_hint			IN 	VARCHAR2 :=null
  , p_called_by_union           IN      VARCHAR2 := 'N' )
    RETURN VARCHAR2;

FUNCTION union_all_trend_sql(
    p_mv                     IN poa_dbi_util_pkg.poa_dbi_mv_tbl
  , p_comparison_type	     IN VARCHAR2
  , p_filter_where           IN VARCHAR2 := NULL
  , p_diff_measures          in varchar2 := 'Y')
    RETURN VARCHAR2;

  FUNCTION dtl_status_sql (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_paren_count               IN       NUMBER := 3
  , p_group_by                  IN       VARCHAR2
  , p_from_clause               IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION dtl_status_sql2 (
    p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_filter_where              IN       VARCHAR2 := NULL
  , p_paren_count               IN       NUMBER := 3
  , p_group_by                  IN       VARCHAR2
  , p_from_clause               IN       VARCHAR2)
    RETURN VARCHAR2;


  FUNCTION get_viewby_rank_clause (
    p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_use_windowing             IN       VARCHAR2)
    RETURN VARCHAR2;

END poa_dbi_template_pkg;

 

/
