--------------------------------------------------------
--  DDL for Package Body FII_GL_EXPENSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_EXPENSE_PKG" AS
/* $Header: FIIGLEXB.pls 120.39 2006/03/15 15:12:45 hpoddar noship $ */


PROCEDURE get_te_per_emp (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_sql out NOCOPY VARCHAR2,
  exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'TE';

    fii_gl_expense_pkg.get_expenses_per_emp(p_page_parameter_tbl, exp_per_emp_sql, exp_per_emp_output);
END get_te_per_emp;

PROCEDURE get_exp_per_emp (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_per_emp_sql out NOCOPY VARCHAR2,
  exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'OE';

    fii_gl_expense_pkg.get_expenses_per_emp(p_page_parameter_tbl, exp_per_emp_sql, exp_per_emp_output);
END get_exp_per_emp;



PROCEDURE GET_EXPENSES_PER_EMP (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_per_emp_sql out NOCOPY VARCHAR2,
exp_per_emp_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

   sqlstmt                 VARCHAR2(30000);
   l_prior_exp             VARCHAR2(5000) := NULL;
   l_prior_hc              VARCHAR2(5000) := NULL;
   l_prior_gt_exp          VARCHAR2(5000) := NULL;
   l_prior_gt_hc           VARCHAR2(5000) := NULL;
   l_total_prior_hc        NUMBER;

   l_shared_hr_flag VARCHAR2(1) := NVL(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');

BEGIN
    fii_gl_util_pkg.g_view_by := 'HRI_PERSON+HRI_PER_USRDR_H';
    fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
    fii_gl_util_pkg.get_bitmasks;
    fii_gl_util_pkg.get_viewby_sql;
    fii_gl_util_pkg.get_mgr_pmv_sql;
    fii_gl_util_pkg.get_cat_pmv_sql;

/*
   VIEWBY       = MANAGER
   FII_MEASURE1 = Current Expenses
   FII_MEASURE9 = Prior Expenses
   FII_MEASURE8 = Current headcount
   FII_MEASURE10 = Prior headcount
   FII_MEASURE2 = Headcount (kpi)
   FII_MEASURE3 = Average Expenses per Head (kpi)
   FII_MEASURE12 = Grand Total (Current Expenses)
   FII_ATTRIBUTE10 = Grand Total (Prior Expenses)
   FII_ATTRIBUTE11 = Grand Total (Current Headcount)
   FII_ATTRIBUTE12 = Grand Total (Prior Headcount)
   FII_MEASURE14 = url for VIEWBY
   FII_MEASURE5 = null
 */

  -- -------------------------------------------------
  -- Following bind is used to calculate total
  -- head-count under a given manager
  -- and used in the Expenses per Head reports
  -- -------------------------------------------------
--query below gets the headcount for the reporting date
        begin
            select total_headcount+1  into fii_gl_util_pkg.g_total_hc
            from   hri_mdp_sup_wmv_sup_mv
            where  supervisor_person_id   = fii_gl_util_pkg.g_mgr_id
            and    effective_start_date  = (SELECT     max(aa.effective_start_date)
                                        FROM     hri_mdp_sup_wmv_sup_mv  aa
                                       WHERE     aa.supervisor_person_id = fii_gl_util_pkg.g_mgr_id
                                         AND     aa.effective_start_date <= decode(l_shared_hr_flag, 'N', fii_gl_util_pkg.g_as_of_date,	sysdate));
        exception
           when others then
             fii_gl_util_pkg.g_total_hc := 1;
        end;

--query below gets the headcount as of the prior reporting date
        begin
            select total_headcount+1  into l_total_prior_hc
            from   hri_mdp_sup_wmv_sup_mv
            where  supervisor_person_id   = fii_gl_util_pkg.g_mgr_id
            and    effective_start_date  = (SELECT     max(aa.effective_start_date)
                                        FROM     hri_mdp_sup_wmv_sup_mv  aa
                                       WHERE     aa.supervisor_person_id = fii_gl_util_pkg.g_mgr_id
                                         AND     aa.effective_start_date <= decode(l_shared_hr_flag, 'N', fii_gl_util_pkg.g_previous_asof_date, sysdate));
        exception
           when others then
             l_total_prior_hc := 1;
        end;

-- First Union gets head count for the directs with cost center resposibility for a given manager as of reporting date.
-- This union excludes the Manager himself.
-- Second Union gets head count for the directs with cost center responsibility for a given manager as of prior reporting date.
--This union exlucdes the manager himself.
-- Third Union accounts for the directs and the manager themselves in the headcount number  for both reporting date + prior reporting date.
-- Fourth Union gets the expenses for reporting date + prior reporting date.

IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') then
   l_prior_exp := 'to_number(null)    FII_MEASURE9,';
   l_prior_hc :=  'to_number(null)    FII_MEASURE10,';
   l_prior_gt_exp := 'to_number(null)  FII_ATTRIBUTE10,';
   l_prior_gt_hc  := 'to_number(null)  FII_ATTRIBUTE12,';
ELSE
   l_prior_exp := 'PY_XTD            FII_MEASURE9,';
   l_prior_hc := ' case when f.VIEWBY_ID = &HRI_PERSON+HRI_PER_USRDR_H
                        then '||l_total_prior_hc||'+1-sum(f.PY_HEADCNT) over()
                        else f.PY_HEADCNT
                        end       FII_MEASURE10,';
   l_prior_gt_exp := ' sum(PY_XTD) over()        FII_ATTRIBUTE10,';
   l_prior_gt_hc  := l_total_prior_hc||'   FII_ATTRIBUTE12,';
END IF;

IF fii_gl_util_pkg.g_mgr_id = -99999 THEN


sqlstmt := 'SELECT	NULL	 VIEWBY,
			NULL	 VIEWBYID,
		        NULL	 FII_MEASURE1,
                        NULL     FII_MEASURE9,
			NULL	 FII_MEASURE8,
			NULL	 FII_MEASURE10,
                        NULL     FII_MEASURE2,
			NULL	 FII_MEASURE3,
			NULL	 FII_MEASURE12,
                        NULL     FII_ATTRIBUTE10,
                        NULL     FII_ATTRIBUTE11,
			NULL     FII_ATTRIBUTE12,
			NULL	 FII_MEASURE14,
                        NULL    FII_MEASURE5
	   FROM		DUAL
	   WHERE	1=2';

ELSE


	sqlstmt := '
         SELECT
                 decode(:MGR_ID, f.viewby_id, decode(:DIM_FLAG,''Y'','||fii_gl_util_pkg.g_viewby_value||', '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG), '||fii_gl_util_pkg.g_viewby_value||') VIEWBY,
                 f.viewby_id                                       VIEWBYID,
                 CY_XTD                                                FII_MEASURE1,
                 '||l_prior_exp||'
                 case when f.VIEWBY_ID = &HRI_PERSON+HRI_PER_USRDR_H
                      then :TOTAL_HC+1-sum(f.headcnt) over()
                      else f.headcnt
                      end                                             FII_MEASURE8,
                 '||l_prior_hc||'
                 case when f.VIEWBY_ID = &HRI_PERSON+HRI_PER_USRDR_H
                      then :TOTAL_HC+1-sum(f.headcnt) over()
                      else f.headcnt
                      end                                                   FII_MEASURE2,
                 CY_XTD /nullif((case when f.VIEWBY_ID = &HRI_PERSON+HRI_PER_USRDR_H
                      then :TOTAL_HC+1-sum(f.headcnt) over()
                      else f.headcnt end), 0)                          FII_MEASURE3,
                 sum(CY_XTD) over()                                    FII_MEASURE12, -- Added for bug#2955837,
                 '||l_prior_gt_exp||'
		 :TOTAL_HC              		    FII_ATTRIBUTE11,
                 '||l_prior_gt_hc||'                                        -- Added for bug#2955837
	decode(NVL(:MGR_ID, -9999), f.viewby_id, '''', ''pFunctionName=FII_GL_EXP_PER_EMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')	FII_MEASURE14,
                 sum(CY_XTD) over() /
                      NULLIF(:TOTAL_HC,0)            FII_MEASURE5
         FROM    (
             SELECT /*+ NO_MERGE */ viewby_id VIEWBY_ID,
                    sum(cy_xtd) CY_XTD,
                    sum(py_xtd) PY_XTD,
                    sum(headcnt) HEADCNT,
                    sum(py_headcnt) PY_HEADCNT
             FROM (
                   SELECT  mgr.emp_id                viewby_id,
                           NVL(cnt.total_headcount,0) HEADCNT,
                           to_number(NULL)           PY_HEADCNT,
                           to_number(NULL)           CY_XTD,
                           to_number(NULL)           PY_XTD
                   FROM    fii_cc_mgr_hierarchies    mgr,
                           hri_mdp_sup_wmv_sup_mv      cnt
                   WHERE   mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
                   AND     mgr.emp_level = mgr.mgr_level + 1
                   AND     cnt.supervisor_person_id = mgr.emp_id
                   AND     cnt.effective_start_date = (SELECT  /*+ no_unnest*/ MAX(cnt2.effective_start_date)
                                                  FROM    hri_mdp_sup_wmv_sup_mv cnt2
                                                  WHERE   cnt.supervisor_person_id = cnt2.supervisor_person_id
                                                  AND     cnt2.effective_start_date <= decode('''||l_shared_hr_flag||''', ''N'', &BIS_CURRENT_ASOF_DATE, sysdate))
                   AND     cnt.total_headcount > 0
                      UNION ALL
                   SELECT  mgr.emp_id                viewby_id,
                           to_number(NULL)           HEADCNT,
                           NVL(cnt.total_headcount,0)      PY_HEADCNT,
                           to_number(NULL)           CY_XTD,
                           to_number(NULL)           PY_XTD
                   FROM    fii_cc_mgr_hierarchies    mgr,
                           hri_mdp_sup_wmv_sup_mv      cnt
                   WHERE   mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
                   AND     mgr.emp_level = mgr.mgr_level + 1
                   AND     cnt.supervisor_person_id = mgr.emp_id
                   AND     cnt.effective_start_date = (SELECT  /*+ no_unnest*/ MAX(cnt2.effective_start_date)
                                                  FROM    hri_mdp_sup_wmv_sup_mv cnt2
                                                  WHERE   cnt.supervisor_person_id = cnt2.supervisor_person_id
                                                  AND     cnt2.effective_start_date <= decode('''||l_shared_hr_flag||''', ''N'', &BIS_PREVIOUS_ASOF_DATE, sysdate))
                   AND     cnt.total_headcount > 0
                      UNION ALL
                   SELECT  mgr.EMP_ID                viewby_id,
                           1                         HEADCNT,
                           1                         PY_HEADCNT,
                           to_number(NULL)           CY_XTD,
                           to_number(NULL)           PY_XTD
                   FROM    fii_cc_mgr_hierarchies    mgr
                   WHERE   mgr.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
                   AND     mgr.emp_level <= mgr.mgr_level + 1
                       UNION ALL
                   SELECT  f.person_id               viewby_id,
                           to_number(NULL)           HEADCNT,
                           to_number(NULL)           PY_HEADCNT,
                           sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                                    then f.actual_g else to_number(null) end)      CY_XTD,
                           sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                    then f.actual_g else to_number(null) end)      PY_XTD
                   FROM   fii_time_rpt_struct cal'||fii_gl_util_pkg.g_view||'
                   WHERE  1=1'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
                   AND    f.time_id         = cal.time_id
                   AND    f.period_type_id  = cal.period_type_id
                   AND    bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE)= cal.record_type_id
                   AND    cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
                   GROUP BY f.person_id
              ) h
              GROUP BY VIEWBY_ID
          ) f, '||fii_gl_util_pkg.g_viewby_from_clause||'
          WHERE  '||fii_gl_util_pkg.g_viewby_join||'
	  ORDER BY NVL(FII_MEASURE3, -9999999999) desc';

END IF;


    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_per_emp_sql, exp_per_emp_output);


END  GET_EXPENSES_PER_EMP;

END FII_GL_EXPENSE_PKG;

/
