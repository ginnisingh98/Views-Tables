--------------------------------------------------------
--  DDL for Package Body FII_GL_REV_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_REV_PROD" AS
/* $Header: FIIGLRPB.pls 120.15 2005/07/18 06:27:56 hpoddar noship $ */

PROCEDURE get_rev_by_prod (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
rev_by_prod_sql out NOCOPY VARCHAR2, rev_by_prod_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

   sqlstmt                 VARCHAR2(10000);
   l_prod_join            VARCHAR2(200) := NULL;

BEGIN
	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.g_fin_type := 'R';
	fii_gl_util_pkg.get_mgr_pmv_sql;

  IF (fii_gl_util_pkg.g_prod_id is not NULL) and (upper(fii_gl_util_pkg.g_prod_id) <> upper('All')) THEN
    l_prod_join :='
       and   prod.parent_id          = &ITEM+ENI_ITEM_VBH_CAT';
  ELSE
    l_prod_join :='
       and   prod.top_node_flag       = ''Y''';
  END IF;

  /*****************************************************************************
   * FII_MEASURE1 = Lower Level Product
   * FII_CAL2 = Product id
   * FII_MEASURE2 = Current amounts
   * FII_MEASURE3 = Prior amounts
   * FII_MEASURE5 = Forecast amounts
   * FII_MEASURE6 = Current amounts for Pie Chart (a hidden column in the table)
   * FII_MEASURE9 = Grand Total of Current amounts
   * FII_MEASURE10 = Grand Total of Prior amounts
   * FII_MEASURE11 = Grand Total of Forecast amounts
   * FII_MEASURE12 = Budget amounts
   * FII_ATTRIBUTE2 = Prior Total amounts
   *****************************************************************************/
    IF fii_gl_util_pkg.g_mgr_id = -99999 THEN  /* Done for bug 3875336 */

sqlstmt := 'SELECT	NULL	FII_MEASURE1,
			NULL	FII_CAL2,
			NULL    FII_MEASURE2,
			NULL    FII_MEASURE3,
			NULL    FII_MEASURE5,
			NULL    FII_MEASURE6,
			NULL	FII_MEASURE12,
			NULL	FII_ATTRIBUTE2,
			NULL	FII_MEASURE9,
			NULL	FII_MEASURE10,
			NULL	FII_MEASURE11
	    FROM	DUAL
	    WHERE	1=2';

ELSE

sqlstmt := '
       select
         f.value 						FII_MEASURE1,
         f.id 							FII_CAL2,
         sum(CY_ACTUAL)                                         FII_MEASURE2,
         sum(PY_ACTUAL)	                                        FII_MEASURE3,
         sum(CY_FORECAST)                                       FII_MEASURE5,
	 sum(CY_ACTUAL)					        FII_MEASURE6,
	 sum(CY_BUDGET)						FII_MEASURE12,
	 sum(PY_SPER_END)					FII_ATTRIBUTE2,
	 sum(sum(CY_ACTUAL)) over()				FII_MEASURE9,
	 sum(sum(PY_ACTUAL)) over()				FII_MEASURE10,
	 sum(sum(CY_FORECAST)) over()				FII_MEASURE11
       from (select prod.value					VALUE,
		    prod.id					ID,
		    sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL,
                    sum(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                          then f.forecast_g
                          else to_number(NULL) end)      CY_FORECAST,
                    sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET,
                    to_number(NULL)                      PY_ACTUAL,
		    to_number(NULL)			 PY_SPER_END
	    from	    FII_TIME_RPT_STRUCT       cal,
            		    eni_item_vbh_nodes_v      prod,
		            fii_gl_prd_v'||fii_gl_util_pkg.g_global_curr_view||' f,
		            fii_fin_item_hierarchies       cat,
			    fii_cc_mgr_hierarchies      h
            where h.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
		  and h.emp_id = f.manager_id
		  and f.time_id = cal.time_id
                  and 	cat.parent_fin_cat_id  in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = ''R'' and TOP_NODE_FLAG = ''Y'')
     		  and   f.period_type_id      = cal.period_type_id
		  and   cat.child_fin_cat_id    = f.fin_category_id
		  and   f.product_category_id = prod.child_id'||l_prod_join||'
	          and   bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
	          and   cal.report_date = &BIS_CURRENT_ASOF_DATE
	    group by prod.value, prod.id

	union all

	select prod.value					VALUE,
	       prod.id					ID,
	       to_number(NULL)                         CY_ACTUAL,
               to_number(NULL)                         CY_FORECAST,
               to_number(NULL)                         CY_BUDGET,
               sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL,
	       sum(case when bitand(cal.record_type_id, :ENT_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_SPER_END
	 from	    FII_TIME_RPT_STRUCT       cal,
            		    eni_item_vbh_nodes_v      prod,
		            fii_gl_prd_v'||fii_gl_util_pkg.g_global_curr_view||' f,
		            fii_fin_item_hierarchies       cat,
			    fii_cc_mgr_hierarchies     h
         where    h.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
		  and h.emp_id = f.manager_id
		  and   f.time_id = cal.time_id
     		  and   f.period_type_id      = cal.period_type_id
		  and 	cat.parent_fin_cat_id   in (select fin_category_id from fii_fin_cat_type_assgns where FIN_CAT_TYPE_CODE = ''R'' and TOP_NODE_FLAG = ''Y'')
		  and   cat.child_fin_cat_id    = f.fin_category_id
		  and   f.product_category_id = prod.child_id'||l_prod_join||'
	          and   bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
	          and   cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	 group by prod.value, prod.id)	f
	 group by f.value, f.id
';

END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_by_prod_sql, rev_by_prod_output);

END get_rev_by_prod;

END fii_gl_rev_prod;

/
