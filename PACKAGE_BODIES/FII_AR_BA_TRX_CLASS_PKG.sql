--------------------------------------------------------
--  DDL for Package Body FII_AR_BA_TRX_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_BA_TRX_CLASS_PKG" AS
/*  $Header: FIIARDBIBTCB.pls 120.11 2007/05/15 20:47:01 vkazhipu ship $ */

--   This package will provide sql statements to retrieve data for Billing Activity

-- --------------------------------------------------------------------------
-- Name : get_bill_act_trx_class
-- Type : Procedure
-- Description : This procedure passes SQL to PMV for Billing Activity Transaction
--               Class Report
-----------------------------------------------------------------------------


PROCEDURE get_bill_act_trx_class (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, ba_trx_class_sum_sql out NOCOPY VARCHAR2,
  ba_trx_class_sum_out out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt			VARCHAR2(30000);
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

  l_cust_acct_or_leaf_amt_drill VARCHAR2(240);

  l_cust_acct_or_leaf_inv_drill VARCHAR2(240);
  l_cust_acct_or_leaf_dm_drill  VARCHAR2(240);
  l_cust_acct_or_leaf_cb_drill  VARCHAR2(240);
  l_customer_drill              VARCHAR2(120);
  l_amount_drill                VARCHAR2(120);

  l_cust_suffix                 VARCHAR2(5);
  l_curr_suffix                 VARCHAR2(4);
  l_viewby_id                   VARCHAR2(30);


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

l_gt_hint := ' leading(t) cardinality(t 1) ';

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



-- Checks whether filter for Ct. acct. is reqd or not
IF l_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
       l_cust_acct_where := ' and f.cust_account_id = gt.cust_account_id';
       l_view_by_flag:=3;
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

 IF (l_view_by_flag = 2 ) /* View by is ct. and implementation is heirarchial */ THEN

	 l_amount_drill := 'pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
   l_customer_drill:= 'pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

END IF;

--vkazhipu added for bug 5960517
 IF l_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' OR
    l_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS'  THEN
    l_view_by_flag:=1; -- for ou,industry
    IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
     l_amount_drill := 'pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
    ELSE
      l_amount_drill := 'pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';
    END IF;
END IF;

-- Drill on amount and view by is ct acct or ct is leaf. Drilll to Billing Activity Detail
IF l_view_by_flag = 3 THEN
  l_cust_acct_or_leaf_amt_drill := 'pFunctionName=FII_AR_BILLING_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
ELSE
  l_cust_acct_or_leaf_amt_drill := 'pFunctionName=FII_AR_BILLING_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

-- Drill on Invoice amt and view by is ct acct or ct is leaf. Drill to Invoice Activity Detail
IF l_view_by_flag = 3 THEN
  l_cust_acct_or_leaf_inv_drill:= 'pFunctionName=FII_AR_INV_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
ELSE
  l_cust_acct_or_leaf_inv_drill:= 'pFunctionName=FII_AR_INV_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

-- Drill on DM amt and view by is ct acct or ct is leaf. Drill to Debit Memo Detail
IF l_view_by_flag = 3 THEN
  l_cust_acct_or_leaf_dm_drill:= 'pFunctionName=FII_AR_DM_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
ELSE
  l_cust_acct_or_leaf_dm_drill:= 'pFunctionName=FII_AR_DM_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

-- Drill on CB amt and view by is ct acct or ct is leaf. Drill to Chargeback Activity Detail
IF l_view_by_flag = 3 THEN
  l_cust_acct_or_leaf_cb_drill:= 'pFunctionName=FII_AR_CB_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&FII_AR_CUST_ACCOUNT=VIEWBYID';
ELSE
   l_cust_acct_or_leaf_cb_drill:= 'pFunctionName=FII_AR_CB_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

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

  l_cust_suffix := fii_ar_util_pkg.g_cust_suffix;
  l_curr_suffix := fii_ar_util_pkg.g_curr_suffix;

-- Now the variable initialization is done, Start to build the PMV Query

l_sql_stmt := l_sql_stmt || 'SELECT  VIEWBY,
                                     VIEW_BY_ID VIEWBYID,
		                     NULLIF(SUM(FII_AR_BILL_ACT_AMT),0) FII_AR_BILL_ACT_AMT,
                                     NULLIF(SUM(FII_AR_BILL_ACT_COUNT),0) FII_AR_BILL_ACT_COUNT,
                                     NULLIF(SUM(FII_AR_BA_INV_AMT),0) FII_AR_BA_INV_AMT,
				     NULLIF(SUM(FII_AR_BA_INV_COUNT),0) FII_AR_BA_INV_COUNT,
				     NULLIF(SUM(FII_AR_BA_DM_AMT),0) FII_AR_BA_DM_AMT,
				     NULLIF(SUM(FII_AR_BA_DM_COUNT),0) FII_AR_BA_DM_COUNT,
				     NULLIF(SUM(FII_AR_BA_CB_AMT),0) FII_AR_BA_CB_AMT,
				     NULLIF(SUM(FII_AR_BA_CB_COUNT),0) FII_AR_BA_CB_COUNT,
				     NULLIF(SUM(FII_AR_BA_BR_AMT),0) FII_AR_BA_BR_AMT,
                                     NULLIF(SUM(FII_AR_BA_BR_COUNT),0) FII_AR_BA_BR_COUNT,
				     NULLIF(SUM(FII_AR_BA_DEP_AMT),0) FII_AR_BA_DEP_AMT,
				     NULLIF(SUM(FII_AR_BA_DEP_COUNT),0) FII_AR_BA_DEP_COUNT,
				     NULLIF(SUM(FII_AR_BA_CM_AMT),0) FII_AR_BA_CM_AMT,
				     NULLIF(SUM(FII_AR_BA_CM_COUNT),0) FII_AR_BA_CM_COUNT,
                                     NULLIF(SUM(SUM(FII_AR_BILL_ACT_AMT)) over(),0) FII_AR_GT_BILL_ACT_AMT ,
				     NULLIF(SUM(SUM(FII_AR_BILL_ACT_COUNT)) over(),0) FII_AR_GT_BILL_ACT_COUNT ,
				     NULLIF(SUM(SUM(FII_AR_BA_INV_AMT)) over(),0) FII_AR_GT_BA_INV_AMT,
				     NULLIF(SUM(SUM(FII_AR_BA_INV_COUNT)) over(),0) FII_AR_GT_BA_INV_COUNT,
				     NULLIF(SUM(SUM(FII_AR_BA_DM_AMT)) over(),0) FII_AR_GT_BA_DM_AMT,
				     NULLIF(SUM(SUM(FII_AR_BA_DM_COUNT)) over(),0) FII_AR_GT_BA_DM_COUNT,
				     NULLIF(SUM(SUM(FII_AR_BA_CB_AMT)) over(),0) FII_AR_GT_BA_CB_AMT,
				     NULLIF(SUM(SUM(FII_AR_BA_CB_COUNT)) over(),0) FII_AR_GT_BA_CB_COUNT,
				     NULLIF(SUM(SUM(FII_AR_BA_BR_AMT)) over(),0) FII_AR_GT_BA_BR_AMT,
                                     NULLIF(SUM(SUM(FII_AR_BA_BR_COUNT)) over(),0) FII_AR_GT_BA_BR_COUNT,
				     NULLIF(SUM(SUM(FII_AR_BA_DEP_AMT)) over(),0) FII_AR_GT_BA_DEP_AMT,
				     NULLIF(SUM(SUM(FII_AR_BA_DEP_COUNT)) over(),0) FII_AR_GT_BA_DEP_COUNT,
				     NULLIF(SUM(SUM(FII_AR_BA_CM_AMT)) over(),0) FII_AR_GT_BA_CM_AMT,
				     NULLIF(SUM(SUM(FII_AR_BA_CM_COUNT)) over(),0) FII_AR_GT_BA_CM_COUNT,
				     NULLIF(SUM(FII_AR_BA_INV_AMT),0) FII_AR_G_BA_INV_AMT,
				     NULLIF(SUM(FII_AR_BA_DM_AMT),0) FII_AR_G_BA_DM_AMT,
				     NULLIF(SUM(FII_AR_BA_CB_AMT),0) FII_AR_G_BA_CB_AMT,
				     NULLIF(SUM(FII_AR_BA_BR_AMT),0) FII_AR_G_BA_BR_AMT,
				     NULLIF(SUM(FII_AR_BA_DEP_AMT),0) FII_AR_G_BA_DEP_AMT,
				     NULLIF(SUM(FII_AR_BA_CM_AMT),0) FII_AR_G_BA_CM_AMT,
				     NULLIF(SUM(FII_AR_BA_INV_COUNT),0) FII_AR_G_BA_INV_COUNT,
				     NULLIF(SUM(FII_AR_BA_DM_COUNT),0) FII_AR_G_BA_DM_COUNT,
				     NULLIF(SUM(FII_AR_BA_CB_COUNT),0) FII_AR_G_BA_CB_COUNT,
				     NULLIF(SUM(FII_AR_BA_BR_COUNT),0) FII_AR_G_BA_BR_COUNT,
				     NULLIF(SUM(FII_AR_BA_DEP_COUNT),0) FII_AR_G_BA_DEP_COUNT,
				     NULLIF(SUM(FII_AR_BA_CM_COUNT),0) FII_AR_G_BA_CM_COUNT, ';


IF l_view_by_flag = 1 THEN /* It means that the view by is either ou or Industry */
   l_sql_stmt := l_sql_stmt ||'DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''','''|| l_amount_drill ||''') FII_AR_BILL_ACT_AMT_DRILL ,
	                       DECODE(NVL(SUM(FII_AR_BA_INV_AMT),0),0,'''','''|| l_amount_drill ||''') FII_AR_BA_INV_AMT_DRILL ,
                               DECODE(NVL(SUM(FII_AR_BA_DM_AMT),0),0,'''','''|| l_amount_drill ||''') FII_AR_BA_DM_AMT_DRILL ,
			       DECODE(NVL(SUM(FII_AR_BA_CB_AMT),0),0,'''','''|| l_amount_drill ||''') FII_AR_BA_CB_AMT_DRILL ,
			       NULL FII_AR_VIEW_BY_DRILL';
ELSIF /*( l_view_by_flag = 3 )
     or */ (l_view_by = 'CUSTOMER+FII_CUSTOMERS' and fii_ar_util_pkg.g_is_hierarchical_flag = 'N' ) THEN

   l_sql_stmt := l_sql_stmt ||'DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''','''|| l_cust_acct_or_leaf_amt_drill || ''') FII_AR_BILL_ACT_AMT_DRILL ,
	                       DECODE(NVL(SUM(FII_AR_BA_INV_AMT),0),0,'''','''||l_cust_acct_or_leaf_inv_drill || ''') FII_AR_BA_INV_AMT_DRILL ,
			       DECODE(NVL(SUM(FII_AR_BA_DM_AMT),0),0,'''','''||l_cust_acct_or_leaf_dm_drill || ''') FII_AR_BA_DM_AMT_DRILL ,
			       DECODE(NVL(SUM(FII_AR_BA_CB_AMT),0),0,'''','''||l_cust_acct_or_leaf_cb_drill || ''') FII_AR_BA_CB_AMT_DRILL ,
                               NULL FII_AR_VIEW_BY_DRILL ';
ELSIF l_view_by_flag =2 or l_view_by_flag=3 THEN /* It means that the View by Is ct and implementation is hierarchial */

    l_sql_stmt := l_sql_stmt || ' DECODE(NVL(SUM(FII_AR_BILL_ACT_AMT),0),0,'''',FII_AR_BILL_ACT_AMT_DRILL) FII_AR_BILL_ACT_AMT_DRILL,
                                  DECODE(NVL(SUM(FII_AR_BA_INV_AMT),0),0,'''',FII_AR_BA_INV_AMT_DRILL) FII_AR_BA_INV_AMT_DRILL,
                                  DECODE(NVL(SUM(FII_AR_BA_DM_AMT),0),0,'''',FII_AR_BA_DM_AMT_DRILL) FII_AR_BA_DM_AMT_DRILL,
				  DECODE(NVL(SUM(FII_AR_BA_CB_AMT),0),0,'''',FII_AR_BA_CB_AMT_DRILL) FII_AR_BA_CB_AMT_DRILL,
                                  FII_AR_VIEW_BY_DRILL ';
END IF;

l_sql_stmt := l_sql_stmt || ' FROM ( SELECT f.inv_ba_amount+f.dm_ba_amount+f.cb_ba_amount
                                   +f.br_ba_amount+f.dep_ba_amount + f.cm_ba_amount FII_AR_BILL_ACT_AMT,
                                  f.inv_ba_count+f.dm_ba_count+f.cb_ba_count
                                   +f.br_ba_count+f.dep_ba_count + f.cm_ba_count FII_AR_BILL_ACT_COUNT,
                                   f.inv_ba_amount FII_AR_BA_INV_AMT,
		                   f.inv_ba_count FII_AR_BA_INV_COUNT,
		                   f.dm_ba_amount FII_AR_BA_DM_AMT,
		                   f.dm_ba_count FII_AR_BA_DM_COUNT,
		                   f.cb_ba_amount FII_AR_BA_CB_AMT,
		                   f.cb_ba_count FII_AR_BA_CB_COUNT,
		                   f.br_ba_amount FII_AR_BA_BR_AMT,
		                   f.br_ba_count FII_AR_BA_BR_COUNT,
		                   f.dep_ba_amount FII_AR_BA_DEP_AMT,
		                   f.dep_ba_count FII_AR_BA_DEP_COUNT,
		                   f.cm_ba_amount FII_AR_BA_CM_AMT,
		                   f.cm_ba_count FII_AR_BA_CM_COUNT,
                                   gt.viewby viewby,
                                   gt.viewby_code VIEW_BY_ID';


IF l_view_by_flag = 3 THEN
           l_cust_acct_or_leaf_amt_drill := l_cust_acct_or_leaf_amt_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
	   l_cust_acct_or_leaf_inv_drill := l_cust_acct_or_leaf_inv_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
	   l_cust_acct_or_leaf_dm_drill := l_cust_acct_or_leaf_dm_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
	   l_cust_acct_or_leaf_cb_drill := l_cust_acct_or_leaf_cb_drill||'&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=';
           l_sql_stmt:=l_sql_stmt || ','''||l_cust_acct_or_leaf_amt_drill||'''||gt.party_id||'''' FII_AR_BILL_ACT_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt || ''''||l_cust_acct_or_leaf_inv_drill||'''||gt.party_id||'''' FII_AR_BA_INV_AMT_DRILL,';
	   l_sql_stmt:=l_sql_stmt || ''''||l_cust_acct_or_leaf_dm_drill||'''||gt.party_id||'''' FII_AR_BA_DM_AMT_DRILL,';
	   l_sql_stmt:=l_sql_stmt || ''''||l_cust_acct_or_leaf_cb_drill||'''||gt.party_id||'''' FII_AR_BA_CB_AMT_DRILL,';
           l_sql_stmt:=l_sql_stmt ||' NULL FII_AR_VIEW_BY_DRILL ';
END IF;

IF l_view_by_flag = 2 THEN /* The view by is ct. and the implementation is heirarchial */
   l_sql_stmt := l_sql_stmt || ', gt.is_leaf_flag IS_LEAF_FLAG ,';
   l_sql_Stmt :=l_sql_stmt || ' CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_amt_drill||'''
				ELSE '''||
				  l_amount_drill||'''
				END FII_AR_BILL_ACT_AMT_DRILL ,
                                CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_inv_drill||'''
				ELSE '''||
				  l_amount_drill||'''
				END FII_AR_BA_INV_AMT_DRILL ,
				 CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_dm_drill||'''
				ELSE '''||
				  l_amount_drill||'''
				END FII_AR_BA_DM_AMT_DRILL ,
				 CASE WHEN gt.is_leaf_flag = ''Y'' OR gt.is_self_flag = ''Y'' THEN '''||
                                  l_cust_acct_or_leaf_cb_drill||'''
				ELSE '''||
				  l_amount_drill||'''
				END FII_AR_BA_CB_AMT_DRILL ,
				DECODE(gt.is_self_flag,''Y'','''',DECODE(gt.is_leaf_flag,''Y'','''','''||l_customer_drill||''')) FII_AR_VIEW_BY_DRILL ';

END IF;


l_sql_stmt:=l_sql_stmt||' FROM fii_ar_billing_act'||l_cust_suffix||'_mv'||l_curr_suffix||' f,
                                (select /*+ no_merge '||l_gt_hint|| ' */ * from fii_time_structures cal, '||l_inner_from_clause||' t
	                         where cal.report_date = :ASOF_DATE
				 and BITAND(cal.record_type_id,:BITAND)= :BITAND '||l_inner_where_clause ||' ) gt
                        where f.time_id = gt.time_id
			and gt.period_type_id=f.period_type_id
                         '|| l_where_clause||') GROUP BY viewby,view_by_id ';

IF l_view_by_flag = 2 or l_view_by_flag= 3 THEN
   l_sql_stmt := l_sql_stmt || ',FII_AR_BILL_ACT_AMT_DRILL,FII_AR_BA_INV_AMT_DRILL,FII_AR_BA_DM_AMT_DRILL,FII_AR_BA_CB_AMT_DRILL, FII_AR_VIEW_BY_DRILL ';
END IF;

l_sql_stmt := l_sql_stmt || l_order_by;


    /* Pass back the pmv sql along with bind variables to PMV */
    fii_ar_util_pkg.bind_variable(l_sql_stmt, p_page_parameter_tbl, ba_trx_class_sum_sql, ba_trx_class_sum_out);

END get_bill_act_trx_class;



END ;


/
