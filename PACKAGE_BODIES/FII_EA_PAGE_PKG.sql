--------------------------------------------------------
--  DDL for Package Body FII_EA_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_PAGE_PKG" AS
/* $Header: FIIEAPAGEB.pls 120.10.12000000.2 2007/04/16 06:52:03 dhmehra ship $ */

PROCEDURE get_exp (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_ana_page_sql out NOCOPY VARCHAR2,
  exp_ana_page_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

sqlstmt                       VARCHAR2(30000);

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type := 'OE';

    sqlstmt := fii_ea_page_pkg.get_revexp(p_page_parameter_tbl);

fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_ana_page_sql, exp_ana_page_output);

END get_exp;



FUNCTION get_revexp (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 IS

  sqlstmt		        VARCHAR2(30000);
  p_aggrt_viewby_id		VARCHAR2(30);
  p_nonaggrt_viewby_id		VARCHAR2(30);
  p_snap_aggrt_viewby_id	VARCHAR2(30);
  p_aggrt_gt_is_empty		VARCHAR2(1);
  p_non_aggrt_gt_is_empty	VARCHAR2(1);
  l_xtd_drill_url	        VARCHAR2(300);
  l_prior			VARCHAR2(300);
  l_budget_decode 		VARCHAR2(300); -- Since we can load budget only against category AND fud1 summary nodes,
						-- this local variable appends a check to agrt MV AND base map MV queries, so that budget is checked only for xTD period.
						-- Budget loaded for prior xTD should not result in any unwanted record, having 0/NA in all columns..
  l_if_leaf_flag		VARCHAR2(1);	-- local var to denote, if category or fud1 param chosen to run the report is a leaf or not..
  l_change			VARCHAR2(300);
  l_gt_change			VARCHAR2(500);
-- Added for enhancement 4269343
  l_drill_source                VARCHAR2(40);
  l_prior_g			VARCHAR2(10000);

 BEGIN

 fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

fii_ea_util_pkg.get_viewby_id(p_aggrt_viewby_id, p_snap_aggrt_viewby_id, p_nonaggrt_viewby_id);

fii_ea_util_pkg.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

CASE fii_ea_util_pkg.g_time_comp

 WHEN 'BUDGET' THEN
		l_prior_g := 'SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					THEN f.budget_g  ELSE NULL END)))   FII_EA_PRIOR_XTD_EXP_G';

		l_prior := 'NULL   FII_EA_PRIOR_XTD_EXP';

		l_change := 'NULL FII_EA_CHANGE,';

		l_gt_change := 'NULL  FII_EA_GT_CHANGE,';

 WHEN 'FORECAST' THEN
		l_prior_g := 'SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					THEN f.forecast_g  ELSE NULL END)))   FII_EA_PRIOR_XTD_EXP_G';

		l_prior := 'NULL   FII_EA_PRIOR_XTD_EXP';

		l_change := 'NULL FII_EA_CHANGE,';

		l_gt_change := 'NULL  FII_EA_GT_CHANGE,';

ELSE
		l_prior_g := 'SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_XTD_EXP_G';

		l_prior := 'SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ASOF_DATE,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_XTD_EXP';

		l_change := 'SUM(((FII_EA_XTD_EXP-FII_EA_PRIOR_XTD_EXP)/ABS(NULLIF(FII_EA_PRIOR_XTD_EXP,0)))*100) FII_EA_CHANGE,';

		l_gt_change := '(SUM(SUM(FII_EA_XTD_EXP)) over() -
			    SUM(SUM(FII_EA_PRIOR_XTD_EXP)) over()) /
			    ABS(NULLIF(SUM(SUM(FII_EA_PRIOR_XTD_EXP)) over(),0)) * 100  FII_EA_GT_CHANGE,';
  END CASE;

IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);
	l_if_leaf_flag := fii_ea_util_pkg.g_fin_cat_is_leaf;

--  This issue was found during testing of fix for bug 4127077. Since these variables are used to
--  check for loading of budgets against summary nodes, we don't need to append
--  l_budget_decode to the main sql, when we choose a leaf category node.

	IF l_if_leaf_flag = 'N' THEN
		l_budget_decode := 'AND f.fin_category_id = DECODE(:G_ID, f.fin_category_id,
									DECODE(f.time_id,:TIME_ID, f.fin_category_id,-99999),f.fin_category_id)';
	END IF;
 ELSE
	l_if_leaf_flag := 'Y';
 END IF;

l_xtd_drill_url := 'pFunctionName=FII_EA_EXP_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

-- Done for enhancement 4269343
-- Depending upon the drill source, i.e. Funds Management Page OR Expense Analysis page, the drill source
-- changes accordingly

-- Added check for FII_EA_EXP_BY_COMP_PORT AK region


   SELECT DECODE(fii_ea_util_pkg.g_region_code,'FII_EA_PAGE','FII_EA_EXP_SUM','FII_EA_EXP_BY_COMP_PORT','FII_EA_EXP_SUM','FII_PSI_EXP_SUM')
     INTO l_drill_source
     FROM DUAL;

 sqlstmt :='
	SELECT  DECODE(:G_ID, inline_view.viewby_id,DECODE('''||l_if_leaf_flag||''',''Y'',
									inline_view.viewby, inline_view.viewby||'' ''||:DIR_MSG),
			inline_view.viewby) VIEWBY,
			inline_view.viewby_id			VIEWBYID,
			SUM(FII_EA_PRIOR_XTD_EXP_G)		FII_EA_PRIOR_XTD_EXP_G,
			SUM(FII_EA_PRIOR_TOTAL_G)		FII_EA_PRIOR_TOTAL_G,
			SUM(FII_EA_XTD_EXP)                     FII_EA_XTD_EXP,
			NULL					FII_EA_CURR_TOTAL_G,
			SUM(FII_EA_PRIOR_XTD_EXP)		FII_EA_PRIOR_XTD_EXP,
			'||l_change||'
			SUM(FII_EA_BUDGET)			FII_EA_BUDGET,
			SUM(FII_EA_FORECAST)			FII_EA_FORECAST,
			SUM(SUM(FII_EA_XTD_EXP)) OVER ()        FII_EA_GT_XTD_EXP,
			SUM(SUM(FII_EA_PRIOR_XTD_EXP)) OVER ()  FII_EA_GT_PRIOR_XTD_EXP,
			'||l_gt_change||'
			SUM(SUM(FII_EA_BUDGET)) OVER ()         FII_EA_GT_BUDGET,
			SUM(SUM(FII_EA_XTD_EXP)) OVER () /
			   NULLIF(SUM(SUM(FII_EA_BUDGET)) OVER (),0) * 100 FII_EA_GT_PCNT_BUDGET,
			SUM(SUM(FII_EA_FORECAST)) OVER ()        	   FII_EA_GT_FORECAST,
			SUM(SUM(FII_EA_XTD_EXP)) OVER () /
				NULLIF(SUM(SUM(FII_EA_FORECAST)) OVER (),0) * 100 FII_EA_GT_PCNT_FORECAST,

			DECODE((SELECT  is_leaf_flag
				FROM    fii_company_hierarchies
				WHERE	parent_company_id = inline_view.viewby_id
					AND child_company_id = inline_view.viewby_id),
				''Y'',
				'''',
				''pFunctionName='||l_drill_source||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')	FII_EA_COMP_DRILL,

			DECODE((SELECT  is_leaf_flag
				FROM    fii_cost_ctr_hierarchies
				WHERE	parent_cc_id = inline_view.viewby_id
					AND child_cc_id = inline_view.viewby_id),
				''Y'',
				'''',
				''pFunctionName='||l_drill_source||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')	FII_EA_CC_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM    fii_fin_item_leaf_hiers
				WHERE	parent_fin_cat_id = inline_view.viewby_id
					AND child_fin_cat_id = inline_view.viewby_id),
				''Y'',
				'''',
				DECODE(:G_ID, inline_view.viewby_id,'''',
					''pFunctionName='||l_drill_source||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')) FII_EA_CAT_DRILL,

			DECODE(SUM(FII_EA_XTD_EXP),0,'''',DECODE(NVL(SUM(FII_EA_XTD_EXP),-999999),-999999,'''','''||l_xtd_drill_url||''')) FII_EA_XTD_DRILL,
			DECODE(SUM(FII_EA_XTD_EXP),0,'''',DECODE(NVL(SUM(FII_EA_XTD_EXP),-999999),-999999,'''','''||l_xtd_drill_url||''')) FII_EA_XTD_PIE_DRILL

	FROM
	      (
			SELECT	'||p_aggrt_viewby_id||'     viewby_id,
		       		inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				'||l_prior_g||',
				SUM(DECODE(inner_inline_view.report_date, :PRIOR_PERIOD_END,
				(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_PRIOR_TOTAL_G,
				SUM(DECODE(inner_inline_view.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					THEN f.actual_g  ELSE NULL END)))   FII_EA_XTD_EXP,
				'||l_prior||',
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
				  WHERE		report_date in (:ASOF_DATE, :PREVIOUS_ASOF_DATE, :PRIOR_PERIOD_END)
						AND (	BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
							BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
							BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
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

			GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order

		) inline_view

GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order

ORDER BY 	NVL(inline_view.sort_order,999999) asc, NVL(FII_EA_XTD_EXP, -999999999) DESC';

 RETURN sqlstmt;

END get_revexp;

END fii_ea_page_pkg;


/
