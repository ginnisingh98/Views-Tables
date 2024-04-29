--------------------------------------------------------
--  DDL for Package Body FII_GL_COST_CENTER_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_COST_CENTER_PKG2" AS
/* $Header: FIIGLC2B.pls 120.66 2006/04/22 00:23:57 mmanasse noship $ */

FUNCTION get_revexp_cc (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, l_fin_type IN VARCHAR2) return VARCHAR2
 IS

  revexp_cc_rec			        BIS_QUERY_ATTRIBUTES;
  sqlstmt                       VARCHAR2(32000);
  l_prior_or_budget             VARCHAR2(5000);
  l_hint			VARCHAR2(300);
  l_url				VARCHAR2(300);
  l_url2			VARCHAR2(300);
  l_dim_flag			VARCHAR2(1);
BEGIN

  fii_gl_util_pkg.reset_globals;
  fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_gl_util_pkg.get_bitmasks;
  fii_gl_util_pkg.g_fin_type := l_fin_type;
  fii_gl_util_pkg.get_viewby_sql;

  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
        l_prior_or_budget :='
                    (SUM(SUM(CY_ACTUAL)) over() - SUM(SUM(CY_BUDGET)) over()) /
             ABS(NULLIF(SUM(SUM(CY_BUDGET)) over(),0)) * 100   FII_ATTRIBUTE12,
                SUM(CY_BUDGET)                               FII_MEASURE3,';
  ELSE
        l_prior_or_budget :='
		(SUM(SUM(CY_ACTUAL)) over() - SUM(SUM(PY_ACTUAL)) over()) /
             ABS(NULLIF(SUM(SUM(PY_ACTUAL)) over(),0)) * 100   FII_ATTRIBUTE12,
                SUM(PY_ACTUAL)                               FII_MEASURE3, ';
  END IF;

  l_hint := '/*+ use_nl(f cat cal mgr per lob) ordered */';
  -- ----------------------------------------------------------------
  -- FII_MEASURE1 = Line of Business
  -- FII_MEASURE10 = Line of Business id (this is added for pass by id uptake)
  -- FII_MEASURE2,9 = Current amounts
  -- FII_MEASURE3 = Prior amounts
  -- FII_MEASURE5 = Forecast amounts
  -- FII_MEASURE7 = Budget amounts
  -- ----------------------------------------------------------------
  -- DEBUG: Why do we select same thing into FII_MEASURE2 and
  --        FII_MEASURE9? Both attribute codes should map to alias of
  --        FII_MEASURE2. Check original package.
  -- DEBUG: Note we cannot control order by in PMV anymore for these type of reports
  --        unless it's passed into the PLSQL table.  Need to raise as concern.

  fii_gl_util_pkg.get_lob_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;
  fii_gl_util_pkg.get_mgr_pmv_sql;

IF fii_gl_util_pkg.g_view_by = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
	l_dim_flag := fii_gl_util_pkg.g_mgr_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'LOB+FII_LOB' THEN
	l_dim_flag := fii_gl_util_pkg.g_lob_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
	l_dim_flag := fii_gl_util_pkg.g_fincat_is_leaf;
  ELSE
	l_dim_flag := 'Y';
  END IF;

  IF fii_gl_util_pkg.g_fin_type = 'R' THEN
	l_url := 'pFunctionName=FII_GL_REV_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_url2 := 'pFunctionName=FII_GL_REV_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&FII_DIM5=FII_MEASURE10&pParamIds=Y';
  ELSIF fii_gl_util_pkg.g_fin_type = 'OE' THEN
	l_url := 'pFunctionName=FII_GL_EXP_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_url2 := 'pFunctionName=FII_GL_EXP_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&FII_DIM5=FII_MEASURE10&pParamIds=Y';
  ELSIF fii_gl_util_pkg.g_fin_type = 'CGS' THEN
  	l_url := 'pFunctionName=FII_GL_COR_LOBMGRCC1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	l_url2 := 'pFunctionName=FII_GL_COR_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&FII_DIM5=FII_MEASURE10&pParamIds=Y';
  END IF;

IF fii_gl_util_pkg.g_mgr_id = -99999 then
        l_prior_or_budget :='
                NULL   FII_ATTRIBUTE12,
                NULL                               FII_MEASURE3,';
    sqlstmt := 'select NULL VIEWBY,
	NULL				FII_MEASURE1,
        NULL	                        FII_MEASURE10,
	NULL				VIEWBYID,
        NULL                                         FII_MEASURE2,
        NULL                                         FII_MEASURE9,
        NULL                                       FII_MEASURE5,
        NULL                                         FII_MEASURE7,
        NULL                                       FII_MEASURE11,
        NULL                             FII_ATTRIBUTE11,
        NULL                           FII_ATTRIBUTE13,
        NULL        FII_ATTRIBUTE14,'||l_prior_or_budget||'
        NULL                             FII_MEASURE12,
        NULL	FII_MEASURE14,
	NULL     FII_MEASURE15
        FROM dual where 1= 2';
ELSE

  sqlstmt := '
    select decode(:LOB_ID, f.viewby_id,decode('''||l_dim_flag||''',''Y'','||fii_gl_util_pkg.g_viewby_value||', '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG), '||fii_gl_util_pkg.g_viewby_value||') VIEWBY,
	to_number(NULL)				FII_MEASURE1,
        f.viewby_id	                        FII_MEASURE10,
	f.viewby_id				VIEWBYID,
        SUM(CY_ACTUAL)                                         FII_MEASURE2,
        SUM(CY_ACTUAL)                                         FII_MEASURE9,
        SUM(CY_FORECAST)                                       FII_MEASURE5,
        SUM(CY_BUDGET)                                         FII_MEASURE7,
        SUM(PY_SPER_END)                                       FII_MEASURE11,
        SUM(SUM(CY_ACTUAL)) over()                             FII_ATTRIBUTE11,
        SUM(SUM(CY_FORECAST)) over()                           FII_ATTRIBUTE13,
        (SUM(SUM(CY_FORECAST)) over() - SUM(SUM(PY_SPER_END)) over()) /
             ABS(NULLIF(SUM(SUM(PY_SPER_END)) over(),0)) * 100   FII_ATTRIBUTE14,'||l_prior_or_budget||'
          SUM(to_number(NULL))                             FII_MEASURE12,
	  DECODE(:LOB_ID, f.viewby_id, '''', '''||l_url||''')	FII_MEASURE14,
	DECODE(:LOB_ID, f.viewby_id, '''', '''||l_url2||''') FII_MEASURE15
    FROM	    '||fii_gl_util_pkg.g_viewby_from_clause||',
(select /*+ leading(cal) */  '||fii_gl_util_pkg.g_viewby_id||'    VIEWBY_ID,
                 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL,
                 SUM(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                          then f.forecast_g
                          else to_number(NULL) end)      CY_FORECAST,
                 SUM(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET,
		 to_number(NULL)			 PY_SPER_END,
		 to_number(NULL)			 PY_ACTUAL
          FROM   fii_time_rpt_struct cal
	  '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
          where  cal.report_date = &BIS_CURRENT_ASOF_DATE
          and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_cat_join||'
    and f.gid = 0
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by  '||fii_gl_util_pkg.g_viewby_id||'
          union all
          select /*+ leading(cal) */  '||fii_gl_util_pkg.g_viewby_id||'      VIEWBY_ID,
                 to_number(NULL)                         CY_ACTUAL,
                 to_number(NULL)                         CY_FORECAST,
                 to_number(NULL)                         CY_BUDGET,
		SUM(case when bitand(cal.record_type_id, :ENT_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_SPER_END,
		SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL
          FROM   fii_time_rpt_struct cal
	  '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
          where  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
	  and cal.time_id = f.time_id '||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_cat_join|| '
    and f.gid = 0
    and    cal.period_type_id     = f.period_type_id
    and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
    group  by '||fii_gl_util_pkg.g_viewby_id||')                               f
    where  '||fii_gl_util_pkg.g_viewby_join||'
    group  by '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id
    order by NVL(FII_MEASURE2, -9999999999) desc';
END IF;
	return sqlstmt;

END get_revexp_cc;

PROCEDURE get_exp_by_cat (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
			 exp_by_cat_sql out NOCOPY VARCHAR2,
			 exp_by_cat_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

   sqlstmt                VARCHAR2(32000);
   l_time_comp		  VARCHAR2(20);
   l_prior_or_budget      VARCHAR2(3000);
   l_hint		  VARCHAR2(300);
   l_url_summary         VARCHAR2(300);
   l_url_trend  VARCHAR2(300);

BEGIN
  fii_gl_util_pkg.reset_globals;
  fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_gl_util_pkg.g_view_by := 'FINANCIAL ITEM+GL_FII_FIN_ITEM';
  fii_gl_util_pkg.g_fin_type := 'OE';
  fii_gl_util_pkg.get_bitmasks;
  fii_gl_util_pkg.get_viewby_sql;
  fii_gl_util_pkg.get_mgr_pmv_sql;
  fii_gl_util_pkg.get_cat_pmv_sql;


  IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
	l_prior_or_budget :='
		(SUM(SUM(CY_ACTUAL)) over() - SUM(SUM(CY_BUDGET)) over()) /
             ABS(NULLIF(SUM(SUM(CY_BUDGET)) over(),0)) * 100   FII_ATTRIBUTE11,
                SUM(CY_BUDGET)                               FII_MEASURE3,';


  ELSE
	l_prior_or_budget :='
		 (SUM(SUM(CY_ACTUAL)) over() - SUM(SUM(PY_ACTUAL)) over()) /
             ABS(NULLIF(SUM(SUM(PY_ACTUAL)) over(),0)) * 100   FII_ATTRIBUTE11,
                SUM(PY_ACTUAL)                               FII_MEASURE3, ';
  END IF;

  l_url_summary := 'pFunctionName=FII_GL_EXP_LOBMGRCC1&FII_DIM7=FII_MEASURE9&VIEW_BY=VIEW_BY&pParamIds=Y';
  --drill across url on category column
  l_url_trend := 'pFunctionName=FII_GL_EXP_PER_TREND&VIEW_BY=TIME+FII_TIME_ENT_PERIOD&FII_DIM3=FII_MEASURE9&pParamIds=Y';
  --drill across url on XTD column

  l_hint := '/*+ ordered use_nl(cal) */';

  /******************************************************************
   * FII_MEASURE2 = Current amounts,  FII_MEASURE3 = Prior amounts  *
   * FII_MEASURE5 = Forecast amounts, FII_MEASURE7 = Budget amounts *
   ******************************************************************/

  IF fii_gl_util_pkg.g_mgr_id = -99999 THEN

  l_prior_or_budget :='NULL  FII_ATTRIBUTE11,
                       NULL  FII_MEASURE3, ';
  sqlstmt := 'select    NULL	 VIEWBY,
			NULL	 FII_MEASURE1,
			NULL	 FII_MEASURE9,
			NULL	 FII_MEASURE14,
 			NULL	 FII_MEASURE2,
			NULL	 FII_MEASURE5,
			NULL	 FII_MEASURE7,
			NULL	 FII_MEASURE11,
			NULL	 FII_ATTRIBUTE14,
			NULL	 FII_ATTRIBUTE13,
			NULL	 FII_ATTRIBUTE12,
			'||l_prior_or_budget||'
			NULL	 FII_MEASURE12,
			NULL	 FII_MEASURE13,
			NULL	 FII_MEASURE15
	     FROM	DUAL
	     WHERE	1=2';

		ELSE

sqlstmt := 'select
             cat_tl2.description				           VIEWBY,
             DECODE(f.viewby_id2 , f.viewby_id, '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG, '||fii_gl_util_pkg.g_viewby_value||') FII_MEASURE1,
             f.viewby_id		                                    FII_MEASURE9,
             f.viewby_id2		                                    FII_MEASURE14,
 		     SUM(CY_ACTUAL)                                     	FII_MEASURE2,
	         SUM(CY_FORECAST)                                       FII_MEASURE5,
	         SUM(CY_BUDGET)                                         FII_MEASURE7,
	         SUM(PY_SPER_END)                                       FII_MEASURE11,
	         SUM(SUM(CY_ACTUAL)) over()                             FII_ATTRIBUTE14,
	         (SUM(SUM(CY_FORECAST)) over() - SUM(SUM(CY_BUDGET)) over()) /
         	     NULLIF(SUM(SUM(CY_BUDGET)) over(),0) * 100      FII_ATTRIBUTE13,
		 SUM(SUM(CY_ACTUAL)) over() /
         	     NULLIF(SUM(SUM(CY_FORECAST)) over(),0) * 100    FII_ATTRIBUTE12,
                '||l_prior_or_budget||'SUM(to_number(NULL)) FII_MEASURE12,
                DECODE( f.viewby_id2 , f.viewby_id,  '''' , '''||l_url_summary||''' )	FII_MEASURE13,
                DECODE( f.viewby_id2 , f.viewby_id,  '''' , '''||l_url_trend||''' )	FII_MEASURE15
                /* Disable drills on the category and XTD column when parent category is same as child category */
    FROM
	    '||fii_gl_util_pkg.g_viewby_from_clause||',
	   fnd_flex_values_tl		             cat_tl2,
	   (select
		 '||fii_gl_util_pkg.g_viewby_id||'    VIEWBY_ID,
		 cat_hier.next_level_fin_cat_id	      VIEWBY_ID2,
                 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACTUAL,
                 SUM(case when bitand(cal.record_type_id, :FORECAST_PERIOD_TYPE) = cal.record_type_id
                          then f.forecast_g
                          else to_number(NULL) end)      CY_FORECAST,
                 SUM(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          then f.budget_g
                          else to_number(NULL) end)      CY_BUDGET,
		 to_number(NULL)			 PY_SPER_END,
		 to_number(NULL)			 PY_ACTUAL
          FROM   fii_time_rpt_struct cal,
	         fii_fin_item_hierarchies                    cat_hier
		  '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
          where  cal.report_date = &BIS_CURRENT_ASOF_DATE
          and    f.fin_category_id             = cat_hier.child_fin_cat_id
              and ( f.parent_fin_category_id = cat_hier.NEXT_LEVEL_FIN_CAT_ID or (cat_hier.next_level_is_leaf = ''Y''))
	          and   cat_hier.child_level <= 2 + cat_hier.parent_level
 		-- Modified join to fix bug 3562244. This join will let us pick up budgets and actuals that might
        -- be loaded at summary nodes
        	  and    cal.time_id = f.time_id
		  '||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join2||'
	          and    cal.period_type_id     = f.period_type_id
	          and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
	  group  by  cat_hier.next_level_fin_cat_id, '||fii_gl_util_pkg.g_viewby_id||'
          union all
          select '||fii_gl_util_pkg.g_viewby_id||'                 VIEWBY_ID,
		 cat_hier.next_level_fin_cat_id			   VIEWBY_ID2,
                 to_number(NULL)                         	   CY_ACTUAL,
                 to_number(NULL)                                   CY_FORECAST,
                 to_number(NULL)                                   CY_BUDGET,
		SUM(case when bitand(cal.record_type_id, :ENT_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_SPER_END,
		SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACTUAL
          FROM   fii_time_rpt_struct cal,
		 fii_fin_item_hierarchies        cat_hier
	  	'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
          where  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
		  and    f.fin_category_id             = cat_hier.child_fin_cat_id
              and ( f.parent_fin_category_id = cat_hier.NEXT_LEVEL_FIN_CAT_ID or (cat_hier.next_level_is_leaf = ''Y''))
	          and   cat_hier.child_level <= 2 + cat_hier.parent_level
        -- Modified join to fix bug 3562244. This join will let us pick up budgets and actuals that might
        -- be loaded at summary nodes
		  and    cal.time_id = f.time_id
                  '||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join2|| '
		  and    cal.period_type_id     = f.period_type_id
                  and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
 	  group  by cat_hier.next_level_fin_cat_id, '||fii_gl_util_pkg.g_viewby_id||')   f
    where  '||fii_gl_util_pkg.g_viewby_join||'
	   and    cat_tl2.flex_value_id = f.viewby_id2
	   and    cat_tl2.language = userenv(''LANG'')
    group  by cat_tl2.description, '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id, f.viewby_id2
    order by cat_tl2.description, '||fii_gl_util_pkg.g_viewby_value||', f.viewby_id';

    END IF;

	fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_by_cat_sql, exp_by_cat_output);


END get_exp_by_cat;

  -- Function
  --   get_exp_by_cat
  --
  -- Purpose
  -- 	Returns data for the Expense Summary by Category report.
  --
  -- History
  --   10-MAY-02  M Bedekar 	Created
  --
  --


PROCEDURE get_exp_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_cc_sql out NOCOPY VARCHAR2,
  exp_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_category VARCHAR2(2);
  sqlstmt        VARCHAR2(32000);
BEGIN

    l_fin_category := 'OE';

    sqlstmt := get_revexp_cc(p_page_parameter_tbl, l_fin_category );

    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, exp_cc_sql, exp_cc_output);

END get_exp_cc;

PROCEDURE get_rev_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_cc_sql out NOCOPY VARCHAR2,
  rev_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_category VARCHAR2(1);
  sqlstmt 	 VARCHAR2(32000);
BEGIN

    l_fin_category := 'R';

    sqlstmt := get_revexp_cc(p_page_parameter_tbl, l_fin_category );

    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rev_cc_sql, rev_cc_output);


END get_rev_cc;

PROCEDURE get_cogs_cc (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cgs_cc_sql out NOCOPY VARCHAR2,
  cgs_cc_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  l_fin_category VARCHAR2(3);
  sqlstmt 	 VARCHAR2(32000);
BEGIN

    l_fin_category := 'CGS';

    sqlstmt := get_revexp_cc(p_page_parameter_tbl, l_fin_category );

    fii_gl_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, cgs_cc_sql, cgs_cc_output);

END get_cogs_cc;


PROCEDURE get_cont_marg(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  cont_marg_sql out NOCOPY VARCHAR2,
  cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, p_opera_marg IN Char DEFAULT 'N')  IS

  sqlstmt                       VARCHAR2(32000);
  l_prior_or_budget             VARCHAR2(10000);
  l_hint                        VARCHAR2(300);
  sqlstmt1                      VARCHAR2(5000);
  cy_act_exp_select		VARCHAR2(100) := NULL;
  l_prior			VARCHAR2(20) := NULL;
  l_record_type			VARCHAR2(20) := NULL;
  l_amt				VARCHAR2(20) :=	NULL;
  l_label			VARCHAR2(20) := NULL;
  cy_prior_exp_select		VARCHAR2(100) := NULL;
  l_subtractor			VARCHAR2(100) := NULL;
  l_subtractor2			VARCHAR2(100) := NULL;
  l_subtractor3			VARCHAR2(100) := NULL;
  l_subtractor4			VARCHAR2(100) := NULL;
  l_url				VARCHAR2(300) := NULL;
  l_dim_flag			VARCHAR2(1);

BEGIN
	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
	fii_gl_util_pkg.get_viewby_sql;
	fii_gl_util_pkg.get_lob_pmv_sql;
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_ccc_pmv_sql;

  IF p_opera_marg = 'Y' THEN
	fii_gl_util_pkg.g_fin_type := 'OM';
	l_url := 'pFunctionName=FII_GL_OPS_LOB_MGR1&FII_DIM8=FII_MEASURE6&VIEW_BY=VIEW_BY&pParamIds=Y';
  ELSE fii_gl_util_pkg.g_fin_type := 'GM';
	l_url := 'pFunctionName=FII_GL_MAR_LOB_MGR1&FII_DIM8=FII_MEASURE6&VIEW_BY=VIEW_BY&pParamIds=Y';
  END IF;

	fii_gl_util_pkg.get_cat_pmv_sql;

  -- since there is no weekly forecast, NULL will be returned if week period type is selected

    IF p_opera_marg = 'Y' THEN
	cy_act_exp_select := ' NVL(SUM(CY_ACT_EXP), 0)   FII_ATTRIBUTE3,';
	l_subtractor2 := '(NVL(SUM(SUM(CY_ACT_CGS)) over(), 0) + NVL(SUM(SUM(CY_ACT_EXP)) over(), 0))';
	l_subtractor3 := '(NVL(SUM(CY_ACT_CGS), 0) + NVL(SUM(CY_ACT_EXP), 0))';
    ELSE
	l_subtractor2 := ' NVL(SUM(SUM(CY_ACT_CGS)) over(), 0) ';
	l_subtractor3 := ' NVL(SUM(CY_ACT_CGS), 0) ';
    END IF;

    sqlstmt1 := ' NVL(SUM(CY_ACT_REV), 0) 	 FII_MEASURE2,
		  NVL(SUM(CY_ACT_CGS), 0)	 FII_MEASURE3, '||cy_act_exp_select||'
		  (NVL(SUM(CY_ACT_REV), 0) - '||l_subtractor3||')/
 			ABS(NULLIF(SUM(CY_ACT_REV), 0)) * 100 		FII_MEASURE11,
		  NVL(SUM(SUM(CY_ACT_REV)) over(), 0) - '||l_subtractor2||'	FII_ATTRIBUTE11,
		  (NVL(SUM(SUM(CY_ACT_REV)) over(), 0) - '||l_subtractor2||') /
              		ABS(NULLIF(SUM(SUM(CY_ACT_REV)) over(),0)) * 100 	FII_ATTRIBUTE12,';

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

	cy_prior_exp_select := 'NVL(SUM('||l_label||'), 0)				        FII_ATTRIBUTE4,';
	l_subtractor := '(NVL(SUM(SUM('||l_prior||'_EXP)) over(), 0) + NVL(SUM(SUM('||l_prior||'_CGS)) over(), 0) )';
	l_subtractor4 := '(NVL(SUM('||l_prior||'_CGS), 0) + NVL(SUM('||l_prior||'_EXP), 0))';
  ELSE
	l_subtractor := 'NVL(SUM(SUM('||l_prior||'_CGS)) over(), 0)';
	l_subtractor4 := ' NVL(SUM('||l_prior||'_CGS), 0) ';

  END IF;

IF fii_gl_util_pkg.g_view_by = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
	l_dim_flag := fii_gl_util_pkg.g_mgr_is_leaf;
  ELSIF fii_gl_util_pkg.g_view_by = 'LOB+FII_LOB' THEN
	l_dim_flag := fii_gl_util_pkg.g_lob_is_leaf;
  ELSE
	l_dim_flag := 'Y';
  END IF;

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

   cy_prior_exp_select := 'NULL FII_ATTRIBUTE4,';
   cy_act_exp_select := ' NULL  FII_ATTRIBUTE3,';
   sqlstmt1 := ' NULL	 FII_MEASURE2,
		  NULL	 FII_MEASURE3, '||cy_act_exp_select||'
		  NULL	 FII_MEASURE11,
		  NULL	 FII_ATTRIBUTE11,
		  NULL   FII_ATTRIBUTE12,';
    sqlstmt := '
		select  NULL	VIEWBY,
			NULL	FII_MEASURE1,
			NULL	FII_MEASURE6,
			'||sqlstmt1||'
			NULL	FII_CAL1,
			NULL	FII_CAL2,
			'||cy_prior_exp_select||'
			NULL	FII_MEASURE4,
			NULL	FII_MEASURE5,
			NULL	ATTRIBUTE13,
			NULL	FII_ATTRIBUTE14,
			NULL    FII_ATTRIBUTE2,
			NULL	FII_MEASURE13,
			NULL	FII_MEASURE14

		FROM	DUAL
		WHERE	1=2 ';
    ELSE

    sqlstmt := '
    select decode(:LOB_ID, f.viewby_id,decode('''||l_dim_flag||''',''Y'','||fii_gl_util_pkg.g_viewby_value||', '||fii_gl_util_pkg.g_viewby_value||'||'''||' '||'''||:DIR_MSG), '||fii_gl_util_pkg.g_viewby_value||') VIEWBY,
	to_number(NULL) FII_MEASURE1,
      f.viewby_id			 FII_MEASURE6,
      '||sqlstmt1||'
      to_number(NULL)		FII_CAL1,
      to_number(NULL)		FII_CAL2,
      '||cy_prior_exp_select||'
      NVL(SUM('||l_prior||'_REV), 0)		FII_MEASURE4,
      NVL(SUM('||l_prior||'_CGS), 0)		FII_MEASURE5,
      ((NVL(SUM(SUM(CY_ACT_REV)) over(), 0) - '||l_subtractor2||') /
             		ABS(NULLIF(SUM(SUM(CY_ACT_REV)) over(),0)) -
	(NVL(SUM(SUM('||l_prior||'_REV)) over(), 0) - '||l_subtractor||') /
             		ABS(NULLIF(SUM(SUM('||l_prior||'_REV)) over(),0))) * 100 FII_ATTRIBUTE13,
       ((NVL(SUM(SUM(CY_ACT_REV)) over(), 0) - '||l_subtractor2||') - (NVL(SUM(SUM('||l_prior||'_REV)) over(), 0) - '||l_subtractor||')) /
             		ABS(NULLIF((NVL(SUM(SUM('||l_prior||'_REV)) over(), 0) - '||l_subtractor||'),0)) * 100	 FII_ATTRIBUTE14,
      SUM(to_number(NULL))            	FII_ATTRIBUTE2,
      (case when NVL(abs((NVL(SUM(CY_ACT_REV), 0) - '||l_subtractor3||')/
			ABS(NULLIF(SUM(CY_ACT_REV), 0)) * 100), 1000) > 999.9 THEN NULL WHEN NVL(abs((NVL(SUM('||l_prior||'_REV), 0) - '||l_subtractor4||')/
			ABS(NULLIF(SUM('||l_prior||'_REV), 0)) * 100), 1000) > 999.9 THEN NULL ELSE 0 END)	FII_MEASURE13,
	DECODE(NVL(:LOB_ID,-9999), f.viewby_id, '''', '''||l_url||''')	FII_MEASURE14
    FROM '||fii_gl_util_pkg.g_viewby_from_clause||',
    (select /*+ leading(cal) index(f FII_GL_MGMT_SUM_MV_N1) */ '||fii_gl_util_pkg.g_viewby_id||'		VIEWBY_ID,
	 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACT_REV,
		 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''OE''
                          then f.actual_g
                          else to_number(NULL) end)	 CY_ACT_EXP,
		 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end)      CY_ACT_CGS,
                 SUM(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''R''
			  then f.budget_g
                          else to_number(NULL) end)      CY_BUD_REV,
		 SUM(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''CGS''
			  then f.budget_g
                          else to_number(NULL) end) 	 CY_BUD_CGS,
		 SUM(case when bitand(cal.record_type_id, :BUDGET_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''OE''
			  then f.budget_g
                          else to_number(NULL) end)	 CY_BUD_EXP,
		 to_number(NULL)                         PY_ACT_REV,
		 to_number(NULL)			 PY_ACT_EXP,
		 to_number(NULL)			 PY_ACT_CGS,
		 to_number(NULL)			 PYPER_ACT_REV,
		 to_number(NULL)			 PYPER_ACT_CGS

	FROM fii_time_rpt_struct          cal,
	     fii_fin_cat_type_assgns	  assgns
	'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
	where   assgns.fin_category_id 	= f.fin_category_id
		'||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||'
		and    cal.time_id            = f.time_id
	        and    cal.period_type_id     = f.period_type_id
	        and    cal.report_date = &BIS_CURRENT_ASOF_DATE
	        and    bitand(cal.record_type_id, :WHERE_PERIOD_TYPE) = cal.record_type_id
      group  by '||fii_gl_util_pkg.g_viewby_id||'
      union all
      select /*+ leading(cal) index(f FII_GL_MGMT_SUM_MV_N1) */  '||fii_gl_util_pkg.g_viewby_id||'		VIEWBY_ID,
	 	 to_number(NULL)          	         CY_ACT_REV,
                 to_number(NULL)			 CY_ACT_EXP,
                 to_number(NULL)			 CY_ACT_CGS,
                 to_number(NULL)		         CY_BUD_REV,
		 to_number(NULL)			 CY_BUD_CGS,
		 to_number(NULL)			 CY_BUD_EXP,
		 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''R''
                          then f.actual_g
                          else to_number(NULL) end)      PY_ACT_REV,
		 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
                          and assgns.fin_cat_type_code = ''OE''
			  then f.actual_g
                          else to_number(NULL) end)	 PY_ACT_EXP,
		 SUM(case when bitand(cal.record_type_id, :ACTUAL_PERIOD_TYPE) = cal.record_type_id
			  and assgns.fin_cat_type_code = ''CGS''
                          then f.actual_g
                          else to_number(NULL) end) 	 PY_ACT_CGS,
                 to_number(NULL) 			 PYPER_ACT_REV,
                 to_number(NULL)			 PYPER_ACT_CGS

	FROM fii_time_rpt_struct          cal,
	     fii_fin_cat_type_assgns	  assgns
	'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_lob_from_clause||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
	where   assgns.fin_category_id = f.fin_category_id
		'||fii_gl_util_pkg.g_gid||fii_gl_util_pkg.g_lob_join||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||'
		and    cal.time_id            = f.time_id
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

  --* Procedure added by Ilavenil.
  --* Procedure is called by OPERATING MARGIN

PROCEDURE get_opera_marg(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  cont_marg_sql out NOCOPY VARCHAR2,
  cont_marg_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)  IS
Begin
    get_cont_marg(p_page_parameter_tbl, cont_marg_sql, cont_marg_output, 'Y');
End get_opera_marg;

END fii_gl_cost_center_pkg2;


/
