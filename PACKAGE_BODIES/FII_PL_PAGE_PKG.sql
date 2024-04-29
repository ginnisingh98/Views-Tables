--------------------------------------------------------
--  DDL for Package Body FII_PL_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PL_PAGE_PKG" AS
/*  $Header: FIIPLPGB.pls 120.5.12000000.2 2007/04/16 06:42:17 dhmehra ship $ */

PROCEDURE get_pl_graph (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, pl_graph_sql out NOCOPY VARCHAR2,
  pl_graph_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt               VARCHAR2(30000);


BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_cat_type :=NULL;
    sqlstmt := fii_pl_page_pkg.get_pl_graph_val(p_page_parameter_tbl);
    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, pl_graph_sql, pl_graph_output);

END get_pl_graph;


FUNCTION get_pl_graph_val (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 IS

  sqlstmt			VARCHAR2(15000);

  p_aggrt_viewby_id             VARCHAR2(30);
  p_snap_aggrt_viewby_id        VARCHAR2(30);
  p_nonaggrt_viewby_id          VARCHAR2(50);

  p_aggrt_gt_is_empty           VARCHAR2(1);
  p_non_aggrt_gt_is_empty       VARCHAR2(1);
  --l_roll_column                 VARCHAR2(10);
  l_xtd_column                  VARCHAR2(10);
  l_source_cogs         	VARCHAR2(100);
  l_source_exp          	VARCHAR2(100);
  l_source_inc          	VARCHAR2(100);


BEGIN
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ea_util_pkg.g_view_by := 'FII_COMPANIES+FII_COMPANIES';
fii_ea_util_pkg.populate_security_gt_tables(p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

l_source_cogs := ltrim(rtrim(fnd_message.get_string('FII','FII_PL_SOURCE_COGS')));
l_source_exp := ltrim(rtrim(fnd_message.get_string('FII','FII_PL_SOURCE_EXP')));
l_source_inc := ltrim(rtrim(fnd_message.get_string('FII','FII_PL_SOURCE_INC')));

 sqlstmt :='
SELECT
FII_PL_SOURCE,
FII_PL_XTD_AMT,
(NVL(FII_PL_XTD_AMT,0)/NULLIF(ABS(NVL((SUM(FII_PL_XTD_AMT) over()),0)),0))*100 FII_PL_XTD_AMT_R
FROM
(SELECT
FII_PL_SOURCE,
CASE WHEN FII_PL_XTD_AMT < 0 THEN 0 ELSE FII_PL_XTD_AMT END FII_PL_XTD_AMT,
FII_ORDER_BY
FROM
(
	SELECT	'||''''||l_source_exp||''''||' FII_PL_SOURCE,
	SUM(f.actual_g)  FII_PL_XTD_AMT,
	2 	FII_ORDER_BY
	FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
		( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
		FROM 	fii_time_structures cal, fii_pmv_aggrt_gt gt
		where	report_date in (:ASOF_DATE)
		and (	bitand(cal.record_type_id, :ACTUAL_BITAND) =
		:ACTUAL_BITAND)
		) inner_inline_view
	WHERE 	f.time_id = inner_inline_view.time_id
	AND f.period_type_id = inner_inline_view.period_type_id
	AND f.parent_company_id = inner_inline_view.parent_company_id
	AND f.company_id = inner_inline_view.company_id
	AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
	AND f.cost_center_id = inner_inline_view.cc_id
	AND f.top_node_fin_cat_type=''OE''
	UNION ALL
	SELECT	 '||''''||l_source_inc||''''||' FII_EA_SOURCE,
	SUM(DECODE(f.top_node_fin_cat_type, ''R'',f.actual_g,f.actual_g*-1))
		FII_PL_XTD_AMT,
	1 	FII_ORDER_BY
	FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
		( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
		FROM 	fii_time_structures cal, fii_pmv_aggrt_gt gt
		where	report_date in (:ASOF_DATE)
		and (	bitand(cal.record_type_id, :ACTUAL_BITAND) =
		:ACTUAL_BITAND)
		) inner_inline_view
	WHERE 	f.time_id = inner_inline_view.time_id
	AND f.period_type_id = inner_inline_view.period_type_id
	AND f.parent_company_id = inner_inline_view.parent_company_id
	AND f.company_id = inner_inline_view.company_id
	AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
	AND f.cost_center_id = inner_inline_view.cc_id
	AND f.top_node_fin_cat_type IN ('||'''R'''||','||'''OE'''||','||'''CGS'''||')
	UNION ALL
	SELECT	 '||''''||l_source_cogs||''''||' FII_PL_SOURCE,
	SUM(f.actual_g)  FII_PL_XTD_AMT,
	3	FII_ORDER_BY
	FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
		( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
		FROM 	fii_time_structures cal, fii_pmv_aggrt_gt gt
		where	report_date in (:ASOF_DATE)
		and (	bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND )
		) inner_inline_view
	WHERE 	f.time_id = inner_inline_view.time_id
	AND f.period_type_id = inner_inline_view.period_type_id
	AND f.parent_company_id = inner_inline_view.parent_company_id
	AND f.company_id = inner_inline_view.company_id
	AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
	AND f.cost_center_id = inner_inline_view.cc_id
	AND f.top_node_fin_cat_type=''CGS''
) ORDER BY FII_ORDER_BY)
';


  return sqlstmt;

END get_pl_graph_val;


PROCEDURE get_rev_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_type := 'R';

    fii_pl_page_pkg.get_expense_sum(p_page_parameter_tbl,
                                     expense_sum_sql,
                                     expense_sum_output);
END get_rev_trend;

PROCEDURE get_exp_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_type := 'OE';

    fii_pl_page_pkg.get_expense_sum(p_page_parameter_tbl,
                                     expense_sum_sql,
                                     expense_sum_output);
END get_exp_trend;

PROCEDURE get_cogs_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_ea_util_pkg.reset_globals;
    fii_ea_util_pkg.g_fin_type := 'CGS';

    fii_pl_page_pkg.get_expense_sum(p_page_parameter_tbl,
                                     expense_sum_sql,
                                     expense_sum_output);
END get_cogs_trend;

PROCEDURE get_mar_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_ea_util_pkg.reset_globals;

    fii_pl_page_pkg.get_margin_sum(p_page_parameter_tbl,
                                     expense_sum_sql,
                                     expense_sum_output);
END get_mar_trend;

PROCEDURE get_expense_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   sqlstmt                 VARCHAR2(32000);
   l_pk                    VARCHAR2(30);
   l_name                  VARCHAR2(100);
   l_time_comp             VARCHAR2(20);
   l_prior_or_budget       VARCHAR2(1000);
   l_prior_or_budget1      VARCHAR2(1000);
   l_curr_effective_num    NUMBER;
   l_min_start_date	   DATE;
   p_aggrt_gt_is_empty     VARCHAR2(1);
   p_non_aggrt_gt_is_empty VARCHAR2(1);

BEGIN

  fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_ea_util_pkg.populate_security_gt_tables(
                  p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

  CASE fii_ea_util_pkg.g_page_period_type
    WHEN 'FII_TIME_ENT_PERIOD' THEN
      l_pk   := 'ent_period_id';
      l_name := 'to_char(t.start_date,''Mon'')';

    WHEN 'FII_TIME_ENT_QTR' THEN
      l_pk   := 'ent_qtr_id';
      l_name := 'replace(fnd_message.get_string(''FII'',''FII_QUARTER_LABEL''),''&QUARTER_NUMBER'',t.sequence)';

    WHEN 'FII_TIME_ENT_YEAR' THEN
      l_pk             := 'ent_year_id';

      SELECT MIN(start_date) into l_min_start_date
      FROM fii_time_ent_period;

      SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_ea_util_pkg.g_as_of_date)))),l_min_start_date)
      INTO fii_ea_util_pkg.g_py_sday
      FROM dual;

      SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_ea_util_pkg.g_previous_asof_date)))),l_min_start_date)
      INTO fii_ea_util_pkg.g_five_yr_back
      FROM dual;

   END CASE;

  /* if budget is selected, the prior amount column will return 0 */
  IF (fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL') OR
     (fii_ea_util_pkg.g_time_comp = 'FORECAST') THEN
	l_prior_or_budget :='case when t.start_date between :P_EXP_ASOF
                                          and :CY_PERIOD_END
                      then f.forecast_g else TO_NUMBER(NULL) end FORECAST ';
   ELSIF (fii_ea_util_pkg.g_time_comp = 'YEARLY') THEN
	l_prior_or_budget :=  'to_number(NULL) FORECAST ';
   ELSIF (fii_ea_util_pkg.g_time_comp = 'BUDGET') THEN
	l_prior_or_budget :=  ' to_number(NULL) FORECAST ';
  END IF;

/* ----------------------------------
   FII_MEASURE1 = Time Level Name
   FII_MEASURE2 = Current Year XTotal
   FII_MEASURE3 = Prior Year XTotal
   FII_MEASURE4 = Current Year XTD
   FII_MEASURE5 = Prior Year XTD
 * ----------------------------------*/

IF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
  sqlstmt := '
    select t.name        VIEWBY,
           t.'||l_pk||'  VIEWBYID,
           sum(CY_QTOT)  FII_MEASURE2,
           sum(PY_QTOT)  FII_MEASURE3,
           sum(CY_QTD)   FII_MEASURE4,
           sum(PY_QTD)   FII_MEASURE5,
           sum(BUDGET)   FII_MEASURE7,
           sum(FORECAST) FII_MEASURE8,
           sum(FORECAST) FII_MEASURE9,
           NVL(sum(CY_QTOT), 0) + NVL(sum(CY_QTD), 0)  FII_CAL1
    from (
      select t.sequence                FII_SEQUENCE,
             f.actual_g                CY_QTOT,
             TO_NUMBER(NULL)           PY_QTOT,
             TO_NUMBER(NULL)           CY_QTD,
             TO_NUMBER(NULL)           PY_QTD,
             f.budget_g                BUDGET,
             TO_NUMBER(NULL)           FORECAST
      from  fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
            fii_pmv_aggrt_gt gt,
             '||fii_ea_util_pkg.g_page_period_type||'  t
      where f.parent_company_id      = gt.parent_company_id
      and   f.company_id             = gt.company_id
      and   f.parent_cost_center_id  = gt.parent_cc_id
      and   f.cost_center_id         = gt.cc_id
      and   f.top_node_fin_cat_type  = :FIN_TYPE
      and   f.time_id               = t.'||l_pk||'
      and   f.period_type_id        = :PERIOD_TYPE
      and   t.start_date between :FIVE_YR_BACK
      and   :ENT_PYR_END
      union all
      select t.sequence               FII_SEQUENCE,
             TO_NUMBER(NULL)          CY_QTOT,
             TO_NUMBER(NULL)          PY_QTOT,
             case when bitand(inner_inline_view.record_type_id, :ACTUAL_BITAND)=:ACTUAL_BITAND
                  then f.actual_g else null end CY_QTD,
             TO_NUMBER(NULL)          PY_QTD,
             case when bitand(inner_inline_view.record_type_id, :BUDGET_BITAND)=:BUDGET_BITAND
                  then f.budget_g else null end BUDGET,
             case when bitand(inner_inline_view.record_type_id, :FORECAST_BITAND)=:FORECAST_BITAND
                  then f.forecast_g else null end FORECAST
      from fii_gl_trend_sum_mv'|| fii_ea_util_pkg.g_curr_view ||' f,
           '||fii_ea_util_pkg.g_page_period_type||'  t,
           (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
            FROM   fii_time_structures cal,
	           fii_pmv_aggrt_gt gt
            WHERE  cal.report_date = &BIS_CURRENT_ASOF_DATE
            AND    (bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
                    bitand(cal.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND OR
                    bitand(cal.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND)
           ) inner_inline_view,
           fii_time_day          day
      where f.time_id                = inner_inline_view.time_id
      and   f.period_type_id         = inner_inline_view.period_type_id
      and   f.parent_company_id      = inner_inline_view.parent_company_id
      and   f.company_id             = inner_inline_view.company_id
      and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
      and   f.cost_center_id         = inner_inline_view.cc_id
      and   f.top_node_fin_cat_type  = :FIN_TYPE
      and   inner_inline_view.report_date         = day.report_date
      and   day.'||l_pk||' = t.'||l_pk||'
    ) g1, '||fii_ea_util_pkg.g_page_period_type||' t
    where FII_SEQUENCE (+)= t.sequence
    and t.start_date >= :PY_SAME_DAY
    and t.end_date   <= :ENT_CYR_END
    group by t.sequence, t.name, t.'||l_pk||'
    order by t.sequence';

ELSIF (fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') and
      (fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL') THEN
  sqlstmt := '
    select t.name VIEWBY,
           t.'||l_pk||' VIEWBYID,
           CY_QTOT FII_MEASURE2,
           PY_QTOT FII_MEASURE3,
           CY_QTD  FII_MEASURE4,
           PY_QTD  FII_MEASURE5,
           BUDGET  FII_MEASURE7,
           FORECAST FII_MEASURE8,
           FORECAST FII_MEASURE9,
           NVL(CY_QTOT, 0) + NVL(CY_QTD, 0) FII_CAL1
    from
     (select inner_inline_view2.FII_SEQUENCE FII_EFFECTIVE_NUM,
             sum(CY_QTOT) CY_QTOT,
             sum(PY_QTOT) PY_QTOT,
             sum(CY_QTD)  CY_QTD,
             sum(PY_QTD)  PY_QTD,
             sum(BUDGET)  BUDGET,
             sum(FORECAST) FORECAST
      from
       (select t.'||l_pk||' FII_SEQUENCE,
               sum(case when t.'||l_pk||' <> :CURR_EFFECTIVE_SEQ
                        then f.actual_g else TO_NUMBER(NULL) end)  CY_QTOT,
               TO_NUMBER(NULL) PY_QTOT,
               TO_NUMBER(NULL) CY_QTD,
               TO_NUMBER(NULL) PY_QTD,
               sum(case when t.start_date between :P_EXP_ASOF
                                          and :CY_PERIOD_END
                        then f.budget_g else TO_NUMBER(NULL) end) BUDGET,
               sum(case when t.start_date between :P_EXP_ASOF
                                          and :CY_PERIOD_END
                        then f.forecast_g else TO_NUMBER(NULL) end) FORECAST
        from  fii_gl_trend_sum_mv'|| fii_ea_util_pkg.g_curr_view ||' f,
              '||fii_ea_util_pkg.g_page_period_type||'     t,
              fii_pmv_aggrt_gt gt
        where f.parent_company_id      = gt.parent_company_id
        and   f.company_id             = gt.company_id
        and   f.parent_cost_center_id  = gt.parent_cc_id
        and   f.cost_center_id         = gt.cc_id
        and   f.top_node_fin_cat_type  = :FIN_TYPE
        and   f.time_id               = t.'||l_pk||'
        and   f.period_type_id        = :PERIOD_TYPE
        and   t.start_date between :P_EXP_START
                           and &BIS_CURRENT_ASOF_DATE
        group by t.'||l_pk||'
        union all
        select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
               TO_NUMBER(NULL) CY_QTOT,
               TO_NUMBER(NULL) PY_QTOT,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE AND
                         bitand(inner_inline_view.record_type_id, :ACTUAL_BITAND)=:ACTUAL_BITAND
                    then f.actual_g else TO_NUMBER(NULL) end  CY_QTD,
               TO_NUMBER(NULL) PY_QTD,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE AND
                         bitand(inner_inline_view.record_type_id, :BUDGET_BITAND)=:BUDGET_BITAND
                    then f.budget_g else to_number(null) end BUDGET,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE AND
                         bitand(inner_inline_view.record_type_id, :FORECAST_BITAND)=:FORECAST_BITAND
                    then f.forecast_g else to_number(null) end   FORECAST
        from fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
              FROM   fii_time_structures cal,
                     fii_pmv_aggrt_gt gt
              WHERE  cal.report_date in (&BIS_CURRENT_ASOF_DATE,
                                         :P_EXP_ASOF)
              AND   (bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
                     bitand(cal.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND OR
                     bitand(cal.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND)) inner_inline_view
            where f.time_id                = inner_inline_view.time_id
            and   f.period_type_id         = inner_inline_view.period_type_id
            and   f.parent_company_id      = inner_inline_view.parent_company_id
            and   f.company_id             = inner_inline_view.company_id
            and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
            and   f.cost_center_id         = inner_inline_view.cc_id
            and   f.top_node_fin_cat_type  = :FIN_TYPE
            ) inner_inline_view2
            group by inner_inline_view2.FII_SEQUENCE
       ) g1,  '||fii_ea_util_pkg.g_page_period_type||' t
       where g1.fii_effective_num (+)= t.'||l_pk||'
       and   t.start_date <= &BIS_CURRENT_ASOF_DATE
       and   t.start_date >  :P_EXP_START
       order by t.start_date';
ELSE
  sqlstmt := '
    select t.name VIEWBY,
           t.'||l_pk||' VIEWBYID,
           CY_QTOT FII_MEASURE2,
           PY_QTOT FII_MEASURE3,
           CY_QTD  FII_MEASURE4,
           PY_QTD  FII_MEASURE5,
           BUDGET  FII_MEASURE7,
           FORECAST FII_MEASURE8,
           FORECAST FII_MEASURE9,
	   NVL(CY_QTOT, 0) + NVL(CY_QTD, 0) FII_CAL1
    from
     (select inner_inline_view2.FII_SEQUENCE FII_EFFECTIVE_NUM,
             sum(CY_QTOT) CY_QTOT,
             sum(PY_QTOT) PY_QTOT,
             sum(CY_QTD)  CY_QTD,
             sum(PY_QTD)  PY_QTD,
             sum(BUDGET)  BUDGET,
             sum(FORECAST) FORECAST
      from
       (select t.sequence FII_SEQUENCE,
               case when t.sequence <> :CURR_EFFECTIVE_SEQ
                    then (case when t.start_date between :P_EXP_ASOF
                                                 and :CY_PERIOD_END
                               then f.actual_g else TO_NUMBER(NULL)end)
                    else TO_NUMBER(NULL) end  CY_QTOT,
               case when t.start_date between :P_EXP_START
                                      and :P_EXP_ASOF
                    then f.actual_g else TO_NUMBER(NULL) end  PY_QTOT,
               TO_NUMBER(NULL) CY_QTD,
               TO_NUMBER(NULL) PY_QTD,
               case when t.start_date between :P_EXP_ASOF
                                      and :CY_PERIOD_END
                    then f.budget_g else TO_NUMBER(NULL) end BUDGET,
               '||l_prior_or_budget||'
        from  fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             '||fii_ea_util_pkg.g_page_period_type||'              t,
             fii_pmv_aggrt_gt gt
        where f.time_id               = t.'||l_pk||'
        and   f.period_type_id        = :PERIOD_TYPE
        and   f.parent_company_id      = gt.parent_company_id
        and   f.company_id             = gt.company_id
        and   f.parent_cost_center_id  = gt.parent_cc_id
        and   f.cost_center_id         = gt.cc_id
        and   f.top_node_fin_cat_type  = :FIN_TYPE
        and   t.start_date between :P_EXP_START
                           and &BIS_CURRENT_ASOF_DATE
        union all
        select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
               TO_NUMBER(NULL) CY_QTOT,
               TO_NUMBER(NULL) PY_QTOT,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE and
                         bitand(inner_inline_view.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
                    then f.actual_g else TO_NUMBER(NULL) end  CY_QTD,
               case when inner_inline_view.report_date = :P_EXP_ASOF and
                         bitand(inner_inline_view.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
                    then f.actual_g else TO_NUMBER(NULL) end PY_QTD,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE and
                         bitand(inner_inline_view.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND
                    then f.budget_g else to_number(null) end BUDGET,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE and
                         bitand(inner_inline_view.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
                    then f.forecast_g else to_number(null) end   FORECAST
        from fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
              FROM fii_time_structures cal,
       	           fii_pmv_aggrt_gt gt
              WHERE cal.report_date in (&BIS_CURRENT_ASOF_DATE,
                                        :P_EXP_ASOF)
              AND   (bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND OR
                     bitand(cal.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND OR
                     bitand(cal.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND)
              ) inner_inline_view
        where f.time_id                = inner_inline_view.time_id
        and   f.period_type_id         = inner_inline_view.period_type_id
        and   f.parent_company_id      = inner_inline_view.parent_company_id
        and   f.company_id             = inner_inline_view.company_id
        and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
        and   f.cost_center_id         = inner_inline_view.cc_id
        and   f.top_node_fin_cat_type  = :FIN_TYPE
      ) inner_inline_view2
         group by inner_inline_view2.FII_SEQUENCE
   ) g1,  '||fii_ea_util_pkg.g_page_period_type||' t
   where g1.fii_effective_num (+)= t.sequence
   and   t.start_date <= &BIS_CURRENT_ASOF_DATE
   and   t.start_date >  :P_EXP_BEGIN
   order by t.start_date';
END IF;

    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl,
                                  expense_sum_sql, expense_sum_output);
END get_expense_sum;


PROCEDURE get_margin_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   sqlstmt                 VARCHAR2(32000);
   l_pk                    VARCHAR2(30);
   l_name                  VARCHAR2(100);
   l_time_comp             VARCHAR2(20);
   l_curr_effective_num    NUMBER;
   l_min_start_date	   DATE;
   p_aggrt_gt_is_empty     VARCHAR2(1);
   p_non_aggrt_gt_is_empty VARCHAR2(1);

BEGIN

  fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_ea_util_pkg.populate_security_gt_tables(
                  p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

  CASE fii_ea_util_pkg.g_page_period_type
    WHEN 'FII_TIME_ENT_PERIOD' THEN
      l_pk   := 'ent_period_id';
      l_name := 'to_char(t.start_date,''Mon'')';

    WHEN 'FII_TIME_ENT_QTR' THEN
      l_pk   := 'ent_qtr_id';
      l_name := 'replace(fnd_message.get_string(''FII'',''FII_QUARTER_LABEL''),''&QUARTER_NUMBER'',t.sequence)';

    WHEN 'FII_TIME_ENT_YEAR' THEN
      l_pk             := 'ent_year_id';

      SELECT MIN(start_date) into l_min_start_date
      FROM fii_time_ent_period;

      SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_ea_util_pkg.g_as_of_date)))),l_min_start_date)
      INTO fii_ea_util_pkg.g_py_sday
      FROM dual;

      SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_ea_util_pkg.g_previous_asof_date)))),l_min_start_date)
      INTO fii_ea_util_pkg.g_five_yr_back
      FROM dual;

   END CASE;


/* ----------------------------------
   FII_MEASURE1 = Time Level Name
   FII_MEASURE2 = Current Year XTotal
   FII_MEASURE3 = Prior Year XTotal
   FII_MEASURE4 = Current Year XTD
   FII_MEASURE5 = Prior Year XTD
 * ----------------------------------*/

IF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
  sqlstmt := '
    select t.name        VIEWBY,
           t.'||l_pk||'  VIEWBYID,
           (nvl(sum(CY_QTOT_REV), 0) - nvl(sum(CY_QTOT_EXP), 0) - nvl(sum(CY_QTOT_CGS), 0)) /
           nullif(abs(nvl(sum(CY_QTOT_REV), 0)), 0) * 100 FII_MEASURE2,
           to_number(NULL)  FII_MEASURE3,
           (nvl(sum(CY_QTD_REV), 0) - nvl(sum(CY_QTD_EXP), 0) - nvl(sum(CY_QTD_CGS), 0)) /
           nullif(abs(nvl(sum(CY_QTD_REV), 0)), 0) * 100 FII_MEASURE4,
           to_number(NULL)   FII_MEASURE5,
           ((nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV), 0)) -
            (nvl(sum(CY_QTOT_EXP), 0) + nvl(sum(CY_QTD_EXP), 0)) -
            (nvl(sum(CY_QTOT_CGS), 0) + nvl(sum(CY_QTD_CGS), 0))) /
           nullif(abs(nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV),0)), 0) * 100  FII_CY_XTD,
           to_number(NULL) FII_PY_XTD,
           ((nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)) -
            (nvl(sum(sum(CY_QTOT_EXP)) over(), 0) + nvl(sum(sum(CY_QTD_EXP)) over(), 0)) -
            (nvl(sum(sum(CY_QTOT_CGS)) over(), 0) + nvl(sum(sum(CY_QTD_CGS)) over(), 0)))
               / nullif(abs(nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)), 0)
               * 100 FII_CY_XTD_GT,
           to_number(NULL) FII_PY_XTD_GT
    from (
      select t.sequence                FII_SEQUENCE,
             decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))   CY_QTOT_REV,
             decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))  CY_QTOT_EXP,
             decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null)) CY_QTOT_CGS,
             TO_NUMBER(NULL)           CY_QTD_REV,
             TO_NUMBER(NULL)           CY_QTD_EXP,
             TO_NUMBER(NULL)           CY_QTD_CGS
      from  fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
            fii_pmv_aggrt_gt gt,
             '||fii_ea_util_pkg.g_page_period_type||'  t
      where f.parent_company_id      = gt.parent_company_id
      and   f.company_id             = gt.company_id
      and   f.parent_cost_center_id  = gt.parent_cc_id
      and   f.cost_center_id         = gt.cc_id
      and   f.top_node_fin_cat_type  IN (''R'', ''OE'', ''CGS'')
      and   f.time_id               = t.'||l_pk||'
      and   f.period_type_id        = :PERIOD_TYPE
      and   t.start_date between :FIVE_YR_BACK
      and   :ENT_PYR_END
      union all
      select t.sequence               FII_SEQUENCE,
             TO_NUMBER(NULL)          CY_QTOT_REV,
             TO_NUMBER(NULL)          CY_QTOT_EXP,
             TO_NUMBER(NULL)          CY_QTOT_CGS,
             decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))   CY_QTD_REV,
             decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))  CY_QTD_EXP,
             decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null)) CY_QTD_CGS
      from fii_gl_trend_sum_mv'|| fii_ea_util_pkg.g_curr_view ||' f,
           '||fii_ea_util_pkg.g_page_period_type||'  t,
           (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
            FROM   fii_time_structures cal,
     	           fii_pmv_aggrt_gt gt
            WHERE  cal.report_date = &BIS_CURRENT_ASOF_DATE
            AND    bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
           ) inner_inline_view,
           fii_time_day          day
      where f.time_id                = inner_inline_view.time_id
      and   f.period_type_id         = inner_inline_view.period_type_id
      and   f.parent_company_id      = inner_inline_view.parent_company_id
      and   f.company_id             = inner_inline_view.company_id
      and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
      and   f.cost_center_id         = inner_inline_view.cc_id
      and   f.top_node_fin_cat_type  IN  (''R'', ''OE'', ''CGS'')
      and   inner_inline_view.report_date         = day.report_date
      and   day.'||l_pk||' = t.'||l_pk||'
    ) g1, '||fii_ea_util_pkg.g_page_period_type||' t
    where FII_SEQUENCE (+)= t.sequence
    and t.start_date >= :PY_SAME_DAY
    and t.end_date   <= :ENT_CYR_END
    group by t.sequence, t.name, t.'||l_pk||'
    order by t.sequence';

ELSIF (fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') and
      (fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL') THEN
  sqlstmt := '
    select t.name VIEWBY,
           t.'||l_pk||' VIEWBYID,
           CY_QTOT         FII_MEASURE2,
           to_number(NULL) FII_MEASURE3,
           CY_QTD          FII_MEASURE4,
           to_number(NULL) FII_MEASURE5,
           FII_CY_XTD      FII_CY_XTD,
           to_number(NULL) FII_PY_XTD,
           FII_CY_XTD_GT   FII_CY_XTD_GT,
           to_number(NULL) FII_PY_XTD_GT
    from
     (select inner_inline_view2.FII_SEQUENCE FII_EFFECTIVE_NUM,
             (nvl(sum(CY_QTOT_REV), 0) - nvl(sum(CY_QTOT_EXP), 0) - nvl(sum(CY_QTOT_CGS), 0)) /
             nullif(abs(nvl(sum(CY_QTOT_REV), 0)), 0) * 100 CY_QTOT,
             (nvl(sum(CY_QTD_REV), 0) - nvl(sum(CY_QTD_EXP), 0) - nvl(sum(CY_QTD_CGS), 0)) /
             nullif(abs(nvl(sum(CY_QTD_REV), 0)), 0) * 100 CY_QTD,
             ((nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV), 0)) -
              (nvl(sum(CY_QTOT_EXP), 0) + nvl(sum(CY_QTD_EXP), 0)) -
              (nvl(sum(CY_QTOT_CGS), 0) + nvl(sum(CY_QTD_CGS), 0))) /
              nullif(abs(nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV), 0)), 0) * 100 FII_CY_XTD,
             ((nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)) -
              (nvl(sum(sum(CY_QTOT_EXP)) over(), 0) + nvl(sum(sum(CY_QTD_EXP)) over(), 0)) -
              (nvl(sum(sum(CY_QTOT_CGS)) over(), 0) + nvl(sum(sum(CY_QTD_CGS)) over(), 0))) /
              nullif(abs(nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)), 0) * 100 FII_CY_XTD_GT
      from
       (select t.'||l_pk||' FII_SEQUENCE,
               sum(case when t.'||l_pk||' <> :CURR_EFFECTIVE_SEQ
                        then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                        else TO_NUMBER(NULL) end)  CY_QTOT_REV,
               sum(case when t.'||l_pk||' <> :CURR_EFFECTIVE_SEQ
                        then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                        else TO_NUMBER(NULL) end)  CY_QTOT_EXP,
               sum(case when t.'||l_pk||' <> :CURR_EFFECTIVE_SEQ
                        then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                        else TO_NUMBER(NULL) end)  CY_QTOT_CGS,
               TO_NUMBER(NULL) CY_QTD_REV,
               TO_NUMBER(NULL) CY_QTD_EXP,
               TO_NUMBER(NULL) CY_QTD_CGS
        from  fii_gl_trend_sum_mv'|| fii_ea_util_pkg.g_curr_view ||' f,
              '||fii_ea_util_pkg.g_page_period_type||'     t,
              fii_pmv_aggrt_gt gt
        where f.parent_company_id      = gt.parent_company_id
        and   f.company_id             = gt.company_id
        and   f.parent_cost_center_id  = gt.parent_cc_id
        and   f.cost_center_id         = gt.cc_id
        and   f.top_node_fin_cat_type  IN (''R'', ''OE'', ''CGS'')
        and   f.time_id               = t.'||l_pk||'
        and   f.period_type_id        = :PERIOD_TYPE
        and   t.start_date between :P_EXP_START
                           and &BIS_CURRENT_ASOF_DATE
        group by t.'||l_pk||'
        union all
        select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
               TO_NUMBER(NULL) CY_QTOT_REV,
               TO_NUMBER(NULL) CY_QTOT_EXP,
               TO_NUMBER(NULL) CY_QTOT_CGS,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_REV,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_EXP,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_CGS
        from fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
              FROM fii_time_structures cal,
                   fii_pmv_aggrt_gt gt
              WHERE cal.report_date in (&BIS_CURRENT_ASOF_DATE,
                                        :P_EXP_ASOF)
              AND   bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
              ) inner_inline_view
            where f.time_id                = inner_inline_view.time_id
            and   f.period_type_id         = inner_inline_view.period_type_id
            and   f.parent_company_id      = inner_inline_view.parent_company_id
            and   f.company_id             = inner_inline_view.company_id
            and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
            and   f.cost_center_id         = inner_inline_view.cc_id
            and   f.top_node_fin_cat_type  IN (''R'', ''OE'', ''CGS'')
            ) inner_inline_view2
            group by inner_inline_view2.FII_SEQUENCE
       ) g1,  '||fii_ea_util_pkg.g_page_period_type||' t
       where g1.fii_effective_num (+)= t.'||l_pk||'
       and   t.start_date <= &BIS_CURRENT_ASOF_DATE
       and   t.start_date >  :P_EXP_START
       order by t.start_date';

ELSE
  sqlstmt := '
    select t.name VIEWBY,
           t.'||l_pk||' VIEWBYID,
           CY_QTOT   FII_MEASURE2,
           PY_QTOT   FII_MEASURE3,
           PY_QTD    FII_MEASURE5,
           PY_QTOT   FII_PY_XTD,
           PY_XTD_GT FII_PY_XTD_GT,
           CY_QTD    FII_MEASURE4,
	   CY_XTD    FII_CY_XTD ,
           CY_XTD_GT FII_CY_XTD_GT
    from
     (select inner_inline_view2.FII_SEQUENCE FII_EFFECTIVE_NUM,
             (nvl(sum(CY_QTOT_REV), 0) - nvl(sum(CY_QTOT_EXP), 0) - nvl(sum(CY_QTOT_CGS), 0)) /
             nullif(abs(nvl(sum(CY_QTOT_REV), 0)), 0) * 100 CY_QTOT,
             (nvl(sum(PY_QTOT_REV), 0) - nvl(sum(PY_QTOT_EXP), 0) - nvl(sum(PY_QTOT_CGS), 0)) /
             nullif(abs(nvl(sum(PY_QTOT_REV), 0)), 0) * 100 PY_QTOT,
             (sum(CY_QTD_REV) - sum(CY_QTD_EXP) - sum(CY_QTD_CGS)) /
             nullif(abs(nvl(sum(CY_QTD_REV), 0)), 0) * 100 CY_QTD,
             (sum(PY_QTD_REV) - sum(PY_QTD_EXP) - sum(PY_QTD_CGS)) /
             nullif(abs(nvl(sum(PY_QTD_REV), 0)), 0) * 100 PY_QTD,
             ((nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV), 0)) -
              (nvl(sum(CY_QTOT_EXP), 0) + nvl(sum(CY_QTD_EXP), 0)) -
              (nvl(sum(CY_QTOT_CGS), 0) + nvl(sum(CY_QTD_CGS), 0))) /
              nullif(abs(nvl(sum(CY_QTOT_REV), 0) + nvl(sum(CY_QTD_REV), 0)), 0) * 100 CY_XTD,
             ((nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)) -
              (nvl(sum(sum(CY_QTOT_EXP)) over(), 0) + nvl(sum(sum(CY_QTD_EXP)) over(), 0)) -
              (nvl(sum(sum(CY_QTOT_CGS)) over(), 0) + nvl(sum(sum(CY_QTD_CGS)) over(), 0))) /
              nullif(abs(nvl(sum(sum(CY_QTOT_REV)) over(), 0) + nvl(sum(sum(CY_QTD_REV)) over(), 0)), 0) * 100 CY_XTD_GT,
             (nvl(sum(sum(PY_QTOT_REV)) over(), 0) - nvl(sum(sum(PY_QTOT_EXP)) over(), 0) - nvl(sum(sum(PY_QTOT_CGS)) over(), 0)) /
             nullif(abs(nvl(sum(sum(PY_QTOT_REV)) over(), 0)), 0) * 100 PY_XTD_GT
      from
       (select t.sequence FII_SEQUENCE,
               case when t.sequence <> :CURR_EFFECTIVE_SEQ
                    then (case when t.start_date between :P_EXP_ASOF
                                                 and :CY_PERIOD_END
                               then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                               else TO_NUMBER(NULL)end)
                    else TO_NUMBER(NULL) end  CY_QTOT_REV,
               case when t.sequence <> :CURR_EFFECTIVE_SEQ
                    then (case when t.start_date between :P_EXP_ASOF
                                                 and :CY_PERIOD_END
                               then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                               else TO_NUMBER(NULL)end)
                    else TO_NUMBER(NULL) end  CY_QTOT_EXP,
               case when t.sequence <> :CURR_EFFECTIVE_SEQ
                    then (case when t.start_date between :P_EXP_ASOF
                                                 and :CY_PERIOD_END
                               then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                               else TO_NUMBER(NULL)end)
                    else TO_NUMBER(NULL) end  CY_QTOT_CGS,
               case when t.start_date between :P_EXP_START
                                      and :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  PY_QTOT_REV,
               case when t.start_date between :P_EXP_START
                                      and :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  PY_QTOT_EXP,
               case when t.start_date between :P_EXP_START
                                      and :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  PY_QTOT_CGS,
               TO_NUMBER(NULL) CY_QTD_REV,
               TO_NUMBER(NULL) CY_QTD_EXP,
               TO_NUMBER(NULL) CY_QTD_CGS,
               TO_NUMBER(NULL) PY_QTD_REV,
               TO_NUMBER(NULL) PY_QTD_EXP,
               TO_NUMBER(NULL) PY_QTD_CGS
        from  fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             '||fii_ea_util_pkg.g_page_period_type||'              t,
             fii_pmv_aggrt_gt gt
        where f.time_id               = t.'||l_pk||'
        and   f.period_type_id        = :PERIOD_TYPE
        and   f.parent_company_id      = gt.parent_company_id
        and   f.company_id             = gt.company_id
        and   f.parent_cost_center_id  = gt.parent_cc_id
        and   f.cost_center_id         = gt.cc_id
        and   f.top_node_fin_cat_type  IN (''R'', ''OE'', ''CGS'')
        and   t.start_date between :P_EXP_START
                           and &BIS_CURRENT_ASOF_DATE
        union all
        select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
               TO_NUMBER(NULL) CY_QTOT_REV,
               TO_NUMBER(NULL) CY_QTOT_EXP,
               TO_NUMBER(NULL) CY_QTOT_CGS,
               TO_NUMBER(NULL) PY_QTOT_REV,
               TO_NUMBER(NULL) PY_QTOT_EXP,
               TO_NUMBER(NULL) PY_QTOT_CGS,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_REV,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_EXP,
               case when inner_inline_view.report_date = &BIS_CURRENT_ASOF_DATE
                    then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end  CY_QTD_CGS,
               case when inner_inline_view.report_date = :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''R'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end PY_QTD_REV,
               case when inner_inline_view.report_date = :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''OE'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end PY_QTD_EXP,
               case when inner_inline_view.report_date = :P_EXP_ASOF
                    then decode(f.top_node_fin_cat_type, ''CGS'', f.actual_g, to_number(null))
                    else TO_NUMBER(NULL) end PY_QTD_CGS
        from fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view ||' f,
             (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
              FROM fii_time_structures cal,
       	           fii_pmv_aggrt_gt gt
              WHERE cal.report_date in (&BIS_CURRENT_ASOF_DATE,
                                        :P_EXP_ASOF)
              AND   bitand(cal.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
              ) inner_inline_view
        where f.time_id                = inner_inline_view.time_id
        and   f.period_type_id         = inner_inline_view.period_type_id
        and   f.parent_company_id      = inner_inline_view.parent_company_id
        and   f.company_id             = inner_inline_view.company_id
        and   f.parent_cost_center_id  = inner_inline_view.parent_cc_id
        and   f.cost_center_id         = inner_inline_view.cc_id
        and   f.top_node_fin_cat_type  IN (''R'', ''OE'', ''CGS'')
      ) inner_inline_view2
         group by inner_inline_view2.FII_SEQUENCE
   ) g1,  '||fii_ea_util_pkg.g_page_period_type||' t
   where g1.fii_effective_num (+)= t.sequence
   and   t.start_date <= &BIS_CURRENT_ASOF_DATE
   and   t.start_date >  :P_EXP_BEGIN
   order by t.start_date';

END IF;

    fii_ea_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl,
                                  expense_sum_sql, expense_sum_output);
END get_margin_sum;

---------------------------------------------------------------------------------
-- Following procedure is used to form PMV SQL, which is used to retrieve data
-- for Gross Margin Table portlet and Gross Margin Summary report

PROCEDURE get_gross_margin( p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL
                           ,p_gross_margin_sql    OUT NOCOPY VARCHAR2
                           ,p_gross_margin_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			  )

IS
   l_sqlstmt			VARCHAR2(32767);
   p_aggrt_viewby_id		VARCHAR2(30);
   p_snap_aggrt_viewby_id	VARCHAR2(30);
   p_nonaggrt_viewby_id		VARCHAR2(50);
   p_aggrt_gt_is_empty		VARCHAR2(1);
   p_non_aggrt_gt_is_empty	VARCHAR2(1);
   l_union_all			VARCHAR2(15);
   l_xtd_column			VARCHAR2(10);   -- At the time of hitting snapshot tables, l_xtd_xolumn is used
   					        -- based on period type chosen i.e if column used to display xtd data
						-- should be actual_curr_mtd/qtd/ytd
   l_roll_column		VARCHAR2(10);
   l_aggrt_sql			VARCHAR2(15000) := NULL;
   l_sqlstmt1			VARCHAR2(15000) := NULL;
   l_snap_sqlstmt1		VARCHAR2(15000) := NULL;
   l_non_aggrt_sql		VARCHAR2(15000) := NULL;
   l_sqlstmt2			VARCHAR2(15000) := NULL;
   l_snap_sqlstmt2		VARCHAR2(15000) := NULL;
   l_trend_sum_mv_sql		VARCHAR2(15000) := NULL;
   l_trend_sum_mv_sql_port	VARCHAR2(15000) := NULL;
   l_viewby_drill_url	        VARCHAR2(300);
   l_snap_prior			VARCHAR2(10000);
   l_trend_mv_prior             VARCHAR2(10000);
   l_agrt_base_prior		VARCHAR2(10000);
   l_if_leaf_flag		VARCHAR2(1);	-- local var to denote, if category or fud1 param chosen to run the report is a leaf or not..
   l_fud2_enabled_flag		VARCHAR2(1);
   l_fud2_where			VARCHAR2(300);
   l_fud2_snap_where		VARCHAR2(300);
   l_fud2_from			VARCHAR2(100);
   l_fud1_decode 		VARCHAR2(300); -- local variable to append decode check for fud1, when viewby chosen is FUD1
   l_budget_decode 		VARCHAR2(300); -- Since we can load budget only against category and fud1 summary nodes,
						-- this local variable appends a check to agrt MV and base map MV queries, so that budget is checked only for xTD period.
						-- Budget loaded for prior xTD should not result in any unwanted record, having 0/NA in all columns..
   l_budget_snap_decode		VARCHAR2(300); -- local variable analogous to l_budget_decode..it appends a similar check to snapshot query
   l_function_name		VARCHAR2(100);

BEGIN

-- Initialization. Calling fii_ea_util_pkg APIs necessary for constructing
-- the PMV sql

   fii_ea_util_pkg.reset_globals;

-- Reassigning following variable to NULL, since it is assigned to OE in reset_globals procedure

   fii_ea_util_pkg.g_fin_cat_type := NULL;

-- Call to get_parameters procedure
   fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

-- Following variable would store the FormFunction name.
-- Based on this, PMV SQL would be constructed for Gross Margin table portlet OR Gross Margin Summary report

   IF (p_page_parameter_tbl.count > 0) THEN
      FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

         IF (p_page_parameter_tbl(i).parameter_name = 'BIS_FXN_NAME') THEN
            l_function_name := p_page_parameter_tbl(i).parameter_value;
         END IF;

      END LOOP;
   END IF;

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

   ELSE
      NULL;

   END CASE;

-- When Compare To is Budget, we display Budget instead of Prior Income
-- l_snap_prior is used when hitting fii_gl_snap_sum_f
-- l_agrt_base_prior is used when hitting fii_gl_agrt_sum_mv OR fii_gl_base_map_mv
-- l_trend_mv_prior is used when hitting fii_gl_trend_sum_mv

   IF (fii_ea_util_pkg.g_time_comp = 'BUDGET') THEN
	l_snap_prior := ',NULL	FII_PL_PRIOR_REVENUE
			 ,NULL  FII_PL_PRIOR_COGS
			 ,NULL  FII_PL_PRIOR_COGS_TOTAL_G
			 ,NULL  FII_PL_PRIOR_REVENUE_TOTAL_G
			 ';
	l_agrt_base_prior :=  l_snap_prior;
	l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

-- When Compare To is Prior Period

   ELSIF fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL' THEN
	l_snap_prior := ',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
				  THEN f.actual_prior_'||l_xtd_column||'
			       ELSE NULL
				END
			    )	FII_PL_PRIOR_REVENUE
			 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
			  	   THEN f.actual_prior_'||l_xtd_column||'
			      ELSE NULL
			       END
			     )	FII_PL_PRIOR_COGS
			 ,NULL	FII_PL_PRIOR_COGS_TOTAL_G
			 ,NULL	FII_PL_PRIOR_REVENUE_TOTAL_G
			 ';
	l_agrt_base_prior := ',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )	FII_PL_PRIOR_REVENUE
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_COGS
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_REVENUE_TOTAL_G
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_COGS_TOTAL_G
			     ';
	l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

-- When Period Type chosen is Year

ELSIF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
	l_snap_prior := ',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
				THEN f.actual_prior_'||l_xtd_column||'
			      ELSE NULL
			      END)	FII_PL_PRIOR_REVENUE
			 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
				THEN f.actual_prior_'||l_xtd_column||'
			      ELSE NULL
			      END)  FII_PL_PRIOR_COGS
			 ,NULL 	FII_PL_PRIOR_COGS_TOTAL_G
			 ,NULL 	FII_PL_PRIOR_REVENUE_TOTAL_G
			 ';
	l_agrt_base_prior := ',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )	FII_PL_PRIOR_REVENUE
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )	FII_PL_PRIOR_COGS
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )	FII_PL_PRIOR_REVENUE_TOTAL_G
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )	FII_PL_PRIOR_COGS_TOTAL_G
				 ';
	l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

ELSE
	l_snap_prior := ',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
				  THEN f.actual_last_year_'||l_xtd_column||'
			       ELSE NULL
				END
			    )		FII_PL_PRIOR_REVENUE
			 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
			  	   THEN f.actual_last_year_'||l_xtd_column||'
			      ELSE NULL
			       END
			     )		FII_PL_PRIOR_COGS
			 ,NULL 	FII_PL_PRIOR_COGS_TOTAL_G
			 ,NULL	FII_PL_PRIOR_REVENUE_TOTAL_G
			   ';
	l_agrt_base_prior := ',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_REVENUE
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_COGS
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				     AND fin_hier.top_node_fin_cat_type = ''R''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_REVENUE_TOTAL_G
			      ,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
				    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
				    AND fin_hier.top_node_fin_cat_type = ''CGS''
				   THEN f.actual_g
				   ELSE NULL
				    END
				   )		FII_PL_PRIOR_COGS_TOTAL_G
			    ';
	l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

END IF;

IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
	l_if_leaf_flag := fii_ea_util_pkg.g_ud1_is_leaf;

-- Following variables are used to check for loading of budgets against summary nodes,
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

-- Checking if User Defined Dimension2 is enabled and forming FROM/WHERE clauses

SELECT	dbi_enabled_flag
  INTO  l_fud2_enabled_flag
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

-- Drill on ViewBy Column
l_viewby_drill_url := 'pFunctionName=FII_PL_GROSS_MARGIN_SUMM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

-- l_sqlstmt1 is the sql to be used, when report_date <> sysdate and fii_pmv_aggrt_gt has been populated

l_sqlstmt1 :=

' /* this query returns data for aggregated nodes */
SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
       '||p_aggrt_viewby_id||'		viewby_id
	,inner_inline_view.viewby	viewby
	,inner_inline_view.sort_order	sort_order
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
	      AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
	      AND fin_hier.top_node_fin_cat_type = ''R''
	     THEN f.actual_g
	      ELSE NULL
	      END
	     )		FII_PL_CURR_REVENUE
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
	        AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
	        AND fin_hier.top_node_fin_cat_type = ''CGS''
	     THEN f.actual_g
	     ELSE NULL
	     END
	    )		FII_PL_CURR_COGS
	'||l_agrt_base_prior||'
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
	      AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
	      AND fin_hier.top_node_fin_cat_type = ''R''
	     THEN f.budget_g
	     ELSE NULL
	      END
	    )		FII_PL_REV_BUDGET
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.budget_g
	     ELSE NULL
	     END
	    )		FII_PL_COGS_BUDGET
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
	       AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
	       AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.forecast_g
	      ELSE NULL
	       END
	     )		FII_PL_REV_FORECAST
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_g
	      ELSE NULL
	       END
	    )		FII_PL_COGS_FORECAST
  FROM	fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
	fii_fin_item_leaf_hiers  fin_hier,
	'||l_fud2_from||'
	(SELECT	/*+ NO_MERGE cardinality(gt 1) */ *
  	   FROM fii_time_structures cal,
		fii_pmv_aggrt_gt gt
	  WHERE	report_date IN ( :ASOF_DATE
				,:PREVIOUS_ASOF_DATE
				,:PRIOR_PERIOD_END
				)
	    AND ( BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
		  BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
		  BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
		)
	 ) inner_inline_view
  WHERE	f.time_id = inner_inline_view.time_id
    AND f.period_type_id = inner_inline_view.period_type_id
    AND f.parent_company_id = inner_inline_view.parent_company_id
    AND f.company_id = inner_inline_view.company_id
    AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
    AND f.cost_center_id = inner_inline_view.cc_id
    '||l_budget_decode||'
    AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
    AND f.fud1_id = inner_inline_view.fud1_id
    '||l_fud2_where||'
    AND fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'')
    AND fin_hier.next_level_fin_cat_id = f.fin_category_id
    AND fin_hier.next_level_fin_cat_id = fin_hier.child_fin_cat_id
GROUP BY '||p_aggrt_viewby_id||',
	inner_inline_view.viewby,
	inner_inline_view.sort_order';

-- l_sqlstmt2 is the sql to be used, when report_date <> sysdate and fii_pmv_non_aggrt_gt has been populated

l_sqlstmt2 :=

' /* this query returns data for non_aggregated nodes */
SELECT	/*+ index(f fii_gl_base_map_mv_n1)  */
	'||p_nonaggrt_viewby_id||' 	viewby_id
	,inner_inline_view.viewby	viewby
	,inner_inline_view.sort_order	sort_order
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
 	    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
	    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )			FII_PL_CURR_REVENUE
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )			FII_PL_CURR_COGS
	 '||l_agrt_base_prior||'
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.budget_g
	      ELSE NULL
	       END
	      )			FII_PL_REV_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.budget_g
	       ELSE NULL
	       END
	       )		FII_PL_COGS_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.forecast_g
	       ELSE NULL
	       END
	       )		FII_PL_REV_FORECAST
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_g
	       ELSE NULL
	       END
	      )			FII_PL_COGS_FORECAST
    FROM fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
	 fii_company_hierarchies co_hier,
	 fii_cost_ctr_hierarchies cc_hier,
	 fii_fin_item_leaf_hiers fin_hier,
	 fii_udd1_hierarchies fud1_hier,
      	 '||l_fud2_from||'
	 ( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
	     FROM fii_time_structures cal,
		  fii_pmv_non_aggrt_gt gt
            WHERE report_date IN ( :ASOF_DATE
				  ,:PREVIOUS_ASOF_DATE
				  ,:PRIOR_PERIOD_END
				 )
	      AND ( BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
	  	    BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
	 	    BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
		  )
	  ) inner_inline_view
  WHERE f.period_type_id = inner_inline_view.period_type_id
    AND f.time_id = inner_inline_view.time_id
    AND co_hier.parent_company_id = inner_inline_view.company_id
    AND co_hier.child_company_id = f.company_id
    AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
    AND cc_hier.child_cc_id = f.cost_center_id
	'||l_budget_decode||'
    AND fin_hier.child_fin_cat_id = f.fin_category_id
    AND fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'')
    AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
	'||l_fud1_decode||'
    AND fud1_hier.child_value_id = f.fud1_id
	'||l_fud2_where||'
GROUP BY '||p_nonaggrt_viewby_id||',
	 inner_inline_view.viewby,
	 inner_inline_view.sort_order';

l_snap_sqlstmt1 := ' -- Hitting fii_gl_snap_sum_f

SELECT   viewby_id
        ,viewby
	,sort_order
	,SUM(FII_PL_CURR_REVENUE) FII_PL_CURR_REVENUE
	,SUM(FII_PL_CURR_COGS)	FII_PL_CURR_COGS
	,SUM(FII_PL_PRIOR_REVENUE) FII_PL_PRIOR_REVENUE
	,SUM(FII_PL_PRIOR_COGS) FII_PL_PRIOR_COGS
	,SUM(FII_PL_REV_BUDGET) FII_PL_REV_BUDGET
	,SUM(FII_PL_COGS_BUDGET) FII_PL_COGS_BUDGET
	,SUM(FII_PL_REV_FORECAST) FII_PL_REV_FORECAST
	,SUM(FII_PL_COGS_FORECAST)  FII_PL_COGS_FORECAST
	,SUM(FII_PL_PRIOR_COGS_TOTAL_G)	FII_PL_PRIOR_COGS_TOTAL_G
	,SUM(FII_PL_PRIOR_REVENUE_TOTAL_G) FII_PL_PRIOR_REVENUE_TOTAL_G
  FROM
(SELECT	/*+ index(f fii_gl_snap_sum_f_n1) */
	'||p_snap_aggrt_viewby_id||'  viewby_id
	,gt.viewby	viewby
	,gt.sort_order	sort_order
	,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.actual_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_CURR_REVENUE
	 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.actual_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_CURR_COGS
	    '||l_snap_prior||'
	  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.budget_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_REV_BUDGET
	  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.budget_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_COGS_BUDGET
	  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.forecast_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_REV_FORECAST
	  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_cur_'||l_xtd_column||'
	    ELSE NULL
	     END
	    )		FII_PL_COGS_FORECAST
FROM fii_gl_snap_sum_f'||fii_ea_util_pkg.g_curr_view||' f,
     fii_fin_item_leaf_hiers  fin_hier,
     '||l_fud2_from||'
     fii_pmv_aggrt_gt gt
WHERE f.parent_company_id = gt.parent_company_id
and f.fin_category_id = fin_hier.child_fin_cat_id
and fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'')
and f.company_id = gt.company_id
and f.parent_cost_center_id = gt.parent_cc_id
and f.cost_center_id =gt.cc_id
'||l_budget_snap_decode||'
and f.parent_fud1_id = gt.parent_fud1_id
and f.fud1_id =gt.fud1_id
'||l_fud2_snap_where||'
GROUP BY '||p_snap_aggrt_viewby_id||', gt.viewby, gt.sort_order

		UNION ALL
/* Following Query calculates PRIOR TOTAL INCOME */
SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
	'||p_aggrt_viewby_id||'		viewby_id
	,inner_inline_view.viewby	viewby
	,inner_inline_view.sort_order	sort_order
	,NULL	FII_PL_CURR_REVENUE
	,NULL	FII_PL_CURR_COGS
	,NULL	FII_PL_PRIOR_REVENUE
	,NULL	FII_PL_PRIOR_COGS
	,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
		THEN f.actual_g
	     ELSE NULL
	     END
	     )	FII_PL_PRIOR_COGS_TOTAL_G
	,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
		THEN f.actual_g
	     ELSE NULL
	     END
	     )	FII_PL_PRIOR_REVENUE_TOTAL_G
	,NULL	FII_PL_REV_BUDGET
	,NULL 	FII_PL_COGS_BUDGET
	,NULL 	FII_PL_REV_FORECAST
	,NULL 	FII_PL_COGS_FORECAST
FROM fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
     fii_fin_item_leaf_hiers  fin_hier,
     '||l_fud2_from||'
     ( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
	  FROM 	fii_time_structures cal,
		fii_pmv_aggrt_gt gt
	  WHERE report_date = :PRIOR_PERIOD_END
	    AND BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
	) inner_inline_view
WHERE f.time_id = inner_inline_view.time_id
AND f.period_type_id = inner_inline_view.period_type_id
AND f.parent_company_id = inner_inline_view.parent_company_id
AND f.company_id = inner_inline_view.company_id
AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
AND f.cost_center_id = inner_inline_view.cc_id
'||l_budget_decode||'
AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
AND f.fud1_id = inner_inline_view.fud1_id
'||l_fud2_where||'
AND fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'')
AND fin_hier.next_level_fin_cat_id = f.fin_category_id
AND fin_hier.next_level_fin_cat_id = fin_hier.child_fin_cat_id
GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order
) GROUP BY  viewby_id, viewby, sort_order';

l_snap_sqlstmt2 :=

' SELECT /*+ index(f fii_gl_base_map_mv_n1) */
	 '||p_nonaggrt_viewby_id||' 	viewby_id
	,inner_inline_view.viewby	viewby
	,inner_inline_view.sort_order	sort_order
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )		FII_PL_CURR_REVENUE
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )		FII_PL_CURR_COGS
	  '||l_agrt_base_prior||'
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.budget_g
	    ELSE NULL
	     END
	    )		FII_PL_REV_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.budget_g
	    ELSE NULL
	     END
	    )		FII_PL_COGS_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''R''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )		FII_PL_REV_FORECAST
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND fin_hier.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )		FII_PL_COGS_FORECAST
FROM	fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
	fii_company_hierarchies co_hier,
	fii_cost_ctr_hierarchies cc_hier,
	fii_fin_item_leaf_hiers fin_hier,
	fii_udd1_hierarchies fud1_hier,
	'||l_fud2_from||'
	( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
	  FROM 	fii_time_structures cal,
		fii_pmv_non_aggrt_gt gt
	  WHERE	report_date IN ( :ASOF_DATE
				,:PREVIOUS_ASOF_DATE
				,:PRIOR_PERIOD_END
				)
	    AND ( BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
		  BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
		  BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND
		)
	) inner_inline_view
WHERE f.period_type_id = inner_inline_view.period_type_id
and f.time_id = inner_inline_view.time_id
and co_hier.parent_company_id = inner_inline_view.company_id
and co_hier.child_company_id = f.company_id
and cc_hier.parent_cc_id = inner_inline_view.cost_center_id
and cc_hier.child_cc_id = f.cost_center_id
and fin_hier.child_fin_cat_id = f.fin_category_id
and fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'')
and fud1_hier.parent_value_id = inner_inline_view.fud1_id
'||l_fud1_decode||'
'||l_budget_decode||'
and fud1_hier.child_value_id = f.fud1_id
'||l_fud2_where||'
GROUP BY 	'||p_nonaggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- When fii_gl_trend_sum_mv is hit

l_trend_sum_mv_sql :='
			SELECT   '||p_aggrt_viewby_id||'	viewby_id
		       		,inner_inline_view.viewby	viewby
				,inner_inline_view.sort_order	sort_order
				,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					    AND f.top_node_fin_cat_type = ''R''
					 THEN f.actual_g
				    ELSE NULL
				     END
				    )				FII_PL_CURR_REVENUE
				 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					     AND f.top_node_fin_cat_type = ''CGS''
					 THEN f.actual_g
				    ELSE NULL
				     END
				    )				FII_PL_CURR_COGS
				 '||l_trend_mv_prior||'
				  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					    AND f.top_node_fin_cat_type = ''R''
					 THEN f.budget_g
				    ELSE NULL
				     END
				    )				FII_PL_REV_BUDGET
				  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
					    AND f.top_node_fin_cat_type = ''CGS''
					 THEN f.budget_g
				    ELSE NULL
				     END
				    )				FII_PL_COGS_BUDGET
			 	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					    AND f.top_node_fin_cat_type = ''R''
					 THEN f.forecast_g
				    ELSE NULL
				     END
				    )				FII_PL_REV_FORECAST
				  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					    AND f.top_node_fin_cat_type = ''CGS''
					 THEN f.forecast_g
				    ELSE NULL
				     END
				    )				FII_PL_COGS_FORECAST
			  FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
				( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
				  FROM 		fii_time_structures cal,
 						fii_pmv_aggrt_gt gt
				   WHERE	report_date IN ( :ASOF_DATE
								,:PREVIOUS_ASOF_DATE
								,:PRIOR_PERIOD_END
								)
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
				AND f.top_node_fin_cat_type IN (''R'',''CGS'')
				'||l_budget_decode||'

			GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- SQL for Gross Margin table portlet
-- Here, we don't calculate any PRIOR columns
-- Even, Budget is not calculated

l_trend_sum_mv_sql_port :='
			SELECT  '||p_aggrt_viewby_id||'		viewby_id
		       		,inner_inline_view.viewby	viewby
				,inner_inline_view.sort_order	sort_order
				,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					    AND f.top_node_fin_cat_type = ''R''
					 THEN f.actual_g
				    ELSE NULL
				     END
				    )				FII_PL_CURR_REVENUE
				 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
					     AND f.top_node_fin_cat_type = ''CGS''
					 THEN f.actual_g
				    ELSE NULL
				     END
				    )				FII_PL_CURR_COGS
				 ,NULL				FII_PL_PRIOR_REVENUE
				 ,NULL				FII_PL_PRIOR_COGS
				 ,NULL				FII_PL_REV_BUDGET
				 ,NULL				FII_PL_COGS_BUDGET
				 ,NULL				FII_PL_PRIOR_REVENUE_TOTAL_G
				 ,NULL				FII_PL_PRIOR_COGS_TOTAL_G
			 	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					    AND f.top_node_fin_cat_type = ''R''
					 THEN f.forecast_g
				    ELSE NULL
				     END
				    )				FII_PL_REV_FORECAST
				 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
					    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
					    AND f.top_node_fin_cat_type = ''CGS''
					 THEN f.forecast_g
				    ELSE NULL
				     END
				    )				FII_PL_COGS_FORECAST
			  FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
				( SELECT 	/*+ NO_MERGE cardinality(gt 1) */ *
				  FROM 		fii_time_structures cal,
 						fii_pmv_aggrt_gt gt
				   WHERE	report_date IN ( :ASOF_DATE
								,:PREVIOUS_ASOF_DATE
								,:PRIOR_PERIOD_END
								)
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
				AND f.top_node_fin_cat_type IN (''R'',''CGS'')
				'||l_budget_decode||'

			GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- Deciding upon SQL, based on FF name
 IF l_function_name = 'FII_PL_GROSS_MARGIN_TABLE' THEN
    l_trend_sum_mv_sql := l_trend_sum_mv_sql_port;
 END IF;

-- Checking conditions to decide upon the SQL variable

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

l_sqlstmt :=

'SELECT
   DECODE(:G_ID, inline_view.viewby_id,DECODE('''||l_if_leaf_flag||''',''Y'',inline_view.viewby
 	,inline_view.viewby||'' ''||:DIR_MSG), inline_view.viewby)
	VIEWBY
  ,inline_view.viewby_id		VIEWBYID
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
   THEN NULL
   ELSE
   (NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0))*100
   /NULLIF(ABS(FII_PL_CURR_REVENUE),0)
   END		FII_PL_GROSS_MARGIN_PERCENT
  ,CASE WHEN FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE
   (NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0))*100
  /NULLIF(ABS(FII_PL_PRIOR_REVENUE),0)
   END		FII_PL_PRIOR_GROSS_MGN_PCNT
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
     AND FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE
  (NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0))*100
	/NULLIF(ABS(FII_PL_CURR_REVENUE),0) -
  (NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0))*100
	/NULLIF(ABS(FII_PL_PRIOR_REVENUE),0)
   END		FII_PL_GROSS_MGN_CHANGE
  ,CASE WHEN FII_PL_PRIOR_REVENUE_TOTAL_G IS NULL AND FII_PL_PRIOR_COGS_TOTAL_G IS NULL
   THEN NULL
   ELSE
   NVL(FII_PL_PRIOR_REVENUE_TOTAL_G,0) - NVL(FII_PL_PRIOR_COGS_TOTAL_G,0)
   END		FII_PL_PRIOR_GROSS_INC_TOTAL
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
   THEN NULL
   ELSE NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0)
   END		FII_PL_GROSS_INCOME_XTD
  ,NULL		FII_PL_GROSS_INCOME_TOTAL
  ,CASE WHEN FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0)
   END		FII_PL_PRIOR_GROSS_INCOME_XTD
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
        AND FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE
   ((NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0)) -
  (NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0))) *100
  /NULLIF(ABS((NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0))),0)
   END		FII_PL_GROSS_INCOME_CHANGE
  ,CASE WHEN FII_PL_REV_BUDGET IS NULL AND FII_PL_COGS_BUDGET IS NULL
     THEN NULL
   ELSE
   NVL(FII_PL_REV_BUDGET,0) - NVL(FII_PL_COGS_BUDGET,0)
   END		FII_PL_BUDGET
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
    THEN NULL
   ELSE (NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0))*100
  /NULLIF(ABS(NVL(FII_PL_REV_BUDGET,0) - NVL(FII_PL_COGS_BUDGET,0)),0)
   END		FII_PL_PCNT_BUDGET
  ,CASE WHEN FII_PL_REV_FORECAST IS NULL AND FII_PL_COGS_FORECAST IS NULL
    THEN NULL
   ELSE NVL(FII_PL_REV_FORECAST,0) - NVL(FII_PL_COGS_FORECAST,0)
   END		FII_PL_FORECAST
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
   THEN NULL
   ELSE (NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0))*100
   /NULLIF(ABS(NVL(FII_PL_REV_FORECAST,0) - NVL(FII_PL_COGS_FORECAST,0)),0)
   END		FII_PL_PCNT_FORECAST
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
    THEN NULL
   ELSE (SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER())*100
  /NULLIF(ABS(SUM(FII_PL_CURR_REVENUE) OVER ()),0)
   END		FII_PL_GT_GROSS_MARGIN_PERCENT
  ,CASE WHEN FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
    THEN NULL
   ELSE (SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER())*100
   /NULLIF(ABS(SUM(FII_PL_PRIOR_REVENUE) OVER ()),0)
   END		FII_PL_GT_PRIOR_GROSS_MGN_PCNT
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
      AND FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE (SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER())*100
  /NULLIF(ABS(SUM(FII_PL_CURR_REVENUE) OVER ()),0) -
    (SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER())*100
  /NULLIF(ABS(SUM(FII_PL_PRIOR_REVENUE) OVER ()),0)
   END		FII_PL_GT_GROSS_MGN_CHANGE
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
      AND FII_PL_PRIOR_REVENUE IS NULL AND FII_PL_PRIOR_COGS IS NULL
   THEN NULL
   ELSE ((SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER ()) -
  (SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER ()- SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER ()))*100
  /NULLIF(ABS((SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER () )),0)
   END		FII_PL_GT_GROSS_INCOME_CHANGE
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
     THEN NULL
   ELSE (SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER ())*100
  /NULLIF(ABS(SUM(NVL(FII_PL_REV_BUDGET,0)) OVER () - SUM(NVL(FII_PL_COGS_BUDGET,0)) OVER ()),0)
   END		FII_PL_GT_PCNT_BUDGET
  ,CASE WHEN FII_PL_CURR_REVENUE IS NULL AND FII_PL_CURR_COGS IS NULL
     THEN NULL
   ELSE (SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER ())*100
  /NULLIF(ABS(SUM(NVL(FII_PL_REV_FORECAST,0)) OVER () - SUM(NVL(FII_PL_COGS_FORECAST,0)) OVER ()),0)
   END		FII_PL_GT_PCNT_FORECAST
  ,DECODE((SELECT is_leaf_flag
  	     FROM fii_company_hierarchies
	    WHERE parent_company_id = inline_view.viewby_id
	     AND child_company_id = inline_view.viewby_id),
	   ''Y'',
	   '''',
	   '''||l_viewby_drill_url||''')	FII_PL_COMP_DRILL
,DECODE((SELECT is_leaf_flag
          FROM fii_cost_ctr_hierarchies
	 WHERE parent_cc_id = inline_view.viewby_id
	   AND child_cc_id = inline_view.viewby_id),
	''Y'',
	'''',
	'''||l_viewby_drill_url||''')	FII_PL_CC_DRILL
,DECODE((SELECT  is_leaf_flag
	   FROM  fii_udd1_hierarchies
	  WHERE	parent_value_id = inline_view.viewby_id
	    AND child_value_id = inline_view.viewby_id),
	  ''Y'',
	   '''',
	 DECODE(:G_ID, inline_view.viewby_id,'''',
	'''||l_viewby_drill_url||'''))	FII_PL_UDD1_DRILL
,DECODE((SELECT  is_leaf_flag
	   FROM  fii_udd2_hierarchies
	  WHERE	parent_value_id = inline_view.viewby_id
	    AND child_value_id = inline_view.viewby_id),
	   ''Y'',
	   '''',
	   '''||l_viewby_drill_url||''') FII_PL_UDD2_DRILL
FROM ( '||l_aggrt_sql||'
    '||l_union_all||'
   '||l_non_aggrt_sql||'
   ) inline_view
 ORDER BY NVL(inline_view.sort_order,999999) ASC, NVL(FII_PL_GROSS_MARGIN_PERCENT,-999999999) DESC';

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_gross_margin_sql,
                              p_bind_output_table => p_gross_margin_output);

END get_gross_margin;

---------------------------------------------------------------------------------
-- Following procedure is used to form PMV SQL, which is used to retrieve data
-- for Operating Margin Table portlet and Operating Margin Summary report

PROCEDURE get_oper_margin( p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL
                           ,p_oper_margin_sql    OUT NOCOPY VARCHAR2
                           ,p_oper_margin_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			  )

IS
   l_sqlstmt			VARCHAR2(30000);
   p_aggrt_viewby_id		VARCHAR2(30);
   p_snap_aggrt_viewby_id	VARCHAR2(30);
   p_nonaggrt_viewby_id		VARCHAR2(50);
   p_aggrt_gt_is_empty		VARCHAR2(1);
   p_non_aggrt_gt_is_empty	VARCHAR2(1);
   l_union_all			VARCHAR2(10);
   l_xtd_column			VARCHAR2(10);   -- At the time of hitting snapshot tables, l_xtd_xolumn is used
   					        -- based on period type chosen i.e if column used to display xtd data
						-- should be actual_curr_mtd/qtd/ytd
   l_roll_column		VARCHAR2(10);
   l_aggrt_sql			VARCHAR2(20000) := NULL;
   l_sqlstmt1			VARCHAR2(20000) := NULL;
   l_snap_sqlstmt1		VARCHAR2(20000) := NULL;
   l_non_aggrt_sql		VARCHAR2(20000) := NULL;
   l_sqlstmt2			VARCHAR2(20000) := NULL;
   l_snap_sqlstmt2		VARCHAR2(20000) := NULL;
   l_trend_sum_mv_sql		VARCHAR2(15000) := NULL;
   l_trend_sum_mv_sql_port	VARCHAR2(15000) := NULL;
   l_viewby_drill_url	        VARCHAR2(300);
   l_snap_prior			VARCHAR2(10000);
   l_trend_mv_prior             VARCHAR2(10000);
   l_agrt_base_prior		VARCHAR2(10000);
   l_if_leaf_flag		VARCHAR2(1);	-- local var to denote, if category or fud1 param chosen to run the report is a leaf or not..
   l_fud2_enabled_flag		VARCHAR2(1);
   l_fud2_where			VARCHAR2(300);
   l_fud2_snap_where		VARCHAR2(300);
   l_fud2_from			VARCHAR2(100);
   l_fud1_decode 		VARCHAR2(300); -- local variable to append decode check for fud1, when viewby chosen is FUD1
   l_budget_decode 		VARCHAR2(300); -- Since we can load budget only against category and fud1 summary nodes,
						-- this local variable appends a check to agrt MV and base map MV queries, so that budget is checked only for xTD period.
						-- Budget loaded for prior xTD should not result in any unwanted record, having 0/NA in all columns..
   l_budget_snap_decode		VARCHAR2(300); -- local variable analogous to l_budget_decode..it appends a similar check to snapshot query
   l_function_name		VARCHAR2(100);

BEGIN

-- Initialization. Calling fii_ea_util_pkg APIs necessary for constructing
-- the PMV sql

   fii_ea_util_pkg.reset_globals;

-- Reassigning following variable to NULL, since it is assigned to OE in reset_globals procedure

   fii_ea_util_pkg.g_fin_cat_type := NULL;

-- Call to get_parameters procedure
   fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

-- Following variable would store the FormFunction name.
-- Based on this, PMV SQL would be constructed for Operating Margin table portlet OR Operating Margin Summary report

   IF (p_page_parameter_tbl.count > 0) THEN
      FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

         IF (p_page_parameter_tbl(i).parameter_name = 'BIS_FXN_NAME') THEN
            l_function_name := p_page_parameter_tbl(i).parameter_value;
         END IF;

      END LOOP;
   END IF;

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

   ELSE
      NULL;

   END CASE;

-- When Compare To is Budget, we display Budget instead of Prior Income
-- l_snap_prior is used when hitting fii_gl_snap_sum_f
-- l_agrt_base_prior is used when hitting fii_gl_agrt_sum_mv & fii_gl_base_map_mv
-- l_trend_mv_prior is used when hitting fii_gl_trend_sum_mv

IF (fii_ea_util_pkg.g_time_comp = 'BUDGET') THEN
   l_snap_prior :=
	',NULL	FII_PL_PRIOR_REVENUE
	 ,NULL  FII_PL_PRIOR_COGS
	 ,NULL  FII_PL_PRIOR_EXP
	 ,NULL  FII_PL_PRIOR_COGS_TOTAL_G
	 ,NULL  FII_PL_PRIOR_REVENUE_TOTAL_G
	 ,NULL  FII_PL_PRIOR_EXP_TOTAL_G
	 ';
   l_agrt_base_prior := l_snap_prior;
   l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

-- When Compare To is Prior Period

ELSIF fii_ea_util_pkg.g_time_comp = 'SEQUENTIAL' THEN
   l_snap_prior :=

',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
     THEN f.actual_prior_'||l_xtd_column||'
     ELSE NULL
     END
    )	FII_PL_PRIOR_REVENUE
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
     THEN f.actual_prior_'||l_xtd_column||'
     ELSE NULL
     END
    )	FII_PL_PRIOR_COGS
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_prior_'||l_xtd_column||'
    ELSE NULL
    END
    )	FII_PL_PRIOR_EXP
,NULL	FII_PL_PRIOR_COGS_TOTAL_G
,NULL	FII_PL_PRIOR_REVENUE_TOTAL_G
,NULL	FII_PL_PRIOR_EXP_TOTAL_G
';

l_agrt_base_prior :=

',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
     AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g  ELSE NULL END)	FII_PL_PRIOR_REVENUE
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
   THEN f.actual_g ELSE NULL END) FII_PL_PRIOR_COGS
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g ELSE NULL END) FII_PL_PRIOR_EXP
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
     AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g ELSE NULL END)	FII_PL_PRIOR_REVENUE_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
   THEN f.actual_g ELSE NULL END) FII_PL_PRIOR_COGS_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_EXP_TOTAL_G
 ';

l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

-- When Period Type chosen is Year

ELSIF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
l_snap_prior :=

',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
	  THEN f.actual_prior_'||l_xtd_column||'
       ELSE NULL
	END
    )	FII_PL_PRIOR_REVENUE
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
	   THEN f.actual_prior_'||l_xtd_column||'
      ELSE NULL
       END
     )	FII_PL_PRIOR_COGS
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
	   THEN f.actual_prior_'||l_xtd_column||'
      ELSE NULL
       END
     )	FII_PL_PRIOR_EXP
 ,NULL	FII_PL_PRIOR_COGS_TOTAL_G
 ,NULL	FII_PL_PRIOR_REVENUE_TOTAL_G
 ,NULL	FII_PL_PRIOR_EXP_TOTAL_G
 ';

l_agrt_base_prior :=

',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
     AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g  ELSE NULL END)	FII_PL_PRIOR_REVENUE
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_COGS
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_EXP
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_REVENUE_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
    AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.actual_g  ELSE NULL END)  FII_PL_PRIOR_COGS_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_EXP_TOTAL_G
';
l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

ELSE

l_snap_prior :=

',SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
	  THEN f.actual_last_year_'||l_xtd_column||'
       ELSE NULL
	END
    )	FII_PL_PRIOR_REVENUE
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
	   THEN f.actual_last_year_'||l_xtd_column||'
      ELSE NULL
       END
     )	FII_PL_PRIOR_COGS
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
	   THEN f.actual_last_year_'||l_xtd_column||'
      ELSE NULL
       END
     )	FII_PL_PRIOR_EXP
 ,NULL 	FII_PL_PRIOR_COGS_TOTAL_G
 ,NULL	FII_PL_PRIOR_REVENUE_TOTAL_G
 ,NULL  FII_PL_PRIOR_EXP_TOTAL_G
   ';
l_agrt_base_prior :=

',SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
   THEN f.actual_g ELSE NULL END)   FII_PL_PRIOR_REVENUE
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
   THEN f.actual_g  ELSE NULL END)  FII_PL_PRIOR_COGS
,SUM(CASE WHEN inner_inline_view.report_date = :PREVIOUS_ASOF_DATE
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g  ELSE NULL END)  FII_PL_PRIOR_EXP
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
   THEN f.actual_g ELSE NULL END)  FII_PL_PRIOR_REVENUE_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
   THEN f.actual_g  ELSE NULL END)  FII_PL_PRIOR_COGS_TOTAL_G
,SUM(CASE WHEN inner_inline_view.report_date = :PRIOR_PERIOD_END
    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
   THEN f.actual_g  ELSE NULL END)  FII_PL_PRIOR_EXP_TOTAL_G
 ';

l_trend_mv_prior  := REPLACE(l_agrt_base_prior,'fin_hier','f');

END IF;

IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

	fii_ea_util_pkg.check_if_leaf(fii_ea_util_pkg.g_udd1_id);
	l_if_leaf_flag := fii_ea_util_pkg.g_ud1_is_leaf;

-- Following variables are used to check for loading of budgets against summary nodes,
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

-- Checking if User Defined Dimension2 is enabled and forming FROM/WHERE clauses

SELECT	dbi_enabled_flag
  INTO  l_fud2_enabled_flag
  FROM	fii_financial_dimensions
 WHERE	dimension_short_name = 'FII_USER_DEFINED_2';

IF l_fud2_enabled_flag = 'Y' THEN

   IF fii_ea_util_pkg.g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN

	l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

	l_fud2_snap_where := ' AND fud2_hier.parent_value_id = gt.fud2_id AND fud2_hier.child_value_id = f.fud2_id ';

	l_fud2_where := ' AND fud2_hier.parent_value_id = inner_inline_view.fud2_id AND fud2_hier.child_value_id = f.fud2_id ';

  ELSIF fii_ea_util_pkg.g_fud2_id <> 'All' THEN

	l_fud2_from := ' fii_udd2_hierarchies fud2_hier, ';

	l_fud2_snap_where := ' AND fud2_hier.parent_value_id = gt.fud2_id AND fud2_hier.child_value_id = f.fud2_id ';

	l_fud2_where := ' AND fud2_hier.parent_value_id = inner_inline_view.fud2_id AND fud2_hier.child_value_id = f.fud2_id ';
  END IF;

END IF;

-- Drill on ViewBy Column
l_viewby_drill_url := 'pFunctionName=FII_PL_OPER_MARGIN_SUMM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

-- l_sqlstmt1 is the sql to be used, when report_date <> sysdate and fii_pmv_aggrt_gt has been populated

l_sqlstmt1 :=

' -- Aggrt nodes
SELECT	/*+ index(f fii_gl_agrt_sum_mv_n1) */
'||p_aggrt_viewby_id||'	    viewby_id
,inner_inline_view.viewby   viewby
,inner_inline_view.sort_order	sort_order
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
      AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_REVENUE
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
      AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_COGS
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
      AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_EXP
'||l_agrt_base_prior||'
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
      AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.budget_g  ELSE NULL END)  FII_PL_REV_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
      AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.budget_g  ELSE NULL END)  FII_PL_COGS_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
      AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.budget_g  ELSE NULL END)  FII_PL_EXP_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
      AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.forecast_g  ELSE NULL END)  FII_PL_REV_FORECAST
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
      AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.forecast_g  ELSE NULL END)  FII_PL_COGS_FORECAST
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
      AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.forecast_g  ELSE NULL END)  FII_PL_EXP_FORECAST
FROM fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
     fii_fin_item_leaf_hiers  fin_hier,
     '||l_fud2_from||'
(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
   FROM fii_time_structures cal,
        fii_pmv_aggrt_gt gt
  WHERE report_date IN ( :ASOF_DATE,:PREVIOUS_ASOF_DATE,:PRIOR_PERIOD_END)
    AND (BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
         BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND)) inner_inline_view
WHERE f.time_id = inner_inline_view.time_id
AND f.period_type_id = inner_inline_view.period_type_id
AND f.parent_company_id = inner_inline_view.parent_company_id
AND f.company_id = inner_inline_view.company_id
AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
AND f.cost_center_id = inner_inline_view.cc_id
'||l_budget_decode||'
AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
AND f.fud1_id = inner_inline_view.fud1_id
'||l_fud2_where||'
AND fin_hier.next_level_fin_cat_id = f.fin_category_id
AND fin_hier.next_level_fin_cat_id = fin_hier.child_fin_cat_id
GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- l_sqlstmt2 is the sql to be used, when report_date <> sysdate and fii_pmv_non_aggrt_gt has been populated

l_sqlstmt2 :=

' -- NonAggrt nodes
SELECT	/*+ index(f fii_gl_base_map_mv_n1) */
'||p_nonaggrt_viewby_id||' viewby_id
,inner_inline_view.viewby  viewby
,inner_inline_view.sort_order	sort_order
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
     THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_REVENUE
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
     THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_COGS
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
     THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_EXP
  '||l_agrt_base_prior||'
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
     THEN f.budget_g  ELSE NULL END)  FII_PL_REV_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
     THEN f.budget_g  ELSE NULL END)  FII_PL_COGS_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
     THEN f.budget_g  ELSE NULL END)  FII_PL_EXP_BUDGET
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND AND fin_hier.top_node_fin_cat_type = ''R''
     THEN f.forecast_g  ELSE NULL END) FII_PL_REV_FORECAST
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
     THEN f.forecast_g  ELSE NULL END) FII_PL_COGS_FORECAST
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
      AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND AND fin_hier.top_node_fin_cat_type = ''OE''
     THEN f.forecast_g  ELSE NULL END) FII_PL_EXP_FORECAST
FROM fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
     fii_company_hierarchies co_hier,
     fii_cost_ctr_hierarchies cc_hier,
     fii_fin_item_leaf_hiers fin_hier,
     fii_udd1_hierarchies fud1_hier,
     '||l_fud2_from||'
(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
   FROM fii_time_structures cal,
	fii_pmv_non_aggrt_gt gt
  WHERE report_date IN ( :ASOF_DATE,:PREVIOUS_ASOF_DATE,:PRIOR_PERIOD_END)
    AND (BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
	 BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND)) inner_inline_view
WHERE f.period_type_id = inner_inline_view.period_type_id
AND f.time_id = inner_inline_view.time_id
AND co_hier.parent_company_id = inner_inline_view.company_id
AND co_hier.child_company_id = f.company_id
AND cc_hier.parent_cc_id = inner_inline_view.cost_center_id
AND cc_hier.child_cc_id = f.cost_center_id
'||l_budget_decode||'
AND fin_hier.child_fin_cat_id = f.fin_category_id
AND fud1_hier.parent_value_id = inner_inline_view.fud1_id
'||l_fud1_decode||'
AND fud1_hier.child_value_id = f.fud1_id
'||l_fud2_where||'
GROUP BY '||p_nonaggrt_viewby_id||',inner_inline_view.viewby,inner_inline_view.sort_order';

l_snap_sqlstmt1 :=

'SELECT viewby_id
        ,viewby
	,sort_order
	,SUM(FII_PL_CURR_REVENUE) FII_PL_CURR_REVENUE
	,SUM(FII_PL_CURR_COGS)	FII_PL_CURR_COGS
	,SUM(FII_PL_CURR_EXP)	FII_PL_CURR_EXP
	,SUM(FII_PL_PRIOR_REVENUE) FII_PL_PRIOR_REVENUE
	,SUM(FII_PL_PRIOR_COGS) FII_PL_PRIOR_COGS
	,SUM(FII_PL_PRIOR_EXP) FII_PL_PRIOR_EXP
	,SUM(FII_PL_REV_BUDGET) FII_PL_REV_BUDGET
	,SUM(FII_PL_COGS_BUDGET) FII_PL_COGS_BUDGET
	,SUM(FII_PL_EXP_BUDGET) FII_PL_EXP_BUDGET
	,SUM(FII_PL_REV_FORECAST) FII_PL_REV_FORECAST
	,SUM(FII_PL_COGS_FORECAST)  FII_PL_COGS_FORECAST
	,SUM(FII_PL_EXP_FORECAST)  FII_PL_EXP_FORECAST
	,SUM(FII_PL_PRIOR_COGS_TOTAL_G)	FII_PL_PRIOR_COGS_TOTAL_G
	,SUM(FII_PL_PRIOR_REVENUE_TOTAL_G) FII_PL_PRIOR_REVENUE_TOTAL_G
	,SUM(FII_PL_PRIOR_EXP_TOTAL_G) FII_PL_PRIOR_EXP_TOTAL_G
 FROM
(SELECT	/*+ index(f fii_gl_snap_sum_f_n1) */
'||p_snap_aggrt_viewby_id||'	viewby_id
,gt.viewby	viewby
,gt.sort_order	sort_order
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
	 THEN f.actual_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_CURR_REVENUE
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
	 THEN f.actual_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_CURR_COGS
 ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
	 THEN f.actual_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_CURR_EXP
    '||l_snap_prior||'
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
	 THEN f.budget_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_REV_BUDGET
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
	 THEN f.budget_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_COGS_BUDGET
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
	 THEN f.budget_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_EXP_BUDGET
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R''
	 THEN f.forecast_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_REV_FORECAST
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS''
	 THEN f.forecast_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_COGS_FORECAST
  ,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE''
	 THEN f.forecast_cur_'||l_xtd_column||'
    ELSE NULL END)  FII_PL_EXP_FORECAST
FROM fii_gl_snap_sum_f'||fii_ea_util_pkg.g_curr_view||' f,
     fii_fin_item_leaf_hiers  fin_hier,
     '||l_fud2_from||'
     fii_pmv_aggrt_gt gt
WHERE f.parent_company_id = gt.parent_company_id
and f.fin_category_id = fin_hier.child_fin_cat_id
and f.company_id = gt.company_id
and f.parent_cost_center_id = gt.parent_cc_id
and f.cost_center_id =gt.cc_id
'||l_budget_snap_decode||'
and f.parent_fud1_id = gt.parent_fud1_id
and f.fud1_id =gt.fud1_id
'||l_fud2_snap_where||'
GROUP BY '||p_snap_aggrt_viewby_id||', gt.viewby, gt.sort_order
		UNION ALL
/* QUERY -- PRIOR TOTAL INCOME */
SELECT  /*+ index(f fii_gl_agrt_sum_mv_n1) */
'||p_aggrt_viewby_id||'	  viewby_id
,inner_inline_view.viewby viewby
,inner_inline_view.sort_order  sort_order
,NULL	FII_PL_CURR_REVENUE
,NULL	FII_PL_CURR_COGS
,NULL	FII_PL_CURR_EXP
,NULL	FII_PL_PRIOR_REVENUE
,NULL	FII_PL_PRIOR_COGS
,NULL	FII_PL_PRIOR_EXP
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.actual_g
     ELSE NULL END)  FII_PL_PRIOR_COGS_TOTAL_G
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g
     ELSE NULL END)  FII_PL_PRIOR_REVENUE_TOTAL_G
,SUM(CASE WHEN fin_hier.top_node_fin_cat_type = ''OE'' THEN f.actual_g
     ELSE NULL END)  FII_PL_PRIOR_EXP_TOTAL_G
,NULL	FII_PL_REV_BUDGET
,NULL 	FII_PL_COGS_BUDGET
,NULL	FII_PL_EXP_BUDGET
,NULL 	FII_PL_REV_FORECAST
,NULL 	FII_PL_COGS_FORECAST
,NULL	FII_PL_EXP_FORECAST
FROM fii_gl_agrt_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
     fii_fin_item_leaf_hiers  fin_hier,
     '||l_fud2_from||'
 (SELECT /*+ NO_MERGE cardinality(gt 1) */ *
    FROM fii_time_structures cal,
	 fii_pmv_aggrt_gt gt
   WHERE report_date = :PRIOR_PERIOD_END
     AND BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND) inner_inline_view
WHERE f.time_id = inner_inline_view.time_id
AND f.period_type_id = inner_inline_view.period_type_id
AND f.parent_company_id = inner_inline_view.parent_company_id
AND f.company_id = inner_inline_view.company_id
AND f.parent_cost_center_id = inner_inline_view.parent_cc_id
AND f.cost_center_id = inner_inline_view.cc_id
'||l_budget_decode||'
AND f.parent_fud1_id = inner_inline_view.parent_fud1_id
AND f.fud1_id = inner_inline_view.fud1_id
'||l_fud2_where||'
AND fin_hier.top_node_fin_cat_type IN (''R'', ''CGS'', ''OE'')
AND fin_hier.next_level_fin_cat_id = f.fin_category_id
AND fin_hier.next_level_fin_cat_id = fin_hier.child_fin_cat_id
GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order
) GROUP BY  viewby_id, viewby, sort_order';

l_snap_sqlstmt2 :=

' SELECT /*+ index(f fii_gl_base_map_mv_n1) */
 '||p_nonaggrt_viewby_id||'  viewby_id
,inner_inline_view.viewby    viewby
,inner_inline_view.sort_order	sort_order
,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
      AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.actual_g  ELSE NULL END)  FII_PL_CURR_REVENUE
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND AND fin_hier.top_node_fin_cat_type = ''CGS''
      THEN f.actual_g ELSE NULL END)  FII_PL_CURR_COGS
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
       AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.actual_g ELSE NULL END)  FII_PL_CURR_EXP
  '||l_agrt_base_prior||'
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
       AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.budget_g ELSE NULL END)  FII_PL_REV_BUDGET
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
       AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.budget_g ELSE NULL END) FII_PL_COGS_BUDGET
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
       AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.budget_g ELSE NULL END) FII_PL_EXP_BUDGET
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
       AND fin_hier.top_node_fin_cat_type = ''R'' THEN f.forecast_g ELSE NULL END) FII_PL_REV_FORECAST
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
       AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
       AND fin_hier.top_node_fin_cat_type = ''CGS'' THEN f.forecast_g  ELSE NULL END) FII_PL_COGS_FORECAST
 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
       AND fin_hier.top_node_fin_cat_type = ''OE'' THEN f.forecast_g  ELSE NULL END)  FII_PL_EXP_FORECAST
FROM fii_gl_base_map_mv'||fii_ea_util_pkg.g_curr_view||' f,
     fii_company_hierarchies co_hier,
     fii_cost_ctr_hierarchies cc_hier,
     fii_fin_item_leaf_hiers fin_hier,
     fii_udd1_hierarchies fud1_hier,
     '||l_fud2_from||'
(SELECT /*+ NO_MERGE cardinality(gt 1) */ *
   FROM fii_time_structures cal,
        fii_pmv_non_aggrt_gt gt
  WHERE report_date IN ( :ASOF_DATE,:PREVIOUS_ASOF_DATE,:PRIOR_PERIOD_END)
    AND (BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR BITAND(cal.record_type_id, :BUDGET_BITAND) = :BUDGET_BITAND OR
         BITAND(cal.record_type_id, :FORECAST_BITAND) = :FORECAST_BITAND)) inner_inline_view
WHERE f.period_type_id = inner_inline_view.period_type_id
and f.time_id = inner_inline_view.time_id
and co_hier.parent_company_id = inner_inline_view.company_id
and co_hier.child_company_id = f.company_id
and cc_hier.parent_cc_id = inner_inline_view.cost_center_id
and cc_hier.child_cc_id = f.cost_center_id
and fin_hier.child_fin_cat_id = f.fin_category_id
and fud1_hier.parent_value_id = inner_inline_view.fud1_id
'||l_fud1_decode||'
'||l_budget_decode||'
and fud1_hier.child_value_id = f.fud1_id
'||l_fud2_where||'
GROUP BY '||p_nonaggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- When fii_gl_trend_sum_mv is hit

l_trend_sum_mv_sql :='
SELECT   '||p_aggrt_viewby_id||'				viewby_id
	,inner_inline_view.viewby				viewby
	,inner_inline_view.sort_order				sort_order
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		    AND f.top_node_fin_cat_type = ''R''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )							FII_PL_CURR_REVENUE
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND f.top_node_fin_cat_type = ''CGS''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )							FII_PL_CURR_COGS
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND f.top_node_fin_cat_type = ''OE''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )							FII_PL_CURR_EXP
	 '||l_trend_mv_prior||'
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND f.top_node_fin_cat_type = ''R''
		 THEN f.budget_g
	    ELSE NULL
	     END
	    )							FII_PL_REV_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND f.top_node_fin_cat_type = ''CGS''
		 THEN f.budget_g
	    ELSE NULL
	     END
	    )							FII_PL_COGS_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:BUDGET_BITAND) = :BUDGET_BITAND
		    AND f.top_node_fin_cat_type = ''OE''
		 THEN f.budget_g
	    ELSE NULL
	     END
	    )							FII_PL_EXP_BUDGET
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''R''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_REV_FORECAST
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_COGS_FORECAST
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''OE''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_EXP_FORECAST
  FROM	fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
	( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
	    FROM fii_time_structures cal,
		 fii_pmv_aggrt_gt gt
	   WHERE report_date IN ( :ASOF_DATE
		 		 ,:PREVIOUS_ASOF_DATE
				 ,:PRIOR_PERIOD_END
				)
	     AND (BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
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
	'||l_budget_decode||'

GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- SQL for Operating Margin table portlet
-- Here, we don't calculate any prior and budget columns

l_trend_sum_mv_sql_port :='
	SELECT   '||p_aggrt_viewby_id||' viewby_id
	,inner_inline_view.viewby	viewby
	,inner_inline_view.sort_order	sort_order
	,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		    AND f.top_node_fin_cat_type = ''R''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )				FII_PL_CURR_REVENUE
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND f.top_node_fin_cat_type = ''CGS''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )				FII_PL_CURR_COGS
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		     AND BITAND(inner_inline_view.record_type_id,:ACTUAL_BITAND) = :ACTUAL_BITAND
		     AND f.top_node_fin_cat_type = ''OE''
		 THEN f.actual_g
	    ELSE NULL
	     END
	    )			FII_PL_CURR_EXP
	 ,NULL			FII_PL_PRIOR_REVENUE
	 ,NULL			FII_PL_PRIOR_COGS
	 ,NULL			FII_PL_PRIOR_EXP
	 ,NULL			FII_PL_REV_BUDGET
	 ,NULL			FII_PL_COGS_BUDGET
	 ,NULL			FII_PL_EXP_BUDGET
	 ,NULL			FII_PL_PRIOR_REVENUE_TOTAL_G
	 ,NULL			FII_PL_PRIOR_COGS_TOTAL_G
	 ,NULL			FII_PL_PRIOR_EXP_TOTAL_G
	 ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''R''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_REV_FORECAST
	  ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''CGS''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_COGS_FORECAST
	    ,SUM(CASE WHEN inner_inline_view.report_date = :ASOF_DATE
		    AND BITAND(inner_inline_view.record_type_id,:FORECAST_BITAND) = :FORECAST_BITAND
		    AND f.top_node_fin_cat_type = ''OE''
		 THEN f.forecast_g
	    ELSE NULL
	     END
	    )							FII_PL_EXP_FORECAST
     FROM fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||' f,
	( SELECT /*+ NO_MERGE cardinality(gt 1) */ *
	    FROM fii_time_structures cal,
		 fii_pmv_aggrt_gt gt
	   WHERE report_date IN ( :ASOF_DATE
		  		 ,:PREVIOUS_ASOF_DATE
				 ,:PRIOR_PERIOD_END
				)
	     AND (BITAND(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND OR
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
'||l_budget_decode||'
GROUP BY '||p_aggrt_viewby_id||', inner_inline_view.viewby, inner_inline_view.sort_order';

-- Deciding upon SQL, based on FF name
 IF l_function_name = 'FII_PL_OPER_MARGIN_TABLE' THEN
    l_trend_sum_mv_sql := l_trend_sum_mv_sql_port;
 END IF;

-- Checking conditions to decide upon the SQL variable

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

 l_sqlstmt :=
'SELECT  DECODE(:G_ID, inline_view.viewby_id,DECODE('''||l_if_leaf_flag||''',''Y'',
inline_view.viewby, inline_view.viewby||'' ''||:DIR_MSG),
inline_view.viewby)	VIEWBY
,inline_view.viewby_id	VIEWBYID
,(NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0) - NVL(FII_PL_CURR_EXP,0))*100
/NULLIF(ABS(FII_PL_CURR_REVENUE),0)	FII_PL_OPER_MARGIN_PCNT
,(NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0) - NVL(FII_PL_PRIOR_EXP,0))*100
/NULLIF(ABS(FII_PL_PRIOR_REVENUE),0)	FII_PL_PRIOR_OPER_MARGIN_PCNT
,NVL(FII_PL_PRIOR_REVENUE_TOTAL_G,0) - NVL(FII_PL_PRIOR_COGS_TOTAL_G,0) - NVL(FII_PL_PRIOR_EXP_TOTAL_G,0)
	FII_PL_PRIOR_OPER_INC_TOTAL
,NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0) - NVL(FII_PL_CURR_EXP,0) FII_PL_OPER_INCOME_XTD
,NULL	FII_PL_OPER_INCOME_TOTAL
,NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0) - NVL(FII_PL_PRIOR_EXP,0) FII_PL_PRIOR_OPER_INCOME_XTD
,((NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0) - NVL(FII_PL_CURR_EXP,0)) -
(NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0) - NVL(FII_PL_PRIOR_EXP,0))) *100
/NULLIF(ABS((NVL(FII_PL_PRIOR_REVENUE,0) - NVL(FII_PL_PRIOR_COGS,0) - NVL(FII_PL_PRIOR_EXP,0))),0)  FII_PL_OPER_INCOME_CHANGE
,NVL(FII_PL_REV_BUDGET,0) - NVL(FII_PL_COGS_BUDGET,0) - NVL(FII_PL_EXP_BUDGET,0)	FII_PL_BUDGET
,(NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0) - NVL(FII_PL_CURR_EXP,0))*100
/NULLIF(ABS(NVL(FII_PL_REV_BUDGET,0) - NVL(FII_PL_COGS_BUDGET,0) - NVL(FII_PL_EXP_BUDGET,0)),0)	FII_PL_PCNT_BUDGET
,NVL(FII_PL_REV_FORECAST,0) - NVL(FII_PL_COGS_FORECAST,0) - NVL(FII_PL_EXP_FORECAST,0)	FII_PL_FORECAST
,(NVL(FII_PL_CURR_REVENUE,0) - NVL(FII_PL_CURR_COGS,0) - NVL(FII_PL_CURR_EXP,0))*100
/NULLIF(ABS(NVL(FII_PL_REV_FORECAST,0) - NVL(FII_PL_COGS_FORECAST,0) - NVL(FII_PL_EXP_FORECAST,0)),0)	FII_PL_PCNT_FORECAST
,(SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER() - SUM(NVL(FII_PL_CURR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(FII_PL_CURR_REVENUE) OVER ()),0)	FII_PL_GT_OPER_MARGIN_PCNT
,(SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER() - SUM(NVL(FII_PL_PRIOR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(FII_PL_PRIOR_REVENUE) OVER ()),0)	FII_PL_GT_PRIOR_OPER_MGN_PCNT
,(SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER() - SUM(NVL(FII_PL_CURR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(FII_PL_CURR_REVENUE) OVER ()),0) -
  (SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER() - SUM(NVL(FII_PL_PRIOR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(FII_PL_PRIOR_REVENUE) OVER ()),0)	FII_PL_GT_OPER_MARGIN_CHANGE
,((SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER () - SUM(NVL(FII_PL_CURR_EXP,0)) OVER()) -
(SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER ()- SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER () - SUM(NVL(FII_PL_PRIOR_EXP,0)) OVER()))*100
/NULLIF(ABS((SUM(NVL(FII_PL_PRIOR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_PRIOR_COGS,0)) OVER () - SUM(NVL(FII_PL_PRIOR_EXP,0)) OVER() )),0)
 	FII_PL_GT_OPER_INCOME_CHANGE
,(SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER () - SUM(NVL(FII_PL_CURR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(NVL(FII_PL_REV_BUDGET,0)) OVER () - SUM(NVL(FII_PL_COGS_BUDGET,0)) OVER () - SUM(NVL(FII_PL_EXP_BUDGET,0)) OVER()),0)
 	FII_PL_GT_PCNT_BUDGET
,(SUM(NVL(FII_PL_CURR_REVENUE,0)) OVER () - SUM(NVL(FII_PL_CURR_COGS,0)) OVER () - SUM(NVL(FII_PL_CURR_EXP,0)) OVER())*100
/NULLIF(ABS(SUM(NVL(FII_PL_REV_FORECAST,0)) OVER () - SUM(NVL(FII_PL_COGS_FORECAST,0)) OVER () - SUM(NVL(FII_PL_EXP_FORECAST,0)) OVER()),0)
 	FII_PL_GT_PCNT_FORECAST
,DECODE
  ((SELECT is_leaf_flag
      FROM fii_company_hierarchies
     WHERE parent_company_id = inline_view.viewby_id
       AND child_company_id = inline_view.viewby_id),
   ''Y'',
   '''',
   '''||l_viewby_drill_url||''')  FII_PL_COMP_DRILL
,DECODE
  ((SELECT is_leaf_flag
     FROM fii_cost_ctr_hierarchies
    WHERE parent_cc_id = inline_view.viewby_id
      AND child_cc_id = inline_view.viewby_id),''Y'','''','''||l_viewby_drill_url||''')  FII_PL_CC_DRILL
,DECODE
   ((SELECT  is_leaf_flag
       FROM  fii_udd1_hierarchies
      WHERE parent_value_id = inline_view.viewby_id
	AND child_value_id = inline_view.viewby_id),''Y'','''',
     DECODE(:G_ID, inline_view.viewby_id,'''','''||l_viewby_drill_url||'''))	FII_PL_UDD1_DRILL
,DECODE
   ((SELECT is_leaf_flag
       FROM fii_udd2_hierarchies
      WHERE parent_value_id = inline_view.viewby_id
        AND child_value_id = inline_view.viewby_id),''Y'','''','''||l_viewby_drill_url||''') FII_PL_UDD2_DRILL
FROM  ('||l_aggrt_sql||'
       '||l_union_all||'
       '||l_non_aggrt_sql||'
      ) inline_view
ORDER BY  NVL(inline_view.sort_order,999999) ASC, NVL(FII_PL_OPER_MARGIN_PCNT,-999999999) DESC';

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_oper_margin_sql,
                              p_bind_output_table => p_oper_margin_output);

END get_oper_margin;




END fii_pl_page_pkg;


/
