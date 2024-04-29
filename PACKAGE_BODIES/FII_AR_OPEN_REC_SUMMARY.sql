--------------------------------------------------------
--  DDL for Package Body FII_AR_OPEN_REC_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_OPEN_REC_SUMMARY" AS
/* $Header: FIIARDBIORSB.pls 120.17 2007/05/15 20:50:37 vkazhipu ship $ */

PROCEDURE get_open_rec_sum (p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                            open_rec_sum_sql     OUT NOCOPY VARCHAR2,
                            open_rec_sum_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

l_party_select		VARCHAR2(100);
l_party_group_by	VARCHAR2(100);
l_party_where 		VARCHAR2(250);
l_parent_party_where 	VARCHAR2(250);
l_collector_where	VARCHAR2(250);
l_cust_acct_where	VARCHAR2(250);

l_cust_drill            VARCHAR2(500);
l_open_drill            VARCHAR2(500);
l_pdue_drill            VARCHAR2(500);
l_curr_drill            VARCHAR2(500);

l_select		VARCHAR2(10000);
l_group_by 		VARCHAR2(100) := NULL;
l_order_by		VARCHAR2(250);
l_order_column		VARCHAR2(250);
l_self                  VARCHAR2(30);
l_gt_hint varchar2(500);


BEGIN

-- init all variables
fii_ar_util_pkg.reset_globals;

-- get global variables assigned
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

-- populate dimension combinations in global temp tables
fii_ar_util_pkg.populate_summary_gt_tables;

-- get viewby id (party_id, cust_account_id, org_id, collector_id)
-- fii_ar_util_pkg.get_viewby_id(l_viewby_id);
l_gt_hint := ' leading(gt) cardinality(gt 1) ';
-- generate where clause for party_id
IF (fii_ar_util_pkg.g_party_id <> '-111' OR
	fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	l_party_where := ' AND f.party_id   = t.party_id ';
END IF;

-- generate where clause for parent_party_id
IF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	l_parent_party_where := 'AND f.parent_party_id = t.parent_party_id ';
END IF;

-- generate where clause for collector_id
IF (fii_ar_util_pkg.g_collector_id <> '-111' OR
	fii_ar_util_pkg.g_view_by = 'FII_COLLECTOR+FII_COLLECTOR') THEN
	l_collector_where := 'AND f.collector_id = t.collector_id ';
END IF;

-- generate where clause for cust_account_id
IF (fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
	l_cust_acct_where := 'AND f.cust_account_id = t.cust_account_id';
	l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
END IF;


-- handle drills
IF (fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS' AND fii_ar_util_pkg.g_is_hierarchical_flag='Y') THEN

l_self := ' t.is_self_flag,';
l_open_drill :=
' DECODE(FII_AR_ORS_OPEN_REC_AMT,0,'''', DECODE(inline_view.is_leaf_flag, ''Y'',''pFunctionName=FII_AR_OPEN_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',
''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'')) ';

l_pdue_drill :=
' DECODE(FII_AR_ORS_PDUE_REC_AMT,0,'''', DECODE(inline_view.is_leaf_flag, ''Y'',''pFunctionName=FII_AR_PDUE_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',
''pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'')) ';

l_curr_drill :=
' DECODE(FII_AR_ORS_CURR_REC_AMT,0,'''', DECODE(inline_view.is_leaf_flag, ''Y'',''pFunctionName=FII_AR_CURR_REC_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',
''pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'')) ';

l_cust_drill :=
' DECODE(inline_view.is_self_flag,''Y'','''', DECODE(inline_view.is_leaf_flag, ''Y'','''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y'')) ';


-- Add SELF to Customer description for self nodes
--l_viewby:= 'DECODE(inline_view.parent_party_id,inline_view.viewby, DECODE(inline_view.is_leaf_flag, ''Y'', inline_view.viewby, inline_view.viewby '||'||'||'''('||fii_ar_util_pkg.g_self_msg||')'''||'), inline_view.viewby) ';
l_group_by := ' inline_view.is_self_flag, inline_view.viewby, inline_view.is_leaf_flag, inline_view.viewby_code ';

ELSIF (fii_ar_util_pkg.g_view_by= 'FII_COLLECTOR+FII_COLLECTOR'
	OR 	fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS') THEN
 IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
		l_open_drill :=
			' DECODE(FII_AR_ORS_OPEN_REC_AMT,0,'''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'') ';

		l_pdue_drill :=
			' DECODE(FII_AR_ORS_PDUE_REC_AMT,0,'''',''pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'') ';

		l_curr_drill :=
		' DECODE(FII_AR_ORS_CURR_REC_AMT,0,'''',''pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y'') ';
 ELSE
   l_open_drill :=
			' DECODE(FII_AR_ORS_OPEN_REC_AMT,0,'''',''pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'') ';

		l_pdue_drill :=
			' DECODE(FII_AR_ORS_PDUE_REC_AMT,0,'''',''pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'') ';

		l_curr_drill :=
		' DECODE(FII_AR_ORS_CURR_REC_AMT,0,'''',''pFunctionName=FII_AR_CURR_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'') ';

END IF;
l_cust_drill := '''''';

l_group_by := 'inline_view.viewby, inline_view.viewby_code ';

ELSE -- this is the case of (fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS')

l_party_select   := ' t.party_id,';
l_party_group_by := ' t.party_id, ';

l_open_drill :=
' DECODE(FII_AR_ORS_OPEN_REC_AMT,0,'''',''pFunctionName=FII_AR_OPEN_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

l_pdue_drill :=
' DECODE(FII_AR_ORS_PDUE_REC_AMT,0,'''',''pFunctionName=FII_AR_PDUE_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

l_curr_drill :=
' DECODE(FII_AR_ORS_CURR_REC_AMT,0,'''',''pFunctionName=FII_AR_CURR_REC_DTL&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||party_id||''&FII_AR_CUST_ACCOUNT=VIEWBYID&pParamIds=Y'') ';

l_cust_drill := '''''';

l_group_by := 'inline_view.viewby, inline_view.viewby_code, inline_view.party_id ';

END IF;


IF INSTR(fii_ar_util_pkg.g_order_by,',') <> 0 THEN

   /*This means no particular sort column is selected in the report
   So sort on the default column in descending order
   NVL is added to make sure the null values appear last*/

   l_order_by := 'ORDER BY NVL(FII_AR_ORS_OPEN_REC_AMT, -999999999) DESC';

ELSIF instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0 THEN

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

l_select :=
' SELECT
viewby       VIEWBY,
viewby_code  VIEWBYID,
FII_AR_ORS_OPEN_REC_AMT,
FII_AR_ORS_PDUE_REC_AMT,
FII_AR_ORS_CURR_REC_AMT,
FII_AR_ORS_OPEN_REC_CT,
FII_AR_ORS_PDUE_REC_CT,
FII_AR_ORS_CURR_REC_CT,
FII_AR_ORS_OPEN_REC_WTD_TRM,
FII_AR_ORS_PDUE_REC_PERCENT,
FII_AR_ORS_PDUE_REC_WTD_DDSO,
SUM(FII_AR_ORS_OPEN_REC_AMT) over() FII_AR_ORS_OPEN_R_AMT_GT,
SUM(FII_AR_ORS_PDUE_REC_AMT) over() FII_AR_ORS_PDUE_R_AMT_GT,
SUM(FII_AR_ORS_CURR_REC_AMT) over() FII_AR_ORS_CURR_R_AMT_GT,
SUM(FII_AR_ORS_OPEN_REC_CT)  over() FII_AR_ORS_OPEN_R_CT_GT,
SUM(FII_AR_ORS_PDUE_REC_CT)  over() FII_AR_ORS_PDUE_R_CT_GT,
SUM(FII_AR_ORS_CURR_REC_CT)  over() FII_AR_ORS_CURR_R_CT_GT,
CASE WHEN sum(FII_AR_ORS_OPEN_REC_AMT) over() = 0
     THEN NULL
     ELSE sum(FII_AR_ORS_OPEN_REC_WTD_TRM_N) over() / sum(FII_AR_ORS_OPEN_REC_AMT) over()
     END  FII_AR_ORS_OPEN_R_WTD_TRM_GT,
CASE WHEN sum(FII_AR_ORS_OPEN_REC_AMT) over() = 0
     THEN NULL
     ELSE (sum(FII_AR_ORS_PDUE_REC_AMT) over() / sum(FII_AR_ORS_OPEN_REC_AMT) over()) * 100
	 END FII_AR_ORS_PDUE_R_PERCENT_GT,
CASE WHEN sum(FII_AR_ORS_PDUE_REC_AMT) over() = 0
     THEN NULL
     ELSE (sum(FII_AR_ORS_PDUE_REC_AMT) over()
	       * to_number(to_char(&BIS_CURRENT_ASOF_DATE,''J''))
	       - sum(FII_AR_ORS_PDUE_REC_WTD_DDSO_N) over()) / sum(FII_AR_ORS_PDUE_REC_AMT) over()
     END FII_AR_ORS_PDUE_R_WTD_DDSO_GT,
'|| l_cust_drill ||' FII_AR_ORS_CUST_DRILL,
'|| l_open_drill ||' FII_AR_ORS_OPEN_DRILL,
'|| l_pdue_drill ||' FII_AR_ORS_PDUE_DRILL,
'|| l_curr_drill ||' FII_AR_ORS_CURR_DRILL
FROM (
SELECT  /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
t.is_leaf_flag,
'||l_self||'
'||l_party_select||'
t.viewby,
t.viewby_code,
sum(total_open_amount)                       FII_AR_ORS_OPEN_REC_AMT,
sum(past_due_open_amount)                         FII_AR_ORS_PDUE_REC_AMT,
sum(current_open_amount)                     FII_AR_ORS_CURR_REC_AMT,
sum(total_open_count)                        FII_AR_ORS_OPEN_REC_CT,
sum(past_due_count)                          FII_AR_ORS_PDUE_REC_CT,
sum(current_open_count)                      FII_AR_ORS_CURR_REC_CT,
sum(wtd_terms_out_open_num)                  FII_AR_ORS_OPEN_REC_WTD_TRM_N,
sum(wtd_DDSO_due_num)                        FII_AR_ORS_PDUE_REC_WTD_DDSO_N,
CASE WHEN abs(sum(total_open_amount)) = 0
     THEN NULL
     ELSE sum(wtd_terms_out_open_num) / abs(sum(total_open_amount))
     END  FII_AR_ORS_OPEN_REC_WTD_TRM,
CASE WHEN abs(sum(total_open_amount)) = 0
     THEN NULL
     ELSE sum(past_due_open_amount) / abs(sum(total_open_amount)) * 100
     END  FII_AR_ORS_PDUE_REC_PERCENT,
CASE WHEN abs(sum(past_due_open_amount)) = 0
     THEN NULL
     ELSE (sum(past_due_open_amount)
	       * to_number(to_char(&BIS_CURRENT_ASOF_DATE ,''J''))
	       - sum(wtd_DDSO_due_num)) / abs(sum(past_due_open_amount))
     END FII_AR_ORS_PDUE_REC_WTD_DDSO
FROM FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
     (
     SELECT /*+ no_merge '||l_gt_hint|| ' */ *
       FROM fii_time_structures cal,
            '||fii_ar_util_pkg.get_from_statement||' gt
      WHERE report_date = :ASOF_DATE
        AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
        AND '  ||fii_ar_util_pkg.get_where_statement||'
	  ) t
WHERE  f.time_id = t.time_id
  AND  f.period_type_id = t.period_type_id
  AND  f.org_id = t.org_id
  AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_parent_party_where||l_party_where||l_collector_where|| l_cust_acct_where||'
GROUP BY  t.is_leaf_flag, '||l_self||l_party_group_by||' t.viewby, t.viewby_code)  inline_view
GROUP BY '||l_group_by||',
FII_AR_ORS_OPEN_REC_AMT,
FII_AR_ORS_PDUE_REC_AMT,
FII_AR_ORS_CURR_REC_AMT,
FII_AR_ORS_OPEN_REC_CT,
FII_AR_ORS_PDUE_REC_CT,
FII_AR_ORS_CURR_REC_CT,
FII_AR_ORS_OPEN_REC_WTD_TRM_N,
FII_AR_ORS_OPEN_REC_WTD_TRM,
FII_AR_ORS_PDUE_REC_PERCENT,
FII_AR_ORS_PDUE_REC_WTD_DDSO_N,
FII_AR_ORS_PDUE_REC_WTD_DDSO
'||l_order_by||' ';

fii_ar_util_pkg.bind_variable(l_select, p_page_parameter_tbl, open_rec_sum_sql, open_rec_sum_output);

END get_open_rec_sum;

END FII_AR_OPEN_REC_SUMMARY;

/
