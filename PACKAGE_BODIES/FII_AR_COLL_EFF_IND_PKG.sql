--------------------------------------------------------
--  DDL for Package Body FII_AR_COLL_EFF_IND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_COLL_EFF_IND_PKG" AS
/*  $Header: FIIARDBICEIB.pls 120.33 2007/07/05 10:41:08 arcdixit ship $ */

--------------------Global Variable Declaration--------------------------
g_scaling_factor	VARCHAR2(100);
g_scale_sign		VARCHAR2(1);
g_scaling_factor_cons	NUMBER;
g_scale_sign_cons	VARCHAR2(1);
g_current_sequence          number;

--------------------------------------------------------------------------
-- For constructing the order by clause for the report
FUNCTION get_order_by return VARCHAR2 IS
--For Order by Clause
l_order_by		varchar2(500);
l_order_column		varchar2(100);

BEGIN

  --Frame the order by clause for the report sql
  IF(instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0)THEN

   /*This means a particular sort column is clicked to have descending order
   in which case we would want all the null values to appear last in the
   report so add an NVL to that column*/

   l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
   l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';

  ELSE

   /*This is the case when user has asked for an ascending order sort.
   Use PMV's order by clause*/

   l_order_by := '&ORDER_BY_CLAUSE';

  END IF;

  return l_order_by;

END get_order_by;

---------------------------------------------------------------------
-- Procedure to set the Scaling factor and sign for billed amount
PROCEDURE get_scaling_factor IS
BEGIN

  --Code to decide the scaling factor for Billed Amount
  --The billed amount needs to be scaled to a month before calculating the CEI.

  -- These global variables will be used in Collection Effectiveness Index and Collection Effectiveness Reports
  -- and trend report for the current period
  IF (fii_ar_util_pkg.g_curr_per_end = fii_ar_util_pkg.g_as_of_date) THEN
   IF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK') THEN
	g_scaling_factor := 4.35;
   ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') THEN
	g_scaling_factor := 3;
   ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR') THEN
	g_scaling_factor := 12;
   ELSE
	g_scaling_factor := 1;
   END IF;
  ELSE
   g_scaling_factor := to_char((((fii_ar_util_pkg.g_as_of_date - fii_ar_util_pkg.g_curr_per_start) + 1) /30), '99999D9999999999999','NLS_NUMERIC_CHARACTERS=''.,');
  END IF;

  g_scale_sign := '/';

  -- This will be used in the trend report as there would be months, weeks, quarters and years with full period
  IF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK') THEN
	g_scaling_factor_cons := 4.35;
	g_scale_sign_cons := '/';
  ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') THEN
	g_scaling_factor_cons := 3;
	g_scale_sign_cons := '/';
  ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR') THEN
	g_scaling_factor_cons := 12;
	g_scale_sign_cons := '/';
  ELSE
	g_scaling_factor_cons := 1;
	g_scale_sign_cons := '/';
  END IF;

  -- To get the sequence of the current period. It will always be the maximum sequence displayed in the trend report
  IF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK') THEN
    select sequence into g_current_sequence from fii_time_week where fii_ar_util_pkg.g_as_of_date between start_date and end_date;

  ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') THEN
    select sequence into g_current_sequence from FII_TIME_ENT_QTR where fii_ar_util_pkg.g_as_of_date between start_date and end_date;

  ELSIF(fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR') THEN
   select sequence into g_current_sequence from FII_TIME_ENT_YEAR where fii_ar_util_pkg.g_as_of_date between start_date and end_date;

  ELSE
   select sequence into g_current_sequence from FII_TIME_ENT_PERIOD where fii_ar_util_pkg.g_as_of_date between start_date and end_date;

  END IF;

END get_scaling_factor;

-----------------------------------------------------------------------------------------------------------
--   This procedure will provide sql statements to retrieve data for Collection Effectiveness Index Summary
PROCEDURE get_coll_eff_index(
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, coll_eff_sql out NOCOPY VARCHAR2,
  coll_eff_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt                       VARCHAR2(30000);

  --Variables for where clauses
  l_collector_where		VARCHAR2(300);
  l_party_where 		VARCHAR2(300);
  l_child_party_where 		VARCHAR2(300);
  l_cust_acct_where 		VARCHAR2(300);

  --Date for beginning open receivables drill
  l_curr_per_start		VARCHAR2(30);

  --Variables for drills
  l_self_drill			VARCHAR2(300);
  l_beg_open_rec_drill		VARCHAR2(300);
  l_end_open_rec_drill		VARCHAR2(300);
  l_end_curr_rec_drill		VARCHAR2(300);
  l_beg_open_rec_drill_l	VARCHAR2(300);
  l_end_open_rec_drill_l	VARCHAR2(300);
  l_end_curr_rec_drill_l	VARCHAR2(300);
  l_beg_open_rec_drill_2	VARCHAR2(300);
  l_end_open_rec_drill_2	VARCHAR2(300);
  l_end_curr_rec_drill_2	VARCHAR2(300);

  --Select sql's
  l_select_sql1			varchar2(500);
  l_select_sql2			varchar2(500);
  l_select_sql3			varchar2(500);

  --Only for viewby Customer
  l_inner_cst_select		varchar2(70);
  l_inner_cst_group		varchar2(50);
  l_self_drill_select		varchar2(200);

  --For Order by Clause
  l_order_by		varchar2(500);

  --For sending Customer id to detail reports
  l_customer_select		varchar2(500);
  l_gt_hint varchar2(500);
BEGIN
  --Call to reset the parameter variables
  fii_ar_util_pkg.reset_globals;

  --Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  --Get the order by clause for the report
  l_order_by := get_order_by;

  --This call will populate fii_ar_summary_gt table
  fii_ar_util_pkg.populate_summary_gt_tables;

  --Call to set up the global variables for scaling factor and sign for billed amount
  get_scaling_factor;
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';
  -- Date to be passed in the drill on Beginning Open Receivables amount
  l_curr_per_start := to_char(trunc(fii_ar_util_pkg.g_curr_per_start), 'DD/MM/YYYY');

  --Amount Drills
  l_beg_open_rec_drill := 'AS_OF_DATE='||l_curr_per_start||'&pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  l_end_open_rec_drill := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  l_end_curr_rec_drill := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';


  IF (fii_ar_util_pkg.g_party_id <> '-111') THEN

 		l_beg_open_rec_drill_2 := 'AS_OF_DATE='||l_curr_per_start||'&pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  	l_end_open_rec_drill_2 := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  	l_end_curr_rec_drill_2 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  ELSE

    l_beg_open_rec_drill_2 := 'AS_OF_DATE='||l_curr_per_start||'&pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  	l_end_open_rec_drill_2 := 'pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  	l_end_curr_rec_drill_2 := 'pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  END IF;


  --Detail drills require Customer and Account as parameter in case the drill is from view by Customer Account
  IF fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN

   l_beg_open_rec_drill_l := 'AS_OF_DATE='||l_curr_per_start||'&pFunctionName=FII_AR_OPEN_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

   l_end_open_rec_drill_l := 'pFunctionName=FII_AR_OPEN_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

   l_end_curr_rec_drill_l := 'pFunctionName=FII_AR_CURR_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  ELSE
   l_beg_open_rec_drill_l := 'AS_OF_DATE='||l_curr_per_start||'&pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

   l_end_open_rec_drill_l := 'pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

   l_end_curr_rec_drill_l := 'pFunctionName=FII_AR_CURR_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  -- Default View by select clause and self drill select clause
  --This will change in case of View by Customer
  l_self_drill_select := '''''';

  --Setting up the where clauses based on the Parameter and viewby
  --for Collector Dimension
  IF (fii_ar_util_pkg.g_collector_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') THEN
  	l_collector_where := 'AND f.collector_id = t.collector_id';
  END IF;

 --Customer Dimension where clause
 IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
  l_child_party_where := ' AND f.party_id   = t.party_id ';
 END IF;

  -- Select, where, group by clauses based on viewby
  If((fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS') OR (fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR')) THEN
	l_select_sql1 := ''''||l_beg_open_rec_drill_2||'''';

	l_select_sql2 := ''''||l_end_open_rec_drill_2||'''';

	l_select_sql3 := ''''||l_end_curr_rec_drill_2||'''';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
	l_select_sql1 := ''''||l_beg_open_rec_drill_l||'''';

	l_select_sql2 := ''''||l_end_open_rec_drill_l||'''';

	l_select_sql3 := ''''||l_end_curr_rec_drill_l||'''';

	l_cust_acct_where := 'AND f.cust_account_id = t.cust_account_id';

	l_customer_select := ' t.party_id   party_id, ';
	l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	IF (fii_ar_util_pkg.g_is_hierarchical_flag = 'Y') THEN
		l_select_sql1 := 'DECODE(inline_view.is_self_flag, ''Y'' ,'''||l_beg_open_rec_drill_l||''', DECODE(is_leaf_flag,''Y'', '''||l_beg_open_rec_drill_l||''', '''||l_beg_open_rec_drill||'''))';

		l_select_sql2 := 'DECODE(inline_view.is_self_flag, ''Y'' ,'''||l_end_open_rec_drill_l||''', DECODE(is_leaf_flag,''Y'', '''||l_end_open_rec_drill_l||''', '''||l_end_open_rec_drill||'''))';

		l_select_sql3 := 'DECODE(inline_view.is_self_flag, ''Y'' ,'''||l_end_curr_rec_drill_l||''', DECODE(is_leaf_flag,''Y'', '''||l_end_curr_rec_drill_l||''', '''||l_end_curr_rec_drill||'''))';

		--Self drill. This is reqd only in case of Viewby Customer
		--Check dynamically if the node is leaf or not. In case of non-leaf this drill is to be enabled.

		l_self_drill := 'pFunctionName=FII_AR_COLL_EFF_INDEX&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

		l_self_drill_select := 'DECODE(inline_view.is_self_flag, ''Y'', '''', DECODE(inline_view.is_leaf_flag, ''Y'','''','''||l_self_drill||'''))';

		--Select and Groupp by Clauses
		l_inner_cst_select := 'is_self_flag is_self_flag, is_leaf_flag is_leaf_flag,';
		l_inner_cst_group := ', is_self_flag, is_leaf_flag';


	ELSE
		l_select_sql1 := ''''||l_beg_open_rec_drill_l||'''';

		l_select_sql2 := ''''||l_end_open_rec_drill_l||'''';

		l_select_sql3 := ''''||l_end_curr_rec_drill_l||'''';
	END IF;

        --  Where clause clause for Customer Dimension
	l_party_where := 'AND f.parent_party_id = t.parent_party_id';

  END IF;

  IF  fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   l_inner_cst_group := l_inner_cst_group || ' ,t.party_id';
  END IF;

  -- Report Query
  sqlstmt := 'SELECT
	inline_view.viewby          VIEWBY,
	inline_view.viewby_id	    VIEWBYID,
	((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC) +
	(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)),0)) * 100   FII_AR_COLL_EFF_INDEX,
(((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC) +
	(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC))/
        NULLIF((NULLIF(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0,FII_AR_BEG_OPEN_REC), 0)
	+(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)),0))* 100) -
        (((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)),0))*100) FII_AR_COLL_EFF_CHANGE,
  FII_AR_BEG_OPEN_REC,
	FII_AR_BILLED_AMOUNT,
	FII_AR_END_OPEN_REC,
	FII_AR_BEG_CURR_REC,
	FII_AR_PAST_DUE_REC,
	FII_AR_END_CURR_REC,
((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)) OVER() +
	SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)) OVER())/
        NULLIF((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))OVER()
	+SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)) OVER()),0)) *100  FII_AR_GT_COLL_EFF_IND,
(((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)) OVER()
	+SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)) OVER())/
        NULLIF((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))OVER()
        +SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)) OVER()),0))* 100)  -
        (((SUM(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)) OVER()
	+SUM(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC)) OVER())/
        NULLIF((SUM(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)) OVER()
	+SUM(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)) OVER()),0))* 100) FII_AR_GT_COLL_EFF_CHG,
 SUM(FII_AR_BEG_OPEN_REC) OVER() FII_AR_GT_BEG_OPEN_REC,
	SUM(FII_AR_BILLED_AMOUNT) OVER() FII_AR_GT_BILLED_AMT,
	SUM(FII_AR_END_OPEN_REC) OVER() FII_AR_GT_END_OPEN_REC,
	SUM(FII_AR_END_CURR_REC) OVER() FII_AR_GT_END_CURR_REC,
((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
        + (DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)),0))  * 100 FII_AR_PRIO_COLL_EFF_INDEX,
      FII_AR_END_PAST_DUE_REC,
	DECODE(FII_AR_BEG_OPEN_REC,0,'''',DECODE(NVL(FII_AR_BEG_OPEN_REC,-999999),-999999,'''',
	'||l_select_sql1||')) FII_AR_BEG_OPEN_REC_DRILL,
DECODE(FII_AR_END_OPEN_REC,0,'''',DECODE(NVL(FII_AR_END_OPEN_REC,-999999),-999999,'''',
	'||l_select_sql2||')) FII_AR_END_OPEN_REC_DRILL,
DECODE(FII_AR_END_CURR_REC,0,'''',DECODE(NVL(FII_AR_END_CURR_REC,-999999),-999999,'''',
	'||l_select_sql3||')) FII_AR_END_CURR_REC_DRILL,
'||l_self_drill_select ||' FII_AR_CUST_SELF_DRILL  ,
	((SUM(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)) OVER() +
	SUM(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC)) OVER())/
        NULLIF((SUM(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC))OVER()
	+SUM(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') OVER()
	-SUM(DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)) OVER()),0)) * 100 FII_AR_GT_PRIO_COLL_EFF_INDEX
  FROM (
  SELECT	 /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/  VIEWBY,
		  viewby_code	viewby_id,
'||l_inner_cst_select||l_customer_select||'
		SUM(DECODE(t.report_date, :CURR_PERIOD_START ,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_BEG_OPEN_REC,
					SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_END_OPEN_REC,
				SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN current_open_amount  ELSE NULL END) ) )   FII_AR_END_CURR_REC,
			SUM(DECODE(t.report_date, :CURR_PERIOD_START,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN current_open_amount  ELSE NULL END) ) )   FII_AR_BEG_CURR_REC,
		   SUM(DECODE(t.report_date, :CURR_PERIOD_START, /*This date will be starting date of the period*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN past_due_open_amount  ELSE NULL END) ) )   FII_AR_PAST_DUE_REC,
       SUM(DECODE(t.report_date, :ASOF_DATE, /*This date will be the as-of-date*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN past_due_open_amount  ELSE NULL END) ) )   FII_AR_END_PAST_DUE_REC,
			 SUM(DECODE(t.report_date, :ASOF_DATE, /*This date will be the as-of-date*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN billed_amount ELSE NULL END) ) )   FII_AR_BILLED_AMOUNT,
   SUM(DECODE(t.report_date, :PRIOR_PERIOD_START, /*This date will be starting date of the prior period*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount ELSE NULL END) ) )   FII_AR_PRIOR_BEG_OPEN_REC,
				SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE, /*This date will be the prior as-of-date*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_PRIOR_END_OPEN_REC,
		 SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE, /*This date will be the prior as-of-date*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN current_open_amount  ELSE NULL END) ) )   FII_AR_PRIOR_END_CURR_REC,
      SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE, /*This date will be the prior as-of-date*/
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN billed_amount  ELSE NULL END) ) )   FII_AR_PRIOR_BILLED_AMOUNT
  FROM FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix
             ||'  f,(	SELECT	/*+ no_merge '||l_gt_hint|| ' */ *
				FROM 	fii_time_structures cal,
					'||fii_ar_util_pkg.get_from_statement||' gt
		     	        WHERE	report_date IN ( :CURR_PERIOD_START ,
							 :ASOF_DATE,
							 :PREVIOUS_ASOF_DATE,
							 :PRIOR_PERIOD_START
						       )
					AND (	bitand(cal.record_type_id, :BITAND) = :BITAND OR
						bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
					    )
				AND '||fii_ar_util_pkg.get_where_statement||'
		     ) t
  WHERE  f.time_id = t.time_id
  AND f.period_type_id = t.period_type_id	'||l_child_party_where||'
  AND f.org_id = t.org_id
  AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_party_where ||' ' || l_collector_where ||' '|| l_cust_acct_where ||'
   GROUP BY  viewby_code, VIEWBY '||l_inner_cst_group||') inline_view
   '||l_order_by;

    -- Call Util package to bind the variables
    fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, coll_eff_sql, coll_eff_output);

END get_coll_eff_index;

----------------------------------------------------------------------------------------------
--Procedure for Collection Effectiveness Report
PROCEDURE get_coll_eff(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
coll_eff_sql out NOCOPY VARCHAR2, coll_eff_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt			VARCHAR2(15000);

  --Variables for where clauses
  l_collector_where		VARCHAR2(300);
  l_party_where 		VARCHAR2(300);
  l_child_party_where 		VARCHAR2(300);
  l_cust_acct_where 		VARCHAR2(300);
  l_industry_where		VARCHAR2(300);


  --Variables for drills
  l_self_drill			VARCHAR2(300);
  l_rec_amt_drill		VARCHAR2(300);
  l_rec_amt_drill_1		VARCHAR2(300);
  l_wadp_drill			VARCHAR2(300);
  l_rec_amt_drill_2		VARCHAR2(300);
  l_wadp_drill_1			VARCHAR2(300);

  --Select sql's
  l_select_sql1			varchar2(500);
  l_select_sql2			varchar2(500);

  --Only for viewby Customer
  l_inner_cst_select		varchar2(70);
  l_inner_cst_group		varchar2(50);
  l_self_drill_select		varchar2(200);

  --For Sorting
  l_order_by			varchar2(500);

  --For sending Customer id to detail reports
  l_customer_select		varchar2(500);
  l_gt_hint varchar2(500);
BEGIN

  fii_ar_util_pkg.reset_globals;

  --Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  --Get the order by clause for the report
  l_order_by := get_order_by;

  --This call will populate fii_ar_summary_gt table
  fii_ar_util_pkg.populate_summary_gt_tables;
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';
  --Amount Drills

  IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
    l_rec_amt_drill_2 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
    l_wadp_drill_1 := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  ELSE
    l_rec_amt_drill_2 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_wadp_drill_1 := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  l_rec_amt_drill := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  --Customer Account Parameter is to be sent to the detail report only in case of viewby Customer Account
  IF fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   l_rec_amt_drill_1 := 'pFunctionName=FII_AR_RCT_ACT_DTL&BIS_PMV_DRILL_CODE_FII_CUSTOMER_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
  ELSE
   l_rec_amt_drill_1 := 'pFunctionName=FII_AR_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  l_wadp_drill := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  -- Default View by select clause and self drill select clause
  --This will change in case of View by Customer
  l_self_drill_select := '''''';

  --Setting up the where clauses based on the Parameter and viewby
  --for Collector Dimension
  IF (fii_ar_util_pkg.g_collector_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') THEN
  	l_collector_where := 'AND f.collector_id = t.collector_id';
  END IF;

 --Customer Dimension where clause
 IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
  l_child_party_where := ' AND f.party_id   = t.party_id ';
 END IF;

 -- Defining industry where clause for specific industry (when view by is not Customer) or when viewby is Industry
 IF (fii_ar_util_pkg.g_industry_id <> '-111' AND fii_ar_util_pkg.g_view_by <> 'CUSTOMER+FII_CUSTOMERS') OR
       fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN

	l_industry_where :=  ' AND t.class_code = f.class_code AND t.class_category = f.class_category';
 END IF;

  -- Select, where, group by clauses based on viewby
  If((fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS')
	OR (fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR')
	OR (fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS')) THEN

	l_select_sql1 := ''''||l_rec_amt_drill_2||'''';
	l_select_sql2 := ''''||l_wadp_drill_1||'''';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN

	l_select_sql1 := ''''||l_rec_amt_drill_1||'''';
	l_select_sql2 := '''''';

	l_cust_acct_where := 'AND f.cust_account_id = t.cust_account_id';
	l_customer_select := ' t.party_id   party_id, ';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN

	IF (fii_ar_util_pkg.g_is_hierarchical_flag = 'Y') THEN
		l_select_sql1 := 'DECODE(inline_view.is_self_flag, ''Y'' ,'''||l_rec_amt_drill_1||''', DECODE(is_leaf_flag,''Y'', '''||l_rec_amt_drill_1||''', '''||l_rec_amt_drill||'''))';
		l_select_sql2 := 'DECODE(inline_view.is_self_flag, ''Y'' ,'''', DECODE(is_leaf_flag,''Y'', '''', '''||l_wadp_drill||'''))';

		--Self drill. This is reqd only in case of Viewby Customer
		--Check dynamically if the node is leaf or not. In case of non-leaf this drill is to be enabled.
		l_self_drill := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
		l_self_drill_select := 'DECODE(inline_view.is_self_flag, ''Y'' , '''', DECODE(inline_view.is_leaf_flag, ''Y'','''','''||l_self_drill||'''))';

		--Select and group by clauses for hierarchical Customer dimension
		l_inner_cst_select := 'is_self_flag is_self_flag, is_leaf_flag is_leaf_flag,';
		l_inner_cst_group := ', is_self_flag, is_leaf_flag';

	ELSE
		l_select_sql1 := ''''||l_rec_amt_drill_1||'''';
		l_select_sql2 := '''''';

	END IF;

        -- Where clause for view by Customer Dimension
	l_party_where := 'AND f.parent_party_id = t.parent_party_id';


  END IF;

  IF  fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   l_inner_cst_group := l_inner_cst_group || ' ,t.party_id';
  END IF;

  --Call to set up the global variables for scaling factor and sign for billed amount
  get_scaling_factor;

 --Formation of the sql for the report
 sqlstmt := 'SELECT
        inline_view.viewby          VIEWBY,
	inline_view .viewby_id	    VIEWBYID,
	((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)),0))  * 100 FII_AR_COLL_EFF_INDEX,
(((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)
	+(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)
	+(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)),0)) * 100) -
        (((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	-DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)),0)) * 100)  FII_AR_COLL_EFF_CHANGE,
(FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0))	FII_AR_DAYS_PAID,
((FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) - (FII_AR_PRIOR_WTD_DP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)))FII_AR_CHANGE_DP,
((FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) - (FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)))	FII_AR_DAYS_DELQ,
(((FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) - (FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)))
	-
	((FII_AR_PRIOR_WTD_DP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)) - (FII_AR_PRIOR_WTD_TP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0))) )	FII_AR_CHANGE_DD,
(FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0))	FII_AR_TERMS_PAID,
((FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) - (FII_AR_PRIOR_WTD_TP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)))	FII_AR_CHANGE_TP,
FII_AR_BILLED_AMOUNT	FII_AR_BILLED_AMOUNT,
FII_AR_REC_AMT	FII_AR_REC_AMT,
((sum(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)) over()
	+sum(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)) over())/
        NULLIF((sum(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))over()
	+sum(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)) over()),0)) * 100 FII_AR_GT_COLL_EFF_IND,
(((sum(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC)) over()
	+sum(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)) over())/
        NULLIF((sum(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))over()
	+sum(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT) '||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC)) over()),0)) * 100 ) -
        (((sum(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)) over()
	+sum(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC)) over())/
        NULLIF((sum(DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)) over()
	+sum(DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||') over()
	-sum(DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)) over()),0)) * 100 ) FII_AR_GT_COLL_EFF_CHG,
(SUM(FII_AR_WTD_DAYS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0))	FII_AR_GT_DP,
((SUM(FII_AR_WTD_DAYS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)) - (SUM(FII_AR_PRIOR_WTD_DP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0)))	FII_AR_GT_DP_CHG,
((SUM(FII_AR_WTD_DAYS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)) - (SUM(FII_AR_WTD_TERMS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)))	FII_AR_GT_DD,
(((SUM(FII_AR_WTD_DAYS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)) - (SUM(FII_AR_WTD_TERMS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)))
	-
	((SUM(FII_AR_PRIOR_WTD_DP_NUM) OVER() /NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0)) - (SUM(FII_AR_PRIOR_WTD_TP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0))) )        FII_AR_GT_DD_CHG,
	(SUM(FII_AR_WTD_TERMS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0))	FII_AR_GT_TP,
((SUM(FII_AR_WTD_TERMS_PAID_NUM) OVER()/NULLIF(SUM(FII_AR_APPLIED_AMOUNT) OVER(),0)) - (SUM(FII_AR_PRIOR_WTD_TP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0)))	FII_AR_GT_TP_CHG,
SUM(FII_AR_BILLED_AMOUNT) OVER()	FII_AR_GT_BILLED_AMT,
SUM(FII_AR_REC_AMT) OVER()	FII_AR_GT_REC_AMT,
((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0, FII_AR_PRIOR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_OPEN_REC, NULL, 0, FII_AR_PRIOR_END_OPEN_REC))/
        NULLIF((DECODE(FII_AR_PRIOR_BEG_OPEN_REC, NULL, 0,FII_AR_PRIOR_BEG_OPEN_REC)
	+ (DECODE(FII_AR_PRIOR_BILLED_AMOUNT, NULL, 0, FII_AR_PRIOR_BILLED_AMOUNT)'||g_scale_sign||' '||g_scaling_factor||')
	- DECODE(FII_AR_PRIOR_END_CURR_REC, NULL, 0, FII_AR_PRIOR_END_CURR_REC)),0)) * 100 FII_AR_PRIO_COLL_EFF_INDEX_G,
((FII_AR_PRIOR_WTD_DP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)) - (FII_AR_PRIOR_WTD_TP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)))	FII_AR_AVG_DD_PRIOR_G,
	'||l_self_drill_select ||'  FII_AR_VIEW_BY_DRILL,
DECODE(FII_AR_REC_AMT,0,'''',DECODE(NVL(FII_AR_REC_AMT,-999999),-999999,'''',
	'||l_select_sql1||')) FII_AR_REC_AMT_DRILL,
DECODE((FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)),0,'''',DECODE(NVL((FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)),-999999),-999999,'''',
	'||l_select_sql2||')) FII_AR_WADP_DRILL,
	FII_AR_PRIOR_REC_AMT		 FII_AR_PRIOR_REC_AMT,
	SUM(FII_AR_PRIOR_REC_AMT) OVER() FII_AR_GT_PRIOR_REC_AMT,
	FII_AR_PRIOR_WTD_DP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)	FII_AR_PRIOR_WTD_AVG_DP,
        ((FII_AR_PRIOR_WTD_DP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)) - (FII_AR_PRIOR_WTD_TP_NUM/NULLIF(FII_AR_PRIOR_APPLIED_AMOUNT,0)))	FII_AR_PRIOR_WTD_AVG_DD,
          NVL((SUM(FII_AR_PRIOR_WTD_DP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0)),0)	FII_AR_GT_PRIOR_WTD_AVG_DP,
NVL( ((SUM(FII_AR_PRIOR_WTD_DP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0))
  - (SUM(FII_AR_PRIOR_WTD_TP_NUM) OVER()/NULLIF(SUM(FII_AR_PRIOR_APPLIED_AMOUNT) OVER(),0))),0)	FII_AR_GT_PRIOR_WTD_AVG_DD
	FROM (
  SELECT	  /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/ VIEWBY,
		  viewby_code	viewby_id,
'|| l_inner_cst_select || l_customer_select ||'
		SUM(DECODE(t.report_date, :CURR_PERIOD_START ,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_BEG_OPEN_REC,
				 SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_END_OPEN_REC,
			SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN current_open_amount  ELSE NULL END) ) )   FII_AR_END_CURR_REC,
			SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN billed_amount ELSE NULL END) ) )   FII_AR_BILLED_AMOUNT,
		   SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN app_amount ELSE NULL END) ) )   FII_AR_APPLIED_AMOUNT,
SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN wtd_days_paid_num ELSE NULL END) ) )   FII_AR_WTD_DAYS_PAID_NUM,
SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN wtd_terms_paid_num ELSE NULL END) ) )   FII_AR_WTD_TERMS_PAID_NUM,
    SUM(DECODE(t.report_date, :ASOF_DATE,
					(CASE WHEN (f.header_filter_date <= :ASOF_DATE) and
					(f.header_filter_date >= :CURR_PERIOD_START) and (bitand(t.record_type_id,:BITAND) = :BITAND)
					 THEN total_receipt_amount ELSE NULL END) ) )   FII_AR_REC_AMT,
	SUM(DECODE(t.report_date, :PRIOR_PERIOD_START,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount ELSE NULL END) ) )   FII_AR_PRIOR_BEG_OPEN_REC,
				SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN total_open_amount  ELSE NULL END) ) )   FII_AR_PRIOR_END_OPEN_REC,
		SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
						THEN current_open_amount  ELSE NULL END) ) )   FII_AR_PRIOR_END_CURR_REC,
     SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN billed_amount  ELSE NULL END) ) )   FII_AR_PRIOR_BILLED_AMOUNT,
SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN app_amount ELSE NULL END) ) )   FII_AR_PRIOR_APPLIED_AMOUNT,
		SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN wtd_days_paid_num ELSE NULL END) ) )   FII_AR_PRIOR_WTD_DP_NUM,
SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN bitand(t.record_type_id,:BITAND) = :BITAND
						THEN wtd_terms_paid_num ELSE NULL END) ) )   FII_AR_PRIOR_WTD_TP_NUM,
SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE,
					(CASE	WHEN (f.header_filter_date <= :PREVIOUS_ASOF_DATE) and
					(f.header_filter_date >= :PRIOR_PERIOD_START) and (bitand(t.record_type_id,:BITAND) = :BITAND)
						THEN total_receipt_amount ELSE NULL END) ) )   FII_AR_PRIOR_REC_AMT
	FROM FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix
             ||'  f,(	SELECT	/*+ no_merge '||l_gt_hint|| ' */  *
				FROM 	fii_time_structures cal,
					'||fii_ar_util_pkg.get_from_statement||' gt
		     	        WHERE	report_date in ( :CURR_PERIOD_START ,
							 :ASOF_DATE,
							 :PREVIOUS_ASOF_DATE,
							 :PRIOR_PERIOD_START
						       )
					AND (	bitand(cal.record_type_id, :BITAND) = :BITAND OR
						bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
					    )
				AND '||fii_ar_util_pkg.get_where_statement||'
		     ) t
  WHERE  f.time_id = t.time_id
  AND f.period_type_id = t.period_type_id	'||l_child_party_where||'
  AND f.org_id = t.org_id
  AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_party_where ||' ' || l_collector_where ||' '|| l_cust_acct_where ||' '|| l_industry_where ||'
  GROUP BY  viewby_code, VIEWBY '||l_inner_cst_group||' ) inline_view
   '||l_order_by;

 fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, coll_eff_sql, coll_eff_output);

END get_coll_eff;

--   This procedure will provide sql statement to retrieve data for Collection Effectiveness Report
PROCEDURE get_coll_eff_trend(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
coll_eff_trend_sql out NOCOPY VARCHAR2, coll_eff_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  sqlstmt			VARCHAR2(32767); --Final sql statement
  l_curr_sql_stmt		VARCHAR2(10000); --Intermediate sql statement to hold the Current periods sql
  l_select_clause		VARCHAR2(30000); --Intermediate sql statement for the upper select part of the final sql

  --Variables for where clauses
  l_collector_where		VARCHAR2(300); --Collector Dimension where clause
  l_party_where 		VARCHAR2(300); --Customer Dimension where clause
  l_industry_where		VARCHAR2(300); --Industry Dimension where clause

  --Time table variable
  l_time_table			varchar2(30); --Variable to hold time table based on Period Type parameter

  --Date bind variable
  l_date_bind			varchar2(20); --Date bind variable decided based on as of date

  --Variables for prior columns select
  l_prior_column		VARCHAR2(5000); --Prior columns select clause
  l_current_prior_column	varchar2(5000); --Prior columns select clause for current period

BEGIN

  fii_ar_util_pkg.reset_globals;
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
  fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';

  --Call to set up the global variables for scaling factor and sign for billed amount
  get_scaling_factor;

  --This call will populate fii_ar_summary_gt table
  fii_ar_util_pkg.populate_summary_gt_tables;

  --Decide which time table needs to be hit
  IF (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK') THEN
   l_time_table := 'FII_TIME_WEEK';
  ELSIF  (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD') THEN
   l_time_table := 'FII_TIME_ENT_PERIOD';
  ELSIF  (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') THEN
   l_time_table := 'FII_TIME_ENT_QTR';
  ELSE
   l_time_table := 'FII_TIME_ENT_YEAR';
  END IF;

  --Setting up the where clauses based on the Parameter
  --for Collector Dimension
  IF (fii_ar_util_pkg.g_collector_id <> '-111' ) THEN
  	l_collector_where := 'AND f.collector_id = t.collector_id';
  END IF;

  --Customer Dimension where clause
  IF (fii_ar_util_pkg.g_party_id <> '-111' ) THEN
   l_party_where := ' AND f.party_id   = t.party_id ';
  END IF;

  --Industry where clause
  IF fii_ar_util_pkg.g_industry_id <> '-111' THEN
        l_industry_where :=  ' AND t.class_code = f.class_code AND t.class_category = f.class_category';
  END IF;

  -------------------------------------------------------------------------------
  --Drills over WADP, CEI and Receipts Amount
  --1) WADP Drills to Collection Effectiveness Report with viewby OU
  --2) CEI Drills to Collection Effectiveness Index Summary Report with viewby OU
  --3) Receipts Amount drills to Receipts Activity Report with viewby OU
  -------------------------------------------------------------------------------

  /*-------------------------------------------------------------------------------
  Bind Variable			Description
  --------------		-------------
  :ASOF_DATE			As Of Date
  :CURR_PERIOD_START		Start Date of the current period
  :BITAND			XTD Bitand value
  :BITAND_INC_TODATE		Bitand for ITD
  :PREVIOUS_ASOF_DATE		Prior as of date
  :PRIOR_PERIOD_START		Start Date of the prior period
  :CURR_PERIOD_END		End Date of Current Period
  :SD_SDATE			Start Date for Current Data
  :SD_PRIOR_PRIOR		Start Date of the prior prior period
  :SD_PRIOR			Start date of the prior period
  -------------------------------------------------------------------------------*/

  /* This condition handles, whether parameter compare to chosen is Prior Period.
     IF Yes, then no need to show Prior Data Otherwise show Prior data. */
  -------------------------------------------------------------------
  --Per FDD when COMPARE TO = PRIOR PERIOD/'SEQUENTIAL' then
  --No prior data is to be shown
  --and when COMPARE TO <> PRIOR PERIOD/'SEQUENTIAL' then
  --Prior Data is to be shown with an exception of period type Year
  -------------------------------------------------------------------

  IF fii_ar_util_pkg.g_time_comp = 'SEQUENTIAL' OR fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
	l_prior_column:= ' NULL FII_PRIOR_AR_BEG_OPEN_REC,
			NULL FII_PRIOR_AR_END_OPEN_REC,
			NULL FII_PRIOR_AR_END_CURR_REC,
			NULL FII_PRIOR_AR_BILLED_AMOUNT,  ';

	l_current_prior_column:= ' NULL FII_PRIOR_AR_BEG_OPEN_REC,
			NULL FII_PRIOR_AR_END_OPEN_REC,
			NULL FII_PRIOR_AR_END_CURR_REC,
			NULL FII_PRIOR_AR_BILLED_AMOUNT,  ';

  ELSE
        l_prior_column:= ' SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' ,
	    CASE
		WHEN t.report_date < :SD_SDATE
		AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		THEN f.total_open_amount
		ELSE null
	    END )) FII_PRIOR_AR_BEG_OPEN_REC,
	    SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'', null,
	    CASE
		WHEN t.report_date < :SD_SDATE
		AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		THEN f.total_open_amount
		ELSE null
	    END     )) FII_PRIOR_AR_END_OPEN_REC,
	    SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
	    CASE
		WHEN t.report_date < :SD_SDATE
		AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		THEN f.current_open_amount
		ELSE null
	    END    )) FII_PRIOR_AR_END_CURR_REC,
	    SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'', null,
            CASE
		WHEN t.report_date < :SD_SDATE
		AND bitand(t.record_type_id, :BITAND) = :BITAND
		THEN f.billed_amount
            ELSE NULL
            END )) FII_PRIOR_AR_BILLED_AMOUNT, ';

   l_current_prior_column := ' SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
        CASE
            WHEN t.report_date = :PRIOR_PERIOD_START /*This needs to be the first date of the month */
            THEN f.total_open_amount
            ELSE null
        END
        )) FII_PRIOR_AR_BEG_OPEN_REC,
	    SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
	    CASE
		WHEN t.report_date = :PREVIOUS_ASOF_DATE
		AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		THEN f.total_open_amount
		ELSE null
	    END     )) FII_PRIOR_AR_END_OPEN_REC,
	    SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
	    CASE
		WHEN t.report_date = :PREVIOUS_ASOF_DATE
		AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		THEN f.current_open_amount
		ELSE null
	    END    )) FII_PRIOR_AR_END_CURR_REC,
	    SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
            CASE
		WHEN t.report_date = :PREVIOUS_ASOF_DATE
		AND bitand(t.record_type_id, :BITAND) = :BITAND
		THEN f.billed_amount
            ELSE NULL
            END )) FII_PRIOR_AR_BILLED_AMOUNT, ';

  END IF;

  ---------------------------------------------------------------
  --Code to decide which Date bind variable to be used in the sql
  --IF as of date = current period end then
  --union all is not required
  --else union all part will be used for the current period
  ----------------------------------------------------------------
  IF( fii_ar_util_pkg.g_as_of_date = fii_ar_util_pkg.g_curr_per_end) THEN
   l_date_bind := ':ASOF_DATE';

   l_curr_sql_stmt := ' ';

    /*Upper select clause. This is common for all period types*/
    -- In this case Union All is not required which means all periods are fully exhausted and
    -- hence the scaling factor are constant for all

   l_select_clause := 'SELECT
     cy_per.name FII_AR_COLL_EFF_VIEW_BY,
     FII_AR_COLL_EFF_INDEX * 100 FII_AR_COLL_EFF_INDEX,
     FII_AR_PRIO_COLL_EFF_INDEX_G * 100 FII_AR_PRIO_COLL_EFF_INDEX_G,
     FII_AR_WTD_AVG_DP,
     (FII_AR_WTD_AVG_DP - FII_AR_WTD_AVG_TP) FII_AR_DAYS_DELQ,
     FII_AR_WTD_AVG_TP,
     FII_AR_REC_AMT,
DECODE(FII_AR_WTD_AVG_DP,0,'''',DECODE(NVL(FII_AR_WTD_AVG_DP, -99999),-99999, '''',DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_DAYS_PAID_DRILL,
 DECODE(FII_AR_COLL_EFF_INDEX,0,'''',DECODE(NVL(FII_AR_COLL_EFF_INDEX, -99999),-99999, '''',DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_COLL_EFF_INDEX&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_COLL_EFF_INDEX&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_CEI_DRILL,
 DECODE(FII_AR_REC_AMT,0,'''',DECODE(NVL(FII_AR_REC_AMT, -99999),-99999, '''', DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_RCT_AMT_DRILL
 FROM '||l_time_table||' cy_per, (
    SELECT
        sequence sequence,
(SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    - SUM(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)))
    /NULLIF((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    -SUM(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC))),0) FII_AR_COLL_EFF_INDEX,
 SUM(FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_WTD_AVG_DP,
    SUM(FII_AR_AVG_DD_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_DAYS_DELQ,
    SUM(FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_WTD_AVG_TP,
    SUM(FII_AR_REC_AMT) FII_AR_REC_AMT,
 (SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    -SUM(DECODE(FII_PRIOR_AR_END_OPEN_REC, NULL, 0, FII_PRIOR_AR_END_OPEN_REC)))
    /NULLIF((SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    - SUM(DECODE(FII_PRIOR_AR_END_CURR_REC, NULL, 0, FII_PRIOR_AR_END_CURR_REC))),0) FII_AR_PRIO_COLL_EFF_INDEX_G
  from (
     SELECT per.name,per.sequence,
   sum(FII_AR_REC_AMT) FII_AR_REC_AMT,
   sum(FII_AR_BEG_OPEN_REC) FII_AR_BEG_OPEN_REC,
   sum(FII_AR_END_OPEN_REC) FII_AR_END_OPEN_REC,
   sum(FII_AR_END_CURR_REC) FII_AR_END_CURR_REC,
   sum(FII_PRIOR_AR_BEG_OPEN_REC) FII_PRIOR_AR_BEG_OPEN_REC,
   sum(FII_PRIOR_AR_END_OPEN_REC)FII_PRIOR_AR_END_OPEN_REC,
   sum(FII_PRIOR_AR_END_CURR_REC) FII_PRIOR_AR_END_CURR_REC,
   sum(FII_PRIOR_AR_BILLED_AMOUNT) FII_PRIOR_AR_BILLED_AMOUNT,
   sum(FII_AR_BILLED_AMOUNT) FII_AR_BILLED_AMOUNT,
   sum(FII_AR_APPLIED_AMOUNT) FII_AR_APPLIED_AMOUNT,
   sum(FII_AR_WTD_DAYS_PAID_NUM) FII_AR_WTD_DAYS_PAID_NUM,
   sum(FII_AR_WTD_TERMS_PAID_NUM) FII_AR_WTD_TERMS_PAID_NUM,
   sum(FII_AR_AVG_DD_NUM) FII_AR_AVG_DD_NUM FROM '||l_time_table||' per,(';

  ELSE
   l_date_bind := ':CURR_PERIOD_START';
   l_curr_sql_stmt := '  UNION ALL
    SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
        per.name,
        per.sequence sequence,
        SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN (t.report_date = :ASOF_DATE)
	    AND (f.header_filter_date <= :ASOF_DATE )
 	    AND (f.header_filter_date >= :CURR_PERIOD_START)
            THEN f.total_receipt_amount
            ELSE null
        END
        )) FII_AR_REC_AMT,
        SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
        CASE
            WHEN t.report_date = :CURR_PERIOD_START
            THEN f.total_open_amount
            ELSE null
        END
        )) FII_AR_BEG_OPEN_REC,
        SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.total_open_amount
            ELSE null
        END
        )) FII_AR_END_OPEN_REC,
        SUM(DECODE(bitand(t.record_type_id,:BITAND_INC_TODATE), :BITAND_INC_TODATE,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.current_open_amount
            ELSE null
        END
        )) FII_AR_END_CURR_REC,
        '||l_current_prior_column||'
        SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.billed_amount
            ELSE null
        END
        )) FII_AR_BILLED_AMOUNT,
       SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.app_amount
            ELSE null
        END
        )) FII_AR_APPLIED_AMOUNT,
        SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.wtd_days_paid_num
            ELSE null
        END
        )) FII_AR_WTD_DAYS_PAID_NUM,
        SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.wtd_terms_paid_num
            ELSE null
        END
        )) FII_AR_WTD_TERMS_PAID_NUM,
        SUM(DECODE(bitand(t.record_type_id,:BITAND), :BITAND,
        CASE
            WHEN t.report_date = :ASOF_DATE
            THEN f.avg_dd_num
            ELSE null
        END
        )) FII_AR_AVG_DD_NUM
    FROM '||l_time_table||' per,
        FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
        (
        SELECT /*+ no_merge leading(gt) cardinality(gt 1)*/  *
        FROM fii_time_structures cal,
            fii_ar_summary_gt gt
        WHERE report_date in(:ASOF_DATE, :PREVIOUS_ASOF_DATE, :PRIOR_PERIOD_START, :CURR_PERIOD_START)
            AND
            (
                bitand(cal.record_type_id, :BITAND) = :BITAND
                OR bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
            )
        ) t
    WHERE f.time_id = t.time_id
    AND f.period_type_id = t.period_type_id
    AND f.org_id = t.org_id '|| l_party_where ||' ' || l_collector_where ||' ' || l_industry_where || '
    AND per.end_date = :CURR_PERIOD_END
    AND '||fii_ar_util_pkg.get_mv_where_statement||'
    GROUP BY t.report_date, per.sequence, name';

     /*Upper select clause. This is common for all period types*/
     -- In case when Union All is used which means that the current period should use a different scaling factor compared to
     -- the other periods

    l_select_clause := 'SELECT
     cy_per.name FII_AR_COLL_EFF_VIEW_BY,
     FII_AR_COLL_EFF_INDEX * 100 FII_AR_COLL_EFF_INDEX,
     FII_AR_PRIO_COLL_EFF_INDEX_G * 100 FII_AR_PRIO_COLL_EFF_INDEX_G,
     FII_AR_WTD_AVG_DP,
     (FII_AR_WTD_AVG_DP - FII_AR_WTD_AVG_TP) FII_AR_DAYS_DELQ,
     FII_AR_WTD_AVG_TP,
     FII_AR_REC_AMT,
 DECODE(FII_AR_WTD_AVG_DP,0,'''',DECODE(NVL(FII_AR_WTD_AVG_DP, -99999),-99999, '''',DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_DAYS_PAID_DRILL,
 DECODE(FII_AR_COLL_EFF_INDEX,0,'''',DECODE(NVL(FII_AR_COLL_EFF_INDEX, -99999),-99999, '''',DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_COLL_EFF_INDEX&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_COLL_EFF_INDEX&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_CEI_DRILL,
   DECODE(FII_AR_REC_AMT,0,'''',DECODE(NVL(FII_AR_REC_AMT, -99999),-99999, '''', DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'' )))
	FII_AR_RCT_AMT_DRILL
FROM '||l_time_table||' cy_per, (
    SELECT
        sequence sequence,
     DECODE (sequence, ' || g_current_sequence ||',
    (SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign||' '||g_scaling_factor||')
    - SUM(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)))/NULLIF((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign||' '||g_scaling_factor||')
    -SUM(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC))),0),
    (SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    - SUM(DECODE(FII_AR_END_OPEN_REC, NULL, 0, FII_AR_END_OPEN_REC)))/NULLIF((SUM(DECODE(FII_AR_BEG_OPEN_REC, NULL, 0, FII_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_AR_BILLED_AMOUNT, NULL, 0, FII_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    -SUM(DECODE(FII_AR_END_CURR_REC, NULL, 0, FII_AR_END_CURR_REC))),0) )FII_AR_COLL_EFF_INDEX,
 SUM(FII_AR_WTD_DAYS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_WTD_AVG_DP,
    SUM(FII_AR_AVG_DD_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_DAYS_DELQ,
    SUM(FII_AR_WTD_TERMS_PAID_NUM/NULLIF(FII_AR_APPLIED_AMOUNT,0)) FII_AR_WTD_AVG_TP,
    SUM(FII_AR_REC_AMT) FII_AR_REC_AMT,
 DECODE (sequence, ' || g_current_sequence ||',
    (SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign||' '||g_scaling_factor||')
    -SUM(DECODE(FII_PRIOR_AR_END_OPEN_REC, NULL, 0, FII_PRIOR_AR_END_OPEN_REC)))/NULLIF((SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign||' '||g_scaling_factor||')
    - SUM(DECODE(FII_PRIOR_AR_END_CURR_REC, NULL, 0, FII_PRIOR_AR_END_CURR_REC))),0),
    (SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    -SUM(DECODE(FII_PRIOR_AR_END_OPEN_REC, NULL, 0, FII_PRIOR_AR_END_OPEN_REC)))/NULLIF((SUM(DECODE(FII_PRIOR_AR_BEG_OPEN_REC, NULL, 0, FII_PRIOR_AR_BEG_OPEN_REC))
    +(SUM(DECODE(FII_PRIOR_AR_BILLED_AMOUNT, NULL, 0, FII_PRIOR_AR_BILLED_AMOUNT))'||g_scale_sign_cons||' '||g_scaling_factor_cons||')
    - SUM(DECODE(FII_PRIOR_AR_END_CURR_REC, NULL, 0, FII_PRIOR_AR_END_CURR_REC))),0) ) FII_AR_PRIO_COLL_EFF_INDEX_G
	from (
   SELECT per.name,per.sequence,
   sum(FII_AR_REC_AMT) FII_AR_REC_AMT,
   sum(FII_AR_BEG_OPEN_REC) FII_AR_BEG_OPEN_REC,
   sum(FII_AR_END_OPEN_REC) FII_AR_END_OPEN_REC,
   sum(FII_AR_END_CURR_REC) FII_AR_END_CURR_REC,
   sum(FII_PRIOR_AR_BEG_OPEN_REC) FII_PRIOR_AR_BEG_OPEN_REC,
   sum(FII_PRIOR_AR_END_OPEN_REC)FII_PRIOR_AR_END_OPEN_REC,
   sum(FII_PRIOR_AR_END_CURR_REC) FII_PRIOR_AR_END_CURR_REC,
   sum(FII_PRIOR_AR_BILLED_AMOUNT) FII_PRIOR_AR_BILLED_AMOUNT,
   sum(FII_AR_BILLED_AMOUNT) FII_AR_BILLED_AMOUNT,
   sum(FII_AR_APPLIED_AMOUNT) FII_AR_APPLIED_AMOUNT,
   sum(FII_AR_WTD_DAYS_PAID_NUM) FII_AR_WTD_DAYS_PAID_NUM,
   sum(FII_AR_WTD_TERMS_PAID_NUM) FII_AR_WTD_TERMS_PAID_NUM,
   sum(FII_AR_AVG_DD_NUM) FII_AR_AVG_DD_NUM FROM '||l_time_table||' per,(';


  END IF;


IF fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK' OR fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' OR fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN
 sqlstmt := l_select_clause || '
     SELECT /*+ no_merge INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
        t.report_date,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN (t.report_date >= :SD_SDATE )
	    AND (f.header_filter_date <= t.report_date)
	    AND (f.header_filter_date >= (select start_date
		                             from '||l_time_table||'
					     where end_date = t.report_date))
            AND (bitand(t.record_type_id, :BITAND) = :BITAND )
            THEN f.total_receipt_amount
            ELSE NULL
        END )) FII_AR_REC_AMT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' ,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE /*This needs to be the first date of the month */
            THEN f.total_open_amount
            ELSE null
        END )) FII_AR_BEG_OPEN_REC,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'', null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
            THEN f.total_open_amount
            ELSE null
        END
        )) FII_AR_END_OPEN_REC,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
            THEN f.current_open_amount
            ELSE null
        END
        )) FII_AR_END_CURR_REC,
     '||l_prior_column||'
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.billed_amount
            ELSE NULL
        END))
        FII_AR_BILLED_AMOUNT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.app_amount
            ELSE NULL
        END ))        FII_AR_APPLIED_AMOUNT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'', null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.wtd_days_paid_num
            ELSE NULL
        END ))        FII_AR_WTD_DAYS_PAID_NUM,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.wtd_terms_paid_num
            ELSE NULL
        END ))        FII_AR_WTD_TERMS_PAID_NUM,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN t.report_date >= :SD_SDATE
            AND bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.avg_dd_num
            ELSE NULL
        END ))        FII_AR_AVG_DD_NUM
 FROM  FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix
             ||' f,
        (
         SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) leading(gt) cardinality(gt 1)*/   *
	 FROM fii_time_structures cal,
         fii_ar_summary_gt gt
	 WHERE report_date in
         (
          SELECT end_date
          FROM '||l_time_table||' cy_per
          WHERE cy_per.start_date < '||l_date_bind||'
          AND cy_per.start_date >= :SD_PRIOR_PRIOR
          UNION
          SELECT start_date
          FROM '||l_time_table||' cy_per
          WHERE cy_per.start_date <'||l_date_bind||'
          AND cy_per.start_date >=:SD_PRIOR_PRIOR
         )
         AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE  OR bitand(cal.record_type_id, :BITAND) = :BITAND )
        )
        t
    WHERE f.time_id = t.time_id
    AND f.period_type_id = t.period_type_id
    AND f.org_id = t.org_id
    AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_party_where ||' ' || l_collector_where ||' ' || l_industry_where || '
     GROUP BY t.report_date) mv
    WHERE     per.start_date >= :SD_PRIOR_PRIOR
    and ( per.end_date = mv.report_date
        OR per.start_date = mv.report_date)
    GROUP BY per.sequence, per.name
    '||l_curr_sql_stmt||'
    )
    group by sequence)outer_view
 WHERE cy_per.start_date <= :ASOF_DATE
 AND cy_per.start_date > :SD_PRIOR
 AND cy_per.sequence = outer_view.sequence (+)
 ORDER BY cy_per.start_date   ';

 ELSE
/*This part will be called in case of year
  Prior data is not required in case of Year*/


  sqlstmt := l_select_clause || '
     SELECT
        /*+ no_merge INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
        t.report_date,
      SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  (f.header_filter_date <= t.report_date)
	    AND (f.header_filter_date >= (select start_date
		                             from '||l_time_table||'
					     where end_date = t.report_date))
   AND (bitand(t.record_type_id, :BITAND) = :BITAND)
            THEN f.total_receipt_amount
            ELSE NULL
        END )) FII_AR_REC_AMT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' ,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE /*This needs to be the first date of the month */
            THEN f.total_open_amount
            ELSE null
        END )) FII_AR_BEG_OPEN_REC,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
            THEN f.total_open_amount
            ELSE null
        END
        )) FII_AR_END_OPEN_REC,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN bitand(t.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
            THEN f.current_open_amount
            ELSE null
        END
        )) FII_AR_END_CURR_REC,
        '||l_prior_column||'
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.billed_amount
            ELSE NULL
        END))
        FII_AR_BILLED_AMOUNT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.app_amount
            ELSE NULL
        END ))        FII_AR_APPLIED_AMOUNT,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.wtd_days_paid_num
            ELSE NULL
        END ))        FII_AR_WTD_DAYS_PAID_NUM,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.wtd_terms_paid_num
            ELSE NULL
        END ))        FII_AR_WTD_TERMS_PAID_NUM,
        SUM(DECODE((SELECT ''Y'' from '||l_time_table||'
		    WHERE start_date = t.report_date), ''Y'' , null,
        CASE
            WHEN  bitand(t.record_type_id, :BITAND) = :BITAND
            THEN f.avg_dd_num
            ELSE NULL
        END ))        FII_AR_AVG_DD_NUM
FROM  FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix
             ||' f,
        (
         SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) leading(gt) cardinality(gt 1) */  *
	 FROM fii_time_structures cal,
         fii_ar_summary_gt gt
	 WHERE report_date in
         (
          SELECT end_date
          FROM '||l_time_table||' cy_per
          WHERE cy_per.start_date < '||l_date_bind||'
          AND cy_per.start_date >= :SD_PRIOR_PRIOR
          UNION
          SELECT start_date
          FROM '||l_time_table||' cy_per
          WHERE cy_per.start_date < '||l_date_bind||'
          AND cy_per.start_date >=:SD_PRIOR_PRIOR
         )
         AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE  OR bitand(cal.record_type_id, :BITAND) = :BITAND )
        ) t
    WHERE f.time_id = t.time_id
    AND f.period_type_id = t.period_type_id
    AND f.org_id = t.org_id
    AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_party_where ||'
    ' || l_collector_where ||'
    ' || l_industry_where || '
    GROUP BY t.report_date) mv
    WHERE     per.start_date >= :SD_PRIOR_PRIOR
    and ( per.end_date = mv.report_date
        OR per.start_date = mv.report_date
	)
    GROUP BY per.sequence, per.name
   '||l_curr_sql_stmt||'
    )
    group by sequence)outer_view
  WHERE cy_per.start_date <= :ASOF_DATE
  AND cy_per.start_date > :SD_PRIOR
  AND cy_per.sequence = outer_view.sequence (+)
  ORDER BY cy_per.start_date   ';

 END IF;

 fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, coll_eff_trend_sql, coll_eff_trend_output);

END get_coll_eff_trend;

END fii_ar_coll_eff_ind_pkg;


/
