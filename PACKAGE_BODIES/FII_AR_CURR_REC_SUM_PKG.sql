--------------------------------------------------------
--  DDL for Package Body FII_AR_CURR_REC_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_CURR_REC_SUM_PKG" AS
/* $Header: FIIARDBICRB.pls 120.11 2007/05/15 20:48:15 vkazhipu ship $ */

PROCEDURE GET_CURR_REC_SUM
      (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       curr_rec_sql out NOCOPY VARCHAR2,
       curr_rec_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_as_of_date        DATE;
  l_cust_suffix       VARCHAR2(30);
  l_curr_suffix       VARCHAR2(30);
  l_collector_id      VARCHAR2(30);
  l_cust_id           VARCHAR2(500);
  l_cust_account_id   VARCHAR2(30);
  l_itd_bitand        NUMBER;
  l_viewby            VARCHAR2(100);
  l_self_msg          VARCHAR2(240);
  l_hierarchical_flag VARCHAR2(1);
  l_cust_clause       VARCHAR2(100);
  l_order_by_clause   VARCHAR2(500);
  l_order_column      VARCHAR2(50);
  l_where_clause      VARCHAR2(500);

  l_max_bucket_ct     NUMBER := 3;
  l_bucket_ct         NUMBER;

  l_customer_url             VARCHAR2(500) := NULL;
  l_open_rec_amt_det_url     VARCHAR2(500) := NULL;
  l_curr_rec_amt_det_url     VARCHAR2(500) := NULL;
  l_curr_due_days_b1_det_url VARCHAR2(500) := NULL;
  l_curr_due_days_b2_det_url VARCHAR2(500) := NULL;
  l_curr_due_days_b3_det_url VARCHAR2(500) := NULL;
  l_open_rec_amt_url         VARCHAR2(500) := NULL;
  l_curr_rec_amt_url         VARCHAR2(500) := NULL;
  l_curr_due_days_b1_url     VARCHAR2(500) := NULL;
  l_curr_due_days_b2_url     VARCHAR2(500) := NULL;
  l_curr_due_days_b3_url     VARCHAR2(500) := NULL;
  l_or_ca_amt_det_url        VARCHAR2(500) := NULL;
  l_cr_ca_amt_det_url        VARCHAR2(500) := NULL;
  l_cdd_ca_b1_det_url        VARCHAR2(500) := NULL;
  l_cdd_ca_b2_det_url        VARCHAR2(500) := NULL;
  l_cdd_ca_b3_det_url        VARCHAR2(500) := NULL;
  l_open_rec_amt_url_1         VARCHAR2(500) := NULL;
  l_curr_rec_amt_url_1        VARCHAR2(500) := NULL;
  l_curr_due_days_b1_url_1     VARCHAR2(500) := NULL;
  l_curr_due_days_b2_url_1     VARCHAR2(500) := NULL;
  l_curr_due_days_b3_url_1     VARCHAR2(500) := NULL;

  l_url_sql                  VARCHAR2(10000);
  l_bucket_sql               VARCHAR2(1000);
  l_sqlstmt                  VARCHAR2(32767);
  i                          NUMBER;
  l_gt_hint varchar2(500);


BEGIN


  -- Reset all the global variables to NULL or to the default value
  fii_ar_util_pkg.reset_globals;

  -- Get the parameters and set the global variables
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';
  -- Retrieve values for global variables
  l_as_of_date        := fii_ar_util_pkg.g_as_of_date;
  l_cust_suffix       := fii_ar_util_pkg.g_cust_suffix;
  l_curr_suffix       := fii_ar_util_pkg.g_curr_suffix;
  l_collector_id      := fii_ar_util_pkg.g_collector_id;
  l_cust_id           := fii_ar_util_pkg.g_party_id;
  l_cust_account_id   := fii_ar_util_pkg.g_cust_account_id;
  l_itd_bitand        := fii_ar_util_pkg.g_bitand_inc_todate;
  l_viewby            := fii_ar_util_pkg.g_view_by;
  l_self_msg          := fii_ar_util_pkg.g_self_msg;
  l_hierarchical_flag := fii_ar_util_pkg.g_is_hierarchical_flag;

  -- Populate global temp table based on the parameters chosen
  fii_ar_util_pkg.populate_summary_gt_tables;


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
  WHERE bb.short_name  = 'FII_DBI_CURRENT_REC_BUCKET'
  AND   bbc.bucket_id  = bb.bucket_id;

  -- Construct the self node clause
  -- We only need this when view by customer and it is a hierarchical setup
  IF (l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'Y') THEN
    l_cust_clause  := ' , v.is_self_flag, v.is_leaf_flag ';
  ELSIF (l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
    l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
    l_cust_clause  := ' , v.party_id ';
  ELSE
    l_cust_clause  := NULL;
  END IF;

-----------------------------------------------------------------------------
  -- When view by Customer for leaf level customers, we'll use the following
  -- drilldown URLs (and pass null to Customer Account):
  --
  -- 1. Open Receivables amount will drill to Open Receivables Detail Report
  --    (Transaction Detail)
  -- 2. Current Receivables amount will drill to Current Receivables Detail
  --    Report (Transaction Detail)
  -- 3. Aging Bucket X amount will drill to Receivables Due in X days Detail
  --    report (Transaction Detail)
  -----------------------------------------------------------------------------
  -- Open Receivables Amount Drilldown URL
  l_open_rec_amt_det_url := 'pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  -- Past Due Receivables Amount Drilldown URL
  l_curr_rec_amt_det_url  := 'pFunctionName=FII_AR_CURR_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_curr_due_days_b1_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_BUCKET_NUM=1';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_curr_due_days_b2_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_BUCKET_NUM=2';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_curr_due_days_b3_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_BUCKET_NUM=3';
  END IF;

-----------------------------------------------------------------------------
  -- When view by Customer Acct, we'll use the following drilldown URLs
  -- (and pass customer account):
  --
  -- 1. Open Receivables amount will drill to Open Receivables Detail Report
  --    (Transaction Detail)
  -- 2. Current Receivables amount will drill to Current Receivables Detail
  --    Report (Transaction Detail)
  -- 3. Aging Bucket X amount will drill to Receivables Due in X days Detail
  --    report (Transaction Detail)
  -----------------------------------------------------------------------------
  -- Open Receivables Amount Drilldown URL
  l_or_ca_amt_det_url := 'pFunctionName=FII_AR_OPEN_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  -- Past Due Receivables Amount Drilldown URL
  l_cr_ca_amt_det_url  := 'pFunctionName=FII_AR_CURR_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_cdd_ca_b1_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y&FII_AR_BUCKET_NUM=1';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_cdd_ca_b2_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y&FII_AR_BUCKET_NUM=2';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_cdd_ca_b3_det_url := 'pFunctionName=FII_AR_REC_DUE_BUCKET&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y&FII_AR_BUCKET_NUM=3';
  END IF;


  -----------------------------------------------------------------------------
  -- When view by OU, Collector, or Customer (for rollup customers),
  -- we'll use the following drilldown URLs:
  --
  -- 1. Open Receivables amount will drill to Open Receivables Summary
  --    (View by Customer Account)
  -- 2. Current Receivables amount will drill to Current Receivables
  --    Summary (View by Customer Account)
  -- 3. Aging bucket X amount will drill to Current Receivables Summary
  --    (View by Customer Account)
  -----------------------------------------------------------------------------

 IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
    -- Open Receivables Amount Drilldown URL
  l_open_rec_amt_url_1 := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Current Receivables Amount Drilldown URL
  l_curr_rec_amt_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_curr_due_days_b1_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_curr_due_days_b2_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_curr_due_days_b3_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;
 ELSE
    -- Open Receivables Amount Drilldown URL
  l_open_rec_amt_url_1 := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  -- Current Receivables Amount Drilldown URL
  l_curr_rec_amt_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_curr_due_days_b1_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_curr_due_days_b2_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_curr_due_days_b3_url_1 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;
 END IF;



  -- Open Receivables Amount Drilldown URL
  l_open_rec_amt_url := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Current Receivables Amount Drilldown URL
  l_curr_rec_amt_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Aging Bucket X Amount Drilldown URL
  IF (l_bucket_ct >= 1) THEN
    l_curr_due_days_b1_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 2) THEN
    l_curr_due_days_b2_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  IF (l_bucket_ct >= 3) THEN
    l_curr_due_days_b3_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  END IF;

  -----------------------------------------------------------------------------
  -- When view by Customer and the customer is not a leaf node,
  -- we'll drilldown to the next level in the customer hierarchy on the same report
  -----------------------------------------------------------------------------
  l_customer_url := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

  ----------------------------------------------------------------
  -- Construct the drilldown URL sql
  ----------------------------------------------------------------
  IF (l_viewby IN ('ORGANIZATION+FII_OPERATING_UNITS',
                   'FII_COLLECTOR+FII_COLLECTOR')) THEN
     l_url_sql :=
       ', DECODE(FII_AR_OPEN_REC_AMT, 0, NULL, NULL, NULL, '''||
            l_open_rec_amt_url_1  || ''') FII_AR_OPEN_REC_DRILL,
          DECODE(FII_AR_CURR_REC_AMT, 0, NULL, NULL, NULL, '''||
            l_curr_rec_amt_url_1  || ''') FII_AR_CURR_REC_AMT_DRILL ';

     IF (l_bucket_ct >= 1) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B1, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b1_url_1 || ''') FII_AR_CR_BKT_AMT_DRILL_B1 ';
     END IF;

     IF (l_bucket_ct >= 2) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B2, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b2_url_1 || ''') FII_AR_CR_BKT_AMT_DRILL_B2 ';
     END IF;

     IF (l_bucket_ct >= 3) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B3, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b3_url_1 || ''') FII_AR_CR_BKT_AMT_DRILL_B3';
     END IF;

     l_url_sql := l_url_sql || ', NULL  FII_AR_CUSTOMER_DRILL';

  ELSIF ((l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'N')) THEN
     l_url_sql :=
       ', DECODE(FII_AR_OPEN_REC_AMT, 0, NULL, NULL, NULL, '''||
          l_open_rec_amt_det_url  || ''') FII_AR_OPEN_REC_DRILL,
            DECODE(FII_AR_CURR_REC_AMT, 0, NULL, NULL, NULL, '''||
            l_curr_rec_amt_det_url  || ''') FII_AR_CURR_REC_AMT_DRILL ';

     IF (l_bucket_ct >= 1) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B1, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b1_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B1 ';
     END IF;

     IF (l_bucket_ct >= 2) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B2, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b2_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B2 ';
     END IF;

     IF (l_bucket_ct >= 3) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B3, 0, NULL, NULL, NULL, '''||
                    l_curr_due_days_b3_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B3 ';
     END IF;

     l_url_sql := l_url_sql || ', NULL  FII_AR_CUSTOMER_DRILL';

  ELSIF (l_viewby = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
     l_url_sql :=
       ', DECODE(FII_AR_OPEN_REC_AMT, 0, NULL, NULL, NULL, '''||
          l_or_ca_amt_det_url  || ''') FII_AR_OPEN_REC_DRILL,
            DECODE(FII_AR_CURR_REC_AMT, 0, NULL, NULL, NULL, '''||
            l_cr_ca_amt_det_url  || ''') FII_AR_CURR_REC_AMT_DRILL ';

     IF (l_bucket_ct >= 1) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B1, 0, NULL, NULL, NULL, '''||
                    l_cdd_ca_b1_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B1 ';
     END IF;

     IF (l_bucket_ct >= 2) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B2, 0, NULL, NULL, NULL, '''||
                    l_cdd_ca_b2_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B2 ';
     END IF;

     IF (l_bucket_ct >= 3) THEN
       l_url_sql := l_url_sql ||
                    ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B3, 0, NULL, NULL, NULL, '''||
                    l_cdd_ca_b3_det_url || ''') FII_AR_CR_BKT_AMT_DRILL_B3 ';
     END IF;

     l_url_sql := l_url_sql || ', NULL  FII_AR_CUSTOMER_DRILL';

  ELSIF ((l_viewby = 'CUSTOMER+FII_CUSTOMERS') AND (l_hierarchical_flag = 'Y'))  THEN
     l_url_sql :=
       ', DECODE(FII_AR_OPEN_REC_AMT, 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_open_rec_amt_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_open_rec_amt_det_url || ''',
                         '''|| l_open_rec_amt_url  || '''))) FII_AR_OPEN_REC_DRILL,
          DECODE(FII_AR_CURR_REC_AMT, 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_curr_rec_amt_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_curr_rec_amt_det_url || ''',
                         '''|| l_curr_rec_amt_url  || '''))) FII_AR_CURR_REC_AMT_DRILL ';

    IF (l_bucket_ct >= 1) THEN
      l_url_sql := l_url_sql ||
        ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B1, 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_curr_due_days_b1_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_curr_due_days_b1_det_url || ''',
                     '''|| l_curr_due_days_b1_url || '''))) FII_AR_CR_BKT_AMT_DRILL_B1 ';
    END IF;

    IF (l_bucket_ct >= 2) THEN
      l_url_sql := l_url_sql ||
        ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B2, 0, NULL, NULL, NULL,
            DECODE(is_self_flag, ''Y'', '''|| l_curr_due_days_b2_det_url || '''
             , DECODE(is_leaf_flag, ''Y'', '''|| l_curr_due_days_b2_det_url || ''',
                     '''|| l_curr_due_days_b2_url || '''))) FII_AR_CR_BKT_AMT_DRILL_B2 ';
    END IF;

    IF (l_bucket_ct >= 3) THEN
      l_url_sql := l_url_sql ||
        ', DECODE(FII_AR_CURR_REC_BUCKET_AMT_B3, 0, NULL, NULL, NULL,
           DECODE(is_self_flag, ''Y'', '''|| l_curr_due_days_b3_det_url || '''
            , DECODE(is_leaf_flag, ''Y'', '''|| l_curr_due_days_b3_det_url || ''',
                     '''|| l_curr_due_days_b3_url || '''))) FII_AR_CR_BKT_AMT_DRILL_B3';
    END IF;

    l_url_sql := l_url_sql ||
                 ', DECODE(is_self_flag, ''Y'', NULL,
                      DECODE(is_leaf_flag, ''N'', '''|| l_customer_url || ''',
                                       NULL)) FII_AR_CUSTOMER_DRILL ';


  END IF;

  -----------------------------------------
  -- Construct the order by clause
  -----------------------------------------
  IF(instr(fii_ar_util_pkg.g_order_by, ',') <> 0) THEN
    /*This means no particular sort column is selected in the report. So sort on
      the default column in descending order.  NVL is added to make sure the null
      values appear last. */
    l_order_by_clause := 'ORDER BY NVL(FII_AR_CURR_REC_AMT, -999999999) DESC';

  ELSIF(instr(fii_ar_util_pkg.g_order_by, 'DESC') <> 0)THEN
    /*This means a particular sort column is clicked to have descending order in which
      case we would want all the null values to appear last in the report so add an
      NVL to that column.*/
    l_order_column := substr(fii_ar_util_pkg.g_order_by, 1,
                             instr(fii_ar_util_pkg.g_order_by, ' DESC'));
    l_order_by_clause := 'ORDER BY NVL('||l_order_column ||', -999999999) DESC';
  ELSE
    /*This is the case when user has asked for an ascending order sort.  Use PMV's
      order by clause*/
    l_order_by_clause := ' &ORDER_BY_CLAUSE';
  END IF;

  --------------------------------------
  -- Construct the bucket sql statements
  --------------------------------------
  i := 1;

  IF (l_bucket_ct >= 1) THEN
    l_bucket_sql :=
      ', sum(current_bucket_1_amount)  FII_AR_CURR_REC_BUCKET_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_bucket_sql            := l_bucket_sql ||
                                 ', NULL  FII_AR_CURR_REC_BUCKET_AMT_B'||i;
    ELSE
      l_bucket_sql            := l_bucket_sql || ', sum(current_bucket_' || i ||
                                 '_amount)  FII_AR_CURR_REC_BUCKET_AMT_B'||i;
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
      (l_cust_account_id <> -111)) THEN
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
    'SELECT VIEWBY,
            VIEWBYID ';

  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 ', FII_AR_CURR_REC_BUCKET_AMT_B1 FII_AR_CURR_REC_BKT_AMT_G_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_CURR_REC_BUCKET_AMT_B' || i || ' FII_AR_CURR_REC_BKT_AMT_G_B' || i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
                 ', FII_AR_CURR_REC_BUCKET_AMT_B'|| i || ' FII_AR_CURR_REC_BKT_AMT_G_B' || i;
    END IF;
  END LOOP;

  l_sqlstmt := l_sqlstmt ||
    ',      FII_AR_OPEN_REC_AMT,
            FII_AR_CURR_REC_AMT,
            FII_AR_CURR_REC_CT,
            FII_AR_WEIGHTED_TO ';

  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 ', FII_AR_CURR_REC_BUCKET_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_CURR_REC_BUCKET_AMT_B' ||i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
                 ', FII_AR_CURR_REC_BUCKET_AMT_B'||i;
    END IF;
  END LOOP;

  l_sqlstmt := l_sqlstmt || ',
               sum(FII_AR_OPEN_REC_AMT) over()   FII_AR_GT_OPEN_REC_AMT,
               sum(FII_AR_CURR_REC_AMT) over()   FII_AR_GT_CURR_REC_AMT,
               sum(FII_AR_CURR_REC_CT) over()    FII_AR_GT_CURR_REC_CT,
               sum(WTD_TERMS_OUT_CURRENT_NUM) over() /
                  NULLIF(sum(FII_AR_CURR_REC_AMT) over (), 0)   FII_AR_GT_WEIGHTED_TO ';

  IF (l_bucket_ct >= 1) THEN
    l_sqlstmt := l_sqlstmt ||
                 ', sum(FII_AR_CURR_REC_BUCKET_AMT_B1) over() FII_AR_GT_CURR_REC_BKT_AMT_B1';
  END IF;

  FOR i IN 2..l_bucket_ct LOOP
    IF (i > l_max_bucket_ct) THEN
      l_sqlstmt := l_sqlstmt ||
                   ', NULL FII_AR_GT_CURR_REC_BKT_AMT_B'||i;
    ELSE
      l_sqlstmt := l_sqlstmt ||
           ', sum(FII_AR_CURR_REC_BUCKET_AMT_B'||i||') over() FII_AR_GT_CURR_REC_BKT_AMT_B'||i;
    END IF;
  END LOOP;

  -- Attach the drilldown URL sql to the sql statement
  l_sqlstmt := l_sqlstmt || l_url_sql;

  FOR i IN 4..l_bucket_ct LOOP
    l_sqlstmt := l_sqlstmt
                 || ', NULL FII_AR_CR_BKT_AMT_DRILL_B' || i;
  END LOOP;

  l_sqlstmt := l_sqlstmt || '  FROM (
        SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
               v.viewby VIEWBY,
               v.viewby_code VIEWBYID,
               sum(f.total_open_amount)      FII_AR_OPEN_REC_AMT,
               sum(f.current_open_amount)    FII_AR_CURR_REC_AMT,
               sum(f.current_open_count)     FII_AR_CURR_REC_CT,
               sum(f.wtd_terms_out_current_num) WTD_TERMS_OUT_CURRENT_NUM,
               sum(f.wtd_terms_out_current_num) / NULLIF(sum(f.current_open_amount),0)     FII_AR_WEIGHTED_TO ' ||
               l_bucket_sql || l_cust_clause || '
        FROM fii_ar_net_rec'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
             (SELECT /*+ no_merge '||l_gt_hint|| ' */ *
              FROM fii_time_structures cal, '||
                   fii_ar_util_pkg.get_from_statement ||
            ' gt WHERE cal.report_date = :ASOF_DATE
              AND   bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
              AND '|| fii_ar_util_pkg.get_where_statement || ') v
        WHERE f.time_id = v.time_id
        AND   f.period_type_id = v.period_type_id
        AND   f.org_id = v.org_id
        AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_where_clause ||
        ' GROUP BY v.viewby, v.viewby_code ' || l_cust_clause || ' ) inner_view ' || l_order_by_clause;


FII_AR_UTIL_PKG.Bind_Variable(
  p_sqlstmt => l_sqlstmt,
  p_page_parameter_tbl => p_page_parameter_tbl,
  p_sql_output => curr_rec_sql,
  p_bind_output_table => curr_rec_output);


END GET_CURR_REC_SUM;

END FII_AR_CURR_REC_SUM_PKG;

/
