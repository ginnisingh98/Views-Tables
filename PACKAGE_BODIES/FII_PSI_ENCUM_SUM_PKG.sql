--------------------------------------------------------
--  DDL for Package Body FII_PSI_ENCUM_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PSI_ENCUM_SUM_PKG" AS
/* $Header: FIIPSIENB.pls 120.6.12000000.2 2007/04/16 06:54:25 dhmehra ship $ */

PROCEDURE get_encum_sum(
	p_page_parameter_tbl			IN	BIS_PMV_PAGE_PARAMETER_TBL,
	p_enc_sum_sql					OUT NOCOPY	VARCHAR2,
	p_enc_sum_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 				VARCHAR2(20000);	-- Variable that stores the final SQL query

l_aggrt_viewby_id			VARCHAR2(240);		-- Variable to store viewby_id when using aggregate mv
l_nonaggrt_viewby_id			VARCHAR2(240);		-- Variable to store viewby_id when using nonaggregate mv
l_aggrt_gt_is_empty			VARCHAR2(240); 		-- Variable to check if fii_pmv_aggrt_gt is empty
l_non_aggrt_gt_is_empty			VARCHAR2(240);		-- Variable to check if fii_pmv_non_aggrt_gt is empty
l_roll_column				VARCHAR2(240);		-- Variable to append rolling period expression (ytd or qtd) based on period type chosen
l_xtd_column				VARCHAR2(240);		-- Variable to append rolling period expression (ytd or qtd or mtd) based on period type chosen

l_query_start				VARCHAR2(10000);	-- Variable to store the prefix part of final query
l_fii_gl_agrt_sum_mv			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_agrt_sum_mv_p_v
l_fii_gl_base_map_mv			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_base_map_mv_p_v
l_trend_sum_mv_sql			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_trend_sum_mv_p_v
l_query_end				VARCHAR2(10000);	-- Variable to store the suffix part of final query

p_snap_aggrt_viewby_id        		VARCHAR2(30); /* Added for Bug 4199668*/

/*Bug 4192505: Variables intitialized*/
l_fud2_enabled_flag           		VARCHAR2(1);
l_fud2_where                  		VARCHAR2(300);
l_fud2_snap_where             		VARCHAR2(300);
l_fud2_from                   		VARCHAR2(100);

/* Bug 4190997: Variables Defined */

l_xtd_drill_url         		VARCHAR2(300);

BEGIN

	/* Clear global parameters AND read the new parameters */
	-- Sets all g_% variables to its default values
	fii_ea_util_pkg.reset_globals;

	-- Reads the parameters from the parameter portlet
	fii_ea_util_pkg.get_parameters( p_page_parameter_tbl);

	-- Sets fin_cat_type to Operating Expenses(OE) as Encumbrances are part of OE
	fii_ea_util_pkg.g_fin_cat_type := 'OE';

	-- Gets the viewby_id
	fii_ea_util_pkg.get_viewby_id(l_aggrt_viewby_id, p_snap_aggrt_viewby_id, l_nonaggrt_viewby_id);

	-- Populates the security related global temporary tables
	fii_ea_util_pkg.populate_security_gt_tables(l_aggrt_gt_is_empty, l_non_aggrt_gt_is_empty);

	-- Initialise the global variables to set FII_PREVIOUS_ONE_DATE, etc.
	fii_ea_util_pkg.get_rolling_period();

	-- Decision ytd, qtd, mtd based on the period type chosen
	CASE fii_ea_util_pkg.g_page_period_type

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

/* Bug 4192505 Start */
SELECT  dbi_enabled_flag INTO l_fud2_enabled_flag
FROM    fii_financial_dimensions
WHERE   dimension_short_name = 'FII_USER_DEFINED_2';

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       and fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       and fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';
  END IF;
END IF;
/* Bug 4192505 End */

/* Bug 4190997 Start */
	IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
		fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);
  	ELSIF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
		fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
  	END IF;
/* Bug 4190997 End */

-- Constructing drilldown URL
l_xtd_drill_url := 'pFunctionName=FII_PSI_ENC_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

	l_query_start := '
		 -- Final Query Header
		SELECT  inline_view.viewby VIEWBY,
			inline_view.viewby_id VIEWBYID,
			SUM(FII_PSI_XTD) FII_PSI_XTD,
			SUM(FII_PSI_COMMITMENTS) FII_PSI_COMMITMENTS,
			SUM(FII_PSI_OBLIGATIONS) FII_PSI_OBLIGATIONS,
			SUM(FII_PSI_OTHER) FII_PSI_OTHER,

			SUM(FII_PSI_HIST_COL1) FII_PSI_HIST_COL1,
			SUM(FII_PSI_HIST_COL2) FII_PSI_HIST_COL2,
			SUM(FII_PSI_HIST_COL3) FII_PSI_HIST_COL3,
			SUM(FII_PSI_HIST_COL4) FII_PSI_HIST_COL4,
                        DECODE(SUM(FII_PSI_XTD), 0, NULL, NULL, NULL, '''|| l_xtd_drill_url||''') FII_PSI_XTD_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM	fii_company_hierarchies
				WHERE	parent_company_id = inline_view.viewby_id
					and child_company_id = inline_view.viewby_id),
					''Y'',
					'''',
				''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_COMPANIES+FII_COMPANIES&pParamIds=Y'') FII_PSI_COMP_DRILL,

			DECODE((SELECT  is_leaf_flag
				FROM	fii_cost_ctr_hierarchies
				WHERE	parent_cc_id = inline_view.viewby_id
					and child_cc_id = inline_view.viewby_id),
					''Y'',
					'''',
					''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+HRI_CL_ORGCC&pParamIds=Y'') FII_PSI_CC_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM	fii_fin_item_leaf_hiers
				WHERE	parent_fin_cat_id = inline_view.viewby_id
					and child_fin_cat_id = inline_view.viewby_id),
					''Y'',
					'''',
				-- Additional DECODE added for bug 4190997
					DECODE(:G_ID, inline_view.viewby_id,'''',
					''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FINANCIAL ITEM+GL_FII_FIN_ITEM&pParamIds=Y'')) FII_PSI_CAT_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM	fii_udd1_hierarchies
				WHERE	parent_value_id = inline_view.viewby_id
					and child_value_id = inline_view.viewby_id),
					''Y'',
					'''',
				-- Additional DECODE added for bug 4190997
					DECODE(:G_ID, inline_view.viewby_id,'''',
					''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_1&pParamIds=Y'')) FII_PSI_PROJECT_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM	fii_udd2_hierarchies
				WHERE	parent_value_id = inline_view.viewby_id
					and child_value_id = inline_view.viewby_id),
					''Y'',
					'''',
					''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_USER_DEFINED+FII_USER_DEFINED_2&pParamIds=Y'') FII_PSI_UD2_DRILL,

			SUM(SUM(FII_PSI_COMMITMENTS)) OVER () FII_PSI_GT_COMMITMENTS,
			SUM(SUM(FII_PSI_OBLIGATIONS)) OVER () FII_PSI_GT_OBLIGATIONS,
			SUM(SUM(FII_PSI_OTHER)) OVER () FII_PSI_GT_OTHER,
			SUM(SUM(FII_PSI_XTD)) OVER () FII_PSI_GT_XTD,
			SUM(SUM(FII_PSI_HIST_COL1)) OVER ()  FII_PSI_GT_HIST_COL1,
			SUM(SUM(FII_PSI_HIST_COL2)) OVER ()  FII_PSI_GT_HIST_COL2,
			SUM(SUM(FII_PSI_HIST_COL3)) OVER ()  FII_PSI_GT_HIST_COL3,
			SUM(SUM(FII_PSI_HIST_COL4)) OVER () FII_PSI_GT_HIST_COL4

		FROM
		( ';

	l_fii_gl_agrt_sum_mv := '
			-- This part of the query gets executed if the nodes selected are aggregated nodes
			SELECT /*+ index(f fii_gl_agrt_sum_mv_n1) */
				'||l_aggrt_viewby_id||' viewby_id, inner_inline_view.viewby viewby, inner_inline_view.sort_order sort_order,

				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) ) FII_PSI_COMMITMENTS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) ) FII_PSI_OBLIGATIONS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_OTHER,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_XTD,

				SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL4

			FROM	fii_gl_agrt_sum_mv_p_v f,
  				'||l_fud2_from||'
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_aggrt_gt
				SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				  FROM fii_time_structures cal, fii_pmv_aggrt_gt gt
					WHERE report_date IN (
						:PREVIOUS_ONE_END_DATE,
						:PREVIOUS_TWO_END_DATE,
						:PREVIOUS_THREE_END_DATE,
						:BUD_ASOF_DATE
						)
						AND (
						BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
						OR
						BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
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
				AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
				AND f.fud1_id = inner_inline_view.fud1_id
			 	'||l_fud2_where||'

			GROUP BY '||l_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order ';

	l_fii_gl_base_map_mv := '
			--This part of the query gets executed if the nodes selected are non aggregated nodes
			SELECT /*+ index(f fii_gl_base_map_mv_n1) */ '||l_nonaggrt_viewby_id||' viewby_id, inner_inline_view.viewby viewby, inner_inline_view.sort_order sort_order,

				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) ) FII_PSI_COMMITMENTS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) ) FII_PSI_OBLIGATIONS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_OTHER,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_XTD,

				SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL4

			FROM fii_gl_base_map_mv_p_v f,
				fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
 				'||l_fud2_from||'
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_non_aggrt_gt
				SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				FROM fii_time_structures cal, fii_pmv_non_aggrt_gt gt
				WHERE report_date IN (
					:PREVIOUS_ONE_END_DATE,
					:PREVIOUS_TWO_END_DATE,
					:PREVIOUS_THREE_END_DATE,
					:BUD_ASOF_DATE
					)
					AND
					(
					BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					OR
					BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
					)
				) inner_inline_view

			WHERE 	f.time_id = inner_inline_view.time_id
				AND f.period_type_id=inner_inline_view.period_type_id
				AND f.company_id = co_hier.child_company_id
				AND f.cost_center_id = cc_hier.child_cc_id
             	AND f.fin_category_id = fin_hier.child_fin_cat_id
				AND f.fud1_id = fud1_hier.child_value_id
				AND co_hier.parent_company_id = inner_inline_view.company_id
                AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
                AND fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
                AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
 		'||l_fud2_where||'
			GROUP BY '||l_nonaggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order	';

	l_trend_sum_mv_sql := '
			-- query formed by hitting fii_gl_trend_sum_mv_p_v

			SELECT '||l_aggrt_viewby_id||' viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) ) FII_PSI_COMMITMENTS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) ) FII_PSI_OBLIGATIONS,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_OTHER,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_XTD,

				SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date,   :PREVIOUS_THREE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL1,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_TWO_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL2,
				SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :PREVIOUS_ONE_END_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL3,
				SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.commitments_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.obligations_g  ELSE NULL END) ) )
				+ SUM(DECODE(inner_inline_view.report_date, :BUD_ASOF_DATE,
					(CASE WHEN BITAND(inner_inline_view.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND THEN f.others_g  ELSE NULL END) ) ) FII_PSI_HIST_COL4

			FROM	fii_gl_trend_sum_mv_p_v f,
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_aggrt_gt
				SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				  FROM fii_time_structures cal, fii_pmv_aggrt_gt gt
				 WHERE report_date IN (
						:PREVIOUS_ONE_END_DATE,
						:PREVIOUS_TWO_END_DATE,
						:PREVIOUS_THREE_END_DATE,
						:BUD_ASOF_DATE
						)
						AND (
						BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
						OR
						BITAND(cal.record_type_id,:HIST_ACTUAL_BITAND) = :HIST_ACTUAL_BITAND
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

			GROUP BY '||l_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order ';

	l_query_end := '
		 -- Final Query Header
		 ) inline_view

	GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order
	ORDER BY 	NVL(inline_view.sort_order,999999) asc, NVL(FII_PSI_XTD, -999999999) desc';

	-- Adding the Final Query Header
	sqlstmt := l_query_start;

	IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN
		-- Appending the part of query that hits fii_gl_trend_sum_mv_p_v
		sqlstmt := sqlstmt || l_trend_sum_mv_sql;
	ELSIF l_aggrt_gt_is_empty = 'N' then
		-- Appending the part of query that hits fii_gl_agrt_sum_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_agrt_sum_mv;
		IF l_non_aggrt_gt_is_empty = 'N' then
			-- Appending the part of query that hits fii_gl_base_map_mv_p_v
			sqlstmt := sqlstmt || ' UNION ALL ' ||  l_fii_gl_base_map_mv;
		END IF;
	ELSIF  l_non_aggrt_gt_is_empty = 'N' then
		-- Appending the part of query that hits fii_gl_base_map_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_base_map_mv;
	ELSE
		-- Default case
		-- Appending the part of query that hits fii_gl_agrt_sum_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_agrt_sum_mv;
	END IF;

	-- Appending the Final Query Footer
	sqlstmt := sqlstmt || l_query_end;


	-- Calling the bind_variable API
	fii_ea_util_pkg.bind_variable(
		p_sqlstmt => sqlstmt,
		p_Page_parameter_tbl => p_page_parameter_tbl,
		p_sql_output => p_enc_sum_sql,
		p_bind_output_table => p_enc_sum_output
	);


END get_encum_sum;

PROCEDURE get_encum_sum_port(
	p_page_parameter_tbl			IN	BIS_PMV_PAGE_PARAMETER_TBL,
	p_enc_sum_sql					OUT NOCOPY	VARCHAR2,
	p_enc_sum_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 				VARCHAR2(20000);	-- Variable that stores the final SQL query

l_aggrt_viewby_id			VARCHAR2(240);		-- Variable to store viewby_id when using aggregate mv
l_nonaggrt_viewby_id			VARCHAR2(240);		-- Variable to store viewby_id when using nonaggregate mv
l_aggrt_gt_is_empty			VARCHAR2(240); 		-- Variable to check if fii_pmv_aggrt_gt is empty
l_non_aggrt_gt_is_empty			VARCHAR2(240);		-- Variable to check if fii_pmv_non_aggrt_gt is empty
l_xtd_column				VARCHAR2(240);		-- Variable to append rolling period expression (ytd or qtd or mtd) based on period type chosen

l_query_start				VARCHAR2(10000);	-- Variable to store the prefix part of final query
l_fii_gl_agrt_sum_mv			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_agrt_sum_mv_p_v
l_fii_gl_base_map_mv			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_base_map_mv_p_v
l_trend_sum_mv_sql			VARCHAR2(10000);	-- Variable to store the part of query that hits fii_gl_trend_sum_mv_p_v
l_query_end				VARCHAR2(10000);	-- Variable to store the suffix part of final query

p_snap_aggrt_viewby_id        		VARCHAR2(30); /* Added for Bug 4199668*/

/*Bug 4192505: Variables intitialized*/
l_fud2_enabled_flag           		VARCHAR2(1);
l_fud2_where                  		VARCHAR2(300);
l_fud2_snap_where             		VARCHAR2(300);
l_fud2_from                   		VARCHAR2(100);

/* Bug 4190997: Variables Defined */
l_xtd_drill_url         		VARCHAR2(300);

BEGIN

	/* Clear global parameters AND read the new parameters */
	-- Sets all g_% variables to its default values
	fii_ea_util_pkg.reset_globals;

	-- Reads the parameters from the parameter portlet
	fii_ea_util_pkg.get_parameters( p_page_parameter_tbl);

	-- Sets fin_cat_type to Operating Expenses(OE) as Encumbrances are part of OE
	fii_ea_util_pkg.g_fin_cat_type := 'OE';

	-- Gets the viewby_id
	fii_ea_util_pkg.get_viewby_id(l_aggrt_viewby_id, p_snap_aggrt_viewby_id, l_nonaggrt_viewby_id);

	-- Populates the security related global temporary tables
	fii_ea_util_pkg.populate_security_gt_tables(l_aggrt_gt_is_empty, l_non_aggrt_gt_is_empty);

	-- Initialise the global variables to set FII_PREVIOUS_ONE_DATE, etc.
	fii_ea_util_pkg.get_rolling_period();

	-- Decision ytd, qtd, mtd based on the period type chosen
	CASE fii_ea_util_pkg.g_page_period_type

	WHEN 'FII_TIME_ENT_YEAR' THEN
		l_xtd_column  := 'ytd' ;

	WHEN 'FII_TIME_ENT_QTR' THEN
		l_xtd_column  := 'qtd' ;

	WHEN 'FII_TIME_ENT_PERIOD' THEN
		l_xtd_column  := 'mtd' ;

	END CASE;

/* Bug 4192505 Start */
SELECT  dbi_enabled_flag INTO l_fud2_enabled_flag
FROM    fii_financial_dimensions
WHERE   dimension_short_name = 'FII_USER_DEFINED_2';

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       and fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

        l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

        l_fud2_snap_where := '  and fud2_hier.parent_value_id = gt.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';

        l_fud2_where := '       and fud2_hier.parent_value_id = inner_inline_view.fud2_id
                                and fud2_hier.child_value_id = f.fud2_id ';
  END IF;
END IF;
/* Bug 4192505 End */

/* Bug 4190997 Start */
	IF fii_ea_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
		fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_category_id);
	ELSIF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
		fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
	END IF;
/* Bug 4190997 End */

-- Constructing drilldown URL
l_xtd_drill_url := 'pFunctionName=FII_PSI_ENC_TREND_DTL&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

	l_query_start := '
		 -- Final Query Header
		SELECT  inline_view.viewby VIEWBY,
			inline_view.viewby_id VIEWBYID,
			SUM(FII_PSI_XTD) FII_PSI_XTD,
			SUM(FII_PSI_COMMITMENTS) FII_PSI_COMMITMENTS,
			SUM(FII_PSI_OBLIGATIONS) FII_PSI_OBLIGATIONS,
			SUM(FII_PSI_OTHER) FII_PSI_OTHER,
                        DECODE(SUM(FII_PSI_XTD), 0, NULL, NULL, NULL, '''|| l_xtd_drill_url||''') FII_PSI_XTD_DRILL,
			DECODE((SELECT  is_leaf_flag
				FROM	fii_company_hierarchies
				WHERE	parent_company_id = inline_view.viewby_id
					AND child_company_id = inline_view.viewby_id),
					''Y'',
					'''',
				''pFunctionName=FII_PSI_ENCUM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=FII_COMPANIES+FII_COMPANIES&pParamIds=Y'') FII_PSI_COMP_DRILL,
			SUM(SUM(FII_PSI_COMMITMENTS)) OVER () FII_PSI_GT_COMMITMENTS,
			SUM(SUM(FII_PSI_OBLIGATIONS)) OVER () FII_PSI_GT_OBLIGATIONS,
			SUM(SUM(FII_PSI_OTHER)) OVER () FII_PSI_GT_OTHER,
			SUM(SUM(FII_PSI_XTD)) OVER () FII_PSI_GT_XTD

		FROM
		( ';

	l_fii_gl_agrt_sum_mv := '
			-- This part of the query gets executed if the nodes selected are aggregated nodes

			SELECT /*+ index(f fii_gl_agrt_sum_mv_n1) */
				'||l_aggrt_viewby_id||' viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(f.commitments_g) FII_PSI_COMMITMENTS,
				SUM(f.obligations_g) FII_PSI_OBLIGATIONS,
				SUM(f.others_g) FII_PSI_OTHER,
				SUM(f.commitments_g) + SUM(f.obligations_g) + SUM(f.others_g) FII_PSI_XTD

			FROM	fii_gl_agrt_sum_mv_p_v f,
				'||l_fud2_from||'
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_aggrt_gt
				SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				  FROM fii_time_structures cal, fii_pmv_aggrt_gt gt
				 WHERE report_date = :BUD_ASOF_DATE
 					      AND (BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND)
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

			GROUP BY '||l_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order ';

	l_fii_gl_base_map_mv := '
			--This part of the query gets executed if the nodes selected are non aggregated nodes

			SELECT /*+ index(f fii_gl_base_map_mv_n1) */
				'||l_nonaggrt_viewby_id||' viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(f.commitments_g) FII_PSI_COMMITMENTS,
				SUM(f.obligations_g) FII_PSI_OBLIGATIONS,
				SUM(f.others_g) FII_PSI_OTHER,
				SUM(f.commitments_g) + SUM(f.obligations_g) + SUM(f.others_g) FII_PSI_XTD

			FROM	fii_gl_base_map_mv_p_v f,
				fii_company_hierarchies co_hier,
				fii_cost_ctr_hierarchies cc_hier,
				fii_fin_item_leaf_hiers fin_hier,
				fii_udd1_hierarchies fud1_hier,
  				'||l_fud2_from||'
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_non_aggrt_gt
				SELECT /*+ NO_MERGE cardinality(gt 1) */ *
				FROM fii_time_structures cal, fii_pmv_non_aggrt_gt gt
				WHERE report_date = :BUD_ASOF_DATE
					AND ( BITAND(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND)
				) inner_inline_view

			WHERE 	f.time_id = inner_inline_view.time_id
				AND f.period_type_id=inner_inline_view.period_type_id
				AND f.company_id = co_hier.child_company_id
				AND f.cost_center_id = cc_hier.child_cc_id
             			AND f.fin_category_id = fin_hier.child_fin_cat_id
				AND f.fud1_id = fud1_hier.child_value_id
				AND co_hier.parent_company_id = inner_inline_view.company_id
				AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
				AND fin_hier.parent_fin_cat_id = inner_inline_view.fin_category_id
				AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
 				'||l_fud2_where||'

			GROUP BY '||l_nonaggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order ';

	l_trend_sum_mv_sql := '
			-- query that hits fii_gl_trend_sum_mv_p_v

			SELECT '||l_aggrt_viewby_id||' viewby_id,
				inner_inline_view.viewby viewby,
				inner_inline_view.sort_order sort_order,
				SUM(f.commitments_g) FII_PSI_COMMITMENTS,
				SUM(f.obligations_g) FII_PSI_OBLIGATIONS,
				SUM(f.others_g) FII_PSI_OTHER,
				SUM(f.commitments_g) + SUM(f.obligations_g) + SUM(f.others_g) FII_PSI_XTD

			FROM	fii_gl_trend_sum_mv_p_v f,
				(
				-- This part of the query joins the fii_time_structures with fii_pmv_aggrt_gt
				SELECT	/*+ NO_MERGE cardinality(gt 1) */ *
				FROM	fii_time_structures cal,
					fii_pmv_aggrt_gt gt
				WHERE	report_date = :BUD_ASOF_DATE
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

			GROUP BY '||l_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order ';

	l_query_end := '
		 -- Final Query Header
		 ) inline_view

	GROUP BY	inline_view.viewby, inline_view.viewby_id, inline_view.sort_order
	ORDER BY 	NVL(inline_view.sort_order,999999) asc, NVL(FII_PSI_XTD, -999999999) desc';

	-- Adding the Final Query Header
	sqlstmt := l_query_start;

	IF fii_ea_util_pkg.g_if_trend_sum_mv = 'Y' THEN
		-- Appending the part of query that hits fii_gl_trend_sum_mv_p_v
		sqlstmt := sqlstmt || l_trend_sum_mv_sql;
	ELSIF l_aggrt_gt_is_empty = 'N' then
		-- Appending the part of query that hits fii_gl_agrt_sum_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_agrt_sum_mv;
		IF l_non_aggrt_gt_is_empty = 'N' then
			-- Appending the part of query that hits fii_gl_base_map_mv_p_v
			sqlstmt := sqlstmt || ' UNION ALL ' || l_fii_gl_base_map_mv;
		END IF;
	ELSIF  l_non_aggrt_gt_is_empty = 'N' then
		-- Appending the part of query that hits fii_gl_base_map_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_base_map_mv;
	ELSE
		-- Default case
		-- Appending the part of query that hits fii_gl_agrt_sum_mv_p_v
		sqlstmt := sqlstmt || l_fii_gl_agrt_sum_mv;
	END IF;

	-- Appending the Final Query Footer
	sqlstmt := sqlstmt || l_query_end;

	-- Calling the bind_variable API
	fii_ea_util_pkg.bind_variable(
		p_sqlstmt => sqlstmt,
		p_Page_parameter_tbl => p_page_parameter_tbl,
		p_sql_output => p_enc_sum_sql,
		p_bind_output_table => p_enc_sum_output
	);


END get_encum_sum_port;

END fii_psi_encum_sum_pkg;


/
