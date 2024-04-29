--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_AGING_PKG" AS
/* $Header: FIIARDBIRAB.pls 120.16 2007/05/15 20:52:06 vkazhipu ship $ */

-----------------------------------------------------------------------------
-- This procedure is called by the Pastdue Receivables Aging Summary report
-------------------------------------------------------------------------------
PROCEDURE get_pastdue_rec_aging
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
 l_sqlstmt                    VARCHAR2(25000);
 l_where_clause               VARCHAR2(2000);
 l_url_sql                    VARCHAR2(6000);
 l_bucket_graph_sql           VARCHAR2(1000);
 l_bucket_sql                 VARCHAR2(1000);
 l_dispute_bkt_graph_sql      VARCHAR2(1000);
 l_dispute_bkt_sql            VARCHAR2(1000);
 l_bucket_ct                  NUMBER;
 l_max_bucket_ct              NUMBER := 7; -- Maximum number of bucket ranges
 i                            NUMBER;

 l_as_of_date                 DATE;
 l_cust_suffix                VARCHAR2(6);
 l_curr_suffix                VARCHAR2(4);
 l_collector_id               VARCHAR2(30);
 l_cust_id                    VARCHAR2(500);
 l_cust_account_id            VARCHAR2(30);
 l_itd_bitand                 NUMBER;
 l_viewby                     VARCHAR2(100);
 l_hierarchical_flag          VARCHAR2(1);
 l_cust_clause                VARCHAR2(100);
 l_cust_clause2               VARCHAR2(100);

 l_customer_url               VARCHAR2(500) := NULL;
 l_open_rec_amt_det_url       VARCHAR2(500) := NULL;
 l_pastdue_rec_amt_det_url    VARCHAR2(500) := NULL;
 l_days_past_due_b1_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b2_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b3_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b4_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b5_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b6_det_url   VARCHAR2(500) := NULL;
 l_days_past_due_b7_det_url   VARCHAR2(500) := NULL;

 l_open_rec_amt_url           VARCHAR2(500) := NULL;
 l_pastdue_rec_amt_url        VARCHAR2(500) := NULL;
 l_days_past_due_b1_url       VARCHAR2(500) := NULL;
 l_days_past_due_b2_url       VARCHAR2(500) := NULL;
 l_days_past_due_b3_url       VARCHAR2(500) := NULL;
 l_days_past_due_b4_url       VARCHAR2(500) := NULL;
 l_days_past_due_b5_url       VARCHAR2(500) := NULL;
 l_days_past_due_b6_url       VARCHAR2(500) := NULL;
 l_days_past_due_b7_url       VARCHAR2(500) := NULL;

 l_open_rec_amt_url_1           VARCHAR2(500) := NULL;
 l_pastdue_rec_amt_url_1        VARCHAR2(500) := NULL;
 l_days_past_due_b1_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b2_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b3_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b4_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b5_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b6_url_1       VARCHAR2(500) := NULL;
 l_days_past_due_b7_url_1       VARCHAR2(500) := NULL;

 l_order_by                   VARCHAR2(500);
 l_order_column               VARCHAR2(100);
 l_gt_hint varchar2(500);
BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  -- Retrieve values for global variables
  l_as_of_date        := fii_ar_util_pkg.g_as_of_date;
  l_cust_suffix       := fii_ar_util_pkg.g_cust_suffix;
  l_curr_suffix       := fii_ar_util_pkg.g_curr_suffix;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;
  l_cust_account_id   := fii_ar_util_pkg.g_cust_account_id;
  l_itd_bitand        := fii_ar_util_pkg.g_bitand_inc_todate;
  l_viewby            := fii_ar_util_pkg.g_view_by;
  l_hierarchical_flag := fii_ar_util_pkg.g_is_hierarchical_flag;

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';
  -- Find out the number of bucket ranges customized for this report
  SELECT sum(decode(bbc.range1_low,  null, 0, 1) +
             decode(bbc.range2_low,  null, 0, 1) +
             decode(bbc.range3_low,  null, 0, 1) +
             decode(bbc.range4_low,  null, 0, 1) +
             decode(bbc.range5_low,  null, 0, 1) +
             decode(bbc.range6_low,  null, 0, 1) +
             decode(bbc.range7_low,  null, 0, 1) +
             decode(bbc.range8_low,  null, 0, 1) +
             decode(bbc.range9_low,  null, 0, 1) +
             decode(bbc.range10_low, null, 0, 1)) bucket_count
  INTO l_bucket_ct
  FROM bis_bucket_customizations bbc,
       bis_bucket bb
  WHERE bb.short_name  = 'FII_DBI_PAST_DUE_REC_BUCKET'
  AND   bbc.bucket_id  = bb.bucket_id;

  -- Construct the self node clause
  -- We only need this when view by customer and it is a hierarchical setup
  IF (l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'Y') THEN
    l_cust_clause  := ' , v.is_self_flag, v.is_leaf_flag ';
    l_cust_clause2 := ' , is_self_flag, is_leaf_flag ';
  ELSE
    l_cust_clause  := NULL;
    l_cust_clause2 := NULL;
  END IF;

  -----------------------------------------------------------------------------
  -- When view by Customer for leaf level customers or view by Customer Acct,
  -- we'll use the following drilldown URLs:
  --
  -- 1. Open Receivables amount will drill to Open Receivables Detail Report
  --    (Transaction Detail)
  -- 2. Past Due Receivables amount will drill to Past Due Receivables Detail
  --    Report (Transaction Detail)
  -- 3. Aging bucket X amount will drill to Receivables X days Past Due Detail
  --    report (Transaction Detail)
  -----------------------------------------------------------------------------

  IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
   --This is for sending customer id in the detail drills
   l_cust_clause := l_cust_clause ||  ' , v.party_id ';
   l_cust_clause2 := l_cust_clause2 || ' , party_id ';

   -- Open Receivables Amount Drilldown URL
   l_open_rec_amt_det_url := 'pFunctionName=FII_AR_OPEN_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

   -- Past Due Receivables Amount Drilldown URL
   l_pastdue_rec_amt_det_url  := 'pFunctionName=FII_AR_PDUE_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
  ELSE
   -- Open Receivables Amount Drilldown URL
   l_open_rec_amt_det_url := 'pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

   -- Past Due Receivables Amount Drilldown URL
   l_pastdue_rec_amt_det_url  := 'pFunctionName=FII_AR_PDUE_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

  END IF;

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b1_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b1_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=1&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 2) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b2_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=2&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b2_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=2&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 3) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b3_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=3&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b3_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=3&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 4) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b4_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_BUCKET_NUM=4&FII_AR_CUST_ACCOUNT=VIEWBYID&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b4_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=4&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 5) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b5_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=5&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b5_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=5&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 6) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b6_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=6&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS'  THEN
    l_days_past_due_b6_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=6&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  IF (l_bucket_ct >= 7) THEN
   IF l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
    l_days_past_due_b7_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&FII_AR_BUCKET_NUM=7&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   ELSIF l_viewby = 'CUSTOMER+FII_CUSTOMERS' THEN
    l_days_past_due_b7_det_url := 'pFunctionName=FII_AR_REC_PDUE_BUCKET&FII_AR_BUCKET_NUM=7&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
   END IF;
  END IF;

  -----------------------------------------------------------------------------
  -- When view by OU, Collector, or Customer (for rollup customers),
  -- we'll use the following drilldown URLs:
  --
  -- 1. Open Receivables amount will drill to Open Receivables Summary
  --    (View by Customer Account)
  -- 2. Past Due Receivables amount will drill to Past Due Receivables Aging
  --    Summary (View by Customer Account)
  -- 3. Aging bucket X amount will drill to Past Due Receivables Aging Summary
  --    (View by Customer Account)
  -----------------------------------------------------------------------------
  --Drill when View by OU or Collector
  IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
  	 -- Open Receivables Amount Drilldown URL
  	l_open_rec_amt_url_1 := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  	-- Past Due Receivables Amount Drilldown URL
  	l_pastdue_rec_amt_url_1   := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  	-- Aging Bucket X Amount Drilldown URL
  	IF (l_bucket_ct >= 1) THEN
    	l_days_past_due_b1_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 2) THEN
    	l_days_past_due_b2_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 3) THEN
    	l_days_past_due_b3_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 4) THEN
    	l_days_past_due_b4_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 5) THEN
    	l_days_past_due_b5_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 6) THEN
    	l_days_past_due_b6_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 7) THEN
    	l_days_past_due_b7_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  	END IF;
  ELSE
     	 -- Open Receivables Amount Drilldown URL
  	l_open_rec_amt_url_1  := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  	-- Past Due Receivables Amount Drilldown URL
  	l_pastdue_rec_amt_url_1   := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  	-- Aging Bucket X Amount Drilldown URL
  	IF (l_bucket_ct >= 1) THEN
    	l_days_past_due_b1_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 2) THEN
    	l_days_past_due_b2_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 3) THEN
    	l_days_past_due_b3_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 4) THEN
    	l_days_past_due_b4_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 5) THEN
    	l_days_past_due_b5_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 6) THEN
    	l_days_past_due_b6_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  	IF (l_bucket_ct >= 7) THEN
    	l_days_past_due_b7_url_1  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  	END IF;

  END IF;


  -- Open Receivables Amount Drilldown URL
  l_open_rec_amt_url := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Past Due Receivables Amount Drilldown URL
  l_pastdue_rec_amt_url  := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_days_past_due_b1_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_days_past_due_b2_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_days_past_due_b3_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 4) THEN
    l_days_past_due_b4_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 5) THEN
    l_days_past_due_b5_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 6) THEN
    l_days_past_due_b6_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 7) THEN
    l_days_past_due_b7_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  -----------------------------------------------------------------------------
  -- When view by Customer and the customer is not a leaf node,
  -- we'll drilldown to the next level in the customer hierarchy on the same report
  -----------------------------------------------------------------------------
  l_customer_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

  ----------------------------------------------------------------
  -- Construct the drilldown URL sql
  ----------------------------------------------------------------
  IF (l_viewby IN ('ORGANIZATION+FII_OPERATING_UNITS',
                   'FII_COLLECTOR+FII_COLLECTOR')) THEN
    l_url_sql :=
       ', DECODE((SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_OPEN_REC_AMT)), 0, NULL, NULL, NULL,  '''||
            l_open_rec_amt_url_1  || ''') FII_AR_OPEN_REC_DRILL,
          DECODE(sum(FII_AR_PASTDUE_REC_AMT), 0, NULL, NULL, NULL, '''||
            l_pastdue_rec_amt_url_1  || ''') FII_AR_PASTDUE_REC_DRILL, ';

    IF (l_bucket_ct >= 1) THEN
      l_url_sql := l_url_sql ||
                   ' DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B1), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b1_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B1 ';
    END IF;

    IF (l_bucket_ct >= 2) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B2), 0, NULL, NULL, NULL, '''||
                        l_days_past_due_b2_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B2 ';
    END IF;

    IF (l_bucket_ct >= 3) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B3), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b3_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B3 ';
    END IF;

    IF (l_bucket_ct >= 4) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B4), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b4_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B4 ';
    END IF;

    IF (l_bucket_ct >= 5) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B5), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b5_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B5';
    END IF;

    IF (l_bucket_ct >= 6) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B6), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b6_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B6';
    END IF;

    IF (l_bucket_ct >= 7) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B7), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b7_url_1 || ''') FII_AR_PD_BKT_AMT_DRILL_B7';
    END IF;

    l_url_sql := l_url_sql || ', NULL  FII_AR_CUSTOMER_DRILL';

  ELSIF (( l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') OR
         ((l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'N'))) THEN
    l_url_sql :=
       ', DECODE((SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_OPEN_REC_AMT)), 0, NULL, NULL, NULL,  '''||
            l_open_rec_amt_det_url  || ''') FII_AR_OPEN_REC_DRILL,
          DECODE(sum(FII_AR_PASTDUE_REC_AMT), 0, NULL, NULL, NULL, '''||
            l_pastdue_rec_amt_det_url  || ''') FII_AR_PASTDUE_REC_DRILL, ';

    IF (l_bucket_ct >= 1) THEN
      l_url_sql := l_url_sql ||
                   ' DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B1), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b1_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B1 ';
    END IF;

    IF (l_bucket_ct >= 2) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B2), 0, NULL, NULL, NULL, '''||
                        l_days_past_due_b2_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B2 ';
    END IF;

    IF (l_bucket_ct >= 3) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B3), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b3_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B3 ';
    END IF;

    IF (l_bucket_ct >= 4) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B4), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b4_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B4 ';
    END IF;

    IF (l_bucket_ct >= 5) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B5), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b5_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B5';
    END IF;

    IF (l_bucket_ct >= 6) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B6), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b6_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B6';
    END IF;

    IF (l_bucket_ct >= 7) THEN
      l_url_sql := l_url_sql ||
                   ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B7), 0, NULL, NULL, NULL, '''||
                       l_days_past_due_b7_det_url || ''') FII_AR_PD_BKT_AMT_DRILL_B7';
    END IF;

    l_url_sql := l_url_sql || ', NULL  FII_AR_CUSTOMER_DRILL';

  ELSIF ((l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'Y'))  THEN
    l_url_sql :=
       ', DECODE((SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_OPEN_REC_AMT)), 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_open_rec_amt_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_open_rec_amt_det_url || ''',
                               '''|| l_open_rec_amt_url  || '''))) FII_AR_OPEN_REC_DRILL,
          DECODE(sum(FII_AR_PASTDUE_REC_AMT), 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_pastdue_rec_amt_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_pastdue_rec_amt_det_url || ''',
                         '''|| l_pastdue_rec_amt_url  || '''))) FII_AR_PASTDUE_REC_DRILL, ';

    IF (l_bucket_ct >= 1) THEN
      l_url_sql := l_url_sql ||
        ' DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B1), 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b1_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b1_det_url || ''',
                     '''|| l_days_past_due_b1_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B1 ';
    END IF;

    IF (l_bucket_ct >= 2) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B2), 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b2_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b2_det_url || ''',
                     '''|| l_days_past_due_b2_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B2 ';
    END IF;

    IF (l_bucket_ct >= 3) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B3), 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b3_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b3_det_url || ''',
                     '''|| l_days_past_due_b3_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B3 ';
    END IF;

    IF (l_bucket_ct >= 4) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B4), 0, NULL, NULL, NULL,
           DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b4_det_url || '''
            , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b4_det_url || ''',
                     '''|| l_days_past_due_b4_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B4 ';
    END IF;

    IF (l_bucket_ct >= 5) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B5), 0, NULL, NULL, NULL,
           DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b5_det_url || '''
            , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b5_det_url || ''',
                     '''|| l_days_past_due_b5_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B5';
    END IF;

    IF (l_bucket_ct >= 6) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B6), 0, NULL, NULL, NULL,
           DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b6_det_url || '''
            , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b6_det_url || ''',
                     '''|| l_days_past_due_b6_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B6';
    END IF;

    IF (l_bucket_ct >= 7) THEN
      l_url_sql := l_url_sql ||
       ', DECODE(sum(FII_AR_PASTDUE_BUCKET_AMT_B7), 0, NULL, NULL, NULL,
           DECODE(is_self_flag, ''Y'', '''|| l_days_past_due_b7_det_url || '''
            , DECODE(is_leaf_flag, ''Y'', '''|| l_days_past_due_b7_det_url || ''',
                     '''|| l_days_past_due_b7_url || '''))) FII_AR_PD_BKT_AMT_DRILL_B7';
    END IF;

    l_url_sql := l_url_sql ||
                 ', DECODE(is_self_flag, ''Y'', NULL,
                      DECODE(is_leaf_flag, ''N'', '''|| l_customer_url || ''',
                                       NULL)) FII_AR_CUSTOMER_DRILL ';

  END IF;

  ----------------------------------------------------------------
  -- Find out the sort order column and construct the order clause
  ----------------------------------------------------------------
  IF (instr(fii_ar_util_pkg.g_order_by, ',') <> 0) THEN
     -------------------------------------------------------------
     -- This means no particular sort column is selected in the
     -- report.  Thus, sort on the default column in descending
     -- order.  NVL is added ot make sure NULL will appear last.
     -------------------------------------------------------------
     l_order_by := ' ORDER BY NVL(FII_AR_PASTDUE_REC_AMT, -999999999) DESC';

  ELSIF (instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0) THEN
     -------------------------------------------------------------
     -- This means a particular sort column is chosen to be sorted
     -- in descending order.  Add NVL to that column so NULL will
     -- appear last.
     -------------------------------------------------------------
     l_order_column := substr(fii_ar_util_pkg.g_order_by, 1,
                              instr(fii_ar_util_pkg.g_order_by, ' DESC'));
     l_order_by := ' ORDER BY NVL('|| l_order_column || ', -999999999) DESC';
  ELSE
     -------------------------------------------------------------
     -- This means user has asked for an ascending order sort.
     -- We should use PMV's order by clause
     -------------------------------------------------------------
     l_order_by := ' &ORDER_BY_CLAUSE';

  END IF;

  --------------------------------------
  -- Construct the bucket sql statements
  --------------------------------------
  i := 1;

  IF (l_bucket_ct >= 1) THEN
    l_bucket_graph_sql :=
      'sum(past_due_bucket_1_amount)  FII_AR_PASTDUE_BKT_AMT_G_B1';
    l_bucket_sql :=
      'sum(past_due_bucket_1_amount)  FII_AR_PASTDUE_BUCKET_AMT_B1';
    l_dispute_bkt_graph_sql := ' 0     FII_AR_PASTDUE_BKT_AMT_G_B1';
    l_dispute_bkt_sql       := ' 0     FII_AR_PASTDUE_BUCKET_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_bucket_graph_sql      := l_bucket_graph_sql ||
                                 ', NULL  FII_AR_PASTDUE_BKT_AMT_G_B'||i;
      l_bucket_sql            := l_bucket_sql ||
                                 ', NULL  FII_AR_PASTDUE_BUCKET_AMT_B'||i;
      l_dispute_bkt_graph_sql := l_dispute_bkt_graph_sql ||
                                 ', NULL FII_AR_PASTDUE_BKT_AMT_G_B'||i;
      l_dispute_bkt_sql       := l_dispute_bkt_sql ||
                                 ', NULL FII_AR_PASTDUE_BUCKET_AMT_B'||i;
    ELSE
      l_bucket_graph_sql      := l_bucket_graph_sql || ', sum(past_due_bucket_' || i ||
                                 '_amount)  FII_AR_PASTDUE_BKT_AMT_G_B'||i;
      l_bucket_sql            := l_bucket_sql || ', sum(past_due_bucket_' || i ||
                                 '_amount)  FII_AR_PASTDUE_BUCKET_AMT_B'||i;
      l_dispute_bkt_graph_sql := l_dispute_bkt_graph_sql ||
                                 ', 0  FII_AR_PASTDUE_BKT_AMT_G_B'||i;
      l_dispute_bkt_sql       := l_dispute_bkt_sql ||
                                 ', 0  FII_AR_PASTDUE_BUCKET_AMT_B'||i;
    END IF;
  END LOOP;

  -----------------------------------------
  -- Construct the conditional where clause
  -----------------------------------------
  -- Only add the join on collector_id if we have a specific collector selected
  -- or view by = Collector
  IF ((l_viewby = 'FII_COLLECTOR+FII_COLLECTOR') OR
      (l_collector_id <> '-111')) THEN
    l_where_clause := l_where_clause ||
                      'AND   f.collector_id = v.collector_id ';
  END IF;

  -- Only add the join on cust_acct_id if we have a specific customer acct
  -- selected or when view by = Customer Account
  IF ((l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') OR
      (l_cust_account_id <> '-111')) THEN
    l_where_clause := l_where_clause ||
                      'AND   f.cust_account_id = v.cust_account_id ';
  END IF;

  -- Only add the join on parent_party_id when view by = Customer
  IF (l_viewby = 'CUSTOMER+FII_CUSTOMERS') THEN
    l_where_clause := l_where_clause ||
                      'AND   f.parent_party_id = v.parent_party_id ';
  END IF;

  -- Only add the join on party_id when we have a specific customer
  -- selected or when view by = Customer
  IF (l_cust_id <> '-111' OR l_viewby = 'CUSTOMER+FII_CUSTOMERS') THEN
    l_where_clause := l_where_clause ||
                      'AND   f.party_id = v.party_id ';
  END IF;

  -------------------------------
  -- Construct the sql statements
  -------------------------------
  l_sqlstmt :=
    'SELECT
       viewby, viewbyid, ';

  i := 1;
  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 'sum(FII_AR_PASTDUE_BKT_AMT_G_B1) FII_AR_PASTDUE_BKT_AMT_G_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_PASTDUE_BKT_AMT_G_B' || i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
             ', sum(FII_AR_PASTDUE_BKT_AMT_G_B'||i||') FII_AR_PASTDUE_BKT_AMT_G_B'||i;
    END IF;
  END LOOP;

 -- <arcdixit> Bug 5005028. Correct column sources for open receivables and weighted ddso
  l_sqlstmt := l_sqlstmt ||',
               ROUND((SUM(FII_AR_PASTDUE_REC_AMT) * to_number(to_char(&BIS_CURRENT_ASOF_DATE , ''J''))
	       -
	       SUM(FII_AR_WEIGHTED_DDSO_NUM))/NULLIF(SUM(FII_AR_PASTDUE_REC_AMT),0)) FII_AR_WEIGHTED_DDSO_G,
               (SUM(FII_AR_PASTDUE_REC_AMT) + SUM(FII_AR_OPEN_REC_AMT))    FII_AR_OPEN_REC_AMT,
               sum(FII_AR_PASTDUE_REC_AMT) FII_AR_PASTDUE_REC_AMT,
               sum(FII_AR_PASTDUE_REC_CT)  FII_AR_PASTDUE_REC_CT,
               (SUM(FII_AR_PASTDUE_REC_AMT) * to_number(to_char(&BIS_CURRENT_ASOF_DATE , ''J''))
	       -
	       SUM(FII_AR_WEIGHTED_DDSO_NUM))/NULLIF(SUM(FII_AR_PASTDUE_REC_AMT),0)   FII_AR_WEIGHTED_DDSO,
               sum(FII_AR_DISPUTE_AMT)     FII_AR_DISPUTE_AMT,
               (sum(FII_AR_DISPUTE_AMT) / NULLIF(sum(FII_AR_PASTDUE_REC_AMT), 0) ) * 100
                   FII_AR_DISPUTE_PERCENT_TOTAL,
               sum(FII_AR_DISPUTE_CT)      FII_AR_DISPUTE_CT,';

  i := 1;
  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 'sum(FII_AR_PASTDUE_BUCKET_AMT_B1) FII_AR_PASTDUE_BUCKET_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_PASTDUE_BUCKET_AMT_B' ||i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
                 ', sum(FII_AR_PASTDUE_BUCKET_AMT_B'||i||') FII_AR_PASTDUE_BUCKET_AMT_B'||i;
    END IF;
  END LOOP;

  l_sqlstmt := l_sqlstmt || ',
               (SUM(SUM(FII_AR_PASTDUE_REC_AMT)) over() + SUM(SUM(FII_AR_OPEN_REC_AMT)) over())     FII_AR_GT_OPEN_REC_AMT,
               sum(sum(FII_AR_PASTDUE_REC_AMT)) over() FII_AR_GT_PASTDUE_REC_AMT,
               sum(sum(FII_AR_PASTDUE_REC_CT)) over()  FII_AR_GT_PASTDUE_REC_CT,
               (SUM(SUM(FII_AR_PASTDUE_REC_AMT)) over() * to_number(to_char(&BIS_CURRENT_ASOF_DATE , ''J''))
	       -
	       SUM(SUM(FII_AR_WEIGHTED_DDSO_NUM)) over())/NULLIF(SUM(SUM(FII_AR_PASTDUE_REC_AMT)) OVER(),0)   FII_AR_GT_WEIGHTED_DDSO,
               sum(sum(FII_AR_DISPUTE_AMT)) over()     FII_AR_GT_DISPUTE_AMT,
               (sum(sum(FII_AR_DISPUTE_AMT))over() / NULLIF(sum(sum(FII_AR_PASTDUE_REC_AMT))over(), 0) ) * 100
                   FII_AR_GT_DISPUTE_PCT_TOTAL,
               sum(sum(FII_AR_DISPUTE_CT)) over()      FII_AR_GT_DISPUTE_CT, ';

  i := 1;
  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 'sum(sum(FII_AR_PASTDUE_BUCKET_AMT_B1)) over() FII_AR_GT_PASTDUE_BKT_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_GT_PASTDUE_BUCKET_AMT_B'||i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
           ', sum(sum(FII_AR_PASTDUE_BUCKET_AMT_B'||i||')) over() FII_AR_GT_PASTDUE_BKT_AMT_B'||i;
    END IF;
  END LOOP;

 -- Attach the drilldown URL sql to the sql statement
 l_sqlstmt := l_sqlstmt || l_url_sql;

 FOR i IN 8..l_bucket_ct LOOP
    l_sqlstmt := l_sqlstmt
                 || ', NULL FII_AR_PD_BKT_AMT_DRILL_B' || i;
  END LOOP;

  l_sqlstmt := l_sqlstmt || '  FROM (
     SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
       v.viewby             VIEWBY,
       v.viewby_code        VIEWBYID,' ||
       l_bucket_graph_sql || ',
       sum(f.wtd_ddso_due_num)    FII_AR_WEIGHTED_DDSO_G,
       sum(f.current_open_amount) FII_AR_OPEN_REC_AMT,
       sum(f.past_due_open_amount) FII_AR_PASTDUE_REC_AMT,
       sum(f.past_due_count)      FII_AR_PASTDUE_REC_CT,
       sum(f.wtd_ddso_due_num)    FII_AR_WEIGHTED_DDSO_NUM,
       NULL                       FII_AR_DISPUTE_AMT,
       NULL                       FII_AR_DISPUTE_CT, '||
       l_bucket_sql || l_cust_clause || '
       FROM fii_ar_net_rec'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
           ( SELECT /*+ no_merge '||l_gt_hint|| ' */ *
             FROM  fii_time_structures cal, '||
                   fii_ar_util_pkg.get_from_statement ||
           ' gt WHERE cal.report_date = :ASOF_DATE
             AND   bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
             AND '|| fii_ar_util_pkg.get_where_statement || ') v
        WHERE f.time_id        = v.time_id
        AND   f.period_type_id = v.period_type_id
        AND   f.org_id         = v.org_id
        AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_where_clause ||
        ' GROUP BY v.viewby, v.viewby_code ' || l_cust_clause;

  -------------------------------------
  -- Sql for the dispute amount section
  -------------------------------------
  l_sqlstmt :=
    l_sqlstmt || ' union all '||
    'SELECT
    v.viewby       VIEWBY,
    v.viewby_code  VIEWBYID, '||
    l_dispute_bkt_graph_sql || ',
    NULL                                          FII_AR_WEIGHTED_DDSO_G,
    NULL                                          FII_AR_OPEN_REC_AMT,
    NULL                                          FII_AR_PASTDUE_REC_AMT,
    NULL                                          FII_AR_PASTDUE_REC_CT,
    NULL                                          FII_AR_WEIGHTED_DDSO_NUM,
    sum(past_due_dispute_amount)                  FII_AR_DISPUTE_AMT,
    sum(past_due_dispute_count)                   FII_AR_DISPUTE_CT, '||
    l_dispute_bkt_sql || l_cust_clause || '
    FROM fii_ar_disputes'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
       ( SELECT /*+ no_merge '||l_gt_hint|| ' */ *
         FROM  fii_time_structures cal, '||
               fii_ar_util_pkg.get_from_statement ||
       ' gt WHERE cal.report_date = :ASOF_DATE
         AND   bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
         AND  '||  fii_ar_util_pkg.get_where_statement || ') v
    WHERE f.time_id        = v.time_id
    AND   f.period_type_id = v.period_type_id
    AND   f.org_id         = v.org_id ' || l_where_clause ||
    ' GROUP BY  v.viewby, v.viewby_code ' || l_cust_clause || ') inline_view
                        GROUP BY viewby, viewbyid ' || l_cust_clause2
                        ||l_order_by;

  -- Bind variables so that no literal will be used in the pmv report
  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_pastdue_rec_aging_sql,
     p_bind_output_table  => p_pastdue_rec_aging_output);

END get_pastdue_rec_aging;

-------------------------------------------------------------------------------
-- This procedure is called by the Receivables Aging Summary report
-------------------------------------------------------------------------------
PROCEDURE get_rec_aging
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
  l_sqlstmt        VARCHAR2(30000);
  l_where_clause   VARCHAR2(2000);
  l_return_status  VARCHAR2(10);
  l_curr_label     VARCHAR2(240);
  l_bis_bucket_rec BIS_BUCKET_PUB.bis_bucket_rec_type;
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_bucket_ct      NUMBER;
  l_as_of_date     DATE;
  l_cust_suffix    VARCHAR2(6);
  l_curr_suffix    VARCHAR2(4);
  l_itd_bitand     NUMBER;
  l_collector_id   VARCHAR2(30);
  l_cust_id        VARCHAR2(500);
  l_max_bucket_ct  NUMBER := 7; -- Maximum number of bucket ranges
  l_last_bucket_num NUMBER;

  l_bkt_url        VARCHAR2(500) := NULL;
  l_curr_rec_url   VARCHAR2(500) := NULL;

  TYPE DataRec IS RECORD (
    l_label_0       VARCHAR2(240),
    l_label_1       VARCHAR2(80),
    l_label_2       VARCHAR2(80),
    l_label_3       VARCHAR2(80),
    l_label_4       VARCHAR2(80),
    l_label_5       VARCHAR2(80),
    l_label_6       VARCHAR2(80),
    l_label_7       VARCHAR2(80),
    l_curr_rec_amt  NUMBER,
    l_pdue_bkt1_amt NUMBER,
    l_pdue_bkt2_amt NUMBER,
    l_pdue_bkt3_amt NUMBER,
    l_pdue_bkt4_amt NUMBER,
    l_pdue_bkt5_amt NUMBER,
    l_pdue_bkt6_amt NUMBER,
    l_pdue_bkt7_amt NUMBER);

  TYPE DataRecTab is table of DataRec;
  TYPE num_type IS TABLE OF NUMBER;
  TYPE val_type IS TABLE OF VARCHAR2(240);

  TYPE bucket_rec IS RECORD (
    l_ord_seq num_type,
    l_label   val_type,
    l_amount  num_type );

  l_data_rec    DataRecTab;
  l_bucket_rec  BUCKET_REC;

  CURSOR rec_aging_cursor IS
    SELECT 7, l_data_rec(1).l_label_7, l_data_rec(1).l_pdue_bkt7_amt
    FROM dual
    UNION
    SELECT 6, l_data_rec(1).l_label_6, l_data_rec(1).l_pdue_bkt6_amt
    FROM dual
    UNION
    SELECT 5, l_data_rec(1).l_label_5, l_data_rec(1).l_pdue_bkt5_amt
    FROM dual
    UNION
    SELECT 4, l_data_rec(1).l_label_4, l_data_rec(1).l_pdue_bkt4_amt
    FROM dual
    UNION
    SELECT 3, l_data_rec(1).l_label_3, l_data_rec(1).l_pdue_bkt3_amt
    FROM dual
    UNION
    SELECT 2, l_data_rec(1).l_label_2, l_data_rec(1).l_pdue_bkt2_amt
    FROM dual
    UNION
    SELECT 1, l_data_rec(1).l_label_1, l_data_rec(1).l_pdue_bkt1_amt
    FROM dual
    UNION
    SELECT 0, l_data_rec(1).l_label_0, l_data_rec(1).l_curr_rec_amt
    FROM dual;

    l_fii_user_id  NUMBER(15);
    l_fii_login_id NUMBER(15);


BEGIN
  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;

  -- Retrieve values for global variables
  l_as_of_date        := fii_ar_util_pkg.g_as_of_date;
  l_cust_suffix       := fii_ar_util_pkg.g_cust_suffix;
  l_curr_suffix       := fii_ar_util_pkg.g_curr_suffix;
  l_itd_bitand        := fii_ar_util_pkg.g_bitand_inc_todate;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;

  l_fii_user_id := FND_GLOBAL.User_Id;
  l_fii_login_id := FND_GLOBAL.Login_Id;

  -- Find out the number of bucket ranges customized for this report
  SELECT sum(decode(bbc.range1_low,  null, 0, 1) +
             decode(bbc.range2_low,  null, 0, 1) +
             decode(bbc.range3_low,  null, 0, 1) +
             decode(bbc.range4_low,  null, 0, 1) +
             decode(bbc.range5_low,  null, 0, 1) +
             decode(bbc.range6_low,  null, 0, 1) +
             decode(bbc.range7_low,  null, 0, 1) +
             decode(bbc.range8_low,  null, 0, 1) +
             decode(bbc.range9_low,  null, 0, 1) +
             decode(bbc.range10_low, null, 0, 1)) bucket_count
  INTO l_bucket_ct
  FROM bis_bucket_customizations bbc,
       bis_bucket bb
  WHERE bb.short_name  = 'FII_DBI_PAST_DUE_REC_BUCKET'
  AND   bbc.bucket_id  = bb.bucket_id;

  -------------------------------------------------------------------------
  -- Construct the drilldown URLs:
  -- 1. Bucket amounts should drill to Past Due Receivables Aging Summary
  --    view by Customer
  -- 2. Current Receivables amount should drill to Current Receivables
  --    Summary view by Customer
  -------------------------------------------------------------------------
  l_bkt_url := 'pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y';

  l_curr_rec_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y';

  -----------------------------------------
  -- Construct the conditional where clause
  -----------------------------------------
  -- Only add the join on collector_id if we have a specific collector selected
  IF (l_collector_id <> '-111') THEN
    l_where_clause := l_where_clause ||
                      'AND   f.collector_id = v.collector_id ';
  END IF;

  -- Only add the join on party_id when we have a specific customer
  -- selected
  IF (l_cust_id <> '-111') THEN
    l_where_clause := l_where_clause ||
                      'AND   f.party_id = v.party_id ';
  END IF;

  -- Clean up temp table
  delete from FII_AR_REC_AGING_SUM_GT;

  -- Retrieve the bucket labels for this report and insert into temp table
  BIS_BUCKET_PUB.retrieve_bis_bucket (
    p_short_name	=> 'FII_DBI_PAST_DUE_REC_BUCKET',
    x_bis_bucket_rec	=> l_bis_bucket_rec,
    x_return_status	=> l_return_status,
    x_error_tbl 	=> l_error_tbl
  );

  -- Retrive the label for current receivables
  l_curr_label := FND_MESSAGE.get_string('FII', 'FII_AR_CURR_REC');

  --------------------------------------------------------------------
  -- Find out receivables aging amounts and current receivables amount
  -- and store the info into pl/sql table l_data_rec
  --------------------------------------------------------------------
  l_sqlstmt :=
    'SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/ ''' ||
       l_curr_label || ''' ,''' ||
       l_bis_bucket_rec.range1_name || ''' ,''' ||
       l_bis_bucket_rec.range2_name || ''' ,''' ||
       l_bis_bucket_rec.range3_name || ''' ,''' ||
       l_bis_bucket_rec.range4_name || ''' ,''' ||
       l_bis_bucket_rec.range5_name || ''' ,''' ||
       l_bis_bucket_rec.range6_name || ''' ,''' ||
       l_bis_bucket_rec.range7_name || ''' ,
       SUM(f.current_bucket_1_amount) + SUM(f.current_bucket_2_amount)
       + SUM(f.current_bucket_3_amount),
       SUM(f.past_due_bucket_1_amount),
       SUM(f.past_due_bucket_2_amount),
       SUM(f.past_due_bucket_3_amount),
       SUM(f.past_due_bucket_4_amount),
       SUM(f.past_due_bucket_5_amount),
       SUM(f.past_due_bucket_6_amount),
       SUM(f.past_due_bucket_7_amount)
     FROM fii_ar_net_rec'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
           ( SELECT /*+ no_merge leading(gt) cardinality(gt 1)*/ *
             FROM  fii_time_structures cal, '||
                   fii_ar_util_pkg.get_from_statement ||
           ' gt WHERE cal.report_date = '''||l_as_of_date||
           '''  AND   bitand(cal.record_type_id, '||l_itd_bitand||') = 512
             AND '|| fii_ar_util_pkg.get_where_statement || ') v
        WHERE f.time_id        = v.time_id
        AND   f.period_type_id = v.period_type_id
        AND   f.org_id         = v.org_id
	AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_where_clause;

  EXECUTE IMMEDIATE l_sqlstmt BULK COLLECT INTO l_data_rec;

  -----------------------------------------------------------------
  -- Use the rec_aging_cursor to turn our row in l_dat_rec
  -- into columns and insert the appropriate values into
  -- FII_AR_REC_AGING_SUM_GT
  -----------------------------------------------------------------
  OPEN rec_aging_cursor;
  FETCH rec_aging_cursor BULK COLLECT INTO l_bucket_rec.l_ord_seq,
                                           l_bucket_rec.l_label,
                                           l_bucket_rec.l_amount;
  CLOSE rec_aging_cursor;

  -- We should only insert data for bucket ranges set up and the
  -- Current Receivables into FII_AR_REC_AGING_SUM_GT.  If bucket ranges
  -- exceed the maximum allowed for this report (7 ranges) we will
  -- only display up to the 7th bucket plus the Current Receivables data
  IF (l_bucket_ct > l_max_bucket_ct) THEN
    l_last_bucket_num := l_max_bucket_ct + 1;
  ELSE
    l_last_bucket_num := l_bucket_ct + 1;
  END IF;

  FORALL i IN l_bucket_rec.l_ord_seq.FIRST .. l_last_bucket_num
    INSERT INTO FII_AR_REC_AGING_SUM_GT
    ( ord_seq, label, amount, creation_date, created_by, last_update_date, last_updated_by, last_update_login )
    VALUES
    ( l_bucket_rec.l_ord_seq(i),
      l_bucket_rec.l_label(i),
      l_bucket_rec.l_amount(i),
      sysdate,
      l_fii_user_id,
      sysdate,
      l_fii_user_id,
      l_fii_login_id);

  -- Build sql statement
  l_sqlstmt := 'SELECT
                amount  FII_AR_REC_AMT_G,
                label   FII_AR_REC_LABEL,
                amount  FII_AR_REC_AMT,
                DECODE( amount, 0, NULL,
                                NULL, NULL,
                                DECODE(ord_seq,
                                 0, '''||l_curr_rec_url ||''',
                                    '''||l_bkt_url ||''')) FII_AR_REC_AMT_DRILL
                FROM FII_AR_REC_AGING_SUM_GT
                ORDER BY ord_seq desc';

  -- Bind variables so that no literal will be used in the pmv report
  fii_ar_util_pkg.bind_variable
    (p_sqlstmt            => l_sqlstmt,
     p_page_parameter_tbl => p_page_parameter_tbl,
     p_sql_output         => p_pastdue_rec_aging_sql,
     p_bind_output_table  => p_pastdue_rec_aging_output);

END get_rec_aging;


END FII_AR_REC_AGING_PKG;


/
