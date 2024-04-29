--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_ACTIVITY_PKG" AS
/* $Header: FIIARDBIRECACTVB.pls 120.19 2007/05/15 20:52:42 vkazhipu ship $ */

PROCEDURE get_rec_activity (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        rec_activity_sql             OUT NOCOPY VARCHAR2,
        rec_activity_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

sqlstmt                       VARCHAR2(30000);

  --Variables for where clauses
  l_collector_where		VARCHAR2(300);
  l_industry_where		VARCHAR2(300);
  l_parent_party_where 		VARCHAR2(300);
  l_party_where 		VARCHAR2(300);
  l_cust_acct_where 		VARCHAR2(300);

  --Variables for drills
  l_summary_drill		VARCHAR2(300);
  l_total_rec_xtd_summary_drill	VARCHAR2(1000);
  l_total_rec_count_drill	VARCHAR2(300);
  l_app_rec_xtd_summary_drill	VARCHAR2(300);
  l_total_rec_xtd_detail_drill	VARCHAR2(300);
  l_app_rec_xtd_detail_drill	VARCHAR2(300);
  l_total_rec_xtd_summary_dr_1	VARCHAR2(1000);
  l_app_rec_xtd_summary_dr_1	VARCHAR2(300);

  --Select sqls
  l_total_rec_xtd_drill		VARCHAR2(500);
  l_total_applied_xtd_drill	VARCHAR2(500);

  --Only for viewby Customer
  l_inner_cst_columns		VARCHAR2(50);
  l_customer_drill		VARCHAR2(10000);

  --For Order by Clause
  l_order_by			VARCHAR2(500);
  l_order_column		VARCHAR2(100);
  l_curr_month_end		date;
  l_curr_month_end_drill        varchar2(50);
  l_gt_hint varchar2(500);
BEGIN
  --Call to reset the parameter variables
  fii_ar_util_pkg.reset_globals;

  --Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';

  --Frame the order by clause for the report sql
  IF(instr(fii_ar_util_pkg.g_order_by,',') <> 0) THEN

   /*This means no particular sort column is selected in the report,
   So sort on the default column FII_AR_TOTAL_REC_XTD in descending order
   NVL is added to make sure the null values appear last*/

   l_order_by := 'ORDER BY NVL(FII_AR_TOTAL_REC_XTD, -999999999) DESC';

  ELSIF(instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0)THEN

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

  -- To get the month end date to be passed to Receipt Activity Detail report
  SELECT nvl(end_date, sysdate) INTO l_curr_month_end
  FROM	 fii_time_ent_period
  WHERE  fii_ar_util_pkg.g_as_of_date between start_date and END_date;

  l_curr_month_end_drill := to_char(l_curr_month_end,'DD/MM/YYYY');

  --This call will populate fii_ar_summary_gt table
  fii_ar_util_pkg.populate_summary_gt_tables;

-- Assigning self drill for view-by Customer scenario to NULL

  l_customer_drill := '''''';

--Amount Drills
  l_total_rec_xtd_summary_drill := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

  l_total_rec_count_drill := 'pFunctionName=FII_AR_REC_ACTIVITY_TREND&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

  l_app_rec_xtd_summary_drill := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';


  IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
   l_total_rec_xtd_summary_dr_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
   l_app_rec_xtd_summary_dr_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
  ELSE
   l_total_rec_xtd_summary_dr_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_app_rec_xtd_summary_dr_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';

  END IF;

  IF fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN

	l_total_rec_xtd_detail_drill := 'pFunctionName=FII_AR_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||
	                                 inline_view.party_id||''&BIS_PMV_DRILL_CODE_AS_OF_DATE='||l_curr_month_end_drill||'&pParamIds=Y';

	l_app_rec_xtd_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&FII_AR_CUST_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&pParamIds=Y';

  -- Bug# 5137713. Passing Customer Name explicitly when ViewBy is Customer Account
	l_total_rec_count_drill := 'pFunctionName=FII_AR_REC_ACTIVITY_TREND&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inline_view.party_id||''&pParamIds=Y';
  ELSE
	l_total_rec_xtd_detail_drill := 'pFunctionName=FII_AR_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&BIS_PMV_DRILL_CODE_AS_OF_DATE='||l_curr_month_end_drill||'&pParamIds=Y';

	l_app_rec_xtd_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
  END IF;

  --Setting up the where clauses based on the Parameter and viewby
  --for Collector Dimension
  IF (fii_ar_util_pkg.g_collector_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') THEN
  	l_collector_where := 'AND f.collector_id = t.collector_id';
  END IF;

 --Customer Dimension where clause
 IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
  l_party_where := ' AND f.party_id = t.party_id ';
 END IF;

 --Industry Dimension where clause
 IF (fii_ar_util_pkg.g_industry_id <> '-111' AND fii_ar_util_pkg.g_view_by <> 'CUSTOMER+FII_CUSTOMERS') OR
	fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN

	l_industry_where :=  ' AND f.class_code = t.class_code AND f.class_category = t.class_category';
  END IF;

  -- Select, where, group by clauses based on viewby
  If((fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS') OR (fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') OR (fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS')) THEN
	l_total_rec_xtd_drill := ''''||l_total_rec_xtd_summary_dr_1||'''';

	l_total_applied_xtd_drill := ''''||l_app_rec_xtd_summary_dr_1||'''';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
  	l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
	l_total_rec_xtd_drill := ''''||l_total_rec_xtd_detail_drill||'''';

	l_total_applied_xtd_drill := ''''||l_app_rec_xtd_detail_drill||'''';

	l_cust_acct_where := 'AND f.cust_account_id = t.cust_account_id';

	l_inner_cst_columns := l_inner_cst_columns || ' ,t.party_id';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	IF (fii_ar_util_pkg.g_is_hierarchical_flag = 'Y') THEN
		l_total_rec_xtd_drill := 'DECODE(is_self_flag, ''Y'',
					'''||l_total_rec_xtd_detail_drill||''', DECODE(is_leaf_flag,''Y'',
									'''||l_total_rec_xtd_detail_drill||''', '''||l_total_rec_xtd_summary_drill||'''))';

		l_total_applied_xtd_drill := 'DECODE(is_self_flag, ''Y'',
						'''||l_app_rec_xtd_detail_drill||''', DECODE(is_leaf_flag,''Y'',
							'''||l_app_rec_xtd_detail_drill||''', '''||l_app_rec_xtd_summary_drill||'''))';
	ELSE
		l_total_rec_xtd_drill := ''''||l_total_rec_xtd_detail_drill||'''';

		l_total_applied_xtd_drill := ''''||l_app_rec_xtd_detail_drill||'''';
	END IF;

        -- Select clause, Where clause, Group By clause and self drills for Customer Dimension

	l_inner_cst_columns := ',is_self_flag, is_leaf_flag';
	l_parent_party_where := 'AND f.parent_party_id = t.parent_party_id';

	--Self drill. This is reqd only in case of Viewby Customer
	--Check dynamically if the node is leaf or not. In case of non-leaf this drill is to be enabled.


	l_summary_drill := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';

	l_customer_drill := 'DECODE(is_self_flag, ''Y'', '''',
						DECODE(inline_view.is_leaf_flag, ''Y'','''',
										'''||l_summary_drill||'''))';

  END IF;

  -- Report Query

  sqlstmt := '

SELECT
	inline_view.viewby VIEWBY,
	inline_view.viewby_id	    VIEWBYID,
	FII_AR_TOTAL_REC_PRIOR_XTD FII_AR_TOTAL_REC_PRIOR_XTD_G,
	FII_AR_TOTAL_REC_XTD FII_AR_TOTAL_REC_XTD_G,
	/*Change calculation. This could have been done in the AK Region as well,
	but since sorting is to be enabled on this column, so doing this calculation here.*/
	((FII_AR_TOTAL_REC_XTD - FII_AR_TOTAL_REC_PRIOR_XTD)/
        ABS(NULLIF(FII_AR_TOTAL_REC_PRIOR_XTD,0))) * 100 FII_AR_TOTAL_REC_CHANGE,
	FII_AR_TOTAL_REC_XTD,
	FII_AR_TOTAL_REC_PRIOR_XTD,
	FII_AR_TOTAL_REC_COUNT,
	FII_AR_APPLIED_REC_XTD,
	/*FII_AR_APPLIED_REC_COUNT, */
	FII_AR_REV_REC_COUNT,
	SUM(FII_AR_TOTAL_REC_XTD) OVER() FII_AR_GT_TOTAL_REC_XTD,
	/* Grand total of Change column*/
	(SUM(FII_AR_TOTAL_REC_XTD) OVER() - SUM(FII_AR_TOTAL_REC_PRIOR_XTD) OVER()) /
        ABS(NULLIF(SUM(FII_AR_TOTAL_REC_PRIOR_XTD) over(),0)) * 100  FII_AR_GT_TOTAL_REC_CHANGE,
	SUM(FII_AR_TOTAL_REC_COUNT) OVER() FII_AR_GT_TOTAL_REC_COUNT,
	SUM(FII_AR_APPLIED_REC_XTD) OVER() FII_AR_GT_APPLIED_REC_XTD,
	/*SUM(FII_AR_APPLIED_REC_COUNT) OVER() FII_AR_GT_APPLIED_REC_COUNT,*/
	SUM(FII_AR_REV_REC_COUNT) OVER() FII_AR_GT_REV_REC_COUNT,
 	/* Amount Drills */
	DECODE(FII_AR_TOTAL_REC_XTD,0,'''',DECODE(NVL(FII_AR_TOTAL_REC_XTD,-999999),-999999,'''',
	'||l_total_rec_xtd_drill||')) FII_AR_TOTAL_REC_XTD_DRILL,
	DECODE(FII_AR_TOTAL_REC_XTD,0,'''',DECODE(NVL(FII_AR_TOTAL_REC_COUNT,-999999),-999999,'''',
	'''||l_total_rec_count_drill||''')) FII_AR_TOTAL_REC_COUNT_DRILL,
	DECODE(FII_AR_APPLIED_REC_XTD,0,'''',DECODE(NVL(FII_AR_APPLIED_REC_XTD,-999999),-999999,'''',
	'||l_total_applied_xtd_drill||')) FII_AR_APPLIED_REC_XTD_DRILL,
	'||l_customer_drill||' FII_AR_CUST_SELF_DRILL
  FROM (
	SELECT	 /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
	  t.viewby		VIEWBY,
		   t.viewby_code	viewby_id
		   '||l_inner_cst_columns||',
	           SUM(CASE WHEN (t.report_date = :ASOF_DATE) and
	               (f.header_filter_date <= :ASOF_DATE) and
	               (f.header_filter_date >= :CURR_PERIOD_START)
	               THEN total_receipt_amount ELSE NULL END) FII_AR_TOTAL_REC_XTD,
                   SUM(CASE WHEN (t.report_date = :ASOF_DATE) and
		       (f.header_filter_date <= :ASOF_DATE) and
		       (f.header_filter_date >= :CURR_PERIOD_START)
		       THEN total_receipt_count ELSE NULL END) FII_AR_TOTAL_REC_COUNT,
		   SUM(DECODE(t.report_date, :ASOF_DATE, app_amount) )   FII_AR_APPLIED_REC_XTD,
   		   /*SUM(DECODE(t.report_date, ASOF_DATE, app_count) )   FII_AR_APPLIED_REC_COUNT,*/
      		   SUM(DECODE(t.report_date, :ASOF_DATE, rev_count) )   FII_AR_REV_REC_COUNT,
	           SUM(CASE WHEN (t.report_date = :PREVIOUS_ASOF_DATE) and
		       (f.header_filter_date <= :PREVIOUS_ASOF_DATE) and
		       (f.header_filter_date >= :PRIOR_PERIOD_START)
		       THEN total_receipt_amount ELSE NULL END) FII_AR_TOTAL_REC_PRIOR_XTD
	FROM	   FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||'  f,
		  (	SELECT	/*+ no_merge '||l_gt_hint|| ' */  *
		        FROM 	fii_time_structures cal,'||fii_ar_util_pkg.get_from_statement||'
		     	gt WHERE	report_date IN ( :ASOF_DATE, :PREVIOUS_ASOF_DATE)
				AND (bitand(cal.record_type_id, :BITAND) = :BITAND)
				AND '||fii_ar_util_pkg.get_where_statement||'
		     ) t
	WHERE	  f.time_id = t.time_id
        AND f.period_type_id = t.period_type_id
	AND f.org_id = t.org_id
	AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_party_where||' '|| l_parent_party_where ||' ' || l_collector_where ||'
	'|| l_industry_where||'  '|| l_cust_acct_where ||'
	GROUP BY VIEWBY, t.viewby_code '||l_inner_cst_columns||') inline_view
	'||l_order_by;

fii_ar_util_pkg.bind_variable(sqlstmt, p_page_parameter_tbl, rec_activity_sql, rec_activity_output);

END get_rec_activity;

END FII_AR_REC_ACTIVITY_PKG;

/
