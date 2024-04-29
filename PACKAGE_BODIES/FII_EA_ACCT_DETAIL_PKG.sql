--------------------------------------------------------
--  DDL for Package Body FII_EA_ACCT_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_ACCT_DETAIL_PKG" AS
/* $Header: FIIEAACCDTLB.pls 120.4 2006/07/19 09:57:10 sajgeo noship $ */

---------------------------------------------------------------------------------
-- the get_cgs_trend_dtl procedure is called by Cost Of Goods Sold Trend by
-- Account Detai report.
-- It is a wrapper for get_rev_exp_trend_dtl.
PROCEDURE get_cgs_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_exp_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_exp_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
 l_fin_cat              VARCHAR2(10);
 l_sqlstmt              VARCHAR2(25000);
 l_calling_report       VARCHAR2(30); -- added for COGS Trend

BEGIN

-- In the table fii_gl_local_snap_f,  fin_cat_type_code is
-- and 'CGS' for Cost Of Goods Sold.

 l_fin_cat:= 'CGS';

l_sqlstmt := get_rev_exp_trend_dtl (p_page_parameter_tbl => p_page_parameter_tbl,
                                    p_fin_cat => l_fin_cat);

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_exp_trend_dtl_sql,
                              p_bind_output_table => p_exp_trend_dtl_output);

END get_cgs_trend_dtl;

---------------------------------------------------------------------------------
-- the get_exp_trend_dtl procedure is called by Expense Trend by Account Detai report.
-- It is a wrapper for get_rev_exp_trend_dtl.

PROCEDURE get_exp_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_exp_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_exp_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
 l_fin_cat              VARCHAR2(10);
 l_sqlstmt              VARCHAR2(25000);
 l_calling_report       VARCHAR2(30); -- added for COGS Trend

BEGIN

-- In the table fii_gl_local_snap_f,  fin_cat_type_code is 'OE' for expenses
-- and 'R' for revenue.

 l_fin_cat:= 'OE';


l_sqlstmt := get_rev_exp_trend_dtl (p_page_parameter_tbl => p_page_parameter_tbl,
                                    p_fin_cat => l_fin_cat);

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_exp_trend_dtl_sql,
                              p_bind_output_table => p_exp_trend_dtl_output);

END get_exp_trend_dtl;

---------------------------------------------------------------------------------
-- the get_rev_trend_dtl procedure is called by Revenue Trend by Account Detail report.
-- It is a wrapper for get_rev_exp_trend_dtl.

PROCEDURE get_rev_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_rev_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_rev_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
 l_fin_cat              VARCHAR2(10);
 l_sqlstmt              VARCHAR2(25000);

BEGIN

-- In the table fii_gl_local_snap_f,  fin_cat_type_code is 'OE' for expenses
-- and 'R' for revenue.

 l_fin_cat:= 'R';

l_sqlstmt := get_rev_exp_trend_dtl (p_page_parameter_tbl => p_page_parameter_tbl,
                                    p_fin_cat => l_fin_cat);

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_rev_trend_dtl_sql,
                              p_bind_output_table => p_rev_trend_dtl_output);

END get_rev_trend_dtl;

---------------------------------------------------------------------------------
-- This is the main function which constructs the PMV sql.

FUNCTION get_rev_exp_trend_dtl (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                                 p_fin_cat IN VARCHAR2) RETURN VARCHAR2
 IS

  get_rev_exp_trend_dtl         BIS_QUERY_ATTRIBUTES;
  l_sqlstmt                       VARCHAR2(25000);
  l_as_of_date                  DATE;
  l_page_period_type            VARCHAR2(100);

  l_company_id                  VARCHAR2(30);
  l_company_id_from             VARCHAR2(300);
  l_company_id_where            VARCHAR2(1000);

  l_cost_center_id              VARCHAR2(30);
  l_curr_view                   VARCHAR2(4);
  l_ledger_where                VARCHAR2(500);
  l_fin_category_id             VARCHAR2(30);
  l_fin_category_id_from        VARCHAR2(100);
  l_fin_category_id_where       VARCHAR2(240);

  l_fud1_where                  VARCHAR2(240);
  l_fud2_where                  VARCHAR2(240);

  l_months                      NUMBER;
  l_year_id                     NUMBER;
  l_sequence                    NUMBER;
  l_prior_year_id               NUMBER;
  xtd                           VARCHAR2(200);
  hist_amt1                     VARCHAR2(200);
  hist_amt2                     VARCHAR2(200);
  hist_amt3                     VARCHAR2(200);
  hist_amt4                     VARCHAR2(200);
  p_hist_amt1                   VARCHAR2(200);
  p_hist_amt2                   VARCHAR2(200);
  p_hist_amt3                   VARCHAR2(200);
  l_prior_year_sqlstmt            VARCHAR2(15000);

  l_period                      VARCHAR2(50);
  l_url_common                  VARCHAR2(200);
  l_url1                        VARCHAR2(500);
  l_url2                        VARCHAR2(500);
  l_url3                        VARCHAR2(500);
  l_url4                        VARCHAR2(500);
  l_url5                        VARCHAR2(500);
  l_as_of_date_2                VARCHAR2(50);
  l_previous_three_end_date     DATE;
  l_previous_two_end_date       DATE;
  l_previous_one_end_date       DATE;
  l_previous_three_end_date_2   VARCHAR2(50);
  l_previous_two_end_date_2     VARCHAR2(50);
  l_previous_one_end_date_2     VARCHAR2(50);
  l_child_cc_id                 NUMBER(15);
  l_child_company_id            NUMBER(15);
  l_having_clause               VARCHAR2(250);
  l_order                       VARCHAR2(500);
  l_order2                      VARCHAR2(2500);

BEGIN
-- initialization. Calling fii_ea_util_pkg APIs necessary for constructing
-- the PMV sql.

fii_ea_util_pkg.reset_globals;
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ea_util_pkg.get_rolling_period;
l_ledger_where := fii_ea_util_pkg.get_ledger_for_detail;
l_as_of_date := fii_ea_util_pkg.g_as_of_date;
l_page_period_type := fii_ea_util_pkg.g_page_period_type;
l_company_id := fii_ea_util_pkg.g_company_id;
l_cost_center_id := fii_ea_util_pkg.g_cost_center_id;
l_curr_view :=  fii_ea_util_pkg.g_curr_view;
l_fin_category_id := fii_ea_util_pkg.g_fin_category_id;
l_fud1_where := fii_ea_util_pkg.get_fud1_for_detail;
l_fud2_where := fii_ea_util_pkg.get_fud2_for_detail;

l_previous_three_end_date := fii_ea_util_pkg.g_previous_three_end_date;
l_previous_two_end_date := fii_ea_util_pkg.g_previous_two_end_date;
l_previous_one_end_date := fii_ea_util_pkg.g_previous_one_end_date;


-- order by clause
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
          l_order := p_page_parameter_tbl(i).parameter_value;
       END IF;
     END LOOP;
  END IF;


CASE
   WHEN (INSTR(l_order,'FII_EA_COL_COMPANY')>0 and INSTR(l_order,'ASC')>0) THEN
     l_order2 := 'NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_COL_COMPANY')>0 and INSTR(l_order,'DESC')>0) THEN
     l_order2 := 'NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') DESC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_COL_COST_CENTER')>0 and INSTR(l_order,'ASC')>0) THEN
     l_order2 := 'NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_COL_COST_CENTER')>0 and INSTR(l_order,'DESC')>0) THEN
     l_order2 := 'NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') DESC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_COL_FIN_CAT')>0 and INSTR(l_order,'ASC')>0) THEN
     l_order2 := 'NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_COL_FIN_CAT')>0 and INSTR(l_order,'DESC')>0) THEN
     l_order2 := 'NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') DESC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  sum(FII_EA_XTD) DESC';
   WHEN (INSTR(l_order,'FII_EA_XTD')>0 and INSTR(l_order,'ASC')>0) THEN
     l_order2 := 'sum(FII_EA_XTD) ASC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC';
   WHEN (INSTR(l_order,'FII_EA_XTD')>0 and INSTR(l_order,'DESC')>0) THEN
     l_order2 := 'sum(FII_EA_XTD) DESC,
                  NLSSORT(com_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(cc_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC,
                  NLSSORT(fin_flex.FLEX_VALUE_MEANING, ''NLS_SORT= BINARY'') ASC';
END CASE;


-- cost center dimension top node. l_child_cc_id will be used when
-- ((l_company_id <> 'All') AND (l_cost_center_id = 'All'))

SELECT dbi_hier_top_node_id INTO l_child_cc_id
FROM fii_financial_dimensions
WHERE DIMENSION_SHORT_NAME = 'HRI_CL_ORGCC';


-- company dimension top node. l_child_company_id will be used when
-- ((l_company_id = 'All') AND (l_cost_center_id <> 'All'))

SELECT dbi_hier_top_node_id INTO l_child_company_id
FROM fii_financial_dimensions
WHERE DIMENSION_SHORT_NAME = 'FII_COMPANIES';


-- from clauses and where clauses for different combinations of
-- Company and Cost center parameters

IF ((l_company_id <> 'All') AND (l_cost_center_id = 'All')) THEN
   l_company_id_from := ', fii_cost_center_grants ccg
                         , fii_company_hierarchies co_hier
                         , fii_cost_ctr_hierarchies cc_hier
                         , fii_com_cc_dim_maps ccom_map ';
   l_company_id_where := ' and co_hier.parent_company_id = :COMPANY_ID
                           and co_hier.child_company_id = ccom_map.parent_company_dim_id
                           and ccom_map.child_company_id = f.company_id
                           and ccg.user_id = fnd_global.user_id
                           and ccg.report_region_code = '''||fii_ea_util_pkg.g_region_code||'''
                           and cc_hier.parent_cc_id = ccg.cost_center_id
                           and cc_hier.child_cc_id = ccom_map.parent_cost_center_dim_id
                           and ccom_map.child_cost_center_id = f.cost_center_id';
ELSIF  ((l_company_id = 'All') AND (l_cost_center_id <> 'All')) THEN
   l_company_id_from := ', fii_company_grants fcg
                         , fii_company_hierarchies co_hier
                         , fii_cost_ctr_hierarchies cc_hier
                         , fii_com_cc_dim_maps ccom_map ';
   l_company_id_where := ' and fcg.user_id = fnd_global.user_id
                           and fcg.report_region_code = '''||fii_ea_util_pkg.g_region_code||'''
                           and co_hier.parent_company_id = fcg.company_id
                           and co_hier.child_company_id = ccom_map.parent_company_dim_id
                           and ccom_map.child_company_id = f.company_id
                           and cc_hier.parent_cc_id = :COST_CENTER_ID
                           and cc_hier.child_cc_id = ccom_map.parent_cost_center_dim_id
                           and ccom_map.child_cost_center_id = f.cost_center_id';
ELSIF  ((l_company_id <> 'All') AND (l_cost_center_id <> 'All')) THEN
   l_company_id_from := ', fii_company_hierarchies co_hier
                         , fii_cost_ctr_hierarchies cc_hier
                         , fii_com_cc_dim_maps ccom_map ';
   l_company_id_where := ' and co_hier.parent_company_id = :COMPANY_ID
                           and co_hier.child_company_id = ccom_map.parent_company_dim_id
                           and ccom_map.child_company_id = f.company_id
                           and cc_hier.parent_cc_id = :COST_CENTER_ID
                           and cc_hier.child_cc_id = ccom_map.parent_cost_center_dim_id
                           and ccom_map.child_cost_center_id = f.cost_center_id';
ELSIF  ((l_company_id = 'All') AND (l_cost_center_id =  'All')) THEN
   l_company_id_from := ', fii_company_grants fcg
                         , fii_cost_center_grants ccg
                         , fii_company_hierarchies co_hier
                         , fii_cost_ctr_hierarchies cc_hier
                         , fii_com_cc_dim_maps ccom_map ';
   l_company_id_where := ' and fcg.user_id = fnd_global.user_id
                           and fcg.report_region_code = '''||fii_ea_util_pkg.g_region_code||'''
                           and co_hier.parent_company_id = fcg.company_id
                           and fcg.user_id = ccg.user_id
                           and fcg.report_region_code = ccg.report_region_code
                           and co_hier.child_company_id = ccom_map.parent_company_dim_id
                           and ccom_map.child_company_id = f.company_id
                           and cc_hier.parent_cc_id = ccg.cost_center_id
                           and cc_hier.child_cc_id = ccom_map.parent_cost_center_dim_id
                           and ccom_map.child_cost_center_id = f.cost_center_id';
END IF;



-- from clauses and where clauses for category parameter

IF (l_fin_category_id IS NOT NULL AND l_fin_category_id <> 'All') THEN
   l_fin_category_id_from  := ', fii_full_fin_item_hiers fin_hier';
   l_fin_category_id_where := ' and fin_hier.parent_fin_cat_id = :FIN_CATEGORY_ID
                                and fin_hier.child_fin_cat_id = f.fin_category_id';
ELSE
   l_fin_category_id_from  := '';
   l_fin_category_id_where := '';
END IF;


-- constructing urls

CASE l_page_period_type

WHEN 'FII_TIME_ENT_YEAR' THEN
l_period := '&FII_TIME_ENT_QTR=TIME+FII_TIME_ENT_QTR';

WHEN 'FII_TIME_ENT_QTR'  THEN
l_period :=  '&FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD';

WHEN 'FII_TIME_ENT_PERIOD'  THEN
l_period :=  null;

END CASE;


l_as_of_date_2 := to_char(l_as_of_date,'DD/MM/YYYY');
l_previous_three_end_date_2 := to_char(l_previous_three_end_date,'DD/MM/YYYY');
l_previous_two_end_date_2 := to_char(l_previous_two_end_date,'DD/MM/YYYY');
l_previous_one_end_date_2 := to_char(l_previous_one_end_date,'DD/MM/YYYY');

IF p_fin_cat = 'R' THEN
    l_url_common := '&pFunctionName=FII_EA_REV_SOURCE&FII_COMPANIES=FII_EA_COL_COMPANY_ID&HRI_CL_ORGCC=FII_EA_COL_COST_CENTER_ID&GL_FII_FIN_ITEM=FII_EA_COL_FIN_CAT_ID&pParamIds=Y';
ELSIF p_fin_cat = 'CGS' THEN /* Done changes for COGS Trend By Acct. Dtl */
    l_url_common := '&pFunctionName=FII_PL_COGS_SOURCE&FII_COMPANIES=FII_EA_COL_COMPANY_ID&HRI_CL_ORGCC=FII_EA_COL_COST_CENTER_ID&GL_FII_FIN_ITEM=FII_EA_COL_FIN_CAT_ID&pParamIds=Y';
ELSE
    l_url_common := '&pFunctionName=FII_EA_EXP_SOURCE&FII_COMPANIES=FII_EA_COL_COMPANY_ID&HRI_CL_ORGCC=FII_EA_COL_COST_CENTER_ID&GL_FII_FIN_ITEM=FII_EA_COL_FIN_CAT_ID&pParamIds=Y';
END IF;

-- l_url1 for FII_EA_XTD_DRILL,
-- l_url2 for     FII_EA_HIST_COL1_DRILL,
-- l_url3 for     FII_EA_HIST_COL2_DRILL,
-- l_url4 for     FII_EA_HIST_COL3_DRILL,
-- l_url5 for     FII_EA_HIST_COL4_DRILL,

--  if period=year then  xtd = ytd and no drill-down on fii_ea_xtd column.

IF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
l_url1 := null;
ELSE
l_url1 := 'AS_OF_DATE='||l_as_of_date_2||l_url_common||'';
END IF;

-- if period=month then no rolling periods and no drill-downs on FII_EA_HIST_COLn columns

IF l_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
l_url2 := null;
l_url3 := null;
l_url4 := null;
l_url5 := null;
else
l_url2 := 'AS_OF_DATE='||l_previous_three_end_date_2||l_period||l_url_common||'';
l_url3 := 'AS_OF_DATE='||l_previous_two_end_date_2||l_period||l_url_common||'';
l_url4 := 'AS_OF_DATE='||l_previous_one_end_date_2||l_period||l_url_common||'';
l_url5 := 'AS_OF_DATE='||l_as_of_date_2||l_period||l_url_common||'';
end if;


-- l_having_clause  - to ignore records where all columns in the report for a
-- particular row are null.  If period_type = Month, only one column is
-- displayed. If th
IF l_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
  l_having_clause := ' HAVING (SUM(FII_EA_XTD) IS NOT NULL) ';
ELSE
  l_having_clause := ' HAVING (SUM(FII_EA_XTD) IS NOT NULL OR SUM(FII_EA_HIST_COL1) IS NOT NULL
                       OR SUM(FII_EA_HIST_COL2) IS NOT NULL OR SUM(FII_EA_HIST_COL3) IS NOT NULL
                       OR SUM(FII_EA_HIST_COL4) IS NOT NULL) ';
END IF;




-- begin year
-- Populating xtd and hist_amt4 columns in the report when period_type = Year

IF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN

	IF fii_ea_util_pkg.g_snapshot = 'Y' THEN
       		    xtd := 'G_YTD';
                    hist_amt4 := 'G_QTD';
	ELSE

-- to find the sequence of the month of as-of-date. Based on the sequence number
-- the  xtd and hist_amt4 columns of the report will be populated.
         	    SELECT  SEQUENCE INTO  l_months
           	    FROM fii_time_ent_period WHERE l_as_of_date  BETWEEN start_date AND end_date;

          	CASE  l_months
          	WHEN  12 THEN
             		xtd := 'G_YEAR';
             		hist_amt4 := 'G_QTR4';
          	WHEN  11 THEN
        	xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0) + NVL(G_QTR3,0) + NVL(G_MONTH10,0) + NVL(G_MONTH11,0)';
		hist_amt4 := 'NVL(G_MONTH10,0) + NVL(G_MONTH11,0)';
          	WHEN 10 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0) + NVL(G_QTR3,0) + NVL(G_MONTH10,0)';
             		hist_amt4 := 'G_MONTH10';
          	WHEN  9 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0) + NVL(G_QTR3,0)';
             		hist_amt4 := 'G_QTR3';
          	WHEN  8 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0) + NVL(G_MONTH7,0) + NVL(G_MONTH8,0)';
             		hist_amt4 := 'NVL(G_MONTH7,0) + NVL(G_MONTH8,0)';
          	WHEN  7 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0) + NVL(G_MONTH7,0)';
             		hist_amt4 := 'G_MONTH7';
          	WHEN  6 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_QTR2,0)';
             		hist_amt4 := 'G_QTR2';
          	WHEN  5 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_MONTH4,0) + NVL(G_MONTH5,0)';
             		hist_amt4 := 'NVL(G_MONTH4,0) + NVL(G_MONTH5,0)';
          	WHEN  4 THEN
             		xtd := 'NVL(G_QTR1,0) + NVL(G_MONTH4,0)';
             		hist_amt4 := 'G_MONTH4';
          	WHEN  3 THEN
             		xtd := 'G_QTR1';
             		hist_amt4 := 'G_QTR1';
          	WHEN  2 THEN
             		xtd := 'NVL(G_MONTH1,0) + NVL(G_MONTH2,0)';
             		hist_amt4 := 'NVL(G_MONTH1,0) + NVL(G_MONTH2,0)';
          	WHEN  1 THEN
             		xtd := 'G_MONTH1';
             		hist_amt4 := 'G_MONTH1';
          	END CASE;

	END IF;

-- Populating hist_amt1, hist_amt2 and  hist_amt3 columns in the report when period_type = Year
-- to find the sequence of the quarter of as-of-date. Based on the sequence number
-- the  hist_amt1, hist_amt2 and  hist_amt3 columns of the report will be populated.

	    SELECT ENT_YEAR_ID, SEQUENCE INTO l_year_id, l_sequence
	    FROM fii_time_ent_qtr WHERE l_as_of_date  BETWEEN start_date AND end_date;
	     CASE l_sequence
	     WHEN  4 THEN
         	hist_amt1 := 'G_QTR1';
         	hist_amt2 := 'G_QTR2';
         	hist_amt3 := 'G_QTR3';
         	p_hist_amt1 := null;
         	p_hist_amt2 := null;
         	p_hist_amt3 := null;
         	l_prior_year_id := 0;

            WHEN  3 THEN
         	hist_amt1 := null;
         	hist_amt2 := 'G_QTR1';
         	hist_amt3 := 'G_QTR2';
         	l_prior_year_id := l_year_id - 1;
         	p_hist_amt1 := 'G_QTR4';
         	p_hist_amt2 := null;
         	p_hist_amt3 := null;

           WHEN  2 THEN
         	hist_amt1 := null;
         	hist_amt2 := null;
         	hist_amt3 := 'G_QTR1';
         	l_prior_year_id := l_year_id - 1;
         	p_hist_amt1 := 'G_QTR3';
         	p_hist_amt2 := 'G_QTR4';
         	p_hist_amt3 := null;

	   WHEN  1 THEN
         	hist_amt1 := null;
         	hist_amt2 := null;
         	hist_amt3 := null;
         	l_prior_year_id := l_year_id - 1;
         	p_hist_amt1 := 'G_QTR2';
         	p_hist_amt2 := 'G_QTR3';
         	p_hist_amt3 := 'G_QTR4';

     	END CASE;

-- END -- period_type = YEAR

-- begin quarter
-- Populating xtd and hist_amt4 columns in the report when period_type = Quarter

ELSIF l_page_period_type = 'FII_TIME_ENT_QTR' THEN

   IF fii_ea_util_pkg.g_snapshot = 'Y' THEN
      xtd := 'G_QTD';
      hist_amt4 := 'G_MTD';
   ELSE
-- to find the sequence of the month of as-of-date. Based on the sequence number
-- the  xtd and hist_amt4 columns of the report will be populated.
        SELECT  SEQUENCE INTO  l_months
        FROM fii_time_ent_period WHERE l_as_of_date  BETWEEN start_date AND end_date;

      CASE l_months
         WHEN  12 THEN
             xtd := 'G_QTR4';
             hist_amt4 := 'G_MONTH12';
          WHEN  11 THEN
             xtd := 'NVL(G_MONTH10,0) + NVL(G_MONTH11,0)';
             hist_amt4 := 'G_MONTH11';
          WHEN  10 THEN
             xtd := 'G_MONTH10';
             hist_amt4 := 'G_MONTH10';
          WHEN  9 THEN
             xtd := 'G_QTR3';
             hist_amt4 := 'G_MONTH9';
          WHEN  8 THEN
             xtd := 'NVL(G_MONTH7,0) + NVL(G_MONTH8,0)';
             hist_amt4 := 'G_MONTH8';
          WHEN  7 THEN
             xtd := 'G_MONTH7';
             hist_amt4 := 'G_MONTH7';
          WHEN  6 THEN
             xtd := 'G_QTR2';
             hist_amt4 := 'G_MONTH6';
          WHEN  5 THEN
             xtd := 'NVL(G_MONTH4,0) + NVL(G_MONTH5,0)';
             hist_amt4 := 'G_MONTH5';
          WHEN  4 THEN
             xtd := 'G_MONTH4';
             hist_amt4 := 'G_MONTH4';
          WHEN  3 THEN
             xtd := 'G_QTR1';
             hist_amt4 := 'G_MONTH3';
          WHEN  2 THEN
             xtd := 'NVL(G_MONTH1,0) + NVL(G_MONTH2,0)';
             hist_amt4 := 'G_MONTH2';
          WHEN  1 THEN
             xtd := 'G_MONTH1';
             hist_amt4 := 'G_MONTH1';
          END CASE;

   END IF;

-- Populating hist_amt1, hist_amt2 and  hist_amt3 columns in the report when period_type = Quarter
-- to find the sequence of the quarter of as-of-date. Based on the sequence number
-- the  hist_amt1, hist_amt2 and  hist_amt3 columns of the report will be populated.

     SELECT ent_year_id, sequence INTO l_year_id, l_sequence
     FROM fii_time_ent_period WHERE l_as_of_date  BETWEEN start_date AND end_date;

    CASE l_sequence
     WHEN  3 then
         hist_amt1 := null;
         hist_amt2 := 'G_MONTH1';
         hist_amt3 := 'G_MONTH2';
         l_prior_year_id := l_year_id - 1;
         p_hist_amt1 := 'G_MONTH12';
         p_hist_amt2 := null;
         p_hist_amt3 :=  null;

     WHEN  2 then
         hist_amt1 :=  null;
         hist_amt2 := null;
         hist_amt3 := 'G_MONTH1';
         l_prior_year_id := l_year_id - 1;
         p_hist_amt1 := 'G_MONTH11';
         p_hist_amt2 := 'G_MONTH12';
         p_hist_amt3 := null;

     WHEN  1 then
         hist_amt1 := null;
         hist_amt2 := null;
         hist_amt3 := null;
         l_prior_year_id := l_year_id - 1;
         p_hist_amt1 := 'G_MONTH10';
         p_hist_amt2 := 'G_MONTH11';
         p_hist_amt3 := 'G_MONTH12';
     ELSE  -- 4 or more
         hist_amt1 := 'G_MONTH'||(l_sequence - 3);
         hist_amt2 := 'G_MONTH'||(l_sequence - 2);
         hist_amt3 := 'G_MONTH'||(l_sequence - 1);
         p_hist_amt1 := null;
         p_hist_amt2 := null;
         p_hist_amt3 := null;
         l_prior_year_id := 0;
     END CASE;


-- END  -- period_type = quarter

-- Populating xtd and rolling period columns in the report when period_type = Period

ELSIF  l_page_period_type = 'FII_TIME_ENT_PERIOD' THEN

-- to find the sequence of the month of as-of-date. Based on the sequence number
-- the  xtd column of the report will be populated.
      SELECT  sequence, ent_year_id  INTO  l_months, l_year_id
      FROM fii_time_ent_period WHERE l_as_of_date  BETWEEN start_date AND end_date;

  IF fii_ea_util_pkg.g_snapshot = 'Y' THEN
         xtd := 'G_MTD';
  ELSE
         xtd := 'G_MONTH'||l_months;

  END IF;

         l_prior_year_id := 0;
         hist_amt1 := null;
         hist_amt2 := null;
         hist_amt3 := null;
         hist_amt4 := null;
         p_hist_amt1 := null;
         p_hist_amt2 := null;
         p_hist_amt3 := null;

END IF; -- period_type - period

fii_ea_util_pkg.g_year_id := l_year_id;
fii_ea_util_pkg.g_prior_year_id := l_prior_year_id;

-- Constructing the sql when rolling periods extend to previous year

--  coded like SUM('||p_hist_amt1||'+0). Sometimes p_hist_amt1 can be null.
-- Then sum(null) will give sql error. To avoid this sql error, added +0


IF l_prior_year_id = 0 THEN
   l_prior_year_sqlstmt:= null;
ELSE
   l_prior_year_sqlstmt:=
    ' UNION ALL
        SELECT
               f.company_id                            FII_EA_COL_COMPANY_ID,
               f.cost_center_id                        FII_EA_COL_COST_CENTER_ID,
               f.fin_category_id                       FII_EA_COL_FIN_CAT_ID,
               TO_NUMBER(NULL)                         FII_EA_XTD,
               SUM(CASE WHEN ('||p_hist_amt1||'+0) = 0 THEN TO_NUMBER(NULL)
                   ELSE ('||p_hist_amt1||'+0)  END)         FII_EA_HIST_COL1,
               SUM(CASE WHEN ('||p_hist_amt2||'+0) = 0 THEN TO_NUMBER(NULL)
                   ELSE ('||p_hist_amt2||'+0)  END)         FII_EA_HIST_COL2,
               SUM(CASE WHEN ('||p_hist_amt3||'+0) = 0 THEN TO_NUMBER(NULL)
                   ELSE ('||p_hist_amt3||'+0)  END)         FII_EA_HIST_COL3,
               TO_NUMBER(NULL)                         FII_EA_HIST_COL4
         FROM
               fii_gl_local_snap_f'||l_curr_view||'  f
               '||l_company_id_from||l_fin_category_id_from||'
        WHERE	f.amount_type_code = ''A''
		AND f.year_id = :PRIOR_YEAR_ID
		AND f.fin_cat_type_code = '''||p_fin_cat||'''
	        '||l_company_id_where||l_fin_category_id_where||l_fud1_where||l_fud2_where||'
		'||l_ledger_where||'
        GROUP BY
                 f.company_id,
                 f.cost_center_id,
                 f.fin_category_id ';

END IF;

-- constructing the mail sql. The PMV engine executes this query.
-- The quary results populate the reports.

l_sqlstmt:= '
         SELECT
	        FII_EA_COL_COMPANY,
                FII_EA_COL_COMPANY_ID,
	        FII_EA_COL_COST_CENTER,
	        FII_EA_COL_COST_CENTER_ID,
                FII_EA_COL_FIN_CAT,
                FII_EA_COL_FIN_CAT_ID,
                FII_EA_COL_FIN_CAT_DESP,
     	        FII_EA_XTD,
                FII_EA_HIST_COL1,
                FII_EA_HIST_COL2,
                FII_EA_HIST_COL3,
                FII_EA_HIST_COL4,
     	        FII_EA_GT_XTD,
                FII_EA_GT_HIST_COL1,
                FII_EA_GT_HIST_COL2,
                FII_EA_GT_HIST_COL3,
                FII_EA_GT_HIST_COL4,
                 DECODE(FII_EA_XTD, NULL, NULL, '''||l_url1||''')      FII_EA_XTD_DRILL,
                 DECODE(FII_EA_HIST_COL1, NULL, NULL, '''||l_url2||''')      FII_EA_HIST_COL1_DRILL,
                 DECODE(FII_EA_HIST_COL2, NULL, NULL, '''||l_url3||''')      FII_EA_HIST_COL2_DRILL,
                 DECODE(FII_EA_HIST_COL3, NULL, NULL, '''||l_url4||''')      FII_EA_HIST_COL3_DRILL,
                 DECODE(FII_EA_HIST_COL4, NULL, NULL, '''||l_url5||''')      FII_EA_HIST_COL4_DRILL
         FROM (
          SELECT
	        com_flex.FLEX_VALUE_MEANING            FII_EA_COL_COMPANY,
                                	               FII_EA_COL_COMPANY_ID,
	        cc_flex.FLEX_VALUE_MEANING             FII_EA_COL_COST_CENTER,
	                                               FII_EA_COL_COST_CENTER_ID,
                fin_flex.FLEX_VALUE_MEANING            FII_EA_COL_FIN_CAT,
                                                       FII_EA_COL_FIN_CAT_ID,
    	        com_flex.DESCRIPTION||''.''||cc_flex.DESCRIPTION||''.''||fin_flex.DESCRIPTION
                                                       FII_EA_COL_FIN_CAT_DESP,
     	                    sum(FII_EA_XTD)                     FII_EA_XTD,
                            sum(FII_EA_HIST_COL1)               FII_EA_HIST_COL1,
                            sum(FII_EA_HIST_COL2)               FII_EA_HIST_COL2,
                            sum(FII_EA_HIST_COL3)               FII_EA_HIST_COL3,
                            sum(FII_EA_HIST_COL4)               FII_EA_HIST_COL4,
     	                    sum(sum(FII_EA_XTD)) over()         FII_EA_GT_XTD,
                            sum(sum(FII_EA_HIST_COL1)) over()   FII_EA_GT_HIST_COL1,
                            sum(sum(FII_EA_HIST_COL2)) over()   FII_EA_GT_HIST_COL2,
                            sum(sum(FII_EA_HIST_COL3)) over()   FII_EA_GT_HIST_COL3,
                            sum(sum(FII_EA_HIST_COL4)) over()   FII_EA_GT_HIST_COL4,
                       (rank () OVER (ORDER BY '||l_order2||' nulls last )) - 1  rnk
 	 FROM
         (SELECT
	       f.company_id                            FII_EA_COL_COMPANY_ID,
	       f.cost_center_id                        FII_EA_COL_COST_CENTER_ID,
               f.fin_category_id                       FII_EA_COL_FIN_CAT_ID,
     	       SUM(CASE WHEN ('||xtd||')=0 THEN TO_NUMBER(NULL)
                      ELSE ('||xtd||')  END)           FII_EA_XTD,
     	       SUM(CASE WHEN ('||hist_amt1||'+0) = 0 THEN TO_NUMBER(NULL)
                      ELSE ('||hist_amt1||'+0) END)    FII_EA_HIST_COL1,
     	       SUM(CASE WHEN ('||hist_amt2||'+0) = 0 THEN TO_NUMBER(NULL)
                      ELSE ('||hist_amt2||'+0) END)    FII_EA_HIST_COL2,
     	       SUM(CASE WHEN ('||hist_amt3||'+0) = 0 THEN TO_NUMBER(NULL)
                      ELSE ('||hist_amt3||'+0) END)    FII_EA_HIST_COL3,
     	       SUM(CASE WHEN ('||hist_amt4||'+0) = 0 THEN TO_NUMBER(NULL)
                      ELSE ('||hist_amt4||'+0) END)    FII_EA_HIST_COL4
 	 FROM
	       fii_gl_local_snap_f'||l_curr_view||'  f
               '||l_company_id_from||l_fin_category_id_from||'
	WHERE	f.amount_type_code = ''A''
		AND f.year_id = :YEAR_ID
		AND f.fin_cat_type_code = '''||p_fin_cat||'''
		'||l_company_id_where||l_fin_category_id_where||l_fud1_where||l_fud2_where||'
		'||l_ledger_where||'
	GROUP BY f.company_id,
                 f.cost_center_id,
                 f.fin_category_id
       '|| l_prior_year_sqlstmt||' )
	 ,fnd_flex_values_tl       com_flex
	 ,fnd_flex_values_tl       cc_flex
	 ,fnd_flex_values_tl       fin_flex
        WHERE FII_EA_COL_COMPANY_ID = com_flex.flex_value_id
	AND com_flex.language = userenv(''LANG'')
	AND FII_EA_COL_COST_CENTER_ID = cc_flex.flex_value_id
	AND cc_flex.language = userenv(''LANG'')
	AND FII_EA_COL_FIN_CAT_ID = fin_flex.flex_value_id
	AND fin_flex.language = userenv(''LANG'')
        group by
            com_flex.flex_value_meaning,
            FII_EA_COL_COMPANY_ID,
            cc_flex.flex_value_meaning,
            FII_EA_COL_COST_CENTER_ID,
            fin_flex.flex_value_meaning,
            FII_EA_COL_FIN_CAT_ID,
    	    com_flex.DESCRIPTION||''.''||cc_flex.DESCRIPTION||''.''||fin_flex.DESCRIPTION
        '||l_having_clause||'
        &ORDER_BY_CLAUSE  nulls last)
        WHERE ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))';


RETURN l_sqlstmt;

END get_rev_exp_trend_dtl;


END FII_EA_ACCT_DETAIL_PKG;


/
