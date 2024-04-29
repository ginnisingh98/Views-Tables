--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_DETAIL_PKG" AS
/* $Header: FIIARDBIRDB.pls 120.27.12000000.2 2007/04/09 20:24:16 vkazhipu ship $ */

--------------------------------------------------
-- This procedure is called by the Receipts Detail
--------------------------------------------------
PROCEDURE get_rec_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_sqlstmt          VARCHAR2(25000);
  l_where_clause     VARCHAR2(2000);
  l_from_table       VARCHAR2(1000);
  l_currency         VARCHAR2(10);

  l_as_of_date       DATE;
  l_curr_suffix      VARCHAR2(4);
  l_itd_bitand       NUMBER;
  l_industry_id      VARCHAR2(30);
  l_collector_id     VARCHAR2(30);
  l_cust_id          VARCHAR2(500);

  l_rct_num_url      VARCHAR2(500) := NULL;
  l_rct_amt_url      VARCHAR2(500) := NULL;
  l_rct_app_amt_url  VARCHAR2(1000) := NULL;

  l_order_clause     VARCHAR2(500);
  l_order_column     VARCHAR2(100);
  l_order_null       VARCHAR2(100);
  l_order_by         VARCHAR2(500);
  l_source_report    VARCHAR2(30);

  l_bucket_num       NUMBER;
  l_bucket_low       NUMBER;
  l_bucket_high      NUMBER;
  l_bis_bucket_rec   BIS_BUCKET_PUB.bis_bucket_rec_type;
  l_return_status    VARCHAR2(10);
  l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_unid_message VARCHAR2(30) := FND_MESSAGE.get_string('FII', 'FII_AR_UNID_CUSTOMER');

  -- Bug 5118034
  l_unapp_select_sql  VARCHAR2(2000);
  l_unapp_end_select_sql   VARCHAR2(2000);

BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';

  -- Retrieve values for global variables
  l_as_of_date        := fii_ar_util_pkg.g_as_of_date;
  l_curr_suffix       := fii_ar_util_pkg.g_curr_suffix;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;
  l_industry_id       := fii_ar_util_pkg.g_industry_id;
  l_itd_bitand        := fii_ar_util_pkg.g_bitand_inc_todate;

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

  ---------------------------------------------------------------------------
  -- Find out additional parameters pass into Receipt Details via URL:
  -- 1. Source report calling Receipt Details
  -- 2. Bucket number from the source report
  -- 3. Transaction number from the source report
  -- 4. Customer account from the source report
  ---------------------------------------------------------------------------
  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF (p_page_parameter_tbl(i).parameter_name = 'BIS_FXN_NAME') THEN
        l_source_report := p_page_parameter_tbl(i).parameter_value;

      ELSIF (p_page_parameter_tbl(i).parameter_name = 'Bucket_Num') THEN
        l_bucket_num := p_page_parameter_tbl(i).parameter_id;

      END IF;

    END LOOP;
  END IF;

  -----------------------------------------
  -- Construct the conditional where clause
  -----------------------------------------
  -- Only add the join on collector_id if we have a specific collector selected
  IF (l_collector_id <> '-111') THEN
    l_from_table   := l_from_table || 'fii_collectors col, ';
    l_where_clause := l_where_clause ||
                      ' AND f.bill_to_customer_id = col.cust_account_id
                        AND f.bill_to_site_use_id = col.site_use_id ';
  END IF;

  -- Only add the join on cust_acct_id if we have a specific customer acct
  -- selected

 IF fii_ar_util_pkg.g_cust_account <> '-111' THEN
     --l_from_table   := l_from_table || '  fii_cust_accounts acct, ';
     l_where_clause :=  l_where_clause ||
                      ' AND f.bill_to_customer_id= :CUST_ACCOUNT
		        AND acct.parent_party_id = :PARTY_ID
		        AND v.party_id = :PARTY_ID ';
 -- Only add the join on party_id when we have a specific customer selected
 -- and customer account is not selected
 ELSIF l_cust_id <> '-111'  THEN
    --l_from_table := l_from_table || 'fii_cust_accounts acct, ';
    l_where_clause :=  l_where_clause ||
                      ' AND acct.account_owner_party_id = :PARTY_ID
			AND acct.account_owner_party_id = acct.parent_party_id
			AND v.party_id = :PARTY_ID';
 ELSE
    l_where_clause :=  l_where_clause ||
                      ' AND acct.account_owner_party_id = acct.parent_party_id';
 END IF;

  -- Only add the join on class_category and class_code if we have a
  -- specific industry selected
  IF (l_industry_id <> '-111') THEN
    l_from_table := l_from_table ||
                    'fii_cust_accounts acct2, fii_party_mkt_class ind, ';

    l_where_clause := l_where_clause ||
                        ' AND   f.bill_to_customer_id = acct2.cust_account_id
                          AND   ind.party_id          = acct2.Account_Owner_Party_ID
                          AND   acct2.parent_party_id = acct2.account_owner_party_id
                          AND   ind.class_category    = v.class_category
                          AND   ind.class_code        = v.class_code ';
  END IF;

  ---------------------------------------------------------------------------
  -- 1. If source form function = 'FII_AR_UNAPP_RCT_DTL', then select receipts
  --    not fully applied as of the As of Date
  ---------------------------------------------------------------------------
  IF (l_source_report = 'FII_AR_UNAPP_RCT_DTL') THEN
    l_where_clause := l_where_clause ||
                      ' AND f.filter_date <= :ASOF_DATE
                        AND f.rct_actual_date_closed > :ASOF_DATE';

     -- Bug 5118034
     --vkazhipu changed SELECT statement by adding SUM and corresponding GROUP BY for Bug
     --5131795
     l_unapp_select_sql :=
     'SELECT
		FII_AR_RCT_ACCT_NUM		FII_AR_RCT_ACCT_NUM,
		FII_AR_RCT_NUM			FII_AR_RCT_NUM,
		FII_AR_RCT_DATE			FII_AR_RCT_DATE,
		FII_AR_RCT_GL_DATE		FII_AR_RCT_GL_DATE,
		FII_AR_RCT_PAY_METHOD		FII_AR_RCT_PAY_METHOD,
		FII_AR_RCT_STATUS		FII_AR_RCT_STATUS,
		FII_AR_RCT_AMT_RCURR		FII_AR_RCT_AMT_RCURR,
		SUM(FII_AR_RCT_AMT)			FII_AR_RCT_AMT,
		SUM(FII_AR_RCT_APP_AMT)		FII_AR_RCT_APP_AMT,
		SUM(FII_AR_RCT_UNAPP_AMT)		FII_AR_RCT_UNAPP_AMT,
		SUM(FII_AR_RCT_EARNED_DCT)		FII_AR_RCT_EARNED_DCT,
		SUM(FII_AR_RCT_UNEARNED_DCT)		FII_AR_RCT_UNEARNED_DCT,
		SUM(SUM(FII_AR_RCT_AMT)) over()		FII_AR_GT_RCT_AMT,
		SUM(SUM(FII_AR_RCT_APP_AMT)) over()		FII_AR_GT_RCT_APP_AMT,
		SUM(SUM(FII_AR_RCT_UNAPP_AMT)) over()		FII_AR_GT_RCT_UNAPP_AMT,
		SUM(SUM(FII_AR_RCT_EARNED_DCT)) over()	FII_AR_GT_RCT_EARNED_DCT,
		SUM(SUM(FII_AR_RCT_UNEARNED_DCT)) over()	FII_AR_GT_RCT_UNEARNED_DCT,
		FII_AR_RCT_NUM_DRILL		FII_AR_RCT_NUM_DRILL,
		FII_AR_RCT_AMT_DRILL		FII_AR_RCT_AMT_DRILL,
		FII_AR_RCT_APP_AMT_DRILL	FII_AR_RCT_APP_AMT_DRILL
	FROM (';

     l_unapp_end_select_sql := ' AND FII_AR_RCT_UNAPP_AMT <>0';
  ---------------------------------------------------------------------------
  -- 2. If source form function = 'FII_AR_UNAPP_X_RCT_DTL', then select
  --    receipts that are not fully applied on the as of date, and the
  --    receipt created [bucket x] days before the As of Date.
  ---------------------------------------------------------------------------
  ELSIF (l_source_report = 'FII_AR_UNAPP_X_RCT_DTL') THEN
    -- Find out bucket information
    BIS_BUCKET_PUB.retrieve_bis_bucket (
      p_short_name	=> 'FII_DBI_UNAPP_RECEIPT_BUCKET',
      x_bis_bucket_rec	=> l_bis_bucket_rec,
      x_return_status	=> l_return_status,
      x_error_tbl 	=> l_error_tbl
    );

    -- Find out the bucket ranges for the bucket calling this report
    -- Note that maximum bucket ranges for Unapplied Receipts Summary
    -- is 3 buckets
    IF (l_bucket_num = 1) THEN
      l_bucket_low  := l_bis_bucket_rec.range1_low;
      l_bucket_high := (l_bis_bucket_rec.range1_high - 1);
    ELSIF (l_bucket_num = 2) THEN
      l_bucket_low  := l_bis_bucket_rec.range2_low;
      l_bucket_high := (l_bis_bucket_rec.range2_high -1);
    ELSIF (l_bucket_num = 3) THEN
      l_bucket_low  := l_bis_bucket_rec.range3_low;
      l_bucket_high := (l_bis_bucket_rec.range3_high-1);
    END IF;

    IF l_bucket_high is NULL THEN
     l_where_clause := l_where_clause ||
                      ' AND f.rct_actual_date_closed > :ASOF_DATE
		        AND f.filter_date <= :ASOF_DATE
                        AND f.receipt_date <= (:ASOF_DATE - '
                            || l_bucket_low || ')';
    ELSE
     l_where_clause := l_where_clause ||
                      ' AND f.rct_actual_date_closed > :ASOF_DATE
		        AND f.filter_date <= :ASOF_DATE
                        AND f.receipt_date BETWEEN ( :ASOF_DATE - ' || l_bucket_high ||
                            ') AND (:ASOF_DATE - '
                            || l_bucket_low || ')';
    END IF;

    -- Bug 5118034
     --vkazhipu changed SELECT statement by adding SUM and corresponding GROUP BY for Bug
     --5131795
     l_unapp_select_sql :=
     'SELECT
		FII_AR_RCT_ACCT_NUM		FII_AR_RCT_ACCT_NUM,
		FII_AR_RCT_NUM			FII_AR_RCT_NUM,
		FII_AR_RCT_DATE			FII_AR_RCT_DATE,
		FII_AR_RCT_GL_DATE		FII_AR_RCT_GL_DATE,
		FII_AR_RCT_PAY_METHOD		FII_AR_RCT_PAY_METHOD,
		FII_AR_RCT_STATUS		FII_AR_RCT_STATUS,
		FII_AR_RCT_AMT_RCURR		FII_AR_RCT_AMT_RCURR,
		SUM(FII_AR_RCT_AMT)			FII_AR_RCT_AMT,
		SUM(FII_AR_RCT_APP_AMT)		FII_AR_RCT_APP_AMT,
		SUM(FII_AR_RCT_UNAPP_AMT)		FII_AR_RCT_UNAPP_AMT,
		SUM(FII_AR_RCT_EARNED_DCT)		FII_AR_RCT_EARNED_DCT,
		SUM(FII_AR_RCT_UNEARNED_DCT)		FII_AR_RCT_UNEARNED_DCT,
		SUM(SUM(FII_AR_RCT_AMT)) over()		FII_AR_GT_RCT_AMT,
		SUM(SUM(FII_AR_RCT_APP_AMT)) over()		FII_AR_GT_RCT_APP_AMT,
		SUM(SUM(FII_AR_RCT_UNAPP_AMT)) over()		FII_AR_GT_RCT_UNAPP_AMT,
		SUM(SUM(FII_AR_RCT_EARNED_DCT)) over()	FII_AR_GT_RCT_EARNED_DCT,
		SUM(SUM(FII_AR_RCT_UNEARNED_DCT)) over()	FII_AR_GT_RCT_UNEARNED_DCT,
		FII_AR_RCT_NUM_DRILL		FII_AR_RCT_NUM_DRILL,
		FII_AR_RCT_AMT_DRILL		FII_AR_RCT_AMT_DRILL,
		FII_AR_RCT_APP_AMT_DRILL	FII_AR_RCT_APP_AMT_DRILL
	FROM (';

     l_unapp_end_select_sql := 'AND FII_AR_RCT_UNAPP_AMT <>0';
  ---------------------------------------------------------------------------
  -- 3. If source form function = 'FII_AR_APP_RCT_DTL', then select receipts
  --    partially or fully applied to the transaction chosen in the sourcel
  --    report
  ---------------------------------------------------------------------------
  ELSIF (l_source_report = 'FII_AR_APP_RCT_DTL') THEN
    -- Bug 5147703. Join on transaction id is not required
    l_where_clause := l_where_clause ||
                      ' AND f.cash_receipt_id = :CASH_RECEIPT_ID';
  END IF;

  -------------------------------
  -- Construct the drilldown URLs
  -------------------------------
  -- Receipt Number Drilldown URL
  l_rct_num_url :=  'pFunctionName=FII_AR_RCT_ACT_HISTORY&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=''||f.currency_code||
                    ''&BIS_PMV_DRILL_CODE_FII_CUSTOMER_ACCOUNT=''||f.bill_to_customer_id||
		    ''&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=''||f.cash_receipt_id||
		    ''&BIS_PMV_DRILL_CODE_FII_AR_RCT_NUM=FII_AR_RCT_NUM&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate'||
		    '&pParamIds=Y';

  -- Receipt Amount Drilldown URL
   l_rct_amt_url := 'pFunctionName=FII_AR_RCT_BALANCES_DTL&BIS_PMV_DRILL_CODE_FII_CUSTOMER_ACCOUNT=''||f.bill_to_customer_id||
                    ''&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=''||f.cash_receipt_id||
		   ''&BIS_PMV_DRILL_CODE_FII_AR_RCT_NUM=FII_AR_RCT_NUM&BIS_PMV_DRILL_CODE_FII_AR_RCT_CURRENCY=''||f.currency_code||
                     ''&BIS_PMV_DRILL_CODE_AS_OF_DATE=sysdate&pParamIds=Y';

  -- Applied Amount Drilldown URL
  l_rct_app_amt_url := 'pFunctionName=FII_AR_PAID_REC_DTL&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=''||f.cash_receipt_id||
                   ''&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=''||f.bill_to_customer_id||
		   ''&pParamIds=Y';

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
    IF l_source_report <> 'FII_AR_APP_RCT_DTL' THEN
     --In case of Unapplied Receipt Detail source the sql structure is different
     l_order_column := substr(fii_ar_util_pkg.g_order_by, 1,
                              instr(l_order_clause, ' DESC'));
     IF (l_order_column is NULL) THEN
      --Ascending order
       l_order_by := ' &ORDER_BY_CLAUSE';
     ELSE
      --Descending Order
      l_order_by := ' ORDER BY NVL('|| l_order_column || ', '
                                   || l_order_null || ' ) DESC';
     END IF;
    ELSE
     --In case of Applied Receipts Detail the query structure is different
     IF (instr(l_order_clause, ' DESC') <> 0) THEN
      l_order_by := ' ORDER BY NVL(sum(f.amount_applied_rct), -999999999) DESC,
                               NVL(f.currency_code, NLSSORT(''000000000'',
                                   ''NLS_SORT=BINARY'')) DESC';
     ELSE
      l_order_by := ' ORDER BY NVL(sum(f.amount_applied_rct), -999999999) ASC,
                               NVL(f.currency_code, NLSSORT(''000000000'',
                                   ''NLS_SORT=BINARY'')) ASC';
     END IF;
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

  l_sqlstmt :='SELECT  FII_AR_RCT_ACCT_NUM FII_AR_RCT_ACCT_NUM,
             FII_AR_RCT_NUM,FII_AR_RCT_DATE,
	     FII_AR_RCT_GL_DATE,
	     m.name FII_AR_RCT_PAY_METHOD ,
             DECODE(l.lookup_code,''NSF'',l.meaning, ''REV'',l.meaning ,''STOP'', l.meaning, ''-'') FII_AR_RCT_STATUS,
	     FII_AR_RCT_AMT_RCURR,
	     SUM(FII_AR_RCT_AMT) FII_AR_RCT_AMT,
	     SUM(FII_AR_RCT_APP_AMT) FII_AR_RCT_APP_AMT,
	     SUM(FII_AR_RCT_UNAPP_AMT) FII_AR_RCT_UNAPP_AMT,
	     SUM(FII_AR_RCT_EARNED_DCT) FII_AR_RCT_EARNED_DCT,
             SUM(FII_AR_RCT_UNEARNED_DCT) FII_AR_RCT_UNEARNED_DCT,
	     SUM(SUM(FII_AR_RCT_AMT)) over() FII_AR_GT_RCT_AMT,
             SUM(SUM(FII_AR_RCT_APP_AMT)) over() FII_AR_GT_RCT_APP_AMT,
	     SUM(SUM(FII_AR_RCT_UNAPP_AMT)) over() FII_AR_GT_RCT_UNAPP_AMT,
	     SUM(SUM(FII_AR_RCT_EARNED_DCT)) over() FII_AR_GT_RCT_EARNED_DCT,
             SUM(SUM(FII_AR_RCT_UNEARNED_DCT)) over() FII_AR_GT_RCT_UNEARNED_DCT,
	     FII_AR_RCT_NUM_DRILL,
             FII_AR_RCT_AMT_DRILL,
	     FII_AR_RCT_APP_AMT_DRILL
    FROM(
    SELECT /*+ no_merge leading(v) cardinality(v 1) */ NVL(acct.account_number,'''||l_unid_message||''') FII_AR_RCT_ACCT_NUM, --acct.account_number account_number,
       f.receipt_number    FII_AR_RCT_NUM,
       f.receipt_date     FII_AR_RCT_DATE,
       f.gl_date          FII_AR_RCT_GL_DATE,
       f.header_status  header_status,
       to_char(SUM(f.amount_applied_rct), ''999,999,999'')
                    || '' '' || f.currency_code FII_AR_RCT_AMT_RCURR,
       sum(f.amount_applied_rct' || l_currency || ') FII_AR_RCT_AMT,
       sum(decode(f.application_status,
                    ''APP'',   f.amount_applied_rct' || l_currency || ',
                    0)) FII_AR_RCT_APP_AMT,
       sum(decode(f.application_status,
                    ''UNAPP'',   f.amount_applied_rct'|| l_currency || ',
                    ''UNID'',    f.amount_applied_rct'|| l_currency || ',
                     0)) FII_AR_RCT_UNAPP_AMT,
       sum(f.earned_discount_amount' || l_currency || ') FII_AR_RCT_EARNED_DCT,
       sum(f.unearned_discount_amount'||l_currency||') FII_AR_RCT_UNEARNED_DCT,
       sum(sum(f.amount_applied_rct' || l_currency || ')) over() FII_AR_GT_RCT_AMT,
       sum(sum(decode(f.application_status,
                    ''APP'',   f.amount_applied_rct' || l_currency || ',
                    0))) over() FII_AR_GT_RCT_APP_AMT,
       sum(sum(decode(f.application_status,
                    ''UNAPP'',   f.amount_applied_rct'|| l_currency || ',
                    ''UNID'',    f.amount_applied_rct'|| l_currency || ',
                     0))) over() FII_AR_GT_RCT_UNAPP_AMT,
       sum(sum(f.earned_discount_amount' || l_currency || ')) over()   FII_AR_GT_RCT_EARNED_DCT,
       sum(sum(f.unearned_discount_amount'||l_currency||')) over() FII_AR_GT_RCT_UNEARNED_DCT,
       decode(f.receipt_number, NULL, NULL, ''' ||

                   l_rct_num_url || ''') FII_AR_RCT_NUM_DRILL,

       decode(sum(f.amount_applied_rct' || l_currency || '), 0, NULL, NULL, NULL, ''' ||
                   l_rct_amt_url || ''')       FII_AR_RCT_AMT_DRILL,

       decode(sum(f.amount_applied_trx' || l_currency || '), 0, NULL, NULL, NULL,

                       ''' || l_rct_app_amt_url || ''')  FII_AR_RCT_APP_AMT_DRILL,
		       f.bill_to_customer_id, f.receipt_method_id
     FROM fii_ar_receipts_f        f, fii_cust_accounts acct,
	  '||l_from_table || '
            FII_AR_SUMMARY_GT v
     WHERE  f.org_id  = v.org_id
     AND f.bill_to_customer_id = acct.cust_account_id '
     || l_where_clause ||'
     GROUP BY NVL(acct.account_number,'''||l_unid_message||''') , f.receipt_number, f.receipt_date, f.gl_date, f.cash_receipt_id,
               f.currency_code, f.bill_to_customer_id, f.header_status, f.receipt_method_id) fact , ar_lookups  l,
	      ar_receipt_methods    m
	  WHERE fact.receipt_method_id   = m.receipt_method_id
	  AND l.lookup_type = ''CHECK_STATUS''
          AND l.lookup_code = fact.header_status    ' || l_unapp_end_select_sql ||'
	  GROUP BY 		FII_AR_RCT_ACCT_NUM,
				FII_AR_RCT_NUM,
				FII_AR_RCT_DATE,
				FII_AR_RCT_GL_DATE,
				m.name,
				l.lookup_code, l.meaning ,
				FII_AR_RCT_AMT_RCURR,
				FII_AR_RCT_NUM_DRILL,
				FII_AR_RCT_AMT_DRILL,
				FII_AR_RCT_APP_AMT_DRILL ' || l_order_by;

-- Bind variables so that no literal will be used in the pmv report
  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_pastdue_rec_aging_sql,
     p_bind_output_table  => p_pastdue_rec_aging_output);

END get_rec_detail;

----------------------------------------------------------
-- This procedure is called by the Receipt Balances Detail
----------------------------------------------------------
PROCEDURE get_rec_bal_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
 l_sqlstmt          VARCHAR2(25000);
 l_where_clause     VARCHAR2(2000);
 l_from_table       VARCHAR2(1000);

 l_as_of_date       DATE;
 l_itd_bitand       NUMBER;
 l_collector_id     VARCHAR2(30);
 l_cust_id          VARCHAR2(500);
 l_rct_num          VARCHAR2(30);
 l_rct_curr         VARCHAR2(30);

 l_rct_amt_url      VARCHAR2(500) := NULL;

BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';

  -- Retrieve values for global variables
  l_as_of_date        := fii_ar_util_pkg.g_as_of_date;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;
  l_itd_bitand        := fii_ar_util_pkg.g_bitand_inc_todate;

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;

  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF (p_page_parameter_tbl(i).parameter_name = 'FII_AR_RCT_NUM') THEN
        l_rct_num := p_page_parameter_tbl(i).parameter_value;

      ELSIF (p_page_parameter_tbl(i).parameter_name = 'FII_AR_RCT_CURRENCY') THEN
        l_rct_curr := p_page_parameter_tbl(i).parameter_value;
      END IF;
    END LOOP;
  END IF;

  IF l_cust_id <> -111 THEN
   l_where_clause := 'AND    gt.party_id      = :PARTY_ID';
  END IF;
  ----------------------------------------------------------------------------
  -- Construct the drilldown URLs
  -- <arcdixit> Bug 5060164.
  -- Modified the drill to pass the following to Paid Receivables Detail report
  -- 1. cash_receipt_id
  -- 2. applied_customer_trx_id (To be Removed as per discussion with Renu)
  -- 3. cust_account_id
  -----------------------------------------------------------------------------
  -- Receipt Amount Drilldown URL
  l_rct_amt_url := 'pFunctionName=FII_AR_PAID_REC_DTL&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=''||v2.cash_receipt_id||
                   ''&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=''||v2.cust_account_id||
		   ''&pParamIds=Y';

  -------------------------------------------------------------------------------------------------------------------
  -- Construct the sql statements
  -- <arcdixit> Bug 5060164.
  -- 1. applied_payment_schedule_id > 0 is for the applied receipts, added applied_payment_schedule_id is NULL
  --    for cases when the receipt is unapplied.
  -- 2. Use application_status instead of header_status in the sql
  -- 3. Remove the join with fii_time_structures tables based on as_of_date
  -- 4. Added cash_receipt_id, applied_customer_trx_id and cust_account_id for drill to Paid Receivables Detail report
  -- 5. Decode should be on lookup_code and not meaning. Changed the same
  ---------------------------------------------------------------------------------------------------------------------
  l_sqlstmt :=
    'SELECT
       lv.meaning                  FII_AR_RCT_BALANCE,
       nvl(sum(v2.amount), 0)      FII_AR_RCT_AMT,
       decode(lv.lookup_code, ''APP'',
         decode(nvl(sum(v2.amount), 0),
                0, NULL,
                ''' || l_rct_amt_url || '''),
                NULL) FII_AR_RCT_AMT_DRILL
     FROM (
       SELECT /*+ leading(gt) cardinality(gt 1) */ f.application_status           status,
              sum(f.amount_applied_rct) amount,
	      f.cash_receipt_id,
	      :CUST_ACCOUNT_ID    cust_account_id
       FROM fii_ar_receipts_f f,  '||l_from_table || ' fii_ar_summary_gt gt
       WHERE  f.org_id         = gt.org_id
       AND   f.cash_receipt_id = :CASH_RECEIPT_ID
       AND   f.currency_code  = '''|| l_rct_curr || '''
       AND   (f.applied_payment_schedule_id > 0 OR f.applied_payment_schedule_id is NULL)
       ' || l_where_clause || '
       GROUP BY f.application_status,
	      f.cash_receipt_id,
	      :CUST_ACCOUNT_ID
       UNION ALL
       SELECT  /*+ leading(gt) cardinality(gt 1) */ decode(applied_payment_schedule_id,
                     -2, ''OTHER'', -3, ''OTHER'', -5, ''OTHER'',
                     -6, ''OTHER'', -8, ''OTHER'', -9, ''OTHER'',
                     -1, ''ONACC'',
                     -4, ''CASH'',
                     -7, ''PREPAY'') status,
              sum(f.amount_applied_rct) amount,
	      f.cash_receipt_id,
	      :CUST_ACCOUNT_ID    cust_account_id
       FROM fii_ar_receipts_f f,  '||l_from_table || ' fii_ar_summary_gt gt
       WHERE  f.org_id         = gt.org_id
       AND   f.cash_receipt_id = :CASH_RECEIPT_ID
       AND   f.currency_code  = '''|| l_rct_curr || '''
       AND   f.applied_payment_schedule_id < 0
       ' || l_where_clause || '
       GROUP BY decode(applied_payment_schedule_id,
                     -2, ''OTHER'', -3, ''OTHER'', -5, ''OTHER'',
                     -6, ''OTHER'', -8, ''OTHER'', -9, ''OTHER'',
                     -1, ''ONACC'',
                     -4, ''CASH'',
                     -7, ''PREPAY''),
	      f.cash_receipt_id,
	      :CUST_ACCOUNT_ID
       ) v2,
       fnd_lookup_values lv
     WHERE lv.lookup_type       = ''FII_AR_RCT_BAL_DETAIL_TYPE''
     AND   lv.view_application_id = 450
     AND   lv.language = userenv(''LANG'')
     AND   v2.status (+)= lv.lookup_code
     GROUP BY lv.meaning, lv.lookup_code, cash_receipt_id,
	      cust_account_id
     ORDER BY decode(lv.lookup_code,
                ''UNID'',  1, ''APP'',  2, ''ONACC'',  3,
                ''UNAPP'', 4, ''CASH'', 5, ''PREPAY'', 6,
                ''OTHER'', 7 )';

  -- Bind variables so that no literal will be used in the pmv report
  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_pastdue_rec_aging_sql,
     p_bind_output_table  => p_pastdue_rec_aging_output);

END get_rec_bal_detail;

END FII_AR_REC_DETAIL_PKG;


/
