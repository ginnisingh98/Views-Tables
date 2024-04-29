--------------------------------------------------------
--  DDL for Package Body FII_PSI_FUNDS_AVAIL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PSI_FUNDS_AVAIL_SUM_PKG" AS
/* $Header: FIIPSIFAB.pls 120.13 2007/10/08 08:37:35 arcdixit ship $ */

PROCEDURE GET_FUNDS_AVAIL_SUM
      (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       funds_avail_sql out NOCOPY VARCHAR2,
       funds_avail_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

       -- declaration section
       sqlstmt                   VARCHAR2(32000); --Bug 6157086
       sqlstmt_temp              VARCHAR2(25000);
       l_outer_sql_b             VARCHAR2(6000);
       l_outer_sql_e             VARCHAR2(200);
       l_inner_sql_sys           VARCHAR2(5000);
       l_inner_sql_sys_agg       VARCHAR2(5000);
       l_inner_sql_sys_nonagg    VARCHAR2(5000);
       l_union_sql               VARCHAR2(20);
       l_inner_sql_nonsys        VARCHAR2(6000);
       l_inner_sql_nonsys_agg    VARCHAR2(8000);
       l_inner_sql_nonsys_nonagg VARCHAR2(8000);
       l_insert_sql_b            VARCHAR2(2000);
       l_schema_name             VARCHAR2(10);
       l_sort_order              VARCHAR2(50);

       l_aggrt_gt_is_empty       VARCHAR2(1);
       l_non_aggrt_gt_is_empty   VARCHAR2(1);
       l_aggrt_viewby_id         VARCHAR2(50);
       l_non_aggrt_viewby_id     VARCHAR2(50);
       l_snap_aggrt_viewby_id    VARCHAR2(30);
       l_as_of_date              DATE;
       l_page_period_type        VARCHAR2(100);
       l_time_comp               VARCHAR2(20);


       l_xtd                     VARCHAR2(3);
       l_compare_to              VARCHAR2(30);

       l_amount_type             VARCHAR2(3);

       l_cat_decode              VARCHAR2(500) := ' ';
       l_fud1_decode             VARCHAR2(500) := ' ';

       l_view_by                 VARCHAR2(100);
       l_fud1_id                 VARCHAR2(30);
       l_fud2_id                 VARCHAR2(30);
       l_if_leaf_flag            VARCHAR2(1);
       l_snapshot                VARCHAR2(1);

       l_ud1_enabled_flag        VARCHAR2(1);
       l_fud1_from               VARCHAR2(1200);
       l_fud1_where              VARCHAR2(1200);

       l_enabled_flag            VARCHAR2(1);
       l_fud2_from               VARCHAR2(1200);
       l_fud2_where              VARCHAR2(1200);
       l_prim_or_sec             VARCHAR2(10);
       l_trend_sum_mv_commitment  VARCHAR2(30);
       l_trend_sum_mv_obligated  VARCHAR2(30);
       l_trend_sum_mv_other	 VARCHAR2(30);

BEGIN
fii_ea_util_pkg.reset_globals;
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

fii_ea_util_pkg.get_viewby_id(l_aggrt_viewby_id, l_snap_aggrt_viewby_id, l_non_aggrt_viewby_id);
fii_ea_util_pkg.populate_security_gt_tables(l_aggrt_gt_is_empty, l_non_aggrt_gt_is_empty);

l_as_of_date := fii_ea_util_pkg.g_as_of_date;
l_page_period_type := fii_ea_util_pkg.g_page_period_type;
l_amount_type := fii_ea_util_pkg.g_amount_type;
l_time_comp := fii_ea_util_pkg.g_time_comp;
l_view_by := fii_ea_util_pkg.g_view_by;
l_fud1_id := fii_ea_util_pkg.g_fud1_id;
l_fud2_id := fii_ea_util_pkg.g_fud2_id;
l_snapshot := fii_ea_util_pkg.g_snapshot;

/*l_xtd and l_compare_to are apart of the column names of the mvs in the pmv sql*/
IF l_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
   l_xtd := 'MTD';
ELSIF l_page_period_type = 'FII_TIME_ENT_QTR' THEN
   l_xtd := 'QTD';
ELSIF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_xtd := 'YTD';
END IF;

IF l_amount_type = 'PTD' THEN l_amount_type := 'MTD'; END IF;

IF l_amount_type = 'YTD' OR l_time_comp = 'SEQUENTIAL' THEN
   l_compare_to := 'PRIOR_' || l_amount_type;
ELSE
   l_compare_to := 'LAST_YEAR_' || l_amount_type;
END IF;

/*If the query needs to hit the full mvs for aggregated and nonaggregated nodes,
  then the query becomes too lengthy and the gt table fii_psi_pmv_gt is used.
  To report the results correctly, need to know sort order.*/
IF l_snapshot = 'Y' OR
   l_aggrt_gt_is_empty = 'Y' OR l_non_aggrt_gt_is_empty = 'Y' THEN
l_sort_order := '';
ELSE
l_sort_order := ' f.sort_order SORT_ORDER, ';
END IF;

/* Per Bug 4099419, if A has children B and C and budgets are uploaded against A, the
   report should display A(Direct), B and C when A is chosen or when All is chosen and
   A is the only node granted access to a user.  To display the direct record, use the self
   record for A to find budgets against A in the base mv. This is only for financial
   category and user defined dimension 1.  */
IF l_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
   fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);
   l_cat_decode :=
     ' and fin_hier.parent_fin_cat_id = DECODE(fin_hier.parent_fin_cat_id, :CATEGORY_ID,
                                              fin_hier.child_fin_cat_id, fin_hier.parent_fin_cat_id)';
   l_if_leaf_flag := fii_ea_util_pkg.g_fin_cat_is_leaf;
ELSIF l_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
   fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
   l_fud1_decode :=
     ' and fud1_hier.parent_value_id = DECODE(fud1_hier.parent_value_id, :UDD1_ID,
                                             fud1_hier.child_value_id, fud1_hier.parent_value_id)';
   l_if_leaf_flag := fii_ea_util_pkg.g_ud1_is_leaf;
ELSE
   l_if_leaf_flag := 'Y';
END IF;

/* Bug 5883351: Find out if user defined dimension 1 is enabled or not */
SELECT dbi_enabled_flag INTO l_ud1_enabled_flag
FROM fii_financial_dimensions
WHERE dimension_short_name = 'FII_USER_DEFINED_1';

/*Remove join to fii_udd2_hierarchies if fud2 is disabled, or fud2 is all
  and the viewby dimension is not fud2. */

SELECT dbi_enabled_flag INTO l_enabled_flag
FROM fii_financial_dimensions
WHERE dimension_short_name = 'FII_USER_DEFINED_2';

IF l_enabled_flag = 'N' OR (l_fud2_id = 'All'
   AND l_view_by <> 'FII_USER_DEFINED+FII_USER_DEFINED_2')
THEN
 l_fud2_from := ' ';
 l_fud2_where := ' ';
ELSE
 l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';
 IF l_snapshot = 'Y' then
   l_fud2_where := ' AND fud2_hier.parent_value_id = gt.fud2_id
                     AND fud2_hier.child_value_id = f.fud2_id ';
 ELSE
   l_fud2_where := ' AND fud2_hier.parent_value_id = inner_inline_view.fud2_id
                     AND fud2_hier.child_value_id = f.fud2_id ';
 END IF;

END IF;


/*Appended to query if query is too long (needs to hit the full mvs for aggregated
  and nonaggregated nodes.*/
l_insert_sql_b :=
	'INSERT INTO FII_PSI_PMV_GT(
			VIEWBY,
			VIEWBYID,
			SORT_ORDER,
			FII_PSI_AVAIL_C,
			FII_PSI_PRIOR_AVAIL_C,
			FII_PSI_GT_AVAIL_C,
			FII_PSI_GT_PRIOR_AVAIL_C,
			FII_PSI_PCNT_AVAIL_C,
			FII_PSI_PRIOR_PCNT_AVAIL_C,
			FII_PSI_GT_PCNT_AVAIL_C,
			FII_PSI_GT_PRIOR_PCNT_AVAIL_C,
			FII_PSI_BUDGET_C,
			FII_PSI_PRIOR_BUDGET_C,
			FII_PSI_GT_BUDGET_C,
			FII_PSI_GT_PRIOR_BUDGET_C,
			FII_PSI_ENCUMBRANCES_C,
			FII_PSI_PRIOR_ENCUMBRANCES_C,
			FII_PSI_GT_ENCUMBRANCES_C,
			FII_PSI_GT_PRIOR_ENCUM_C,
			FII_PSI_COMMITTED_C_KPI,
			FII_PSI_PRIOR_COMMITTED_C,
			FII_PSI_GT_COMMITTED_C_KPI,
			FII_PSI_GT_PRIOR_COMMITTED_C,
			FII_PSI_OBLIGATED_C_KPI,
			FII_PSI_PRIOR_OBLIGATED_C,
			FII_PSI_GT_OBLIGATED_C_KPI,
			FII_PSI_GT_PRIOR_OBLIGATED_C,
			FII_PSI_OTHERS_C_KPI,
			FII_PSI_PRIOR_OTHERS_C,
			FII_PSI_GT_OTHERS_C_KPI,
			FII_PSI_GT_PRIOR_OTHERS_C,
			FII_PSI_ACTUALS_C,
			FII_PSI_PRIOR_ACTUALS_C,
			FII_PSI_GT_ACTUALS_C,
			FII_PSI_GT_PRIOR_ACTUALS_C,
			FII_PSI_BUDGET_A,
			FII_PSI_ENCUMBRANCES_A,
			FII_PSI_ACTUALS_A,
			FII_PSI_GT_BUDGET_A,
			FII_PSI_GT_ENCUMBRANCES_A,
			FII_PSI_GT_ACTUALS_A,
			FII_PSI_COMP_DRILL,
			FII_PSI_CC_DRILL,
			FII_PSI_CAT_DRILL,
			FII_PSI_PROJECT_DRILL,
			FII_PSI_UD2_DRILL)';

/*Outer query used in all cases*/
l_outer_sql_b :=
'SELECT  DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
                                                   f.VIEWBY, f.VIEWBY||'' ''||:DIR_MSG),
                                            f.VIEWBY) VIEWBY,
        f.VIEWBYID VIEWBYID, ' || l_sort_order || '
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
               FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C, NULL),
               FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C) FII_PSI_AVAIL_C,
        FII_PSI_PRIOR_BUDGET_C - FII_PSI_PRIOR_ENCUMBRANCES_C - FII_PSI_PRIOR_ACTUALS_C FII_PSI_PRIOR_AVAIL_C,
        SUM(FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C) OVER () FII_PSI_GT_AVAIL_C,
        SUM(FII_PSI_PRIOR_BUDGET_C - FII_PSI_PRIOR_ENCUMBRANCES_C - FII_PSI_PRIOR_ACTUALS_C) OVER () FII_PSI_GT_PRIOR_AVAIL_C,
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
             ((FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C) / NULLIF(FII_PSI_BUDGET_C,0)) * 100, NULL),
             ((FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C) / NULLIF(FII_PSI_BUDGET_C,0)) * 100) FII_PSI_PCNT_AVAIL_C,
        ((FII_PSI_PRIOR_BUDGET_C - FII_PSI_PRIOR_ENCUMBRANCES_C - FII_PSI_PRIOR_ACTUALS_C)
          / NULLIF(FII_PSI_PRIOR_BUDGET_C,0)) * 100 FII_PSI_PRIOR_PCNT_AVAIL_C,
        ((SUM(FII_PSI_BUDGET_C - FII_PSI_ENCUMBRANCES_C - FII_PSI_ACTUALS_C) OVER ()) /
           (NULLIF(SUM(FII_PSI_BUDGET_C) OVER (),0))) * 100 FII_PSI_GT_PCNT_AVAIL_C,
        ((SUM(FII_PSI_PRIOR_BUDGET_C - FII_PSI_PRIOR_ENCUMBRANCES_C - FII_PSI_PRIOR_ACTUALS_C) OVER ()) /
           (NULLIF(SUM(FII_PSI_PRIOR_BUDGET_C) OVER (),0))) * 100 FII_PSI_GT_PRIOR_PCNT_AVAIL_C,
        FII_PSI_BUDGET_C,
        FII_PSI_PRIOR_BUDGET_C,
        SUM(FII_PSI_BUDGET_C) OVER () FII_PSI_GT_BUDGET_C,
        SUM(FII_PSI_PRIOR_BUDGET_C) OVER () FII_PSI_GT_PRIOR_BUDGET_C,
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
               FII_PSI_ENCUMBRANCES_C, NULL),
               FII_PSI_ENCUMBRANCES_C) FII_PSI_ENCUMBRANCES_C,
        FII_PSI_PRIOR_ENCUMBRANCES_C,
        SUM(FII_PSI_ENCUMBRANCES_C) OVER () FII_PSI_GT_ENCUMBRANCES_C,
        SUM(FII_PSI_PRIOR_ENCUMBRANCES_C) OVER () FII_PSI_GT_PRIOR_ENCUM_C,
        FII_PSI_COMMITTED_C_KPI,
        FII_PSI_PRIOR_COMMITTED_C,
        SUM(FII_PSI_COMMITTED_C_KPI) OVER () FII_PSI_GT_COMMITTED_C_KPI,
        SUM(FII_PSI_PRIOR_COMMITTED_C) OVER () FII_PSI_GT_PRIOR_COMMITTED_C,
        FII_PSI_OBLIGATED_C_KPI,
        FII_PSI_PRIOR_OBLIGATED_C,
        SUM(FII_PSI_OBLIGATED_C_KPI) OVER () FII_PSI_GT_OBLIGATED_C_KPI,
        SUM(FII_PSI_PRIOR_OBLIGATED_C) OVER () FII_PSI_GT_PRIOR_OBLIGATED_C,
        FII_PSI_OTHERS_C_KPI,
        FII_PSI_PRIOR_OTHERS_C,
        SUM(FII_PSI_OTHERS_C_KPI) OVER ()       FII_PSI_GT_OTHERS_C_KPI,
        SUM(FII_PSI_PRIOR_OTHERS_C) OVER ()       FII_PSI_GT_PRIOR_OTHERS_C,
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
               FII_PSI_ACTUALS_C, NULL),
               FII_PSI_ACTUALS_C) FII_PSI_ACTUALS_C,
        FII_PSI_PRIOR_ACTUALS_C,
        SUM(FII_PSI_ACTUALS_C) OVER ()      FII_PSI_GT_ACTUALS_C,
        SUM(FII_PSI_PRIOR_ACTUALS_C) OVER ()      FII_PSI_GT_PRIOR_ACTUALS_C,
        FII_PSI_BUDGET_A,
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
               FII_PSI_ENCUMBRANCES_A, NULL),
               FII_PSI_ENCUMBRANCES_A) FII_PSI_ENCUMBRANCES_A,
        DECODE(:G_ID, f.VIEWBYID, DECODE(''' || l_if_leaf_flag || ''', ''Y'',
               FII_PSI_ACTUALS_A, NULL),
               FII_PSI_ACTUALS_A) FII_PSI_ACTUALS_A,
        SUM(FII_PSI_BUDGET_A) OVER ()                      FII_PSI_GT_BUDGET_A,
        SUM(FII_PSI_ENCUMBRANCES_A) OVER ()                FII_PSI_GT_ENCUMBRANCES_A,
        SUM(FII_PSI_ACTUALS_A) OVER ()                     FII_PSI_GT_ACTUALS_A,
        DECODE((SELECT is_leaf_flag FROM fii_company_hierarchies
                WHERE parent_company_id = f.VIEWBYID and child_company_id = f.VIEWBYID), ''Y'', '''',
                ''pFunctionName=FII_PSI_FUNDS_AVAIL_SUM_C&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_COMPANIES+FII_COMPANIES&pParamIds=Y'') FII_PSI_COMP_DRILL,
        DECODE((SELECT is_leaf_flag FROM fii_cost_ctr_hierarchies
                WHERE parent_cc_id = f.VIEWBYID and child_cc_id = f.VIEWBYID), ''Y'', '''',
                ''pFunctionName=FII_PSI_FUNDS_AVAIL_SUM_C&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+HRI_CL_ORGCC&pParamIds=Y'') FII_PSI_CC_DRILL,
        DECODE((SELECT is_leaf_flag FROM fii_fin_item_leaf_hiers
                WHERE parent_fin_cat_id = f.VIEWBYID and child_fin_cat_id = f.VIEWBYID), ''Y'',  '''',
                DECODE(:G_ID, f.VIEWBYID, '''',
                ''pFunctionName=FII_PSI_FUNDS_AVAIL_SUM_C&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FINANCIAL ITEM+GL_FII_FIN_ITEM&pParamIds=Y'')) FII_PSI_CAT_DRILL,
        DECODE((SELECT  is_leaf_flag FROM fii_udd1_hierarchies
                WHERE parent_value_id = f.VIEWBYID and child_value_id = f.VIEWBYID), ''Y'', '''',
                DECODE(:G_ID, f.VIEWBYID, '''',
                ''pFunctionName=FII_PSI_FUNDS_AVAIL_SUM_C&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_1&pParamIds=Y'')) FII_PSI_PROJECT_DRILL,
        DECODE((SELECT  is_leaf_flag FROM fii_udd2_hierarchies
                WHERE parent_value_id = f.VIEWBYID and child_value_id = f.VIEWBYID), ''Y'', '''',
                ''pFunctionName=FII_PSI_FUNDS_AVAIL_SUM_C&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_2&pParamIds=Y'') FII_PSI_UD2_DRILL
FROM (';

l_outer_sql_e :=
') f
ORDER BY NVL(f.sort_order, 999999) asc,
         NVL(FII_PSI_BUDGET_C, -999999) desc,
         NVL(f.VIEWBY, 999999) asc';

/*Only append union if the query needs to hit aggregated and nonaggregated nodes.*/
IF l_aggrt_gt_is_empty ='Y' or l_non_aggrt_gt_is_empty ='Y' THEN
	l_union_sql := ' ';
ELSE
	l_union_sql := ' UNION ALL ';
END IF;


/*Need to hit the snapshot mvs.*/
IF l_snapshot = 'Y' THEN
l_inner_sql_sys :=
'            gt.viewby VIEWBY,
             gt.sort_order SORT_ORDER,
             NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN BUDGET_CUR_' || l_amount_type || ' ELSE 0 END), 0)            FII_PSI_BUDGET_C,
             NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN BUDGET_' || l_compare_to || ' ELSE 0 END), 0)      FII_PSI_PRIOR_BUDGET_C,
             NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN COMMITMENTS_CUR_' || l_amount_type || ' ELSE 0 END), 0)
               + NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN OBLIGATIONS_CUR_' || l_amount_type || ' ELSE 0 END), 0)
               + NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN OTHERS_CUR_' || l_amount_type || ' ELSE 0 END), 0)        FII_PSI_ENCUMBRANCES_C,
             NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN COMMITMENTS_' || l_compare_to || ' ELSE 0 END), 0)
               + NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN OBLIGATIONS_' || l_compare_to || ' ELSE 0 END), 0)
               + NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN OTHERS_' || l_compare_to || ' ELSE 0 END), 0)  FII_PSI_PRIOR_ENCUMBRANCES_C,
             NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN COMMITMENTS_CUR_' || l_amount_type || ' ELSE 0 END), 0)       FII_PSI_COMMITTED_C_KPI,
             NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN COMMITMENTS_' || l_compare_to || ' ELSE 0 END), 0) FII_PSI_PRIOR_COMMITTED_C,
             NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN OBLIGATIONS_CUR_' || l_amount_type || ' ELSE 0 END), 0)       FII_PSI_OBLIGATED_C_KPI,
             NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN OBLIGATIONS_' || l_compare_to || ' ELSE 0 END), 0) FII_PSI_PRIOR_OBLIGATED_C,
             NVL(SUM(CASE WHEN f.posted_date < :ASOF_DATE THEN OTHERS_CUR_' || l_amount_type || ' ELSE 0 END), 0)            FII_PSI_OTHERS_C_KPI,
             NVL(SUM(CASE WHEN f.posted_date < :PREVIOUS_ASOF_DATE THEN OTHERS_' || l_compare_to || ' ELSE 0 END), 0)      FII_PSI_PRIOR_OTHERS_C,
             NVL(SUM(ACTUAL_CUR_' || l_amount_type || '), 0)            FII_PSI_ACTUALS_C,
             NVL(SUM(ACTUAL_' || l_compare_to || '), 0)      FII_PSI_PRIOR_ACTUALS_C,
             NVL(SUM(BUDGET_CUR_' || l_xtd || '), 0)            FII_PSI_BUDGET_A,
             NVL(SUM(COMMITMENTS_CUR_' || l_xtd || '), 0)
                + NVL(SUM(OBLIGATIONS_CUR_' || l_xtd || '), 0)
                + NVL(SUM(OTHERS_CUR_' || l_xtd || '), 0)       FII_PSI_ENCUMBRANCES_A,
             NVL(SUM(ACTUAL_CUR_' || l_xtd || '), 0)            FII_PSI_ACTUALS_A';

/*Query fii_gl_snap_sum_f_p_v if aggregated nodes need to be displayed or no nodes.*/
IF (l_aggrt_gt_is_empty = 'N') OR
   (l_aggrt_gt_is_empty = 'Y' AND l_non_aggrt_gt_is_empty = 'Y') THEN

-- Bug 5883351: Find out fud1 where clause if ud1 is enabled/ALL or view by = ud1
IF l_ud1_enabled_flag = 'N' THEN
  l_fud1_where := '';
ELSIF (l_fud1_id = 'All'
   AND l_view_by <> 'FII_USER_DEFINED+FII_USER_DEFINED_1') THEN
  l_fud1_where := 'AND f.parent_fud1_id = -999 ';
ELSE
  l_fud1_where := 'AND   f.parent_fud1_id = gt.parent_fud1_id
	           AND   f.fud1_id = gt.fud1_id ';
END IF;

l_inner_sql_sys_agg :=
'      SELECT /*+ index(f fii_gl_snap_sum_f_n1) */
		' || l_snap_aggrt_viewby_id || ' VIEWBYID,
		' || l_inner_sql_sys || '
       FROM	fii_gl_snap_sum_f_p_v f,
		' || l_fud2_from || '
		fii_pmv_aggrt_gt gt
      WHERE	f.parent_company_id = gt.parent_company_id
		AND   f.company_id = gt.company_id
		AND   f.parent_cost_center_id = gt.parent_cc_id
		AND   f.cost_center_id = gt.cc_id
		AND   f.parent_fin_category_id = gt.parent_fin_category_id
		AND   f.fin_category_id = gt.fin_category_id
		' || l_fud1_where || '
		' || l_fud2_where || '
      GROUP BY ' || l_snap_aggrt_viewby_id || ', gt.viewby, gt.sort_order';
ELSE
	l_inner_sql_sys_agg := ' ';
END IF;

/*Only query fii_gl_snap_f_p_v if non-aggregated nodes need to be displayed.*/
IF l_non_aggrt_gt_is_empty = 'N' THEN

-- Bug 5883351: Find out fud1 from and where clause if ud1 is enabled/ALL or view by = ud1
IF l_ud1_enabled_flag = 'N' OR (l_fud1_id = 'All'
   AND l_view_by <> 'FII_USER_DEFINED+FII_USER_DEFINED_1') THEN
  l_fud1_from  := '';
  l_fud1_where := '';
ELSE
  l_fud1_from  := ' fii_udd1_hierarchies fud1_hier, ';
  l_fud1_where := 'AND   f.fud1_id = fud1_hier.child_value_id ' || l_fud1_decode || '
		   AND   fud1_hier.parent_value_id = gt.fud1_id ';
END IF;

l_inner_sql_sys_nonagg :=
'      SELECT /*+ index(f fii_gl_snap_f_n1) */
		' || l_non_aggrt_viewby_id || ' VIEWBYID,
		' || l_inner_sql_sys || '
       FROM	fii_gl_snap_f_p_v f,
		fii_company_hierarchies co_hier,
		fii_cost_ctr_hierarchies cc_hier,
		fii_fin_item_leaf_hiers fin_hier,
		' || l_fud1_from || '
		' || l_fud2_from || '
		fii_pmv_non_aggrt_gt gt
      WHERE	f.company_id = co_hier.child_company_id
		AND   co_hier.parent_company_id = gt.company_id
		AND   f.cost_center_id = cc_hier.child_cc_id
		AND   cc_hier.parent_cc_id = gt.cost_center_id
		AND   f.fin_category_id = fin_hier.child_fin_cat_id ' || l_cat_decode || '
		AND   fin_hier.parent_fin_cat_id = gt.fin_category_id
		' || l_fud1_where || '
		' || l_fud2_where || '
      GROUP BY ' || l_non_aggrt_viewby_id || ', gt.viewby, gt.sort_order';
ELSE
	l_inner_sql_sys_nonagg := ' ';
END IF;

sqlstmt := l_outer_sql_b || l_inner_sql_sys_agg
                         || l_union_sql
                         || l_inner_sql_sys_nonagg
           || l_outer_sql_e;

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt => sqlstmt,
        p_page_parameter_tbl => p_page_parameter_tbl,
        p_sql_output => funds_avail_sql,
        p_bind_output_table => funds_avail_output);

ELSE /*system date is not chosen. need to hit full mvs.*/

/* currency views on top of fii_gl_trend_sum_mv don't have posted_date column,
so, we're hitting fii_gl_trend_sum_mv directly by using the below mentioned work-around */

IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN

	l_prim_or_sec := 'PRIM_';
	l_trend_sum_mv_commitment := 'COMMITTED_AMOUNT_PRIM';
	l_trend_sum_mv_obligated := 'OBLIGATED_AMOUNT_PRIM';
	l_trend_sum_mv_other := 'OTHER_AMOUNT_PRIM';
	l_aggrt_viewby_id := REPLACE(l_aggrt_viewby_id, 'company_id', 'company_dim_id');
	l_aggrt_viewby_id := REPLACE(l_aggrt_viewby_id, 'cost_center_id', 'cost_center_dim_id');
	l_aggrt_viewby_id := REPLACE(l_aggrt_viewby_id, 'fin_category_id', 'fin_category_dim_id');
ELSE
	l_trend_sum_mv_commitment := 'COMMITMENTS_G';
	l_trend_sum_mv_obligated := 'OBLIGATIONS_G';
	l_trend_sum_mv_other := 'OTHERS_G';
END IF;

l_inner_sql_nonsys :=
'             inner_inline_view.viewby VIEWBY,
             inner_inline_view.sort_order SORT_ORDER,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :ASOF_DATE
	             THEN '||l_prim_or_sec||'BUDGET_G ELSE 0 END), 0) FII_PSI_BUDGET_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_BOUNDARY_END
	                  AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :PREVIOUS_ASOF_DATE
                 THEN '||l_prim_or_sec||'BUDGET_G ELSE 0 END), 0) FII_PSI_PRIOR_BUDGET_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :BOUNDARY_END
	                  AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :ASOF_DATE
                 THEN  '||l_trend_sum_mv_commitment||' + '||l_trend_sum_mv_obligated||' + '||l_trend_sum_mv_other||' ELSE 0 END), 0) FII_PSI_ENCUMBRANCES_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :PREVIOUS_ASOF_DATE
	             THEN '||l_trend_sum_mv_commitment||' + '||l_trend_sum_mv_obligated||' + '||l_trend_sum_mv_other||' ELSE 0 END), 0) FII_PSI_PRIOR_ENCUMBRANCES_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :BOUNDARY_END
	                  AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :ASOF_DATE
                 THEN '||l_trend_sum_mv_commitment||' ELSE 0 END), 0) FII_PSI_COMMITTED_C_KPI,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :PREVIOUS_ASOF_DATE
	             THEN '||l_trend_sum_mv_commitment||' ELSE 0 END), 0) FII_PSI_PRIOR_COMMITTED_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :ASOF_DATE
	             THEN '||l_trend_sum_mv_obligated||' ELSE 0 END), 0) FII_PSI_OBLIGATED_C_KPI,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :PREVIOUS_ASOF_DATE
	             THEN '||l_trend_sum_mv_obligated||' ELSE 0 END), 0) FII_PSI_PRIOR_OBLIGATED_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :ASOF_DATE
	             THEN '||l_trend_sum_mv_other||' ELSE 0 END), 0) FII_PSI_OTHERS_C_KPI,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_BOUNDARY_END
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
                      AND f.posted_date <= :PREVIOUS_ASOF_DATE
	             THEN '||l_trend_sum_mv_other||' ELSE 0 END), 0) FII_PSI_PRIOR_OTHERS_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
	             THEN '||l_prim_or_sec||'ACTUAL_G ELSE 0 END), 0) FII_PSI_ACTUALS_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
                      AND BITAND(inner_inline_view.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
	             THEN '||l_prim_or_sec||'ACTUAL_G ELSE 0 END), 0) FII_PSI_PRIOR_ACTUALS_C,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
                      AND BITAND(inner_inline_view.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
	             THEN '||l_prim_or_sec||'BUDGET_G ELSE 0 END), 0) FII_PSI_BUDGET_A,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
                      AND BITAND(inner_inline_view.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
	             THEN '||l_trend_sum_mv_commitment||' + '||l_trend_sum_mv_obligated||' + '||l_trend_sum_mv_other||' ELSE 0 END), 0) FII_PSI_ENCUMBRANCES_A,
             NVL(SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
                      AND BITAND(inner_inline_view.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
	             THEN '||l_prim_or_sec||'ACTUAL_G ELSE 0 END), 0) FII_PSI_ACTUALS_A';

IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN

l_inner_sql_nonsys_agg :=
'      SELECT   ' || l_aggrt_viewby_id || ' VIEWBYID,
		' || l_inner_sql_nonsys || '
       FROM	fii_gl_trend_sum_mv f,
		(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		 FROM	fii_time_structures cal,
			fii_pmv_aggrt_gt gt
		 WHERE report_date in (:BOUNDARY_END,:PRIOR_BOUNDARY_END, :ASOF_DATE,:PREVIOUS_ASOF_DATE)
			AND  (BITAND(cal.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
			OR BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND)) inner_inline_view
      WHERE	f.time_id = inner_inline_view.time_id
		AND   f.period_type_id = inner_inline_view.period_type_id
		AND   f.parent_company_dim_id = inner_inline_view.parent_company_id
		AND   f.company_dim_id = inner_inline_view.company_id
		AND   f.parent_cost_center_dim_id = inner_inline_view.parent_cc_id
		AND   f.cost_center_dim_id = inner_inline_view.cc_id
		AND   f.parent_fin_category_dim_id = inner_inline_view.parent_fin_category_id
		AND   f.fin_category_dim_id = inner_inline_view.fin_category_id
      GROUP BY ' || l_aggrt_viewby_id || ', inner_inline_view.viewby, inner_inline_view.sort_order';

ELSIF (l_aggrt_gt_is_empty = 'N') OR
   (l_aggrt_gt_is_empty = 'Y' AND l_non_aggrt_gt_is_empty = 'Y')THEN
   /*Query fii_gl_agrt_sum_p_v if aggregated nodes need to be displayed or no nodes.*/
l_inner_sql_nonsys_agg :=
'      SELECT /*+ index(f fii_gl_agrt_sum_mv_n1) */
		' || l_aggrt_viewby_id || ' VIEWBYID,
		' || l_inner_sql_nonsys || '
       FROM	fii_gl_agrt_sum_mv_p_v f,
		' || l_fud2_from || '
		(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		 FROM	fii_time_structures cal,
			fii_pmv_aggrt_gt gt
		 WHERE report_date in (:BOUNDARY_END,:PRIOR_BOUNDARY_END, :ASOF_DATE,:PREVIOUS_ASOF_DATE)
			AND  (BITAND(cal.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
			OR BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND)) inner_inline_view
      WHERE	f.time_id = inner_inline_view.time_id
		AND   f.period_type_id = inner_inline_view.period_type_id
		AND   f.parent_company_id = inner_inline_view.parent_company_id
		AND   f.company_id = inner_inline_view.company_id
		AND   f.parent_cost_center_id = inner_inline_view.parent_cc_id
		AND   f.cost_center_id = inner_inline_view.cc_id
		AND   f.parent_fin_category_id = inner_inline_view.parent_fin_category_id
		AND   f.fin_category_id = inner_inline_view.fin_category_id
		AND   f.parent_fud1_id = inner_inline_view.parent_fud1_id
		AND   f.fud1_id = inner_inline_view.fud1_id
		' || l_fud2_where || '
      GROUP BY ' || l_aggrt_viewby_id || ', inner_inline_view.viewby, inner_inline_view.sort_order';
ELSE
	l_inner_sql_nonsys_agg := ' ';
END IF;

/*Only query fii_gl_base_map_mv_p_v if non-aggregated nodes need to be displayed.*/
IF l_non_aggrt_gt_is_empty = 'N' THEN
l_inner_sql_nonsys_nonagg :=
'
      SELECT	/*+ index(f fii_gl_base_map_mv_n1) */ ' || l_non_aggrt_viewby_id || ' VIEWBYID,
		' || l_inner_sql_nonsys || '
      FROM	fii_gl_base_map_mv_p_v f,
		fii_company_hierarchies co_hier,
		fii_cost_ctr_hierarchies cc_hier,
		fii_fin_item_leaf_hiers fin_hier,
		fii_udd1_hierarchies fud1_hier,
		' || l_fud2_from || '
		(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
		 FROM	fii_time_structures cal,
			fii_pmv_non_aggrt_gt gt
		 WHERE report_date in (:BOUNDARY_END, :PRIOR_BOUNDARY_END, :ASOF_DATE, :PREVIOUS_ASOF_DATE)
			AND  (BITAND(cal.record_type_id, :AMOUNT_TYPE_BITAND) = :AMOUNT_TYPE_BITAND
			OR BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND)) inner_inline_view
      WHERE	f.time_id = inner_inline_view.time_id
		AND   f.period_type_id = inner_inline_view.period_type_id
		AND   f.company_id = co_hier.child_company_id
		AND   co_hier.parent_company_id = inner_inline_view.company_id
		AND   f.cost_center_id = cc_hier.child_cc_id
		AND   cc_hier.parent_cc_id = inner_inline_view.cost_center_id
		AND   f.fin_category_id = fin_hier.child_fin_cat_id ' || l_cat_decode || '
		AND   fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
		AND   f.fud1_id = fud1_hier.child_value_id ' || l_fud1_decode || '
		AND   fud1_hier.parent_value_id = inner_inline_view.fud1_id
		' || l_fud2_where || '
      GROUP BY ' || l_non_aggrt_viewby_id || ', inner_inline_view.viewby, inner_inline_view.sort_order';
ELSE
	l_inner_sql_nonsys_nonagg := ' ';
END IF;


/*query does not involve a union so it is below length limit*/
IF l_aggrt_gt_is_empty = 'Y' OR l_non_aggrt_gt_is_empty = 'Y' THEN

sqlstmt := l_outer_sql_b || l_inner_sql_nonsys_agg
                         || l_union_sql
                         || l_inner_sql_nonsys_nonagg
           || l_outer_sql_e;

FII_EA_UTIL_PKG.bind_variable(
        p_sqlstmt => sqlstmt,
        p_page_parameter_tbl => p_page_parameter_tbl,
        p_sql_output => funds_avail_sql,
        p_bind_output_table => funds_avail_output);

ELSE /*query involves a union so query exceedes length limit and need to use the gt table.*/

l_schema_name := FII_UTIL.get_schema_name('FII');
EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema_name||'.FII_PSI_PMV_GT';

sqlstmt_temp := l_insert_sql_b ||
           l_outer_sql_b || l_inner_sql_nonsys_agg
                         || l_union_sql
                         || l_inner_sql_nonsys_nonagg
           || l_outer_sql_e;

sqlstmt_temp := REPLACE(sqlstmt_temp, ':DIR_MSG', to_char(fii_ea_util_pkg.g_dir_msg));
sqlstmt_temp := REPLACE(sqlstmt_temp, ':BOUNDARY_END', '''' || to_char(fii_ea_util_pkg.g_boundary_end, 'DD/MM/YYYY') || '''');
sqlstmt_temp := REPLACE(sqlstmt_temp, ':AMOUNT_TYPE_BITAND', to_char(fii_ea_util_pkg.g_amount_type_BITAND));
sqlstmt_temp := REPLACE(sqlstmt_temp, ':PRIOR_BOUNDARY_END', '''' || to_char(fii_ea_util_pkg.g_prior_boundary_end, 'DD/MM/YYYY') || '''');
sqlstmt_temp := REPLACE(sqlstmt_temp, ':ASOF_DATE', '''' || to_char(fii_ea_util_pkg.g_as_of_date, 'DD/MM/YYYY') || '''');
sqlstmt_temp := REPLACE(sqlstmt_temp, ':PREVIOUS_ASOF_DATE', '''' || to_char(fii_ea_util_pkg.g_previous_asof_date, 'DD/MM/YYYY') || '''');
sqlstmt_temp := REPLACE(sqlstmt_temp, ':ACTUAL_BITAND', to_char(fii_ea_util_pkg.g_actual_BITAND));

EXECUTE IMMEDIATE(sqlstmt_temp);

funds_avail_sql :=
'SELECT VIEWBY,
	VIEWBYID,
	FII_PSI_AVAIL_C,
	FII_PSI_PRIOR_AVAIL_C,
	FII_PSI_GT_AVAIL_C,
	FII_PSI_GT_PRIOR_AVAIL_C,
	FII_PSI_PCNT_AVAIL_C,
	FII_PSI_PRIOR_PCNT_AVAIL_C,
	FII_PSI_GT_PCNT_AVAIL_C,
	FII_PSI_GT_PRIOR_PCNT_AVAIL_C,
	FII_PSI_BUDGET_C,
	FII_PSI_PRIOR_BUDGET_C,
	FII_PSI_GT_BUDGET_C,
	FII_PSI_GT_PRIOR_BUDGET_C,
	FII_PSI_ENCUMBRANCES_C,
	FII_PSI_PRIOR_ENCUMBRANCES_C,
	FII_PSI_GT_ENCUMBRANCES_C,
	FII_PSI_GT_PRIOR_ENCUM_C,
	FII_PSI_COMMITTED_C_KPI,
	FII_PSI_PRIOR_COMMITTED_C,
	FII_PSI_GT_COMMITTED_C_KPI,
	FII_PSI_GT_PRIOR_COMMITTED_C,
	FII_PSI_OBLIGATED_C_KPI,
	FII_PSI_PRIOR_OBLIGATED_C,
	FII_PSI_GT_OBLIGATED_C_KPI,
	FII_PSI_GT_PRIOR_OBLIGATED_C,
	FII_PSI_OTHERS_C_KPI,
	FII_PSI_PRIOR_OTHERS_C,
	FII_PSI_GT_OTHERS_C_KPI,
	FII_PSI_GT_PRIOR_OTHERS_C,
	FII_PSI_ACTUALS_C,
	FII_PSI_PRIOR_ACTUALS_C,
	FII_PSI_GT_ACTUALS_C,
	FII_PSI_GT_PRIOR_ACTUALS_C,
	FII_PSI_BUDGET_A,
	FII_PSI_ENCUMBRANCES_A,
	FII_PSI_ACTUALS_A,
	FII_PSI_GT_BUDGET_A,
	FII_PSI_GT_ENCUMBRANCES_A,
	FII_PSI_GT_ACTUALS_A,
	FII_PSI_COMP_DRILL,
	FII_PSI_CC_DRILL,
	FII_PSI_CAT_DRILL,
	FII_PSI_PROJECT_DRILL,
	FII_PSI_UD2_DRILL
FROM	FII_PSI_PMV_GT
ORDER BY NVL(SORT_ORDER, 999999) asc,
         NVL(FII_PSI_BUDGET_C, -999999) desc,
         NVL(VIEWBY, 999999) asc';

END IF;

END IF;

END GET_FUNDS_AVAIL_SUM;

END FII_PSI_FUNDS_AVAIL_SUM_PKG;

/
