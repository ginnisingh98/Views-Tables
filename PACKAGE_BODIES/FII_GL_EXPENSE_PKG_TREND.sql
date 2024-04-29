--------------------------------------------------------
--  DDL for Package Body FII_GL_EXPENSE_PKG_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_EXPENSE_PKG_TREND" AS
/* $Header: FIIGLE2B.pls 120.33 2005/10/30 05:08:12 appldev noship $ */

PROCEDURE get_exp_per_emp_trend(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_trend_sql out NOCOPY VARCHAR2, exp_per_emp_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   sqlstmt                VARCHAR2(32000);
   l_pk                   VARCHAR2(30);
   l_ak_region_item       VARCHAR2(100);
   g_min_start_date	  DATE;
BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'OE';
    fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
    fii_gl_util_pkg.get_bitmasks;
    fii_gl_util_pkg.get_mgr_pmv_sql;
    fii_gl_util_pkg.get_cat_pmv_sql;

select min(start_date) into g_min_start_date
   from fii_time_ent_period;

  CASE fii_gl_util_pkg.g_page_period_type
     WHEN 'FII_TIME_WEEK' THEN
       l_pk             := 'week_id';
       l_ak_region_item := 'BIS_WEEK';
       fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_WEEK';

     /* Commented out for bug 3893359 and replaced with select

     fii_gl_util_pkg.g_cy_period_end := fii_time_api.pwk_end(trunc(sysdate));
       fii_gl_util_pkg.g_py_sday := fii_time_api.sd_lyswk(trunc(sysdate)); */

       select	NVL(fii_time_api.pwk_end(trunc(sysdate)),g_min_start_date),
		NVL(fii_time_api.sd_lyswk(trunc(sysdate)),g_min_start_date)
	INTO	fii_gl_util_pkg.g_cy_period_end,
		fii_gl_util_pkg.g_py_sday
	FROM	dual;

	fii_gl_util_pkg.g_begin_date := trunc(sysdate) - 91;

       select distinct a.sequence into fii_gl_util_pkg.g_curr_per_sequence
       from FII_TIME_WEEK a
       where trunc(sysdate) BETWEEN a.START_DATE AND a.END_DATE;

     WHEN 'FII_TIME_ENT_PERIOD' THEN
       l_pk             := 'ent_period_id';
       l_ak_region_item := 'MONTH';
       fii_gl_util_pkg.g_viewby_type :=  'TIME+FII_TIME_ENT_PERIOD';

   /* Commented out for bug 3893359 and replaced with select

   fii_gl_util_pkg.g_cy_period_end := fii_time_api.ent_pper_end(trunc(sysdate));
       fii_gl_util_pkg.g_py_sday := fii_time_api.ent_sd_lysper_end(trunc(sysdate)); */

       select	NVL(fii_time_api.ent_pper_end(trunc(sysdate)),g_min_start_date),
		NVL(fii_time_api.ent_sd_lysper_end(trunc(sysdate)),g_min_start_date)
	INTO	fii_gl_util_pkg.g_cy_period_end,
		fii_gl_util_pkg.g_py_sday
	FROM	dual;

	fii_gl_util_pkg.g_begin_date :=    fii_gl_util_pkg.g_py_sday;


       select distinct a.sequence into fii_gl_util_pkg.g_curr_per_sequence
       from FII_TIME_ENT_PERIOD a
       where trunc(sysdate) BETWEEN a.START_DATE AND a.END_DATE;

     WHEN 'FII_TIME_ENT_QTR' THEN
       l_pk             := 'ent_qtr_id';
       l_ak_region_item := 'QUARTER';
       fii_gl_util_pkg.g_viewby_type :=  'TIME+FII_TIME_ENT_QTR';
 /* Commented out for bug 3893359 and replaced with select

 fii_gl_util_pkg.g_cy_period_end := fii_time_api.ent_pqtr_end(trunc(sysdate));
       fii_gl_util_pkg.g_py_sday :=       fii_time_api.ent_sd_lysqtr_end(
                                          fii_time_api.ent_sd_lysqtr_end(
                                          trunc(sysdate))); */

	select	NVL(fii_time_api.ent_pqtr_end(trunc(sysdate)),g_min_start_date),
		NVL(fii_time_api.ent_sd_lysqtr_end(fii_time_api.ent_sd_lysqtr_end(trunc(sysdate))),g_min_start_date)
	INTO	fii_gl_util_pkg.g_cy_period_end,
		fii_gl_util_pkg.g_py_sday
	FROM	dual;

	fii_gl_util_pkg.g_begin_date :=    fii_gl_util_pkg.g_py_sday;



       select distinct ent_qtr_id
       into fii_gl_util_pkg.g_curr_per_sequence
       from FII_TIME_ENT_QTR a
       where  trunc(sysdate) between a.START_DATE and a.END_DATE;


     WHEN 'FII_TIME_ENT_YEAR' THEN
       l_pk             := 'ent_year_id';
       l_ak_region_item := 'YEAR';
       fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_ENT_YEAR';

/* Commented out for bug 3893359 and replaced with select
       fii_gl_util_pkg.g_cy_period_end := fii_time_api.ent_pyr_end(
                                          trunc(sysdate));
       fii_gl_util_pkg.g_py_sday :=       fii_time_api.ent_pyr_start(
                                          fii_time_api.ent_pyr_start(
                                          fii_time_api.ent_pyr_start(
                                          fii_time_api.ent_pyr_start(
                                          trunc(sysdate)))));
       fii_gl_util_pkg.g_begin_date :=    fii_time_api.ent_pyr_start(
                                          fii_gl_util_pkg.g_py_sday); */


select	NVL(fii_time_api.ent_pyr_end(trunc(sysdate)),g_min_start_date),
	NVL(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   fii_time_api.ent_pyr_start(
                                   trunc(sysdate))))),g_min_start_date)
	INTO fii_gl_util_pkg.g_cy_period_end,
	     fii_gl_util_pkg.g_py_sday
	FROM dual;

	SELECT	NVL(fii_time_api.ent_pyr_start(fii_gl_util_pkg.g_py_sday),g_min_start_date)
	INTO    fii_gl_util_pkg.g_begin_date
	FROM	dual;


       select distinct a.sequence
       into fii_gl_util_pkg.g_curr_per_sequence
       from FII_TIME_ENT_YEAR a
       where trunc(sysdate) BETWEEN a.START_DATE AND a.END_DATE;


   END CASE;

/*
   VIEWBY = Time Level display name e.g. Q1, Q2, Q3, Q4
   FII_HEADCOUNT = Headcount
   FII_CURRENT_TD = Expenses
 */


--      -First UNION gets TOTALs amounts for current year qtrs
--      -Second UNION gets TD amounts for ongoing quarter

IF fii_gl_util_pkg.g_mgr_id = -99999 THEN

sqlstmt := '
      SELECT NULL	VIEWBY,
             NULL	VIEWBYID,
             NULL	FII_HEADCOUNT,
             NULL	FII_CURRENT_TD
      FROM   DUAL
      WHERE  1=2';

ELSIF fii_gl_util_pkg.g_page_period_type <> 'FII_TIME_ENT_QTR' THEN
     sqlstmt := '
      SELECT t.name VIEWBY,
              t.'||l_pk||' VIEWBYID,
              nvl(FII_HEADCOUNT, 1)  FII_HEADCOUNT,
              FII_CURRENT_TD     FII_CURRENT_TD
      FROM
         (SELECT inner_inline_view.FII_SEQUENCE FII_EFFECTIVE_NUM,
              sum(FII_HEADCOUNT)               FII_HEADCOUNT,
              sum(FII_CURRENT_TD)                      FII_CURRENT_TD
         FROM
           (SELECT  t.sequence FII_SEQUENCE,
                    to_number(null) FII_HEADCOUNT,
                    decode(t.sequence, :CURR_EFFECTIVE_SEQ, to_number(null), f.actual_g) FII_CURRENT_TD
            FROM    '||fii_gl_util_pkg.g_page_period_type||' t '||fii_gl_util_pkg.g_view||'
            WHERE   1=1 '||fii_gl_util_pkg.g_mgr_join||
            fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            AND   f.time_id              = t.'||l_pk||'
            AND   f.period_type_id       = :PERIOD_TYPE
            AND   t.start_date between to_date(:PY_SAME_DAY, ''DD-MM-YYYY'')
                               and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
            UNION ALL
            SELECT :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
                   to_number(null)     FII_HEADCOUNT,
                   case when c.report_date = trunc(sysdate)
                        then f.actual_g else to_number(null) end  FII_CURRENT_TD
            FROM fii_time_rpt_struct_v c
                 '|| fii_gl_util_pkg.g_view ||'
            WHERE   1=1 '||fii_gl_util_pkg.g_mgr_join||
            fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
     	      AND   f.time_id              = c.time_id
            AND   f.period_type_id       = c.period_type_id
            AND   bitand(c.record_type_id,:ACTUAL_PERIOD_TYPE) = c.record_type_id
            AND   c.report_date in (trunc(sysdate))
            UNION ALL
            SELECT   t.sequence      FII_SEQUENCE,
                     decode(t.sequence, :CURR_EFFECTIVE_SEQ, to_number(null), total_headcount+1) FII_HEADCOUNT,
                     to_number(null) FII_CURRENT_TD
            FROM  hri_mdp_sup_wmv_sup_mv,
                  '||fii_gl_util_pkg.g_page_period_type||' t
            WHERE supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND   effective_start_date       = (SELECT max(effective_start_date)
                                          FROM   hri_mdp_sup_wmv_sup_mv aa
                                          WHERE  supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
                                          AND    effective_start_date <= t.end_date
                                          )
            AND   t.start_date between to_date(:PY_SAME_DAY, ''DD-MM-YYYY'')
                             and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
            UNION ALL
            SELECT   :CURR_EFFECTIVE_SEQ      FII_SEQUENCE,
                     total_headcount+1              FII_HEADCOUNT,
                     to_number(null)          FII_CURRENT_TD
            FROM  hri_mdp_sup_wmv_sup_mv
            WHERE supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND   effective_start_date       = (SELECT max(effective_start_date)
                                          FROM   hri_mdp_sup_wmv_sup_mv aa
                                          WHERE  supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
                                          AND    aa.effective_start_date <= trunc(sysdate)
                                          )
            ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
       ) g1, '||fii_gl_util_pkg.g_page_period_type||' t
 WHERE g1.fii_effective_num (+)= t.sequence
 AND t.start_date <= trunc(sysdate)
 AND t.start_date > to_date(:BEGIN_DATE, ''DD-MM-YYYY'')
 ORDER BY t.start_date';

ELSE
     sqlstmt := '
      SELECT t.name VIEWBY,
              t.'||l_pk||' VIEWBYID,
              nvl(FII_HEADCOUNT,1)  FII_HEADCOUNT,
              FII_CURRENT_TD     FII_CURRENT_TD
      FROM
         (SELECT inner_inline_view.FII_SEQUENCE FII_EFFECTIVE_NUM,
              sum(FII_HEADCOUNT)                   FII_HEADCOUNT,
              sum(FII_CURRENT_TD)                      FII_CURRENT_TD
         FROM
           (SELECT  t.ent_qtr_id FII_SEQUENCE,
                    to_number(null) FII_HEADCOUNT,
                    decode(t.sequence, :CURR_EFFECTIVE_SEQ, to_number(null), f.actual_g) FII_CURRENT_TD
            FROM    '||fii_gl_util_pkg.g_page_period_type||' t '||fii_gl_util_pkg.g_view||'
            WHERE   1=1 '||fii_gl_util_pkg.g_mgr_join||
            fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
            AND   f.time_id              = t.'||l_pk||'
            AND   f.period_type_id       = :PERIOD_TYPE
            AND   t.start_date between to_date(:PY_SAME_DAY, ''DD-MM-YYYY'')
                               and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
            UNION ALL
            SELECT :CURR_EFFECTIVE_SEQ FII_SEQUENCE,
                   to_number(null)     FII_HEADCOUNT,
                   case when c.report_date = trunc(sysdate)
                        then f.actual_g else to_number(null) end  FII_CURRENT_TD
            FROM fii_time_rpt_struct_v c
                 '|| fii_gl_util_pkg.g_view ||'
            WHERE   1=1 '||fii_gl_util_pkg.g_mgr_join||
            fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
     	      AND   f.time_id              = c.time_id
            AND   f.period_type_id       = c.period_type_id
            AND   bitand(c.record_type_id,:ACTUAL_PERIOD_TYPE) = c.record_type_id
            AND   c.report_date in (trunc(sysdate))
            UNION ALL
            SELECT   t.ent_qtr_id      FII_SEQUENCE,
                     decode(t.sequence, :CURR_EFFECTIVE_SEQ, to_number(null), total_headcount+1) FII_HEADCOUNT,
                     to_number(null) FII_CURRENT_TD
            FROM  hri_mdp_sup_wmv_sup_mv,
                  '||fii_gl_util_pkg.g_page_period_type||' t
            WHERE supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND   effective_start_date       = (SELECT max(effective_start_date)
                                          FROM   hri_mdp_sup_wmv_sup_mv aa
                                          WHERE  supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
                                          AND    effective_start_date <= t.end_date
                                          )
            AND   t.start_date between to_date(:PY_SAME_DAY, ''DD-MM-YYYY'')
                             and to_date(:CY_PERIOD_END, ''DD-MM-YYYY'')
            UNION ALL
            SELECT   :CURR_EFFECTIVE_SEQ      FII_SEQUENCE,
                     total_headcount+1     FII_HEADCOUNT,
                     to_number(null) FII_CURRENT_TD
            FROM  hri_mdp_sup_wmv_sup_mv
            WHERE supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND   effective_start_date       = (SELECT max(effective_start_date)
                                          FROM   hri_mdp_sup_wmv_sup_mv aa
                                          WHERE  supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
                                          AND    aa.effective_start_date <= trunc(sysdate)
                                          )
            ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
       ) g1, '||fii_gl_util_pkg.g_page_period_type||' t
 WHERE g1.fii_effective_num (+)= t.'||l_pk||'
 AND t.start_date <= trunc(sysdate)
 AND t.start_date > to_date(:BEGIN_DATE, ''DD-MM-YYYY'')
 ORDER BY t.start_date';

END IF;

   fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_per_emp_trend_sql, exp_per_emp_trend_output);


END  get_exp_per_emp_trend;

END fii_gl_expense_pkg_trend;

/
