--------------------------------------------------------
--  DDL for Package Body FII_GL_EXP_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_EXP_TREND" AS
/* $Header: FIIGLETB.pls 120.32 2006/02/07 13:23:30 hpoddar noship $ */


PROCEDURE get_te_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'TE';

    fii_gl_exp_trend.get_expense_sum(p_page_parameter_tbl, expense_sum_sql, expense_sum_output);
END get_te_sum;

PROCEDURE get_exp_sum (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, expense_sum_sql out NOCOPY VARCHAR2,
  expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'OE';

    fii_gl_exp_trend.get_expense_sum(p_page_parameter_tbl, expense_sum_sql, expense_sum_output);
END get_exp_sum;

PROCEDURE get_expense_sum (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
expense_sum_sql out NOCOPY VARCHAR2, expense_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   sqlstmt                VARCHAR2(32000);
   l_pk                   VARCHAR2(30);
   l_name                 VARCHAR2(100);
   l_time_comp            VARCHAR2(20);
   l_prior_or_budget      VARCHAR2(1000);
   l_prior_or_budget1     VARCHAR2(1000);
   l_curr_effective_num   NUMBER;
   l_min_start_date	  DATE;


BEGIN

	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_cat_pmv_sql;

    CASE fii_gl_util_pkg.g_page_period_type
     WHEN 'FII_TIME_WEEK' THEN
       l_pk             := 'week_id';
       fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_WEEK';
        l_name           := 'replace(fnd_message.get_string(''FII'',''FII_WEEK_LABEL''),''&WEEK_NUMBER'',t.sequence)';

     WHEN 'FII_TIME_ENT_PERIOD' THEN
       l_pk             := 'ent_period_id';
       fii_gl_util_pkg.g_viewby_type :='TIME+FII_TIME_ENT_PERIOD';
       l_name           := 'to_char(t.start_date,''Mon'')';

     WHEN 'FII_TIME_ENT_QTR' THEN
       l_pk             := 'ent_qtr_id';
       fii_gl_util_pkg.g_viewby_type :='TIME+FII_TIME_ENT_QTR';
       l_name           := 'replace(fnd_message.get_string(''FII'',''FII_QUARTER_LABEL''),''&QUARTER_NUMBER'',t.sequence)';

     WHEN 'FII_TIME_ENT_YEAR' THEN
       l_pk             := 'ent_year_id';
       fii_gl_util_pkg.g_viewby_type :='TIME+FII_TIME_ENT_YEAR';

       SELECT MIN(start_date) into l_min_start_date
       FROM fii_time_ent_period;

      /* fix for bug 4962173*/

      SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_gl_util_pkg.g_as_of_date)))),l_min_start_date)
	INTO fii_gl_util_pkg.g_py_sday
	FROM dual;

       SELECT NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_gl_util_pkg.g_previous_asof_date)))),l_min_start_date)
	INTO fii_gl_util_pkg.g_five_yr_back
	FROM dual;

   END CASE;

     /* if budget is selected, the prior amount column will return 0 */
  IF (fii_gl_util_pkg.g_time_comp = 'SEQUENTIAL') THEN
	l_prior_or_budget :='case when t.start_date between to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                                          and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
                      then f.forecast_g else TO_NUMBER(NULL) end FORECAST ';
   ELSIF (fii_gl_util_pkg.g_time_comp = 'YEARLY') THEN
	l_prior_or_budget :=  'to_number(NULL) FORECAST ';
   ELSIF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
	l_prior_or_budget :=  ' to_number(NULL) FORECAST ';
  END IF;

/* ----------------------------------
   FII_MEASURE1 = Time Level Name
   FII_MEASURE2 = Current Year XTotal
   FII_MEASURE3 = Prior Year XTotal
   FII_MEASURE4 = Current Year XTD
   FII_MEASURE5 = Prior Year XTD
 * ----------------------------------*/

  IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
     sqlstmt := '
       select NULL	VIEWBY,
              NULL	VIEWBYID,
              NULL	FII_MEASURE2,
              NULL	FII_MEASURE3,
              NULL	FII_MEASURE4,
              NULL	FII_MEASURE5,
              NULL	FII_MEASURE7,
              NULL	FII_MEASURE8,
	      NULL	FII_CAL1
	FROM  DUAL
	WHERE 1=2 ';

ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN


sqlstmt := '
       select t.name VIEWBY,
              t.'||l_pk||' VIEWBYID,
              sum(CY_QTOT) FII_MEASURE2,
              sum(PY_QTOT) FII_MEASURE3,
              sum(CY_QTD)  FII_MEASURE4,
              sum(PY_QTD)  FII_MEASURE5,
              sum(BUDGET)  FII_MEASURE7,
              sum(FORECAST) FII_MEASURE8,
	          NVL(sum(CY_QTOT), 0) + NVL(sum(CY_QTD), 0)  FII_CAL1
       from (
            select t.sequence                FII_SEQUENCE,
                   f.actual_g                CY_QTOT,
                   TO_NUMBER(NULL)           PY_QTOT,
                   TO_NUMBER(NULL)           CY_QTD,
                   TO_NUMBER(NULL)           PY_QTD,
                   f.budget_g                BUDGET,
                   TO_NUMBER(NULL)           FORECAST
            from  fii_gl_mgmt_sum_v'||fii_gl_util_pkg.g_global_curr_view ||' f,
                  '||fii_gl_util_pkg.g_page_period_type||'  t
		  '||fii_gl_util_pkg.g_mgr_from_clause||'
            where 1=1 '||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||'
            and   f.time_id               = t.'||l_pk||'
            and   f.period_type_id        = :PERIOD_TYPE
            and   t.start_date between to_date(:FIVE_YR_BACK, ''DD-MM-YYYY'')
                  and to_date(:ENT_PYR_END, ''DD-MM-YYYY'')
            union all
            select t.sequence               FII_SEQUENCE,
                   TO_NUMBER(NULL)          CY_QTOT,
                   TO_NUMBER(NULL)          PY_QTOT,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                        then f.actual_g else TO_NUMBER(NULL) end           CY_QTD,
                   TO_NUMBER(NULL)          PY_QTD,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                        then f.budget_g else to_number(null) end BUDGET,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                        then f.forecast_g else to_number(null) end   FORECAST
            from fii_gl_mgmt_sum_v'|| fii_gl_util_pkg.g_global_curr_view ||' f,
                 FII_TIME_RPT_STRUCT       cal,
                 '||fii_gl_util_pkg.g_page_period_type||'  t,
                 fii_time_day          day
		 '||fii_gl_util_pkg.g_mgr_from_clause||'
            where  1=1 '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            and   f.time_id               = cal.time_id
            and   f.period_type_id        = cal.period_type_id
            and   cal.report_date         = day.report_date
            and   day.'||l_pk||' = t.'||l_pk||'
            and   bitand(cal.record_type_id,:WHERE_PERIOD_TYPE)=cal.record_type_id
            and   cal.report_date = &BIS_CURRENT_ASOF_DATE
       ) g1, '||fii_gl_util_pkg.g_page_period_type||' t
       where FII_SEQUENCE (+)= t.sequence
       and t.start_date >= to_date(:PY_SAME_DAY, ''DD-MM-YYYY'')
       and t.end_date   <= to_date(:ENT_CYR_END, ''DD-MM-YYYY'')
       group by t.sequence, t.name, t.'||l_pk||'
       order by t.sequence';
   ELSIF (fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') and (fii_gl_util_pkg.g_time_comp = 'SEQUENTIAL') THEN
       sqlstmt := '
              select t.name VIEWBY,
              t.'||l_pk||' VIEWBYID,
              CY_QTOT FII_MEASURE2,
              PY_QTOT FII_MEASURE3,
              CY_QTD  FII_MEASURE4,
              PY_QTD  FII_MEASURE5,
              BUDGET  FII_MEASURE7,
              FORECAST FII_MEASURE8,
	          NVL(CY_QTOT, 0) + NVL(CY_QTD, 0) FII_CAL1
        from
          (select inner_inline_view.FII_SEQUENCE FII_EFFECTIVE_NUM,
              sum(CY_QTOT) CY_QTOT,
              sum(PY_QTOT) PY_QTOT,
              sum(CY_QTD)  CY_QTD,
              sum(PY_QTD)  PY_QTD,
              sum(BUDGET)  BUDGET,
              sum(FORECAST) FORECAST
              from
            (select t.'||l_pk||' FII_SEQUENCE,
                   sum(case when t.'||l_pk||' <> :CURR_EFFECTIVE_SEQ then f.actual_g
                       else TO_NUMBER(NULL) end)  CY_QTOT,
                   TO_NUMBER(NULL) PY_QTOT,
                   TO_NUMBER(NULL) CY_QTD,
                   TO_NUMBER(NULL) PY_QTD,
                   sum(case when t.start_date between to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                                          and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
                        then f.budget_g else TO_NUMBER(NULL) end) BUDGET,
                   sum(case when t.start_date between to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                                          and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
                      then f.forecast_g else TO_NUMBER(NULL) end) FORECAST
            from  fii_gl_mgmt_sum_v'|| fii_gl_util_pkg.g_global_curr_view ||' f,
                  '||fii_gl_util_pkg.g_page_period_type||'     t
		  '||fii_gl_util_pkg.g_mgr_from_clause||'
            where  1=1 '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            and   f.time_id               = t.'||l_pk||'
            and   f.period_type_id        = :PERIOD_TYPE
            and   t.start_date between to_date(:P_EXP_START, ''DD-MM-YYYY'')
                               and &BIS_CURRENT_ASOF_DATE
            group by t.'||l_pk||'
            union all
            select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
                   TO_NUMBER(NULL) CY_QTOT,
                   TO_NUMBER(NULL) PY_QTOT,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                        then f.actual_g else TO_NUMBER(NULL) end  CY_QTD,
                   TO_NUMBER(NULL) PY_QTD,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                        then f.budget_g else to_number(null) end BUDGET,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                        then f.forecast_g else to_number(null) end   FORECAST
            from fii_gl_mgmt_sum_v'||fii_gl_util_pkg.g_global_curr_view ||' f,
                 FII_TIME_RPT_STRUCT                        cal
		 '||fii_gl_util_pkg.g_mgr_from_clause||'
            where  1=1 '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            and   f.time_id               = cal.time_id
            and   f.period_type_id        = cal.period_type_id
            and   bitand(cal.record_type_id,:WHERE_PERIOD_TYPE)=cal.record_type_id
            and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, to_date(:P_EXP_ASOF, ''DD-MM-YYYY'') )) inner_inline_view
            group by inner_inline_view.FII_SEQUENCE
       ) g1,  '||fii_gl_util_pkg.g_page_period_type||' t
       where g1.fii_effective_num (+)= t.'||l_pk||'
       and t.start_date <= &BIS_CURRENT_ASOF_DATE
       and t.start_date >  to_date(:P_EXP_START, ''DD-MM-YYYY'')
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
	      NVL(CY_QTOT, 0) + NVL(CY_QTD, 0) FII_CAL1
        from
          (select inner_inline_view.FII_SEQUENCE FII_EFFECTIVE_NUM,
              sum(CY_QTOT) CY_QTOT,
              sum(PY_QTOT) PY_QTOT,
              sum(CY_QTD)  CY_QTD,
              sum(PY_QTD)  PY_QTD,
              sum(BUDGET)  BUDGET,
              sum(FORECAST) FORECAST
              from
            (select t.sequence FII_SEQUENCE,
                   case when t.sequence <> :CURR_EFFECTIVE_SEQ then (case when t.start_date between to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                                          and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
                        then f.actual_g else TO_NUMBER(NULL)end) else TO_NUMBER(NULL) end  CY_QTOT,
                   case when t.start_date between to_date(:P_EXP_START, ''DD-MM-YYYY'')
                                          and to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                        then f.actual_g else TO_NUMBER(NULL) end  PY_QTOT,
                   TO_NUMBER(NULL) CY_QTD,
                   TO_NUMBER(NULL) PY_QTD,
                   case when t.start_date between to_date(:P_EXP_ASOF, ''DD-MM-YYYY'')
                                          and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
                        then f.budget_g else TO_NUMBER(NULL) end BUDGET,
                   '||l_prior_or_budget||'
            from  fii_gl_mgmt_sum_v'||fii_gl_util_pkg.g_global_curr_view ||' f,
                  '||fii_gl_util_pkg.g_page_period_type||'                   t
		  '||fii_gl_util_pkg.g_mgr_from_clause||'
            where  f.time_id               = t.'||l_pk||'
            and  1=1 '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            and   f.time_id               = t.'||l_pk||'
            and   f.period_type_id        = :PERIOD_TYPE
            and   t.start_date between to_date(:P_EXP_START, ''DD-MM-YYYY'')
                               and &BIS_CURRENT_ASOF_DATE
            union all
            select :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
                   TO_NUMBER(NULL) CY_QTOT,
                   TO_NUMBER(NULL) PY_QTOT,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                        then f.actual_g else TO_NUMBER(NULL) end  CY_QTD,
                   case when cal.report_date = to_date(:P_EXP_ASOF, ''DD-MM-YYYY'') and
                   bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                        then f.actual_g else TO_NUMBER(NULL) end PY_QTD,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                        then f.budget_g else to_number(null) end BUDGET,
                   case when cal.report_date = &BIS_CURRENT_ASOF_DATE and
                   bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                        then f.forecast_g else to_number(null) end   FORECAST
            from fii_gl_mgmt_sum_v'||fii_gl_util_pkg.g_global_curr_view ||' f,
                 FII_TIME_RPT_STRUCT                       cal
		  '||fii_gl_util_pkg.g_mgr_from_clause||'
            where  1=1 '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            and   f.time_id               = cal.time_id
            and   f.period_type_id        = cal.period_type_id
            and   bitand(cal.record_type_id,:WHERE_PERIOD_TYPE)=cal.record_type_id
            and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, to_date(:P_EXP_ASOF, ''DD-MM-YYYY'') )) inner_inline_view
            group by inner_inline_view.FII_SEQUENCE
       ) g1,  '||fii_gl_util_pkg.g_page_period_type||' t
       where g1.fii_effective_num (+)= t.sequence
       and t.start_date <= &BIS_CURRENT_ASOF_DATE
       and t.start_date >  to_date(:P_EXP_BEGIN, ''DD-MM-YYYY'')
       order by t.start_date';
   END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, expense_sum_sql, expense_sum_output);

END get_expense_sum;

END fii_gl_exp_trend;


/
