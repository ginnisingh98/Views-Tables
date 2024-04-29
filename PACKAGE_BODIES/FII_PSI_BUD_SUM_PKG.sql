--------------------------------------------------------
--  DDL for Package Body FII_PSI_BUD_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PSI_BUD_SUM_PKG" AS
/* $Header: FIIPSIB1B.pls 120.7.12000000.2 2007/04/16 06:55:17 dhmehra ship $ */

g_fin_type	VARCHAR2(10);


/* Wrapper procedure for Expense */

PROCEDURE get_bud_sum (
  p_page_parameter_tbl	IN BIS_PMV_PAGE_PARAMETER_TBL,
  bud_sum_sql 		OUT NOCOPY VARCHAR2,
  bud_sum_output 	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

        sqlstmt                 VARCHAR2(17000);
	l_sqlstmt1		VARCHAR2(10000);
	l_sqlstmt2		VARCHAR2(10000);
        l_trend_sum_mv_sql	VARCHAR2(10000) := NULL;
	l_aggrt_sql 		VARCHAR2(10000) := NULL;
	l_non_aggrt_sql 	VARCHAR2(10000) := NULL;
	l_union_all 		VARCHAR2(15) := NULL;
	l_ledger_where		VARCHAR2(1000);
	l_roll_column		VARCHAR2(10);
	l_xtd_column		VARCHAR2(10);
	l_comp_detail_url	VARCHAR2(1000);
	l_cc_detail_url		VARCHAR2(1000);
	l_cat_detail_url	VARCHAR2(1000);
	l_journal_src_url	VARCHAR2(1000);
        l_xtd_drill_url         VARCHAR2(300);
	p_aggrt_gt_is_empty	VARCHAR2(10);
	p_non_aggrt_gt_is_empty	VARCHAR2(10);
	p_aggrt_viewby_id	VARCHAR2(100);
	p_nonaggrt_viewby_id	VARCHAR2(100);
	p_snap_aggrt_viewby_id        VARCHAR2(30); /* Added for Bug 4193545*/

 	l_cat_decode                  VARCHAR2(300); -- local variable to append decode check for category, when we have only 1 top node
  	l_fud1_decode                 VARCHAR2(300); -- local variable to append decode check for fud1, when viewby chosen is FUD1

  	l_time_id                     NUMBER;         -- local var for storing time_id of g_as_of_date, based on period type
  	l_fud2_enabled_flag           VARCHAR2(1);
  	l_fud2_where                  VARCHAR2(300);
  	l_fud2_snap_where             VARCHAR2(300);
  	l_fud2_from                   VARCHAR2(100);

BEGIN

FII_EA_UTIL_PKG.reset_globals;
FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);
FII_EA_UTIL_PKG.get_rolling_period;

FII_EA_UTIL_PKG.get_viewby_id(p_aggrt_viewby_id, p_snap_aggrt_viewby_id, p_nonaggrt_viewby_id);
FII_EA_UTIL_PKG.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

/* Setting 'period type' dependent variables in this CASE structure which need to be used in
dynamic pmv sql to retrieve data FROM the correct columns */

CASE fii_ea_util_pkg.g_page_period_type
WHEN 'FII_TIME_ENT_YEAR' THEN
	l_roll_column := 'qtd';
	l_xtd_column  := 'ytd' ;

 	SELECT  ent_year_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;

WHEN 'FII_TIME_ENT_QTR' THEN
	l_roll_column := 'mtd';
	l_xtd_column  := 'qtd' ;

 	SELECT  ent_qtr_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;
WHEN 'FII_TIME_ENT_PERIOD' THEN
        l_roll_column := 'mtd';
        l_xtd_column  := 'mtd' ;

 	SELECT  ent_period_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;

END CASE;

-- logic for fix to display DIRECT.. if we choose node A which has 2 children B & C, then, we want to
-- display A in the tabular data, only if there is budget/forecast loaded directly against A.
-- For this, while keeping parent_id as A, we want to look only for A in fii_gl_base_map_mv
-- so that we do not get duplication of actuals..hence we append conditional decode
-- statements l_cat_decode AND l_fud1_decode  in l_sqlstmt2 AND l_snap_sqlstmt2..

IF fii_ea_util_pkg.g_fin_category_id = 'All' THEN
        IF fii_ea_util_pkg.g_fin_cat_top_node_count = 1 THEN
                l_cat_decode := 'AND fin_hier.parent_fin_cat_id = decode(fin_hier.parent_fin_cat_id,:CATEGORY_ID,
                                                                         fin_hier.child_fin_cat_id,fin_hier.parent_fin_cat_id)';
        END IF;
ELSE
                l_cat_decode := 'AND fin_hier.parent_fin_cat_id = DECODE(fin_hier.parent_fin_cat_id, :CATEGORY_ID,
                                                                         fin_hier.child_fin_cat_id, fin_hier.parent_fin_cat_id)';
END IF;

IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN

        fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);

  ELSIF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

        fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
 	l_fud1_decode := 'AND fud1_hier.parent_value_id = DECODE(fud1_hier.parent_value_id, :UDD1_ID,
                                                          fud1_hier.child_value_id, fud1_hier.parent_value_id)';
  END IF;

/* Bug 4192452 - Start */

BEGIN
	SELECT  dbi_enabled_flag INTO l_fud2_enabled_flag
	FROM    fii_financial_dimensions
	WHERE   dimension_short_name = 'FII_USER_DEFINED_2';
END;

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  AND fud2_hier.parent_value_id = gt.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       AND fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  AND fud2_hier.parent_value_id = gt.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       AND fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';
  END IF;

END IF;

/* Bug 4192452 - End */

-- Constructing drilldown URL
l_xtd_drill_url := 'pFunctionName=FII_PSI_BUD_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

l_sqlstmt1 :=
	' /* this query returns data for aggregated nodes */

	SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
		'||p_aggrt_viewby_id||'   	viewby_id,
		inner_inline_view.viewby 	viewby,
		inner_inline_view.sort_order 	sort_order,
		SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   	FII_PSI_HIST_COL1,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   	FII_PSI_HIST_COL2,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL3,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL4,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_XTD,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_PRIOR,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.baseline_budget_g  ELSE NULL END) ) )   FII_PSI_ORIGINAL
	FROM	fii_gl_agrt_sum_mv_p_v f,
		'||l_fud2_from||'
 		( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		  FROM 	fii_time_structures cal,
			fii_pmv_aggrt_gt gt
		  WHERE report_date in (:PREVIOUS_THREE_END_DATE,:PREVIOUS_TWO_END_DATE,
 					:PREVIOUS_ONE_END_DATE,:BUD_ASOF_DATE, :PREVIOUS_BUD_ASOF_DATE)
			AND (	BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
				BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND)
		) inner_inline_view

	WHERE 	f.time_id = inner_inline_view.time_id
		AND f.period_type_id = inner_inline_view.period_type_id
		AND f.parent_company_id = inner_inline_view.parent_company_id
		AND f.company_id = inner_inline_view.company_id
		AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
		AND f.cost_center_id = inner_inline_view.cc_id
		AND f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		AND f.fin_category_id = inner_inline_view.fin_category_id
		AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
		AND f.fud1_id = inner_inline_view.fud1_id
	 	'||l_fud2_where||'

      GROUP BY  '||p_aggrt_viewby_id||',
		inner_inline_view.viewby,
		inner_inline_view.sort_order ';

-- l_sqlstmt2 is the sql to be used, when report_date <> sysdate AND fii_pmv_non_aggrt_gt has been populated

l_sqlstmt2 :=
	' /* this query returns data for non_aggregated nodes */

	SELECT   /*+ index(f fii_gl_base_map_mv_n1) */
		'||p_nonaggrt_viewby_id||'     viewby_id,
		inner_inline_view.viewby viewby,
		inner_inline_view.sort_order sort_order,
		SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL1,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   	FII_PSI_HIST_COL2,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL3,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL4,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_XTD,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
			  	THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_PRIOR,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.baseline_budget_g  ELSE NULL END) ) )   FII_PSI_ORIGINAL
	FROM	fii_gl_base_map_mv_p_v f,
		fii_company_hierarchies co_hier,
		fii_cost_ctr_hierarchies cc_hier,
		fii_fin_item_leaf_hiers fin_hier,
		fii_udd1_hierarchies fud1_hier,
 		'||l_fud2_from||'
		( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		  FROM 	fii_time_structures cal,
 			fii_pmv_non_aggrt_gt gt
		  WHERE report_date in (:PREVIOUS_THREE_END_DATE, :PREVIOUS_TWO_END_DATE,
					:PREVIOUS_ONE_END_DATE, :BUD_ASOF_DATE,	:PREVIOUS_BUD_ASOF_DATE)
			AND ( BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
			      BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND)
		) inner_inline_view

	WHERE 	f.period_type_id = inner_inline_view.period_type_id
		AND f.time_id = inner_inline_view.time_id
	        AND f.company_id = co_hier.child_company_id
		AND f.cost_center_id = cc_hier.child_cc_id
		AND f.fin_category_id = fin_hier.child_fin_cat_id
		'||l_cat_decode||'
		'||l_fud1_decode||'
		AND f.fud1_id = fud1_hier.child_value_id
		AND co_hier.parent_company_id = inner_inline_view.company_id
		AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
		AND fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
		AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
 		'||l_fud2_where||'
      GROUP BY 	'||p_nonaggrt_viewby_id||',
		inner_inline_view.viewby,
		inner_inline_view.sort_order ';


l_trend_sum_mv_sql :=
	' /* this query is formed, when we hit fii_gl_trend_sum_mv */

	SELECT	'||p_aggrt_viewby_id||'   	viewby_id,
		inner_inline_view.viewby 	viewby,
		inner_inline_view.sort_order 	sort_order,
		SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   	FII_PSI_HIST_COL1,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   	FII_PSI_HIST_COL2,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL3,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_HIST_COL4,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_XTD,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.budget_g  ELSE NULL END) ) )   FII_PSI_PRIOR,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
			(CASE	WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				THEN f.baseline_budget_g  ELSE NULL END) ) )   FII_PSI_ORIGINAL
	FROM	fii_gl_trend_sum_mv_p_v f,
 		( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		  FROM 	fii_time_structures cal,
			fii_pmv_aggrt_gt gt
		  WHERE report_date in (:PREVIOUS_THREE_END_DATE,:PREVIOUS_TWO_END_DATE,
 					:PREVIOUS_ONE_END_DATE,:BUD_ASOF_DATE, :PREVIOUS_BUD_ASOF_DATE)
			AND (	BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
				BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND)
		) inner_inline_view

	WHERE 	f.time_id = inner_inline_view.time_id
		AND f.period_type_id = inner_inline_view.period_type_id
		AND f.parent_company_id = inner_inline_view.parent_company_id
		AND f.company_id = inner_inline_view.company_id
		AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
		AND f.cost_center_id = inner_inline_view.cc_id
		AND f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		AND f.fin_category_id = inner_inline_view.fin_category_id

      GROUP BY  '||p_aggrt_viewby_id||',
		inner_inline_view.viewby,
		inner_inline_view.sort_order ';

	IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN

		l_aggrt_sql := l_trend_sum_mv_sql;

	ELSIF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated
		l_aggrt_sql := l_sqlstmt1;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_non_aggrt_sql := l_sqlstmt2;
			l_union_all := ' UNION ALL ';
		END IF;

	ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated
			l_non_aggrt_sql := l_sqlstmt2;

	ELSE	-- neither of the GT tables are populated...
		l_aggrt_sql := l_sqlstmt1;

	END IF;


/*DECODE('||l_id||', inline_view.viewby_id, DECODE('''||l_if_leaf_flag||''',''Y'',
                                                                        inline_view.viewby, inline_view.viewby||'' ''||:DIR_MSG),
                        inline_view.viewby) VIEWBY,*/
 sqlstmt :=' SELECT
	inline_view.viewby              VIEWBY,
	inline_view.viewby_id		VIEWBYID,
	SUM(FII_PSI_XTD)       		FII_PSI_XTD,
	SUM(FII_PSI_PRIOR)	 	FII_PSI_PRIOR,
	SUM(FII_PSI_ORIGINAL)         	FII_PSI_ORIGINAL,
	SUM(FII_PSI_HIST_COL1)			FII_PSI_HIST_COL1,
	SUM(FII_PSI_HIST_COL2)			FII_PSI_HIST_COL2,
	SUM(FII_PSI_HIST_COL3)			FII_PSI_HIST_COL3,
	SUM(FII_PSI_HIST_COL4)			FII_PSI_HIST_COL4,
        DECODE(SUM(FII_PSI_XTD), 0, NULL, NULL, NULL, '''|| l_xtd_drill_url||''') FII_PSI_XTD_DRILL,
	SUM(SUM(FII_PSI_XTD)) OVER ()       FII_PSI_GT_XTD,
	SUM(SUM(FII_PSI_PRIOR)) OVER () FII_PSI_GT_PRIOR,
	SUM(SUM(FII_PSI_ORIGINAL)) OVER ()       FII_PSI_GT_ORIGINAL,
	(SUM(SUM(FII_PSI_XTD)) over() - SUM(SUM(FII_PSI_PRIOR)) over()) / ABS(NULLIF(SUM(SUM(FII_PSI_PRIOR)) over(),0)) * 100  FII_PSI_GT_PCNT_CHANGE,
	SUM(SUM(FII_PSI_HIST_COL1)) OVER ()  FII_PSI_GT_HIST_COL1,
	SUM(SUM(FII_PSI_HIST_COL2)) OVER ()  FII_PSI_GT_HIST_COL2,
	SUM(SUM(FII_PSI_HIST_COL3)) OVER ()  FII_PSI_GT_HIST_COL3,
	SUM(SUM(FII_PSI_HIST_COL4)) OVER () FII_PSI_GT_HIST_COL4,
	DECODE((SELECT  is_leaf_flag
		FROM    fii_company_hierarchies
		WHERE	parent_company_id = inline_view.viewby_id
			AND child_company_id = inline_view.viewby_id),
			''Y'',
			'''',
			''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_COMPANIES+FII_COMPANIES&pParamIds=Y'') 	FII_PSI_COMP_DRILL,
	DECODE((SELECT  is_leaf_flag
		FROM    fii_cost_ctr_hierarchies
		WHERE	parent_cc_id = inline_view.viewby_id
			AND child_cc_id = inline_view.viewby_id),
			''Y'',
			'''',
			''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+HRI_CL_ORGCC&pParamIds=Y'')	FII_PSI_CC_DRILL,
	DECODE((SELECT  is_leaf_flag
		FROM    fii_fin_item_leaf_hiers
		WHERE	parent_fin_cat_id = inline_view.viewby_id
			AND child_fin_cat_id = inline_view.viewby_id),
			''Y'',
			'''',
 			DECODE(:G_ID, inline_view.viewby_id,'''',
			''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FINANCIAL ITEM+GL_FII_FIN_ITEM&pParamIds=Y''))	FII_PSI_CAT_DRILL,
	DECODE((SELECT  is_leaf_flag
		FROM    fii_udd1_hierarchies
		WHERE	parent_value_id = inline_view.viewby_id
			AND child_value_id = inline_view.viewby_id),
			''Y'',
			'''',
		 	DECODE(:G_ID, inline_view.viewby_id,'''',
			''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_1&pParamIds=Y''))	FII_PSI_PROJECT_DRILL,
	DECODE((SELECT  is_leaf_flag
		FROM    fii_udd2_hierarchies
		WHERE	parent_value_id = inline_view.viewby_id
			AND child_value_id = inline_view.viewby_id),
			''Y'',
			'''',
			''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_2&pParamIds=Y'')	FII_PSI_UD2_DRILL
FROM
	(
			'||l_aggrt_sql||'
			'||l_union_all||'
			'||l_non_aggrt_sql||'
		) inline_view
GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order
ORDER BY 	NVL(inline_view.sort_order,999999) asc,
 		NVL(FII_PSI_XTD, -999999999) desc  ';


-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>bud_sum_sql,
        p_bind_output_table=>bud_sum_output);

END get_bud_sum;


PROCEDURE get_bud_sum_port (
  p_page_parameter_tbl	IN BIS_PMV_PAGE_PARAMETER_TBL,
  bud_sum_sql 		OUT NOCOPY VARCHAR2,
  bud_sum_output 	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

        sqlstmt                 VARCHAR2(17000);
	l_sqlstmt1		VARCHAR2(10000);
	l_sqlstmt2		VARCHAR2(10000);
        l_trend_sum_mv_sql	VARCHAR2(10000) := NULL;
	l_aggrt_sql 		VARCHAR2(10000) := NULL;
	l_non_aggrt_sql 	VARCHAR2(10000) := NULL;
	l_union_all 		VARCHAR2(15) := NULL;
	l_ledger_where		VARCHAR2(1000);
	l_roll_column		VARCHAR2(10);
	l_xtd_column		VARCHAR2(10);
	l_comp_detail_url	VARCHAR2(1000);
	l_cc_detail_url		VARCHAR2(1000);
	l_cat_detail_url	VARCHAR2(1000);
	l_journal_src_url	VARCHAR2(1000);
        l_xtd_drill_url         VARCHAR2(300);
	p_aggrt_gt_is_empty	VARCHAR2(10);
	p_non_aggrt_gt_is_empty	VARCHAR2(10);
	p_aggrt_viewby_id	VARCHAR2(100);
	p_nonaggrt_viewby_id	VARCHAR2(100);
	p_snap_aggrt_viewby_id        VARCHAR2(30); /* Added for Bug 4193545*/

 	l_cat_decode                  VARCHAR2(300); -- local variable to append decode check for category, when we have only 1 top node
  	l_fud1_decode                 VARCHAR2(300); -- local variable to append decode check for fud1, when viewby chosen is FUD1

  	l_time_id                     NUMBER;         -- local var for storing time_id of g_as_of_date, based on period type
  	l_fud2_enabled_flag           VARCHAR2(1);
  	l_fud2_where                  VARCHAR2(300);
  	l_fud2_snap_where             VARCHAR2(300);
  	l_fud2_from                   VARCHAR2(100);
BEGIN

FII_EA_UTIL_PKG.reset_globals;
FII_EA_UTIL_PKG.get_parameters(p_page_parameter_tbl=>p_page_parameter_tbl);
FII_EA_UTIL_PKG.get_rolling_period;

fii_ea_util_pkg.get_viewby_id(p_aggrt_viewby_id, p_snap_aggrt_viewby_id, p_nonaggrt_viewby_id);
fii_ea_util_pkg.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);


/* Setting 'period type' dependent variables in this CASE structure which need to be used in
dynamic pmv sql to retrieve data FROM the correct columns */

CASE fii_ea_util_pkg.g_page_period_type
WHEN 'FII_TIME_ENT_YEAR' THEN
	l_roll_column := 'qtd';
	l_xtd_column  := 'ytd' ;

 	SELECT  ent_year_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;

WHEN 'FII_TIME_ENT_QTR' THEN
	l_roll_column := 'mtd';
	l_xtd_column  := 'qtd' ;

 	SELECT  ent_qtr_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;

WHEN 'FII_TIME_ENT_PERIOD' THEN
        l_roll_column := 'mtd';
        l_xtd_column  := 'mtd' ;

 	SELECT  ent_period_id into l_time_id
        FROM    fii_time_ent_period per
        WHERE   fii_ea_util_pkg.g_as_of_date between start_date AND end_date;

END CASE;

-- logic for fix to display DIRECT.. if we choose node A which has 2 children B & C, then, we want to
-- display A in the tabular data, only if there is budget/forecast loaded directly against A.
-- For this, while keeping parent_id as A, we want to look only for A in fii_gl_base_map_mv
-- so that we do not get duplication of actuals..hence we append conditional decode
-- statements l_cat_decode AND l_fud1_decode  in l_sqlstmt2 AND l_snap_sqlstmt2..

IF fii_ea_util_pkg.g_fin_category_id = 'All' THEN
        IF fii_ea_util_pkg.g_fin_cat_top_node_count = 1 THEN
                l_cat_decode := 'AND fin_hier.parent_fin_cat_id = decode(fin_hier.parent_fin_cat_id,:CATEGORY_ID,
                                                                         fin_hier.child_fin_cat_id,fin_hier.parent_fin_cat_id)';
        END IF;
ELSE
                l_cat_decode := 'AND fin_hier.parent_fin_cat_id = DECODE(fin_hier.parent_fin_cat_id, :CATEGORY_ID,
                                                                         fin_hier.child_fin_cat_id, fin_hier.parent_fin_cat_id)';
END IF;

IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);

  ELSIF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

       	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
 	l_fud1_decode := 'AND fud1_hier.parent_value_id = DECODE(fud1_hier.parent_value_id, :UDD1_ID,
                                                          fud1_hier.child_value_id, fud1_hier.parent_value_id)';
  END IF;

/* Bug 4192452 - Start */

BEGIN
	SELECT  dbi_enabled_flag INTO l_fud2_enabled_flag
	FROM    fii_financial_dimensions
	WHERE   dimension_short_name = 'FII_USER_DEFINED_2';
END;

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  AND fud2_hier.parent_value_id = gt.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       AND fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  AND fud2_hier.parent_value_id = gt.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       AND fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                AND fud2_hier.child_value_id = f.fud2_id ';
  END IF;

END IF;

/* Bug 4192452 - End */

-- Constructing drilldown URL
l_xtd_drill_url := 'pFunctionName=FII_PSI_BUD_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

l_sqlstmt1 :=
' /* this query returns data for aggregated nodes */

	SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
		'||p_aggrt_viewby_id||'   	viewby_id,
		inner_inline_view.viewby 	viewby,
		inner_inline_view.sort_order 	sort_order,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.budget_g))   FII_PSI_XTD,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE, f.budget_g))   FII_PSI_PRIOR,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.baseline_budget_g))   FII_PSI_ORIGINAL

	FROM	fii_gl_agrt_sum_mv_p_v f,
  		'||l_fud2_from||'
		( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		  FROM 	fii_time_structures cal, fii_pmv_aggrt_gt gt
		  WHERE report_date in (:BUD_ASOF_DATE, :PREVIOUS_BUD_ASOF_DATE)
			AND ( BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND)
		) inner_inline_view

	WHERE 	f.time_id = inner_inline_view.time_id
		AND f.period_type_id = inner_inline_view.period_type_id
		AND f.parent_company_id = inner_inline_view.parent_company_id
		AND f.company_id = inner_inline_view.company_id
		AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
		AND f.cost_center_id = inner_inline_view.cc_id
		AND f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		AND f.fin_category_id = inner_inline_view.fin_category_id
		AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
		AND f.fud1_id = inner_inline_view.fud1_id
  		'||l_fud2_where||'

     GROUP BY	'||p_aggrt_viewby_id||',
		inner_inline_view.viewby,
		inner_inline_view.sort_order ';

-- l_sqlstmt2 is the sql to be used, when report_date <> sysdate AND fii_pmv_non_aggrt_gt has been populated

l_sqlstmt2 :=
' /* this query returns data for non_aggregated nodes */

	SELECT   /*+ index(f fii_gl_base_map_mv_n1) */
		'||p_nonaggrt_viewby_id||'     viewby_id,
		inner_inline_view.viewby viewby,
		inner_inline_view.sort_order sort_order,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.budget_g))   FII_PSI_XTD,
		SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE, f.budget_g))   FII_PSI_PRIOR,
		SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.baseline_budget_g))   FII_PSI_ORIGINAL

	FROM	fii_gl_base_map_mv_p_v f,
		fii_company_hierarchies co_hier,
		fii_cost_ctr_hierarchies cc_hier,
		fii_fin_item_leaf_hiers fin_hier,
		fii_udd1_hierarchies fud1_hier,
 		'||l_fud2_from||'
		( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		  FROM	fii_time_structures cal,
 			fii_pmv_non_aggrt_gt gt
		 WHERE 	report_date in (:BUD_ASOF_DATE, :PREVIOUS_BUD_ASOF_DATE)
			AND ( BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND)
		) inner_inline_view

	WHERE 	f.period_type_id = inner_inline_view.period_type_id
		AND f.time_id = inner_inline_view.time_id
	        AND f.company_id = co_hier.child_company_id
		AND f.cost_center_id = cc_hier.child_cc_id
		AND f.fin_category_id = fin_hier.child_fin_cat_id
		'||l_cat_decode||'
		'||l_fud1_decode||'
		AND f.fud1_id = fud1_hier.child_value_id
		AND co_hier.parent_company_id = inner_inline_view.company_id
		AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
		AND fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
		AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
 		'||l_fud2_where||'

     GROUP BY 	'||p_nonaggrt_viewby_id||',
		inner_inline_view.viewby,
		inner_inline_view.sort_order ';

l_trend_sum_mv_sql :='
			SELECT	'||p_aggrt_viewby_id||'     viewby_id,
		       		inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.budget_g))   FII_PSI_XTD,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_BUD_ASOF_DATE, f.budget_g))   FII_PSI_PRIOR,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE, f.baseline_budget_g))   FII_PSI_ORIGINAL

			FROM	fii_gl_trend_sum_mv_p_v f,
				( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				  FROM 	  fii_time_structures cal,
 					  fii_pmv_aggrt_gt gt
				   WHERE  report_date in (:BUD_ASOF_DATE, :PREVIOUS_BUD_ASOF_DATE)
					  AND ( BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND )
				) inner_inline_view

			WHERE 	f.time_id = inner_inline_view.time_id
				AND f.period_type_id = inner_inline_view.period_type_id
		                AND f.parent_company_id = inner_inline_view.parent_company_id
                                AND f.company_id = inner_inline_view.company_id
                                AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
                                AND f.cost_center_id = inner_inline_view.cc_id
                                AND f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		                AND f.fin_category_id = inner_inline_view.fin_category_id

			GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN

	l_aggrt_sql := l_trend_sum_mv_sql;

ELSIF p_aggrt_gt_is_empty = 'N' then -- aggrt GT table is populated
		l_aggrt_sql := l_sqlstmt1;

		IF p_non_aggrt_gt_is_empty = 'N' then -- both GT tables are populated
			l_non_aggrt_sql := l_sqlstmt2;
			l_union_all := ' UNION ALL ';
		END IF;

ELSIF  p_non_aggrt_gt_is_empty = 'N' then -- only non aggrt GT table is populated
			l_non_aggrt_sql := l_sqlstmt2;

ELSE	-- neither of the GT tables are populated...
		l_aggrt_sql := l_sqlstmt1;

END IF;


 sqlstmt :='
	SELECT  inline_view.viewby              VIEWBY,
		inline_view.viewby_id			VIEWBYID,
		SUM(FII_PSI_XTD)       		FII_PSI_XTD,
		SUM(FII_PSI_PRIOR)	 	FII_PSI_PRIOR,
		SUM(FII_PSI_ORIGINAL)           FII_PSI_ORIGINAL,
		DECODE(SUM(FII_PSI_XTD), 0, NULL, NULL, NULL, '''|| l_xtd_drill_url||''') FII_PSI_XTD_DRILL,
		SUM(SUM(FII_PSI_XTD)) OVER ()       	FII_PSI_GT_XTD,
		SUM(SUM(FII_PSI_PRIOR)) OVER () 	FII_PSI_GT_PRIOR,
		SUM(SUM(FII_PSI_ORIGINAL)) OVER ()      FII_PSI_GT_ORIGINAL,
		(SUM(SUM(FII_PSI_XTD)) over() - SUM(SUM(FII_PSI_PRIOR)) OVER()) / ABS(NULLIF(SUM(SUM(FII_PSI_PRIOR)) over(),0)) * 100  FII_PSI_GT_PCNT_CHANGE,
		DECODE((SELECT  is_leaf_flag
			FROM    fii_company_hierarchies
			WHERE   parent_company_id = inline_view.viewby_id
				AND child_company_id = inline_view.viewby_id),
				''Y'',
				'''',
				''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_COMPANIES+FII_COMPANIES&pParamIds=Y'') FII_PSI_COMP_DRILL,
		DECODE((SELECT  is_leaf_flag
			FROM    fii_fin_item_leaf_hiers
			WHERE	parent_fin_cat_id = inline_view.viewby_id
				AND child_fin_cat_id = inline_view.viewby_id),
				''Y'',
				'''',
 				DECODE(:G_ID, inline_view.viewby_id,'''',
				''pFunctionName=FII_PSI_BUDGET_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FINANCIAL ITEM+GL_FII_FIN_ITEM&pParamIds=Y''))	FII_PSI_CAT_DRILL
	FROM
		(
			'||l_aggrt_sql||'
			'||l_union_all||'
			'||l_non_aggrt_sql||'
		) inline_view

	GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order
	ORDER BY 	NVL(inline_view.sort_order,-999999) asc,
 			NVL(FII_PSI_XTD, -999999999) desc  ';

-- Attach bind parameters

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt=>sqlstmt,
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_sql_output=>bud_sum_sql,
        p_bind_output_table=>bud_sum_output);

END get_bud_sum_port;

END FII_PSI_BUD_SUM_PKG;


/
