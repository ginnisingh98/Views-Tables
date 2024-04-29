--------------------------------------------------------
--  DDL for Package Body FII_GL_PROFIT_AND_LOSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_PROFIT_AND_LOSS" AS
/* $Header: FIIGLPLB.pls 120.43 2006/03/27 12:13:50 hpoddar noship $ */



PROCEDURE GET_OPER_PROFIT1 (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
oper_profit_sql out NOCOPY VARCHAR2,
oper_profit_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  oper_profit_rec BIS_QUERY_ATTRIBUTES;
  sqlstmt                 VARCHAR2(32000);
  comp_amt		  VARCHAR2(500);

BEGIN
    fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.g_fin_type := 'OM';
	fii_gl_util_pkg.g_view_by := 'FINANCIAL ITEM+GL_FII_FIN_ITEM';
	fii_gl_util_pkg.get_viewby_sql;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_cat_pmv_sql;


      IF ('||fii_gl_util_pkg.g_time_comp||' = 'BUDGET') THEN

		comp_amt := 'SUM(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                                  and bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                                  then f.budget_g else 0 end) prior_amt';
      ELSE

		comp_amt := 'SUM(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                  and bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                                  then f.actual_g else 0 end) prior_amt';
      END IF;

             sqlstmt := '
             SELECT  decode(viewbytype, ''CGS'', :COG_MSG, ''OE'', :EXP_MSG, ''R'', :REV_MSG,viewby) VIEWBY,
                     sum(decode(viewbytype, ''CGS'',grand_total, curr_amt)) FII_MEASURE1,
                     sum(decode(viewbytype, ''CGS'',prior_grand_total, prior_amt)) FII_MEASURE2
                     from
                     (select oper.viewby, cat.fin_category_id viewby_id, cat.fin_cat_type_code viewbytype, oper.curr_amt, oper.prior_amt,
                      sum(case when cat.fin_cat_type_code =''R'' then oper.curr_amt else oper.curr_amt*(-1) end) over () grand_total,
                      sum(case when cat.fin_cat_type_code=''R'' then oper.prior_amt else oper.prior_amt*(-1) end) over () prior_grand_total
                      from
                             (SELECT  /*+ ordered (cal, f) */ '||fii_gl_util_pkg.g_viewby_value||' viewby,
			      tl.flex_value_id viewby_id,
                              SUM(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                                  and bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                                  then f.actual_g else 0 end) curr_amt,

                              '||comp_amt||'

                              FROM  FII_TIME_RPT_STRUCT      cal
				    '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||',' ||fii_gl_util_pkg.g_viewby_from_clause||'
                              WHERE f.time_id = cal.time_id
			      '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_gid||'
                              AND   f.period_type_id = cal.period_type_id
			      AND   (tl.flex_value_id = '||fii_gl_util_pkg.g_viewby_id||' OR
				     tl.flex_value_id = f.parent_fin_category_id)
			      AND   tl.language = '''||userenv('LANG')||'''
                              AND   BITAND(cal.record_type_id, :WHERE_PERIOD_TYPE)= cal.record_type_id
                              AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
                              GROUP BY '||fii_gl_util_pkg.g_viewby_value||', tl.flex_value_id
                              order by '||fii_gl_util_pkg.g_viewby_value||' desc) oper,
                                       (select fin_category_id, fin_cat_type_code from fii_fin_cat_type_assgns
					where top_node_flag = ''Y'' and fin_cat_type_code in (''R'', ''OE'', ''CGS'')) cat
                     where oper.viewby_id (+)= cat.fin_category_id)
		     group by decode(viewbytype, ''CGS'', :COG_MSG, ''OE'', :EXP_MSG, ''R'', :REV_MSG,viewby)';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, oper_profit_sql, oper_profit_output);

END get_oper_profit1;

PROCEDURE GET_OPER_PROFIT (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
oper_profit_sql out NOCOPY VARCHAR2,
oper_profit_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
  oper_profit_rec BIS_QUERY_ATTRIBUTES;
  sqlstmt                 VARCHAR2(32000);
  l_prior_or_budget1      VARCHAR2(1000);
  l_prior_or_budget2      VARCHAR2(1000);
  l_prior_or_budget3      VARCHAR2(4000);

BEGIN
    fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.g_fin_type := 'OM';
	fii_gl_util_pkg.g_view_by := 'HRI_PERSON+HRI_PER_USRDR_H';
	fii_gl_util_pkg.get_viewby_sql;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_cat_pmv_sql;

  -- when budget comparison type is selected, budget amount is used to calculate the change column
  -- in the KPI portlet; when year/year or sequential comparison type is selected, prior actual
  -- amount is used to calculate the change column in the KPI portlet
  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
        l_prior_or_budget1 :='NVL(sum(CY_BUDGET_REV), 0) 		FII_MEASURE2,
			      SUM(NVL(sum(CY_BUDGET_REV), 0)) OVER () 		FII_GRAND_TOTAL2,';

        l_prior_or_budget2 :='NVL(sum(CY_BUDGET_EXP), 0)		FII_MEASURE4,
			      SUM(NVL(sum(CY_BUDGET_EXP), 0)) OVER ()		FII_GRAND_TOTAL4,';

        l_prior_or_budget3 :='NULL		FII_MEASURE13,
			      (sum(NVL(sum(CY_BUDGET_REV),0)) over() - (sum(NVL(sum(CY_BUDGET_EXP),0)) over() + sum(NVL(sum(CY_BUDGET_CGS),0)) over() )) /
             		NULLIF(sum(sum(CY_BUDGET_REV)) over(),0)*100    FII_MEASURE10,
	NVL(sum(CY_BUDGET_REV), 0) - (NVL(sum(CY_BUDGET_EXP), 0) + NVL(sum(CY_BUDGET_CGS), 0))		FII_MEASURE6,
	SUM(NVL(sum(CY_BUDGET_REV), 0) - (NVL(sum(CY_BUDGET_EXP), 0) + NVL(sum(CY_BUDGET_CGS), 0))) OVER ()		FII_GRAND_TOTAL6';

  ELSE
        l_prior_or_budget1 :='NVL(sum(PY_ACTUAL_REV),0)		FII_MEASURE2,
			      SUM(NVL(sum(PY_ACTUAL_REV),0)) OVER ()		FII_GRAND_TOTAL2,';

        l_prior_or_budget2 :='NVL(sum(PY_ACTUAL_EXP),0)		FII_MEASURE4,
			      SUM(NVL(sum(PY_ACTUAL_EXP),0)) OVER ()		FII_GRAND_TOTAL4,';

        l_prior_or_budget3 :='NULL		FII_MEASURE13,
			 (sum(NVL(sum(PY_ACTUAL_REV),0)) over() - (sum(NVL(sum(PY_ACTUAL_EXP),0)) over() + sum(NVL(sum(PY_ACTUAL_CGS),0)) over() )) /
             		NULLIF(sum(sum(PY_ACTUAL_REV)) over(),0)*100    FII_MEASURE10,
			NVL(sum(PY_ACTUAL_REV),0) - (NVL(sum(PY_ACTUAL_EXP),0) + NVL(sum(PY_ACTUAL_CGS),0)) 		FII_MEASURE6,
			SUM(NVL(sum(PY_ACTUAL_REV),0) - (NVL(sum(PY_ACTUAL_EXP),0) + NVL(sum(PY_ACTUAL_CGS),0))) OVER () 		FII_GRAND_TOTAL6';

  END IF;

/* --------------- Mapping ----------------
 * manager                     VIEWBY
 * revenue_amount              FII_MEASURE1,
 * revenue_amount_previous     FII_MEASURE2,
 * expenses_amount             FII_MEASURE3,
 * expenses_amount_previous    FII_MEASURE4,
 * operating_income            FII_MEASURE5,
 * operating_income_previous   FII_MEASURE6
 */

    sqlstmt := '
             SELECT  '||fii_gl_util_pkg.g_viewby_value||'			  VIEWBY,
                     f.viewby_id				                  VIEWBYID,
		     NVL(sum(CY_ACTUAL_REV),0)                                    FII_MEASURE1,
		     SUM(NVL(sum(CY_ACTUAL_REV),0)) OVER ()                       FII_GRAND_TOTAL1,
		     NVL(sum(CY_ACTUAL_EXP),0)                                    FII_MEASURE3,
		     SUM(NVL(sum(CY_ACTUAL_EXP),0)) OVER ()                       FII_GRAND_TOTAL3,
        	     NULL							  FII_MEASURE14,
		     NVL(sum(CY_ACTUAL_REV),0) - (NVL(sum(CY_ACTUAL_EXP),0) + NVL(sum(CY_ACTUAL_CGS),0)) FII_MEASURE5,
		     SUM(NVL(sum(CY_ACTUAL_REV),0) - (NVL(sum(CY_ACTUAL_EXP),0) + NVL(sum(CY_ACTUAL_CGS),0))) OVER () FII_GRAND_TOTAL5,
		     (NVL(sum(sum(CY_ACTUAL_REV)) over(),0) - (NVL(sum(sum(CY_ACTUAL_EXP)) over(),0) + NVL(sum(sum(CY_ACTUAL_CGS)) over(),0) )) /
             		NULLIF(sum(sum(CY_ACTUAL_REV)) over(),0)*100	  FII_MEASURE9,
		     to_number(NULL)						  FII_MEASURE15,
		     to_number(NULL)						  FII_MEASURE16,
		     '||l_prior_or_budget1||'
                     '||l_prior_or_budget2||'
                     '||l_prior_or_budget3||'
             FROM
		   '||fii_gl_util_pkg.g_viewby_from_clause||',
		(select '||fii_gl_util_pkg.g_viewby_id||' viewby_id,
    		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL_REV,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''OE''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL_EXP,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL_CGS,
                 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and asgn.fin_cat_type_code = ''R''
			  then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET_REV,
		  sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and asgn.fin_cat_type_code = ''OE''
			  then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET_EXP,
		  sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and asgn.fin_cat_type_code = ''CGS''
			  then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET_CGS,
		 to_number(NULL)                         PY_ACTUAL_REV,
		 to_number(NULL)			 PY_ACTUAL_EXP,
		 to_number(NULL)			 PY_ACTUAL_CGS
                 FROM  FII_TIME_RPT_STRUCT                        cal,
		       FII_FIN_CAT_TYPE_ASSGNS                    asgn
		   '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||'
		 WHERE f.time_id = cal.time_id
	     '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||'
             '||fii_gl_util_pkg.g_gid||'
             AND   f.period_type_id = cal.period_type_id
             AND   BITAND(cal.record_type_id, :WHERE_PERIOD_TYPE)= cal.record_type_id
             AND   cal.report_date = &BIS_CURRENT_ASOF_DATE
	     AND   asgn.fin_category_id = f.fin_category_id
             GROUP BY '||fii_gl_util_pkg.g_viewby_id||'
		union all

		select '||fii_gl_util_pkg.g_viewby_id||' viewby_id,
		        to_number(NULL)				CY_ACTUAL_REV,
                to_number(NULL)				CY_ACTUAL_EXP,
                to_number(NULL)			    CY_ACTUAL_CGS,
                to_number(NULL)				CY_BUDGET_REV,
                to_number(NULL)				CY_BUDGET_EXP,
		        to_number(NULL)				CY_BUDGET_CGS,
        	sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL_REV,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''OE''
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL_EXP,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and asgn.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL_CGS
		 FROM  FII_TIME_RPT_STRUCT                        cal,
                FII_FIN_CAT_TYPE_ASSGNS                    asgn
		   '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||'
             WHERE f.time_id = cal.time_id
	     '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||'
             '||fii_gl_util_pkg.g_gid||'
             AND   f.period_type_id = cal.period_type_id
             AND   BITAND(cal.record_type_id, :ACT_WHERE_PERIOD_TYPE)= cal.record_type_id
             AND   cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	     AND   asgn.fin_category_id = f.fin_category_id
		GROUP BY '||fii_gl_util_pkg.g_viewby_id||')  f

	     WHERE '||fii_gl_util_pkg.g_viewby_join||'
             GROUP BY '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, oper_profit_sql, oper_profit_output);
END get_oper_profit;

PROCEDURE GET_REV_BY_CHANNEL (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_by_channel_sql out NOCOPY VARCHAR2, rev_by_channel_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
   rev_by_channel_rec     BIS_QUERY_ATTRIBUTES;
   sqlstmt                VARCHAR2(32000);

BEGIN
    fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
    fii_gl_util_pkg.get_bitmasks;



  /* --- Mapping -------
   * channel                     FII_ATTRIBUTE1,
   * revenue_amount              FII_MEASURE1,
   * revenue_amount_previous     FII_MEASURE2,
   * revenue_amount              FII_MEASURE4,
   * revenue_amount_previous     FII_MEASURE5,
   */

 IF fii_gl_util_pkg.g_mgr_id = -99999 THEN /* Done for bug 3875336 */

 sqlstmt := '

	SELECT	NULL	FII_ATTRIBUTE1,
		NULL    FII_MEASURE9,
		NULL    FII_MEASURE1,
		NULL    FII_MEASURE2,
		NULL    FII_MEASURE4,
		NULL    FII_MEASURE5,
		NULL	FII_MEASURE7,
		NULL	FII_MEASURE8
	FROM	DUAL
	WHERE	1=2';

ELSE

sqlstmt := '
      SELECT bsc.value                                        FII_ATTRIBUTE1,
             bsc.id                                           FII_MEASURE9,
	     sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                      then f.actual_g else 0 end)           FII_MEASURE1,
             sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                      then f.actual_g else 0 end)           FII_MEASURE2,
             sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                      then f.actual_g else 0 end)           FII_MEASURE4,
             sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                      then f.actual_g else 0 end)           FII_MEASURE5,
             sum(sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                      then f.actual_g else 0 end)) over() FII_MEASURE7,
             sum(sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                      then f.actual_g else 0 end)) over() FII_MEASURE8
      FROM   bis_sales_channels_v     bsc,
             fii_ar_rev_sum_v'|| fii_gl_util_pkg.g_global_curr_view ||'        f,
	     fii_cc_mgr_hierarchies   h,
             FII_TIME_RPT_STRUCT      cal
      where f.sales_channel_code = bsc.id
      and   h.mgr_id 	 	 =  &HRI_PERSON+HRI_PER_USRDR_H
      and   f.manager_id 	 =  h.emp_id
      and   f.time_id            = cal.time_id
      and   f.period_type_id     = cal.period_type_id
      and   bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE)= cal.record_type_id
      and   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
      group by bsc.value, bsc.id';

END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_by_channel_sql, rev_by_channel_output);

END GET_REV_BY_CHANNEL;

END fii_gl_profit_and_loss;

/
