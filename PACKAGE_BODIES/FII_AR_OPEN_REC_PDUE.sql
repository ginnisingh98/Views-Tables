--------------------------------------------------------
--  DDL for Package Body FII_AR_OPEN_REC_PDUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_OPEN_REC_PDUE" AS
/* $Header: FIIARDBIPDB.pls 120.15 2007/05/15 20:51:17 vkazhipu ship $ */



PROCEDURE get_rec_pdue (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

l_party_where 		VARCHAR2(250);
l_parent_party_where 	VARCHAR2(250);
l_collector_where	VARCHAR2(250);
l_cust_acct_where	VARCHAR2(250);
l_cust_self_drill	VARCHAR2(500);
l_past_due_rec_drill	VARCHAR2(500);
l_open_rec_drill	VARCHAR2(500);
l_select		VARCHAR2(10000);
l_group_by 		VARCHAR2(100) := NULL;
l_order_by		VARCHAR2(250);
l_order_column		VARCHAR2(250);
l_self                  VARCHAR2(25);
l_party_select		VARCHAR2(50);
l_party_groupby		VARCHAR2(50);
l_gt_hint varchar2(500);
BEGIN

fii_ar_util_pkg.reset_globals;
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
fii_ar_util_pkg.populate_summary_gt_tables;



l_gt_hint := ' leading(gt) cardinality(gt 1) ';

/* Dynamically generating the where clause for PARTY_ID*/
IF (fii_ar_util_pkg.g_party_id <> '-111' OR
	fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	l_party_where := ' AND f.party_id   = t.party_id ';
END IF;

/* Dynamically generating the where clause for PARENT_PARTY_ID */
IF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	l_parent_party_where := 'AND f.parent_party_id = t.parent_party_id ';
END IF;

/* Dynamically generating the where clause for COLLECTOR_ID*/
IF (fii_ar_util_pkg.g_collector_id <> '-111' OR
	fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') THEN
	l_collector_where := 'AND f.collector_id = t.collector_id ';
END IF;

l_party_select := ' ';
l_party_groupby := ' ';

/* Drills */
IF (fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS' AND fii_ar_util_pkg.g_is_hierarchical_flag='Y') THEN

l_self := ' t.is_self_flag,';

	l_past_due_rec_drill:=
	' DECODE(FII_AR_PDUE_REC,0,'''',DECODE(inline_view.is_self_flag, ''Y'',''pFunctionName=FII_AR_PDUE_REC_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'',DECODE(inline_view.is_leaf_flag, ''Y'' ,
''pFunctionName=FII_AR_PDUE_REC_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'', ''pFunctionName=FII_AR_OPEN_REC_PDUE&VIEW_BY_NAME=VIEW_BY_ID
&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y''))) ';

	l_open_rec_drill :=
	' DECODE(FII_AR_OPEN_REC,0,'''',DECODE(inline_view.is_self_flag, ''Y'',''pFunctionName=FII_AR_OPEN_REC_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'',DECODE(inline_view.is_leaf_flag, ''Y'' ,
''pFunctionName=FII_AR_OPEN_REC_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'', ''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID
&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y''))) ';

/* Drills to children on Customer dimension */
	l_cust_self_drill :=' DECODE(inline_view.is_self_flag,''Y'','''', DECODE(inline_view.is_leaf_flag, ''Y'','''',''pFunctionName=FII_AR_OPEN_REC_PDUE&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')) ';

	l_group_by := ' inline_view.is_self_flag,inline_view.viewby,inline_view.is_leaf_flag,inline_view.viewby_id ';

ELSIF 	(fii_ar_util_pkg.g_view_by= 'FII_COLLECTOR+FII_COLLECTOR'
	OR 	fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' ) THEN
 IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
/* Calls Open Receivables: Percent Past Due - View by Customer Account*/
	l_past_due_rec_drill := ' DECODE(FII_AR_PDUE_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_PDUE&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'') ';

/* Calls Open Receivables Summary - View by Customer Account*/
	l_open_rec_drill := ' DECODE(FII_AR_OPEN_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'') ';
 ELSE
  /* Calls Open Receivables: Percent Past Due - View by Customer*/
	l_past_due_rec_drill := ' DECODE(FII_AR_PDUE_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_PDUE&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'') ';

/* Calls Open Receivables Summary - View by Customer*/
	l_open_rec_drill := ' DECODE(FII_AR_OPEN_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'') ';


 END IF;
	l_cust_self_drill := ''' ''';
	l_group_by := 'inline_view.viewby, inline_view.viewby_id ';

ELSIF (fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
  l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
	l_party_select := ' t.party_id party_id, ';
	l_party_groupby := ',t.party_id ';

/* Dynamically generating the where clause for Customer Account */
        l_cust_acct_where := 'AND f.cust_account_id = t.cust_account_id';

/* Calls Past Due Receivales Detail report  */
        l_past_due_rec_drill := '
DECODE(FII_AR_PDUE_REC,0,'''',''pFunctionName=FII_AR_PDUE_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

/* Calls Open Receivables Detail report  */
        l_open_rec_drill := '
DECODE(FII_AR_OPEN_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

	l_cust_self_drill := ''' ''';

        l_group_by := 'inline_view.viewby,
inline_view.viewby_id,inline_view.party_id ';

ELSE

/* Calls Past Due Receivales Detail report  */
	l_past_due_rec_drill := ' DECODE(FII_AR_PDUE_REC,0,'''',''pFunctionName=FII_AR_PDUE_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

/* Calls Open Receivables Detail report  */
	l_open_rec_drill := ' DECODE(FII_AR_OPEN_REC,0,'''',''pFunctionName=FII_AR_OPEN_REC_DTL&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';
	l_cust_self_drill := ''' ''';

	l_group_by := 'inline_view.viewby, inline_view.viewby_id ';
END IF;


IF INSTR(fii_ar_util_pkg.g_order_by,',') <> 0 THEN
   l_order_by := 'ORDER BY NVL(FII_AR_PERC_OPEN_REC, -999999999) DESC';

ELSIF instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0 THEN
   l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
   l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';
ELSE
   l_order_by := '&ORDER_BY_CLAUSE';
END IF;


l_select :=
' SELECT  inline_view.viewby  viewby,
viewby_id    VIEWBYID,
(FII_AR_PRIOR_PDUE_REC/NULLIF(abs(FII_AR_PRIOR_OPEN_REC),0))*100 FII_AR_PERC_PRIOR_OPEN_REC,
(FII_AR_PDUE_REC/NULLIF(abs(FII_AR_OPEN_REC),0))*100 FII_AR_PERC_OPEN_REC_G,
(FII_AR_PDUE_REC/NULLIF(abs(FII_AR_OPEN_REC),0))*100 FII_AR_PERC_OPEN_REC,
FII_AR_PDUE_REC,
FII_AR_OPEN_REC,
FII_AR_PRIOR_PDUE_REC,
FII_AR_PRIOR_OPEN_REC,
'||l_open_rec_drill||' FII_AR_OPEN_REC_DRILL,
'||l_past_due_rec_drill||' FII_AR_PDUE_REC_DRILL,
'||l_cust_self_drill||' FII_AR_CUST_SELF_DRILL,
SUM(FII_AR_PDUE_REC) over() FII_AR_PDUE_REC_GT,
SUM(FII_AR_OPEN_REC) over() FII_AR_OPEN_REC_GT,
CASE WHEN SUM(FII_AR_OPEN_REC) over() = 0 THEN NULL
ELSE (SUM(FII_AR_PDUE_REC) over()/SUM(FII_AR_OPEN_REC) over()) *100 END FII_AR_PERC_OPEN_REC_GT
FROM (
SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
t.is_leaf_flag,
'||l_self||'
t.viewby viewby,
viewby_code viewby_id ,
'||l_party_select||'
SUM(DECODE(t.report_date, :ASOF_DATE , past_due_open_amount , NULL ) )   FII_AR_PDUE_REC,
SUM(DECODE(t.report_date, :ASOF_DATE, total_open_amount, NULL ) )   FII_AR_OPEN_REC,
SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE, past_due_open_amount, NULL ) )   FII_AR_PRIOR_PDUE_REC,
SUM(DECODE(t.report_date, :PREVIOUS_ASOF_DATE, total_open_amount, NULL ) )   FII_AR_PRIOR_OPEN_REC
FROM FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
( SELECT  /*+ no_merge '||l_gt_hint|| ' */ *
	FROM 	fii_time_structures cal, '||fii_ar_util_pkg.get_from_statement||' gt
	WHERE report_date in (:ASOF_DATE,  :PREVIOUS_ASOF_DATE)
	AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
	AND '  ||fii_ar_util_pkg.get_where_statement||' ) t
WHERE  f.time_id = t.time_id
AND f.period_type_id = t.period_type_id
AND f.org_id = t.org_id
AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_parent_party_where||l_party_where||l_collector_where|| l_cust_acct_where||'
GROUP BY '||l_self||' t.is_leaf_flag, t.viewby, viewby_code'||l_party_groupby||')  inline_view
GROUP BY '||l_group_by||', FII_AR_OPEN_REC,FII_AR_PDUE_REC, FII_AR_PRIOR_OPEN_REC, FII_AR_PRIOR_PDUE_REC
'||l_order_by||' ';

fii_ar_util_pkg.bind_variable(l_select, p_page_parameter_tbl, open_rec_sql, open_rec_output);

END get_rec_pdue;

END FII_AR_OPEN_REC_PDUE;


/
