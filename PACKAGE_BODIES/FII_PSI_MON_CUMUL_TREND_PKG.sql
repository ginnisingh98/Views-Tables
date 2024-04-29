--------------------------------------------------------
--  DDL for Package Body FII_PSI_MON_CUMUL_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PSI_MON_CUMUL_TREND_PKG" AS
/* $Header: FIIPSIMCTB.pls 120.2 2006/05/25 10:26:28 hpoddar noship $ */

---------------------------------------------------------------------------------
-- the GET_MON_CUMUL_TREND procedure is called by Monthly Cumulative Trend report.

PROCEDURE GET_MON_CUMUL_TREND (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_mon_trend_sql out NOCOPY VARCHAR2,
                         p_mon_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
  l_sqlstmt                VARCHAR2(15000);
  l_as_of_date             DATE;
  l_min_start_date         DATE;
  l_curr_per_start         DATE;
  l_curr_per_end           DATE;
  l_company_security       VARCHAR2(1000);
  l_cost_center_security   VARCHAR2(1000);


BEGIN
-- initialization. Calling fii_ea_util_pkg APIs necessary for constructing
-- the PMV sql.

fii_ea_util_pkg.reset_globals;
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);


l_as_of_date := fii_ea_util_pkg.g_as_of_date;

-- to find out the year start date and END date
SELECT NVL(MIN(start_date), trunc(sysdate))  INTO l_min_start_date   FROM   fii_time_ent_period;

SELECT NVL(fii_time_api.ent_cyr_start(l_as_of_date), l_min_start_date)
       INTO l_curr_per_start FROM DUAL;

SELECT NVL(fii_time_api.ent_cyr_end(l_as_of_date), l_min_start_date)
       INTO l_curr_per_end FROM DUAL;

-- Obtaining all possible company-ids to which user has access

   IF fii_ea_util_pkg.g_company_id = 'All' THEN
        l_company_security :=
                ' AND  f.company_dim_id IN
                        (SELECT company_id FROM fii_company_grants
                         WHERE user_id = fnd_global.user_id
                         AND report_region_code = '''||fii_ea_util_pkg.g_region_code||''') ';
   ELSE
        l_company_security := ' AND f.company_dim_id = &FII_COMPANIES+FII_COMPANIES ' ;
   END IF;

-- Obtaining all possible cost-center-ids to which user has access

   IF fii_ea_util_pkg.g_cost_center_id = 'All' THEN
         l_cost_center_security :=
                ' AND f.cost_center_dim_id IN (SELECT cost_center_id
                                               FROM fii_cost_center_grants
                                               WHERE user_id = fnd_global.user_id
                                               AND report_region_code =
                                                    '''||fii_ea_util_pkg.g_region_code||''' ) ';
   ELSE
         l_cost_center_security := ' AND f.cost_center_dim_id = &ORGANIZATION+HRI_CL_ORGCC ';
   END IF;


-- assigning bind variables
fii_ea_util_pkg.g_curr_per_start := l_curr_per_start;
fii_ea_util_pkg.g_curr_per_end := l_curr_per_end;


-- first union - budgets and encumbrances for the entire period
-- second union - actuals for < as-of-date
-- third union - actuals for the rest of the year,  >= as-of-date


l_sqlstmt:= '
           SELECT
                t.ent_period_id                                     FII_PSI_PERIOD_ID,
                t.name                                              FII_PSI_PERIOD,
               SUM(CASE WHEN FII_PSI_BUDGET_A=0 THEN TO_NUMBER(NULL)
                      ELSE FII_PSI_BUDGET_A END)                              FII_PSI_BUDGET_A,
               SUM(CASE WHEN FII_PSI_ENCUMBRANCES_A=0 THEN TO_NUMBER(NULL)
                      ELSE FII_PSI_ENCUMBRANCES_A END)                        FII_PSI_ENCUMBRANCES_A,
               SUM(CASE WHEN FII_PSI_ACTUALS_A=0 THEN TO_NUMBER(NULL)
                      ELSE FII_PSI_ACTUALS_A END)                             FII_PSI_ACTUALS_A,
               SUM(CASE WHEN (FII_PSI_ENCUMBRANCES_A=0 and FII_PSI_ACTUALS_A=0)
                      THEN TO_NUMBER(NULL)
                      ELSE FII_PSI_ENCUMBRANCES_A+FII_PSI_ACTUALS_A END)      FII_PSI_SPENDING_A,
               SUM(CASE WHEN (FII_PSI_ENCUMBRANCES_A=0 and FII_PSI_ACTUALS_A=0 and FII_PSI_BUDGET_A=0)
                     THEN TO_NUMBER(NULL) ELSE
                     FII_PSI_BUDGET_A-FII_PSI_ENCUMBRANCES_A-FII_PSI_ACTUALS_A END) FII_PSI_AVAIL_A
           FROM(
                 SELECT
                       t.ent_period_id                                     FII_PSI_PERIOD_ID,
                      SUM(CASE WHEN TRUNC(f.posted_date) <= :ASOF_DATE
                                THEN f.PRIM_BUDGET_G  ELSE 0  END)        FII_PSI_BUDGET_A,
                      SUM(CASE WHEN TRUNC(f.posted_date) <= :ASOF_DATE
                                THEN (f.COMMITTED_AMOUNT_PRIM + f.OBLIGATED_AMOUNT_PRIM +
                                       f.OTHER_AMOUNT_PRIM) ELSE 0  END)   FII_PSI_ENCUMBRANCES_A,
                       0                                                   FII_PSI_ACTUALS_A
                 FROM  fii_time_structures      cal,
                       fii_time_ent_period      t,
                       fii_gl_trend_sum_mv      f
                 WHERE f.time_id = cal.time_id
			AND   f.period_type_id = cal.period_type_id
			AND   bitand(cal.record_type_id,  256) = 256
			AND   cal.report_date  = t.end_date
                       '||l_company_security||l_cost_center_security||'
 			AND top_node_fin_cat_type = ''OE''
			AND   t.start_date >=  :CURR_PERIOD_START
			AND   t.end_date >=  :CURR_PERIOD_START
			AND   t.end_date <=  :CURR_PERIOD_END
                 GROUP BY t.ent_period_id, t.end_date

                 UNION ALL

                 SELECT t.ent_period_id                                   FII_PSI_PERIOD_ID,
			0                                                 FII_PSI_BUDGET_A,
			0                                                 FII_PSI_ENCUMBRANCES_A,
			SUM(f.PRIM_ACTUAL_G)                              FII_PSI_ACTUALS_A
                 FROM	fii_time_structures   cal,
			fii_time_ent_period     t,
			fii_gl_trend_sum_mv     f
                 WHERE	f.time_id = cal.time_id
			AND   f.period_type_id = cal.period_type_id
			AND   BITAND(cal.record_type_id, 256) = 256
			AND   cal.report_date  = t.end_date
                       '||l_company_security||l_cost_center_security||'
	                AND top_node_fin_cat_type = ''OE''
			AND   t.start_date >= :CURR_PERIOD_START
			AND   t.end_date >= :CURR_PERIOD_START
			AND   t.end_date < :ASOF_DATE
                 GROUP BY t.ent_period_id, t.end_date

                 UNION ALL

                 SELECT
                       t.ent_period_id                                  FII_PSI_PERIOD_ID,
                       FII_PSI_BUDGET_A                                 FII_PSI_BUDGET_A,
                       FII_PSI_ENCUMBRANCES_A                           FII_PSI_ENCUMBRANCES_A,
                       FII_PSI_ACTUALS_A                                FII_PSI_ACTUALS_A
                 FROM(
                       SELECT
                                 cal.report_date                             report_date,
                                 0                                      FII_PSI_BUDGET_A,
                                 0                                      FII_PSI_ENCUMBRANCES_A,
                                SUM(f.PRIM_ACTUAL_G)                   FII_PSI_ACTUALS_A
                       FROM     fii_time_structures   cal,
                                fii_gl_trend_sum_mv   f
                       WHERE	f.time_id = cal.time_id
				AND   f.period_type_id = cal.period_type_id
				AND   bitand(cal.record_type_id, 256) = 256
				AND   cal.report_date  = :ASOF_DATE
				'||l_company_security||l_cost_center_security||'
				 AND top_node_fin_cat_type = ''OE''
                       GROUP BY cal.report_date ) f1,
                                fii_time_ent_period  t
                       WHERE t.start_date >=  :CURR_PERIOD_START
                       AND   t.end_date >=  :ASOF_DATE
                       AND   t.end_date <= :CURR_PERIOD_END
                       ) f2,
                       fii_time_ent_period  t
                       WHERE	t.start_date >= :CURR_PERIOD_START
				AND   t.end_date >= :CURR_PERIOD_START
				AND   t.end_date <= :CURR_PERIOD_END
				AND   t.ent_period_id = f2.fii_psi_period_id(+)
                  GROUP	 BY t.ent_period_id, t.name
                  ORDER BY t.ent_period_id ASC';

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_mon_trend_sql,
                              p_bind_output_table => p_mon_trend_output);

END GET_MON_CUMUL_TREND;

END FII_PSI_MON_CUMUL_TREND_PKG;


/
