--------------------------------------------------------
--  DDL for Package Body FII_GL_COST_CENTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_COST_CENTER_PKG" AS
/* $Header: FIIGLC1B.pls 120.108 2006/02/21 12:24:13 hpoddar noship $ */


PROCEDURE is_mgr_topnode ( l_mgr_id   IN NUMBER,
                           mgr_is_topnode OUT  NOCOPY VARCHAR2) IS


              mgr_level   NUMBER;


BEGIN
 select mgr_level into mgr_level from fii_cc_mgr_hierarchies where EMP_ID = l_mgr_id and DIRECT_ID = l_mgr_id and MGR_ID = l_mgr_id;
 if (mgr_level = 1) THEN
 mgr_is_topnode := 'Y';
 ELSE
 mgr_is_topnode := 'N';
 END IF;

 END is_mgr_topnode;

PROCEDURE get_exp_by_cat (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
			 l_fin_category IN VARCHAR2,
			 exp_by_cat_sql out NOCOPY VARCHAR2,
			 exp_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

   exp_by_cat_rec	  BIS_QUERY_ATTRIBUTES;
   sqlstmt                VARCHAR2(32000);
   l_mgr_viewby_value	  VARCHAR2(30);
   l_cat_viewby_value	  VARCHAR2(30);
   l_mgr_viewby_id	  VARCHAR2(30);
   l_cat_viewby_id	  VARCHAR2(30);
   l_mgr_join		  VARCHAR2(100);
   l_cat_join		  VARCHAR2(100);
   l_mgr_from_clause	  VARCHAR2(200);
   l_cat_from_clause	  VARCHAR2(200);

BEGIN

	fii_gl_util_pkg.g_fin_type := 'OE';
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
        fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_cat_pmv_sql;


  /******************************************************************
   * FII_MEASURE2 = Current amounts,  FII_MEASURE3 = Prior amounts  *
   * FII_MEASURE5 = Forecast amounts, FII_MEASURE7 = Budget amounts *
   ******************************************************************/

sqlstmt := '  select  value            VIEWBY,
	      	sum(CY_ACTUAL)           FII_MEASURE2,
       	      	sum(PY_ACTUAL)           FII_MEASURE3,
              	sum(CY_FORECAST)         FII_MEASURE5,
              	sum(CY_BUDGET)           FII_MEASURE7,
	      FROM
              (select '||fii_gl_util_pkg.g_viewby_id||'      ID,
		      '||fii_gl_util_pkg.g_viewby_value||'	 value,
                	sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id then f.actual_g else to_number(NULL) end)      CY_ACTUAL,
                 	sum(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id then f.forecast_g else to_number(NULL) end)      CY_FORECAST,
                 	sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id then f.budget_g else to_number(NULL) end)      CY_BUDGET,
                 	to_number(NULL)          PY_ACTUAL
          	from   fii_time_rpt_stuct   cal
                       '||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_mgr_from_clause||'
          where  cal.report_date = &BIS_CURRENT_ASOF_DATE
          and    cal.record_type_id = bitand(cal.record_type_id, :WHERE_PERIOD_TYPE)
          and    f.time_id = cal.time_id
          and    f.period_type_id = cal.period_type_id
          '||fii_gl_util_pkg.g_gid||'
	  '||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_mgr_join||'
          group by '||fii_gl_util_pkg.g_cat_viewby_id||'
          union all
          select '||fii_gl_util_pkg.g_cat_viewby_id||'                   ID,
		 '||fii_gl_util_pkg.g_viewby_value||'		 VALUE,
                 to_number(NULL)                         CY_ACTUAL,
                 to_number(NULL)                         CY_FORECAST,
                 to_number(NULL)                         CY_BUDGET,
                 sum(f.actual_g)                         PY_ACTUAL
          from   fii_time_rpt_stuct   cal
                 '||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_mgr_from_clause||'
          where  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
          and    cal.record_type_id = bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE)
          and    f.time_id = cal.time_id
          and    f.period_type_id = cal.period_type_id
          '||fii_gl_util_pkg.g_gid||'
	  '||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_mgr_join||'
          group by '||fii_gl_util_pkg.g_viewby_id||' )
group by  VALUE
order by  FII_MEASURE2 desc';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_by_cat_sql, exp_by_cat_output);

END get_exp_by_cat;

PROCEDURE get_te_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, te_cc_sql out NOCOPY VARCHAR2,
  te_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(32000);
BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'TE';

    sqlstmt := fii_gl_cost_center_pkg.get_revexp_cc(p_page_parameter_tbl);
    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, te_cc_sql, te_cc_output);
END get_te_cc;

PROCEDURE get_cogs_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_cc_sql out NOCOPY VARCHAR2,
  cogs_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(32000);
BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'CGS';

    sqlstmt := fii_gl_cost_center_pkg.get_revexp_cc(p_page_parameter_tbl);
    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, cogs_cc_sql, cogs_cc_output);
END get_cogs_cc;

PROCEDURE get_exp_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_cc_sql out NOCOPY VARCHAR2,
  exp_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  sqlstmt                       VARCHAR2(32000);
BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'OE';

    sqlstmt := fii_gl_cost_center_pkg.get_revexp_cc(p_page_parameter_tbl);
    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_cc_sql, exp_cc_output);
END get_exp_cc;

PROCEDURE get_rev_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_cc_sql out NOCOPY VARCHAR2,
  rev_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  sqlstmt                       VARCHAR2(32000);
BEGIN
    fii_gl_util_pkg.reset_globals;
    fii_gl_util_pkg.g_fin_type := 'R';
    sqlstmt := fii_gl_cost_center_pkg.get_revexp_cc(p_page_parameter_tbl);

  fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_cc_sql, rev_cc_output);

END get_rev_cc;

FUNCTION get_revexp_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) return VARCHAR2 IS

  sqlstmt                       VARCHAR2(32000);
  l_prior_or_budget             VARCHAR2(3000) := NULL;
  gt_cy_act 	      VARCHAR2(20);
  gt_py_act 	      VARCHAR2(200);
  gt_cy_fore 	      VARCHAR2(20);
  gt_cy_bud 	      VARCHAR2(200);
  gt_fore_act 	      VARCHAR2(20);
  gt_fore_bud 	      VARCHAR2(20);
  gt_fore_py	      VARCHAR2(20);
  gt_act_py	      VARCHAR2(20);
  l_url 	      VARCHAR2(300);
  l_url2	      VARCHAR2(300);



BEGIN

  fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_gl_util_pkg.get_bitmasks;


 IF fii_gl_util_pkg.g_fin_type = 'R' THEN

	 gt_cy_act := 'FII_MEASURE11';
	 gt_cy_fore := 'FII_CAL1';
	 gt_fore_act := 'FII_ATTRIBUTE13';
         gt_fore_bud := 'FII_ATTRIBUTE14';
	 gt_fore_py := 'FII_ATTRIBUTE12';
	 IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
	 gt_py_act := 'NULL  FII_MEASURE12,';
	 gt_cy_bud := 'NULL  FII_CAL2,';
	 ELSE
	  gt_py_act := 'sum(sum(PY_ACTUAL)) over()  FII_MEASURE12,';
	  gt_cy_bud := 'sum(sum(CY_BUDGET)) over()  FII_CAL2,';
	 END IF;

	 l_url := 'pFunctionName=FII_GL_REV_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	 l_url2 := 'pFunctionName=FII_GL_REV_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
 ELSIF (fii_gl_util_pkg.g_fin_type = 'OE' OR fii_gl_util_pkg.g_fin_type = 'TE') THEN
	 gt_cy_act := 'FII_ATTRIBUTE5';
	 gt_cy_fore := 'FII_ATTRIBUTE7';
	 gt_fore_act := 'FII_ATTRIBUTE1';
         gt_fore_bud := 'FII_ATTRIBUTE2';
	 gt_fore_py := 'FII_ATTRIBUTE12';
	 IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
	  gt_py_act := 'NULL  FII_ATTRIBUTE6,';
	  gt_cy_bud := 'NULL FII_ATTRIBUTE8,';
	  ELSE
	       IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
 			gt_py_act := 'sum(sum(CY_BUDGET)) over()  FII_ATTRIBUTE6,';
	       ELSE
			gt_py_act := 'sum(sum(PY_ACTUAL)) over()  FII_ATTRIBUTE6,';
	       END IF;
        gt_cy_bud := 'sum(sum(CY_BUDGET)) over()  FII_ATTRIBUTE8,';
	  END IF;

	 IF fii_gl_util_pkg.g_fin_type = 'OE' THEN
	 	l_url := 'pFunctionName=FII_GL_EXP_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_url2 := 'pFunctionName=FII_GL_EXP_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
	 ELSE
		l_url := 'pFunctionName=FII_GL_TE_EXP_LOB1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_url2 := 'pFunctionName=FII_GL_TE_EXP_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
	 END IF;
 ELSIF fii_gl_util_pkg.g_fin_type = 'CGS' THEN
	 gt_cy_act := 'FII_MEASURE11';
	 gt_cy_fore := 'FII_CAL1';
	 gt_fore_act := 'FII_ATTRIBUTE13';
	 gt_fore_bud := 'FII_ATTRIBUTE14';
	 gt_fore_py := 'FII_ATTRIBUTE12';
	 IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
		gt_py_act := 'NULL  FII_MEASURE12,';
		gt_cy_bud := 'NULL  FII_CAL2,';
	 ELSE
		gt_py_act := 'sum(sum(PY_ACTUAL)) over()  FII_MEASURE12,';
		gt_cy_bud := 'sum(sum(CY_BUDGET)) over()  FII_CAL2,';
	 END IF;

	 l_url := 'pFunctionName=FII_GL_COR_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	 l_url2 := 'pFunctionName=FII_GL_COR_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
 END IF;

 gt_act_py := NULL;

 --If comparison type is budget, series definition change.
  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN

        l_prior_or_budget :='(sum(sum(CY_ACTUAL)) over() - sum(sum(CY_BUDGET)) over()) /
				ABS(NULLIF(sum(sum(CY_BUDGET)) over(),0)) * 100     FII_ATTRIBUTE11,
				sum(CY_BUDGET)                         FII_MEASURE10,
				sum(CY_BUDGET)                         FII_MEASURE3';

  ELSE
        l_prior_or_budget := '(sum(sum(CY_ACTUAL)) over() - sum(sum(PY_ACTUAL)) over()) /
				ABS(NULLIF(sum(sum(PY_ACTUAL)) over(),0)) * 100     FII_ATTRIBUTE11,
				sum(PY_ACTUAL)                         FII_MEASURE10,
				sum(PY_ACTUAL)                         FII_MEASURE3';
  END IF;



  fii_gl_util_pkg.get_viewby_sql;
  fii_gl_util_pkg.get_mgr_pmv_sql;
  fii_gl_util_pkg.get_lob_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;
  fii_gl_util_pkg.get_ccc_pmv_sql;

  --code moved to FII_GL_UTIL_PKG
  --bug 5002238..to make it as bind variable

  /*IF fii_gl_util_pkg.g_view_by = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
	l_id := fii_gl_util_pkg.g_mgr_id;
	l_dim_flag := fii_gl_util_pkg.g_mgr_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'LOB+FII_LOB' THEN
	l_id := fii_gl_util_pkg.g_lob_id;
	l_dim_flag := fii_gl_util_pkg.g_lob_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
	l_id := fii_gl_util_pkg.g_fin_id;
	l_dim_flag := fii_gl_util_pkg.g_fincat_is_leaf;
  ELSE
	l_id := -9999;
	l_dim_flag := 'Y';
  END IF; */


 --Since we need to join to a different mv that is no longer
 --aggregated along management hierarchy, we re-construct the
 --final PMV select
  IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
  l_prior_or_budget :='NULL    FII_ATTRIBUTE11,
		       NULL    FII_MEASURE3,
		       NULL    FII_MEASURE10';

   sqlstmt := '
   select  NULL VIEWBY,
          NULL				               VIEWBYID,
        NULL                                       FII_MEASURE13,
        NULL                                       FII_MEASURE2,
        NULL                                    FII_MEASURE5,
        NULL                                         FII_MEASURE7,
	NULL				       FII_MEASURE9,
        NULL				       FII_ATTRIBUTE4,
        NULL                             '||GT_CY_ACT||',
        '||GT_PY_ACT||'
        NULL                           '||GT_CY_FORE||',
        '||GT_CY_BUD||'
        NULL  '||GT_FORE_ACT||',
        NULL  '||GT_FORE_BUD||',
        NULL   '||GT_FORE_PY||',
	'||l_prior_or_budget||',
	NULL	FII_MEASURE14,
	NULL	FII_MEASURE15,
   	NULL	FII_MEASURE16,
	NULL FII_MEASURE17,
	NULL FII_MEASURE18

	FROM DUAL
	WHERE 1=2 ';

	ELSE

	sqlstmt := '
   select  decode(:L_ID, f.viewby_id,decode(:DIM_FLAG,''Y'','||fii_gl_util_pkg.g_viewby_value||', '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG), '||fii_gl_util_pkg.g_viewby_value||') VIEWBY,
        f.viewby_id				               VIEWBYID,
        to_number(null)                                        FII_MEASURE13,
        sum(CY_ACTUAL)                                         FII_MEASURE2,
        sum(CY_FORECAST)                                       FII_MEASURE5,
        sum(CY_BUDGET)                                         FII_MEASURE7,
	sum(CY_ACTUAL)					       FII_MEASURE9,
        sum(PY_SPER_END)				       FII_ATTRIBUTE4,
        sum(sum(CY_ACTUAL)) over()                             '||GT_CY_ACT||',
        '||GT_PY_ACT||'
        sum(sum(CY_FORECAST)) over()                           '||GT_CY_FORE||',
        '||GT_CY_BUD||'
        sum(sum(CY_ACTUAL)) over() /
             NULLIF(sum(sum(CY_FORECAST)) over(),0) * 100   '||GT_FORE_ACT||',
        (sum(sum(CY_FORECAST)) over() - sum(sum(CY_BUDGET)) over()) /
            NULLIF(sum(sum(CY_BUDGET)) over(),0) * 100     '||GT_FORE_BUD||',
        (sum(sum(CY_FORECAST)) over() - sum(sum(PY_SPER_END)) over()) /
             ABS(NULLIF(sum(sum(PY_SPER_END)) over(),0)) * 100   '||GT_FORE_PY||','||l_prior_or_budget||',
	decode('||NVL(fii_gl_util_pkg.g_mgr_id, -9999)||', f.viewby_id, '''', '''||l_url||''')	FII_MEASURE14,
	decode('||NVL(fii_gl_util_pkg.g_fin_id, -9999)||', f.viewby_id, '''', '''||l_url||''')	FII_MEASURE15,
   	decode('||NVL(fii_gl_util_pkg.g_lob_id, -9999)||', f.viewby_id, '''', '''||l_url||''')	FII_MEASURE16,
	decode(:L_ID, f.viewby_id,decode(:DIM_FLAG,''Y'','''||l_url2||''',''''), '''||l_url2||''') FII_MEASURE17,
	decode(:L_ID, f.viewby_id,decode(:DIM_FLAG,''Y'','''||l_url2||''',''''), '''||l_url2||''') FII_MEASURE18
    from '||fii_gl_util_pkg.g_viewby_from_clause||',
	  (select /*+ leading(cal) */ '||fii_gl_util_pkg.g_viewby_id||'    VIEWBY_ID,
                 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL,
                 sum(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                          then f.forecast_g
                          else to_number(NULL) end)      CY_FORECAST,
                 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET,
                 to_number(NULL)                         PY_ACTUAL,
		 to_number(NULL)			 PY_SPER_END
          from   fii_time_rpt_struct cal
	  '||fii_gl_util_pkg.g_view||'
	  '||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
          where  cal.report_date = &BIS_CURRENT_ASOF_DATE
          and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_ccc_join||fii_gl_util_pkg.g_cat_join||'
    '||fii_gl_util_pkg.g_gid||'
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by  '||fii_gl_util_pkg.g_viewby_id||'
          union all
          select /*+ leading(cal) */ '||fii_gl_util_pkg.g_viewby_id||'      VIEWBY_ID,
                 to_number(NULL)                         CY_ACTUAL,
                 to_number(NULL)                         CY_FORECAST,
                 to_number(NULL)                         CY_BUDGET,
                 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL,
		sum(case when bitand(cal.record_type_id, :ENT_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_SPER_END
          from   fii_time_rpt_struct cal
          '||fii_gl_util_pkg.g_view||'
	  '||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
          where  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	  and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join|| '
    '||fii_gl_util_pkg.g_gid||'
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by '||fii_gl_util_pkg.g_viewby_id||' )       f
    where  '||fii_gl_util_pkg.g_viewby_join||'
    group  by '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id
    order by NVL(FII_MEASURE2, -999999999) desc';

     END IF;

  return sqlstmt;

END get_revexp_cc;


PROCEDURE get_exp_ccc_mgr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_ccc_mgr_sql out NOCOPY VARCHAR2,
  exp_ccc_mgr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(32000);
  l_prior_or_budget             VARCHAR2(3000) := NULL;


BEGIN

  fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_gl_util_pkg.get_bitmasks;
  fii_gl_util_pkg.g_fin_type := 'OE';

 --If comparison type is budget, series definition change.
  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN

        l_prior_or_budget :='(sum(sum(CY_ACTUAL)) over() - sum(sum(CY_BUDGET)) over()) /
             ABS(NULLIF(sum(sum(CY_BUDGET)) over(),0)) * 100     FII_ATTRIBUTE11,
		        sum(CY_BUDGET)                         FII_MEASURE3';

  ELSE
        l_prior_or_budget := '(sum(sum(CY_ACTUAL)) over() - sum(sum(PY_ACTUAL)) over()) /
             ABS(NULLIF(sum(sum(PY_ACTUAL)) over(),0)) * 100     FII_ATTRIBUTE11,
		        sum(PY_ACTUAL)                         FII_MEASURE3';
  END IF;

  fii_gl_util_pkg.g_view_by := 'ORGANIZATION+HRI_CL_ORGCC';
  fii_gl_util_pkg.get_viewby_sql;
  fii_gl_util_pkg.get_mgr_pmv_sql;
  fii_gl_util_pkg.get_lob_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;
  fii_gl_util_pkg.get_ccc_pmv_sql;


 --Since we need to join to a different mv that is no longer
 --aggregated along management hierarchy, we re-construct the
 --final PMV select


  sqlstmt := '
   select  '||fii_gl_util_pkg.g_viewby_value||' VIEWBY,
        f.viewby_id				               VIEWBYID,
	emp.value                                              FII_ATTRIBUTE14,
        to_number(null)                                        FII_MEASURE13,
        sum(CY_ACTUAL)                                         FII_MEASURE2,
        sum(CY_FORECAST)                                       FII_MEASURE5,
        sum(CY_BUDGET)                                         FII_MEASURE7,
	sum(CY_ACTUAL)					       FII_MEASURE9,
        sum(PY_SPER_END)				       FII_ATTRIBUTE4,
        sum(sum(CY_ACTUAL)) over()                             FII_ATTRIBUTE5,
        sum(sum(PY_ACTUAL)) over()  			       FII_ATTRIBUTE6,
        sum(sum(CY_FORECAST)) over()                           FII_ATTRIBUTE7,
        sum(sum(CY_BUDGET)) over()  			       FII_ATTRIBUTE8,
        sum(sum(CY_ACTUAL)) over() /
             NULLIF(sum(sum(CY_FORECAST)) over(),0) * 100      FII_ATTRIBUTE1,
        (sum(sum(CY_FORECAST)) over() - sum(sum(CY_BUDGET)) over()) /
             NULLIF(sum(sum(CY_BUDGET)) over(),0) * 100        FII_ATTRIBUTE2,
        (sum(sum(CY_FORECAST)) over() - sum(sum(PY_SPER_END)) over()) /
            ABS(NULLIF(sum(sum(PY_SPER_END)) over(),0)) * 100      FII_ATTRIBUTE12,'||l_prior_or_budget||'

    from '||fii_gl_util_pkg.g_viewby_from_clause||',
	 hri_cs_per_orgcc_ct ct,
    	 hri_dbi_cl_per_n_v emp,
	  (select '||fii_gl_util_pkg.g_viewby_id||'    VIEWBY_ID,
                 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL,
                 sum(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                          then f.forecast_g
                          else to_number(NULL) end)      CY_FORECAST,
                 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET,
                 to_number(NULL)                         PY_ACTUAL,
		 to_number(NULL)			 PY_SPER_END
          from   fii_time_rpt_struct cal
	  '||fii_gl_util_pkg.g_view||'
	  '||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
          where  cal.report_date = &BIS_CURRENT_ASOF_DATE
          and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_ccc_join||fii_gl_util_pkg.g_cat_join||'
    '||fii_gl_util_pkg.g_gid||'
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by  '||fii_gl_util_pkg.g_viewby_id||'
          union all
          select '||fii_gl_util_pkg.g_viewby_id||'      VIEWBY_ID,
                 to_number(NULL)                         CY_ACTUAL,
                 to_number(NULL)                         CY_FORECAST,
                 to_number(NULL)                         CY_BUDGET,
                 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL,
		sum(case when bitand(cal.record_type_id, :ENT_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_SPER_END
          from   fii_time_rpt_struct cal
          '||fii_gl_util_pkg.g_view||'
	  '||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
          where  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	  and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join|| '
    '||fii_gl_util_pkg.g_gid||'
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by '||fii_gl_util_pkg.g_viewby_id||' )       f
    where  '||fii_gl_util_pkg.g_viewby_join||'
	and     cc.ORGANIZATION_ID = ct.ORGANIZATION_ID
    	and     sysdate between emp.effective_start_date and emp.effective_end_date
    	and     emp.person_id = ct.CC_MNGR_PERSON_ID
    group  by '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id, substr(emp.first_name,1,1)' || '||''.''|| ' || 'emp.last_name
    &ORDER_BY_CLAUSE';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_ccc_mgr_sql, exp_ccc_mgr_output);


END get_exp_ccc_mgr;





PROCEDURE get_exp_cc_by_cat1 (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
exp_cc_by_cat1_sql out NOCOPY VARCHAR2, exp_cc_by_cat1_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, fin_type VARCHAR2)
 IS

   exp_cc_by_cat1_rec 	     BIS_QUERY_ATTRIBUTES;
   sqlstmt                   VARCHAR2(32000);
   l_time_parameter          VARCHAR2(100);
   l_bitmask		     NUMBER;
   l_cat_detail_url	     VARCHAR2(300);
   l_journal_src_url	     VARCHAR2(300);
   l_id			     NUMBER;

BEGIN

	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.g_view_by := 'FINANCIAL ITEM+GL_FII_FIN_ITEM';
    	fii_gl_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
	fii_gl_util_pkg.get_bitmasks;

	fii_gl_util_pkg.g_fin_type := fin_type;

	IF fii_gl_util_pkg.g_fin_type = 'R' THEN
		l_cat_detail_url := 'pFunctionName=FII_GL_REV_CAT3&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_journal_src_url:= 'pFunctionName=FII_GL_INV_REV_R&FII_DIM9=FII_MEASURE7&FII_DIM2=FII_MEASURE1&FII_DIM8=FII_MEASURE10&pParamIds=Y';
	ELSIF (fii_gl_util_pkg.g_fin_type = 'OE' ) THEN
		l_cat_detail_url := 'pFunctionName=FII_GL_EXP_CAT3&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_journal_src_url := 'pFunctionName=FII_GL_INV_EXP_R&FII_DIM9=FII_MEASURE7&FII_DIM2=FII_MEASURE1&FII_DIM8=FII_MEASURE10&pParamIds=Y';
	ELSIF fii_gl_util_pkg.g_fin_type = 'CGS' THEN
		l_cat_detail_url := 'pFunctionName=FII_GL_COR_CAT3&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_journal_src_url := 'pFunctionName=FII_GL_INV_COR_R&FII_DIM9=FII_MEASURE7&FII_DIM2=FII_MEASURE1&FII_DIM8=FII_MEASURE10&pParamIds=Y';
	END IF;




  fii_gl_util_pkg.get_viewby_sql;
  fii_gl_util_pkg.get_mgr_pmv_sql;
  fii_gl_util_pkg.get_lob_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;
  fii_gl_util_pkg.get_ccc_pmv_sql;

l_id := NVL(fii_gl_util_pkg.g_fin_id,-9999);

  select nvl(to_char(min(ent_period_id)),fii_gl_util_pkg.g_month_id) into l_time_parameter
  from fii_time_ent_period
  where fii_gl_util_pkg.g_as_of_date between start_date and end_date;

  IF (fii_gl_util_pkg.g_month_id <> l_time_parameter) THEN
	l_bitmask := 256;
  ELSE
	l_bitmask := 23;

  END IF;



  /******************************************************************
   * FII_MEASURE5 = Parent category -> NULL aftr bug 2797564        *
   * FII_MEASURE1 = Category id                                     *
   * FII_MEASURE6 = Manager id                                      *
   * FII_MEASURE7 = Month id                                        *
   * FII_MEASURE8 = Line of Business id                             *
   * FII_MEASURE9 = Currency id                                     *
   * FII_MEASURE10 = Cost Center id                                 *
   * FII_MEASURE2 = Current amounts                                 *
   * FII_MEASURE3 = Prior amounts                                   *
   ******************************************************************/
--we need to make sure that bug 2797564 is fixed


sqlstmt := ' select    '||fii_gl_util_pkg.g_viewby_value||'             VIEWBY,
			f.viewby_id	                    VIEWBYID,
          		NULL                                FII_MEASURE5,
          	        f.viewby_id	                    FII_MEASURE1,
	               :MGR_ID  		            FII_MEASURE6,
          	       :MONTH_ID			    FII_MEASURE7,
	               :LOB_ID 		                    FII_MEASURE8,
          	       :CURRENCY    			    FII_MEASURE9,
	               :CCC_ID  			    FII_MEASURE10,
	               sum(CY_ACTUAL)                       FII_MEASURE2,
                       sum(PY_ACTUAL)                       FII_MEASURE3,
decode((SELECT  is_leaf_flag
	FROM    fii_fin_item_hierarchies
	WHERE	parent_fin_cat_id = f.viewby_id
		and child_fin_cat_id = f.viewby_id),
		''Y'','''||l_journal_src_url||''',
		'''||l_cat_detail_url||''')		    FII_URL
		from   '||fii_gl_util_pkg.g_viewby_from_clause||',
			(select '||fii_gl_util_pkg.g_viewby_id||'         VIEWBY_ID,
				sum(f.actual_g)                           CY_ACTUAL,
				to_number(NULL)                           PY_ACTUAL
			from    fii_time_rpt_struct   cal
				'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
			where   cal.report_date = to_date(:P_AS_OF, ''DD-MM-YYYY'')
	/*Fix -- should be set dynamically*/
				and    cal.record_type_id = bitand(cal.record_type_id, '||l_bitmask||')
				and    f.time_id = cal.time_id
				and    f.period_type_id = cal.period_type_id
				'||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_ccc_mgr_join||'
				'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_ccc_join||'
			group by '||fii_gl_util_pkg.g_viewby_id||'
			union all
			select '||fii_gl_util_pkg.g_viewby_id||'        VIEWBY_ID,
				to_number(NULL)                         CY_ACTUAL,
				sum(f.actual_g)                         PY_ACTUAL
			from	fii_time_rpt_struct   cal
				'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
			where	cal.report_date = to_date(:P_PREV_AS_OF, ''DD-MM-YYYY'')
				and    cal.record_type_id = bitand(cal.record_type_id, '||l_bitmask||')
				and    f.time_id = cal.time_id
			        and    f.period_type_id = cal.period_type_id
			        '||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_ccc_mgr_join||'
				'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_ccc_join||'
			group by '||fii_gl_util_pkg.g_viewby_id||' )                         f
		where     '||fii_gl_util_pkg.g_viewby_join||'
		group by  '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id
		order by  '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id';

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_cc_by_cat1_sql, exp_cc_by_cat1_output);

  END get_exp_cc_by_cat1;
PROCEDURE get_rev_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_cc_by_cat_sql out NOCOPY VARCHAR2,
  rev_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(1);
BEGIN
    fii_gl_util_pkg.reset_globals;
    l_fin_type := 'R';
    fii_gl_cost_center_pkg.get_exp_cc_by_cat1(p_page_parameter_tbl, rev_cc_by_cat_sql, rev_cc_by_cat_output, l_fin_type );


END get_rev_cc_by_cat;

PROCEDURE get_exp_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_cc_by_cat_sql out NOCOPY VARCHAR2,
  exp_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(2);
BEGIN
    fii_gl_util_pkg.reset_globals;
    l_fin_type := 'OE';
    fii_gl_cost_center_pkg.get_exp_cc_by_cat1(p_page_parameter_tbl, exp_cc_by_cat_sql, exp_cc_by_cat_output, l_fin_type );


END get_exp_cc_by_cat;

PROCEDURE get_cogs_cc_by_cat (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_cc_by_cat_sql out NOCOPY VARCHAR2,
  cogs_cc_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(3);
BEGIN
    fii_gl_util_pkg.reset_globals;
    l_fin_type := 'CGS';
    fii_gl_cost_center_pkg.get_exp_cc_by_cat1(p_page_parameter_tbl, cogs_cc_by_cat_sql, cogs_cc_by_cat_output, l_fin_type );


END get_cogs_cc_by_cat;


  PROCEDURE get_revexp_tr(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  revexp_tr_sql out NOCOPY VARCHAR2, revexp_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, l_fin_type in VARCHAR2) IS

  revexp_tr_rec			BIS_QUERY_ATTRIBUTES;
  sqlstmt                       VARCHAR2(32000);
  l_hint1			VARCHAR2(200) := NULL;
  l_hint2			VARCHAR2(200) := NULL;
  l_join1                       VARCHAR2(100):= NULL;
  l_join2                       VARCHAR2(100):= NULL;
  l_join3                       VARCHAR2(100):= NULL;
  l_lyr                         DATE;
  l_llyr                         DATE;

BEGIN
  fii_gl_util_pkg.reset_globals;
  fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_gl_util_pkg.g_fin_type := l_fin_type;
  fii_gl_util_pkg.g_page_period_type := 'FII_TIME_ENT_PERIOD';
  fii_gl_util_pkg.get_bitmasks;
  fii_gl_util_pkg.get_mgr_pmv_sql;
  fii_gl_util_pkg.get_lob_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;
  fii_gl_util_pkg.get_ccc_pmv_sql;

   IF fii_gl_util_pkg.g_lob_is_top_node <> 'Y' AND fii_gl_util_pkg.g_lob_id IS NOT NULL THEN
	l_hint1 := '/*+ leading(per) use_nl(f) */';
	l_hint2 := '/*+ leading(cal) use_nl(f) */';
  END IF;

    SELECT  fii_time_api.ent_sd_lysper_end(fii_gl_util_pkg.g_as_of_date)
    INTO    l_lyr
    FROM    dual;

    IF l_lyr is NOT NULL THEN
       l_join1 := ' > to_date(:P_SD_LYR, ''DD-MM-YYYY'')';
       l_join3 := '= to_date(:P_SD_LYR, ''DD-MM-YYYY'')';
    ELSE
       l_join1 := ' >= to_date(:P_SD_LYR, ''DD-MM-YYYY'')';
       l_join3 := '< to_date(:P_SD_LYR, ''DD-MM-YYYY'')';
    END IF;

    SELECT fii_time_api.ent_sd_lysper_end(l_lyr)
    INTO   l_llyr
    FROM   dual;

    IF l_llyr is NOT NULL THEN
        l_join2 := '> to_date(:PPY_SAME_DAY, ''DD-MM-YYYY'')';
    ELSE
        l_join2 := '>= to_date(:PPY_SAME_DAY, ''DD-MM-YYYY'')';
    END IF;

  IF fii_gl_util_pkg.g_mgr_id = -99999 THEN /* Done for bug 3875336 */

  sqlstmt := '	SELECT	NULL                   VIEWBY,
			NULL                   FII_MEASURE1,
			NULL                   FII_MEASURE2,
			NULL                   FII_MEASURE3
		FROM	DUAL
		WHERE	1=2 ';

  ELSE

  sqlstmt := '
  select  cy_per.name                           VIEWBY,
          cy_per.ent_period_id                  FII_MEASURE1,
          inline_view.cy_ptot                   FII_MEASURE2,
          inline_view.py_ptot                   FII_MEASURE3
  from
    fii_time_ent_period cy_per,
    (select inner_inline_view.fii_effective_num  FII_EFFECTIVE_NUM,
            sum(CY_PTOT)                         CY_PTOT,
            sum(PY_PTOT)                         PY_PTOT
     from
		(select  '||l_hint1||' per.sequence                      FII_EFFECTIVE_NUM,
			 case when per.start_date '||l_join1||' and
				per.end_date  < to_date(:ASOF_DATE, ''DD-MM-YYYY'')
				then f.actual_g else to_number(NULL) end        CY_PTOT,
			 case when per.end_date < to_date(:P_SD_LYR, ''DD-MM-YYYY'')
			      then f.actual_g else to_number(NULL) end        PY_PTOT
		from    fii_time_ent_period      per
			'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
		where   per.ent_period_id = f.time_id
			'||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join||'
			'||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_ccc_mgr_join||'
			and    per.start_date '||l_join2||'
			and    per.end_date   < to_date(:ASOF_DATE, ''DD-MM-YYYY'')
			and    f.period_type_id       = 32
		union all
		select	'||l_hint2||' :CURR_EFFECTIVE_SEQ          FII_EFFECTIVE_NUM,
			case when cal.REPORT_DATE = to_date(:ASOF_DATE, ''DD-MM-YYYY'')
				then f.actual_g
				else to_number(NULL)
			end          CY_QTOT,
			case when cal.REPORT_DATE '||l_join3||'
				then f.actual_g
			else to_number(NULL)
			end          PY_QTOT
	       from   fii_time_rpt_struct    cal
		      '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
	       where  cal.time_id = f.time_id
		      '||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join||'
		      '||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_ccc_mgr_join||'
	              and    cal.period_type_id     = f.period_type_id
		      and    cal.report_date in (to_date(:ASOF_DATE, ''DD-MM-YYYY'') , to_date(:P_SD_LYR, ''DD-MM-YYYY''))
	              and    bitand(cal.record_type_id, 23) = cal.record_type_id) inner_inline_view
	      group by inner_inline_view.fii_effective_num ) inline_view
   where  cy_per.start_date <= to_date(:ASOF_DATE, ''DD-MM-YYYY'')
	  and   cy_per.start_date  >= to_date(:P_SD_LYR, ''DD-MM-YYYY'')
	  and   cy_per.sequence = inline_view.fii_effective_num (+)
   order by cy_per.start_date';

   END IF;

  fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, revexp_tr_sql, revexp_tr_output);

  END get_revexp_tr;

PROCEDURE get_rev_tr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_tr_sql out NOCOPY VARCHAR2,
  rev_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(1);
BEGIN
    l_fin_type := 'R';
    fii_gl_cost_center_pkg.get_revexp_tr(p_page_parameter_tbl, rev_tr_sql, rev_tr_output, l_fin_type );


END get_rev_tr;

PROCEDURE get_cogs_tr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_tr_sql out NOCOPY VARCHAR2,
  cogs_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(3);
BEGIN
    l_fin_type := 'CGS';
    fii_gl_cost_center_pkg.get_revexp_tr(p_page_parameter_tbl, cogs_tr_sql, cogs_tr_output, l_fin_type );


END get_cogs_tr;

PROCEDURE get_exp_tr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_tr_sql out NOCOPY VARCHAR2,
  exp_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(2);
BEGIN
    l_fin_type := 'OE';
    fii_gl_cost_center_pkg.get_revexp_tr(p_page_parameter_tbl, exp_tr_sql, exp_tr_output, l_fin_type );
END get_exp_tr;

PROCEDURE get_te_tr (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, te_tr_sql out NOCOPY VARCHAR2,
  te_tr_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_type VARCHAR2(2);
BEGIN
    l_fin_type := 'TE';
    fii_gl_cost_center_pkg.get_revexp_tr(p_page_parameter_tbl, te_tr_sql, te_tr_output, l_fin_type );

END get_te_tr;

  PROCEDURE get_cont_marg(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, p_opera_marg IN Char DEFAULT 'N') IS

  cont_marg_rec 		BIS_QUERY_ATTRIBUTES;
  sqlstmt                       VARCHAR2(32000);
  sqlstmt1                      VARCHAR2(5000);
  cy_act_exp_select		VARCHAR2(100) := NULL;
  l_prior			VARCHAR2(20) := NULL;
  l_record_type			VARCHAR2(20) := NULL;
  l_amt				VARCHAR2(20) :=	NULL;
  l_label			VARCHAR2(20) := NULL;
  cy_prior_exp_select		VARCHAR2(100) := NULL;
  l_subtractor2			VARCHAR2(100) := NULL;
  l_subtractor			VARCHAR2(100) := NULL;
  l_subtractor3			VARCHAR2(100) := NULL;
  l_subtractor4			VARCHAR2(100) := NULL;
  l_hint			VARCHAR2(100) := NULL;
  l_url				VARCHAR2(300) := NULL;
 -- l_id				NUMBER;
 -- l_dim_flag			VARCHAR2(1);

BEGIN

	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.get_viewby_sql;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_lob_pmv_sql;
	fii_gl_util_pkg.get_ccc_pmv_sql;

  IF p_opera_marg = 'Y' THEN
	fii_gl_util_pkg.g_fin_type := 'OM';
	l_url := 'pFunctionName=FII_GL_OPS_LOB_MGR1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
  ELSE fii_gl_util_pkg.g_fin_type := 'GM';
       l_url := 'pFunctionName=FII_GL_MAR_LOB_MGR1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
  END IF;

	fii_gl_util_pkg.get_cat_pmv_sql;


    IF p_opera_marg = 'Y' THEN
	cy_act_exp_select := ' NVL(sum(NVL(CY_ACT_EXP,0)), 0)   FII_ATTRIBUTE2,';
	l_subtractor := '(NVL(sum(sum(NVL(CY_ACT_CGS,0))) over(), 0) + NVL(sum(sum(NVL(CY_ACT_EXP,0))) over(), 0))';
	l_subtractor3 := '(NVL(sum(NVL(CY_ACT_CGS,0)), 0) + NVL(sum(NVL(CY_ACT_EXP,0)), 0))';
    ELSE
	l_subtractor := ' NVL(sum(sum(NVL(CY_ACT_CGS,0))) over(), 0) ';
	l_subtractor3 := ' NVL(sum(NVL(CY_ACT_CGS,0)), 0) ';
    END IF;

    sqlstmt1 := ' NVL(sum(CY_ACT_REV), 0) 	 FII_MEASURE2,
		  NVL(sum(CY_ACT_CGS), 0)	 FII_MEASURE3, '||cy_act_exp_select||'
		  (NVL(sum(CY_ACT_REV), 0) - '||l_subtractor3||')/
 			ABS(NULLIF(sum(CY_ACT_REV), 0)) * 100 		FII_MEASURE11,
		  NVL(sum(sum(CY_ACT_REV)) over(), 0) - '||l_subtractor||'	FII_ATTRIBUTE11,
		  (NVL(sum(sum(CY_ACT_REV)) over(), 0) - '||l_subtractor||') /
             		ABS(NULLIF(sum(sum(CY_ACT_REV)) over(),0)) * 100 	FII_ATTRIBUTE12,';

  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN

	l_prior := 'CY_BUD';
	l_record_type := ':BUDGET_PERIOD_TYPE';
	l_amt := 'actual_g';
	IF p_opera_marg = 'Y' THEN
		l_label := 'CY_BUD_EXP';
	END IF;

  ELSE

	l_prior := 'PY_ACT';
	l_record_type := ':ACTUAL_PERIOD_TYPE';
	l_amt := 'actual_g';
	IF p_opera_marg = 'Y' THEN
		l_label := 'PY_ACT_EXP';
	END IF;

  END IF;


  IF p_opera_marg = 'Y' THEN

	cy_prior_exp_select := 'NVL(sum('||l_label||'), 0)				        FII_ATTRIBUTE4,';
	l_subtractor2 := '(NVL(sum(sum(NVL('||l_prior||'_EXP,0))) over(), 0) + NVL(sum(sum(NVL('||l_prior||'_CGS,0))) over(), 0) )';
	l_subtractor4 := '(NVL(sum(NVL('||l_prior||'_CGS,0)), 0) + NVL(sum(NVL('||l_prior||'_EXP,0)), 0))';
  ELSE
	l_subtractor2 := 'NVL(sum(sum(NVL('||l_prior||'_CGS,0))) over(), 0)';
	l_subtractor4 := ' NVL(sum(NVL('||l_prior||'_CGS,0)), 0) ';
  END IF;

  --moved to fii_gl_util_pkg
    --added for bug fix 5002238
  --by vkazhipu
  --changing l_id and l_dim_flag to bind variables
  /*
  IF fii_gl_util_pkg.g_view_by = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
	l_id := fii_gl_util_pkg.g_mgr_id;
	l_dim_flag := fii_gl_util_pkg.g_mgr_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'LOB+FII_LOB' THEN
	l_id := fii_gl_util_pkg.g_lob_id;
	l_dim_flag := fii_gl_util_pkg.g_lob_is_leaf;
  ELSE
	l_id := -9999;
	l_dim_flag := 'Y';
  END IF;
  */

l_hint := '/*+ index(mgr.HRI_CS_SUPH, HRI_CS_SUPH_N5) use_nl(f cat cal mgr per lob lob2) ordered */';

  -- ----------------------------------------------------------------
  -- FII_MEASURE2 = Forecasted Rev amounts
  -- FII_MEASURE3 = Forecasted COR amounts
  -- FII_MEASURE4 = Prior Revenue amounts
  -- FII_MEASURE5 = Prior COR amounts
  -- FII_MEASURE1 = LOB name
  -- FII_CAL1 = Prior Total Revenue amounts
  -- FII_CAL2 = Prior Total COR amounts
  -- ----------------------------------------------------------------
    IF fii_gl_util_pkg.g_mgr_id = -99999 THEN
    cy_prior_exp_select := 'NULL  FII_ATTRIBUTE4,';
    cy_act_exp_select := '  NULL  FII_ATTRIBUTE2,';
    sqlstmt1 := ' NULL	 FII_MEASURE2,
		  NULL	 FII_MEASURE3, '||cy_act_exp_select||'
		  NULL	 FII_MEASURE11,
		  NULL	 FII_ATTRIBUTE11,
		  NULL	FII_ATTRIBUTE12,';
    sqlstmt := '
    SELECT	NULL VIEWBY,
		NULL		VIEWBYID,
		'||sqlstmt1||'
		NULL	FII_CAL1,
		NULL	FII_CAL2,
		'||cy_prior_exp_select||'
		NULL	FII_MEASURE4,
		NULL	FII_MEASURE5,
		NULL FII_ATTRIBUTE13,
		NULL FII_ATTRIBUTE14,
		NULL	 FII_MEASURE13,
		NULL	FII_MEASURE14,
		NULL	FII_MEASURE15

    FROM	DUAL
    WHERE	1=2 ';

	ELSE

	sqlstmt := '
    select decode(:L_ID, f.viewby_id,decode(:DIM_FLAG,''Y'','||fii_gl_util_pkg.g_viewby_value||', '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG), '||fii_gl_util_pkg.g_viewby_value||') VIEWBY,
      f.viewby_id		VIEWBYID,
      '||sqlstmt1||'
      to_number(NULL)	FII_CAL1,
      to_number(NULL)	FII_CAL2,
      '||cy_prior_exp_select||'
      NVL(sum('||l_prior||'_REV), 0)		FII_MEASURE4,
      NVL(sum('||l_prior||'_CGS), 0)		FII_MEASURE5,
      ( (NVL(sum(sum(NVL(CY_ACT_REV,0))) over(), 0) - '||l_subtractor||') /
             		ABS(NULLIF(sum(sum(NVL(CY_ACT_REV,0))) over(),0)) -
	(NVL(sum(sum(NVL('||l_prior||'_REV,0))) over(), 0) - '||l_subtractor2||') /
             		ABS(NULLIF(sum(sum(NVL('||l_prior||'_REV,0))) over(),0))) * 100 FII_ATTRIBUTE13,
	((NVL(sum(sum(NVL(CY_ACT_REV,0))) over(), 0) - '||l_subtractor||') -
(NVL(sum(sum(NVL('||l_prior||'_REV,0))) over(), 0) - '||l_subtractor2||')) /
ABS(NULLIF((sum(sum(NVL('||l_prior||'_REV,0))) over() - '||l_subtractor2||'),0)) * 100	 FII_ATTRIBUTE14,
	(case when NVL(abs((NVL(sum(CY_ACT_REV), 0) - '||l_subtractor3||')/
ABS(NULLIF(sum(CY_ACT_REV), 0)) * 100), 1000) > 999.9 THEN NULL WHEN NVL(abs((NVL(sum('||l_prior||'_REV), 0) - '||l_subtractor4||')/
ABS(NULLIF(sum('||l_prior||'_REV), 0)) * 100), 1000) > 999.9 THEN NULL ELSE 0 END)	 FII_MEASURE13,
	decode('||NVL(fii_gl_util_pkg.g_mgr_id, -9999)||', f.viewby_id, '''', '''||l_url||''')	FII_MEASURE14,
	decode('||NVL(fii_gl_util_pkg.g_lob_id, -9999)||', f.viewby_id, '''', '''||l_url||''')	FII_MEASURE15
    from '||fii_gl_util_pkg.g_viewby_from_clause||',
    (select '||fii_gl_util_pkg.g_viewby_id||'	VIEWBY_ID,
	 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACT_REV,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''OE''
                          then f.actual_g
                          else to_number(NULL) end)	CY_ACT_EXP,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACT_CGS,
                 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''R''
			  then f.budget_g
                          else to_number(NULL) end)	 CY_BUD_REV,
		 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''CGS''
			  then f.budget_g
                          else to_number(NULL) end)	 CY_BUD_CGS,
		 sum(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''OE''
			  then f.budget_g
                          else to_number(NULL) end)	 CY_BUD_EXP,
		 to_number(NULL)                         PY_ACT_REV,
		 to_number(NULL)			 PY_ACT_EXP,
		 to_number(NULL)			 PY_ACT_CGS,
		 to_number(NULL)			 PYPER_ACT_REV,
		 to_number(NULL)			 PYPER_ACT_CGS

	from fii_time_rpt_struct          cal,
	     fii_fin_cat_type_assgns	  assgns
	'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
	where   cal.time_id = f.time_id
		'||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join||'
		and    assgns.fin_category_id= f.fin_category_id
		'||fii_gl_util_pkg.g_gid||'
	        and    cal.period_type_id     = f.period_type_id
	        and    cal.report_date = &BIS_CURRENT_ASOF_DATE
	        and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
      group  by '||fii_gl_util_pkg.g_viewby_id||'
      union all
      select '||fii_gl_util_pkg.g_viewby_id||'		VIEWBY_ID,
	 	 to_number(NULL)          	         CY_ACT_REV,
                 to_number(NULL)			 CY_ACT_EXP,
                 to_number(NULL)			 CY_ACT_CGS,
                 to_number(NULL)		         CY_BUD_REV,
		 to_number(NULL)			 CY_BUD_CGS,
		 to_number(NULL)			 CY_BUD_EXP,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACT_REV,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''OE''
                          then f.actual_g
                          else to_number(NULL) end)			 PY_ACT_EXP,
		 sum(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end)	PY_ACT_CGS,
                 to_number(NULL) 			 PYPER_ACT_REV,
                 to_number(NULL) 			 PYPER_ACT_CGS

	from fii_time_rpt_struct          cal,
	     fii_fin_cat_type_assgns	  assgns
	'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||fii_gl_util_pkg.g_ccc_from_clause||'
	where   cal.time_id = f.time_id
		'||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||fii_gl_util_pkg.g_ccc_join||'
		and    assgns.fin_category_id = f.fin_category_id
	        '||fii_gl_util_pkg.g_gid||'
	        and    cal.period_type_id     = f.period_type_id
	        and    cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	        and    bitand(cal.record_type_id, :ACT_WHERE_PERIOD_TYPE) = cal.record_type_id
      group  by '||fii_gl_util_pkg.g_viewby_id||') f
 where '||fii_gl_util_pkg.g_viewby_join||'
 group  by '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id
 order by NVL(FII_MEASURE11, -9999999999) desc';

 END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, cont_marg_sql, cont_marg_output);

  END get_cont_marg;

  --* Procedure added by Ilavenil.  This procedure is called by OPERATING MARGIN.
  PROCEDURE get_opera_marg(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  cont_marg_sql out NOCOPY VARCHAR2, cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  Begin
    get_cont_marg(p_page_parameter_tbl, cont_marg_sql,  cont_marg_output, 'Y');
  End;

END fii_gl_cost_center_pkg;


/
