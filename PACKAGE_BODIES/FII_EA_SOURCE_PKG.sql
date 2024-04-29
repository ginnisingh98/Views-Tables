--------------------------------------------------------
--  DDL for Package Body FII_EA_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_SOURCE_PKG" AS
/* $Header: FIIEASOURCEB.pls 120.3 2005/06/22 15:12:21 sajgeo noship $ */

---------------------------------------------------------------------------------
-- the get_exp_source procedure is called by Expense Source report.
-- It is a wrapper for get_rev_exp_source function.

PROCEDURE get_exp_source (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_exp_source_sql out NOCOPY VARCHAR2,
                         p_exp_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

is
l_multi_factor         NUMBER;
l_sqlstmt                VARCHAR2(15000);

BEGIN

-- in table fii_gl_je_summary_b, the expenses are negative numbers and
-- revenues are positive numbers. Hence in Expense Source report, the
-- numbers are multiplied by -1. In Revenue Source report, the numbers
-- are multiplied by +1.

l_multi_factor := -1;

l_sqlstmt := get_rev_exp_source (p_page_parameter_tbl => p_page_parameter_tbl,
                                 p_multi_factor => l_multi_factor);

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_exp_source_sql,
                              p_bind_output_table => p_exp_source_output);

END get_exp_source;

---------------------------------------------------------------------------------
-- the get_rev_source procedure is called by Revenue Source report.
-- It is a wrapper for get_rev_exp_source function.

PROCEDURE get_rev_source (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_rev_source_sql out NOCOPY VARCHAR2,
                         p_rev_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

 is
 l_multi_factor         NUMBER;
 l_sqlstmt                VARCHAR2(15000);

BEGIN
-- in table fii_gl_je_summary_b, the expenses are negative numbers and
-- revenues are positive numbers. Hence in Expense Source report, the
-- numbers are multiplied by -1. In Revenue Source report, the numbers
-- are multiplied by +1.

 l_multi_factor := 1;

l_sqlstmt := get_rev_exp_source (p_page_parameter_tbl => p_page_parameter_tbl,
                                 p_multi_factor => l_multi_factor);

fii_ea_util_pkg.bind_variable(p_sqlstmt => l_sqlstmt,
                              p_page_parameter_tbl => p_page_parameter_tbl,
                              p_sql_output => p_rev_source_sql,
                              p_bind_output_table => p_rev_source_output);

END get_rev_source;


---------------------------------------------------------------------------------
-- This is the main function which constructs the PMV sql.

FUNCTION get_rev_exp_source (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                             p_multi_factor IN NUMBER) return VARCHAR2
 IS

  get_rev_exp_source            BIS_QUERY_ATTRIBUTES;
  l_sqlstmt                       VARCHAR2(15000);

  l_ledger_where                VARCHAR2(500);
  l_fud1_where                VARCHAR2(240);
  l_fud2_where                VARCHAR2(240);
  l_curr_view                   VARCHAR2(4);
  l_ledger_id                   VARCHAR2(30);
  l_url_ap                      VARCHAR2(500);
  l_url_fa                      VARCHAR2(500);
  l_url_other                     VARCHAR2(500);
  l_url_common                  VARCHAR2(500);


BEGIN
-- initialization. Calling fii_ea_util_pkg APIs necessary for constructing
-- the PMV sql.

fii_ea_util_pkg.reset_globals;
fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);
l_ledger_where := fii_ea_util_pkg.get_ledger_for_detail;
l_fud1_where := fii_ea_util_pkg.get_fud1_for_detail;
l_fud2_where := fii_ea_util_pkg.get_fud2_for_detail;
l_curr_view :=  fii_ea_util_pkg.g_curr_view;
l_ledger_id := fii_ea_util_pkg.g_ledger_id;

-- ledger , fii_ledger_v is already joining to FII_SOURCE_LEDGER_GROUPS, FII_SLG_ASSIGNMENTS.
-- pslau: will review this code during perf testing

IF l_ledger_id = 'All' THEN
  l_ledger_where := '';
ELSE
  l_ledger_where := l_ledger_where;
end if;

-- constructing urls for drill-down reports. The drill-down reports depend on the FII_EA_COL_JE_SOURCE_CODE.
-- FII_EA_COL_JE_SOURCE_CODE is the look-up code which is based on the je_source.

l_url_common := '&FII_LEDGER=FII_EA_COL_LEDGER_ID&FII_CURRENCIES=FII_EA_COL_FUNC_CURRENCY&pParamIds=Y';

l_url_ap := 'pFunctionName=FII_EA_AP_TRAN&FII_EA_JE_SOURCE_GROUP=FII_EA_COL_JE_SOURCE_CODE'||l_url_common||'';
l_url_fa := 'pFunctionName=FII_EA_DPRN_EXP_MAJ'||l_url_common||'';
l_url_other := 'pFunctionName=FII_EA_JE_TRAN&FII_EA_JE_SOURCE_GROUP=FII_EA_COL_JE_SOURCE_CODE'||l_url_common||'';

-- A new look-up type named 'FII_EA_FUNCTIONAL_GROUP' is created and a bunch of look-up codes
-- are created thereunder. The look-up code value depends on the je_source value.

-- The Expense Source and Revenue Source reports are drill-down reports from Expense / Revenue Trend
-- by Account Detail reports for a specific company, cost-center and category. Hence in Expense / Revenue
-- Source reports - the company, cost-center and category parameters can never be 'All' .


l_sqlstmt:= '
   SELECT
               FII_EA_COL_LEDGER_ID,
               FII_EA_COL_LEDGER,
               FII_EA_COL_JOURNAL_SOURCE,
               FII_EA_COL_JE_SOURCE_CODE,
               FII_EA_COL_FUNC_CURRENCY,
               FII_EA_FUNC_AMT,
               FII_EA_XTD,
               FII_EA_GT_XTD,
               decode(FII_EA_COL_JOURNAL_SOURCE,''AP Translator'','''||l_url_ap||''', ''Payables'','''||l_url_ap||''',
                ''Assets'','''||l_url_fa||''', '''||l_url_other||''') FII_EA_FUNC_AMT_DRILL
   FROM  (SELECT
               sob.id                   FII_EA_COL_LEDGER_ID,
               sob.value                FII_EA_COL_LEDGER,
               jes.user_je_source_name  FII_EA_COL_JOURNAL_SOURCE,
               f.je_source              FII_EA_COL_JE_SOURCE_CODE,
               f.functional_currency    FII_EA_COL_FUNC_CURRENCY,
               '||p_multi_factor||' * sum(f.amount_b)         FII_EA_FUNC_AMT,
               '||p_multi_factor||' * sum(f.amount_g)         FII_EA_XTD,
               '||p_multi_factor||' * sum(sum(f.amount_g)) over()  FII_EA_GT_XTD,
               (rank () OVER (ORDER BY NLSSORT(sob.value, ''NLS_SORT= BINARY'') ASC
                                       nulls last)) - 1  rnk
        from fii_gl_je_summary_b'||l_curr_view||'  f,
             fii_ledger_v sob,
             fii_time_structures cal,
             gl_je_sources_tl jes
        where cal.report_date = :ASOF_DATE
        and bitand(cal.record_type_id, :ACTUAL_BITAND) = :ACTUAL_BITAND
        and cal.time_id = f.time_id
        and cal.period_type_id = f.period_type_id
        and sob.id = f.ledger_id
        and f.company_id = &FII_COMPANIES+FII_COMPANIES
        and f.cost_center_id = &ORGANIZATION+HRI_CL_ORGCC
        and f.fin_category_id =  &FINANCIAL ITEM+GL_FII_FIN_ITEM
        AND     f.je_source = jes.je_source_name
        and     jes.language =   userenv(''LANG'')
        '||l_ledger_where||l_fud1_where||l_fud2_where||'
        group by sob.id,
                 sob.value,
                 jes.user_je_source_name,
                 f.je_source,
                 f.functional_currency)
        WHERE ((rnk between &START_INDEX and &END_INDEX) or (&END_INDEX = -1))
        ORDER BY NLSSORT(FII_EA_COL_LEDGER, ''NLS_SORT= BINARY'') ASC,NLSSORT(FII_EA_COL_JOURNAL_SOURCE,''NLS_SORT= BINARY'') ASC,  FII_EA_XTD DESC, NLSSORT(FII_EA_COL_FUNC_CURRENCY, ''NLS_SORT= BINARY'') ASC nulls last';


RETURN l_sqlstmt;

end get_rev_exp_source;



END FII_EA_SOURCE_PKG;


/
