--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_ACT_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_ACT_DETAIL_PKG" AS
/* $Header: FIIARDBIRADB.pls 120.25.12000000.2 2007/04/09 20:23:04 vkazhipu ship $ */

-----------------------------------------------------------------
-- This procedure is called by the Receipts Activity Detail
-----------------------------------------------------------------
PROCEDURE get_rec_act_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_rec_act_detail_sql       OUT NOCOPY VARCHAR2,
   p_rec_act_detail_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_sqlstmt          VARCHAR2(25000);
  l_where_clause     VARCHAR2(2000);
  l_where_clause1    VARCHAR2(2000);
  l_dim_where_clause VARCHAR2(2000);
  l_dim_where_clause1 VARCHAR2(2000) := '1=1';
  l_from_table       VARCHAR2(1000);
  l_from_table1       VARCHAR2(1000);
  l_dim_from_table   VARCHAR2(1000);
  l_dim_from_table1  VARCHAR2(1000);
  l_currency         VARCHAR2(10);
  l_curr_suffix      VARCHAR2(6);
  l_industry_id      VARCHAR2(30);
  l_collector_id     VARCHAR2(30);
  l_cust_id          VARCHAR2(500);
  l_rct_num_url      VARCHAR2(500) := NULL;
  l_rct_amt_url      VARCHAR2(500) := NULL;
  l_rct_app_amt_url  VARCHAR2(500) := NULL;

  l_order_clause     VARCHAR2(500);
  l_order_column     VARCHAR2(100);
  l_order_null       VARCHAR2(100);
  l_order_by         VARCHAR2(500);
  l_source_report    VARCHAR2(30);
  l_gt_table_name    VARCHAR2(300)  := 'FII_AR_SUMMARY_GT v';
  l_gt_table_name1    VARCHAR2(300) := 'FII_AR_SUMMARY_GT v1';
  l_cust_acct_id     VARCHAR2(30);
  l_return_status    VARCHAR2(10);
  l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_unid_message VARCHAR2(30) := FND_MESSAGE.get_string('FII', 'FII_AR_UNID_CUSTOMER');
  l_index_hint VARCHAR2(240) := '';

BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  -- Retrieve values for global variables
  l_curr_suffix       := fii_ar_util_pkg.g_curr_suffix;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;
  l_industry_id       := fii_ar_util_pkg.g_industry_id;
  l_cust_acct_id      := fii_ar_util_pkg.g_cust_account_id;

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;


  -- Set the currency suffix for use in the amount columns
  IF (l_curr_suffix = '_p_v') THEN
    l_currency := '_prim';
  ELSIF (l_curr_suffix = '_s_v') THEN
    l_currency := '_sec';
  ELSIF (l_curr_suffix = '_f_v') THEN
    l_currency := '_func';
  END IF;

  -----------------------------------------------------------------------------
  -- Find out additional parameters pass into Receipt Activity Detail via URL:
  -- 1. Source report calling Receipt Details
 ------------------------------------------------------------------------------

  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF (p_page_parameter_tbl(i).parameter_name = 'BIS_FXN_NAME') THEN
        l_source_report := p_page_parameter_tbl(i).parameter_value;
      END IF;

    END LOOP;
  END IF;

  -----------------------------------------
  -- Construct the conditional where clause
  -----------------------------------------

  -- Only add the join on collector_id if we have a specific collector selected
  --Dimension queries are stored in variable l_dim_where_clause
  --THIS QUERY COMES IN THE OUTER PART AFTER FACT TABLE IS FILTERED
  --TWO WHERECLAUSES SINCE APP REC ACTIVITY DETAIL REPORT USES
  --FACT TABLE 3 TIMES

  IF (l_collector_id <> '-111') THEN

    l_dim_from_table   := l_dim_from_table  || ',fii_ar_dimensions_mv col ';
    l_dim_from_table1  := l_dim_from_table1 || ',fii_ar_dimensions_mv col1 ';

    l_dim_where_clause := l_dim_where_clause ||
                      ' AND fact.cust_account_id = col.cust_account_id
                        AND fact.collector_bill_to_site_use_id = col.site_use_id
                        AND fact.collector_id = col.collector_id';

    l_dim_where_clause1 := l_dim_where_clause1 ||
                      ' AND fact1.cust_account_id = col1.cust_account_id
                        AND fact1.collector_bill_to_site_use_id = col1.site_use_id
                        AND fact1.collector_id = col1.collector_id';

  END IF;


  IF (l_cust_acct_id <> '-111') THEN

    l_from_table   := l_from_table || '  fii_cust_accounts acct, ';
    l_from_table1  := l_from_table1 || ' fii_cust_accounts acct1, ';

    l_where_clause := l_where_clause ||
                      ' AND   f.collector_bill_to_customer_id = :CUST_ACCOUNT_ID
                        AND   f.collector_bill_to_customer_id= acct.cust_account_id
                        AND   v.party_id = :PARTY_ID
                        AND   v.party_id = acct.parent_party_id ';

    l_where_clause1 := l_where_clause1 ||
                      ' AND   f1.collector_bill_to_customer_id = :CUST_ACCOUNT_ID
                        AND   f1.collector_bill_to_customer_id = acct1.cust_account_id
                        AND   v1.party_id = :PARTY_ID
                        AND   v1.party_id = acct1.parent_party_id ';


  -- Only add the join on party_id when we have a specific customer selected
  -- and if customer account id is not present
  --if customer account id is present just bind customer account id and don't user customer id
  --since one customer account anyway belongs to one customer



  ELSIF (l_cust_id <> '-111') THEN

    l_from_table   := l_from_table || 'fii_cust_accounts acct, ';
    l_from_table1   := l_from_table1 || 'fii_cust_accounts acct1, ';

    l_index_hint := ' INDEX (acct fii_cust_accounts_n1)';

    l_where_clause := l_where_clause1 ||
                        ' AND f.collector_bill_to_Customer_id = acct.cust_account_id
                          AND acct.account_owner_party_id in ( :PARTY_ID )
                          AND acct.account_owner_party_id = acct.parent_party_id
                          AND v.party_id = :PARTY_ID ';

    l_where_clause1 := l_where_clause1 ||
                        ' AND f1.collector_bill_to_Customer_id = acct1.cust_account_id
                          AND acct1.account_owner_party_id in ( :PARTY_ID )
                          AND acct1.account_owner_party_id = acct1.parent_party_id
                          AND v1.party_id = :PARTY_ID ';



 END IF;

  -- Only add the join on class_category and class_code if we have a
  -- specific industry selected

  IF (l_industry_id <> '-111') THEN



    l_dim_from_table := l_dim_from_table ||
                    ' ,fii_party_mkt_class ind ';

    l_dim_from_table1 := l_dim_from_table1 ||
                    ' ,fii_party_mkt_class ind1 ';

    l_dim_where_clause := l_dim_where_clause ||
                        ' AND   ind.party_id          = fact.Account_Owner_Party_ID
                          AND   ind.class_category    = fact.class_category
                          AND   ind.class_code        = fact.class_code ';

    l_dim_where_clause1 := l_dim_where_clause1 ||
                        ' AND   ind1.party_id          = fact1.Account_Owner_Party_ID
                          AND   ind1.class_category    = fact1.class_category
                          AND   ind1.class_code        = fact1.class_code ';


  END IF;

-------------------------------
  -- Construct the drilldown URLs
  -------------------------------

  -- Receipt Number Drilldown URL
 IF (l_source_report = 'FII_AR_RCT_ACT_DTL') THEN
  l_rct_num_url :=  'pFunctionName=FII_AR_RCT_ACT_HISTORY&FII_AR_RCT_NUM=FII_AR_RCT_NUM'||
  '&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=FII_AR_RCT_CURRENCY'||
 '&BIS_PMV_DRILL_CODE_BIS_FII_CUSTOMER_ACCOUNT=''||cust_account_id||'''||
  '&FII_AR_CASH_RECEIPT_ID=FII_AR_CASH_RECEIPT_ID&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate'||
  '&pParamIds=Y';

    -- Receipt Amount Drilldown URL


  l_rct_amt_url := 'pFunctionName=FII_AR_RCT_BALANCES_DTL'||
  '&BIS_PMV_DRILL_CODE_BIS_FII_CUSTOMER_ACCOUNT=''||cust_account_id||'''||
  '&FII_AR_RCT_NUM=FII_AR_RCT_NUM'||
 '&FII_AR_CASH_RECEIPT_ID=FII_AR_CASH_RECEIPT_ID'||
  '&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=FII_AR_RCT_CURRENCY&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate'||
  '&pParamIds=Y';

 ELSE

   -- Receipt Number Drilldown URL

  l_rct_num_url :=  'pFunctionName=FII_AR_RCT_ACT_HISTORY&FII_AR_RCT_NUM=FII_AR_RCT_NUM'||
  '&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=FII_AR_RCT_CURRENCY'||
  '&BIS_PMV_DRILL_CODE_BIS_FII_CUSTOMER_ACCOUNT=''||cust_account_id||'''||
  '&FII_AR_CASH_RECEIPT_ID=FII_AR_CASH_RECEIPT_ID&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate'||
  '&pParamIds=Y';

   -- Receipt Amount Drilldown URL


   l_rct_amt_url := 'pFunctionName=FII_AR_RCT_BALANCES_DTL'||
 '&BIS_PMV_DRILL_CODE_BIS_FII_CUSTOMER_ACCOUNT=''||cust_account_id||'''||
 '&FII_AR_RCT_NUM=FII_AR_RCT_NUM'||
  '&FII_AR_CASH_RECEIPT_ID=FII_AR_CASH_RECEIPT_ID'||
  '&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=FII_AR_RCT_CURRENCY'||
  '&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y';

 END IF;




  ----------------------------------------------------------------
  -- Find out the sort order column and construct the order clause
  ----------------------------------------------------------------

  l_order_clause := fii_ar_util_pkg.g_order_by;

  -- Set the default order by clause for displaying NULL last when
  -- we sort in descending order

  IF (instr(l_order_clause, 'DATE') <> 0) THEN

    -- The sort column is a date column

    l_order_null := 'to_date(''0001/12/31'',''YYYY/MM/DD'')';

  ELSIF (instr(l_order_clause, 'NLSSORT') <> 0) THEN

    -- The sort column is a VARCHAR2 column

    l_order_null := 'NLSSORT(''000000000'', ''NLS_SORT=BINARY'')';

  ELSE
    -- The sort column is a numeric column

    l_order_null := '-999999999';

  END IF;

  -- Set the order by clause for the PMV sql

  IF (instr(l_order_clause, 'FII_AR_RCT_AMT_RCURR') <> 0) THEN

    -------------------------------------------------------------
    -- Special treatment for the Receipt Amount (Receipt Currency)
    -- column.  We should sort this as if it is a numeric column
    -- based on the receipt amount value.
    -------------------------------------------------------------

    IF (instr(l_order_clause, ' DESC') <> 0) THEN

      l_order_by := ' ORDER BY NVL(sum(receipt_amount), -999999999) DESC,
                               NVL(FII_AR_RCT_CURRENCY, NLSSORT(''000000000'',
                                   ''NLS_SORT=BINARY'')) DESC';
    ELSE
      l_order_by := ' ORDER BY NVL(sum(receipt_amount), -999999999) ASC,
                               NVL(FII_AR_RCT_CURRENCY, NLSSORT(''000000000'',
                                   ''NLS_SORT=BINARY'')) ASC';
    END IF;


  ELSIF ((instr(l_order_clause, ',') <> 0) AND

      (instr(l_order_clause, 'NLSSORT') = 0)) THEN

     -------------------------------------------------------------
     -- No particular sort column is selected in the report.  We'll
     -- sort on the default column in descending order.  NVL is
     -- added ot make sure NULL will appear last.
     -------------------------------------------------------------

     l_order_by := ' ORDER BY NVL(FII_AR_RCT_AMT, -999999999) DESC';

  ELSIF (instr(l_order_clause, ' DESC') <> 0) THEN

     -------------------------------------------------------------
     -- User has asked for a descending order sort.  We'll also
     -- make sure NULL will appear last with the default order clause.
     -------------------------------------------------------------

     l_order_column := substr(fii_ar_util_pkg.g_order_by, 1,
                              instr(l_order_clause, ' DESC'));
     l_order_by := ' ORDER BY NVL('|| l_order_column || ', '
                                   || l_order_null || ' ) DESC';

  ELSE

     -------------------------------------------------------------
     -- User has asked for an ascending order sort.  We should use
     -- PMV's order by clause
     -------------------------------------------------------------

     l_order_by := ' &ORDER_BY_CLAUSE';

  END IF;


  -------------------------------
  -- Construct the sql statements
  -------------------------------
 IF (l_source_report = 'FII_AR_RCT_ACT_DTL') THEN

  l_sqlstmt :=
    'SELECT FII_AR_RCT_ACCT_NUM,
            FII_AR_RCT_NUM,
            FII_AR_RCT_DATE,
            FII_AR_RCT_GL_DATE,
            FII_AR_RCT_PAY_METHOD,
            FII_AR_RCT_STATUS,
            to_char(sum(receipt_amount),''999,999,999,999'')|| '' '' || FII_AR_RCT_CURRENCY FII_AR_RCT_AMT_RCURR,
            sum(FII_AR_RCT_AMT) FII_AR_RCT_AMT ,
            sum(FII_AR_RCT_APP_AMT) FII_AR_RCT_APP_AMT,
            sum(FII_AR_RCT_EARNED_DCT) FII_AR_RCT_EARNED_DCT,
            sum(FII_AR_RCT_UNEARNED_DCT)FII_AR_RCT_UNEARNED_DCT ,
            sum(sum(FII_AR_RCT_AMT)) over() FII_AR_GT_RCT_AMT,
            sum(sum(FII_AR_RCT_APP_AMT)) over() FII_AR_GT_RCT_APP_AMT,
            sum(sum(FII_AR_RCT_EARNED_DCT)) over() FII_AR_GT_RCT_EARNED_DCT,
            sum(sum(FII_AR_RCT_UNEARNED_DCT)) over() FII_AR_GT_RCT_UNEARNED_DCT,
            decode(FII_AR_RCT_NUM, NULL, NULL, ''' || l_rct_num_url || ''') FII_AR_RCT_NUM_DRILL,
            decode(sum(FII_AR_RCT_AMT), 0, NULL, NULL, NULL,'''|| l_rct_amt_url ||''') FII_AR_RCT_AMT_DRILL,
            FII_AR_RCT_CURRENCY,
            FII_AR_CASH_RECEIPT_ID
            FROM (
           SELECT
       		  NVL(fact.account_number,'''||l_unid_message||''') FII_AR_RCT_ACCT_NUM,
       			FII_AR_RCT_NUM   FII_AR_RCT_NUM,
       			FII_AR_RCT_DATE     FII_AR_RCT_DATE,
       			FII_AR_RCT_GL_DATE         FII_AR_RCT_GL_DATE,
       			m.name             FII_AR_RCT_PAY_METHOD,
       			hist.status        FII_AR_RCT_STATUS,
       			receipt_amount     receipt_amount,
       			FII_AR_RCT_AMT FII_AR_RCT_AMT,
       			FII_AR_RCT_APP_AMT FII_AR_RCT_APP_AMT,
       			FII_AR_RCT_EARNED_DCT FII_AR_RCT_EARNED_DCT,
       			FII_AR_RCT_UNEARNED_DCT FII_AR_RCT_UNEARNED_DCT,
            FII_AR_RCT_CURRENCY FII_AR_RCT_CURRENCY,
            FII_AR_CASH_RECEIPT_ID FII_AR_CASH_RECEIPT_ID,
            fact.cust_account_id cust_account_id
             FROM(
             SELECT /*+ no_merge leading(v) cardinality(v 1) */ f.receipt_number FII_AR_RCT_NUM,
             acct.account_number account_number,
             f.receipt_date FII_AR_RCT_DATE,
             f.gl_date          FII_AR_RCT_GL_DATE,
             sum(f.amount_applied_rct) receipt_amount,
             sum(f.amount_applied_rct' || l_currency || ') FII_AR_RCT_AMT,
             CASE WHEN f.application_status = ''APP''
                  AND  f.filter_date <= :ASOF_DATE
                  AND f.filter_date >= :CURR_PERIOD_START
             THEN sum(f.amount_applied_rct' || l_currency || ')
       			ELSE 0
       			END FII_AR_RCT_APP_AMT,
            sum(f.earned_discount_amount' || l_currency || ') FII_AR_RCT_EARNED_DCT,
            sum(f.unearned_discount_amount' || l_currency || ') FII_AR_RCT_UNEARNED_DCT,
            f.currency_code FII_AR_RCT_CURRENCY,
            f.cash_receipt_id FII_AR_CASH_RECEIPT_ID,
            f.collector_bill_to_customer_id cust_account_id ,
            f.receipt_method_id receipt_method_id,
       			f.collector_bill_to_site_use_id collector_bill_to_site_use_id,
       			v.collector_id collector_id,
       			acct.account_owner_party_id Account_Owner_Party_ID,
       			v.class_Category class_category,
       		  v.class_code class_code
       	FROM  fii_ar_receipts_f        f,
       	      '||l_from_table || '
       	      '||l_gt_table_name||'
       	WHERE f.org_id              = v.org_id
       	AND  ((f.header_filter_date <= :ASOF_DATE
          				AND   f.header_filter_date >= :CURR_PERIOD_START)
          				AND
          				(f.filter_date <= :ASOF_DATE
          				AND   f.filter_date >= :CURR_PERIOD_START))
        '|| l_where_clause ||'
         GROUP BY  f.receipt_number,acct.account_number,f.receipt_date, f.gl_date,
                 f.currency_code, f.cash_receipt_id,
                 f.collector_bill_to_customer_id,
                 f.receipt_method_id,f.filter_date,f.application_status,
                 f.collector_bill_to_site_use_id ,
       					 v.collector_id ,
                 acct.account_owner_party_id,
                 v.class_Category ,
                 v.class_code)fact,
          			ar_receipt_methods       m,
         				-- hz_cust_accounts ca,
          			ar_cash_receipt_history_all hist    '||l_dim_from_table||'
     			WHERE
           fact.receipt_method_id   = m.receipt_method_id
           AND   hist.cash_receipt_id  = fact.FII_AR_CASH_RECEIPT_ID
           AND   hist.cash_receipt_history_id = (select  /*+ no_merge */ max(cash_receipt_history_id) from
                                           ar_cash_receipt_history_all hist1 where
                                           hist1.cash_receipt_id = fact.FII_AR_CASH_RECEIPT_ID)
          -- AND fact.cust_account_id = ca.cust_account_id(+)
           '||l_dim_where_clause||')
     		GROUP BY
        FII_AR_RCT_ACCT_NUM,
        FII_AR_RCT_NUM,
        FII_AR_RCT_DATE,
        FII_AR_RCT_GL_DATE,
        FII_AR_RCT_PAY_METHOD,
        FII_AR_RCT_STATUS,
        CUST_ACCOUNT_ID,
        FII_AR_RCT_CURRENCY,
        FII_AR_CASH_RECEIPT_ID
        '|| l_order_by ;

ELSE

   l_sqlstmt := 'SELECT
        FII_AR_RCT_ACCT_NUM,
        FII_AR_RCT_NUM,
        FII_AR_RCT_DATE,
        FII_AR_RCT_GL_DATE,
        FII_AR_RCT_PAY_METHOD,
        FII_AR_RCT_STATUS,
        to_char(sum(receipt_amount),''999,999,999,999'')|| '' '' || FII_AR_RCT_CURRENCY FII_AR_RCT_AMT_RCURR,
        sum(FII_AR_RCT_AMT) FII_AR_RCT_AMT,
        sum(FII_AR_RCT_APP_AMT)FII_AR_RCT_APP_AMT ,
        sum(FII_AR_RCT_EARNED_DCT) FII_AR_RCT_EARNED_DCT,
        sum(FII_AR_RCT_UNEARNED_DCT) FII_AR_RCT_UNEARNED_DCT,
        sum(sum(FII_AR_GT_RCT_AMT)) over() FII_AR_GT_RCT_AMT,
        sum(sum(FII_AR_GT_RCT_APP_AMT)) over() FII_AR_GT_RCT_APP_AMT,
        sum(sum(FII_AR_GT_RCT_EARNED_DCT)) over() FII_AR_GT_RCT_EARNED_DCT,
        sum(sum(FII_AR_GT_RCT_UNEARNED_DCT)) over() FII_AR_GT_RCT_UNEARNED_DCT,
        decode(FII_AR_RCT_NUM, NULL, NULL, ''' ||
             l_rct_num_url || ''') FII_AR_RCT_NUM_DRILL,
        decode(sum(FII_AR_RCT_AMT), 0, NULL, NULL, NULL,
                 ''' || l_rct_amt_url ||
                 ''')     FII_AR_RCT_AMT_DRILL,
        FII_AR_RCT_CURRENCY,
        FII_AR_CASH_RECEIPT_ID FROM(
        SELECT
       NVL(fact.account_number,'''||l_unid_message||''') FII_AR_RCT_ACCT_NUM,
       FII_AR_RCT_NUM      FII_AR_RCT_NUM,
       FII_AR_RCT_DATE     FII_AR_RCT_DATE,
       FII_AR_RCT_GL_DATE  FII_AR_RCT_GL_DATE,
       m.name             FII_AR_RCT_PAY_METHOD,
       hist.status        FII_AR_RCT_STATUS,
       0 receipt_amount,
       0 FII_AR_RCT_AMT,
       FII_AR_RCT_APP_AMT FII_AR_RCT_APP_AMT,
       0 FII_AR_RCT_EARNED_DCT,
       0 FII_AR_RCT_UNEARNED_DCT,
       0 FII_AR_GT_RCT_AMT,
       FII_AR_GT_RCT_APP_AMT FII_AR_GT_RCT_APP_AMT,
       0 FII_AR_GT_RCT_EARNED_DCT,
       0 FII_AR_GT_RCT_UNEARNED_DCT,
       FII_AR_RCT_CURRENCY FII_AR_RCT_CURRENCY,
       FII_AR_CASH_RECEIPT_ID FII_AR_CASH_RECEIPT_ID,
       fact.cust_account_id cust_account_id
       FROM (
       SELECT  /*+ no_merge leading(v) cardinality(v 1)*/
       acct.account_number  account_number,
       f.receipt_number   FII_AR_RCT_NUM,
       f.receipt_date     FII_AR_RCT_DATE,
       f.gl_date          FII_AR_RCT_GL_DATE,
       sum(f.amount_applied_rct' || l_currency || ') FII_AR_RCT_APP_AMT,
       sum(f.amount_applied_rct' || l_currency || ')  FII_AR_GT_RCT_APP_AMT,
       f.currency_code FII_AR_RCT_CURRENCY,
       f.cash_receipt_id FII_AR_CASH_RECEIPT_ID,
       f.collector_bill_to_customer_id cust_account_id,
       f.receipt_method_id receipt_method_id,
       f.collector_bill_to_site_use_id collector_bill_to_site_use_id,
       v.collector_id collector_id,
       acct.account_owner_party_id Account_Owner_Party_ID,
       v.class_Category class_category,
       v.class_code class_code
       FROM fii_ar_receipts_f        f,
            '||l_from_table || '
           '||l_gt_table_name||'
     WHERE f.org_id    = v.org_id
     AND f.filter_date <= :ASOF_DATE
     AND f.filter_date >= :CURR_PERIOD_START
     AND f.application_status = ''APP''
     AND (f.applied_payment_schedule_id > 0 OR f.applied_payment_schedule_id IS NULL) '
     || l_where_clause ||
     ' GROUP BY  acct.account_number ,f.receipt_number, f.receipt_date, f.gl_date,
                 f.currency_code, f.cash_receipt_id,
                 f.collector_bill_to_customer_id,
                 f.receipt_method_id,
                 f.collector_bill_to_site_use_id ,
       					 v.collector_id ,
                 acct.account_owner_party_id,
                 v.class_Category ,
                 v.class_code) fact,
                   ar_receipt_methods       m,
          				 ar_cash_receipt_history_all hist
                   '||l_dim_from_table||'
         WHERE
           fact.receipt_method_id   = m.receipt_method_id
           AND   hist.cash_receipt_id  = fact.FII_AR_CASH_RECEIPT_ID
           AND   hist.cash_receipt_history_id = (select  /*+ no_merge */ max(cash_receipt_history_id) from
                                           ar_cash_receipt_history_all hist1 where
                                           hist1.cash_receipt_id = fact.FII_AR_CASH_RECEIPT_ID)
           '||l_dim_where_clause||'
     UNION ALL
    SELECT NVL(fact.account_number,'''||l_unid_message||''') FII_AR_RCT_ACCT_NUM,
       FII_AR_RCT_NUM   FII_AR_RCT_NUM,
       FII_AR_RCT_DATE     FII_AR_RCT_DATE,
       FII_AR_RCT_GL_DATE          FII_AR_RCT_GL_DATE,
       m.name             FII_AR_RCT_PAY_METHOD,
       hist.status        FII_AR_RCT_STATUS,
       receipt_amount receipt_amount,
       FII_AR_RCT_AMT FII_AR_RCT_AMT,
       0 FII_AR_RCT_APP_AMT,
       FII_AR_RCT_EARNED_DCT FII_AR_RCT_EARNED_DCT,
       FII_AR_RCT_UNEARNED_DCT FII_AR_RCT_UNEARNED_DCT,
       FII_AR_GT_RCT_AMT FII_AR_GT_RCT_AMT,
       0 FII_AR_GT_RCT_APP_AMT,
       FII_AR_GT_RCT_EARNED_DCT FII_AR_GT_RCT_EARNED_DCT,
       FII_AR_GT_RCT_UNEARNED_DCT FII_AR_GT_RCT_UNEARNED_DCT,
       FII_AR_RCT_CURRENCY FII_AR_RCT_CURRENCY,
       FII_AR_CASH_RECEIPT_ID FII_AR_CASH_RECEIPT_ID ,
       fact.cust_account_id cust_account_id FROM (
       SELECT  /*+ no_merge '||l_index_hint||' leading(v) cardinality(v 1)*/
       acct.account_number  account_number,
       f.receipt_number   FII_AR_RCT_NUM,
       f.receipt_date     FII_AR_RCT_DATE,
       f.gl_date          FII_AR_RCT_GL_DATE,
       sum(f.amount_applied_rct) receipt_amount,
       sum(f.amount_applied_rct' || l_currency || ') FII_AR_RCT_AMT,
       sum(f.earned_discount_amount' || l_currency || ') FII_AR_RCT_EARNED_DCT,
       sum(f.unearned_discount_amount'||l_currency||') FII_AR_RCT_UNEARNED_DCT,
       sum(f.amount_applied_rct' || l_currency || ')  FII_AR_GT_RCT_AMT,
       sum(f.earned_discount_amount' || l_currency || ') FII_AR_GT_RCT_EARNED_DCT,
       sum(f.unearned_discount_amount'||l_currency||') FII_AR_GT_RCT_UNEARNED_DCT,
       f.currency_code FII_AR_RCT_CURRENCY,
       f.cash_receipt_id FII_AR_CASH_RECEIPT_ID,
       f.collector_bill_to_customer_id cust_account_id,
       f.receipt_method_id receipt_method_id,
       f.collector_bill_to_site_use_id collector_bill_to_site_use_id,
       v.collector_id collector_id,
       acct.account_owner_party_id Account_Owner_Party_ID,
       v.class_Category class_category,
       v.class_code class_code
      FROM fii_ar_receipts_f        f,
         '||l_from_table || '
          '||l_gt_table_name||'
     WHERE f.org_id              = v.org_id
     AND f.filter_date <= :ASOF_DATE
     and f.cash_receipt_id in
     		(select /*+ no_merge */  distinct cash_receipt_id from
     				(	select  /*+ no_merge leading(v1) cardinality(v1 1)*/ v1.collector_id collector_id,
     				 v1.class_category class_category,
     				 v1.class_code class_code,
     				 acct1.account_owner_party_id account_owner_party_id
     				,cash_receipt_id
     				,f1.collector_bill_to_customer_id cust_account_id
     			  ,f1.collector_bill_to_site_use_id collector_bill_to_site_use_id
      			from FII_AR_RECEIPTS_F f1
     				,  '||l_from_table1 || '
          	'||l_gt_table_name1||'
     				where  f1.org_id = v1.org_id
     				AND f1.filter_date <= :ASOF_DATE
     				AND f1.filter_date >= :CURR_PERIOD_START
     				AND f1.application_status = ''APP''
     				and (f1.applied_payment_schedule_id > 0 OR f1.applied_payment_schedule_id IS NULL)
     				'|| l_where_clause1 ||'
     				) fact1 '||l_dim_from_table1||'
        WHERE
          '||l_dim_where_clause1||'
        )
     AND (f.applied_payment_schedule_id > 0 OR f.applied_payment_schedule_id IS NULL)'
    || l_where_clause ||
     ' GROUP BY  acct.account_number,f.receipt_number, f.receipt_date, f.gl_date,
               f.currency_code, f.cash_receipt_id,
             f.collector_bill_to_customer_id,f.receipt_method_id,
              f.collector_bill_to_site_use_id ,
       					 v.collector_id ,
                 acct.account_owner_party_id,
                 v.class_Category ,
                 v.class_code) fact,
              ar_receipt_methods       m,
          			  ar_cash_receipt_history_all hist
                    '||l_dim_from_table||'
          WHERE
           fact.receipt_method_id   = m.receipt_method_id
           AND   hist.cash_receipt_id  = fact.FII_AR_CASH_RECEIPT_ID
           AND   hist.cash_receipt_history_id = (select  /*+ no_merge */ max(cash_receipt_history_id) from
                                           ar_cash_receipt_history_all hist1 where
                                           hist1.cash_receipt_id = fact.FII_AR_CASH_RECEIPT_ID)
            '||l_dim_where_clause||' )
            GROUP BY
            FII_AR_RCT_ACCT_NUM,
        FII_AR_RCT_NUM,
        FII_AR_RCT_DATE,
        FII_AR_RCT_GL_DATE,
        FII_AR_RCT_PAY_METHOD,
        FII_AR_RCT_STATUS,
        FII_AR_RCT_CURRENCY,
        FII_AR_CASH_RECEIPT_ID,
        CUST_ACCOUNT_ID '
    || l_order_by;

    END IF;

  -- Bind variables so that no literal will be used in the pmv report


  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_rec_act_detail_sql,
     p_bind_output_table  => p_rec_act_detail_output);

END get_rec_act_detail;



END FII_AR_REC_ACT_DETAIL_PKG;


/
