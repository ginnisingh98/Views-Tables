--------------------------------------------------------
--  DDL for Package Body FII_EA_SUM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_SUM_TREND_PKG" AS
/*  $Header: FIIEASUMB.pls 120.11.12000000.2 2007/04/16 06:53:20 dhmehra ship $ */

--   This package will provide sql statements to retrieve data for Expense Summary, Revenue Summary,
--   Expense Rolling Trend & Revenue Rolling Trend reports

-- get_exp_sum procedure is called by Expense Summary report. It is a wrapper for get_revexp_sum.

PROCEDURE get_exp_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_sum_sql out NOCOPY VARCHAR2,
  exp_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'OE';

    sqlstmt := fii_ea_sum_trend_pkg.get_revexp_sum(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_sum_sql, exp_sum_output);

END get_exp_sum;

-- get_rev_sum procedure is called by Revenue Summary report. It is a wrapper for get_revexp_sum.

PROCEDURE get_rev_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_sum_sql out NOCOPY VARCHAR2,
  rev_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'R';

    sqlstmt := fii_ea_sum_trend_pkg.get_revexp_sum(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_sum_sql, rev_sum_output);

END get_rev_sum;

--
-- get_cgs_sum procedure is called by Cost of Goods Sold Summary report.
-- It is a wrapper for get_revexp_sum().
--
PROCEDURE get_cgs_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_sum_sql out NOCOPY VARCHAR2,
  rev_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'CGS';

    sqlstmt := fii_ea_sum_trend_pkg.get_revexp_sum(p_page_parameter_tbl);

    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_sum_sql, rev_sum_output);

END get_cgs_sum;

-- get_revexp_sum is a common procedure, used both by Expense and Revenue Summary reports

FUNCTION get_revexp_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 IS

  sqlstmt			VARCHAR2(15000);
  p_aggrt_viewby_id		VARCHAR2(30);
  p_snap_aggrt_viewby_id	VARCHAR2(30);
  p_nonaggrt_viewby_id		VARCHAR2(50);
  p_aggrt_gt_is_empty		VARCHAR2(1);
  p_non_aggrt_gt_is_empty	VARCHAR2(1);
  l_union_all			VARCHAR2(10);
  l_roll_column			VARCHAR2(10);
  l_xtd_column			VARCHAR2(10);   -- At the time of hitting snapshot tables, l_roll_column and l_xtd_xolumn are used to differentitate some columns,
						-- based on period type chosen i.e if column used to display xtd data should be actual_curr_mtd/qtd/ytd..

  l_aggrt_sql			VARCHAR2(10000) := NULL;
  l_sqlstmt1			VARCHAR2(10000) := NULL;
  l_snap_sqlstmt1		VARCHAR2(10000) := NULL;
  l_non_aggrt_sql		VARCHAR2(10000) := NULL;
  l_sqlstmt2			VARCHAR2(10000) := NULL;
  l_snap_sqlstmt2		VARCHAR2(10000) := NULL;
  l_trend_sum_mv_sql		VARCHAR2(10000) := NULL;
  l_viewby_drill_url	        VARCHAR2(300);
  l_xtd_drill_url	        VARCHAR2(300);
  l_snap_prior			VARCHAR2(300);
  l_bud_frcst_prior		VARCHAR2(10000);
  l_cat_decode 			VARCHAR2(300); -- local variable to append decode check for category, when we have only 1 top node
  l_fud1_decode 		VARCHAR2(300); -- local variable to append decode check for fud1, when viewby chosen is FUD1
  l_budget_decode 		VARCHAR2(300); -- Since we can load budget only against category and fud1 summary nodes,
						-- this local variable appends a check to agrt MV and base map MV queries, so that budget is checked only for xTD period.
						-- Budget loaded for prior xTD should not result in any unwanted record, having 0/NA in all columns..
  l_budget_snap_decode 		VARCHAR2(300); -- local variable analogous to l_budget_decode..it appends a similar check to snapshot query
  l_id				NUMBER;
  l_if_leaf_flag		VARCHAR2(1);	-- local var to denote, if category or fud1 param chosen to run the report is a leaf or not..
  l_fud2_enabled_flag		VARCHAR2(1);
  l_fud2_where			VARCHAR2(300);
  l_fud2_snap_where		VARCHAR2(300);
  l_fud2_from			VARCHAR2(100);
-- Added for enhancement 4269343
  l_drill_source                VARCHAR2(40);


BEGIN
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ea_util_pkg.get_rolling_period;
fii_ea_util_pkg.get_viewby_id(p_aggrt_viewby_id, p_snap_aggrt_viewby_id, p_nonaggrt_viewby_id);
fii_ea_util_pkg.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

CASE fii_ea_util_pkg.g_page_period_type  -- we set different 'period type' dependent variables in this CASE structure

  WHEN 'FII_TIME_ENT_YEAR' THEN
	l_roll_column := 'qtd';
	l_xtd_column  := 'ytd' ;

  WHEN 'FII_TIME_ENT_QTR' THEN
	l_roll_column := 'mtd';
	l_xtd_column  := 'qtd' ;

  WHEN 'FII_TIME_ENT_PERIOD' THEN
	l_roll_column := 'mtd';
	l_xtd_column  := 'mtd' ;

  END CASE;

IF (fii_ea_util_pkg.g_time_comp = 'BUDGET') THEN
	l_snap_prior := 'SUM(f.budget_cur_'||l_xtd_column||')    FII_EA_PRIOR_XTD_EXP_G,
			 NULL  FII_EA_PRIOR_XTD_EXP,
			 NULL  FII_EA_PRIOR_BUDGET,
			 NULL  FII_EA_PRIOR_FORECAST,
			 NULL    FII_EA_PRIOR_TOTAL_G,
			 NULL    FII_EA_CURR_TOTAL_G,';
	l_bud_frcst_prior := '	SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP_G,
				NULL	FII_EA_PRIOR_XTD_EXP,
				NULL	FII_EA_PRIOR_BUDGET,
				NULL	FII_EA_PRIOR_FORECAST,
				NULL    FII_EA_PRIOR_TOTAL_G,
				NULL    FII_EA_CURR_TOTAL_G,';
ELSIF fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL' THEN
	l_snap_prior := 'SUM(f.actual_prior_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP_G,
			 SUM(f.actual_prior_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP,
			 SUM(f.budget_prior_'||l_xtd_column||')  FII_EA_PRIOR_BUDGET,
			 SUM(f.forecast_prior_'||l_xtd_column||')  FII_EA_PRIOR_FORECAST,
			 NULL    FII_EA_PRIOR_TOTAL_G,
			 NULL    FII_EA_CURR_TOTAL_G,';
	l_bud_frcst_prior := '	SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP_G,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END) ) )   FII_EA_PRIOR_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_PRIOR_FORECAST,
				SUM(DECODE(inner_inline_view.report_date, :PRIOR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_TOTAL_G,
			        SUM(DECODE(inner_inline_view.report_date, :CURR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_CURR_TOTAL_G,';
ELSIF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
	l_snap_prior := 'SUM(f.actual_prior_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP_G,
			 SUM(f.actual_prior_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP,
			 SUM(f.budget_prior_'||l_xtd_column||')  FII_EA_PRIOR_BUDGET,
			 SUM(f.forecast_prior_'||l_xtd_column||')  FII_EA_PRIOR_FORECAST,
			 NULL    FII_EA_PRIOR_TOTAL_G,
			 NULL    FII_EA_CURR_TOTAL_G,';
	l_bud_frcst_prior := '	SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP_G,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END) ) )   FII_EA_PRIOR_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_PRIOR_FORECAST,
				SUM(DECODE(inner_inline_view.report_date, :PRIOR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_TOTAL_G,
			        SUM(DECODE(inner_inline_view.report_date, :CURR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_CURR_TOTAL_G,';
ELSE
	l_snap_prior := 'SUM(f.actual_prior_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP_G,
			 SUM(f.actual_last_year_'||l_xtd_column||')  FII_EA_PRIOR_XTD_EXP,
			 SUM(f.budget_last_year_'||l_xtd_column||')  FII_EA_PRIOR_BUDGET,
			 SUM(f.forecast_last_year_'||l_xtd_column||')  FII_EA_PRIOR_FORECAST,
			 NULL    FII_EA_PRIOR_TOTAL_G,
			 NULL    FII_EA_CURR_TOTAL_G,';
	l_bud_frcst_prior := '	SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP_G,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_PRIOR_XTD_EXP,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END) ) )   FII_EA_PRIOR_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_PRIOR_FORECAST,
				SUM(DECODE(inner_inline_view.report_date, :PRIOR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_TOTAL_G,
			        SUM(DECODE(inner_inline_view.report_date, :CURR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_CURR_TOTAL_G,';
END IF;


-- logic for bug fix 4099357.. if we choose node A which has 2 children B & C, then, we want to
-- display A in the tabular data, only if there is budget/forecast loaded directly against A.
-- For this, while keeping parent_id as A, we want to look only for A in fii_gl_base_map_mv
-- so that we do not get duplication of actuals..hence we append conditional decode
-- statements l_cat_decode and l_fud1_decode  in l_sqlstmt2 and l_snap_sqlstmt2..

IF fii_ea_util_pkg.g_fin_category_id = 'All' THEN
	IF fii_ea_util_pkg.g_fin_cat_top_node_count = 1 THEN
		l_cat_decode := 'and fin_hier.parent_fin_cat_id = decode(fin_hier.parent_fin_cat_id,:CATEGORY_ID,
									 fin_hier.child_fin_cat_id,fin_hier.parent_fin_cat_id)';
	END IF;
ELSE
		l_cat_decode := 'and fin_hier.parent_fin_cat_id = DECODE(fin_hier.parent_fin_cat_id, :CATEGORY_ID,
									 fin_hier.child_fin_cat_id, fin_hier.parent_fin_cat_id)';
END IF;

IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);
	l_if_leaf_flag := fii_ea_util_pkg.g_fin_cat_is_leaf;

-- This issue was found during testing of fix for bug 4127077. Since these variables are used to check for loading of budgets against summary nodes,
-- we don't need to append l_budget_snap_decode and l_budget_decode to the main sql, when we choose a leaf category node.

	IF l_if_leaf_flag = 'N' THEN
		l_budget_snap_decode := 'and f.fin_category_id = DECODE(:G_ID, f.fin_category_id,
								DECODE(budget_cur_'||l_roll_column||',0, -99999, f.fin_category_id),f.fin_category_id)';

		l_budget_decode := 'and f.fin_category_id = DECODE(:G_ID, f.fin_category_id,
									DECODE(f.time_id,:TIME_ID, f.fin_category_id,-99999),f.fin_category_id)';
	END IF;

  ELSIF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
	l_if_leaf_flag := fii_ea_util_pkg.g_ud1_is_leaf;

-- This issue was found during testing of fix for bug 4127077. Since these variables are used to check for loading of budgets against summary nodes,
-- we don't need to append l_budget_snap_decode and l_budget_decode to the main sql, when we choose a leaf fud1 node.

	IF l_if_leaf_flag = 'N' THEN
		l_fud1_decode := 'and fud1_hier.parent_value_id = DECODE(fud1_hier.parent_value_id, :UDD1_ID,
									 fud1_hier.child_value_id, fud1_hier.parent_value_id)';
		l_budget_snap_decode := 'and f.fud1_id = DECODE( :G_ID, f.fud1_id,
								DECODE(budget_cur_'||l_roll_column||',0, -99999, f.fud1_id),f.fud1_id)';
		l_budget_decode := 'and f.fud1_id = DECODE(:G_ID, f.fud1_id,
									DECODE(f.time_id,:TIME_ID, f.fud1_id,-99999),f.fud1_id)';
	END IF;
  ELSE
	l_if_leaf_flag := 'Y';
  END IF;

  -- Done for enhancement 4269343
  -- Depending upon the drill source, i.e. Funds Management Page OR Expense Analysis page, the drill source
  -- changes accordingly

   SELECT DECODE(fii_ea_util_pkg.g_region_code,'FII_EA_EXP_SUM','FII_EA_EXP_SUM','FII_PSI_EXP_SUM')
     INTO l_drill_source
     FROM DUAL;

-- Checking if User Defined Dimension2 is enabled

SELECT	dbi_enabled_flag INTO l_fud2_enabled_flag
FROM	fii_financial_dimensions
WHERE	dimension_short_name = 'FII_USER_DEFINED_2';

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

	l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

	l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
				and fud2_hier.child_value_id = f.fud2_id ';

	l_fud2_where := '	and fud2_hier.parent_value_id = inner_inline_view.fud2_id
		                and fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

	l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

	l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
				and fud2_hier.child_value_id = f.fud2_id ';

	l_fud2_where := '	and fud2_hier.parent_value_id = inner_inline_view.fud2_id
		                and fud2_hier.child_value_id = f.fud2_id ';
  END IF;

END IF;

IF fii_ea_util_pkg.g_fin_cat_type = 'R' THEN
	l_viewby_drill_url := 'pFunctionName=FII_EA_REV_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_xtd_drill_url := 'pFunctionName=FII_EA_REV_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
ELSIF fii_ea_util_pkg.g_fin_cat_type = 'CGS' THEN
	l_viewby_drill_url := 'pFunctionName=FII_PL_COGS_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_xtd_drill_url := 'pFunctionName=FII_PL_CGS_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
ELSE
	l_viewby_drill_url := 'pFunctionName='||l_drill_source||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_xtd_drill_url := 'pFunctionName=FII_EA_EXP_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

-- l_sqlstmt1 is the sql to be used, when when report_date <> sysdate and fii_pmv_aggrt_gt has been populated

l_sqlstmt1 := ' /* this query returns data for aggregated nodes */

		SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
			'||p_aggrt_viewby_id||'   viewby_id,
			inner_inline_view.viewby viewby,
			inner_inline_view.sort_order sort_order,
			SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
			  		THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL1,
			SUM(DECODE(inner_inline_view.report_date,:PREVIOUS_TWO_END_DATE,
				(CASE WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL2,
			SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL3,
			SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL4,
			SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END) ) )   FII_EA_XTD_EXP,
			'||l_bud_frcst_prior||'
			SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END) ) )   FII_EA_BUDGET,
			SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_FORECAST


		FROM	fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
	 		'||l_fud2_from||'
			(	select	/*+ NO_MERGE cardinality(gt 1) */ *
				from 	fii_time_structures cal,
					fii_pmv_aggrt_gt gt
		     	        where	report_date in ( :PREVIOUS_ONE_END_DATE, :PREVIOUS_TWO_END_DATE,
							 :PREVIOUS_THREE_END_DATE, :ASOF_DATE,
							 :PREVIOUS_ASOF_DATE
						       )
					and (	bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
						bitand(cal.record_type_id, :HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND OR
						bitand(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
						bitand(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
					    )

		        ) inner_inline_view

		WHERE 	f.time_id = inner_inline_view.time_id
			and f.period_type_id = inner_inline_view.period_type_id
			and f.parent_company_id = inner_inline_view.parent_company_id
			and f.company_id = inner_inline_view.company_id
			and f.parent_cost_center_id = inner_inline_view.parent_cc_id
			and f.cost_center_id = inner_inline_view.cc_id
			and f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
			and f.fin_category_id = inner_inline_view.fin_category_id
			'||l_budget_decode||'
			and f.parent_fud1_id = inner_inline_view.parent_fud1_id
			and f.fud1_id = inner_inline_view.fud1_id
			'||l_fud2_where||'

		GROUP BY	'||p_aggrt_viewby_id||',
				inner_inline_view.viewby,
				inner_inline_view.sort_order';

-- l_sqlstmt2 is the sql to be used, when report_date <> sysdate and fii_pmv_non_aggrt_gt has been populated

l_sqlstmt2 := ' /* this query returns data for non_aggregated nodes */

		SELECT	/*+ index(f fii_gl_base_map_mv_n1) */
				'||p_nonaggrt_viewby_id||'     viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				  		THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date,:PREVIOUS_TWO_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL4,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_XTD_EXP,
				'||l_bud_frcst_prior||'
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
						THEN f.budget_g  ELSE NULL END) ) )   FII_EA_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
						THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_FORECAST

		FROM	fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
			fii_company_hierarchies co_hier,
			fii_cost_ctr_hierarchies cc_hier,
			fii_fin_item_leaf_hiers fin_hier,
			fii_udd1_hierarchies fud1_hier,
           		'||l_fud2_from||'
			(	select	/*+ NO_MERGE cardinality(gt 1) */ *
				from 	fii_time_structures cal,
					fii_pmv_non_aggrt_gt gt
		     	        where	report_date in ( :PREVIOUS_ONE_END_DATE, :PREVIOUS_TWO_END_DATE,
							 :PREVIOUS_THREE_END_DATE, :ASOF_DATE,
							 :PREVIOUS_ASOF_DATE
						       )
					and (	bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
						bitand(cal.record_type_id, :HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND OR
						bitand(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
						bitand(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
					    )

		        ) inner_inline_view


		WHERE 	f.period_type_id = inner_inline_view.period_type_id
			and f.time_id = inner_inline_view.time_id
                	and co_hier.parent_company_id = inner_inline_view.company_id
			and co_hier.child_company_id = f.company_id
		        and cc_hier.parent_cc_id = inner_inline_view.cost_center_id
			and cc_hier.child_cc_id = f.cost_center_id
             		and fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
			'||l_cat_decode||'
			'||l_budget_decode||'
			and fin_hier.child_fin_cat_id = f.fin_category_id
		        and fud1_hier.parent_value_id = inner_inline_view.fud1_id
			'||l_fud1_decode||'
			and fud1_hier.child_value_id = f.fud1_id
			'||l_fud2_where||'

		GROUP BY 	'||p_nonaggrt_viewby_id||',
				inner_inline_view.viewby,
				inner_inline_view.sort_order';

l_snap_sqlstmt1 := '/* This query returns xtd, Prior xtd, budget, forecast and HIST4 values for aggregated nodes */

		SELECT		/*+ index(f fii_gl_snap_sum_f_n1) */
				'||p_snap_aggrt_viewby_id||'   viewby_id,
				gt.viewby viewby,
				gt.sort_order sort_order,
				NULL   	FII_EA_HIST_COL1,
				NULL   	FII_EA_HIST_COL2,
				NULL	FII_EA_HIST_COL3,
				SUM(f.actual_cur_'||l_roll_column||')   FII_EA_HIST_COL4,
				SUM(f.actual_cur_'||l_xtd_column||')    FII_EA_XTD_EXP,
				'||l_snap_prior||'
				SUM(f.budget_cur_'||l_xtd_column||')    FII_EA_BUDGET,
				SUM(f.forecast_cur_'||l_xtd_column||')  FII_EA_FORECAST


		FROM		fii_gl_snap_sum_f'||fii_ea_util_pkg.g_curr_view||' f,
 				'||l_fud2_from||'
				fii_pmv_aggrt_gt gt

		WHERE 		f.parent_company_id = gt.parent_company_id
				and f.company_id = gt.company_id
				and f.parent_cost_center_id = gt.parent_cc_id
				and f.cost_center_id =gt.cc_id
				and f.parent_fin_category_id = gt.parent_fin_category_id
				and f.fin_category_id = gt.fin_category_id
				'||l_budget_snap_decode||'
				and f.parent_fud1_id = gt.parent_fud1_id
				and f.fud1_id =gt.fud1_id
				'||l_fud2_snap_where||'

		GROUP BY	'||p_snap_aggrt_viewby_id||', gt.viewby, gt.sort_order

		UNION ALL

/* This query returns HIST1, HIST2 and HIST3 values for aggregated nodes */

		SELECT		/*+ index(f fii_gl_agrt_sum_mv_n1) */
				'||p_aggrt_viewby_id||'   viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_THREE_END_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))	FII_EA_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))	FII_EA_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))	FII_EA_HIST_COL3,
				NULL   FII_EA_HIST_COL4,
				NULL   FII_EA_XTD_EXP,
				NULL   FII_EA_PRIOR_XTD_EXP_G,
				NULL   FII_EA_PRIOR_XTD_EXP,
				NULL   FII_EA_PRIOR_BUDGET,
				NULL   FII_EA_PRIOR_FORECAST,
				SUM(DECODE(inner_inline_view.report_date, :PRIOR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_TOTAL_G,
			        SUM(DECODE(inner_inline_view.report_date, :CURR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_CURR_TOTAL_G,
				NULL   FII_EA_BUDGET,
				NULL   FII_EA_FORECAST

		FROM		fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
			 	'||l_fud2_from||'
				( select /*+ NO_MERGE cardinality(gt 1) */ *
				  from 	fii_time_structures cal,
					fii_pmv_aggrt_gt gt
				  where report_date in ( :PREVIOUS_ONE_END_DATE, :PREVIOUS_TWO_END_DATE,
							 :PREVIOUS_THREE_END_DATE
						       )
					and ( BITAND(cal.record_type_id, :HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND OR
                 			      BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
					    )

				) inner_inline_view

		WHERE 		f.time_id = inner_inline_view.time_id
				and f.period_type_id = inner_inline_view.period_type_id
				and f.parent_company_id = inner_inline_view.parent_company_id
				and f.company_id = inner_inline_view.company_id
				and f.parent_cost_center_id = inner_inline_view.parent_cc_id
				and f.cost_center_id = inner_inline_view.cc_id
				and f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
				and f.fin_category_id = inner_inline_view.fin_category_id
				'||l_budget_decode||'
				and f.parent_fud1_id = inner_inline_view.parent_fud1_id
				and f.fud1_id = inner_inline_view.fud1_id
				'||l_fud2_where||'

		GROUP BY	'||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- logic for bug fix 4099357.. if we choose node A which has 2 children B & C, then, we want to
-- display A in the tabular data, only if there is budget/forecast loaded directly against A. For this, while keeping
-- parent_fin_cat_id as A, we want to look only for A in fii_gl_base_map_mv hence we introduced
-- conditional decode statements l_cat_decode and l_fud1_decode  in l_sqlstmt2 and l_snap_sqlstmt2..


l_snap_sqlstmt2 := ' /* This query returns value for xtd and all 4 rolling period columns for non - aggregated nodes */

		SELECT		/*+ index(f fii_gl_base_map_mv_n1) */

				'||p_nonaggrt_viewby_id||'     viewby_id,
		        	inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_THREE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL4,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_XTD_EXP,
				'||l_bud_frcst_prior||'
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
						THEN f.budget_g  ELSE NULL END) ) )   FII_EA_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
						THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_FORECAST


		FROM		fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
				fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
	           		'||l_fud2_from||'
				( select 	/*+ NO_MERGE cardinality(gt 1) */ *
				  from 		fii_time_structures cal,
 						fii_pmv_non_aggrt_gt gt
				  where		report_date in ( :PREVIOUS_ONE_END_DATE, :PREVIOUS_TWO_END_DATE,
								 :PREVIOUS_THREE_END_DATE, :ASOF_DATE,
								 :PREVIOUS_ASOF_DATE
								)
						and (	bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
							bitand(cal.record_type_id, :HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND OR
							bitand(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
							bitand(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
		  				    )

				) inner_inline_view


		WHERE 		f.period_type_id = inner_inline_view.period_type_id
				and f.time_id = inner_inline_view.time_id
		        	and co_hier.parent_company_id = inner_inline_view.company_id
				and co_hier.child_company_id = f.company_id
	                        and cc_hier.parent_cc_id = inner_inline_view.cost_center_id
		                and cc_hier.child_cc_id = f.cost_center_id
		             	and fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
				'||l_cat_decode||'
				and fin_hier.child_fin_cat_id = f.fin_category_id
		                and fud1_hier.parent_value_id = inner_inline_view.fud1_id
				'||l_fud1_decode||'
				'||l_budget_decode||'
				and fud1_hier.child_value_id = f.fud1_id
		            	'||l_fud2_where||'

		GROUP BY 	'||p_nonaggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

l_trend_sum_mv_sql :='
			SELECT	'||p_aggrt_viewby_id||'     viewby_id,
		       		inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_THREE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   	FII_EA_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_HIST_COL4,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
						THEN f.actual_g  ELSE NULL END) ) )   FII_EA_XTD_EXP,
				'||l_bud_frcst_prior||'
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
						THEN f.budget_g  ELSE NULL END) ) )   FII_EA_BUDGET,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
						THEN f.forecast_g  ELSE NULL END) ) )   FII_EA_FORECAST


			FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
				( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
				  FROM 		fii_time_structures cal,
 						fii_pmv_aggrt_gt gt
				   where		report_date in ( :PREVIOUS_ONE_END_DATE, :PREVIOUS_TWO_END_DATE,
								 :PREVIOUS_THREE_END_DATE, :ASOF_DATE,
								 :PREVIOUS_ASOF_DATE
								)
						and (	bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
							bitand(cal.record_type_id, :HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND OR
							bitand(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
							bitand(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
		  				    )
				) inner_inline_view

			WHERE 	f.time_id = inner_inline_view.time_id
				AND f.period_type_id = inner_inline_view.period_type_id
		                AND f.parent_company_id = inner_inline_view.parent_company_id
                                AND f.company_id = inner_inline_view.company_id
                                AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
                                AND f.cost_center_id = inner_inline_view.cc_id
                                AND f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		                AND f.fin_category_id = inner_inline_view.fin_category_id
				'||l_budget_decode||'

			GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

 IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN

	l_aggrt_sql := l_trend_sum_mv_sql;

 ELSIF fii_ea_util_pkg.g_snapshot = 'Y' THEN


	IF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated

		l_aggrt_sql := l_snap_sqlstmt1;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_non_aggrt_sql := l_snap_sqlstmt2;
			l_union_all := 'UNION ALL';
		END IF;

	ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated

			l_non_aggrt_sql := l_snap_sqlstmt2;

	ELSE	-- neither of the GT tables are populated...

		l_aggrt_sql := l_snap_sqlstmt1;

	END IF;
ELSE
	IF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated

		l_aggrt_sql := l_sqlstmt1;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_non_aggrt_sql := l_sqlstmt2;
			l_union_all := 'UNION ALL';
		END IF;

	ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated

			l_non_aggrt_sql := l_sqlstmt2;

	ELSE	-- neither of the GT tables are populated...

		l_aggrt_sql := l_sqlstmt1;

	END IF;

END IF;

 sqlstmt :='
		SELECT  DECODE(:G_ID, inline_view.viewby_id,DECODE('''||l_if_leaf_flag||''',''Y'',
									inline_view.viewby, inline_view.viewby||'' ''||:DIR_MSG),
			inline_view.viewby) VIEWBY,
			inline_view.viewby_id			VIEWBYID,
			SUM(FII_EA_PRIOR_XTD_EXP_G)		FII_EA_PRIOR_XTD_EXP_G,
			SUM(FII_EA_PRIOR_TOTAL_G)		FII_EA_PRIOR_TOTAL_G,
			SUM(FII_EA_XTD_EXP)                     FII_EA_XTD_EXP,
			SUM(FII_EA_CURR_TOTAL_G)		FII_EA_CURR_TOTAL_G,
			SUM(FII_EA_PRIOR_XTD_EXP)		FII_EA_PRIOR_XTD_EXP,
			SUM(FII_EA_PRIOR_BUDGET)		FII_EA_PRIOR_BUDGET,
			SUM(FII_EA_PRIOR_FORECAST)		FII_EA_PRIOR_FORECAST,
			SUM(FII_EA_BUDGET)			FII_EA_BUDGET,
			SUM(FII_EA_FORECAST)			FII_EA_FORECAST,
			SUM(FII_EA_HIST_COL1)			FII_EA_HIST_COL1,
			SUM(FII_EA_HIST_COL2)			FII_EA_HIST_COL2,
			SUM(FII_EA_HIST_COL3)			FII_EA_HIST_COL3,
			SUM(FII_EA_HIST_COL4)			FII_EA_HIST_COL4,
			SUM(SUM(FII_EA_XTD_EXP)) OVER ()        FII_EA_GT_XTD_EXP,
			SUM(SUM(FII_EA_PRIOR_XTD_EXP)) OVER ()  FII_EA_GT_PRIOR_XTD_EXP,
			(SUM(SUM(FII_EA_XTD_EXP)) over() -
			    SUM(SUM(FII_EA_PRIOR_XTD_EXP)) over()) /
			    ABS(NULLIF(SUM(SUM(FII_EA_PRIOR_XTD_EXP)) over(),0)) * 100  FII_EA_GT_CHANGE,
			SUM(SUM(FII_EA_BUDGET)) OVER ()       FII_EA_GT_BUDGET,
			NULLIF(SUM(SUM(FII_EA_PRIOR_BUDGET)) OVER (),0)       FII_EA_GT_PRIOR_BUDGET,
			SUM(SUM(FII_EA_XTD_EXP)) OVER () /
			   NULLIF(SUM(SUM(FII_EA_BUDGET)) OVER (),0) * 100 	 FII_EA_GT_PCNT_BUDGET,
			SUM(SUM(FII_EA_FORECAST)) OVER ()        		 FII_EA_GT_FORECAST,
			NULLIF(SUM(SUM(FII_EA_PRIOR_FORECAST)) OVER (),0)        		 FII_EA_GT_PRIOR_FORECAST,
			SUM(SUM(FII_EA_XTD_EXP)) OVER () /
				NULLIF(SUM(SUM(FII_EA_FORECAST)) OVER (),0) * 100 	 FII_EA_GT_PCNT_FORECAST,
			SUM(SUM(FII_EA_HIST_COL1)) OVER ()  FII_EA_GT_HIST_COL1,
			SUM(SUM(FII_EA_HIST_COL2)) OVER ()  FII_EA_GT_HIST_COL2,
			SUM(SUM(FII_EA_HIST_COL3)) OVER ()  FII_EA_GT_HIST_COL3,
			SUM(SUM(FII_EA_HIST_COL4)) OVER () FII_EA_GT_HIST_COL4,

			DECODE((SELECT  is_leaf_flag
				FROM    fii_company_hierarchies
				WHERE	parent_company_id = inline_view.viewby_id
					and child_company_id = inline_view.viewby_id),
				''Y'',
				'''',
				'''||l_viewby_drill_url||''') FII_EA_COMP_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM    fii_cost_ctr_hierarchies
				WHERE	parent_cc_id = inline_view.viewby_id
					and child_cc_id = inline_view.viewby_id),
				''Y'',
				'''',
				'''||l_viewby_drill_url||''')	FII_EA_CC_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM    fii_fin_item_leaf_hiers
				WHERE	parent_fin_cat_id = inline_view.viewby_id
					and child_fin_cat_id = inline_view.viewby_id),
				''Y'',
				'''',
				DECODE(:G_ID, inline_view.viewby_id,'''',
					'''||l_viewby_drill_url||''')) FII_EA_CAT_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM    fii_udd1_hierarchies
				WHERE	parent_value_id = inline_view.viewby_id
					and child_value_id = inline_view.viewby_id),
				''Y'',
				'''',
				DECODE(:G_ID, inline_view.viewby_id,'''',
					'''||l_viewby_drill_url||''')) FII_EA_UDD1_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM    fii_udd2_hierarchies
				WHERE	parent_value_id = inline_view.viewby_id
					and child_value_id = inline_view.viewby_id),
				''Y'',
				'''',
				'''||l_viewby_drill_url||''')	 FII_EA_UDD2_DRILL,
			DECODE(SUM(FII_EA_XTD_EXP),0,'''',DECODE(NVL(SUM(FII_EA_XTD_EXP),-999999),-999999,'''','''||l_xtd_drill_url||''')) FII_EA_XTD_DRILL,
			DECODE(SUM(FII_EA_XTD_EXP),0,'''',DECODE(NVL(SUM(FII_EA_XTD_EXP),-999999),-999999,'''','''||l_xtd_drill_url||'''))
FII_EA_XTD_PIE_DRILL

	FROM
		(
			'||l_aggrt_sql||'
			'||l_union_all||'
			'||l_non_aggrt_sql||'


		) inline_view

GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order

ORDER BY 	NVL(inline_view.sort_order,999999) asc, NVL(FII_EA_XTD_EXP, -999999999) desc'; /* Done for bug 4093082 */


  return sqlstmt;

END get_revexp_sum;

-- Added for Cost of Goods Sold Rolling Trend
-- Profit and Loss Analysis, DBI 7.3
PROCEDURE get_cogs_trend ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                          ,p_cogs_trend_sql     OUT NOCOPY VARCHAR2
                          ,p_cogs_trend_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'CGS';

    l_sqlstmt := fii_ea_sum_trend_pkg.get_revexp_trend(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable( l_sqlstmt
                                  ,p_page_parameter_tbl
				  ,p_cogs_trend_sql
				  ,p_cogs_trend_output
				  );

END get_cogs_trend;


-- get_exp_trend procedure is called by Expense Rolling Trend report. It is a wrapper for get_revexp_trend.

PROCEDURE get_exp_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_trend_sql out NOCOPY VARCHAR2,
  exp_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'OE';

    sqlstmt := fii_ea_sum_trend_pkg.get_revexp_trend(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_trend_sql, exp_trend_output);

END get_exp_trend;

-- get_rev_trend procedure is called by Revenue Rolling Trend report. It is a wrapper for get_revexp_trend.

PROCEDURE get_rev_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_trend_sql out NOCOPY VARCHAR2,
  rev_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'R';

    sqlstmt := fii_ea_sum_trend_pkg.get_revexp_trend(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_trend_sql, rev_trend_output);

END get_rev_trend;

-- get_revexp_trend is a common procedure, used both by Expense and Revenue Rolling Trend reports

FUNCTION get_revexp_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 IS

  sqlstmt			VARCHAR2(15000);
  l_agrt_snap_sql		VARCHAR2(15000);
  l_agrt_sql			VARCHAR2(15000);
  l_base_map_sql		VARCHAR2(15000);
  l_base_map_snap_sql		VARCHAR2(15000);
  l_union_agrt_snap_sql		VARCHAR2(2000);
  l_union_base_snap_sql		VARCHAR2(5000);
  p_aggrt_gt_is_empty		VARCHAR2(1);
  p_non_aggrt_gt_is_empty	VARCHAR2(1);
  l_union_all			VARCHAR2(10);
  l_sqlstmt1			VARCHAR2(10000) := NULL;
  l_sqlstmt2			VARCHAR2(10000) := NULL;
  l_xtd_drill_url	        VARCHAR2(300);
  l_ledger_where		VARCHAR2(500);
  l_curr_per_sequence		NUMBER;
  l_cat_type			VARCHAR2(10);
  l_curr_end_date		DATE;
  l_fud2_enabled_flag		VARCHAR2(1);
  l_fud2_where			VARCHAR2(300);
  l_fud2_from			VARCHAR2(100);
  l_trend_sum_mv_sql		VARCHAR2(10000) := NULL;

BEGIN

fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ea_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
fii_ea_util_pkg.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);
l_ledger_where := fii_ea_util_pkg.get_ledger_for_detail;

SELECT	DISTINCT per.sequence INTO l_curr_per_sequence
FROM	FII_TIME_ENT_PERIOD per
WHERE	fii_ea_util_pkg.g_as_of_date BETWEEN per.start_date and per.end_date;

IF fii_ea_util_pkg.g_fin_cat_type = 'R' THEN
	l_cat_type := 'EA_REV';
ELSIF fii_ea_util_pkg.g_fin_cat_type = 'CGS' THEN
	l_cat_type := 'PL_CGS';
ELSE
	l_cat_type := 'EA_EXP';
END IF;

SELECT	end_date INTO l_curr_end_date
FROM	fii_time_ent_period
WHERE	fii_ea_util_pkg.g_as_of_date between start_date and end_date;

-- Checking if User Defined Dimension2 is enabled

SELECT dbi_enabled_flag
  INTO l_fud2_enabled_flag
  FROM fii_financial_dimensions
 WHERE dimension_short_name = 'FII_USER_DEFINED_2';

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

	l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

	l_fud2_where := '	and fud2_hier.parent_value_id = gt.fud2_id
		                and fud2_hier.child_value_id = f.fud2_id ';
  END IF;

END IF;


IF fii_ea_util_pkg.g_as_of_date <> l_curr_end_date THEN
	l_union_agrt_snap_sql := 'UNION ALL

			SELECT	/*+ index(f fii_gl_snap_sum_f_n1) */
				'||l_curr_per_sequence||'		 FII_EFFECTIVE_NUM,
				f.actual_cur_mtd FII_EA_XTD,
				f.actual_last_year_mtd 		 FII_EA_PRIOR_XTD
		       FROM     fii_gl_snap_sum_f'||fii_ea_util_pkg.g_curr_view||' f ,
				'||l_fud2_from||'
				fii_pmv_aggrt_gt gt
		       WHERE    f.parent_company_id = gt.parent_company_id
				and f.company_id = gt.company_id
				and f.parent_cost_center_id = gt.parent_cc_id
				and f.cost_center_id = gt.cc_id
				and f.parent_fin_category_id = gt.parent_fin_category_id
				and f.fin_category_id = gt.fin_category_id
				and f.parent_fud1_id = gt.parent_fud1_id
				and f.fud1_id = gt.fud1_id
				'||l_fud2_where||l_ledger_where;

	l_union_base_snap_sql := 'UNION ALL

			SELECT  /*+ index(f fii_gl_base_map_mv_n1) */
				'||l_curr_per_sequence||'                      FII_EFFECTIVE_NUM,
				CASE	WHEN	cal.report_date =  :ASOF_DATE
				THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
				CASE	WHEN	cal.report_date =  :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD

			FROM    fii_time_structures      cal,
			        fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
			        fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
           			'||l_fud2_from||'
				fii_pmv_non_aggrt_gt gt

			WHERE   cal.time_id = f.time_id
				and cal.report_date in (:ASOF_DATE,:SD_PRIOR)
				and cal.period_type_id = f.period_type_id
				and bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
                		and co_hier.parent_company_id = gt.company_id
				and co_hier.child_company_id = f.company_id
			        and cc_hier.parent_cc_id = gt.cost_center_id
				and cc_hier.child_cc_id = f.cost_center_id
             			and fin_hier.parent_fin_cat_id = gt.fin_category_id
				and fin_hier.child_fin_cat_id = f.fin_category_id
				and fud1_hier.parent_value_id = gt.fud1_id
				and fud1_hier.child_value_id = f.fud1_id
				'||l_fud2_where||l_ledger_where;
END IF;


 l_agrt_snap_sql :='
			SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
				per.sequence                      FII_EFFECTIVE_NUM,
				CASE	WHEN	per.start_date > :SD_PRIOR
						and  per.end_date  <=  :ASOF_DATE
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
				CASE	WHEN	per.end_date <= :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD
			FROM    fii_time_ent_period      per,
			        fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
			        '||l_fud2_from||'
				fii_pmv_aggrt_gt gt

			WHERE   per.ent_period_id = f.time_id
				and f.period_type_id = 32
				and per.start_date >  :SD_PRIOR_PRIOR
				and per.end_date   <=  :ASOF_DATE
				and  f.parent_company_id = gt.parent_company_id
				and f.company_id = gt.company_id
				and f.parent_cost_center_id = gt.parent_cc_id
				and f.cost_center_id = gt.cc_id
				and f.parent_fin_category_id = gt.parent_fin_category_id
				and f.fin_category_id = gt.fin_category_id
				and f.parent_fud1_id = gt.parent_fud1_id
				and f.fud1_id = gt.fud1_id
				'||l_fud2_where||l_ledger_where||l_union_agrt_snap_sql;

 l_agrt_sql :='
			SELECT  /*+ index(f fii_gl_agrt_sum_mv_n1) */
				per.sequence                      FII_EFFECTIVE_NUM,
				CASE	WHEN	per.start_date > :SD_PRIOR
						and per.end_date  <=  :ASOF_DATE
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
		  		CASE	WHEN	per.end_date <= :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD
			FROM    fii_time_ent_period      per,
			        fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
			        '||l_fud2_from||'
				fii_pmv_aggrt_gt gt

			WHERE   per.ent_period_id = f.time_id
				and f.period_type_id = 32
				and per.start_date >  :SD_PRIOR_PRIOR
				and per.end_date   <= :ASOF_DATE
				and  f.parent_company_id = gt.parent_company_id
				and f.company_id = gt.company_id
				and f.parent_cost_center_id = gt.parent_cc_id
				and f.cost_center_id = gt.cc_id
				and f.parent_fin_category_id = gt.parent_fin_category_id
				and f.fin_category_id = gt.fin_category_id
				and f.parent_fud1_id = gt.parent_fud1_id
				and f.fud1_id = gt.fud1_id
				'||l_fud2_where||l_ledger_where;


 l_base_map_snap_sql :='
			SELECT  /*+ index(f fii_gl_base_map_mv_n1) */
				per.sequence                      FII_EFFECTIVE_NUM,
				CASE	WHEN	per.start_date > :SD_PRIOR
						and per.end_date  <=  :ASOF_DATE
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
				CASE	WHEN	per.end_date <= :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD
			FROM    fii_time_ent_period      per,
			        fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
			        fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
           			 '||l_fud2_from||'
				fii_pmv_non_aggrt_gt gt

			WHERE   per.ent_period_id = f.time_id
				and f.period_type_id = 32
				and per.start_date >  :SD_PRIOR_PRIOR
				and per.end_date   <=  :ASOF_DATE
                		and co_hier.parent_company_id = gt.company_id
				and co_hier.child_company_id = f.company_id
			        and cc_hier.parent_cc_id = gt.cost_center_id
				and cc_hier.child_cc_id = f.cost_center_id
             			and fin_hier.parent_fin_cat_id = gt.fin_category_id
				and fin_hier.child_fin_cat_id = f.fin_category_id
				and fud1_hier.parent_value_id = gt.fud1_id
				and fud1_hier.child_value_id = f.fud1_id
				'||l_fud2_where||l_ledger_where||l_union_base_snap_sql;



l_base_map_sql :='
			SELECT  /*+ index(f fii_gl_base_map_mv_n1) */
				per.sequence                      FII_EFFECTIVE_NUM,
				CASE	WHEN	per.start_date > :SD_PRIOR
						and per.end_date  <=  :ASOF_DATE
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
				CASE	WHEN	per.end_date <= :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD
			FROM    fii_time_ent_period      per,
			        fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
			        fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
           			 '||l_fud2_from||'
				fii_pmv_non_aggrt_gt gt

			WHERE   per.ent_period_id = f.time_id
				and f.period_type_id = 32
				and per.start_date >  :SD_PRIOR_PRIOR
				and per.end_date   <=  :ASOF_DATE
                		and co_hier.parent_company_id = gt.company_id
				and co_hier.child_company_id = f.company_id
			        and cc_hier.parent_cc_id = gt.cost_center_id
				and cc_hier.child_cc_id = f.cost_center_id
             			and fin_hier.parent_fin_cat_id = gt.fin_category_id
				and fin_hier.child_fin_cat_id = f.fin_category_id
				and fud1_hier.parent_value_id = gt.fud1_id
				and fud1_hier.child_value_id = f.fud1_id
				'||l_fud2_where||l_ledger_where;

 l_trend_sum_mv_sql :='
			SELECT  per.sequence                      FII_EFFECTIVE_NUM,
				CASE	WHEN	per.start_date > :SD_PRIOR
						and per.end_date  <=  :ASOF_DATE
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_XTD,
		  		CASE	WHEN	per.end_date <= :SD_PRIOR
					THEN	f.actual_g ELSE to_number(NULL)
				END        FII_EA_PRIOR_XTD
			FROM    fii_time_ent_period      per,
			        fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
				fii_pmv_aggrt_gt gt

			WHERE   per.ent_period_id = f.time_id
				and f.period_type_id = 32
				and per.start_date >  :SD_PRIOR_PRIOR
				and per.end_date   <= :ASOF_DATE
				and  f.parent_company_id = gt.parent_company_id
				and f.company_id = gt.company_id
				and f.parent_cost_center_id = gt.parent_cc_id
				and f.cost_center_id = gt.cc_id
				and f.parent_fin_category_id = gt.parent_fin_category_id
				and f.fin_category_id = gt.fin_category_id';

-- IF fii_ea_util_pkg.g_as_of_date = trunc(sysdate) THEN
/* commented out temporarily for testing snapshot table queries */
  IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN
	l_sqlstmt1 := l_trend_sum_mv_sql;

  ELSIF fii_ea_util_pkg.g_snapshot = 'Y' THEN


	IF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated

		l_sqlstmt1 := l_agrt_snap_sql;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_sqlstmt2 := l_base_map_snap_sql;
			l_union_all := 'UNION ALL';
		END IF;

	ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated

			l_sqlstmt2 := l_base_map_snap_sql;

	ELSE	-- neither of the GT tables are populated...

		l_sqlstmt1 := l_agrt_snap_sql;

	END IF;
ELSE
	IF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated

		l_sqlstmt1 := l_agrt_sql;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_sqlstmt2 := l_base_map_sql;
			l_union_all := 'UNION ALL';
		END IF;

	ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated

			l_sqlstmt2 := l_base_map_sql;

	ELSE	-- neither of the GT tables are populated...

		l_sqlstmt1 := l_agrt_sql;

	END IF;

END IF;

/*
Logic for MTD drill region item, FII_EA_XTD_DRILL:

IF MTD amount is 0 THEN NO DRILL
ELSIF MTD amount is NULL THEN NO DRILL
ELSIF month-end date is > fii_ea_util_pkg.g_as_of_date THEN pass sysdate to called report
ELSE pass month-end date to called report
END IF;
*/


sqlstmt := '
		SELECT	cy_per.name                           VIEWBY,
			to_char(cy_per.end_date,''DD/MM/YYYY'') FII_EA_MONTH_END_DATE,
			inline_view.FII_EA_XTD            FII_EA_XTD,

		        inline_view.FII_EA_PRIOR_XTD      FII_EA_PRIOR_XTD,
			DECODE(FII_EA_XTD,0,'''',DECODE(NVL(FII_EA_XTD,-999999),-999999,'''',
			DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
			''pFunctionName=FII_EA_'||l_cat_type||'_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',
			''AS_OF_DATE=FII_EA_MONTH_END_DATE&pFunctionName=FII_'||l_cat_type||'_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''))) FII_EA_XTD_DRILL
		FROM
			fii_time_ent_period cy_per,
		    (	SELECT	inner_inline_view.fii_effective_num  FII_EFFECTIVE_NUM,
				sum(FII_EA_XTD)                  FII_EA_XTD,
				sum(FII_EA_PRIOR_XTD)                         FII_EA_PRIOR_XTD
			FROM
			      (		'||l_sqlstmt1||'
					'||l_union_all||'
					'||l_sqlstmt2||'
			       ) inner_inline_view

		        GROUP BY inner_inline_view.fii_effective_num

		    ) inline_view

		WHERE	cy_per.start_date <= :ASOF_DATE
			and   cy_per.start_date  >= :SD_PRIOR
			and   cy_per.sequence = inline_view.fii_effective_num (+)

		ORDER BY cy_per.start_date';


  return sqlstmt;

END get_revexp_trend;

END fii_ea_sum_trend_pkg;


/
