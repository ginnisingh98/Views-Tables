--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_ACT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_ACT_HISTORY_PKG" AS
/* $Header: FIIARDBIRAHB.pls 120.8.12000000.2 2007/04/09 20:23:39 vkazhipu ship $ */

-----------------------------------------------------------------
-- This procedure is called by the Receipts Activity History report
-----------------------------------------------------------------
PROCEDURE get_rec_act_history
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_rec_act_detail_sql       OUT NOCOPY VARCHAR2,
   p_rec_act_detail_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_sqlstmt          VARCHAR2(25000);
  l_rct_amt_url      VARCHAR2(500) := NULL;
  l_return_status    VARCHAR2(10);
  l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_cust_acct_id     VARCHAR2(30);
  l_cust_id          VARCHAR2(500);
  l_where_clause     VARCHAR2(2000);
  l_from_table       VARCHAR2(1000);
  l_gt_table_name    VARCHAR2(300) := 'FII_AR_SUMMARY_GT v';
  l_other            VARCHAR2(30)  :=  FND_MESSAGE.get_string('FII', 'FII_AR_OTHER');


BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

   l_cust_id           := fii_ar_util_pkg.g_party_id;
   l_cust_acct_id      := fii_ar_util_pkg.g_cust_account_id;

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;

 -- Only add the join on cust_acct_id if we have a specific customer acct
  -- selected

IF (l_cust_acct_id <> '-111') THEN
    l_where_clause := l_where_clause ||
                      ' AND   f.collector_bill_to_customer_id = :CUST_ACCOUNT_ID
                        AND   v.org_id = f.org_id
                        AND   v.party_id = :PARTY_ID';
     l_gt_table_name := 'FII_AR_SUMMARY_GT v';

  -- Only add the join on party_id when we have a specific customer selected
  -- and if customer account id is not present
  --if customer account id is present just bind customer account id and don't user customer id
  --since one customer account anyway belongs to one customer

  ELSIF (l_cust_id <> '-111') THEN

    l_from_table   := l_from_table || 'fii_cust_accounts acct, ';
    l_where_clause := l_where_clause ||
                        ' AND f.collector_bill_to_customer_id = acct.cust_account_id
                          AND acct.account_owner_party_id in ( :PARTY_ID )
                          AND   v.org_id = f.org_id
                          AND acct.account_owner_party_id = acct.parent_party_id
                          AND   v.party_id = :PARTY_ID';
  	l_gt_table_name := 'FII_AR_SUMMARY_GT v';
  END IF;


 -------------------------------
  -- Construct the drilldown URLs
  -------------------------------

  -- Receipt Amount Drilldown URL
  --
  l_rct_amt_url := 'pFunctionName=FII_AR_PAID_REC_DTL&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=FII_AR_CUST_ACCOUNT'||
  '&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=FII_AR_CASH_RECEIPT_ID'||
  '&pParamIds=Y';



  -------------------------------
  -- Construct the sql statements
  -------------------------------
  l_sqlstmt :=
    'SELECT /*+ leading(v) cardinality(v 1) */ decode(f.application_status,''ACC'','''||l_other||''',''OTHER ACC'','''||l_other||''',l.meaning) FII_AR_RCT_ACTION,
            f.amount_applied_rct FII_AR_RCT_AMT,
            f.filter_date       FII_AR_RCT_DATE,
            fnd.user_name   FII_AR_RCT_USER,
            decode(f.application_status,''APP'',''' ||l_rct_amt_url||''',NULL) FII_AR_RCT_AMT_DRILL,
            NVL(f.applied_customer_trx_id,-999999) FII_AR_APP_CUST_TRX_ID
            FROM
            fii_ar_receipts_f        f,
             '||l_from_table ||'
             '||l_gt_table_name||'
       	      ,ar_lookups               l
       	      ,fnd_user                 fnd
        WHERE f.user_id              = fnd.user_id
        AND   l.lookup_type          = ''PAYMENT_TYPE''
        AND   l.lookup_code         = f.application_status
        AND   f.cash_receipt_id     = :CASH_RECEIPT_ID
        '|| l_where_clause ||'
        &ORDER_BY_CLAUSE';




  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_rec_act_detail_sql,
     p_bind_output_table  => p_rec_act_detail_output);

END get_rec_act_history;



END FII_AR_REC_ACT_HISTORY_PKG;


/
