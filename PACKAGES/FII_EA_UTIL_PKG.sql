--------------------------------------------------------
--  DDL for Package FII_EA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAUTILS.pls 120.7 2006/07/19 06:25:46 sajgeo noship $ */

g_as_of_date 	           DATE;
/* 4439400 Budget */
g_bud_as_of_date           DATE;
g_previous_bud_asof_date   DATE;
g_page_period_type         VARCHAR2(100);
g_currency                 VARCHAR2(50);
g_view_by                  VARCHAR2(100);
g_time_comp                VARCHAR2(30);
g_previous_asof_date       DATE;
g_company_id               VARCHAR2(30) := 'All';
g_parent_company_id        NUMBER;
g_top_company_id           NUMBER;
g_cost_center_id           VARCHAR2(30) := 'All';
g_parent_cost_center_id    NUMBER;
g_top_cost_center_id       NUMBER;
g_fin_category_id          VARCHAR2(30) := 'All';
g_parent_fin_category_id   NUMBER;
g_fin_cat_type             VARCHAR2(10) := 'OE';
g_ledger_id                VARCHAR2(30) := 'All';
g_fud1_id                  VARCHAR2(30) := 'All';
g_parent_fud1_id           NUMBER;
g_top_fud1_id              NUMBER;
g_fud2_id                  VARCHAR2(30) := 'All';
g_parent_fud2_id           NUMBER;
g_top_fud2_id              NUMBER;
g_curr_view                VARCHAR2(4);
g_actual_bitand            NUMBER;
g_hist_actual_bitand       NUMBER;
g_budget_bitand            NUMBER;
g_forecast_bitand          NUMBER;
g_previous_one_end_date    DATE;
g_previous_two_end_date    DATE;
g_previous_three_end_date  DATE;
g_je_source_group          VARCHAR2(30);
g_unassigned_id            NUMBER;
g_year_id                  NUMBER;
g_prior_year_id            NUMBER;
g_coaid                    NUMBER;
g_period_set_name          VARCHAR2(15);
g_accounted_period_type    VARCHAR2(15);
g_curr_per_start           DATE;
g_curr_per_end             DATE;
g_prior_per_start          DATE;
g_prior_per_end            DATE;
g_curr_month_start         DATE;
g_hist_budget_bitand       NUMBER;
g_amount_type              VARCHAR2(3);
g_boundary                 VARCHAR2(1);
g_boundary_end             DATE;
g_prior_boundary_end       DATE;
g_amount_type_bitand       NUMBER;
g_snapshot                 VARCHAR2(1);
g_maj_cat_id               VARCHAR2(30) := 'All';
g_fin_cat_top_node_count   NUMBER;
g_category_id		   NUMBER;
g_udd1_id		   NUMBER;
g_company_is_leaf	   VARCHAR2(1);
g_cost_center_is_leaf	   VARCHAR2(1);
g_fin_cat_is_leaf	   VARCHAR2(1);
g_ud1_is_leaf		   VARCHAR2(1);
g_ud2_is_leaf		   VARCHAR2(1);
g_dir_msg		   VARCHAR2(240);
g_min_cat_id               VARCHAR2(30) := 'All';
g_region_code		   VARCHAR2(100);
g_sd_prior		   DATE;
g_sd_prior_prior	   DATE;
g_session_id		   NUMBER;
g_top_node_is_leaf	   VARCHAR2(1) := 'N';
g_id			   NUMBER;
g_time_id		   NUMBER;
g_aggrt_gt_record_count    NUMBER;
g_non_aggrt_gt_record_count NUMBER;
g_if_trend_sum_mv	   VARCHAR2(1) := 'N'; -- this variable indicates, if report/portlet queries would be hitting fii_gl_trend_sum_mv or not
g_fin_aggregate_flag	   VARCHAR2(1);
g_ud1_aggregate_flag	   VARCHAR2(1);
g_company_count		   NUMBER;
g_cc_count		   NUMBER;
g_display_sequence	   NUMBER; --  global variable used to maintain consistency in display of N/A and 0 for Period = Year
g_curr_per_start_id        NUMBER;
g_as_of_date_id            NUMBER;

-- Added for P&L Analysis
g_five_yr_back             DATE;
g_py_sday                  DATE;
g_exp_asof_date            DATE;
g_cy_period_end	           DATE;
g_ent_pyr_end              DATE;
g_period_type              NUMBER;
g_actual_period_type       NUMBER;
g_budget_period_type       NUMBER;
g_where_period_type        NUMBER;
g_ent_cyr_end              DATE;
g_curr_per_sequence        NUMBER;
g_exp_start                DATE;
g_forecast_period_type     NUMBER;
g_exp_begin_date           DATE;
g_fin_type	           VARCHAR2(200);
g_fin_id	           NUMBER;
g_fincat_is_leaf           VARCHAR2(1);
g_cat_join	           VARCHAR2(32000);
g_cat_join2		   VARCHAR2(32000);
g_parent_fin_id            NUMBER;

--   This package will provide central utilities for Expense Analysis PMV content

-- -----------------------------------------------------------------------
-- Name: reset_globals
-- Desc: This procedure is used to reset all the global variables to null.
-- Output: N/A.
-- -----------------------------------------------------------------------
PROCEDURE reset_globals;

-- -----------------------------------------------------------------------
-- Name: get_parameters
-- Desc: This procedure is consumed by all the reports to set the global
--       variables.
--       Obtains metadata: As of Date, Period Type, Currency, View By,
--       Compare To, Previous As of Date, Company id, Cost Center id,
--       Financial Category id, Ledger id, Financial UD1 id, Financial UD2
--       id, Currency view, Actual bitand mask, Budget/Forecase bitand
--       mask.
-- Output: N/A.
-- -----------------------------------------------------------------------
PROCEDURE get_parameters (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL);

-- -----------------------------------------------------------------------
-- Name: get_viewby_id
-- Desc: This procedure is used to obtain the viewby columns for aggregated
--       and nonaggregated nodes.
-- Output: p_aggrt_viewby_id returns the viewby column for aggregated
--         nodes, p_snap_aggrt_viewby_id returns the viewby column while hitting
--	   snapshot table for aggregated nodes and p_nonaggrt_viewby_id returns
--         the viewby column for nonaggregated nodes.
-- -----------------------------------------------------------------------
PROCEDURE get_viewby_id (p_aggrt_viewby_id OUT NOCOPY VARCHAR2,
			 p_snap_aggrt_viewby_id OUT NOCOPY VARCHAR2,
                         p_nonaggrt_viewby_id OUT NOCOPY VARCHAR2);

-- -----------------------------------------------------------------------
-- Name: insert_into_debug_tables
-- Desc: This procedure is used to store fii_pmv_%_gt table's records
--       in debug tables to facilitate debugging.
-- Output: N/A
-- -----------------------------------------------------------------------

PROCEDURE insert_into_debug_tables;

-- -----------------------------------------------------------------------
-- Name: populate_security_gt_tables
-- Desc: This procedure is used to populate the global tables fii_pmv_aggrt_gt
--       and fii_pmv_non_aggrt_gt.  The tables are populated with the
--       aggregated and non-aggregated dimension combination(s) that the
--       user has access to.
-- Output: p_aggrt_gt_is_empty returns 'N' if fii_pmv_aggrt_gt is empty
--         else 'Y'.  p_non_aggrt_gt_is_empty returns 'N' if fii_pmv_non_aggrt_gt
--         is empty else 'Y'.
-- -----------------------------------------------------------------------
PROCEDURE populate_security_gt_tables (p_aggrt_gt_is_empty OUT NOCOPY VARCHAR2,
				       p_non_aggrt_gt_is_empty OUT NOCOPY VARCHAR2);

-- -----------------------------------------------------------------------
-- Name: get_rolling_period
-- Desc: This procedure is used to obtain the rolling period end dates for
--       Expense Summary and Expense Trend by Account Detail.
--       Sets global variables: g_previous_one_end_date, g_previous_two_end_date,
--       g_previous_three_end_date
-- Output: N/A.
-- -----------------------------------------------------------------------
PROCEDURE get_rolling_period;

-- -----------------------------------------------------------------------
-- Name: get_ledger_for_detail
-- Desc: This function is used to obtain the filtering condition for the
--       Ledger parameter for detail reports.
-- Output: Returns ledger where clause conditions to be concatenated with
--         the remaining PMV query.
-- -----------------------------------------------------------------------
FUNCTION get_ledger_for_detail RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: get_fud1_for_detail
-- Desc: This function is used to obtain the filtering condition for the
--       Financial UD1 parameter for detail reports.
-- Output: Returns financial UD1 where clause conditions to be concatenated
--         with the remaining PMV query.
-- -----------------------------------------------------------------------
FUNCTION get_fud1_for_detail RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: get_fud2_for_detail
-- Desc: This function is used to obtain the filtering condition for the
--       Financial UD2 parameter for detail reports.
-- Output: Returns financial UD2 where clause conditions to be concatenated
--         with the remaining PMV query.
-- -----------------------------------------------------------------------
FUNCTION get_fud2_for_detail RETURN VARCHAR2;

FUNCTION get_curr RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: xtd
-- Desc: This function is used to obtain the column heading for the XTD
--       amount columns.
-- Output: Returns the column heading based on the Period Type parameter.
--         Either 'PTD', 'QTD', or 'YTD'.
-- -----------------------------------------------------------------------
FUNCTION xtd ( p_page_id           IN     VARCHAR2,
	       p_user_id           IN     VARCHAR2,
	       p_session_id        IN     VARCHAR2,
	       p_function_name     IN     VARCHAR2
              ) RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: prior_xtd
-- Desc: This function is used to obtain the column heading for the prior
--       XTD amount columns.
-- Output: Returns the column heading based on the Compare To parameter.
--         Either 'Prior XTD' or 'Budget'.
-- -----------------------------------------------------------------------
FUNCTION prior_xtd( p_page_id           IN     VARCHAR2,
	            p_user_id           IN     VARCHAR2,
	            p_session_id        IN     VARCHAR2,
	            p_function_name     IN     VARCHAR2) RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: prior_graph
-- Desc: This function is used to obtain the column heading for the prior
--       XTD amount graph columns.
-- Output: Returns the column heading based on the Compare To parameter.
--         Either 'Prior XTD' or 'Budget' or 'Forecast'.
-- -----------------------------------------------------------------------
FUNCTION prior_graph( p_page_id         IN     VARCHAR2,
                    p_user_id           IN     VARCHAR2,
                    p_session_id        IN     VARCHAR2,
                    p_function_name     IN     VARCHAR2) RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: get_rolling_period_label
-- Desc: This function is used to obtain the column heading for the rolling
--       period columns.
-- Output: Returns the column heading based on the Period Type parameter.
--         Either period display name/MTD or quarter display name/QTD.
-- -----------------------------------------------------------------------
FUNCTION get_rolling_period_label (p_sequence IN VARCHAR2) RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: period_label
-- Desc: This function is used to obtain the column heading period name.
-- Output: Returns the column heading period name based on the Period Type
--         parameter and the input date.
-- -----------------------------------------------------------------------
FUNCTION period_label (p_as_of_date IN DATE) RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: curr_period_label
-- Desc: This function is used to obtain the column heading period name.
-- Output: Returns the column heading period name based on the Period Type
--         parameter for the current period.
-- -----------------------------------------------------------------------
FUNCTION curr_period_label RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: prior_period_label
-- Desc: This function is used to obtain the column heading period name.
-- Output: Returns the column heading period name based on the Period Type
--         parameter for the prior period.
-- -----------------------------------------------------------------------
FUNCTION prior_period_label RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: change_label
-- Desc: This function is used to obtain the column heading for 'change'
--	 column on EA page portlets.
-- Output: Returns the column heading for 'change' column on EA page
--	   portlets based on the comparison Type parameter.
-- -----------------------------------------------------------------------
FUNCTION change_label RETURN VARCHAR2;


-- -----------------------------------------------------------------------
-- Name: get_com_name
-- Desc: This function is used to obtain the column heading for 'FII_EA_COL_COMPANY'
--       column on Expense Trend by Account Detail report.
-- Output: Returns the column heading for 'FII_EA_COL_COMPANY' column on
--        Expense Trend by Account Detail report. It could be 'Company'
--        or 'Fund' depending on Industry profile 'Commercial' or
--        'Government'.
-- -----------------------------------------------------------------------

FUNCTION get_com_name RETURN VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: check_if_leaf
-- Desc: This procedure is used to check whether respective
--	 parameters chosen are leaf or not.
-- Output: N/A.
-- -----------------------------------------------------------------------
PROCEDURE check_if_leaf(p_id IN NUMBER);

-- -----------------------------------------------------------------------
-- Name: bind_variable
-- Desc: This procedure is used to bind all the bind variables, no literal
--       shall be used in any report
-- Output: N/A.
-- -----------------------------------------------------------------------

PROCEDURE bind_variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ea_util_pkg;

 

/
