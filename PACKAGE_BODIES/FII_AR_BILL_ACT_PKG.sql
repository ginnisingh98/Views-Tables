--------------------------------------------------------
--  DDL for Package Body FII_AR_BILL_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_BILL_ACT_PKG" AS
/*  $Header: FIIARDBIBAB.pls 120.19 2007/05/15 20:46:27 vkazhipu ship $ */

--   This package will provide sql statements to retrieve data for Billing Activity


-- --------------------------------------------------------------------------
-- Name : get_billing_activity
-- Type : Procedure
-- Description : This procedure passes SQL to PMV for Billing Activity Report
-----------------------------------------------------------------------------


PROCEDURE get_billing_activity (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, bill_act_sum_sql out NOCOPY VARCHAR2,
  bill_sum_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt			VARCHAR2(30000);
  l_sql_stmt1                    VARCHAR2(20000);
  l_view_by_flag                NUMBER(1);
  l_view_by                     VARCHAR2(120);
  l_customer_where              VARCHAR2(60);
  l_cust_acct_where             VARCHAR2(60);
  l_org_where                   VARCHAR2(30);
  l_industry_where              VARCHAR2(240);
  l_where_clause                VARCHAR2(1000);
  l_inner_from_clause           VARCHAR2(60);
  l_inner_where_clause          VARCHAR2(60);
  l_child_party_where           VARCHAR2(60);

  l_bill_act_amt_drill          VARCHAR2(120);
  l_cust_acct_or_leaf_amt_drill VARCHAR2(240);
  l_bill_act_count_drill        VARCHAR2(120);
  l_acct_or_leaf_count_drill VARCHAR2(120);
  l_open_rec_drill              VARCHAR2(120);
  l_cust_acct_or_leaf_rec_drill VARCHAR2(240);
  l_customer_drill               VARCHAR2(120);

  l_self_mesg                   VARCHAR2(20);
  l_dso_period                  NUMBER(3);
  l_cust_suffix                 VARCHAR2(5);
  l_curr_suffix                 VARCHAR2(4);
  l_viewby_id                   VARCHAR2(30);

  l_inv_flag                    VARCHAR2(1);
  l_dm_flag                     VARCHAR2(1);
  l_cb_flag                     VARCHAR2(1);
  l_br_flag                     VARCHAR2(1);
  l_dep_flag                    VARCHAR2(1);
  l_cm_flag                     VARCHAR2(1);
  l_undep_flag                  VARCHAR2(1);
  l_unrec_flag                  VARCHAR2(1);
  l_oacb_flag                   VARCHAR2(1);
  l_ocb_flag                    VARCHAR2(1);

  l_class_inclusion             VARCHAR2(1000);
  l_unapp_amount                VARCHAR2(30);

  l_order_by			varchar2(500);
  l_order_column		varchar2(100);
  l_gt_hint varchar2(500);
BEGIN



    /* Reset Global Variables */
    fii_ar_util_pkg.reset_globals;




/* Get the parameters that the user has selected */
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);


/* Populate the dimension combination(s) that the user has access to */
fii_ar_util_pkg.populate_summary_gt_tables;



-- Get the view by
l_view_by := fii_ar_util_pkg.g_view_by;

/* Check whether join on party is is reqd. or not */
IF (fii_ar_util_pkg.g_party_id <> '-111' OR l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
    l_child_party_where := ' AND f.party_id   = gt.party_id ';
END IF;

-- Check whether we need a filter for parent_party_id. This is applicable only if the Ct. dimension is hierarchial and view by
-- is customer.
IF fii_ar_util_pkg.g_is_hierarchical_flag = 'Y' and l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
       l_customer_where := ' and f.parent_party_id = gt.parent_party_id';
       l_view_by_flag :=2; -- for Customer
END IF;

l_gt_hint := ' leading(t) cardinality(t 1) ';

-- Checks whether filter for Ct. acct. is reqd or not
IF l_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
       l_cust_acct_where := ' and f.cust_account_id = gt.cust_account_id';
       l_view_by_flag:=3;
       --Added by vkazhipu for performance reasons.
       l_gt_hint := ' leading(t.gt) cardinality(t.gt 1) ';
END IF;

/* Org filter will be there in all cases */
      l_org_where := ' and f.org_id=gt.org_id';

/* Check whether industry filter is reqd or not */
IF  l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
       l_industry_where := NULL;
ELSIF fii_ar_util_pkg.g_industry_id <> '-111' OR l_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
      l_industry_where := ' and f.class_code=gt.class_code and f.class_category=gt.class_category';
END IF;

-- The below mentioned variable will make the code easy to understand.
   l_where_clause := l_child_party_where||l_customer_where || l_cust_acct_where || l_org_where||l_industry_where;


-- Drills
  --  Drill on amount to Billing Activity with view by as ct acct
  --  Drill on Open Receivables. Drill to Open Receivable Summary with view by as ct. acct.
  --  Drill on View By. This is true only in case the view by is Ct. and the implementation is hierarchial
  IF (l_view_by_flag = 2 ) /* View by is ct. and implementation is heirarchial */ THEN
--vkazhipu changed
        	l_bill_act_amt_drill := 'pFunctionName=FII_AR_BILLING_ACTIVITY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
					l_open_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
        --   IF (l_view_by = 'CUSTOMER+FII_CUSTOMERS' and fii_ar_util_pkg.g_is_hierarchical_flag='Y' ) THEN
           --   l_view_by_flag:=2;
	        l_customer_drill:= 'pFunctionName=FII_AR_BILLING_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	       -- END IF;
END IF;
  IF l_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' OR
     l_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
      IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
       l_bill_act_amt_drill := 'pFunctionName=FII_AR_BILLING_ACTIVITY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
		   l_open_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
      ELSE
       --l_bill_act_amt_drill := 'pFunctionName=FII_AR_BILLING_ACTIVITY&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
		   --l_open_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
       l_bill_act_amt_drill := 'pFunctionName=FII_AR_BILLING_ACTIVITY&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
		   l_open_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';

      END IF;
       l_view_by_flag := 1; -- for OU, Industry
  END IF;

-- Drill on amount and view by is ct acct or ct is leaf. Drilll to Billing Activity Detail
-- added the if for Bug#5140376
IF l_view_by_flag = 3 THEN
  l_cust_acct_or_leaf_amt_drill := 'pFunctionName=FII_AR_BILLING_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
ELSE
  l_cust_acct_or_leaf_amt_drill := 'pFunctionName=FII_AR_BILLING_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;


-- Drill on Count. Drill to Billing Activity Trend in all cases except when the view by is Ct. acct.
-- As per mail from Renu , the drill for count should be enabled even in case of view by as ct acct.
/*  IF l_view_by_flag=3 THEN
     l_bill_act_count_drill := NULL;
  ELSE */
     l_bill_act_count_drill := 'pFunctionName=FII_AR_BILLING_ACT_TREND&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
--  END IF;

  --Bug#5114003: Pass party_id to trend report for view by ct. acct.
  IF l_view_by_flag=3 THEN
     l_bill_act_count_drill:=l_bill_act_count_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
  END IF;

 -- Drill on open rec and view by is ct. acct or ct is leaf. Drill to open rec detail.
 -- added the if for bug Bug#5140376
 IF l_view_by_flag = 3 THEN
     l_cust_acct_or_leaf_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
 ELSE
     l_cust_acct_or_leaf_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
 END IF;

l_dso_period := fiI_ar_util_pkg.g_dso_period;


l_cust_suffix := fii_ar_util_pkg.g_cust_suffix;
l_curr_suffix := fii_ar_util_pkg.g_curr_suffix;


/* Get the transaction classes based on DSO setup */
fii_ar_util_pkg.get_dso_table_values;

l_class_inclusion := 0;


For i in fii_ar_util_pkg.g_dso_table.FIRST..fii_ar_util_pkg.g_dso_table.LAST LOOP

    IF fii_ar_util_pkg.g_dso_table(i).dso_value = 'Y' THEN
        IF fii_ar_util_pkg.g_dso_table(i).dso_type = 'INV' THEN
           l_class_inclusion := l_class_inclusion ||'+ f.INV_AMOUNT';
        ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'DM' THEN
           l_class_inclusion := l_class_inclusion ||'+ f.DM_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'CB' THEN
	   l_class_inclusion := l_class_inclusion ||'+ f.CB_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'BR' THEN
	   l_class_inclusion := l_class_inclusion ||'+ f.BR_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'DEP' THEN
	   l_class_inclusion := l_class_inclusion ||'+ f. DEP_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'CM' THEN
	   l_class_inclusion := l_class_inclusion ||'+ f.ON_ACCOUNT_CREDIT_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'UNDEP' THEN
	   l_class_inclusion := l_class_inclusion ||'- f.UNAPP_DEP_AMOUNT';
	 ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'UNREC' THEN
	  -- l_class_inclusion := l_class_inclusion ||'- f.UNAPP_AMOUNT';
	   l_unapp_amount := '- f.UNAPP_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'OACB' THEN
	   l_class_inclusion := l_class_inclusion ||'- f.ON_ACCOUNT_CASH_AMOUNT';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'OCB' THEN
	   l_class_inclusion := l_class_inclusion ||'- f.CLAIM_AMOUNT ';
	ELSIF fii_ar_util_pkg.g_dso_table(i).dso_type = 'PREPAY' THEN
	   l_class_inclusion := l_class_inclusion ||'- f.PREPAYMENT_AMOUNT ';
	END IF;

   END IF;
END LOOP;



-- Construct the order by
IF(instr(fii_ar_util_pkg.g_order_by,',') <> 0) THEN

   /*This means no particular sort column is selected in the report
   So sort on the default column in descending order
   NVL is added to make sure the NULL values appear last*/

   l_order_by := 'ORDER BY NVL(FII_AR_BILL_ACT_AMT, -999999999) DESC';

  ELSIF(instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0)THEN

   /*This means a particular sort column is clicked to have descending order
   in which case we would want all the NULL values to appear last in the
   report so add an NVL to that column*/

   l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
   l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';

  ELSE

   /*This is the case when user has asked for an ascending order sort.
   Use PMV's order by clause*/

   l_order_by := '&ORDER_BY_CLAUSE';

  END IF;

  IF l_view_by_flag=3 THEN /* Viewby is Ct. acct */
    l_inner_from_clause := fii_ar_util_pkg.get_from_statement;
    l_inner_where_clause := ' and '||fii_ar_util_pkg.get_where_statement;
  ELSE
    l_inner_from_clause := 'fii_ar_summary_gt ';
    l_inner_where_clause := NULL;
  END IF;

-- Now the variable initialization is done, Start to build the PMV Query


l_sql_stmt := 'SELECT  VIEWBY,
                       VIEW_BY_ID VIEWBYID,
		       SUM(FII_AR_BILL_ACT_AMT_PRIOR) FII_AR_BILL_ACT_AMT_PRIOR,
		       NULLIF(SUM(FII_AR_BILL_ACT_AMT),0) FII_AR_BILL_ACT_AMT,
                       (( SUM(FII_AR_BILL_ACT_AMT)-SUM(FII_AR_BILL_ACT_AMT_PRIOR) ) /
                                              NULLIF(SUM(FII_AR_BILL_ACT_AMT_PRIOR),0 )) * 100  FII_AR_BILL_ACT_AMT_CHG,
		       SUM(FII_AR_BILL_ACT_COUNT) FII_AR_BILL_ACT_COUNT,
                       (( SUM(FII_AR_BILL_ACT_COUNT)-SUM(FII_AR_BILL_ACT_COUNT_PRIOR) ) /
                                              NULLIF(SUM(FII_AR_BILL_ACT_COUNT_PRIOR),0) ) * 100  FII_AR_BILL_ACT_COUNT_CHG,
                        NULLIF(SUM(FII_AR_OPEN_REC_AMT),0) FII_AR_BILL_OPEN_REC_AMT,
			(SUM(net_receivable_amount) / NULLIF(SUM(billed_amount),0)) *'||l_dso_period||' FII_AR_BILL_ACT_DSO,
                       NULLIF(SUM(SUM(FII_AR_BILL_ACT_AMT)) over(),0) FII_AR_GT_BILL_ACT_AMT ,
		       ((SUM(SUM(FII_AR_BILL_ACT_AMT)) over() - SUM(SUM(FII_AR_BILL_ACT_AMT_PRIOR)) over() )/
                                            NULLIF(SUM(SUM(FII_AR_BILL_ACT_AMT_PRIOR)) over(),0)) *100
                                                                     FII_AR_GT_BILL_ACT_AMT_CHG,
                        NULLIF(SUM(SUM(FII_AR_BILL_ACT_COUNT)) over(),0) FII_AR_GT_BILL_ACT_COUNT,
                                       ((SUM(SUM(FII_AR_BILL_ACT_COUNT)) over() - SUM(SUM(FII_AR_BILL_ACT_COUNT_PRIOR)) over() )/
                                            NULLIF(SUM(SUM(FII_AR_BILL_ACT_COUNT_PRIOR)) over(),0)) *100
                                                                     FII_AR_GT_BILL_ACT_COUNT_CHG,
                       NULLIF(SUM(SUM(FII_AR_OPEN_REC_AMT)) over(),0) FII_AR_GT_OPEN_REC_AMT,
                       (SUM(SUM(net_receivable_amount)) over()/NULLIF(SUM(SUM(billed_amount)) over(),0) )*'||l_dso_period||' FII_AR_GT_BILL_ACT_DSO,
		       (SUM(prior_net_receivable_amount) / NULLIF(SUM(prior_billed_amount),0)) *'||l_dso_period||' FII_AR_PRIOR_DSO_KPI,
		       (SUM(SUM(prior_net_receivable_amount)) OVER()/NULLIF(SUM(SUM(prior_billed_amount)) OVER(),0) )*'||l_dso_period||' FII_AR_GT_PRIOR_DSO_KPI,
		       SUM (SUM(FII_AR_BILL_ACT_AMT_PRIOR)) OVER () FII_AR_GT_BILL_ACT_PRIOR_AMT, ';

IF l_view_by_flag = 1 THEN /* It means that the view by is either ou or Industry */

          l_sql_stmt := l_sql_stmt ||'DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''','''|| l_bill_act_amt_drill ||''') FII_AR_BILL_ACT_AMT_DRILL ,
	                            DECODE(NVL(SUM(FII_AR_BILL_ACT_COUNT),0),0,'''','''||l_bill_act_count_drill ||''') FII_AR_BILL_ACT_COUNT_DRILL ,
				    DECODE(NVL(SUM(FII_AR_OPEN_REC_AMT),0),0,'''','''||l_open_rec_drill || ''') FII_AR_BILL_OPEN_REC_AMT_DRILL ,
                                  NULL FII_AR_VIEW_BY_DRILL';

ELSIF /*( l_view_by_flag = 3 )
               or */ (l_view_by = 'CUSTOMER+FII_CUSTOMERS' and fii_ar_util_pkg.g_is_hierarchical_flag = 'N' ) THEN

          l_sql_stmt := l_sql_stmt ||'DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''','''|| l_cust_acct_or_leaf_amt_drill || ''') FII_AR_BILL_ACT_AMT_DRILL ,
	                              DECODE(NVL(SUM(FII_AR_BILL_ACT_COUNT),0),0,'''','''||l_bill_act_count_drill || ''') FII_AR_BILL_ACT_COUNT_DRILL ,
				      DECODE(NVL(SUM(FII_AR_OPEN_REC_AMT),0),0,'''','''||l_cust_acct_or_leaf_rec_drill || ''') FII_AR_BILL_OPEN_REC_AMT_DRILL ,
                                      NULL FII_AR_VIEW_BY_DRILL ';

ELSIF l_view_by_flag =2 or l_view_by_flag=3 THEN /* It means that the View by Is ct and implementation is hierarchial */

    l_sql_stmt := l_sql_stmt || ' DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''',FII_AR_BILL_ACT_AMT_DRILL) FII_AR_BILL_ACT_AMT_DRILL,
                                       DECODE(NVL(SUM(FII_AR_BILL_ACT_COUNT),0),0,'''',FII_AR_BILL_ACT_COUNT_DRILL) FII_AR_BILL_ACT_COUNT_DRILL,
                                       DECODE(NVL(SUM(FII_AR_OPEN_REC_AMT),0),0,'''',FII_AR_BILL_OPEN_REC_AMT_DRILL) FII_AR_BILL_OPEN_REC_AMT_DRILL,
                                       FII_AR_VIEW_BY_DRILL ';
END IF;

l_sql_stmt := l_sql_stmt || ' FROM ( select /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
                CASE WHEN gt.report_date=:PREVIOUS_ASOF_DATE and BITAND(gt.record_type_id,:BITAND)= :BITAND  THEN
                     f.billing_activity_amount
                ELSE
                     NULL
                END FII_AR_BILL_ACT_AMT_PRIOR,
                CASE WHEN gt.report_date=:ASOF_DATE and BITAND(gt.record_type_id,:BITAND)= :BITAND  THEN
                     f.billing_activity_amount
                ELSE
                     NULL
                END FII_AR_BILL_ACT_AMT,
                CASE WHEN gt.report_date=:ASOF_DATE and BITAND(gt.record_type_id,:BITAND)= :BITAND  THEN
                     f.billing_activity_count
                ELSE
                     NULL
                END FII_AR_BILL_ACT_COUNT,
                CASE WHEN gt.report_date=:PREVIOUS_ASOF_DATE and BITAND(gt.record_type_id,:BITAND)= :BITAND  THEN
                     f.billing_activity_count
                ELSE
                     NULL
                END FII_AR_BILL_ACT_COUNT_PRIOR,
                CASE when gt.report_date=:ASOF_DATE and BITAND(gt.record_type_Id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE THEN
                      f.total_open_amount
	        ELSE
                     NULL
                END FII_AR_OPEN_REC_AMT,
                CASE when gt.report_date=:ASOF_DATE and BITAND(gt.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE THEN '||
                     l_class_inclusion ||'
                ELSE
                     NULL
                END   NET_RECEIVABLE_AMOUNT,
                CASE when gt.report_date=:ASOF_DATE and BITAND(gt.record_type_id,:DSO_BITAND)= :DSO_BITAND  THEN
                     f.billed_amount
	        ELSE
                     NULL
                END BILLED_AMOUNT ,
		CASE when gt.report_date=:PREVIOUS_ASOF_DATE and BITAND(gt.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE THEN '||
                     l_class_inclusion ||'
                ELSE
                     NULL
                END   PRIOR_NET_RECEIVABLE_AMOUNT,
                CASE when gt.report_date=:PREVIOUS_ASOF_DATE and BITAND(gt.record_type_id,:DSO_BITAND)= :DSO_BITAND  THEN
                     f.billed_amount
	        ELSE
                     NULL
                END PRIOR_BILLED_AMOUNT,
		gt.viewby viewby,
                gt.viewby_code VIEW_BY_ID';

IF l_view_by_flag = 3 THEN

           l_cust_acct_or_leaf_amt_drill := l_cust_acct_or_leaf_amt_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
	   l_cust_acct_or_leaf_rec_drill := l_cust_acct_or_leaf_rec_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
           l_sql_stmt:=l_sql_stmt || ','''||l_cust_acct_or_leaf_amt_drill||'''||gt.party_id||'''' FII_AR_BILL_ACT_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt || ''''||l_bill_act_count_drill||'''||gt.party_id||'''' FII_AR_BILL_ACT_COUNT_DRILL,';
           l_sql_stmt:=l_sql_stmt || ''''||l_cust_acct_or_leaf_rec_drill||'''||gt.party_id||'''' FII_AR_BILL_OPEN_REC_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt ||' NULL FII_AR_VIEW_BY_DRILL ';
END IF;



IF l_view_by_flag = 2 THEN /* The view by is ct. and the implementation is heirarchial */
   l_sql_stmt1 := ', gt.is_leaf_flag IS_LEAF_FLAG ,';
   l_sql_Stmt1 :=l_sql_stmt1 || ' CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_amt_drill||'''
				ELSE '''||
				  l_bill_act_amt_drill||'''
				END FII_AR_BILL_ACT_AMT_DRILL ,'''||l_bill_act_count_drill  ||''' FII_AR_BILL_ACT_COUNT_DRILL,
                                CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_rec_drill||'''
				ELSE '''||
				  l_open_rec_drill||'''
				END FII_AR_BILL_OPEN_REC_AMT_DRILL ,
                                DECODE(gt.is_self_flag,''Y'','''',DECODE(gt.is_leaf_flag,''Y'','''','''||l_customer_drill||''')) FII_AR_VIEW_BY_DRILL ';
   l_sql_stmt := l_sql_stmt||l_sql_stmt1;

END IF;




l_sql_stmt:=l_sql_stmt||' from fii_ar_net_rec'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
                                (select /*+ no_merge '||l_gt_hint|| ' */  * from fii_time_structures cal, '||l_inner_from_clause||' t
	                         where cal.report_date in(:ASOF_DATE ,:PREVIOUS_ASOF_DATE)
				 and (BITAND(cal.record_type_id,:BITAND)= :BITAND
				     OR BITAND(cal.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE
				     OR BITAND(cal.record_type_id,:DSO_BITAND)=:DSO_BITAND ) '||l_inner_where_clause ||' ) gt
                        where f.time_id = gt.time_id
			and gt.period_type_id=f.period_type_id
                         '|| l_where_clause||' and '||fii_ar_util_pkg.get_mv_where_statement;
	IF l_unapp_amount IS NOT NULL THEN
			l_sql_stmt:=l_sql_stmt||' UNION ALL
			  SELECT /*+ INDEX(f FII_AR_RCT_AGING'|| fii_ar_util_pkg.g_cust_suffix ||'_MV_N1)*/ NULL FII_AR_BILL_ACT_AMT_PRIOR,
			         NULL FII_AR_BILL_ACT_AMT,
				 NULL FII_AR_BILL_ACT_COUNT,
				 NULL FII_AR_BILL_ACT_COUNT_PRIOR,
				 NULL FII_AR_OPEN_REC_AMT,
				 CASE when gt.report_date=:ASOF_DATE and BITAND(gt.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE THEN '||
				   l_unapp_amount || ' ELSE NULL END NET_RECEIVABLE_AMOUNT,
				 NULL BILLED_AMOUNT,
                                 CASE when gt.report_date=:PREVIOUS_ASOF_DATE and BITAND(gt.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE THEN '||
				   l_unapp_amount || ' ELSE NULL END PRIOR_NET_RECEIVABLE_AMOUNT,
				 NULL PRIOR_BILLED_AMOUNT,
				 gt.viewby viewby,
				 gt.viewby_code VIEW_BY_ID';
IF l_view_by_flag = 3 THEN
         -- commented out for bug5107816
	 -- This piece was redundant as it was already done for the 1st select and was not reqd for 2nd select
         /*  l_cust_acct_or_leaf_amt_drill := l_cust_acct_or_leaf_amt_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
	   l_cust_acct_or_leaf_rec_drill := l_cust_acct_or_leaf_rec_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='; */
           l_sql_stmt:=l_sql_stmt || ','''||l_cust_acct_or_leaf_amt_drill||'''||gt.party_id||'''' FII_AR_BILL_ACT_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt || ''''||l_bill_act_count_drill||'''||gt.party_id||'''' FII_AR_BILL_ACT_COUNT_DRILL,';
           l_sql_stmt:=l_sql_stmt || ''''||l_cust_acct_or_leaf_rec_drill||'''||gt.party_id||'''' FII_AR_BILL_OPEN_REC_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt ||' NULL FII_AR_VIEW_BY_DRILL ';
END IF;

               IF l_view_by_flag = 2 THEN /* The view by is ct. and the implementation is heirarchial */
	             l_sql_stmt:=l_sql_stmt||l_sql_stmt1;
	       END IF;

	       l_sql_stmt:=l_sql_stmt||' from fii_ar_rct_aging'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
	                                  (select /*+ no_merge '||l_gt_hint|| ' */   * from fii_time_structures cal, '||l_inner_from_clause||' t
	                                   where cal.report_date in(:ASOF_DATE ,:PREVIOUS_ASOF_DATE)
				             and (BITAND(cal.record_type_id,:BITAND)= :BITAND
				                 OR BITAND(cal.record_type_id,:BITAND_INC_TODATE)= :BITAND_INC_TODATE
				                 OR BITAND(cal.record_type_id,:DSO_BITAND)=:DSO_BITAND ) '||l_inner_where_clause ||' ) gt
                                         where f.time_id = gt.time_id
			                   and gt.period_type_id=f.period_type_id
			                   AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' '|| l_where_clause;


	END IF;

       l_sql_stmt:=l_sql_stmt||' ) GROUP BY viewby,view_by_id ';



IF l_view_by_flag = 2 or l_view_by_flag= 3 THEN
   l_sql_stmt := l_sql_stmt || ',FII_AR_BILL_ACT_AMT_DRILL,FII_AR_BILL_ACT_COUNT_DRILL,FII_AR_BILL_OPEN_REC_AMT_DRILL, FII_AR_VIEW_BY_DRILL ';
END IF;

l_sql_stmt := l_sql_stmt || l_order_by;




    /* Pass back the pmv sql along with bind variables to PMV */
    fii_ar_util_pkg.bind_variable(l_sql_stmt, p_page_parameter_tbl, bill_act_sum_sql, bill_sum_output);

END get_billing_activity;



END ;


/
